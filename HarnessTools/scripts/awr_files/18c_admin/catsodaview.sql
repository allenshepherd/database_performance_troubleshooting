--
-- $Header: rdbms/admin/catsodaview.sql /st_rdbms_18.0/1 2018/04/11 10:34:39 sriksure Exp $
--
-- catsodaview.sql
--
-- Copyright (c) 2014, 2018, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--      catsodaview.sql - SODA collections VIEW creation
--
--    DESCRIPTION
--       Creates a view over the collections metadata table
--
--    NOTES
--      
--
--    BEGIN SQL_FILE_METADATA 
--    SQL_SOURCE_FILE: rdbms/admin/catsodaview.sql 
--    SQL_SHIPPED_FILE: rdbms/admin/catsodaview.sql
--    SQL_PHASE: CATSODAVIEW
--    SQL_STARTUP_MODE: NORMAL 
--    SQL_IGNORABLE_ERRORS: NONE 
--    SQL_CALLING_FILE: rdbms/admin/catsodacoll.sql
--    END SQL_FILE_METADATA
--
--    MODIFIED   (MM/DD/YY)
--    sriksure    04/02/18 - Bug 27698424: Backport SODA bugs from main
--    prthiaga    06/21/16 - Bug 23625161: USER -> CURRENT_USER
--    prthiaga    10/19/15 - Bug 22067651: add columns to json_table query
--    prthiaga    05/20/15 - Bug 21116398: grant read priv to SODA_APP
--    prthiaga    07/29/14 - Created
--

@@?/rdbms/admin/sqlsessstart.sql

