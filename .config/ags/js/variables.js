// @ts-expect-error
import GLib from "gi://GLib";
import options from "./options.js";
import Variable from "resource:///com/github/Aylur/ags/variable.js";

const intval = options.systemFetchInterval;

function prettifyTime(timeString) {
  // Validate the time format "hh:mm"
  if (!/^\d{1,2}:\d{2}$/.test(timeString)) {
    // If the format is incorrect, return the original string
    return timeString;
  }

  // Split the time string into hours and minutes
  const [hoursComponent, minutesComponent] = timeString.split(":");

  // Convert string to numbers
  const hours = parseInt(hoursComponent, 10);
  const minutes = parseInt(minutesComponent, 10);

  // Determine the hour and minute text
  const hoursText = hours === 1 ? "hour" : "hours";
  const minutesText = minutes === 1 ? "minute" : "minutes";

  // Build the prettified time string
  let prettifiedTime = "";

  if (hours > 0) {
    prettifiedTime += `${hours} ${hoursText}`;
  }
  if (minutes > 0) {
    if (prettifiedTime.length > 0) {
      prettifiedTime += ", ";
    }
    prettifiedTime += `${minutes} ${minutesText}`;
  }

  return prettifiedTime || "0 minutes";
}

// eslint-disable-next-line consistent-return
const prettyUptime = (uptimeStr) => {
  // This regex will capture any text after "up " and before ", n users" or " n users"
  // accounting for cases where there is no comma before the number of users.
  const regex = /up\s+(.*?)(?=\s*(,|\d+\s+users))/;
  const match = uptimeStr.match(regex);
  const output = match[1] ?? "00:00";

  return prettifyTime(output);
};

export const uptime = Variable(0, {
  poll: [60_000, "uptime", prettyUptime],
});

export const distro = GLib.get_os_info("ID");

export const distroIcon = (() => {
  switch (distro) {
    case "fedora":
      return "";
    case "arch":
      return "";
    case "nixos":
      return "";
    case "debian":
      return "";
    case "opensuse-tumbleweed":
      return "";
    case "ubuntu":
      return "";
    case "endeavouros":
      return "";
    default:
      return "";
  }
})();

/** @type {function([string, string] | string[]): number} */
const divide = ([total, free]) =>
  Number.parseInt(free) / Number.parseInt(total);

export const cpu = Variable(0, {
  poll: [
    intval,
    "top -b -n 1",
    (out) =>
      divide([
        "100",
        out
          .split("\n")
          .find((line) => line.includes("Cpu(s)"))
          ?.split(/\s+/)[1]
          .replace(",", ".") || "0",
      ]),
  ],
});

export const ram = Variable(0, {
  poll: [
    intval,
    "free",
    (out) =>
      divide(
        out
          .split("\n")
          .find((line) => line.includes("Mem:"))
          ?.split(/\s+/)
          .splice(1, 2) || ["1", "1"]
      ),
  ],
});

export const temp = Variable(0, {
  poll: [
    intval,
    "cat " + options.temperature,
    (n) => {
      return Number.parseInt(n) / 100_000;
    },
  ],
});
