set echo off
Rem
Rem $Header: rdbms/admin/utlsrt.sql /main/3 2017/05/28 22:46:13 stanaya Exp $
Rem
Rem utlsrt.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlsrt.sql - Utility for Sync Refresh
Rem
Rem    DESCRIPTION
Rem      The utility script creates the SYNCREF_TABLE that is
Rem      used by the DBMS_SYNC_REFRESH.CAN_SYNCREF_TABLE() API.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utlsrt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlsrt.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    sramakri    01/27/15 - bug-20301978
Rem    sramakri    06/22/11 - SYNCREF_TABLE
Rem    sramakri    06/22/11 - Created
Rem

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

-- This table is used by the following DBMS_SYNC_REFRESH.CAN_SYNCREF_TABLE()
-- API:
--
--  PROCEDURE can_syncref_table(schema_name   IN VARCHAR2, 
--                              table_name    IN VARCHAR2, 
--                              statement_id  IN VARCHAR2);
--
-- The SYNCREF_TABLE must between created by user before using the API.
-- 
-- The can_syncref_table() procedure advises the user on whether the
-- table and its its dependent MV's are eligible for Sync Refresh. 
-- It provides an explanation of its analysis. If not eligible, 
-- the user can examine the reasons and take appropriate action if possible.
--      
-- The fields of SYNCREF_TABLE have the following significance:
--
-- statement_id   -  An identifier provided by the user to uniquely identify
--                   the results of the run. It is the user's responsibility
--                   to provide a different statement_id for each invocation.
--
-- schema_name    -  The name of the schema of the table being analyzed.
--
-- table_name     -  The name of the  table being analyzed.
--
-- mv_schema_name -  The name of the schema of an MV dependent on the 
--                   the table being analyzed.
--
-- mv_name        -  The name of the MV dependent on the the table being 
--                   analyzed. 
--
-- eligible       -  This field can have two values - 'Y' means the MV
--                   is eligible for Sync Refresh based on the check or
--                   information supplied in the message field; 'N' indicate
--                   otherwise. In order to for the MV to be eligible the 
--                   MV must pass all the criteria.
-- 
-- seq_num        -  This field is just a sequence number starting with 1
--                   for each MV. It can be used to order the rows within 
--                   each MV to undertstand the eligibility analysis.
--
-- msg_number     -  The message-number of the message. The messages
--                   belong to the QSM facility and are defined in qsmus.msg
--
-- message        -  The message describing the eligibilty check or  
--                   information pertaining to the eligibility of the 
--                   MV for Sync Refresh.     
-- 

CREATE TABLE SYNCREF_TABLE(
          statement_id         VARCHAR2(30), 
          schema_name          VARCHAR2(128),
          table_name           VARCHAR2(128), 
          mv_schema_name       VARCHAR2(128),
          mv_name              VARCHAR2(128),
          eligible             VARCHAR2(1), 
          seq_num              NUMBER,
          msg_number           NUMBER,
          message              VARCHAR2(4000));
