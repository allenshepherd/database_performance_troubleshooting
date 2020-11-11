Rem
Rem $Header: rdbms/admin/catpspi.sql /main/10 2016/01/21 13:22:41 amullick Exp $
Rem
Rem catpspi.sql
Rem
Rem Copyright (c) 2009, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpspi.sql - catalog for DBFS HS service provider
Rem
Rem    DESCRIPTION
Rem       Creates the dictionary objects necessary for DBFS HS service 
Rem       provider.
Rem
Rem    NOTES
Rem      
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catpspi.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catpspi.sql
Rem SQL_PHASE: CATPSPI
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amullick    12/22/15 - Bug22455465: define user views on current user
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    shase       07/27/09 - bug 8729613- fwd merge for bug 8666190 and bug
Rem                           8614740
Rem    amullick    02/27/09 - fix bug8291480
Rem    schitti     01/28/09 - Add views
Rem    amullick    01/22/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem dbfs hs Metadata Table
create table sys.dbfs_hs$_fs (
        store_owner          varchar2(128)    not null
    ,   store_name           varchar2(128)    not null
    ,   version#             integer         not null
    /* global constraints  */
    ,  unique  (store_owner, store_name)
)
   tablespace SYSAUX;

grant select on sys.dbfs_hs$_fs
    to dbfs_role;

Rem used to genarate a unique id per store per database
create sequence sys.dbfs_hs$_rseq     
  start with 1
  increment by 1
  minvalue 1
  nomaxvalue
  cache 20
  order
  nocycle 
/

Rem dbfs hs internal property table
create table sys.dbfs_hs$_property (
        store_owner          varchar2(128)    not null
    ,   store_name           varchar2(128)    not null
    ,   prop_name            varchar2(256)   not null
    ,   prop_value           varchar2(256)   not null
    ,   prop_type            varchar2(128)    not null
) tablespace SYSAUX;



Rem Table for determining -
Rem 1. Which Tarball is a ArchiveRefId present in, and at what offset in 
Rem    the tarball is it present in.
CREATE TABLE sys.dbfs_hs$_SFLocatorTable (
   ArchiveRefId     RAW(256),
   SequenceNumber   NUMBER,
   StartOffset      NUMBER,
   EndOffset        NUMBER,
   TarballId        NUMBER) TABLESPACE SYSAUX
/

create index i1_dbfs_hs$_SFLocatorTable on sys.dbfs_hs$_SFLocatorTable(ArchiveRefId, SequenceNumber)
/

CREATE INDEX i2_dbfs_hs$_SFLocatorTable ON sys.dbfs_hs$_SFLocatorTable(TarballId)
/

Rem This table determines -
Rem Which are the stores the tarball is written to
Rem If the tarball had to be split up while writing to a store,
Rem what are the files into which it has been split up
CREATE TABLE sys.dbfs_hs$_BackupFileTable(
   TarballId      NUMBER,
   StoreId        NUMBER,
   BackupFileName VARCHAR2(256),
   TarStartOffset NUMBER,
   TarEndOffset   NUMBER) TABLESPACE SYSAUX
/                                            

CREATE INDEX i1_dbfs_hs$_BackupFileTable ON sys.dbfs_hs$_BackupFileTable(StoreId, TarballId)
/

CREATE INDEX i2_dbfs_hs$_BackupFileTable ON sys.dbfs_hs$_BackupFileTable(BackupFileName)
/

Rem Maps a contentFilename to a ArchiveRefId
Rem ArchiveRefId is the db-wide unique reference
Rem Two or more contentIds can have the same ArchiveRefId
CREATE TABLE sys.dbfs_hs$_ContentFnMapTbl (
  ContentFilename VARCHAR2(1024) PRIMARY KEY,
  ArchiveRefId    RAW(256)) TABLESPACE SYSAUX
/

CREATE TABLE sys.dbfs_hs$_storeCommands(
   StoreId      NUMBER,
   StoreCommand VARCHAR2(512),
   StoreFlags   NUMBER) TABLESPACE SYSAUX
