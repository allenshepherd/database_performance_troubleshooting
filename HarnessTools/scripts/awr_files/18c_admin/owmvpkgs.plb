@@?/rdbms/admin/sqlsessstart.sql
begin
  for prec in (select admin_option, common
               from dba_sys_privs
               where grantee = 'WMSYS' and
                     privilege = 'SELECT ANY DICTIONARY' and
                     (admin_option = 'YES' or common = 'NO')) loop

    execute immediate 'revoke select any dictionary from wmsys' || (case when sys_context('userenv', 'cdb_name') is null then null else (case prec.common when 'YES' then ' container=all' else ' container=current' end) end) ;
  end loop ;

  execute immediate 'grant select any dictionary to wmsys' ;
end;
/
grant inherit privileges on user sys to wmsys ;
grant execute on sys.dbms_registry to wmsys ;
create or replace package wmsys.owm_vscript_pkg wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
54f 28c
tEd2wFzaRB5yS9Zcswkug/LWzywwgzvDLm0FfC/NrZ3mB+Z2FpkTVeY4rgvefgr3bDIh8m63
KABWDD5MgyX5c8XcPIHqy5n2L0c0804Zz4UcXcvyjiT5PyC15JKSTik6v/jkzcxnXfLVqO/z
o0gLZ9N72CvmRnVOs4xXd7sN8i02bQDI2KlhMc0z62B62EWu42aj+oMx60wpihz06729vVkx
lX63VUm05+ZKkRLKASkkyNOEUL419yzpi5YlKDJXQP1q9w0phcbbbMKXAC93hVqTFw3fQiDm
g/JIo53VH+PV5yVYVAVfqCyCPy8+ZTWs2EtAHC+emeNAlUWMo/5mx8F0rJBOvuSC8tRgW8uT
wOiJSYWkViVcSk6QSEVO1Sbn1m1l8cuu3FEYRmZ8L6r0BFK0lVL9wUzb1NoGNe8HvZC7mwEY
0W9UPSYp6TTjkRhTQu8ZfQzhArlpFymgnHmk0k4hXK5UfYujhCAlwzwD2702Y+dj741jAFPN
TwnEbwUtEnifu7WdmB/R/fAp4Cxk1NQoYR/ekJUh0uZej0KCmXz7nHew6Y2YSHKgYlsyoPih
bF6PSJ5oKKmxd4b8kjROZOKfJhx+aUHZ55nMkD8rcF9bpz3mV8KoT7ig8no0+Fu28XHi

/
@@?/rdbms/admin/sqlsessend.sql
