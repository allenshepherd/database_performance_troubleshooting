Rem
Rem $Header: rdbms/admin/noncdb_to_pdb.sql /main/54 2017/07/13 11:28:53 pyam Exp $
Rem
Rem noncdb_to_pdb.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      noncdb_to_pdb.sql - Convert PDB
Rem
Rem    DESCRIPTION
Rem      Converts DB to PDB.
Rem
Rem    NOTES
Rem      Given a DB with proper obj$ common bits set, we convert it to a proper
Rem      PDB by deleting unnecessary metadata.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pyam        06/30/17 - Bug 26098159: move SET SERVEROUTPUT ON later
Rem    tojhuan     03/22/16 - 22465938: clear obj$ common flags before start
Rem    akruglik    01/29/16 - (22132084) handle Ext Data Link bit
Rem    raeburns    12/28/15 - Bug 22175911: Remove use of preupgrade functions
Rem    pyam        12/13/15 - LRG 18533922: pass argument to loc_to_common3.sql
Rem    pyam        12/03/15 - 22243517: remove execute immediate
Rem    pyam        07/14/15 - 20954956: move pre-script check to before loc1
Rem    pyam        04/30/15 - set time/timing on
Rem    pyam        04/19/15 - 20839705: move setting of local mcode earlier
Rem    syetchin    04/06/15 - Fix for diffs in lrgdbconc0e3ee and
Rem                           lrgdbconc0e4ee by mjungerm
Rem    surman      01/08/15 - 19475031: Add SQL patching metadata
Rem    pyam        10/22/14 - put common code in loc_to_common*.sql
Rem    thbaby      09/10/14 - Proj 47234: remove INT$ views; drop temp views
Rem    sankejai    08/13/14 - 19001359: compare type# when marking users/roles
Rem                           as common
Rem    huiz        06/06/14 - 18918217: only make type w/o annotated name local
Rem    pyam        05/28/14 - 18727940: before marking type as common, confirm
Rem                           that signature and hashcode match
Rem    huiz        05/07/14 - bug 18692867: mark nested tables created via 
Rem                           xml schema registration as local 
Rem    pyam        04/17/14 - 18063022,18595341: call utlip, flush shared pool
Rem                           before alter table upgrade
Rem    pyam        04/08/14 - 18478064: call reenable_indexes.sql
Rem    huiz        04/03/14 - bug 18406799: mark default tables created via 
Rem                           xml schema registration as local 
Rem    jaeblee     04/03/14 - set serveroutput off for later portions of script
Rem    pyam        03/05/14 - convert local to common privileges
Rem    jaeblee     03/05/14 - pdb should be in restricted mode, not upgrade
Rem                           mode, during utlrp
Rem    jaeblee     02/25/14 - lrg 11285945: set nls_length_semantics explicitly
Rem    pyam        01/27/14 - 18043599: add enabled$indexes
Rem    huiz        01/14/14 - bug 18056347: mark types created via xml schema 
Rem                           registration as local 
Rem    mjungerm    01/11/14 - normalize dependencies for all MDL java objects,
Rem                           not just classes.bin - bug 1731977
Rem    pyam        12/19/13 - 17976551: fix ALTER TABLE UPGRADE query
Rem    pyam        12/13/13 - ALTER TABLE UPGRADE bef clearing "_ORACLE_SCRIPT"
Rem    pyam        10/29/13 - move ALTER TABLE UPGRADE of type deps down
Rem    gravipat    10/10/13 - 17562904: Open pdb in upgrade mode until
Rem                           noncdb_to_pdb is run successfully
Rem    pyam        10/03/13 - 17490498: remove pdb bounce, remove
Rem                           _noncdb_to_pdb
Rem    thbaby      08/29/13 - 14515351: add INT$ views for sharing=object
Rem    talliu      08/07/13 - change to close immediate
Rem    pyam        07/26/13 - fix missing &pdbid
Rem    pyam        06/25/13 - 16935643: alter table upgrade for type deps
Rem    talliu      06/24/13 - 16967214: add instances = all for close
Rem    sankejai    04/11/13 - 16530655: do not update status in container$
Rem    pyam        04/03/13 - rename temp cdb$* views, to not interfere when
Rem                           this is run in multiple PDBs simultaneously
Rem    pyam        02/06/13 - error out for non-CDB
Rem    pyam        01/21/13 - stop exiting on sqlerror at end
Rem    mjungerm    01/17/13 - XbranchMerge mjungerm_bug-16171710 from
Rem                           st_rdbms_12.1.0.1
Rem    pyam        01/15/13 - leave PDB in state in which it started
Rem    pyam        11/30/12 - delete services SYS$BACKGROUND and SYS$USERS
Rem    jomcdon     11/16/12 - bug 15894059: fix DBRM code for non-SYS
Rem    pyam        11/15/12 - set nls_length_semantics=byte
Rem    pyam        11/13/12 - skip old version types, update common user bit
Rem    jomcdon     11/07/12 - bug 14800566: fix resource manager plans for pdb
Rem    pyam        10/18/12 - add _noncdb_to_pdb
Rem    pyam        09/27/12 - support plug of upgraded db
Rem    pyam        08/13/12 - remove switches from PL/SQL, disable system 
Rem                           triggers
Rem    pyam        06/26/12 - rename script to noncdb_to_pdb.sql
Rem    pyam        02/23/12 - validate v_$parameter properly
Rem    pyam        09/29/11 - Created
Rem
Rem  BEGIN SQL_FILE_METADATA 
Rem  SQL_SOURCE_FILE: rdbms/admin/noncdb_to_pdb.sql 
Rem  SQL_SHIPPED_FILE: rdbms/admin/noncdb_to_pdb.sql
Rem  SQL_PHASE: NONCDB_TO_PDB
Rem  SQL_STARTUP_MODE: NORMAL 
Rem  SQL_IGNORABLE_ERRORS: NONE 
Rem  SQL_CALLING_FILE: NONE
Rem  END SQL_FILE_METADATA
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET VERIFY OFF

