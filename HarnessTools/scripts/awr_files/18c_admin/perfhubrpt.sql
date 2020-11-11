Rem
Rem $Header: rdbms/admin/perfhubrpt.sql /main/5 2017/05/28 22:46:08 stanaya Exp $
Rem
Rem perfrpt.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      perfhubrpt.sql
Rem
Rem    DESCRIPTION
Rem      This is the script to generate perfhub active report.
Rem      User can generate perfhub report for the following cases:
Rem           a. From pdb:
Rem               1. For pdb, using awr_pdb_xxxx views
Rem                   -- uses pdb's con_dbid
Rem               2. For imported data, using awr_pdb_xxx views
Rem               3. For pdb, using awr_root_xxxx views
Rem                   -- uses ROOT's dbid
Rem           b. From Root:
Rem               1. For ROOT and  imported data 
Rem                     using awr_root_xxxs views
Rem               2. For PDB, using awr_root_xxxx views
Rem           c. From Non_CDB, using awr_root_xxxx views
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/perfhubrpt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/perfhubrpt.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    zhcai       08/22/16 - non cdb fix
Rem    yxie        08/17/16 - always generate hist report for imported data
Rem    sshastry    05/23/16 - Generate pdb perfhub report
Rem    jinhuo      06/23/14 - Make script more robust
Rem    jinhuo      02/12/14 - Improve time period selection
Rem    jinhuo      12/10/13 - Creation


set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 60 linesize 80 newpage 1 recsep off;
set trimspool on trimout on define "&" concat "." serveroutput on;

-- set date format
var date_fmt                 varchar2(32)
-- declare default start end time variables
var v_default_start          varchar2(19);
var v_default_end            varchar2(19);
var v_outer_interval         number;
var v_selected_interval      number;
-- msg to display
var msg varchar2(32767);
var is_root_selected         number;
begin
-- date format
:date_fmt := 'mm/dd/yyyy hh24:mi:ss';
end;
/

prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt ~                   PERFHUB ACTIVE REPORT                              ~
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt ~  This script will generate PerfHub active report according to        ~
prompt ~  users input.  The script will prompt users for the                  ~
prompt ~  following information:                                              ~
prompt ~     (1) report level: basic, typical or all                          ~
prompt ~     (2) dbid                                                         ~
prompt ~     (3) instance id                                                  ~
prompt ~     (4) selected time range                                          ~
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- prompt for report level
prompt 
prompt Specify the report level
prompt ~~~~~~~~~~~~~~~~~~~~~~~~
prompt *  Please enter basic, typical or all                     
prompt *  Report level "basic" - include tab contents but no further details
prompt *  Report level "typical" - include tab contents with details for top
prompt *                           SQL statements
prompt *  Report level "all" - include tab contents with details for all SQL
prompt *                       statements
prompt                      
accept report_level prompt "Please enter report level [typical]: "
prompt

set heading off;
var v_rpt_level varchar2(10);
begin
  select 'Using ' || rpt_level || ' for report level',
         rpt_level
  into :msg, :v_rpt_level
  from
    (select
         case lower(nvl('&&report_level' , 'typical'))
           when 'basic' then 'basic'
           when 'all'  then 'all'
           else 'typical'
         end rpt_level
     from sys.dual) t;
end;
/
print :msg;
set heading on;


-- get current database id and instance number
set termout off;
column db_inst_num  heading "Inst Num"  new_value db_inst_num  format 99999 noprint;
column db_inst_name heading "Instance"  new_value db_inst_name format a12 noprint;
column db_db_name   heading "DB Name"   new_value db_db_name   format a12 noprint;
column db_dbid      heading "DB Id"     new_value db_dbid noprint;

select d.dbid            db_dbid
     , d.name            db_db_name
     , i.instance_number db_inst_num
     , i.instance_name   db_inst_name
  from v$database d,
       v$instance i;
set termout on;

-- list databases and instances
set underline on;
column DBID        heading "DB Id"              format a12;
column a_db_name   heading "DB Name"            format a12;
column a_cont_name heading "AWR Data Source"    format a24;
column type        heading "Type"               format a24;

