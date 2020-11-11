Rem
Rem $Header: rdbms/admin/catpend.sql /main/37 2017/04/28 12:03:07 akruglik Exp $
Rem
Rem catpend.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpend.sql - CATProc END
Rem
Rem    DESCRIPTION
Rem      This script runs the final actions for catproc.sqll
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql.
Rem      It is run with catctl.pl as a  single process phase.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catpend.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catpend.sql
Rem SQL_PHASE: CATPEND
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    akruglik    04/17/17 - Lrg 20215745: avoid using regular expression
Rem                           operator when checking for XDB being set in
Rem                           _no_catalog parameter as it can cause the server
Rem                           to hang
Rem    anupkk      03/30/17 - Bug 25406198: do not set 0x10 flag in ASTATUS
Rem                           column of user$ for users without passwords
Rem    akruglik    03/13/17 - XbranchMerge akruglik_noxdb from st_rdbms_pt-dwcs
Rem    raeburns    03/05/17 - Bug 25491041: Separate upgrade error checking 
Rem                           from validation routines for CATALOG/CATPROC
Rem    akruglik    02/28/17 - do not run catqm.sql if XDB schema should not 
Rem                           be created
Rem    nlee        02/22/17 - Bug 23294337: Add a new PL/SQL block to invoke
Rem                           'catclust.sql' if RAC is not loaded.
Rem    dcolello    11/15/15 - move prvtgwm.sql to catxrd.sql
Rem    yanchuan    09/10/15 - Bug 20366116: set 0x10 flag in ASTATUS column of
Rem                           user$ correctly for database fresh install
Rem    bnnguyen    04/11/15 - bug 20860190: Rename 'EXADIRECT' to 'DBSFWUSER'
Rem    jorgrive    03/23/15 - add catggshard
Rem    raeburns    03/11/15 - add EXADIRECT to ancillary schemas
Rem    raeburns    12/20/14 - Bug 20088724: complete CATPROC schemas
Rem    cderosa     12/03/14 - Add call to execlmnr.sql to set statistics
Rem                           preferences and gather initial stats on logminer
Rem                           dictionary tables.
Rem    jlingow     09/03/14 - proj-58146 adding remote_scheduler_agent schema 
Rem    raeburns    08/20/14 - Always run XDB install after catproc completes
Rem    jerrede     03/10/14 - Move Validate CATPROC to end of file.
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      07/02/13 - bug 17024953: remove create_cdbviews
Rem    ssonawan    07/12/12 - bug 13843068: add changes required for Default
Rem                           Password Scanner tool
Rem    nbenadja    06/21/12 - Add prvtgwm.sql and catgwmcat.sql
Rem    gravipat    05/14/12 - create_cdbviews is now part of CDBView package
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jerrede     02/10/12 - Fix lrg 6728115 Incorrectly marking RDBMS status
Rem                           during a create database
Rem    jerrede     11/02/11 - Fix bug 13252372
Rem    dgraj       10/30/11 - Project 32079: Add script for TSDP
Rem    cmlim       08/28/11 - mandatory xdb: invoke catqm.sql during install
Rem                           only
Rem    mjstewar    06/22/11 - Add GSM schema to schema list
Rem    gravipat    05/09/11 - DB Consolidation: create cdb views during db
Rem                           creation
Rem    jibyun      02/28/11 - Project 5687: Invoke catadmprvs.sql
Rem    pyoun       01/16/09 - bug 7653375 add random salt confounder
Rem    shiyer      03/26/08 - Remove TSMSYS schema
Rem    dsemler     02/07/08 - Add APPQOSSYS schema to schema list
Rem    achoi       02/01/08 - add DIP, ORACLE_OCM
Rem    rburns      01/19/07 - add package reset
Rem    rburns      08/28/06 - move sql_bind_capture
Rem    mzait       06/15/06 - add TSMSYS to the registry
Rem    rburns      05/22/06 - add timestamp 
Rem    rburns      01/13/06 - split catproc for parallel upgrade 
Rem    rburns      01/13/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

------------------------------------------------------------------------------

Rem
Rem [g]v$sql_bind_capture
Rem   must be create here since it has a dependency with AnyData type
-- should be included in some other script
-- causes hang in catpdeps.sql
Rem
create or replace view v_$sql_bind_capture as select * from o$sql_bind_capture;
create or replace public synonym v$sql_bind_capture for v_$sql_bind_capture;
grant select on v_$sql_bind_capture to select_catalog_role;

create or replace view gv_$sql_bind_capture as select * from go$sql_bind_capture;
create or replace public synonym gv$sql_bind_capture for gv_$sql_bind_capture;
grant select on gv_$sql_bind_capture to select_catalog_role;

Rem Reset the package state of any packages used during catproc.sql
execute DBMS_SESSION.RESET_PACKAGE; 

Rem
Rem add random salt confounder for bug 7653375
Rem
insert into props$
    (select 'NO_USERID_VERIFIER_SALT', RAWTOHEX(sys.DBMS_CRYPTO.RANDOMBYTES (16)),
NULL from dual
     where 'NO_USERID_VERIFIER_SALT' NOT IN (select name from props$));


Rem
Rem Invoke catadmprvs.sql
Rem
@@catadmprvs.sql

SET SERVEROUTPUT ON

Rem
Rem Invoke catgwmcat.sql
Rem
@@catgwmcat.sql

Rem
Rem OGG sharding schema
Rem
@@catggshard.sql

Rem
Rem Invoke execlmnr.sql
Rem Gather stats on Logminer Dictionary tables to initialize incremental
Rem stats mode
Rem
@@execlmnr.sql

