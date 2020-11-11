Rem
Rem $Header: rdbms/admin/xdbes112.sql /main/17 2017/04/04 09:12:44 raeburns Exp $
Rem
Rem xdbes112.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbes112.sql - XDB Schema Downgrade
Rem
Rem    DESCRIPTION
Rem      This script downgrades XDB schemas to 11.2
Rem
Rem    NOTES
Rem      It is invoked from xdbdwgrd.sql and xdbes111.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbes112.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbes112.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/xdbdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    sriksure    07/20/16 - Bug 22967968 - Moving inline XML schemas to
Rem                           external schema files
Rem    joalvizo    03/28/16 - Remove the reloads
Rem    joalvizo    02/18/16 - lrg 19277463
Rem    huiz        10/19/15 - lrg 18677101 
Rem    huiz        10/07/15 - bug 21960981: delete/reregister XDBStandard.xsd 
Rem    raeburns    11/27/13 - add 12.1 downgrade
Rem    prthiaga    08/15/13 - Bug 17322893 : Remove hardcoded prop-nums from 
Rem                           downgradeConfigHostName
Rem    rpang       03/25/13 - 16546969: skip #4892564 xdbconfig downgrade for
Rem                           11.2.0.4
Rem    hxzhang     01/22/13 - XbranchMerge hxzhang_bug-16092359_2 from
Rem                           st_rdbms_12.1.0.1
Rem    hxzhang     01/15/13 - add back servlet element 
Rem    rpang       11/01/12 - 4892564: remove new enum values for EPG
Rem    dmelinge    04/10/12 - Upgrade IP hostname, bug 13917375
Rem    thbaby      04/02/12 - drop table xdb.xdb$cdbports
Rem    bhammers    11/01/11 - lrg 6000890
Rem    juding      07/29/11 - bug 12622803: move
Rem                                         drop function sys.getUserIdOnTarget
Rem                                         from xdbeu112.sql
Rem    juding      07/29/11 - bug 12622803: Created from split of xdbe112.sql
Rem    bhammers    05/25/11 - Created
Rem

Rem ================================================================
Rem BEGIN XDB Schema downgrade to 12.1.0
Rem ================================================================

@@xdbes121.sql

Rem ================================================================
Rem END XDB Schema downgrade to 12.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Schema downgrade to 11.2.0
Rem ================================================================

-- utility functions may not have been dropped during prior upgrade from 11.1
-- drop them here
@@xdbuud2

Rem Load XDB upgrade downgrade utilities (dbms_xdbmig_util)
@@prvtxudu.plb

--select OBJECT_NAME, STATUS from dba_objects where owner = 'XDB' and OBJECT_NAME like '%XDBUTIL%';

--@@dbmsxdb.sql

--@@prvtxdb.plb

--select OBJECT_NAME, STATUS from dba_objects where owner = 'XDB' and OBJECT_NAME like '%XDBUTIL%';

execute dbms_session.reset_package;

@@catxdbh

--first remove XDBStandard.xsd and then re-register it; if there are 
--dependants on the schema, use CopyEvolve instead.
declare
     c NUMBER;
     n integer;
     file_len INTEGER;
     content CLOB;
     newsch   XMLSequenceType;
     urls     XDB$STRING_LIST_T;
     schowner XDB$STRING_LIST_T;
     STDURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/XDBStandard.xsd';  
     STDXSD BFILE := dbms_metadata_hack.get_bfile('xdbstandard.xsd.11.2');

  has_dependants EXCEPTION;
  PRAGMA EXCEPTION_INIT(has_dependants,-31088);
begin
  select count(1) into c from xdb.xdb$schema s
    where s.xmldata.schema_url = STDURL;

  if (c > 0) then
    dbms_xmlschema.deleteschema(STDURL, dbms_xmlschema.delete_cascade);
  end if;

  select count(1) into n from xdb.xdb$schema s
  where s.xmldata.schema_url = STDURL;

  dbms_metadata_hack.cre_dir();
  if (n = 0) then
    xdb.dbms_xmlschema.registerSchema(STDURL, STDXSD, FALSE, TRUE, 
                                      FALSE, TRUE, FALSE, 'XDB');
  end if;

  exception
    when has_dependants then
      begin
        urls := XDB$STRING_LIST_T(STDURL);

        dbms_lob.fileopen(STDXSD);
        file_len := dbms_lob.getlength(STDXSD);
        dbms_lob.createtemporary(content, FALSE);
        DBMS_LOB.loadfromfile(content, STDXSD, file_len);
        newsch := XMLSequenceType(xmltype(content));
        dbms_lob.close(STDXSD);
        dbms_lob.freetemporary(content);

        schowner := XDB$STRING_LIST_T('XDB');
        dbms_xmlschema.CopyEvolve(urls, newsch, NULL, FALSE, NULL,TRUE,
                                  FALSE, schowner);
      end;
    when others then
        dbms_lob.close(STDXSD);
        dbms_lob.freetemporary(content);
        raise;
