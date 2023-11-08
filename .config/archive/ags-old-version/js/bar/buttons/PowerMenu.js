import icons from "../../icons.js";
import PanelButton from "../PanelButton.js";
import { Widget, Utils } from "../../imports.js";

export default () =>
  PanelButton({
    className: "powermenu",
    content: Widget.Icon({ icon: icons.powermenu.shutdown, size: 22 }),
    onClicked: () => Utils.execAsync("wlogout"),
  });
