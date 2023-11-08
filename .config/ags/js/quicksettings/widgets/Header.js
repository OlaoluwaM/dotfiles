import icons from "../../icons.js";
import PowerMenu from "../../bar/buttons/PowerMenu.js";
import Avatar from "../../misc/Avatar.js";
import { uptime } from "../../variables.js";
import { Battery, Utils, Widget } from "../../imports.js";
import PanelButton from "../../bar/PanelButton.js";
import { toggleClassesBasedOnBatteryStatus } from "../../utils.js";

export const BatteryProgress = () =>
  Widget.Box({
    class_name: "battery-progress",
    vexpand: true,
    binds: [["visible", Battery, "available"]],
    connections: [
      [
        Battery,
        (w) => {
          toggleClassesBasedOnBatteryStatus(w, Battery);
        },
      ],
    ],
    child: Widget.Overlay({
      vexpand: true,
      child: Widget.ProgressBar({
        hexpand: true,
        vexpand: true,
        connections: [
          [
            Battery,
            (progress) => {
              progress.fraction = Battery.percent / 100;
              progress.tooltipText =
                Battery.charging || Battery.charged
                  ? icons.battery.charging
                  : `Battery @ ${Battery.percent}%`;
            },
          ],
        ],
      }),
      //   overlays: [
      //     Widget.Label({
      //       connections: [
      //         [
      //           Battery,
      //           (l) => {
      //             l.label =
      //               Battery.charging || Battery.charged
      //                 ? icons.battery.charging
      //                 : `${Battery.percent}%`;
      //           },
      //         ],
      //       ],
      //     }),
      //   ],
    }),
  });

const SwayncNotificationIcon = () =>
  PanelButton({
    valign: "center",
    onClicked: () => Utils.execAsync("swaync-client -t"),
    content: Widget.Icon({ icon: "notification-symbolic" }),
  });

export default () =>
  Widget.Box({
    class_name: "header",
    children: [
      Avatar(),
      Widget.Box({
        class_name: "system-box",
        vertical: true,
        hexpand: true,
        children: [
          Widget.Box({
            children: [
              // Widget.Button({
              //   valign: "center",
              //   onClicked: () => Theme.openSettings(),
              //   child: Widget.Icon(icons.settings),
              // }),
              Widget.Label({
                class_name: "uptime",
                hexpand: true,
                vpack: "center",
                connections: [
                  [
                    uptime,
                    (label) => {
                      label.label = uptime.value;
                    },
                  ],
                ],
                tooltipText: "Uptime",
              }),
              SwayncNotificationIcon(),
              PowerMenu(),
            ],
          }),
          BatteryProgress(),
        ],
      }),
    ],
  });
