Rem
Rem $Header: rdbms/admin/catnorul.sql /main/10 2017/05/28 22:46:03 stanaya Exp $
Rem
Rem catnorul.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnorul.sql - Uninstall script for Rule Manager 
Rem
Rem    DESCRIPTION
Rem      This script un-installs the Rule Manager component 
Rem
Rem    NOTES
Rem      See Documentation
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnorul.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnorul.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    sdas        05/21/13 - invoke ADM_EXPFIL_SYSTRIG iff valid or compiles
Rem    sdas        03/15/13 - to avoid -1432, issue drop public synonym only
Rem                           for existing synonyms
Rem    sdas        01/22/13 - bug 16303916: defensive use of
Rem                           dbms_xmlschema.deleteschema
Rem    sdas        01/21/13 - XbranchMerge sdas_bug-16038193 from
Rem                           st_rdbms_12.1.0.1
Rem    jerrede     01/14/13 - XbranchMerge jerrede_bug-16097914 from
Rem                           st_rdbms_12.1.0.1
Rem    sdas        01/11/13 - drop in catnoexf: type RLM$ROWIDTAB
Rem    dvoss       01/11/13 - disable database guard
Rem    jerrede     01/03/13 - Bug#16025279 Add Error Checking
Rem    ayalaman    05/14/07 - drop irrelev java classes
Rem    ayalaman    02/16/05 - drop the truncate system trigger with uninstall 
Rem    ayalaman    07/16/04 - negation with delay dictionary table 
Rem    ayalaman    06/29/04 - rules with negation and deadline 
Rem    ayalaman    04/23/04 - ayalaman_rule_manager_support 
Rem    ayalaman    04/02/04 - Created
Rem


REM 
REM Drop the Rule Manager specific objects from the EXFSYS schema
REM 
EXECUTE dbms_registry.removing('RUL');

ALTER SESSION DISABLE GUARD;

begin
  dbms_scheduler.drop_job(job_name => 'EXFSYS.RLM$EVTCLEANUP', force=> true);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -27475 THEN NULL; ELSE RAISE; END IF;
END;
/

begin
  dbms_scheduler.drop_job(job_name => 'EXFSYS.RLM$SCHDNEGACTION', force=> true);EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -27475 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop package exfsys.dbms_rlmgr_dr';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop package exfsys.dbms_rlmgr_ir';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop package exfsys.dbms_rlmgr';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop package exfsys.dbms_rlmgr_utl';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop package exfsys.rlm$timecentral';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop package exfsys.dbms_rlmgr_depasexp';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop package exfsys.dbms_rlmgr_exp';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop package exfsys.dbms_rlm4j_dictmaint'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop package exfsys.dbms_rlmgr_irpk'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop package exfsys.ADM_RLMGR_SYSTRIG'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop package exfsys.DBMS_RLM4J_DICTMAINT_DR'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop procedure exfsys.RLM$CREATE_SCHEDULER_JOBS'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop procedure exfsys.RLM$PROCESSCOLLPREDS'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop procedure exfsys.RLM$PROCCLLGRPBY'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop function exfsys.RLM$UNIQUETAG'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop function exfsys.RLM$PARSEOBYCLS'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop function exfsys.RLM$OPTIMEQCLS'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop function exfsys.RLM$EQLLSRNONEG'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

--exec dbms_java.dropjava('-schema exfsys oracle.expfil.rlmgr.HavingExpParser.java');
--exec dbms_java.dropjava('-schema exfsys oracle.expfil.rlmgr.RLMAggregateRules.java');
--exec dbms_java.dropjava('-schema exfsys oracle.expfil.rlmgr.RLMPropertiesParser.java');

