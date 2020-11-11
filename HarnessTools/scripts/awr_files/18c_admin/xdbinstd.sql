Rem
Rem $Header: rdbms/admin/xdbinstd.sql /main/5 2014/02/20 12:45:45 surman Exp $
Rem
Rem xdbinstd.sql
Rem
Rem Copyright (c) 2005, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbinstd.sql - Execute all XDB Digest Authentication Setup here
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/xdbinstd.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/xdbinstd.sql
Rem SQL_PHASE: XDBINSTD
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         12/01/12 - createnoncekey is moved back to dbms_xdb_amdin
Rem    badeoti     03/19/09 - dbms_xdb_admin.createnoncekey moved to dbms_xdbz
Rem    petam       01/19/05 - create table to store nonce key 
Rem    petam       01/19/05 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE TABLE XDB.XDB$NONCEKEY(nonceKey CHAR(32));

exec dbms_xdb_admin.CreateNonceKey()

@?/rdbms/admin/sqlsessend.sql
