Rem
Rem $Header: rdbms/admin/catxlcr1.sql /main/6 2015/05/22 12:06:37 sgarduno Exp $
Rem
Rem catxlcr1.sql
Rem
Rem Copyright (c) 2001, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxlcr1.sql - XML schema definition for LCRs
Rem
Rem    DESCRIPTION
Rem      This script declares the LCR schema
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catxlcr1.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxlcr1.sql
Rem SQL_PHASE: CATXLCR1
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catxlcr.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sbaez       04/28/15 - Bug 20303382 LIDENT SA: ddl_lcr_t type does not
Rem                           support long identifier names
Rem    jorgrive    10/20/14 - Bug 18734501: annotate complexType xmlschema
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    alakshmi    10/16/03 - Bug 3197273 
Rem    bpwang      11/07/03 - Bug 3240955: Store rowid extra attr as urowid
Rem    spannala    08/29/03 - spannala_upglrg_2 
Rem    sichandr    07/28/03 - add LCR Schema
Rem    sichandr    07/28/03 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package lcr$_xml_schema as

  CONFIGURL VARCHAR2(2000) := 
             'http://xmlns.oracle.com/streams/schemas/lcr/streamslcr.xsd';
  CONFIGXSD_10101 VARCHAR2(20000) := 
'<schema xmlns="http://www.w3.org/2001/XMLSchema" 
        targetNamespace="http://xmlns.oracle.com/streams/schemas/lcr" 
        xmlns:lcr="http://xmlns.oracle.com/streams/schemas/lcr"
        xmlns:xdb="http://xmlns.oracle.com/xdb"
          version="1.0"
        elementFormDefault="qualified">

  <simpleType name = "short_name">
    <restriction base = "string">
      <maxLength value="30"/>
    </restriction>
  </simpleType>

  <simpleType name = "long_name">
    <restriction base = "string">
      <maxLength value="4000"/>
    </restriction>
  </simpleType>

  <simpleType name = "db_name">
    <restriction base = "string">
      <maxLength value="128"/>
    </restriction>
  </simpleType>

  <!-- Default session parameter is used if format is not specified -->
  <complexType name="datetime_format" xdb:SQLType="LCR_DATETIME_FORMAT_T">
    <sequence>
      <element name = "value" type = "string" nillable="true"/>
      <element name = "format" type = "string" minOccurs="0" nillable="true"/>
    </sequence>
  </complexType>

  <complexType name="anydata" xdb:SQLType="LCR_ANYDATA_T">
    <choice>
      <element name="varchar2" type = "string" xdb:SQLType="CLOB" 
                                                        nillable="true"/>

      <!-- Represent char as varchar2. xdb:CHAR blank pads upto 2000 bytes! -->
      <element name="char" type = "string" xdb:SQLType="CLOB"
                                                        nillable="true"/>
      <element name="nchar" type = "string" xdb:SQLType="NCLOB"
                                                        nillable="true"/>

      <element name="nvarchar2" type = "string" xdb:SQLType="NCLOB"
                                                        nillable="true"/>
      <element name="number" type = "double" xdb:SQLType="NUMBER"
                                                        nillable="true"/>
      <element name="raw" type = "hexBinary" xdb:SQLType="BLOB" 
                                                        nillable="true"/>
      <element name="date" type = "lcr:datetime_format"/>
      <element name="timestamp" type = "lcr:datetime_format"/>
      <element name="timestamp_tz" type = "lcr:datetime_format"/>
      <element name="timestamp_ltz" type = "lcr:datetime_format"/>

      <!-- Interval YM should be as per format allowed by SQL -->
      <element name="interval_ym" type = "string" nillable="true"/>

      <!-- Interval DS should be as per format allowed by SQL -->
      <element name="interval_ds" type = "string" nillable="true"/>

      <element name="urowid" type = "string" xdb:SQLType="VARCHAR2"
                                                        nillable="true"/>
    </choice>
  </complexType>

  <complexType name="column_value" xdb:SQLType="LCR_COLUMN_VALUE_T">
    <sequence>
      <element name = "column_name" type = "lcr:long_name" nillable="false"/>
      <element name = "data" type = "lcr:anydata" nillable="false"/>
      <element name = "lob_information" type = "string" minOccurs="0"
                                                           nillable="true"/>
      <element name = "lob_offset" type = "nonNegativeInteger" minOccurs="0"
                                                           nillable="true"/>
      <element name = "lob_operation_size" type = "nonNegativeInteger" 
                                             minOccurs="0" nillable="true"/>
      <element name = "long_information" type = "string" minOccurs="0"
                                                           nillable="true"/>
    </sequence>
  </complexType>

  <complexType name="extra_attribute" xdb:SQLType="LCR_EXTRA_ATTRIBUTE_T">
    <sequence>
      <element name = "attribute_name" type = "lcr:db_name"/>
      <element name = "attribute_value" type = "lcr:anydata"/>
    </sequence>
  </complexType>

  <element name = "ROW_LCR" xdb:defaultTable="">
    <complexType xdb:SQLType="ROW_LCR_T">
      <sequence>
        <element name = "source_database_name" type = "lcr:db_name" 
                                                            nillable="false"/>
        <element name = "command_type" type = "string" nillable="false"/>
        <element name = "object_owner" type = "lcr:db_name" 
                                                            nillable="false"/>
        <element name = "object_name" type = "lcr:db_name"
                                                            nillable="false"/>
        <element name = "tag" type = "hexBinary" xdb:SQLType="RAW" 
                                               minOccurs="0" nillable="true"/>
        <element name = "transaction_id" type = "string" minOccurs="0" 
                                                             nillable="true"/>
        <element name = "scn" type = "double" xdb:SQLType="NUMBER" 
                                               minOccurs="0" nillable="true"/>
        <element name = "old_values" minOccurs = "0">
          <complexType xdb:SQLType="LCR_OLD_VALUES_T">
            <sequence>
              <element name = "old_value" type="lcr:column_value" 
                       maxOccurs = "unbounded" 
                       xdb:SQLCollType="LCR_OLD_NEW_VALUE_T"/>
            </sequence>
          </complexType>
        </element>
        <element name = "new_values" minOccurs = "0">
          <complexType xdb:SQLType="LCR_NEW_VALUES_T">
            <sequence>
              <element name = "new_value" type="lcr:column_value" 
                       maxOccurs = "unbounded"
                       xdb:SQLCollType="LCR_OLD_NEW_VALUE_T"/>
            </sequence>
          </complexType>
        </element>
        <element name = "extra_attribute_values" minOccurs = "0">
          <complexType xdb:SQLType="LCR_EXTRA_ATTRIBUTE_VALUES_T">
            <sequence>
              <element name = "extra_attribute_value"
                       type="lcr:extra_attribute"
                       maxOccurs = "unbounded"
                       xdb:SQLCollType="LCR_EXTRA_ATTRIBUTE_VALUE_T"/>
            </sequence>
          </complexType>
        </element>
      </sequence>
    </complexType>
  </element>

  <element name = "DDL_LCR" xdb:defaultTable="">
    <complexType xdb:SQLType="DDL_LCR_T">
      <sequence>
        <element name = "source_database_name" type = "lcr:db_name" 
                                                        nillable="false"/>
        <element name = "command_type" type = "string" nillable="false"/>
        <element name = "current_schema" type = "lcr:db_name"
                                                        nillable="false"/>
        <element name = "ddl_text" type = "string" xdb:SQLType="CLOB"
                                                        nillable="false"/>
        <element name = "object_type" type = "string"
                                        minOccurs = "0" nillable="true"/>
        <element name = "object_owner" type = "lcr:db_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "object_name" type = "lcr:db_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "logon_user" type = "lcr:db_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "base_table_owner" type = "lcr:db_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "base_table_name" type = "lcr:db_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "tag" type = "hexBinary" xdb:SQLType="RAW"
                                        minOccurs = "0" nillable="true"/>
        <element name = "transaction_id" type = "string"
                                        minOccurs = "0" nillable="true"/>
        <element name = "scn" type = "double" xdb:SQLType="NUMBER"
                                        minOccurs = "0" nillable="true"/>
        <element name = "extra_attribute_values" minOccurs = "0">
          <complexType xdb:SQLType="LCR_EXTRA_ATTRIBUTE_VALUES_T">
            <sequence>
              <element name = "extra_attribute_value"
                       type="lcr:extra_attribute"
                       maxOccurs = "unbounded"
                       xdb:SQLCollType="LCR_EXTRA_ATTRIBUTE_VALUE_T"/>
            </sequence>
          </complexType>
        </element>
      </sequence>
    </complexType>
  </element>