end;
/

commit;

select OBJECT_NAME, STATUS from dba_objects where owner = 'XDB' and OBJECT_NAME like '%SERVLET%';

REM ************************************
REM Remove xdb manageability tools BEGIN
REM ************************************
@@catremxutil.sql
@@catremvxutil.sql

REM ************************************
REM Remove xdb manageability tools END
REM ************************************
-- remove the session-state-cache-param element under the servlet element
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
  CONFIG_PROPNUMS CONSTANT INTEGER := 207;
  sescachectseq    REF SYS.XMLTYPE;
  skidsescachelist XDB.XDB$XMLTYPE_REF_LIST_T;
  prop_propnum     INTEGER;
  r                REF SYS.XMLTYPE;
  anypart          VARCHAR2(4000);
  i                INTEGER;
  schema_url     VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  config_sch_ref   REF SYS.XMLTYPE;
  refservlettype   REF SYS.XMLTYPE;
  refskidservlet   REF SYS.XMLTYPE;
  schoiceservlet   XDB.XDB$XMLTYPE_REF_LIST_T;
  skidservlet      XDB.XDB$XMLTYPE_REF_LIST_T;
  ckidservlet      XDB.XDB$XMLTYPE_REF_LIST_T;
  allkidservlet    XDB.XDB$XMLTYPE_REF_LIST_T;
  refsescacheelt   REF SYS.XMLTYPE;
  refsescachectype REF SYS.XMLTYPE;
  refsescacheskid  REF SYS.XMLTYPE;
  refcachesizeelt  REF SYS.XMLTYPE;
  refexptimeelt    REF SYS.XMLTYPE;  
  isfound          BOOLEAN;
begin
  select ref(s) into config_sch_ref
  from xdb.xdb$schema s
  where s.xmldata.schema_url = schema_url;

  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid, 
         m.xmldata.elements, m.xmldata.choice_kids
    into refservlettype, refskidservlet, skidservlet, schoiceservlet
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
  if r is not null then
    select ref(e), e.xmldata.cplx_type_decl, c.xmldata.sequence_kid
      into refsescacheelt, refsescachectype, refsescacheskid
      from xdb.xdb$element e, xdb.xdb$complex_type c
     where e.xmldata.property.name ='session-state-cache-param' 
       and e.xmldata.property.parent_schema = config_sch_ref
       and ref(c) = e.xmldata.cplx_type_decl;

    select ref(e) into refcachesizeelt
      from xdb.xdb$element e
     where e.xmldata.property.name='cache-size'
       and e.xmldata.property.parent_schema = config_sch_ref;

    select ref(e) into refexptimeelt
      from xdb.xdb$element e
     where e.xmldata.property.name='expiration-timeout'
       and e.xmldata.property.parent_schema = config_sch_ref;

    delete from xdb.xdb$element e where ref(e)=refsescacheelt;
    delete from xdb.xdb$complex_type c where ref(c)=refsescachectype;
    delete from xdb.xdb$sequence_model m where ref(m)=refsescacheskid;
    delete from xdb.xdb$element e where ref(e)=refcachesizeelt;
    delete from xdb.xdb$element e where ref(e)=refexptimeelt;
    dbms_output.put_line('removed cache-size element');
    dbms_output.put_line('removed expiration-timeout element');
    dbms_output.put_line('removed complex type and sequence of session-state-cache-param element');
    dbms_output.put_line('removed session-state-cache-param element');

    isfound := FALSE;
    for i in 1..skidservlet.last loop
      if (not (isfound)) then
        if (skidservlet(i) = refsescacheelt) then
          isfound := TRUE;
        end if;
      else
        skidservlet(i-1) := skidservlet(i);
      end if;
    end loop;
    skidservlet.trim(1);

    isfound := FALSE;
    for i in 1..allkidservlet.last loop
      if (not (isfound)) then
        if (allkidservlet(i) = refsescacheelt) then
          isfound := TRUE;
        end if;
      else
        allkidservlet(i-1) := allkidservlet(i);
      end if;
    end loop;
    allkidservlet.trim(1);
