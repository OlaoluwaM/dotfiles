#!/usr/bin/env zx

// Please make sure zx is installed

const HOME_DIR = os.homedir();
const HIDDEN_FOLDER_REGEX = /^\..*/;
const HOME_DIR_REGEX = /~|\$HOME/;

async function createSymlinksForFolderContents(folderName) {
  const filesWithDestinations = await getFolderContentsWithDestinations(
    folderName
  );

  const results = await Promise.allSettled(
    filesWithDestinations.map(([filename, destinationPath]) =>
      createSymlink(folderName, filename, destinationPath)
    )
  );

  const filenamesOnly = filesWithDestinations.filter(([file]) => file);
  outputSymlinkOperationResults(results, filenamesOnly);
}

async function getFolderContentsWithDestinations(folderName) {
  const allFilesInFolder = await fs.readdir(
    path.resolve(__dirname, folderName)
  );

  const requiredFiles = allFilesInFolder.filter(
    file => file !== 'destinations.json'
  );

  const destinationsString = fs.readFileSync(
    path.resolve(__dirname, folderName, 'destinations.json')
  );

  const destinationsObj = JSON.parse(
    destinationsString,
    processDestinationString
  );

  return requiredFiles.map(file => [
    file,
    generateFileDestination(file, destinationsObj, HOME_DIR),
  ]);
}

function processDestinationString(key, pathString) {
  if (!key) return pathString;

  return HOME_DIR_REGEX.test(pathString)
    ? pathString.replace(HOME_DIR_REGEX, HOME_DIR)
    : pathString;
}

function generateFileDestination(filename, destinationsObj, homeDir) {
  return destinationsObj?.[filename] ?? destinationsObj?.['*'] ?? homeDir;
}

async function createSymlink(folderName, file, destinationPath = HOME_DIR) {
  await deleteSymlinkIfItExists(file, destinationPath);

  return Promise.all([
    fs.symlink(
      path.resolve(__dirname, `${folderName}/${file}`),
      path.resolve(destinationPath, file)
    ),

    Promise.resolve(
      `Success! ${file} symlinked in ${destinationPath} directory`
    ),
  ]);
}

async function deleteSymlinkIfItExists(file, destinationPath = HOME_DIR) {
  try {
    return await fs.unlink(path.resolve(destinationPath, file));
  } catch (error) {
    return Promise.resolve('No such symlink exists');
  }
}

function outputSymlinkOperationResults(symlinkResults, folderContents) {
  symlinkResults.forEach((promiseResult, ind) => {
    const isRejectedPromise = 'reason' in promiseResult;
    const filename = folderContents[ind];

    if (isRejectedPromise) {
      error(`Symlink could not be created for file ${filename}`);
      error(promiseResult.reason);
      return;
    }

    promiseResult.value.forEach(output => {
      if (!output) return;
      success(output);
    });
  });
}

function success(message) {
  console.info(chalk.bold.green(message));
}

function error(message) {
  console.error(chalk.bold.red(message));
}

function parseDirectoriesFromArguments() {
  const dirs = process.argv.slice(3);
  return dirs;
}

async function getDirectories(path) {
  const directoryContents = await fs.readdir(path, { withFileTypes: true });

  return directoryContents
    .filter(
      dirent => dirent.isDirectory() && !HIDDEN_FOLDER_REGEX.test(dirent.name)
    )
    .map(dirent => dirent.name);
}

async function generateDirectoriesToWorkOn(path = __dirname) {
  const passedDirectories = parseDirectoriesFromArguments();
  const allDirs = await getDirectories(path);

  if (passedDirectories.length === 0) return allDirs;

  const directoriesToWorkOn = passedDirectories.filter(dirname =>
    allDirs.includes(dirname)
  );

  if (directoriesToWorkOn.length === 0) {
    error('Looks like the directories you entered do not exist :/');
    error('You can run this with no arguments to work on all dirs');
    process.exit(1);
  }

  return directoriesToWorkOn;
}

const foldersToSymlink = await generateDirectoriesToWorkOn();
await Promise.allSettled(
  foldersToSymlink.map(folder => createSymlinksForFolderContents(folder))
);
