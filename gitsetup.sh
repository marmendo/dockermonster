#!/bin/sh
git init
git add *
git commit -m "Initial commit"
#git remote add origin ssh://localhost/demo/dockermonster.git
#git remote add origin git://localhost/demo/dockermonster.git
git remote add origin https://github.com/marmendo/dockermonster.git
#git clone --bare ~/git/dockermonster dockermonster.git
git push
