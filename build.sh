#!/bin/bash

## Defaults
OPENCV_BUILD_VERSION=3.4.5
BUILD_ANDROID=0
BUILD_PC=1
ANDROID_BUILD_ABIS="arm7-android arm8-android"
PC_BUILD_ABIS="x64-ubuntu x64-osx"
SCRIPT_FILEPATH="$(cd "$(dirname "$0")"; pwd)/$(basename "$0")"
OPENCV_PATH=`dirname $SCRIPT_FILEPATH`
PWD=$(pwd)

## Configuration
git checkout $OPENCV_BUILD_VERSION
[ $? != 0 ] && echo "OpenCV version ${OPENCV_BUILD_VERSION} does not exist in current repo." && exit 1
[ -z ${ANDROID_NDK} ] && echo "ANDROID_NDK must be defined to build android targets." && BUILD_ANDROID=0

function dependencies() {
if [[ "$OSTYPE" == *linux* ]] ; then
  ## Dependencies
  sudo apt -y remove x264 libx264-dev
  sudo apt -y install build-essential checkinstall cmake pkg-config yasm
  sudo apt -y install git gfortran
  sudo apt -y install libjpeg8-dev libjasper-dev libpng12-dev
  sudo apt -y install libtiff5-dev
  sudo apt -y install libtiff-dev
  sudo apt -y install libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev
  sudo apt -y install libxine2-dev libv4l-dev
  pushd /usr/include/linux
  sudo ln -s -f ../libv4l1-videodev.h videodev.h
  popd
  sudo apt -y install libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev
  sudo apt -y install libgtk2.0-dev libtbb-dev qt5-default
  sudo apt -y install libatlas-base-dev
  sudo apt -y install libfaac-dev libmp3lame-dev libtheora-dev
  sudo apt -y install libvorbis-dev libxvidcore-dev
  sudo apt -y install libopencore-amrnb-dev libopencore-amrwb-dev
  sudo apt -y install libavresample-dev
  sudo apt -y install x264 v4l-utils

  # Optional dependencies
  sudo apt -y install libprotobuf-dev protobuf-compiler
  sudo apt -y install libgoogle-glog-dev libgflags-dev
  sudo apt -y install libgphoto2-dev libeigen3-dev libhdf5-dev doxygen

  # Python dependencies
  sudo apt -y install python3-dev python3-pip python3-venv
  sudo -H pip3 install -U pip numpy
  sudo apt -y install python3-testresources

  # Python virtual environment
  if [ ! -d OpenCV-"$OPENCV_BUILD_VERSION"-py3 ]; then
  python3 -m venv OpenCV-"$OPENCV_BUILD_VERSION"-py3
  echo "# Virtual Environment Wrapper" >> ~/.bashrc
  echo "alias enable-opencv-$OPENCV_BUILD_VERSION=\"source $PWD/OpenCV-$OPENCV_BUILD_VERSION-py3/bin/activate\"" >> ~/.bashrc
  source $PWD/OpenCV-"$OPENCV_BUILD_VERSION"-py3/bin/activate
  # install python libraries within this virtual environment
  # using mulitple passes to avoid errors
  pip install wheel numpy
  pip install scipy matplotlib scikit-image scikit-learn
  pip install ipython dlib
  # quit virtual environment
  deactivate
  fi
elif [[ "$OSTYPE" == *darwin* ]] ; then
  $(shell brew update)
fi
}

function main ()
{
  BUILD_ROOT=$OPENCV_PATH
  INSTALL_PATH=$OPENCV_PATH/install
  ENABLE_OPENCL=ON

  # number of parallel jobs
  if [ "${TRAVIS}" == "true" -a "${CI}" == "true" ] ; then
    export BUILD_NUM_CORES=1
  else
    if [[ "$OSTYPE" == *darwin* ]] ; then
      export BUILD_NUM_CORES=`sysctl -n hw.ncpu`
    elif [[ "$OSTYPE" == *linux* ]] ; then
      export BUILD_NUM_CORES=`nproc`
    else
      export BUILD_NUM_CORES=1
    fi
  fi

  pushd $BUILD_ROOT
  INSTALL_PATH=`pwd`/install
  for i in "$@"
  do
  case $i in
      clean)
      rm -rf build
      shift
      ;;
      -t=*|--targets=*)
      ANDROID_BUILD_ABIS="${i#*=}"
      shift
      ;;
      -l=*|--lib=*)
      LIBPATH="${i#*=}"
      shift
      ;;
      -i=*)
      INSTALL_PATH="${i#*=}"
      shift
      ;;
      -noCL|-nocl)
      ENABLE_OPENCL=OFF
      shift
      ;;
      -h|--help|*)
      echo "`basename $0` [clean] remake cmake files [-t=,--targets=] x64-osx,arm7-android,arm8-android [-i=] install path"
      exit 0
      ;;
  esac
  done

  echo "INSTALL_PATH=${INSTALL_PATH}"
  echo "ANDROID_BUILD_ABIS=${ANDROID_BUILD_ABIS}"
  echo "ANDROID_NDK"=${ANDROID_NDK}

  [ ! -d ${INSTALL_PATH} ] && mkdir -p ${INSTALL_PATH}
  [[ -n "${ANDROID_BUILD_ABIS}" ]] && build_platform ${ANDROID_BUILD_ABIS}
  popd
}

