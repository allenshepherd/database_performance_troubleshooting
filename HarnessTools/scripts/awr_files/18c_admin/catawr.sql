Rem
Rem $Header: rdbms/admin/catawr.sql /st_rdbms_18.0/1 2017/12/03 13:39:32 osuro Exp $
Rem
Rem catawr.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catawr.sql - Catalog script for Automatic Workload Repository
Rem                   (AWR)
Rem
Rem    DESCRIPTION
Rem      Creates tables, views, package for AWR
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem      The newly created tables should be TRUNCATE in the downgrade script.
Rem      Any new views and their synonyms should be dropped in the downgrade
Rem      script.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catawr.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catawr.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    osuro       11/28/17 - bug 27078828: Add AWR_CDB_* views
Rem    yingzhen    10/06/15 - Bug 21575534: change dba_hist view location
Rem    ardesai     12/01/14 - Add catawrrtvw and catawrpdbvw
Rem    ilistvin    01/31/08 - add prvsawri.plb
Rem    ilistvin    09/14/07 - add prv[st]awrs.plb
Rem    ilistvin    11/22/06 - changes for catproc restructuring
Rem    mlfeng      06/11/06 - package spec first 
Rem    veeve       06/04/04 - added prvtash.plb
Rem    pbelknap    11/03/03 - pbelknap_swrfnm_to_awrnm 
Rem    pbelknap    10/29/03 - change SWRF to AWR everywhere
Rem    mlfeng      01/24/03 - Remove catdbfus.sql
Rem    mlfeng      01/16/03 - Adding call to catswrvw.sql to create views
Rem    mlfeng      01/07/03 - Add script to create DB Feature Usage
Rem    mlfeng      09/26/02 - Enable WR schema creation
Rem    mlfeng      08/01/02 - updating dba_sysaux_occupant
Rem    mlfeng      07/08/02 - swrf flushing
Rem    mlfeng      06/14/02 - Adding DBA_SYSAUX_OCCUPANT view
Rem    mlfeng      06/11/02 - Created
Rem

Rem The following script will create the WR tables
@@catawrtb

Rem Create the DBMS_WORKLOAD_REPOSITORY package
@@dbmsawr

Rem The following script will create the AWR_ROOT views for the 
Rem Workload Repository
@@catawrrtvw

Rem The following script will create the AWR_PDB views for the 
Rem Workload Repository
@@catawrpdbvw

Rem The following script will create the AWR_CDB views for the 
Rem Workload Repository
@@catawrcdbvw

Rem The following script will create the DBA_HIST views for the 
Rem Workload Repository
@@catawrvw
@@catawrpd

Rem Create DBMS_ASH_INTERNAL package and package body
Rem NOTE: prvtawr uses functions in prvtash, so include prvtash first.
@@prvsash.plb
@@prvtash.plb

Rem Create DBMS_WORKLOAD_REPOSITORY package body,
Rem Create DBMS_SWRF_INTERNAL package and package body,
Rem Create DBMS_SWRF_REPORT_INTERNAL package and package body
Rem NOTE: prvtawr uses functions in prvtash, so include prvtash first.
@@prvsawr.plb
@@prvsawri.plb
@@prvsawrs.plb
@@prvtawr.plb
@@prvtawri.plb
@@prvtawrs.plb

Rem
Rem Create AWR Staging Schema
exec dbms_swrf_internal.create_staging_schema;
