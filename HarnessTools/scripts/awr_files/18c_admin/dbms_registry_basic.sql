Rem
Rem dbms_registry_basic.sql.pp
Rem
Rem Copyright (c) 2014, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbms_registry_basic.sql.pp and dbms_registry_basic.sql
Rem
Rem    DESCRIPTION
Rem      This file contains SQLPLUS constants for use by Upgrade and Downgrade.
Rem
Rem      Because some of the Upgrade team's PLSQL code must execute in the very limited
Rem      UPGRADE/MIGRATE mode ("alter database open upgrade" which lacks package
Rem      standard and dbms_output among other things) the SQLPLUS constants
Rem      and low level functions shared by Upgrade PLSQL code are divided into
Rem      two packages, dbms_registry_basic and dbms_registry_extended.  The former contains
Rem      definitions which are acceptable in upgrade mode, and the latter contains
Rem      any constants and functions for use by Preupgrade.
Rem
Rem      This file, contains those former, "basic" server-related SQLPLUS constants.
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
Rem        ##bannnerversionfull## - the server's full RU version (i.e., 18.3.2.0.0)
Rem        ##banner_status## - the server's version status, i.e., Production
Rem
Rem        In order to keep all of the Upgrade common definitions synchronized
Rem        across the various languages used by our team, it is imperative that
Rem        the following files stay religiously in lock step with one another:
Rem        
Rem            catconst.pm.pp
Rem            tkumregistry.tsc.pp
Rem            (dbms_registry_basic.sql.pp and dbms_registry_extended.sql.pp together*)
Rem        
Rem        That means that any definition placed in one of the files should
Rem        appear in all of the files.  In as much as possible within the
Rem        conventions of each language, the object definitions should use the
Rem        exact same name, including case, as used in other files.  The
Rem        definitions should be made in the same order to facilitate debugging
Rem        and allow for quick visual comparison of the files.
Rem        
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbms_registry_basic.sql.pp
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbms_registry_basic.sql
Rem    SQL_PHASE: DBMS_REGISTRY_BASIC
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catupstr.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      03/22/18 - Backport raeburns_bug-27523800 from main
Rem    raeburns    02/20/18 - Bug 27523800: move preupgrade constants to
Rem                           dbms_registry_extended
Rem    sshringa    09/08/17 - Adding start/end markers for rti-20225108
Rem    raeburns    08/28/17 - Bug 26255427: add RU constants
Rem    sshringa    08/04/17 - adding sql start/end markers
Rem    frealvar    01/25/17 - Bug 25385743 adding 12201 as supported version
Rem    raeburns    08/16/16 - Bug 24709706 Add 0,1,2,3-dot variables 
Rem    frealvar    07/30/16 - Bug 24332006 added missing metadata
Rem    raeburns    06/27/16 - Add BANNER_STATUS
Rem    ewittenb    10/29/14 - Creation
Rem

@?/rdbms/admin/sqlsessstart.sql

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

--    Server RU version  The VERSIONFULL constant is the full 5 numbers, the other
--                       constants are the individual numbers for 
--                            major version, 
--                            release update,
--                            release update revision, 
--                            release update increment, 
--                            and unused (next)
--  

define C_ORACLE_HIGH_VERSIONFULL=18.3.1.0.0
define C_ORACLE_HIGH_MAJ=18
define C_ORACLE_HIGH_RU=3
define C_ORACLE_HIGH_RUR=1
define C_ORACLE_HIGH_INC=0
define C_ORACLE_HIGH_NEXT=0

--
--    Server Status (Production, Dev, Beta, etc.)
--

define C_ORACLE_HIGH_STATUS=Production

--
--    Latest oracore/zoneinfo/timezone_*.dat file shipped (in dbms_registry_extended as well)
--    

define C_LTZ_CONTENT_VER=31


@?/rdbms/admin/sqlsessend.sql
