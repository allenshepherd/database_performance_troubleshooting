Rem
Rem
Rem catpcnfg.sql
Rem
Rem Copyright (c) 2006, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpcnfg.sql - CATPROC CoNFiGuration
Rem
Rem    DESCRIPTION
Rem      This script runs required configuration scripts to set up
Rem      scheduler and other required objects
Rem
Rem    NOTES
Rem      The script is run by catproc.sql as a single process script
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catpcnfg.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catpcnfg.sql
Rem SQL_PHASE: CATPCNFG
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sramakri    06/09/16 - remove CDC from 12.2
Rem    molagapp    01/14/15 - Project 47808 - Restore from preplugin backup
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    banand      08/23/12 - add remove dbmsrspreq.plb 
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    banand      06/23/11 - add dbmsrspreq.plb for Recovery Server schema
Rem    ilistvin    11/13/06 - add catmwin.sql
Rem    jinwu       11/02/06 - move catstr.sql and catpstr.sql
Rem    elu         10/23/06 - catrep restructure
Rem    rburns      08/25/06 - move prvtsnap
Rem    rburns      07/27/06 - configuration scripts 
Rem    rburns      07/27/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Resource Manager
@@execrm.sql

Rem Scheduler objects
@@execsch.sql

-- Scheduler calls to AQ packages
@@catscqa.sql

-- Svrman calls to AQ and Scheduler
@@catmwin.sql

Rem on-disk versions of rman support
-- dependent on streams
@@catpplb.sql
@@prvtrmns.plb
@@prvtbkrs.plb
@@prvtpplb.plb

@?/rdbms/admin/sqlsessend.sql
