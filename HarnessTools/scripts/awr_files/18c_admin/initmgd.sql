Rem
Rem $Header: rdbms/admin/initmgd.sql /main/5 2017/05/28 22:46:06 stanaya Exp $
Rem
Rem initmgd.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      initmgd.sql - load mgd java components
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/initmgd.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/initmgd.sql
Rem    SQL_PHASE: INITMGD
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       03/02/16 - add call to sqlsessstart and sqlsessend
Rem    hgong       07/12/06 - use upper case sys user 
Rem    hgong       06/12/06 - Created
Rem

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessstart.sql
Rem ********************************************************************

call sys.dbms_java.loadjava('-resolve -force -synonym -schema MGDSYS -grant PUBLIC rdbms/jlib/mgd_idcode.jar');

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessend.sql
Rem ********************************************************************

