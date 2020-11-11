Rem
Rem $Header: rdbms/admin/cdsqlddl.sql /main/24 2017/03/17 20:38:03 anupkk Exp $
Rem
Rem cdsqlddl.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdsqlddl.sql - Catalog DSQLDDL.bsq views
Rem
Rem    DESCRIPTION
Rem      database links, dictionary, recyclebin objects, etc
Rem
Rem    NOTES
Rem      This script contains Catalog Views for objects in dsqlddl.bsq.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdsqlddl.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdsqlddl.sql
Rem SQL_PHASE: CDSQLDDL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    anupkk      03/09/17 - Bug 25512307: Add DICTIONARY_CREDENTIALS_ENCRYPT
Rem    anupkk      12/09/16 - Proj 67576: Add valid column in
Rem                           DBA_DB_LINKS, ALL_DB_LINKS and USER_DB_LINKS
Rem    zzeng       09/19/16 - Bug 22515110: add SHARD_INTERNAL to *_DB_LINKS
Rem    makataok    07/14/16 - 23498888: add UNNEST hint to USER_RECYCLEBIN
Rem    kquinn      11/11/15 - 22186210: Support CDB_* objects in
Rem                           DICT/DICTIONARY views
Rem    rpang       01/20/15 - 17854208: add diagnostic columns to sqltxl views
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    thbaby      10/16/14 - Proj 47234: add HIDDEN column to *_DB_LINKS
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    sasounda    11/19/13 - 17746252: handle KZSRAT when creating all_* views
Rem    rpang       10/23/13 - 17637420: add tracking columns to sqltxl views
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    rpang       08/26/12 - Rename SQL translation profile attributes
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    hlakshma    11/10/11 - Move ILM related views to catilm.sql
Rem    hlakshma    10/15/11 - ILM view enhancements
Rem    rpang       09/22/11 - 13015720: Add FOREIGN_SQL_SYNTAX column
Rem    hlakshma    08/24/11 - ILM related view enhancements
Rem    hlakshma    05/25/11 - ILM (project 30966) related views
Rem    rpang       02/06/11 - add SQL translation dictionary views
Rem    achoi       05/18/06 - handle application edition 
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

remark
remark  FAMILY "DB_LINKS"
remark  All relevant information about database links.
remark
create or replace view USER_DB_LINKS
    (DB_LINK, USERNAME, PASSWORD, HOST, CREATED, HIDDEN, SHARD_INTERNAL, VALID)
as
select l.name, l.userid, l.password, l.host, l.ctime,
       decode(bitand(l.flag, 4), 4, 'YES', 'NO'),
       decode(bitand(l.flag, 8), 8, 'YES', 'NO'),
       decode(bitand(l.flag, 16), 16, 'NO', 'YES')
from sys.link$ l
where l.owner# = userenv('SCHEMAID')
/
comment on table USER_DB_LINKS is
'Database links owned by the user'
/
comment on column USER_DB_LINKS.DB_LINK is
'Name of the database link'
/
comment on column USER_DB_LINKS.USERNAME is
'Name of user to log on as'
/
comment on column USER_DB_LINKS.PASSWORD is
'Deprecated-Password for logon'
/
comment on column USER_DB_LINKS.HOST is
'SQL*Net string for connect'
/
comment on column USER_DB_LINKS.CREATED is
'Creation time of the database link'
/
comment on column USER_DB_LINKS.HIDDEN is
'Whether database link is hidden or not'
/
comment on column USER_DB_LINKS.SHARD_INTERNAL is
'Whether database link is internally managed for sharding'
/
comment on column USER_DB_LINKS.VALID is
'Whether database link is usable or not'
/
create or replace public synonym USER_DB_LINKS for USER_DB_LINKS
/
grant read on USER_DB_LINKS to PUBLIC with grant option
/
create or replace view ALL_DB_LINKS
    (OWNER, DB_LINK, USERNAME, HOST, CREATED, HIDDEN, SHARD_INTERNAL, VALID)
as
select u.name, l.name, l.userid, l.host, l.ctime,
       decode(bitand(l.flag, 4), 4, 'YES', 'NO'),
       decode(bitand(l.flag, 8), 8, 'YES', 'NO'),
       decode(bitand(l.flag, 16), 16, 'NO', 'YES')
from sys.link$ l, sys.user$ u
where l.owner# in ( select kzsrorol from x$kzsro )
  and l.owner# = u.user#
/
comment on table ALL_DB_LINKS is
'Database links accessible to the user'
/
comment on column ALL_DB_LINKS.DB_LINK is
'Name of the database link'
/
comment on column ALL_DB_LINKS.USERNAME is
'Name of user to log on as'
/
comment on column ALL_DB_LINKS.HOST is
'SQL*Net string for connect'
/
comment on column ALL_DB_LINKS.CREATED is
'Creation time of the database link'
/
comment on column ALL_DB_LINKS.HIDDEN is
'Whether database link is hidden or not'
/
comment on column ALL_DB_LINKS.SHARD_INTERNAL is
'Whether database link is internally managed for sharding'
/
comment on column ALL_DB_LINKS.VALID is
'Whether database link is usable or not'
/
create or replace public synonym ALL_DB_LINKS for ALL_DB_LINKS
/
grant read on ALL_DB_LINKS to PUBLIC with grant option
/
create or replace view DBA_DB_LINKS
    (OWNER, DB_LINK, USERNAME, HOST, CREATED, HIDDEN, SHARD_INTERNAL, VALID)
as
select u.name, l.name, l.userid, l.host, l.ctime,
       decode(bitand(l.flag, 4), 4, 'YES', 'NO'),
       decode(bitand(l.flag, 8), 8, 'YES', 'NO'),
       decode(bitand(l.flag, 16), 16, 'NO', 'YES')
