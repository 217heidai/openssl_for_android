#!/bin/bash
# tc3-android-build-wrapper.sh, ABr
#
# Build openssl for android with mods to compiled correctly
the_log=/tmp/build_openssl_android.log
echo 'build_openssl_android: Start...' | tee "$the_log"
echo '' | tee -a "$the_log"
first_flag=0
for i in armeabi-v7a arm64-v8a x86 x86_64 ; do
  if [ x"$first_flag" = x1 ] ; then
    echo "***$i: clean" | tee -a "$the_log"
    ./openssl_build.sh $i clean | tee -a /tmp/build_openssl_android.log || break
    echo '' | tee -a "$the_log"
    first_flag=0
  fi
  echo "***$i: build" | tee -a "$the_log"
  ./openssl_build.sh $i 2>&1 | tee -a /tmp/build_openssl_android.log || break
  echo '' | tee -a "$the_log"
done

