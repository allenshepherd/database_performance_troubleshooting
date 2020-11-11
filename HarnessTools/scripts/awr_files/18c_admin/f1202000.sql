Rem
Rem f1202000.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      f1202000.sql - Use PL/SQL packages for downgrade
Rem                     from 12.2.0.1 patch release
Rem
Rem    DESCRIPTION
Rem
Rem      This scripts is run from catdwgrd.sql to perform any actions
Rem      using PL/SQL packages needed to downgrade from the current
Rem      12.2 patch release to prior 12.2 patch releases
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release environment
Rem        (before installing the release to which you want to downgrade).
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/f1202000.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/f1202000.sql
Rem    SQL_PHASE:DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       amunnoli 09/15/17 - Bug 26389197,26515990: update objauth$
Rem       amunnoli 06/30/17 - Lrg 20390114: Fix container ID of CDB$ROOT
Rem       smangala 06/28/17 - rti 20215644: fix re-exec of agespill_12202to122
Rem       amunnoli 05/27/17 - Bug 25245797:Privilege propagation on audit objs
Rem       raeburns 03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem       smangala 03/21/17 - bug 24926757: circular transaction queue
Rem       sursridh 12/19/16 - Downgrade for pdb event notification framework.
Rem       jnunezg  02/07/17 - BUG 25422950: Drop file watcher job and program
Rem       mmcracke 12/02/16 - #(24958335) ODM 12.2.0.2 downgrade
Rem       geadon   09/21/16 - bug 24515918: drop pmo_deferred_gidx_maint job
Rem       welin 06/02/16   Created
Rem

Rem *************************************************************************
Rem BEGIN f1202000.sql
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release
Rem =========================================================================

-- @@fxxxxxxx.sql

Rem =========================================================================
Rem END STAGE 1: downgrade from the current release
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade dictionary to 12.2.0
Rem =========================================================================

BEGIN
   dbms_registry.downgrading('CATALOG');
   dbms_registry.downgrading('CATPROC');
END;
/

