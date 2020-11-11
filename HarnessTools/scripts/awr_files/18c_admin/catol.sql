Rem
Rem $Header: rdbms/admin/catol.sql /main/15 2014/12/11 22:46:34 skayoor Exp $
Rem
Rem catol.sql
Rem
Rem Copyright (c) 1998, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catol.sql - outline views and synonyms
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catol.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catol.sql
Rem SQL_PHASE: CATOL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    traney      03/30/11 - 35209: long identifiers dictionary upgrade
Rem    yzhu        02/04/08 - add MIGRATED column in *_outlines views
Rem    rburns      08/11/06 - add grants
Rem    ddas        01/07/05 - #(4052436) modify *_OUTLINE_HINTS views 
Rem    svivian     06/13/03 - add node_name to ol$nodes
Rem    svivian     06/10/03 - handle local hint format
Rem    svivian     08/20/02 - remove symbolics that don't work
Rem    svivian     08/19/02 - add private outline tables to system
Rem    desinha     04/29/02 - #2303866: change user => userenv('SCHEMAID')
Rem    gviswana    05/24/01 - CREATE AND REPLACE SYNONYM
Rem    svivian     08/22/00 - add signature to views
Rem    pejustus    06/22/98 - add phase column to hint views
Rem    svivian     04/16/98 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

--
-- NAME: ora$grant_sys_select
--
-- DESCRIPTION:
--      System only procedure that grants select on outln tables
--      to select_catalog_role without requiring a connect to
--      the OUTLN schema.
--
-- PARAMETERS
--
-- USAGE NOTES:
--      To be used during database startup only
--
create or replace procedure outln.ora$grant_sys_select as
begin
  EXECUTE IMMEDIATE 'GRANT SELECT ON OUTLN.OL$ TO SELECT_CATALOG_ROLE';
  EXECUTE IMMEDIATE 'GRANT SELECT ON OUTLN.OL$HINTS TO SELECT_CATALOG_ROLE';
  EXECUTE IMMEDIATE 'GRANT SELECT ON OUTLN.OL$NODES TO SELECT_CATALOG_ROLE';
  EXECUTE IMMEDIATE 'GRANT SELECT ON OUTLN.OL$ TO SYS WITH GRANT OPTION';
  EXECUTE IMMEDIATE 'GRANT SELECT ON OUTLN.OL$HINTS TO SYS WITH GRANT OPTION';
  EXECUTE IMMEDIATE 'GRANT SELECT ON OUTLN.OL$NODES TO SYS WITH GRANT OPTION';
end;
/

begin
 outln.ora$grant_sys_select;
end;  
/

create or replace view USER_OUTLINES
  (NAME, CATEGORY, USED, TIMESTAMP, VERSION, SQL_TEXT, SIGNATURE,
   COMPATIBLE, ENABLED, FORMAT, MIGRATED)
as
select ol_name, category, 
  decode(bitand(flags, 1), 0, 'UNUSED', 1, 'USED'),
  timestamp, version, sql_text, signature,
  decode(bitand(flags, 2), 0, 'COMPATIBLE', 2, 'INCOMPATIBLE'),
  decode(bitand(flags, 4), 0, 'ENABLED', 4, 'DISABLED'),
  decode(bitand(flags, 8), 0, 'NORMAL', 8, 'LOCAL'),
  decode(bitand(flags, 16), 0, 'NOT-MIGRATED', 16, 'MIGRATED') 
from outln.ol$, sys.user$ u
where creator = u.name
and u.user# = USERENV('SCHEMAID')
/
comment on table USER_OUTLINES is
'Stored outlines owned by the user'
/
comment on column USER_OUTLINES.NAME is
'Name of the outline'
/
comment on column USER_OUTLINES.CATEGORY is
'Category to which the outline belongs'
/
comment on column USER_OUTLINES.USED is
'Flag indicating whether the outline has ever been used'
/
comment on column USER_OUTLINES.TIMESTAMP is
'Timestamp at which the outline was created'
/
comment on column USER_OUTLINES.VERSION is
'Oracle Version that created the outline'
/
comment on column USER_OUTLINES.SQL_TEXT is
'SQL text of the query'
/
comment on column USER_OUTLINES.SIGNATURE is
'Signature uniquely identifying the outline SQL text'
/
comment on column USER_OUTLINES.COMPATIBLE is
'Flag indicating whether the outline hints were compatible across migration'
/
comment on column USER_OUTLINES.ENABLED is
'Flag indicating whether the outline is enabled'
/
comment on column USER_OUTLINES.FORMAT is
'Flag indicating what hint format is used'
/
comment on column USER_OUTLINES.MIGRATED is
'Flag indicating whether the outline has been migrated to SQL plan baseline'
/
create or replace public synonym USER_OUTLINES for USER_OUTLINES
/
grant read on USER_OUTLINES to PUBLIC with grant option
/
create or replace public synonym ALL_OUTLINES for USER_OUTLINES
/
grant read on ALL_OUTLINES to PUBLIC with grant option
/
create or replace view DBA_OUTLINES
  (NAME, OWNER, CATEGORY, USED, TIMESTAMP, VERSION, SQL_TEXT, SIGNATURE,
   COMPATIBLE, ENABLED, FORMAT, MIGRATED)
