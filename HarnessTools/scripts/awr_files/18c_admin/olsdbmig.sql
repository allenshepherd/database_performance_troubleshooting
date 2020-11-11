Rem
Rem $Header: rdbms/admin/olsdbmig.sql /main/34 2017/08/25 20:41:45 rtattuku Exp $
Rem
Rem olsdbmig.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olsdbmig.sql - OLS Data Base MIGration script.
Rem
Rem    DESCRIPTION
Rem      olsdbmig.sql performs the upgrade of the OLS component from all 
Rem      prior releases supported for upgrade (817, 901, and 920 for 10i). 
Rem      It first runs the "u" script to upgrade the tables and types
Rem      for OLS and then runs the scripts to load in the new package 
Rem      specifications, views, and package and type bodies,
Rem
Rem    NOTES
Rem      It is called from cmpupgrd.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/olsdbmig.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/olsdbmig.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/cmpupgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rtattuku    06/22/17 - version change from cdilling
Rem    risgupta    06/14/17 - Bug 26246240: Update CONFIGURE_OLS calls
Rem    risgupta    05/08/17 - Bug 26001269: Add SQL_FILE_METADATA
Rem    raeburns    04/08/17 - Change re-run version check for 18.0.0
Rem    anupkk      03/06/17 - Bug 25387289: Call to olsu122.sql added
Rem    risgupta    08/02/16 - Bug 23639570: Update OLS_ENFORCEMENT calls
Rem    anupkk      06/16/16 - Bug 23568287: Remove extra inherit privileges
Rem                           to LBACSYS
Rem    anupkk      04/03/16 - Bug 22917286: Call to olstrig.sql added
Rem    frealvar    03/25/16 - Bug 22695570 Removing references to deprecated
Rem                           packages and constants
Rem    risgupta    11/27/15 - Bug 22267756: Set current schema to LBACSYS
Rem    risgupta    08/27/15 - Lrg 18421763: Move the OLS version check from
Rem                           cmpupnjv.sql
Rem    risgupta    05/05/15 - Bug 20970539: Configure/Enable OLS only if
Rem                           upgrading from version lower than 12.1
Rem    risgupta    05/03/15 - Bug 20069908: remove references to olsu111
Rem    mjgreave    02/23/15 - bug 20352942: change length of file_name1
Rem    risgupta    06/03/14 - Lrg 12142809: Update code to accomodate
Rem                           OLS version change in 12.2
Rem    aramappa    07/29/13 - bug 16593436: invoke olsu121
Rem    risgupta    07/09/13 - Bug 17014227: Rerunnability for OLS upgrade
Rem    jkati       05/11/12 - bug#14002092 : grant inherit any privileges to
Rem                           lbacsys 
Rem    aramappa    11/15/11 - bug 13098014: configure OLS before enable
Rem    yanchuan    10/11/11 - Bug 12776828: admin procedure name changes
Rem    rpang       08/16/11 - Proj 32719: Grant/revoke inherit privileges
Rem    srtata      06/27/11 - 12g upgrade: rearch
Rem    srtata      03/30/11 - add olsu112.sql and support only from 10.2
Rem    srtata      03/02/09 - add olsu102 and olsu111
Rem    srtata      10/30/08 - use upgraded instead of loaded
Rem    srtata      10/15/08 - put back olstrig.sql to postupgrade as certain
Rem                           functionsin the script ned OLS cache to be
Rem                           initialized and DB in a normal mode
Rem    srtata      02/26/08 - move olstrig.sql from catuppst.sql
Rem    cchui       10/08/04 - 3936531: use validate_ols 
Rem    srtata      03/31/04 - check if OID enabled OLS 
Rem    srtata      02/13/04 - add olsu101.sql 
Rem    vpesati     11/25/02 - add server instance check
Rem    srtata      10/16/02 - add olsu920.sql
Rem    rburns      10/31/01 - fix syntax
Rem    shwong      10/26/01 - Merged shwong_upgdng
Rem    shwong      10/26/01 - Created
Rem

VARIABLE upgrade_ols VARCHAR2(5);
COLUMN :file_name NEW_VALUE comp_file NOPRINT
VARIABLE file_name VARCHAR2(30)
COLUMN :file_name1 NEW_VALUE comp_file1 NOPRINT
VARIABLE file_name1 VARCHAR2(30)

Rem Bug 21672325: Invoke dbms_registry_extended.sql to simplify the checks
Rem done below.
@@dbms_registry_basic.sql
@@dbms_registry_extended.sql

Rem LRG 18421763: Move the OLS version check here from cmpupnjv.sql
Rem Bug 21178327: Check whether OLS version is same as RDBMS version, if not
Rem dont upgrade OLS if version not supported for direct upgrade.
SET SERVEROUTPUT ON
DECLARE
catproc_version    sys.registry$.version%type;
ols_version        sys.registry$.version%type;
ols_version_3_dots sys.v$instance.version%type;
BEGIN
  -- Initialize variables
  :upgrade_ols := 'NO';
  :file_name  := sys.dbms_registry.nothing_script;
  :file_name1 := sys.dbms_registry.nothing_script;
  
  -- Lrg 18421763: Check whether OLS is installed
  IF sys.dbms_registry.is_loaded('OLS') IS NOT NULL THEN
    /* Check previous version because CATPROC will be updated by now */
    SELECT prv_version INTO catproc_version FROM sys.registry$
    WHERE cid = 'CATPROC';

    SELECT version INTO ols_version FROM sys.registry$
    WHERE cid = 'OLS';

    /* Truncate OLS version to 3 dots */
    ols_version_3_dots :=
      dbms_registry_extended.convert_version_to_n_dots(ols_version, 3);

    DBMS_OUTPUT.PUT_LINE('Label Security current version is ' ||
                         ols_version_3_dots);

    IF ((ols_version = catproc_version) OR
       (instr(',&C_UPGRADABLE_VERSIONS,',
              ',' || ols_version_3_dots || ',') != 0))
    THEN
      :upgrade_ols := 'YES';
    ELSE
      DBMS_OUTPUT.PUT_LINE('Label Security is not at a version supported ' ||
        'for direct database upgrades. Uninstall Label Security. Refer to' ||
        ' MOS Note 2046002.1 for more details');
    END IF;
  END IF;
