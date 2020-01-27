set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem

set echo on

drop table hscripts;

create table hscripts (
     script_name    varchar2(40)    not null
    ,script_desc    varchar2(250)
    ,parm1  varchar2(250)
    ,parm2  varchar2(250)
    ,parm3  varchar2(250)
    ,command_syntax         varchar2(400)
    ,script_type    varchar2(20)
    ,constraint HSCRIPTS_PK primary key (script_name)
);

rem script_type values:  INSTALL, TOOLSPACK, HARNESS, CLASSONLY

set echo on feed off

insert into hscripts values ('hstatcomp','Compares specific resource statistic (by pattern) for a scenario','Workspace','Exact statistic or pattern','View all scenarios (0) or n (number)','@hstatcomp <parm1> <parm2> <parm3>','HARNESS');
insert into hscripts values ('hsctrace','Displays specified lines from the extended SQL trace file for a scenario',null,null,null,'@hsctrace','HARNESS');
insert into hscripts values ('hsctracecmd','Displays specified lines from the extended SQL trace file for a scenario','Workspace','Scenario','What to View','@hsctracecmd <parm1> <parm2> <parm3>','HARNESS');
insert into hscripts values ('hkept','Displays list of triggers, procedures and packages currently in memory',null,null,null,'@hkept','TOOLSPACK');
insert into hscripts values ('hprofany','Creates a simple resource profile for any trace file','Trace file name',null,null,'@hprofany <parm1>','TOOLSPACK');
insert into hscripts values ('hprof','Creates a simple resource profile for a specified scenario',null,null,null,'@hprof','HARNESS');
insert into hscripts values ('hrmfile','Deletes a trace file from USER_DUMP_DEST',null,null,null,'@hrmfile','TOOLSPACK');
insert into hscripts values ('hinlist_rows','Displays estimated number of rows returned for a specified IN-List size','Column density','# Values in IN-List','# Rows in Table','@hinlist_rows <parm1> <parm2> <parm3>','TOOLSPACK');
insert into hscripts values ('hds','Displays block and row selectivity information for specified attributes',null,null,null,'@hds','TOOLSPACK');
insert into hscripts values ('hdsd','Displays block and row selectivity information for specified attributes but pulls total blocks and total rows from data dictionary',null,null,null,'@hdsd','TOOLSPACK');
insert into hscripts values ('hdsp','Displays block and row selectivity information for specified attributes for partitioned tables',null,null,null,'@hdsd','TOOLSPACK');
insert into hscripts values ('diff','Display differences between 2 scenarios',null,null,null,'@diff','HARNESS');
insert into hscripts values ('do','Create a scenario for a SELECT statement (using dbms_pipe)',null,null,null,'@do','HARNESS');
insert into hscripts values ('hcluf','Lists clustering factors for indexes on specified table',null,null,null,'@hcluf','TOOLSPACK');
insert into hscripts values ('hconfig','Configure harness user and execution parameters',null,null,null,'@hconfig','HARNESS');
insert into hscripts values ('hconnect','Replaces SQL*Plus connect (sets harness environment)','id/password@instance',null,null,'@hconnect <parm1>','HARNESS');
insert into hscripts values ('hcons','Displays constraints for specified table',null,null,null,'@hcons','TOOLSPACK');
insert into hscripts values ('hcosts','Displays scenario costs for all scenarios in a single workspace',null,null,null,'@hcosts','HARNESS');
insert into hscripts values ('hcreatestattab','Creates a "stattab" table for DBMS_STATS',null,null,null,'@hcreatstattab','TOOLSPACK');
insert into hscripts values ('hdts','Deletes table statistics for specified table',null,null,null,'@hdts','TOOLSPACK');
insert into hscripts values ('henv','Set SQL*Plus environment variables.',null,null,null,'@henv','HARNESS');
insert into hscripts values ('hexplbuffer','Display EXPLAIN PLAN for v9 - SQL must be in buffer',null,null,null,'@hexpl9','TOOLSPACK');
insert into hscripts values ('hexplain','Display EXPLAIN PLAN for v9 - SQL must be in .sql file',null,null,null,'@hexpl9a','TOOLSPACK');
insert into hscripts values ('hexpsstats','Exports schema statistics',null,null,null,'@hexpsstats','TOOLSPACK');
insert into hscripts values ('hexpsysstats','Exports system statistics',null,null,null,'@hexpsysstats','TOOLSPACK');
insert into hscripts values ('hexptstats','Exports table statistics',null,null,null,'@hexptstats','TOOLSPACK');
insert into hscripts values ('hfixvw','Displays view definition for a fixed view (ex: V$xxxxxxx)','view name',null,null,'@hfixvw <parm1>','TOOLSPACK');
insert into hscripts values ('hgetstats','Displays statistics for a table (more detail than hstats)',null,null,null,'@hgetstats','TOOLSPACK');
insert into hscripts values ('hgetsysstats','Displays system statistics',null,null,null,'@hgetsysstats','TOOLSPACK');
insert into hscripts values ('hgts','Gathers table statistics (100%, no histograms)',null,null,null,'@hgts','TOOLSPACK');
insert into hscripts values ('hhilo','Displays hi and lo column value statistic for specified column',null,null,null,'@hhilo','TOOLSPACK');
insert into hscripts values ('hhwm','Displays highwater mark and total rows in table',null,null,null,'@hhwm','TOOLSPACK');
insert into hscripts values ('hhwmd','Displays highwater mark and total rows in table plus block detail',null,null,null,'@hhwmd','TOOLSPACK');
insert into hscripts values ('hidxstats','Displays detailed index statistics (more detailed than hstats)',null,null,null,'@hidxstats','TOOLSPACK');
insert into hscripts values ('himpsstats','Imports schema statistics from stattab',null,null,null,'@himipsstats','TOOLSPACK');
insert into hscripts values ('himpsysstats','Imports system statistics from stattab',null,null,null,'@himpsysstats','TOOLSPACK');
insert into hscripts values ('himptstats','Imports table statistics from stattab',null,null,null,'@himptstats','TOOLSPACK');
insert into hscripts values ('hix','Display list of indexes','Owner.Table.Index - or any combination',null,null,'@hix <parm1>','HARNESS');
insert into hscripts values ('hlio','Displays comparison of LIO between all scenarios in one workspace',null,null,null,'@hlio','TOOLSPACK');
insert into hscripts values ('hloadtrc','Loads a trace file into the harness tables (independent of do.sql)',null,null,null,'@hloadtrc','HARNESS');
insert into hscripts values ('hlogin','Set Hotsos and SQL*Plus system variables and environment.',null,null,null,'@hlogin','HARNESS');
insert into hscripts values ('hlts','Locks table stats to prevent change from new stats collections',null,null,null,'@hlts','TOOLSPACK');
insert into hscripts values ('hmobj','Displays all_objects info for specified object','Object name',null,null,'@hmobj <parm1>','TOOLSPACK');
insert into hscripts values ('hmsess','Displays information about currently logged in session',null,null,null,'@hmsess','TOOLSPACK');
insert into hscripts values ('hmtab','Displays base table statistics for specified table','Table name',null,null,'@hmtab <parm1>','TOOLSPACK');
insert into hscripts values ('hnewplan','Copy execution plan from one outline to another','Source','Destination',null,'@hnewplan <parm1> <parm2>','TOOLSPACK');
insert into hscripts values ('hnobind','Finds candidate SQL statements that do not use bind variables','Length of SQL text substring',null,null,'@hnobind','TOOLSPACK');
insert into hscripts values ('hnostats','Displays list of objects that do not have statistics',null,null,null,'@hnostats','TOOLSPACK');
insert into hscripts values ('hopttrace','Displays 10053 trace data for a scenario',null,null,null,'@hopttrace','HARNESS');
insert into hscripts values ('horatrace','Displays 10046 trace data for a scenario',null,null,null,'@horatrace','HARNESS');
insert into hscripts values ('hparam','Displays parameters matching requested pattern','Parameter pattern',null,null,'@hparam <parm1>','TOOLSPACK');
insert into hscripts values ('hrank','Displays scenarios in elapsed time order',null,null,null,'@hrank','HARNESS');
insert into hscripts values ('hsess','Displays session connection information',null,null,null,'@hsess','TOOLSPACK');
insert into hscripts values ('hsetcstats','Manually change column statistics',null,null,null,'@hsetcstats','TOOLSPACK');
insert into hscripts values ('hsetistats','Manually change index statistics',null,null,null,'@hsetistats','TOOLSPACK');
insert into hscripts values ('hsettstats','Manually change table statistics',null,null,null,'@hsettstats','TOOLSPACK');
insert into hscripts values ('hsqltxt','Displays SQL statement for given hash value','Hash Value (from v$sqltext)',null,null,'@hsqltxt <parm1>','TOOLSPACK');
insert into hscripts values ('hsqlusers','Displays sessions which are currently executing a specified SQL','Hash Value (from v$sqltext)',null,null,'@hsqlusers <parm1>','TOOLSPACK');
insert into hscripts values ('hstats','Displays table and related index statistics for any owner.table',null,null,null,'@hstats','TOOLSPACK');
insert into hscripts values ('hstatslevel','Displays enabled/disabled statistics collection options',null,null,null,'@hstatslevel','TOOLSPACK');
insert into hscripts values ('htabstats','Displays table and related index statistics for any owner.table',null,null,null,'@htabstats','TOOLSPACK');
insert into hscripts values ('htopsql','Displays a list of top hitter SQL',null,null,null,'@htopsql','TOOLSPACK');
insert into hscripts values ('hults','Unlock table statistics for a specified owner.table',null,null,null,'@hults','TOOLSPACK');
insert into hscripts values ('htlist','Displays a list of all tables for schema from user_tables',null,null,null,'@htlist','TOOLSPACK');
insert into hscripts values ('htracefiles','Displays trace files list for a scenario',null,null,null,'@htracefiles','HARNESS');
insert into hscripts values ('hxplan','Displays explain plan from plan_table using dbms_xplan (v9 +)',null,null,null,'@hxplan','TOOLSPACK');
insert into hscripts values ('login','Set Hotsos and SQL*Plus system variables and environment.',null,null,null,'@login','HARNESS');
insert into hscripts values ('lssc','List of scenarios for one workspace',null,null,null,'@lssc','HARNESS');
insert into hscripts values ('lsscexpl','Displays the EXPLAIN PLAN for a scenario',null,null,null,'@lsscexpl','HARNESS');
insert into hscripts values ('lsscstat','List statistics for one scenario',null,null,null,'@lsscstat','HARNESS');
insert into hscripts values ('lsws','List of available workspaces',null,null,null,'@lsws','HARNESS');
insert into hscripts values ('mvsc','Moves a scenario to a different workspace',null,null,null,'@mvsc','HARNESS');
insert into hscripts values ('mvws','Changes a workspace name',null,null,null,'@mvws','HARNESS');
insert into hscripts values ('rmsc','Remove a scenario',null,null,null,'@rmsc','HARNESS');
insert into hscripts values ('rmws','Remove a workspace',null,null,null,'@rmws','HARNESS');
insert into hscripts values ('rmws_all','Removes all workspaces',null,null,null,'@rmws_all','HARNESS');

