# THIS DOCKERFILE TRIES TO COMPILE CURL/OPENSSL FOR ANDROID
#
# 5 july 2015
#
# More detals could be found here: 
# http://vitiy.info/dockerfile-example-to-compile-libcurl-for-android-inside-docker-container/
# https://qiita.com/honeniq/items/07ae3d73eb0e8a8fb27f
 
FROM ubuntu

MAINTAINER Victor Laskin "victor.laskin@gmail.com"

# Install compilation tools

RUN echo "nameserver 8.8.8.8" >> /etc/resolv.conf

RUN apt-get update && apt-get install -y \
    automake \
    build-essential \
    wget \
    bash \
    curl \
    python \
    vim \
    zip


# Download SDK / NDK

RUN mkdir /Android && cd Android && mkdir output
WORKDIR /Android

RUN wget http://dl.google.com/android/android-sdk_r24.3.3-linux.tgz
RUN wget https://dl.google.com/android/repository/android-ndk-r17b-linux-x86_64.zip

# Extracting ndk/sdk

RUN tar -xvzf android-sdk_r24.3.3-linux.tgz && \
	unzip android-ndk-r17b-linux-x86_64.zip


# Set ENV variables

ENV ANDROID_HOME /Android/android-sdk-linux
ENV NDK_ROOT /Android/android-ndk-r17b
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools

# Make stand alone toolchain (Modify platform / arch here)

RUN mkdir=toolchain-arm && bash $NDK_ROOT/build/tools/make-standalone-toolchain.sh \
    --verbose --platform=android-19 --install-dir=toolchain-19-arm --arch=arm \
    --toolchain=arm-linux-androideabi-clang3.6 --stl=libc++

RUN mkdir=toolchain-x86 && bash $NDK_ROOT/build/tools/make-standalone-toolchain.sh \
    --verbose --platform=android-19 --install-dir=toolchain-19-x86 --arch=x86 \
    --toolchain=arm-linux-androideabi-clang3.6 --stl=libc++

RUN mkdir=toolchain-arm && bash $NDK_ROOT/build/tools/make-standalone-toolchain.sh \
    --verbose --platform=android-21 --install-dir=toolchain-21-arm --arch=arm \
    --toolchain=arm-linux-androideabi-clang3.6 --stl=libc++

RUN mkdir=toolchain-aarch64 && bash $NDK_ROOT/build/tools/make-standalone-toolchain.sh \
    --verbose --platform=android-21 --install-dir=toolchain-21-aarch64 --arch=arm64 \
    --toolchain=aarch64-linux-androideabi-clang3.6 --stl=libc++

RUN mkdir=toolchain-x86 && bash $NDK_ROOT/build/tools/make-standalone-toolchain.sh \
    --verbose --platform=android-21 --install-dir=toolchain-21-x86 --arch=x86 \
    --toolchain=x86-linux-androideabi-clang3.6 --stl=libc++

RUN mkdir=toolchain-x86_64 && bash $NDK_ROOT/build/tools/make-standalone-toolchain.sh \
    --verbose --platform=android-21 --install-dir=toolchain-21-x86_64 --arch=x86_64 \
    --toolchain=x86_64-linux-androideabi-clang3.6 --stl=libc++

# build.sh
COPY build.sh .
