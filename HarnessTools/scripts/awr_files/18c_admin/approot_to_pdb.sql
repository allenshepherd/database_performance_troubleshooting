Rem
Rem $Header: rdbms/admin/approot_to_pdb.sql /main/13 2017/05/18 12:04:15 tianlli Exp $
Rem
Rem approot_to_pdb.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      approot_to_pdb.sql - App Root -> PDB conversion script
Rem
Rem    DESCRIPTION
Rem      When an App Root is plugged in or cloned into a regular PDB,
Rem      certain dictionary bits need to be cleared. This is accomplished 
Rem      as part of this script. If these dictionary bits are not cleared,
Rem      certain views may not display correctly and certain parts of 
Rem      Oracle code may not run properly.
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/approot_to_pdb.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/approot_to_pdb.sql
Rem    SQL_PHASE: APPROOT_TO_PDB
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tianlli     05/18/17 - Bug 25437015: clear extended data for app object
Rem    pjulsaks    12/14/16 - Bug 25177158: drop sequence APP$CON$SEQ
Rem    prshanth    08/02/16 - Bug 23329799: add checks for running this script
Rem    thbaby      01/12/16 - Bug 22521947: disallow script in PDB$SEED
Rem    thbaby      12/08/15 - Bug 22321067: disallow script in App Container
Rem    pyam        11/25/15 - 22282825: fed$statements -> pdb_sync$
Rem    pyam        11/22/15 - 21911641: remove fed$sessions
Rem    akruglik    11/18/15 - (21193922): rows representing App Common
Rem                           users/roles/profiles have both common and app bit
Rem                           set
Rem    thbaby      11/10/15 - bug 22181033: do not use obj$.spare10 for appid
Rem    thbaby      08/17/15 - 21646878: truncate table fed$dependency
Rem    thbaby      05/05/15 - 20977420: clear more bits in sysauth$/objauth$
Rem    thbaby      04/11/15 - 20836220: remove query for FEDERATION_NAME
Rem    thbaby      03/25/15 - 20725844: clear app bits in user$
Rem    thbaby      03/18/15 - script for App Root -> regular PDB conversion
Rem    thbaby      03/18/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

WHENEVER SQLERROR EXIT;

-- Check if we really need to run approot_to_pdb.sql for this PDB
exec dbms_pdb.noncdb_to_pdb(7);

VARIABLE cdbname VARCHAR2(128)
VARIABLE pdbname VARCHAR2(128)
VARIABLE appname VARCHAR2(128)
BEGIN
  -- Disallow script in non-CDB
  SELECT sys_context('USERENV', 'CDB_NAME') 
    INTO :cdbname
    FROM dual
    WHERE sys_context('USERENV', 'CDB_NAME') is not null;
  -- Disallow script in CDB Root
  -- Disallow script in PDB$SEED (Bug 22521947)
  SELECT sys_context('USERENV', 'CON_NAME') 
    INTO :pdbname
    FROM dual
    WHERE sys_context('USERENV', 'CON_NAME') <> 'CDB$ROOT'
    AND   sys_context('USERENV', 'CON_NAME') <> 'PDB$SEED';
  -- Disallow script in Application Container (Bug 22321067)
  SELECT sys_context('USERENV', 'APPLICATION_NAME')
    INTO :appname
    FROM dual
    WHERE sys_context('USERENV', 'APPLICATION_NAME') is null;
  -- Disallow script in Proxy PDB (Bug 22521947). This query works 
  -- because remote mapping in Proxy PDB has been disabled using 
  -- the underscore parameter. 
  SELECT /*+ OPT_PARAM('_ENABLE_VIEW_PDB', 'FALSE') */ name
    INTO :pdbname
    FROM v$pdbs
    WHERE proxy_pdb='NO';
END;
/

-- Change state of PDB so that subsequent SQLs will succeed
COLUMN pdbname NEW_VALUE pdbname
COLUMN pdbid NEW_VALUE pdbid

select :pdbname pdbname from dual;

select TO_CHAR(con_id) pdbid from v$pdbs where name='&pdbname';

-- save pluggable database open mode
COLUMN open_state_col NEW_VALUE open_sql;
COLUMN restricted_col NEW_VALUE restricted_state;
SELECT decode(open_mode,
              'READ ONLY', 'ALTER PLUGGABLE DATABASE &pdbname OPEN READ ONLY',
              'READ WRITE', 'ALTER PLUGGABLE DATABASE &pdbname OPEN',
              'MIGRATE', 'ALTER PLUGGABLE DATABASE &pdbname OPEN UPGRADE', '')
         open_state_col,
       decode(restricted, 'YES', 'RESTRICTED', '')
         restricted_col
       from v$pdbs where name='&pdbname';

alter session set container=CDB$ROOT;

-- if pdb was already closed, don't exit on error
WHENEVER SQLERROR CONTINUE;
alter pluggable database "&pdbname" close immediate instances=all;
WHENEVER SQLERROR EXIT;

alter pluggable database "&pdbname" open upgrade;

-- initial setup before beginning the script
alter session set NLS_LENGTH_SEMANTICS=BYTE;

alter session set container = "&pdbname";

