Rem
Rem $Header: rdbms/admin/catnodrdaas.sql /main/4 2017/05/28 22:46:02 stanaya Exp $
Rem
Rem catnodrdaas.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnodrdaas.sql - CATalog NO DRDA Application Server
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnodrdaas.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnodrdaas.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    pcastro     04/16/12 - bug 13815188: fix default owner/qualifier usage
Rem    pcastro     11/03/11 - Created
Rem

drop public synonym DBMS_DRDAAS;
drop public synonym DBMS_DRDAAS_ADMIN;

drop public synonym USER_DRDAASTRACE;
drop public synonym DBA_DRDAASTRACE;

drop public synonym ALL_DRDAASPACKAGE;
drop public synonym USER_DRDAASPACKAGE;
drop public synonym DBA_DRDAASPACKAGE;

drop public synonym USER_DRDAASPACKSTMT;
drop public synonym DBA_DRDAASPACKSTMT;

drop public synonym ALL_DRDAASPACKAUTH;
drop public synonym USER_DRDAASPACKAUTH;
drop public synonym DBA_DRDAASPACKAUTH;

drop public synonym ALL_DRDAASPACKSIDE;
drop public synonym USER_DRDAASPACKSIDE;
drop public synonym DBA_DRDAASPACKSIDE;


drop role DRDAAS_USER_ROLE;
drop role DRDAAS_ADMIN_ROLE;

drop user SYSIBM cascade;

commit;
DOC
#######################################################################
  Customer should drop the SYSIBM tablespace.

Eg:
  drop tablespace SYSIBM;

#######################################################################
#

