Rem
Rem $Header: rdbms/admin/execsvrm.sql /main/21 2017/07/12 10:51:45 osuro Exp $
Rem
Rem execsvrm.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execsvrm.sql - EXECute SerVeR Manageablity PL/SQL blocks
Rem
Rem    DESCRIPTION
Rem      
Rem
Rem    NOTES
Rem      
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/execsvrm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/execsvrm.sql
Rem SQL_PHASE: EXECSVRM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    osuro       07/04/17 - bug 26373814: create first partn during upgrade
Rem    quotran     02/16/16 - Make umf$_registration_xml schema identical to
Rem                           umf$_registration
Rem    quotran     02/06/16 - bug 22626346
Rem    osuro       01/14/16 - Bug 22161760: recreate staging schema
Rem    yingzhen    10/30/15 - Add callback to filer x$kewrtb
Rem    yingzhen    10/06/15 - Bug 21575534: change dba_hist view location
Rem    rmorant     07/15/15 - Bug 21143682 longid
Rem    spapadom    02/12/15 - UMF Milestone 2: Added UMF XML views.
Rem    spapadom    08/18/14 - Removed SYSAWR, added SYSUMF_ROLE grants.
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    gravipat    11/06/13 - 17709031: Use create_cdbview procedure to create
Rem                           cdb views
Rem    jerrede     12/18/12 - Catch and ignore ORA-65040 during CDB upgrades 
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    shjoshi     02/27/12 - Insert row in wrp$_reports_control table
Rem    gravipat    12/05/11 - Create cdbview using CDB$VIEW function
Rem    gngai       09/19/11 - added create_staging_schema
Rem    ilistvin    07/13/11 - create CDB views for dictionary tables
Rem    ilistvin    03/15/11 - set LAST_CHANGE to NULL for Autotask
Rem    ilistvin    11/10/08 - set default thresholds for temp and undo
Rem                           tablespaces
Rem    ilistvin    01/05/07 - move procedure invocations from prvtawr.sql
Rem    ilistvin    11/15/06 - register feature usage here
Rem    ilistvin    11/08/06 - merge in catmwin.sql
Rem    ilistvin    11/08/06 - merge in AUTOTASK init code
Rem    mlfeng      10/31/06 - merge in Alert initialization
Rem    rburns      09/16/06 - execute SVRM packages
Rem    rburns      09/16/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Set the default database thresholds
BEGIN
dbms_server_alert.set_threshold(9000,null,null,null,null,1,1,'',5,'');
EXCEPTION
  when others then
    if sqlcode = -00001 then NULL;         -- unique constraint error
    else raise;
    end if;
END;
/
Rem 
Rem For all UNDO and TEMPORARY tablespaces for which there is no
Rem explicit threshold set, create an explicit "Do Not Check" threshold
Rem
DECLARE
  tbsname dbms_id;
  CURSOR tbs IS
    SELECT tablespace_name 
      FROM dba_tablespaces
     WHERE extent_management = 'LOCAL'
       AND contents IN ('TEMPORARY','UNDO')
       AND tablespace_name NOT IN 
                  (SELECT object_name
                     FROM table(dbms_server_alert.view_thresholds)
                    WHERE object_type = 5
                      AND object_name IS NOT NULL
                      AND metrics_id IN (9000, 9001));
BEGIN
  OPEN tbs;
  LOOP
    FETCH tbs INTO tbsname;
    EXIT WHEN tbs%NOTFOUND;
    BEGIN
      dbms_server_alert.set_threshold(dbms_server_alert.TABLESPACE_PCT_FULL
                                    , dbms_server_alert.OPERATOR_DO_NOT_CHECK
                                    , '<SYSTEM-GENERATED THRESHOLD>'  
                                    , dbms_server_alert.OPERATOR_DO_NOT_CHECK
                                    , '0'  -- critical value
                                    , 0    -- observation period 
                                    , 0    -- consecutive occurrences 
                                    , NULL -- instance name
                                    , dbms_server_alert.OBJECT_TYPE_TABLESPACE
                                    , tbsname);
    EXCEPTION WHEN OTHERS THEN 
      RAISE;
    END;
  END LOOP;
  CLOSE tbs;
EXCEPTION WHEN OTHERS THEN RAISE;
END;
/  
  
