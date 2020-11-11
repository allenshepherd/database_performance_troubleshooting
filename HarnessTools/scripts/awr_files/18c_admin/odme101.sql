Rem ##########################################################################
Rem 
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      odme101.sql
Rem
Rem    DESCRIPTION
Rem      Run all sql scripts for Data Mining Downgrade from 10gR2 to 10gR1 
Rem
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected as SYS   
Rem
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/odme101.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/odme101.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem       xbarr    06/27/07 - fix bug#6160179
Rem       xbarr    02/02/05 - remove dbms_dm_exp_internal 
Rem       xbarr    12/01/04 - remove dmsys prefix 
Rem       xbarr    10/29/04 - add validation proc 
Rem       xbarr    08/03/04 - update for downgrade 
Rem       xbarr    07/28/04 - fix lrg 1726228 
Rem       xbarr    06/25/04 - xbarr_dm_rdbms_migration
Rem       xbarr    06/24/04 - update registry 
Rem       amozes   06/23/04 - remove hard tabs
Rem       xbarr    06/07/04 - fix schema name
Rem       xbarr    05/13/04 - xbarr_txn111447
Rem       xbarr    05/12/04 - creation
Rem
Rem #########################################################################

ALTER SESSION SET CURRENT_SCHEMA = "SYS";

execute dbms_registry.downgrading('ODM');

ALTER SESSION SET CURRENT_SCHEMA = "DMSYS";

Rem Remove DM metadata resided in DMSYS after downgrade
Rem
Rem remove 10.2 JDM package
Rem
drop package dbms_jdm_internal; 

Rem remove 10.2 predictive analytics package
Rem
drop package dbms_predictive_analytics; 

Rem remove 10.2 internal EXP package
Rem
drop package dbms_dm_exp_internal;

grant execute on dmsys.dm_modelname_list to public;

ALTER SESSION SET CURRENT_SCHEMA = "SYS";

Rem downgrade ODM from 11gR1 to 10gR1 (must run as SYS)
Rem

Rem First run 11gR1 to 10gR2 downgrade
@@odme102.sql

Rem Run model downgrade to 10.1.0
exec dmp_sys.downgrade_models('10.2.0') 

execute sys.dbms_registry.downgraded('ODM','10.1.0');

commit;
