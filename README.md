# Android Library Builder
## Summary
This Dockerfile builds Android libraries. Currently, following libraries are built.

+ curl
+ jansson
+ zlib

All the libraries are installed into /root/usr


Also following binary is built

+ cpuminer


## Usage

```
$ mkdir data
$ docker build -t android_builder .
$ docker run -it --rm -v ./data:/data android_builder bash
# cp -r /root/usr /data
```
