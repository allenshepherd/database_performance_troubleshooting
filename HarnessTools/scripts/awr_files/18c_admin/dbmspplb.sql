Rem
Rem
Rem dbmspplb.sql
Rem
Rem Copyright (c) 2015, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmspplb.sql - RDBMS Pre-Plugin Backup package specification
Rem
Rem    DESCRIPTION
Rem      Defines the interface to restore pre-plugin backups.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmspplb.sql 
Rem    SQL_SHIPPED_FILE:  rdbms/admin/dbmspplb.sql
Rem    SQL_PHASE: DBMSPPLB
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    panreddy    03/15/16 - bug-22813503 switch container using dbms_sql.
Rem    molagapp    05/30/15 - bug-21132967
Rem    molagapp    05/05/15 - rename importX$RmanTables
Rem    molagapp    03/23/15 - Project 47808 - Phase 2
Rem    molagapp    01/22/15 - Project 47808 - Restore from preplugin backup
Rem    molagapp    01/16/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE TYPE SYS.ORA$PREPLUGIN_BACKUP_MSG_T AS OBJECT
(
   con_id NUMBER
);
/

--*****************************************************************************
-- Package Declaration
--*****************************************************************************

CREATE OR REPLACE PACKAGE sys.dbms_preplugin_backup AS

   PROCEDURE dropX$RmanTables(p_con_id IN number);
   -- Purges all X$ tables used by RMAN to restore and recover pre-plugin
   -- backup from ROOT.
   --
   -- Input arguments:
   --    p_con_id - container id of database whose X$ tables needs to be
   --               purged.
   --

   PROCEDURE exportX$RmanTables(
                p_pdb_name IN varchar2 DEFAULT NULL
               ,p_type     IN number   DEFAULT NULL);
   -- Exports all X$ tables used by RMAN to restore and recover pre-plugin
   -- backup into PDB dictionary.
   --
   -- Input arguments:
   --    pdb_name - name of a pluggable database to be exported. If pdb_name
   --               is omitted, the pluggable database to which the session
   --               is connected will be exported. If pdb_name is omitted,
   --               and the session is connected to the Root, an error will
   --               be returned.
   --    type     - NULL to indicate export all x$ tables.
   --               1 - export only tables required for media recovery.
   --               2 - export only backup meta-data tables
   --

   PROCEDURE importX$RmanTables(p_pdb_name IN varchar2);
   -- Imports all X$ tables used by RMAN to restore and recover pre-plugin
   -- backup from PDB dictonary to ROOT.
   --
   -- Input arguments:
   --    pdb_name - name of the pluggable database to be imported. If the
   --               session is connected to the Root, an error will
   --               be returned.

   PROCEDURE importX$RmanTablesUsingConId(
      p_msg IN SYS.ORA$PREPLUGIN_BACKUP_MSG_T);
   -- See previous description except that instead of pdb_name, this
   -- procedure takes container id as input as message type.
   --

   PROCEDURE importX$RmanTablesAsJob(p_con_id IN number);
   -- Same as importX$RmanTables except that it is executed as async
   -- using dbms_scheduler.

   PROCEDURE exportX$RmanTablesAsPdb(p_type IN number);
   -- Export X$ Rman tables procedure that can be invoked using dbms_sql.

   PROCEDURE truncateX$RmanTables;
   -- Truncate KRBPPBTBL tables procedure that can be invoked using dbms_sql.
END;
/

@?/rdbms/admin/sqlsessend.sql
