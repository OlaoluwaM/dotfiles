import Clock from "../../misc/Clock.js";
import PanelButton from "../PanelButton.js";
import { App } from "../../imports.js";

export default ({ format = "%A %B%e ~ %H:%M" } = {}) =>
  PanelButton({
    class_name: "dashboard panel-button",
    onClicked: () => App.toggleWindow("dashboard"),
    window: "dashboard",
    content: Clock({ format }),
  });
