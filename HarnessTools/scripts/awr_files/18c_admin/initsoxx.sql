Rem
Rem $Header: rdbms/admin/initsoxx.sql /main/4 2017/04/27 17:09:44 raeburns Exp $
Rem
Rem initsoxx.sql
Rem
Rem Copyright (c) 1999, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      initsoxx.sql - loads sql, objects, extensibility and xml related java
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      script must be run as SYS
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/initsoxx.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/initsoxx.sql
Rem    SQL_PHASE:  INITSOXX
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catjava.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/12/17 - Bug 25790192; add SQL_METADATA
Rem    ayoaz       08/21/03 - change to pl/sql block
Rem    rshaikh     11/01/99 - script to load ODCI and CartridgeServices jars
Rem    rshaikh     11/01/99 - Created
Rem

@?/rdbms/admin/sqlsessstart.sql

begin
 sys.dbms_java.loadjava('-f -r -v -s -g public rdbms/jlib/CartridgeServices.jar rdbms/jlib/ODCI.jar'); 
end;
/ 

@?/rdbms/admin/sqlsessend.sql

