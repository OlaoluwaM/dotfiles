import icons from "../../icons.js";
// import PowerMenu from "../../services/powermenu.js";
import Theme from "../../services/theme/theme.js";
// import Lockscreen from "../../services/lockscreen.js";
import Avatar from "../../misc/Avatar.js";
import { uptime } from "../../variables.js";
import { Battery, Widget, Utils } from "../../imports.js";
import PanelButton from "../../bar/PanelButton.js";
import PowerMenu from "../../bar/buttons/PowerMenu.js";

export const BatteryProgress = () =>
  Widget.Box({
    className: "battery-progress",
    vexpand: true,
    binds: [["visible", Battery, "available"]],
    connections: [
      [
        Battery,
        (w) => {
          w.toggleClassName("half", Battery.percent < 46);
          w.toggleClassName("low", Battery.percent < 30);
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
            (_progress) => {
              const progress = _progress;
              progress.fraction = Battery.percent / 100;
              progress.tooltipText =
                Battery.charging || Battery.charged
                  ? icons.battery.charging
                  : `Battery @ ${Battery.percent}%`;
            },
          ],
        ],
      }),
      overlays: [
        // Widget.Label({
        //   connections: [
        //     [
        //       Battery,
        //       (_l) => {
        //         const l = _l;
        //         l.label =
        //           Battery.charging || Battery.charged
        //             ? icons.battery.charging
        //             : `${Battery.percent}%`;
        //       },
        //     ],
        //   ],
        // }),
      ],
    }),
  });

const SwayncNotificationIcon = () =>
  PanelButton({
    valign: "center",
    onClicked: () => Utils.execAsync("swaync-client -t"),
    child: Widget.Icon({ icon: "notification-symbolic" }),
  });

export default () =>
  Widget.Box({
    className: "header",
    children: [
      Avatar(),
      Widget.Box({
        className: "system-box",
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
                className: "uptime",
                hexpand: true,
                valign: "center",
                connections: [
                  [
                    uptime,
                    (_label) => {
                      const label = _label;
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