from sys.link$ l, sys.user$ u
where l.owner# = u.user#
/
create or replace public synonym DBA_DB_LINKS for DBA_DB_LINKS
/
grant select on DBA_DB_LINKS to select_catalog_role
/
comment on table DBA_DB_LINKS is
'All database links in the database'
/
comment on column DBA_DB_LINKS.DB_LINK is
'Name of the database link'
/
comment on column DBA_DB_LINKS.USERNAME is
'Name of user to log on as'
/
comment on column DBA_DB_LINKS.HOST is
'SQL*Net string for connect'
/
comment on column DBA_DB_LINKS.CREATED is
'Creation time of the database link'
/
comment on column DBA_DB_LINKS.HIDDEN is
'Whether database link is hidden or not'
/
comment on column DBA_DB_LINKS.SHARD_INTERNAL is
'Whether database link is internally managed for sharding'
/
comment on column DBA_DB_LINKS.VALID is
'Whether database link is usable or not'
/

execute CDBView.create_cdbview(false,'SYS','DBA_DB_LINKS','CDB_DB_LINKS');
grant select on SYS.CDB_DB_LINKS to select_catalog_role
/
create or replace public synonym CDB_DB_LINKS for SYS.CDB_DB_LINKS
/

remark
remark  VIEW "DICTIONARY"
remark  Online documentation for data dictionary tables and views.
remark  This view exists outside of the family schema.
remark
/* Find the names of public synonyms for views owned by SYS that
have names different from the synonym name.  This allows the user
to see the short-hand synonyms we have created.
*/
create or replace view DICTIONARY
    (TABLE_NAME, COMMENTS)
as
select o.name, c.comment$
from sys.obj$ o, sys.com$ c
where o.obj# = c.obj#(+)
  and c.col# is null
  and o.owner# = 0
  and o.type# = 4
  and (o.name like 'USER%'
       or o.name like 'ALL%'
       or ((o.name like 'DBA%' or o.name like 'CDB_%')
           and exists
                   (select null
                    from sys.v$enabledprivs
                    where priv_number = -47 /* SELECT ANY TABLE */
                    or priv_number = -397 /* READ ANY TABLE */)
           )
      )
union all
select o.name, c.comment$
from sys.obj$ o, sys.com$ c
where o.obj# = c.obj#(+)
  and o.owner# = 0
  and o.name in ('AUDIT_ACTIONS', 'COLUMN_PRIVILEGES', 'DICTIONARY',
        'DICT_COLUMNS', 'DUAL', 'GLOBAL_NAME', 'INDEX_HISTOGRAM',
        'INDEX_STATS', 'RESOURCE_COST', 'ROLE_ROLE_PRIVS', 'ROLE_SYS_PRIVS',
        'ROLE_TAB_PRIVS', 'SESSION_PRIVS', 'SESSION_ROLES',
        'TABLE_PRIVILEGES','NLS_SESSION_PARAMETERS','NLS_INSTANCE_PARAMETERS',
        'NLS_DATABASE_PARAMETERS', 'DATABASE_COMPATIBLE_LEVEL',
        'DBMS_ALERT_INFO', 'DBMS_LOCK_ALLOCATED')
  and c.col# is null
union all
select so.name, 'Synonym for ' || sy.name
from sys.obj$ ro, sys.syn$ sy, sys.obj$ so
where so.type# = 5
  and ro.linkname is null
  and so.owner# = 1
  and so.obj# = sy.obj#
  and so.name <> sy.name
  and sy.owner = 'SYS'
  and sy.name = ro.name
  and ro.owner# = 0
  and ro.type# = 4
  and (ro.owner# = userenv('SCHEMAID')
       or ro.obj# in
           (select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro))
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -397/* READ ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  ))
/
comment on table DICTIONARY is
'Description of data dictionary tables and views'
/
comment on column DICTIONARY.TABLE_NAME is
'Name of the object'
/
comment on column DICTIONARY.COMMENTS is
'Text comment on the object'
/

create or replace public synonym DICTIONARY for DICTIONARY
/
create or replace public synonym DICT for DICTIONARY
/
grant read on DICTIONARY to PUBLIC with grant option
/
remark
remark  VIEW "DICT_COLUMNS"
remark  Online documentation for columns in data dictionary tables and views.
remark  This view exists outside of the family schema.
remark
/* Find the column comments for public synonyms for views owned by SYS that
have names different from the synonym name.  This allows the user
to see the columns of the short-hand synonyms we have created.
*/
create or replace view DICT_COLUMNS
    (TABLE_NAME, COLUMN_NAME, COMMENTS)
as
select o.name, c.name, co.comment$
from sys.com$ co, sys.col$ c, sys.obj$ o
where o.owner# = 0
  and o.type# = 4
  and (o.name like 'USER%'
       or o.name like 'ALL%'
       or (o.name like 'DBA%'
           and exists
                   (select null
                    from sys.v$enabledprivs
                    where priv_number = -47 /* SELECT ANY TABLE */
                    or priv_number = -397 /* READ ANY TABLE */)
           )
      )
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.col# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
union all
select o.name, c.name, co.comment$
from sys.com$ co, sys.col$ c, sys.obj$ o
where o.owner# = 0
  and o.name in ('AUDIT_ACTIONS','DUAL','DICTIONARY', 'DICT_COLUMNS')
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.col# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
union all
select so.name, c.name, co.comment$
from sys.com$ co,sys.col$ c, sys.obj$ ro, sys.syn$ sy, sys.obj$ so
where so.type# = 5
  and so.owner# = 1
  and so.obj# = sy.obj#
  and so.name <> sy.name
  and sy.owner = 'SYS'
  and sy.name = ro.name
  and ro.owner# = 0
  and ro.type# = 4
  and ro.obj# = c.obj#
  and c.col# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
  and c.obj# = co.obj#(+)
/
comment on table DICT_COLUMNS is
'Description of columns in data dictionary tables and views'
/
comment on column DICT_COLUMNS.TABLE_NAME is
'Name of the object that contains the column'
/
comment on column DICT_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column DICT_COLUMNS.COMMENTS is
'Text comment on the object'
/
create or replace public synonym DICT_COLUMNS for DICT_COLUMNS
/
grant read on DICT_COLUMNS to PUBLIC with grant option
/


