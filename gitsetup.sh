#!/bin/sh
git init
git add *
git commit -m "Initial commit"
git remote add origin https://github.com/marmendo/dockermonster.git
git push --set-upstream origin master
