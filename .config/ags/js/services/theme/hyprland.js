import { Utils } from "../../imports.js";

// const noAlphaignore = ["verification", "powermenu", "lockscreen"];

export default function ({
  wm_gaps,
  border_width,
  hypr_active_border,
  hypr_inactive_border,
  radii,
  drop_shadow,
  bar_style,
  layout,
}) {
  try {
    JSON.parse(Utils.exec("hyprctl -j monitors")).forEach(({ name }) => {
      if (bar_style !== "normal") {
        switch (layout) {
          case "topbar":
          case "unity":
            Utils.execAsync(
              `hyprctl keyword monitor ${name},addreserved,-${wm_gaps},0,0,0`
            );
            break;

          case "bottombar":
            Utils.execAsync(
              `hyprctl keyword monitor ${name},addreserved,0,-${wm_gaps},0,0`
            );
            break;

          default:
            break;
        }
      } else {
        Utils.execAsync(`hyprctl keyword monitor ${name},addreserved,0,0,0,0`);
      }
    });

    Utils.execAsync(`hyprctl keyword general:gaps_out ${wm_gaps}`);
    Utils.execAsync(`hyprctl keyword general:gaps_in ${wm_gaps / 2}`);
  } catch (error) {
    console.error(error);
  }
}
