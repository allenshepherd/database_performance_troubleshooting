Rem
Rem $Header: rdbms/admin/catxdbeo.sql /main/8 2016/10/06 14:55:25 hxzhang Exp $
Rem
Rem catxdbeo.sql
Rem
Rem Copyright (c) 2003, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxdbeo.sql - XDB repository views extensible optimizer
Rem
Rem    DESCRIPTION
Rem      This script creates statistics type and schema
Rem
Rem    NOTES
Rem      
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catxdbeo.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxdbeo.sql
Rem SQL_PHASE: CATXDBEO
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hxzhang     09/22/16 - bug#24618516, 24706168, move folderlisting to
Rem                           catxdbeo.sql, so it will be called during reload
Rem    sriksure    07/20/16 - Bug 22967968 - Moving inline XML schemas to
Rem                           external schema files
Rem    huiz        12/12/14 - bug# 18857697: annotate stats.xsd 
Rem    hxzhang     05/12/14 - annotate schemas with SQLName
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    huiz        11/22/11 - ignore error 29931 raised by executing disassociate statistics 
Rem    njalali     05/20/03 - njalali_all_xml_schemas2
Rem    fge         05/19/03 - support repository views extensible optimizer
Rem    fge         05/19/03 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

/* disassociate statistics type */
begin
  execute immediate 'disassociate statistics from indextypes xdb.xdbhi_idxtyp';
  execute immediate 'disassociate statistics from packages xdb.xdb_funcimpl';
exception
  when others then
    -- suppress expected exception
    -- ORA-29931: specified association does not exist 
    if (SQLCODE != -29931) 
    then raise; 
    end if;
end;
/

/* drop statistics type */
drop type xdb.funcstats;

/* --------------------------------------------------------------------------*/
/* create statistics type                                                    */
/* --------------------------------------------------------------------------*/
create or replace type xdb.funcstats
OID '0000000000000000000000000002015E'
authid definer as object
(
  -- user-defined function cost and selectivity functions
  j number,

  static function ODCIGetInterfaces(ifclist OUT sys.ODCIObjectList) 
    return number,

  -- function to collect index statistics
  static function ODCIStatsCollect(ia sys.ODCIIndexInfo,
                                   options sys.ODCIStatsOptions,
                                   statistics OUT RAW,
                                   env sys.ODCIEnv)
  return number
  is language C
  name "STATSCOLL_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    ia,
    ia INDICATOR STRUCT,
    options,
    options INDICATOR STRUCT,
    statistics,
    statistics INDICATOR,
    statistics LENGTH,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

  -- funtion to delete index statistics
  static function ODCIStatsDelete(ia sys.ODCIIndexInfo,
                                  statistics OUT RAW,
                                  env sys.ODCIEnv)
  return number
  is language C
  name "STATSDEL_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    ia,
    ia INDICATOR STRUCT,
    statistics,
    statistics INDICATOR,
    statistics LENGTH,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

  -- index cost
  static function ODCIStatsIndexCost(ia sys.ODCIIndexInfo,
                                     sel number,
                                     cost OUT sys.ODCICost,
                                     qi sys.ODCIQueryInfo,
                                     pred sys.ODCIPredInfo,
                                     args sys.ODCIArgDescList,
                                     strt number,
                                     stop number,
                                     depth number,
                                     valarg varchar2,
                                     env sys.ODCIenv)
  return number
  is language C
  name "STATSINDCOST_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    ia,
    ia INDICATOR STRUCT,
    sel,
    sel INDICATOR,
    cost,
    cost INDICATOR STRUCT,
    qi,
    qi INDICATOR STRUCT,
    pred,
    pred INDICATOR STRUCT,
    args,
    args INDICATOR,
    strt,
    strt INDICATOR,
    stop,
    stop INDICATOR,
    depth,
    depth INDICATOR,
    valarg,
    valarg INDICATOR,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

  static function ODCIStatsIndexCost(ia sys.ODCIIndexInfo,
                                     sel number,
                                     cost OUT sys.ODCICost,
                                     qi sys.ODCIQueryInfo,
                                     pred sys.ODCIPredInfo,
                                     args sys.ODCIArgDescList,
                                     strt number,
                                     stop number,
                                     valarg varchar2,
                                     env sys.ODCIenv)
  return number
  is language C
  name "STATSINDCOST1_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    ia,
    ia INDICATOR STRUCT,
    sel,
    sel INDICATOR,
    cost,
    cost INDICATOR STRUCT,
    qi,
    qi INDICATOR STRUCT,
    pred,
    pred INDICATOR STRUCT,
    args,
    args INDICATOR,
    strt,
    strt INDICATOR,
    stop,
    stop INDICATOR,
    valarg,
    valarg INDICATOR,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

  -- function cost

  static function ODCIStatsFunctionCost(func sys.ODCIFuncInfo,
                                        cost OUT sys.ODCICost,
                                        args sys.ODCIArgDescList,
                                        colval xmltype,
                                        depth number,
                                        valarg varchar2,
                                        env  sys.ODCIEnv)
  return number
  is language C
  name "STATSFUNCCOST_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    func,
    func INDICATOR STRUCT,
    cost,
    cost INDICATOR STRUCT,
    args,
    args INDICATOR,
    colval, 
    colval INDICATOR,
    depth,
    depth INDICATOR,
    valarg, 
    valarg INDICATOR,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

  static function ODCIStatsFunctionCost(func sys.ODCIFuncInfo,
                                        cost OUT sys.ODCICost,
                                        args sys.ODCIArgDescList,
                                        colval xmltype,
                                        valarg varchar2,
                                        env  sys.ODCIEnv)
  return number
  is language C
  name "STATSFUNCCOST1_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    func,
    func INDICATOR STRUCT,
    cost,
    cost INDICATOR STRUCT,
    args,
    args INDICATOR,
    colval, 
    colval INDICATOR,
    valarg, 
    valarg INDICATOR,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

   static function ODCIStatsSelectivity(pred sys.ODCIPredInfo,
                                        sel OUT number,
                                        args sys.ODCIArgDescList,
                                        strt number,
                                        stop number,
                                        colval xmltype,
                                        depth number,
                                        valarg varchar2,
                                       env sys.ODCIenv)
  return number
  is language C
  name "STATSSEL_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    pred,
    pred INDICATOR STRUCT,
    sel,
    sel INDICATOR,
    args,
    args INDICATOR,
    strt,
    strt INDICATOR,
    stop,
    stop INDICATOR,
    colval, 
    colval INDICATOR,
    depth,
    depth INDICATOR,
    valarg, 
    valarg INDICATOR,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

 -- selectivity for under_path_func1
  static function ODCIStatsSelectivity(pred sys.ODCIPredInfo,
                                       sel OUT number,
                                       args sys.ODCIArgDescList,
                                       strt number,
                                       stop number,
                                       colval xmltype,
                                       valarg varchar2,
                                       env sys.ODCIenv)
  return number
  is language C
  name "STATSSEL1_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    pred,
    pred INDICATOR STRUCT,
    sel,
    sel INDICATOR,
    args,
    args INDICATOR,
    strt,
    strt INDICATOR,
    stop,
    stop INDICATOR,
    colval, 
    colval INDICATOR,
    valarg, 
    valarg INDICATOR,
    env,
    env INDICATOR STRUCT,
    return OCINumber)
);
/

