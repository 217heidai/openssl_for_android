#!/bin/bash -e

ANDROID_NDK_PATH=$HOME/Android/env/android-ndk-r17b
OPENSSL_SOURCES_PATH=$HOME/work/SSL/Android/openssl-1.0.2q
ANDROID_TARGET_API=$1
ANDROID_TARGET_ABI=$2
GCC_VERSION=$3
OUTPUT_PATH=$4

NDK_MAKE_TOOLCHAIN="$ANDROID_NDK_PATH/build/tools/make-standalone-toolchain.sh"
OPENSSL_TMP_FOLDER="/tmp/openssl"
rm -rf "$OPENSSL_TMP_FOLDER"
mkdir -p "$OPENSSL_TMP_FOLDER"
cp -r ${OPENSSL_SOURCES_PATH}/* ${OPENSSL_TMP_FOLDER}

function build_library {
    mkdir -p ${OUTPUT_PATH}
    export PATH=$TOOLCHAIN_PATH:$PATH
    make && make install
    rm -rf ${OPENSSL_TMP_FOLDER}
    echo "Build completed! Check output libraries in ${OUTPUT_PATH}"
}

if [ "$ANDROID_TARGET_ABI" == "armeabi-v7a" ]
then
    ${NDK_MAKE_TOOLCHAIN} --platform=android-${ANDROID_TARGET_API} \
                          --toolchain=arm-linux-androideabi-${GCC_VERSION} \
                          --install-dir="${OPENSSL_TMP_FOLDER}/android-toolchain-arm"
    export TOOLCHAIN_PATH="${OPENSSL_TMP_FOLDER}/android-toolchain-arm/bin"
    export TOOL=arm-linux-androideabi
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export ARCH_FLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
    export ARCH_LINK="-march=armv7-a -Wl,--fix-cortex-a8"
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-armv7 --openssldir=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "arm64-v8a" ]
then
    ${NDK_MAKE_TOOLCHAIN} --platform=android-${ANDROID_TARGET_API} \
                          --toolchain=aarch64-linux-android-${GCC_VERSION} \
                          --install-dir="${OPENSSL_TMP_FOLDER}/android-toolchain-arm64"
    export TOOLCHAIN_PATH="${OPENSSL_TMP_FOLDER}/android-toolchain-arm64/bin"
    export TOOL=aarch64-linux-android
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export ARCH_FLAGS=
    export ARCH_LINK=
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android --openssldir=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "armeabi" ]
then
    ${NDK_MAKE_TOOLCHAIN} --platform=android-${ANDROID_TARGET_API} \
                          --toolchain=arm-linux-androideabi-${GCC_VERSION} \
                          --install-dir="${OPENSSL_TMP_FOLDER}/android-toolchain-arm"
    export TOOLCHAIN_PATH="${OPENSSL_TMP_FOLDER}/android-toolchain-arm/bin"
    export TOOL=arm-linux-androideabi
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export ARCH_FLAGS="-mthumb"
    export ARCH_LINK=
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android --openssldir=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "x86" ]
then
    ${NDK_MAKE_TOOLCHAIN} --platform=android-${ANDROID_TARGET_API} \
                          --toolchain=x86-${GCC_VERSION} \
                          --install-dir="${OPENSSL_TMP_FOLDER}/android-toolchain-x86"
    export TOOLCHAIN_PATH="${OPENSSL_TMP_FOLDER}/android-toolchain-x86/bin"
    export TOOL=i686-linux-android
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export ARCH_FLAGS="-march=i686 -msse3 -mstackrealign -mfpmath=sse"
    export ARCH_LINK=
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-x86 --openssldir=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "x86_64" ]
then
    ${NDK_MAKE_TOOLCHAIN} --platform=android-${ANDROID_TARGET_API} \
                          --toolchain=x86_64-${GCC_VERSION} \
                          --install-dir="${OPENSSL_TMP_FOLDER}/android-toolchain-x86_64"
    export TOOLCHAIN_PATH="${OPENSSL_TMP_FOLDER}/android-toolchain-x86_64/bin"
    export TOOL=x86_64-linux-android
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure linux-x86_64 --openssldir=${OUTPUT_PATH}
    build_library
elif [ "$ANDROID_TARGET_ABI" == "mips" ]
then
    ${NDK_MAKE_TOOLCHAIN} --platform=android-${ANDROID_TARGET_API} \
                          --toolchain=mipsel-linux-android-${GCC_VERSION} \
                          --install-dir="${OPENSSL_TMP_FOLDER}/android-toolchain-mipsel"

    export TOOLCHAIN_PATH="${OPENSSL_TMP_FOLDER}/android-toolchain-mipsel/bin"
    export TOOL=mipsel-linux-android
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export ARCH_FLAGS=
    export ARCH_LINK=
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-mips --openssldir=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "mips64" ]
then
    ${NDK_MAKE_TOOLCHAIN} --platform=android-${ANDROID_TARGET_API} \
                          --toolchain=mips64el-linux-android-${GCC_VERSION} \
                          --install-dir="${OPENSSL_TMP_FOLDER}/android-toolchain-mips64el"

    export TOOLCHAIN_PATH="${OPENSSL_TMP_FOLDER}/android-toolchain-mips64el/bin"
    export TOOL=mips64el-linux-android
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export ARCH_FLAGS=
    export ARCH_LINK=
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-mips64 --openssldir=${OUTPUT_PATH}
    build_library

else
    echo "Unsupported target ABI: $ANDROID_TARGET_ABI"
    exit 1
fi
