Rem
Rem $Header: rdbms/admin/jave122.sql /main/2 2017/04/04 09:12:45 raeburns Exp $
Rem
Rem jave122.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      jave122.sql - downgrade catJAVa to 12.2
Rem
Rem    DESCRIPTION
Rem      Downgrade CATJAVA from current release to 12.2
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/jave122.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/jave122.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/javdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    welin       11/16/16 - Created
Rem

Rem Downgrade CATJAVA from next release
--@@javexxx.sql

execute dbms_registry.downgrading('CATJAVA');

Rem Add CATJAVA downgrade actions here

Rem drop AQ jar files
execute sys.dbms_java.dropjava('-s rdbms/jlib/aqapi.jar');

execute dbms_registry.downgraded('CATJAVA','12.2.0');
 
