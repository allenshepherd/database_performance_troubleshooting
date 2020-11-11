Rem
Rem $Header: rdbms/admin/dbmsxreg.sql /main/5 2014/02/20 12:46:25 surman Exp $
Rem
Rem dbmsxreg.sql
Rem
Rem Copyright (c) 2002, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxreg.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Package definiton of the registry package.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxreg.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxreg.sql
Rem SQL_PHASE: DBMSXREG
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    badeoti     04/08/08 - add object validation
Rem    pnath       10/25/04 - Make SYS the owner of DBMS_REGXDB package 
Rem    spannala    01/09/02 - Merged spannala_upg
Rem    spannala    01/03/02 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package sys.DBMS_REGXDB authid current_user as
  procedure validatexdb;
  procedure validatexdb_objs;
end dbms_regxdb;
/



@?/rdbms/admin/sqlsessend.sql
