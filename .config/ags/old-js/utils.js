import options from "./options.js";
import icons from "./icons.js";
import { Utils, Mpris, } from "./imports.js";

// @ts-expect-error
import Gdk from "gi://Gdk";
// @ts-expect-error
import cairo from "cairo";

export function toPercent(value) {
  return Math.floor(value * 100);
}

/**
 * @param {number} length
 * @param {number=} start
 * @returns {Array<number>}
 */
export function range(length, start = 1) {
  return Array.from({ length }, (_, i) => i + start);
}

/**
 * @param {Array<[string, string] | string[]>} collection
 * @param {string} item
 * @returns {string}
 */
export function substitute(collection, item) {
  return collection.find(([from]) => from === item)?.[1] || item;
}

export function forMonitors(widget) {
  const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
  return range(n, 0).map(widget).flat(1);
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

/**
 * Generates the audio type icon based on the given icon name.
 *
 * @param {string} icon - The name of the icon.
 * @return {string} The corresponding audio type icon.
 */
export function getAudioTypeIcon(icon) {
  const substituesObj = {
    "audio-headset-bluetooth": icons.audio.type.headset,
    "audio-card-analog-pci": icons.audio.type.card,
    "audio-card-analog-usb": icons.audio.type.speaker,
  };

  return substituesObj?.[icon] ?? icon;
}



// Was removed in latest version of Aylur's dots
export function activePlayer() {
  let active;
  globalThis.mpris = () => active || Mpris.players[0];
  Mpris.connect("player-added", (mpris, bus) => {
    mpris.getPlayer(bus)?.connect("changed", (player) => {
      active = player;
    });
  });
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

  widget.toggleClassName("medium", Battery.percent < options.batteryBar.medium.value);

  widget.toggleClassName("low", Battery.percent < options.batteryBar.low.value);
}
