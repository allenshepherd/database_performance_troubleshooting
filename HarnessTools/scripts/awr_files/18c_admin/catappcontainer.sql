Rem
Rem $Header: rdbms/admin/catappcontainer.sql /main/44 2017/11/12 10:33:00 pyam Exp $
Rem
Rem catappcontainer.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catappcontainer.sql - Application Container tables and views
Rem
Rem    DESCRIPTION
Rem      Create tables and views used by a Application Container
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catappcontainer.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catappcontainer.sql 
Rem    SQL_PHASE: CATAPPCONTAINER
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pyam        11/04/17 - Bug 26894818: int$dba_app_statements.app_id
Rem    thbaby      10/26/17 - Bug 26988917: set MIGRATE_CROSS_CON
Rem    pyam        06/04/17 - Bug 25578235: dba_app_statements additions
Rem    pyam        05/16/17 - Bug 21503941 fwd merge: table creation to .bsq
Rem    thbaby      04/21/17 - Bug 25906547: begin/end system app only in Root
Rem    pjulsaks    04/05/17 - Bug 25773902: Add ver# to dba_app_statements
Rem    pjulsaks    03/21/16 - Bug 25661716: Add checksum column in patch/ver
Rem    pyam        12/14/16 - Bug 25256116: no cat..tab.sql if capturing
Rem    pyam        11/10/16 - move tables into catappcontainertab.sql
Rem    thbaby      06/30/16 - Bug 22911078: show app status as SET VERSION
Rem    thbaby      05/22/16 - Bug 21540980: add DBA_APP_PDB_STATUS
Rem    thbaby      05/20/16 - Bug 21540980: spare1 column to store UID of PDB
Rem    sursridh    03/11/16 - Bug 21028455: Rename catfed->catappcontainer.
Rem    sursridh    03/09/16 - Bug 22895916: Add columns to fed$binds.
Rem    thbaby      02/08/16 - Bug 22606619: avoid temp lob in
Rem                           INT$DBA_APP_STATEMENTS
Rem    akruglik    01/13/16 - (22132084): replace COMMON_DATA with EXTENDED
Rem                           DATA
Rem    thbaby      01/07/16 - Bug 22384309: add SYNC_TIME to DBA_APP_ERRORS
Rem    jaeblee     12/17/15 - 22162629: only install APP$CDB$SYSTEM for CDB
Rem    sursridh    12/01/15 - Bug 21515971: Add inc# to fed$binds.
Rem    pyam        11/22/15 - 22282825: change fed$statements to pdb_sync$
Rem    sursridh    11/12/15 - Move sqlid col from fed$binds to fed$statements.
Rem    thbaby      10/21/15 - 21963357: add ORIGIN_CON_ID to DBA_APP_STATEMENTS
Rem    thbaby      10/15/15 - 21963357: install application APP$CDB$SYSTEM
Rem    thbaby      10/10/15 - 21963357: create sequence app$system$seq
Rem    thbaby      10/10/15 - 21963357: add srvn and modn columns 
Rem    thbaby      10/05/15 - 21841612: add comment column to fed$ tables
Rem    thbaby      09/21/15 - bug 21871257: order statement sequence
Rem    dgagne      09/03/15 - add insert into impcalloutreg$ for datapump
Rem                           approot support - Proj 47234
Rem    juilin      08/25/15 - 21659390: set fed$bind column value type to blob
Rem    thbaby      08/17/15 - 21646878: add table fed$dependency
Rem    thbaby      08/04/15 - 20561398: add errorseq# column to fed$app$status
Rem    thbaby      07/22/15 - 21485248: Federation -> Application Container
Rem    pyam        06/23/15 - CDB-wide applications
Rem    thbaby      06/12/15 - 21251366: rename no_op column to flag
Rem    thbaby      03/11/15 - add spare columns to fed$ tables
Rem    thbaby      03/01/15 - Proj 47234: add flag column to fed$apps
Rem    pyam        02/17/15 - add fed$sessions
Rem    thbaby      02/07/15 - Proj 47234: add DBA_APP_ERRORS
Rem    thbaby      02/07/15 - Proj 47234: add INT$DBA_APP_STATEMENTS
Rem    thbaby      02/06/15 - Proj 47234: handle INSTALLING in DBA_APPLICATIONS
Rem    pyam        01/07/15 - add fed$editions
Rem    pyam        12/01/14 - Proj 47234: add fed$binds
Rem    thbaby      11/17/14 - Proj 47234: change column to root_clone_con_uid#
Rem    thbaby      10/10/14 - Proj 47234: fix DBA_APPLICATIONS
Rem    thbaby      09/03/14 - Proj 47234: create Federation Views
Rem    thbaby      09/02/14 - Proj 47234: create tables need by Federation
Rem    thbaby      09/02/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Bug 25906547: begin/end system application only in CDB Root
begin
  if (sys_context('USERENV','CON_ID') = 1) then
    execute immediate 'alter pluggable database application APP$CDB$SYSTEM ' ||
                      'begin install ''1.0''';
    execute immediate 'alter pluggable database application APP$CDB$SYSTEM ' ||
                      'end   install ''1.0''';
  end if;
