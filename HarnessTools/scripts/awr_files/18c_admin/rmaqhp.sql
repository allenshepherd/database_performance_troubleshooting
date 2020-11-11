Rem
Rem $Header: rdbms/admin/rmaqhp.sql /main/3 2017/05/28 22:46:08 stanaya Exp $
Rem
Rem rmaqhp.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      rmaqhp.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/rmaqhp.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/rmaqhp.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    nbhatt         05/01/01 - remove echo
Rem    rbhyrava       03/30/01 - Merged rbhyrava_http_prop_jms
Rem    rbhyrava       02/12/01 - Created
Rem

call sys.dbms_java.dropjava('-s rdbms/jlib/aqprop.jar');
