Rem
Rem $Header: rdbms/admin/catapt.sql /main/7 2015/09/01 10:27:25 vinbhat Exp $
Rem
Rem catapt.sql
Rem
Rem Copyright (c) 2009, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catapt.sql - Archive Provider types
Rem
Rem    DESCRIPTION
Rem      creates public types for dbms_archive_provider
Rem
Rem    NOTES
Rem      
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catapt.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catapt.sql
Rem SQL_PHASE: CATAPT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptyps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vinbhat     08/24/15 - Bug 20745929: Lomg identifier support
Rem    raeburns    05/31/15 - remove OR REPLACE for types with table dependents
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    amullick    02/27/09 - fix bug8291480 - remove unnecessary types
Rem    amullick    01/27/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create type dbms_dbfs_hs_item_t
    authid definer
as object (
    storename  varchar2(ORA_MAX_NAME_LEN),
    storeowner varchar2(ORA_MAX_NAME_LEN),
    path        varchar2(1024),
    contentfilename   varchar2(1024)
);
/
show errors;

create or replace public synonym dbms_dbfs_hs_item_t
    for sys.dbms_dbfs_hs_item_t;

create or replace type dbms_dbfs_hs_litems_t
    as table of dbms_dbfs_hs_item_t;
/
show errors;

create or replace public synonym dbms_dbfs_hs_litems_t
    for sys.dbms_dbfs_hs_litems_t;

@?/rdbms/admin/sqlsessend.sql
