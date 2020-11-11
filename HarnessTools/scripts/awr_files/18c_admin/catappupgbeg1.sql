Rem
Rem $Header: rdbms/admin/catappupgbeg1.sql /main/3 2017/09/29 14:04:55 pyam Exp $
Rem
Rem catappupgbeg1.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catappupgbeg1.sql - Begin App Upgrade
Rem
Rem    DESCRIPTION
Rem      Begins upgrade of APP$CDB$CATALOG
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catappupgbeg1.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: INSTALL
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pyam        09/27/17 - Bug 26856671: alter system with scope=memory
Rem    pyam        08/28/17 - Bug 25857770: set _enable_cdb_upgrade_capture
Rem                           only during upgrade
Rem    pyam        11/10/16 - move install into different block
Rem    pyam        05/20/15 - cdb upgrade optimizations
Rem    pyam        05/19/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

COLUMN createvsn NEW_VALUE createvsn
select version createvsn from registry$ where cid='CATPROC';

alter system set "_enable_cdb_upgrade_capture"=true scope=memory;

-- do begin/end install if necessary
alter pluggable database application APP$CDB$CATALOG begin install '&createvsn';
alter pluggable database application APP$CDB$CATALOG end install '&createvsn';

COLUMN fromvsn NEW_VALUE fromvsn
-- use nvl(max(...)) so that if it doesn't exist, we have a dummy string to
-- avoid a parse error in the alter pluggable database
select nvl(max(tgtver),'!') fromvsn from fed$versions v, fed$apps a
 where v.ver#=a.ver# and v.appid#=a.appid# and a.app_name='APP$CDB$CATALOG';

COLUMN tovsn NEW_VALUE tovsn
select (version || '.partial') tovsn from v$instance;

alter pluggable database application APP$CDB$CATALOG begin upgrade
  '&fromvsn' to '&tovsn';

@?/rdbms/admin/sqlsessend.sql

