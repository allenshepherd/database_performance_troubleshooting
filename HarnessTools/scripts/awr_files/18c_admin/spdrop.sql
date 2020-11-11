Rem
Rem $Header: rdbms/admin/spdrop.sql /main/5 2017/05/28 22:46:10 stanaya Exp $
Rem
Rem spdrop.sql
Rem
Rem Copyright (c) 1999, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      spdrop.sql
Rem
Rem    DESCRIPTION
Rem	 SQL*PLUS command file drop user, tables and package for
Rem	 performance diagnostic tool STATSPACK
Rem
Rem    NOTES
Rem	 Note the script connects INTERNAL and so must be run from
Rem	 an account which is able to connect internal.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/spdrop.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/spdrop.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    kchou       01/12/17 - Bug# 25233027 - Set _oracle_script=FALSE at the
Rem                           end
Rem    cdialeri    05/03/00 - 1261813
Rem    cdialeri    02/16/00 - 1191805
Rem    cdialeri    08/13/99 - Drops entire STATSPACK environment
Rem    cdialeri    08/13/99 - Created
Rem

-- Bug#25233027: xxx Set this parameter for creating common objects in consolidated database
alter session set "_oracle_script" = TRUE;

--
--  Drop PERFSTAT's tables and indexes

@@spdtab


--
--  Drop PERFSTAT user

@@spdusr

-- Bug#25233027: xxx Set this parameter to FALSE for creating common objects in consolidated database
alter session set "_oracle_script" = FALSE;

