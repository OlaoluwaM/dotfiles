import GLib from "gi://GLib";
import { Widget } from "../imports.js";

export default ({
  format = "%H:%M:%S %B %e. %A",
  interval = 1000,
  ...props
} = {}) =>
  Widget.Label({
    className: "clock",
    ...props,
    connections: [
      [
        interval,
        (_label) => {
          const label = _label;
          label.label = GLib.DateTime.new_now_local().format(format);
        },
      ],
    ],
  });
