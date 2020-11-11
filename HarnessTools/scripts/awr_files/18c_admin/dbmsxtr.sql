Rem
Rem $Header: rdbms/admin/dbmsxtr.sql /main/3 2014/02/20 12:46:25 surman Exp $
Rem
Rem dbmsxtr.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxtr.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxtr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxtr.sql
Rem SQL_PHASE: DBMSXTR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    smalde      03/03/06 - Add enableTranslations 
Rem    smalde      02/21/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

set echo on
set feedback 1
set numwidth 10
set linesize 80
set trimspool on
set tab off
set pagesize 100

grant execute on xdb.xdb_privileges to public with grant option;

create or replace package xdb.dbms_xmltranslations 
authid current_user is

function translatexml ( 
    doc  in xmltype,
    lang in varchar2
) return xmltype;

function getbasedocument ( 
    doc  in xmltype
) return xmltype;

function updatetranslation (
    doc   in xmltype,
    xpath in varchar2, 
    lang  in varchar2, 
    value in varchar2,
    namespace in varchar2 := null
) return xmltype;

function setsourcelang (
    doc   in xmltype,
    xpath in varchar2, 
    lang  in varchar2,
    namespace in varchar2 := null
) return xmltype;

function extractxliff (
    doc   in xmltype, 
    xpath in varchar2,
    namespace in varchar2 := null
) return xmltype;

function extractxliff (
    abspath in varchar2,
    xpath   in varchar2,
    namespace in varchar2 := null
) return xmltype;

function mergexliff (
    doc   in xmltype, 
    xliff in xmltype
) return xmltype;

procedure mergexliff (
    xliff in xmltype
);

procedure enableTranslation;
procedure disableTranslation;

end dbms_xmltranslations;
/
show errors;

create or replace public synonym dbms_xmltranslations for xdb.dbms_xmltranslations
/
grant execute on xdb.dbms_xmltranslations to public
/
show errors;

@?/rdbms/admin/sqlsessend.sql
