Rem
Rem $Header: rdbms/admin/dbmsxvr.sql /main/10 2014/02/20 12:46:26 surman Exp $
Rem
Rem dbmsxvr.sql
Rem
Rem Copyright (c) 2003, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxvr.sql - DBMS_XDB_VERSION package
Rem
Rem    DESCRIPTION
Rem      Package definiton and body of dbms_xdb_version package.
Rem
Rem    NOTES
Rem      Split out from catxdbvr for the purposes of independent loading
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxvr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxvr.sql
Rem SQL_PHASE: DBMSXVR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catxdbvr
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    stirmizi    04/11/12 - remove subprograms from dbms_xdb_version header
Rem    yinlu       10/13/11 - handle checkin and uncheckout
Rem    yinlu       09/29/11 - add makeversioned_int
Rem    yinlu       07/20/11 - add pragma for logical standby
Rem    thbaby      12/30/05 - new checkout api 
Rem    thbaby      12/30/05 - default parameter values 
Rem    thbaby      11/09/05 - add workspace related API routines 
Rem    vkapoor     03/07/05 - 
Rem    vkapoor     02/03/05 - bug 4075243 
Rem    vkapoor     02/06/05 - bug 4075253 
Rem    najain      10/01/04 - dbms_xdb_version is invoker\'s rights
Rem    spannala    12/23/03 - spannala_bug-3321840 
Rem    spannala    12/16/03 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

