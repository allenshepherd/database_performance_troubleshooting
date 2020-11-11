Rem
Rem $Header: rdbms/admin/dbmsxschlsb.sql /main/9 2015/08/19 11:54:51 raeburns Exp $
Rem
Rem dbmsxschlsb.sql
Rem
Rem Copyright (c) 2011, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxschlsb.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxschlsb.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxschlsb.sql
Rem SQL_PHASE: DBMSXSCHLSB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    06/09/15 - Use FORCE for types with only type dependents
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    tojhuan     11/13/12 - 15865197: provide replication pragmas for
Rem                           procedures in DBMS_XMLSCHEMA_LSB
Rem    srirkris    07/15/12 - Add resmd parameter to supplementally logged procedure
Rem    srirkris    09/08/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

create or replace library xdb.DBMSXSCHLSB_LIB trusted as static
/

CREATE OR REPLACE TYPE xdb.DBMS_XMLSCHEMA_TABMD FORCE as OBJECT (
        schema_name  varchar2(700),
	element_name varchar2(128),
	table_name   varchar2(128),
	table_oid    raw(16)
);
/

CREATE OR REPLACE TYPE xdb.DBMS_XMLSCHEMA_TABMDARR AS VARRAY(65536) OF xdb.DBMS_XMLSCHEMA_TABMD;
/


CREATE OR REPLACE TYPE xdb.DBMS_XMLSCHEMA_RESMD FORCE as OBJECT (
        path_name varchar2(4000),
	path_oid raw(16)
);
/

CREATE OR REPLACE TYPE xdb.DBMS_XMLSCHEMA_RESMDARR AS VARRAY(65536) OF xdb.DBMS_XMLSCHEMA_RESMD;
/


create or replace public synonym DBMS_XMLSCHEMA_TABMD for xdb.DBMS_XMLSCHEMA_TABMD;
grant execute on DBMS_XMLSCHEMA_TABMD to public ;
create or replace public synonym DBMS_XMLSCHEMA_TABMDARR for xdb.DBMS_XMLSCHEMA_TABMDARR;
grant execute on DBMS_XMLSCHEMA_TABMDARR to public ;


create or replace public synonym DBMS_XMLSCHEMA_RESMD for xdb.DBMS_XMLSCHEMA_RESMD;
grant execute on DBMS_XMLSCHEMA_RESMD to public ;
create or replace public synonym DBMS_XMLSCHEMA_RESMDARR for xdb.DBMS_XMLSCHEMA_RESMDARR;
grant execute on DBMS_XMLSCHEMA_RESMDARR to public ;


create or replace package xdb.dbms_xmlschema_lsb authid current_user is

  procedure registerSchema_Str(schemaurl IN varchar2,
                           schemadoc IN varchar2,
                           local IN number,
                           gentypes IN number, 
                           genbean IN number, 
                           gentables IN number,
                           force IN number,
                           owner IN varchar2,
                           enablehierarchy IN number,
                           options IN number,
                           schemaoid IN RAW,
                           tabmd IN xdb.DBMS_XMLSCHEMA_TABMDARR,
                           resmd IN xdb.DBMS_XMLSCHEMA_RESMDARR);
  pragma supplemental_log_data (registerSchema_Str, AUTO);
   
  procedure registerSchema_Clob(schemaurl IN varchar2,
                           schemadoc IN CLOB, 
                           local IN number,
                           gentypes IN number, 
                           genbean IN number, 
                           gentables IN number,
                           force IN number,
                           owner IN varchar2,
                           enableHierarchy IN number,
                           options IN number,
                           schemaoid IN RAW,
                           tabmd IN xdb.DBMS_XMLSCHEMA_TABMDARR,
                           resmd IN xdb.DBMS_XMLSCHEMA_RESMDARR);

  procedure registerSchema_Blob(schemaurl IN varchar2,
                           schemadoc IN BLOB, 
                           local IN number,
                           gentypes IN number, 
                           genbean IN number, 
                           gentables IN number,
                           force IN number,
                           owner IN varchar2, 
                           csid IN NUMBER,
                           enablehierarchy IN number,
                           options IN number,
                           schemaoid IN RAW,
                           tabmd IN xdb.DBMS_XMLSCHEMA_TABMDARR,
                           resmd IN xdb.DBMS_XMLSCHEMA_RESMDARR);
  pragma supplemental_log_data (registerSchema_Blob, AUTO);

  procedure registerSchema_XML(schemaurl IN varchar2,
                           schemadoc IN sys.xmltype, 
                           local IN number,
                           gentypes IN number, 
                           genbean IN number, 
                           gentables IN number,
                           force IN number,
                           owner IN varchar2,
                           enablehierarchy IN number,
                           options IN number,
                           schemaoid IN RAW,
                           tabmd IN xdb.DBMS_XMLSCHEMA_TABMDARR,
                           resmd IN xdb.DBMS_XMLSCHEMA_RESMDARR);
  pragma supplemental_log_data (registerSchema_XML, AUTO);

  procedure registerSchema_OID(schemaurl IN varchar2,
                           schemadoc IN CLOB, 
                           local IN number,
                           gentypes IN number, 
                           genbean IN number, 
                           gentables IN number,
                           force IN number,
                           owner IN varchar2,
                           enablehierarchy IN number,
                           options IN number,
                           schemaoid IN RAW,
                           elname IN varchar2,
                           elnum IN number,
                           import_options IN number,
                           tabmd IN xdb.DBMS_XMLSCHEMA_TABMDARR,
                           resmd IN xdb.DBMS_XMLSCHEMA_RESMDARR);
  pragma supplemental_log_data (registerSchema_OID, AUTO);

  procedure CopyEvolve(schemaurls         IN XDB$STRING_LIST_T,
                       newSchemas         IN XMLSequenceType,
                       transforms         IN XMLSequenceType,
                       preserveolddocs    IN NUMBER,
                       maptabname         IN VARCHAR2,
                       generatetables     IN NUMBER,
                       force              IN NUMBER,
                       schemaowners       IN XDB$STRING_LIST_T,
                       paralleldegree     IN NUMBER,
                       options            IN NUMBER,
                       tabmd IN xdb.DBMS_XMLSCHEMA_TABMDARR,
                       resmd IN xdb.DBMS_XMLSCHEMA_RESMDARR);
  pragma supplemental_log_data (CopyEvolve, AUTO);

  procedure compileSchema(schemaURL IN varchar2, 
                          schemaoid IN RAW,
                          tabmd        IN xdb.DBMS_XMLSCHEMA_TABMDARR);

end dbms_xmlschema_lsb;
/
show errors

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XMLSCHEMA_LSB FOR xdb.DBMS_XMLSCHEMA_LSB;

GRANT EXECUTE ON DBMS_XMLSCHEMA_LSB TO PUBLIC;

@?/rdbms/admin/sqlsessend.sql
