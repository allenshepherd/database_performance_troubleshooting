Rem
Rem $Header: rdbms/admin/catpspec.sql /main/19 2017/05/16 11:24:47 yuyzhang Exp $
Rem
Rem catpspec.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpspec.sql - CATPROC Package Specs
Rem
Rem    DESCRIPTION
Rem      Single-threaded script to create package specifications that are 
Rem      referenced in other package specs (in catpdbms.sql)
Rem
Rem    NOTES
Rem       
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catpspec.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catpspec.sql
Rem SQL_PHASE: CATPSPEC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yuyzhang    04/17/17 - proj# 54799: move prvtstas.plb from catpdbms
Rem    aarvanit    03/16/17 - bug #24966761: add dbmssqlt.sql
Rem    sdavidso    01/26/17 - bug25225293 have catmettypes.sql execute before
Rem                           dbmsmeta.sql
Rem    osuro       11/07/16 - bug 24674921: move catawrtv.sql to catpspect.sql
Rem    jjye        08/04/16 - bug 21571874: MV uses dbms_scheduler 
Rem    atomar      09/01/15 - bug 20803176,cataqjms,cataqalt121
Rem    jiayan      07/22/14 - switch calls to dbmsstat and prvtstas 
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    elu         02/21/13 - move dbmsobj.sql to catpspec.sql
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    arbalakr    01/18/12 - add prvs_awr_data.sql
Rem    bdagevil    12/10/11 - move dbmsrep.sql in since prvsemx_admin depends
Rem                           on it
Rem    jerrede     10/06/11 - Fix lrg 5829047 Dependency Warning Errors
Rem    skabraha    09/27/11 - move urlrcmp chere
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    hosu        07/18/11 - move prvtstas.sql from catpdbms to catpsepc
Rem    yiru        07/08/11 - Add triton security package: xsprin.sql,
Rem                           prvtprin.plb, move prvtkzrxu.plb to catpprvt.sql
Rem    yiru        10/20/09 - Add triton security package: xsadmi.sql
Rem    yiru        08/17/09 - Add triton security packages: xsutil.sql, 
Rem                           prvtkzrxh.plb, prvtkzrxu.plb
Rem    ilistvin    11/15/06 - create specs for packages used by other pakage
Rem                           specs
Rem    ilistvin    11/15/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Metadata API type defs for object view of dictionary
Rem   (after catnomtt.sql(catptabs.sql), before dbmsmeta.sql(catpdbms.sql))
@@catmettypes.sql

Rem
Rem create AWR schema
Rem
@@catawrtv.sql

Rem advisor framework
@@dbmsadv.sql
@@dbmsasrt.sql
@@prvtasrt.plb

Rem pl/sql packages used for rdbms functionality
@@catodci.sql

Rem AQ jms type creation
@@cataqjms.sql

Rem AQ alter types in 12.2
@@cataqalt121.sql

Rem Scheduler dependent views
Rem Scheduler packages - depend on ODCI
@@dbmssch.sql
@@catschv.sql
@@prvthsch.plb
REM bug 21571874 MV is using dba_scheduler_jobs view 
@@catsnap.sql 

Rem Triton security packages
@@xsadmi.sql
@@xsutil.sql
@@xsprin.sql
@@prvtkzrxh.plb
@@prvtprin.plb

Rem DBMS_STATS (dbmsstat uses types created in prvtstas)
@@dbmsstat.sql
Rem prvtstataggs uses types created in prvtstas
@@prvtstas.plb

Rem utl_recomp package
@@utlrcmp.sql

Rem Create dbms_sqltune_utilx package specifications
Rem for sqltune and sqlpi advisors
@@dbmssqlu.sql

Rem
Rem SQL Tuning Package specification
Rem
@@dbmssqlt.sql

Rem Manageability/Diagnosability Report Framework
@@dbmsrep

Rem Compare Period type definitions
@@prvs_awr_data.plb

Rem
Rem general objects utilities
Rem
@@dbmsobj.sql

@?/rdbms/admin/sqlsessend.sql
