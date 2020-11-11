Rem
Rem $Header: rdbms/admin/catxdbh.sql /main/13 2017/03/20 11:28:54 pyam Exp $
Rem
Rem catxdbh.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxdbh.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catxdbh.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxdbh.sql
Rem SQL_PHASE: CATXDBH
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catxdbz.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pyam        03/15/17 - 25479584: alter system -> alter session
Rem    pyam        11/17/16 - Proj 70732: clear _upgrade_optim
Rem    prthiaga    09/10/15 - Bug 21609823: Remove SHARING=NONE
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    qyu         10/08/12 - lrg7292965: add dbms_assert
Rem    lbarton     10/06/06 - bug 5371722: restore _kolfuseslf to prior value
Rem    spetride    08/28/06 - support access xdbconfig.xml.11.0
Rem    mrafiq      04/07/06 - cleaning up 
Rem    abagrawa    03/20/06 - Remove set echo on 
Rem    abagrawa    03/11/06 - Contains dbms_metadata_hack 
Rem    abagrawa    03/11/06 - Contains dbms_metadata_hack 
Rem    abagrawa    03/11/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Proj 70732: clear internal parameter _upgrade_optim so that this creation
-- of DBMS_METADATA_HACK is not treated as a no-op. This object is
-- dropped during upgrade, so we need this create replayed in PDB upgrade.
alter session set "_upgrade_optim"=FALSE;

--
-- Register XML schemas for SXML docs
-- When XDK is created by catproc.sql, this code can go into
--  dbms_metadata_util.  For now we keep it here.
--
create or replace package dbms_metadata_hack authid definer as
  procedure cre_dir;
  procedure drop_dir;
  function  get_bfile(filename varchar2) return BFILE;
  procedure load_xsd(filename varchar2,
                     gentypes1 boolean := FALSE);
  procedure deleteSchema(name varchar2);

  -- above procedures assume directory is rdbms/xml/schema
  -- following procedures are needed for rdbms/xml access
  procedure cre_xml_dir;
  procedure drop_xml_dir;
  function  get_xml_bfile(filename varchar2) return BFILE;
  function  get_xml_dirname return VARCHAR2;
  
end dbms_metadata_hack;
/
show errors

create or replace type dirnamesmh as varray(2) of varchar2(2000);
/

create or replace package body dbms_metadata_hack as
--------------------------------------------------------------------
-- PACKAGE STATE
--
kolfuseslf           VARCHAR2(4000) := 'FALSE';
XML_DIR              CONSTANT BINARY_INTEGER := 1;
SCHEMA_DIR           CONSTANT BINARY_INTEGER := 2;

RDBMS_DIR  CONSTANT DIRNAMESMH := DIRNAMESMH(NULL, 'schema'); 
LOGIC_DIR  CONSTANT DIRNAMESMH := DIRNAMESMH('XMLDIR', 'XSDDIR'); 
-- XSDDIR: schema directory name
-- XMLDIR: xml doc directory name 

-- Constants defined in rdbms/include/splatform3.h
PLATFORM_WINDOWS32    CONSTANT BINARY_INTEGER := 7;
PLATFORM_WINDOWS64    CONSTANT BINARY_INTEGER := 8;
PLATFORM_OPENVMS      CONSTANT BINARY_INTEGER := 15;

---------------------------------------------------------------------
-- GET_DIR_INT: Helper function. Return the platform-
--  specific pathname for the rdbms/xml/`subdir` directory.
-- RETURNS:
--                      - directory containing XML data/schemas

  FUNCTION get_dir_int(subdir BINARY_INTEGER) RETURN VARCHAR2 IS
    -- local variables
    pfid        NUMBER;
    root        VARCHAR2(2000);
    oraroot     VARCHAR2(2000);
BEGIN
  -- get the platform id
  SELECT platform_id INTO pfid FROM v$database;

  IF pfid = PLATFORM_OPENVMS THEN
    -- ORA_ROOT is a VMS logical name
    IF (subdir = XML_DIR) THEN
      oraroot := 'ORA_ROOT:[RDBMS.XML]';
    ELSE
       oraroot := 'ORA_ROOT:[RDBMS.XML.' || RDBMS_DIR(subdir) || ']'; 
    END IF;
    RETURN oraroot;
  ELSE
    -- Get ORACLE_HOME
    DBMS_SYSTEM.GET_ENV('ORACLE_HOME', root);
    -- Return platform-specific string
    IF pfid = PLATFORM_WINDOWS32 OR pfid = PLATFORM_WINDOWS64
    THEN
      IF (subdir = XML_DIR) THEN
        oraroot := root || '\rdbms\xml';
      ELSE
        oraroot := root || '\rdbms\xml\' || RDBMS_DIR(subdir);
      END IF;
      RETURN oraroot;
    ELSE
      IF (subdir = XML_DIR) THEN
        oraroot := root || '/rdbms/xml';
      ELSE
        oraroot := root || '/rdbms/xml/' || RDBMS_DIR(subdir);
      END IF; 
      RETURN oraroot;
    END IF;
  END IF;
