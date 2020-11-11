Rem
Rem $Header: rdbms/admin/initjms.sql /st_rdbms_18.0/1 2018/05/01 17:53:47 apfwkr Exp $
Rem
Rem initjms.sql
Rem
Rem Copyright (c) 1999, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      initjms.sql - script used to load AQ/JMS jar files into the database
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/initjms.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/initjms.sql
Rem    SQL_PHASE:  INITJMS
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catjava.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      04/24/18 - Backport pgahukar_bug-27748954 from main
Rem    pgahukar    04/13/18 - Bug 27748954: pass username in uppercase
Rem    raeburns    06/20/17 - RTI 20264012: Correct session start
Rem    raeburns    04/12/17 - Bug 25790192; add SQL_METADATA
Rem    rburns      12/03/01 - remove echo
Rem    rbhyrava    09/07/00 - use one loadjava call
Rem    rbhyrava    04/07/00 - call only once
Rem    bnainani    10/22/99 - script to load JMS/AQ jar files
Rem    bnainani    10/22/99 - Created
Rem

@?/rdbms/admin/sqlsessstart.sql

call sys.dbms_java.loadjava('-v -f -r -s -g PUBLIC rdbms/jlib/jmscommon.jar');
call sys.dbms_java.loadjava('-v -f -r -s -g PUBLIC rdbms/jlib/aqapi.jar');

@?/rdbms/admin/sqlsessend.sql
