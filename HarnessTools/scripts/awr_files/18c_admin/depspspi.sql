Rem
Rem $Header: rdbms/admin/depspspi.sql /main/5 2014/12/11 22:46:35 skayoor Exp $
Rem
Rem depspspi.sql
Rem
Rem Copyright (c) 2009, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      depspspi.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/depspspi.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/depspspi.sql
Rem SQL_PHASE: DEPSPSPI
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    shase       01/28/09 - Add dependent views of Archive Provider
Rem    shase       01/28/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE VIEW USER_DBFS_HS_FILES AS SELECT APT.path, SF.SequenceNumber, SF.StartOffset, SF.EndOffset, SF.TarballId, BF.BackupFileName, BF.TarStartOffset, BF.TarEndOffset FROM DBFS_HS$_SFLocatorTable SF, DBFS_HS$_ContentFnMapTbl MP, DBFS_HS$_StoreId2PolicyCtx PC, DBFS_HS$_BackupFileTable BF, TABLE(dbms_dbfs_hs.listcontentfilename) APT WHERE MP.ArchiveRefId = SF.ArchiveRefId AND PC.StoreId = BF.StoreId AND BF.TarballId = SF.TarballId AND APT.contentfilename = MP.ContentFilename
/

CREATE OR REPLACE PUBLIC SYNONYM USER_DBFS_HS_FILES FOR USER_DBFS_HS_FILES
/

GRANT READ ON USER_DBFS_HS_FILES TO PUBLIC
/


@?/rdbms/admin/sqlsessend.sql
