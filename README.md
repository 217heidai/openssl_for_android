# OpenSSL for Android
Automatically compile static OpenSSL library for Android.

This was originally built from 217heidai/openssl_for_android but has drifted significantly and been simplified.

The worker script is build_openssh.sh as in the original fork, but the build structure itself is totally different.

Usage:
1. Requires installed Android NDK. The location can be set using `ANDROID_NDK_LOCAL_PLATFORM` environment variable but the script attempts to locate the NDK for macOS and Linux if the environment variable is not provided.
1. To build latest OpenSSL use:
    ```
    openssl_build.sh [android_target_abi | clean] [android_target_api | default]
    ```
    The two parameters are:
    * `android_target_abi` - one of:
        * `armeabi-v7a`, `arm64-v8a`, `x86`, `x86_64` - ABI to build (`arm64-v8a` is default if not provided on command line)
        * `clean` - Removes all local output files to force a fresh rebuild
    * `android_target_api` - specific API level to target or `default` to use the default level from the NDK (`default` is used if not provided on command line)
1. OpenSSL is pulled down based on the environment variable `OPENSSL_VERSION` (defaults to `3.2.1`)
1. Output is placed in the local folder under `openssl-[android_target_abi]`. For example, arm64 is located under `openssl-arm64-v8a`.

To build everything using default target API level:
```
./tc3-android-build-wrapper.sh
```
Output is placed in `/tmp/build_openssl_android.log`

## Android
`armeabi`、`mips`、`mips64` targets are no longer supported with NDK R17+.
* [ ] armeabi
* [x] armeabi-v7a
* [x] arm64-v8a
* [x] x86
* [x] x86_64
* [ ] mips
* [ ] mips64

