import OverviewButton from "./buttons/OverviewButton.js";
import Workspaces from "./buttons/Workspaces.js";
import FocusedClient from "./buttons/FocusedClient.js";
import MediaIndicator from "./buttons/MediaIndicator.js";
import DateButton from "./buttons/DateButton.js";
// import NotificationIndicator from './buttons/NotificationIndicator.js';
import SysTray from "./buttons/SysTray.js";
// import ColorPicker from './buttons/ColorPicker.js';
import SystemIndicators from "./buttons/SystemIndicators.js";
import Separator from "../misc/Separator.js";
import ScreenRecord from "./buttons/ScreenRecord.js";
import BatteryBar from "./buttons/BatteryBar.js";
import SubMenu from "./buttons/SubMenu.js";
import {
  SystemTray,
  Widget,
  Variable,
  Utils,
  /* Notifications */ Mpris,
  Battery,
} from "../imports.js";
import Recorder from "../services/screenrecord.js";
import * as vars from "../variables.js";
// import icons from '../icons.js';
import PanelButton from "./PanelButton.js";
// import HoverRevealer from '../misc/HoverRevealer.js';
// import FontIcon from '../misc/FontIcon.js';
import { toPercent } from "../utils.js";

const submenuItems = Variable(1);
SystemTray.connect("changed", () => {
  submenuItems.setValue(SystemTray.items.length + 1);
});

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
    onSecondaryClick: () => Utils.execAsync(clickCmd).catch(print),

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
          inverted: true,
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

// const SysProgressHoverReveal = (type, title, unit, direction = 'left') =>
//     HoverRevealer({
//         className: `panel-button system-resources-box ${type}`,
//         direction,
//         duration: 200,

//         onPrimaryClick: () =>
//             Utils.execAsync('kitty btm --default_widget_type proc -e').catch(print),

//         indicator: Widget.CircularProgress({
//             inverted: true,
//             binds: [['value', vars[type]]],
//             className: `circular-progress-bar ${type}`,
//             startAt: 0.75,
//             rounded: true,
//         }),

//         child: Widget.Box({
//             children: [
//                 Widget.Label({
//                     className: `system-resources-label ${type}`,
//                     binds: [
//                         [
//                             'label',
//                             vars[type],
//                             'value',
//                             value => `${Math.floor(value * 100)}${unit}`,
//                         ],
//                     ],
//                 }),
//             ],
//         }),

//         tooltipText: title,

//         eventboxConnections: [
//             [
//                 vars[type],
//                 hr => {
//                     const sysVal = vars[type].value;
//                     const isLow = toPercent(sysVal) <= 25;
//                     const isMedium = toPercent(sysVal) <= 50 && toPercent(sysVal) > 25;
//                     const isHigh = toPercent(sysVal) > 50;

//                     hr.toggleClassName('low', isLow);
//                     hr.toggleClassName('medium', isMedium);
//                     hr.toggleClassName('high', isHigh);
//                 },
//             ],
//         ],
//     });

const SeparatorDot = (service, condition) =>
  Separator({
    orientation: "vertical",
    valign: "center",
    connections: service && [
      [
        service,
        (_dot) => {
          const dot = _dot;
          dot.visible = condition(service);
        },
      ],
    ],
  });

const Start = () =>
  Widget.Box({
    className: "start",
    children: [
      // OverviewButton(),
      SeparatorDot(),
      Workspaces(),
      SeparatorDot(),
      FocusedClient(),
      Widget.Box({ hexpand: true }),
      // NotificationIndicator(),
      // SeparatorDot(Notifications, n => n.notifications.length > 0 || n.dnd),
    ],
  });

const Center = () =>
  Widget.Box({
    className: "center",
    children: [DateButton()],
  });

const End = () =>
  Widget.Box({
    className: "end",
    children: [
      SeparatorDot(Mpris, (m) => m.players.length > 0),
      MediaIndicator(),
      Widget.Box({ hexpand: true }),

      SubMenu({
        items: submenuItems,
        children: [
          SysTray(),
          // ColorPicker(),
        ],
      }),
      SeparatorDot(),
      // PanelButton({
      //   className: "sys-resources ",
      // }),
      Widget.CenterBox({
        className: "sys-resources-container",
        children: [
          SysProgressClickReveal(
            "cpu",
            "CPU",
            "%",
            "kitty btm --default_widget_type cpu -e",
          ),
          SysProgressClickReveal(
            "ram",
            "RAM",
            "%",
            "kitty btm --default_widget_type proc -e",
          ),
        ],
      }),
      SeparatorDot(),
      // SwayncNotificationIcon(),
      ScreenRecord(),
      SeparatorDot(Recorder, (r) => r.recording),
      BatteryBar(),
      SeparatorDot(Battery, (b) => b.available),
      SystemIndicators(),
      SeparatorDot(),
      // PowerMenu(),
    ],
  });

export default (monitor) =>
  Widget.Window({
    name: `bar${monitor}`,
    exclusive: true,
    monitor,
    anchor: ["top", "left", "right"],
    child: Widget.CenterBox({
      className: "panel",
      startWidget: Start(),
      centerWidget: Center(),
      endWidget: End(),
    }),
  });
