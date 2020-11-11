Rem
Rem $Header: rdbms/admin/xdbuo121.sql /st_rdbms_18.0/1 2017/11/30 19:31:10 luisgarc Exp $
Rem
Rem xdbuo121.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbuo121.sql - XDB Upgrade RDBMS Objects from 12.1.0
Rem
Rem    DESCRIPTION
Rem      This script upgrades the base XDB objects from release 12.1.0
Rem      to the current release.
Rem
Rem    NOTES
Rem     It is invoked by xdbuo.sql, and invokes the xdbuoNNN script for the 
Rem     subsequent release.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbuo121.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbuo121.sql 
Rem    SQL_PHASE: UPGRADE 
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbuo.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    luisgarc    11/29/17 - Bug 26650540: Change casing in ALTER TYPE for
Rem                           XDB.XDB$RESOURCE_T
Rem    raeburns    04/15/17 - Bug Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    raeburns    01/12/17 - RTI 20037449: remove ALTER TYPE for
Rem                           XMLIndexMethods
Rem    qyu         11/10/16 - invoke xdbuo122.sql
Rem    dmelinge    08/01/16 - Remove sys.DBMS_XDB_HTTP_DIGEST
Rem    qyu         07/25/16 - add file metadata
Rem    prthiaga    06/25/16 - Bug 23625161: alter XDB.JSON$COLLECTION_METADATA
Rem    dmelinge    03/21/16 - AddSchemaLocMapping for XDB, bug 22916987
Rem    raeburns    02/29/16 - Bug 22820096: revert ALTER TYPE to default
Rem                           CASCADE
Rem    dmelinge    02/08/16 - Tighter grant for xdb, bug 22646079
Rem    dmelinge    12/17/15 - No User$ access for XDB, bug 22249624
Rem    raeburns    11/19/15 - add serveroutput and version query
Rem    luisgarc    07/15/15 - LRG15396352: Drop xdb.xdbhi_idx before altering
Rem                           xdb.xdb$resourc_t
Rem    joalvizo    06/22/15 - Bug 20517236: Drop unique constraint for XDB$TSETMAP 
Rem                           and XDB$TTSET
Rem    luisgarc    06/10/15 - LRG15396352: Adding upgrade steps for
Rem                           XDB$RESOURCE_T
Rem    prthiaga    05/19/15 - Bug 21116398: Enable upgrade for SODA APIs
Rem    prthiaga    05/19/15 - Bug 21079087: Create tables required for TTS 
Rem                           in 12.2
Rem    raeburns    10/27/14 - add xdb.xdb$tsetmap from transaction stirmizi_proj-47294
Rem    prthiaga    09/29/14 - Bug 19680796: Temporarily comment out SODA APIs
Rem    prthiaga    08/18/14 - Bug 19317646: PL/SQL Collection API
Rem    raeburns    05/14/14 - move xdb$ttset changes to xdbuo121.sql
Rem    srtata      04/08/14 - proj 47295: add DML callouts with OID in
Rem                           XMLIndexMethods
Rem    raeburns    04/13/14 - move 121 actions post reload
Rem    raeburns    03/07/14 - add patch 12.1.0.2 upgrade actions
Rem    huiz        01/21/14 - bug 18056347: mark types created via xml schema 
Rem                           registration as local 
Rem    prthiaga    12/18/13 - LRG 11071543 - Add read privilege for XDB
Rem                           tables & Fix up corrupted PDs    
Rem    raeburns    11/28/13 - include 12.1 upgrades from xdbpatch.sql
Rem    prthiaga    11/26/13 - Bug 17860485 - hard code new tokens from 
Rem                           12.1 in token table
Rem    tojhuan     10/08/13 - 17563549: patch XDB.XDB_RESOURCE_T if it is
Rem                           upgraded from 10.5 to 11 onwards incorrectly
Rem    raeburns    10/25/13 - XDB upgrade restructure
Rem    raeburns    10/25/13 - Created

Rem ================================================================
Rem BEGIN XDB RDBMS Object Upgrade from 12.1.0
Rem ================================================================

-- Display version, sharing, and oracle-maintianed information 
-- for XDB$RESOURCE_T type and XDB$RESOURCE table prior to upgrade 
select substr(object_name,1,20), substr(subobject_name,1,10), object_type, 
  sharing, oracle_maintained
from dba_objects where owner='XDB' and object_name like 'XDB$RESOURCE%'  
  and object_type in ('TABLE','TYPE') 
order by object_name, subobject_name, object_type;

-- BEGIN moved from xdbpatch.sql

-- 17563549: patch XDB.XDB_RESOURCE_T if it is upgraded from 10.5 to 11
-- and onwards incorrectly. We can detect such incorrect upgrade by finding    
-- if its attribute 'RCLIST' falls behind 'CHECKEDOUTBYID' and 'BASEVERSION'.  
-- See Bug 17472123 for details.

