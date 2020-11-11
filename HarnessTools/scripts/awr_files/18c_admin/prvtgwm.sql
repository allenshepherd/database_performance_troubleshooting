Rem
Rem $Header: rdbms/admin/prvtgwm.sql /main/14 2016/11/24 09:04:25 dcolello Exp $
Rem
Rem prvtgwm.sql
Rem
Rem Copyright (c) 2011, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      prvtgwm.sql - Global Workload Management
Rem
Rem    DESCRIPTION
Rem      Load package implementations for GSM that should be installed on
Rem      every database.
Rem
Rem    NOTES
Rem      
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/prvtgwm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/prvtgwm.sql
Rem SQL_PHASE: PRVTGWM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpxrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dcolello    11/19/16 - always set schema to gsmadmin_internal
Rem    dcolello    06/24/16 - bug 22151011: move triggers after body creation
Rem    dcolello    03/14/16 - Add fixed package dbmsgwmfx.sql
Rem    sdball      11/23/15 - Move prvtgwmfix.sql up
Rem    dcolello    11/20/15 - move to carxrd.sql
Rem    sdball      02/10/15 - Fix Windows SRG by removing full-paths
Rem    sdball      03/17/14 - Add fixed package body prvtgwmfix.plb
Rem    sdball      12/30/13 - temporarily revert to unwrapped SQL
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    lenovak     07/29/13 - shard support
Rem    nbenadja    02/21/13 - Add prvtgwmalt.plb.
Rem    sdball      03/12/12 - GSM catalog update
Rem    mjstewar    04/26/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- can't grant this from catgwmcat.sql since that's 
--  run prior to XDB installation.
-- can't move catgwmcat.sql after XDB installation 
--  to catxrd.sql since GSMCATUSER needs to exist
--  for registry calls to succeed in catpend.sql
-- so...do this here for now

-- So that dbms_gsm_xdb can be called from GDSCTL
grant xdbadmin to gsmadmin_role;

--************************************
-- Install GSM Package Implementations
--************************************

-- the following run in the SYS schema
@@prvtgwmfix.plb
@@prvtgwmfx.plb

-- the following run in the GSMADMIN_INTERNAL schema
--   the sub-scripts handle the move to and from 
--   the correct schema
@@prvtgwmco.plb
@@prvtgwmdb.plb
@@prvtgwmut.plb
@@prvtgwmpl.plb
@@prvtgwmcl.plb
@@prvtgwmalt.plb

-- set schema to GSMADMIN_INTERNAL for the rest of this script
ALTER SESSION SET CURRENT_SCHEMA = gsmadmin_internal;

-- CALL triggers must be created AFTER the package body (not just the spec)
--   of the package they are calling.  So, these are moved here from 
--   catgwmcat.sql.  See bug 22151011.

------------------------------------------------------------------------------
-- support for catalog rollbacks in the event of an aborted update
-- on a target database
CREATE OR REPLACE TRIGGER cat_rollback_trigger AFTER UPDATE OF status
    ON gsm_requests FOR EACH ROW WHEN (new.status = 'A') 
    CALL dbms_gsm_pooladmin.catRollback(:new.request, :new.old_instances)
/
show errors

-- support for catalog completion actions
-- NOTE: this compound trigger currently assumes that we delete only one
-- row from gsm_requests in each statement. If we delete more than one, then
-- only the last row deleted is passed to the procedure at the end of the
-- statement. If we ever want to delete more than one row, then these variables
-- should become colletcion types.
--
-- This compound trigger is necesary to avoid a mutating table
-- error when we send another AQ from the trigger (thus adding a new row
-- to gsm_requests)
CREATE OR REPLACE TRIGGER request_delete_trigger AFTER DELETE ON gsm_requests
   FOR EACH ROW CALL
   dbms_gsm_pooladmin.requestDelete(:old.change_seq#, :old.request, :old.status)
/
show errors

CREATE OR REPLACE TRIGGER done_trigger AFTER UPDATE OF status
    ON gsm_requests FOR EACH ROW WHEN (new.status = 'D')
    CALL dbms_gsm_pooladmin.requestDone(:old.request, :new.status)
/
show errors

-- This a log off trigger that checks if a GSM is logging off from the catalog.
CREATE OR REPLACE TRIGGER GSMlogoff
                   BEFORE LOGOFF  ON gsmcatuser.schema
                   CALL dbms_gsm_cloudadmin.checkGSMDown
/
show errors

ALTER SESSION SET CURRENT_SCHEMA = SYS;

@?/rdbms/admin/sqlsessend.sql
