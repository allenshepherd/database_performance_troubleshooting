Rem
Rem $Header: rdbms/admin/dbmsmp.sql /main/5 2017/05/02 14:15:38 aarvanit Exp $
Rem
Rem dbmsmp.sql
Rem
Rem Copyright (c) 2007, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsmp.sql - declaration of the DBMS_Management_Packs package
Rem
Rem    DESCRIPTION
Rem      A package for limited control of manageability features to be 
Rem      used even when diagnostic and tuning pack licenses are not available
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsmp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsmp.sql
Rem SQL_PHASE: DBMSMP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aarvanit    11/16/16 - bug #24966761: remove STS from tuning pack
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    pbelknap    03/02/07 - make package DEFINER rights/SYS-only
Rem    ushaft      01/19/07 - 
Rem    pbelknap    01/18/07 - make pack name a constant
Rem    mlfeng      01/11/07 - add awr routines
Rem    ushaft      01/03/07 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_management_packs AUTHID DEFINER
IS

-------------------------------------------------------------------------------
--                       PUBLIC CONSTANTS AND TYPES SECTION
-------------------------------------------------------------------------------

DIAGNOSTIC_PACK CONSTANT VARCHAR2(30) := 'DIAGNOSTIC';
TUNING_PACK     CONSTANT VARCHAR2(30) := 'TUNING';

-------------------------------------------------------------------------------
--                     PUBLIC PROCEDURES AND FUNCTIONS SECTION
-------------------------------------------------------------------------------

--    PROCEDURE DBMS_MANAGEMENT_PACKS.check_pack_enabled
--    PURPOSE: Check if pack license is declared to the system
--             via the system parameter "control_management_pack_license"
--    PARAMETERS:
--         PACK_NAME
--            The name of the pack (DIAGNOSTIC_PACK or TUNING_PACK)
--    NOTES: throws a user error if pack license not declared to the system.
PROCEDURE check_pack_enabled(pack_name IN varchar2);

--    FUNCTION DBMS_MANAGEMENT_PACKS.report
--    PURPOSE: Get a text report of what changes will be done to the system
--             if the "purge" procedure is called with a specific level.
--    PARAMETERS:
--         LICENSE_LEVEL
--             Any valid value for init.ora parameter 
--             "control_management_pack_access". NULL is also a valid value,
--             and it is equivalent to using the function with the current
--             value of the init.ora parameter.
--    RETURN: a clob containing a text explanation of the changes.
FUNCTION report(license_level IN varchar2) RETURN clob;

--    PROCEDURE DBMS_MANAGEMENT_PACKS.purge
--    PURPOSE: Remove/deactivate objects in the database that are inconsistent
--             with the proposed setting of the 
--             "control_management_pack_access" parameter
--    PARAMETERS:
--         LICENSE_LEVEL
--             Any valid value for init.ora parameter 
--             "control_management_pack_access". NULL is also a valid value,
--             and it is equivalent to using the function with the current
--             value of the init.ora parameter.
PROCEDURE purge(license_level IN varchar2);

--    PROCEDURE DBMS_MANAGEMENT_PACKS.modify_awr_settings
--    PURPOSE: Modify the AWR snapshot settings.
--    PARAMETERS:
--         RETENTION
--             new retention time (in minutes). The specified value 
--             must be in the range:
--               MIN_RETENTION (1 day) to 
--               MAX_RETENTION (100 years)
--
--             If ZERO is specified, snapshots will be retained forever.
--
--             If NULL is specified, the old value for retention is preserved.
--                           
--         INTERVAL
--             The interval between each snapshot, in units of minutes.
--             The specified value must be in the range:
--               MIN_INTERVAL (10 minutes) to 
--               MAX_INTERVAL (100 years)
--
--             If ZERO is specified, automatic and manual snapshots 
--             will be disabled.
--
--             If NULL is specified, the current value is preserved.
PROCEDURE modify_awr_settings(retention  IN NUMBER DEFAULT NULL,
                              interval   IN NUMBER DEFAULT NULL);

--    PROCEDURE DBMS_MANAGEMENT_PACKS.purge_awr
--    PURPOSE: Purge all AWR data from the system.
PROCEDURE purge_awr;

--    PROCEDURE DBMS_MANAGEMENT_PACKS.purge_sqlsets
--    PURPOSE: Purge SQL Tuning Sets
--
--    PARAMETERS:
--         REPORT
--             Report CLOB being built
--    RETURN: none
PROCEDURE purge_sqlsets(buffer IN OUT NOCOPY clob);

END dbms_management_packs;
/


@?/rdbms/admin/sqlsessend.sql
