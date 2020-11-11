Rem
Rem $Header: rdbms/admin/dbmstxin.sql /main/7 2016/02/09 11:48:14 sspendse Exp $
Rem
Rem dbmstxin.sql
Rem
Rem Copyright (c) 2002, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmstxin.sql - transaction layer package for internal use 
Rem
Rem    DESCRIPTION
Rem      Transaction layer package for internal use 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmstxin.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmstxin.sql
Rem SQL_PHASE: DBMSTXIN
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sspendse    01/25/15 - 20296530: FLASHBACKTBLIST to have 261 bytes
Rem    sspendse    01/20/15 - 20296530: FLASHBACKTBLIST to have 128 bytes
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    wyang       03/19/03 - grant execute on dbms_fbt to public
Rem    wyang       02/11/03 - bug 2795827
Rem    vakrishn    10/29/02 - vakrishn_fbt_main
Rem    wyang       10/08/02 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Create type FLASHBACKTBLIST outside DBMS_FBT package to fix bug 2795827. 
-- It seems that jdbc has some problem with array type defined in package.
-- Bug 20296530- increased the length to accommodate 261 byte
CREATE OR REPLACE TYPE flashbacktblist AS VARRAY(100) of VARCHAR2(261)
/

GRANT EXECUTE ON flashbacktblist TO public
/

CREATE OR REPLACE PACKAGE dbms_fbt AUTHID CURRENT_USER IS

  -- PUBLIC TYPES

  TYPE TMPTBCURTYPE IS REF CURSOR;
 
  -- PUBLIC PROCEDURES AND FUNCTIONS
  
  PROCEDURE fbt_analyze(table_name         IN  VARCHAR2,
                        flashback_scn      IN  NUMBER,
                        tmptbcur           OUT TMPTBCURTYPE);
  PROCEDURE fbt_analyze(table_name         IN  VARCHAR2,
                        flashback_time     IN  TIMESTAMP,
                        tmptbcur           OUT TMPTBCURTYPE);
  PROCEDURE fbt_execute(table_names        IN  FLASHBACKTBLIST,
                        flashback_scn      IN  NUMBER);
  PROCEDURE fbt_execute(table_names        IN  FLASHBACKTBLIST,
                        flashback_time     IN  TIMESTAMP);
  PROCEDURE fbt_discard;
  
END; 
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_fbt FOR sys.dbms_fbt
/

GRANT EXECUTE ON dbms_fbt TO public 
/

CREATE OR REPLACE LIBRARY dbms_fbt_lib TRUSTED AS STATIC
/

@?/rdbms/admin/sqlsessend.sql
