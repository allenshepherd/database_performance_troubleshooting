Rem
Rem $Header: rdbms/admin/mgdmeta.sql /main/6 2017/05/28 22:46:06 stanaya Exp $
Rem
Rem mgdmeta.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      mgdmeta.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/mgdmeta.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/mgdmeta.sql
Rem    SQL_PHASE: MGDMETA
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       03/02/16 - add call to sqlsessstart and sqlsessend
Rem    hgong       01/17/13 - create table to store a local version of
Rem                           ManagerTranslation.xml
Rem    hgong       07/12/06 - add version and uri info to EPC category 
Rem    hgong       05/15/06 - move tag data translation schema and xml file 
Rem                           contents to mgdmeta.sql 
Rem    hgong       05/12/06 - fix load metadata to work for all platforms and 
Rem                           ade 
Rem    hgong       04/04/06 - changed xml directory 
Rem    hgong       03/31/06 - load metadata 
Rem    hgong       03/31/06 - load metadata 
Rem    hgong       03/31/06 - Created
Rem

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessstart.sql
Rem ********************************************************************

--Store local backup of lookup tables, such as ManagerTranslation.xml in mgd_id_lookup_table
DECLARE
  amt          NUMBER;
  buf          VARCHAR2(32767);
  pos          NUMBER;
  seq          BINARY_INTEGER;
  tdt_xml      CLOB;
BEGIN
  --store tdt schema into a one column, one row table 
  --DELETE FROM mgd_id_lookup_table;
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);

  buf := '<GEPC64Table date="2011-11-23T13:02:52-05:00">
