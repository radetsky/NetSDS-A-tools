--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = routing, pg_catalog;

ALTER TABLE ONLY routing.trunkgroup_items DROP CONSTRAINT tgrp_item_group;
ALTER TABLE ONLY routing.trunkgroup_items DROP CONSTRAINT tgrp_item_fk;
ALTER TABLE ONLY routing.route DROP CONSTRAINT route_route_direction_id_fkey;
ALTER TABLE ONLY routing.permissions DROP CONSTRAINT fk_direction_in_dlist;
ALTER TABLE ONLY routing.directions DROP CONSTRAINT dr_name;
DROP TRIGGER route_check_dest_id ON routing.route;
DROP INDEX routing.fki_tgrp_item_group;
DROP INDEX routing.fki_tgrp_item_fk;
DROP INDEX routing.fki_dr_name;
DROP INDEX routing.fki_direction_in_dlist;
SET search_path = public, pg_catalog;

DROP INDEX public.sip_peers_name;
DROP INDEX public.queue_uniq;
DROP INDEX public.cdr_calldate;
SET search_path = routing, pg_catalog;

ALTER TABLE ONLY routing.trunkgroup_items DROP CONSTRAINT trunkgroup_items_pkey;
ALTER TABLE ONLY routing.trunkgroups DROP CONSTRAINT tgrp_pkey;
ALTER TABLE ONLY routing.trunkgroups DROP CONSTRAINT tgrp_name_uniq;
ALTER TABLE ONLY routing.route DROP CONSTRAINT route_pkey;
ALTER TABLE ONLY routing.permissions DROP CONSTRAINT permissions_pkey;
ALTER TABLE ONLY routing.directions DROP CONSTRAINT dr_pk;
ALTER TABLE ONLY routing.directions_list DROP CONSTRAINT "DLIST_UNIQ_NAME";
ALTER TABLE ONLY routing.directions_list DROP CONSTRAINT "DLIST_PK";
SET search_path = public, pg_catalog;

ALTER TABLE ONLY public.sip_peers DROP CONSTRAINT sip_peers_pkey;
ALTER TABLE ONLY public.sip_conf DROP CONSTRAINT sip_conf_pkey;
ALTER TABLE ONLY public.queues DROP CONSTRAINT queues_pkey;
ALTER TABLE ONLY public.queue_members DROP CONSTRAINT queue_members_pkey;
ALTER TABLE ONLY public.extensions_conf DROP CONSTRAINT extensions_conf_pkey;
SET search_path = routing, pg_catalog;

SET search_path = public, pg_catalog;

SET search_path = routing, pg_catalog;

ALTER TABLE routing.trunkgroups ALTER COLUMN tgrp_id DROP DEFAULT;
ALTER TABLE routing.trunkgroup_items ALTER COLUMN tgrp_item_id DROP DEFAULT;
ALTER TABLE routing.route ALTER COLUMN route_id DROP DEFAULT;
ALTER TABLE routing.permissions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE routing.directions_list ALTER COLUMN dlist_id DROP DEFAULT;
ALTER TABLE routing.directions ALTER COLUMN dr_id DROP DEFAULT;
SET search_path = public, pg_catalog;

ALTER TABLE public.whitelist ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.sip_peers ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.sip_conf ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.queue_parsed ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.queue_members ALTER COLUMN uniqueid DROP DEFAULT;
ALTER TABLE public.queue_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.extensions_conf ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.blacklist ALTER COLUMN id DROP DEFAULT;
SET search_path = routing, pg_catalog;

DROP SEQUENCE routing.trunkgroups_tgrp_id_seq;
DROP TABLE routing.trunkgroups;
DROP SEQUENCE routing.trunkgroup_items_tgrp_item_id_seq;
DROP TABLE routing.trunkgroup_items;
DROP SEQUENCE routing.route_route_id_seq;
DROP TABLE routing.route;
DROP SEQUENCE routing.permissions_id_seq;
DROP TABLE routing.permissions;
DROP SEQUENCE routing."directions_list_DLIST_ID_seq";
DROP TABLE routing.directions_list;
DROP SEQUENCE routing.directions_dr_id_seq;
DROP TABLE routing.directions;
SET search_path = public, pg_catalog;

