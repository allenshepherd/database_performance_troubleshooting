Rem
Rem $Header: rdbms/admin/xsu112.sql /main/9 2017/05/28 22:46:14 stanaya Exp $
Rem xsu112.sql
Rem
Rem Copyright (c) 2008, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsu112.sql - XS Upgrade from 11.2
Rem
Rem    DESCRIPTION
Rem      This script upgrades XS from 11.2 to the current release
Rem
Rem    NOTES
Rem      Invoked from xsdbmig.sql and xsu111.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xsu112.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xsu112.sql
Rem    SQL_PHASE: UPGRADE 
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/11/17 - Bug 25790192: Add SQL_METADATA
Rem    minx        05/08/13 - Fix bug 16684412: drop extra XS packages and views
Rem    smierau     09/14/12 - move nacla112.sql from xsa112
Rem    smierau     09/04/12 - Add xs_olap_migration
Rem    minx        03/01/12 - Drop XS packages and views
Rem    minx        01/30/12 - Drop xdb.DOCUMENT_LINKS2
Rem    yiru        11/01/11 - Drop resconfig and principal/roleset schema
Rem    yiru        09/07/11 - drop xml index
Rem    yiru        03/13/08 - Created
Rem

Rem ======================================================================
Rem BEGIN XS upgrade from 11.2.0
Rem ======================================================================

Rem load XS_OBJECT_MIGRATION package
@@prvtconsacl.plb

Rem load XS_OLAP_MIGRATION package
@@prvtolapmig.plb

-- Do the OLAP migration before everything is dropped.
declare
  ct number;
begin
  execute immediate 'select count(*) from xdb.xs$data_security xds' into ct;
  dbms_output.put_line('count = ' || ct);
  xs_olap_migration.upgrade_ds(NULL, NULL);
exception
  when others then
  NULL;
end;
/

-- Migrate network ACLs from XDB (moved from xsa112)
@@nacla112.sql

-- Fix lrg 5472611,5133741(ORA-64131)
-- Drop the index through upgrade from 11.2 to 12.0 in the major release path
begin
  execute immediate 'drop index xdb.prin_xidx force';
exception
  when others then
  NULL;
end;
/

begin
  execute immediate 'drop index xdb.sc_xidx force';
exception
  when others then
  NULL;
end;
/

DECLARE
  slist XDB$STRING_LIST_T;
BEGIN  
  slist := dbms_resconfig.getRepositoryResConfigPaths();
  IF slist.count > 0 THEN    
    FOR i IN slist.first..slist.last
    LOOP         
      if slist(i) = '/sys/xs/userrc.xml' THEN
        DBMS_ResConfig.DeleteRepositoryResConfig(i-1);
      end if;     
    END LOOP;
  END IF;
EXCEPTION
  when others then
  NULL;
END;
/

DECLARE
  slist XDB$STRING_LIST_T;
BEGIN  
  slist := dbms_resconfig.getRepositoryResConfigPaths();
  IF slist.count > 0 THEN    
    FOR i IN slist.first..slist.last
    LOOP         
      if slist(i) = '/sys/xs/rolesetrc.xml' THEN
        DBMS_ResConfig.DeleteRepositoryResConfig(i-1);
      end if;     
    END LOOP;
  END IF;
EXCEPTION
  when others then
  NULL;
END;
/

DECLARE
  slist XDB$STRING_LIST_T;
BEGIN  
  slist := dbms_resconfig.getRepositoryResConfigPaths();
  IF slist.count > 0 THEN    
    FOR i IN slist.first..slist.last
    LOOP         
      if slist(i) = '/sys/xs/drolerc.xml' THEN
        DBMS_ResConfig.DeleteRepositoryResConfig(i-1);
      end if;     
    END LOOP;
  END IF;
EXCEPTION
  when others then
  NULL;
END;
/

DECLARE
  slist XDB$STRING_LIST_T;
BEGIN  
  slist := dbms_resconfig.getRepositoryResConfigPaths();
  IF slist.count > 0 THEN    
    FOR i IN slist.first..slist.last
    LOOP         
      if slist(i) = '/sys/xs/rolerc.xml' THEN
        DBMS_ResConfig.DeleteRepositoryResConfig(i-1);
      end if;     
    END LOOP;
  END IF;
EXCEPTION
  when others then
  NULL;
END;
/

DECLARE
  slist XDB$STRING_LIST_T;
