Rem
Rem $Header: rdbms/admin/catemxt.sql /main/3 2014/02/20 12:45:51 surman Exp $
Rem
Rem catemxt.sql
Rem
Rem Copyright (c) 2011, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catemxt.sql - catalog script for EM Express
Rem
Rem    DESCRIPTION
Rem      Creates the base tables for EM Express. See catemxv for view defs.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catemxt.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catemxt.sql
Rem SQL_PHASE: CATEMXT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptyps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    yxie        03/06/11 - Define schema for EM Express
Rem    yxie        03/06/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-------------------------------------------------------------------------------
--                              table definitions                            --
-------------------------------------------------------------------------------

---------------------------------- wri$_emx_files -----------------------------
-- NAME:
--     wri$_emx_files
--
-- DESCRIPTION: 
--     This table stores the files managed by EM Express.  
--
--     FIXME should files be stored as CLOBs?
--
-- PRIMARY KEY:
--     The primary key is id    
-------------------------------------------------------------------------------
CREATE TABLE wri$_emx_files
(
  id           NUMBER         NOT NULL,                /* unique id for file */
  name         VARCHAR2(500)  NOT NULL,       /* file name, without the path */
  description  VARCHAR2(256),                            /* file description */
  data         CLOB,                              /* non binary file content */
  binary_data  BLOB,                                  /* binary file content */
  properties   NUMBER,      /* file properties, first bit: if file is public */
  constraint wri$_emx_files_pk primary key(id)
  using INDEX tablespace SYSAUX
)
tablespace SYSAUX
/

create unique index wri$_emx_files_idx_01 
on wri$_emx_files(name)
tablespace sysaux
/

-------------------------------------------------------------------------------
--                             sequence definitions                           -
-------------------------------------------------------------------------------
------------------------------ WRI$_EMX_FILE_ID_SEQ ---------------------------
-- NAME:
--     WRI$_EMX_FILE_ID_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for WRI$_EMX_FILES
-------------------------------------------------------------------------------
CREATE SEQUENCE wri$_emx_file_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  CACHE 100
  NOCYCLE
/

@?/rdbms/admin/sqlsessend.sql
