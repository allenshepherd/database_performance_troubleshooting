Rem
Rem $Header: rdbms/admin/xdbupgrdses.sql /main/2 2017/04/27 17:09:46 raeburns Exp $
Rem
Rem xdbupgrdses.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbupgrdses.sql - XDB UPGRaDe SESsion script
Rem
Rem    DESCRIPTION
Rem      This script initializes parallel processes for the XDB upgrade
Rem
Rem    NOTES
Rem      Invoked by catctl.pl in all process used for the XDB upgrade
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbupgrdses.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbupgrdses.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/cmpupgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Add SQL_METADATA
Rem    raeburns    10/13/14 - XDB upgrade session script
Rem    raeburns    10/13/14 - Created
Rem


Rem xdbupgrd.sql settings
Rem =====================================================================

set errorlogging on table sys.registry$error identifier 'XDB';


