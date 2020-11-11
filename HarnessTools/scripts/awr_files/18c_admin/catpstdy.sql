Rem
Rem $Header: rdbms/admin/catpstdy.sql /main/18 2017/05/23 15:54:04 qicui Exp $
Rem
Rem catpstdy.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpstdy.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catpstdy.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catpstdy.sql
Rem SQL_PHASE: CATPSTDY
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    qicui       05/10/17 - Remove grant select on any table
Rem    dagagne     02/10/15 - remove ZDLRA on-disk stats
Rem    jinjche     02/28/14 - Add a couple of columns to dba_redo_db
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jinjche     11/22/13 - Add big SCN support
Rem    jinjche     10/16/13 - Rename nab to old_blocks
Rem    jinjche     08/21/13 - Add a column and rename some columns
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    jinjche     04/30/13 - Rename and add columns for cross-endian support
Rem    jinjche     10/19/12 - Rename redo_db.spare1 to redo_db.curlog
Rem    jinjche     10/15/12 - Remove insert that the code reviewer suggested me
Rem                           add last time because it resulted in the row being
Rem                           inserted twice
Rem    jinjche     08/24/12 - Add columns required to support Enterprise
Rem                           Manager
Rem    jinjche     07/27/12 - Change column name DBNAME to DBUNAME
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jinjche     12/22/11 - Fix a dependency issue on DBMS_DATAPUMP
Rem    jinjche     12/06/11 - Add DataPump support
Rem    jinjche     10/17/11 - Fix potential parallel upgrade issue, bug
Rem                           13102767
Rem    jinjche     08/15/11 - Add purge_done column
Rem    jinjche     08/11/11 - Add ts1 and ts2 columns to redo_log
Rem    jinjche     08/09/11 - Add two more columns to the redo_db table
Rem    jinjche     08/02/11 - Add GAP_RET column
Rem    jinjche     07/18/11 - Rename cur_branch column to has_child
Rem    jinjche     07/18/11 - Add more columns
Rem    jinjche     07/15/11 - Add and rename columns
Rem    jinjche     06/07/11 - Rename ERROR column to ERROR1
Rem    jinjche     06/01/11 - Add the error column to the redo_log table
Rem    jinjche     05/20/11 - Add three columns to the db table
Rem    jinjche     03/25/11 - Add a column to the redo_log table
Rem    jinjche     03/24/11 - Change the name of the redo_pdb table
Rem    jinjche     03/20/11 - Add some columns on sequence number
Rem    jinjche     03/18/11 - Remove redundant SQL statements and add columns
Rem    swerthei    03/15/11 - force new version on PT.RS branch
Rem    jinjche     03/09/11 - Change the Data Guard table names
Rem    jinjche     02/24/11 - Initial creation
Rem    jinjche     02/24/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE VIEW DBA_REDO_DB AS
  SELECT
    S.DBID                 DBID,
    S.GLOBAL_DBNAME        GLOBAL_DBNAME,
    S.DBUNAME              DBUNAME,
    S.VERSION              VERSION,
    S.THREAD#              THREAD#,
    S.RESETLOGS_SCN        RESETLOGS_SCN,
    S.RESETLOGS_TIME       RESETLOGS_TIME,
    S.PRESETLOGS_SCN       PRESETLOGS_SCN,
    S.PRESETLOGS_TIME      PRESETLOGS_TIME,
    S.SEQNO_RCV_CUR        SEQNO_RCV_CUR,
    S.SEQNO_RCV_LO         SEQNO_RCV_LO,
    S.SEQNO_RCV_HI         SEQNO_RCV_HI,
    S.SEQNO_DONE_CUR       SEQNO_DONE_CUR,
    S.SEQNO_DONE_LO        SEQNO_DONE_LO,
    S.SEQNO_DONE_HI        SEQNO_DONE_HI,
    S.GAP_SEQNO            GAP_SEQNO,
    S.GAP_NEXT_SCN         GAP_NEXT_SCN,
    S.GAP_NEXT_TIME        GAP_NEXT_TIME,
    S.GAP_RET              GAP_RET,
    S.GAP_DONE             GAP_DONE,
    S.APPLY_SEQNO          APPLY_SEQNO,
    S.APPLY_DONE           APPLY_DONE,
    S.PURGE_DONE           PURGE_DONE,
    S.HAS_CHILD            HAS_CHILD,
    S.ERROR1               ERROR1,
    S.STATUS               STATUS,
    S.CREATE_DATE          CREATE_DATE,
    S.TS1                  TS1,
    S.TS2                  TS2,
    S.TS3                  TS3,
    S.GAP_RET2             GAP_RET2,
    S.CURLOG               CURLOG,
    S.ENDIAN               ENDIAN,
    S.ENQIDX               ENQIDX
  FROM SYSTEM.REDO_DB S;