DROP SEQUENCE public.whitelist_id_seq;
DROP TABLE public.whitelist;
DROP SEQUENCE public.sip_peers_id_seq;
DROP TABLE public.sip_peers;
DROP SEQUENCE public.sip_conf_id_seq;
DROP TABLE public.sip_conf;
DROP TABLE public.queues;
DROP SEQUENCE public.queue_parsed_id_seq;
DROP TABLE public.queue_parsed;
DROP SEQUENCE public.queue_members_uniqueid_seq;
DROP TABLE public.queue_members;
DROP SEQUENCE public.queue_log_id_seq;
DROP TABLE public.queue_log;
DROP SEQUENCE public.extensions_conf_id_seq;
DROP TABLE public.extensions_conf;
DROP TABLE public.cdr;
DROP SEQUENCE public.blacklist_id_seq;
DROP TABLE public.blacklist;
SET search_path = routing, pg_catalog;

DROP FUNCTION routing.route_test();
DROP FUNCTION routing.get_permission(peer_name character varying, number_b character varying);
DROP FUNCTION routing.get_next_trunk_in_group(group_id bigint);
DROP FUNCTION routing.get_dial_route3(exten character varying, current_try integer);
DROP FUNCTION routing.get_dial_route(destination character varying, try integer);
SET search_path = public, pg_catalog;

DROP FUNCTION public.uuid_ns_x500();
DROP FUNCTION public.uuid_ns_url();
DROP FUNCTION public.uuid_ns_oid();
DROP FUNCTION public.uuid_ns_dns();
DROP FUNCTION public.uuid_nil();
DROP FUNCTION public.uuid_generate_v5(namespace uuid, name text);
DROP FUNCTION public.uuid_generate_v4();
DROP FUNCTION public.uuid_generate_v3(namespace uuid, name text);
DROP FUNCTION public.uuid_generate_v1mc();
DROP FUNCTION public.uuid_generate_v1();
DROP PROCEDURAL LANGUAGE plpgsql;
DROP SCHEMA users;
DROP SCHEMA routing;
DROP SCHEMA public;
DROP SCHEMA ivr;
--
-- Name: ivr; Type: SCHEMA; Schema: -; Owner: asterisk
--

CREATE SCHEMA ivr;


ALTER SCHEMA ivr OWNER TO asterisk;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


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
--
-- Try to find direction by prefix;
-- 
select * into dir from routing.directions 
	where $1 ~ dr_prefix 
	order by dr_prio 
	asc 
	limit 1; 

if not found then 
	raise exception 'NO DIRECTION';
end if; 
--
-- Try to find route record that will give us type and destination id.
--
select * into r from routing.route 
	where route_direction_id = dir.dr_list_item 
	and route_step = $2  
	order by route_step asc limit 1; 

if not found then 
	raise exception 'NO ROUTE';
end if; 

-- Try to find destination id and name; 
-- case route_type (user) 
if r.route_type = 'user' then 
	select name into rname from public.sip_users where id=r.route_dest_id; 
	if not found then 
		raise exception 'NO DESTINATION'; 
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
		raise exception 'NO DESTINATION'; 
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
-- Name: get_dial_route3(character varying, integer); Type: FUNCTION; Schema: routing; Owner: asterisk
--

CREATE FUNCTION get_dial_route3(exten character varying, current_try integer) RETURNS TABLE(dst_str character varying, dst_type character varying, try integer)
    LANGUAGE plpgsql
    AS $_$
declare

dir routing.directions%ROWTYPE;
r routing.route%ROWTYPE;
rname varchar(32);
trunk_id bigint; 

begin
--
-- Try to find direction by prefix;
-- 
select * into dir from routing.directions 
	where $1 ~ dr_prefix 
	order by dr_prio 
	asc 
	limit 1; 

if not found then 
	raise exception 'NO DIRECTION';
end if; 
--
-- Try to find route record that will give us type and destination id.
--
select * into r from routing.route 
	where route_direction_id = dir.dr_list_item 
	and route_step = $2  
	order by route_step asc limit 1; 

if not found then 
	raise exception 'NO ROUTE';
end if; 

dst_type = r.route_type;
try = current_try; 

