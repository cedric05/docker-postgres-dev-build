# debain would have been better, it needs testing
FROM ubuntu:focal

LABEL org.opencontainers.image.authors="kesavarapu.siva@gmail.com"

ENV LANG en_US.utf8
ENV PG_VERSION 15.0
ENV PG_PREFIX /usr/share/postgresql
ENV PGHOME ${PG_PREFIX}/$PG_VERSION
ENV PGDATA /var/lib/postgresql/data
ENV DEBIAN_FRONTEND=noninteractive 
ENV PG_START_UP_SCRIPT /startup.sql
ENV PATH $PATH:${PGHOME}/bin
ENV TZ=Etc/UTC
RUN set -ex \
        \
        && apt-get update && apt-get install -y \
           ca-certificates \
           curl \
           procps \
           sysstat \
           libldap2-dev \
           libreadline-dev \
           libssl-dev \
           bison \
           flex \
           libghc-zlib-dev \
           libcrypto++-dev \
           libxml2-dev \
           libxslt1-dev \
           bzip2 nano \
           make \
           gcc \
           unzip \
           python3 libpython3-dev \
           locales \
           git libxml2\
        && localedef -i en_US -c -f UTF-8 en_US.UTF-8 \
        && groupadd -r postgres --gid=999 \
        && useradd -m -r -g postgres --uid=999 postgres \
        && git clone  --depth 1 https://github.com/postgres/postgres \
        && mv postgres /home/postgres/ \
        && mkdir -p "$PGDATA" "$PGHOME" \
        && chown -R postgres:postgres /home/postgres ${PGHOME} ${PGDATA} \
        && cd /home/postgres/postgres \
        && su postgres -c "./configure \
                --enable-integer-datetimes \
                --enable-thread-safety \
                --with-pgport=5432 \
                --prefix=${PGHOME} \
                --with-ldap \
                --with-python \
                --with-openssl \
                --with-libxml \
                --with-libxslt" \
        && su postgres -c "make -j 4 all" \
        && su postgres -c "make install" \
        && su postgres -c "make -C contrib install" \
        && apt-get update && apt-get purge --auto-remove -y \
           libldap2-dev \
           libpython3-dev \
           libreadline-dev \
           libssl-dev \
           libghc-zlib-dev \
           libcrypto++-dev \
           libxml2-dev \
           libxslt1-dev \
           bzip2 \
           gcc \
           make \
        && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.utf8
USER postgres
EXPOSE 5432
COPY docker-entrypoint.sh /
COPY write.sql /
ENTRYPOINT ["/docker-entrypoint.sh"]