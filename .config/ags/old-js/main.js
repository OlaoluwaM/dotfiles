// import TopBar from "./bar/TopBar.js";
// import ScreenCorners from "./screencorner/ScreenCorners.js";
// import Overview from "./overview/Overview.js";
// import Dashboard from "./dashboard/Dashboard.js";
import OSD from "./osd/OSD.js";
// import QuickSettings from "./quicksettings/QuickSettings.js";
import options from "./options.js";
import * as setup from "./utils.js";
import { forMonitors } from "./utils.js";

setup.warnOnLowBattery();
setup.scssWatcher();
setup.globalServices();
// setup.activePlayer();

const windows = () => [
  // forMonitors(TopBar),
  // forMonitors(ScreenCorners),
  forMonitors(OSD),
  // Overview(),
  // Dashboard(),
  // QuickSettings(),
];

export default {
  windows: windows().flat(2),
  maxStreamVolume: 1.05,
  // cacheNotificationActions: true,
  closeWindowDelay: {
    quicksettings: options.windowAnimationDuration,
    dashboard: options.windowAnimationDuration,
  },
};
