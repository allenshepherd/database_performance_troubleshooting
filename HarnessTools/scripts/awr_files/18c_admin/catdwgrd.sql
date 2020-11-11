Rem
Rem $Header: rdbms/admin/catdwgrd.sql /st_rdbms_18.0/1 2017/11/28 09:52:41 surman Exp $
Rem
Rem catdwgrd.sql
Rem
Rem
Rem Copyright (c) 2000, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catdwgrd.sql -  DataBase DoWnGrade from the current release 
Rem                      to the original release (if supported)
Rem
Rem    DESCRIPTION
Rem
Rem      This script is to be used for downgrading your database from the
Rem      current release you have installed to the release from which 
Rem      you upgraded.
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release environment
Rem        (before installing the release to which you want to downgrade).
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catdwgrd.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catdwgrd.sql
Rem    SQL_PHASE:DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      11/21/17 - XbranchMerge surman_bug-26281129 from main
Rem    surman      11/01/17 - 26281129: Support for new release model
Rem    hvieyra     10/19/17 - Fix for bug 26997466. Make DROP JAVA SOURCE actions
Rem                           conditional to the existance of JAVAVM component.
Rem    frealvar    09/22/17 - RTI 20613555 Remove dbms_preup 
Rem    arvijaya    07/11/17 - Bug 26379553: add catdwgrd_bgn/end tags
Rem    bwright     06/13/17 - Bug 25651930: Add OBSOLETE, ALL option to catnodp
Rem    mmcracke    04/24/17 - #(25814895) Fix data mining downgrade version
Rem                           check
Rem    pyam        04/23/17 - Bug 25879441: revert default_pwd$ data link
Rem    surman      04/17/17 - 25269268: Delete not truncate registry$sqlpatch
Rem    skabraha    03/29/17 - add check for PERSISTABLE keyword
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    welin       02/07/17 - Bug 25507759: truncate compatible value to 4
Rem                           digits
Rem    stanaya     01/11/17 - Bug-25356250 : adding sql metadata
Rem    mmcracke    12/02/16 - #(24958335) ODM 12.2.0.2 downgrade checks
Rem    welin       09/22/16 - version check for 12.2.0; add support for 
Rem                           downgrades to 12.2.0.1
Rem    gravipat    09/19/16 - 24690877: move call to update_version from f
Rem                           script to catdwgrd
Rem    amunnoli    08/29/16 - Lrg 19715106: Relax downgrade abort if pdb$seed,
Rem                           app seed and app root clone have audit records
Rem    schakkap    08/02/16 - #(24309782) mark all the tables whose stats
Rem                           updated after upgrade as stale
Rem    frealvar    07/29/16 - Bug 24355625 catdwgrd.sql throwing java error
Rem    thbaby      07/28/16 - XbranchMerge thbaby_bug-24341326 from
Rem                           st_rdbms_12.2.0.1.0
Rem    raeburns    07/25/16 - XbranchMerge raeburns_bug-24298357 from
Rem                           st_rdbms_12.2.0.1.0
Rem    thbaby      07/22/16 - Bug 24341326: check for Application Containers 
Rem                           and Proxy PDBs
Rem    raeburns    07/14/16 - Bug 24298357: Add version check to prevent rerun
Rem    amunnoli    07/01/16 - Bug 23727767: Relax downgrade abort from CDB ROOT
Rem                           when there are some unified audit records present
Rem    amunnoli    05/30/16 - Bug 23221566: Check if the Oracle wallet is
Rem                           open when audit table is stored in encrypted ts
Rem    surman      03/03/16 - 22531619: Directly query registry$sqlpatch
Rem    welin       01/27/16 - bug 22603875 - downgrade must explictly set
Rem                           NLS_LENGTH_SEMANTICS to BYTE
Rem    hvieyra     10/20/15 - Auto Upgrade resume functionality - Bug fix 20688203
Rem    welin       09/04/15 - Bug 21792696: Disable CDB/PDB downgrade from 12.2
Rem                           to 12.1.0.1
Rem    amunnoli    07/30/15 - Bug 21370358:Raise an application error if
Rem                           AUDSYS.AUD$UNIFIED table has some audit data
Rem    pyam        07/13/15 - 20981795: add _pdb_first_script
Rem    sdoraisw    06/29/15 - 21074797:check for null default directory
Rem    sdoraisw    04/15/15 - proj47082: check for PET during downgrade
Rem    jerrede     03/30/15 - Remove procedure call to figure out version.
Rem                           Cannot references any packages since they may
Rem                           become invalid during downgrade.
Rem    raeburns    03/16/15 - Bug 20446846: remove 11.1 downgrade
Rem                         - (unsupported downgrade version)
Rem    amunnoli    01/22/15 - Bug 20391712: Fix Long Identifier issue
Rem    surman      11/18/14 - 19976523: Call ctxdwchk
Rem    prthiaga    08/18/14 - Bug 19461428 - Check for JSON during downgrade
Rem    jerrede     06/11/14 - Allow 12.1.0.2.0 downgrade
Rem    surman      05/26/14 - 17277459: Check for SQL patches
Rem    wesmith     05/14/14 - Project 47511: data-bound collation
Rem    amozes      05/11/14 - ODM 12.2 changes
Rem    sasounda    03/06/14 - 18111335: conditionalize READ priv downgrd action
Rem    surman      02/12/14 - 13922626: Update SQL metadata
Rem    cdilling    02/07/14 - bug 18165071 - add back drop scheduler code
Rem    cdilling    12/26/13 - remove obsolete checks since we do not support
Rem                           downgrades to 10.2 or below
Rem    cdilling    11/75/13 - fix lrg 10152308 - remove obsolete checks for database links, data mining and scheduler code
Rem    sasounda    11/06/13 - proj 47829: update/remove READ entries from
Rem                           access$ at the end of STAGE 4
Rem    cdilling    09/29/13 - move shutdown to utlmmigdown.sql
Rem    ajadams     08/19/13 - lrg-7157890: move catnodp after LogMiner uses
Rem                           dbms_stats
Rem    cdilling    05/12/13 - add support for downgrade back to 12.1.0.2
Rem    jerrede     03/18/13 - Conditionalize utlmmigdown.sql
Rem    cdilling    01/27/13 - add support for downgrade back to 12.1.0.1
Rem    cdilling    10/26/12 - add support for 12.1.0.2
Rem    amunnoli    08/30/12 - Bug 14560783: Raise an application error if the 
Rem                           unified audit trail is not empty
Rem    srtata      07/03/12 - bug 14251893: update error to include full path
Rem                           of olspredowngrade.sql
Rem    srtata      03/09/12 - bug 13779729 : add checks for OLS pre-downgrade
Rem    cdilling    01/25/12 - we no longer need to warn about EM
Rem    cdilling    10/13/11 - add direct downgrade version support
Rem    traney      09/12/11 - move utlmmigdown to the end
Rem    cdilling    03/09/11 - add support for 12.1
Rem    traney      01/13/11 - 35209: downgrade dictionary for long identifiers
Rem    amozes      10/18/10 - Changes for ODM downgrade
Rem    cdilling    10/03/10 - check for 1201000 for patch vs major release
Rem    bmccarth    05/25/10 - deal with 1102000
Rem    cdilling    08/20/09 - add support for patch downgrades in 11.2
Rem    cdilling    06/04/09 - update to reflect supported downgrade versions
Rem    rpang       02/05/09 - 7600720: Network ACL check only when XDB present
Rem    rgmani      10/30/08 - Downgrade scheduler java code
Rem    rpang       03/28/08 - no xml rewrite for network acl query
Rem    nkgopal     01/29/08 - lrg 3284618
Rem    nkgopal     01/14/08 - Add DBMS_AUDIT_MGMT downgrade check
Rem    rpang       01/09/08 - add check for PL/SQL network ACLs
Rem    rburns      01/03/08 - 11.2 major release downgrade
Rem    rburns      12/10/07 - component patch downgrade
Rem    rburns      08/27/07 - change compatible test
Rem    cdilling    08/09/07 - add support for 11g patch downgrade
Rem    cdilling    04/19/07 - em downgrade changes
Rem    rburns      02/25/07 - recompile indextypes
Rem    cdilling    09/15/06 - add call to f&downgrade_file for pl/sql calls
Rem    rtjoa       07/10/06 - Avoid XMLindexes check before downgrade for XDB 
Rem                           objects 
Rem    liwong      06/07/06 - Check user buffered message apply 
Rem    rburns      05/08/06 - check patch compatible value 
Rem    xbarr       03/09/06 - add support for 11g to 10.2 data mining downgrade 
Rem    cdilling    11/02/05 - add support for 11g to 10.2 downgrade 
Rem    rburns      10/05/05 - remove 9.2 downgrade 
Rem    rburns      03/28/05 - enable component check 
Rem    rburns      03/14/05 - dbms_registry_sys timestamp 
Rem    rburns      02/27/05 - record action for history 
Rem    attran      11/04/04 - check for XMLIDX
Rem    htran       07/26/04 - check for commit-time queue tables
Rem    rburns      06/28/04 - consolidate warnings 
Rem    clei        06/10/04 - disallow downgrade if encrypted columns exist
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      02/04/04 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem =======================================================================
Rem To mark the begin of catdwgrd.sql
Rem =======================================================================
SELECT dbms_registry_sys.time_stamp('CATDWGRD_BGN') AS timestamp FROM DUAL;

