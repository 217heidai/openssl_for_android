# OpenSSL for Android
static OpenSSL library for android
## Android
| Android | Suport |
| --- | --- |
| armeabi | √ |
| armeabi-v7a | √ |
| arm64-v8a | √ |
| x86 | √ |
| x86_64 | √ |
| mips | × |
| mips64 | × |
## OpenSSL
| OpenSSL | Suport |
| --- | --- |
| 1.0.2* | √ |
| 1.1.0* | × |
| 1.1.1* | × |

[Download](https://www.openssl.org/source/)
## How to compile
### Android NDK
change Android NDK path in openssl_build.sh "ANDROID_NDK_PATH=xxxx"
### Android API
change Android API in openssl_build_xxxx.sh "ANDROID_TARGET_API=xx"
### OpenSSl Path
change OpenSSL path in openssl_build.sh "OPENSSL_SOURCES_PATH=xxxx"
### Output
change output path in openssl_build_xxxx.sh "OUTPUT_PATH=xxxx"



