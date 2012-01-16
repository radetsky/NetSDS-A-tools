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
ALTER TABLE ONLY routing.callerid DROP CONSTRAINT callerid_direction_id_fkey;
SET search_path = integration, pg_catalog;

ALTER TABLE ONLY integration.workplaces DROP CONSTRAINT workplaces_sip_id_fkey;
SET search_path = routing, pg_catalog;

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
ALTER TABLE ONLY routing.callerid DROP CONSTRAINT callerid_pkey;
ALTER TABLE ONLY routing.directions_list DROP CONSTRAINT "DLIST_UNIQ_NAME";
ALTER TABLE ONLY routing.directions_list DROP CONSTRAINT "DLIST_PK";
SET search_path = public, pg_catalog;

ALTER TABLE ONLY public.sip_peers DROP CONSTRAINT sip_peers_pkey;
ALTER TABLE ONLY public.sip_conf DROP CONSTRAINT sip_conf_pkey;
ALTER TABLE ONLY public.queues DROP CONSTRAINT queues_pkey;
ALTER TABLE ONLY public.queue_members DROP CONSTRAINT queue_members_pkey;
ALTER TABLE ONLY public.extensions_conf DROP CONSTRAINT extensions_conf_pkey;
SET search_path = integration, pg_catalog;

ALTER TABLE ONLY integration.workplaces DROP CONSTRAINT workplaces_pkey;
ALTER TABLE ONLY integration.recordings DROP CONSTRAINT recordings_pkey;
ALTER TABLE ONLY integration.ulines DROP CONSTRAINT "ULines_pkey";
SET search_path = routing, pg_catalog;

SET search_path = public, pg_catalog;

SET search_path = integration, pg_catalog;

SET search_path = routing, pg_catalog;

ALTER TABLE routing.trunkgroups ALTER COLUMN tgrp_id DROP DEFAULT;
ALTER TABLE routing.trunkgroup_items ALTER COLUMN tgrp_item_id DROP DEFAULT;
ALTER TABLE routing.route ALTER COLUMN route_id DROP DEFAULT;
ALTER TABLE routing.permissions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE routing.directions_list ALTER COLUMN dlist_id DROP DEFAULT;
ALTER TABLE routing.directions ALTER COLUMN dr_id DROP DEFAULT;
ALTER TABLE routing.callerid ALTER COLUMN id DROP DEFAULT;
SET search_path = public, pg_catalog;

ALTER TABLE public.whitelist ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.sip_peers ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.sip_conf ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.queue_parsed ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.queue_members ALTER COLUMN uniqueid DROP DEFAULT;
ALTER TABLE public.queue_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.extensions_conf ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.blacklist ALTER COLUMN id DROP DEFAULT;
SET search_path = integration, pg_catalog;

ALTER TABLE integration.workplaces ALTER COLUMN id DROP DEFAULT;
ALTER TABLE integration.recordings ALTER COLUMN id DROP DEFAULT;
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
DROP SEQUENCE routing.callerid_id_seq;
DROP TABLE routing.callerid;
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
SET search_path = integration, pg_catalog;

DROP SEQUENCE integration.workplaces_id_seq;
DROP TABLE integration.workplaces;
DROP TABLE integration.ulines;
DROP SEQUENCE integration.recordings_id_seq;
DROP TABLE integration.recordings;
SET search_path = routing, pg_catalog;

DROP FUNCTION routing.route_test();
DROP FUNCTION routing.get_permission(peer_name character varying, number_b character varying);
DROP FUNCTION routing.get_next_trunk_in_group(group_id bigint);
DROP FUNCTION routing.get_dial_route4(peername character varying, exten character varying, current_try integer);
DROP FUNCTION routing.get_dial_route3(exten character varying, current_try integer);
DROP FUNCTION routing.get_dial_route(destination character varying, try integer);
DROP FUNCTION routing.get_callerid(peer_name character varying, number_b character varying);
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
SET search_path = integration, pg_catalog;

DROP FUNCTION integration.get_free_uline();
DROP PROCEDURAL LANGUAGE plpgsql;
DROP SCHEMA routing;
DROP SCHEMA public;
DROP SCHEMA ivr;
DROP SCHEMA integration;
--
-- Name: integration; Type: SCHEMA; Schema: -; Owner: asterisk
--

CREATE SCHEMA integration;


ALTER SCHEMA integration OWNER TO asterisk;

--
-- Name: SCHEMA integration; Type: COMMENT; Schema: -; Owner: asterisk
--

COMMENT ON SCHEMA integration IS 'Сюда пишем всякие таблицы по интеграции и т.д. ';


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
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = integration, pg_catalog;

--
-- Name: get_free_uline(); Type: FUNCTION; Schema: integration; Owner: asterisk
--

CREATE FUNCTION get_free_uline() RETURNS integer
    LANGUAGE plpgsql
    AS $$declare 

UID integer; 

begin 

select id into UID from integration.ulines 
	where status='free' 
	order by id asc limit 1
	for update; 
if not found then 
	raise exception 'ALL LINES BUSY'; 
end if; 

return UID; 

end;
$$;


ALTER FUNCTION integration.get_free_uline() OWNER TO asterisk;

--
-- Name: FUNCTION get_free_uline(); Type: COMMENT; Schema: integration; Owner: asterisk
--

COMMENT ON FUNCTION get_free_uline() IS 'Изначально просто  select * from integration.ulines where status=''free'' order by id asc limit 1;  а там посмотрим';


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
-- Name: get_callerid(character varying, character varying); Type: FUNCTION; Schema: routing; Owner: asterisk
--

