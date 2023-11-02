import Gtk from "gi://Gtk";
import icons from "../../icons.js";
import Spinner from "../../misc/Spinner.js";
import { Menu, ArrowToggleButton } from "../ToggleButton.js";
import { Bluetooth, Widget } from "../../imports.js";

export const BluetoothToggle = () =>
  ArrowToggleButton({
    name: "bluetooth",
    icon: Widget.Icon({
      connections: [
        [
          Bluetooth,
          (_icon) => {
            const icon = _icon;
            icon.icon = Bluetooth.enabled
              ? icons.bluetooth.enabled
              : icons.bluetooth.disabled;
          },
        ],
      ],
    }),
    label: Widget.Label({
      truncate: "end",
      connections: [
        [
          Bluetooth,
          (_label) => {
            const label = _label;
            if (!Bluetooth.enabled) {
              label.label = "Disabled";
              return;
            }

            if (Bluetooth.connectedDevices.length === 0) {
              label.label = "Not Connected";
              return;
            }

            if (Bluetooth.connectedDevices.length === 1) {
              label.label = Bluetooth.connectedDevices[0].alias;
              return;
            }

            label.label = `${Bluetooth.connectedDevices.length} Connected`;
          },
        ],
      ],
    }),
    connection: [Bluetooth, () => Bluetooth.enabled],
    deactivate: () => {
      Bluetooth.enabled = false;
    },

    activate: () => {
      Bluetooth.enabled = true;
    },
  });

export const BluetoothDevices = () =>
  Menu({
    name: "bluetooth",
    icon: Widget.Icon(icons.bluetooth.disabled),
    title: Widget.Label("Bluetooth"),
    content: Widget.Box({
      hexpand: true,
      vertical: true,
      connections: [
        [
          Bluetooth,
          (_box) => {
            const box = _box;
            box.children = Bluetooth.devices
              .filter((d) => d.name)
              .map((device) =>
                Widget.Box({
                  className: "device-item",
                  children: [
                    Widget.Icon(`${device.iconName}-symbolic`),
                    Widget.Label(device.name),
                    device.batteryPercentage > 0 &&
                      Widget.Label(`${device.batteryPercentage}%`),
                    Widget.Box({ hexpand: true }),
                    device.connecting
                      ? Spinner()
                      : Widget({
                          className: "toggle-switch",
                          type: Gtk.Switch,
                          active: device.connected,
                          connections: [
                            [
                              "notify::active",
                              ({ active }) => {
                                device.setConnection(active);
                              },
                            ],
                          ],
                        }),
                  ],
                }),
              );
          },
        ],
      ],
    }),
  });