prompt
prompt
prompt Available Databases and Instances. 
prompt The database with * is current database
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

select distinct 
      (case 
          when a.a_dbid = sys_context('userenv','con_dbid') THEN '* '
          else '  ' 
       end) || a.a_dbid DBID, 
       a.a_db_name, a.a_cont_name, 
      (case    data_source_type
        when 'ROOT' THEN 
          case rac
            when 'YES' THEN 
              case cdb 
                when 'YES' THEN 'CDB, RAC'
                else 'NON_CDB, RAC'
              end   
            else 
              case cdb 
                when 'YES' THEN 'CDB'
                else 'NON_CDB'
              end 
          end
        when 'PDB' THEN 
          case rac
            when 'YES' THEN 'PDB, RAC'
            else 'PDB'
          end  
        when 'IMPORTED' THEN
          case rac
            when 'YES' THEN 
              case cdb
                when 'YES' THEN 
                  case 
                    when (sys.dbms_sqltune_util2.is_imported_pdb(a.a_dbid) =  'yes')
                      then 'IMPORTED, RAC, PDB'
                    else
                      'IMPORTED, RAC, CDB'
                  end    
                else 'IMPORTED, RAC'
              end
            when 'NO' THEN
              case cdb
                when 'YES' THEN 
                  case 
                    when (sys.dbms_sqltune_util2.is_imported_pdb(a.a_dbid) =  'yes')
                      then 'IMPORTED, PDB'
                    else 'IMPORTED, CDB'
                  end  
                else 'IMPORTED' 
              end  
            else 'IMPORTED' 
          end  
      end ) type 
  from
(
  select wr.dbid a_dbid,
         wr.db_name a_db_name,
         (case wr.cdb
            when 'YES' THEN 'CDB$ROOT'
            else wr.db_name -- in non_cdb, display db_name
          end) a_cont_name,
         sys.dbms_sqltune_util2.resolve_database_type(wr.dbid) data_source_type,
         wr.parallel rac, wr.cdb cdb, wr.con_id con_id 
  from awr_root_database_instance wr
  UNION ALL
  select wr.dbid a_dbid,
           wr.db_name a_db_name,
           nvl(pi.pdb_name, wr.db_name) data_source,
           sys.dbms_sqltune_util2.resolve_database_type(wr.dbid) data_source_type,
           wr.parallel rac, wr.cdb cdb, wr.con_id con_id
  from awr_pdb_database_instance wr,
       awr_pdb_pdb_instance pi
  where wr.dbid  = pi.con_dbid (+) 
        and sys_context('userenv', 'con_id') > 2
) a ;   



prompt
prompt Specify the database ID
prompt ~~~~~~~~~~~~~~~~~~~~~~~
accept dbid prompt "Please enter database ID [&db_dbid]: " 
prompt

set heading off;
var v_dbid number;
var v_valid_dbid number;

declare 
    INVALID_DBID_EXCEPTION EXCEPTION;
begin
    :v_valid_dbid := 0;

  select 'Using ' || nvl('&&dbid', '&db_dbid') || ' for database ID'
         , to_number(nvl('&&dbid', '&db_dbid'), '9999999999')
  into :msg, :v_dbid
  from sys.dual;

     -- check whether user entered dbid is current dbid or current con_dbid
     if ( (:v_dbid = sys_context('userenv','dbid')) or 
          (:v_dbid = sys_context('userenv','con_dbid'))
        ) 
     then
        :v_valid_dbid := 1; --valid dbid
     end if;

     -- If :v_valid_dbid is still 0, then it could be imported dbid.
     -- Note: In case of imported RAC NON-CDB/CDB, value of :v_valid_dbid 
     -- could be >= 1, due to multiple rows for each instance in the view
     if (:v_valid_dbid = 0) 
     then 
         select count(*) into :v_valid_dbid from awr_pdb_database_instance 
         where dbid = :v_dbid;
     end if;

     -- If not a valid dbid, throw an exception.
     if (:v_valid_dbid = 0) then 
        RAISE INVALID_DBID_EXCEPTION;
     end if;

