Rem
Rem $Header: rdbms/admin/awrgrpt.sql /main/6 2017/05/28 22:46:00 stanaya Exp $
Rem
Rem awrgrpt.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      awrgrpt.sql - AWR Global Report 
Rem
Rem    DESCRIPTION
Rem      This script defaults the dbid to that of the
Rem      current instance connected-to, then calls awrgrpti.sql to produce
Rem      the Workload Repository RAC report.
Rem
Rem    NOTES
Rem      Run with select_catalog privileges.  
Rem
Rem      If you want to use this script in an non-interactive fashion,
Rem      see the 'customer-customizable report settings' section in
Rem      awrgrpti.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/awrgrpt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/awrgrpt.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    ardesai     01/11/16 - bug[22334236] select proper default dbid
Rem    rmorant     06/04/15 - Bug21176460 use v$database in non-cdb case
Rem    ardesai     09/30/14 - Use v$pdbs in case of CDB mode
Rem    ilistvin    04/27/09 - change variable name
Rem    ilistvin    11/26/07 - Created
Rem

--
-- call the awrrpt indicating this call is for awrgrpt
-- 

-- define the rpt variable which is used in awrrpt.sql
column awrgrpt_rptc new_value awrgrpt_rptv noprint;
select 'awrgrpt' awrgrpt_rptc from dual;

@@awrrpt.sql

undefine awrgrpt_rptv;

-- End of script
