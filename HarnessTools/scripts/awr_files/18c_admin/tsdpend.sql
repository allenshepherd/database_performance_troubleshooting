Rem
Rem $Header: rdbms/admin/tsdpend.sql /main/9 2017/02/01 23:08:09 amunnoli Exp $
Rem
Rem tsdpend.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      tsdpend.sql - TSDP END script
Rem
Rem    DESCRIPTION
Rem      This script registers the XML schemas for TSDP.
Rem
Rem    NOTES
Rem      Called by catpend.sql
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/tsdpend.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/tsdpend.sql
Rem SQL_PHASE: TSDPEND
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catxrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amunnoli    02/01/17 - Bug 25455795: Annotate COLUMN and COMMENT fields
Rem    anupkk      10/13/15 - Bug 20322354: Fix the TSDP XML to recognise the
Rem                           new tags added in ER 9938589
Rem    amunnoli    10/28/14 - Bug 18747400:Add SQLCollType where maxOccurs > 0
Rem    amunnoli    09/26/14 - Bug 18747400: Annotate XML schemas
Rem    raeburns    08/21/14 - Project 46659: XDB Upgrade Restructure 
Rem                         - add error handling
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      04/12/12 - 13615447: Add Add SQL patching tags
Rem    dgraj       03/19/12 - ER 13485095: Make SENSITIVE_INFO optional for
Rem                           sensitivedata_12_1.xsd
Rem    dgraj       10/31/11 - Project 32079: Transparent Sensitive Data
Rem                           Protection (TSDP)
Rem    dgraj       10/31/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

DECLARE
  schema_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_exists,-31085);

BEGIN

 BEGIN
  -- Register the schema for Sensitive Data
  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    SCHEMAURL => 'http://xmlns.oracle.com/sdm/sensitivedata_12_1.xsd',
    SCHEMADOC => '<schema elementFormDefault="qualified"
                          targetNamespace="http://xmlns.oracle.com/sdm/sensitive_data_12.1"
                          xmlns="http://www.w3.org/2001/XMLSchema"
                          xmlns:tsdm="http://xmlns.oracle.com/sdm/sensitive_data_12.1"
                          xmlns:xdb="http://xmlns.oracle.com/xdb">

<!-- annotation>
	<documentation xml:lang="en">
		Sensitive Data import.	
		Copyright Oracle 2011. All rights reserved.
	</documentation>
</annotation -->

	<element name="DDRM" type="tsdm:DDRMType"/>
		<complexType name="DDRMType" xdb:SQLType="ORATSDP_SD_DDRM_T">
			<sequence>
				<element name="NAME" 	 	   type="string"/>
				<element name="APP_SUITE_NAME"   type="string"/>
				<element name="VERSION_INFO" 	   type="string"/>
				<element name="SOURCE" 	 	   type="string"/>
				<element name="SENSITIVE_TYPE"   type="tsdm:SENSITIVE_TYPEType" minOccurs="0" maxOccurs="unbounded" xdb:SQLName="SENSITIVE_TYPE" xdb:SQLCollType="ORATSDP_SD_SENSITIVE_TYPE_V"/>
				<element name="APPLICATION" 	   type="tsdm:APPLICATIONType" minOccurs="0" maxOccurs="unbounded" xdb:SQLName="APPLICATION" xdb:SQLCollType="ORATSDP_SD_APPLICATION_V"/>
			</sequence>
			<attribute name="META_VER" type="string" use="optional"/>
			<attribute name="PROD_VER" type="string" use="optional"/>
		</complexType>

<!-- annotation>
	<documentation xml:lang="en">
		SENSITIVE_TYPE defines a sensitive type.
	</documentation>
</annotation -->

	<complexType name="SENSITIVE_TYPEType" xdb:SQLType="ORATSDP_SD_SENSITIVE_TYPE_T">
		<sequence>
			<element name="NAME"   			type="string"/>
			<element name="OWNER"  			type="string"/>
			<element name="COL_NAME_PATTERN"  	type="string"/>
			<element name="COL_COMMENT_PATTERN" type="string"/>
			<element name="DATA_REGEX"  		type="string"/>
			<element name="DESCRIPTION"	  	type="string"/>
			<element name="OPERATOR"	  	type="string"/>
		</sequence>
		<attribute name="IS_SYS_DEFINED" use="optional">
			<simpleType>
				<restriction  base="string">
					<enumeration value = "Y"/>
					<enumeration value = "N"/>
				</restriction>
			</simpleType>
		</attribute>
	</complexType> 

<!-- annotation>
	<documentation xml:lang="en">
		APPLICATION contains the list of sensitive columns for an Application/Schema
	</documentation>
