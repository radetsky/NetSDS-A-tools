--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

create user asterisk with password 'supersecret'; 

--
-- Name: asterisk; Type: DATABASE; Schema: -; Owner: asterisk
--

CREATE DATABASE asterisk WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF8' LC_CTYPE = 'en_US.UTF8';


ALTER DATABASE asterisk OWNER TO asterisk;

\connect asterisk

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: ivr; Type: SCHEMA; Schema: -; Owner: asterisk
--

CREATE SCHEMA ivr;


ALTER SCHEMA ivr OWNER TO asterisk;

--
-- Name: routing; Type: SCHEMA; Schema: -; Owner: asterisk
--

CREATE SCHEMA routing;


ALTER SCHEMA routing OWNER TO asterisk;

--
-- Name: users; Type: SCHEMA; Schema: -; Owner: asterisk
--

CREATE SCHEMA users;


ALTER SCHEMA users OWNER TO asterisk;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- Name: uuid_generate_v1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_generate_v1() RETURNS uuid
    LANGUAGE c STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v1';


ALTER FUNCTION public.uuid_generate_v1() OWNER TO postgres;

--
-- Name: uuid_generate_v1mc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_generate_v1mc() RETURNS uuid
    LANGUAGE c STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v1mc';


ALTER FUNCTION public.uuid_generate_v1mc() OWNER TO postgres;