exception
  when others then
   select 'Invalid/No Database ID was entered. Using &db_dbid for Database ID'
       , &db_dbid
    into :msg, :v_dbid
    from sys.dual;
end;
/
print :msg;
set heading on;

var is_root_selected number;

set heading off;
declare
    v_is_root number;
begin
    if (:v_dbid = sys_context('userenv','dbid')) then
        v_is_root := 1;
    else 
        v_is_root := 0;
    end if;

    select v_is_root into :is_root_selected from dual;

end;
/

set heading on;

-- get current database id and instance number
set termout off;
column c_dbid      heading "DB Id"              new_value dbid noprint a32;
column con_name     heading "Container Name"    new_value con_name noprint;

select distinct name con_name, dbid c_dbid, con_id 
  from v$containers
  where con_id <> 2
  order by con_id desc;

set termout on;

set heading off;
select 'Please specify the container name for which to generate the report' 
from dual 
where :is_root_selected = 1 and sys_context('userenv','con_id') = 1;

select 'List of available open container(s):' 
from dual
where :is_root_selected = 1 and sys_context('userenv','con_id') = 1;

select 'Note: Upto 10 open container(s) on this instance are displayed below.
Enter a valid container name.' 
from dual
where :is_root_selected = 1 and sys_context('userenv','con_id') = 1;

set heading on;

column con_dbid   heading "Container DBID"   new_value con_dbid;
column cont_name  heading "Container Name"   new_value cont_name format a24;

select
 (case when rn < 11 then cont_name else '...' end) cont_name,
 (case when rn < 11 then con_dbid else null end) con_dbid,
 (case when rn < 11 then type else null end) type
from
(select
 (case
      when name = sys_context('userenv','con_name') THEN '* '
      else ' '
      end) || name cont_name,
    dbid con_dbid, decode (name, 'CDB$ROOT', 'CDB', 'PDB')  type, rownum rn
  from v$containers
  where
  :is_root_selected = 1 and
  con_id <> 2 and
  open_mode='READ WRITE' and
  rownum < 12 and
  sys_context('userenv','con_id') = 1);

-- accept con_name prompt "Please enter container name [&con_name]: " 
-- prompt

set echo off;
SET TERMOUT OFF
column con_name_prompt new_value con_name_prompt
column con_name new_value con_name
set define off

select case 
         when ( (:is_root_selected = 1) 
                 and (sys_context('userenv','con_id') = 1) )
            then 'Please enter container name: ' 
         else 'Generating report for selected data source. Please press Enter'
       end "con_name_prompt"  
from dual;

set define on
SET TERMOUT ON

prompt
accept con_name prompt '&&con_name_prompt'
prompt

-- -----------------------------------
set heading off;
var v_con_name varchar2(128);
var v_con_name_valid number;

declare 
    INVALID_CON_NAME_EXCEPTION EXCEPTION;
begin
    :v_con_name_valid := 1;

    if ( (:is_root_selected = 1) and (sys_context('userenv','con_id') = 1) ) 
    then
        select 'Using ' || nvl('&&con_name', 'CDB$ROOT') || 
                    ' for container name' , nvl('&&con_name', 'CDB$ROOT')
        into :msg, :v_con_name
        from sys.dual 
        where :is_root_selected = 1
        ;

        select 1 into :v_con_name_valid from sys.dual where 
        -- :is_root_selected = 1 and 
        :v_con_name in (
            select name from v$containers 
            where con_id <> 2 and open_mode='READ WRITE'
            );

         if (:v_con_name_valid = 0) then 
            RAISE INVALID_CON_NAME_EXCEPTION;
         end if;
    else 
    -- reset msg
        :msg := ''; 
    end if;

