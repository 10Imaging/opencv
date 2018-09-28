#!/bin/bash 

rm -rf ~/10imaging/iris/opencv/src/main/jni/include/*
rm -rf ~/10imaging/iris/opencv/src/main/java/*
rm -rf ~/10imaging/iris/opencv/src/main/jniLibs/*

if [ "$1" == "debug" ]; then
  cp -av install.android.debug/src/main/jni/include/* ~/10imaging/iris/opencv/src/main/jni/include/
  cp -av install.android.debug/src/main/java/* ~/10imaging/iris/opencv/src/main/java/
  cp -av install.android.debug/src/main/jnilibs/* ~/10imaging/iris/opencv/src/main/jniLibs/
  cp -av install.android.debug/src/main/AndroidManifest.xml ~/10imaging/iris/opencv/src/main/AndroidManifest.xml 
else
  cp -av install.android.release/src/main/jni/include/* ~/10imaging/iris/opencv/src/main/jni/include/
  cp -av install.android.release/src/main/java/* ~/10imaging/iris/opencv/src/main/java/
  cp -av install.android.release/src/main/jnilibs/* ~/10imaging/iris/opencv/src/main/jniLibs/
  cp -av install.android.release/src/main/AndroidManifest.xml ~/10imaging/iris/opencv/src/main/AndroidManifest.xml 
fi