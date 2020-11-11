Rem
Rem $Header: rdbms/admin/loc_to_common3.sql /main/8 2017/07/24 11:21:51 pyam Exp $
Rem
Rem loc_to_common3.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      loc_to_common3.sql - helper script for converting local to common
Rem
Rem    DESCRIPTION
Rem      Does the third set of operations needed to convert local to common.
Rem      Does utlip + utlrp + related tasks.
Rem
Rem    NOTES
Rem      Called by noncdb_to_pdb.sql, apex_to_common.sql, pdb_to_apppdb.sql
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/loc_to_common3.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/loc_to_common3.sql
Rem    SQL_PHASE: LOC_TO_COMMON3
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/noncdb_to_pdb.sql
Rem    END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pyam        07/20/17 - Bug 26434999: turn off concurrent stats gathering
Rem    thbaby      04/22/17 - Bug 25940936: set _enable_view_pdb
Rem    pyam        12/22/15 - 21927236: rename pdb_to_fedpdb to pdb_to_apppdb
Rem    pyam        12/13/15 - LRG 18533922: convert STANDARD/DBMS_STANDARD if
Rem                           necessary
Rem    pyam        10/21/15 - 12172090: move up marking valid of old type
Rem                           versions
Rem    vperiwal    03/26/15 - 20172151: add immediate instances = all for close
Rem    surman      01/08/15 - 19475031: Update SQL metadata
Rem    pyam        09/16/14 - Helper script #3 for converting local objects to
Rem                           common in a CDB environment.
Rem    pyam        09/16/14 - Created
Rem

Rem invalidate_standard == &&1;

alter session set "_enable_view_pdb"=false;

-- if requested, invalidate STANDARD and DBMS_STANDARD and mark them common
update obj$ set status=6, flags=flags-bitand(flags,196608)+65536
 where &&1=1 and name in ('STANDARD', 'DBMS_STANDARD');
commit;

@@?/rdbms/admin/utlip

-- explicitly compile these now, before close/reopen. Otherwise they would
-- be used/validated within PDB Open, where such patching (clearing of dict
-- rows) can't be done.
alter session set "_ORACLE_SCRIPT"=true;
alter public synonym ALL_OBJECTS compile;
alter view SYS.V_$PARAMETER compile;

WHENEVER SQLERROR CONTINUE;
alter type SYS.ANYDATA compile;
WHENEVER SQLERROR EXIT;

alter session set "_ORACLE_SCRIPT"=false;

alter pluggable database "&pdbname" close immediate instances=all;
alter pluggable database "&pdbname" open restricted;

-- mark old version types as valid, as utlrp skips these
update sys.obj$ set status = 1
  where type#=13 and subname is not null and status > 1;
commit;
alter system flush shared_pool;

-- 26434999: set concurrent stats gathering to OFF, save original value
COLUMN concurrent NEW_VALUE concurrent
select dbms_stats.get_prefs('CONCURRENT') concurrent from dual;
exec dbms_stats.set_global_prefs('CONCURRENT', 'OFF');

@@?/rdbms/admin/utlrp

-- 26434999: set global prefs back to original value
exec dbms_stats.set_global_prefs('CONCURRENT','&concurrent')

alter pluggable database "&pdbname" close immediate instances=all;
alter system flush shared_pool;
alter pluggable database "&pdbname" open upgrade;


