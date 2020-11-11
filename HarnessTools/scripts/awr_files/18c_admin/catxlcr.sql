Rem
Rem $Header: rdbms/admin/catxlcr.sql /main/13 2014/11/14 06:58:41 raeburns Exp $
Rem
Rem catxlcr.sql
Rem
Rem Copyright (c) 2001, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxlcr.sql - XML schema definition for LCRs
Rem
Rem    DESCRIPTION
Rem      This script registers the LCR schema
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catxlcr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxlcr.sql
Rem SQL_PHASE: CATXLCR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catxrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    09/19/14 - add error handling for rerun
Rem    raeburns    06/25/14 - drop package after use
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    spannala    08/21/03 - using package variables to register the lcr 
Rem    htran       06/26/03 - add long_information
Rem    alakshmi    01/21/03 - remove lines for testing
Rem    liwong      09/09/02 - extra attributes
Rem    alakshmi    08/22/02 - lrg 102518
Rem    rvenkate    02/14/02 - varchar is not supported
Rem    alakshmi    02/04/02 - Lob support
Rem    alakshmi    01/30/02 - minOccurs=0 for object_type
Rem    alakshmi    01/23/02 - SQLType:CHAR=>VARCHAR2
Rem    alakshmi    01/15/02 - Merged alakshmi_xml_supp
Rem    alakshmi    01/15/02 - targetNamespace changes
Rem    alakshmi    01/07/02 - DDL LCR
Rem    alakshmi    12/10/01 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem create lcr$_xml_schema package with constants
@@catxlcr1.sql

DECLARE
  schema_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_exists,-31085);
BEGIN
  dbms_xmlschema.registerSchema(schemaURL => lcr$_xml_schema.CONFIGURL, 
                                schemaDoc => lcr$_xml_schema.CONFIGXSD_10101,
                                local => FALSE,
                                genTypes => TRUE,
                                genBean => FALSE,
                                genTables => FALSE,
                                force => FALSE);
EXCEPTION
  WHEN schema_exists THEN
    NULL;
 END;
/

Rem package no longer needed
DROP PACKAGE lcr$_xml_schema;

@?/rdbms/admin/sqlsessend.sql
