import icons from "../../icons.js";
import PanelButton from "../PanelButton.js";
import { Widget, Utils } from "../../imports.js";

export default () =>
  PanelButton({
    class_name: "powermenu",
    content: Widget.Icon({ icon: icons.powermenu.shutdown, size: 22 }),
    onClicked: () => Utils.execAsync("wlogout"),
  });