/*
select m.xmldata.sys_xdbpd$ from xdb.xdb$schema s, xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m where ref(s) = e.xmldata.property.parent_schema and s.xmldata.schema_url like '%xdbconfig.11.2%' and e.xmldata.property.name ='servlet' and ref(c) = e.xmldata.cplx_type_decl and ref(m) = c.xmldata.sequence_kid;
*/
    update xdb.xdb$sequence_model m
       set m.xmldata.elements   = skidservlet,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('23060000008180050281800407')
     where ref(m)= refskidservlet;
    dbms_output.put_line('updated sequence kid and PD of servlet');
  
    -- update annotations for the complex type declaration for servlet
    -- annotations are built using the list of elements obtained by
    -- merging the list of elements in the servlet sequence and the list
    -- of elements in the choice under that sequence
    anypart := dbms_xdbmig_util.buildAnnotationKidList(allkidservlet, null);
  
/*
select c.xmldata.annotation.appinfo, c.xmldata.annotation.sys_xdbpd$ from xdb.xdb$schema s, xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m where ref(s) = e.xmldata.property.parent_schema and s.xmldata.schema_url like '%xdbconfig.11.2%' and e.xmldata.property.name ='servlet' and ref(c) = e.xmldata.cplx_type_decl and ref(m) = c.xmldata.sequence_kid;
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

-- remove the 'white-list' element under the httpconfig element
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
  CONFIG_PROPNUMS CONSTANT INTEGER := 205;
  prop_propnum INTEGER;
  r            REF SYS.XMLTYPE;
  anypart      VARCHAR2(4000);
  i            INTEGER;
  schema_url   VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  config_sch_ref      REF SYS.XMLTYPE;
  refhttpconfigtype   REF SYS.XMLTYPE;
  refskidhttpconfig   REF SYS.XMLTYPE;
  skidhttpconfig      XDB.XDB$XMLTYPE_REF_LIST_T;
  refwhitelelt        REF SYS.XMLTYPE;
  refwhitelctype      REF SYS.XMLTYPE;
  refwhitelskid       REF SYS.XMLTYPE;
  refwhitelpatelt     REF SYS.XMLTYPE;
  refwhitelpatst      REF SYS.XMLTYPE;
  isfound             BOOLEAN;
begin
  select ref(s) into config_sch_ref
  from xdb.xdb$schema s
  where s.xmldata.schema_url = schema_url;

  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid, m.xmldata.elements 
    into refhttpconfigtype, refskidhttpconfig, skidhttpconfig 
    from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where e.xmldata.property.name ='httpconfig' 
     and e.xmldata.property.parent_schema = config_sch_ref
     and ref(c) = e.xmldata.cplx_type_decl
     and ref(m) = c.xmldata.sequence_kid;

  r := dbms_xdbmig_util.find_child(skidhttpconfig, 'white-list');
  if r is not null then
    select ref(e), e.xmldata.cplx_type_decl, c.xmldata.sequence_kid
      into refwhitelelt, refwhitelctype, refwhitelskid
      from xdb.xdb$element e, xdb.xdb$complex_type c
     where e.xmldata.property.name ='white-list' 
       and e.xmldata.property.parent_schema = config_sch_ref
       and ref(c) = e.xmldata.cplx_type_decl;

    select ref(e), e.xmldata.property.smpl_type_decl 
      into refwhitelpatelt, refwhitelpatst
      from xdb.xdb$element e
     where e.xmldata.property.name='white-list-pattern'
       and e.xmldata.property.parent_schema = config_sch_ref;

    delete from xdb.xdb$element e where ref(e)=refwhitelelt;
    delete from xdb.xdb$complex_type c where ref(c)=refwhitelctype;
    delete from xdb.xdb$sequence_model m where ref(m)=refwhitelskid;
    delete from xdb.xdb$element e where ref(e)=refwhitelpatelt;
    delete from xdb.xdb$simple_type s where ref(s)=refwhitelpatst;

    dbms_output.put_line('removed simple type of white-list-pattern element');
    dbms_output.put_line('removed white-list-pattern element');
    dbms_output.put_line('removed complex type and sequence of white-list element');
    dbms_output.put_line('removed white-list element');

    isfound := FALSE;
    for i in 1..skidhttpconfig.last loop
      if (not (isfound)) then
        if (skidhttpconfig(i) = refwhitelelt) then
          isfound := TRUE;
        end if;
      else
        skidhttpconfig(i-1) := skidhttpconfig(i);
      end if;
    end loop;
    skidhttpconfig.trim(1);

/*
select m.xmldata.sys_xdbpd$ from xdb.xdb$schema s, xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m where ref(s) = e.xmldata.property.parent_schema and s.xmldata.schema_url like '%xdbconfig.11.2%' and e.xmldata.property.name ='httpconfig' and ref(c) = e.xmldata.cplx_type_decl and ref(m) = c.xmldata.sequence_kid;
*/
    update xdb.xdb$sequence_model m
       set m.xmldata.elements   = skidhttpconfig,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081801807')
     where ref(m)= refskidhttpconfig;
    dbms_output.put_line('updated sequence kid and PD of httpconfig');
  
    -- update annotations for the complex type declaration for httpconfig
    anypart := dbms_xdbmig_util.buildAnnotationKidList(skidhttpconfig, null);
  