Rem
Rem Trusted Servers View
Rem
create or replace view TRUSTED_SERVERS(TRUST, NAME)
as
select a.trust, b.dbname from sys.trusted_list$ b,
(select decode (dbname, '+*','Untrusted', '-*', 'Trusted') trust
from sys.trusted_list$ where dbname like '%*') a
where b.dbname not like '%*'
union
select decode (dbname, '-*', 'Untrusted', '+*', 'Trusted') trust, 'All'
from sys.trusted_list$
where dbname like '%*'
/
create or replace public synonym TRUSTED_SERVERS for TRUSTED_SERVERS
/
grant select on TRUSTED_SERVERS to select_catalog_role
/
comment on table TRUSTED_SERVERS is
'Trustedness of Servers'
/
comment on column TRUSTED_SERVERS.TRUST is
'Trustedness of the server listed. Unlisted servers have opposite trustedness.'
/
comment on column TRUSTED_SERVERS.NAME is
'Server name'
/


remark
remark  FAMILY "RECYCLEBIN"
remark  List of objects in recycle bin
remark
remark 23498888: UNNEST hint in case CBT determines to not unnest
remark 
create or replace view USER_RECYCLEBIN
    (OBJECT_NAME, ORIGINAL_NAME, OPERATION, TYPE, TS_NAME,
     CREATETIME, DROPTIME, DROPSCN, PARTITION_NAME, CAN_UNDROP, CAN_PURGE,
     RELATED, BASE_OBJECT, PURGE_OBJECT, SPACE)
as
select /*+ UNNEST */ o.name, r.original_name,
       decode(r.operation, 0, 'DROP', 1, 'TRUNCATE', 'UNDEFINED'),
       decode(r.type#, 1, 'TABLE', 2, 'INDEX', 3, 'INDEX',
                       4, 'NESTED TABLE', 5, 'LOB', 6, 'LOB INDEX',
                       7, 'DOMAIN INDEX', 8, 'IOT TOP INDEX',
                       9, 'IOT OVERFLOW SEGMENT', 10, 'IOT MAPPING TABLE',
                       11, 'TRIGGER', 12, 'CONSTRAINT', 13, 'Table Partition',
                       14, 'Table Composite Partition', 15, 'Index Partition',
                       16, 'Index Composite Partition', 17, 'LOB Partition',
                       18, 'LOB Composite Partition',
                       'UNDEFINED'),
       t.name,
       to_char(o.ctime, 'YYYY-MM-DD:HH24:MI:SS'),
       to_char(r.droptime, 'YYYY-MM-DD:HH24:MI:SS'),
       r.dropscn, r.partition_name,
       decode(bitand(r.flags, 4), 0, 'NO', 4, 'YES', 'NO'),
       decode(bitand(r.flags, 2), 0, 'NO', 2, 'YES', 'NO'),
       r.related, r.bo, r.purgeobj, r.space
from sys."_CURRENT_EDITION_OBJ" o, sys.recyclebin$ r, sys.ts$ t
where r.owner# = userenv('SCHEMAID')
  and o.obj# = r.obj#
  and r.ts# = t.ts#(+)
/
comment on table USER_RECYCLEBIN is
'User view of his recyclebin'
/
comment on column USER_RECYCLEBIN.OBJECT_NAME is
'New name of the object'
/
comment on column USER_RECYCLEBIN.ORIGINAL_NAME is
'Original name of the object'
/
comment on column USER_RECYCLEBIN.OPERATION is
'Operation carried out on the object'
/
comment on column USER_RECYCLEBIN.TYPE is
'Type of the object'
/
comment on column USER_RECYCLEBIN.TS_NAME is
'Tablespace Name to which object belongs'
/
comment on column USER_RECYCLEBIN.CREATETIME is
'Timestamp for the creating of the object'
/
comment on column USER_RECYCLEBIN.DROPTIME is
'Timestamp for the dropping of the object'
/
comment on column USER_RECYCLEBIN.DROPSCN is
'SCN of the transaction which moved object to Recycle Bin'
/
comment on column USER_RECYCLEBIN.PARTITION_NAME is
'Partition Name which was dropped'
/
comment on column USER_RECYCLEBIN.CAN_UNDROP is
'User can undrop this object'
/
comment on column USER_RECYCLEBIN.CAN_PURGE is
'User can undrop this object'
/
comment on column USER_RECYCLEBIN.RELATED is
'Parent objects Obj#'
/
comment on column USER_RECYCLEBIN.BASE_OBJECT is
'Base objects Obj#'
/
comment on column USER_RECYCLEBIN.PURGE_OBJECT is
'Obj# for object which gets purged'
/
comment on column USER_RECYCLEBIN.SPACE is
'Number of blocks used by this object'
/
create or replace public synonym USER_RECYCLEBIN for USER_RECYCLEBIN
/
create or replace public synonym RECYCLEBIN for USER_RECYCLEBIN
/
grant read on USER_RECYCLEBIN to PUBLIC with grant option
/

create or replace view DBA_RECYCLEBIN
    (OWNER, OBJECT_NAME, ORIGINAL_NAME, OPERATION, TYPE, TS_NAME,
     CREATETIME, DROPTIME, DROPSCN, PARTITION_NAME, CAN_UNDROP, CAN_PURGE,
     RELATED, BASE_OBJECT, PURGE_OBJECT, SPACE)
as
select u.name, o.name, r.original_name,
       decode(r.operation, 0, 'DROP', 1, 'TRUNCATE', 'UNDEFINED'),
       decode(r.type#, 1, 'TABLE', 2, 'INDEX', 3, 'INDEX',
                       4, 'NESTED TABLE', 5, 'LOB', 6, 'LOB INDEX',
                       7, 'DOMAIN INDEX', 8, 'IOT TOP INDEX',
                       9, 'IOT OVERFLOW SEGMENT', 10, 'IOT MAPPING TABLE',
                       11, 'TRIGGER', 12, 'CONSTRAINT', 13, 'Table Partition',
                       14, 'Table Composite Partition', 15, 'Index Partition',
                       16, 'Index Composite Partition', 17, 'LOB Partition',
                       18, 'LOB Composite Partition',
                       'UNDEFINED'),
       t.name,
       to_char(o.ctime, 'YYYY-MM-DD:HH24:MI:SS'),
       to_char(r.droptime, 'YYYY-MM-DD:HH24:MI:SS'),
       r.dropscn, r.partition_name,
       decode(bitand(r.flags, 4), 0, 'NO', 4, 'YES', 'NO'),
       decode(bitand(r.flags, 2), 0, 'NO', 2, 'YES', 'NO'),
       r.related, r.bo, r.purgeobj, r.space
