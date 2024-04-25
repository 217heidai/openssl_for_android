#!/bin/bash
# tc3-android-build-wrapper.sh, ABr
#
# Build openssl for android with mods to compiled correctly
echo 'build_openssl_android: Start...'
echo ''
first_flag=0
for i in armeabi-v7a arm64-v8a x86 x86_64 ; do
  if [ x"$first_flag" = x1 ] ; then
    echo "***$i: clean"
    ./openssl_build.sh $i clean || break
    echo ''
    first_flag=0
  fi
  echo "***$i: build"
  ./openssl_build.sh $i || break
  echo ''
done

