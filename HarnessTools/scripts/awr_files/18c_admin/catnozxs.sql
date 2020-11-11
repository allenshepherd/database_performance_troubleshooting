Rem
Rem $Header: rdbms/admin/catnozxs.sql /main/7 2017/05/28 22:46:03 stanaya Exp $
Rem
Rem catnozxs.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnozxs.sql - for removing (NO) XS
Rem
Rem    DESCRIPTION
Rem      This script is invoked at the beginning of catnoqm.sql
Rem
Rem    NOTES
Rem      Schema tables are deleted in catnoqm.sql. All objects are under 'SYS'
Rem      unless qualified with a different schema.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnozxs.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnozxs.sql
Rem    SQL_PHASE: CATNOZXS
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    minx        10/25/12 - deprecated
Rem    minx        03/25/12 - XS Cleanup
Rem    rpang       02/02/12 - Network ACL triton migration
Rem    yiru        05/09/10 - Full Drop6R cleanup before merge-down
Rem    snadhika    04/14/10 - Remove PREDICATE xmlindex
Rem    yiru        03/25/09 - Created
Rem
