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
RUN wget https://dl.google.com/android/repository/android-ndk-r14b-linux-x86_64.zip

# Extracting ndk/sdk

RUN tar -xvzf android-sdk_r24.3.3-linux.tgz && \
	unzip android-ndk-r14b-linux-x86_64.zip


# Set ENV variables

ENV ANDROID_HOME /Android/android-sdk-linux
ENV NDK_ROOT /Android/android-ndk-r14b
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools

# Make stand alone toolchain (Modify platform / arch here)

RUN mkdir=toolchain-arm && bash $NDK_ROOT/build/tools/make-standalone-toolchain.sh \
    --verbose --platform=android-22 --install-dir=toolchain-arm --arch=arm \
    --toolchain=arm-linux-androideabi-clang3.6 --stl=libc++

ENV TOOLCHAIN /Android/toolchain-arm
ENV SYSROOT $TOOLCHAIN/sysroot
ENV PATH $PATH:$TOOLCHAIN/bin:$SYSROOT/usr/local/bin

# Configure toolchain path

ENV ARCH armv7

#ENV CROSS_COMPILE arm-linux-androideabi
ENV CC arm-linux-androideabi-clang
ENV CXX arm-linux-androideabi-clang++
ENV AR arm-linux-androideabi-ar
ENV AS arm-linux-androideabi-as
ENV LD arm-linux-androideabi-ld
ENV RANLIB arm-linux-androideabi-ranlib
ENV NM arm-linux-androideabi-nm
ENV STRIP arm-linux-androideabi-strip
ENV CHOST arm-linux-androideabi

ENV CXXFLAGS -std=c++14 -Wno-error=unused-command-line-argument

# curl
RUN curl -OL http://curl.haxx.se/download/curl-7.57.0.tar.gz && \
	tar -xzf curl-7.57.0.tar.gz

RUN cd curl-7.57.0 && ./configure --prefix=$HOME/usr --host=arm-linux-androideabi && \
    make && make install 

# jansson
RUN curl -O http://www.digip.org/jansson/releases/jansson-2.10.tar.gz && \
    tar -xzf jansson-2.10.tar.gz

RUN cd jansson-2.10 && ./configure --prefix=$HOME/usr --host=arm-linux-androideabi && \
    make && make install

# zlib
RUN curl -OL https://www.zlib.net/zlib-1.2.11.tar.gz && \
    tar -xzf zlib-1.2.11.tar.gz

RUN cd zlib-1.2.11 && ./configure --prefix=$HOME/usr && \
    make && make install


# miner
RUN curl -OL https://github.com/bitzeny/cpuminer/archive/master.zip && \
    unzip master.zip && cd cpuminer-master && \
    mkdir m4 && cp $HOME/usr/share/aclocal/libcurl.m4 m4 && \
    sed -i -e 's/aclocal/aclocal -I m4/' autogen.sh && \
    echo 'minerd_LDFLAGS += -fPIE -pie' >> Makefile.am &&\
    echo 'minerd_CPPFLAGS += -fPIE' >> Makefile.am &&\
    echo 'ACLOCAL_AMFLAGS = -I m4' >> Makefile.am &&\
    ./autogen.sh && ./configure --host=arm-linux-androideabi --with-libcurl=$HOME/usr && make

#ENTRYPOINT cp -r /Android/output/* /output
