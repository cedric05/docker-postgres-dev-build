SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
SET default_tablespace = '';
SET default_table_access_method = heap;

CREATE TABLE public.transaction (
    type integer NOT NULL,
    nonce integer NOT NULL,
    tr_from character varying(32) NOT NULL,
    tr_to character varying(32) NOT NULL,
    amount integer NOT NULL,
    ts bigint NOT NULL,
    signature character varying(64) NOT NULL,
    block_miner_id integer NOT NULL,
    block_miner_signature character varying(64) NOT NULL,
    hash bigint NOT NULL,
    ctimestamp bigint DEFAULT (date_part('epoch'::text, now()) * (1000)::double precision) NOT NULL,
    name character varying(32) NOT NULL
);

ALTER TABLE public.transaction OWNER TO postgres;
COPY public.transaction (type, nonce, tr_from, tr_to, amount, ts, signature, block_miner_id, block_miner_signature, hash, ctimestamp, name) FROM stdin;
CREATE INDEX transaction_ctimestamp_idx ON public.transaction USING btree (ctimestamp);
CREATE INDEX transaction_hash_idx ON public.transaction USING btree (hash);
CREATE PUBLICATION mypublication WITH (publish = 'insert');
ALTER PUBLICATION mypublication OWNER TO postgres;
GRANT ALL ON TABLE public.transaction TO sammy;
CREATE ROLE pgexporter WITH LOGIN PASSWORD 'pgexporter';
GRANT ALL PRIVILEGES ON DATABASE "postgres" to pgexporter;
ALTER USER pgexporter WITH SUPERUSER;
CREATE ROLE sammy WITH REPLICATION LOGIN PASSWORD 'my_password';
GRANT ALL PRIVILEGES ON DATABASE postgres TO sammy;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO sammy;
ALTER PUBLICATION mypublication ADD TABLE ONLY public.transaction WHERE (((name)::text = 'mm1'::text));