-- Try to find destination id and name; 
-- case route_type (user) 
if r.route_type = 'user' then 
	select name into dst_str from public.sip_peers where id=r.route_dest_id; 
	if not found then 
		raise exception 'NO DESTINATION'; 
	end if; 
	
	return next;
	return;
end if; 
-- case route_type (trunk) 
if r.route_type = 'trunk' then 
	select name into dst_str from public.sip_peers where id=r.route_dest_id; 
	if not found then 
		raise exception 'NO DESTINATION'; 
	end if;
	return next;
	return;
end if; 

-- case route_type (context) 
if r.route_type = 'context' then 
	select context into dst_str from public.extensions_conf where id=r.route_dest_id; 
	if not found then 
		raise exception 'NO DESTINATION'; 
	end if; 
	return next; 
	return; 
end if; 

-- case route_type (trunkgroup) 
if r.route_type = 'tgrp' then 
-- находим последний транк в группе, который был заюзан крайний раз.
-- и уменьшаем кол-во попыток на -1 , что бы снова вернутся к группе. 
-- ВОПРОС: а как же определить заканчивание цикла ?  
-- ОТВЕТ: в перле. 
	try = current_try - 1; 
	select get_next_trunk_in_group into trunk_id from routing.get_next_trunk_in_group (r.route_dest_id);
	if trunk_id < 0 then 
		raise exception 'NO DESTINATION IN GROUP'; 
	end if; 

	select name into dst_str from public.sip_peers where id=trunk_id; 
	if not found then 
		raise exception 'NO DESTINATION'; 
	end if;
	return next;
	return;

end if; 
RAISE EXCEPTION 'This is the end. Some situation can not be handled.';
return;

end
$_$;


ALTER FUNCTION routing.get_dial_route3(exten character varying, current_try integer) OWNER TO asterisk;

--
-- Name: get_next_trunk_in_group(bigint); Type: FUNCTION; Schema: routing; Owner: asterisk
--