BEGIN  
  slist := dbms_resconfig.getRepositoryResConfigPaths();
  IF slist.count > 0 THEN    
    FOR i IN slist.first..slist.last
    LOOP         
      if slist(i) = '/sys/xs/frolerc.xml' THEN
        DBMS_ResConfig.DeleteRepositoryResConfig(i-1);
      end if;     
    END LOOP;
  END IF;
EXCEPTION
  when others then
  NULL;
END;
/

DECLARE
  slist XDB$STRING_LIST_T;
BEGIN  
  slist := dbms_resconfig.getRepositoryResConfigPaths();
  IF slist.count > 0 THEN    
    FOR i IN slist.first..slist.last
    LOOP         
      if slist(i) = '/sys/xs/xdserc.xml' THEN
        DBMS_ResConfig.DeleteRepositoryResConfig(i-1);
      end if;     
    END LOOP;
  END IF;
EXCEPTION
  when others then
  NULL;
END;
/
DECLARE
  slist XDB$STRING_LIST_T;
BEGIN  
  slist := dbms_resconfig.getRepositoryResConfigPaths();
  IF slist.count > 0 THEN    
    FOR i IN slist.first..slist.last
    LOOP         
      if slist(i) = '/sys/xs/scrc.xml' THEN
        DBMS_ResConfig.DeleteRepositoryResConfig(i-1);
      end if;     
    END LOOP;
  END IF;
EXCEPTION
  when others then
  NULL;
END;
/



BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/userrc.xml')) then
    DBMS_XDB.deleteResource('/sys/xs/userrc.xml',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/rolesetrc.xml')) then
    DBMS_XDB.deleteResource('/sys/xs/rolesetrc.xml',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/drolerc.xml')) then
    DBMS_XDB.deleteResource('/sys/xs/drolerc.xml',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/rolerc.xml')) then
    DBMS_XDB.deleteResource('/sys/xs/rolerc.xml',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/frolerc.xml')) then
    DBMS_XDB.deleteResource('/sys/xs/frolerc.xml',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/roles')) then
    DBMS_XDB.deleteResource('/sys/xs/roles',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/users')) then
    DBMS_XDB.deleteResource('/sys/xs/users',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/xdse')) then
    DBMS_XDB.deleteResource('/sys/xs/xdse',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/securityclasses/securityclass')) then
    DBMS_XDB.deleteResource('/sys/xs/securityclasses/securityclass',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/securityclasses/securityclass.xml')) then
    DBMS_XDB.deleteResource('/sys/xs/securityclasses/securityclass.xml',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/securityclasses/baseSystemPrivileges.xml')) then
    DBMS_XDB.deleteResource('/sys/xs/securityclasses/baseSystemPrivileges.xml',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/securityclasses/baseDavPrivileges.xml')) then
    DBMS_XDB.deleteResource('/sys/xs/securityclasses/baseDavPrivileges.xml',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/securityclasses/systemPrivileges.xml')) then
    DBMS_XDB.deleteResource('/sys/xs/securityclasses/systemPrivileges.xml',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/securityclasses/dav.xml')) then
    DBMS_XDB.deleteResource('/sys/xs/securityclasses/dav.xml',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

BEGIN
  if (DBMS_XDB.existsResource('/sys/xs/securityclasses/principalsc.xml')) then
    DBMS_XDB.deleteResource('/sys/xs/securityclasses/principalsc.xml',DBMS_XDB.DELETE_RECURSIVE_FORCE);
  end if;
EXCEPTION 
  when others then
  NULL;
END;
/

DECLARE
  is_reg NUMBER := 0;
BEGIN
 select 1 into is_reg from dba_xml_schemas 
 where schema_url= 'http://xmlns.oracle.com/xs/principal.xsd';

 IF is_reg = 1 THEN 
   dbms_xmlschema.deleteSchema('http://xmlns.oracle.com/xs/principal.xsd',
                               dbms_xmlschema.delete_cascade_force);
 END IF;
  exception
  when others then
  NULL; 
END;
/

DECLARE
  is_reg NUMBER:= 0;
BEGIN
  select 1 into is_reg from dba_xml_schemas 
  where schema_url= 'http://xmlns.oracle.com/xs/roleset.xsd';

  IF is_reg = 1 THEN 
    dbms_xmlschema.deleteSchema('http://xmlns.oracle.com/xs/roleset.xsd',
                                dbms_xmlschema.delete_cascade_force);
  END IF;
EXCEPTION
  when others then
  NULL;  
END;
/

DECLARE
  is_reg NUMBER:= 0;
BEGIN
  select 1 into is_reg from dba_xml_schemas 
  where schema_url= 'http://xmlns.oracle.com/xs/dataSecurity.xsd';

  IF is_reg = 1 THEN 
    dbms_xmlschema.deleteSchema('http://xmlns.oracle.com/xs/dataSecurity.xsd',
                                dbms_xmlschema.delete_cascade_force);
  END IF;
EXCEPTION
  when others then
  NULL;  
END;
/

DECLARE
  is_reg NUMBER:= 0;
BEGIN
  select 1 into is_reg from dba_xml_schemas 
  where schema_url= 'http://xmlns.oracle.com/xs/aclids.xsd';

  IF is_reg = 1 THEN 
    dbms_xmlschema.deleteSchema('http://xmlns.oracle.com/xs/aclids.xsd',
                                dbms_xmlschema.delete_cascade_force);
  END IF;
EXCEPTION
  when others then
  NULL;  
END;
/

DECLARE
  is_reg NUMBER:= 0;
BEGIN
  select 1 into is_reg from dba_xml_schemas 
  where schema_url= 'http://xmlns.oracle.com/xs/securityclass.xsd';

  IF is_reg = 1 THEN 
    dbms_xmlschema.deleteSchema('http://xmlns.oracle.com/xs/securityclass.xsd',
                                dbms_xmlschema.delete_cascade_force);
  END IF;
EXCEPTION
  when others then
  NULL;  
END;
/

DECLARE
  is_reg NUMBER:= 0;
BEGIN
  execute immediate 'drop package dbms_xs_roleset_events_int';
EXCEPTION
  when others then
  NULL;  
END;
/



BEGIN
  execute immediate 'drop package dbms_xs_principal_events_int';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop package dbms_xs_date_security_events_int';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop package dbms_xs_secclass_events_int';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop package DBMS_XS_SECCLASS_EVENTS';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop public synonym DOCUMENT_LINKS2';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop view xdb.DOCUMENT_LINKS2';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop public synonym ALL_XS_SECURITYCLASSES';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop view xdb.all_xs_securityclasses';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop public synonym ALL_XS_SECURITYCLASSE_DEP';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop view xdb.all_xs_securityclasse_dep';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop public synonym ALL_XS_PRIVS';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop view xdb.all_xs_privs';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop public synonym ALL_XS_AGGR_PRIVS';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop view xdb.all_xs_aggr_privs';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop table XDB.XS$CACHE_ACTIONS';
EXCEPTION
  when others then
  NULL;
END;
/

BEGIN
  execute immediate 'drop table XDB.XS$CACHE_DELETE';
EXCEPTION
  when others then
  NULL;
END;
/



--Drop XS olap migration package
drop public synonym xs_olap_migration;
drop package  xs_olap_migration;

--Drop XS object migration package
drop public synonym xs_object_migration;
drop package  xs_object_migration;

--Bug16684412: drop extra packages
drop package DBMS_XDSUTL;
drop public synonym DBMS_XDSUTL;
drop package DBMS_XS_DATA_SECURITY_EVENTS;
drop public synonym DBMS_XS_DATA_SECURITY_EVENTS;
drop package DBMS_XS_SECCLASS_INT;
drop public synonym DBMS_XS_SECCLASS_INT;
drop package DBMS_XS_SECCLASS_INT_FFI;
drop public synonym DBMS_XS_SECCLASS_INT_FFI; 

--Drop XDS views
drop public synonym DBA_XDS_OBJECTS;
drop public synonym ALL_XDS_OBJECTS;
drop public synonym USER_XDS_OBJECTS;
drop public synonym DBA_XDS_INSTANCE_SETS;
drop public synonym ALL_XDS_INSTANCE_SETS;
drop public synonym USER_XDS_INSTANCE_SETS;
drop public synonym DBA_XDS_ATTRIBUTE_SECS;
drop public synonym ALL_XDS_ATTRIBUTE_SECS;
drop public synonym USER_XDS_ATTRIBUTE_SECS;
 
   
drop view sys.DBA_XDS_OBJECTS;
drop view sys.ALL_XDS_OBJECTS;
drop view sys.USER_XDS_OBJECTS;
drop view sys.DBA_XDS_INSTANCE_SETS;
drop view sys.ALL_XDS_INSTANCE_SETS;
drop view sys.USER_XDS_INSTANCE_SETS;
drop view sys.DBA_XDS_ATTRIBUTE_SECS;
drop view sys.ALL_XDS_ATTRIBUTE_SECS;
drop view sys.USER_XDS_ATTRIBUTE_SECS;
 
   

Rem ======================================================================
Rem END XS upgrade from 11.2.0 
Rem ======================================================================
