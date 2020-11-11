Rem
Rem $Header: rdbms/admin/rtaddmrpti.sql /main/1 2013/10/08 15:17:11 arbalakr Exp $
Rem
Rem rtaddmrpti.sql
Rem
Rem Copyright (c) 2013, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      rtaddmrpti.sql - SQL Plus script to generate a real time ADDM report
Rem
Rem    DESCRIPTION
Rem     
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    arbalakr    07/15/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/rtaddmrpti.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA


--
-- Specify default values for the report name prefix and extension.
-- These would be ignored if the variable'report_name' is defined.
define report_name_prefix = 'rtaddmrpt';
define report_name_extension = '.html';
define report_name_suffix = 'MMDD_HH24MI';
define default_report_duration = 60;
define rtaddm_time_format = 'DD/MM/YYYY HH24:MI:SS';

set heading on echo off feedback off verify off underline on timing off;

Rem
Rem Get dbid and instid 
Rem ====================

column inst_id heading "Inst Num" format 99999;
column db_id heading "Db Id";
prompt
prompt
prompt Instances in this Report reposistory
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set heading on

select distinct dbid db_id, instance_number inst_id from dba_hist_reports;

prompt
prompt Default to current database

column dbid new_value dbid;

set heading off
select 'Using database id:',
        (case when '&&dbid' IS NULL
              then d.dbid
              else to_number('&&dbid') end ) || ' ' as dbid
from v$database d;
set heading on


Rem
Rem Get btime
Rem =========
prompt
prompt Enter begin time for report:
prompt
prompt --    Valid input formats:
prompt --      To specify absolute begin time:
prompt --        [MM/DD[/YY]] HH24:MI[:SS]
prompt --        Examples: 02/23/03 14:30:15 
prompt --                  02/23 14:30:15
prompt --                  14:30:15
prompt --                  14:30
prompt --      To specify relative begin time: (start with '-' sign)
prompt --         -[HH24:]MI
prompt --         Examples: -1:15 (SYSDATE - 1 Hr 15 Mins)
prompt --                   -25   (SYSDATE - 25 Mins)
prompt
prompt Default to -&&default_report_duration mins
prompt Report begin time specified: &&begin_time
prompt

--
-- Set up the binds for btime
whenever sqlerror exit;
variable btime varchar2(30);
declare
  lbtime_in   varchar2(100);
  begin_time  date;
  
  FUNCTION get_time_from_begin_time( btime_in IN VARCHAR2)
    RETURN DATE
  IS
    first_char    VARCHAR2(2);
    in_str        VARCHAR2(100);

    past_hrs      NUMBER;
    past_mins     NUMBER;
    pos           NUMBER;

    num_slashes   NUMBER := 0;
    num_colons    NUMBER := 0;
    date_part     VARCHAR2(100);
    time_part     VARCHAR2(100);

    my_fmt        VARCHAR2(100) := 'MM/DD/YY HH24:MI:SS';
  BEGIN
    in_str := TRIM(btime_in);
    first_char := SUBSTR(in_str, 1, 1);

    /* Handle relative input format starting with a -ve sign, first */
    IF (first_char = '-') THEN
      in_str := SUBSTR(in_str, 2);
      pos := INSTR(in_str,':');
      IF (pos = 0) THEN
        past_hrs := 0;
        past_mins := TO_NUMBER(in_str);
      ELSE
        past_hrs := TO_NUMBER(SUBSTR(in_str,1,pos-1));
        past_mins := TO_NUMBER(SUBSTR(in_str,pos+1));
      END IF;
      
      IF (past_mins = 0 AND past_hrs = 0) THEN
        /* Invalid input */
        raise_application_error( -20500, 
                                 'Invalid input! Cannot recognize ' ||
                                 'input format for begin_time ' || '"' || 
                                 TRIM(btime_in) || '"' );
        RETURN NULL;
      END IF;

      RETURN (sysdate - past_hrs/24 - past_mins/1440);
    END IF;

    /* Handle absolute input format now.
       Fill out all the missing optional parts of the input string
       to make it look like 'my_fmt' first. Then just do "return to_date()".
     */
    FOR pos in 1..LENGTH(in_str) LOOP
      IF (SUBSTR(in_str,pos,1) = '/') THEN
        num_slashes := num_slashes + 1;
      END IF;
      IF (SUBSTR(in_str,pos,1) = ':') THEN
        num_colons := num_colons + 1;
      END IF;
    END LOOP;

    IF (num_slashes > 0) THEN
      pos := INSTR(in_str,' ');
      date_part := TRIM(SUBSTR(in_str,1,pos-1));
      time_part := TRIM(SUBSTR(in_str,pos+1));

      IF (num_slashes = 1) THEN
        date_part := date_part || '/' || TO_CHAR(sysdate,'YY');
      END IF;
    ELSE
      date_part := TO_CHAR(sysdate,'MM/DD/YY');
      time_part := in_str;
    END IF;

    IF (num_colons > 0) THEN
      IF (num_colons = 1) THEN
        time_part := time_part || ':00';
      END IF;
      in_str := date_part || ' ' || time_part;
      begin
        RETURN TO_DATE(in_str, my_fmt);
      exception
        when others then
        /* Invalid input */
        raise_application_error( -20500, 
                                 'Invalid input! Cannot recognize ' ||
                                 'input format for begin_time ' || '"' || 
                                 TRIM(btime_in) || '"' );
      end;
    END IF;

    /* Invalid input */
    raise_application_error( -20500, 
                             'Invalid input! Cannot recognize ' ||
                             'input format for begin_time ' || '"' || 
                             TRIM(btime_in) || '"' );
    RETURN NULL;

  END get_time_from_begin_time;

