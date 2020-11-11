Rem
Rem $Header: rdbms/admin/xdbus111.sql /main/3 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbus111.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbus111.sql - XDB Upgrade Schemas from 11.1.0
Rem
Rem    DESCRIPTION
Rem     This script upgrades the XDB schemas from release 11.1.0
Rem     to the current release.
Rem
Rem    NOTES
Rem     It is invoked by xdbus.sql, and invokes the xdbusNNN script for the 
Rem     subsequent release.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbus111.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbus111.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbus.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         07/25/16 - add file metadata
Rem    raeburns    10/25/13 - XDB upgrade restructure
Rem    raeburns    10/25/13 - Created

Rem ================================================================
Rem BEGIN XDB Schemas Upgrade from 11.1.0
Rem ================================================================

-- BEGIN from xdbs111.sql

/*************************************************************************/
/******************* Upgrade XDBResource schema to 11.2 ******************/
/*************************************************************************/
declare
  res_schema_ref  REF XMLTYPE;
  res_schema_url  VARCHAR2(100);
begin
  res_schema_url := 'http://xmlns.oracle.com/xdb/XDBResource.xsd';
  
  select ref(s) into res_schema_ref 
  from xdb.xdb$schema s 
  where s.xmldata.schema_url = res_schema_url;

/* Set numcolumns for simple types to 0 */
  execute immediate
  'update xdb.xdb$element e 
  set e.xmldata.num_cols = 0 
  where e.xmldata.property.name=''XMLRef'' or 
        e.xmldata.property.name=''XMLLob'' or 
        e.xmldata.property.name=''Flags'' or 
        e.xmldata.property.name=''SBResExtra'' or 
        e.xmldata.property.name=''Snapshot'' or 
        e.xmldata.property.name=''NodeNum'' or 
        e.xmldata.property.name=''ContentSize'' or 
        e.xmldata.property.name=''SizeOnDisk'' 
    and e.xmldata.property.parent_schema=:1' using  res_schema_ref;

/* IsXMLIndexed - mark unmutable */
  update xdb.xdb$attribute a
  set a.xmldata.MUTABLE = '01'
  where a.xmldata.parent_schema = res_schema_ref
    and a.xmldata.name = 'IsXMLIndexed';

/* container - mark unmutable */
  update xdb.xdb$attribute a
  set a.xmldata.MUTABLE = '01'
  where a.xmldata.parent_schema = res_schema_ref
    and a.xmldata.name = 'Container';


  commit;
end;
/


/*************************************************************************/
/********************** Upgrade ACL schema to 11.2  **********************/
/*************************************************************************/

-- This changes the processContents attribute for the any element in the acl and ace elements
-- to lax so that user defined data can be added to these any elements.
create or replace procedure xdb$updateAclProcessContents(ace_cplx_ref IN REF SYS.XMLTYPE)
as
  anylist         XDB.XDB$XMLTYPE_REF_LIST_T;
  any_ref           REF XMLTYPE;
  seq_ref           REF XMLTYPE;
begin
  -- update the any element of the ace element to make 
  -- processContents attibute equals lax 
  select c.xmldata.sequence_kid into seq_ref
  from xdb.xdb$complex_type c
  where ref(c) = ace_cplx_ref;

  select m.xmldata.anys into anylist
  from xdb.xdb$sequence_model m
  where ref(m) = seq_ref;

  any_ref := anylist(1);

  update xdb.xdb$any a
  set a.xmldata.process_contents = XDB.XDB$PROCESSCHOICE('01'),
      a.xmldata.property.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43881800F000001E1F1C1D0809181B030B0C07')
  where ref(a) = any_ref;

  -- update the any element of the acl element to make 
  -- processContents attibute equals lax 
  select c.xmldata.sequence_kid into seq_ref
  from xdb.xdb$complex_type c
  where c.xmldata.name like 'aclType';

  select m.xmldata.anys into anylist
  from xdb.xdb$sequence_model m
  where ref(m) = seq_ref;

  any_ref := anylist(1);

  update xdb.xdb$any a
  set a.xmldata.process_contents = XDB.XDB$PROCESSCHOICE('01'),
      a.xmldata.property.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43881800F000001E1F1C1D0809181B030B0C07')
  where ref(a) = any_ref;

  commit;
end xdb$updateAclProcessContents;
/
show errors;

-- This adds 'ApplicationName' principal format
create or replace procedure xdb$addAclApplicationName(ace_cplx_ref IN REF SYS.XMLTYPE) as
  aceattrs      XDB.XDB$XMLTYPE_REF_LIST_T;
  i             NUMBER;
  nm            VARCHAR2(256);
  aceattr       REF SYS.XMLTYPE;
begin
  -- find the list of attributes for the ace's complex type
  select c.xmldata.attributes into aceattrs 
  from xdb.xdb$complex_type c
  where ref(c) = ace_cplx_ref;

  for i in 1..aceattrs.last loop
     select a.xmldata.name into nm from xdb.xdb$attribute a 
     where ref(a)=aceattrs(i);

     if (nm = 'principalFormat') then
        -- update the simple type for principalFormat
        update xdb.xdb$simple_type s
        set s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('23020000000106'),
            s.xmldata.restriction = 
                 XDB.XDB$SIMPLE_DERIVATION_T(
                      XDB.XDB$RAW_LIST_T('330008020000118B8005'), NULL, 
                      XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, 
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                      XDB.XDB$FACET_LIST_T(
                          XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                                          'ShortName', '00', NULL), 
                          XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                                          'DistinguishedName', '00', NULL), 
                          XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                                          'GUID', '00', NULL), 
                          XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                                          'XSName', '00', NULL), 
                          XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                                          'ApplicationName', '00', NULL)),
                      NULL, NULL)
        where ref(s) = (select a.xmldata.smpl_type_decl from xdb.xdb$attribute a 
                        where ref(a)=aceattrs(i));
        dbms_output.put_line('updated acl.ace.principalFormat.restriction');
        -- exit the loop
        exit;
     end if;
  end loop;

  commit;
end xdb$addAclApplicationName;
/  
show errors;

declare
  acl_schema_url    VARCHAR2(100);
  acl_schema_ref    REF XMLTYPE;
  ace_cplxType_ref  REF XMLTYPE;
