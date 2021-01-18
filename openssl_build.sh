#!/bin/bash -e

WORK_PATH=/home/runner/work/openssl_for_android/openssl_for_android
ANDROID_NDK_PATH=${WORK_PATH}/android-ndk-r14b
OPENSSL_SOURCES_PATH=${WORK_PATH}/openssl-OpenSSL_1_1_1i
ANDROID_TARGET_API=$1
ANDROID_TARGET_ABI=$2
OUTPUT_PATH=${WORK_PATH}/openssl_${ANDROID_TARGET_ABI}_1.1.1i

OPENSSL_TMP_FOLDER="/tmp/openssl"
rm -rf ${OPENSSL_TMP_FOLDER}
mkdir -p ${OPENSSL_TMP_FOLDER}
cp -r ${OPENSSL_SOURCES_PATH}/* ${OPENSSL_TMP_FOLDER}

function build_library {
    rm -rf ${OUTPUT_PATH}
    mkdir -p ${OUTPUT_PATH}
    make && make install
    rm -rf ${OPENSSL_TMP_FOLDER}
    rm -rf ${OUTPUT_PATH}/bin
    rm -rf ${OUTPUT_PATH}/share
    rm -rf ${OUTPUT_PATH}/ssl
    rm -rf ${OUTPUT_PATH}/lib/engines*
    rm -rf ${OUTPUT_PATH}/lib/pkgconfig
    echo "Build completed! Check output libraries in ${OUTPUT_PATH}"
}

if [ "$ANDROID_TARGET_ABI" == "armeabi" ]
then
    export ANDROID_NDK_HOME=${ANDROID_NDK_PATH}
    PATH=$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-arm -DANDROID_API=${ANDROID_TARGET_API} no-shared no-tests --prefix=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "armeabi-v7a" ]
then
    export ANDROID_NDK_HOME=${ANDROID_NDK_PATH}
    PATH=$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-arm -DANDROID_API=${ANDROID_TARGET_API} no-shared no-tests --prefix=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "arm64-v8a" ]
then
    export ANDROID_NDK_HOME=${ANDROID_NDK_PATH}
    PATH=$ANDROID_NDK_HOME/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-arm64 -DANDROID_API=${ANDROID_TARGET_API} no-shared no-tests --prefix=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "mips" ]
then
    export ANDROID_NDK_HOME=${ANDROID_NDK_PATH}
    PATH=$ANDROID_NDK_HOME/toolchains/mipsel-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-mips -DANDROID_API=${ANDROID_TARGET_API} no-shared no-tests --prefix=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "mips64" ]
then
    export ANDROID_NDK_HOME=${ANDROID_NDK_PATH}
    PATH=$ANDROID_NDK_HOME/toolchains/mips64el-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-mips64 -DANDROID_API=${ANDROID_TARGET_API} no-shared no-tests --prefix=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "x86" ]
then
    export ANDROID_NDK_HOME=${ANDROID_NDK_PATH}
    PATH=$ANDROID_NDK_HOME/toolchains/x86-4.9/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-x86 -DANDROID_API=${ANDROID_TARGET_API} no-shared no-tests --prefix=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "x86_64" ]
then
    export ANDROID_NDK_HOME=${ANDROID_NDK_PATH}
    PATH=$ANDROID_NDK_HOME/toolchains/x86_64-4.9/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-x86_64 -DANDROID_API=${ANDROID_TARGET_API} no-shared no-tests --prefix=${OUTPUT_PATH}
    build_library

else
    echo "Unsupported target ABI: $ANDROID_TARGET_ABI"
    exit 1
fi
