import { toPercent } from "../../utils.js";
import { Widget, Utils } from "../../imports.js";
import * as vars from "../../variables.js";
import PanelButton from "../PanelButton.js";

const SysProgressClickReveal = (type, title, unit, clickCmd) => {
  const revealer = Widget.Revealer({
    revealChild: false,
    transition: "slide_right",
    child: Widget.Label({
      className: `system-resources-label ${type}`,
      binds: [
        [
          "label",
          vars[type],
          "value",
          (value) => `${Math.floor(value * 100)}${unit}`,
        ],
      ],
    }),
  });

  return PanelButton({
    tooltipText: title,
    onClicked: () => {
      revealer.revealChild = !revealer.revealChild;
    },
    onSecondaryClick: () => Utils.execAsync(clickCmd).catch(console.error),

    content: Widget.Box({
      className: `system-resources-box ${type}`,
      connections: [
        [
          vars[type],
          (hr) => {
            const sysVal = vars[type].value;
            const isLow = toPercent(sysVal) <= 25;
            const isMedium = toPercent(sysVal) <= 50 && toPercent(sysVal) > 25;
            const isHigh = toPercent(sysVal) > 50;

            hr.toggleClassName("low", isLow);
            hr.toggleClassName("medium", isMedium);
            hr.toggleClassName("high", isHigh);
          },
        ],
      ],
      children: [
        revealer,
        Widget.CircularProgress({
          value: 0,
          binds: [["value", vars[type]]],
          className: `circular-progress-bar ${type}`,
          startAt: 0.75,
          rounded: true,
        }),
      ],
    }),
  });
};

export default SysProgressClickReveal;