as
select ol_name, creator, category, 
  decode(bitand(flags, 1), 0, 'UNUSED', 1, 'USED'),
  timestamp, version, sql_text, signature,
  decode(bitand(flags, 2), 0, 'COMPATIBLE', 2, 'INCOMPATIBLE'),
  decode(bitand(flags, 4), 0, 'ENABLED', 4, 'DISABLED'),
  decode(bitand(flags, 8), 0, 'NORMAL', 8, 'LOCAL'),
  decode(bitand(flags, 16), 0, 'NOT-MIGRATED', 16, 'MIGRATED')
from outln.ol$
/
comment on table DBA_OUTLINES is
'Stored outlines'
/
comment on column DBA_OUTLINES.NAME is
'Name of the outline'
/
comment on column DBA_OUTLINES.OWNER is
'User who created the outline'
/
comment on column DBA_OUTLINES.CATEGORY is
'Category to which the outline belongs'
/
comment on column DBA_OUTLINES.USED is
'Flag indicating whether the outline has ever been used'
/
comment on column DBA_OUTLINES.TIMESTAMP is
'Timestamp at which the outline was created'
/
comment on column DBA_OUTLINES.VERSION is
'Oracle Version that created the outline'
/
comment on column DBA_OUTLINES.SQL_TEXT is
'SQL text of the query'
/
comment on column DBA_OUTLINES.SIGNATURE is
'Signature uniquely identifying the outline SQL text'
/
comment on column DBA_OUTLINES.COMPATIBLE is
'Flag indicating whether the outline hints were compatible across migration'
/
comment on column DBA_OUTLINES.ENABLED is
'Flag indicating whether the outline is enabled'
/
comment on column DBA_OUTLINES.FORMAT is
'Flag indicating what hint format is used'
/
comment on column DBA_OUTLINES.MIGRATED is
'Flag indicating whether the outline has been migrated to SQL plan baseline'
/
create or replace public synonym DBA_OUTLINES for DBA_OUTLINES
/
grant select on DBA_OUTLINES to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_OUTLINES','CDB_OUTLINES');
grant select on SYS.CDB_OUTLINES to select_catalog_role
/
create or replace public synonym CDB_OUTLINES for SYS.CDB_OUTLINES
/

create or replace view USER_OUTLINE_HINTS
  (NAME, NODE, STAGE, JOIN_POS, HINT)
as
select o.ol_name, h.node#, h.stage#, table_pos,
       NVL(h.hint_string, h.hint_text)
from outln.ol$ o, outln.ol$hints h, sys.user$ u
where o.ol_name = h.ol_name
  and o.creator = u.name
  and u.user#   = USERENV('SCHEMAID')
/
comment on table USER_OUTLINE_HINTS is
'Hints stored in outlines owned by the user'
/
comment on column USER_OUTLINE_HINTS.NAME is
'Stage at which the outline is processed'
/
comment on column USER_OUTLINE_HINTS.NODE is
'I.D. of the query or subquery to which the hint applies'
/
comment on column USER_OUTLINE_HINTS.STAGE is
'Stage at which outline is processed'
/
comment on column USER_OUTLINE_HINTS.JOIN_POS is
'Position of the table in the join order'
/
comment on column USER_OUTLINE_HINTS.HINT is
'Text of the hint'
/
create or replace public synonym USER_OUTLINE_HINTS for USER_OUTLINE_HINTS
/
grant read on USER_OUTLINE_HINTS to PUBLIC with grant option
/
create or replace public synonym ALL_OUTLINE_HINTS for USER_OUTLINE_HINTS
/
grant read on ALL_OUTLINE_HINTS to PUBLIC with grant option
/
create or replace view DBA_OUTLINE_HINTS
  (NAME, OWNER, NODE, STAGE, JOIN_POS, HINT)
as
select o.ol_name, o.creator, h.node#, h.stage#, h.table_pos,
       NVL(h.hint_string, h.hint_text)
