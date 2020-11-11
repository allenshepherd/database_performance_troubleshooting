Rem
Rem $Header: rdbms/admin/catnofus.sql /main/3 2017/05/28 22:46:02 stanaya Exp $
Rem
Rem catnofus.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnofus.sql - Drop Catalog File for DB Feature Usage 
Rem
Rem    DESCRIPTION
Rem      This file drops the schema objects for DB Feature Usage.
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnofus.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnofus.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfeng      05/04/05 - add tables 
Rem    aime        04/25/03 - aime_going_to_main
Rem    mlfeng      01/13/03 - DB Feature Usage
Rem    mlfeng      10/30/02 - Created
Rem

drop table WRI$_DBU_USAGE_SAMPLE
/
drop table WRI$_DBU_FEATURE_USAGE 
/
drop table WRI$_DBU_FEATURE_METADATA
/
drop table WRI$_DBU_HIGH_WATER_MARK
/
drop table WRI$_DBU_HWM_METADATA
/
drop table WRI$_DBU_CPU_USAGE_SAMPLE
/
drop table WRI$_DBU_CPU_USAGE
/