---------------------------
-- Default Password Scanner
----------------------------
-- Since 10G verifiers of default accounts will eventually be removed from
--   default-pwd$, we use 0x10 flag in ASTATUS column of user$ to indicate
--   default accounts who are using default passwords.
-- Hence this ASTATUS column flag should be set correctly, in all scenarios -
--   (a) Upgrade, (b) Fresh Install, (c) Password change & (d) Account creation
-- DBA_USERS_WITH_DEFPWD view definition will use only this flag to project
--   the required list of default accounts using default passwords.

  -- Fresh DB Install: set 0x10 flag for default accounts, who are 
  --                   using default passwords
  -- DB Upgrade: set 0x10 flag for default accounts, who are 
  --             using default passwords in pre-12.1 DB
  -- Bug 25406198: Do not set 0x10 flag in ASTATUS column of user$ for users
  -- created without passwords
  update user$ set astatus=(astatus + 16 - BITAND(astatus,16))
     where name in (select name from user$, default_pwd$ 
                    where name=user_name
                      AND (bitand(spare1,65536) != 65536)
                      AND ( (pv_type = 0 AND password=pwd_verifier)
                          OR pv_type = 1 ));

  -- Delete default accounts entries from default_pwd$, which contain 10G
  --   verifiers and for which accounts SHA-1 hash has already added.
  -- Since default_pwd$ has SHA-1 hash for such accounts, 10G verifiers are no
  --   longer needed and they should be deleted.
  delete from default_pwd$ dp
    where dp.pv_type=0 and
          dp.user_name IN (select user_name from default_pwd$ where pv_type=1);

  -- At this point, some default accounts would not have SHA-1 hash and hence
  --   their 10G verifiers are preserved in default_pwd$. 
  -- Since such accounts are using non-trivial default passwords, we need to
  --   check with their product owners for generating and adding SHA-1 hash
  --   into default_pwd$.
  COMMIT;

Rem
Rem
Rem
Rem
Rem NOTE: THIS IS THE LAST STEP IN THE INSTALL
Rem       THERE SHOULD BE NO CODE ADDED BEYOND THIS POINT.
Rem
Rem
Rem Indicate CATPROC load complete and check validity
Rem

BEGIN
   -- Add all the ancillary schemas for CATPROC
   dbms_registry.update_schema_list('CATPROC',
        dbms_registry.schema_list_t('SYSTEM', 'OUTLN', 'DBSNMP', 'DIP',
                'AUDSYS', 'GSMCATUSER', 'GSMUSER', 'GSMADMIN_INTERNAL',
                'SYS$UMF', 'SYSBACKUP', 'SYSDG', 'SYSKM', 'SYSRAC', 
                'DBSFWUSER',
                'ORACLE_OCM', 'APPQOSSYS', 'REMOTE_SCHEDULER_AGENT',
                'GGSYS'));
   IF sys.dbms_registry.is_loaded('CATPROC') IS NULL THEN
   -- Only validate on initial install, not on any subsequent reruns
   -- CATALOG and CATPROC will be re-validated when utlrp.sql is run
      sys.dbms_registry.loaded('CATPROC');
      sys.dbms_registry_sys.validate_catproc;
      sys.dbms_registry_sys.validate_catalog;
   ELSE
      sys.dbms_registry.loaded('CATPROC');
   END IF;
END;
/

commit;
SELECT dbms_registry_sys.time_stamp('CATPROC') AS timestamp FROM DUAL;  


SET SERVEROUTPUT OFF

Rem  -----------------------------------------------------------------------
Rem Invoke catqm.sql to install XDB if it is not in the DB.
Rem Do not run catqm.sql if XDB schema should not be created
Rem  -----------------------------------------------------------------------

VARIABLE dbinst_name VARCHAR2(256)
COLUMN :dbinst_name NEW_VALUE dbinst_file NOPRINT

DECLARE
  temp_ts        dba_users.temporary_tablespace%TYPE;  -- temporary tablespace name
  xdb_ts         dba_users.default_tablespace%TYPE;  -- name of tablespace to install XDB in
  exclude_xdb number;  -- should XDB-related schema objects not be created
BEGIN
  select count(*) into exclude_xdb from v$parameter 
    where name='_no_catalog' and 
          (value = 'XDB' or value like 'XDB,%' or value like '%,XDB' or 
           value like '%,XDB,%');
  IF (dbms_registry.is_loaded('XDB') IS NULL and exclude_xdb = 0) THEN
     xdb_ts := 'SYSAUX';

     SELECT temporary_tablespace INTO temp_ts FROM dba_users
            WHERE username='SYS'; -- use SYS temporary tablespace
     :dbinst_name := dbms_registry_server.XDB_path ||
                     'catqm.sql XDB ' || xdb_ts || ' ' || temp_ts || ' YES';
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/

SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SET SERVEROUTPUT OFF

Rem  -----------------------------------------------------------------------
Rem Invoke catclust.sql to install RAC if it is not in the DB.
Rem  -----------------------------------------------------------------------

VARIABLE dbinst_name VARCHAR2(256)
COLUMN :dbinst_name NEW_VALUE dbinst_file NOPRINT

BEGIN
  IF (dbms_registry.is_loaded('RAC') IS NULL) THEN
     :dbinst_name := dbms_registry_server.RAC_path ||
                     'catclust.sql';
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/

SELECT :dbinst_name FROM DUAL;
@&dbinst_file

@?/rdbms/admin/sqlsessend.sql
