Rem
Rem $Header: rdbms/admin/dbmsgwm.sql /main/10 2016/11/24 09:04:25 dcolello Exp $
Rem
Rem dbmsgwm.sql
Rem
Rem Copyright (c) 2011, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsgwm.sql - Global Workload Management
Rem
Rem    DESCRIPTION
Rem      Loads package specifications for GSM that should be installed on
Rem      every database.
Rem
Rem    NOTES
Rem      
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsgwm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsgwm.sql
Rem SQL_PHASE: DBMSGWM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dcolello    11/19/16 - child scripts handle setting schema
Rem    dcolello    03/08/16 - Add fixed package dbmsgwmfx.sql
Rem    sdball      03/17/14 - Add fixed package dbmsgwmfix.sql
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    lenovak     07/29/13 - shard support
Rem    sdball      05/02/13 - switch ordering because of dependencies
Rem    nbenadja    02/21/13 - Add dbmsgwmalt.sql file.
Rem    sdball      03/12/12 - Include catalog packages in all databases
Rem    nbenadja    11/28/11 - include prvtgwmut.sql
Rem    mjstewar    04/27/11 - Second GSM transaction
Rem    mjstewar    02/23/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

--***********************************
-- Install GSM Package Specifications
--***********************************

-- the following scripts will be run in
--   the GSMADMIN_INTERNAL schema
-- each script is responsible for setting
--   and resetting the schema correctly.
@@dbmsgwmco.sql
@@dbmsgwmut.sql
@@dbmsgwmdb.sql
@@dbmsgwmpl.sql
@@dbmsgwmcl.sql
@@dbmsgwmalt.sql

-- the following scripts will be run in
--   the SYS schema
@@dbmsgwmfx.sql
@@dbmsgwmfix.sql

@?/rdbms/admin/sqlsessend.sql