alter session set "_pdb_first_script"=TRUE;
alter session set NLS_LENGTH_SEMANTICS=BYTE;

Rem =======================================================================
Rem Exit immediately if there are errors in the initial checks
Rem =======================================================================

WHENEVER SQLERROR EXIT;

COLUMN catprvversion NEW_VALUE CAT_PRV_VERSION NOPRINT;
SELECT substr(prv_version,1,8) as catprvversion FROM registry$ WHERE cid='CATPROC';
SET VERIFY OFF

DOC
#######################################################################
#######################################################################

 If the below SQL statement raises an 'ORA-01722: invalid number' error
 then catdwgrd.sql has already been run on this database. 

 Please refer to Chapter 6 of the Database Upgrade Guide, "Downgrading 
 Oracle Database to an Earlier Release" for information about 
 continuing the downgrade processs by running catrelod.sql using the
 earlier release server. If there were errors running catdwgrd.sql,
 recover the database, address the errors, and rerun catdwgrd.sql.

#######################################################################
#######################################################################
#

SELECT TO_NUMBER('DATABASE ALREADY DOWNGRADED') 
FROM sys.dual
WHERE (SELECT substr(version,1,8) FROM v$instance) <>
      (SELECT substr(version,1,8) FROM registry$ WHERE cid='CATPROC');