begin
  acl_schema_url := 'http://xmlns.oracle.com/xdb/acl.xsd';

  select ref(s) into acl_schema_ref 
  from xdb.xdb$schema s 
  where s.xmldata.schema_url = acl_schema_url;
  
  select e.xmldata.cplx_type_decl into ace_cplxType_ref
  from xdb.xdb$element e
  where e.xmldata.property.name = 'ace'
  and e.xmldata.property.parent_schema = acl_schema_ref;

  xdb$updateAclProcessContents(ace_cplxType_ref);
  xdb$addAclApplicationName(ace_cplxType_ref);
end;
/

-- drop acl-specific procedures/functions
drop procedure xdb$updateAclProcessContents;
drop procedure xdb$addAclApplicationName;

/*-----------------------------------------------------------------------*/
/* End upgrade of ACL schema */
/*-----------------------------------------------------------------------*/

/****** Some utility functions ******/
/*-----------------------------------------------------------------------*/
/* Return complex type in input list under schema_ref,  */
/*             and with name = child                    */
/*    OR null if none exist in list                     */
/*-----------------------------------------------------------------------*/
create or replace function xdb$find_cmplx_type(seq  xdb.xdb$xmltype_ref_list_t,
                    child varchar2, 
                    schema_ref REF SYS.XMLTYPE) return ref xmltype as
  r  ref sys.xmltype;
begin                 
  select ref(c) into r from xdb.xdb$complex_type c
   where (seq is null OR (ref(c) in (select * from table(seq)))) 
     and c.xmldata.name = child
     and c.xmldata.parent_schema = schema_ref;
  return r;                      
exception
  when no_data_found then
    return null;
end xdb$find_cmplx_type;
/
show errors;


/*************************************************************************/
/********************* Upgrage XDBConfig to 11.2 *************************/
/*************************************************************************/

/* Insert one element under the xdbconfig schema into xdb$element table */
create or replace function xdb$insertCfgCplxElem(
--    elems_reflist     XDB.XDB$XMLTYPE_REF_LIST_T,
    prop_pd           XDB.XDB$RAW_LIST_T,
    prop_parschema    REF SYS.XMLTYPE,
    prop_elemname     VARCHAR2,
    prop_typename     XDB.XDB$QNAME,
    prop_memtypecode  RAW,
    prop_sqlname      VARCHAR2,
    prop_sqltype      VARCHAR2,
    prop_dfltval      VARCHAR2,
    prop_smpltypedecl REF SYS.XMLTYPE,
    prop_typeref      REF SYS.XMLTYPE,
    mem_inline        RAW,
    java_inline       RAW,
    cplx_type_decl    REF SYS.XMLTYPE,
    min_occurs        INTEGER,
    max_occurs        VARCHAR2) return REF SYS.XMLTYPE
AS
  elemref           REF SYS.XMLTYPE := NULL;
  prop_propnum      INTEGER;
BEGIN
  -- TODO: Need to check if element exists, to avoid dangling refs???
  -- TODO: this has to be done with element_exists_complextype since multiple elements with same name and other details can exist in the same schema, especially if many of these details are null or default
  
  -- extend sequence and insert new element
--  elems_reflist.extend(1);
  prop_propnum := xdb.xdb$propnum_seq.nextval;
  insert into xdb.xdb$element e (e.xmlextra, e.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$ELEMENT_T(
           XDB.XDB$PROPERTY_T(prop_pd, prop_parschema, prop_propnum, 
             prop_elemname, prop_typename, 
             NULL, prop_memtypecode, '00', '00', NULL, -- 10  
             prop_sqlname, prop_sqltype, NULL, NULL, prop_dfltval, 
             prop_smpltypedecl, prop_typeref, NULL, NULL, NULL, -- 20
             NULL,  '00', NULL, NULL, NULL, '00', NULL, NULL, '00'),
           NULL, NULL, '00', NULL, NULL, '00', mem_inline, '01', java_inline, -- 10
           '01', NULL, NULL, NULL, NULL, 
           NULL, NULL, cplx_type_decl, NULL, NULL, -- 20
           min_occurs, max_occurs, '00', '01', NULL, 
           NULL, NULL, NULL, NULL, NULL, -- 30
           NULL, NULL))
  returning ref(e) into elemref;
--  elems_reflist(elems_reflist.last) := elemref;
  dbms_output.put_line('created new element ' || prop_elemname || 
      ' ,propnum = ' || prop_propnum);
  return elemref;
END xdb$insertCfgCplxElem;
/
show errors;

-- ipv6 support: modify simpletype ipaddress in xdbconfig
create or replace procedure xdb$updateConfigIpaddress(config_sch_ref IN REF SYS.XMLTYPE)
as
begin
  update xdb.xdb$simple_type e
  set e.xmldata.restriction.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('3310000200001104'),
      e.xmldata.restriction.maxlength  = XDB.XDB$NUMFACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 40, '00', NULL),
      e.xmldata.restriction.pattern    = NULL
  where e.xmldata.parent_schema = config_sch_ref
    and e.xmldata.name = 'ipaddress';

  commit;
end xdb$updateConfigIpaddress;
/
show errors;

/*-----------------------------------------------------------------------*/
/* Procedure to create custom-authentication-trust-type (global complex type in xdbconfig)
 *   If xdbconfig.custom-authentication-trust-type exists in xdb$complex_type, 
 *   we return that instead 
/*-----------------------------------------------------------------------*/
create or replace function xdb$getCustomAuthTrustType(config_sch_ref IN REF SYS.XMLTYPE) 
return REF SYS.XMLTYPE
as
  skidtrustelems      XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidtrustelems   REF SYS.XMLTYPE;
  anypart             VARCHAR2(4000);
  reftrustschtyp      REF SYS.XMLTYPE;
  skidtrustschs       XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidtrustschs    REF SYS.XMLTYPE;
  refcauthtrusttyp    REF SYS.XMLTYPE;
