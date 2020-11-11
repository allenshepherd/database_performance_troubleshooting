Rem
Rem $Header: rdbms/admin/loc_to_common2.sql /main/14 2017/04/25 08:09:06 thbaby Exp $
Rem
Rem loc_to_common2.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      loc_to_common2.sql - helper script for converting local to common
Rem
Rem    DESCRIPTION
Rem      Does the second set of operations needed to convert local to common.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/loc_to_common2.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/loc_to_common2.sql
Rem    SQL_PHASE: LOC_TO_COMMON2
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/noncdb_to_pdb.sql
Rem    END SQL_FILE_METADATA
Rem
Rem      
Rem
Rem    NOTES
Rem      Called by noncdb_to_pdb.sql, apex_to_common.sql, pdb_to_apppdb.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    thbaby      04/21/17 - Bug 25940936: set _enable_view_pdb
Rem    thbaby      03/13/17 - Bug 25212689: exception handler for truncate
Rem    pyam        06/29/16 - 23184418: truncate data link tables in app pdb
Rem    tojhuan     03/22/16 - 22465938: keep common views in status INVALID
Rem    akruglik    01/15/16 - (22132084) replace COMMON_DATA with EXTENDED DATA
Rem    pyam        12/22/15 - 21927236: rename pdb_to_fedpdb to pdb_to_apppdb
Rem    pyam        12/13/15 - LRG 18533922: dont invalidate
Rem                           STANDARD/DBMS_STANDARD
Rem    akruglik    11/24/15 - (21193922) App Common users are marked with both
Rem                           common and App-common bits
Rem    thbaby      09/02/15 - Bug 21774247: handle COMMON_DATA
Rem    pyam        06/24/15 - 21199445: mark converted objects as invalid
Rem    kquinn      05/18/15 - 21095719: improve performance
Rem    pyam        04/30/15 - 20989123: fix fed flags for user$
Rem    surman      01/08/15 - 19475031: Update SQL metadata
Rem    pyam        09/16/14 - Helper script #2 for converting local objects to
Rem                           common in a CDB environment.
Rem    pyam        09/16/14 - Created
Rem

Rem fed == &&1;

alter session set "_enable_view_pdb"=false;

-- CDB Common Users/Roles have 128 (Common) set in user$.spare1 while App 
-- Common Users/Roles have both 128 (Common) and 4096 (App Common) set.  
COLUMN cmnusrflag NEW_VALUE cmnusrflag
select decode(&&1, 1, '4224', '128') cmnusrflag from dual;

COLUMN fedobjflag NEW_VALUE fedobjflag
select decode(&&1, 1, '134217728', '0') fedobjflag from dual;

-- mark users and roles in our PDB as common if they exist as common in ROOT
-- also compare the type# to ensure that we match users in PDB with users in
-- ROOT (and same for roles)
update sys.user$ a set a.spare1=a.spare1+&cmnusrflag where a.user# in (
  select p.user# from sys.cdb$common_users&pdbid r, sys.user$ p
  where r.name=p.name and r.type#=p.type# and bitand(p.spare1, 4224)=0);

-- TODO: fed
-- mark privileges in our PDB as common if they exist as common in ROOT
DECLARE
  cursor c is
    select s.grantee#, s.privilege#
      from sys.sysauth$ s, sys.user$ u, sys.cdb$commonsysprivs&pdbid r
     where u.user#=s.grantee# and u.name=r.name and s.privilege#=r.privilege#
           and bitand(s.option$,8)=0;
BEGIN
  FOR obj in c
  LOOP
    BEGIN
      update sys.sysauth$ set option$=option$+12+bitand(option$,3)*15 
        where grantee#=obj.grantee# and privilege#=obj.privilege#;
    END;
  END LOOP;
  commit;
END;
/


-- TODO: fed
DECLARE
  cursor c is
    select s.grantee#, s.privilege#
      from sys.sysauth$ s, sys.user$ u, sys.cdb$commonrolegrants&pdbid r,
           sys.user$ ru
     where u.user#=s.grantee# and u.name=r.name and r.rolename=ru.name and
           s.privilege#=ru.user# and bitand(s.option$,8)=0;