Rem Check instance version and status; set session attributes
EXECUTE dbms_registry.check_server_instance;

Rem Determine the previous release 
CREATE OR REPLACE FUNCTION version_script
RETURN VARCHAR2 IS

  p_compatible  VARCHAR2(30);

BEGIN
  IF '&CAT_PRV_VERSION' IS NULL THEN
     RAISE_APPLICATION_ERROR(-20000,
       'Downgrade not supported - database has not been upgraded');
  END IF;

  -- Only allow downgrades to versions 11.2.0.3 and higher
  IF '&CAT_PRV_VERSION' NOT IN 
     ('11.2.0.3','11.2.0.4','12.1.0.1','12.1.0.2','12.2.0.1')
  THEN
     RAISE_APPLICATION_ERROR(-20000,
       'Downgrade not supported to version ' || '&CAT_PRV_VERSION');
  ELSIF '&CAT_PRV_VERSION' IN ('12.1.0.1') AND 
     sys.dbms_registry.is_db_consolidated()
  THEN
     RAISE_APPLICATION_ERROR(-20000,
       'Downgrade of a CDB/PDB is not supported to version 12.1.0.1' );
  END IF;
 
  -- Get the current compatible value   
  SELECT substr(value,1,8) INTO p_compatible
  FROM v$parameter
  WHERE name = 'compatible';
  IF p_compatible > '&CAT_PRV_VERSION' THEN
     dbms_sys_error.raise_system_error(-39707, p_compatible, '&CAT_PRV_VERSION');
  END IF;

  IF '&CAT_PRV_VERSION' IN ('11.2.0.3','11.2.0.4') THEN
     RETURN '1102000';
  ELSIF '&CAT_PRV_VERSION' IN('12.1.0.1','12.1.0.2') THEN
     RETURN '1201000';
  ELSIF '&CAT_PRV_VERSION' IN ('12.2.0.1') THEN
     RETURN '1202000';
  END IF;
END version_script;
/

Rem get the version correct into the "downgrade_file" variable
COLUMN file_name NEW_VALUE downgrade_file NOPRINT;
SELECT version_script AS file_name FROM DUAL;
DROP function version_script;

Rem =========================================================================
Rem BEGIN STAGE 1: Perform checks prior to downgrade to previous release
Rem =========================================================================

Rem 26281129: No longer need to query the SQL registry

DOC
#######################################################################
#######################################################################
If non partititioned external tables with a missing DEFAULT DIRECTORY 
clause were created, then the downgrade cannot proceed till they have
been dropped. This query can be used to locate the tables that must be 
dropped:
   select name from obj$ o, external_tab$ xt
   where o.obj#=xt.obj#
   and o.subname is NULL
   and xt.default_dir is NULL;
#######################################################################
#
Rem Error out if non partitioned tables with missing default directory exist
declare
   null_def_dir_cnt number := 0;

begin
  select count(*) into null_def_dir_cnt from 
    obj$ o, external_tab$ xt
    where  o.obj#=xt.obj#
    and  o.subname is NULL
    and xt.default_dir is NULL;
  if ( null_def_dir_cnt != 0) then
      raise_application_error(-20000,
      'All non partitioned external tables with missing DEFAULT DIRECTORY must be dropped before downgrade');
  end if;
end;
/

DOC
#######################################################################
#######################################################################
If any of the user types have PERSISTABLE keyword, they need to be 
dropped before downgrading as the keyword would not be recognized by 
downgraded binary. You can see the offending types in the output log.
If the types are need after downgrade, they should be recreated without
the keyword.
#######################################################################
#

declare
 retval number;
begin
 retval := dbms_objects_utils.persistable_downgrade_check();
 if (retval = 1) then
    RAISE_APPLICATION_ERROR(-20000,
       'There are user types with PERSISTABLE keyword');
 end if;

end;
/


Rem =========================================================================
Rem Perform 11.2 downgrade checks
Rem =========================================================================

DOC
#######################################################################
#######################################################################
  
 If the below PL/SQL block raises an ORA-01403 error, use the following
 query to verify if the olspredowngrade.sql script has been run or not.
 Oracle Label Security (OLS) pre process script prior to downgrade is 
 required to be run to process the aud$ table contents. OLS downgrade from 12g 
 will move the aud$ from SYS schema to SYSTEM schema.

   SELECT object_name FROM dba_objects WHERE object_name='PREDWG_AUD$'
                      AND owner = 'SYSTEM' AND OBJECT_TYPE='TABLE';

 
 To run the Oracle Label Security pre process script prior to downgrade, 
 execute the following $ORACLE_HOME/rdbms/admin/olspredowngrade.sql as SYSDBA, 
 before starting the downgrade process. The OLS pre-downgrade script creates a 
 temporary table 'PREDWG_AUD$' in 'SYSTEM' schema.
   
#######################################################################
#######################################################################
#

Rem Raise error if the 'PREDWG_AUD$' does not exist in 'SYSTEM' schema
DECLARE
  tabname VARCHAR2(256);
  lbac_cnt NUMBER :=0;