/   

CREATE INDEX  i1_dbfs_hs$_storeCommands ON sys.dbfs_hs$_storeCommands(StoreId)
/

CREATE TABLE sys.dbfs_hs$_StoreId2PolicyCtx(
   PolicyType NUMBER,
   StoreId    NUMBER,
   PolicyCtx  RAW(1024) ) TABLESPACE SYSAUX
/

CREATE INDEX i1_dbfs_hs$_StoreId2PolicyCtx ON sys.dbfs_hs$_StoreId2PolicyCtx(PolicyCtx)
/

CREATE INDEX i2_dbfs_hs$_StoreId2PolicyCtx ON sys.dbfs_hs$_StoreId2PolicyCtx(StoreId)
/

CREATE TABLE sys.dbfs_hs$_StoreProperties(
   storeId        NUMBER,
   propertyName  VARCHAR2(256), 
   propertyValue VARCHAR2(256))  TABLESPACE SYSAUX
/

CREATE INDEX i1_dbfs_hs$_StoreProperties ON sys.dbfs_hs$_StoreProperties(StoreId)
/

CREATE TABLE sys.dbfs_hs$_StoreIdTable(
   StoreName      VARCHAR2(256),
   StoreOwner     VARCHAR2(64),
   StoreId        NUMBER,
   unique(StoreName, StoreOwner) ) TABLESPACE SYSAUX
 /
 
 CREATE SEQUENCE sys.dbfs_hs$_storeIdSeq
  start with 1
  increment by 1
  minvalue 1
  nomaxvalue
  cache 2
  order
  nocycle
/

CREATE SEQUENCE sys.dbfs_hs$_ArchiveRefIdSeq
  start with 1
  increment by 1
  minvalue 1
  nomaxvalue
  cache 2
  order
  nocycle
/

CREATE SEQUENCE sys.dbfs_hs$_TarballSeq
  start with 1
  increment by 1
  minvalue 1
  nomaxvalue
  cache 2
  order
  nocycle
/

CREATE SEQUENCE sys.dbfs_hs$_PolicyIdSeq
  start with 1
  increment by 1
  minvalue 1
  nomaxvalue
  cache 2
  order
  nocycle
/

CREATE SEQUENCE sys.dbfs_hs$_BackupFileIdSeq
  start with 1
  increment by 1
  minvalue 1
  nomaxvalue
  cache 2
  order
  nocycle
/

CREATE OR REPLACE VIEW DBA_DBFS_HS AS SELECT storeName, storeOwner FROM sys.dbfs_hs$_storeIdTable
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_DBFS_HS for DBA_DBFS_HS
/

GRANT SELECT ON DBA_DBFS_HS TO select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_DBFS_HS','CDB_DBFS_HS');
grant select on SYS.CDB_DBFS_HS to select_catalog_role
/
create or replace public synonym CDB_DBFS_HS for SYS.CDB_DBFS_HS
/

CREATE OR REPLACE VIEW USER_DBFS_HS AS SELECT d.storeName FROM DBA_DBFS_HS d, sys.user$ u WHERE u.user#= userenv('SCHEMAID') and d.storeOwner = u.name
/

CREATE OR REPLACE PUBLIC SYNONYM USER_DBFS_HS for USER_DBFS_HS
/
 
GRANT READ ON  USER_DBFS_HS TO PUBLIC
/

CREATE OR REPLACE VIEW DBA_DBFS_HS_PROPERTIES AS SELECT RT.storeName, RT.StoreOwner, propertyName, propertyValue FROM sys.dbfs_hs$_storeProperties RP, sys.dbfs_hs$_storeIdTable RT WHERE RP.storeId = RT.storeId
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_DBFS_HS_PROPERTIES for DBA_DBFS_HS_PROPERTIES
/