</annotation -->

	<element name="APPLICATION" type="tsdm:APPLICATIONType"/>
		<complexType name="APPLICATIONType" xdb:SQLType="ORATSDP_SD_APPLICATION_T">
			<sequence>
				<element name="NAME"    	      type="string" /> 
				<element name="SHORT_NAME"    	type="string" /> 
				<element name="SCHEMA_NAME"    	type="string" /> 
				<element name="SOURCE" 		   	type="string" />
				<element name="SENSITIVE_INFO"     	type="tsdm:SENSITIVE_INFOType" maxOccurs="unbounded" xdb:SQLName="SENSITIVE_INFO" xdb:SQLCollType="ORATSDP_SD_SENSITIVE_INFO_V"/>
			</sequence>
		</complexType>

<!-- annotation>
	<documentation xml:lang="en">
		SENSITIVE_INFO defines a sensitive column.
	</documentation>
</annotation -->

	<complexType name="SENSITIVE_INFOType" xdb:SQLType="ORATSDP_SD_SENSITIVE_INFO_T">
		<sequence>
			<element name="SHORT_NAME"   type="string"/>
			<element name="COMMENT" type="string" xdb:SQLName="COMMENT_"/>
			<element name="TABLE_NAME"    type="string"/>
			<element name="COLUMN" type="string" xdb:SQLName="COLUMN_"/>
			<element name="SOURCE"    type="string"/>
			<element name="TYPE"    type="string"/>
			<element name="OBJECT_TYPE"    type="string" minOccurs="0" maxOccurs="unbounded" xdb:SQLName="SENSITIVE_INFO_OT" xdb:SQLCollType="ORATSDP_SD_SENSITIVE_INFO_OTV"/>
		</sequence>
	</complexType>          
                    
</schema>',
 LOCAL     => FALSE,
 GENTYPES  => TRUE,
 GENTABLES => FALSE,
 ENABLEHIERARCHY => DBMS_XMLSCHEMA.ENABLE_HIERARCHY_NONE);

 EXCEPTION
  WHEN schema_exists THEN
    NULL;
 END;

-- Register the schema for Sensitive Column Types
 BEGIN
  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    SCHEMAURL => 'http://xmlns.oracle.com/sdm/sensitivetypes_12_1.xsd',
    SCHEMADOC => '<schema elementFormDefault="qualified"
                          targetNamespace="http://xmlns.oracle.com/sdm/sensitive_types_12.1"
                          xmlns="http://www.w3.org/2001/XMLSchema"
                          xmlns:tsdm="http://xmlns.oracle.com/sdm/sensitive_types_12.1"
                          xmlns:xdb="http://xmlns.oracle.com/xdb">

<!-- annotation>
	<documentation xml:lang="en">
		Sensitive Types import.	
		Copyright Oracle 2011. All rights reserved.
	</documentation>
</annotation -->

	<element name="DDRM" type="tsdm:DDRMType"/>
		<complexType name="DDRMType" xdb:SQLType="ORATSDP_SCT_DDRM_T">
			<sequence>
				<element name="NAME" 	 	   type="string"/>
				<element name="APP_SUITE_NAME"   type="string"/>
				<element name="VERSION_INFO" 	   type="string"/>
				<element name="SOURCE" 	 	   type="string"/>
				<element name="SENSITIVE_TYPE" 	type="tsdm:SENSITIVE_TYPEType" minOccurs="1" maxOccurs="unbounded" xdb:SQLName="SENSITIVE_TYPE" xdb:SQLCollType="ORATSDP_SCT_SENSITIVE_TYPE_V"/>
			</sequence>
			<attribute name="META_VER" type="string" use="optional"/>
			<attribute name="PROD_VER" type="string" use="optional"/>
		</complexType>           
       
<!-- annotation>
	<documentation xml:lang="en">
		SENSITIVE_TYPE defines a sensitive type.
	</documentation>
</annotation -->

	<complexType name="SENSITIVE_TYPEType" xdb:SQLType="ORATSDP_SCT_SENSITIVE_TYPE_T">
		<sequence>
			<element name="NAME"   			type="string"/>
			<element name="OWNER"  			type="string"/>
			<element name="COL_NAME_PATTERN"  	type="string"/>
			<element name="COL_COMMENT_PATTERN" type="string"/>
			<element name="DATA_REGEX"  		type="string"/>
			<element name="DESCRIPTION"	  	type="string"/>
			<element name="OPERATOR"	  	type="string"/>
		</sequence>
		<attribute name="IS_SYS_DEFINED" use="optional">
			<simpleType>
				<restriction  base="string">
					<enumeration value = "Y"/>
					<enumeration value = "N"/>
				</restriction>
			</simpleType>
		</attribute>
	</complexType>    

</schema>',
 LOCAL     => FALSE,
 GENTYPES  => TRUE,
 GENTABLES => FALSE,
 ENABLEHIERARCHY => DBMS_XMLSCHEMA.ENABLE_HIERARCHY_NONE);

 EXCEPTION
  WHEN schema_exists THEN
    NULL;
 END;

END;
/



@?/rdbms/admin/sqlsessend.sql
