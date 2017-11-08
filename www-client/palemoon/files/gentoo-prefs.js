// Start searching without explicitly triggering search
pref("accessibility.typeaheadfind", true);
// Allow installing extensions from all locations - if this is removed
// e.g. system langpacks would not be installed
pref("extensions.autoDisableScopes", 0);
// Don't auto-select on single click in URL bar
pref("browser.urlbar.clickSelectsAll", false);
// but auto-select on double click
pref("browser.urlbar.doubleClickSelectsAll", true);
