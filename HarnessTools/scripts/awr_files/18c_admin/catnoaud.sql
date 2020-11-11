rem 
rem $Header: rdbms/admin/catnoaud.sql /main/5 2017/05/28 22:46:02 stanaya Exp $ noaudit.sql 
rem 
Rem Copyright (c) 1990, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem NAME
Rem    catnoaud.sql
Rem  FUNCTION
Rem    Drop the auditing catalog views, created by cataudit.sql.
Rem  NOTES
Rem    Must be run while connected to SYS.
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnoaud.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnoaud.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem  MODIFIED
Rem     dsirmuka   12/14/04 - 4055382. catnoaud.sql in sync with cataudit.sql 
Rem     pmothkur   03/23/98 - (526201) drop public synonyms
Rem     glumpkin   10/20/92 - Renamed from noaudit.sql 
Rem     rlim       07/30/91 - added new drop sysnonyms for new auditing
Rem     Chaudhr    03/09/90 - Creation
Rem

Rem -- Tables

drop table AUDIT_ACTIONS
/

Rem -- Views

drop view  ALL_DEF_AUDIT_OPTS
/
drop view  USER_OBJ_AUDIT_OPTS
/
drop view  DBA_OBJ_AUDIT_OPTS
/
drop view  DBA_STMT_AUDIT_OPTS
/
drop view  DBA_PRIV_AUDIT_OPTS
/
drop view  DBA_AUDIT_TRAIL
/
drop view  USER_AUDIT_TRAIL
/
drop view  DBA_AUDIT_SESSION
/
drop view  USER_AUDIT_SESSION
/
drop view  DBA_AUDIT_STATEMENT
/
drop view  USER_AUDIT_STATEMENT
/
drop view  DBA_AUDIT_OBJECT
/
drop view  USER_AUDIT_OBJECT
/
drop view  DBA_AUDIT_EXISTS
/

Rem -- Public Synonyms [for tables and views]

drop public synonym AUDIT_ACTIONS
/
drop public synonym ALL_DEF_AUDIT_OPTS
/
drop public synonym USER_OBJ_AUDIT_OPTS
/
drop public synonym DBA_OBJ_AUDIT_OPTS
/
drop public synonym DBA_STMT_AUDIT_OPTS
/
drop public synonym DBA_PRIV_AUDIT_OPTS
/
drop public synonym DBA_AUDIT_TRAIL
/
drop public synonym USER_AUDIT_TRAIL
/
drop public synonym DBA_AUDIT_SESSION
/
drop public synonym USER_AUDIT_SESSION
/
drop public synonym DBA_AUDIT_STATEMENT
/
drop public synonym USER_AUDIT_STATEMENT
/
drop public synonym DBA_AUDIT_OBJECT
/
drop public synonym USER_AUDIT_OBJECT
/
drop public synonym DBA_AUDIT_EXISTS
/
