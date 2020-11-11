rem 
rem $Header: rdbms/admin/catnosvm.sql /main/5 2017/05/28 22:46:03 stanaya Exp $ 
rem 
Rem  Copyright (c) 1991 by Oracle Corporation 
Rem    NAME
Rem      catnosvm.sql - Remove the objects catsvrmg.sql creates
Rem    DESCRIPTION
Rem      
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script expects to already be connected
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnosvm.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnosvm.sql
Rem    SQL_PHASE: CATNOSVM
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem     barthur    01/23/94 -  Remove the sm$security items we no longer need 
Rem     barthur    12/30/93 -  Add new views and table for improvements to secu
Rem     ameyer     10/22/93 -  Synced with catsvrmg.sql and fixed up. 
Rem     ameyer     10/12/93 -  Added sm$version. 
Rem     barthur    09/23/93 -  Add sys. to the names of views and tables 
Rem     barthur    07/30/93 -  Add drop to correspond to changes in catsvrmg.sq
Rem     barthur    05/07/93 -  Creation 

REM Drop the views and tables created by the Server Manager installation
REM script catsvrmg.sql
REM This script should be run by a user who can delete objects owned by sys
REM (Usually SYS or INTERNAL)

drop view sys.sm_$version;
drop public synonym sm$version;

drop view sys.sm$ts_avail;

drop view sys.sm$ts_used;

drop view sys.sm$ts_free;

drop view sys.sm$audit_config;

drop view sys.sm$integrity_cons;
