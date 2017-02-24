FROM anapsix/alpine-java:8_server-jre_unlimited

RUN  apk add --no-cache --virtual .build-deps curl \
 &&  curl -L https://github.com/krallin/tini/releases/download/v0.14.0/tini \
     | install -m 0755 /dev/stdin /usr/bin/tini \
 &&  apk del .build-deps \
 &&  rm -rf /var/cache/apk/*

RUN  apk add --no-cache --virtual .runtime-deps su-exec \
 &&  rm -rf /var/cache/apk/*

RUN  apk add --no-cache --virtual .build-deps libcap \
 &&  setcap 'cap_net_bind_service=+ep' /opt/jdk/bin/java \
 &&  cp /opt/jdk/jre/lib/amd64/jli/libjli.so /usr/lib/ \
 &&  /usr/glibc-compat/sbin/ldconfig \
 &&  apk del .build-deps \
 &&  rm -rf /var/cache/apk/*

RUN  set -x \
 &&  export pkgname=tomcat-native pkgver=1.2.12 \
 &&  apk add --no-cache --virtual .runtime-deps apr \
 &&  apk add --no-cache --virtual .build-deps apr-dev chrpath openjdk8 curl tar openssl-dev gcc make libc-dev \
 &&  mkdir /usr/src \
 &&  cd /usr/src \
 &&  curl -sL http://www-eu.apache.org/dist/tomcat/tomcat-connectors/native/$pkgver/source/$pkgname-$pkgver-src.tar.gz \
     | tar -xvz \
 &&  cd tomcat-native-$pkgver-src/native \
 &&  ./configure --prefix=/usr --with-java-home=$(find /usr -name jni_md.h | grep x86_64-alpine-linux-musl | head -1 | xargs dirname | xargs dirname) --with-ssl=yes \
 &&  DESTDIR=/usr/src/tomcat-native-${pkgver}-dist make install \
 &&  ( cd /usr/src/tomcat-native-${pkgver}-dist; find * -name '*.so*' -type f | xargs -t -r -n1 strip -s) \
 &&  ( cd /usr/src/tomcat-native-${pkgver}-dist; tar -c $(find * -name '*.so*')) | tar -x -C / \
 &&  cd / \
 &&  rm -rf /usr/src \
 &&  apk del .build-deps

ADD scripts/with-reaper         /with-reaper
ADD scripts/environment-hygiene /environment-hygiene

ADD scripts/log4j-configurator  /log4j-configurator
ADD scripts/tomcat-configurator /tomcat-configurator
