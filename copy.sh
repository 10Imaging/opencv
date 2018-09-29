#!/bin/bash

if [ "${1}" == "dropbox" ]; then
  [ -d ${HOME}/Dropbox ] && DBX=${HOME}/Dropbox/Downloads/opencv/${HOSTNAME}
  [ -z ${DBX} ] && echo "Dropbox not found. Please install Dropbox at "${HOME}/Dropbox && exit 1
  cp -av install.android.debug ${DBX}
  cp -av install.android.release ${DBX}
else
  rm -rf ~/10imaging/iris/opencv/src/main/*
fi

[ ! -d ${HOME}/10imaging/iris/opencv/src/main] && echo "Iris not found at "${HOME}/10imaging/iris && exit 1

if [ "${1}" == "debug" ]; then
  cp -av install.android.debug/src/main/* ~/10imaging/iris/opencv/src/main
else
  cp -av install.android.release/src/main/* ~/10imaging/iris/opencv/src/main
fi
