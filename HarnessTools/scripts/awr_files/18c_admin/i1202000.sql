Rem
Rem i1202000.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      i1202000.sql - load specific tables that are needed to
Rem                     process basic DDL statements
Rem
Rem    DESCRIPTION
Rem      This script MUST be one of the first things called from the
Rem      top-level upgrade script.
Rem
Rem      Only put statements in here that must be run in order
Rem      to process basic SQL commands.  For example, in order to
Rem      drop a package, the server code may depend on new tables.
Rem      Another example: in order to alter a table, the server code
Rem      needs to perform an update of the radm_mc$ dictionary table.
Rem      If these tables do not exist, a recursive SQL error will occur,
Rem      causing the command to be aborted.
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: upgrade from 12.2 to the current release
Rem        STAGE 2: invoke script for subsequent release
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/i1202000.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/i1202000.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupstr.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED (MM/DD/YY)
Rem    rdecker   10/13/17 - bug 26894033: utlip in 18 = all units recompiled
Rem    rdecker   07/07/17 - Bug 25872389: Add new PL/Scope objects/columns
Rem    rdecker   02/22/17 - ER 24622590: Enhance PL/Scope
Rem    rdecker   02/01/17 - Bug 5910872: Reduce the size of argument$
Rem    raeburns  03/09/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    schakkap  01/09/17 - lrg 19868839: fix spare6 column of tab_stats$
Rem    wanma     01/05/17 - RTI 19972666:delete obsolete objn from dependency$ 
Rem    welin     06/03/16 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: upgrade from 12.2 to the current release
Rem =========================================================================

Rem =====================================================================
Rem Start Bug 5910872 changes
Rem =====================================================================

Rem Add the new column to argument$
alter table argument$ add (type_type# number);

Rem =====================================================================
Rem End Bug 5910872 changes
Rem =====================================================================

Rem lrg 19868839: fix spare6 column of tab_stats$
alter table tab_stats$ modify (spare6 timestamp with time zone);

Rem Bug 24826690: Delete fixed objects after rename 'segdict' to 'globaldcit'.
delete from dependency$ where p_obj# in 
(4294953856,4294953857,4294953859,4294953860,4294953862,4294953863,4294953865,
 4294953866);
commit;

Rem *************************************************************************
Rem Begin PL/Scope ER 24622590 and bug 25872389
Rem *************************************************************************
alter table plscope_action$ add (flags number, exp1 number, exp2 number, 
                                 decl_obj# number)
/

Rem Create some new indexes to help with dictionary table operations
create index i_plscope_flags_action$ on plscope_action$(obj#,decl_obj#,flags)
tablespace sysaux
/
create index i_plscope_decl_action$ on plscope_action$(obj#,decl_obj#)
tablespace sysaux
/

Rem *************************************************************************
Rem End PL/Scope ER 24622590
Rem *************************************************************************

---------- ADD UPGRADE ACTIONS ABOVE THIS LINE ---------------

Rem =========================================================================
Rem END STAGE 1: upgrade from 12.2 to the current release
Rem =========================================================================


Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

-- @@ixxxxxxx.sql

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END i1202000.sql
Rem *************************************************************************