/*
select c.xmldata.annotation.appinfo, c.xmldata.annotation.sys_xdbpd$ from xdb.xdb$schema s, xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m where ref(s) = e.xmldata.property.parent_schema and s.xmldata.schema_url like '%xdbconfig.11.2%' and e.xmldata.property.name ='httpconfig' and ref(c) = e.xmldata.cplx_type_decl and ref(m) = c.xmldata.sequence_kid;
*/
    update xdb.xdb$complex_type c
       set c.xmldata.annotation.appinfo = 
              XDB.XDB$APPINFO_LIST_T(
                  XDB.XDB$APPINFO_T(
                    XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)),
           c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000') 
     where c.xmldata.parent_schema = config_sch_ref 
       and ref(c)=refhttpconfigtype;  
  
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

Rem clean up updown utilities
@@dbmsxuducu.sql
Rem Load XDB upgrade downgrade utilities (dbms_xdbmig_util)
@@prvtxudu.plb

set serveroutput on

-- Resource container - mark mutable
declare
  res_schema_ref  REF XMLTYPE;
begin
  select ref(s) into res_schema_ref                                                   from xdb.xdb$schema s
  where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

  update xdb.xdb$attribute a
  set a.xmldata.MUTABLE = '00'
  where a.xmldata.parent_schema = res_schema_ref
    and a.xmldata.name = 'Container';
    
  commit;
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

/*-----------------------------------------------------------------------*/
/* Re-add:      */
/*   /xdbconfig/xdbc:custom-authentication-trust-type/trust-scheme/workgroup  */
/*-----------------------------------------------------------------------*/

