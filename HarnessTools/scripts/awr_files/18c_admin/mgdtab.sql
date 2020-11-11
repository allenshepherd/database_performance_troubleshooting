Rem
Rem $Header: rdbms/admin/mgdtab.sql /main/9 2017/05/28 22:46:07 stanaya Exp $
Rem
Rem mgdtab.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      mgdtab.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/mgdtab.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/mgdtab.sql
Rem    SQL_PHASE: MGDTAB
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       03/02/16 - add call to sqlsessstart and sqlsessend
Rem    hgong       03/31/15 - bug 20746710 support 128 bytes
Rem    hgong       01/17/13 - create table to store a local version of
Rem                           ManagerTranslation.xml
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    hgong       06/29/06 - add comments 
Rem    hgong       04/04/06 - rename oidcode.jar 
Rem    hgong       03/31/06 - create metadata tables 
Rem    hgong       03/31/06 - create metadata tables 
Rem    hgong       03/31/06 - Created
Rem

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessstart.sql
Rem ********************************************************************

prompt .. Creating mgd_id_xml_validator table
create table mgd_id_xml_validator(
   xsd_schema           clob                   -- xml validator 
);
COMMENT ON TABLE mgd_id_xml_validator IS
'Oracle tag data translation schema table. This is a single column, single row table that stores the CLOB of Oracle TDT schema.'
/
COMMENT ON COLUMN mgd_id_xml_validator.xsd_schema IS
'Oracle tag data translation schema'
/

prompt .. Creating the mgd_id_category_tab table
create table mgd_id_category_tab(
  owner         VARCHAR2(128)
        default sys_context('userenv', 'CURRENT_USER'),
  category_id   number(4),
  category_name varchar2(256) not null,
  version    varchar2(256),
  agency     varchar2(256),  
  URI        varchar2(256),
  constraint mgd_id_category_tab$pk primary key (owner,category_id),
  constraint mgd_id_category_tab$uq unique (owner, category_name, version)
);
COMMENT ON TABLE mgd_id_category_tab IS
'Encoding category table'
/
COMMENT ON COLUMN mgd_id_category_tab.owner IS
'Database user who created the category'
/
COMMENT ON COLUMN mgd_id_category_tab.category_id IS
'Category ID'
/
COMMENT ON COLUMN mgd_id_category_tab.category_name IS
'Category name'
/
COMMENT ON COLUMN mgd_id_category_tab.version IS
'Category version'
/
COMMENT ON COLUMN mgd_id_category_tab.agency IS
'Organization who defined the category'
/
COMMENT ON COLUMN mgd_id_category_tab.URI IS
'URI that describes the category'
/

/* Should we store XML as CLOB or XML type?
   http://www.oracle.com/technology/oramag/oracle/03-jul/o43xml.html#t1
   If we preload into the JAVA objects, we only read the XML once, so there is no
   requiremend for good data manipulation language (DML) performance - might as well
   store as CLOB. */
prompt .. Creating mgd_id_scheme_tab table
           create table mgd_id_scheme_tab(
   owner             varchar2(128)
        default sys_context('userenv', 'CURRENT_USER'),
   category_id       number(4), 
   type_name         varchar2(256) not null,
   tdt_xml           clob,          
   encodings         varchar2(256), 
   components        varchar2(1024),
   CONSTRAINT mgd_id_scheme_tab$pk primary key (owner, category_id, type_name),
   CONSTRAINT mgd_id_scheme_tab$fk FOREIGN KEY (owner, category_id) 
      REFERENCES mgd_id_category_tab(owner, category_id) ON DELETE CASCADE
);

COMMENT ON TABLE mgd_id_scheme_tab IS
'Encoding scheme table'
/
COMMENT ON COLUMN mgd_id_scheme_tab.owner IS
'Database user who created the scheme'
/
COMMENT ON COLUMN mgd_id_scheme_tab.category_id IS
'Category ID'
/
COMMENT ON COLUMN mgd_id_scheme_tab.type_name IS
'Encoding scheme name, e.g., SGTIN-96, GID-96, etc.'
/
COMMENT ON COLUMN mgd_id_scheme_tab.tdt_xml IS
'Tag data translation xml for this encoding scheme'
/
COMMENT ON COLUMN mgd_id_scheme_tab.encodings IS
'Encodings separated by '','', e.g., ''LEGACY,TAG_ENCODING,PURE_IDENTITY,BINARY'' for SGTIN-96'
/
COMMENT ON COLUMN mgd_id_scheme_tab.components IS
'Relevant component names, extracted from each level and then combined. The component names are separated by '','', e.g., ''objectclass,generalmanager,serial'' for GID-96'
/

prompt .. Creating mgd_id_lookup_table table
create table mgd_id_lookup_table(
   url               varchar2(1024),
   content           clob,
   use_local         varchar2(1),
   CONSTRAINT mgd_id_lookup$pk primary key (url)
); 
COMMENT ON TABLE mgd_id_lookup_table IS
'Oracle tag data translation lookup tables, which stores a backup version of the look up tables at the given URL, such as that of ManagerTranslation.xml'
/
COMMENT ON COLUMN mgd_id_lookup_table.url IS
'Table URL'
/
COMMENT ON COLUMN mgd_id_lookup_table.content IS
'Table content'
/
COMMENT ON COLUMN mgd_id_lookup_table.use_local IS
'Whether to use this local copy of the content for the given table URL, Y or N'
/

create sequence mgd$sequence_category;

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessend.sql
Rem ********************************************************************

