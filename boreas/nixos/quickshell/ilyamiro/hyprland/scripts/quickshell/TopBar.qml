import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    delegate: Component {
        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            WlrLayershell.namespace: "qs-topbar"
            WlrLayershell.layer: WlrLayer.Top

            anchors { top: true; left: true; right: true }
            implicitHeight: 48
            exclusiveZone: 56
            margins { top: 8; left: 8; right: 8; bottom: 0 }
            color: "transparent"

            MatugenColors { id: theme }

            property string timeText: Qt.formatDateTime(new Date(), "HH:mm")
            property string dateText: Qt.formatDateTime(new Date(), "ddd, MMM d")

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    bar.timeText = Qt.formatDateTime(new Date(), "HH:mm")
                    bar.dateText = Qt.formatDateTime(new Date(), "ddd, MMM d")
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.78)
                border.color: Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.08)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                RowLayout {
                    spacing: 6
                    TopBarButton { label: "󰍉"; accent: theme.blue; command: "toggle applauncher" }
                    TopBarButton { label: "󰅇"; accent: theme.mauve; command: "toggle clipboard" }
                    TopBarButton { label: ""; accent: theme.green; command: "toggle wallpaper" }
                    TopBarButton { label: "󰕾"; accent: theme.peach; command: "toggle volume" }
                }

                Item { Layout.fillWidth: true }

                ColumnLayout {
                    spacing: -2
                    Layout.alignment: Qt.AlignCenter
                    Text {
                        text: bar.timeText
                        Layout.alignment: Qt.AlignHCenter
                        font.family: "JetBrains Mono"
                        font.pixelSize: 16
                        font.bold: true
                        color: theme.blue
                    }
                    Text {
                        text: bar.dateText
                        Layout.alignment: Qt.AlignHCenter
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                        color: theme.subtext0
                    }
                }

                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: 6
                    TopBarButton { label: "󰤨"; accent: theme.teal; command: "toggle network" }
                    TopBarButton { label: "󰁹"; accent: theme.yellow; command: "toggle battery" }
                    TopBarButton { label: "󰊠"; accent: theme.pink; command: "toggle music" }
                    TopBarButton { label: "󰊕"; accent: theme.lavender; command: "toggle focustime" }
                }
            }
        }
    }
}