create or replace view XDB.JSON$COLLECTION_METADATA_V
as
select MD.URI_NAME                   URI_NAME,
       MD.OWNER                      OWNER,
       JT.SCHEMA_NAME                SCHEMA_NAME,
       JT.TABLE_NAME                 TABLE_NAME,
       JT.VIEW_NAME                  VIEW_NAME,
       JT.PACKAGE_NAME               PACKAGE_NAME,
       JT.TABLESPACE_NAME            TABLESPACE_NAME,
       JT.STORAGE_INIT_SIZE          STORAGE_INIT_SIZE,
       JT.STORAGE_INCREASE_PCT       STORAGE_INCREASE_PCT,
       JT.KEY_COLUMN_NAME            KEY_COLUMN_NAME,
       JT.KEY_COLUMN_TYPE            KEY_COLUMN_TYPE,
       JT.KEY_COLUMN_LEN             KEY_COLUMN_LEN,
       JT.KEY_ASSIGNMENT_METHOD      KEY_ASSIGNMENT_METHOD,
       JT.KEY_SEQUENCE_NAME          KEY_SEQUENCE_NAME,
       JT.KEY_PATH                   KEY_PATH,
       JT.PARTITION_COLUMN_NAME      PARTITION_COLUMN_NAME,
       JT.PARTITION_COLUMN_TYPE      PARTITION_COLUMN_TYPE,
       JT.PARTITION_COLUMN_LEN       PARTITION_COLUMN_LEN,
       JT.PARTITION_PATH             PARTITION_PATH,
       JT.CONTENT_COLUMN_NAME        CONTENT_COLUMN_NAME,
       JT.CONTENT_COLUMN_TYPE        CONTENT_COLUMN_TYPE,
       JT.CONTENT_COLUMN_LEN         CONTENT_COLUMN_LEN,
       JT.CONTENT_VALIDATION         CONTENT_VALIDATION,
       JT.CONTENT_LOB_COMPRESS       CONTENT_LOB_COMPRESS,
       JT.CONTENT_LOB_CACHE          CONTENT_LOB_CACHE,
       JT.CONTENT_LOB_ENCRYPT        CONTENT_LOB_ENCRYPT,
       JT.CONTENT_LOB_TS             CONTENT_LOB_TS,
       JT.LAST_MODIFIED_COLUMN_NAME  LAST_MODIFIED_COLUMN_NAME,
       JT.LAST_MODIFIED_INDEX        LAST_MODIFIED_INDEX,
       JT.VERSION_COLUMN_NAME        VERSION_COLUMN_NAME,
       JT.VERSIONING_METHOD          VERSIONING_METHOD,
       JT.MEDIA_TYPE_COLUMN_NAME     MEDIA_TYPE_COLUMN_NAME,
       JT.CREATION_TIME_COLUMN_NAME  CREATION_TIME_COLUMN_NAME,
       JT.READ_ONLY                  READ_ONLY,
       JT.PRE_PARSED                 PRE_PARSED
  from XDB.JSON$COLLECTION_METADATA MD,
       Json_Table(MD.JSON_DESCRIPTOR, '$' null on error columns
 "SCHEMA_NAME"               varchar2(128) path '$.schemaName',
 "TABLE_NAME"                varchar2(128) path '$.tableName',
 "VIEW_NAME"                 varchar2(128) path '$.viewName',
 "PACKAGE_NAME"              varchar2(128) path '$.packageName',
 "TABLESPACE_NAME"           varchar2(128) path '$.tablespace',
 "STORAGE_INIT_SIZE"         number        path '$.storage.size',
 "STORAGE_INCREASE_PCT"      number        path '$.storage.increase',
 "KEY_COLUMN_NAME"           varchar2(128) path '$.keyColumn.name',
 "KEY_COLUMN_TYPE"           varchar2(10)  path '$.keyColumn.sqlType',
 "KEY_COLUMN_LEN"            number        path '$.keyColumn.maxLength',
 "KEY_ASSIGNMENT_METHOD"     varchar2(10)  path '$.keyColumn.assignmentMethod',
 "KEY_SEQUENCE_NAME"         varchar2(128) path '$.keyColumn.sequenceName',
 "KEY_PATH"                  varchar2(255) path '$.keyColumn.path',
 "PARTITION_COLUMN_NAME"     varchar2(128) path '$.partitionColumn.name',
 "PARTITION_COLUMN_TYPE"     varchar2(10)  path '$.partitionColumn.sqlType',
 "PARTITION_COLUMN_LEN"      number        path '$.partitionColumn.maxLength',
 "PARTITION_PATH"            varchar2(255) path '$.partitionColumn.path',
 "CONTENT_COLUMN_NAME"       varchar2(128) path '$.contentColumn.name',
 "CONTENT_COLUMN_TYPE"       varchar2(10)  path '$.contentColumn.sqlType',
 "CONTENT_COLUMN_LEN"        number        path '$.contentColumn.maxLength',
 "CONTENT_VALIDATION"        varchar2(10)  path '$.contentColumn.validation',
 "CONTENT_LOB_COMPRESS"      varchar2(10)  path '$.contentColumn.compress',
 "CONTENT_LOB_CACHE"         varchar2(10)  path '$.contentColumn.cache',
 "CONTENT_LOB_ENCRYPT"       varchar2(10)  path '$.contentColumn.encrypt',
 "CONTENT_LOB_TS"            varchar2(128) path '$.contentColumn.tablespace',
 "LAST_MODIFIED_COLUMN_NAME" varchar2(128) path '$.lastModifiedColumn.name',
 "LAST_MODIFIED_INDEX"       varchar2(128) path '$.lastModifiedColumn.index',
 "VERSION_COLUMN_NAME"       varchar2(128) path '$.versionColumn.name',
 "VERSIONING_METHOD"         varchar2(10)  path '$.versionColumn.method',
 "MEDIA_TYPE_COLUMN_NAME"    varchar2(128) path '$.mediaTypeColumn.name',
 "CREATION_TIME_COLUMN_NAME" varchar2(128) path '$.creationTimeColumn.name',
 "READ_ONLY"                 varchar2(10)  path '$.readOnly',
 "PRE_PARSED"                varchar2(10)  path '$.preParsed'
                 ) JT;

Rem
Rem This view may be granted to public
Rem
create or replace view XDB.JSON$USER_COLLECTION_METADATA
as
select URI_NAME,
       OBJECT_TYPE, OBJECT_SCHEMA, OBJECT_NAME,
       CREATED_ON, CREATE_MODE, JSON_DESCRIPTOR
  from XDB.JSON$COLLECTION_METADATA
 where OWNER = SYS_CONTEXT('USERENV','CURRENT_USER');

grant read on XDB.JSON$USER_COLLECTION_METADATA to SODA_APP;

create public synonym USER_SODA_COLLECTIONS for XDB.JSON$USER_COLLECTION_METADATA; 


@?/rdbms/admin/sqlsessend.sql
