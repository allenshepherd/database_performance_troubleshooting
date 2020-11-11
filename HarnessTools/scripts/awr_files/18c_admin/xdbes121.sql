Rem
Rem $Header: rdbms/admin/xdbes121.sql /main/7 2017/04/04 09:12:44 raeburns Exp $
Rem
Rem xdbes121.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbes121.sql - XDB Schema Downgrade to 12.1
Rem
Rem    DESCRIPTION
Rem     This script downgrades XDB schema from 12.2 to 12.1
Rem
Rem    NOTES
Rem      It is invoked from xdbdwgrd.sql and from xdbes112.sql 
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbes121.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbes121.sql 
Rem    SQL_PHASE: DOWNGRADE 
Rem    SQL_STARTUP_MODE: DOWNGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbdwgrd.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    qyu         11/10/16 - invoke xdbes122.sql
Rem    qyu         07/25/16 - add file metadata
Rem    joalvizo    03/28/16 - remove ALTER TABLE statements for xdb$root_info
Rem    ckavoor     01/21/15 - 18938910:Downgrade schema_for_schema
Rem    dmelinge    11/17/14 - SetRemoteHttpPort, SR 38986558561
Rem    raeburns    11/04/13 - XDB 12.1 downgrade
Rem    raeburns    11/04/13 - Created

Rem ================================================================
Rem BEGIN XDB Schema downgrade to 12.2.0
Rem ================================================================

@@xdbes122.sql

Rem ================================================================
Rem END XDB Schema downgrade to 12.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Schema downgrade to 12.1.0
Rem ================================================================


-- ANNOTATION_ID 

set serveroutput on
declare
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 276;
  sch_ref                 REF SYS.XMLTYPE;
  numprops                number;
  attlist         XDB.XDB$XMLTYPE_REF_LIST_T;
  last_att_ref    REF XMLTYPE;
  last_att_name  varchar2(100);
begin
-- get the schema's REF
  select ref(s) into sch_ref from xdb.xdb$schema s where
   s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBSchema.xsd';

-- Has the property already been deleted
  select s.xmldata.num_props into numprops from xdb.xdb$schema s
   where ref(s) = sch_ref;

  IF (numprops != PN_RES_TOTAL_PROPNUMS) THEN
    dbms_output.put_line('downgrading schema_for_schemas for 122');

    begin
     execute immediate
      'alter type xdb.xdb$annotation_t drop attribute (id) cascade';
     exception 
      when others then
        dbms_output.put_line('alter type on xdb$ had issues, still continuing');
    end;
    commit;

    dbms_output.put_line('downgrading annotation id');

    select c.xmldata.attributes into attlist from xdb.xdb$complex_type c
     where c.xmldata.name = 'annotation' and c.xmldata.parent_schema = sch_ref;

    last_att_ref := attlist(attlist.last);
	
    select e.xmldata.name into last_att_name from xdb.xdb$attribute e
     where ref(e) = last_att_ref;

    if last_att_name = 'id' then
      dbms_output.put_line('downgrading annotation id .. id found');

    begin
      delete from xdb.xdb$attribute e where ref(e) = last_att_ref;
      exception when others then
        dbms_output.put_line('Deleting ID from xdb$annotation_t had issues, still continuing');
    end;
    commit;

      attlist.trim(1); 

    begin
      update xdb.xdb$complex_type c
      set c.xmldata.attributes = attlist where c.xmldata.name = 'annotation'
       and c.xmldata.parent_schema = sch_ref;
      exception when others then
        dbms_output.put_line('Updating xdb$complex_type had issues, still continuing');
    end;
    commit;

    else
      dbms_output.put_line('downgrading annotation id failed');
    end if;

    update xdb.xdb$schema s
      set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS where ref(s) = sch_ref;
    commit;

    dbms_output.put_line('12.2: schema for schemas downgraded');

  ELSE
    dbms_output.put_line('12.2: There is nothing to downgrade');
  END IF;

  execute immediate 'alter system flush shared_pool';

end;
/
show errors;

set serveroutput off

Rem ================================================================
Rem END XDB Schema downgrade to 12.1.0
Rem ================================================================
