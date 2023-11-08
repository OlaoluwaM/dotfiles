import { Service, Utils, App } from "../imports.js";
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

  _path = GLib.get_home_dir() + "/Videos/Screencasts";
  _screenshotting = false;
  recording = false;
  timer = 0;

  async start(full = false) {
    if (this.recording) return;

    // Utils.execAsync("slurp")
    //   .then((area) => {
    //     Utils.ensureDirectory(this._path);
    //     this._file = `${this._path}/${now()}.mp4`;
    //     Utils.execAsync(["wf-recorder", "-g", area, "-f", this._file]);
    //     this.recording = true;
    //     this.changed("recording");

    //     this.timer = 0;
    //     this._interval = Utils.interval(1000, () => {
    //       this.changed("timer");
    //       this.timer++;
    //     });
    //   })
    //   .catch((err) => console.error(err));

    try {
      Utils.ensureDirectory(this._path);
      this._file = `${this._path}/${now()}.webm`;

      if (full) {
        Utils.execAsync(["wf-recorder", "-f", this._file]);
      } else {
        const area = await Utils.execAsync("slurp");
        Utils.execAsync(["wf-recorder", "-g", area, "-f", this._file]);
      }

      this.recording = true;
      this.changed("recording");
      this.timer = 0;
      this._interval = Utils.interval(1000, () => {
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
    GLib.source_remove(this._interval);
    Utils.execAsync([
      "notify-send",
      "-A",
      "files=Show in Files",
      "-A",
      "view=View",
      "-i",
      "video-x-generic-symbolic",
      "Screenrecord",
      this._file,
    ])
      .then((res) => {
        if (res === "files") Utils.execAsync("xdg-open " + this._path);

        if (res === "view") Utils.execAsync("xdg-open " + this._file);
      })
      .catch(console.error);
  }

  async screenshot(full = false) {
    try {
      const path = GLib.get_home_dir() + "/Pictures/Screenshots";
      Utils.ensureDirectory(path);

      const file = `${path}/${now()}.png`;

      if (full) {
        await Utils.execAsync(["wayshot", "-f", file]);
      } else {
        const area = await Utils.execAsync("slurp");
        // I'll keep these for debugging purposes
        console.log("Area received");
        await Utils.execAsync(["wayshot", "-s", area, "-f", file])
          .then(console.log)
          .catch(console.error);
        console.log("Screenshot saved");
      }

      await Utils.execAsync(["bash", "-c", `wl-copy < ${file}`]);

      // NOTE: Execution seems to be hanging here for some reason
      const res = await Utils.execAsync([
        "notify-send",
        `--icon=${file}`,
        "--action=files=Show in Files",
        "--action=view=View",
        "--action=edit=Edit",
        "Screenshot",
        file,
      ]);

      console.log({ res });

      //   if (res === "files") Utils.execAsync("xdg-open " + path);

      //   if (res === "view") Utils.execAsync("xdg-open " + file);

      //   if (res === "edit") Utils.execAsync(["swappy", "-f", file]);

      //   App.closeWindow("dashboard");
    } catch (error) {
      console.error(error);
      await Utils.execAsync([
        "notify-send",
        "--icon=error",
        "Screenshot Error",
        error,
      ]);
    }
  }
}

export default new Recorder();
