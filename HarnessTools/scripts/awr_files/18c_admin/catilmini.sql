Rem
Rem $Header: rdbms/admin/catilmini.sql /main/19 2017/09/25 10:44:30 sgdelgad Exp $
Rem
Rem catilmini.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catilmini.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catilmini.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catilmini.sql
Rem SQL_PHASE: CATILMINI
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sgdelgad    09/18/17 - Bug 26081503: Insert row used to serialize AIM
Rem                           RAC operations.
Rem    hlakshma    06/26/17 - (Bug-26353947): Insert row used to serialize AIM
Rem                           configuration operations
Rem    hlakshma    02/18/15 - Project# 45958 : Add new column values to 
Rem                           status row in heat_map_stat$
Rem    hlakshma    02/27/14 - Initialize the value of the ADO parameter
Rem                           policy_time (bug-17833609)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    hlakshma    12/05/13 - Initialize purge interval
Rem    hlakshma    05/14/13 - Backport fixes in 12.1 to MAIN
Rem    vradhakr    01/21/13 - XbranchMerge vradhakr_bug-16067485 from
Rem                           st_rdbms_12.1.0.1
Rem    vradhakr    01/06/13 - Bug 16067485: Add status row to heat_map_stat$.
Rem    maba        11/26/12 - log error for bug 14615619
Rem    hlakshma    06/18/12 - Provide reasonable defaults for storage tiering
Rem                           related ILM constants
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    hlakshma    01/03/12 - Add initializations for customizing ILM
Rem                           environment
Rem    hlakshma    11/11/11 - Insert entries for concurrency control
Rem    hlakshma    02/07/11 - ILM initialization
Rem    hlakshma    02/07/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

REM Add entires for controling ILM runtime environment

DECLARE
  attribute_exists       EXCEPTION;
  PRAGMA                EXCEPTION_INIT(attribute_exists, -00001);

BEGIN  
  /* ILM concurrency control */
  begin 
    insert into SYS.ILM_CONCURRENCY$ (last_exec_time, attribute)
                          values (systimestamp-1,1);
  exception
    when attribute_exists then
       null; 
  end;

  /* ILM RAC concurrency control for DBIM */
  begin 
    insert into SYS.ILM_CONCURRENCY$ (last_exec_time, attribute)
                          values (systimestamp-1,5);
  exception
    when attribute_exists then
       null; 
  end;
 
  /* ILM runtime related initialization */ 
  begin
    insert into SYS.ILM_PARAM$ (param#, param_name, param_value)
                        values (DBMS_ILM_ADMIN.enabled, 
                                'ENABLED', DBMS_ILM_ADMIN.ILM_ENABLED);
  exception
    when attribute_exists then
       null;
  end;
  
  begin
    insert into SYS.ILM_PARAM$ (param#, param_name, param_value)
                        values (DBMS_ILM_ADMIN.RETENTION_TIME, 
                                'RETENTION TIME', 
                                DBMS_ILM_ADMIN. ILM_RETENTION_TIME);
  exception
    when attribute_exists then
       null;
  end;

  begin
    insert into SYS.ILM_PARAM$ (param#, param_name, param_value)
                        values (DBMS_ILM_ADMIN.JOBLIMIT, 
                                'JOB LIMIT', 
                                DBMS_ILM_ADMIN.ILM_LIMIT_DEF);
  exception
    when attribute_exists then
       null;
  end;

  
  begin
    insert into SYS.ILM_PARAM$ (param#, param_name, param_value)
                        values (DBMS_ILM_ADMIN.EXECUTION_MODE, 
                                'EXECUTION MODE', 
                                DBMS_ILM_ADMIN.ILM_EXECUTION_ONLINE);
  exception
    when attribute_exists then
       null;
  end;

  begin
    insert into SYS.ILM_PARAM$ (param#, param_name, param_value)
                        values (DBMS_ILM_ADMIN.EXECUTION_INTERVAL, 

                                'EXECUTION INTERVAL', 15);
  exception
    when attribute_exists then
       null;
  end;
 
  begin
    insert into SYS.ILM_PARAM$ (param#, param_name               , param_value)
                        values (DBMS_ILM_ADMIN.TBS_PERCENT_USED , 'TBS PERCENT USED' , 85 );
  exception
    when attribute_exists then
      null;
  end;

  begin
    insert into SYS.ILM_PARAM$ (param#, param_name               , param_value)
                        values (DBMS_ILM_ADMIN.TBS_PERCENT_FREE , 'TBS PERCENT FREE', 25 );
  exception
    when attribute_exists then
      null;
  end;

   begin
    insert into SYS.ILM_PARAM$ (param#, param_name  , param_value)
                        values (DBMS_ILM_ADMIN.POLICY_TIME , 'POLICY TIME', 
                                DBMS_ILM_ADMIN.ILM_POLICY_IN_DAYS);
  exception
    when attribute_exists then
      null;
  end;

END;
/
 
REM Add subscriber to the scheduler event queue

DECLARE
  subscriber_exists     EXCEPTION;
  PRAGMA                EXCEPTION_INIT(subscriber_exists, -24034);
  subs                  SYS.AQ$_AGENT;

BEGIN

   subs := SYS.AQ$_AGENT('ILM_AGENT', NULL, NULL);
   DBMS_AQADM.ADD_SUBSCRIBER('SYS.SCHEDULER$_EVENT_QUEUE', subs);

EXCEPTION
  WHEN subscriber_exists THEN
    NULL;

END;
/

REM Register ILM callback

DECLARE 

BEGIN

DBMS_AQ.REGISTER (
          SYS.AQ$_REG_INFO_LIST(
             SYS.AQ$_REG_INFO(
               'SYS.SCHEDULER$_EVENT_QUEUE:ILM_AGENT',
                DBMS_AQ.NAMESPACE_AQ,
                'plsql://SYS.PRVT_ILM.ILM_CALLBACK',
                HEXTORAW('FF')
                )
             ),
         1
         );
exception
  when others then
    if sqlcode = -04063 then
      dbms_system.ksdwrt(1, 'Error-04063: scheduler$_event_queue will be re-validated');
    else
      raise;
    end if;

END;
/

REM Insert status row in heat_map_stat$

DECLARE 
  v_rows number;
BEGIN
  select count(*) into v_rows from heat_map_stat$ where obj#=-1;
  if (v_rows = 0) then
    insert into heat_map_stat$ (obj#, dataobj#, ts#, track_time, 
                                segment_access, flag, spare1, spare2,
                                spare3, n_write, n_fts,n_lookup)
    values (-1, -1, -1, sysdate, 0, 1, NULL,NULL,NULL, 0, 0, 0);
    commit;
  end if;
END;
/

REM Initialize sys.ado_imparam$ with special row to serialize parameter insert/
REM update

DECLARE 
  v_rows number;
BEGIN
-- param# = 0 is a special row that is used to serialize configuration of 
-- AIM parameters

  select count(*) into v_rows 
   from sys.ado_imparam$ 
  where param#=0;

  if (v_rows = 0) then
    insert into sys.ado_imparam$ (param#, param_name, param_value)
     values (0,'AIM CONFIG SERIALIZATION', 0);
    commit;
  end if;
END;
/

@?/rdbms/admin/sqlsessend.sql
