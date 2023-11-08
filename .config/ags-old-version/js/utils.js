import Cairo from "cairo";
import GLib from "gi://GLib";
import options from "./options.js";
import icons from "./icons.js";
import Theme from "./services/theme/theme.js";
import { Utils, Battery } from "./imports.js";

export function toPercent(value) {
  return Math.floor(value * 100);
}

export function range(length, start = 1) {
  return Array.from({ length }, (_, i) => i + start);
}

export function substitute(collection, item) {
  return collection?.[item] ?? item;
}

export function forMonitors(widget) {
  const ws = JSON.parse(Utils.exec("hyprctl -j monitors"));
  return ws.map((mon) => widget(mon.id));
}

export function createSurfaceFromWidget(widget) {
  const alloc = widget.get_allocation();
  const surface = new Cairo.ImageSurface(
    Cairo.Format.ARGB32,
    alloc.width,
    alloc.height,
  );

  const cr = new Cairo.Context(surface);
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
      `${GLib.getenv("DOTS")}/ags/scss`,
    ],
    () => Theme.setup(),
  );
}

export async function globalServices() {
  globalThis.ags = await import("./imports.js");
  globalThis.recorder = (await import("./services/screenrecord.js")).default;
  globalThis.brightness = (await import("./services/brightness.js")).default;
  globalThis.indicator = (
    await import("./services/onScreenIndicator.js")
  ).default;
  globalThis.theme = (await import("./services/theme/theme.js")).default;
  globalThis.audio = globalThis.ags.Audio;
  globalThis.mpris = globalThis.ags.Mpris;
}

export function launchApp(appParam) {
  const app = appParam;
  Utils.execAsync(`hyprctl dispatch exec ${app.executable}`);
  app.frequency += 1;
}

export function toggleClassesBasedOnBatteryStatus(widget, Battery) {
  const isPseudoFull = Battery._proxy.TimeToEmpty === 0;

  widget.toggleClassName(
    "charging",
    Battery.charging || Battery.charged || isPseudoFull,
  );

  widget.toggleClassName("medium", Battery.percent < options.batteryBar.medium);

  widget.toggleClassName("low", Battery.percent < options.batteryBar.low);
}
