Rem
Rem dbms_registry_extended.sql.pp
Rem
Rem Copyright (c) 2014, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbms_registry_extended.sql.pp
Rem
Rem    DESCRIPTION
Rem      This file contains the Preupgrade SQLPLUS constants and the dbms_registry_extended 
Rem      package.
Rem
Rem      Because some of the Upgrade team's PLSQL code must execute in the very limited
Rem      UPGRADE/MIGRATE mode ("alter database open upgrade" which lacks package
Rem      standard and dbms_output among other things) the common constants
Rem      and low level definitions shared by Upgrade PLSQL code are divided into
Rem      two packages, dbms_registry_basic and dbms_registry_extended.  The former contains
Rem      definitions which are used upgrade mode, and the latter contains
Rem      any SQLPLUS constants for Preupgrade processing.
Rem
Rem      This file, contains those latter definitions.
Rem
Rem
Rem    NOTES
Rem      Since some of the low level definitions are constants which are defined
Rem      by groups outside of Upgrade, the .sql.pp source file will be preprocessed
Rem      by the build to generate a corresponding DERIVED_OBJECT .sql file by replacing
Rem      tags in the .sql.pp file with their actual values derived by the build.
Rem
Rem      The tags are **UPPER CASE** equivalents of the following strings:
Rem
Rem        ##bannerversion## - the server's version number,(high_version) i.e. 12.2.0.0.0
Rem        ##ltz_content_ver## - the timezone*.dat version number, i.e. 23
Rem        ##apex_version## - apex's version is not the same as the server's, i.e. 4.2.5.00.08
Rem
Rem      In order to keep all of the Upgrade common definitions synchronized
Rem      across the various languages used by our team, it is imperative that
Rem      the following files stay religiously in lock step with one another:
Rem      
Rem          catconst.pm.pp
Rem          tkumregistry.tsc.pp
Rem          (dbms_registry_basic.sql.pp and dbms_registry_extended.sql.pp together*)
Rem        
Rem      That means that any definition placed in one of the files should
Rem      appear in all of the files.  In as much as possible within the
Rem      conventions of each language, the object definitions should use the
Rem      exact same name, including case, as used in other files.  The
Rem      definitions should be made in the same order to facilitate debugging
Rem      and allow for quick visual comparison of the files.
Rem        
Rem      * Note: due to the limitations of running sql under
Rem      "alter database open upgrade", the definitions made in SQL have to be
Rem      split into two files: dbms_registry_basic.sql.pp and dbms_registry_extended.sql.pp.
Rem      The former contains definitions which work when the database is open
Rem      in upgrade mode, and the latter file holds all of the other
Rem      definitions which can only be accessed when in NORMAL mode.  When it
Rem      comes to ordering definitions across all four of the files above, imagine
Rem      that dbms_registry_basic.sql.pp and dbms_registry_extended.sql.pp are logically
Rem      concatenated in that order.  A definition should appear only once in
Rem      one of those two files.  That means, if you are adding a definition
Rem      that belongs at the end of dbms_registry_basic.sql.pp, there will be no
Rem      definition in dbms_registry_extended.sql.pp, and the placement of the defintion
Rem      in dbms_registry_extended.pm.pp and dbms_registry_extended.tsc.pp will appear somewhere in
Rem      the middle of those files.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbms_registry_extended.sql.pp
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbms_registry_extended.sql
Rem    SQL_PHASE: DBMS_REGISTRY_EXTENDED
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/olsdbmig.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      03/22/18 - Backport raeburns_bug-27523800 from main
Rem    raeburns    02/20/18 - Bug 27523800: move preupgrade constants to
Rem                           dbms_registry_extended
Rem    pyam        12/06/17 - Bug 27203948: don't no-op dbms_registry_extended 
Rem    raeburns    10/03/17 - Bug 26825615: Remove EXECUTE IMMEDIATE
Rem    frealvar    07/30/16 - Bug 24332006 added missing metadata
Rem    frealvar    10/22/15 - frealvar_read_only_db_state: moved functions compare_versions,
Rem                           occurs and element from preupgrade_package.sql
Rem    frealvar    09/18/15 - Added constants from catconst.pm and export support,
Rem                           changes done due to bug 21274752
Rem    ewittenb    10/29/14 - Creation
Rem

--
--    Server Version.  This is the HIGH numbered version in an upgrade/downgrade scenario
--                     and contains exactly 4 dots, i.e. 12.1.0.2.0
--                     The n-DOTS version constants can be used in upgrade situations 
--                     where the dbms_registry_extended package cannot yet be used.
--
define C_ORACLE_HIGH_VERSION_4_DOTS=18.0.0.0.0
define C_ORACLE_HIGH_VERSION_3_DOTS=18.0.0.0
define C_ORACLE_HIGH_VERSION_2_DOTS=18.0.0
define C_ORACLE_HIGH_VERSION_1_DOT=18.0
define C_ORACLE_HIGH_VERSION_0_DOTS=18

