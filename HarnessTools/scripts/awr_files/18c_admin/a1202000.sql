Rem
Rem a1202000.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      a1202000.sql - additional ANONYMOUS BLOCK dictionary upgrade
Rem                     making use of PL/SQL packages installed by
Rem                     catproc.sql.
Rem
Rem    DESCRIPTION
Rem      Additional upgrade script to be run during the upgrade of an
Rem      12.2.0 database to the new release.
Rem
Rem      This script is called from catupgrd.sql and a1201000.sql
Rem
Rem      Put any anonymous block related changes here.
Rem      Any dictionary create, alter, updates and deletes
Rem      that must be performed before catalog.sql and catproc.sql go
Rem      in "c" script.
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
Rem SQL_SOURCE_FILE: rdbms/admin/a1202000.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/a1202000.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupprc.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yunkzhan    11/22/17 - XbranchMerge yunkzhan_bug-27084613 from main
Rem    yunkzhan    11/16/17 - Bug 27084613 - restore missing index data in
Rem                           logmnrc_ind_gg table
Rem    itaranov    08/25/17 - Update SHARDING hash range def
Rem    sroesch     07/03/17 - Bug 26272761: Fix service$ table during upgrade
Rem    amunnoli    06/23/17 - Bug 26040105: Update ORA_CIS_RECOMMENDATIONS
Rem    raeburns    06/13/17 - RTI 20258949: TSMSYS still exists in 12.1.0.1
Rem                           databases
Rem    msabesan    04/24/17 - bug 25927752: revoke exec privs from sysumf_role
Rem    smangala    03/21/17 - bug 24926757: circular transaction queue
Rem    raeburns    03/09/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    rthatte     02/03/17 - Bug 23753068: Reduce privileges to AUDIT_ADMIN
Rem    jnunezg     02/08/17 - BUG 25422950: Remove FW job and program on upgrade
Rem    mmcracke    12/02/16 - #(24958335) ODM 12.2.0.2 upgrade
Rem    yanlili     11/16/16 - Bug 24799459: Support 12.1.0.1 Salted SHA1 as
Rem                           Legacy SSHA1 for XS direct logon user    
Rem    welin       08/31/16 - bug 24555134: remove apex orphaned synonyms
Rem    welin       06/03/16 - Created
Rem

Rem *************************************************************************
Rem BEGIN a1202000.sql
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN STAGE 1: upgrade from 12.2 to the current release
Rem =========================================================================

Rem *************************************************************************
Rem BEGIN BUG 24555134: remove apex orphaned synonyms
Rem *************************************************************************
BEGIN
  IF sys.dbms_registry.is_loaded('APEX') IS NULL THEN
    execute immediate 'drop public synonym APEX_PKG_APP_INSTALL_LOG';
    execute immediate 'drop public synonym APEX_SPATIAL';
  END IF;
  commit;
END;
/
Rem *************************************************************************
Rem END BUG 24555134: remove apex orphaned synonyms
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 24926757: circular transaction queue
Rem *************************************************************************
begin
  sys.dbms_logmnr_internal.agespill_122to12202;
end;
/
Rem *************************************************************************
Rem BEGIN END 24926757: circular transaction queue
Rem *************************************************************************

Rem ====================================================================
Rem Begin Bug 24799459
Rem ====================================================================

Rem
Rem Support 12.1.0.1 SSHA1 verifier as Legacy SSHA1 for existing RAS 
Rem direct logon user. Change SSHA1 type to Legacy SSHA1 type.
Rem

DECLARE
CURSOR xs_ssha1_verifiers IS
select user#, verifier from sys.xs$verifiers where type# = 1;
BEGIN
FOR xs_ssha1_verifiers_crec IN xs_ssha1_verifiers LOOP
  update xs$verifiers set verifier = 'R:'||xs_ssha1_verifiers_crec.verifier, type#=3 where user#=xs_ssha1_verifiers_crec.user#;
END LOOP;
END;
/

Rem ====================================================================
Rem End Bug 24799459
Rem ====================================================================

Rem =====================
Rem Begin ODM changes
Rem =====================

