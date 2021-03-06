#!/bin/bash

# Download libaries
# curl
curl -OL http://curl.haxx.se/download/curl-7.57.0.tar.gz && \
	tar -xzf curl-7.57.0.tar.gz

# jansson
curl -O http://www.digip.org/jansson/releases/jansson-2.11.tar.gz && \
    tar -xzf jansson-2.11.tar.gz

# zlib
curl -OL https://www.zlib.net/zlib-1.2.11.tar.gz && \
    tar -xzf zlib-1.2.11.tar.gz

# miner
curl -OL https://github.com/BitzenyCoreDevelopers/cpuminer/archive/master.zip && \
    unzip master.zip

CXXFLAGS='-std=c++14 -Wno-error=unused-command-line-argument'

for API in 19 21
do
    if [ ${API} -eq 19 ]; then
        ARCHS=(arm x86)
    else
        ARCHS=(arm aarch64 x86 x86_64)
    fi
    for ARCH in ${ARCHS[@]}
    do
        export TOOLCHAIN=/Android/toolchain-${API}-${ARCH}
        export SYSROOT=$TOOLCHAIN/sysroot
        export PATH=$PATH:$TOOLCHAIN/bin:$SYSROOT/usr/local/bin

        if [ ${ARCH} == arm ]; then
            TARGET=arm-linux-androideabi
        elif [ ${ARCH} == x86 ]; then
            TARGET=i686-linux-android
        else
            TARGET=${ARCH}-linux-android
        fi

        # cross compile environment variables
        export CC=${TARGET}-clang
        export CXX=${TARGET}-clang++
        export AR=${TARGET}-ar
        export AS=${TARGET}-as
        export LD=${TARGET}-ld
        export RANLIB=${TARGET}-ranlib
        export NM=${TARGET}-nm
        export STRIP=${TARGET}-strip
        export CHOST=${TARGET}
        echo "=================="
        echo $CC
        echo "=================="

        # curl
        pushd `pwd`
        cd curl-7.57.0 && ./configure --prefix=$HOME/usr/${API}/${ARCH} --host=${TARGET} && \
            make && make install && make clean
        popd

        # jansson
        pushd `pwd`
        cd jansson-2.11 && ./configure --prefix=$HOME/usr/${API}/${ARCH} --host=${TARGET} && \
            make && make install && make clean
        popd

        # zlib
        pushd `pwd`
        cd zlib-1.2.11 && ./configure --prefix=$HOME/usr/${API}/${ARCH} && \
            make && make install && make clean
        popd

        # miner
        pushd `pwd`
        cd cpuminer-master && \
        mkdir -p m4 && cp $HOME/usr/${API}/${ARCH}/share/aclocal/libcurl.m4 m4 && \
            sed -i -e 's/aclocal/aclocal -I m4/' autogen.sh && \
            echo 'minerd_LDFLAGS += -fPIE -pie' >> Makefile.am && \
            echo 'minerd_CPPFLAGS += -fPIE' >> Makefile.am && \
            echo 'ACLOCAL_AMFLAGS = -I m4' >> Makefile.am && \
            ./autogen.sh && \
            ./configure --prefix=$HOME/miner/${API}/${ARCH} --host=${TARGET} --with-libcurl=$HOME/usr/${API}/${ARCH} CFLAGS="-O3 -march=native -funroll-loops -fomit-frame-pointer" && \
            make && make install && make clean
        popd
    done
done