define C_ORACLE_HIGH_STATUS=Production

--
--    The version of APEX that ships with the 12.2.0.0.0 version of Oracle.
--
define C_APEX_VERSION_4_DOTS=5.1.3.00.05

--
--    Latest oracore/zoneinfo/timezone_*.dat file shipped.
--
define C_LTZ_CONTENT_VER=31

--
--    The Oracle server versions that can be directly upgraded to C_ORACLE_HIGH_VERSION_4_DOTS
--    Note the value string intentionally includes NO SPACES, making version checks easier.
--
define C_UPGRADABLE_VERSIONS=11.2.0.3,11.2.0.4,12.1.0.1,12.1.0.2,12.2.0.1

--
--    Version specific default settings for PROCESSES initialization parameter
--
define C_DEFAULT_PROCESSES=300

--
--    Minimum setting for COMPATIBLE initialization parameter
--
define C_MINIMUM_COMPATIBLE=11.2.0

--
--    min value for upgrades to 12102 (needed for APEX)
--
define C_MIN_OPEN_CURSORS=150

--    List of all the available cids that a database might have
--
--  APEX       - Oracle Application Express
--  APS        - OLAP Analytic Workspace
--  CATALOG    - Oracle Catalog Views
--  CATJAVA    - Oracle Java Packages
--  CATPROC    - Oracle Packages and Types
--  CONTEXT    - Oracle Text
--  DV         - Oracle Database Vault
--  JAVAVM     - JServer JAVA Virtual Machine
--  OLS        - Oracle Label Security
--  ORDIM      - Oracle Multimedia
--  OWM        - Oracle Workspace Manager
--  RAC        - Real Application Clusters
--  SDO        - Oracle Spatial
--  XDB        - Oracle XML Database
--  XML        - Oracle XDK for Java
--  XOQ        - Oracle OLAP API
--  ODM        - Data Mining
--  MGW        - Messaging Gateway
--  WK         - Oracle Ultra Search
--  EM         - Oracle Enterprise Manager Repository

define AVAILABE_CIDS = APEX,APS,CATALOG,CATJAVA,CATPROC,CONTEXT,DV,JAVAVM,OLS,ORDIM,OWM,RAC,SDO,XDB,XML,XOQ,ODM,MGW,WK,EM

--
--    Turn off SQLPLUS printing "Old Value: New Value:"
--
set verify off

-- Bug 27203948: do not no-op these statements because objects may exist
declare
  cnt number;
begin
  select count(*) into cnt from x$ksppi where ksppinm='_upgrade_capture_noops';
  if (cnt > 0) then
    execute immediate 'alter session set "_upgrade_capture_noops"=false';
  end if;
end;
/

--
-- Package Header
--

CREATE OR REPLACE PACKAGE dbms_registry_extended AS

    FUNCTION convert_version_to_n_dots(version IN VARCHAR2, n NUMBER) RETURN VARCHAR2;
    FUNCTION compare_versions (version1 VARCHAR2, version2 VARCHAR2) RETURN NUMBER;
    FUNCTION compare_versions (version1 VARCHAR2, version2 VARCHAR2, number_of_dots NUMBER) RETURN NUMBER;
    FUNCTION occurs (src VARCHAR2, search_string VARCHAR2) RETURN NUMBER;
    FUNCTION element(src IN VARCHAR2, delimiter IN CHAR, element_number IN NUMBER) RETURN VARCHAR2;

END dbms_registry_extended;
/

show errors;

--
--  The package body starts here
--

