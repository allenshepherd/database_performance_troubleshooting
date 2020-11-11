Rem
Rem $Header: rdbms/admin/xdbeo121.sql /main/24 2017/04/04 09:12:44 raeburns Exp $
Rem
Rem xdbeo121.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbeo121.sql - XDB RDBMS Object downgrade to 12.1
Rem
Rem    DESCRIPTION
Rem      This script downgrades the XDB base RDBMS objects from 12.2 to 12.1
Rem
Rem    NOTES
Rem     The script is invoked from xdbe121.sql and from xdbeo112.sql
Rem     of the prior release.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbeo121.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbeo121.sql 
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbdwgrd.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    qyu         01/06/17 - Lrg 19027374: correct version check for soda
Rem    qyu         11/10/16 - invoke xdbeo122.sql
Rem    yinlu       09/08/16 - bug 24617129: drop dbms_json_lib
Rem    qyu         07/25/16 - add file metadata
Rem    dmelinge    06/15/16 - Drop new internal fcn, rti 19540150
Rem    yinlu       06/09/16 - bug 23548844: drop function dg$getDgQuoteName
Rem    joalvizo    03/28/16 - add ALTER TABLE statements for xdb$root_info
Rem    sriksure    03/14/16 - Lrg 19342611 - Adding the missing ';'
Rem    yinlu       03/09/16 - change all|user|dba_json_dataguide to
Rem                           all|user|dba_json_dataguides
Rem    sriksure    02/19/16 - Bug 16299881 - Drop sys.dbms_xdb_util package
Rem    dmelinge    02/08/16 - Tighter grant for xdb, bug 22646079
Rem    yinlu       01/19/16 - bug 22559941: drop dataguide agg functions
Rem    dmelinge    12/17/15 - No User$ access for XDB, bug 22249624
Rem    prthiaga    10/23/15 - Bug 22067651: DROP DBMS_SODA_DOM
Rem    yinlu       10/07/15 - drop dba/all/user_json_dataguide view
Rem    prthiaga    07/20/15 - Bug 21473696: Drop xdb.dbms_clobutil
Rem    prthiaga    05/19/15 - Bug 21116398: Drop SODA stuff only if empty
Rem    prthiaga    05/19/15 - Bug 21079087: Drop tables created for TTS
Rem    yinlu       01/07/15 - drop dbms_json package
Rem    raeburns    10/27/14 - truncate xdb$tsetmap from transaction stirmizi_proj-47294
Rem    prthiaga    09/16/14 - Bug 19317646: Drop Collection API tables
Rem    raeburns    03/07/14 - add patch 12.1.0.2 downgrade actions
Rem    raeburns    11/04/13 - XDB 12.1 downgrade
Rem    raeburns    11/04/13 - Created
Rem

Rem ================================================================
Rem BEGIN XDB Object downgrade to 12.2.0
Rem ================================================================

@@xdbeo122.sql

Rem ================================================================
Rem END XDB Object downgrade to 12.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Object downgrade to 12.1.0
Rem ================================================================

Rem Remote ports not stored in xdbconfig, but they are in root_info.

DECLARE
  noexist_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT(noexist_ex, -904);
BEGIN
  EXECUTE IMMEDIATE 'alter table xdb.xdb$root_info drop column rhttps_port';
  EXECUTE IMMEDIATE 'alter table xdb.xdb$root_info drop column rhttps_protocol';
  EXECUTE IMMEDIATE 'alter table xdb.xdb$root_info drop column rhttps_host';
  EXECUTE IMMEDIATE 'alter table xdb.xdb$root_info drop column rhttp_port';
  EXECUTE IMMEDIATE 'alter table xdb.xdb$root_info drop column rhttp_protocol';
  EXECUTE IMMEDIATE 'alter table xdb.xdb$root_info drop column rhttp_host';

  EXECUTE IMMEDIATE 'drop view xdb.xdb$root_info_v';

  EXCEPTION WHEN noexist_ex THEN NULL;
END;
/
show errors;

Rem
Rem Remove any realm definition in sys.props$ 
begin
  execute immediate 'DELETE from sys.props$ WHERE name = ''HTTP_REALM'' ';
  execute immediate 'DROP view sys.xdb_realm_view ';
  COMMIT;
  exception
    when others then
      null;
end;
/

drop public synonym dbms_csx_int2;

drop package xdb.dbms_csx_int2;


Rem
Rem Drop Collection API tables/views/packages
Rem

DECLARE
  previous_version varchar2(30);
  is_soda_used     number := 0;
BEGIN
  select substr(prv_version, 1, 8)
  into   previous_version
  from   registry$
  where  cid = 'XDB';

  select count(*) 
  into   is_soda_used
  from   XDB.JSON$COLLECTION_METADATA;

