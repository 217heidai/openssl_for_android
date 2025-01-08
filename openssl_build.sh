#!/bin/bash

# identify which openssl version we require
OPENSSL_VERSION="${OPENSSL_VERSION:-3.2.1}"

# ABr: modifications
WORK_PATH=$(cd "$(dirname "$0")";pwd)
ANDROID_NDK_PATH=''
OPENSSL_SOURCES_PATH=${WORK_PATH}/openssl-$OPENSSL_VERSION
ANDROID_TARGET_API=$1
ANDROID_TARGET_ABI=$2
OUTPUT_PATH=${WORK_PATH}/openssl_${OPENSSL_VERSION}_${ANDROID_TARGET_ABI}

# ABr: caller may pass in target ABI and API
ANDROID_TARGET_ABI="${1:-arm64-v8a}" ; shift
ANDROID_TARGET_API="${1:-default}" ; shift

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
  local l_rc=0

  echo "mkdir -p '${OUTPUT_PATH}'"
  mkdir -p "${OUTPUT_PATH}"

  echo "make && make install"
  make && make install
  l_rc=$? ; [ $l_rc -ne 0 ] && return $l_rc

  echo 'Cleaning up build...'
  rm -rf ${OPENSSL_TMP_FOLDER}
  rm -rf ${OUTPUT_PATH}/bin
  rm -rf ${OUTPUT_PATH}/share
  rm -rf ${OUTPUT_PATH}/ssl
  rm -rf ${OUTPUT_PATH}/lib/engines*
  rm -rf ${OUTPUT_PATH}/lib/pkgconfig
  rm -rf ${OUTPUT_PATH}/lib/ossl-modules
  echo ''

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

echo "Using ANDROID_NDK_ROOT='$ANDROID_NDK_ROOT'..."
echo "Using PATH='$PATH'..."
echo ''

# the remainder is the same for all :)
echo "cd '${OPENSSL_TMP_FOLDER}'"
cd "${OPENSSL_TMP_FOLDER}"
echo ''

# by default __ANDROID_API__ is defined and we get warnings if we redefine
the_tmp="/tmp/openssl_build_$$.sh"
echo "#!$SHELL" >"$the_tmp"
# ABr: solve "relocation R_AARCH64_ADR_PREL_PG_HI21 cannot be used against symbol 'bio_type_lock'; recompile with -fPIC"
echo 'export CFLAGS=-fPIC' >>"$the_tmp"
echo "./Configure $openssl_platform \\" >>"$the_tmp"
if [ x"$ANDROID_TARGET_API" != xdefault ] ; then
  # see https://github.com/openssl/openssl/issues/18561#issuecomment-1155298077
  echo "  -U__ANDROID_API__ -D__ANDROID_API__=${ANDROID_TARGET_API} \\" >>"$the_tmp"
fi
echo "  -static no-asm no-shared no-tests --prefix='${OUTPUT_PATH}'" >>"$the_tmp"
echo 'Running configure...'
chmod +x "$the_tmp"
cat "$the_tmp"
"$the_tmp"
the_rc=$?
rm -f "$the_tmp"
[ $the_rc -ne 0 ] && exit $the_rc
echo ''

build_library
exit $?

