Rem
Rem $Header: rdbms/admin/catxdbz0.sql /main/14 2016/04/19 12:54:30 qyu Exp $
Rem
Rem catxdbz0.sql
Rem
Rem Copyright (c) 2005, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxdbz0.sql - xdb security initialization
Rem
Rem    DESCRIPTION
Rem      This script registers all required system schemas before 
Rem      initXDBSecurity() can be called.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catxdbz0.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxdbz0.sql
Rem SQL_PHASE: CATXDBZ0
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catxdbz.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    qyu         03/28/16 - #22956970: create XMLDIR in the root
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    raeburns    06/25/14 - break out view definitions for reload
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    spetride    06/11/08 - 11.2 acl schema
Rem    thbaby      12/06/07 - set acl on schemas created pre-security
Rem    vkapoor     05/08/07 - bug 5769835
Rem    sidicula    12/19/06 - Avoid xmltable in xds_acl view
Rem    bkhaladk    04/24/06 - add CSX xml.xsd and xmltr.xsd schema 
Rem    petam       04/14/06 - fix xds_acl and xds_ace views 
Rem    petam       04/07/06 - separate out the install of ResConfig 
Rem    abagrawa    03/11/06 - Use acl.xsd in registerschema 
Rem    thbaby      03/12/06 - csx fix - principal not transient 
Rem    petam       02/08/06 - add ACL and ACE views 
Rem    petam       12/07/05 - acl enhancement for fusion security 
Rem    mrafiq      09/22/05 - merging changes for upgrade/downgrade
Rem    thoang      03/01/05 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Register ACL Schema

-- Create directory for picking up schemas
exec dbms_metadata_hack.cre_dir;
-- #22956970: need create XMLDIR in the root as common object
exec dbms_metadata_hack.cre_xml_dir;

-- Register the CSX xml.xsd
declare
  XMLNSXSD BFILE := dbms_metadata_hack.get_bfile('xmlcsx.xsd.11.0');
  XMLNSURL VARCHAR2(2000) := 'http://www.w3.org/2001/csx.xml.xsd';  