</schema>';

  CONFIGXSD_9204 VARCHAR2(20000) := 
'<schema xmlns="http://www.w3.org/2001/XMLSchema" 
        targetNamespace="http://xmlns.oracle.com/streams/schemas/lcr" 
        xmlns:lcr="http://xmlns.oracle.com/streams/schemas/lcr"
        xmlns:xdb="http://xmlns.oracle.com/xdb"
          version="1.0"
        elementFormDefault="qualified">

  <simpleType name = "short_name">
    <restriction base = "string">
      <maxLength value="30"/>
    </restriction>
  </simpleType>

  <simpleType name = "long_name">
    <restriction base = "string">
      <maxLength value="4000"/>
    </restriction>
  </simpleType>

  <simpleType name = "db_name">
    <restriction base = "string">
      <maxLength value="128"/>
    </restriction>
  </simpleType>

  <!-- Default session parameter is used if format is not specified -->
  <complexType name="datetime_format" xdb:SQLType="LCR_DATETIME_FORMAT_T">
    <sequence>
      <element name = "value" type = "string" nillable="true"/>
      <element name = "format" type = "string" minOccurs="0" nillable="true"/>
    </sequence>
  </complexType>

  <complexType name="anydata" xdb:SQLType="LCR_ANYDATA_T">
    <choice>
      <element name="varchar2" type = "string" xdb:SQLType="VARCHAR2" 
                                                        nillable="true"/>

      <!-- Represent char as varchar2. xdb:CHAR blank pads upto 2000 bytes! -->
      <element name="char" type = "string" xdb:SQLType="VARCHAR2"
                                                        nillable="true"/>
      <element name="nchar" type = "string" xdb:SQLType="NVARCHAR2"
                                                        nillable="true"/>

      <element name="nvarchar2" type = "string" xdb:SQLType="NVARCHAR2"
                                                        nillable="true"/>
      <element name="number" type = "double" xdb:SQLType="NUMBER"
                                                        nillable="true"/>
      <element name="raw" type = "hexBinary" xdb:SQLType="RAW" 
                                                        nillable="true"/>
      <element name="date" type = "lcr:datetime_format"/>
      <element name="timestamp" type = "lcr:datetime_format"/>
      <element name="timestamp_tz" type = "lcr:datetime_format"/>
      <element name="timestamp_ltz" type = "lcr:datetime_format"/>

      <!-- Interval YM should be as per format allowed by SQL -->
      <element name="interval_ym" type = "string" nillable="true"/>

      <!-- Interval DS should be as per format allowed by SQL -->
      <element name="interval_ds" type = "string" nillable="true"/>

    </choice>
  </complexType>

  <complexType name="column_value" xdb:SQLType="LCR_COLUMN_VALUE_T">
    <sequence>
      <element name = "column_name" type = "lcr:long_name" nillable="false"/>
      <element name = "data" type = "lcr:anydata" nillable="false"/>
      <element name = "lob_information" type = "string" minOccurs="0"
                                                           nillable="true"/>
      <element name = "lob_offset" type = "nonNegativeInteger" minOccurs="0"
                                                           nillable="true"/>
      <element name = "lob_operation_size" type = "nonNegativeInteger" 
                                             minOccurs="0" nillable="true"/>
    </sequence>
  </complexType>

  <element name = "ROW_LCR">
    <complexType xdb:SQLType="ROW_LCR_T">
      <sequence>
        <element name = "source_database_name" type = "lcr:db_name" 
                                                            nillable="false"/>
        <element name = "command_type" type = "string" nillable="false"/>
        <element name = "object_owner" type = "lcr:db_name" 
                                                            nillable="false"/>
        <element name = "object_name" type = "lcr:db_name"
                                                            nillable="false"/>
        <element name = "tag" type = "hexBinary" xdb:SQLType="RAW" 
                                               minOccurs="0" nillable="true"/>
        <element name = "transaction_id" type = "string" minOccurs="0" 
                                                             nillable="true"/>
        <element name = "scn" type = "double" xdb:SQLType="NUMBER" 
                                               minOccurs="0" nillable="true"/>
        <element name = "old_values" minOccurs = "0">
          <complexType xdb:SQLType="LCR_OLD_VALUES_T">
            <sequence>
              <element name = "old_value" type="lcr:column_value" 
                       maxOccurs = "unbounded"
                       xdb:SQLCollType="LCR_OLD_NEW_VALUE_T"/>
            </sequence>
          </complexType>
        </element>
        <element name = "new_values" minOccurs = "0">
          <complexType xdb:SQLType="LCR_NEW_VALUES_T">
            <sequence>
              <element name = "new_value" type="lcr:column_value" 
                       maxOccurs = "unbounded"
                       xdb:SQLCollType="LCR_OLD_NEW_VALUE_T"/>
            </sequence>
          </complexType>
        </element>
      </sequence>
    </complexType>
  </element>

  <element name = "DDL_LCR">
    <complexType xdb:SQLType="DDL_LCR_T">
      <sequence>
        <element name = "source_database_name" type = "lcr:db_name" 
                                                        nillable="false"/>
        <element name = "command_type" type = "string" nillable="false"/>
        <element name = "current_schema" type = "lcr:db_name"
                                                        nillable="false"/>
        <element name = "ddl_text" type = "string" nillable="false"/>
        <element name = "object_type" type = "string"
                                        minOccurs = "0" nillable="true"/>
        <element name = "object_owner" type = "lcr:db_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "object_name" type = "lcr:db_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "logon_user" type = "lcr:db_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "base_table_owner" type = "lcr:db_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "base_table_name" type = "lcr:db_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "tag" type = "hexBinary" xdb:SQLType="RAW"
                                        minOccurs = "0" nillable="true"/>
        <element name = "transaction_id" type = "string"
                                        minOccurs = "0" nillable="true"/>
        <element name = "scn" type = "double" xdb:SQLType="NUMBER"
                                        minOccurs = "0" nillable="true"/>
      </sequence>
    </complexType>
  </element>
</schema>';
end;
/


@?/rdbms/admin/sqlsessend.sql