BEGIN
  SELECT COUNT(*) into lbac_cnt FROM dba_users where USERNAME = 'LBACSYS';

  -- If no OLS in picture return 
  -- OLS pre-downgrade script is required to be run only if downgrading 
  -- to 11.2. If database is being downgraded to 12.1 or above
  -- there is no need to run this script

  IF lbac_cnt = 0  OR '&CAT_PRV_VERSION' NOT IN
     ('11.2.0.3','11.2.0.4') THEN 
   RETURN;
  END IF;

  SELECT table_name INTO tabname FROM dba_tables WHERE  
      table_name='PREDWG_AUD$' AND owner = 'SYSTEM';
  
  EXCEPTION 
   WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20000,
       'Downgrade cannot proceed - $ORACLE_HOME/rdbms/admin/olspredowngrade.sql script must be executed prior to downgrade');
END;
/

DOC
#######################################################################
#######################################################################

 Please be aware that after downgrade all the Unified Audit data will be lost.

 If the below PL/SQL block raises an ORA-20001 error, then
 clean up the unified audit trail using the following steps:
 
 - Open the Database in the migrate mode
 - Connect as SYS user
 - If you want to take the backup of the audit data then 
   select from UNIFIED_AUDIT_TRAIL into a table. Once copied, then
   issue the following PL/SQL procedure to execute clean up of Unified
   Audit Trail.
 - Clean Up Unified Audit Trail.

    DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL
     (audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED, 
      use_last_arch_timestamp => FALSE);

#######################################################################
#######################################################################
#

DECLARE
  ErrMsg VARCHAR2(1024);
  no_rows NUMBER := 0;
  audsys_prsnt NUMBER := 0;
  tab_name  dbms_id;
  aud_unified_tab_exists NUMBER := 0;
  aud_unified_tab_rows NUMBER := 0;
  cur_con_id  NUMBER := 0;
  app_seed  VARCHAR2(5);
  app_root_clone VARCHAR2(5);
BEGIN
  -- First check if AUDSYS exists or already been dropped?
  SELECT count(*) into audsys_prsnt FROM sys.user$
  WHERE (name = 'AUDSYS' and type# = 1);

  -- If AUDSYS still exists
  IF audsys_prsnt = 1 THEN

    ErrMsg := 'Downgrade cannot proceed - ' ||
              'Unified Audit Trail data exists.' ||
              'Please clean up the data first using '||
              'DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL.';

    -- Get the Current Container ID where we are running this check
    select sys_context('userenv', 'con_id') into cur_con_id from dual;

    IF '&CAT_PRV_VERSION' NOT IN ('11.2.0.3','11.2.0.4') THEN
      -- Check if AUD$UNIFIED table exists
      select count(*) into aud_unified_tab_exists FROM sys.obj$ o WHERE
      o.name = 'AUD$UNIFIED' and o.type# = 2 and o.owner# IN (select u.user#
      from sys.user$ u where u.name = 'AUDSYS');

      IF aud_unified_tab_exists = 1 THEN
        -- Check if AUD$UNIFIED still holds the unified audit records
        select count(*) into aud_unified_tab_rows from audsys.aud$unified;

        -- Bug 23727767: Relax the downgrade abort when we are in CDB ROOT,
        -- because while catdwgrd.sql is getting run in PDBs there could be 
        -- some audit records generated inside CDB ROOT's UNIFIED_AUDIT_TRAIL.
        -- Lrg 19715106: When cleanup of audit trail is performed with
        -- CONTAINER_ALL, we skip PDB$SEED, APPLICATION SEED and APPLICATION
        -- ROOT CLONE Containers, thus we do not want to abort the
        -- downgrade if there are some unified audit records generated in
        -- these containers.
        select application_seed, application_root_clone into app_seed,
        app_root_clone from v$containers where 
        con_id = sys_context('userenv', 'con_id');

        IF ((aud_unified_tab_rows > 1) AND (cur_con_id != 1) AND 
            (cur_con_id != 2) AND (app_seed != 'YES') AND 
            (app_root_clone != 'YES')) THEN
          RAISE_APPLICATION_ERROR(-20001, ErrMsg);
        END IF;  
      END IF;

    ELSE
      -- Get the unified audit trail CLI table name
      select t.name into tab_name from cli_log$ l, cli_tab$ t
      where l.log# = t.log# and l.name='ORA$AUDIT_NEXTGEN_LOG';

      -- Check if the unified audit CLI table has some data
      execute immediate
      'select count(*) from audsys.'||'"'||tab_name||'"' into no_rows;

      -- If audit trail has some data, raise the application error
      IF no_rows > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, ErrMsg);
      END IF;
    END IF;
  END IF;
EXCEPTION 
  WHEN NO_DATA_FOUND THEN
   NULL;
  WHEN OTHERS THEN
   RAISE;
END;
/

DOC
#######################################################################
#######################################################################

 If the below PL/SQL block raises an ORA-20001 error, then
 please make sure Oracle Encryption Wallet is Open for it to succeed.

 - Open the Database in the migrate mode
 - Connect as SYS user
 - Open the Oracle Encryption Wallet

#######################################################################
#######################################################################
#

