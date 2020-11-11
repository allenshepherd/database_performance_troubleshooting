Rem
Rem $Header: rdbms/admin/xdbload.sql /main/15 2017/05/26 05:12:29 raeburns Exp $
Rem
Rem xdbload.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbload.sql - XDB LoaD
Rem
Rem    DESCRIPTION
Rem      Loads new versions of XDB views, packages, and type bodies
Rem
Rem    NOTES
Rem      Used by the XDB upgrade (xdbupgrd.sql) and XDB downgrade 
Rem      reload (xdbrelod.sql) scripts.
Rem
Rem      This script does not change the contents of the XDB
Rem      entry in the component registry; the invoking script
Rem      must update the registry appropriatly.
Rem
Rem      The script includes annotations for CATCTL parallel
Rem      processing.  Currently only the XDB upgrade uses
Rem      parallel processing. xdbupgrd.sql is invoked from
Rem      cmpupgrd.sql with the "-CP XDB -X" annotation where the -X
Rem      indicates that xdbupgrd.sql contains CATCTL annotations for
Rem      parallel processing.  In turn, xdbupgrd.sql invokes this
Rem      script, xdbload.sql, with the -X option, so that the
Rem      CATCTL annotations in this script will be processed
Rem      by catctl.pl during an upgrade. 
Rem
Rem            -S runs the subsequent scripts in a SINGLE process
Rem            -M runs the subsequent scripts using Multiple processes
Rem            -CS Starts _load_without_compile for package/type bodies
Rem            -CE Ends _load_without_compile
Rem
Rem      When this xdbload.sql script is run with sqlplus, not 
Rem      catctl.pl, all of the CATCTL annotations are treated 
Rem      as comments.
Rem
Rem      The _ORACLE_SCRIPT parameter must be set in the invoking
Rem      script and/or in the XDB scripts included in the subscripts.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbload.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbload.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbrelod.sql
Rem    SQL_CALLING_FILE: rdbms/admin/xdbupgrd.sql
Rem    SQL_DRIVER_ONLY: YES
Rem    END SQL_FILE_METADATA
Rem
Rem    USAGE NOTE:
Rem        DO NOT USE SLASHES in the -- comments on the @@ lines!
Rem        There is a bug in SQLPLUS (19524303) that will cause the 
Rem        file to not be found if there are slashes in the comment!
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    05/14/17 - Bug 25906282: Use SQL_DRIVER_ONLY
Rem    raeburns    04/15/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    prthiaga    03/15/17 - Fix for RTI 20165165
Rem    prthiaga    02/17/17 - Bug 25577443: PL/SQL SODA Upgrade
Rem    dmelinge    02/15/16 - Dependency problem, bug 22660684
Rem    rpang       11/13/15 - Move EPG to catxrd.sql
Rem    prthiaga    10/23/15 - Bug 22067651: Add DBMS_SODA_DOM pkg
Rem    raeburns    06/20/15 - Change order to remove deadlocks
Rem    prthiaga    05/19/15 - Bug 21116398: Enable Upgrade of SODA APIs
Rem    yinlu       01/07/15 - add dbms_json package
Rem    raeburns    10/30/14 - break out interdependent scripts
Rem    raeburns    09/30/14 - move dbmsxsch.sql
Rem    prthiaga    09/29/14 - Bug 19680796: Temporarily comment out SODA APIs
Rem    prthiaga    09/17/14 - Bug 19317646: PL/SQL Collection API
Rem    raeburns    06/20/14 - xdbrelod.sql restructure
Rem    raeburns    06/20/14 - Created
Rem

Rem ================================================================
Rem BEGIN XDB Load Views, Packages, Package Bodies, and Type Bodies
Rem ================================================================

-- PHASE 1 Create objects necessary for subsequent scripts
-- dbmsxres depends on dbmsxmlu, cannot do dbmsxmlu in phase 2, bug 22660684
--CATCTL -S

@@dbmsxmlt.sql    -- XMLTYPE
@@dbmsxmlu.sql    -- utl STREAM types (dbmsxmls.sql depends on utl_ types)
@@dbmsxmld.sql    -- DBMS_XMLDOM (used by many several other dbms scripts)

-- PHASE 2 Load package specifications with dependents
--CATCTL -M

@@dbmsxmlp.sql    -- DBMS_XMLPARSER (depends on DBMS_XMLDOM)
@@catxtbix.sql    -- XMLTableIndex
@@catxidx.sql     -- XMLINDEX types and packages
@@catsodaview.sql -- SODA Collecton API views
@@catxdbpi.sql    -- Path Index (uses XMLType)
@@dbmsxsch.sql    -- DBMS_XML_SCHEMA (dependent on XMLTYPE)
@@dbmsxres.sql    -- DBMS_XDBResource 
@@dbmsxdbz.sql    -- security packages
@@prvtxdb0.plb    -- utility packages (DBMS_XDBUTIL_INT, DBMS_CSX_INT, more)

-- PHASE 3 Load package specifications without dependents
--CATCTL -M

