set serveroutput on size 30000
set lines 220 pages 50000

PROMPT _________________________________________________________________________________________________________________________________________

PROMPT -                              CHECK DG SYNC/CONFIGURATION
PROMPT _________________________________________________________________________________________________________________________________________

declare
v_role varchar2(32);
v_name varchar2(32);
v_version varchar2(32);
v_lag number;
v_date varchar2(32);
v_date2 varchar2(32);
BEGIN
v_role  :='';
select database_role into v_role from v$database;
     DBMS_OUTPUT.NEW_LINE;
  IF v_role='PHYSICAL STANDBY' THEN
    select db_unique_name into v_name from v$database;
    select version into v_version from v$instance;
    select to_char(sysdate,'dd-Mon-YYYY hh24:mi:ss') into v_date from dual;
    select NVL(to_char(max(timestamp),'dd-Mon-YYYY hh24:mi:ss'),'         N/A               ') into v_date2 from gv$recovery_progress where item='Last Applied Redo';
    select NVL(to_number(round((current_date-max(timestamp))*24*60*60),'99999999999'),'360000') TIME into v_lag from gv$recovery_progress where item='Last Applied Redo';
    FOR record IN (  select (select DB_unique_name from v$database) Database, (select Database_role from v$database) Role, (select to_char(TIMESTAMP,'dd.mm.yyyy hh24:mi') from gv$recovery_progress where start_time=(select max(start_time) from gv$recovery_progress) and item='Last Applied Redo') SCN_TIMESTAMP, (select instance_name from gv$instance where inst_id=(select distinct(inst_id) from gv$recovery_progress)) Instance, (select decode(greatest(count(*),0),0,'TRUE','FALSE') from V$MANAGED_STANDBY where status='APPLYING_LOG') MRP from dual) LOOP
     DBMS_OUTPUT.PUT_LINE('           DATABASE         ->  '||  record.Database); 
     DBMS_OUTPUT.PUT_LINE('           DB ROLE          ->  '||  record.Role);
     DBMS_OUTPUT.PUT_LINE('           APPLY INSTANCE   ->  '|| record.instance);
     DBMS_OUTPUT.PUT_LINE('           APPLY RUNNING    ->  '|| record.mrp );
     DBMS_OUTPUT.PUT_LINE('           DB GAP           ->  '||  v_lag||' seconds');
    END LOOP;

  END IF;

  IF  v_lag > 1800  then
  DBMS_OUTPUT.PUT_LINE('      _____________LAG_DETECTED_________________');
     DBMS_OUTPUT.PUT_LINE('      This DB has a lag. Try investigating the following');
     DBMS_OUTPUT.PUT_LINE('              +dgmgrl configurations for lags');
     DBMS_OUTPUT.PUT_LINE('              +Check if password file issues exist (note files must be exactly the same');
     DBMS_OUTPUT.NEW_LINE; 

/*    FOR log IN (select * from v$archive_gap) loop
    DBMS_OUTPUT.PUT_LINE('      _____________GAP_DETECTED_________________');
     DBMS_OUTPUT.PUT_LINE('       This DB appears to be out of sync due to a gap. To remedy this issue, start by connecting');
     DBMS_OUTPUT.PUT_LINE('              to rman and issuing the below information to resolve gap issue the following command:');
     DBMS_OUTPUT.NEW_LINE;
     DBMS_OUTPUT.PUT_LINE('          RESTORE ARCHIVELOG FROM LOGSEQ '||log.LOW_SEQUENCE# ||' UNTIL LOGSEQ '|| log.HIGH_SEQUENCE# ||' THREAD '||log.THREAD#||';');
    DBMS_OUTPUT.PUT_LINE('      ___________________________________________');
    END LOOP;
*/
  END IF;
END;
/

PROMPT _________________________________________________________________________________________________________________________________________

PROMPT - HELPFUL COMMANDS
PROMPT -          ALTER DATABASE RECOVER MANAGED STANDBY DATABASE  THROUGH ALL SWITCHOVER DISCONNECT USING CURRENT LOGFILE;
PROMPT -          ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
PROMPT -          RESTORE ARCHIVELOG FROM LOGSEQ xxxx UNTIL LOGSEQ yyyy THREAD 1;
PROMPT _________________________________________________________________________________________________________________________________________


