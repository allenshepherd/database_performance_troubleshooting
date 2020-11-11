Rem
Rem $Header: rdbms/admin/catmetx.sql /main/41 2016/11/18 08:01:15 rapayne Exp $
Rem
Rem catmetx.sql
Rem
Rem Copyright (c) 2001, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catmetx.sql - Metadata API: Real definitions for XDB object views.
Rem
Rem    DESCRIPTION
Rem      Metadata API object views for XDB objects
Rem
Rem    NOTES
Rem     For reasons having to do with compatibility, the XDB objects
Rem     cannot be created by catproc.sql; they must instead be created
Rem     by a separate script catqm.sql.  Since catmeta.sql is run
Rem     by catproc.sql, it contains fake object views for XDB objects.
Rem     The real object views are defined in this file which is
Rem     invoked by catxdbv.sql (which is invoked by catqm.sql).
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmetx.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmetx.sql
Rem SQL_PHASE: CATMETX
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catmetinsert.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rapayne     10/20/16 - bug 24926031: fix nls_sort ci problem
Rem    prshanth    06/10/16 - Bug 23479331: recompile packages to make them
Rem                           common again.
Rem    sdavidso    02/12/16 - bug22151959 fix xlm schema-element name
Rem    tbhukya     05/26/15 - Bug 21143649: Long identifier fix
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    cmlim       10/16/14 - bug 19791377: remove 2 out of 3 consecutive flush
Rem                           shared pool for upgrade performance; and move the
Rem                           flush to before recomp_catmeta_views is executed
Rem    mjangir     04/23/14 - bug 18311501:remove comments to fix tpu run issue 
Rem    raeburns    12/31/13 - in upgrade mode, do not recompile metadata views
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    spetride    05/20/10 - lrg 4430944 
Rem    sdavidso    03/26/10 - bug9480755: export dependant xmlschemas
Rem    sdavidso    01/27/10 - Bug 8847153: reduce resources for xmlschema
Rem                           export
Rem    spetride    02/22/10 - XMLSchemaStripUsername signature change
Rem    spetride    01/20/10 - add XMLSCHEMA_LEVEL_VIEW
Rem    htseng      01/21/09 - fix lrg 3756606 for recompile view
Rem    lbarton     12/05/08 - bug 5976472: sql inj
Rem    lbarton     07/01/08 - lrg 3465660
Rem    lbarton     06/09/08 - move xmlschema registration to catmetx2.sql
Rem    lbarton     04/07/08 - add kuscomp.xsd
Rem    rapayne     02/08/08 - bug 6088114 - xmlschema for TYPE_SPECs
Rem    spetride    05/07/07 - bug 5950173 - xmlschema dependencies
Rem    sdavidso    04/17/07 - bug 5950173 - xmlschema dependencies
Rem    bmccarth    04/06/07 - validate args to ku$ view check procedure
Rem                           before executing (bug 597642)
Rem    sdavidso    03/22/07 - 5903231 - maintain binary storage for xmlschemas
Rem    lbarton     01/04/07 - conditional compilation of differ code
Rem    lbarton     03/09/06 - bug 4918185: base xmlschema_view on catalog view 
Rem    abagrawa    03/11/06 - Move dbms_metadata_hack to catxdbh 
Rem    htseng      10/20/05 - register schemas 
Rem    lbarton     09/06/05 - register schemas 
Rem    vkapoor     05/18/05 - LRG 1798757. Freeing some memory 
Rem    ataracha    10/21/04 - ku$_xmlschema_elmt_view - use the base element 
Rem                         - name for ref elements
Rem    spannala    05/20/04 - workaround for disabled xdbhi_idx 
Rem    bmccarth    01/17/03 - add procedure to revalidate ku$ views if needed
Rem    bmccarth    11/15/02 - enable stripusername for url
Rem    amanikut    10/25/02 - specify namespace correctly in extractvalue()
Rem    bmccarth    08/22/02 - XDB 92->main merge - disable (for now)
Rem                           call to stripschema in xdb utility package (not 
Rem                           available yet)
Rem    bmccarth    03/01/02 - add schemaoid to xmlschema
Rem    lbarton     01/16/02 - Merged lbarton_mdapi_xdb
Rem    lbarton     01/15/02 - fix comment
Rem    lbarton     12/03/01 - debug
Rem    lbarton     11/21/01 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- indexes get disabled on compilation of function. Workaround.
alter package xdb.xdb_funcimpl compile;
alter index xdb.xdbhi_idx rebuild;