declare
  schema_url           VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  refs                 REF SYS.XMLTYPE;
  numprops             NUMBER(38);
  refcauthtrusttype    REF SYS.XMLTYPE;
  cauthtrustskid       REF SYS.XMLTYPE;
  cauthtrustelems   XDB.XDB$XMLTYPE_REF_LIST_T;
  reftrustsch         REF SYS.XMLTYPE;
  refCtrustsch         REF SYS.XMLTYPE;
  trustschskid       REF SYS.XMLTYPE;
  trustschelems   XDB.XDB$XMLTYPE_REF_LIST_T;
  workgrpref      REF SYS.XMLTYPE;
  workgrpind     number := 0;
  anypart        VARCHAR2(4000);
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

  /* workgroup element is only need for 11.2.0.1.
   * it was added when upgrading to 11.2.0.1.
   * then it was removed from 11.2.0.2. 
   */
  if not (previous_version like '11.2.0.1%')
  then
    return;
  end if;

  select ref(s), s.xmldata.num_props
    into refs, numprops
    from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

  dbms_output.put_line('downgrading xdbconfig schema, numprops was ' || numprops);
             
  select ref(c), c.xmldata.sequence_kid, m.xmldata.elements
    into refcauthtrusttype, cauthtrustskid, cauthtrustelems
    from xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where c.xmldata.name = 'custom-authentication-trust-type'
     and c.xmldata.parent_schema = refs
     and ref(m) = c.xmldata.sequence_kid;

  -- get trust-scheme element
  reftrustsch := cauthtrustelems(1);

  -- get trust-scheme's anonymous complex type's elements
  select ref(c), c.xmldata.sequence_kid, m.xmldata.elements 
    into refCtrustsch, trustschskid, trustschelems
    from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where ref(e) = reftrustsch
     and ref(c) = e.xmldata.cplx_type_decl
     and ref(m) = c.xmldata.sequence_kid;

  dbms_output.put_line(to_char(trustschelems.count) || ' elements under trust-scheme');
  for j in 1..trustschelems.last loop
   select e.xmldata.property.name into schema_url 
     from xdb.xdb$element e
    where ref(e) = trustschelems(j);
    
   if schema_url = 'workgroup' then
     workgrpind := j;
   end if;
   -- dbms_output.put_line(to_char(j) || ': ' || schema_url);
  end loop;

  if workgrpind = 0 and trustschelems.count = 6 then
    dbms_output.put_line('did not find workgroup, adding it');
    -- insert workgroup element
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata)
    values(XMLTYPEEXTRA(
            XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', 
                      '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', 
                      '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'),
            XMLTYPEPI('523030')),
           XDB.XDB$ELEMENT_T(
             XDB.XDB$PROPERTY_T(
               XDB.XDB$RAW_LIST_T('83B810200080030C000000040532330809181B23262A343503150C07292728'), 
               refs, xdb.xdb$propnum_seq.nextval, 'workgroup', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, NULL, 
               'string', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', 
               NULL, NULL, '00'), 
             NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, 
             NULL, NULL, NULL, NULL, NULL, NULL, 0, 'unbounded', '00', '01', NULL, NULL, NULL, NULL,
             NULL, NULL, NULL, NULL))
      returning ref(e) into workgrpref;
    trustschelems.extend(1);
    trustschelems(trustschelems.last) := workgrpref;
    update xdb.xdb$sequence_model m
       set m.xmldata.elements   = trustschelems,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800707')
     where ref(m) = trustschskid;

    anypart := dbms_xdbmig_util.buildAnnotationKidList(trustschelems, null);
    update xdb.xdb$complex_type c
       set c.xmldata.annotation.appinfo =
              XDB.XDB$APPINFO_LIST_T(
                  XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)),
           c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000')
     where c.xmldata.parent_schema = refs
       and ref(c)=refCtrustsch;
    update xdb.xdb$schema s
       set s.xmldata.num_props     = s.xmldata.num_props + 1
     where ref(s) = refs;
    commit;
  elsif workgrpind > 0 then
    dbms_output.put_line('workgroup property existed');
  end if;
end;
/

/*-----------------------------------------------------------------------*/
/* Remove:      */
/*   /xdbconfig/xdbc:custom-authentication-type/custom-authentication-mappings/custom-authentication-mapping/on-deny */
/*-----------------------------------------------------------------------*/

declare
  schema_url           VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  refs                 REF SYS.XMLTYPE;
  refcauthmapp         REF SYS.XMLTYPE;
  refcauthmappctype       REF SYS.XMLTYPE;
  cauthmappskid       REF SYS.XMLTYPE;
  cauthmappelems   XDB.XDB$XMLTYPE_REF_LIST_T;
  ref_ondeny_typ       REF SYS.XMLTYPE;
  ref_ondeny    REF SYS.XMLTYPE;
  anypart        VARCHAR2(4000);
  new_cfgprop_count   number := 0;
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


  /* on-deny was first added in 11.2.0.2.
   * It needs to be removed when downgrading to 11.2.0.1. 
   * Downgrading to 111 is handled in xdbes111.sql. 
   */
  if not (previous_version like '11.2.0.1%')
  then
    return;
  end if;

  select ref(s) into refs from xdb.xdb$schema s
     where s.xmldata.schema_url = schema_url;

  select ref(e), ref(c), c.xmldata.sequence_kid, m.xmldata.elements
    into refcauthmapp, refcauthmappctype, cauthmappskid, cauthmappelems
  from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
  where e.xmldata.property.name = 'custom-authentication-mapping'
    and e.xmldata.property.parent_schema = refs
    and ref(c) = e.xmldata.cplx_type_decl
    and ref(m) = c.xmldata.sequence_kid;

  if cauthmappelems.count = 5 then 
    -- ref to the on-deny element and its simple type
    select ref(e), e.xmldata.property.smpl_type_decl into ref_ondeny, ref_ondeny_typ
    from xdb.xdb$element e
    where e.xmldata.property.name='on-deny' and e.xmldata.property.parent_schema = refs;

    ------- Lets now do the cleanup
    cauthmappelems.trim(1);
  
    update xdb.xdb$sequence_model m
           set m.xmldata.elements   = cauthmappelems,    
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800407')
           where ref(m) = cauthmappskid;

    anypart := dbms_xdbmig_util.buildAnnotationKidList(cauthmappelems, null);

    update xdb.xdb$complex_type c
           set c.xmldata.annotation.appinfo =
           XDB.XDB$APPINFO_LIST_T(
                XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)),
           c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000')
           where c.xmldata.parent_schema = refs and ref(c)=refcauthmappctype;

    delete from xdb.xdb$element e where ref(e)=ref_ondeny;
    delete from xdb.xdb$simple_type t where ref(t)=ref_ondeny_typ;

    update xdb.xdb$schema s
           set s.xmldata.num_props = (s.xmldata.num_props - 1) 
           where ref(s) = refs;

    commit;

  end if;

