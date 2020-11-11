Rem
Rem $Header: rdbms/admin/dbmsaclsrv.sql /main/3 2015/06/01 10:41:52 bnnguyen Exp $
Rem
Rem dbmsaclsrv.sql
Rem
Rem Copyright (c) 2014, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem	 dbmsaclsrv.sql - DBMS_SFW_ACL_ADMIN
Rem
Rem    DESCRIPTION
Rem	 Service FireWall Admin package
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsaclsrv.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmsaclsrv.sql
Rem    SQL_PHASE: DBMSACLSRV
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bnnguyen    05/07/15 - bug 20134461: IP firewall support
Rem    bnnguyen    04/11/15 - bug 20860190: Rename 'EXADIRECT' to 'DBSFWUSER'
Rem    bnnguyen    09/03/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

GRANT SELECT ON DBA_XS_OBJECTS TO DBSFWUSER;
GRANT SELECT ON DBA_XS_ACLS TO DBSFWUSER;
GRANT SELECT ON DBA_XS_ACES TO DBSFWUSER;
GRANT EXECUTE ON XS_ACL TO DBSFWUSER;
GRANT EXECUTE ON DBMS_ASSERT TO DBSFWUSER;
GRANT EXECUTE ON DBMS_UTILITY TO DBSFWUSER;
GRANT EXECUTE ON DBMS_OUTPUT TO DBSFWUSER;
GRANT EXECUTE ON XS_SECURITY_CLASS TO DBSFWUSER;

CREATE OR REPLACE PACKAGE DBSFWUSER.DBMS_SFW_ACL_ADMIN AS

-----------
-- OVERVIEW
--
-- This package provides the APIs to administer service Access Control List
-- (ACL). ACLs are used to control accesss to DB services by external Virtual
-- Machines (VMs) or host networks.
--
-- There are two types of ACL: Exadirect and IP. Exadirect ACL is used to
-- grant access to VMs; where as, IP ACL is used to grant access to host
-- networks.
-- 
-- Exadirect APIs are prefixed by 'ed_'.
--
-- IP APIs are prefixed by 'ip_'.
--
-- APIs w/o prefix are generic.
--
---------------
-- INSTALLATION
-- This package is installed under DBSFWUSER schema
--
-----------
-- SECURITY
-- This package is owned and executed only by DBSFWUSER user. In CDB env,
-- DBSFWUSER must connect to CDB$ROOT container.
--
----------------
-- CONFIGURATION
-- This package works in conjunction with the network/listener configuration to
-- enforce access control on incoming client connections. To enable ACL
-- validation, the "FIREWALL" attribute must be turned on for the listening
-- endpoint. 
-- 
-- For example:
--
-- To enable IP firewall on TCP endpoint,
-- (ADDRESS=(PROTOCOL=TCP)(HOST=..)(PORT=1521)(FIREWALL=ON)) 
--
-- To enable Exadirect firewall on EXADIRECT endpoint,
-- (ADDRESS=(PROTOCOL=EXADIRECT)(HOST=..)(PORT=1521)(FIREWALL=ON))
-- 
-- For IP firewall, the following rules apply:
-- 1. (FIREWALL=ON) is explicitly set in endpoint. This will enable strict
--    validation of all connections coming on this endpoint. By default,
--    the connection will be rejected if no ACL is configured for that
--    service.
-- 2. FIREWALL is not set in endpoint - This implies relaxed validation. If
--    ACL is configured for the service, validation will be done for that
--    service. In absence of the ACL's, no validation will be done and the
--    connection for the that service will be accepted.
-- 3. (FIREWALL=OFF) is set in endpoint - No validation will be done and
--    all incoming connections will be accepted on this endpoint.
--
-- For Exadirect firewall, the following rules apply:
-- 1. (FIREWALL=ON) is explicit set in endpoint. This will enable strict
--    validation of all connections coming on this endpoint. By default,
--    the connection will be rejected if no ACL is configured for that
--    service.
-- 2. (FIREWALL=OFF) or FIREWALL is not set in the endpoint. No validation
--    will be done and all incoming connections will be accepted on this
--    endpoint.
-- 3. FIREWALL endpoint must be configured on secure network interface.
-- 4. The network interface is secure if DBSECURE=yes is set in its ifcfg.
-- 5. ACL must be enabled in DB cluster. It can be enabled via
--    ed_acl_enable() API.
--
------------------------
-- ERRORS AND EXCEPTIONS
--
exadirect_sgid_in_used Exception;
PRAGMA EXCEPTION_INIT(exadirect_sgid_in_used,-20001);
exadirect_dup_svc_and_uuid Exception;
PRAGMA EXCEPTION_INIT(exadirect_dup_svc_and_uuid,-20002);
exadirect_null_service Exception;
PRAGMA EXCEPTION_INIT(exadirect_null_service,-20003);
exadirect_null_uuid Exception;
PRAGMA EXCEPTION_INIT(exadirect_null_uuid,-20004);
exadirect_unknown Exception;
PRAGMA EXCEPTION_INIT(exadirect_unknown,-20005);
exadirect_bad_sgid Exception;
PRAGMA EXCEPTION_INIT(exadirect_bad_sgid,-20006);
exadirect_ids_mismatch Exception;
PRAGMA EXCEPTION_INIT(exadirect_ids_mismatch, -20007);
exadirect_insufficient_priv Exception;
PRAGMA EXCEPTION_INIT(exadirect_insufficient_priv, -20008);
ip_host_exists Exception;
PRAGMA EXCEPTION_INIT(ip_host_exists,-20009);
ip_invalid_host Exception;
PRAGMA EXCEPTION_INIT(ip_invalid_host,-20010);
ip_no_host Exception;
PRAGMA EXCEPTION_INIT(ip_no_host,-20011);
container_not_root Exception;
PRAGMA EXCEPTION_INIT(container_not_root, -20012);
not_exadata Exception;
PRAGMA EXCEPTION_INIT(not_exadata, -20013);

