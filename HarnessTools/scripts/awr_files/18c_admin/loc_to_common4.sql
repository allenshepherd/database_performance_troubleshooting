Rem
Rem $Header: rdbms/admin/loc_to_common4.sql /main/10 2017/04/25 08:09:06 thbaby Exp $
Rem
Rem loc_to_common4.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      loc_to_common4.sql - helper script for converting local to common
Rem
Rem    DESCRIPTION
Rem      Does the fourth set of operations needed to convert local to common.
Rem      Cleans up views created in loc_to_common1.sql
Rem
Rem    NOTES
Rem      Called by noncdb_to_pdb.sql, apex_to_common.sql, pdb_to_apppdb.sql
Rem
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/loc_to_common4.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/loc_to_common4.sql
Rem    SQL_PHASE: LOC_TO_COMMON4
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/noncdb_to_pdb.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    thbaby      04/22/17 - Bug 25940936: set _enable_view_pdb
Rem    pyam        01/05/17 - set/clear scriptparam separately per container
Rem    pyam        09/08/16 - RTI 19633354: remove duplicate set &scriptparam
Rem    sankejai    01/22/16 - 16076261: session parameters scoped to container 
Rem    pyam        12/22/15 - 21927236: rename pdb_to_fedpdb to pdb_to_apppdb
Rem    thbaby      09/02/15 - Bug 21774247: handle COMMON_DATA
Rem    pyam        07/01/15 - set _APPLICATION_SCRIPT if applicable
Rem    vperiwal    03/26/15 - 20172151: add immediate instances = all for close
Rem    surman      01/08/15 - 19475031: Update SQL metadata
Rem    pyam        09/16/14 - Helper script #2 for converting local objects to
Rem                           common in a CDB environment.
Rem    pyam        09/16/14 - Created
Rem

alter session set "_enable_view_pdb"=false;

COLUMN scriptparam NEW_VALUE scriptparam
select decode(&&1, 6, '"_APPLICATION_SCRIPT"', '"_ORACLE_SCRIPT"') scriptparam
  from dual;
alter session set &scriptparam=true;

drop view sys.cdb$tables&pdbid;
drop view sys.cdb$objects&pdbid;
drop view sys.cdb$types&pdbid;
drop view sys.cdb$common_root_objects&pdbid;
drop view sys.cdb$cdata_root_tables&pdbid;
drop view sys.cdb$cdata_root_views&pdbid;
drop view sys.cdb$cmn_root_types&pdbid;
drop view sys.cdb$common_users&pdbid;
drop view sys.cdb$rootdeps&pdbid;
drop view sys.cdb$commonsysprivs&pdbid;
drop view sys.cdb$commonrolegrants&pdbid;
drop view sys.cdb$commonobjprivs&pdbid;

alter session set &scriptparam=false;

alter session set container=&rootcon;

alter session set &scriptparam=true;
drop view sys.cdb$common_root_objects&pdbid;
drop view sys.cdb$cdata_root_tables&pdbid;
drop view sys.cdb$cdata_root_views&pdbid;
drop view sys.cdb$cmn_root_types&pdbid;
drop view sys.cdb$common_users&pdbid;
drop view sys.cdb$rootdeps&pdbid;
drop view sys.cdb$commonsysprivs&pdbid;
drop view sys.cdb$commonrolegrants&pdbid;
drop view sys.cdb$commonobjprivs&pdbid;
alter session set &scriptparam=false;

alter session set container="&pdbname";

alter session set "_enable_view_pdb"=false;

-- reset the parameters at the end of the script
exec dbms_pdb.noncdb_to_pdb(&&1);

alter session set &scriptparam=true;

Rem &&1 is 6 if fed

COLUMN fedobjflag NEW_VALUE fedobjflag
select decode(&&1, 6, '134217728', '0') fedobjflag from dual;

-- run ALTER TABLE UPGRADE on table dependents of common types
-- note this is done after noncdb_to_pdb(2), because between (1) and (2),
-- the driver was changed to only compute signatures
DECLARE
  cursor c is
    select u.name owner, o.name object_name
      from sys.obj$ o, sys.user$ u
    where o.type#=2 and u.user#=o.owner# and obj# in
      (select d_obj# from sys.dependency$ d, sys.obj$ typo where
       typo.type#=13 and typo.obj#=d.p_obj# and d.p_timestamp <> typo.stime and
       bitand(typo.flags, 196608)<>0 and
       bitand(typo.flags, 134217728)=&fedobjflag);
BEGIN
  FOR tab in c
  LOOP
    BEGIN
      execute immediate 'ALTER TABLE ' ||
                        dbms_assert.enquote_name(tab.owner, FALSE) || '.' ||
                        dbms_assert.enquote_name(tab.object_name, FALSE) ||
                        ' UPGRADE';
    EXCEPTION
      WHEN OTHERS THEN
      BEGIN
        IF (sqlcode = -600 or sqlcode = -602 or sqlcode = -603) THEN
          raise;
        END IF;
      END;
    END;
  END LOOP;
  commit;
END;
/

alter session set &scriptparam=false;

alter pluggable database "&pdbname" close immediate instances=all;
alter session set container = CDB$ROOT;
alter system flush shared_pool;
/
/
alter session set container = "&pdbname";

alter session set "_enable_view_pdb"=false;

-- leave the PDB in the same state it was when we started
BEGIN
  execute immediate '&open_sql &restricted_state';
EXCEPTION
  WHEN OTHERS THEN
  BEGIN
    IF (sqlcode <> -900) THEN
      RAISE;
    END IF;
  END;
END;
/

WHENEVER SQLERROR CONTINUE;


