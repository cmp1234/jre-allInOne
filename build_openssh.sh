#!/bin/sh

PREFIX=/usr/local/openssh

OPENSSH=openssh-7.4p1
ZLIB=zlib-1.2.11
OPENSSL=openssl-1.0.2k

ZLIB_PKG=${ZLIB}.tar.gz
OPENSSL_PKG=${OPENSSL}.tar.gz
OPENSSH_PKG=${OPENSSH}.tar.gz

ZLIB_DOWNLOAD_URL=http://zlib.net
OPENSSL_DOWNLOAD_URL=http://www.openssl.org/source
OPENSSH_DOWNLOAD_URL=http://mirrors.sonic.net/pub/OpenBSD/OpenSSH/portable

rm -rf $PREFIX 
mkdir $PREFIX

rm -rf src 
mkdir src

rm openssh -rf

cd src

wget $ZLIB_DOWNLOAD_URL/$ZLIB_PKG --no-check-certificate && tar xf $ZLIB_PKG
wget $OPENSSL_DOWNLOAD_URL/$OPENSSL_PKG --no-check-certificate && tar xf $OPENSSL_PKG
wget $OPENSSH_DOWNLOAD_URL/$OPENSSH_PKG && tar xf $OPENSSH_PKG

cd $OPENSSH

./configure --prefix=$PREFIX --with-zlib=../$ZLIB --with-ssl-dir=../$OPENSSL && make \
&& make install \
&& cp contrib/ssh-copy-id /usr/local/bin/ \
&& chmod +x /usr/local/bin/ssh-copy-id \
&& cd ../.. \
&& rm -rf src \
&& cp $PREFIX/bin/* /usr/local/bin/ \
&& rm -rf $PREFIX/libexec $PREFIX/sbin $PREFIX/bin/*
