# OpenSSL for Android
How to compile static OpenSSL library for android by Linux

## Android
| Android | Suport |
| :-: | :-: |
| armeabi | √ |
| armeabi-v7a | √ |
| arm64-v8a | √ |
| x86 | √ |
| x86_64 | √ |
| mips | √ |
| mips64 | √ |

## How to compile
1. Download [OpenSSL 1.1.1*](https://www.openssl.org/source/)、[Android NDK r14b](https://developer.android.google.cn/ndk/downloads/index.html)  
**only support Android NDK r14b**  

2. Android NDK path  
Set Android NDK path in openssl_build.sh "ANDROID_NDK_PATH=xxxx"

3. OpenSSl Path  
Set OpenSSL path in openssl_build.sh "OPENSSL_SOURCES_PATH=xxxx"

4. output Path  
Set output path in openssl_build.sh "OUTPUT_PATH=xxxx"

5. compile all  
    ```bash
    sh openssl_build_all.sh
    ```
