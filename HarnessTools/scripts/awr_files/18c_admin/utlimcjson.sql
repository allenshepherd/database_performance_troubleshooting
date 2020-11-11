Rem
Rem $Header: rdbms/admin/utlimcjson.sql /main/2 2017/10/05 19:37:00 sayanala Exp $
Rem
Rem utlimcjson.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlimcjson.sql
Rem
Rem    DESCRIPTION
Rem      For all the tables containing json columns (IS JSON check constraint) 
Rem      that are  created without setting compatiblty=12.2 or 
Rem      max_string_size=extended, this script will upgrade all 
Rem      of these json columns in all these tables  to prepare to take advantage 
Rem      of in memory json processing that is new in 12.2 release.
Rem
Rem    NOTES
Rem      The database server must set compatible=12.2.0.0 and
Rem      max_string_size=extended in order to run this script.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/utlimcjson.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlimcjson.sql
Rem    SQL_PHASE: UTILITY 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sayanala    09/17/17 - To handle 18.0.0.0 version change
Rem    yinlu       03/01/16 - Created
Rem

@?/rdbms/admin/sqlsessstart.sql

Rem Exit immediately if Any failure in this script
WHENEVER SQLERROR EXIT;

DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01722: invalid number"
   error if the database does not have compatible >= 12.2.0.

   Set compatible >= 12.2.0 and retry.
#######################################################################
#######################################################################
#

DECLARE
  comp     VARCHAR2(30);
  firstdot NUMBER;
  secdot   NUMBER;
  major    NUMBER;
  minor    NUMBER;
  dummy    NUMBER;
BEGIN
  -- Get the current compatible value   
  SELECT value INTO comp
  FROM v$parameter
  WHERE lower(name) = 'compatible';
    
  firstdot := INSTR(comp, '.');
  secdot := INSTR(comp, '.', 1, 2);

  major := TO_NUMBER(SUBSTR(comp, 1, (firstdot-1)));
  minor := TO_NUMBER(SUBSTR(comp, (firstdot+1), (secdot-firstdot)));
  if (major < 12 or (major=12 and minor<2)) then
    SELECT TO_NUMBER('COMPATIBLE_12.2.0_REQUIRED') INTO dummy FROM DUAL;
  end if;
END;
/

DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01722: invalid number"
   error if the database does not have max_string_size = extended.

   Set max_string_size = extended and retry.
#######################################################################
#######################################################################
#

DECLARE
  dummy number;
BEGIN
  SELECT CASE WHEN upper(value) <> 'EXTENDED'
              THEN TO_NUMBER('MAXSTRINGSIZE_EXTENDED_REQUIRED')
              ELSE NULL
              END INTO dummy
  FROM v$parameter WHERE lower(name) = 'max_string_size';
END;
/

DOC
#######################################################################
#######################################################################
  For all the tables containing json columns (IS JSON check constraint) 
  that are created without setting compatiblty=12.2 or 
  max_string_size=extended, this following statement upgrades all of 
  those JSON columns in all those tables to prepare to take advantage 
  of in memory JSON processing that is new in 12.2 release.
#######################################################################
#######################################################################
#

--

create or replace PROCEDURE jsn$pJColInM(owner VARCHAR2, tabName VARCHAR2,
                                         jcolName VARCHAR2, format VARCHAR2)
IS
  EXTERNAL
  NAME "DBMS_JSON_PREPJSONCOLINMEMORY"
  LANGUAGE C
  LIBRARY xdb.DBMS_JSON_LIB
  WITH CONTEXT
  PARAMETERS (context,
              owner                         STRING,
              owner                  INDICATOR sb4,
              owner                     LENGTH sb4,
              tabName                       STRING,
              tabName                INDICATOR sb4,
              tabName                   LENGTH sb4,
              jcolName                      STRING,
              jcolName               INDICATOR sb4,
              jcolName                  LENGTH sb4,
              format                        STRING,
              format                 INDICATOR sb4,
              format                    LENGTH sb4
              );
/

DECLARE
v_tname VARCHAR2(130);
v_cname VARCHAR2(130);
v_format VARCHAR2(130);
v_owner VARCHAR2(130);
CURSOR c1 IS
  select OWNER, TABLE_NAME, COLUMN_NAME, FORMAT
  FROM  DBA_JSON_COLUMNS;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO v_owner, v_tname, v_cname, v_format;
    EXIT WHEN c1%NOTFOUND;
    -- C callout
    jsn$pJColInM(v_owner, v_tname, v_cname, v_format);
  END LOOP;
  CLOSE c1;
  return;
END;
/

Rem Continue even if there are SQL errors 
WHENEVER SQLERROR CONTINUE;

@?/rdbms/admin/sqlsessend.sql
