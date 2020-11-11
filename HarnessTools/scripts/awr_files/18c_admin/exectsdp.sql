Rem
Rem $Header: rdbms/admin/exectsdp.sql /main/3 2014/02/20 12:45:37 surman Exp $
Rem
Rem exectsdp.sql
Rem
Rem Copyright (c) 2011, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      exectsdp.sql - EXECute anonymous pl/sql blocks for TSDP
Rem
Rem    DESCRIPTION
Rem      This script is used to execute anonymous PL/SQL blocks.
Rem
Rem    NOTES
Rem      Called by catpexec.sql
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/exectsdp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/exectsdp.sql
Rem SQL_PHASE: EXECTSDP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      04/12/12 - 13615447: Add Add SQL patching tags
Rem    dgraj       10/13/11 - Project 32079: Anonumous PL/SQL blocks for TSDP
Rem    dgraj       10/13/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Create the default REDACT_AUDIT Policy 
DECLARE
radm_feature_options sys.dbms_TSDP_protect.FEATURE_OPTIONS;
policy_conditions sys.dbms_TSDP_protect.POLICY_CONDITIONS;
BEGIN
  radm_feature_options ('ORA$TSDP_DEFAULT') := 'ORA$TSDP_DEFAULT';

  begin

  sys.dbms_TSDP_protect.add_policy('REDACT_AUDIT', 0, radm_feature_options,
                                   policy_conditions);

  exception
    when others then
      null;

  end;

END;
/


@?/rdbms/admin/sqlsessend.sql
