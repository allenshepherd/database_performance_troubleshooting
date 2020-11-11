Rem
Rem $Header: rdbms/admin/loc_to_common1.sql /main/15 2017/04/25 08:09:06 thbaby Exp $
Rem
Rem loc_to_common1.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      loc_to_common1.sql - helper script for converting local to common
Rem
Rem    DESCRIPTION
Rem      Does the first set of operations needed to convert local to common.
Rem      Creates object-linked views.
Rem
Rem    NOTES
Rem      Called by noncdb_to_pdb.sql, apex_to_common.sql, pdb_to_apppdb.sql
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/loc_to_common1.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/loc_to_common1.sql
Rem    SQL_PHASE: LOC_TO_COMMON1
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/noncdb_to_pdb.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    thbaby      04/21/17 - Bug 25940936: set _enable_view_pdb
Rem    pyam        01/05/17 - set/clear scriptparam separately per container
Rem    pyam        09/08/16 - RTI 19633354: remove duplicate set &scriptparam
Rem    akruglik    01/25/16 - (22132084): handle Extended Data links
Rem    sankejai    01/22/16 - 16076261: session parameters scoped to container 
Rem    pyam        12/22/15 - 21927236: rename pdb_to_fedpdb to pdb_to_apppdb
Rem    akruglik    11/24/15 - (21193922) App Common users are marked with both
Rem                           common and App-common bits
Rem    thbaby      09/02/15 - Bug 21774247: handle COMMON_DATA
Rem    juilin      09/01/15 - 21458522: rename syscontext FEDERATION_NAME
Rem    pyam        04/30/15 - 20989123: fix fed flags for user$
Rem    pyam        04/19/15 - 20795461: change to _application_script for
Rem                           pdb_to_apppdb
Rem    syetchin    04/06/15 - Fix for diffs in lrgdbconc0e3ee and
Rem                           lrgdbconc0e4ee by mjungerm
Rem    surman      01/08/15 - 19475031: Update SQL metadata
Rem    pyam        09/16/14 - Helper script #1 for converting local objects to
Rem                           common in a CDB environment.
Rem    pyam        09/16/14 - Created
Rem

alter session set "_enable_view_pdb"=false;
exec dbms_pdb.noncdb_to_pdb(&&1);

COLUMN rootcon NEW_VALUE rootcon
select decode(&&1, 5, SYS_CONTEXT('USERENV', 'APPLICATION_NAME'), 'CDB$ROOT')
       rootcon from dual;

COLUMN scriptparam NEW_VALUE scriptparam
select decode(&&1, 5, '"_APPLICATION_SCRIPT"', '"_ORACLE_SCRIPT"') scriptparam
  from dual;

alter session set container=&rootcon;

alter session set &scriptparam=true;

-- CDB Common Users/Roles have 128 (Common) set in user$.spare1 while App 
-- Common Users/Roles have both 128 (Common) and 4096 (App Common) set.  
-- If we are looking for App Common Users/Roles, CDB Common users/Roles get 
-- skipped because we check whether user$.spare1 has both 128 and 4096 set, 
-- but if we are interested in CDB Common Users/Roles, we need to restrict 
-- ourselves to USER$ rows which have 128 but not 4096 set in spare1
COLUMN cmnusrflag NEW_VALUE cmnusrflag
select decode(&&1, 5, '4224', '128') cmnusrflag from dual;

-- if this is for federation conversion, only treat federation objects
-- as common
COLUMN fedobjflag NEW_VALUE fedobjflag
select decode(&&1, 5, '134217728', '0') fedobjflag from dual;

-- create temporary object-linked view to get list of objects marked as common
-- in CDB$ROOT
--
-- NOTE: SHARING bits in OBJ$.FLAGS are:
-- - 65536  = MDL (Metadata Link)
-- - 131072 = DL (Data Link, formerly OBL)
-- - 4294967296 = EDL (Extended Data Link)
define mdl=65536
define dl=131072
define edl=4294967296
define sharing_bits=(&mdl+&dl+&edl)

create or replace view sys.cdb$common_root_objects&pdbid sharing=object as
select u.name owner, o.name object_name, o.type# object_type, o.namespace nsp,
       o.subname object_subname, o.signature object_sig,
       decode(bitand(o.flags, &sharing_bits), 
              &edl+&mdl, 'EDL', &dl, 'DL', 'MDL') sharing
  from sys.obj$ o, sys.user$ u
 where o.owner#=u.user# and bitand(o.flags, &sharing_bits) <> 0
   and bitand(o.flags,&fedobjflag)=&fedobjflag;

