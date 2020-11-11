Rem
Rem $Header: rdbms/admin/dbmskzxp.sql /main/4 2014/02/20 12:45:43 surman Exp $
Rem
Rem dbmskzxp.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmskzxp.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmskzxp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmskzxp.sql
Rem SQL_PHASE: DBMSKZXP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    snadhika    11/12/09 - Remove set_system_acl 
Rem    taahmed     10/29/09 - set_xs_acl_result_size
Rem    jsamuel     09/19/07 - add xsCallback check
Rem    jsamuel     12/13/06 - moved fidm packaged to dbmskzxp
Rem    jsamuel     11/29/06 - Package specification to set XS system paramaeters
Rem    jsamuel     11/29/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


CREATE OR REPLACE PACKAGE DBMS_XS_SYSTEM AUTHID CURRENT_USER AS

  PROCEDURE block_principal_changes (bpc IN BOOLEAN) ;

  FUNCTION check_xsProvision RETURN BOOLEAN ;

  FUNCTION check_xsCallback RETURN BOOLEAN ;

  PROCEDURE set_xs_acl_result_size (numacl IN PLS_INTEGER);

END DBMS_XS_SYSTEM ;
/
show errors ;


CREATE OR REPLACE PACKAGE dbms_xs_system_ffi AUTHID CURRENT_USER AS

  PROCEDURE block_principal_changes (bpc IN BOOLEAN) ;

  PROCEDURE check_xsProvision (granted OUT BOOLEAN) ;

  PROCEDURE check_xsCallback (granted OUT BOOLEAN) ; 

  PROCEDURE set_xs_acl_result_size (numacl IN PLS_INTEGER);

END dbms_xs_system_ffi ;
/
show errors ;

CREATE OR REPLACE PACKAGE dbms_xs_fidm AUTHID CURRENT_USER AS

  PROCEDURE dbms_xs_fidm_insert(contentXML XMLType) ;

  PROCEDURE dbms_xs_fidm_update(contentXMLold XMLType, contentXMLnew XMLTYPE) ;

  PROCEDURE dbms_xs_fidm_delete(contentXML XMLType) ;

END dbms_xs_fidm ;
/
show errors ;


@?/rdbms/admin/sqlsessend.sql
