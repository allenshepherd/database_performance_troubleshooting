Rem
Rem sbreport.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      sbreport.sql
Rem
Rem    DESCRIPTION
Rem      This script calls sbrepins.sql to produce standby statspack report
Rem
Rem    NOTES
Rem      Must run as the standby statspack owner, stdbyperf
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/sbreport.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/sbreport.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      02/15/07 - fix bug
Rem    wlohwass    12/04/06 - Created, based on spreport.sql


@@sbrepins