-- IP address mask: xxx.xxx.xxx.xxx
IP_ADDR_MASK    constant VARCHAR2(80) := '([[:digit:]]+\.){3}[[:digit:]]+';
-- IP submet mask:  xxx.xxx...*
IP_SUBNET_MASK  constant VARCHAR2(80) := '([[:digit:]]+\.){0,3}\*';
-- Hostname mask:   ???.???.???...???
HOSTNAME_MASK   constant VARCHAR2(80) := '[^\.\:\/\*]+(\.[^\.\:\/\*]+)*';
-- Hostname mask:   *.???.???...???
DOMAIN_MASK     constant VARCHAR2(80) := '\*(\.[^\.\:\/\*]+)*';


------------------
-- TYPE definition
--
-- This type is defined for use in batch operation.
--
TYPE table_type IS TABLE OF VARCHAR(300) INDEX BY BINARY_INTEGER;

---------------------------
-- PROCEDURES AND FUNCTIONS
--

procedure commit_acl;
-- Commit changes to the DB ACL table and propagate them to all
-- access control points in the DB cluster.
--
-- Exadirect ACL updates are only propagated if DB ACL control is enabled.
--
-- The call returns when the operation has completed successfully.
--
-- Input parameter:
--   None.
-- Output parameter:
--   None.
-- Exception:
--   Application to retry the call.   

procedure get_cdb_svcs( p_services OUT SYS_REFCURSOR );
-- Return all services for the CDB, excluding GLOBAL and INTERNAL
-- services.
-- services.
--
-- Input parameter:
--   None
-- Output parameter:
--   p_services
--     REF cursor of service names 

procedure ed_enable_acl;
-- Enable DB ACL control, load and propagate the initial ACLs to
-- all access control points in the DB cluster.
--
-- By default, DB ACL control is disabled and all access to secure
-- network interfaces(s) is denied.
--
-- The call returns when the operation has completed successfully.
--
-- Input parameter:
--   None.
-- Output parameter:
--   None
-- Exception:
--   not_exadata
--     Must be running on Exadata
--   others
--     Application to retry the call.

