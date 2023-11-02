import options from "./options.js";
import { Variable, Utils } from "./imports.js";

// eslint-disable-next-line consistent-return
const prettyUptime = (uptimeStr) => {
  // This regex will capture any text after "up " and include the hh:mm before the comma and "n users"
  const regex = /up\s+(.*?)(?=\s*,\s*\d+\s+users)/;
  const match = uptimeStr.match(regex);
  return match ? match[1] : null;
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
