Rem
Rem $Header: rdbms/admin/catcapit.sql /main/5 2015/08/19 11:54:50 raeburns Exp $
Rem
Rem catcapit.sql
Rem
Rem Copyright (c) 2009, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catcapit.sql - DBFS types.
Rem
Rem    DESCRIPTION
Rem      Create public types for the DBFS.
Rem
Rem    NOTES
Rem      DBFS metadata tables, packages, views, and dependents
Rem      (application-side entities like FUSE, and service-provider
Rem      entiries like SFS) require these type definitions.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catcapit.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catcapit.sql
Rem SQL_PHASE: CATCAPIT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptyps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    05/31/15 - remove OR REPLACE for types with table dependents
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    kkunchit    01/15/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql



/* ------------------------------- dbfs role ------------------------------- */
/*
 * Access to the DBFS operational and administrative API (packages, types,
 * tables, etc.) is available through the "dbfs_role". This role can be
 * granted to all users as needed.
 *
 */

create role dbfs_role;



/* ----------------------------- helper types ------------------------------ */

/*
 * Property bundles:
 *
 * The "dbms_dbfs_content_property_t" object type describes a single (name,
 * value, typecode) property tuple. All properties: standard, optional, and
 * user-defined, are described via such tuples.
 *
 * "dbms_dbfs_content_properties_t" is a variable-sized array of property
 * tuples.
 *
 * These two types are used by both the client-facing APIs and by the store
 * providers for the DBFS API.
 *
 *
 * See the definitions of "dbms_dbfs_content.property_t" and
 * "dbms_dbfs_content.properties_t" below for the PL/SQL versions of these
 * types for use in the client-facing APIs.
 *
 */

create type dbms_dbfs_content_property_t
    authid definer
as object (
    propname    varchar2(32),
    propvalue   varchar2(1024),
    typecode    integer
);
/
show errors;

create or replace public synonym dbms_dbfs_content_property_t
    for sys.dbms_dbfs_content_property_t;

grant execute on dbms_dbfs_content_property_t
    to dbfs_role;


create type dbms_dbfs_content_properties_t as
    table of dbms_dbfs_content_property_t;
/
show errors;

create or replace public synonym dbms_dbfs_content_properties_t
    for sys.dbms_dbfs_content_properties_t;

grant execute on dbms_dbfs_content_properties_t
    to dbfs_role;



/*
 * Execution context for DBFS providers.
 *
 */

create or replace type dbms_dbfs_content_context_t
    authid definer
as object (
    principal   varchar2(32),
    acl         varchar2(1024),
    owner       varchar2(32),
    asof        timestamp,
    read_only   integer
);
/
show errors;

create or replace public synonym dbms_dbfs_content_context_t
    for sys.dbms_dbfs_content_context_t;

grant execute on dbms_dbfs_content_context_t
    to dbfs_role;



/*
 * RAW data transport for batch interfaces.
 *
 */
create or replace type dbms_dbfs_content_raw_t
    as table of raw(32767);
/
show errors;

create or replace public synonym dbms_dbfs_content_raw_t
    for sys.dbms_dbfs_content_raw_t;

grant execute on dbms_dbfs_content_raw_t
    to dbfs_role;



/*
 * Directory listing helper types.
 *
 */

create type dbms_dbfs_content_list_item_t
    authid definer
as object (
    path        varchar2(1024),
    item_name   varchar2(256),
    item_type   integer
);
/
show errors;

create or replace public synonym dbms_dbfs_content_list_item_t
    for sys.dbms_dbfs_content_list_item_t;

grant execute on dbms_dbfs_content_list_item_t
    to dbfs_role;


create or replace type dbms_dbfs_content_list_items_t
    as table of dbms_dbfs_content_list_item_t;
/
show errors;

create or replace public synonym dbms_dbfs_content_list_items_t
    for sys.dbms_dbfs_content_list_items_t;

grant execute on dbms_dbfs_content_list_items_t
    to dbfs_role;




@?/rdbms/admin/sqlsessend.sql