BEGIN
  dbms_scheduler.disable('SYS.PMO_DEFERRED_GIDX_MAINT_JOB', TRUE);
  dbms_scheduler.stop_job('SYS.PMO_DEFERRED_GIDX_MAINT_JOB', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 or sqlcode = -27476 THEN
    NULL; -- Supress job not running (27366), "does not exist" (27476)
  ELSE
    raise;
  END IF;
END;
/

BEGIN
  dbms_scheduler.drop_job('SYS.PMO_DEFERRED_GIDX_MAINT_JOB', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27475 THEN
    NULL; -- Supress "unknown job" error
  ELSE
    raise;
  END IF;
END;
/

BEGIN
  dbms_scheduler.disable('SYS.PMO_DEFERRED_GIDX_MAINT', TRUE);
  dbms_scheduler.drop_program('SYS.PMO_DEFERRED_GIDX_MAINT', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27476 THEN
    NULL; -- Supress "does not exist" error
  ELSE
    raise;
  END IF;
END;
/

-- create 12.2.0.1 deferred global index maintenance program
BEGIN
  dbms_scheduler.create_program(
    program_name        => 'sys.pmo_deferred_gidx_maint', 
    program_type        => 'PLSQL_BLOCK', 
    program_action      => 'dbms_part.cleanup_gidx_internal(
                              noop_okay_in => 1);',
    number_of_arguments => 0,
    enabled             => TRUE,
    comments
      => 'Oracle defined automatic index cleanup for partition maintenance '
      || 'operations with deferred global index maintenance ');

  EXCEPTION
    when others then
      if sqlcode = -27477 then NULL;
      else raise;
      end if;
END;
/

-- create 12.2.0.1 deferred global index maintenance job
BEGIN
  dbms_scheduler.create_job(
    job_name           => 'sys.pmo_deferred_gidx_maint_job',
    program_name       => 'sys.pmo_deferred_gidx_maint', 
    schedule_name      => 'sys.pmo_deferred_gidx_maint_sched',
    job_class          => 'SCHED$_LOG_ON_ERRORS_CLASS',
    enabled            => TRUE,
    auto_drop          => FALSE,
    comments
      => 'Oracle defined automatic index cleanup for partition maintenance '
      || 'operations with deferred global index maintenance ');

  EXCEPTION
    when others then
      if sqlcode = -27477 then NULL;
      else raise;
      end if;
END;
/

Rem =======================================================================
Rem Begin Changes for Logical Standby
Rem =======================================================================

Rem BUG 18529468:
Rem Convert Logical Standby Ckpt data from 12.2.0.2 format to 12.2 format
Rem

begin
  sys.dbms_logmnr_internal.agespill_12202to122;
end;
/

Rem =======================================================================
Rem End Changes for Logical Standby
Rem =======================================================================

Rem =====================
Rem Begin ODM changes
Rem =====================

Rem ODM model downgrades (specify downgrade from version)
exec dmp_sys.downgrade_models('12.2.0.2');

Rem =====================
Rem End ODM changes
Rem =====================

-- Drop pdb_mon_event_queue$ and associated queue table.
-- This is used by the PDB events framework.
exec dbms_aqadm.stop_queue('pdb_mon_event_queue$');
exec dbms_aqadm.drop_queue('pdb_mon_event_queue$');
exec dbms_aqadm.drop_queue_table('pdb_mon_event_qtable$');


Rem =======================
Rem Begin Scheduler changes
Rem =======================

-- BUG 25422950: Drop File watcher job and program
BEGIN
  dbms_scheduler.disable('SYS.FILE_WATCHER', TRUE);
  dbms_scheduler.stop_job('SYS.FILE_WATCHER', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 or sqlcode = -27476 THEN
    NULL; -- Supress job not running (27366), "does not exist" (27476)
  ELSE
    raise;
  END IF;
END;
/

BEGIN
  dbms_scheduler.drop_job('SYS.FILE_WATCHER', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27475 THEN
    NULL; -- Supress "unknown job" error
  ELSE
    raise;
  END IF;
END;
/

BEGIN
  dbms_scheduler.drop_program('SYS.FILE_WATCHER_PROGRAM');
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27476 THEN
    NULL; -- Supress program des not exist
  ELSE
    raise;
  END IF;
END;
/

Rem =======================
Rem End Scheduler changes
Rem =======================

Rem ============================
Rem Begin Bug 25245797 changes
Rem ============================

--
-- Create DUMMY AUDIT OBJECTS (which we plan to move from AUDSYS schema to 
-- SYS schema) under SYS schema and grant the object level privileges
-- on these dummy objects to those users/roles who have already been 
-- granted object level privileges on these objects under AUDSYS schema.
-- Once the downgrade finishes, as part of catuat.sql/dbmsamgt.sql these
-- dummy objects would get replaced with actual obects under SYS schema.
-- Since we would be granting required privileges on these objects under SYS
-- schema to users/roles, post DB upgrade accessing these objects wouldn't
-- have privilege issues.
--
create or replace view SYS.CDB_XS_AUDIT_TRAIL as select * from sys.dual;
create or replace view SYS.DBA_XS_AUDIT_TRAIL as select * from sys.dual;
create or replace view SYS.DV$ENFORCEMENT_AUDIT as select * from sys.dual;
create or replace view SYS.DV$CONFIGURATION_AUDIT as select * from sys.dual;
create or replace view SYS.CDB_UNIFIED_AUDIT_TRAIL as select * from sys.dual;
create or replace view SYS.UNIFIED_AUDIT_TRAIL as select * from sys.dual;

-- Before creating a dummy DBMS_AUDIT_MGMT package inside SYS schema, make
-- sure we drop the PRIVATE SYNONYM under SYS schema pointing to
-- AUDSYS.DBMS_AUDIT_MGMT package, else creation of dummy package with the
-- same name will fail with ORA-955.
DROP SYNONYM SYS.DBMS_AUDIT_MGMT;
create or replace package SYS.DBMS_AUDIT_MGMT as
procedure dummy_sys_proc;
end;
/

-- Bug 26389197, 26515990: Update the objauth$ dictionary to set the grantor
-- information correctly. This would also avoid executing the GRANT statements
-- with CONTAINER=ALL when _ORACLE_SCRIPT is set to TRUE.

declare
cnt                    NUMBER := 0;    -- Number of Grants
sys_audit_objid        NUMBER := 0;    -- Audit Object ID owned by SYS
audsys_audit_objid     NUMBER := 0;    -- Audit Object ID owned by AUDSYS
audsys_uid             NUMBER := 0;    -- AUDSYS UserID
TYPE obj_name_list IS VARRAY(7) OF VARCHAR2(30); -- List of Audit Objects
audit_obj_list obj_name_list;

BEGIN
  audit_obj_list := obj_name_list('UNIFIED_AUDIT_TRAIL',
                                  'CDB_UNIFIED_AUDIT_TRAIL',
                                  'DBA_XS_AUDIT_TRAIL',
                                  'CDB_XS_AUDIT_TRAIL',
                                  'DV$ENFORCEMENT_AUDIT',
                                  'DV$CONFIGURATION_AUDIT',
                                  'DBMS_AUDIT_MGMT');

  -- Get the UserID of AUDSYS
  SELECT user# INTO audsys_uid FROM sys.user$ where name = 'AUDSYS';

  -- For every Audit Object of interest
  FOR i IN audit_obj_list.first..audit_obj_list.last
  LOOP
    BEGIN
      -- First, check if the grant exists on this AUDSYS owned audit object
      SELECT count(*) INTO cnt FROM sys.objauth$ oa, sys.obj$ o
      WHERE o.owner# = audsys_uid AND o.name = audit_obj_list(i)
      AND oa.obj# = o.obj# AND rownum = 1;

      IF (cnt > 0) THEN  -- if the grant exists
        IF (audit_obj_list(i) = 'DBMS_AUDIT_MGMT') THEN -- if package
          -- Get the object ID of SYS owned audit package
          SELECT o.obj# INTO sys_audit_objid FROM sys.obj$ o
          WHERE o.owner# = 0 AND o.name = audit_obj_list(i)
          AND o.type# = 9;

          -- Get the object ID of AUDSYS owned audit package
          SELECT o.obj# INTO audsys_audit_objid FROM sys.obj$ o
          WHERE o.owner# = audsys_uid AND o.name = audit_obj_list(i)
          AND o.type# = 9;

        ELSE  -- else, it is a view
          -- Get the object ID of SYS owned audit view
          SELECT o.obj# INTO sys_audit_objid FROM sys.obj$ o
          WHERE o.owner# = 0 AND o.name = audit_obj_list(i)
          AND o.type# = 4;

          -- Get the object ID of AUDSYS owned audit view
          SELECT o.obj# INTO audsys_audit_objid FROM sys.obj$ o
          WHERE o.owner# = audsys_uid AND o.name = audit_obj_list(i)
          AND o.type# = 4;
        END IF;

        -- Update both obj# and grantor# for entries who have been granted by
        -- AUDSYS or anybody with GRANT ANY OBJECT privilege.
        UPDATE sys.objauth$ SET
        obj# = sys_audit_objid, grantor# = 0
        WHERE obj# = audsys_audit_objid AND grantor# = audsys_uid;

        -- Update ONLY obj# for entries who have been granted by user
        -- having 'WITH GRANT OPION'.
        UPDATE sys.objauth$ SET obj# = sys_audit_objid
        WHERE obj# = audsys_audit_objid AND grantor# <> audsys_uid;

        COMMIT;
      END IF;
    END;
  END LOOP;
END;
/

Rem ============================
Rem End Bug 25245797 changes
Rem ============================

----- ADD ACTIONS USING VIEWS OR PACKAGES ABOVE THIS LINE ------
-------- ADD OTHER DOWNGRADE ACTIONS TO e1202000.sql -----------

Rem update status in component registry (last)

BEGIN
   dbms_registry.downgraded('CATALOG','12.2.0');
   dbms_registry.downgraded('CATPROC','12.2.0');
END;
/

Rem =========================================================================
Rem END STAGE 2: downgrade dictionary to 12.2.0
Rem =========================================================================

Rem *************************************************************************
Rem END f1202000.sql
Rem *************************************************************************

