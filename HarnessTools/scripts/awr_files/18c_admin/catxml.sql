Rem
Rem $Header: rdbms/admin/catxml.sql /main/7 2013/03/25 10:50:17 qyu Exp $
Rem
Rem catxml.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxml.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catxml.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxml.sql
Rem SQL_PHASE: CATXML
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptyps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    qyu         03/18/13 - Common start and end scripts
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    rburns      05/04/06 - move prvt files 
Rem    hxzhang     04/11/06 - added catxtblidx.sql
Rem    amanikut    04/09/01 - reorder tests
Rem    rbooredd    04/06/01 - Switch order
Rem    mkrishna    06/22/00 - Created
Rem
Rem    Should be run in compatible 8.2.0 mode
Rem 

@@?/rdbms/admin/sqlsessstart.sql

@@dbmsxmlt.sql
@@dbmsuri.sql
@@dbmsxml.sql



@?/rdbms/admin/sqlsessend.sql