END;


  FUNCTION get_schema_dir RETURN VARCHAR2 IS
    oraroot VARCHAR2(2000);
BEGIN
  oraroot := get_dir_int(SCHEMA_DIR);
  RETURN oraroot;
END;


  procedure drop_dir_int(subdir BINARY_INTEGER) is
    stmt                VARCHAR2(2000);
BEGIN
  stmt := 'DROP DIRECTORY ' || LOGIC_DIR(subdir);
  EXECUTE IMMEDIATE stmt;

  -- alter session: disable use of symbolic links
  -- (restore the variable to its prior value)
  stmt := 'ALTER SESSION SET "_kolfuseslf" = ' || 
          DBMS_ASSERT.SIMPLE_SQL_NAME(kolfuseslf);
  EXECUTE IMMEDIATE stmt;

END;

  procedure cre_dir_int(subdir BINARY_INTEGER) is
    -- local variables
    kolfuseslf_cnt      NUMBER := 0;
    dirpath             VARCHAR2(2000);
    stmt                VARCHAR2(2000);
BEGIN
  -- alter session: enable use of symbolic links
  -- first get the current value of _kolfuseslf (default FALSE)
  stmt := 'SELECT COUNT(*) FROM V$PARAMETER WHERE NAME=''_kolfuseslf''';
  EXECUTE IMMEDIATE stmt INTO kolfuseslf_cnt;
  IF kolfuseslf_cnt != 0 THEN
    stmt := 'SELECT VALUE FROM V$PARAMETER WHERE NAME=''_kolfuseslf''';
    EXECUTE IMMEDIATE stmt INTO kolfuseslf;
  END IF;
  stmt := 'ALTER SESSION SET "_kolfuseslf" = TRUE';
  EXECUTE IMMEDIATE stmt;

  -- get directory path
  dirpath := get_dir_int(subdir);

  -- create a directory object
  stmt := 'CREATE OR REPLACE DIRECTORY ' || LOGIC_DIR(subdir) || 
          ' AS ''' || dirpath || '''';
  EXECUTE IMMEDIATE stmt;

  EXCEPTION WHEN OTHERS THEN
    BEGIN
    drop_dir_int(subdir);
    RAISE;
    END;
END;



  procedure cre_dir is
BEGIN
   cre_dir_int(SCHEMA_DIR);
END;


  procedure drop_dir is
BEGIN
   drop_dir_int(SCHEMA_DIR);
END;


  function get_bfile(filename varchar2) return BFILE is
  begin
    return BFILENAME(LOGIC_DIR(SCHEMA_DIR), filename);
  end;
 

  procedure load_xsd(filename varchar2,
         gentypes1 boolean := FALSE) is
  ssfile              BFILE;
begin
  ssfile := BFILENAME(LOGIC_DIR(SCHEMA_DIR), filename);
  dbms_xmlschema.registerSchema(filename, ssfile,TRUE,gentypes1,FALSE, FALSE);
  EXCEPTION WHEN OTHERS THEN
    BEGIN
    ROLLBACK;
    drop_dir;
    RAISE;
    END;
end;
  procedure deleteSchema(name varchar2) is
  err_num NUMBER;
begin
  dbms_xmlschema.deleteSchema(name, dbms_xmlschema.DELETE_CASCADE_FORCE);
  EXCEPTION WHEN OTHERS THEN
    BEGIN
    -- suppress expected exception
    -- ORA-31000: Resource '<name>' is not an XDB schema document
    err_num := SQLCODE;
    IF err_num != -31000 THEN
      RAISE;
    END IF;
    END;
end;


---------------------------------------------------------------------
-- GET_XML_DIR: Helper function. Return the platform-
--  specific pathname for the rdbms/xml directory.
-- RETURNS:
--                      - directory containing XML docs

  FUNCTION get_xml_dir RETURN VARCHAR2 IS
    oraroot VARCHAR2(2000);
BEGIN
  oraroot := get_dir_int(XML_DIR);
  RETURN oraroot;
END;


  procedure drop_xml_dir is
BEGIN
  drop_dir_int(XML_DIR);
END;


  procedure cre_xml_dir is
BEGIN
   cre_dir_int(XML_DIR);
END;

  function get_xml_bfile(filename varchar2) return BFILE is
  begin
    return BFILENAME(LOGIC_DIR(XML_DIR), filename);
  end;

  function  get_xml_dirname return VARCHAR2 is
  begin
    return LOGIC_DIR(XML_DIR);
  end;

end dbms_metadata_hack;
/
show errors

alter session set "_upgrade_optim"=TRUE;
@?/rdbms/admin/sqlsessend.sql
