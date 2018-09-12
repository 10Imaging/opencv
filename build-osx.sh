[ -d build/osx ] && rm -rf build/osx
mkdir -p build/osx && cd build/osx
cmake -D CMAKE_INSTALL_PREFIX=/usr/local/opt/opencv3d \
  -D BUILD_EXAMPLES=ON \
  -D CMAKE_BUILD_TYPE=Debug \
  ../..

make -j`sysctl -n hw.ncpu`