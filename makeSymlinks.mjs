#!/usr/bin/env zx

// Please make sure zx is installed
const HOME_DIR = os.homedir();
const HOME_DIR_REGEX = new RegExp(/[~|$HOME]/);

function success(message) {
  return chalk.bold.green(message);
}

function error(message) {
  return chalk.bold.red(message);
}

function outputSymlinkOperationResults(symlinkResults, folderContents) {
  symlinkResults.forEach((promiseResult, ind) => {
    const isRejectedPromise = 'reason' in promiseResult;
    const filename = folderContents[ind];

    if (isRejectedPromise) {
      console.error(error(`Symlink could not be created for file ${filename}`));
      console.error(promiseResult.reason);
      return;
    }

    promiseResult.value.forEach(output => {
      if (!output) return;
      console.log(success(output));
    });
  });
}

async function deleteSymlinkWithoutException(file, destinationPath = HOME_DIR) {
  try {
    return await fs.unlink(path.resolve(destinationPath, file));
  } catch (error) {
    return Promise.resolve('No such symlink exists');
  }
}

async function createSymlink(folderName, file, destinationPath = HOME_DIR) {
  await deleteSymlinkWithoutException(file, destinationPath);

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

function processDestinationString(key, pathString) {
  if (!key) return pathString;

  return HOME_DIR_REGEX.test(pathString)
    ? pathString.replace(HOME_DIR_REGEX, HOME_DIR)
    : pathString;
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

  return requiredFiles.map(file => [file, destinationsObj?.[file] ?? HOME_DIR]);
}

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

const foldersToSymlink = ['git', 'zsh', 'npm', 'tmux', 'neofetch', 'others'];
foldersToSymlink.forEach(folder => createSymlinksForFolderContents(folder));

// TODO: Add support for linux distros via CLI argument