DECLARE
  ErrMsg VARCHAR2(1024);
  aud_ts_encrypted NUMBER := 0;
  uniaud_ts_encrypted NUMBER := 0;
  wallet_open_status NUMBER := 0;
  uniaud_is_part NUMBER := 0;
BEGIN

  ErrMsg := 'Downgrade cannot proceed - ' ||
            'Audit Table is stored in an Encrypted Tablespace, and' ||
            'Oracle Encryption Wallet is not Open. '||
            'Please make sure Oracle Encryption Wallet is Open.';

  -- Check if Oracle Encryption Wallet is Open
  SELECT count(*) INTO wallet_open_status FROM v$encryption_wallet
  WHERE status <> 'OPEN' AND wallet_type IN ('PRIMARY', 'SINGLE', 'UNKNOWN');

  IF (wallet_open_status > 0) THEN -- Wallet Not Open

    -- Check if AUD$/FGA_LOG$ is stored in an Encrypted Tablespace
    SELECT count(*) INTO aud_ts_encrypted FROM sys.ts$ t1, sys.tab$ t2
    WHERE (t1.ts# = t2.ts#) 
    AND (bitand(t1.flags, 16384)=16384) -- encrypted tablespace bit check
    AND t2.obj# IN (SELECT o.obj# FROM sys.obj$ o WHERE 
                    o.name IN ('AUD$', 'FGA_LOG$') AND (o.type# = 2) 
                    AND o.owner# IN (SELECT u.user# FROM sys.user$ u
                    WHERE u.name IN ('SYS', 'SYSTEM') AND (u.type# = 1)));

    IF (aud_ts_encrypted > 0) THEN
       ErrMsg := ErrMsg 
        || 'Audit Table is - AUD$/FGA_LOG$ in SYS/SYSTEM schema.';
       RAISE_APPLICATION_ERROR(-20001, ErrMsg);
    END IF;

    -- Check if AUDSYS.AUD$UNIFIED is stored in an Encrypted Tablespace
    -- Before that, first check if AUDSYS.AUD$UNIFIED is Partitioned
    SELECT count(*) INTO uniaud_is_part FROM
    sys.partobj$ p, sys.obj$ o, sys.user$ u WHERE
    (p.obj# = o.obj#) AND (o.type# = 2) AND (o.name = 'AUD$UNIFIED') AND
    (o.owner# = u.user#) AND (u.name = 'AUDSYS') AND (u.type# = 1);

    IF (uniaud_is_part > 0) THEN  -- AUDSYS.AUD$UNIFIED is Partitioned
      SELECT count(*) INTO uniaud_ts_encrypted FROM 
      sys.ts$ t1, sys.tabpart$ t2, sys.obj$ o, sys.user$ u
      WHERE (t1.ts# = t2.ts#) AND (bitand(t1.flags, 16384)=16384) AND
      (t2.bo# = o.obj#) AND (o.type# = 2) AND (o.name = 'AUD$UNIFIED') AND
      (o.owner# = u.user#) AND (u.name='AUDSYS') AND (u.type# = 1);
    ELSE
      SELECT count(*) INTO uniaud_ts_encrypted FROM
      sys.ts$ t1, sys.tab$ t2, sys.obj$ o, sys.user$ u
      WHERE (t1.ts# = t2.ts#) AND (bitand(t1.flags, 16384)=16384) AND
      (t2.obj# = o.obj#) AND (o.type# = 2) AND (o.name = 'AUD$UNIFIED')
      AND (o.owner# = u.user#) AND (u.name = 'AUDSYS') AND (u.type# = 1);
    END IF;

    IF (uniaud_ts_encrypted > 0) THEN
       ErrMsg := ErrMsg || 'Audit Table is - AUDSYS.AUD$UNIFIED.';
       RAISE_APPLICATION_ERROR(-20001, ErrMsg);
    END IF;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
   NULL;
  WHEN OTHERS THEN
   RAISE;
END;
/

Rem =========================================================================
Rem Perform 12.1 downgrade checks
Rem =========================================================================

DOC
#############################################################################
#############################################################################

  If the below PL/SQL block raises an ORA-65347 error, use the following
  query to identify the PDBs to be dropped prior to downgrade.

  To retrieve names of Proxy PDBs or PDBs related to Application Container, 
    use this query: 

    SELECT NAME 
    FROM   V$PDBS
    WHERE  APPLICATION_ROOT='YES' 
       OR  APPLICATION_SEED='YES'
       OR  APPLICATION_PDB='YES'
       OR  PROXY_PDB='YES';

    Drop the PDBs returned by the above query prior to downgrade

#######################################################################
#######################################################################
#

Rem =========================================================================
Rem Check if there are Proxy PDBs or PDBs related to Application Containers. 
Rem If yes, we error out here and ask the user to drop them before proceeding 
Rem with downgrade.
Rem =========================================================================

DECLARE
  pdbcnt                   NUMBER := 0;
  appcon_downgrade_error   exception;
  PRAGMA EXCEPTION_INIT(appcon_downgrade_error, -65347);
BEGIN
  -- If we are downgrading to 12.2.0.1 or higher then no action is required. 
  -- Note that a Multitenant database cannot be downgraded to any version
  -- prior to 12.1.0.1. Therefore, there is no need to check for 11.2.0.x.
  if '&CAT_PRV_VERSION' IN ('12.1.0.1','12.1.0.2') then
    -- Check usage of Application Container or Proxy PDB 
    execute immediate 'select count(*) from v$pdbs '||
                      ' where application_root=''YES''' ||
                      '    or application_seed=''YES''' ||
                      '    or application_pdb=''YES''' ||
                      '    or proxy_pdb=''YES''' 
    into pdbcnt;
 
    if (pdbcnt > 0 ) then
      raise appcon_downgrade_error;
    end if;
  end if;
END;
/

DOC
#############################################################################
#############################################################################

    If the below PL/SQL block raises an ORA-40350 error, use the following
    query to identify Data Mining Models that need to be dropped (models
    created in 12.2 or beyond).

      SELECT u.name owner, o.name model_name
      FROM  sys.model$ m, sys.obj$ o, sys.user$ u
      WHERE (m.version-(round(m.version/65536)*65536)) > 4
      AND   m.obj# = o.obj#
      AND   o.owner# = u.user#;

    Drop above models prior to downgrade 

#######################################################################
#######################################################################
#

Rem   Raise error if there are Data Mining Models created in 12.2.0.2 or beyond
DECLARE
   cnt                 NUMBER;
   odm_downgrade_error exception;
   PRAGMA EXCEPTION_INIT(odm_downgrade_error, -40350);
BEGIN
   IF '&CAT_PRV_VERSION' IN ('11.2.0.3','11.2.0.4','12.1.0.1', '12.1.0.2', '12.2.0.1') THEN
     execute immediate 
       'select count(*) from sys.model$ ' ||
       'where (version-(round(version/65536)*65536)) > 4' into cnt;
     IF cnt != 0 THEN
       RAISE odm_downgrade_error;
     END IF;
   END IF;
END;
/

DOC
#############################################################################
#############################################################################

  If the below PL/SQL block raises an ORA-40559 error, use the following
  query to identify the JSON objects/constraints to be dropped prior 
  to downgrade.

  To get the columns with IS JSON constraint, use,

    SELECT OWNER, TABLE_NAME, COLUMN_NAME from DBA_JSON_COLUMNS;

  To get any text indexes using JSON operators, use,

    SELECT u.NAME, c.IDX_NAME 
    FROM   ctxsys.dr$index c, user$ u  
    WHERE  c.idx_id in (select ixv_idx_id 
                        from   ctxsys.dr$index_value 
                        where  IXV_OAT_ID = 50817 
                            OR IXV_OAT_ID = 50819)
      AND  u.user# = c.idx_owner#              


    Drop above columns/indexes prior to downgrade

#######################################################################
#######################################################################
#

Rem =========================================================================
Rem Check if there are any columns with a IS JSON constraint or any views
Rem created with a JSON operator. If so, we error out here and ask the user
Rem to drop them before proceeding with downgrade.
Rem =========================================================================

DECLARE
  colcnt                 NUMBER := 0;
  tidxcnt                NUMBER := 0;
  json_downgrade_error   exception;
  PRAGMA EXCEPTION_INIT(json_downgrade_error, -40559);
BEGIN
  -- If we are downgrading to 12.1.0.2 or higher then no action 
  -- is required. If we see any of the counts > 0 and we are 
  -- downgrading to 12.1.0.1 or lower, then raise error, if we have 
  -- any JSON objects.
  if '&CAT_PRV_VERSION' IN ('11.2.0.3','11.2.0.4','12.1.0.1') then
    -- Get count of columns with IS JSON constraint  
    execute immediate 'select count(*) from dba_json_columns '||
                      ' where owner not in (''XDB'', ''SYS'')'
    into colcnt;
 
    begin
      -- Get count of any JSON/BSON text indexes
      execute immediate 'select count(*) from  ctxsys.dr$index  where
                         idx_id in (select ixv_idx_id from 
                         ctxsys.dr$index_value where IXV_OAT_ID = 50817 
                         OR IXV_OAT_ID = 50819)'
      into tidxcnt;
    exception
      when OTHERS then
        tidxcnt := 0;
    end;

    if (colcnt > 0 OR tidxcnt > 0 ) then
      raise json_downgrade_error;
    end if;
  end if;
END;
/

Rem =========================================================================
Rem BEGIN Component downgrade check scripts
Rem =========================================================================

COLUMN check_script NEW_VALUE check_script NOPRINT

Rem Context
SELECT dbms_registry.script('CONTEXT', '?/ctx/admin/ctxdwchk') AS check_script
  FROM dual;
@&check_script

Rem =========================================================================
Rem END Component downgrade check scripts
Rem =========================================================================

Rem =========================================================================
Rem END STAGE 1: Perform checks prior to downgrade to previous release
Rem =========================================================================

SET SERVEROUTPUT OFF
SET VERIFY ON
WHENEVER SQLERROR CONTINUE

SELECT dbms_registry_sys.time_stamp('DWGRD_BGN') AS timestamp FROM DUAL;

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade installed components to previous release
Rem =========================================================================

Rem =========================================================================
Rem Collect indextype names for later recompiles
Rem =========================================================================

create table ityp$temp1
  (ityp_own varchar2(128), ityp_nam varchar2(128), 
   typ_own varchar2(128), typ_nam varchar2(128));

-- get the indextypes and their implementation types and insert into the
-- temporary table

insert into ityp$temp1
  (select u1.name ityp_own, o1.name ityp_nam, u2.name typ_own, o2.name typ_nam 
       from  obj$ o1, obj$ o2, user$ u1, user$ u2, indtypes$ ityp
       where o1.type# = 32 and o1.obj# = ityp.obj# and
       o1.owner# = u1.user# and ityp.implobj# = o2.obj#
       and o2.owner# = u2.user#);

Rem =========================================================================
Rem          Remove scheduler java-related code
Rem =========================================================================

DECLARE
   is_javavm_here NUMBER:=0;
   vstring        VARCHAR2(80);
BEGIN
   EXECUTE IMMEDIATE 'select count(1) from sys.dba_registry
   where comp_id=''JAVAVM''' INTO is_javavm_here;
   IF is_javavm_here=1 THEN
      EXECUTE IMMEDIATE 'DROP JAVA SOURCE "schedFileWatcherJava"';
      EXECUTE IMMEDIATE 'DROP JAVA SOURCE "dbFWTrace"';
      vstring:='sys.dbms_java.dropjava(''-s rdbms/jlib/schagent.jar'')';
      EXECUTE IMMEDIATE ('BEGIN '||vstring ||'; END;');
   END IF;
   EXCEPTION
   WHEN OTHERS THEN RAISE;
END;
/


Rem =========================================================================
Rem Downgrade Components 
Rem =========================================================================

@@cmpdwgrd.sql

Rem =========================================================================
Rem END STAGE 2: downgrade installed components to previous release
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 3: downgrade actions always performed
Rem =========================================================================

Rem Truncate export actions tables (reloaded during catrelod.sql)
truncate table noexp$;
truncate table exppkgobj$;
truncate table exppkgact$;
truncate table expdepobj$;
truncate table expdepact$;

Rem Drop dbms_rcvman (refers to new fixed views)
drop package dbms_rcvman;


Rem #(24309782) Mark all the tables whose stats updated after upgrade as stale
Rem When user gather stats for them after downgrade using GATHER STALE option,
Rem the stats will be regathered using the downgraded version of the dbms_stats
Rem package.

merge into sys.mon_mods_all$ m
using (
  select /*+ leading(tab) dynamic_sampling(4) dynamic_sampling_est_cdn  */
    tab.obj# obj#, 0 inserts, 0 updates, 0 deletes, sysdate timestamp,
    1 flags, 0 drop_segments
  from
    (select t.obj#,  analyzetime                 /* non-partitioned tables */
     from sys.tab$ t 
     /* Temp tables are volatile. Avoid marking them as stale and get
      * picked up by manually gathering statistics with STALE option where 
      * these tables will not have any data when stats are gathered.
      */
     where bitand(t.property, 4194304+8388608) = 0
     union all                                         /* table partitions */
     select t.obj#,  analyzetime 
     from sys.tabpart$ t 
     union all                              /* table partitions(composite) */
     select t.obj#,  analyzetime 
     from sys.tabcompart$ t 
     union all                                      /* table subpartitions */
     select t.obj#,  analyzetime 
     from sys.tabsubpart$ t 
    ) tab, obj$ o
  /* get tables or sub(partitions) analyzed since last upgrade */
  where tab.analyzetime >
    (select max(action_time)
     from sys.registry$history 
     where action = 'UPGRADE')
    and tab.obj# = o.obj# 
    and bitand(o.flags, 128) != 128                  /* not in recycle bin */
) v on (m.obj# = v.obj#)
when matched then
  /* set stats as truncated */
  update set flags = flags - bitand(flags,1) + 1
when NOT matched then
  insert values
    (v.obj#, v.inserts, v.updates, v.deletes, v.timestamp,
     v.flags, v.drop_segments);

commit;

Rem =========================================================================
Rem END STAGE 3: downgrade actions always performed
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 4: downgrade dictionary to specified release
Rem =========================================================================

Rem First the "f" script is run which contains downgrade actions that
Rem call PL/SQL packages. These downgrade actions must be executed
Rem prior to running the "e" downgrade script in case the dropping of 
Rem dependent objects causes the packages to become invalid. 
Rem
Rem If your downgrade code references PL/SQL packages then update the "f" 
Rem downgrade_file to include these actions.
Rem

@@f&downgrade_file

Rem ====================================================================
Rem update version in container$
Rem ====================================================================
EXECUTE dbms_pdb.update_version();

Rem Remove all DataPump objects including all Metadata API types
@@catnodpall

Rem Downgrade dictionary objects
Rem The "e" downgrade file contains actions to downgrade data dictionary 
Rem objects. Code in the "e" downgrade script should not reference any
Rem PL/SQL packages.
Rem

@@e&downgrade_file

Rem =========================================================================
Rem Recompile any invalid indextypes to update object numbers
Rem with  ALTER INDEXTYPE ... USING
Rem =========================================================================

DECLARE
   cursor find_invld_idxtyp IS
              SELECT t.ityp_own, t.ityp_nam, t.typ_own, t.typ_nam
              FROM obj$ o, user$ u, ityp$temp1 t
              WHERE t.ityp_own = u.name and u.user# = o.owner#
                    and o.name = t.ityp_nam and o.status >1;
   alt_idxtyp_sql VARCHAR2(300);
   alt_typ_sql    VARCHAR2(300);

BEGIN
   FOR rec IN find_invld_idxtyp LOOP
        alt_typ_sql := 'ALTER TYPE ' || rec.typ_own || '.' 
                        || rec.typ_nam ||
                        ' COMPILE REUSE SETTINGS';
        alt_idxtyp_sql := 'ALTER INDEXTYPE ' || rec.ityp_own || '.' ||
                             rec.ityp_nam || ' USING ' || rec.typ_own ||
                          '.' || rec.typ_nam;
        BEGIN
           EXECUTE IMMEDIATE alt_typ_sql;
           EXECUTE IMMEDIATE alt_idxtyp_sql;
        EXCEPTION
           WHEN OTHERS THEN NULL;
        END;
   END LOOP;
END;
/

DROP TABLE ityp$temp1;

-- Project 47829: update/delete READ access in access$
declare
  cursor c1 is
    select a1.d_obj#, a1.order# from sys.access$ a1, sys.access$ a2
    where a1.d_obj# = a2.d_obj# and a1.order# = a2.order#
    and a1.types != a2.types and a1.types = 17 and a2.types = 9;
  priv_record c1%rowtype;
begin
  if '&CAT_PRV_VERSION' IN ('11.2.0.3','11.2.0.4','12.1.0.1') then
    open c1;
    loop
      fetch c1 into priv_record;
      exit when c1%NOTFOUND;
      delete from sys.access$ a
        where a.d_obj# = priv_record.d_obj#
        and a.d_obj# not in (select obj# from sys.obj$ where type# = 23)
        and a.order# = priv_record.order#
        and a.types = 17;
      commit;
    end loop;
    close c1;
    update sys.access$ a set a.types = 9 where a.types = 17
      and a.d_obj# not in (select obj# from sys.obj$ where type# = 23);
    commit;
  end if;
end;
/

Rem**************************************************************************
Rem BEGIN BUG 25879441: revert make default_pwd$ a data link
Rem**************************************************************************
update obj$ set flags=flags-bitand(flags,196608)+65536
 where name='DEFAULT_PWD$' and owner#=0 and type#=2;
commit;
alter system flush shared_pool;

Rem**************************************************************************
Rem END BUG 25879441: revert make default_pwd$ a data link
Rem**************************************************************************

Rem**************************************************************************
Rem BEGIN RTI 20613555: remove DBMS_PREUP
Rem**************************************************************************
DROP PACKAGE SYS.DBMS_PREUP;
Rem**************************************************************************
Rem END RTI 20613555: remove DBMS_PREUP
Rem**************************************************************************

Rem =========================================================================
Rem END STAGE 4: downgrade dictionary to specified release
Rem =========================================================================

Rem put timestamps into spool log,registry$history, and registry$log
INSERT INTO registry$log (cid, namespace, operation, optime)
       VALUES ('DWGRD_END','SERVER',-1,SYSTIMESTAMP);
INSERT INTO registry$history (action_time, action)
        VALUES(SYSTIMESTAMP,'DOWNGRADE');
COMMIT;
SELECT 'COMP_TIMESTAMP DWGRD_END ' || 
        TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ')  || 
        TO_CHAR(SYSTIMESTAMP,'J SSSSS ')
        AS timestamp FROM DUAL;

Rem =========================================================================
Rem Downgrade bootstrap tables, Only do for 12.1 and below.
Rem =========================================================================

VARIABLE utilmmig_name VARCHAR2(256)                   
COLUMN  :utilmmig_name NEW_VALUE  utilmmig_file NOPRINT

DECLARE

 p_prv_version sys.registry$.prv_version%type;

BEGIN

  --
  -- Call utlmmigdown.sql if downgrading to an 11.2.0.x.0 database.
  -- Call utlmmigdown121.sql if downgrading to a 12.1 database.
  -- No conversion needed if the prior release was 12.2.
  --

  --
  -- Default to 11.2 migration
  --
  IF '&CAT_PRV_VERSION' IN ('11.2.0.3','11.2.0.4') THEN
      :utilmmig_name := '@utlmmigdown.sql';
  --
  -- Downgrade to 12.1 call 12.1 migration
  --
  ELSIF '&CAT_PRV_VERSION' IN ('12.1.0.1','12.1.0.2') THEN
      :utilmmig_name := '@utlmmigdown121.sql';
  --
  -- Downgrade to 12.2 no migration
  --
  ELSE
      :utilmmig_name := '@nothing.sql';
  END IF;

END;
/
Rem =========================================================================
Rem Truncate registry$upg_resume table, We want to start fresh on every upgrade. 
Rem =========================================================================

TRUNCATE  table registry$upg_resume;

SELECT :utilmmig_name FROM SYS.DUAL;
@&utilmmig_file

Rem =======================================================================
Rem To mark the end of catdwgrd.sql
Rem =======================================================================
INSERT INTO registry$log (cid, namespace, operation, optime)
       VALUES ('CATDWGRD_END','SERVER',-1,SYSTIMESTAMP);
COMMIT;

alter session set "_pdb_first_script"=FALSE;
@?/rdbms/admin/sqlsessend.sql

Rem ***********************************************************************
Rem END catdwgrd.sql
Rem ***********************************************************************

