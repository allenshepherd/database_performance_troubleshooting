Rem
Rem $Header: rdbms/admin/catxdbpi.sql /main/17 2016/06/13 13:44:45 qyu Exp $
Rem
Rem catxdbpi.sql
Rem
Rem Copyright (c) 2001, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxdbpi.sql - XDB Path Index
Rem
Rem    DESCRIPTION
Rem      This file contains the indextype information needed to support 
Rem    the PATH INDEX
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catxdbpi.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxdbpi.sql
Rem SQL_PHASE: CATXDBPI
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    qyu         06/08/16 - do not grant exec on XDB_PITRIG_PKG_01 to public 
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    samane      05/28/09 - Security fixes: added authid current_user 
Rem    abagrawa    04/13/04 - Add pi upd, del for metadata 
Rem    najain      05/28/03 - create XDB_PITRIG_PKG under sys
Rem    najain      05/22/03 - pass current user in pitrig_upd
Rem    njalali     09/04/02 - removing references to PATH_INDEX until 10i
Rem    njalali     08/13/02 - no ORA errors during migration
Rem    fge         06/25/02 - fix bug 2285601
Rem    fge         06/13/02 - rename prvtpidx.sql to prvtxdbp.sql
Rem    sichandr    01/16/02 - remove getref from pathindex pkg
Rem    fge         01/08/02 - rename prvtxdbpi.sql to prvtpidx.sql
Rem    spannala    01/11/02 - making all systems types have standard TOIDs
Rem    sichandr    01/02/02 - fix xdbhi_im
Rem    spannala    12/27/01 - run setup connected as sys
Rem    spannala    12/13/01 - removing connect
Rem    najain      11/14/01 - get_ref signature change
Rem    nagarwal    11/12/01 - Merged nagarwal_xdb_pathindex_fix
Rem    nagarwal    11/12/01 - grant exempt access policy to xdb
Rem    nagarwal    11/08/01 - move the raise_error procedure to prvtxdbz
Rem    nagarwal    11/05/01 - some reorg & cleanup
Rem    najain      11/03/01 - use triggers for hierarchy
Rem    najain      10/31/01 - fix compilation errors
Rem    najain      10/30/01 - define indices
Rem    najain      10/23/01 - define truncate/drop triggers
Rem    nagarwal    10/08/01 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


/* drop objects */
Rem drop indextype xdb.path_index;
drop type xdb.xdbpi_im;
drop table xdb.xdb$path_index_params;

/*-----------------------------------------------------------------------*/
/*  LIBRARY & DICT TABLE                                                 */
/*-----------------------------------------------------------------------*/
create or replace library xdb.path_index_lib trusted as static;
/
create table xdb.xdb$path_index_params
( mount_point      varchar2(2000),
  enum_col_clause  varchar2(2000),
  name             varchar2(128),
  connect_clause   varchar2(2000)
);

/*------------------------------------------------------------------------*/
/* Index TRIGGER BODY                                                     */
/*------------------------------------------------------------------------*/
-- XDB Path Index TRIGger PacKaGE
create or replace package xdb.XDB_PITRIG_PKG_01 authid definer AS
  procedure pitrig_del(owner varchar2, name varchar2, deloid raw, tbloid raw);
  procedure pitrig_upd(owner varchar2, name varchar2, deloid raw, tbloid raw,
                       cuser varchar2);
  procedure pitrig_delmetadata(owner varchar2, name varchar2, deloid raw,
                               tbloid raw, resid raw, cuser varchar2);
  procedure pitrig_updmetadata(owner varchar2, name varchar2, deloid raw,
                               tbloid raw, resid raw, cuser varchar2);
end XDB_PITRIG_PKG_01;
/

create or replace package xdb.XDB_PITRIG_PKG authid current_user AS 
  procedure pitrig_del(owner varchar2, name varchar2, deloid raw, tbloid raw);
  procedure pitrig_upd(owner varchar2, name varchar2, deloid raw, tbloid raw,
                       cuser varchar2);
  procedure pitrig_drop(owner varchar2, name varchar2);
  procedure pitrig_truncate(owner varchar2, name varchar2);
  procedure pitrig_delmetadata(owner varchar2, name varchar2, deloid raw, 
                               tbloid raw, resid raw, cuser varchar2);
  procedure pitrig_updmetadata(owner varchar2, name varchar2, deloid raw, 
                               tbloid raw, resid raw, cuser varchar2);
  procedure pitrig_dropmetadata(owner varchar2, name varchar2);
end XDB_PITRIG_PKG;
/

grant execute on xdb.XDB_PITRIG_PKG to public;

show errors;

