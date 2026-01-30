#!/usr/bin/env bash

set -euo pipefail

missing_pkgs=()
for pkg in libopencv-dev libpcre2-dev ffmpeg bison; do
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    missing_pkgs+=("$pkg")
  fi
done

if ((${#missing_pkgs[@]})); then
  sudo apt-get update
  sudo apt-get install -y "${missing_pkgs[@]}"
fi

rm -rf build

export CUDA_HOME=/usr/local/cuda-13
export CC=/usr/bin/gcc-12
export CXX=/usr/bin/g++-12
export CUDAHOSTCXX=/usr/bin/g++-12

# 3090/A6000 = sm_86; 5090 = sm_120 (PTX generated for highest CC by CMake)
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PWD/build/install" \
  -DALICEVISION_BUILD_DEPENDENCIES=ON \
  -DAV_USE_CUDA=ON \
  -DALICEVISION_CUDA_CC_LIST="86;120" \
  -DAV_BUILD_OPENCV=OFF \
  -DALICEVISION_USE_OPENCV=ON \
  -DOpenCV_DIR=/usr/lib/x86_64-linux-gnu/cmake/opencv4 \
  -DAV_BUILD_FFMPEG=OFF \
  -DFFMPEG_ROOT=/usr \
  -DAV_BUILD_SWIG=ON \
  -DAV_BUILD_E57FORMAT=ON \
  -DAV_BUILD_LAPACK=OFF \
  -DBLAS_LIBRARIES=/usr/lib/x86_64-linux-gnu/libblas.so \
  -DLAPACK_LIBRARIES=/usr/lib/x86_64-linux-gnu/liblapack.so

cmake --build build -j 2>&1 | tee /tmp/av-build.log
