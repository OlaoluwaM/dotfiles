import icons from "../../icons.js";
import { SimpleToggleButton } from "../ToggleButton.js";
import { Audio, Widget } from "../../imports.js";

export default () =>
  SimpleToggleButton({
    icon: Widget.Icon({
      size: 16,
      style: "padding: 0 0.5rem",
      connections: [
        [
          Audio,
          (_icon) => {
            const icon = _icon;
            icon.icon = Audio.microphone?.isMuted
              ? icons.audio.mic.muted
              : icons.audio.mic.high;
          },
          "microphone-changed",
        ],
      ],
    }),
    toggle: () => {
      Audio.microphone.isMuted = !Audio.microphone.isMuted;
    },
    connection: [Audio, () => Audio.microphone?.isMuted],
  });
