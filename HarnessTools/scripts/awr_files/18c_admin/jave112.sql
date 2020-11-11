Rem
Rem $Header: rdbms/admin/jave112.sql /main/4 2017/04/04 09:12:45 raeburns Exp $
Rem
Rem jave112.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      jave112.sql - downgrade catJAVa to 11.2
Rem
Rem    DESCRIPTION
Rem      Downgrade CATJAVA from current release to 11.2
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/jave112.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/jave112.sql
Rem    SQL_PHASE:DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/javdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns      03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    cdilling      07/28/14 - invoke jave121.sql
Rem    cdilling      06/27/12 - add drop java classes
Rem    cdilling      05/13/11 - Add support for 12.1
Rem    cdilling      02/06/09 - Created
Rem

Rem Downgrade CATJAVA from 12.2 to 12.1
@@jave121

execute dbms_registry.downgrading('CATJAVA');

Rem Add CATJAVA downgrade actions here
 
Rem drop AQ jar files 
execute sys.dbms_java.dropjava('-s rdbms/jlib/aqapi.jar');

execute dbms_registry.downgraded('CATJAVA','11.2.0');


