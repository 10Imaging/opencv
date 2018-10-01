#!/bin/bash

if [ "${1}" == "dropbox" ]; then
  DATE_STAMP=`date +%Y-%m-%d`
  [ -d ${HOME}/Dropbox/Downloads ] && DBX=${HOME}/Dropbox/Downloads/opencv/${HOSTNAME}/${DATE_STAMP}
  [ -z ${DBX} ] && echo "Dropbox not found. Please install Dropbox at "${HOME}/Dropbox" and include Downloads directory." && exit 1
  echo Copying debug and release build to Dropbox at ${DBX}
  [ ! -d ${DBX} ] && mkdir -p ${DBX}
  cp -a install.android.debug ${DBX}
  cp -a install.android.release ${DBX}
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
      echo Copying ${BUILD_TYPE} from build
      cp -a ${SCRIPT_PATH}/install.android.${BUILD_TYPE}/src/main/* ~/10imaging/iris/opencv/src/main
    fi
  else
    echo "BUILD_TYPE not set. No files copied."
  fi
fi
