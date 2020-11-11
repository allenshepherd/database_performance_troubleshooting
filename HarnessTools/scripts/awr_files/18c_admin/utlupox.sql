Rem
Rem $Header: rdbms/admin/utlupox.sql /main/2 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem utlupox.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlupox.sql - UTLU Populate Oracle-supplied eXternal Table
Rem
Rem    DESCRIPTION
Rem      Populates/creates flat files with oracle-supplied obj$ and user$
Rem      info for external table consumption.
Rem
Rem    NOTES
Rem      - Creates external table flat files with oracle-supplied bit info
Rem        needed for upgrades of a standalone db to 12c.
Rem      - The oracle-supplied bit info consists of : objects in obj$ and
Rem        users in user$.
Rem      - This script to be run by the install team when building the 12c
Rem        shiphome kit.  Install team to create a cdb, run this utlupox.sql
Rem        script, and then include these 2 flat files to
Rem        rdbms/admin directory.
Rem      - During upgrade process in 12c oracle home, 2 external tables will
Rem        be created using the flat files in the 12c oracle home.  And then
Rem        entries in obj$ and user$ will be updated as oracle-supplied by
Rem        referencing these 2 external tables during the upgrade process.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/utlupox.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlupox.sql 
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Add SQL_METADATA
Rem    cmlim       11/02/12 - bug 14763826: populate oracle-supplied info into
Rem                           external tables
Rem    cmlim       11/02/12 - Created
Rem


set pagesize 0 
set echo off
set head off
set feedback off


Rem ***********************************************************************
Rem 1. Populate oracle-supplied OBJects eXTernal table (info from obj$)
Rem ***********************************************************************

spool upobjxt.lst

select u.name || ',' || o.name || ',' || o.subname || ',' || o.type#  || ','
from sys.obj$ o, sys.user$ u
where o.owner# = u.user# and bitand(o.flags,4194304)=4194304
order by o.name, u.name;

spool off


Rem ***********************************************************************
Rem 2. Populate oracle-supplied USERs eXTernal table (info from usr$)
Rem ***********************************************************************

spool upuserxt.lst

select name || ','
from sys.user$
where bitand(spare1,256)=256
order by name;

spool off


