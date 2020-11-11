Rem
Rem
Rem xdbed112.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbed112.sql - XDB Dependent Object downgrade
Rem
Rem    DESCRIPTION
Rem      This script downgrades XDB dependent objects to 11.2.0
Rem
Rem    NOTES
Rem      It is invoked from the top-level XDB downgrade script (xdbdwgrd.sql)
Rem      and from the 11.1 data downgrade script (xdbeu111.sql)
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbed112.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbed112.sql 
Rem    SQL_PHASE: DOWNGRADE 
Rem    SQL_STARTUP_MODE: DOWNGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbdwgrd.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    qyu         07/25/16 - add file metadata
Rem    sriksure    07/20/16 - Bug 22967968 - Moving inline XML schemas to
Rem                           external schema files
Rem    joalvizo    04/13/16 - RTI 19388120: Add dbms_xdb.deleteresource
Rem    raeburns    02/02/14 - add 12.1 downgrade and rename scripts
Rem    prthiaga    08/16/13 - Bug 17322893 - Remove any host-name elements from
Rem                           xdbconfig
Rem    prthiaga    10/26/12 - LRG-7246788: No need to re-register xmltr schema
Rem    stirmizi    04/11/12 - re-register xdblog, ftplog, httplog, xmltr
Rem    stirmizi    04/11/12 - re-create xdb$workspace
Rem    stirmizi    04/11/12 - registration of XInclude.xsd added
Rem    molagapp    16/08/11 - lrg# 5062435
Rem    juding      07/29/11 - bug 12622803: move
Rem                                         drop function sys.getUserIdOnTarget
Rem                                         to xdbes112.sql
Rem    juding      07/29/11 - bug 12622803: add split of xdbe112.sql
Rem    thbaby      07/21/11 - remove white-list
Rem    swerthei    06/23/11 - recovery server downgrade
Rem    spetride    06/20/11 - drop sys.getUserIdOnTarget
Rem    yxie        05/06/11 - remove em express servlet
Rem    yxie        05/06/11 - Created

Rem ================================================================
Rem BEGIN XDB Dependent Object downgrade to 12.1.0
Rem ================================================================

@@xdbed121.sql

Rem ================================================================
Rem END XDB Dependent Object downgrade to 12.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Dependent Object downgrade to 11.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB downgrade for XDB Repository export/ import
Rem ================================================================

create or replace type sv as varray(18) of varchar2(2000);
/

declare
  stmt_tbl   sv := sv('XDB.XDB$SCHEMA_EXPORT_VIEW_TBL',
                      'XDB.XDB$RESOURCE_EXPORT_VIEW_TBL',
                      'DBA_TYPE_XMLSCHEMA_DEP_TBL',
                      'DBA_XML_SCHEMA_DEPENDENCY_TBL',
                      'xdb.xdb$simple_type_view_tbl',
                      'xdb.xdb$complex_type_view_tbl',
                      'xdb.xdb$all_model_view_tbl',
                      'xdb.xdb$choice_model_view_tbl',
                      'xdb.xdb$sequence_model_view_tbl',
                      'xdb.xdb$group_def_view_tbl',
                      'xdb.xdb$group_ref_view_tbl',
                      'xdb.xdb$attribute_view_tbl',
                      'xdb.xdb$element_view_tbl',
                      'xdb.xdb$any_view_tbl',
                      'xdb.xdb$anyattr_view_tbl',
                      'xdb.xdb$attrgroup_def_view_tbl',
                      'xdb.xdb$attrgroup_ref_view_tbl',
                      'SYS.XML_TABNAME2OID_VIEW_TBL');
  stmt_view  sv := sv('XDB.XDB$SCHEMA_EXPORT_VIEW',
                      'XDB.XDB$RESOURCE_EXPORT_VIEW',
                      'DBA_TYPE_XMLSCHEMA_DEP',
                      'xdb.xdb$simple_type_view',
                      'xdb.xdb$complex_type_view',
                      'xdb.xdb$all_model_view',
                      'xdb.xdb$choice_model_view',
                      'xdb.xdb$sequence_model_view',
                      'xdb.xdb$group_def_view',
                      'xdb.xdb$group_ref_view',
                      'xdb.xdb$attribute_view',
                      'xdb.xdb$element_view',
                      'xdb.xdb$any_view',
                      'xdb.xdb$anyattr_view',
                      'xdb.xdb$attrgroup_def_view',
                      'xdb.xdb$attrgroup_ref_view',
                      'SYS.XML_TABNAME2OID_VIEW');
  i      number;
  stmt   varchar2(2000);
  previous_version varchar2(30);
