#!/bin/bash
# tc3-android-update-tc3.sh, ABr
# Update target android openssl libraries on Tc3 external

tc3_dir="${tc3_dir:-$HOME/proj/git/src/triplecyber.visualstudio.com/abruce-dev/TripleChain/Tc3}"
openssl_ver="${openssl_ver:-3.1.4}"
for i in arm64-v8a armeabi-v7a x86 x86_64 ; do
  echo "Processing $i..."
  abi=$i
  src_dir=./openssl-$abi
  tgt_dir="$tc3_dir"/External/openssl/android/$openssl_ver/$abi
  echo "mkdir -p '$tgt_dir'"
  mkdir -p "$tgt_dir"
  echo "rm -fR '$tgt_dir'/*"
  rm -fR "$tgt_dir"/*
  the_rc=$? ; [ $the_rc -ne 0 ] && break
  echo "cp -R '$src_dir'/* '$tgt_dir'/"
  yes | cp -R "$src_dir"/* "$tgt_dir"/
  the_rc=$? ; [ $the_rc -ne 0 ] && break
  echo ''
done

