Rem
Rem $Header: rdbms/admin/nacle111.sql /main/3 2017/05/28 22:46:07 stanaya Exp $
Rem
Rem nacle111.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      nacle111.sql - Downgrade script for PL/SQL network security
Rem
Rem    DESCRIPTION
Rem      Downgrade script for PL/SQL network security
Rem
Rem    NOTES
Rem      None
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/nacle111.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/nacle111.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    rpang       03/30/09 - Created
Rem

Rem Restore old XDB operators in network ACL views
create or replace view DBA_NETWORK_ACLS
(HOST, LOWER_PORT, UPPER_PORT, ACL, ACLID)
as
select a.host, a.lower_port, a.upper_port, r.any_path, a.aclid
  from net$_acl a, resource_view r
 where sys_op_r2o(extractValue(r.res, '/Resource/XMLRef')) = a.aclid
/


execute CDBView.create_cdbview(false,'SYS','DBA_NETWORK_ACLS','CDB_NETWORK_ACLS');
grant select on SYS.CDB_NETWORK_ACLS to select_catalog_role
/
create or replace public synonym CDB_NETWORK_ACLS for SYS.CDB_NETWORK_ACLS
/

create or replace view DBA_NETWORK_ACL_PRIVILEGES
(ACL, ACLID, PRINCIPAL, PRIVILEGE, IS_GRANT, INVERT, START_DATE, END_DATE)
as
select r.any_path, x.aclid, x.principal, p.privilege, x.is_grant,
       x.invert, x.start_date, x.end_date
  from resource_view r, xds_ace x,
       xmltable(xmlnamespaces('http://xmlns.oracle.com/xdb/acl.xsd' as "a"),
                '/a:privilege/*' passing x.privilege
                columns privilege varchar2(7) path 'fn:local-name(.)') p
 where x.aclid = sys_op_r2o(extractValue(r.res, '/Resource/XMLRef')) and
       x.aclid in (select aclid from net$_acl)
/

execute CDBView.create_cdbview(false,'SYS','DBA_NETWORK_ACL_PRIVILEGES','CDB_NETWORK_ACL_PRIVILEGES');
grant select on SYS.CDB_NETWORK_ACL_PRIVILEGES to select_catalog_role
/
create or replace public synonym CDB_NETWORK_ACL_PRIVILEGES for SYS.CDB_NETWORK_ACL_PRIVILEGES
/

