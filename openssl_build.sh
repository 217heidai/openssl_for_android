#!/bin/bash -e

################################################################################
#   Copyright 2021-2025 217heidai<217heidai@gmail.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
################################################################################

################################################################################
#   build OpenSSL for Android armeabi mips mips64
#   support Linux and macOS
################################################################################


WORK_PATH=$(cd "$(dirname "$0")";pwd)

ANDROID_TARGET_API=$1
ANDROID_TARGET_ABI=$2
OPENSSL_VERSION=$3
ANDROID_NDK_VERSION=$4
ANDROID_NDK_PATH=${WORK_PATH}/android-ndk-${ANDROID_NDK_VERSION}
OPENSSL_PATH=${WORK_PATH}/openssl-${OPENSSL_VERSION}
OUTPUT_PATH=${WORK_PATH}/openssl_${OPENSSL_VERSION}_${ANDROID_TARGET_ABI}
OPENSSL_OPTIONS="no-apps no-asm no-docs no-engine no-gost no-legacy no-shared no-ssl no-tests no-zlib"


function build(){
    mkdir ${OUTPUT_PATH}

    cd ${OPENSSL_PATH}

    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    export CXXFLAGS="-fPIC -Os"
    export CPPFLAGS="-DANDROID -fPIC -Os"

    if   [ "${ANDROID_TARGET_ABI}" == "armeabi" ]; then
        if [ "$(uname)"=="Darwin" ]; then
            PATH=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin:${ANDROID_NDK_HOME}/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin:$PATH
        else
            PATH=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin:${ANDROID_NDK_HOME}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
        fi
        ./Configure android-arm    -D__ANDROID_API__=${ANDROID_TARGET_API} -static ${OPENSSL_OPTIONS} --prefix=${OPENSSL_OUTPUT}
    elif [ "${ANDROID_TARGET_ABI}" == "mips"   ]; then
        if [ "$(uname)"=="Darwin" ]; then
            PATH=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin:${ANDROID_NDK_HOME}/toolchains/mipsel-linux-android-4.9/prebuilt/darwin-x86_64/bin:$PATH
        else
            PATH=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin:${ANDROID_NDK_HOME}/toolchains/mipsel-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
        fi
        ./Configure android-mips   -D__ANDROID_API__=${ANDROID_TARGET_API} -static ${OPENSSL_OPTIONS} --prefix=${OPENSSL_OUTPUT}
    elif [ "${ANDROID_TARGET_ABI}" == "mips64" ]; then
        if [ "$(uname)"=="Darwin" ]; then
            PATH=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin:${ANDROID_NDK_HOME}/toolchains/mips64el-linux-android-4.9/prebuilt/darwin-x86_64/bin:$PATH
        else
            PATH=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin:${ANDROID_NDK_HOME}/toolchains/mips64el-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
        fi
        ./Configure android-mips64 -D__ANDROID_API__=${ANDROID_TARGET_API} -static ${OPENSSL_OPTIONS} --prefix=${OPENSSL_OUTPUT}
    else
        echo "Unsupported target ABI: ${ANDROID_TARGET_ABI}"
        exit 1
    fi

    if [ "$(uname)"=="Darwin" ]; then
        make -j$(sysctl -n hw.logicalcpu)
    else
        make -j$(nproc)
    fi
    make install

    echo "Build completed! Check output libraries in ${OUTPUT_PATH}"
}

function clean(){
    if [ -d ${OUTPUT_PATH} ]; then
        rm -rf ${OUTPUT_PATH}/bin
        rm -rf ${OUTPUT_PATH}/share
        rm -rf ${OUTPUT_PATH}/ssl
        rm -rf ${OUTPUT_PATH}/lib/cmake
        rm -rf ${OUTPUT_PATH}/lib/engines-3
        rm -rf ${OUTPUT_PATH}/lib/ossl-modules
        rm -rf ${OUTPUT_PATH}/lib/pkgconfig
    fi
}

build
clean
