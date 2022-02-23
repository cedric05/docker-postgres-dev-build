FROM ubuntu

LABEL org.opencontainers.image.authors="kesavarapu.siva@gmail.com"

ENV LANG en_US.utf8
ENV PG_VERSION 14.3
ENV PGDATA /u02/pgdata
ENV DEBIAN_FRONTEND=noninteractive 
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
           bzip2 \
           make \
           gcc \
           unzip \
           python3 libpython3-dev \
           locales \
           git libxml2\
        && localedef -i en_US -c -f UTF-8 en_US.UTF-8 \
        && mkdir /u01/ \
        \
        && groupadd -r postgres --gid=999 \
        && useradd -m -r -g postgres --uid=999 postgres \
        && chown postgres:postgres /u01/ \
        && mkdir -p "$PGDATA" \
        && chown -R postgres:postgres "$PGDATA" \
        && chmod 700 "$PGDATA" \
        \
        && git clone  --depth 1 https://github.com/postgres/postgres \
        && mv postgres /home/postgres/ \
        && chown -R postgres:postgres /home/postgres \
        \
        cd /home/postgres/postgres \
        && su postgres -c "./configure \
                --enable-integer-datetimes \
                --enable-thread-safety \
                --with-pgport=5432 \
                --prefix=/u01/app/postgres/product/$PG_VERSION \
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
ENTRYPOINT ["/docker-entrypoint.sh"]