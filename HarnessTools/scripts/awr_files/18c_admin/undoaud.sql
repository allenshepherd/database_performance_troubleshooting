Rem
Rem $Header: rdbms/admin/undoaud.sql /main/2 2017/05/28 22:46:11 stanaya Exp $
Rem
Rem undoaud.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      undoaud.sql - undo 11g default auditing changes 
Rem
Rem    DESCRIPTION
Rem      Undo the audit-related secure configuration changes for 11g. This
Rem      reverts to the 10gR2 default settings, which have auditing disabled
Rem      by default, and no audit options set. Called by DBCA if requested
Rem      by user for compatibility or performance reasons. Not intended to be
Rem      used during upgrade, since any customer audit options will be 
Rem      removed.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/undoaud.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/undoaud.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    nlewis      07/11/06 - add comments 
Rem    asurpur     06/16/06 - audit changes for sec config 
Rem    asurpur     06/16/06 - audit changes for sec config 
Rem    asurpur     06/16/06 - Created
Rem


-- Turn off auditing and auditing options

noaudit all;

noaudit all privileges;

noaudit exempt access policy;

-- Can use the following to check that all audit options are indeed off:

-- select * from dba_stmt_audit_opts;

-- select * from dba_priv_audit_opts;