function ed_is_acl_enabled return boolean;
-- Return the state of ACL control on DB.
--
-- Input parameter:
--   None
-- Return value:
--   TRUE - ACL control is enabled on DB
--   FALSE - ACL control is disabled on DB

procedure ed_add_ace(p_service_name 	IN VARCHAR2,
                            p_vm_UUID 	IN VARCHAR2,
                            p_vm_SGID 	IN VARCHAR2);
-- Add a new Exadirect ACL entry.
--
-- Input parameters:
--   p_service_name
--     service name of the ACL entry.
--   p_vm_SGID
--     Source Global ID of VM that is allowed access to the service. 
--     It must be unique across running VMs and can be NULL.
--   p_vm_UUID
--     Universal Unique ID of VM. Used only by Exalogic Mgmt Stack. 
-- Output parameter:
--   None.
-- Exceptions:
--   exadirect_bad_sgid
--     SGID must conform to format "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x".
--   exadirect_null_service
--     service name is NULL
--   exadirect_null_uuid
--     VM UUID is NULL
--   exadirect_sgid_in_used
--     SGID is being used by another VM

procedure ed_update_ace(p_service_name IN VARCHAR2,
                               p_vm_UUID      IN VARCHAR2,
                               p_vm_SGID      IN VARCHAR2);
-- Update an Exadirect ACL entry.
--
-- Input parameters:
--   p_service_name
--     service name of the ACL entry to be updated.
--   p_vm_SGID
--     SGID of VM that is allowed access to the service.
--   p_vm_UUID
--     UUID of VM. Used only by Exalogic Mgmt Stack. 
-- Output parameter:
--   None.
-- Exceptions:
--   exadirect_bad_sgid
--     SGID must conform to format "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x"
--   exadirect_null_service
--     service name is NULL
--   exadirect_null_uuid
--     VM UUID is NULL
--   exadirect_sgid_in_used
--     SGID is being used by another VM

procedure ed_remove_ace_by_uuid(p_service_name IN VARCHAR2,
                                       p_vm_UUID      IN VARCHAR2);
-- Remove an Exadirect ACL entry for the specified service name and VM UUID.
--
-- Input parameters:
--   p_service_name
--     service name of the ACL entry.
--   p_vm_UUID
--     VM UUID of the ACL entry.
-- Output parameter:
--   None.

procedure ed_remove_ace_by_sgid(p_service_name IN VARCHAR2,
                                       p_vm_SGID      IN VARCHAR2);
-- Remove an Exadirect ACL entry for the specified service name and VM SGID.
--
-- Input parameters:
--   p_service_name
--     service name of the ACL entry.
--   p_vm_SGID
--     VM SGID of the ACL entry.
-- Output parameter:
--   None.

procedure ed_remove_aces_by_uuid(p_vm_UUID IN VARCHAR2);
-- Remove all service Exadirect ACL entries for the specified VM UUID 
--
-- Input parameter:
--   p_vm_UUID
--     VM UUID of the ACL entry
-- Output parameter:
--   None.

procedure ed_remove_aces_by_sgid(p_vm_SGID IN VARCHAR2);
-- Remove all service Exadirect ACL entries for the specified VM SGID 
--
-- Input parameter:
--   p_vm_SGID
--     VM SGID of the ACL entry
-- Output parameter:
--   None.

procedure ed_get_aces_by_uuid(p_vm_uuid  IN VARCHAR2,
                                     p_services OUT SYS_REFCURSOR);
-- Get all service Exadirect ACL entries for the specified VM UUID 
--
-- Input parameter:
--   p_vm_UUID
--     VM UUID of the ACL entry
-- Output parameter:
--   None.

PROCEDURE ed_get_aces_by_sgid(p_vm_sgid  IN VARCHAR2,
                                     p_services OUT SYS_REFCURSOR);
-- Get all service Exadirect ACL entries for the specified VM SGID 
--
-- Input parameter:
--   p_vm_SGID
--     VM SGID of the ACL entry
-- Output parameter:
--   None.

