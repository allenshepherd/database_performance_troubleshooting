@@?/rdbms/admin/sqlsessstart.sql
create or replace view dba_analyze_objects (owner, object_name, object_type) as
       select u.name, o.name, decode(o.type#, 2, 'TABLE', 3, 'CLUSTER')
       from sys.user$ u, sys.obj$ o, sys.tab$ t
       where o.owner# = u.user#
       and   o.obj# = t.obj# (+)
       and   t.bobj# is null
       and   o.type# in (2,3)
       and   bitand(o.flags, 128) = 0 
       and   o.linkname is null
/
create or replace public synonym dba_analyze_objects
                             for sys.dba_analyze_objects;
execute CDBView.create_cdbview(false,'SYS','DBA_ANALYZE_OBJECTS','CDB_ANALYZE_OBJECTS');
create or replace public synonym cdb_analyze_objects
                             for sys.cdb_analyze_objects;
@?/rdbms/admin/sqlsessend.sql
