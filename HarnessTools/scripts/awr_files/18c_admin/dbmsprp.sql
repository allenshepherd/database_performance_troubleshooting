Rem
Rem $Header: rdbms/admin/dbmsprp.sql /main/14 2014/02/20 12:45:38 surman Exp $
Rem
Rem dbmsprp.sql
Rem
Rem Copyright (c) 2001, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsprp.sql - Streams Propagation APIs
Rem
Rem    DESCRIPTION
Rem      This file contains the API for Streams Propagation
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsprp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsprp.sql
Rem SQL_PHASE: DBMSPRP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dbmsstr.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      04/12/12 - 13615447: Add SQL patching tags
Rem    juyuan      05/23/06 - rename auto_merge to auto_merge_threshold 
Rem    juyuan      01/23/06 - add parameters to create_propagation 
Rem    narora      03/02/05 - add start/stop apis 
Rem    rvenkate    05/05/04 - add param to streams propagation apis 
Rem    htran       11/04/02 - change drop_unused_rule_set param to
Rem                           drop_unused_rule_sets
Rem    elu         08/20/02 - add negative rule sets
Rem    htran       09/18/02 - add drop_unused_rule_set parameter
Rem                           to drop_propagation
Rem    kmeiyyap    02/18/02 - default destination_dblink to NULL.
Rem    wesmith     02/12/02 - make dbms_propagation_adm invoker's rights
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    alakshmi    11/08/01 - Merged alakshmi_apicleanup
Rem    kmeiyyap    10/30/01 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_propagation_adm AUTHID CURRENT_USER AS

  PROCEDURE create_propagation(
       propagation_name          IN VARCHAR2,
       source_queue              IN VARCHAR2,
       destination_queue         IN VARCHAR2,
       destination_dblink        IN VARCHAR2  DEFAULT NULL,
       rule_set_name             IN VARCHAR2  DEFAULT NULL,
       negative_rule_set_name    IN VARCHAR2  DEFAULT NULL,
       queue_to_queue            IN BOOLEAN   DEFAULT NULL,
       -- The following two parameters are ONLY used by 
       -- split-merge api
       original_propagation_name IN VARCHAR2  DEFAULT NULL,
       auto_merge_threshold      IN NUMBER    DEFAULT NULL);

  PROCEDURE alter_propagation(
       propagation_name         IN VARCHAR2,
       rule_set_name            IN VARCHAR2 DEFAULT NULL,
       remove_rule_set          IN BOOLEAN  DEFAULT FALSE,
       negative_rule_set_name   IN VARCHAR2 DEFAULT NULL,
       remove_negative_rule_set IN BOOLEAN  DEFAULT FALSE);

  PROCEDURE drop_propagation(
       propagation_name      IN VARCHAR2,
       drop_unused_rule_sets IN BOOLEAN DEFAULT FALSE);

  PROCEDURE stop_propagation(
       propagation_name      IN VARCHAR2,
       force                 IN BOOLEAN DEFAULT FALSE);

  PROCEDURE start_propagation(
       propagation_name      IN VARCHAR2);

END dbms_propagation_adm;
/
GRANT EXECUTE ON dbms_propagation_adm TO execute_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_propagation_adm FOR dbms_propagation_adm
/


@?/rdbms/admin/sqlsessend.sql