PROCEDURE ed_get_aces_by_uuid_sgid(p_vm_uuid  IN VARCHAR2,
                                          p_vm_sgid  IN VARCHAR2,
                                          p_services OUT SYS_REFCURSOR);
-- Get all service Exadirect ACL entries for the specified VM SGID and UUID.
--
-- Input parameters:
--   p_vm_uuid
--     VM UUID of the ACL entry
--   p_vm_sgid
--     VM SGID of the ACL entry
-- Output parameter:
--   p_services
--     REF cursor of service names

procedure ed_get_aces_by_svc(p_service_name IN VARCHAR2,
                             p_vm_UUIDs     OUT SYS_REFCURSOR);
-- Get all VM UUIDs for the specified service. This call will be used by
-- mgmt Stack to cleanup stalled service after the service has been removed
-- by DBA. This call will be used in conjunction with remove_acl_svc_by_uuid.
--
-- Input parameter:
--   p_service_name
--     service name of the ACL entry
-- Output parameter:
--   p_vm_UUIDs
--     REF cursor of UUIDs

procedure ed_bupdate_commit(p_vm_UUIDs    IN table_type,
                                 p_vm_SGIDs    IN table_type,
                                 p_vm_services IN table_type);
-- Batch update and commit. This is normally called when starting the VM.
--
-- Input parameters:
--   p_vm_UUIDs
--     table of UUIDs
--   p_vm_SGIDs 
--     table of SGIDs
--   p_vm_services
--     table of services
-- Output parameter:
--   None
-- Exception:
--   exadirect_ids_mismatch
--     Number of UUIDs and SGIDs mismatch 

procedure ed_bremove_commit_by_uuids(p_vm_UUIDs IN table_type);
-- Batch remove and commit. This is normally called when stopping a VM.
--
-- Input parameters:
--   p_vm_UUIDs
--     table of UUIDs
-- Output parameter"
--   None

procedure ed_add_pdb_ace(p_pdb_name IN VARCHAR2,
                         p_vm_UUID  IN VARCHAR2,
                         p_vm_SGID  IN VARCHAR2);
-- Add a new Exadirect ACL entry for each of the service in the specified PDB..
--
-- Input parameters:
--   p_pdb_name
--     PDB name.
--   p_vm_SGID
--     Source Global ID of VM that is allowed access to the service. 
--     It must be unique across running VMs and can be NULL.
--   p_vm_UUID
--     Universal Unique ID of VM. Used only by Exalogic Mgmt Stack. 
-- Output parameter:
--   None.
-- Exceptions:
--   exadirect_bad_sgid
--     SGID must conform to format "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x".
--   exadirect_null_service
--     service name is NULL
--   exadirect_null_uuid
--     VM UUID is NULL
--   exadirect_sgid_in_used
--     SGID is being used by another VM

procedure ed_update_pdb_ace(p_pdb_name IN VARCHAR2,
                            p_vm_UUID  IN VARCHAR2,
                            p_vm_SGID  IN VARCHAR2);
-- Update an Exadirect ACL entry for each of the service in the specified PDB.
--
-- Input parameters:
--   p_pdb_name
--     PDB name.
--   p_vm_SGID
--     SGID of VM that is allowed access to the service.
--   p_vm_UUID
--     UUID of VM. Used only by Exalogic Mgmt Stack. 
-- Output parameter:
--   None.
-- Exceptions:
--   exadirect_bad_sgid
--     SGID must conform to format "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x"
--   exadirect_null_service
--     service name is NULL
--   exadirect_null_uuid
--     VM UUID is NULL
--   exadirect_sgid_in_used
--     SGID is being used by another VM

procedure ed_remove_pdb_ace_by_uuid(p_pdb_name IN VARCHAR2,
                                    p_vm_UUID  IN VARCHAR2);
-- Remove an Exadirect ACL entry for each of the service in the specified PDB.
--
-- Input parameters:
--   p_pdb_name
--     PDB name.
--   p_vm_UUID
--     VM UUID of the ACL entry.
-- Output parameter:
--   None.

procedure ed_remove_pdb_ace_by_sgid(p_pdb_name IN VARCHAR2,
                                    p_vm_SGID  IN VARCHAR2);
