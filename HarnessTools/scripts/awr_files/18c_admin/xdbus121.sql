Rem
Rem $Header: rdbms/admin/xdbus121.sql /main/8 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbus121.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbus121.sql - XDB Upgrade Schemas from 12.1.0
Rem
Rem    DESCRIPTION
Rem      This script upgrades the XDB schemas from release 12.1.0
Rem      to the current release.
Rem
Rem    NOTES
Rem     It is invoked by xdbus.sql, and invokes the xdbusNNN script for the 
Rem     subsequent release.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbus121.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbus121.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbus.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         11/10/16 - invoke xdbus122.sql
Rem    qyu         07/25/16 - add file metadata
Rem    raeburns    02/26/16 - Bug 22682005: xdb$annotation_t long identifier
Rem    ckavoor     01/21/15 - 18938910:Upgrade schema_for_schemas
Rem    hxzhang     11/17/15 - bug#21525058, drop bitmap index
Rem    dmelinge    11/17/14 - SetRemoteHttpPort, SR 38986558561
Rem    raeburns    10/25/13 - XDB upgrade restructure
Rem    raeburns    10/25/13 - Created


Rem ================================================================
Rem BEGIN XDB Schema Upgrade from 12.1.0
Rem ================================================================

Rem Remote ports not stored in xdbconfig, but they are in root_info.
DECLARE
  alreadyexist_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT(alreadyexist_ex, -1430);
BEGIN
  EXECUTE IMMEDIATE 'alter table xdb.xdb$root_info add (
    rhttp_port number(5),
    rhttp_protocol varchar2(4000),
    rhttp_host varchar2(4000),
    rhttps_port number(5),
    rhttps_protocol varchar2(4000),
    rhttps_host varchar2(4000))';

  EXECUTE IMMEDIATE 'create or replace force view xdb.xdb$root_info_v
    as select * from xdb.xdb$root_info';
  EXECUTE IMMEDIATE 'grant select on xdb.xdb$root_info_v to public';

  EXCEPTION WHEN alreadyexist_ex THEN NULL;
END;
/
show errors;

/* bug#21525058, drop bitmap index */
BEGIN
 execute immediate 
 'drop index xdb.xdb$element_global';
 EXCEPTION WHEN OTHERS THEN NULL;
END;
/
SET SERVEROUTPUT ON

-- ANNOTATION_ID
declare
  xdb_schema_ref           REF XMLTYPE;
  xdbannotationid_ref      REF XMLTYPE;
  attlist                  XDB.XDB$XMLTYPE_REF_LIST_T := XDB.XDB$XMLTYPE_REF_LIST_T();
  xdb_schema_url           VARCHAR2(100);
  PN_RES_TOTAL_PROPNUMS    CONSTANT INTEGER := 277;
  PN_ANNOTATION_ID         CONSTANT INTEGER := 276;
  num_props                number;
  c                        integer := 0;
begin
  xdb_schema_url := 'http://xmlns.oracle.com/xdb/XDBSchema.xsd';

  select ref(s) into xdb_schema_ref from xdb.xdb$schema s where
    s.xmldata.schema_url = xdb_schema_url;

  select s.xmldata.num_props into num_props from xdb.xdb$schema s
    where ref(s) = xdb_schema_ref;

  if(num_props != PN_RES_TOTAL_PROPNUMS) then
    dbms_output.put_line('upgrading schema for schemas for 12.2');

    select count ( e.xmldata.name ) into c
        from xdb.xdb$attribute e, xdb.xdb$schema s
        where s.xmldata.schema_url = xdb_schema_url
        and e.xmldata.parent_schema = ref(s)
        and e.xmldata.name = 'id'
        and e.xmldata.prop_number = PN_ANNOTATION_ID;

    if ( c != 0 ) then
      dbms_output.put_line ( 'annotation id already exists.' );
    else
      dbms_output.put_line ( 'upgrading annotation id' );

      insert into xdb.xdb$attribute e (e.xmldata) values
        (XDB.XDB$PROPERTY_T(NULL, xdb_schema_ref, PN_ANNOTATION_ID, 'id', XDB.XDB$QNAME('00', 'string'), NULL, '01', '01', '00', NULL, 'ID', 'VARCHAR2', NULL, XDB.XDB$JAVATYPE('00'),NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
         returning ref(e) into xdbannotationid_ref;

      attlist.extend(1);
      attlist(attlist.last) := xdbannotationid_ref;
      update xdb.xdb$complex_type c
        set c.xmldata.attributes = attlist
        where c.xmldata.name = 'annotation' and
        c.xmldata.parent_schema = xdb_schema_ref;

      update xdb.xdb$schema s set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
        where ref(s) = xdb_schema_ref;

      execute immediate
        'alter type xdb.xdb$annotation_t add attribute (id varchar2(128)) cascade';
      commit;
    end if;

      dbms_output.put_line('12.2: schema for schemas upgraded');

  ELSE
    dbms_output.put_line('Annotation ID already exists. Nothing to upgrade');
  end if;

  execute immediate 'alter system flush shared_pool';
end;
/
show errors;

SET SERVEROUTPUT OFF

Rem ================================================================
Rem END XDB Schema Upgrade from 12.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Schema Upgrade from the next release
Rem ================================================================

@@xdbus122.sql
