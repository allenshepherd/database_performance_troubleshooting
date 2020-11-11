Rem
Rem catspd.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catspd.sql - Sql Plan Directive catalog views
Rem
Rem    DESCRIPTION
Rem      This file contain view definitions of Sql Plan Directives.
Rem
Rem    NOTES
Rem      The views in this file can be created only after creating dbms_spd
Rem      package as the views refer to functions in the package.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catspd.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catspd.sql
Rem SQL_PHASE: CATSPD
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    schakkap    05/15/15 - #(20918167) add SQL STATEMENT ENVIRONMENT
Rem    schakkap    03/24/15 - directive for DS result
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    schakkap    06/08/13 - #(16571451): dba_sql_plan_directives changes
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    schakkap    10/03/11 - project SPD (31794): display fixed tables,
Rem                           add auto_drop column
Rem    schakkap    07/04/11 - project SPD (31794): fix last_used timestamp
Rem    schakkap    04/01/11 - project SPD (31794): add catalog views
Rem    schakkap    04/01/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem _BASE* views
Rem The following views are not exposed. They just decode flags, collist etc
Rem from base dictionary tables.
Rem

CREATE OR REPLACE VIEW "_BASE_OPT_FINDING" (
    f_id,
    f_own#,
    type,
    reason,
    ctime,
    tab_cnt
) AS
SELECT
    f.f_id,
    f_own#,
    decode(f.type, 1, 'OPTIMIZER_BAD_DECISION', 
                   2, 'DYNAMIC_SAMPLING_STATEMENT',
                      'UNKNOWN'),
    decode(f.reason, 1, 'SINGLE TABLE CARDINALITY MISESTIMATE', 
                     2, 'JOIN CARDINALITY MISESTIMATE',
                     3, 'QUERY BLOCK CARDINALITY MISESTIMATE',
                     4, 'GROUP BY CARDINALITY MISESTIMATE',
                     5, 'HAVING CARDINALITY MISESTIMATE',
                     6, 'SPREADSHEET CARDINALITY MISESTIMATE',
                     7, 'VERIFY CARDINALITY ESTIMATE',
                        'UNKNOWN'),
    cast(f.ctime as timestamp),
    f.tab_cnt
FROM
    sys.opt_finding$ f
/

CREATE OR REPLACE VIEW "_BASE_OPT_FINDING_OBJ" (
    f_id,
    f_obj#,
    obj_type,
    col_list,
    cvec_size,
    nrows,
    notes
) AS
SELECT
    f.f_id,
    f.f_obj#,
    f.obj_type,
    f.col_list,
    f.cvec_size,
    f.nrows,
    xmltype(
      '<obj_note>' ||
         '<equality_predicates_only>' || 
           decode(bitand(f.flags, 1), 0, 'NO', 'YES') ||
         '</equality_predicates_only>' ||
         '<simple_column_predicates_only>' || 
           decode(bitand(f.flags, 2), 0, 'NO', 'YES') ||
         '</simple_column_predicates_only>' ||
         '<index_access_by_join_predicates>' || 
           decode(bitand(f.flags, 4), 0, 'NO', 'YES') ||
         '</index_access_by_join_predicates>' || 
         '<filter_on_joining_object>' || 
           decode(bitand(f.flags, 8), 0, 'NO', 'YES') ||
         '</filter_on_joining_object>' ||
       '</obj_note>')  notes
FROM
    sys.opt_finding_obj$ f
/

CREATE OR REPLACE VIEW "_BASE_OPT_FINDING_OBJ_COL" (
    f_id,
    f_obj#,
    obj_type,
    notes,
    intcol#
) AS
SELECT
    f.f_id,
    f.f_obj#,
    f.obj_type,
    f.notes,
    c.column_value
FROM
    sys."_BASE_OPT_FINDING_OBJ" f,
    table(sys.dbms_spd_internal.get_vec_set_ids(f.col_list, f.cvec_size)) c
WHERE f.col_list is not null
/

