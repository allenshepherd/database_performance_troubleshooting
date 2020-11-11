Rem
Rem $Header: rdbms/admin/rstrconn.sql /main/2 2017/05/28 22:46:08 stanaya Exp $
Rem
Rem rstrconn.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem    rstrconn.sql - SQL*Plus script to grant all the
Rem                   pre-10gR2 privielges back to CONNECT Role.
Rem
Rem    DESCRIPTION
Rem    This script should be run by a user who is a SYSDBA or has the
Rem    DBA role granted to them.
Rem
Rem    NOTES
Rem    By default, 10gR2 and higher only grants CREATE SESSION
Rem    to CONNECT. This script can be used to restore
Rem    pre-10GR2 CONNECT privileges
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/rstrconn.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/rstrconn.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    pthornto    08/10/04 - pthornto_sqlbsq_connect_deprecate
Rem    pthornto    08/10/04 - Created
Rem

GRANT create session, create table, create view, create synonym,
  create database link, create cluster, create sequence, alter session
  TO CONNECT;
commit;