@@dbmsxdb.sql      -- DBMS_XDB (references DBMS_XDBRESOURCE, needed by other scripts)
@@dbmsxutil.sql    -- XDB Manageabilty packages
@@dbmsxrc.sql      -- DBMS_RESCONFIG package
@@dbmsxdbc.sql     -- XDB utilities 
@@dbmsxdba.sql     -- DBMS_XDB_ADMIN package 
@@dbmsxreg.sql     -- XDB registry package and validation procedure
@@dbmsxschlsb.sql  -- DBMS_XMLSCHEMA_LSB package
@@dbmsxlsb.sql     -- DBMS_XLSB package
@@dbmsxdbrepos.sql -- DBMS_XDBREPOS package
@@dbmsxtr.sql      -- DBMS_XMLTRANSLATIONS package
@@dbmsxidx.sql     -- DBMS_XMLINDEX
@@dbmsxvr.sql      -- DBMS_XDB_VERSION package
@@dbmsxmls.sql     -- STREAM types
@@catxdbh.sql      -- DBMS_METADATA_HACK package and package body
@@dbmsxdbdt.sql    -- xdb$ExtName2IntName
@@dbmsxslp.sql     -- DBMS_XSLPROCESSOR (depends on DBMS_XMLDOM)
@@prvtxdr0.plb     -- XDB_FUNCIMPL, Resource View
@@dbmsxev.sql      -- DBMS_XEVENT package (uses DBMS_XDBRESOURCE)
@@prvtxdz0.plb     -- XDB Security modules (is_vpd_enabled, get_table_name, isXMLTypeTable)
@@prvtxsch0.plb    -- DBMS_XMLSCHEMA_INT
@@dbmsjson.sql     -- DBMS_JSON package
@@dbmssodacoll.sql -- DBMS_SODA_ADMIN Package Specification
@@dbmssodadom.sql  -- DBMS_SODA_DOM Package Specification
@@dbmssodautil.sql -- SYS.DBMS_SODA_UTIL package Specification
@@dbmssodapls.sql  -- SYS.DBMS_SODA and SODA Types Specification

-- PHASE 4 Load packages and views with forward/backward dependencies
--CATCTL -S

@@dbmsxdbr.sql     -- DBMS_XDB_REPOS (references dbms_xdb and dbms_xdbresource)
@@catxdbr.sql      -- RESOURCE_VIEW and operators (depends on XDB_FUNCIMPL)
@@catxdbv.sql      -- XDB views (uses dbms_csx_int, views need for package bodies)
@@catvxutil.sql    -- XDB Manageabilty views (depends on catxdbv views, prvtxutil needs))

-- PHASE 5 Load package and type bodies  
-- Turn off compiles, load in single process
--CATCTL -CS
--CATCTL -S

@@prvtxsch.plb        -- DBMS_XMLSCHEMA 
@@prvtxdbr.plb        -- XDB_FUNCIMPL, XDB_RVTRIG_PKG, UNDER_PATH_FUNC
@@prvtxslp.plb        -- CLOB utility and DBMS_XSLPROCESSOR body
@@prvtxdbz.plb        -- DBMS_XDBZ0, DBMS_XDBZ
@@prvtxmlt.plb        -- XMLTYPE
@@prvtxutil.plb       -- XDB Manageabilty packages
@@prvtxrc.plb         -- DBMS_RESCONFIG package
@@prvtxres.plb        -- DBMS_XDBResource 
@@prvtxdbdl.plb       -- Document Link trigger
@@prvtxdb.plb         -- DBMS_XDB
@@prvtxdba.plb        -- DBMS_CSX_ADMIN
@@prvtxreg.plb        -- XDB registry package
@@prvtxdbp.plb        -- XDB Path Index
@@prvtxschlsb.plb     -- DBMS_XMLSCHEMA_LSB package
@@prvtxlsb.plb        -- DBMS_XLSB package
@@prvtxdbrepos.plb    -- DBMS_XDBREPOS package
@@prvtxev.plb         -- DBMS_XEVENT package
@@prvtxtr.plb         -- DBMS_XMLTRANSLATIONS package
@@prvtxidx.plb        -- DBMS_XMLINDEX package
@@prvtxmlstreams.plb  -- XML STREAM types
@@prvtxmld.plb        -- DBMS_XMLDOM
@@prvtxmlp.plb        -- DBMS_XMLPARSER
@@prvtxsch.plb        -- DBMS_XMLSCHEMA
@@prvtxsfsclient.plb  -- DBMS_XDB_CONTENT package
@@prvtxschnpb.plb     -- XML_SCHEMA_NAME_PRESENT package
@@prvtjson.plb        -- DBMS_JSON package
@@prvtsodautil.plb    -- SYS.DBMS_SODA_UTIL package 
@@prvtsodadml.plb     -- XDB.DBMS_SODA_DML package
@@prvtsodacoll.plb    -- XDB.DBMS_SODA_ADMIN package
@@prvtsodadom.plb     -- XDB.DBMS_SODA_DOM package
@@prvtsodapls.plb     -- SYS.DBMS_SODA package and SODA Types 

-- Turn compile back on
--CATCTL -CE

-- PHASE 6 Post load operations using loaded packages and views
--CATCTL -M

@@catxdbpv.sql    -- PATH VIEW
@@catxdbeo.sql    -- Extensible optimizer 
@@xdbinstd.sql    -- XDB Digest Authentication
@@catxdbapp.sql   -- Application User Views (uses DBMS_XDBZ)
@@catxdbdl.sql    -- Document Link Views (uses DBMS_XMLSCHEMA)
@@catxdbz1.sql    -- Security Views (uses DBMS_CSX_INT)

-- PHASE 7 End of reload operations
--CATCTL -S

@@catmetx.sql     -- Metadata API views (causes hangs and deadlocks if run earlier)
@@xdbloadend.sql  -- Final actions 

Rem ================================================================
Rem END Load Views, Packages, Package Bodies, and Type Bodies
Rem ================================================================
