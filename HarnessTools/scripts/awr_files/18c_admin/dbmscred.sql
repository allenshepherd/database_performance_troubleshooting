Rem
Rem $Header: rdbms/admin/dbmscred.sql /main/6 2017/03/08 10:37:33 sankejai Exp $
Rem
Rem dbmscred.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmscred.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmscred.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmscred.sql
Rem SQL_PHASE: DBMSCRED
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sankejai    02/22/17 - Bug 25600289: add key for credential
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jlingow     09/17/13 - removing supplemental log from create_credential
Rem    paestrad    06/02/12 - Adding the database_role field for credentials
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    paestrad    05/17/11 - Headers for PLSQL package DBMS_CREDENTIAL
Rem    paestrad    05/17/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem  ==========================================================
Rem   dbms_credential: Oracle Credentials PL/SQL interface
Rem  ==========================================================

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100


--  Main Credential package
CREATE OR REPLACE PACKAGE dbms_credential AUTHID CURRENT_USER AS

---Allowed credential logging levels

/*************************************************************
 * Credential Administration Procedures
 *************************************************************
 */

-- Create a new credential. The credential name can be optionally qualified
-- with a schema.
PROCEDURE create_credential(
  credential_name             IN VARCHAR2,
  username                    IN VARCHAR2,
  password                    IN VARCHAR2,
  database_role               IN VARCHAR2 DEFAULT NULL,
  windows_domain              IN VARCHAR2 DEFAULT NULL,
  comments                    IN VARCHAR2 DEFAULT NULL,
  enabled                     IN BOOLEAN  DEFAULT TRUE,
  key                         IN VARCHAR2 DEFAULT NULL
);

-- Drops an existing credential (or a comma separated list of credentials).
-- When force is set to false the credential must not be
-- referred to by any job or extproc.  When force is set to true, 
-- any jobs referring to this credential will be disabled (same behavior 
-- as calling the disable routine on those jobs with the force option).
-- exproc alias libraries that reference the credential will become invalid
PROCEDURE drop_credential(
  credential_name             IN VARCHAR2,
  force                       IN BOOLEAN DEFAULT FALSE);

-- Update credential changes the value of an attribute for a given credential
-- credential attributes which can be updated with the following call:
--
-- username           - VARCHAR2
--                      user to execute the job as.
-- password           - VARCHAR2
--                      password to use to authenticate the user
-- comments           - VARCHAR2
--                      an optional comment. This can describe what the
--                      credential is intended to be used for.
-- windows_domain     - VARCHAR2
--                      Windows domain to use when logging in
-- NOTE-------------------------
-- The ENABLED attribute can not be updated with this call
PROCEDURE update_credential(
  credential_name             IN VARCHAR2,
  attribute                   IN VARCHAR2,
  value                       IN VARCHAR2);

-- Disables an existing Oracle credential
-- If force is set to FALSE, the credential must not be referenced by any
-- object or library. If the credential is referenced by an object, the call
-- returns error
-- If force is set to TRUE, the credential will be disabled either way
PROCEDURE disable_credential(
  credential_name             IN VARCHAR2,
  force                       IN BOOLEAN DEFAULT FALSE);

-- Enables an existing oracle credential
--This will NOT return an error if the credential was enabled already
PROCEDURE enable_credential(
  credential_name             IN VARCHAR2);

END dbms_credential;
/

show errors;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_credential FOR dbms_credential
/

GRANT EXECUTE ON dbms_credential TO PUBLIC
/

@?/rdbms/admin/sqlsessend.sql