begin
  refcauthtrusttyp := xdb$find_cmplx_type(null, 'custom-authentication-trust-type', config_sch_ref);
  if refcauthtrusttyp is not null then
    dbms_output.put_line('custom-authentication-trust-type exists, not creating');
    return refcauthtrusttyp;
  end if;

  dbms_output.put_line('creating custom-authentication-trust-type ...');
  
  -- create seq(trust-scheme-name,        requireParsingSchema, allowRegistration, 
  --            trust-scheme-description, trusted-session-user, trusted-parsing-schema) 
  -- for trust-scheme
  skidtrustelems := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidtrustelems.extend(6);

  -- create trust-scheme-name element
  skidtrustelems(1):= xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'trust-scheme-name',
      XDB.XDB$QNAME('00','string'), '01', null, 'string', null, null, null,
      '01', '01', null, 0, NULL);

  -- create the requireParsingSchema element
  skidtrustelems(2):= xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B890200080030400000004050F320809181B23262A343503150C07292728'),
      config_sch_ref, 'requireParsingSchema',
      XDB.XDB$QNAME('00', 'boolean'), 'FC', NULL, 'boolean', 'true', NULL, NULL,
      '01', '01', null, 0, NULL);

  -- create the allowRegistration element
  skidtrustelems(3):= xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B890200080030400000004050F320809181B23262A343503150C07292728'),
      config_sch_ref, 'allowRegistration',
      XDB.XDB$QNAME('00', 'boolean'), 'FC', NULL, 'boolean', 'true', NULL, NULL,
      '01', '01', null, 0, NULL);

  -- create the trust-scheme-description element
  skidtrustelems(4):= xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B81020008003040000000405320809181B23262A343503150C07292728'),
      config_sch_ref, 'trust-scheme-description',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', null, 0, NULL);

  -- create the trusted-user-session element
  skidtrustelems(5):= xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030C000000040532330809181B23262A343503150C07292728'),
      config_sch_ref, 'trusted-session-user',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 1, 'unbounded');

  -- create the trusted-parsing-schema element
  skidtrustelems(6):= xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030C000000040532330809181B23262A343503150C07292728'),
      config_sch_ref, 'trusted-parsing-schema',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, 'unbounded');

  -- the workgroup element is not added anymore
  dbms_output.put_line(to_char(skidtrustelems.count) || ' elements in trust-scheme');
  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
    values(dbms_xdbmig_util.getConfigXtra,
           XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('230200000081800607'),
                        config_sch_ref, 0, NULL, 
                        skidtrustelems,
                        NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidtrustelems;

  -- create annotation for trust-scheme
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidtrustelems, null);
 
  -- create complex type declaration for trust-scheme
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('33090000000000030D0E13'), config_sch_ref, 
           NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidtrustelems, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), 
             NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, NULL))
  returning ref(c) into reftrustschtyp;
 
  -- create seq(trust-scheme) for custom-authentication-trust-type
  skidtrustschs := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidtrustschs.extend(1);
 
  -- create complex element trust-scheme
  skidtrustschs(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839800201080030C0000000432331C0809181B23262A3435031507292728'),
      config_sch_ref, 'trust-scheme',
      NULL, '0102', NULL, NULL, NULL,  NULL, reftrustschtyp, 
      '00', '00', reftrustschtyp, 0, 'unbounded');

  insert into  xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23020000000107'), config_sch_ref, 0, NULL, 
                         skidtrustschs, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidtrustschs;

  -- create annotation for complex type custom-authentication-trust-type
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidtrustschs, null);

  -- create complex type custom-authentication-trust-type
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('3309104000000C00030D0E1316'),
           config_sch_ref, NULL, 'custom-authentication-trust-type', '00', '00', 
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidtrustschs, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), 
             NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, 215))
  returning ref(c) into refcauthtrusttyp;
  commit;
  return refcauthtrusttyp;
end xdb$getCustomAuthTrustType;
/  
show errors;


create or replace function xdb$getCAuthMappings(config_sch_ref IN REF SYS.XMLTYPE) 
return REF SYS.XMLTYPE
as
  refmapselem          REF SYS.XMLTYPE;
  skidmapelems         XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidmap           REF SYS.XMLTYPE;
  refmaptype           REF SYS.XMLTYPE;
  skidmapselems        XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidmaps          REF SYS.XMLTYPE;
  refmapstype          REF SYS.XMLTYPE;
  ref_ondeny_typ       REF SYS.XMLTYPE;
  anypart              VARCHAR2(4000);
begin
  begin
    select ref(e) into refmapselem
      from xdb.xdb$complex_type c, xdb.xdb$element e
     where e.xmldata.property.name = 'custom-authentication-mappings'
       and e.xmldata.cplx_type_decl = ref(c)
       and e.xmldata.property.parent_schema = config_sch_ref
       and c.xmldata.parent_schema = config_sch_ref; 
    dbms_output.put_line('custom-authentication-mappings element exists, not creating');
    return refmapselem;
  exception
    when no_data_found then
      null;
  end;

  dbms_output.put_line('creating custom-authentication-mappings element');

  -- create seq(authentication-pattern, authentication-name, authentication-trust-name, 
  --            user-prefix,            on-deny)
  -- for custom-authentication-mapping
  skidmapelems := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidmapelems.extend(5);

  -- create authentication-pattern element
  skidmapelems(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'authentication-pattern',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create authentication-name element
  skidmapelems(2) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'authentication-name',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create authentication-trust-name element
  skidmapelems(3) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B81020008003040000000405320809181B23262A343503150C07292728'),
      config_sch_ref, 'authentication-trust-name',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create user-prefix element
  skidmapelems(4) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B81020008003040000000405320809181B23262A343503150C07292728'),
      config_sch_ref, 'user-prefix',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create the simple type for on-deny
  insert into xdb.xdb$simple_type t (t.xmlextra, t.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$SIMPLE_T(
           XDB.XDB$RAW_LIST_T('23020000000106'), config_sch_ref, NULL, '00', 
           XDB.XDB$SIMPLE_DERIVATION_T(
             XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, 
             XDB.XDB$QNAME('00', 'string'), 
             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
             NULL, NULL, 
             XDB.XDB$FACET_LIST_T(
               XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                 'next-custom', '00', NULL), 
               XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                 'basic', '00', NULL)), 
             NULL, NULL), 
           NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(t) into ref_ondeny_typ;
  
  -- create the on-deny element
  skidmapelems(5) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839A1020008003040000000432010809181B23262A343503150C07292728'),
      config_sch_ref, 'on-deny',
      NULL, '0103', NULL, 'string', NULL, ref_ondeny_typ, ref_ondeny_typ,
      '01', '01', NULL, 0, NULL);

  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(
           XDB.XDB$RAW_LIST_T('230200000081800507'),
           config_sch_ref, 0, NULL, skidmapelems,
           NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidmap;

  -- create annotation for custom-authentication-mapping
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidmapelems, null);
  
  -- create complex type declaration for custom-authentication-mapping
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('33090000000000030D0E13'), 
           config_sch_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           refskidmap, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), 
                 anypart,
                 NULL)), NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, NULL))
  returning ref(c) into refmaptype;

  -- create seq(custom-authentication-mapping)
  skidmapselems := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidmapselems.extend(1);

  -- create custom-authentication-mapping element
  skidmapselems(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839800201080030C0000000432331C0809181B23262A3435031507292728'),
      config_sch_ref, 'custom-authentication-mapping',
      NULL, '0102', NULL, NULL, NULL, NULL, refmaptype,
      '00', '00', refmaptype, 0, 'unbounded');

  insert into  xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23020000000107'), config_sch_ref, 0, NULL, 
                         skidmapselems, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidmaps;

  -- create annotation for complex type declaration for custom-authentication-mappings
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidmapselems, null);

  -- create complex type declaration for custom-authentication-mappings
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('33090000000000030D0E13'), 
           config_sch_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidmaps, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), 
                 anypart, NULL)), NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, NULL))
  returning ref(c) into refmapstype;
  
  refmapselem := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('8398002010800300000000041C0809181B23262A323435031507292728'),
      config_sch_ref, 'custom-authentication-mappings',
      NULL, '0102', NULL, NULL, NULL, NULL, refmapstype,
      '00', '00', refmapstype, 0, NULL);

  return refmapselem;