BEGIN
  execute immediate 'drop table exfsys.RLM$COLLGRPBYSPEC'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$dmlevttrigs';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$orderclsals';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm4j$ruleset'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm4j$evtstructs'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.RLM4J$ATTRALIASES'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$schactlist';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$schacterrs';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$equalspec';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$eventstruct';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$rulesetprivs';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$validprivs';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$primevttypemap'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$rsprimevents';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$errcode';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$jobqueue';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$ruleset';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$rulesetstcode';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop table exfsys.rlm$parsedcond';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.RLM$INCRRSLTMAPS';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.USER_RLM4J_ATTRIBUTE_ALIASES'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.user_rlm4j_evtst'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.user_rlm4j_ruleclasses'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.user_rlmgr_event_structs';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.all_rlmgr_event_structs';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.adm_rlmgr_event_structs';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.user_rlmgr_rule_classes';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.all_rlmgr_rule_classes';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.adm_rlmgr_rule_classes';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.user_rlmgr_privileges';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.adm_rlmgr_privileges';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.user_rlmgr_rule_class_status';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.all_rlmgr_rule_class_status';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.adm_rlmgr_rule_class_status';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.all_rlmgr_rule_class_opcodes';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.user_rlmgr_comprcls_properties'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.all_rlmgr_comprcls_properties'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.adm_rlmgr_comprcls_properties'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.user_rlmgr_action_errors';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.all_rlmgr_action_errors';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop view exfsys.adm_rlmgr_action_errors';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -942 THEN NULL; ELSE RAISE; END IF;
END;
/

-- drop public synonyms --
BEGIN
for idx in (
select object_name 
  from all_objects 
 where owner='PUBLIC' and object_type='SYNONYM'
   and object_name in (
 upper('dbms_rlmgr')
,upper('user_rlmgr_rule_classes')
,upper('all_rlmgr_rule_classes')
,upper('user_rlmgr_privileges')
,upper('rlm$eventids')
,upper('user_rlmgr_event_structs')
,upper('all_rlmgr_event_structs')
,upper('user_rlmgr_rule_class_status')
,upper('all_rlmgr_rule_class_status')
,upper('user_rlmgr_comprcls_properties')
,upper('all_rlmgr_comprcls_properties')
)
)
loop
  begin
    execute immediate 'drop public synonym ' || idx.object_name;
    --SYS.DBMS_SYSTEM.KSDWRT(SYS.DBMS_SYSTEM.TRACE_FILE, 'DONE: DROP PUBLIC SYNONYM' || idx.object_name);
  EXCEPTION
    WHEN OTHERS THEN IF SQLCODE = -1432 THEN NULL; ELSE RAISE; END IF;
  end;
end loop;
END;
/

/*
BEGIN
  execute immediate 'drop public synonym dbms_rlmgr';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -1432 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop public synonym user_rlmgr_rule_classes';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -1432 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop public synonym all_rlmgr_rule_classes';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -1432 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop public synonym user_rlmgr_privileges';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -1432 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop public synonym rlm$eventids';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -1432 THEN NULL; ELSE RAISE; END IF;
END;
/

--drop public synonym all_rlmgr_privileges;

BEGIN
  execute immediate 'drop public synonym user_rlmgr_event_structs';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -1432 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop public synonym all_rlmgr_event_structs';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -1432 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop public synonym user_rlmgr_rule_class_status';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -1432 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop public synonym all_rlmgr_rule_class_status';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -1432 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop public synonym user_rlmgr_comprcls_properties';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -1432 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop public synonym all_rlmgr_comprcls_properties';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -1432 THEN NULL; ELSE RAISE; END IF;
END;
/

---drop public synonym rlm$equalattr;
*/

BEGIN
  execute immediate 'drop type exfsys.rlm$keyval'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop type exfsys.rlm$dateval';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/ 

BEGIN
  --execute immediate 'drop type exfsys.rlm$rowidtab';
  NULL;
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop type exfsys.rlm$numval';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop type exfsys.rlm$equalattr';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop type exfsys.rlm$collpreds';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop type exfsys.rlm$collevents';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop type exfsys.rlm$collevent';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop type exfsys.RLM$APNUMBLST'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop type exfsys.RLM$APMULTVCL'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop type exfsys.RLM$APVARCLST'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop function exfsys.rlm$eqlchk';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  execute immediate 'drop function exfsys.rlm$seqchk';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4043 THEN NULL; ELSE RAISE; END IF;
END;
/