-- view for xmlschemas
--  this view is used for direct use of MDAPI; not for datapump
create or replace force view sys.ku$_xmlschema_view of sys.ku$_xmlschema_t
  with object identifier (schemaoid) as
  select '1','0',
        u.user#, u.name, x.schema_url, x.schema_id,
        (case when x.local='YES' then 1 else 0 end
         + case when x.binary='YES' then 2 else 0 end),
        xlvl.lvl,                              
        value(s).getClobVal(), 
        xdb.dbms_xdbutil_int.XMLSchemaStripUsername(XMLTYPE(
                                                    value(s).getClobVal()),
                                                    u.name)    -- stripped
    from sys.user$ u, sys.dba_xml_schemas x, xdb.xdb$schema s,
         sys.dba_xmlschema_level_view xlvl
    where x.owner=u.name and xlvl.schema_oid = x.schema_id and 
          s.sys_nc_oid$ = x.schema_id and
          (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0) OR
                EXISTS ( SELECT * FROM session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/
grant read on sys.ku$_xmlschema_view to public
/
-- ku$_table_xmlschema_view is used to find the xmlschemas directly referenced
-- for xmltype columns/tables and dependent schemas referenced.
-- elclude hidden xmlschemas (32768 set in xdb$schema flags)
create or replace  view ku$_table_xmlschema_view as
  select opq.obj# tabobj_num, opq.schemaoid schemaoid, opq.schemaoid par_oid
  from sys.opqtype$ opq
 UNION
  select opq.obj# tabobj_num, sd.dep_schema_oid schemaoid, opq.schemaoid par_oid
  from sys.opqtype$ opq, dba_xml_schema_dependency sd
  start with
    sd.schema_oid=opq.schemaoid and opq.type=1 and opq.schemaoid is not null
  connect by nocycle
    prior sd.dep_schema_oid=sd.schema_oid and 
    prior opq.schemaoid=opq.schemaoid and opq.type=1
/
grant select on ku$_table_xmlschema_view  to select_catalog_role
/
-- view for xmlschemas
--  this view is used for datapump where xmlschemas need to be ordered.
--  also, fetch of the (potentially large) schema definition is defered,
--  to avoid excessive resource consumption during the sort. 
create or replace force view sys.ku$_exp_xmlschema_view of sys.ku$_xmlschema_t
  with object identifier (schemaoid) as
  select '1','0',
        u.user#, u.name, x.schema_url, x.schema_id,
        (case when x.local='YES' then 1 else 0 end
         + case when x.binary='YES' then 2 else 0 end),
        xlvl.lvl,
        null, null
    from sys.user$ u, sys.dba_xml_schemas x, sys.dba_xmlschema_level_view xlvl
    where x.owner=u.name and
          xlvl.schema_oid = x.schema_id and 
          (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0) OR
                EXISTS ( SELECT * FROM session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/
grant read on sys.ku$_exp_xmlschema_view to public
/
create or replace force view sys.ku$_xmlschema_elmt_view
  of sys.ku$_xmlschema_elmt_t with object identifier(schemaoid, elemnum) as
  select 
    opq.obj#,
    opq.intcol#,
    opq.schemaoid,
    extractValue(value(schm), 
        '/schema/@x:schemaURL',
        'xmlns="http://www.w3.org/2001/XMLSchema"'||
          ' xmlns:x="http://xmlns.oracle.com/xdb"'),
    opq.elemnum,
    DBMS_XMLSCHEMA.GetSchemaElementName( opq.schemaoid,opq.elemnum)
  from sys.opqtype$ opq, xdb.xdb$schema schm
  where opq.schemaoid = schm.sys_nc_oid$
/
grant select on sys.ku$_xmlschema_elmt_view to select_catalog_role
/

--
-- view of xmlschema generated types by table
--  This finds xmlschemas (including dependent xmlsschemas) by table,
--  and types for those xmlschemas.
--

create or replace force view sys.ku$_xmlschema_types_view as
  select t.tabobj_num tabobjno, typo.obj_num typeobjno,
         st.typname typename, st.typowner typeowner 
  from (
      select c.xmldata.sqltype typname,
             c.xmldata.sqlschema typowner,
             (select s.sys_nc_oid$ from xdb.xdb$schema s 
              where ref(s)=c.xmldata.parent_schema) tschemaoid
      from xdb.xdb$complex_type c
      union
      select e.xmldata.property.sqlcolltype typname,
             e.xmldata.property.sqlcollschema typowner,
             (select s.sys_nc_oid$ from xdb.xdb$schema s 
              where ref(s)=e.xmldata.property.parent_schema) tschemaoid
      from xdb.xdb$element e
      where
        not exists (select 1
          from xdb.xdb$element e2
          where e2.xmldata.property.sqlcolltype = e.xmldata.property.sqlcolltype
                and e2.xmldata.property.sqlcollschema = 
                     e.xmldata.property.sqlcollschema
                and e2.xmldata.property.parent_schema <>
                     e.xmldata.property.parent_schema) ) st, 
    ku$_schemaobj_view typo, ku$_table_xmlschema_view t
  where st.typname is not null and 
        st.typowner is not null and
        ((st.typowner <> 'XDB') or 
         ((st.typname not like 'XDB$%%') and (st.typname <> 'XMLTYPE'))) and
        typo.name=st.typname and typo.owner_name=st.typowner and
        t.schemaoid=tschemaoid
/
grant select on sys.ku$_xmlschema_types_view to select_catalog_role
/


-- recompile dbms_metadata_int to enable the diffing code
alter package dbms_metadata_int compile plsql_ccflags = 'ku$xml_enabled:true';

-- recompile dbms_metadata_util to enable the xmlschema load code
alter package dbms_metadata_util compile plsql_ccflags = 'ku$xml_enabled:true';

-- Due to recompilation of dbms_metadata_int and dbms_metadata_util with
-- extra compilation flags to enable diffing code, a number of packages which
-- are dependent on dbms_metadata_util/dbms_metadata_int are treated as local
-- objects due to signature mismatch and dependencies involved.
-- These packages have to be recompiled to make them COMMON again. This helps
-- DATAPUMP operations to bypass lockdown.
-- TODO : This is a temporary solution and a more concrete code fix is going
-- to be done later which will automatically resolve these dependecies and mark
-- them COMMON again.
alter package kupw$worker compile;
alter package kupf$file compile;
alter package kupv$ft compile;
alter package kupd$data compile;
alter package kupm$mcp compile;
alter package dbms_metadata_diff compile;
alter package dbms_metadata_build compile;
alter package dbms_logmnr_session_int compile;
alter package dbms_export_extension compile;
alter package dbms_datapump compile;
alter package dbms_metadata_int compile plsql_ccflags = 'ku$xml_enabled:true';

Rem
Rem During the XDB setup, several KU$_ views go invalid, recompile 
Rem them as needed.
Rem (In particular, recompiling dbms_metadata_util causes views that
Rem  reference it to go invalid. - lrg 3465660)
Rem 

CREATE OR REPLACE PROCEDURE recomp_catmeta_views AS
  TYPE cur_type is REF CURSOR;
  data_cursor  cur_type;
  invalid_view DBMS_ID;
  sql_stmt_1   VARCHAR2(1000);
  sql_stmt_2   VARCHAR2(1000);
  my_status    number;

BEGIN
-- 
-- Only get SYS-owned KU$_ views with invalid states
--
  OPEN data_cursor FOR 'SELECT name FROM SYS.OBJ$ WHERE STATUS > 1 ' ||
                       'AND TYPE# = 4 AND owner#=0 AND name like ''KU$_%''';

  sql_stmt_2 := 'select status from sys.obj$ where name = :1 and owner# = 0';

  LOOP

    FETCH data_cursor INTO invalid_view;
    EXIT WHEN data_cursor%NOTFOUND;

    -- The compile of a view will automatically compile any other view which it
    -- references. If we compile a view that already has a success status it 
    -- will invalidate any calling view. Therefore, check if the current view 
    -- still needs to be compiled. 
    execute immediate sql_stmt_2 into my_status using invalid_view;  
    --
    -- the 2 dbms_assert functions are to prevent sql injection
    --
    if my_status > 1 THEN
      sql_stmt_1 := 'ALTER VIEW ' ||
        dbms_assert.enquote_name(dbms_assert.qualified_sql_name(invalid_view)) 
                   || ' COMPILE';
      EXECUTE IMMEDIATE sql_stmt_1;

--      BEGIN
--        EXECUTE IMMEDIATE sql_stmt_1;
--        kupf$file.trace('GOOD', 'View complilation succeeded on ' ||
--                            invalid_view);
--      EXCEPTION
--        WHEN OTHERS THEN
--          IF SQLCODE = -24344 THEN
--            NULL;
--            kupf$file.trace('WARN', 'View complilation warning on ' ||
--                            invalid_view);
--          ELSE
--            kupf$file.trace('FAIL', 'View failed to compile ' ||
--                            invalid_view || ' ' || sqlerrm);
--            RAISE;
--          END IF;
--      END;
--    else
--      kupf$file.trace('SKIP', 'skipping View ' ||
--                            invalid_view);
    end if;
  END LOOP;
  CLOSE data_cursor;
end recomp_catmeta_views;
/

Rem 
Rem Execute then drop the procedure.
Rem

DECLARE
  instance_status varchar2(30);
BEGIN
--  Don't recompile during upgrades, leave for post-upgrade utlrp
  SELECT status into instance_status FROM v$instance;
  if instance_status <> 'OPEN MIGRATE' THEN
     execute immediate 'alter system flush shared_pool';
     recomp_catmeta_views;
  end if;
end;
/

drop procedure recomp_catmeta_views;



@?/rdbms/admin/sqlsessend.sql
