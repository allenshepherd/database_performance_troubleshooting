Rem
Rem $Header: rdbms/admin/catptyps.sql /main/18 2015/11/04 06:36:03 raeburns Exp $
Rem
Rem catptyps.sql
Rem
Rem Copyright (c) 2006, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catptyps.sql - CATProc TYPe creation
Rem
Rem    DESCRIPTION
Rem      This script creates types and other objects needed for 
Rem      subsequent scripts
Rem
Rem    NOTES
Rem      
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catptyps.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catptyps.sql
Rem SQL_PHASE: CATPTYPS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    09/25/15 - RTI 16218614: add catrm to catptyps 
Rem                           and consolidate other scripts
Rem    bhammers    01/06/15 - add dbmsjsont.sql (json dom for pl/sql)
Rem    jiayan      07/22/14 - add prvtstattyp.sql
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    tbhukya     07/13/12 - Remove catqityp.sql
Rem    jerrede     04/18/12 - Lrg 6874389 Fix Deadlocking Issues
Rem                           when processing grants. Move grants
Rem                           to catpgrants.sql
Rem    jerrede     04/17/12 - Fix Mutex error in cattsdp.sql when creating
Rem                           table tsdp_protection$. Moved from catptabs.sql
Rem                           to catptyps.sql to serialize the operation.
Rem    jerrede     04/11/12 - Fix lrg 6888498 Deadlock in catqueue.sql when
Rem                           processing grants. Move from catptabs.sql to
Rem                           catptyps.sql to serialize the operation.
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    shjoshi     03/05/12 - load prvsautorepi instead of dbmsautorep.sql
Rem    tbhukya     12/22/11 - Add catqityp.sql
Rem    jerrede     11/04/11 - Fix dependency problem found
Rem                           with dbmsautorep.sql when fixing
Rem                           bug 13252372
Rem    shiyadav    06/12/11 - add dbmsadro - ADR objects
Rem    yxie        04/28/11 - add em express schema creation
Rem    jheng       03/14/11 - Proj 32973: add catproft for Privilege Profile
Rem    amullick    01/27/09 - Archive Provider support
Rem    kkunchit    01/15/09 - ContentAPI support
Rem    elu         10/23/06 - add replication types
Rem    rburns      05/07/06 - Public Types 
Rem    rburns      05/07/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


-- creates the ANYDATA type used by scripts in catptabs.sql
@@dbmsany.sql

Rem XMLTYPE specs
-- Manageaablity tables depend on XMLTYPE
@@catxml.sql

Rem EM Express schema, includes file manager used by 
Rem Manageability/Diagnosability Report Framework
-- Needs to run before catrept
@@catemxt.sql

Rem Manageability/Diagnosability Report Framework
-- tables and views are currently in separate scripts, so create tables here
@@catrept.sql

Rem global plan_table
@@catplan.sql

Rem Replication
@@catreplt.sql

Rem ContentAPI
@@catcapit.sql

Rem ArchiveProvider
@@catapt.sql

Rem Privilege Profile
@@catproft.sql

Rem Adr Objects
@@dbmsadro.sql

Rem Optimizer Stats
@@prvtstattyp.plb

Rem This package spec is required before creating views for 
Rem Automatic Report Capture infrastructure
-- package needed to create views for automatic report capture
@@prvsautorepi.plb

Rem TSDP Tables and Views
@@cattsdp.sql

Rem json dom for pl/sql
@@catjsont.sql

Rem
Rem GSM roles/users/grants
Rem
@@catgwm.sql
Rem
Rem rolling upgrade views
Rem
@@catrupg.sql

Rem
Rem Resource Manager Views
Rem
@@catrm.sql

Rem *********************************************************************
Rem END catptyps.sql
Rem *********************************************************************


@?/rdbms/admin/sqlsessend.sql