--
-- If we are downgrading to lower than 12.1.0.2 OR
-- we are downgrading to 12.1.0.2 and SODA has never been
-- used then we are okay to drop all SODA tables/views/packages
--
  if ((previous_version < '12.1.0.2' ) OR
      (previous_version = '12.1.0.2' AND is_soda_used = 0)) then
    execute immediate 'drop public synonym DBMS_SODA_ADMIN';
    execute immediate 'drop public synonym USER_SODA_COLLECTIONS';
    execute immediate 'drop package XDB.DBMS_SODA_ADMIN';
    execute immediate 'drop package SYS.DBMS_SODA_UTIL';
    execute immediate 'drop package XDB.DBMS_SODA_DML';
    execute immediate 'drop view XDB.JSON$COLLECTION_METADATA_V';
    execute immediate 'drop view XDB.JSON$USER_COLLECTION_METADATA';
    execute immediate 'drop table XDB.JSON$COLLECTION_METADATA';
    execute immediate 'drop role SODA_APP';
  end if;
END;
/

-- Project 47294
truncate table xdb.xdb$tsetmap;

-- Remove tables created for XDB TTS

begin
  execute immediate 'drop table XDB.XDB$IMPORT_QN_INFO';
  execute immediate 'drop table XDB.XDB$IMPORT_NM_INFO';
  execute immediate 'drop table XDB.XDB$IMPORT_PT_INFO';
exception
  when others then
    null;
end;
/

-- Bug 22249624: Pre 12.2 XDB account needs SYS.User$ Select access again.  
GRANT SELECT ON user$ TO xdb;

-- Bug 22646079: Pre 12.2 dba and system accounts had all permissions on
-- repository files.
grant all on XDB.XDB$RESOURCE to dba;
grant all on XDB.XDB$RESOURCE to system with grant option;
grant all on XDB.XDB$H_INDEX to dba;
grant all on XDB.XDB$H_INDEX to system with grant option;
grant all on XDB.XDB$H_LINK to dba;
grant all on XDB.XDB$H_LINK to system with grant option;
grant all on XDB.XDB$D_LINK to dba;
grant all on XDB.XDB$D_LINK to system with grant option;
grant all on XDB.XDB$NLOCKS to dba;
grant all on XDB.XDB$NLOCKS to system with grant option;
grant all on XDB.XDB$CHECKOUTS to dba;
grant all on XDB.XDB$CHECKOUTS to system with grant option;
grant all on XDB.XDB$ACL to dba;
grant all on XDB.XDB$ACL to system with grant option;
grant all on XDB.XDB$CONFIG to dba;
grant all on XDB.XDB$CONFIG to system with grant option;
grant all on XDB.XDB$RESCONFIG to dba;
grant all on XDB.XDB$RESCONFIG to system with grant option;
grant all on XDB.XDB$CONFIG to xdbadmin;

-- Bug 22646079: Pre 12.2 dba and system accounts had all permissions on
-- repository files.  (X$PT used for TTS and datapump).
declare
  suf  varchar2(26);
  stmt varchar2(2000);
  ptguid varchar2(34);
begin
  select toksuf into suf from xdb.xdb$ttset where flags = 0;

  ptguid := 'XDB.' || dbms_assert.simple_sql_name('X$PT' || suf);

  stmt := 'grant all on ' || ptguid || ' to DBA';
  execute immediate stmt;
  stmt := 'grant all on ' || ptguid || ' to SYSTEM WITH GRANT OPTION';
  execute immediate stmt;
end;       
/

-- Project 47322: drop dataguide views and dbms_json package
drop public synonym ALL_JSON_DATAGUIDES;
drop public synonym USER_JSON_DATAGUIDES;
drop public synonym CDB_JSON_DATAGUIDES;
drop public synonym DBA_JSON_DATAGUIDES;
drop view ALL_JSON_DATAGUIDES;
drop view USER_JSON_DATAGUIDES;
drop view CDB_JSON_DATAGUIDES;
drop view DBA_JSON_DATAGUIDES;
drop view INT$DBA_JSON_DATAGUIDES;
drop function dg$hasDGIndex;
drop function dg$getDgQuoteName;

drop public synonym dbms_json;
drop package sys.dbms_json0;
drop package xdb.dbms_json_int;
drop package xdb.dbms_json;

-- bug 22559941: drop dataguide aggregate functions
drop public synonym JSON_DATAGUIDE;
drop public synonym JSON_HIERDATAGUIDE;
drop public synonym KCISYS_CTXAGG;
drop function JSON_DATAGUIDE;
drop function JSON_HIERDATAGUIDE;
drop function KCISYS_CTXAGG;
drop type JsonDgImp;
drop type JsonHDgImp;
drop type CtxAggimp;
drop library JSON_LIB;
drop library kci_ctxagg_lib;

-- bug 24617129, drop xdb.DBMS_JSON_LIB
drop library xdb.DBMS_JSON_LIB;

-- Drop xdb.dbms_clobutil
drop public synonym dbms_clobutil;
drop package xdb.dbms_clobutil;

-- Drop xdb.dbms_soda_dom 
drop public synonym DBMS_SODA_DOM;
drop package XDB.DBMS_SODA_DOM;

-- Drop sys.dbms_xdb_util
drop package sys.dbms_xdb_util;

-- rti 19540150, drop new function isxmltypetable_internal
drop function isXmlTypeTable_internal;


Rem ================================================================
Rem END XDB Object downgrade to 12.1.0
Rem ================================================================
