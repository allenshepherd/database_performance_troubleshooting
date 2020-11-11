Rem
Rem $Header: rdbms/admin/depscapi.sql /main/4 2014/02/20 12:45:54 surman Exp $
Rem
Rem depscapi.sql
Rem
Rem Copyright (c) 2009, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      depscapi.sql - DBFS content/property views
Rem
Rem    DESCRIPTION
Rem      DBFS content/property views
Rem
Rem    NOTES
Rem      Definition of "dbfs_content" and "dbfs_content_properties"
Rem      based on table functions in "dbms_dbfs_content".
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/depscapi.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/depscapi.sql
Rem SQL_PHASE: DEPSCAPI
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    kkunchit    01/15/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql



/* ---------------------- content and property views ----------------------- */

create or replace view dbfs_content
    as
    select * from table(dbms_dbfs_content.listAllContent);

create or replace public synonym dbfs_content
    for sys.dbfs_content;

grant select on dbfs_content
    to dbfs_role;


create or replace view dbfs_content_properties
    as
    select * from table(dbms_dbfs_content.listAllProperties);

create or replace public synonym dbfs_content_properties
    for sys.dbfs_content_properties;

grant select on dbfs_content_properties
    to dbfs_role;




@?/rdbms/admin/sqlsessend.sql
