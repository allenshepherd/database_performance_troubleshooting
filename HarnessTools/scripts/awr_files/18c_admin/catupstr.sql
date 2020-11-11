Rem
Rem $Header: rdbms/admin/catupstr.sql /main/120 2017/10/10 12:10:25 raeburns Exp $
Rem
Rem catupstr.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catupstr.sql - CATalog UPgrade STaRt script
Rem
Rem    DESCRIPTION
Rem      This script performs the initial checks for upgrade
Rem      (open for UPGRADE, AS SYSDBA, etc.) and then runs
Rem      the "i" scripts, utlip.sql, and the "c" scripts
Rem      to complete the basic RDBMS upgrade
Rem
Rem    NOTES
Rem      Invoked from catupgrd.sql
Rem
Rem     *WARNING*   *WARNING*  *WARNING*  *WARNING*  *WARNING*  *WARNING*
Rem
Rem      set serveroutput must be set to off before
Rem      invoking utlip.sql script otherwise deadlocks
Rem      and internal errors may result.
Rem
Rem     *WARNING*   *WARNING*  *WARNING*  *WARNING*  *WARNING*  *WARNING*
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catupstr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catupstr.sql
Rem SQL_PHASE: UPGRADE 
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    09/18/17 - Bug 26815460: Check version_full value
Rem    rtattuku    06/22/17 - version change from cdilling
Rem    jaeblee     06/19/17 - Bug 25947201: pseudo-boostrap before c scripts
Rem    raeburns    04/07/17 - Version Change to 18.0.0; use 7 chars for
Rem                           compares since QU number can be > 10
Rem    stanaya     Fixing Bug : bug-25580596 : Add SQL Metadata
Rem    raeburns    01/04/17 - Bug 25262869: Add NOCYCLE to CONNECT BY query
Rem                           and improve query 
Rem    pyam        12/02/16 - 70732: add application begin upgrade
Rem    welin       09/27/16 - version check for 12.2.0; support upgrades 
Rem                           to 12.2.0.2
Rem    amunnoli    09/26/16 - Bug 24741114: Do not abort upgrade if AUD$UNIFIED
Rem                           table partitions are not oracle maintained
Rem    rburns      08/16/16 - Bug 24709706: Use version constants from
Rem                           dbms_registry.basic.sql
Rem    cdilling    07/19/16 - Change rdbms version to 12.2.0.2
Rem    amunnoli    05/11/16 - Bug 23221566: Abort upgrade if audit tables are
Rem                           in encrypted tablespace and wallet is not open
Rem    frealvar    03/25/16 - Bug 22695570 Removing references to deprecated
Rem                           packages and constants
Rem    yanchuan    03/06/16 - Bug 20505982: Remove the pre-upgrade check that
Rem                           Database Vault is disabled
Rem    cmlim       03/03/16 - bug 22751232: do not check invalid table data if
Rem                           this is a db rerun; NONUPGRADED_TABLEDATA check
Rem    raeburns    02/03/16 - Bug 22322252: new INVALID_TABLEDATA query/fixup
Rem    welin       01/14/16 - Bug 22543613: REMOTE_LOGIN_PASSWORDFILE=SHARED
Rem                           should not abort upgrade
Rem    frealvar    12/08/15 - Bug 21156050 invalid sys default tablespace
Rem    ssonawan    11/17/15 - Bug 21289647: Add pre-Upgrade check for REMOTE_
Rem                           LOGIN_PASSWORDFILE
Rem    svaziran    08/25/15 - bug 21548817: check for application_trace_viewer
Rem    amunnoli    08/20/15 - Bug 21655904: Check for Oracle maintained bit
Rem                           for AUDSYS.AUD$UNIFIED table 
Rem    amunnoli    07/30/15 - Bug 21370344:Upgrade check for AUD$UNIFIED table
Rem    yanlili     06/23/15 - Fix bug 20897609: Upgrade check for XS_CONNECT
Rem                           role
Rem    namoham     05/12/15 - Bug 16570807: Include a filter to check default
Rem                           DV role conflicts
Rem    hvieyra     05/11/15 - Auto Upgrade resume functionality - Bug fix 20688203
Rem    ewittenb    04/29/15 - fix timezone
Rem    bnnguyen    04/11/15 - bug 20860190: Rename 'EXADIRECT' to 'DBSFWUSER'
Rem    jorgrive    04/07/15 - upgrade check for GGSYS/GGSYS_ROLE
Rem    raeburns    03/16/15 - Bug 20446846: cleanup versions no longer 
Rem                         - supported for upgrade/downgrade
Rem    jerrede     11/05/14 - Remove loading of prvtcrs.plb and
Rem                           dbmscrs.sql.  Already loaded in cdstrt.sql
Rem                           after standard is loaded.
Rem    bnnguyen    10/29/14 - bug 19697038: upgrade check for EXADIRECT USER/
Rem                           ROLE 
Rem    cmlim       10/20/14 - bug 19805359: grant all privileges to sys in db
Rem                           upgrades
Rem    cmlim       10/19/14 - lrg 13418229: latest time zone file version is 23
Rem    cmlim       10/10/14 - bug 19688078: fix 32K_MIGRATION_NOT_COMPLETED
Rem                           check to not return ORA-1427 if executed in root
Rem    jlingow     09/11/14 - proj-58146 adding oracle provided user
Rem                           remote_scheduler_agent
Rem    spapadom    08/18/14 - Added checks for SYS$UMF and SYSUMF_ROLE.
Rem    cmlim       07/07/14 - lrg 12281386: 12.2 is now at time zone file
Rem                           version 22
Rem    sanbhara    04/25/14 - Project 46816 - adding support for SYSRAC.
Rem    sagrawal    04/21/14 - Polymorphic Table Functions
Rem    cmlim       04/25/14 - bug 18555439: if this is a non-cdb, seed, or pdb,
Rem                           then terminate upgrade if MAX_STRING_SIZE=EXTENDED
Rem                           but utl32k.sql had not completed yet
Rem    cmlim       04/15/14 - bug 18589266: to see if new users/roles were
Rem                           created in 12c, check oracle-supplied bit
Rem    cdilling    03/13/14 - version to 12.2
Rem    jaeblee     02/21/14 - 18056941: for CDB, run i1201000.sql instead of 
Rem                           i1002000.sql
Rem    cmlim       11/26/13 - lrg 10260355: latest time zone file version for
Rem                           12102 is 21
Rem    jerrede     11/14/13 - Add summary table for DBUA
Rem    jerrede     11/12/13 - Add DBUA Summary Table.
Rem    cechen      10/17/13 - Bug 16561577: handle GDS users and roles
Rem    kyagoub     09/12/13 - bug16561082: handle EM_EXPRESS_ALL and
Rem                           EM_EXPRESS_BASIC
Rem    cdilling    09/07/13 - Bug 17404281: make sys.enabled$indexes a local table
Rem    cmlim       07/05/13 - lrg 8816946: update time zone file version to 20
                              in 12.1.0.2 in 'time zone check 3' below.
