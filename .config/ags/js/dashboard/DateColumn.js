import icons from "../icons.js";
import Clock from "../misc/Clock.js";
import * as vars from "../variables.js";
import { Widget } from "../imports.js";

export default () =>
  Widget.Box({
    vertical: true,
    className: "datemenu",
    children: [
      Clock({ format: "%H:%M" }),
      Widget.Label({
        binds: [
          [
            "label",
            vars.uptime,
            "value",
            (t) => {
              return `Uptime: ${t}`;
            },
          ],
        ],
      }),
      Widget.Box({
        className: "calendar",
        children: [
          Widget({
            type: imports.gi.Gtk.Calendar,
            hexpand: true,
            halign: "center",
          }),
        ],
      }),
    ],
  });