from sys."_CURRENT_EDITION_OBJ" o, sys.recyclebin$ r, sys.user$ u, sys.ts$ t
where o.obj# = r.obj#
  and r.owner# = u.user#
  and r.ts# = t.ts#(+)
/
comment on table DBA_RECYCLEBIN is
'Description of the Recyclebin view accessible to the user'
/
comment on column DBA_RECYCLEBIN.OWNER is
'Name of the original owner of the object'
/
comment on column DBA_RECYCLEBIN.OBJECT_NAME is
'New name of the object'
/
comment on column DBA_RECYCLEBIN.ORIGINAL_NAME is
'Original name of the object'
/
comment on column DBA_RECYCLEBIN.OPERATION is
'Operation carried out on the object'
/
comment on column DBA_RECYCLEBIN.TYPE is
'Type of the object'
/
comment on column DBA_RECYCLEBIN.TS_NAME is
'Tablespace Name to which object belongs'
/
comment on column DBA_RECYCLEBIN.CREATETIME is
'Timestamp for the creating of the object'
/
comment on column DBA_RECYCLEBIN.DROPTIME is
'Timestamp for the dropping of the object'
/
comment on column DBA_RECYCLEBIN.DROPSCN is
'SCN of the transaction which moved object to Recycle Bin'
/
comment on column DBA_RECYCLEBIN.PARTITION_NAME is
'Partition Name which was dropped'
/
comment on column DBA_RECYCLEBIN.CAN_UNDROP is
'User can undrop this object'
/
comment on column DBA_RECYCLEBIN.CAN_PURGE is
'User can purge this object'
/
comment on column DBA_RECYCLEBIN.RELATED is
'Parent objects Obj#'
/
comment on column DBA_RECYCLEBIN.BASE_OBJECT is
'Base objects Obj#'
/
comment on column DBA_RECYCLEBIN.PURGE_OBJECT is
'Obj# for object which gets purged'
/
comment on column DBA_RECYCLEBIN.SPACE is
'Number of blocks used by this object'
/
create or replace public synonym DBA_RECYCLEBIN for DBA_RECYCLEBIN
/
grant select on DBA_RECYCLEBIN to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_RECYCLEBIN','CDB_RECYCLEBIN');
grant select on SYS.CDB_RECYCLEBIN to select_catalog_role
/
create or replace public synonym CDB_RECYCLEBIN for SYS.CDB_RECYCLEBIN
/

Rem
Rem  FAMILY "SQL_TRANSLATION"
Rem  All relevant information about SQL translation.
Rem
Rem  ****** Contact rpang for review of changes to these views *****
Rem

create or replace view DBA_SQL_TRANSLATION_PROFILES
(OWNER, PROFILE_NAME, TRANSLATOR, FOREIGN_SQL_SYNTAX,
 TRANSLATE_NEW_SQL, RAISE_TRANSLATION_ERROR,
 LOG_TRANSLATION_ERROR, TRACE_TRANSLATION, LOG_ERRORS)
as
select u.name, o.name,
       case when (s.txlrowner is null and s.txlrname is null) then
         null
       else
         '"'||s.txlrowner||'"."'||s.txlrname||'"'
       end,
       decode(bitand(s.flags, 1), 1, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 2), 2, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 4), 4, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 8), 8, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 16), 16, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 32), 32, 'TRUE', 0, 'FALSE')
  from sys.sqltxl$ s, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
 where s.obj# = o.obj# and
       o.owner# = u.user#
/
comment on table DBA_SQL_TRANSLATION_PROFILES is
'Describes all SQL translation profiles in the database'
/
comment on column DBA_SQL_TRANSLATION_PROFILES.OWNER is
'Owner of the SQL translation profile'
/
comment on column DBA_SQL_TRANSLATION_PROFILES.PROFILE_NAME is
'Name of the SQL translation profile'
/
comment on column DBA_SQL_TRANSLATION_PROFILES.TRANSLATOR is
'The translator package'
/
comment on column DBA_SQL_TRANSLATION_PROFILES.FOREIGN_SQL_SYNTAX is
'Is the SQL syntax foreign?'
/
comment on column DBA_SQL_TRANSLATION_PROFILES.TRANSLATE_NEW_SQL is
'Translate new SQL statements and errors using the translator?'
/
comment on column DBA_SQL_TRANSLATION_PROFILES.RAISE_TRANSLATION_ERROR is
'Raise translation error?'
/
comment on column DBA_SQL_TRANSLATION_PROFILES.LOG_TRANSLATION_ERROR is
'Log translation error?'
/
comment on column DBA_SQL_TRANSLATION_PROFILES.TRACE_TRANSLATION is
'Trace translation?'
/
comment on column DBA_SQL_TRANSLATION_PROFILES.LOG_ERRORS is
'Log errors?'
/
create or replace public synonym DBA_SQL_TRANSLATION_PROFILES
for DBA_SQL_TRANSLATION_PROFILES
/
grant select on DBA_SQL_TRANSLATION_PROFILES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_SQL_TRANSLATION_PROFILES','CDB_SQL_TRANSLATION_PROFILES');
grant select on SYS.CDB_SQL_TRANSLATION_PROFILES to select_catalog_role
/
create or replace public synonym CDB_SQL_TRANSLATION_PROFILES for SYS.CDB_SQL_TRANSLATION_PROFILES
/

create or replace view DBA_SQL_TRANSLATIONS
(OWNER, PROFILE_NAME, SQL_TEXT, TRANSLATED_TEXT, SQL_ID, HASH_VALUE, ENABLED,
 REGISTRATION_TIME, CLIENT_INFO, MODULE, ACTION, PARSING_USER_ID,
 PARSING_SCHEMA_ID, COMMENTS, ERROR_CODE, ERROR_SOURCE, TRANSLATION_METHOD,
 DICTIONARY_SQL_ID)
