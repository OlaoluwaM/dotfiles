import App from "resource:///com/github/Aylur/ags/app.js";
import Service from "resource:///com/github/Aylur/ags/service.js";
import * as Utils from "resource:///com/github/Aylur/ags/utils.js";
import GLib from "gi://GLib";

const now = () => GLib.DateTime.new_now_local().format("%Y-%m-%d_%H-%M-%S");

class Recorder extends Service {
  static {
    Service.register(
      this,
      {},
      {
        timer: ["int"],
        recording: ["boolean"],
      }
    );
  }

  #path = `${GLib.get_home_dir()}/Videos/Screencasts`;
  #file = "";
  #interval = 0;

  recording = false;
  timer = 0;

  async start(full = false) {
    if (this.recording) return;

    try {
      Utils.ensureDirectory(this.#path);
      this.#file = `${this.#path}/screencast-from-${now()}.webm`;

      if (full) {
        Utils.execAsync(["wf-recorder", "-f", this.#file]);
      } else {
        const area = await Utils.execAsync("slurp");
        Utils.execAsync(["wf-recorder", "-g", area, "-f", this.#file]);
      }

      this.recording = true;
      this.changed("recording");
      this.timer = 0;

      this.#interval = Utils.interval(1000, () => {
        this.changed("timer");
        this.timer++;
      });
    } catch (error) {
      console.error(error);
    }
  }

  stop() {
    if (!this.recording) return;

    Utils.execAsync("killall -INT wf-recorder");
    this.recording = false;

    this.changed("recording");
    GLib.source_remove(this.#interval);

    Utils.execAsync([
      "notify-send",
      "-A",
      "files=Show in Files",
      "-A",
      "view=View",
      "-i",
      "video-x-generic-symbolic",
      "Screenrecord",
      this.#file,
    ])
      .then((res) => {
        if (res === "files") Utils.execAsync("xdg-open " + this.#path);

        if (res === "view") Utils.execAsync("xdg-open " + this.#file);
      })
      .catch(console.error);
  }

  async screenshot(full = false) {
    try {
      const path = `${GLib.get_home_dir()}/Pictures/Screenshots`;
      Utils.ensureDirectory(path);

      const file = `${path}/screenshot-from-${now()}.png`;

      if (full) {
        await Utils.execAsync(["wayshot", "-f", file]);
      } else {
        const area = await Utils.execAsync("slurp");
        // I'll keep these for debugging purposes
        console.log("Area received");
        await Utils.execAsync(["wayshot", "-s", area, "-f", file]);
        console.log("Screenshot saved");
      }

      Utils.execAsync(["bash", "-c", `wl-copy -f < ${file}`]);

      // Also for debugging purposes
      console.log("Screenshot copied to clipboard");

      // NOTE: Execution seems to be hanging here for some reason
      Utils.execAsync([
        "notify-send",
        `--icon=${file}`,
        "--action=files=Show in Files",
        "--action=view=View",
        "--action=edit=Edit",
        "Screenshot",
        file,
      ]).then((res) => {
        // I think the code needs to be written this way to avoid locks of a sort with notifications
        if (res === "files") Utils.execAsync("xdg-open " + path);

        if (res === "view") Utils.execAsync("xdg-open " + file);

        if (res === "edit") Utils.execAsync(["swappy", "-f", file]);

        App.closeWindow("dashboard");
      });
    } catch (error) {
      console.error(error);
      // Kept for debugging purposes
      Utils.execAsync([
        "notify-send",
        "--icon=error",
        "Screenshot Error",
        error,
      ]);
    }
  }
}

export default new Recorder();
