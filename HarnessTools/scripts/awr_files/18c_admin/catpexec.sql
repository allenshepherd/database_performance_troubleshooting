Rem
Rem $Header: rdbms/admin/catpexec.sql /main/39 2017/05/26 05:12:29 raeburns Exp $
Rem
Rem catpexec.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpexec.sql - CATProc EXECute pl/sql blocks
Rem
Rem    DESCRIPTION
Rem      This script runs after all package and type bodies have been loaded
Rem      and created objects using the packages and types.
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql.
Rem      It can be run with catctl.pl as a multiprocess phase.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catpexec.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catpexec.sql
Rem SQL_PHASE: CATPEXEC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem SQL_DRIVER_ONLY: YES
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    05/14/17 - Bug 25906282: Use SQL_DRIVER_ONLY
Rem    sursridh    12/23/16 - Add support for pdb events notification.
Rem    shvmalik    11/25/16 - #25035608: revert back FCP txn
Rem    jlingow     07/01/16 - calling execschlb scheduler load balancing
Rem    shvmalik    06/30/16 - #23721669: add execfcp.sql
Rem    jftorres    02/17/15 - proj 45826: add execsmb.sql
Rem    jlingow     09/08/14 - proj-58146 Exec actions for remote scheduler
Rem                           agent.
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jstraub     01/14/13 - XbranchMerge jstraub_lrg-8743190 from
Rem                           st_rdbms_12.1.0.1
Rem    jstraub     01/09/13 - remove catapex.sql
Rem    surman      12/10/12 - XbranchMerge surman_bug-12876907 from main
Rem    surman      11/14/12 - 12876907: Add ORACLE_SCRIPT
Rem    jerrede     10/04/12 - Fix Deadlock issue in catdph.sql when alter
Rem                           package dbms_metadata_util command was issued
Rem                           Moved to serial phase
Rem    nbenadja    06/21/12 - Move catgwmcat.sql and prvtgwm.cat to catpend.sql
Rem    rpang       03/28/12 - lrg 6858789: remove execnacl.sql
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    sdball      03/23/12 - Add GSM catalog and procedures
Rem    rpang       02/13/12 - Network ACL triton migration
Rem    dgraj       10/13/11 - Project 32079: Add script for TSDP
Rem    jerrede     12/13/11 - Add Comments for Parallel Upgrade
Rem    jerrede     10/13/11 - Parallel Upgrade ntt Changes
Rem    jerrede     09/08/11 - Parallel Upgrade Project #23496 change file
Rem                           names for catmeta files.
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    xbarr       06/01/11 - remove prvtdmj
Rem    yxie        03/06/11 - em express catalog scripts
Rem    jstraub     03/15/11 - add catapex.sql
Rem    rburns      01/06/07 - final catproc cleanup
Rem    ilistvin    11/10/06 - move execsqlt.sql to execsvrm.sql
Rem    rburns      09/16/06 - split catsvrm.sql
Rem    jinwu       11/13/06 - add execstr.sql (Streams)
Rem    elu         10/23/06 - add replication files
Rem    arogers     10/23/06 - 5572026 - call execsvr.sql
Rem    rburns      08/23/06 - more restructuring
Rem    rburns      08/13/06 - more restructuring
Rem    jsoule      07/18/06 - add bsln job creation 
Rem    dkapoor     05/23/06 - OCM integration 
Rem    nlewis      06/06/06 - secure configuration changes 
Rem    kneel       06/01/06 - add exechae.sql 
Rem    pbelknap    05/26/06 - add execsqlt 
Rem    rburns      05/19/06 - add queue files 
Rem    rburns      01/13/06 - split catproc for parallel upgrade 
Rem    rburns      01/13/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


Rem **********************************************************************
Rem 
Rem  NOTE: SQL CODE NOT PERMITTED IN THIS FILE ONLY THE EXECUTION OF A
Rem       .SQL or .PLB file.
Rem
Rem **********************************************************************

Rem
Rem Catmeta Grants
Rem
@@catmetgrant2.sql

Rem
Rem EM Express and report framework registration
Rem
@@execemx.sql

Rem
Rem Component Registry initialization
Rem
@@execcr.sql

Rem
Rem Heterogeneous Services:  Gateways and external procedures
Rem
@@caths.sql

Rem
Rem emon based failure detection queues
Rem
@@catemini.sql

Rem
Rem AQ grants and queue creations
Rem
@@execaq.sql

Rem
Rem Server Manageablity
Rem
@@execsvrm.sql

Rem
Rem HA Events (FAN alerts)
Rem
@@exechae.sql

Rem
Rem Secure configuration settings
Rem
@@execsec.sql

Rem
Rem BSLN automatic stats maintenance job
Rem
@@execbsln.sql

Rem
Rem oracle_loader and oracle_datapump for external tables
Rem
@@dbmspump.sql

Rem
Rem OLAP Services
Rem
@@olappl.sql

Rem
Rem Replication
Rem
@@execrep.sql

Rem
Rem GSM Catalogs

--CATCTL -R
--CATCTL -M
Rem
Rem Streams
Rem
@@execstr.sql

Rem
Rem Kernel Service Workgroup Services
Rem
@@execsvr.sql

Rem
Rem Stats
Rem
@@execstat.sql

Rem
Rem SMB
Rem
@@execsmb.sql

Rem
Rem SNMP catalog objects  
Rem must be after dbmsdrs, catsvrm.sql, catalrt.sql
Rem
@@catsnmp.sql

Rem
Rem describe utility (used by mod_plsql)
Rem
@@wpiutil.sql

Rem
Rem embedded plsql gateway/owa packages
Rem
@@owainst.sql

Rem
Rem Initialization for ILM
Rem
@@catilmini.sql

Rem
Rem OCM integration
Rem
@@execocm.sql

Rem
Rem TSDP
Rem
@@exectsdp.sql

Rem Queryable patch inventory
@@execqopi.sql

--CATCTL -R
--CATCTL -M
Rem proj-58146
Rem Execute actions for the remote scheduler agent
@@execrsa.plb

Rem
Rem Scheduler Load Balancing
Rem
@@execschlb.plb

Rem
Rem PDB related code
Rem
@@execpdb.sql

Rem *********************************************************************
Rem END catpexec.sql
Rem *********************************************************************

@?/rdbms/admin/sqlsessend.sql