/*-----------------------------------------------------------------------*/
/*  IMPLEMENTATION TYPE                                                  */
/*-----------------------------------------------------------------------*/
create or replace type xdb.xdbpi_im OID '00000000000000000000000000020116'
   authid definer as object(
  notused    RAW(4),

  
  static function ODCIGetInterfaces (ilist OUT sys.ODCIObjectList) return number,

  static function ODCIIndexCreate(ia sys.odciindexinfo, parms varchar2,
      env sys.odcienv)  return number,

  static function ODCIIndexDrop(ia sys.odciindexinfo, env sys.ODCIEnv)
    return number, 

  STATIC FUNCTION ODCIIndexTruncate(ia sys.odciindexinfo, env sys.ODCIEnv) 
    RETURN NUMBER,

  static function ODCIIndexInsert(ia sys.odciindexinfo, rid varchar2, 
        newval sys.xmltype, env sys.ODCIEnv) return number,

  static function ODCIIndexDelete(ia sys.odciindexinfo, rid varchar2, 
    oldval sys.xmltype, env sys.ODCIEnv) return number,

  static function ODCIIndexUpdate(ia sys.odciindexinfo, rid varchar2, 
    oldval sys.xmltype, newval sys.xmltype, env sys.ODCIEnv) 
    return number, 

  static function ODCIIndexStart(sctx IN OUT xdb.xdbpi_im, 
      ia sys.odciindexinfo, op sys.odcipredinfo, qi sys.odciqueryinfo,
      strt number, stop number, pathstr varchar2, env sys.odcienv)  
      return number,

  member function ODCIIndexFetch(nrows number, rids OUT sys.odciridlist, 
     env sys.odcienv) return number,

  member function ODCIIndexClose (env sys.odcienv) return number 
);
/
show errors;

/*------------------------------------------------------------------------*/
/* IMPLEMENTATION TYPE BODY                                              */
/*------------------------------------------------------------------------*/
create or replace type body xdb.xdbpi_im
is 
  static function ODCIGetInterfaces(ilist OUT sys.ODCIObjectList) 
    return number is 
  begin 
    ilist := sys.ODCIObjectList(sys.ODCIObject('SYS', 'ODCIINDEX2'));
    return ODCICONST.SUCCESS;
  end ODCIGetInterfaces;

  static function ODCIIndexCreate(ia sys.odciindexinfo, parms varchar2,
    env sys.ODCIEnv) return number as 
  begin 
    return ODCICONST.SUCCESS;
  end ODCIIndexCreate;

  static function ODCIIndexDrop(ia sys.odciindexinfo, env sys.ODCIEnv) 
    return number
  is 
  begin 
    -- drop all the rows in the resource_view
    -- The drop is handled via the trigger xdb_pi_trig
    return ODCICONST.SUCCESS;
  end ODCIIndexDrop;

  STATIC FUNCTION ODCIIndexTruncate(ia sys.odciindexinfo, env sys.ODCIEnv) 
    RETURN NUMBER
  is 
  begin 
    -- drop all the rows in the resource_view
    -- The truncate is handled via the trigger xdb_pi_trig
    return ODCICONST.SUCCESS;
  end ODCIIndexTruncate;

  static function ODCIIndexInsert(ia sys.ODCIIndexInfo, rid varchar2,
    newval sys.xmltype, env sys.ODCIEnv) return number 
  is 
  begin 
    return ODCICONST.SUCCESS;
  end ODCIIndexInsert;

  static function ODCIIndexDelete(ia sys.ODCIIndexInfo, rid varchar2, 
    oldval sys.xmltype, env sys.ODCIEnv) return number
  is
  begin 
    -- For delete/update a trigger will be created per table when the table is
    -- enabled for hierarchy. The name of the trigger: <table_name>_XDB_PITRIG
    -- This is done is prvtxdbz.sql
    return ODCICONST.SUCCESS;
  end ODCIIndexDelete;

  static function ODCIIndexUpdate(ia sys.ODCIIndexInfo, rid varchar2,
    oldval sys.xmltype, newval sys.xmltype, env sys.ODCIEnv)
    return number 
  is
  begin 
    return ODCICONST.SUCCESS;
  end ODCIIndexUpdate;

  static function ODCIIndexStart(sctx IN OUT xdb.xdbpi_im, 
      ia sys.odciindexinfo, op sys.odcipredinfo, qi sys.odciqueryinfo,
      strt number, stop number, pathstr varchar2, env sys.odcienv)  
      return number 
  is
  begin
    return ODCICONST.SUCCESS;
  end ODCIIndexStart;

  member function ODCIIndexFetch(nrows number, rids OUT sys.odciridlist, 
     env sys.odcienv) return number 
  is
  begin
    return ODCICONST.SUCCESS;
  end ODCIIndexFetch;

  member function ODCIIndexClose (env sys.odcienv) return number 
  is
  begin
    return ODCICONST.SUCCESS;
  end ODCIIndexClose;

end;
/
show errors;
grant execute on xdb.xdbpi_im to public;

/*------------------------------------------------------------------------*/
/*  OPERATORS and INDEXTYPES                                              */
/*------------------------------------------------------------------------*/
/* primary operator */
create or replace package xdb.xdbpi_funcimpl as
  function noop_func(res sys.xmltype) return number;
end;
/

create or replace package body xdb.xdbpi_funcimpl as
  function noop_func(res sys.xmltype) return number is
  begin
   return 0;
  end;
end;
/


-- dummy operator
Rem create or replace operator xdb.xdbpi_noop binding (sys.xmltype) 
Rem return number 
Rem using xdb.xdbpi_funcimpl.noop_func;

Rem grant execute on xdb.xdbpi_noop to public;

-- indextype
Rem create indextype xdb.path_index for xdb.xdbpi_noop(sys.xmltype) 
Rem  using xdb.xdbpi_im;

-- The body for catxdbpi i.e. prvtxdbp is invoked from catxdbr.sql because of 
-- the dependency of the package body on resource_view

@?/rdbms/admin/sqlsessend.sql
