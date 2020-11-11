Rem
Rem $Header: rdbms/admin/catappupgpre.sql /main/2 2017/06/14 10:35:11 pyam Exp $
Rem
Rem catappupgpre.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catappupgpre.sql - creates prerequisite objects for app capture/replay 
Rem
Rem    DESCRIPTION
Rem      Creates objects needed for ALTER PLUGGABLE DATABASE APPLICATION
Rem      statements to run properly. pdb_sync$, fed$apps, etc.
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catappupgpre.sql
Rem    SQL_SHIPPED_FILE:
Rem    SQL_PHASE: INSTALL
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE:
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pyam        06/04/17 - Bug 25578235: add pdb_sync$.sessserial# index
Rem    pyam        11/07/16 - Prerequisites for App Upgrade
Rem    pyam        11/07/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- PDB_SYNC$ alters needed for 12.1->12.2
Rem =======================================================================
Rem BEGIN Changes for pdb_sync$
Rem =======================================================================
REM This table stores some information about any common ddl changes that may
REM have happened in root when one or more of the pdbs were closed. This will
REM be consulted during the next read write open of the pdb to sync only the
REM changed information.
REM This table usually has data in root only.
create table pdb_sync$
(
  scnwrp      number not null,       /* scnbas - scn base, scnwrp - scn wrap */
  scnbas      number not null,                 /* scn for the current change */
  ctime       date not null,                                /* creation time */
  sqlstmt     varchar2(4000),    /* responsible sql statement for the change */
  name        varchar2(128) not null,         /* primary object name changed */
  auxname1    varchar2(128),                     /* aux name1 for the object */
  auxname2    varchar2(128),                     /* aux name2 for the object */
  opcode      number not null,                      /* opcode for the change */
  flags       number,                                               /* flags */
  longsqltxt  clob,                                         /* long sql text */
  replay#     number not null,      /* replay counter: 
                                    /*     in PDB,  total # of DDLs replayed */
                                    /*     in ROOT, total # of DDLs executed */
  creation#   number,                                               /* spare */
  spare3      varchar2(128),                                        /* spare */
  spare4      varchar2(128),                                        /* spare */
  spare5      varchar2(4000),                                       /* spare */
  spare6      number,                                               /* spare */
  spare7      number,                                               /* spare */
  spare8      number                                                /* spare */
)
/

ALTER TABLE pdb_sync$ ADD (sqlid varchar2(13));

ALTER TABLE pdb_sync$ ADD (appid#      number);
                                                           /* Application ID */
ALTER TABLE pdb_sync$ ADD (ver#        number);
                          /* Internally generated application version number */
ALTER TABLE pdb_sync$ ADD (patch#      number);
                                                 /* Application patch number */
ALTER TABLE pdb_sync$ ADD (app_status  number);
                                                    /* Status of Application */
ALTER TABLE pdb_sync$ ADD (sessserial# number);
                                                          /* session serial# */

REM pdb_sync$ is also used for 12.2 capture/replay
DROP INDEX i_pdbsync1
/

CREATE INDEX i_pdbsync1 ON pdb_sync$(replay#)
/

CREATE INDEX i_pdbsync2 on pdb_sync$(name)
/

CREATE INDEX i_pdbsync3 on pdb_sync$(bitand(flags,8))
/

CREATE INDEX i_pdbsync4 ON pdb_sync$(sessserial#)
/

REM This table is an auxiliary table to pdb_sync$.  pdb_sync$ will evolve to
REM store only the id for the sql statement. pdb_sync_stmt$ will then
REM store the mapping from sql id to full sql text.  Intent is to store the
REM same sql text only once.
CREATE TABLE pdb_sync_stmt$
(
  appid#      number,                                      /* Application id */
  sqlid       varchar2(13),              /* base 32 representation of sql id */
  sqltext     clob                                          /* full sql text */
)
/

CREATE UNIQUE INDEX i_pdb_sync_stmt$ ON pdb_sync_stmt$(appid#, sqlid)
/

Rem =======================================================================
Rem  END Changes for pdb_sync$
Rem =======================================================================

-- other app container tables needed
@@?/rdbms/admin/catappcontainertab.sql

@?/rdbms/admin/sqlsessend.sql
 