<entry index="1" companyPrefix="0037000"/>
<entry index="6" companyPrefix="0681131"/>
<entry index="7" companyPrefix="0808736"/>
<entry index="16" companyPrefix="0016000"/>
<entry index="17" companyPrefix="0078742"/>
<entry index="18" companyPrefix="0605388"/>
<entry index="19" companyPrefix="0029000"/>
<entry index="20" companyPrefix="0013130"/>
<entry index="21" companyPrefix="0044000"/>
<entry index="24" companyPrefix="0038675"/>
<entry index="25" companyPrefix="0073257"/>
<entry index="26" companyPrefix="0044710"/>
<entry index="31" companyPrefix="0085239"/>
<entry index="32" companyPrefix="0011120"/>
<entry index="33" companyPrefix="0353265"/>
<entry index="36" companyPrefix="0077661"/>
<entry index="37" companyPrefix="8901296"/>
<entry index="39" companyPrefix="0051500"/>
<entry index="40" companyPrefix="0075338"/>
<entry index="41" companyPrefix="0044500"/>
<entry index="42" companyPrefix="0071068"/>
<entry index="43" companyPrefix="4017587"/>
<entry index="44" companyPrefix="0030000"/>
<entry index="45" companyPrefix="0052000"/>
<entry index="46" companyPrefix="0048500"/>
<entry index="47" companyPrefix="0027045"/>
<entry index="48" companyPrefix="0076501"/>
<entry index="50" companyPrefix="0024600"/>
<entry index="51" companyPrefix="0074108"/>
<entry index="53" companyPrefix="0019200"/>
<entry index="54" companyPrefix="0041500"/>
<entry index="55" companyPrefix="0051700"/>
<entry index="61" companyPrefix="0073420"/>
<entry index="63" companyPrefix="0034502"/>
<entry index="64" companyPrefix="0051071"/>
<entry index="65" companyPrefix="0041000"/>
<entry index="66" companyPrefix="0041790"/>
<entry index="67" companyPrefix="0032247"/>
<entry index="71" companyPrefix="0027426"/>
<entry index="72" companyPrefix="4973934"/>
<entry index="74" companyPrefix="0070010"/>
<entry index="75" companyPrefix="0028000"/>
<entry index="76" companyPrefix="0039000"/>
<entry index="77" companyPrefix="0050000"/>
<entry index="78" companyPrefix="0017800"/>
<entry index="79" companyPrefix="0070640"/>
<entry index="80" companyPrefix="4035147"/>
<entry index="81" companyPrefix="0017082"/>
<entry index="82" companyPrefix="0076753"/>
<entry index="83" companyPrefix="4000400"/>
<entry index="99" companyPrefix="0041554"/>
<entry index="100" companyPrefix="0071249"/>
<entry index="104" companyPrefix="0037600"/>
<entry index="105" companyPrefix="0071106"/>
<entry index="106" companyPrefix="0038100"/>
<entry index="108" companyPrefix="0079340"/>
<entry index="112" companyPrefix="0323400"/>
<entry index="113" companyPrefix="0310742"/>
<entry index="114" companyPrefix="0882224"/>
<entry index="115" companyPrefix="0016500"/>
<entry index="117" companyPrefix="0025866"/>
<entry index="118" companyPrefix="0312843"/>
<entry index="121" companyPrefix="0026616"/>
<entry index="122" companyPrefix="0086483"/>
<entry index="123" companyPrefix="0023169"/>
<entry index="124" companyPrefix="0097783"/>
<entry index="125" companyPrefix="0019800"/>
<entry index="126" companyPrefix="0046500"/>
<entry index="127" companyPrefix="0053100"/>
<entry index="128" companyPrefix="0022592"/>
<entry index="129" companyPrefix="0068274"/>
<entry index="130" companyPrefix="0076031"/>
<entry index="131" companyPrefix="0018100"/>
<entry index="132" companyPrefix="0661526"/>
<entry index="133" companyPrefix="0730787"/>
<entry index="135" companyPrefix="0074970"/>
<entry index="149" companyPrefix="0093007"/>
<entry index="150" companyPrefix="0659556"/>
<entry index="151" companyPrefix="0805529"/>
<entry index="152" companyPrefix="0076657"/>
<entry index="153" companyPrefix="0030473"/>
<entry index="155" companyPrefix="0013000"/>
<entry index="156" companyPrefix="0027242"/>
<entry index="157" companyPrefix="0012547"/>
<entry index="158" companyPrefix="0073796"/>
<entry index="159" companyPrefix="0032967"/>
<entry index="160" companyPrefix="0040072"/>
<entry index="161" companyPrefix="0085452"/>
<entry index="162" companyPrefix="0086279"/>
<entry index="168" companyPrefix="0072782"/>
<entry index="170" companyPrefix="0071709"/>
<entry index="172" companyPrefix="0073502"/>
<entry index="176" companyPrefix="0047406"/>
<entry index="182" companyPrefix="0042437"/>
<entry index="183" companyPrefix="030766"/>
<entry index="184" companyPrefix="0353100"/>
<entry index="185" companyPrefix="0345800"/>
<entry index="186" companyPrefix="0349692"/>
<entry index="187" companyPrefix="030135"/>
<entry index="188" companyPrefix="0074684"/>
<entry index="189" companyPrefix="0311530"/>
<entry index="190" companyPrefix="0310158"/>
<entry index="191" companyPrefix="5000347"/>
<entry index="192" companyPrefix="030021"/>
<entry index="193" companyPrefix="0071549"/>
<entry index="194" companyPrefix="0726651"/>
<entry index="195" companyPrefix="0726652"/>
<entry index="196" companyPrefix="0726653"/>
<entry index="197" companyPrefix="0726654"/>
<entry index="198" companyPrefix="0726655"/>
<entry index="199" companyPrefix="0726656"/>
<entry index="200" companyPrefix="0726657"/>
<entry index="201" companyPrefix="0726658"/>
<entry index="202" companyPrefix="0604200"/>
<entry index="203" companyPrefix="0718268"/>
<entry index="204" companyPrefix="0026729"/>
<entry index="205" companyPrefix="0047741"/>
<entry index="206" companyPrefix="0689206"/>
<entry index="207" companyPrefix="0604201"/>
<entry index="208" companyPrefix="0015000"/>
<entry index="209" companyPrefix="0070382"/>
<entry index="210" companyPrefix="0030900"/>
<entry index="211" companyPrefix="0035000"/>
<entry index="213" companyPrefix="0043396"/>
<entry index="214" companyPrefix="0711719"/>
<entry index="215" companyPrefix="0074643"/>
<entry index="217" companyPrefix="0013258"/>
<entry index="218" companyPrefix="0013261"/>
<entry index="219" companyPrefix="0013262"/>
<entry index="220" companyPrefix="0013264"/>
<entry index="226" companyPrefix="0021000"/>
<entry index="227" companyPrefix="0043000"/>
<entry index="228" companyPrefix="0054400"/>
<entry index="229" companyPrefix="0032700"/>
<entry index="231" companyPrefix="0031600"/>
<entry index="232" companyPrefix="0085447"/>
<entry index="233" companyPrefix="0074200"/>
<entry index="234" companyPrefix="0046029"/>
<entry index="235" companyPrefix="0043935"/>
<entry index="236" companyPrefix="0042714"/>
<entry index="237" companyPrefix="0038257"/>
<entry index="238" companyPrefix="0742466"/>
<entry index="239" companyPrefix="0727271"/>
<entry index="240" companyPrefix="0635424"/>
<entry index="241" companyPrefix="0032100"/>
<entry index="242" companyPrefix="0033700"/>
<entry index="243" companyPrefix="0053400"/>
<entry index="244" companyPrefix="0054500"/>
<entry index="245" companyPrefix="0075971"/>
<entry index="246" companyPrefix="0077900"/>
<entry index="247" companyPrefix="0090563"/>
<entry index="248" companyPrefix="0024106"/>
<entry index="249" companyPrefix="4025521"/>
<entry index="250" companyPrefix="0057791"/>
<entry index="251" companyPrefix="0065857"/>
<entry index="253" companyPrefix="0061500"/>
<entry index="254" companyPrefix="0065557"/>
<entry index="255" companyPrefix="0037988"/>
<entry index="256" companyPrefix="0077711"/>
<entry index="257" companyPrefix="0023753"/>
<entry index="259" companyPrefix="0312547"/>
<entry index="271" companyPrefix="0044069"/>
<entry index="272" companyPrefix="030521"/>
<entry index="273" companyPrefix="0074887"/>
<entry index="274" companyPrefix="0026427"/>
<entry index="280" companyPrefix="0032281"/>
<entry index="286" companyPrefix="0072821"/>
<entry index="287" companyPrefix="0042666"/>
<entry index="290" companyPrefix="0074182"/>
<entry index="292" companyPrefix="0028028"/>
<entry index="293" companyPrefix="0014800"/>
<entry index="294" companyPrefix="0078000"/>
<entry index="296" companyPrefix="0032017"/>
<entry index="297" companyPrefix="0022265"/>
<entry index="298" companyPrefix="4904550"/>
<entry index="299" companyPrefix="0054100"/>
<entry index="301" companyPrefix="0074000"/>
<entry index="302" companyPrefix="0046034"/>
<entry index="305" companyPrefix="0662919"/>
<entry index="306" companyPrefix="08359240"/>
<entry index="307" companyPrefix="0050332"/>
<entry index="308" companyPrefix="4545350"/>
<entry index="309" companyPrefix="735078"/>
<entry index="310" companyPrefix="0650530"/>
<entry index="312" companyPrefix="8808979"/>
<entry index="313" companyPrefix="0079400"/>
<entry index="317" companyPrefix="3660603"/>
<entry index="318" companyPrefix="0051900"/>
<entry index="319" companyPrefix="0026259"/>
<entry index="320" companyPrefix="0018208"/>
<entry index="321" companyPrefix="0708431"/>
<entry index="322" companyPrefix="4902530"/>
<entry index="323" companyPrefix="4902580"/>
<entry index="324" companyPrefix="0025215"/>
<entry index="325" companyPrefix="0076906"/>
<entry index="326" companyPrefix="0077567"/>
<entry index="328" companyPrefix="4977729"/>
<entry index="330" companyPrefix="0031200"/>
<entry index="331" companyPrefix="0046838"/>
<entry index="332" companyPrefix="4975769"/>
<entry index="334" companyPrefix="0013803"/>
<entry index="335" companyPrefix="0082966"/>
<entry index="336" companyPrefix="4960999"/>
<entry index="337" companyPrefix="0074101"/>
<entry index="347" companyPrefix="95100009"/>
<entry index="348" companyPrefix="456010159"/>
<entry index="349" companyPrefix="0880760"/>
<entry index="351" companyPrefix="0040169"/>
<entry index="353" companyPrefix="0048168"/>
<entry index="355" companyPrefix="0045557"/>
<entry index="358" companyPrefix="0728213"/>
<entry index="364" companyPrefix="4971850"/>
<entry index="365" companyPrefix="4961311"/>
<entry index="366" companyPrefix="457122707"/>
<entry index="369" companyPrefix="456214481"/>
<entry index="370" companyPrefix="458028752"/>
</GEPC64Table>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_lookup_table(url, content, use_local) 
    values('http://www.onsepc.com/ManagerTranslation.xml', tdt_xml, 'Y');
  COMMIT;
