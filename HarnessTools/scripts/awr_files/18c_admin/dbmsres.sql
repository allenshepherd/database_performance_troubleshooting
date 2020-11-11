Rem
Rem $Header: rdbms/admin/dbmsres.sql /main/5 2014/02/20 12:45:39 surman Exp $
Rem
Rem dbmsres.sql
Rem
Rem Copyright (c) 2000, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsres.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsres.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsres.sql
Rem SQL_PHASE: DBMSRES
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    ssvemuri    04/16/01 - execute on dbms_resumable to dba.
Rem    shihliu     09/05/00 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_resumable AUTHID CURRENT_USER IS

  PROCEDURE abort(sessionID IN NUMBER);
  FUNCTION get_session_timeout(sessionID IN NUMBER) RETURN NUMBER;
  PROCEDURE set_session_timeout(sessionID IN NUMBER, timeout IN NUMBER);
  FUNCTION get_timeout RETURN NUMBER;
  PROCEDURE set_timeout(timeout IN NUMBER);
  FUNCTION space_error_info(error_type          OUT VARCHAR2,
                            object_type         OUT VARCHAR2,
                            object_owner        OUT VARCHAR2,
                            table_space_name    OUT VARCHAR2,
                            object_name         OUT VARCHAR2,
                            sub_object_name     OUT VARCHAR2) RETURN BOOLEAN;

END;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_resumable FOR sys.dbms_resumable
/
GRANT EXECUTE ON dbms_resumable TO dba
/

CREATE OR REPLACE FUNCTION space_error_info
        (error_type          OUT VARCHAR2,
         object_type         OUT VARCHAR2,
         object_owner        OUT VARCHAR2,
         table_space_name    OUT VARCHAR2,
         object_name         OUT VARCHAR2,
         sub_object_name     OUT VARCHAR2) RETURN BOOLEAN IS
BEGIN
  RETURN dbms_resumable.space_error_info(error_type, object_type,
                                         object_owner, table_space_name,
                                         object_name, sub_object_name);
END;
/

GRANT EXECUTE ON space_error_info TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM ora_space_error_info FOR space_error_info
/

-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_RESUMABLE_LIB TRUSTED AS STATIC
/


@?/rdbms/admin/sqlsessend.sql
