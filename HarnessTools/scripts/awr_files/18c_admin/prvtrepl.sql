Rem
Rem
Rem prvtrepl.sql
Rem
Rem Copyright (c) 2006, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      prvtrepl.sql - PRVT REPlication
Rem
Rem    DESCRIPTION
Rem      Loads replication (MV, Multi-Master and IAS) package bodies.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/prvtrepl.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/prvtrepl.sql
Rem SQL_PHASE: PRVTREPL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jorgrive    08/13/14 - Desupport Advanced Replication
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    yurxu       12/04/08 - Disable IAS
Rem    juyuan      02/12/07 - add prvtbsat
Rem    elu         11/02/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem ------------------------------------------------------------------------
Rem Snapshot (MV) package bodies
Rem ------------------------------------------------------------------------

@@prvtgen.plb
@@prvtsnap.plb
@@prvtbrmg.plb

Rem The following has been added to straighten out a dependency problem
alter package sys.dbms_snapshot compile body
/

@?/rdbms/admin/sqlsessend.sql
