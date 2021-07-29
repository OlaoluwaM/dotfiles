#!/usr/bin/env node

const fsPromise = require('fs/promises');
const path = require('path');

const linuxDistro = process.argv?.[2].replace('--', '');
const homeDir = process.env.HOME;

function displayRejectedSymlinks(symlinkResultsArr) {
  const rejectedSymlinks = symlinkResultsArr.filter(
    ({ status }) => status === 'rejected'
  );

  rejectedSymlinks.forEach(console.log);
}

// Make symlinks for all the files in the common directory
async function createSymlinksForCommonDotFiles() {
  const commonDotFiles = await fsPromise.readdir(
    path.resolve(__dirname, 'common')
  );

  const results = await Promise.allSettled(
    commonDotFiles.map(file =>
      fsPromise.symlink(
        path.resolve(__dirname, `common/${file}`),
        path.resolve(homeDir, file)
      )
    )
  );

  displayRejectedSymlinks(results);
}

async function createSymlinksForDistroDotfiles() {
  const distroFolderName = linuxDistro.toLocaleLowerCase();

  const dotfilesForDistro = await fsPromise.readdir(
    path.resolve(__dirname, 'linux', distroFolderName)
  );

  const results = await Promise.allSettled(
    dotfilesForDistro.map(file =>
      fsPromise.symlink(
        path.resolve(__dirname, 'linux', `${distroFolderName}/${file}`),
        path.resolve(homeDir, file)
      )
    )
  );

  displayRejectedSymlinks(results);
}

async function createSymlinks() {
  await Promise.all([
    createSymlinksForCommonDotFiles(),
    linuxDistro && createSymlinksForDistroDotfiles(),
  ]);

  console.log('Done!');
}

createSymlinks();