end xdb$getCAuthMappings;
/
show errors;
 
create or replace function xdb$getCAuthList(config_sch_ref IN REF SYS.XMLTYPE)
return REF SYS.XMLTYPE
as
  reflistelem          REF SYS.XMLTYPE;
  reflangtype          REF SYS.XMLTYPE;
  skidauthelems        XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidauth          REF SYS.XMLTYPE;
  refauthtype          REF SYS.XMLTYPE;
  skidauthlistelems    XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidauthlist      REF SYS.XMLTYPE;
  refauthlisttype      REF SYS.XMLTYPE;
  anypart              VARCHAR2(4000);
begin
  begin
    select ref(e) into reflistelem
      from xdb.xdb$complex_type c, xdb.xdb$element e
     where e.xmldata.property.name = 'custom-authentication-list'
       and e.xmldata.cplx_type_decl = ref(c)
       and e.xmldata.property.parent_schema = config_sch_ref
       and c.xmldata.parent_schema = config_sch_ref; 
    dbms_output.put_line('custom-authentication-list element exists, not creating');
    return reflistelem;
  exception
    when no_data_found then
      null;
  end;

  dbms_output.put_line('creating custom-authentication-list element');

  -- create seq(authentication-name, authentication-description, authentication-implement-schema, 
  --            authentication-implement-method, authentication-implement-language) 
  -- for custom-authentication-list.complexType.authentication
  skidauthelems := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidauthelems.extend(5);

  -- create authentication-name element
  skidauthelems(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'authentication-name',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create authentication-description element
  skidauthelems(2) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B81020008003040000000405320809181B23262A343503150C07292728'),
      config_sch_ref, 'authentication-description',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create authentication-implement-schema element
  skidauthelems(3) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'authentication-implement-schema',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create authentication-implement-method element
  skidauthelems(4) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'authentication-implement-method',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create annotation for simple type for authentication-implement-language (not needed)

  -- create simple type for authentication-implement-language
  insert into xdb.xdb$simple_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$SIMPLE_T(
           XDB.XDB$RAW_LIST_T('23020000000106'), config_sch_ref, NULL, '00', 
           XDB.XDB$SIMPLE_DERIVATION_T(
             XDB.XDB$RAW_LIST_T('330008020000110B'), NULL, XDB.XDB$QNAME('00', 'string'),
             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
             XDB.XDB$FACET_LIST_T(
               XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'PL/SQL', '00', NULL)), 
             NULL, NULL), 
           NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(c) into reflangtype;

  -- create authentication-implement-language element
  skidauthelems(5) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839A10200080030000000004010809181B23262A32343503150C07292728'),
      config_sch_ref, 'authentication-implement-language',
      NULL, '0103', NULL, 'string', NULL, reflangtype, reflangtype,
      '01', '01', NULL, 0, NULL);
  
  insert into  xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(
           XDB.XDB$RAW_LIST_T('230200000081800507'), config_sch_ref, 0, NULL, 
           skidauthelems, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidauth;  

  -- create annotation for complex type declaration for authentication
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidauthelems, null);

  -- create complex type declaration for authentication
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('33090000000000030D0E13'), 
           config_sch_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidauth, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), 
             NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, NULL))
  returning ref(c) into refauthtype;

  -- create seq(authentication)
  skidauthlistelems := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidauthlistelems.extend(1);

  -- create authentication element
  skidauthlistelems(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839800201080030C0000000432331C0809181B23262A3435031507292728'),
      config_sch_ref, 'authentication',
      NULL, '0102', NULL, NULL, NULL, NULL, refauthtype,
      '00', '00', refauthtype, 0, 'unbounded');
  
  insert into  xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(
           XDB.XDB$RAW_LIST_T('23020000000107'), 
           config_sch_ref, 0, NULL, skidauthlistelems, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidauthlist;

  -- create annotation for complex type declaration for custom-authentication-list
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidauthlistelems, null);

  -- create complex type declaration for custom-authentication-list
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('33090000000000030D0E13'), 
           config_sch_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidauthlist, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, NULL))
  returning ref(c) into refauthlisttype;

  reflistelem := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('8398002010800300000000041C0809181B23262A323435031507292728'),
      config_sch_ref, 'custom-authentication-list',
      NULL, '0102', NULL, NULL, NULL, NULL, refauthlisttype,
      '00', '00', refauthlisttype, 0, NULL);

  return reflistelem;
end xdb$getCAuthList;
/
show errors;

create or replace function xdb$getCustomAuthType(config_sch_ref IN REF SYS.XMLTYPE,
                                            cauthtrusttyp_ref IN REF SYS.XMLTYPE) 
return REF SYS.XMLTYPE
as
  refcauthtype         REF SYS.XMLTYPE;
  skidcauthtypeelems   XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidcauthtype     REF SYS.XMLTYPE;
  anypart              VARCHAR2(4000);