-- Register export package as a sysstem export action
DELETE FROM exppkgact$ WHERE package = 'DBMS_SERVER_ALERT_EXPORT'
/
INSERT INTO exppkgact$ (package, schema, class, level#)
  VALUES ('DBMS_SERVER_ALERT_EXPORT', 'SYS', 1, 1000)
/
commit
/


DECLARE
  DUPLICATE_KEY exception;
  pragma EXCEPTION_INIT(DUPLICATE_KEY, -1);
BEGIN
--
-- Initialize AUTOTASK status
-- (dummy_key prevents > 1 row from being inserted)
--
 INSERT INTO KET$_AUTOTASK_STATUS(DUMMY_KEY, AUTOTASK_STATUS,ABA_STATE)
 VALUES (99999, 2, 99);
EXCEPTION
  WHEN DUPLICATE_KEY THEN NULL;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  DUPLICATE_KEY exception;
  pragma EXCEPTION_INIT(DUPLICATE_KEY, -1);
BEGIN
 dbms_auto_task_admin.default_reset('ALL');
EXCEPTION
  WHEN DUPLICATE_KEY THEN NULL;
  WHEN OTHERS THEN RAISE;
END;
/

Rem
Rem Setup the advisor repository
Rem

execute dbms_advisor.setup_repository;


Rem SQL Tuning Advisor initialization of Automatic Task
@@execsqlt.sql

/* register all the features and high water marks */
begin
  DBMS_FEATURE_REGISTER_ALLFEAT;
  DBMS_FEATURE_REGISTER_ALLHWM;
end;
/

--
-- Register the local database into AWR.
-- This works for non-CDB and for CDB$ROOT, but in PDB, you get an error:
-- ORA-65040: operation not allowed from within a pluggable database
--
BEGIN
  /* register the local dbid if it hasn't been done yet */
  dbms_swrf_internal.register_local_dbid;

  /* create partitions for newly added AWR partitioned tables */
  dbms_swrf_internal.create_upgrade_partitions;
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -65040) THEN NULL; ELSE RAISE; END IF;
END;
/


--
-- Execute the call to create the AWR Staging schema.
--
BEGIN
  /* drop existing Staging tables */
  dbms_swrf_internal.remove_staging_schema;

  /* create Staging tables */
  dbms_swrf_internal.create_staging_schema;
END;
/

--
-- Execute the call to insert the baseline details
-- We call this because we introduce the new WRM$_BASELINE_DETAILS table
-- in 11g, and rows need to be inserted during upgrade (catproc.sql)
--
BEGIN
  /* insert the baseline details */
  dbms_swrf_internal.insert_baseline_details;
END;
/

/* AWR Snapshots require CDB view over ts$ */
execute CDBView.create_cdbview(false, 'SYS', 'TS$', 'AWRI$_CDB_TS$');

grant select on awri$_cdb_ts$ to SELECT_CATALOG_ROLE;

-- insert the row in the wrp reports control table
-- This row indicates the mode of execution of the report capture
-- service, where 0 => Regular and 1 => Full capture
BEGIN
  insert into wrp$_reports_control
    select dbid, 0 from v$database;
EXCEPTION
  when others then
    if sqlcode = -00001 then 
      NULL;             -- unique constraint error
    else 
      raise;
    end if;
END;
/


/* Grant privileges on AWR Tables and AWR Staged Tables to 
   the sysumf_role role. */
DECLARE 
  table_name VARCHAR2(2048); 
  staged_table_name VARCHAR2(2048);
  sql_str1 varchar2(2048); 
  sql_str2 varchar2(2048);

  /* AWR table flags used, these flags are the same as in kewr.h */
  KEWRTF_TABLE_GROUP        CONSTANT BINARY_INTEGER := POWER(2, 13);

  CURSOR c_table_name IS 
     SELECT table_name_kewrtb, table_name_kewrstgtb 
      FROM x$kewrtb LEFT OUTER JOIN x$kewrstgtb ON 
        table_id_kewrtb = table_id_kewrstgtb 
      WHERE bitand(table_flag_kewrtb, KEWRTF_TABLE_GROUP) = 0;

BEGIN
  OPEN c_table_name; 
  LOOP 

        FETCH c_table_name INTO table_name, staged_table_name;
        EXIT WHEN c_table_name%notfound; 
        sql_str1 := 'GRANT SELECT, INSERT, DELETE, UPDATE ON ' || table_name ||
                        ' TO sysumf_role';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, DELETE, UPDATE ON ' 
                        || table_name ||
                        ' TO sysumf_role';

        IF staged_table_name IS NOT NULL THEN  
        
                sql_str2 := 'GRANT SELECT, INSERT, DELETE, UPDATE ON ' ||
                                         staged_table_name ||' TO sysumf_role';

                EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, DELETE, UPDATE ON ' ||
                                         staged_table_name ||' TO sysumf_role';
        END IF; 
  END LOOP; 
END;
/

/* Grant privileges on UMF Tables to the sysumf_role role. */
DECLARE 
  table_name VARCHAR2(2048); 
  CURSOR c_table_name IS SELECT table_name_keumtb FROM x$keumtb ;
BEGIN
  OPEN c_table_name; 
  LOOP 
        FETCH c_table_name INTO table_name;
        EXIT WHEN c_table_name%notfound; 
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, DELETE, UPDATE ON ' 
                        || table_name ||
                        ' TO sysumf_role';
  END LOOP;