show errors;

/* --------------------------------------------------------------------------*/
/* create statistics type bodies                                             */
/* --------------------------------------------------------------------------*/
create or replace type body xdb.funcstats is
   static function ODCIGetInterfaces(ifclist OUT sys.ODCIObjectList)
       return number is
   begin
       ifclist := sys.ODCIObjectList(sys.ODCIObject('SYS','ODCISTATS2'));
       return ODCIConst.Success;
   end ODCIGetInterfaces;

end;
/
show errors;

grant execute on xdb.funcstats to public;

associate statistics with indextypes xdb.xdbhi_idxtyp using xdb.funcstats;
associate statistics with packages xdb.xdb_funcimpl using xdb.funcstats;

/* --------------------------------------------------------------------------*/
/* register statistics schema
/* --------------------------------------------------------------------------*/
declare
  STATSXSD BFILE := dbms_metadata_hack.get_bfile('stats.xsd');
  STATSURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/stats.xsd';
  n integer;
begin
  select count(*) into n from xdb.xdb$schema s
  where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/stats.xsd';

  dbms_metadata_hack.cre_dir();
  if (n = 0) then
    xdb.dbms_xmlschema.registerSchema(STATSURL, STATSXSD, FALSE, TRUE,
                                      FALSE, TRUE, FALSE, 'XDB');
  end if;
end;
/

Rem Create the schema for folder listings. This is used for representing
Rem folder listings with name and size of each entry. Its not intended
Rem as a schema for folders - merely as a simple schema for listings.

declare
  FLXSD BFILE :=  dbms_metadata_hack.get_bfile('xdbfolderlisting.xsd');
  FLURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/XDBFolderListing.xsd';
  n integer;
begin
  select count(*) into n from xdb.xdb$schema s
  where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBFolderListing.xsd';
  if (n = 0) then
    xdb.dbms_xmlschema.registerSchema(FLURL, FLXSD, FALSE, TRUE, FALSE, FALSE, 
                                      FALSE, 'XDB');
  end if;
end;
/

@?/rdbms/admin/sqlsessend.sql
