Rem
Rem $Header: rdbms/admin/xdbed111.sql /main/3 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbed111.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbed111.sql - XDB Dependent object downgrade
Rem
Rem    DESCRIPTION
Rem      This script downgrades XDB Dependent objects to 11.1.0
Rem
Rem    NOTES
Rem      It is invoked from the top-level XDB downgrade script (xdbe111.sql)
Rem      and from the 10.2 data downgrade script (xdbeu102.sql)
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbed111.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbed111.sql 
Rem    SQL_PHASE: DOWNGRADE 
Rem    SQL_STARTUP_MODE: DOWNGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbe111.sql 
Rem    END SQL_FILE_METADATA
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use DOWNGRADE for SQL_PHASE
Rem    qyu         07/25/16 - add file metadata
Rem    raeburns    02/02/14 - rename for new structure
Rem    juding      07/29/11 - bug 12622803: xdbeu112.sql already invoked
Rem    yxie        05/06/11 - add downgrade from 11.2 release
Rem    spetride    06/15/10 - disable Digest HTTP auth on downgrade
Rem    bhammers    11/19/09 - 8760324, clear 'Unstructured Present' flag
Rem                           when downgrading XIDX from 11.2.0.2 to 11.1.0.7
Rem    spetride    07/29/09 - more custom authentication and trust data 
Rem                           downgrade
Rem    spetride    02/16/09 - remove all Expire mappings in xdbconfig
Rem    atabar      02/06/09 - xdbconfig default-type-mappings downgrade
Rem    spetride    08/07/08 - remove allow-mechanism:custom and 
Rem                           allow-authentication-trust
Rem                         - downgrade for app users and roles
Rem    rburns      11/06/07 - 11.1 data downgrade
Rem    rburns      11/06/07 - Created


Rem ================================================================
Rem BEGIN XDB Dependent Object downgrade to 11.2.0
Rem ================================================================

-- downgrade to 11.2.0 release
@@xdbed112.sql

Rem ================================================================
Rem END XDB Dependent Object downgrade to 11.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Dependent Object downgrade to 11.1.0
Rem ================================================================

-- downgrade for Application user and roles support
declare
  stmt    varchar2(4000);
  cnt     number := 0;
begin
  stmt := 'select count(*) from dba_tables where (owner = ''' || 'XDB' ||
          ''') and (table_name = ''' || 'APP_USERS_AND_ROLES' || ''') '; 
  execute immediate stmt into cnt;
  if (cnt > 0) then
    execute immediate 'drop table XDB.APP_USERS_AND_ROLES';
  end if;
  stmt := 'select count(*) from dba_tables where (owner = ''' || 'XDB' ||
          ''') and (table_name = ''' || 'APP_ROLE_MEMBERSHIP' || ''') '; 
  execute immediate stmt into cnt;
  if (cnt > 0) then
    execute immediate 'drop table XDB.APP_ROLE_MEMBERSHIP';
  end if;
end;
/

-- XDB CONFIG Data downgrade
create or replace procedure xdbConfigDataDowngrade(path varchar2) as
  new_cfg         XMLTYPE;      
  cexists         NUMBER := 0;
begin
  select existsNode(dbms_xdb.cfg_get(), path, 
                    'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') 
    into cexists from dual;  
  if (cexists > 0) then
    select deletexml(dbms_xdb.cfg_get(), path,
                     'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
    into new_cfg from dual;

    dbms_xdb.cfg_update(new_cfg);  
    commit;   
  end if;
end xdbConfigDataDowngrade;
/

show errors;

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication/allow-mechanism[text()="custom"]');

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/allow-authentication-trust');

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/default-type-mappings');

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/protocolconfig/httpconfig/expire');

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/protocolconfig/httpconfig/custom-authentication');

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/custom-authentication-trust');

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/localApplicationGroupStore');

drop procedure xdbConfigDataDowngrade;

-- remove Digest as an allowed HTTP authentication mechanism
declare
  new_cfg         XMLTYPE;      
  dcount          NUMBER := 0; 
  bcount          NUMBER := 0; 
  snippet         VARCHAR2(1024);
begin
  select existsNode(dbms_xdb.cfg_get(),
    '/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication/allow-mechanism[text()="digest"]',
    'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') 
  into dcount from dual;

  if (dcount = 0 ) then
    return;
  end if;

  select existsNode(dbms_xdb.cfg_get(),
    '/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication/allow-mechanism[text()="basic"]',
    'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') 
  into bcount from dual;

  if (bcount = 0) then
    -- add Basic as allowed mechanism, since we will remove Digest and at least
    -- one authentication mechanism is required
    snippet := '<allow-mechanism xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">basic</allow-mechanism>';
    select insertChildXML(dbms_xdb.cfg_get(), '/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication',
                         'allow-mechanism',
                         xmltype(snippet), 'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
    into new_cfg from dual;
    dbms_xdb.cfg_update(new_cfg);
  end if;

  -- remove Digest
  select deletexml(dbms_xdb.cfg_get(), 
                   '/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication/allow-mechanism[text()="digest"]',
                   'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
  into new_cfg from dual;
  dbms_xdb.cfg_update(new_cfg); 
  commit; 
end;
/


begin
-- clear 'UNSTRUCTURED PRESENT' flag for all XML indexes 
execute immediate 'UPDATE xdb.xdb$dxptab 
                   SET flags = flags - 268435456 
                   WHERE bitand(flags, 268435456) = 268435456';
exception
  when others then dbms_output.put_line('XDBNB: flag update failed');
end;
/

-- 1st pass to remove the post-11.2+ SYNCSCN
update xdb.xdb$dxptab set parameters =
  deleteXML(parameters,'/parameters/async/syncscn');
-- 2nd pass to remove NULL ASYNC, w/o the SYNC_JOB_NAME, INTERVAL, ...
update xdb.xdb$dxptab set parameters =
  deleteXML(parameters,'/parameters/async')
  where extractvalue(parameters, '/parameters/async') is null;
commit;

Rem ================================================================
Rem END XDB Dependent Object downgrade to 11.1.0
Rem ================================================================