-- Delete rows from pdb_sync$ pertaining to 12.2 capture
-- Truncate the rest of the tables related to Application Container
delete   from  sys.pdb_sync$ where bitand(flags,8)=8;
truncate table sys.fed$apps;
truncate table sys.fed$patches;
truncate table sys.fed$versions;
truncate table sys.fed$statement$errors;
truncate table sys.fed$app$status;
truncate table sys.fed$binds;
truncate table sys.fed$editions;
truncate table sys.fed$dependency;

-- Bug 25177158: Drop Application sequence
drop sequence APP$CON$SEQ;

-- Bug 25437015: Clear COMMON_DATA table or view bits in tab$ or view$ for
-- extended data link application objects
update tab$ t
  set t.property = t.property - power(2,32) * 1048576
 where exists(
    select * 
      from obj$ o
     where t.obj# = o.obj# 
      and bitand(o.flags, 134217728 + 4294967296) = 134217728 + 4294967296)
/
commit;

update view$ v
  set v.property = v.property - power(2,32) * 1048576
 where exists(
    select * 
      from obj$ o
     where v.obj# = o.obj# 
      and bitand(o.flags, 134217728 + 4294967296) = 134217728 + 4294967296)
/
commit;

-- Bug 22181033: Clear App ID/Version ID columns for Application objects
update obj$ o
   set o.creappid = null, o.modappid = null, 
       o.creverid = null, o.modverid = null
 where bitand(o.flags, 134217728) = 134217728
/
commit;

-- Clear OBL bits on Application objects
update obj$ o 
   set o.flags = o.flags - 134217728 - 131072
 where bitand(o.flags, 134217728+131072) =  134217728 + 131072
/
commit;

-- Bug 25437015: Clear extended data link bits for application objects. 
-- Note that it also has Metadata link bits
update obj$ o 
   set o.flags = o.flags - 134217728 - 4294967296 - 65536
 where bitand(o.flags, 134217728 + 4294967296) = 134217728 + 4294967296
/
commit;

-- Clear MDL bits on Application objects
update obj$ o 
   set o.flags = o.flags - 134217728 - 65536
 where bitand(o.flags, 134217728 + 65536) = 134217728 + 65536
/
commit;

-- Clear Application bit on other Application objects
update obj$ o 
   set o.flags = o.flags - 134217728
 where bitand(o.flags, 134217728) = 134217728
/
commit;

-- Clear bits (KTSUCS1_COMMON and KTSUCS1_APP) marking users/roles as App 
-- Common in user$
update user$ u
set    u.spare1 = u.spare1 - 4224
where  bitand(u.spare1, 4224) = 4224
/
commit;

-- Clear bits (KZDPF_COMMON and KZDPF_APP) marking profiles as App 
-- Common in profname$
update profname$ n
set    n.flags = n.flags - 3
where  bitand(n.flags, 3) = 3
/
commit;

-- Clear KZDSYS_NO_LOCAL in sysauth$
update sysauth$ s 
set    s.option$  = s.option$ - 4
where  bitand(s.option$, 4) = 4
and    bitand(s.option$, 64) = 64
/
commit;

-- Set KZDSYSWAO instead of KZDSYSFEDWAO in sysauth$
update sysauth$ s
set    s.option$ = s.option$ - power(2,7) + power(2,0)
where  bitand(s.option$, power(2,7)) = power(2,7)
and    bitand(s.option$, 64) = 64
/
commit;

-- Set KZDSYSWDO instead of KZDSYSFEDWDO in sysauth$
update sysauth$ s
set    s.option$ = s.option$ - power(2,8) + power(2,1)
where  bitand(s.option$, power(2,8)) = power(2,8)
and    bitand(s.option$, 64) = 64
/
commit;

-- Clear Application bit KZDSYSFED in sysauth$
update sysauth$ s
set    s.option$ = s.option$ - 64
where  bitand(s.option$, 64) = 64
/
commit;

-- Clear KZDOO_NO_LOCAL in objauth$
update objauth$ o
set    o.option$ = o.option$ - 4
where  bitand(o.option$, 4) = 4
and    bitand(o.option$, 64) = 64
/
commit;

-- Set KZDOOWGO instead of KZDOOFEDWGO in objauth$
update objauth$ o
set    o.option$ = o.option$ - power(2,7) + power(2,0)
where  bitand(o.option$, power(2,7)) = power(2,7)
and    bitand(o.option$, 64) = 64
/
commit;

-- Set KZDOOWHO instead of KZDOOFEDWHO in objauth$
update objauth$ o
set    o.option$ = o.option$ - power(2,8) + power(2,1)
where  bitand(o.option$, power(2,8)) = power(2,8)
and    bitand(o.option$, 64) = 64
/
commit;

-- Clear Application bit KZDOOFED in objauth$
update objauth$ o
set    o.option$ = o.option$ - 64
where  bitand(o.option$, 64) = 64
/
commit;

-- Reset approot_to_pdb property
exec dbms_pdb.noncdb_to_pdb(8);

alter system flush shared_pool;

-- Restore PDB to the state it was found in
alter pluggable database "&pdbname" close;

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

@?/rdbms/admin/sqlsessend.sql
