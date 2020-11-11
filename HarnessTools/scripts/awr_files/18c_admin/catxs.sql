Rem
Rem $Header: oraolap/admin/catxs.sql /main/76 2017/10/30 09:54:08 jcarey Exp $
Rem
Rem catxs.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxs.sql - eXpreSs Catalog creation
Rem
Rem    DESCRIPTION
Rem      This loads the catalog for the analytic workspaces
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: oraolap/admin/catxs.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxs.sql
Rem SQL_PHASE: CATXS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jcarey      10/20/17 - 12.2->18.1
Rem    ghicks      03/14/17 - bug 25713495 - pass 'SYS' to create_cdbview
Rem    mstasiew    04/02/15 - 20345942 proj 58196 read priv, ora_check_sys_priv
Rem    ghicks      04/21/14 - add AW version 12.2
Rem    surman      01/13/14 - 13922626: Update SQL metadata
Rem    sasounda    11/19/13 - 17746252: handle KZSRAT when creating all_* views
Rem    talliu      07/18/13 - Add cdbview
Rem    cchiappa    03/14/13 - Backport cchiappa_set_oracle_script_121010
Rem    dmiramon    02/26/13 - Adding IS_MULTI_LINGUAL column
Rem    glyon       10/16/12 - bugs 14752361 & 14768908: privs for folder views
Rem    byu         05/03/12 - Bug 13242046: add SELECT and ALTER privilege for  
Rem                           measure folder and build process
Rem    smesropi    05/10/12 - METADATA_PROPERTIES views and dictionary ID cols
Rem    byu         12/16/11 - add xxx_cube_dependencies views
Rem    smesropi    04/02/12 - added views - CUBE_SUB_PARTITION_LEVELS,
Rem                           CUBE_NAMED_BUILD_SPECS, MEASURE_FOLDER_SUBFOLDERS
Rem    surman      03/28/12 - 13615447: Add SQL patching tags
Rem    smesropi    03/26/12 - access to LOOP properties in cube_measures views
Rem    byu         10/14/11 - change spare1 in olap_descriptions$
Rem    byu         10/19/11 - bug 13109001 rename cols in XXX_CUBE_DESCRIPTIONS
Rem    byu         08/15/11 - bug 12544166 - add more views and columns for
Rem                           metadata
Rem    cchiappa    03/01/11 - Move drop trigger to prvtaw.sql
Rem    sfeinste    02/18/11 - bug 11791349 - fix performance issue with
Rem                           security checks for some ALL_CUBE* views
Rem    cchiappa    09/23/10 - V12 support
Rem    glyon       03/27/09 - bug 8391053 - fix ALL_MEASURE_FOLDERS view
Rem    cvenezia    02/18/09 - Do not allow user with CREATE ALL to see objects
Rem    jhartsin    02/03/09 - Got rid of extra join in all_cube_measures
Rem    hyechung    11/24/08 - v11.2 support
Rem    mstasiew    03/27/08 - ET_ATTR_PREFIX 5921859
Rem    ckearney    11/01/07 - update message when Olap objects present
Rem    cvenezia    08/30/07 - Add Dim requirement to privs in ALL_CUBE* views
Rem    mstasiew    08/14/07 - START_DATE
Rem    sfeinste    05/31/07 - Fix for bug 6085568
Rem    ckearney    05/22/07 - use olap_* tables instead of obj$ in drp trigger
Rem    sfeinste    05/10/07 - Fix for bug 6042471
Rem    cvenezia    05/09/07 - Correct privileges in ALL_*_VIEWS
Rem    sfeinste    04/30/07 - Dict renames and modifications (and undo hack)
Rem    ckearney    04/18/07 - add cube & cube dimension check
Rem    sfeinste    04/20/07 - Hack to prepare for dict changes
Rem    mstasiew    03/16/07 - 5837465
Rem    wechen      01/26/07 - rename olap kgl types, step 3
Rem    wechen      01/26/07 - rename olap kgl types, step 1
Rem    sfeinste    11/27/06 - Add interaction views
Rem    rsamuels    10/30/06 - Skip hidden measures in ALL/DBA/USER_MEASURES
Rem    cchiappa    09/21/06 - Trigger deletes sequence from noexp$
Rem    sfeinste    09/12/06 - modify olap_ views to do outer join
Rem    smesropi    06/14/06 - added views to olap_* data dictionary tables
Rem    jcarey      07/27/06 - revert drop trig before/after 
Rem    jcarey      07/17/06 - Add aw_version to user_aws 
Rem    cchiappa    07/12/06 - Disallow dropping table with COT 
Rem    jcarey      06/12/06 - remove truncate trigger 
Rem    jcarey      06/07/06 - v11 support 
Rem    jcarey      06/09/06 - Temp back out truncate trigger 
Rem    jcarey      05/22/06 - drop trigger before 
Rem    zqiu        06/09/05 - more checks in aw drop trigger 
Rem    zqiu        07/15/04 - more truthful ps{gen,num} count
Rem    cchiappa    06/16/04 - Drop trigger deletes from expdepact$
Rem    dbardwel    05/21/04 - Support for 10.2 aw_version
Rem    dbardwel    03/26/04 - Add missing join to ALL_AWS and ALL_AW_PS
Rem    ckearney    03/17/04 - add AW_VERSION to DBA_AWS & ALL_AWS
Rem    zqiu        10/16/03 - delete from noexp in trigger
Rem    zqiu        10/01/03 - fix redundancy in all_ views
Rem    zqiu        09/23/03 - strip DML priv to public
Rem    zqiu        12/05/02 - remove temp columns in aw_prop$
Rem    zqiu        11/21/02 - modify trigger to delete from aw_*$ table
Rem    zqiu        09/17/02 - bypass select from user_table in aw_drop_proc
Rem    zqiu        09/09/02 - add view all_aws
Rem    zqiu        07/25/02 - use dynamic sql for aw_drop_trigger
Rem    zqiu        06/18/02 - trigger to clean aw$/ps$ when user table dropped
Rem    jcarey      10/18/01 - remove lobtab from aw$
Rem    esoyleme    09/13/01 - views in spec..
Rem    esoyleme    09/10/01 - creation

@@?/rdbms/admin/sqlsessstart.sql

--create views on aw$

create or replace view DBA_AWS
(OWNER, AW_NUMBER, AW_NAME, AW_VERSION, PAGESPACES, GENERATIONS, FROZEN)
as
SELECT u.name, a.awseq#, a.awname,
       DECODE(a.version,
              0, '9.1',
              1, '10.1', 2, '10.2',
              3, '11.1', 4, '11.2',
              5, '12.0', 6, '18.1',
              NULL), 
        n.num, g.gen, f.frozen
FROM aw$ a, user$ u,
     (SELECT awseq#, COUNT(psgen) gen FROM ps$ WHERE psnumber IS NULL GROUP BY awseq#) g,
     (SELECT awseq#, COUNT(UNIQUE(psnumber)) num FROM ps$ WHERE psnumber IS NOT NULL GROUP BY awseq#) n ,
     (SELECT max(awseq#) awmax, decode(max(mapoffset), 1, 'Frozen', 
         2, 'NoThaw', NULL) frozen from ps$ where psnumber is NULL
         group by awseq#) f
WHERE   a.owner#=u.user# and a.awseq#=g.awseq# and a.awseq#=n.awseq# and
        a.awseq# = f.awmax
/

comment on table DBA_AWS is
'Analytic Workspaces in the database'
/
comment on column DBA_AWS.OWNER is
'Owner of the Analytic Workspace'
/
comment on column DBA_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column DBA_AWS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column DBA_AWS.PAGESPACES is
'Number of pagespaces in the Analytic Workspace'
/
comment on column DBA_AWS.GENERATIONS is
'Number of active generations in the Analytic Workspace'
/
comment on column DBA_AWS.FROZEN is
'Freeze state of the Analytic Workspace'
/
comment on column DBA_AWS.AW_VERSION is
'Format version of the Analytic Workspace'
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_AWS','CDB_AWS');
create or replace public synonym CDB_AWS for sys.CDB_AWS;
grant select on CDB_AWS to select_catalog_role;

create or replace view USER_AWS
(AW_NUMBER, AW_NAME, AW_VERSION, PAGESPACES, GENERATIONS, FROZEN)
as
SELECT a.awseq#, a.awname, 
       DECODE(a.version,
              0, '9.1',
              1, '10.1', 2, '10.2',
              3, '11.1', 4, '11.2',
              5, '12.0', 6, '18.1',
              NULL), 
       n.num, g.gen, f.frozen
FROM aw$ a,
     (SELECT awseq#, COUNT(psgen) gen FROM ps$ WHERE psnumber IS NULL GROUP BY awseq#) g,
     (SELECT awseq#, COUNT(UNIQUE(psnumber)) num FROM ps$ WHERE psnumber IS NOT NULL GROUP BY awseq#) n ,
     (SELECT max(awseq#) awmax, decode(max(mapoffset), 1, 'Frozen', 
         2, 'NoThaw', NULL) frozen from ps$ where psnumber is NULL
         group by awseq#) f
WHERE   a.owner#=USERENV('SCHEMAID') and a.awseq#=g.awseq# and a.awseq#=n.awseq# 
        and a.awseq# = f.awmax
/

comment on table USER_AWS is
'Analytic Workspaces owned by the user'
/
comment on column USER_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column USER_AWS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column USER_AWS.PAGESPACES is
'Number of pagespaces in the Analytic Workspace'
/
comment on column USER_AWS.GENERATIONS is
'Number of active generations in the Analytic Workspace'
/
comment on column USER_AWS.FROZEN is
'Freeze state of the Analytic Workspace'
/
comment on column USER_AWS.AW_VERSION is
'Format version of the Analytic Workspace'
/
create or replace view ALL_AWS
(OWNER, AW_NUMBER, AW_NAME, AW_VERSION, PAGESPACES, GENERATIONS, FROZEN)
as
SELECT u.name, a.awseq#, a.awname,
       decode(a.version,
              0, '9.1',
              1, '10.1', 2, '10.2',
              3, '11.1', 4, '11.2',
              5, '12.0', 6, '18.1',
              NULL), 
        n.num, g.gen, f.frozen
FROM aw$ a, sys.obj$ o, sys.user$ u,
     (SELECT awseq#, COUNT(psgen) gen FROM ps$ WHERE psnumber IS NULL GROUP BY awseq#) g,
     (SELECT awseq#, COUNT(UNIQUE(psnumber)) num FROM ps$ WHERE psnumber IS NOT NULL GROUP BY awseq#) n ,
     (SELECT max(awseq#) awmax, decode(max(mapoffset), 1, 'Frozen', 
         2, 'NoThaw', NULL) frozen from ps$ where psnumber is NULL
         group by awseq#) f
WHERE  a.owner#=u.user#
       and o.owner# = a.owner#
       and o.name = 'AW$' || a.awname and o.type#= 2 /* type for table */
       and a.awseq#=g.awseq# and a.awseq#=n.awseq# and a.awseq# = f.awmax
       and (a.owner# in (userenv('SCHEMAID'), 1)   /* public objects */
            or
            o.obj# in ( select obj#  /* directly granted privileges */
                        from sys.objauth$
                        where grantee# in ( select kzsrorol from x$kzsro )
                      )
            or   /* user has system privileges */
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_AWS is
'Analytic Workspaces accessible to the user'
/
comment on column ALL_AWS.OWNER is
'Owner of the Analytic Workspace'
/
comment on column ALL_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column ALL_AWS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column ALL_AWS.PAGESPACES is
'Number of pagespaces in the Analytic Workspace'
/
comment on column ALL_AWS.GENERATIONS is
'Number of active generations in the Analytic Workspace'
/
comment on column ALL_AWS.FROZEN is
'Freeze state of the Analytic Workspace'
/
comment on column ALL_AWS.AW_VERSION is
'Format version of the Analytic Workspace'
/
--create views on ps$

create or replace view DBA_AW_PS
(OWNER, AW_NUMBER, AW_NAME, PSNUMBER, GENERATIONS, MAXPAGES)
as
SELECT u.name, a.awseq#, a.awname, p.psnumber, count(unique(p.psgen)), max(p.maxpages)
FROM aw$ a, ps$ p, user$ u
WHERE   a.owner#=u.user# and a.awseq#=p.awseq#
group by a.awseq#, a.awname, u.name, p.psnumber
/

comment on table DBA_AW_PS is
'Pagespaces in Analytic Workspaces owned by the user'
/
comment on column DBA_AW_PS.OWNER is
'Owner of the Analytic Workspace'
/
comment on column DBA_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column DBA_AW_PS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column DBA_AW_PS.PSNUMBER is
'Number of the pagespace'
/
comment on column DBA_AW_PS.GENERATIONS is
'Number of active generations in the pagespace'
/
comment on column DBA_AW_PS.MAXPAGES is
'Maximum pages allocated in the pagespace'
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_AW_PS','CDB_AW_PS');
create or replace public synonym CDB_AW_PS for sys.CDB_AW_PS;
grant select on CDB_AW_PS to select_catalog_role;

create or replace view USER_AW_PS
(AW_NUMBER, AW_NAME, PSNUMBER, GENERATIONS, MAXPAGES)
as
SELECT a.awseq#, a.awname, p.psnumber, count(unique(p.psgen)), max(p.maxpages)
FROM aw$ a, ps$ p
WHERE   a.owner#=USERENV('SCHEMAID') and a.awseq#=p.awseq#
group by a.awseq#, a.awname, p.psnumber
/

comment on table USER_AW_PS is
'Pagespaces in Analytic Workspaces owned by the user'
/
comment on column USER_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column USER_AW_PS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column USER_AW_PS.PSNUMBER is
'Number of the pagespace'
/
comment on column USER_AW_PS.GENERATIONS is
'Number of active generations in the pagespace'
/
comment on column USER_AW_PS.MAXPAGES is
'Maximum pages allocated in the pagespace'
/

create or replace view ALL_AW_PS
(OWNER, AW_NUMBER, AW_NAME, PSNUMBER, GENERATIONS, MAXPAGES)
as
SELECT u.name, a.awseq#, a.awname, p.psnumber, count(unique(p.psgen)), max(p.maxpages)
FROM aw$ a, ps$ p, user$ u, sys.obj$ o
WHERE  a.owner#=u.user#
       and o.owner# = a.owner#
       and o.name = 'AW$' || a.awname and o.type#= 2 /* type for table */
       and a.awseq#=p.awseq#
       and (a.owner# in (userenv('SCHEMAID'), 1)   /* public objects */
            or
            o.obj# in ( select obj#  /* directly granted privileges */
                        from sys.objauth$
                        where grantee# in ( select kzsrorol from x$kzsro )
                      )
            or   /* user has system privileges */
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
group by a.awseq#, a.awname, u.name, p.psnumber
/

comment on table ALL_AW_PS is
'Pagespaces in Analytic Workspaces accessible to the user'
/
comment on column ALL_AW_PS.OWNER is
'Owner of the Analytic Workspace'
/
comment on column ALL_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column ALL_AW_PS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column ALL_AW_PS.PSNUMBER is
'Number of the pagespace'
/
comment on column ALL_AW_PS.GENERATIONS is
'Number of active generations in the pagespace'
/
comment on column ALL_AW_PS.MAXPAGES is
'Maximum pages allocated in the pagespace'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_AWS FOR SYS.DBA_AWS
/
GRANT SELECT ON DBA_AWS to select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM DBA_AW_PS FOR SYS.DBA_AW_PS
/
GRANT SELECT ON DBA_AW_PS to select_catalog_role
/

CREATE OR REPLACE PUBLIC SYNONYM USER_AWS FOR SYS.USER_AWS
/
GRANT READ ON USER_AWS to public
/
CREATE OR REPLACE PUBLIC SYNONYM USER_AW_PS FOR SYS.USER_AW_PS
/
GRANT READ ON USER_AW_PS to public
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_AWS FOR SYS.ALL_AWS
/
GRANT READ ON ALL_AWS to public
/
CREATE OR REPLACE PUBLIC SYNONYM ALL_AW_PS FOR SYS.ALL_AW_PS
/
GRANT READ ON ALL_AW_PS to public
/

-- OLAP_CUBES DATA DICTIONARY TABLES --

create or replace view DBA_CUBES
AS
SELECT 
  u.name OWNER, 
  o.name CUBE_NAME,
  c.obj# CUBE_ID,
  a.awname AW_NAME,
  syn.syntax_clob CONSISTENT_SOLVE_SPEC,
  d.description_value DESCRIPTION,
  io.option_value SPARSE_TYPE,
  syn2.syntax_clob PRECOMPUTE_CONDITION,
  io2.option_num_value PRECOMPUTE_PERCENT,
  io3.option_num_value PRECOMPUTE_PERCENT_TOP,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  io5.option_value REFRESH_MVIEW_NAME,
  io6.option_value REWRITE_MVIEW_NAME,
  syn3.syntax_clob DEFAULT_BUILD_SPEC,
  io7.option_value MEASURE_STORAGE,
  syn4.syntax_clob SQL_CUBE_STORAGE_TYPE,
  io8.option_value CUBE_STORAGE_TYPE
FROM  
  olap_cubes$ c, 
  user$ u, 
  aw$ a, 
  obj$ o, 
  olap_syntax$ syn,
  olap_syntax$ syn2,
  olap_syntax$ syn3,
  olap_syntax$ syn4,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 1 --CUBE
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_impl_options$ io4,
  olap_impl_options$ io5,
  olap_impl_options$ io6,
  olap_impl_options$ io7,
  olap_impl_options$ io8,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od  
WHERE
  o.obj#=c.obj#
  AND o.owner#=u.user#
  AND c.awseq#=a.awseq#(+)
  AND c.obj#=d.owning_object_id(+)
  AND syn.owner_id(+)=c.obj#
  AND syn.owner_type(+)=1
  AND syn.ref_role(+)=16 -- consistent solve spec 
  AND syn2.owner_id(+)=c.obj#
  AND syn2.owner_type(+)=1
  AND syn2.ref_role(+)=20 -- precompute condition 
  AND syn3.owner_id(+)=c.obj#
  AND syn3.owner_type(+)=1
  AND syn3.ref_role(+)=17 -- default build spec 
  AND syn4.owner_id(+)=c.obj#
  AND syn4.owner_type(+)=1
  AND syn4.ref_role(+)=24 -- sql cube storage type
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1
  AND io.option_type(+)=7 -- sparse type 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1
  AND io2.option_type(+)=24 -- precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1
  AND io3.option_type(+)=25 -- precompute percent top 
  AND io4.owning_objectid(+)=c.obj#
  AND io4.object_type(+)=1
  AND io4.option_type(+)=9 -- partition level 
  AND io4.option_num_value=hl.hierarchy_level_id(+)
  AND io5.owning_objectid(+)=c.obj#
  AND io5.object_type(+)=1
  AND io5.option_type(+)=30 -- refresh MV name
  AND io6.owning_objectid(+)=c.obj#
  AND io6.object_type(+)=1
  AND io6.option_type(+)=31 -- rewrite MV name
  AND io7.owning_objectid(+)=c.obj#
  AND io7.object_type(+)=1
  AND io7.option_type(+)=17 -- measure storage
  AND io8.owning_objectid(+)=c.obj#
  AND io8.object_type(+)=1
  AND io8.option_type(+)=20 -- cube storage type
  AND hl.hierarchy_id=h.hierarchy_id(+)
  AND hl.dim_level_id=dl.level_id(+)
  AND h.dim_obj#=od.obj#(+)
/

comment on table DBA_CUBES is
'OLAP Cubes in the database'
/
comment on column DBA_CUBES.OWNER is
'Owner of the OLAP Cube'
/
comment on column DBA_CUBES.CUBE_NAME is
'Name of the OLAP Cube'
/
comment on column DBA_CUBES.CUBE_ID is
'Dictionary Id of the OLAP Cube'
/
comment on column DBA_CUBES.AW_NAME is
'Name of the Analytic Workspace which owns the OLAP Cube'
/
comment on column DBA_CUBES.CONSISTENT_SOLVE_SPEC is
'The Consistent Solve Specification for the OLAP Cube'
/
comment on column DBA_CUBES.DESCRIPTION is
'Long Description of the OLAP Cube'
/
comment on column DBA_CUBES.SPARSE_TYPE is
'Text value indicating type of sparsity for the OLAP Cube'
/
comment on column DBA_CUBES.PRECOMPUTE_CONDITION is
'Condition syntax representing precompute condition of the OLAP Cube'
/
comment on column DBA_CUBES.PRECOMPUTE_PERCENT is
'Precompute percent of the OLAP Cube'
/
comment on column DBA_CUBES.PRECOMPUTE_PERCENT_TOP is
'Top precompute percent of the OLAP Cube'
/
comment on column DBA_CUBES.PARTITION_DIMENSION_NAME is
'Name of the Cube Dimension for which there is a partition on the OLAP Cube'
/
comment on column DBA_CUBES.PARTITION_HIERARCHY_NAME is
'Name of the Hierarchy for which there is a partition on the OLAP Cube'
/
comment on column DBA_CUBES.PARTITION_LEVEL_NAME is
'Name of the HierarchyLevel for which there is a partition on the OLAP Cube'
/
comment on column DBA_CUBES.REFRESH_MVIEW_NAME is
'Name of the refresh materialized view for the OLAP Cube'
/
comment on column DBA_CUBES.REWRITE_MVIEW_NAME is
'Name of the rewrite materialized view for the OLAP Cube'
/
comment on column DBA_CUBES.DEFAULT_BUILD_SPEC is
'The Default Build Specification for the OLAP Cube'
/
comment on column DBA_CUBES.MEASURE_STORAGE is
'The Measure Storage for the OLAP Cube'
/
comment on column DBA_CUBES.SQL_CUBE_STORAGE_TYPE is
'The SQL Cube Storage Type for the OLAP Cube'
/
comment on column DBA_CUBES.CUBE_STORAGE_TYPE is
'The Cube Storage Type for the OLAP Cube'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBES FOR SYS.DBA_CUBES
/
GRANT SELECT ON DBA_CUBES to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBES','CDB_CUBES');
create or replace public synonym CDB_CUBES for sys.CDB_CUBES;
grant select on CDB_CUBES to select_catalog_role;

create or replace view ALL_CUBES
as
SELECT 
  u.name OWNER, 
  o.name CUBE_NAME,
  c.obj# CUBE_ID,
  a.awname AW_NAME,
  syn.syntax_clob CONSISTENT_SOLVE_SPEC,
  d.description_value DESCRIPTION,
  io.option_value SPARSE_TYPE,
  syn2.syntax_clob PRECOMPUTE_CONDITION,
  io2.option_num_value PRECOMPUTE_PERCENT,
  io3.option_num_value PRECOMPUTE_PERCENT_TOP,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  io5.option_value REFRESH_MVIEW_NAME,
  io6.option_value REWRITE_MVIEW_NAME,
  syn3.syntax_clob DEFAULT_BUILD_SPEC,
  io7.option_value MEASURE_STORAGE,
  syn4.syntax_clob SQL_CUBE_STORAGE_TYPE,
  io8.option_value CUBE_STORAGE_TYPE
FROM  
  olap_cubes$ c, 
  user$ u,
  aw$ a, 
  obj$ o, 
  olap_syntax$ syn,
  olap_syntax$ syn2,
  olap_syntax$ syn3,
  olap_syntax$ syn4,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 1 --CUBE
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_impl_options$ io4,
  olap_impl_options$ io5,
  olap_impl_options$ io6,
  olap_impl_options$ io7,
  olap_impl_options$ io8,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od,
  (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE
  o.obj#=c.obj#
  AND c.obj#=da.obj#(+)
  AND o.owner#=u.user#(+)
  AND c.awseq#=a.awseq#(+)
  AND c.obj#=d.owning_object_id(+)
  AND syn.owner_id(+)=c.obj#
  AND syn.owner_type(+)=1
  AND syn.ref_role(+)=16 -- consistent solve spec 
  AND syn2.owner_id(+)=c.obj#
  AND syn2.owner_type(+)=1
  AND syn2.ref_role(+)=20 -- precompute condition 
  AND syn3.owner_id(+)=c.obj#
  AND syn3.owner_type(+)=1
  AND syn3.ref_role(+)=17 -- default build spec 
  AND syn4.owner_id(+)=c.obj#
  AND syn4.owner_type(+)=1
  AND syn4.ref_role(+)=24 -- sql cube storage type
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1
  AND io.option_type(+)=7 -- sparse type 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1
  AND io2.option_type(+)=24 -- precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1
  AND io3.option_type(+)=25 -- precompute percent top 
  AND io4.owning_objectid(+)=c.obj#
  AND io4.object_type(+)=1
  AND io4.option_type(+)=9 -- partition level 
  AND io4.option_num_value=hl.hierarchy_level_id(+)
  AND io5.owning_objectid(+)=c.obj#
  AND io5.object_type(+)=1
  AND io5.option_type(+)=30 -- refresh MV name
  AND io6.owning_objectid(+)=c.obj#
  AND io6.object_type(+)=1
  AND io6.option_type(+)=31 -- rewrite MV name
  AND io7.owning_objectid(+)=c.obj#
  AND io7.object_type(+)=1
  AND io7.option_type(+)=17 -- measure storage
  AND io8.owning_objectid(+)=c.obj#
  AND io8.object_type(+)=1
  AND io8.option_type(+)=20 -- cube storage type
  AND hl.hierarchy_id=h.hierarchy_id(+)
  AND hl.dim_level_id=dl.level_id(+)
  AND h.dim_obj#=od.obj#(+)
  and (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
/

comment on table ALL_CUBES is
'OLAP Cubes in the database accessible to the user'
/
comment on column ALL_CUBES.OWNER is
'Owner of the OLAP Cube'
/
comment on column ALL_CUBES.CUBE_NAME is
'Name of the OLAP Cube'
/
comment on column ALL_CUBES.CUBE_ID is
'Dictionary Id of the OLAP Cube'
/
comment on column ALL_CUBES.AW_NAME is
'Name of the Analytic Workspace which owns the OLAP Cube'
/
comment on column ALL_CUBES.CONSISTENT_SOLVE_SPEC is
'The Consistent Solve Specification for the OLAP Cube'
/
comment on column ALL_CUBES.DESCRIPTION is
'Long Description of the OLAP Cube'
/
comment on column ALL_CUBES.SPARSE_TYPE is
'Text value indicating type of sparsity for the OLAP Cube'
/
comment on column ALL_CUBES.PRECOMPUTE_CONDITION is
'Condition syntax representing precompute condition of the OLAP Cube'
/
comment on column ALL_CUBES.PRECOMPUTE_PERCENT is
'Precompute percent of the OLAP Cube'
/
comment on column ALL_CUBES.PRECOMPUTE_PERCENT_TOP is
'Top precompute percent of the OLAP Cube'
/
comment on column ALL_CUBES.PARTITION_DIMENSION_NAME is
'Name of the Cube Dimension for which there is a partition on the OLAP Cube'
/
comment on column ALL_CUBES.PARTITION_HIERARCHY_NAME is
'Name of the Hierarchy for which there is a partition on the OLAP Cube'
/
comment on column ALL_CUBES.PARTITION_LEVEL_NAME is
'Name of the HierarchyLevel for which there is a partition on the OLAP Cube'
/
comment on column ALL_CUBES.REFRESH_MVIEW_NAME is
'Name of the refresh materialized view for the OLAP Cube'
/
comment on column ALL_CUBES.REWRITE_MVIEW_NAME is
'Name of the rewrite materialized view for the OLAP Cube'
/
comment on column ALL_CUBES.DEFAULT_BUILD_SPEC is
'The Default Build Specification for the OLAP Cube'
/
comment on column ALL_CUBES.MEASURE_STORAGE is
'The Measure Storage for the OLAP Cube'
/
comment on column ALL_CUBES.SQL_CUBE_STORAGE_TYPE is
'The SQL Cube Storage Type for the OLAP Cube'
/
comment on column ALL_CUBES.CUBE_STORAGE_TYPE is
'The Cube Storage Type for the OLAP Cube'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBES FOR SYS.ALL_CUBES
/
GRANT READ ON ALL_CUBES to public
/

create or replace view USER_CUBES
as
SELECT 
  o.name CUBE_NAME,
  c.obj# CUBE_ID,
  a.awname AW_NAME, 
  syn.syntax_clob CONSISTENT_SOLVE_SPEC,
  d.description_value DESCRIPTION,
  io.option_value SPARSE_TYPE,
  syn2.syntax_clob PRECOMPUTE_CONDITION,
  io2.option_num_value PRECOMPUTE_PERCENT,
  io3.option_num_value PRECOMPUTE_PERCENT_TOP,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  io5.option_value REFRESH_MVIEW_NAME,
  io6.option_value REWRITE_MVIEW_NAME,
  syn3.syntax_clob DEFAULT_BUILD_SPEC,
  io7.option_value MEASURE_STORAGE,
  syn4.syntax_clob SQL_CUBE_STORAGE_TYPE,
  io8.option_value CUBE_STORAGE_TYPE
FROM
  olap_cubes$ c,
  aw$ a,
  obj$ o,
  olap_syntax$ syn,
  olap_syntax$ syn2,
  olap_syntax$ syn3,
  olap_syntax$ syn4,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 1 --CUBE
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_impl_options$ io4,
  olap_impl_options$ io5,
  olap_impl_options$ io6,
  olap_impl_options$ io7,
  olap_impl_options$ io8,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od  
WHERE 
  o.obj#=c.obj#
  AND o.owner#=USERENV('SCHEMAID') 
  AND c.awseq#=a.awseq#(+)
  AND c.obj#=d.owning_object_id(+)
  AND syn.owner_id(+)=c.obj#
  AND syn.owner_type(+)=1
  AND syn.ref_role(+)=16 -- consistent solve spec 
  AND syn2.owner_id(+)=c.obj#
  AND syn2.owner_type(+)=1
  AND syn2.ref_role(+)=20 -- precompute condition 
  AND syn3.owner_id(+)=c.obj#
  AND syn3.owner_type(+)=1
  AND syn3.ref_role(+)=17 -- default build spec 
  AND syn4.owner_id(+)=c.obj#
  AND syn4.owner_type(+)=1
  AND syn4.ref_role(+)=24 -- sql cube storage type
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1
  AND io.option_type(+)=7 -- sparse type 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1
  AND io2.option_type(+)=24 -- precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1
  AND io3.option_type(+)=25 -- precompute percent top 
  AND io4.owning_objectid(+)=c.obj#
  AND io4.object_type(+)=1
  AND io4.option_type(+)=9 -- partition level 
  AND io4.option_num_value=hl.hierarchy_level_id(+)
  AND io5.owning_objectid(+)=c.obj#
  AND io5.object_type(+)=1
  AND io5.option_type(+)=30 -- refresh MV name
  AND io6.owning_objectid(+)=c.obj#
  AND io6.object_type(+)=1
  AND io6.option_type(+)=31 -- rewrite MV name
  AND io7.owning_objectid(+)=c.obj#
  AND io7.object_type(+)=1
  AND io7.option_type(+)=17 -- measure storage
  AND io8.owning_objectid(+)=c.obj#
  AND io8.object_type(+)=1
  AND io8.option_type(+)=20 -- cube storage type
  AND hl.hierarchy_id=h.hierarchy_id(+)
  AND hl.dim_level_id=dl.level_id(+)
  AND h.dim_obj#=od.obj#(+)
/

comment on table USER_CUBES is
'OLAP Cubes owned by the user in the database'
/
comment on column USER_CUBES.CUBE_NAME is
'Name of the OLAP Cube'
/
comment on column USER_CUBES.CUBE_ID is
'Dictionary Id of the OLAP Cube'
/
comment on column USER_CUBES.AW_NAME is
'Name of the Analytic Workspace which owns the OLAP Cube'
/
comment on column USER_CUBES.CONSISTENT_SOLVE_SPEC is
'The Consistent Solve Specification for the OLAP Cube'
/
comment on column USER_CUBES.DESCRIPTION is
'Long Description of the OLAP Cube'
/
comment on column USER_CUBES.SPARSE_TYPE is
'Text value indicating type of sparsity for the OLAP Cube'
/
comment on column USER_CUBES.PRECOMPUTE_CONDITION is
'Condition syntax representing precompute condition of the OLAP Cube'
/
comment on column USER_CUBES.PRECOMPUTE_PERCENT is
'Precompute percent of the OLAP Cube'
/
comment on column USER_CUBES.PRECOMPUTE_PERCENT_TOP is
'Top precompute percent of the OLAP Cube'
/
comment on column USER_CUBES.PARTITION_DIMENSION_NAME is
'Name of the Cube Dimension for which there is a partition on the OLAP Cube'
/
comment on column USER_CUBES.PARTITION_HIERARCHY_NAME is
'Name of the Hierarchy for which there is a partition on the OLAP Cube'
/
comment on column USER_CUBES.PARTITION_LEVEL_NAME is
'Name of the HierarchyLevel for which there is a partition on the OLAP Cube'
/
comment on column USER_CUBES.REFRESH_MVIEW_NAME is
'Name of the refresh materialized view for the OLAP Cube'
/
comment on column USER_CUBES.REWRITE_MVIEW_NAME is
'Name of the rewrite materialized view for the OLAP Cube'
/
comment on column USER_CUBES.DEFAULT_BUILD_SPEC is
'The Default Build Specification for the OLAP Cube'
/
comment on column USER_CUBES.MEASURE_STORAGE is
'The Measure Storage for the OLAP Cube'
/
comment on column USER_CUBES.SQL_CUBE_STORAGE_TYPE is
'The SQL Cube Storage Type for the OLAP Cube'
/
comment on column USER_CUBES.CUBE_STORAGE_TYPE is
'The Cube Storage Type for the OLAP Cube'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBES FOR SYS.USER_CUBES
/
GRANT READ ON USER_CUBES to public
/

create or replace view USER_CUBE_SUB_PARTITION_LEVELS
as
SELECT 
  o.name CUBE_NAME,
  io.option_value SUB_PARTITION_LEVEL_NAME,
  io2.option_num_value PRECOMPUTE_PERCENT,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  1 SUB_PARTITION_LEVEL_ORDER  
FROM  
  olap_cubes$ c, 
  obj$ o, 
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od  
WHERE 
  o.obj#=c.obj#
  AND o.owner#=USERENV('SCHEMAID')
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1 -- CUBE
  AND io.option_type(+) = 38 -- sub partition1 name 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1 -- CUBE
  AND io2.option_type(+) = 39 -- sub partition1 precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1 --CUBE
  AND io3.option_type(+) = 37 -- sub partition level1
  AND io3.option_num_value=hl.hierarchy_level_id(+)  
  AND hl.hierarchy_id=h.hierarchy_id
  AND hl.dim_level_id=dl.level_id
  AND h.dim_obj#=od.obj#
UNION ALL
SELECT 
  o.name CUBE_NAME,
  io.option_value SUB_PARTITION_LEVEL_NAME,
  io2.option_num_value PRECOMPUTE_PERCENT,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  2 SUB_PARTITION_LEVEL_ORDER
FROM  
  olap_cubes$ c,
  obj$ o,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od  
WHERE 
  o.obj#=c.obj#
  AND o.owner#=USERENV('SCHEMAID')
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1 -- CUBE
  AND io.option_type(+) = 41 -- sub partition2 name 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1 -- CUBE
  AND io2.option_type(+) = 42 -- sub partition2 precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1 --CUBE
  AND io3.option_type(+) = 40 -- sub partition level2
  AND io3.option_num_value=hl.hierarchy_level_id(+)  
  AND hl.hierarchy_id=h.hierarchy_id
  AND hl.dim_level_id=dl.level_id
  AND h.dim_obj#=od.obj#
UNION ALL
SELECT 
  o.name CUBE_NAME,
  io.option_value SUB_PARTITION_LEVEL_NAME,
  io2.option_num_value PRECOMPUTE_PERCENT,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  3 SUB_PARTITION_LEVEL_ORDER
FROM  
  olap_cubes$ c,  
  obj$ o,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od  
WHERE 
  o.obj#=c.obj#
  AND o.owner#=USERENV('SCHEMAID')
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1 -- CUBE
  AND io.option_type(+) = 44 -- sub partition3 name 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1 -- CUBE
  AND io2.option_type(+) = 45 -- sub partition3 precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1 --CUBE
  AND io3.option_type(+) = 43 -- sub partition level3
  AND io3.option_num_value=hl.hierarchy_level_id(+)  
  AND hl.hierarchy_id=h.hierarchy_id
  AND hl.dim_level_id=dl.level_id
  AND h.dim_obj#=od.obj#
UNION ALL
SELECT 
  o.name CUBE_NAME,
  mo.option_value SUB_PARTITION_LEVEL_NAME,
  mo2.option_num_value PRECOMPUTE_PERCENT,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  mo.OPTION_ORDER + 1 SUB_PARTITION_LEVEL_ORDER
FROM  
  olap_cubes$ c, 
  obj$ o,
  olap_multi_options$ mo,
  olap_multi_options$ mo2,
  olap_multi_options$ mo3,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od  
WHERE 
  o.obj#=c.obj#
  AND o.owner#=USERENV('SCHEMAID')
  AND mo.owning_objectid(+)=c.obj#
  AND mo.object_type(+)=1 -- CUBE
  AND mo.option_type(+) = 5 -- sub partition name 
  AND mo2.owning_objectid(+)=c.obj#
  AND mo2.object_type(+)=1 -- CUBE
  AND mo2.option_type(+) = 6 -- sub partition precompute percent 
  AND mo3.owning_objectid(+)=c.obj#
  AND mo3.object_type(+)=1 --CUBE
  AND mo3.option_type(+) = 4 -- sub partition level
  AND mo.OPTION_ORDER = mo2.OPTION_ORDER 
  AND mo2.OPTION_ORDER = mo3.OPTION_ORDER
  AND mo3.option_num_value=hl.hierarchy_level_id(+)
  AND hl.hierarchy_id=h.hierarchy_id
  AND hl.dim_level_id=dl.level_id
  AND h.dim_obj#=od.obj#
/

comment on column USER_CUBE_SUB_PARTITION_LEVELS.CUBE_NAME is
'Name of the OLAP Cube'
/
comment on column USER_CUBE_SUB_PARTITION_LEVELS.SUB_PARTITION_LEVEL_NAME is
'Name of the secondary partition level of the OLAP Cube'
/
comment on column USER_CUBE_SUB_PARTITION_LEVELS.PRECOMPUTE_PERCENT is
'Precompute percent of the secondary partition level of the OLAP Cube'
/
comment on column USER_CUBE_SUB_PARTITION_LEVELS.PARTITION_HIERARCHY_NAME is
'Name of the Hierarchy for which there is a secondary partition level on the OLAP Cube'
/
comment on column USER_CUBE_SUB_PARTITION_LEVELS.PARTITION_LEVEL_NAME is
'Name of the HierarchyLevel for which there is a secondary partition level on the OLAP Cube'
/
comment on column USER_CUBE_SUB_PARTITION_LEVELS.PARTITION_DIMENSION_NAME is
'Name of the Cube Dimension for which there is a secondary partition level on the OLAP Cube'
/
comment on column USER_CUBE_SUB_PARTITION_LEVELS.SUB_PARTITION_LEVEL_ORDER is
'Order number of the secondary partition level on the OLAP cube'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_SUB_PARTITION_LEVELS FOR SYS.USER_CUBE_SUB_PARTITION_LEVELS
/
GRANT READ ON USER_CUBE_SUB_PARTITION_LEVELS to public
/

create or replace view DBA_CUBE_SUB_PARTITION_LEVELS
as
SELECT
  u.name OWNER,
  o.name CUBE_NAME,
  io.option_value SUB_PARTITION_LEVEL_NAME,
  io2.option_num_value PRECOMPUTE_PERCENT,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  1 SUB_PARTITION_LEVEL_ORDER
FROM  
  olap_cubes$ c,
  obj$ o,
  user$ u,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od  
WHERE 
  o.obj#=c.obj#
  AND o.owner# = u.user# 
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1 -- CUBE
  AND io.option_type(+) = 38 -- sub partition1 name 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1 -- CUBE
  AND io2.option_type(+) = 39 -- sub partition1 precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1 --CUBE
  AND io3.option_type(+) = 37 -- sub partition level1
  AND io3.option_num_value=hl.hierarchy_level_id(+)  
  AND hl.hierarchy_id=h.hierarchy_id
  AND hl.dim_level_id=dl.level_id
  AND h.dim_obj#=od.obj#
UNION ALL
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  io.option_value SUB_PARTITION_LEVEL_NAME,
  io2.option_num_value PRECOMPUTE_PERCENT,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  2 SUB_PARTITION_LEVEL_ORDER
FROM  
  olap_cubes$ c,
  obj$ o,
  user$ u,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od  
WHERE 
  o.obj#=c.obj#
  AND o.owner# = u.user# 
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1 -- CUBE
  AND io.option_type(+) = 41 -- sub partition2 name 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1 -- CUBE
  AND io2.option_type(+) = 42 -- sub partition2 precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1 --CUBE
  AND io3.option_type(+) = 40 -- sub partition level2
  AND io3.option_num_value=hl.hierarchy_level_id(+)  
  AND hl.hierarchy_id=h.hierarchy_id
  AND hl.dim_level_id=dl.level_id
  AND h.dim_obj#=od.obj#
UNION ALL
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  io.option_value SUB_PARTITION_LEVEL_NAME,
  io2.option_num_value PRECOMPUTE_PERCENT,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  3 SUB_PARTITION_LEVEL_ORDER
FROM  
  olap_cubes$ c,
  obj$ o,
  user$ u,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od  
WHERE 
  o.obj#=c.obj#
  AND o.owner# = u.user#
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1 -- CUBE
  AND io.option_type(+) = 44 -- sub partition3 name 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1 -- CUBE
  AND io2.option_type(+) = 45 -- sub partition3 precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1 --CUBE
  AND io3.option_type(+) = 43 -- sub partition level3
  AND io3.option_num_value=hl.hierarchy_level_id(+)  
  AND hl.hierarchy_id=h.hierarchy_id
  AND hl.dim_level_id=dl.level_id
  AND h.dim_obj#=od.obj#
UNION ALL
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  mo.option_value SUB_PARTITION_LEVEL_NAME,
  mo2.option_num_value PRECOMPUTE_PERCENT,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  mo.OPTION_ORDER + 1 SUB_PARTITION_LEVEL_ORDER
FROM  
  olap_cubes$ c,
  obj$ o,
  user$ u,
  olap_multi_options$ mo,
  olap_multi_options$ mo2,
  olap_multi_options$ mo3,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od  
WHERE 
  o.obj#=c.obj#
  AND o.owner# = u.user# 
  AND mo.owning_objectid(+)=c.obj#
  AND mo.object_type(+)=1 -- CUBE
  AND mo.option_type(+) = 5 -- sub partition name 
  AND mo2.owning_objectid(+)=c.obj#
  AND mo2.object_type=1 -- CUBE
  AND mo2.option_type = 6 -- sub partition precompute percent 
  AND mo3.owning_objectid=c.obj#
  AND mo3.object_type(+)=1 --CUBE
  AND mo3.option_type(+) = 4 -- sub partition level
  AND mo.OPTION_ORDER = mo2.OPTION_ORDER 
  AND mo2.OPTION_ORDER = mo3.OPTION_ORDER
  AND mo3.option_num_value=hl.hierarchy_level_id(+)
  AND hl.hierarchy_id=h.hierarchy_id
  AND hl.dim_level_id=dl.level_id
  AND h.dim_obj#=od.obj#
/

comment on table DBA_CUBE_SUB_PARTITION_LEVELS is
'OLAP Secondary Partition Levels in the database'
/
comment on column DBA_CUBE_SUB_PARTITION_LEVELS.OWNER is
'Owner of the OLAP secondary partition levels'
/
comment on column DBA_CUBE_SUB_PARTITION_LEVELS.CUBE_NAME is
'Name of the OLAP Cube'
/
comment on column DBA_CUBE_SUB_PARTITION_LEVELS.SUB_PARTITION_LEVEL_NAME is
'Name of the secondary partition level of the OLAP Cube'
/
comment on column DBA_CUBE_SUB_PARTITION_LEVELS.PRECOMPUTE_PERCENT is
'Precompute percent of the secondary partition level of the OLAP Cube'
/
comment on column DBA_CUBE_SUB_PARTITION_LEVELS.PARTITION_HIERARCHY_NAME is
'Name of the Hierarchy for which there is a secondary partition level on the OLAP Cube'
/
comment on column DBA_CUBE_SUB_PARTITION_LEVELS.PARTITION_LEVEL_NAME is
'Name of the HierarchyLevel for which there is a secondary partition level on the OLAP Cube'
/
comment on column DBA_CUBE_SUB_PARTITION_LEVELS.PARTITION_DIMENSION_NAME is
'Name of the Cube Dimension for which there is a secondary partition level on the OLAP Cube'
/
comment on column DBA_CUBE_SUB_PARTITION_LEVELS.SUB_PARTITION_LEVEL_ORDER is
'Order number of the secondary partition level on the OLAP cube'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_SUB_PARTITION_LEVELS FOR SYS.DBA_CUBE_SUB_PARTITION_LEVELS
/
GRANT SELECT ON DBA_CUBE_SUB_PARTITION_LEVELS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_SUB_PARTITION_LEVELS','CDB_CUBE_SUB_PARTITION_LEVELS');
create or replace public synonym CDB_CUBE_SUB_PARTITION_LEVELS for sys.CDB_CUBE_SUB_PARTITION_LEVELS;
grant select on CDB_CUBE_SUB_PARTITION_LEVELS to select_catalog_role;

create or replace view ALL_CUBE_SUB_PARTITION_LEVELS
as
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  io.option_value SUB_PARTITION_LEVEL_NAME,
  io2.option_num_value PRECOMPUTE_PERCENT,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  1 SUB_PARTITION_LEVEL_ORDER
FROM  
  olap_cubes$ c,  
  obj$ o, 
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od,
  user$ u,
  (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
   FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      olap_dimensionality$ diml,
      olap_cube_dimensions$ dim,
      obj$ do
    WHERE
      do.obj# = dim.obj#
      AND diml.dimensioned_object_type = 1 --CUBE
      AND diml.dimensioned_object_id = c.obj#
      AND diml.dimension_type = 11 --DIMENSION
      AND diml.dimension_id = do.obj#
    )
    GROUP BY obj# ) da 
WHERE 
  o.obj#=c.obj#
  AND c.obj#=da.obj#(+)
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1 -- CUBE
  AND io.option_type(+) = 38 -- sub partition1 name 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1 -- CUBE
  AND io2.option_type(+) = 39 -- sub partition1 precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1 --CUBE
  AND io3.option_type(+) = 37 -- sub partition level1
  AND io3.option_num_value=hl.hierarchy_level_id(+)  
  AND hl.hierarchy_id=h.hierarchy_id
  AND hl.dim_level_id=dl.level_id
  AND h.dim_obj#=od.obj#
UNION ALL
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  io.option_value SUB_PARTITION_LEVEL_NAME,
  io2.option_num_value PRECOMPUTE_PERCENT,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  2 SUB_PARTITION_LEVEL_ORDER
FROM  
  olap_cubes$ c, 
  obj$ o,  
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od,
  user$ u,
  (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      olap_dimensionality$ diml,
      olap_cube_dimensions$ dim,
      obj$ do
    WHERE
      do.obj# = dim.obj#
      AND diml.dimensioned_object_type = 1 --CUBE
      AND diml.dimensioned_object_id = c.obj#
      AND diml.dimension_type = 11 --DIMENSION
      AND diml.dimension_id = do.obj#
    )
    GROUP BY obj# ) da 
WHERE 
  o.obj#=c.obj#
  AND c.obj#=da.obj#(+)
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1 -- CUBE
  AND io.option_type(+) = 41 -- sub partition2 name 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1 -- CUBE
  AND io2.option_type(+) = 42 -- sub partition2 precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1 --CUBE
  AND io3.option_type(+) = 40 -- sub partition level2
  AND io3.option_num_value=hl.hierarchy_level_id(+)  
  AND hl.hierarchy_id=h.hierarchy_id
  AND hl.dim_level_id=dl.level_id
  AND h.dim_obj#=od.obj#
UNION ALL
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  io.option_value SUB_PARTITION_LEVEL_NAME,
  io2.option_num_value PRECOMPUTE_PERCENT,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  3 SUB_PARTITION_LEVEL_ORDER
FROM  
  olap_cubes$ c,
  obj$ o,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od,
  user$ u,
  (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
   FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      olap_dimensionality$ diml,
      olap_cube_dimensions$ dim,
      obj$ do
    WHERE
      do.obj# = dim.obj#
      AND diml.dimensioned_object_type = 1 --CUBE
      AND diml.dimensioned_object_id = c.obj#
      AND diml.dimension_type = 11 --DIMENSION
      AND diml.dimension_id = do.obj#
    )
    GROUP BY obj# ) da 
WHERE 
  o.obj#=c.obj#
  AND c.obj#=da.obj#(+)
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1 -- CUBE
  AND io.option_type(+) = 44 -- sub partition3 name 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1 -- CUBE
  AND io2.option_type(+) = 45 -- sub partition3 precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1 --CUBE
  AND io3.option_type(+) = 43 -- sub partition level3
  AND io3.option_num_value=hl.hierarchy_level_id(+)  
  AND hl.hierarchy_id=h.hierarchy_id
  AND hl.dim_level_id=dl.level_id
  AND h.dim_obj#=od.obj#
UNION ALL
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  mo.option_value SUB_PARTITION_LEVEL_NAME,
  mo2.option_num_value PRECOMPUTE_PERCENT,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME,
  mo.OPTION_ORDER + 1 SUB_PARTITION_LEVEL_ORDER
FROM  
  olap_cubes$ c,
  obj$ o,
  olap_multi_options$ mo,
  olap_multi_options$ mo2,
  olap_multi_options$ mo3,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od,
  user$ u,
  (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
   FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      olap_dimensionality$ diml,
      olap_cube_dimensions$ dim,
      obj$ do
    WHERE
      do.obj# = dim.obj#
      AND diml.dimensioned_object_type = 1 --CUBE
      AND diml.dimensioned_object_id = c.obj#
      AND diml.dimension_type = 11 --DIMENSION
      AND diml.dimension_id = do.obj#
    )
    GROUP BY obj# ) da 
WHERE 
  o.obj#=c.obj#
  AND c.obj#=da.obj#(+)
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
  AND mo.owning_objectid(+)=c.obj#
  AND mo.object_type(+)=1 -- CUBE
  AND mo.option_type(+) = 5 -- sub partition name 
  AND mo2.owning_objectid(+)=c.obj#
  AND mo2.object_type=1 -- CUBE
  AND mo2.option_type = 6 -- sub partition precompute percent 
  AND mo3.owning_objectid=c.obj#
  AND mo3.object_type(+)=1 --CUBE
  AND mo3.option_type(+) = 4 -- sub partition level
  AND mo.OPTION_ORDER = mo2.OPTION_ORDER 
  AND mo2.OPTION_ORDER = mo3.OPTION_ORDER
  AND mo3.option_num_value=hl.hierarchy_level_id
  AND hl.hierarchy_id=h.hierarchy_id
  AND hl.dim_level_id=dl.level_id
  AND h.dim_obj#=od.obj#
/

comment on column ALL_CUBE_SUB_PARTITION_LEVELS.CUBE_NAME is
'Name of the OLAP Cube'
/
comment on column ALL_CUBE_SUB_PARTITION_LEVELS.SUB_PARTITION_LEVEL_NAME is
'Name of the secondary partition level of the OLAP Cube'
/
comment on column ALL_CUBE_SUB_PARTITION_LEVELS.PRECOMPUTE_PERCENT is
'Precompute percent of the secondary partition level of the OLAP Cube'
/
comment on column ALL_CUBE_SUB_PARTITION_LEVELS.PARTITION_HIERARCHY_NAME is
'Name of the Hierarchy for which there is a secondary partition level on the OLAP Cube'
/
comment on column ALL_CUBE_SUB_PARTITION_LEVELS.PARTITION_LEVEL_NAME is
'Name of the HierarchyLevel for which there is a secondary partition level on the OLAP Cube'
/
comment on column ALL_CUBE_SUB_PARTITION_LEVELS.PARTITION_DIMENSION_NAME is
'Name of the Cube Dimension for which there is a secondary partition level on the OLAP Cube'
/
comment on column ALL_CUBE_SUB_PARTITION_LEVELS.SUB_PARTITION_LEVEL_ORDER is
'Order number of the secondary partition level on the OLAP cube'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_SUB_PARTITION_LEVELS FOR SYS.ALL_CUBE_SUB_PARTITION_LEVELS
/
GRANT READ ON ALL_CUBE_SUB_PARTITION_LEVELS to public
/

-- OLAP_DIMENSIONALITY$ DATA DICTIONARY VIEWS -
create or replace view DBA_CUBE_DIMENSIONALITY
AS
SELECT
   cu.name OWNER,
   co.name CUBE_NAME,
   do.name DIMENSION_NAME,
   io_diml.option_value DIMENSIONALITY_NAME,
   diml.dimensionality_id DIMENSIONALITY_ID,
   diml.order_num ORDER_NUM,
   (case
     when io.option_num_value is null then 0
     else io.option_num_value
    end) IS_SPARSE,
   io_eap.option_value ET_ATTR_PREFIX
FROM  
  olap_cubes$ c, 
  user$ cu, 
  obj$ co,
  olap_dimensionality$ diml,
  obj$ do,
  olap_impl_options$ io,
  olap_impl_options$ io_eap,
  olap_impl_options$ io_diml
WHERE
  co.obj# = c.obj#
  AND co.owner# = cu.user#
  AND diml.dimensioned_object_type = 1 --CUBE
  AND diml.dimensioned_object_id = c.obj#
  AND diml.dimension_type = 11 --DIMENSION
  AND diml.dimension_id = do.obj#
  AND io.object_type(+) = 16 -- DIMENSIONALITY 
  AND io.owning_objectid(+) = diml.dimensionality_id
  AND io.option_type(+) = 10 -- IS_SPARSE_DIM   
  AND io_eap.object_type(+) = 16 -- DIMENSIONALITY 
  AND io_eap.owning_objectid(+) = diml.dimensionality_id
  AND io_eap.option_type(+) =  36 -- ET_ATTR_PREFIX 
  AND io_diml.object_type(+) = 16 -- DIMENSIONALITY
  AND io_diml.owning_objectid(+) = diml.dimensionality_id
  AND io_diml.option_type(+) =  33 -- DIMENSIONALITY NAME
/

comment on table DBA_CUBE_DIMENSIONALITY is
'OLAP Cube Dimensionality in the database'
/
comment on column DBA_CUBE_DIMENSIONALITY.OWNER is
'Owner of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMENSIONALITY.CUBE_NAME is
'Name of the OLAP Cube of the Dimensionality'
/
comment on column DBA_CUBE_DIMENSIONALITY.DIMENSION_NAME is
'Name of the Dimension of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMENSIONALITY.DIMENSIONALITY_NAME is
'Name of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMENSIONALITY.DIMENSIONALITY_ID is
'Dictionary Id of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMENSIONALITY.ORDER_NUM is
'Order number of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMENSIONALITY.IS_SPARSE is
'Indication of whether or not the Dimension is Sparse in the Cube'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIMENSIONALITY FOR SYS.DBA_CUBE_DIMENSIONALITY
/
GRANT SELECT ON DBA_CUBE_DIMENSIONALITY to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_DIMENSIONALITY','CDB_CUBE_DIMENSIONALITY');
create or replace public synonym CDB_CUBE_DIMENSIONALITY for sys.CDB_CUBE_DIMENSIONALITY;
grant select on CDB_CUBE_DIMENSIONALITY to select_catalog_role;

create or replace view ALL_CUBE_DIMENSIONALITY
AS
SELECT
   cu.name OWNER,
   co.name CUBE_NAME,
   do.name DIMENSION_NAME,
   io_diml.option_value DIMENSIONALITY_NAME,
   diml.dimensionality_id DIMENSIONALITY_ID,
   diml.order_num ORDER_NUM,
   (case
     when io.option_num_value is null then 0
     else io.option_num_value
    end) IS_SPARSE,
   io_eap.option_value ET_ATTR_PREFIX
FROM  
  olap_cubes$ c, 
  user$ cu, 
  obj$ co,
  olap_dimensionality$ diml,
  obj$ do,
  olap_impl_options$ io,
  olap_impl_options$ io_eap,
  olap_impl_options$ io_diml,
 (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      olap_dimensionality$ diml,
      olap_cube_dimensions$ dim,
      obj$ do
    WHERE
      do.obj# = dim.obj#
      AND diml.dimensioned_object_type = 1 --CUBE
      AND diml.dimensioned_object_id = c.obj#
      AND diml.dimension_type = 11 --DIMENSION
      AND diml.dimension_id = do.obj#
    )
    GROUP BY obj# ) da 
WHERE
  co.obj# = c.obj#
  AND c.obj#=da.obj#(+)
  AND co.owner# = cu.user#
  AND diml.dimensioned_object_type = 1 --CUBE
  AND diml.dimensioned_object_id = c.obj#
  AND diml.dimension_type = 11 --DIMENSION
  AND diml.dimension_id = do.obj#
  AND io.object_type(+) = 16 -- DIMENSIONALITY 
  AND io.owning_objectid(+) = diml.dimensionality_id
  AND io.option_type(+) = 10 -- IS_SPARSE_DIM   
  AND io_eap.object_type(+) = 16 -- DIMENSIONALITY 
  AND io_eap.owning_objectid(+) = diml.dimensionality_id
  AND io_eap.option_type(+) =  36 -- ET_ATTR_PREFIX   
  AND io_diml.object_type(+) = 16 -- DIMENSIONALITY
  AND io_diml.owning_objectid(+) = diml.dimensionality_id
  AND io_diml.option_type(+) =  33 -- DIMENSIONALITY NAME
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (co.owner#, co.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
/

comment on table ALL_CUBE_DIMENSIONALITY is
'OLAP Cube Dimensionality in the database accessible to the user'
/
comment on column ALL_CUBE_DIMENSIONALITY.OWNER is
'Owner of the OLAP Cube Dimensionality'
/
comment on column ALL_CUBE_DIMENSIONALITY.CUBE_NAME is
'Name of the OLAP Cube of the Dimensionality'
/
comment on column ALL_CUBE_DIMENSIONALITY.DIMENSION_NAME is
'Name of the Dimension of the OLAP Cube Dimensionality'
/
comment on column ALL_CUBE_DIMENSIONALITY.ORDER_NUM is
'Order number of the OLAP Cube Dimensionality'
/
comment on column ALL_CUBE_DIMENSIONALITY.IS_SPARSE is
'Indication of whether or not the Dimension is Sparse in the Cube'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIMENSIONALITY FOR SYS.ALL_CUBE_DIMENSIONALITY
/
GRANT READ ON ALL_CUBE_DIMENSIONALITY to public
/

create or replace view USER_CUBE_DIMENSIONALITY
AS
SELECT
   co.name CUBE_NAME,
   do.name DIMENSION_NAME,
   io_diml.option_value DIMENSIONALITY_NAME,
   diml.dimensionality_id DIMENSIONALITY_ID,
   diml.order_num ORDER_NUM,
   (case
     when io.option_num_value is null then 0
     else io.option_num_value
    end) IS_SPARSE,
   io_eap.option_value ET_ATTR_PREFIX
FROM  
  olap_cubes$ c, 
  obj$ co,
  olap_dimensionality$ diml,
  obj$ do,
  olap_impl_options$ io,
  olap_impl_options$ io_eap,
  olap_impl_options$ io_diml
WHERE
  co.obj# = c.obj# AND co.owner#=USERENV('SCHEMAID')
  AND diml.dimensioned_object_type = 1 --CUBE
  AND diml.dimensioned_object_id = c.obj#
  AND diml.dimension_type = 11 --DIMENSION
  AND diml.dimension_id = do.obj#
  AND io.object_type(+) = 16 -- DIMENSIONALITY 
  AND io.owning_objectid(+) = diml.dimensionality_id
  AND io.option_type(+) = 10 -- IS_SPARSE_DIM   
  AND io_eap.object_type(+) = 16 -- DIMENSIONALITY 
  AND io_eap.owning_objectid(+) = diml.dimensionality_id
  AND io_eap.option_type(+) =  36 -- ET_ATTR_PREFIX
  AND io_diml.object_type(+) = 16 -- DIMENSIONALITY
  AND io_diml.owning_objectid(+) = diml.dimensionality_id
  AND io_diml.option_type(+) =  33 -- DIMENSIONALITY NAME
/
comment on table USER_CUBE_DIMENSIONALITY is
'OLAP Cube Dimensionality owned by the user in the database'
/
comment on column USER_CUBE_DIMENSIONALITY.CUBE_NAME is
'Name of the OLAP Cube of the Dimensionality'
/
comment on column USER_CUBE_DIMENSIONALITY.DIMENSION_NAME is
'Name of the Dimension of the OLAP Cube Dimensionality'
/
comment on column USER_CUBE_DIMENSIONALITY.DIMENSIONALITY_NAME is
'Name of the OLAP Cube Dimensionality'
/
comment on column USER_CUBE_DIMENSIONALITY.DIMENSIONALITY_ID is
'Dictionary Id of the OLAP Cube Dimensionality'
/
comment on column USER_CUBE_DIMENSIONALITY.ORDER_NUM is
'Order number of the OLAP Cube Dimensionality'
/
comment on column USER_CUBE_DIMENSIONALITY.IS_SPARSE is
'Indication of whether or not the Dimension is Sparse in the Cube'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIMENSIONALITY FOR SYS.USER_CUBE_DIMENSIONALITY
/
GRANT READ ON USER_CUBE_DIMENSIONALITY to public
/

-- OLAP_CUBE_MEASURES DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_MEASURES
as
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  m.measure_name MEASURE_NAME,
  m.measure_id MEASURE_ID,
  ss.syntax_clob OVERRIDE_SOLVE_SPEC, 
  DECODE(m.measure_type, 1, 'BASE', 2, 'DERIVED') MEASURE_TYPE,
  DECODE(m.measure_type, 2, s.syntax_clob) EXPRESSION,
  d.description_value DESCRIPTION,
  DECODE(m.type#, 1, decode(m.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                  2, decode(m.scale, null,
                            decode(m.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                  8, 'LONG',
                  9, decode(m.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                  12, 'DATE',
                  23, 'RAW', 24, 'LONG RAW',
                  69, 'ROWID',
                  96, decode(m.charsetform, 2, 'NCHAR', 'CHAR'),
                  100, 'BINARY_FLOAT',
                  101, 'BINARY_DOUBLE',
                  105, 'MLSLABEL',
                  106, 'MLSLABEL',
                  112, decode(m.charsetform, 2, 'NCLOB', 'CLOB'),
                  113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                  178, 'TIME(' ||m.scale|| ')',
                  179, 'TIME(' ||m.scale|| ')' || ' WITH TIME ZONE',
                  180, 'TIMESTAMP(' ||m.scale|| ')',
                  181, 'TIMESTAMP(' ||m.scale|| ')' || ' WITH TIME ZONE',
                  231, 'TIMESTAMP(' ||m.scale|| ')' || ' WITH LOCAL TIME ZONE',
                  182, 'INTERVAL YEAR(' ||m.precision#||') TO MONTH',
                  183, 'INTERVAL DAY(' ||m.precision#||') TO SECOND(' ||
                        m.scale || ')',
                  208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  m.length DATA_LENGTH, 
  m.precision# DATA_PRECISION, 
  m.scale DATA_SCALE,
  io.option_value LOOP_VAR_OVERRIDE,
  io2.option_value LOOP_DENSE_OVERRIDE,
  io3.option_value LOOP_TYPE
FROM   
  olap_measures$ m, 
  user$ u, 
  obj$ o, 
  olap_syntax$ ss,
  olap_syntax$ s, 
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 2 --MEASURE
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
  m.cube_obj#=o.obj#
  AND o.owner#=u.user# 
  AND m.measure_id=s.owner_id(+) 
  AND m.measure_id=ss.owner_id(+)
  AND io.owning_objectid(+)=m.measure_id
  AND io.object_type(+)=2
  AND io.option_type(+)=51 -- LOOP_VAR_OVERRIDE
  AND io2.owning_objectid(+)=m.measure_id
  AND io2.object_type(+)=2
  AND io2.option_type(+)=52 -- LOOP_DENSE_OVERRIDE
  AND io3.owning_objectid(+)=m.measure_id
  AND io3.object_type(+)=2
  AND io3.option_type(+)=53 -- LOOP_TYPE
  AND m.is_hidden=0 --NOT HIDDEN
  AND s.owner_type(+)=2 --MEASURE 
  AND s.ref_role(+)=14 --DERIVED_MEAS_EXPRESSION 
  AND ss.owner_type(+)=2 --MEASURE
  AND ss.ref_role(+)=16 --CONSISTENT_SOLVE_SPEC
  AND m.measure_id=d.owning_object_id(+)
/

comment on table DBA_CUBE_MEASURES is
'OLAP Measures in the database'
/
comment on column DBA_CUBE_MEASURES.OWNER is
'Owner of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.CUBE_NAME is
'Name of the OLAP Cube which owns the Measure'
/
comment on column DBA_CUBE_MEASURES.MEASURE_NAME is
'Name of Measure in the OLAP Cube'
/
comment on column DBA_CUBE_MEASURES.MEASURE_ID is
'Dictionary Id of the Measure in the OLAP Cube'
/
comment on column DBA_CUBE_MEASURES.OVERRIDE_SOLVE_SPEC is
'Override solve specification of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.MEASURE_TYPE is
'Type of Measure in the OLAP Cube'
/
comment on column DBA_CUBE_MEASURES.EXPRESSION is
'Expression of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.DESCRIPTION is
'Description of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.DATA_TYPE is
'Data Type of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.DATA_LENGTH is
'Data Length of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.DATA_PRECISION is
'Data Precision of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.DATA_SCALE is
'Data Scale of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.LOOP_VAR_OVERRIDE is
'Override $LOOP_VAR of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.LOOP_DENSE_OVERRIDE is
'Override $LOOP_DENSE of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.LOOP_TYPE is
'$LOOP_TYPE of the OLAP Measure'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_MEASURES FOR SYS.DBA_CUBE_MEASURES
/
GRANT SELECT ON DBA_CUBE_MEASURES to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_MEASURES','CDB_CUBE_MEASURES');
create or replace public synonym CDB_CUBE_MEASURES for sys.CDB_CUBE_MEASURES;
grant select on CDB_CUBE_MEASURES to select_catalog_role;

create or replace view ALL_CUBE_MEASURES
as
SELECT 
  u.name OWNER,
  o.name CUBE_NAME, 
  m.measure_name MEASURE_NAME,
  m.measure_id MEASURE_ID,
  ss.syntax_clob OVERRIDE_SOLVE_SPEC, 
  DECODE(m.measure_type, 1, 'BASE', 2, 'DERIVED') MEASURE_TYPE,
  DECODE(m.measure_type, 2, s.syntax_clob) EXPRESSION,
  d.description_value DESCRIPTION,
  DECODE(m.type#, 1, decode(m.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                  2, decode(m.scale, null,
                            decode(m.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                  8, 'LONG',
                  9, decode(m.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                  12, 'DATE',
                  23, 'RAW', 24, 'LONG RAW',
                  69, 'ROWID',
                  96, decode(m.charsetform, 2, 'NCHAR', 'CHAR'),
                  100, 'BINARY_FLOAT',
                  101, 'BINARY_DOUBLE',
                  105, 'MLSLABEL',
                  106, 'MLSLABEL',
                  112, decode(m.charsetform, 2, 'NCLOB', 'CLOB'),
                  113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                  178, 'TIME(' ||m.scale|| ')',
                  179, 'TIME(' ||m.scale|| ')' || ' WITH TIME ZONE',
                  180, 'TIMESTAMP(' ||m.scale|| ')',
                  181, 'TIMESTAMP(' ||m.scale|| ')' || ' WITH TIME ZONE',
                  231, 'TIMESTAMP(' ||m.scale|| ')' || ' WITH LOCAL TIME ZONE',
                  182, 'INTERVAL YEAR(' ||m.precision#||') TO MONTH',
                  183, 'INTERVAL DAY(' ||m.precision#||') TO SECOND(' ||
                        m.scale || ')',
                  208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  m.length DATA_LENGTH, 
  m.precision# DATA_PRECISION, 
  m.scale DATA_SCALE,
  io.option_value LOOP_VAR_OVERRIDE,
  io2.option_value LOOP_DENSE_OVERRIDE,
  io3.option_value LOOP_TYPE
FROM   
  olap_measures$ m, 
  user$ u, 
  obj$ o, 
  olap_syntax$ ss,
  olap_syntax$ s, 
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 2 --MEASURE
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
 (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE  
  m.cube_obj#=o.obj#
  AND o.obj#=da.obj#(+)
  AND o.owner#=u.user# 
  AND m.measure_id=s.owner_id(+) 
  AND m.measure_id=ss.owner_id(+)
  AND m.is_hidden=0 --NOT HIDDEN
  AND s.owner_type(+)=2 --MEASURE 
  AND s.ref_role(+)=14 --DERIVED_MEAS_EXPRESSION 
  AND ss.owner_type(+)=2 --MEASURE
  AND ss.ref_role(+)=16 --CONSISTENT_SOLVE_SPEC
  AND m.measure_id=d.owning_object_id(+)
  AND io.owning_objectid(+)=m.measure_id
  AND io.object_type(+)=2
  AND io.option_type(+)=51 -- LOOP_VAR_OVERRIDE
  AND io2.owning_objectid(+)=m.measure_id
  AND io2.object_type(+)=2
  AND io2.option_type(+)=52 -- LOOP_DENSE_OVERRIDE
  AND io3.owning_objectid(+)=m.measure_id
  AND io3.object_type(+)=2
  AND io3.option_type(+)=53 -- LOOP_TYPE
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
/

comment on table ALL_CUBE_MEASURES is
'OLAP Measures in the database accessible to the user'
/
comment on column ALL_CUBE_MEASURES.OWNER is
'Owner of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.CUBE_NAME is
'Name of the OLAP Cube which owns the Measure'
/
comment on column ALL_CUBE_MEASURES.MEASURE_NAME is
'Name of Measure in the OLAP Cube'
/
comment on column ALL_CUBE_MEASURES.OVERRIDE_SOLVE_SPEC is
'Override solve specification of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.MEASURE_TYPE is
'Type of Measure in the OLAP Cube'
/
comment on column ALL_CUBE_MEASURES.EXPRESSION is
'Expression of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.DESCRIPTION is
'Description of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.DATA_TYPE is
'Data Type of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.DATA_LENGTH is
'Data Length of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.DATA_PRECISION is
'Data Precision of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.DATA_SCALE is
'Data Scale of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.LOOP_VAR_OVERRIDE is
'Override $LOOP_VAR of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.LOOP_DENSE_OVERRIDE is
'Override $LOOP_DENSE of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.LOOP_TYPE is
'$LOOP_TYPE of the OLAP Measure'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_MEASURES FOR SYS.ALL_CUBE_MEASURES
/
GRANT READ ON ALL_CUBE_MEASURES to public
/


create or replace view USER_CUBE_MEASURES
as
SELECT 
  o.name CUBE_NAME, 
  m.measure_name MEASURE_NAME,
  m.measure_id MEASURE_ID,
  ss.syntax_clob OVERRIDE_SOLVE_SPEC, 
  DECODE(m.measure_type, 1, 'BASE', 2, 'DERIVED') MEASURE_TYPE,
  DECODE(m.measure_type, 2, s.syntax_clob) EXPRESSION,
  d.description_value DESCRIPTION,
  DECODE(m.type#, 1, decode(m.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                  2, decode(m.scale, null,
                            decode(m.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                  8, 'LONG',
                  9, decode(m.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                  12, 'DATE',
                  23, 'RAW', 24, 'LONG RAW',
                  69, 'ROWID',
                  96, decode(m.charsetform, 2, 'NCHAR', 'CHAR'),
                  100, 'BINARY_FLOAT',
                  101, 'BINARY_DOUBLE',
                  105, 'MLSLABEL',
                  106, 'MLSLABEL',
                  112, decode(m.charsetform, 2, 'NCLOB', 'CLOB'),
                  113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                  178, 'TIME(' ||m.scale|| ')',
                  179, 'TIME(' ||m.scale|| ')' || ' WITH TIME ZONE',
                  180, 'TIMESTAMP(' ||m.scale|| ')',
                  181, 'TIMESTAMP(' ||m.scale|| ')' || ' WITH TIME ZONE',
                  231, 'TIMESTAMP(' ||m.scale|| ')' || ' WITH LOCAL TIME ZONE',
                  182, 'INTERVAL YEAR(' ||m.precision#||') TO MONTH',
                  183, 'INTERVAL DAY(' ||m.precision#||') TO SECOND(' ||
                        m.scale || ')',
                  208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  m.length DATA_LENGTH, 
  m.precision# DATA_PRECISION, 
  m.scale DATA_SCALE,
  io.option_value LOOP_VAR_OVERRIDE,
  io2.option_value LOOP_DENSE_OVERRIDE,
  io3.option_value LOOP_TYPE
FROM   
  olap_measures$ m, 
  obj$ o, 
  olap_syntax$ ss,
  olap_syntax$ s, 
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 2 --MEASURE
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
  m.cube_obj#=o.obj# AND o.owner#=USERENV('SCHEMAID')
  AND m.measure_id=s.owner_id(+) 
  AND m.measure_id=ss.owner_id(+)
  AND io.owning_objectid(+)=m.measure_id
  AND io.object_type(+)=2
  AND io.option_type(+)=51 -- LOOP_VAR_OVERRIDE
  AND io2.owning_objectid(+)=m.measure_id
  AND io2.object_type(+)=2
  AND io2.option_type(+)=52 -- LOOP_DENSE_OVERRIDE
  AND io3.owning_objectid(+)=m.measure_id
  AND io3.object_type(+)=2
  AND io3.option_type(+)=53 -- LOOP_TYPE
  AND m.is_hidden=0 --NOT HIDDEN
  AND s.owner_type(+)=2 --MEASURE 
  AND s.ref_role(+)=14 --DERIVED_MEAS_EXPRESSION 
  AND ss.owner_type(+)=2 --MEASURE
  AND ss.ref_role(+)=16 --CONSISTENT_SOLVE_SPEC
  AND m.measure_id=d.owning_object_id(+)
/

comment on table USER_CUBE_MEASURES is
'OLAP Measures owned by the user in the database'
/
comment on column USER_CUBE_MEASURES.CUBE_NAME is
'Name of the OLAP Cube which owns the Measure'
/
comment on column USER_CUBE_MEASURES.MEASURE_NAME is
'Name of Measure in the OLAP Cube'
/
comment on column USER_CUBE_MEASURES.MEASURE_ID is
'Dictionary Id of the Measure in the OLAP Cube'
/
comment on column USER_CUBE_MEASURES.OVERRIDE_SOLVE_SPEC is
'Override solve specification of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.MEASURE_TYPE is
'Type of Measure in the OLAP Cube'
/
comment on column USER_CUBE_MEASURES.EXPRESSION is
'Expression of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.DESCRIPTION is
'Long Description of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.DATA_TYPE is
'Data Type of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.DATA_LENGTH is
'Data Length of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.DATA_PRECISION is
'Data Precision of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.DATA_SCALE is
'Data Scale of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.LOOP_VAR_OVERRIDE is
'Override $LOOP_VAR of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.LOOP_DENSE_OVERRIDE is
'Override $LOOP_DENSE of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.LOOP_TYPE is
'$LOOP_TYPE of the OLAP Measure'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_MEASURES FOR SYS.USER_CUBE_MEASURES
/
GRANT READ ON USER_CUBE_MEASURES to public
/


-- OLAP_CUBE_DIMENSIONS DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_DIMENSIONS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME,
  dim.obj# DIMENSION_ID,
  DECODE(dim.dimension_type,1, 'STANDARD',
                            2, 'TIME',
                            3, 'LINEITEM',
                            4, 'MEASURE',
                            5, 'LANGUAGE',
                            6, 'FINANCIAL_ELEMENT',
                            7, 'SPATIAL') DIMENSION_TYPE, 
  a.awname AW_NAME, 
  h.hierarchy_name DEFAULT_HIERARCHY_NAME, 
  d.description_value DESCRIPTION,
  io.option_value HIERARCHY_CONSISTENCY_RULE,
  DECODE(io2.option_num_value, 1, 'YES', 'NO') ADD_UNIQUE_KEY_PREFIX,
  syn.syntax_clob CUSTOM_ORDER
FROM   
   olap_cube_dimensions$ dim, 
   user$ u,  
   aw$ a, 
   obj$ o, 
   olap_hierarchies$ h, 
   olap_syntax$ syn,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 11 --DIMENSION
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io, -- For HIERARCHY_CONSISTENCY_RULE
  olap_impl_options$ io2 -- For ADD_UNIQUE_KEY_PREFIX
WHERE  
   o.obj#=dim.obj# AND o.owner#=u.user#
   AND dim.awseq#=a.awseq#(+) 
   AND h.hierarchy_id(+)=dim.default_hierarchy_id
   AND d.owning_object_id(+)=dim.obj#
   AND io.object_type(+) = 11 -- DIMENSION
   AND io.owning_objectid(+) = dim.obj#
   AND io.option_type(+) = 26 -- Hierarchy Consistency Rule
   AND dim.obj# = io2.owning_objectid(+)
   AND io2.object_type(+) = 11 -- DIMENSION
   AND io2.option_type(+) = 29 -- Add_Unique_Key_Prefix
   AND syn.owner_id(+) = dim.obj#
   AND syn.owner_type(+) = 11
   AND syn.ref_role(+) = 23 -- CustomOrder
/

comment on table DBA_CUBE_DIMENSIONS is
'OLAP Cube Dimensions in the database'
/
comment on column DBA_CUBE_DIMENSIONS.OWNER is
'Owner of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.DIMENSION_NAME is
'Name of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.DIMENSION_ID is
'Dictionary Id of the Olap Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.DIMENSION_TYPE is
'Type of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.AW_NAME is
'Name of the Analytic Workspace which owns the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.DESCRIPTION is
'Description of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.DEFAULT_HIERARCHY_NAME is
'Default Hierarchy name of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.DESCRIPTION is
'Long Description of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.HIERARCHY_CONSISTENCY_RULE is
'Hierarchy consistency rule of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.ADD_UNIQUE_KEY_PREFIX is
'Add_Unique_Key_Prefix flag of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.CUSTOM_ORDER is
'Custom Order of the OLAP Cube Dimension'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIMENSIONS 
FOR SYS.DBA_CUBE_DIMENSIONS
/
GRANT SELECT ON DBA_CUBE_DIMENSIONS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_DIMENSIONS','CDB_CUBE_DIMENSIONS');
create or replace public synonym CDB_CUBE_DIMENSIONS for sys.CDB_CUBE_DIMENSIONS;
grant select on CDB_CUBE_DIMENSIONS to select_catalog_role;

create or replace view ALL_CUBE_DIMENSIONS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  dim.obj# DIMENSION_ID,
  DECODE(dim.dimension_type,1, 'STANDARD',
                            2, 'TIME',
                            3, 'LINEITEM',
                            4, 'MEASURE',
                            5, 'LANGUAGE',
                            6, 'FINANCIAL_ELEMENT',
                            7, 'SPATIAL') DIMENSION_TYPE, 
  a.awname AW_NAME, 
  h.hierarchy_name DEFAULT_HIERARCHY_NAME, 
  d.description_value DESCRIPTION,
  io.option_value HIERARCHY_CONSISTENCY_RULE,
  DECODE(io2.option_num_value, 1, 'YES', 'NO') ADD_UNIQUE_KEY_PREFIX,
  syn.syntax_clob CUSTOM_ORDER
FROM   
   olap_cube_dimensions$ dim, 
   user$ u,  
   aw$ a, 
   obj$ o, 
   olap_hierarchies$ h, 
   olap_syntax$ syn,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 11 --DIMENSION
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io, -- For HIERARCHY_CONSISTENCY_RULE
  olap_impl_options$ io2 -- For ADD_UNIQUE_KEY_PREFIX
WHERE  
   o.obj#=dim.obj# AND o.owner#=u.user#
   AND dim.awseq#=a.awseq#(+) 
   AND h.hierarchy_id(+)=dim.default_hierarchy_id
   AND d.owning_object_id(+)=dim.obj#
   AND io.object_type(+) = 11 -- DIMENSION
   AND io.owning_objectid(+) = dim.obj#
   AND io.option_type(+) = 26 -- Hierarchy Consistency Rule
   AND dim.obj# = io2.owning_objectid(+)
   AND io2.object_type(+) = 11 -- DIMENSION
   AND io2.option_type(+) = 29 -- Add_Unique_Key_Prefix
   AND syn.owner_id(+) = dim.obj#
   AND syn.owner_type(+) = 11
   AND syn.ref_role(+) = 23 -- CustomOrder
   AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_CUBE_DIMENSIONS is
'OLAP Cube Dimensions in the database accessible by the user'
/
comment on column ALL_CUBE_DIMENSIONS.OWNER is
'Owner of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.DIMENSION_NAME is
'Name of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.DIMENSION_ID is
'Dictionary Id of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.DIMENSION_TYPE is
'Type of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.AW_NAME is
'Name of the Analytic Workspace which owns the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.DESCRIPTION is
'Description of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.DEFAULT_HIERARCHY_NAME is
'Default Hierarchy name of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.DESCRIPTION is
'Long Description of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.HIERARCHY_CONSISTENCY_RULE is
'Hierarchy consistency rule of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.ADD_UNIQUE_KEY_PREFIX is
'Add_Unique_Key_Prefix flag of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.CUSTOM_ORDER is
'Custom Order of the OLAP Cube Dimension'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIMENSIONS FOR SYS.ALL_CUBE_DIMENSIONS
/
GRANT READ ON ALL_CUBE_DIMENSIONS to public
/

create or replace view USER_CUBE_DIMENSIONS
as
SELECT 
  o.name DIMENSION_NAME, 
  dim.obj# DIMENSION_ID,
  DECODE(dim.dimension_type,1, 'STANDARD',
                            2, 'TIME',
                            3, 'LINEITEM',
                            4, 'MEASURE',
                            5, 'LANGUAGE',
                            6, 'FINANCIAL_ELEMENT',
                            7, 'SPATIAL') DIMENSION_TYPE, 
  a.awname AW_NAME, 
  h.hierarchy_name DEFAULT_HIERARCHY_NAME, 
  d.description_value DESCRIPTION,
  io.option_value HIERARCHY_CONSISTENCY_RULE,
  DECODE(io2.option_num_value, 1, 'YES', 'NO') ADD_UNIQUE_KEY_PREFIX,
  syn.syntax_clob CUSTOM_ORDER
FROM   
   olap_cube_dimensions$ dim, 
   aw$ a, 
   obj$ o, 
   olap_hierarchies$ h,
   olap_syntax$ syn,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 11 --DIMENSION
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io, -- For HIERARCHY_CONSISTENCY_RULE
  olap_impl_options$ io2 -- For ADD_UNIQUE_KEY_PREFIX
WHERE  
   o.obj#=dim.obj# AND o.owner#=USERENV('SCHEMAID')
   AND dim.awseq#=a.awseq#(+) 
   AND h.hierarchy_id(+)=dim.default_hierarchy_id
   AND d.owning_object_id(+)=dim.obj#
   AND io.object_type(+) = 11 -- DIMENSION
   AND io.owning_objectid(+) = dim.obj#
   AND io.option_type(+) = 26 -- Hierarchy Consistency Rule
   AND dim.obj# = io2.owning_objectid(+)
   AND io2.object_type(+) = 11 -- DIMENSION
   AND io2.option_type(+) = 29 -- Add_Unique_Key_Prefix
   AND syn.owner_id(+) = dim.obj#
   AND syn.owner_type(+) = 11
   AND syn.ref_role(+) = 23 -- CustomOrder
/

comment on table USER_CUBE_DIMENSIONS is
'OLAP Cube Dimensions owned by the user in the database'
/
comment on column USER_CUBE_DIMENSIONS.DIMENSION_NAME is
'Name of the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.DIMENSION_ID is
'Dictionary Id of the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.DIMENSION_TYPE is
'Type of the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.AW_NAME is
'Name of the Analytic Workspace which owns the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.DESCRIPTION is
'Description of the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.DEFAULT_HIERARCHY_NAME is
'Default Hierarchy name of the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.DESCRIPTION is
'Long Description of the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.HIERARCHY_CONSISTENCY_RULE is
'Hierarchy consistency rule of the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.ADD_UNIQUE_KEY_PREFIX is
'Add_Unique_Key_Prefix flag of the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.CUSTOM_ORDER is
'Custom Order of the OLAP Cube Dimension'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIMENSIONS FOR SYS.USER_CUBE_DIMENSIONS
/
GRANT READ ON USER_CUBE_DIMENSIONS to public
/

-- OLAP_CUBE_HIERARCHIES DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_HIERARCHIES
as
SELECT 
   u.name OWNER, 
   o.name DIMENSION_NAME, 
   h.hierarchy_name HIERARCHY_NAME,
   h.hierarchy_id HIERARCHY_ID,
   DECODE(h.hierarchy_type, 1, 'LEVEL', 2, 'VALUE') HIERARCHY_TYPE,  
   d.description_value DESCRIPTION,
   (case
     when io.option_num_value is null then 0
     else io.option_num_value
    end) IS_RAGGED,
   (case
     when io2.option_num_value is null then 0
     else io2.option_num_value
    end) IS_SKIP_LEVEL,
   io3.option_value REFRESH_MVIEW_NAME,
   syn.syntax_clob CUSTOM_ORDER
FROM 
  olap_hierarchies$ h, 
  user$ u, 
  obj$ o, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 13 --HIERARCHY
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_syntax$ syn
WHERE 
  h.dim_obj#=o.obj#
  AND o.owner#=u.user#
  AND d.owning_object_id(+)=h.hierarchy_id
  AND io.object_type(+) = 13 -- HIERARCHY 
  AND io.owning_objectid(+) = h.hierarchy_id
  AND io.option_type(+) = 6 -- IS_RAGGED 
  AND io2.object_type(+) = 13 -- HIERARCHY 
  AND io2.owning_objectid(+) = h.hierarchy_id
  AND io2.option_type(+) = 1 -- IS_SKIP_LEVEL 
  AND io3.object_type(+) = 13 -- HIERARCHY
  AND io3.owning_objectid(+) = h.hierarchy_id
  AND io3.option_type(+) = 30 -- refresh MV name
  AND syn.owner_id(+) = h.hierarchy_id
  AND syn.owner_type(+) = 13
  AND syn.ref_role(+) = 23 -- CustomOrder
/

comment on table DBA_CUBE_HIERARCHIES is
'OLAP Hierarchies in the database'
/
comment on column DBA_CUBE_HIERARCHIES.OWNER is
'Owner of the OLAP Hierarchy'
/
comment on column DBA_CUBE_HIERARCHIES.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy'
/
comment on column DBA_CUBE_HIERARCHIES.HIERARCHY_NAME is
'Name of the OLAP Hierarchy'
/
comment on column DBA_CUBE_HIERARCHIES.HIERARCHY_ID is
'Dictionary Id of the OLAP Hierarchy'
/
comment on column DBA_CUBE_HIERARCHIES.HIERARCHY_TYPE is
'Type of the OLAP Hierarchy'
/
comment on column DBA_CUBE_HIERARCHIES.DESCRIPTION is
'Long Description of the OLAP Hierarchy'
/
comment on column DBA_CUBE_HIERARCHIES.IS_RAGGED is
'Indication of whether the OLAP Hierarchy is Ragged'
/
comment on column DBA_CUBE_HIERARCHIES.IS_SKIP_LEVEL is
'Indication of whether the OLAP Hierarchy is SkipLevel'
/
comment on column DBA_CUBE_HIERARCHIES.REFRESH_MVIEW_NAME is
'Name of the refresh materialized view for the OLAP Hierarchy'
/
comment on column DBA_CUBE_HIERARCHIES.CUSTOM_ORDER is
'Custom Order of the OLAP Hierarchy'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_HIERARCHIES FOR SYS.DBA_CUBE_HIERARCHIES
/
GRANT SELECT ON DBA_CUBE_HIERARCHIES to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_HIERARCHIES','CDB_CUBE_HIERARCHIES');
create or replace public synonym CDB_CUBE_HIERARCHIES for sys.CDB_CUBE_HIERARCHIES;
grant select on CDB_CUBE_HIERARCHIES to select_catalog_role;

create or replace view ALL_CUBE_HIERARCHIES
as
SELECT 
   u.name OWNER, 
   o.name DIMENSION_NAME, 
   h.hierarchy_name HIERARCHY_NAME, 
   h.hierarchy_id HIERARCHY_ID,
   DECODE(h.hierarchy_type, 1, 'LEVEL', 2, 'VALUE') HIERARCHY_TYPE,  
   d.description_value DESCRIPTION,
   (case
     when io.option_num_value is null then 0
     else io.option_num_value
    end) IS_RAGGED,
   (case
     when io2.option_num_value is null then 0
     else io2.option_num_value
    end) IS_SKIP_LEVEL,
   io3.option_value REFRESH_MVIEW_NAME,
   syn.syntax_clob CUSTOM_ORDER
FROM 
  olap_hierarchies$ h, 
  user$ u, 
  obj$ o, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 13 --HIERARCHY
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_syntax$ syn
WHERE 
  h.dim_obj#=o.obj#
  AND o.owner#=u.user#
  AND d.owning_object_id(+)=h.hierarchy_id
  AND io.object_type(+) = 13 -- HIERARCHY 
  AND io.owning_objectid(+) = h.hierarchy_id
  AND io.option_type(+) = 6 -- IS_RAGGED 
  AND io2.object_type(+) = 13 -- HIERARCHY 
  AND io2.owning_objectid(+) = h.hierarchy_id
  AND io2.option_type(+) = 1 -- IS_SKIP_LEVEL 
  AND io3.object_type(+) = 13 -- HIERARCHY
  AND io3.owning_objectid(+) = h.hierarchy_id
  AND io3.option_type(+) = 30 -- refresh MV name
  AND syn.owner_id(+) = h.hierarchy_id
  AND syn.owner_type(+) = 13
  AND syn.ref_role(+) = 23 -- CustomOrder
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_CUBE_HIERARCHIES is
'OLAP Hierarchies in the database accessible by the user'
/
comment on column ALL_CUBE_HIERARCHIES.OWNER is
'Owner of the OLAP Hierarchy'
/
comment on column ALL_CUBE_HIERARCHIES.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy'
/
comment on column ALL_CUBE_HIERARCHIES.HIERARCHY_NAME is
'Name of the OLAP Hierarchy'
/
comment on column ALL_CUBE_HIERARCHIES.HIERARCHY_ID is
'Dictionary Id of the OLAP Hierarchy'
/
comment on column ALL_CUBE_HIERARCHIES.HIERARCHY_TYPE is
'Type of the OLAP Hierarchy'
/
comment on column ALL_CUBE_HIERARCHIES.DESCRIPTION is
'Long Description of the OLAP Hierarchy'
/
comment on column ALL_CUBE_HIERARCHIES.IS_RAGGED is
'Indication of whether the OLAP Hierarchy is Ragged'
/
comment on column ALL_CUBE_HIERARCHIES.IS_SKIP_LEVEL is
'Indication of whether the OLAP Hierarchy is SkipLevel'
/
comment on column ALL_CUBE_HIERARCHIES.REFRESH_MVIEW_NAME is
'Name of the refresh materialized view for the OLAP Hierarchy'
/
comment on column ALL_CUBE_HIERARCHIES.CUSTOM_ORDER is
'Custom Order of the OLAP Hierarchy'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_HIERARCHIES FOR SYS.ALL_CUBE_HIERARCHIES
/
GRANT READ ON ALL_CUBE_HIERARCHIES to public
/

create or replace view USER_CUBE_HIERARCHIES
as
SELECT 
   o.name DIMENSION_NAME, 
   h.hierarchy_name HIERARCHY_NAME, 
   h.hierarchy_id HIERARCHY_ID,
   DECODE(h.hierarchy_type, 1, 'LEVEL', 2, 'VALUE') HIERARCHY_TYPE,  
   d.description_value DESCRIPTION,
   (case
     when io.option_num_value is null then 0
     else io.option_num_value
    end) IS_RAGGED,
   (case
     when io2.option_num_value is null then 0
     else io2.option_num_value
    end) IS_SKIP_LEVEL,
   io3.option_value REFRESH_MVIEW_NAME,
   syn.syntax_clob CUSTOM_ORDER
FROM 
  olap_hierarchies$ h, 
  obj$ o, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 13 --HIERARCHY
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_syntax$ syn
WHERE 
  h.dim_obj#=o.obj# AND o.owner#=USERENV('SCHEMAID')
  AND d.owning_object_id(+)=h.hierarchy_id
  AND io.object_type(+) = 13 -- HIERARCHY 
  AND io.owning_objectid(+) = h.hierarchy_id
  AND io.option_type(+) = 6 -- IS_RAGGED 
  AND io2.object_type(+) = 13 -- HIERARCHY 
  AND io2.owning_objectid(+) = h.hierarchy_id
  AND io2.option_type(+) = 1 -- IS_SKIP_LEVEL 
  AND io3.object_type(+) = 13 -- HIERARCHY
  AND io3.owning_objectid(+) = h.hierarchy_id
  AND io3.option_type(+) = 30 -- refresh MV name
  AND syn.owner_id(+) = h.hierarchy_id
  AND syn.owner_type(+) = 13
  AND syn.ref_role(+) = 23 -- CustomOrder
/

comment on table USER_CUBE_HIERARCHIES is
'OLAP Hierarchies owned by the user in the database'
/
comment on column USER_CUBE_HIERARCHIES.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy'
/
comment on column USER_CUBE_HIERARCHIES.HIERARCHY_NAME is
'Name of the OLAP Hierarchy'
/
comment on column USER_CUBE_HIERARCHIES.HIERARCHY_ID is
'Dictionary Id of the OLAP Hierarchy'
/
comment on column USER_CUBE_HIERARCHIES.HIERARCHY_TYPE is
'Type of the OLAP Hierarchy'
/
comment on column USER_CUBE_HIERARCHIES.DESCRIPTION is
'Long Description of the OLAP Hierarchy'
/
comment on column USER_CUBE_HIERARCHIES.IS_RAGGED is
'Indication of whether the OLAP Hierarchy is Ragged'
/
comment on column USER_CUBE_HIERARCHIES.IS_SKIP_LEVEL is
'Indication of whether the OLAP Hierarchy is SkipLevel'
/
comment on column USER_CUBE_HIERARCHIES.REFRESH_MVIEW_NAME is
'Name of the refresh materialized view for the OLAP Hierarchy'
/
comment on column USER_CUBE_HIERARCHIES.CUSTOM_ORDER is
'Custom Order of the OLAP Hierarchy'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_HIERARCHIES FOR SYS.USER_CUBE_HIERARCHIES
/
GRANT READ ON USER_CUBE_HIERARCHIES to public
/

-- OLAP_HIER_LEVELS DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_HIER_LEVELS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  h.hierarchy_name HIERARCHY_NAME, 
  dl.level_name LEVEL_NAME,
  hl.hierarchy_level_id HIERARCHY_LEVEL_ID,
  hl.order_num ORDER_NUM,  
  d.description_value DESCRIPTION
FROM 
  olap_hier_levels$ hl, 
  user$ u, obj$ o, 
  olap_hierarchies$ h,
  olap_dim_levels$ dl, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 14 --HIER_LEVEL
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  hl.hierarchy_id=h.hierarchy_id AND o.owner#=u.user#
  AND dl.level_id=hl.dim_level_id AND o.obj#=dl.dim_obj#
  AND d.owning_object_id(+)=hl.hierarchy_level_id
/

comment on table DBA_CUBE_HIER_LEVELS is
'OLAP Hierarchy Levels in the database'
/
comment on column DBA_CUBE_HIER_LEVELS.OWNER is
'Owner of the OLAP Hierarchy Level'
/
comment on column DBA_CUBE_HIER_LEVELS.DIMENSION_NAME is
'Name of the owning Dimension of the OLAP Hierarchy Level'
/
comment on column DBA_CUBE_HIER_LEVELS.HIERARCHY_NAME is
'Name of the owning Hierarchy of the OLAP Hierarchy Level'
/
comment on column DBA_CUBE_HIER_LEVELS.LEVEL_NAME is
'Name of the OLAP Dimension Level'
/
comment on column DBA_CUBE_HIER_LEVELS.HIERARCHY_LEVEL_ID is
'Dictionary Id of the OLAP Hierarchy Level'
/
comment on column DBA_CUBE_HIER_LEVELS.ORDER_NUM is
'Order number of the OLAP Hierarchy Level within the hierarchy'
/
comment on column DBA_CUBE_HIER_LEVELS.DESCRIPTION is
'Long Description of the OLAP Hierarchy Level'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_HIER_LEVELS 
FOR SYS.DBA_CUBE_HIER_LEVELS
/
GRANT SELECT ON DBA_CUBE_HIER_LEVELS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_HIER_LEVELS','CDB_CUBE_HIER_LEVELS');
create or replace public synonym CDB_CUBE_HIER_LEVELS for sys.CDB_CUBE_HIER_LEVELS;
grant select on CDB_CUBE_HIER_LEVELS to select_catalog_role;

create or replace view ALL_CUBE_HIER_LEVELS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  h.hierarchy_name HIERARCHY_NAME, 
  dl.level_name LEVEL_NAME, 
  hl.hierarchy_level_id HIERARCHY_LEVEL_ID,
  hl.order_num ORDER_NUM,  
  d.description_value DESCRIPTION
FROM 
  olap_hier_levels$ hl, 
  user$ u, obj$ o, 
  olap_hierarchies$ h,
  olap_dim_levels$ dl, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 14 --HIER_LEVEL
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  hl.hierarchy_id=h.hierarchy_id AND o.owner#=u.user#
  AND dl.level_id=hl.dim_level_id AND o.obj#=dl.dim_obj#
  AND d.owning_object_id(+)=hl.hierarchy_level_id
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_CUBE_HIER_LEVELS is
'OLAP Hierarchy Levels in the database accessible to the user'
/
comment on column ALL_CUBE_HIER_LEVELS.OWNER is
'Owner of the OLAP Hierarchy Level'
/
comment on column ALL_CUBE_HIER_LEVELS.DIMENSION_NAME is
'Name of the owning Dimension of the OLAP Hierarchy Level'
/
comment on column ALL_CUBE_HIER_LEVELS.HIERARCHY_NAME is
'Name of the owning Hierarchy of the OLAP Hierarchy Level'
/
comment on column ALL_CUBE_HIER_LEVELS.LEVEL_NAME is
'Name of the OLAP Dimension Level'
/
comment on column ALL_CUBE_HIER_LEVELS.HIERARCHY_LEVEL_ID is
'Dictionary Id of the OLAP Hierarchy Level'
/
comment on column ALL_CUBE_HIER_LEVELS.ORDER_NUM is
'Order number of the OLAP Hierarchy Level within the hierarchy'
/
comment on column ALL_CUBE_HIER_LEVELS.DESCRIPTION is
'Long Description of the OLAP Hierarchy Level'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_HIER_LEVELS 
FOR SYS.ALL_CUBE_HIER_LEVELS
/
GRANT READ ON ALL_CUBE_HIER_LEVELS to public
/

create or replace view USER_CUBE_HIER_LEVELS
as
SELECT 
  o.name DIMENSION_NAME, 
  h.hierarchy_name HIERARCHY_NAME, 
  dl.level_name LEVEL_NAME, 
  hl.hierarchy_level_id HIERARCHY_LEVEL_ID,
  hl.order_num ORDER_NUM,  
  d.description_value DESCRIPTION
FROM 
  olap_hier_levels$ hl, 
  obj$ o, 
  olap_hierarchies$ h,
  olap_dim_levels$ dl, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 14 --HIER_LEVEL
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  hl.hierarchy_id=h.hierarchy_id AND o.owner#=USERENV('SCHEMAID')
  AND dl.level_id=hl.dim_level_id AND o.obj#=dl.dim_obj#
  AND d.owning_object_id(+)=hl.hierarchy_level_id
/

comment on table USER_CUBE_HIER_LEVELS is
'OLAP Hierarchy Levels owned by the user in the database'
/
comment on column USER_CUBE_HIER_LEVELS.DIMENSION_NAME is
'Name of the owning Dimension of the OLAP Hierarchy Level'
/
comment on column USER_CUBE_HIER_LEVELS.HIERARCHY_NAME is
'Name of the owning Hierarchy of the OLAP Hierarchy Level'
/
comment on column USER_CUBE_HIER_LEVELS.LEVEL_NAME is
'Name of the OLAP Dimension Level'
/
comment on column USER_CUBE_HIER_LEVELS.HIERARCHY_LEVEL_ID is
'Dictionary Id of the OLAP Hierarchy Level'
/
comment on column USER_CUBE_HIER_LEVELS.ORDER_NUM is
'Order number of the OLAP Hierarchy Level within the hierarchy'
/
comment on column USER_CUBE_HIER_LEVELS.DESCRIPTION is
'Long Description of the OLAP Hierarchy Level'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_HIER_LEVELS 
FOR SYS.USER_CUBE_HIER_LEVELS
/
GRANT READ ON USER_CUBE_HIER_LEVELS to public
/

-- OLAP_DIM_LEVELS$ DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_DIM_LEVELS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  dl.level_name LEVEL_NAME,
  dl.level_id LEVEL_ID,
  d.description_value DESCRIPTION
FROM 
  obj$ o, 
  olap_dim_levels$ dl, 
  user$ u, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 12 --DIM_LEVEL
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  o.obj#=dl.dim_obj# AND o.owner#=u.user#
  AND d.owning_object_id(+)=dl.level_id
/

comment on table DBA_CUBE_DIM_LEVELS is
'OLAP Dimension Levels in the database'
/
comment on column DBA_CUBE_DIM_LEVELS.OWNER is
'Owner of the OLAP Dimension Level'
/
comment on column DBA_CUBE_DIM_LEVELS.DIMENSION_NAME is
'Name of the dimension which owns the OLAP Dimension Level'
/
comment on column DBA_CUBE_DIM_LEVELS.LEVEL_NAME is
'Name of the OLAP Dimension Level'
/
comment on column DBA_CUBE_DIM_LEVELS.LEVEL_ID is
'Dictionary Id of the OLAP Dimension Level'
/
comment on column DBA_CUBE_DIM_LEVELS.DESCRIPTION is
'Long Description of the OLAP Dimension Level'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIM_LEVELS 
FOR SYS.DBA_CUBE_DIM_LEVELS
/
GRANT SELECT ON DBA_CUBE_DIM_LEVELS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_DIM_LEVELS','CDB_CUBE_DIM_LEVELS');
create or replace public synonym CDB_CUBE_DIM_LEVELS for sys.CDB_CUBE_DIM_LEVELS;
grant select on CDB_CUBE_DIM_LEVELS to select_catalog_role;

create or replace view ALL_CUBE_DIM_LEVELS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  dl.level_name LEVEL_NAME,
  dl.level_id LEVEL_ID,
  d.description_value DESCRIPTION
FROM 
  obj$ o, 
  olap_dim_levels$ dl, 
  user$ u, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 12 --DIM_LEVEL
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  o.obj#=dl.dim_obj# AND o.owner#=u.user#
  AND d.owning_object_id(+)=dl.level_id
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_CUBE_DIM_LEVELS is
'OLAP Dimension Levels in the database accessible by the user'
/
comment on column ALL_CUBE_DIM_LEVELS.OWNER is
'Owner of the OLAP Dimension Level'
/
comment on column ALL_CUBE_DIM_LEVELS.DIMENSION_NAME is
'Name of the dimension which owns the OLAP Dimension Level'
/
comment on column ALL_CUBE_DIM_LEVELS.LEVEL_NAME is
'Name of the OLAP Dimension Level'
/
comment on column ALL_CUBE_DIM_LEVELS.LEVEL_ID is
'Dictionary Id of the OLAP Dimension Level'
/
comment on column ALL_CUBE_DIM_LEVELS.DESCRIPTION is
'Long Description of the OLAP Dimension Level'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIM_LEVELS 
FOR SYS.ALL_CUBE_DIM_LEVELS
/
GRANT READ ON ALL_CUBE_DIM_LEVELS to public
/

create or replace view USER_CUBE_DIM_LEVELS
as
SELECT 
  o.name DIMENSION_NAME, 
  dl.level_name LEVEL_NAME, 
  dl.level_id LEVEL_ID,
  d.description_value DESCRIPTION
FROM 
  obj$ o, 
  olap_dim_levels$ dl, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 12 --DIM_LEVEL
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  o.obj#=dl.dim_obj# AND o.owner#=USERENV('SCHEMAID')
  AND d.owning_object_id(+)=dl.level_id
/

comment on table USER_CUBE_DIM_LEVELS is
'OLAP Dimension Levels owned by the user in the database'
/
comment on column USER_CUBE_DIM_LEVELS.DIMENSION_NAME is
'Name of the dimension which owns the OLAP Dimension Level'
/
comment on column USER_CUBE_DIM_LEVELS.LEVEL_NAME is
'Name of the OLAP Dimension Level'
/
comment on column USER_CUBE_DIM_LEVELS.LEVEL_ID is
'Dictionary Id of the OLAP Dimension Level'
/
comment on column USER_CUBE_DIM_LEVELS.DESCRIPTION is
'Long Description of the OLAP Dimension Level'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIM_LEVELS 
FOR SYS.USER_CUBE_DIM_LEVELS
/
GRANT READ ON USER_CUBE_DIM_LEVELS to public
/

-- OLAP_CUBE_ATTRIBUTES$ DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_ATTRIBUTES
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  a.attribute_name ATTRIBUTE_NAME, 
  a.attribute_id ATTRIBUTE_ID,
  tdo.name TARGET_DIMENSION_NAME,
  (CASE a.attribute_role_mask
     WHEN 1 THEN 'SHORT_DESCRIPTION'
     WHEN 2 THEN 'LONG_DESCRIPTION'
     WHEN 3 THEN 'DESCRIPTION'
     WHEN 4 THEN 'TIME_SPAN'
     WHEN 8 THEN 'END_DATE'
     WHEN 16 THEN 'START_DATE'
     ELSE null END) ATTRIBUTE_ROLE,
  d.description_value DESCRIPTION,
  i.option_value ATTRIBUTE_GROUP_NAME,
  DECODE(a.type#, 1, decode(a.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                  2, decode(a.scale, null,
                            decode(a.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                  8, 'LONG',
                  9, decode(a.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                  12, 'DATE',
                  23, 'RAW', 24, 'LONG RAW',
                  69, 'ROWID',
                  96, decode(a.charsetform, 2, 'NCHAR', 'CHAR'),
                  100, 'BINARY_FLOAT',
                  101, 'BINARY_DOUBLE',
                  105, 'MLSLABEL',
                  106, 'MLSLABEL',
                  112, decode(a.charsetform, 2, 'NCLOB', 'CLOB'),
                  113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                  178, 'TIME(' ||a.scale|| ')',
                  179, 'TIME(' ||a.scale|| ')' || ' WITH TIME ZONE',
                  180, 'TIMESTAMP(' ||a.scale|| ')',
                  181, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH TIME ZONE',
                  231, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH LOCAL TIME ZONE',
                  182, 'INTERVAL YEAR(' ||a.precision#||') TO MONTH',
                  183, 'INTERVAL DAY(' ||a.precision#||') TO SECOND(' ||
                        a.scale || ')',
                  208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  a.length DATA_LENGTH, 
  a.precision# DATA_PRECISION, 
  a.scale DATA_SCALE,
  DECODE(i2.option_num_value, 1, 'YES', NULL, 'NO') CREATE_INDEX,
  DECODE(i3.option_num_value, 1, 'YES', NULL, 'NO') IS_MULTI_LINGUAL
FROM
  olap_attributes$ a, 
  obj$ o, 
  obj$ tdo, 
  user$ u, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 15 --ATTRIBUTE
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ i,  -- For ATTRIBUTE_GROUP_NAME
  olap_impl_options$ i2, -- For CREATE_INDEX
  olap_impl_options$ i3  -- For IS_MULTI_LINGUAL
WHERE 
  o.obj#=a.dim_obj#
  AND o.owner#=u.user#
  AND a.target_dim#=tdo.obj#(+)
  AND a.attribute_id = d.owning_object_id(+)
  AND a.attribute_id = i.owning_objectid(+)
  AND i.object_type(+) = 15
  AND i.option_type(+) = 35
  AND a.attribute_id = i2.owning_objectid(+)
  AND i2.object_type(+) = 15 --ATTRIBUTE 
  AND i2.option_type(+) = 3  --CREATE_INDEX
  AND a.attribute_id = i3.owning_objectid(+)
  AND i3.object_type(+) = 15 --ATTRIBUTE
  AND i3.option_type(+) = 2  --IS_MULTI_LINGUAL
/

comment on table DBA_CUBE_ATTRIBUTES is
'OLAP Attributes in the database'
/
comment on column DBA_CUBE_ATTRIBUTES.OWNER is
'Owner of OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.DIMENSION_NAME is
'Name of owning Cube Dimension of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.ATTRIBUTE_NAME is
'Name of OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.ATTRIBUTE_ID is
'Dictionary Id of OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.TARGET_DIMENSION_NAME is
'Name of Target Dimension of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.ATTRIBUTE_ROLE is
'Special role this attribute plays (e.g. ShortDescription), or null if none'
/
comment on column DBA_CUBE_ATTRIBUTES.DESCRIPTION is
'Long Description of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.ATTRIBUTE_GROUP_NAME is
'Name of attribute group of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.DATA_TYPE is
'Data Type of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.DATA_LENGTH is
'Data Length of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.DATA_PRECISION is
'Data Precision of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.DATA_SCALE is
'Data Scale of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.CREATE_INDEX is
'Create_Index flag of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.IS_MULTI_LINGUAL is
'Is MultiLingual flag of the OLAP Attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_ATTRIBUTES
FOR SYS.DBA_CUBE_ATTRIBUTES
/
GRANT SELECT ON DBA_CUBE_ATTRIBUTES to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_ATTRIBUTES','CDB_CUBE_ATTRIBUTES');
create or replace public synonym CDB_CUBE_ATTRIBUTES for sys.CDB_CUBE_ATTRIBUTES;
grant select on CDB_CUBE_ATTRIBUTES to select_catalog_role;

create or replace view ALL_CUBE_ATTRIBUTES
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  a.attribute_name ATTRIBUTE_NAME, 
  a.attribute_id ATTRIBUTE_ID,
  tdo.name TARGET_DIMENSION_NAME,
  (CASE a.attribute_role_mask
     WHEN 1 THEN 'SHORT_DESCRIPTION'
     WHEN 2 THEN 'LONG_DESCRIPTION'
     WHEN 3 THEN 'DESCRIPTION'
     WHEN 4 THEN 'TIME_SPAN'
     WHEN 8 THEN 'END_DATE'
     WHEN 16 THEN 'START_DATE'
     ELSE null END) ATTRIBUTE_ROLE,
  d.description_value DESCRIPTION,
  i.option_value ATTRIBUTE_GROUP_NAME,
  DECODE(a.type#, 1, decode(a.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                  2, decode(a.scale, null,
                            decode(a.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                  8, 'LONG',
                  9, decode(a.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                  12, 'DATE',
                  23, 'RAW', 24, 'LONG RAW',
                  69, 'ROWID',
                  96, decode(a.charsetform, 2, 'NCHAR', 'CHAR'),
                  100, 'BINARY_FLOAT',
                  101, 'BINARY_DOUBLE',
                  105, 'MLSLABEL',
                  106, 'MLSLABEL',
                  112, decode(a.charsetform, 2, 'NCLOB', 'CLOB'),
                  113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                  178, 'TIME(' ||a.scale|| ')',
                  179, 'TIME(' ||a.scale|| ')' || ' WITH TIME ZONE',
                  180, 'TIMESTAMP(' ||a.scale|| ')',
                  181, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH TIME ZONE',
                  231, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH LOCAL TIME ZONE',
                  182, 'INTERVAL YEAR(' ||a.precision#||') TO MONTH',
                  183, 'INTERVAL DAY(' ||a.precision#||') TO SECOND(' ||
                        a.scale || ')',
                  208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  a.length DATA_LENGTH, 
  a.precision# DATA_PRECISION, 
  a.scale DATA_SCALE,
  DECODE(i2.option_num_value, 1, 'YES', NULL, 'NO') CREATE_INDEX,
  DECODE(i3.option_num_value, 1, 'YES', NULL, 'NO') IS_MULTI_LINGUAL
FROM 
  olap_attributes$ a, 
  obj$ o, 
  obj$ tdo, 
  user$ u, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 15 --ATTRIBUTE
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_syntax$ s,
  olap_impl_options$ i,  -- For ATTRIBUTE_GROUP_NAME
  olap_impl_options$ i2, -- For CREATE_INDEX
  olap_impl_options$ i3  -- For IS_MULTI_LINGUAL
WHERE 
  o.obj#=a.dim_obj#
  AND o.owner#=u.user#
  AND a.target_dim#=tdo.obj#(+)
  AND a.attribute_id=s.owner_id(+) 
  AND s.owner_type(+) = 15 --ATTRIBUTE 
  AND s.ref_role(+) = 2 --ATTRIBUTE_ROLE 
  AND a.attribute_id = d.owning_object_id(+)
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND a.attribute_id = i.owning_objectid(+)
  AND i.object_type(+) = 15
  AND i.option_type(+) = 35
  AND a.attribute_id = i2.owning_objectid(+)
  AND i2.object_type(+) = 15 --ATTRIBUTE 
  AND i2.option_type(+) = 3  --CREATE_INDEX
  AND a.attribute_id = i3.owning_objectid(+)
  AND i3.object_type(+) = 15 --ATTRIBUTE
  AND i3.option_type(+) = 2  --IS_MULTI_LINGUAL
/

comment on table ALL_CUBE_ATTRIBUTES is
'OLAP Attributes in the database accessible by the user'
/
comment on column ALL_CUBE_ATTRIBUTES.OWNER is
'Owner of OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.DIMENSION_NAME is
'Name of owning Cube Dimension of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.ATTRIBUTE_NAME is
'Name of OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.ATTRIBUTE_ID is
'Dictionary Id of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.TARGET_DIMENSION_NAME is
'Name of Target Dimension of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.ATTRIBUTE_ROLE is
'Special role this attribute plays (e.g. ShortDescription), or null if none'
/
comment on column ALL_CUBE_ATTRIBUTES.DESCRIPTION is
'Long Description of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.ATTRIBUTE_GROUP_NAME is
'Name of attribute group of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.DATA_TYPE is
'Data Type of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.DATA_LENGTH is
'Data Length of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.DATA_PRECISION is
'Data Precision of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.DATA_SCALE is
'Data Scale of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.CREATE_INDEX is
'Create Index flag of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.IS_MULTI_LINGUAL is
'Is MultiLingual flag of the OLAP Attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_ATTRIBUTES
FOR SYS.ALL_CUBE_ATTRIBUTES
/
GRANT READ ON ALL_CUBE_ATTRIBUTES to public
/

create or replace view USER_CUBE_ATTRIBUTES
as
SELECT 
  o.name DIMENSION_NAME, 
  a.attribute_name ATTRIBUTE_NAME, 
  a.attribute_id ATTRIBUTE_ID,
  tdo.name TARGET_DIMENSION_NAME,
  (CASE a.attribute_role_mask
     WHEN 1 THEN 'SHORT_DESCRIPTION'
     WHEN 2 THEN 'LONG_DESCRIPTION'
     WHEN 3 THEN 'DESCRIPTION'
     WHEN 4 THEN 'TIME_SPAN'
     WHEN 8 THEN 'END_DATE'
     WHEN 16 THEN 'START_DATE'
     ELSE null END) ATTRIBUTE_ROLE,
  d.description_value DESCRIPTION,
  i.option_value ATTRIBUTE_GROUP_NAME,
  DECODE(a.type#, 1, decode(a.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                  2, decode(a.scale, null,
                            decode(a.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                  8, 'LONG',
                  9, decode(a.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                  12, 'DATE',
                  23, 'RAW', 24, 'LONG RAW',
                  69, 'ROWID',
                  96, decode(a.charsetform, 2, 'NCHAR', 'CHAR'),
                  100, 'BINARY_FLOAT',
                  101, 'BINARY_DOUBLE',
                  105, 'MLSLABEL',
                  106, 'MLSLABEL',
                  112, decode(a.charsetform, 2, 'NCLOB', 'CLOB'),
                  113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                  178, 'TIME(' ||a.scale|| ')',
                  179, 'TIME(' ||a.scale|| ')' || ' WITH TIME ZONE',
                  180, 'TIMESTAMP(' ||a.scale|| ')',
                  181, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH TIME ZONE',
                  231, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH LOCAL TIME ZONE',
                  182, 'INTERVAL YEAR(' ||a.precision#||') TO MONTH',
                  183, 'INTERVAL DAY(' ||a.precision#||') TO SECOND(' ||
                        a.scale || ')',
                  208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  a.length DATA_LENGTH, 
  a.precision# DATA_PRECISION, 
  a.scale DATA_SCALE,
  DECODE(i2.option_num_value, 1, 'YES', NULL, 'NO') CREATE_INDEX,
  DECODE(i3.option_num_value, 1, 'YES', NULL, 'NO') IS_MULTI_LINGUAL
FROM 
  olap_attributes$ a, 
  obj$ o, 
  obj$ tdo, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 15 --ATTRIBUTE
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_syntax$ s,
  olap_impl_options$ i,  -- For ATTRIBUTE_GROUP_NAME
  olap_impl_options$ i2, -- For CREATE_INDEX
  olap_impl_options$ i3  -- For IS_MULTI_LINGUAL
WHERE 
  o.obj#=a.dim_obj#
  AND o.owner#=USERENV('SCHEMAID')
  AND a.target_dim#=tdo.obj#(+)
  AND a.attribute_id=s.owner_id(+) 
  AND s.owner_type(+) = 15 --ATTRIBUTE 
  AND s.ref_role(+) = 2 --ATTRIBUTE_ROLE 
  AND a.attribute_id = d.owning_object_id(+)
  AND a.attribute_id = i.owning_objectid(+)
  AND i.object_type(+) = 15  --ATTRIBUTE 
  AND i.option_type(+) = 35  --ATTRIBUTE_GROUP_NAME
  AND a.attribute_id = i2.owning_objectid(+)
  AND i2.object_type(+) = 15 --ATTRIBUTE 
  AND i2.option_type(+) = 3  --CREATE_INDEX
  AND a.attribute_id = i3.owning_objectid(+)
  AND i3.object_type(+) = 15 --ATTRIBUTE
  AND i3.option_type(+) = 2  --IS_MULTI_LINGUAL
/

comment on table USER_CUBE_ATTRIBUTES is
'OLAP Attributes owned by the user in the database'
/
comment on column USER_CUBE_ATTRIBUTES.DIMENSION_NAME is
'Name of owning Cube Dimension of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.ATTRIBUTE_NAME is
'Name of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.ATTRIBUTE_ID is
'Dictionary Id of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.TARGET_DIMENSION_NAME is
'Name of Target Dimension of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.ATTRIBUTE_ROLE is
'Special role this attribute plays (e.g. ShortDescription), or null if none'
/
comment on column USER_CUBE_ATTRIBUTES.DESCRIPTION is
'Long Description of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.ATTRIBUTE_GROUP_NAME is
'Name of attribute group of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.DATA_TYPE is
'Data Type of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.DATA_LENGTH is
'Data Length of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.DATA_PRECISION is
'Data Precision of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.DATA_SCALE is
'Data Scale of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.CREATE_INDEX is
'Create Index flag of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.IS_MULTI_LINGUAL is
'Is MultiLingual flag of the OLAP Attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_ATTRIBUTES
FOR SYS.USER_CUBE_ATTRIBUTES
/
GRANT READ ON USER_CUBE_ATTRIBUTES to public
/

-- xxx_CUBE_ATTR_VISIBILITY --

create or replace view DBA_CUBE_ATTR_VISIBILITY
AS
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  null LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'DIMENSION' TO_TYPE
FROM
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'HIERARCHY' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'DIM_LEVEL' TO_TYPE
FROM
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND dl.dim_obj# = o.obj#
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND h.dim_obj# = o.obj#
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,
  'HIERARCHY' FROM_TYPE,
  'HIERARCHY' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 13 -- HIERARCHY
  AND av.owning_dim_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'HIERARCHY' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 13 -- HIERARCHY
  AND av.owning_dim_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'HIER_LEVEL' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 14 -- HIER_LEVEL
  AND av.owning_dim_id = hl.hierarchy_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIM_LEVEL' FROM_TYPE,
  'DIM_LEVEL' TO_TYPE
FROM
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 12 -- DIM_LEVEL
  AND av.owning_dim_id = dl.level_id
  AND dl.dim_obj# = o.obj#
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIM_LEVEL' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 12 -- DIM_LEVEL
  AND av.owning_dim_id = dl.level_id
  AND dl.level_id = hl.dim_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
/

comment on table DBA_CUBE_ATTR_VISIBILITY is
'OLAP Attributes visible for Dimensions, Hierarchies, and Levels'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.OWNER is
'Owner of OLAP Attribute'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.DIMENSION_NAME is
'Name of the OLAP Cube Dimension that owns the OLAP Attribute'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.ATTRIBUTE_NAME is
'Name of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.HIERARCHY_NAME is
'Name of the OLAP Hierarchy for which the Attribute is visible'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.LEVEL_NAME is
'Name of the OLAP Level for which the Attribute is visible'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.FROM_TYPE is
'Object type on which the visibility has been explicitly set'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.TO_TYPE is
'Object type on which the visibility has been implicitly derived'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_ATTR_VISIBILITY
FOR SYS.DBA_CUBE_ATTR_VISIBILITY
/
GRANT SELECT ON DBA_CUBE_ATTR_VISIBILITY to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_ATTR_VISIBILITY','CDB_CUBE_ATTR_VISIBILITY');
create or replace public synonym CDB_CUBE_ATTR_VISIBILITY for sys.CDB_CUBE_ATTR_VISIBILITY;
grant select on CDB_CUBE_ATTR_VISIBILITY to select_catalog_role;


create or replace view ALL_CUBE_ATTR_VISIBILITY
AS
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  null LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'DIMENSION' TO_TYPE
FROM
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'HIERARCHY' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'DIM_LEVEL' TO_TYPE
FROM
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND dl.dim_obj# = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND h.dim_obj# = o.obj#
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,
  'HIERARCHY' FROM_TYPE,
  'HIERARCHY' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 13 -- HIERARCHY
  AND av.owning_dim_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'HIERARCHY' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 13 -- HIERARCHY
  AND av.owning_dim_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'HIER_LEVEL' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 14 -- HIER_LEVEL
  AND av.owning_dim_id = hl.hierarchy_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIM_LEVEL' FROM_TYPE,
  'DIM_LEVEL' TO_TYPE
FROM
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 12 -- DIM_LEVEL
  AND av.owning_dim_id = dl.level_id
  AND dl.dim_obj# = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIM_LEVEL' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 12 -- DIM_LEVEL
  AND av.owning_dim_id = dl.level_id
  AND dl.level_id = hl.dim_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/
comment on table ALL_CUBE_ATTR_VISIBILITY is
'OLAP Attributes visible for Dimensions, Hierarchies, and Levels'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.OWNER is
'Owner of OLAP Attribute'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.DIMENSION_NAME is
'Name of the OLAP Cube Dimension that owns the OLAP Attribute'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.ATTRIBUTE_NAME is
'Name of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.HIERARCHY_NAME is
'Name of the OLAP Hierarchy for which the Attribute is visible'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.LEVEL_NAME is
'Name of the OLAP Level for which the Attribute is visible'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.FROM_TYPE is
'Object type on which the visibility has been explicitly set'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.TO_TYPE is
'Object type on which the visibility has been implicitly derived'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_ATTR_VISIBILITY
FOR SYS.ALL_CUBE_ATTR_VISIBILITY
/
GRANT READ ON ALL_CUBE_ATTR_VISIBILITY to public
/


create or replace view USER_CUBE_ATTR_VISIBILITY
AS
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  null LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'DIMENSION' TO_TYPE
FROM
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'HIERARCHY' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND h.dim_obj# = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'DIM_LEVEL' TO_TYPE
FROM
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND dl.dim_obj# = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND h.dim_obj# = o.obj#
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,
  'HIERARCHY' FROM_TYPE,
  'HIERARCHY' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 13 -- HIERARCHY
  AND av.owning_dim_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'HIERARCHY' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 13 -- HIERARCHY
  AND av.owning_dim_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'HIER_LEVEL' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 14 -- HIER_LEVEL
  AND av.owning_dim_id = hl.hierarchy_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIM_LEVEL' FROM_TYPE,
  'DIM_LEVEL' TO_TYPE
FROM
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 12 -- DIM_LEVEL
  AND av.owning_dim_id = dl.level_id
  AND dl.dim_obj# = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIM_LEVEL' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 12 -- DIM_LEVEL
  AND av.owning_dim_id = dl.level_id
  AND dl.level_id = hl.dim_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
/
comment on table USER_CUBE_ATTR_VISIBILITY is
'OLAP Attributes visible for Dimensions, Hierarchies, and Levels'
/
comment on column USER_CUBE_ATTR_VISIBILITY.DIMENSION_NAME is
'Name of the OLAP Cube Dimension that owns the OLAP Attribute'
/
comment on column USER_CUBE_ATTR_VISIBILITY.ATTRIBUTE_NAME is
'Name of the OLAP Attribute'
/
comment on column USER_CUBE_ATTR_VISIBILITY.HIERARCHY_NAME is
'Name of the OLAP Hierarchy for which the Attribute is visible'
/
comment on column USER_CUBE_ATTR_VISIBILITY.LEVEL_NAME is
'Name of the OLAP Level for which the Attribute is visible'
/
comment on column USER_CUBE_ATTR_VISIBILITY.FROM_TYPE is
'Object type on which the visibility has been explicitly set'
/
comment on column USER_CUBE_ATTR_VISIBILITY.TO_TYPE is
'Object type on which the visibility has been implicitly derived'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_ATTR_VISIBILITY
FOR SYS.USER_CUBE_ATTR_VISIBILITY
/
GRANT READ ON USER_CUBE_ATTR_VISIBILITY to public
/


-- OLAP_MODELS$ DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_DIM_MODELS
AS
SELECT 
  du.name OWNER, 
  do.name DIMENSION_NAME,
  m.model_name MODEL_NAME,
  m.model_id MODEL_ID,
  d.description_value DESCRIPTION
FROM
  olap_models$ m, 
  obj$ do,
  user$ du, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 16 --MODEL
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
  m.owning_obj_type = 11 --DIMENSION
  AND m.owning_obj_id = do.obj#
  AND do.owner# = du.user# 
  AND m.model_id = d.owning_object_id(+)
/

comment on table DBA_CUBE_DIM_MODELS is
'OLAP Dimension Models in the database'
/
comment on column DBA_CUBE_DIM_MODELS.OWNER is
'Owner of OLAP Dimension Model'
/
comment on column DBA_CUBE_DIM_MODELS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension Model'
/
comment on column DBA_CUBE_DIM_MODELS.MODEL_NAME is
'Name of the OLAP Dimension Model'
/
comment on column DBA_CUBE_DIM_MODELS.MODEL_ID is
'Dictionary Id of the OLAP Dimension Model'
/
comment on column DBA_CUBE_DIM_MODELS.DESCRIPTION is
'Long Description of the OLAP Dimension Model'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIM_MODELS 
FOR SYS.DBA_CUBE_DIM_MODELS
/
GRANT SELECT ON DBA_CUBE_DIM_MODELS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_DIM_MODELS','CDB_CUBE_DIM_MODELS');
create or replace public synonym CDB_CUBE_DIM_MODELS for sys.CDB_CUBE_DIM_MODELS;
grant select on CDB_CUBE_DIM_MODELS to select_catalog_role;

create or replace view ALL_CUBE_DIM_MODELS
AS
SELECT 
  du.name OWNER, 
  do.name DIMENSION_NAME,
  m.model_name MODEL_NAME,
  m.model_id MODEL_ID,
  d.description_value DESCRIPTION
FROM
  olap_models$ m, 
  obj$ do,
  user$ du, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 16 --MODEL
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
  m.owning_obj_type = 11 --DIMENSION
  AND m.owning_obj_id = do.obj#
  AND do.owner# = du.user# 
  AND m.model_id = d.owning_object_id(+)
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (do.owner#, do.type#) = 1
            )
/

comment on table ALL_CUBE_DIM_MODELS is
'OLAP Dimension Models in the database accessible to the user'
/
comment on column ALL_CUBE_DIM_MODELS.OWNER is
'Owner of OLAP Dimension Model'
/
comment on column ALL_CUBE_DIM_MODELS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension Model'
/
comment on column ALL_CUBE_DIM_MODELS.MODEL_NAME is
'Name of the OLAP Dimension Model'
/
comment on column ALL_CUBE_DIM_MODELS.MODEL_ID is
'Dictionary Id of the OLAP Dimension Model'
/
comment on column ALL_CUBE_DIM_MODELS.DESCRIPTION is
'Long Description of the OLAP Dimension Model'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIM_MODELS 
FOR SYS.ALL_CUBE_DIM_MODELS
/
GRANT READ ON ALL_CUBE_DIM_MODELS to public
/

create or replace view USER_CUBE_DIM_MODELS
AS
SELECT 
  do.name DIMENSION_NAME,
  m.model_name MODEL_NAME,
  m.model_id MODEL_ID,
  d.description_value DESCRIPTION
FROM
  olap_models$ m, 
  obj$ do,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 16 --MODEL
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
  m.owning_obj_type = 11 --DIMENSION
  AND m.owning_obj_id = do.obj#
  AND do.owner# = USERENV('SCHEMAID')
  AND m.model_id = d.owning_object_id(+)
/

comment on table USER_CUBE_DIM_MODELS is
'OLAP Dimension Models in the database accessible to the user'
/
comment on column USER_CUBE_DIM_MODELS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension Model'
/
comment on column USER_CUBE_DIM_MODELS.MODEL_NAME is
'Name of the OLAP Dimension Model'
/
comment on column USER_CUBE_DIM_MODELS.MODEL_ID is
'Dictionary Id of the OLAP Dimension Model'
/
comment on column USER_CUBE_DIM_MODELS.DESCRIPTION is
'Long Description of the OLAP Dimension Model'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIM_MODELS 
FOR SYS.USER_CUBE_DIM_MODELS
/
GRANT READ ON USER_CUBE_DIM_MODELS to public
/

-- OLAP_CUBE_CALCULATED_MEMBERS$ DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_CALCULATED_MEMBERS
as
SELECT 
  u.name OWNER,
  o.name DIMENSION_NAME,
  cm.member_name MEMBER_NAME, 
  DECODE(cm.is_customaggregate, 1, 'YES', 0, 'NO') IS_CUSTOM_AGGREGATE,
  DECODE(cm.storage_type, 1, 'DYNAMIC', 2, 'PRECOMPUTE') STORAGE_TYPE,
  syn.syntax_clob EXPRESSION
FROM 
  olap_calculated_members$ cm, 
  obj$ o, 
  user$ u,
  olap_syntax$ syn
WHERE 
  cm.dim_obj#=o.obj# 
  AND o.owner#=u.user#
  AND cm.member_id = syn.owner_id(+)
  AND syn.owner_type = 6 --CALC_MEMBER 
  AND syn.ref_role=19 -- MEMBER_EXPRESSION_ROLE 
/

comment on table DBA_CUBE_CALCULATED_MEMBERS is
'OLAP Calculated Members in the database'
/
comment on column DBA_CUBE_CALCULATED_MEMBERS.OWNER is
'Owner of the OLAP Calculated Member'
/
comment on column DBA_CUBE_CALCULATED_MEMBERS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Calculated Member'
/
comment on column DBA_CUBE_CALCULATED_MEMBERS.MEMBER_NAME is
'Member Name of the OLAP Calculated Member'
/
comment on column DBA_CUBE_CALCULATED_MEMBERS.IS_CUSTOM_AGGREGATE is
'Custom Aggregate flag of the OLAP Calculated Member'
/
comment on column DBA_CUBE_CALCULATED_MEMBERS.STORAGE_TYPE is
'Storage Type of the OLAP Calculated Member'
/
comment on column DBA_CUBE_CALCULATED_MEMBERS.EXPRESSION is
'Expression of the OLAP Calculated Member'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_CALCULATED_MEMBERS
FOR SYS.DBA_CUBE_CALCULATED_MEMBERS
/
GRANT SELECT ON DBA_CUBE_CALCULATED_MEMBERS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_CALCULATED_MEMBERS','CDB_CUBE_CALCULATED_MEMBERS');
create or replace public synonym CDB_CUBE_CALCULATED_MEMBERS for sys.CDB_CUBE_CALCULATED_MEMBERS;
grant select on CDB_CUBE_CALCULATED_MEMBERS to select_catalog_role;

create or replace view ALL_CUBE_CALCULATED_MEMBERS
as
SELECT 
  u.name OWNER,
  o.name DIMENSION_NAME,
  cm.member_name MEMBER_NAME, 
  DECODE(cm.is_customaggregate, 1, 'YES', 0, 'NO') IS_CUSTOM_AGGREGATE,
  DECODE(cm.storage_type, 1, 'DYNAMIC', 2, 'PRECOMPUTE') STORAGE_TYPE,
  syn.syntax_clob EXPRESSION
FROM 
  olap_calculated_members$ cm, 
  obj$ o, 
  user$ u,
  olap_syntax$ syn
WHERE 
  cm.dim_obj#=o.obj# 
  AND o.owner#=u.user#
  AND cm.member_id = syn.owner_id(+)
  AND syn.owner_type = 6 --CALC_MEMBER 
  AND syn.ref_role=19 -- MEMBER_EXPRESSION_ROLE 
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_CUBE_CALCULATED_MEMBERS is
'OLAP Calculated Members in the database accessible to the user'
/
comment on column ALL_CUBE_CALCULATED_MEMBERS.OWNER is
'Owner of the OLAP Calculated Member'
/
comment on column ALL_CUBE_CALCULATED_MEMBERS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Calculated Member'
/
comment on column ALL_CUBE_CALCULATED_MEMBERS.MEMBER_NAME is
'Member Name of the OLAP Calculated Member'
/
comment on column ALL_CUBE_CALCULATED_MEMBERS.IS_CUSTOM_AGGREGATE is
'Custom Aggregate flag of the OLAP Calculated Member'
/
comment on column ALL_CUBE_CALCULATED_MEMBERS.STORAGE_TYPE is
'Storage Type of the OLAP Calculated Member'
/
comment on column ALL_CUBE_CALCULATED_MEMBERS.EXPRESSION is
'Expression of the OLAP Calculated Member'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_CALCULATED_MEMBERS
FOR SYS.ALL_CUBE_CALCULATED_MEMBERS
/
GRANT READ ON ALL_CUBE_CALCULATED_MEMBERS to public
/

create or replace view USER_CUBE_CALCULATED_MEMBERS
as
SELECT 
  o.name DIMENSION_NAME,
  cm.member_name MEMBER_NAME, 
  DECODE(cm.is_customaggregate, 1, 'YES', 0, 'NO') IS_CUSTOM_AGGREGATE,
  DECODE(cm.storage_type, 1, 'DYNAMIC', 2, 'PRECOMPUTE') STORAGE_TYPE,
  syn.syntax_clob EXPRESSION
FROM 
  olap_calculated_members$ cm, 
  obj$ o, 
  olap_syntax$ syn
WHERE 
  cm.dim_obj#=o.obj# 
  AND o.owner#=USERENV('SCHEMAID')
  AND cm.member_id = syn.owner_id(+)
  AND syn.owner_type = 6 --CALC_MEMBER 
  AND syn.ref_role=19 -- MEMBER_EXPRESSION_ROLE 
/

comment on table USER_CUBE_CALCULATED_MEMBERS is
'OLAP Calculated Members in the database accessible to the user'
/
comment on column USER_CUBE_CALCULATED_MEMBERS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Calculated Member'
/
comment on column USER_CUBE_CALCULATED_MEMBERS.MEMBER_NAME is
'Member Name of the OLAP Calculated Member'
/
comment on column USER_CUBE_CALCULATED_MEMBERS.IS_CUSTOM_AGGREGATE is
'Custom Aggregate flag of the OLAP Calculated Member'
/
comment on column USER_CUBE_CALCULATED_MEMBERS.STORAGE_TYPE is
'Storage Type of the OLAP Calculated Member'
/
comment on column USER_CUBE_CALCULATED_MEMBERS.EXPRESSION is
'Expression of the OLAP Calculated Member'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_CALCULATED_MEMBERS
FOR SYS.USER_CUBE_CALCULATED_MEMBERS
/
GRANT READ ON USER_CUBE_CALCULATED_MEMBERS to public
/

-- OLAP_AW_VIEWS$ DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_VIEWS
as
SELECT
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  obj$ co,
  user$ cu,
  obj$ vo
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id=co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner#=cu.user#
  AND av.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=cu.user#      
/

comment on table DBA_CUBE_VIEWS is
'OLAP Cube Views in the database'
/
comment on column DBA_CUBE_VIEWS.OWNER is
'Owner of the OLAP Cube View'
/
comment on column DBA_CUBE_VIEWS.CUBE_NAME is
'Name of owning cube of the OLAP Cube View'
/
comment on column DBA_CUBE_VIEWS.VIEW_NAME is
'View Name of the OLAP Cube View'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_VIEWS
FOR SYS.DBA_CUBE_VIEWS
/
GRANT SELECT ON DBA_CUBE_VIEWS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_VIEWS','CDB_CUBE_VIEWS');
create or replace public synonym CDB_CUBE_VIEWS for sys.CDB_CUBE_VIEWS;
grant select on CDB_CUBE_VIEWS to select_catalog_role;

create or replace view ALL_CUBE_VIEWS
as
SELECT
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  obj$ co,
  user$ cu,
  obj$ vo,
 (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id=co.obj#
  AND co.obj#=da.obj#(+)
  AND av.view_type = 1 -- ET 
  AND co.owner#=cu.user#
  AND av.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=cu.user#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privilages 
              ora_check_SYS_privilege (co.owner#, co.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
/

comment on table ALL_CUBE_VIEWS is
'OLAP Cube Views in the database accessible by the user'
/
comment on column ALL_CUBE_VIEWS.OWNER is
'Owner of the OLAP Cube View'
/
comment on column ALL_CUBE_VIEWS.CUBE_NAME is
'Name of owning cube of the OLAP Cube View'
/
comment on column ALL_CUBE_VIEWS.VIEW_NAME is
'View Name of the OLAP Cube View'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_VIEWS
FOR SYS.ALL_CUBE_VIEWS
/
GRANT READ ON ALL_CUBE_VIEWS to public
/

create or replace view USER_CUBE_VIEWS
as
SELECT
  co.name CUBE_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  obj$ co,
  obj$ vo
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id=co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner#=USERENV('SCHEMAID')
  AND av.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#      
/

comment on table USER_CUBE_VIEWS is
'OLAP Cube Views owned by the user in the database'
/
comment on column USER_CUBE_VIEWS.CUBE_NAME is
'Name of owning cube of the OLAP Cube View'
/
comment on column USER_CUBE_VIEWS.VIEW_NAME is
'View Name of the OLAP Cube View'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_VIEWS
FOR SYS.USER_CUBE_VIEWS
/
GRANT READ ON USER_CUBE_VIEWS to public
/

create or replace view DBA_CUBE_VIEW_COLUMNS
as
SELECT 
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'MEASURE' COLUMN_TYPE,
  m.measure_name OBJECT_NAME -- name of measure  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_measures$ m,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 2 -- MEASURE 
  AND avc.referenced_object_id = m.measure_id
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by dimension 
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 11 -- DIMENSION 
  AND d.dimension_id = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by dimension level 
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_dim_levels$ dl
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 12 -- DIM_LEVEL 
  AND d.dimension_id = dl.level_id
  AND dl.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by hierarchy 
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_hierarchies$ h
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 13 -- HIERARCHY 
  AND d.dimension_id = h.hierarchy_id
  AND h.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by hierarchy level 
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_hierarchies$ h,
  olap_hier_levels$ hl
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 14 -- HIER_LEVEL 
  AND d.dimension_id = hl.hierarchy_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
/

comment on table DBA_CUBE_VIEW_COLUMNS is
'OLAP Cube View Columns in the database'
/
comment on column DBA_CUBE_VIEW_COLUMNS.OWNER is
'Owner of the OLAP Cube View Column'
/
comment on column DBA_CUBE_VIEW_COLUMNS.CUBE_NAME is
'Name of owning cube of the OLAP Cube View Column'
/
comment on column DBA_CUBE_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Cube View Column'
/
comment on column DBA_CUBE_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Cube View Column'
/
comment on column DBA_CUBE_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Cube View Column'
/
comment on column DBA_CUBE_VIEW_COLUMNS.OBJECT_NAME is
'Name of Measure of the OLAP Cube View Column'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_VIEW_COLUMNS
FOR SYS.DBA_CUBE_VIEW_COLUMNS
/
GRANT SELECT ON DBA_CUBE_VIEW_COLUMNS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_VIEW_COLUMNS','CDB_CUBE_VIEW_COLUMNS');
create or replace public synonym CDB_CUBE_VIEW_COLUMNS for sys.CDB_CUBE_VIEW_COLUMNS;
grant select on CDB_CUBE_VIEW_COLUMNS to select_catalog_role;

create or replace view ALL_CUBE_VIEW_COLUMNS
as
SELECT OWNER, CUBE_NAME, VIEW_NAME, COLUMN_NAME, COLUMN_TYPE, OBJECT_NAME
FROM
(SELECT 
  co.obj# obj#,
  co.owner# owner#,
  co.type# type#,
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'MEASURE' COLUMN_TYPE,
  m.measure_name OBJECT_NAME -- name of measure  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_measures$ m,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 2 -- MEASURE 
  AND avc.referenced_object_id = m.measure_id
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privilages 
              ora_check_SYS_privilege (co.owner#, co.type#) = 1
            )
UNION ALL
SELECT -- dimensioned by dimension 
  co.obj# obj#,
  co.owner# owner#,
  co.type# type#,
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 11 -- DIMENSION 
  AND d.dimension_id = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privilages 
              ora_check_SYS_privilege (co.owner#, co.type#) = 1
            )
UNION ALL
SELECT -- dimensioned by dimension level 
  co.obj# obj#,
  co.owner# owner#,
  co.type# type#,
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_dim_levels$ dl
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 12 -- DIM_LEVEL 
  AND d.dimension_id = dl.level_id
  AND dl.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privilages 
              ora_check_SYS_privilege (co.owner#, co.type#) = 1
            )
UNION ALL
SELECT -- dimensioned by hierarchy 
  co.obj# obj#,
  co.owner# owner#,
  co.type# type#,
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_hierarchies$ h
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 13 -- HIERARCHY 
  AND d.dimension_id = h.hierarchy_id
  AND h.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privilages 
              ora_check_SYS_privilege (co.owner#, co.type#) = 1
            )
UNION ALL
SELECT -- dimensioned by hierarchy level 
  co.obj# obj#,
  co.owner# owner#,
  co.type# type#,
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_hierarchies$ h,
  olap_hier_levels$ hl
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 14 -- HIER_LEVEL 
  AND d.dimension_id = hl.hierarchy_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privilages 
              ora_check_SYS_privilege (co.owner#, co.type#) = 1
            )
) u,
 (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE u.obj#=da.obj#(+)
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL)
         or   -- user has system privileges
                ora_check_SYS_privilege (owner#, type#) = 1
  )

/

comment on table ALL_CUBE_VIEW_COLUMNS is
'OLAP Cube View Columns in the database accessible by the user'
/
comment on column ALL_CUBE_VIEW_COLUMNS.OWNER is
'Owner of the OLAP Cube View Column'
/
comment on column ALL_CUBE_VIEW_COLUMNS.CUBE_NAME is
'Name of owning cube of the OLAP Cube View Column'
/
comment on column ALL_CUBE_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Cube View Column'
/
comment on column ALL_CUBE_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Cube View Column'
/
comment on column ALL_CUBE_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Cube View Column'
/
comment on column ALL_CUBE_VIEW_COLUMNS.OBJECT_NAME is
'Name of Measure of the OLAP Cube View Column'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_VIEW_COLUMNS
FOR SYS.ALL_CUBE_VIEW_COLUMNS
/
GRANT READ ON ALL_CUBE_VIEW_COLUMNS to public
/

create or replace view USER_CUBE_VIEW_COLUMNS
as
SELECT 
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'MEASURE' COLUMN_TYPE,
  m.measure_name OBJECT_NAME -- name of measure  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_measures$ m,
  col$ col,
  obj$ co,
  obj$ vo
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = USERENV('SCHEMAID')
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 2 -- MEASURE 
  AND avc.referenced_object_id = m.measure_id
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by dimension 
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = USERENV('SCHEMAID')
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 11 -- DIMENSION 
  AND d.dimension_id = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by dimension level 
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_dim_levels$ dl
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = USERENV('SCHEMAID')
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 12 -- DIM_LEVEL 
  AND d.dimension_id = dl.level_id
  AND dl.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by hierarchy 
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_hierarchies$ h
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = USERENV('SCHEMAID')
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 13 -- HIERARCHY 
  AND d.dimension_id = h.hierarchy_id
  AND h.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by hierarchy level 
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_hierarchies$ h,
  olap_hier_levels$ hl
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = USERENV('SCHEMAID')
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 14 -- HIER_LEVEL 
  AND d.dimension_id = hl.hierarchy_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
/

comment on table USER_CUBE_VIEW_COLUMNS is
'OLAP Cube View Columns owned by the user in the database'
/
comment on column USER_CUBE_VIEW_COLUMNS.CUBE_NAME is
'Name of owning cube of the OLAP Cube View Column'
/
comment on column USER_CUBE_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Cube View Column'
/
comment on column USER_CUBE_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Cube View Column'
/
comment on column USER_CUBE_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Cube View Column'
/
comment on column USER_CUBE_VIEW_COLUMNS.OBJECT_NAME is
'Name of Measure of the OLAP Cube View Column'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_VIEW_COLUMNS
FOR SYS.USER_CUBE_VIEW_COLUMNS
/
GRANT READ ON USER_CUBE_VIEW_COLUMNS to public
/

create or replace view DBA_CUBE_DIM_VIEWS
as
SELECT
  du.name OWNER,
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  obj$ do,
  user$ du,
  obj$ vo
WHERE
  av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id=do.obj#
  AND av.view_type = 1 -- ET 
  AND do.owner#=du.user#
  AND av.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
/

comment on table DBA_CUBE_DIM_VIEWS is
'OLAP Dimension Views in the database'
/
comment on column DBA_CUBE_DIM_VIEWS.OWNER is
'Owner of the OLAP Dimension View'
/
comment on column DBA_CUBE_DIM_VIEWS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension View'
/
comment on column DBA_CUBE_DIM_VIEWS.VIEW_NAME is
'View Name of the OLAP Dimension View'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIM_VIEWS
FOR SYS.DBA_CUBE_DIM_VIEWS
/
GRANT SELECT ON DBA_CUBE_DIM_VIEWS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_DIM_VIEWS','CDB_CUBE_DIM_VIEWS');
create or replace public synonym CDB_CUBE_DIM_VIEWS for sys.CDB_CUBE_DIM_VIEWS;
grant select on CDB_CUBE_DIM_VIEWS to select_catalog_role;

create or replace view ALL_CUBE_DIM_VIEWS
as
SELECT
  du.name OWNER,
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  obj$ do,
  user$ du,
  obj$ vo
WHERE
  av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id=do.obj#
  AND av.view_type = 1 -- ET 
  AND do.owner#=du.user#
  AND av.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (do.owner#, do.type#) = 1
            )
/

comment on table ALL_CUBE_DIM_VIEWS is
'OLAP Dimension Views in the database accessible by the user'
/
comment on column ALL_CUBE_DIM_VIEWS.OWNER is
'Owner of the OLAP Dimension View'
/
comment on column ALL_CUBE_DIM_VIEWS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension View'
/
comment on column ALL_CUBE_DIM_VIEWS.VIEW_NAME is
'View Name of the OLAP Dimension View'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIM_VIEWS
FOR SYS.ALL_CUBE_DIM_VIEWS
/
GRANT READ ON ALL_CUBE_DIM_VIEWS to public
/

create or replace view USER_CUBE_DIM_VIEWS
as
SELECT
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  obj$ do,
  obj$ vo
WHERE
  av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id=do.obj#
  AND av.view_type = 1 -- ET 
  AND do.owner#=USERENV('SCHEMAID')
  AND av.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
/

comment on table USER_CUBE_DIM_VIEWS is
'OLAP Dimension Views owned by the user in the database'
/
comment on column USER_CUBE_DIM_VIEWS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension View'
/
comment on column USER_CUBE_DIM_VIEWS.VIEW_NAME is
'View Name of the OLAP Dimension View'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIM_VIEWS
FOR SYS.USER_CUBE_DIM_VIEWS
/
GRANT READ ON USER_CUBE_DIM_VIEWS to public
/

create or replace view DBA_CUBE_DIM_VIEW_COLUMNS
as
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  DECODE(avc.column_type, 2, 'KEY',
                          4, 'LEVEL_NAME',
                          7, 'DIM_ORDER',
                          9, 'MEMBER_TYPE') COLUMN_TYPE,
  NULL OBJECT_NAME -- no object name for these column types  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ do,
  user$ du,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id = do.obj#
  AND av.view_type = 1 -- ET 
  AND avc.column_type IN (2, 4, 6, 7, 9)
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND do.owner# = du.user#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
UNION ALL
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'ATTRIBUTE' COLUMN_TYPE,
  a.attribute_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_attributes$ a,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id = do.obj#
  AND av.view_type = 1 -- ET 
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 15 --ATTRIBUTE
  AND avc.referenced_object_id = a.attribute_id
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND a.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
/

comment on table DBA_CUBE_DIM_VIEW_COLUMNS is
'OLAP Dimension View Columns in the database'
/
comment on column DBA_CUBE_DIM_VIEW_COLUMNS.OWNER is
'Owner of the OLAP Dimension View Column'
/
comment on column DBA_CUBE_DIM_VIEW_COLUMNS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension View Column'
/
comment on column DBA_CUBE_DIM_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Dimension View Column'
/
comment on column DBA_CUBE_DIM_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Dimension View Column'
/
comment on column DBA_CUBE_DIM_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Dimension View Column'
/
comment on column DBA_CUBE_DIM_VIEW_COLUMNS.OBJECT_NAME is
'No object names for OLAP Dimension View Columns'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIM_VIEW_COLUMNS
FOR SYS.DBA_CUBE_DIM_VIEW_COLUMNS
/
GRANT SELECT ON DBA_CUBE_DIM_VIEW_COLUMNS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_DIM_VIEW_COLUMNS','CDB_CUBE_DIM_VIEW_COLUMNS');
create or replace public synonym CDB_CUBE_DIM_VIEW_COLUMNS for sys.CDB_CUBE_DIM_VIEW_COLUMNS;
grant select on CDB_CUBE_DIM_VIEW_COLUMNS to select_catalog_role;

create or replace view ALL_CUBE_DIM_VIEW_COLUMNS
as
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  DECODE(avc.column_type, 2, 'KEY',
                          4, 'LEVEL_NAME',
                          7, 'DIM_ORDER',
                          9, 'MEMBER_TYPE') COLUMN_TYPE,
  NULL OBJECT_NAME -- no object name for these column types  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ do,
  user$ du,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id = do.obj#
  AND av.view_type = 1 -- ET 
  AND avc.column_type IN (2, 4, 6, 7, 9)
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND do.owner# = du.user#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#   
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (do.owner#, do.type#) = 1
            )
UNION ALL
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'ATTRIBUTE' COLUMN_TYPE,
  a.attribute_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_attributes$ a,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id = do.obj#
  AND av.view_type = 1 -- ET 
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 15 --ATTRIBUTE
  AND avc.referenced_object_id = a.attribute_id
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND a.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (do.owner#, do.type#) = 1
            )
/

comment on table ALL_CUBE_DIM_VIEW_COLUMNS is
'OLAP Dimension View Columns in the database accessible to the user'
/
comment on column ALL_CUBE_DIM_VIEW_COLUMNS.OWNER is
'Owner of the OLAP Dimension View Column'
/
comment on column ALL_CUBE_DIM_VIEW_COLUMNS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension View Column'
/
comment on column ALL_CUBE_DIM_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Dimension View Column'
/
comment on column ALL_CUBE_DIM_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Dimension View Column'
/
comment on column ALL_CUBE_DIM_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Dimension View Column'
/
comment on column ALL_CUBE_DIM_VIEW_COLUMNS.OBJECT_NAME is
'No object names for OLAP Dimension View Columns'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIM_VIEW_COLUMNS
FOR SYS.ALL_CUBE_DIM_VIEW_COLUMNS
/
GRANT READ ON ALL_CUBE_DIM_VIEW_COLUMNS to public
/

create or replace view USER_CUBE_DIM_VIEW_COLUMNS
as
SELECT 
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  DECODE(avc.column_type, 2, 'KEY',
                          4, 'LEVEL_NAME',
                          7, 'DIM_ORDER',
                          9, 'MEMBER_TYPE') COLUMN_TYPE,
  NULL OBJECT_NAME -- no object name for these column types  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ do,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id = do.obj#
  AND av.view_type = 1 -- ET 
  AND avc.column_type IN (2, 4, 6, 7, 9)
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND do.owner# = USERENV('SCHEMAID')
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
UNION ALL
SELECT 
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'ATTRIBUTE' COLUMN_TYPE,
  a.attribute_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_attributes$ a,
  col$ col,
  obj$ do,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id = do.obj#
  AND av.view_type = 1 -- ET 
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 15 --ATTRIBUTE
  AND avc.referenced_object_id = a.attribute_id
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND a.dim_obj# = do.obj#
  AND do.owner# = USERENV('SCHEMAID')
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
/

comment on table USER_CUBE_DIM_VIEW_COLUMNS is
'OLAP Dimension View Columns in the database accessible to the user'
/
comment on column USER_CUBE_DIM_VIEW_COLUMNS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension View Column'
/
comment on column USER_CUBE_DIM_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Dimension View Column'
/
comment on column USER_CUBE_DIM_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Dimension View Column'
/
comment on column USER_CUBE_DIM_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Dimension View Column'
/
comment on column USER_CUBE_DIM_VIEW_COLUMNS.OBJECT_NAME is
'No object names for OLAP Dimension View Columns'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIM_VIEW_COLUMNS
FOR SYS.USER_CUBE_DIM_VIEW_COLUMNS
/
GRANT READ ON USER_CUBE_DIM_VIEW_COLUMNS to public
/

create or replace view DBA_CUBE_HIER_VIEWS
as
SELECT
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  olap_hierarchies$ h,
  obj$ do,
  user$ du,
  obj$ vo
WHERE
  av.olap_object_type = 13 --HIERACHY
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
/

comment on table DBA_CUBE_HIER_VIEWS is
'OLAP Hierarchy Views in the database'
/
comment on column DBA_CUBE_HIER_VIEWS.OWNER is
'Owner of the OLAP Hierarchy View'
/
comment on column DBA_CUBE_HIER_VIEWS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy View'
/
comment on column DBA_CUBE_HIER_VIEWS.HIERARCHY_NAME is
'Name of hierarchy of the OLAP Hierarchy View'
/
comment on column DBA_CUBE_HIER_VIEWS.VIEW_NAME is
'View Name of the OLAP Hierarchy View'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_HIER_VIEWS
FOR SYS.DBA_CUBE_HIER_VIEWS
/
GRANT SELECT ON DBA_CUBE_HIER_VIEWS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_HIER_VIEWS','CDB_CUBE_HIER_VIEWS');
create or replace public synonym CDB_CUBE_HIER_VIEWS for sys.CDB_CUBE_HIER_VIEWS;
grant select on CDB_CUBE_HIER_VIEWS to select_catalog_role;

create or replace view ALL_CUBE_HIER_VIEWS
as
SELECT
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  olap_hierarchies$ h,
  obj$ do,
  user$ du,
  obj$ vo
WHERE
  av.olap_object_type = 13 --HIERACHY
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (do.owner#, do.type#) = 1
            )
/

comment on table ALL_CUBE_HIER_VIEWS is
'OLAP Hierarchy Views in the database accessible to the user'
/
comment on column ALL_CUBE_HIER_VIEWS.OWNER is
'Owner of the OLAP Hierarchy View'
/
comment on column ALL_CUBE_HIER_VIEWS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy View'
/
comment on column ALL_CUBE_HIER_VIEWS.HIERARCHY_NAME is
'Name of hierarchy of the OLAP Hierarchy View'
/
comment on column ALL_CUBE_HIER_VIEWS.VIEW_NAME is
'View Name of the OLAP Hierarchy View'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_HIER_VIEWS
FOR SYS.ALL_CUBE_HIER_VIEWS
/
GRANT READ ON ALL_CUBE_HIER_VIEWS to public
/

create or replace view USER_CUBE_HIER_VIEWS
as
SELECT
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  olap_hierarchies$ h,
  obj$ do,
  obj$ vo
WHERE
  av.olap_object_type = 13 --HIERACHY
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = USERENV('SCHEMAID')
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
/

comment on table USER_CUBE_HIER_VIEWS is
'OLAP Hierarchy Views owner by the user in the database'
/
comment on column USER_CUBE_HIER_VIEWS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy View'
/
comment on column USER_CUBE_HIER_VIEWS.HIERARCHY_NAME is
'Name of hierarchy of the OLAP Hierarchy View'
/
comment on column USER_CUBE_HIER_VIEWS.VIEW_NAME is
'View Name of the OLAP Hierarchy View'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_HIER_VIEWS
FOR SYS.USER_CUBE_HIER_VIEWS
/
GRANT READ ON USER_CUBE_HIER_VIEWS to public
/

create or replace view DBA_CUBE_HIER_VIEW_COLUMNS
as
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  DECODE(avc.column_type, 2, 'KEY',
                          3, 'PARENT',
                          4, 'LEVEL_NAME',
                          5, 'DEPTH',
                          8, 'HIER_ORDER',
                          9, 'MEMBER_TYPE') COLUMN_TYPE,
  NULL OBJECT_NAME -- no object name for these column types  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND avc.column_type IN (2, 3, 4, 5, 8, 9)
  AND av.olap_object_type = 13 --HIERARCHY
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
UNION ALL
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'ATTRIBUTE' COLUMN_TYPE,
  a.attribute_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  olap_attributes$ a,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 13 --HIERARCHY
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 15 --ATTRIBUTE
  AND avc.referenced_object_id = a.attribute_id
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
UNION ALL
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'LEVEL' COLUMN_TYPE,
  dl.level_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  olap_hier_levels$ l,
  olap_dim_levels$ dl,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 13 --HIERARCHY
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 12 --DIM_LEVEL
  AND avc.referenced_object_id = dl.level_id
  AND l.dim_level_id = dl.level_id
  AND l.hierarchy_id = h.hierarchy_id
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
/

comment on table DBA_CUBE_HIER_VIEW_COLUMNS is
'OLAP Hierarchy View Columns in the database'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.OWNER is
'Owner of the OLAP Hierarchy View Column'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy View Column'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.HIERARCHY_NAME is
'Name of hierarchy of the OLAP Hierarchy View Column'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Hierarchy View Column'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Hierarchy View Column'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Hierarchy View Column'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.OBJECT_NAME is
'No object names for OLAP Hierarchy View Columns'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_HIER_VIEW_COLUMNS 
FOR SYS.DBA_CUBE_HIER_VIEW_COLUMNS
/
GRANT SELECT ON DBA_CUBE_HIER_VIEW_COLUMNS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_HIER_VIEW_COLUMNS','CDB_CUBE_HIER_VIEW_COLUMNS');
create or replace public synonym CDB_CUBE_HIER_VIEW_COLUMNS for sys.CDB_CUBE_HIER_VIEW_COLUMNS;
grant select on CDB_CUBE_HIER_VIEW_COLUMNS to select_catalog_role;

create or replace view ALL_CUBE_HIER_VIEW_COLUMNS
as
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  DECODE(avc.column_type, 2, 'KEY',
                          3, 'PARENT',
                          4, 'LEVEL_NAME',
                          5, 'DEPTH',
                          8, 'HIER_ORDER',
                          9, 'MEMBER_TYPE') COLUMN_TYPE,
  NULL OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND avc.column_type IN (2, 3, 4, 5, 8, 9)
  AND av.olap_object_type = 13 --HIERARCHY
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (do.owner#, do.type#) = 1
            )
UNION ALL
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'ATTRIBUTE' COLUMN_TYPE,
  a.attribute_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  olap_attributes$ a,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 13 --HIERARCHY
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 15 --ATTRIBUTE
  AND avc.referenced_object_id = a.attribute_id
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (do.owner#, do.type#) = 1
            )
UNION ALL
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'LEVEL' COLUMN_TYPE,
  dl.level_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  olap_hier_levels$ l,
  olap_dim_levels$ dl,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 13 --HIERARCHY
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 12 --DIM_LEVEL
  AND avc.referenced_object_id = dl.level_id
  AND l.dim_level_id = dl.level_id
  AND l.hierarchy_id = h.hierarchy_id
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (do.owner#, do.type#) = 1
            )
/

comment on table ALL_CUBE_HIER_VIEW_COLUMNS is
'OLAP Hierarchy View Columns in the database accessible to the user'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.OWNER is
'Owner of the OLAP Hierarchy View Column'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy View Column'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.HIERARCHY_NAME is
'Name of hierarchy of the OLAP Hierarchy View Column'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Hierarchy View Column'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Hierarchy View Column'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Hierarchy View Column'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.OBJECT_NAME is
'No object names for OLAP Hierarchy View Columns'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_HIER_VIEW_COLUMNS 
FOR SYS.ALL_CUBE_HIER_VIEW_COLUMNS
/
GRANT READ ON ALL_CUBE_HIER_VIEW_COLUMNS to public
/

create or replace view USER_CUBE_HIER_VIEW_COLUMNS
as
SELECT 
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  DECODE(avc.column_type, 2, 'KEY',
                          3, 'PARENT',
                          4, 'LEVEL_NAME',
                          5, 'DEPTH',
                          8, 'HIER_ORDER',
                          9, 'MEMBER_TYPE') COLUMN_TYPE,
  NULL OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  col$ col,
  obj$ do,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND avc.column_type IN (2, 3, 4, 5, 8, 9)
  AND av.olap_object_type = 13 --HIERARCHY
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = USERENV('SCHEMAID')
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
UNION ALL
SELECT 
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'ATTRIBUTE' COLUMN_TYPE,
  a.attribute_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  olap_attributes$ a,
  col$ col,
  obj$ do,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 13 --HIERARCHY
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 15 --ATTRIBUTE
  AND avc.referenced_object_id = a.attribute_id
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = USERENV('SCHEMAID')
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
UNION ALL
SELECT 
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'LEVEL' COLUMN_TYPE,
  dl.level_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  olap_hier_levels$ l,
  olap_dim_levels$ dl,
  col$ col,
  obj$ do,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 13 --HIERARCHY
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 12 --DIM_LEVEL
  AND avc.referenced_object_id = dl.level_id
  AND l.dim_level_id = dl.level_id
  AND l.hierarchy_id = h.hierarchy_id
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = USERENV('SCHEMAID')
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
/

comment on table USER_CUBE_HIER_VIEW_COLUMNS is
'OLAP Hierarchy View Columns owned by the user in the database'
/
comment on column USER_CUBE_HIER_VIEW_COLUMNS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy View Column'
/
comment on column USER_CUBE_HIER_VIEW_COLUMNS.HIERARCHY_NAME is
'Name of hierarchy of the OLAP Hierarchy View Column'
/
comment on column USER_CUBE_HIER_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Hierarchy View Column'
/
comment on column USER_CUBE_HIER_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Hierarchy View Column'
/
comment on column USER_CUBE_HIER_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Hierarchy View Column'
/
comment on column USER_CUBE_HIER_VIEW_COLUMNS.OBJECT_NAME is
'No object names for OLAP Hierarchy View Columns'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_HIER_VIEW_COLUMNS 
FOR SYS.USER_CUBE_HIER_VIEW_COLUMNS
/
GRANT READ ON USER_CUBE_HIER_VIEW_COLUMNS to public
/

-- OLAP_MEASURE_FOLDERS$ DATA DICTIONARY VIEWS --

create or replace view DBA_MEASURE_FOLDERS
as
SELECT 
  u.name OWNER,
  o.name MEASURE_FOLDER_NAME,
  mf.obj# MEASURE_FOLDER_ID,
  d.description_value DESCRIPTION
FROM 
  olap_measure_folders$ mf, 
  obj$ o, 
  user$ u, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 10 --MEASURE_FOLDER
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  mf.obj# = o.obj# 
  AND o.owner# = u.user# 
  AND mf.obj# = d.owning_object_id(+)
/

comment on table DBA_MEASURE_FOLDERS is
'OLAP Measure Folders in the database'
/
comment on column DBA_MEASURE_FOLDERS.OWNER is
'Owner of the OLAP Measure Folder'
/
comment on column DBA_MEASURE_FOLDERS.MEASURE_FOLDER_NAME is
'Name of the OLAP Measure Folder'
/
comment on column DBA_MEASURE_FOLDERS.MEASURE_FOLDER_ID is
'Dictionary Id of the OLAP Measure Folder'
/
comment on column DBA_MEASURE_FOLDERS.DESCRIPTION is
'Long Description of the OLAP Measure Folder'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_MEASURE_FOLDERS 
FOR SYS.DBA_MEASURE_FOLDERS
/
GRANT SELECT ON DBA_MEASURE_FOLDERS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_MEASURE_FOLDERS','CDB_MEASURE_FOLDERS');
create or replace public synonym CDB_MEASURE_FOLDERS for sys.CDB_MEASURE_FOLDERS;
grant select on CDB_MEASURE_FOLDERS to select_catalog_role;

create or replace view ALL_MEASURE_FOLDERS
as
SELECT 
  u.name OWNER,
  o.name MEASURE_FOLDER_NAME,
  mf.obj# MEASURE_FOLDER_ID,
  d.description_value DESCRIPTION
FROM 
  olap_measure_folders$ mf, 
  obj$ o, 
  user$ u, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 10 --MEASURE_FOLDER
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  mf.obj# = o.obj# 
  AND o.owner# = u.user# 
  AND mf.obj# = d.owning_object_id(+)
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_MEASURE_FOLDERS is
'OLAP Measure Folders in the database accessible to the user'
/
comment on column ALL_MEASURE_FOLDERS.OWNER is
'Owner of the OLAP Measure Folder'
/
comment on column ALL_MEASURE_FOLDERS.MEASURE_FOLDER_NAME is
'Name of the OLAP Measure Folder'
/
comment on column ALL_MEASURE_FOLDERS.MEASURE_FOLDER_ID is
'Dictionary Id of the OLAP Measure Folder'
/
comment on column ALL_MEASURE_FOLDERS.DESCRIPTION is
'Long Description of the OLAP Measure Folder'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_MEASURE_FOLDERS 
FOR ALL_MEASURE_FOLDERS
/
GRANT READ ON ALL_MEASURE_FOLDERS to public
/

create or replace view USER_MEASURE_FOLDERS
as
SELECT 
  o.name MEASURE_FOLDER_NAME,
  mf.obj# MEASURE_FOLDER_ID,
  d.description_value DESCRIPTION
FROM 
  olap_measure_folders$ mf, 
  obj$ o, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 10 --MEASURE_FOLDER
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  mf.obj# = o.obj# 
  AND o.owner# = USERENV('SCHEMAID')
  AND mf.obj# = d.owning_object_id(+)
/

comment on table USER_MEASURE_FOLDERS is
'OLAP Measure Folders owned by the user in the database'
/
comment on column USER_MEASURE_FOLDERS.MEASURE_FOLDER_NAME is
'Name of the OLAP Measure Folder'
/
comment on column USER_MEASURE_FOLDERS.MEASURE_FOLDER_ID is
'Dictionary Id of the OLAP Measure Folder'
/
comment on column USER_MEASURE_FOLDERS.DESCRIPTION is
'Long Description of the OLAP Measure Folder'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_MEASURE_FOLDERS 
FOR USER_MEASURE_FOLDERS
/
GRANT READ ON USER_MEASURE_FOLDERS to public
/

create or replace view DBA_MEASURE_FOLDER_CONTENTS
as
SELECT 
  u.name OWNER,
  o.name MEASURE_FOLDER_NAME,
  cu.name CUBE_OWNER,
  co.name CUBE_NAME,
  m.measure_name MEASURE_NAME,
  mf.order_num ORDER_NUM
FROM 
  olap_meas_folder_contents$ mf, 
  obj$ o, 
  user$ u,
  olap_measures$ m,
  obj$ co,
  user$ cu
WHERE 
  mf.measure_folder_obj#=o.obj# 
  AND o.owner#=u.user# 
  AND mf.object_type = 2 -- MEASURE 
  AND mf.object_id = m.measure_id
  AND m.cube_obj# = co.obj#
  AND co.owner# = cu.user#
/

comment on table DBA_MEASURE_FOLDER_CONTENTS is
'OLAP Measure Folder Contents in the database'
/
comment on column DBA_MEASURE_FOLDER_CONTENTS.OWNER is
'Owner of the OLAP Measure Folder Content'
/
comment on column DBA_MEASURE_FOLDER_CONTENTS.MEASURE_FOLDER_NAME is
'Name of the owning OLAP Measure Folder'
/
comment on column DBA_MEASURE_FOLDER_CONTENTS.CUBE_OWNER is
'Owner of the cube of the OLAP Measure Folder Content'
/
comment on column DBA_MEASURE_FOLDER_CONTENTS.CUBE_NAME is
'Name of the owning cube of the OLAP Measure Folder Content'
/
comment on column DBA_MEASURE_FOLDER_CONTENTS.MEASURE_NAME is
'Name of the owning measure of the OLAP Measure Folder Content'
/
comment on column DBA_MEASURE_FOLDER_CONTENTS.ORDER_NUM is
'Order number of the OLAP Measure Folder Content'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_MEASURE_FOLDER_CONTENTS
FOR SYS.DBA_MEASURE_FOLDER_CONTENTS
/
GRANT SELECT ON DBA_MEASURE_FOLDER_CONTENTS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_MEASURE_FOLDER_CONTENTS','CDB_MEASURE_FOLDER_CONTENTS');
create or replace public synonym CDB_MEASURE_FOLDER_CONTENTS for sys.CDB_MEASURE_FOLDER_CONTENTS;
grant select on CDB_MEASURE_FOLDER_CONTENTS to select_catalog_role;

create or replace view ALL_MEASURE_FOLDER_CONTENTS
as
SELECT 
  u.name OWNER,
  o.name MEASURE_FOLDER_NAME,
  cu.name CUBE_OWNER,
  co.name CUBE_NAME,
  m.measure_name MEASURE_NAME,
  mf.order_num ORDER_NUM
FROM 
  olap_meas_folder_contents$ mf, 
  obj$ o, 
  user$ u,
  olap_measures$ m,
  obj$ co,
  user$ cu,
  (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE 
  mf.measure_folder_obj#=o.obj# 
  AND o.owner#=u.user# 
  AND mf.object_type = 2 -- MEASURE 
  AND mf.object_id = m.measure_id
  AND m.cube_obj# = co.obj#
  AND co.owner# = cu.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- folder is ownwd by user or public object
       or   -- user has access to measure folder
             (o.obj# in 
                  ( select obj#  -- directly granted privileges 
                    from sys.objauth$
                    where grantee# in ( select kzsrorol from x$kzsro ) ) )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- cube is owned by user or public object
       or   -- user has access to cube
             (co.obj# in 
                  ( select obj#  -- directly granted privileges 
                    from sys.objauth$
                    where grantee# in ( select kzsrorol from x$kzsro ) ) )
       or   -- user has system privileges 
              ora_check_SYS_privilege (co.owner#, co.type#) = 1
            )
  AND co.obj# = da.obj#(+)
  AND (da.have_all_dim_access = 1 or da.have_all_dim_access is NULL)
/

comment on table ALL_MEASURE_FOLDER_CONTENTS is
'OLAP Measure Folder Contents in the database accessible by the user'
/
comment on column ALL_MEASURE_FOLDER_CONTENTS.OWNER is
'Owner of the OLAP Measure Folder Content'
/
comment on column ALL_MEASURE_FOLDER_CONTENTS.MEASURE_FOLDER_NAME is
'Name of the owning OLAP Measure Folder'
/
comment on column ALL_MEASURE_FOLDER_CONTENTS.CUBE_OWNER is
'Owner of the cube of the OLAP Measure Folder Content'
/
comment on column ALL_MEASURE_FOLDER_CONTENTS.CUBE_NAME is
'Name of the owning cube of the OLAP Measure Folder Content'
/
comment on column ALL_MEASURE_FOLDER_CONTENTS.MEASURE_NAME is
'Name of the owning measure of the OLAP Measure Folder Content'
/
comment on column ALL_MEASURE_FOLDER_CONTENTS.ORDER_NUM is
'Order number of the OLAP Measure Folder Content'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_MEASURE_FOLDER_CONTENTS
FOR SYS.ALL_MEASURE_FOLDER_CONTENTS
/
GRANT READ ON ALL_MEASURE_FOLDER_CONTENTS to public
/

create or replace view USER_MEASURE_FOLDER_CONTENTS
as
SELECT 
  o.name MEASURE_FOLDER_NAME,
  cu.name CUBE_OWNER,
  co.name CUBE_NAME,
  m.measure_name MEASURE_NAME,
  mf.order_num ORDER_NUM
FROM 
  olap_meas_folder_contents$ mf, 
  obj$ o, 
  olap_measures$ m,
  obj$ co,
  user$ cu
WHERE 
  mf.measure_folder_obj#=o.obj# 
  AND o.owner#=USERENV('SCHEMAID')
  AND mf.object_type = 2 -- MEASURE 
  AND mf.object_id = m.measure_id
  AND m.cube_obj# = co.obj#
  AND co.owner# = cu.user#
/

comment on table USER_MEASURE_FOLDER_CONTENTS is
'OLAP Measure Folder Contents owned by the user in the database'
/
comment on column USER_MEASURE_FOLDER_CONTENTS.MEASURE_FOLDER_NAME is
'Name of the owning OLAP Measure Folder'
/
comment on column USER_MEASURE_FOLDER_CONTENTS.CUBE_OWNER is
'Owner of the cube of the OLAP Measure Folder Content'
/
comment on column USER_MEASURE_FOLDER_CONTENTS.CUBE_NAME is
'Name of the owning cube of the OLAP Measure Folder Content'
/
comment on column USER_MEASURE_FOLDER_CONTENTS.MEASURE_NAME is
'Name of the owning measure of the OLAP Measure Folder Content'
/
comment on column USER_MEASURE_FOLDER_CONTENTS.ORDER_NUM is
'Order number of the OLAP Measure Folder Content'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_MEASURE_FOLDER_CONTENTS
FOR SYS.USER_MEASURE_FOLDER_CONTENTS
/
GRANT READ ON USER_MEASURE_FOLDER_CONTENTS to public
/

create or replace view USER_MEASURE_FOLDER_SUBFOLDERS
as
SELECT
  o.name MEASURE_FOLDER_NAME,
  uchild.name MEASURE_SUBFOLDER_OWNER,
  ochild.name MEASURE_SUBFOLDER_NAME
FROM
  olap_meas_folder_contents$ mfc,
  obj$ o,
  obj$ ochild,
  user$ uchild
WHERE
  mfc.MEASURE_FOLDER_OBJ# = o.obj# -- PARENT
  AND ochild.owner# = uchild.user# -- SUBFOLDER_OWNER
  AND o.owner# = USERENV('SCHEMAID')
  AND mfc.object_type = 10 --MEASURE_FOLDER 
  AND ochild.obj# = mfc.OBJECT_ID --CHILD
/

comment on table USER_MEASURE_FOLDER_SUBFOLDERS is
'OLAP Measure Folders contained within the user OLAP Measure Folders'
/
comment on column USER_MEASURE_FOLDER_SUBFOLDERS.MEASURE_FOLDER_NAME is
'Name of the OLAP Measure Folder that contains a subfolder'
/
comment on column USER_MEASURE_FOLDER_SUBFOLDERS.MEASURE_SUBFOLDER_OWNER is
'Owner of the OLAP Measure Folder subfolder'
/
comment on column USER_MEASURE_FOLDER_SUBFOLDERS.MEASURE_SUBFOLDER_NAME is
'Name of the OLAP Measure Folder subfolder'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_MEASURE_FOLDER_SUBFOLDERS
FOR SYS.USER_MEASURE_FOLDER_SUBFOLDERS
/
GRANT READ ON USER_MEASURE_FOLDER_SUBFOLDERS to public
/

create or replace view DBA_MEASURE_FOLDER_SUBFOLDERS
as
SELECT
  u.name OWNER,
  o.name MEASURE_FOLDER_NAME,
  uchild.name MEASURE_SUBFOLDER_OWNER,
  ochild.name MEASURE_SUBFOLDER_NAME
FROM
  olap_meas_folder_contents$ mfc,
  obj$ o,
  obj$ ochild,
  user$ uchild,
  user$ u
WHERE
  mfc.MEASURE_FOLDER_OBJ# = o.obj# -- PARENT
  AND ochild.owner# = uchild.user# -- SUBFOLDER_OWNER
  AND o.owner#=u.user#
  AND mfc.object_type = 10 --MEASURE_FOLDER 
  AND ochild.obj# = mfc.OBJECT_ID --CHILD
/

comment on table DBA_MEASURE_FOLDER_SUBFOLDERS is
'OLAP Measure Folders contained within the database OLAP Measure Folders'
/
comment on column DBA_MEASURE_FOLDER_SUBFOLDERS.OWNER is
'Owner of the OLAP Measure Folder that contains a subfolder'
/
comment on column DBA_MEASURE_FOLDER_SUBFOLDERS.MEASURE_FOLDER_NAME is
'Name of the OLAP Measure Folder that contains a subfolder'
/
comment on column DBA_MEASURE_FOLDER_SUBFOLDERS.MEASURE_SUBFOLDER_OWNER is
'Owner of the OLAP Measure Folder subfolder'
/
comment on column DBA_MEASURE_FOLDER_SUBFOLDERS.MEASURE_SUBFOLDER_NAME is
'Name of the OLAP Measure Folder subfolder'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_MEASURE_FOLDER_SUBFOLDERS
FOR SYS.DBA_MEASURE_FOLDER_SUBFOLDERS
/
GRANT SELECT ON DBA_MEASURE_FOLDER_SUBFOLDERS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_MEASURE_FOLDER_SUBFOLDERS','CDB_MEASURE_FOLDER_SUBFOLDERS');
create or replace public synonym CDB_MEASURE_FOLDER_SUBFOLDERS for sys.CDB_MEASURE_FOLDER_SUBFOLDERS;
grant select on CDB_MEASURE_FOLDER_SUBFOLDERS to select_catalog_role;

create or replace view ALL_MEASURE_FOLDER_SUBFOLDERS
as
SELECT
  u.name OWNER,
  o.name MEASURE_FOLDER_NAME,
  uchild.name MEASURE_SUBFOLDER_OWNER,
  ochild.name MEASURE_SUBFOLDER_NAME
FROM
  olap_meas_folder_contents$ mfc,
  obj$ o,
  obj$ ochild,
  user$ uchild,
  user$ u 
WHERE
  mfc.MEASURE_FOLDER_OBJ# = o.obj# -- PARENT
  AND ochild.owner# = uchild.user# -- SUBFOLDER_OWNER
  AND o.owner#=u.user#
  AND mfc.object_type = 10 --MEASURE_FOLDER 
  AND ochild.obj# = mfc.OBJECT_ID --CHILD
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_MEASURE_FOLDER_SUBFOLDERS is
'OLAP Measure Folders contained within the OLAP Measure Folders accessible to the user'
/
comment on column ALL_MEASURE_FOLDER_SUBFOLDERS.OWNER is
'Owner of the OLAP Measure Folder that contains a subfolder'
/
comment on column ALL_MEASURE_FOLDER_SUBFOLDERS.MEASURE_FOLDER_NAME is
'Name of the OLAP Measure Folder that contains a subfolder'
/
comment on column ALL_MEASURE_FOLDER_SUBFOLDERS.MEASURE_SUBFOLDER_OWNER is
'Owner of the OLAP Measure Folder subfolder'
/
comment on column ALL_MEASURE_FOLDER_SUBFOLDERS.MEASURE_SUBFOLDER_NAME is
'Name of the owning OLAP Measure Folder subfolder'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_MEASURE_FOLDER_SUBFOLDERS
FOR SYS.ALL_MEASURE_FOLDER_SUBFOLDERS
/
GRANT READ ON ALL_MEASURE_FOLDER_SUBFOLDERS to public
/

-- OLAP_CUBE_BUILD_PROCESSES$ DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_BUILD_PROCESSES
as
SELECT 
  u.name OWNER,
  o.name BUILD_PROCESS_NAME,
  ia.obj# BUILD_PROCESS_ID,
  syn.syntax_clob BUILD_PROCESS,
  d.description_value DESCRIPTION
FROM 
  olap_cube_build_processes$ ia, 
  obj$ o, 
  user$ u, 
  olap_syntax$ syn,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 8 --BUILD_PROCESS
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  ia.obj# = o.obj# 
  AND o.owner# = u.user# 
  AND ia.obj# = d.owning_object_id(+)
  AND syn.owner_id(+)=ia.obj#
  AND syn.owner_type(+)=8
  AND syn.ref_role(+)=13 -- build process 
/

comment on table DBA_CUBE_BUILD_PROCESSES is
'OLAP Build Processes in the database'
/
comment on column DBA_CUBE_BUILD_PROCESSES.OWNER is
'Owner of the OLAP Build Process'
/
comment on column DBA_CUBE_BUILD_PROCESSES.BUILD_PROCESS_NAME is
'Name of the OLAP Build Process'
/
comment on column DBA_CUBE_BUILD_PROCESSES.BUILD_PROCESS_ID is
'Dictionary Id of the OLAP Build Process'
/
comment on column DBA_CUBE_BUILD_PROCESSES.BUILD_PROCESS is
'The Build Process syntax text for the OLAP Build Process'
/
comment on column DBA_CUBE_BUILD_PROCESSES.DESCRIPTION is
'Long Description of the OLAP Build Process'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_BUILD_PROCESSES 
FOR SYS.DBA_CUBE_BUILD_PROCESSES
/
GRANT SELECT ON DBA_CUBE_BUILD_PROCESSES to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_BUILD_PROCESSES','CDB_CUBE_BUILD_PROCESSES');
create or replace public synonym CDB_CUBE_BUILD_PROCESSES for sys.CDB_CUBE_BUILD_PROCESSES;
grant select on CDB_CUBE_BUILD_PROCESSES to select_catalog_role;

create or replace view ALL_CUBE_BUILD_PROCESSES
as
SELECT 
  u.name OWNER,
  o.name BUILD_PROCESS_NAME,
  ia.obj# BUILD_PROCESS_ID,
  syn.syntax_clob BUILD_PROCESS,
  d.description_value DESCRIPTION
FROM 
  olap_cube_build_processes$ ia, 
  obj$ o, 
  user$ u, 
  olap_syntax$ syn,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 8 --BUILD_PROCESS
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  ia.obj# = o.obj# 
  AND o.owner# = u.user# 
  AND ia.obj# = d.owning_object_id(+)
  AND syn.owner_id(+)=ia.obj#
  AND syn.owner_type(+)=8
  AND syn.ref_role(+)=13 -- build process 
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_CUBE_BUILD_PROCESSES is
'OLAP Build Processes in the database accessible to the user'
/
comment on column ALL_CUBE_BUILD_PROCESSES.OWNER is
'Owner of the OLAP Build Processes'
/
comment on column ALL_CUBE_BUILD_PROCESSES.BUILD_PROCESS_NAME is
'Name of the OLAP Build Process'
/
comment on column ALL_CUBE_BUILD_PROCESSES.BUILD_PROCESS_ID is
'Dictionary Id of the OLAP Build Process'
/
comment on column ALL_CUBE_BUILD_PROCESSES.BUILD_PROCESS is
'The Build Process syntax text for the OLAP Build Process'
/
comment on column ALL_CUBE_BUILD_PROCESSES.DESCRIPTION is
'Long Description of the OLAP Build Process'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_BUILD_PROCESSES 
FOR SYS.ALL_CUBE_BUILD_PROCESSES
/
GRANT READ ON ALL_CUBE_BUILD_PROCESSES to public
/

create or replace view USER_CUBE_BUILD_PROCESSES
as
SELECT 
  o.name BUILD_PROCESS_NAME,
  ia.obj# BUILD_PROCESS_ID,
  syn.syntax_clob BUILD_PROCESS,
  d.description_value DESCRIPTION
FROM 
  olap_cube_build_processes$ ia, 
  obj$ o, 
  olap_syntax$ syn,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
        n.parameter = 'NLS_LANGUAGE'
        and d.description_type = 'Description'
        and d.owning_object_type = 8 --BUILD_PROCESS
        and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  ia.obj# = o.obj# 
  AND o.owner# = USERENV('SCHEMAID')
  AND ia.obj# = d.owning_object_id(+)
  AND syn.owner_id(+)=ia.obj#
  AND syn.owner_type(+)=8
  AND syn.ref_role(+)=13 -- build process 
/

comment on table USER_CUBE_BUILD_PROCESSES is
'OLAP Build Processes owned by the user in the database'
/
comment on column USER_CUBE_BUILD_PROCESSES.BUILD_PROCESS_NAME is
'Name of the OLAP Build Process'
/
comment on column USER_CUBE_BUILD_PROCESSES.BUILD_PROCESS_ID is
'Dictionary Id of the OLAP Build Process'
/
comment on column USER_CUBE_BUILD_PROCESSES.BUILD_PROCESS is
'The Build Process syntax text for the OLAP Build Process'
/
comment on column USER_CUBE_BUILD_PROCESSES.DESCRIPTION is
'Long Description of the OLAP Build Process'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_BUILD_PROCESSES 
FOR SYS.USER_CUBE_BUILD_PROCESSES
/
GRANT READ ON USER_CUBE_BUILD_PROCESSES to public
/

-- OLAP_MAPPINGS$ DATA DICTIONARY VIEWS for CUBE MAPPINGS --
create or replace view DBA_CUBE_MAPPINGS
as
SELECT
  u.name OWNER,
  o.name CUBE_NAME,
  m.map_name MAP_NAME, 
  m.map_id MAP_ID,
  s1.syntax_clob QUERY,
  s2.syntax_clob WHERE_CLAUSE,
  s3.syntax_clob FROM_CLAUSE,
  decode(i1.option_num_value, '1', 'Y', 'N') IS_SOLVED,
  i2.option_value AGGREGATION_METHOD       
FROM 
  olap_mappings$ m,
  user$ u,
  obj$ o, 
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_impl_options$ i1,
  olap_impl_options$ i2
WHERE
  m.map_type = 22 
  AND m.mapping_owner_id = o.obj#
  AND o.owner# = u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 21
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = i1.owning_objectid(+)
  AND m.map_type = i1.object_type(+)
  AND i1.option_type(+) = 11
  AND m.map_id = i2.owning_objectid(+)
  AND m.map_type = i2.object_type(+)
  AND i2.option_type(+) = 21
/

comment on table DBA_CUBE_MAPPINGS is
'OLAP Cube Mappings in the database'
/
comment on column DBA_CUBE_MAPPINGS.OWNER is
'Owner of the OLAP Cube'
/
comment on column DBA_CUBE_MAPPINGS.MAP_NAME is
'Name of the OLAP Cube Mapping'
/
comment on column DBA_CUBE_MAPPINGS.MAP_ID is
'Dictionary Id of the OLAP Cube Mapping'
/
comment on column DBA_CUBE_MAPPINGS.QUERY is
'Query of the OLAP Cube Mapping'
/
comment on column DBA_CUBE_MAPPINGS.WHERE_CLAUSE is
'Where Clause of the OLAP Cube Mapping'
/
comment on column DBA_CUBE_MAPPINGS.FROM_CLAUSE is
'From Clause of the OLAP Cube Mapping'
/
comment on column DBA_CUBE_MAPPINGS.IS_SOLVED is
'Indication of whether or not the OLAP Cube Mapping is solved'
/
comment on column DBA_CUBE_MAPPINGS.AGGREGATION_METHOD is
'Aggregation method of the OLAP Cube Mapping'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_MAPPINGS
FOR SYS.DBA_CUBE_MAPPINGS
/
GRANT SELECT ON DBA_CUBE_MAPPINGS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_MAPPINGS','CDB_CUBE_MAPPINGS');
create or replace public synonym CDB_CUBE_MAPPINGS for sys.CDB_CUBE_MAPPINGS;
grant select on CDB_CUBE_MAPPINGS to select_catalog_role;

create or replace view ALL_CUBE_MAPPINGS
as
SELECT
  u.name OWNER,
  o.name CUBE_NAME,
  m.map_name MAP_NAME, 
  m.map_id MAP_ID,
  s1.syntax_clob QUERY,
  s2.syntax_clob WHERE_CLAUSE,
  s3.syntax_clob FROM_CLAUSE,
  decode(i1.option_num_value, '1', 'Y', 'N') IS_SOLVED,
  i2.option_value AGGREGATION_METHOD       
FROM 
  olap_mappings$ m,
  user$ u,
  obj$ o, 
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_impl_options$ i1,
  olap_impl_options$ i2,
 (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE
  m.map_type = 22 
  AND m.mapping_owner_id = o.obj#
  AND o.obj# = da.obj#(+)
  AND o.owner# = u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 21
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = i1.owning_objectid(+)
  AND m.map_type = i1.object_type(+)
  AND i1.option_type(+) = 11
  AND m.map_id = i2.owning_objectid(+)
  AND m.map_type = i2.object_type(+)
  AND i2.option_type(+) = 21
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
/

comment on table ALL_CUBE_MAPPINGS is
'OLAP Cube Mappings in the database accessible to the user'
/
comment on column ALL_CUBE_MAPPINGS.OWNER is
'Owner of the OLAP Cube'
/
comment on column ALL_CUBE_MAPPINGS.MAP_NAME is
'Name of the OLAP Cube Mapping'
/
comment on column ALL_CUBE_MAPPINGS.MAP_ID is
'Dictionary Id of the OLAP Cube Mapping'
/
comment on column ALL_CUBE_MAPPINGS.QUERY is
'Query of the OLAP Cube Mapping'
/
comment on column ALL_CUBE_MAPPINGS.WHERE_CLAUSE is
'Where Clause of the OLAP Cube Mapping'
/
comment on column ALL_CUBE_MAPPINGS.FROM_CLAUSE is
'From Clause of the OLAP Cube Mapping'
/
comment on column ALL_CUBE_MAPPINGS.IS_SOLVED is
'Indication of whether or not the OLAP Cube Mapping is solved'
/
comment on column ALL_CUBE_MAPPINGS.AGGREGATION_METHOD is
'Aggregation method of the OLAP Cube Mapping'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_MAPPINGS
FOR SYS.ALL_CUBE_MAPPINGS
/
GRANT READ ON ALL_CUBE_MAPPINGS to public
/

create or replace view USER_CUBE_MAPPINGS
as
SELECT
  o.name CUBE_NAME,
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  s1.syntax_clob QUERY,
  s2.syntax_clob WHERE_CLAUSE,
  s3.syntax_clob FROM_CLAUSE,
  decode(i1.option_num_value, '1', 'Y', 'N') IS_SOLVED,
  i2.option_value AGGREGATION_METHOD       
FROM 
  olap_mappings$ m,
  obj$ o, 
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_impl_options$ i1,
  olap_impl_options$ i2
WHERE
  m.map_type = 22 
  AND m.mapping_owner_id = o.obj#
  AND o.owner#=USERENV('SCHEMAID')   
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 21
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = i1.owning_objectid(+)
  AND m.map_type = i1.object_type(+)
  AND i1.option_type(+) = 11
  AND m.map_id = i2.owning_objectid(+)
  AND m.map_type = i2.object_type(+)
  AND i2.option_type(+) = 21
/

comment on table USER_CUBE_MAPPINGS is
'OLAP Cube Mappings owned by the user in the database'
/
comment on column USER_CUBE_MAPPINGS.MAP_NAME is
'Name of the OLAP Cube Mapping'
/
comment on column USER_CUBE_MAPPINGS.MAP_ID is
'Dictionary Id of the OLAP Cube Mapping'
/
comment on column USER_CUBE_MAPPINGS.QUERY is
'Query of the OLAP Cube Mapping'
/
comment on column USER_CUBE_MAPPINGS.WHERE_CLAUSE is
'Where Clause of the OLAP Cube Mapping'
/
comment on column USER_CUBE_MAPPINGS.FROM_CLAUSE is
'From Clause of the OLAP Cube Mapping'
/
comment on column USER_CUBE_MAPPINGS.IS_SOLVED is
'Indication of whether or not the OLAP Cube Mapping is solved'
/
comment on column USER_CUBE_MAPPINGS.AGGREGATION_METHOD is
'Aggregation method of the OLAP Cube Mapping'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_MAPPINGS
FOR SYS.USER_CUBE_MAPPINGS
/
GRANT READ ON USER_CUBE_MAPPINGS to public
/

-- OLAP_MAPPINGS$ DATA DICTIONARY VIEWS for CUBE MEASURE MAPPINGS --

create or replace view DBA_CUBE_MEAS_MAPPINGS
as
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  owner_map.map_name CUBE_MAP_NAME,
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  meas.measure_name MEASURE_NAME,
  s1.syntax_clob MEASURE_EXPRESSION
FROM
  olap_mappings$ m,
  olap_mappings$ owner_map,
  user$ u,
  obj$ o,
  olap_measures$ meas,
  olap_syntax$ s1
WHERE
  m.map_type = 24
  AND m.mapped_object_id = meas.measure_id
  AND meas.cube_obj# = o.obj#
  AND o.owner# = u.user#
  AND m.mapping_owner_id = owner_map.map_id
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 1
/

comment on table DBA_CUBE_MEAS_MAPPINGS is
'OLAP Cube Measure Mappings in the database'
/
comment on column DBA_CUBE_MEAS_MAPPINGS.OWNER is
'Owner of the OLAP Cube that contains the measure'
/
comment on column DBA_CUBE_MEAS_MAPPINGS.CUBE_NAME is
'Name of the OLAP Cube that contains the measure'
/
comment on column DBA_CUBE_MEAS_MAPPINGS.CUBE_MAP_NAME is
'Name of the map that contains the cube measure mapping'
/
comment on column DBA_CUBE_MEAS_MAPPINGS.MAP_NAME is
'Name of the OLAP Cube Measure Mapping'
/
comment on column DBA_CUBE_MEAS_MAPPINGS.MAP_ID is
'Dictionary Id of the OLAP Cube Measure Mapping'
/
comment on column DBA_CUBE_MEAS_MAPPINGS.MEASURE_NAME is
'Name of the OLAP Cube Measure'
/
comment on column DBA_CUBE_MEAS_MAPPINGS.MEASURE_EXPRESSION is
'Expression of the OLAP Cube Measure Mapping'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_MEAS_MAPPINGS
FOR SYS.DBA_CUBE_MEAS_MAPPINGS
/
GRANT SELECT ON DBA_CUBE_MEAS_MAPPINGS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_MEAS_MAPPINGS','CDB_CUBE_MEAS_MAPPINGS');
create or replace public synonym CDB_CUBE_MEAS_MAPPINGS for sys.CDB_CUBE_MEAS_MAPPINGS;
grant select on CDB_CUBE_MEAS_MAPPINGS to select_catalog_role;

create or replace view ALL_CUBE_MEAS_MAPPINGS
as
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  owner_map.map_name CUBE_MAP_NAME,
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  meas.measure_name MEASURE_NAME,
  s1.syntax_clob MEASURE_EXPRESSION
FROM
  olap_mappings$ m,
  olap_mappings$ owner_map,
  user$ u,
  obj$ o,
  olap_measures$ meas,
  olap_syntax$ s1,
 (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE
  m.map_type = 24
  AND m.mapped_object_id = meas.measure_id
  AND m.mapping_owner_id = owner_map.map_id
  AND meas.cube_obj# = o.obj#
  AND o.obj# = da.obj#(+)
  AND o.owner# = u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 1
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
/

comment on table ALL_CUBE_MEAS_MAPPINGS is
'OLAP Cube Measure Mappings in the database that are accessible to the user'
/
comment on column ALL_CUBE_MEAS_MAPPINGS.OWNER is
'Owner of the OLAP Cube that contains the measure'
/
comment on column ALL_CUBE_MEAS_MAPPINGS.CUBE_NAME is
'Name of the OLAP Cube that contains the measure'
/
comment on column ALL_CUBE_MEAS_MAPPINGS.CUBE_MAP_NAME is
'Name of the map that contains the cube measure mapping'
/
comment on column ALL_CUBE_MEAS_MAPPINGS.MAP_NAME is
'Name of the OLAP Cube Measure Mapping'
/
comment on column ALL_CUBE_MEAS_MAPPINGS.MAP_ID is
'Dictionary Id of the OLAP Cube Measure Mapping'
/
comment on column ALL_CUBE_MEAS_MAPPINGS.MEASURE_NAME is
'Name of the OLAP Cube Measure'
/
comment on column ALL_CUBE_MEAS_MAPPINGS.MEASURE_EXPRESSION is
'Expression of the OLAP Cube Measure Mapping'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_MEAS_MAPPINGS
FOR SYS.ALL_CUBE_MEAS_MAPPINGS
/
GRANT READ ON ALL_CUBE_MEAS_MAPPINGS to public
/

create or replace view USER_CUBE_MEAS_MAPPINGS
as
SELECT 
  o.name CUBE_NAME,
  owner_map.map_name CUBE_MAP_NAME,
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  meas.measure_name MEASURE_NAME,
  s1.syntax_clob MEASURE_EXPRESSION
FROM
  olap_mappings$ m,
  olap_mappings$ owner_map,
  obj$ o,
  olap_measures$ meas,
  olap_syntax$ s1
WHERE
  m.map_type = 24
  AND m.mapped_object_id = meas.measure_id
  AND m.mapping_owner_id = owner_map.map_id
  AND meas.cube_obj# = o.obj#
  AND o.owner#=USERENV('SCHEMAID')   
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 1
/

comment on table USER_CUBE_MEAS_MAPPINGS is
'OLAP Cube Measure Mappings owned by the user in the database'
/
comment on column USER_CUBE_MEAS_MAPPINGS.CUBE_NAME is
'Name of the OLAP Cube that contains the measure'
/
comment on column USER_CUBE_MEAS_MAPPINGS.CUBE_MAP_NAME is
'Name of the map that contains the cube measure mapping'
/
comment on column USER_CUBE_MEAS_MAPPINGS.MAP_NAME is
'Name of the OLAP Cube Measure Mapping'
/
comment on column USER_CUBE_MEAS_MAPPINGS.MAP_ID is
'Dictionary Id of the OLAP Cube Measure Mapping'
/
comment on column USER_CUBE_MEAS_MAPPINGS.MEASURE_NAME is
'Name of the OLAP Cube Measure'
/
comment on column USER_CUBE_MEAS_MAPPINGS.MEASURE_EXPRESSION is
'Expression of the OLAP Cube Measure Mapping'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_MEAS_MAPPINGS
FOR SYS.USER_CUBE_MEAS_MAPPINGS
/
GRANT READ ON USER_CUBE_MEAS_MAPPINGS to public
/

-- OLAP_MAPPINGS$ DATA DICTIONARY VIEWS for CUBE DIMENSIONALITY MAPPINGS --

create or replace view DBA_CUBE_DIMNL_MAPPINGS
as
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  owner_map.map_name CUBE_MAP_NAME,
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  o2.name MAPPED_DIMENSION_NAME,
  CASE m.mapped_dim_type
  WHEN 14 -- hier_level
  THEN (SELECT h.hierarchy_name
        FROM olap_hier_levels$ hl, olap_hierarchies$ h             
        WHERE m.mapped_dim_id = hl.hierarchy_level_id
              AND hl.hierarchy_id = h.hierarchy_id                            
        )  
  WHEN 13 -- hierarchy
  THEN (SELECT h.hierarchy_name
        FROM olap_hierarchies$ h
        WHERE m.mapped_dim_id = h.hierarchy_id
       )
  ELSE null END AS MAPPED_HIERARCHY_NAME,
  CASE m.mapped_dim_type
  WHEN 12 -- dim_level
  THEN (SELECT dl.level_name 
        FROM olap_dim_levels$ dl
        WHERE m.mapped_dim_id = dl.level_id 
        )
  WHEN 14 -- hier_level
  THEN (SELECT dl.level_name
        FROM olap_dim_levels$ dl, olap_hier_levels$ hl, olap_hierarchies$ h
        WHERE m.mapped_dim_id = hl.hierarchy_level_id
              AND hl.hierarchy_id = h.hierarchy_id
              AND hl.dim_level_id = dl.level_id  
        )  
  ELSE null END AS MAPPED_LEVEL_NAME,
  decode(m.mapped_dim_type, '12', 'DIMENSION LEVEL',
                            '11', 'PRIMARY DIMENSION',
                            '14', 'HIERARCHY LEVEL',
                            '13', 'HIERARCHY') MAPPED_DIMENSION_TYPE,
  s1.syntax_clob JOIN_CONDITION,
  s2.syntax_clob LEVEL_ID_EXPRESSION,
  s3.syntax_clob DIMENSIONALITY_EXPRESSION
FROM 
  olap_mappings$ m,
  olap_mappings$ owner_map,
  user$ u,
  olap_dimensionality$ diml,
  obj$ o,
  obj$ o2,
  olap_syntax$ s1,
  olap_syntax$ s2, 
  olap_syntax$ s3
WHERE 
  m.map_type = 23
  AND m.mapped_object_id = diml.dimensionality_id
  AND m.mapping_owner_id = owner_map.map_id
  AND diml.dimensioned_object_id = o.obj#
  AND o.owner# = u.user#
  AND diml.dimension_id = o2.obj#(+)
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 7
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 8
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 15
/

comment on table DBA_CUBE_DIMNL_MAPPINGS is
'OLAP Cube Dimenisonality Mappings in the database'
/
comment on column DBA_CUBE_DIMNL_MAPPINGS.OWNER is
'Owner of the OLAP Cube that contains the dimensionality'
/
comment on column DBA_CUBE_DIMNL_MAPPINGS.CUBE_NAME is
'Name of the OLAP Cube that contains the dimensionality'
/
comment on column DBA_CUBE_DIMNL_MAPPINGS.CUBE_MAP_NAME is
'Name of the OLAP Cube Map that contains the dimensionality mapping'
/
comment on column DBA_CUBE_DIMNL_MAPPINGS.MAP_NAME is
'Name of the OLAP Cube Dimensionality Mapping'
/
comment on column DBA_CUBE_DIMNL_MAPPINGS.MAP_ID is
'Dictionary Id of the OLAP Cube Dimensionality Mapping'
/
comment on column DBA_CUBE_DIMNL_MAPPINGS.MAPPED_DIMENSION_NAME is
'Name of the mapped dimension of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMNL_MAPPINGS.MAPPED_HIERARCHY_NAME is
'Name of the mapped hierarchy of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMNL_MAPPINGS.MAPPED_LEVEL_NAME is
'Name of the mapped dimension level of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMNL_MAPPINGS.MAPPED_DIMENSION_TYPE is
'Text value indicating the type of the mapped dimension object'
/
comment on column DBA_CUBE_DIMNL_MAPPINGS.JOIN_CONDITION is
'Join condition of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMNL_MAPPINGS.LEVEL_ID_EXPRESSION is
'Level ID expression of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMNL_MAPPINGS.DIMENSIONALITY_EXPRESSION is
'Dimensionality expression of the OLAP Cube Dimensionality'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIMNL_MAPPINGS
FOR SYS.DBA_CUBE_DIMNL_MAPPINGS
/
GRANT SELECT ON DBA_CUBE_DIMNL_MAPPINGS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_DIMNL_MAPPINGS','CDB_CUBE_DIMNL_MAPPINGS');
create or replace public synonym CDB_CUBE_DIMNL_MAPPINGS for sys.CDB_CUBE_DIMNL_MAPPINGS;
grant select on CDB_CUBE_DIMNL_MAPPINGS to select_catalog_role;

create or replace view ALL_CUBE_DIMNL_MAPPINGS
as
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  owner_map.map_name CUBE_MAP_NAME,
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  o2.name  MAPPED_DIMENSION_NAME,
  CASE m.mapped_dim_type
  WHEN 14 -- hier_level
  THEN (SELECT h.hierarchy_name
        FROM olap_hier_levels$ hl, olap_hierarchies$ h             
        WHERE m.mapped_dim_id = hl.hierarchy_level_id
              AND hl.hierarchy_id = h.hierarchy_id                            
        )  
  WHEN 13 -- hierarchy
  THEN (SELECT h.hierarchy_name
        FROM olap_hierarchies$ h
        WHERE m.mapped_dim_id = h.hierarchy_id
       )
  ELSE null END AS MAPPED_HIERARCHY_NAME,
  CASE m.mapped_dim_type
  WHEN 12 -- dim_level
  THEN (SELECT dl.level_name 
        FROM olap_dim_levels$ dl
        WHERE m.mapped_dim_id = dl.level_id 
        )
  WHEN 14 -- hier_level
  THEN (SELECT dl.level_name
        FROM olap_dim_levels$ dl, olap_hier_levels$ hl, olap_hierarchies$ h
        WHERE m.mapped_dim_id = hl.hierarchy_level_id
              AND hl.hierarchy_id = h.hierarchy_id
              AND hl.dim_level_id = dl.level_id  
        )  
  ELSE null END AS MAPPED_LEVEL_NAME,
  decode(m.mapped_dim_type, '12', 'DIMENSION LEVEL',
                            '11', 'PRIMARY DIMENSION',
                            '14', 'HIERARCHY LEVEL',
                            '13', 'HIERARCHY') MAPPED_DIMENSION_TYPE,
  s1.syntax_clob JOIN_CONDITION,
  s2.syntax_clob LEVEL_ID_EXPRESSION,
  s3.syntax_clob DIMENSIONALITY_EXPRESSION
FROM 
  olap_mappings$ m,
  olap_mappings$ owner_map,
  user$ u,
  olap_dimensionality$ diml,
  obj$ o,
  obj$ o2,
  olap_syntax$ s1,
  olap_syntax$ s2, 
  olap_syntax$ s3,
 (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE 
  m.map_type = 23
  AND m.mapped_object_id = diml.dimensionality_id
  AND m.mapping_owner_id = owner_map.map_id
  AND diml.dimensioned_object_id = o.obj#
  AND o.obj# = da.obj#(+)
  AND o.owner# = u.user#
  AND diml.dimension_id = o2.obj#(+)
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 7
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 8
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 15
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
/

comment on table ALL_CUBE_DIMNL_MAPPINGS is
'OLAP Cube Dimenisonality Mappings in the database that are accessible to the user'
/
comment on column ALL_CUBE_DIMNL_MAPPINGS.OWNER is
'Owner of the OLAP Cube that contains the dimensionality'
/
comment on column ALL_CUBE_DIMNL_MAPPINGS.CUBE_NAME is
'Name of the OLAP Cube that contains the dimensionality'
/
comment on column ALL_CUBE_DIMNL_MAPPINGS.CUBE_MAP_NAME is
'Name of the OLAP Cube Map that contains the dimensionality mapping'
/
comment on column ALL_CUBE_DIMNL_MAPPINGS.MAP_NAME is
'Name of the OLAP Cube Dimensionality Mapping'
/
comment on column ALL_CUBE_DIMNL_MAPPINGS.MAP_ID is
'Dictionary Id of the OLAP Cube Dimensionality Mapping'
/
comment on column ALL_CUBE_DIMNL_MAPPINGS.MAPPED_DIMENSION_NAME is
'Name of the mapped dimension of the OLAP Cube Dimensionality'
/
comment on column ALL_CUBE_DIMNL_MAPPINGS.MAPPED_HIERARCHY_NAME is
'Name of the mapped hierarchy of the OLAP Cube Dimensionality'
/
comment on column ALL_CUBE_DIMNL_MAPPINGS.MAPPED_LEVEL_NAME is
'Name of the mapped dimension level of the OLAP Cube Dimensionality'
/
comment on column ALL_CUBE_DIMNL_MAPPINGS.MAPPED_DIMENSION_TYPE is
'Text value indicating the type of the mapped dimension object'
/
comment on column ALL_CUBE_DIMNL_MAPPINGS.JOIN_CONDITION is
'Join condition of the OLAP Cube Dimensionality'
/
comment on column ALL_CUBE_DIMNL_MAPPINGS.LEVEL_ID_EXPRESSION is
'Level ID expression of the OLAP Cube Dimensionality'
/
comment on column ALL_CUBE_DIMNL_MAPPINGS.DIMENSIONALITY_EXPRESSION is
'Dimensionality expression of the OLAP Cube Dimensionality'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIMNL_MAPPINGS
FOR SYS.ALL_CUBE_DIMNL_MAPPINGS
/
GRANT READ ON ALL_CUBE_DIMNL_MAPPINGS to public
/

create or replace view USER_CUBE_DIMNL_MAPPINGS
as
SELECT 
  o.name CUBE_NAME,
  owner_map.map_name CUBE_MAP_NAME,
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  o2.name MAPPED_DIMENSION_NAME,
  CASE m.mapped_dim_type
  WHEN 14 -- hier_level
  THEN (SELECT h.hierarchy_name
        FROM olap_hier_levels$ hl, olap_hierarchies$ h             
        WHERE m.mapped_dim_id = hl.hierarchy_level_id
              AND hl.hierarchy_id = h.hierarchy_id                            
        )  
  WHEN 13 -- hierarchy
  THEN (SELECT h.hierarchy_name
        FROM olap_hierarchies$ h
        WHERE m.mapped_dim_id = h.hierarchy_id
       )
  ELSE null END AS MAPPED_HIERARCHY_NAME,
  CASE m.mapped_dim_type
  WHEN 12 -- dim_level
  THEN (SELECT dl.level_name 
        FROM olap_dim_levels$ dl
        WHERE m.mapped_dim_id = dl.level_id 
        )
  WHEN 14 -- hier_level
  THEN (SELECT dl.level_name
        FROM olap_dim_levels$ dl, olap_hier_levels$ hl, olap_hierarchies$ h
        WHERE m.mapped_dim_id = hl.hierarchy_level_id
              AND hl.hierarchy_id = h.hierarchy_id
              AND hl.dim_level_id = dl.level_id  
        )  
  ELSE null END AS MAPPED_LEVEL_NAME,
  decode(m.mapped_dim_type, '12', 'DIMENSION LEVEL',
                            '11', 'PRIMARY DIMENSION',
                            '14', 'HIERARCHY LEVEL',
                            '13', 'HIERARCHY') MAPPED_DIMENSION_TYPE,
  s1.syntax_clob JOIN_CONDITION,
  s2.syntax_clob LEVEL_ID_EXPRESSION,
  s3.syntax_clob DIMENSIONALITY_EXPRESSION
FROM 
  olap_mappings$ m,
  olap_mappings$ owner_map,
  olap_dimensionality$ diml,
  obj$ o,
  obj$ o2,
  olap_syntax$ s1,
  olap_syntax$ s2, 
  olap_syntax$ s3
WHERE 
  m.map_type = 23
  AND m.mapped_object_id = diml.dimensionality_id
  AND m.mapping_owner_id = owner_map.map_id
  AND diml.dimensioned_object_id = o.obj#
  AND diml.dimension_id = o2.obj#(+)
  AND o.owner#=USERENV('SCHEMAID')   
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 7
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 8
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 15
/

comment on table USER_CUBE_DIMNL_MAPPINGS is
'OLAP Cube Dimenisonality Mappings owned by the user in the database'
/
comment on column USER_CUBE_DIMNL_MAPPINGS.CUBE_NAME is
'Name of the OLAP Cube that contains the dimensionality'
/
comment on column USER_CUBE_DIMNL_MAPPINGS.CUBE_MAP_NAME is
'Name of the OLAP Cube Map that contains the dimensionality mapping'
/
comment on column USER_CUBE_DIMNL_MAPPINGS.MAP_NAME is
'Name of the OLAP Cube Dimensionality Mapping'
/
comment on column USER_CUBE_DIMNL_MAPPINGS.MAP_ID is
'Dictionary Id of the OLAP Cube Dimensionality Mapping'
/
comment on column USER_CUBE_DIMNL_MAPPINGS.MAPPED_DIMENSION_NAME is
'Name of the mapped dimension of the OLAP Cube Dimensionality'
/
comment on column USER_CUBE_DIMNL_MAPPINGS.MAPPED_HIERARCHY_NAME is
'Name of the mapped hierarchy of the OLAP Cube Dimensionality'
/
comment on column USER_CUBE_DIMNL_MAPPINGS.MAPPED_LEVEL_NAME is
'Name of the mapped dimension level of the OLAP Cube Dimensionality'
/
comment on column USER_CUBE_DIMNL_MAPPINGS.MAPPED_DIMENSION_TYPE is
'Text value indicating the type of the mapped dimension object'
/
comment on column USER_CUBE_DIMNL_MAPPINGS.JOIN_CONDITION is
'Join condition of the OLAP Cube Dimensionality'
/
comment on column USER_CUBE_DIMNL_MAPPINGS.LEVEL_ID_EXPRESSION is
'Level ID expression of the OLAP Cube Dimensionality'
/
comment on column USER_CUBE_DIMNL_MAPPINGS.DIMENSIONALITY_EXPRESSION is
'Dimensionality expression of the OLAP Cube Dimensionality'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIMNL_MAPPINGS
FOR SYS.USER_CUBE_DIMNL_MAPPINGS
/
GRANT READ ON USER_CUBE_DIMNL_MAPPINGS to public
/

-- OLAP_MAPPINGS$ DATA DICTIONARY VIEWS for CUBE DIMENSION MAPPINGS --

create or replace view DBA_CUBE_DIM_MAPPINGS
as
SELECT
  u.name OWNER, 
  o.name DIMENSION_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,   
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  'DIMENSION LEVEL' MAPPED_DIMENSION_TYPE,
  null MAPPED_HIERARCHY_TYPE,   
  s1.syntax_clob QUERY,
  s2.syntax_clob KEY_EXPRESSION,
  s3.syntax_clob FROM_CLAUSE,
  s4.syntax_clob WHERE_CLAUSE,
  null JOIN_CONDITION,
  null LEVEL_ID_EXPRESSION,
  null PARENT_EXPRESSION,
  null PARENT_LEVEL_ID_EXPRESSION,
  null LEVEL_EXPRESSION
FROM
  olap_mappings$ m,
  user$ u,
  obj$ o, 
  olap_dim_levels$ dl,
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_syntax$ s4
WHERE
  m.map_type in (18, 19, 20, 21)
  AND m.mapping_owner_type = 12 -- dim_level
  AND m.mapping_owner_id = dl.level_id
  AND dl.dim_obj# = o.obj#
  AND o.owner#=u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 6
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = s4.owner_id(+) 
  AND m.map_type = s4.owner_type(+)
  AND s4.ref_role(+) = 21
UNION ALL
SELECT
  u.name OWNER, 
  o.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,   
  m.map_name MAP_NAME, 
  m.map_id MAP_ID,
  'HIERARCHY LEVEL' MAPPED_DIMENSION_TYPE,
  DECODE(h.hierarchy_type, 1, 'LEVEL', 2, 'VALUE') MAPPED_HIERARCHY_TYPE,   
  s1.syntax_clob QUERY,
  s2.syntax_clob KEY_EXPRESSION,
  s3.syntax_clob FROM_CLAUSE,
  s4.syntax_clob WHERE_CLAUSE,
  s5.syntax_clob JOIN_CONDITION,
  null LEVEL_ID_EXPRESSION,
  null PARENT_EXPRESSION,
  null PARENT_LEVEL_ID_EXPRESSION,
  null LEVEL_EXPRESSION
FROM
  olap_mappings$ m,
  user$ u,
  obj$ o, 
  olap_dim_levels$ dl,
  olap_hier_levels$ hl,
  olap_hierarchies$ h,
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_syntax$ s4,
  olap_syntax$ s5
WHERE
  m.map_type in (18, 19, 20, 21)
  AND m.mapping_owner_type = 14 -- hier_level
  AND m.mapping_owner_id = hl.hierarchy_level_id
  AND hl.dim_level_id = dl.level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner#=u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 6
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = s4.owner_id(+) 
  AND m.map_type = s4.owner_type(+)
  AND s4.ref_role(+) = 21
  AND m.map_id = s5.owner_id(+) 
  AND m.map_type = s5.owner_type(+)
  AND s5.ref_role(+) = 7
UNION ALL
SELECT
  u.name OWNER, 
  o.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,   
  m.map_name MAP_NAME, 
  m.map_id MAP_ID,
  'HIERARCHY' MAPPED_DIMENSION_TYPE,
  DECODE(h.hierarchy_type, 1, 'LEVEL', 2, 'VALUE') MAPPED_HIERARCHY_TYPE,
  s1.syntax_clob QUERY,
  s2.syntax_clob KEY_EXPRESSION,
  s3.syntax_clob FROM_CLAUSE,
  s4.syntax_clob WHERE_CLAUSE,
  null JOIN_CONDITION,
  s5.syntax_clob LEVEL_ID_EXPRESSION,
  s6.syntax_clob PARENT_EXPRESSION,
  s7.syntax_clob PARENT_LEVEL_ID_EXPRESSION,
  s8.syntax_clob LEVEL_EXPRESSION
FROM 
  olap_mappings$ m,
  user$ u, 
  obj$ o, 
  olap_hierarchies$ h,
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_syntax$ s4,
  olap_syntax$ s5,
  olap_syntax$ s6,
  olap_syntax$ s7,
  olap_syntax$ s8
WHERE
  m.map_type in (18, 19, 20, 21)
  AND m.mapping_owner_type = 13 -- hierarchy
  AND m.mapping_owner_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner#=u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 6
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = s4.owner_id(+) 
  AND m.map_type = s4.owner_type(+)
  AND s4.ref_role(+) = 21
  AND m.map_id = s5.owner_id(+) 
  AND m.map_type = s5.owner_type(+)
  AND s5.ref_role(+) = 8
  AND m.map_id = s6.owner_id(+) 
  AND m.map_type = s6.owner_type(+)
  AND s6.ref_role(+) = 9
  AND m.map_id = s7.owner_id(+) 
  AND m.map_type = s7.owner_type(+)
  AND s7.ref_role(+) = 10
  AND m.map_id = s8.owner_id(+) 
  AND m.map_type = s8.owner_type(+)
  AND s8.ref_role(+) = 11
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  null HIERARCHY_NAME,
  null LEVEL_NAME,   
  m.map_name MAP_NAME, 
  m.map_id MAP_ID,
  'PRIMARY DIMENSION' MAPPED_DIMENSION_TYPE,
  null MAPPED_HIERARCHY_TYPE,
  s1.syntax_clob QUERY,
  s2.syntax_clob KEY_EXPRESSION,
  s3.syntax_clob FROM_CLAUSE,
  s4.syntax_clob WHERE_CLAUSE,
  null JOIN_CONDITION,
  null LEVEL_ID_EXPRESSION,
  null PARENT_EXPRESSION,
  null PARENT_LEVEL_ID_EXPRESSION,
  null LEVEL_EXPRESSION
FROM
  olap_mappings$ m,
  user$ u, 
  obj$ o, 
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_syntax$ s4
WHERE
  m.map_type in (18, 19, 20, 21)
  AND m.mapping_owner_type = 11 -- dimension
  AND m.mapping_owner_id = o.obj#
  AND o.owner#=u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 6
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = s4.owner_id(+) 
  AND m.map_type = s4.owner_type(+)
  AND s4.ref_role(+) = 21
/

comment on table DBA_CUBE_DIM_MAPPINGS is
'OLAP Cube Dimension Mappings in the database'
/
comment on column DBA_CUBE_DIM_MAPPINGS.OWNER is
'Owner of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIM_MAPPINGS.DIMENSION_NAME is
'Name of the OLAP Cube Dimension that contains the mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.HIERARCHY_NAME is
'Name of the OLAP Cube Hierarchy that contains the mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.LEVEL_NAME is
'Name of the OLAP Cube Dimension Level that contains the mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.MAP_NAME is
'Name of the OLAP Cube Dimension Mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.MAP_ID is
'Dictionary Id of the OLAP Cube Dimension Mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.MAPPED_DIMENSION_TYPE is
'Text value indicating the type of the OLAP Dimension that contains the mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.MAPPED_HIERARCHY_TYPE is
'Text value indicating the type of the OLAP Hierarchy that contains the mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.QUERY is
'Query of the OLAP Cube Dimension Mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.KEY_EXPRESSION is
'Key expression of the OLAP Cube Dimension Mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.FROM_CLAUSE is
'From clause of the OLAP Cube Dimension Mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.WHERE_CLAUSE is
'Where clause of the OLAP Cube Dimension Mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.JOIN_CONDITION is
'Join condition of the OLAP Cube Dimension Mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.LEVEL_ID_EXPRESSION is
'Level ID expression of the OLAP Cube Dimension Mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.PARENT_EXPRESSION is
'Parent expression of the OLAP Cube Dimension Mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.PARENT_LEVEL_ID_EXPRESSION is
'Parent level ID expression of the OLAP Cube Dimension Mapping'
/
comment on column DBA_CUBE_DIM_MAPPINGS.LEVEL_EXPRESSION is
'Level expression of the OLAP Cube Dimension Mapping'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIM_MAPPINGS
FOR SYS.DBA_CUBE_DIM_MAPPINGS
/
GRANT SELECT ON DBA_CUBE_DIM_MAPPINGS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_DIM_MAPPINGS','CDB_CUBE_DIM_MAPPINGS');
create or replace public synonym CDB_CUBE_DIM_MAPPINGS for sys.CDB_CUBE_DIM_MAPPINGS;
grant select on CDB_CUBE_DIM_MAPPINGS to select_catalog_role;

create or replace view ALL_CUBE_DIM_MAPPINGS
as
SELECT
  u.name OWNER, 
  o.name DIMENSION_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,   
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  'DIMENSION LEVEL' MAPPED_DIMENSION_TYPE,
  null MAPPED_HIERARCHY_TYPE,   
  s1.syntax_clob QUERY,
  s2.syntax_clob KEY_EXPRESSION,
  s3.syntax_clob FROM_CLAUSE,
  s4.syntax_clob WHERE_CLAUSE,
  null JOIN_CONDITION,
  null LEVEL_ID_EXPRESSION,
  null PARENT_EXPRESSION,
  null PARENT_LEVEL_ID_EXPRESSION,
  null LEVEL_EXPRESSION
FROM
  olap_mappings$ m,
  user$ u,
  obj$ o, 
  olap_dim_levels$ dl,
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_syntax$ s4
WHERE
  m.map_type in (18, 19, 20, 21)
  AND m.mapping_owner_type = 12 -- dim_level
  AND m.mapping_owner_id = dl.level_id
  AND dl.dim_obj# = o.obj#
  AND o.owner#=u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 6
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = s4.owner_id(+) 
  AND m.map_type = s4.owner_type(+)
  AND s4.ref_role(+) = 21
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER, 
  o.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,   
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  'HIERARCHY LEVEL' MAPPED_DIMENSION_TYPE,
  DECODE(h.hierarchy_type, 1, 'LEVEL', 2, 'VALUE') MAPPED_HIERARCHY_TYPE,   
  s1.syntax_clob QUERY,
  s2.syntax_clob KEY_EXPRESSION,
  s3.syntax_clob FROM_CLAUSE,
  s4.syntax_clob WHERE_CLAUSE,
  s5.syntax_clob JOIN_CONDITION,
  null LEVEL_ID_EXPRESSION,
  null PARENT_EXPRESSION,
  null PARENT_LEVEL_ID_EXPRESSION,
  null LEVEL_EXPRESSION
FROM
  olap_mappings$ m,
  user$ u,
  obj$ o, 
  olap_dim_levels$ dl,
  olap_hier_levels$ hl,
  olap_hierarchies$ h,
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_syntax$ s4,
  olap_syntax$ s5
WHERE
  m.map_type in (18, 19, 20, 21)
  AND m.mapping_owner_type = 14 -- hier_level
  AND m.mapping_owner_id = hl.hierarchy_level_id
  AND hl.dim_level_id = dl.level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner#=u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 6
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = s4.owner_id(+) 
  AND m.map_type = s4.owner_type(+)
  AND s4.ref_role(+) = 21
  AND m.map_id = s5.owner_id(+) 
  AND m.map_type = s5.owner_type(+)
  AND s5.ref_role(+) = 7
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER, 
  o.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,   
  m.map_name MAP_NAME, 
  m.map_id MAP_ID,
  'HIERARCHY' MAPPED_DIMENSION_TYPE,
  DECODE(h.hierarchy_type, 1, 'LEVEL', 2, 'VALUE') MAPPED_HIERARCHY_TYPE,
  s1.syntax_clob QUERY,
  s2.syntax_clob KEY_EXPRESSION,
  s3.syntax_clob FROM_CLAUSE,
  s4.syntax_clob WHERE_CLAUSE,
  null JOIN_CONDITION,
  s5.syntax_clob LEVEL_ID_EXPRESSION,
  s6.syntax_clob PARENT_EXPRESSION,
  s7.syntax_clob PARENT_LEVEL_ID_EXPRESSION,
  s8.syntax_clob LEVEL_EXPRESSION
FROM 
  olap_mappings$ m,
  user$ u, 
  obj$ o, 
  olap_hierarchies$ h,
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_syntax$ s4,
  olap_syntax$ s5,
  olap_syntax$ s6,
  olap_syntax$ s7,
  olap_syntax$ s8
WHERE
  m.map_type in (18, 19, 20, 21)
  AND m.mapping_owner_type = 13 -- hierarchy
  AND m.mapping_owner_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner#=u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 6
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = s4.owner_id(+) 
  AND m.map_type = s4.owner_type(+)
  AND s4.ref_role(+) = 21
  AND m.map_id = s5.owner_id(+) 
  AND m.map_type = s5.owner_type(+)
  AND s5.ref_role(+) = 8
  AND m.map_id = s6.owner_id(+) 
  AND m.map_type = s6.owner_type(+)
  AND s6.ref_role(+) = 9
  AND m.map_id = s7.owner_id(+) 
  AND m.map_type = s7.owner_type(+)
  AND s7.ref_role(+) = 10
  AND m.map_id = s8.owner_id(+) 
  AND m.map_type = s8.owner_type(+)
  AND s8.ref_role(+) = 11
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  null HIERARCHY_NAME,
  null LEVEL_NAME,   
  m.map_name MAP_NAME, 
  m.map_id MAP_ID,
  'PRIMARY DIMENSION' MAPPED_DIMENSION_TYPE,
  null MAPPED_HIERARCHY_TYPE,
  s1.syntax_clob QUERY,
  s2.syntax_clob KEY_EXPRESSION,
  s3.syntax_clob FROM_CLAUSE,
  s4.syntax_clob WHERE_CLAUSE,
  null JOIN_CONDITION,
  null LEVEL_ID_EXPRESSION,
  null PARENT_EXPRESSION,
  null PARENT_LEVEL_ID_EXPRESSION,
  null LEVEL_EXPRESSION
FROM
  olap_mappings$ m,
  user$ u, 
  obj$ o, 
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_syntax$ s4
WHERE
  m.map_type in (18, 19, 20, 21)
  AND m.mapping_owner_type = 11 -- dimension
  AND m.mapping_owner_id = o.obj#
  AND o.owner#=u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 6
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = s4.owner_id(+) 
  AND m.map_type = s4.owner_type(+)
  AND s4.ref_role(+) = 21
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_CUBE_DIM_MAPPINGS is
'OLAP Cube Dimension Mappings in the database that are accessible to the user'
/
comment on column ALL_CUBE_DIM_MAPPINGS.OWNER is
'Owner of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIM_MAPPINGS.DIMENSION_NAME is
'Name of the OLAP Cube Dimension that contains the mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.HIERARCHY_NAME is
'Name of the OLAP Cube Hierarchy that contains the mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.LEVEL_NAME is
'Name of the OLAP Cube Dimension Level that contains the mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.MAP_NAME is
'Name of the OLAP Cube Dimension Mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.MAP_ID is
'Dictionary Id of the OLAP Cube Dimension Mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.MAPPED_DIMENSION_TYPE is
'Text value indicating the type of the OLAP Dimension that contains the mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.MAPPED_HIERARCHY_TYPE is
'Text value indicating the type of the OLAP Hierarchy that contains the mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.QUERY is
'Query of the OLAP Cube Dimension Mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.KEY_EXPRESSION is
'Key expression of the OLAP Cube Dimension Mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.FROM_CLAUSE is
'From clause of the OLAP Cube Dimension Mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.WHERE_CLAUSE is
'Where clause of the OLAP Cube Dimension Mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.JOIN_CONDITION is
'Join condition of the OLAP Cube Dimension Mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.LEVEL_ID_EXPRESSION is
'Level ID expression of the OLAP Cube Dimension Mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.PARENT_EXPRESSION is
'Parent expression of the OLAP Cube Dimension Mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.PARENT_LEVEL_ID_EXPRESSION is
'Parent level ID expression of the OLAP Cube Dimension Mapping'
/
comment on column ALL_CUBE_DIM_MAPPINGS.LEVEL_EXPRESSION is
'Level expression of the OLAP Cube Dimension Mapping'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIM_MAPPINGS
FOR SYS.ALL_CUBE_DIM_MAPPINGS
/
GRANT READ ON ALL_CUBE_DIM_MAPPINGS to public
/

create or replace view USER_CUBE_DIM_MAPPINGS
as
SELECT
  o.name DIMENSION_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,   
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  'DIMENSION LEVEL' MAPPED_DIMENSION_TYPE,
  null MAPPED_HIERARCHY_TYPE,   
  s1.syntax_clob QUERY,
  s2.syntax_clob KEY_EXPRESSION,
  s3.syntax_clob FROM_CLAUSE,
  s4.syntax_clob WHERE_CLAUSE,
  null JOIN_CONDITION,
  null LEVEL_ID_EXPRESSION,
  null PARENT_EXPRESSION,
  null PARENT_LEVEL_ID_EXPRESSION,
  null LEVEL_EXPRESSION
FROM
  olap_mappings$ m,
  obj$ o, 
  olap_dim_levels$ dl,
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_syntax$ s4
WHERE
  m.map_type in (18, 19, 20, 21)
  AND m.mapping_owner_type = 12 -- dim_level
  AND m.mapping_owner_id = dl.level_id
  AND dl.dim_obj# = o.obj#
  AND o.owner#=USERENV('SCHEMAID')
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 6
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = s4.owner_id(+) 
  AND m.map_type = s4.owner_type(+)
  AND s4.ref_role(+) = 21
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,   
  m.map_name MAP_NAME, 
  m.map_id MAP_ID,
  'HIERARCHY LEVEL' MAPPED_DIMENSION_TYPE,
  DECODE(h.hierarchy_type, 1, 'LEVEL', 2, 'VALUE') MAPPED_HIERARCHY_TYPE,   
  s1.syntax_clob QUERY,
  s2.syntax_clob KEY_EXPRESSION,
  s3.syntax_clob FROM_CLAUSE,
  s4.syntax_clob WHERE_CLAUSE,
  s5.syntax_clob JOIN_CONDITION,
  null LEVEL_ID_EXPRESSION,
  null PARENT_EXPRESSION,
  null PARENT_LEVEL_ID_EXPRESSION,
  null LEVEL_EXPRESSION
FROM
  olap_mappings$ m,
  obj$ o, 
  olap_dim_levels$ dl,
  olap_hier_levels$ hl,
  olap_hierarchies$ h,
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_syntax$ s4,
  olap_syntax$ s5
WHERE
  m.map_type in (18, 19, 20, 21)
  AND m.mapping_owner_type = 14 -- hier_level
  AND m.mapping_owner_id = hl.hierarchy_level_id
  AND hl.dim_level_id = dl.level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner#=USERENV('SCHEMAID')
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 6
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = s4.owner_id(+) 
  AND m.map_type = s4.owner_type(+)
  AND s4.ref_role(+) = 21
  AND m.map_id = s5.owner_id(+) 
  AND m.map_type = s5.owner_type(+)
  AND s5.ref_role(+) = 7
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,   
  m.map_name MAP_NAME, 
  m.map_id MAP_ID,
  'HIERARCHY' MAPPED_DIMENSION_TYPE,
  DECODE(h.hierarchy_type, 1, 'LEVEL', 2, 'VALUE') MAPPED_HIERARCHY_TYPE,
  s1.syntax_clob QUERY,
  s2.syntax_clob KEY_EXPRESSION,
  s3.syntax_clob FROM_CLAUSE,
  s4.syntax_clob WHERE_CLAUSE,
  null JOIN_CONDITION,
  s5.syntax_clob LEVEL_ID_EXPRESSION,
  s6.syntax_clob PARENT_EXPRESSION,
  s7.syntax_clob PARENT_LEVEL_ID_EXPRESSION,
  s8.syntax_clob LEVEL_EXPRESSION
FROM 
  olap_mappings$ m,
  obj$ o, 
  olap_hierarchies$ h,
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_syntax$ s4,
  olap_syntax$ s5,
  olap_syntax$ s6,
  olap_syntax$ s7,
  olap_syntax$ s8
WHERE
  m.map_type in (18, 19, 20, 21)
  AND m.mapping_owner_type = 13 -- hierarchy
  AND m.mapping_owner_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner#=USERENV('SCHEMAID')
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 6
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = s4.owner_id(+) 
  AND m.map_type = s4.owner_type(+)
  AND s4.ref_role(+) = 21
  AND m.map_id = s5.owner_id(+) 
  AND m.map_type = s5.owner_type(+)
  AND s5.ref_role(+) = 8
  AND m.map_id = s6.owner_id(+) 
  AND m.map_type = s6.owner_type(+)
  AND s6.ref_role(+) = 9
  AND m.map_id = s7.owner_id(+) 
  AND m.map_type = s7.owner_type(+)
  AND s7.ref_role(+) = 10
  AND m.map_id = s8.owner_id(+) 
  AND m.map_type = s8.owner_type(+)
  AND s8.ref_role(+) = 11
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  null HIERARCHY_NAME,
  null LEVEL_NAME,   
  m.map_name MAP_NAME, 
  m.map_id MAP_ID,
  'PRIMARY DIMENSION' MAPPED_DIMENSION_TYPE,
  null MAPPED_HIERARCHY_TYPE,
  s1.syntax_clob QUERY,
  s2.syntax_clob KEY_EXPRESSION,
  s3.syntax_clob FROM_CLAUSE,
  s4.syntax_clob WHERE_CLAUSE,
  null JOIN_CONDITION,
  null LEVEL_ID_EXPRESSION,
  null PARENT_EXPRESSION,
  null PARENT_LEVEL_ID_EXPRESSION,
  null LEVEL_EXPRESSION
FROM
  olap_mappings$ m,
  obj$ o, 
  olap_syntax$ s1, 
  olap_syntax$ s2, 
  olap_syntax$ s3,
  olap_syntax$ s4
WHERE
  m.map_type in (18, 19, 20, 21)
  AND m.mapping_owner_type = 11 -- dimension
  AND m.mapping_owner_id = o.obj#
  AND o.owner#=USERENV('SCHEMAID')
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 3
  AND m.map_id = s2.owner_id(+) 
  AND m.map_type = s2.owner_type(+)
  AND s2.ref_role(+) = 6
  AND m.map_id = s3.owner_id(+) 
  AND m.map_type = s3.owner_type(+)
  AND s3.ref_role(+) = 22
  AND m.map_id = s4.owner_id(+) 
  AND m.map_type = s4.owner_type(+)
  AND s4.ref_role(+) = 21
/

comment on table USER_CUBE_DIM_MAPPINGS is
'OLAP Cube Dimension Mappings owned by the user in the database'
/
comment on column USER_CUBE_DIM_MAPPINGS.DIMENSION_NAME is
'Name of the OLAP Cube Dimension that contains the mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.HIERARCHY_NAME is
'Name of the OLAP Cube Hierarchy that contains the mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.LEVEL_NAME is
'Name of the OLAP Cube Dimension Level that contains the mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.MAP_NAME is
'Name of the OLAP Cube Dimension Mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.MAP_ID is
'Dictionary Id of the OLAP Cube Dimension Mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.MAPPED_DIMENSION_TYPE is
'Text value indicating the type of the OLAP Dimension that contains the mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.MAPPED_HIERARCHY_TYPE is
'Text value indicating the type of the OLAP Hierarchy that contains the mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.QUERY is
'Query of the OLAP Cube Dimension Mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.KEY_EXPRESSION is
'Key expression of the OLAP Cube Dimension Mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.FROM_CLAUSE is
'From clause of the OLAP Cube Dimension Mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.WHERE_CLAUSE is
'Where clause of the OLAP Cube Dimension Mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.JOIN_CONDITION is
'Join condition of the OLAP Cube Dimension Mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.LEVEL_ID_EXPRESSION is
'Level ID expression of the OLAP Cube Dimension Mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.PARENT_EXPRESSION is
'Parent expression of the OLAP Cube Dimension Mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.PARENT_LEVEL_ID_EXPRESSION is
'Parent level ID expression of the OLAP Cube Dimension Mapping'
/
comment on column USER_CUBE_DIM_MAPPINGS.LEVEL_EXPRESSION is
'Level expression of the OLAP Cube Dimension Mapping'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIM_MAPPINGS
FOR SYS.USER_CUBE_DIM_MAPPINGS
/
GRANT READ ON USER_CUBE_DIM_MAPPINGS to public
/

-- OLAP_MAPPINGS$ DATA DICTIONARY VIEWS for CUBE ATTRIBUTE MAPPINGS --

create or replace view DBA_CUBE_ATTR_MAPPINGS
as
SELECT
  u.name OWNER, 
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  decode(owner_map.mapping_owner_type, '12', 'DIMENSION LEVEL',
                            '11', 'PRIMARY DIMENSION',
                            '14', 'HIERARCHY LEVEL',
                            '13', 'HIERARCHY') OWNER_MAP_DIMENSION_TYPE,
  CASE owner_map.mapping_owner_type 
  WHEN 14  -- hier_level
  THEN (select h.hierarchy_name
        from olap_dim_levels$ dl,
             olap_hier_levels$ hl, olap_hierarchies$ h
        where owner_map.mapping_owner_id = hl.hierarchy_level_id
              AND hl.dim_level_id = dl.level_id
              AND hl.hierarchy_id = h.hierarchy_id)
  WHEN 13 -- hierarchy
  THEN (select h.hierarchy_name
        from olap_hierarchies$ h
        where owner_map.mapping_owner_id = h.hierarchy_id)
  ELSE NULL
  END AS OWNER_MAP_HIERARCHY_NAME,
  CASE owner_map.mapping_owner_type 
  WHEN 12 -- dim_level 
  THEN (select dl.level_name 
        from olap_dim_levels$ dl   
        where owner_map.mapping_owner_id = dl.level_id)
  WHEN 14  -- hier_level
  THEN (select dl.level_name
        from olap_dim_levels$ dl, olap_hier_levels$ hl
        where owner_map.mapping_owner_id = hl.hierarchy_level_id
              AND hl.dim_level_id = dl.level_id)
  ELSE NULL
  END AS OWNER_MAP_LEVEL_NAME,
  owner_map.map_name OWNER_MAP_NAME,
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  s1.syntax_clob ATTRIBUTE_EXPRESSION,
  i1.option_value LANGUAGE
FROM
  olap_mappings$ m,
  olap_mappings$ owner_map,
  obj$ o,
  user$ u,
  olap_attributes$ a,
  olap_syntax$ s1,
  olap_impl_options$ i1
WHERE
  m.map_type = 17
  AND m.mapping_owner_id = owner_map.map_id
  AND m.mapped_object_id = a.attribute_id
  AND a.dim_obj# = o.obj#
  AND o.owner#=u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 2
  AND m.map_id = i1.owning_objectid(+)
  AND i1.option_type(+) = 12
/

comment on table DBA_CUBE_ATTR_MAPPINGS is
'OLAP Cube Attribute Mappings in the database'
/
comment on column DBA_CUBE_ATTR_MAPPINGS.OWNER is
'Owner of the OLAP Cube Attribute'
/
comment on column DBA_CUBE_ATTR_MAPPINGS.DIMENSION_NAME is
'Name of the Cube Dimension of the Cube Attribute'
/
comment on column DBA_CUBE_ATTR_MAPPINGS.ATTRIBUTE_NAME is
'Name of the Cube Attribute'
/
comment on column DBA_CUBE_ATTR_MAPPINGS.OWNER_MAP_DIMENSION_TYPE is
'Text value indicating the type of the Cube Dimenension that owns the map 
that contains the Cube Attribute Mapping'
/
comment on column DBA_CUBE_ATTR_MAPPINGS.OWNER_MAP_HIERARCHY_NAME is
'Name of the Hierarchy of the Cube Dimension that owns the map 
that contains the Cube Attribute Mapping'
/
comment on column DBA_CUBE_ATTR_MAPPINGS.OWNER_MAP_LEVEL_NAME is
'Name of the Level of the Cube Dimension or Cube Hierarchy that owns the map 
that contains the Cube Attribute Mapping'
/
comment on column DBA_CUBE_ATTR_MAPPINGS.OWNER_MAP_NAME is
'Name of the map that contains the Cube Attribute Mapping'
/
comment on column DBA_CUBE_ATTR_MAPPINGS.MAP_NAME is
'Name of the Cube Attribute Mapping'
/
comment on column DBA_CUBE_ATTR_MAPPINGS.MAP_ID is
'Dictionary Id of the Cube Attribute Mapping'
/
comment on column DBA_CUBE_ATTR_MAPPINGS.ATTRIBUTE_EXPRESSION is
'Expression of the Cube Attribute Mapping'
/
comment on column DBA_CUBE_ATTR_MAPPINGS.LANGUAGE is
'Language of the Cube Attribute Mapping'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_ATTR_MAPPINGS
FOR SYS.DBA_CUBE_ATTR_MAPPINGS
/
GRANT SELECT ON DBA_CUBE_ATTR_MAPPINGS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_ATTR_MAPPINGS','CDB_CUBE_ATTR_MAPPINGS');
create or replace public synonym CDB_CUBE_ATTR_MAPPINGS for sys.CDB_CUBE_ATTR_MAPPINGS;
grant select on CDB_CUBE_ATTR_MAPPINGS to select_catalog_role;

create or replace view ALL_CUBE_ATTR_MAPPINGS
as
SELECT
  u.name OWNER, 
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  decode(owner_map.mapping_owner_type, '12', 'DIMENSION LEVEL',
                            '11', 'PRIMARY DIMENSION',
                            '14', 'HIERARCHY LEVEL',
                            '13', 'HIERARCHY') OWNER_MAP_DIMENSION_TYPE,
  CASE owner_map.mapping_owner_type 
  WHEN 14  -- hier_level
  THEN (select h.hierarchy_name
        from olap_dim_levels$ dl,
             olap_hier_levels$ hl, olap_hierarchies$ h
        where owner_map.mapping_owner_id = hl.hierarchy_level_id
              AND hl.dim_level_id = dl.level_id
              AND hl.hierarchy_id = h.hierarchy_id)
  WHEN 13 -- hierarchy
  THEN (select h.hierarchy_name
        from olap_hierarchies$ h
        where owner_map.mapping_owner_id = h.hierarchy_id)
  ELSE NULL
  END AS OWNER_MAP_HIERARCHY_NAME,
  CASE owner_map.mapping_owner_type 
  WHEN 12 -- dim_level 
  THEN (select dl.level_name 
        from olap_dim_levels$ dl   
        where owner_map.mapping_owner_id = dl.level_id)
  WHEN 14  -- hier_level
  THEN (select dl.level_name
        from olap_dim_levels$ dl, olap_hier_levels$ hl
        where owner_map.mapping_owner_id = hl.hierarchy_level_id
              AND hl.dim_level_id = dl.level_id)
  ELSE NULL
  END AS OWNER_MAP_LEVEL_NAME,
  owner_map.map_name OWNER_MAP_NAME,
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  s1.syntax_clob ATTRIBUTE_EXPRESSION,
  i1.option_value LANGUAGE
FROM
  olap_mappings$ m,
  olap_mappings$ owner_map,
  obj$ o,
  user$ u, 
  olap_attributes$ a,
  olap_syntax$ s1,
  olap_impl_options$ i1
WHERE
  m.map_type = 17
  AND m.mapping_owner_id = owner_map.map_id
  AND m.mapped_object_id = a.attribute_id
  AND a.dim_obj# = o.obj#
  AND o.owner#=u.user#
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 2
  AND m.map_id = i1.owning_objectid(+)
  AND i1.option_type(+) = 12
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_CUBE_ATTR_MAPPINGS is
'OLAP Cube Attribute Mappings in the database that are accessible by the user'
/
comment on column ALL_CUBE_ATTR_MAPPINGS.OWNER is
'Owner of the OLAP Cube Attribute'
/
comment on column ALL_CUBE_ATTR_MAPPINGS.DIMENSION_NAME is
'Name of the Cube Dimension of the Cube Attribute'
/
comment on column ALL_CUBE_ATTR_MAPPINGS.ATTRIBUTE_NAME is
'Name of the Cube Attribute'
/
comment on column ALL_CUBE_ATTR_MAPPINGS.OWNER_MAP_DIMENSION_TYPE is
'Text value indicating the type of the Cube Dimenension that owns the map 
that contains the Cube Attribute Mapping'
/
comment on column ALL_CUBE_ATTR_MAPPINGS.OWNER_MAP_HIERARCHY_NAME is
'Name of the Hierarchy of the Cube Dimension that owns the map 
that contains the Cube Attribute Mapping'
/
comment on column ALL_CUBE_ATTR_MAPPINGS.OWNER_MAP_LEVEL_NAME is
'Name of the Level of the Cube Dimension or Cube Hierarchy that owns the map 
that contains the Cube Attribute Mapping'
/
comment on column ALL_CUBE_ATTR_MAPPINGS.OWNER_MAP_NAME is
'Name of the map that contains the Cube Attribute Mapping'
/
comment on column ALL_CUBE_ATTR_MAPPINGS.MAP_NAME is
'Name of the Cube Attribute Mapping'
/
comment on column ALL_CUBE_ATTR_MAPPINGS.MAP_ID is
'Dictionary Id of the Cube Attribute Mapping'
/
comment on column ALL_CUBE_ATTR_MAPPINGS.ATTRIBUTE_EXPRESSION is
'Expression of the Cube Attribute Mapping'
/
comment on column ALL_CUBE_ATTR_MAPPINGS.LANGUAGE is
'Language of the Cube Attribute Mapping'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_ATTR_MAPPINGS
FOR SYS.ALL_CUBE_ATTR_MAPPINGS
/
GRANT READ ON ALL_CUBE_ATTR_MAPPINGS to public
/

create or replace view USER_CUBE_ATTR_MAPPINGS
as
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  decode(owner_map.mapping_owner_type, '12', 'DIMENSION LEVEL',
                            '11', 'PRIMARY DIMENSION',
                            '14', 'HIERARCHY LEVEL',
                            '13', 'HIERARCHY') OWNER_MAP_DIMENSION_TYPE,
  owner_map.map_name OWNER_MAP_NAME,
  CASE owner_map.mapping_owner_type 
  WHEN 14  -- hier_level
  THEN (select h.hierarchy_name
        from olap_dim_levels$ dl,
             olap_hier_levels$ hl, olap_hierarchies$ h
        where owner_map.mapping_owner_id = hl.hierarchy_level_id
              AND hl.dim_level_id = dl.level_id
              AND hl.hierarchy_id = h.hierarchy_id)
  WHEN 13 -- hierarchy
  THEN (select h.hierarchy_name
        from olap_hierarchies$ h
        where owner_map.mapping_owner_id = h.hierarchy_id)
  ELSE NULL
  END AS OWNER_MAP_HIERARCHY_NAME,
  CASE owner_map.mapping_owner_type 
  WHEN 12 -- dim_level 
  THEN (select dl.level_name 
        from olap_dim_levels$ dl   
        where owner_map.mapping_owner_id = dl.level_id)
  WHEN 14  -- hier_level
  THEN (select dl.level_name
        from olap_dim_levels$ dl, olap_hier_levels$ hl
        where owner_map.mapping_owner_id = hl.hierarchy_level_id
              AND hl.dim_level_id = dl.level_id)
  ELSE NULL
  END AS OWNER_MAP_LEVEL_NAME,
  m.map_name MAP_NAME,
  m.map_id MAP_ID,
  s1.syntax_clob ATTRIBUTE_EXPRESSION,
  i1.option_value LANGUAGE
FROM
  olap_mappings$ m,
  olap_mappings$ owner_map,
  obj$ o,
  olap_attributes$ a,
  olap_syntax$ s1,
  olap_impl_options$ i1
WHERE
  m.map_type = 17
  AND m.mapping_owner_id = owner_map.map_id
  AND m.mapped_object_id = a.attribute_id
  AND a.dim_obj# = o.obj#
  AND o.owner#=USERENV('SCHEMAID')
  AND m.map_id = s1.owner_id(+) 
  AND m.map_type = s1.owner_type(+)
  AND s1.ref_role(+) = 2
  AND m.map_id = i1.owning_objectid(+)
  AND i1.option_type(+) = 12
/

comment on table USER_CUBE_ATTR_MAPPINGS is
'OLAP Cube Attribute Mappings owned by the user in the database'
/
comment on column USER_CUBE_ATTR_MAPPINGS.DIMENSION_NAME is
'Name of the Cube Dimension of the Cube Attribute'
/
comment on column USER_CUBE_ATTR_MAPPINGS.ATTRIBUTE_NAME is
'Name of the Cube Attribute'
/
comment on column USER_CUBE_ATTR_MAPPINGS.OWNER_MAP_DIMENSION_TYPE is
'Text value indicating the type of the Cube Dimenension that owns the map 
that contains the Cube Attribute Mapping'
/
comment on column USER_CUBE_ATTR_MAPPINGS.OWNER_MAP_HIERARCHY_NAME is
'Name of the Hierarchy of the Cube Dimension that owns the map 
that contains the Cube Attribute Mapping'
/
comment on column USER_CUBE_ATTR_MAPPINGS.OWNER_MAP_LEVEL_NAME is
'Name of the Level of the Cube Dimension or Cube Hierarchy that owns the map 
that contains the Cube Attribute Mapping'
/
comment on column USER_CUBE_ATTR_MAPPINGS.OWNER_MAP_NAME is
'Name of the map that contains the Cube Attribute Mapping'
/
comment on column USER_CUBE_ATTR_MAPPINGS.MAP_NAME is
'Name of the Cube Attribute Mapping'
/
comment on column USER_CUBE_ATTR_MAPPINGS.MAP_ID is
'Dictionary Id of the Cube Attribute Mapping'
/
comment on column USER_CUBE_ATTR_MAPPINGS.ATTRIBUTE_EXPRESSION is
'Expression of the Cube Attribute Mapping'
/
comment on column USER_CUBE_ATTR_MAPPINGS.LANGUAGE is
'Language of the Cube Attribute Mapping'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_ATTR_MAPPINGS
FOR SYS.USER_CUBE_ATTR_MAPPINGS
/
GRANT READ ON USER_CUBE_ATTR_MAPPINGS to public
/

-- olap_descriptions$ DATA DICTIONARY VIEWS for CUBE DESCRIPTIONS --

create or replace view DBA_CUBE_DESCRIPTIONS
as
SELECT 
  u.name OWNER,
  CASE d.owning_object_type
  WHEN 4 -- ASSIGNMENT
  THEN (SELECT o.name || '.' || m.model_name || '.' || a.member_name
        FROM olap_model_assignments$ a, olap_models$ m, obj$ o
        WHERE d.owning_object_id = a.assignment_id
              AND m.model_id = a.model_id
              AND m.owning_obj_type = 11
              AND m.owning_obj_id = o.obj#
        )
  WHEN 3 -- model
  THEN (SELECT o.name || '.' || m.model_name
        FROM olap_models$ m, obj$ o
        WHERE d.owning_object_id = m.model_id
              AND m.owning_obj_type = 11
              AND m.owning_obj_id = o.obj#
        )
  WHEN 14 -- hier_level
  THEN (SELECT o.name || '.' || h.hierarchy_name || '.' || dl.level_name
        FROM olap_hier_levels$ hl, olap_dim_levels$ dl,
             olap_hierarchies$ h, obj$ o
        WHERE d.owning_object_id = hl.hierarchy_level_id
              AND hl.dim_level_id = dl.level_id
              AND hl.hierarchy_id = h.hierarchy_id
              AND h.dim_obj# = o.obj#
        )
  WHEN 13 -- hierarchy
  THEN (SELECT o.name || '.' || h.hierarchy_name
        FROM olap_hierarchies$ h, obj$ o
        WHERE d.owning_object_id = h.hierarchy_id
              AND h.dim_obj# = o.obj#
       )
  WHEN 12 -- dim_level
  THEN (SELECT o.name || '.' || dl.level_name
        FROM olap_dim_levels$ dl, obj$ o
        WHERE d.owning_object_id = dl.level_id
              AND dl.dim_obj# = o.obj#
       )
  WHEN 15 -- attribute
  THEN (SELECT o.name || '.' || a.attribute_name
        FROM olap_attributes$ a, obj$ o
        WHERE d.owning_object_id = a.attribute_id
              AND a.dim_obj# = o.obj#
       )
  WHEN 6 -- calc_member
  THEN (SELECT o.name || '.' || c.member_name
        FROM OLAP_CALCULATED_MEMBERS$ c, obj$ o            
        WHERE d.owning_object_id = c.member_id
              AND c.dim_obj# = o.obj#
       )
  WHEN 11 -- dimension
  THEN (SELECT o.name  
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  WHEN 2 -- measure
  THEN (SELECT o.name || '.' || m.measure_name
        FROM olap_measures$ m, olap_cubes$ c, obj$ o
        WHERE d.owning_object_id = m.measure_id
              AND m.cube_obj# = c.obj#
              AND c.obj# = o.obj#
        )
  WHEN 1 -- cube
  THEN (SELECT o.name 
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#              
       )
  WHEN 10 -- measure_folder
  THEN (SELECT o.name
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  WHEN 8 -- interaction
  THEN (SELECT o.name
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  ELSE null 
  END AS OBJECT_NAME,
  decode(d.owning_object_type, '4', 'ASSIGNMENT',
                               '3', 'MODEL',
                               '14', 'HIERARCHY LEVEL',  
                               '13', 'HIERARCHY',
                               '12', 'DIMENSION LEVEL',
                               '15', 'ATTRIBUTE',
                               '6', 'CALCULATION MEMBER',
                               '11', 'DIMENSION',
                               '2', 'MEASURE',
                               '1', 'CUBE',
                               '10', 'MEASURE FOLDER',
                               '8', 'BUILD PROCESS') OBJECT_TYPE,
  d.description_type DESCRIPTION_TYPE,
  d.description_value DESCRIPTION_VALUE,
  d.language LANGUAGE
FROM 
  olap_descriptions$ d, 
  user$ u, 
  obj$ o
WHERE 
  d.description_class is null
  AND d.obj# = o.obj# 
  AND o.owner# = u.user#
/

comment on table DBA_CUBE_DESCRIPTIONS is
'OLAP Descriptions in the database'
/
comment on column DBA_CUBE_DESCRIPTIONS.OWNER is
'Owner of the OLAP Description'
/
comment on column DBA_CUBE_DESCRIPTIONS.OBJECT_NAME is
'Name of the OLAP object that has the description'
/
comment on column DBA_CUBE_DESCRIPTIONS.OBJECT_TYPE is
'Text value indicating the type of the OLAP object that has the description'
/
comment on column DBA_CUBE_DESCRIPTIONS.DESCRIPTION_TYPE is
'Text value indicating the type the of OLAP Description'
/
comment on column DBA_CUBE_DESCRIPTIONS.DESCRIPTION_VALUE is
'Text of the OLAP Description'
/
comment on column DBA_CUBE_DESCRIPTIONS.LANGUAGE is
'Language of the OLAP Description'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DESCRIPTIONS
FOR SYS.DBA_CUBE_DESCRIPTIONS
/
GRANT SELECT ON DBA_CUBE_DESCRIPTIONS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_DESCRIPTIONS','CDB_CUBE_DESCRIPTIONS');
create or replace public synonym CDB_CUBE_DESCRIPTIONS for sys.CDB_CUBE_DESCRIPTIONS;
grant select on CDB_CUBE_DESCRIPTIONS to select_catalog_role;

create or replace view ALL_CUBE_DESCRIPTIONS
as
SELECT 
  u.name OWNER,
  CASE d.owning_object_type
  WHEN 4 -- ASSIGNMENT
  THEN (SELECT o.name || '.' || m.model_name || '.' || a.member_name
        FROM olap_model_assignments$ a, olap_models$ m, obj$ o
        WHERE d.owning_object_id = a.assignment_id
              AND m.model_id = a.model_id
              AND m.owning_obj_type = 11
              AND m.owning_obj_id = o.obj#
        )
  WHEN 3 -- model
  THEN (SELECT o.name || '.' || m.model_name
        FROM olap_models$ m, obj$ o
        WHERE d.owning_object_id = m.model_id
              AND m.owning_obj_type = 11
              AND m.owning_obj_id = o.obj#
        )
  WHEN 14 -- hier_level
  THEN (SELECT o.name || '.' || h.hierarchy_name || '.' || dl.level_name
        FROM olap_hier_levels$ hl, olap_dim_levels$ dl,
             olap_hierarchies$ h, obj$ o
        WHERE d.owning_object_id = hl.hierarchy_level_id
              AND hl.dim_level_id = dl.level_id
              AND hl.hierarchy_id = h.hierarchy_id
              AND h.dim_obj# = o.obj#
        )
  WHEN 13 -- hierarchy
  THEN (SELECT o.name || '.' || h.hierarchy_name
        FROM olap_hierarchies$ h, obj$ o
        WHERE d.owning_object_id = h.hierarchy_id
              AND h.dim_obj# = o.obj#
       )
  WHEN 12 -- dim_level
  THEN (SELECT o.name || '.' || dl.level_name
        FROM olap_dim_levels$ dl, obj$ o
        WHERE d.owning_object_id = dl.level_id
              AND dl.dim_obj# = o.obj#
       )
  WHEN 15 -- attribute
  THEN (SELECT o.name || '.' || a.attribute_name
        FROM olap_attributes$ a, obj$ o
        WHERE d.owning_object_id = a.attribute_id
              AND a.dim_obj# = o.obj#
       )
  WHEN 6 -- calc_member
  THEN (SELECT o.name || '.' || c.member_name
        FROM OLAP_CALCULATED_MEMBERS$ c, obj$ o            
        WHERE d.owning_object_id = c.member_id
              AND c.dim_obj# = o.obj#
       )
  WHEN 11 -- dimension
  THEN (SELECT o.name  
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  ELSE null 
  END AS OBJECT_NAME,
  decode(d.owning_object_type, '4', 'ASSIGNMENT',
                               '3', 'MODEL',
                               '14', 'HIERARCHY LEVEL',  
                               '13', 'HIERARCHY',
                               '12', 'DIMENSION LEVEL',
                               '15', 'ATTRIBUTE',
                               '6', 'CALCULATION MEMBER',
                               '11', 'DIMENSION') OBJECT_TYPE,
  d.description_type DESCRIPTION_TYPE,
  d.description_value DESCRIPTION_VALUE,
  d.language LANGUAGE
FROM 
  olap_descriptions$ d, 
  user$ u, 
  obj$ o
WHERE 
  d.description_class is null
  AND d.obj# = o.obj# 
  AND o.owner# = u.user#
  AND d.owning_object_type in (3, 4, 6, 11, 12, 13, 14, 15)
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT 
  u.name OWNER,
  CASE d.owning_object_type
  WHEN 2 -- measure
  THEN (SELECT o.name || '.' || m.measure_name
        FROM olap_measures$ m, olap_cubes$ c, obj$ o
        WHERE d.owning_object_id = m.measure_id
              AND m.cube_obj# = c.obj#
              AND c.obj# = o.obj#
        )
  WHEN 1 -- cube
  THEN (SELECT o.name 
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#              
       )
  ELSE null 
  END AS OBJECT_NAME,
  decode(d.owning_object_type, '1', 'CUBE',
                               '2', 'MEASURE') OBJECT_TYPE,
  d.description_type DESCRIPTION_TYPE,
  d.description_value DESCRIPTION_VALUE,
  d.language LANGUAGE
FROM 
  olap_descriptions$ d, 
  user$ u, 
  obj$ o,
  (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE 
  d.description_class is null
  AND d.obj# = o.obj# 
  AND o.owner# = u.user#
  AND o.obj#=da.obj#(+)
  AND d.owning_object_type in (1, 2)
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
UNION ALL
SELECT 
  u.name OWNER,
  o2.name OBJECT_NAME, 
  'MEASURE FOLDER' OBJECT_TYPE,
  d.description_type DESCRIPTION_TYPE,
  d.description_value DESCRIPTION_VALUE,
  d.language LANGUAGE
FROM 
  olap_descriptions$ d, 
  user$ u, 
  obj$ o,
  obj$ o2
WHERE 
  d.description_class is null
  AND d.obj# = o.obj# 
  AND o.owner# = u.user#
  AND d.owning_object_id = o2.obj#
  AND d.owning_object_type = 10 -- MEASURE FOLDER
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
       or   -- user has access to cubes in measure folder
              ( exists (select null from olap_meas_folder_contents$ mfc, olap_measures$ m
                        where mfc.measure_folder_obj# = o2.obj#
                          and m.measure_id  = mfc.object_id
                          and (
                              m.cube_obj# in
                                ( select obj#  -- directly granted authorization
                                  from sys.objauth$
                                  where grantee# in ( select kzsrorol from x$kzsro )
                                )
                              )
                       )
              )
            )
UNION ALL
SELECT 
  u.name OWNER,
  o2.name OBJECT_NAME, 
  'BUILD PROCESS' OBJECT_TYPE,
  d.description_type DESCRIPTION_TYPE,
  d.description_value DESCRIPTION_VALUE,
  d.language LANGUAGE
FROM 
  olap_descriptions$ d, 
  user$ u, 
  obj$ o,
  obj$ o2
WHERE 
  d.description_class is null
  AND d.obj# = o.obj# 
  AND o.owner# = u.user#
  AND d.owning_object_id = o2.obj#
  AND d.owning_object_type = 8 --BUILD_PROCESS
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_CUBE_DESCRIPTIONS is
'OLAP Descriptions in the database that are accessible to the user'
/
comment on column ALL_CUBE_DESCRIPTIONS.OWNER is
'Owner of the OLAP Description'
/
comment on column ALL_CUBE_DESCRIPTIONS.OBJECT_NAME is
'NAME of the OLAP object that has the description'
/
comment on column ALL_CUBE_DESCRIPTIONS.OBJECT_TYPE is
'Text value indicating the type of the OLAP object that has the description'
/
comment on column ALL_CUBE_DESCRIPTIONS.DESCRIPTION_TYPE is
'Text value indicating the type the of OLAP Description'
/
comment on column ALL_CUBE_DESCRIPTIONS.DESCRIPTION_VALUE is
'Text of the OLAP Description'
/
comment on column ALL_CUBE_DESCRIPTIONS.LANGUAGE is
'Language of the OLAP Description'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DESCRIPTIONS
FOR SYS.ALL_CUBE_DESCRIPTIONS
/
GRANT READ ON ALL_CUBE_DESCRIPTIONS to public
/

create or replace view USER_CUBE_DESCRIPTIONS
as
SELECT 
  CASE d.owning_object_type
  WHEN 4 -- ASSIGNMENT
  THEN (SELECT o.name || '.' || m.model_name || '.' || a.member_name
        FROM olap_model_assignments$ a, olap_models$ m, obj$ o
        WHERE d.owning_object_id = a.assignment_id
              AND m.model_id = a.model_id
              AND m.owning_obj_type = 11
              AND m.owning_obj_id = o.obj#
        )
  WHEN 3 -- model
  THEN (SELECT o.name || '.' || m.model_name
        FROM olap_models$ m, obj$ o
        WHERE d.owning_object_id = m.model_id
              AND m.owning_obj_type = 11
              AND m.owning_obj_id = o.obj#
        )
  WHEN 14 -- hier_level
  THEN (SELECT o.name || '.' || h.hierarchy_name || '.' || dl.level_name
        FROM olap_hier_levels$ hl, olap_dim_levels$ dl,
             olap_hierarchies$ h, obj$ o
        WHERE d.owning_object_id = hl.hierarchy_level_id
              AND hl.dim_level_id = dl.level_id
              AND hl.hierarchy_id = h.hierarchy_id
              AND h.dim_obj# = o.obj#
        )
  WHEN 13 -- hierarchy
  THEN (SELECT o.name || '.' || h.hierarchy_name
        FROM olap_hierarchies$ h, obj$ o
        WHERE d.owning_object_id = h.hierarchy_id
              AND h.dim_obj# = o.obj#
       )
  WHEN 12 -- dim_level
  THEN (SELECT o.name || '.' || dl.level_name
        FROM olap_dim_levels$ dl, obj$ o
        WHERE d.owning_object_id = dl.level_id
              AND dl.dim_obj# = o.obj#
       )
  WHEN 15 -- attribute
  THEN (SELECT o.name || '.' || a.attribute_name
        FROM olap_attributes$ a, obj$ o
        WHERE d.owning_object_id = a.attribute_id
              AND a.dim_obj# = o.obj#
       )
  WHEN 6 -- calc_member
  THEN (SELECT o.name || '.' || c.member_name
        FROM OLAP_CALCULATED_MEMBERS$ c, obj$ o            
        WHERE d.owning_object_id = c.member_id
              AND c.dim_obj# = o.obj#
       )
  WHEN 11 -- dimension
  THEN (SELECT o.name  
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  WHEN 2 -- measure
  THEN (SELECT o.name || '.' || m.measure_name
        FROM olap_measures$ m, olap_cubes$ c, obj$ o
        WHERE d.owning_object_id = m.measure_id
              AND m.cube_obj# = c.obj#
              AND c.obj# = o.obj#
        )
  WHEN 1 -- cube
  THEN (SELECT o.name 
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#              
       )
  WHEN 10 -- measure_folder
  THEN (SELECT o.name
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  WHEN 8 -- interaction
  THEN (SELECT o.name
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  ELSE null 
  END AS OBJECT_NAME,
  decode(d.owning_object_type, '4', 'ASSIGNMENT',
                               '3', 'MODEL',
                               '14', 'HIERARCHY LEVEL',  
                               '13', 'HIERARCHY',
                               '12', 'DIMENSION LEVEL',
                               '15', 'ATTRIBUTE',
                               '6', 'CALCULATION MEMBER',
                               '11', 'DIMENSION',
                               '2', 'MEASURE',
                               '1', 'CUBE',
                               '10', 'MEASURE FOLDER',
                               '8', 'BUILD PROCESS') OBJECT_TYPE,
  d.description_type DESCRIPTION_TYPE,
  d.description_value DESCRIPTION_VALUE,
  d.language LANGUAGE
FROM 
  olap_descriptions$ d, 
  obj$ o
WHERE 
  d.description_class is null
  AND d.obj# = o.obj# 
  AND o.owner# = USERENV('SCHEMAID')
/

comment on table USER_CUBE_DESCRIPTIONS is
'OLAP Descriptions owned by the user in the database'
/
comment on column USER_CUBE_DESCRIPTIONS.OBJECT_NAME is
'Name of the OLAP object that has the description'
/
comment on column USER_CUBE_DESCRIPTIONS.OBJECT_TYPE is
'Text value indicating the type of the OLAP object that has the description'
/
comment on column USER_CUBE_DESCRIPTIONS.DESCRIPTION_TYPE is
'Text value indicating the type the of OLAP Description'
/
comment on column USER_CUBE_DESCRIPTIONS.DESCRIPTION_VALUE is
'Text of the OLAP Description'
/
comment on column USER_CUBE_DESCRIPTIONS.LANGUAGE is
'Language of the OLAP Description'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DESCRIPTIONS
FOR SYS.USER_CUBE_DESCRIPTIONS
/
GRANT READ ON USER_CUBE_DESCRIPTIONS to public
/

-- olap_descriptions$ DATA DICTIONARY VIEWS for CLASSIFICATIONS --

create or replace view DBA_CUBE_CLASSIFICATIONS
as
SELECT
  u.name OWNER, 
  CASE d.owning_object_type
  WHEN 4 -- ASSIGNMENT
  THEN (SELECT o.name || '.' || m.model_name || '.' || a.member_name
        FROM olap_model_assignments$ a, olap_models$ m, obj$ o
        WHERE d.owning_object_id = a.assignment_id
              AND m.model_id = a.model_id
              AND m.owning_obj_type = 11
              AND m.owning_obj_id = o.obj#
        )
  WHEN 3 -- model
  THEN (SELECT o.name || '.' || m.model_name
        FROM olap_models$ m, obj$ o
        WHERE d.owning_object_id = m.model_id
              AND m.owning_obj_type = 11
              AND m.owning_obj_id = o.obj#
        )
  WHEN 14 -- hier_level
  THEN (SELECT o.name || '.' || h.hierarchy_name || '.' || dl.level_name
        FROM olap_hier_levels$ hl, olap_dim_levels$ dl,
             olap_hierarchies$ h, obj$ o
        WHERE d.owning_object_id = hl.hierarchy_level_id
              AND hl.dim_level_id = dl.level_id
              AND hl.hierarchy_id = h.hierarchy_id
              AND h.dim_obj# = o.obj#
        )
  WHEN 13 -- hierarchy
  THEN (SELECT o.name || '.' || h.hierarchy_name
        FROM olap_hierarchies$ h, obj$ o
        WHERE d.owning_object_id = h.hierarchy_id
              AND h.dim_obj# = o.obj#
       )
  WHEN 12 -- dim_level
  THEN (SELECT o.name || '.' || dl.level_name
        FROM olap_dim_levels$ dl, obj$ o
        WHERE d.owning_object_id = dl.level_id
              AND dl.dim_obj# = o.obj#
       )
  WHEN 15 -- attribute
  THEN (SELECT o.name || '.' || a.attribute_name
        FROM olap_attributes$ a, obj$ o
        WHERE d.owning_object_id = a.attribute_id
              AND a.dim_obj# = o.obj#
       )
  WHEN 6 -- calc_member
  THEN (SELECT o.name || '.' || c.member_name
        FROM OLAP_CALCULATED_MEMBERS$ c, obj$ o            
        WHERE d.owning_object_id = c.member_id
              AND c.dim_obj# = o.obj#
       )
  WHEN 11 -- dimension
  THEN (SELECT o.name  
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  WHEN 2 -- measure
  THEN (SELECT o.name || '.' || m.measure_name
        FROM olap_measures$ m, olap_cubes$ c, obj$ o
        WHERE d.owning_object_id = m.measure_id
              AND m.cube_obj# = c.obj#
              AND c.obj# = o.obj#
        )
  WHEN 1 -- cube
  THEN (SELECT o.name 
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#              
       )
  WHEN 10 -- measure_folder
  THEN (SELECT o.name
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  WHEN 8 -- interaction
  THEN (SELECT o.name
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  ELSE null 
  END AS OBJECT_NAME,
  decode(d.owning_object_type, '4', 'ASSIGNMENT',
                               '3', 'MODEL',
                               '14', 'HIERARCHY LEVEL',  
                               '13', 'HIERARCHY',
                               '12', 'DIMENSION LEVEL',
                               '15', 'ATTRIBUTE',
                               '6', 'CALCULATION MEMBER',
                               '11', 'DIMENSION',
                               '2', 'MEASURE',
                               '1', 'CUBE',
                               '10', 'MEASURE FOLDER',
                               '8', 'BUILD PROCESS') OBJECT_TYPE,
  d.language LANGUAGE,
  d.description_value CLASSIFICATION,
  d.description_order ORDER_NUM
FROM
  olap_descriptions$ d, 
  obj$ o,
  user$ u
WHERE
  d.description_class = 1
  AND d.obj# = o.obj#
  AND o.owner#=u.user#
/

comment on table DBA_CUBE_CLASSIFICATIONS is
'OLAP Object Classifications in the database'
/
comment on column DBA_CUBE_CLASSIFICATIONS.OWNER is
'Owner of the OLAP Classification'
/
comment on column DBA_CUBE_CLASSIFICATIONS.OBJECT_NAME is
'Name of the OLAP Object that has the classification'
/
comment on column DBA_CUBE_CLASSIFICATIONS.OBJECT_TYPE is
'Type of the OLAP Object that has the classification'
/
comment on column DBA_CUBE_CLASSIFICATIONS.LANGUAGE is
'Language of the OLAP Classification'
/
comment on column DBA_CUBE_CLASSIFICATIONS.ORDER_NUM is
'Order number of the OLAP Classification'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_CLASSIFICATIONS
FOR SYS.DBA_CUBE_CLASSIFICATIONS
/
GRANT SELECT ON DBA_CUBE_CLASSIFICATIONS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_CLASSIFICATIONS','CDB_CUBE_CLASSIFICATIONS');
create or replace public synonym CDB_CUBE_CLASSIFICATIONS for sys.CDB_CUBE_CLASSIFICATIONS;
grant select on CDB_CUBE_CLASSIFICATIONS to select_catalog_role;

create or replace view ALL_CUBE_CLASSIFICATIONS
as
SELECT
  u.name OWNER, 
  CASE d.owning_object_type
  WHEN 4 -- ASSIGNMENT
  THEN (SELECT o.name || '.' || m.model_name || '.' || a.member_name
        FROM olap_model_assignments$ a, olap_models$ m, obj$ o
        WHERE d.owning_object_id = a.assignment_id
              AND m.model_id = a.model_id
              AND m.owning_obj_type = 11
              AND m.owning_obj_id = o.obj#
        )
  WHEN 3 -- model
  THEN (SELECT o.name || '.' || m.model_name
        FROM olap_models$ m, obj$ o
        WHERE d.owning_object_id = m.model_id
              AND m.owning_obj_type = 11
              AND m.owning_obj_id = o.obj#
        )
  WHEN 14 -- hier_level
  THEN (SELECT o.name || '.' || h.hierarchy_name || '.' || dl.level_name
        FROM olap_hier_levels$ hl, olap_dim_levels$ dl,
             olap_hierarchies$ h, obj$ o
        WHERE d.owning_object_id = hl.hierarchy_level_id
              AND hl.dim_level_id = dl.level_id
              AND hl.hierarchy_id = h.hierarchy_id
              AND h.dim_obj# = o.obj#
        )
  WHEN 13 -- hierarchy
  THEN (SELECT o.name || '.' || h.hierarchy_name
        FROM olap_hierarchies$ h, obj$ o
        WHERE d.owning_object_id = h.hierarchy_id
              AND h.dim_obj# = o.obj#
       )
  WHEN 12 -- dim_level
  THEN (SELECT o.name || '.' || dl.level_name
        FROM olap_dim_levels$ dl, obj$ o
        WHERE d.owning_object_id = dl.level_id
              AND dl.dim_obj# = o.obj#
       )
  WHEN 15 -- attribute
  THEN (SELECT o.name || '.' || a.attribute_name
        FROM olap_attributes$ a, obj$ o
        WHERE d.owning_object_id = a.attribute_id
              AND a.dim_obj# = o.obj#
       )
  WHEN 6 -- calc_member
  THEN (SELECT o.name || '.' || c.member_name
        FROM OLAP_CALCULATED_MEMBERS$ c, obj$ o            
        WHERE d.owning_object_id = c.member_id
              AND c.dim_obj# = o.obj#
       )
  WHEN 11 -- dimension
  THEN (SELECT o.name  
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  ELSE null 
  END AS OBJECT_NAME,
  decode(d.owning_object_type, '4', 'ASSIGNMENT',
                               '3', 'MODEL',
                               '14', 'HIERARCHY LEVEL',  
                               '13', 'HIERARCHY',
                               '12', 'DIMENSION LEVEL',
                               '15', 'ATTRIBUTE',
                               '6', 'CALCULATION MEMBER',
                               '11', 'DIMENSION') OBJECT_TYPE,
  d.language LANGUAGE,
  d.description_value CLASSIFICATION,
  d.description_order ORDER_NUM
FROM
  olap_descriptions$ d, 
  obj$ o,
  user$ u
WHERE
  d.description_class = 1
  AND d.obj# = o.obj# 
  AND o.owner#=u.user#
  AND d.owning_object_type in (3, 4, 6, 11, 12, 13, 14, 15)
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT 
  u.name OWNER,
  CASE d.owning_object_type
  WHEN 2 -- measure
  THEN (SELECT o.name || '.' || m.measure_name
        FROM olap_measures$ m, olap_cubes$ c, obj$ o
        WHERE d.owning_object_id = m.measure_id
              AND m.cube_obj# = c.obj#
              AND c.obj# = o.obj#
        )
  WHEN 1 -- cube
  THEN (SELECT o.name 
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#              
       )
  ELSE null 
  END AS OBJECT_NAME,
  decode(d.owning_object_type, '1', 'CUBE',
                               '2', 'MEASURE') OBJECT_TYPE,
  d.language LANGUAGE,
  d.description_value CLASSIFICATION,
  d.description_order ORDER_NUM
FROM
  olap_descriptions$ d, 
  obj$ o,
  user$ u,
  (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE
  d.description_class = 1
  AND d.obj# = o.obj# 
  AND o.owner#=u.user#
  AND o.obj#=da.obj#(+)
  AND d.owning_object_type in (1, 2)
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
UNION ALL
SELECT 
  u.name OWNER,
  o2.name OBJECT_NAME, 
  'MEASURE FOLDER' OBJECT_TYPE,
  d.language LANGUAGE,
  d.description_value CLASSIFICATION,
  d.description_order ORDER_NUM
FROM
  olap_descriptions$ d, 
  obj$ o,
  user$ u,
  obj$ o2
WHERE
  d.description_class = 1
  AND d.obj# = o.obj# 
  AND o.owner#=u.user#
  AND d.owning_object_id = o2.obj#
  AND d.owning_object_type = 10 -- MEASURE FOLDER
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
       or   -- user has access to cubes in measure folder
              ( exists (select null from olap_meas_folder_contents$ mfc, olap_measures$ m
                        where mfc.measure_folder_obj# = o2.obj#
                          and m.measure_id  = mfc.object_id
                          and (
                              m.cube_obj# in
                                ( select obj#  -- directly granted authorization
                                  from sys.objauth$
                                  where grantee# in ( select kzsrorol from x$kzsro )
                                )
                              )
                       )
              )
            )
UNION ALL
SELECT 
  u.name OWNER,
  o2.name OBJECT_NAME, 
  'BUILD PROCESS' OBJECT_TYPE,
  d.language LANGUAGE,
  d.description_value CLASSIFICATION,
  d.description_order ORDER_NUM
FROM
  olap_descriptions$ d, 
  obj$ o,
  user$ u,
  obj$ o2
WHERE
  d.description_class = 1
  AND d.obj# = o.obj# 
  AND o.owner#=u.user#
  AND d.owning_object_id = o2.obj#
  AND d.owning_object_type = 8 --BUILD_PROCESS
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_CUBE_CLASSIFICATIONS is
'OLAP Object Classifications in the database that are accessible to the user'
/
comment on column ALL_CUBE_CLASSIFICATIONS.OWNER is
'Owner of the OLAP Classification'
/
comment on column ALL_CUBE_CLASSIFICATIONS.OBJECT_NAME is
'Name of the OLAP Object that has the classification'
/
comment on column ALL_CUBE_CLASSIFICATIONS.OBJECT_Type is
'Type of the OLAP Object that has the classification'
/
comment on column ALL_CUBE_CLASSIFICATIONS.LANGUAGE is
'Language of the OLAP Classification'
/
comment on column ALL_CUBE_CLASSIFICATIONS.ORDER_NUM is
'Order number of the OLAP Classification'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_CLASSIFICATIONS
FOR SYS.ALL_CUBE_CLASSIFICATIONS
/
GRANT READ ON ALL_CUBE_CLASSIFICATIONS to public
/

create or replace view USER_CUBE_CLASSIFICATIONS
as
SELECT
  CASE d.owning_object_type
  WHEN 4 -- ASSIGNMENT
  THEN (SELECT o.name || '.' || m.model_name || '.' || a.member_name
        FROM olap_model_assignments$ a, olap_models$ m, obj$ o
        WHERE d.owning_object_id = a.assignment_id
              AND m.model_id = a.model_id
              AND m.owning_obj_type = 11
              AND m.owning_obj_id = o.obj#
        )
  WHEN 3 -- model
  THEN (SELECT o.name || '.' || m.model_name
        FROM olap_models$ m, obj$ o
        WHERE d.owning_object_id = m.model_id
              AND m.owning_obj_type = 11
              AND m.owning_obj_id = o.obj#
        )
  WHEN 14 -- hier_level
  THEN (SELECT o.name || '.' || h.hierarchy_name || '.' || dl.level_name
        FROM olap_hier_levels$ hl, olap_dim_levels$ dl,
             olap_hierarchies$ h, obj$ o
        WHERE d.owning_object_id = hl.hierarchy_level_id
              AND hl.dim_level_id = dl.level_id
              AND hl.hierarchy_id = h.hierarchy_id
              AND h.dim_obj# = o.obj#
        )
  WHEN 13 -- hierarchy
  THEN (SELECT o.name || '.' || h.hierarchy_name
        FROM olap_hierarchies$ h, obj$ o
        WHERE d.owning_object_id = h.hierarchy_id
              AND h.dim_obj# = o.obj#
       )
  WHEN 12 -- dim_level
  THEN (SELECT o.name || '.' || dl.level_name
        FROM olap_dim_levels$ dl, obj$ o
        WHERE d.owning_object_id = dl.level_id
              AND dl.dim_obj# = o.obj#
       )
  WHEN 15 -- attribute
  THEN (SELECT o.name || '.' || a.attribute_name
        FROM olap_attributes$ a, obj$ o
        WHERE d.owning_object_id = a.attribute_id
              AND a.dim_obj# = o.obj#
       )
  WHEN 6 -- calc_member
  THEN (SELECT o.name || '.' || c.member_name
        FROM OLAP_CALCULATED_MEMBERS$ c, obj$ o            
        WHERE d.owning_object_id = c.member_id
              AND c.dim_obj# = o.obj#
       )
  WHEN 11 -- dimension
  THEN (SELECT o.name  
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  WHEN 2 -- measure
  THEN (SELECT o.name || '.' || m.measure_name
        FROM olap_measures$ m, olap_cubes$ c, obj$ o
        WHERE d.owning_object_id = m.measure_id
              AND m.cube_obj# = c.obj#
              AND c.obj# = o.obj#
        )
  WHEN 1 -- cube
  THEN (SELECT o.name 
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#              
       )
  WHEN 10 -- measure_folder
  THEN (SELECT o.name
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  WHEN 8 -- interaction
  THEN (SELECT o.name
        FROM obj$ o
        WHERE d.owning_object_id = o.obj#
       )
  ELSE null 
  END AS OBJECT_NAME,
  decode(d.owning_object_type, '4', 'ASSIGNMENT',
                               '3', 'MODEL',
                               '14', 'HIERARCHY LEVEL',  
                               '13', 'HIERARCHY',
                               '12', 'DIMENSION LEVEL',
                               '15', 'ATTRIBUTE',
                               '6', 'CALCULATION MEMBER',
                               '11', 'DIMENSION',
                               '2', 'MEASURE',
                               '1', 'CUBE',
                               '10', 'MEASURE FOLDER',
                               '8', 'BUILD PROCESS') OBJECT_TYPE,
  d.language LANGUAGE,
  d.description_value CLASSIFICATION,
  d.description_order ORDER_NUM
FROM
  olap_descriptions$ d, 
  obj$ o
WHERE
  d.description_class = 1
  AND d.obj# = o.obj#
  AND o.owner#=USERENV('SCHEMAID')
/

comment on table USER_CUBE_CLASSIFICATIONS is
'OLAP Object Classifications owned by the user in the database'
/
comment on column USER_CUBE_CLASSIFICATIONS.OBJECT_NAME is
'Name of the OLAP Object that has the classification'
/
comment on column USER_CUBE_CLASSIFICATIONS.OBJECT_TYPE is
'Type of the OLAP Object that has the classification'
/
comment on column USER_CUBE_CLASSIFICATIONS.LANGUAGE is
'Language of the OLAP Classification'
/
comment on column USER_CUBE_CLASSIFICATIONS.ORDER_NUM is
'Order number of the OLAP Classification'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_CLASSIFICATIONS
FOR SYS.USER_CUBE_CLASSIFICATIONS
/
GRANT READ ON USER_CUBE_CLASSIFICATIONS to public
/


-- data dictionary view for UNIQUE KEY ATTRIBUTES -- 

create or replace view DBA_CUBE_ATTR_UNIQUE_KEYS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  a.attribute_name ATTRIBUTE_NAME, 
  dl.level_name UNIQUE_KEY_LEVEL_NAME
FROM 
  olap_attributes$ a, 
  obj$ o, 
  user$ u, 
  olap_dim_levels$ dl,
  olap_attribute_visibility$ av
WHERE 
  o.obj#=a.dim_obj#
  AND o.owner#=u.user#
  AND a.attribute_id = av.attribute_id
  AND av.is_unique_key = 1
  AND av.owning_dim_id = dl.level_id
/

comment on table DBA_CUBE_ATTR_UNIQUE_KEYS is
'OLAP Unique Key Attributes in the database'
/
comment on column DBA_CUBE_ATTR_UNIQUE_KEYS.OWNER is
'Owner of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTR_UNIQUE_KEYS.DIMENSION_NAME is
'Name of owning Cube Dimension of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTR_UNIQUE_KEYS.ATTRIBUTE_NAME is
'Name of the Olap Attribute'
/
comment on column DBA_CUBE_ATTR_UNIQUE_KEYS.UNIQUE_KEY_LEVEL_NAME is
'Name of Dimension Level where the OLAP Attribute is unique key attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_ATTR_UNIQUE_KEYS
FOR SYS.DBA_CUBE_ATTR_UNIQUE_KEYS
/
GRANT SELECT ON DBA_CUBE_ATTR_UNIQUE_KEYS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_ATTR_UNIQUE_KEYS','CDB_CUBE_ATTR_UNIQUE_KEYS');
create or replace public synonym CDB_CUBE_ATTR_UNIQUE_KEYS for sys.CDB_CUBE_ATTR_UNIQUE_KEYS;
grant select on CDB_CUBE_ATTR_UNIQUE_KEYS to select_catalog_role;

create or replace view ALL_CUBE_ATTR_UNIQUE_KEYS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  a.attribute_name ATTRIBUTE_NAME, 
  dl.level_name UNIQUE_KEY_LEVEL_NAME
FROM 
  olap_attributes$ a, 
  obj$ o, 
  user$ u, 
  olap_dim_levels$ dl,
  olap_attribute_visibility$ av
WHERE 
  o.obj#=a.dim_obj#
  AND o.owner#=u.user#
  AND a.attribute_id = av.attribute_id
  AND av.is_unique_key = 1
  AND av.owning_dim_id = dl.level_id
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_CUBE_ATTR_UNIQUE_KEYS is
'OLAP Unique Key Attributes in the database that are accessible to the current user'
/
comment on column ALL_CUBE_ATTR_UNIQUE_KEYS.OWNER is
'Owner of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTR_UNIQUE_KEYS.DIMENSION_NAME is
'Name of owning Cube Dimension of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTR_UNIQUE_KEYS.ATTRIBUTE_NAME is
'Name of the Olap Attribute'
/
comment on column ALL_CUBE_ATTR_UNIQUE_KEYS.UNIQUE_KEY_LEVEL_NAME is
'Name of Dimension Level where the OLAP Attribute is unique key attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_ATTR_UNIQUE_KEYS
FOR SYS.ALL_CUBE_ATTR_UNIQUE_KEYS
/
GRANT READ ON ALL_CUBE_ATTR_UNIQUE_KEYS to public
/

create or replace view USER_CUBE_ATTR_UNIQUE_KEYS
as
SELECT 
  o.name DIMENSION_NAME, 
  a.attribute_name ATTRIBUTE_NAME, 
  dl.level_name UNIQUE_KEY_LEVEL_NAME
FROM 
  olap_attributes$ a, 
  obj$ o, 
  olap_dim_levels$ dl,
  olap_attribute_visibility$ av
WHERE 
  o.obj#=a.dim_obj#
  AND o.owner#=USERENV('SCHEMAID')
  AND a.attribute_id = av.attribute_id
  AND av.is_unique_key = 1
  AND av.owning_dim_id = dl.level_id
/

comment on table USER_CUBE_ATTR_UNIQUE_KEYS is
'OLAP Unique Key Attributes owned by the user in the database'
/
comment on column USER_CUBE_ATTR_UNIQUE_KEYS.DIMENSION_NAME is
'Name of owning Cube Dimension of the OLAP Attribute'
/
comment on column USER_CUBE_ATTR_UNIQUE_KEYS.ATTRIBUTE_NAME is
'Name of the Olap Attribute'
/
comment on column USER_CUBE_ATTR_UNIQUE_KEYS.UNIQUE_KEY_LEVEL_NAME is
'Name of Dimension Level where the OLAP Attribute is unique key attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_ATTR_UNIQUE_KEYS
FOR SYS.USER_CUBE_ATTR_UNIQUE_KEYS
/
GRANT READ ON USER_CUBE_ATTR_UNIQUE_KEYS to public
/

create or replace view USER_CUBE_NAMED_BUILD_SPECS
as
SELECT 
  o.name CUBE_NAME,
  syn.syntax_clob NAMED_BUILD_SPEC
FROM
  olap_cubes$ c,
  obj$ o,
  olap_syntax$ syn
WHERE 
  o.obj#=c.obj#
  AND o.owner#=USERENV('SCHEMAID') 
  AND syn.owner_id(+)=c.obj#
  AND syn.owner_type(+)=1
  AND syn.ref_role = 18 -- named build spec 
/

comment on table USER_CUBE_NAMED_BUILD_SPECS is
'OLAP Cube Named Build Specifications owned by the user in the database'
/
comment on column USER_CUBE_NAMED_BUILD_SPECS.CUBE_NAME is
'Name of the OLAP Cube'
/
comment on column USER_CUBE_NAMED_BUILD_SPECS.NAMED_BUILD_SPEC is
'Name of the OLAP Cube Named Build Specification'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_NAMED_BUILD_SPECS
FOR SYS.USER_CUBE_NAMED_BUILD_SPECS
/
GRANT READ ON USER_CUBE_NAMED_BUILD_SPECS to public
/

create or replace view DBA_CUBE_NAMED_BUILD_SPECS
as
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  syn.syntax_clob NAMED_BUILD_SPEC
FROM
  olap_cubes$ c,
  user$ u,
  obj$ o,
  olap_syntax$ syn
WHERE 
  o.obj#=c.obj#
  AND o.owner#=u.user#
  AND syn.owner_id(+)=c.obj#
  AND syn.owner_type(+)=1
  AND syn.ref_role = 18 -- named build spec 
/

comment on table DBA_CUBE_NAMED_BUILD_SPECS is
'OLAP Cube Named Build Specifications in the database'
/
comment on column DBA_CUBE_NAMED_BUILD_SPECS.OWNER is
'Owner of the OLAP Named Build Specification'
/
comment on column DBA_CUBE_NAMED_BUILD_SPECS.CUBE_NAME is
'Name of the OLAP Cube'
/
comment on column DBA_CUBE_NAMED_BUILD_SPECS.NAMED_BUILD_SPEC is
'Name of the OLAP Cube Named Build Specification'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_NAMED_BUILD_SPECS
FOR SYS.DBA_CUBE_NAMED_BUILD_SPECS
/
GRANT SELECT ON DBA_CUBE_NAMED_BUILD_SPECS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_NAMED_BUILD_SPECS','CDB_CUBE_NAMED_BUILD_SPECS');
create or replace public synonym CDB_CUBE_NAMED_BUILD_SPECS for sys.CDB_CUBE_NAMED_BUILD_SPECS;
grant select on CDB_CUBE_NAMED_BUILD_SPECS to select_catalog_role;

create or replace view ALL_CUBE_NAMED_BUILD_SPECS
as
SELECT 
  u.name OWNER,
  o.name CUBE_NAME,
  syn.syntax_clob NAMED_BUILD_SPEC
FROM
  olap_cubes$ c,
  user$ u,
  obj$ o,
  olap_syntax$ syn,
  (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
   FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      olap_dimensionality$ diml,
      olap_cube_dimensions$ dim,
      obj$ do
    WHERE
      do.obj# = dim.obj#
      AND diml.dimensioned_object_type = 1 --CUBE
      AND diml.dimensioned_object_id = c.obj#
      AND diml.dimension_type = 11 --DIMENSION
      AND diml.dimension_id = do.obj#
    )
    GROUP BY obj# ) da 
WHERE 
  o.obj#=c.obj#
  AND o.obj#=da.obj#(+)
  AND o.owner#=u.user#  
  AND syn.owner_id(+)=c.obj#
  AND syn.owner_type(+)=1
  AND syn.ref_role = 18 -- named build spec 
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
/

comment on table ALL_CUBE_NAMED_BUILD_SPECS is
'OLAP Cube Named Build Specifications in the database accessible by the user'
/
comment on column ALL_CUBE_NAMED_BUILD_SPECS.OWNER is
'Owner of the OLAP Named Build Specification'
/
comment on column ALL_CUBE_NAMED_BUILD_SPECS.CUBE_NAME is
'Name of the OLAP Cube'
/
comment on column ALL_CUBE_NAMED_BUILD_SPECS.NAMED_BUILD_SPEC is
'Name of the OLAP Cube Named Build Specification'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_NAMED_BUILD_SPECS
FOR SYS.ALL_CUBE_NAMED_BUILD_SPECS
/
GRANT READ ON ALL_CUBE_NAMED_BUILD_SPECS to public
/


create or replace view USER_METADATA_PROPERTIES
as
SELECT
  mp.owning_object_id OWNING_OBJECT_ID,
  decode(mp.owning_type, '1', 'CUBE',
                         '2', 'MEASURE',
                         '3', 'MODEL',
                         '4', 'ASSIGNMENT',
                         '6', 'CALCULATION MEMBER',
                         '8', 'BUILD PROCESS',
                         '10', 'MEASURE FOLDER',
                         '11', 'DIMENSION',
                         '12', 'DIMENSION LEVEL',
                         '13', 'HIERARCHY',
                         '14', 'HIERARCHY LEVEL',
                         '15', 'ATTRIBUTE',
                         '16', 'DIMENSIONALITY',
                         '17', 'ATTRIBUTE MAP',
                         '18', 'HIER LEVEL MAP',
                         '19', 'SOLVED LEVEL HIER MAP',
                         '20', 'SOLVED VALUE HIER MAP',
                         '21', 'MEMBER LIST MAP',
                         '22', 'CUBE MAP',
                         '23', 'CUBE DIMENSIONALITY MAP',
                         '24', 'MEASURE MAP',
                         '34', 'METADATA PROPERTY') OWNING_TYPE,
  mp.property_id PROPERTY_ID,
  mp.property_key PROPERTY_KEY,
  mp.property_value PROPERTY_VALUE,
  mp.property_order PROPERTY_ORDER
FROM
  obj$ o,
  olap_metadata_properties$ mp
WHERE
  o.obj# = mp.top_obj# -- joined via the top level object id
  AND o.owner#=USERENV('SCHEMAID')
  AND mp.owning_type2 IS NULL
/

comment on table USER_METADATA_PROPERTIES is
'OLAP Metadata Properties owned by the user in the database'
/
comment on column USER_METADATA_PROPERTIES.OWNING_OBJECT_ID is
'Dictionary Id of the OLAP Metadata Property owner'
/
comment on column USER_METADATA_PROPERTIES.OWNING_TYPE is
'Owning type of the OLAP Metadata Property'
/
comment on column USER_METADATA_PROPERTIES.PROPERTY_ID is
'Dictionary Id of the OLAP Metadata Property'
/
comment on column USER_METADATA_PROPERTIES.PROPERTY_KEY is
'Key of the OLAP Metadata Property'
/
comment on column USER_METADATA_PROPERTIES.PROPERTY_VALUE is
'Value of the OLAP Metadata Property'
/
comment on column USER_METADATA_PROPERTIES.PROPERTY_ORDER is
'Order number of the OLAP Metadata Property'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_METADATA_PROPERTIES
FOR SYS.USER_METADATA_PROPERTIES
/
GRANT READ ON USER_METADATA_PROPERTIES to public
/

create or replace view ALL_METADATA_PROPERTIES
as
SELECT
  u.name OWNER, 
  mp.owning_object_id OWNING_OBJECT_ID,
  decode(mp.owning_type, '1', 'CUBE',
                         '2', 'MEASURE',
                         '3', 'MODEL',
                         '4', 'ASSIGNMENT',
                         '6', 'CALCULATION MEMBER',
                         '8', 'BUILD PROCESS',
                         '10', 'MEASURE FOLDER',
                         '11', 'DIMENSION',
                         '12', 'DIMENSION LEVEL',
                         '13', 'HIERARCHY',
                         '14', 'HIERARCHY LEVEL',
                         '15', 'ATTRIBUTE',
                         '16', 'DIMENSIONALITY',
                         '17', 'ATTRIBUTE MAP',
                         '18', 'HIER LEVEL MAP',
                         '19', 'SOLVED LEVEL HIER MAP',
                         '20', 'SOLVED VALUE HIER MAP',
                         '21', 'MEMBER LIST MAP',
                         '22', 'CUBE MAP',
                         '23', 'CUBE DIMENSIONALITY MAP',
                         '24', 'MEASURE MAP',
                         '34', 'METADATA PROPERTY') OWNING_TYPE,
  mp.property_id PROPERTY_ID,
  mp.property_key PROPERTY_KEY,
  mp.property_value PROPERTY_VALUE,
  mp.property_order PROPERTY_ORDER
FROM
  user$ u,
  obj$ o,
  olap_metadata_properties$ mp
WHERE  
  o.obj# = mp.top_obj# -- joined via the top level object id
  AND o.type# = 92 -- Cube Dimension
  AND o.owner#=u.user#(+)
  AND mp.owning_type2 IS NULL
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER, 
  mp.owning_object_id OWNING_OBJECT_ID,
  decode(mp.owning_type, '1', 'CUBE',
                         '2', 'MEASURE',
                         '3', 'MODEL',
                         '4', 'ASSIGNMENT',
                         '6', 'CALCULATION MEMBER',
                         '8', 'BUILD PROCESS',
                         '10', 'MEASURE FOLDER',
                         '11', 'DIMENSION',
                         '12', 'DIMENSION LEVEL',
                         '13', 'HIERARCHY',
                         '14', 'HIERARCHY LEVEL',
                         '15', 'ATTRIBUTE',
                         '16', 'DIMENSIONALITY',
                         '17', 'ATTRIBUTE MAP',
                         '18', 'HIER LEVEL MAP',
                         '19', 'SOLVED LEVEL HIER MAP',
                         '20', 'SOLVED VALUE HIER MAP',
                         '21', 'MEMBER LIST MAP',
                         '22', 'CUBE MAP',
                         '23', 'CUBE DIMENSIONALITY MAP',
                         '24', 'MEASURE MAP',
                         '34', 'METADATA PROPERTY') OWNING_TYPE,
  mp.property_id PROPERTY_ID,
  mp.property_key PROPERTY_KEY,
  mp.property_value PROPERTY_VALUE,
  mp.property_order PROPERTY_ORDER
FROM
  user$ u,
  obj$ o,
  olap_metadata_properties$ mp,
 (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE
  o.obj# = mp.top_obj# -- joined via the top level object id
  AND o.type# = 93 -- Cube
  AND o.obj#=da.obj#(+)
  AND o.owner#=u.user#(+)
  AND mp.owning_type2 IS NULL
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
UNION ALL
SELECT
  u.name OWNER, 
  mp.owning_object_id OWNING_OBJECT_ID,
  decode(mp.owning_type, '1', 'CUBE',
                         '2', 'MEASURE',
                         '3', 'MODEL',
                         '4', 'ASSIGNMENT',
                         '6', 'CALCULATION MEMBER',
                         '8', 'BUILD PROCESS',
                         '10', 'MEASURE FOLDER',
                         '11', 'DIMENSION',
                         '12', 'DIMENSION LEVEL',
                         '13', 'HIERARCHY',
                         '14', 'HIERARCHY LEVEL',
                         '15', 'ATTRIBUTE',
                         '16', 'DIMENSIONALITY',
                         '17', 'ATTRIBUTE MAP',
                         '18', 'HIER LEVEL MAP',
                         '19', 'SOLVED LEVEL HIER MAP',
                         '20', 'SOLVED VALUE HIER MAP',
                         '21', 'MEMBER LIST MAP',
                         '22', 'CUBE MAP',
                         '23', 'CUBE DIMENSIONALITY MAP',
                         '24', 'MEASURE MAP',
                         '34', 'METADATA PROPERTY') OWNING_TYPE,
  mp.property_id PROPERTY_ID,
  mp.property_key PROPERTY_KEY,
  mp.property_value PROPERTY_VALUE,
  mp.property_order PROPERTY_ORDER
FROM
  user$ u,
  obj$ o,
  olap_metadata_properties$ mp
WHERE
  o.obj# = mp.top_obj# -- joined via the top level object id
  AND o.type# = 94 -- Measure Folder
  AND o.owner#=u.user#(+)
  AND mp.owning_type2 IS NULL
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
       or   -- user has access to cubes in measure folder
              ( exists (select null from olap_meas_folder_contents$ mfc, olap_measures$ m
                        where mfc.measure_folder_obj# = o.obj#
                          and m.measure_id  = mfc.object_id
                          and (
                              m.cube_obj# in
                                ( select obj#  -- directly granted authorization
                                  from sys.objauth$
                                  where grantee# in ( select kzsrorol from x$kzsro )
                                )
                              )
                       )
              )
            )
UNION ALL
SELECT
  u.name OWNER, 
  mp.owning_object_id OWNING_OBJECT_ID,
  decode(mp.owning_type, '1', 'CUBE',
                         '2', 'MEASURE',
                         '3', 'MODEL',
                         '4', 'ASSIGNMENT',
                         '6', 'CALCULATION MEMBER',
                         '8', 'BUILD PROCESS',
                         '10', 'MEASURE FOLDER',
                         '11', 'DIMENSION',
                         '12', 'DIMENSION LEVEL',
                         '13', 'HIERARCHY',
                         '14', 'HIERARCHY LEVEL',
                         '15', 'ATTRIBUTE',
                         '16', 'DIMENSIONALITY',
                         '17', 'ATTRIBUTE MAP',
                         '18', 'HIER LEVEL MAP',
                         '19', 'SOLVED LEVEL HIER MAP',
                         '20', 'SOLVED VALUE HIER MAP',
                         '21', 'MEMBER LIST MAP',
                         '22', 'CUBE MAP',
                         '23', 'CUBE DIMENSIONALITY MAP',
                         '24', 'MEASURE MAP',
                         '34', 'METADATA PROPERTY') OWNING_TYPE,
  mp.property_id PROPERTY_ID,
  mp.property_key PROPERTY_KEY,
  mp.property_value PROPERTY_VALUE,
  mp.property_order PROPERTY_ORDER
FROM
  user$ u,
  obj$ o,
  olap_metadata_properties$ mp
WHERE
  o.obj# = mp.top_obj# -- joined via the top level object id
  AND o.type# = 95 -- Build Process
  AND o.owner#=u.user#(+)
  AND mp.owning_type2 IS NULL
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_METADATA_PROPERTIES is
'OLAP Metadata Properties in the database'
/
comment on column ALL_METADATA_PROPERTIES.OWNER is
'Owner of the OLAP Metadata Property'
/
comment on column ALL_METADATA_PROPERTIES.OWNING_OBJECT_ID is
'Dictionary Id of the OLAP Metadata Property owner'
/
comment on column ALL_METADATA_PROPERTIES.OWNING_TYPE is
'Owning type of the OLAP Metadata Property'
/
comment on column ALL_METADATA_PROPERTIES.PROPERTY_ID is
'Dictionary Id of the OLAP Metadata Property'
/
comment on column ALL_METADATA_PROPERTIES.PROPERTY_KEY is
'Key of the OLAP Metadata Property'
/
comment on column ALL_METADATA_PROPERTIES.PROPERTY_VALUE is
'Value of the OLAP Metadata Property'
/
comment on column ALL_METADATA_PROPERTIES.PROPERTY_ORDER is
'Order number of the OLAP Metadata Property'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_METADATA_PROPERTIES
FOR SYS.ALL_METADATA_PROPERTIES
/
GRANT READ ON ALL_METADATA_PROPERTIES to public
/

create or replace view DBA_METADATA_PROPERTIES
as
SELECT
  u.name OWNER,
  mp.owning_object_id OWNING_OBJECT_ID,
  decode(mp.owning_type, '1', 'CUBE',
                         '2', 'MEASURE',
                         '3', 'MODEL',
                         '4', 'ASSIGNMENT',
                         '6', 'CALCULATION MEMBER',
                         '8', 'BUILD PROCESS',
                         '10', 'MEASURE FOLDER',
                         '11', 'DIMENSION',
                         '12', 'DIMENSION LEVEL',
                         '13', 'HIERARCHY',
                         '14', 'HIERARCHY LEVEL',
                         '15', 'ATTRIBUTE',
                         '16', 'DIMENSIONALITY',
                         '17', 'ATTRIBUTE MAP',
                         '18', 'HIER LEVEL MAP',
                         '19', 'SOLVED LEVEL HIER MAP',
                         '20', 'SOLVED VALUE HIER MAP',
                         '21', 'MEMBER LIST MAP',
                         '22', 'CUBE MAP',
                         '23', 'CUBE DIMENSIONALITY MAP',
                         '24', 'MEASURE MAP',
                         '34', 'METADATA PROPERTY') OWNING_TYPE,
  mp.property_id PROPERTY_ID,
  mp.property_key PROPERTY_KEY,
  mp.property_value PROPERTY_VALUE,
  mp.property_order PROPERTY_ORDER
FROM
  obj$ o,
  user$ u,
  olap_metadata_properties$ mp
WHERE
  o.obj# = mp.top_obj# -- joined via the top level object id
  AND o.owner#=u.user#
  AND mp.owning_type2 IS NULL
  AND o.owner# = u.user#
/

comment on table DBA_METADATA_PROPERTIES is
'OLAP Metadata Properties in the database'
/
comment on column DBA_METADATA_PROPERTIES.OWNER is
'Owner of the OLAP Metadata Property'
/
comment on column DBA_METADATA_PROPERTIES.OWNING_OBJECT_ID is
'Dictionary Id of the OLAP Metadata Property owner'
/
comment on column DBA_METADATA_PROPERTIES.OWNING_TYPE is
'Owning type of the OLAP Metadata Property'
/
comment on column DBA_METADATA_PROPERTIES.PROPERTY_ID is
'Dictionary Id of the OLAP Metadata Property'
/
comment on column DBA_METADATA_PROPERTIES.PROPERTY_KEY is
'Key of the OLAP Metadata Property'
/
comment on column DBA_METADATA_PROPERTIES.PROPERTY_VALUE is
'Value of the OLAP Metadata Property'
/
comment on column DBA_METADATA_PROPERTIES.PROPERTY_ORDER is
'Order number of the OLAP Metadata Property'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_METADATA_PROPERTIES
FOR SYS.DBA_METADATA_PROPERTIES
/
GRANT SELECT ON DBA_METADATA_PROPERTIES to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_METADATA_PROPERTIES','CDB_METADATA_PROPERTIES');
create or replace public synonym CDB_METADATA_PROPERTIES for sys.CDB_METADATA_PROPERTIES;
grant select on CDB_METADATA_PROPERTIES to select_catalog_role;


-- data dictionary view for metadata dependencies

CREATE OR REPLACE VIEW DBA_CUBE_DEPENDENCIES  
AS
SELECT
  u.name OWNER,
  o.name as D_TOP_OBJ_NAME,
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME1 */
  WHEN 4 -- ASSIGNMENT
  THEN (SELECT m.model_name
	FROM olap_model_assignments$ a, olap_models$ m
	WHERE md.d_sub_obj# = a.assignment_id
	      AND m.model_id = a.model_id
	      AND m.owning_obj_type = 11
	      AND m.owning_obj_id = md.d_top_obj#
	)
  WHEN 3 -- model
  THEN (SELECT m.model_name
	FROM olap_models$ m
	WHERE md.d_sub_obj# = m.model_id
	      AND m.owning_obj_type = 11
	      AND m.owning_obj_id = md.d_top_obj#
	)
  WHEN 14 -- hier_level
  THEN (SELECT h.hierarchy_name
	FROM olap_hier_levels$ hl, olap_hierarchies$ h
	WHERE md.d_sub_obj# = hl.hierarchy_level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 13 -- hierarchy
  THEN (SELECT h.hierarchy_name
	FROM olap_hierarchies$ h
	WHERE md.d_sub_obj# = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
       )
  WHEN 12 -- dim_level
  THEN (SELECT dl.level_name
	FROM olap_dim_levels$ dl
	WHERE md.d_sub_obj# = dl.level_id
	      AND dl.dim_obj# = md.d_top_obj#
       )
  WHEN 15 -- attribute
  THEN (SELECT a.attribute_name
	FROM olap_attributes$ a
	WHERE md.d_sub_obj# = a.attribute_id
	      AND a.dim_obj# = md.d_top_obj#
       )
  WHEN 6 -- calc_member
  THEN (SELECT c.member_name
	FROM OLAP_CALCULATED_MEMBERS$ c
	WHERE md.d_sub_obj# = c.member_id
	      AND c.dim_obj# = md.d_top_obj#
       )
  WHEN 18 -- hier_level_map
  THEN (SELECT h.hierarchy_name
	FROM olap_mappings$ m, olap_hierarchies$ h, olap_hier_levels$ hl
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = hl.hierarchy_level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 19 -- solved_level_hier_map
  THEN (SELECT h.hierarchy_name
	FROM olap_mappings$ m, olap_hierarchies$ h
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 20 -- solved_value_hier_map
  THEN (SELECT h.hierarchy_name
	FROM olap_mappings$ m, olap_hierarchies$ h
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 21 -- member_list_map
  THEN (SELECT 
          (CASE m.mapping_owner_type
           WHEN 11 -- primary_dim
           THEN (select m.map_name 
                 from olap_cube_dimensions$ d
                 where d.obj# = md.d_top_obj#
                       AND d.obj# = m.mapping_owner_id)
           WHEN 12 -- dim_level
           THEN (select dl.level_name
                 from olap_dim_levels$ dl
                 where m.mapping_owner_id = dl.level_id
                       AND dl.dim_obj# = md.d_top_obj#)
           WHEN 14 -- hier_level
           THEN (select h.hierarchy_name
                 from olap_hier_levels$ hl, olap_hierarchies$ h
                 where m.mapping_owner_id = hl.hierarchy_level_id
 	               AND hl.hierarchy_id = h.hierarchy_id
   	               AND h.dim_obj# = md.d_top_obj#)
           WHEN 13 -- hierarchy
           THEN (select h.hierarchy_name
                 from olap_hierarchies$ h
                 where m.mapping_owner_id = h.hierarchy_id
                       AND h.dim_obj# = md.d_top_obj#)
           ELSE null
           END) AS D_SUB_OBJ_NAME1
 	FROM olap_mappings$ m
 	WHERE m.map_id = md.d_sub_obj#
 	)
  WHEN 17 -- attribute_map
  THEN (SELECT
	  (CASE owner_map.mapping_owner_type
	  WHEN 14 -- hier_level
	  THEN (select h.hierarchy_name
		from olap_hier_levels$ hl, olap_hierarchies$ h
		where owner_map.mapping_owner_id = hl.hierarchy_level_id
		      AND hl.hierarchy_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 13 -- hierarchy
	  THEN (select h.hierarchy_name
		from olap_hierarchies$ h
		where owner_map.mapping_owner_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 12 -- dim_level
	  THEN (select dl.level_name
		from olap_dim_levels$ dl
		where owner_map.mapping_owner_id = dl.level_id
		      AND dl.dim_obj# = md.d_top_obj#)
	  WHEN 11 -- primary dimension
          THEN (select owner_map.map_name
		from olap_cube_dimensions$ d
		where d.obj# = md.d_top_obj#
		      AND owner_map.mapping_owner_id = d.obj#)
	  ELSE null
	  END) AS D_SUB_OBJ_NAME1
	FROM olap_mappings$ m, olap_mappings$ owner_map
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = owner_map.map_id
       )
  WHEN 2 -- measure
  THEN (SELECT meas.measure_name
        FROM olap_measures$ meas
        WHERE md.d_sub_obj# = meas.measure_id
              AND meas.cube_obj# = md.d_top_obj#
       )
  WHEN 22 -- cube_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ m
	WHERE m.mapping_owner_id = md.d_top_obj#
	      AND m.map_id = md.d_sub_obj#
       )
  WHEN 23 -- cube_dimnl_map
  THEN (SELECT owner_map.map_name
	FROM olap_mappings$ owner_map, olap_mappings$ m
	WHERE m.mapping_owner_id = owner_map.map_id
	      AND m.map_id = md.d_sub_obj#
	      AND owner_map.mapping_owner_id = md.d_top_obj#
       )
  WHEN 24 -- cube_meas_map
  THEN (SELECT owner_map.map_name
	FROM olap_mappings$ owner_map, olap_mappings$ m
	WHERE m.mapping_owner_id = owner_map.map_id
	      AND m.map_id = md.d_sub_obj#
	      AND owner_map.mapping_owner_id = md.d_top_obj#
       )
  WHEN 27 -- aw_dim_org
  THEN '$AW_ORGANIZATION'
  WHEN 28 -- aw_cube_org
  THEN '$AW_ORGANIZATION'
  WHEN 16 -- dimensionality
  THEN (SELECT io_diml.option_value
        FROM olap_dimensionality$ diml, olap_impl_options$ io_diml
        WHERE diml.DIMENSIONED_OBJECT_ID = md.d_top_obj# 
              AND diml.DIMENSIONALITY_ID = md.d_sub_obj#
              AND io_diml.object_type = 16 -- DIMENSIONALITY
              AND io_diml.owning_objectid = diml.dimensionality_id
              AND io_diml.option_type = 33 -- DIMENSIONALITY NAME
       )
  WHEN 30 -- secondary_partition_level
  THEN '$AW_ORGANIZATION'
  ELSE null
  END AS D_SUB_OBJ_NAME1,                       /* END COLUMN D_SUB_OBJ_NAME1 */
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME2 */
  WHEN 4 -- ASSIGNMENT
  THEN (SELECT a.member_name
	FROM olap_model_assignments$ a, olap_models$ m
	WHERE md.d_sub_obj# = a.assignment_id
	      AND m.model_id = a.model_id
	      AND m.owning_obj_type = 11
	      AND m.owning_obj_id = md.d_top_obj#
	)
  WHEN 14 -- hier_level
  THEN (SELECT dl.level_name
	FROM olap_hier_levels$ hl, olap_dim_levels$ dl,
	     olap_hierarchies$ h
	WHERE md.d_sub_obj# = hl.hierarchy_level_id
	      AND hl.dim_level_id = dl.level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 18 -- hier_level_map
  THEN (SELECT dl.level_name
	FROM olap_mappings$ m, olap_hierarchies$ h, olap_hier_levels$ hl,
	     olap_dim_levels$ dl
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = hl.hierarchy_level_id
	      AND hl.dim_level_id = dl.level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 19 -- solved_level_hier_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ m, olap_hierarchies$ h
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 20 -- solved_value_hier_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ m, olap_hierarchies$ h
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 21 -- member_list_map
   THEN (SELECT 
           (CASE m.mapping_owner_type
            WHEN 12 -- dim_level
            THEN (select m.map_name
                  from olap_dim_levels$ dl
                  where m.mapping_owner_id = dl.level_id
                        AND dl.dim_obj# = md.d_top_obj#)
            WHEN 14 -- hier_level
            THEN (select dl.level_name
                  from olap_hier_levels$ hl, olap_hierarchies$ h, 
                       olap_dim_levels$ dl
         	  where m.mapping_owner_id = hl.hierarchy_level_id
 	                AND hl.hierarchy_id = h.hierarchy_id
                        AND hl.dim_level_id = dl.level_id
   	                AND h.dim_obj# = md.d_top_obj#)
            WHEN 13 -- hierarchy
            THEN (select m.map_name
                  from olap_hierarchies$ h
                  where m.mapping_owner_id = h.hierarchy_id
                        AND h.dim_obj# = md.d_top_obj#)
            ELSE null
            END) AS D_SUB_OBJ_NAME1
 	FROM olap_mappings$ m
 	WHERE m.map_id = md.d_sub_obj#
 	)
  WHEN 17 -- attribute_map
  THEN (SELECT
	  (CASE owner_map.mapping_owner_type
	  WHEN 14 -- hier_level
	  THEN (select dl.level_name
		from olap_hier_levels$ hl, olap_hierarchies$ h,
		     olap_dim_levels$ dl
		where owner_map.mapping_owner_id = hl.hierarchy_level_id
		      AND hl.hierarchy_id = h.hierarchy_id
		      AND hl.dim_level_id = dl.level_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 13 -- hierarchy
	  THEN (select owner_map.map_name
		from olap_hierarchies$ h
		where owner_map.mapping_owner_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 12 -- dim_level
	  THEN (select owner_map.map_name
		from olap_dim_levels$ dl
		where owner_map.mapping_owner_id = dl.level_id
		      AND dl.dim_obj# = md.d_top_obj#)
	  WHEN 11 -- primary dimension
	  THEN (select m.map_name
		from olap_cube_dimensions$ d
		where d.obj# = md.d_top_obj#
		      AND owner_map.mapping_owner_id = d.obj#)
	  ELSE null
	  END) AS D_SUB_OBJ_NAME2
	FROM olap_mappings$ m, olap_mappings$ owner_map
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = owner_map.map_id
       )
  WHEN 23 -- cube_dimnl_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ owner_map, olap_mappings$ m
	WHERE m.mapping_owner_id = owner_map.map_id
	      AND m.map_id = md.d_sub_obj#
	      AND owner_map.mapping_owner_id = md.d_top_obj#
       )
  WHEN 24 -- cube_meas_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ owner_map, olap_mappings$ m
	WHERE m.mapping_owner_id = owner_map.map_id
	      AND m.map_id = md.d_sub_obj#
	      AND owner_map.mapping_owner_id = md.d_top_obj#
       )
  WHEN 30 -- secondary_partition_level
  THEN (SELECT
	  CASE
	  WHEN md.d_sub_obj# < 3
	  THEN (SELECT io.option_value
	  FROM olap_impl_options$ io
	  WHERE io.owning_objectid = md.d_top_obj#
	        AND io.object_type = 1
	        AND io.option_type = 
                    (case when d_sub_obj# = 0 then 38
                          when d_sub_obj# = 1 then 41 
                          else 44 end))
	  ELSE (SELECT mo.option_value
	  FROM olap_multi_options$ mo
	  WHERE mo.owning_objectid = md.d_top_obj#
	        AND mo.object_type = 1
	        AND mo.option_type = 5
	        AND mo.option_order = md.d_sub_obj#)
	  END
	FROM dual
	)
  ELSE null
  END AS D_SUB_OBJ_NAME2,                       /* END COLUMN D_SUB_OBJ_NAME2 */
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME3 */
  WHEN 18 -- hier_level_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ m, olap_hierarchies$ h, olap_hier_levels$ hl
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = hl.hierarchy_level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 21 -- member_list_map
  THEN (SELECT 
          (CASE m.mapping_owner_type
           WHEN 14 -- hier_level
           THEN (select m.map_name
                 from olap_hier_levels$ hl, olap_hierarchies$ h, 
                      olap_dim_levels$ dl
                  where m.mapping_owner_id = hl.hierarchy_level_id
	                AND hl.hierarchy_id = h.hierarchy_id
                        AND hl.dim_level_id = dl.level_id
   	                AND h.dim_obj# = md.d_top_obj#)
           ELSE null
           END) AS D_SUB_OBJ_NAME1
 	FROM olap_mappings$ m
 	WHERE m.map_id = md.d_sub_obj#
 	)
  WHEN 17 -- attribute_map
  THEN (SELECT
	  (CASE owner_map.mapping_owner_type
	  WHEN 14 -- hier_level
	  THEN (select owner_map.map_name
		from olap_hier_levels$ hl, olap_hierarchies$ h
		where owner_map.mapping_owner_id = hl.hierarchy_level_id
		      AND hl.hierarchy_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 13 -- hierarchy
	  THEN (select m.map_name
		from olap_hierarchies$ h
		where owner_map.mapping_owner_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 12 -- dim_level
	  THEN (select m.map_name
		from olap_dim_levels$ dl
		where owner_map.mapping_owner_id = dl.level_id
		      AND dl.dim_obj# = md.d_top_obj#)
	  ELSE null
	  END) AS D_SUB_OBJ_NAME3
	FROM olap_mappings$ m, olap_mappings$ owner_map
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = owner_map.map_id
       )
  ELSE null
  END AS D_SUB_OBJ_NAME3,                       /* END COLUMN D_SUB_OBJ_NAME3 */
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME4 */
  WHEN 17 -- attribute_map
  THEN (SELECT
	  (CASE owner_map.mapping_owner_type
	  WHEN 14 -- hier_level
	  THEN (select m.map_name
		from olap_hier_levels$ hl, olap_hierarchies$ h
		where owner_map.mapping_owner_id = hl.hierarchy_level_id
		      AND hl.hierarchy_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  ELSE null
	  END) AS D_SUB_OBJ_NAME3
	FROM olap_mappings$ m, olap_mappings$ owner_map
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = owner_map.map_id
       )
  ELSE null
  END AS D_SUB_OBJ_NAME4,                       /* END COLUMN D_SUB_OBJ_NAME4 */
  decode(md.d_obj_type, '1', 'CUBE',
			'2', 'MEASURE',
			'3', 'MODEL',
			'4', 'ASSIGNMENT',
			'6', 'CALCULATION MEMBER',
                        '10', 'MEASURE FOLDER',
                        '8',  'BUILD PROCESS',
			'11', 'DIMENSION',
			'12', 'DIMENSION LEVEL',
			'13', 'HIERARCHY',
			'14', 'HIERARCHY LEVEL',
			'15', 'ATTRIBUTE',
                        '16', 'DIMENSIONALITY',
			'17', 'ATTRIBUTE MAP',
			'18', 'HIER LEVEL MAP',
			'19', 'SOLVED LEVEL HIER MAP',
			'20', 'SOLVED VALUE HIER MAP',
			'21', 'MEMBER LIST MAP',
			'22', 'CUBE MAP',
			'23', 'CUBE DIMENSIONALITY MAP',
			'24', 'MEASURE MAP',
			'25', 'TABLE OR VIEW',
			'26', 'COLUMN',
                        '27', 'AW DIM ORGANIZATION',
                        '28', 'AW CUBE ORGANIZATION',
                        '29', 'AW',
                        '30', 'SECONDARY PARTITION LEVEL') D_OBJ_TYPE,
  md.P_OWNER P_OBJ_OWNER,
  md.P_TOP_OBJ_NAME P_TOP_OBJ_NAME,
  md.P_SUB_OBJ_NAME1 P_SUB_OBJ_NAME1,
  md.P_SUB_OBJ_NAME2 P_SUB_OBJ_NAME2,
  md.P_SUB_OBJ_NAME3 P_SUB_OBJ_NAME3,
  md.P_SUB_OBJ_NAME4 P_SUB_OBJ_NAME4,
  case md.p_obj_type
  WHEN 25 -- TABLE OR VIEW
       THEN (SELECT decode(o.type#, '4', 'VIEW', 'TABLE')
             FROM obj$ o
             WHERE o.obj# = md.p_obj#
            )
       ELSE decode(md.p_obj_type, '1', 'CUBE',
			'2', 'MEASURE',
			'3', 'MODEL',
			'4', 'ASSIGNMENT',
			'6', 'CALCULATION MEMBER',
                        '8',  'BUILD PROCESS',
                        '10', 'MEASURE FOLDER',
			'11', 'DIMENSION',
			'12', 'DIMENSION LEVEL',
			'13', 'HIERARCHY',
			'14', 'HIERARCHY LEVEL',
			'15', 'ATTRIBUTE',
                        '16', 'DIMENSIONALITY',
			'17', 'ATTRIBUTE MAP',
			'18', 'HIER LEVEL MAP',
			'19', 'SOLVED LEVEL HIER MAP',
			'20', 'SOLVED VALUE HIER MAP',
			'21', 'MEMBER LIST MAP',
			'22', 'CUBE MAP',
			'23', 'CUBE DIMENSIONALITY MAP',
			'24', 'MEASURE MAP',
			'26', 'COLUMN',
                        '27', 'AW DIM ORGANIZATION',
                        '28', 'AW CUBE ORGANIZATION',
                        '29', 'AW') END AS P_OBJ_TYPE,
  decode(md.dep_type, '1', 'CONSISTENT SOLVE SPEC',
                      '2', 'DEFAULT BUILD SPEC',
                      '3', 'BUILD SPEC',
                      '4', 'BUILD PROCESS',
                      '6', 'MEASURE IN MEASURE DIM',
                      '7', 'CUSTOM ORDER',
                      '9', 'TARGET ATTRIBUTE',
                      '10', 'TARGET DIMENSION',
                      '11', 'MEMBER EXPRESSION',
                      '12', 'EXPLICIT DIMENSION',
                      '13', 'PRIMARY DIMENSION',
                      '15', 'MEASURE IN MEASURE FOLDER',
                      '16', 'MEASURE FOLDER SUBFOLDER',
                      '17', 'MAPPED DIMENSION',
                      '18', 'QUERY',
                      '19', 'FROM CLAUSE',
                      '20', 'WHERE CLAUSE',
                      '21', 'JOIN CONDITION',
                      '22', 'LEVEL_ID EXPRESSION',
                      '23', 'KEY EXPRESSION',
                      '24', 'VALUE MAP EXPRESSION',
                      '25', 'LEVEL EXPRESSION',
                      '26', 'PARENT KEY EXPRESSION',
                      '27', 'PARENT LEVEL_ID EXPRESSION',
                      '28', 'MEASURE EXPRESSION',
                      '29', 'NVL EXPRESSION',
                      '30', 'AW',
                      '31', 'AW TABLE',
                      '32', 'PARTITION LEVEL',
                      '33', 'SECONDARY PARTITION LEVEL',
                      '34', 'PRECOMPUTE CONDITION'
                      ) DEPENDENCY_TYPE
FROM 
  olap_metadata_dependencies$ md, 
  obj$ o,
  user$ u
WHERE 
  o.obj# = md.d_top_obj#
  AND o.owner# = u.user#
/

comment on table DBA_CUBE_DEPENDENCIES is
'OLAP metadata dependencies in the database'
/
comment on column DBA_CUBE_DEPENDENCIES.OWNER is
'Owner of the dependent metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.D_TOP_OBJ_NAME is
'Name of the top-level object of the dependent metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.D_SUB_OBJ_NAME1 is
'Name of the first sub-object of the dependent metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.D_SUB_OBJ_NAME2 is
'Name of the second sub-object of the dependent metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.D_SUB_OBJ_NAME3 is
'Name of the third sub-object of the dependent metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.D_SUB_OBJ_NAME4 is
'Name of the fourth sub-object of the dependent metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.D_OBJ_TYPE is 
'Type of the dependent metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.P_OBJ_OWNER is
'Owner of the referenced metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.P_TOP_OBJ_NAME is
'Name of the top-level object of the referenced metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.P_SUB_OBJ_NAME1 is
'Name of the first sub-object of the referenced metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.P_SUB_OBJ_NAME2 is
'Name of the second sub-object of the referenced metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.P_SUB_OBJ_NAME3 is
'Name of the third sub-object of the referenced metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.P_SUB_OBJ_NAME4 is
'Name of the fourth sub-object of the referenced metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.P_OBJ_TYPE is
'Type of the referenced metadata object'
/
comment on column DBA_CUBE_DEPENDENCIES.DEPENDENCY_TYPE is
'Type of the dependency relationship'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DEPENDENCIES
FOR SYS.DBA_CUBE_DEPENDENCIES
/
GRANT SELECT ON DBA_CUBE_DEPENDENCIES to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CUBE_DEPENDENCIES','CDB_CUBE_DEPENDENCIES');
create or replace public synonym CDB_CUBE_DEPENDENCIES for sys.CDB_CUBE_DEPENDENCIES;
grant select on CDB_CUBE_DEPENDENCIES to select_catalog_role;

CREATE OR REPLACE VIEW ALL_CUBE_DEPENDENCIES  
AS
SELECT
  u.name OWNER,
  o.name as D_TOP_OBJ_NAME,
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME1 */
  WHEN 4 -- ASSIGNMENT
  THEN (SELECT m.model_name
	FROM olap_model_assignments$ a, olap_models$ m
	WHERE md.d_sub_obj# = a.assignment_id
	      AND m.model_id = a.model_id
	      AND m.owning_obj_type = 11
	      AND m.owning_obj_id = md.d_top_obj#
	)
  WHEN 3 -- model
  THEN (SELECT m.model_name
	FROM olap_models$ m
	WHERE md.d_sub_obj# = m.model_id
	      AND m.owning_obj_type = 11
	      AND m.owning_obj_id = md.d_top_obj#
	)
  WHEN 14 -- hier_level
  THEN (SELECT h.hierarchy_name
	FROM olap_hier_levels$ hl, olap_hierarchies$ h
	WHERE md.d_sub_obj# = hl.hierarchy_level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 13 -- hierarchy
  THEN (SELECT h.hierarchy_name
	FROM olap_hierarchies$ h
	WHERE md.d_sub_obj# = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
       )
  WHEN 12 -- dim_level
  THEN (SELECT dl.level_name
	FROM olap_dim_levels$ dl
	WHERE md.d_sub_obj# = dl.level_id
	      AND dl.dim_obj# = md.d_top_obj#
       )
  WHEN 15 -- attribute
  THEN (SELECT a.attribute_name
	FROM olap_attributes$ a
	WHERE md.d_sub_obj# = a.attribute_id
	      AND a.dim_obj# = md.d_top_obj#
       )
  WHEN 6 -- calc_member
  THEN (SELECT c.member_name
	FROM OLAP_CALCULATED_MEMBERS$ c
	WHERE md.d_sub_obj# = c.member_id
	      AND c.dim_obj# = md.d_top_obj#
       )
  WHEN 18 -- hier_level_map
  THEN (SELECT h.hierarchy_name
	FROM olap_mappings$ m, olap_hierarchies$ h, olap_hier_levels$ hl
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = hl.hierarchy_level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 19 -- solved_level_hier_map
  THEN (SELECT h.hierarchy_name
	FROM olap_mappings$ m, olap_hierarchies$ h
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 20 -- solved_value_hier_map
  THEN (SELECT h.hierarchy_name
	FROM olap_mappings$ m, olap_hierarchies$ h
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 21 -- member_list_map
  THEN (SELECT 
          (CASE m.mapping_owner_type
           WHEN 11 -- primary_dim
           THEN (select m.map_name 
                 from olap_cube_dimensions$ d
                 where d.obj# = md.d_top_obj#
                       AND d.obj# = m.mapping_owner_id)
           WHEN 12 -- dim_level
           THEN (select dl.level_name
                 from olap_dim_levels$ dl
                 where m.mapping_owner_id = dl.level_id
                       AND dl.dim_obj# = md.d_top_obj#)
           WHEN 14 -- hier_level
           THEN (select h.hierarchy_name
                 from olap_hier_levels$ hl, olap_hierarchies$ h
                 where m.mapping_owner_id = hl.hierarchy_level_id
 	               AND hl.hierarchy_id = h.hierarchy_id
   	               AND h.dim_obj# = md.d_top_obj#)
           WHEN 13 -- hierarchy
           THEN (select h.hierarchy_name
                 from olap_hierarchies$ h
                 where m.mapping_owner_id = h.hierarchy_id
                       AND h.dim_obj# = md.d_top_obj#)
           ELSE null
           END) AS D_SUB_OBJ_NAME1
 	FROM olap_mappings$ m
 	WHERE m.map_id = md.d_sub_obj#
 	)
  WHEN 17 -- attribute_map
  THEN (SELECT
	  (CASE owner_map.mapping_owner_type
	  WHEN 14 -- hier_level
	  THEN (select h.hierarchy_name
		from olap_hier_levels$ hl, olap_hierarchies$ h
		where owner_map.mapping_owner_id = hl.hierarchy_level_id
		      AND hl.hierarchy_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 13 -- hierarchy
	  THEN (select h.hierarchy_name
		from olap_hierarchies$ h
		where owner_map.mapping_owner_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 12 -- dim_level
	  THEN (select dl.level_name
		from olap_dim_levels$ dl
		where owner_map.mapping_owner_id = dl.level_id
		      AND dl.dim_obj# = md.d_top_obj#)
	  WHEN 11 -- primary dimension
          THEN (select owner_map.map_name
		from olap_cube_dimensions$ d
		where d.obj# = md.d_top_obj#
		      AND owner_map.mapping_owner_id = d.obj#)
	  ELSE null
	  END) AS D_SUB_OBJ_NAME1
	FROM olap_mappings$ m, olap_mappings$ owner_map
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = owner_map.map_id
       )
  WHEN 27 -- aw_dim_org
  THEN '$AW_ORGANIZATION'
  ELSE null
  END AS D_SUB_OBJ_NAME1,                       /* END COLUMN D_SUB_OBJ_NAME1 */
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME2 */
  WHEN 4 -- ASSIGNMENT
  THEN (SELECT a.member_name
	FROM olap_model_assignments$ a, olap_models$ m
	WHERE md.d_sub_obj# = a.assignment_id
	      AND m.model_id = a.model_id
	      AND m.owning_obj_type = 11
	      AND m.owning_obj_id = md.d_top_obj#
	)
  WHEN 14 -- hier_level
  THEN (SELECT dl.level_name
	FROM olap_hier_levels$ hl, olap_dim_levels$ dl,
	     olap_hierarchies$ h
	WHERE md.d_sub_obj# = hl.hierarchy_level_id
	      AND hl.dim_level_id = dl.level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 18 -- hier_level_map
  THEN (SELECT dl.level_name
	FROM olap_mappings$ m, olap_hierarchies$ h, olap_hier_levels$ hl,
	     olap_dim_levels$ dl
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = hl.hierarchy_level_id
	      AND hl.dim_level_id = dl.level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 19 -- solved_level_hier_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ m, olap_hierarchies$ h
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 20 -- solved_value_hier_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ m, olap_hierarchies$ h
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 21 -- member_list_map
  THEN (SELECT 
          (CASE m.mapping_owner_type
           WHEN 12 -- dim_level
           THEN (select m.map_name
                 from olap_dim_levels$ dl
                 where m.mapping_owner_id = dl.level_id
                       AND dl.dim_obj# = md.d_top_obj#)
           WHEN 14 -- hier_level
           THEN (select dl.level_name
                 from olap_hier_levels$ hl, olap_hierarchies$ h, 
                      olap_dim_levels$ dl
       	         where m.mapping_owner_id = hl.hierarchy_level_id
	               AND hl.hierarchy_id = h.hierarchy_id
                       AND hl.dim_level_id = dl.level_id
   	               AND h.dim_obj# = md.d_top_obj#)
           WHEN 13 -- hierarchy
           THEN (select m.map_name
                 from olap_hierarchies$ h
                 where m.mapping_owner_id = h.hierarchy_id
                       AND h.dim_obj# = md.d_top_obj#)
           ELSE null
           END) AS D_SUB_OBJ_NAME1
 	FROM olap_mappings$ m
 	WHERE m.map_id = md.d_sub_obj#
 	)
  WHEN 17 -- attribute_map
  THEN (SELECT
	  (CASE owner_map.mapping_owner_type
	  WHEN 14 -- hier_level
	  THEN (select dl.level_name
		from olap_hier_levels$ hl, olap_hierarchies$ h,
		     olap_dim_levels$ dl
		where owner_map.mapping_owner_id = hl.hierarchy_level_id
		      AND hl.hierarchy_id = h.hierarchy_id
		      AND hl.dim_level_id = dl.level_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 13 -- hierarchy
	  THEN (select owner_map.map_name
		from olap_hierarchies$ h
		where owner_map.mapping_owner_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 12 -- dim_level
	  THEN (select owner_map.map_name
		from olap_dim_levels$ dl
		where owner_map.mapping_owner_id = dl.level_id
		      AND dl.dim_obj# = md.d_top_obj#)
	  WHEN 11 -- primary dimension
	  THEN (select m.map_name
		from olap_cube_dimensions$ d
		where d.obj# = md.d_top_obj#
		      AND owner_map.mapping_owner_id = d.obj#)
	  ELSE null
	  END) AS D_SUB_OBJ_NAME2
	FROM olap_mappings$ m, olap_mappings$ owner_map
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = owner_map.map_id
       )
  ELSE null
  END AS D_SUB_OBJ_NAME2,                       /* END COLUMN D_SUB_OBJ_NAME2 */
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME3 */
  WHEN 18 -- hier_level_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ m, olap_hierarchies$ h, olap_hier_levels$ hl
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = hl.hierarchy_level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 21 -- member_list_map
  THEN (SELECT 
          (CASE m.mapping_owner_type
           WHEN 14 -- hier_level
           THEN (select m.map_name
                 from olap_hier_levels$ hl, olap_hierarchies$ h, 
                      olap_dim_levels$ dl
                  where m.mapping_owner_id = hl.hierarchy_level_id
	                AND hl.hierarchy_id = h.hierarchy_id
                        AND hl.dim_level_id = dl.level_id
   	                AND h.dim_obj# = md.d_top_obj#)
           ELSE null
           END) AS D_SUB_OBJ_NAME1
 	FROM olap_mappings$ m
 	WHERE m.map_id = md.d_sub_obj#
 	)
  WHEN 17 -- attribute_map
  THEN (SELECT
	  (CASE owner_map.mapping_owner_type
	  WHEN 14 -- hier_level
	  THEN (select owner_map.map_name
		from olap_hier_levels$ hl, olap_hierarchies$ h
		where owner_map.mapping_owner_id = hl.hierarchy_level_id
		      AND hl.hierarchy_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 13 -- hierarchy
	  THEN (select m.map_name
		from olap_hierarchies$ h
		where owner_map.mapping_owner_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 12 -- dim_level
	  THEN (select m.map_name
		from olap_dim_levels$ dl
		where owner_map.mapping_owner_id = dl.level_id
		      AND dl.dim_obj# = md.d_top_obj#)
	  ELSE null
	  END) AS D_SUB_OBJ_NAME3
	FROM olap_mappings$ m, olap_mappings$ owner_map
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = owner_map.map_id
       )
  ELSE null
  END AS D_SUB_OBJ_NAME3,                       /* END COLUMN D_SUB_OBJ_NAME3 */
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME4 */
  WHEN 17 -- attribute_map
  THEN (SELECT
	  (CASE owner_map.mapping_owner_type
	  WHEN 14 -- hier_level
	  THEN (select m.map_name
		from olap_hier_levels$ hl, olap_hierarchies$ h
		where owner_map.mapping_owner_id = hl.hierarchy_level_id
		      AND hl.hierarchy_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  ELSE null
	  END) AS D_SUB_OBJ_NAME3
	FROM olap_mappings$ m, olap_mappings$ owner_map
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = owner_map.map_id
       )
  ELSE null
  END AS D_SUB_OBJ_NAME4,                       /* END COLUMN D_SUB_OBJ_NAME4 */
  decode(md.d_obj_type, '3', 'MODEL',
			'4', 'ASSIGNMENT',
			'6', 'CALCULATION MEMBER',
                        '11', 'DIMENSION',
			'12', 'DIMENSION LEVEL',
			'13', 'HIERARCHY',
			'14', 'HIERARCHY LEVEL',
			'15', 'ATTRIBUTE',
			'17', 'ATTRIBUTE MAP',
			'18', 'HIER LEVEL MAP',
			'19', 'SOLVED LEVEL HIER MAP',
			'20', 'SOLVED VALUE HIER MAP',
			'21', 'MEMBER LIST MAP',
                        '27', 'AW DIM ORGANIZATION',
                        '29', 'AW') D_OBJ_TYPE,
  md.P_OWNER P_OBJ_OWNER,
  md.P_TOP_OBJ_NAME P_TOP_OBJ_NAME,
  md.P_SUB_OBJ_NAME1 P_SUB_OBJ_NAME1,
  md.P_SUB_OBJ_NAME2 P_SUB_OBJ_NAME2,
  md.P_SUB_OBJ_NAME3 P_SUB_OBJ_NAME3,
  md.P_SUB_OBJ_NAME4 P_SUB_OBJ_NAME4,
  case md.p_obj_type
  WHEN 25 -- TABLE OR VIEW
       THEN (SELECT decode(o.type#, '4', 'VIEW', 'TABLE')
             FROM obj$ o
             WHERE o.obj# = md.p_obj#
            )
       ELSE decode(md.p_obj_type, '1', 'CUBE',
			'2', 'MEASURE',
			'3', 'MODEL',
			'4', 'ASSIGNMENT',
			'6', 'CALCULATION MEMBER',
                        '8',  'BUILD PROCESS',
                        '10', 'MEASURE FOLDER',
			'11', 'DIMENSION',
			'12', 'DIMENSION LEVEL',
			'13', 'HIERARCHY',
			'14', 'HIERARCHY LEVEL',
			'15', 'ATTRIBUTE',
                        '16', 'DIMENSIONALITY',
			'17', 'ATTRIBUTE MAP',
			'18', 'HIER LEVEL MAP',
			'19', 'SOLVED LEVEL HIER MAP',
			'20', 'SOLVED VALUE HIER MAP',
			'21', 'MEMBER LIST MAP',
			'22', 'CUBE MAP',
			'23', 'CUBE DIMENSIONALITY MAP',
			'24', 'MEASURE MAP',
			'26', 'COLUMN',
                        '27', 'AW DIM ORGANIZATION',
                        '28', 'AW CUBE ORGANIZATION',
                        '29', 'AW') END AS P_OBJ_TYPE,
  decode(md.dep_type, '1', 'CONSISTENT SOLVE SPEC',
                      '2', 'DEFAULT BUILD SPEC',
                      '3', 'BUILD SPEC',
                      '4', 'BUILD PROCESS',
                      '6', 'MEASURE IN MEASURE DIM',
                      '7', 'CUSTOM ORDER',
                      '9', 'TARGET ATTRIBUTE',
                      '10', 'TARGET DIMENSION',
                      '11', 'MEMBER EXPRESSION',
                      '12', 'EXPLICIT DIMENSION',
                      '13', 'PRIMARY DIMENSION',
                      '15', 'MEASURE IN MEASURE FOLDER',
                      '16', 'MEASURE FOLDER SUBFOLDER',
                      '17', 'MAPPED DIMENSION',
                      '18', 'QUERY',
                      '19', 'FROM CLAUSE',
                      '20', 'WHERE CLAUSE',
                      '21', 'JOIN CONDITION',
                      '22', 'LEVEL_ID EXPRESSION',
                      '23', 'KEY EXPRESSION',
                      '24', 'VALUE MAP EXPRESSION',
                      '25', 'LEVEL EXPRESSION',
                      '26', 'PARENT KEY EXPRESSION',
                      '27', 'PARENT LEVEL_ID EXPRESSION',
                      '28', 'MEASURE EXPRESSION',
                      '29', 'NVL EXPRESSION',
                      '30', 'AW',
                      '31', 'AW TABLE',
                      '32', 'PARTITION LEVEL',
                      '33', 'SECONDARY PARTITION LEVEL',
                      '34', 'PRECOMPUTE CONDITION'
                      ) DEPENDENCY_TYPE
FROM 
  olap_metadata_dependencies$ md, 
  obj$ o,
  user$ u
WHERE 
  o.obj# = md.d_top_obj#
  AND o.owner# = u.user#
  AND md.d_obj_type in (3, 4, 6, 11, 12, 13, 14, 15, 17, 18, 19, 20, 21, 27, 29)
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name as D_TOP_OBJ_NAME,
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME1 */
  WHEN 2 -- measure
  THEN (SELECT meas.measure_name
        FROM olap_measures$ meas
        WHERE md.d_sub_obj# = meas.measure_id
              AND meas.cube_obj# = md.d_top_obj#
       )
  WHEN 22 -- cube_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ m
	WHERE m.mapping_owner_id = md.d_top_obj#
	      AND m.map_id = md.d_sub_obj#
       )
  WHEN 23 -- cube_dimnl_map
  THEN (SELECT owner_map.map_name
	FROM olap_mappings$ owner_map, olap_mappings$ m
	WHERE m.mapping_owner_id = owner_map.map_id
	      AND m.map_id = md.d_sub_obj#
	      AND owner_map.mapping_owner_id = md.d_top_obj#
       )
  WHEN 24 -- cube_meas_map
  THEN (SELECT owner_map.map_name
	FROM olap_mappings$ owner_map, olap_mappings$ m
	WHERE m.mapping_owner_id = owner_map.map_id
	      AND m.map_id = md.d_sub_obj#
	      AND owner_map.mapping_owner_id = md.d_top_obj#
       )
  WHEN 16 -- dimensionality
  THEN (SELECT io_diml.option_value
        FROM olap_dimensionality$ diml, olap_impl_options$ io_diml
        WHERE diml.DIMENSIONED_OBJECT_ID = md.d_top_obj# 
              AND diml.DIMENSIONALITY_ID = md.d_sub_obj#
              AND io_diml.object_type = 16 -- DIMENSIONALITY
              AND io_diml.owning_objectid = diml.dimensionality_id
              AND io_diml.option_type = 33 -- DIMENSIONALITY NAME
       )
  WHEN 28 -- aw_cube_org
  THEN '$AW_ORGANIZATION'
  WHEN 30 -- secondary_partition_level
  THEN '$AW_ORGANIZATION'
  ELSE null
  END AS D_SUB_OBJ_NAME1,                       /* END COLUMN D_SUB_OBJ_NAME1 */
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME2 */
  WHEN 23 -- cube_dimnl_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ owner_map, olap_mappings$ m
	WHERE m.mapping_owner_id = owner_map.map_id
	      AND m.map_id = md.d_sub_obj#
	      AND owner_map.mapping_owner_id = md.d_top_obj#
       )
  WHEN 24 -- cube_meas_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ owner_map, olap_mappings$ m
	WHERE m.mapping_owner_id = owner_map.map_id
	      AND m.map_id = md.d_sub_obj#
	      AND owner_map.mapping_owner_id = md.d_top_obj#
       )
  WHEN 30 -- secondary_partition_level
  THEN (SELECT
	  CASE
	  WHEN md.d_sub_obj# < 3
	  THEN (SELECT io.option_value
	  FROM olap_impl_options$ io
	  WHERE io.owning_objectid = md.d_top_obj#
	        AND io.object_type = 1
	        AND io.option_type = 
                    (case when d_sub_obj# = 0 then 38
                          when d_sub_obj# = 1 then 41 
                          else 44 end))
	  ELSE (SELECT mo.option_value
	  FROM olap_multi_options$ mo
	  WHERE mo.owning_objectid = md.d_top_obj#
	        AND mo.object_type = 1
	        AND mo.option_type = 5
	        AND mo.option_order = md.d_sub_obj#)
	  END
	FROM dual
	)
  ELSE null
  END AS D_SUB_OBJ_NAME2,                       /* END COLUMN D_SUB_OBJ_NAME2 */
  null AS D_SUB_OBJ_NAME3,
  null AS D_SUB_OBJ_NAME4,
  decode(md.d_obj_type, '1', 'CUBE',
			'2', 'MEASURE',
                        '16', 'DIMENSIONALITY',
			'22', 'CUBE MAP',
			'23', 'CUBE DIMENSIONALITY MAP',
			'24', 'MEASURE MAP',
                        '28', 'AW CUBE ORGANIZATION',
                        '30', 'SECONDARY PARTITION LEVEL',
                        '29', 'AW') D_OBJ_TYPE,
  md.P_OWNER P_OBJ_OWNER,
  md.P_TOP_OBJ_NAME P_TOP_OBJ_NAME,
  md.P_SUB_OBJ_NAME1 P_SUB_OBJ_NAME1,
  md.P_SUB_OBJ_NAME2 P_SUB_OBJ_NAME2,
  md.P_SUB_OBJ_NAME3 P_SUB_OBJ_NAME3,
  md.P_SUB_OBJ_NAME4 P_SUB_OBJ_NAME4,
  case md.p_obj_type
  WHEN 25 -- TABLE OR VIEW
       THEN (SELECT decode(o.type#, '4', 'VIEW', 'TABLE')
             FROM obj$ o
             WHERE o.obj# = md.p_obj#
            )
       ELSE decode(md.p_obj_type, '1', 'CUBE',
			'2', 'MEASURE',
			'3', 'MODEL',
			'4', 'ASSIGNMENT',
			'6', 'CALCULATION MEMBER',
                        '8',  'BUILD PROCESS',
                        '10', 'MEASURE FOLDER',
			'11', 'DIMENSION',
			'12', 'DIMENSION LEVEL',
			'13', 'HIERARCHY',
			'14', 'HIERARCHY LEVEL',
			'15', 'ATTRIBUTE',
                        '16', 'DIMENSIONALITY',
			'17', 'ATTRIBUTE MAP',
			'18', 'HIER LEVEL MAP',
			'19', 'SOLVED LEVEL HIER MAP',
			'20', 'SOLVED VALUE HIER MAP',
			'21', 'MEMBER LIST MAP',
			'22', 'CUBE MAP',
			'23', 'CUBE DIMENSIONALITY MAP',
			'24', 'MEASURE MAP',
			'26', 'COLUMN',
                        '27', 'AW DIM ORGANIZATION',
                        '28', 'AW CUBE ORGANIZATION',
                        '29', 'AW') END AS P_OBJ_TYPE,
  decode(md.dep_type, '1', 'CONSISTENT SOLVE SPEC',
                      '2', 'DEFAULT BUILD SPEC',
                      '3', 'BUILD SPEC',
                      '4', 'BUILD PROCESS',
                      '6', 'MEASURE IN MEASURE DIM',
                      '7', 'CUSTOM ORDER',
                      '9', 'TARGET ATTRIBUTE',
                      '10', 'TARGET DIMENSION',
                      '11', 'MEMBER EXPRESSION',
                      '12', 'EXPLICIT DIMENSION',
                      '13', 'PRIMARY DIMENSION',
                      '15', 'MEASURE IN MEASURE FOLDER',
                      '16', 'MEASURE FOLDER SUBFOLDER',
                      '17', 'MAPPED DIMENSION',
                      '18', 'QUERY',
                      '19', 'FROM CLAUSE',
                      '20', 'WHERE CLAUSE',
                      '21', 'JOIN CONDITION',
                      '22', 'LEVEL_ID EXPRESSION',
                      '23', 'KEY EXPRESSION',
                      '24', 'VALUE MAP EXPRESSION',
                      '25', 'LEVEL EXPRESSION',
                      '26', 'PARENT KEY EXPRESSION',
                      '27', 'PARENT LEVEL_ID EXPRESSION',
                      '28', 'MEASURE EXPRESSION',
                      '29', 'NVL EXPRESSION',
                      '30', 'AW',
                      '31', 'AW TABLE',
                      '32', 'PARTITION LEVEL',
                      '33', 'SECONDARY PARTITION LEVEL',
                      '34', 'PRECOMPUTE CONDITION'
                      ) DEPENDENCY_TYPE
FROM 
  olap_metadata_dependencies$ md, 
  obj$ o,
  user$ u,
  (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ora_check_SYS_privilege (do.owner#, do.type#) = 1
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE 
  o.obj# = md.d_top_obj#
  AND o.owner# = u.user#
  AND o.obj#=da.obj#(+)
  AND md.d_obj_type in (1, 2, 16, 22, 23, 24, 28, 29, 30)
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
UNION ALL
SELECT
  u.name OWNER,
  o.name as D_TOP_OBJ_NAME,
  null AS D_SUB_OBJ_NAME1,
  null AS D_SUB_OBJ_NAME2,
  null AS D_SUB_OBJ_NAME3,
  null AS D_SUB_OBJ_NAME4,
  'MEASURE FOLDER' D_OBJ_TYPE,
  md.P_OWNER P_OBJ_OWNER,
  md.P_TOP_OBJ_NAME P_TOP_OBJ_NAME,
  md.P_SUB_OBJ_NAME1 P_SUB_OBJ_NAME1,
  md.P_SUB_OBJ_NAME2 P_SUB_OBJ_NAME2,
  md.P_SUB_OBJ_NAME3 P_SUB_OBJ_NAME3,
  md.P_SUB_OBJ_NAME4 P_SUB_OBJ_NAME4,
  case md.p_obj_type
  WHEN 25 -- TABLE OR VIEW
       THEN (SELECT decode(o.type#, '4', 'VIEW', 'TABLE')
             FROM obj$ o
             WHERE o.obj# = md.p_obj#
            )
       ELSE decode(md.p_obj_type, '1', 'CUBE',
			'2', 'MEASURE',
			'3', 'MODEL',
			'4', 'ASSIGNMENT',
			'6', 'CALCULATION MEMBER',
                        '8',  'BUILD PROCESS',
                        '10', 'MEASURE FOLDER',
			'11', 'DIMENSION',
			'12', 'DIMENSION LEVEL',
			'13', 'HIERARCHY',
			'14', 'HIERARCHY LEVEL',
			'15', 'ATTRIBUTE',
                        '16', 'DIMENSIONALITY',
			'17', 'ATTRIBUTE MAP',
			'18', 'HIER LEVEL MAP',
			'19', 'SOLVED LEVEL HIER MAP',
			'20', 'SOLVED VALUE HIER MAP',
			'21', 'MEMBER LIST MAP',
			'22', 'CUBE MAP',
			'23', 'CUBE DIMENSIONALITY MAP',
			'24', 'MEASURE MAP',
			'26', 'COLUMN',
                        '27', 'AW DIM ORGANIZATION',
                        '28', 'AW CUBE ORGANIZATION',
                        '29', 'AW') END AS P_OBJ_TYPE,
  decode(md.dep_type, '1', 'CONSISTENT SOLVE SPEC',
                      '2', 'DEFAULT BUILD SPEC',
                      '3', 'BUILD SPEC',
                      '4', 'BUILD PROCESS',
                      '6', 'MEASURE IN MEASURE DIM',
                      '7', 'CUSTOM ORDER',
                      '9', 'TARGET ATTRIBUTE',
                      '10', 'TARGET DIMENSION',
                      '11', 'MEMBER EXPRESSION',
                      '12', 'EXPLICIT DIMENSION',
                      '13', 'PRIMARY DIMENSION',
                      '15', 'MEASURE IN MEASURE FOLDER',
                      '16', 'MEASURE FOLDER SUBFOLDER',
                      '17', 'MAPPED DIMENSION',
                      '18', 'QUERY',
                      '19', 'FROM CLAUSE',
                      '20', 'WHERE CLAUSE',
                      '21', 'JOIN CONDITION',
                      '22', 'LEVEL_ID EXPRESSION',
                      '23', 'KEY EXPRESSION',
                      '24', 'VALUE MAP EXPRESSION',
                      '25', 'LEVEL EXPRESSION',
                      '26', 'PARENT KEY EXPRESSION',
                      '27', 'PARENT LEVEL_ID EXPRESSION',
                      '28', 'MEASURE EXPRESSION',
                      '29', 'NVL EXPRESSION',
                      '30', 'AW',
                      '31', 'AW TABLE',
                      '32', 'PARTITION LEVEL',
                      '33', 'SECONDARY PARTITION LEVEL',
                      '34', 'PRECOMPUTE CONDITION'
                      ) DEPENDENCY_TYPE
FROM 
  olap_metadata_dependencies$ md, 
  obj$ o,
  user$ u
WHERE 
  o.obj# = md.d_top_obj#
  AND o.owner# = u.user#
  AND md.d_obj_type = 10
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
       or   -- user has access to cubes in measure folder
              ( exists (select null from olap_meas_folder_contents$ mfc, 
                                         olap_measures$ m
                        where mfc.measure_folder_obj# = o.obj#
                          and m.measure_id  = mfc.object_id
                          and (
                              m.cube_obj# in
                                ( select obj#  -- directly granted authorization
                                  from sys.objauth$
                                  where grantee#
                                        in ( select kzsrorol from x$kzsro )
                                )
                              )
                       )
              )
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name as D_TOP_OBJ_NAME,
  null AS D_SUB_OBJ_NAME1,
  null AS D_SUB_OBJ_NAME2,
  null AS D_SUB_OBJ_NAME3,
  null AS D_SUB_OBJ_NAME4,
  'BUILD PROCESS' AS D_OBJ_TYPE,
  md.P_OWNER P_OBJ_OWNER,
  md.P_TOP_OBJ_NAME P_TOP_OBJ_NAME,
  md.P_SUB_OBJ_NAME1 P_SUB_OBJ_NAME1,
  md.P_SUB_OBJ_NAME2 P_SUB_OBJ_NAME2,
  md.P_SUB_OBJ_NAME3 P_SUB_OBJ_NAME3,
  md.P_SUB_OBJ_NAME4 P_SUB_OBJ_NAME4,
  case md.p_obj_type
  WHEN 25 -- TABLE OR VIEW
       THEN (SELECT decode(o.type#, '4', 'VIEW', 'TABLE')
             FROM obj$ o
             WHERE o.obj# = md.p_obj#
            )
       ELSE decode(md.p_obj_type, '1', 'CUBE',
			'2', 'MEASURE',
			'3', 'MODEL',
			'4', 'ASSIGNMENT',
			'6', 'CALCULATION MEMBER',
                        '8',  'BUILD PROCESS',
                        '10', 'MEASURE FOLDER',
			'11', 'DIMENSION',
			'12', 'DIMENSION LEVEL',
			'13', 'HIERARCHY',
			'14', 'HIERARCHY LEVEL',
			'15', 'ATTRIBUTE',
                        '16', 'DIMENSIONALITY',
			'17', 'ATTRIBUTE MAP',
			'18', 'HIER LEVEL MAP',
			'19', 'SOLVED LEVEL HIER MAP',
			'20', 'SOLVED VALUE HIER MAP',
			'21', 'MEMBER LIST MAP',
			'22', 'CUBE MAP',
			'23', 'CUBE DIMENSIONALITY MAP',
			'24', 'MEASURE MAP',
			'26', 'COLUMN',
                        '27', 'AW DIM ORGANIZATION',
                        '28', 'AW CUBE ORGANIZATION',
                        '29', 'AW') END AS P_OBJ_TYPE,
  decode(md.dep_type, '1', 'CONSISTENT SOLVE SPEC',
                      '2', 'DEFAULT BUILD SPEC',
                      '3', 'BUILD SPEC',
                      '4', 'BUILD PROCESS',
                      '6', 'MEASURE IN MEASURE DIM',
                      '7', 'CUSTOM ORDER',
                      '9', 'TARGET ATTRIBUTE',
                      '10', 'TARGET DIMENSION',
                      '11', 'MEMBER EXPRESSION',
                      '12', 'EXPLICIT DIMENSION',
                      '13', 'PRIMARY DIMENSION',
                      '15', 'MEASURE IN MEASURE FOLDER',
                      '16', 'MEASURE FOLDER SUBFOLDER',
                      '17', 'MAPPED DIMENSION',
                      '18', 'QUERY',
                      '19', 'FROM CLAUSE',
                      '20', 'WHERE CLAUSE',
                      '21', 'JOIN CONDITION',
                      '22', 'LEVEL_ID EXPRESSION',
                      '23', 'KEY EXPRESSION',
                      '24', 'VALUE MAP EXPRESSION',
                      '25', 'LEVEL EXPRESSION',
                      '26', 'PARENT KEY EXPRESSION',
                      '27', 'PARENT LEVEL_ID EXPRESSION',
                      '28', 'MEASURE EXPRESSION',
                      '29', 'NVL EXPRESSION',
                      '30', 'AW',
                      '31', 'AW TABLE',
                      '32', 'PARTITION LEVEL',
                      '33', 'SECONDARY PARTITION LEVEL',
                      '34', 'PRECOMPUTE CONDITION'
                      ) DEPENDENCY_TYPE
FROM 
  olap_metadata_dependencies$ md, 
  obj$ o,
  user$ u
WHERE 
  o.obj# = md.d_top_obj#
  AND o.owner# = u.user#
  AND md.d_obj_type = 8 -- build process
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ora_check_SYS_privilege (o.owner#, o.type#) = 1
            )
/

comment on table ALL_CUBE_DEPENDENCIES is
'OLAP metadata dependencies in the database that are accessible to the current 
user'
/
comment on column ALL_CUBE_DEPENDENCIES.OWNER is
'Owner of the dependent metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.D_TOP_OBJ_NAME is
'Name of the top-level object of the dependent metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.D_SUB_OBJ_NAME1 is
'Name of the first sub-object of the dependent metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.D_SUB_OBJ_NAME2 is
'Name of the second sub-object of the dependent metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.D_SUB_OBJ_NAME3 is
'Name of the third sub-object of the dependent metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.D_SUB_OBJ_NAME4 is
'Name of the fourth sub-object of the dependent metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.D_OBJ_TYPE is 
'Type of the dependent metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.P_OBJ_OWNER is
'Owner of the referenced metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.P_TOP_OBJ_NAME is
'Name of the top-level object of the referenced metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.P_SUB_OBJ_NAME1 is
'Name of the first sub-object of the referenced metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.P_SUB_OBJ_NAME2 is
'Name of the second sub-object of the referenced metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.P_SUB_OBJ_NAME3 is
'Name of the third sub-object of the referenced metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.P_SUB_OBJ_NAME4 is
'Name of the fourth sub-object of the referenced metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.P_OBJ_TYPE is
'Type of the referenced metadata object'
/
comment on column ALL_CUBE_DEPENDENCIES.DEPENDENCY_TYPE is
'Type of the dependency relationship'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DEPENDENCIES
FOR SYS.ALL_CUBE_DEPENDENCIES
/
GRANT READ ON ALL_CUBE_DEPENDENCIES to public
/


CREATE OR REPLACE VIEW USER_CUBE_DEPENDENCIES  
AS
SELECT
  o.name as D_TOP_OBJ_NAME,
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME1 */
  WHEN 4 -- ASSIGNMENT
  THEN (SELECT m.model_name
	FROM olap_model_assignments$ a, olap_models$ m
	WHERE md.d_sub_obj# = a.assignment_id
	      AND m.model_id = a.model_id
	      AND m.owning_obj_type = 11
	      AND m.owning_obj_id = md.d_top_obj#
	)
  WHEN 3 -- model
  THEN (SELECT m.model_name
	FROM olap_models$ m
	WHERE md.d_sub_obj# = m.model_id
	      AND m.owning_obj_type = 11
	      AND m.owning_obj_id = md.d_top_obj#
	)
  WHEN 14 -- hier_level
  THEN (SELECT h.hierarchy_name
	FROM olap_hier_levels$ hl, olap_hierarchies$ h
	WHERE md.d_sub_obj# = hl.hierarchy_level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 13 -- hierarchy
  THEN (SELECT h.hierarchy_name
	FROM olap_hierarchies$ h
	WHERE md.d_sub_obj# = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
       )
  WHEN 12 -- dim_level
  THEN (SELECT dl.level_name
	FROM olap_dim_levels$ dl
	WHERE md.d_sub_obj# = dl.level_id
	      AND dl.dim_obj# = md.d_top_obj#
       )
  WHEN 15 -- attribute
  THEN (SELECT a.attribute_name
	FROM olap_attributes$ a
	WHERE md.d_sub_obj# = a.attribute_id
	      AND a.dim_obj# = md.d_top_obj#
       )
  WHEN 6 -- calc_member
  THEN (SELECT c.member_name
	FROM OLAP_CALCULATED_MEMBERS$ c
	WHERE md.d_sub_obj# = c.member_id
	      AND c.dim_obj# = md.d_top_obj#
       )
  WHEN 18 -- hier_level_map
  THEN (SELECT h.hierarchy_name
	FROM olap_mappings$ m, olap_hierarchies$ h, olap_hier_levels$ hl
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = hl.hierarchy_level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 19 -- solved_level_hier_map
  THEN (SELECT h.hierarchy_name
	FROM olap_mappings$ m, olap_hierarchies$ h
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 20 -- solved_value_hier_map
  THEN (SELECT h.hierarchy_name
	FROM olap_mappings$ m, olap_hierarchies$ h
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 21 -- member_list_map
  THEN (SELECT 
          (CASE m.mapping_owner_type
           WHEN 11 -- primary_dim
           THEN (select m.map_name 
                 from olap_cube_dimensions$ d
                 where d.obj# = md.d_top_obj#
                       AND d.obj# = m.mapping_owner_id)
           WHEN 12 -- dim_level
           THEN (select dl.level_name
                 from olap_dim_levels$ dl
                 where m.mapping_owner_id = dl.level_id
                       AND dl.dim_obj# = md.d_top_obj#)
           WHEN 14 -- hier_level
           THEN (select h.hierarchy_name
                 from olap_hier_levels$ hl, olap_hierarchies$ h
                 where m.mapping_owner_id = hl.hierarchy_level_id
 	               AND hl.hierarchy_id = h.hierarchy_id
   	               AND h.dim_obj# = md.d_top_obj#)
           WHEN 13 -- hierarchy
           THEN (select h.hierarchy_name
                 from olap_hierarchies$ h
                 where m.mapping_owner_id = h.hierarchy_id
                       AND h.dim_obj# = md.d_top_obj#)
           ELSE null
           END) AS D_SUB_OBJ_NAME1
 	FROM olap_mappings$ m
 	WHERE m.map_id = md.d_sub_obj#
 	)
  WHEN 17 -- attribute_map
  THEN (SELECT
	  (CASE owner_map.mapping_owner_type
	  WHEN 14 -- hier_level
	  THEN (select h.hierarchy_name
		from olap_hier_levels$ hl, olap_hierarchies$ h
		where owner_map.mapping_owner_id = hl.hierarchy_level_id
		      AND hl.hierarchy_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 13 -- hierarchy
	  THEN (select h.hierarchy_name
		from olap_hierarchies$ h
		where owner_map.mapping_owner_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 12 -- dim_level
	  THEN (select dl.level_name
		from olap_dim_levels$ dl
		where owner_map.mapping_owner_id = dl.level_id
		      AND dl.dim_obj# = md.d_top_obj#)
	  WHEN 11 -- primary dimension
          THEN (select owner_map.map_name
		from olap_cube_dimensions$ d
		where d.obj# = md.d_top_obj#
		      AND owner_map.mapping_owner_id = d.obj#)
	  ELSE null
	  END) AS D_SUB_OBJ_NAME1
	FROM olap_mappings$ m, olap_mappings$ owner_map
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = owner_map.map_id
       )
  WHEN 2 -- measure
  THEN (SELECT meas.measure_name
        FROM olap_measures$ meas
        WHERE md.d_sub_obj# = meas.measure_id
              AND meas.cube_obj# = md.d_top_obj#
       )
  WHEN 22 -- cube_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ m
	WHERE m.mapping_owner_id = md.d_top_obj#
	      AND m.map_id = md.d_sub_obj#
       )
  WHEN 23 -- cube_dimnl_map
  THEN (SELECT owner_map.map_name
	FROM olap_mappings$ owner_map, olap_mappings$ m
	WHERE m.mapping_owner_id = owner_map.map_id
	      AND m.map_id = md.d_sub_obj#
	      AND owner_map.mapping_owner_id = md.d_top_obj#
       )
  WHEN 24 -- cube_meas_map
  THEN (SELECT owner_map.map_name
	FROM olap_mappings$ owner_map, olap_mappings$ m
	WHERE m.mapping_owner_id = owner_map.map_id
	      AND m.map_id = md.d_sub_obj#
	      AND owner_map.mapping_owner_id = md.d_top_obj#
       )
  WHEN 27 -- aw_dim_org
  THEN '$AW_ORGANIZATION'
  WHEN 28 -- aw_cube_org
  THEN '$AW_ORGANIZATION'
  WHEN 16 -- dimensionality
  THEN (SELECT io_diml.option_value
        FROM olap_dimensionality$ diml, olap_impl_options$ io_diml
        WHERE diml.DIMENSIONED_OBJECT_ID = md.d_top_obj# 
              AND diml.DIMENSIONALITY_ID = md.d_sub_obj#
              AND io_diml.object_type = 16 -- DIMENSIONALITY
              AND io_diml.owning_objectid = diml.dimensionality_id
              AND io_diml.option_type = 33 -- DIMENSIONALITY NAME
       )
  WHEN 30 -- secondary_partition_level
  THEN '$AW_ORGANIZATION'
  ELSE null
  END AS D_SUB_OBJ_NAME1,                       /* END COLUMN D_SUB_OBJ_NAME1 */
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME2 */
  WHEN 4 -- ASSIGNMENT
  THEN (SELECT a.member_name
	FROM olap_model_assignments$ a, olap_models$ m
	WHERE md.d_sub_obj# = a.assignment_id
	      AND m.model_id = a.model_id
	      AND m.owning_obj_type = 11
	      AND m.owning_obj_id = md.d_top_obj#
	)
  WHEN 14 -- hier_level
  THEN (SELECT dl.level_name
	FROM olap_hier_levels$ hl, olap_dim_levels$ dl,
	     olap_hierarchies$ h
	WHERE md.d_sub_obj# = hl.hierarchy_level_id
	      AND hl.dim_level_id = dl.level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 18 -- hier_level_map
  THEN (SELECT dl.level_name
	FROM olap_mappings$ m, olap_hierarchies$ h, olap_hier_levels$ hl,
	     olap_dim_levels$ dl
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = hl.hierarchy_level_id
	      AND hl.dim_level_id = dl.level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 19 -- solved_level_hier_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ m, olap_hierarchies$ h
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 20 -- solved_value_hier_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ m, olap_hierarchies$ h
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 21 -- member_list_map
   THEN (SELECT 
           (CASE m.mapping_owner_type
            WHEN 12 -- dim_level
            THEN (select m.map_name
                  from olap_dim_levels$ dl
                  where m.mapping_owner_id = dl.level_id
                        AND dl.dim_obj# = md.d_top_obj#)
            WHEN 14 -- hier_level
            THEN (select dl.level_name
                  from olap_hier_levels$ hl, olap_hierarchies$ h, 
                       olap_dim_levels$ dl
         	  where m.mapping_owner_id = hl.hierarchy_level_id
 	                AND hl.hierarchy_id = h.hierarchy_id
                        AND hl.dim_level_id = dl.level_id
   	                AND h.dim_obj# = md.d_top_obj#)
            WHEN 13 -- hierarchy
            THEN (select m.map_name
                  from olap_hierarchies$ h
                  where m.mapping_owner_id = h.hierarchy_id
                        AND h.dim_obj# = md.d_top_obj#)
            ELSE null
            END) AS D_SUB_OBJ_NAME1
 	FROM olap_mappings$ m
 	WHERE m.map_id = md.d_sub_obj#
 	)
  WHEN 17 -- attribute_map
  THEN (SELECT
	  (CASE owner_map.mapping_owner_type
	  WHEN 14 -- hier_level
	  THEN (select dl.level_name
		from olap_hier_levels$ hl, olap_hierarchies$ h,
		     olap_dim_levels$ dl
		where owner_map.mapping_owner_id = hl.hierarchy_level_id
		      AND hl.hierarchy_id = h.hierarchy_id
		      AND hl.dim_level_id = dl.level_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 13 -- hierarchy
	  THEN (select owner_map.map_name
		from olap_hierarchies$ h
		where owner_map.mapping_owner_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 12 -- dim_level
	  THEN (select owner_map.map_name
		from olap_dim_levels$ dl
		where owner_map.mapping_owner_id = dl.level_id
		      AND dl.dim_obj# = md.d_top_obj#)
	  WHEN 11 -- primary dimension
	  THEN (select m.map_name
		from olap_cube_dimensions$ d
		where d.obj# = md.d_top_obj#
		      AND owner_map.mapping_owner_id = d.obj#)
	  ELSE null
	  END) AS D_SUB_OBJ_NAME2
	FROM olap_mappings$ m, olap_mappings$ owner_map
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = owner_map.map_id
       )
  WHEN 23 -- cube_dimnl_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ owner_map, olap_mappings$ m
	WHERE m.mapping_owner_id = owner_map.map_id
	      AND m.map_id = md.d_sub_obj#
	      AND owner_map.mapping_owner_id = md.d_top_obj#
       )
  WHEN 24 -- cube_meas_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ owner_map, olap_mappings$ m
	WHERE m.mapping_owner_id = owner_map.map_id
	      AND m.map_id = md.d_sub_obj#
	      AND owner_map.mapping_owner_id = md.d_top_obj#
       )
  WHEN 30 -- secondary_partition_level
  THEN (SELECT
	  CASE
	  WHEN md.d_sub_obj# < 3
	  THEN (SELECT io.option_value
	  FROM olap_impl_options$ io
	  WHERE io.owning_objectid = md.d_top_obj#
	        AND io.object_type = 1
	        AND io.option_type = 
                    (case when d_sub_obj# = 0 then 38
                          when d_sub_obj# = 1 then 41 
                          else 44 end))
	  ELSE (SELECT mo.option_value
	  FROM olap_multi_options$ mo
	  WHERE mo.owning_objectid = md.d_top_obj#
	        AND mo.object_type = 1
	        AND mo.option_type = 5
	        AND mo.option_order = md.d_sub_obj#)
	  END
	FROM dual
	)
  ELSE null
  END AS D_SUB_OBJ_NAME2,                       /* END COLUMN D_SUB_OBJ_NAME2 */
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME3 */
  WHEN 18 -- hier_level_map
  THEN (SELECT m.map_name
	FROM olap_mappings$ m, olap_hierarchies$ h, olap_hier_levels$ hl
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = hl.hierarchy_level_id
	      AND hl.hierarchy_id = h.hierarchy_id
	      AND h.dim_obj# = md.d_top_obj#
	)
  WHEN 21 -- member_list_map
  THEN (SELECT 
          (CASE m.mapping_owner_type
           WHEN 14 -- hier_level
           THEN (select m.map_name
                 from olap_hier_levels$ hl, olap_hierarchies$ h, 
                      olap_dim_levels$ dl
                  where m.mapping_owner_id = hl.hierarchy_level_id
	                AND hl.hierarchy_id = h.hierarchy_id
                        AND hl.dim_level_id = dl.level_id
   	                AND h.dim_obj# = md.d_top_obj#)
           ELSE null
           END) AS D_SUB_OBJ_NAME1
 	FROM olap_mappings$ m
 	WHERE m.map_id = md.d_sub_obj#
 	)
  WHEN 17 -- attribute_map
  THEN (SELECT
	  (CASE owner_map.mapping_owner_type
	  WHEN 14 -- hier_level
	  THEN (select owner_map.map_name
		from olap_hier_levels$ hl, olap_hierarchies$ h
		where owner_map.mapping_owner_id = hl.hierarchy_level_id
		      AND hl.hierarchy_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 13 -- hierarchy
	  THEN (select m.map_name
		from olap_hierarchies$ h
		where owner_map.mapping_owner_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  WHEN 12 -- dim_level
	  THEN (select m.map_name
		from olap_dim_levels$ dl
		where owner_map.mapping_owner_id = dl.level_id
		      AND dl.dim_obj# = md.d_top_obj#)
	  ELSE null
	  END) AS D_SUB_OBJ_NAME3
	FROM olap_mappings$ m, olap_mappings$ owner_map
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = owner_map.map_id
       )
  ELSE null
  END AS D_SUB_OBJ_NAME3,                       /* END COLUMN D_SUB_OBJ_NAME3 */
  case md.D_OBJ_TYPE                          /* BEGIN COLUMN D_SUB_OBJ_NAME4 */
  WHEN 17 -- attribute_map
  THEN (SELECT
	  (CASE owner_map.mapping_owner_type
	  WHEN 14 -- hier_level
	  THEN (select m.map_name
		from olap_hier_levels$ hl, olap_hierarchies$ h
		where owner_map.mapping_owner_id = hl.hierarchy_level_id
		      AND hl.hierarchy_id = h.hierarchy_id
		      AND h.dim_obj# = md.d_top_obj#)
	  ELSE null
	  END) AS D_SUB_OBJ_NAME3
	FROM olap_mappings$ m, olap_mappings$ owner_map
	WHERE m.map_id = md.d_sub_obj#
	      AND m.mapping_owner_id = owner_map.map_id
       )
  ELSE null
  END AS D_SUB_OBJ_NAME4,                       /* END COLUMN D_SUB_OBJ_NAME4 */
  decode(md.d_obj_type, '1', 'CUBE',
			'2', 'MEASURE',
			'3', 'MODEL',
			'4', 'ASSIGNMENT',
			'6', 'CALCULATION MEMBER',
                        '10', 'MEASURE FOLDER',
                        '8',  'BUILD PROCESS',
			'11', 'DIMENSION',
			'12', 'DIMENSION LEVEL',
			'13', 'HIERARCHY',
			'14', 'HIERARCHY LEVEL',
			'15', 'ATTRIBUTE',
                        '16', 'DIMENSIONALITY',
			'17', 'ATTRIBUTE MAP',
			'18', 'HIER LEVEL MAP',
			'19', 'SOLVED LEVEL HIER MAP',
			'20', 'SOLVED VALUE HIER MAP',
			'21', 'MEMBER LIST MAP',
			'22', 'CUBE MAP',
			'23', 'CUBE DIMENSIONALITY MAP',
			'24', 'MEASURE MAP',
			'25', 'TABLE OR VIEW',
			'26', 'COLUMN',
                        '27', 'AW DIM ORGANIZATION',
                        '28', 'AW CUBE ORGANIZATION',
                        '29', 'AW',
                        '30', 'SECONDARY PARTITION LEVEL') D_OBJ_TYPE,
  md.P_OWNER P_OBJ_OWNER,
  md.P_TOP_OBJ_NAME P_TOP_OBJ_NAME,
  md.P_SUB_OBJ_NAME1 P_SUB_OBJ_NAME1,
  md.P_SUB_OBJ_NAME2 P_SUB_OBJ_NAME2,
  md.P_SUB_OBJ_NAME3 P_SUB_OBJ_NAME3,
  md.P_SUB_OBJ_NAME4 P_SUB_OBJ_NAME4,
  case md.p_obj_type
  WHEN 25 -- TABLE OR VIEW
       THEN (SELECT decode(o.type#, '4', 'VIEW', 'TABLE')
             FROM obj$ o
             WHERE o.obj# = md.p_obj#
            )
       ELSE decode(md.p_obj_type, '1', 'CUBE',
			'2', 'MEASURE',
			'3', 'MODEL',
			'4', 'ASSIGNMENT',
			'6', 'CALCULATION MEMBER',
                        '8',  'BUILD PROCESS',
                        '10', 'MEASURE FOLDER',
			'11', 'DIMENSION',
			'12', 'DIMENSION LEVEL',
			'13', 'HIERARCHY',
			'14', 'HIERARCHY LEVEL',
			'15', 'ATTRIBUTE',
                        '16', 'DIMENSIONALITY',
			'17', 'ATTRIBUTE MAP',
			'18', 'HIER LEVEL MAP',
			'19', 'SOLVED LEVEL HIER MAP',
			'20', 'SOLVED VALUE HIER MAP',
			'21', 'MEMBER LIST MAP',
			'22', 'CUBE MAP',
			'23', 'CUBE DIMENSIONALITY MAP',
			'24', 'MEASURE MAP',
			'26', 'COLUMN',
                        '27', 'AW DIM ORGANIZATION',
                        '28', 'AW CUBE ORGANIZATION',
                        '29', 'AW') END AS P_OBJ_TYPE,
  decode(md.dep_type, '1', 'CONSISTENT SOLVE SPEC',
                      '2', 'DEFAULT BUILD SPEC',
                      '3', 'BUILD SPEC',
                      '4', 'BUILD PROCESS',
                      '6', 'MEASURE IN MEASURE DIM',
                      '7', 'CUSTOM ORDER',
                      '9', 'TARGET ATTRIBUTE',
                      '10', 'TARGET DIMENSION',
                      '11', 'MEMBER EXPRESSION',
                      '12', 'EXPLICIT DIMENSION',
                      '13', 'PRIMARY DIMENSION',
                      '15', 'MEASURE IN MEASURE FOLDER',
                      '16', 'MEASURE FOLDER SUBFOLDER',
                      '17', 'MAPPED DIMENSION',
                      '18', 'QUERY',
                      '19', 'FROM CLAUSE',
                      '20', 'WHERE CLAUSE',
                      '21', 'JOIN CONDITION',
                      '22', 'LEVEL_ID EXPRESSION',
                      '23', 'KEY EXPRESSION',
                      '24', 'VALUE MAP EXPRESSION',
                      '25', 'LEVEL EXPRESSION',
                      '26', 'PARENT KEY EXPRESSION',
                      '27', 'PARENT LEVEL_ID EXPRESSION',
                      '28', 'MEASURE EXPRESSION',
                      '29', 'NVL EXPRESSION',
                      '30', 'AW',
                      '31', 'AW TABLE',
                      '32', 'PARTITION LEVEL',
                      '33', 'SECONDARY PARTITION LEVEL',
                      '34', 'PRECOMPUTE CONDITION'
                      ) DEPENDENCY_TYPE
FROM 
  olap_metadata_dependencies$ md, 
  obj$ o
WHERE 
  o.obj# = md.d_top_obj#
  AND o.owner#=USERENV('SCHEMAID')
/

comment on table USER_CUBE_DEPENDENCIES is
'OLAP metadata dependencies owned by the user in the database'
/
comment on column USER_CUBE_DEPENDENCIES.D_TOP_OBJ_NAME is
'Name of the top-level object of the dependent metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.D_SUB_OBJ_NAME1 is
'Name of the first sub-object of the dependent metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.D_SUB_OBJ_NAME2 is
'Name of the second sub-object of the dependent metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.D_SUB_OBJ_NAME3 is
'Name of the third sub-object of the dependent metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.D_SUB_OBJ_NAME4 is
'Name of the fourth sub-object of the dependent metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.D_OBJ_TYPE is 
'Type of the dependent metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.P_OBJ_OWNER is
'Owner of the referenced metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.P_TOP_OBJ_NAME is
'Name of the top-level object of the referenced metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.P_SUB_OBJ_NAME1 is
'Name of the first sub-object of the referenced metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.P_SUB_OBJ_NAME2 is
'Name of the second sub-object of the referenced metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.P_SUB_OBJ_NAME3 is
'Name of the third sub-object of the referenced metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.P_SUB_OBJ_NAME4 is
'Name of the fourth sub-object of the referenced metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.P_OBJ_TYPE is
'Type of the referenced metadata object'
/
comment on column USER_CUBE_DEPENDENCIES.DEPENDENCY_TYPE is
'Type of the dependency relationship'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DEPENDENCIES
FOR SYS.USER_CUBE_DEPENDENCIES
/
GRANT READ ON USER_CUBE_DEPENDENCIES to public
/

@@?/rdbms/admin/sqlsessend.sql
