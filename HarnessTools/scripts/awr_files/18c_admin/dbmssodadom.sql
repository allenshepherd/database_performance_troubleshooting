Rem
Rem $Header: rdbms/admin/dbmssodadom.sql /st_rdbms_18.0/1 2018/04/11 10:34:39 sriksure Exp $
Rem
Rem dbmssodadom.sql
Rem
Rem Copyright (c) 2015, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmssodadom.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmssodadom.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmssodadom.sql
Rem    SQL_PHASE: DBMSSODADOM
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catsodacoll.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sriksure    04/02/18 - Bug 27698424: Backport SODA bugs from main
Rem    morgiyan    05/11/16 - Removed old comment
Rem    prthiaga    10/19/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package XDB.DBMS_SODA_DOM
authid current_user
is
  -- Bad patch spec or projection spec errors,
  -- coming from XDK error translation in qjsng.c
  INVALID_SPEC                constant number := -40564;

  -- Array related errors in projection spec,
  -- coming from XDK error translation in qjsng.c
  PROJ_SPEC_ARRAY_ERRORS      constant number := -40457;

  -- Invalid path errors in projection spec
  -- coming from XDK error translation in qjsng.c
  PROJ_SPEC_PATH_ERRORS       constant number := -40442;
  
  -- JSON_SYNTAX_ERROR is returned by patch/redact DOM
  -- methods when the spec is not in valid JSON.
  -- DBMS_SODA_DOM then returns PROJ_SPEC_JSON_INVALID
  -- or PATCH_SPEC_JSON_INVALID to the caller. In other words,
  -- JSON_SYNTAX_ERROR is mapped to PROJ_SPEC_JSON_INVALID
  -- or PATCH_SPEC_JSON_INVALID by DBMS_SODA_DOM
  JSON_SYNTAX_ERROR           constant number := -40441;
  PROJ_SPEC_JSON_INVALID      constant number := -40628;
  PATCH_SPEC_JSON_INVALID     constant number := -40629;
  --
  function JSON_SELECT(JVAL in varchar2,
                       JSELECT in varchar2,
                       EXCEPTIONS in varchar2 default 'ALL')
    return varchar2;
  function JSON_SELECT_N(JVAL in nvarchar2,
                         JSELECT in varchar2,
                         EXCEPTIONS in varchar2 default 'ALL')
    return varchar2;
  function JSON_SELECT_R(JVAL in raw,
                         JSELECT in varchar2,
                         EXCEPTIONS in varchar2 default 'ALL')
    return raw;
  function JSON_SELECT_C(JVAL in clob,
                         JSELECT in varchar2,
                         EXCEPTIONS in varchar2 default 'ALL')
    return clob;
  function JSON_SELECT_NC(JVAL in nclob,
                          JSELECT in varchar2,
                          EXCEPTIONS in varchar2 default 'ALL')
    return clob;
  function JSON_SELECT_B(JVAL in blob,
                         JSELECT in varchar2,
                         EXCEPTIONS in varchar2 default 'ALL')
    return blob;
  --
  function JSON_PATCH(JVAL in varchar2,
                      JPATCH in varchar2,
                      EXCEPTIONS in varchar2 default 'ALL')
    return varchar2;
  function JSON_PATCH_N(JVAL in nvarchar2,
                        JPATCH in varchar2,
                        EXCEPTIONS in varchar2 default 'ALL')
    return varchar2;
  function JSON_PATCH_R(JVAL in raw,
                        JPATCH in varchar2,
                        EXCEPTIONS in varchar2 default 'ALL')
    return raw;
  function JSON_PATCH_C(JVAL in clob,
                        JPATCH in varchar2,
                        EXCEPTIONS in varchar2 default 'ALL')
    return clob;
  function JSON_PATCH_NC(JVAL in nclob,
                         JPATCH in varchar2,
                         EXCEPTIONS in varchar2 default 'ALL')
    return clob;
  function JSON_PATCH_B(JVAL in blob,
                        JPATCH in varchar2,
                        EXCEPTIONS in varchar2 default 'ALL')
    return blob;
  --
  function JSON_MERGE_PATCH(JVAL in varchar2,
                            JPATCH in varchar2,
                            EXCEPTIONS in varchar2 default 'ALL')
    return varchar2;
  function JSON_MERGE_PATCH_N(JVAL in nvarchar2,
                              JPATCH in varchar2,
                              EXCEPTIONS in varchar2 default 'ALL')
    return varchar2;
  function JSON_MERGE_PATCH_R(JVAL in raw,
                              JPATCH in varchar2,
                              EXCEPTIONS in varchar2 default 'ALL')
    return raw;
  function JSON_MERGE_PATCH_C(JVAL in clob,
                              JPATCH in varchar2,
                              EXCEPTIONS in varchar2 default 'ALL')
    return clob;
  function JSON_MERGE_PATCH_NC(JVAL in nclob,
                               JPATCH in varchar2,
                               EXCEPTIONS in varchar2 default 'ALL')
    return clob;
  function JSON_MERGE_PATCH_B(JVAL in blob,
                              JPATCH in varchar2,
                              EXCEPTIONS in varchar2 default 'ALL')
    return blob;
  --                    
  function TIMESTAMP_TO_NUMBER(TSTAMP in timestamp)
    return number;      
  function UUID_TO_HEX(UUID in raw)
    return varchar2;
  function NUMBER_TO_STRING(NUM in number)
    return varchar2;
  function NUMBER_TO_HEX(NUM in number)
    return varchar2;
  --
end DBMS_SODA_DOM;
/

show errors;
/

create public synonym DBMS_SODA_DOM for XDB.DBMS_SODA_DOM;

grant execute on XDB.DBMS_SODA_DOM to PUBLIC;

@?/rdbms/admin/sqlsessend.sql