set serveroutput on
declare
  attr_no_RCL  number;
  attr_no_COBI number;
  attr_no_BV   number;
  found_XDBHI  number;
  patch_COBI   boolean;
  patch_BV     boolean;
  patch_XDBHI  boolean;

begin
  select attr_no into attr_no_RCL  from DBA_TYPE_ATTRS 
  where owner = 'XDB' and type_name = 'XDB$RESOURCE_T' and ATTR_NAME = 'RCLIST';

  select attr_no into attr_no_COBI from DBA_TYPE_ATTRS
  where owner = 'XDB' and type_name = 'XDB$RESOURCE_T' and ATTR_NAME = 'CHECKEDOUTBYID';

  select attr_no into attr_no_BV   from DBA_TYPE_ATTRS
  where owner = 'XDB' and type_name = 'XDB$RESOURCE_T' and ATTR_NAME = 'BASEVERSION';

  select count(*) into found_XDBHI from DBA_INDEXES
  where owner = 'XDB' and table_name = 'XDB$RESOURCE' and INDEX_NAME = 'XDBHI_IDX';

  patch_COBI   :=  (attr_no_RCL > attr_no_COBI);
  patch_BV     :=  (attr_no_RCL > attr_no_BV) OR (attr_no_COBI > attr_no_BV);
  patch_XDBHI  :=  (found_XDBHI > 0) AND (patch_COBI OR patch_BV);

  if (patch_COBI OR patch_BV OR patch_XDBHI) then
    dbms_output.put_line('Patching XDB.XDB$RESOURCE_T');
  else
    dbms_output.put_line('No need to patch XDB.XDB$RESOURCE_T');
    return;
  end if;

  if patch_XDBHI then
    dbms_output.put_line('  Dropping index      XDB.XDBHI_IDX on XDB.XDB_RESOURCE');
    execute immediate 'drop index XDB.XDBHI_IDX';
    -- will be re-created when catxdbr.sql is run by xdbload.sql
  end if;

  if patch_COBI then
    dbms_output.put_line('  Patching attribute  CHECKEDOUTBYID');
    execute immediate
      'alter type XDB.XDB$RESOURCE_T drop attribute CHECKEDOUTBYID cascade';
    execute immediate
      'alter type XDB.XDB$RESOURCE_T add attribute (CHECKEDOUTBYID RAW(16)) cascade';
  end if;

  if patch_BV then
    dbms_output.put_line('  Patching attribute  BASEVERSION');
    execute immediate
      'alter type XDB.XDB$RESOURCE_T drop attribute BASEVERSION cascade';
    execute immediate
      'alter type XDB.XDB$RESOURCE_T add attribute (BASEVERSION RAW(16)) cascade';
  end if;

end;
/
set serveroutput off


-- Hard code new tokens from 12.1 into the token table if possible
-- to make a upgraded 12.1.0.2 look same as fresh install 12.1.0.2

declare
   qnguid     varchar2(34);
   suf        varchar2(26);
begin
   -- Get the token suffix from the ttset table
   execute immediate
     'select toksuf from xdb.xdb$ttset where flags = 0' into suf;

   qnguid := 'XDB.' || dbms_assert.simple_sql_name('X$QN' || suf);

   -- START hard coded qnames for Linux->Solaris conflict avoidance
   execute immediate
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
          USING HEXTORAW('6D9F'), 'cache-size', HEXTORAW('00'), HEXTORAW('6DCA');
   execute immediate
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
          USING HEXTORAW('6D9F'), 'expiration-timeout', HEXTORAW('00'), HEXTORAW('78F3');
   execute immediate
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
          USING HEXTORAW('6D9F'), 'session-state-cache-param', HEXTORAW('00'), HEXTORAW('0F86');
   execute immediate
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
          USING HEXTORAW('6D9F'), 'white-list', HEXTORAW('00'), HEXTORAW('20F0');
   execute immediate
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
          USING HEXTORAW('6D9F'), 'white-list-pattern', HEXTORAW('00'), HEXTORAW('45B3');

  -- END hard coded qnames for Linux->Solaris conflict avoidance
  exception
    when others then
     -- raise no error if we cannot insert
    NULL;
end;
/