CREATE OR REPLACE PACKAGE BODY dbms_registry_extended AS

    FUNCTION convert_version_to_n_dots(version IN VARCHAR2, n NUMBER) RETURN VARCHAR2
    IS
        dot_count NUMBER;
        next_dot_index NUMBER;
        result_version VARCHAR2(100);
    BEGIN
        --
        --    confirm we have normal, expected parameters.  If not, return NULL
        --
        IF (version IS NULL) OR (n < 0) THEN
            RETURN null;
        END IF;

        --
        --    There is an implicit dot at the end of any passed in version
        --    that doesn't end with one already.  Make it explicit.
        --    It will get chooped off if not needed.
        --    After this IF, result_version is guaranteed to end with a dot
        --    that just makes processing easier.
        --
        result_version := version;
        IF (substr(result_version, length(result_version), 1) <> '.') THEN
            result_version := version || '.';
        END IF;

        --
        --    march through the version stopping at each successive dot
        --
        dot_count := 0;
        next_dot_index := instr(result_version, '.', 1);
        WHILE (next_dot_index > 0) LOOP
            IF (dot_count = n) THEN
                RETURN substr(result_version, 1, next_dot_index-1);
            END IF;
    
            dot_count := dot_count + 1;
            next_dot_index := instr(result_version, '.', next_dot_index + 1);
        END LOOP;

        --
        --    if we haven't returned yet, we're short of dots in the version
        --    so add more.  version 11.1 to 3 dots would become 11.1.0.0
        --
        --    earlier in this routine, we forced result_version to always end with "."
        --
        result_version := result_version || '0';
        WHILE (dot_count < n) LOOP
            result_version := result_version || '.0';
            dot_count := dot_count + 1;
        END LOOP;

        return result_version;
    END convert_version_to_n_dots;

    --
    --    This function returns the following values:
    --    throws exception if one of the versions has an invalid format
    --    or if the versions do not contain the same number of dots.
    --    if you need to convert one or more versions to a specified
    --    number of dots, use dbms_registry_extended.convert_version_to_n_dots()
    --    or try compare_versions with three parameters.
    --
    --    -1 : version1 < version2
    --     0 : version1 = version2
    --    +1 : version1 > version2
    --
    FUNCTION compare_versions (version1 VARCHAR2, version2 VARCHAR2) RETURN NUMBER
    IS
        dots NUMBER;
        element_number NUMBER;
        v1_val NUMBER;
        v2_val NUMBER;
    BEGIN
        dots := occurs(version1, '.');
        
        --
        --    The versions must both contain only digits and '.'s
        --    and the number of dots must be the same in both versions.
        --
        IF (LENGTH(REGEXP_SUBSTR(version1, '[0123456789.]*', 1)) < LENGTH(version1)) OR
           (LENGTH(REGEXP_SUBSTR(version2, '[0123456789.]*', 1)) < LENGTH(version2)) OR
           (occurs(version2, '.') <> dots) THEN
            RAISE_APPLICATION_ERROR (-20000,
                     'Invalid version comparison ' ||
                         ' version1=' || version1 ||
                         ' version2=' || version2);
        ELSE
            FOR element_number IN 1..dots+1 LOOP
                v1_val := to_number(element(version1, '.', element_number));
                v2_val := to_number(element(version2, '.', element_number));
            
                IF (v1_val > v2_val) THEN
                    RETURN 1;
                ELSE
                    IF (v1_val < v2_val) THEN
                        RETURN -1;
                    ELSE
                        NULL;  -- if the values are the same, continue to compare the next digits
                    END IF;
                END IF;
            END LOOP;
        END IF;
    
        RETURN 0;    -- strings must be equal
    END compare_versions;
    
    --
    -- Function to compare database versions which contains a given number of points
    -- and can return one of the following values
    --
    --    -1 : version1 < version2
    --     0 : version1 = version2
    --    +1 : version1 > version2
    --
    FUNCTION compare_versions(version1 VARCHAR2, version2 VARCHAR2, number_of_dots NUMBER) RETURN NUMBER
    IS
    BEGIN
        RETURN compare_versions( dbms_registry_extended.convert_version_to_n_dots(version1, number_of_dots),
                                 dbms_registry_extended.convert_version_to_n_dots(version2, number_of_dots) );
    END compare_versions;
    
    --
    -- This function looks for the number of apparitions of search_string in src
    -- and return the values a number
    --
    FUNCTION occurs(src VARCHAR2, search_string VARCHAR2) RETURN NUMBER
    IS
        total     NUMBER := 0;
        src_index NUMBER := 1;
        search_string_length NUMBER;
    BEGIN
        search_string_length := length(search_string);
        src_index := instr(src, search_string, src_index);
        while (src_index <> 0) LOOP
            total := total + 1;
            src_index := instr(src, search_string, src_index + search_string_length);
        END LOOP;
        RETURN total;
    END occurs;

    --
    -- This function returns a given element from a string
    -- if src=a.b.c.d.e and delimiter=. and element_number=2
    -- the function will return b
    -- if src=a.b.c.d.e and delimiter=. and element_number=4
    -- the function will return d
    -- The first element_number is element # 1, not 0.
    --
    -- If element_number < 0 return delimiter
    -- 
    FUNCTION element(src IN VARCHAR2, delimiter IN CHAR, element_number IN NUMBER) RETURN VARCHAR2
    IS
        start_index NUMBER := 0;
        end_index   NUMBER := 0;
    BEGIN
        IF (src IS NULL) OR (element_number < 1) THEN
            return delimiter;
        END IF;
    
        IF (element_number = 1) THEN
            start_index := 0;
        ELSE
            start_index := instr(src, delimiter, 1, element_number-1);
            IF (start_index = 0) THEN
                RETURN delimiter;
            END IF;
        END IF;
    
        end_index := instr(src, delimiter, start_index + 1);
        IF (end_index = 0) THEN
            RETURN substr(src, start_index+1);
        END IF;
    
        RETURN substr(src, start_index+1, end_index-start_index-1);
    END element;

END dbms_registry_extended;
/

-- Bug 27203948: reset parameter
declare
  cnt number;
begin
  select count(*) into cnt from x$ksppi where ksppinm='_upgrade_capture_noops';
  if (cnt > 0) then
    execute immediate 'alter session set "_upgrade_capture_noops"=true';
  end if;
end;
/

show errors;

