Rem
Rem $Header: rdbms/admin/upgrdpdbcheck.sql /main/1 2016/12/12 17:15:20 pyam Exp $
Rem
Rem upgrdpdbcheck.sql
Rem
Rem Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      upgrdpdbcheck.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/upgrdpdbcheck.sql
Rem    SQL_SHIPPED_FILE:
Rem    SQL_PHASE:
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE:
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pyam        11/25/16 - Upgrades a PDB using App Sync. First checks if
Rem                           we're in an open PDB and upgrade is not already
Rem                           complete.
Rem    pyam        11/25/16 - Created
Rem

COLUMN filename NEW_VALUE filename
-- sets filename to upgrdpdb.sql if:
--   we're in a PDB and it's open, and
--   upgrade has not already completed
select nvl(max('upgrdpdb.sql'),'nothing.sql') filename from dual where
 exists (select 1 from registry$ r, v$instance v
   where r.cid <> 'APEX' and r.version <> v.version);

@@&filename
 