begin
  refcauthtype := xdb$find_cmplx_type(null, 'custom-authentication-type', config_sch_ref);
  if refcauthtype is not null then 
    dbms_output.put_line('custom-authentication-type exists, not creating');
    return refcauthtype;
  end if;

  dbms_output.put_line('creating custom-authentication-type ...');

  -- create seq(custom-authentication-mappings, custom-authentication-list, 
  --            custom-authentication-trust) 
  -- for custom-authentication-type
  skidcauthtypeelems :=  XDB.XDB$XMLTYPE_REF_LIST_T();
  skidcauthtypeelems.extend(3);

  -- create custom-authentication-mappings element
  skidcauthtypeelems(1) := xdb$getCAuthMappings(config_sch_ref);

  -- create custom-authentication-list element
  skidcauthtypeelems(2) := xdb$getCAuthList(config_sch_ref);

  skidcauthtypeelems(3) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B80020008003040000000405320809181B23262A3435031507292728'),
      config_sch_ref, 'custom-authentication-trust',
      XDB.XDB$QNAME('01', 'custom-authentication-trust-type'), '0102', 
      NULL, NULL, NULL, NULL, cauthtrusttyp_ref,
      '00', '00', NULL, 0, NULL);

  insert into  xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(
           XDB.XDB$RAW_LIST_T('230200000081800307'), config_sch_ref, 0, NULL, 
           skidcauthtypeelems, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidcauthtype;  

  -- create annotation for custom-authentication-type
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidcauthtypeelems, null);
  
  -- create complex type custom-authentication-type
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('3309104000000C00030D0E1316'), 
           config_sch_ref, NULL, 'custom-authentication-type', '00', '00', NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, 
           refskidcauthtype, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), 
             NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, 141))
  returning ref(c) into refcauthtype;
  commit;
  return refcauthtype;
end xdb$getCustomAuthType;
/
show errors;

/*-----------------------------------------------------------------------*/
/* Procedure to create expire-type (global complex type in xdbconfig)  */
/* If xdbconfig.expire-type exists in xdb$complex_type, we return that instead */
/*-----------------------------------------------------------------------*/
create or replace function xdb$getConfigExpireType (config_sch_ref IN REF SYS.XMLTYPE) 
return ref sys.xmltype 
as 
  exptype              REF SYS.XMLTYPE;
  expdeftype           REF SYS.XMLTYPE;
  skidexpmap           XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidmap           REF SYS.XMLTYPE;
  anypart              VARCHAR2(4000);
  expmaptype           REF SYS.XMLTYPE;
  skidexp              XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidexp           REF SYS.XMLTYPE;
begin
  exptype := xdb$find_cmplx_type(null, 'expire-type', config_sch_ref);
  if exptype is not null then
    dbms_output.put_line('expire-type exists, not creating');
    return exptype;
  end if;

  dbms_output.put_line('creating expire-type ...');
 
  skidexpmap := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidexpmap.extend(2);

  -- create the expire-pattern element
  skidexpmap(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'expire-pattern',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);
  dbms_output.put_line('1. expire-pattern element created');

  -- create simple type for expire-default
  insert into xdb.xdb$simple_type st (st.xmlextra, st.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$SIMPLE_T(
           XDB.XDB$RAW_LIST_T('23020000000106'), config_sch_ref, NULL, '00',
           XDB.XDB$SIMPLE_DERIVATION_T(
             XDB.XDB$RAW_LIST_T('330004020000110A'), NULL, 
             XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, 
             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
             XDB.XDB$FACET_LIST_T(
               XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                 '(now|modification)(\s(plus))?(\s(([1]\s(year))|([0-9]*\s(years))))?(\s(([1]\s(month))|([0-9]*\s(months))))?(\s(([1]\s(week))|([0-9]*\s(weeks))))?(\s(([1]\s(day))|([0-9]*\s(days))))?(\s(([1]\s(hour))|([0-9]*\s(hours))))?(\s(([1]\s(minute))|([0-9]*\s(minutes))))?(\s(([1]\s(second))|([0-9]*\s(seconds))))?', 
                 '00', NULL)), 
             NULL, NULL, NULL), 
           NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(st) into expdeftype;
  dbms_output.put_line('2. simple type for expire-default created');

  -- create expire-default element
  skidexpmap(2) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839A10200080030000000004010809181B23262A32343503150C07292728'),
      config_sch_ref, 'expire-default',
      NULL, '01', NULL, 'string', NULL, expdeftype, expdeftype,
      '01', '01', NULL, 0, NULL);
  dbms_output.put_line('3. expire-default element created');

  --  seq(expire-pattern, expire-default)
  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
          XDB.XDB$MODEL_T(
            XDB.XDB$RAW_LIST_T('230200000081800207'), config_sch_ref, 0, NULL, 
            skidexpmap, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(m) into refskidmap;
  dbms_output.put_line('4. seq(expire-pattern, expire-default) created');

  -- create annotation for the type of expire-mapping
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidexpmap, null);

  -- create complex type declaration for expire-mapping
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('33090000000000030D0E13'), 
           config_sch_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidmap, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, NULL))
  returning ref(c) into expmaptype;
  dbms_output.put_line('5. complex type for expire-mapping created');

  -- seq(expire-mapping)
  skidexp := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidexp.extend(1);

  -- create expire-mapping element
  skidexp(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839800201080030C0000000432331C0809181B23262A3435031507292728'),
      config_sch_ref, 'expire-mapping',
      NULL, '0102', NULL, NULL, NULL, NULL, expmaptype,
      '00', '00', expmaptype, 0, 'unbounded');
  dbms_output.put_line('6. expire-mapping element created');

  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23020000000107'), config_sch_ref, 0, NULL, 
                          skidexp, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidexp;
  dbms_output.put_line('7. seq(expire-mapping) created');

  -- create annotation for expire-type
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidexp, null);

  -- create expire-type
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('3309104000000C00030D0E1316'), 
           config_sch_ref, NULL, 'expire-type', '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidexp, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), 
             NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, 143))
  returning ref(c) into exptype;
  dbms_output.put_line('8. expire-type created');
  commit;
  return exptype;
end xdb$getConfigExpireType;
/
show errors;

/*
 Upgrade /xdbconfig/sysconfig/httpconfig children
 Add:
   /sysconfig/httpconfig/custom-authentication
   /sysconfig/httpconfig/realm
   /sysconfig/httpconfig/respond-with-server-info
   /sysconfig/httpconfig/expire
 */
create or replace procedure xdb$updateHttpConfig(config_sch_ref IN REF SYS.XMLTYPE, 
                                                 refcauthtype   IN REF SYS.XMLTYPE,
                                                 refexptype     IN REF SYS.XMLTYPE) as 
  PRAGMA AUTONOMOUS_TRANSACTION;
  refhttptype    REF SYS.XMLTYPE;
  refskidhttp    REF SYS.XMLTYPE;
  skidhttpelems  XDB.XDB$XMLTYPE_REF_LIST_T;
  anypart        VARCHAR2(4000);
  r              REF SYS.XMLTYPE;
  seqsize        number;
