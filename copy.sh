#!/bin/bash

if [ "${1}" == "dropbox" ]; THEN
  [ -d ${HOME}/Dropbox ] && DBX=${HOME}/Dropbox/Downloads/opencv/${HOSTNAME}
  [ -z ${DBX} ] && echo "Dropbox not found. Please install Dropbox at "${HOME}/Dropbox && exit 1
  cp -av install.android.debug ${DBX}
  cp -av install.android.release ${DBX}
else
  rm -rf ~/10imaging/iris/opencv/src/main/jni/include/*
  rm -rf ~/10imaging/iris/opencv/src/main/java/*
  rm -rf ~/10imaging/iris/opencv/src/main/res/*
  rm -rf ~/10imaging/iris/opencv/src/main/jniLibs/*
fi

if [ "${1}" == "debug" ]; then
  cp -av install.android.debug/src/main/jni/include/* ~/10imaging/iris/opencv/src/main/jni/include/
  cp -av install.android.debug/src/main/java/* ~/10imaging/iris/opencv/src/main/java/
  cp -av install.android.debug/src/main/res/* ~/10imaging/iris/opencv/src/main/res/
  cp -av install.android.debug/src/main/jnilibs/* ~/10imaging/iris/opencv/src/main/jniLibs/
  cp -av install.android.debug/src/main/AndroidManifest.xml ~/10imaging/iris/opencv/src/main/AndroidManifest.xml
else
  cp -av install.android.release/src/main/jni/include/* ~/10imaging/iris/opencv/src/main/jni/include/
  cp -av install.android.release/src/main/java/* ~/10imaging/iris/opencv/src/main/java/
  cp -av install.android.release/src/main/res/* ~/10imaging/iris/opencv/src/main/res/
  cp -av install.android.release/src/main/jnilibs/* ~/10imaging/iris/opencv/src/main/jniLibs/
  cp -av install.android.release/src/main/AndroidManifest.xml ~/10imaging/iris/opencv/src/main/AndroidManifest.xml
fi
