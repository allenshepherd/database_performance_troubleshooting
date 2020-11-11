Rem
Rem $Header: rdbms/admin/catxdav2.sql /main/3 2014/02/20 12:45:53 surman Exp $
Rem
Rem catxdav2.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxdav2.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catxdav2.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxdav2.sql
Rem SQL_PHASE: CATXDAV2
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catxdbz.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    mrafiq      04/07/06 - cleaning up 
Rem    petam       03/17/06 - 
Rem    abagrawa    03/15/06 - Drop dav schema registration functions 
Rem    abagrawa    03/15/06 - Drop dav schema registration functions 
Rem    abagrawa    03/15/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


drop procedure register_dav_schema;

@?/rdbms/admin/sqlsessend.sql