begin
  -- update elements and PD for seq kid of httpconfig
  -- new elements : { ..., custom-authentication, realm, respond-with-server-info, 
  --                        expire} 
  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid, m.xmldata.elements 
    into refhttptype, refskidhttp, skidhttpelems 
    from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where e.xmldata.property.name ='httpconfig' 
     and e.xmldata.property.parent_schema = config_sch_ref
     and ref(c) = e.xmldata.cplx_type_decl
     and ref(m) = c.xmldata.sequence_kid;
 
  -- save initial count
  seqsize := skidhttpelems.count;

  -- create custom-authentication element of type custom-authentication-type
  r := dbms_xdbmig_util.find_child(skidhttpelems, 'custom-authentication');
  if r is null then
    skidhttpelems.extend(1);
    skidhttpelems(skidhttpelems.last) := xdb$insertCfgCplxElem(
        XDB.XDB$RAW_LIST_T('83B80020008003040000000405320809181B23262A3435031507292728'),
        config_sch_ref, 'custom-authentication',
        XDB.XDB$QNAME('01', 'custom-authentication-type'), '0102', 
        NULL, NULL, NULL, NULL, refcauthtype,
        '00', '00', NULL, 0, NULL);
    dbms_output.put_line('added custom-authentication to http elem list');
  end if;

  -- create the realm element
  r := dbms_xdbmig_util.find_child(skidhttpelems, 'realm');
  if r is null then
    skidhttpelems.extend(1);
    skidhttpelems(skidhttpelems.last) := xdb$insertCfgCplxElem(
        XDB.XDB$RAW_LIST_T('83B81020008003040000000405320809181B23262A343503150C07292728'),
        config_sch_ref, 'realm',
        XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
        '01', '01', NULL, 0, NULL);
    dbms_output.put_line('added realm to http elem list');
  end if;

  -- create the respond-with-server-info element
  r := dbms_xdbmig_util.find_child(skidhttpelems, 'respond-with-server-info');
  if r is null then
    skidhttpelems.extend(1);
    skidhttpelems(skidhttpelems.last) := xdb$insertCfgCplxElem(
        XDB.XDB$RAW_LIST_T('83B890200080030400000004050F320809181B23262A343503150C07292728'),
        config_sch_ref, 'respond-with-server-info',
        XDB.XDB$QNAME('00', 'boolean'), 'FC', NULL, 'boolean', 'true', NULL, NULL,
        '01', '01', NULL, 0, NULL);
    dbms_output.put_line('added respond-with-server-info to http elem list');
  end if;

  -- create the expire element
  r := dbms_xdbmig_util.find_child(skidhttpelems, 'expire');
  if r is null then
    skidhttpelems.extend(1);
    skidhttpelems(skidhttpelems.last) := xdb$insertCfgCplxElem(
        XDB.XDB$RAW_LIST_T('83B80020008003040000000405320809181B23262A3435031507292728'),
        config_sch_ref, 'expire',
        XDB.XDB$QNAME('01', 'expire-type'), '0102', NULL, NULL, NULL, NULL, refexptype,
        '00', '00', NULL, 0, NULL);
    dbms_output.put_line('added expire to http elem list');
  end if;

  commit;

  -- update elements and PD for seq kid of httpconfig, if new element was added
  if skidhttpelems.count > seqsize then
    update xdb.xdb$sequence_model m
       set m.xmldata.elements   = skidhttpelems,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081801807')
     where ref(m)= refskidhttp;
    dbms_output.put_line('httpconfig: updated sequence kid and PD');
  
    -- update annotations for the complex type declaration for httpconfig
    anypart := dbms_xdbmig_util.buildAnnotationKidList(skidhttpelems, null);
  
    -- needed in the 11.1.0.7 upgrade to main
    update xdb.xdb$complex_type c
       set c.xmldata.annotation.appinfo = 
              XDB.XDB$APPINFO_LIST_T(
                  XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)),
           c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000') 
     where c.xmldata.parent_schema = config_sch_ref 
       and ref(c)=refhttptype;  
  
    commit;
  end if;
end xdb$updateHttpConfig;
/
show errors;

/*
 Upgrade /xdbconfig/sysconfig children
 Add:
   /sysconfig/allow-authentication-trust
   /sysconfig/custom-authentication-trust
   /sysconfig/default-type-mappings
   /sysconfig/localApplicationGroupStore
 */
create or replace procedure xdb$updateSysConfig(config_sch_ref IN REF SYS.XMLTYPE, 
                                                refcauthtrusttyp IN REF SYS.XMLTYPE) as 
  PRAGMA AUTONOMOUS_TRANSACTION;
  refsystype     REF SYS.XMLTYPE;
  refskidsys     REF SYS.XMLTYPE;
  skidsyselems   XDB.XDB$XMLTYPE_REF_LIST_T;
  anypart        VARCHAR2(4000);
  r              REF SYS.XMLTYPE;
  simpletype_ref REF SYS.XMLTYPE;
  seqsize        NUMBER;
