Rem $Header: rdbms/admin/xdbeo112.sql /main/24 2017/04/07 17:26:54 qyu Exp $
Rem
Rem xdbeo112.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbeo112.sql - Downgrade XDB objects to 11.2
Rem
Rem    DESCRIPTION
Rem      XDB objects unrelated to the repository should be downgraded here
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbeo112.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbeo112.sql 
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbdwgrd.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    qyu         01/06/17 - #25070346: drop synonym
Rem    qyu         07/25/16 - add file metadata
Rem    joalvizo    04/12/16 - RTI 19388120: Remove plsql block from drop table 
Rem                           xdb.xdb$dbfs_virtual_folder; 
Rem    raeburns    07/28/14 - drop DBMS_XDB_CONTENT
Rem    dmelinge    12/11/13 - Remove rootinfo view, bug 17761566
Rem    raeburns    11/04/13 - add 12.1 downgrade
Rem    prthiaga    07/09/13 - remove package xdb.dbms_clobutil
Rem    stirmizi    10/23/12 - remove xdbimport_tt_info
Rem    qyu         09/14/12 - #14629199: refer sys.session_roles
Rem    yinlu       08/27/12 - lrg 7215262
Rem    srirkris    07/15/12 - Drop types and synonyms
Rem    yinlu       06/29/12 - revoke priviledge of dbms_xdb_config
Rem    dmelinge    06/18/12 - drop dbms_xdb_config package, lrg 7026593
Rem    qyu         03/08/12 - bug 13474450
Rem    sipatel     10/05/11 - move xidx downgrade below acl idx creation script
Rem    sipatel     09/15/11 - drop dxptab(nbpendtabobj#, nberrtabobj#)
Rem    sipatel     09/05/11 - #(11883969) - drop xidx_part_tab and 
Rem                           dxptab(tablespace, table_attrs)
Rem    thbaby      09/08/11 - create indexes on xdb.xdb$acl
Rem    yinlu       08/05/11 - drop dbms_xlsb package
Rem    vhosur      08/18/11 - Remove dbfs virtual folder
Rem    juding      07/29/11 - bug 12622803: Created from split of xdbe112.sql
Rem


Rem ================================================================
Rem BEGIN XDB Object downgrade to 12.1.0
Rem ================================================================

@@xdbeo121.sql

Rem ================================================================
Rem END XDB Object downgrade to 12.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Object downgrade to 11.2.0
Rem ================================================================

-----------------------------------------------------------------------------
-- downgrade SXI to 11.2.0.1
-- set OID column to null for SXI table created for partitioned xmltype table
-----------------------------------------------------------------------------

alter session set events '19119 trace name context forever, level 0x20000000';

declare
  -- local SXI table created for partitioned xmltype table
  cursor XTAB_CUR_1 is
    select t.IDXOBJ# idx_id
         , t.XMLTABOBJ# idxtab_id
         , bu.NAME btab_user
         , bo.NAME btab_name
         , u.NAME xtab_user
         , o.NAME xtab_name
    from XDB.XDB$XTAB t
       , IND$ i, OBJ$ bo, USER$ bu
       , OBJ$ o, USER$ u
    where bitand(t.FLAGS, 16640) = 16640
    and t.IDXOBJ# = i.OBJ#
    and i.BO# = bo.OBJ#
    and bo.OWNER# = bu.USER#
    and t.XMLTABOBJ# = o.OBJ#
    and o.OWNER# = u.USER#;

  previous_version varchar2(30);
  stmt varchar2(2000);
begin
  select prv_version into previous_version
  from registry$
  where cid = 'XDB';

  /* If XDB was installed during a upgrade, previous_version will be NULL.
   * When that happens, get previous_version from CATPROC.
   */
  if previous_version is NULL
  then
    select prv_version into previous_version
    from registry$
    where cid = 'CATPROC';
  end if;

  if previous_version like '11.2.0.1%' then
    for XTAB_REC in XTAB_CUR_1
    loop
        -- set OID column nullable
        stmt :=
        'alter table '
        || dbms_assert.enquote_name(XTAB_REC.xtab_user, FALSE) || '.' 
        || dbms_assert.enquote_name(XTAB_REC.xtab_name, FALSE)
        || ' modify (OID null)';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;

        -- set OID column to null
        stmt :=
        'update '
        || dbms_assert.enquote_name(XTAB_REC.xtab_user, FALSE) || '.' 
        || dbms_assert.enquote_name(XTAB_REC.xtab_name, FALSE) || ' xt'
        || ' set OID = null';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
    end loop;
    commit;
  end if;
end;
/

alter session set events '19119 trace name context off';

-----------------------------------------------------------------------------
-- downgrade SXI to 11.2.0.2
-- set KEY column to null for SXI leaf table
-----------------------------------------------------------------------------

alter session set events '19119 trace name context forever, level 0x20000000';

declare
  -- SXI leaf table
  cursor XTAB_CUR_1 is
    select u.NAME xtab_user
         , o.NAME xtab_name
         , t.IDXOBJ# idx_id
         , t.XMLTABOBJ# idxtab_id
         , iu.NAME xidx_user
         , io.NAME xidx_name
         , decode(bitand(t.FLAGS, 16384), 16384, 'local', '') ptlcl
    from XDB.XDB$XTAB t, OBJ$ o, USER$ u
       , XDB.XDB$XTAB k, OBJ$ io, USER$ iu
    where 1=1
    and t.XMLTABOBJ# = o.OBJ#
    and o.OWNER# = u.USER#
    and t.XMLTABOBJ# = k.PTABOBJ# (+)
    and t.IDXOBJ# = io.OBJ#
    and io.OWNER# = iu.USER#
    group by u.NAME 
           , o.NAME
           , t.PTABOBJ#
           , t.IDXOBJ#
           , t.XMLTABOBJ#
           , iu.NAME
           , io.NAME
           , t.FLAGS
    having count(k.XMLTABOBJ#) = 0;

  previous_version varchar2(30);
  stmt varchar2(2000);

  idxnm varchar2(200);
  cstcnt integer;
begin
  select prv_version into previous_version
  from registry$
  where cid = 'XDB';

  /* If XDB was installed during a upgrade, previous_version will be NULL.
   * When that happens, get previous_version from CATPROC.
   */
  if previous_version is NULL
  then
    select prv_version into previous_version
    from registry$
    where cid = 'CATPROC';
  end if;

  if previous_version like '11.2.0.2%' then
    for XTAB_REC in XTAB_CUR_1
    loop
      idxnm := 'SYS' || XTAB_REC.idx_id || '_'
               || XTAB_REC.idxtab_id || '_KEY_IDX';

      -- KEY column is primary key?
      select count(*) into cstcnt
      from all_constraints
      where OWNER = XTAB_REC.xtab_user
      and CONSTRAINT_NAME = idxnm
      and CONSTRAINT_TYPE = 'P'
      and TABLE_NAME = XTAB_REC.xtab_name;

      if cstcnt > 0
      then
        -- drop primary key constraint on KEY column
        stmt :=
        'alter table '
        || dbms_assert.enquote_name(XTAB_REC.xtab_user, FALSE) || '.' 
        || dbms_assert.enquote_name(XTAB_REC.xtab_name, FALSE)
        || ' drop primary key drop index';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
      end if;

      -- set KEY column to null
      stmt :=
      'update '
      || dbms_assert.enquote_name(XTAB_REC.xtab_user, FALSE) || '.' 
      || dbms_assert.enquote_name(XTAB_REC.xtab_name, FALSE)
      || ' set KEY = null';
      -- dbms_output.put_line(stmt);
      execute immediate stmt;
    end loop;
    commit;
  end if;
end;
/

alter session set events '19119 trace name context off';

/* drop dbms_clobutil package */
drop public synonym dbms_clobutil;
drop package xdb.dbms_clobutil;

/* drop dbms_xlsb package */ 
revoke execute on xdb.dbms_xlsb from public;
drop public synonym dbms_xlsb;
drop package xdb.dbms_xlsb;

/* drop dbms_xlsb package */ 
revoke execute on xdb.dbms_xmlschema_lsb from public;
drop public synonym dbms_xmlschema_lsb;
drop package xdb.dbms_xmlschema_lsb;

drop public synonym DBMS_XMLSCHEMA_TABMDARR;

drop public synonym DBMS_XMLSCHEMA_TABMD;

drop type xdb.DBMS_XMLSCHEMA_TABMDARR force;

drop type xdb.DBMS_XMLSCHEMA_TABMD force;

drop public synonym DBMS_XMLSCHEMA_RESMDARR;

drop public synonym DBMS_XMLSCHEMA_RESMD;

drop type xdb.DBMS_XMLSCHEMA_RESMDARR force;

drop type xdb.DBMS_XMLSCHEMA_RESMD force;

/* drop dbms_xdb_config package, lrg 7026593 */ 
revoke execute on xdb.dbms_xdb_config from public;
drop public synonym dbms_xdb_config;  
drop package XDB.DBMS_XDB_CONFIG;

------------------------------
-- ACL TABLE OPERATIONS BEGIN
------------------------------
-- create indexes on xdb.xdb$acl

create or replace package xdb.xdb$acl_pkg_int
authid current_user is 
TYPE strlist IS TABLE OF VARCHAR2(4000);
function current_principals return strlist pipelined;
function special_acl(acl xmltype) return number deterministic;
end;
/

create or replace package body xdb.xdb$acl_pkg_int
is 
  function current_principals return strlist pipelined is 
    rolename VARCHAR2(4000);
  begin 
    pipe ROW('PUBLIC');
    pipe ROW(USER());
    for item IN (SELECT role from sys.session_roles) loop
      PIPE ROW(item.role);
    end loop;

    return;
  end;

  function special_acl(acl xmltype) return number deterministic is
    ret NUMBER := null;
  begin
    select 1 into ret 
    from dual 
    where existsNode(acl, '/acl/extends-from', 
        'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') = 1 or 
    existsNode(acl, '/acl/ace/invert', 
        'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') = 1;

    return ret;
  end;
end;
/

grant execute on xdb.xdb$acl_pkg_int to public;

-- create XML index on xdb$acl table and also the value index
declare
  cur integer;
  rc  integer;
begin
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(cur,
     'create index xdb.xdb$acl_xidx on xdb.xdb$acl(object_value) '||
     'indextype is xdb.xmlindex '||
     'parameters(''PATH TABLE XDBACL_PATH_TAB VALUE INDEX XDBACL_PATH_TAB_VALUE_IDX'') ',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
end;
/

-- create functional index on special_acl()
declare
  cur integer;
  rc  integer;
begin
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(cur,
     'create index xdb.xdb$acl_spidx on xdb.xdb$acl(xdb.xdb$acl_pkg_int.special_acl(object_value), object_id)',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
end;
/

------------------------------
-- ACL TABLE OPERATIONS END
------------------------------

-------------------------------------------------
-- TOKEN MANAGEMENT RELATED OPERATIONS BEGIN
-------------------------------------------------
DECLARE
  noexist_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT(noexist_ex, -942);
BEGIN
  EXECUTE IMMEDIATE 'drop table xdb.xdb$import_tt_info';
  EXCEPTION WHEN noexist_ex THEN NULL;
END;
/
-------------------------------------------------
-- TOKEN MANAGEMENT RELATED OPERATIONS END
-------------------------------------------------

-----------------------------------------------------------------------------
-- downgrade XMLIndex to 11.2
-- #(11883969) drop xidx_part_tab and  dxptab(tablespace, table_attrs)
-- drop dxptab(nbpendtabobj#, nberrtabobj#)
-----------------------------------------------------------------------------
DECLARE
  noexist_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT(noexist_ex, -942);
  invalididn_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalididn_ex, -904);
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'drop table xdb.xdb$xidx_part_tab';
    EXCEPTION WHEN noexist_ex THEN NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'alter table xdb.xdb$dxptab drop column tablespace';
    EXCEPTION WHEN invalididn_ex THEN NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'alter table xdb.xdb$dxptab drop column table_attrs';
    EXCEPTION WHEN invalididn_ex THEN NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'alter table xdb.xdb$dxptab drop column nbpendtabobj#';
    EXCEPTION WHEN invalididn_ex THEN NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'alter table xdb.xdb$dxptab drop column nberrtabobj#';
    EXCEPTION WHEN invalididn_ex THEN NULL;
  END;
END;
/
----------------------------------
-- XMLIndex downgrade to 11.2 end
----------------------------------

-- dbms_xdb.deleteresource is now in xdbed112.sql to avoid upgrade issues
drop table xdb.xdb$dbfs_virtual_folder;  
commit;

-------------------------------------------------
-- REMOVE ROOT_INFO VIEW BEGIN
-------------------------------------------------
DECLARE
  noexist_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT(noexist_ex, -942);
BEGIN
  -- Note: package dbms_xdb in prvtxdb has a dependency on this view;
  -- package becomes invalid after this.
  EXECUTE IMMEDIATE 'drop view xdb.xdb$root_info_v';
  EXCEPTION WHEN noexist_ex THEN NULL;
END;
/
-------------------------------------------------
-- REMOVE ROOT_INFO VIEW END
-------------------------------------------------

-- Drop package loaded by prvtxsfsclient.plb
-- A new package in 12.1, it is invalid after a downgrade to 11.1
drop package XDB.DBMS_XDB_CONTENT;
drop public synonym DBMS_XDB_CONTENT;

Rem ================================================================
Rem END XDB Object downgrade to 11.2.0
Rem ================================================================

