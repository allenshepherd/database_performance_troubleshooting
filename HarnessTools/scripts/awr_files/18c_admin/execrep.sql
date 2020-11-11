Rem
Rem $Header: rdbms/admin/execrep.sql /main/5 2014/11/27 16:09:01 jorgrive Exp $
Rem
Rem execrep.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execrep.sql - EXEC REPlication
Rem
Rem    DESCRIPTION
Rem      PL/SQL blocks for replication executed after package bodies 
Rem      are loaded.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/execrep.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/execrep.sql
Rem SQL_PHASE: EXECREP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jorgrive    10/20/14 - Desupport Advanced Replication
Rem    jorgrive    02/21/14 - Bug 9774957
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    elu         10/23/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Objects for deferred RPC and Materialized Views
Rem Dependencies on queues and jobs; required for Replication
@@catdefer

Rem Recompile views, synonyms and packages that were dependent
Rem on the dummy def$_aqcall and def$_aqerror tables (which were
Rem dropped and recreated in catdefer.sql).

alter package DBMS_SNAPSHOT  compile
/

Rem Added to support dbms_repcat.wait_master_log
GRANT EXECUTE ON dbms_alert TO system
/

@?/rdbms/admin/sqlsessend.sql
