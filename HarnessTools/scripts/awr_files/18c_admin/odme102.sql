Rem
Rem $Header: rdbms/admin/odme102.sql /main/8 2017/05/28 22:46:07 stanaya Exp $
Rem
Rem odme102.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      odme102.sql - Data mining 11g to 10.2 downgrade script 
Rem
Rem    DESCRIPTION
Rem      This script is to be run as part of rdbms 11g to 10.2 
Rem      component downgrade process
Rem
Rem    NOTES
Rem      Script to be run as SYS
Rem
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/odme102.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/odme102.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    amozes      10/11/10 - lrg 4889314: add component downgrade from 12
Rem    xbarr       02/04/09 - add odm111 call
Rem    xbarr       04/25/07 - remove 'valid' call
Rem    xbarr       01/11/07 - add odm downgrade calls in registry
Rem    xbarr       03/09/06 - Created
Rem
Rem
Rem  Invoke 11.2 to 11.1 downgrade script
Rem  ====================================
Rem 
@@odme111.sql

Rem   Downgrade PL/SQL API 11.1 mining models to 10.2
Rem   ================================================
Rem
exec sys.dbms_registry.downgrading('ODM');

update sys.registry$ set vproc='VALIDATE_ODM' where cid='ODM' and cname='Oracle Data Mining';

exec dmp_sys.downgrade_models('12.0.0');
/
exec dmp_sys.downgrade_models('11.0.0');
/

exec sys.dbms_registry.downgraded('ODM','10.2.0');
/

commit;