exception when others then
  if sqlcode in (-65212, -65221, -65251, -65213, -65271, -65217) then null;
  else raise;
  end if;
end;
/

/*****************************************************************************/
/*************************** DBA_APPLICATIONS  *******************************/
/*****************************************************************************/
create or replace view DBA_APPLICATIONS (
  APP_NAME,                                              /* Application Name */
  APP_ID,                                                  /* Application ID */
  APP_VERSION,                                        /* Application Version */
  APP_STATUS,                                          /* Application Status */
  APP_IMPLICIT,                                   /* Is Application Implicit */
  APP_CAPTURE_SERVICE,                      /* Service Name used for Capture */
  APP_CAPTURE_MODULE                         /* Module Name used for Capture */
)
as
select a.app_name, a.appid#, NULL, 'INSTALLING',
       decode(bitand(a.flag,56), 0, 'N', 'Y'), a.srvn, a.modn
from fed$apps a
where a.app_name <> '_CURRENT_STATE'
and a.app_status=1
and a.spare1=0
union all
select a.app_name, a.appid#, v.tgtver,
       decode(a.app_status, 2, 'UPGRADING', 3, 'PATCHING',
                            4, 'UNINSTALLING', 5, 'UNINSTALLED',
                            6, 'SET VERSION', 7, 'SET PATCH',
                            0, 'NORMAL'),
       decode(bitand(a.flag,56), 0, 'N', 'Y'), a.srvn, a.modn
from fed$apps a, fed$versions v
where a.app_name <> '_CURRENT_STATE'
and a.ver#=v.ver#
and a.appid#=v.appid#
and a.app_status<>1
and a.spare1=0
/

comment on table DBA_APPLICATIONS is
'Describes all applications in the Application Container'
/

comment on column DBA_APPLICATIONS.APP_NAME is
'Name of the application'
/

comment on column DBA_APPLICATIONS.APP_ID is
'Id of the application'
/

comment on column DBA_APPLICATIONS.APP_VERSION is
'Version of the application'
/

comment on column DBA_APPLICATIONS.APP_STATUS is
'Status of the application'
/

comment on column DBA_APPLICATIONS.APP_IMPLICIT is
'Whether the application is implicit'
/

comment on column DBA_APPLICATIONS.APP_CAPTURE_SERVICE is
'Service name used for capture'
/

comment on column DBA_APPLICATIONS.APP_CAPTURE_MODULE is
'Module name used for capture'
/

create or replace public synonym DBA_APPLICATIONS for DBA_APPLICATIONS
/

grant select on DBA_APPLICATIONS to select_catalog_role
/

/*****************************************************************************/
/**************************** DBA_APP_PATCHES  *******************************/
/*****************************************************************************/
create or replace view DBA_APP_PATCHES (
  APP_NAME,                                              /* Application Name */
  PATCH_NUMBER,                                              /* Patch Number */
  PATCH_MIN_VERSION,                    /* Patch Minimum Application Version */
  PATCH_STATUS,                                              /* Patch Status */
  PATCH_COMMENT,                                            /* Patch Comment */
  PATCH_CHECKSUM                                           /* Patch Checksum */
)
as
select a.app_name, p.patch#, v.tgtver,
       decode(p.status, 0, 'INSTALLING', 1, 'INSTALLED'), p.cmnt, p.spare1
from fed$apps a, fed$versions v, fed$patches p
where a.app_name <> '_CURRENT_STATE'
and a.appid#=v.appid# and v.appid#=p.appid#
and v.ver#=p.minver#
and a.spare1=0
/

comment on table DBA_APP_PATCHES is
'Describes all application patches in the Application Container'
/

comment on column DBA_APP_PATCHES.APP_NAME is
'Name of the application'
/

comment on column DBA_APP_PATCHES.PATCH_NUMBER is
'Patch number'
/

comment on column DBA_APP_PATCHES.PATCH_MIN_VERSION is
'Minimum application version for the patch'
/

comment on column DBA_APP_PATCHES.PATCH_STATUS is
'Status of the patch'
/

comment on column DBA_APP_PATCHES.PATCH_COMMENT is
'Comment associated with the patch'
/

