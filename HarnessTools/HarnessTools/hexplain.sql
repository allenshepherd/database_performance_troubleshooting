set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem
rem  Usage:   Place any select, insert, update, or delete in the SQL*Plus
rem           .sql file.
rem       Parameters:
rem       1 - .sql file name

set pause off autotrace off

define pltab=plan_table

accept htst_dofile  prompt 'Enter .sql file name (without extension): '
define plan_file = '&htst_dofile'

set echo off termout off heading off feedback off verify off

get &plan_file

save explbig.tmp replace

col pid new_value explbig_statement_id

select userenv('sessionid') pid from dual;

delete from plan_table where statement_id = '&explbig_statement_id';
commit ;

get explbig.tmp

0 explain plan set statement_id='&explbig_statement_id' for
/

col hexpl_maxlen_id new_value hexpl_maxlen_id

select max(length(id)) hexpl_maxlen_id
  from plan_table
where statement_id = '&explbig_statement_id';

set pagesize 500 termout on feedback off heading on

col plan format a60 heading 'Row Source Operation'
col cardinality heading 'CDN'
col id heading 'ID'
col parent_id heading 'PID'
col pred format a1 heading ''

select cardinality,
       id,
       case when access_predicates is null and
                 filter_predicates is null
            then '' else '*'
            end as pred,
       parent_id, rpad ( ' ' , level-1 ) || operation ||
       decode(options, null, '', ' '||options) ||
       decode(object_name, null, '', ' '||object_name) ||
       decode(cost, null, '', ' ('||cost||')') plan
  from plan_table
start with statement_id='&explbig_statement_id'
       and id = 0
connect by prior id = parent_id
       and statement_id = '&explbig_statement_id';

col predicates format a80 word_wrap

select trim('* access - ' || id) || ' ' || access_predicates predicates
  from plan_table
 where statement_id = '&explbig_statement_id'
   and access_predicates is not null
UNION
select trim('* filter - ' || id) || ' ' || filter_predicates predicates
  from plan_table
 where statement_id = '&explbig_statement_id'
   and filter_predicates is not null;

set termout off

rollback;

get explbig.tmp

rem Change this if your OS uses some other command to remove files.
@hrmtempfile explbig.tmp

undefine explbig_statement_id
undefine hexpl_debug
undefine 1
undefine 2
undefine plan_file
undefine pltab

set termout on

clear columns

@hlogin
@henv