as
select u.name, o.name, s.sqltext, s.txltext, s.sqlid, s.sqlhash,
       decode(bitand(s.flags, 1), 1, 'TRUE', 0, 'FALSE'),
       s.rtime, s.cinfo, s.module, s.action, s.puser#, s.pschema#, s.comment$,
       s.errcode#,
       decode(s.errsrc, 1, 'TRANSLATE', 2, 'PARSE', 3, 'EXECUTE'),
       decode(s.txlmthd, 1, 'TRANSLATOR', 2, 'DICTIONARY'),
       s.dictid
  from sys.sqltxl_sql$ s, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
 where s.obj# = o.obj# and
       o.owner# = u.user#
/
comment on table DBA_SQL_TRANSLATIONS is
'Describes all SQL translations in the database'
/
comment on column DBA_SQL_TRANSLATIONS.OWNER is
'Owner of the SQL translation profile'
/
comment on column DBA_SQL_TRANSLATIONS.PROFILE_NAME is
'Name of the SQL translation profile'
/
comment on column DBA_SQL_TRANSLATIONS.SQL_TEXT is
'The SQL text'
/
comment on column DBA_SQL_TRANSLATIONS.TRANSLATED_TEXT is
'The translated SQL text'
/
comment on column DBA_SQL_TRANSLATIONS.SQL_ID is
'SQL identifier of the SQL text'
/
comment on column DBA_SQL_TRANSLATIONS.HASH_VALUE is
'Hash value of the SQL text'
/
comment on column DBA_SQL_TRANSLATIONS.ENABLED is
'Is the translation enabled?'
/
comment on column DBA_SQL_TRANSLATIONS.REGISTRATION_TIME is
'Time the translation was registered'
/
comment on column DBA_SQL_TRANSLATIONS.CLIENT_INFO is
'Client information when the SQL was parsed and the translation was registered'
/
comment on column DBA_SQL_TRANSLATIONS.MODULE is
'Module when the SQL was parsed and the translation was registered'
/
comment on column DBA_SQL_TRANSLATIONS.ACTION is
'Action when the SQL was parsed and the translation was registered'
/
comment on column DBA_SQL_TRANSLATIONS.PARSING_USER_ID is
'Current user ID when the SQL was parsed and the translation was registered'
/
comment on column DBA_SQL_TRANSLATIONS.PARSING_SCHEMA_ID is
'Current schema ID when the SQL was parsed and the translation was registered'
/
comment on column DBA_SQL_TRANSLATIONS.COMMENTS is
'Comment on the translation'
/
comment on column DBA_SQL_TRANSLATIONS.ERROR_CODE is
'Last error code when the SQL was run'
/
comment on column DBA_SQL_TRANSLATIONS.ERROR_SOURCE is
'Source of the last error'
/
comment on column DBA_SQL_TRANSLATIONS.TRANSLATION_METHOD is
'Method used to translate the SQL during the last error'
/
comment on column DBA_SQL_TRANSLATIONS.DICTIONARY_SQL_ID is
'SQL identifier of the SQL text in translation dictionary used to translate the SQL during the last error'
/
create or replace public synonym DBA_SQL_TRANSLATIONS
for DBA_SQL_TRANSLATIONS
/
grant select on DBA_SQL_TRANSLATIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_SQL_TRANSLATIONS','CDB_SQL_TRANSLATIONS');
grant select on SYS.CDB_SQL_TRANSLATIONS to select_catalog_role
/
create or replace public synonym CDB_SQL_TRANSLATIONS for SYS.CDB_SQL_TRANSLATIONS
/

create or replace view DBA_ERROR_TRANSLATIONS
(OWNER, PROFILE_NAME, ERROR_CODE, TRANSLATED_CODE, TRANSLATED_SQLSTATE, ENABLED,
 REGISTRATION_TIME, COMMENTS)
as
select u.name, o.name, s.errcode#, s.txlcode#, s.txlsqlstate,
       decode(bitand(s.flags, 1), 1, 'TRUE', 0, 'FALSE'), s.rtime, s.comment$
  from sys.sqltxl_err$ s, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
 where s.obj# = o.obj# and
       o.owner# = u.user#
/
comment on table DBA_ERROR_TRANSLATIONS is
'Describes all error translations in the database'
/
comment on column DBA_ERROR_TRANSLATIONS.OWNER is
'Owner of the SQL translation profile'
/
comment on column DBA_ERROR_TRANSLATIONS.PROFILE_NAME is
'Name of the SQL translation profile'
/
comment on column DBA_ERROR_TRANSLATIONS.ERROR_CODE is
'The error code'
/
comment on column DBA_ERROR_TRANSLATIONS.TRANSLATED_CODE is
'The translated error code'
/
comment on column DBA_ERROR_TRANSLATIONS.TRANSLATED_SQLSTATE is
'The translated SQLSTATE'
/
comment on column DBA_ERROR_TRANSLATIONS.ENABLED is
'Is the translation enabled?'
/
comment on column DBA_ERROR_TRANSLATIONS.REGISTRATION_TIME is
'Time the translation was registered'
/
comment on column DBA_ERROR_TRANSLATIONS.COMMENTS is
'Comment on the translation'
/
create or replace public synonym DBA_ERROR_TRANSLATIONS
for DBA_ERROR_TRANSLATIONS
/
grant select on DBA_ERROR_TRANSLATIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_ERROR_TRANSLATIONS','CDB_ERROR_TRANSLATIONS');
grant select on SYS.CDB_ERROR_TRANSLATIONS to select_catalog_role
/
create or replace public synonym CDB_ERROR_TRANSLATIONS for SYS.CDB_ERROR_TRANSLATIONS
/

create or replace view USER_SQL_TRANSLATION_PROFILES
(PROFILE_NAME, TRANSLATOR, FOREIGN_SQL_SYNTAX,
 TRANSLATE_NEW_SQL, RAISE_TRANSLATION_ERROR,
 LOG_TRANSLATION_ERROR, TRACE_TRANSLATION, LOG_ERRORS)
