# Android Library Builder
## Summary
This Dockerfile builds Android libraries. Currently, following libraries are built.

+ curl
+ jansson
+ zlib

All the libraries are installed into /root/usr/[Arch]


Supported archtectures are

+ armeabi-v7a
+ arm64-v8a
+ x86
+ x86_64


Also following binary is built (currently build fails with arm64-v8a, x86 and x86_64)

+ cpuminer


## Usage

```
$ mkdir data
$ docker build -t android_builder .
$ docker run -it --rm -v ./data:/data android_builder bash
# ./build.sh
# cp -r /root/usr /data
# cp -r /root/miner /data
```
