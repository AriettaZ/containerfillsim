#!/bin/bash

# WORKS GREAT and YOU NEED TO DO THIS TO SEE THE HISTORY when in foo/
# GIT_DIR=/Users/efranz/dev/tmp/foo.git git log
# GIT_DIR=/Users/efranz/dev/tmp/foo.git GIT_WORK_TREE=. git diff

# definitely in post-update so we can handle errors etc.
# Write to STDERR to see the output!!!
# pushd and popd do so!!!

if [ $GIT_DIR = "." ]; then
  GIT_WORK_TREE="${PWD%.*}"
  
  if [ ! -d $GIT_WORK_TREE ]; then
    mkdir $GIT_WORK_TREE
  fi
  
  # temporary make it writable
  chmod -R g+w $GIT_WORK_TREE
  
  GIT_WORK_TREE=$GIT_WORK_TREE git checkout -f
  GIT_WORK_TREE=$GIT_WORK_TREE git clean -f
  
  # copy files to $GIT_WORK_TREE/
  # cd into $GIT_WORK_TREE and run bundle install etc.
  
  # pushd $GIT_WORK_TREE
  #
  # inside directory do fun stuff
  # bundle install --local
  # echo `date` >> README.rdoc
  #
  # popd
  
  # kill write permissions
  chmod -R g-w $GIT_WORK_TREE
fi

# DOES NOT WORK SO GREAT
# if [ $GIT_DIR = "." ]; then
#   DEST="${PWD%.*}"
#   
#   if [ ! -d $DEST ]; then
#     git clone . $DEST
#   else
#     pushd $DEST
#     git checkout -f
#     git clean -f
#     popd
#   fi
# fi
