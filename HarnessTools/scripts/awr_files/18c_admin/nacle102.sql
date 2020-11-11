Rem
Rem $Header: rdbms/admin/nacle102.sql /main/6 2017/05/28 22:46:07 stanaya Exp $
Rem
Rem nacle102.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      nacle102.sql - Downgrade script for PL/SQL network security
Rem
Rem    DESCRIPTION
Rem      Downgrade script for PL/SQL network security
Rem
Rem    NOTES
Rem      None
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/nacle102.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/nacle102.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       05/22/07 - remove dbms_network_acl_admin_int
Rem    rpang       12/04/06 - drop dbms_network_acl_utility
Rem    rpang       11/20/06 - drop view/synonym USER_NETWORK_ACL_PRIVILEGES
Rem    pthornto    10/16/06 - drop view/synonym DBA_NETWORK_ACLS
Rem    rpang       08/14/06 - Created
Rem

-- Remove all the resources created under /sys/apps/plsql
BEGIN
  for r1 in (select any_path p from resource_view
              where under_path(res, '/sys/apps/plsql', 1) = 1
              order by depth(1) desc) loop
    execute immediate 'delete from resource_view where equals_path(res, :1)=1'
      using r1.p;
  end loop;
  delete from resource_view where equals_path(res, '/sys/apps/plsql')=1;
END;
/

-- Drop network ACL security objects
drop public synonym user_network_acl_privileges;
drop view user_network_acl_privileges;
drop public synonym dba_network_acl_privileges;
drop view dba_network_acl_privileges;
drop public synonym dba_network_acls;
drop view dba_network_acls;
drop table net$_acl;
drop package dbms_network_acl_admin;
drop package dbms_network_acl_utility;
