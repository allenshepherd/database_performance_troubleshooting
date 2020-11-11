Rem
Rem $Header: emll/admin/scripts/prvtocm.sql /main/2 2014/02/20 12:44:06 surman Exp $
Rem
Rem prvtocm.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      prvtocm.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: emll/admin/scripts/prvtocm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/prvtocm.sql
Rem SQL_PHASE: PRVTOCM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/15/14 - 13922626: Update SQL metadata
Rem    dkapoor     05/31/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem The package bodies
@@ocmdbb.sql
@@ocmjb10.sql

@?/rdbms/admin/sqlsessend.sql