Rem    cdilling    05/12/13 - check version is 12.2
Rem    cdilling    04/03/13 - only run ultip for major release upgrades, not
Rem                           patch upgrades
Rem    jibyun      03/28/13 - Bug 16567861: throw an error if the following
Rem                           users/roles already exist: SYSBACKUP, SYSDG,
Rem                           SYSKM, capture_admin 
Rem    yiru        03/28/13 - Bug 16561033: Add query to check the existence
Rem                           of RAS reserved roles
Rem    vpriyans    03/26/13 - Bug 16552266: modify query to check the existence
Rem                           of audit admins
Rem    cmlim       03/01/13 - XbranchMerge cmlim_bug-16085743 from
Rem                           st_rdbms_12.1.0.1
Rem    aramappa    02/19/13 - bug 16317592 - Remove PREUPG_AUD$ check
Rem    jerrede     02/04/13 - Upgrade Support for CDB
Rem    cdilling    01/17/13 - version to 12.1.0.2
Rem    cmlim       01/09/13 - comment: fix INVALID_TABLEDATA error in old OH
Rem    bmccarth    12/05/12 - check for invalid table data - 7174392
Rem                         - remove unsupported prior version checks
Rem                         - Fix use of dual
Rem    jerrede     11/08/12 - Make sure set serverouput is off Lrg 8473773
Rem    brwolf      10/22/12 - enable editioning for public synonyms
Rem    cmlim       10/16/12 - "_ORACLE_SCRIPT"=true set is missing at begin of
Rem                           catupstr.sql
Rem    amunnoli    10/05/12 - Bug 14727837:Fix AUDSYS query to work 
Rem                           for non-english locale
Rem    amunnoli    09/14/12 - Bug 14560783:Throw error on upgrade if AUDSYS,
Rem                           AUDIT_ADMIN(/VIEWER) exists in the source DB
Rem    aramappa    08/30/12 - bug 14555249: fix olspreupgrade query to work for
Rem                           non-english locale
Rem    cdilling    08/29/12 - version to 12.1.0.1.0
Rem    cdilling    08/29/12 - version to 12.1.0.1.0
Rem    cdilling    08/20/12 - add 10205 to check for olspreupgrade
Rem    bmccarth    07/10/12 - tz to 18
Rem    traney      07/09/12 - bug 12915774: mark sys objects noneditionable
Rem    srtata      03/09/12 - bug 13779729 : add checks for OLS pre-upgrade
Rem    jerrede     12/21/11 - Make Parallel Upgrade the Default
Rem    jerrede     12/12/11 - Display Version Info
Rem    cdilling    11/16/11 - run @i1002000.sql rather than @i090200.sql
Rem    jerrede     10/28/11 - Fix Bug 13252372
Rem    cmlim       10/26/11 - update_tzv_17: change time zone file version from
Rem                           16 to 17
Rem    cdilling    10/13/11 - check direct upgrade versions for 12.1
Rem    yanchuan    10/11/11 - Bug 12776828: admin procedure name changes
Rem    cmlim       10/04/11 - update_tzv_16: change utlu_tz_version from 15 to
Rem                           16
Rem    cmlim       09/16/11 - olsdv upgrade: updated checks to dv-not-enabled
Rem                           and ols-not-installed
Rem    cmlim       11/11/09 - change the timezone check from 8 to 11
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    brwolf      08/31/11 - 32733: finer-grained editioning
Rem    cmlim       04/17/11 - bug 12363704: update time zone check in
Rem                           catupstr.sql that will work for re-upgrades
Rem                         - update time zone file version from 14 to 15
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    cdilling    02/17/11 - invoke utlip for upgrade to 12.1
Rem    cdilling    02/12/11 - bug 10373381: check instance to the 4th digit
Rem    cmlim       12/14/10 - bug 10400001: check that 112 oracle has DV off
Rem                           prior to upgrade
Rem    bmccarth    08/13/10 - version_script update for 12.1
Rem    cdilling    08/04/10 - add support for 12.1 instance version
Rem    cmlim       06/21/10 - update_tzv14: 11202 is now at time zone file v14
Rem    cmlim       04/26/10 - bug 9546509; suggest to force a checkpoint prior
Rem                           to shutdown abort in instructions
Rem    cdilling    03/12/10 - abort upgrade if invalid conditions for editions
Rem                           - bug 9454506
Rem    cmlim       02/01/10 - 11202 is now at time zone file version 13
Rem    cdilling    06/01/09 - check for supported upgrade versions
Rem    cdilling    05/26/09 - for PSU check only 5 digits for version
Rem    cmlim       01/16/09 - bug 7496789: update check on when DV needs to be
Rem                           relinked off
Rem    cmlim       12/19/08 - timezone_b7193417-c: rewrite timezone check
Rem    cmlim       12/12/08 - timezone_b7193417-b: if old OH has newer timezone
Rem                           version than 8, abort if new OH is not patched
Rem    rlong       09/25/08 - 
Rem    cmlim       07/24/08 - bug 7193417: support timezone file version
Rem                           changes in 11.2
Rem    awitkows    03/30/08 - DST. repl registry with props
Rem    rburns      11/11/07 - XbranchMerge rburns_bug-6446262 from
Rem                           st_rdbms_project-18813
Rem    rburns      11/08/07 - check for INVALID old versions of types
Rem    jciminsk    10/22/07 - Upgrade support for 11.2
Rem    cdilling    10/09/07 - update version to 11.2
Rem    cdilling    08/23/07 - check disabled indexes only
Rem    rburns      07/16/07 - add 11.1 patch upgrade
Rem    rburns      05/29/07 - add timezone version check
Rem    rburns      05/01/07 - reload dbms_assert
Rem    rburns      03/10/07 - add DV and OLS check
Rem    cdilling    02/19/07 - add sys.enabled$indexes table for bug 5530085
Rem    dvoss       02/19/07 - Check bootstrap migration status
Rem    rburns      10/23/06 - add session script
Rem    rburns      08/14/06 - add RDBMS identifier
Rem    cdilling    06/08/06 - add error logging table
Rem    gviswana    06/07/06 - Enable 4523571 fix 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem

Rem =====================================================================
Rem Exit immediately if there are errors in the initial checks
Rem =====================================================================

WHENEVER SQLERROR EXIT;        


Rem Set session initializations by invoking catpses.sql directly.
Rem This script will set session variable "_ORACLE_SCRIPT" to TRUE.
@@catpses.sql

Rem Pick up common Upgrade variables
@@dbms_registry_basic.sql

DOC 
######################################################################
######################################################################
    The following statement will cause an "ORA-01722: invalid number"
    error if the user running this script is not SYS.  Disconnect
    and reconnect with AS SYSDBA.
######################################################################
######################################################################
#

SELECT TO_NUMBER('MUST_BE_AS_SYSDBA') FROM SYS.DUAL
WHERE USER != 'SYS';

DOC
######################################################################
######################################################################
    The following statement will cause an "ORA-01722: invalid number"
    error if the database server version is not correct for this script.
    Perform "ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT", and use
    a different script or a different server.
######################################################################
######################################################################
#