-- Bug 22646079: Pre 12.2 system and dba accounts had all permissions on
-- repository files, now only permissions needed.
--
-- Remove old "all" permissions from XDB tables 
revoke all on XDB.XDB$RESOURCE from dba;
revoke all on XDB.XDB$RESOURCE from system;
revoke all on XDB.XDB$H_INDEX from dba;
revoke all on XDB.XDB$H_INDEX from system;
revoke all on XDB.XDB$H_LINK from dba;
revoke all on XDB.XDB$H_LINK from system;
revoke all on XDB.XDB$D_LINK from dba;
revoke all on XDB.XDB$D_LINK from system;
revoke all on XDB.XDB$NLOCKS from dba;
revoke all on XDB.XDB$NLOCKS from system;
revoke all on XDB.XDB$CHECKOUTS from dba;
revoke all on XDB.XDB$CHECKOUTS from system;
revoke all on XDB.XDB$ACL from dba;
revoke all on XDB.XDB$ACL from system;
revoke all on XDB.XDB$CONFIG from dba;
revoke all on XDB.XDB$CONFIG from system;
revoke all on XDB.XDB$RESCONFIG from dba;
revoke all on XDB.XDB$RESCONFIG from system;
revoke all on XDB.XDB$CONFIG from xdbadmin;
--
-- Grant needed permissions to XDB tables 
grant select,insert,update,delete on XDB.XDB$RESOURCE to dba;
grant select,insert,update,delete on XDB.XDB$RESOURCE to system
        with grant option;
grant select,insert,update,delete on XDB.XDB$H_INDEX to dba;
grant select,insert,update,delete on XDB.XDB$H_INDEX to system
        with grant option;
grant select,insert,update,delete on XDB.XDB$H_LINK to dba;
grant select,insert,update,delete on XDB.XDB$H_LINK to system with grant option;
grant select,insert,update,delete on XDB.XDB$D_LINK to dba;
grant select,insert,update,delete on XDB.XDB$D_LINK to system with grant option;
grant select,insert,update,delete on XDB.XDB$NLOCKS to dba;
grant select,insert,update,delete on XDB.XDB$NLOCKS to system with grant option;
grant select,insert,update,delete on XDB.XDB$CHECKOUTS to dba;
grant select,insert,update,delete on XDB.XDB$CHECKOUTS to system
        with grant option;
grant select,insert,update,delete on XDB.XDB$ACL to dba;
grant select,insert,update,delete on XDB.XDB$ACL to system with grant option;
grant select,insert,update,delete on XDB.XDB$CONFIG to dba;
grant select,insert,update,delete on XDB.XDB$CONFIG to system with grant option;
grant select,insert,update,delete on XDB.XDB$RESCONFIG to dba;
grant select,insert,update,delete on XDB.XDB$RESCONFIG to system
        with grant option;
grant select,insert,update,delete on XDB.XDB$CONFIG to xdbadmin;
-- 
-- Do Revoke/Grant for more XDB tables (X$PT used for TTS and datapump).
declare
  suf  varchar2(26);
  stmt varchar2(2000);
  ptguid varchar2(34);
begin
  select toksuf into suf from xdb.xdb$ttset where flags = 0;

  ptguid := 'XDB.' || dbms_assert.simple_sql_name('X$PT' || suf);

  stmt := 'revoke all on ' || ptguid || ' from DBA';
  execute immediate stmt;
  stmt := 'grant select,insert,update,delete on ' || ptguid || ' to DBA';
  execute immediate stmt;
  stmt := 'revoke all on ' || ptguid || ' from SYSTEM';
  execute immediate stmt;
  stmt := 'grant select,insert,update,delete on ' || ptguid ||
           ' to SYSTEM WITH GRANT OPTION';
  execute immediate stmt;
end;       
/

-- Bug 22916987: 12.2 AddSchemaLocMapping needs dba_xml_schemas access
grant select on sys.dba_xml_schemas to xdb;

-- END moved from xdbpatch.sql

-- Call catsodaddl.sql to create tables/views required
-- for JSON PL/SQL Collection API

@@catsodaddl.sql

-- Bug 23625161: alter XDB.JSON$COLLECTION_METADATA
ALTER TABLE XDB.JSON$COLLECTION_METADATA MODIFY
 (OWNER default SYS_CONTEXT('USERENV','CURRENT_USER'),
  OBJECT_SCHEMA default SYS_CONTEXT('USERENV','CURRENT_SCHEMA'));

--bug 20517236,  since 12.2 we dont need unique constraint anymore
alter table xdb.xdb$ttset
    drop constraint xdb$ttset_uniq;


