#!/bin/bash -e

################################################################################
#   Copyright 2021-2025 nepmods
#   Licensed under the Apache License, Version 2.0
################################################################################

# Build cURL for Android ABIs: armeabi-v7a, arm64-v8a, x86, x86_64, riscv64

WORK_PATH=$(cd "$(dirname "$0")";pwd)

ANDROID_TARGET_API=$1
ANDROID_TARGET_ABI=$2
CURL_VERSION=$3
ANDROID_NDK_VERSION=$4
ANDROID_NDK_PATH=${WORK_PATH}/android-ndk-${ANDROID_NDK_VERSION}
CURL_PATH=${WORK_PATH}/curl-${CURL_VERSION}
OUTPUT_PATH=${WORK_PATH}/curl_${CURL_VERSION}_${ANDROID_TARGET_ABI}

OPENSSL_VERSION=3.5.0
OPENSSL_SYSROOT=${WORK_PATH}/openssl_${OPENSSL_VERSION}_${ANDROID_TARGET_ABI}

if [ "$(uname -s)" == "Darwin" ]; then
    echo "Build on macOS..."
    PLATFORM="darwin"
    export alias nproc="sysctl -n hw.logicalcpu"
else
    echo "Build on Linux..."
    PLATFORM="linux"
fi

function build() {
    mkdir -p ${OUTPUT_PATH}
    cd ${CURL_PATH}
    ./buildconf || true

    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    TOOLCHAIN=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${PLATFORM}-x86_64

    case "${ANDROID_TARGET_ABI}" in
        armeabi-v7a)
            TARGET_HOST="armv7a-linux-androideabi"
            ARCH="arm"
            ;;
        arm64-v8a)
            TARGET_HOST="aarch64-linux-android"
            ARCH="arm64"
            ;;
        x86)
            TARGET_HOST="i686-linux-android"
            ARCH="x86"
            ;;
        x86_64)
            TARGET_HOST="x86_64-linux-android"
            ARCH="x86_64"
            ;;
        riscv64)
            TARGET_HOST="riscv64-linux-android"
            ARCH="riscv64"
            ;;
        *)
            echo "Unsupported ABI: ${ANDROID_TARGET_ABI}"
            exit 1
            ;;
    esac

    export CC=${TOOLCHAIN}/bin/${TARGET_HOST}${ANDROID_TARGET_API}-clang
    export AR=${TOOLCHAIN}/bin/llvm-ar
    export AS=${TOOLCHAIN}/bin/llvm-as
    export LD=${TOOLCHAIN}/bin/ld
    export RANLIB=${TOOLCHAIN}/bin/llvm-ranlib
    export STRIP=${TOOLCHAIN}/bin/llvm-strip
    export CFLAGS="-fPIE -fPIC -O2 --sysroot=${TOOLCHAIN}/sysroot"
    export LDFLAGS="-pie"
    export PKG_CONFIG_PATH=${OPENSSL_SYSROOT}/lib/pkgconfig

    ./configure \
      --host=armv7a-linux-androideabi \
      --disable-shared \
      --enable-static \
      --without-ssl \
      --disable-ldap \
      --prefix=$PWD/install


    make -j$(nproc)
    make install

    echo "Build completed! Output: ${OUTPUT_PATH}"
}

function clean() {
    if [ -d ${OUTPUT_PATH} ]; then
        rm -rf ${OUTPUT_PATH}/bin
        rm -rf ${OUTPUT_PATH}/share
        rm -rf ${OUTPUT_PATH}/lib/pkgconfig
    fi
}

build
clean
