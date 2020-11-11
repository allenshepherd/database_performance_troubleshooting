Rem
Rem $Header: rdbms/admin/dvu122.sql /main/13 2017/09/19 20:12:36 amunnoli Exp $
Rem
Rem dvu122.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dvu122.sql - Upgrade from 12.2.0.1 to current version
Rem
Rem    DESCRIPTION
Rem      Upgrade DV from 12.2.0.1 to current/latest version
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amunnoli    09/15/17 - Bug 26389197,26515990: update objauth$
Rem    youyang     08/28/17 - bug26619982:add default value for action
Rem    jibyun      08/22/17 - Bug 26612996: CSW_USR_ROLE ans SPATIAL_CSW_ADMIN
Rem                           roles are deprecated in 18.1
Rem    amunnoli    06/26/17 - Lrg 20400585: create and process dummy views in
Rem                           AUDSYS schema for DV unified audit trail
Rem    jibyun      06/23/17 - Bug 26338289: remove realm protection for the
Rem                           JAVA_DEPLOY role (deprecated)
Rem    raeburns    06/13/17 - RTI 20258949: Drop objects removed from DV
Rem                           install
Rem    amunnoli    06/02/17 - Bug 25245797: move DV uniaud views to audsys
Rem    youyang     05/23/17 - bug26001318:modify sql meta data
Rem    risgupta    03/23/17 - Bug 25677837: Move old simulation log records to
Rem                           new table
Rem    risgupta    01/15/17 - Proj 67579: Upgrade changes for DV Simulation
Rem                           Enhancements
Rem    risgupta    11/14/16 - Bug 24971682: Move downgrade changes for 24557076
Rem                           to dvu121.sql
Rem    jibyun      09/22/16 - Bug 24557076: Reduce privileges of DV_OWNER
Rem    namoham     09/13/16 - Bug 24582583: Increase the length of audit_trail$
Rem                           fields: os_process and action_name 
Rem    namoham     09/13/16 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dvu122.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dvu122.sql
Rem    SQL_PHASE: UPGRADE 
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/dvdbmig.sql
Rem    END SQL_FILE_METADATA


-- Bug 24582583
-- ACTION_NAME value is taken from dvsys.code_t$.value field which is
-- of length 4000. Increase the field to match it.
alter table dvsys.audit_trail$ modify action_name varchar2(4000);
-- OS_PROCESS value is taken from sys.gv_$session.process field which is
-- of length 24. Increase the field to match it.
alter table dvsys.audit_trail$ modify os_process varchar2(24);

-- Bug 26338289: JAVA_DEPLOY has been deprecated.
DELETE FROM dvsys.realm_object$ WHERE object_name = 'JAVA_DEPLOY' AND object_type = 'ROLE';

-- Bug 26612996: CSW_USR_ROLE and SPATIAL_CSW_ADMIN roles are depreciated.
DELETE FROM dvsys.realm_object$ WHERE object_type = 'ROLE' and object_name in ('CSW_USR_ROLE', 'SPATIAL_CSW_ADMIN');

-- Proj 67579: Update DV metadata tables to include new columns
alter table dvsys.command_rule$ add pl_sql_stack number default 0;
alter table dvsys.realm$ add pl_sql_stack number default 0;
alter table dvsys.policy$ add pl_sql_stack number default 0;

-- Bug 25677837: Move the old simulation log records to new table, if any.
-- Else, drop the existing table.
DECLARE
  cnt          PLS_INTEGER := 0;
  simTblExists BOOLEAN := TRUE;
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 
      'select count(*) from dvsys.simulation_log$ where rownum <= 1' INTO cnt;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN (-942) THEN simTblExists := FALSE;
      ELSE RAISE;
      END IF;
  END;  

  IF (simTblExists = TRUE) THEN
    -- If no simulation log records exist, drop the existing table. It is 
    -- created in rdbms/admin/catmacc.sql.
    IF (cnt = 0) THEN
      EXECUTE IMMEDIATE 'drop table dvsys.simulation_log$';
    ELSE
    -- If simulation log records exist, move them to
    -- dvsys.old_simulation_log$ table.
      EXECUTE IMMEDIATE 'ALTER TABLE dvsys.simulation_log$
                         RENAME TO old_simulation_log$';
      sys.dbms_registry.set_progress_value('DV', 'SIMULATION LOGS',
'The existing simulation logs have been moved to dvsys.old_simulation_log$');
    END IF;
  END IF;
END;
/

-----------------------------------------------------------------------
--- End: Project 67579 Changes
-----------------------------------------------------------------------