-- Project 47294:  Add XDB$TSETMAP
create table xdb.xdb$tsetmap(
         guid   raw(16) not null,
         type   number not null,
         obj#   number not null)
      segment creation immediate;
alter table xdb.xdb$tsetmap
    add constraint xdb$tsetmap_uniq1 unique (guid, type);
-- alter table xdb.xdb$tsetmap
--    add constraint xdb$tsetmap_uniq2 unique (obj#);

/************ Create XDB.XDB$IMPORT_QN_INFO table ***************/
/* This table will be used to populate the qnames from
 * the export side central token table on the import side.
 */
create table xdb.xdb$import_qn_info
(
  nmspcid      raw(8),
  localname    varchar2(2000),
  flags        raw(4),
  id           raw(8));

grant select,insert,update,delete on xdb.xdb$import_qn_info to public;

/************ Create XDB.XDB$IMPORT_NM_INFO table ***************/
/* This table will be used to populate the namespaces from
 * the export side central token table on the import side.
 */
create table xdb.xdb$import_nm_info
(
  nmspcuri     varchar(2000),
  id           raw(8));

grant select,insert,update,delete on xdb.xdb$import_nm_info to public;

/************ Create XDB.XDB$IMPORT_PT_INFO table ***************/
/* This table will be used to populate the path table from
 * the export side central token table on the import side.
 */
create table xdb.xdb$import_pt_info
(
  path         raw(2000),
  id           raw(8));

grant select,insert,update,delete on xdb.xdb$import_pt_info to public;


--project : Long ID for XDB
  --catxtbix.sql
declare
  attrsize number;
  exist    number;
begin
  select count(*) into exist from DBA_TABLES where table_name = 'XDB$XTAB'
  and owner = 'XDB';
  if exist = 1 then
    select CHAR_LENGTH into attrsize from ALL_TAB_COLUMNS where 
                       TABLE_NAME  ='XDB$XTAB' and 
                       OWNER       = 'XDB'     AND 
                       COLUMN_NAME = 'GROUPNAME';
    if(attrsize < ORA_MAX_NAME_LEN) then
      execute immediate
         'alter table XDB.XDB$XTAB modify 
                          GROUPNAME NVARCHAR2('||ORA_MAX_NAME_LEN||')';
    end if;

    select CHAR_LENGTH into attrsize from ALL_TAB_COLUMNS where 
                       TABLE_NAME  = 'XDB$XTABNMSP' and 
                       OWNER       = 'XDB'          AND 
                       COLUMN_NAME = 'GROUPNAME';
    if(attrsize < ORA_MAX_NAME_LEN) then
      execute immediate
        'alter table XDB.XDB$XTABNMSP modify 
                        GROUPNAME  NVARCHAR2('||ORA_MAX_NAME_LEN||')';
    end if;

    select CHAR_LENGTH into attrsize from ALL_TAB_COLUMNS where 
                       TABLE_NAME  = 'XDB$XTABNMSP' and 
                       OWNER       = 'XDB'          AND 
                       COLUMN_NAME = 'PREFIX';
    if(attrsize < ORA_MAX_NAME_LEN) then
      execute immediate
        'alter table XDB.XDB$XTABNMSP modify 
                            PREFIX  NVARCHAR2('||ORA_MAX_NAME_LEN||')';
    end if;

     select CHAR_LENGTH into attrsize from ALL_TAB_COLUMNS where 
                          TABLE_NAME  = 'XDB$XTABCOLS' and 
                          OWNER       = 'XDB' AND 
                          COLUMN_NAME = 'GROUPNAME' ;
    if (attrsize < ORA_MAX_NAME_LEN) then
        execute immediate 
               'alter table XDB.XDB$XTABCOLS modify 
                               GROUPNAME NVARCHAR2('||ORA_MAX_NAME_LEN||')';
    end if;
  end if;
end;
/

-- Project 46836: Modify xdb$resource.snapshot attr
set serveroutput on
declare
  len1 number;
begin
  select LENGTH into len1 from dba_type_attrs
    where owner = 'XDB' and TYPE_NAME = 'XDB$RESOURCE_T'
          and ATTR_NAME = 'SNAPSHOT';

  if (len1 < 8) then
    execute immediate 'drop index XDB.XDBHI_IDX';
    -- index will be recreated when catxdbr.sql is run by xdbload.sql
    execute immediate
       'alter type XDB.XDB$RESOURCE_T modify attribute SNAPSHOT RAW(8) cascade';
    dbms_output.put_line('altered resource_t snapshot attr and resource table');
  end if;
end;
/
set serveroutput off

-- Bug 22249624: Revoke select grant from xdb on sys.user$.
-- Ignore the following error:
-- -01927: Cannot REVOKE privileges you did not grant

BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT on sys.user$ from XDB';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1927 THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- Bug 24292116, backport of bug 22160989, created package dbms_xdb_http_digest.
-- It is not needed in 12.2 and beyond; drop it.
drop package sys.DBMS_XDB_HTTP_DIGEST;

Rem ================================================================
Rem END XDB RDBMS Object Upgrade from 12.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB RDBMS Object Upgrade from the next release
Rem ================================================================

@@xdbuo122.sql