BEGIN
  FOR obj in c
  LOOP
    BEGIN
      update sys.sysauth$ set option$=option$+12+bitand(option$,3)*15 
        where grantee#=obj.grantee# and privilege#=obj.privilege#;
    END;
  END LOOP;
  commit;
END;
/

-- TODO: fed
DECLARE
  cursor c is
    select oa.privilege#, oa.grantee#, oa.obj#, oa.col#
      from sys.objauth$ oa, sys.user$ u, sys.cdb$commonobjprivs&pdbid r,
           sys.obj$ o, sys.user$ ou
     where oa.privilege#=r.privilege# and oa.grantee#=u.user# and
           u.name=r.name and o.name=r.objname and oa.obj#=o.obj# and
           ou.name=r.owner and o.owner#=ou.user# and bitand(oa.option$,8)=0 and
           ((oa.col# is null and r.col# is null) or oa.col#=r.col#);

BEGIN
  FOR obj in c
  LOOP
    BEGIN
      IF (obj.col# is null) THEN
        update sys.objauth$ set option$=option$+12+bitand(option$,3)*15 
          where grantee#=obj.grantee# and privilege#=obj.privilege# and
                obj#=obj.obj# and col# is null;
      ELSE
        update sys.objauth$ set option$=option$+12+bitand(option$,3)*15 
          where grantee#=obj.grantee# and privilege#=obj.privilege# and
                obj#=obj.obj# and col# = obj.col#;
      END IF;

    END;
  END LOOP;
  commit;
END;
/

-- mark objects in our PDB as common if they exist as common in ROOT
-- mark them as invalid if they're of a type that can be invalid
-- LRG 18533922: refrain from invalidating STANDARD and DBMS_STANDARD
-- BUG 22465938: there is no guarantee that views are all validated
--     before noncdb_to_pdb/apex_to_common/pdb_to_apppdb, leading to
--     failure of follow-up loc_to_common steps. It is more robust to
--     keep their status INVALID (6) as we do on the other source objects.
--
-- NOTE: SHARING bits in OBJ$.FLAGS are:
-- - 65536  = MDL (Metadata Link)
-- - 131072 = DL (Data Link, formerly OBL)
-- - 4294967296 = EDL (Extended Data Link)
define mdl=65536
define dl=131072
define edl=4294967296
define sharing_bits=(&mdl+&dl+&edl)

DECLARE
  cursor c is
    select p.object_id, 
           p.flags-bitand(p.flags, &sharing_bits+&fedobjflag) flags,
           decode(r.sharing, 'MDL', &mdl, 'DL', &dl, &edl+&mdl) sharing_flag,
           case when p.object_type in (4, 7, 8, 9, 11, 12, 14, 22, 32, 33, 87)
                 and p.object_subname is null
                then 6
                else 1
           end new_status
      from sys.cdb$common_root_objects&pdbid r, sys.cdb$objects&pdbid p
    where r.owner=p.owner and r.object_name=p.object_name
      and r.object_type=p.object_type and r.object_type != 13 and r.nsp=p.nsp
      and (p.object_subname is null and r.object_subname is null
           or r.object_subname=p.object_subname)
      and decode(bitand(p.flags, &sharing_bits), 
                 &edl+&mdl, 'EDL', &dl, 'DL', &mdl, 'MDL', 'NONE')
          <> r.sharing
      and not (r.owner='SYS' and
               (r.object_name='STANDARD' or r.object_name='DBMS_STANDARD') and
               (r.object_type in (9, 11)));
  cursor ctyp is
    select p.object_id, 
           p.flags-bitand(p.flags, &sharing_bits+&fedobjflag) flags,
           decode(r.sharing, 'MDL', &mdl, 'DL', &dl, &edl+&mdl) sharing_flag
      from sys.cdb$cmn_root_types&pdbid r, sys.cdb$types&pdbid p
    where r.owner=p.owner and r.object_name=p.object_name
      and (p.object_subname is null and r.object_subname is null
           or r.object_subname=p.object_subname)
      and decode(bitand(p.flags, &sharing_bits), 
                 &edl+&mdl, 'EDL', &dl, 'DL', &mdl, 'MDL', 'NONE')<>r.sharing
      and p.object_sig=r.object_sig and p.hashcode=r.hashcode;
BEGIN
  FOR obj in c
  LOOP
    BEGIN
      update sys.obj$ set flags=(obj.flags + obj.sharing_flag + &fedobjflag),
                          status=obj.new_status
                    where obj#=obj.object_id;
    END;
  END LOOP;
  FOR obj in ctyp
  LOOP
    BEGIN
      update sys.obj$ set flags=(obj.flags + obj.sharing_flag + &fedobjflag),
                          status=6
                    where obj#=obj.object_id;
    END;
  END LOOP;
  commit;
END;
/

-- BUG 23184418: truncate and drop index for datalink table.
alter session set &scriptparam=true;

-- make sure link flags are reloaded properly
alter system flush shared_pool;

DECLARE
  cursor c is
    select p.object_id, p.object_type,
            '"' || p.owner || '"."' || p.object_name || '"' as name
    from sys.cdb$objects&pdbid p
    where p.object_type = 2 and bitand(p.flags, &dl) = &dl
     and  bitand(p.flags, 134217728)=&fedobjflag;
BEGIN
  FOR obj in c
  LOOP
    BEGIN
      execute immediate 'TRUNCATE TABLE '|| obj.name;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;

    FOR ind IN
      (select '"'||u.name||'"."'||o.name||'"' as name
       from obj$ o, user$ u, (select unique i.obj# as idx_obj
                              from ind$ i
                              where bo# = obj.object_id and i.type# = 1 and
                              i.obj# not in (select nvl(enabled,0) from cdef$))
       where o.obj# = idx_obj and user# = owner#)
    LOOP
      BEGIN
        execute immediate 'DROP INDEX '|| ind.name;
      EXCEPTION WHEN OTHERS THEN NULL;
      END;
    END LOOP;
  END LOOP;
END;
/
alter session set &scriptparam=false;

-- Bug 21774247: Handle COMMON_DATA tables (this includes tables for which 
-- COMMON_DATA was specified explicitly as well as EXTENDED DATA tables 
-- (for which COMMON_DATA bit will be getting set for the time being.))
-- Retrieve all tables marked as COMMON_DATA in Root and mark them as 
-- COMMON_DATA in PDB (if not already marked as COMMON_DATA).
DECLARE
  cursor c is 
    select p.object_id 
      from sys.cdb$cdata_root_tables&pdbid r, sys.cdb$objects&pdbid p
     where r.owner=p.owner and r.object_name=p.object_name;
BEGIN
  FOR obj in c
    LOOP
      BEGIN
        update sys.tab$ t set t.property=(t.property + power(2,52))
                        where bitand(t.property, power(2,52)) = 0 
                          and t.obj#=obj.object_id;
      END;
    END LOOP;
    commit;
END;
/

-- Bug 21774247: Handle COMMON_DATA views (this includes views for which 
-- COMMON_DATA was specified explicitly as well as EXTENDED DATA views 
-- (for which COMMON_DATA bit will be getting set for the time being.))
-- Retrieve all views marked as COMMON_DATA in Root and mark them as
-- COMMON_DATA in PDB (if not already marked as COMMON_DATA).
DECLARE
  cursor c is 
    select p.object_id 
      from sys.cdb$cdata_root_views&pdbid r, sys.cdb$objects&pdbid p
     where r.owner=p.owner and r.object_name=p.object_name;
BEGIN
  FOR obj in c
    LOOP
      BEGIN
        update sys.view$ v set v.property=(v.property + power(2,52))
                         where bitand(v.property, power(2,52)) = 0 
                           and v.obj#=obj.object_id;
      END;
    END LOOP;
    commit;
END;
/

alter system flush shared_pool;

