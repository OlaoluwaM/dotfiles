import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import "../"

Item {
    id: root
    anchors.fill: parent

    Caching { id: paths }
    MatugenColors { id: theme }

    readonly property string wallpaperDir: Quickshell.env("WALLPAPER_DIR") || (Quickshell.env("HOME") + "/Pictures/Wallpapers")

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.92)
    }

    FolderListModel {
        id: wallpapers
        folder: "file://" + root.wallpaperDir
        showDirs: false
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        sortField: FolderListModel.Time
        sortReversed: true
    }

    Text {
        visible: wallpapers.count === 0
        anchors.centerIn: parent
        text: "No wallpapers found in " + root.wallpaperDir
        font.family: "JetBrains Mono"
        font.pixelSize: 16
        color: theme.text
    }

    ListView {
        anchors.fill: parent
        anchors.margins: 28
        orientation: ListView.Horizontal
        spacing: 18
        model: wallpapers
        clip: true

        delegate: Rectangle {
            width: 260
            height: ListView.view.height
            radius: 12
            color: Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.8)
            border.color: mouse.containsMouse ? theme.mauve : Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.08)
            border.width: mouse.containsMouse ? 2 : 1

            Image {
                anchors.fill: parent
                anchors.margins: 8
                source: fileUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const path = String(fileUrl).replace("file://", "");
                    Quickshell.execDetached(["bash", "-c", `swww img '${path.replace(/'/g, "'\\''")}' --transition-type grow --transition-duration 0.8 && matugen image '${path.replace(/'/g, "'\\''")}' || true`]);
                }
            }
        }
    }
}
