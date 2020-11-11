Rem
Rem $Header: rdbms/admin/dbmsslxp.sql /main/3 2014/02/20 12:45:41 surman Exp $
Rem
Rem dbmsslxp.sql
Rem
Rem Copyright (c) 2003, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsslxp.sql - export action for Server aLert threshold
Rem
Rem    DESCRIPTION
Rem      Implements export action which is automatically called by export
Rem      to export server alert threshold.  Generate Pl/SQL blocks to 
Rem      define thresholds, which are stored by export in the export file,
Rem      later to be invoked by import.
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsslxp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsslxp.sql
Rem SQL_PHASE: DBMSSLXP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jxchen      05/31/03 - jxchen_alrt8
Rem    jxchen      05/14/03 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_server_alert_export AUTHID CURRENT_USER AS

-- Generate PL/SQL for procedural actions
 FUNCTION system_info_exp(prepost IN PLS_INTEGER,
                          connectstring OUT VARCHAR2,
                          version IN VARCHAR2,
                          new_block OUT PLS_INTEGER)
 RETURN VARCHAR2;

END dbms_server_alert_export;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_server_alert_export
   for sys.dbms_server_alert_export
/
GRANT EXECUTE ON dbms_server_alert_export TO EXECUTE_CATALOG_ROLE
/

@?/rdbms/admin/sqlsessend.sql
