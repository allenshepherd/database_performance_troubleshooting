drop table hstat;

create table hstat as
select 0                report_section_id,
       0                always_print,
       -1               id,
       'CUST'           type,
       'elapsed time'   name
from dual
UNION
select 0                report_section_id,
       0                always_print,
       statistic#       id,
       'STAT'           type,
       name
  from v$statname
UNION
select 0                report_section_id,
       0                always_print,
       latch#+10000     id,
       'LATCH'          type,
       name
  from v$latchname
/

update hstat
   set always_print = 1
 where name in (
                'elapsed time',
                'db block gets',
                'consistent gets',
                'physical reads',
                'physical writes',
                'buffer is pinned count',
                'sorts (memory)',
                'sorts (disk)',
                'sorts (rows)',
                'redo size',
                'table scans (short tables)',
                'table scans (long tables)',
                'table scan blocks gotten',
                'table fetch by rowid',
                'cache buffers chains',
                'row cache objects',
                'shared pool',
                'library cache',
                'session logical reads',
                'session uga memory',
                'session uga memory max',
                'session pga memory',
                'session pga memory max',
                'db block changes',
                'index fast full scans (full)',
                'parse count (total)',
                'parse count (hard)',
                'execute count'
                )
/

commit;

create unique index hstat_id_idx on hstat(id);
