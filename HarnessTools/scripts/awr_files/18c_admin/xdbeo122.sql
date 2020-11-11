Rem
Rem $Header: rdbms/admin/xdbeo122.sql /main/10 2017/09/14 20:57:38 sriksure Exp $
Rem
Rem xdbeo122.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbeo122.sql - XDB RDBMS Object downgrade to 12.2.0 
Rem
Rem    DESCRIPTION
Rem      This script downgrades the XDB base RDBMS objects to 12.2.0 
Rem
Rem    NOTES
Rem      The script is invoked from xdbe122.sql and from xdbeo121.sql
Rem      of the prior release. 
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbeo122.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbeo122.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/xdbdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sriksure    09/07/17 - Bug 26769325: Drop SODA objects
Rem    prthiaga    07/06/17 - Bug 26403429: Comment SODA_OPERATION_T
Rem    prthiaga    04/20/17 - Bug 25927228: Drop SODA_CollName_List_T
Rem    prthiaga    03/28/17 - Bug 25713769: Drop Soda_Operation_T
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    prthiaga    02/21/17 - Bug 25577443: Drop SODA PL/SQL libraries
Rem    prthiaga    01/31/17 - Bug 25477695: Drop SODA PL/SQL stuff
Rem    yinlu       01/20/17 - bug 25248104: drop SYSDGAGGIMP and SYS_DGAGG
Rem    yinlu       12/05/16 - bug 24965187: drop json_dataguide_fields views
Rem    qyu         11/10/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem ================================================================
Rem BEGIN XDB Object downgrade to 13.1.0
Rem ================================================================

-- uncomment for next release
--@@xdbeo131.sql

Rem ================================================================
Rem END XDB Object downgrade to 13.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Object downgrade to 12.2.0
Rem ================================================================

-- drop dataguide views json_dataguide_fields
drop public synonym ALL_JSON_DATAGUIDE_FIELDS;
drop public synonym USER_JSON_DATAGUIDE_FIELDS;
drop public synonym CDB_JSON_DATAGUIDE_FIELDS;
drop public synonym DBA_JSON_DATAGUIDE_FIELDS;
drop view ALL_JSON_DATAGUIDE_FIELDS;
drop view USER_JSON_DATAGUIDE_FIELDS;
drop view CDB_JSON_DATAGUIDE_FIELDS;
drop view DBA_JSON_DATAGUIDE_FIELDS;
drop view INT$DBA_JSON_DG_COLS;
drop function dg$getFlatDg;
drop type dg$rowset;
drop type dg$row;

-- bug 25248104: drop sys_dgagg aggregate functions
drop public synonym SYS_DGAGG;
drop public synonym SYS_HIERDGAGG;
drop function SYS_DGAGG;
drop function SYS_HIERDGAGG;
drop type SysDgAggImp;
drop type SysHierDgAggImp;

-----------------------------------------------
-- BEGIN SODA Objects Downgrade
-----------------------------------------------
-- Drop SODA Synonyms
DROP PUBLIC SYNONYM DBMS_SODA;
DROP PUBLIC SYNONYM SODA_Collection_T;
DROP PUBLIC SYNONYM SODA_Document_T;
DROP PUBLIC SYNONYM SODA_Operation_T;
DROP PUBLIC SYNONYM SODA_Cursor_T;
DROP PUBLIC SYNONYM SODA_CollName_List_T;
DROP PUBLIC SYNONYM SODA_Document_List_T;
DROP PUBLIC SYNONYM SODA_Key_List_T;

-- Drop SODA Packages and Types
DROP PACKAGE SYS.DBMS_SODA;
DROP TYPE SYS.SODA_CollName_List_T;
DROP TYPE SYS.SODA_Collection_T;
DROP TYPE SYS.SODA_Operation_T;
DROP TYPE SYS.SODA_Document_List_T;
DROP TYPE SYS.SODA_Key_List_T;
DROP TYPE SYS.SODA_Cursor_T;
DROP TYPE SYS.SODA_Document_T;

-- Drop SODA Libraries
DROP LIBRARY SYS.DBMS_SODA_LIB;
DROP LIBRARY SYS.DBMS_SODACOLL_LIB;
DROP LIBRARY SYS.DBMS_SODAOPR_LIB;
DROP LIBRARY SYS.DBMS_SODACUR_LIB;
DROP LIBRARY SYS.DBMS_SODADOC_LIB;

-----------------------------------------------
-- END SODA Objects Downgrade
-----------------------------------------------

Rem ================================================================
Rem END XDB Object downgrade to 12.2.0
Rem ================================================================

@?/rdbms/admin/sqlsessend.sql
 
