import OverviewButton from "./buttons/OverviewButton.js";
import Workspaces from "./buttons/Workspaces.js";
import FocusedClient from "./buttons/FocusedClient.js";
import MediaIndicator from "./buttons/MediaIndicator.js";
import DateButton from "./buttons/DateButton.js";
// import NotificationIndicator from "./buttons/NotificationIndicator.js";
import SysTray from "./buttons/SysTray.js";
import SystemIndicators from "./buttons/SystemIndicators.js";
import PowerMenu from "./buttons/PowerMenu.js";
import ScreenRecord from "./buttons/ScreenRecord.js";
import BatteryBar from "./buttons/BatteryBar.js";
import SubMenu from "./buttons/SubMenu.js";
import { SystemTray, Widget, Variable } from "../imports.js";
import { Mpris, Battery } from "../imports.js";
import Recorder from "../services/screenrecord.js";
import SysProgressClickReveal from "./buttons/SysMonitor.js";
import ColorPicker from "./buttons/ColorPicker.js";

const submenuItems = Variable(1);
SystemTray.connect("changed", () => {
  submenuItems.setValue(SystemTray.items.length + 1);
});

const SeparatorDot = (service, condition) =>
  Widget.Separator({
    orientation: 0,
    vpack: "center",
    connections: !service
      ? []
      : [
          [
            service,
            (dot) => {
              dot.visible = condition(service);
            },
          ],
        ],
  });

const Start = () =>
  Widget.Box({
    class_name: "start",
    children: [
      // OverviewButton(),
      SeparatorDot(),
      Workspaces(),
      SeparatorDot(),
      FocusedClient(),
      Widget.Box({ hexpand: true }),
      // NotificationIndicator(),
      //   SeparatorDot(Notifications, (n) => n.notifications.length > 0 || n.dnd),
    ],
  });

const Center = () =>
  Widget.Box({
    class_name: "center",
    children: [DateButton()],
  });

const End = () =>
  Widget.Box({
    class_name: "end",
    children: [
      SeparatorDot(Mpris, (m) => m.players.length > 0),
      MediaIndicator(),
      Widget.Box({ hexpand: true }),

      SubMenu({
        items: submenuItems,
        children: [SysTray(), ColorPicker()],
      }),

      SysProgressClickReveal(
        "cpu",
        "CPU",
        "%",
        "kitty btm --default_widget_type cpu -e"
      ),

      SysProgressClickReveal(
        "ram",
        "RAM",
        "%",
        "kitty btm --default_widget_type proc -e"
      ),

      SeparatorDot(),
      ScreenRecord(),
      SeparatorDot(Recorder, (r) => r.recording),
      BatteryBar(),
      SeparatorDot(Battery, (b) => b.available),
      SystemIndicators(),
      SeparatorDot(),
    ],
  });

export default (monitor) =>
  Widget.Window({
    name: `bar${monitor}`,
    exclusive: true,
    monitor,
    anchor: ["top", "left", "right"],
    child: Widget.CenterBox({
      class_name: "panel",
      start_widget: Start(),
      center_widget: Center(),
      end_widget: End(),
    }),
  });