begin
  -- update elements and PD for seq kid of sysconfig
  -- adding elements { ..., allow-authentication-trust, custom-authentication-trust }
  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid, m.xmldata.elements
    into refsystype, refskidsys, skidsyselems
    from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where e.xmldata.property.name ='sysconfig' 
     and e.xmldata.property.parent_schema = config_sch_ref
     and ref(c) = e.xmldata.cplx_type_decl
     and ref(m) = c.xmldata.sequence_kid;

  -- save initial count
  seqsize := skidsyselems.count;

  -- create allow-authentication-trust element
  r := dbms_xdbmig_util.find_child(skidsyselems, 'allow-authentication-trust');
  if r is null then
    skidsyselems.extend(1);
    skidsyselems(skidsyselems.last) := xdb$insertCfgCplxElem(
        XDB.XDB$RAW_LIST_T('83B890200080030400000004050F320809181B23262A343503150C07292728'),
        config_sch_ref, 'allow-authentication-trust',
        XDB.XDB$QNAME('00', 'boolean'), 'FC', NULL, 'boolean', 'false', NULL, NULL,
        '01', '01', NULL, 0, NULL);
    dbms_output.put_line('added allow-authentication-trust to sysconfig child list');
  end if;

  -- create custom-authentication-trust element under sysconfig
  r := dbms_xdbmig_util.find_child(skidsyselems, 'custom-authentication-trust');
  if r is null then
    skidsyselems.extend(1);
    skidsyselems(skidsyselems.last) := xdb$insertCfgCplxElem(
        XDB.XDB$RAW_LIST_T('83B80020008003040000000405320809181B23262A3435031507292728'),
        config_sch_ref, 'custom-authentication-trust',
        XDB.XDB$QNAME('01', 'custom-authentication-trust-type'), 
        '0102', NULL, NULL, NULL, NULL, refcauthtrusttyp,
        '00', '00', NULL, 0, NULL);
     dbms_output.put_line('added custom-authentication-trust to sysconfig child list');
  end if;

  -- create default-type-mappings element
  r := dbms_xdbmig_util.find_child(skidsyselems, 'default-type-mappings');
  if r is null then
    -- create simple type declaration for default-type-mappings
    insert into xdb.xdb$simple_type st (st.xmlextra, st.xmldata)  
    values (dbms_xdbmig_util.getConfigXtra,
   	        XDB.XDB$SIMPLE_T(
              XDB.XDB$RAW_LIST_T('23020000000106'), config_sch_ref, NULL, '00', 
              XDB.XDB$SIMPLE_DERIVATION_T(
                XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, 
                XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, 
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                XDB.XDB$FACET_LIST_T(
                  XDB.XDB$FACET_T(
                    XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'pre-11.2', '00', NULL), 
                  XDB.XDB$FACET_T(
                    XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'post-11.2', '00', NULL)), 
                NULL, NULL), 
              NULL, NULL, NULL, NULL, NULL, NULL, NULL)) 
    returning ref(st) into simpletype_ref;

    skidsyselems.extend(1); 
    skidsyselems(skidsyselems.last) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839A1020008003040000000432010809181B23262A343503150C07292728'),
      config_sch_ref, 'default-type-mappings',
      NULL, '0103', NULL, 'string', NULL, simpletype_ref, simpletype_ref,
      '01', '01', NULL, 0, NULL);
      dbms_output.put_line('added default-type-mappings to sysconfig child list');
  end if;

  -- create localApplicationGroupStore element
  r := dbms_xdbmig_util.find_child(skidsyselems, 'localApplicationGroupStore');
  if r is null then
    skidsyselems.extend(1); 
    skidsyselems(skidsyselems.last) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B890200080030400000004050F320809181B23262A343503150C07292728'),
      config_sch_ref, 'localApplicationGroupStore',
      XDB.XDB$QNAME('00', 'boolean'), 'FC', NULL, 'boolean', 'true', NULL, NULL,
      '01', '01', NULL, 0, NULL);
    dbms_output.put_line('added localApplicationGroupStore to sysconfig child list');
  end if;

  commit;

  -- update elements and PD for seq kid of sysconfig, if new element was added
  if skidsyselems.count > seqsize then
    update xdb.xdb$sequence_model m 
       set m.xmldata.elements   = skidsyselems,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801C07')
     where ref(m) = refskidsys;
  
    -- update annotations for the complex type declaration for sysconfig
    anypart := dbms_xdbmig_util.buildAnnotationKidList(skidsyselems, null);
  
    -- pd update needed in the 11.1.0.7 upgrade to main
    update xdb.xdb$complex_type c
       set c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000'), 
           c.xmldata.annotation.appinfo    = XDB.XDB$APPINFO_LIST_T(
                                               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), 
                                                                 anypart, NULL))
     where c.xmldata.parent_schema = config_sch_ref
       and ref(c) = refsystype; 
  
     commit;
   end if;
end xdb$updateSysConfig;
/
show errors;


/*
 ************ PLEASE MAKE SURE THIS REMAINS COMPLETELY RE-RUNNABLE **********
 --add global complex types
 *custom-authentication-trust-type and
 *custom-authentication-type (dependent on custom-authentication-trust-type)
 *expire-type
 
 --add elements to sysconfig
 *allow-authentication-trust (type boolean)
 *custom-authentication-trust (type xdbc:custom-authentication-trust-type)
 *default-type-mappings (simple type)
 *localApplicationGroupStore (type boolean)

 --add elements to sysconfig->httpconfig
 *custom-authentication (type xdbc:custom-authentication-type)
 *realm  (type string)
 *respond-with-server-info (type boolean)
 *expire

 --add value custom to restriction sysconfig->httpconfig->authentication->allow-mechanism

 */
create or replace procedure xdb$upgradeConfigSchema as 
  schema_url           VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  refs                 REF SYS.XMLTYPE;
  CONFIG_PRPONUMS      CONSTANT INTEGER := 204;
  clistinsch           XDB.XDB$XMLTYPE_REF_LIST_T;
  numprops             NUMBER(38);
  anypart              VARCHAR2(4000);
  r                    REF SYS.XMLTYPE;
  refcauthtrusttyp     REF SYS.XMLTYPE;
  refcauthtype         REF SYS.XMLTYPE;
  refexptype           REF SYS.XMLTYPE;
