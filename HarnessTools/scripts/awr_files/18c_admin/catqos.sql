Rem
Rem $Header: rdbms/admin/catqos.sql /main/18 2017/03/02 12:17:11 alui Exp $
Rem
Rem catqos.sql
Rem
Rem Copyright (c) 2008, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catqos.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Create Quality of Service Management Schema in the datbase
Rem
Rem    NOTES
Rem      This script must run after catsnmp so that the DBSNMP user is
Rem      already in place when the grants are done.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catqos.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catqos.sql
Rem SQL_PHASE: CATQOS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catsnmp.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    alui        02/21/17 - grant wlm_pcservice view access to appqossys user
Rem    jmunozn     01/23/17 - Add grants for Project 70502
Rem    alui        11/02/15 - bug 22049157: fixed views for selective pdb
Rem                           management
Rem    alui        08/21/15 - Bug 20674123: fix feature usage for QoSM
Rem    alui        04/10/15 - grant privilege access for RM RSRC plan
Rem                           directives
Rem    alui        11/05/14 - 19954888: grants needed for access to PDB name.
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    akruglik    02/05/13 - (bug 16194686) ensure that ALTER USER SET
Rem                           CONTAINER_DATA statement refers to a public
Rem                           synonym to a [g]v_$ view defined over a fixed
Rem                           view
Rem    alui        07/22/12 - for appqossys to see all data in v$wlm_pcmetric
Rem                           in the root
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    rpang       07/25/11 - Proj 32719: revoke inherit priv on appqossys
Rem    alui        02/28/11 - grant type access to APPQOSSYS user for
Rem                           Capabilities object
Rem    sbasu       06/05/10 - add privilege to APPQOSSYS user for RLB|CLB info
Rem    alui        10/26/09 - add tables for pushing alerts
Rem    dsemler     03/10/09 - add EM access to WLM_CLASSIFIER_PLAN
Rem    dsemler     02/24/09 - remove psm column, add negative_interval column
Rem                           to wlm_metrics_stream
Rem    dsemler     11/26/08 - correct privileges assigned to appqossys
Rem    alui        08/15/08 - change Max classifier list string from 2048 to
Rem                           4000
Rem    alui        06/11/08 - add classifier table
Rem    dsemler     03/26/08 - add required permissions to the APPQOSSYS user
Rem    dsemler     01/10/08 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create user APPQOSSYS identified by "APPQOSSYS"
  default tablespace sysaux
  quota unlimited on sysaux
  account lock password expire;

Rem Grants required for APPQOSSYS
grant CREATE SESSION to APPQOSSYS;
grant SELECT on sys.v_$wlm_pcmetric to APPQOSSYS;
alter USER APPQOSSYS set container_data=all for "PUBLIC".v$wlm_pcmetric;
grant SELECT on sys.v_$wlm_pcservice to APPQOSSYS;
alter USER APPQOSSYS set container_data=all for "PUBLIC".v$wlm_pcservice;
grant SELECT on DBA_PDBS to APPQOSSYS;
alter USER APPQOSSYS set container_data=all for dba_pdbs;
grant SELECT on sys.v_$containers to APPQOSSYS;
alter USER APPQOSSYS set container_data=all for "PUBLIC".v$containers;
grant SELECT on DBA_RSRC_CONSUMER_GROUPS to APPQOSSYS;
grant SELECT on DBA_RSRC_GROUP_MAPPINGS to APPQOSSYS;
grant SELECT on DBA_CDB_RSRC_PLAN_DIRECTIVES to APPQOSSYS;
grant SELECT on V_$SESSION to APPQOSSYS;
grant SELECT on V_$PROCESS to APPQOSSYS;
grant SELECT on V_$LICENSE to APPQOSSYS;
grant SELECT on V_$OSSTAT to APPQOSSYS;
grant SELECT on ALL_SERVICES to APPQOSSYS;
grant ALTER SESSION to APPQOSSYS;
grant execute on WLM_CAPABILITY_OBJECT to APPQOSSYS;
grant execute on WLM_CAPABILITY_ARRAY to APPQOSSYS;
grant SELECT on sys.v_$wlm_db_mode to APPQOSSYS;
alter USER APPQOSSYS set container_data=all for "PUBLIC".v$wlm_db_mode;
grant SELECT on sys.gv_$wlm_db_mode to APPQOSSYS;
alter USER APPQOSSYS set container_data=all for "PUBLIC".gv$wlm_db_mode;
grant SELECT on V_$SYSMETRIC to APPQOSSYS;
grant SELECT on V_$PARAMETER to APPQOSSYS;