END;
/


/******************************************************************************
 *        UMF XML TABLE Views.
 *        These views are built on an XML object provided by 
 *        the dbms_umf_internal.topology_load_xml PL/SQL so they have
 *        to be created after the UMF PL/SQL packages, hence their placement
 *        in execsvrm.
 *****************************************************************************/

/******************************************************************************
 *        UMF$_TOPOLOGY_XML
 * 
 *        Presents a relational view of the "topology" section of the UMF
 *        metadata. The view corresponds to the umf$_topology table on the 
 *        target and contains identical information.
 *****************************************************************************/
CREATE OR REPLACE VIEW umf$_topology_xml AS
          SELECT * FROM XMLTable('/UMF_SCHEMA/TOPOLOGY/TOPOLOGY_INST'
          PASSING dbms_umf_internal.topology_load_xml
          COLUMNS topology_name varchar2(128) PATH 'TOPOLOGY_NAME',
                  target_id NUMBER PATH 'TARGET_ID',
                  topology_version NUMBER PATH 'TOPOLOGY_VERSION',
                  topology_state NUMBER PATH 'TOPOLOGY_STATE');

/******************************************************************************
 *        UMF$_REGISTRATION_XML
 * 
 *        Presents a relational view of the "registration" section of the UMF
 *        metadata. The view corresponds to the umf$_registration table on the 
 *        target and contains identical information.
 *****************************************************************************/
CREATE OR REPLACE VIEW umf$_registration_xml AS
          SELECT * FROM XMLTable('/UMF_SCHEMA/REGISTRATION/REGISTRATION_INST'
          PASSING dbms_umf_internal.topology_load_xml
          COLUMNS topology_name varchar2(128) PATH 'TOPOLOGY_NAME',
                  node_name varchar2(128) PATH 'NODE_NAME',
                  node_id NUMBER PATH 'NODE_ID',
                  node_type NUMBER PATH 'NODE_TYPE',
                  as_source NUMBER PATH 'AS_SOURCE',
                  as_candidate_target NUMBER PATH 'AS_CANDIDATE_TARGET',
                  state NUMBER PATH 'STATE');

/******************************************************************************
 *        UMF$_LINK_XML
 * 
 *        Presents a relational view of the "link" section of the UMF
 *        metadata. The view corresponds to the umf$_link table on the 
 *        target and contains identical information.
 *****************************************************************************/
CREATE OR REPLACE VIEW umf$_link_xml AS
         SELECT * FROM XMLTable('/UMF_SCHEMA/LINK/LINK_INST'
         PASSING dbms_umf_internal.topology_load_xml
         COLUMNS topology_name varchar2(128) PATH 'TOPOLOGY_NAME',
                  from_node_id NUMBER PATH 'FROM_NODE_ID',
                  to_node_id NUMBER PATH 'TO_NODE_ID',
                  link_name varchar2(128) PATH 'LINK_NAME');

/******************************************************************************
 *        UMF$_SERVICE_XML
 * 
 *        Presents a relational view of the "service" section of the UMF
 *        metadata. The view corresponds to the umf$_service table on the 
 *        target and contains identical information.
 *****************************************************************************/
CREATE OR REPLACE VIEW umf$_service_xml AS
        SELECT * FROM XMLTable('/UMF_SCHEMA/SERVICE/SERVICE_INST'
        PASSING dbms_umf_internal.topology_load_xml
        COLUMNS topology_name varchar2(128) PATH 'TOPOLOGY_NAME',
                node_id NUMBER PATH 'NODE_ID',
                service_id NUMBER PATH 'SERVICE_ID');


GRANT SELECT, INSERT, DELETE, UPDATE ON umf$_topology_xml TO sys$umf;
GRANT SELECT, INSERT, DELETE, UPDATE ON umf$_registration_xml TO sys$umf;
GRANT SELECT, INSERT, DELETE, UPDATE ON umf$_link_xml TO sys$umf;
GRANT SELECT, INSERT, DELETE, UPDATE ON umf$_service_xml TO sys$umf;

GRANT SELECT ON UMF$_TOPOLOGY_XML TO SELECT_CATALOG_ROLE
/
GRANT SELECT ON UMF$_REGISTRATION_XML TO SELECT_CATALOG_ROLE
/
GRANT SELECT ON UMF$_LINK_XML TO SELECT_CATALOG_ROLE
/
GRANT SELECT ON UMF$_SERVICE_XML TO SELECT_CATALOG_ROLE
/
GRANT SELECT ON UMF_SCHEMA_XMLTYPE TO SELECT_CATALOG_ROLE
/
GRANT SELECT, INSERT, DELETE, UPDATE ON umf_schema_xmltype TO sys$umf; 
/

@?/rdbms/admin/sqlsessend.sql
