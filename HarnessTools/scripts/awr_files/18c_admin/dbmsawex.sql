--
-- $Header: oraolap/src/sql/dbmsawex.sql /main/15 2017/03/29 10:42:40 jcarey Exp $
--
-- dbmsawex.sql
--
-- Copyright (c) 2004, 2017, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--      dbmsawex.sql
--
--    DESCRIPTION
--      Provides the DBMS_AW_EXP package
--
--    NOTES
--      None
--
--
-- BEGIN SQL_FILE_METADATA
-- SQL_SOURCE_FILE: olap/src/sql/dbmsawex.sql
-- SQL_SHIPPED_FILE: rdbms/admin/dbmsawex.sql
-- SQL_PHASE: DBMSAWEX
-- SQL_STARTUP_MODE: NORMAL
-- SQL_IGNORABLE_ERRORS: NONE
-- SQL_CALLING_FILE: rdbms/admin/olappl.sql
-- END SQL_FILE_METADATA
--
--    MODIFIED   (MM/DD/YY)
--      jcarey    03/13/17 - Bug 25254484 - aw lockdown
--      cchiappa  07/18/16 - Bug#24309417
--      cchiappa  03/14/13 - Set _ORACLE_SCRIPT
--      cchiappa  07/27/12 - V12 support
--      cchiappa  07/18/12 - Export transporting
--      surman    03/27/12 - 13615447: Add SQL patching tags
--      esoyleme  03/11/09 - transportable tablespaces with MVs
--      hyechung  06/27/07 - schema_callout
--      esoyleme  07/20/04 - callout-based transport
--      cchiappa  07/13/04 - Move DBMS_AW_EXP to dbmsawex.sql (again) 
--      cchiappa  07/02/04 - Backout split
--      cchiappa  06/30/04 - Move DBMS_AW_EXP here
--      cchiappa  04/06/04 - Created dummy file
--

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_aw_exp AUTHID CURRENT_USER AS

  EIF_LOB_SIZE_OUT_OF_RANGE EXCEPTION;
  INVALID_AW_VERSION CONSTANT NUMBER := -20004;
  CROSS_PLATFORM_TRANSPORT CONSTANT NUMBER := -20005;
  AW_TOO_MANY_OBJECTS CONSTANT NUMBER := -20006;

  PROCEDURE alter_lob_size(  newsize     IN   NUMBER);

  PROCEDURE import_begin120( schema      IN   VARCHAR2,
                             name        IN   VARCHAR2);
  PROCEDURE import_chunk120( amt         IN   BINARY_INTEGER,
                             stream      IN   VARCHAR2);
  PROCEDURE import_finish120(schema      IN   VARCHAR2,
                             name        IN   VARCHAR2);
  PROCEDURE import_begin112( schema      IN   VARCHAR2,
                             name        IN   VARCHAR2);
  PROCEDURE import_chunk112( amt         IN   BINARY_INTEGER,
                             stream      IN   VARCHAR2);
  PROCEDURE import_finish112(schema      IN   VARCHAR2,
                             name        IN   VARCHAR2);
  PROCEDURE import_begin100( schema      IN   VARCHAR2,
                             name        IN   VARCHAR2);
  PROCEDURE import_chunk100( amt         IN   BINARY_INTEGER,
                             stream      IN   VARCHAR2);
  PROCEDURE import_finish100(schema      IN   VARCHAR2,
                             name        IN   VARCHAR2);
  PROCEDURE import_begin92(  schema      IN   VARCHAR2,
                             name        IN   VARCHAR2);
  PROCEDURE import_chunk92(  amt         IN   BINARY_INTEGER,
                             stream      IN   VARCHAR2);
  PROCEDURE import_finish92( schema      IN   VARCHAR2,
                             name        IN   VARCHAR2);

  -- Transportable tablespace support
  PROCEDURE trans_begin102(  awname      IN   VARCHAR2,
                             schema      IN   VARCHAR2,
                             namespace   IN   PLS_INTEGER,
                             type        IN   PLS_INTEGER);

  PROCEDURE trans_chunk102(  amt         IN     BINARY_INTEGER,
                             stream      IN     VARCHAR2);

  PROCEDURE trans_finish102( awname      IN   VARCHAR2,
                             schema      IN   VARCHAR2,
                             namespace   IN   PLS_INTEGER,
                             type        IN   PLS_INTEGER);

  PROCEDURE trans_finish112( awname      IN   VARCHAR2,
                             schema      IN   VARCHAR2,
                             namespace   IN   PLS_INTEGER,
                             type        IN   PLS_INTEGER,
                             prepost     IN  PLS_INTEGER);

  PROCEDURE trans_finish120( awname      IN   VARCHAR2,
                             schema      IN   VARCHAR2,
                             namespace   IN   PLS_INTEGER,
                             type        IN   PLS_INTEGER,
                             prepost     IN  PLS_INTEGER);

  PROCEDURE trans_finish122( awname      IN   VARCHAR2,
                             schema      IN   VARCHAR2,
                             namespace   IN   PLS_INTEGER,
                             type        IN   PLS_INTEGER,
                             prepost     IN  PLS_INTEGER);

  FUNCTION  schema_info_exp( schema      IN   VARCHAR2,
                             prepost     IN   PLS_INTEGER,
                             isdba       IN   PLS_INTEGER,
                             version     IN   VARCHAR2,
                             new_block   OUT  PLS_INTEGER)
     RETURN VARCHAR2;

  PROCEDURE schema_callout(  schema      IN   VARCHAR2,
                             prepost     IN   PLS_INTEGER,
                             isdba       IN   PLS_INTEGER,
                             version     IN   VARCHAR2);

  PROCEDURE import_callout120(schema     IN   VARCHAR2);
  PROCEDURE import_callout112(schema     IN   VARCHAR2);

  PROCEDURE import_table_callout120(
                              schema     IN   VARCHAR2,
                              tabname    IN   VARCHAR2,
                              preport    IN   PLS_INTEGER);

  FUNCTION  instance_extended_info_exp(
                              name       IN   VARCHAR2,
                              schema     IN   VARCHAR2,
                              namespace  IN   PLS_INTEGER,
                              type       IN   PLS_INTEGER,
                              prepost    IN   PLS_INTEGER,
                              exp_user   IN   VARCHAR2,
                              isdba      IN   PLS_INTEGER,
                              version    IN   VARCHAR2,
                              new_block  OUT  PLS_INTEGER)
     RETURN VARCHAR2;

  PROCEDURE instance_callout_imp(
                              obj_name   IN   VARCHAR2,
                              obj_schema IN   VARCHAR2,
                              obj_type   IN   VARCHAR2,
                              prepost    IN   PLS_INTEGER,
                              action     OUT  VARCHAR2,
                              alt_name   OUT  VARCHAR2);

  TYPE rawvec_t      IS TABLE OF      RAW(31744);
  TYPE varchar2vec_t IS TABLE OF VARCHAR2(31744);
  FUNCTION  lob_write(       wlob IN OUT NOCOPY BLOB,
                             pos  IN            BINARY_INTEGER,
                             data IN            rawvec_t)
     RETURN BINARY_INTEGER;

  FUNCTION  lob_writeappend( wlob IN OUT NOCOPY BLOB,
                             data IN            rawvec_t)
     RETURN BINARY_INTEGER;

  FUNCTION  lob_write(       wlob IN OUT NOCOPY CLOB CHARACTER SET ANY_CS,
                             pos  IN            BINARY_INTEGER,
                             data IN            varchar2vec_t)
     RETURN BINARY_INTEGER;

  FUNCTION  lob_writeappend( wlob IN OUT NOCOPY CLOB CHARACTER SET ANY_CS,
                             data IN            varchar2vec_t)
     RETURN BINARY_INTEGER;

  -- Exported for DBMS_CUBE_EXP
  FUNCTION transporting
     RETURN BOOLEAN;

END dbms_aw_exp;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_aw_exp FOR sys.dbms_aw_exp
/
GRANT EXECUTE ON dbms_aw_exp TO PUBLIC
/

@@?/rdbms/admin/sqlsessend.sql
