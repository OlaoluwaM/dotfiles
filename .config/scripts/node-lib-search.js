const fs = require("node:fs/promises");
const path = require("path");
const util = require("node:util");
const exec = require("node:child_process").exec;

const promiseExec = util.promisify(exec);

async function main() {
  const libraryPath = process.env.LIBRARY;
  const files = await fs.readdir(libraryPath, { recursive: true });
  const absolutePdfFilePaths = files.filter((file) => file.endsWith(".pdf"));

  const pdfFileNameToAbsFilePathMap = absolutePdfFilePaths.reduce(
    (pathMap, absPdfPath) => {
      const key = path.basename(absPdfPath, ".pdf");
      pathMap[key] = absPdfPath;
      return pathMap;
    },
    {}
  );

  const pdfNames = absolutePdfFilePaths.map((filepath) =>
    path.basename(filepath, ".pdf")
  );

  const { stdout } = await promiseExec(
    `echo -e "${pdfNames.join("\n")}" | fuzzel -d`
  );

  const chosenFile = stdout.trim();
  await promiseExec(
    `xdg-open "${libraryPath}/${pdfFileNameToAbsFilePathMap[chosenFile]}"`
  );
}

main();
