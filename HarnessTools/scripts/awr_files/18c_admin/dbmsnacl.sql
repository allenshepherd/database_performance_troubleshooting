Rem
Rem $Header: plsql/admin/dbmsnacl.sql /main/20 2016/06/24 17:09:05 rpang Exp $
Rem
Rem dbmsnacl.sql
Rem
Rem Copyright (c) 2006, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsnacl.sql - DBMS Network ACL
Rem
Rem    DESCRIPTION
Rem      This package provides the PL/SQL interface to administer the
Rem      access control list of network access from the database through
Rem      the PL/SQL network-related utility packages.
Rem
Rem    NOTES
Rem      This package must be created under SYS.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: plsql/admin/dbmsnacl.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsnacl.sql
Rem SQL_PHASE: DBMSNACL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       06/22/16 - Bug 23620391: obsolete instance_export_action
Rem    rpang       06/21/16 - Bug 23605481: update check_privilege/_aclid doc
Rem                           on null user
Rem    rpang       10/22/15 - Mark deprecated APIs
Rem    surman      01/15/14 - 13922626: Update SQL metadata
Rem    rpang       10/15/12 - Add import/export callouts
Rem    rpang       05/18/12 - Add append ACL APIs
Rem    rpang       05/11/12 - 14065886: move get aclids API to admin package
Rem    rpang       04/09/12 - 13941768: add new privilege admin APIs
Rem    rpang       04/05/12 - 13932413: add exception declarations
Rem    rpang       11/25/11 - Triton migration
Rem    rpang       03/21/11 - Add export/import support
Rem    rpang       03/17/08 - Add API to assign ACL to wallets
Rem    rpang       01/02/08 - IPv6 support
Rem    rpang       03/09/07 - Use ACLID
Rem    rpang       12/13/06 - Move check_privilege_aclid impl to body
Rem    rpang       09/21/06 - Handle ACE start_date and end_date
Rem    rpang       08/24/06 - Add ACE start_date/end_date
Rem    rpang       06/08/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package dbms_network_acl_admin is

  /*
   * DBMS_NETWORK_ACL_ADMIN is the PL/SQL package that provides the interface
   * to administer the network ACL. The EXECUTE privilege on the package will
   * be granted only to the DBA role by default.
   */

  ----------------
  -- Exceptions --
  ----------------
  ace_already_exists          EXCEPTION;
  empty_acl                   EXCEPTION;
  acl_not_found               EXCEPTION;
  acl_already_exists          EXCEPTION;
  invalid_acl_path            EXCEPTION;
  invalid_host                EXCEPTION;
  invalid_privilege           EXCEPTION;
  invalid_wallet_path         EXCEPTION;
  bad_argument                EXCEPTION;
  unresolved_principal        EXCEPTION;
  privilege_not_granted       EXCEPTION;
  PRAGMA EXCEPTION_INIT(ace_already_exists,          -24243);
  PRAGMA EXCEPTION_INIT(empty_acl,                   -24246);
  PRAGMA EXCEPTION_INIT(acl_not_found,               -46114);
  PRAGMA EXCEPTION_INIT(acl_already_exists,          -46212);
  PRAGMA EXCEPTION_INIT(invalid_acl_path,            -46059);
  PRAGMA EXCEPTION_INIT(invalid_host,                -24244);
  PRAGMA EXCEPTION_INIT(invalid_privilege,           -24245);
  PRAGMA EXCEPTION_INIT(invalid_wallet_path,         -29248);
  PRAGMA EXCEPTION_INIT(bad_argument,                -29261);
  PRAGMA EXCEPTION_INIT(unresolved_principal,        -46238);
  PRAGMA EXCEPTION_INIT(privilege_not_granted,       -01927);
  ace_already_exists_num      constant PLS_INTEGER := -24243;
  empty_acl_num               constant PLS_INTEGER := -24246;
  acl_not_found_num           constant PLS_INTEGER := -46114;
  acl_already_exists_num      constant PLS_INTEGER := -46212;
  invalid_acl_path_num        constant PLS_INTEGER := -46059;
  invalid_host_num            constant PLS_INTEGER := -24244;
  invalid_privilege_num       constant PLS_INTEGER := -24245;
  invalid_wallet_path_num     constant PLS_INTEGER := -29248;
  bad_argument_num            constant PLS_INTEGER := -29261;
  unresolved_principal_num    constant PLS_INTEGER := -46238;
  privilege_not_granted_num   constant PLS_INTEGER := -01927;

  -- IP address mask: xxx.xxx.xxx.xxx
  IP_ADDR_MASK    constant VARCHAR2(80) := '([[:digit:]]+\.){3}[[:digit:]]+';
  -- IP submet mask:  xxx.xxx...*
  IP_SUBNET_MASK  constant VARCHAR2(80) := '([[:digit:]]+\.){0,3}\*';
  -- Hostname mask:   ???.???.???...???
  HOSTNAME_MASK   constant VARCHAR2(80) := '[^\.\:\/\*]+(\.[^\.\:\/\*]+)*';
  -- Hostname mask:   *.???.???...???
  DOMAIN_MASK     constant VARCHAR2(80) := '\*(\.[^\.\:\/\*]+)*';

  /* Table of ACL IDs */
  type aclid_table is table of number index by binary_integer;

  /*--------------- API for ACL and privilege administration ---------------*/

  /*
   * Creates an access control list (ACL) with an initial privilege setting.
   * An ACL must have at least one privilege setting. The ACL has no access
   * control effect unless it is assigned to a network host.
   *
   * PARAMETERS
   *   acl          the name of the ACL. Relative path will be relative to
   *                "/sys/acls".
   *   description  the description attribute in the ACL
   *   principal    the principal (database user or role) whom the privilege
   *                is granted to or denied from
   *   is_grant     is the privilege is granted or denied
   *   privilege    the network privilege to be granted or denied
   *   start_date   the start date of the access control entry (ACE). When
   *                specified, the ACE will be valid only on and after the
   *                specified date.
   *   end_date     the end date of the access control entry (ACE). When
   *                specified, the ACE will expire after the specified date.
   *                The end_date must be greater than or equal to the
   *                start_date.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   *   To remove the ACL, use DROP_ACL. To assign the ACL to a network host,
   *   use ASSIGN_ACL.
   */
  procedure create_acl(acl          in varchar2,
                       description  in varchar2,
                       principal    in varchar2,
                       is_grant     in boolean,
                       privilege    in varchar2,
                       start_date   in timestamp with time zone default null,
                       end_date     in timestamp with time zone default null);
    pragma deprecate(create_acl,
                     'DBMS_NETWORK_ACL_ADMIN.CREATE_ACL is deprecated!');

  /*
   * Adds a privilege to grant or deny the network access to the user. The
   * access control entry (ACE) will be created if it does not exist.
   *
   * PARAMETERS
   *   acl          the name of the ACL. Relative path will be relative to
   *                "/sys/acls".
   *   principal    the principal (database user or role) whom the privilege
   *                is granted to or denied from
   *   is_grant     is the privilege is granted or denied
   *   privilege    the network privilege to be granted or denied
   *   position     the position of the ACE. If a non-null value is given,
   *                the privilege will be added in a new ACE at the given
   *                position and there should not be another ACE for the
   *                principal with the same is_grant (grant or deny). If a null
   *                value is given, the privilege will be added to the ACE
   *                matching the principal and the is_grant if one exists, or
   *                to the end of the ACL if the matching ACE does not exist.
   *   start_date   the start date of the access control entry (ACE). When
   *                specified, the ACE will be valid only on and after the
   *                specified date. The start_date will be ignored if the
   *                privilege is added to an existing ACE.
   *   end_date     the end date of the access control entry (ACE). When
   *                specified, the ACE will expire after the specified date.
   *                The end_date must be greater than or equal to the
   *                start_date. The end_date will be ignored if the
   *                privilege is added to an existing ACE.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   *   To remove the privilege, use DELETE_privilege.
   */
  procedure add_privilege(acl        in varchar2,
                          principal  in varchar2,
                          is_grant   in boolean,
                          privilege  in varchar2,
                          position   in pls_integer default null,
                          start_date in timestamp with time zone default null,
                          end_date   in timestamp with time zone default null);
    pragma deprecate(add_privilege,
                     'DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE is deprecated!');

  /*
   * Delete a privilege.
   *
   * PARAMETERS
   *   acl          the name of the ACL. Relative path will be relative to
   *                "/sys/acls".
   *   principal    the principal (database user or role) for whom the
   *                privileges will be deleted
   *   is_grant     is the privilege is granted or denied. If a null
   *                value is given, the deletion is applicable to both
   *                granted or denied privileges.
   *   privilege    the privilege to be deleted. If a null value is given,
   *                the deletion is applicable to all privileges.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   *   Any ACE that does not contain any privilege after the deletion will
   *   be removed also.
   */
  procedure delete_privilege(acl          in varchar2,
                             principal    in varchar2,
                             is_grant     in boolean  default null,
                             privilege    in varchar2 default null);
    pragma deprecate(delete_privilege,
                     'DBMS_NETWORK_ACL_ADMIN.DELETE_PRIVILEGE is deprecated!');

  /*
   * Drops an access control list (ACL).
   *
   * PARAMETERS
   *   acl          the name of the ACL. Relative path will be relative to
   *                "/sys/acls".
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   */
  procedure drop_acl(acl in varchar2);
    pragma deprecate(drop_acl,
                     'DBMS_NETWORK_ACL_ADMIN.DROP_ACL is deprecated!');

  /*--------- API for ACL assignment to network hosts and wallets ---------*/

  /*
   * Assigns an access control list (ACL) to a network host, and optionally
   * specific to a TCP port range.
   *
   * PARAMETERS
   *   acl        the name of the ACL. Relative path will be relative to
   *              "/sys/acls".
   *   host       the host to which the ACL will be assigned. The host can be
   *              the name or the IP address of the host. A wildcard can be
   *              used to specify a domain or a IP subnet. The host or
   *              domain name is case-insensitive.
   *   lower_port the lower bound of a TCP port range if not NULL.
   *   upper_port the upper bound of a TCP port range. If NULL,
   *              lower_port is assumed.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   * 1. The ACL assigned to a domain takes a lower precedence than the other
   *    ACLs assigned sub-domains, which take a lower precedence than the ACLs
   *    assigned to the individual hosts. So for a given host say
   *    "www.us.mycompany.com", the following domains are listed in decreasing
   *    precedences:
   *      - www.us.mycompany.com
   *      - *.us.mycompany.com
   *      - *.mycompany.com
   *      - *.com
   *      - *
   *    In the same way, the ACL assigned to an subnet takes a lower
   *    precedence than the other ACLs assigned smaller subnets, which take a
   *    lower precedence than the ACLs assigned to the individual IP addresses.
   *    So for a given IP address say "192.168.0.100", the following subnets
   *    are listed in decreasing precedences:
   *      - 192.168.0.100
   *      - 192.168.0.*
   *      - 192.168.*
   *      - 192.*
   *      - *
   * 2. The port range is applicable only to the "connect" privilege
   *    assignments in the ACL. The "resolve" privilege assignments in an ACL
   *    have effects only when the ACL is assigned to a host without a port
   *    range.
   * 3. For the "connect" privilege assignments, an ACL assigned to the host
   *    without a port range takes a lower precedence than other ACLs assigned
   *    to the same host with a port range.
   * 4. When specifying a TCP port range, both lower_port and upper_port must
   *    not be NULL and upper_port must be greater than or equal to lower_port.
   *    The port range must not overlap with any other port ranges for the same
   *    host assigned already.
   * 5. To remove the assignment, use UNASSIGN_ACL.
   */
  procedure assign_acl(acl        in varchar2,
                       host       in varchar2,
                       lower_port in pls_integer default null,
                       upper_port in pls_integer default null);
    pragma deprecate(assign_acl,
                     'DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL is deprecated!');

  /*
   * Unassign the access control list (ACL) currently assigned to a network
   * host.
   *
   * PARAMETERS
   *   acl        the name of the ACL. Relative path will be relative to
   *              "/sys/acls". If acl is NULL, any ACL assigned to the host
   *              will be unassigned.
   *   host       the host remove the ACL assignment from. The host can be
   *              the name or the IP address of the host. A wildcard can be
   *              used to specify a domain or a IP subnet. The host or
   *              domain name is case-insensitive. If host is null, the ACL
   *              will be unassigned from any host. If both host and acl are
   *              NULL, all ACLs assigned to any hosts will be unassigned.
   *   lower_port if not NULL, the lower bound of a TCP port range for the
   *              host.
   *   upper_port the upper bound of a TCP port range. If NULL,
   *              lower_port is assumed.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   */
  procedure unassign_acl(acl        in varchar2 default null,
                         host       in varchar2 default null,
                         lower_port in pls_integer default null,
                         upper_port in pls_integer default null);
    pragma deprecate(unassign_acl,
                     'DBMS_NETWORK_ACL_ADMIN.UNASSIGN_ACL is deprecated!');

  /*
   * Assigns an access control list (ACL) to a wallet.
   *
   * PARAMETERS
   *   acl         the name of the ACL. Relative path will be relative to
   *               "/sys/acls".
   *   wallet_path the directory path of the wallet to which the ACL will be
   *               assigned. The path is case-sensitive and of the format
   *               "file:<directory-path>".
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   *   To remove the assignment, use UNASSIGN_WALLET_ACL.
   */
  procedure assign_wallet_acl(acl         in varchar2,
                              wallet_path in varchar2);
    pragma deprecate(assign_wallet_acl,
                     'DBMS_NETWORK_ACL_ADMIN.ASSIGN_WALLET_ACL is deprecated!');

  /*
   * Unassign the access control list (ACL) currently assigned to a wallet.
   *
   * PARAMETERS
   *   acl         the name of the ACL. Relative path will be relative to
   *               "/sys/acls". If acl is NULL, any ACL assigned to the wallet
   *               will be unassigned.
   *   wallet_path the directory path of the wallet to which the ACL will be
   *               assigned. The path is case-sensitive and of the format
   *               "file:<directory-path>". If wallet_path is null, the ACL
   *               will be unassigned from any wallet.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   */
  procedure unassign_wallet_acl(acl         in varchar2 default null,
                                wallet_path in varchar2 default null);
    pragma deprecate(unassign_wallet_acl,
                   'DBMS_NETWORK_ACL_ADMIN.UNASSIGN_WALLET_ACL is deprecated!');

  /*
   * Check if a privilege is granted to or denied from the user in an
   * access control list.
   *
   * PARAMETERS
   *   acl        the name of the ACL. Relative path will be relative to
   *              "/sys/acls".
   *   aclid      the object ID of the ACL.
   *   user       the user to check against. The username is case-sensitive as
   *              in the USERNAME column of the ALL_USERS view.
   *   privilege  the network privilege to check
   * RETURN
   *   1 when the privilege is granted; 0 when the privilege is denied;
   *   NULL when the privilege is neither granted or denied.
   * EXCEPTIONS
   *
   * NOTES
   *   - These functions used to accept a null user as argument and on which
   *     they always returned 1. They will now raise error if a null user is
   *     given.
   */
  function check_privilege(acl       in varchar2,
                           user      in varchar2,
                           privilege in varchar2) return number; 
    pragma deprecate(check_privilege,
                     'DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE is deprecated!');
  function check_privilege_aclid(aclid     in raw,
                                 user      in varchar2,
                                 privilege in varchar2) return number; 
    pragma deprecate(check_privilege_aclid,
                 'DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE_ACLID is deprecated!');

  /*
   * Append an access control entry (ACE) to the access control list (ACL)
   * of a network host. The ACL controls access to the given host from the
   * database and the ACE specifies the privileges granted to or denied
   * from the specified principal.
   *
   * PARAMETERS
   *   host       the host. It can be the name or the IP address of the host.
   *              A wildcard can be used to specify a domain or a IP subnet.
   *              The host or domain name is case-insensitive.
   *   lower_port the lower bound of an optional TCP port range.
   *   upper_port the upper bound of an optional TCP port range. If NULL,
   *              lower_port is assumed.
   *   ace        the ACE.
   * RETURN
   *   None
   * EXCEPTIONS
   *
   * NOTES
   * - Duplicate privileges in the matching ACE in the host ACL will be
   *   skipped.
   * - To remove the ACE, use REMOVE_HOST_ACE.
   * - A host's ACL takes precedence over its domains' ACLs. For a given host
   *   say "www.us.mycompany.com", the following domains are listed in
   *   decreasing precedence:
   *     - www.us.mycompany.com
   *     - *.us.mycompany.com
   *     - *.mycompany.com
   *     - *.com
   *     - *
   *   An IP address' ACL takes precedence over its subnets' ACLs. For a given
   *   IP address say "192.168.0.100", the following subnets are listed in
   *   decreasing precedence:
   *     - 192.168.0.100
   *     - 192.168.0.*
   *     - 192.168.*
   *     - 192.*
   *     - *
   * - An ACE with a "resolve" privilege can be appended only to a host's ACL
   *   without a port range.
   * - When ACEs with "connect" privileges are appended to a host's ACLs
   *   with and without a port range, the one appended to the host with a
   *   port range takes precedence.
   * - When specifying a TCP port range of a host, it cannot overlap with other
   *   existing port ranges of the host.
   * - If the ACL is shared with another host or wallet, a copy of the ACL
   *   will be made before the ACL is modified.
   */
  procedure append_host_ace(host       in varchar2,
                            lower_port in pls_integer default null,
                            upper_port in pls_integer default null,
                            ace        in xs$ace_type);

  /*
   * Append access control entries (ACE) of an access control list (ACL) to
   * the ACL of a network host.
   *
   * PARAMETERS
   *   host       the host. It can be the name or the IP address of the host.
   *              A wildcard can be used to specify a domain or a IP subnet.
   *              The host or domain name is case-insensitive.
   *   lower_port the lower bound of an optional TCP port range.
   *   upper_port the upper bound of an optional TCP port range. If NULL,
   *              lower_port is assumed.
   *   acl        the ACL to append from.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   * - See APPEND_HOST_ACE.
   */
  procedure append_host_acl(host       in varchar2,
                            lower_port in pls_integer default null,
                            upper_port in pls_integer default null,
                            acl        in varchar2);

  /*
   * Remove privileges from access control entries (ACE) in the access control
   * list (ACL) of a network host matching the given ACE.
   *
   * PARAMETERS
   *   host             the host. It can be the name or the IP address of the
   *                    host. A wildcard can be used to specify a domain or a
   *                    IP subnet. The host or domain name is case-insensitive.
   *   lower_port       the lower bound of an optional TCP port range.
   *   upper_port       the upper bound of an optional TCP port range. If NULL,
   *                    lower_port is assumed.
   *   ace              the ACE.
   *   remove_empty_acl remove empty ACL also?
   * RETURN
   *   None
   * EXCEPTIONS
   *
   * NOTES
   * - If the ACL is shared with another host or wallet, a copy of the ACL
   *   will be made before the ACL is modified.
   */
  procedure remove_host_ace(host             in varchar2,
                            lower_port       in pls_integer default null,
                            upper_port       in pls_integer default null,
                            ace              in xs$ace_type,
                            remove_empty_acl in boolean default false);

  /*
   * Append an access control entry (ACE) to the access control list (ACL)
   * of a wallet. The ACL controls access to the given wallet from the
   * database and the ACE specifies the privileges granted to or denied
   * from the specified principal.
   *
   * PARAMETERS
   *   wallet_path the directory path of the wallet. The path is case-sensitive
   *               of the format "file:<directory-path>".
   *   ace         the ACE.
   * RETURN
   *   None
   * EXCEPTIONS
   *
   * NOTES
   * - Duplicate privileges in the matching ACE in the wallet ACL will be
   *   skipped.
   * - To remove the ACE, use REMOVE_WALLET_ACE.
   * - If the ACL is shared with another host or wallet, a copy of the ACL
   *   will be made before the ACL is modified.
   */
  procedure append_wallet_ace(wallet_path in varchar2,
                              ace         in xs$ace_type);

  /*
   * Append access control entries (ACE) of an access control list (ACL) to the
   * ACL of a wallet.
   *
   * PARAMETERS
   *   wallet_path the directory path of the wallet. The path is case-sensitive
   *               of the format "file:<directory-path>".
   *   acl         the ACL to append from.
   * RETURN
   *   None
   * EXCEPTIONS
   *
   * NOTES
   * - See APPEND_WALLET_ACE.
   */
  procedure append_wallet_acl(wallet_path in varchar2,
                              acl         in varchar2);

  /*
   * Remove privileges from access control entries (ACE) in the access control
   * list (ACL) of a wallet matching the given ACE.
   *
   * PARAMETERS
   *   wallet_path      the directory path of the wallet. The path is
   *                    case-sensitive of the format "file:<directory-path>".
   *   ace              the ACE.
   *   remove_empty_acl remove empty ACL also?
   * RETURN
   *   None
   * EXCEPTIONS
   *
   * NOTES
   * - If the ACL is shared with another host or wallet, a copy of the ACL
   *   will be made before the ACL is modified.
   */
  procedure remove_wallet_ace(wallet_path      in varchar2,
                              ace              in xs$ace_type,
                              remove_empty_acl in boolean default false);

  /*
   * Set the access control list (ACL) of a network host which controls access
   * to the host from the database.
   *
   * PARAMETERS
   *   host       the host. It can be the name or the IP address of the host.
   *              A wildcard can be used to specify a domain or a IP subnet.
   *              The host or domain name is case-insensitive.
   *   lower_port the lower bound of an optional TCP port range.
   *   upper_port the upper bound of an optional TCP port range. If NULL,
   *              lower_port is assumed.
   *   acl        the ACL. Null to unset the host's ACL.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   * - A host's ACL is created and set on-demand when an access control entry
   *   (ACE) is appended to the host's ACL. Users are discouraged from setting
   *   a host's ACL manually.
   */
  procedure set_host_acl(host       in varchar2,
                         lower_port in pls_integer default null,
                         upper_port in pls_integer default null,
                         acl        in varchar2);

  /*
   * Set the access control list (ACL) of a wallet which controls access to
   * the wallet from the database.
   *
   * PARAMETERS
   *   wallet_path the directory path of the wallet. The path is case-sensitive
   *               and of the format "file:<directory-path>".
   *   acl         the ACL. Null to unset the wallet's ACL.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   * - A wallet's ACL is created and set on-demand when an access control
   *   entry (ACE) is appended to the wallet's ACL. Users are discouraged from
   *   setting a wallet's ACL manually.
   */
  procedure set_wallet_acl(wallet_path in varchar2,
                           acl         in varchar2);

  /* Internal functions */
  function get_host_aclids(host in varchar2, port in number) return aclid_table
    result_cache;
  function get_wallet_aclid(wallet_path in varchar2) return number
    result_cache;
  procedure instance_callout_imp(obj_name   in  varchar2,
                                 obj_schema in  varchar2,
                                 obj_type   in  number,
                                 prepost    in  pls_integer,
                                 action     out varchar2,
                                 alt_name   out varchar2);

