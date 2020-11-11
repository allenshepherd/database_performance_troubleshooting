Rem
Rem $Header: rdbms/admin/catnacl.sql /main/18 2014/02/20 12:45:39 surman Exp $
Rem
Rem catnacl.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnacl.sql - Network ACL
Rem
Rem    DESCRIPTION
Rem      This script creates the tables required to define the access control
Rem      list (ACL) for PL/SQL network-related utility packages.
Rem
Rem    NOTES
Rem      This script should be run as "SYS".
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catnacl.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catnacl.sql
Rem SQL_PHASE: CATNACL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    rpang       07/10/12 - Remove name sequence
Rem    rpang       04/17/12 - Rename name_map column
Rem    surman      04/12/12 - 13615447: Add SQL patching tags
Rem    rpang       03/26/12 - Remove long_name primary key
Rem    rpang       11/25/11 - Triton migration
Rem    rpang       06/14/11 - Show privilege fullname
Rem    rpang       03/16/11 - 11878452: same CMNT in impcalloutreg$ for same TAG
Rem    rpang       02/08/11 - Add export support
Rem    rpang       03/04/09 - Use standard XML operators
Rem    rpang       02/15/08 - Add wallet ACL
Rem    rpang       06/27/07 - Commit netaclsc.xml changes
Rem    rpang       05/03/07 - Relocate resource config creation
Rem    rpang       04/06/07 - DBA_NETWORK_ACL_PRIVILEGES query against XDS_ACE
Rem    rpang       03/13/07 - Use ACLID
Rem    rpang       01/04/07 - Remove timestamp cast
Rem    rpang       09/21/06 - Handle ACE start_date and end_date
Rem    rpang       08/16/06 - Updated
Rem    rpang       06/13/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem ACL host assignments
Rem

create table NACL$_HOST
(
  HOST               varchar2(1000) not null,                /* network host */
  LOWER_PORT         number(5),                 /* lower bound of port range */
  UPPER_PORT         number(5),                 /* upper bound of port range */
  ACL#               number not null,                              /* ACL ID */
  constraint nacl$_host_uk unique (host,lower_port,upper_port)
)
/

Rem
Rem ACL wallet assignments
Rem

create table NACL$_WALLET
(
  WALLET_PATH        varchar2(1000) not null,                 /* wallet path */
  ACL#               number not null,                              /* ACL ID */
  constraint nacl$_wallet_pk primary key (wallet_path)
)
/

Rem
Rem ACL XDB name mapping
Rem

create table NACL$_NAME_MAP
(  
  XNAME              varchar2(4000) not null,       /* old XDB long ACL name */
  ACL#               varchar2(128)  not null,                      /* ACL ID */
  constraint nacl$_name_map_pk primary key (acl#)
)
/

@?/rdbms/admin/sqlsessend.sql