from outln.ol$ o, outln.ol$hints h
where o.ol_name = h.ol_name
/
comment on table DBA_OUTLINE_HINTS is
'Hints stored in outlines'
/
comment on column DBA_OUTLINE_HINTS.NAME is
'Name of the outline'
/
comment on column DBA_OUTLINE_HINTS.OWNER is
'User who created the outline'
/
comment on column DBA_OUTLINE_HINTS.NODE is
'I.D. of the query or subquery to which the hint applies'
/
comment on column DBA_OUTLINE_HINTS.STAGE is
'Stage at which the outline is processed'
/
comment on column DBA_OUTLINE_HINTS.JOIN_POS is
'Position of the table in the join order'
/
comment on column DBA_OUTLINE_HINTS.HINT is
'Text of the hint'
/
create or replace public synonym DBA_OUTLINE_HINTS for DBA_OUTLINE_HINTS
/
grant select on DBA_OUTLINE_HINTS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_OUTLINE_HINTS','CDB_OUTLINE_HINTS');
grant select on SYS.CDB_OUTLINE_HINTS to select_catalog_role
/
create or replace public synonym CDB_OUTLINE_HINTS for SYS.CDB_OUTLINE_HINTS
/

create global temporary table system.ol$
(
  ol_name           varchar2(128),                          /* outline name */
  sql_text          long,                    /* the SQL stmt being outlined */
  textlen           number,                           /* length of SQL stmt */
  signature         raw(16),                       /* signature of sql_text */
  hash_value        number,                  /* KGL's calculated hash value */
  hash_value2       number,/* hash value on sql_text stripped of whitespace */
  category          varchar2(128),                         /* category name */
  version           varchar2(64),          /* db version @ outline creation */
  creator           varchar2(128),        /* user from whom outline created */
  timestamp         date,                               /* time of creation */
  flags             number,              /* e.g. everUsed, bindVars, dynSql */
  hintcount         number,               /* number of hints on the outline */
  spare1            number,                                 /* spare column */
  spare2            varchar2(1000)                          /* spare column */
) on commit preserve rows
/
create global temporary table system.ol$hints
(
  ol_name           varchar2(128),                          /* outline name */
  hint#             number,               /* which hint for a given outline */
  category          varchar2(128),              /* collection/grouping name */
  hint_type         number,                                 /* type of hint */
  hint_text         varchar2(512),             /* hint specific information */
  stage#            number,            /* stage of hint generation/applic'n */
  node#             number,                                  /* QBC node id */
  table_name        varchar2(128),                      /* for ORDERED hint */
  table_tin         number,                        /* table instance number */
  table_pos         number,                             /* for ORDERED hint */
  ref_id            number,        /* node id that this hint is referencing */
  user_table_name   varchar2(260), /* table name to which this hint applies */
  cost              double precision,    /* optimizer estimated cost of the */
                                                        /* hinted operation */
  cardinality       double precision,    /* optimizer estimated cardinality */
                                                 /* of the hinted operation */
  bytes             double precision,     /* optimizer estimated byte count */
                                                 /* of the hinted operation */
  hint_textoff      number,             /* offset into the SQL statement to */
                                                 /* which this hint applies */
  hint_textlen      number,     /* length of SQL to which this hint applies */
  join_pred         varchar2(2000),     /* join predicate (applies only for */
                                                      /* join method hints) */
  spare1            number,         /* spare number for future enhancements */
  spare2            number,         /* spare number for future enhancements */
  hint_string       clob           /* hint text (replaces hint_text column) */
) on commit preserve rows
/
create global temporary table system.ol$nodes
(
  ol_name       varchar2(128),                              /* outline name */
  category      varchar2(128),                          /* outline category */
  node_id       number,                              /* qbc node identifier */
  parent_id     number,      /* node id of the parent node for current node */ 
  node_type     number,                                    /* qbc node type */
  node_textlen  number,         /* length of SQL to which this node applies */ 
  node_textoff  number,      /* offset into the SQL statement to which this */
                                                            /* node applies */
  node_name     varchar2(64)                               /* qbc node name */
) on commit preserve rows
/
create unique index system.ol$name on system.ol$(ol_name)
/
create unique index system.ol$signature on system.ol$(signature,category)
/
create unique index system.ol$hnt_num on system.ol$hints(ol_name, hint#)
/
create or replace public synonym ol$ for system.ol$
/
create or replace public synonym ol$hints for system.ol$hints
/
create or replace public synonym ol$nodes for system.ol$nodes
/
grant select,insert,update,delete on system.ol$ to public
/
grant select,insert,update,delete on system.ol$hints to public
/
grant select,insert,update,delete on system.ol$nodes to public
/

@?/rdbms/admin/sqlsessend.sql