create or replace public synonym dba_redo_db for dba_redo_db;
grant select on dba_redo_db to select_catalog_role;


execute CDBView.create_cdbview(false,'SYS','DBA_REDO_DB','CDB_REDO_DB');
grant select on SYS.CDB_REDO_DB to select_catalog_role
/
create or replace public synonym CDB_REDO_DB for SYS.CDB_REDO_DB
/

CREATE OR REPLACE VIEW DBA_REDO_LOG AS
  SELECT
    S.DBID                 DBID,
    S.GLOBAL_DBNAME        GLOBAL_DBNAME,
    S.DBUNAME              DBUNAME,
    S.VERSION              VERSION,
    S.THREAD#              THREAD#,
    S.RESETLOGS_SCN        RESETLOGS_SCN,
    S.RESETLOGS_TIME       RESETLOGS_TIME,
    S.PRESETLOGS_SCN       PRESETLOGS_SCN,
    S.PRESETLOGS_TIME      PRESETLOGS_TIME,
    S.SEQUENCE#            SEQUENCE#,
    S.DUPID                DUPID,
    S.STATUS1              LOG_TYPE,
    S.STATUS2              LOG_STATE,
    S.CREATE_TIME          CREATE_TIME,
    S.CLOSE_TIME           CLOSE_TIME,
    S.DONE_TIME            DONE_TIME,
    S.FIRST_SCN            FIRST_SCN,
    S.FIRST_TIME           FIRST_TIME,
    S.NEXT_SCN             NEXT_SCN,
    S.NEXT_TIME            NEXT_TIME,
    S.BLOCKS               BLOCKS,
    S.BLOCK_SIZE           BLOCK_SIZE,
    S.CREATE_DATE          CREATE_DATE,
    S.ERROR1               ERROR1,
    S.ERROR2               ERROR2,
    S.FILENAME             FILENAME,
    S.TS1                  TS1,
    S.TS2                  TS2,
    S.TS3                  TS3,
    S.ENDIAN               ENDIAN,
    S.OLD_BLOCKS           OLD_BLOCKS,
    S.OLD_STATUS1          OLD_LOG_TYPE,
    S.OLD_STATUS2          OLD_LOG_STATE,
    S.OLD_FILENAME         OLD_FILENAME
  FROM SYSTEM.REDO_LOG S;
create or replace public synonym dba_redo_log for dba_redo_log;
grant select on dba_redo_log to select_catalog_role;


execute CDBView.create_cdbview(false,'SYS','DBA_REDO_LOG','CDB_REDO_LOG');
grant select on SYS.CDB_REDO_LOG to select_catalog_role
/
create or replace public synonym CDB_REDO_LOG for SYS.CDB_REDO_LOG
/

--
-- Register the tables
--
      delete from noexp$ where name='REDO_DB' and owner='SYSTEM'
      /
      insert into noexp$ (owner, name, obj_type)
      values('SYSTEM', 'REDO_DB', 2)
      /
      delete from noexp$ where name='REDO_LOG' and owner='SYSTEM'
      /
      insert into noexp$ (owner, name, obj_type)
      values('SYSTEM', 'REDO_LOG', 2)
      /

delete from sys.impcalloutreg$ where tag='PSTDY';

insert into sys.impcalloutreg$ (package, schema, tag, class, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
     values ('PSTDY_DATAPUMP_SUPPORT','SYS','PSTDY',3,0,
             'SYSTEM','REDO_DB',2,'Standby Redo Management');
insert into sys.impcalloutreg$ (package, schema, tag, class, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
     values ('PSTDY_DATAPUMP_SUPPORT','SYS','PSTDY',3,0,
             'SYSTEM','REDO_LOG',2,'Standby Redo Management');
commit;


@?/rdbms/admin/sqlsessend.sql