exception
 when TOO_MANY_ROWS then 
    null;
 when NO_DATA_FOUND then 
    -- null;
    select 
    'Invalid/No container name was entered. Using CDB$ROOT for container name'
       , 'CDB$ROOT'     -- nvl('&con_name', 'CDB$ROOT')
    into :msg, :v_con_name
    from sys.dual;

 when INVALID_CON_NAME_EXCEPTION then
    select 
    'Invalid/No container name was entered. Using CDB$ROOT for container name'
       , 'CDB$ROOT'     -- nvl('&con_name', 'CDB$ROOT')
    into :msg, :v_con_name
    from sys.dual;
 when others then 
    null;
end;
/

print :msg;
set heading on;

-- -----------------------------------

-- create instance prompt script file dynamically
-- No need to query dba_hist_database_instance.
-- awr_pdb_database_instance has the same data as dba_hist_database_instance 
-- in SI,ROOT,PDB case(For imported and local awr data)
var is_rac number;
begin
  select is_rac into :is_rac
  from (
    select case when parallel = 'YES'
                  then 1
                else 0
           end is_rac
    from v$instance
    where :v_dbid=&db_dbid
    union 
    select case when parallel = 'YES'
                  then 1
                else 0
           end is_rac 
    from  awr_pdb_database_instance
    where dbid=:v_dbid and :v_dbid!=&db_dbid 
  );
end;
/

set echo off;
SET TERMOUT OFF
column inst_prompt new_value inst_prompt
column inst_id new_value inst_id
set define off

select case :is_rac 
         when 1 then 'Please enter instance number [all instances]:' 
         else 'Single Instance Database. Please press Enter' 
       end "inst_prompt"  
from dual;

set define on
SET TERMOUT ON

prompt
prompt Specify the Instance Number
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
accept inst_id prompt '&&inst_prompt'
prompt

set heading off;
var v_inst_id number;
begin
  select case :is_rac 
           when 1 then 
             'Using ' || decode(lower('&&inst_id'), 
                                null, 'all instances', 
                                'null', 'all instances',                                  
                                '&&inst_id')  || ' for instance'
           else null
         end,
         case :is_rac
           when 1 then 
             to_number(
               decode(lower('&&inst_id'), 'all instances', null, 
                                  'null', null, '&&inst_id'),
               '9999999999'
             )
           else null
         end
  into :msg, :v_inst_id
  from sys.dual;
exception
  when others then
    select 
      'Invalid instance number was entered. Using "all instances" for instance'
      , null
    into :msg, :v_inst_id
    from sys.dual;
end;
/
print :msg;
set heading on;

-- default start time
column start_time heading "Default Start Time" new_value start_time format a19;
-- default end time and available end time 
-- (current time or max time in historical data)
column end_time   heading "Default End Time" new_value end_time   format a19;
-- available start time (min time in historical data)
column a_start_time heading "Oldest Available Snapshot Time" new_value a_start_time format a30;


var pdb_type number;
begin
    -- IMPORTED => imported into current container/pdb
    -- NOTE: Even at root, awr_pdb_xxxx views contains imported data
    if (sys.dbms_sqltune_util2.resolve_database_type(:v_dbid)  
         in (sys.dbms_sqltune_util2.DB_TYPE_PDB, 
             sys.dbms_sqltune_util2.DB_TYPE_IMP) ) 
    then
       :pdb_type := 2;
    else 
       :pdb_type := 0;
    end if;
end;
/


-- adjusted half seconds to snapshot end interval to cover precision lost

