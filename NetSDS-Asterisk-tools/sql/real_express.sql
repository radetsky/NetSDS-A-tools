--
-- PostgreSQL database dump
--

-- Dumped from database version 9.0.4
-- Dumped by pg_dump version 9.0.3
-- Started on 2012-01-09 13:56:35 EET

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 6 (class 2615 OID 16717)
-- Name: integration; Type: SCHEMA; Schema: -; Owner: asterisk
--

CREATE SCHEMA integration;


ALTER SCHEMA integration OWNER TO asterisk;

--
-- TOC entry 2084 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA integration; Type: COMMENT; Schema: -; Owner: asterisk
--

COMMENT ON SCHEMA integration IS 'Сюда пишем всякие таблицы по интеграции и т.д. ';


--
-- TOC entry 7 (class 2615 OID 16718)
-- Name: ivr; Type: SCHEMA; Schema: -; Owner: asterisk
--

CREATE SCHEMA ivr;


ALTER SCHEMA ivr OWNER TO asterisk;

--
-- TOC entry 8 (class 2615 OID 16719)
-- Name: routing; Type: SCHEMA; Schema: -; Owner: asterisk
--

CREATE SCHEMA routing;


ALTER SCHEMA routing OWNER TO asterisk;

--
-- TOC entry 393 (class 2612 OID 11574)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = integration, pg_catalog;

--
-- TOC entry 33 (class 1255 OID 16720)
-- Dependencies: 6 393
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
-- TOC entry 2087 (class 0 OID 0)
-- Dependencies: 33
-- Name: FUNCTION get_free_uline(); Type: COMMENT; Schema: integration; Owner: asterisk
--

COMMENT ON FUNCTION get_free_uline() IS 'Изначально просто  select * from integration.ulines where status=''free'' order by id asc limit 1;  а там посмотрим';


SET search_path = public, pg_catalog;