comment on column DBA_APP_PATCHES.PATCH_CHECKSUM is
'Checksum for the patch'
/

create or replace public synonym DBA_APP_PATCHES for DBA_APP_PATCHES
/

grant select on DBA_APP_PATCHES to select_catalog_role
/

/*****************************************************************************/
/*************************** DBA_APP_VERSIONS  *******************************/
/*****************************************************************************/
create or replace view DBA_APP_VERSIONS (
  APP_NAME,                                              /* Application Name */
  APP_VERSION,                                        /* Application Version */
  APP_VERSION_COMMENT,                    /* Comment for Application Version */
  APP_VERSION_CHECKSUM                               /* Application Checksum */
)
as
select a.app_name, v.tgtver, v.cmnt, v.spare1
from fed$apps a, fed$versions v
where a.app_name <> '_CURRENT_STATE'
and a.appid#=v.appid#
and a.spare1=0
/

comment on table DBA_APP_VERSIONS is
'Describes all applications in the Application Container'
/

comment on column DBA_APP_VERSIONS.APP_NAME is
'Name of the application'
/

comment on column DBA_APP_VERSIONS.APP_VERSION is
'Version of the application'
/

comment on column DBA_APP_VERSIONS.APP_VERSION_COMMENT is
'Comment for the application version'
/

comment on column DBA_APP_VERSIONS.APP_VERSION_CHECKSUM is
'Checksum for the application version'
/

create or replace public synonym DBA_APP_VERSIONS for DBA_APP_VERSIONS
/

grant select on DBA_APP_VERSIONS to select_catalog_role
/

/*****************************************************************************/
/*********************** DBA_APP_STATEMENTS **********************************/
/*****************************************************************************/

create or replace view INT$DBA_APP_STATEMENTS 
migrate_cross_con sharing=extended data (
  STATEMENT_ID,
  CAPTURE_TIME,
  LONGSQLTXT,
  SQLSTMT,
  APP_NAME,
  APP_STATUS,
  PATCH_NUMBER,
  VERSION_NUMBER,
  SESSION_ID,
  OPCODE,
  OPTIMIZED,
  APP_ID,
  SHARING,
  ORIGIN_CON_ID
)
as select s.replay#, s.ctime, s.longsqltxt, s.sqlstmt, a.app_name,
          decode(s.app_status, 1, 'INSTALLING', 2, 'UPGRADING', 3, 'PATCHING',
                               4, 'UNINSTALLING', 5, 'UNINSTALLED',
                               6, 'SET VERSION', 7, 'SET PATCH',
                               0, 'NORMAL'),
          s.patch#, s.ver#, s.sessserial#, s.opcode,
          decode(bitand(s.flags,48), 16, 'NO OP', 32, 'NO REPLAY', null)
            optimized, s.appid#,
          1,
          to_number(sys_context('USERENV', 'CON_ID'))
from fed$apps a, pdb_sync$ s
where a.appid#=s.appid# and bitand(s.flags,8)=8 and a.spare1=0
/

create or replace view DBA_APP_STATEMENTS (
  ORIGIN_CON_ID,
  STATEMENT_ID,
  CAPTURE_TIME,
  APP_STATEMENT,
  APP_NAME,
  APP_STATUS,
  PATCH_NUMBER,
  VERSION_NUMBER,
  SESSION_ID, 
  OPCODE
)
as select ORIGIN_CON_ID, STATEMENT_ID, CAPTURE_TIME, NVL(LONGSQLTXT, SQLSTMT),
          APP_NAME, APP_STATUS, PATCH_NUMBER, VERSION_NUMBER, SESSION_ID,
          OPCODE
from INT$DBA_APP_STATEMENTS
/

comment on table DBA_APP_STATEMENTS is
'Describes all statements from all applications in the Application Container'
/

comment on column DBA_APP_STATEMENTS.ORIGIN_CON_ID is 
'ID of Container where row originates'
/

comment on column DBA_APP_STATEMENTS.STATEMENT_ID is
'Statement ID'
/

comment on column DBA_APP_STATEMENTS.CAPTURE_TIME is
'Time of capture of application statement'
/

comment on column DBA_APP_STATEMENTS.APP_STATEMENT is 
'Application statement'
/

comment on column DBA_APP_STATEMENTS.APP_NAME is
'Name of the application whose statement was captured'
/

comment on column DBA_APP_STATEMENTS.APP_STATUS is
'Status of the application when statement was captured'
/

comment on column DBA_APP_STATEMENTS.PATCH_NUMBER is 
'Patch number of patch installation when statement was captured'
/

comment on column DBA_APP_STATEMENTS.SESSION_ID is 
'Unique session id when statement was captured'
/

