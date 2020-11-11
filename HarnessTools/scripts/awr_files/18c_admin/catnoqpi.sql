Rem
Rem $Header: rdbms/admin/catnoqpi.sql /main/5 2017/05/28 22:46:03 stanaya Exp $
Rem
Rem catnoqpi.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnoqpi.sql - Drop objects
Rem
Rem    DESCRIPTION
Rem      Drop queryable patch inventory objects for downgrade
Rem
Rem    NOTES
Rem      .
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnoqpi.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnoqpi.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    dkoppar     09/23/15 - #21052918 pending-act changes for bigsql
Rem    dkoppar     07/25/12 - drop types related to xmltype
Rem    tbhukya     07/13/12 - Drop tables of new implementation with xml
Rem    tbhukya     05/08/12 - Drop table opatch_inst_job.
Rem    tbhukya     12/19/11 - Created
Rem

-- DROP Job
DECLARE
  inst_tab dbms_utility.instance_table;
  inst_cnt NUMBER;
  jobname varchar2(128)  := NULL;
BEGIN

  -- Check if it is a RAC env or not
  IF dbms_utility.is_cluster_database THEN
    dbms_utility.active_instances(inst_tab, inst_cnt);

    -- Drop job on all the active nodes in RAC
    FOR i in inst_tab.FIRST..inst_tab.LAST LOOP
      jobname := 'Load_opatch_inventory_' || inst_tab(i).inst_number;
      DBMS_SCHEDULER.DROP_JOB (job_name        => jobname);

    END LOOP;
  END IF;

  -- Create job on current oracle home
  DBMS_SCHEDULER.DROP_JOB (job_name        => 'Load_opatch_inventory');

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
END;
/
show errors

-- Drop Packages, Types, sequence, tables, procedure.
DROP PACKAGE BODY dbms_qopatch;
DROP PACKAGE dbms_qopatch;


DROP TABLE opatch_xml_inv CASCADE CONSTRAINTS;
DROP TABLE opatch_xinv_tab CASCADE CONSTRAINTS;
DROP TABLE opatch_inst_job CASCADE CONSTRAINTS;
DROP TABLE opatch_inst_patch CASCADE CONSTRAINTS;
DROP TABLE opatch_sql_patches CASCADE CONSTRAINTS;

DROP type  opatch_node_array;

DROP DIRECTORY opatch_log_dir;
DROP DIRECTORY opatch_script_dir;