select a.start_time, a.end_time, a.a_start_time
    FROM
       ( select to_char(start_time, :date_fmt) start_time,
               to_char(max_time,:date_fmt) end_time,
               to_char(min_time, :date_fmt) a_start_time
        from (
          select case :v_dbid when &db_dbid then rmx.max_time
                              else mx.max_time 
                 end max_time, 
                 case :v_dbid when &db_dbid then rmx.min_time
                              else mx.min_time 
                 end min_time, 
                 case :v_dbid when &db_dbid then rmx.start_time
                      else greatest(nvl(smx.sec_max_time, mx.max_time - 1/24), 
                                            mx.min_time
                                   )
                 end start_time
          from (
            select max(end_interval_time + 1/172800) max_time,
                   min(end_interval_time - 1/172800) min_time
            from awr_pdb_snapshot    
            where dbid=:v_dbid and :v_dbid != &db_dbid
          ) mx, 
          (
            select max(end_interval_time +  1/172800) sec_max_time
            from awr_pdb_snapshot sn, (
              select snap_id, dbid
              from (
                select snap_id, dbid,
                       row_number() over (order by snap_id desc) as row_num 
                from (
                  select distinct snap_id, dbid 
                  from awr_pdb_snapshot 
                  where dbid=:v_dbid and :v_dbid != &db_dbid
                )
              ) 
              where row_num=2
            ) ssn 
            where sn.snap_id=ssn.snap_id
            and sn.dbid=ssn.dbid
            and sn.dbid=:v_dbid and :v_dbid != &db_dbid
          ) smx,
          ( 
            select sysdate max_time,
             nvl(min(end_interval_time - 1/172800), sysdate - 1/24) min_time,
                   sysdate - 5/1440 start_time
            from v$database d
            left outer join awr_pdb_snapshot h on  d.dbid=h.dbid
            where d.dbid=:v_dbid and :v_dbid=&db_dbid
          ) rmx
        ) where :pdb_type = 2
        UNION ALL
        select to_char(start_time, :date_fmt) start_time,
               to_char(max_time,:date_fmt) end_time,
               to_char(min_time, :date_fmt) a_start_time
        from (
          select case :v_dbid when &db_dbid then rmx.max_time
                              else mx.max_time 
                 end max_time, 
                 case :v_dbid when &db_dbid then rmx.min_time
                              else mx.min_time 
                 end min_time, 
                 case :v_dbid when &db_dbid then rmx.start_time
                      else greatest(nvl(smx.sec_max_time, mx.max_time - 1/24), 
                                            mx.min_time
                                   )
                 end start_time
          from (
            select max(end_interval_time + 1/172800) max_time,
                   min(end_interval_time - 1/172800) min_time
            from awr_root_snapshot    
            where dbid=:v_dbid and :v_dbid != &db_dbid
          ) mx, 
          (
            select max(end_interval_time +  1/172800) sec_max_time
            from awr_root_snapshot sn, (
              select snap_id, dbid
              from (
                select snap_id, dbid,
                       row_number() over (order by snap_id desc) as row_num 
                from (
                  select distinct snap_id, dbid 
                  from awr_root_snapshot 
                  where dbid=:v_dbid and :v_dbid != &db_dbid
                )
              ) 
              where row_num=2
            ) ssn 
            where sn.snap_id=ssn.snap_id
            and sn.dbid=ssn.dbid
            and sn.dbid=:v_dbid and :v_dbid != &db_dbid
          ) smx,
          ( 
            select sysdate max_time,
              nvl(min(end_interval_time - 1/172800), sysdate - 1/24) min_time,
                   sysdate - 5/1440 start_time
            from v$database d
            left outer join awr_root_snapshot h on  d.dbid=h.dbid
            where d.dbid=:v_dbid and :v_dbid=&db_dbid
          ) rmx
        ) where :pdb_type = 0 
       ) a ;

-- instructions for time range selection
prompt 
prompt Specify selected time range
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt *  If the selected time range is in the past hour, report data will be 
prompt *    retrieved from V$ views.
prompt *  If the selected time range is over 1 hour ago, report data
prompt *    will be retrieved from AWR.
prompt *  If the dbid selected is not for the current database, only AWR data 
prompt *    is available.
prompt *
prompt *  Valid input formats:
prompt *      To specify absolute time:
prompt *        [mm/dd[/yyyy]] hh24:mi[:ss] 
prompt *        Examples: 02/23/14 14:30:15
prompt *                  02/23 14:30:15
prompt *                  14:30:15
prompt *                  14:30
prompt *      To specify relative time: (start with '-' sign)
prompt *        -[hh24:]mi                
prompt *        Examples: -1:15  (SYSDATE - 1 Hr 15 Mins)
prompt *                  -25    (SYSDATE - 25 Mins)
prompt
accept selected_start_time prompt "Please enter start time [&start_time]: "
prompt
accept selected_end_time prompt "Please enter end time [&end_time]: "
prompt