-- save settings
STORE SET ncdb2pdb.settings.sql REPLACE

SET TIME ON
SET TIMING ON

WHENEVER SQLERROR EXIT;

DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01403: no data found"
   error if we're not in a PDB.
   This script is intended to be run right after plugin of a PDB,
   while inside the PDB.
#######################################################################
#######################################################################
#

VARIABLE cdbname VARCHAR2(128)
VARIABLE pdbname VARCHAR2(128)
BEGIN
  SELECT sys_context('USERENV', 'CDB_NAME') 
    INTO :cdbname
    FROM dual
    WHERE sys_context('USERENV', 'CDB_NAME') is not null;
  SELECT sys_context('USERENV', 'CON_NAME') 
    INTO :pdbname
    FROM dual
    WHERE sys_context('USERENV', 'CON_NAME') <> 'CDB$ROOT';
END;
/

@@?/rdbms/admin/loc_to_common0.sql

---------------------------------------------------------------------------
-- PRE-SCRIPT CHECKS GO HERE:

-- Check that we have no invalid (not upgraded) table data from 
-- ALTERing Oracle-Maintained Types
DOC
#######################################################################
#######################################################################

     The following statement will cause an "ORA-01722: invalid number"
     error, if the database contains invalid data as a result of type
     evolution which was performed without the data being converted.
     
     To resolve this specific "ORA-01722: invalid number" error:
       Perform the data conversion (details below) in the pluggable database.

     Please refer to Oracle Database Object-Relational Developer's Guide
     for more information about type evolution.

     Data in columns of evolved Oracle-Maintained types must be converted 
     before the database can be converted.

     The following commands, run inside the PDB, will perform the data
     conversion for Oracle supplied tables:

     @?/rdbms/admin/catuptabdata.sql

     You should then confirm that any non-Oracle supplied tables that
     are dependent on Oracle-Maintained types are also converted.  
     You should review the data and determine if it needs
     to be converted or removed. 

     To view the columns affected by type evolution, execute the
     following inside the PDB:

     SELECT rpad(u.name,128) TABLENAME, rpad(o.name,128) OWNER,
            rpad(c.name,128) COLNAME 
     FROM SYS.OBJ$ o, SYS.COL$ c, SYS.COLTYPE$ t, SYS.USER$ u
     WHERE BITAND(t.FLAGS, 256) = 256  -- UPGRADED = NO
       AND o.OBJ# = t.OBJ# AND c.OBJ# = t.OBJ# AND c.COL# = t.COL#
       AND t.INTCOL# = c.INTCOL#
       AND o.owner# = u.user#
       AND o.owner# NOT IN -- NOT a COMMON user
           (SELECT user# FROM sys.user$ 
            WHERE type#=1 and bitand(spare1, 256)= 256)
       AND t.OBJ# IN  -- A dependent of an Oracle-Maintained type
           (SELECT DISTINCT d_obj# 
            FROM sys.dependency$
            START WITH p_obj# IN -- Oracle-Maintained types
                   (SELECT obj# from sys.obj$ 
                    WHERE type#=13 AND 
                          bitand(flags, 4194304) = 4194304)
            CONNECT BY PRIOR d_obj# = p_obj#);

     Once the data is confirmed, the following commands, run inside the PDB, 
     will convert the data returned by the above query.

     @?/rdbms/admin/utluptabdata.sql
 
     Depending on the amount of data involved, converting the evolved type
     data can take a significant amount of time.

     After this is complete, please rerun noncdb_to_pdb.sql.

#######################################################################
#######################################################################
#

set serveroutput on

DECLARE
  do_abort boolean := false;
  t_null varchar2(1);
BEGIN

  -- check for Oracle-Maintained tables that are not UPGRADED
  BEGIN  
    SELECT NULL INTO t_null
    FROM sys.coltype$ t, sys.obj$ o
    WHERE BITAND(t.flags, 256) = 256  -- UPGRADED = NO
      AND t.obj# = o.obj# 
      AND o.owner# IN -- An Oracle-Supplied user
          (SELECT user# FROM sys.user$
           WHERE type#=1 and bitand(spare1, 256)= 256)
      AND rownum <=1;
    do_abort := TRUE;
    dbms_output.put_line('Oracle-Maintained tables need to be UPGRADED.');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  -- check for user tables dependent on Oracle-Maintained types
  -- that are not upgraded
  BEGIN  
    SELECT NULL INTO t_null
    FROM sys.obj$ o, sys.coltype$ t      
    WHERE BITAND(t.FLAGS, 256) = 256   -- UPGRADED = NO
      AND t.obj# = o.obj# 
      AND o.owner# NOT IN -- Not an Oracle-Supplied user
          (SELECT user# FROM sys.user$
           WHERE type#=1 and bitand(spare1, 256)= 256)
      AND t.obj# IN
         (SELECT DISTINCT d_obj# 
          FROM sys.dependency$
          START WITH p_obj# IN -- Oracle-Maintained types
                (SELECT obj# from sys.obj$ 
                 WHERE type#=13 AND 
                       bitand(flags, 4194304) = 4194304)
          CONNECT BY PRIOR d_obj# = p_obj#)
      AND rownum <=1;
    do_abort := TRUE;
    dbms_output.put_line('User tables dependent on Oracle-Maintained types');
    dbms_output.put_line('need to be UPGRADED.');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;


  If do_abort THEN
    dbms_output.put_line ('Non-CDB conversion aborting.');
    dbms_output.put_line ('For instructions, look for ORA-01722 in this script.');
    dbms_output.put_line ('Please resolve these and rerun noncdb_to_pdb.sql.');
    RAISE INVALID_NUMBER;
  END IF;
END;
/

-- END PRE-SCRIPT CHECKS
---------------------------------------------------------------------------
-- NOTE: SHARING bits in OBJ$.FLAGS are:
-- - 65536  = MDL (Metadata Link)
-- - 131072 = DL (Data Link, formerly OBL)
-- - 4294967296 = EDL (Extended Data Link)
define mdl=65536
define dl=131072
define edl=4294967296
define sharing_bits=(&mdl+&dl+&edl)

select count(*) from sys.obj$
where bitand(flags, &sharing_bits) <> 0;

-- 22465938: if obj$ common bits are already set for certain objects,
-- the noncdb_to_pdb conversion might fail to validate these objects.
-- When the first time noncdb_to_pdb.sql is run on a legacy database
-- which is plugged into the CDB, clear any such common bits.
declare
  to_pdb varchar2(128);
begin
  select value$ into to_pdb from props$ where name = 'NONCDB_TO_PDB.SQL';
  if to_pdb = 'TRUE' then
    update sys.obj$
       set flags = flags - bitand(flags, &sharing_bits)
     where bitand(flags, &sharing_bits) <> 0;
    dbms_output.put_line('Common bits are cleared for ' ||
                         sql%rowcount || ' objects.');
    commit;
  else
    dbms_output.put_line('No need to clear common bits twice.');
  end if;
exception
  when no_data_found then
    dbms_output.put_line('No need to clear common bits at all.');
end;
/

select count(*) from sys.obj$
where bitand(flags, &sharing_bits) <> 0;

set serveroutput off;

@@?/rdbms/admin/loc_to_common1.sql 1

-- 18478064:
-- In the case that this is run post-upgrade, we should reenable indexes that
-- were disabled during upgrade. That way, ENABLED$INDEXES created below will
-- accurately reflect . This is necessary because indexes can be dropped
-- and recreated during upgrade, and enabled$indexes.objnum would be outdated.
-- In the non-upgrade case, this will be a no-op, because enabled$indexes
-- wouldn't exist
@@?/rdbms/admin/reenable_indexes.sql

-- record enabled indexes, so that if this script disables them implicitly
-- we can reenable them in the end
set serveroutput off

CREATE TABLE sys.enabled$indexes sharing=none ( schemaname, indexname, objnum )
AS select u.name, o1.name, i.obj# from user$ u, obj$ o1, obj$ o2, ind$ i
    where
        u.user# = o1.owner# and o1.type# = 1 and o1.obj# = i.obj#
       and bitand(i.property, 16)= 16 and bitand(i.flags, 1024)=0
       and i.bo# = o2.obj# and bitand(o2.flags, 2)=0;

-- generate signatures for the common tables which don't have them
DECLARE
  cursor c is
    select r.owner, r.object_name
      from sys.cdb$common_root_objects&pdbid r, sys.cdb$tables&pdbid p
    where r.owner=p.owner and r.object_name=p.object_name
      and r.object_type=2 and p.object_sig is null
      and p.object_name not in ('OBJ$', 'USER$');
BEGIN
  FOR tab in c
  LOOP
    BEGIN
      execute immediate 'ALTER TABLE ' || tab.owner || '."' ||
                        tab.object_name || '" UPGRADE';
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

-- for each table whose signature doesn't match ROOT's, mark its PL/SQL
-- dependents for local MCode 
DECLARE
  cursor c is
    select obj#
      from sys.obj$ o, sys.user$ u, sys.cdb$common_root_objects&pdbid ro
    where o.type# <> 4 and u.name=ro.owner and u.user#=o.owner#
      and o.name=ro.object_name and o.type#=ro.object_type and obj# in
      (select d_obj# from sys.dependency$ where p_obj# in
        (select p.object_id from sys.CDB$common_root_objects&pdbid r,
                                 sys.cdb$tables&pdbid p
         where r.owner=p.owner and r.object_name=p.object_name
           and r.object_type=2 and r.object_sig <> p.object_sig));
BEGIN
  FOR obj in c
  LOOP
    update sys.obj$ set flags=flags+33554432-bitand(flags, 33554432)
                  where obj#=obj.obj#;
  END LOOP;
END;
/

@@?/rdbms/admin/loc_to_common2.sql 0

-- Mark types created via xml schema registration as local. Only need to do 
-- this for common types with system generated name.  
DECLARE
  cursor c is
    select p.obj#, p.flags oldflags
    from sys.obj$ p, sys.dependency$ d, sys.obj$ o
    where p.type#=13 and d.p_obj#=p.obj# and d.d_obj#=o.obj# and o.type#=55
          and bitand(p.flags, &sharing_bits) != 0
          and ((regexp_instr(p.name, '[0-9]_T',1,1) != 0 and 
                regexp_instr(p.name, '[0-9]_T',1,1) = length(p.name)-2) or 
               (regexp_instr(p.name, '[0-9]_COLL',1,1) != 0 and 
                regexp_instr(p.name, '[0-9]_COLL',1,1) = length(p.name)-4)); 
BEGIN
  FOR obj in c
  LOOP
    update sys.obj$ set flags=(obj.oldflags - bitand(obj.oldflags, &sharing_bits))
                  where obj#=obj.obj#;
  END LOOP;
END;
/

-- As types with system generated name created via xml schema registration
-- are marked as local, mark default tables depending on those types as
-- local too, plus default tables with system generated table name.
-- Only need to do this for common tables.  
DECLARE
  cursor c is
  with v as (select p.obj#, p.flags pflags
             from sys.obj$ p, sys.dependency$ d, sys.obj$ o
             where p.type#=13 and p.obj#=d.p_obj# and d.d_obj#=o.obj# 
                   and o.type#=55)
  select distinct o1.obj#, o1.flags oldflags
  from v, sys.dependency$ d1, sys.obj$ o1
  where v.obj#=d1.p_obj# and d1.d_obj#=o1.obj# and o1.type#=2 
        and bitand(o1.flags, &sharing_bits) != 0
        and ((bitand(pflags, &sharing_bits) = 0) or
             (regexp_instr(o1.name, '[0-9]_TAB',1,1) != 0 and 
              regexp_instr(o1.name, '[0-9]_TAB',1,1) = length(o1.name)-3)); 
BEGIN
  FOR obj in c
  LOOP
    BEGIN
      update sys.obj$ set flags=(obj.oldflags - bitand(obj.oldflags, &sharing_bits))
                    where obj#=obj.obj#;
    END;
  END LOOP;
END;
/

-- As default tables created via xml schema registration are marked as local, 
-- mark all nested tables as local too if its parent table is local.
-- Only need to do this for common nested tables.  
declare 
  -- get local O-R xmltype parent table owned by common users 
  cursor ortabq is 
    select n.owner, n.parent_table_name 
    from sys.obj$ o, dba_users u, dba_nested_tables n, 
    ( select owner, table_name from dba_xml_tables 
      where storage_type='OBJECT-RELATIONAL' 
      union 
      select owner, table_name from dba_xml_tab_cols 
      where storage_type='OBJECT-RELATIONAL' 
     ) t 
    where n.owner = t.owner 
          and n.parent_table_name = t.table_name 
          and t.owner = u.username 
          and u.common='YES' 
          and u.user_id = o.owner# 
          and o.name = t.table_name 
          and bitand(o.flags, &sharing_bits) = 0
    order by n.owner, n.parent_table_name; 

  -- get the hierarchy of nested tables, given a parent table name and owner 
  cursor ntq(oname varchar2, pname varchar2) is 
    select n.owner, n.parent_table_name, n.table_name 
    from dba_nested_tables n 
    where n.owner=oname 
    start with parent_table_name=pname 
    connect by prior table_name=parent_table_name 
    order by n.owner, n.parent_table_name, n.table_name;
 
  -- get obj$ entries for the common nested tables, given its owner and name 
  cursor c (owner_name varchar2, obj_name varchar2) is 
    select o.obj#, o.flags oldflags
    from sys.obj$ o, dba_users u
    where o.owner#=u.user_id and u.username=owner_name and o.name=obj_name
          and bitand(o.flags, &sharing_bits) != 0;
begin 
  for rec in ortabq loop 
    for ntrec in ntq(rec.owner, rec.parent_table_name) loop
      for obj in c(ntrec.owner, ntrec.table_name) loop
        begin 
          update sys.obj$
             set flags=(obj.oldflags - bitand(obj.oldflags, &sharing_bits))
           where obj#=obj.obj#;
        end;
      end loop; 
    end loop; 
  end loop; 
end; 
/ 

select to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') from dual;

-- get rid of idl_ub1$ rows for MDL java objects
delete from sys.idl_ub1$ where obj# in (select obj# from sys.obj$ where bitand(flags, 65536)=65536 and type# in (28,29,30,56));
commit;

-- do java long identifier translation in the pdb if need be
declare junk varchar2(100);
begin
junk := dbms_java_test.funcall('-lid_translate_all', ' ');
exception when others then null;
end;
/

-- normalize dependencies for MDL java objects (includes classes.bin objects)
delete from sys.dependency$ where d_obj# in (select obj# from sys.obj$ where bitand(flags,65536)=65536 and type# in (29,56));

insert into sys.dependency$ (select do.obj#,do.stime,order#,po.obj#,po.stime,do.owner#,property,d_attrs,d_reason from sys.obj$ do,sys.user$ du,sys.obj$ po,sys.user$ pu,sys.cdb$rootdeps&pdbid rd where du.user#=do.owner# and pu.user#=po.owner# and do.name=rd.name and du.name=owner and do.type#=d_type# and po.name=referenced_name and pu.name=referenced_owner and po.type#=p_type# and bitand(do.flags,65536)=65536 and do.type# in (29,56));

commit;
alter system flush shared_pool;

select owner#, name from sys.obj$ where bitand(flags, 33554432)=33554432
  order by 1, 2;

-- pass in 1 to indicate that we need to invalidate STANDARD and DBMS_STANDARD
@@?/rdbms/admin/loc_to_common3.sql 1

-- handle Resource Manager plan conversions
exec dbms_rmin.rm$_noncdb_to_pdb;

-- delete SYS$BACKGROUND and SYS$USERS from service$
delete from sys.service$ where name in ('SYS$BACKGROUND', 'SYS$USERS');
commit;

@@?/rdbms/admin/loc_to_common4.sql 2

-- restore old settings
START ncdb2pdb.settings.sql

