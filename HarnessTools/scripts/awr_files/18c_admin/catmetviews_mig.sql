Rem
Rem $Header: rdbms/admin/catmetviews_mig.sql /main/46 2017/10/20 20:29:23 jstenois Exp $
Rem
Rem catmetviews_mig.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catmetviews_mig.sql - catmet migration views
Rem
Rem    DESCRIPTION
Rem      Creates catmet views whose definitions are dependent on 'new' columns
Rem      in bootstrap tables. Here 'new' means columns which may not exist
Rem      when we begin upgrade from a previous version.
Rem
Rem    NOTES
Rem      This script is run from catmetviews.sql (DB create, upgrade, patch).
Rem      During upgrade, it is run a 2nd time, called from utlmmigtbls.sql.
Rem
Rem      The issue is that in upgrade, when called from catmetviews, new 
Rem      columns in bootstrap tables do not exist. However, the views must 
Rem      create without errors.
Rem
Rem      When called from utlmmigtbls, new columns in bootstrap tables still
Rem      do not exist, but new columns should be referenced. FORCE is
Rem      used so the view is created, and 'success_with_error' is raised.
Rem      When run from utlmmigtbls, props$ has a row with 
Rem      name='BOOTSTRAP_UPGRADE_ERROR'.
Rem      The DB will then be restarted; new columns will exist; the views
Rem      will be recompiled on first reference and all is well.
Rem
Rem    What are 'bootstrap' tables?
Rem      Examine dcore.bsq; search for // right after 'create table bootstrap$'
Rem      You will find: 
Rem        //                          /* "//" required for bootstrap */
Rem
Rem      All tables created prior to and including bootstrap$ are bootstrap
Rem      tables.
Rem
Rem    The bootstap tables, in 12.2 on 2/24/2015 (the list is fairly static):
Rem      tab$                                             /* table table */
Rem      clu$                                           /* cluster table */
Rem      fet$                                       /* free extent table */
Rem      uet$                                       /* used extent table */
Rem      seg$                                           /* segment table */
Rem      undo$                                     /* undo segment table */
Rem      ts$                                         /* tablespace table */
Rem      file$                                             /* file table */
Rem      obj$                                            /* object table */
Rem      ind$                                             /* index table */
Rem      icol$                                     /* index column table */
Rem      col$                                            /* column table */
Rem      user$                                             /* user table */
Rem      proxy_data$
Rem      proxy_role_data$
Rem      con$                                        /* constraint table */
Rem      cdef$                            /* constraint definition table */
Rem      ccol$                                /* constraint column table */
Rem      bootstrap$
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmetviews_mig.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmetviews_mig.sql
Rem SQL_PHASE: CATMETVIEWS_MIG
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catmetviews.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED    MM/DD/YY
Rem    jstenois    09/30/17 - add DATAPUMP_CLOUD_EXP role
Rem    jjanosik    08/11/17 - Bug 26595466: Get original column name for index
Rem                           partition columns
Rem    tbhukya     04/10/17 - Bug 25556006: Partitioned Databound
Rem                           Collation support
Rem    jstenois    03/30/17 - 25410933: pass UID for current user to parse
Rem                           functions
Rem    tbhukya     03/15/17 - Bug 25717130: Get view default collation
Rem    mjangir     12/22/16 - bug 25297023: add unique id for ku$ views
Rem    sdavidso    11/17/16 - bug24702230 p2t support for varchar stored lob
Rem                           bug24707589 p2t lob support for xmltype column
Rem    jjanosik    10/25/16 - Project 34974: support no authentication for user
Rem                           creation
Rem    rapayne     10/20/16 - bug 24926031: fix nls_sort ci problem
Rem    jjanosik    09/20/16 - Bug 24675692: Use nvl in nls_collation_name calls
Rem    bwright     09/08/16 - Bug 24513141: Remove project 30935 implementation
Rem    tbhukya     07/08/16 - Bug 23738844: IOT deferred storage
Rem    thbaby      05/09/16 - Bug 23181611: add crepatchid/modpatchid to OBJ$
Rem    sdavidso    03/04/16 - lrg19304366 remove debug code
Rem    sogugupt    02/26/16 - Bug21944278 use condtional exp in comapre_edition
Rem    sdavidso    02/18/16 - bug22577904 shard P2T - missing constraint
Rem    hmohanku    02/04/16 - bug 22160989: H verifier not generated default
Rem    jjanosik    01/28/16 - bug 18062718 - assign MASFLAG in materialized
Rem                           views based on version
Rem    mstasiew    12/07/15 - Bug 22309211: olap updates objtyp 92->95
Rem    sdavidso    11/24/15 - bug22264616 more move chunk subpart
Rem    aditigu     11/23/15 - Bug 21238674: New column in imsvc$
Rem    tbhukya     11/04/15 - Bug 22125304: Get orignal col name for index
Rem                           when it has virtual collation column
Rem    sdavidso    10/30/15 - bug21869037 chunk move w/subpartitions
Rem    thbaby      10/30/15 - bug 21939181: support for app id/version
Rem    sfeinste    10/22/15 - Bug 22008202: HCS name changes
Rem    jjanosik    10/09/15 - bug 21798129: move ku$_user_base_view and 
Rem                           ku$_user_view to catmetviews_mig
Rem    sdavidso    10/13/15 - bug21943144 upgrade - ku$_schemaobj_view is wrong
Rem    rapayne     08/01/15 - Bug 21147617: expand IM related queries to include
Rem                           new FOR SERVICE syntax for DISTRIBUTE clause.
Rem    sdavidso    08/01/15 - bug21539111: include check constraint for P2T exp
Rem    sdavidso    07/21/15 - bug-20756759: lobs, indexes, droppped tables
Rem    rapayne     06/24/15 - Bug 21290101: Fix type_name decode.
Rem    tbhukya     06/08/15 - Bug 21117759:DBC Use original column name in index
Rem    tbhukya     05/08/15 - Bug 21038781: DBC mv support
Rem    tbhukya     02/25/15 - Proj 47173: Data bound collation
Rem    sdavidso    01/15/15 - proj 56220 - partition transportable
Rem    rapayne     03/02/15 - tab$.property2 xmltoken bits have been moved to
Rem                           tab$.property (see kqld.h)
Rem    rmacnico    01/15/15 - Proj 47506: CELLCACHE
Rem    traney      12/12/14 - 20184217: check for null linkname
Rem    beiyu       11/26/14 - Proj 47091: add HCS objs to ku$_schemaobj_view
Rem    wesmith     05/05/14 - Project 47511: data-bound collation
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    bwright     10/18/13 - Bug 17627666: Add COL_SORTKEY for consistent
Rem                           column ordering with stream and exttbl metadata
Rem    dvekaria    07/18/13 - Bug 15962071: Modify ku$_prim_column_t to hold
Rem                           DEFAULT_VAL expression as varchar or clob.
Rem    sdavidso    04/06/13 - proj42352: DP In-memory columnar
Rem    traney      09/26/12 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-------------------------------------------------------------------------------
--                              SCHEMA OBJECTS
-------------------------------------------------------------------------------

-- create functions to encapsulate some logic common for this module.
-- these are dropped before we exit catmetviews_mig.
CREATE OR REPLACE FUNCTION ku$$column_exists( 
       table_name IN VARCHAR2, 
       col_name IN VARCHAR2) RETURN boolean AS
  col_count NUMBER;
BEGIN
  select count(*) into col_count from col$ c
   where c.obj# = (select o.obj# from obj$ o
                  where o.owner#=0 and name=table_name and o.linkname is null)
         and c.name = col_name;
  return col_count = 1;
END;
/
CREATE OR REPLACE FUNCTION ku$$mig_final RETURN boolean AS
  col_count NUMBER;
BEGIN
  select count(*) into col_count from props$ 
    where name='BOOTSTRAP_UPGRADE_ERROR';
  return col_count = 1;
END;
/
-- view for schema objects

declare
  column_exists_12_1 boolean;
  column_exists_12_2 boolean;
  use_new_cols boolean;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  column_exists_12_1 := ku$$column_exists('OBJ$','SIGNATURE');
  column_exists_12_2 := ku$$column_exists('OBJ$','DFLCOLLID');
  use_new_cols := column_exists_12_2 or ku$$mig_final;
  execute immediate q'!
create or replace force view ku$_edition_obj_view
 (    obj#,
      dataobj#,
      defining_owner#,
      name,
      namespace,
      subname,
      type#,
      ctime,
      mtime,
      stime,
      status,
      remoteowner,
      linkname,
      flags,
      oid$,
      spare1,
      spare2,
      spare3,
      spare4,
      spare5,
      spare6,
      signature,
      spare7,
      spare8,
      spare9,
      dflcollid,
      creappid,
      creverid,
      crepatchid,
      modappid,
      modverid,
      modpatchid,
      spare10,
      spare11,
      spare12,
      spare13,
      spare14,
      owner#,
      defining_edition
 )
