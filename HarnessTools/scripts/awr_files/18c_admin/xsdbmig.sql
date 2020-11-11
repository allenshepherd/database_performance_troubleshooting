Rem
Rem $Header: rdbms/admin/xsdbmig.sql /main/12 2017/05/28 22:46:14 stanaya Exp $
Rem
Rem xsdbmig.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsdbmig.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xsdbmig.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xsdbmig.sql
Rem    SQL_PHASE: XSDBMIG
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/11/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         04/01/16 - #22956970: keep XMLDIR in the root
Rem    yiru        01/08/16 - Fix lrg 18858485: do not run u/a script if 
Rem                           upgrade is complete during rerun
Rem    minx        09/20/12 - Remove xsrelod
Rem    rpang       03/01/12 - Invoke xsa112.sql in upgrade from 11.2
Rem    yiru        09/01/11 - Fix lrg 5472611,bug 12778018:add 11.2 upgrade
Rem    rburns      10/02/07 - add 11.1 upgrade
Rem    pthornto    10/09/06 - Main migration/upgrade file for Xtensible
Rem                           Security
Rem    pthornto    10/09/06 - Created
Rem

Rem ============================================================
Rem    Initialize environment for XS upgrade
Rem ============================================================

-- Initialize ResConfig before proceeding
-- is this necessary?
call xdb.dbms_xdbz0.initXDBResConfig();

-- temp load package and create directory
-- move xdbdbmig in restructure
@@catxdbh
exec dbms_metadata_hack.cre_dir;
exec dbms_metadata_hack.cre_xml_dir;

Rem ============================================================
Rem Determine which release is being upgraded
Rem and set upgrade script name
Rem ============================================================

VARIABLE xs_version VARCHAR2(30);
VARIABLE xs_status  VARCHAR2(30);
VARIABLE xsu_script VARCHAR2(30);
VARIABLE xsa_script VARCHAR2(30);
VARIABLE xsreload_script VARCHAR2(30);

DECLARE
   xdb_version       registry$.version%type;
   xdb_prv_version   registry$.prv_version%type;
   xdb_version_before_upgrade registry$.prv_version%type;
BEGIN
   -- check that XDB has been upgraded to current version
   SELECT version, prv_version into xdb_version, xdb_prv_version
   FROM registry$ where cid='XDB';

   IF xdb_version = dbms_registry.release_version THEN
     -- XDB has been upgraded to current version, use previous version
     xdb_version_before_upgrade := xdb_prv_version;
   ELSE
     -- XDB not yet current version for some reason, use version
     xdb_version_before_upgrade := xdb_version;
   END IF;
    
   IF sys.dbms_registry.get_progress_value('XDB','XS STATUS') = 
          'COMPLETED 12.2' THEN
     :xsu_script := '@nothing.sql';
     :xsa_script := '@nothing.sql';     
     :xs_status := 'VALID';    
     :xs_version := xdb_version;  
   ELSIF substr(xdb_version_before_upgrade,1,6) = '11.1.0' THEN
     :xs_status := 'VALID';    -- for upgrades from 11.1
     :xs_version := '111';  
     :xsu_script := '@xsu111.sql';
     :xsa_script := '@xsa111.sql';
     :xsreload_script := '@xsrelod.sql';
   ELSIF substr(xdb_version_before_upgrade,1,6) = '10.2.0' OR
         substr(xdb_version_before_upgrade,1,6) = '10.1.0' OR
         substr(xdb_version_before_upgrade,1,5) = '9.2.0'  THEN
     :xs_status := 'VALID';   -- for all upgrades prior to 11.1
     :xs_version := '102';  
     :xsu_script := '@xsu102.sql';
     :xsa_script := '@xsa102.sql';
     :xsreload_script := '@xsrelod.sql';
   ELSIF substr(xdb_version_before_upgrade,1,6) = '11.2.0' THEN
     :xs_status := 'VALID';  -- for upgrades from 11.2
     :xs_version := '112';
     :xsu_script := '@xsu112.sql';
     :xsa_script := '@xsa112.sql';
   ELSE
     :xs_status := 'INVALID'; -- for all upgrades after 11.2
     :xs_version := 'NONE';
     :xsu_script := '@nothing.sql';
     :xsa_script := '@nothing.sql';
   END IF;   
END;
/

exec dbms_output.put_line('version = ' || :xs_version || ' status = ' || :xs_status);

Rem get version being upgraded into xs_file variable
COLUMN :xs_version NEW_VALUE xs_file NOPRINT;
SELECT :xs_version FROM DUAL;
COLUMN :xsu_script NEW_VALUE xsu_file NOPRINT;
SELECT :xsu_script FROM DUAL;
COLUMN :xsa_script NEW_VALUE xsa_file NOPRINT;
SELECT :xsa_script FROM DUAL;
COLUMN :xsreload_script NEW_VALUE xsreload_file NOPRINT;
SELECT :xsreload_script FROM DUAL;

-- set progress value as IN PROGRESS
execute sys.dbms_registry.set_progress_value('XDB','XS STATUS','IN PROGRESS')

Rem Run Fusion security base upgrade script
@&xsu_file

Rem Run Fusion Security post-reload upgrade script
@&xsa_file

-- temporarily drop directories and package
-- move to xdbdbmig.sql
-- #22956970: need keep DIR in the root as common object
-- execute dbms_metadata_hack.drop_dir;
-- execute dbms_metadata_hack.drop_xml_dir;
drop package dbms_metadata_hack;

-- set progress value COMPLETED
execute sys.dbms_registry.set_progress_value ('XDB','XS STATUS','COMPLETED 12.2');