-- Bug 21774247: Handle COMMON_DATA tables.
-- create temporary object-linked view to get list of tables marked as 
-- common_data in Root
create or replace view sys.cdb$cdata_root_tables&pdbid sharing=object as
select u.name owner, o.name object_name
  from sys.obj$ o, sys.user$ u, sys.tab$ t
 where o.owner#=u.user# and o.obj#=t.obj# 
   and bitand(t.property, power(2,52))=power(2,52);

-- Bug 21774247: Handle COMMON_DATA views.
-- create temporary object-linked view to get list of views marked as 
-- common_data in Root
create or replace view sys.cdb$cdata_root_views&pdbid sharing=object as
select u.name owner, o.name object_name
  from sys.obj$ o, sys.user$ u, sys.view$ v
 where o.owner#=u.user# and o.obj#=v.obj# 
   and bitand(v.property, power(2,52))=power(2,52);

create or replace view sys.cdb$cmn_root_types&pdbid sharing=object as
select u.name owner, o.name object_name, o.type# object_type, o.namespace nsp,
       o.subname object_subname, o.signature object_sig, t.hashcode hashcode,
       decode(bitand(o.flags, &sharing_bits), 
              &edl+&mdl, 'EDL', &dl, 'DL', 'MDL') sharing
  from sys.obj$ o, sys.user$ u, sys.type$ t where
  o.type#=13 and o.oid$=t.tvoid and o.owner#=u.user# and
  bitand(o.flags, &sharing_bits) <> 0 and 
  bitand(o.flags,&fedobjflag)=&fedobjflag;

-- object-linked view for list of common users
create or replace view sys.cdb$common_users&pdbid sharing=object as
select name, type# from sys.user$ 
where bitand(spare1,4224) = &cmnusrflag;

-- object-linked view for accessing dependency$
create or replace view sys.cdb$rootdeps&pdbid sharing=object as select du.name as owner, do.name as name, do.type# as d_type#, do.namespace as d_namespace,pu.name as referenced_owner, po.name as referenced_name, po.type# as p_type#, po.namespace as p_namespace,d.order#,d.property,d.d_attrs,d.d_reason from sys.obj$ do, sys.obj$ po, sys.user$ du, sys.user$ pu, sys.dependency$ d where du.user#=do.owner# and pu.user#=po.owner# and do.obj#=d_obj# and po.obj#=p_obj#;

-- TODO: update to include fed flags
-- object-linked view for accessing sysauth$: common system privileges
create or replace view sys.cdb$commonsysprivs&pdbid sharing=object as
select u.name, s.privilege# from sys.user$ u, sys.sysauth$ s
where s.grantee#=u.user# and bitand(s.option$,8)=8 and s.privilege#<0;

-- TODO: update to include fed flags
-- object-linked view for accessing sysauth$: common role grants
create or replace view sys.cdb$commonrolegrants&pdbid sharing=object as
select u.name, r.name rolename from sys.user$ u, sys.sysauth$ s, sys.user$ r
where s.grantee#=u.user# and bitand(s.option$,8)=8 and s.privilege#>0 and
s.privilege#=r.user#;

-- TODO: update to include fed flags
-- object-linked view for accessing objauth$
create or replace view sys.cdb$commonobjprivs&pdbid sharing=object as
select u.name, oa.privilege#, u2.name owner, o.name objname, oa.col#
from sys.user$ u, sys.objauth$ oa, sys.obj$ o, sys.user$ u2
where oa.grantee#=u.user# and bitand(oa.option$,8)=8
and oa.obj#=o.obj# and o.owner#=u2.user#;

-- do java long identifier translation in the root if need be
declare junk varchar2(100);
begin
junk := dbms_java_test.funcall('-lid_translate_all', ' ');
exception when others then null;
end;
/
alter session set &scriptparam=false;

-- switch into PDB
alter session set container="&pdbname";

alter session set "_enable_view_pdb"=false;
alter session set &scriptparam=true;
create or replace view sys.cdb$common_root_objects&pdbid sharing=object as
select u.name owner, o.name object_name, o.type# object_type, o.namespace nsp,
       o.subname object_subname, o.signature object_sig,
       decode(bitand(o.flags, &sharing_bits), 
              &edl+&mdl, 'EDL', &dl, 'DL', 'MDL') sharing
  from sys.obj$ o, sys.user$ u
 where o.owner#=u.user# and bitand(o.flags, &sharing_bits) <> 0
   and bitand(o.flags,&fedobjflag)=&fedobjflag;

