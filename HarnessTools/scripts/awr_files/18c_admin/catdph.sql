Rem
Rem $Header: rdbms/admin/catdph.sql /main/18 2017/08/22 17:19:52 bwright Exp $
Rem
Rem catdph.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catdph.sql -  Main install script for all DataPump header components
Rem
Rem    DESCRIPTION
Rem      This script is invoked from catproc.sql before catptabs.sql where
Rem      our scripts catdpb.sql and catnodpobs.sql are run in parallel.
Rem      Because of the parallel execution, we want as much of our installation
Rem      to be done in parallel.  Therefore, all new objects should try to be
Rem      added to catdpb.sql.  Only if conflicts or errors occur during upgrade,
Rem      the new operations should be added here.  This script gets run by itself 
Rem      from catproc.sql before the catptabs.sql scripts.
Rem
Rem    NOTES
Rem      This is an old note and accuracy has not been confirmed:
Rem      When adding components to this file, remember to:
Rem      Update catnodp.sql, ship_it, getcat.tsc, tkdp2pfg.tsc, tkdpsuit.tsc,
Rem      tkdppfr.sql and tkdp2rst.tsc. (The last four are used for PL/SQL 
Rem      code coverage.) Also consider upgrade/downgrade.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catdph.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catdph.sql
Rem SQL_PHASE: CATDPH
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bwright     08/14/17 - Bug 26638628 Move as much from catdph to catdpb
Rem                           to maximize upgrade parallelism
Rem    bwright     07/10/17 - Bug 25651930: Use catnodpaq to drop AQ tables
Rem    sdipirro    05/26/15 - Fix potential lident issue
Rem    bwright     02/12/15 - Bug 20391526: fix long identifier issues
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    dgagne      08/30/13 - do not remove stats index
Rem    rphillip    12/11/12 - Bug 15888410: use global temp table for explain
Rem                           plan
Rem    dgagne      05/21/12 - drop stat table before recreating it
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    lbarton     09/09/10 - move prvtdput from catdph.sql to catpdbms.sql,
Rem                            catpprvt.sql
Rem    dgagne      02/01/10 - add update priv in sys.impdp_stats to public
Rem    sdipirro    04/24/07 - Support multiple queue tables
Rem    wfisher     09/12/06 - Disable application roles
Rem    rburns      08/13/06 - split out for parallel
Rem    bpwang      10/05/05 - Grant execute on dbms_server_alert
Rem    wfisher     09/01/05 - Lrg 1908671: Factoring for Standard Edition 
Rem    wfisher     08/19/05 - Creating new roles 
Rem    dgagne      10/15/04 - dgagne_split_catdp
Rem    dgagne      10/04/04 - Created
Rem
@@?/rdbms/admin/sqlsessstart.sql

--
-- Need this here because dbmsslrt.sql moved before catdph.sql in catproc.sql
-- (could not move to catdpb.sql).
--
GRANT execute 
ON dbms_server_alert 
TO datapump_imp_full_database;

--
-- ----------------------------------------------------------------------------
-- Import stats table
-- ----------------------------------------------------------------------------
-- The global temp. table used by datapump import to store statistics
-- information that will be used with dbms_stats.import... The worker will load
-- statistics information into this table and then call the dbms_stats package
-- to take the data in this table and create statistics.
--
BEGIN
  DBMS_STATS.DROP_STAT_TABLE('SYS', 'IMPDP_STATS');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -20002 THEN
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

BEGIN
  DBMS_STATS.CREATE_STAT_TABLE('SYS','IMPDP_STATS', NULL, TRUE);
END;
/
GRANT delete, 
      insert, 
      select, 
      update 
ON sys.impdp_stats 
TO PUBLIC
/


--
-- ----------------------------------------------------------------------------
-- Create the Data Pump default directory object (DATA_PUMP_DIR)
-- ----------------------------------------------------------------------------
--
BEGIN
  DBMS_DATAPUMP_UTL.CREATE_DEFAULT_DIR;
END;
/
--
-- ----------------------------------------------------------------------------
-- Create a global temporary table for when the export version is not the same
-- as the current version and the current master table needs to be downgraded.
-- This way, the data in the master can be copied to the global temporary table
-- and then it can be modified and once that is complete, the data can be
-- unloaded.
-- ----------------------------------------------------------------------------
--
BEGIN
  SYS.KUPV$FT.CREATE_GBL_TEMPORARY_MASTERS();
END;
/

--
-- ----------------------------------------------------------------------------
-- Drop all DataPump queue tables by invoking DBMS_AQADM, so that package has
-- to be valid.  (couldn't move to catdpb.sql).  Note: Data Pump queue tables
-- are now created dynamically, so there is no need to create one here anymore.
-- ----------------------------------------------------------------------------
--
@@catnodpaq
--
-- ----------------------------------------------------------------------------
-- Build heterogeneous type definitions and install XSL stylesheets (from 
-- rdbms/xml/xsl) in sys.metastylesheet.
-- ----------------------------------------------------------------------------
--
@@catmet2.sql
--
-- ------------------
-- End of catdph.sql
-- ------------------
--
@?/rdbms/admin/sqlsessend.sql
