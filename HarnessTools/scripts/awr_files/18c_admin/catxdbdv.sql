Rem
Rem $Header: rdbms/admin/catxdbdv.sql /main/8 2014/02/20 12:46:27 surman Exp $
Rem
Rem catxdbdv.sql
Rem
Rem Copyright (c) 2003, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxdbdv.sql - CATalog XDB Dummy Views
Rem
Rem    DESCRIPTION
Rem      Dummy XDB views for ALL_OBJECTS
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catxdbdv.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxdbdv.sql
Rem SQL_PHASE: CATXDBDV
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cdstrt.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    atabar      02/16/12 - 8368788: wrap xml_schema_name_present
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    badeoti     10/09/08 - update all_xml_schemas def to 11.1
Rem    najain      12/08/03 - added package xml_schema_name_present
Rem    njalali     05/12/03 - added all_xml_schemas2
Rem    abagrawa    04/02/03 - abagrawa_catalog_view_schema_fixes
Rem    abagrawa    03/12/03 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace force view ALL_XML_SCHEMAS
 (OWNER, SCHEMA_URL, LOCAL, SCHEMA, INT_OBJNAME, QUAL_SCHEMA_URL, HIER_TYPE, BINARY, SCHEMA_ID, HIDDEN, DUMMY_DEFINITION) 
 as select null, null, null, null, null, null, null, null, null, null, null from dual where 1=0; 

Rem We want ALL_OBJECTS to depend on ALL_XML_SCHEMAS, but XMLTYPE is not
Rem available when ALL_OBJECTS is created.  For this reason, we create
Rem a version of ALL_XML_SCHEMAS we call ALL_XML_SCHEMAS2 that doesn't 
Rem require the presence of XMLTYPE.  Here we make a dummy version of
Rem the view, and later, after ALL_OBJECTS is created, we redefine the
Rem view in catxdbv.sql.  Since we don't want ALL_OBJECTS to become
Rem invalidated as a result of our recreating ALL_XML_SCHEMAS2, we
Rem cast all the "dummy" values to the final VARCHAR2 types that we get
Rem when the view is created for real.

create or replace force view ALL_XML_SCHEMAS2
 (OWNER, SCHEMA_URL, LOCAL, INT_OBJNAME, QUAL_SCHEMA_URL) 
 as select
    CAST('A' AS VARCHAR2(128)), 
    CAST('B' AS VARCHAR2(700)),
    CAST('C' AS VARCHAR2(3)),
    CAST('D' AS VARCHAR2(4000)),
    CAST('E' AS VARCHAR2(767)) from dual where 1=0; 


Rem ALL_OBJECTS depends on ALL_XML_SCHEMAS2, which gets recreated if XDB is
Rem installed. Remove this dependency, and redefine ALL_OBJECTS to depend
Rem on the function xml_schema_name_present instead. Note that once 3234025 
Rem is fixed, the package xml_schema_name_present can be removed. Also 
Rem while upgrading, xdb schema objects may be present, but xdb may not be
Rem installed. The reaon xml_schema_name_present is a function is that the 
Rem package body can be recreated without any invalidations.

@@prvtxschnp.plb


@?/rdbms/admin/sqlsessend.sql
