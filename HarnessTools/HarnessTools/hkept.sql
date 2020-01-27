set echo off

rem $Header$
rem $Name$      hkept.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Show objects kept/pinned in the cache
rem


set pagesize 60 feedback off heading on termout on

column executions format 999,999,999
column Mem_used format 999,999,999

SELECT SUBSTR(owner,1,10) Owner,
       SUBSTR(type,1,12) Type,
       SUBSTR(name,1,20) Name,
       executions,
       sharable_mem Mem_used,
       SUBSTR(kept||' ',1,4) "Kept?"
  FROM v$db_object_cache
 WHERE type in ('TRIGGER','PROCEDURE','PACKAGE BODY','PACKAGE')
 ORDER BY executions desc
/

clear columns

@henv

