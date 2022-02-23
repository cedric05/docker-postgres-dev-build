FROM ubuntu
 
# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
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
           python3 \
           locales \
           git 
           
RUN rm -rf /var/lib/apt/lists/* \
        && localedef -i en_US -c -f UTF-8 en_US.UTF-8 \
        && mkdir /u01/ \
        \
        && groupadd -r postgres --gid=999 \
        && useradd -m -r -g postgres --uid=999 postgres \
        && chown postgres:postgres /u01/ \
        && mkdir -p "$PGDATA" \
        && chown -R postgres:postgres "$PGDATA" \
        && chmod 700 "$PGDATA"
RUN set -ex \
        && git clone  --depth 1 https://github.com/postgres/postgres \
        && mv postgres /home/postgres/ \
        && chown -R postgres:postgres /home/postgres
RUN apt-get update && apt-get install -y libpython3-dev
RUN  cd /home/postgres/postgres \
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
        && apt-get update \
        && apt-get install -y libxml2
ENV LANG en_US.utf8
USER postgres
EXPOSE 5432
COPY docker-entrypoint.sh /
# COPY postgresql.conf /
ENTRYPOINT ["/docker-entrypoint.sh"]