Rem =====================================================================
Rem The following statement confirms that the script version identified by
Rem the &C_ORACLE_HIGH_ sqlplus variables matches the
Rem server version full value from v$instance. The C_ORACLE_HIGH
Rem sqlplus variables are defined in dbms_registry_basic.sql and contains
Rem a version value like 18.10.2.0.0. This value will be
Rem substituted in the query at run time, for example,
Rem TO_NUMBER('MUST_BE_18.10.2')
Rem =====================================================================

SELECT TO_NUMBER(
  'MUST_BE_&C_ORACLE_HIGH_MAJ..&C_ORACLE_HIGH_RU..&C_ORACLE_HIGH_RUR') 
FROM v$instance
WHERE substr(version_full,1,instr(version,'.',1,3)-1) !=
  	    '&C_ORACLE_HIGH_MAJ..&C_ORACLE_HIGH_RU..&C_ORACLE_HIGH_RUR';

DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01722: invalid number"
   error if the database has not been opened for UPGRADE.  

   Perform "ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT",  and 
   restart using UPGRADE.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('MUST_BE_OPEN_UPGRADE') FROM v$instance
WHERE status != 'OPEN MIGRATE';

DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01722: invalid number"
   error if Oracle Database Vault is installed but
   Oracle Label Security is not.  To successfully upgrade Oracle
   Database Vault, both Database Vault and Label Security must be
   installed.

   Install Oracle Label Security in this database before continuing
   the database upgrade.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('LABEL_SECURITY_NOT_INSTALLED') FROM SYS.DUAL
WHERE (SELECT COUNT(*) FROM user$ where name = 'LBACSYS') = 0 and
      (SELECT COUNT(*) FROM user$ where name = 'DVSYS') = 1;

DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01722: invalid number"
   error if bootstrap migration is in progress and logminer clients
   require utlmmig.sql to be run next to support this redo stream.

   Run utlmmig.sql
   then (if needed) 
   restart the database using UPGRADE and
   rerun the upgrade script.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('MUST_RUN_UTLMMIG.SQL')
    FROM SYS.V$DATABASE V
    WHERE V.LOG_MODE = 'ARCHIVELOG' and
          V.SUPPLEMENTAL_LOG_DATA_MIN != 'NO' and
          exists (select 1 from sys.props$
                  where name = 'LOGMNR_BOOTSTRAP_UPGRADE_ERROR');


Rem Assure CHAR semantics are not used in the dictionary
ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;


DOC
#######################################################################
#######################################################################
   The following error is generated if (1) the old release uses a time
   zone file version newer than the one shipped with the new oracle
   release and (2) the new oracle home has not been patched yet:

      SELECT TO_NUMBER('MUST_PATCH_TIMEZONE_FILE_VERSION_ON_NEW_ORACLE_HOME')
                       *
      ERROR at line 1:
      ORA-01722: invalid number

     o Action:
       Shutdown database ("alter system checkpoint" and then "shutdown abort").
       Patch new ORACLE_HOME to the same time zone file version as used
       in the old ORACLE_HOME.

#######################################################################
#######################################################################
#

Rem   SELECT TO_NUMBER('MUST_PATCH_TIMEZONE_FILE_VERSION_ON_NEW_ORACLE_HOME')

Rem Check if time zone file version used by the database exists in new home
SELECT TO_NUMBER('MUST_PATCH_TIMEZONE_FILE_VERSION_ON_NEW_ORACLE_HOME')
   FROM sys.props$
   WHERE
     (
      (name = 'DST_PRIMARY_TT_VERSION' AND TO_NUMBER(value$) > &C_LTZ_CONTENT_VER)
      AND
      (0 = (select count(*) from v$timezone_file))
     );


DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error, if a user or role with the name AUDSYS or AUDIT_ADMIN or 
     AUDIT_VIEWER is found in the database. 
     AUDSYS is an Oracle supplied user in 12.1 and AUDIT_ADMIN, AUDIT_VIEWER 
     are Oracle supplied roles in 12.1. Hence, these existing user or role 
     names found in the database must be dropped before upgrading.
     Please move the contents if any, from AUDSYS schema to a different schema.

     To drop the user 'AUDSYS' in this database, log in as SYS
     and run this operation
     "DROP USER AUDSYS CASCADE". 
     To drop the role 'AUDIT_ADMIN' in this database, log in as SYS
     and run this operation
     "DROP ROLE AUDIT_ADMIN".
     To drop the role 'AUDIT_VIEWER' in this database, log in as SYS
     and run this operation
     "DROP ROLE AUDIT_VIEWER".
#######################################################################
#######################################################################
#

Rem Bug 18589266: include filter to check if users/roles are oracle-supplied

SELECT TO_NUMBER('AUDIT_ADMINS_ARE_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('AUDSYS', 'AUDIT_ADMIN', 'AUDIT_VIEWER')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM sys.registry$ where
       cid = 'CATPROC') < '12.1' ;

DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error, if a table with the name AUD$UNIFIED owned by AUDSYS user 
     is found in the database.
     AUDSYS.AUD$UNIFIED is an Oracle internal table in 12.2. 
     Hence, this existing table name found in the database must be 
     dropped before upgrading.
     Please move the contents if any, from AUDSYS.AUD$UNIFIED table 
     to a different table.

     To drop the table 'AUDSYS.AUD$UNIFIED' in this database, 
     log in as SYS and run this operation
     "DROP TABLE AUDSYS.AUD$UNIFIED".
#######################################################################
#######################################################################
#

Rem Bug 21655904: Include filter to check if the table is Oracle Supplied
Rem Bug 24741114: Do not abort upgrade if AUDSYS.AUD$UNIFIED table partitions
Rem are not Oracle maintained.

