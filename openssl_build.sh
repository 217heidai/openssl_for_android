#!/bin/bash

# modified by ABr

# identify which openssl version we require
OPENSSL_VERSION=3.1.3

# caller may pass in target API and ABI
ANDROID_TARGET_API="${1:-30}" ; shift
ANDROID_TARGET_ABI="${1:-arm64-v8a}" ; shift

# special surprise: if ANDROID_TARGET_API is 'clean' then clean up...
if [ x"$ANDROID_TARGET_API" = xclean ] ; then
  echo 'Cleaning project...'
  rm -fR ./openssl-* /tmp/openssl-*
  exit $?
fi

# caller must set ANDROID_NDK_HOME
[ x"$ANDROID_NDK_HOME" = x ] && echo 'Must set ANDROID_NDK_HOME' && exit 1

# caller may set ANDROID_NDK_LOCAL_PLATFORM or use computed default
unameOut="`uname -s | dos2unix`"
case "${unameOut}" in
  Linux*)     machine=linux;;
  Darwin*)    machine=mac;;
  CYGWIN*)    machine=cygwin;;
  MINGW*)     machine=mingw;;
  *)          machine="UNKNOWN:${unameOut}"
esac
if [ x"$ANDROID_NDK_LOCAL_PLATFORM" = x ] ; then
  if [ x"$machine" = xmac ] ; then
    # apple silicon or intel?
    ANDROID_NDK_LOCAL_PLATFORM=darwin-`uname -m`
  elif [ x"$machine" = xlinux ] ; then
    ANDROID_NDK_LOCAL_PLATFORM=linux-`uname -m`
  fi
fi
[ x"$ANDROID_NDK_LOCAL_PLATFORM" = x ] && echo 'Must set ANDROID_NDK_LOCAL_PLATFORM' && exit 1

# we must have platform bin folder for NDK build to work
required_ndk_bin_folder="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$ANDROID_NDK_LOCAL_PLATFORM"
[ ! -d "$required_ndk_bin_folder" ] && echo "Cannot locate required NDK '$required_ndk_bin_folder'" && exit 1

function pull_openssl {
  # copy from web
  if [ ! -f "${WORK_PATH}/openssl-${OPENSSL_VERSION}.tar.gz" ]; then
    echo "Pull down 'https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz'..." 
    rm -fR "$OPENSSL_SOURCES_PATH"
    curl -fL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" -o "${WORK_PATH}/openssl-${OPENSSL_VERSION}.tar.gz"
    curl -fL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.sha256" -o "${WORK_PATH}/openssl-${OPENSSL_VERSION}.tar.gz.sha256"
    DIGEST=$( cat ${WORK_PATH}/openssl-${OPENSSL_VERSION}.tar.gz.sha256 )

    if [[ "$(shasum -a 256 "openssl-${OPENSSL_VERSION}.tar.gz" | awk '{ print " "$1}')" != "${DIGEST}" ]]
    then
      echo "openssl-${OPENSSL_VERSION}.tar.gz: checksum mismatch"
      exit 1
    fi
    rm -f "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256"
  fi

  # update
  if [ ! -d "$OPENSSL_SOURCES_PATH" ] ; then
    echo "Extract into '$OPENSSL_SOURCES_PATH'..."
    tar xzf "${WORK_PATH}/openssl-${OPENSSL_VERSION}.tar.gz" || exit $?
    rm -fR "$OPENSSL_TMP_FOLDER"
  fi
  return 0
}

function build_library {
  mkdir -p ${OUTPUT_PATH}
  make && make install
  rm -rf ${OPENSSL_TMP_FOLDER}
  rm -rf ${OUTPUT_PATH}/bin
  rm -rf ${OUTPUT_PATH}/share
  rm -rf ${OUTPUT_PATH}/ssl
  rm -rf ${OUTPUT_PATH}/lib/engines*
  rm -rf ${OUTPUT_PATH}/lib/pkgconfig
  rm -rf ${OUTPUT_PATH}/lib/ossl-modules
  echo "Build completed! Check output libraries in ${OUTPUT_PATH}"
}

# derived variables
WORK_PATH=$(cd "$(dirname "$0")";pwd)
ANDROID_NDK_PATH="$ANDROID_NDK_HOME"
OPENSSL_SOURCES_PATH=${WORK_PATH}/openssl-$OPENSSL_VERSION
OUTPUT_PATH=${WORK_PATH}/openssl-$OPENSSL_VERSION_${ANDROID_TARGET_ABI}
OPENSSL_TMP_FOLDER=/tmp/openssl-${ANDROID_TARGET_ABI}

pull_openssl || exit $?

mkdir -p ${OPENSSL_TMP_FOLDER}
echo "rsync -av '${OPENSSL_SOURCES_PATH}/' '${OPENSSL_TMP_FOLDER}'"
rsync -av "${OPENSSL_SOURCES_PATH}/" "${OPENSSL_TMP_FOLDER}"

# PATH is set the same for all build variants
export ANDROID_NDK_ROOT="${ANDROID_NDK_PATH}"
PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$ANDROID_NDK_LOCAL_PLATFORM/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/$ANDROID_NDK_LOCAL_PLATFORM/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/$ANDROID_NDK_LOCAL_PLATFORM/bin:$PATH"

# map the platform identifier from Android to OpenSSL (e.g. arm64-v8a -> android-arm64)
case "$ANDROID_TARGET_ABI" in
  armeabi-v7a) openssl_platform='android-arm';;
  arm64-v8a) openssl_platform='android-arm64';;
  x86) openssl_platform='android-x86';;
  x86_64) openssl_platform='android-x86_64';;
  *) echo "Unsupported ANDROID_TARGET_ABI '$ANDROID_TARGET_ABI'" ; exit 1;;
esac

# the remainder is the same for all :)
cd ${OPENSSL_TMP_FOLDER}
./Configure $openssl_platform -D__ANDROID_API__=${ANDROID_TARGET_API} -static no-asm no-shared no-tests --prefix=${OUTPUT_PATH}
build_library
exit $?

if [ "$ANDROID_TARGET_ABI" == "armeabi-v7a" ]
then
    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-arm -D__ANDROID_API__=${ANDROID_TARGET_API} -static no-asm no-shared no-tests --prefix=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "arm64-v8a" ]
then
    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-arm64 -D__ANDROID_API__=${ANDROID_TARGET_API} -static no-asm no-shared no-tests --prefix=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "x86" ]
then
    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-x86 -D__ANDROID_API__=${ANDROID_TARGET_API} -static no-asm no-shared no-tests --prefix=${OUTPUT_PATH}
    build_library

elif [ "$ANDROID_TARGET_ABI" == "x86_64" ]
then
    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-x86_64 -D__ANDROID_API__=${ANDROID_TARGET_API} -static no-asm no-shared no-tests --prefix=${OUTPUT_PATH}
    build_library

else
    echo "Unsupported target ABI: $ANDROID_TARGET_ABI"
    exit 1
fi
