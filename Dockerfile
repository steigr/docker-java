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

RUN  export XMLSTARLET_VERSION=1.6.1-r1 \
 &&  apk add --no-cache --virtual .runtime-deps libxml2 libxslt \
 &&  apk add --no-cache --virtual .build-deps curl \
 &&  curl -Lo xmlstarlet-${XMLSTARLET_VERSION}.apk https://github.com/menski/alpine-pkg-xmlstarlet/releases/download/${XMLSTARLET_VERSION}/xmlstarlet-${XMLSTARLET_VERSION}.apk \
 &&  apk add --allow-untrusted xmlstarlet-${XMLSTARLET_VERSION}.apk \
 &&  apk del .build-deps \
 &&  rm -rf /var/cache/apk/* \
            xmlstarlet-${XMLSTARLET_VERSION}.apk

ADD scripts/with-reaper           /with-reaper
ADD scripts/environment-hygiene   /environment-hygiene
ADD scripts/timezone-configurator /timezone-configurator
