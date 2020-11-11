Rem Copyright (c) 2003, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlprp.sql - Recompile invalid objects in the database
Rem
Rem    DESCRIPTION
Rem      This script recompiles invalid objects in the database.
Rem
Rem      This script is typically used to recompile invalid objects
Rem      remaining at the end of a database upgrade or downgrade. 
Rem 
Rem      Although invalid objects are automatically recompiled on demand,
Rem      running this script ahead of time will reduce or eliminate
Rem      latencies due to automatic recompilation.
Rem
Rem      This script is a wrapper based on the UTL_RECOMP package. 
Rem      UTL_RECOMP provides a more general recompilation interface,
Rem      including options to recompile objects in a single schema. Please
Rem      see the documentation for package UTL_RECOMP for more details.
Rem
Rem    INPUTS
Rem      The degree of parallelism for recompilation can be controlled by
Rem      providing a parameter to this script. If this parameter is 0 or
Rem      NULL, UTL_RECOMP will automatically determine the appropriate
Rem      level of parallelism based on Oracle parameters cpu_count and
Rem      parallel_threads_per_cpu. If the parameter is 1, sequential
Rem      recompilation is used. Please see the documentation for package
Rem      UTL_RECOMP for more details.
Rem
Rem    NOTES
Rem      * You must be connected AS SYSDBA to run this script.
Rem      * There should be no other DDL on the database while running the
Rem        script.  Not following this recommendation may lead to deadlocks.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/utlprp.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlprp.sql 
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: utlrp.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    thbaby      05/11/17 - Bug 26046188: disable redirection in Proxy PDB
Rem    raeburns    04/15/17 - Bug 25790192: Add SQL_METADATA
Rem    jmuller     12/09/14 - Fix bug 19728696 (sort of): clarify comments
Rem    pyam        04/08/14 - 18478064: factor out to reenable_indexes.sql
Rem    kquinn      11/01/11 - 13059165: amend 'OBJECTS WITH ERRORS' SQL
Rem    cdilling    05/15/10 - fix bug 9712478 - call local enquote_name
Rem    anighosh    02/19/09 - #(8264899): re-enabling of function based indexes
Rem                           not needed.
Rem    cdilling    07/21/08 - check bitand for functional index - bug 7243270
Rem    cdilling    01/21/08 - add support for ORA-30552
Rem    cdilling    08/27/07 - check disabled indexes only
Rem    cdilling    05/22/07 - add support for ORA-38301
Rem    cdilling    02/19/07 - 5530085 - renable invalid indexes
Rem    rburns      03/17/05 - use dbms_registry_sys 
Rem    gviswana    02/07/05 - Post-compilation diagnostics 
Rem    gviswana    09/09/04 - Auto tuning and diagnosability
Rem    rburns      09/20/04 - fix validate_components 
Rem    gviswana    12/09/03 - Move functional-index re-enable here 
Rem    gviswana    06/04/03 - gviswana_bug-2814808
Rem    gviswana    05/28/03 - Created
Rem

SET VERIFY OFF;

Rem Bug 26046188: In a Proxy PDB, all top-level statements are redirected to  
Rem the target (PDB) of the Proxy PDB. Set underscore parameter so that 
Rem automatic redirection is turned off. This is needed so that utlrp/utlprp
Rem can be used to recompile objects in Proxy PDB.
Rem 
alter session set "_enable_view_pdb"=false;

SELECT dbms_registry_sys.time_stamp('utlrp_bgn') as timestamp from dual;

DOC
   The following PL/SQL block invokes UTL_RECOMP to recompile invalid
   objects in the database. Recompilation time is proportional to the
   number of invalid objects in the database, so this command may take
   a long time to execute on a database with a large number of invalid
   objects.
  
   Use the following queries to track recompilation progress:
   
   1. Query returning the number of invalid objects remaining. This
      number should decrease with time.
         SELECT COUNT(*) FROM obj$ WHERE status IN (4, 5, 6);
   
   2. Query returning the number of objects compiled so far. This number
      should increase with time.
         SELECT COUNT(*) FROM UTL_RECOMP_COMPILED;
  
   This script automatically chooses serial or parallel recompilation
   based on the number of CPUs available (parameter cpu_count) multiplied
   by the number of threads per CPU (parameter parallel_threads_per_cpu).
   On RAC, this number is added across all RAC nodes.
  
   UTL_RECOMP uses DBMS_SCHEDULER to create jobs for parallel
   recompilation. Jobs are created without instance affinity so that they
   can migrate across RAC nodes. Use the following queries to verify
   whether UTL_RECOMP jobs are being created and run correctly:
  
   1. Query showing jobs created by UTL_RECOMP
         SELECT job_name FROM dba_scheduler_jobs
            WHERE job_name like 'UTL_RECOMP_SLAVE_%';
  
   2. Query showing UTL_RECOMP jobs that are running
         SELECT job_name FROM dba_scheduler_running_jobs
            WHERE job_name like 'UTL_RECOMP_SLAVE_%';
#

DECLARE
   threads pls_integer := &&1;
BEGIN
   utl_recomp.recomp_parallel(threads);
END;
/

SELECT dbms_registry_sys.time_stamp('utlrp_end') as timestamp from dual;

Rem #(8264899): The code to Re-enable functional indexes, which used to exist
Rem here, is no longer needed.

DOC
 The following query reports the number of invalid objects.

 If the number is higher than expected, please examine the error
 messages reported with each object (using SHOW ERRORS) to see if they
 point to system misconfiguration or resource constraints that must be
 fixed before attempting to recompile these objects.
#
select COUNT(*) "OBJECTS WITH ERRORS" from obj$ where status in (3,4,5,6);


DOC
 The following query reports the number of exceptions caught during
 recompilation. If this number is non-zero, please query the error
 messages in the table UTL_RECOMP_ERRORS to see if any of these errors
 are due to misconfiguration or resource constraints that must be
 fixed before objects can compile successfully.
 Note: Typical compilation errors (due to coding errors) are not
       logged into this table: they go into DBA_ERRORS instead.
#
select COUNT(*) "ERRORS DURING RECOMPILATION" from utl_recomp_errors;

Rem =====================================================================
Rem Reenable indexes that may have been disabled, based on the 
Rem table SYS.ENABLED$INDEXES
Rem =====================================================================

@@?/rdbms/admin/reenable_indexes.sql

Rem =====================================================================
Rem Run component validation procedure
Rem =====================================================================

SET serveroutput on
EXECUTE dbms_registry_sys.validate_components; 
SET serveroutput off