--
-- TOC entry 31 (class 1255 OID 17049)
-- Dependencies: 9 393
-- Name: get_dial_route4(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: asterisk
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

 -- case route_type (trunkgroup) 
 if r.route_type = 'tgrp' then
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


ALTER FUNCTION public.get_dial_route4(peername character varying, exten character varying, current_try integer) OWNER TO asterisk;

--
-- TOC entry 26 (class 1255 OID 16389)
-- Dependencies: 9
-- Name: uuid_generate_v1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_generate_v1() RETURNS uuid
    LANGUAGE c STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v1';


ALTER FUNCTION public.uuid_generate_v1() OWNER TO postgres;

--
-- TOC entry 27 (class 1255 OID 16390)
-- Dependencies: 9
-- Name: uuid_generate_v1mc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_generate_v1mc() RETURNS uuid
    LANGUAGE c STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v1mc';


ALTER FUNCTION public.uuid_generate_v1mc() OWNER TO postgres;

--
-- TOC entry 28 (class 1255 OID 16391)
-- Dependencies: 9
-- Name: uuid_generate_v3(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_generate_v3(namespace uuid, name text) RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v3';


ALTER FUNCTION public.uuid_generate_v3(namespace uuid, name text) OWNER TO postgres;

--
-- TOC entry 29 (class 1255 OID 16392)
-- Dependencies: 9
-- Name: uuid_generate_v4(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_generate_v4() RETURNS uuid
    LANGUAGE c STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v4';


ALTER FUNCTION public.uuid_generate_v4() OWNER TO postgres;

--
-- TOC entry 30 (class 1255 OID 16393)
-- Dependencies: 9
-- Name: uuid_generate_v5(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_generate_v5(namespace uuid, name text) RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v5';


ALTER FUNCTION public.uuid_generate_v5(namespace uuid, name text) OWNER TO postgres;

--
-- TOC entry 18 (class 1255 OID 16384)
-- Dependencies: 9
-- Name: uuid_nil(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_nil() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_nil';


ALTER FUNCTION public.uuid_nil() OWNER TO postgres;

--
-- TOC entry 22 (class 1255 OID 16385)
-- Dependencies: 9
-- Name: uuid_ns_dns(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_ns_dns() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_ns_dns';


ALTER FUNCTION public.uuid_ns_dns() OWNER TO postgres;

--
-- TOC entry 24 (class 1255 OID 16387)
-- Dependencies: 9
-- Name: uuid_ns_oid(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_ns_oid() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_ns_oid';


ALTER FUNCTION public.uuid_ns_oid() OWNER TO postgres;

--
-- TOC entry 23 (class 1255 OID 16386)
-- Dependencies: 9
-- Name: uuid_ns_url(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_ns_url() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_ns_url';


ALTER FUNCTION public.uuid_ns_url() OWNER TO postgres;

--
-- TOC entry 25 (class 1255 OID 16388)
-- Dependencies: 9
-- Name: uuid_ns_x500(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_ns_x500() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_ns_x500';


ALTER FUNCTION public.uuid_ns_x500() OWNER TO postgres;

SET search_path = routing, pg_catalog;

--
-- TOC entry 34 (class 1255 OID 16721)
-- Dependencies: 8 393
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
-- TOC entry 2088 (class 0 OID 0)
-- Dependencies: 34
-- Name: FUNCTION get_callerid(peer_name character varying, number_b character varying); Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON FUNCTION get_callerid(peer_name character varying, number_b character varying) IS 'Находим и подставляем callerid. 
';


--
-- TOC entry 35 (class 1255 OID 16722)
-- Dependencies: 393 8
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
-- TOC entry 2089 (class 0 OID 0)
-- Dependencies: 35
-- Name: FUNCTION get_dial_route(destination character varying, try integer); Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON FUNCTION get_dial_route(destination character varying, try integer) IS 'Main function for this software. Return the name of the peer/user depends on destination number and count of tries. ';


--
-- TOC entry 36 (class 1255 OID 16723)
-- Dependencies: 8 393
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
-- TOC entry 32 (class 1255 OID 17050)
-- Dependencies: 393 8
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
-- TOC entry 37 (class 1255 OID 16724)
-- Dependencies: 8 393
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
-- TOC entry 2090 (class 0 OID 0)
-- Dependencies: 37
-- Name: FUNCTION get_next_trunk_in_group(group_id bigint); Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON FUNCTION get_next_trunk_in_group(group_id bigint) IS 'Возвращает следующий транк в группе. Если дошли по циклу или ошибка, то возвращает -1. ';


--
-- TOC entry 38 (class 1255 OID 16725)
-- Dependencies: 8 393
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
-- TOC entry 2091 (class 0 OID 0)
-- Dependencies: 38
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
-- TOC entry 39 (class 1255 OID 16726)
-- Dependencies: 8 393
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

SET search_path = integration, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1585 (class 1259 OID 16727)
-- Dependencies: 1899 1900 6
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
-- TOC entry 1586 (class 1259 OID 16735)
-- Dependencies: 1585 6
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
-- TOC entry 2092 (class 0 OID 0)
-- Dependencies: 1586
-- Name: recordings_id_seq; Type: SEQUENCE OWNED BY; Schema: integration; Owner: asterisk
--

ALTER SEQUENCE recordings_id_seq OWNED BY recordings.id;


--
-- TOC entry 2093 (class 0 OID 0)
-- Dependencies: 1586
-- Name: recordings_id_seq; Type: SEQUENCE SET; Schema: integration; Owner: asterisk
--

SELECT pg_catalog.setval('recordings_id_seq', 206, true);


--
-- TOC entry 1587 (class 1259 OID 16737)
-- Dependencies: 1902 6
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
-- TOC entry 1588 (class 1259 OID 16744)
-- Dependencies: 1903 1904 6
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
-- TOC entry 1589 (class 1259 OID 16752)
-- Dependencies: 1588 6
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
-- TOC entry 2094 (class 0 OID 0)
-- Dependencies: 1589
-- Name: workplaces_id_seq; Type: SEQUENCE OWNED BY; Schema: integration; Owner: asterisk
--

ALTER SEQUENCE workplaces_id_seq OWNED BY workplaces.id;


--
-- TOC entry 2095 (class 0 OID 0)
-- Dependencies: 1589
-- Name: workplaces_id_seq; Type: SEQUENCE SET; Schema: integration; Owner: asterisk
--

SELECT pg_catalog.setval('workplaces_id_seq', 19, true);


SET search_path = public, pg_catalog;

--
-- TOC entry 1590 (class 1259 OID 16754)
-- Dependencies: 1906 1907 9
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
-- TOC entry 1591 (class 1259 OID 16759)
-- Dependencies: 1590 9
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
-- TOC entry 2096 (class 0 OID 0)
-- Dependencies: 1591
-- Name: blacklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE blacklist_id_seq OWNED BY blacklist.id;


--
-- TOC entry 2097 (class 0 OID 0)
-- Dependencies: 1591
-- Name: blacklist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('blacklist_id_seq', 1, false);


--
-- TOC entry 1592 (class 1259 OID 16761)
-- Dependencies: 1909 1910 1911 1912 1913 1914 1915 1916 1917 1918 1919 1920 1921 1922 1923 1924 9
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
-- TOC entry 1593 (class 1259 OID 16783)
-- Dependencies: 1925 1926 1927 1928 9
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
-- TOC entry 1594 (class 1259 OID 16790)
-- Dependencies: 1593 9
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
-- TOC entry 2098 (class 0 OID 0)
-- Dependencies: 1594
-- Name: extensions_conf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE extensions_conf_id_seq OWNED BY extensions_conf.id;


--
-- TOC entry 2099 (class 0 OID 0)
-- Dependencies: 1594
-- Name: extensions_conf_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('extensions_conf_id_seq', 12, true);


--
-- TOC entry 1595 (class 1259 OID 16792)
-- Dependencies: 9
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
-- TOC entry 1596 (class 1259 OID 16795)
-- Dependencies: 1595 9
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
-- TOC entry 2100 (class 0 OID 0)
-- Dependencies: 1596
-- Name: queue_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE queue_log_id_seq OWNED BY queue_log.id;


--
-- TOC entry 2101 (class 0 OID 0)
-- Dependencies: 1596
-- Name: queue_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('queue_log_id_seq', 1, false);


--
-- TOC entry 1597 (class 1259 OID 16797)
-- Dependencies: 9
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
-- TOC entry 1598 (class 1259 OID 16803)
-- Dependencies: 9 1597
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
-- TOC entry 2102 (class 0 OID 0)
-- Dependencies: 1598
-- Name: queue_members_uniqueid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE queue_members_uniqueid_seq OWNED BY queue_members.uniqueid;


--
-- TOC entry 2103 (class 0 OID 0)
-- Dependencies: 1598
-- Name: queue_members_uniqueid_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('queue_members_uniqueid_seq', 21, true);


--
-- TOC entry 1599 (class 1259 OID 16805)
-- Dependencies: 1932 1933 1934 1935 1936 1937 1938 1939 1940 9
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
-- TOC entry 1600 (class 1259 OID 16817)
-- Dependencies: 1599 9
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
-- TOC entry 2104 (class 0 OID 0)
-- Dependencies: 1600
-- Name: queue_parsed_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE queue_parsed_id_seq OWNED BY queue_parsed.id;


--
-- TOC entry 2105 (class 0 OID 0)
-- Dependencies: 1600
-- Name: queue_parsed_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('queue_parsed_id_seq', 1, false);


--
-- TOC entry 1601 (class 1259 OID 16819)
-- Dependencies: 1942 1943 1944 1945 1946 1947 1948 1949 1950 1951 1952 1953 1954 1955 1956 1957 1958 1959 1960 9
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
-- TOC entry 1602 (class 1259 OID 16844)
-- Dependencies: 1961 1962 1963 1964 1965 1966 1967 9
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
-- TOC entry 1603 (class 1259 OID 16857)
-- Dependencies: 1602 9
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
-- TOC entry 2106 (class 0 OID 0)
-- Dependencies: 1603
-- Name: sip_conf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE sip_conf_id_seq OWNED BY sip_conf.id;


--
-- TOC entry 2107 (class 0 OID 0)
-- Dependencies: 1603
-- Name: sip_conf_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('sip_conf_id_seq', 30, true);


--
-- TOC entry 1604 (class 1259 OID 16859)
-- Dependencies: 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1995 9
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
-- TOC entry 1605 (class 1259 OID 16890)
-- Dependencies: 1604 9
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
-- TOC entry 2108 (class 0 OID 0)
-- Dependencies: 1605
-- Name: sip_peers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE sip_peers_id_seq OWNED BY sip_peers.id;


--
-- TOC entry 2109 (class 0 OID 0)
-- Dependencies: 1605
-- Name: sip_peers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('sip_peers_id_seq', 104, true);


--
-- TOC entry 1606 (class 1259 OID 16892)
-- Dependencies: 1996 1997 9
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
-- TOC entry 1607 (class 1259 OID 16897)
-- Dependencies: 1606 9
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
-- TOC entry 2110 (class 0 OID 0)
-- Dependencies: 1607
-- Name: whitelist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE whitelist_id_seq OWNED BY whitelist.id;


--
-- TOC entry 2111 (class 0 OID 0)
-- Dependencies: 1607
-- Name: whitelist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('whitelist_id_seq', 1, false);


SET search_path = routing, pg_catalog;

--
-- TOC entry 1608 (class 1259 OID 16899)
-- Dependencies: 1999 8
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
-- TOC entry 2112 (class 0 OID 0)
-- Dependencies: 1608
-- Name: TABLE callerid; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE callerid IS 'Таблица подстановок CALLERID. 
Пример: 
По направлению  DR_ID, юзер/пир SIP_PEER_ID требует установки CALLERID = XXXX. 
Если правило найдено, то CALLERID устанавливаем, а если не найдено, то не трогаем вообще. 

Если SIP_ID is NULL, то устанавливаем правило несмотря на того, кто звонит. Очень удобно для корпоративов. Если нужно подставить значение, которое общее для всех. Все равно сначала ищем "для конкретного человека", а потом "для всего кагала". 
';


--
-- TOC entry 1609 (class 1259 OID 16906)
-- Dependencies: 8 1608
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
-- TOC entry 2113 (class 0 OID 0)
-- Dependencies: 1609
-- Name: callerid_id_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE callerid_id_seq OWNED BY callerid.id;


--
-- TOC entry 2114 (class 0 OID 0)
-- Dependencies: 1609
-- Name: callerid_id_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('callerid_id_seq', 32, true);


--
-- TOC entry 1610 (class 1259 OID 16908)
-- Dependencies: 2001 8
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
-- TOC entry 2115 (class 0 OID 0)
-- Dependencies: 1610
-- Name: TABLE directions; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE directions IS 'Список направлений. Направление характеризуется: 
1. Префиксом 
2. Названием
3. Приоритетом. ';


--
-- TOC entry 2116 (class 0 OID 0)
-- Dependencies: 1610
-- Name: COLUMN directions.dr_list_item; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON COLUMN directions.dr_list_item IS 'Ссылка на список названий. ';


--
-- TOC entry 2117 (class 0 OID 0)
-- Dependencies: 1610
-- Name: COLUMN directions.dr_prefix; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON COLUMN directions.dr_prefix IS 'Таки префикс, вплоть до самого номера. 067
067220 
0672201 :) ';


--
-- TOC entry 2118 (class 0 OID 0)
-- Dependencies: 1610
-- Name: COLUMN directions.dr_prio; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON COLUMN directions.dr_prio IS 'Приоритет маршрутизации. Чем меньше значение, тем выше приоритет. Пример: 
067       Киевстар            5
067220 Сотрудники_КС 1 

При выборе направления выбираем по regexp и order by prio. 

В данном примере будет 06722067 будет выбран 067220. ';


--
-- TOC entry 1611 (class 1259 OID 16912)
-- Dependencies: 8 1610
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
-- TOC entry 2119 (class 0 OID 0)
-- Dependencies: 1611
-- Name: directions_dr_id_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE directions_dr_id_seq OWNED BY directions.dr_id;


--
-- TOC entry 2120 (class 0 OID 0)
-- Dependencies: 1611
-- Name: directions_dr_id_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('directions_dr_id_seq', 73, true);


--
-- TOC entry 1612 (class 1259 OID 16914)
-- Dependencies: 8
-- Name: directions_list; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE directions_list (
    dlist_id bigint NOT NULL,
    dlist_name character varying(32) NOT NULL
);


ALTER TABLE routing.directions_list OWNER TO asterisk;

--
-- TOC entry 2121 (class 0 OID 0)
-- Dependencies: 1612
-- Name: TABLE directions_list; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE directions_list IS 'Просто список с уникальными названиями и PK';


--
-- TOC entry 1613 (class 1259 OID 16917)
-- Dependencies: 8 1612
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
-- TOC entry 2122 (class 0 OID 0)
-- Dependencies: 1613
-- Name: directions_list_DLIST_ID_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE "directions_list_DLIST_ID_seq" OWNED BY directions_list.dlist_id;


--
-- TOC entry 2123 (class 0 OID 0)
-- Dependencies: 1613
-- Name: directions_list_DLIST_ID_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('"directions_list_DLIST_ID_seq"', 16, true);


--
-- TOC entry 1614 (class 1259 OID 16919)
-- Dependencies: 8
-- Name: permissions; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE permissions (
    id bigint NOT NULL,
    direction_id bigint,
    peer_id bigint
);


ALTER TABLE routing.permissions OWNER TO asterisk;

--
-- TOC entry 2124 (class 0 OID 0)
-- Dependencies: 1614
-- Name: TABLE permissions; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE permissions IS 'Права доступа к разным направлениям для peers/users. ';


--
-- TOC entry 1615 (class 1259 OID 16923)
-- Dependencies: 8 1614
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
-- TOC entry 2125 (class 0 OID 0)
-- Dependencies: 1615
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE permissions_id_seq OWNED BY permissions.id;


--
-- TOC entry 2126 (class 0 OID 0)
-- Dependencies: 1615
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('permissions_id_seq', 121, true);


--
-- TOC entry 1616 (class 1259 OID 16925)
-- Dependencies: 2005 2007 2008 8
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
    CONSTRAINT route_type_check CHECK ((((((route_type)::text = 'user'::text) OR ((route_type)::text = 'context'::text)) OR ((route_type)::text = 'trunk'::text)) OR ((route_type)::text = 'tgrp'::text)))
);


ALTER TABLE routing.route OWNER TO asterisk;

--
-- TOC entry 2127 (class 0 OID 0)
-- Dependencies: 1616
-- Name: TABLE route; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE route IS 'Таблица маршрутизации. 
Направление, приоритет, транк/группа/контекст, название.';


--
-- TOC entry 2128 (class 0 OID 0)
-- Dependencies: 1616
-- Name: COLUMN route.route_step; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON COLUMN route.route_step IS 'Шаг. Попытка. Обычно не более 5.';


--
-- TOC entry 1617 (class 1259 OID 16931)
-- Dependencies: 8 1616
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
-- TOC entry 2129 (class 0 OID 0)
-- Dependencies: 1617
-- Name: route_route_id_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE route_route_id_seq OWNED BY route.route_id;


--
-- TOC entry 2130 (class 0 OID 0)
-- Dependencies: 1617
-- Name: route_route_id_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('route_route_id_seq', 121, true);


--
-- TOC entry 1618 (class 1259 OID 16933)
-- Dependencies: 2009 8
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
-- TOC entry 2131 (class 0 OID 0)
-- Dependencies: 1618
-- Name: TABLE trunkgroup_items; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE trunkgroup_items IS 'Взяимосвязь между trunkgroups && sip_peers';


--
-- TOC entry 1619 (class 1259 OID 16937)
-- Dependencies: 8 1618
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
-- TOC entry 2132 (class 0 OID 0)
-- Dependencies: 1619
-- Name: trunkgroup_items_tgrp_item_id_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE trunkgroup_items_tgrp_item_id_seq OWNED BY trunkgroup_items.tgrp_item_id;


--
-- TOC entry 2133 (class 0 OID 0)
-- Dependencies: 1619
-- Name: trunkgroup_items_tgrp_item_id_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('trunkgroup_items_tgrp_item_id_seq', 21, true);


--
-- TOC entry 1620 (class 1259 OID 16939)
-- Dependencies: 8
-- Name: trunkgroups; Type: TABLE; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE TABLE trunkgroups (
    tgrp_id bigint NOT NULL,
    tgrp_name character varying(32) NOT NULL
);


ALTER TABLE routing.trunkgroups OWNER TO asterisk;

--
-- TOC entry 2134 (class 0 OID 0)
-- Dependencies: 1620
-- Name: TABLE trunkgroups; Type: COMMENT; Schema: routing; Owner: asterisk
--

COMMENT ON TABLE trunkgroups IS 'Список транкгрупп';


--
-- TOC entry 1621 (class 1259 OID 16942)
-- Dependencies: 8 1620
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
-- TOC entry 2135 (class 0 OID 0)
-- Dependencies: 1621
-- Name: trunkgroups_tgrp_id_seq; Type: SEQUENCE OWNED BY; Schema: routing; Owner: asterisk
--

ALTER SEQUENCE trunkgroups_tgrp_id_seq OWNED BY trunkgroups.tgrp_id;


--
-- TOC entry 2136 (class 0 OID 0)
-- Dependencies: 1621
-- Name: trunkgroups_tgrp_id_seq; Type: SEQUENCE SET; Schema: routing; Owner: asterisk
--

SELECT pg_catalog.setval('trunkgroups_tgrp_id_seq', 9, true);


SET search_path = integration, pg_catalog;

--
-- TOC entry 1901 (class 2604 OID 16944)
-- Dependencies: 1586 1585
-- Name: id; Type: DEFAULT; Schema: integration; Owner: asterisk
--

ALTER TABLE recordings ALTER COLUMN id SET DEFAULT nextval('recordings_id_seq'::regclass);


--
-- TOC entry 1905 (class 2604 OID 16945)
-- Dependencies: 1589 1588
-- Name: id; Type: DEFAULT; Schema: integration; Owner: asterisk
--

ALTER TABLE workplaces ALTER COLUMN id SET DEFAULT nextval('workplaces_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- TOC entry 1908 (class 2604 OID 16946)
-- Dependencies: 1591 1590
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE blacklist ALTER COLUMN id SET DEFAULT nextval('blacklist_id_seq'::regclass);


--
-- TOC entry 1929 (class 2604 OID 16947)
-- Dependencies: 1594 1593
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE extensions_conf ALTER COLUMN id SET DEFAULT nextval('extensions_conf_id_seq'::regclass);


--
-- TOC entry 1930 (class 2604 OID 16948)
-- Dependencies: 1596 1595
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE queue_log ALTER COLUMN id SET DEFAULT nextval('queue_log_id_seq'::regclass);


--
-- TOC entry 1931 (class 2604 OID 16949)
-- Dependencies: 1598 1597
-- Name: uniqueid; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE queue_members ALTER COLUMN uniqueid SET DEFAULT nextval('queue_members_uniqueid_seq'::regclass);


--
-- TOC entry 1941 (class 2604 OID 16950)
-- Dependencies: 1600 1599
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE queue_parsed ALTER COLUMN id SET DEFAULT nextval('queue_parsed_id_seq'::regclass);


--
-- TOC entry 1968 (class 2604 OID 16951)
-- Dependencies: 1603 1602
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE sip_conf ALTER COLUMN id SET DEFAULT nextval('sip_conf_id_seq'::regclass);


--
-- TOC entry 1994 (class 2604 OID 16952)
-- Dependencies: 1605 1604
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE sip_peers ALTER COLUMN id SET DEFAULT nextval('sip_peers_id_seq'::regclass);


--
-- TOC entry 1998 (class 2604 OID 16953)
-- Dependencies: 1607 1606
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE whitelist ALTER COLUMN id SET DEFAULT nextval('whitelist_id_seq'::regclass);


SET search_path = routing, pg_catalog;

--
-- TOC entry 2000 (class 2604 OID 16954)
-- Dependencies: 1609 1608
-- Name: id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE callerid ALTER COLUMN id SET DEFAULT nextval('callerid_id_seq'::regclass);


--
-- TOC entry 2002 (class 2604 OID 16955)
-- Dependencies: 1611 1610
-- Name: dr_id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE directions ALTER COLUMN dr_id SET DEFAULT nextval('directions_dr_id_seq'::regclass);


--
-- TOC entry 2003 (class 2604 OID 16956)
-- Dependencies: 1613 1612
-- Name: dlist_id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE directions_list ALTER COLUMN dlist_id SET DEFAULT nextval('"directions_list_DLIST_ID_seq"'::regclass);


--
-- TOC entry 2004 (class 2604 OID 16957)
-- Dependencies: 1615 1614
-- Name: id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE permissions ALTER COLUMN id SET DEFAULT nextval('permissions_id_seq'::regclass);


--
-- TOC entry 2006 (class 2604 OID 16958)
-- Dependencies: 1617 1616
-- Name: route_id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE route ALTER COLUMN route_id SET DEFAULT nextval('route_route_id_seq'::regclass);


--
-- TOC entry 2010 (class 2604 OID 16959)
-- Dependencies: 1619 1618
-- Name: tgrp_item_id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE trunkgroup_items ALTER COLUMN tgrp_item_id SET DEFAULT nextval('trunkgroup_items_tgrp_item_id_seq'::regclass);


--
-- TOC entry 2011 (class 2604 OID 16960)
-- Dependencies: 1621 1620
-- Name: tgrp_id; Type: DEFAULT; Schema: routing; Owner: asterisk
--

ALTER TABLE trunkgroups ALTER COLUMN tgrp_id SET DEFAULT nextval('trunkgroups_tgrp_id_seq'::regclass);


SET search_path = integration, pg_catalog;

--
-- TOC entry 2061 (class 0 OID 16727)
-- Dependencies: 1585
-- Data for Name: recordings; Type: TABLE DATA; Schema: integration; Owner: asterisk
--

INSERT INTO recordings VALUES (36, 1, '2011/12/31/125157-1003.wav', true, 'FAULT', 35, 38);
INSERT INTO recordings VALUES (38, 1, '2011/12/31/125256-201.wav', true, 'FAULT', 36, 40);
INSERT INTO recordings VALUES (94, 2, '2012/01/03/162359-3039338.wav', true, '2012/01/03/162359-3039338.mp3', 0, 0);
INSERT INTO recordings VALUES (40, 1, '2011/12/31/125326-201.wav', true, 'FAULT', 38, 0);
INSERT INTO recordings VALUES (45, 1, '2011/12/31/140639-1003.wav', true, 'FAULT', 44, 47);
INSERT INTO recordings VALUES (47, 1, '2011/12/31/140714-201.wav', true, 'FAULT', 45, 49);
INSERT INTO recordings VALUES (49, 1, '2011/12/31/140731-201.wav', true, 'FAULT', 47, 0);
INSERT INTO recordings VALUES (50, 1, '2011/12/31/141601-1003.wav', true, '2011/12/31/141601-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (51, 1, '2011/12/31/142102-1003.wav', true, '2011/12/31/142102-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (52, 1, '2011/12/31/142241-1003.wav', true, '2011/12/31/142241-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (53, 1, '2011/12/31/142511-1003.wav', true, '2011/12/31/142511-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (54, 1, '2011/12/31/144310-1003.wav', true, '2011/12/31/144310-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (55, 1, '2011/12/31/144411-1003.wav', true, '2011/12/31/144411-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (56, 1, '2011/12/31/144558-1003.wav', true, '2011/12/31/144558-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (57, 1, '2011/12/31/145204-1003.wav', true, '2011/12/31/145204-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (96, 1, '2012/01/03/162600-201.wav', true, '2012/01/03/162600-201.mp3', 0, 0);
INSERT INTO recordings VALUES (1, 18, '2011/12/17/195449-1003.wav', true, '2011/12/17/195449-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (2, 19, '2011/12/17/195548-1003.wav', true, '2011/12/17/195548-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (3, 20, '2011/12/17/195610-201.wav', true, '2011/12/17/195610-201.mp3', 0, 0);
INSERT INTO recordings VALUES (73, 1, '2012/01/02/204717-201.wav', true, '2012/01/02/204717-201.mp3', 0, 0);
INSERT INTO recordings VALUES (80, 2, '2012/01/02/204857-201.wav', true, '2012/01/02/204717-3039338.mp3', 78, 0);
INSERT INTO recordings VALUES (4, 21, '2011/12/17/195816-1003.wav', true, '2011/12/17/195816-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (5, 22, '2011/12/17/200255-1003.wav', true, '2011/12/17/200255-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (6, 23, '2011/12/17/200546-1003.wav', true, '2011/12/17/200546-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (9, 26, '2011/12/17/201210-1003.wav', true, '/var/spool/asterisk/monitor/2011/12/17/201210-1003.mp3', 0, 10);
INSERT INTO recordings VALUES (10, 26, '2011/12/17/201211-1003.wav', true, '/var/spool/asterisk/monitor/2011/12/17/201210-1003.mp3', 9, 0);
INSERT INTO recordings VALUES (11, 27, '2011/12/17/201301-201.wav', true, '2011/12/17/201301-201.mp3', 0, 0);
INSERT INTO recordings VALUES (12, 28, '2011/12/17/201330-201.wav', true, '2011/12/17/201330-201.mp3', 0, 0);
INSERT INTO recordings VALUES (75, 1, '2012/01/02/204820-201.wav', true, '2012/01/02/204820-201.mp3', 0, 76);
INSERT INTO recordings VALUES (58, 1, '2011/12/31/145305-1003.wav', true, '2011/12/31/145305-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (59, 1, '2011/12/31/145416-1003.wav', true, '2011/12/31/145416-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (76, 1, '2012/01/02/204820-201.wav', true, '2012/01/02/204820-201.mp3', 75, 0);
INSERT INTO recordings VALUES (79, 1, '2012/01/02/204857-201.wav', true, '2012/01/02/204857-201.mp3', 0, 0);
INSERT INTO recordings VALUES (60, 1, '2011/12/31/145452-1003.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (98, 1, '2012/01/03/163955-201.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (100, 1, '2012/01/03/164910-201.wav', true, '2012/01/03/164910-201.mp3', 0, 0);
INSERT INTO recordings VALUES (82, 1, '2012/01/02/205701-1003.wav', true, '2012/01/02/205700-1003.mp3', 81, 84);
INSERT INTO recordings VALUES (86, 1, '2012/01/02/205716-201.wav', true, '2012/01/02/205700-1003.mp3', 84, 88);
INSERT INTO recordings VALUES (85, 2, '2012/01/02/205716-201.wav', true, '2012/01/02/205716-201.mp3', 0, 0);
INSERT INTO recordings VALUES (92, 2, '2012/01/03/153016-201.wav', true, '2012/01/03/152947-3039338.mp3', 90, 0);
INSERT INTO recordings VALUES (61, 1, '2011/12/31/145509-1003.wav', true, '2011/12/31/145509-1003.mp3', 0, 62);
INSERT INTO recordings VALUES (91, 1, '2012/01/03/153016-201.wav', true, '2012/01/03/153016-201.mp3', 0, 0);
INSERT INTO recordings VALUES (13, 29, '2011/12/20/200417-1003.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (62, 1, '2011/12/31/145509-1003.wav', true, '2011/12/31/145509-1003.mp3', 61, 64);
INSERT INTO recordings VALUES (64, 1, '2011/12/31/145525-201.wav', true, '2011/12/31/145509-1003.mp3', 62, 66);
INSERT INTO recordings VALUES (66, 1, '2011/12/31/145535-201.wav', true, '2011/12/31/145509-1003.mp3', 64, 0);
INSERT INTO recordings VALUES (63, 2, '2011/12/31/145525-201.wav', true, '2011/12/31/145525-201.mp3', 0, 0);
INSERT INTO recordings VALUES (65, 3, '2011/12/31/145535-201.wav', true, '2011/12/31/145535-201.mp3', 0, 0);
INSERT INTO recordings VALUES (67, 3, '2012/01/02/133242-1003.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (69, 1, '2012/01/02/140153-1003.wav', true, '2012/01/02/140153-1003.mp3', 0, 70);
INSERT INTO recordings VALUES (72, 1, '2012/01/02/140213-201.wav', true, '2012/01/02/140153-1003.mp3', 70, 0);
INSERT INTO recordings VALUES (71, 2, '2012/01/02/140213-201.wav', true, '2012/01/02/140213-201.mp3', 0, 0);
INSERT INTO recordings VALUES (103, 2, '2012/01/03/164959-201.wav', true, '2012/01/03/164910-3039338.mp3', 101, 105);
INSERT INTO recordings VALUES (14, 1, '2011/12/20/201433-1003.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (22, 1, '2011/12/31/123337-1003.wav', true, '2011/12/31/123337-1003.mp3', 21, 24);
INSERT INTO recordings VALUES (24, 1, '2011/12/31/123411-201.wav', true, '2011/12/31/123337-1003.mp3', 22, 26);
INSERT INTO recordings VALUES (26, 1, '2011/12/31/123446-201.wav', true, '2011/12/31/123337-1003.mp3', 24, 0);
INSERT INTO recordings VALUES (106, 1, '2012/01/03/170142-201.wav', true, '2012/01/03/170142-201.mp3', 0, 0);
INSERT INTO recordings VALUES (102, 1, '2012/01/03/164959-201.wav', true, '2012/01/03/164959-201.mp3', 0, 0);
INSERT INTO recordings VALUES (108, 1, '2012/01/03/175605-1003.wav', true, '2012/01/03/175605-1003.mp3', 0, 109);
INSERT INTO recordings VALUES (110, 2, '2012/01/03/175625-201.wav', true, '2012/01/03/175625-201.mp3', 0, 0);
INSERT INTO recordings VALUES (114, 1, '2012/01/03/175645-201.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (116, 1, '2012/01/03/175654-3039338.wav', true, '2012/01/03/175654-201.mp3', 115, 0);
INSERT INTO recordings VALUES (119, 1, '2012/01/03/175754-201.wav', true, '2012/01/03/175754-201.mp3', 0, 120);
INSERT INTO recordings VALUES (120, 1, '2012/01/03/175754-201.wav', true, '2012/01/03/175754-201.mp3', 119, 0);
INSERT INTO recordings VALUES (125, 1, '2012/01/03/202810-3039338.wav', true, '2012/01/03/202810-201.mp3', 124, 0);
INSERT INTO recordings VALUES (89, 1, '2012/01/03/152947-201.wav', true, '2012/01/03/152947-201.mp3', 0, 0);
INSERT INTO recordings VALUES (111, 1, '2012/01/03/175625-201.wav', true, '2012/01/03/175605-1003.mp3', 109, 113);
INSERT INTO recordings VALUES (128, 1, '2012/01/03/204627-1003.wav', true, '2012/01/03/204627-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (23, 2, '2011/12/31/123411-201.wav', true, '2011/12/31/123411-201.mp3', 0, 0);
INSERT INTO recordings VALUES (25, 3, '2011/12/31/123446-201.wav', true, '2011/12/31/123446-201.mp3', 0, 0);
INSERT INTO recordings VALUES (27, 1, '2011/12/31/123809-1003.wav', true, '2011/12/31/123809-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (28, 1, '2011/12/31/123909-1003.wav', true, '2011/12/31/123909-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (29, 1, '2011/12/31/124821-1003.wav', true, '2011/12/31/124821-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (30, 1, '2011/12/31/125112-1003.wav', true, '2011/12/31/125112-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (95, 1, '2012/01/03/162503-201.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (97, 1, '2012/01/03/162600-3039338.wav', true, '2012/01/03/162600-3039338.mp3', 0, 0);
INSERT INTO recordings VALUES (118, 1, '2012/01/03/175740-201.wav', true, '2012/01/03/175740-201.mp3', 117, 0);
INSERT INTO recordings VALUES (121, 1, '2012/01/03/175804-201.wav', true, '2012/01/03/175804-201.mp3', 0, 122);
INSERT INTO recordings VALUES (122, 1, '2012/01/03/175804-201.wav', true, '2012/01/03/175804-201.mp3', 121, 0);
INSERT INTO recordings VALUES (130, 1, '2012/01/03/205044-1003.wav', true, '2012/01/03/205044-1003.mp3', 0, 131);
INSERT INTO recordings VALUES (126, 1, '2012/01/03/202920-201.wav', true, '2012/01/03/202920-201.mp3', 0, 127);
INSERT INTO recordings VALUES (7, 24, '2011/12/17/200733-1003.wav', true, '2011/12/17/200733-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (8, 25, '2011/12/17/200752-201.wav', true, '2011/12/17/200752-201.mp3', 0, 0);
INSERT INTO recordings VALUES (15, 1, '2011/12/20/201447-1003.wav', true, '2011/12/20/201447-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (16, 1, '2011/12/21/190827-1003.wav', true, '2011/12/21/190827-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (17, 2, '2011/12/21/194212-1003.wav', true, '2011/12/21/194212-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (18, 3, '2011/12/21/195705-1003.wav', true, '2011/12/21/195705-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (19, 1, '2011/12/29/115138-1003.wav', true, '2011/12/29/115138-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (20, 1, '2011/12/29/115231-1003.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (21, 1, '2011/12/31/123337-1003.wav', true, '2011/12/31/123337-1003.mp3', 0, 22);
INSERT INTO recordings VALUES (31, 1, '2011/12/31/125140-1003.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (32, 1, '2011/12/31/125146-1003.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (33, 1, '2011/12/31/125149-1003.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (34, 1, '2011/12/31/125153-1003.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (35, 1, '2011/12/31/125156-1003.wav', true, 'FAULT', 0, 36);
INSERT INTO recordings VALUES (37, 2, '2011/12/31/125256-201.wav', true, '2011/12/31/125256-201.mp3', 0, 0);
INSERT INTO recordings VALUES (39, 2, '2011/12/31/125326-201.wav', true, '2011/12/31/125326-201.mp3', 0, 0);
INSERT INTO recordings VALUES (41, 1, '2011/12/31/134007-201.wav', true, '2011/12/31/134007-201.mp3', 0, 0);
INSERT INTO recordings VALUES (42, 1, '2011/12/31/140505-201.wav', true, '2011/12/31/140505-201.mp3', 0, 0);
INSERT INTO recordings VALUES (43, 1, '2011/12/31/140550-201.wav', true, '2011/12/31/140550-201.mp3', 0, 0);
INSERT INTO recordings VALUES (44, 1, '2011/12/31/140639-1003.wav', true, 'FAULT', 0, 45);
INSERT INTO recordings VALUES (46, 2, '2011/12/31/140714-201.wav', true, '2011/12/31/140714-201.mp3', 0, 0);
INSERT INTO recordings VALUES (48, 2, '2011/12/31/140731-201.wav', true, '2011/12/31/140731-201.mp3', 0, 0);
INSERT INTO recordings VALUES (68, 3, '2012/01/02/133305-1003.wav', true, '2012/01/02/133305-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (70, 1, '2012/01/02/140153-1003.wav', true, '2012/01/02/140153-1003.mp3', 69, 72);
INSERT INTO recordings VALUES (74, 2, '2012/01/02/204717-3039338.wav', true, '2012/01/02/204717-3039338.mp3', 0, 78);
INSERT INTO recordings VALUES (78, 2, '2012/01/02/204827-201.wav', true, '2012/01/02/204717-3039338.mp3', 74, 80);
INSERT INTO recordings VALUES (77, 1, '2012/01/02/204827-201.wav', true, '2012/01/02/204827-201.mp3', 0, 0);
INSERT INTO recordings VALUES (129, 2, '2012/01/03/204702-201.wav', true, '2012/01/03/204702-201.mp3', 0, 0);
INSERT INTO recordings VALUES (131, 1, '2012/01/03/205044-1003.wav', true, '2012/01/03/205044-1003.mp3', 130, 133);
INSERT INTO recordings VALUES (81, 1, '2012/01/02/205700-1003.wav', true, '2012/01/02/205700-1003.mp3', 0, 82);
INSERT INTO recordings VALUES (84, 1, '2012/01/02/205710-201.wav', true, '2012/01/02/205700-1003.mp3', 82, 86);
INSERT INTO recordings VALUES (88, 1, '2012/01/02/205722-201.wav', true, '2012/01/02/205700-1003.mp3', 86, 0);
INSERT INTO recordings VALUES (83, 2, '2012/01/02/205710-201.wav', true, '2012/01/02/205710-201.mp3', 0, 0);
INSERT INTO recordings VALUES (87, 2, '2012/01/02/205722-201.wav', true, '2012/01/02/205722-201.mp3', 0, 0);
INSERT INTO recordings VALUES (132, 2, '2012/01/03/205203-201.wav', true, '2012/01/03/205203-201.mp3', 0, 0);
INSERT INTO recordings VALUES (90, 2, '2012/01/03/152947-3039338.wav', true, '2012/01/03/152947-3039338.mp3', 0, 92);
INSERT INTO recordings VALUES (93, 1, '2012/01/03/162359-201.wav', true, '2012/01/03/162359-201.mp3', 0, 0);
INSERT INTO recordings VALUES (99, 1, '2012/01/03/164008-201.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (101, 2, '2012/01/03/164910-3039338.wav', true, '2012/01/03/164910-3039338.mp3', 0, 103);
INSERT INTO recordings VALUES (105, 2, '2012/01/03/165018-201.wav', true, '2012/01/03/164910-3039338.mp3', 103, 0);
INSERT INTO recordings VALUES (104, 1, '2012/01/03/165018-201.wav', true, '2012/01/03/165018-201.mp3', 0, 0);
INSERT INTO recordings VALUES (107, 1, '2012/01/03/170142-3039338.wav', true, '2012/01/03/170142-3039338.mp3', 0, 0);
INSERT INTO recordings VALUES (109, 1, '2012/01/03/175605-1003.wav', true, '2012/01/03/175605-1003.mp3', 108, 111);
INSERT INTO recordings VALUES (113, 1, '2012/01/03/175634-201.wav', true, '2012/01/03/175605-1003.mp3', 111, 0);
INSERT INTO recordings VALUES (112, 2, '2012/01/03/175634-201.wav', true, '2012/01/03/175634-201.mp3', 0, 0);
INSERT INTO recordings VALUES (115, 1, '2012/01/03/175654-201.wav', true, '2012/01/03/175654-201.mp3', 0, 116);
INSERT INTO recordings VALUES (117, 1, '2012/01/03/175740-201.wav', true, '2012/01/03/175740-201.mp3', 0, 118);
INSERT INTO recordings VALUES (134, 2, '2012/01/03/205253-201.wav', true, '2012/01/03/205253-201.mp3', 0, 0);
INSERT INTO recordings VALUES (140, 1, '2012/01/03/210240-201.wav', true, '2012/01/03/210218-1003.mp3', 137, 142);
INSERT INTO recordings VALUES (123, 1, '2012/01/03/202507-201.wav', true, '2012/01/03/202507-201.mp3', 0, 0);
INSERT INTO recordings VALUES (124, 1, '2012/01/03/202810-201.wav', true, '2012/01/03/202810-201.mp3', 0, 125);
INSERT INTO recordings VALUES (127, 1, '2012/01/03/202920-201.wav', true, '2012/01/03/202920-201.mp3', 126, 0);
INSERT INTO recordings VALUES (133, 1, '2012/01/03/205203-201.wav', true, '2012/01/03/205044-1003.mp3', 131, 135);
INSERT INTO recordings VALUES (135, 1, '2012/01/03/205253-201.wav', true, '2012/01/03/205044-1003.mp3', 133, 0);
INSERT INTO recordings VALUES (138, 2, '2012/01/03/210218-1003.wav', true, '2012/01/03/210218-1003.mp3', 0, 144);
INSERT INTO recordings VALUES (167, 1, '2012/01/03/214113-201.wav', true, '2012/01/03/213832-201.mp3', 165, 0);
INSERT INTO recordings VALUES (162, 2, '2012/01/03/214044-201.wav', true, '2012/01/03/214044-201.mp3', 0, 0);
INSERT INTO recordings VALUES (164, 2, '2012/01/03/214104-201.wav', true, '2012/01/03/214104-201.mp3', 0, 0);
INSERT INTO recordings VALUES (166, 2, '2012/01/03/214113-201.wav', true, '2012/01/03/214113-201.mp3', 0, 0);
INSERT INTO recordings VALUES (197, 2, '2012/01/04/190838-201.wav', true, '2012/01/04/190838-201.mp3', 0, 0);
INSERT INTO recordings VALUES (188, 1, '2012/01/04/184557-1003.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (136, 1, '2012/01/03/210111-1003.wav', true, '2012/01/03/210111-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (137, 1, '2012/01/03/210218-1003.wav', true, '2012/01/03/210218-1003.mp3', 0, 140);
INSERT INTO recordings VALUES (142, 1, '2012/01/03/210248-201.wav', true, '2012/01/03/210218-1003.mp3', 140, 0);
INSERT INTO recordings VALUES (144, 2, '2012/01/03/210251-201.wav', true, '2012/01/03/210218-1003.mp3', 138, 0);
INSERT INTO recordings VALUES (139, 3, '2012/01/03/210240-201.wav', true, '2012/01/03/210240-201.mp3', 0, 0);
INSERT INTO recordings VALUES (141, 3, '2012/01/03/210248-201.wav', true, '2012/01/03/210248-201.mp3', 0, 0);
INSERT INTO recordings VALUES (143, 3, '2012/01/03/210251-201.wav', true, '2012/01/03/210251-201.mp3', 0, 0);
INSERT INTO recordings VALUES (145, 1, '2012/01/03/210649-1003.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (146, 1, '2012/01/03/210823-1003.wav', true, '2012/01/03/210823-1003.mp3', 0, 148);
INSERT INTO recordings VALUES (148, 1, '2012/01/03/210945-201.wav', true, '2012/01/03/210823-1003.mp3', 146, 0);
INSERT INTO recordings VALUES (147, 2, '2012/01/03/210945-201.wav', true, '2012/01/03/210945-201.mp3', 0, 0);
INSERT INTO recordings VALUES (149, 1, '2012/01/03/211040-1003.wav', true, '2012/01/03/211040-1003.mp3', 0, 151);
INSERT INTO recordings VALUES (151, 1, '2012/01/03/211104-201.wav', true, '2012/01/03/211040-1003.mp3', 149, 153);
INSERT INTO recordings VALUES (153, 1, '2012/01/03/211120-201.wav', true, '2012/01/03/211040-1003.mp3', 151, 0);
INSERT INTO recordings VALUES (150, 2, '2012/01/03/211104-201.wav', true, '2012/01/03/211104-201.mp3', 0, 0);
INSERT INTO recordings VALUES (152, 2, '2012/01/03/211120-201.wav', true, '2012/01/03/211120-201.mp3', 0, 0);
INSERT INTO recordings VALUES (168, 1, '2012/01/04/123708-201.wav', true, '2012/01/04/123708-201.mp3', 0, 0);
INSERT INTO recordings VALUES (154, 1, '2012/01/03/211348-201.wav', true, '2012/01/03/211348-201.mp3', 0, 0);
INSERT INTO recordings VALUES (155, 1, '2012/01/03/211348-3039338.wav', true, 'FAULT', 0, 157);
INSERT INTO recordings VALUES (157, 1, '2012/01/03/211511-201.wav', true, 'FAULT', 155, 159);
INSERT INTO recordings VALUES (159, 1, '2012/01/03/211549-201.wav', true, 'FAULT', 157, 0);
INSERT INTO recordings VALUES (169, 1, '2012/01/04/123708-1003.wav', true, 'FAULT', 0, 171);
INSERT INTO recordings VALUES (189, 1, '2012/01/04/185450-1003.wav', true, '2012/01/04/185450-1003.mp3', 0, 0);
INSERT INTO recordings VALUES (175, 1, '2012/01/04/181558-201.wav', true, '2012/01/04/181558-201.mp3', 0, 0);
INSERT INTO recordings VALUES (176, 1, '2012/01/04/182948-201.wav', true, '2012/01/04/182948-201.mp3', 0, 0);
INSERT INTO recordings VALUES (177, 1, '2012/01/04/183027-201.wav', true, '2012/01/04/183027-201.mp3', 0, 179);
INSERT INTO recordings VALUES (179, 1, '2012/01/04/183159-201.wav', true, '2012/01/04/183027-201.mp3', 177, 181);
INSERT INTO recordings VALUES (181, 1, '2012/01/04/183214-201.wav', true, '2012/01/04/183027-201.mp3', 179, 183);
INSERT INTO recordings VALUES (183, 1, '2012/01/04/183249-201.wav', true, '2012/01/04/183027-201.mp3', 181, 185);
INSERT INTO recordings VALUES (156, 2, '2012/01/03/211511-201.wav', true, '2012/01/03/211511-201.mp3', 0, 0);
INSERT INTO recordings VALUES (158, 2, '2012/01/03/211549-201.wav', true, '2012/01/03/211549-201.mp3', 0, 0);
INSERT INTO recordings VALUES (160, 1, '2012/01/03/213753-201.wav', true, '2012/01/03/213753-201.mp3', 0, 0);
INSERT INTO recordings VALUES (161, 1, '2012/01/03/213832-201.wav', true, '2012/01/03/213832-201.mp3', 0, 163);
INSERT INTO recordings VALUES (163, 1, '2012/01/03/214044-201.wav', true, '2012/01/03/213832-201.mp3', 161, 165);
INSERT INTO recordings VALUES (165, 1, '2012/01/03/214104-201.wav', true, '2012/01/03/213832-201.mp3', 163, 167);
INSERT INTO recordings VALUES (171, 1, '2012/01/04/123923-201.wav', true, 'FAULT', 169, 0);
INSERT INTO recordings VALUES (170, 2, '2012/01/04/123923-201.wav', true, '2012/01/04/123923-201.mp3', 0, 0);
INSERT INTO recordings VALUES (172, 1, '2012/01/04/131322-201.wav', true, 'FAULT', 0, 0);
INSERT INTO recordings VALUES (173, 1, '2012/01/04/131829-201.wav', true, '2012/01/04/131829-201.mp3', 0, 0);
INSERT INTO recordings VALUES (174, 1, '2012/01/04/132701-201.wav', true, '2012/01/04/132701-201.mp3', 0, 0);
INSERT INTO recordings VALUES (200, 2, '2012/01/04/201434-201.wav', true, '2012/01/04/201434-201.mp3', 0, 0);
INSERT INTO recordings VALUES (190, 1, '2012/01/04/185705-1003.wav', true, 'FAULT', 0, 192);
INSERT INTO recordings VALUES (193, 1, '2012/01/04/190417-1003.wav', true, '2012/01/04/190417-1003.mp3', 0, 195);
INSERT INTO recordings VALUES (192, 1, '2012/01/04/185823-201.wav', true, 'FAULT', 190, 0);
INSERT INTO recordings VALUES (195, 1, '2012/01/04/190441-201.wav', true, '2012/01/04/190417-1003.mp3', 193, 0);
INSERT INTO recordings VALUES (185, 1, '2012/01/04/183309-201.wav', true, '2012/01/04/183027-201.mp3', 183, 187);
INSERT INTO recordings VALUES (187, 1, '2012/01/04/183335-201.wav', true, '2012/01/04/183027-201.mp3', 185, 0);
INSERT INTO recordings VALUES (178, 2, '2012/01/04/183159-201.wav', true, '2012/01/04/183159-201.mp3', 0, 0);
INSERT INTO recordings VALUES (180, 3, '2012/01/04/183214-201.wav', true, '2012/01/04/183214-201.mp3', 0, 0);
INSERT INTO recordings VALUES (182, 2, '2012/01/04/183249-201.wav', true, '2012/01/04/183249-201.mp3', 0, 0);
INSERT INTO recordings VALUES (184, 2, '2012/01/04/183309-201.wav', true, '2012/01/04/183309-201.mp3', 0, 0);
INSERT INTO recordings VALUES (186, 3, '2012/01/04/183335-201.wav', true, '2012/01/04/183335-201.mp3', 0, 0);
INSERT INTO recordings VALUES (191, 2, '2012/01/04/185823-201.wav', true, '2012/01/04/185823-201.mp3', 0, 0);
INSERT INTO recordings VALUES (194, 2, '2012/01/04/190441-201.wav', true, '2012/01/04/190441-201.mp3', 0, 0);
INSERT INTO recordings VALUES (196, 1, '2012/01/04/190810-1003.wav', true, '2012/01/04/190810-1003.mp3', 0, 198);
INSERT INTO recordings VALUES (198, 1, '2012/01/04/190838-201.wav', true, '2012/01/04/190810-1003.mp3', 196, 0);
INSERT INTO recordings VALUES (199, 1, '2012/01/04/201408-1003.wav', true, '2012/01/04/201408-1003.mp3', 0, 201);
INSERT INTO recordings VALUES (201, 1, '2012/01/04/201434-201.wav', true, '2012/01/04/201408-1003.mp3', 199, 0);
INSERT INTO recordings VALUES (203, 2, '2012/01/04/202103-201.wav', true, '2012/01/04/202103-201.mp3', 0, 0);
INSERT INTO recordings VALUES (205, 3, '2012/01/04/202313-201.wav', true, '2012/01/04/202313-201.mp3', 0, 0);
INSERT INTO recordings VALUES (202, 1, '2012/01/04/202056-1003.wav', true, '2012/01/04/202056-1003.mp3', 0, 204);
INSERT INTO recordings VALUES (204, 1, '2012/01/04/202103-201.wav', true, '2012/01/04/202056-1003.mp3', 202, 206);
INSERT INTO recordings VALUES (206, 1, '2012/01/04/202313-201.wav', true, '2012/01/04/202056-1003.mp3', 204, 0);


--
-- TOC entry 2062 (class 0 OID 16737)
-- Dependencies: 1587
-- Data for Name: ulines; Type: TABLE DATA; Schema: integration; Owner: asterisk
--

INSERT INTO ulines VALUES (67, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (68, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (69, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (70, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (71, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (72, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (73, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (74, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (75, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (76, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (77, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (78, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (79, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (80, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (81, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (82, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (83, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (84, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (85, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (86, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (87, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (88, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (89, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (90, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (91, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (92, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (93, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (94, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (95, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (96, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (97, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (98, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (99, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (100, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (101, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (102, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (103, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (104, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (105, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (106, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (107, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (108, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (109, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (110, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (111, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (112, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (113, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (114, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (115, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (116, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (117, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (118, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (119, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (120, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (121, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (122, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (123, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (124, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (125, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (126, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (127, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (128, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (129, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (130, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (131, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (132, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (133, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (134, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (135, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (136, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (137, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (138, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (139, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (140, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (141, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (142, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (143, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (144, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (145, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (146, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (147, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (148, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (149, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (150, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (151, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (152, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (153, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (154, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (155, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (156, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (157, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (158, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (159, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (160, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (161, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (162, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (163, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (21, 'free', '1003', '2011-12-17 19:58:16', 'SIP/t_express-0000002d', '1324144696.62');
INSERT INTO ulines VALUES (22, 'free', '1003', '2011-12-17 20:02:55', 'SIP/t_express-0000002f', '1324144975.64');
INSERT INTO ulines VALUES (30, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (31, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (32, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (33, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (34, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (35, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (36, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (37, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (38, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (39, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (40, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (41, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (42, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (43, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (44, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (45, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (46, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (47, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (48, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (49, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (50, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (23, 'free', '1003', '2011-12-17 20:05:46', 'SIP/t_express-00000031', '1324145146.66');
INSERT INTO ulines VALUES (26, 'free', '1003', '2011-12-17 20:12:10', 'SIP/t_express-00000036', '1324145530.72');
INSERT INTO ulines VALUES (28, 'free', '201', '2011-12-17 20:13:30', 'SIP/201-00000039', '1324145610.78');
INSERT INTO ulines VALUES (29, 'free', '1003', '2011-12-20 20:04:17', 'SIP/t_express-0000003e', '1324404257.83');
INSERT INTO ulines VALUES (27, 'free', '201', '2011-12-17 20:13:01', 'SIP/201-00000038', '1324145581.75');
INSERT INTO ulines VALUES (24, 'free', '1003', '2011-12-17 20:07:33', 'SIP/t_express-00000033', '1324145253.68');
INSERT INTO ulines VALUES (25, 'free', '201', '2011-12-17 20:07:52', 'SIP/201-00000035', '1324145272.71');
INSERT INTO ulines VALUES (51, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (52, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (53, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (54, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (55, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (56, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (57, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (58, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (59, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (60, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (61, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (62, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (63, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (64, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (65, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (66, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (7, 'free', '1003', '2011-12-17 14:37:44', 'SIP/t_express-00000015', '1324125464.27');
INSERT INTO ulines VALUES (164, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (165, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (166, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (167, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (168, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (169, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (170, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (171, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (172, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (173, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (174, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (175, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (176, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (177, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (178, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (179, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (180, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (181, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (182, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (183, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (184, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (185, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (186, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (187, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (188, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (189, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (190, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (191, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (192, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (193, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (194, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (195, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (196, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (197, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (198, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (199, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (200, 'free', NULL, NULL, NULL, NULL);
INSERT INTO ulines VALUES (2, 'free', '201', '2012-01-04 20:21:03', 'SIP/201-000000ae', '1325701263.256');
INSERT INTO ulines VALUES (1, 'free', '1003', '2012-01-04 20:20:56', 'SIP/t_express-000000ac', '1325701256.253');
INSERT INTO ulines VALUES (3, 'free', '201', '2012-01-04 20:23:13', 'SIP/201-000000af', '1325701393.259');
INSERT INTO ulines VALUES (13, 'free', '201', '2011-12-17 15:45:37', 'SIP/201-00000023', '1324129537.46');
INSERT INTO ulines VALUES (15, 'free', '201', '2011-12-17 15:45:57', 'SIP/201-00000025', '1324129557.50');
INSERT INTO ulines VALUES (17, 'free', '201', '2011-12-17 15:46:27', 'SIP/201-00000027', '1324129587.56');
INSERT INTO ulines VALUES (4, 'free', '201', '2011-12-17 14:18:37', 'SIP/201-0000000e', '1324124317.18');
INSERT INTO ulines VALUES (5, 'free', '1003', '2011-12-17 14:23:29', 'SIP/t_express-0000000f', '1324124609.19');
INSERT INTO ulines VALUES (6, 'free', '1003', '2011-12-17 14:32:50', 'SIP/t_express-00000012', '1324125170.23');
INSERT INTO ulines VALUES (8, 'free', '1003', '2011-12-17 14:56:47', 'SIP/t_express-00000018', '1324126607.31');
INSERT INTO ulines VALUES (9, 'free', '1003', '2011-12-17 15:35:18', 'SIP/t_express-0000001b', '1324128918.35');
INSERT INTO ulines VALUES (10, 'free', '1003', '2011-12-17 15:38:25', 'SIP/t_express-0000001e', '1324129105.39');
INSERT INTO ulines VALUES (11, 'free', '201', '2011-12-17 15:38:36', 'SIP/201-00000020', '1324129116.42');
INSERT INTO ulines VALUES (12, 'free', '1003', '2011-12-17 15:45:16', 'SIP/t_express-00000021', '1324129516.43');
INSERT INTO ulines VALUES (14, 'free', '201', '2011-12-17 15:45:48', 'SIP/201-00000024', '1324129548.49');
INSERT INTO ulines VALUES (16, 'free', '201', '2011-12-17 15:46:16', 'SIP/201-00000026', '1324129576.53');
INSERT INTO ulines VALUES (18, 'free', '1003', '2011-12-17 19:54:49', 'SIP/t_express-00000028', '1324144489.57');
INSERT INTO ulines VALUES (19, 'free', '1003', '2011-12-17 19:55:48', 'SIP/t_express-0000002a', '1324144548.59');
INSERT INTO ulines VALUES (20, 'free', '201', '2011-12-17 19:56:10', 'SIP/201-0000002c', '1324144570.61');


--
-- TOC entry 2063 (class 0 OID 16744)
-- Dependencies: 1588
-- Data for Name: workplaces; Type: TABLE DATA; Schema: integration; Owner: asterisk
--

INSERT INTO workplaces VALUES (2, 58, '192.168.0.22', '192.168.1.22', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8221d77b');
INSERT INTO workplaces VALUES (3, 59, '192.168.0.23', '192.168.1.23', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8221d77c');
INSERT INTO workplaces VALUES (4, 60, '192.168.0.24', '192.168.1.24', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8221d77d');
INSERT INTO workplaces VALUES (5, 61, '192.168.0.25', '192.168.1.25', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8221d77f');
INSERT INTO workplaces VALUES (6, 62, '192.168.0.26', '192.168.1.26', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b82226396');
INSERT INTO workplaces VALUES (7, 63, '192.168.0.27', '192.168.1.27', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b82226397');
INSERT INTO workplaces VALUES (8, 64, '192.168.0.11', '192.168.1.11', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8217fd9b');
INSERT INTO workplaces VALUES (9, 65, '192.168.0.12', '192.168.1.12', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8217fd3b');
INSERT INTO workplaces VALUES (10, 66, '192.168.0.13', '192.168.1.13', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8217fd99');
INSERT INTO workplaces VALUES (11, 67, '192.168.0.16', '192.168.1.16', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b82226394');
INSERT INTO workplaces VALUES (12, 68, '192.168.0.17', '192.168.1.17', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b82226395');
INSERT INTO workplaces VALUES (13, 69, '192.168.0.14', '192.168.1.14', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8217fd9c');
INSERT INTO workplaces VALUES (14, 70, '192.168.0.15', '192.168.1.15', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8217fd9a');
INSERT INTO workplaces VALUES (15, 71, '192.168.0.16', '192.168.1.16', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8221d733');
INSERT INTO workplaces VALUES (16, 72, '192.168.0.17', '192.168.1.17', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8217fd9e');
INSERT INTO workplaces VALUES (17, 73, '192.168.0.28', '192.168.1.28', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8221d737');
INSERT INTO workplaces VALUES (18, 74, '192.168.0.29', '192.168.1.29', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b821a40a3');
INSERT INTO workplaces VALUES (19, 75, '192.168.0.30', '192.168.1.30', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8227c189');
INSERT INTO workplaces VALUES (1, 57, '192.168.0.21', '192.168.1.21', 'GrandStreamGXP1200', true, 335, 'TaxiOffice', '000b8221d77a');


SET search_path = public, pg_catalog;

--
-- TOC entry 2064 (class 0 OID 16754)
-- Dependencies: 1590
-- Data for Name: blacklist; Type: TABLE DATA; Schema: public; Owner: asterisk
--



--
-- TOC entry 2065 (class 0 OID 16761)
-- Dependencies: 1592
-- Data for Name: cdr; Type: TABLE DATA; Schema: public; Owner: asterisk
--

INSERT INTO cdr VALUES ('2011-12-09 23:02:15+00', '"Alex Radetsky" <1003>', '1003', '201', 'default', 'SIP/t_express-0000000b', 'SIP/201-0000000c', 'Dial', 'SIP/201|120|rtT', 5, 0, 'NO ANSWER', 3, '', '1323471735.11', '');
INSERT INTO cdr VALUES ('2011-12-17 11:42:46+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000000', 'SIP/201-00000001', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 16, 10, 'ANSWERED', 3, '', '1324122166.0', '');
INSERT INTO cdr VALUES ('2011-12-17 11:44:11+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000002', 'SIP/201-00000003', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 21, 17, 'ANSWERED', 3, '', '1324122251.2', '');
INSERT INTO cdr VALUES ('2011-12-17 11:44:52+00', '"Im Phone" <201>', '201', '10', 'parkingslot', 'SIP/201-00000004', 'SIP/t_express-00000002', 'ParkedCall', '10', 15, 15, 'ANSWERED', 3, '', '1324122292.5', '');
INSERT INTO cdr VALUES ('2011-12-17 11:53:54+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000005', 'SIP/201-00000006', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 21, 9, 'ANSWERED', 3, '', '1324122834.6', '');
INSERT INTO cdr VALUES ('2011-12-17 11:55:08+00', '"Im Phone" <201>', '201', 'i', 'parkingslot', 'SIP/201-00000007', '', 'Playback', 'pbx-invalidpark', 3, 3, 'ANSWERED', 3, '', '1324122908.9', '');
INSERT INTO cdr VALUES ('2011-12-17 11:55:12+00', '"Im Phone" <201>', '201', '4', 'parkingslot', 'SIP/201-00000008', 'SIP/t_express-00000005', 'ParkedCall', '4', 6, 6, 'ANSWERED', 3, '', '1324122912.10', '');
INSERT INTO cdr VALUES ('2011-12-17 12:04:43+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000009', 'SIP/201-0000000a', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 13, 9, 'ANSWERED', 3, '', '1324123483.11', '');
INSERT INTO cdr VALUES ('2011-12-17 12:05:26+00', '"Im Phone" <201>', '201', '1', 'parkingslot', 'SIP/201-0000000b', 'SIP/t_express-00000009', 'ParkedCall', '1', 5, 4, 'ANSWERED', 3, '', '1324123526.14', '');
INSERT INTO cdr VALUES ('2011-12-17 12:18:18+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000000c', 'SIP/201-0000000d', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 13, 7, 'ANSWERED', 3, '', '1324124298.15', '');
INSERT INTO cdr VALUES ('2011-12-17 12:18:37+00', '"Im Phone" <201>', '201', '3', 'parkingslot', 'SIP/201-0000000e', 'SIP/t_express-0000000c', 'ParkedCall', '3', 6, 6, 'ANSWERED', 3, '', '1324124317.18', '');
INSERT INTO cdr VALUES ('2011-12-17 12:23:29+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000000f', 'SIP/201-00000010', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 10, 8, 'ANSWERED', 3, '', '1324124609.19', '');
INSERT INTO cdr VALUES ('2011-12-17 12:23:44+00', '"Im Phone" <201>', '201', '5', 'parkingslot', 'SIP/201-00000011', 'SIP/t_express-0000000f', 'ParkedCall', '5', 9, 9, 'ANSWERED', 3, '', '1324124624.22', '');
INSERT INTO cdr VALUES ('2011-12-17 12:32:50+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000012', 'SIP/201-00000013', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 7, 6, 'ANSWERED', 3, '', '1324125170.23', '');
INSERT INTO cdr VALUES ('2011-12-17 12:33:03+00', '"Im Phone" <201>', '201', '6', 'parkingslot', 'SIP/201-00000014', 'SIP/t_express-00000012', 'ParkedCall', '6', 4, 4, 'ANSWERED', 3, '', '1324125183.26', '');
INSERT INTO cdr VALUES ('2011-12-17 12:37:44+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000015', 'SIP/201-00000016', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 6, 4, 'ANSWERED', 3, '', '1324125464.27', '');
INSERT INTO cdr VALUES ('2011-12-17 12:37:54+00', '"Im Phone" <201>', '201', '7', 'parkingslot', 'SIP/201-00000017', 'SIP/t_express-00000015', 'ParkedCall', '7', 4, 4, 'ANSWERED', 3, '', '1324125474.30', '');
INSERT INTO cdr VALUES ('2011-12-17 12:56:47+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000018', 'SIP/201-00000019', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 10, 7, 'ANSWERED', 3, '', '1324126607.31', '');
INSERT INTO cdr VALUES ('2011-12-17 12:56:59+00', '"Im Phone" <201>', '201', '8', 'parkingslot', 'SIP/201-0000001a', 'SIP/t_express-00000018', 'ParkedCall', '8', 7, 6, 'ANSWERED', 3, '', '1324126619.34', '');
INSERT INTO cdr VALUES ('2011-12-17 13:35:18+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000001b', 'SIP/201-0000001c', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 13, 7, 'ANSWERED', 3, '', '1324128918.35', '');
INSERT INTO cdr VALUES ('2011-12-17 13:35:37+00', '"Im Phone" <201>', '201', '9', 'parkingslot', 'SIP/201-0000001d', 'SIP/t_express-0000001b', 'ParkedCall', '9', 9, 8, 'ANSWERED', 3, '', '1324128937.38', '');
INSERT INTO cdr VALUES ('2011-12-17 13:38:25+00', '"LINE 10" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000001e', 'SIP/201-0000001f', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 8, 6, 'ANSWERED', 3, '', '1324129105.39', '');
INSERT INTO cdr VALUES ('2011-12-17 13:38:36+00', '"LINE 11" <201>', '201', '10', 'parkingslot', 'SIP/201-00000020', 'SIP/t_express-0000001e', 'ParkedCall', '10', 4, 4, 'ANSWERED', 3, '', '1324129116.42', '');
INSERT INTO cdr VALUES ('2011-12-17 13:45:16+00', '"LINE 12" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000021', 'SIP/201-00000022', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 7, 4, 'ANSWERED', 3, '', '1324129516.43', '');
INSERT INTO cdr VALUES ('2011-12-17 13:45:37+00', '"LINE 13" <201>', '201', '12', 'parkingslot', 'SIP/201-00000023', 'SIP/t_express-00000021', 'ParkedCall', '12', 6, 6, 'ANSWERED', 3, '', '1324129537.46', '');
INSERT INTO cdr VALUES ('2011-12-17 13:45:48+00', '"LINE 14" <201>', '201', '1', 'parkingslot', 'SIP/201-00000024', '', 'ParkedCall', '1', 5, 4, 'ANSWERED', 3, '', '1324129548.49', '');
INSERT INTO cdr VALUES ('2011-12-17 13:45:57+00', '"LINE 15" <201>', '201', '12', 'parkingslot', 'SIP/201-00000025', 'SIP/t_express-00000021', 'ParkedCall', '12', 4, 4, 'ANSWERED', 3, '', '1324129557.50', '');
INSERT INTO cdr VALUES ('2011-12-17 13:46:16+00', '"LINE 16" <201>', '201', '12', 'parkingslot', 'SIP/201-00000026', 'SIP/t_express-00000021', 'ParkedCall', '12', 8, 8, 'ANSWERED', 3, '', '1324129576.53', '');
INSERT INTO cdr VALUES ('2011-12-17 13:46:27+00', '"LINE 17" <201>', '201', '12', 'parkingslot', 'SIP/201-00000027', 'SIP/t_express-00000021', 'ParkedCall', '12', 4, 4, 'ANSWERED', 3, '', '1324129587.56', '');
INSERT INTO cdr VALUES ('2011-12-17 17:54:49+00', '"LINE 18" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000028', 'SIP/201-00000029', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 28, 20, 'ANSWERED', 3, '', '1324144489.57', '');
INSERT INTO cdr VALUES ('2011-12-17 17:55:48+00', '"LINE 19" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000002a', 'SIP/201-0000002b', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 14, 12, 'ANSWERED', 3, '', '1324144548.59', '');
INSERT INTO cdr VALUES ('2011-12-17 17:56:10+00', '"LINE 20" <201>', '201', '19', 'parkingslot', 'SIP/201-0000002c', '', 'ParkedCall', '19', 2, 1, 'ANSWERED', 3, '', '1324144570.61', '');
INSERT INTO cdr VALUES ('2011-12-17 17:58:16+00', '"LINE 21" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000002d', 'SIP/201-0000002e', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 6, 3, 'ANSWERED', 3, '', '1324144696.62', '');
INSERT INTO cdr VALUES ('2011-12-17 18:02:55+00', '"LINE 22" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000002f', 'SIP/201-00000030', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 5, 2, 'ANSWERED', 3, '', '1324144975.64', '');
INSERT INTO cdr VALUES ('2011-12-17 18:05:46+00', '"LINE 23" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000031', 'SIP/201-00000032', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 4, 2, 'ANSWERED', 3, '', '1324145146.66', '');
INSERT INTO cdr VALUES ('2011-12-17 18:07:33+00', '"LINE 24" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000033', 'SIP/201-00000034', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 4, 3, 'ANSWERED', 3, '', '1324145253.68', '');
INSERT INTO cdr VALUES ('2011-12-17 18:07:52+00', '"LINE 25" <201>', '201', '24', 'parkingslot', 'SIP/201-00000035', 'SIP/t_express-00000033', 'ParkedCall', '24', 2, 2, 'ANSWERED', 3, '', '1324145272.71', '');
INSERT INTO cdr VALUES ('2011-12-17 18:12:10+00', '"LINE 26" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000036', 'SIP/201-00000037', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 5, 3, 'ANSWERED', 3, '', '1324145530.72', '');
INSERT INTO cdr VALUES ('2011-12-17 18:13:01+00', '"LINE 27" <201>', '201', '26', 'parkingslot', 'SIP/201-00000038', 'SIP/t_express-00000036', 'ParkedCall', '26', 19, 18, 'ANSWERED', 3, '', '1324145581.75', '');
INSERT INTO cdr VALUES ('2011-12-17 18:13:30+00', '"LINE 28" <201>', '201', '26', 'parkingslot', 'SIP/201-00000039', 'SIP/t_express-00000036', 'ParkedCall', '26', 51, 51, 'ANSWERED', 3, '', '1324145610.78', '');
INSERT INTO cdr VALUES ('2011-12-12 11:43:23+00', '"Alex Radetsky" <1003>', '1003', '200', 'default', 'SIP/t_express-0000001b', 'SIP/t_express-0000001c', 'Hangup', '17', 0, 0, 'FAILED', 3, '', '1323690203.27', '');
INSERT INTO cdr VALUES ('2011-12-12 15:04:18+00', '"Im Phone" <201>', '201', '3039338', 'default', 'SIP/201-00000021', 'SIP/t_express-00000022', 'Hangup', '17', 0, 0, 'FAILED', 3, '', '1323702258.33', '');
INSERT INTO cdr VALUES ('2011-12-12 15:06:34+00', '"Im Phone" <201>', '201', '3039338', 'default', 'SIP/201-00000023', 'SIP/t_express-00000024', 'Dial', 'SIP/t_express/3039338|120|rtTg', 5, 4, 'ANSWERED', 3, '', '1323702394.35', '');
INSERT INTO cdr VALUES ('2011-12-13 07:49:36+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000028', 'SIP/201-00000029', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 47, 35, 'ANSWERED', 3, '', '1323762576.40', '');
INSERT INTO cdr VALUES ('2011-12-13 14:58:33+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000002c', 'SIP/201-0000002d', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 27, 10, 'ANSWERED', 3, '', '1323788313.44', '');
INSERT INTO cdr VALUES ('2011-12-13 15:00:22+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000030', 'SIP/201-00000031', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 53, 52, 'ANSWERED', 3, '', '1323788422.48', '');
INSERT INTO cdr VALUES ('2011-12-13 15:05:34+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000036', 'SIP/201-00000037', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 16, 0, 'ANSWERED', 3, '', '1323788734.54', '');
INSERT INTO cdr VALUES ('2011-12-15 16:19:46+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000039', 'SIP/201-0000003a', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 10, 6, 'ANSWERED', 3, '', '1323965986.57', '');
INSERT INTO cdr VALUES ('2011-12-15 16:23:57+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000003b', 'SIP/201-0000003c', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 9, 6, 'ANSWERED', 3, '', '1323966237.59', '');
INSERT INTO cdr VALUES ('2011-12-15 16:24:50+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000003d', 'SIP/201-0000003e', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 10, 8, 'ANSWERED', 3, '', '1323966290.61', '');
INSERT INTO cdr VALUES ('2011-12-15 16:25:37+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000040', 'SIP/201-00000041', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 51, 49, 'ANSWERED', 3, '', '1323966337.64', '');
INSERT INTO cdr VALUES ('2011-12-15 16:27:01+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000046', 'SIP/201-00000047', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 22, 19, 'ANSWERED', 3, '', '1323966421.70', '');
INSERT INTO cdr VALUES ('2011-12-20 18:14:47+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000042', 'SIP/201-00000043', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 68, 66, 'ANSWERED', 3, '', '1324404887.87', '');
INSERT INTO cdr VALUES ('2011-12-21 17:08:27+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000044', 'SIP/201-00000045', 'Queue', 'express|rtTn|15|NetSDS-AGI-integration.pl', 74, 69, 'ANSWERED', 3, '', '1324487307.89', '');
INSERT INTO cdr VALUES ('2011-12-21 17:42:12+00', '"LINE 2" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000046', 'SIP/201-00000047', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 107, 100, 'ANSWERED', 3, '', '1324489332.91', '');
INSERT INTO cdr VALUES ('2011-12-21 17:57:05+00', '"LINE 3" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000048', 'SIP/201-00000049', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 33, 25, 'ANSWERED', 3, '', '1324490225.93', '');
INSERT INTO cdr VALUES ('2011-12-29 09:51:38+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000004a', 'SIP/201-0000004b', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 52, 48, 'ANSWERED', 3, '', '1325152298.95', '');
INSERT INTO cdr VALUES ('2011-12-15 16:48:33+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000000', 'SIP/201-00000001', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 23, 21, 'ANSWERED', 3, '', '1323967713.0', '');
INSERT INTO cdr VALUES ('2011-12-31 10:33:37+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000000', 'SIP/201-00000001', 'AGI', 'VERBOSE', 19, 17, 'ANSWERED', 3, '', '1325327617.0', '');
INSERT INTO cdr VALUES ('2011-12-31 10:34:11+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000002', 'SIP/t_express-00000000', 'ParkedCall', '1', 25, 25, 'ANSWERED', 3, '', '1325327651.3', '');
INSERT INTO cdr VALUES ('2011-12-31 10:34:46+00', '"LINE 3" <201>', '201', '1', 'parkingslot', 'SIP/201-00000003', 'SIP/t_express-00000000', 'ParkedCall', '1', 11, 11, 'ANSWERED', 3, '', '1325327686.6', '');
INSERT INTO cdr VALUES ('2011-12-31 10:38:09+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000004', 'SIP/201-00000005', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 26, 23, 'ANSWERED', 3, '', '1325327889.7', '');
INSERT INTO cdr VALUES ('2011-12-31 10:39:09+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000006', 'SIP/201-00000007', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 7, 4, 'ANSWERED', 3, '', '1325327949.9', '');
INSERT INTO cdr VALUES ('2011-12-31 10:48:21+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000008', 'SIP/201-00000009', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 57, 47, 'ANSWERED', 3, '', '1325328501.11', '');
INSERT INTO cdr VALUES ('2011-12-31 10:51:12+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000000a', 'SIP/201-0000000b', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 13, 10, 'ANSWERED', 3, '', '1325328672.13', '');
INSERT INTO cdr VALUES ('2011-12-31 10:51:56+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000010', 'SIP/201-00000011', 'AGI', 'VERBOSE', 18, 15, 'ANSWERED', 3, '', '1325328716.19', '');
INSERT INTO cdr VALUES ('2011-12-31 10:52:56+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000012', 'SIP/t_express-00000010', 'ParkedCall', '1', 12, 12, 'ANSWERED', 3, '', '1325328776.22', '');
INSERT INTO cdr VALUES ('2011-12-31 10:53:26+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000013', 'SIP/t_express-00000010', 'ParkedCall', '1', 9, 9, 'ANSWERED', 3, '', '1325328806.25', '');
INSERT INTO cdr VALUES ('2011-12-31 11:40:07+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-00000014', 'SIP/t_express-00000015', 'Dial', 'SIP/t_express/3039338|120|rtTg', 6, 6, 'ANSWERED', 3, '', '1325331607.26', '');
INSERT INTO cdr VALUES ('2011-12-31 12:05:05+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-00000016', 'SIP/t_express-00000017', 'Dial', 'SIP/t_express/3039338|120|rtTg', 4, 3, 'ANSWERED', 3, '', '1325333105.28', '');
INSERT INTO cdr VALUES ('2011-12-15 17:39:42+00', '"Im Phone" <201>', '201', '0', 'default', 'SIP/201-00000000', '', 'Park', '10', 10, 10, 'ANSWERED', 3, '', '1323970782.0', '');
INSERT INTO cdr VALUES ('2011-12-15 17:41:26+00', '"Im Phone" <201>', '201', '0', 'default', 'SIP/201-00000001', '', 'Park', '', 36, 36, 'ANSWERED', 3, '', '1323970886.2', '');
INSERT INTO cdr VALUES ('2011-12-15 17:47:18+00', '"Im Phone" <201>', '201', '0', 'default', 'SIP/201-00000004', '', 'Park', '', 11, 10, 'ANSWERED', 3, '', '1323971238.6', '');
INSERT INTO cdr VALUES ('2011-12-15 17:48:24+00', '"Im Phone" <201>', '201', '0', 'default', 'SIP/201-00000005', '', 'Park', '', 4, 4, 'ANSWERED', 3, '', '1323971304.8', '');
INSERT INTO cdr VALUES ('2011-12-15 17:47:06+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000002', 'SIP/201-00000003', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 96, 94, 'ANSWERED', 3, '', '1323971226.4', '');
INSERT INTO cdr VALUES ('2011-12-15 17:53:54+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000006', 'SIP/201-00000007', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 10, 5, 'ANSWERED', 3, '', '1323971634.10', '');
INSERT INTO cdr VALUES ('2011-12-15 17:54:58+00', '"Im Phone" <201>', '201', '0', 'default', 'SIP/201-00000011', '', 'Park', '', 6, 6, 'ANSWERED', 3, '', '1323971698.21', '');
INSERT INTO cdr VALUES ('2011-12-15 17:54:34+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000000f', 'SIP/201-00000010', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 70, 66, 'ANSWERED', 3, '', '1323971674.19', '');
INSERT INTO cdr VALUES ('2011-12-15 17:58:24+00', '"Im Phone" <201>', '201', '0', 'default', 'SIP/201-00000014', '', 'Park', '', 13, 13, 'ANSWERED', 3, '', '1323971904.25', '');
INSERT INTO cdr VALUES ('2011-12-15 17:58:04+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000012', 'SIP/201-00000013', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 42, 38, 'ANSWERED', 3, '', '1323971884.23', '');
INSERT INTO cdr VALUES ('2011-12-15 17:59:29+00', '"Im Phone" <201>', '201', '0', 'default', 'SIP/201-00000017', '', 'Park', '', 12, 12, 'ANSWERED', 3, '', '1323971969.29', '');
INSERT INTO cdr VALUES ('2011-12-15 17:59:21+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000015', 'SIP/201-00000016', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 51, 49, 'ANSWERED', 3, '', '1323971961.27', '');
INSERT INTO cdr VALUES ('2011-12-15 18:02:30+00', '"Im Phone" <201>', '201', '0', 'default', 'SIP/201-0000001a', '', 'Park', '', 7, 7, 'ANSWERED', 3, '', '1323972150.33', '');
INSERT INTO cdr VALUES ('2011-12-15 18:02:22+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000018', 'SIP/201-00000019', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 58, 56, 'ANSWERED', 3, '', '1323972142.31', '');
INSERT INTO cdr VALUES ('2011-12-15 18:09:57+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000001b', 'SIP/201-0000001c', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 43, 41, 'ANSWERED', 3, '', '1323972597.35', '');
INSERT INTO cdr VALUES ('2011-12-15 18:11:49+00', '', '', 'parkannounce', 'parkingslot', 'Local/parkannounce@parkingslot-8c3f,2', '', 'Hangup', '', 0, 0, 'ANSWERED', 3, '', '1323972709.46', '');
INSERT INTO cdr VALUES ('2011-12-15 18:11:49+00', '', '', 'parkannounce', 'parkingslot', 'Local/parkannounce@parkingslot-8c3f,1', '', '', '', 0, 0, 'ANSWERED', 3, '', '1323972709.45', '');
INSERT INTO cdr VALUES ('2011-12-15 18:11:41+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000001e', 'SIP/201-0000001f', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 29, 28, 'ANSWERED', 3, '', '1323972701.41', '');
INSERT INTO cdr VALUES ('2011-12-15 18:16:44+00', '', '', 'parkannounce', 'parkingslot', 'Local/parkannounce@parkingslot-c88f,2', '', 'Hangup', '', 0, 0, 'ANSWERED', 3, '', '1323973004.52', '');
INSERT INTO cdr VALUES ('2011-12-15 18:16:44+00', '', '', 'parkannounce', 'parkingslot', 'Local/parkannounce@parkingslot-c88f,1', '', '', '', 0, 0, 'ANSWERED', 3, '', '1323973004.51', '');
INSERT INTO cdr VALUES ('2011-12-15 18:16:39+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000021', 'SIP/201-00000022', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 34, 33, 'ANSWERED', 3, '', '1323972999.47', '');
INSERT INTO cdr VALUES ('2011-12-15 18:22:27+00', '', '', 'parkannounce', 'parkingslot', 'Local/parkannounce@parkingslot-bfae,2', '', 'Hangup', '', 0, 0, 'ANSWERED', 3, '', '1323973347.58', '');
INSERT INTO cdr VALUES ('2011-12-15 18:22:27+00', '', '', 'parkannounce', 'parkingslot', 'Local/parkannounce@parkingslot-bfae,1', '', '', '', 0, 0, 'ANSWERED', 3, '', '1323973347.57', '');
INSERT INTO cdr VALUES ('2011-12-15 18:22:15+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000024', 'SIP/201-00000025', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 19, 17, 'ANSWERED', 3, '', '1323973335.53', '');
INSERT INTO cdr VALUES ('2011-12-15 18:47:10+00', '"Im Phone" <201>', '201', 'i', 'parkingslot', 'SIP/201-00000027', '', 'Hangup', '', 0, 0, 'ANSWERED', 3, '', '1323974830.59', '');
INSERT INTO cdr VALUES ('2011-12-15 18:47:44+00', '', '', 'parkannounce', 'parkingslot', 'Local/parkannounce@parkingslot-f7c5,1', '', '', '', 0, 0, 'ANSWERED', 3, '', '1323974864.64', '');
INSERT INTO cdr VALUES ('2011-12-15 18:47:44+00', '', '', 'parkannounce', 'parkingslot', 'Local/parkannounce@parkingslot-f7c5,2', '', 'Answer', '', 0, 0, 'ANSWERED', 3, '', '1323974864.65', '');
INSERT INTO cdr VALUES ('2011-12-15 18:47:38+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000028', 'SIP/201-00000029', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 7, 5, 'ANSWERED', 3, '', '1323974858.60', '');
INSERT INTO cdr VALUES ('2011-12-15 18:47:57+00', '"Im Phone" <201>', '201', '10', 'parkingslot', 'SIP/201-0000002b', 'SIP/t_express-00000028', 'ParkedCall', '10', 29, 29, 'ANSWERED', 3, '', '1323974877.66', '');
INSERT INTO cdr VALUES ('2011-12-15 18:49:50+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000002c', 'SIP/201-0000002d', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 19, 17, 'ANSWERED', 3, '', '1323974990.67', '');
INSERT INTO cdr VALUES ('2011-12-15 18:50:30+00', '"Im Phone" <201>', '201', '10', 'parkingslot', 'SIP/201-0000002f', 'SIP/t_express-0000002c', 'ParkedCall', '10', 1, 1, 'ANSWERED', 3, '', '1323975030.71', '');
INSERT INTO cdr VALUES ('2011-12-15 18:50:52+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000030', 'SIP/201-00000031', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 9, 8, 'ANSWERED', 3, '', '1323975052.72', '');
INSERT INTO cdr VALUES ('2011-12-15 18:51:08+00', '"Im Phone" <201>', '201', '10', 'parkingslot', 'SIP/201-00000033', 'SIP/t_express-00000030', 'ParkedCall', '10', 4, 4, 'ANSWERED', 3, '', '1323975068.76', '');
INSERT INTO cdr VALUES ('2011-12-15 19:03:03+00', '"Im Phone" <201>', '201', '0', 'default', 'SIP/201-00000036', '', 'Park', '', 2, 2, 'ANSWERED', 3, '', '1323975783.79', '');
INSERT INTO cdr VALUES ('2011-12-15 19:02:44+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000034', 'SIP/201-00000035', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 34, 32, 'ANSWERED', 3, '', '1323975764.77', '');
INSERT INTO cdr VALUES ('2011-12-15 19:03:05+00', '"Im Phone" <201>', '201', '0', 'default', 'SIP/201-00000037', '', 'Park', '', 13, 13, 'ANSWERED', 3, '', '1323975785.81', '');
INSERT INTO cdr VALUES ('2011-12-16 15:07:37+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000003e', 'SIP/201-0000003f', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 9, 1, 'ANSWERED', 3, '', '1324048057.89', '');
INSERT INTO cdr VALUES ('2011-12-31 12:05:50+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-00000018', 'SIP/t_express-00000019', 'Dial', 'SIP/t_express/3039338|120|rtTg', 5, 4, 'ANSWERED', 3, '', '1325333150.30', '');
INSERT INTO cdr VALUES ('2011-12-31 12:06:39+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000001a', 'SIP/201-0000001b', 'AGI', 'VERBOSE', 16, 14, 'ANSWERED', 3, '', '1325333199.32', '');
INSERT INTO cdr VALUES ('2011-12-31 12:07:14+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-0000001c', 'SIP/t_express-0000001a', 'ParkedCall', '1', 7, 6, 'ANSWERED', 3, '', '1325333234.35', '');
INSERT INTO cdr VALUES ('2011-12-31 12:07:31+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-0000001d', 'SIP/t_express-0000001a', 'ParkedCall', '1', 4, 4, 'ANSWERED', 3, '', '1325333251.38', '');
INSERT INTO cdr VALUES ('2011-12-31 12:16:01+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000001e', 'SIP/201-0000001f', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 31, 29, 'ANSWERED', 3, '', '1325333761.39', '');
INSERT INTO cdr VALUES ('2011-12-16 15:28:07+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000048', 'SIP/201-00000049', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 15, 13, 'ANSWERED', 3, '', '1324049287.99', '');
INSERT INTO cdr VALUES ('2011-12-16 15:28:22+00', '"Alex Radetsky" <1003>', '1003', 'SIP/201', 'park-dial', 'SIP/t_express-00000048', 'SIP/201-0000004b', 'Dial', 'SIP/201|30|Tt', 111, 63, 'ANSWERED', 3, '', '1324049287.99', '');
INSERT INTO cdr VALUES ('2011-12-31 12:21:02+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000020', 'SIP/201-00000021', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 19, 18, 'ANSWERED', 3, '', '1325334062.41', '');
INSERT INTO cdr VALUES ('2011-12-31 12:22:41+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000022', 'SIP/201-00000023', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 18, 16, 'ANSWERED', 3, '', '1325334161.43', '');
INSERT INTO cdr VALUES ('2011-12-31 12:25:11+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000024', 'SIP/201-00000025', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 6, 3, 'ANSWERED', 3, '', '1325334311.45', '');
INSERT INTO cdr VALUES ('2011-12-31 12:43:10+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000026', 'SIP/201-00000027', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 19, 15, 'ANSWERED', 3, '', '1325335390.47', '');
INSERT INTO cdr VALUES ('2011-12-31 12:44:11+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000028', 'SIP/201-00000029', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 13, 11, 'ANSWERED', 3, '', '1325335451.49', '');
INSERT INTO cdr VALUES ('2011-12-31 12:45:58+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000002a', 'SIP/201-0000002b', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 6, 4, 'ANSWERED', 3, '', '1325335558.51', '');
INSERT INTO cdr VALUES ('2011-12-31 12:52:04+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000002c', 'SIP/201-0000002d', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 11, 9, 'ANSWERED', 3, '', '1325335924.53', '');
INSERT INTO cdr VALUES ('2011-12-31 12:53:05+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000002e', 'SIP/201-0000002f', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 21, 20, 'ANSWERED', 3, '', '1325335985.55', '');
INSERT INTO cdr VALUES ('2011-12-31 12:54:16+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000030', 'SIP/201-00000031', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 13, 11, 'ANSWERED', 3, '', '1325336056.57', '');
INSERT INTO cdr VALUES ('2011-12-31 12:55:09+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000033', 'SIP/201-00000034', 'AGI', 'VERBOSE', 8, 6, 'ANSWERED', 3, '', '1325336109.60', '');
INSERT INTO cdr VALUES ('2011-12-31 12:55:25+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000035', 'SIP/t_express-00000033', 'ParkedCall', '1', 4, 4, 'ANSWERED', 3, '', '1325336125.63', '');
INSERT INTO cdr VALUES ('2011-12-31 12:55:35+00', '"LINE 3" <201>', '201', '1', 'parkingslot', 'SIP/201-00000036', 'SIP/t_express-00000033', 'ParkedCall', '1', 4, 3, 'ANSWERED', 3, '', '1325336135.66', '');
INSERT INTO cdr VALUES ('2012-01-02 11:33:05+00', '"LINE 3" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000039', 'SIP/201-0000003a', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 98, 95, 'ANSWERED', 3, '', '1325503985.69', '');
INSERT INTO cdr VALUES ('2012-01-02 12:01:53+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000003b', 'SIP/201-0000003c', 'AGI', 'VERBOSE', 9, 7, 'ANSWERED', 3, '', '1325505713.71', '');
INSERT INTO cdr VALUES ('2012-01-02 12:02:13+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-0000003d', 'SIP/t_express-0000003b', 'ParkedCall', '1', 52, 51, 'ANSWERED', 3, '', '1325505733.74', '');
INSERT INTO cdr VALUES ('2012-01-02 18:47:17+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-0000003e', 'SIP/t_express-0000003f', 'Dial', 'SIP/t_express/3039338|120|rtTg', 50, 49, 'ANSWERED', 3, '', '1325530037.75', '');
INSERT INTO cdr VALUES ('2012-01-02 18:48:20+00', '"LINE 1" <201>', '201', '1', 'parkingslot', 'SIP/201-00000040', '', 'ParkedCall', '1', 5, 4, 'ANSWERED', 3, '', '1325530100.79', '');
INSERT INTO cdr VALUES ('2012-01-02 18:48:27+00', '"LINE 1" <201>', '201', '2', 'parkingslot', 'SIP/201-00000041', 'SIP/t_express-0000003f', 'ParkedCall', '2', 26, 25, 'ANSWERED', 3, '', '1325530107.80', '');
INSERT INTO cdr VALUES ('2012-01-02 18:48:57+00', '"LINE 1" <201>', '201', '2', 'parkingslot', 'SIP/201-00000042', 'SIP/t_express-0000003f', 'ParkedCall', '2', 17, 17, 'ANSWERED', 3, '', '1325530137.83', '');
INSERT INTO cdr VALUES ('2012-01-02 18:57:00+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000043', 'SIP/201-00000044', 'AGI', 'VERBOSE', 8, 6, 'ANSWERED', 3, '', '1325530620.84', '');
INSERT INTO cdr VALUES ('2012-01-02 18:57:10+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000045', 'SIP/t_express-00000043', 'ParkedCall', '1', 4, 4, 'ANSWERED', 3, '', '1325530630.87', '');
INSERT INTO cdr VALUES ('2012-01-02 18:57:16+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000046', 'SIP/t_express-00000043', 'ParkedCall', '1', 4, 4, 'ANSWERED', 3, '', '1325530636.90', '');
INSERT INTO cdr VALUES ('2012-01-02 18:57:22+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000047', 'SIP/t_express-00000043', 'ParkedCall', '1', 4, 4, 'ANSWERED', 3, '', '1325530642.93', '');
INSERT INTO cdr VALUES ('2012-01-03 13:29:47+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-00000048', 'SIP/t_express-00000049', 'Dial', 'SIP/t_express/3039338|120|rtTg', 24, 24, 'ANSWERED', 3, '', '1325597387.94', '');
INSERT INTO cdr VALUES ('2012-01-03 13:30:16+00', '"LINE 1" <201>', '201', '2', 'parkingslot', 'SIP/201-0000004a', 'SIP/t_express-00000049', 'ParkedCall', '2', 7, 7, 'ANSWERED', 3, '', '1325597416.98', '');
INSERT INTO cdr VALUES ('2012-01-03 14:23:59+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-0000004b', 'SIP/t_express-0000004c', 'Dial', 'SIP/t_express/3039338|120|rtTg', 36, 36, 'ANSWERED', 3, '', '1325600639.99', '');
INSERT INTO cdr VALUES ('2012-01-03 14:23:59+00', '"LINE 2" <201>', '201', '0', 'default', 'SIP/201-0000004b', 'SIP/t_express-0000004c', 'Park', '', 61, 61, 'ANSWERED', 3, '', '1325600639.99', '');
INSERT INTO cdr VALUES ('2012-01-03 14:26:00+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-0000004e', 'SIP/t_express-0000004f', 'Dial', 'SIP/t_express/3039338|120|rtTg', 21, 21, 'ANSWERED', 3, '', '1325600760.104', '');
INSERT INTO cdr VALUES ('2012-01-03 14:26:00+00', '"LINE 1" <201>', '201', '0', 'default', 'SIP/201-0000004e', 'SIP/t_express-0000004f', 'Park', '', 51, 51, 'ANSWERED', 3, '', '1325600760.104', '');
INSERT INTO cdr VALUES ('2012-01-03 14:49:10+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-00000052', 'SIP/t_express-00000053', 'Dial', 'SIP/t_express/3039338|120|rtTg', 20, 19, 'ANSWERED', 3, '', '1325602150.110', '');
INSERT INTO cdr VALUES ('2012-01-03 14:49:59+00', '"LINE 1" <201>', '201', '2', 'parkingslot', 'SIP/201-00000054', 'SIP/t_express-00000053', 'ParkedCall', '2', 10, 10, 'ANSWERED', 3, '', '1325602199.114', '');
INSERT INTO cdr VALUES ('2012-01-03 14:50:18+00', '"LINE 1" <201>', '201', '2', 'parkingslot', 'SIP/201-00000055', 'SIP/t_express-00000053', 'ParkedCall', '2', 4, 4, 'ANSWERED', 3, '', '1325602218.117', '');
INSERT INTO cdr VALUES ('2012-01-03 15:01:42+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-00000056', 'SIP/t_express-00000057', 'Dial', 'SIP/t_express/3039338|120|rtTg', 22, 22, 'ANSWERED', 3, '', '1325602902.118', '1');
INSERT INTO cdr VALUES ('2012-01-03 15:01:42+00', '"LINE 1" <201>', '201', '0', 'default', 'SIP/201-00000056', 'SIP/t_express-00000057', 'Park', '', 47, 47, 'ANSWERED', 3, '', '1325602902.118', '1');
INSERT INTO cdr VALUES ('2012-01-03 15:56:05+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000058', 'SIP/201-00000059', 'AGI', 'VERBOSE', 12, 10, 'ANSWERED', 3, '', '1325606165.122', '1');
INSERT INTO cdr VALUES ('2012-01-03 15:56:25+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-0000005a', 'SIP/t_express-00000058', 'ParkedCall', '1', 7, 6, 'ANSWERED', 3, '', '1325606185.125', '2');
INSERT INTO cdr VALUES ('2012-01-03 15:56:34+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-0000005b', 'SIP/t_express-00000058', 'ParkedCall', '1', 7, 7, 'ANSWERED', 3, '', '1325606194.128', '2');
INSERT INTO cdr VALUES ('2012-01-03 15:56:54+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-0000005d', 'SIP/t_express-0000005e', 'Dial', 'SIP/t_express/3039338|120|rtTg', 27, 27, 'ANSWERED', 3, '', '1325606214.130', '1');
INSERT INTO cdr VALUES ('2012-01-03 15:57:40+00', '"LINE 1" <201>', '201', '1', 'parkingslot', 'SIP/201-0000005f', 'SIP/t_express-0000005e', 'ParkedCall', '1', 10, 10, 'ANSWERED', 3, '', '1325606260.134', '1');
INSERT INTO cdr VALUES ('2011-12-16 18:32:36+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000000', 'SIP/201-00000001', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 8, 6, 'ANSWERED', 3, '', '1324060356.0', '');
INSERT INTO cdr VALUES ('2011-12-16 18:32:44+00', '"Alex Radetsky" <1003>', '1003', 'SIP/201', 'park-dial', 'SIP/t_express-00000000', 'SIP/201-00000002', 'Dial', 'SIP/201|30|Tt', 56, 9, 'ANSWERED', 3, '', '1324060356.0', '');
INSERT INTO cdr VALUES ('2011-12-16 18:38:23+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000005', 'SIP/201-00000006', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 7, 5, 'ANSWERED', 3, '', '1324060703.6', '');
INSERT INTO cdr VALUES ('2012-01-03 15:57:54+00', '"LINE 1" <201>', '201', '1', 'parkingslot', 'SIP/201-00000060', 'SIP/t_express-0000005e', 'ParkedCall', '1', 8, 8, 'ANSWERED', 3, '', '1325606274.137', '1');
INSERT INTO cdr VALUES ('2012-01-03 15:58:04+00', '"LINE 1" <201>', '201', '1', 'parkingslot', 'SIP/201-00000061', 'SIP/t_express-0000005e', 'ParkedCall', '1', 8, 7, 'ANSWERED', 3, '', '1325606284.140', '1');
INSERT INTO cdr VALUES ('2012-01-03 18:25:07+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-00000062', 'SIP/t_express-00000063', 'Dial', 'SIP/t_express/3039338|120|rtTg', 31, 31, 'ANSWERED', 3, '', '1325615107.141', '1');
INSERT INTO cdr VALUES ('2012-01-03 18:25:07+00', '201', '201', '0', 'default', 'SIP/201-00000062', 'SIP/t_express-00000063', 'Hangup', '17', 31, 31, 'ANSWERED', 3, '', '1325615107.141', '1');
INSERT INTO cdr VALUES ('2012-01-03 18:28:10+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-00000064', 'SIP/t_express-00000065', 'Dial', 'SIP/t_express/3039338|120|rtTg', 25, 25, 'ANSWERED', 3, '', '1325615290.144', '1');
INSERT INTO cdr VALUES ('2012-01-03 18:29:20+00', '"LINE 1" <201>', '201', '1', 'parkingslot', 'SIP/201-00000066', 'SIP/t_express-00000065', 'ParkedCall', '1', 22, 22, 'ANSWERED', 3, '', '1325615360.148', '1');
INSERT INTO cdr VALUES ('2012-01-03 18:46:27+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000067', 'SIP/201-00000068', 'AGI', 'VERBOSE', 26, 24, 'ANSWERED', 3, '', '1325616387.149', '1');
INSERT INTO cdr VALUES ('2012-01-03 18:47:02+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000069', 'SIP/t_express-00000067', 'ParkedCall', '1', 13, 13, 'ANSWERED', 3, '', '1325616422.152', '2');
INSERT INTO cdr VALUES ('2012-01-03 18:50:44+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000006a', 'SIP/201-0000006b', 'AGI', 'VERBOSE', 37, 35, 'ANSWERED', 3, '', '1325616644.153', '1');
INSERT INTO cdr VALUES ('2012-01-03 18:52:03+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-0000006c', 'SIP/t_express-0000006a', 'ParkedCall', '1', 37, 37, 'ANSWERED', 3, '', '1325616723.156', '2');
INSERT INTO cdr VALUES ('2012-01-03 18:52:53+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-0000006d', 'SIP/t_express-0000006a', 'ParkedCall', '1', 53, 53, 'ANSWERED', 3, '', '1325616773.159', '2');
INSERT INTO cdr VALUES ('2012-01-03 19:01:11+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000006e', 'SIP/201-0000006f', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 32, 30, 'ANSWERED', 3, '', '1325617271.160', '1');
INSERT INTO cdr VALUES ('2012-01-03 19:02:18+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000070', 'SIP/201-00000071', 'AGI', 'VERBOSE', 8, 7, 'ANSWERED', 3, '', '1325617338.162', '1');
INSERT INTO cdr VALUES ('2012-01-03 19:02:40+00', '"LINE 3" <201>', '201', '1', 'parkingslot', 'SIP/201-00000072', '', 'ParkedCall', '1', 4, 4, 'ANSWERED', 3, '', '1325617360.165', '3');
INSERT INTO cdr VALUES ('2012-01-03 19:02:48+00', '"LINE 3" <201>', '201', '1', 'parkingslot', 'SIP/201-00000073', '', 'ParkedCall', '1', 2, 2, 'ANSWERED', 3, '', '1325617368.166', '3');
INSERT INTO cdr VALUES ('2012-01-03 19:02:51+00', '"LINE 3" <201>', '201', '2', 'parkingslot', 'SIP/201-00000074', 'SIP/t_express-00000070', 'ParkedCall', '2', 3, 3, 'ANSWERED', 3, '', '1325617371.167', '2');
INSERT INTO cdr VALUES ('2012-01-03 19:08:23+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000077', 'SIP/201-00000078', 'AGI', 'VERBOSE', 46, 43, 'ANSWERED', 3, '', '1325617703.170', '1');
INSERT INTO cdr VALUES ('2012-01-03 19:09:45+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000079', 'SIP/t_express-00000077', 'ParkedCall', '1', 26, 25, 'ANSWERED', 3, '', '1325617785.173', '2');
INSERT INTO cdr VALUES ('2012-01-03 19:10:40+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000007a', 'SIP/201-0000007b', 'AGI', 'VERBOSE', 14, 12, 'ANSWERED', 3, '', '1325617840.174', '1');
INSERT INTO cdr VALUES ('2011-12-16 18:44:13+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000000', 'SIP/201-00000001', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 9, 7, 'ANSWERED', 3, '', '1324061053.0', '');
INSERT INTO cdr VALUES ('2011-12-16 18:53:41+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000003', 'SIP/201-00000004', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 19, 9, 'ANSWERED', 3, '', '1324061621.3', '');
INSERT INTO cdr VALUES ('2011-12-16 19:09:12+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000005', 'SIP/201-00000006', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 10, 8, 'ANSWERED', 3, '', '1324062552.5', '');
INSERT INTO cdr VALUES ('2011-12-16 19:10:03+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000007', 'SIP/201-00000008', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 14, 11, 'ANSWERED', 3, '', '1324062603.7', '');
INSERT INTO cdr VALUES ('2011-12-16 19:13:46+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000009', 'SIP/201-0000000a', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 14, 9, 'ANSWERED', 3, '', '1324062826.9', '');
INSERT INTO cdr VALUES ('2011-12-16 19:47:39+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000000c', 'SIP/201-0000000d', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 10, 8, 'ANSWERED', 3, '', '1324064859.13', '');
INSERT INTO cdr VALUES ('2011-12-16 19:48:04+00', '"Im Phone" <201>', '201', '10', 'parkingslot', 'SIP/201-0000000e', 'SIP/t_express-0000000c', 'ParkedCall', '10', 13, 13, 'ANSWERED', 3, '', '1324064884.16', '');
INSERT INTO cdr VALUES ('2012-01-03 19:11:04+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-0000007c', 'SIP/t_express-0000007a', 'ParkedCall', '1', 9, 8, 'ANSWERED', 3, '', '1325617864.177', '2');
INSERT INTO cdr VALUES ('2012-01-03 19:11:20+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-0000007d', 'SIP/t_express-0000007a', 'ParkedCall', '1', 8, 7, 'ANSWERED', 3, '', '1325617880.180', '2');
INSERT INTO cdr VALUES ('2012-01-03 19:13:48+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-0000007e', 'SIP/t_express-0000007f', 'Dial', 'SIP/t_express/3039338|120|rtTg', 29, 29, 'ANSWERED', 3, '', '1325618028.181', '1');
INSERT INTO cdr VALUES ('2012-01-03 19:15:11+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000080', 'SIP/t_express-0000007f', 'ParkedCall', '1', 23, 23, 'ANSWERED', 3, '', '1325618111.185', '1');
INSERT INTO cdr VALUES ('2012-01-03 19:15:49+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000081', 'SIP/t_express-0000007f', 'ParkedCall', '1', 7, 7, 'ANSWERED', 3, '', '1325618149.188', '2');
INSERT INTO cdr VALUES ('2012-01-03 19:37:53+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-00000082', 'SIP/t_express-00000083', 'Dial', 'SIP/t_express/3039338|120|rtTg', 28, 28, 'ANSWERED', 3, '', '1325619473.189', '1');
INSERT INTO cdr VALUES ('2012-01-03 19:38:32+00', '"LINE 1" <201>', '201', '3039338', 'default', 'SIP/201-00000084', 'SIP/t_express-00000085', 'Dial', 'SIP/t_express/3039338|120|rtTg', 90, 89, 'ANSWERED', 3, '', '1325619512.191', '1');
INSERT INTO cdr VALUES ('2012-01-03 19:40:44+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000086', 'SIP/t_express-00000085', 'ParkedCall', '1', 14, 14, 'ANSWERED', 3, '', '1325619644.195', '1');
INSERT INTO cdr VALUES ('2012-01-03 19:41:04+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000087', 'SIP/t_express-00000085', 'ParkedCall', '1', 8, 7, 'ANSWERED', 3, '', '1325619664.198', '2');
INSERT INTO cdr VALUES ('2012-01-03 19:41:13+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000088', 'SIP/t_express-00000085', 'ParkedCall', '1', 9, 8, 'ANSWERED', 3, '', '1325619673.201', '2');
INSERT INTO cdr VALUES ('2012-01-04 10:37:08+00', '"LINE 1" <201>', '201', '1003', 'default', 'SIP/201-00000089', 'SIP/t_express-0000008a', 'Dial', 'SIP/t_express/1003|120|rtTg', 74, 62, 'ANSWERED', 3, '', '1325673428.202', '1');
INSERT INTO cdr VALUES ('2012-01-04 10:39:23+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-0000008b', 'SIP/t_express-0000008a', 'ParkedCall', '1', 10, 9, 'ANSWERED', 3, '', '1325673563.206', '1');
INSERT INTO cdr VALUES ('2012-01-04 11:18:29+00', '"LINE 1" <201>', '201', '2054455', 'default', 'SIP/201-0000008d', 'SIP/t_express-0000008e', 'Dial', 'SIP/t_express/2054455|120|rtTg', 104, 98, 'ANSWERED', 3, '', '1325675909.208', '1');
INSERT INTO cdr VALUES ('2012-01-04 11:27:01+00', '"LINE 1" <201>', '201', '2054455', 'default', 'SIP/201-0000008f', 'SIP/t_express-00000090', 'Dial', 'SIP/t_express/2054455|120|rtTg', 144, 140, 'ANSWERED', 3, '', '1325676421.210', '1');
INSERT INTO cdr VALUES ('2012-01-04 16:15:58+00', '"LINE 1" <201>', '201', '1003', 'default', 'SIP/201-00000091', 'SIP/t_express-00000092', 'Dial', 'SIP/t_express/1003|120|rtTg', 28, 20, 'ANSWERED', 3, '', '1325693758.212', '1');
INSERT INTO cdr VALUES ('2012-01-04 16:29:48+00', '"LINE 1" <201>', '201', '1003', 'default', 'SIP/201-00000093', 'SIP/t_express-00000094', 'Dial', 'SIP/t_express/1003|120|rtTg', 13, 5, 'ANSWERED', 3, '', '1325694588.214', '1');
INSERT INTO cdr VALUES ('2012-01-04 16:30:27+00', '"LINE 1" <201>', '201', '1003', 'default', 'SIP/201-00000095', 'SIP/t_express-00000096', 'Dial', 'SIP/t_express/1003|120|rtTg', 59, 46, 'ANSWERED', 3, '', '1325694627.216', '1');
INSERT INTO cdr VALUES ('2012-01-04 16:31:59+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000097', 'SIP/t_express-00000096', 'ParkedCall', '1', 12, 12, 'ANSWERED', 3, '', '1325694719.220', '1');
INSERT INTO cdr VALUES ('2012-01-04 16:32:14+00', '"LINE 3" <201>', '201', '1', 'parkingslot', 'SIP/201-00000098', 'SIP/t_express-00000096', 'ParkedCall', '1', 24, 24, 'ANSWERED', 3, '', '1325694734.223', '2');
INSERT INTO cdr VALUES ('2012-01-04 16:32:49+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-00000099', 'SIP/t_express-00000096', 'ParkedCall', '1', 9, 9, 'ANSWERED', 3, '', '1325694769.226', '3');
INSERT INTO cdr VALUES ('2012-01-04 16:33:09+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-0000009a', 'SIP/t_express-00000096', 'ParkedCall', '1', 8, 7, 'ANSWERED', 3, '', '1325694789.229', '2');
INSERT INTO cdr VALUES ('2012-01-04 16:33:35+00', '"LINE 3" <201>', '201', '1', 'parkingslot', 'SIP/201-0000009b', 'SIP/t_express-00000096', 'ParkedCall', '1', 6, 6, 'ANSWERED', 3, '', '1325694815.232', '2');
INSERT INTO cdr VALUES ('2012-01-04 16:45:57+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000009c', 'SIP/201-0000009d', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 43, 42, 'ANSWERED', 3, '', '1325695557.233', '1');
INSERT INTO cdr VALUES ('2012-01-04 16:54:50+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-0000009e', 'SIP/201-0000009f', 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl', 39, 37, 'ANSWERED', 3, '', '1325696090.235', '1');
INSERT INTO cdr VALUES ('2012-01-04 16:57:05+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-000000a0', 'SIP/201-000000a1', 'AGI', 'VERBOSE', 31, 30, 'ANSWERED', 3, '', '1325696225.237', '1');
INSERT INTO cdr VALUES ('2012-01-04 16:58:23+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-000000a2', 'SIP/t_express-000000a0', 'ParkedCall', '1', 27, 27, 'ANSWERED', 3, '', '1325696303.240', '2');
INSERT INTO cdr VALUES ('2012-01-04 17:04:17+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-000000a3', 'SIP/201-000000a4', 'AGI', 'VERBOSE', 13, 11, 'ANSWERED', 3, '', '1325696657.241', '1');
INSERT INTO cdr VALUES ('2012-01-04 17:04:41+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-000000a5', 'SIP/t_express-000000a3', 'ParkedCall', '1', 21, 21, 'ANSWERED', 3, '', '1325696681.244', '2');
INSERT INTO cdr VALUES ('2012-01-04 17:08:10+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-000000a6', 'SIP/201-000000a7', 'AGI', 'VERBOSE', 16, 14, 'ANSWERED', 3, '', '1325696890.245', '1');
INSERT INTO cdr VALUES ('2012-01-04 17:08:38+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-000000a8', 'SIP/t_express-000000a6', 'ParkedCall', '1', 10, 10, 'ANSWERED', 3, '', '1325696918.248', '2');
INSERT INTO cdr VALUES ('2012-01-04 18:14:08+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-000000a9', 'SIP/201-000000aa', 'AGI', 'VERBOSE', 12, 10, 'ANSWERED', 3, '', '1325700848.249', '1');
INSERT INTO cdr VALUES ('2012-01-04 18:14:34+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-000000ab', 'SIP/t_express-000000a9', 'ParkedCall', '1', 43, 43, 'ANSWERED', 3, '', '1325700874.252', '2');
INSERT INTO cdr VALUES ('2012-01-04 18:20:56+00', '"LINE 1" <1003>', '1003', '2391515', 'express', 'SIP/t_express-000000ac', 'SIP/201-000000ad', 'AGI', 'VERBOSE', 4, 2, 'ANSWERED', 3, '', '1325701256.253', '1');
INSERT INTO cdr VALUES ('2011-12-17 09:23:42+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000000', 'SIP/201-00000001', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 30, 25, 'ANSWERED', 3, '', '1324113822.0', '');
INSERT INTO cdr VALUES ('2012-01-04 18:21:03+00', '"LINE 2" <201>', '201', '1', 'parkingslot', 'SIP/201-000000ae', 'SIP/t_express-000000ac', 'ParkedCall', '1', 128, 127, 'ANSWERED', 3, '', '1325701263.256', '2');
INSERT INTO cdr VALUES ('2012-01-04 18:23:13+00', '"LINE 3" <201>', '201', '1', 'parkingslot', 'SIP/201-000000af', 'SIP/t_express-000000ac', 'ParkedCall', '1', 70, 70, 'ANSWERED', 3, '', '1325701393.259', '2');
INSERT INTO cdr VALUES ('2011-12-17 10:35:56+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000000', 'SIP/201-00000001', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 13, 11, 'ANSWERED', 3, '', '1324118156.0', '');
INSERT INTO cdr VALUES ('2011-12-17 10:37:03+00', '"Im Phone" <201>', '201', '1', 'parkingslot', 'SIP/201-00000002', 'SIP/t_express-00000000', 'ParkedCall', '1', 20, 20, 'ANSWERED', 3, '', '1324118223.3', '');
INSERT INTO cdr VALUES ('2011-12-17 10:40:46+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000003', 'SIP/201-00000004', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 14, 12, 'ANSWERED', 3, '', '1324118446.4', '');
INSERT INTO cdr VALUES ('2011-12-17 10:41:30+00', '"Alex Radetsky" <1003>', '1003', '2391515', 'express', 'SIP/t_express-00000009', 'SIP/201-0000000a', 'Queue', 'express|rtTn|15|NetSDS-AGI-Integration.pl', 11, 8, 'ANSWERED', 3, '', '1324118490.11', '');
INSERT INTO cdr VALUES ('2011-12-17 10:41:56+00', '"Im Phone" <201>', '201', '8', 'parkingslot', 'SIP/201-0000000b', 'SIP/t_express-00000009', 'ParkedCall', '8', 10, 10, 'ANSWERED', 3, '', '1324118516.14', '');
INSERT INTO cdr VALUES ('2011-12-09 21:59:55+00', '"Alex Radetsky" <1003>', '1003', '201', 'default', 'SIP/t_express-00000008', 'SIP/201-00000009', 'Dial', 'SIP/201|120|rtT', 6, 0, 'NO ANSWER', 3, '', '1323467995.8', '');


--
-- TOC entry 2066 (class 0 OID 16783)
-- Dependencies: 1593
-- Data for Name: extensions_conf; Type: TABLE DATA; Schema: public; Owner: asterisk
--

INSERT INTO extensions_conf VALUES (3, 'default', '_X!', 3, 'Hangup', '17');
INSERT INTO extensions_conf VALUES (6, 'parkingslot', '_X!', 1, 'NoOp', 'see extensions.conf');
INSERT INTO extensions_conf VALUES (5, 'express', 'h', 1, 'NoOp', 'EOCall: ${CALLERID(num)} ${CDR(start)}');
INSERT INTO extensions_conf VALUES (2, 'default', '_X!', 2, 'AGI', 'NetSDS-route.pl|${CHANNEL}|${EXTEN}');
INSERT INTO extensions_conf VALUES (1, 'default', '_X!', 1, 'NoOp', '');
INSERT INTO extensions_conf VALUES (4, 'express', '_X!', 1, 'Queue', 'express|rtTn|||15|NetSDS-AGI-integration.pl');
INSERT INTO extensions_conf VALUES (7, 'LocalOffice', '_X!', 1, 'NoOp', 'see extensions.conf');
INSERT INTO extensions_conf VALUES (8, 'autoexpress', '_X!', 1, 'Queue', 'autoexpress|rtTn|||15|NetSDS-AGI-integration.pl');
INSERT INTO extensions_conf VALUES (9, 'express', '_X!', 2, 'Queue', 'autoexpress|rtTn|||300|NetSDS-AGI-integration.pl');
INSERT INTO extensions_conf VALUES (10, 'evakuator', '_X!', 1, 'Queue', 'evakuator|rtTn|||300|NetSDS-AGI-integration.pl');
INSERT INTO extensions_conf VALUES (11, 'miniexpress', '_X!', 1, 'Queue', 'miniexpress|rtTn|||300|NetSDS-AGI-integration.pl');
INSERT INTO extensions_conf VALUES (12, 'leader', '_X!', 1, 'Queue', 'leader|rtTn|||300|NetSDS-AGI-integration.pl');


--
-- TOC entry 2067 (class 0 OID 16792)
-- Dependencies: 1595
-- Data for Name: queue_log; Type: TABLE DATA; Schema: public; Owner: asterisk
--



--
-- TOC entry 2068 (class 0 OID 16797)
-- Dependencies: 1597
-- Data for Name: queue_members; Type: TABLE DATA; Schema: public; Owner: asterisk
--

INSERT INTO queue_members VALUES (1, '201', 'express', 'SIP/201', NULL, NULL);
INSERT INTO queue_members VALUES (2, '202', 'express', 'SIP/202', NULL, NULL);
INSERT INTO queue_members VALUES (3, '203', 'express', 'SIP/203', NULL, NULL);
INSERT INTO queue_members VALUES (4, '204', 'express', 'SIP/204', NULL, NULL);
INSERT INTO queue_members VALUES (5, '205', 'express', 'SIP/205', NULL, NULL);
INSERT INTO queue_members VALUES (6, '206', 'express', 'SIP/206', NULL, NULL);
INSERT INTO queue_members VALUES (7, '207', 'express', 'SIP/207', NULL, NULL);
INSERT INTO queue_members VALUES (8, '208', 'autoexpress', 'SIP/208', NULL, NULL);
INSERT INTO queue_members VALUES (9, '209', 'autoexpress', 'SIP/209', NULL, NULL);
INSERT INTO queue_members VALUES (10, '210', 'autoexpress', 'SIP/210', NULL, NULL);
INSERT INTO queue_members VALUES (11, '211', 'autoexpress', 'SIP/211', NULL, NULL);
INSERT INTO queue_members VALUES (12, '212', 'autoexpress', 'SIP/212', NULL, NULL);
INSERT INTO queue_members VALUES (13, '213', 'evakuator', 'SIP/213', NULL, NULL);
INSERT INTO queue_members VALUES (14, '214', 'evakuator', 'SIP/214', NULL, NULL);
INSERT INTO queue_members VALUES (15, '215', 'evakuator', 'SIP/215', NULL, NULL);
INSERT INTO queue_members VALUES (17, '216', 'evakuator', 'SIP/216', NULL, NULL);
INSERT INTO queue_members VALUES (18, '216', 'leader', 'SIP/216', NULL, NULL);
INSERT INTO queue_members VALUES (19, '217', 'leader', 'SIP/217', NULL, NULL);
INSERT INTO queue_members VALUES (20, '218', 'leader', 'SIP/218', NULL, NULL);
INSERT INTO queue_members VALUES (21, '219', 'miniexpress', 'SIP/219', NULL, NULL);


--
-- TOC entry 2069 (class 0 OID 16805)
-- Dependencies: 1599
-- Data for Name: queue_parsed; Type: TABLE DATA; Schema: public; Owner: asterisk
--



--
-- TOC entry 2070 (class 0 OID 16819)
-- Dependencies: 1601
-- Data for Name: queues; Type: TABLE DATA; Schema: public; Owner: asterisk
--

INSERT INTO queues VALUES ('express', 'default', NULL, NULL, 0, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, 30, 10, 0, 'ringall', 'no', 'yes', true, true, false, 0, 0, false, NULL, NULL, false, true, 'mixmonitor');
INSERT INTO queues VALUES ('autoexpress', 'default', NULL, NULL, 0, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, 30, 10, 0, 'ringall', 'no', 'yes', true, true, false, 0, 0, false, NULL, NULL, false, true, 'mixmonitor');
INSERT INTO queues VALUES ('miniexpress', 'default', NULL, NULL, 0, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, 30, 10, 0, 'ringall', 'no', 'yes', true, true, false, 0, 0, false, NULL, NULL, false, true, 'mixmonitor');
INSERT INTO queues VALUES ('evakuator', 'default', NULL, NULL, 0, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, 30, 10, 0, 'ringall', 'no', 'yes', true, true, false, 0, 0, false, NULL, NULL, false, true, 'mixmonitor');
INSERT INTO queues VALUES ('leader', 'default', NULL, NULL, 0, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, 30, 10, 0, 'ringall', 'no', 'yes', true, true, false, 0, 0, false, NULL, NULL, false, true, 'mixmonitor');


--
-- TOC entry 2071 (class 0 OID 16844)
-- Dependencies: 1602
-- Data for Name: sip_conf; Type: TABLE DATA; Schema: public; Owner: asterisk
--

INSERT INTO sip_conf VALUES (20, 0, 0, 0, 'sip.conf', 'general', 'context', 'default');
INSERT INTO sip_conf VALUES (21, 0, 1, 0, 'sip.conf', 'general', 'allowoverlap', 'no');
INSERT INTO sip_conf VALUES (22, 0, 2, 0, 'sip.conf', 'general', 'bindport', '5060');
INSERT INTO sip_conf VALUES (23, 0, 3, 0, 'sip.conf', 'general', 'bindaddr', '0.0.0.0');
INSERT INTO sip_conf VALUES (24, 0, 4, 0, 'sip.conf', 'general', 'srvlookup', 'yes');
INSERT INTO sip_conf VALUES (26, 0, 6, 0, 'sip.conf', 'general', 'rtcachefriends', 'yes');
INSERT INTO sip_conf VALUES (27, 0, 7, 0, 'sip.conf', 'general', 'rtsavesysname', 'yes');
INSERT INTO sip_conf VALUES (28, 0, 8, 0, 'sip.conf', 'general', 'rtupdate', 'yes');
INSERT INTO sip_conf VALUES (29, 0, 9, 0, 'sip.conf', 'general', 'rtautoclear', 'yes');
INSERT INTO sip_conf VALUES (30, 0, 0, 0, 'sip.conf', 'general', 'ignoreregexpire', 'yes');
INSERT INTO sip_conf VALUES (25, 0, 5, 1, 'sip.conf', 'general', 'register', 't_express:t_wsedr21W@telco.netstyle.com.ua/5060');


--
-- TOC entry 2072 (class 0 OID 16859)
-- Dependencies: 1604
-- Data for Name: sip_peers; Type: TABLE DATA; Schema: public; Owner: asterisk
--

INSERT INTO sip_peers VALUES (2, 'gsm1', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, 'ru', NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, NULL, 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (3, 'gsm2', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, 'ru', NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, NULL, 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (4, 'gsm3', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, 'ru', NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, NULL, 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (73, '217', NULL, NULL, NULL, 'Leader 1 <217>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'mCpGD4yIPMP66Fjn', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (74, '218', NULL, NULL, NULL, 'Leader 2 <218>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'fLWjbe2nsiuCdWOD', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (75, '219', NULL, NULL, NULL, 'Mini 1 <219>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, '1Vj5bLg1heZ5cF0m', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (58, '202', NULL, NULL, NULL, 'Express 2 <202>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, 'ru', NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'L7rPj9VWZsjjWMCh', 'friend', '202', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '-1', '', '', NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (76, '220', NULL, NULL, NULL, 'Unused <220>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'fz6aLiPqMIh0Xn3F', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (59, '203', NULL, NULL, NULL, 'Express 3 <203>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'Kz5bWmpwsmaw0JxO', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (60, '204', NULL, NULL, NULL, 'Express 4 <204>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'NKTW4gR0g2UkVIdh', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (61, '205', NULL, NULL, NULL, 'Express 5 <205>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'pa6XsDz7WPzICqf5', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (62, '206', NULL, NULL, NULL, 'Express 6 <206>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'pW0ASyGYoks1wscv', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (63, '207', NULL, NULL, NULL, 'Express 7 <207>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'pI4jWzahu2hESAqp', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (64, '208', NULL, NULL, NULL, 'Auto 1 <208>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'gsGXk1WpQJwn8kby', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (65, '209', NULL, NULL, NULL, 'Auto 2 <209>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'mUxnqJ9KeqFNLMsp', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (66, '210', NULL, NULL, NULL, 'Auto 3 <210>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'tZ6KDbtU5kdPgSCh', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (67, '211', NULL, NULL, NULL, 'Auto 4 <211>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, '4ePQUAzBqJGbKMch', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (68, '212', NULL, NULL, NULL, 'Auto 5 <212>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'ojjPJJCSQXak2o5J', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (69, '213', NULL, NULL, NULL, 'Evakuator 1 <213>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, '3dqvyUmrAdRrTMYU', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (70, '214', NULL, NULL, NULL, 'Evakuator 2 <214>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'YGFUaeyg2g7HN5t7', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (71, '215', NULL, NULL, NULL, 'Evakuator 3 <215>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, '1fsBfw7eH3Oc6gJc', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (72, '216', NULL, NULL, NULL, 'Evakuator 4 <216>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'tFSvp3jhboc98qfI', 'friend', '', 'all', 'ulaw,alaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (77, '0445380303', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'sip.datagroup.com.ua', 'port,invite', NULL, NULL, NULL, 'no', '80.91.169.2/255.255.255.255', '0.0.0.0/0.0.0.0', NULL, NULL, '', 'yes', NULL, NULL, NULL, NULL, 'peer', '0445380303', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (78, 'UTL', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, '193.19.229.70', 'port,invite', NULL, NULL, NULL, 'no', '193.19.229.70/255.255.255.255', '0.0.0.0/0.0.0.0', NULL, NULL, '', 'yes', NULL, NULL, NULL, NULL, 'peer', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (80, 'VEGA2', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, '62.221.34.22', 'port,invite', NULL, NULL, NULL, 'no', '62.221.34.22/255.255.255.255', '0.0.0.0/0.0.0.0', NULL, NULL, '', 'yes', NULL, NULL, NULL, NULL, 'peer', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (81, '0001', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (82, '0002', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (83, '0003', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (84, '0004', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (85, '0005', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (86, '0006', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (87, '0007', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (88, '0008', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (89, '0009', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (90, '0010', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (91, '0011', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (92, '0012', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (93, '0013', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (94, '0014', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (95, '0015', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (96, '0016', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, 'qwerty', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (97, '0017', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, '0017', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (98, '0018', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, '0018', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (99, '0019', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, '0019', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (100, '0020', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, '0020', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (101, '0021', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, '0021', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (102, '0022', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, '0022', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (103, '0023', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, '0023', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (57, '201', NULL, NULL, NULL, 'Express 1 <201>', 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, 'ru', NULL, NULL, 'no', NULL, NULL, NULL, NULL, '5060', 'yes', NULL, NULL, NULL, 'lVL3YCGn0BWKbOXD', 'friend', '201', 'all', 'ulaw,alaw', NULL, 1325768018, '192.168.1.114', '', 'yes', '', 1, '-1', '', 'sip:201@192.168.1.114:5060', NULL, NULL, NULL);
INSERT INTO sip_peers VALUES (104, '0024', NULL, NULL, NULL, NULL, 'no', 'yes', 'default', NULL, 'rfc2833', NULL, NULL, 'dynamic', NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, '', 'yes', NULL, NULL, NULL, '0024', 'friend', '', 'all', 'alaw,ulaw', NULL, 0, '', '', 'yes', '', 1, '0', NULL, NULL, NULL, NULL, NULL);


--
-- TOC entry 2073 (class 0 OID 16892)
-- Dependencies: 1606
-- Data for Name: whitelist; Type: TABLE DATA; Schema: public; Owner: asterisk
--



SET search_path = routing, pg_catalog;

--
-- TOC entry 2074 (class 0 OID 16899)
-- Dependencies: 1608
-- Data for Name: callerid; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

INSERT INTO callerid VALUES (3, 1, NULL, '380442391515');
INSERT INTO callerid VALUES (5, 8, NULL, '380442391515');
INSERT INTO callerid VALUES (6, 8, 57, '380442391515');
INSERT INTO callerid VALUES (7, 8, 58, '380442391515');
INSERT INTO callerid VALUES (8, 8, 59, '380442391515');
INSERT INTO callerid VALUES (9, 8, 60, '380442391515');
INSERT INTO callerid VALUES (10, 8, 61, '380442391515');
INSERT INTO callerid VALUES (11, 8, 62, '380442391515');
INSERT INTO callerid VALUES (12, 8, 63, '380442391515');
INSERT INTO callerid VALUES (13, 8, 64, '380442390303');
INSERT INTO callerid VALUES (14, 8, 65, '380442390303');
INSERT INTO callerid VALUES (15, 8, 66, '380442390303');
INSERT INTO callerid VALUES (16, 8, 67, '380442390303');
INSERT INTO callerid VALUES (17, 8, 68, '380442390303');
INSERT INTO callerid VALUES (18, 8, 69, '0445380303');
INSERT INTO callerid VALUES (19, 8, 70, '0445380303');
INSERT INTO callerid VALUES (20, 8, 71, '0445380303');
INSERT INTO callerid VALUES (21, 8, 72, '0445380303');
INSERT INTO callerid VALUES (4, 6, NULL, '380442390303');
INSERT INTO callerid VALUES (22, 6, 57, '380442252525');
INSERT INTO callerid VALUES (23, 6, 58, '380442252525');
INSERT INTO callerid VALUES (24, 6, 59, '380442252525');
INSERT INTO callerid VALUES (25, 6, 60, '380442252525');
INSERT INTO callerid VALUES (26, 6, 61, '380442252525');
INSERT INTO callerid VALUES (27, 6, 62, '380442252525');
INSERT INTO callerid VALUES (28, 6, 63, '380442252525');
INSERT INTO callerid VALUES (29, 6, 69, '0445380303');
INSERT INTO callerid VALUES (30, 6, 70, '0445380303');
INSERT INTO callerid VALUES (31, 6, 71, '0445380303');
INSERT INTO callerid VALUES (32, 6, 72, '0445380303');


--
-- TOC entry 2075 (class 0 OID 16908)
-- Dependencies: 1610
-- Data for Name: directions; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

INSERT INTO directions VALUES (1, 1, '^3039338$', 5);
INSERT INTO directions VALUES (7, 2, '^098', 5);
INSERT INTO directions VALUES (6, 2, '^097', 5);
INSERT INTO directions VALUES (4, 2, '^096', 5);
INSERT INTO directions VALUES (3, 2, '^067', 5);
INSERT INTO directions VALUES (9, 4, '^2391515$', 5);
INSERT INTO directions VALUES (10, 1, '^200$', 5);
INSERT INTO directions VALUES (12, 5, '^0$', 5);
INSERT INTO directions VALUES (13, 5, '^1\\d$', 5);
INSERT INTO directions VALUES (14, 5, '^\\d$', 5);
INSERT INTO directions VALUES (15, 5, '^\\d\\d$', 5);
INSERT INTO directions VALUES (17, 5, '^1\\d\\d$', 5);
INSERT INTO directions VALUES (18, 1, '^1\\d\\d\\d$', 5);
INSERT INTO directions VALUES (19, 6, '^[2-5]\\d\\d\\d\\d\\d\\d$', 5);
INSERT INTO directions VALUES (23, 8, '^910\\d$', 5);
INSERT INTO directions VALUES (22, 7, '^2\\d\\d$', 5);
INSERT INTO directions VALUES (24, 9, '^00', 5);
INSERT INTO directions VALUES (25, 2, '^0[3-6]', 5);
INSERT INTO directions VALUES (26, 12, '^068', 4);
INSERT INTO directions VALUES (27, 10, '^050', 4);
INSERT INTO directions VALUES (28, 10, '^095', 4);
INSERT INTO directions VALUES (29, 10, '^066', 4);
INSERT INTO directions VALUES (30, 10, '^099', 4);
INSERT INTO directions VALUES (31, 11, '^063', 4);
INSERT INTO directions VALUES (32, 11, '^093', 4);
INSERT INTO directions VALUES (33, 4, '^0001$', 5);
INSERT INTO directions VALUES (34, 13, '^0002$', 5);
INSERT INTO directions VALUES (35, 15, '^0003$', 5);
INSERT INTO directions VALUES (36, 15, '^0004$', 5);
INSERT INTO directions VALUES (37, 13, '^0005$', 5);
INSERT INTO directions VALUES (38, 15, '^0006$', 5);
INSERT INTO directions VALUES (39, 15, '^0007$', 5);
INSERT INTO directions VALUES (40, 15, '^0008$', 5);
INSERT INTO directions VALUES (41, 13, '^0011$', 5);
INSERT INTO directions VALUES (42, 13, '^0012$', 5);
INSERT INTO directions VALUES (43, 15, '^0013$', 5);
INSERT INTO directions VALUES (44, 13, '^0014$', 5);
INSERT INTO directions VALUES (45, 13, '^0015$', 5);
INSERT INTO directions VALUES (46, 13, '^0016$', 5);
INSERT INTO directions VALUES (47, 15, '^0017$', 5);
INSERT INTO directions VALUES (48, 4, '^0018$', 5);
INSERT INTO directions VALUES (49, 4, '^0019$', 5);
INSERT INTO directions VALUES (50, 4, '^0020$', 5);
INSERT INTO directions VALUES (51, 15, '^0021$', 5);
INSERT INTO directions VALUES (52, 4, '^0022$', 5);
INSERT INTO directions VALUES (53, 4, '^0023$', 5);
INSERT INTO directions VALUES (54, 4, '^0024$', 5);
INSERT INTO directions VALUES (55, 13, '^0445380303$', 5);
INSERT INTO directions VALUES (56, 13, '^380442382828$', 5);
INSERT INTO directions VALUES (57, 16, '^380442388282$', 5);
INSERT INTO directions VALUES (58, 4, '^380442250225$', 5);
INSERT INTO directions VALUES (60, 4, '^380442252828$', 5);
INSERT INTO directions VALUES (61, 4, '^380442258282$', 5);
INSERT INTO directions VALUES (64, 13, '^380442390303$', 5);
INSERT INTO directions VALUES (65, 4, '^380442391515$', 5);
INSERT INTO directions VALUES (66, 4, '^380442511515$', 5);
INSERT INTO directions VALUES (68, 4, '^380445021515$', 5);
INSERT INTO directions VALUES (69, 4, '^380445031515$', 5);
INSERT INTO directions VALUES (70, 4, '^380445811515$', 5);
INSERT INTO directions VALUES (73, 15, '5833333', 5);
INSERT INTO directions VALUES (59, 14, '^380442252525$', 5);


--
-- TOC entry 2076 (class 0 OID 16914)
-- Dependencies: 1612
-- Data for Name: directions_list; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

INSERT INTO directions_list VALUES (1, 'NetStyle Office');
INSERT INTO directions_list VALUES (5, 'parking slot');
INSERT INTO directions_list VALUES (6, 'Local City (Kyiv)');
INSERT INTO directions_list VALUES (7, 'Local Office');
INSERT INTO directions_list VALUES (8, '911 and so on');
INSERT INTO directions_list VALUES (9, 'International');
INSERT INTO directions_list VALUES (2, 'KyivStar and InterCity');
INSERT INTO directions_list VALUES (10, 'MTS');
INSERT INTO directions_list VALUES (11, 'Life');
INSERT INTO directions_list VALUES (12, 'Beeline');
INSERT INTO directions_list VALUES (4, 'Express');
INSERT INTO directions_list VALUES (13, 'AutoExpress');
INSERT INTO directions_list VALUES (15, 'Evakuator');
INSERT INTO directions_list VALUES (16, 'Leader');
INSERT INTO directions_list VALUES (14, 'MiniExpress');


--
-- TOC entry 2077 (class 0 OID 16919)
-- Dependencies: 1614
-- Data for Name: permissions; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

INSERT INTO permissions VALUES (1, 1, 1);
INSERT INTO permissions VALUES (2, 2, 1);
INSERT INTO permissions VALUES (5, 4, 56);
INSERT INTO permissions VALUES (6, 1, 56);
INSERT INTO permissions VALUES (7, 1, 57);
INSERT INTO permissions VALUES (9, 5, 57);
INSERT INTO permissions VALUES (10, 5, 56);
INSERT INTO permissions VALUES (11, 6, 57);
INSERT INTO permissions VALUES (12, 7, 57);
INSERT INTO permissions VALUES (13, 7, 58);
INSERT INTO permissions VALUES (14, 7, 59);
INSERT INTO permissions VALUES (15, 7, 60);
INSERT INTO permissions VALUES (16, 7, 61);
INSERT INTO permissions VALUES (17, 7, 62);
INSERT INTO permissions VALUES (18, 7, 63);
INSERT INTO permissions VALUES (19, 7, 64);
INSERT INTO permissions VALUES (20, 7, 65);
INSERT INTO permissions VALUES (21, 7, 66);
INSERT INTO permissions VALUES (22, 7, 67);
INSERT INTO permissions VALUES (23, 7, 68);
INSERT INTO permissions VALUES (25, 7, 69);
INSERT INTO permissions VALUES (26, 7, 70);
INSERT INTO permissions VALUES (27, 7, 71);
INSERT INTO permissions VALUES (28, 7, 72);
INSERT INTO permissions VALUES (29, 7, 73);
INSERT INTO permissions VALUES (30, 7, 74);
INSERT INTO permissions VALUES (31, 7, 75);
INSERT INTO permissions VALUES (32, 7, 76);
INSERT INTO permissions VALUES (33, 8, 57);
INSERT INTO permissions VALUES (34, 8, 58);
INSERT INTO permissions VALUES (35, 8, 59);
INSERT INTO permissions VALUES (36, 8, 60);
INSERT INTO permissions VALUES (37, 8, 61);
INSERT INTO permissions VALUES (38, 8, 62);
INSERT INTO permissions VALUES (39, 8, 63);
INSERT INTO permissions VALUES (40, 8, 64);
INSERT INTO permissions VALUES (41, 8, 65);
INSERT INTO permissions VALUES (42, 8, 66);
INSERT INTO permissions VALUES (43, 8, 67);
INSERT INTO permissions VALUES (44, 8, 68);
INSERT INTO permissions VALUES (45, 8, 69);
INSERT INTO permissions VALUES (46, 8, 70);
INSERT INTO permissions VALUES (47, 8, 71);
INSERT INTO permissions VALUES (48, 8, 72);
INSERT INTO permissions VALUES (49, 8, 73);
INSERT INTO permissions VALUES (50, 8, 74);
INSERT INTO permissions VALUES (51, 8, 75);
INSERT INTO permissions VALUES (52, 8, 76);
INSERT INTO permissions VALUES (53, 6, 58);
INSERT INTO permissions VALUES (54, 6, 59);
INSERT INTO permissions VALUES (55, 6, 60);
INSERT INTO permissions VALUES (56, 6, 61);
INSERT INTO permissions VALUES (57, 6, 62);
INSERT INTO permissions VALUES (58, 6, 63);
INSERT INTO permissions VALUES (59, 6, 64);
INSERT INTO permissions VALUES (60, 6, 65);
INSERT INTO permissions VALUES (61, 6, 66);
INSERT INTO permissions VALUES (62, 6, 67);
INSERT INTO permissions VALUES (63, 6, 68);
INSERT INTO permissions VALUES (64, 6, 69);
INSERT INTO permissions VALUES (65, 6, 70);
INSERT INTO permissions VALUES (66, 6, 71);
INSERT INTO permissions VALUES (67, 6, 72);
INSERT INTO permissions VALUES (68, 6, 73);
INSERT INTO permissions VALUES (69, 6, 74);
INSERT INTO permissions VALUES (70, 6, 75);
INSERT INTO permissions VALUES (71, 6, 76);
INSERT INTO permissions VALUES (72, 2, 57);
INSERT INTO permissions VALUES (73, 2, 58);
INSERT INTO permissions VALUES (74, 2, 59);
INSERT INTO permissions VALUES (75, 2, 60);
INSERT INTO permissions VALUES (76, 2, 61);
INSERT INTO permissions VALUES (77, 2, 62);
INSERT INTO permissions VALUES (78, 2, 63);
INSERT INTO permissions VALUES (79, 2, 64);
INSERT INTO permissions VALUES (80, 2, 65);
INSERT INTO permissions VALUES (81, 2, 66);
INSERT INTO permissions VALUES (82, 2, 67);
INSERT INTO permissions VALUES (83, 2, 68);
INSERT INTO permissions VALUES (84, 2, 69);
INSERT INTO permissions VALUES (85, 2, 70);
INSERT INTO permissions VALUES (86, 2, 71);
INSERT INTO permissions VALUES (87, 2, 72);
INSERT INTO permissions VALUES (88, 2, 73);
INSERT INTO permissions VALUES (89, 2, 74);
INSERT INTO permissions VALUES (90, 2, 75);
INSERT INTO permissions VALUES (91, 2, 76);
INSERT INTO permissions VALUES (92, 4, 81);
INSERT INTO permissions VALUES (93, 13, 82);
INSERT INTO permissions VALUES (94, 15, 83);
INSERT INTO permissions VALUES (95, 15, 84);
INSERT INTO permissions VALUES (96, 13, 85);
INSERT INTO permissions VALUES (97, 15, 86);
INSERT INTO permissions VALUES (98, 15, 87);
INSERT INTO permissions VALUES (99, 15, 88);
INSERT INTO permissions VALUES (100, 13, 91);
INSERT INTO permissions VALUES (101, 13, 92);
INSERT INTO permissions VALUES (102, 15, 93);
INSERT INTO permissions VALUES (103, 13, 94);
INSERT INTO permissions VALUES (104, 13, 95);
INSERT INTO permissions VALUES (105, 13, 96);
INSERT INTO permissions VALUES (106, 15, 97);
INSERT INTO permissions VALUES (107, 4, 98);
INSERT INTO permissions VALUES (108, 4, 99);
INSERT INTO permissions VALUES (109, 4, 100);
INSERT INTO permissions VALUES (110, 15, 101);
INSERT INTO permissions VALUES (111, 4, 102);
INSERT INTO permissions VALUES (112, 4, 103);
INSERT INTO permissions VALUES (113, 4, 104);
INSERT INTO permissions VALUES (114, 13, 77);
INSERT INTO permissions VALUES (115, 13, 78);
INSERT INTO permissions VALUES (116, 16, 78);
INSERT INTO permissions VALUES (117, 4, 80);
INSERT INTO permissions VALUES (118, 13, 80);
INSERT INTO permissions VALUES (119, 15, 80);
INSERT INTO permissions VALUES (120, 14, 80);
INSERT INTO permissions VALUES (121, 16, 80);


--
-- TOC entry 2078 (class 0 OID 16925)
-- Dependencies: 1616
-- Data for Name: route; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

INSERT INTO route VALUES (11, 4, 1, 'context', 4, NULL);
INSERT INTO route VALUES (14, 5, 1, 'context', 6, NULL);
INSERT INTO route VALUES (16, 7, 1, 'context', 7, NULL);
INSERT INTO route VALUES (20, 8, 1, 'trunk', 80, 57);
INSERT INTO route VALUES (21, 8, 1, 'trunk', 80, 58);
INSERT INTO route VALUES (22, 8, 1, 'trunk', 80, 59);
INSERT INTO route VALUES (23, 8, 1, 'trunk', 80, 60);
INSERT INTO route VALUES (24, 8, 1, 'trunk', 80, 61);
INSERT INTO route VALUES (25, 8, 1, 'trunk', 80, 62);
INSERT INTO route VALUES (26, 8, 1, 'trunk', 80, 63);
INSERT INTO route VALUES (27, 8, 1, 'trunk', 80, NULL);
INSERT INTO route VALUES (28, 6, 1, 'trunk', 80, NULL);
INSERT INTO route VALUES (29, 6, 1, 'trunk', 80, 57);
INSERT INTO route VALUES (30, 6, 1, 'trunk', 80, 58);
INSERT INTO route VALUES (31, 6, 1, 'trunk', 80, 59);
INSERT INTO route VALUES (32, 6, 1, 'trunk', 80, 60);
INSERT INTO route VALUES (33, 6, 1, 'trunk', 80, 61);
INSERT INTO route VALUES (34, 6, 1, 'trunk', 80, 62);
INSERT INTO route VALUES (35, 6, 1, 'trunk', 80, 63);
INSERT INTO route VALUES (36, 6, 1, 'trunk', 77, 69);
INSERT INTO route VALUES (37, 6, 1, 'trunk', 77, 70);
INSERT INTO route VALUES (38, 6, 1, 'trunk', 77, 71);
INSERT INTO route VALUES (39, 6, 1, 'trunk', 77, 72);
INSERT INTO route VALUES (4, 1, 1, 'trunk', 80, NULL);
INSERT INTO route VALUES (40, 2, 1, 'tgrp', 2, NULL);
INSERT INTO route VALUES (41, 2, 2, 'tgrp', 3, NULL);
INSERT INTO route VALUES (42, 2, 3, 'tgrp', 4, NULL);
INSERT INTO route VALUES (43, 10, 1, 'tgrp', 5, NULL);
INSERT INTO route VALUES (44, 10, 2, 'tgrp', 6, NULL);
INSERT INTO route VALUES (45, 11, 1, 'tgrp', 7, NULL);
INSERT INTO route VALUES (46, 11, 2, 'trunk', 85, NULL);
INSERT INTO route VALUES (48, 12, 1, 'tgrp', 9, NULL);
INSERT INTO route VALUES (49, 2, 1, 'trunk', 100, 57);
INSERT INTO route VALUES (50, 2, 1, 'trunk', 100, 58);
INSERT INTO route VALUES (51, 2, 1, 'trunk', 100, 59);
INSERT INTO route VALUES (52, 2, 1, 'trunk', 100, 60);
INSERT INTO route VALUES (53, 2, 1, 'trunk', 100, 61);
INSERT INTO route VALUES (54, 2, 1, 'trunk', 100, 62);
INSERT INTO route VALUES (55, 2, 1, 'trunk', 100, 63);
INSERT INTO route VALUES (57, 10, 1, 'trunk', 100, 57);
INSERT INTO route VALUES (58, 10, 1, 'trunk', 100, 58);
INSERT INTO route VALUES (59, 10, 1, 'trunk', 100, 59);
INSERT INTO route VALUES (60, 10, 1, 'trunk', 100, 60);
INSERT INTO route VALUES (61, 10, 1, 'trunk', 100, 61);
INSERT INTO route VALUES (62, 10, 1, 'trunk', 100, 62);
INSERT INTO route VALUES (63, 10, 1, 'trunk', 100, 63);
INSERT INTO route VALUES (64, 11, 1, 'trunk', 100, 57);
INSERT INTO route VALUES (65, 11, 1, 'trunk', 100, 58);
INSERT INTO route VALUES (66, 11, 1, 'trunk', 100, 59);
INSERT INTO route VALUES (67, 11, 1, 'trunk', 100, 60);
INSERT INTO route VALUES (68, 11, 1, 'trunk', 100, 61);
INSERT INTO route VALUES (69, 11, 1, 'trunk', 100, 62);
INSERT INTO route VALUES (70, 11, 1, 'trunk', 100, 63);
INSERT INTO route VALUES (71, 12, 1, 'trunk', 100, 57);
INSERT INTO route VALUES (72, 12, 1, 'trunk', 100, 58);
INSERT INTO route VALUES (73, 12, 1, 'trunk', 100, 59);
INSERT INTO route VALUES (74, 12, 1, 'trunk', 100, 60);
INSERT INTO route VALUES (75, 12, 1, 'trunk', 100, 61);
INSERT INTO route VALUES (76, 12, 1, 'trunk', 100, 62);
INSERT INTO route VALUES (77, 12, 1, 'trunk', 100, 63);
INSERT INTO route VALUES (78, 2, 2, 'tgrp', 2, 57);
INSERT INTO route VALUES (79, 2, 2, 'tgrp', 2, 58);
INSERT INTO route VALUES (80, 2, 2, 'tgrp', 2, 59);
INSERT INTO route VALUES (81, 2, 2, 'tgrp', 2, 60);
INSERT INTO route VALUES (82, 2, 2, 'tgrp', 2, 61);
INSERT INTO route VALUES (83, 2, 2, 'tgrp', 2, 62);
INSERT INTO route VALUES (84, 2, 2, 'tgrp', 2, 63);
INSERT INTO route VALUES (87, 2, 3, 'tgrp', 3, 57);
INSERT INTO route VALUES (88, 2, 3, 'tgrp', 3, 58);
INSERT INTO route VALUES (89, 2, 3, 'tgrp', 3, 59);
INSERT INTO route VALUES (90, 2, 3, 'tgrp', 3, 60);
INSERT INTO route VALUES (91, 2, 3, 'tgrp', 3, 61);
INSERT INTO route VALUES (92, 2, 3, 'tgrp', 3, 62);
INSERT INTO route VALUES (93, 2, 3, 'tgrp', 3, 63);
INSERT INTO route VALUES (94, 2, 1, 'tgrp', 3, 69);
INSERT INTO route VALUES (95, 2, 1, 'tgrp', 3, 70);
INSERT INTO route VALUES (96, 2, 1, 'tgrp', 3, 71);
INSERT INTO route VALUES (97, 2, 1, 'tgrp', 3, 72);
INSERT INTO route VALUES (98, 2, 2, 'tgrp', 4, 69);
INSERT INTO route VALUES (99, 2, 2, 'tgrp', 4, 70);
INSERT INTO route VALUES (100, 2, 2, 'tgrp', 4, 71);
INSERT INTO route VALUES (101, 2, 2, 'tgrp', 4, 72);
INSERT INTO route VALUES (102, 10, 2, 'tgrp', 5, 57);
INSERT INTO route VALUES (103, 10, 2, 'tgrp', 5, 58);
INSERT INTO route VALUES (104, 10, 2, 'tgrp', 5, 59);
INSERT INTO route VALUES (105, 10, 2, 'tgrp', 5, 60);
INSERT INTO route VALUES (106, 10, 2, 'tgrp', 5, 61);
INSERT INTO route VALUES (107, 10, 2, 'tgrp', 5, 62);
INSERT INTO route VALUES (108, 10, 2, 'tgrp', 5, 63);
INSERT INTO route VALUES (109, 10, 3, 'tgrp', 6, 57);
INSERT INTO route VALUES (110, 10, 3, 'tgrp', 6, 58);
INSERT INTO route VALUES (111, 10, 3, 'tgrp', 6, 59);
INSERT INTO route VALUES (113, 10, 3, 'tgrp', 6, 60);
INSERT INTO route VALUES (114, 10, 3, 'tgrp', 6, 61);
INSERT INTO route VALUES (115, 10, 3, 'tgrp', 6, 62);
INSERT INTO route VALUES (116, 10, 3, 'tgrp', 6, 63);
INSERT INTO route VALUES (118, 13, 1, 'context', 8, NULL);
INSERT INTO route VALUES (119, 14, 1, 'context', 11, NULL);
INSERT INTO route VALUES (120, 15, 1, 'context', 10, NULL);
INSERT INTO route VALUES (121, 16, 1, 'context', 12, NULL);


--
-- TOC entry 2079 (class 0 OID 16933)
-- Dependencies: 1618
-- Data for Name: trunkgroup_items; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

INSERT INTO trunkgroup_items VALUES (17, 93, 7, false);
INSERT INTO trunkgroup_items VALUES (18, 94, 7, false);
INSERT INTO trunkgroup_items VALUES (19, 95, 9, false);
INSERT INTO trunkgroup_items VALUES (20, 96, 9, false);
INSERT INTO trunkgroup_items VALUES (21, 85, 8, false);
INSERT INTO trunkgroup_items VALUES (10, 82, 4, false);
INSERT INTO trunkgroup_items VALUES (16, 102, 6, false);
INSERT INTO trunkgroup_items VALUES (15, 101, 6, true);
INSERT INTO trunkgroup_items VALUES (5, 102, 2, false);
INSERT INTO trunkgroup_items VALUES (6, 103, 2, false);
INSERT INTO trunkgroup_items VALUES (7, 104, 2, true);
INSERT INTO trunkgroup_items VALUES (8, 89, 3, false);
INSERT INTO trunkgroup_items VALUES (9, 90, 3, true);
INSERT INTO trunkgroup_items VALUES (13, 91, 5, false);
INSERT INTO trunkgroup_items VALUES (14, 92, 5, true);
INSERT INTO trunkgroup_items VALUES (11, 83, 4, false);
INSERT INTO trunkgroup_items VALUES (12, 84, 4, true);
INSERT INTO trunkgroup_items VALUES (3, 3, 1, false);
INSERT INTO trunkgroup_items VALUES (4, 4, 1, false);
INSERT INTO trunkgroup_items VALUES (2, 2, 1, true);


--
-- TOC entry 2080 (class 0 OID 16939)
-- Dependencies: 1620
-- Data for Name: trunkgroups; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

INSERT INTO trunkgroups VALUES (1, 'Test trunk group');
INSERT INTO trunkgroups VALUES (2, 'KyivStar1');
INSERT INTO trunkgroups VALUES (3, 'KyivStar2');
INSERT INTO trunkgroups VALUES (4, 'KyivStar3');
INSERT INTO trunkgroups VALUES (5, 'MTS1');
INSERT INTO trunkgroups VALUES (6, 'MTS2');
INSERT INTO trunkgroups VALUES (7, 'Life1');
INSERT INTO trunkgroups VALUES (8, 'Life2');
INSERT INTO trunkgroups VALUES (9, 'Beeline1');


SET search_path = integration, pg_catalog;

--
-- TOC entry 2015 (class 2606 OID 16962)
-- Dependencies: 1587 1587
-- Name: ULines_pkey; Type: CONSTRAINT; Schema: integration; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY ulines
    ADD CONSTRAINT "ULines_pkey" PRIMARY KEY (id);


--
-- TOC entry 2013 (class 2606 OID 16964)
-- Dependencies: 1585 1585
-- Name: recordings_pkey; Type: CONSTRAINT; Schema: integration; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY recordings
    ADD CONSTRAINT recordings_pkey PRIMARY KEY (id);


--
-- TOC entry 2017 (class 2606 OID 16966)
-- Dependencies: 1588 1588
-- Name: workplaces_pkey; Type: CONSTRAINT; Schema: integration; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY workplaces
    ADD CONSTRAINT workplaces_pkey PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- TOC entry 2020 (class 2606 OID 16968)
-- Dependencies: 1593 1593
-- Name: extensions_conf_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY extensions_conf
    ADD CONSTRAINT extensions_conf_pkey PRIMARY KEY (id);


--
-- TOC entry 2022 (class 2606 OID 16970)
-- Dependencies: 1597 1597
-- Name: queue_members_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY queue_members
    ADD CONSTRAINT queue_members_pkey PRIMARY KEY (uniqueid);


--
-- TOC entry 2025 (class 2606 OID 16972)
-- Dependencies: 1601 1601
-- Name: queues_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY queues
    ADD CONSTRAINT queues_pkey PRIMARY KEY (name);


--
-- TOC entry 2027 (class 2606 OID 16974)
-- Dependencies: 1602 1602
-- Name: sip_conf_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY sip_conf
    ADD CONSTRAINT sip_conf_pkey PRIMARY KEY (id);


--
-- TOC entry 2030 (class 2606 OID 16976)
-- Dependencies: 1604 1604
-- Name: sip_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY sip_peers
    ADD CONSTRAINT sip_peers_pkey PRIMARY KEY (id);


SET search_path = routing, pg_catalog;

--
-- TOC entry 2037 (class 2606 OID 16978)
-- Dependencies: 1612 1612
-- Name: DLIST_PK; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY directions_list
    ADD CONSTRAINT "DLIST_PK" PRIMARY KEY (dlist_id);


--
-- TOC entry 2039 (class 2606 OID 16980)
-- Dependencies: 1612 1612
-- Name: DLIST_UNIQ_NAME; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY directions_list
    ADD CONSTRAINT "DLIST_UNIQ_NAME" UNIQUE (dlist_name);


--
-- TOC entry 2032 (class 2606 OID 16982)
-- Dependencies: 1608 1608
-- Name: callerid_pkey; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY callerid
    ADD CONSTRAINT callerid_pkey PRIMARY KEY (id);


--
-- TOC entry 2034 (class 2606 OID 16984)
-- Dependencies: 1610 1610
-- Name: dr_pk; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY directions
    ADD CONSTRAINT dr_pk PRIMARY KEY (dr_id);


--
-- TOC entry 2042 (class 2606 OID 16986)
-- Dependencies: 1614 1614
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 2044 (class 2606 OID 16988)
-- Dependencies: 1616 1616
-- Name: route_pkey; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY route
    ADD CONSTRAINT route_pkey PRIMARY KEY (route_id);


--
-- TOC entry 2050 (class 2606 OID 16990)
-- Dependencies: 1620 1620
-- Name: tgrp_name_uniq; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY trunkgroups
    ADD CONSTRAINT tgrp_name_uniq UNIQUE (tgrp_name);


--
-- TOC entry 2052 (class 2606 OID 16992)
-- Dependencies: 1620 1620
-- Name: tgrp_pkey; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY trunkgroups
    ADD CONSTRAINT tgrp_pkey PRIMARY KEY (tgrp_id);


--
-- TOC entry 2048 (class 2606 OID 16994)
-- Dependencies: 1618 1618
-- Name: trunkgroup_items_pkey; Type: CONSTRAINT; Schema: routing; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY trunkgroup_items
    ADD CONSTRAINT trunkgroup_items_pkey PRIMARY KEY (tgrp_item_id);


SET search_path = public, pg_catalog;

--
-- TOC entry 2018 (class 1259 OID 16995)
-- Dependencies: 1592
-- Name: cdr_calldate; Type: INDEX; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE INDEX cdr_calldate ON cdr USING btree (calldate);


--
-- TOC entry 2023 (class 1259 OID 16996)
-- Dependencies: 1597 1597
-- Name: queue_uniq; Type: INDEX; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE UNIQUE INDEX queue_uniq ON queue_members USING btree (queue_name, interface);


--
-- TOC entry 2028 (class 1259 OID 16997)
-- Dependencies: 1604
-- Name: sip_peers_name; Type: INDEX; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE UNIQUE INDEX sip_peers_name ON sip_peers USING btree (name);


SET search_path = routing, pg_catalog;

--
-- TOC entry 2040 (class 1259 OID 16998)
-- Dependencies: 1614
-- Name: fki_direction_in_dlist; Type: INDEX; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE INDEX fki_direction_in_dlist ON permissions USING btree (direction_id);


--
-- TOC entry 2035 (class 1259 OID 16999)
-- Dependencies: 1610
-- Name: fki_dr_name; Type: INDEX; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE INDEX fki_dr_name ON directions USING btree (dr_list_item);


--
-- TOC entry 2045 (class 1259 OID 17000)
-- Dependencies: 1618
-- Name: fki_tgrp_item_fk; Type: INDEX; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE INDEX fki_tgrp_item_fk ON trunkgroup_items USING btree (tgrp_item_peer_id);


--
-- TOC entry 2046 (class 1259 OID 17001)
-- Dependencies: 1618
-- Name: fki_tgrp_item_group; Type: INDEX; Schema: routing; Owner: asterisk; Tablespace: 
--

CREATE INDEX fki_tgrp_item_group ON trunkgroup_items USING btree (tgrp_item_group_id);


--
-- TOC entry 2060 (class 2620 OID 17002)
-- Dependencies: 39 1616
-- Name: route_check_dest_id; Type: TRIGGER; Schema: routing; Owner: asterisk
--

CREATE TRIGGER route_check_dest_id BEFORE INSERT OR UPDATE ON route FOR EACH ROW EXECUTE PROCEDURE route_test();


SET search_path = integration, pg_catalog;

--
-- TOC entry 2053 (class 2606 OID 17003)
-- Dependencies: 1588 1604 2029
-- Name: workplaces_sip_id_fkey; Type: FK CONSTRAINT; Schema: integration; Owner: asterisk
--

ALTER TABLE ONLY workplaces
    ADD CONSTRAINT workplaces_sip_id_fkey FOREIGN KEY (sip_id) REFERENCES public.sip_peers(id);


SET search_path = routing, pg_catalog;

--
-- TOC entry 2054 (class 2606 OID 17008)
-- Dependencies: 1608 1612 2036
-- Name: callerid_direction_id_fkey; Type: FK CONSTRAINT; Schema: routing; Owner: asterisk
--

ALTER TABLE ONLY callerid
    ADD CONSTRAINT callerid_direction_id_fkey FOREIGN KEY (direction_id) REFERENCES directions_list(dlist_id);


--
-- TOC entry 2055 (class 2606 OID 17013)
-- Dependencies: 1610 1612 2036
-- Name: dr_name; Type: FK CONSTRAINT; Schema: routing; Owner: asterisk
--

ALTER TABLE ONLY directions
    ADD CONSTRAINT dr_name FOREIGN KEY (dr_list_item) REFERENCES directions_list(dlist_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2056 (class 2606 OID 17018)
-- Dependencies: 1614 1612 2036
-- Name: fk_direction_in_dlist; Type: FK CONSTRAINT; Schema: routing; Owner: asterisk
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT fk_direction_in_dlist FOREIGN KEY (direction_id) REFERENCES directions_list(dlist_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2057 (class 2606 OID 17023)
-- Dependencies: 1616 1612 2036
-- Name: route_route_direction_id_fkey; Type: FK CONSTRAINT; Schema: routing; Owner: asterisk
--

ALTER TABLE ONLY route
    ADD CONSTRAINT route_route_direction_id_fkey FOREIGN KEY (route_direction_id) REFERENCES directions_list(dlist_id);


--
-- TOC entry 2058 (class 2606 OID 17028)
-- Dependencies: 1618 1604 2029
-- Name: tgrp_item_fk; Type: FK CONSTRAINT; Schema: routing; Owner: asterisk
--

ALTER TABLE ONLY trunkgroup_items
    ADD CONSTRAINT tgrp_item_fk FOREIGN KEY (tgrp_item_peer_id) REFERENCES public.sip_peers(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2059 (class 2606 OID 17033)
-- Dependencies: 1618 1620 2051
-- Name: tgrp_item_group; Type: FK CONSTRAINT; Schema: routing; Owner: asterisk
--

ALTER TABLE ONLY trunkgroup_items
    ADD CONSTRAINT tgrp_item_group FOREIGN KEY (tgrp_item_group_id) REFERENCES trunkgroups(tgrp_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2086 (class 0 OID 0)
-- Dependencies: 9
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2012-01-09 13:56:37 EET

--
-- PostgreSQL database dump complete
--

