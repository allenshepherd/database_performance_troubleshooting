Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      getawrviewloc.sql - SQL*Plus script to check if we are inside a PDB
Rem                     And if so, get the data source.
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem    This script cannot be run alone. The variables defined in this script
Rem    will be undefined in the scripts that call this.
Rem
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/getawrviewloc.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/getawrviewloc.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    kmorfoni   12/06/16 - specify con_dbid in AWR SQL report
Rem    arbalakr   08/16/16 - Fix default awr_location
Rem    arbalakr   07/14/16 - Created
Rem

Rem
Rem Check if we are at ROOT or non-CDB
Rem ====================================
set termout off;
set serveroutput on format wrapped;

column is_pdb new_value is_pdb noprint;

select (case when sys_context('userenv','dbid') = 
                  sys_context('userenv','con_dbid') then 0
            else 1 end) is_pdb
from dual;

Rem
Rem Inside a PDB, choose 'AWR_ROOT' as default awr_location.
Rem Otherwise, choose 'AWR_PDB' as default awr_location
Rem

column default_awr_location new_value default_awr_location noprint;
select case when &is_pdb = 1
            then 'AWR_ROOT'
            else 'AWR_PDB' end as default_awr_location
from dual;

column view_loc new_value view_loc noprint;
select '&default_awr_location' view_loc from dual;

column script new_value script noprint;
select case when  &is_pdb = 1 
            then '@ashrptipdb'            
            else '@ashrptinoop' end as script
from dual;

set termout on;
@&script

undefine script
