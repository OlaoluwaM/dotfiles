// import { showAbout } from "../about/about.js";
// import { hyprlandInit, setupHyprland } from "./hyprland.js";
// import Notifications from "resource:///com/github/Aylur/ags/service/notifications.js";

import App from "resource:///com/github/Aylur/ags/app.js";
import * as Utils from "resource:///com/github/Aylur/ags/utils.js";
import Battery from "resource:///com/github/Aylur/ags/service/battery.js";
import options from "../options.js";
import icons from "../icons.js";
import { reloadScss, scssWatcher } from "./scss.js";
import { initWallpaper } from "./wallpaper.js";
import { globals } from "./globals.js";
import Gtk from "gi://Gtk";

export function init() {
  App.connect("config-parsed", () => {
    // tmux();
    // gsettigsColorScheme();
    // gtkFontSettings();
    // notificationBlacklist();
    // hyprlandInit();
    // setupHyprland();
    // wallpaper();
    // showAbout();

    initWallpaper();
    warnOnLowBattery();
    globals();
    scssWatcher();
    dependandOptions();
    reloadScss();
  });
}

function dependandOptions() {
  options.bar.style.connect("changed", ({ value }) => {
    if (value !== "normal")
      options.desktop.screen_corners.setValue(false, true);
  });
}

function tmux() {
  if (!Utils.exec("which tmux")) return;

  /** @param {string} scss */
  function getColor(scss) {
    if (scss.includes("#")) return scss;

    if (scss.includes("$")) {
      const opt = options
        .list()
        .find((opt) => opt.scss === scss.replace("$", ""));
      return opt?.value;
    }
  }

  options.theme.accent.accent.connect("changed", ({ value }) =>
    Utils.execAsync(`tmux set @main_accent ${getColor(value)}`).catch((err) =>
      console.error(err.message)
    )
  );
}

function gsettigsColorScheme() {
  if (!Utils.exec("which gsettings")) return;

  options.theme.scheme.connect("changed", ({ value }) => {
    const gsettings = "gsettings set org.gnome.desktop.interface color-scheme";
    Utils.execAsync(`${gsettings} "prefer-${value}"`).catch((err) =>
      console.error(err.message)
    );
  });
}

function gtkFontSettings() {
  const settings = Gtk.Settings.get_default();
  if (!settings) {
    console.error(Error("Gtk.Settings unavailable"));
    return;
  }

  const callback = () => {
    const { size, font } = options.font;
    settings.gtk_font_name = `${font.value} ${size.value}`;
  };

  options.font.font.connect("notify::value", callback);
  options.font.size.connect("notify::value", callback);
}

function notificationBlacklist() {
  Notifications.connect("notified", (_, id) => {
    const n = Notifications.getNotification(id);
    options.notifications.black_list.value.forEach((item) => {
      if (n?.app_name.includes(item) || n?.app_entry?.includes(item)) n.close();
    });
  });
}

function mkBatterNotificationSender(batteryPercentage) {
  return (notifTitle = "Low Battery") =>
    Utils.execAsync([
      "notify-send",
      "--urgency",
      "critical",
      "--icon",
      icons.battery.warning,
      notifTitle,
      `Battery is at ${batteryPercentage}%. You might want to start charging`,
    ]).catch(console.error);
}

export function warnOnLowBattery() {
  const warningFired = {
    atLow: false,
    atHalfLow: false,
    atCritical: false,
  };

  Battery.connect("changed", (battery) => {
    const { low, critical } = options.battery;
    const { _percent: batteryPercentage, _charging: charging } = battery;

    const warnAtLow =
      !charging && batteryPercentage <= low.value && !warningFired.atLow;
    const warnAtHalfLow =
      !charging && batteryPercentage <= low.value / 2 && !warningFired.atHalfLow;
    const warnAtCritical =
      !charging && batteryPercentage <= critical.value && !warningFired.atCritical;

    const allWarningTriggersReset = [
      warningFired.atLow,
      warningFired.atHalfLow,
      warningFired.atCritical,
    ].every((trigger) => trigger === false);

    const sendBatteryNotification =
      mkBatterNotificationSender(batteryPercentage);

    if (warnAtLow) {
      warningFired.atLow = true;
      sendBatteryNotification();
    }

    if (warnAtHalfLow) {
      warningFired.atHalfLow = true;
      sendBatteryNotification();
    }

    if (warnAtCritical) {
      warningFired.atCritical = true;
      sendBatteryNotification("Critical Power Warning");
    }

    if (batteryPercentage > low && !allWarningTriggersReset) {
      warningFired.atLow = false;
      warningFired.atHalfLow = false;
      warningFired.atCritical = false;
    }
  });
}