as
select o.name,
       case when (s.txlrowner is null and s.txlrname is null) then
         null
       else
         '"'||s.txlrowner||'"."'||s.txlrname||'"'
       end,
       decode(bitand(s.flags, 1), 1, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 2), 2, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 4), 4, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 8), 8, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 16), 16, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 32), 32, 'TRUE', 0, 'FALSE')
  from sys.sqltxl$ s, sys."_CURRENT_EDITION_OBJ" o
 where s.obj# = o.obj# and
       o.owner# = userenv('SCHEMAID')
/
comment on table USER_SQL_TRANSLATION_PROFILES is
'Describes all SQL translation profiles owned by the user'
/
comment on column USER_SQL_TRANSLATION_PROFILES.PROFILE_NAME is
'Name of the SQL translation profile'
/
comment on column USER_SQL_TRANSLATION_PROFILES.TRANSLATOR is
'The translator package'
/
comment on column USER_SQL_TRANSLATION_PROFILES.FOREIGN_SQL_SYNTAX is
'Is the SQL syntax foreign?'
/
comment on column USER_SQL_TRANSLATION_PROFILES.TRANSLATE_NEW_SQL is
'Translate new SQL statements and errors using the translator?'
/
comment on column USER_SQL_TRANSLATION_PROFILES.RAISE_TRANSLATION_ERROR is
'Raise translation error?'
/
comment on column USER_SQL_TRANSLATION_PROFILES.LOG_TRANSLATION_ERROR is
'Log translation error?'
/
comment on column USER_SQL_TRANSLATION_PROFILES.TRACE_TRANSLATION is
'Trace translation?'
/
comment on column USER_SQL_TRANSLATION_PROFILES.LOG_ERRORS is
'Log errors?'
/
create or replace public synonym USER_SQL_TRANSLATION_PROFILES
for USER_SQL_TRANSLATION_PROFILES
/
grant read on USER_SQL_TRANSLATION_PROFILES to public with grant option
/

create or replace view USER_SQL_TRANSLATIONS
(PROFILE_NAME, SQL_TEXT, TRANSLATED_TEXT, SQL_ID, HASH_VALUE, ENABLED,
 REGISTRATION_TIME, CLIENT_INFO, MODULE, ACTION, PARSING_USER_ID,
 PARSING_SCHEMA_ID, COMMENTS, ERROR_CODE, ERROR_SOURCE, TRANSLATION_METHOD,
 DICTIONARY_SQL_ID)
as
select o.name, s.sqltext, s.txltext, s.sqlid, s.sqlhash,
       decode(bitand(s.flags, 1), 1, 'TRUE', 0, 'FALSE'),
       s.rtime, s.cinfo, s.module, s.action, s.puser#, s.pschema#, s.comment$,
       s.errcode#,
       decode(s.errsrc, 1, 'TRANSLATE', 2, 'PARSE', 3, 'EXECUTE'),
       decode(s.txlmthd, 1, 'TRANSLATOR', 2, 'DICTIONARY'),
       s.dictid
  from sys.sqltxl_sql$ s, sys."_CURRENT_EDITION_OBJ" o
 where s.obj# = o.obj# and
       o.owner# = userenv('SCHEMAID')
/
comment on table USER_SQL_TRANSLATIONS is
'Describes all SQL translations owned by the user'
/
comment on column USER_SQL_TRANSLATIONS.PROFILE_NAME is
'Name of the SQL translation profile'
/
comment on column USER_SQL_TRANSLATIONS.SQL_TEXT is
'The SQL text'
/
comment on column USER_SQL_TRANSLATIONS.TRANSLATED_TEXT is
'The translated SQL text'
/
comment on column USER_SQL_TRANSLATIONS.SQL_ID is
'SQL identifier of the SQL text'
/
comment on column USER_SQL_TRANSLATIONS.HASH_VALUE is
'Hash value of the SQL text'
/
comment on column USER_SQL_TRANSLATIONS.ENABLED is
'Is the translation enabled?'
/
comment on column USER_SQL_TRANSLATIONS.REGISTRATION_TIME is
'Time the translation was registered'
/
comment on column USER_SQL_TRANSLATIONS.CLIENT_INFO is
'Client information when the SQL was parsed and the translation was registered'
/
comment on column USER_SQL_TRANSLATIONS.MODULE is
'Module when the SQL was parsed and the translation was registered'
/
comment on column USER_SQL_TRANSLATIONS.ACTION is
'Action when the SQL was parsed and the translation was registered'
/
comment on column USER_SQL_TRANSLATIONS.PARSING_USER_ID is
'Current user ID when the SQL was parsed and the translation was registered'
/
comment on column USER_SQL_TRANSLATIONS.PARSING_SCHEMA_ID is
'Current schema ID when the SQL was parsed and the translation was registered'
/
comment on column USER_SQL_TRANSLATIONS.COMMENTS is
'Comment on the translation'
/
comment on column USER_SQL_TRANSLATIONS.ERROR_CODE is
'Last error code when the SQL was run'
/
comment on column USER_SQL_TRANSLATIONS.ERROR_SOURCE is
'Source of the last error'
/
comment on column USER_SQL_TRANSLATIONS.TRANSLATION_METHOD is
'Method used to translate the SQL during the last error'
/
comment on column USER_SQL_TRANSLATIONS.DICTIONARY_SQL_ID is
'SQL identifier of the SQL text in translation dictionary used to translate the SQL during the last error'
/
create or replace public synonym USER_SQL_TRANSLATIONS
for USER_SQL_TRANSLATIONS
/
grant read on USER_SQL_TRANSLATIONS to public with grant option
/

create or replace view USER_ERROR_TRANSLATIONS
(PROFILE_NAME, ERROR_CODE, TRANSLATED_CODE, TRANSLATED_SQLSTATE, ENABLED,
 REGISTRATION_TIME, COMMENTS)
as
select o.name, s.errcode#, s.txlcode#, s.txlsqlstate,
       decode(bitand(s.flags, 1), 1, 'TRUE', 0, 'FALSE'), s.rtime, s.comment$
  from sys.sqltxl_err$ s, sys."_CURRENT_EDITION_OBJ" o
 where s.obj# = o.obj# and
       o.owner# = userenv('SCHEMAID')