CREATE OR REPLACE VIEW "_BASE_OPT_DIRECTIVE" (
    dir_own#,
    dir_id,
    f_id,
    type,
    internal_state,
    auto_drop,
    redundant,
    enabled,
    created,
    last_modified,
    last_used
) AS
SELECT
    d.dir_own#,
    d.dir_id,
    d.f_id,
    decode(type, 1, 'DYNAMIC_SAMPLING', 
                 2, 'DYNAMIC_SAMPLING_RESULT',
                    'UNKNOWN'),
    decode(state, 1, 'NEW', 
                 2, 'MISSING_STATS',
                 3, 'HAS_STATS',
                 5, 'PERMANENT',
                    'UNKNOWN'),
    decode(bitand(flags, 1), 1, 'YES', 'NO'),
    decode(bitand(flags, 2), 2, 'YES', 'NO'),
    decode(bitand(flags, 4), 4, 'NO', 'YES'),
    cast(d.created as timestamp),
    cast(d.last_modified as timestamp),
    -- Please see QOSD_DAYS_TO_UPDATE and QOSD_PLUS_SECONDS for more details 
    -- about 6.5
    cast(d.last_used as timestamp) - NUMTODSINTERVAL(6.5, 'day')
FROM
    sys.opt_directive$ d
/

Rem
Rem Public views
Rem

CREATE OR REPLACE VIEW dba_sql_plan_directives (
    directive_id,
    type,
    enabled,
    state,
    auto_drop,
    reason,
    created,
    last_modified,
    last_used,
    notes
) AS
SELECT
    d.dir_id,
    d.type,
    d.enabled,
    case when d.internal_state = 'HAS_STATS' or d.redundant = 'YES' 
           then 'SUPERSEDED'
         when d.internal_state in ('NEW', 'MISSING_STATS', 'PERMANENT')
           then 'USABLE' 
         else 'UNKNOWN' end case,
    d.auto_drop,
    f.reason,
    d.created,
    d.last_modified,
    d.last_used,
    xmltype(
      '<spd_note>' ||
         '<internal_state>' || d.internal_state || '</internal_state>' ||
         '<redundant>' || d.redundant || '</redundant>' ||
         '<spd_text>' || sys.dbms_spd_internal.get_spd_text(d.dir_id) ||
         '</spd_text>' ||
       '</spd_note>')  notes
FROM
    sys."_BASE_OPT_DIRECTIVE" d,
    sys."_BASE_OPT_FINDING" f
WHERE d.f_id = f.f_id
/

COMMENT ON TABLE dba_sql_plan_directives IS
    'Set of sql plan directives'
/
COMMENT ON COLUMN dba_sql_plan_directives.directive_id IS
    'The identifier of the sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_directives.type IS
    'The type of the sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_directives.enabled IS
    'Whether the sql plan directive is enabled or not'
/
COMMENT ON COLUMN dba_sql_plan_directives.state IS
    'The state of the sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_directives.auto_drop IS
    'If YES, the sql plan directive gets dropped when unused beyond SPD_RETENTION_WEEKS'
/
COMMENT ON COLUMN dba_sql_plan_directives.reason IS
    'The reason for creating the sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_directives.created IS
    'The creation timestamp of the sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_directives.last_modified IS
    'The timestamp of most recent modification of the sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_directives.last_used IS
    'The timestamp of most recent usage of the sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_directives.notes IS
    'Extra information about the sql plan directive'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_sql_plan_directives 
FOR sys.dba_sql_plan_directives
/
GRANT SELECT ON sys.dba_sql_plan_directives TO select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_SQL_PLAN_DIRECTIVES','CDB_SQL_PLAN_DIRECTIVES');
grant select on SYS.CDB_sql_plan_directives to select_catalog_role
/
create or replace public synonym CDB_sql_plan_directives for SYS.CDB_sql_plan_directives
/

CREATE OR REPLACE VIEW dba_sql_plan_dir_objects (
    directive_id,
    owner,
    object_name,
    subobject_name,
    object_type,
    num_rows,
    notes
) AS
SELECT
    d.dir_id,
    u.name,
    o.name,
    c.name,
    'COLUMN',
    NULL,
    NULL