SELECT TO_NUMBER('AUD$UNIFIED_TABLE_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.obj$ o where o.name='AUD$UNIFIED' and 
       ((o.namespace = 1 or o.type# = 2) and o.type# != 19) 
       and (bitand(o.flags, 4194304) != 4194304) 
       and o.owner# IN (select u.user# from sys.user$ u 
                        where u.name='AUDSYS')) > 0 AND 
      (select SUBSTR(version,1,4) FROM sys.registry$ where
       cid = 'CATPROC') < '12.2' ;

DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error, if the tablespace associated with traditional audit tables
     (AUD$ and/or FGA_LOG$ in SYS/SYSTEM schema) and/or unified audit 
     table (AUDSYS.AUD$UNIFIED) is encrypted and if the Oracle 
     Encryption Wallet is Not Open.
     We may require to add new columns as well as insert data into this 
     table as part of Upgrade.

     In this case, please make sure Oracle Encryption Wallet is Open 
     before proceeding further with the db upgrade.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('AUDIT_TS_ENCRYPTED_WALLET_NOT_OPEN') FROM SYS.DUAL
WHERE ((SELECT count(*) FROM v$encryption_wallet 
        WHERE status <> 'OPEN' 
              AND wallet_type IN ('PRIMARY', 'SINGLE', 'UNKNOWN')) > 0) 
      AND
      (((SELECT count(*) FROM sys.ts$ t1, sys.tab$ t2 
         WHERE (t1.ts# = t2.ts#) AND 
         (bitand(t1.flags, 16384)=16384) -- encrypted tablespace bit check
         AND t2.obj# IN
         (SELECT o.obj# FROM sys.obj$ o WHERE o.name IN ('AUD$', 'FGA_LOG$')
          AND (o.type# = 2) AND o.owner# IN
          (SELECT u.user# FROM sys.user$ u 
           WHERE u.name IN ('SYS', 'SYSTEM') AND (u.type# = 1)))) > 0)
       OR
       ((SELECT count(*) FROM 
         sys.ts$ t1, sys.tabpart$ t2, sys.obj$ o, sys.user$ u
         WHERE (t1.ts# = t2.ts#) AND (bitand(t1.flags, 16384)=16384) AND 
         (t2.bo# = o.obj#) AND (o.type# = 2) AND (o.name = 'AUD$UNIFIED') AND 
         (o.owner# = u.user#) AND (u.name='AUDSYS') AND (u.type# = 1)) > 0)
       OR
       ((SELECT count(*) FROM 
         sys.ts$ t1, sys.tab$ t2, sys.obj$ o, sys.user$ u 
         WHERE (t1.ts# = t2.ts#) AND (bitand(t1.flags, 16384)=16384) AND
         (t2.obj# = o.obj#) AND (o.type# = 2) AND (o.name = 'AUD$UNIFIED')
         AND (o.owner# = u.user#) AND (u.name = 'AUDSYS') 
         AND (u.type# = 1)) > 0));

DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error if a user/role with the name PROVISIONER, XS_RESOURCE, 
     XS_SESSION_ADMIN, XS_NAMESPACE_ADMIN, XS_CACHE_ADMIN, XS_CONNECT 
     is found in the database.

     PROVISIONER, XS_RESOURCE, XS_SESSION_ADMIN, XS_NAMESPACE_ADMIN,
     XS_CACHE_ADMIN are Oracle supplied roles in 12.1 and XS_CONNECT is
     Oracle supplied role in 12.2. Hence, these existing user or role names 
     found in the database must be dropped before upgrading.

     Please move the contents in the existing schemas to different schemas,
     if necessary, before dropping these schemas. The fixup needs to be
     done in the original Oracle home.

     Shutdown database ("alter system checkpoint" and then "shutdown abort").
     Revert to the original oracle home and start the database.
     Move the contents in the conflicting schemas as needed.
     Drop the conflicting users/roles.
     Revert to the new oracle home and restart the database in UPGRADE mode.
     Continue the database upgrade.

     Note - the following drops require execution as SYS:
     To drop role 'PROVISIONER'         - "DROP ROLE PROVISIONER".
     To drop role 'XS_RESOURCE'         - "DROP ROLE XS_RESOURCE".
     To drop role 'XS_SESSION_ADMIN'    - "DROP ROLE XS_SESSION_ADMIN".
     To drop role 'XS_NAMESPACE_ADMIN'  - "DROP ROLE XS_NAMESPACE_ADMIN".
     To drop role 'XS_CACHE_ADMIN'      - "DROP ROLE XS_CACHE_ADMIN".
     To drop role 'XS_CONNECT'          - "DROP ROLE XS_CONNECT".
#######################################################################
#######################################################################
#

Rem Bug 18589266: include filter to check if users/roles are oracle-supplied

SELECT TO_NUMBER('RAS_RESERVED_ROLES_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('PROVISIONER', 'XS_RESOURCE', 'XS_SESSION_ADMIN',
                 'XS_NAMESPACE_ADMIN', 'XS_CACHE_ADMIN')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.1' ;

Rem Bug 20897609: XS_CONNECT is introduced in 12.2 
SELECT TO_NUMBER('XS_CONNECT_ROLES_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('XS_CONNECT')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.2' ;

DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error if a user or role with the name DV_AUDIT_CLEANUP, 
     DV_DATAPUMP_NETWORK_LINK, DV_POLICY_OWNER is found in the database.

     DV_AUDIT_CLEANUP is an Oracle supplied role in 11.2.0.4, 
     DV_DATAPUMP_NETWORK_LINK  is Oracle supplied roles in 12.1 and 
     DV_POLICY_OWNER is an Oracle supplied role in 12.2. Hence, these 
     existing user or role names found in the database must be dropped 
     before upgrading.

     Please move the contents in the existing schemas to different schemas,
     if necessary, before dropping these schemas. The fixup needs to be
     done in the original Oracle home.

     Shutdown database ("alter system checkpoint" and then "shutdown abort").
     Revert to the original oracle home and start the database.
     Move the contents in the conflicting schemas as needed.
     Drop the conflicting users/roles.
     Revert to the new oracle home and restart the database in UPGRADE mode.
     Continue the database upgrade.

     Note - the following drops require execution as SYS:
     To drop role 'DV_AUDIT_CLEANUP'         - "DROP ROLE DV_AUDIT_CLEANUP".
     To drop role 'DV_DATAPUMP_NETWORK_LINK' - "DROP ROLE DV_DATAPUMP_NETWORK_LINK".
     To drop role 'DV_POLICY_OWNER'          - "DROP ROLE DV_POLICY_OWNER".
#######################################################################
#######################################################################
#

Rem Bug 16570807: add filters to check DV default roles

Rem DV_AUDIT_CLEANUP role is introduced in 11.2.0.4
SELECT TO_NUMBER('DV_RESERVED_ROLES_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
       name = 'DV_AUDIT_CLEANUP' AND
       bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,8) FROM registry$ where
       cid = 'CATPROC') = '11.2.0.3' ;

Rem DV_DATAPUMP_NETWORK_LINK role is introduced in 12.1
SELECT TO_NUMBER('DV_RESERVED_ROLES_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
       name = 'DV_DATAPUMP_NETWORK_LINK' AND
       bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.1' ;

Rem DV_POLICY_OWNER role is introduced in 12.2
SELECT TO_NUMBER('DV_RESERVED_ROLES_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
       name = 'DV_POLICY_OWNER' AND 
       bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.2' ;

DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error, if a user or role with the name SYSBACKUP, SYSDG, SYSKM, SYSRAC,
     or CAPTURE_ADMIN is found in the database.

     SYSBACKUP, SYSDG, SYSKM, and SYSRAC are Oracle supplied users in 12.1, 
     and CAPTURE_ADMIN is Oracle supplied role in 12.1. Hence, these 
     existing user or role names found in the database must be dropped
     before upgrading. 

     Please move the contents in the existing schemas to different schemas,
     if necessary, before dropping these schemas. The fixup needs to be
     done in the original Oracle home.

     Shutdown database ("alter system checkpoint" and then "shutdown abort").
     Revert to the original oracle home and start the database.
     Move the contents in the conflicting schemas as needed.
     Drop the conflicting users/roles.
     Revert to the new oracle home and restart the database in UPGRADE mode.
     Continue the database upgrade.

     Note - the following drops require execution as SYS:
     To drop user 'SYSBACKUP'      - "DROP USER SYSBACKUP CASCADE".
     To drop user 'SYSDG'          - "DROP USER SYSDG CASCADE".
     To drop user 'SYSKM'          - "DROP USER SYSKM CASCADE".
     To drop user 'SYSRAC'         - "DROP USER SYSRAC CASCADE".
     To drop role 'CAPTURE_ADMIN'  - "DROP ROLE CAPTURE_ADMIN".
#######################################################################
#######################################################################
#

Rem Bug 18589266: include filter to check if users/roles are oracle-supplied

SELECT TO_NUMBER('SOD_USERS_ARE_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('SYSBACKUP', 'SYSDG', 'SYSKM')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.1';

SELECT TO_NUMBER('CAPTURE_ADMIN_IS_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name = 'CAPTURE_ADMIN'
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.1';

SELECT TO_NUMBER('SYSRAC_USER_IS_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name = 'SYSRAC'
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.2';

DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error if a user/role with the name EM_EXPRESS_BASIC or 
     EM_EXPRESS_ALL is found in the database.

     EM_EXPRESS_BASIC and EM_EXPRESS_ALL are Oracle supplied roles 
     in 12.1. Hence, these existing user or role names found in 
     the database must be dropped before upgrading.

     Please move the contents in the existing schemas to different schemas,
     if necessary, before dropping these schemas. The fixup needs to be
     done in the original Oracle home.

     Shutdown database ("alter system checkpoint" and then "shutdown abort").
     Revert to the original oracle home and start the database.
     Move the contents in the conflicting schemas as needed.
     Drop the conflicting users/roles.
     Revert to the new oracle home and restart the database in UPGRADE mode.
     Continue the database upgrade.

     Note - the following drops require execution as SYS:
     To drop role 'EM_EXPRESS_BASIC' - "DROP ROLE EM_EXPRESS_BASIC".
     To drop role 'EM_EXPRESS_ALL'   - "DROP ROLE EM_EXPRESS_ALL".

#######################################################################
#######################################################################
#

Rem Bug 18589266: include filter to check if users/roles are oracle-supplied

SELECT TO_NUMBER('EM_EXPRESS_RESERVED_ROLES_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('EM_EXPRESS_BASIC', 'EM_EXPRESS_ALL')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.1' ;

DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error if a user/role with the name APPLICATION_TRACE_VIEWER
     is found in the database.

     APPLICATION_TRACE_VIEWER is an Oracle supplied role 
     in 12.2. Hence, these existing user or role name found in 
     the database must be dropped before upgrading.

     Please move the contents in the existing schemas to different schemas,
     if necessary, before dropping these schemas. The fixup needs to be
     done in the original Oracle home.

     Shutdown database ("alter system checkpoint" and then "shutdown abort").
     Revert to the original oracle home and start the database.
     Move the contents in the conflicting schemas as needed.
     Drop the conflicting users/roles.
     Revert to the new oracle home and restart the database in UPGRADE mode.
     Continue the database upgrade.

     Note - the following drops require execution as SYS:
     To drop role 'APPLICATION_TRACE_VIEWER' - 
       "DROP ROLE APPLICATION_TRACE_VIEWER".

#######################################################################
#######################################################################
#
SELECT TO_NUMBER('APPLICATION_TRACE_VIEWER_ROLE_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('APPLICATION_TRACE_VIEWER')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.2' ;

DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error, if a user or role with the name GSMCATUSER, GSMUSER, 
     GSMADMIN_INTERNAL or GSMUSER_ROLE, GSM_POOLADMIN_ROLE, GSMADMIN_ROLE, 
     GDS_CATALOG_SELECT is found in the database.

     GSMCATUSER, GSMUSER and GSMADMIN_INTERNAL are Oracle supplied users in 
     12.1, and GSMUSER_ROLE, GSM_POOLADMIN_ROLE, GSMADMIN_ROLE, 
     GDS_CATALOG_SELECT is Oracle supplied role in 12.1. Hence, these 
     existing user or role names found in the database must be dropped
     before upgrading. 

     Please move the contents in the existing schemas to different schemas,
     if necessary, before dropping these schemas. The fixup needs to be
     done in the original Oracle home.

     Shutdown database ("alter system checkpoint" and then "shutdown abort").
     Revert to the original oracle home and start the database.
     Move the contents in the conflicting schemas as needed.
     Drop the conflicting users/roles.
     Revert to the new oracle home and restart the database in UPGRADE mode.
     Continue the database upgrade.

     Note - the following drops require execution as SYS:
     To drop user 'GSMCATUSER'     - "DROP USER GSMCATUSER CASCADE".
     To drop user 'GSMUSER'        - "DROP USER GSMUSER CASCADE".
     To drop user 'GSMADMIN_INTERNAL' - "DROP USER GSMADMIN_INTERNAL CASCADE".
     To drop role 'GSMUSER_ROLE'         - "DROP ROLE GSMUSER_ROLE".
     To drop role 'GSM_POOLADMIN_ROLE'   - "DROP ROLE GSM_POOLADMIN_ROLE".
     To drop role 'GSMADMIN_ROLE'        - "DROP ROLE GSMADMIN_ROLE".
     To drop role 'GDS_CATALOG_SELECT'   - "DROP ROLE GDS_CATALOG_SELECT".
#######################################################################
#######################################################################
#

Rem Bug 18589266: include filter to check if users/roles are oracle-supplied

SELECT TO_NUMBER('GDS_USERS_ARE_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('GSMCATUSER', 'GSMUSER', 'GSMADMIN_INTERNAL')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.1';

SELECT TO_NUMBER('GDS_ROLES_ARE_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('GSMUSER_ROLE', 'GSM_POOLADMIN_ROLE', 'GSMADMIN_ROLE',
        'GDS_CATALOG_SELECT')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.1';

Rem proj-58146
DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error, if a user or role with the name REMOTE_SCHEDULER_AGENT is found in 
     the database.

     REMOTE_SCHEDULER_AGENT is an Oracle supplied user in 
     12.2. Hence, this existing user found in the database must be dropped
     before upgrading. 

     Please move the contents in the existing schemas to different schemas,
     if necessary, before dropping these schemas. The fixup needs to be
     done in the original Oracle home.

     Shutdown database ("alter system checkpoint" and then "shutdown abort").
     Revert to the original oracle home and start the database.
     Move the contents in the conflicting schemas as needed.
     Drop the conflicting users/roles.
     Revert to the new oracle home and restart the database in UPGRADE mode.
     Continue the database upgrade.

     Note - the following drops require execution as SYS:
     To drop user 'REMOTE_SCHEDULER_AGENT' - 
       "DROP USER REMOTE_SCHEDULER_AGENT CASCADE".
#######################################################################
#######################################################################
#

Rem Bug 18589266: include filter to check if users/roles are oracle-supplied

SELECT TO_NUMBER('REMOTE_SCHEDULER_AGENT_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('REMOTE_SCHEDULER_AGENT_FOUND')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.2';

DOC
#######################################################################
#######################################################################

     The following statement will cause an "ORA-01722: invalid number"
     error, if a user or role with the name SYS$UMF or SYSUMF_ROLE
     is found in the database.

     SYS$UMF is an Oracle supplied user in 12.2, and SYSUMF_ROLE is an 
     Oracle supplied role in 12.2. Hence, these existing user or role 
     names found in the database must be dropped before upgrading. 

     Please move the contents in the existing schemas to different schemas,
     if necessary, before dropping these schemas. The fixup needs to be
     done in the original Oracle home.

     Shutdown database ("alter system checkpoint" and then "shutdown abort").
     Revert to the original oracle home and start the database.
     Move the contents in the conflicting schemas as needed.
     Drop the conflicting users/roles.
     Revert to the new oracle home and restart the database in UPGRADE mode.
     Continue the database upgrade.

     Note - the following drops require execution as SYS:
     To drop user 'SYS$UMF'     - "DROP USER SYS$UMF".
     To drop role 'SYSUMF_ROLE' - "DROP ROLE SYSUMF_ROLE".
#######################################################################
#######################################################################
#

Rem Bug 18589266: include filter to check if users/roles are oracle-supplied

SELECT TO_NUMBER('UMF_USERS_ARE_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('SYS$UMF')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.2';

SELECT TO_NUMBER('UMF_ROLES_ARE_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('SYSUMF_ROLE')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.2';

DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error, if a user or role named DBSFWUSER or DBSFWUSER_ROLE is found
     in the database.

     DBSFWUSER and DBSFWUSER_ROLE are Oracle supplied in 12.2. Hence,
     they must be dropped before upgrading.

     Note - the following drops require execution as SYS:
     to drop user 'DBSFWUSER' - "DROP USER DBSFWUSER CASCADE".
     to drop role 'DBSFWUSER_ROLE' - "DROP ROLE DBSFWUSER_ROLE".

#######################################################################
#######################################################################
#

SELECT TO_NUMBER('DBSFWUSER_USERS_ARE_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('DBSFWUSER')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.2';

SELECT TO_NUMBER('DBSFWUSER_ROLES_ARE_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('DBSFWUSER_ROLE')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.2';

DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error, if a user or role named GGSYS or GGSYS_ROLE is found
     in the database.

     GGSYS and GGSYS_ROLE are Oracle supplied in 12.2. Hence,
     they must be dropped before upgrading.

     Note - the following drops require execution as SYS:
     to drop user 'GGSYS' - "DROP USER GGSYS CASCADE".
     to drop role 'GGSYS_ROLE' - "DROP ROLE GGSYS_ROLE".

#######################################################################
#######################################################################
#

Rem include filter to check if users/roles are oracle-supplied

SELECT TO_NUMBER('GGSYS_USERS_ARE_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('GGSYS')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.2';

SELECT TO_NUMBER('GGSYS_ROLES_ARE_FOUND') FROM SYS.DUAL
WHERE (select count(*) from sys.user$ WHERE
        name in ('GGSYS_ROLE')
        AND bitand(spare1, 256) != 256) > 0 AND
      (select SUBSTR(version,1,4) FROM registry$ where
       cid = 'CATPROC') < '12.2';

DOC
#######################################################################
#######################################################################

     The following statement will cause an "ORA-01722: invalid number"
     error, if the database contains invalid data as a result of type
     evolution which was performed without the data being converted.
     
     To resolve this specific "ORA-01722: invalid number" error:
       Shutdown database ("alter system checkpoint" and then "shutdown abort").
       Perform the data conversion (details below) in the old ORACLE_HOME.

     Please refer to Oracle Database Object-Relational Developer's Guide
     for more information about type evolution.

     Data in columns of tables dependent on Oracle_maintained types
     must be converted before the database can be upgraded. 

     This data can be converted at any time prior to the upgrade (the
     conversion does not need to be performed directly before the
     upgrade). The data conversion process can be time consuming.

     Load the Pre-upgrade Information Tool into the database using the 
     original database server (see the Pre-Upgrade Information Tool 
     instructions in the Oracle Database Upgrade Guide). Then execute 
     the following commands to perform the data conversion for 
     Oracle-Maintained tables:

     SET SERVEROUTPUT ON
     DECLARE
      RESULT BOOLEAN;
     BEGIN
      RESULT:= DBMS_PREUP.RUN_FIXUP('invalid_sys_tabledata');
     END;
     /
     SET SERVEROUTPUT OFF

     You should then confirm that any user tables dependent on Oracle-
     Maintained types are also converted.  You should review the data and
     determine if it needs to be converted or removed. 

     To view user tables which are affected by the evolution of 
     Oracle-Maintained types, execute the following:

     SELECT u.name OWNER, o.name TABLENAME, c.name COLNAME 
     FROM SYS.OBJ$ o, SYS.COL$ c, SYS.COLTYPE$ t, SYS.USER$ u
     WHERE o.OBJ# = t.OBJ# AND c.OBJ# = t.OBJ# AND c.COL# = t.COL#
       AND t.INTCOL# = c.INTCOL# AND BITAND(t.FLAGS, 256) = 256
       AND o.type#=2 AND o.OWNER# = u.USER# AND o.OWNER# NOT IN
          (SELECT schema# FROM sys.registry$ WHERE namespace = 'SERVER'
           UNION
           SELECT schema# FROM sys.registry$schemas 
           WHERE namespace = 'SERVER'
           UNION
           SELECT user# FROM sys.user$ WHERE type#=1 AND bitand(spare1,256)= 256)
       AND o.obj# IN
          (SELECT do.obj#
           FROM sys.dependency$ d, sys.obj$ do
           WHERE do.obj# = d.d_obj#
             AND do.type# IN (2,13)
           START WITH d.p_obj# IN -- Oracle-Maintained types
             (SELECT obj# from sys.obj$ 
              WHERE type#=13
                AND owner# IN
                   (SELECT schema# FROM sys.registry$ WHERE namespace='SERVER'
                    UNION
                    SELECT schema# FROM sys.registry$schemas 
                    WHERE namespace='SERVER'
                    UNION
                    SELECT user# FROM sys.user$ WHERE type#=1 
                       AND bitand(spare1,256)=256))
          CONNECT BY NOCYCLE PRIOR d.d_obj# = d.p_obj#);

     Once the data is confirmed, the following commands will convert the
     the data returned by the above query:

     SET SERVEROUTPUT ON
     DECLARE
      RESULT BOOLEAN;
     BEGIN
      RESULT:= DBMS_PREUP.RUN_FIXUP('invalid_usr_tabledata');
     END;
     /
     SET SERVEROUTPUT OFF

     Depending on the amount of data involved, converting the evolved type
     data can take a significant amount of time.

#######################################################################
#######################################################################
#

SELECT TO_NUMBER('NONUPGRADED_TABLEDATA') FROM SYS.V$INSTANCE
WHERE 
     (version <> (select version from sys.registry$ where cid = 'CATALOG'))
     AND
     EXISTS 
     (SELECT o.obj#
      FROM SYS.OBJ$ o, SYS.COL$ c, SYS.COLTYPE$ t
      WHERE o.OBJ# = t.OBJ# AND c.OBJ# = t.OBJ# AND c.COL# = t.COL# 
        AND t.INTCOL# = c.INTCOL# AND BITAND(t.FLAGS, 256) = 256 
        AND o.TYPE# = 2 AND o.OBJ# IN  
           (SELECT do.obj# 
            FROM sys.dependency$ d, sys.obj$ do
            WHERE do.obj# = d.d_obj#
              AND do.type# IN (2,13)
            START WITH d.p_obj# IN 
              (SELECT obj# from sys.obj$
               WHERE type#=13 
                 AND owner# IN
                    (SELECT schema# FROM sys.registry$ WHERE namespace='SERVER'
                     UNION
                     SELECT schema# FROM sys.registry$schemas 
                     WHERE namespace='SERVER'
                     UNION
                     SELECT user# FROM sys.user$ WHERE type#=1 
                        AND bitand(spare1,256)=256))
            CONNECT BY NOCYCLE PRIOR d.d_obj# = d.p_obj#));

DOC
#######################################################################
#######################################################################
   The following error is generated if initialization parameter
   MAX_STRING_SIZE is set to 'EXTENDED' but the 32k migration (or
   rdbms/admin/utl32k.sql) had not completed yet.

   SELECT TO_NUMBER('32K_MIGRATION_NOT_COMPLETED')
                    *
      ERROR at line 1:
      ORA-01722: invalid number

   Database upgrade will terminate on this error.

   o Cause:
     a) MAX_STRING_SIZE initialization parameter is set to
        EXTENDED but 32K migration had not completed.

     b) Database upgrade does not run rdbms/admin/utl32k.sql.

   o Action:
     Since database upgrade had already started, let's wait until
     it is done before user completes 32K migration.

     a) To resume database upgrade:
        Reset initialization parameter MAX_STRING_SIZE to 'STANDARD',
        restart database in UPGRADE mode,
        and rerun database upgrade.

     b) To complete 32K migration after database had been upgraded:
        Set initialization parameter MAX_STRING_SIZE to 'EXTENDED',
        restart database in UPGRADE mode,
        and run rdbms/admin/utl32k.sql.

#######################################################################
#######################################################################
#

Rem
Rem Bug 18555439
Rem Terminate upgrade if the following conditions are TRUE:
Rem a) if database is a non-CDB, PDB$SEED, or PDB
Rem (note: root, with con_id of 1, is not included in the check
Rem        because utl32k.sql doesn't change props$ value for root.
Rem  note: non-cdb has con_id of 0.)
Rem AND
Rem b) initialization parameter MAX_STRING_SIZE is at 'EXTENDED'
Rem AND
Rem c) MAX_STRING_SIZE in sys.props$ is not at 'EXTENDED'
Rem (note: we only care about the 'EXTENDED' value as this is the
Rem        value set at end of utl32k.sql)
Rem

SELECT TO_NUMBER('32K_MIGRATION_NOT_COMPLETED')
FROM sys.props$
WHERE
  ((select min(con_id) from sys.v$containers) <> 1)
  AND
  ((select upper(value) from sys.v$parameter where upper(name)
     = 'MAX_STRING_SIZE') = upper('EXTENDED'))
  AND
  ((select upper(value$) from sys.props$ where upper(name)
     = 'MAX_STRING_SIZE') <> upper('EXTENDED'));


Rem =====================================================================
Rem Assure CHAR semantics are not used in the dictionary
Rem =====================================================================

ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;

Rem =====================================================================
Rem Install App Prereqs, and begin Catalog App Upgrade
Rem Statement capture begins after this point.
Rem ALL NEW UPGRADE CODE SHOULD BE ADDED AFTER THIS.
Rem =====================================================================
@@catappupgpre.sql
@@catappupgbeg1.sql

Rem =====================================================================
Rem Continue even if there are SQL errors in remainder of script
Rem =====================================================================

WHENEVER SQLERROR CONTINUE;  

Rem
Rem Bug 5530085
Rem
Rem Poplulate sys.enabled_indexes table with the list of function-based 
Rem indexes that are currently not 'disabled'. This schema/index name list 
Rem will be later used in utlrp.sql to enable indexes in the list that may 
Rem have become disabled. 
Rem
CREATE TABLE sys.enabled$indexes sharing=none ( schemaname, indexname, objnum )
AS select u.name, o1.name, i.obj# from user$ u, obj$ o1, obj$ o2, ind$ i
    where
        u.user# = o1.owner# and o1.type# = 1 and o1.obj# = i.obj#
       and bitand(i.property, 16)= 16 and bitand(i.flags, 1024)=0
       and i.bo# = o2.obj# and bitand(o2.flags, 2)=0;



Rem
Rem Create error logging table
Rem
CREATE TABLE sys.registry$error(username   VARCHAR(256),
                                timestamp  TIMESTAMP,
                                script     VARCHAR(1024),
                                identifier VARCHAR(256),
                                message    CLOB,
                                statement  CLOB);
                                         
DELETE FROM sys.registry$error;
commit;

Rem
Rem Run Session initialization scripts
Rem error logging table must exist
Rem
@@catupses.sql
@@catalogses.sql

Rem
Rem Summary progress of the upgrade used by DBUA
Rem
Rem Create DBUA Summary table in the ROOT only
Rem PDB's are object linked to the table.
Rem

CREATE TABLE sys.registry$upg_summary
                (con_id      NUMBER,          /* Con id */
                 con_name    VARCHAR2(128),   /* Container Name */
                 cid         VARCHAR2(30),    /* Component id */
                 progress    VARCHAR2(1024),  /* DBUA Timestamp progress */
                 errcnt      NUMBER,          /* Error Count */
                 starttime   TIMESTAMP,       /* Start of phase time */
                 endtime     TIMESTAMP,       /* End of phase time */
                 reportname  VARCHAR2(2000)   /* Summary Report Name */
                );
Rem
Rem Remove existing data
Rem
DELETE FROM sys.registry$upg_summary;

--
-- Insert into upgrade summary table 
--
INSERT INTO sys.registry$upg_summary (con_id,
                                      con_name,
                                      cid,
                                      progress,
                                      errcnt,
                                      starttime,
                                      endtime,
                                      reportname)
VALUES (-1,
        'REPORT',
        'REPORT',
        'REPORT',
        0,
        SYSDATE,
        SYSDATE,
        'Report not run');
COMMIT;


Rem
Rem Pre-create log to record upgrade operations and errors
Rem

CREATE TABLE registry$log (
             cid         VARCHAR2(128),              /* component identifier */
             namespace   VARCHAR2(128),               /* component namespace */
             operation   NUMBER NOT NULL,              /* current operation */
             optime      TIMESTAMP,                  /* operation timestamp */
             errmsg      varchar2(1000)         /* ORA error message number */
             );
Rem Clear log entries if the table already exists
DELETE FROM registry$log;

Rem put timestamps into spool log and registry$log
INSERT INTO registry$log (cid, namespace, operation, optime)
       VALUES ('UPGRD_BGN','SERVER',-1,SYSTIMESTAMP);
COMMIT;
SELECT 'COMP_TIMESTAMP UPGRD__BGN ' || 
        TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ')  || 
        TO_CHAR(SYSTIMESTAMP,'J SSSSS ')
        AS timestamp FROM SYS.DUAL;

Rem
Rem Pre-create restart table for tracking phase related information 
Rem

CREATE TABLE registry$upg_resume(
             version    VARCHAR2(30),    /* database version  */
             phaseno    NUMBER,          /* upgrade phase number*/
             errorcnt   NUMBER,          /* errors during the phase*/
             starttime  TIMESTAMP(6),    /* phase start time */
             endtime    TIMESTAMP(6)     /* phase end time   */
             )
/

DELETE FROM registry$upg_resume; 

--
--   Display Version Info from registry$
--
SELECT substr(org_version,1,15) org_version,
       substr(prv_version,1,15) prv_version, 
       substr(version,1,15) version
from sys.registry$ where cid = 'CATPROC';

--
-- NOTE: DBUA_TIMESTAMP is sorted by catctl.pl if you change the
-- position of the SYSTIMESTAMP output then you have to change
-- the substr command on the sort in catrpt.pl.
--
SELECT 'DBUA_TIMESTAMP RDBMS      STARTED     ' || 
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ') from SYS.DUAL;

Rem =====================================================================
Rem BEGIN STAGE 1: load dictionary changes for basic SQL processing
Rem =====================================================================

Rem For non-CDB, run all of the "i" scripts from the earliest supported release
Rem release.  For CDB, we only need to run from 12.1.

COLUMN i_script NEW_VALUE i_upgrade_file
SELECT decode(cdb,'YES','i1201000.sql','i1102000.sql') i_script
from v$database;

@@&i_upgrade_file

Rem =====================================================================
Rem END STAGE 1: load dictionary changes for basic SQL processing
Rem =====================================================================

Rem =====================================================================
Rem Begin Bug 21156050 changes
Rem =====================================================================

Rem The default sys and system tablespace must be system as it is
Rem the unique valid configuration

alter user sys    default tablespace system;
alter user system default tablespace system;

Rem =====================================================================
Rem End Bug 21156050 changes
Rem =====================================================================

Rem =====================================================================
Rem Between stages 1 and 2
Rem =====================================================================

-- Beginning in version 12.1, PUBLIC has editioning enabled for public
-- synonyms.  Because utlip recreates the public synonym for dbms_standard,
-- before utlip can run all existing synonyms in PUBLIC must be marked as
-- non-editionable.  We do that here.

update obj$ set flags = flags + 1048576
  where owner# = 1 and type# in (5,10) and bitand(flags, 1048576) = 0;

-- bug 12915774: Set noneditionable bit for builtin schema objects
update obj$ set flags = (flags - bitand(flags, 1048576) + 1048576)
  where owner# in (select u.user# from registry$ r, user$ u 
    where r.status in (0,1,3,5)
       and r.namespace = 'SERVER'
       and r.schema#   = u.user#
     union all
     select u.user#
     from registry$ r, registry$schemas s, user$ u
     where r.status in (0,1,3,5)
       and r.namespace = 'SERVER'
       and r.cid       = s.cid
       and s.schema#   = u.user#)
  and type# in (4,5,7,8,9,11,12,13,14,22,114);
commit;
alter role "PUBLIC" enable editions for synonym;
alter system flush shared_pool;

Rem =====================================================================
Rem BEGIN STAGE 2: invalidate all non-Java objects
Rem =====================================================================

--
-- Invalidate all PL/SQL packages
--
@@utlip.sql 


-- Bug 6446262, check for INVALID old versions of types and update 
-- any with status = 6
SELECT name, subname, owner#, status FROM obj$
       WHERE type#=13 AND subname IS NOT NULL AND status > 1;
UPDATE obj$ SET status=1 
       WHERE type#=13 AND subname IS NOT NULL AND status=6;
COMMIT;
ALTER SYSTEM FLUSH SHARED_POOL;

-- Reload dbms_assert package for changed interfaces (used in "c" scripts)
@@dbmsasrt.sql
@@prvtasrt.plb

Rem =====================================================================
Rem END STAGE 2: invalidate all non-Java objects
Rem =====================================================================

Rem =====================================================================
Rem BEGIN STAGE 3: dictionary upgrade
Rem =====================================================================

WHENEVER SQLERROR EXIT

Rem Determine original release and run the appropriate script
CREATE OR REPLACE FUNCTION version_script 
RETURN VARCHAR2 IS

  p_null         char(1);
  p_version      VARCHAR2(30);
  p_prv_version  VARCHAR2(30);
  server_version VARCHAR2(30);

BEGIN


-- For 12.2, direct uppgrades are supported from 
-- 11.2.0.3 and above.
-- Above version #s to correspond to those in "Description" in catupgrd.sql.


  SELECT version INTO p_version FROM registry$ where cid='CATPROC';

  IF substr(p_version,1,8) IN ('11.2.0.3','11.2.0.4') THEN
     RETURN '1102000';
  ELSIF substr(p_version,1,6) = '12.1.0' THEN
     RETURN '1201000';  
  ELSIF substr(p_version,1,6) = '12.2.0' THEN
     RETURN '1202000';
  ELSE
     -- Use 7 character compare, since with QU version changes, the 2nd
     -- component can be > 10
     SELECT substr(version,1,7) INTO server_version FROM v$instance;
     IF substr(p_version,1,7) = server_version THEN
        -- version is the same as instance, so rerun the previous upgrade
        SELECT prv_version INTO p_prv_version
               FROM registry$ where cid='CATPROC';
        IF substr(p_prv_version,1,8) IN ('11.2.0.3','11.2.0.4') THEN
           RETURN '1102000';
        ELSIF substr(p_prv_version,1,6) = '12.1.0' THEN
           RETURN '1201000';
        ELSIF substr(p_prv_version,1,6) = '12.2.0' OR
              p_prv_version IS NULL THEN  -- new database
           RETURN '1202000';
        ELSE
           RAISE_APPLICATION_ERROR(-20000,
          'Upgrade re-run not supported from version ' || p_prv_version );
        END IF;
      END IF;
  END IF;

  RAISE_APPLICATION_ERROR(-20000,
       'Upgrade not supported from version ' || p_version );

END version_script;
/

Rem get the correct script name into the "upgrade_file" variable
COLUMN file_name NEW_VALUE upgrade_file NOPRINT;
SELECT version_script AS file_name FROM SYS.DUAL;

WHENEVER SQLERROR CONTINUE

Rem Now we pseudo-boostrap to enable CBO for the rest of upgrade
alter session set "_pseudo_bootstrap" = TRUE;
alter session set "_pseudo_bootstrap" = FALSE;

Rem run the selected "c" upgrade script
@@c&upgrade_file

Rem Remove entries from sys.duc$ - rebuilt for 11g by catalog and catproc
Rem Can cause errors on any DROP USER statements in upgrade scripts
truncate table duc$;

Rem  bug 19805359: grant all privileges to sys during db upgrades
Rem    note: a freshly created db has the same grant done in dsec.bsq
grant all privileges to sys;

Rem =====================================================================
Rem END STAGE 3: dictionary upgrade
Rem =====================================================================

