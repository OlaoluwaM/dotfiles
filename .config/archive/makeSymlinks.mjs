#!/usr/bin/env node

import os from 'os';
import path from 'path';

import { fileURLToPath } from 'url';
import { readFileSync, existsSync } from 'fs';
import { symlink, readdir, unlink, mkdir } from 'fs/promises';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const HOME_DIR = os.homedir();
const HIDDEN_FOLDER_REGEX = /^\..*/;
const HOME_DIR_REGEX = /~|\$HOME/;
const IGNORE_KEY = '!';

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
  const allFilesInFolder = await readdir(path.resolve(__dirname, folderName));

  const requiredFiles = allFilesInFolder.filter(
    file => file !== 'destinations.json'
  );

  const destinationsString = readFileSync(
    path.resolve(__dirname, folderName, 'destinations.json')
  );

  const destinationsObj = JSON.parse(
    destinationsString,
    processDestinationString
  );

  const filesToIgnore = determineFilesToExclude(destinationsObj, requiredFiles);

  const fileDestinationMap = requiredFiles.map(file => [
    file,
    generateFileDestination(file, destinationsObj, HOME_DIR),
  ]);

  const fileDestinationMapWithoutIgnoredFiles = excludeIgnoredFiles(
    fileDestinationMap,
    filesToIgnore,
    folderName
  );

  return fileDestinationMapWithoutIgnoredFiles;
}

function processDestinationString(key, pathString) {
  if (!key) return pathString;

  if (key === IGNORE_KEY) {
    const filenameArr = pathString;
    return filenameArr;
  }

  return HOME_DIR_REGEX.test(pathString)
    ? pathString.replace(HOME_DIR_REGEX, HOME_DIR)
    : pathString;
}

function determineFilesToExclude(destinationsObj, allFilesInFolder) {
  const filesToPotentiallyExclude = destinationsObj?.[IGNORE_KEY] ?? [];
  if (Array.isArray(filesToPotentiallyExclude))
    return filesToPotentiallyExclude;

  const filesWithSetDestinations = allFilesInFolder.filter(
    filename => !!destinationsObj?.[filename]
  );
  const filesToExclude = allFilesInFolder.filter(
    filename => !filesWithSetDestinations.includes(filename)
  );
  return filesToExclude;
}

function generateFileDestination(filename, destinationsObj, homeDir) {
  const destinationPath =
    destinationsObj[filename] ?? destinationsObj['*'] ?? homeDir;

  return destinationPath;
}

function excludeIgnoredFiles(fileDestinationArr, filesToExclude, folderName) {
  const IGNORE_ALL_SYMBOL = '*';

  if (Array.isArray(filesToExclude)) {
    filesToExclude.forEach(file => info(`${file} is being ignored`));
  }

  const filesListWithoutIgnoredFiles = fileDestinationArr.filter(([filename]) =>
    filesToExclude === IGNORE_ALL_SYMBOL
      ? false
      : !filesToExclude.includes(filename)
  );

  if (isEmpty.array(filesListWithoutIgnoredFiles)) {
    const msg = `Seems like all the files in the ${folderName} folder are being ignored`;
    error(msg);
    throw new Error(msg);
  }

  return filesListWithoutIgnoredFiles;
}

async function createSymlink(folderName, file, destinationPath = HOME_DIR) {
  await deleteSymlinkIfItExists(file, destinationPath);
  await createDirIfItDoesNotExists(destinationPath);

  return Promise.all([
    symlink(
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
    return await unlink(path.resolve(destinationPath, file));
  } catch (error) {
    return Promise.resolve('No such symlink exists');
  }
}

async function createDirIfItDoesNotExists(dirPath) {
  const dirExists = existsSync(dirPath);
  if (dirExists) return;

  try {
    await mkdir(dirPath, { recursive: true });
  } catch (error) {
    console.error(error);
    return;
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

function info(message) {
  const INFO_COLOR_CODE = '\x1b[1m\x1b[37m%s\x1b[0m';
  console.info(INFO_COLOR_CODE, message);
}

function success(message) {
  const SUCCESS_COLOR_CODE = '\x1b[1m\x1b[32m%s\x1b[0m';
  console.info(SUCCESS_COLOR_CODE, message);
}

function error(message) {
  const ERROR_COLOR_CODE = '\x1b[1m\x1b[31m%s\x1b[0m';
  console.error(ERROR_COLOR_CODE, message);
}

const isEmpty = {
  array(possiblyEmptyArray) {
    return possiblyEmptyArray.length === 0;
  },
};

function excludeFromCollection(collection, subSetOExclude) {
  const filteredCollection = collection.filter(
    elem => !subSetOExclude.includes(elem)
  );

  return filteredCollection;
}

function parseDirectoriesFromArguments() {
  const STARTING_INDEX_OF_ARGS = 2;
  const dirs = process.argv.slice(STARTING_INDEX_OF_ARGS);
  return dirs;
}

async function getDirectories(pathToDirs) {
  const directoryContents = await readdir(pathToDirs, {
    withFileTypes: true,
  });

  return directoryContents
    .filter(
      dirent => dirent.isDirectory() && !HIDDEN_FOLDER_REGEX.test(dirent.name)
    )
    .map(dirent => dirent.name);
}

async function generateDirectoriesToWorkOn(pathToDirs = __dirname) {
  const passedDirectories = parseDirectoriesFromArguments();
  const allDirs = await getDirectories(pathToDirs);

  if (isEmpty.array(passedDirectories)) return allDirs;

  const directoriesToWorkOn = passedDirectories.filter(dirname =>
    allDirs.includes(dirname)
  );

  if (isEmpty.array(directoriesToWorkOn)) {
    error('Looks like the directories you entered do not exist :/');
    error('You can run this with no arguments to work on all dirs');
    process.exit(1);
  }

  return directoriesToWorkOn;
}

function excludeCertainDirs(dirs) {
  const dirsToExclude = ['notion', 'dak-reader', 'mailspring', 'fly-pie'];
  const result = excludeFromCollection(dirs, dirsToExclude);
  if (result.length > 0) return result;

  error('Sorry, the dirs you provided cannot be symlinked');
  process.exit(127);
}

const foldersToSymlink = excludeCertainDirs(
  await generateDirectoriesToWorkOn()
);

await Promise.allSettled(
  foldersToSymlink.map(folder => createSymlinksForFolderContents(folder))
);