begin

  select ref(s), s.xmldata.num_props, s.xmldata.complex_types 
    into refs, numprops, clistinsch
    from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

  dbms_output.put_line('upgrading xdbconfig schema, numprops was ' || numprops);
  
  xdb$updateConfigIpaddress(refs);
      
  -- create/retrieve custom-authentication-trust-type complex type
  refcauthtrusttyp := xdb$getCustomAuthTrustType(refs);

  -- create/retrieve custom-authentication-type complex type
  refcauthtype := xdb$getCustomAuthType(refs, refcauthtrusttyp);

  -- create/retrieve expire-type complex type
  refexptype  := xdb$getConfigExpireType(refs);

  commit;

  -- update /sysconfig/httpconfig children
  xdb$updateHttpConfig(refs, refcauthtype, refexptype);

  -- add 'custom' for 'allow-mechanism' 
  -- Note: if more than one 'allow-mechanism' subelemnts will ever be added to the CONFIG schema,
  --       change this code to go through the kids of httpconfig, find 'authentication', and pick 
  --       the 'allow-mechanism' in the authentication kids
  update xdb.xdb$simple_type t
     set t.xmldata.sys_xdbpd$  = XDB.XDB$RAW_LIST_T('23020000000106'),
         t.xmldata.restriction = 
              XDB.XDB$SIMPLE_DERIVATION_T(
                  XDB.XDB$RAW_LIST_T('330008020000118B8003'), 
                  NULL, XDB.XDB$QNAME('00', 'string'), 
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                  NULL, NULL, NULL, 
                  XDB.XDB$FACET_LIST_T(
                    XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), 
                      NULL, 'digest', '00', NULL), 
                    XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), 
                      NULL, 'basic', '00', NULL), 
                    XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), 
                      NULL, 'custom', '00', NULL)), 
                  NULL, NULL)
   where ref(t) = (select e.xmldata.property.smpl_type_decl from xdb.xdb$element e
                    where e.xmldata.property.name ='allow-mechanism' 
                      and e.xmldata.property.parent_schema = refs);

   commit;

  -- update sysconfig children
  xdb$updateSysConfig(refs, refcauthtrusttyp);

  commit;

  -- update complex_types list in schema to include the new custom-authentication and trust types
  -- update num_props in schema 
  r := xdb$find_cmplx_type(clistinsch, 'custom-authentication-trust-type', refs);
  if r is null then
    clistinsch.extend(1);
    clistinsch(clistinsch.last) := refcauthtrusttyp;
    dbms_output.put_line('added custom-authentication-trust-type to config schema list');
  end if;
  r := xdb$find_cmplx_type(clistinsch, 'custom-authentication-type', refs);
  if r is null then
    clistinsch.extend(1);
    clistinsch(clistinsch.last) := refcauthtype;
    dbms_output.put_line('added custom-authentication-type to config schema list');
  end if;
  -- update complex_types list in schema to include the new expire-type  types
  r := xdb$find_cmplx_type(clistinsch, 'expire-type', refs);
  if r is null then
    clistinsch.extend(1);
    clistinsch(clistinsch.last) := refexptype;
    dbms_output.put_line('added expire-type to config schema list');
  end if;
  
  commit;
  
  update xdb.xdb$schema s 
     set s.xmldata.complex_types = clistinsch, 
         s.xmldata.sys_xdbpd$    = XDB.XDB$RAW_LIST_T('43163C8600050084010084020184030202081820637573746F6D697A6564206572726F7220706167657320020A3E20706172616D6574657220666F72206120736572766C65743A206E616D652C2076616C7565207061697220616E642061206465736372697074696F6E20200B0C110482800B818002828004131416120A170D'), 
         s.xmldata.num_props     = CONFIG_PRPONUMS
   where s.xmldata.schema_url = schema_url;  

  commit;
end xdb$upgradeConfigSchema;
/

show errors;

-- now upgrade XDB$CONFIG schema
exec xdb$upgradeConfigSchema;


-- drop config-specific procedures/functions
drop procedure xdb$upgradeConfigSchema;
drop procedure xdb$updateSysConfig;
drop procedure xdb$updateHttpConfig;
drop function xdb$getConfigExpireType;
drop function xdb$getCustomAuthType;
drop function xdb$getCAuthList;
drop function xdb$getCAuthMappings;
drop function xdb$getCustomAuthTrustType;
drop procedure xdb$updateConfigIpaddress;
drop function xdb$insertCfgCplxElem;

/* End upgrade of XDBConfig schema */

/*************************************************************************/
/********************* Upgrade XDBResConfig to 11.2 **********************/
/*************************************************************************/
Rem Manually add xlink-config/pre-condition property to XDB resource config schema

declare
  seq_ref                REF SYS.XMLTYPE;
  elem_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
  attr_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
  config_schema_url      VARCHAR2(100);
  config_schema_ref      REF SYS.XMLTYPE;
  elem_ref_precond       REF SYS.XMLTYPE;
  elem_typeref_precond   REF SYS.XMLTYPE;
  elem_propno            number(38);
  anypart                varchar2(4000);
begin
  config_schema_url := 'http://xmlns.oracle.com/xdb/XDBResConfig.xsd';

  if not dbms_xdbmig_util.element_exists_complextype(config_schema_url, 'xlink-config', 'pre-condition') then
     select ref(s) into config_schema_ref
       from xdb.xdb$schema s
      where s.xmldata.schema_url = config_schema_url;

     select c.xmldata.sequence_kid, c.xmldata.attributes into seq_ref, attr_arr
       from xdb.xdb$complex_type c
      where c.xmldata.name = 'xlink-config'
        and c.xmldata.parent_schema = config_schema_ref;

     -- Get a list of all elements in this sequence
     select m.xmldata.elements into elem_arr
       from xdb.xdb$sequence_model m
      where ref(m) = seq_ref;

     -- create pre-condition element
     select ref(c) into elem_typeref_precond
      from xdb.xdb$complex_type c
     where c.xmldata.name = 'condition'
       and c.xmldata.parent_schema = config_schema_ref;

     insert into xdb.xdb$element e (e.xmlextra, e.xmldata) 
     values (SYS.XMLTYPEEXTRA(
                SYS.XMLTYPEPI(
                  dbms_xdbmig_util.getpickledns('http://www.w3.org/2001/XMLSchema', null), 
                  dbms_xdbmig_util.getpickledns('http://xmlns.oracle.com/xdb','xdb'),
                  dbms_xdbmig_util.getpickledns('http://xmlns.oracle.com/xdb/XDBResConfig.xsd', 
                    'rescfg')), 
                SYS.XMLTYPEPI('523030')),
             XDB.XDB$ELEMENT_T(
               XDB.XDB$PROPERTY_T(
                 XDB.XDB$RAW_LIST_T('83B800200080030C000000040532330809181B23262A3435031507292728'), 
                 config_schema_ref, xdb.xdb$propnum_seq.nextval, 'pre-condition', 
                 XDB.XDB$QNAME('02', 'condition'), NULL, '0102', '00', '00', 
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, elem_typeref_precond, 
                 NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), 
               NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', 
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', '00', '01', 
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
     returning ref(e) into elem_ref_precond;

     -- extend elem_arr and add new element 
     elem_arr.extend(1);
     elem_arr(elem_arr.last)  := elem_ref_precond; 
     
     -- update child element sequence for the xlink-config complex type
     update xdb.xdb$sequence_model m
        set m.xmldata.elements   = elem_arr,
            m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800407')
      where ref(m) = seq_ref;

     -- edit annotation kidlist
     -- construct kidlist from element and attribute lists
     anypart := dbms_xdbmig_util.buildAnnotationKidList(elem_arr, attr_arr);

     update xdb.xdb$complex_type c
        set c.xmldata.annotation.appinfo =  
                XDB.XDB$APPINFO_LIST_T(
                    XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL))
      where c.xmldata.parent_schema = config_schema_ref
        and c.xmldata.name = 'xlink-config';

     -- no need to alter type since this is not an object type
  end if;

  commit;
end;
/

/* End upgrade of XDBResConfig schema */

-- drop functions
drop function xdb$find_cmplx_type;

-- END from xdbs111.sql

Rem ================================================================
Rem BEGIN XDB Schemas Upgrade from the next release
Rem ================================================================

@@xdbus112.sql

