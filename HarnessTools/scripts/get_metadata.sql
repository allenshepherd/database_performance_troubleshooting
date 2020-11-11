set lines 220 pages 9000 long 4000
select DBMS_METADATA.GET_DDL('&OBJECT_TYPE','&OBJECT_NAME','&OBJECT_OWNER') from dual
/