CREATE FUNCTION get_next_trunk_in_group(group_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
declare 

trunk_id bigint;
new_id bigint; 

begin 

-- Получаем последний занятый. Его надо обновить на свободный.

select tgrp_item_peer_id into trunk_id 
	from routing.trunkgroup_items 
	where tgrp_item_group_id = $1 
	and tgrp_item_last is true 
	order by tgrp_item_peer_id 
	asc limit 1 
	for update;

if not found then 
	select tgrp_item_peer_id into trunk_id 
		from routing.trunkgroup_items
		where tgrp_item_group_id = $1 
		order by tgrp_item_peer_id 
		asc limit 1 
		for update; 
-- Если в группе вообще ничего нет, то ошибка.
	if not found then 
		return -1; 
	end if; 
-- Если есть. Занимаем первый транк.
	update routing.trunkgroup_items 
		set tgrp_item_last=true 
		where tgrp_item_group_id = $1 
		and tgrp_item_peer_id = trunk_id; 
	return trunk_id; 

else 
-- У нас есть trunk_id. Ищем сначала следующий. 
	select tgrp_item_peer_id into new_id 
		from routing.trunkgroup_items 
		where tgrp_item_group_id = $1 
		and tgrp_item_peer_id > trunk_id  
		order by tgrp_item_peer_id 
		asc limit 1 
		for update;
-- Если не нашел, ищем с начала списка 
	if not found then 
		select tgrp_item_peer_id into new_id 
			from routing.trunkgroup_items 
			where tgrp_item_group_id = $1 
			and tgrp_item_peer_id < trunk_id  
			order by tgrp_item_peer_id 
			asc limit 1 
			for update;	
-- Если не нашел и сначала, то ошибка. В группе только 1(один!) транк. 
		if not found then 
			return -1; 
		end if; 

	end if; 
--Обновляем на "свободный" бывший занятый транк.
	update routing.trunkgroup_items 
		set tgrp_item_last=false
		where tgrp_item_group_id = $1 
		and tgrp_item_peer_id = trunk_id; 
-- Занимаем следующий транк 
	update routing.trunkgroup_items 
		set tgrp_item_last=true
		where tgrp_item_group_id = $1 
		and tgrp_item_peer_id = new_id; 

	return new_id; 
end if; 

end;
$_$;


ALTER FUNCTION routing.get_next_trunk_in_group(group_id bigint) OWNER TO asterisk;

--
-- Name: FUNCTION get_next_trunk_in_group(group_id bigint); Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON FUNCTION get_next_trunk_in_group(group_id bigint) IS 'Возвращает следующий транк в группе. Если дошли по циклу или ошибка, то возвращает -1. ';


--
-- Name: get_permission(character varying, character varying); Type: FUNCTION; Schema: routing; Owner: asterisk
--

CREATE FUNCTION get_permission(peer_name character varying, number_b character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
declare 

UID bigint;
DIR_ID bigint; 

begin

--
-- we getting UID 
--

select id from public.sip_peers where name=$1 into UID;
if not found then 
	raise exception 'NO SOURCE PEER/USER BY CHANNEL';
end if; 

--
-- gettting direction_id by number_b
-- 

select dr_list_item into DIR_ID from routing.directions 
	where $2 ~ dr_prefix 
	order by dr_prio 
	asc 
	limit 1; 

if not found then 
	raise exception 'NO DESTINATION BY NUMBER_B'; 
end if; 



perform id from routing.permissions 
	where direction_id=DIR_ID 
	and peer_id=UID;
	
if not found then 
	return false; 
end if; 

return true; 

end;

--
-- Функция завершена 30.11.11
-- Модификация 09.12.11 (убрали u_type и проверку по типу прав peer/user)
--
$_$;


ALTER FUNCTION routing.get_permission(peer_name character varying, number_b character varying) OWNER TO asterisk;

--
-- Name: FUNCTION get_permission(peer_name character varying, number_b character varying); Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON FUNCTION get_permission(peer_name character varying, number_b character varying) IS 'Процедура получения прав доступа на текущий звонок с номера А (канала А) на номер Б (направление Б). Исходные данные: 
- обрезанное имя канала (SIP/kyivstar-000001 = kyivstar), 
- номер Б 

Задача: 
1. найти указанное направление по номеру Б. 
2. Получить хотя бы одну запись из таблицы permissions. 

Тогда право есть. Иначе - permission denied and get out :-) ';


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
	perform  id from public.sip_peers where id=NEW.route_dest_id; 
	if not found then 
		raise exception 'sip user not found with same id';
	end if; 
end if;
if NEW.route_type = 'context' then 
	perform id from public.extensions_conf where id=NEW.route_dest_id; 
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
-- Name: blacklist; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE blacklist (
    id bigint NOT NULL,
    number character(20) NOT NULL,
    reason character varying(255) DEFAULT NULL::character varying,
    create_date timestamp without time zone DEFAULT now()
);


ALTER TABLE public.blacklist OWNER TO asterisk;

--
-- Name: blacklist_id_seq; Type: SEQUENCE; Schema: public; Owner: asterisk
--

CREATE SEQUENCE blacklist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blacklist_id_seq OWNER TO asterisk;

--
-- Name: blacklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE blacklist_id_seq OWNED BY blacklist.id;


--
-- Name: blacklist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('blacklist_id_seq', 1, false);


--
-- Name: cdr; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

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


ALTER TABLE public.cdr OWNER TO asterisk;

--
-- Name: extensions_conf; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE extensions_conf (
    id bigint NOT NULL,
    context character varying(20) DEFAULT ''::character varying NOT NULL,
    exten character varying(20) DEFAULT ''::character varying NOT NULL,
    priority smallint DEFAULT 0 NOT NULL,
    app character varying(20) DEFAULT ''::character varying NOT NULL,
    appdata character varying(128)
);


ALTER TABLE public.extensions_conf OWNER TO asterisk;

--
-- Name: extensions_conf_id_seq; Type: SEQUENCE; Schema: public; Owner: asterisk
--

CREATE SEQUENCE extensions_conf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.extensions_conf_id_seq OWNER TO asterisk;

--
-- Name: extensions_conf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE extensions_conf_id_seq OWNED BY extensions_conf.id;


--
-- Name: extensions_conf_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('extensions_conf_id_seq', 4, true);


--
-- Name: queue_log; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE queue_log (
    id bigint NOT NULL,
    callid character varying(32),
    queuename character varying(32),
    agent character varying(32),
    event character varying(32),
    data character varying(255),
    "time" timestamp without time zone
);


ALTER TABLE public.queue_log OWNER TO asterisk;

--
-- Name: queue_log_id_seq; Type: SEQUENCE; Schema: public; Owner: asterisk
--

CREATE SEQUENCE queue_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.queue_log_id_seq OWNER TO asterisk;

--
-- Name: queue_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE queue_log_id_seq OWNED BY queue_log.id;


--
-- Name: queue_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('queue_log_id_seq', 1, false);


--
-- Name: queue_members; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE queue_members (
    uniqueid bigint NOT NULL,
    membername character varying,
    queue_name character varying,
    interface character varying,
    penalty integer,
    paused integer
);


ALTER TABLE public.queue_members OWNER TO asterisk;

--
-- Name: queue_members_uniqueid_seq; Type: SEQUENCE; Schema: public; Owner: asterisk
--

CREATE SEQUENCE queue_members_uniqueid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.queue_members_uniqueid_seq OWNER TO asterisk;

--
-- Name: queue_members_uniqueid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE queue_members_uniqueid_seq OWNED BY queue_members.uniqueid;


--
-- Name: queue_members_uniqueid_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('queue_members_uniqueid_seq', 1, false);


--
-- Name: queue_parsed; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE queue_parsed (
    id bigint NOT NULL,
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
-- Name: queue_parsed_id_seq; Type: SEQUENCE; Schema: public; Owner: asterisk
--

CREATE SEQUENCE queue_parsed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.queue_parsed_id_seq OWNER TO asterisk;

--
-- Name: queue_parsed_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE queue_parsed_id_seq OWNED BY queue_parsed.id;


--
-- Name: queue_parsed_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('queue_parsed_id_seq', 1, false);


--
-- Name: queues; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE queues (
    name character varying NOT NULL,
    musiconhold character varying DEFAULT 'default'::character varying NOT NULL,
    announce character varying,
    context character varying,
    timeout integer DEFAULT 0,
    monitor_format character varying DEFAULT 'wav'::character varying NOT NULL,
    queue_youarenext character varying,
    queue_thereare character varying,
    queue_callswaiting character varying,
    queue_holdtime character varying,
    queue_minutes character varying,
    queue_seconds character varying,
    queue_lessthan character varying,
    queue_thankyou character varying,
    queue_reporthold character varying,
    retry integer DEFAULT 2,
    wrapuptime integer DEFAULT 30,
    maxlen integer DEFAULT 10,
    servicelevel integer DEFAULT 0,
    strategy character varying DEFAULT 'ringall'::character varying NOT NULL,
    joinempty character varying DEFAULT 'no'::character varying NOT NULL,
    leavewhenempty character varying DEFAULT 'yes'::character varying NOT NULL,
    eventmemberstatus boolean DEFAULT true,
    eventwhencalled boolean DEFAULT true,
    reportholdtime boolean DEFAULT false,
    memberdelay integer DEFAULT 0,
    weight integer DEFAULT 0,
    timeoutrestart boolean DEFAULT false,
    periodic_announce character varying,
    periodic_announce_frequency integer,
    ringinuse boolean DEFAULT false,
    setinterfacevar boolean DEFAULT true,
    "monitor-type" character varying DEFAULT 'mixmonitor'::character varying NOT NULL
);


ALTER TABLE public.queues OWNER TO asterisk;

--
-- Name: sip_conf; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE sip_conf (
    id bigint NOT NULL,
    cat_metric integer DEFAULT 0 NOT NULL,
    var_metric integer DEFAULT 0 NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    filename character varying DEFAULT ''::character varying NOT NULL,
    category character varying DEFAULT 'default'::character varying NOT NULL,
    var_name character varying DEFAULT ''::character varying NOT NULL,
    var_val character varying DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.sip_conf OWNER TO asterisk;

--
-- Name: sip_conf_id_seq; Type: SEQUENCE; Schema: public; Owner: asterisk
--

CREATE SEQUENCE sip_conf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sip_conf_id_seq OWNER TO asterisk;

--
-- Name: sip_conf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE sip_conf_id_seq OWNED BY sip_conf.id;


--
-- Name: sip_conf_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('sip_conf_id_seq', 29, true);


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
    insecure character varying,
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
    lastms character varying(5) DEFAULT '0'::character varying,
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
-- Name: sip_peers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('sip_peers_id_seq', 58, true);


--
-- Name: whitelist; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE whitelist (
    id bigint NOT NULL,
    number character(20) NOT NULL,
    reason character varying(255) DEFAULT NULL::character varying,
    create_date timestamp without time zone DEFAULT now()
);


ALTER TABLE public.whitelist OWNER TO asterisk;

--
-- Name: whitelist_id_seq; Type: SEQUENCE; Schema: public; Owner: asterisk
--

CREATE SEQUENCE whitelist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.whitelist_id_seq OWNER TO asterisk;

--
-- Name: whitelist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE whitelist_id_seq OWNED BY whitelist.id;


--
-- Name: whitelist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('whitelist_id_seq', 1, false);


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
-- Name: directions_dr_id_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('directions_dr_id_seq', 10, true);


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
-- Name: directions_list_DLIST_ID_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('"directions_list_DLIST_ID_seq"', 4, true);


--
-- Name: permissions; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE permissions (
    id bigint NOT NULL,
    direction_id bigint,
    peer_id bigint,
    peer_type character varying(4) DEFAULT "current_user"() NOT NULL
);


ALTER TABLE routing.permissions OWNER TO asterisk;

--
-- Name: TABLE permissions; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE permissions IS 'Права доступа к разным направлениям для peers/users. ';


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: routing; Owner: asterisk
--

CREATE SEQUENCE permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE routing.permissions_id_seq OWNER TO asterisk;

--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE permissions_id_seq OWNED BY permissions.id;


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('permissions_id_seq', 7, true);


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
    CONSTRAINT route_type_check CHECK ((((((route_type)::text = 'user'::text) OR ((route_type)::text = 'context'::text)) OR ((route_type)::text = 'trunk'::text)) OR ((route_type)::text = 'tgrp'::text)))
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
-- Name: route_route_id_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('route_route_id_seq', 11, true);


--
-- Name: trunkgroup_items; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE trunkgroup_items (
    tgrp_item_id bigint NOT NULL,
    tgrp_item_peer_id bigint NOT NULL,
    tgrp_item_group_id bigint NOT NULL,
    tgrp_item_last boolean DEFAULT false
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
-- Name: trunkgroup_items_tgrp_item_id_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('trunkgroup_items_tgrp_item_id_seq', 4, true);


--
-- Name: trunkgroups; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE trunkgroups (
    tgrp_id bigint NOT NULL,
    tgrp_name character varying(32) NOT NULL
);


ALTER TABLE routing.trunkgroups OWNER TO asterisk;

--
-- Name: TABLE trunkgroups; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE trunkgroups IS 'Список транкгрупп';


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


--
-- Name: trunkgroups_tgrp_id_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('trunkgroups_tgrp_id_seq', 1, true);


SET search_path = public, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE blacklist ALTER COLUMN id SET DEFAULT nextval('blacklist_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE extensions_conf ALTER COLUMN id SET DEFAULT nextval('extensions_conf_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE queue_log ALTER COLUMN id SET DEFAULT nextval('queue_log_id_seq'::regclass);


--
-- Name: uniqueid; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE queue_members ALTER COLUMN uniqueid SET DEFAULT nextval('queue_members_uniqueid_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE queue_parsed ALTER COLUMN id SET DEFAULT nextval('queue_parsed_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE sip_conf ALTER COLUMN id SET DEFAULT nextval('sip_conf_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE sip_peers ALTER COLUMN id SET DEFAULT nextval('sip_peers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE whitelist ALTER COLUMN id SET DEFAULT nextval('whitelist_id_seq'::regclass);


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
-- Name: id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE permissions ALTER COLUMN id SET DEFAULT nextval('permissions_id_seq'::regclass);


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
-- Data for Name: blacklist; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY blacklist (id, number, reason, create_date) FROM stdin;
\.


--
-- Data for Name: cdr; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY cdr (calldate, clid, src, dst, dcontext, channel, dstchannel, lastapp, lastdata, duration, billsec, disposition, amaflags, accountcode, uniqueid, userfield) FROM stdin;
2011-12-10 01:02:15+02	"Alex Radetsky" <1003>	1003	201	default	SIP/t_express-0000000b	SIP/201-0000000c	Dial	SIP/201|120|rtT	5	0	NO ANSWER	3		1323471735.11	
2011-12-12 13:43:23+02	"Alex Radetsky" <1003>	1003	200	default	SIP/t_express-0000001b	SIP/t_express-0000001c	Hangup	17	0	0	FAILED	3		1323690203.27	
2011-12-12 17:04:18+02	"Im Phone" <201>	201	3039338	default	SIP/201-00000021	SIP/t_express-00000022	Hangup	17	0	0	FAILED	3		1323702258.33	
2011-12-12 17:06:34+02	"Im Phone" <201>	201	3039338	default	SIP/201-00000023	SIP/t_express-00000024	Dial	SIP/t_express/3039338|120|rtTg	5	4	ANSWERED	3		1323702394.35	
2011-12-09 23:59:55+02	"Alex Radetsky" <1003>	1003	201	default	SIP/t_express-00000008	SIP/201-00000009	Dial	SIP/201|120|rtT	6	0	NO ANSWER	3		1323467995.8	
\.


--
-- Data for Name: extensions_conf; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY extensions_conf (id, context, exten, priority, app, appdata) FROM stdin;
3	default	_X!	3	Hangup	17
2	default	_X!	2	NoOp	60
1	default	_X!	1	AGI	NetSDS-route.pl|${CHANNEL}|${EXTEN}
4	express	_X!	1	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl
\.


--
-- Data for Name: queue_log; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY queue_log (id, callid, queuename, agent, event, data, "time") FROM stdin;
\.


--
-- Data for Name: queue_members; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY queue_members (uniqueid, membername, queue_name, interface, penalty, paused) FROM stdin;
\.


--
-- Data for Name: queue_parsed; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY queue_parsed (id, callid, queue, "time", callerid, agentid, status, success, holdtime, calltime, "position") FROM stdin;
\.


--
-- Data for Name: queues; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY queues (name, musiconhold, announce, context, timeout, monitor_format, queue_youarenext, queue_thereare, queue_callswaiting, queue_holdtime, queue_minutes, queue_seconds, queue_lessthan, queue_thankyou, queue_reporthold, retry, wrapuptime, maxlen, servicelevel, strategy, joinempty, leavewhenempty, eventmemberstatus, eventwhencalled, reportholdtime, memberdelay, weight, timeoutrestart, periodic_announce, periodic_announce_frequency, ringinuse, setinterfacevar, "monitor-type") FROM stdin;
rad	default	\N	\N	0	wav	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	30	10	0	ringall	no	yes	t	t	f	0	0	f	\N	\N	f	t	mixmonitor
\.


--
-- Data for Name: sip_conf; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY sip_conf (id, cat_metric, var_metric, commented, filename, category, var_name, var_val) FROM stdin;
20	0	0	0	sip.conf	general	context	default
21	0	1	0	sip.conf	general	allowoverlap	no
22	0	2	0	sip.conf	general	bindport	5060
23	0	3	0	sip.conf	general	bindaddr	0.0.0.0
24	0	4	0	sip.conf	general	srvlookup	yes
25	0	5	0	sip.conf	general	register	t_express:t_wsedr21W@telco.netstyle.com.ua/5060
26	0	6	0	sip.conf	general	rtcachefriends	yes
27	0	7	0	sip.conf	general	rtsavesysname	yes
28	0	8	0	sip.conf	general	rtupdate	yes
29	0	9	0	sip.conf	general	rtautoclear	yes
\.


--
-- Data for Name: sip_peers; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY sip_peers (id, name, accountcode, amaflags, callgroup, callerid, canreinvite, directmedia, context, defaultip, dtmfmode, fromuser, fromdomain, host, insecure, language, mailbox, md5secret, nat, permit, deny, mask, pickupgroup, port, qualify, restrictcid, rtptimeout, rtpholdtimeout, secret, type, username, disallow, allow, musiconhold, regseconds, ipaddr, regexten, cancallforward, comment, "call-limit", lastms, regserver, fullcontact, useragent, defaultuser) FROM stdin;
1	kyivstar	\N	\N	\N	\N	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N
2	gsm1	\N	\N	\N	\N	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N
3	gsm2	\N	\N	\N	\N	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N
4	gsm3	\N	\N	\N	\N	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N
56	t_express	\N	\N	\N	\N	no	yes	default	\N	rfc2833	\N	\N	193.193.194.6	port,invite	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	t_wsedr21W	friend	t_express	all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N
58	202	\N	\N	\N	\N	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	WhiteBlack	friend	202	all	ulaw,alaw	\N	0			yes		1	-1			\N	\N
57	201	\N	\N	\N	\N	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N	0	yes	\N	\N	\N	SuperPasswd	friend	201	all	ulaw,alaw	\N	1323708332	0.0.0.0		yes		1	68		sip:201@192.168.1.114:5060	\N	\N
\.


--
-- Data for Name: whitelist; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY whitelist (id, number, reason, create_date) FROM stdin;
\.


SET search_path = routing, pg_catalog;

--
-- Data for Name: directions; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

COPY directions (dr_id, dr_list_item, dr_prefix, dr_prio) FROM stdin;
1	1	^3039338$	5
7	2	^098	5
6	2	^097	5
4	2	^096	5
3	2	^067	5
8	3	^201$	5
9	4	^2391515$	5
10	1	^200$	5
\.


--
-- Data for Name: directions_list; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

COPY directions_list (dlist_id, dlist_name) FROM stdin;
1	Офис Нет Стайл
2	Киевстар
3	Dmitry Kruglikoff
4	taxi express
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

COPY permissions (id, direction_id, peer_id, peer_type) FROM stdin;
1	1	1	peer
2	2	1	user
3	3	58	user
4	3	56	peer
5	4	56	peer
6	1	56	peer
7	1	57	user
\.


--
-- Data for Name: route; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

COPY route (route_id, route_direction_id, route_step, route_type, route_dest_id) FROM stdin;
4	1	1	trunk	56
9	3	1	user	57
7	2	1	tgrp	1
11	4	1	context	4
\.


--
-- Data for Name: trunkgroup_items; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

COPY trunkgroup_items (tgrp_item_id, tgrp_item_peer_id, tgrp_item_group_id, tgrp_item_last) FROM stdin;
3	3	1	f
4	4	1	f
2	2	1	t
\.


--
-- Data for Name: trunkgroups; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

COPY trunkgroups (tgrp_id, tgrp_name) FROM stdin;
1	Группа трако
\.


SET search_path = public, pg_catalog;

--
-- Name: extensions_conf_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY extensions_conf
    ADD CONSTRAINT extensions_conf_pkey PRIMARY KEY (id);


--
-- Name: queue_members_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY queue_members
    ADD CONSTRAINT queue_members_pkey PRIMARY KEY (uniqueid);


--
-- Name: queues_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY queues
    ADD CONSTRAINT queues_pkey PRIMARY KEY (name);


--
-- Name: sip_conf_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY sip_conf
    ADD CONSTRAINT sip_conf_pkey PRIMARY KEY (id);


--
-- Name: sip_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY sip_peers
    ADD CONSTRAINT sip_peers_pkey PRIMARY KEY (id);


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
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


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
-- Name: cdr_calldate; Type: INDEX; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE INDEX cdr_calldate ON cdr USING btree (calldate);


--
-- Name: queue_uniq; Type: INDEX; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE UNIQUE INDEX queue_uniq ON queue_members USING btree (queue_name, interface);


--
-- Name: sip_peers_name; Type: INDEX; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE UNIQUE INDEX sip_peers_name ON sip_peers USING btree (name);


SET search_path = routing, pg_catalog;

--
-- Name: fki_direction_in_dlist; Type: INDEX; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE INDEX fki_direction_in_dlist ON permissions USING btree (direction_id);


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
-- Name: fk_direction_in_dlist; Type: FK CONSTRAINT; Schema: routing; Owner: asterisk
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT fk_direction_in_dlist FOREIGN KEY (direction_id) REFERENCES directions_list(dlist_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


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


--
-- PostgreSQL database dump complete
--

