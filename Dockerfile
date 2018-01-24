#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM cmp1234/alpine-bash
# A few problems with compiling Java from source:
#  1. Oracle.  Licensing prevents us from redistributing the official JDK.
#  2. Compiling OpenJDK also requires the JDK to be installed, and it gets
#       really hairy.

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin:/usr/local/bin

ENV JAVA_VERSION 8u151
ENV JAVA_ALPINE_VERSION 8.151.12-r0

RUN set -ex; \
	sed -i -e 's/v3\.6/edge/g' /etc/apk/repositories; \
	apk add --no-cache \
	openjdk8-jre="$JAVA_ALPINE_VERSION"; \
	sed -i -e 's/edge/v3\.6/g' /etc/apk/repositories; \
	adduser -u 18345 -D cmp;

	
#install python

# install ca-certificates so that HTTPS works consistently
# the other runtime dependencies for Python are installed later
ENV GPG_KEY C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF
ENV PYTHON_VERSION 2.7.14

RUN apk add --no-cache python2=2.7.14-r2 ca-certificates

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 9.0.1

RUN set -ex; \
	\
	apk add --no-cache --virtual .fetch-deps libressl; \
	\
	wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
	\
	apk del .fetch-deps; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a -name test -o -name tests \) \
			-o \
			\( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py
	
	
#install su&font
RUN apk add --no-cache fontconfig ttf-dejavu
RUN apk add --no-cache 'su-exec>=0.2'


#install sshpass
ENV SSHPASS_VERSION 1.06
ENV SSHPASS_DOWNLOAD_URL https://nchc.dl.sourceforge.net/project/sshpass/sshpass/1.06/sshpass-1.06.tar.gz

RUN curl -fSL $SSHPASS_DOWNLOAD_URL -o sshpass-${SSHPASS_VERSION}.tar.gz; \
	tar xvf sshpass-${SSHPASS_VERSION}.tar.gz; \
	cd sshpass-${SSHPASS_VERSION}; \
	./configure --prefix=/usr/local && make && make install && cd .. && rm sshpass-${SSHPASS_VERSION}* -rf; 
	
	
#install ansible
RUN ansibleList=' \
            pycrypto==2.6.1 \
            ecdsa==0.13 \
            paramiko==1.17.0 \
            MarkupSafe==1.0 \
            Jinja2==2.8 \
            PyYAML==3.11 \
            ansible==2.2.1.0 \
        '; \
  pip install $ansibleList;
	
	
#install openssh
COPY build_openssh.sh /build_openssh.sh 
RUN chmod +x /build_openssh.sh

RUN set -ex; \
	\
	apk add --no-cache --virtual .build-deps \
		coreutils \
		gcc \
		curl \
		linux-headers \
		make \
		musl-dev \
		zlib \
		zlib-dev \
		openssl \
		openssl-dev \
		bash \
		python2-dev \
		python3-dev \
	; \
	apk add --no-cache --virtual .run-deps \
		libcrypto1.0 \
	; \
	
  	sh /build_openssh.sh; \
	apk del .build-deps; \
	ln -s /usr/local/bin/bash /bin/bash; \
	rm -f /build_openssh.sh;

	
#install geniso	
RUN apk add --no-cache cdrkit

WORKDIR /home/cmp