GRANT SELECT ON DBA_DBFS_HS_PROPERTIES TO select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_DBFS_HS_PROPERTIES','CDB_DBFS_HS_PROPERTIES');
grant select on SYS.CDB_DBFS_HS_PROPERTIES to select_catalog_role
/
create or replace public synonym CDB_DBFS_HS_PROPERTIES for SYS.CDB_DBFS_HS_PROPERTIES
/

CREATE OR REPLACE VIEW USER_DBFS_HS_PROPERTIES AS SELECT RP.storeName, RP.propertyName, RP.propertyValue FROM DBA_DBFS_HS_PROPERTIES RP, USER_DBFS_HS UR WHERE UR.storeName = RP.storeName
/

CREATE OR REPLACE PUBLIC SYNONYM USER_DBFS_HS_PROPERTIES FOR USER_DBFS_HS_PROPERTIES
/

GRANT READ ON USER_DBFS_HS_PROPERTIES TO PUBLIC
/

CREATE OR REPLACE VIEW DBA_DBFS_HS_COMMANDS AS SELECT RT.StoreName, RT.StoreOwner, StoreCommand, StoreFlags FROM sys.dbfs_hs$_StoreCommands RC, sys.dbfs_hs$_StoreIdTable RT WHERE RC.StoreId = RT.StoreId
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_DBFS_HS_COMMANDS for DBA_DBFS_HS_COMMANDS
/

GRANT SELECT ON DBA_DBFS_HS_COMMANDS TO select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_DBFS_HS_COMMANDS','CDB_DBFS_HS_COMMANDS');
grant select on SYS.CDB_DBFS_HS_COMMANDS to select_catalog_role
/
create or replace public synonym CDB_DBFS_HS_COMMANDS for SYS.CDB_DBFS_HS_COMMANDS
/

CREATE OR REPLACE VIEW USER_DBFS_HS_COMMANDS AS SELECT RC.StoreName, RC.StoreCommand, RC.StoreFlags FROM DBA_DBFS_HS_COMMANDS RC, USER_DBFS_HS UR WHERE UR.StoreName = RC.StoreName
/

CREATE OR REPLACE PUBLIC SYNONYM USER_DBFS_HS_COMMANDS FOR USER_DBFS_HS_COMMANDS
/

GRANT READ ON USER_DBFS_HS_COMMANDS TO PUBLIC
/

CREATE OR REPLACE VIEW DBA_DBFS_HS_FIXED_PROPERTIES AS SELECT STORE_NAME , STORE_OWNER , PROP_NAME , PROP_VALUE FROM SYS.DBFS_HS$_PROPERTY WHERE PROP_TYPE LIKE 'IPROP_USER_VISIBLE' 
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_DBFS_HS_FIXED_PROPERTIES FOR DBA_DBFS_HS_FIXED_PROPERTIES
/

GRANT READ ON DBA_DBFS_HS_FIXED_PROPERTIES TO PUBLIC
/


execute CDBView.create_cdbview(false,'SYS','DBA_DBFS_HS_FIXED_PROPERTIES','CDB_DBFS_HS_FIXED_PROPERTIES');
grant READ on SYS.CDB_DBFS_HS_FIXED_PROPERTIES to PUBLIC 
/
create or replace public synonym CDB_DBFS_HS_FIXED_PROPERTIES for SYS.CDB_DBFS_HS_FIXED_PROPERTIES
/

CREATE OR REPLACE VIEW USER_DBFS_HS_FIXED_PROPERTIES AS SELECT d.STORE_NAME , d.PROP_NAME , d.PROP_VALUE FROM DBA_DBFS_HS_FIXED_PROPERTIES d, sys.user$ u WHERE u.user#= userenv('SCHEMAID') and d.STORE_OWNER = u.name
/

CREATE OR REPLACE PUBLIC SYNONYM USER_DBFS_HS_FIXED_PROPERTIES FOR USER_DBFS_HS_FIXED_PROPERTIES
/

GRANT READ ON USER_DBFS_HS_FIXED_PROPERTIES TO PUBLIC
/



@?/rdbms/admin/sqlsessend.sql
