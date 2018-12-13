#!/bin/bash

#openssl build for android: armeabi, armeabi-v7a, x86, x86_64, arm64-v8a, mips, mips64

ANDROID_TARGET_API=28
ANDROID_TARGET_ABI=arm64-v8a
GCC_VERSION=4.9
OUTPUT_PATH=xxxx

rm -rf ${OUTPUT_PATH}

./openssl_build.sh ${ANDROID_TARGET_API} ${ANDROID_TARGET_ABI} ${GCC_VERSION} ${OUTPUT_PATH}
 
rm -rf ${OUTPUT_PATH}/bin
rm -rf ${OUTPUT_PATH}/certs
rm -rf ${OUTPUT_PATH}/lib/engines
rm -rf ${OUTPUT_PATH}/lib/pkgconfig
rm -rf ${OUTPUT_PATH}/man
rm -rf ${OUTPUT_PATH}/misc
rm -rf ${OUTPUT_PATH}/private
rm -f ${OUTPUT_PATH}/openssl.cnf

