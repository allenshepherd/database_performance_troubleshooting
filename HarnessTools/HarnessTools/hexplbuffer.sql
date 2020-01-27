set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem
rem
rem  Usage:   Place any select, insert, update, or delete in the SQL*Plus
rem           buffer but no need to execute it.  Place a blank line after
rem           the statement and follow the blank line with a call to this
rem           script.
rem           This script will:
rem              1. save the SQL*Plus buffer
rem              2. modify the buffer to prepend 'explain plan for' before
rem                 the statement
rem              3. execute the newly created explain plan statement
rem              4. query the plan table
rem              5. rollback the inserts performed by step 3
rem              6. restore the SQL*Plus buffer

set pause off autotrace off term off verify off
define pltab=plan_table

save explbig.tmp replace

col pid new_value explbig_statement_id

select userenv('sessionid') pid from dual;

delete from plan_table where statement_id = '&explbig_statement_id';
commit ;

get explbig.tmp

0 explain plan set statement_id='&explbig_statement_id' for
/

set termout off
col hexpl_maxlen_id new_value hexpl_maxlen_id

select max(length(id)) hexpl_maxlen_id
  from &pltab
where statement_id = '&explbig_statement_id';

set pagesize 500 termout on feedback off heading on

col plan format a60 heading 'Row Source Operation'
col cardinality heading 'CDN'
col id heading 'ID'
col parent_id heading 'Parent ID'
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
  from &pltab
start with statement_id='&explbig_statement_id'
       and id = 0
connect by prior id = parent_id
       and statement_id = '&explbig_statement_id';

col predicates format a74 wrap

select trim('* access - ' || id) || ' ' || access_predicates predicates
  from &pltab
 where statement_id = '&explbig_statement_id'
   and access_predicates is not null
UNION
select trim('* filter - ' || id) || ' ' || filter_predicates predicates
  from &pltab
 where statement_id = '&explbig_statement_id'
   and filter_predicates is not null;

set termout off

rollback;

get explbig.tmp

rem Change this if your OS uses some other command to remove files.
@hrmtempfile explbig.tmp

clear columns

undefine explbig_statement_id
undefine pltab

@hlogin
@henv
