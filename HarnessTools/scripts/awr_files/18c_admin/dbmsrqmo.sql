Rem
Rem $Header: rdbms/admin/dbmsrqmo.sql /main/3 2017/02/08 17:42:08 ffeli Exp $
Rem
Rem dbmsrqmo.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsrqmo.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsrqmo.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/dbmsodm.sql
Rem                      rdbms/admin/dmproc.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ffeli       12/12/16 - Add view_num for algorithm registration
Rem    qinwan      01/22/15 - bug 20398431: model_name naming conflict
Rem    qinwan      09/17/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-------------------------- dm$rqMod_DetailImpl --------------------------------
--
-- Object type declaration for table function GET_MODEL_DETAILS_RA
-- in DBMS_DATA_MINING package.
--
CREATE OR REPLACE TYPE dm$rqMod_DetailImpl 
AUTHID CURRENT_USER AS OBJECT (
  typ                            SYS.AnyType,
  key                            RAW(4),

  -- ODCITableDescribe --------------------------------------------------------
  --
  STATIC FUNCTION ODCITableDescribe(
    typ1                           OUT SYS.AnyType,
    mod_nam                        VARCHAR2,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    view_num                       NUMBER default -1)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTableDescribe(
    typ1                           OUT SYS.AnyType,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITablePrepare ---------------------------------------------------------
  --
  STATIC FUNCTION ODCITablePrepare(
    sctx                           OUT dm$rqMod_DetailImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    mod_nam                        VARCHAR2,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    view_num                       NUMBER default -1)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTablePrepare(
    sctx                           OUT dm$rqMod_DetailImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITableStart -----------------------------------------------------------
  --
  STATIC FUNCTION ODCITableStart(
    sctx                           IN OUT dm$rqMod_DetailImpl,
    mod_nam                        VARCHAR2,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    view_num                       NUMBER default -1)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTableStart(
    sctx                           IN OUT dm$rqMod_DetailImpl,
    mod_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    env_val                        ora_mining_varchar2_nt,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITableFetch -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableFetch(
    self                           IN OUT dm$rqMod_DetailImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER,

  MEMBER FUNCTION StubTableFetch(
    self                           IN OUT dm$rqMod_DetailImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER,

  -- ODCITableClose -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableClose(
    self                           dm$rqMod_DetailImpl)
  RETURN PLS_INTEGER,

  MEMBER FUNCTION StubTableClose(
    self                           dm$rqMod_DetailImpl)
  RETURN PLS_INTEGER
);
/

@?/rdbms/admin/sqlsessend.sql
