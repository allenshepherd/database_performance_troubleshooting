Rem 
Rem $Header: dbmsxfr.sql
Rem
Rem dbmsxfr.sql
Rem 
Rem Copyright (c) 2002, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxfr.sql - DBMS package specification for bfile transfer
Rem
Rem    DESCRIPTION
Rem      This package provides get, put, and copy operations on BFILEs.
Rem
Rem    NOTES
Rem      The procedural option is needed to use this package. This package
Rem      must be created under SYS (connect internal). Operations provided 
Rem      by this package are performed under the current calling user, not
Rem      under the package owner SYS.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxfr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxfr.sql
Rem SQL_PHASE: DBMSXFR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sankejai    12/15/16 - 25192661: overload copy_file with options for ASM
Rem    rpingte     07/20/16 - 24294098: use constant for package variables
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jstamos     12/27/02 - workaround bfile limitation
Rem    jstamos     10/21/02 - add flag to session state
Rem    jstamos     10/08/02 - jstamos_file_transfer
Rem    jstamos     09/09/02 - creation

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_file_transfer AUTHID CURRENT_USER AS

  invalid_parameter EXCEPTION;
    PRAGMA exception_init(invalid_parameter, -31600);
    invalid_parameter_num CONSTANT NUMBER := -31600;

  package_flag CONSTANT BINARY_INTEGER := 0;

  PROCEDURE get_file(source_directory_object      IN VARCHAR2,
                     source_file_name             IN VARCHAR2,
                     source_database              IN VARCHAR2,
                     destination_directory_object IN VARCHAR2,
                     destination_file_name        IN VARCHAR2);
-- The procedure get_file contacts a remote database to read a remote
-- file and then creates a copy in the local file system.  The parameter
-- source_database is a database link to the remote database.  The source
-- file must exist at the source database with the name given by
-- source_file_name in the directory associated with source directory object.
-- The new copy has a name given by destination_file_name in the directory
-- associated with destination directory object.  The destination file
-- must not already exist at the local database.  If the destination file
-- already exists, get_file raises an exception.  The destination file is
-- not closed until the operation completes successfully.  The current user
-- needs write privileges at the local database on the
-- destination directory object.  The connected user at the source database,
-- which depends on the database link details, needs read privileges at the
-- source database on the  directory object.  All parameters to
-- get_file must be non-NULL.
-- Directory objects are automatically converted to upper case unless
-- protected by double quotes.  File names are not converted to upper case.
-- The file size must be a multiple of 512 bytes and must be no more than
-- 2 TB.  Transferring the file is not transactional.  The file is
-- treated as a binary file and no character set conversion is done.  For
-- long transfers, progress is displayed in the v$session_longops view.

  PROCEDURE put_file(source_directory_object      IN VARCHAR2,
                     source_file_name             IN VARCHAR2,
                     destination_directory_object IN VARCHAR2,
                     destination_file_name        IN VARCHAR2,
                     destination_database         IN VARCHAR2);
-- The procedure put_file reads a local file and contacts a remote
-- database to create a copy in a remote file system.  The parameter
-- destination_database is a database link to the remote database.  The
-- local file must exist with the name given by source_file_name in the
-- directory associated with source directory object.  The new copy has a
-- name given by destination_file_name in the directory associated with
-- destination_file_object.  The destination file must not already exist
-- at the destination database.  If the destination file already exists,
-- put_file raises an exception.  The destination file is not closed until the
-- operation completes successfully.  The current user needs read privileges
-- at the local database on the source directory object.  The connected user
-- at the destination database, which depends on the database link details,
-- needs write privileges at the destination database on the
-- destination directory object.  All parameters to put_file must be non-NULL.
-- Directory objects are automatically converted to upper case unless
-- protected by double quotes.  File names are not converted to upper case.
-- The file size must be a multiple of 512 bytes and must be no more than 2
-- TB.  Transferring the file is not transactional.  The file is treated
-- as a binary file and no character set conversion is done.  For long
-- transfers, progress is displayed in the v$session_longops view.


   PROCEDURE copy_file(source_directory_object      IN VARCHAR2,
                       source_file_name             IN VARCHAR2,
                       destination_directory_object IN VARCHAR2,
                       destination_file_name        IN VARCHAR2);

-- The procedure copy_file reads a local file and creates a copy in the
-- local file system.  The source file must exist with the name given by
-- source_file_name in the directory associated with source directory object.
-- The new copy has a name given by destination_file_name in the directory
-- associated with destination directory object.  The destination file must
-- not already exist.  If the destination file already exists, copy_file
-- raises an exception.  The destination file is not closed until the
-- operation completes successfully.  The current user needs read privileges
-- on the source directory object.  The current user needs write privileges on
-- the destination directory object.  All parameters to copy_file must be
-- non-NULL.  Directory objects are automatically converted to upper case
-- unless protected by double quotes.  File names are not converted to upper
-- case.  The file size must be a multiple of 512 bytes and must be
-- no more than 2 TB.  Copying the file is not transactional.  The file
-- is treated as a binary file and no character set conversion is done.
-- For long copy operations, progress is displayed in the
-- v$session_longops view.

   PROCEDURE copy_file(source_directory_object      IN VARCHAR2,
                       source_file_name             IN VARCHAR2,
                       destination_directory_object IN VARCHAR2,
                       destination_file_name        IN VARCHAR2,
                       created_file_name            OUT VARCHAR2,
                       destination_file_tag IN VARCHAR2 DEFAULT 'COPY_FILE');
-- This procedure is similar to copy_file above, with additional handling for
-- ASM files. In case the destination directory object points to an ASM
-- diskgroup and no file name is specified, then a file will be automatically
-- created in ASM and then path of the created file will be returned in
-- created_file_name argument. The destination_file_tag is a hint for the
-- file name alias to use in ASM when generated the name for the destination
-- file.

END dbms_file_transfer;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_file_transfer FOR dbms_file_transfer
/

GRANT EXECUTE ON dbms_file_transfer TO execute_catalog_role
/

@?/rdbms/admin/sqlsessend.sql
