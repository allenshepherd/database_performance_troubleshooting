set echo off
set verify off

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Gather stats on a given table


set termout on
accept htst_owner prompt 'Enter the owner name        : '
accept htst_table prompt 'Enter the table name        : '
accept htst_est   prompt 'Enter the estimate percent  : '
accept htst_inv   prompt 'Invalidate SQL? [Y or N]    : '
accept htst_idx   prompt 'Cascade to indexes? [Y or N]: '
accept htst_opt   prompt 'Method OPT clause?          : '
accept htst_sttab prompt 'Enter the stat table name   : '
accept htst_stown prompt 'Enter the stat table owner  : '
accept htst_stid  prompt 'Enter the stat id           : '


DECLARE
     v_owner    all_tables.owner%type := '&htst_owner' ;
     v_tab      all_tables.table_name%type := '&htst_table' ;
     v_est      number := &htst_est;
     v_inv      varchar2(5) := upper('&htst_inv');
     v_idx      varchar2(5) := upper('&htst_idx');
     v_opt      varchar2(50) := upper('&htst_opt');
     v_invbool  boolean ;
     v_idxbool  boolean ;
     v_stat_tab all_tables.table_name%type := upper('&htst_sttab');
     v_stat_own all_tables.owner%type := upper('&htst_stown');
     v_stat_id  varchar2(128) := upper('&htst_stid');

BEGIN

     v_invbool := case when substr(v_inv,1,1) = 'Y' then FALSE else TRUE end ;
     v_idxbool := case when substr(v_idx,1,1) = 'Y' then TRUE else FALSE end ;

     if v_opt is null then
        v_opt := 'FOR ALL COLUMNS SIZE 1' ;
     end if ;

     DBMS_STATS.GATHER_TABLE_STATS (
                v_owner,
                v_tab,
                method_opt=>v_opt,
                cascade=>v_idxbool,
                estimate_percent=>v_est,
                no_invalidate=>v_invbool,
                stattab=>v_stat_tab,
                statown=>v_stat_own,
                statid=>v_stat_id);
END;
/

undefine htst_owner
undefine htst_table
undefine htst_est
undefine htst_inv
undefine htst_idx
undefine htst_opt
undefine htst_sttab
undefine htst_stown
undefine hsts_stid