whenever sqlerror exit;
var v_in_starttime varchar2(19);
var v_in_endtime varchar2(19);
declare
  -- the function to get date from input
  FUNCTION get_time_from_input( btime_in IN VARCHAR2 )
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

    my_fmt        VARCHAR2(100) := 'MM/DD/YYYY HH24:MI:SS';
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
        date_part := date_part || '/' || TO_CHAR(sysdate,'YYYY');
      END IF;
    ELSE
      date_part := TO_CHAR(sysdate,'MM/DD/YYYY');
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
                                 'input format for time ' || '"' || 
                                 TRIM(btime_in) || '"' );
      end;
    END IF;

    /* Invalid input */
    raise_application_error( -20500, 
                             'Invalid input! Cannot recognize ' ||
                             'input format for time ' || '"' || 
                             TRIM(btime_in) || '"' );
    RETURN NULL;

  END get_time_from_input;

begin
  :v_in_endtime := to_char(
                     get_time_from_input(
                       nvl('&&selected_end_time' , '&end_time')
                     ),
                     :date_fmt
                   );
  :v_in_starttime := to_char(
                     get_time_from_input(
                        nvl('&&selected_start_time' , '&start_time')
                     ),
                     :date_fmt
                   );
end;
/
whenever sqlerror continue;

-- determine time range selection
set heading off;
var v_selected_start_time varchar2(19);
var v_selected_end_time varchar2(19);
var v_outer_start_time varchar2(19);
var v_outer_end_time varchar2(19);
var v_is_realtime number;
var v_selected_interval number;
var v_outer_interval number;
begin
    -- determine whether realtime or not
    -- determine selected end time - earliest between user input
    -- and available end time
    select to_char(selected_end_time,:date_fmt),
           to_char(selected_end_time, :date_fmt), 
           case 
             when selected_end_time < sysdate - 1/24
               then 0
             else 1 
           end is_realtime
      into :msg, :v_selected_end_time, :v_is_realtime
    from (
      select case when selected_end_time < a_start_time 
                       or selected_end_time > end_time
                    then end_time
                  else selected_end_time
             end selected_end_time,
             end_time,
             start_time
      from (
      -- convert string to date
        select to_date(:v_in_endtime, :date_fmt) selected_end_time,
               to_date('&end_time', :date_fmt) end_time,
               to_date('&start_time', :date_fmt) start_time,
               to_date('&a_start_time', :date_fmt) a_start_time
        from sys.dual
      )
    );

   -- override: for imported data, we always generate historical report
    if (sys.dbms_sqltune_util2.resolve_database_type(:v_dbid)  
         = sys.dbms_sqltune_util2.DB_TYPE_IMP) 
    then
       :v_is_realtime := 0;
    end if;

    -- determine default intervals
    select case :v_is_realtime when 1 then 5/1440 else 1/24 end,
           case :v_is_realtime when 1 then 1/24 else 1 end
    into :v_selected_interval, :v_outer_interval
    from sys.dual;
end;
/

set heading on;
set termout off;
-- adjust a_start_time for realtime
select case :v_is_realtime 
         when 1 then to_char(
                       to_date('&end_time', :date_fmt) - 1/24, 
                       :date_fmt)
         else '&a_start_time'
       end a_start_time
from sys.dual;

set termout on;
set heading off;

