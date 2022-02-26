# Postgres-dev-build
This project aims to build postgres from latest [build](https://github.com/postgres/postgres)

## Running

To run

`docker run --restart always --name postgres-15 -p 5432:5432  ghcr.io/cedric05/postgres:dev`

To connect using default user 

`psql postgresql://my_pg_user:my_pg_password@localhost:5432/my_pg_database`

## Configuration && persistance

bydefault all the postgres database data will be stored in `/var/lib/postgresql/data`

```shell
docker volume create postgres-data
docker run --restart always -e PGDATABASENAME=my_post -e PGUSERNAME=my_post -e PGPASSWD=my_post -v $(pwd)/startup.sql:/startup.sql -v $(pwd)/config.yaml:/extra_config.conf  -v postgres-data:/var/lib/postgresql --name postgres-15 -p 5432:5432 ghcr.io/cedric05/postgres:dev
```

    (or)

```yml
services:
    cedric05:
        restart: always
        environment:
            # handle to configure custom user/password/database
            - PGDATABASENAME=my_post
            - PGUSERNAME=my_post
            - PGPASSWD=my_post
        volumes:
            # handle to run startup script (only runs first time)
            - ./startup.sql:/startup.sql
            # handle to update `postgres.conf` only works first time
            - ./extra_config.conf:/extra_config.conf
            # use persistance volume
            - 'postgres-data:/var/lib/postgresql'
        container_name: postgres-15
        ports:
            - '5432:5432'
        image: 'ghcr.io/cedric05/postgres:dev'
    adminer:
        image: adminer
        restart: always
        ports:
        - 8080:8080
volumes:
    postgres-data:
```

and connect using 

`psql postgresql://my_post:my_post@localhost:5432/my_post`

### Environment Variables


PGUSERNAME

    This environment variable is required for you to use the PostgreSQL image. It must not be empty or undefined. This environment variable sets the superuser password for PostgreSQL. The default superuser is defined by the `PGUSERNAME` environment variable.

PGPASSWD

    This optional environment variable is used in conjunction with `PGPASSWD` to set a user and its password. This variable will create the specified user with superuser power and a database with the same name. If it is not specified, then the default user of postgres will be used.

PGDATABASENAME

    This optional environment variable can be used to define a different name for the default database that is created when the image is first started. If it is not specified, then the value of `PGUSERNAME` will be used.