as
select o.*,
  !' || -- drop back into PL/SQL to define the columns conditionally
  case 
    when use_new_cols then ''
    when column_exists_12_1 and not column_exists_12_2 then
      'null, null, null, null, null, null, null, null, null, null, null, null, '
    else 'null, 0, 0, 0, null, null, null, null, null, null, null, null, null, null, null, null, '
  end || q'!
       o.spare3,
       case when (o.type# not in (select ue.type# from user_editioning$ ue
                                  where ue.user# = o.spare3) or
                  bitand(o.flags, 1048576) = 1048576 or
                  bitand(u.spare1, 16) = 0) then
         null
       when (u.type# = 2) then
        (select eo.name from obj$ eo where eo.obj# = u.spare2)
       else
        'ORA$BASE'
       end
from obj$ o, user$ u
where o.owner# = u.user#
  and (   /* non-versionable object */
          (   (    o.type# not in (select type# from user_editioning$ ue
                                  where ue.user# = o.spare3)
               and o.type# != 88)
           or bitand(o.flags, 1048576) = 1048576
           or bitand(u.spare1, 16) = 0)
          /* versionable object visible in designated edition */
       or (    o.type# in (select ue.type# from user_editioning$ ue
                           where ue.user# = o.spare3)
           and (   (u.type# <> 2 and
                    (select distinct sys.dbms_metadata.get_edition from dual)
                        = 'ORA$BASE')
                or (u.type# = 2 and
                    u.spare2 =
                        (select distinct sys.dbms_metadata.get_edition_id from dual))
                or exists (select 1 from obj$ o2, user$ u2
                           where o2.type# = 88
                             and o2.dataobj# = o.obj#
                             and o2.owner# = u2.user#
                             and u2.type#  = 2
                             and u2.spare2 =
                        (select distinct sys.dbms_metadata.get_edition_id from dual))
               )
          )
      )
  !';
exception
  when success_with_error then
  if use_new_cols then 
    null;
  else
    raise;
  end if;
end;
/

--
-- FAMILY "EDITION OBJ" - Objects annotated with edition information.
-- These views are based on "_CURRENT_EDITION_OBJ" in cdcore.sql, and
-- are intended for internal use only. The difference from cdcore is
-- that the edition name may be taken from a filter, rather than session
-- context.
--
-- ku$_edition_obj_view - used in place of obj$, when edition semantics
--  are required.
--
-- ku$_edition_schemaobj_view - used in place of ku$_schemaobj, when edition
--  semantics are required.
--
-- In both views, the owner# in is the base user# (not the adjunct schema).
--
-- In modifying our references to OBJ$, we will consider the following
-- substitutions:
--    sys.ku$_edition_obj_view for obj$
--    sys.ku$_edition_schemaobj_view for ku$_schemaobj_view

-- view for schema objects

declare
  use_new_cols       boolean;
  type_name_len      number;
  success_with_error exception;
  objcom             varchar2(10000);
  soobj_tail         varchar2(10000);
  edobj_tail         varchar2(10000);
  pragma exception_init(success_with_error, -24344);
  procedure cre_view(vname VARCHAR2, tname VARCHAR2, tail VARCHAR2) as
    begin
      -- The folowing (put_line) can be very helpful in debug, but fails
      -- if execution is attemted during DB create (dbms_output no available)
      --   so enable as needed!
      --dbms_output.put_line('..create or replace force view ku$_'||vname||'_view of ku$_'||tname||tail);
      execute immediate
        'create or replace force view '||vname||' of ku$_'
        || tname||tail;
    exception
      when success_with_error then
        null;
    end;
begin
  select length into type_name_len from DBA_TYPE_ATTRS where
    TYPE_NAME='KU$_SCHEMAOBJ_T' and
    ATTR_NAME='TYPE_NAME';
  use_new_cols := ku$$column_exists('OBJ$','DFLCOLLID') or ku$$mig_final;

  objcom  :=  q'!
     with object identifier(obj_num) as
     select o.obj#, o.dataobj#, o.owner#, u.name, o.name, o.namespace, o.subname,
         o.type#,
         -- translate type# to name: type# values are defined in kgl.h
         substrb(
         decode(o.type#,
                 0, 'CURSOR',                    1, 'INDEX',
                 2, 'TABLE',                     3, 'CLUSTER',
                 4, 'VIEW',                      5, 'SYNONYM',
                 6, 'SEQUENCE',                  7, 'PROCEDURE',
                 8, 'FUNCTION',                  9, 'PACKAGE',
                11, 'PACKAGE_BODY',             12, 'TRIGGER',
                13, 'TYPE',                     14, 'TYPE_BODY',
                15, 'OBJECT',                   16, 'USER',
                17, 'LINK',                     18, 'PIPE',
                19, 'TABLE PARTITION',          20, 'INDEX PARTITION',
                21, 'LOB',                      22, 'LIBRARY',
                23, 'DIRECTORY',                24, 'QUEUE',
                25, 'IOT',                      26, 'REPLICATION OBJECT GROUP',
                27, 'REPLICATION PROPAGATOR',   28, 'JAVA_SOURCE',
                29, 'JAVA_CLASS',               30, 'JAVA_RESOURCE',
                31, 'JAVA JAR',                 32, 'INDEXTYPE',
                33, 'OPERATOR',                 34, 'TABLE SUBPARTITION',
                35, 'INDEX SUBPARTITION',       36, 'SERVER-SIDE REPAPI',
                37, 'REPLICATION INTERNAL PACKAGE',
                38, 'CONTEXT POLICY OBJECT',
                39, 'PUB_SUB INTERNAL INFORMATION',
                40, 'LOB PARTITION',            41, 'LOB SUBPARTITION',
                42, 'SUMMARY',                  43, 'DIMENSION',
                44, 'CONTEXT',                  45, 'OUTLINE',
                46, 'RULESET OBJECT',           47, 'SCHEDULER PLAN',
                48, 'SCHEDULER CLASS',          49, 'PENDING SCHEDULER PLAN',
                50, 'PENDING SCHEDULER CLASS',  51, 'SUBSCRIPTION INFORMATION',
                52, 'LOCATION INFORMATION',     53, 'REMOTE OBJECTS INFO',
                54, 'REPAPI SNAPSHOT METADATA', 55, 'IFS DATA',
                56, 'JAVA SHARED DATA',         57, 'SECURITY PROFILE',
                58, 'TRANSFORMATION',           59, 'RULE',
                60, 'CAPTURE PROCESS',          61, 'APPLY PROCESS',
                62, 'RULE EVALUATION CONTEXT',  63, 'LOG-BASED REPL SOURCE',
                64, 'STREAM DDL',               65, 'KGL TEST',
                66, 'SCHEDULER JOB',            67, 'SCHEDULER PROGRAM',
                68, 'SCHEDULER CLASS',          69, 'SCHEDULER WINDOW',
                70, 'MULTI-VERSIONED OBJECT',   71, 'SCHEDULER JOB SLAVE',
                72, 'SCHEDULER WINDOW GROUP',   73, 'CDC CHANGE SET',
                74, 'SCHEDULER SCHEDULE',       75, 'SQL TUNING BASE',
                76, 'HINTSET',                  77, 'SCHEDULER ATTRIBUTES',
                78, 'RESOURCE MANAGER CDB PLAN',
                79, 'SCHEDULER JOB CHAIN',      80, 'STRACH PAD',
                81, 'STREAMS FILE GROUP',       82, 'MINING MODEL',
                83, 'SCHEDULER EVENT QUEUE INFO',
                84, 'LIGHT WEIGHT SESSION',     85, 'DATA SECURITY DOCUMENT',
                86, 'SECURITY CLASS',           87, 'ASSEMBLY',
                88, 'STUB',                     89, 'LIGHTWEIGHT JOBS',
                90, 'CREDENTIAL',               91, 'REMOTE OBJECT REFERENCE',
                92, 'CUBE DIMENSION',           93, 'CUBE',
                94, 'MEASURE FOLDER',           95, 'CUBE BUILD PROCESS',
                96, 'STREAM PROPAGATION',       97, 'FUSION XS PARAMETERS',
                98, 'XDB REPOSITORY',           99, 'OBJECT ID',
                100, 'SCHEDULER FILE WATCHER',
                101, 'JOB SCHEDULER NAMED DESTINATION',
                102, 'CURSOR STATS',            103, 'TEXT MVDATA CACHE ',
                104, 'TEXT MVDATA -M    ',      105, 'TEXT MVDATA -F    ',
                106, 'TABLE-INDEX PARTITION CACHE',
                107, 'SPATIAL INDEX METADATA',
                108, 'FUSION XS NAMESPACE TEMPLATES',
                109, 'FUSION XS SECURITY CLASS',
                110, 'FUSION SECURITY ACL',     111, 'PLUGGABLE DATABASE',
                112, 'SPATIAL GEOM METADATA',   113, 'SPATIAL SRID METADATA',
                114, 'SQL TRANSLATION PROFILE', 115, 'AUDIT POLICY',
                116, 'SPATIAL FEATURE USAGE',
                117, 'SPATIAL CRS DIMENSION METADATA',
                118, 'SCHEDULER IN-MEMORY JOBS',
                119, 'OLS ILABELS',
                120, 'OLS GROUP NUMBER TO SHORT NAME MAPPINGS',
                121, 'OLS GROUP SHORT NAME TO NUMBER MAPPINGS',
                122, 'OLS COMPARTMENT NUMBER TO SHORT NAME MAPPINGS',
                123, 'OLS COMPARTMENT SHORT NAME TO NUMBER MAPPINGS',
                124, 'OLS LEVEL NUMBER TO SHORT NAME MAPPINGS',
                125, 'OLS LEVEL SHORT NAME TO NUMBER MAPPINGS',
                126, 'OPTIMIZER FINDING',       127, 'OPTIMIZER DIRECTIVE OWNER',
                128, 'OLS USERS',               129, 'DATABASE VAULT RULE',
                130, 'DATABASE VAULT RULE SET',
                131, 'LABEL SECURITY POLICY-TABLE CACHE',
                132, 'LABEL SECURITY LABEL-PID CACHE',
                133, 'OLS READ CONTROL RELATED CACHE',
                134, 'OLS$AUDIT OPTIONS',       135, 'USER PRIVILEGE',
                136, 'SCHEDULER RESOURCE CONSTRAINT',
                137, 'QUEUE DURABLE SUBSCRIBERS',
                150, 'HIERARCHY',
                151, 'ATTRIBUTE DIMENSION',
                152, 'ANALYTIC VIEW',
                153, 'INMEMORY TABLE COMPRESSION',
                154, 'EXPRESSION HEADER',
                155, 'EXPRESSION OBJECT',
                     'ERROR'),1,
         !' || type_name_len || q'! ),
         to_char(o.ctime,'YYYY-MM-DD HH24:MI:SS'),
         to_char(o.mtime,'YYYY-MM-DD HH24:MI:SS'),
         to_char(o.stime,'YYYY-MM-DD HH24:MI:SS'),
         o.status, o.remoteowner,
         o.linkname, o.flags, o.oid$,
         o.spare1, o.spare2, o.spare3,
         o.spare4, o.spare5, to_char(o.spare6,'YYYY/MM/DD HH24:MI:SS'),
         case when (o.spare3 > 0) then
             (select u.name from user$ u where o.spare3 = u.user#)
         else null
         end,
  !' || -- drop back into PL/SQL to define the columns conditionally
  case
    when use_new_cols then 
'         o.signature, o.spare7, o.spare8, o.spare9,
         nls_collation_name(nvl(o.dflcollid, 16382)),
         o.spare10, o.spare11, o.spare12, o.spare13, o.spare14
' 
    else 'null, 0, 0, 0,null,null,null,null,null,null
' 
  end;

  soobj_tail := q'!
     from obj$ o, user$ u
     where o.owner# = u.user# !';
  edobj_tail := q'!
     from sys.ku$_edition_obj_view o, user$ u
     where o.owner# = u.user# !';

  cre_view('ku$_schemaobj_view',        'schemaobj_t', objcom || soobj_tail);
  cre_view('ku$_edition_schemaobj_view','schemaobj_t', objcom || edobj_tail);
end;
/

-------------------------------------------------------------------------------
--                              TABLE COLUMNS
-------------------------------------------------------------------------------

-- views for table level columns metadata
--  ku$_prim_column_view - columns of tables with only scalar columns
--      (no partitioning, LOBs or UDTs).
--  ku$_column_view - columns of more complex tables, not partitioned
--  ku$_pcolumn_view - columns of partitioned tables
--  ku$_p2tpartcol_view - partitioned lob columns for promotion to a table
--  ku$_sp2tpartcol_view - subpartitioned lob columns for promotion to a table
-- also
--  ku$_p2tcolumn_view - columns of partition to table promotion
--  ku$_sp2tcolumn_view - columns of subpartition to table promotion
--
-- Each column has a constraint ADT embedded in it if the column has
-- a not-null constraint.  If there is no such constraint,
-- the constraint attribute evaluates to null.  Other constraints
-- are in the table UDT.

--set serveroutput on linesize 8000 pagesize 0 trimspool on termout off echo on
--spool column_views.sql
declare
  use_new_cols boolean;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
  col_comm   varchar2(10000);
  col_prim   varchar2(10000);
  col_full   varchar2(10000);
  col_lob    varchar2(10000);
  col_nplob  varchar2(10000);
  col_parlob varchar2(10000);
  col_p2tlob varchar2(10000);
  col_tail   varchar2(10000);
  promote_tail varchar2(10000);
  p2t_tail   varchar2(10000);
  sp2t_tail   varchar2(10000);
  procedure cre_view(vname VARCHAR2, tail VARCHAR2) as
    begin
     -- One of the following (put_line) can be very helpful in debug, but fails
     -- if execution is attempted during DB create (dbms_output not available)
     --   so enable as needed!
-- dbms_output.put_line('..create or replace force view ku$_'||vname||'_view');
--
--- For this, you may want to spool output and disable the 'execute immediate'.
--- Then you can run the DDL directly from sqlplus.
--    dbms_output.put_line('create or replace view '||vname||tail);
      execute immediate  'create or replace force view '||vname||tail;
    exception
      when success_with_error then
        null;
    end;
begin
  use_new_cols := ku$$column_exists('COL$','COLLID') or ku$$mig_final;

-- {obj,col,intcol,segcol}_num, segcollength, offset, property, name
col_comm :=  q'! of ku$_tab_column_t
  with object identifier (obj_num,intcol_num) as
  select c.obj#, c.col#, c.intcol#, c.segcol#,
         c.segcollength, c.offset,
         bitand(c.property, 4294967295),
         trunc(c.property / power(2,32)),
         c.name, 
      -- type, length ... charsetid, charsetform
         c.type#, c.length, c.fixedstorage,
         c.precision#, c.scale, c.null$, c.deflength,
         case
           when c.deflength > 4000 
           then null
           else
             sys.dbms_metadata_util.long2varchar(c.deflength,
                                                 'SYS.COL$',
                                                 'DEFAULT$',
                                                  c.rowid)
         end, 
         case 
           when c.deflength <= 4000
           then null
           else
             sys.dbms_metadata_util.long2clob(c.deflength,
                                              'SYS.COL$',
                                              'DEFAULT$',
                                              c.rowid)
         end,
         case
           when c.deflength is null or bitand(c.property,32+65536)=0
           then null
           else
             (select sys.dbms_metadata.parse_default
                        (SYS_CONTEXT('USERENV','CURRENT_USERID'),u.name,o.name,
                                     c.deflength, c.rowid)
              from obj$ o, user$ u
              where o.obj#=c.obj# and o.owner#=u.user#)
         end,
         sys.dbms_metadata_util.blob2clob(c.obj#,c.intcol#, c.property),
         (select e.guard_id from ecol$ e where e.tabobj#=c.obj# and e.colnum=c.intcol#),
         c.charsetid, c.charsetform,
       -- column constraints
         ( select value(cv)
             from ku$_constraint_col_view ccv, ku$_constraint0_view cv
             where c.intcol# = ccv.intcol_num
             and c.obj# = ccv.obj_num
             and ccv.con_num = cv.con_num
             and cv.contype in (7,11)
         ),
      -- spare1-6, identity_col, edition numbers, attrname2, col_sortkey
         c.spare1, c.spare2, c.spare3, c.spare4, c.spare5,
         to_char(c.spare6,'YYYY/MM/DD HH24:MI:SS'),
         case when (bitand(c.property,137438953472+274877906944)!=0) then
             (select value(i) from ku$_identity_col_view i
                              where i.obj_num = c.obj#)
         else null end, !' ||
         case when use_new_cols then 
           'nvl(evaledition#,0),
            nvl(unusablebefore#,0),
            nvl(unusablebeginning#,0)'
         else '0, 0, 0' end || q'!,
         -- If column has the properties ((ADT attribute, hidden, system
         -- generated) or (type id, ADT attribute, hidden)), then
         -- this column may be part of an unpacked anydata type. 
         case when (bitand(c.property,289) = 289  or
                    bitand(c.property,33554465) = 33554465) then 
            sys.dbms_metadata_util.get_attrname2(c.obj#, c.intcol#, c.col#)
          else
            NULL
         end,
         -- Column sortkey: in principle we want to sort by segcol#, but 
         -- segcol# for xmltype is 0 so replace it with the segcol# of its 
         -- underlying lob or object rel column that contains the actual
         -- data.  This query needs to be identical to the one for the 
         -- col_sorkey column in ku$_strmtable_view in order to ensure that
         -- lob columns are ordered identically when writing to and reading
         -- from dump files (bug# 12998987, 17627666).
         case when (c.segcol# = 0 and c.type# = 58) then
          NVL((select cc.segcol# from col$ cc, opqtype$ opq
              where opq.obj#=c.obj#
                and opq.intcol#=c.intcol#
                and opq.type=1
                and cc.intcol#=opq.lobcol    -- xmltype stored as lob
                and cc.obj#=c.obj#),
                (NVL((select cc.segcol# from col$ cc, opqtype$ opq
                      where opq.obj#=c.obj#
                        and opq.intcol#=c.intcol#
                        and opq.type=1
                        and cc.intcol#=opq.objcol  -- xmltype stored obj rel
                        and bitand(opq.flags,1)=1
                        and cc.obj#=c.obj#),0)))
         else c.segcol# 
         end,
        !' ||
         case when use_new_cols then '
           nls_collation_name(nvl(c.collid, 16382)),
           c.collintcol#
        ' else 'null,0' end || q'!, !';
col_prim := q'!
      -- attrname, fullattrname, base_col_{num, type, name}
         NULL,     NULL,     c.intcol#,    0, NULL,
      -- typemd, lobmd, opqmd, oidindex, plobmd (for primitive)
         NULL,NULL,NULL,NULL,NULL,NULL
!';



-- elements not needed for 'primitive' columns
-- attranme, fullattrname, base_{intcol_num,col_type,col_name},
--  typemd, oidindex,
col_full := q'!
         sys.dbms_metadata_util.get_attrname(
                        c.obj#, c.intcol#),
         sys.dbms_metadata_util.get_fullattrname(
                        c.obj#, c.col#, c.intcol#, c.type#),
      -- base column info - intcol_num, type, name (not for primitive columns)
         case c.col# when c.intcol# then c.intcol#
                     when 0 then c.intcol#
          else sys.dbms_metadata_util.get_base_intcol_num(c.obj#,c.col#,
                                                          c.intcol#,c.type#)
         end,
         case c.col# when 0 then 0
          else
            sys.dbms_metadata_util.get_base_col_type(c.obj#,c.col#,
                                                          c.intcol#,c.type#)
         end,
         case c.col#
          when c.intcol# then NULL
          when 0 then NULL
          else
            sys.dbms_metadata_util.get_base_col_name(c.obj#,c.col#,
                                                          c.intcol#,c.type#)
         end,
       -- typemd, lobmd, opqmd, oidindex (not for primitive)
         ( select value(ctv)
             from ku$_coltype_view ctv
             where c.type# in ( 121,    -- DTYADT  (user-defined type)
                                122,    -- DTYNTB  (nested table)
                                123,    -- DTYNAR  (varray)
                                111,    -- DTYIREF (REF)
                                 58)    -- DTYOPQ  (opaque type)
             and   c.obj#  = ctv.obj_num
             and   c.intcol# = ctv.intcol_num
         ),
         ( select value(oi)
             from ku$_oidindex_view oi
             where bitand(c.property, 2) = 2
             and   c.obj# = oi.obj_num
             and   c.intcol# = oi.intcol_num
         ),!';

-- lobmd, opqmd
col_lob := q'!
      --  lobmd
         ( select value(lv)
             from ku$_lob_view lv
             where (c.type# in (112,    -- CLOB
                                113,    -- BLOB
                                123)    -- DTYNAR  (varray)
                    and   c.obj#  = lv.obj_num
                    and   c.intcol# = lv.intcol_num)
             or    (c.type# = 58        -- DTYOPQ (XML type)
                    and   c.obj#  = lv.obj_num
                    and   lv.intcol_num =
                          (select op.lobcol from sys.opqtype$ op
                                    where op.obj# = c.obj#
                                    and   bitand(op.flags,4) != 0
                                    and   op.intcol# = c.intcol#)
                    )
             or    (c.type# = 58        -- DTYOPQ (opaque type)
                    and   c.obj#  = lv.obj_num
                    and   c.intcol# = lv.intcol_num
                    and   EXISTS (
                          SELECT  1
                          FROM    sys.opqtype$ op
                          WHERE  op.obj# = c.obj#
                                 and   op.intcol# = c.intcol#
                                 and   op.type = 0 )
                    )
             or    (c.type# in (1,         -- VARCHAR2
                                23)        -- RAW
                    and   bitand(c.property,128)!=0 -- stored as lob (long var)
                    and   c.obj#  = lv.obj_num
                    and   c.intcol# = lv.intcol_num
                    )
         ),
       -- opqmd
         ( select value(opq) from sys.ku$_opqtype_view opq
             where c.type# = 58        -- DTYOPQ (opaque type)
             and   c.obj# = opq.obj_num
             and   c.intcol# = opq.intcol_num
         ),!';
col_nplob := q'!
       -- plobmd, part_objnum
         NULL, NULL !';

-- lobmd, opqmd, plobmd (partitioned lob info ), part_objnum
col_parlob := q'!
       -- plobmd, part_objnum
         ( select value(lv)
             from ku$_partlob_view lv
             where (c.type# in (112,    -- CLOB
                                113,    -- BLOB
                                123)    -- DTYNAR  (varray)
                    and   c.obj#  = lv.obj_num
                    and   c.intcol# = lv.intcol_num)
             or    (c.type# = 58        -- DTYOPQ (XML type)
                    and   c.obj#  = lv.obj_num
                    and   lv.intcol_num =
                          (select op.lobcol from sys.opqtype$ op
                                    where op.obj# = c.obj#
                                    and   bitand(op.flags,4) != 0
                                    and   op.intcol# = c.intcol#)
                    )
             or    (c.type# = 58        -- DTYOPQ (opaque type)
                    and   c.obj#  = lv.obj_num
                    and   c.intcol# = lv.intcol_num
                    and   EXISTS (
                          SELECT  1
                          FROM    sys.opqtype$ op
                          WHERE  op.obj# = c.obj#
                                 and   op.intcol# = c.intcol#
                                 and   op.type = 0 )
                    )
             or    (c.type# in (1,          -- VARCHAR2
                                23)         -- RAW
                    and   bitand(c.property,128)!=0 -- stored as lob (long var)
                    and   c.obj#  = lv.obj_num
                    and   c.intcol# = lv.intcol_num
                    )
         ),NULL
!';
-- lobmd, opqmd, plobmd (partitioned lob info ), part_objnum
col_p2tlob := q'!
       -- lobmd, opqmd
         value(lv),
         ( select value(opq) from sys.ku$_opqtype_view opq
             where c.type# = 58        -- DTYOPQ (opaque type)
             and   c.obj# = opq.obj_num
             and   c.intcol# = opq.intcol_num
         ),
         NULL, NULL
!';
col_tail := q'!  from col$ c !' ||
  case when use_new_cols then
  'where (((
     case
         when  nvl(unusablebefore#,0) = 0 then (0)
         else  dbms_editions_utilities.compare_edition(
               dbms_metadata.get_edition_id, unusablebefore#)
         end) in (0,2) )
      and((
      case
           when nvl(unusablebeginning#,0) = 0 then (1)
           else dbms_editions_utilities.compare_edition(
                dbms_metadata.get_edition_id, unusablebeginning#)
      end) = 1  ))'
  else ''
  end;
promote_tail := q'!
 where 
    c.obj#  = lv.base_obj_num and
    ((c.type# in (1,23,58,112,113) and c.intcol# = lv.intcol_num) or
     (c.type# = 58 and 
      lv.intcol_num = ( select opq.lobcol 
                        from sys.ku$_opqtype_view opq
                        where c.obj# = opq.obj_num
                          and c.intcol# = opq.intcol_num ))) !' ||
  case when use_new_cols then
  'and (((
     case
         when  nvl(unusablebefore#,0) = 0 then (0)
         else  dbms_editions_utilities.compare_edition(
               dbms_metadata.get_edition_id, unusablebefore#)
         end) in (0,2) )
      and((
      case
           when nvl(unusablebeginning#,0) = 0 then (1)
           else dbms_editions_utilities.compare_edition(
                dbms_metadata.get_edition_id, unusablebeginning#)
      end) = 1  ))'
  else ''
  end;
p2t_tail  := q'!  from col$ c, ku$_p2tlob_view lv !' || promote_tail;
sp2t_tail := q'!  from col$ c, ku$_sp2tlob_view lv !' || promote_tail;

  --scalar columns
  cre_view('ku$_prim_column_view',
     col_comm||col_prim            ||col_tail);
  --full non-partitioned table 
  cre_view('ku$_column_view',
     col_comm||col_full||col_lob||col_nplob ||col_tail);
  --full partitioned table 
  cre_view('ku$_pcolumn_view',
     col_comm||col_full||col_lob||col_parlob||col_tail);
  --full p2t 
  cre_view('ku$_p2tpartcol_view',
     col_comm||col_full||col_p2tlob||p2t_tail);
  --full sp2t 
  cre_view('ku$_sp2tpartcol_view',
     col_comm||col_full||col_p2tlob||sp2t_tail);
end;
/
--spool off
--set echo off linesize 120 pagesize 0 termout on

-- This is the foundation for a number of different
-- column variants and is sufficient for simple column name lists.

-- view to get a simple set of column attributes.
-- NOTE: Originally we had just an attribute called 'name' that was either
-- c.name or attrcol$.name selected via a DECODE of c.property bit 1.
-- However, for an as yet unexplained reason, this causes a full table scan
-- on col$ in outer views that used this view.
declare
  use_new_cols boolean;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  use_new_cols := ku$$column_exists('COL$','COLLINTCOL#') or ku$$mig_final;
execute immediate q'!
  create or replace force view ku$_simple_col_view of ku$_simple_col_t
   with object identifier (obj_num,intcol_num) as
   select c.obj#,
          c.col#,
          c.intcol#,
          c.segcol#,
          bitand(c.property, 4294967295),
          trunc(c.property / power(2,32)),
          c.name,
          case
           when c.type#=123 or c.type#=122 or c.type#=112
           then sys.dbms_metadata_util.get_fullattrname(
                         c.obj#, c.col#, c.intcol#, c.type#)
           else sys.dbms_metadata_util.get_attrname(
                         c.obj#, c.intcol#)
          end,
          c.type#,
          c.deflength,
          case
            when c.deflength is null or bitand(c.property,32+65536)=0
                 or c.deflength > 4000
            then null
            else
              sys.dbms_metadata_util.func_index_default(c.deflength,
                                                        c.rowid)
          end,
          case
            when c.deflength is null or bitand(c.property,32+65536)=0
                 or c.deflength <= 4000
            then null
            when c.deflength <= 32000
            then
              sys.dbms_metadata_util.func_index_defaultc(c.deflength,
                                                         c.rowid)
            else
              sys.dbms_metadata_util.long2clob(c.deflength,
                                               'SYS.COL$',
                                               'DEFAULT$',
                                               c.rowid)
          end,
          case
            when c.deflength is null or bitand(c.property,32+65536)=0
            then null
            else
             (select sys.dbms_metadata.parse_default(
                                 SYS_CONTEXT('USERENV','CURRENT_USERID'),
                                 u.name,o.name,c.deflength,c.rowid)
              from obj$ o, user$ u
              where o.obj#=c.obj# and o.owner#=u.user#)
          end,
          !' ||
          case when use_new_cols then '
               (select c1.name from col$ c1
                    where c1.intcol#=c.collintcol# and
                          c1.obj#=c.obj#)
         ' else 'null' end || q'!
  from col$ c
!';
exception
  when success_with_error then
    null;
end;
/

declare
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
execute immediate q'!
 create or replace force view ku$_p2tcolumn_view of ku$_tab_column_t
   with object identifier (obj_num,intcol_num) as
 select *
 from ku$_p2tpartcol_view c
UNION ALL
 select *
 from ku$_column_view c
 where not (c.type_num in (112,113)
            or (c.type_num = 58 and 
                EXISTS ( SELECT 1
                         from sys.opqtype$ op
                         where op.obj#=c.obj_num and op.intcol#=c.intcol_num
                               and (op.type != 1 or (bitand(op.flags,4) = 0) )
            or (c.type_num in (1,23) and  bitand(c.property,128)!=0))))
  !';
exception
  when success_with_error then
    null;
end;
/

declare
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
execute immediate q'!
 create or replace force view ku$_sp2tcolumn_view of ku$_tab_column_t
   with object identifier (obj_num,intcol_num) as
 select *
 from ku$_sp2tpartcol_view c
UNION ALL
 select *
 from ku$_column_view c
 where not (c.type_num in (112,113)
            or (c.type_num = 58 and 
                EXISTS ( SELECT 1
                         from sys.opqtype$ op
                         where op.obj#=c.obj_num and op.intcol#=c.intcol_num
                               and (op.type != 1 or (bitand(op.flags,4) = 0) )
            or (c.type_num in (1,23) and  bitand(c.property,128)!=0))))
  !';
exception
  when success_with_error then
    null;
end;
/

-- view for deferred storage UDT
-- moved view ku$_deferred_stg_view to catmetviews_mig.sql
declare
  use_new_cols boolean;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  use_new_cols := ku$$column_exists('DEFERRED_STG$','FLAGS2_STG')
                  or ku$$mig_final;
  execute immediate q'!
create or replace force view ku$_deferred_stg_view
  of ku$_deferred_stg_t
  with object identifier (obj_num) as select
  obj#          ,                            /* object number */
  pctfree_stg   ,                                  /* PCTFREE */
  pctused_stg   ,                                  /* PCTUSED */
  size_stg      ,                                     /* SIZE */
  initial_stg   ,                                  /* INITIAL */
  next_stg      ,                                     /* NEXT */
  minext_stg    ,                               /* MINEXTENTS */
  maxext_stg    ,                               /* MAXEXTENTS */
  maxsiz_stg    ,                                  /* MAXSIZE */
  lobret_stg    ,                             /* LOBRETENTION */
  mintim_stg    ,                                  /* MIN tim */
  pctinc_stg    ,                              /* PCTINCREASE */
  initra_stg    ,                                 /* INITRANS */
  maxtra_stg    ,                                 /* MAXTRANS */
  optimal_stg   ,                                  /* OPTIMAL */
  decode(maxins_stg,0,1,maxins_stg) ,      /* FREELIST GROUPS */
  decode(frlins_stg,0,1,frlins_stg) ,            /* FREELISTS */
  flags_stg     ,                                    /* flags */
  bfp_stg       ,                              /* BUFFER_POOL */
  enc_stg       ,                               /* encryption */
  cmpflag_stg   ,                         /* compression type */
  cmplvl_stg    ,                        /* compression level */ !' ||
  case when use_new_cols then
  ' imcflag_stg ,
    ccflag_stg  ,
    flags2_stg
'
  else ' 0, 0, 0
'
  end || q'!
 from sys.deferred_stg$
  !';
exception
  when success_with_error then
    null;
end;
/

--
-- Views for TABLEs
--
-- Here is code to create 7 views for various types of table.
-- Mostly the differing views are used to improve performance, as most
-- table metadata can be extracted with relatively simple views.
--
-- ku$_htable_view - primitive, non-partitioned Heap TABLEs
-- ku$_phtable_view - primitive, Partitioned Heap TABLEs
-- ku$_fhtable_view - Full (i.e., non-primitive), non-partitioned Heap TABLEs
-- ku$_pfhtable_view - Partitioned, Full (i.e., non-primitive) Heap TABLEs
-- ku$_acptable_view - Reference partitioned child tables -- like pfhtable, but
--   These need special treatment for proper ordering (i.e., refapr_level).
--  NOTE THIS HACK---
--   The special treatment includes naming the view so it will be exported last,
--   based on in alpha sort of table view names (in hetero object script loading)!
--   So 'A' for sorting, the 'cp' for child [ref] partitioning
-- ku$_iotable_view - non-partitioned Index-Organized TABLEs
-- ku$_piotable_view - partitioned Index-Organized TABLEs
--
-- The view, ku$_10_2_fhtable_view, excludes column attributes that are part 
-- of the subtype, sql_plan_allstat_row_type. In 11g, SQL Tuning introduced 
-- this new subtype as well as the ability for customers to export a SQL Tuning
-- Set(STS) to 10.2.  To support this new feature, expdp must not export this
-- new subtype to 10.2 since it does not exist in 10.2.
--
--set serveroutput on lines 10000 pages 10000 trimspool on
--spool table_views.sql
declare
  use_new_cols   boolean;
  tabcom         varchar2(10000);
  p2t_tabcom     varchar2(10000);
  tab_stor       varchar2(10000);
  iotab_stor     varchar2(10000);
  p2t_stor       varchar2(10000);
 sp2t_stor       varchar2(10000);
  prim_col_list  varchar2(10000);
  col_list       varchar2(10000);
  col_list_10_2  varchar2(10000);
  pcol_list      varchar2(10000);
  p2tcol_list    varchar2(10000);
 sp2tcol_list    varchar2(10000);
  full_list      varchar2(10000);
  prim_list      varchar2(10000);
  ref_par        varchar2(10000);
  noref_par      varchar2(10000);
  objgrant       varchar2(10000);
  noobjgrant     varchar2(10000);
  iot_comm       varchar2(10000);
  noiot_comm     varchar2(10000);
  hpart          varchar2(10000);
  iopart         varchar2(10000);
  p2t_part       varchar2(10000);
 sp2t_part       varchar2(10000);
  nopart         varchar2(10000);
  htail          varchar2(10000);
  phtail         varchar2(10000);
  fhtail         varchar2(10000);
  pfhtail        varchar2(10000);
  iotail         varchar2(10000);
  piotail        varchar2(10000);
  acptail        varchar2(10000);
  p2ttail        varchar2(10000);
-- for subpartition to table promotion, pieces of the table view are identical to
-- partition to table promotion, except that we take values from ku$_tab_subpart_view
-- rather than from ku$_tab_part_view. This is handled in p2ttail/sp2ttail.
 sp2ttail        varchar2(10000);
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
  procedure cre_view(vname VARCHAR2, tname VARCHAR2, tail VARCHAR2) as
    begin
      -- The folowing (put_line) can be very helpful in debug, but fails
      -- if execution is attemted during DB create (dbms_output not available)
      --   so enable as needed!
--  dbms_output.put_line('..create or replace force view 
--    '||vname||' of ku$_'||tname);
--  dbms_output.put_line('create or replace view '||
--       vname||' of ku$_'||tname||tail||';
--show errors
--');
      -- objects types used: ku$_table_t, ku$_partition_t, ku$_io_table_t
      execute immediate 
        'create or replace force view '||vname||' of ku$_'||tname||tail;
    exception
      when success_with_error then
        null;
    end;
begin
  use_new_cols := ku$$column_exists('TAB$','SPARE10') or ku$$mig_final;
  tabcom := q'!
  with object OID(obj_num)
 as select '2','8',
         t.obj#,
         value(o),
         -- if this is a secondary table, get base obj and ancestor obj
         decode(bitand(o.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, secobj$ s
              where o.obj_num=s.secobj#
                and oo.obj_num=s.obj#
                and rownum < 2),
           null),
         decode(bitand(o.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, ind$ i, secobj$ s
              where o.obj_num=s.secobj#
                and i.obj#=s.obj#
                and oo.obj_num=i.bo#
                and rownum < 2),
           null),
        /* -- */
         t.bobj#, t.tab#, t.cols,
         t.clucols,
         (select value(cl) from ku$_tabcluster_view cl
          where cl.obj_num = t.obj#),
        /* fba  - flashback archive, table clustering, ILM */
         (select value(fb) from ku$_fba_view fb where fb.obj_num = t.obj#),
         cast( multiset(select * from ku$_fba_period_view fb
                        where fb.obj_num = t.obj#
                        order by fb.periodname
                        ) as ku$_fba_period_list_t
             ),
         (select value(cz) from ku$_clst_view cz where cz.obj_num = t.obj#),
         cast( multiset(select * from ku$_ilm_policy_view p
                        where p.obj_num = t.obj#
                        order by p.policy_num
                        ) as ku$_ilm_policy_list_t
              ),
         t.flags,
         replace(t.audit$,chr(0),'-'), t.rowcnt, t.blkcnt, t.empcnt,
         t.avgspc, t.chncnt, t.avgrln, t.avgspc_flb, t.flbcnt,
         to_char(t.analyzetime,'YYYY/MM/DD HH24:MI:SS'),
         t.samplesize, t.degree, t.instances, t.intcols, t.kernelcols,
         (select sys.dbms_metadata_util.has_tstz_cols(t.obj#) from dual),
         t.trigflag,
         t.spare1, t.spare2, t.spare3, t.spare4, t.spare5,
         to_char(t.spare6,'YYYY/MM/DD HH24:MI:SS'),  !' ||
         case when use_new_cols then
                   't.spare7,t.spare8,t.spare9,t.spare10,'
              else
                   'NULL,NULL,NULL,NULL,'
         end || q'!
         decode(bitand(t.trigflag, 65536), 65536,
           (select e.encalg from sys.enc$ e where e.obj#=t.obj#),
           null),
         decode(bitand(t.trigflag, 65536), 65536,
           (select e.intalg from sys.enc$ e where e.obj#=t.obj#),
           null),
         cast( multiset(select * from ku$_im_colsel_view imc
                        where imc.obj_num = t.obj#
                       ) as ku$_im_colsel_list_t
             ),
         cast( multiset(select * from ku$_constraint0_view con
                        where con.obj_num = t.obj#
                        and con.contype not in (7,11)
                       ) as ku$_constraint0_list_t
             ),
         cast( multiset(select * from ku$_constraint2_view con
                        where con.obj_num = t.obj#
                       ) as ku$_constraint2_list_t
             ),
         (select value(etv) from ku$_exttab_view etv
                        where etv.obj_num = o.obj_num),
         (select value(otv) from ku$_cube_tab_view otv
                        where otv.obj_num = o.obj_num),
         (select svcname  from imsvc$ where obj# = t.obj# and subpart# is null),
         (select svcflags from imsvc$ where obj# = t.obj# and subpart# is null),!';
p2t_tabcom := regexp_replace(tabcom,
                             'ku\$_constraint2_view',
                             'ku$_p2t_constraint2_view');
tab_stor := q'!
      /* storage and deferred storage (at most one will be found), tablespace name/blocksize */
         bitand(t.property, (power(2, 32)-1)),
         bitand(trunc(t.property / power(2, 32)), (power(2, 32)-1)),
         trunc(t.property / power(2, 64)),
         (select value(s) from ku$_storage_view s
          where t.file# = s.file_num
          and t.block#  = s.block_num
          and t.ts#     = s.ts_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = t.obj#),
         ts.name, ts.blocksize,
         t.dataobj#,
         t.pctfree$, t.pctused$, t.initrans, t.maxtrans,
         cast( multiset(select * from ku$_constraint1_view con
                        where con.obj_num = t.obj#
                       ) as ku$_constraint1_list_t
             ),!';
iotab_stor := q'!
      /* storage, deferred_storage, tablespace name/blocksize */
         bitand(t.property, (power(2, 32)-1)),
         bitand(trunc(t.property / power(2, 32)), (power(2, 32)-1)),
         trunc(t.property / power(2, 64)),
         (select value(s) from ku$_storage_view s
          where i.file# = s.file_num
          and i.block#  = s.block_num
          and i.ts#     = s.ts_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = i.obj#),
         ts.name, ts.blocksize,
         i.dataobj#,
         i.pctfree$, NULL, i.initrans, i.maxtrans,
         cast( multiset(select * from ku$_constraint1_view con
                        where con.obj_num = t.obj#
                       ) as ku$_constraint1_list_t
             ),!';
-- storage related for partition promotion export for table import (sharding)
p2t_stor := q'!
         bitand(t.property, ((power(2, 32)-1)-32)),
         -- property2 is bits 32-63
         -- Note: property bit 0x20 (32) must be cleared -
         --   metadata is generated as for a non-partitioned table
         bitand(trunc(t.property / power(2, 32)),
                ((power(2, 32)-1)-4))+trunc(bitand(tp.flags,65536)/(65536/4)),
         trunc(t.property / power(2, 64)),
         tp.storage,
         tp.deferred_stg,
         tp.ts_name,
         tp.blocksize,
         tp.dataobj_num,
         tp.pct_free, tp.pct_used, tp.initrans, tp.maxtrans,
         cast( multiset(select * from ku$_p2t_constraint1_view con
                        where con.obj_num = t.obj#
                              and (con.ind IS NULL or
                                   con.ind.ind_part.part_num=tp.phypart_num)
                       ) as ku$_constraint1_list_t
             ),!';
-- storage related for subpartition promotion export for table import (sharding)
sp2t_stor := q'!
         bitand(t.property, ((power(2, 32)-1)-32)),
         -- property2 is bits 32-63
         -- Note: property bit 0x20 (32) must be cleared -
         --   metadata is generated as for a non-partitioned table
         bitand(trunc(t.property / power(2, 32)),
                ((power(2, 32)-1)-4))+trunc(bitand(tp.flags,65536)/(65536/4)),
         trunc(t.property / power(2, 64)),
         tp.storage,
         tp.deferred_stg,
         tp.ts_name,
         tp.blocksize,
         tp.dataobj_num,
         tp.pct_free, tp.pct_used, tp.initrans, tp.maxtrans,
         cast( multiset(select * 
           from ku$_sp2t_constraint1_view con
           where con.obj_num = t.obj# AND
                 (con.ind IS NULL or
                  tp.obj_num = con.ind.tabpart_obj_num)
              ) as ku$_constraint1_list_t
             ),!';

/* col_list primitive, full, full-partitioned,  */
prim_col_list := '
         cast( multiset(select * from ku$_prim_column_view c
                        where c.obj_num = t.obj#
                        order by c.col_num, c.intcol_num
                        ) as ku$_tab_column_list_t
              ),
';
col_list := '
         cast( multiset(select * from ku$_column_view c
                        where c.obj_num = t.obj#
                        order by c.col_num, c.intcol_num
                        ) as ku$_tab_column_list_t
              ),';
col_list_10_2 := '
         cast( multiset(select * from ku$_column_view c
                        where c.obj_num = t.obj# and
                        dbms_metadata.is_attr_valid_on_10(t.obj#,c.intcol_num)=1
                        order by c.col_num, c.intcol_num
                        ) as ku$_tab_column_list_t
              ),';

pcol_list := '
         cast( multiset(select * from ku$_pcolumn_view c
                        where c.obj_num = t.obj#
                        order by c.col_num, c.intcol_num
                        ) as ku$_tab_column_list_t
              ),';
p2tcol_list := '
         cast( multiset(select * from ku$_p2tcolumn_view c
                        where c.obj_num = t.obj# and
                          ( c.lobmd is null or
                            c.lobmd.part_num = tp.part_num )
                        order by c.col_num, c.intcol_num
                        ) as ku$_tab_column_list_t
              ),';
sp2tcol_list := '
         cast( multiset(select * from ku$_sp2tcolumn_view c
                        where c.obj_num = t.obj# and
                          ( c.lobmd is null or
                            c.lobmd.part_obj_num = tp.obj_num )
                        order by c.col_num, c.intcol_num
                        ) as ku$_tab_column_list_t
              ),';

/* NT, ref constraints, xmltype metadata - all only in "full" */
full_list := q'!         (select value(nt) from ku$_nt_parent_view nt
          where nt.obj_num = t.obj#),
         cast( multiset(select * from ku$_pkref_constraint_view con
                        where con.obj_num = t.obj#
                       ) as ku$_pkref_constraint_list_t
             ),
        /* xmltype metadata - only with non-primitive columns */
         decode((select 1 from dual where
                 (exists (select q.obj# from sys.opqtype$ q
                          where q.obj#=t.obj#
                          and q.type=1                        /* xmltype col */
                          and bitand(q.flags,2+64)!=0))),       /* CSX or SB */
                1,'Y','N'),
         case when (exists (select q.obj# from sys.opqtype$ q
                          where q.obj#=t.obj#
                          and q.type=1))                      /* xmltype col */
              then dbms_metadata_util.get_xmlcolset(o.obj_num)
              else NULL end,
         case when (exists (select q.obj# from sys.opqtype$ q
                          where q.obj#=t.obj#
                          and q.type=1))                      /* xmltype col */
              then dbms_metadata_util.get_xmlhierarchy(o.owner_name,o.name)
              else NULL end,!';
prim_list := q'!NULL,NULL,'N',NULL,NULL,!';

/* refpar : parent, refpar_level - acp view only */
ref_par := q'!
         (select value(po) from ku$_schemaobj_view po
           where
            po.obj_num=sys.dbms_metadata_util.ref_par_parent(t.obj#)),
         sys.dbms_metadata_util.ref_par_level(t.obj#),!';
noref_par := 'null,0,';

/* objgrant_list - grants required for parent access */
objgrant := q'! 
         cast(multiset(select value(og) from  ku$_objgrant_view og, ku$_schemaobj_view po
                 where og.base_obj.obj_num = sys.dbms_metadata_util.ref_par_parent(t.obj#) and
                       po.obj_num = og.base_obj.obj_num and
                       og.privname = 'REFERENCES' and
                       og.base_obj.name = po.name
                 order by og.wgo desc)
                 as ku$_objgrant_list_t),!';
noobjgrant := 'null, ';
/* IOT common: thresh, keycol, inclcol, iov, maptab */
iot_comm := q'!
         mod(i.pctthres$,256), i.spare2,
         (select c.name from col$ c
                 where c.obj# = t.obj#
                 and   c.col# = i.trunccnt and i.trunccnt != 0
                 and   bitand(c.property,1)=0
                 and   bitand(c.property,256)=0),
         (select value(ov) from ku$_ov_table_view ov
          where ov.bobj_num = t.obj#
          and bitand(t.property, 128) = 128),  -- IOT has overflow
         (select value(mp) from ku$_map_table_view mp
          where mp.bobj_num = t.obj#),!';
noiot_comm := q'!null,null,null,null,null,!';

/* partition metadata - differs for heap vs index organization */
hpart := q'!
         (select value(po) from ku$_tab_partobj_view po
          where t.obj# = po.obj_num)!'; 
iopart := q'!
         (select value (po) from ku$_iot_partobj_view po
          where t.obj# = po.obj_num)!'; 
nopart := q'!null!'; 
p2t_part  := ' value(tp), NULL';
sp2t_part  := ' NULL, value(tp)';

htail := q'!
  from  ku$_schemaobj_view o, tab$ t, ts$ ts
  where t.obj# = o.obj_num
        AND bitand(t.property,1607917567)     -- mask off bits 0x20292000
                in (0,1024,8192)              -- can be clustered table (1024)
                                              -- or nested table (8192)
        AND t.ts# = ts.ts#
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY'))) !';

phtail := q'!
  from  ku$_schemaobj_view o, tab$ t, ts$ ts
  where t.obj# = o.obj_num
        AND bitand(t.property,1607917567)     -- mask off bits 0x20292000
                in (32,32+8192)         /* simple, partitioned tables */
                                        /* no CLOBs, UDTs, nested cols*/
                                        /* (but can be nested table) */
        AND not exists( select * from partobj$ po
                        where po.obj# = t.obj# and po.parttype = 5)
        AND t.ts# = ts.ts#
        AND     (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY'))) !';

fhtail := q'!
  from ku$_schemaobj_view o, tab$ t, ts$ ts
  where t.obj# = o.obj_num
        AND t.ts# = ts.ts#
        AND bitand(t.property, 32+64+128+256+512) = 0
                                                /* not IOT, partitioned   */
        AND bitand(t.property,1607917567)     -- mask off bits 0x20292000
                NOT in (0,1024,8192) -- don`t include those in ku$_htable_view
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY'))) !';

pfhtail := q'!
  from ku$_schemaobj_view o, tab$ t, ts$ ts
  where t.obj# = o.obj_num
        AND t.ts# = ts.ts#
        AND bitand(t.property, 32+64+128+256+512) = 32
                                                /* partitioned (32)       */
                                                /* but not IOT            */
        AND bitand(t.property,1607917567)     -- mask off bits 0x20292000
             not in (32,32+8192)  /* Mutually exclusive of ku$_phtable_view */
        AND not exists( select * from partobj$ po
                        where po.obj# = t.obj# and po.parttype = 5)
        AND     (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY'))) !';

iotail := q'!
  from ku$_schemaobj_view o, tab$ t, ind$ i, ts$ ts
  where t.obj# = o.obj_num
        and t.pctused$ = i.obj#          -- For IOTs, pctused has index obj#
        and bitand(t.property, 32+64+512) = 64  -- IOT but not overflow
                                                -- or partitioned (32)
        and  i.ts# = ts.ts#
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY'))) !';

piotail := q'!
  from ku$_schemaobj_view o, tab$ t, ind$ i, ts$ ts
  where t.obj# = o.obj_num
        and t.pctused$ = i.obj#          -- For IOTs, pctused has index obj#
        and bitand(t.property, 32+64+512)  = 32+64  -- PIOT but not overflow
        AND i.ts# = ts.ts#
        AND     (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY'))) !';

acptail := q'! 
  from ku$_schemaobj_view o, tab$ t, ts$ ts
  where t.obj# = o.obj_num
        AND t.ts# = ts.ts#
        AND bitand(t.property, 32+64+128+256+512) = 32
                                                /* partitioned (32)       */
                                                /* but not IOT            */
        /* mutually exclusive with ku$_phtable and ku$_pfhtable */
        AND exists( select * from partobj$ po
                    where po.obj# = t.obj# and po.parttype = 5)
        AND     (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY'))) !';
p2ttail := q'! 
 from ku$_schemaobj_view o, tab$ t, ts$ ts, ku$_tab_part_view tp
  where t.obj# = o.obj_num 
        AND tp.base_obj_num = t.obj#
        AND tp.ts_name = ts.name
        AND bitand(t.property, 32) != 0         -- only partitioned
        AND bitand(t.property, 64+128+256+512) = 0  -- not any kind of IOT
        AND bitand(t.property,1607917567)     -- mask off bits 0x20292000
                NOT in (0,1024,8192) -- do not include clustered, nested
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY'))) !';
sp2ttail := q'! 
 from ku$_schemaobj_view o, tab$ t, ts$ ts, ku$_tab_subpart_view tp
  where t.obj# = o.obj_num 
        AND (select tpt.bo# from tabcompart$ tpt where tp.pobj_num = tpt.obj#) = t.obj#
        AND tp.ts_name = ts.name
        AND bitand(t.property, 32) != 0         -- only partitioned
        AND bitand(t.property, 64+128+256+512) = 0  -- not any kind of IOT
        AND bitand(t.property,1607917567)     -- mask off bits 0x20292000
                NOT in (0,1024,8192) -- do not include clustered, nested
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY'))) !';

  cre_view('ku$_htable_view','table_t',       tabcom||tab_stor  ||prim_col_list||
           prim_list||noref_par||noobjgrant||noiot_comm||nopart  ||htail);

  cre_view('ku$_phtable_view','table_t',      tabcom||tab_stor  ||prim_col_list||
           prim_list||noref_par||noobjgrant||noiot_comm||hpart   ||phtail);

  cre_view('ku$_fhtable_view','table_t',      tabcom||tab_stor  ||col_list||
           full_list||noref_par||noobjgrant||noiot_comm||nopart  ||fhtail);

  cre_view('ku$_10_2_fhtable_view','table_t', tabcom||tab_stor  ||col_list_10_2||
           full_list||noref_par||noobjgrant||noiot_comm||nopart  ||fhtail);

  cre_view('ku$_pfhtable_view','table_t',     tabcom||tab_stor  ||pcol_list||
           full_list||noref_par||noobjgrant||noiot_comm||hpart   ||pfhtail);

  cre_view('ku$_acptable_view','table_t',     tabcom||tab_stor  ||pcol_list||
           full_list||ref_par  ||  objgrant||noiot_comm||hpart   ||acptail);

  cre_view('ku$_partition_view','partition_t',p2t_tabcom||p2t_stor  ||p2tcol_list||
           full_list||ref_par  ||  objgrant||noiot_comm||p2t_part||p2ttail);

  cre_view('ku$_subpartition_view','partition_t',tabcom||sp2t_stor  ||sp2tcol_list||
           full_list||ref_par  ||  objgrant||noiot_comm||sp2t_part||sp2ttail);

  cre_view('ku$_iotable_view','io_table_t',   tabcom||iotab_stor||col_list||
           full_list||noref_par||noobjgrant||  iot_comm||nopart  ||iotail);

  cre_view('ku$_piotable_view','io_table_t',  tabcom||iotab_stor||pcol_list||
           full_list||noref_par||noobjgrant||  iot_comm||iopart  ||piotail);

end;
/
--spool off
-------------------------------------------------------------------------------
--                           Materialized View
-------------------------------------------------------------------------------

declare
  use_new_cols boolean;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  use_new_cols := ku$$column_exists('OBJ$','DFLCOLLID') or ku$$mig_final;
  execute immediate q'!
create or replace force view ku$_m_view_view_base of ku$_m_view_t
  with object identifier (oidval) as
  select '2',
         case when dbms_metadata.get_version >= '12.00.00.00.00' then '4'
              when dbms_metadata.get_version >= '11.02.00.00.00' then '3'
              when dbms_metadata.get_version >= '11.00.00.00.00' then '2'
              when dbms_metadata.get_version >= '10.00.00.00.00' then '1'
              else '0'
         end,
         sys_guid(),
         s.sowner,
         s.vname,
         s.tname,
         s.mowner,
         s.master,
         s.mlink,
         !' ||
         case when use_new_cols then
                   '(select nls_collation_name(nvl(o.dflcollid, 16382)) 
                           from sys.obj$ o, sys.user$ u, sum$ sm
                           where u.user# = o.owner#
                                 and u.name  = s.sowner
                                 and o.name  = s.vname
                                 and o.obj#  = sm.obj#
                                 and o.type# = 42)'
              else 'null' end || q'!,
         (select o.obj# from sys.obj$ o, user$ u
          where  dbms_metadata.get_version >= '12.00.00.00.00'
            and s.mlink is null
            and o.owner# = u.user#
            and s.mowner = u.name
            and s.master = o.name
            and o.type#  = 2
            and o.linkname is null), /* interested in local objects only
                                        (see  s.mlink is null ) */
         TO_CHAR(s.snapshot,'YYYY-MM-DD HH24:MI:SS'),
         s.snapid,
         DECODE(s.auto_fast, 'C', 'COMPLETE', 'F', 'FAST', '?', 'FORCE',
                NULL, 'FORCE', 'N', 'NEVER', 'ERROR'),
         s.auto_fun,
         to_char(s.auto_date,'YYYY/MM/DD HH24:MI:SS'),
         s.uslog,
         s.status,
         s.master_version,
         s.tables,
         s.flag,
         s.flag2,
         case when dbms_metadata.get_version >= '11.02.00.00.00'
           then NVL(s.flag3, 0)
           else 0
         end,
         s.lobmaskvec,
         s.mas_roll_seg,
         s.rscn,
         s.instsite,
         NVL(s.flavor_id, 0),
         s.objflag,
         s.sna_type_owner,
         s.sna_type_name,
         s.mas_type_owner,
         s.mas_type_name,
         s.parent_sowner,
         s.parent_vname,
         s.query_len,
         sys.dbms_metadata_util.long2clob(s.query_len, 'sys.snap$',
                                            'query_txt', s.rowid),
         sys.dbms_metadata.parse_query(SYS_CONTEXT('USERENV','CURRENT_USERID'),
                                       s.sowner, s.query_len, 'sys.snap$',
                                       'query_txt', s.rowid),
--         sys.dbms_metadata_util.long2vcnt(s.query_len, 'sys.snap$',
--                                            'query_txt', s.rowid),
         NULL,
         s.rel_query,
         (select rg.rollback_seg
          from   sys.rgroup$ rg
          where  rg.owner = s.sowner
             and rg.name = s.vname),
         p.value$,
         s.syn_count,
         cast(multiset(select srt.tablenum,
                              TO_CHAR(srt.snaptime,'YYYY-MM-DD HH24:MI:SS'),
                              srt.mowner,
                              srt.master,
                              case when dbms_metadata.get_version >= '11.02.00.00.00'
                                then srt.masflag
                                else bitand(srt.masflag, 65535)
                              end,
                              srt.masobj#,
                              TO_CHAR(srt.loadertime,'YYYY-MM-DD HH24:MI:SS'),
                              srt.refscn,
                              TO_CHAR(srt.lastsuccess,'YYYY-MM-DD HH24:MI:SS'),
                              srt.fcmaskvec,
                              srt.ejmaskvec,
                              srt.sub_handle,
                              srt.change_view,
                              (select count(*)
                               from   sys.snap_colmap$ scm
                               where  srt.vname = scm.vname
                               and    srt.sowner = scm.sowner
                               and    srt.instsite = scm.instsite
                               and    srt.tablenum = scm.tabnum),
                              cast(multiset(select scm.snacol,
                                                   scm.mascol,
                                                   scm.maspos,
                                                   scm.colrole,
                                                   scm.snapos
                                            from   sys.snap_colmap$ scm
                                            where  srt.vname = scm.vname
                                            and    srt.sowner = scm.sowner
                                            and    srt.instsite = scm.instsite
                                            and    srt.tablenum = scm.tabnum
                                            order by scm.maspos)
                                            as ku$_m_view_scm_list_t)
                       from   sys.snap_reftime$ srt
                       where  s.vname    = srt.vname
                          and s.sowner   = srt.sowner
                          and s.instsite = srt.instsite
                       order by srt.tablenum, srt.mowner, srt.master)
                       as ku$_m_view_srt_list_t),
         nvl((select sm.mflags
              from   sys.obj$ o, sys.user$ u, sum$ sm
              where  u.user# = o.owner#
              and    u.name = s.sowner
              and    o.name = s.vname
              and    o.obj# = sm.obj#), 0),
         nvl((select sm.xpflags
              from   sys.obj$ o, sys.user$ u, sum$ sm
              where  u.user# = o.owner#
              and    u.name = s.sowner
              and    o.name = s.vname
              and    o.obj# = sm.obj#), 0),
         nvl((select sm.zmapscale
              from   sys.obj$ o, sys.user$ u, sum$ sm
              where  u.user# = o.owner#
              and    u.name = s.sowner
              and    o.name = s.vname
              and    o.obj# = sm.obj#), 0),
         nvl((select sm.evaledition#
              from   sys.obj$ o, sys.user$ u, sum$ sm
              where  u.user# = o.owner#
              and    u.name = s.sowner
              and    o.name = s.vname
              and    o.obj# = sm.obj#), 0),
         nvl((select sm.unusablebefore#
              from   sys.obj$ o, sys.user$ u, sum$ sm
              where  u.user# = o.owner#
              and    u.name = s.sowner
              and    o.name = s.vname
              and    o.obj# = sm.obj#), 0),
         nvl((select sm.unusablebeginning#
              from   sys.obj$ o, sys.user$ u, sum$ sm
              where  u.user# = o.owner#
              and    u.name = s.sowner
              and    o.name = s.vname
              and    o.obj# = sm.obj#), 0)
  from   snap$ s, sys.props$ p
  where  p.name  = 'GLOBAL_DB_NAME'
  /* for < 11.2, exclude MVs using scn-based refresh */
  and (dbms_metadata.get_version >= '11.02.00.00.00'
       or
       (dbms_metadata.get_version < '11.02.00.00.00' and bitand(s.flag3, 1)=0))
 !';
exception
  when success_with_error then
  if use_new_cols then
    null;
  else
    raise;
  end if;
end;
/

show errors

--
-- This view is queried by prvtmeta.sql as part of views-as-tables validation
--

declare
  use_new_cols boolean;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  use_new_cols := ku$$column_exists('OBJ$','DFLCOLLID') or ku$$mig_final;
  execute immediate q'!
create or replace force view ku$_viewprop_view
 (obj_num,name,schema,property,dflcollname)
 as
 select o.obj#, o.name, u.name, v.property,
        !' ||
          case when use_new_cols then
               'nls_collation_name(nvl(o.dflcollid, 16382))'
          else 'null' end || q'!
 from obj$ o, user$ u, view$ v
 where o.owner# = u.user#
 and   o.obj#   = v.obj#
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
 !';
exception
  when success_with_error then
  if use_new_cols then
    null;
  else
    raise;
  end if;
end;
/
-------------------------------------------------------------------------------
--                              INDEX COLUMNS
-------------------------------------------------------------------------------

-- view for index columns

declare
  use_new_cols boolean;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  use_new_cols := ku$$column_exists('COL$','COLLINTCOL#') or ku$$mig_final;
  execute immediate q'!
create or replace force view ku$_index_col_view of ku$_index_col_t
  with object identifier(obj_num, intcol_num) as
  select ic.obj#, ic.bo#, ic.intcol#,
          value(c), ic.pos#,
          ic.segcol#, ic.segcollength, ic.offset, ic.spare1,
          ic.spare2, ic.spare3, ic.spare4, ic.spare5, to_char(ic.spare6,'YYYY/MM/DD HH24:MI:SS'),
          decode(bitand(c.property,1024+2),0,0,2,1,1024,2,0),
          case when bitand(i.property, 16) = 16 then
            !' || 
            case when use_new_cols then
                   '(select c1.name from col$ c1 
                           /* Get collation intcol# if the column is 
                              (virtual + system generated + hidden) and
                              has collation column expression */
                           where c1.intcol# = (select c2.collintcol# from col$ c2 
                                                      where c2.obj#=ic.bo# and c2.intcol#=ic.intcol# and
                                                            bitand(c2.property,65536+256+32) = (65536+256+32) and
                                                            bitand(trunc(c2.property / power(2,32)),16384) = 16384)
                                 and c1.obj#=ic.bo#)'
                 else
                   'null'
                 end || q'!
          else
            null
          end
  from ku$_simple_col_view c, ind$ i, icol$ ic
  where ic.bo#     = c.obj_num
  and   i.obj# = ic.obj#
  and c.intcol_num =
   case
      /* join index : 0x0400 */
    when (bitand(i.property, 1024) = 1024) then ic.spare2
     /* not a join index */
     /* Is this a functional index ? */
    when bitand(i.property, 16) = 16 then
      dbms_metadata.get_index_intcol(ic.bo#, ic.intcol#)
    else
      ic.intcol#
   end
!';
exception
  when success_with_error then
    null;
end;
/

-------------------------------------------------------------------------------
--                              USER
-------------------------------------------------------------------------------
declare
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
  use_new_cols boolean;
begin
 use_new_cols := ku$$column_exists('USER$','SPARE9') or ku$$mig_final;

 execute immediate q'!
create or replace force view ku$_user_base_view 
    (vers_major, vers_minor, user_id, name, type_num, password, datats, tempts, ltempts,
     ctime, ptime, exptime, ltime, profnum, profname, user_audit, defrole,
     defgrp_num, defgrp_seq_num, astatus, astatus_12, lcount, defschclass,
     ext_username, spare1, spare2, spare3, spare4, spare4_12, spare5, spare6)
  as
  select '2','0',
          u.user#,
          u.name,
          u.type#,
          case 
            when dbms_metadata.get_version < '12.02.00.00.00' and
                    bitand(u.spare1, 65536) = 65536 then
              'S:000000000000000000000000000000000000000000000000000000000000'
            else
              u.password
          end,
          ts1.name,
          ts2.name, 
          !' ||
          case when use_new_cols then
           ' (select ts3.name from ts$ ts3 where u.spare9 = ts3.ts#), '
          else
           ' NULL, '
          end || q'!
          to_char(u.ctime,'YYYY/MM/DD HH24:MI:SS'),
          to_char(u.ptime,'YYYY/MM/DD HH24:MI:SS'),
          to_char(u.exptime,'YYYY/MM/DD HH24:MI:SS'),
          to_char(u.ltime,'YYYY/MM/DD HH24:MI:SS'),
          u.resource$,
          p.name,
          replace(u.audit$,chr(0),'-'),
          u.defrole,
          u.defgrp#,
          u.defgrp_seq#,
          DECODE(NVL(instr(u.spare4, ';H:'),0), 0, u.astatus, 
                 u.astatus - BITAND(u.astatus, 9) + 9),
          u.astatus,
          u.lcount,
          NVL((select cgm.consumer_group
                        from sys.resource_group_mapping$ cgm
                        where cgm.attribute = 'ORACLE_USER'
                        and cgm.status = 'ACTIVE'
                        and cgm.value = u.name), u.defschclass),
          u.ext_username,
          u.spare1,
          u.spare2,
          nls_collation_name(nvl(u.spare3, 16382)),
          NVL(NVL(SUBSTR(u.spare4, 1, instr(u.spare4, ';H:') - 1),
             SUBSTR(u.spare4, 1, instr(u.spare4, ';T:') - 1)),
             u.spare4),
          u.spare4,
          u.spare5,
          to_char(u.spare6,'YYYY/MM/DD HH24:MI:SS')
  from sys.user$ u,
       sys.ts$ ts1, sys.ts$ ts2, sys.profname$ p
  where   u.datats# = ts1.ts# AND
          u.tempts# = ts2.ts# AND
          u.type# = 1 AND
          u.resource$ = p.profile#
          AND (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
                OR EXISTS ( SELECT * FROM sys.session_roles
                   WHERE role='EXP_FULL_DATABASE' OR
                         role='DATAPUMP_CLOUD_EXP' ))
UNION
  select '2','0',
          u.user#,
          u.name,
          u.type#,
          NULL,
          ts1.name,
          ts2.name,
          !' ||
          case when use_new_cols then
           ' (select ts3.name from ts$ ts3 where u.spare9 = ts3.ts#), '
          else
           ' NULL, '
          end || q'!
          to_char(u.ctime,'YYYY/MM/DD HH24:MI:SS'),
          to_char(u.ptime,'YYYY/MM/DD HH24:MI:SS'),
          to_char(u.exptime,'YYYY/MM/DD HH24:MI:SS'),
          to_char(u.ltime,'YYYY/MM/DD HH24:MI:SS'),
          u.resource$,
          p.name,
          replace(u.audit$,chr(0),'-'),
          u.defrole,
          u.defgrp#,
          u.defgrp_seq#,
          u.astatus,
          u.astatus,
          u.lcount,
          NVL((select cgm.consumer_group
               from sys.resource_group_mapping$ cgm
               where cgm.attribute = 'ORACLE_USER'
                 and cgm.status = 'ACTIVE'
                 and cgm.value = u.name), u.defschclass),
          u.ext_username,
          u.spare1,
          u.spare2,
          nls_collation_name(nvl(u.spare3, 16382)),
          NULL, NULL,
          u.spare5,
          to_char(u.spare6,'YYYY/MM/DD HH24:MI:SS')
  from sys.user$ u,
       sys.ts$ ts1, sys.ts$ ts2, sys.profname$ p
  where   u.datats# = ts1.ts# AND
          u.tempts# = ts2.ts# AND 
          u.type# = 1 AND
          u.resource$ = p.profile#
     AND (SYS_CONTEXT('USERENV','CURRENT_USERID') != 0 )
     AND NOT (EXISTS ( SELECT * FROM sys.session_roles
                   WHERE role='EXP_FULL_DATABASE' OR
                         role='DATAPUMP_CLOUD_EXP' ))
     AND (EXISTS ( SELECT * FROM sys.session_roles
                   WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
!';
exception
  when success_with_error then
    null;
end;
/

declare
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
execute immediate q'!
create or replace force view ku$_user_view of ku$_user_t
  with object identifier(user_id) as
  select ubv.*,
        cast(multiset(select * from ku$_user_editioning_view uev
                      where uev.user_id = ubv.user_id)
                      as ku$_user_editioning_list_t)
  from sys.ku$_user_base_view ubv
!';
exception
  when success_with_error then
    null;
end;
/

DROP FUNCTION ku$$column_exists;
DROP FUNCTION ku$$mig_final;

@?/rdbms/admin/sqlsessend.sql