begin
  lbtime_in  := nvl('&&begin_time', '-' || &&default_report_duration);
  begin_time := get_time_from_begin_time(lbtime_in);
  :btime := to_char( begin_time, '&&rtaddm_time_format' );
end;
/
whenever sqlerror continue;

Rem
Rem Get etime
Rem =========
prompt Enter duration in minutes starting from begin time: 
prompt Defaults to SYSDATE - begin_time 
prompt Press Enter to analyze till current time
prompt Report duration specified:   &&duration

--
--  Set up the binds for etime
variable etime varchar2(30);
declare
  duration          number;
  since_begin_time  number;
  begin_time        date;
  end_time          date;
begin
  -- First calculate minutes since begin_time
  begin_time := to_date( :btime, '&&rtaddm_time_format' );
  since_begin_time := (sysdate - begin_time)*1440;

  -- Default to since_begin_time
  duration   := nvl('&&duration', since_begin_time);

  -- Put upper bound on user input to not go into the future
  -- only if begin_time is not already in the future
  if (duration > since_begin_time AND since_begin_time > 0) then
    duration := since_begin_time;
  end if;

  -- Calculate end_time and :etime
  end_time := begin_time + duration/1440;
  :etime := to_char( end_time, '&&rtaddm_time_format' );
end;
/

column nl80 format a80 newline;
set heading off
select 'Using ' || :btime || ' as report begin time' as nl80,
       'Using ' || :etime || ' as report end time' as nl80
from   dual;
set heading on


prompt
prompt Report ids in this workload repository.
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt

whenever sqlerror exit
declare
  cnt number;
begin 
  SELECT count(*) INTO cnt
  FROM dba_hist_reports
  WHERE component_name = 'perf'
    AND generation_time > to_date(:btime, '&&rtaddm_time_format')
    AND generation_time <= to_date(:etime, '&&rtaddm_time_format')
    AND dbid = &dbid;
  IF (cnt = 0) THEN
    raise_application_error(-20000, 'No valid reports found in the specified time range. Please specify a different begin and end time');
  END IF;
end;
/


column report_id format 9999999;
column trigger_cause format a25;
column impact format a10;
column time format a20;
set linesize 100;


SELECT reps.dbid, reps.report_id, 
       to_char(generation_time, '&&rtaddm_time_format') as time,
       reps_xml."trigger_cause", reps_xml."impact"
FROM dba_hist_reports reps,
     XMLTABLE('/report_repository_summary/trigger' 
         PASSING XMLTYPE(reps.report_summary)
         COLUMNS "trigger_cause" varchar2(30)
                  PATH '/trigger/@id_desc',
                 "impact" varchar2(30)
                  PATH '/trigger/@impact') reps_xml
WHERE reps.component_name = 'perf'
  AND reps.generation_time > to_date(:btime, '&&rtaddm_time_format')
  AND reps.generation_time <= to_date(:etime, '&&rtaddm_time_format')
  AND reps.dbid = &dbid
ORDER BY reps.report_id;       
 
prompt
prompt Select a report id from the list. If the report id list is empty,
prompt please select a different begin time and end time. 
prompt Report id specified : &&report_id

Rem
Rem Get Report Name
Rem ===============

set termout off;
column dflt_name new_value dflt_name noprint;
select '&&report_name_prefix' || '_'
       || to_char( to_date(:etime, '&&rtaddm_time_format'),
                   '&&report_name_suffix') 
       || '&&report_name_extension' dflt_name
from dual;
set termout on;

prompt Specify the Report Name
prompt ~~~~~~~~~~~~~~~~~~~~~~~~
prompt The default report file name is &&dflt_name.. To use this name, 
prompt press <return> to continue, otherwise enter an alternative.

column report_name_msg new_value report_name_msg;
column report_name new_value report_name;
set heading off;
select 'Using the report name' 
       as report_name_msg,
       nvl('&&report_name', '&dflt_name') as report_name
from dual;
set heading on;


Rem
Rem Spool out the report
Rem =====================

set termout on heading off;
set pagesize 0
set linesize 32000
set long 1000000
set trimspool on
variable version varchar2(32);

column report_header format a32000 newline;
column report_body format a32000 newline;
column report_footer format a32000 newline;

variable report_xml CLOB;
variable report_version VARCHAR2(32);
begin
  SELECT dbms_perf.report_addm_watchdog_xml(&report_id).getClobVal()
  INTO :report_xml
  FROM dual;

  SELECT extractvalue(xmltype(:report_xml), '/report/@db_version')
  INTO :version
  FROM dual;
end;
/

spool &report_name;

select '<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <base href="http://download.oracle.com/otn_software/"/>
    <script id="scriptVersion" language="javascript" type="text/javascript">var version = "'|| :version || '";</script>
    <script id="scriptActiveReportInit" language="javascript" type="text/javascript" src="emviewers/scripts/activeReportInit.js">
      <!-- script defining sendXML() -->
    </script>
  </head>
  <body onload="sendXML();">
    <script type="text/javascript">writeIframe();</script>
    <script id="fxtmodel" type="text/xml">
      <!--FXTMODEL-->' as report_header
from dual;
select :report_xml as report_body from dual;
select'<!--FXTMODEL--></script></body></html>' as report_footer from dual;
spool off;

prompt Report written to &report_name.
-- Undefine all defines
undefine report_name_prefix;
undefine report_name_extension;
undefine report_name_suffix;
undefine default_report_duration;
undefine rtaddm_time_format;


-- Undefine all 'new_value's
undefine report_name
undefine report_name_msg
undefine dflt_name

-- Undefine all 'input variables'
undefine begin_time
undefine duration
undefine report_id
undefine dbid


-- End of script file
