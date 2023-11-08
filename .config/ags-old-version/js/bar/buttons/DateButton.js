import Clock from "../../misc/Clock.js";
import PanelButton from "../PanelButton.js";
import { App } from "../../imports.js";

export default ({ format = "%A %B%e ~ %H:%M" } = {}) =>
  PanelButton({
    className: "dashboard panel-button",
    onClicked: () => App.toggleWindow("dashboard"),
    connections: [
      [
        App,
        (btn, win, visible) => {
          btn.toggleClassName("active", win === "dashboard" && visible);
        },
      ],
    ],
    child: Clock({ format }),
  });
