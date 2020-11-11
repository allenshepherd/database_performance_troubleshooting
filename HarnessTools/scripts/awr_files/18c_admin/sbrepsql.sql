Rem
Rem $Header: rdbms/admin/sbrepsql.sql /main/2 2017/05/28 22:46:09 stanaya Exp $
Rem
Rem sbrepsql.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      sbrepsql.sql - StandBy statspack REPort SQL
Rem
Rem    DESCRIPTION
Rem      This script calls sprsqins.sql to produce
Rem      the standard standby Statspack SQL report.
Rem
Rem    NOTES
Rem      Usually run as the STDBYPERF user
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/sbrepsql.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/sbrepsql.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      09/15/09 - Created
Rem

@@sbrsqins

--
-- End of file