begin
  xdb.dbms_xmlschema.registerSchema(XMLNSURL, XMLNSXSD, FALSE, FALSE, FALSE, 
		                    TRUE, FALSE, 'XDB', 
                                   options=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end;
/

declare
  TRXSD BFILE := dbms_metadata_hack.get_bfile('xmltr.xsd.11.0');
  TRURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/csx.xmltr.xsd';  
begin
  xdb.dbms_xmlschema.registerSchema(TRURL, TRXSD, FALSE, FALSE, FALSE, TRUE,
                                    FALSE, 'XDB', 
                                 options => DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end;
/

declare
  ACLXSD BFILE := dbms_metadata_hack.get_bfile('acl.xsd.11.2');
  ACLURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/acl.xsd';  
begin
xdb.dbms_xmlschema.registerSchema(ACLURL, ACLXSD, FALSE, FALSE, FALSE, TRUE,
                                  FALSE, 'XDB', 
                                 options => DBMS_XMLSCHEMA.REGISTER_BINARYXML);

end;
/

-- Disable XRLS hierarchy priv check for xdb$acl and xdb$schema tables
BEGIN
   xdb.dbms_xdbz.disable_hierarchy('XDB', 'XDB$ACL');
   xdb.dbms_xdbz.disable_hierarchy('XDB', 'XDB$SCHEMA');
END;
/
  
-- INSERT bootstrap AND root acl's   
DECLARE 
  b_abspath          VARCHAR2(200);
  b_data             VARCHAR2(2000);
  r_abspath          VARCHAR2(200);
  r_data             VARCHAR2(2000);
  o_abspath          VARCHAR2(200);
  o_data             VARCHAR2(2000);
  ro_abspath         VARCHAR2(200);
  ro_data            VARCHAR2(2000);
  retbool            BOOLEAN;
BEGIN
   b_abspath := '/sys/acls/bootstrap_acl.xml';
   b_data := 
'<acl description="Protected:Readable by PUBLIC and all privileges to OWNER"
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd" xmlns:dav="DAV:"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd 
                          http://xmlns.oracle.com/xdb/acl.xsd">
  <ace> 
    <grant>true</grant>
    <principal>dav:owner</principal>
    <privilege>
      <all/>
    </privilege>
  </ace> 
  <ace> 
    <grant>true</grant>
    <principal>XDBADMIN</principal>
    <privilege>
      <all/>
    </privilege>
  </ace> 
  <ace> 
    <grant>true</grant>
    <principal>PUBLIC</principal>
    <privilege>
      <read-properties/>
      <read-contents/>
      <read-acl/>
      <resolve/>
    </privilege>
  </ace>
</acl>';
   
   r_abspath := '/sys/acls/all_all_acl.xml';
   r_data := 
'<acl description="Public:All privileges to PUBLIC"
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd  
                          http://xmlns.oracle.com/xdb/acl.xsd"> 
  <ace> 
    <grant>true</grant>
    <principal>PUBLIC</principal>
    <privilege>
      <all/>
    </privilege>
  </ace>
</acl>';
   
   o_abspath := '/sys/acls/all_owner_acl.xml';
   o_data := 
'<acl description="Private:All privileges to OWNER only and not accessible to others"
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd" xmlns:dav="DAV:"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd 
                          http://xmlns.oracle.com/xdb/acl.xsd"> 
  <ace> 
    <grant>true</grant>
    <principal>dav:owner</principal>
    <privilege>
      <all/>
    </privilege>
  </ace>
</acl>';
   
   ro_abspath := '/sys/acls/ro_all_acl.xml';
   ro_data := 
'<acl description="Read-Only:Readable by all and writeable by none"
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd  
                          http://xmlns.oracle.com/xdb/acl.xsd">
  <ace> 
    <grant>true</grant>
    <principal>PUBLIC</principal>
    <privilege>
      <read-properties/>
      <read-contents/>
      <read-acl/>
      <resolve/>
    </privilege>
  </ace>
</acl>';
   
   retbool := dbms_xdb.createresource(b_abspath, b_data);
   retbool := dbms_xdb.createresource(r_abspath, r_data);
   retbool := dbms_xdb.createresource(o_abspath, o_data);
   retbool := dbms_xdb.createresource(ro_abspath, ro_data);
END;
/
  
declare 
   tablename     varchar2(2000);
   sqlstatement  varchar2(2000);
begin
   select e.xmldata.default_table into tablename from xdb.xdb$element e where e.xmldata.property.parent_schema = ( select ref(s) from xdb.xdb$schema s where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/acl.xsd') and e.xmldata.property.name = 'acl';

   tablename := 'xdb.' || '"' || tablename || '"';

   sqlstatement := 'update xdb.xdb$resource r set r.xmldata.acloid = ( select e.sys_nc_oid$ from ' || tablename || ' e where extractvalue(e.object_value, ''/acl/@description'') like ''Protected%'')';
   execute immediate sqlstatement;

   sqlstatement := 'update xdb.xdb$acl set acloid = ( select e.sys_nc_oid$ from ' || tablename || ' e where extractvalue(e.object_value, ''/acl/@description'') like ''Protected%'')';
   execute immediate sqlstatement;

   sqlstatement := 'update xdb.xdb$schema set acloid = ( select e.sys_nc_oid$ from ' || tablename || ' e where extractvalue(e.object_value, ''/acl/@description'') like ''Protected%'')';
   execute immediate sqlstatement;

   sqlstatement := 'update xdb.xdb$h_index set acl_id = ( select e.sys_nc_oid$ from ' || tablename || ' e where extractvalue(e.object_value, ''/acl/@description'') like ''Protected%'')';
   execute immediate sqlstatement;

   sqlstatement := 'update xdb.xdb$h_link set child_acloid = ( select e.sys_nc_oid$ from ' || tablename || ' e where extractvalue(e.object_value, ''/acl/@description'') like ''Protected%'')';
   execute immediate sqlstatement;
end;
/

commit;

-- Insert a row into xdbready to indicate ACLs are available
insert into xdb.xdb$xdb_ready values (null);
commit;

-- Create views - moved to separate script for xdbload
@@catxdbz1.sql

@?/rdbms/admin/sqlsessend.sql
