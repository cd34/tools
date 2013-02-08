#!/bin/bash
# initial gitosis update so I could import 50 repos without having
# to retype

DIR=`pwd`
PACKAGE=${DIR##*/}

git init
git remote add origin git@devel.mia:$PACKAGE.git
git add .
git commit -m 'Initial Import'
git push origin master:refs/heads/master