-----------------------------------------------------------------------
--  BEGIN RTI 12596835: Drop tables truncated in dvu121.sql
-----------------------------------------------------------------------

drop table DVSYS."REALM_COMMAND_RULE$";
drop table DVSYS."DOCUMENT$";
drop table DVSYS."FACTOR_SCOPE$";
drop table DVSYS."MONITOR_RULE$";
drop table DVSYS."MONITOR_RULE_T$";

-----------------------------------------------------------------------
--  END RTI 12596835: Drop tables truncated in dvu121.sql
-----------------------------------------------------------------------

-----------------------------------------------------------------------
--- Begin: Bug 25245797 Changes
-----------------------------------------------------------------------

-- LRG 20400585: Create DUMMY DV UNIAUD objects (which we plan to move from 
-- SYS schema to AUDSYS schema) under AUDSYS schema and grant the object level 
-- privileges on these dummy objects to those users/roles who have already been 
-- granted object level privileges on these objects under SYS schema.
-- Once the upgrade finishes, as part of catmacc.sql these
-- dummy objects would get replaced with actual objects under AUDSYS schema.
-- Since we would be granting required privileges on these objects under AUDSYS
-- schema to users/roles, post DB upgrade accessing these objects wouldn't
-- have privilege issues.

create or replace view AUDSYS.DV$ENFORCEMENT_AUDIT as select * from sys.dual;
create or replace view AUDSYS.DV$CONFIGURATION_AUDIT as select * from sys.dual;

-- Bug 26389197, 26515990: Update the objauth$ dictionary to set the grantor
-- information correctly. This would also avoid executing the GRANT statements
-- with CONTAINER=ALL when _ORACLE_SCRIPT is set to TRUE.

declare
cnt                    NUMBER := 0;    -- Number of Grants
sys_audit_objid        NUMBER := 0;    -- Audit Object ID owned by SYS
audsys_audit_objid     NUMBER := 0;    -- Audit Object ID owned by AUDSYS
audsys_uid             NUMBER := 0;    -- AUDSYS UserID
TYPE obj_name_list IS VARRAY(2) OF VARCHAR2(30); -- List of Audit Objects
audit_obj_list obj_name_list;

BEGIN
  audit_obj_list := obj_name_list('DV$CONFIGURATION_AUDIT',
                                  'DV$ENFORCEMENT_AUDIT');

  -- Get the UserID of AUDSYS
  SELECT user# INTO audsys_uid FROM sys.user$ where name = 'AUDSYS';

  -- For every Audit Object of interest
  FOR i IN audit_obj_list.first..audit_obj_list.last
  LOOP
    BEGIN
      -- First, check if the grant exists on this SYS owned audit object
      SELECT count(*) INTO cnt FROM sys.objauth$ oa, sys.obj$ o
      WHERE o.owner# = 0 AND o.name = audit_obj_list(i)
      AND oa.obj# = o.obj# AND rownum = 1;

      IF (cnt > 0) THEN  -- if the grant exists
        -- Get the object ID of SYS owned audit view
        SELECT o.obj# INTO sys_audit_objid FROM sys.obj$ o
        WHERE o.owner# = 0 AND o.name = audit_obj_list(i)
        AND o.type# = 4;

        -- Get the object ID of AUDSYS owned audit view
        SELECT o.obj# INTO audsys_audit_objid FROM sys.obj$ o
        WHERE o.owner# = audsys_uid AND o.name = audit_obj_list(i)
        AND o.type# = 4;

        -- Update both obj# and grantor# for entries who have been granted by
        -- SYS or anyone with GRANT ANY OBJECT privilege.
        UPDATE sys.objauth$ SET
        obj# = audsys_audit_objid, grantor# = audsys_uid
        WHERE obj# = sys_audit_objid AND grantor# = 0;

        -- Update ONLY obj# for entries who have been granted by user
        -- having 'WITH GRANT OPION'.
        UPDATE sys.objauth$ SET obj# = audsys_audit_objid
        WHERE obj# = sys_audit_objid AND grantor# <> 0;

        COMMIT;
      END IF;
    END;
  END LOOP;
END;
/

-- DROP the SYS owned DV UNIAUD views
DROP VIEW SYS.dv$enforcement_audit;
DROP VIEW SYS.dv$configuration_audit;

-----------------------------------------------------------------------
--- End: Bug 25245797 Changes
-----------------------------------------------------------------------

--bug 26619982
alter table dvsys.dv_auth$ modify action default '%';