end;
/

grant execute on sys.dbms_network_acl_admin to dba;
grant execute on sys.dbms_network_acl_admin to execute_catalog_role;

create or replace public synonym dbms_network_acl_admin
for sys.dbms_network_acl_admin;

create or replace package dbms_network_acl_utility is

  /*
   * DBMS_NETWORK_ACL_UTILITY is the PL/SQL package that provides the utility
   * functions to facilitate the evaluation of ACL assignments governing
   * TCP connections to network hosts.
   */

  -----------
  -- Types --
  -----------
  type domain_table is table of varchar2(1000);

  ----------------
  -- Exceptions --
  ----------------
  access_denied               EXCEPTION;
  PRAGMA EXCEPTION_INIT(access_denied,               -24247);
  access_denied_num           constant PLS_INTEGER := -24247;

  /*
   * For a given host, return the domains whose ACL assigned will be used to
   * determine if a user has the privilege to access the given host or not.
   * When the IP address of the host is given, return the subnets instead.
   *
   * PARAMETERS
   *   host       the network host.
   * RETURN
   *   The domains or subnets for the given host.
   * EXCEPTIONS
   *
   * NOTES
   *   This function cannot handle IPv6 addresses. Nor can it generate
   *   subnets of arbitrary number of prefix bits for an IPv4 address.
   */
  function domains(host in varchar2) return domain_table pipelined;

  /*
   * Return the domain level of the given host name, domain, or subnet.
   *
   * PARAMETERS
   *   host       the network host, domain, or subnet.
   * RETURN
   *   The domain level of the given host, domain, or subnet.
   * EXCEPTIONS
   *
   * NOTES
   *   This function cannot handle IPv6 addresses and subnets, and subnets
   *   in Classless Inter-Domain Routing (CIDR) notation.
   */
  function domain_level(host in varchar2) return number deterministic;

  /*
   * Determines if the two given hosts, domains, or subnets are equal. For
   * IP addresses and subnets, this function can handle different
   * representations of the same address or subnet. For example, an IPv6
   * representation of an IPv4 address versus its IPv4 representation.
   *
   * PARAMETERS
   *   host1      the network host, domain, or subnet to compare.
   *   host2      the network host, domain, or subnet to compare.
   * RETURN
   *   1 if the two hosts, domains, or subnets are equal. 0 when not equal.
   *   NULL when either of the hosts is NULL.
   * EXCEPTIONS
   *
   * NOTES
   *   This function does not perform domain name resolution when comparing
   * any host or domain for equality.
   */
  function equals_host(host1 in varchar2, host2 in varchar2) return number
    deterministic;
    pragma interface(C, equals_host);

  /*
   * Determines if the given host is equal to or contained in the given host,
   * domain, or subnet. For IP addresses and subnets, this function can handle
   * different representations of the same address or subnet. For example, an
   * IPv6 representation of an IPv4 address versus its IPv4 representation.
   *
   * PARAMETERS
   *   host       the network host.
   *   domain     the host, domain, or subnet.
   * RETURN
   *   A non-NULL value will be returned if the given host is equal to or
   *   contained in the given host, domain, or subnet:
   *     - if domain is a hostname, the level of its domain + 1 will be
   *       returned;
   *     - if domain is a domain name, the domain level will be returned;
   *     - if domain is an IP address or subnet, the number of significant
   *       address bits of the IP address or subnet will be returned;
   *     - if domain is the wildcard "*", 0 will be returned.
   *   The non-NULL value returned indicates the precedence of the domain or
   *   subnet for ACL assignment. The higher the value, the higher is the
   *   precedence. NULL will be returned if the host is not equal to or
   *   contained in the given host, domain or subnet. NULL will also be
   *   returned if either the host or domain is NULL.
   * EXCEPTIONS
   *   
   * NOTES
   *   This function does not perform domain name resolution when evaluating
   * any host or domain.
   */
  function contains_host(host in varchar2, domain in varchar2) return number
    deterministic;
    pragma interface(C, contains_host);

end;
/

grant execute on sys.dbms_network_acl_utility to public;

create or replace public synonym dbms_network_acl_utility
for sys.dbms_network_acl_utility;

@?/rdbms/admin/sqlsessend.sql
