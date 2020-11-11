Rem
Rem $Header: rdbms/admin/xdbus112.sql /main/4 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbus112.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbus112.sql - XDB Upgrade Schemas from release 11.2.0
Rem
Rem    DESCRIPTION
Rem     This script upgrades the XDB Schemas from release 11.2.0
Rem     to the current release.  Content formerly in xdbs112.sql
Rem
Rem    NOTES
Rem     It is invoked by xdbus.sql, and invokes the xdbusNNN script for the 
Rem     subsequent release.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbus112.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbus112.sql 
Rem    SQL_PHASE: UPGRADE 
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbus.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         07/25/16 - add file metadata
Rem    ckavoor     11/19/15 - 18938910:convert the INSERT into dynamic SQL
Rem    prthiaga    12/10/13 - backout realm changes
Rem    raeburns    10/25/13 - XDB upgrade restructure
Rem    dmelinge    10/14/13 - Fix xdb context, lrg 9965449
Rem    dmelinge    08/26/13 - Realm changes, bug 17074378
Rem    prthiaga    08/16/13 - Bug 17322893 - Fix prop-num logic
Rem                           in xdb$upgradeConfigFtpHostName 
Rem    dmelinge    06/28/13 - Realm from sys.props, bug 16278103
Rem    rpang       11/01/12 - 4892564: add new enum values for EPG
Rem    dmelinge    04/05/12 - Upgrade IP hostname, bug 13917375
Rem    thbaby      04/02/12 - (moved to xdbuo112.sql) add xdb.xdb$cdbports
Rem    shvenugo    11/07/11 - lrg 5556182 - add fix for 9304342
Rem    qyu         08/04/11 - (moved to xdbuo112.sql)long identifier proj 
Rem    thbaby      07/18/11 - Created

Rem ================================================================
Rem BEGIN XDB Schema Upgrade from 11.2.0
Rem ================================================================

-- BEGIN MOVED FROM xdbs112.sql

-- Add the white-list element under the httpconfig element
--  <element name="white-list">
--    <complexType>
--      <sequence>
--        <element name="white-list-pattern" minOccurs="0" maxOccurs="unbounded">
--          <simpleType>
--            <restriction base="string">
--              <pattern value="(/[^\*/]+)*(/\*)?"/>
--            </restriction>
--          </simpleType>
--        </element>
--      </sequence>
--    </complexType>
--  </element>
SET SERVEROUTPUT ON

declare
  schema_url     VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  CONFIG_PROPNUMS CONSTANT INTEGER := 207;
  refhttptype    REF SYS.XMLTYPE;
  refskidhttp    REF SYS.XMLTYPE;
  skidhttpelems  XDB.XDB$XMLTYPE_REF_LIST_T;
  config_sch_ref   REF SYS.XMLTYPE;
  whitelistpattype REF SYS.XMLTYPE;
  whitelistpatelt  REF SYS.XMLTYPE;
  whitelistctseq   REF SYS.XMLTYPE;
  whitelistct      REF SYS.XMLTYPE;
  whitelistelement REF SYS.XMLTYPE;
  skidwhitelist    XDB.XDB$XMLTYPE_REF_LIST_T;
  prop_propnum     INTEGER;
  numprops         INTEGER;
  r                REF SYS.XMLTYPE;
  anypart          VARCHAR2(4000);
begin
  -- Ensure that the number of props in xdbconfig schema before the 
  -- upgrade is 205
  select s.xmldata.num_props into numprops
  from xdb.xdb$schema s
  where s.xmldata.schema_url = schema_url;
  if numprops <> 205 then
    dbms_output.put_line('number of props should be 205');
    dbms_output.put_line('number of props was ' || numprops);
  end if;

  select ref(s) into config_sch_ref
  from xdb.xdb$schema s
  where s.xmldata.schema_url = schema_url;

  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid, m.xmldata.elements 
    into refhttptype, refskidhttp, skidhttpelems 
    from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where e.xmldata.property.name ='httpconfig' 
     and e.xmldata.property.parent_schema = config_sch_ref
     and ref(c) = e.xmldata.cplx_type_decl
     and ref(m) = c.xmldata.sequence_kid;

  r := dbms_xdbmig_util.find_child(skidhttpelems, 'white-list');
  if r is null then
  -- create simple type for white-list-pattern