END;
/
SHOW ERRORS;

DECLARE
  amt          NUMBER;
  buf          VARCHAR2(32767);
  pos          NUMBER;
  seq          BINARY_INTEGER;
  tdt_xml      CLOB;

BEGIN
  --store tdt schema into a one column, one row table 
  DELETE FROM mgd_id_xml_validator;

  INSERT INTO mgd_id_xml_validator VALUES(empty_clob())
    RETURNING xsd_schema into tdt_xml;

   DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
   buf := '<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema targetNamespace="oracle.mgd.idcode"
            xmlns:xsd="http://www.w3.org/2001/XMLSchema"
            xmlns:tdt="oracle.mgd.idcode" elementFormDefault="unqualified"
            attributeFormDefault="unqualified" version="1.0">
  <xsd:annotation>
    <xsd:documentation>
      <![CDATA[
<epcglobal:copyright>Copyright ?2004 Epcglobal Inc., All Rights
Reserved.</epcglobal:copyright>
<epcglobal:disclaimer>EPCglobal Inc., its members, officers, directors,
employees, or agents shall not be liable for any injury, loss, damages,
financial or otherwise, arising from, related to, or caused by the use of this
document. The use of said document shall constitute your express consent to
the foregoing exculpation.</epcglobal:disclaimer>
<epcglobal:specification>Tag Data Translation (TDT) version
1.0</epcglobal:specification>
]]>
    </xsd:documentation>
  </xsd:annotation>
  <xsd:simpleType name="LevelTypeList">
    <xsd:restriction base="xsd:string">
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="TagLengthList">
    <xsd:restriction base="xsd:string">
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="SchemeNameList">
    <xsd:restriction base="xsd:string">
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="InputFormatList">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="BINARY"/>
      <xsd:enumeration value="STRING"/>
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="ModeList">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="EXTRACT"/>
      <xsd:enumeration value="FORMAT"/>
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="CompactionMethodList">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="32-bit"/>
      <xsd:enumeration value="16-bit"/>
      <xsd:enumeration value="8-bit"/>
      <xsd:enumeration value="7-bit"/>
      <xsd:enumeration value="6-bit"/>
      <xsd:enumeration value="5-bit"/>
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="PadDirectionList">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="LEFT"/>
      <xsd:enumeration value="RIGHT"/>
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:complexType name="Field">
    <xsd:attribute name="seq" type="xsd:integer" use="required"/>
    <xsd:attribute name="name" type="xsd:string" use="required"/>
    <xsd:attribute name="bitLength" type="xsd:integer"/>
    <xsd:attribute name="characterSet" type="xsd:string" use="required"/>
    <xsd:attribute name="compaction" type="tdt:CompactionMethodList"/>
    <xsd:attribute name="compression" type="xsd:string"/>
    <xsd:attribute name="padChar" type="xsd:string"/>
    <xsd:attribute name="padDir" type="tdt:PadDirectionList"/>
    <xsd:attribute name="decimalMinimum" type="xsd:long"/>
    <xsd:attribute name="decimalMaximum" type="xsd:long"/>
    <xsd:attribute name="length" type="xsd:integer"/>
  </xsd:complexType>
  <xsd:complexType name="Option">
    <xsd:sequence>
      <xsd:element name="field" type="tdt:Field" maxOccurs="unbounded"/>
    </xsd:sequence>
    <xsd:attribute name="optionKey" type="xsd:string" use="required"/>
    <xsd:attribute name="pattern" type="xsd:string"/>
    <xsd:attribute name="grammar" type="xsd:string" use="required"/>
  </xsd:complexType>
  <xsd:complexType name="Rule">
    <xsd:attribute name="type" type="tdt:ModeList" use="required"/>
    <xsd:attribute name="inputFormat" type="tdt:InputFormatList"
                   use="required"/>
    <xsd:attribute name="seq" type="xsd:integer" use="required"/>
    <xsd:attribute name="newFieldName" type="xsd:string" use="required"/>
    <xsd:attribute name="characterSet" type="xsd:string" use="required"/>
    <xsd:attribute name="padChar" type="xsd:string"/>
    <xsd:attribute name="padDir" type="tdt:PadDirectionList"/>
    <xsd:attribute name="decimalMinimum" type="xsd:long"/>
    <xsd:attribute name="decimalMaximum" type="xsd:long"/>
    <xsd:attribute name="length" type="xsd:string"/>
    <xsd:attribute name="function" type="xsd:string" use="required"/>
    <xsd:attribute name="tableURI" type="xsd:string"/>
    <xsd:attribute name="tableParams" type="xsd:string"/>
    <xsd:attribute name="tableXPath" type="xsd:string"/>
    <xsd:attribute name="tableSQL" type="xsd:string"/>
  </xsd:complexType>
  <xsd:complexType name="Level">
    <xsd:sequence>
      <xsd:element name="option" type="tdt:Option" minOccurs="1"
                   maxOccurs="unbounded"/>
      <xsd:element name="rule" type="tdt:Rule" minOccurs="0"
                   maxOccurs="unbounded"/>
    </xsd:sequence>
    <xsd:attribute name="type" type="tdt:LevelTypeList" use="required"/>
    <xsd:attribute name="prefixMatch" type="xsd:string" use="optional"/>
    <xsd:attribute name="requiredParsingParameters" type="xsd:string"/>
    <xsd:attribute name="requiredFormattingParameters" type="xsd:string"/>
  </xsd:complexType>
  <xsd:complexType name="Scheme">
    <xsd:sequence>
      <xsd:element name="level" type="tdt:Level" minOccurs="1" maxOccurs="5"/>
    </xsd:sequence>
    <xsd:attribute name="name" type="tdt:SchemeNameList" use="required"/>
    <xsd:attribute name="optionKey" type="xsd:string" use="required"/>
    <xsd:attribute name="tagLength" type="tdt:TagLengthList" use="optional"/>
  </xsd:complexType>
  <xsd:complexType name="TagDataTranslation">
    <xsd:sequence>
      <xsd:element name="scheme" type="tdt:Scheme" maxOccurs="unbounded"/>
    </xsd:sequence>
    <xsd:attribute name="version" type="xsd:string" use="required"/>
    <xsd:attribute name="date" type="xsd:dateTime" use="required"/>
  </xsd:complexType>
  <xsd:element name="TagDataTranslation" type="tdt:TagDataTranslation"/>