begin
  select prv_version into previous_version
  from registry$
  where cid = 'XDB';

  /* If XDB was installed during a upgrade, previous_version will be NULL.
   * When that happens, get previous_version from CATPROC.
   */
  if previous_version is NULL
  then
    select prv_version into previous_version
    from registry$
    where cid = 'CATPROC';
  end if;

  if not (previous_version like '11.2.0.2%' or
          previous_version like '11.2.0.1%' or
          previous_version like '11.2.0.0%' or
          previous_version like '11.1%' or
          previous_version like '11.0%' or
          previous_version like '10.%' or
          previous_version like '9.%')
  then
    return;
  end if;

  for i in 1..18 loop
    begin
      stmt := 'drop table ' || upper(stmt_tbl(i));
      --dbms_output.put_line(stmt);
      execute immediate stmt;
      exception
         when OTHERS then
            null;
    end; 
  end loop;
  for i in 1..17 loop
    begin
      stmt := 'drop view ' || upper(stmt_view(i));
      --dbms_output.put_line(stmt);
      execute immediate stmt;
      exception
         when OTHERS then
            null;
    end;    
  end loop;

  begin
    stmt := 'delete from sys.impcalloutreg$ where tgt_schema = ''' || 
            'XDB' || ''' ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
  begin
    stmt := 'delete from sys.exppkgact$ where package = ''' || 
            'DBMS_XDBUTIL_INT' || ''' and schema=''' || 'XDB' || ''' ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
end;
/

begin
  execute immediate 'drop type sv';
exception
   when others then
     NULL;
end;
/


Rem ================================================================
Rem END XDB downgrade for XDB Repository export/ import
Rem ================================================================

Rem ==== Create xdb.xdb$workspace ==================================
declare
  exist number;
begin
  select count(*) into exist from DBA_TABLES where table_name = 'XDB$WORKSPACE'
  and owner = 'XDB';

  if exist = 0 then
    execute immediate
        'create table xdb.xdb$workspace(wsname        varchar2(1024),
                                        wsid          raw(16),
                                        vr_wsid       raw(16),
                                        flags         raw(4),
                                        vh_bitmap     blob,
                                        res_bitmap    blob,
                                        vh_to_res_map blob,
                                        checkout_set  blob)';
  end if;
end;
/

Rem ================================================================
Rem BEGIN XDBCONFIG file downgrade
Rem ================================================================

Rem
Rem Add report framework servlet and delete EM Express servlet
Rem

declare
  cfg_data XMLTYPE;
  scount   NUMBER := 0;
begin
  cfg_data := dbms_xdb.cfg_get();

  -- Add Report framework servlet mapping
  SELECT existsNode(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-mappings/' ||
                'servlet-mapping[servlet-name=''ReportFmwkServlet'']')  
    INTO scount 
    FROM dual;

  IF (scount = 0) THEN
    SELECT appendchildxml(
                cfg_data, 
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-mappings', 
                xmltype(
                  '<servlet-mapping xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">  
                     <servlet-pattern>/orarep/*</servlet-pattern>
                     <servlet-name>ReportFmwkServlet</servlet-name>
                   </servlet-mapping>'))
      INTO cfg_data
      FROM dual;
  END IF;

  -- Add Report framework servlet 
  SELECT existsNode(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-list/' ||
                'servlet[servlet-name=''ReportFmwkServlet'']')
    INTO scount 
    FROM dual;

  IF (scount = 0) THEN
    SELECT appendchildxml(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-list',
                xmltype(
                  '<servlet xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">
                     <servlet-name>ReportFmwkServlet</servlet-name>
                     <servlet-language>C</servlet-language>
                     <display-name>REPT</display-name>
                     <description>Servlet for accessing reports</description>
                     <security-role-ref>
                       <role-name>authenticatedUser</role-name>
                       <role-link>authenticatedUser</role-link>
                     </security-role-ref>
                   </servlet>'))
      INTO cfg_data
      FROM dual;
  END IF;


  -- Delete EM Express servlet mapping
  SELECT existsNode(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-mappings/' ||
                'servlet-mapping[servlet-name=''EMExpressServlet'']')  
    INTO scount 
    FROM dual;

  IF (scount = 1) THEN
    SELECT deleteXML(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-mappings/' ||
                'servlet-mapping[servlet-name=''EMExpressServlet'']')
      INTO cfg_data
      FROM dual; 
  END IF;


  -- Delete EM Express serlvet
  SELECT existsNode(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-list/' ||
                'servlet[servlet-name=''EMExpressServlet'']')
    INTO scount 
    FROM dual;

  IF (scount = 1) THEN
    SELECT deleteXML(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-list/' ||
                'servlet[servlet-name=''EMExpressServlet'']')
       INTO cfg_data
       FROM dual; 
  END IF;

  SELECT existsNode(
            cfg_data,
            '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
            '/servletconfig/servlet-mappings/' ||
            'servlet-mapping[servlet-name=''ORSServlet'']')
    INTO scount 
    FROM dual;

  IF (scount = 1) THEN
    SELECT deleteXML(
             cfg_data,
             '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
             '/servletconfig/servlet-mappings/' ||
             'servlet-mapping[servlet-name=''ORSServlet'']')
    INTO   cfg_data
    FROM   dual;
  END IF;

  SELECT existsNode(
            cfg_data,
            '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
            '/servletconfig/servlet-list/' ||
            'servlet[servlet-name=''ORSServlet'']')
    INTO scount 
    FROM dual;

  IF (scount = 1) THEN
    SELECT deleteXML(
              cfg_data,
              '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
              '/servletconfig/servlet-list/' ||
              'servlet[servlet-name=''ORSServlet'']')
    INTO   cfg_data
    FROM   dual;
  END IF;

  -- update xdbconfig file
  dbms_xdb.cfg_update(cfg_data);

end;
/

COMMIT;

Rem
Rem Remove white-list
Rem

declare
  cfg_data XMLTYPE;
  scount   NUMBER := 0;
begin
  cfg_data := dbms_xdb.cfg_get();
  SELECT existsNode(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/white-list')
    INTO scount 
    FROM dual;

  IF (scount = 1) THEN
    SELECT deleteXML(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/white-list')
       INTO cfg_data
       FROM dual; 
  END IF;

  -- update xdbconfig file
  dbms_xdb.cfg_update(cfg_data);

end;
/

COMMIT;

-- XDB CONFIG Data downgrade to remove host-name element
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

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/protocolconfig/ftpconfig/host-name');

-- clean up
drop procedure xdbConfigDataDowngrade;

@@catxdbh

begin
dbms_metadata_hack.cre_dir();
end;
/

-- Register standard schemas (catxdbst.sql)
declare
 c      NUMBER;
 XLURL VARCHAR2(2000) :=
  'http://xmlns.oracle.com/xdb/log/xdblog.xsd';
 FLURL VARCHAR2(2000) :=
  'http://xmlns.oracle.com/xdb/log/ftplog.xsd';
 HLURL VARCHAR2(2000) :=
  'http://xmlns.oracle.com/xdb/log/httplog.xsd';

 XLXSD BFILE := dbms_metadata_hack.get_bfile('xdblog.xsd');
 FLXSD BFILE := dbms_metadata_hack.get_bfile('ftplog.xsd');
 HLXSD BFILE := dbms_metadata_hack.get_bfile('httplog.xsd');

begin
  select count(*) into c from xdb.xdb$schema s
  where s.xmldata.schema_url = XLURL;
  if c = 0 then
    xdb.dbms_xmlschema.registerSchema(XLURL, XLXSD, FALSE, FALSE, FALSE,
                                      FALSE, FALSE, 'XDB');
  end if;

  select count(*) into c from xdb.xdb$schema s
  where s.xmldata.schema_url = FLURL;
  if c = 0 then
    xdb.dbms_xmlschema.registerSchema(FLURL, FLXSD, FALSE, FALSE, FALSE,
                                      FALSE, FALSE, 'XDB');
  end if;

  select count(*) into c from xdb.xdb$schema s
  where s.xmldata.schema_url = HLURL;
  if c = 0 then
    xdb.dbms_xmlschema.registerSchema(HLURL, HLXSD, FALSE, FALSE, FALSE,
                                      FALSE, FALSE, 'XDB');
  end if;
end;
/

-- Register OR version of XInclude.xsd
declare
  c number;
  schema_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_exists,-31085);
  XINCLUDEXSD BFILE := dbms_metadata_hack.get_bfile('xinclude.xsd.11.2');
  XINCLUDEURL VARCHAR2(2000) := 'http://www.w3.org/2001/XInclude.xsd';

begin

select count(*) into c
from resource_view
where equals_path(RES, '/sys/schemas/PUBLIC/www.w3.org/2001/XInclude.xsd')=1;

if c = 0 then
  xdb.dbms_xmlschema.registerSchema(XINCLUDEURL, XINCLUDEXSD, FALSE, FALSE,
                                    FALSE, FALSE, FALSE, 'XDB');
end if;

exception
  when schema_exists then
    NULL;
end;
/

declare                                                                          
  dbfs_path varchar2(4000) :=NULL; 
  num_entries  NUMBER; 
  tab_exists  number; 
begin 
  select count(*) into tab_exists from DBA_TABLES where table_name ='XDB$DBFS_VIRTUAL_FOLDER' and owner ='XDB';
  if tab_exists = 1 then 
    -- dbfs_virtual_folder is supported on only one folder. 
    -- Do nothing if the folder is not present 
    select count(*) into num_entries from xdb.xdb$dbfs_virtual_folder where hidden_def = 1;
    if num_entries = 1 then 
      select mount_path into dbfs_path from xdb.xdb$dbfs_virtual_folder where hidden_def = 1;
      dbms_xdb.deleteresource(abspath => dbfs_path, delete_option => dbms_xdb.delete_force );
    end if; 
  end if; 
end; 
/ 
commit; 

Rem ================================================================
Rem END XDBCONFIG file downgrade
Rem ================================================================

Rem ================================================================
Rem END XDB Dependent Object downgrade to 11.2.0
Rem ================================================================