begin
  -- since this is a fresh install, delete any actions left behind --
  -- from past installations --
  delete from sys.expdepact$ where schema = 'EXFSYS'
     and package = 'DBMS_RLMGR_DEPASEXP';

  delete from sys.exppkgact$ where package = 'DBMS_RLMGR_DEPASEXP'
    and schema = 'EXFSYS';

end;
/

ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;

declare
  usr varchar2(30) := 'EXFSYS';
  url varchar2(200) := 'http://xmlns.oracle.com/rlmgr/rclsprop.xsd';
  cnt pls_integer := 0;
BEGIN
  execute immediate
    'SELECT count(*) FROM dba_xml_schemas WHERE owner=:1 AND schema_url=:2'
    into cnt using usr, url;
  if (cnt > 0) then
    dbms_xmlschema.deleteschema(url, dbms_xmlschema.DELETE_CASCADE);
  end if;
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -31000 THEN NULL; ELSE RAISE; END IF;
END;
/

declare
  usr varchar2(30) := 'EXFSYS';
  url varchar2(200) := 'http://xmlns.oracle.com/rlmgr/rulecond.xsd';
  cnt pls_integer := 0;
BEGIN
  execute immediate
    'SELECT count(*) FROM dba_xml_schemas WHERE owner=:1 AND schema_url=:2'
    into cnt using usr, url;
  if (cnt > 0) then
    dbms_xmlschema.deleteschema(url, dbms_xmlschema.DELETE_CASCADE);
  end if;
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -31000 THEN NULL; ELSE RAISE; END IF;
END;
/

-- create the system trigger without rule manager maintenance --
-- drop the truncate trigger for rule class tables --
BEGIN
  execute immediate 'drop trigger exfsys.rlmgr_truncate_maint'; 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -4080 THEN NULL; ELSE RAISE; END IF;
END;
/

create or replace package adm_rlmgr_systrig as

  procedure pre_dropobj_maint (objowner VARCHAR2,
                               objname  VARCHAR2,
                               objtype  VARCHAR2);

  --- @todo: system trigger to avoid truncate of the rules table --
  --- @todo: consider all other operations such as renaming tables, --
  ---        dropping columns from the table and altering the tables --
end adm_rlmgr_systrig;
/

create or replace package body adm_rlmgr_systrig as

  /*************************************************************************/
  /*** PRE_DROPOBJ_MAINT : Pre drop maintenance for rule manager objects ***/
  /*************************************************************************/
  procedure pre_dropobj_maint (objowner VARCHAR2,
                               objname  VARCHAR2,
                               objtype  VARCHAR2) as
  begin
    return;
  end;
end;
/

-- invoke ADM_EXPFIL_SYSTRIG subprogram only if it is valid or compiles ok
set serveroutput on;

declare
  valid_cnt   pls_integer := 0;
  skip        boolean := false;
  stmt        varchar2(4000);
begin
  select count(*) into valid_cnt from all_objects
   where owner = 'EXFSYS'
     and object_name = 'ADM_EXPFIL_SYSTRIG'
     and object_type IN ('PACKAGE','PACKAGE BODY')
     and status = 'VALID';
  sys.dbms_output.put_line('valid_cnt=' || valid_cnt);

  if (valid_cnt < 2) then
    begin
      stmt := 'alter package EXFSYS.ADM_EXPFIL_SYSTRIG compile';
      execute immediate stmt;

      stmt := 'alter package EXFSYS.ADM_EXPFIL_SYSTRIG compile body';
      execute immediate stmt;

      EXCEPTION when others then 
       sys.dbms_output.put_line('Failed to compile: stmt=' || stmt || 
                                chr(10) || 'SQLERRM=' || SQLERRM);
       skip := true;
    end;
  end if;

  if not(skip) then
    begin
      execute immediate 'begin exfsys.adm_expfil_systrig.create_systrig_dropobj; end;';
      EXCEPTION when others then 
       sys.dbms_output.put_line('Failed to execute: exfsys.adm_expfil_systrig.create_systrig_dropobj ' ||
                                chr(10) || 'SQLERRM=' || SQLERRM);
    end;
  end if;
end;
/

set serveroutput off;

ALTER SESSION SET CURRENT_SCHEMA = SYS;

EXECUTE dbms_registry.removed('RUL');
