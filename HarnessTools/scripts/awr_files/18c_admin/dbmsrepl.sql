Rem
Rem $Header: rdbms/admin/dbmsrepl.sql /main/6 2015/04/12 11:36:35 jorgrive Exp $
Rem
Rem dbmsrepl.sql
Rem
Rem Copyright (c) 2006, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsrepl.sql - DBMS REPLication package headers.
Rem
Rem    DESCRIPTION
Rem      Load Replication (MV, Multi-Master, and IAS) package headers.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsrepl.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsrepl.sql
Rem SQL_PHASE: DBMSREPL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jorgrive    08/13/14 - Desupport Advanced Replication
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    yurxu       12/04/08 - Disable IAS
Rem    elu         11/02/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem --------------------------------------------------------------------------
Rem Snapshot (MV) package headers
Rem --------------------------------------------------------------------------

@@prvthitr.plb
@@prvtsnps.plb
@@dbmshrmg.sql
@@dbmsgen.sql

@?/rdbms/admin/sqlsessend.sql
