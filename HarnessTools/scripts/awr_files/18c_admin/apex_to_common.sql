Rem
Rem $Header: rdbms/admin/apex_to_common.sql /main/7 2015/12/16 18:05:28 pyam Exp $
Rem
Rem apex_to_common.sql
Rem
Rem Copyright (c) 2012, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      apex_to_common.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem  BEGIN SQL_FILE_METADATA 
Rem  SQL_SOURCE_FILE: rdbms/admin/apex_to_common.sql 
Rem  SQL_SHIPPED_FILE: rdbms/admin/apex_to_common.sql
Rem  SQL_PHASE: APEX_TO_COMMON
Rem  SQL_STARTUP_MODE: NORMAL 
Rem  SQL_IGNORABLE_ERRORS: NONE 
Rem  SQL_CALLING_FILE: NONE
Rem  END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pyam        12/13/15 - LRG 18533922: pass argument to loc_to_common3.sql
Rem    surman      01/08/15 - 19475031: Update SQL metadata
Rem    pyam        10/22/14 - put common code in loc_to_common*.sql
Rem    gravipat    06/03/14 - 18879013: use dbms_pdb.noncdb_to_pdb instead of
Rem                           setting the _noncdb_to_pdb parameter
Rem    thbaby      08/29/13 - 14515351: add INT$ views for sharing=object
Rem    sankejai    03/26/13 - 16530655: do not update status in container$
Rem    pyam        11/15/12 - Converts Local APEX to Common APEX in a PDB.
Rem    pyam        11/15/12 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

VARIABLE pdbname VARCHAR2(128)
WHENEVER SQLERROR EXIT;

BEGIN
  SELECT sys_context('USERENV', 'CDB_NAME') 
    INTO :cdbname
    FROM dual
    WHERE sys_context('USERENV', 'CDB_NAME') is not null;
  SELECT sys_context('USERENV', 'CON_NAME') 
    INTO :pdbname
    FROM dual
    WHERE sys_context('USERENV', 'CON_NAME') <> 'CDB$ROOT';
END;
/

@@?/rdbms/admin/loc_to_common1.sql 3
@@?/rdbms/admin/loc_to_common2.sql 0
@@?/rdbms/admin/loc_to_common3.sql 0
@@?/rdbms/admin/loc_to_common4.sql 4