# valid ABIs = arm7,arm8
function build_platform ()
#$1 [build ABIs] array, e.g. "arm7-android x86_64-osx"
{
  for i in "$@"
  do
    local TARGET_ABI=${i%-*}
    local TARGET_PLATFORM=${i#*-}
    echo "Building $1"
  case $i in
    arm7-android)
#    COMMON_OPTIONS="-DCMAKE_VERBOSE_MAKEFILE=ON -DENABLE_NEON=ON -DWITH_TBB=ON -DBUILD_TBB=ON -DWITH_CUDA=OFF\
    COMMON_OPTIONS="-DENABLE_NEON=ON -DWITH_TBB=ON -DBUILD_TBB=ON -DWITH_CUDA=OFF\
     -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DENABLE_PRECOMPILED_HEADERS=OFF -DBUILD_ANDROID_EXAMPLES=OFF\
     -DINSTALL_ANDROID_EXAMPLES=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_DOCS=OFF\
     -DANDROID_NATIVE_API_LEVEL=21 -DANDROID_SDK_TARGET=21 -DNDK_CCACHE=ccache -DANDROID_STL=c++_shared\
     -DWITH_WEBP=OFF -DOPENCV_EXTRA_MODULES_PATH=${BUILD_ROOT}/../opencv_contrib/modules\
     -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake -DANDROID_TOOLCHAIN=clang"
#     -DCMAKE_CXX_FLAGS_DEBUG=-fdebug-prefix-map=${HOME}=~\
#     -DCMAKE_C_FLAGS_DEBUG=-fdebug-prefix-map=${HOME}=~"
    EXTRA_OPTIONS="-DWITH_OPENCL=${ENABLE_OPENCL}"
    build_target "build/android/debug/arm7" Debug $TARGET_ABI $TARGET_PLATFORM
    build_target "build/android/release/arm7" Release $TARGET_ABI $TARGET_PLATFORM
    shift
    ;;
    arm8-android)
    COMMON_OPTIONS="-DENABLE_NEON=ON -DWITH_TBB=ON -DBUILD_TBB=ON -DWITH_CUDA=OFF\
     -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DENABLE_PRECOMPILED_HEADERS=OFF -DBUILD_ANDROID_EXAMPLES=OFF\
     -DINSTALL_ANDROID_EXAMPLES=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_DOCS=OFF\
     -DANDROID_NATIVE_API_LEVEL=21 -DANDROID_SDK_TARGET=21 -DNDK_CCACHE=ccache -DANDROID_STL=c++_shared\
     -DWITH_WEBP=OFF -DOPENCV_EXTRA_MODULES_PATH=${BUILD_ROOT}/../opencv_contrib/modules\
     -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake -DANDROID_TOOLCHAIN=clang"
#     -DCMAKE_CXX_FLAGS_DEBUG=-fdebug-prefix-map=${HOME}=~\
#     -DCMAKE_C_FLAGS_DEBUG=-fdebug-prefix-map=${HOME}=~"
    EXTRA_OPTIONS="-DWITH_OPENCL=${ENABLE_OPENCL}"
    build_target "build/android/debug/arm8" Debug $TARGET_ABI $TARGET_PLATFORM
    build_target "build/android/release/arm8" Release $TARGET_ABI $TARGET_PLATFORM
    shift
    ;;
    x64-osx)
    cmake -DWITH_TBB=ON -DWITH_QT=ON -DWITH_OPENGL=ON -DWITH_CUDA=ON -DWITH_OPENCL=OFF -DENABLE_PRECOMPILED_HEADERS=OFF -DQt5_DIR=$(brew --prefix qt5)/lib/cmake/Qt5 ..
    #-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON
    COMMON_OPTIONS="-DWITH_QT=ON -DWITH_TBB=ON -DWITH_CUDA=OFF \
     -DWITH_OPENGL=ON -DWITH_OPENCL=OFF -DENABLE_PRECOMPILED_HEADERS=OFF \
     -DOPENCV_EXTRA_MODULES_PATH=${BUILD_ROOT}/../opencv_contrib/modules \
     -DQt5_DIR=$(brew --prefix qt5)/lib/cmake/Qt5 \
     -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_DOCS=OFF"
    EXTRA_OPTIONS=""
    build_target "build/osx/debug/x64/opencv" Debug $TARGET_ABI $TARGET_PLATFORM
    build_target "build/osx/release/x64/opencv" Release $TARGET_ABI $TARGET_PLATFORM
    shift
    ;;
  esac
  done
}

