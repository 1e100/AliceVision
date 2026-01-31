#!/usr/bin/env bash

set -euo pipefail

# Prefer MKL for BLAS/LAPACK; try common package names.
mkl_pkgs=(intel-oneapi-mkl-dev intel-oneapi-mkl libmkl-dev intel-mkl)
mkl_installed=0
for pkg in "${mkl_pkgs[@]}"; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    mkl_installed=1
    break
  fi
done

missing_pkgs=()
for pkg in \
  libopencv-dev \
  libpcre2-dev \
  ffmpeg \
  libavcodec-dev \
  libavformat-dev \
  libavutil-dev \
  libswscale-dev \
  bison \
  gfortran \
  libexpat1-dev \
  libopenimageio-dev \
  openimageio-tools \
  libboost-atomic-dev \
  libboost-container-dev \
  libboost-date-time-dev \
  libboost-graph-dev \
  libboost-json-dev \
  libboost-log-dev \
  libboost-math-dev \
  libboost-program-options-dev \
  libboost-regex-dev \
  libboost-serialization-dev \
  libboost-stacktrace-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libboost-timer-dev \
  libboost-test-dev \
  libtiff-dev \
  libpng-dev \
  libgmp-dev \
  libflann-dev; do
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    missing_pkgs+=("$pkg")
  fi
done

if ((${#missing_pkgs[@]})); then
  sudo apt-get update
  sudo apt-get install -y "${missing_pkgs[@]}"
fi

if [[ $mkl_installed -eq 0 ]]; then
  sudo apt-get update
  # Try to install the preferred MKL package(s) if available.
  if ! sudo apt-get install -y intel-oneapi-mkl-dev; then
    if ! sudo apt-get install -y libmkl-dev; then
      echo "Intel MKL not found. Install intel-oneapi-mkl-dev (preferred) or libmkl-dev, then re-run." >&2
      exit 1
    fi
  fi
fi

MKL_LIB=$(ldconfig -p 2>/dev/null | grep -m1 "libmkl_rt.so" | awk '{print $NF}' || true)
if [[ -z "${MKL_LIB}" ]]; then
  echo "Could not locate libmkl_rt.so via ldconfig. Ensure MKL is installed and configured." >&2
  exit 1
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
  -DAV_BUILD_TIFF=OFF \
  -DAV_BUILD_PNG=OFF \
  -DAV_BUILD_JPEG=OFF \
  -DAV_BUILD_ZLIB=OFF \
  -DAV_BUILD_BOOST=OFF \
  -DAV_BUILD_EXPAT=OFF \
  -DAV_BUILD_OPENEXR=OFF \
  -DAV_BUILD_OPENIMAGEIO=OFF \
  -DAV_BUILD_EIGEN=OFF \
  -DAV_BUILD_TBB=OFF \
  -DOpenCV_DIR=/usr/lib/x86_64-linux-gnu/cmake/opencv4 \
  -DAV_BUILD_FFMPEG=OFF \
  -DFFMPEG_ROOT=/usr \
  -DAV_BUILD_SWIG=OFF \
  -DAV_USE_SWIG=ON \
  -DAV_BUILD_E57FORMAT=ON \
  -DAV_BUILD_LAPACK=OFF \
  -DAV_BUILD_SUITESPARSE=ON \
  -DAV_BUILD_CERES=ON \
  -DBLAS_LIBRARIES="${MKL_LIB}" \
  -DLAPACK_LIBRARIES="${MKL_LIB}" \
  -DCMAKE_PREFIX_PATH=/usr \
  -DBOOST_ROOT=/usr

cmake --build build -j 2>&1 | tee /tmp/av-build.log