-- Remove an Exadirect ACL entry for each of the service in the specified PDB.
--
-- Input parameters:
--   p_pdb_name
--     PDB name.
--   p_vm_SGID
--     VM SGID of the ACL entry.
-- Output parameter:
--   None.

procedure ed_remove_acl(p_service_name IN VARCHAR2);
-- Remove Exadirect ACL for the specified service name.
--
-- Input parameters:
--   p_service_name
--     service name.
-- Output parameter:
--   None.

procedure ed_remove_pdb_acl(p_pdb_name IN VARCHAR2);
-- Remove the Exadirect ACL for each of the service in the specified PDB.
--
-- Input parameters:
--   p_pdb_name
--     PDB name.
-- Output parameter:
--   None.

procedure ip_add_ace(p_service_name    IN VARCHAR2,
                     p_host            IN VARCHAR2);
-- Add a new IP ACL entry.
--
-- Input parameters:
--   p_service_name
--     service name of the ACL entry.
--   p_host
--      host string. The string can be a hostname, dotted-decimal IPv4
--      or hexadecimal IPv6 address. Wildcard "*" for IPv4 and CIDR format
--      allowed.
-- Output parameter:
--   None.
-- Exceptions:
--   host_exists
--     host exists for the service name
--   invalid_host
--     host is invalid
--   null_service
--     service name is NULL
--   null_host
--     host is NULL

procedure ip_remove_ace(p_service_name IN VARCHAR2,
                        p_host         IN VARCHAR2);
-- Remove an IP ACL entry for the specified service name and host.
--
-- Input parameters:
--   p_service_name
--     service name of the ACL entry.
--   p_host
--     IP address string of the ACL entry.
-- Output parameter:
--   None.

procedure ip_remove_acl(p_service_name IN VARCHAR2);
-- Remove all IP ACL entries for the specified service name.
--
-- Input parameters:
--   p_service_name
--     service name of the ACL entries.
-- Output parameter:
--   None.

procedure ip_get_acl(p_service_name IN VARCHAR2,
                     p_hosts        OUT SYS_REFCURSOR);
-- Get all IP ACL entries for the specified service name.
-- Input parameters:
--   p_service_name
--     service name of the ACL entries.
-- Output parameter:
--   p_hosts
--     REF cursor of host strings

procedure ip_get_acl_svcs_by_host(p_host         IN VARCHAR2,
                                  p_services     OUT SYS_REFCURSOR);
-- Get all service names for a specified host.
-- Input parameters:
--   p_host
--     host string.
-- Output parameter:
--   p_services
--     REF cursor of service names

procedure ip_add_pdb_ace(p_pdb_name        IN VARCHAR2,
                         p_host            IN VARCHAR2);
-- Add a new IP ACL entry for each of the service in the specified PDB.
--
-- Input parameters:
--   p_pdb_name
--     PDB name.
--   p_host
--      host string. The string can be a hostname, dotted-decimal IPv4
--      or hexadecimal IPv6 address. Wildcard "*" for IPv4 and CIDR format
--      allowed.
-- Output parameter:
--   None.
-- Exceptions:
--   host_exists
--     host exists for the service name
--   invalid_host
--     host is invalid
--   null_service
--     service name is NULL
--   null_host
--     host is NULL

procedure ip_remove_pdb_ace(p_pdb_name     IN VARCHAR2,
                            p_host         IN VARCHAR2);
-- Remove an IP ACL entry for each of the service in the specified PDB. 
--
-- Input parameters:
--   p_pdb_name
--     PDB name.
--   p_host
--     IP address string of the ACL entry.
-- Output parameter:
--   None.

procedure ip_remove_pdb_acl(p_pdb_name     IN VARCHAR2);
-- Remove the IP ACL for each of the service in the specified PDB.
--
-- Input parameters:
--   p_pdb_name
--     PDB name.
-- Output parameter:
--   None.

END DBMS_SFW_ACL_ADMIN;
/

@?/rdbms/admin/sqlsessend.sql
