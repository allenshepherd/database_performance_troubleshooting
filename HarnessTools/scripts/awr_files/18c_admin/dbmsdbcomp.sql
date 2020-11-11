Rem
Rem $Header: rdbms/admin/dbmsdbcomp.sql /main/2 2015/12/21 13:44:20 yulcho Exp $
Rem
Rem dbmsdbcomp.sql
Rem
Rem Copyright (c) 2014, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsdbcomp.sql - dbcompare.sql - dbcompare package definition
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsdbcomp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsdbcomp.sql
Rem SQL_PHASE: DBMSDBCOMP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yuli        03/10/14 - bug 13922626: Update SQL metadata
Rem    hoyao       04/08/13 - Created

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE DBMS_DBCOMP AUTHID CURRENT_USER IS

-- DE-HEAD     <- tell SED where to cut when generating fixed package

PROCEDURE DBCOMP(datafile IN varchar2
                ,outputfile IN varchar2
                ,block_dump IN boolean := false);

-------------------------------------------------------------------------------
  pragma TIMESTAMP('2013-06-29:18:43:00');
-------------------------------------------------------------------------------



END;

-- CUT_HERE    <- tell sed where to chop off the rest
/

@?/rdbms/admin/sqlsessend.sql

