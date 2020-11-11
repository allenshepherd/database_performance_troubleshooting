Rem
Rem $Header: rdbms/admin/execrm.sql /main/7 2014/02/20 12:45:40 surman Exp $
Rem
Rem execrm.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execrm.sql - EXECute Resource Manager packages
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/execrm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/execrm.sql
Rem SQL_PHASE: EXECRM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpcnfg.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jomcdon     08/23/11 - project 27116: move to dbms_rmin_sys
Rem    suelee      03/18/09 - Map dataload function to etl_group
Rem    nchoudhu    07/14/08 - XbranchMerge nchoudhu_sage_july_merge117 from
Rem                           st_rdbms_11.1.0
Rem    aksshah     07/03/08 - Add default mapping for dataload functions
Rem    aksshah     03/01/08 - Add default mapping for backup/copy operations
Rem    rburns      05/31/06 - Resource Manager packages 
Rem    rburns      05/31/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


-- install mandatory and system managed (but non-mandatory) objects.
execute dbms_rmin_sys.install;

-- grant system privilege to IMP_FULL_DATABASE and EXP_FULL_DATABASE
execute dbms_resource_manager_privs.grant_system_privilege('IMP_FULL_DATABASE', 'ADMINISTER_RESOURCE_MANAGER', FALSE);
execute dbms_resource_manager_privs.grant_system_privilege('EXP_FULL_DATABASE', 'ADMINISTER_RESOURCE_MANAGER', FALSE);




@?/rdbms/admin/sqlsessend.sql