Rem  ODM model upgrades (specify upgrade to version)
exec dmp_sys.upgrade_models('12.2.0.2');
/

Rem =====================
Rem End ODM changes
Rem =====================

Rem *************************************************************************
Rem BEGIN Bug 23753068: revoke select , grant read to AUDIT_ADMIN
Rem *************************************************************************

revoke select on DBA_OBJECTS from AUDIT_ADMIN;
revoke select on DBA_OBJECTS_AE from AUDIT_ADMIN;
revoke select on DBA_USERS from AUDIT_ADMIN;
revoke select on DBA_ROLES from AUDIT_ADMIN;
revoke select on SYS.CDB_ROLES from AUDIT_ADMIN;
grant read on DBA_OBJECTS to AUDIT_ADMIN;
grant read on DBA_OBJECTS_AE to AUDIT_ADMIN;
grant read on DBA_USERS to AUDIT_ADMIN;
grant read on DBA_ROLES to AUDIT_ADMIN;
grant read on SYS.CDB_ROLES to AUDIT_ADMIN;

Rem *************************************************************************
Rem END Bug 23753068: revoke select , grant read to AUDIT_ADMIN
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN changes for Scheduler new dbms_ischedfw package
Rem *************************************************************************
-- Drop File watcher job and program

BEGIN
  dbms_scheduler.disable('SYS.FILE_WATCHER', TRUE);
  dbms_scheduler.stop_job('SYS.FILE_WATCHER', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 or sqlcode = -27476 THEN
    NULL; -- Supress job not running (27366), "does not exist" (27476)
  ELSE
    raise;
  END IF;
END;
/

BEGIN
  dbms_scheduler.drop_job('SYS.FILE_WATCHER', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27475 THEN
    NULL; -- Supress "unknown job" error
  ELSE
    raise;
  END IF;
END;
/

BEGIN
  dbms_scheduler.drop_program('SYS.FILE_WATCHER_PROGRAM');
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27476 THEN
    NULL; -- Supress program des not exist
  ELSE
    raise;
  END IF;
END;
/

Rem *************************************************************************
Rem END changes for Scheduler new dbms_ischedfw package
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 25927752: revoke EXECUTE ON dbms_sqltune_internal 
Rem *************************************************************************

revoke execute on dbms_sqltune_internal from sysumf_role;

Rem *************************************************************************
Rem END  Bug 25927752: revoke EXECUTE ON dbms_sqltune_internal 
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 26040105: UPDATE ORA_CIS_RECOMMENDATIONS AUDIT POLICY
Rem *************************************************************************

BEGIN
  EXECUTE IMMEDIATE 'ALTER AUDIT POLICY ORA_CIS_RECOMMENDATIONS ADD '||
  'ACTIONS ALTER SYNONYM, CREATE FUNCTION, CREATE PACKAGE, ' ||
  'CREATE PACKAGE BODY, ALTER FUNCTION, ALTER PACKAGE, ALTER SYSTEM, ' ||
  'ALTER PACKAGE BODY, DROP FUNCTION, DROP PACKAGE, DROP PACKAGE BODY, ' ||
  'CREATE TRIGGER, ALTER TRIGGER, DROP TRIGGER ' ||
  'DROP PRIVILEGES CREATE ANY LIBRARY, ' ||
  'DROP ANY LIBRARY, CREATE ANY TRIGGER, ALTER ANY TRIGGER, ' ||
  'DROP ANY TRIGGER';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN (-46357) THEN NULL; -- ignore policy not found error
      ELSE RAISE;
      END IF;
END;
/

Rem *************************************************************************
Rem END BUG 26040105: UPDATE ORA_CIS_RECOMMENDATIONS AUDIT POLICY
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN  RTI 20258949: TSMSYS still exists in 12.1.0.1 databases
Rem *************************************************************************

DROP USER TSMSYS CASCADE;

Rem *************************************************************************
Rem END  RTI 20258949: TSMSYS still exists in 12.1.0.1 databases
Rem *************************************************************************

UPDATE DBA_SERVICES SET NAME_HASH = DBMS_SERVICE_PRVT.GET_HASH(NAME);
COMMIT;

Rem *************************************************************************
Rem BEGIN BUG 26544479: Sharding hash range definitions
Rem *************************************************************************

update gsmadmin_internal.chunks
  set high_key=4294967296, bhiboundval='06C52B5F614961'
  where high_key=4294967295;

update gsmadmin_internal.all_chunks
  set high_key=4294967296
  where high_key=4294967295;

update tabcompart$
  set hiboundval='4294967296', bhiboundval = '06C52B5F614961'
  where obj# in (select t1.obj# as part_obj_no 
    from sys.tabcompart$ t1 
      left join sys.tabcompart$ tmax 
        on (t1.bo#=tmax.bo# and t1.part# < tmax.part#)
      join sys.tab$ t3 on (t1.bo#=t3.obj#)
    where tmax.part# is null and t1.hiboundval is not null
      and t1.hiboundlen = 10 and bitand(t3.property/power(2, 75), 1) = 1);

update tabpart$
  set hiboundval='4294967296', bhiboundval = '06C52B5F614961'
  where obj# in (select t1.obj# as part_obj_no 
    from sys.tabpart$ t1 
      left join sys.tabpart$ tmax 
        on (t1.bo#=tmax.bo# and t1.part# < tmax.part#)
      join sys.tab$ t3 on (t1.bo#=t3.obj#)
    where tmax.part# is null and t1.hiboundval is not null
      and t1.hiboundlen = 10 and bitand(t3.property/power(2, 75), 1) = 1);

update indcompart$
  set hiboundval='4294967296'
  where obj# in (select t1.obj# as part_obj_no 
    from sys.indcompart$ t1 
      left join sys.indcompart$ tmax 
        on (t1.bo#=tmax.bo# and t1.part# < tmax.part#)
      join sys.ind$ t2 on (t1.bo#=t2.obj#) join sys.tab$ t3 on (t2.bo#=t3.obj#)
    where tmax.part# is null and t1.hiboundval is not null 
      and t1.hiboundlen = 10 and bitand(t3.property/power(2, 75), 1) = 1);

update indpart$
  set hiboundval='4294967296'
  where obj# in (select t1.obj# as part_obj_no 
    from sys.indpart$ t1 
      left join sys.indpart$ tmax 
        on (t1.bo#=tmax.bo# and t1.part# < tmax.part#)
      join sys.ind$ t2 on (t1.bo#=t2.obj#) join sys.tab$ t3 on (t2.bo#=t3.obj#)
    where tmax.part# is null and t1.hiboundval is not null 
      and t1.hiboundlen = 10 and bitand(t3.property/power(2, 75), 1) = 1);

commit;

alter system flush shared_pool;

Rem *************************************************************************
Rem END BUG 26544479: Sharding hash range definitions
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 26544479: Restore missing data in logmnrc_ind_gg table
Rem *************************************************************************

Declare
  -- MINUS operator returns only unique rows returned by the first 
  -- query but not by the second.
  -- Ordering by the commit_scn makes sure that we process the rows in the
  -- right order.
  -- The following cursor will find all the index object which has been cached
  -- in indcol_gg table while missing from ind_gg table.
  cursor find_missing_ind  is
   select logmnr_uid, obj#, commit_scn
    from (     
     select logmnr_uid, obj#, commit_scn
       from system.logmnrc_indcol_gg
     MINUS
     select logmnr_uid, obj#, commit_scn
       from system.logmnrc_ind_gg
    )
  order by commit_scn ASC;

  baseobj#  number;
  baseobjv# number;
  flags     number;
  owner#    number;
  ownername varchar2(384);
  indexname varchar2(384);
  start_scn number;
  
  -- Index flag bits
  KEY_INDEX          CONSTANT NUMBER := 2; /* 0x0002 */
  KEY_DESCENDING     CONSTANT NUMBER := 8; /* 0x0008 */
  KEY_UNIQUE         CONSTANT NUMBER := 32; /* 0x0020 */

Begin
  /*
   * Find all the index object that missing information in ind_gg table.
   * If we have information from the frontier and cache table, 
   * re-populate the ind_gg table.
   * Otherwise, remove the rows from indcol_gg table.
   */
  for obj_rec in find_missing_ind  loop
    -- Find the metadata for this index.
    begin
      -- Look for baseobj#, flags and start_scn
      -- baseobjv#, owner# and ownername from gtlo
      select i.bo#, o.name, g.baseobjv#, g.owner#, g.ownername,
             (KEY_INDEX +
              decode(bitand(i.property,1),1,KEY_UNIQUE,0) +
              decode(bitand(c.property,131072),131072, KEY_DESCENDING,0)
              ) ind_flags,
             (o.start_scnwrp * 4294967296 + o.start_scnbas) start_scn
        into baseobj#, indexname, baseobjv#, owner#, ownername,
             flags, start_scn
        from system.logmnr_ind$ i,
             system.logmnr_obj$ o,
             system.logmnrc_gtcs c,
             system.logmnrc_gtlo g
       where c.logmnr_uid = obj_rec.logmnr_uid
         and i.logmnr_uid = c.logmnr_uid
         and o.logmnr_uid = c.logmnr_uid
         and g.logmnr_uid = c.logmnr_uid
         and g.keyobj#    = i.bo#
         and i.obj#       = obj_rec.obj#
         and i.obj#       = o.obj#
         and c.obj#       = i.bo#
         and c.objv#      = g.baseobjv#
         and start_scn <= obj_rec.commit_scn
         and g.start_scn <= obj_rec.commit_scn
         and (g.drop_scn  > obj_rec.commit_scn or g.drop_scn is NULL)
         and ROWNUM       = 1;

      -- Update prior version
      -- Only commit_scn is available from the indcol_gg table.
      -- The logic here is similar to fast start caching.
      update system.logmnrc_ind_gg ind
         set ind.drop_scn   = obj_rec.commit_scn
       where ind.logmnr_uid = obj_rec.logmnr_uid
         and ind.obj#       = obj_rec.obj#
         and ind.commit_scn < obj_rec.commit_scn
         and ind.drop_scn   is NULL;

       -- Insert the metadata of the current version, drop scn will be NULL
       -- The drop_scn of the lastest version will be updated in add_ind_obj.
       -- The logic here is similar to fast start caching.
       insert into system.logmnrc_ind_gg(
             logmnr_uid,
             obj#,
             flags,
             name,
             baseobj#,
             baseobjv#,
             commit_scn,
             drop_scn,
             owner#,
             ownername
             ) 
            values (
             obj_rec.logmnr_uid, 
             obj_rec.obj#,
             flags,
             indexname,
             baseobj#,
             baseobjv#,
             obj_rec.commit_scn,
             NULL,
             owner#, 
             ownername
             );

    exception 
      when no_data_found then
        -- Cannot resolve the metadata of the index
        -- Remove all the indcols from indcol_gg table.
        delete from system.logmnrc_indcol_gg
        where logmnr_uid = obj_rec.logmnr_uid
          and       obj# = obj_rec.obj#
          and commit_scn = obj_rec.commit_scn;
      when dup_val_on_index then
        -- Highly unlikely this would happen, but just in case.
        update system.logmnrc_ind_gg
           set flags      = flags,
               name       = indexname,
               baseobj#   = baseobj#,
               baseobjv#  = baseobjv#,
               drop_scn   = NULL,
               owner#     = owner#,
               ownername  = ownername
         where logmnr_uid = obj_rec.logmnr_uid AND
               obj#       = obj_rec.obj# AND
               commit_scn = commit_scn;
    end;
  end loop;

commit;
end;
/

Rem *************************************************************************
Rem END BUG 26544479: Restore missing data in logmnrc_ind_gg table
Rem *************************************************************************



---------- ADD UPGRADE ACTIONS ABOVE THIS LINE ---------------

Rem =========================================================================
Rem END STAGE 1: upgrade from 12.2 to the current release
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

-- @@axxxxxxx.sql

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END a1202000.sql
Rem *************************************************************************

