// import HoverRevealer from "../../misc/HoverRevealer.js";
import PanelButton from "../PanelButton.js";
import Asusctl from "../../services/asusctl.js";
import Indicator from "../../services/onScreenIndicator.js";
import icons from "../../icons.js";
import {
  App,
  Widget,
  Bluetooth,
  Audio,
  /* Notifications */ Network,
} from "../../imports.js";

const ProfileIndicator = () =>
  Widget.Icon({
    connections: [
      [
        Asusctl,
        (_icon) => {
          const icon = _icon;
          icon.visible = Asusctl.profile !== "Balanced";
          icon.icon = icons.asusctl.profile[Asusctl.profile];
        },
      ],
    ],
  });

const ModeIndicator = () =>
  Widget.Icon({
    connections: [
      [
        Asusctl,
        (_icon) => {
          const icon = _icon;
          icon.visible = Asusctl.mode !== "Hybrid";
          icon.icon = icons.asusctl.mode[Asusctl.mode];
        },
      ],
    ],
  });

const MicrophoneIndicator = () =>
  Widget.Icon({
    connections: [
      [
        Audio,
        (_icon) => {
          if (!Audio.microphone) return;
          const icon = _icon;

          const { muted, low, medium, high } = icons.audio.mic;
          if (Audio.microphone.isMuted) {
            icon.icon = muted;
            return;
          }

          // eslint-disable-next-line prefer-destructuring
          icon.icon = [
            [67, high],
            [34, medium],
            [1, low],
            [0, muted],
          ].find(
            ([threshold]) => threshold <= Audio.microphone.volume * 100,
          )[1];

          icon.visible =
            (Audio?.recorders && Audio.recorders.length > 0) ||
            Audio.microphone.isMuted;
        },
      ],
    ],
  });

// const DNDIndicator = () => Widget.Icon({
//     icon: icons.notifications.silent,
//     binds: [['visible', Notifications, 'dnd']],
// });

// const BluetoothDevicesIndicator = () =>
//   Widget.Box({
//     connections: [
//       [
//         Bluetooth,
//         (_box) => {
//           const box = _box;
//           box.children = Bluetooth.connectedDevices.map(({ iconName, name }) =>
//             HoverRevealer({
//               indicator: Widget.Icon(`${iconName}-symbolic`),
//               child: Widget.Label(name),
//             }),
//           );

//           box.visible = Bluetooth.connectedDevices.length > 0;
//         },
//         "notify::connected-devices",
//       ],
//     ],
//   });

const BluetoothIndicator = () =>
  Widget.Icon({
    className: "bluetooth",
    icon: icons.bluetooth.enabled,
    binds: [["visible", Bluetooth, "enabled"]],
  });

const NetworkIndicator = () =>
  Widget.Stack({
    items: [
      [
        "wifi",
        Widget.Icon({
          connections: [
            [
              Network,
              (_icon) => {
                const icon = _icon;
                icon.icon = Network.wifi?.iconName;
              },
            ],
          ],
        }),
      ],
      [
        "wired",
        Widget.Icon({
          connections: [
            [
              Network,
              (_icon) => {
                const icon = _icon;
                icon.icon = Network.wired?.iconName;
              },
            ],
          ],
        }),
      ],
    ],
    binds: [["shown", Network, "primary"]],
  });

const AudioIndicator = () =>
  Widget.Icon({
    connections: [
      [
        Audio,
        (_icon) => {
          if (!Audio.speaker) return;
          const icon = _icon;

          const { muted, low, medium, high, overamplified } =
            icons.audio.volume;
          if (Audio.speaker.isMuted) {
            icon.icon = muted;
            return;
          }

          // eslint-disable-next-line prefer-destructuring
          icon.icon = [
            [101, overamplified],
            [67, high],
            [34, medium],
            [1, low],
            [0, muted],
          ].find(([threshold]) => threshold <= Audio.speaker.volume * 100)[1];
        },
        "speaker-changed",
      ],
    ],
  });

export default () =>
  PanelButton({
    className: "quicksettings panel-button",
    onClicked: () => App.toggleWindow("quicksettings"),
    onScrollUp: () => {
      Audio.speaker.volume += 0.02;
      Indicator.speaker();
    },
    onScrollDown: () => {
      Audio.speaker.volume -= 0.02;
      Indicator.speaker();
    },
    connections: [
      [
        App,
        (btn, win, visible) => {
          btn.toggleClassName("active", win === "quicksettings" && visible);
        },
      ],
    ],
    child: Widget.Box({
      children: [
        // Asusctl?.available && ProfileIndicator(),
        // Asusctl?.available && ModeIndicator(),
        // DNDIndicator(),
        // BluetoothDevicesIndicator(),
        BluetoothIndicator(),
        NetworkIndicator(),
        AudioIndicator(),
        MicrophoneIndicator(),
      ],
    }),
  });
