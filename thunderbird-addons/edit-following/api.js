/*
 * Finishes Thunderbird's half-built "this and all following occurrences" choice
 * for recurring events: the occurrence prompt already has the button, hidden,
 * and promptOccurrenceModification() throws NS_ERROR_NOT_IMPLEMENTED for it
 * (calendar-item-editing.js in omni.ja, Thunderbird 156).
 *
 * In the prompt, the button shows for editing or deleting one event without
 * attendees. In the main window, promptOccurrenceModification() is replaced by a
 * copy that handles the button, and modifyEventWithDialog() is wrapped to open
 * the editor on the future part of the series. Both functions are restored when
 * the add-on shuts down.
 */

/* global ExtensionCommon, ExtensionSupport, cal, Services */
"use strict";

var { ExtensionCommon } = ChromeUtils.importESModule(
  "resource://gre/modules/ExtensionCommon.sys.mjs"
);
var { ExtensionSupport } = ChromeUtils.importESModule(
  "resource:///modules/ExtensionSupport.sys.mjs"
);
var { cal } = ChromeUtils.importESModule("resource:///modules/calendar/calUtils.sys.mjs");

const LISTENER_ID = "edit-following@dotfiles";
const MAIN_URL = "chrome://messenger/content/messenger.xhtml";
const PROMPT_URL = "chrome://calendar/content/calendar-occurrence-prompt.xhtml";

// the prompt's return values, as in promptOccurrenceModification()
const CANCEL = 0;
const MODIFY_OCCURRENCE = 1;
const MODIFY_FOLLOWING = 2;
const MODIFY_PARENT = 3;

var editFollowing = class extends ExtensionCommon.ExtensionAPI {
  onStartup() {
    // loadSubScript() refuses the add-on's own file: and moz-extension: URLs,
    // so serve its folder under chrome://edit-following/content/ instead
    const aomStartup = Cc["@mozilla.org/addons/addon-manager-startup;1"].getService(
      Ci.amIAddonManagerStartup
    );
    const manifestURI = Services.io.newURI("manifest.json", null, this.extension.rootURI);
    this.chromeHandle = aomStartup.registerChrome(manifestURI, [
      ["content", "edit-following", "./"],
    ]);

    const scope = { cal };
    Services.scriptloader.loadSubScript("chrome://edit-following/content/split.js", scope);
    const { splitSeries } = scope;

    ExtensionSupport.registerWindowListener(LISTENER_ID, {
      chromeURLs: [MAIN_URL, PROMPT_URL],
      onLoadWindow(win) {
        if (win.location.href == PROMPT_URL) {
          showFollowingButton(win);
        } else {
          patchMainWindow(win, splitSeries);
        }
      },
    });
  }

  onShutdown(isAppShutdown) {
    if (isAppShutdown) {
      return;
    }
    ExtensionSupport.unregisterWindowListener(LISTENER_ID);
    for (const win of Services.wm.getEnumerator("mail:3pane")) {
      unpatchMainWindow(win);
    }
    this.chromeHandle.destruct();
    this.chromeHandle = null;
    // loadSubScript() caches split.js under its chrome:// URL, which stays the
    // same across reinstalls
    Services.obs.notifyObservers(null, "startupcache-invalidate");
  }

  getAPI() {
    return { editFollowing: {} };
  }
};

/** Show the prompt's hidden "all following" button when this add-on can handle it. */
function showFollowingButton(win) {
  const args = win.arguments[0];
  const action = args.action || "edit";
  if ((action != "edit" && action != "delete") || args.items.length != 1) {
    return;
  }
  const item = args.items[0];
  if (!item.isEvent() || item.getAttendees().length || !item.parentItem.recurrenceInfo) {
    return;
  }
  win.document.getElementById("accept-allfollowing-button").hidden = false;
}

/** Replace the main window's occurrence prompt and edit function with versions that handle "all following". */
function patchMainWindow(win, splitSeries) {
  if (
    typeof win.promptOccurrenceModification != "function" ||
    typeof win.modifyEventWithDialog != "function"
  ) {
    return;
  }
  const originals = {
    promptOccurrenceModification: win.promptOccurrenceModification,
    modifyEventWithDialog: win.modifyEventWithDialog,
  };
  win.editFollowingOriginals = originals;

  // a copy of Thunderbird's version, plus the MODIFY_FOLLOWING case; deleting
  // happens here, since the delete code takes only the returned item, while
  // editing is left to modifyEventWithDialog() below
  win.promptOccurrenceModification = function (aItem, aNeedsFuture, aAction) {
    const items = Array.isArray(aItem) ? aItem : [aItem];
    if (items.every(item => item == item.parentItem)) {
      return originals.promptOccurrenceModification.call(win, aItem, aNeedsFuture, aAction);
    }

    const rv = { value: CANCEL, items, action: aAction };
    win.openDialog(PROMPT_URL, "PromptOccurrenceModification", "centerscreen,chrome,modal,titlebar", rv);

    switch (rv.value) {
      case MODIFY_PARENT: {
        const parents = items.map(item => item.parentItem);
        return [Array.isArray(aItem) ? parents : parents[0], false, MODIFY_PARENT];
      }
      case MODIFY_OCCURRENCE:
        return [aItem, false, MODIFY_OCCURRENCE];
      case MODIFY_FOLLOWING: {
        if (aAction != "delete") {
          return [aItem, false, MODIFY_FOLLOWING];
        }
        const parent = items[0].parentItem;
        const split = splitSeries(parent, items[0].recurrenceId);
        if (!split) {
          return [parent, false, MODIFY_PARENT];
        }
        // the delete code runs inside a batch, so this joins its Undo step;
        // CANCEL makes it delete nothing more
        win.doTransaction("modify", split.past, parent.calendar, parent);
        return [null, false, CANCEL];
      }
      default:
        return [null, false, CANCEL];
    }
  };

  win.modifyEventWithDialog = function (aItem, aPromptOccurrence, initialDate = null, aCounterProposal) {
    if (aPromptOccurrence === false || aItem == aItem.parentItem || cal.item.findWindow(aItem)) {
      return originals.modifyEventWithDialog.call(win, aItem, aPromptOccurrence, initialDate, aCounterProposal);
    }

    const [item, , response] = win.promptOccurrenceModification(aItem, true, "edit");
    if (response != MODIFY_FOLLOWING) {
      if (item && response) {
        originals.modifyEventWithDialog.call(win, item, false, initialDate, aCounterProposal);
      }
      return undefined;
    }

    const parent = aItem.parentItem;
    const split = splitSeries(parent, aItem.recurrenceId);
    if (!split) {
      return originals.modifyEventWithDialog.call(win, parent, false, initialDate, aCounterProposal);
    }

    // the editor works on the future series; on save, add it and shorten the
    // original as one Undo step; adding first leaves the original untouched
    // if the new series can't be saved
    const onSave = (newItem, calendar, originalItem, listener, extResponse) => {
      win.startBatchTransaction();
      try {
        win.doTransaction("add", newItem, calendar, null, listener, extResponse);
        win.doTransaction("modify", split.past, parent.calendar, parent);
      } finally {
        win.endBatchTransaction();
      }
    };
    win.openEventDialog(split.future, parent.calendar, "modify", onSave, initialDate);
    return undefined;
  };
}

/** Put back the main window's original functions. */
function unpatchMainWindow(win) {
  const originals = win.editFollowingOriginals;
  if (!originals) {
    return;
  }
  Object.assign(win, originals);
  delete win.editFollowingOriginals;
}
