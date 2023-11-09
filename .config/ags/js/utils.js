import cairo from "cairo";
import options from "./options.js";
import icons from "./icons.js";
import Theme from "./services/theme/theme.js";
import Gdk from "gi://Gdk";
import GLib from "gi://GLib";
import { Utils, App, Battery, Mpris, Audio } from "./imports.js";

export function toPercent(value) {
  return Math.floor(value * 100);
}

export function range(length, start = 1) {
  return Array.from({ length }, (_, i) => i + start);
}

export function substitute(collection, item) {
  return collection.find(([from]) => from === item)?.[1] || item;
}

export function forMonitors(widget) {
  const n = Gdk.Display.get_default().get_n_monitors();
  return range(n, 0).map(widget);
}

export function createSurfaceFromWidget(widget) {
  const alloc = widget.get_allocation();
  const surface = new cairo.ImageSurface(
    cairo.Format.ARGB32,
    alloc.width,
    alloc.height
  );
  const cr = new cairo.Context(surface);
  cr.setSourceRGBA(255, 255, 255, 0);
  cr.rectangle(0, 0, alloc.width, alloc.height);
  cr.fill();
  widget.draw(cr);

  return surface;
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
    const { low, critical } = options.batteryBar;
    const { _percent: batteryPercentage, _charging: charging } = battery;

    const warnAtLow =
      !charging && batteryPercentage <= low && !warningFired.atLow;
    const warnAtHalfLow =
      !charging && batteryPercentage <= low / 2 && !warningFired.atHalfLow;
    const warnAtCritical =
      !charging && batteryPercentage <= critical && !warningFired.atCritical;

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

/** @type {function(string): string}*/
export function getAudioTypeIcon(icon) {
  const substituesObj = {
    "audio-headset-bluetooth": icons.audio.type.headset,
    "audio-card-analog-pci": icons.audio.type.card,
    "audio-card-analog-usb": icons.audio.type.speaker,
  };

  return substituesObj?.[icon] ?? icon;
}

export function scssWatcher() {
  return Utils.subprocess(
    [
      "inotifywait",
      "--recursive",
      "--event",
      "create,modify",
      "-m",
      `/home/${Utils.USER}/Desktop/olaolu_dev/dotfiles/.config/ags/scss`,
    ],
    () => Theme.setup(),
    () => print("missing dependancy for css hotreload: inotify-tools")
  );
}

export function activePlayer() {
  let active;
  globalThis.mpris = () => active || Mpris.players[0];
  Mpris.connect("player-added", (mpris, bus) => {
    mpris.getPlayer(bus)?.connect("changed", (player) => {
      active = player;
    });
  });
}

export async function globalServices() {
  globalThis.audio = Audio;
  globalThis.ags = await import("./imports.js");
  globalThis.recorder = (await import("./services/screenrecord.js")).default;
  globalThis.brightness = (await import("./services/brightness.js")).default;
  globalThis.indicator = (
    await import("./services/onScreenIndicator.js")
  ).default;
  globalThis.theme = (await import("./services/theme/theme.js")).default;
}

export function launchApp(app) {
  Utils.execAsync(["hyprctl", "dispatch", "exec", `sh -c ${app.executable}`]);
  app.frequency += 1;
}

export function toggleClassesBasedOnBatteryStatus(widget, Battery) {
  const isPseudoFull = Battery._proxy.TimeToEmpty === 0;

  widget.toggleClassName(
    "charging",
    Battery.charging || Battery.charged || isPseudoFull
  );

  widget.toggleClassName("medium", Battery.percent < options.batteryBar.medium);

  widget.toggleClassName("low", Battery.percent < options.batteryBar.low);
}
