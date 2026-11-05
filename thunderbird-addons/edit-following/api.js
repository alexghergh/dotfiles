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
 *
 * Double-clicking an event opens a summary window instead of the prompt; its
 * Edit menu calls the main window's modifyEventWithDialog() without prompting,
 * so the same choice is added there as a menu item, for the same events.
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
const SUMMARY_URL = "chrome://calendar/content/calendar-summary-dialog.xhtml";

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
      chromeURLs: [MAIN_URL, PROMPT_URL, SUMMARY_URL],
      onLoadWindow(win) {
        if (win.location.href == PROMPT_URL) {
          showFollowingButton(win);
        } else if (win.location.href == SUMMARY_URL) {
          addFollowingMenuItem(win, splitSeries);
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
  if (canSplit(args.items[0])) {
    win.document.getElementById("accept-allfollowing-button").hidden = false;
  }
}

/** Add "this and all future occurrences" to the Edit menu of the summary window that double-clicking an event opens. */
function addFollowingMenuItem(win, splitSeries) {
  const occurrence = win.arguments[0].calendarEvent;
  if (occurrence == occurrence.parentItem || !canSplit(occurrence)) {
    return;
  }

  const doc = win.document;
  const menuItem = doc.createXULElement("menuitem");
  menuItem.setAttribute("label", "Edit this and all future occurrences");
  menuItem.setAttribute("accesskey", "f");
  // the same steps as the menu's own items (useEditDialog() in
  // calendar-summary-dialog.js): the editor opens from the main window once
  // the summary has closed
  menuItem.addEventListener("command", () => {
    win.addEventListener("unload", () => {
      editFollowingOccurrences(win.opener, splitSeries, occurrence);
    });
    win.close();
  });
  doc.getElementById("edit-button-context-menu-all-occurrences").before(menuItem);
}

/** Whether "all following" can handle `item`: an event in a series, without attendees. */
function canSplit(item) {
  return item.isEvent() && !item.getAttendees().length && Boolean(item.parentItem.recurrenceInfo);
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
    if (response == MODIFY_FOLLOWING) {
      editFollowingOccurrences(win, splitSeries, aItem, initialDate, aCounterProposal);
    } else if (item && response) {
      originals.modifyEventWithDialog.call(win, item, false, initialDate, aCounterProposal);
    }
    return undefined;
  };
}

/** Open the editor in the patched main window `win` on the series from `occurrence` on. */
function editFollowingOccurrences(win, splitSeries, occurrence, initialDate, counterProposal) {
  const parent = occurrence.parentItem;
  // an editor already open on this occurrence or on the series would save over
  // the split, so bring it forward instead, as modifyEventWithDialog() does;
  // cal.item.findWindow() only sees editors in their own window, not in a tab
  const openEditor = cal.item.findWindow(occurrence) || cal.item.findWindow(parent);
  if (openEditor) {
    openEditor.focus();
    return;
  }

  const split = splitSeries(parent, occurrence.recurrenceId);
  if (!split) {
    win.editFollowingOriginals.modifyEventWithDialog.call(win, parent, false, initialDate, counterProposal);
    return;
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