/*
select st.xmlextra, st.xmldata 
from xdb.xdb$simple_type st 
where ref(st) in (select e.xmldata.property.smpl_type_decl from xdb.xdb$element e where e.xmldata.property.name='white-list-pattern');
*/
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
                   '(/[^\*/]+)*(/\*)?', 
                   '00', NULL)), 
               NULL, NULL, NULL), 
             NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(st) into whitelistpattype;
    dbms_output.put_line('simple type for white-list-pattern created');

    -- create white-list-pattern element
/*
select e.xmlextra, e.xmldata 
from xdb.xdb$element e 
where e.xmldata.property.name='white-list-pattern';
*/
    prop_propnum := xdb.xdb$propnum_seq.nextval;
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata)
    values(dbms_xdbmig_util.getConfigXtra,
           XDB.XDB$ELEMENT_T(
             XDB.XDB$PROPERTY_T(
               XDB.XDB$RAW_LIST_T('839A10200080030C000000043233010809181B23262A343503150C07292728'), 
               config_sch_ref, 
               prop_propnum, --white-list-pattern-prop-num
               'white-list-pattern', NULL, NULL, '01', '00', 
               '00', NULL, NULL, 'string', NULL, NULL, NULL, 
               whitelistpattype, whitelistpattype, 
               NULL, NULL, NULL, NULL, '00', NULL, NULL, 
               NULL, '00', NULL, NULL, '00'), 
             NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, 
             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'unbounded', 
             '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into whitelistpatelt;
    dbms_output.put_line('white-list-pattern element created');

    -- create sequence(white-list-pattern)
/*
select s.xmldata from xdb.xdb$sequence_model s where ref(s) = (select ct.xmldata.sequence_kid from xdb.xdb$complex_type ct where ref(ct) = (select e.xmldata.cplx_type_decl from xdb.xdb$element e where e.xmldata.property.name='white-list'));
*/
    skidwhitelist := XDB.XDB$XMLTYPE_REF_LIST_T();
    skidwhitelist.extend(1);
    skidwhitelist(1) := whitelistpatelt;

    insert into xdb.xdb$sequence_model s (s.xmlextra, s.xmldata)
    values(dbms_xdbmig_util.getConfigXtra,
           XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23020000000107'), 
           config_sch_ref, 0, NULL, skidwhitelist,
           NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(s) into whitelistctseq;
    dbms_output.put_line('sequence for white-list created');

    -- create annotation for the type of white-list
    anypart := dbms_xdbmig_util.buildAnnotationKidList(skidwhitelist, null);

    -- create complex type for white-list
/*
select ct.xmldata from xdb.xdb$complex_type ct where ref(ct) = (select e.xmldata.cplx_type_decl from xdb.xdb$element e where e.xmldata.property.name='white-list');
*/
/*18938910: convert the INSERT into dynamic SQL */

 EXECUTE IMMEDIATE
   'insert into xdb.xdb$complex_type ct (ct.xmlextra, ct.xmldata)
    values(dbms_xdbmig_util.getConfigXtra,
           XDB.XDB$COMPLEX_T(
             XDB.XDB$RAW_LIST_T(''33090000000000030D0E13''),
             :config_sch_ref, NULL, NULL, ''00'', ''00'',
             NULL, NULL, NULL, NULL, NULL, NULL, NULL,
             :whitelistctseq, NULL, NULL,
             XDB.XDB$ANNOTATION_T(
               XDB.XDB$RAW_LIST_T(''1301000000''),
               XDB.XDB$APPINFO_LIST_T(
                 XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T(''1301000000''), :anypart,
                 NULL)),
               NULL),
             NULL, NULL, ''01'', NULL, NULL, NULL, NULL)) 
            returning ref(ct) into :whitelistct '
    using config_sch_ref, whitelistctseq, anypart, OUT whitelistct;
    dbms_output.put_line('complex type for white-list created');

    -- create white-list element
/*
select e.xmlextra, e.xmldata 
from xdb.xdb$element e 
where e.xmldata.property.name='white-list';
*/
    prop_propnum := xdb.xdb$propnum_seq.nextval;
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata)
    values(dbms_xdbmig_util.getConfigXtra,
           XDB.XDB$ELEMENT_T(
             XDB.XDB$PROPERTY_T(
               XDB.XDB$RAW_LIST_T('839800201080030400000004321C0809181B23262A3435031507292728'), 
               config_sch_ref, 
               prop_propnum, --white-list-prop-num
               'white-list', NULL, NULL, '0102', '00',
               '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
               whitelistct, NULL, NULL, NULL, NULL,
               '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), 
             NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, 
             NULL, NULL, NULL, NULL, NULL, 
             whitelistct, NULL, NULL, 0, NULL, '00', '01', 
             NULL, NULL, NULL, NULL, 
             NULL, NULL, NULL, NULL))
    returning ref(e) into whitelistelement;
    dbms_output.put_line('white-list element created');

    skidhttpelems.extend(1);
    skidhttpelems(skidhttpelems.last) := whitelistelement;
    dbms_output.put_line('added white-list to http elem list');


 /*
select m.xmldata.sys_xdbpd$ from xdb.xdb$schema s, xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m where ref(s) = e.xmldata.property.parent_schema and s.xmldata.schema_url like '%xdbconfig.12%' and e.xmldata.property.name ='httpconfig' and ref(c) = e.xmldata.cplx_type_decl and ref(m) = c.xmldata.sequence_kid;
*/
    update xdb.xdb$sequence_model m
       set m.xmldata.elements   = skidhttpelems,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('23020001000218FB014D2077686974652D6C6973742077617320616464656420696E2031322E3120746F2070726F7669646520610A2020202020202020202020202020202020202020202020202020202020202077617920666F72206F6E6C79206365727461696E2055524C7320746F206265206578706F7365640A202020202020202020202020202020202020202020202020202020202020207468726F75676820485454502E20496E2031322E312C2074686520696E74656E74696F6E207761730A2020202020202020202020202020202020202020202020202020202020202074686174206F6E6C79207468652055524C20636F72726573706F6E64696E6720746F2074686520454D0A202020202020202020202020202020202020202020202020202020202020204578707265737320736572766C65742077696C6C206265206578706F7365642062792064656661756C742081801907')
     where ref(m)= refskidhttp;
    dbms_output.put_line('updated sequence kid and PD of httconfig');
  
    -- update annotations for the complex type declaration for httpconfig
    anypart := dbms_xdbmig_util.buildAnnotationKidList(skidhttpelems, null);
  
/*
select c.xmldata.annotation.appinfo, c.xmldata.annotation.sys_xdbpd$ from xdb.xdb$schema s, xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m where ref(s) = e.xmldata.property.parent_schema and s.xmldata.schema_url like '%xdbconfig.12%' and e.xmldata.property.name ='httpconfig' and ref(c) = e.xmldata.cplx_type_decl and ref(m) = c.xmldata.sequence_kid;
*/
    update xdb.xdb$complex_type c
       set c.xmldata.annotation.appinfo = 
              XDB.XDB$APPINFO_LIST_T(
                  XDB.XDB$APPINFO_T(
                    XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)),
           c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000') 
     where c.xmldata.parent_schema = config_sch_ref 
       and ref(c)=refhttptype;  
  
    commit;
  end if;

  update xdb.xdb$schema s 
     set s.xmldata.num_props = CONFIG_PROPNUMS
   where ref(s) = config_sch_ref;
  commit;
end;
/

show errors;
SET SERVEROUTPUT OFF

-- add the session-state-cache-param element under the servlet element
--<element name="session-state-cache-param" minOccurs="0">
--    <complexType>  
--      <sequence>     
--        <element name="cache-size" type="unsignedInt"/>
--        <element name="expiration-timeout" type="unsignedInt"/>
--      </sequence>    
--    </complexType> 
--  </element>     

SET SERVEROUTPUT ON

declare
  schema_url     VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  CONFIG_PROPNUMS CONSTANT INTEGER := 210;
  refservlettype   REF SYS.XMLTYPE;
  refskidservlet   REF SYS.XMLTYPE;
  schoiceservlet   XDB.XDB$XMLTYPE_REF_LIST_T;
  skidservlet      XDB.XDB$XMLTYPE_REF_LIST_T;
  ckidservlet      XDB.XDB$XMLTYPE_REF_LIST_T;
  allkidservlet    XDB.XDB$XMLTYPE_REF_LIST_T;
  config_sch_ref   REF SYS.XMLTYPE;
  cachesizeelt     REF SYS.XMLTYPE;
  exptimeelt       REF SYS.XMLTYPE;
  sescachectseq    REF SYS.XMLTYPE;
  sescachect       REF SYS.XMLTYPE;
  sescacheelement  REF SYS.XMLTYPE;
  skidsescachelist XDB.XDB$XMLTYPE_REF_LIST_T;
  i                INTEGER;
  prop_propnum     INTEGER;
  r                REF SYS.XMLTYPE;
  anypart          VARCHAR2(4000);
begin
  select ref(s) into config_sch_ref
  from xdb.xdb$schema s
  where s.xmldata.schema_url = schema_url;

  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid, 
         m.xmldata.elements, m.xmldata.choice_kids
    into refservlettype, refskidservlet, skidservlet , schoiceservlet
    from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where e.xmldata.property.name ='servlet' 
     and e.xmldata.property.parent_schema = config_sch_ref
     and ref(c) = e.xmldata.cplx_type_decl
     and ref(m) = c.xmldata.sequence_kid;

  -- servlet element is a complex type with a sequence. The sequence
  -- has a choice within it. Retrieve the elements under the choice.
  select m.xmldata.elements 
    into ckidservlet
    from xdb.xdb$choice_model m
   where ref(m)=schoiceservlet(1);

  allkidservlet := XDB.XDB$XMLTYPE_REF_LIST_T();
  allkidservlet.extend(skidservlet.count);
  allkidservlet.extend(ckidservlet.count);
  -- the choice appears within the sequence after the fifth element
  -- under the sequence. the choice has three elements under it. 
  for i in 1..5 loop
    allkidservlet(i) := skidservlet(i);
  end loop;
  for i in 1..3 loop
    allkidservlet(5+i) := ckidservlet(i);
  end loop;
  for i in 6..skidservlet.last loop
    allkidservlet(3+i) := skidservlet(i);
  end loop;

  r := dbms_xdbmig_util.find_child(skidservlet, 'session-state-cache-param');
  if r is null then
    -- create cache-size element
/*
select e.xmlextra, e.xmldata 
from xdb.xdb$element e 
where e.xmldata.property.name='cache-size';
*/
    prop_propnum := xdb.xdb$propnum_seq.nextval;
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata)
    values(dbms_xdbmig_util.getConfigXtra,
           XDB.XDB$ELEMENT_T(
             XDB.XDB$PROPERTY_T(
               XDB.XDB$RAW_LIST_T('83F810200080030000000004050809181B23262A32343503150C0706292728'), 
               config_sch_ref,
               prop_propnum, -- cache-size-propnum
              'cache-size', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', 
              '00', '00', NULL, NULL, 'unsigned-int', NULL, NULL, NULL,
              NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, 
              '00', NULL, NULL, '00'), 
            NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', 
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 
            NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into cachesizeelt;
    dbms_output.put_line('cache-size element created');

    -- create expiration-timeout element
/*
select e.xmlextra, e.xmldata 
from xdb.xdb$element e 
where e.xmldata.property.name='expiration-timeout';
*/
    prop_propnum := xdb.xdb$propnum_seq.nextval;
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata)
    values(dbms_xdbmig_util.getConfigXtra,
           XDB.XDB$ELEMENT_T(
             XDB.XDB$PROPERTY_T(
               XDB.XDB$RAW_LIST_T('83F810200080030000000004050809181B23262A32343503150C0706292728'), 
               config_sch_ref,
               prop_propnum, -- expiration-timeout propnum
               'expiration-timeout', XDB.XDB$QNAME('00', 'unsignedInt'), 
               '04', '44', '00', '00', NULL, NULL, 'unsigned-int', NULL, 
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', 
               NULL, NULL, NULL, '00', NULL, NULL, '00'), 
             NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL,
             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', 
             '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into exptimeelt;
    dbms_output.put_line('expiration-timeout element created');

    -- create sequence(cache-size, expiration-timeout)
/*
select s.xmldata from xdb.xdb$sequence_model s where ref(s) = (select ct.xmldata.sequence_kid from xdb.xdb$complex_type ct where ref(ct) = (select e.xmldata.cplx_type_decl from xdb.xdb$element e where e.xmldata.property.name='session-state-cache-param'));
*/
    skidsescachelist := XDB.XDB$XMLTYPE_REF_LIST_T();
    skidsescachelist.extend(2);
    skidsescachelist(1) := cachesizeelt;
    skidsescachelist(2) := exptimeelt;

    insert into xdb.xdb$sequence_model s (s.xmlextra, s.xmldata)
    values(dbms_xdbmig_util.getConfigXtra,
           XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('230200000081800207'), 
           config_sch_ref, 0, NULL, skidsescachelist, 
           NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(s) into sescachectseq;
    dbms_output.put_line('sequence for (cache-size, expiration-timeout) created');

    -- create annotation for the type of white-list
    anypart := dbms_xdbmig_util.buildAnnotationKidList(skidsescachelist, null);

    -- create complex type for session-state-cache-param
/*
select ct.xmldata from xdb.xdb$complex_type ct where ref(ct) = (select e.xmldata.cplx_type_decl from xdb.xdb$element e where e.xmldata.property.name='session-state-cache-param');
*/
/*18938910: convert the INSERT into dynamic SQL */

  EXECUTE IMMEDIATE
    'insert into xdb.xdb$complex_type ct (ct.xmlextra, ct.xmldata)
    values(dbms_xdbmig_util.getConfigXtra,
           XDB.XDB$COMPLEX_T( 
		     XDB.XDB$RAW_LIST_T(''33090000000000030D0E13''),
             :config_sch_ref, NULL, NULL, ''00'', ''00'',
             NULL, NULL, NULL, NULL, NULL, NULL, NULL,
             :sescachectseq, NULL, NULL,
             XDB.XDB$ANNOTATION_T(
               XDB.XDB$RAW_LIST_T(''1301000000''),
               XDB.XDB$APPINFO_LIST_T(
                 XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T(''1301000000''), :anypart,
                 NULL)),
               NULL),
             NULL, NULL, ''01'', NULL, NULL, NULL, NULL)) 
             returning ref(ct) into :sescachect'
    using config_sch_ref, sescachectseq, anypart, OUT sescachect;
    dbms_output.put_line('complex type for session-state-cache-param created');

    -- create session-state-cache-param element
/*
select e.xmlextra, e.xmldata 
from xdb.xdb$element e 
where e.xmldata.property.name='session-state-cache-param';
*/
    prop_propnum := xdb.xdb$propnum_seq.nextval;
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata)
    values(dbms_xdbmig_util.getConfigXtra,
           XDB.XDB$ELEMENT_T(
             XDB.XDB$PROPERTY_T(
               XDB.XDB$RAW_LIST_T('839800201080030400000004321C0809181B23262A3435031507292728'), 
               config_sch_ref, 
               prop_propnum, -- session-state-cache-param propnum
               'session-state-cache-param', NULL, NULL, '0102', '00', '00', 
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
               sescachect, NULL, NULL, NULL, NULL, 
               '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), 
             NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, 
             NULL, NULL, NULL, NULL, NULL, 
             sescachect, NULL, NULL, 0, NULL, '00', '01', 
             NULL, NULL, NULL, NULL, 
             NULL, NULL, NULL, NULL))
    returning ref(e) into sescacheelement;
    dbms_output.put_line('session-state-cache-param element created');

    skidservlet.extend(1);
    skidservlet(skidservlet.last) := sescacheelement;
    
    allkidservlet.extend(1);
    allkidservlet(allkidservlet.last) := sescacheelement;
    dbms_output.put_line('added session-state-cache-param to servlet elem list');

/*
select m.xmldata.sys_xdbpd$ from xdb.xdb$schema s, xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m where ref(s) = e.xmldata.property.parent_schema and s.xmldata.schema_url like '%xdbconfig.12%' and e.xmldata.property.name ='servlet' and ref(c) = e.xmldata.cplx_type_decl and ref(m) = c.xmldata.sequence_kid;
*/
    update xdb.xdb$sequence_model m
       set m.xmldata.elements   = skidservlet,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('2306000100020AB32073657373696F6E2D73746174652D63616368652D706172616D20636170747572657320616C6C2074686520706172616D65746572730A20202020202020202020202020202020202020202020206F66207468652073657373696F6E2073746174652063616368652E2065787069726174696F6E2D74696D656F75742069730A202020202020202020202020202020202020202020202073706563696669656420696E2063656E74692D7365636F6E64732E208180050281800507')
     where ref(m)= refskidservlet;
    dbms_output.put_line('updated sequence kid and PD of servlet');
  
    -- update annotations for the complex type declaration for servlet
    -- annotations are built using the list of elements obtained by
    -- merging the list of elements in the servlet sequence and the list
    -- of elements in the choice under that sequence
    anypart := dbms_xdbmig_util.buildAnnotationKidList(allkidservlet, null);
  
/*
select c.xmldata.annotation.appinfo, c.xmldata.annotation.sys_xdbpd$ from xdb.xdb$schema s, xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m where ref(s) = e.xmldata.property.parent_schema and s.xmldata.schema_url like '%xdbconfig.12%' and e.xmldata.property.name ='servlet' and ref(c) = e.xmldata.cplx_type_decl and ref(m) = c.xmldata.sequence_kid;
*/
    update xdb.xdb$complex_type c
       set c.xmldata.annotation.appinfo = 
              XDB.XDB$APPINFO_LIST_T(
                  XDB.XDB$APPINFO_T(
                    XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)),
           c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000') 
     where c.xmldata.parent_schema = config_sch_ref 
       and ref(c)=refservlettype;  
  
    commit;
  end if;

  update xdb.xdb$schema s 
     set s.xmldata.num_props = CONFIG_PROPNUMS
   where ref(s) = config_sch_ref;
  commit;
end;
/

show errors;
SET SERVEROUTPUT OFF


---------------------------------------------------------
-- Start upgrading xdbconfig for (ftp) host-name
-- /xdbconfig/sysconfig/protocolconfig/ftpconfig/host-name
---------------------------------------------------------
create or replace procedure xdb$upgradeConfigFtpHostName as
  i              NUMBER(38);
  pnum           NUMBER(38);
  numprops       NUMBER(38);
  elem_propnum   NUMBER(38);
  cplx_ref       REF SYS.XMLTYPE;
  seq_ref        REF SYS.XMLTYPE;
  confsch_ref    REF SYS.XMLTYPE;
  element_ref    REF SYS.XMLTYPE;
  simpletype_ref REF SYS.XMLTYPE;
  seq_elems      XDB.XDB$XMLTYPE_REF_LIST_T;
  anypart        VARCHAR2(4000);
  confsch_url    VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  hostnamerecs   NUMBER(38); 
begin
  -- ref to xdbconfig schema
  select ref(s) into confsch_ref
  from xdb.xdb$schema s
  where s.xmldata.schema_url = confsch_url;

  -- ref to complex type (ftpconfig anonymous complex type)
  select e.xmldata.cplx_type_decl into cplx_ref from xdb.xdb$element e
  where e.xmldata.property.name = 'ftpconfig' and
        e.xmldata.property.parent_schema = confsch_ref;

  -- ref to sequence (ftpconfig complex type sequence)
  select c.xmldata.sequence_kid into seq_ref from xdb.xdb$complex_type c
  where ref(c) = cplx_ref;

  -- sequence elements 
  select m.xmldata.elements into seq_elems
  from xdb.xdb$sequence_model m where ref(m) = seq_ref;
  
  -- before doing upgrade (used for checking only)
  select s.xmldata.num_props into numprops
  from xdb.xdb$schema s
  where s.xmldata.schema_url = confsch_url;

  -- already upgraded?
  --if (numprops >= NUM_PROPS) then
  --  dbms_output.put_line ('xdbconfig schema already upgraded for ftp host-name');
  --  return;
  --end if;
  
  -- If we already have host-name, do not add again
  select count(*) into hostnamerecs
  from xdb.xdb$element e 
  where e.xmldata.property.name='host-name' and 
  e.xmldata.property.parent_schema = confsch_ref ;

  if (hostnamerecs > 0) then
    dbms_output.put_line('xdbconfig schema upgraded, already there');
    return;
  end if;

 -- create (ftp) host-name element
  pnum := xdb.xdb$propnum_seq.nextval;
  insert into xdb.xdb$element e (e.xmlextra, e.xmldata)
   values (XMLTYPEEXTRA(XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B810200080030C000000040532330809181B23262A343503150C07292728'), confsch_ref, pnum, 'host-name', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, NULL, 'string', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
 returning ref(e) into element_ref; 
  -- add one element to the end of varray;
  seq_elems.extend(1);
  seq_elems(seq_elems.last) := element_ref;

  -- update element and PD for seq kid of ftpconfig
  update xdb.xdb$sequence_model m set m.xmldata.elements = seq_elems, m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800907') where ref(m) = seq_ref;

  -- update annotations for the complex type declaration for sysconfig
  anypart := '<xdb:kidList xmlns:xdb="http://xmlns.oracle.com/xdb" sequential="true">';
  for i in 1..seq_elems.last loop
     select e.xmldata.property.prop_number into elem_propnum from xdb.xdb$element e
     where ref(e) = seq_elems(i);
     anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propnum || '" kidNum="' || (i-1) || '"/>';
  end loop;
  anypart := anypart || chr(10) || '</xdb:kidList>';

  update xdb.xdb$complex_type c
  set c.xmldata.annotation.appinfo = XDB.XDB$APPINFO_LIST_T(XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL))
  where c.xmldata.parent_schema = confsch_ref and ref(c) = cplx_ref;

  -- update num_props for schema
  update xdb.xdb$schema s set s.xmldata.num_props = (s.xmldata.num_props + 1)
  where s.xmldata.schema_url = confsch_url;

  commit;
end;
/
show errors;
exec xdb$upgradeConfigFtpHostName;
--cleanup
drop procedure xdb$upgradeConfigFtpHostName;
---------------------------------------------------------
-- end upgrading xdbconfig for (ftp) host-name 
---------------------------------------------------------

-- Upgrade enum type of input-filter-element to
-- <element name="input-filter-enable">
--   <simpleType>
--     <restriction base="string">
--       <enumeration value="On"/>
--       <enumeration value="Off"/>
--       <enumeration value="SecurityOn"/>
--       <enumeration value="SecurityOff"/>
--     </restriction>
--   </simpleType>
-- </element>
declare
  schema_url     VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  config_sch_ref REF SYS.XMLTYPE;
begin

  select ref(s) into config_sch_ref
    from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

/*
select s.xmlextra, s.xmldata from xdb.xdb$simple_type s
 where ref(s) = (select e.xmldata.property.type_ref from xdb.xdb$element e
                  where e.xmldata.property.name ='input-filter-enable');
*/

  -- update emum type
  update xdb.xdb$simple_type s
     set s.xmldata.restriction = XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8004'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'On', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Off', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'SecurityOn', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'SecurityOff', '00', NULL)), NULL, NULL)
   where ref(s) = (select e.xmldata.property.type_ref from xdb.xdb$element e
                    where e.xmldata.property.parent_schema = config_sch_ref
                      and e.xmldata.property.name ='input-filter-enable');
  commit;
end;
/

-- END MOVED FROM xdbs112.sql

Rem ================================================================
Rem END XDB Schema Upgrade from 11.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Schema Upgrade from the next release
Rem ================================================================

@@xdbus121.sql