insert into hscripts values ('cleanup_all','Uninstalls the class tables (drops all tables)',null,null,null,'@cleanup_all','CLASSONLY');
insert into hscripts values ('clnudump','Remove trace files from user_dump_dest',null,null,null,'@clnudump','CLASSONLY');
insert into hscripts values ('hflush','Flushes buffer pool (BP) or shared pool (SP)','BP = buffer pool, SP = shared pool',null,null,'@hflush <parm1>','CLASSONLY');

insert into hscripts values ('hudump','Displays the contents of the USER_DUMP_DEST directory',null,null,null,'@hudump','CLASSONLY');
insert into hscripts values ('op_uninstall','Uninstalls the Test Harness objects',null,null,null,'@op_uninstall','CLASSONLY');
insert into hscripts values ('op_class_install','Installs the Test Harness objects',null,null,null,'@op_class_install','CLASSONLY');
insert into hscripts values ('setup_all','Installs the class tables and populates them with data',null,null,null,'@setup_all','CLASSONLY');
insert into hscripts values ('harness_grant_privs','Script to grant harness user permissions to sys-owned objects','User ID to grant privileges to',null,null,'@harness_grant_privs <parm1>','INSTALL');
insert into hscripts values ('harness_revoke_privs','Script to revoke harness user permissions to sys-owned objects','User ID to revoke privileges from',null,null,'@harness_revoke_privs <parm1>','INSTALL');
insert into hscripts values ('harness_sys_install','Create harness objects owned by sys',null,null,null,'@harness_sys_install','INSTALL');
insert into hscripts values ('harness_sys_uninstall','Drop harness objects owned by sys',null,null,null,'@harness_sys_uninstall','INSTALL');
insert into hscripts values ('harness_user_install','Create harness objects owned by harness user',null,null,null,'@harness_user_install','INSTALL');
insert into hscripts values ('harness_user_uninstall','Drop harness objects owned by harness user',null,null,null,'@harness_user_uninstall','INSTALL');
insert into hscripts values ('hotsospkg','Package script called during harness_sys_install.sql',null,null,null,'@hotsospkg','INSTALL');
insert into hscripts values ('hscenario','Table create and populate for HSCENARIO',null,null,null,'@hscenario','INSTALL');
insert into hscripts values ('hsessparam','Table create and populate for HSESSPARAM',null,null,null,'@hsessparam','INSTALL');
insert into hscripts values ('hscenario_sessparam','Table create and populate for HSCENARIO_SESSPARAM',null,null,null,'@hscenario_sessparam','INSTALL');
insert into hscripts values ('hreport_stat','Table create and populate for HREPORT_STAT',null,null,null,'@hreport_stat','INSTALL');
insert into hscripts values ('hstatt','Table create and populate for HSTAT',null,null,null,'@hstatt','INSTALL');
insert into hscripts values ('hscenario_snap_stat','Table create and populate for HSCENARIO_SNAP_STAT',null,null,null,'@hscenario_snap_stat','INSTALL');
insert into hscripts values ('hscenario_10046_line','Table create and populate for HSCENARIO_10046_LINE',null,null,null,'@hscenario_10046_line','INSTALL');
insert into hscripts values ('hscenario_10053_line','Table create and populate for HSCENARIO_10053_LINE',null,null,null,'@hscenario_10053_line','INSTALL');
insert into hscripts values ('hscenario_plans','Table create and populate for HSCENARIO_PLANS',null,null,null,'@hscenario_plans','INSTALL');
insert into hscripts values ('hconfigt','Table create and populate for HCONFIG',null,null,null,'@hconfigt','INSTALL');
insert into hscripts values ('hseq','Sequence for creating unique scenario ids',null,null,null,'@hseq','INSTALL');
insert into hscripts values ('hscenario_stat_diff','Create for view HSCENARIO_STAT_DIFF',null,null,null,'@hscenario_stat_diff','INSTALL');
insert into hscripts values ('hstat_diff','Create for view HSTAT_DIFF',null,null,null,'@hstat_diff','INSTALL');
insert into hscripts values ('get_snap_remote','Create for procedure GET_SNAP_REMOTE',null,null,null,'@get_snap_remote','INSTALL');
insert into hscripts values ('snap_request','Create for procedure SNAP_REQUEST',null,null,null,'@snap_request','INSTALL');
insert into hscripts values ('snap_request_fulfill','Create for procedure SNAP_REQUEST_FULFILL',null,null,null,'@snap_request_fulfill','INSTALL');
insert into hscripts values ('load_trace','Create for procedure LOAD_TRACE',null,null,null,'@load_trace','INSTALL');
insert into hscripts values ('print_table','Create for procedure PRINT_TABLE',null,null,null,'@print_table','INSTALL');
insert into hscripts values ('hboilraw','Create for procedure BOIL_RAW',null,null,null,'@hboilraw','INSTALL');

insert into hscripts values ('hsqlrunning','Displays a list of currently running SQL',null,null,null,'@hsqlrunning','TOOLSPACK');
insert into hscripts values ('hrecentsql','Displays a list of recently executed SQL for a user','User','Pattern string',null,'@hrecentsql <parm1> <parm2>','TOOLSPACK');
insert into hscripts values ('hvxplan','Displays execution plan info for a specified hash value','SQL Hash Value',null,null,'@hvxplan <parm1>','TOOLSPACK');

commit ;
set echo on feed on
