Rem
Rem $Header: rdbms/admin/execsmb.sql /main/2 2016/01/29 10:27:57 jftorres Exp $
Rem
Rem execsmb.sql
Rem
Rem Copyright (c) 2015, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execsmb.sql - EXECute SQL Management Base packages
Rem
Rem    DESCRIPTION
Rem      Initializes the dbms_smb and dbms_spm packages.
Rem
Rem    NOTES
Rem    
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/execsmb.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/execsmb.sql
Rem    SQL_PHASE: EXECSMB 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpexec.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jftorres    01/19/16 - #(13073335): rename init_smb_config() to
Rem                           init_smb()
Rem    jftorres    02/02/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

exec dbms_smb_internal.init_smb();

@?/rdbms/admin/sqlsessend.sql
