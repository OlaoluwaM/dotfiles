import options from "./options.js";
import { Variable, Utils } from "./imports.js";

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

export const distro = Utils.exec("cat /etc/os-release")
  .split("\n")
  .find((line) => line.startsWith("ID"))
  .split("=")[1];

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

const divide = ([total, free]) => free / total;
export const cpu = Variable(0, {
  poll: [
    options.systemFetchInterval,
    "top -b -n 1",
    (out) =>
      divide([
        100,
        out
          .split("\n")
          .find((line) => line.includes("Cpu(s)"))
          .split(/\s+/)[1]
          .replace(",", "."),
      ]),
  ],
});

export const ram = Variable(0, {
  poll: [
    options.systemFetchInterval,
    "free",
    (out) =>
      divide(
        out
          .split("\n")
          .find((line) => line.includes("Mem:"))
          .split(/\s+/)
          .splice(1, 2),
      ),
  ],
});

export const temp = Variable(0, {
  poll: [
    options.systemFetchInterval,
    `cat ${options.temperature}`,
    (n) => n / 100_000,
  ],
});
