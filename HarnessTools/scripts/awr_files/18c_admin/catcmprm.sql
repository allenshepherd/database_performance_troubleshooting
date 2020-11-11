Rem
Rem $Header: rdbms/admin/catcmprm.sql /main/2 2017/05/28 22:46:01 stanaya Exp $
Rem
Rem catcmprm.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catcmprm.sql - CATproc CoMPonenet Removal 
Rem
Rem    DESCRIPTION
Rem      Invoke the component removal script for input component ID
Rem
Rem    INPUT
Rem       This expects the following input:
Rem       component ID (JAVAVM, OWM, CONTEXT, etc)
Rem
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catcmprm.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catcmprm.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling    06/07/06 - Created
Rem

SET SERVEROUTPUT ON;
SET VERIFY OFF;

DEFINE comp_id = &1 -- component id
DEFINE removal_file = 'nothing.sql'      

Rem Setup component script filename variable
COLUMN removal_name NEW_VALUE removal_file NOPRINT;
SELECT dbms_registry_sys.removal_script('&comp_id')
   AS removal_name FROM DUAL;

SET SERVEROUTPUT OFF 
@&removal_file