</xsd:schema>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  COMMIT;
END;
/
SHOW ERRORS;

DECLARE
  amt          NUMBER;
  buf          VARCHAR2(32767);
  pos          NUMBER;
  seq          BINARY_INTEGER;
  tdt_xml      CLOB;

BEGIN
  --create EPC category 
  SELECT mgd$sequence_category.nextval INTO seq FROM DUAL;
  INSERT INTO mgd_id_category_tab(owner, category_id, category_name, version, agency, uri) VALUES('MGDSYS', seq, 'EPC', '1.0', 'EPCGlobal', 'http://www.epcglobalinc.org');
  --COMMIT;

  --add schemes for EPC category

  --GID-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode">
  <scheme name="GID-96" optionKey="1" xmlns="">
    <level type="BINARY" prefixMatch="00110101" requiredFormattingParameters="">
      <option optionKey="1" pattern="00110101([01]{28})([01]{24})([01]{36})" grammar="''00110101'' generalmanager objectclass serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="268435455" characterSet="[01]*" bitLength="28" name="generalmanager"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16777215" characterSet="[01]*" bitLength="24" name="objectclass"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[01]*" bitLength="36" name="serial"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:gid-96" requiredFormattingParameters="">
      <option optionKey="1" pattern="urn:epc:tag:gid-96:([0-9]*)\.([0-9]*)\.([0-9]*)" grammar="''urn:epc:tag:gid-96:'' generalmanager ''.'' objectclass ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="268435455" characterSet="[0-9]*" name="generalmanager"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16777215" characterSet="[0-9]*" name="objectclass"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:gid">
      <option optionKey="1" pattern="urn:epc:id:gid:([0-9]*)\.([0-9]*)\.([0-9]*)" grammar="''urn:epc:id:gid:'' generalmanager ''.'' objectclass ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="268435455" characterSet="[0-9]*" name="generalmanager"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16777215" characterSet="[0-9]*" name="objectclass"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="generalmanager=">
      <option optionKey="1" pattern="generalmanager=([0-9]*);objectclass=([0-9]*);serial=([0-9]*)" grammar="''generalmanager=''generalmanager'';objectclass=''objectclass '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="268435455" characterSet="[0-9]*" name="generalmanager"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16777215" characterSet="[0-9]*" name="objectclass"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
  </scheme>
</TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  --COMMIT;

  --GIAI-64
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="GIAI-64" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00001011" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="12" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="11" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="13" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="10" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="14" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="9" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="15" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="8" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="16" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="7" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="17" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="6" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="18" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="companyprefix" characterSet="[0-9]*" function="TABLELOOKUP(companyprefixindex,tdt64bitcpi,companyprefixindex,companyprefix)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@index=''$1'']/@companyPrefix" tableParams="companyprefixindex"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefixlength" characterSet="[0-9]*" function="LENGTH(companyprefix)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="companyprefixindex" characterSet="[0-9]*" function="TABLELOOKUP(companyprefix,tdt64bitcpi,companyprefix,companyprefixindex)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@companyPrefix=''$1'']/@index" tableParams="companyprefix"/>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:giai-64" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{12})\.([0-9]{12})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{11})\.([0-9]{13})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{10})\.([0-9]{14})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{9})\.([0-9]{15})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="15" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{8})\.([0-9]{16})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="16" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{7})\.([0-9]{17})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="17" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{6})\.([0-9]{18})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:giai">
      <option optionKey="12" pattern="urn:epc:id:giai:([0-9]{12})\.([0-9]{12})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:giai:([0-9]{11})\.([0-9]{13})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:giai:([0-9]{10})\.([0-9]{14})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:giai:([0-9]{9})\.([0-9]{15})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999999" characterSet="[0-9]*" length="15" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:giai:([0-9]{8})\.([0-9]{16})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999999999" characterSet="[0-9]*" length="16" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:giai:([0-9]{7})\.([0-9]{17})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999999999" characterSet="[0-9]*" length="17" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:giai:([0-9]{6})\.([0-9]{18})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="giai=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="giai=([0-9]{13,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="11" pattern="giai=([0-9]{12,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="10" pattern="giai=([0-9]{11,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="9" pattern="giai=([0-9]{10,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="8" pattern="giai=([0-9]{9,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="7" pattern="giai=([0-9]{8,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="6" pattern="giai=([0-9]{7,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="indassetref" characterSet="[0-9]*" function="SUBSTR(giai,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(giai,0,companyprefixlength)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  --COMMIT;

  --GIAI-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="GIAI-96" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00110100" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00110100([01]{3})000([01]{40})([01]{42})" grammar="''00110100'' filter ''000'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[01]*" bitLength="40" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[01]*" bitLength="42" length="12" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="11" pattern="00110100([01]{3})001([01]{37})([01]{45})" grammar="''00110100'' filter ''001'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="37" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[01]*" bitLength="45" length="13" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="10" pattern="00110100([01]{3})010([01]{34})([01]{48})" grammar="''00110100'' filter ''010'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="34" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[01]*" bitLength="48" length="14" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="9" pattern="00110100([01]{3})011([01]{30})([01]{52})" grammar="''00110100'' filter ''011'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="30" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999999999" characterSet="[01]*" bitLength="52" length="15" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="8" pattern="00110100([01]{3})100([01]{27})([01]{55})" grammar="''00110100'' filter ''100'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="27" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999999999" characterSet="[01]*" bitLength="55" length="16" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="7" pattern="00110100([01]{3})101([01]{24})([01]{58})" grammar="''00110100'' filter ''101'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999999999" characterSet="[01]*" bitLength="58" length="17" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="6" pattern="00110100([01]{3})110([01]{20})([01]{62})" grammar="''00110100'' filter ''110'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[01]*" bitLength="62" length="18" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:giai-96" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{12})\.([0-9]{12})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{11})\.([0-9]{13})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{10})\.([0-9]{14})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{9})\.([0-9]{15})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999999999" characterSet="[0-9]*" length="15" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{8})\.([0-9]{16})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999999999" characterSet="[0-9]*" length="16" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{7})\.([0-9]{17})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999999999" characterSet="[0-9]*" length="17" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{6})\.([0-9]{18})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:giai">
      <option optionKey="12" pattern="urn:epc:id:giai:([0-9]{12})\.([0-9]{12})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:giai:([0-9]{11})\.([0-9]{13})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:giai:([0-9]{10})\.([0-9]{14})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:giai:([0-9]{9})\.([0-9]{15})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999999" characterSet="[0-9]*" length="15" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:giai:([0-9]{8})\.([0-9]{16})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999999999" characterSet="[0-9]*" length="16" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:giai:([0-9]{7})\.([0-9]{17})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999999999" characterSet="[0-9]*" length="17" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:giai:([0-9]{6})\.([0-9]{18})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="giai=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="giai=([0-9]{13,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="11" pattern="giai=([0-9]{12,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="10" pattern="giai=([0-9]{11,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="9" pattern="giai=([0-9]{10,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="8" pattern="giai=([0-9]{9,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="7" pattern="giai=([0-9]{8,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="6" pattern="giai=([0-9]{7,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="indassetref" characterSet="[0-9]*" function="SUBSTR(giai,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(giai,0,companyprefixlength)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  --COMMIT;

  --GRAI-64
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="GRAI-64" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00001010" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" characterSet="[01]*" bitLength="20" length="0" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="11" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[01]*" bitLength="20" length="1" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="10" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[01]*" bitLength="20" length="2" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="9" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[01]*" bitLength="20" length="3" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="8" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[01]*" bitLength="20" length="4" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="7" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="20" length="5" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="6" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="companyprefix" characterSet="[0-9]*" function="TABLELOOKUP(companyprefixindex,tdt64bitcpi,companyprefixindex,companyprefix)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@index=''$1'']/@companyPrefix" tableParams="companyprefixindex"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefixlength" characterSet="[0-9]*" function="LENGTH(companyprefix)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="companyprefixindex" characterSet="[0-9]*" function="TABLELOOKUP(companyprefix,tdt64bitcpi,companyprefix,companyprefixindex)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@companyPrefix=''$1'']/@index" tableParams="companyprefix"/>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:grai-64" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:grai">
      <option optionKey="12" pattern="urn:epc:id:grai:([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:grai:([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:grai:([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:grai:([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:grai:([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:grai:([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:grai:([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="grai=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="11" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="10" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="9" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="8" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="7" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="6" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="graiprefixremainder" characterSet="[0-9]*" length="12" function="SUBSTR(grai,1,12)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="assettype" characterSet="[0-9]*" function="SUBSTR(graiprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="serial" characterSet="[0-9]*" function="SUBSTR(grai,14)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="4" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(graiprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="graiprefix" characterSet="[0-9]*" length="13" function="CONCAT(0,companyprefix,assettype)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(graiprefix)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  --COMMIT;

  --GRAI-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="GRAI-96" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00110011" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00110011([01]{3})000([01]{40})([01]{4})([01]{38})" grammar="''00110011'' filter ''000'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[01]*" bitLength="40" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" characterSet="[01]*" bitLength="4" length="0" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="11" pattern="00110011([01]{3})001([01]{37})([01]{7})([01]{38})" grammar="''00110011'' filter ''001'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="37" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[01]*" bitLength="7" length="1" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="10" pattern="00110011([01]{3})010([01]{34})([01]{10})([01]{38})" grammar="''00110011'' filter ''010'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="34" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[01]*" bitLength="10" length="2" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="9" pattern="00110011([01]{3})011([01]{30})([01]{14})([01]{38})" grammar="''00110011'' filter ''011'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="30" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[01]*" bitLength="14" length="3" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="8" pattern="00110011([01]{3})100([01]{27})([01]{17})([01]{38})" grammar="''00110011'' filter ''100'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="27" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[01]*" bitLength="17" length="4" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="7" pattern="00110011([01]{3})101([01]{24})([01]{20})([01]{38})" grammar="''00110011'' filter ''101'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="20" length="5" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="6" pattern="00110011([01]{3})110([01]{20})([01]{24})([01]{38})" grammar="''00110011'' filter ''110'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="24" length="6" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:grai-96" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:grai">
      <option optionKey="12" pattern="urn:epc:id:grai:([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:grai:([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:grai:([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:grai:([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:grai:([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:grai:([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:grai:([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="grai=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="11" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="10" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="9" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="8" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="7" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="6" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="graiprefixremainder" characterSet="[0-9]*" length="12" function="SUBSTR(grai,1,12)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="assettype" characterSet="[0-9]*" function="SUBSTR(graiprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="serial" characterSet="[0-9]*" function="SUBSTR(grai,14)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="4" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(graiprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="graiprefix" characterSet="[0-9]*" length="13" function="CONCAT(0,companyprefix,assettype)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(graiprefix)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  --COMMIT;

  --SGLN-64
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="SGLN-64" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00001001" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="0" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="11" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="1" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="10" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="2" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="9" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="3" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="8" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="4" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="7" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="5" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="6" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="companyprefix" characterSet="[0-9]*" function="TABLELOOKUP(companyprefixindex,tdt64bitcpi,companyprefixindex,companyprefix)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@index=''$1'']/@companyPrefix" tableParams="companyprefixindex"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefixlength" characterSet="[0-9]*" function="LENGTH(companyprefix)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="companyprefixindex" characterSet="[0-9]*" function="TABLELOOKUP(companyprefix,tdt64bitcpi,companyprefix,companyprefixindex)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@companyPrefix=''$1'']/@index" tableParams="companyprefix"/>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:sgln-64" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:sgln">
      <option optionKey="12" pattern="urn:epc:id:sgln:([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="1" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:sgln:([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:sgln:([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:sgln:([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:sgln:([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:sgln:([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:sgln:([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="gln=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="glnprefixremainder" characterSet="[0-9]*" length="12" function="SUBSTR(gln,0,12)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="locationref" characterSet="[0-9]*" function="SUBSTR(glnprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(glnprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="glnprefix" characterSet="[0-9]*" length="12" function="CONCAT(companyprefix,locationref)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(glnprefix)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  --COMMIT;

  --SGLN-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="SGLN-96" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00110010" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00110010([01]{3})000([01]{40})([01]{1})([01]{41})" grammar="''00110010'' filter ''000'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[01]*" bitLength="40" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" characterSet="[01]*" bitLength="1" length="0" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
      <option optionKey="11" pattern="00110010([01]{3})001([01]{37})([01]{4})([01]{41})" grammar="''00110010'' filter ''001'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="37" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[01]*" bitLength="4" length="1" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
      <option optionKey="10" pattern="00110010([01]{3})010([01]{34})([01]{7})([01]{41})" grammar="''00110010'' filter ''010'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="34" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[01]*" bitLength="7" length="2" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
      <option optionKey="9" pattern="00110010([01]{3})011([01]{30})([01]{11})([01]{41})" grammar="''00110010'' filter ''011'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="30" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[01]*" bitLength="11" length="3" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
      <option optionKey="8" pattern="00110010([01]{3})100([01]{27})([01]{14})([01]{41})" grammar="''00110010'' filter ''100'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="27" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[01]*" bitLength="14" length="4" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
      <option optionKey="7" pattern="00110010([01]{3})101([01]{24})([01]{17})([01]{41})" grammar="''00110010'' filter ''101'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="17" length="5" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
      <option optionKey="6" pattern="00110010([01]{3})110([01]{20})([01]{21})([01]{41})" grammar="''00110010'' filter ''110'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="21" length="6" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:sgln-96" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:sgln">
      <option optionKey="12" pattern="urn:epc:id:sgln:([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="1" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:sgln:([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:sgln:([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:sgln:([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:sgln:([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:sgln:([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:sgln:([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="gln=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' gln '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="glnprefixremainder" characterSet="[0-9]*" length="12" function="SUBSTR(gln,0,12)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="locationref" characterSet="[0-9]*" function="SUBSTR(glnprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(glnprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="glnprefix" characterSet="[0-9]*" length="12" function="CONCAT(companyprefix,locationref)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(glnprefix)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  --COMMIT;

  --SGTIN-64
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="SGTIN-64" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="10" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[01]*" bitLength="20" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <option optionKey="11" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[01]*" bitLength="20" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <option optionKey="10" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[01]*" bitLength="20" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <option optionKey="9" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[01]*" bitLength="20" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <option optionKey="8" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="20" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <option optionKey="7" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <option optionKey="6" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="companyprefix" characterSet="[0-9]*" function="TABLELOOKUP(companyprefixindex,tdt64bitcpi,companyprefixindex,companyprefix)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@index=''$1'']/@companyPrefix" tableParams="companyprefixindex"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefixlength" characterSet="[0-9]*" function="LENGTH(companyprefix)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="companyprefixindex" characterSet="[0-9]*" function="TABLELOOKUP(companyprefix,tdt64bitcpi,companyprefix,companyprefixindex)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@companyPrefix=''$1'']/@index" tableParams="companyprefix"/>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:sgtin-64" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{12})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{11})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{10})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{9})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{8})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{7})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{6})\.([0-9]{7})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:sgtin">
      <option optionKey="12" pattern="urn:epc:id:sgtin:([0-9]{12})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:sgtin:([0-9]{11})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:sgtin:([0-9]{10})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:sgtin:([0-9]{9})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:sgtin:([0-9]{8})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:sgtin:([0-9]{7})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:sgtin:([0-9]{6})\.([0-9]{7})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="1048575" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="gtin=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="gtinprefixremainder" characterSet="[0-9]*" length="12" function="SUBSTR(gtin,1,12)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="indicatordigit" characterSet="[0-9]*" length="1" function="SUBSTR(gtin,0,1)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="itemrefremainder" characterSet="[0-9]*" function="SUBSTR(gtinprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="4" newFieldName="itemref" characterSet="[0-9]*" function="CONCAT(indicatordigit,itemrefremainder)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="5" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(gtinprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="indicatordigit" characterSet="[0-9]*" length="1" function="SUBSTR(itemref,0,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="itemrefremainder" characterSet="[0-9]*" function="SUBSTR(itemref,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="3" newFieldName="gtinprefix" characterSet="[0-9]*" length="13" function="CONCAT(indicatordigit,companyprefix,itemrefremainder)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="4" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(gtinprefix)"/>
    </level>
    <level type="ONS_HOSTNAME">
      <option optionKey="12" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="11" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="10" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="9" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="8" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="7" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="6" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  --COMMIT;

  --SGTIN-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="SGTIN-96" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00110000" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00110000([01]{3})000([01]{40})([01]{4})([01]{38})" grammar="''00110000'' filter ''000'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[01]*" bitLength="40" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[01]*" bitLength="4" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="11" pattern="00110000([01]{3})001([01]{37})([01]{7})([01]{38})" grammar="''00110000'' filter ''001'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="37" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[01]*" bitLength="7" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="10" pattern="00110000([01]{3})010([01]{34})([01]{10})([01]{38})" grammar="''00110000'' filter ''010'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="34" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[01]*" bitLength="10" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="9" pattern="00110000([01]{3})011([01]{30})([01]{14})([01]{38})" grammar="''00110000'' filter ''011'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="30" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[01]*" bitLength="14" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="8" pattern="00110000([01]{3})100([01]{27})([01]{17})([01]{38})" grammar="''00110000'' filter ''100'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="27" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="17" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="7" pattern="00110000([01]{3})101([01]{24})([01]{20})([01]{38})" grammar="''00110000'' filter ''101'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="6" pattern="00110000([01]{3})110([01]{20})([01]{24})([01]{38})" grammar="''00110000'' filter ''110'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:sgtin-96" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{12})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{11})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{10})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{9})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{8})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{7})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{6})\.([0-9]{7})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:sgtin">
      <option optionKey="12" pattern="urn:epc:id:sgtin:([0-9]{12})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:sgtin:([0-9]{11})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:sgtin:([0-9]{10})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:sgtin:([0-9]{9})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:sgtin:([0-9]{8})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:sgtin:([0-9]{7})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:sgtin:([0-9]{6})\.([0-9]{7})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="gtin=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="gtinprefixremainder" characterSet="[0-9]*" length="12" function="SUBSTR(gtin,1,12)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="indicatordigit" characterSet="[0-9]*" length="1" function="SUBSTR(gtin,0,1)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="itemrefremainder" characterSet="[0-9]*" function="SUBSTR(gtinprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="4" newFieldName="itemref" characterSet="[0-9]*" function="CONCAT(indicatordigit,itemrefremainder)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="5" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(gtinprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="indicatordigit" characterSet="[0-9]*" length="1" function="SUBSTR(itemref,0,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="itemrefremainder" characterSet="[0-9]*" function="SUBSTR(itemref,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="3" newFieldName="gtinprefix" characterSet="[0-9]*" length="13" function="CONCAT(indicatordigit,companyprefix,itemrefremainder)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="4" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(gtinprefix)"/>
    </level>
    <level type="ONS_HOSTNAME">
      <option optionKey="12" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="11" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="10" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="9" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="8" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="7" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="6" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  --COMMIT;

  --SSCC-64
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="SSCC-64" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00001000" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="39" length="5" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="11" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="39" length="6" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="10" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="39" length="7" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="9" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="39" length="8" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="8" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="39" length="9" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="7" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="39" length="10" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="6" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="39" length="11" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="companyprefix" characterSet="[0-9]*" function="TABLELOOKUP(companyprefixindex,tdt64bitcpi,companyprefixindex,companyprefix)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@index=''$1'']/@companyPrefix" tableParams="companyprefixindex"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefixlength" characterSet="[0-9]*" function="LENGTH(companyprefix)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="companyprefixindex" characterSet="[0-9]*" function="TABLELOOKUP(companyprefix,tdt64bitcpi,companyprefix,companyprefixindex)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@companyPrefix=''$1'']/@index" tableParams="companyprefix"/>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:sscc-64" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{12})\.([0-9]{5})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{11})\.([0-9]{6})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{10})\.([0-9]{7})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{9})\.([0-9]{8})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{8})\.([0-9]{9})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{7})\.([0-9]{10})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{6})\.([0-9]{11})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:sscc">
      <option optionKey="12" pattern="urn:epc:id:sscc:([0-9]{12})\.([0-9]{5})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:sscc:([0-9]{11})\.([0-9]{6})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:sscc:([0-9]{10})\.([0-9]{7})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:sscc:([0-9]{9})\.([0-9]{8})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:sscc:([0-9]{8})\.([0-9]{9})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:sscc:([0-9]{7})\.([0-9]{10})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:sscc:([0-9]{6})\.([0-9]{11})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="sscc=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="11" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="10" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="9" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="8" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="7" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="6" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="ssccprefixremainder" characterSet="[0-9]*" length="16" function="SUBSTR(sscc,1,16)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="extensiondigit" characterSet="[0-9]*" length="1" function="SUBSTR(sscc,0,1)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="serialrefremainder" characterSet="[0-9]*" function="SUBSTR(ssccprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="4" newFieldName="serialref" characterSet="[0-9]*" function="CONCAT(extensiondigit,serialrefremainder)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="5" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(ssccprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="extensiondigit" characterSet="[0-9]*" length="1" function="SUBSTR(serialref,0,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="serialrefremainder" characterSet="[0-9]*" function="SUBSTR(serialref,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="3" newFieldName="ssccprefix" characterSet="[0-9]*" length="17" function="CONCAT(extensiondigit,companyprefix,serialrefremainder)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="4" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(ssccprefix)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  --COMMIT;

  --SSCC-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="SSCC-96" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00110001" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00110001([01]{3})000([01]{40})([01]{18})000000000000000000000000" grammar="''00110001'' filter ''000'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[01]*" bitLength="40" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="18" length="5" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="11" pattern="00110001([01]{3})001([01]{37})([01]{21})000000000000000000000000" grammar="''00110001'' filter ''001'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="37" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="21" length="6" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="10" pattern="00110001([01]{3})010([01]{34})([01]{24})000000000000000000000000" grammar="''00110001'' filter ''010'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="34" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="9" pattern="00110001([01]{3})011([01]{30})([01]{28})000000000000000000000000" grammar="''00110001'' filter ''011'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="30" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="28" length="8" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="8" pattern="00110001([01]{3})100([01]{27})([01]{31})000000000000000000000000" grammar="''00110001'' filter ''100'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="27" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="31" length="9" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="7" pattern="00110001([01]{3})101([01]{24})([01]{34})000000000000000000000000" grammar="''00110001'' filter ''101'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="34" length="10" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="6" pattern="00110001([01]{3})110([01]{20})([01]{38})000000000000000000000000" grammar="''00110001'' filter ''110'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="38" length="11" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:sscc-96" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{12})\.([0-9]{5})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{11})\.([0-9]{6})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{10})\.([0-9]{7})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{9})\.([0-9]{8})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{8})\.([0-9]{9})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{7})\.([0-9]{10})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{6})\.([0-9]{11})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:sscc">
      <option optionKey="12" pattern="urn:epc:id:sscc:([0-9]{12})\.([0-9]{5})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:sscc:([0-9]{11})\.([0-9]{6})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:sscc:([0-9]{10})\.([0-9]{7})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:sscc:([0-9]{9})\.([0-9]{8})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:sscc:([0-9]{8})\.([0-9]{9})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:sscc:([0-9]{7})\.([0-9]{10})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:sscc:([0-9]{6})\.([0-9]{11})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="sscc=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="11" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="10" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="9" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="8" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="7" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="6" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="ssccprefixremainder" characterSet="[0-9]*" length="16" function="SUBSTR(sscc,1,16)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="extensiondigit" characterSet="[0-9]*" length="1" function="SUBSTR(sscc,0,1)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="serialrefremainder" characterSet="[0-9]*" function="SUBSTR(ssccprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="4" newFieldName="serialref" characterSet="[0-9]*" function="CONCAT(extensiondigit,serialrefremainder)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="5" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(ssccprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="extensiondigit" characterSet="[0-9]*" length="1" function="SUBSTR(serialref,0,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="serialrefremainder" characterSet="[0-9]*" function="SUBSTR(serialref,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="3" newFieldName="ssccprefix" characterSet="[0-9]*" length="17" function="CONCAT(extensiondigit,companyprefix,serialrefremainder)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="4" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(ssccprefix)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  --COMMIT;

  --USDOD-64
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="USDOD-64" optionKey="1" xmlns="">
    <level type="BINARY" prefixMatch="11001110" requiredFormattingParameters="">
      <option optionKey="1" pattern="11001110([01]{2})([01]{30})([01]{24})" grammar="''11001110'' filter cageordodaac serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="3" characterSet="[01]*" bitLength="2" name="filter"/>
        <field seq="2" characterSet="[01]*" compaction="6-bit" length="5" padChar=" " padDir="LEFT" bitLength="30" name="cageordodaac"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="16777215" characterSet="[01]*" bitLength="24" name="serial"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:usdod-64" requiredFormattingParameters="">
      <option optionKey="1" pattern="urn:epc:tag:usdod-64:([0-9])\.([0-9 A-HJ-NP4469 Z]{5})\.([0-9]+)" grammar="''urn:epc:tag:usdod-64:'' filter ''.'' cageordodaac ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="3" characterSet="[0-3]*" name="filter"/>
        <field seq="2" characterSet="[0-9 A-HJ-NP-Z]*" name="cageordodaac"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="16777215" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:usdod">
      <option optionKey="1" pattern="urn:epc:id:usdod:([0-9 A-HJ-NP-Z]{5})\.([0-9]+)" grammar="''urn:epc:id:usdod:'' cageordodaac ''.'' serial">
        <field seq="1" characterSet="[0-9 A-HJ-NP-Z]*" name="cageordodaac"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16777215" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="cageordodaac=">
      <option optionKey="1" pattern="cageordodaac=([0-9 A-HJ-NP-Z]{5});serial=([0-9]+)" grammar="''cageordodaac='' cageordodaac '';serial='' serial">
        <field seq="1" characterSet="[0-9 A-HJ-NP-Z]*" name="cageordodaac"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16777215" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  --COMMIT;

  --USDOD-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = "1.0" encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="USDOD-96" optionKey="1" xmlns="">
    <level type="BINARY" prefixMatch="00101111" requiredFormattingParameters="">
      <option optionKey="1" pattern="00101111([01]{4})([01]{48})([01]{36})" grammar="''00101111'' filter cageordodaac serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="15" characterSet="[01]*" bitLength="4" name="filter"/>
        <field seq="2" characterSet="[01]*" compaction="8-bit" padChar=" " padDir="LEFT" length="6" bitLength="48" name="cageordodaac"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[01]*" bitLength="36" name="serial"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:usdod-96" requiredFormattingParameters="">
      <option optionKey="1" pattern="urn:epc:tag:usdod-96:([0-9])\.([0-9 A-HJ-NP4517 Z]{5,6})\.([0-9]*)" grammar="''urn:epc:tag:usdod-96:'' filter ''.'' cageordodaac ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="15" characterSet="[0-9]*" name="filter"/>
        <field seq="2" characterSet="[0-9 A-HJ-NP-Z]*" name="cageordodaac"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:usdod">
      <option optionKey="1" pattern="urn:epc:id:usdod:([0-9 A-HJ-NP-Z]{5,6})\.([0-9]+)" grammar="''urn:epc:id:usdod:'' cageordodaac ''.'' serial">
        <field seq="1" characterSet="[0-9 A-HJ-NP-Z]*" name="cageordodaac"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="cageordodaac=">
      <option optionKey="1" pattern="cageordodaac=([0-9 A-HJ-NP-Z]{5,6});serial=([0-9]+)" grammar="''cageordodaac='' cageordodaac '';serial='' serial">
        <field seq="1" characterSet="[0-9 A-HJ-NP-Z]*" name="cageordodaac"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

END;
/
SHOW ERRORS;

call dbms_output.put_line('Make sure these values look OK:');
col category_name format a10;
col type_name format a10;
col encodings format a22;
col url format a64;
select dbms_lob.getlength(xsd_schema) as XML_VALIDATOR_CHAR_LENGTH from mgd_id_xml_validator;
select url, dbms_lob.getlength(content), use_local as LOOKUP_TABLE_CHAR_LENGTH from mgd_id_lookup_table;
select category_name, category_id from mgd_id_category;
select category_id, type_name, encodings, dbms_lob.getlength(tdt_xml) XML_TDTs_CHAR_LENGTH  from mgd_id_scheme;

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessend.sql
Rem ********************************************************************

