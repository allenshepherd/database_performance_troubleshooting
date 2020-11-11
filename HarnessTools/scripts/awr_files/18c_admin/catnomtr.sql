Rem
Rem $Header: rdbms/admin/catnomtr.sql /main/2 2017/05/28 22:46:03 stanaya Exp $
Rem
Rem catnomtr.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnomtr.sql - Remove DBMS_MONITOR package and tables
Rem
Rem    DESCRIPTION
Rem      Removes everything related to the DBMS_MONITOR package
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnomtr.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnomtr.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    aime        04/25/03 - aime_going_to_main
Rem    mramache    01/23/03 - add v_$sys_time_model view
Rem    atsukerm    01/17/03 - remove aggregation tables and views
Rem    atsukerm    12/05/02 - atsukerm_e2etr
Rem    atsukerm    10/25/02 - Created
-- Drop the views and public synonyms
drop public synonym DBA_ENABLED_TRACES;
drop view DBA_ENABLED_TRACES;
drop public synonym DBA_ENABLED_AGGREGATIONS;
drop view DBA_ENABLED_AGGREGATIONS;
drop public synonym v$client_stats;
drop view v_$client_stats;
drop public synonym gv$client_stats;
drop view gv_$client_stats;
drop public synonym v$serv_mod_act_stats;
drop view v_$serv_mod_act_stats;
drop public synonym gv$serv_mod_act_stats;
drop view gv_$serv_mod_act_stats;
drop public synonym v$sys_time_model;
drop view v_$sys_time_model;
drop public synonym gv$sys_time_model;
drop view gv_$sys_time_model;

-- Drop the base tables
drop table WRI$_TRACING_ENABLED;
drop table WRI$_AGGREGATION_ENABLED;

-- Drop packages and libraries
drop package DBMS_MONITOR;
drop library DBMS_MONITOR_LIB;
