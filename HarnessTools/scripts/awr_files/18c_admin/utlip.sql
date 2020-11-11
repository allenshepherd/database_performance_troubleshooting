Rem
Rem $Header: rdbms/admin/utlip.sql 
Rem
Rem utlip.sql
Rem
Rem Copyright (c) 1998, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem   NAME
Rem     utlip.sql - UTiLity script to Invalidate Pl/sql
Rem
Rem   DESCRIPTION
Rem
Rem     *WARNING*   *WARNING*  *WARNING*  *WARNING*  *WARNING*  *WARNING*
Rem
Rem     Do not run this script directly.
Rem
Rem     utlip.sql is automatically executed when required for database
Rem     upgrades.
Rem
Rem     Use utlirp.sql if you are looking to invalidate and recompile
Rem     PL/SQL for a 32-bit to 64-bit conversion. Use dbmsupgnv.sql
Rem     to convert all PL/SQL to NATIVE or dbmsupgin.sql to convert all
Rem     PL/SQL to INTERPRETED.
Rem
Rem     set serveroutput must be set to off before
Rem     invoking this script otherwise deadlocks
Rem     and internal errors may result.
Rem
Rem     *WARNING*   *WARNING*  *WARNING*  *WARNING*  *WARNING*  *WARNING*
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/utlip.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlip.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catupstr.sql
Rem    END SQL_FILE_METADATA
Rem
Rem   MODIFIED   (MM/DD/YY)
Rem    pyam        09/08/17 - 25837415: delete diana with negative version num
Rem    raeburns    03/09/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    pyam        02/10/17 - Fwd merge 25125745: remove deletes
Rem    pyam        09/30/16 - 24711897: delete potential duplicate idl_* rows
Rem    jaeblee     06/13/16 - 23239870: force compilation of standard
Rem    pyam        12/22/15 - 21927236: update props$ checks to pdb_to_apppdb
Rem    pyam        06/11/14 - LRG 11949012: fix invalidation clause for
Rem                           noncdb_to_pdb.sql
Rem    pyam        05/22/14 - for ncdb-to-pdb conversion, invalidate not only
Rem                           plsql
Rem    pyam        04/17/14 - 18063022: now called from noncdb_to_pdb.sql.
Rem                           Invalidate only common objs if unconverted
Rem                           non-CDB
Rem    jerrede     11/08/12 - Document set serveroutput on deadlock issue
Rem                           Lrg 8473773
Rem    gviswana    05/02/07 - Add warning messages; revert view Diana delete
Rem    gviswana    06/10/06 - Delete Diana performance optimization 
Rem    gviswana    06/06/06 - Delete 11.x Diana for fine-grain deps 
Rem    ssubrama    12/30/05 - bug 4882839 invalidate dbms_standard dependents 
Rem    gviswana    06/17/05 - Delete sequence Diana 
Rem    weiwang     05/06/05 - invalidate rules engine objects 
Rem    ciyer       07/24/04 - selectively invalidate views and synonyms 
Rem    jmuller     02/12/04 - Fix bug 3432304: commit even if no rows deleted 
Rem    gviswana    08/28/03 - 3103287: Remove Diana deletions for PL/SQL 
Rem    jmallory    08/18/03 - Hardcode dbms_dbupgrade_subname
Rem    gviswana    06/23/03 - 2985184: Invalidate dependent views
Rem    kquinn      07/22/03 - 3009599: Handle remote dbms_standard case
Rem    jmallory    06/09/03 - Fix null checking
Rem    jmallory    03/31/03 - Exclude dbupgrade objects
Rem    gviswana    04/16/03 - Move system parameter handling to utlirp.sql
Rem    kmuthukk    02/03/03 - fix update performance
Rem    nfolkert    12/23/02 - invalidate summary objects
Rem    kmuthukk    10/22/02 - ncomp dlls in db
Rem    gviswana    10/28/02 - Deferred synonym translation
Rem    rdecker     11/09/01 - remove CREATE library code FOR bug 1952368
Rem    gviswana    08/17/01 - Break up IDL_ deletes to avoid blowing rollback
Rem    rburns      08/23/01 - bug 1950073 - add exit on error
Rem    rburns      08/24/01 - add plitblm
Rem    rburns      07/26/01 - invalidate index types and operators
Rem    rxgovind    04/30/01 - interim fix for bug-1747462
Rem    gviswana    10/19/00 - Disable system triggers for Standard recompile
Rem    sbalaram    06/01/00 - Add prvthssq.sql after resolving Bug 1292760
Rem    thoang      05/26/00 - Do not invalidate earlier type versions 
Rem    jdavison    04/11/00 - Modify usage notes for 8.2 changes.
Rem    rshaikh     09/22/99 - quote library names
Rem    mjungerm    06/15/99 - add java shared data object type
Rem    rshaikh     02/12/99 - dont delete java idl objects
Rem    rshaikh     11/17/98 - remove obsolete comments
Rem    rshaikh     10/30/98 - add slash after last truncate stmt
Rem    abrik       10/01/98 - just truncate idl_*$ tables
Rem    rshaikh     10/14/98 - bug 491101: recreate libraries
Rem    ncramesh    08/04/98 - change for sqlplus
Rem    rshaikh     07/20/98 - add commits
Rem    usundara    06/03/98 - merge from 8.0.5
Rem    usundara    04/29/98 - creation (split from utlirp)
Rem                           Kannan Muthukkaruppan (kmuthukk) was the original
Rem                           author of this script.

