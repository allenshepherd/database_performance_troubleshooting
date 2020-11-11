Rem
Rem $Header: rdbms/admin/catupend.sql /main/38 2017/06/19 08:56:48 amunnoli Exp $
Rem
Rem catupend.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catupend.sql - CATalog UPgrade END
Rem
Rem    DESCRIPTION
Rem      Final scripts for the Complete upgrade
Rem
Rem    NOTES
Rem      Invoked by catupgrd.sql

Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catupend.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catupend.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amunnoli    06/13/17 - Bug 26182029: update audit policies to remove
Rem                           synonym objects
Rem    anighosh    05/30/17 - #(26137367): Request a fresh instantiation
Rem    anighosh    03/28/17 - #(25548765): Drop OLD shadow types, whose
Rem                           KOTTDSGT bit is not set
Rem    raeburns    03/08/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    skayoor     02/03/16 - Bug 22608480: Revoke SELECT from TABLE objects
Rem    skayoor     07/24/15 - Bug 21496928: Revoke select privilege
Rem    molagapp    06/16/15 - bug 21068213
Rem    raeburns    05/18/15 - lrg 16457040 - reset dbms_registry package state
Rem    skayoor     05/06/15 - Bug 20888348: Revoke SELECT privilege
Rem    sanagara    07/15/14 - 18852024: recompile certain synonyms
Rem    yinlu       01/22/14 - bug 18063843: add validate_old_typeversions to
Rem                           pass sanity check
Rem    cxie        08/30/13 - update vsn in container$
Rem    jerrede     01/14/13 - XbranchMerge jerrede_bug-160      
Rem    jerrede     09/11/13 - Add Java Resolve Invalid Classes
Rem    talliu      07/02/13 - delete create_cdbviews
Rem    jerrede     04/01/13 - Do not run utlmmig.sql for patch updates
Rem    jerrede     01/18/13 - Upgrade CDB. Move utilmmig.sql to catupgrd.sql.
Rem    cdilling    11/05/12 - set EDITION for CATPROC - lrg 7333924
Rem    cmlim       11/04/12 - bug 14763826
Rem    gravipat    05/14/12 - create_cdbviews is now part of CDBView package
Rem    jerrede     03/09/12 - Bug #13719893 Correct utlusts.sql timmings
Rem    dvoss       02/16/12 - bug 13719292 - logminer build only if no
Rem                           migration
Rem    aramappa    02/03/12 - #13653782:invoke olsrle to validate lbac_events
Rem    cdilling    08/28/11 - remove XE check in 12.1
Rem    mdietric    03/23/11 - remove STATS_END - bug 11901407
Rem    traney      01/31/11 - 35209: always run utlmmig.sql
Rem    cmlim       03/02/10 - bug 9412562: add reminder to run DBMS_DST after
Rem                           db upgrade
Rem    cdilling    08/17/09 - do not invoke utlmmig.sql for 11.2 patch upgrades
Rem    nlee        04/02/09 - Fix for bug 8289601.
Rem    yiru        02/28/09 - fix lrg problem: 3795747
Rem    srtata      02/03/09 - validate LBAC_EVENTS : reupgrade issue
Rem    achoi       04/03/08 - run utlmmig.sql for 11.2
Rem    rburns      07/11/07 - no utlmmig for patch upgrade
Rem    cdilling    04/23/07 - add end timestamp for gathering stats
Rem    rburns      02/17/07 - remove edition column if it exists (XE database)
Rem    achoi       11/06/06 - add utlmmig to add index to bootstrap object
Rem    rburns      07/19/06 - fix log miner location 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem

Rem =========================================================================
Rem set the status of types with older versions to 1 in obj$ 
Rem in order to pass sanity check
Rem =========================================================================

Rem Compilation of standard might end up invalidating all object types,
Rem including older versions. This will cause problems if we have data
Rem depending on these versions, as they cannot be revalidated. Older
Rem versions are only used for data conversion, so we only need the
Rem information in type dictionary tables which are unaffected by
Rem changes to standard. Reset obj$ status of these versions to valid
Rem so we can get to the type dictionary metadata.
Rem We need to make this a trusted C callout so that we can bypass the
Rem security check. Otherwise we run intp 1031 when DV is already linked in.

