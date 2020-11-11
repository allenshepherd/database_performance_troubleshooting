Rem
Rem $Header: rdbms/admin/rmaqjms.sql /main/2 2017/05/28 22:46:08 stanaya Exp $
Rem
Rem rmaqjms.sql
Rem
Rem Copyright (c) 2000, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      rmaqjms.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/rmaqjms.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/rmaqjms.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    bnainani    05/30/00 - Script to remove jms classes during downgrade
Rem    bnainani    05/30/00 - Created
Rem
call sys.dbms_java.dropjava('-s rdbms/jlib/aqapi.jar');
call sys.dbms_java.dropjava('-s rdbms/jlib/jmscommon.jar');


