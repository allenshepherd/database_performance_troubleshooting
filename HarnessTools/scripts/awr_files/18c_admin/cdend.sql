Rem
Rem $Header: rdbms/admin/cdend.sql /main/7 2014/02/20 12:45:39 surman Exp $
Rem
Rem cdend.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdend.sql - Catalog END 
Rem
Rem    DESCRIPTION
Rem      Create views and objects that can be created near the end.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdend.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdend.sql
Rem SQL_PHASE: CDEND
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    cdilling    08/02/06 - clean up
Rem    ushaft      05/22/06 - add dbmsaddm
Rem    gssmith     06/03/06 - Move SQL Access Advisor scripts 
Rem    rburns      05/22/06 - add timestamp 
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Indicate load complete

BEGIN
   dbms_registry.loaded('CATALOG');
END;
/

SELECT dbms_registry.time_stamp('CATALOG') AS timestamp FROM DUAL;

@?/rdbms/admin/sqlsessend.sql
