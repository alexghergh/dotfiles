// Thunderbird applies these at every start, over prefs.js; change them here,
// since changes made in the settings UI revert at the next start

// load chrome/userChrome.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// look
user_pref("extensions.activeThemeID", "thunderbird-compact-light@mozilla.org");
user_pref("mail.uidensity", 2);
user_pref("mail.uifontsize", 16);
user_pref("mail.threadpane.cardsview.rowcount", 2);
user_pref("mail.showCondensedAddresses", false);
user_pref("font.language.group", "x-unicode");
user_pref("font.name.sans-serif.x-unicode", "Adwaita Sans");
user_pref("font.name.sans-serif.x-western", "Adwaita Sans");
user_pref("font.name.serif.x-unicode", "Charter");
user_pref("font.name.serif.x-western", "Charter");
user_pref("font.name.monospace.x-unicode", "JetBrains Mono");
user_pref("font.name.monospace.x-western", "JetBrains Mono");
user_pref("font.size.variable.x-unicode", 15);
user_pref("font.size.variable.x-western", 15);
user_pref("font.size.variable.ja", 15);
user_pref("font.size.monospace.x-unicode", 13);
user_pref("font.size.monospace.x-western", 13);
user_pref("font.size.monospace.ja", 13);
user_pref("font.minimum-size.x-unicode", 15);
user_pref("font.minimum-size.x-western", 15);
user_pref("font.minimum-size.ja", 15);

// reading and composing
user_pref("mailnews.default_sort_order", 1);
user_pref("mailnews.scroll_to_new_message", false);
user_pref("mail.inline_attachments", false);
user_pref("mail.fixed_width_messages", false);
user_pref("mail.compose.big_attachments.notify", false);
user_pref("mail.mdn.report.enabled", false);
user_pref("mail.spam.manualMark", true);
user_pref("mail.external_protocol_requires_permission", true);

// notifications and startup
user_pref("mail.biff.play_sound", false);
user_pref("mail.biff.alert.enabled_actions", "mark-as-read");
user_pref("mail.chat.enabled", false);
user_pref("messenger.startup.action", 0);
user_pref("mailnews.start_page.enabled", false);
user_pref("offline.startup_state", 4);

// calendar
user_pref("calendar.timezone.useSystemTimezone", true);
user_pref("calendar.notifications.times", "-PT10M");
user_pref("calendar.alarms.playsound", false);
user_pref("calendar.view.visiblehours", 24);
user_pref("calendar.view.showLocation", true);

// privacy
user_pref("mailnews.headers.sendUserAgent", false);
user_pref("messenger.status.reportIdle", false);
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("network.trr.mode", 2);
user_pref("network.trr.uri", "https://dns.quad9.net/dns-query");

// use the desktop's file picker
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