Rem ===========================================================================
Rem BEGIN utlip.sql
Rem ===========================================================================

Rem Exit immediately if Any failure in this script
WHENEVER SQLERROR EXIT;        

-- If we are in the middle of converting a PDB, the initial objects we
-- invalidate should be limited to common objects
COLUMN andcommon NEW_VALUE andcommon
select decode(cnt, 0, '', 'and bitand(flags,196608)<>0') andcommon
  from (select count(*) cnt from props$
        where name in ('NONCDB_TO_PDB.SQL', 'PDB_TO_APPPDB.SQL')
          and value$='CONVERTING');

-- if invalidate should be limited to Oracle-supplied objects
COLUMN andorclsupp NEW_VALUE andorclsupp
select decode(cnt, 0, '', 'and bitand(flags,4194304)<>0') andorclsupp
  from (select count(*) cnt from props$
        where name='NONCDB_TO_PDB.SQL' and value$='CONVERTING');

-- if invalidate should be limited to Application Container objects
COLUMN andapp NEW_VALUE andapp
select decode(cnt, 0, '', 'and bitand(flags,134217728)<>0') andapp
  from (select count(*) cnt from props$
        where name='PDB_TO_APPPDB.SQL' and value$='CONVERTING');

-- specify types to invalidate. If we're converting, invalidate beyond plsql
COLUMN typestoinv NEW_VALUE typestoinv
select decode(cnt, 0,
   '((type# in (7, 8, 9, 11, 12, 14, 22, 32, 33, 87)) or (type# = 13 and subname is null))',
   '((type# in (4,5,6,7,8,9,11,12,14,22,23,32,33)) or (type# = 13 and subname is null))')
       typestoinv
  from (select count(*) cnt from props$
        where name in ('NONCDB_TO_PDB.SQL', 'PDB_TO_APPPDB.SQL')
          and value$='CONVERTING');

-- call standard and dbmsstdx if this is not for app container conversion
COLUMN standard NEW_VALUE standard
select decode(cnt, 0, 'standard', 'nothing') standard
  from (select count(*) cnt from props$
        where name='PDB_TO_APPPDB.SQL' and value$='CONVERTING');

COLUMN dbmsstdx NEW_VALUE dbmsstdx
select decode(cnt, 0, 'dbmsstdx', 'nothing') dbmsstdx
  from (select count(*) cnt from props$
        where name='PDB_TO_APPPDB.SQL' and value$='CONVERTING');

-- Step (I)
--
-- First we invalidate all stored PL/SQL units (procs, fns, pkgs,
-- types, triggers.)
--
--   The type# in the update statement below indicates the KGL
--   type of the object. They have the following interpretation:
--       7 - pl/sql stored procedure
--       8 - pl/sql stored function
--       9 - pl/sql pkg spec
--      11 - pl/sql pkg body
--      12 - trigger
--      13 - type spec
--      14 - type body
--      22 - library
--      32 - indextype
--      33 - operator
-- 
-- Earlier type versions do not need to be invalidated since all pgm
-- units reference latest type versions. There is no mechanisms to
-- recompile earlier type versions anyway. They must be kept valid so
-- we can get access to its TDO to handle image conversion from one type
-- version to another. 
-- All earlier type versions has the version name stored in obj$.subname
-- and the latest type version always has a null subname. We use this
-- fact to invalidate only the latest type version.
update obj$ set status = 6 
        where &typestoinv
        and ((subname is null) or (subname <> 'DBMS_DBUPGRADE_BABY'))
        and status not in (5,6) 
        and linkname is null
        and not exists (select 1
                        from type$ 
                        where (bitand(properties, 16) = 16) 
                        and toid = obj$.oid$) &andorclsupp &andapp
/
commit
/

Rem Always invalidate MVs during upgrades/ downgrades
update obj$ set status = 5 where type# = 42;
commit;