END;
/
SET SERVEROUTPUT OFF;

WHENEVER SQLERROR EXIT;
BEGIN
  IF (:upgrade_ols = 'YES') THEN
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON dbms_registry to LBACSYS';
    sys.dbms_registry.check_server_instance;
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;

DECLARE
already_revoked exception;
pragma exception_init(already_revoked,-01927);
p_version SYS.registry$.version%type;

procedure revoke_inherit_privileges(user in varchar2) as
begin
  execute immediate 'revoke inherit privileges on user '||
                      dbms_assert.enquote_name(user)||' from public';

exception
  when already_revoked then null;
end;

BEGIN
  IF (:upgrade_ols = 'YES') THEN
    -- indicate the upgrade process has begun
    sys.dbms_registry.upgrading('OLS', 'Oracle Label Security', 'validate_ols');

    -- Revoke the default grant of INHERIT PRIVILEGES on DIP and LBACSYS
    -- from public.
    revoke_inherit_privileges('dip');
    revoke_inherit_privileges('lbacsys');
    
    IF substr(sys.dbms_registry.version('OLS'),1,6)='11.2.0'
    THEN
      :file_name := 'olsu112.sql';
    -- LRG 12142809: Update code to accomodate OLS version
    -- change in 12.2
    ELSIF substr(sys.dbms_registry.version('OLS'),1,6)='12.1.0'
    THEN
      :file_name := 'olsu121.sql';
    ELSIF substr(sys.dbms_registry.version('OLS'),1,6)='12.2.0'
    THEN
      :file_name := 'olsu122.sql';
    -- Check for rerun 
    ELSIF substr(sys.dbms_registry.version('OLS'),1,7) =
         substr(sys.dbms_registry.release_version,1,7)
      THEN
        BEGIN
          -- Bug 17014227: check if this is a upgrade rerun and
          -- invoke appropriate script
          EXECUTE IMMEDIATE 'select prv_version from registry$
                             where cid = ''OLS'''
                             into p_version;

          IF substr(p_version, 1, 6) = '11.2.0'
          THEN
            :file_name := 'olsu112.sql';
          ELSIF substr(p_version, 1, 6) = '12.1.0'
          THEN
            -- bug 16593436: invoke olsu121 
            :file_name := 'olsu121.sql';
          ELSIF substr(p_version, 1, 6) = '12.2.0'
          THEN
            :file_name := 'olsu122.sql';
          END IF;
        END;
    ELSE
      :file_name := sys.dbms_registry.nothing_script;
    END IF;

    -- Populate variables to recreate OLS packages and views.
    :file_name1 := 'olsload.sql';
  END IF;  
END;
/

-- Bug 22267756: Set current schema to LBACSYS
ALTER SESSION SET CURRENT_SCHEMA = LBACSYS;

-- Upgrade Script
SELECT :file_name FROM DUAL;
@@&comp_file

-- OLS Packages' and Views' Load Script
SELECT :file_name1 FROM DUAL;
@@&comp_file1

-- Bug 22267756: Reset current schema to SYS
ALTER SESSION SET CURRENT_SCHEMA = SYS;

Rem =======================================================================
Rem If OLS is being upgraded, run olstrig.sql to OLS policies to recreate
Rem trigger definitions 
Rem =======================================================================

COLUMN :ols_name NEW_VALUE ols_file NOPRINT;
VARIABLE ols_name VARCHAR2(30)
DECLARE
BEGIN
   IF (:upgrade_ols = 'YES') THEN
      :ols_name := 'olstrig.sql';   -- OLS installed in DB and upgrading
   ELSE
      :ols_name := sys.dbms_registry.nothing_script;   -- No OLS
   END IF;
END;
/
SELECT :ols_name FROM DUAL;
@@&ols_file

DECLARE
    num number;
BEGIN
  IF (:upgrade_ols = 'YES') THEN
    -- Bug 20970539:- Configure and Enable OLS only if upgrading from
    -- version lower than 12.1.
    IF TO_NUMBER((substr(sys.dbms_registry.version('OLS'),1,2))) < 12 THEN
      -- configure OLS
      SYS.configure_ols;

      -- Run the enable procedure
      SYS.OLS_ENFORCEMENT.enable_ols;
    END IF;
   
    sys.dbms_registry.upgraded('OLS');
    -- Use the error log to set the status to invalid if errors occurred
    IF sys.dbms_registry.count_errors_in_registry('OLS') > 0 THEN
      sys.dbms_registry.invalid('OLS');
    END IF;

    commit;
  END IF;
END;
/
