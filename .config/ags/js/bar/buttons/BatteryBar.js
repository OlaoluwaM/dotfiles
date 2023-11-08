import icons from "../../icons.js";
import FontIcon from "../../misc/FontIcon.js";
import options from "../../options.js";
import PanelButton from "../PanelButton.js";
import { Battery, Widget } from "../../imports.js";
import { toggleClassesBasedOnBatteryStatus } from "../../utils.js";

const Indicator = () =>
  Widget.Stack({
    items: [
      ["false", Widget.Icon({ binds: [["icon", Battery, "icon-name"]] })],
      ["true", FontIcon(icons.battery.charging)],
    ],
    connections: [
      [
        Battery,
        (stack) => {
          stack.shown = `${Battery.charging || Battery.charged}`;
        },
      ],
    ],
  });

const PercentLabel = () =>
  Widget.Revealer({
    transition: "slide_right",
    reveal_child: options.batteryBar.showPercentage,
    child: Widget.Label({
      binds: [["label", Battery, "percent", (p) => `${p}%`]],
    }),
  });

const LevelBar = () =>
  Widget.LevelBar({
    vpack: "center",
    binds: [["value", Battery, "percent", (p) => p / 100]],
  });

export default () => {
  const revaler = PercentLabel();

  return PanelButton({
    class_name: "battery-bar",
    onClicked: () => (revaler.reveal_child = !revaler.reveal_child),
    content: Widget.Box({
      binds: [["visible", Battery, "available"]],
      connections: [
        [
          Battery,
          (w) => {
            toggleClassesBasedOnBatteryStatus(w, Battery);
          },
        ],
      ],
      children: [Indicator(), revaler, LevelBar()],
    }),
  });
};
