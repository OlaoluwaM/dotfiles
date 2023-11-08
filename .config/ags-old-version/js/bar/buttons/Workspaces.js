import { Hyprland, Widget, Utils } from "../../imports.js";
import options from "../../options.js";
import { range } from "../../utils.js";

const wsNumPref = options.workspaces;

const dispatch = (ws) => Utils.execAsync(`hyprctl dispatch workspace ${ws}`);

const Workspaces = () =>
  Widget.Box({
    children: range(wsNumPref).map((i) =>
      Widget.Button({
        setup: (_btn) => {
          const btn = _btn;
          btn.id = i;
        },
        onClicked: () => dispatch(i),
        child: Widget.Label({
          label: `${i}`,
          className: "indicator",
          valign: "center",
        }),
        tooltipText: `Switch to workspace ${i}`,
        connections: [
          [
            Hyprland,
            (btn) => {
              btn.toggleClassName("active", Hyprland.active.workspace.id === i);
              btn.toggleClassName(
                "occupied",
                Hyprland.getWorkspace(i)?.windows > 0,
              );
            },
          ],
        ],
      }),
    ),
    // remove this connection if you want fixed number of buttons
    connections: [
      [
        Hyprland,
        (box) =>
          box.children.forEach((_btn) => {
            const btn = _btn;
            btn.visible = Hyprland.workspaces.some((ws) => ws.id === btn.id);
          }),
      ],
    ],
  });

export default () =>
  Widget.Box({
    className: "workspaces panel-button",
    child: Widget.Box({
      // its nested like this to keep it consistent with other PanelButton widgets
      child: Widget.EventBox({
        onScrollUp: () => dispatch("+1"),
        onScrollDown: () => dispatch("-1"),
        className: "eventbox",
        child: Workspaces(),
      }),
    }),
  });
