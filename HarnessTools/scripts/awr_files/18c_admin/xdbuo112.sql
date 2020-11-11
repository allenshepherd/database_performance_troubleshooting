Rem
Rem $Header: rdbms/admin/xdbuo112.sql /main/5 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbuo112.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbuo112.sql - XDB Upgrade RDBMS Objects from release 11.2.0
Rem
Rem    DESCRIPTION
Rem     This script upgrades the base XDB objects from release 11.2.0
Rem     to the current release.  Content formerly in xdbs112.sql and xdbu112.sql
Rem     No actions that would cause XDB bootstrap processing should be included.
Rem     Only actions that are required for schema upgrades or for packages and views
Rem     compilations should be included in this script.
Rem
Rem    NOTES
Rem     It is invoked by xdbuo.sql, and invokes the xdbuoNNN script for the 
Rem     subsequent release.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbuo112.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbuo112.sql 
Rem    SQL_PHASE: UPGRADE 
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbuo.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         07/25/16 - add file metadata
Rem    raeburns    02/29/16 - Bug 22820096: revert ALTER TYPE to default
Rem                           CASCADE
Rem    qyu         09/29/15 - #21861687:check user before revoking priv
Rem    raeburns    10/25/13 - XDB upgrade restructure
Rem    stirmizi    10/23/12 - add xdb.xdb$import_tt_info for token table merge
Rem    bhammers    04/15/12 - bug 13647232, remove dupliucates in TTSET 
Rem    stirmizi    04/11/12 - drop table xdb$workspace
Rem    aamirish    01/05/12 - Bug 12843902: Grant EXECUTE to XDB on
Rem                           User-defined Types that are  used in the
Rem                           predicate returned by XDB VPD Policy Functions.
Rem    bhammers    10/12/11 - undo  catxdbvfexp
Rem    thbaby      10/13/11 - drop procedure sys.set_tablespace
Rem    sipatel     10/15/11 - #(11883969) - IAS for xidx_part_tab
Rem    thbaby      10/14/11 - cache for xmllob
Rem    sipatel     09/15/11 - add dxptab(nbpendtabobj#, nberrtabobj#)
Rem    sipatel     09/05/11 - #(11883969) - add xidx_part_tab and
Rem                           dxptab(tablespace, table_attrs)
Rem    thbaby      09/08/11 - drop indexes on acl table
Rem    vhosur      07/19/11 - Create the dbfs virtual folder
Rem    jheng       06/26/11 - grant to xdb

Rem ================================================================
Rem BEGIN XDB RDBMS Object Upgrade from 11.2.0
Rem ================================================================

-- BEGIN MOVED FROM XDBDBMIG

-- Grant INHERIT ANY PRIVILEGES to XDB to inherit privileges of callers of
-- its invoker rights routines.
-- moved from xdbdbmig.sql

grant inherit any privileges to xdb;
grant inherit privileges on user sys to xdb;

-- Grant execute on DBMS_PDB_EXEC_SQL to XDB.  This privilege is necessary for
-- CDB to work properly (bug 13425408)
grant execute on dbms_pdb_exec_sql to xdb;

-- Revoke the default grant of INHERIT PRIVILEGES on XDB and ANONYMOUS
-- from public.

declare
  already_revoked exception;
  pragma exception_init(already_revoked,-01927);

  procedure revoke_inherit_privileges(user in varchar2) as
  sql_stmt   varchar2(4000);
  usr_exists number := 0;
  begin
   
    sql_stmt := 'select 1 from user$ where name = upper(:1)';
    execute immediate sql_stmt into usr_exists using user;

    if (usr_exists = 1) then 
      execute immediate 'revoke inherit privileges on user '||
                        dbms_assert.enquote_name(user)||' from public';
    end if;
  exception
    when already_revoked then null;
  end;

begin
  revoke_inherit_privileges('xdb');
  revoke_inherit_privileges('anonymous');
end;
/

-- Drop the xdbhi_idx index This will get recreated later in the upgrade
-- moved from xdbdbmig.sql

declare
 ct number;
begin
  select count(*) into ct from dba_indexes where owner = 'XDB' and 
    index_name = 'XDBHI_IDX';
    if ct > 0 then
      dbms_output.put_line('dissociating statistics');
      execute immediate 'disassociate statistics from ' ||
                        'indextypes xdb.xdbhi_idxtyp force';
      execute immediate 'disassociate statistics from ' ||
                        'packages xdb.xdb_funcimpl force';
      execute immediate 'drop index xdb.xdbhi_idx';
    end if;
end;
/

-- END MOVED FROM XDBDBMIG

-- BEGIN MOVED FROM xdbs112.sql

-- utility functions may not have been dropped during prior upgrade from 11.1
-- drop them here
@@xdbuud2

-- Long Identifier: change attribute types from varchar2(30) to varchar2(128)

alter type XDB.XDB$SIMPLE_T
        modify attribute sqltype varchar2(128) cascade;
alter type XDB.XDB$COMPLEX_T
        modify attribute(sqltype varchar2(128), sqlschema varchar2(128)) 
        cascade;
alter type XDB.XDB$PROPERTY_T
        modify attribute(sqlname varchar2(128), sqltype varchar2(128), 
        sqlschema varchar2(128),
        sqlcolltype varchar2(128), sqlcollschema varchar2(128)) 
        cascade;
alter type XDB.XDB$ELEMENT_T
        modify attribute(default_table varchar2(128), 
        default_table_schema varchar2(128)) 
        cascade;
alter type XDB.XDB$SCHEMA_T
        modify attribute(schema_owner varchar2(128)) cascade;

create table xdb.xdb$cdbports (
         pdb         number,
         service     number,
         port        number);

-- END MOVED from xdbs112.sql

-- BEGIN MOVED FROM xdbu112.sql


/* Grant EXECUTE to XDB on User-defined Types that are used in the predicate 
 * returned by XDB VPD Policy Functions.
 */
DECLARE   
  stmt          CLOB;
  TYPE          refcurs IS REF CURSOR;
  curs          refcurs;
  type_name     VARCHAR2(128);
  schema_name   VARCHAR2(128);
  sqltxt        VARCHAR2(300);
BEGIN
  stmt := 'select distinct po.name, u.name from' ||
          ' dependency$ dep, dba_xml_schemas x, obj$ do, obj$ po, user$ u' ||
          ' where do.obj#=dep.d_obj# and po.obj#=dep.p_obj# and do.type#=55' ||
          ' and do.name=x.int_objname and po.type#=13 and po.owner#=u.user#';
  OPEN curs FOR stmt;
  LOOP
    FETCH curs INTO type_name,schema_name;
    EXIT WHEN curs%NOTFOUND;
      sqltxt := 'grant execute on ' || 
                 dbms_assert.enquote_name(schema_name, FALSE) || '.' || 
                 dbms_assert.enquote_name(type_name, FALSE) || ' to xdb';
      EXECUTE IMMEDIATE sqltxt;
  END LOOP;
END;
/

grant execute on dbms_priv_capture to xdb;

-- Drop table xdb.servlet 
begin
  execute immediate 'drop table xdb.servlet';
  commit;
  exception
     when others then
          null;
end;
/

Rem ===============
Rem alter xdb.xdb$resource to enable the CACHE option on XMLLOB
Rem This is done to avoid poor performance of repository read
Rem operations in MTS (Shared Server) mode. See bug 13083410 
Rem for details.
Rem ===============
alter table xdb.xdb$resource modify lob (xmldata.xmllob) (cache);

Rem ======= Remove xdb.xdb$workspace ===============================

declare
  exist number;
begin
  select count(*) into exist from DBA_TABLES where table_name = 'XDB$WORKSPACE'
  and owner = 'XDB';

  if exist = 1 then
    execute immediate
        'drop table xdb.xdb$workspace';
  end if;
end;
/

----------------------------------------------------------------------------
-- during upgrade from 11.2.0.x, drop procedure sys.set_tablespace
-- since movexdb_tablespace does not rely on sys.set_tablespace
-- in 12cR1
-- 
begin
  execute immediate 'drop procedure sys.set_tablespace';
  exception
     when others then
        if (SQLCODE != -4043) then
          raise;
        end if;
end;
/

-----------------------------------------------------------------------------
-- upgrade XMLIndex from 11.2
-- #(11883969) add xidx_part_tab and  dxptab(tablespace, table_attrs)
-- add dxptab(nbpendtabobj#, nberrtabobj#)
-----------------------------------------------------------------------------
DECLARE
  exist_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT(exist_ex, -955);
  colexist_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT(colexist_ex, -1430);
  keyexist_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT(keyexist_ex, -1);
BEGIN
  BEGIN
    EXECUTE IMMEDIATE
      'create table xdb.xdb$xidx_part_tab(
         idxobj#         number not null,       -- object # of XMLIndex
         part_name       varchar2(128) not null,-- partition name 
         tablespace      varchar2(128),         -- partition tablespace 
         partition_attrs varchar2(4000),        -- partition physical attributes 
           constraint xdb$xidx_part_tab_pk primary key (idxobj#, part_name))';
    EXCEPTION WHEN exist_ex THEN NULL;
  END;

  -- insert index obj# and partition name into xidx_part_tab.
  -- tablespace==null => user did not specify any tablespace.
  BEGIN
    EXECUTE IMMEDIATE
      'insert into xdb.xdb$xidx_part_tab(idxobj#, part_name)
          select dxptab.idxobj# as idxobj#, o.subname as part_name
          from xdb.xdb$dxptab dxptab, sys.indpart$ ip, sys.obj$ o
          where dxptab.idxobj#=ip.BO# and ip.obj#=o.obj#';
      commit;
    EXCEPTION WHEN keyexist_ex THEN NULL;
  END;

  BEGIN
    EXECUTE IMMEDIATE 'alter table xdb.xdb$dxptab add (tablespace varchar2(128))';
    EXCEPTION WHEN colexist_ex THEN NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'alter table xdb.xdb$dxptab add (table_attrs varchar2(4000))';
    EXCEPTION WHEN colexist_ex THEN NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'alter table xdb.xdb$dxptab add (nbpendtabobj# number)';
    EXCEPTION WHEN colexist_ex THEN NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'alter table xdb.xdb$dxptab add (nberrtabobj# number)';
    EXCEPTION WHEN colexist_ex THEN NULL;
  END;
END;
/

Rem create dbfs_virtual_folder table if it does not exist
declare
 exist number;
begin
  select count(*) into exist from DBA_TABLES where table_name ='XDB$DBFS_VIRTUAL_FOLDER'
  and owner ='XDB';
 
  if exist = 0 then
   execute immediate 'CREATE TABLE XDB.XDB$DBFS_VIRTUAL_FOLDER (
   hidden_def         NUMBER default 1,
   mount_path         VARCHAR2(4000) NOT NULL,
   CONSTRAINT snglerow UNIQUE  (hidden_def))';
  end if;
end;
/   
SHOW ERRORS;

Rem ================================================================
Rem Remove Views and callout registries for XDB datapump export/import
Rem ================================================================

-- remove registered callouts 
declare
  stmt varchar2(10000);
begin
  begin
    stmt := 
       'delete from sys.impcalloutreg$ where tag = ''XDB_REPOSITORY''';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
  begin
    stmt := 'delete from sys.exppkgact$ where package = ''' || 
            'DBMS_XDBUTIL_INT' || ''' and schema=''' || 'XDB' || ''' ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
end;
/


-- remove views. tables, public synonyms, function
declare
  stmt varchar2(10000);
begin
  begin
    stmt := 
       'drop table SYS.XML_TABNAME2OID_VIEW_TBL';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
  begin
    stmt := 
       'drop public synonym XML_TABNAME2OID_VIEW';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view SYS.XML_TABNAME2OID_VIEW ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table XDB.XDB$RESOURCE_EXPORT_VIEW_TBL ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
  begin
    stmt := 
       'drop view XDB.XDB$RESOURCE_EXPORT_VIEW';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table DBA_XML_SCHEMA_DEPENDENCY_TBL';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table DBA_TYPE_XMLSCHEMA_DEP_TBL ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
  begin
    stmt := 
       'drop public synonym DBA_TYPE_XMLSCHEMA_DEP';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view DBA_TYPE_XMLSCHEMA_DEP';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$attrgroup_ref_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$attrgroup_ref_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$attrgroup_def_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$attrgroup_def_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$anyattr_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$anyattr_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$any_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$any_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$element_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$element_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$attribute_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$attribute_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$group_ref_view_tbl ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$group_ref_view ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$group_def_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$group_def_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$sequence_model_view_tbl ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
   begin
    stmt := 
       'drop view xdb.xdb$sequence_model_view ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;


  begin
    stmt := 
       'drop table xdb.xdb$choice_model_view_tbl ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
   begin
    stmt := 
       'drop  view xdb.xdb$choice_model_view ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop  table xdb.xdb$all_model_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
   begin
    stmt := 
       'drop view xdb.xdb$all_model_view ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$complex_type_view_tbl ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
   begin
    stmt := 
       'drop view xdb.xdb$complex_type_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$simple_type_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
   begin
    stmt := 
       'drop view xdb.xdb$simple_type_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table XDB.XDB$SCHEMA_EXPORT_VIEW_TBL';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
   begin
    stmt := 
       'drop view XDB.XDB$SCHEMA_EXPORT_VIEW';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

   begin
    stmt := 
       'drop function getUserIdOnTarget';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
end;
/


--bug 13647232, remove duplicate rows (remove all but default toksuf ( flags== 0))
begin
 execute immediate 
 'delete from xdb.xdb$ttset where FLAGS != 0 AND TOKSUF in (select TOKSUF from xdb.xdb$ttset where FLAGS = 0)';
    exception
       when others then
         NULL;
end;
/

--bug 13647232,  add unique constraint
begin
   execute immediate 
        'alter table xdb.xdb$ttset
         add constraint xdb$ttset_uniq unique (toksuf)';
    exception
       when others then
         NULL;
end;
/

/*************** Create XDB.XDB$IMPORT_TT_INFO table *****************/
begin
   execute immediate
      'create table xdb.xdb$import_tt_info( 
          guid     raw(16), 
          nmspcid      raw(8),
          localname    varchar2(2000),
          flags        raw(4),
          id           raw(8))';
  exception
       when others then
         -- raise no error if table already exists
         NULL;
end;
/

grant select,insert,update,delete on xdb.xdb$import_tt_info to public;

-- END MOVED from xdbu112.sql

Rem ================================================================
Rem END XDB RDBMS Object Upgrade from 11.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB RDBMS Object Upgrade from the next release
Rem ================================================================

@@xdbuo121.sql