/
comment on table USER_ERROR_TRANSLATIONS is
'Describes all error translations owned by the user'
/
comment on column USER_ERROR_TRANSLATIONS.PROFILE_NAME is
'Name of the SQL translation profile'
/
comment on column USER_ERROR_TRANSLATIONS.ERROR_CODE is
'The error code'
/
comment on column USER_ERROR_TRANSLATIONS.TRANSLATED_CODE is
'The translated error code'
/
comment on column USER_ERROR_TRANSLATIONS.TRANSLATED_SQLSTATE is
'The translated SQLSTATE'
/
comment on column USER_ERROR_TRANSLATIONS.ENABLED is
'Is the translation enabled?'
/
comment on column USER_ERROR_TRANSLATIONS.REGISTRATION_TIME is
'Time the translation was registered'
/
comment on column USER_ERROR_TRANSLATIONS.COMMENTS is
'Comment on the translation'
/
create or replace public synonym USER_ERROR_TRANSLATIONS
for USER_ERROR_TRANSLATIONS
/
grant read on USER_ERROR_TRANSLATIONS to public with grant option
/

create or replace view ALL_SQL_TRANSLATION_PROFILES
(OWNER, PROFILE_NAME, TRANSLATOR, FOREIGN_SQL_SYNTAX,
 TRANSLATE_NEW_SQL, RAISE_TRANSLATION_ERROR,
 LOG_TRANSLATION_ERROR, TRACE_TRANSLATION, LOG_ERRORS)