function build_target ()
# $1 = target cmake directory
# $2 = cmake build type
# $3 = target ABI
# $4 = target platform
{
  local TARGET_DIR=${1}
  local TARGET_CMAKE_TYPE=${2}
  local TARGET_ABI=${3}
  local TARGET_PLATFORM=${4}
  local REBUILD_CMAKE=
  [ "$TARGET_ABI" == "arm7" ] && TARGET_ABI="armeabi-v7a with NEON"
  [ "$TARGET_ABI" == "arm8" ] && TARGET_ABI="arm64-v8a"
  [ "$TARGET_PLATFORM" == "osx" ] && TARGET_ABI="x86_64"
  [ ! -d "$TARGET_DIR" ] && mkdir -p "$TARGET_DIR" && REBUILD_CMAKE=true
  pushd "$TARGET_DIR"
  if [ -n "$REBUILD_CMAKE" ] ; then
    cmake '-GUnix Makefiles' -DCMAKE_BUILD_TYPE=$2 -DANDROID_ABI="$TARGET_ABI" $EXTRA_OPTIONS $COMMON_OPTIONS ${BUILD_ROOT}
  fi
  make -j${BUILD_NUM_CORES}
  #cmake -DCOMPONENT=libs -P cmake_install.cmake
  #cmake -DCOMPONENT=dev -P cmake_install.cmake
  #cmake -DCOMPONENT=java -P cmake_install.cmake
  #cmake -DCOMPONENT=samples -P cmake_install.cmake
  if [ "$2" == "Debug" ] ; then
    make install
  else
    make install/strip
  fi
  install_library ${INSTALL_PATH} $2 ${TARGET_PLATFORM}
  popd
}

function install_library ()
# $1 install path
# $2 debug or release
# $3 platform = "android" or "osx"
{
  set +e
  pwd
  INSTALL_ALL=$1
  if [[ "$2" == "Debug" ]] ; then
    BUILD_TYPE_EXT=debug
    INSTALL_DIR=$1"."$3".debug"
  else
    BUILD_TYPE_EXT=release
    INSTALL_DIR=$1"."$3".release"
  fi
  [ ! -d ${INSTALL_DIR} ] && mkdir -p ${INSTALL_DIR}
  #[ -d install/sdk/native/libs/armeabi-v7a ] && rm -rf install/sdk/native/libs/armeabi-v7a
  #[ -d install/sdk/native/libs/armeabi-v7a-hard ] && mv install/sdk/native/libs/armeabi-v7a-hard install/sdk/native/libs/armeabi-v7a
  #[ -d install/sdk/native/3rdparty/libs/armeabi-v7a ] && rm -rf install/sdk/native/3rdparty/libs/armeabi-v7a
  #[ -d install/sdk/native/3rdparty/libs/armeabi-v7a-hard ] && mv install/sdk/native/3rdparty/libs/armeabi-v7a-hard install/sdk/native/3rdparty/libs/armeabi-v7a

  # scrub all .a library files
  find ${INSTALL_DIR}* -name *.a | xargs -n 1 -t rm

  cp -av $BUILD_ROOT/platforms/android/template/opencv-lib/* ${INSTALL_DIR}
  cp -av android_sdk/bin/aidl ${INSTALL_DIR}/src/main
  cp -av bin/AndroidManifest.xml ${INSTALL_DIR}/src/main

  # jnilibs, java, jni
  mkdir -p ${INSTALL_DIR}/src/main/jnilibs
  cp -av install/sdk/native/libs/ ${INSTALL_DIR}/src/main/jnilibs
  cp -av install/sdk/native/jni/include ${INSTALL_DIR}/src/main/jni
  cp -av install/sdk/java/src/ ${INSTALL_DIR}/src/main/java
  cp -av install/sdk/java/res ${INSTALL_DIR}/src/main
  cp -av install/sdk/java/AndroidManifest.xml ${INSTALL_DIR}/src/main
  set -e
}

main "$@"
