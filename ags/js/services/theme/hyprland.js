import { App, Utils } from "../../imports.js";

const noAlphaignore = ["verification", "powermenu", "lockscreen"];

export default function ({
  wmGaps,
  borderWidth,
  hyprActiveBorder,
  hyprInactiveBorder,
  radii,
  dropShadow,
  barStyle,
  layout,
}) {
  try {
    App.connect("config-parsed", () => {
      // for (const [name] of App.windows) {
      //   Utils.execAsync([
      //     "hyprctl",
      //     "keyword",
      //     "layerrule",
      //     `unset, ${name}`,
      //   ]).then(() => {
      //     Utils.execAsync(["hyprctl", "keyword", "layerrule", `blur, ${name}`]);
      //     if (!noAlphaignore.every((skip) => !name.includes(skip))) return;
      //     Utils.execAsync([
      //       "hyprctl",
      //       "keyword",
      //       "layerrule",
      //       `ignorealpha 0.6, ${name}`,
      //     ]);
      //   });
      // }
    });

    // JSON.parse(Utils.exec("hyprctl -j monitors")).forEach(({ name }) => {
    //   if (barStyle !== "normal") {
    //     switch (layout) {
    //       case "topbar":
    //       case "unity":
    //         Utils.execAsync(
    //           `hyprctl keyword monitor ${name},addreserved,-${wmGaps},0,0,0`,
    //         );
    //         break;

    //       case "bottombar":
    //         Utils.execAsync(
    //           `hyprctl keyword monitor ${name},addreserved,0,-${wmGaps},0,0`,
    //         );
    //         break;

    //       default:
    //         break;
    //     }
    //   } else {
    //     Utils.execAsync(`hyprctl keyword monitor ${name},addreserved,0,0,0,0`);
    //   }
    // });

    Utils.execAsync(`hyprctl keyword general:gaps_out ${wmGaps}`);
    Utils.execAsync(`hyprctl keyword general:gaps_in ${wmGaps / 2}`);
  } catch (error) {
    console.error(error);
  }
}
