Rem
Rem $Header: rdbms/admin/dbmsrmpr.sql /main/6 2014/02/20 12:45:43 surman Exp $
Rem
Rem dbmsrmpriv.sql
Rem
Rem Copyright (c) 1998, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsrmpriv.sql - public interface for DBMS Resource Manager PRIVileges
Rem
Rem    DESCRIPTION
Rem      Specification for the resource manager privileges package
Rem
Rem    NOTES
Rem      
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsrmpr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsrmpr.sql
Rem SQL_PHASE: DBMSRMPR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    gviswana    07/30/98 - Remove SQL_NAME_RESOLVE                          
Rem    akalra      06/01/98 - Remove switch_current_consumer_group             
Rem    akalra      05/20/98 - Change interface                                 
Rem    akalra      04/02/98 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_resource_manager_privs AUTHID CURRENT_USER AS

 --
 -- grant a system privilege to a user/role.
 --
 -- Input arguments:
 --   grantee        - name of the user or role to whom privilege is to be
 --                    granted
 --   privilege_name - name of the privilege to be granted.
 --   admin_option   - TRUE if the grant is with admin_option, FALSE otherwise
 --
 PROCEDURE grant_system_privilege(grantee_name IN VARCHAR2,
                                  privilege_name IN VARCHAR2 DEFAULT
                                  'ADMINISTER_RESOURCE_MANAGER',
                                  admin_option IN BOOLEAN);
 
 --
 -- revoke a system privilege from a user/role
 --
 -- Input arguments:
 --   revokee_name - name of the user or role from whom privilege is to be
 --                  revoked
 --
 PROCEDURE revoke_system_privilege(revokee_name IN VARCHAR2,
                                   privilege_name in VARCHAR2 DEFAULT
                                  'ADMINISTER_RESOURCE_MANAGER');

 --
 -- allow the specified user/role to switch to the given consumer group
 -- 
 -- Input arguments:
 --   grantee_name   - name of user/role to which to grant access
 --   consumer_group - name of consumer_group
 --   grant_option   - TRUE if grantee should be allowed to grant access,
 --                    FALSE otherwise.
 --
 PROCEDURE grant_switch_consumer_group(grantee_name IN VARCHAR2,
                                       consumer_group IN VARCHAR2,
                                       grant_option IN BOOLEAN);

 --
 -- disallow the specified user/role from switching to the given
 -- consumer group, and from granting access to the group to other
 -- users/roles.
 -- 
 -- Input arguments:
 --   revokee_name      - name of user/role from which to revoke access
 --   consumer_group    - name of consumer group
 --
 PROCEDURE revoke_switch_consumer_group(revokee_name IN VARCHAR2,
                                        consumer_group IN VARCHAR2);

END dbms_resource_manager_privs;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_resource_manager_privs FOR 
sys.dbms_resource_manager_privs
/
GRANT EXECUTE ON dbms_resource_manager_privs TO public
/

@?/rdbms/admin/sqlsessend.sql
