#!/usr/bin/env bash

# It seems like `bare` repositories are the kind of repositories we have on GitHub. 
# We can also create bare repositories locally and use them as local remotes
# https://stackoverflow.com/questions/10603671/how-to-add-a-local-repo-and-treat-it-as-a-remote-repo
# https://stackoverflow.com/questions/33225785/mock-a-git-repo-to-test-against

# Create a local git repository like normal
mkdir <dir_name>
cd <dir_name>
touch .gitignore README.md index.txt
git init

# Commit changes in regular repo
git add -A
git commit -m "repo init"

# Now create a local remote repo using `git clone`
cd ..
git clone --bare /path/to/normal/repo /path/to/desired/location/for/upstream

# Not hook the two up
cd /path/to/normal/repo/created/initially
git remote add origin /path/to/created/upstream

# Push to local upstream
git push -u origin HEAD