Rem Execute on DBMS_WLM permits DBWLM to upload classifiers used in tagging
grant execute on dbms_wlm to appqossys;

Rem Grant Resource Manager Admin privilege, so DBWLM can alter consumer
Rem   group mappings.
begin
dbms_resource_manager_privs.grant_system_privilege(
  grantee_name => 'APPQOSSYS',
  privilege_name => 'ADMINISTER_RESOURCE_MANAGER',
  admin_option => FALSE);
end;
/

Rem Revoke automatic grant of INHERIT PRIVILEGES from public
declare
  already_revoked exception;
  pragma exception_init(already_revoked,-01927);
begin
  execute immediate 'revoke inherit privileges on user appqossys from public';
exception
  when already_revoked then
    null;
end;
/

ALTER SESSION SET CURRENT_SCHEMA = APPQOSSYS;

CREATE TABLE wlm_metrics_stream
(
   timestamp          DATE,
   pc                 VARCHAR2(31),
   negative_interval  NUMBER
)
/

CREATE TABLE wlm_classifier_plan
(
   oper               NUMBER,
   nclsrs             NUMBER,
   clpcstr            VARCHAR2(4000),
   active             CHAR,
   seqno              NUMBER,
   timestamp          DATE,
   chksum             NUMBER
)
/

CREATE TABLE wlm_mpa_stream
(
   name               VARCHAR2(4000),
   serverorpool       VARCHAR2(8),
   risklevel          NUMBER
)
/

CREATE TABLE wlm_violation_stream
(
   timestamp         DATE,
   serverpool        VARCHAR2(4000),
   violation         VARCHAR2(4000)
)
/

CREATE TABLE wlm_feature_usage
(
   timestamp           TIMESTAMP,
   modebtime           TIMESTAMP,
   curmode             NUMBER,
   prevmode            NUMBER,
   maxpc               NUMBER,
   curnumpc            NUMBER,
   managed             NUMBER,
   measureonly         NUMBER,
   monitor             NUMBER,
   managed_cumtime     INTERVAL DAY(9) to SECOND(0),
   measureonly_cumtime INTERVAL DAY(9) to SECOND(0),
   monitor_cumtime     INTERVAL DAY(9) to SECOND(0),
   used                NUMBER,
   stats1              NUMBER,
   stats2              NUMBER,
   stats3              NUMBER,
   feature_info        VARCHAR2(4000)
)
/

Rem Allow the EM Agent access to this table for PSM alert purposes
CREATE OR REPLACE PUBLIC SYNONYM WLM_METRICS_STREAM
  FOR APPQOSSYS.WLM_METRICS_STREAM;
GRANT SELECT ON APPQOSSYS.wlm_metrics_stream TO DBSNMP;

Rem Allow the EM Agent access to WLM_CLASSIFIER_PLAN
CREATE OR REPLACE PUBLIC SYNONYM WLM_CLASSIFIER_PLAN
  FOR APPQOSSYS.WLM_CLASSIFIER_PLAN;
GRANT SELECT ON APPQOSSYS.wlm_classifier_plan TO DBSNMP;

Rem Allow the EM Agent access to this table for alert purposes
CREATE OR REPLACE PUBLIC SYNONYM WLM_MPA_STREAM
  FOR APPQOSSYS.WLM_MPA_STREAM;
GRANT SELECT ON APPQOSSYS.wlm_mpa_stream TO DBSNMP;

Rem Allow the EM Agent access to this table for alert purposes
CREATE OR REPLACE PUBLIC SYNONYM WLM_VIOLATION_STREAM
  FOR APPQOSSYS.WLM_VIOLATION_STREAM;
GRANT SELECT ON APPQOSSYS.wlm_violation_stream TO DBSNMP;

CREATE SYNONYM DBMS_WLM FOR SYS.DBMS_WLM;

ALTER SESSION SET CURRENT_SCHEMA = SYS;

@?/rdbms/admin/sqlsessend.sql
