Rem
Rem $Header: rdbms/admin/dbmsscnc.sql /main/2 2014/02/20 12:45:55 surman Exp $
Rem
Rem dbmsscn.sql
Rem
Rem Copyright (c) 2012, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsscnc.sql - dbms_scn package definition
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsscnc.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsscnc.sql
Rem SQL_PHASE: DBMSSCNC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    mtiwary     05/26/12 - Declarations and definitions related to DBMS_SCN
Rem                           package.
Rem    mtiwary     05/26/12 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE LIBRARY DBMS_SCN_LIB TRUSTED AS STATIC;
/

CREATE OR REPLACE PACKAGE DBMS_SCN AUTHID CURRENT_USER IS

DBMS_SCN_API_MAJOR_VERSION  CONSTANT NUMBER := 1; 
DBMS_SCN_API_MINOR_VERSION  CONSTANT NUMBER := 0;

PROCEDURE GetCurrentSCNParams(
                rsl      OUT number,
                headroom_in_scn OUT number,
                headroom_in_sec OUT number,
                cur_scn_compat OUT number,
                max_scn_compat OUT number);

--      Currently no exceptions are thrown.
--      rsl             - Reasonable SCN Limit as of 'now'
--      headroom_in_scn - Difference between current SCN and RSL
--      headroom_in_sec - number of seconds it would take to reach RSL
--                        assuming a constant SCN consumption rate associated
--                        with current SCN compatibility level
--      cur_scn_compat  - current value of SCN compatibility
--      max_scn_compat  - max value of SCN compatibility this database
--                        understands

FUNCTION GetSCNParamsByCompat(
                compat IN number,
                rsl           OUT number,
                headroom_in_scn OUT number,
                headroom_in_sec OUT number
         ) RETURN boolean;

--     compat           -- SCN compatibility value
--     rsl              -- Reasonable SCN Limit
--     headroom_in_scn  -- Difference between current SCN and RSL
--     headroom_in_sec  -- number of seconds it would take to reach RSL
--                         assuming a constant SCN consumption rate associated
--                         with specified database SCN compatibility
--
--     Returns False if 'compat' parameter value is invalid, and OUT parameters
--     are not updated.

PROCEDURE GetSCNAutoRolloverParams(
                effective_auto_rollover_ts OUT DATE,
                target_compat OUT number,
                is_enabled OUT boolean);

--      effective_auto_rollover_ts  - timestamp at which rollover becomes
--                                    effective
--      target_compat               - SCN compatibility value this database
--                                    will move to, as a result of
--                                    auto-rollover
--      is_enabled                  - TRUE if auto-rollover feature is
--                                    currently enabled

PROCEDURE EnableAutoRollover;

PROCEDURE DisableAutoRollover;

END DBMS_SCN;
/


@?/rdbms/admin/sqlsessend.sql
