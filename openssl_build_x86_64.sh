#!/bin/bash


ANDROID_TARGET_API=21
ANDROID_TARGET_ABI=x86_64
GCC_VERSION=4.9

rm -rf ${OUTPUT_PATH}

./openssl_build.sh ${ANDROID_TARGET_API} ${ANDROID_TARGET_ABI} ${GCC_VERSION}
 
rm -rf ${OUTPUT_PATH}/bin
rm -rf ${OUTPUT_PATH}/share
rm -rf ${OUTPUT_PATH}/ssl
rm -rf ${OUTPUT_PATH}/lib/engines*
rm -rf ${OUTPUT_PATH}/lib/pkgconfig