CREATE FUNCTION get_callerid(peer_name character varying, number_b character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
declare

UID bigint;
DIR_ID bigint; 
CALLER_ID character varying; 

begin

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

--
-- get caller id
--
select set_callerid into CALLER_ID from routing.callerid 
	where direction_id = DIR_ID and sip_id = UID;
if not found then
	select set_callerid into CALLER_ID from routing.callerid 
		where direction_id = DIR_ID and sip_id is NULL; 
	if not found then 
		return '';
	end if; 
end if; 

return CALLER_ID;

end;


$_$;


ALTER FUNCTION routing.get_callerid(peer_name character varying, number_b character varying) OWNER TO asterisk;

--
-- Name: FUNCTION get_callerid(peer_name character varying, number_b character varying); Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON FUNCTION get_callerid(peer_name character varying, number_b character varying) IS 'Находим и подставляем callerid. 
';


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
-- Name: get_dial_route4(character varying, character varying, integer); Type: FUNCTION; Schema: routing; Owner: asterisk
--

CREATE FUNCTION get_dial_route4(peername character varying, exten character varying, current_try integer) RETURNS TABLE(dst_str character varying, dst_type character varying, try integer)
    LANGUAGE plpgsql
    AS $_$
declare

dir routing.directions%ROWTYPE;
r routing.route%ROWTYPE;
rname varchar(32);
trunk_id bigint; 
sip_id bigint; 

begin

--
-- Get SIP ID from peername; 
-- 

select id from public.sip_peers where name=$1 into sip_id; 
if not found then 
	raise exception 'NO SOURCE PEER/USER BY CHANNEL';
end if; 

--
-- Try to find direction by prefix;
-- 
select * into dir from routing.directions 
	where $2 ~ dr_prefix 
	order by dr_prio 
	asc 
	limit 1; 

if not found then 
	raise exception 'NO DIRECTION';
end if; 

--
-- Try to find route record that will give us type and destination id.
--
 
--
-- First try to search route record with peer sip ID 
--

select * into r from routing.route 
	where route_direction_id = dir.dr_list_item 
	and route_step = $3 
	and route_sip_id = sip_id 
	order by route_step asc limit 1; 

if not found then 
-- Try to find general route record with (route_sip_id = NULL) 
	select * into r from routing.route 
		where route_direction_id = dir.dr_list_item 
		and route_step = $3
		and route_sip_id is NULL   
		order by route_step asc limit 1; 
	if not found then 
		raise exception 'NO ROUTE';
	end if;
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

-- case route_type (lmask) 
if r.route_type = 'lmask' then 
	select name into dst_str from public.sip_peers where name=$2; 
	if not found then 
		raise exception 'LOCAL USER NOT FOUND';
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


ALTER FUNCTION routing.get_dial_route4(peername character varying, exten character varying, current_try integer) OWNER TO asterisk;

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
if NEW.route_type = 'tgrp' then 
	perform tgrp_id from routing.trunkgroups where tgrp_id=NEW.route_dest_id; 
	if not found then 
		raise exception 'trunkgroup not found'; 
	end if;
end if;
return NEW;
end;
$$;


ALTER FUNCTION routing.route_test() OWNER TO asterisk;

SET search_path = integration, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: recordings; Type: TABLE; Schema: integration; Owner: asterisk; Tablespace: 
--

CREATE TABLE recordings (
    id bigint NOT NULL,
    uline_id integer,
    original_file character varying,
    concatenated boolean DEFAULT false,
    result_file character varying,
    previous_record bigint DEFAULT 0,
    next_record bigint
);


ALTER TABLE integration.recordings OWNER TO asterisk;

--
-- Name: recordings_id_seq; Type: SEQUENCE; Schema: integration; Owner: asterisk
--

CREATE SEQUENCE recordings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE integration.recordings_id_seq OWNER TO asterisk;

--
-- Name: recordings_id_seq; Type: SEQUENCE OWNED BY; Schema: integration; Owner: asterisk
--

ALTER SEQUENCE recordings_id_seq OWNED BY recordings.id;


--
-- Name: recordings_id_seq; Type: SEQUENCE SET; Schema: integration; Owner: asterisk
--

SELECT pg_catalog.setval('recordings_id_seq', 222, true);


--
-- Name: ulines; Type: TABLE; Schema: integration; Owner: asterisk; Tablespace: 
--

CREATE TABLE ulines (
    id integer NOT NULL,
    status character varying(4) DEFAULT 'free'::character varying NOT NULL,
    callerid_num character varying,
    cdr_start character varying,
    channel_name character varying,
    uniqueid character varying
);


ALTER TABLE integration.ulines OWNER TO asterisk;

--
-- Name: workplaces; Type: TABLE; Schema: integration; Owner: asterisk; Tablespace: 
--

CREATE TABLE workplaces (
    id bigint NOT NULL,
    sip_id bigint NOT NULL,
    ip_addr_pc character varying,
    ip_addr_tel character varying,
    teletype character varying,
    autoprovision boolean DEFAULT false,
    tcp_port integer,
    integration_type character varying,
    mac_addr_tel character varying(16) DEFAULT NULL::character varying
);


ALTER TABLE integration.workplaces OWNER TO asterisk;

--
-- Name: workplaces_id_seq; Type: SEQUENCE; Schema: integration; Owner: asterisk
--

CREATE SEQUENCE workplaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE integration.workplaces_id_seq OWNER TO asterisk;

--
-- Name: workplaces_id_seq; Type: SEQUENCE OWNED BY; Schema: integration; Owner: asterisk
--

ALTER SEQUENCE workplaces_id_seq OWNED BY workplaces.id;


--
-- Name: workplaces_id_seq; Type: SEQUENCE SET; Schema: integration; Owner: asterisk
--

SELECT pg_catalog.setval('workplaces_id_seq', 19, true);


SET search_path = public, pg_catalog;

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

SELECT pg_catalog.setval('extensions_conf_id_seq', 6, true);


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

SELECT pg_catalog.setval('queue_members_uniqueid_seq', 21, true);


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

SELECT pg_catalog.setval('sip_conf_id_seq', 30, true);


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
    defaultuser character varying(10) DEFAULT NULL::character varying,
    outboundproxy character varying(80) DEFAULT NULL::character varying,
    CONSTRAINT sip_peers_name_check CHECK (((name)::text <> ''::text))
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

SELECT pg_catalog.setval('sip_peers_id_seq', 76, true);


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
-- Name: callerid; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE callerid (
    id bigint NOT NULL,
    direction_id bigint NOT NULL,
    sip_id bigint,
    set_callerid character varying DEFAULT ''::character varying NOT NULL
);


ALTER TABLE routing.callerid OWNER TO asterisk;

--
-- Name: TABLE callerid; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE callerid IS 'Таблица подстановок CALLERID. 
Пример: 
По направлению  DR_ID, юзер/пир SIP_PEER_ID требует установки CALLERID = XXXX. 
Если правило найдено, то CALLERID устанавливаем, а если не найдено, то не трогаем вообще. 

Если SIP_ID is NULL, то устанавливаем правило несмотря на того, кто звонит. Очень удобно для корпоративов. Если нужно подставить значение, которое общее для всех. Все равно сначала ищем "для конкретного человека", а потом "для всего кагала". 
';


--
-- Name: callerid_id_seq; Type: SEQUENCE; Schema: routing; Owner: asterisk
--

CREATE SEQUENCE callerid_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE routing.callerid_id_seq OWNER TO asterisk;

--
-- Name: callerid_id_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE callerid_id_seq OWNED BY callerid.id;


--
-- Name: callerid_id_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('callerid_id_seq', 4, true);


--
-- Name: directions; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE directions (
    dr_id bigint NOT NULL,
    dr_list_item bigint NOT NULL,
    dr_prefix character varying(32) NOT NULL,
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

SELECT pg_catalog.setval('directions_dr_id_seq', 20, true);


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

SELECT pg_catalog.setval('"directions_list_DLIST_ID_seq"', 7, true);


--
-- Name: permissions; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE permissions (
    id bigint NOT NULL,
    direction_id bigint,
    peer_id bigint
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

SELECT pg_catalog.setval('permissions_id_seq', 11, true);


--
-- Name: route; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE route (
    route_id bigint NOT NULL,
    route_direction_id bigint,
    route_step smallint,
    route_type character varying(8) DEFAULT 'trunk'::character varying NOT NULL,
    route_dest_id bigint NOT NULL,
    route_sip_id bigint,
    CONSTRAINT route_route_prio_check CHECK (((route_step >= 0) AND (route_step <= 5))),
    CONSTRAINT route_type_check2 CHECK (((((((route_type)::text = 'user'::text) OR ((route_type)::text = 'context'::text)) OR ((route_type)::text = 'trunk'::text)) OR ((route_type)::text = 'tgrp'::text)) OR ((route_type)::text = 'lmask'::text)))
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
-- Name: COLUMN route.route_sip_id; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON COLUMN route.route_sip_id IS 'Если не NULL, то правило маршрутизации касается только указанного sip_id (sip_peers.id). ';


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

SELECT pg_catalog.setval('route_route_id_seq', 17, true);


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


SET search_path = integration, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: integration; Owner: asterisk
--

ALTER TABLE recordings ALTER COLUMN id SET DEFAULT nextval('recordings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: integration; Owner: asterisk
--

ALTER TABLE workplaces ALTER COLUMN id SET DEFAULT nextval('workplaces_id_seq'::regclass);


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
-- Name: id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE callerid ALTER COLUMN id SET DEFAULT nextval('callerid_id_seq'::regclass);


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


SET search_path = integration, pg_catalog;

--
-- Data for Name: recordings; Type: TABLE DATA; Schema: integration; Owner: asterisk
--

COPY recordings (id, uline_id, original_file, concatenated, result_file, previous_record, next_record) FROM stdin;
36	1	2011/12/31/125157-1003.wav	t	FAULT	35	38
38	1	2011/12/31/125256-201.wav	t	FAULT	36	40
94	2	2012/01/03/162359-3039338.wav	t	2012/01/03/162359-3039338.mp3	0	0
40	1	2011/12/31/125326-201.wav	t	FAULT	38	0
45	1	2011/12/31/140639-1003.wav	t	FAULT	44	47
47	1	2011/12/31/140714-201.wav	t	FAULT	45	49
49	1	2011/12/31/140731-201.wav	t	FAULT	47	0
50	1	2011/12/31/141601-1003.wav	t	2011/12/31/141601-1003.mp3	0	0
51	1	2011/12/31/142102-1003.wav	t	2011/12/31/142102-1003.mp3	0	0
52	1	2011/12/31/142241-1003.wav	t	2011/12/31/142241-1003.mp3	0	0
53	1	2011/12/31/142511-1003.wav	t	2011/12/31/142511-1003.mp3	0	0
54	1	2011/12/31/144310-1003.wav	t	2011/12/31/144310-1003.mp3	0	0
55	1	2011/12/31/144411-1003.wav	t	2011/12/31/144411-1003.mp3	0	0
56	1	2011/12/31/144558-1003.wav	t	2011/12/31/144558-1003.mp3	0	0
57	1	2011/12/31/145204-1003.wav	t	2011/12/31/145204-1003.mp3	0	0
96	1	2012/01/03/162600-201.wav	t	2012/01/03/162600-201.mp3	0	0
1	18	2011/12/17/195449-1003.wav	t	2011/12/17/195449-1003.mp3	0	0
2	19	2011/12/17/195548-1003.wav	t	2011/12/17/195548-1003.mp3	0	0
3	20	2011/12/17/195610-201.wav	t	2011/12/17/195610-201.mp3	0	0
73	1	2012/01/02/204717-201.wav	t	2012/01/02/204717-201.mp3	0	0
80	2	2012/01/02/204857-201.wav	t	2012/01/02/204717-3039338.mp3	78	0
4	21	2011/12/17/195816-1003.wav	t	2011/12/17/195816-1003.mp3	0	0
5	22	2011/12/17/200255-1003.wav	t	2011/12/17/200255-1003.mp3	0	0
6	23	2011/12/17/200546-1003.wav	t	2011/12/17/200546-1003.mp3	0	0
9	26	2011/12/17/201210-1003.wav	t	/var/spool/asterisk/monitor/2011/12/17/201210-1003.mp3	0	10
10	26	2011/12/17/201211-1003.wav	t	/var/spool/asterisk/monitor/2011/12/17/201210-1003.mp3	9	0
11	27	2011/12/17/201301-201.wav	t	2011/12/17/201301-201.mp3	0	0
12	28	2011/12/17/201330-201.wav	t	2011/12/17/201330-201.mp3	0	0
75	1	2012/01/02/204820-201.wav	t	2012/01/02/204820-201.mp3	0	76
58	1	2011/12/31/145305-1003.wav	t	2011/12/31/145305-1003.mp3	0	0
59	1	2011/12/31/145416-1003.wav	t	2011/12/31/145416-1003.mp3	0	0
76	1	2012/01/02/204820-201.wav	t	2012/01/02/204820-201.mp3	75	0
79	1	2012/01/02/204857-201.wav	t	2012/01/02/204857-201.mp3	0	0
60	1	2011/12/31/145452-1003.wav	t	FAULT	0	0
98	1	2012/01/03/163955-201.wav	t	FAULT	0	0
100	1	2012/01/03/164910-201.wav	t	2012/01/03/164910-201.mp3	0	0
82	1	2012/01/02/205701-1003.wav	t	2012/01/02/205700-1003.mp3	81	84
86	1	2012/01/02/205716-201.wav	t	2012/01/02/205700-1003.mp3	84	88
85	2	2012/01/02/205716-201.wav	t	2012/01/02/205716-201.mp3	0	0
92	2	2012/01/03/153016-201.wav	t	2012/01/03/152947-3039338.mp3	90	0
61	1	2011/12/31/145509-1003.wav	t	2011/12/31/145509-1003.mp3	0	62
91	1	2012/01/03/153016-201.wav	t	2012/01/03/153016-201.mp3	0	0
13	29	2011/12/20/200417-1003.wav	t	FAULT	0	0
62	1	2011/12/31/145509-1003.wav	t	2011/12/31/145509-1003.mp3	61	64
64	1	2011/12/31/145525-201.wav	t	2011/12/31/145509-1003.mp3	62	66
66	1	2011/12/31/145535-201.wav	t	2011/12/31/145509-1003.mp3	64	0
63	2	2011/12/31/145525-201.wav	t	2011/12/31/145525-201.mp3	0	0
65	3	2011/12/31/145535-201.wav	t	2011/12/31/145535-201.mp3	0	0
67	3	2012/01/02/133242-1003.wav	t	FAULT	0	0
69	1	2012/01/02/140153-1003.wav	t	2012/01/02/140153-1003.mp3	0	70
72	1	2012/01/02/140213-201.wav	t	2012/01/02/140153-1003.mp3	70	0
71	2	2012/01/02/140213-201.wav	t	2012/01/02/140213-201.mp3	0	0
103	2	2012/01/03/164959-201.wav	t	2012/01/03/164910-3039338.mp3	101	105
14	1	2011/12/20/201433-1003.wav	t	FAULT	0	0
22	1	2011/12/31/123337-1003.wav	t	2011/12/31/123337-1003.mp3	21	24
24	1	2011/12/31/123411-201.wav	t	2011/12/31/123337-1003.mp3	22	26
26	1	2011/12/31/123446-201.wav	t	2011/12/31/123337-1003.mp3	24	0
106	1	2012/01/03/170142-201.wav	t	2012/01/03/170142-201.mp3	0	0
102	1	2012/01/03/164959-201.wav	t	2012/01/03/164959-201.mp3	0	0
108	1	2012/01/03/175605-1003.wav	t	2012/01/03/175605-1003.mp3	0	109
110	2	2012/01/03/175625-201.wav	t	2012/01/03/175625-201.mp3	0	0
114	1	2012/01/03/175645-201.wav	t	FAULT	0	0
116	1	2012/01/03/175654-3039338.wav	t	2012/01/03/175654-201.mp3	115	0
119	1	2012/01/03/175754-201.wav	t	2012/01/03/175754-201.mp3	0	120
120	1	2012/01/03/175754-201.wav	t	2012/01/03/175754-201.mp3	119	0
125	1	2012/01/03/202810-3039338.wav	t	2012/01/03/202810-201.mp3	124	0
89	1	2012/01/03/152947-201.wav	t	2012/01/03/152947-201.mp3	0	0
111	1	2012/01/03/175625-201.wav	t	2012/01/03/175605-1003.mp3	109	113
128	1	2012/01/03/204627-1003.wav	t	2012/01/03/204627-1003.mp3	0	0
23	2	2011/12/31/123411-201.wav	t	2011/12/31/123411-201.mp3	0	0
25	3	2011/12/31/123446-201.wav	t	2011/12/31/123446-201.mp3	0	0
27	1	2011/12/31/123809-1003.wav	t	2011/12/31/123809-1003.mp3	0	0
28	1	2011/12/31/123909-1003.wav	t	2011/12/31/123909-1003.mp3	0	0
29	1	2011/12/31/124821-1003.wav	t	2011/12/31/124821-1003.mp3	0	0
30	1	2011/12/31/125112-1003.wav	t	2011/12/31/125112-1003.mp3	0	0
95	1	2012/01/03/162503-201.wav	t	FAULT	0	0
97	1	2012/01/03/162600-3039338.wav	t	2012/01/03/162600-3039338.mp3	0	0
118	1	2012/01/03/175740-201.wav	t	2012/01/03/175740-201.mp3	117	0
121	1	2012/01/03/175804-201.wav	t	2012/01/03/175804-201.mp3	0	122
122	1	2012/01/03/175804-201.wav	t	2012/01/03/175804-201.mp3	121	0
130	1	2012/01/03/205044-1003.wav	t	2012/01/03/205044-1003.mp3	0	131
126	1	2012/01/03/202920-201.wav	t	2012/01/03/202920-201.mp3	0	127
7	24	2011/12/17/200733-1003.wav	t	2011/12/17/200733-1003.mp3	0	0
8	25	2011/12/17/200752-201.wav	t	2011/12/17/200752-201.mp3	0	0
15	1	2011/12/20/201447-1003.wav	t	2011/12/20/201447-1003.mp3	0	0
16	1	2011/12/21/190827-1003.wav	t	2011/12/21/190827-1003.mp3	0	0
17	2	2011/12/21/194212-1003.wav	t	2011/12/21/194212-1003.mp3	0	0
18	3	2011/12/21/195705-1003.wav	t	2011/12/21/195705-1003.mp3	0	0
19	1	2011/12/29/115138-1003.wav	t	2011/12/29/115138-1003.mp3	0	0
20	1	2011/12/29/115231-1003.wav	t	FAULT	0	0
21	1	2011/12/31/123337-1003.wav	t	2011/12/31/123337-1003.mp3	0	22
31	1	2011/12/31/125140-1003.wav	t	FAULT	0	0
32	1	2011/12/31/125146-1003.wav	t	FAULT	0	0
33	1	2011/12/31/125149-1003.wav	t	FAULT	0	0
34	1	2011/12/31/125153-1003.wav	t	FAULT	0	0
35	1	2011/12/31/125156-1003.wav	t	FAULT	0	36
37	2	2011/12/31/125256-201.wav	t	2011/12/31/125256-201.mp3	0	0
39	2	2011/12/31/125326-201.wav	t	2011/12/31/125326-201.mp3	0	0
41	1	2011/12/31/134007-201.wav	t	2011/12/31/134007-201.mp3	0	0
42	1	2011/12/31/140505-201.wav	t	2011/12/31/140505-201.mp3	0	0
43	1	2011/12/31/140550-201.wav	t	2011/12/31/140550-201.mp3	0	0
44	1	2011/12/31/140639-1003.wav	t	FAULT	0	45
46	2	2011/12/31/140714-201.wav	t	2011/12/31/140714-201.mp3	0	0
48	2	2011/12/31/140731-201.wav	t	2011/12/31/140731-201.mp3	0	0
68	3	2012/01/02/133305-1003.wav	t	2012/01/02/133305-1003.mp3	0	0
70	1	2012/01/02/140153-1003.wav	t	2012/01/02/140153-1003.mp3	69	72
74	2	2012/01/02/204717-3039338.wav	t	2012/01/02/204717-3039338.mp3	0	78
78	2	2012/01/02/204827-201.wav	t	2012/01/02/204717-3039338.mp3	74	80
77	1	2012/01/02/204827-201.wav	t	2012/01/02/204827-201.mp3	0	0
129	2	2012/01/03/204702-201.wav	t	2012/01/03/204702-201.mp3	0	0
131	1	2012/01/03/205044-1003.wav	t	2012/01/03/205044-1003.mp3	130	133
81	1	2012/01/02/205700-1003.wav	t	2012/01/02/205700-1003.mp3	0	82
84	1	2012/01/02/205710-201.wav	t	2012/01/02/205700-1003.mp3	82	86
88	1	2012/01/02/205722-201.wav	t	2012/01/02/205700-1003.mp3	86	0
83	2	2012/01/02/205710-201.wav	t	2012/01/02/205710-201.mp3	0	0
87	2	2012/01/02/205722-201.wav	t	2012/01/02/205722-201.mp3	0	0
132	2	2012/01/03/205203-201.wav	t	2012/01/03/205203-201.mp3	0	0
90	2	2012/01/03/152947-3039338.wav	t	2012/01/03/152947-3039338.mp3	0	92
93	1	2012/01/03/162359-201.wav	t	2012/01/03/162359-201.mp3	0	0
99	1	2012/01/03/164008-201.wav	t	FAULT	0	0
101	2	2012/01/03/164910-3039338.wav	t	2012/01/03/164910-3039338.mp3	0	103
105	2	2012/01/03/165018-201.wav	t	2012/01/03/164910-3039338.mp3	103	0
104	1	2012/01/03/165018-201.wav	t	2012/01/03/165018-201.mp3	0	0
107	1	2012/01/03/170142-3039338.wav	t	2012/01/03/170142-3039338.mp3	0	0
109	1	2012/01/03/175605-1003.wav	t	2012/01/03/175605-1003.mp3	108	111
113	1	2012/01/03/175634-201.wav	t	2012/01/03/175605-1003.mp3	111	0
112	2	2012/01/03/175634-201.wav	t	2012/01/03/175634-201.mp3	0	0
115	1	2012/01/03/175654-201.wav	t	2012/01/03/175654-201.mp3	0	116
117	1	2012/01/03/175740-201.wav	t	2012/01/03/175740-201.mp3	0	118
134	2	2012/01/03/205253-201.wav	t	2012/01/03/205253-201.mp3	0	0
140	1	2012/01/03/210240-201.wav	t	2012/01/03/210218-1003.mp3	137	142
123	1	2012/01/03/202507-201.wav	t	2012/01/03/202507-201.mp3	0	0
124	1	2012/01/03/202810-201.wav	t	2012/01/03/202810-201.mp3	0	125
127	1	2012/01/03/202920-201.wav	t	2012/01/03/202920-201.mp3	126	0
133	1	2012/01/03/205203-201.wav	t	2012/01/03/205044-1003.mp3	131	135
135	1	2012/01/03/205253-201.wav	t	2012/01/03/205044-1003.mp3	133	0
138	2	2012/01/03/210218-1003.wav	t	2012/01/03/210218-1003.mp3	0	144
167	1	2012/01/03/214113-201.wav	t	2012/01/03/213832-201.mp3	165	0
162	2	2012/01/03/214044-201.wav	t	2012/01/03/214044-201.mp3	0	0
164	2	2012/01/03/214104-201.wav	t	2012/01/03/214104-201.mp3	0	0
166	2	2012/01/03/214113-201.wav	t	2012/01/03/214113-201.mp3	0	0
197	2	2012/01/04/190838-201.wav	t	2012/01/04/190838-201.mp3	0	0
188	1	2012/01/04/184557-1003.wav	t	FAULT	0	0
136	1	2012/01/03/210111-1003.wav	t	2012/01/03/210111-1003.mp3	0	0
137	1	2012/01/03/210218-1003.wav	t	2012/01/03/210218-1003.mp3	0	140
142	1	2012/01/03/210248-201.wav	t	2012/01/03/210218-1003.mp3	140	0
144	2	2012/01/03/210251-201.wav	t	2012/01/03/210218-1003.mp3	138	0
139	3	2012/01/03/210240-201.wav	t	2012/01/03/210240-201.mp3	0	0
141	3	2012/01/03/210248-201.wav	t	2012/01/03/210248-201.mp3	0	0
143	3	2012/01/03/210251-201.wav	t	2012/01/03/210251-201.mp3	0	0
145	1	2012/01/03/210649-1003.wav	t	FAULT	0	0
146	1	2012/01/03/210823-1003.wav	t	2012/01/03/210823-1003.mp3	0	148
148	1	2012/01/03/210945-201.wav	t	2012/01/03/210823-1003.mp3	146	0
147	2	2012/01/03/210945-201.wav	t	2012/01/03/210945-201.mp3	0	0
149	1	2012/01/03/211040-1003.wav	t	2012/01/03/211040-1003.mp3	0	151
151	1	2012/01/03/211104-201.wav	t	2012/01/03/211040-1003.mp3	149	153
153	1	2012/01/03/211120-201.wav	t	2012/01/03/211040-1003.mp3	151	0
150	2	2012/01/03/211104-201.wav	t	2012/01/03/211104-201.mp3	0	0
152	2	2012/01/03/211120-201.wav	t	2012/01/03/211120-201.mp3	0	0
168	1	2012/01/04/123708-201.wav	t	2012/01/04/123708-201.mp3	0	0
154	1	2012/01/03/211348-201.wav	t	2012/01/03/211348-201.mp3	0	0
155	1	2012/01/03/211348-3039338.wav	t	FAULT	0	157
157	1	2012/01/03/211511-201.wav	t	FAULT	155	159
159	1	2012/01/03/211549-201.wav	t	FAULT	157	0
169	1	2012/01/04/123708-1003.wav	t	FAULT	0	171
189	1	2012/01/04/185450-1003.wav	t	2012/01/04/185450-1003.mp3	0	0
175	1	2012/01/04/181558-201.wav	t	2012/01/04/181558-201.mp3	0	0
176	1	2012/01/04/182948-201.wav	t	2012/01/04/182948-201.mp3	0	0
177	1	2012/01/04/183027-201.wav	t	2012/01/04/183027-201.mp3	0	179
179	1	2012/01/04/183159-201.wav	t	2012/01/04/183027-201.mp3	177	181
181	1	2012/01/04/183214-201.wav	t	2012/01/04/183027-201.mp3	179	183
183	1	2012/01/04/183249-201.wav	t	2012/01/04/183027-201.mp3	181	185
156	2	2012/01/03/211511-201.wav	t	2012/01/03/211511-201.mp3	0	0
158	2	2012/01/03/211549-201.wav	t	2012/01/03/211549-201.mp3	0	0
160	1	2012/01/03/213753-201.wav	t	2012/01/03/213753-201.mp3	0	0
161	1	2012/01/03/213832-201.wav	t	2012/01/03/213832-201.mp3	0	163
163	1	2012/01/03/214044-201.wav	t	2012/01/03/213832-201.mp3	161	165
165	1	2012/01/03/214104-201.wav	t	2012/01/03/213832-201.mp3	163	167
171	1	2012/01/04/123923-201.wav	t	FAULT	169	0
170	2	2012/01/04/123923-201.wav	t	2012/01/04/123923-201.mp3	0	0
172	1	2012/01/04/131322-201.wav	t	FAULT	0	0
173	1	2012/01/04/131829-201.wav	t	2012/01/04/131829-201.mp3	0	0
174	1	2012/01/04/132701-201.wav	t	2012/01/04/132701-201.mp3	0	0
200	2	2012/01/04/201434-201.wav	t	2012/01/04/201434-201.mp3	0	0
190	1	2012/01/04/185705-1003.wav	t	FAULT	0	192
193	1	2012/01/04/190417-1003.wav	t	2012/01/04/190417-1003.mp3	0	195
192	1	2012/01/04/185823-201.wav	t	FAULT	190	0
195	1	2012/01/04/190441-201.wav	t	2012/01/04/190417-1003.mp3	193	0
185	1	2012/01/04/183309-201.wav	t	2012/01/04/183027-201.mp3	183	187
187	1	2012/01/04/183335-201.wav	t	2012/01/04/183027-201.mp3	185	0
178	2	2012/01/04/183159-201.wav	t	2012/01/04/183159-201.mp3	0	0
180	3	2012/01/04/183214-201.wav	t	2012/01/04/183214-201.mp3	0	0
182	2	2012/01/04/183249-201.wav	t	2012/01/04/183249-201.mp3	0	0
184	2	2012/01/04/183309-201.wav	t	2012/01/04/183309-201.mp3	0	0
186	3	2012/01/04/183335-201.wav	t	2012/01/04/183335-201.mp3	0	0
191	2	2012/01/04/185823-201.wav	t	2012/01/04/185823-201.mp3	0	0
194	2	2012/01/04/190441-201.wav	t	2012/01/04/190441-201.mp3	0	0
196	1	2012/01/04/190810-1003.wav	t	2012/01/04/190810-1003.mp3	0	198
198	1	2012/01/04/190838-201.wav	t	2012/01/04/190810-1003.mp3	196	0
199	1	2012/01/04/201408-1003.wav	t	2012/01/04/201408-1003.mp3	0	201
201	1	2012/01/04/201434-201.wav	t	2012/01/04/201408-1003.mp3	199	0
203	2	2012/01/04/202103-201.wav	t	2012/01/04/202103-201.mp3	0	0
205	3	2012/01/04/202313-201.wav	t	2012/01/04/202313-201.mp3	0	0
202	1	2012/01/04/202056-1003.wav	t	2012/01/04/202056-1003.mp3	0	204
204	1	2012/01/04/202103-201.wav	t	2012/01/04/202056-1003.mp3	202	206
206	1	2012/01/04/202313-201.wav	t	2012/01/04/202056-1003.mp3	204	0
207	1	2012/01/06/201629-201.wav	f	\N	0	\N
208	2	2012/01/06/201646-201.wav	f	\N	0	\N
209	3	2012/01/06/201659-201.wav	f	\N	0	\N
210	4	2012/01/08/122437-1003.wav	f	\N	0	\N
211	6	2012/01/10/142950-201.wav	f	\N	0	\N
212	7	2012/01/10/143004-201.wav	f	\N	0	\N
213	8	2012/01/11/152135-201.wav	f	\N	0	\N
214	9	2012/01/11/152158-201.wav	f	\N	0	\N
215	10	2012/01/11/152226-201.wav	f	\N	0	\N
216	11	2012/01/11/152406-201.wav	f	\N	0	\N
217	12	2012/01/11/152717-201.wav	f	\N	0	\N
218	13	2012/01/11/153043-201.wav	f	\N	0	\N
219	14	2012/01/11/153142-201.wav	f	\N	0	\N
220	15	2012/01/11/153200-201.wav	f	\N	0	\N
221	17	2012/01/12/122331-201.wav	f	\N	0	\N
222	18	2012/01/16/120750-201.wav	f	\N	0	\N
\.


--
-- Data for Name: ulines; Type: TABLE DATA; Schema: integration; Owner: asterisk
--

COPY ulines (id, status, callerid_num, cdr_start, channel_name, uniqueid) FROM stdin;
67	free	\N	\N	\N	\N
68	free	\N	\N	\N	\N
69	free	\N	\N	\N	\N
70	free	\N	\N	\N	\N
71	free	\N	\N	\N	\N
72	free	\N	\N	\N	\N
73	free	\N	\N	\N	\N
74	free	\N	\N	\N	\N
75	free	\N	\N	\N	\N
76	free	\N	\N	\N	\N
77	free	\N	\N	\N	\N
78	free	\N	\N	\N	\N
79	free	\N	\N	\N	\N
80	free	\N	\N	\N	\N
81	free	\N	\N	\N	\N
82	free	\N	\N	\N	\N
83	free	\N	\N	\N	\N
84	free	\N	\N	\N	\N
85	free	\N	\N	\N	\N
86	free	\N	\N	\N	\N
87	free	\N	\N	\N	\N
88	free	\N	\N	\N	\N
89	free	\N	\N	\N	\N
90	free	\N	\N	\N	\N
91	free	\N	\N	\N	\N
92	free	\N	\N	\N	\N
93	free	\N	\N	\N	\N
94	free	\N	\N	\N	\N
95	free	\N	\N	\N	\N
96	free	\N	\N	\N	\N
97	free	\N	\N	\N	\N
98	free	\N	\N	\N	\N
99	free	\N	\N	\N	\N
100	free	\N	\N	\N	\N
101	free	\N	\N	\N	\N
102	free	\N	\N	\N	\N
103	free	\N	\N	\N	\N
104	free	\N	\N	\N	\N
105	free	\N	\N	\N	\N
106	free	\N	\N	\N	\N
107	free	\N	\N	\N	\N
108	free	\N	\N	\N	\N
109	free	\N	\N	\N	\N
110	free	\N	\N	\N	\N
111	free	\N	\N	\N	\N
112	free	\N	\N	\N	\N
113	free	\N	\N	\N	\N
114	free	\N	\N	\N	\N
115	free	\N	\N	\N	\N
116	free	\N	\N	\N	\N
117	free	\N	\N	\N	\N
118	free	\N	\N	\N	\N
119	free	\N	\N	\N	\N
120	free	\N	\N	\N	\N
121	free	\N	\N	\N	\N
122	free	\N	\N	\N	\N
123	free	\N	\N	\N	\N
124	free	\N	\N	\N	\N
125	free	\N	\N	\N	\N
126	free	\N	\N	\N	\N
127	free	\N	\N	\N	\N
128	free	\N	\N	\N	\N
129	free	\N	\N	\N	\N
130	free	\N	\N	\N	\N
131	free	\N	\N	\N	\N
132	free	\N	\N	\N	\N
133	free	\N	\N	\N	\N
134	free	\N	\N	\N	\N
135	free	\N	\N	\N	\N
136	free	\N	\N	\N	\N
137	free	\N	\N	\N	\N
138	free	\N	\N	\N	\N
139	free	\N	\N	\N	\N
140	free	\N	\N	\N	\N
141	free	\N	\N	\N	\N
142	free	\N	\N	\N	\N
143	free	\N	\N	\N	\N
144	free	\N	\N	\N	\N
145	free	\N	\N	\N	\N
146	free	\N	\N	\N	\N
147	free	\N	\N	\N	\N
148	free	\N	\N	\N	\N
149	free	\N	\N	\N	\N
150	free	\N	\N	\N	\N
151	free	\N	\N	\N	\N
152	free	\N	\N	\N	\N
153	free	\N	\N	\N	\N
154	free	\N	\N	\N	\N
155	free	\N	\N	\N	\N
156	free	\N	\N	\N	\N
157	free	\N	\N	\N	\N
158	free	\N	\N	\N	\N
159	free	\N	\N	\N	\N
160	free	\N	\N	\N	\N
161	free	\N	\N	\N	\N
162	free	\N	\N	\N	\N
163	free	\N	\N	\N	\N
21	free	1003	2011-12-17 19:58:16	SIP/t_express-0000002d	1324144696.62
22	free	1003	2011-12-17 20:02:55	SIP/t_express-0000002f	1324144975.64
30	free	\N	\N	\N	\N
31	free	\N	\N	\N	\N
32	free	\N	\N	\N	\N
33	free	\N	\N	\N	\N
34	free	\N	\N	\N	\N
35	free	\N	\N	\N	\N
36	free	\N	\N	\N	\N
37	free	\N	\N	\N	\N
38	free	\N	\N	\N	\N
39	free	\N	\N	\N	\N
40	free	\N	\N	\N	\N
41	free	\N	\N	\N	\N
42	free	\N	\N	\N	\N
43	free	\N	\N	\N	\N
44	free	\N	\N	\N	\N
45	free	\N	\N	\N	\N
46	free	\N	\N	\N	\N
47	free	\N	\N	\N	\N
48	free	\N	\N	\N	\N
49	free	\N	\N	\N	\N
50	free	\N	\N	\N	\N
23	free	1003	2011-12-17 20:05:46	SIP/t_express-00000031	1324145146.66
26	free	1003	2011-12-17 20:12:10	SIP/t_express-00000036	1324145530.72
28	free	201	2011-12-17 20:13:30	SIP/201-00000039	1324145610.78
29	free	1003	2011-12-20 20:04:17	SIP/t_express-0000003e	1324404257.83
27	free	201	2011-12-17 20:13:01	SIP/201-00000038	1324145581.75
24	free	1003	2011-12-17 20:07:33	SIP/t_express-00000033	1324145253.68
25	free	201	2011-12-17 20:07:52	SIP/201-00000035	1324145272.71
51	free	\N	\N	\N	\N
52	free	\N	\N	\N	\N
53	free	\N	\N	\N	\N
54	free	\N	\N	\N	\N
55	free	\N	\N	\N	\N
56	free	\N	\N	\N	\N
57	free	\N	\N	\N	\N
58	free	\N	\N	\N	\N
59	free	\N	\N	\N	\N
60	free	\N	\N	\N	\N
61	free	\N	\N	\N	\N
62	free	\N	\N	\N	\N
63	free	\N	\N	\N	\N
64	free	\N	\N	\N	\N
65	free	\N	\N	\N	\N
66	free	\N	\N	\N	\N
18	busy	201	2012-01-16 12:07:50	SIP/201-00000021	1326708470.33
164	free	\N	\N	\N	\N
165	free	\N	\N	\N	\N
166	free	\N	\N	\N	\N
167	free	\N	\N	\N	\N
168	free	\N	\N	\N	\N
169	free	\N	\N	\N	\N
170	free	\N	\N	\N	\N
171	free	\N	\N	\N	\N
172	free	\N	\N	\N	\N
173	free	\N	\N	\N	\N
174	free	\N	\N	\N	\N
175	free	\N	\N	\N	\N
176	free	\N	\N	\N	\N
177	free	\N	\N	\N	\N
178	free	\N	\N	\N	\N
179	free	\N	\N	\N	\N
180	free	\N	\N	\N	\N
181	free	\N	\N	\N	\N
182	free	\N	\N	\N	\N
183	free	\N	\N	\N	\N
184	free	\N	\N	\N	\N
185	free	\N	\N	\N	\N
186	free	\N	\N	\N	\N
187	free	\N	\N	\N	\N
188	free	\N	\N	\N	\N
189	free	\N	\N	\N	\N
190	free	\N	\N	\N	\N
191	free	\N	\N	\N	\N
192	free	\N	\N	\N	\N
193	free	\N	\N	\N	\N
194	free	\N	\N	\N	\N
195	free	\N	\N	\N	\N
196	free	\N	\N	\N	\N
197	free	\N	\N	\N	\N
198	free	\N	\N	\N	\N
199	free	\N	\N	\N	\N
200	free	\N	\N	\N	\N
1	busy	201	2012-01-06 20:16:29	SIP/201-00000000	1325873789.0
2	busy	201	2012-01-06 20:16:46	SIP/201-00000002	1325873806.2
3	busy	201	2012-01-06 20:16:59	SIP/201-00000004	1325873819.4
4	busy	1003	2012-01-08 12:24:37	SIP/t_express-00000006	1326018277.6
5	busy	201	2012-01-10 14:29:47	SIP/201-00000008	1326198587.8
6	busy	201	2012-01-10 14:29:50	SIP/201-00000009	1326198590.9
7	busy	201	2012-01-10 14:30:04	SIP/201-0000000c	1326198604.12
8	busy	201	2012-01-11 15:21:35	SIP/201-0000000e	1326288095.14
9	busy	201	2012-01-11 15:21:58	SIP/201-00000010	1326288118.16
10	busy	201	2012-01-11 15:22:26	SIP/201-00000012	1326288146.18
11	busy	201	2012-01-11 15:24:06	SIP/201-00000014	1326288246.20
12	busy	201	2012-01-11 15:27:17	SIP/201-00000016	1326288437.22
13	busy	201	2012-01-11 15:30:43	SIP/201-00000018	1326288643.24
14	busy	201	2012-01-11 15:31:42	SIP/201-0000001a	1326288702.26
15	busy	201	2012-01-11 15:32:00	SIP/201-0000001c	1326288720.28
16	busy	201	2012-01-12 12:23:27	SIP/201-0000001e	1326363807.30
17	busy	201	2012-01-12 12:23:31	SIP/201-0000001f	1326363811.31
19	free	1003	2011-12-17 19:55:48	SIP/t_express-0000002a	1324144548.59
20	free	201	2011-12-17 19:56:10	SIP/201-0000002c	1324144570.61
\.


--
-- Data for Name: workplaces; Type: TABLE DATA; Schema: integration; Owner: asterisk
--

COPY workplaces (id, sip_id, ip_addr_pc, ip_addr_tel, teletype, autoprovision, tcp_port, integration_type, mac_addr_tel) FROM stdin;
2	58	192.168.0.22	192.168.1.22	GrandStreamGXP1200	t	335	TaxiOffice	000b8221d77b
3	59	192.168.0.23	192.168.1.23	GrandStreamGXP1200	t	335	TaxiOffice	000b8221d77c
4	60	192.168.0.24	192.168.1.24	GrandStreamGXP1200	t	335	TaxiOffice	000b8221d77d
5	61	192.168.0.25	192.168.1.25	GrandStreamGXP1200	t	335	TaxiOffice	000b8221d77f
6	62	192.168.0.26	192.168.1.26	GrandStreamGXP1200	t	335	TaxiOffice	000b82226396
7	63	192.168.0.27	192.168.1.27	GrandStreamGXP1200	t	335	TaxiOffice	000b82226397
8	64	192.168.0.11	192.168.1.11	GrandStreamGXP1200	t	335	TaxiOffice	000b8217fd9b
9	65	192.168.0.12	192.168.1.12	GrandStreamGXP1200	t	335	TaxiOffice	000b8217fd3b
10	66	192.168.0.13	192.168.1.13	GrandStreamGXP1200	t	335	TaxiOffice	000b8217fd99
11	67	192.168.0.16	192.168.1.16	GrandStreamGXP1200	t	335	TaxiOffice	000b82226394
12	68	192.168.0.17	192.168.1.17	GrandStreamGXP1200	t	335	TaxiOffice	000b82226395
13	69	192.168.0.14	192.168.1.14	GrandStreamGXP1200	t	335	TaxiOffice	000b8217fd9c
14	70	192.168.0.15	192.168.1.15	GrandStreamGXP1200	t	335	TaxiOffice	000b8217fd9a
15	71	192.168.0.16	192.168.1.16	GrandStreamGXP1200	t	335	TaxiOffice	000b8221d733
16	72	192.168.0.17	192.168.1.17	GrandStreamGXP1200	t	335	TaxiOffice	000b8217fd9e
17	73	192.168.0.28	192.168.1.28	GrandStreamGXP1200	t	335	TaxiOffice	000b8221d737
18	74	192.168.0.29	192.168.1.29	GrandStreamGXP1200	t	335	TaxiOffice	000b821a40a3
19	75	192.168.0.30	192.168.1.30	GrandStreamGXP1200	t	335	TaxiOffice	000b8227c189
1	57	192.168.1.98	192.168.1.114	GrandStreamGXP1200	t	335	TaxiOffice	000b8221d77a
\.


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
2011-12-17 13:42:46+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000000	SIP/201-00000001	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	16	10	ANSWERED	3		1324122166.0	
2011-12-17 13:44:11+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000002	SIP/201-00000003	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	21	17	ANSWERED	3		1324122251.2	
2011-12-17 13:44:52+02	"Im Phone" <201>	201	10	parkingslot	SIP/201-00000004	SIP/t_express-00000002	ParkedCall	10	15	15	ANSWERED	3		1324122292.5	
2011-12-17 13:53:54+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000005	SIP/201-00000006	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	21	9	ANSWERED	3		1324122834.6	
2011-12-17 13:55:08+02	"Im Phone" <201>	201	i	parkingslot	SIP/201-00000007		Playback	pbx-invalidpark	3	3	ANSWERED	3		1324122908.9	
2011-12-17 13:55:12+02	"Im Phone" <201>	201	4	parkingslot	SIP/201-00000008	SIP/t_express-00000005	ParkedCall	4	6	6	ANSWERED	3		1324122912.10	
2011-12-17 14:04:43+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000009	SIP/201-0000000a	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	13	9	ANSWERED	3		1324123483.11	
2011-12-17 14:05:26+02	"Im Phone" <201>	201	1	parkingslot	SIP/201-0000000b	SIP/t_express-00000009	ParkedCall	1	5	4	ANSWERED	3		1324123526.14	
2011-12-17 14:18:18+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-0000000c	SIP/201-0000000d	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	13	7	ANSWERED	3		1324124298.15	
2011-12-17 14:18:37+02	"Im Phone" <201>	201	3	parkingslot	SIP/201-0000000e	SIP/t_express-0000000c	ParkedCall	3	6	6	ANSWERED	3		1324124317.18	
2011-12-17 14:23:29+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-0000000f	SIP/201-00000010	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	10	8	ANSWERED	3		1324124609.19	
2011-12-17 14:23:44+02	"Im Phone" <201>	201	5	parkingslot	SIP/201-00000011	SIP/t_express-0000000f	ParkedCall	5	9	9	ANSWERED	3		1324124624.22	
2011-12-17 14:32:50+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000012	SIP/201-00000013	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	7	6	ANSWERED	3		1324125170.23	
2011-12-17 14:33:03+02	"Im Phone" <201>	201	6	parkingslot	SIP/201-00000014	SIP/t_express-00000012	ParkedCall	6	4	4	ANSWERED	3		1324125183.26	
2011-12-17 14:37:44+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000015	SIP/201-00000016	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	6	4	ANSWERED	3		1324125464.27	
2011-12-17 14:37:54+02	"Im Phone" <201>	201	7	parkingslot	SIP/201-00000017	SIP/t_express-00000015	ParkedCall	7	4	4	ANSWERED	3		1324125474.30	
2011-12-17 14:56:47+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000018	SIP/201-00000019	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	10	7	ANSWERED	3		1324126607.31	
2011-12-17 14:56:59+02	"Im Phone" <201>	201	8	parkingslot	SIP/201-0000001a	SIP/t_express-00000018	ParkedCall	8	7	6	ANSWERED	3		1324126619.34	
2011-12-17 15:35:18+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-0000001b	SIP/201-0000001c	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	13	7	ANSWERED	3		1324128918.35	
2011-12-17 15:35:37+02	"Im Phone" <201>	201	9	parkingslot	SIP/201-0000001d	SIP/t_express-0000001b	ParkedCall	9	9	8	ANSWERED	3		1324128937.38	
2011-12-17 15:38:25+02	"LINE 10" <1003>	1003	2391515	express	SIP/t_express-0000001e	SIP/201-0000001f	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	8	6	ANSWERED	3		1324129105.39	
2011-12-17 15:38:36+02	"LINE 11" <201>	201	10	parkingslot	SIP/201-00000020	SIP/t_express-0000001e	ParkedCall	10	4	4	ANSWERED	3		1324129116.42	
2011-12-17 15:45:16+02	"LINE 12" <1003>	1003	2391515	express	SIP/t_express-00000021	SIP/201-00000022	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	7	4	ANSWERED	3		1324129516.43	
2011-12-17 15:45:37+02	"LINE 13" <201>	201	12	parkingslot	SIP/201-00000023	SIP/t_express-00000021	ParkedCall	12	6	6	ANSWERED	3		1324129537.46	
2011-12-17 15:45:48+02	"LINE 14" <201>	201	1	parkingslot	SIP/201-00000024		ParkedCall	1	5	4	ANSWERED	3		1324129548.49	
2011-12-17 15:45:57+02	"LINE 15" <201>	201	12	parkingslot	SIP/201-00000025	SIP/t_express-00000021	ParkedCall	12	4	4	ANSWERED	3		1324129557.50	
2011-12-17 15:46:16+02	"LINE 16" <201>	201	12	parkingslot	SIP/201-00000026	SIP/t_express-00000021	ParkedCall	12	8	8	ANSWERED	3		1324129576.53	
2011-12-17 15:46:27+02	"LINE 17" <201>	201	12	parkingslot	SIP/201-00000027	SIP/t_express-00000021	ParkedCall	12	4	4	ANSWERED	3		1324129587.56	
2011-12-17 19:54:49+02	"LINE 18" <1003>	1003	2391515	express	SIP/t_express-00000028	SIP/201-00000029	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	28	20	ANSWERED	3		1324144489.57	
2011-12-17 19:55:48+02	"LINE 19" <1003>	1003	2391515	express	SIP/t_express-0000002a	SIP/201-0000002b	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	14	12	ANSWERED	3		1324144548.59	
2011-12-17 19:56:10+02	"LINE 20" <201>	201	19	parkingslot	SIP/201-0000002c		ParkedCall	19	2	1	ANSWERED	3		1324144570.61	
2011-12-17 19:58:16+02	"LINE 21" <1003>	1003	2391515	express	SIP/t_express-0000002d	SIP/201-0000002e	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	6	3	ANSWERED	3		1324144696.62	
2011-12-17 20:02:55+02	"LINE 22" <1003>	1003	2391515	express	SIP/t_express-0000002f	SIP/201-00000030	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	5	2	ANSWERED	3		1324144975.64	
2011-12-17 20:05:46+02	"LINE 23" <1003>	1003	2391515	express	SIP/t_express-00000031	SIP/201-00000032	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	4	2	ANSWERED	3		1324145146.66	
2011-12-17 20:07:33+02	"LINE 24" <1003>	1003	2391515	express	SIP/t_express-00000033	SIP/201-00000034	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	4	3	ANSWERED	3		1324145253.68	
2011-12-17 20:07:52+02	"LINE 25" <201>	201	24	parkingslot	SIP/201-00000035	SIP/t_express-00000033	ParkedCall	24	2	2	ANSWERED	3		1324145272.71	
2011-12-17 20:12:10+02	"LINE 26" <1003>	1003	2391515	express	SIP/t_express-00000036	SIP/201-00000037	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	5	3	ANSWERED	3		1324145530.72	
2011-12-17 20:13:01+02	"LINE 27" <201>	201	26	parkingslot	SIP/201-00000038	SIP/t_express-00000036	ParkedCall	26	19	18	ANSWERED	3		1324145581.75	
2011-12-17 20:13:30+02	"LINE 28" <201>	201	26	parkingslot	SIP/201-00000039	SIP/t_express-00000036	ParkedCall	26	51	51	ANSWERED	3		1324145610.78	
2011-12-12 13:43:23+02	"Alex Radetsky" <1003>	1003	200	default	SIP/t_express-0000001b	SIP/t_express-0000001c	Hangup	17	0	0	FAILED	3		1323690203.27	
2011-12-12 17:04:18+02	"Im Phone" <201>	201	3039338	default	SIP/201-00000021	SIP/t_express-00000022	Hangup	17	0	0	FAILED	3		1323702258.33	
2011-12-12 17:06:34+02	"Im Phone" <201>	201	3039338	default	SIP/201-00000023	SIP/t_express-00000024	Dial	SIP/t_express/3039338|120|rtTg	5	4	ANSWERED	3		1323702394.35	
2011-12-13 09:49:36+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000028	SIP/201-00000029	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	47	35	ANSWERED	3		1323762576.40	
2011-12-13 16:58:33+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-0000002c	SIP/201-0000002d	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	27	10	ANSWERED	3		1323788313.44	
2011-12-13 17:00:22+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000030	SIP/201-00000031	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	53	52	ANSWERED	3		1323788422.48	
2011-12-13 17:05:34+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000036	SIP/201-00000037	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	16	0	ANSWERED	3		1323788734.54	
2011-12-15 18:19:46+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000039	SIP/201-0000003a	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	10	6	ANSWERED	3		1323965986.57	
2011-12-15 18:23:57+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-0000003b	SIP/201-0000003c	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	9	6	ANSWERED	3		1323966237.59	
2011-12-15 18:24:50+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-0000003d	SIP/201-0000003e	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	10	8	ANSWERED	3		1323966290.61	
2011-12-15 18:25:37+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000040	SIP/201-00000041	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	51	49	ANSWERED	3		1323966337.64	
2011-12-15 18:27:01+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000046	SIP/201-00000047	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	22	19	ANSWERED	3		1323966421.70	
2011-12-20 20:14:47+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000042	SIP/201-00000043	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	68	66	ANSWERED	3		1324404887.87	
2011-12-21 19:08:27+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000044	SIP/201-00000045	Queue	express|rtTn|15|NetSDS-AGI-integration.pl	74	69	ANSWERED	3		1324487307.89	
2011-12-21 19:42:12+02	"LINE 2" <1003>	1003	2391515	express	SIP/t_express-00000046	SIP/201-00000047	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	107	100	ANSWERED	3		1324489332.91	
2011-12-21 19:57:05+02	"LINE 3" <1003>	1003	2391515	express	SIP/t_express-00000048	SIP/201-00000049	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	33	25	ANSWERED	3		1324490225.93	
2011-12-29 11:51:38+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000004a	SIP/201-0000004b	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	52	48	ANSWERED	3		1325152298.95	
2011-12-15 18:48:33+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000000	SIP/201-00000001	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	23	21	ANSWERED	3		1323967713.0	
2011-12-31 12:33:37+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000000	SIP/201-00000001	AGI	VERBOSE	19	17	ANSWERED	3		1325327617.0	
2011-12-31 12:34:11+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000002	SIP/t_express-00000000	ParkedCall	1	25	25	ANSWERED	3		1325327651.3	
2011-12-31 12:34:46+02	"LINE 3" <201>	201	1	parkingslot	SIP/201-00000003	SIP/t_express-00000000	ParkedCall	1	11	11	ANSWERED	3		1325327686.6	
2011-12-31 12:38:09+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000004	SIP/201-00000005	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	26	23	ANSWERED	3		1325327889.7	
2011-12-31 12:39:09+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000006	SIP/201-00000007	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	7	4	ANSWERED	3		1325327949.9	
2011-12-31 12:48:21+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000008	SIP/201-00000009	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	57	47	ANSWERED	3		1325328501.11	
2011-12-31 12:51:12+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000000a	SIP/201-0000000b	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	13	10	ANSWERED	3		1325328672.13	
2011-12-31 12:51:56+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000010	SIP/201-00000011	AGI	VERBOSE	18	15	ANSWERED	3		1325328716.19	
2011-12-31 12:52:56+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000012	SIP/t_express-00000010	ParkedCall	1	12	12	ANSWERED	3		1325328776.22	
2011-12-31 12:53:26+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000013	SIP/t_express-00000010	ParkedCall	1	9	9	ANSWERED	3		1325328806.25	
2011-12-31 13:40:07+02	"LINE 1" <201>	201	3039338	default	SIP/201-00000014	SIP/t_express-00000015	Dial	SIP/t_express/3039338|120|rtTg	6	6	ANSWERED	3		1325331607.26	
2011-12-31 14:05:05+02	"LINE 1" <201>	201	3039338	default	SIP/201-00000016	SIP/t_express-00000017	Dial	SIP/t_express/3039338|120|rtTg	4	3	ANSWERED	3		1325333105.28	
2011-12-15 19:39:42+02	"Im Phone" <201>	201	0	default	SIP/201-00000000		Park	10	10	10	ANSWERED	3		1323970782.0	
2011-12-15 19:41:26+02	"Im Phone" <201>	201	0	default	SIP/201-00000001		Park		36	36	ANSWERED	3		1323970886.2	
2011-12-15 19:47:18+02	"Im Phone" <201>	201	0	default	SIP/201-00000004		Park		11	10	ANSWERED	3		1323971238.6	
2011-12-15 19:48:24+02	"Im Phone" <201>	201	0	default	SIP/201-00000005		Park		4	4	ANSWERED	3		1323971304.8	
2011-12-15 19:47:06+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000002	SIP/201-00000003	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	96	94	ANSWERED	3		1323971226.4	
2011-12-15 19:53:54+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000006	SIP/201-00000007	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	10	5	ANSWERED	3		1323971634.10	
2011-12-15 19:54:58+02	"Im Phone" <201>	201	0	default	SIP/201-00000011		Park		6	6	ANSWERED	3		1323971698.21	
2011-12-15 19:54:34+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-0000000f	SIP/201-00000010	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	70	66	ANSWERED	3		1323971674.19	
2011-12-15 19:58:24+02	"Im Phone" <201>	201	0	default	SIP/201-00000014		Park		13	13	ANSWERED	3		1323971904.25	
2011-12-15 19:58:04+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000012	SIP/201-00000013	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	42	38	ANSWERED	3		1323971884.23	
2011-12-15 19:59:29+02	"Im Phone" <201>	201	0	default	SIP/201-00000017		Park		12	12	ANSWERED	3		1323971969.29	
2011-12-15 19:59:21+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000015	SIP/201-00000016	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	51	49	ANSWERED	3		1323971961.27	
2011-12-15 20:02:30+02	"Im Phone" <201>	201	0	default	SIP/201-0000001a		Park		7	7	ANSWERED	3		1323972150.33	
2011-12-15 20:02:22+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000018	SIP/201-00000019	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	58	56	ANSWERED	3		1323972142.31	
2011-12-15 20:09:57+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-0000001b	SIP/201-0000001c	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	43	41	ANSWERED	3		1323972597.35	
2011-12-15 20:11:49+02			parkannounce	parkingslot	Local/parkannounce@parkingslot-8c3f,2		Hangup		0	0	ANSWERED	3		1323972709.46	
2011-12-15 20:11:49+02			parkannounce	parkingslot	Local/parkannounce@parkingslot-8c3f,1				0	0	ANSWERED	3		1323972709.45	
2011-12-15 20:11:41+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-0000001e	SIP/201-0000001f	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	29	28	ANSWERED	3		1323972701.41	
2011-12-15 20:16:44+02			parkannounce	parkingslot	Local/parkannounce@parkingslot-c88f,2		Hangup		0	0	ANSWERED	3		1323973004.52	
2011-12-15 20:16:44+02			parkannounce	parkingslot	Local/parkannounce@parkingslot-c88f,1				0	0	ANSWERED	3		1323973004.51	
2011-12-15 20:16:39+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000021	SIP/201-00000022	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	34	33	ANSWERED	3		1323972999.47	
2011-12-15 20:22:27+02			parkannounce	parkingslot	Local/parkannounce@parkingslot-bfae,2		Hangup		0	0	ANSWERED	3		1323973347.58	
2011-12-15 20:22:27+02			parkannounce	parkingslot	Local/parkannounce@parkingslot-bfae,1				0	0	ANSWERED	3		1323973347.57	
2011-12-15 20:22:15+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000024	SIP/201-00000025	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	19	17	ANSWERED	3		1323973335.53	
2011-12-15 20:47:10+02	"Im Phone" <201>	201	i	parkingslot	SIP/201-00000027		Hangup		0	0	ANSWERED	3		1323974830.59	
2011-12-15 20:47:44+02			parkannounce	parkingslot	Local/parkannounce@parkingslot-f7c5,1				0	0	ANSWERED	3		1323974864.64	
2011-12-15 20:47:44+02			parkannounce	parkingslot	Local/parkannounce@parkingslot-f7c5,2		Answer		0	0	ANSWERED	3		1323974864.65	
2011-12-15 20:47:38+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000028	SIP/201-00000029	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	7	5	ANSWERED	3		1323974858.60	
2011-12-15 20:47:57+02	"Im Phone" <201>	201	10	parkingslot	SIP/201-0000002b	SIP/t_express-00000028	ParkedCall	10	29	29	ANSWERED	3		1323974877.66	
2011-12-15 20:49:50+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-0000002c	SIP/201-0000002d	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	19	17	ANSWERED	3		1323974990.67	
2011-12-15 20:50:30+02	"Im Phone" <201>	201	10	parkingslot	SIP/201-0000002f	SIP/t_express-0000002c	ParkedCall	10	1	1	ANSWERED	3		1323975030.71	
2011-12-15 20:50:52+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000030	SIP/201-00000031	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	9	8	ANSWERED	3		1323975052.72	
2011-12-15 20:51:08+02	"Im Phone" <201>	201	10	parkingslot	SIP/201-00000033	SIP/t_express-00000030	ParkedCall	10	4	4	ANSWERED	3		1323975068.76	
2011-12-15 21:03:03+02	"Im Phone" <201>	201	0	default	SIP/201-00000036		Park		2	2	ANSWERED	3		1323975783.79	
2011-12-15 21:02:44+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000034	SIP/201-00000035	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	34	32	ANSWERED	3		1323975764.77	
2011-12-15 21:03:05+02	"Im Phone" <201>	201	0	default	SIP/201-00000037		Park		13	13	ANSWERED	3		1323975785.81	
2011-12-16 17:07:37+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-0000003e	SIP/201-0000003f	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	9	1	ANSWERED	3		1324048057.89	
2011-12-31 14:05:50+02	"LINE 1" <201>	201	3039338	default	SIP/201-00000018	SIP/t_express-00000019	Dial	SIP/t_express/3039338|120|rtTg	5	4	ANSWERED	3		1325333150.30	
2011-12-31 14:06:39+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000001a	SIP/201-0000001b	AGI	VERBOSE	16	14	ANSWERED	3		1325333199.32	
2011-12-31 14:07:14+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-0000001c	SIP/t_express-0000001a	ParkedCall	1	7	6	ANSWERED	3		1325333234.35	
2011-12-31 14:07:31+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-0000001d	SIP/t_express-0000001a	ParkedCall	1	4	4	ANSWERED	3		1325333251.38	
2011-12-31 14:16:01+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000001e	SIP/201-0000001f	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	31	29	ANSWERED	3		1325333761.39	
2011-12-16 17:28:07+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000048	SIP/201-00000049	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	15	13	ANSWERED	3		1324049287.99	
2011-12-16 17:28:22+02	"Alex Radetsky" <1003>	1003	SIP/201	park-dial	SIP/t_express-00000048	SIP/201-0000004b	Dial	SIP/201|30|Tt	111	63	ANSWERED	3		1324049287.99	
2011-12-31 14:21:02+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000020	SIP/201-00000021	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	19	18	ANSWERED	3		1325334062.41	
2011-12-31 14:22:41+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000022	SIP/201-00000023	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	18	16	ANSWERED	3		1325334161.43	
2011-12-31 14:25:11+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000024	SIP/201-00000025	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	6	3	ANSWERED	3		1325334311.45	
2011-12-31 14:43:10+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000026	SIP/201-00000027	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	19	15	ANSWERED	3		1325335390.47	
2011-12-31 14:44:11+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000028	SIP/201-00000029	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	13	11	ANSWERED	3		1325335451.49	
2011-12-31 14:45:58+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000002a	SIP/201-0000002b	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	6	4	ANSWERED	3		1325335558.51	
2011-12-31 14:52:04+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000002c	SIP/201-0000002d	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	11	9	ANSWERED	3		1325335924.53	
2011-12-31 14:53:05+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000002e	SIP/201-0000002f	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	21	20	ANSWERED	3		1325335985.55	
2011-12-31 14:54:16+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000030	SIP/201-00000031	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	13	11	ANSWERED	3		1325336056.57	
2011-12-31 14:55:09+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000033	SIP/201-00000034	AGI	VERBOSE	8	6	ANSWERED	3		1325336109.60	
2011-12-31 14:55:25+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000035	SIP/t_express-00000033	ParkedCall	1	4	4	ANSWERED	3		1325336125.63	
2011-12-31 14:55:35+02	"LINE 3" <201>	201	1	parkingslot	SIP/201-00000036	SIP/t_express-00000033	ParkedCall	1	4	3	ANSWERED	3		1325336135.66	
2012-01-02 13:33:05+02	"LINE 3" <1003>	1003	2391515	express	SIP/t_express-00000039	SIP/201-0000003a	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	98	95	ANSWERED	3		1325503985.69	
2012-01-02 14:01:53+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000003b	SIP/201-0000003c	AGI	VERBOSE	9	7	ANSWERED	3		1325505713.71	
2012-01-02 14:02:13+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-0000003d	SIP/t_express-0000003b	ParkedCall	1	52	51	ANSWERED	3		1325505733.74	
2012-01-02 20:47:17+02	"LINE 1" <201>	201	3039338	default	SIP/201-0000003e	SIP/t_express-0000003f	Dial	SIP/t_express/3039338|120|rtTg	50	49	ANSWERED	3		1325530037.75	
2012-01-02 20:48:20+02	"LINE 1" <201>	201	1	parkingslot	SIP/201-00000040		ParkedCall	1	5	4	ANSWERED	3		1325530100.79	
2012-01-02 20:48:27+02	"LINE 1" <201>	201	2	parkingslot	SIP/201-00000041	SIP/t_express-0000003f	ParkedCall	2	26	25	ANSWERED	3		1325530107.80	
2012-01-02 20:48:57+02	"LINE 1" <201>	201	2	parkingslot	SIP/201-00000042	SIP/t_express-0000003f	ParkedCall	2	17	17	ANSWERED	3		1325530137.83	
2012-01-02 20:57:00+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000043	SIP/201-00000044	AGI	VERBOSE	8	6	ANSWERED	3		1325530620.84	
2012-01-02 20:57:10+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000045	SIP/t_express-00000043	ParkedCall	1	4	4	ANSWERED	3		1325530630.87	
2012-01-02 20:57:16+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000046	SIP/t_express-00000043	ParkedCall	1	4	4	ANSWERED	3		1325530636.90	
2012-01-02 20:57:22+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000047	SIP/t_express-00000043	ParkedCall	1	4	4	ANSWERED	3		1325530642.93	
2012-01-03 15:29:47+02	"LINE 1" <201>	201	3039338	default	SIP/201-00000048	SIP/t_express-00000049	Dial	SIP/t_express/3039338|120|rtTg	24	24	ANSWERED	3		1325597387.94	
2012-01-03 15:30:16+02	"LINE 1" <201>	201	2	parkingslot	SIP/201-0000004a	SIP/t_express-00000049	ParkedCall	2	7	7	ANSWERED	3		1325597416.98	
2012-01-03 16:23:59+02	"LINE 1" <201>	201	3039338	default	SIP/201-0000004b	SIP/t_express-0000004c	Dial	SIP/t_express/3039338|120|rtTg	36	36	ANSWERED	3		1325600639.99	
2012-01-03 16:23:59+02	"LINE 2" <201>	201	0	default	SIP/201-0000004b	SIP/t_express-0000004c	Park		61	61	ANSWERED	3		1325600639.99	
2012-01-03 16:26:00+02	"LINE 1" <201>	201	3039338	default	SIP/201-0000004e	SIP/t_express-0000004f	Dial	SIP/t_express/3039338|120|rtTg	21	21	ANSWERED	3		1325600760.104	
2012-01-03 16:26:00+02	"LINE 1" <201>	201	0	default	SIP/201-0000004e	SIP/t_express-0000004f	Park		51	51	ANSWERED	3		1325600760.104	
2012-01-03 16:49:10+02	"LINE 1" <201>	201	3039338	default	SIP/201-00000052	SIP/t_express-00000053	Dial	SIP/t_express/3039338|120|rtTg	20	19	ANSWERED	3		1325602150.110	
2012-01-03 16:49:59+02	"LINE 1" <201>	201	2	parkingslot	SIP/201-00000054	SIP/t_express-00000053	ParkedCall	2	10	10	ANSWERED	3		1325602199.114	
2012-01-03 16:50:18+02	"LINE 1" <201>	201	2	parkingslot	SIP/201-00000055	SIP/t_express-00000053	ParkedCall	2	4	4	ANSWERED	3		1325602218.117	
2012-01-03 17:01:42+02	"LINE 1" <201>	201	3039338	default	SIP/201-00000056	SIP/t_express-00000057	Dial	SIP/t_express/3039338|120|rtTg	22	22	ANSWERED	3		1325602902.118	1
2012-01-03 17:01:42+02	"LINE 1" <201>	201	0	default	SIP/201-00000056	SIP/t_express-00000057	Park		47	47	ANSWERED	3		1325602902.118	1
2012-01-03 17:56:05+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000058	SIP/201-00000059	AGI	VERBOSE	12	10	ANSWERED	3		1325606165.122	1
2012-01-03 17:56:25+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-0000005a	SIP/t_express-00000058	ParkedCall	1	7	6	ANSWERED	3		1325606185.125	2
2012-01-03 17:56:34+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-0000005b	SIP/t_express-00000058	ParkedCall	1	7	7	ANSWERED	3		1325606194.128	2
2012-01-03 17:56:54+02	"LINE 1" <201>	201	3039338	default	SIP/201-0000005d	SIP/t_express-0000005e	Dial	SIP/t_express/3039338|120|rtTg	27	27	ANSWERED	3		1325606214.130	1
2012-01-03 17:57:40+02	"LINE 1" <201>	201	1	parkingslot	SIP/201-0000005f	SIP/t_express-0000005e	ParkedCall	1	10	10	ANSWERED	3		1325606260.134	1
2011-12-16 20:32:36+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000000	SIP/201-00000001	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	8	6	ANSWERED	3		1324060356.0	
2011-12-16 20:32:44+02	"Alex Radetsky" <1003>	1003	SIP/201	park-dial	SIP/t_express-00000000	SIP/201-00000002	Dial	SIP/201|30|Tt	56	9	ANSWERED	3		1324060356.0	
2011-12-16 20:38:23+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000005	SIP/201-00000006	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	7	5	ANSWERED	3		1324060703.6	
2012-01-03 17:57:54+02	"LINE 1" <201>	201	1	parkingslot	SIP/201-00000060	SIP/t_express-0000005e	ParkedCall	1	8	8	ANSWERED	3		1325606274.137	1
2012-01-03 17:58:04+02	"LINE 1" <201>	201	1	parkingslot	SIP/201-00000061	SIP/t_express-0000005e	ParkedCall	1	8	7	ANSWERED	3		1325606284.140	1
2012-01-03 20:25:07+02	"LINE 1" <201>	201	3039338	default	SIP/201-00000062	SIP/t_express-00000063	Dial	SIP/t_express/3039338|120|rtTg	31	31	ANSWERED	3		1325615107.141	1
2012-01-03 20:25:07+02	201	201	0	default	SIP/201-00000062	SIP/t_express-00000063	Hangup	17	31	31	ANSWERED	3		1325615107.141	1
2012-01-03 20:28:10+02	"LINE 1" <201>	201	3039338	default	SIP/201-00000064	SIP/t_express-00000065	Dial	SIP/t_express/3039338|120|rtTg	25	25	ANSWERED	3		1325615290.144	1
2012-01-03 20:29:20+02	"LINE 1" <201>	201	1	parkingslot	SIP/201-00000066	SIP/t_express-00000065	ParkedCall	1	22	22	ANSWERED	3		1325615360.148	1
2012-01-03 20:46:27+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000067	SIP/201-00000068	AGI	VERBOSE	26	24	ANSWERED	3		1325616387.149	1
2012-01-03 20:47:02+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000069	SIP/t_express-00000067	ParkedCall	1	13	13	ANSWERED	3		1325616422.152	2
2012-01-03 20:50:44+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000006a	SIP/201-0000006b	AGI	VERBOSE	37	35	ANSWERED	3		1325616644.153	1
2012-01-03 20:52:03+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-0000006c	SIP/t_express-0000006a	ParkedCall	1	37	37	ANSWERED	3		1325616723.156	2
2012-01-03 20:52:53+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-0000006d	SIP/t_express-0000006a	ParkedCall	1	53	53	ANSWERED	3		1325616773.159	2
2012-01-03 21:01:11+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000006e	SIP/201-0000006f	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	32	30	ANSWERED	3		1325617271.160	1
2012-01-03 21:02:18+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000070	SIP/201-00000071	AGI	VERBOSE	8	7	ANSWERED	3		1325617338.162	1
2012-01-03 21:02:40+02	"LINE 3" <201>	201	1	parkingslot	SIP/201-00000072		ParkedCall	1	4	4	ANSWERED	3		1325617360.165	3
2012-01-03 21:02:48+02	"LINE 3" <201>	201	1	parkingslot	SIP/201-00000073		ParkedCall	1	2	2	ANSWERED	3		1325617368.166	3
2012-01-03 21:02:51+02	"LINE 3" <201>	201	2	parkingslot	SIP/201-00000074	SIP/t_express-00000070	ParkedCall	2	3	3	ANSWERED	3		1325617371.167	2
2012-01-03 21:08:23+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-00000077	SIP/201-00000078	AGI	VERBOSE	46	43	ANSWERED	3		1325617703.170	1
2012-01-03 21:09:45+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000079	SIP/t_express-00000077	ParkedCall	1	26	25	ANSWERED	3		1325617785.173	2
2012-01-03 21:10:40+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000007a	SIP/201-0000007b	AGI	VERBOSE	14	12	ANSWERED	3		1325617840.174	1
2011-12-16 20:44:13+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000000	SIP/201-00000001	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	9	7	ANSWERED	3		1324061053.0	
2011-12-16 20:53:41+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000003	SIP/201-00000004	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	19	9	ANSWERED	3		1324061621.3	
2011-12-16 21:09:12+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000005	SIP/201-00000006	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	10	8	ANSWERED	3		1324062552.5	
2011-12-16 21:10:03+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000007	SIP/201-00000008	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	14	11	ANSWERED	3		1324062603.7	
2011-12-16 21:13:46+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000009	SIP/201-0000000a	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	14	9	ANSWERED	3		1324062826.9	
2011-12-16 21:47:39+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-0000000c	SIP/201-0000000d	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	10	8	ANSWERED	3		1324064859.13	
2011-12-16 21:48:04+02	"Im Phone" <201>	201	10	parkingslot	SIP/201-0000000e	SIP/t_express-0000000c	ParkedCall	10	13	13	ANSWERED	3		1324064884.16	
2012-01-03 21:11:04+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-0000007c	SIP/t_express-0000007a	ParkedCall	1	9	8	ANSWERED	3		1325617864.177	2
2012-01-03 21:11:20+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-0000007d	SIP/t_express-0000007a	ParkedCall	1	8	7	ANSWERED	3		1325617880.180	2
2012-01-03 21:13:48+02	"LINE 1" <201>	201	3039338	default	SIP/201-0000007e	SIP/t_express-0000007f	Dial	SIP/t_express/3039338|120|rtTg	29	29	ANSWERED	3		1325618028.181	1
2012-01-03 21:15:11+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000080	SIP/t_express-0000007f	ParkedCall	1	23	23	ANSWERED	3		1325618111.185	1
2012-01-03 21:15:49+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000081	SIP/t_express-0000007f	ParkedCall	1	7	7	ANSWERED	3		1325618149.188	2
2012-01-03 21:37:53+02	"LINE 1" <201>	201	3039338	default	SIP/201-00000082	SIP/t_express-00000083	Dial	SIP/t_express/3039338|120|rtTg	28	28	ANSWERED	3		1325619473.189	1
2012-01-03 21:38:32+02	"LINE 1" <201>	201	3039338	default	SIP/201-00000084	SIP/t_express-00000085	Dial	SIP/t_express/3039338|120|rtTg	90	89	ANSWERED	3		1325619512.191	1
2012-01-03 21:40:44+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000086	SIP/t_express-00000085	ParkedCall	1	14	14	ANSWERED	3		1325619644.195	1
2012-01-03 21:41:04+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000087	SIP/t_express-00000085	ParkedCall	1	8	7	ANSWERED	3		1325619664.198	2
2012-01-03 21:41:13+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000088	SIP/t_express-00000085	ParkedCall	1	9	8	ANSWERED	3		1325619673.201	2
2012-01-04 12:37:08+02	"LINE 1" <201>	201	1003	default	SIP/201-00000089	SIP/t_express-0000008a	Dial	SIP/t_express/1003|120|rtTg	74	62	ANSWERED	3		1325673428.202	1
2012-01-04 12:39:23+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-0000008b	SIP/t_express-0000008a	ParkedCall	1	10	9	ANSWERED	3		1325673563.206	1
2012-01-04 13:18:29+02	"LINE 1" <201>	201	2054455	default	SIP/201-0000008d	SIP/t_express-0000008e	Dial	SIP/t_express/2054455|120|rtTg	104	98	ANSWERED	3		1325675909.208	1
2012-01-04 13:27:01+02	"LINE 1" <201>	201	2054455	default	SIP/201-0000008f	SIP/t_express-00000090	Dial	SIP/t_express/2054455|120|rtTg	144	140	ANSWERED	3		1325676421.210	1
2012-01-04 18:15:58+02	"LINE 1" <201>	201	1003	default	SIP/201-00000091	SIP/t_express-00000092	Dial	SIP/t_express/1003|120|rtTg	28	20	ANSWERED	3		1325693758.212	1
2012-01-04 18:29:48+02	"LINE 1" <201>	201	1003	default	SIP/201-00000093	SIP/t_express-00000094	Dial	SIP/t_express/1003|120|rtTg	13	5	ANSWERED	3		1325694588.214	1
2012-01-04 18:30:27+02	"LINE 1" <201>	201	1003	default	SIP/201-00000095	SIP/t_express-00000096	Dial	SIP/t_express/1003|120|rtTg	59	46	ANSWERED	3		1325694627.216	1
2012-01-04 18:31:59+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000097	SIP/t_express-00000096	ParkedCall	1	12	12	ANSWERED	3		1325694719.220	1
2012-01-04 18:32:14+02	"LINE 3" <201>	201	1	parkingslot	SIP/201-00000098	SIP/t_express-00000096	ParkedCall	1	24	24	ANSWERED	3		1325694734.223	2
2012-01-04 18:32:49+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-00000099	SIP/t_express-00000096	ParkedCall	1	9	9	ANSWERED	3		1325694769.226	3
2012-01-04 18:33:09+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-0000009a	SIP/t_express-00000096	ParkedCall	1	8	7	ANSWERED	3		1325694789.229	2
2012-01-04 18:33:35+02	"LINE 3" <201>	201	1	parkingslot	SIP/201-0000009b	SIP/t_express-00000096	ParkedCall	1	6	6	ANSWERED	3		1325694815.232	2
2012-01-04 18:45:57+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000009c	SIP/201-0000009d	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	43	42	ANSWERED	3		1325695557.233	1
2012-01-04 18:54:50+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-0000009e	SIP/201-0000009f	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl	39	37	ANSWERED	3		1325696090.235	1
2012-01-04 18:57:05+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-000000a0	SIP/201-000000a1	AGI	VERBOSE	31	30	ANSWERED	3		1325696225.237	1
2012-01-04 18:58:23+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-000000a2	SIP/t_express-000000a0	ParkedCall	1	27	27	ANSWERED	3		1325696303.240	2
2012-01-04 19:04:17+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-000000a3	SIP/201-000000a4	AGI	VERBOSE	13	11	ANSWERED	3		1325696657.241	1
2012-01-04 19:04:41+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-000000a5	SIP/t_express-000000a3	ParkedCall	1	21	21	ANSWERED	3		1325696681.244	2
2012-01-04 19:08:10+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-000000a6	SIP/201-000000a7	AGI	VERBOSE	16	14	ANSWERED	3		1325696890.245	1
2012-01-04 19:08:38+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-000000a8	SIP/t_express-000000a6	ParkedCall	1	10	10	ANSWERED	3		1325696918.248	2
2012-01-04 20:14:08+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-000000a9	SIP/201-000000aa	AGI	VERBOSE	12	10	ANSWERED	3		1325700848.249	1
2012-01-04 20:14:34+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-000000ab	SIP/t_express-000000a9	ParkedCall	1	43	43	ANSWERED	3		1325700874.252	2
2012-01-04 20:20:56+02	"LINE 1" <1003>	1003	2391515	express	SIP/t_express-000000ac	SIP/201-000000ad	AGI	VERBOSE	4	2	ANSWERED	3		1325701256.253	1
2011-12-17 11:23:42+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000000	SIP/201-00000001	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	30	25	ANSWERED	3		1324113822.0	
2012-01-04 20:21:03+02	"LINE 2" <201>	201	1	parkingslot	SIP/201-000000ae	SIP/t_express-000000ac	ParkedCall	1	128	127	ANSWERED	3		1325701263.256	2
2012-01-04 20:23:13+02	"LINE 3" <201>	201	1	parkingslot	SIP/201-000000af	SIP/t_express-000000ac	ParkedCall	1	70	70	ANSWERED	3		1325701393.259	2
2011-12-17 12:35:56+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000000	SIP/201-00000001	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	13	11	ANSWERED	3		1324118156.0	
2011-12-17 12:37:03+02	"Im Phone" <201>	201	1	parkingslot	SIP/201-00000002	SIP/t_express-00000000	ParkedCall	1	20	20	ANSWERED	3		1324118223.3	
2011-12-17 12:40:46+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000003	SIP/201-00000004	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	14	12	ANSWERED	3		1324118446.4	
2011-12-17 12:41:30+02	"Alex Radetsky" <1003>	1003	2391515	express	SIP/t_express-00000009	SIP/201-0000000a	Queue	express|rtTn|15|NetSDS-AGI-Integration.pl	11	8	ANSWERED	3		1324118490.11	
2011-12-17 12:41:56+02	"Im Phone" <201>	201	8	parkingslot	SIP/201-0000000b	SIP/t_express-00000009	ParkedCall	8	10	10	ANSWERED	3		1324118516.14	
2012-01-06 20:16:29+02	"LINE 1" <201>	201	1003	default	SIP/201-00000000	SIP/t_express-00000001	Hangup	17	0	0	FAILED	3		1325873789.0	1
2012-01-06 20:16:46+02	"LINE 2" <201>	201	1003	default	SIP/201-00000002	SIP/t_express-00000003	Dial	SIP/t_express/1003|120|rtTg	9	3	ANSWERED	3		1325873806.2	2
2012-01-06 20:16:59+02	"LINE 3" <201>	201	1001	default	SIP/201-00000004	SIP/t_express-00000005	Dial	SIP/t_express/1001|120|rtTg	13	8	ANSWERED	3		1325873819.4	3
2012-01-10 14:29:50+02	"LINE 6" <201>	201	1003	default	SIP/201-00000009	SIP/t_express-0000000a	Hangup	17	0	0	FAILED	3		1326198590.9	6
2012-01-10 14:30:04+02	"LINE 7" <201>	201	5948732	default	SIP/201-0000000c	SIP/t_express-0000000d	Hangup	17	2	0	BUSY	3		1326198604.12	7
2012-01-11 15:21:35+02	"LINE 8" <201>	201	5948732	default	SIP/201-0000000e	SIP/t_express-0000000f	Hangup	17	2	0	BUSY	3		1326288095.14	8
2012-01-11 15:21:58+02	"LINE 9" <201>	201	5948732	default	SIP/201-00000010	SIP/t_express-00000011	Hangup	17	2	0	BUSY	3		1326288118.16	9
2012-01-11 15:22:26+02	"LINE 10" <201>	201	2063505	default	SIP/201-00000012	SIP/t_express-00000013	Hangup	17	3	0	BUSY	3		1326288146.18	10
2012-01-11 15:24:06+02	"LINE 11" <201>	201	2063505	default	SIP/201-00000014	SIP/t_express-00000015	Hangup	17	3	0	BUSY	3		1326288246.20	11
2012-01-11 15:27:17+02	"LINE 12" <201>	201	2063505	default	SIP/201-00000016	SIP/t_express-00000017	Hangup	17	2	0	BUSY	3		1326288437.22	12
2012-01-11 15:30:43+02	"LINE 13" <201>	201	2063505	default	SIP/201-00000018	SIP/t_express-00000019	Dial	SIP/t_express/2063505|120|rtTg	53	0	NO ANSWER	3		1326288643.24	13
2012-01-11 15:31:42+02	"LINE 14" <201>	201	2063506	default	SIP/201-0000001a	SIP/t_express-0000001b	Dial	SIP/t_express/2063506|120|rtTg	15	0	NO ANSWER	3		1326288702.26	14
2012-01-11 15:32:00+02	"LINE 15" <201>	201	2063512	default	SIP/201-0000001c	SIP/t_express-0000001d	Dial	SIP/t_express/2063512|120|rtTg	19	0	NO ANSWER	3		1326288720.28	15
2012-01-12 12:23:31+02	"LINE 17" <201>	201	4559146	default	SIP/201-0000001f	SIP/t_express-00000020	Dial	SIP/t_express/4559146|120|rtTg	57	41	ANSWERED	3		1326363811.31	17
2012-01-16 12:07:50+02	"LINE 18" <201>	201	3310199	default	SIP/201-00000021	SIP/t_express-00000022	Dial	SIP/t_express/3310199|120|rtTg	59	0	NO ANSWER	3		1326708470.33	18
2011-12-09 23:59:55+02	"Alex Radetsky" <1003>	1003	201	default	SIP/t_express-00000008	SIP/201-00000009	Dial	SIP/201|120|rtT	6	0	NO ANSWER	3		1323467995.8	
\.


--
-- Data for Name: extensions_conf; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY extensions_conf (id, context, exten, priority, app, appdata) FROM stdin;
3	default	_X!	3	Hangup	17
6	parkingslot	_X!	1	NoOp	see extensions.conf
5	express	h	1	NoOp	EOCall: ${CALLERID(num)} ${CDR(start)}
2	default	_X!	2	AGI	NetSDS-route.pl|${CHANNEL}|${EXTEN}
1	default	_X!	1	NoOp	
4	express	_X!	1	Queue	express|rtTn|||15|NetSDS-AGI-integration.pl
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
1	201	express	SIP/201	\N	\N
2	202	express	SIP/202	\N	\N
3	203	express	SIP/203	\N	\N
4	204	express	SIP/204	\N	\N
5	205	express	SIP/205	\N	\N
6	206	express	SIP/206	\N	\N
7	207	express	SIP/207	\N	\N
8	208	autoexpress	SIP/208	\N	\N
9	209	autoexpress	SIP/209	\N	\N
10	210	autoexpress	SIP/210	\N	\N
11	211	autoexpress	SIP/211	\N	\N
12	212	autoexpress	SIP/212	\N	\N
13	213	evakuator	SIP/213	\N	\N
14	214	evakuator	SIP/214	\N	\N
15	215	evakuator	SIP/215	\N	\N
17	216	evakuator	SIP/216	\N	\N
18	216	leader	SIP/216	\N	\N
19	217	leader	SIP/217	\N	\N
20	218	leader	SIP/218	\N	\N
21	219	miniexpress	SIP/219	\N	\N
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
express	default	\N	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	\N	2	30	10	0	ringall	no	yes	t	t	f	0	0	f	\N	\N	f	t	mixmonitor
autoexpress	default	\N	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	\N	2	30	10	0	ringall	no	yes	t	t	f	0	0	f	\N	\N	f	t	mixmonitor
miniexpress	default	\N	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	\N	2	30	10	0	ringall	no	yes	t	t	f	0	0	f	\N	\N	f	t	mixmonitor
evakuator	default	\N	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	\N	2	30	10	0	ringall	no	yes	t	t	f	0	0	f	\N	\N	f	t	mixmonitor
leader	default	\N	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	\N	2	30	10	0	ringall	no	yes	t	t	f	0	0	f	\N	\N	f	t	mixmonitor
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
30	0	0	0	sip.conf	general	ignoreregexpire	yes
\.


--
-- Data for Name: sip_peers; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY sip_peers (id, name, accountcode, amaflags, callgroup, callerid, canreinvite, directmedia, context, defaultip, dtmfmode, fromuser, fromdomain, host, insecure, language, mailbox, md5secret, nat, permit, deny, mask, pickupgroup, port, qualify, restrictcid, rtptimeout, rtpholdtimeout, secret, type, username, disallow, allow, musiconhold, regseconds, ipaddr, regexten, cancallforward, comment, "call-limit", lastms, regserver, fullcontact, useragent, defaultuser, outboundproxy) FROM stdin;
2	gsm1	\N	\N	\N	\N	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	ru	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
3	gsm2	\N	\N	\N	\N	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	ru	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
4	gsm3	\N	\N	\N	\N	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	ru	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
58	202	\N	\N	\N	Express 2 <202>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	ru	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	WhiteBlack	friend	202	all	ulaw,alaw	\N	0			yes		1	-1			\N	\N	\N
72	216	\N	\N	\N	Evakuator 4 <216>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
73	217	\N	\N	\N	Leader 1 <217>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
74	218	\N	\N	\N	Leader 2 <218>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
75	219	\N	\N	\N	Mini 1 <219>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
76	220	\N	\N	\N	Unused <220>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
59	203	\N	\N	\N	Express 3 <203>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
60	204	\N	\N	\N	Express 4 <204>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
61	205	\N	\N	\N	Express 5 <205>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
62	206	\N	\N	\N	Express 6 <206>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
63	207	\N	\N	\N	Express 7 <207>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
64	208	\N	\N	\N	Auto 1 <208>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
65	209	\N	\N	\N	Auto 2 <209>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
66	210	\N	\N	\N	Auto 3 <210>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
67	211	\N	\N	\N	Auto 4 <211>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
68	212	\N	\N	\N	Auto 5 <212>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
69	213	\N	\N	\N	Evakuator 1 <213>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
70	214	\N	\N	\N	Evakuator 2 <214>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
71	215	\N	\N	\N	Evakuator 3 <215>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	\N	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	\N	friend		all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	\N
56	t_express	\N	\N	\N	\N	no	yes	default	\N	rfc2833	\N	\N	193.193.194.6	port,invite	ru	\N	\N	no	\N	\N	\N	\N		yes	\N	\N	\N	t_wsedr21W	friend	t_express	all	ulaw,alaw	\N	0			yes		1	0	\N	\N	\N	\N	193.193.194.6
57	201	\N	\N	\N	Express 1 <201>	no	yes	default	\N	rfc2833	\N	\N	dynamic	\N	ru	\N	\N	no	\N	\N	\N	\N	5060	yes	\N	\N	\N	SuperPasswd	friend	201	all	ulaw,alaw	\N	1326717384	192.168.1.114		yes		1	10		sip:201@192.168.1.114:5060	\N	\N	\N
\.


--
-- Data for Name: whitelist; Type: TABLE DATA; Schema: public; Owner: asterisk
--

COPY whitelist (id, number, reason, create_date) FROM stdin;
\.


SET search_path = routing, pg_catalog;

--
-- Data for Name: callerid; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

COPY callerid (id, direction_id, sip_id, set_callerid) FROM stdin;
1	1	57	3039338
3	1	\N	5949641
4	6	\N	3039338
\.


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
12	5	^0$	5
13	5	^1\\d$	5
14	5	^\\d$	5
15	5	^\\d\\d$	5
17	5	^1\\d\\d$	5
18	1	^1\\d\\d\\d$	5
19	6	^[2-5]\\d\\d\\d\\d\\d\\d$	5
20	7	^2\\d\\d$	5
\.


--
-- Data for Name: directions_list; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

COPY directions_list (dlist_id, dlist_name) FROM stdin;
3	Dmitry Kruglikoff
4	taxi express
1	NetStyle Office
2	KyivStar
5	parking slot
6	Local City (Kyiv)
7	Local Office 2xx
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

COPY permissions (id, direction_id, peer_id) FROM stdin;
3	3	58
4	3	56
5	4	56
6	1	56
7	1	57
9	5	57
10	5	56
11	6	57
\.


--
-- Data for Name: route; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

COPY route (route_id, route_direction_id, route_step, route_type, route_dest_id, route_sip_id) FROM stdin;
4	1	1	trunk	56	\N
9	3	1	user	57	\N
7	2	1	tgrp	1	\N
11	4	1	context	4	\N
14	5	1	context	6	\N
15	6	1	trunk	56	\N
17	7	1	lmask	0	\N
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


SET search_path = integration, pg_catalog;

--
-- Name: ULines_pkey; Type: CONSTRAINT; Schema: integration; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY ulines
    ADD CONSTRAINT "ULines_pkey" PRIMARY KEY (id);


--
-- Name: recordings_pkey; Type: CONSTRAINT; Schema: integration; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY recordings
    ADD CONSTRAINT recordings_pkey PRIMARY KEY (id);


--
-- Name: workplaces_pkey; Type: CONSTRAINT; Schema: integration; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY workplaces
    ADD CONSTRAINT workplaces_pkey PRIMARY KEY (id);


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
-- Name: callerid_pkey; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY callerid
    ADD CONSTRAINT callerid_pkey PRIMARY KEY (id);


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


SET search_path = integration, pg_catalog;

--
-- Name: workplaces_sip_id_fkey; Type: FK CONSTRAINT; Schema: integration; Owner: asterisk
--

ALTER TABLE ONLY workplaces
    ADD CONSTRAINT workplaces_sip_id_fkey FOREIGN KEY (sip_id) REFERENCES public.sip_peers(id);


SET search_path = routing, pg_catalog;

--
-- Name: callerid_direction_id_fkey; Type: FK CONSTRAINT; Schema: routing; Owner: asterisk
--

ALTER TABLE ONLY callerid
    ADD CONSTRAINT callerid_direction_id_fkey FOREIGN KEY (direction_id) REFERENCES directions_list(dlist_id);


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

