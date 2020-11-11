Rem
Rem $Header: rdbms/admin/odme111.sql /main/2 2017/05/28 22:46:07 stanaya Exp $
Rem
Rem odme111.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      odme111.sql - Data Mining 11.2 downgrade script
Rem
Rem    DESCRIPTION
Rem      This script to be run as part of rdbms downgrade from 11.2 
Rem      to 11.1 release
Rem
Rem    NOTES
Rem      This script must be run as SYS.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/odme111.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/odme111.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    xbarr       02/04/09 - Created
Rem
Rem
ALTER SESSION SET CURRENT_SCHEMA = "SYS";

exec sys.dbms_registry.downgrading('ODM');

update sys.registry$ set vproc='NULL' where cid='ODM' and cname='Oracle Data Mining';

exec sys.dbms_registry.downgraded('ODM','11.1.0');
/

commit;