CREATE OR REPLACE LIBRARY UPGRADE_LIB TRUSTED AS STATIC
/
CREATE OR REPLACE PROCEDURE validate_old_typeversions IS
LANGUAGE C
NAME "VALIDATE_OLD_VERSIONS"
LIBRARY UPGRADE_LIB;
/
execute validate_old_typeversions();
commit;
alter system flush shared_pool;
drop procedure validate_old_typeversions;

Rem =====================================================================
Rem Recreate XS component - V$XS_SESSION view if it is invalid
Rem Used when customers rerun catupgrd mutiple times
Rem =====================================================================

DECLARE
  stat VARCHAR(4000);
BEGIN
  SELECT status into stat FROM DBA_OBJECTS  
  WHERE object_name = 'V$XS_SESSION' and owner='SYS' ;
  IF stat = 'INVALID' THEN
    execute immediate 'create or replace view v$xs_session as
         select *
           from xs$sessions with read only'; 
    execute immediate 'create or replace public synonym V$XS_SESSION 
              for v$xs_session';
    execute immediate 'grant select on V$XS_SESSION to DBA';
  END IF; 
EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
/

Rem =====================================================================
Rem 18852024 - Look for synonyms that are pointing at objects that were
Rem originally non-existent but which got created during the upgrade.
Rem Such synonyms need to be recompiled now so that they are pointing at
Rem the right base object. Note that this is an unusual situation and
Rem there should not be many such synonyms (if any).
Rem =====================================================================
DECLARE
  -- This cursor selects synonyms which do not have any row in dependency$
  -- even though it has a valid status and the object being pointed at
  -- by the synonym exists.
  CURSOR c1 IS
  SELECT s.obj#
    FROM syn$ s, obj$ o, user$ u
    WHERE (node is null
           AND o.obj# = s.obj#
           AND o.status = 1       /* synonym is valid */
           AND u.name = s.owner   /* base object's owner exists */
           AND EXISTS (select 1   /* base object exists */
                          FROM obj$ bo
                          WHERE bo.owner# = u.user#
                            AND bo.name = s.name
                            AND bo.type# != 10 /* not non-existent */
                            AND bo.linkname IS NULL)
           AND NOT EXISTS         /* no dependency entry */
                (SELECT 1 FROM dependency$ d WHERE d.d_obj# = s.obj#));

BEGIN
  FOR c IN c1 LOOP
    dbms_utility.invalidate(c.obj#);
    dbms_utility.validate(c.obj#);
  END LOOP;
END;
/

Rem =====================================================================
Rem Set the edition for CATPROC in registry$ table using the edition
Rem value in v$instance. (AFTER all component upgrades)
Rem =====================================================================

EXECUTE dbms_session.reset_package;
EXECUTE sys.dbms_registry.set_edition('CATPROC');

Rem =====================================================================
Rem Recompile DDL triggers
Rem =====================================================================

@@utlrdt

Rem ======================================================================
Rem Recompile all views
Rem ======================================================================

@@utlrvw

Rem ====================================================================
Rem Validate OLS package on which OLS logon and DDL triggers depend.
Rem If not validated these triggers fire with invalid package state
Rem and cause issues in post upgrade mode. 
Rem =====================================================================

@@olsrle



Rem ====================================================================
Rem UPgrade - Add Oracle-Supplied Bits where db was previously pre-12.1
Rem ====================================================================

-- 'uposb' stands for 'UPgrade - update Oracle-Supplied Bits'

VARIABLE uposb_name VARCHAR2(100)
COLUMN :uposb_name NEW_VALUE uposb_file NOPRINT

DECLARE
  p_prv_version  VARCHAR2(30);
BEGIN
  EXECUTE IMMEDIATE
    'SELECT dbms_registry.prev_version(''CATPROC'') FROM sys.dual'
  INTO p_prv_version;
  if substr(p_prv_version, 1, 6) < '12.1.0' then
    :uposb_name := 'catuposb.sql';  -- update oracle-supplied bits
  else
    :uposb_name := 'nothing.sql';  -- execute 'nothing'
  end if;
END;
/

select :uposb_name from sys.dual;
@@&uposb_file

Rem ====================================================================
Rem Resolve java class files
Rem ====================================================================

EXECUTE sys.dbms_registry_sys.resolve_catjava();

Rem ====================================================================
Rem update version in container$
Rem ====================================================================
EXECUTE dbms_pdb.update_version();

Rem =========================================================================
Rem BEGIN BUG 20888348 - REVOKE SELECT ON DICTIONARY VIEWS FROM PUBLIC AFTER
Rem                      UPGRADE. REVOKE WILL DONE ONLY ON THOSE VIEWS WHICH
Rem                      HAS READ PRIVILEGE GRANTED ON THEM TO PUBLIC TOO.
Rem Combination of dbms_assert and ALL_USERS leads to deadlock and hence
Rem ALL_USERS is revoked separately.
Rem =========================================================================
declare
TYPE revoke_array_type IS TABLE OF VARCHAR2(300) INDEX BY pls_integer;
v_rev_array    revoke_array_type;
v_dml_str  VARCHAR2            (300);
capitalize BOOLEAN;
begin
  capitalize := FALSE;
  with part1 as (
    select o.name object, u1.name owner, o.obj#
    from obj$ o, user$ u, table_privilege_map tpm, objauth$ oa, user$ u1
    where o.type# in (2,4) -- TABLE/VIEW
      and bitand (o.flags, 4194304) = 4194304  -- Oracle Maintained
      and u.name = 'PUBLIC'
      and o.obj# = oa.obj#
      and o.owner# = u1.user#
      and oa.grantee# = u.user#
      and oa.privilege# = tpm.privilege
      and tpm.name = 'SELECT'),
  part2 AS (
    select o.name object, u1.name owner, o.obj#
    from obj$ o, user$ u, table_privilege_map tpm, objauth$ oa, user$ u1
    where o.type# in (2,4) -- TABLE/VIEW
      and bitand (o.flags, 4194304) = 4194304  -- Oracle Maintained
      and u.name = 'PUBLIC'
      and o.obj# = oa.obj#
      and o.owner# = u1.user#
      and oa.grantee# = u.user#
      and oa.privilege# = tpm.privilege
      and tpm.name = 'READ')
  SELECT *
  BULK COLLECT
  INTO v_rev_array
  FROM
  (SELECT dbms_assert.enquote_name (part1.owner,capitalize)
         ||'.'||
         dbms_assert.enquote_name (part1.object,capitalize)
  FROM part1,
       part2
  where part1.object = part2.object
        and part1.owner = part2.owner
  MINUS
  SELECT dbms_assert.enquote_name (part1.owner,capitalize)  
         ||'.'|| 
         dbms_assert.enquote_name (part1.object,capitalize)
  FROM PART1, objauth$ oa1   
  where oa1.obj# = part1.obj# and
  oa1.privilege# not in (9,17)
  MINUS
  SELECT dbms_assert.enquote_name(part1.owner,capitalize)
         ||'.'||
         dbms_assert.enquote_name(part1.object,capitalize)
  FROM part1
  WHERE part1.object = 'ALL_USERS'
        and part1.owner = 'SYS');
  if (v_rev_array.count > 0)
  then
    for i in v_rev_array.first..v_rev_array.last loop
      begin
        v_dml_str:=   'revoke select on '
                      || dbms_assert.qualified_sql_name (v_rev_array(i))
                      || ' from public';
        execute immediate v_dml_str;
        exception when OTHERS then
          NULL;
      end;
    end loop;
  end if;
  commit;
  exception when OTHERS then
    NULL;
end;
/

begin
  execute immediate 'revoke select on sys.all_users from public';
  exception when OTHERS then
    NULL;
end;
/

Rem ===========================================================================
Rem Bug 26137367: DBMS_ASSERT could've been in an invalid state, at this point
Rem of time. like in this bug it was. Given that a DBMS_ASSERT instantiation
Rem will already be around, due to the prior usage, and the package in an
Rem invalid state, this would lead to an ORA-6508, on the next invocation of
Rem this package. Hence ensure that we reset the package state, so that the
Rem subsequent invocation auto validates the package and retrieves a fresh
Rem instantiation of the same.
Rem ===========================================================================

execute dbms_session.reset_package;

Rem =========================================================================
Rem END BUG 20888348
Rem =========================================================================

Rem =========================================================================
Rem BEGIN BUG 25548765 - Drop those SYS_PLSQL_% shadown types which are
Rem                      system generated, but do not have the pertinent
Rem                      bit viz. KOTTDSGT, set in their property. These
Rem                      are old types, which must have been generated when
Rem                      we were not setting the system bit, by mistake,
Rem                      which is corrected in newer releases. They were
Rem                      supposed to get dropped in the below block wherein
Rem                      drop all these shadow types, but their system bit
Rem                      was not set, thus they never qualified to be dropped.
Rem                      Also, they were not generated later on during utlrp
Rem                      because utlrp does not process these shadow types.
Rem                      Thus, if they were invalid in first place, in that
Rem                      case, they continued to remain so, even after utlrp.
Rem =========================================================================

DECLARE 
   rc sys_refcursor; 
   str VARCHAR2(4000); 
   name VARCHAR2(32); 
   owner VARCHAR(32); 
   edition VARCHAR2(32); 
   editionable VARCHAR2(1); 
   my_cursor NUMBER := dbms_sql.open_cursor(); 
BEGIN 

   open rc FOR select o.name, db.owner, db.edition_name, db.EDITIONABLE 
     from sys.type$ t, sys.obj$ o,  dba_objects_ae db 
     where  o.oid$ = t.tvoid 
     and o.type# =13 
     and bitand(t.properties, 2048) = 0 
     AND o.subname IS NULL 
     AND REGEXP_LIKE(o.name, 'SYS_PLSQL_[[:alnum:]]+_[[:alnum:]]+_[12]') 
     and o.obj#=db.object_id; 

   LOOP 
      fetch rc INTO name, owner, edition, editionable; 

      EXIT WHEN rc%NOTFOUND; 

      str := 'drop type '||dbms_assert.ENQUOTE_name(owner, false)||'.'||dbms_assert.ENQUOTE_name(name, false)||' force'; 
       
      IF (editionable = 'Y') THEN 
         DECLARE 
            retval NUMBER; 
         BEGIN 
            dbms_sql.parse(c =>my_cursor, statement =>str, 
              language_flag => DBMS_SQL.NATIVE, edition =>edition); 
            retval := dbms_sql.execute(my_cursor); 
         END; 
      ELSE 
         execute immediate str; 
      END IF; 
   END LOOP; 
   close rc;
   dbms_sql.close_cursor(my_cursor); 
EXCEPTION WHEN OTHERS THEN 
   close rc;
   dbms_sql.close_cursor(my_cursor); 
   null; 
END; 
/

Rem =========================================================================
Rem END BUG 25548765
Rem =========================================================================

Rem *************************************************************************
Rem  BEGIN Bug 21068213: Drop shadow Types
Rem *************************************************************************

declare
  cursor c1 is
    select u.name, o.name
    from sys.type$ t, sys.obj$ o, sys.user$ u
    where o.type# = 13
          and bitand(t.properties, 2048) = 2048 
          and o.oid$ = t.toid
          and o.owner# = u.user#
          and o.name like 'SYS_PLSQL_%';
  type_owner   varchar2(128);
  type_name    varchar2(128);
begin
  -- Drop system generated shadow Types
  open c1;
  loop
    fetch c1 into type_owner, type_name;
    exit when c1%NOTFOUND;
    begin
      EXECUTE IMMEDIATE 'drop type "' || type_owner || '"."' || 
                        type_name || '" force';
    exception
      when others then
        null;
    end;
  end loop;
  close c1;
exception
  when others then
    null;
end;
/

Rem *************************************************************************
Rem  END Bug 21068213: Drop shadow Types
Rem *************************************************************************

Rem *************************************************************************
Rem  BEGIN Bug 26182029: Update audit policies to remove synonym objects
Rem *************************************************************************

-- Needs to run on every upgrade in case the underlying object is changed to
-- SYNONYM over db releases.

delete from sys.aud_object_opt$ where policy# in 
 (select obj# from sys.obj$ where namespace = 93) and object# in 
 (select obj# from sys.obj$ where type# = 5);
commit;

Rem *************************************************************************
Rem  END Bug 26182029: Update audit policies to remove synonym objects
Rem *************************************************************************

@?/rdbms/admin/sqlsessend.sql
