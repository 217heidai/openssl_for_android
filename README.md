# OpenSSL for Android
Automatically compile static OpenSSL(3.1.*) library for Android by Github Actions.

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
1. OpenSSL is pulled down based on the environment variable `OPENSSL_VERSION` (defaults to `3.1.3`)
1. Output is placed in the local folder under `openssl-[android_target_abi]`. For example, arm64 is located under `openssl-arm64-v8a`.

To build everything using default target API level:
```
for i in armeabi-v7a arm64-v8a x86 x86_64 ; do ./openssl_build.sh $i 2>&1 | tee -a /tmp/build_openssl_android.log || break ; done
```

## Android
`armeabi`、`mips`、`mips64` targets are no longer supported with NDK R17+.
* [ ] armeabi
* [x] armeabi-v7a
* [x] arm64-v8a
* [x] x86
* [x] x86_64
* [ ] mips
* [ ] mips64

## ChangeLog
| Date      | Content                                                              |
|-----------|----------------------------------------------------------------------|
| 2023.09.21 | OpenSSL 3.1.3 |
| 2023.08.03 | OpenSSL 3.1.2 |
| 2023.06.05 | OpenSSL 3.1.1 |
| 2023.03.15 | OpenSSL 3.1.0 |
| 2023.02.09 | OpenSSL 3.0.8 |
| 2022.11.07 | OpenSSL 3.0.7 |
| 2022.07.14 | OpenSSL 3.0.5 |
| 2022.06.23 | OpenSSL 3.0.4 |
| 2022.05.19 | OpenSSL 3.0.3 |
| 2022.03.16 | OpenSSL 3.0.2 |
| 2021.12.24 | OpenSSL 3.0.1 |
| 2021.10.12 | OpenSSL 3.0.0 && `*MIPS` targets are no longer supported|
| 2021.09.08 | OpenSSL 1.1.1l |
| 2021.03.29 | OpenSSL 1.1.1k |
| 2021.02.18 | OpenSSL 1.1.1j |
| 2021.01.20 | OpenSSL 1.1.1i |