begin

  -- validate start time
  -- if it is earlier than selected end time, set it to 
  -- end time - default interval; if it is earlier than 
  -- available start time, set it to available start time
  select to_char(
             greatest(selected_start_time, a_start_time),
           :date_fmt)
  into :v_selected_start_time
  from (             
    select selected_end_time,
           case when selected_start_time > selected_end_time
                  then selected_end_time - :v_selected_interval
                when selected_start_time < a_start_time
                  then a_start_time
                else selected_start_time
           end selected_start_time,
           end_time,
           start_time,
           a_start_time
    from (
      select to_date(:v_selected_end_time, 
                     :date_fmt) selected_end_time,
             to_date(:v_in_starttime, :date_fmt) selected_start_time,
             to_date('&end_time', :date_fmt) end_time,
             to_date('&start_time', :date_fmt) start_time,
             to_date('&a_start_time', :date_fmt) a_start_time
        from sys.dual
    )
  );
  -- outer end time is default end time in realtime or
  -- selected end time in historical mode
  -- outer start time is default start time in realtime or
  --   or selected start time in historical mode
  select to_char(
           case :v_is_realtime when 1
             then end_time
             else selected_end_time
           end, 
           :date_fmt
         ) outer_end_time,
         to_char(
           case :v_is_realtime when 1
             then a_start_time
             else greatest(
                    a_start_time, 
                    least(
                      selected_start_time, 
                      selected_end_time-:v_outer_interval
                    )
                  )
           end,
           :date_fmt
         ) outer_start_time
  into :v_outer_end_time,
       :v_outer_start_time
  from (    
    select to_date(:v_selected_end_time, :date_fmt) selected_end_time,
           to_date(
             :v_selected_start_time, 
             :date_fmt) selected_start_time,
           to_date('&end_time', :date_fmt) end_time,
           to_date('&start_time', :date_fmt) start_time,
           to_date('&a_start_time', :date_fmt) a_start_time
      from sys.dual
  );

  -- construct message
  select 'Generating report for ' || :v_selected_start_time  
           || ' - ' || :msg
  into :msg
  from sys.dual;
end;
/
print :msg;

-- default report name
column rpt_name new_value rpt_name format a100;

set termout off;
select 'perfhub_'
         || case :v_is_realtime 
              when 1 then 'rt_' 
              else 'ht_' 
            end
         || case when :v_inst_id is null then ''
                 else :v_inst_id || '_'
            end
         || to_char(to_date(:v_selected_end_time, :date_fmt), 'mmddhh24mi')
         || '.html' rpt_name
from sys.dual;
set termout on;
set heading on;

-- prmpt for report name
prompt 
prompt Specify the Report Name
prompt ~~~~~~~~~~~~~~~~~~~~~~~
accept report_name prompt "Please enter report name [&rpt_name]: "
prompt

set heading off;
column report_name new_value report_name noprint
select 'Generating report ' || nvl('&&report_name', '&rpt_name') 
         || ' ...',
       nvl('&&report_name', '&rpt_name') report_name
from sys.dual;
set heading on;

-- turn off compression
-- alter session set events 'emx_control compress_xml=none';

set termout off;
SET TRIMSPOOL ON
SET TRIM ON
SET PAGESIZE 0 LINESIZE 32767
set long 10000000 longchunksize 10000000
SET VERIFY OFF
set heading off;
set underline off;

-- generate the report
spool &report_name create;

select dbms_perf.report_perfhub(is_realtime=>:v_is_realtime,
                         outer_start_time=>
                           to_date(:v_outer_start_time, :date_fmt),
                         outer_end_time=>
                           to_date(:v_outer_end_time, :date_fmt),
                         selected_start_time=>
                           to_date(:v_selected_start_time, :date_fmt),
                         selected_end_time=>
                           to_date(:v_selected_end_time, :date_fmt),
                         inst_id=>:v_inst_id,
                         dbid=>:v_dbid,
                         report_level=>:v_rpt_level,
                         con_name => :v_con_name)
from sys.dual;

spool off;

set termout on;
prompt
prompt Report written to &report_name.
prompt

undefine report_level;
undefine dbid;
undefine inst_id;
undefine inst_prompt;
undefine selected_end_time;
undefine selected_start_time;
undefine report_name;

set underline on
set verify on

set long 80 longchunksize 80
set pagesize 60;
set linesize 78 termout on feedback 6 heading on;
