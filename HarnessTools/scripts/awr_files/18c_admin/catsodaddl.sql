Rem
Rem $Header: rdbms/admin/catsodaddl.sql /main/6 2017/03/10 10:40:08 bhammers Exp $
Rem
Rem catsodaddl.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catsodaddl.sql - SODA collections TABle creation
Rem
Rem    DESCRIPTION
Rem      Creates the table that stores collection metadata
Rem
Rem    NOTES
Rem      The table is striped by OWNER (which is always USER schema).
Rem
Rem      Columns:
Rem        URI_NAME        - visible name of collection (must be Unicode)
Rem        OWNER           - user that owns this collection
Rem        OBJECT_TYPE     - denormalized from the descriptor
Rem                          One of: TABLE, VIEW, PACKAGE
Rem        OBJECT_SCHEMA   - denormalized from the descriptor
Rem                          schema where target table/view/package exists
Rem                          (may be different from OWNER)
Rem        OBJECT_NAME     - denormalized from the descriptor
Rem                          typically a table or view name
Rem        CREATED_ON      - date/time collection was created
Rem        CREATE_MODE     - Create collection mode - 'DDL' or 'MAP'
Rem        JSON_DESCRIPTOR - descriptor
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catsodaddl.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catsodaddl.sql
Rem    SQL_PHASE: CATSODADDL
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catsodacoll.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bhammers    03/09/17 - bug 25684917
Rem    prthiaga    06/21/16 - Bug 23625161: USER -> CURRENT_USER
Rem    prthiaga    11/05/15 - RTI 18730635: Make script re-runnable
Rem    prthiaga    07/29/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

DECLARE 
  stmt VARCHAR2(4000);
BEGIN

  stmt := 'create table XDB.JSON$COLLECTION_METADATA(
           URI_NAME            nvarchar2(255)                      not null,
           OWNER               varchar2(128)  
                 default SYS_CONTEXT(''USERENV'',''CURRENT_USER'') not null,
           OBJECT_TYPE         varchar2(10)   default ''TABLE''    not null,
           OBJECT_SCHEMA       varchar2(128)  
               default SYS_CONTEXT(''USERENV'',''CURRENT_SCHEMA'') not null,
           OBJECT_NAME         varchar2(128)                       not null,
           CREATED_ON          timestamp      default 
                                    sys_extract_utc(SYSTIMESTAMP)  not null,
           CREATE_MODE         varchar2(10)   default ''MAP''      not null,
           JSON_DESCRIPTOR     varchar2(4000)                      not null,
             constraint JSON$COLLECTION_METADATA_PK 
               primary key (OWNER, URI_NAME), 
             constraint JSON$COLLECTION_METADATA_C1 
               check (OBJECT_TYPE in (''TABLE'',''VIEW'',''PACKAGE'')),
             constraint JSON$COLLECTION_METADATA_C2
               check (CREATE_MODE in (''DDL'',''MAP'')))';

  execute immediate stmt;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -955) THEN NULL; --table already created
      ELSE RAISE;
      END IF;
END; 
/   

--
-- This constraint on the descriptor may not work on older databases
-- so it's separated from the table creation above.
--
DECLARE
  stmt VARCHAR2(4000);
BEGIN

  stmt := 'alter table XDB.JSON$COLLECTION_METADATA 
           add constraint JSON$COLLECTION_METADATA_CJ 
           check (JSON_DESCRIPTOR is json)';

  execute immediate stmt;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -2264, -40664 ) THEN NULL; 
           --  2264: constraint with that name already exists
           -- 40664: the column already has an IS JSON constraint
      ELSE RAISE;
      END IF;
END; 
/   


create role SODA_APP;
grant SODA_APP to RESOURCE;
grant SODA_APP to XDB with admin option;

@?/rdbms/admin/sqlsessend.sql