UPDATE sys.obj$ SET status = 5
where obj# in
  ((select obj# from obj$ where type# = 62 or type# = 46 or type# = 59)
   union all
   (select /*+ index (dependency$ i_dependency2) */ 
      d_obj# from dependency$
      connect by prior d_obj# = p_obj#
      start with p_obj# in
        (select obj# from obj$ where type# = 62 or type# = 46 or type# = 59)))
  &andcommon
/
commit
/

-- Invalidate all synonym dependents of dbms_standard. If not we will end up
-- with a timestamp mismatch between dependency  and obj

update obj$ set status=6 where obj# in
(select d_obj# from dependency$
 where p_obj# in (select obj# from obj$ where name='DBMS_STANDARD' and
                  type# in ( 9, 11) and owner#=0)
) and type#=5
/
commit
/

alter system flush shared_pool
/

--
-- Step (II)
--
-- Delete Diana to force full recompile (rather than fast validation).
-- Diana deletion is accomplished by changing the version number to make
-- rows invisible.
-- bug 25837415: delete any existing DIANA with negative version. We can have
-- pre-existing DIANA with negative version when noncdb_to_pdb.sql has
-- previously been run.
--
delete from idl_ub1$ where part = 0 and version<=-184549376;
delete from idl_ub2$ where part = 0 and version<=-184549376;
delete from idl_sb4$ where part = 0 and version<=-184549376;
delete from idl_char$ where part = 0 and version<=-184549376;
commit;

update idl_ub1$ set version = -version
 where part = 0 and version >= 184549376
   and obj# IN
       (select obj# from obj$ o where status in (5, 6) and 
               type# in (7, 8, 9, 11, 12, 13, 14, 22, 32, 33, 87));
update idl_ub2$ SET version = -version
 where part = 0 and version >= 184549376
   and obj# IN
       (select obj# from obj$ o where status in (5, 6) and 
               type# in (7, 8, 9, 11, 12, 13, 14, 22, 32, 33, 87));
update idl_sb4$ SET version = -version
 where part = 0 and version >= 184549376
   and obj# IN
       (select obj# from obj$ o where status in (5, 6) and 
               type# in (7, 8, 9, 11, 12, 13, 14, 22, 32, 33, 87));
update idl_char$ SET version = -version
 where part = 0 and version >= 184549376
   and obj# IN
       (select obj# from obj$ o where status in (5, 6) and 
               type# in (7, 8, 9, 11, 12, 13, 14, 22, 32, 33, 87));

commit;
alter system flush shared_pool;

-- Step (II)
--
-- Recreate package standard and dbms_standard. This is needed to execute
-- subsequent anonymous blocks
alter session set "_force_standard_compile"=TRUE;
@@&standard
@@&dbmsstdx
alter session set "_force_standard_compile"=FALSE;

-- Step (III)
--
-- Invalidate views and synonyms which depend (directly or indirectly) on
-- invalid objects.
begin
  loop
    update obj$ o_outer set status = 6
    where     type# in (4, 5)
          and status not in (5, 6)
          and linkname is null
          and ((subname is null) or (subname <> 'DBMS_DBUPGRADE_BABY'))
          and exists (select o.obj# from obj$ o, dependency$ d
                      where     d.d_obj# = o_outer.obj#
                            and d.p_obj# = o.obj#
                            and (bitand(d.property, 1) = 1)
                            and o.status > 1);
    exit when sql%notfound;
  end loop;
end;
/

commit;

alter system flush shared_pool;

-- Step (IV)
--
-- Delete Diana for tables, views, and sequences
--
-- The DELETEs are coded in chunks using a PL/SQL loop to avoid running
-- into rollback segment limits.
--
begin

   loop
      delete from idl_ub1$ where
         obj# in (select o.obj# from obj$ o where o.type# in (2, 4, 6))
         and rownum < 5000;
      exit when sql%rowcount = 0;
      commit;
   end loop;
   
   -- 
   -- IDL_UB2$ must use dynamic SQL because its PIECE type is not
   -- understood by PL/SQL.
   --
   loop
      execute immediate
         'delete from idl_ub2$ where
          obj# in (select o.obj# from obj$ o where o.type# in (2, 4, 6))
          and rownum < 5000';
      exit when sql%rowcount = 0;
      commit;
   end loop;
      
   -- 
   -- IDL_SB4$ must use dynamic SQL because its PIECE type is not
   -- understood by PL/SQL.
   --
   loop
      execute immediate
         'delete from idl_sb4$ where
          obj# in (select o.obj# from obj$ o where o.type# in (2, 4, 6))
          and rownum < 5000';
      exit when sql%rowcount = 0;
      commit;
   end loop;

   loop
      delete from idl_char$ where
         obj# in (select o.obj# from obj$ o where o.type# in (2, 4, 6))
         and rownum < 5000;
      exit when sql%rowcount = 0;
      commit;
   end loop;
end;
/
commit;
alter system flush shared_pool;

Rem Continue even if there are SQL errors 
WHENEVER SQLERROR CONTINUE;  

Rem ===========================================================================
Rem END utlip.sql
Rem ===========================================================================
