#!/bin/bash

if [ "${1}" == "dropbox" ]; then
  [ -d ${HOME}/Dropbox ] && DBX=${HOME}/Dropbox/Downloads/opencv/${HOSTNAME}
  [ -z ${DBX} ] && echo "Dropbox not found. Please install Dropbox at "${HOME}/Dropbox && exit 1
  cp -av install.android.debug ${DBX}
  cp -av install.android.release ${DBX}
  cp copy.sh ${DBX}/install.android.debug
  cp copy.sh ${DBX}/install.android.release
else
  [ ! -d ${HOME}/10imaging/iris/opencv/src/main ] && echo "Iris not found at "${HOME}/10imaging/iris && exit 1
  SCRIPT_FILEPATH="$(cd "$(dirname "$0")"; pwd)/$(basename "$0")"
  SCRIPT_PATH=`dirname $SCRIPT_FILEPATH`
  [[ ${SCRIPT_FILEPATH} == **install.android.debug** ]] && BUILD_TYPE=debug
  [[ ${SCRIPT_FILEPATH} == **install.android.release** ]] && BUILD_TYPE=release
  [[ ${1} == debug || ${1} == release ]] && BUILD_TYPE=${1}
  if [[ ${BUILD_TYPE} == debug || ${BUILD_TYPE} == release ]]; then
    rm -rf ~/10imaging/iris/opencv/src/main/*
    if [[ ${SCRIPT_PATH} =~ .*install.android.${BUILD_TYPE} ]] ; then
      echo Copying from Dropbox
      cp -a ${SCRIPT_PATH}/src/main/* ~/10imaging/iris/opencv/src/main
    else
      echo Copying from build
      cp -a ${SCRIPT_PATH}/install.android.${BUILD_TYPE}/src/main/* ~/10imaging/iris/opencv/src/main
    fi
  else
    echo "BUILD_TYPE not set. No files copied."
  fi
fi
