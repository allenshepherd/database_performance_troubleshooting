Rem
Rem $Header: rdbms/admin/xdbud111.sql /main/3 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbud111.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbud111.sql - XDB Upgrade Dependent objects from 11.1.0
Rem
Rem    DESCRIPTION
Rem     This script upgrades the XDB dependent objects from release 11.1.0
Rem     to the current release.
Rem
Rem    NOTES
Rem     It is invoked by xdbud.sql, and invokes the xdbudNNN script for the 
Rem     subsequent release.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbud111.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbud111.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbud.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         07/25/16 - add file metadata
Rem    raeburns    02/02/14 - rename script
Rem    raeburns    10/25/13 - XDB upgrade restructure
Rem    raeburns    10/25/13 - Created

Rem ================================================================
Rem BEGIN XDB Dependent Object Upgrade from 11.1.0
Rem ================================================================

-- BEGIN from xdbu111.sql

/*-----------------------------------------------------------------------*/
/*  Upgrade XMLIndex type */
/*-----------------------------------------------------------------------*/

-- Support new partitioning methods
alter indextype XDB.xmlindex
  using XDB.XMLIndexMethods
  with local partition
  with system managed storage tables;

/*
 * Updates for XDB DEFAULT CONFIG
 */

-- (Re-)Insert the authentication element into xdbconfig.xml
declare
  auth_count      INTEGER := 0;
  auth_frag xmltype;
  cfg xmltype;
begin
   cfg := dbms_xdb.cfg_get();
   begin
   select 1 into auth_count from dual
    where XMLExists(
       'declare namespace c = "http://xmlns.oracle.com/xdb/xdbconfig.xsd";
        /c:xdbconfig/c:sysconfig/c:protocolconfig/c:httpconfig/c:authentication'
        PASSING cfg);
   exception 
     when no_data_found then null;
   end;
 
   -- enable INSERTXMLBEFORE, APPENDCHILDXML, DELETEXML(4)
   -- Turn on rewrite for updxml/delxml/insertxml over collections(128)
   execute immediate 
     'alter session set events ''19027 trace name context forever, level 132'' ';

   if auth_count = 0 then
     auth_frag := xmltype('<authentication xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"><allow-mechanism>basic</allow-mechanism><digest-auth><nonce-timeout>300</nonce-timeout></digest-auth></authentication>');
   else
     -- extract authentication fragment for later re-insertion
     dbms_output.put_line('authentication fragment existed, deleting');
     auth_frag := cfg.extract('/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication');
     select deletexml (cfg,
        '/c:xdbconfig/c:sysconfig/c:protocolconfig/c:httpconfig/c:authentication',
        'xmlns:c="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
     into cfg from dual;
   end if;

   dbms_output.put_line('inserting authentication fragment');
   select insertchildxml (cfg,
       '/c:xdbconfig/c:sysconfig/c:protocolconfig/c:httpconfig',
       'authentication',
       auth_frag,
       'xmlns:c="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
   into cfg from dual;
   dbms_output.put_line('updating xdbconfig doc');
   dbms_xdb.cfg_update(cfg); 
  end;
/

/*-----------------------------------------------------------------------*/
/*  Upgrade for Application user and roles support */
/*-----------------------------------------------------------------------*/
COLUMN :xdbapp_name NEW_VALUE xdbapp_file NOPRINT
VARIABLE xdbapp_name VARCHAR2(50)

declare
  stmt    varchar2(4000);
  cnt     number := 0;
begin
  :xdbapp_name := '@nothing.sql';
  stmt := 'select count(*) from dba_tables where (owner = ''' || 'XDB' ||
          ''') and (table_name = ''' || 'APP_USERS_AND_ROLES' || ''') '; 
  execute immediate stmt into cnt;
  if (cnt = 0) then
    :xdbapp_name := '@catxdbapp.sql';
  end if;

  exception
     when others then
      :xdbapp_name := '@nothing.sql'; 
end;
/
SELECT :xdbapp_name FROM DUAL;
@&xdbapp_file


-- add app users and groups virtual folders
declare
 ret boolean;
begin
  begin
    ret := 
      xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/users/application');
    if ret then
      dbms_xdb.setACL('/sys/principals/users/application', 
                      '/sys/acls/bootstrap_acl.xml');
      dbms_output.put_line('added app users');
    end if;
    
    exception
      when others then
        dbms_output.put_line('XDBNB: error adding app users');
  end;  

  begin
    ret := 
      xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/groups/application');
    if ret then
      dbms_xdb.setACL('/sys/principals/groups/application', 
                      '/sys/acls/bootstrap_acl.xml');
      dbms_output.put_line('added app groups');
    end if;

    exception
      when others then
        dbms_output.put_line('XDBNB: error adding app groups');
  end;
end;
/
commit;
--
-- During an upgrade of Application Express, the previous images directory is 
-- copied and renamed.  There are resources in the images directory shipped 
-- with Application Express 3.0 and DB 11.1.0.6 which were marked as
-- encoded in Shift JIS when, in fact, they were encoded in utf-8.  
-- Locate these resources and delete them
--
begin
    for c1 in (select any_path, extractvalue(res,'/Resource/CharacterSet/text()')
      from xdb.resource_view
     where any_path like '/images%'
       and (any_path like '%ja/toc.xml' or any_path like '%ja/TDPAX/toc.xml')
       and extractvalue(res,'/Resource/CharacterSet/text()') = 'SHIFT_JIS') 
     loop
      dbms_xdb.deleteresource( abspath => c1.any_path, delete_option => dbms_xdb.delete_force );
     end loop;
    commit;
end;
/


-- add Digest as an allowed authentication mechanism (the last in the list)
declare
  new_cfg         XMLTYPE;
  dcount          NUMBER := 0;
  snippet         VARCHAR2(1024);
begin
    select existsNode(dbms_xdb.cfg_get(),
      '/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication/allow-mechanism[text()="digest"]',
      'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
    into dcount from dual;

    if (dcount = 0) then
        snippet := '<allow-mechanism xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">digest</allow-mechanism>';
        select insertChildXML(dbms_xdb.cfg_get(), '/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication',
                              'allow-mechanism',
                              xmltype(snippet), 'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
        into new_cfg from dual;
        dbms_xdb.cfg_update(new_cfg);
        commit;
    end if;
end;
/

-- END from xdbu111.sql

Rem ================================================================
Rem END XDB Dependent Object from 11.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Dependent Object Upgrade from the next release
Rem ================================================================

@@xdbud112.sql

