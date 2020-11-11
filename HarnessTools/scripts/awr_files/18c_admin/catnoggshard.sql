Rem
Rem $Header: rdbms/admin/catnoggshard.sql /main/1 2015/04/14 15:21:49 jorgrive Exp $
Rem
Rem catnoggshard.sql
Rem
Rem Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      catnoggshard.sql - NO GGSHARD
Rem
Rem    DESCRIPTION
Rem      Removes GGSYS schema and role 
Rem
Rem    NOTES
Rem      .
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catnoggshard.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnoggshard.sql 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jorgrive    03/25/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-------------------------------------------------------------------------------
-- DROP GGSYS user
-------------------------------------------------------------------------------
BEGIN
EXECUTE IMMEDIATE 'DROP USER ggsys cascade';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1918 THEN NULL;
       -- suppress error for non-existent user
  ELSE raise;
  END IF;
END;
/

-------------------------------------------------------------------------------
-- DROP GGSYS_ROLE
-------------------------------------------------------------------------------
BEGIN
EXECUTE IMMEDIATE 'DROP ROLE ggsys_role';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1919 THEN NULL;
       -- suppress error for non-existent role
  ELSE raise;
  END IF;
END;
/

@?/rdbms/admin/sqlsessend.sql
