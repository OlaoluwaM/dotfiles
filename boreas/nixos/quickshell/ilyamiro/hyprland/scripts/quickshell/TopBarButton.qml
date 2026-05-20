import QtQuick
import Quickshell

Rectangle {
    id: button
    required property string label
    required property color accent
    required property string command

    width: 34
    height: 34
    radius: 10
    color: mouse.containsMouse ? Qt.rgba(accent.r, accent.g, accent.b, 0.18) : "transparent"

    Text {
        anchors.centerIn: parent
        text: button.label
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 20
        color: mouse.containsMouse ? button.accent : "white"
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["bash", "-c", "~/.config/hypr/scripts/qs_manager.sh " + button.command])
    }
}