comment on column DBA_APP_STATEMENTS.OPCODE is 
'Opcode indicating statement type'
/

comment on column DBA_APP_STATEMENTS.VERSION_NUMBER is 
'Version number when statement was captured'
/

create or replace public synonym DBA_APP_STATEMENTS 
for DBA_APP_STATEMENTS
/

grant select on DBA_APP_STATEMENTS to select_catalog_role
/

/*****************************************************************************/
/****************************** DBA_APP_ERRORS *******************************/
/*****************************************************************************/
create or replace view DBA_APP_ERRORS (
  APP_NAME,
  APP_STATEMENT,
  ERRORNUM,
  ERRORMSG,
  SYNC_TIME)
as select s.APP_NAME, s.APP_STATEMENT, e.ERRORNUM, e.ERRORMSG, e.stime
from DBA_APP_STATEMENTS s, fed$statement$errors e, fed$apps a 
where s.STATEMENT_ID=e.SEQ#
and a.appid#=e.appid#
and a.app_name=s.app_name
and a.spare1=0
order by s.STATEMENT_ID
/

comment on table DBA_APP_ERRORS is
'Describes all application error messages in the Application Container'
/

comment on column DBA_APP_ERRORS.APP_NAME is
'Name of the application whose statement was captured'
/

comment on column DBA_APP_ERRORS.APP_STATEMENT is 
'Application statement'
/

comment on column DBA_APP_ERRORS.ERRORNUM is 
'Error number for statement'
/

comment on column DBA_APP_ERRORS.ERRORMSG is
'Error message for statement'
/

comment on column DBA_APP_ERRORS.SYNC_TIME is
'Time of sync of statement'
/

create or replace public synonym DBA_APP_ERRORS for DBA_APP_ERRORS
/

grant select on DBA_APP_ERRORS to select_catalog_role
/

/*****************************************************************************/
/**************************** DBA_APP_PDB_STATUS  ****************************/
/*****************************************************************************/
create or replace view DBA_APP_PDB_STATUS (
  CON_UID,                                           /* Unique Id of the PDB */
  APP_NAME,                                              /* Application Name */
  APP_ID,                                                  /* Application ID */
  APP_VERSION,                                        /* Application Version */
  APP_STATUS                                           /* Application Status */
)
as
select a.spare1, a.app_name, a.appid#, NULL, 'INSTALLING'
from fed$apps a
where a.app_name <> '_CURRENT_STATE'
and a.app_status=1
and a.spare1>0
union all
select a.spare1, a.app_name, a.appid#, v.tgtver,
       decode(a.app_status, 2, 'UPGRADING', 3, 'PATCHING',
                            0, 'NORMAL')
from fed$apps a, fed$versions v
where a.app_name <> '_CURRENT_STATE'
and a.ver#=v.ver#
and a.appid#=v.appid#
and a.app_status not in (1, 4, 5)
and a.spare1>0
union all
select a.spare1, a.app_name, a.appid#, v.tgtver,
       decode(a.app_status, 4, 'UNINSTALLING', 5, 'UNINSTALLED')
from fed$apps a, fed$versions v
where a.app_name <> '_CURRENT_STATE'
and a.ver#-1=v.ver#
and a.appid#=v.appid#
and a.app_status in (4, 5)
and a.spare1>0
/

comment on table DBA_APP_PDB_STATUS is
'Describes all applications in the Application Container'
/

comment on column DBA_APP_PDB_STATUS.CON_UID is
'Unique ID of the PDB'
/

comment on column DBA_APP_PDB_STATUS.APP_NAME is
'Name of the application'
/

comment on column DBA_APP_PDB_STATUS.APP_ID is
'Id of the application'
/

comment on column DBA_APP_PDB_STATUS.APP_VERSION is
'Version of the application'
/

comment on column DBA_APP_PDB_STATUS.APP_STATUS is
'Status of the application'
/

create or replace public synonym DBA_APP_PDB_STATUS for DBA_APP_PDB_STATUS
/

grant select on DBA_APP_PDB_STATUS to select_catalog_role
/

/*****************************************************************************/
/****************************** Import callout support ***********************/
/*****************************************************************************/
-- NOTE uncomment out when replay code supports Data Pump import.
--delete from sys.impcalloutreg$ where tag='APPROOT';
--
--insert into sys.impcalloutreg$ (package, schema, tag, class, flags,
--                                tgt_schema, tgt_object, tgt_type, cmnt)
--     values ('DBMS_PDB','SYS','APPROOT',3, 1, 'SYS', 'FED$%', 2,
--             'Application Root/PDB objects');
--
--commit;

@?/rdbms/admin/sqlsessend.sql
