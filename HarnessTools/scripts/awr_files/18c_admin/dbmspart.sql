Rem
Rem $Header: rdbms/admin/dbmspart.sql /main/6 2016/10/12 02:15:41 geadon Exp $
Rem
Rem dbmspart.sql
Rem
Rem Copyright (c) 2011, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmspart.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmspart.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmspart.sql
Rem SQL_PHASE: DBMSPART
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    geadon      09/16/16 - bug 24515918: add parameters for global idx
Rem                           cleanup
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    sasounda    09/13/12 - 14621938: procedure to cleanup failed online move
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    geadon      10/21/11 - cleanup_gidx signature change
Rem    geadon      09/08/11 - DBMS_PART package
Rem    geadon      09/08/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package dbms_part authid current_user as

  procedure cleanup_gidx(schema_name_in varchar2 default null,
                         table_name_in  varchar2 default null,
                         parallel       varchar2 default '0',
                         options        varchar2 default 'CLEANUP_ORPHANS');

  procedure cleanup_gidx_job(parallel       varchar2 default '0',
                             options        varchar2 default 'CLEANUP_ORPHANS');

  procedure cleanup_online_op(
    schema_name    in varchar2 default null,
    table_name     in varchar2 default null,
    partition_name in varchar2 default null);

end dbms_part;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_part FOR dbms_part
/

GRANT EXECUTE ON dbms_part TO public
/

-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_PART_LIB TRUSTED AS STATIC;
/

@?/rdbms/admin/sqlsessend.sql