/* Package DBMS_XDB_VERSION */
create or replace package XDB.DBMS_XDB_VERSION authid current_user as

  SUBTYPE resid_type is RAW(16);
  TYPE resid_list_type is VARRAY(1000) of RAW(16);

  PROCEDURE makeversioned_int(pathname IN VARCHAR2, resid OUT resid_type);
  PRAGMA SUPPLEMENTAL_LOG_DATA(makeversioned_int, AUTO);

  FUNCTION makeversioned(pathname VARCHAR2) RETURN resid_type;

  PROCEDURE checkout(pathname VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(checkout, AUTO);

  PROCEDURE checkin_int(pathname IN VARCHAR2, resid OUT resid_type);
  PRAGMA SUPPLEMENTAL_LOG_DATA(checkin_int, AUTO);

  FUNCTION checkin(pathname VARCHAR2) RETURN resid_type;

  PROCEDURE uncheckout_int(pathname IN VARCHAR2, resid OUT resid_type);
  PRAGMA SUPPLEMENTAL_LOG_DATA(uncheckout_int, AUTO);

  FUNCTION uncheckout(pathname VARCHAR2) RETURN resid_type;

  FUNCTION ischeckedout(pathname VARCHAR2) RETURN BOOLEAN;
  FUNCTION GetPredecessors(pathname VARCHAR2) RETURN resid_list_type;
  FUNCTION GetPredsByResId(resid resid_type) RETURN resid_list_type;
  FUNCTION GetSuccessors(pathname VARCHAR2) RETURN resid_list_type;
  FUNCTION GetSuccsByResId(resid resid_type) RETURN resid_list_type;
  FUNCTION GetResourceByResId(resid resid_type) RETURN XMLType;
  FUNCTION GetContentsBlobByResId(resid resid_type) RETURN BLOB;
  FUNCTION GetContentsClobByResId(resid resid_type) RETURN CLOB;
  FUNCTION GetContentsXmlByResId(resid resid_type) RETURN XMLType;

end DBMS_XDB_VERSION;
/
show errors;

/* library for DBMS_XDB_VERSION */
CREATE OR REPLACE LIBRARY XDB.DBMS_XDB_VERSION_LIB TRUSTED AS STATIC
/

/* package body */
create or replace package body XDB.DBMS_XDB_VERSION as

  PROCEDURE makeversioned_int(pathname IN varchar2, resid OUT resid_type) is
    LANGUAGE C NAME "qmevsMakeVersioned"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, 
                  pathname indicator sb4,
                  resid,
                  resid    indicator sb4,
                  resid    length size_t
                 );

  FUNCTION makeversioned(pathname varchar2) RETURN resid_type is
    ret resid_type;
  BEGIN
    makeversioned_int(pathname, ret);
    return ret;
  END;

  PROCEDURE checkout(pathname varchar2) is
    LANGUAGE C NAME "qmevsCheckout"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname     OCIString, 
                  pathname indicator sb4);

  PROCEDURE checkin_int(pathname IN varchar2, resid OUT resid_type) is
    LANGUAGE C NAME "qmevsCheckin"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, 
                  pathname indicator sb4,
                  resid,
                  resid    indicator sb4,
                  resid    length size_t
                 );

  FUNCTION checkin(pathname varchar2) RETURN resid_type is
    ret resid_type;
  BEGIN
    checkin_int(pathname, ret);
    return ret;
  END;

  PROCEDURE uncheckout_int(pathname IN varchar2, resid OUT resid_type) is
    LANGUAGE C NAME "qmevsUncheckout"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, 
                  pathname indicator sb4,
                  resid,
                  resid    indicator sb4,
                  resid    length size_t
                 );

  FUNCTION uncheckout(pathname varchar2) RETURN resid_type is
    ret resid_type;
  BEGIN
    uncheckout_int(pathname, ret);
    return ret;
  END;

  FUNCTION ischeckedout(pathname varchar2) RETURN BOOLEAN is
    LANGUAGE C NAME "qmevsIsResCheckedOut"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4, 
                  return
                 );

  FUNCTION getresid(pathname varchar2) RETURN resid_type is
    LANGUAGE C NAME "qmevsGetResID"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  FUNCTION GetPredecessors(pathname varchar2) RETURN resid_list_type is
    resid  resid_type;
  BEGIN
    resid := getresid(pathname);
    return GetPredsByResId(resid);
  END;

  FUNCTION GetPredsByResId(resid resid_type) RETURN resid_list_type is
    LANGUAGE C NAME "qmevsGetPredsByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetSuccessors(pathname varchar2) RETURN resid_list_type is
    resid  resid_type;
  BEGIN
    resid := getresid(pathname);
    return GetSuccsByResId(resid);
  END;

  FUNCTION GetSuccsByResId(resid resid_type) RETURN resid_list_type is
    LANGUAGE C NAME "qmevsGetSuccsByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetResourceByResId(resid resid_type) RETURN XMLType is
    LANGUAGE C NAME "qmevsGetResByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetContentsBlobByResId(resid resid_type) RETURN BLOB is
    LANGUAGE C NAME "qmevsGetCtsBlobByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN OCILobLocator
                 );

  FUNCTION GetContentsClobByResId(resid resid_type) RETURN CLOB is
    LANGUAGE C NAME "qmevsGetCtsClobByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN OCILobLocator
                 );

  FUNCTION GetContentsXmlByResId(resid resid_type) RETURN XMLType is
    LANGUAGE C NAME "qmevsGetCtsXmlByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetVersionHistoryID(pathname varchar2) RETURN resid_type is
    LANGUAGE C NAME "qmevsGetVerHistID"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  FUNCTION GetVersionHistory(resid resid_type) RETURN resid_list_type is
    LANGUAGE C NAME "qmevsGetVerHist"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetVersionHistoryRoot(resid resid_type) RETURN resid_type IS
    LANGUAGE C NAME "qmevsGetVerHistRoot"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  PROCEDURE CreateRealWorkspace(wsname        IN VARCHAR2, 
                                initializer   IN VARCHAR2,
                                published     IN boolean, 
                                privateNonVCR IN boolean) IS
    LANGUAGE C NAME "qmevsCreateRealWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname            OCIString, 
                  wsname        indicator sb4,
                  initializer       OCIString, 
                  initializer   indicator sb4,
                  published               ub2, 
                  published     indicator sb4,
                  privateNonVCR           ub2, 
                  privateNonVCR indicator sb4
                 );

  PROCEDURE CreateVirtualWorkspace(wsname      IN VARCHAR2, 
                                   base_wsname IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsCreateVirtualWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname          OCIString, 
                  wsname      indicator sb4,
                  base_wsname     OCIString, 
                  base_wsname indicator sb4
                 );

  PROCEDURE DeleteWorkspace(wsname IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsDeleteWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname     OCIString, 
                  wsname indicator sb4
                 );

  PROCEDURE SetWorkspace(wsname IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsSetWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname     OCIString, 
                  wsname indicator sb4
                 );

  PROCEDURE GetWorkspace(wsname OUT VARCHAR2) IS
    LANGUAGE C NAME "qmevsGetWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname          STRING,
                  wsname   INDICATOR sb4,
                  wsname      LENGTH sb4,
                  wsname      MAXLEN sb4
                 );

  PROCEDURE PublishWorkspace(wsname IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsPublishWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname     OCIString, 
                  wsname indicator sb4
                 );

  PROCEDURE UnPublishWorkspace(wsname IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsUnPublishWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname     OCIString, 
                  wsname indicator sb4
                 );

  PROCEDURE UpdateWorkspace(target_wsname IN VARCHAR2,
                            source_wsname IN VARCHAR2,
                            privateNonVCR IN BOOLEAN) IS
    LANGUAGE C NAME "qmevsUpdateWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  target_wsname     OCIString, 
                  target_wsname indicator sb4,
                  source_wsname     OCIString, 
                  source_wsname indicator sb4,
                  privateNonVCR           ub2,
                  privateNonVCR indicator sb4
                 );

  PROCEDURE CreateBranch(name IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsCreateBranch"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  name      OCIString, 
                  name  indicator sb4
                 );

  PROCEDURE MakeShared(path IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsMakeShared"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  path         OCIString, 
                  path     indicator sb4
                 );

  PROCEDURE CreateVCR(path IN VARCHAR2, versionResID IN resid_type) IS
    LANGUAGE C NAME "qmevsCreateVCR"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  path             OCIString, 
                  path         indicator sb4,
                  versionResID        OCIRaw,
                  versionResID indicator sb4
                 );

  PROCEDURE UpdateVCRVersion(path IN VARCHAR2, newResID IN resid_type) IS
    LANGUAGE C NAME "qmevsUpdateVCR"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  path             OCIString, 
                  path         indicator sb4,
                  newResID            OCIRaw,
                  newResID     indicator sb4
                 );

  PROCEDURE DeleteVersion(versionResID IN resid_type) IS
    LANGUAGE C NAME "qmevsDelVersion"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  versionResID        OCIRaw,
                  versionResID indicator sb4
                 );

  PROCEDURE DeleteVersionHistory(vhid resid_type) IS
    LANGUAGE C NAME "qmevsDeleteVerHist"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  vhid        OCIRaw,
                  vhid indicator sb4
                 );

end DBMS_XDB_VERSION;
/
show errors;
GRANT EXECUTE ON XDB.DBMS_XDB_VERSION TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM DBMS_XDB_VERSION FOR XDB.DBMS_XDB_VERSION;

@?/rdbms/admin/sqlsessend.sql
