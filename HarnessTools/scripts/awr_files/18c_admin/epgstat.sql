Rem
Rem $Header: rdbms/admin/epgstat.sql /main/4 2017/05/28 22:46:05 stanaya Exp $
Rem
Rem epgstat.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      epgstat.sql - Embedded PL/SQL Gateway Status
Rem
Rem    DESCRIPTION
Rem      This script shows various status of the embedded PL/SQL gateway and
Rem      the XDB HTTP listener.
Rem
Rem    NOTES
Rem      This script should be run by a user with XDBADMIN and DBA roles.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/epgstat.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/epgstat.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       11/12/15 - Use standard xquery
Rem    rpang       11/22/06 - Show authentication schemes
Rem    rpang       10/31/06 - Created
Rem

set echo      off
set feedback  on
set numwidth  10
set linesize  80
set trimspool on
set tab       off
set pagesize  100

PROMPT +--------------------------------------+
PROMPT | XDB protocol ports:                  |
PROMPT |  XDB is listening for the protocol   |
PROMPT |  when the protocol port is non-zero. |
PROMPT +--------------------------------------+

COLUMN http_port FORMAT 99999 HEADING 'HTTP Port'
COLUMN ftp_port  FORMAT 99999 HEADING 'FTP Port'

select dbms_xdb_config.gethttpport http_port,
       dbms_xdb_config.getftpport ftp_port
  from dual;

PROMPT +---------------------------+
PROMPT | DAD virtual-path mappings |
PROMPT +---------------------------+

COLUMN vpath    FORMAT a32 HEADING 'Virtual Path'
COLUMN dad_name FORMAT a32 HEADING 'DAD Name'

select map.vpath, map.dad_name
  from xmltable(
         xmlnamespaces(default 'http://xmlns.oracle.com/xdb/xdbconfig.xsd'), 
         '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig/servletconfig'
         passing dbms_xdb_config.cfg_get
         columns
           mappings xmltype path 'servlet-mappings',
           list     xmltype path 'servlet-list') cfg,
       xmltable(
         xmlnamespaces(default 'http://xmlns.oracle.com/xdb/xdbconfig.xsd'), 
         '/servlet-mappings/servlet-mapping'
         passing cfg.mappings
         columns
           vpath    varchar2(4000) path 'servlet-pattern',
           dad_name varchar2(4000) path 'servlet-name') map,
       xmltable(
         xmlnamespaces(default 'http://xmlns.oracle.com/xdb/xdbconfig.xsd'), 
         '/servlet-list/servlet[servlet-language="PL/SQL"]'
         passing cfg.list
         columns
           dad_name varchar2(4000) path 'servlet-name') dad
 where map.dad_name = dad.dad_name
 order by vpath;

PROMPT +----------------+
PROMPT | DAD attributes |
PROMPT +----------------+

COLUMN dad_name    FORMAT a12 HEADING 'DAD Name'
COLUMN param_name  FORMAT a24 HEADING 'DAD Param'
COLUMN param_value FORMAT a40 HEADING 'DAD Value'
BREAK ON dad_name

select dad_name, param_name, param_value
  from xmltable(
         xmlnamespaces(default 'http://xmlns.oracle.com/xdb/xdbconfig.xsd'), 
         '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig/servletconfig/servlet-list/servlet[servlet-language="PL/SQL"]'
         passing dbms_xdb_config.cfg_get
         columns
           dad_name    varchar2(4000) path 'servlet-name',
           params      xmltype        path 'plsql') dad,
       xmltable(
         xmlnamespaces(default 'http://xmlns.oracle.com/xdb/xdbconfig.xsd'), 
         '/plsql/*'
         passing dad.params
         columns
           param_name  varchar2(4000) path 'name()',
           param_value varchar2(4000) path '.') param
 order by dad_name;

PROMPT +---------------------------------------------------+
PROMPT | DAD authorization:                                |
PROMPT |  To use static authentication of a user in a DAD, |
PROMPT |  the DAD must be authorized for the user.         |
PROMPT +---------------------------------------------------+

COLUMN dad_name FORMAT a32 HEADING 'DAD Name'
COLUMN username FORMAT a32 HEADING 'User Name'

select dad_name, username from dba_epg_dad_authorization order by dad_name;

PROMPT +----------------------------+
PROMPT | DAD authentication schemes |
PROMPT +----------------------------+

COLUMN dad_name FORMAT a20 HEADING 'DAD Name'
COLUMN username FORMAT a32 HEADING 'User Name'
COLUMN auth     FORMAT a18 HEADING 'Auth Scheme'

select cfg.dad_name, cfg.username,
       case when cfg.username = 'ANONYMOUS'      then 'Anonymous'
            when auth.username is null then
                 (case when cfg.username is null then 'Dynamic'
                       else                           'Dynamic Restricted' end)
            else                                      'Static' end auth
  from xmltable(
         xmlnamespaces(default 'http://xmlns.oracle.com/xdb/xdbconfig.xsd'), 
         '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig/servletconfig/servlet-list/servlet[servlet-language="PL/SQL"]'
         passing dbms_xdb_config.cfg_get
         columns
           dad_name varchar2(4000) path 'servlet-name',
           username varchar2(4000) path 'plsql/database-username') cfg,
       dba_epg_dad_authorization auth
 where cfg.dad_name = auth.dad_name(+) and
       cfg.username = auth.username(+)
 order by cfg.dad_name;

PROMPT +--------------------------------------------------------+
PROMPT | ANONYMOUS user status:                                 |
PROMPT |  To use static or anonymous authentication in any DAD, |
PROMPT |  the ANONYMOUS account must be unlocked.               |
PROMPT +--------------------------------------------------------+

COLUMN username       FORMAT a15 HEADING 'Database User'
COLUMN account_status FORMAT a20 HEADING 'Status'

select username, account_status from dba_users
 where username = 'ANONYMOUS';

PROMPT +-------------------------------------------------------------------+
PROMPT | ANONYMOUS access to XDB repository:                               |
PROMPT |  To allow public access to XDB repository without authentication, |
PROMPT |  ANONYMOUS access to the repository must be allowed.              |
PROMPT +-------------------------------------------------------------------+

COLUMN anonymous_access FORMAT a34 HEADING 'Allow repository anonymous access?'

select nvl(anonymous_access, 'false') anonymous_access
  from xmltable(
         xmlnamespaces(default 'http://xmlns.oracle.com/xdb/xdbconfig.xsd'), 
         '/xdbconfig/sysconfig/protocolconfig/httpconfig'
         passing dbms_xdb_config.cfg_get
         columns
           anonymous_access varchar2(4000)
             path 'allow-repository-anonymous-access');