FROM
    sys."_BASE_OPT_DIRECTIVE" d,
    sys."_BASE_OPT_FINDING_OBJ_COL" ft,
    (select obj#, owner#, name from sys.obj$
     union all
     select object_id obj#, 0 owner#, name from  v$fixed_table) o,
    (select obj#, intcol#, name from sys.col$
     union all
     select kqfcotob obj#, kqfcocno intcol#, kqfconam name 
     from sys.x$kqfco) c,
    sys.user$ u
WHERE 
    d.f_id = ft.f_id and ft.f_obj# = o.obj# and o.owner# = u.user#
    and o.obj# = c.obj# and ft.intcol# = c.intcol#
union all
SELECT
    d.dir_id,
    u.name,
    o.name,
    NULL,
    'TABLE',
    fo.nrows,
    fo.notes
FROM
    sys."_BASE_OPT_DIRECTIVE" d,
    sys."_BASE_OPT_FINDING_OBJ" fo,
    (select obj#, owner#, name from sys.obj$
     union all
     select object_id obj#, 0 owner#, name from  v$fixed_table) o,
    sys.user$ u
WHERE 
    d.f_id = fo.f_id and fo.f_obj# = o.obj# and o.owner# = u.user#
union all
-- Directives that store DS result have an object of type SQL
-- STATEMENT (which represents the DS Sql Statement). The following 
-- branch gives the sqlid of that SQL.
SELECT
    d.dir_id,
    null,
    dbms_spd_internal.ub8_to_sqlid(fo.f_obj#),
    NULL,
    'SQL STATEMENT',
    NULL,
    NULL
FROM
    sys."_BASE_OPT_DIRECTIVE" d,
    sys."_BASE_OPT_FINDING_OBJ" fo
WHERE 
    d.f_id = fo.f_id and d.type = 'DYNAMIC_SAMPLING_RESULT' and
    fo.obj_type = 4
union all
-- Directives that store DS result have an object of type 
-- SQL STATEMENT ENVIRONMENT (which is the signature of the enviornment
-- that affects the result of DS Sql Statement like bind values). 
-- The following branch gives that signature.
SELECT
    d.dir_id,
    null,
    dbms_spd_internal.ub8_to_sqlid(fo.f_obj#),
    NULL,
    'SQL STATEMENT ENVIRONMENT',
    NULL,
    NULL
FROM
    sys."_BASE_OPT_DIRECTIVE" d,
    sys."_BASE_OPT_FINDING_OBJ" fo
WHERE 
    d.f_id = fo.f_id and d.type = 'DYNAMIC_SAMPLING_RESULT' and
    fo.obj_type = 5
/

COMMENT ON TABLE dba_sql_plan_dir_objects IS
    'Set of objects in sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_dir_objects.directive_id IS
    'The identifier of the sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_dir_objects.owner IS
    'The username of the owner of the object in the sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_dir_objects.object_name IS
    'The name of the object in the sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_dir_objects.subobject_name IS
    'The name of the sub-object (for example column) in the sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_dir_objects.object_type IS
    'The type of the (sub-)object in the sql plan directive'
/
COMMENT ON COLUMN dba_sql_plan_dir_objects.num_rows IS
    'The number of rows in the object when directive is created'
/
COMMENT ON COLUMN dba_sql_plan_dir_objects.notes IS
    'Other notes about the object'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_sql_plan_dir_objects 
FOR sys.dba_sql_plan_dir_objects
/
GRANT SELECT ON sys.dba_sql_plan_dir_objects TO select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_SQL_PLAN_DIR_OBJECTS','CDB_SQL_PLAN_DIR_OBJECTS');
grant select on SYS.CDB_sql_plan_dir_objects to select_catalog_role
/
create or replace public synonym CDB_sql_plan_dir_objects for SYS.CDB_sql_plan_dir_objects
/


@?/rdbms/admin/sqlsessend.sql
