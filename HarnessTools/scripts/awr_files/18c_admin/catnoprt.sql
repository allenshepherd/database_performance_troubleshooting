Rem
Rem $Header: rdbms/admin/catnoprt.sql /main/2 2017/05/28 22:46:03 stanaya Exp $
Rem
Rem catnoprt.sql
Rem
Rem Copyright (c) 1997, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnoprt.sql - CATalog NO PaRTitioning
Rem
Rem    DESCRIPTION
Rem      Drops data dictionary views for the partitioning table.
Rem
Rem    NOTES
Rem      1. This file use to be called CATNOPART.SQL.
Rem      2. This script is used to drop these views run CATPART.SQL.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnoprt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnoprt.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    achaudhr    03/10/97 - Created
Rem
drop view USER_PART_TABLES
/
drop view ALL_PART_TABLES
/
drop view DBA_PART_TABLES
/
drop view USER_PART_INDEXES
/
drop view ALL_PART_INDEXES
/
drop view DBA_PART_INDEXES
/
drop view USER_PART_KEY_COLUMNS
/
drop view ALL_PART_KEY_COLUMNS
/
drop view DBA_PART_KEY_COLUMNS
/
drop view USER_TAB_PARTITIONS
/
drop view ALL_TAB_PARTITIONS
/
drop view DBA_TAB_PARTITIONS
/
drop view USER_IND_PARTITIONS
/
drop view ALL_IND_PARTITIONS
/
drop view DBA_IND_PARTITIONS
/
drop view USER_PART_COL_STATISTICS
/
drop view ALL_PART_COL_STATISTICS
/
drop view DBA_PART_COL_STATISTICS
/
drop view USER_PART_HISTOGRAMS
/
drop view ALL_PART_HISTOGRAMS
/
drop view DBA_PART_HISTOGRAMS
/