end;
/

-------------------------------------------------------------
-- start downgrading xdbconfig for FTPhostname
-- /xdbconfig/sysconfig/protocolconfig/ftpconfig/host-name
-------------------------------------------------------------
create or replace procedure downgradeConfigHostName as 
  isfound         BOOLEAN;
  confsch_ref     REF SYS.XMLTYPE;
  simpletype_ref  REF SYS.XMLTYPE;
  elem_ref        REF SYS.XMLTYPE;
  cplx_ref        REF SYS.XMLTYPE;
  seq_ref         REF SYS.XMLTYPE;
  seq_elems       XDB.XDB$XMLTYPE_REF_LIST_T;
  elem_propnum    NUMBER(38);
  propnum         NUMBER(38); 
  confsch_url     VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  anypart         VARCHAR2(4000);
  i               NUMBER(38); 
  numprops        NUMBER(38);
  numhostnames    NUMBER(38);

begin
    
  -- ref for xdbconfig schema
  select ref(s) into confsch_ref from xdb.xdb$schema s
  where s.xmldata.schema_url = confsch_url;

  -- num_props
  select s.xmldata.num_props into numprops from xdb.xdb$schema s
  where s.xmldata.schema_url = confsch_url; 

  -- already downgraded?
  --if (numprops <= NUM_PROPS) then
  --   dbms_output.put_line('xdbconfig schema already downgraded');
  --   return;
  --end if;

  -- no hostnames to downgrade?
  select count(*) into numhostnames
     from xdb.xdb$element e
     where 
           e.xmldata.property.name='host-name' and
           e.xmldata.property.parent_schema = confsch_ref;
  if (numhostnames <= 0) then
     dbms_output.put_line('xdbconfig schema downgraded, no hostname');
     return;
  end if;

  -- ref and prop num for the default-type-mappings element
  select ref(e), 
         e.xmldata.property.prop_number 
  into elem_ref, elem_propnum
  from xdb.xdb$element e
  where e.xmldata.property.name='host-name' and 
        e.xmldata.property.parent_schema = confsch_ref;

  -- ref to the ftpconfig element and its type
  select e.xmldata.cplx_type_decl into cplx_ref  
  from xdb.xdb$element e
  where e.xmldata.property.name='ftpconfig' and
        e.xmldata.property.parent_schema = confsch_ref;

  -- ref to the sequence kid in the complex type for ftpconfig
  select c.xmldata.sequence_kid into seq_ref from xdb.xdb$complex_type c
  where ref(c) = cplx_ref;

  -- elements in the sequence 
  select m.xmldata.elements into seq_elems from xdb.xdb$sequence_model m 
  where ref(m)= seq_ref;

  -- update annotation for the complex type declaration for ftpconfig 
  --  (remove reference to default-type-mappings)
  isfound := FALSE;
  anypart := '<xdb:kidList xmlns:xdb="http://xmlns.oracle.com/xdb" sequential="true">';
  for i in 1..seq_elems.last loop
     select e.xmldata.property.prop_number into propnum 
     from xdb.xdb$element e
     where ref(e) = seq_elems(i);
     if (not (isfound)) then
       if (propnum != elem_propnum) then 
         anypart := anypart || chr(10) || '  <xdb:kid propNum="' || propnum || '" kidNum="' || (i-1) || '"/>';
       else
         isfound := TRUE;
       end if;
     else
       -- shift left
       anypart := anypart || chr(10) || '  <xdb:kid propNum="' || propnum || '" kidNum="' || (i-2) || '"/>';
       seq_elems(i-1) := seq_elems(i);
     end if;
  end loop;  
  anypart := anypart || chr(10) || '</xdb:kidList>';

  seq_elems.trim(1);

  update xdb.xdb$complex_type c
  set c.xmldata.annotation.appinfo = XDB.XDB$APPINFO_LIST_T(XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000') 
  where c.xmldata.parent_schema = confsch_ref and ref(c) = cplx_ref;

   -- update elements and PD for seq kid of ftpconfig 
  update xdb.xdb$sequence_model m set m.xmldata.elements = seq_elems,
                                      m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800807')
  where ref(m)= seq_ref;

  -- remove the default-type-mappings element
  delete from xdb.xdb$element e where ref(e) = elem_ref;
  
  -- update num_props for schema
  update xdb.xdb$schema s set s.xmldata.num_props = (s.xmldata.num_props - 1)
  where s.xmldata.schema_url = confsch_url;  

  commit; 

end;
/

show errors;
exec downgradeConfigHostName;

-- clean up
drop procedure downgradeConfigHostName;

--------------------------------------------------
-- end downgrading xdbconfig FTP Host Name 
--------------------------------------------------

-- Downgrade enum type of input-filter-element to
-- <element name="input-filter-enable">
--   <simpleType>
--     <restriction base="string">
--       <enumeration value="On"/>
--       <enumeration value="Off"/>
--     </restriction>
--   </simpleType>
-- </element>
declare
  previous_version varchar2(30);
begin

  /* 16546969: Skip input-filter-element downgrade for 11.2.0.4 which has this
   * backported also.
   */
  select prv_version into previous_version from registry$ where cid = 'XDB';

  /* If XDB was installed during a upgrade, previous_version will be NULL.
   * When that happens, get previous_version from CATPROC.
   */
  if previous_version is NULL then
    select prv_version into previous_version
      from registry$ where cid = 'CATPROC';
  end if;

  if previous_version like '11.2.0.4%' then
    return;
  end if;

  -- Revert 12.1 enum values to old "Off" value for some minimal security check
  for r in (select svt.*
              from xdb.xdb$config cfg,
                   xmltable(
                     xmlnamespaces(
                       default 'http://xmlns.oracle.com/xdb/xdbconfig.xsd'),
                     '//httpconfig//servlet[servlet-language="PL/SQL"]'
                     passing cfg.object_value
                     columns
                       name
                         varchar2(4000) path 'servlet-name',
                       input_filter_enable
                         varchar2(4000) path 'plsql/input-filter-enable') svt)
  loop
    if (   r.input_filter_enable = 'SecurityOn'
        or r.input_filter_enable = 'SecurityOff') then
        dbms_epg.set_dad_attribute(r.name, 'input-filter-enable', 'Off');
    end if;
  end loop;
end;
/

declare
  schema_url     VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  config_sch_ref REF SYS.XMLTYPE;
  previous_version varchar2(30);
begin

  /* 16546969: Skip input-filter-element downgrade for 11.2.0.4 which has this
   * backported also.
   */
  select prv_version into previous_version from registry$ where cid = 'XDB';

  /* If XDB was installed during a upgrade, previous_version will be NULL.
   * When that happens, get previous_version from CATPROC.
   */
  if previous_version is NULL then
    select prv_version into previous_version
      from registry$ where cid = 'CATPROC';
  end if;

  if previous_version like '11.2.0.4%' then
    return;
  end if;

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
     set s.xmldata.restriction = XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'On', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Off', '00', NULL)), NULL, NULL)
   where ref(s) = (select e.xmldata.property.type_ref from xdb.xdb$element e
                    where e.xmldata.property.parent_schema = config_sch_ref
                      and e.xmldata.property.name ='input-filter-enable');
  commit;
end;
/

begin
  execute immediate ('drop function sys.getUserIdOnTarget');
  exception
     when others then
      null;
end;
/

declare
  exist number;
begin
  select count(*) into exist from DBA_TABLES where table_name = 'XDB$CDBPORTS'
  and owner = 'XDB';

  if exist = 1 then
    execute immediate
      'drop table xdb.xdb$cdbports';
  end if;
end;
/

SHOW ERRORS;

Rem clean up updown utilities
@@dbmsxuducu.sql

Rem ================================================================
Rem END XDB Schema downgrade to 11.2.0
Rem ================================================================

