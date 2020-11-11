Rem
Rem $Header: rdbms/admin/execcr.sql /main/5 2014/02/20 12:45:51 surman Exp $
Rem
Rem execcr.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execcr.sql - EXECute Component Registry packages
Rem
Rem    DESCRIPTION
Rem      This scripts executes component registry procedures
Rem      required as part of database creation.
Rem
Rem    NOTES
Rem      Run from catpexec.sql (catproc.sql)
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/execcr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/execcr.sql
Rem SQL_PHASE: EXECCR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    cdilling    07/12/06 - clean up session state 
Rem    rburns      05/06/06 - component registry execute 
Rem    rburns      05/06/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

show error package dbms_registry;
show error procedure dbms_registry.set_session_namespace


Rem
Rem Start with a clean session state for the package
Rem
execute DBMS_SESSION.RESET_PACKAGE; 

show error package dbms_registry;
show error procedure dbms_registry.set_session_namespace


Rem
Rem Set up drop user invocation
Rem

DELETE FROM sys.duc$ WHERE owner='SYS' AND pack='DBMS_REGISTRY_SYS';
INSERT INTO sys.duc$ (owner, pack, proc, operation#, seq, com)
  VALUES ('SYS','DBMS_REGISTRY_SYS','DROP_USER',1, 1,
          'Delete registry entries when schema or invoker is dropped');
COMMIT;

Rem
Rem  Create CONTEXT for Registry Variables and set namespace to SERVER
Rem



CREATE OR REPLACE CONTEXT registry$ctx USING dbms_registry_sys;

show error package dbms_registry;
show error procedure dbms_registry.set_session_namespace


alter session set events '4063 trace name context forever, level 1';

BEGIN
   dbms_registry.set_session_namespace('SERVER');
   dbms_registry_sys.set_registry_context('COMPONENT','RDBMS');
END;
/

alter session set events '4063 trace name context off';

show error package dbms_registry;
show error procedure dbms_registry.set_session_namespace



@?/rdbms/admin/sqlsessend.sql
