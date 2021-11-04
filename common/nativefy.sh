#!/usr/bin/env bash

outputDir="$HOME/other_apps"
appName=$1
appUrl=$2

nativefier --name $appName $appUrl "$outputDir"

nativeAppFolderName="${appName}-linux-x64"
tempDesktopFilePath="$HOME/$(echo "$appName" | tr '[:upper:]' '[:lower:]').desktop"

# Create .desktop file for app
cat <<EOT >>"$tempDesktopFilePath"
[Desktop Entry]

Type=Application

Version=1.0

Name=$appName

Comment=$appName for Linux

Path=$outputDir/$nativeAppFolderName

Exec=$outputDir/$nativeAppFolderName/$appName

Icon=$outputDir/$nativeAppFolderName/resources/app/icon.png

Terminal=false
EOT

mv "$tempDesktopFilePath" "$HOME/.local/share/applications"