-- Bug 21774247: Handle COMMON_DATA tables.
-- create temporary object-linked view to get list of tables marked as 
-- common_data in Root
create or replace view sys.cdb$cdata_root_tables&pdbid sharing=object as
select u.name owner, o.name object_name
  from sys.obj$ o, sys.user$ u, sys.tab$ t
 where o.owner#=u.user# and o.obj#=t.obj# 
   and bitand(t.property, power(2,52))=power(2,52);

-- Bug 21774247: Handle COMMON_DATA views.
-- create temporary object-linked view to get list of views marked as 
-- common_data in Root
create or replace view sys.cdb$cdata_root_views&pdbid sharing=object as
select u.name owner, o.name object_name
  from sys.obj$ o, sys.user$ u, sys.view$ v
 where o.owner#=u.user# and o.obj#=v.obj# 
   and bitand(v.property, power(2,52))=power(2,52);

create or replace view sys.cdb$cmn_root_types&pdbid sharing=object as
select u.name owner, o.name object_name, o.type# object_type, o.namespace nsp,
       o.subname object_subname, o.signature object_sig, t.hashcode hashcode,
       decode(bitand(o.flags, &sharing_bits), 
              &edl+&mdl, 'EDL', &dl, 'DL', 'MDL') sharing
  from sys.obj$ o, sys.user$ u, sys.type$ t where
  o.type#=13 and o.oid$=t.tvoid and o.owner#=u.user# and
  bitand(o.flags, &sharing_bits) <> 0 and 
  bitand(o.flags,&fedobjflag)=&fedobjflag;

-- object-linked view for list of common users
create or replace view sys.cdb$common_users&pdbid sharing=object as
select name, type# from sys.user$ 
where bitand(spare1,4224) = &cmnusrflag;

-- object-linked view for accessing dependency$
create or replace view sys.cdb$rootdeps&pdbid sharing=object as select du.name as owner, do.name as name, do.type# as d_type#, do.namespace as d_namespace,pu.name as referenced_owner, po.name as referenced_name, po.type# as p_type#, po.namespace as p_namespace,d.order#,d.property,d.d_attrs,d.d_reason from sys.obj$ do, sys.obj$ po, sys.user$ du, sys.user$ pu, sys.dependency$ d where du.user#=do.owner# and pu.user#=po.owner# and do.obj#=d_obj# and po.obj#=p_obj#;

-- TODO: update to include fed flags
-- object-linked view for accessing sysauth$: common system privileges
create or replace view sys.cdb$commonsysprivs&pdbid sharing=object as
select u.name, s.privilege# from sys.user$ u, sys.sysauth$ s
where s.grantee#=u.user# and bitand(s.option$,8)=8 and s.privilege#<0;

-- TODO: update to include fed flags
-- object-linked view for accessing sysauth$: common role grants
create or replace view sys.cdb$commonrolegrants&pdbid sharing=object as
select u.name, r.name rolename from sys.user$ u, sys.sysauth$ s, sys.user$ r
where s.grantee#=u.user# and bitand(s.option$,8)=8 and s.privilege#>0 and
s.privilege#=r.user#;

-- TODO: update to include fed flags
-- object-linked view for accessing objauth$
create or replace view sys.cdb$commonobjprivs&pdbid sharing=object as
select u.name, oa.privilege#, u2.name owner, o.name objname, oa.col#
from sys.user$ u, sys.objauth$ oa, sys.obj$ o, sys.user$ u2
where oa.grantee#=u.user# and bitand(oa.option$,8)=8
and oa.obj#=o.obj# and o.owner#=u2.user#;

create or replace view sys.cdb$objects&pdbid sharing=none as
select u.name owner, o.name object_name, o.signature object_sig,
       o.namespace nsp, o.subname object_subname, o.obj# object_id,
       o.type# object_type, o.flags flags
  from sys.obj$ o, sys.user$ u
  where o.owner#=u.user#;

create or replace view sys.cdb$types&pdbid sharing=none as
select u.name owner, o.name object_name, o.signature object_sig,
       o.namespace nsp, o.subname object_subname, o.obj# object_id,
       o.type# object_type, o.flags flags, t.hashcode hashcode
  from sys.obj$ o, sys.user$ u, sys.type$ t
  where o.owner#=u.user# and o.type#=13 and o.oid$=t.tvoid;


create or replace view sys.cdb$tables&pdbid sharing=none as
select * from sys.cdb$objects&pdbid where object_type=2;

alter session set &scriptparam=false;

