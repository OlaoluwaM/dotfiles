pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: config

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string hyprDir: homeDir + "/.config/hypr"
    readonly property string qsScriptsDir: hyprDir + "/scripts/quickshell"
    readonly property string settingsJsonPath: hyprDir + "/settings.json"

    property bool dataReady: true
    property var rawSettings: ({})
    property real uiScale: 1.0
    property bool openGuideAtStartup: false
    property bool topbarHelpIcon: false
    property int workspaceCount: 8
    property int initialWorkspaceCount: 8
    property string wallpaperDir: Quickshell.env("WALLPAPER_DIR") || (homeDir + "/Pictures/Wallpapers")
    property string language: ""
    property string kbOptions: "grp:alt_shift_toggle"
    property var keybindsData: []
    property var startupData: []

    signal keybindsLoaded()
    signal startupLoaded()

    function sh(cmd) {
        Quickshell.execDetached(["bash", "-c", cmd]);
    }

    function getSetting(key, fallbackValue) {
        return rawSettings.hasOwnProperty(key) ? rawSettings[key] : fallbackValue;
    }

    function setSetting(key, value) {
        rawSettings[key] = value;
        let safeValue = typeof value === "string" ? `"${value}"` : JSON.stringify(value);
        let cmd = `mkdir -p "$(dirname '${settingsJsonPath}')" && ` +
                  `[ ! -f '${settingsJsonPath}' ] && echo '{}' > '${settingsJsonPath}'; ` +
                  `jq '. + {"${key}": ${safeValue}}' '${settingsJsonPath}' > '${settingsJsonPath}.tmp' && ` +
                  `mv '${settingsJsonPath}.tmp' '${settingsJsonPath}'`;
        sh(cmd);
    }

    function updateJsonBulk(dataObj) {
        for (let key in dataObj) rawSettings[key] = dataObj[key];
        let jsonStr = JSON.stringify(dataObj).replace(/'/g, "'\\''");
        let cmd = `mkdir -p "$(dirname '${settingsJsonPath}')" && ` +
                  `[ ! -f '${settingsJsonPath}' ] && echo '{}' > '${settingsJsonPath}'; ` +
                  `jq '. + ${jsonStr}' '${settingsJsonPath}' > '${settingsJsonPath}.tmp' && ` +
                  `mv '${settingsJsonPath}.tmp' '${settingsJsonPath}'`;
        sh(cmd);
    }

    function saveAppSettings() {
        updateJsonBulk({
            "uiScale": uiScale,
            "openGuideAtStartup": openGuideAtStartup,
            "topbarHelpIcon": topbarHelpIcon,
            "wallpaperDir": wallpaperDir,
            "language": language,
            "kbOptions": kbOptions,
            "workspaceCount": workspaceCount
        });
    }

    function saveAllKeybinds(bindsArray) {
        keybindsData = bindsArray;
        setSetting("keybinds", bindsArray);
    }

    function saveAllStartup(startupArray) {
        startupData = startupArray;
        setSetting("startup", startupArray);
    }

    property alias monitorsModel: _monitorsModel
    ListModel { id: _monitorsModel }
    property int monActiveEditIndex: 0
    property real monUiScale: 0.10
    property int monOriginalOriginX: 0
    property int monOriginalOriginY: 0

    function monIsOverlapping() { return false; }
    function monIsOverlappingAny() { return false; }
    function monGetPerimeterSnap(pX, pY) { return { x: pX, y: pY }; }
    function monForceLayoutUpdate() {}
    function applyMonitors() {}

    Timer { id: _monDelayedLayoutUpdate; interval: 10 }
    property alias monDelayedLayoutUpdate: _monDelayedLayoutUpdate

    Process {
        id: _displayPoller
        command: ["hyprctl", "monitors", "-j"]
        running: false
    }
    property alias displayPoller: _displayPoller

    Component.onCompleted: {
        keybindsLoaded();
        startupLoaded();
    }
}
