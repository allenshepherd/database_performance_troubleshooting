Rem
Rem $Header: rdbms/admin/catshutdownpdb.sql /main/3 2017/04/27 17:09:44 raeburns Exp $
Rem
Rem catshutdownpdb.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catshutdownpdb.sql - Shut down the PDB database(s)
Rem
Rem    DESCRIPTION
Rem      Shutdown the pdb database(s) immediately.
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catshutdownpdb.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catshutdownpdb.sql
Rem    SQL_PHASE:  UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: catupgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/14/17 - Bug 25790192: Add SQL_METADATA
Rem    traney      01/14/14 - 18074131: move code from dbms_registry_sys
Rem    jerrede     08/28/12 - Shutdown the Pdb Database(s)
Rem    jerrede     08/28/12 - Created
Rem

--
-- Setup script filename variables
--
COLUMN shutdown_name NEW_VALUE shutdown_file NOPRINT;
VARIABLE shutdown_name VARCHAR2(256)                   
COLUMN :shutdown_name NEW_VALUE shutdown_file NOPRINT

--
--
-- Shutdown PDB Database(s) only
--
begin
  IF (sys.dbms_registry.is_db_pdb() = TRUE) THEN
     :shutdown_name := 'catshutdown.sql';
  ELSE
     :shutdown_name := 'nothing.sql';
  END IF;
end;
/
SELECT :shutdown_name FROM SYS.DUAL;
@@&shutdown_file