as
select u.name, o.name,
       case when (s.txlrowner is null and s.txlrname is null) then
         null
       else
         '"'||s.txlrowner||'"."'||s.txlrname||'"'
       end,
       decode(bitand(s.flags, 1), 1, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 2), 2, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 4), 4, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 8), 8, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 16), 16, 'TRUE', 0, 'FALSE'),
       decode(bitand(s.flags, 32), 32, 'TRUE', 0, 'FALSE')
  from sys.sqltxl$ s, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
 where s.obj# = o.obj# and
       o.owner# = u.user# and
       (
         o.owner# = userenv('SCHEMAID')
         or
         exists (select null from sys.objauth$ oa
                  where oa.obj# = o.obj#
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# in (0 /* ALTER */, 29 /* USE */))
         or
         exists (select null from v$enabledprivs
                 where priv_number in (
                                -335 /* CREATE ANY SQL TRANSLATION PROFILE */,
                                -336 /* ALTER ANY SQL TRANSLATION PROFILE  */,
                                -337 /* USE ANY SQL TRANSLATION PROFILE    */,
                                -338 /* DROP ANY SQL TRANSLATION PROFILE   */
                                      )
                )
       )
/
comment on table ALL_SQL_TRANSLATION_PROFILES is
'Describes all SQL translation profiles accessible to the user'
/
comment on column ALL_SQL_TRANSLATION_PROFILES.OWNER is
'Owner of the SQL translation profile'
/
comment on column ALL_SQL_TRANSLATION_PROFILES.PROFILE_NAME is
'Name of the SQL translation profile'
/
comment on column ALL_SQL_TRANSLATION_PROFILES.TRANSLATOR is
'The translator package'
/
comment on column ALL_SQL_TRANSLATION_PROFILES.FOREIGN_SQL_SYNTAX is
'Is the SQL syntax foreign?'
/
comment on column ALL_SQL_TRANSLATION_PROFILES.TRANSLATE_NEW_SQL is
'Translate new SQL statements and errors using the translator?'
/
comment on column ALL_SQL_TRANSLATION_PROFILES.RAISE_TRANSLATION_ERROR is
'Raise translation error?'
/
comment on column ALL_SQL_TRANSLATION_PROFILES.LOG_TRANSLATION_ERROR is
'Log translation error?'
/
comment on column ALL_SQL_TRANSLATION_PROFILES.TRACE_TRANSLATION is
'Trace translation?'
/
comment on column ALL_SQL_TRANSLATION_PROFILES.LOG_ERRORS is
'Log errors?'
/
create or replace public synonym ALL_SQL_TRANSLATION_PROFILES
for ALL_SQL_TRANSLATION_PROFILES
/
grant read on ALL_SQL_TRANSLATION_PROFILES to public with grant option
/

create or replace view ALL_SQL_TRANSLATIONS
(OWNER, PROFILE_NAME, SQL_TEXT, TRANSLATED_TEXT, SQL_ID, HASH_VALUE, ENABLED,
 REGISTRATION_TIME, CLIENT_INFO, MODULE, ACTION, PARSING_USER_ID,
 PARSING_SCHEMA_ID, COMMENTS, ERROR_CODE, ERROR_SOURCE, TRANSLATION_METHOD,
 DICTIONARY_SQL_ID)
as
select u.name, o.name, s.sqltext, s.txltext, s.sqlid, s.sqlhash,
       decode(bitand(s.flags, 1), 1, 'TRUE', 0, 'FALSE'),
       s.rtime, s.cinfo, s.module, s.action, s.puser#, s.pschema#, s.comment$,
       s.errcode#,
       decode(s.errsrc, 1, 'TRANSLATE', 2, 'PARSE', 3, 'EXECUTE'),
       decode(s.txlmthd, 1, 'TRANSLATOR', 2, 'DICTIONARY'),
       s.dictid
  from sys.sqltxl_sql$ s, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
 where s.obj# = o.obj# and
       o.owner# = u.user# and
       (
         o.owner# = userenv('SCHEMAID')
         or
         exists (select null from sys.objauth$ oa
                  where oa.obj# = o.obj#
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# in (0 /* ALTER */, 29 /* USE */))
         or
         exists (select null from v$enabledprivs
                 where priv_number in (
                                -335 /* CREATE ANY SQL TRANSLATION PROFILE */,
                                -336 /* ALTER ANY SQL TRANSLATION PROFILE  */,
                                -337 /* USE ANY SQL TRANSLATION PROFILE    */,
                                -338 /* DROP ANY SQL TRANSLATION PROFILE   */
                                      )
                )
       )
/
comment on table ALL_SQL_TRANSLATIONS is
'Describes all SQL translations accessible to the user'
/
comment on column ALL_SQL_TRANSLATIONS.OWNER is
'Owner of the SQL translation profile'
/
comment on column ALL_SQL_TRANSLATIONS.PROFILE_NAME is
'Name of the SQL translation profile'
/
comment on column ALL_SQL_TRANSLATIONS.SQL_TEXT is
'The SQL text'
/
comment on column ALL_SQL_TRANSLATIONS.TRANSLATED_TEXT is
'The translated SQL text'
/
comment on column ALL_SQL_TRANSLATIONS.SQL_ID is
'SQL identifier of the SQL text'
/
comment on column ALL_SQL_TRANSLATIONS.HASH_VALUE is
'Hash value of the SQL text'
/
comment on column ALL_SQL_TRANSLATIONS.ENABLED is
'Is the translation enabled?'
/
comment on column ALL_SQL_TRANSLATIONS.REGISTRATION_TIME is
'Time the translation was registered'
/
comment on column ALL_SQL_TRANSLATIONS.CLIENT_INFO is
'Client information when the SQL was parsed and the translation was registered'
/
comment on column ALL_SQL_TRANSLATIONS.MODULE is
'Module when the SQL was parsed and the translation was registered'
/
comment on column ALL_SQL_TRANSLATIONS.ACTION is
'Action when the SQL was parsed and the translation was registered'
/
comment on column ALL_SQL_TRANSLATIONS.PARSING_USER_ID is
'Current user ID when the SQL was parsed and the translation was registered'
/
comment on column ALL_SQL_TRANSLATIONS.PARSING_SCHEMA_ID is
'Current schema ID when the SQL was parsed and the translation was registered'
/
comment on column ALL_SQL_TRANSLATIONS.COMMENTS is
'Comment on the translation'
/
comment on column ALL_SQL_TRANSLATIONS.ERROR_CODE is
'Last error code when the SQL was run'
/
comment on column ALL_SQL_TRANSLATIONS.ERROR_SOURCE is
'Source of the last error'
/
comment on column ALL_SQL_TRANSLATIONS.TRANSLATION_METHOD is
'Method used to translate the SQL during the last error'
/
comment on column ALL_SQL_TRANSLATIONS.DICTIONARY_SQL_ID is
'SQL identifier of the SQL text in translation dictionary used to translate the SQL during the last error'
/
create or replace public synonym ALL_SQL_TRANSLATIONS
for ALL_SQL_TRANSLATIONS
/
grant read on ALL_SQL_TRANSLATIONS to public with grant option
/

create or replace view ALL_ERROR_TRANSLATIONS
(OWNER, PROFILE_NAME, ERROR_CODE, TRANSLATED_CODE, TRANSLATED_SQLSTATE, ENABLED,
 REGISTRATION_TIME, COMMENTS)
as
select u.name, o.name, s.errcode#, s.txlcode#, s.txlsqlstate,
       decode(bitand(s.flags, 1), 1, 'TRUE', 0, 'FALSE'), s.rtime, s.comment$
  from sys.sqltxl_err$ s, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
 where s.obj# = o.obj# and
       o.owner# = u.user# and
       (
         o.owner# = userenv('SCHEMAID')
         or
         exists (select null from sys.objauth$ oa
                  where oa.obj# = o.obj#
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# in (0 /* ALTER */, 29 /* USE */))
         or
         exists (select null from v$enabledprivs
                 where priv_number in (
                                -335 /* CREATE ANY SQL TRANSLATION PROFILE */,
                                -336 /* ALTER ANY SQL TRANSLATION PROFILE  */,
                                -337 /* USE ANY SQL TRANSLATION PROFILE    */,
                                -338 /* DROP ANY SQL TRANSLATION PROFILE   */
                                      )
                )
       )
/
comment on table ALL_ERROR_TRANSLATIONS is
'Describes all error translations accessible to the user'
/
comment on column ALL_ERROR_TRANSLATIONS.OWNER is
'Owner of the SQL translation profile'
/
comment on column ALL_ERROR_TRANSLATIONS.PROFILE_NAME is
'Name of the SQL translation profile'
/
comment on column ALL_ERROR_TRANSLATIONS.ERROR_CODE is
'The error code'
/
comment on column ALL_ERROR_TRANSLATIONS.TRANSLATED_CODE is
'The translated error code'
/
comment on column ALL_ERROR_TRANSLATIONS.TRANSLATED_SQLSTATE is
'The translated SQLSTATE'
/
comment on column ALL_ERROR_TRANSLATIONS.ENABLED is
'Is the translation enabled?'
/
comment on column ALL_ERROR_TRANSLATIONS.REGISTRATION_TIME is
'Time the translation was registered'
/
comment on column ALL_ERROR_TRANSLATIONS.COMMENTS is
'Comment on the translation'
/
create or replace public synonym ALL_ERROR_TRANSLATIONS
for ALL_ERROR_TRANSLATIONS
/
grant read on ALL_ERROR_TRANSLATIONS to public with grant option
/

-- Bug 25512307: Add DICTIONARY_CREDENTIALS_ENCRYPT
create or replace view DICTIONARY_CREDENTIALS_ENCRYPT (ENFORCEMENT)
as
select case when count(*) > 0 then 'ENABLED' else 'DISABLED' end
  from sys.enc$ e, sys.obj$ o
  where e.obj#=o.obj# and o.name='LINK$' and o.owner#=0 and o.type#=2
/
comment on table DICTIONARY_CREDENTIALS_ENCRYPT is
'Describes whether encryption of dictionary credentials is enforced or not'
/
comment on column DICTIONARY_CREDENTIALS_ENCRYPT.ENFORCEMENT is
'Enforcement status for encryption of dictionary credentials'
/
create or replace public synonym DICTIONARY_CREDENTIALS_ENCRYPT
for DICTIONARY_CREDENTIALS_ENCRYPT
/
grant read on DICTIONARY_CREDENTIALS_ENCRYPT to public with grant option
/ 

@?/rdbms/admin/sqlsessend.sql