--
-- Name: uuid_generate_v3(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_generate_v3(namespace uuid, name text) RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v3';


ALTER FUNCTION public.uuid_generate_v3(namespace uuid, name text) OWNER TO postgres;

--
-- Name: uuid_generate_v4(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_generate_v4() RETURNS uuid
    LANGUAGE c STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v4';


ALTER FUNCTION public.uuid_generate_v4() OWNER TO postgres;

--
-- Name: uuid_generate_v5(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_generate_v5(namespace uuid, name text) RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v5';


ALTER FUNCTION public.uuid_generate_v5(namespace uuid, name text) OWNER TO postgres;

--
-- Name: uuid_nil(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_nil() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_nil';


ALTER FUNCTION public.uuid_nil() OWNER TO postgres;

--
-- Name: uuid_ns_dns(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_ns_dns() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_ns_dns';


ALTER FUNCTION public.uuid_ns_dns() OWNER TO postgres;

--
-- Name: uuid_ns_oid(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_ns_oid() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_ns_oid';


ALTER FUNCTION public.uuid_ns_oid() OWNER TO postgres;

--
-- Name: uuid_ns_url(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_ns_url() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_ns_url';


ALTER FUNCTION public.uuid_ns_url() OWNER TO postgres;

--
-- Name: uuid_ns_x500(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_ns_x500() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_ns_x500';


ALTER FUNCTION public.uuid_ns_x500() OWNER TO postgres;

SET search_path = routing, pg_catalog;

--
-- Name: get_dial_route(character varying, integer); Type: FUNCTION; Schema: routing; Owner: asterisk
--

CREATE FUNCTION get_dial_route(destination character varying, try integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
declare

dir routing.directions%ROWTYPE;
r routing.route%ROWTYPE;
rname varchar(32);

begin

-- Try to find direction by prefix; 
select * into dir from routing.directions 
	where dr_prefix ~* $1 
	order by dr_prio 
	asc 
	limit 1; 

if not found then 
	return 'NO DIRECTION';
end if; 

-- Try to find route record that will give us type and destination id.
select * into r from routing.route 
	where route_direction_id = dir.dr_list_item 
	order by route_prio asc limit 1; 

if not found then 
	return 'NO ROUTE';
end if; 

-- Try to find destination id and name; 
-- case route_type (user) 
if r.route_type = 'user' then 
	select name into rname from public.sip_users where id=r.route_dest_id; 
	if not found then 
		return 'NO DESTINATION'; 
	end if; 
	return rname;
end if; 
-- case route_type (context) 
if r.route_type = 'context' then 

end if;
-- case route_type (trunk) 
if r.route_type = 'trunk' then 
	select name into rname from public.sip_peers where id=r.route_desi_id; 
	if not found then 
		return 'NO DESTINATION'; 
	end if;
	return rname; 
end if; 
-- case route_type (trunkgroup) 
if r.route_type = 'tgroup' then 

end if; 
RAISE EXCEPTION 'This is the end. Some situation can not be handled.';
return 'END';

end
$_$;


ALTER FUNCTION routing.get_dial_route(destination character varying, try integer) OWNER TO asterisk;

--
-- Name: FUNCTION get_dial_route(destination character varying, try integer); Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON FUNCTION get_dial_route(destination character varying, try integer) IS 'Main function for this software. Return the name of the peer/user depends on destination number and count of tries. ';


--
-- Name: route_test(); Type: FUNCTION; Schema: routing; Owner: asterisk
--

CREATE FUNCTION route_test() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
begin 
if NEW.route_type = 'trunk' then  
	perform  id from public.sip_peers where id=NEW.route_dest_id; 
	if not found then 
		raise exception 'sip peer not found with same id';
	end if;
end if;  
if NEW.route_type = 'user' then 
	perform  id from public.sip_users where id=NEW.route_dest_id; 
	if not found then 
		raise exception 'sip user not found with same id';
	end if; 
end if;
if NEW.route_type = 'context' then 
	perform id from public.extensions where id=NEW.route_dest_id; 
	if not found then 
		raise exception 'context not found'; 
	end if ; 
end if; 
if NEW.route_type = 'tgroup' then 
	perform tgrp_id from routing.trunkgroups where tgrp_id=NEW.route_dest_id; 
	if not found then 
		raise exception 'trunkgroup not found'; 
	end if;
end if;
return NEW;
end;
$$;


ALTER FUNCTION routing.route_test() OWNER TO asterisk;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: sip_peers; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE sip_peers (
    id bigint NOT NULL,
    name character varying(80) DEFAULT ''::character varying NOT NULL,
    accountcode character varying(20),
    amaflags character varying(7),
    callgroup character varying(10),
    callerid character varying(80),
    canreinvite character varying(3) DEFAULT 'no'::character varying,
    directmedia character varying(3) DEFAULT 'yes'::character varying,
    context character varying(80) DEFAULT 'default'::character varying,
    defaultip character varying(15),
    dtmfmode character varying(7) DEFAULT 'rfc2833'::character varying,
    fromuser character varying(80),
    fromdomain character varying(80),
    host character varying(31) DEFAULT 'dynamic'::character varying NOT NULL,
    insecure character varying(4),
    language character varying(2),
    mailbox character varying(50),
    md5secret character varying(80),
    nat character varying(5) DEFAULT 'no'::character varying NOT NULL,
    permit character varying(95),
    deny character varying(95),
    mask character varying(95),
    pickupgroup character varying(10),
    port character varying(5) DEFAULT ''::character varying NOT NULL,
    qualify character varying(3) DEFAULT 'yes'::character varying,
    restrictcid character varying(1),
    rtptimeout character varying(3),
    rtpholdtimeout character varying(3),
    secret character varying(80),
    type character varying DEFAULT 'friend'::character varying NOT NULL,
    username character varying(80) DEFAULT ''::character varying NOT NULL,
    disallow character varying(100) DEFAULT 'all'::character varying,
    allow character varying(100) DEFAULT 'ulaw,alaw'::character varying,
    musiconhold character varying(100),
    regseconds bigint DEFAULT (0)::bigint NOT NULL,
    ipaddr character varying(15) DEFAULT ''::character varying NOT NULL,
    regexten character varying(80) DEFAULT ''::character varying NOT NULL,
    cancallforward character varying(3) DEFAULT 'yes'::character varying,
    comment character varying(80) DEFAULT ''::character varying,
    "call-limit" smallint DEFAULT 1,
    lastms integer DEFAULT 0,
    regserver character varying(100) DEFAULT NULL::character varying,
    fullcontact character varying(80) DEFAULT NULL::character varying,
    useragent character varying(20) DEFAULT NULL::character varying,
    defaultuser character varying(10) DEFAULT NULL::character varying
);


ALTER TABLE public.sip_peers OWNER TO asterisk;

--
-- Name: sip_peers_id_seq; Type: SEQUENCE; Schema: public; Owner: asterisk
--

CREATE SEQUENCE sip_peers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sip_peers_id_seq OWNER TO asterisk;

--
-- Name: sip_peers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE sip_peers_id_seq OWNED BY sip_peers.id;


--
-- Name: sip_users; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE sip_users (
    id bigint NOT NULL,
    name character varying(80) DEFAULT ''::character varying NOT NULL,
    accountcode character varying(20),
    amaflags character varying(7),
    callgroup character varying(10),
    callerid character varying(80),
    canreinvite character varying(3) DEFAULT 'no'::character varying,
    directmedia character varying(3) DEFAULT 'yes'::character varying,
    context character varying(80) DEFAULT 'default'::character varying,
    defaultip character varying(15),
    dtmfmode character varying(7) DEFAULT 'rfc2833'::character varying,
    fromuser character varying(80),
    fromdomain character varying(80),
    host character varying(31) DEFAULT 'dynamic'::character varying NOT NULL,
    insecure character varying(4),
    language character varying(2),
    mailbox character varying(50),
    md5secret character varying(80),
    nat character varying(5) DEFAULT 'no'::character varying NOT NULL,
    permit character varying(95),
    deny character varying(95),
    mask character varying(95),
    pickupgroup character varying(10),
    port character varying(5) DEFAULT ''::character varying NOT NULL,
    qualify character varying(3) DEFAULT 'yes'::character varying,
    restrictcid character varying(1),
    rtptimeout character varying(3),
    rtpholdtimeout character varying(3),
    secret character varying(80),
    type character varying DEFAULT 'friend'::character varying NOT NULL,
    username character varying(80) DEFAULT ''::character varying NOT NULL,
    disallow character varying(100) DEFAULT 'all'::character varying,
    allow character varying(100) DEFAULT 'ulaw,alaw'::character varying,
    musiconhold character varying(100),
    regseconds bigint DEFAULT (0)::bigint NOT NULL,
    ipaddr character varying(15) DEFAULT ''::character varying NOT NULL,
    regexten character varying(80) DEFAULT ''::character varying NOT NULL,
    cancallforward character varying(3) DEFAULT 'yes'::character varying,
    comment character varying(80) DEFAULT ''::character varying,
    "call-limit" smallint DEFAULT 1,
    lastms integer DEFAULT 0,
    regserver character varying(100) DEFAULT NULL::character varying,
    fullcontact character varying(80) DEFAULT NULL::character varying,
    useragent character varying(20) DEFAULT NULL::character varying,
    defaultuser character varying(10) DEFAULT NULL::character varying
);


ALTER TABLE public.sip_users OWNER TO asterisk;

--
-- Name: sip_users_id_seq; Type: SEQUENCE; Schema: public; Owner: asterisk
--

CREATE SEQUENCE sip_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sip_users_id_seq OWNER TO asterisk;

--
-- Name: sip_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE sip_users_id_seq OWNED BY sip_users.id;


SET search_path = routing, pg_catalog;

--
-- Name: directions; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE directions (
    dr_id bigint NOT NULL,
    dr_list_item bigint NOT NULL,
    dr_prefix character varying(16) NOT NULL,
    dr_prio smallint DEFAULT 5 NOT NULL
);


ALTER TABLE routing.directions OWNER TO asterisk;

--
-- Name: TABLE directions; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE directions IS 'Список направлений. Направление характеризуется: 
1. Префиксом 
2. Названием
3. Приоритетом. ';


--
-- Name: COLUMN directions.dr_list_item; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON COLUMN directions.dr_list_item IS 'Ссылка на список названий. ';


--
-- Name: COLUMN directions.dr_prefix; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON COLUMN directions.dr_prefix IS 'Таки префикс, вплоть до самого номера. 067
067220 
0672201 :) ';


--
-- Name: COLUMN directions.dr_prio; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON COLUMN directions.dr_prio IS 'Приоритет маршрутизации. Чем меньше значение, тем выше приоритет. Пример: 
067       Киевстар            5
067220 Сотрудники_КС 1 

При выборе направления выбираем по regexp и order by prio. 

В данном примере будет 06722067 будет выбран 067220. ';


--
-- Name: directions_dr_id_seq; Type: SEQUENCE; Schema: routing; Owner: asterisk
--

CREATE SEQUENCE directions_dr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE routing.directions_dr_id_seq OWNER TO asterisk;

--
-- Name: directions_dr_id_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE directions_dr_id_seq OWNED BY directions.dr_id;


--
-- Name: directions_list; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE directions_list (
    dlist_id bigint NOT NULL,
    dlist_name character varying(32) NOT NULL
);


ALTER TABLE routing.directions_list OWNER TO asterisk;

--
-- Name: TABLE directions_list; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE directions_list IS 'Просто список с уникальными названиями и PK';


--
-- Name: directions_list_DLIST_ID_seq; Type: SEQUENCE; Schema: routing; Owner: asterisk
--

CREATE SEQUENCE "directions_list_DLIST_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE routing."directions_list_DLIST_ID_seq" OWNER TO asterisk;

--
-- Name: directions_list_DLIST_ID_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE "directions_list_DLIST_ID_seq" OWNED BY directions_list.dlist_id;


--
-- Name: route; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE route (
    route_id bigint NOT NULL,
    route_direction_id bigint,
    route_step smallint,
    route_type character varying(8) DEFAULT 'trunk'::character varying NOT NULL,
    route_dest_id bigint NOT NULL,
    CONSTRAINT route_route_prio_check CHECK (((route_step >= 0) AND (route_step <= 5))),
    CONSTRAINT route_route_type_check CHECK ((((((route_type)::text = 'user'::text) OR ((route_type)::text = 'context'::text)) OR ((route_type)::text = 'trunk'::text)) OR ((route_type)::text = 'tgroup'::text)))
);


ALTER TABLE routing.route OWNER TO asterisk;

--
-- Name: TABLE route; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE route IS 'Таблица маршрутизации. 
Направление, приоритет, транк/группа/контекст, название.';


--
-- Name: COLUMN route.route_step; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON COLUMN route.route_step IS 'Шаг. Попытка. Обычно не более 5.';


--
-- Name: route_route_id_seq; Type: SEQUENCE; Schema: routing; Owner: asterisk
--

CREATE SEQUENCE route_route_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE routing.route_route_id_seq OWNER TO asterisk;

--
-- Name: route_route_id_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE route_route_id_seq OWNED BY route.route_id;


--
-- Name: trunkgroup_items; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE trunkgroup_items (
    tgrp_item_id bigint NOT NULL,
    tgrp_item_peer_id bigint NOT NULL,
    tgrp_item_group_id bigint NOT NULL
);


ALTER TABLE routing.trunkgroup_items OWNER TO asterisk;

--
-- Name: TABLE trunkgroup_items; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE trunkgroup_items IS 'Взяимосвязь между trunkgroups && sip_peers';


--
-- Name: trunkgroup_items_tgrp_item_id_seq; Type: SEQUENCE; Schema: routing; Owner: asterisk
--

CREATE SEQUENCE trunkgroup_items_tgrp_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE routing.trunkgroup_items_tgrp_item_id_seq OWNER TO asterisk;

--
-- Name: trunkgroup_items_tgrp_item_id_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE trunkgroup_items_tgrp_item_id_seq OWNED BY trunkgroup_items.tgrp_item_id;


--
-- Name: trunkgroups; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE trunkgroups (
    tgrp_id bigint NOT NULL,
    tgrp_name character varying(32) NOT NULL,
    tgrp_last_used_trunk bigint
);


ALTER TABLE routing.trunkgroups OWNER TO asterisk;

--
-- Name: TABLE trunkgroups; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE trunkgroups IS 'Список транкгрупп';


--
-- Name: COLUMN trunkgroups.tgrp_last_used_trunk; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON COLUMN trunkgroups.tgrp_last_used_trunk IS 'Идентификатор последнего использованного транка. trunk_id';


--
-- Name: trunkgroups_tgrp_id_seq; Type: SEQUENCE; Schema: routing; Owner: asterisk
--

CREATE SEQUENCE trunkgroups_tgrp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE routing.trunkgroups_tgrp_id_seq OWNER TO asterisk;

--
-- Name: trunkgroups_tgrp_id_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE trunkgroups_tgrp_id_seq OWNED BY trunkgroups.tgrp_id;


SET search_path = public, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE sip_peers ALTER COLUMN id SET DEFAULT nextval('sip_peers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE sip_users ALTER COLUMN id SET DEFAULT nextval('sip_users_id_seq'::regclass);


SET search_path = routing, pg_catalog;

--
-- Name: dr_id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE directions ALTER COLUMN dr_id SET DEFAULT nextval('directions_dr_id_seq'::regclass);


--
-- Name: dlist_id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE directions_list ALTER COLUMN dlist_id SET DEFAULT nextval('"directions_list_DLIST_ID_seq"'::regclass);


--
-- Name: route_id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE route ALTER COLUMN route_id SET DEFAULT nextval('route_route_id_seq'::regclass);


--
-- Name: tgrp_item_id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE trunkgroup_items ALTER COLUMN tgrp_item_id SET DEFAULT nextval('trunkgroup_items_tgrp_item_id_seq'::regclass);


--
-- Name: tgrp_id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE trunkgroups ALTER COLUMN tgrp_id SET DEFAULT nextval('trunkgroups_tgrp_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- Name: sip_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY sip_peers
    ADD CONSTRAINT sip_peers_pkey PRIMARY KEY (id);


--
-- Name: sip_users_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY sip_users
    ADD CONSTRAINT sip_users_pkey PRIMARY KEY (id);


SET search_path = routing, pg_catalog;

--
-- Name: DLIST_PK; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY directions_list
    ADD CONSTRAINT "DLIST_PK" PRIMARY KEY (dlist_id);


--
-- Name: DLIST_UNIQ_NAME; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY directions_list
    ADD CONSTRAINT "DLIST_UNIQ_NAME" UNIQUE (dlist_name);


--
-- Name: dr_pk; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY directions
    ADD CONSTRAINT dr_pk PRIMARY KEY (dr_id);


--
-- Name: route_pkey; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY route
    ADD CONSTRAINT route_pkey PRIMARY KEY (route_id);


--
-- Name: tgrp_name_uniq; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY trunkgroups
    ADD CONSTRAINT tgrp_name_uniq UNIQUE (tgrp_name);


--
-- Name: tgrp_pkey; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY trunkgroups
    ADD CONSTRAINT tgrp_pkey PRIMARY KEY (tgrp_id);


--
-- Name: trunkgroup_items_pkey; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY trunkgroup_items
    ADD CONSTRAINT trunkgroup_items_pkey PRIMARY KEY (tgrp_item_id);


SET search_path = public, pg_catalog;

--
-- Name: sip_peers_name; Type: INDEX; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE UNIQUE INDEX sip_peers_name ON sip_peers USING btree (name);


--
-- Name: sip_users_name; Type: INDEX; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE UNIQUE INDEX sip_users_name ON sip_users USING btree (name);


SET search_path = routing, pg_catalog;

--
-- Name: fki_dr_name; Type: INDEX; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE INDEX fki_dr_name ON directions USING btree (dr_list_item);


--
-- Name: fki_tgrp_item_fk; Type: INDEX; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE INDEX fki_tgrp_item_fk ON trunkgroup_items USING btree (tgrp_item_peer_id);


--
-- Name: fki_tgrp_item_group; Type: INDEX; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE INDEX fki_tgrp_item_group ON trunkgroup_items USING btree (tgrp_item_group_id);


--
-- Name: route_check_dest_id; Type: TRIGGER; Schema: routing; Owner: asterisk
--

CREATE TRIGGER route_check_dest_id BEFORE INSERT OR UPDATE ON route FOR EACH ROW EXECUTE PROCEDURE route_test();


--
-- Name: dr_name; Type: FK CONSTRAINT; Schema: routing; Owner: asterisk
--

ALTER TABLE ONLY directions
    ADD CONSTRAINT dr_name FOREIGN KEY (dr_list_item) REFERENCES directions_list(dlist_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: route_route_direction_id_fkey; Type: FK CONSTRAINT; Schema: routing; Owner: asterisk
--

ALTER TABLE ONLY route
    ADD CONSTRAINT route_route_direction_id_fkey FOREIGN KEY (route_direction_id) REFERENCES directions_list(dlist_id);


--
-- Name: tgrp_item_fk; Type: FK CONSTRAINT; Schema: routing; Owner: asterisk
--

ALTER TABLE ONLY trunkgroup_items
    ADD CONSTRAINT tgrp_item_fk FOREIGN KEY (tgrp_item_peer_id) REFERENCES public.sip_peers(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: tgrp_item_group; Type: FK CONSTRAINT; Schema: routing; Owner: asterisk
--

ALTER TABLE ONLY trunkgroup_items
    ADD CONSTRAINT tgrp_item_group FOREIGN KEY (tgrp_item_group_id) REFERENCES trunkgroups(tgrp_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


set search_path to public; 

CREATE TABLE blacklist (
    id bigserial NOT NULL,
    number character(20) NOT NULL,
    reason character varying(255) DEFAULT NULL::character varying,
    create_date timestamp without time zone DEFAULT now()
);

CREATE TABLE whitelist (
    id bigserial NOT NULL,
    number character(20) NOT NULL,
    reason character varying(255) DEFAULT NULL::character varying,
    create_date timestamp without time zone DEFAULT now()
);

ALTER TABLE public.blacklist OWNER TO asterisk;
ALTER TABLE public.whitelist OWNER TO asterisk;


CREATE TABLE cdr (
    calldate timestamp with time zone DEFAULT now() NOT NULL,
    clid character varying(80) DEFAULT ''::character varying NOT NULL,
    src character varying(80) DEFAULT ''::character varying NOT NULL,
    dst character varying(80) DEFAULT ''::character varying NOT NULL,
    dcontext character varying(80) DEFAULT ''::character varying NOT NULL,
    channel character varying(80) DEFAULT ''::character varying NOT NULL,
    dstchannel character varying(80) DEFAULT ''::character varying NOT NULL,
    lastapp character varying(80) DEFAULT ''::character varying NOT NULL,
    lastdata character varying(80) DEFAULT ''::character varying NOT NULL,
    duration bigint DEFAULT (0)::bigint NOT NULL,
    billsec bigint DEFAULT (0)::bigint NOT NULL,
    disposition character varying(45) DEFAULT ''::character varying NOT NULL,
    amaflags bigint DEFAULT (0)::bigint NOT NULL,
    accountcode character varying(20) DEFAULT ''::character varying NOT NULL,
    uniqueid character varying(32) DEFAULT ''::character varying NOT NULL,
    userfield character varying(255) DEFAULT ''::character varying NOT NULL
);

CREATE INDEX cdr_calldate ON cdr USING btree (calldate);

ALTER TABLE public.cdr OWNER TO asterisk;


CREATE TABLE extensions_conf (
    id bigserial NOT NULL,
    context character varying(20) DEFAULT ''::character varying NOT NULL,
    exten character varying(20) DEFAULT ''::character varying NOT NULL,
    priority smallint DEFAULT 0 NOT NULL,
    app character varying(20) DEFAULT ''::character varying NOT NULL,
    appdata character varying(128)
);


ALTER TABLE public.extensions_conf OWNER TO asterisk;
-- Name: queue_log; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE queue_log (
    id bigserial NOT NULL,
    callid character varying(32),
    queuename character varying(32),
    agent character varying(32),
    event character varying(32),
    data character varying(255),
    "time" timestamp without time zone
);


ALTER TABLE public.queue_log OWNER TO asterisk;

--
-- Name: queue_parsed; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE queue_parsed (
    id bigserial NOT NULL,
    callid character varying(32) DEFAULT ''::character varying NOT NULL,
    queue character varying(32) DEFAULT 'default'::character varying NOT NULL,
    "time" timestamp without time zone NOT NULL,
    callerid character varying(32) DEFAULT ''::character varying NOT NULL,
    agentid character varying(32) DEFAULT ''::character varying NOT NULL,
    status character varying(32) DEFAULT ''::character varying NOT NULL,
    success integer DEFAULT 0 NOT NULL,
    holdtime integer DEFAULT 0 NOT NULL,
    calltime integer DEFAULT 0 NOT NULL,
    "position" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.queue_parsed OWNER TO asterisk;



--
-- PostgreSQL database dump complete
--
