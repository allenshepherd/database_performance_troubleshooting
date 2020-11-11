Rem
Rem $Header: rdbms/admin/utlmmig.sql /main/41 2017/08/03 17:44:03 wesmith Exp $
Rem
Rem utlmmig.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlmmig.sql - Mini MIGration for Bootstrap objects
Rem
Rem    DESCRIPTION
Rem      This mini migration script replaces bootstrap tables with new
Rem      definitions and new indexes.
Rem
Rem      Mini Migration is done in the following steps:
Rem      0. Logminer Dictionary Conditional Special Build.
Rem      1. Create the new objects e.g. obj$mig and indexes.
Rem      2. Prepare the bootstrap sql text for the new objects.
Rem      ***
Rem      *** Any failure between step 3 and 8 will cause this script to quit
Rem      ***
Rem      3. Copy data from old table to the new table. From now on, we should
Rem         not do any more DDL.
Rem      4. Swap the name of the new tables and old tables in obj$mig.
Rem      5. Remove the old object entries in bootstrap$mig.
Rem      6. Insert the new object entries in bootstrap$mig.
Rem      7. Update dependency$ directly.
Rem      8. Forward all privilege grants from old tables to new tables.
Rem      ***
Rem      *** From this point on, ignore errors so we do shutdown the database
Rem      ***
Rem      9. Swap bootstrap$mig with bootstrap$.
Rem      10. SHUTDOWN THE DATABASE.
Rem
Rem    NOTES
Rem      If this script fails, then it must be rerun while the database is
Rem      opened in UPGRADE mode. Attempts to start the database in normal
Rem      mode will result in ORA-39714.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/utlmmig.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/utlmmig.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catmmig.sql
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wesmith     08/07/17 - bug 22187143: fix dba_part/subpart_key_columns_v$
Rem    ciyer       12/08/16 - bug 23292323: drop orphaned stats temp tables
Rem    anighosh    07/19/16 - Lrg 19627400: Make room for large obj#'s
Rem    anighosh    06/19/16 - #(23309270): Deal with LONG cols
Rem    pyam        04/06/16 - LRG 19328531: use new cols when prv ver is null
Rem    pyam        08/27/15 - 19370504: recompile DBMS_STATS before step 3
Rem    traney      11/19/14 - 19607109: long tablespace names
Rem    wesmith     05/12/14 - Project 47511: data-bound collation
Rem    traney      01/14/14 - 18074131: always run utlmmigtbls.sql
Rem    jerrede     04/22/13 - Add support for CDB
Rem    traney      02/06/13 - 16225123: improve data copying performance
Rem                           16219403: fix invalidation logic 
Rem    traney      11/08/12 - 15848223: fix running in cdb mode
Rem    gravipat    10/12/12 - use cdb_name instead of con_name to check if its
Rem                           a cdb or not
Rem    traney      08/03/12 - 14103766: props$ error row for use in CDBs
Rem    traney      07/26/12 - lrg 7149217: update obj$ after gathering stats
Rem    jerrede     06/26/12 - Set event to optionally update required stats
Rem                           during upgrade
Rem    traney      05/09/12 - lrg 6940139: invalidate dependent views
Rem    traney      03/23/12 - lrg 6762280: move _CURRENT_EDITION_OBJ redef
Rem                           to the beginning
Rem    traney      03/16/12 - bug 13715632: add agent to library$
Rem    traney      03/12/12 - bug 13719175: move stats to catuppst.sql
Rem    jerrede     03/09/12 - Bug #13719893 Correct utlusts.sql timmings
Rem    pyam        01/18/12 - add obj$ columns (signature, spares)
Rem    traney      10/06/11 - recreate clusters
Rem    brwolf      09/09/11 - 32733: finer-grained editioning
Rem    brwolf      06/21/11 - 32733: evaluation editions
Rem    jerrede     07/19/11 - Revert fix for bug 12562569
Rem    jerrede     05/19/11 - Fix bug 12562569
Rem    skayoor     04/07/11 - Project 36360: add spare columns to user$
Rem    traney      02/01/11 - 35209: longer identifiers
Rem    akruglik    02/06/09 - DBMS_STATS (used in this script) now depends on
Rem                           DBMS_UTILITY which may have gotten invalidated by
Rem                           some preceeding DDL statement, so package state
Rem                           needs to be cleared to avoid ORA-04068
Rem    achoi       11/20/08 - bootstrpa object need to be created in SYSTEM
Rem                           tablespace
Rem    achoi       05/30/08 - bug7140173
Rem    achoi       04/03/08 - change i_obj2 ordering to restore partition
Rem                           performance
Rem    achoi       07/17/07 - bug6247730 - fix "CURRENT_EDITION_OBJ"
Rem    achoi       05/14/07 - redefine "_CURRENT_EDITION_OBJ" properly
Rem    achoi       02/20/07 - add i_obj5
Rem    achoi       05/14/07 - replace "_CURRENT_EDITION_OBJ"
Rem    dvoss       02/19/07 - move whenever sqlerror
Rem    abrown      02/09/07 - Add Logminer Dictionary build
Rem    achoi       12/07/06 - invalidate those depends on USER$
Rem    achoi       11/15/06 - Created
Rem


/*****************************************************************************/
/*
 * We need to exit immediately on any error.  If this script fails, the
 * script must be run again from the beginning.
 */
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/*
 * Display start time of utlmmig
 */
SELECT sys.dbms_registry_sys.time_stamp_comp_display('UTLMMIG_BG') AS
       timestamp FROM DUAL;

/*****************************************************************************/
/*
 * Step 1 - Create the new bootstrap objects and recreate related views.
 */
/*****************************************************************************/
@@utlmmigtbls.sql

/* This table stores the new obj bootstrap sql text. */
drop table bootstrap$tmpstr;
create table bootstrap$tmpstr
( line#         number not null,                       /* statement order id */
  obj#          number not null,                            /* object number */
  sql_text      varchar2(4000) not null)                        /* statement */
/

/* This library is used to generate sqltext and to swap the bootstrap tables.
 * [23309270]: This is also used to copy default$ column from col$ to col$mig.
 */
create or replace library DBMS_DDL_INTERNAL_LIB trusted as static;
/

/* Perform the col$ copy now, because the indexes need to be created after the
 * copy (to improve performance) but before Step 2.
 */
declare

  sPrvVersion   registry$.prv_version%type;  -- Previous Version
  use_new_cols  boolean := FALSE;

begin
  sPrvVersion := sys.dbms_registry.prev_version('CATPROC');

  -- if db is newly created (previous version is null) or previous version is
  -- 12.1 or greater, include new 12.1 columns
  IF sPrvVersion is null OR
     dbms_registry.version_greater(sPrvVersion, '12.1') THEN
    use_new_cols := TRUE;
  END IF;

  -- [23309270]: Insert all columns other than default$.

  execute immediate '
insert /*+ append */ into col$mig
(OBJ#, COL#, SEGCOL#, SEGCOLLENGTH, OFFSET, NAME, TYPE#, LENGTH, FIXEDSTORAGE, 
 PRECISION#, SCALE, NULL$, DEFLENGTH, INTCOL#, PROPERTY, CHARSETID, 
 CHARSETFORM, SPARE1, SPARE2, SPARE3, SPARE4, SPARE5, SPARE6,
 EVALEDITION#, UNUSABLEBEFORE#, UNUSABLEBEGINNING#, SPARE7, SPARE8)
select
 OBJ#, COL#, SEGCOL#, SEGCOLLENGTH, OFFSET, NAME, TYPE#, LENGTH, FIXEDSTORAGE, 
 PRECISION#, SCALE, NULL$, DEFLENGTH, INTCOL#, PROPERTY, CHARSETID, 
 CHARSETFORM, SPARE1, SPARE2, SPARE3, SPARE4, SPARE5, SPARE6' ||
case when use_new_cols 
then ', EVALEDITION#, UNUSABLEBEFORE#, UNUSABLEBEGINNING#, SPARE7, SPARE8'
else ', null, null, null, null, null' end 
|| 
' from col$ ';
commit;

end;
/

-- [23309270]: Copy over not-null default$ entries from col$ to col$mig
-- Lrg 19627400: Use oracle numbers for parameter passing

declare

  -- callout to select default$ from col$ and update the same into col$mig
  procedure select_update_long(objno number, intcolno number)
    is language c library DBMS_DDL_INTERNAL_LIB
    name "select_update_long"
    with context
      parameters(context, objno OCINumber, intcolno OCINumber);

  cursor rc is select obj#, intcol#
               from col$
               where default$ is not null;

begin

  -- for each not-null default$ entry in col$, select default$ and update the
  -- same into col$mig

  for colrec in rc loop
    select_update_long(colrec.obj#, colrec.intcol#);
  end loop;

  commit;

end;
/

create unique index i_col_mig1 on col$mig(obj#, name)
  storage (initial 30k next 100k maxextents unlimited pctincrease 0)
  tablespace system
/
create index i_col_mig2 on col$mig(obj#, col#)
  storage (initial 30k next 100k maxextents unlimited pctincrease 0)
  tablespace system
/
create unique index i_col_mig3 on col$mig(obj#, intcol#)
  storage (initial 30k next 100k maxextents unlimited pctincrease 0)
  tablespace system
/

declare
  sPrvVersion   registry$.prv_version%type;  -- Previous Version
  use_new_cols  boolean := FALSE;
begin
  sPrvVersion := sys.dbms_registry.prev_version('CATPROC');

  -- if db is newly created (previous version is null) or previous version is
  -- 12.1 or greater, include new 12.1 columns
  IF sPrvVersion is null OR
     dbms_registry.version_greater(sPrvVersion, '12.1') THEN
    use_new_cols := TRUE;
  END IF;

  execute immediate '
insert /*+ APPEND */ into user$mig 
(user#,name,type#,password,datats#,tempts#,ctime,ptime,exptime,ltime,
 resource$,audit$,defrole,defgrp#,defgrp_seq#,astatus,lcount,defschclass,
 ext_username,spare1,spare2,spare3,spare4,spare5,spare6,
 spare7,spare8,spare9,spare10,spare11)
select user#,name,type#,password,datats#,tempts#,ctime,ptime,exptime,ltime,
 resource$,audit$,defrole,defgrp#,defgrp_seq#,astatus,lcount,defschclass,
 ext_username,spare1,spare2,spare3,spare4,spare5,spare6' ||
case when use_new_cols 
then ',spare7,spare8,spare9,spare10,spare11'
else ',null,null,null,null,null' end 
|| 
' from user$';

commit;

end;
/

create unique index i_user_mig1 on user$mig(name) tablespace system
/
create unique index i_user_mig2 on user$mig(user#, type#, spare1, spare2)
 tablespace system
/

insert /*+ APPEND */ into con$mig (CON#,NAME,OWNER#,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6) select CON#,NAME,OWNER#,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6 from con$;
commit;
create unique index i_con_mig1 on con$mig(owner#, name)
/
create unique index i_con_mig2 on con$mig(con#)
/

/* Copy data for the tables created in Step 1B. */
insert /*+ APPEND */ into lob$mig (OBJ#,COL#,INTCOL#,LOBJ#,PART#,IND#,TS#,FILE#,BLOCK#,CHUNK,PCTVERSION$,FLAGS,PROPERTY,RETENTION,FREEPOOLS,SPARE1,SPARE2,SPARE3) select OBJ#,COL#,INTCOL#,LOBJ#,PART#,IND#,TS#,FILE#,BLOCK#,CHUNK,PCTVERSION$,FLAGS,PROPERTY,RETENTION,FREEPOOLS,SPARE1,SPARE2,SPARE3 from lob$;
commit;
create index i_lob1mig on lob$mig(obj#, intcol#)
/
create unique index i_lob2mig on lob$mig(lobj#)
/

insert /*+ APPEND */ into coltype$mig (OBJ#,COL#,INTCOL#,TOID,VERSION#,PACKED,INTCOLS,INTCOL#S,FLAGS,TYPIDCOL#,SYNOBJ#) select OBJ#,COL#,INTCOL#,TOID,VERSION#,PACKED,INTCOLS,INTCOL#S,FLAGS,TYPIDCOL#,SYNOBJ# from coltype$;
commit;
create index i_coltype1mig on coltype$mig(obj#, col#)
/
create unique index i_coltype2mig on coltype$mig(obj#, intcol#)
/

insert /*+ APPEND */ into subcoltype$mig (OBJ#,INTCOL#,TOID,VERSION#,INTCOLS,INTCOL#S,FLAGS,SYNOBJ#) select OBJ#,INTCOL#,TOID,VERSION#,INTCOLS,INTCOL#S,FLAGS,SYNOBJ# from subcoltype$;
commit;
create index i_subcoltype1mig on subcoltype$mig(obj#, intcol#)
/

insert /*+ APPEND */ into ntab$mig (OBJ#,COL#,INTCOL#,NTAB#,NAME) select OBJ#,COL#,INTCOL#,NTAB#,NAME from ntab$;
commit;
create index i_ntab1mig on ntab$mig(obj#, col#)
/
create unique index i_ntab2mig on ntab$mig(obj#, intcol#)
/
create index i_ntab3mig on ntab$mig(ntab#)
/

insert /*+ APPEND */ into refcon$mig (OBJ#,COL#,INTCOL#,REFTYP,STABID,EXPCTOID) select OBJ#,COL#,INTCOL#,REFTYP,STABID,EXPCTOID from refcon$;
commit;
create index i_refcon1mig on refcon$mig(obj#, col#)
/
create unique index i_refcon2mig on refcon$mig(obj#, intcol#)
/

insert /*+ APPEND */ into opqtype$mig (OBJ#,INTCOL#,TYPE,FLAGS,LOBCOL,OBJCOL,EXTRACOL,SCHEMAOID,ELEMNUM,SCHEMAURL) select OBJ#,INTCOL#,TYPE,FLAGS,LOBCOL,OBJCOL,EXTRACOL,SCHEMAOID,ELEMNUM,SCHEMAURL from opqtype$;
commit;
create unique index i_opqtype1mig on opqtype$mig(obj#, intcol#)
/

insert /*+ APPEND */ into viewtrcol$mig (OBJ#,INTCOL#,ATTRIBUTE#,NAME) select OBJ#,INTCOL#,ATTRIBUTE#,NAME from viewtrcol$;
commit;
create unique index i_viewtrcol1mig on viewtrcol$mig(obj#, intcol#,attribute#)
/

insert /*+ APPEND */ into attrcol$mig (OBJ#,INTCOL#,NAME) select OBJ#,INTCOL#,NAME from attrcol$;
commit;
create unique index i_attrcol1mig on attrcol$mig(obj#, intcol#)
/

insert /*+ APPEND */ into ts$mig (TS#,NAME,OWNER#,ONLINE$,CONTENTS$,UNDOFILE#,UNDOBLOCK#,BLOCKSIZE,INC#,SCNWRP,SCNBAS,DFLMINEXT,DFLMAXEXT,DFLINIT,DFLINCR,DFLMINLEN,DFLEXTPCT,DFLOGGING,AFFSTRENGTH,BITMAPPED,PLUGGED,DIRECTALLOWED,FLAGS,PITRSCNWRP,PITRSCNBAS,OWNERINSTANCE,BACKUPOWNER,GROUPNAME,SPARE1,SPARE2,SPARE3,SPARE4) select TS#,NAME,OWNER#,ONLINE$,CONTENTS$,UNDOFILE#,UNDOBLOCK#,BLOCKSIZE,INC#,SCNWRP,SCNBAS,DFLMINEXT,DFLMAXEXT,DFLINIT,DFLINCR,DFLMINLEN,DFLEXTPCT,DFLOGGING,AFFSTRENGTH,BITMAPPED,PLUGGED,DIRECTALLOWED,FLAGS,PITRSCNWRP,PITRSCNBAS,OWNERINSTANCE,BACKUPOWNER,GROUPNAME,SPARE1,SPARE2,SPARE3,SPARE4 from ts$;
commit;
create unique index i_ts1mig on ts$mig(name)
/


/*****************************************************************************/
/* Step 2 - Prepare the bootstrap sql text for the new objects
*/
/*****************************************************************************/

/* A transaction needs to be active for the callout to work. Don't commit until
 * the end of the following anonymous block.
 */
drop table bootstrap$dummy;
create table bootstrap$dummy (col1 number)
/
insert into bootstrap$dummy values (5);


declare
  pl_max_line_num number;                /* current max line # in bootstrap$ */
                   /* used for new bootstrap objects. see get_line_num below */

  /* Get Obj Number in OBJ$
     Given the obj name and namespace, return the obj# in obj$.
  */
  function get_obj_num(pl_objname varchar2, pl_nmspc number) return number
  is
    pl_obn number;
  begin
    select obj# into pl_obn from sys.obj$
      where owner#=0 and name=pl_objname and namespace=pl_nmspc
        and linkname is null and subname is null;

    return pl_obn;
  end;

  /* Get Line Number in bootstrap$
     Given the obj name and namespace, returns the line# in boostrap$. If the
     obj doesn't exists, then incr pl_max_line_num and return it - this can 
     happen for an index that didn't exist pre-upgrade.
  */
  function get_line_num(pl_objname varchar2, pl_nmspc number) return number
  is
    pl_bln number;
  begin
    select b.line# into pl_bln
    from sys.bootstrap$ b, sys.obj$ o
    where o.owner#    = 0
      and o.name      = pl_objname
      and o.obj#      = b.obj#
      and o.namespace = pl_nmspc;

    return pl_bln;
  exception
    when NO_DATA_FOUND then
      pl_max_line_num := pl_max_line_num + 1;
    return pl_max_line_num;
  end;
  
  -- callout to generate the sqltext
  function gen_sqltext(pobjname in varchar2, nmspc in pls_integer,
                       idxname in varchar2) return varchar2
    is language c library DBMS_DDL_INTERNAL_LIB
    name "gen_sqltext"
    with context
      parameters(context, pobjname String, pobjname LENGTH ub2, nmspc ub2,
                 idxname String, idxname LENGTH ub2, idxname INDICATOR sb2,
                 return LENGTH ub2, return INDICATOR sb2, return String);
  
  -- invokes the above callout and inserts a row in bootstrap$tmpstr
  procedure add_sqltext(pl_objname in varchar2, pl_oldobjname in varchar2, 
                        pl_nmspc in number, pl_pobjname in varchar2, 
                        pl_pobjnmspc in number)
  is
    pl_objtxt       varchar2(4000);   /* bootstrap$.sql_text for the new obj */
    pl_obj_num      number;           /* obj# of the new obj */
    pl_line_num     number;           /* line# in bootstrap$ for the new obj */
  begin
    pl_obj_num  := get_obj_num(pl_objname, pl_nmspc);
    pl_line_num := get_line_num(pl_oldobjname, pl_nmspc);
    
    -- for an index, pass parent object name plus index name
    if pl_nmspc = 4 then
      pl_objtxt := gen_sqltext(pl_pobjname, pl_pobjnmspc, pl_objname);
    else
      pl_objtxt := gen_sqltext(pl_objname, pl_nmspc, NULL);
    end if;
    
    -- remove the "MIG" from object names in sqltext
    pl_objtxt := replace(pl_objtxt, '_MIG');
    pl_objtxt := replace(pl_objtxt, 'MIG');
    
    insert into bootstrap$tmpstr values(pl_line_num, pl_obj_num, pl_objtxt);
  end;

begin
  -- initialize max_line_num for get_line_num above
  select max(line#) into pl_max_line_num from sys.bootstrap$;
  
  -- generate sqltext and insert into bootstrap$tmpstr
  add_sqltext('OBJ$MIG', 'OBJ$', 1, NULL, NULL);
  add_sqltext('I_OBJ_MIG1', 'I_OBJ1', 4, 'OBJ$MIG', 1);
  add_sqltext('I_OBJ_MIG2', 'I_OBJ2', 4, 'OBJ$MIG', 1);
  add_sqltext('I_OBJ_MIG3', 'I_OBJ3', 4, 'OBJ$MIG', 1);
  add_sqltext('I_OBJ_MIG4', 'I_OBJ4', 4, 'OBJ$MIG', 1);
  add_sqltext('I_OBJ_MIG5', 'I_OBJ5', 4, 'OBJ$MIG', 1);
  
  add_sqltext('USER$MIG', 'USER$', 1, NULL, NULL);
  add_sqltext('I_USER_MIG1', 'I_USER1', 4, 'USER$MIG', 1);
  add_sqltext('I_USER_MIG2', 'I_USER2', 4, 'USER$MIG', 1);
  
  add_sqltext('COL$MIG', 'COL$', 1, NULL, NULL);
  add_sqltext('I_COL_MIG1', 'I_COL1', 4, 'COL$MIG', 1);
  add_sqltext('I_COL_MIG2', 'I_COL2', 4, 'COL$MIG', 1);
  add_sqltext('I_COL_MIG3', 'I_COL3', 4, 'COL$MIG', 1);
  
  add_sqltext('CLU$MIG', 'CLU$', 1, NULL, NULL);
  
  add_sqltext('CON$MIG', 'CON$', 1, NULL, NULL);
  add_sqltext('I_CON_MIG1', 'I_CON1', 4, 'CON$MIG', 1);
  add_sqltext('I_CON_MIG2', 'I_CON2', 4, 'CON$MIG', 1);
  
  add_sqltext('C_OBJ#MIG', 'C_OBJ#', 5, NULL, NULL);
  add_sqltext('I_OBJ#MIG', 'I_OBJ#', 4, 'C_OBJ#MIG', 5);
  
  add_sqltext('C_USER#MIG', 'C_USER#', 5, NULL, NULL);
  add_sqltext('I_USER#MIG', 'I_USER#', 4, 'C_USER#MIG', 5);
  
  add_sqltext('TAB$MIG', 'TAB$', 1, NULL, NULL);
  add_sqltext('I_TAB1MIG', 'I_TAB1', 4, 'TAB$MIG', 1);
  
  add_sqltext('IND$MIG', 'IND$', 1, NULL, NULL);
  add_sqltext('I_IND1MIG', 'I_IND1', 4, 'IND$MIG', 1);
  
  add_sqltext('ICOL$MIG', 'ICOL$', 1, NULL, NULL);
  add_sqltext('I_ICOL1MIG', 'I_ICOL1', 4, 'ICOL$MIG', 1);
  
--  add_sqltext('TS$MIG', 'TS$', 1, NULL, NULL);
--  add_sqltext('I_TS1MIG', 'I_TS1', 4, 'TS$MIG', 1);

--  add_sqltext('FET$MIG', 'FET$', 1, NULL, NULL);
  
--  add_sqltext('C_TS#MIG', 'C_TS#', 5, NULL, NULL);
--  add_sqltext('I_TS#MIG', 'I_TS#', 4, 'C_TS#MIG', 5);
  
  add_sqltext('BOOTSTRAP$MIG', 'BOOTSTRAP$', 1, NULL, NULL);
  
  commit;
end;
/

drop table bootstrap$dummy;

/* compile DBMS_STATS to prevent later implicit compilation, since DDLs
 * are disallowed from Step 3 onwards.
 */
alter package dbms_stats compile body reuse settings;

execute dbms_session.reset_package;

/* bug 23292323: drop orphaned dbms_stats temporary tables
 *
 * Various dbms_stats routines create temporary tables. These tables can
 * be orphaned if the stats operation is interrupted. dbms_stats will
 * drop these orphaned tables on next invocation.
 * 
 * Step 3 can invoke dbms_stats in catrequired.sql.
 *
 * We don't want DDL operations to happen once Step 3 starts. Call dbms_stats
 * to drop orphaned temp tables before proceeding with Step 3.
 */
begin
  dbms_stats_internal.drop_old_temp(2147483647);
end;
/

/*****************************************************************************/
/*
 * Step 3 - Copy data from old tables to the new tables.
 *
 * There must be no DDL from now on.
 */
/*****************************************************************************/
declare
  sPrvVersion   registry$.prv_version%type;  -- Previous Version
  use_new_cols  boolean := FALSE;

begin
  sPrvVersion := sys.dbms_registry.prev_version('CATPROC');

  -- if db is newly created (previous version is null) or previous version is
  -- 12.1 or greater, include new 12.1 columns
  IF sPrvVersion is null OR
     dbms_registry.version_greater(sPrvVersion, '12.1') THEN
    use_new_cols := TRUE;
  END IF;

  execute immediate '
insert /*+ APPEND */ into obj$mig
(obj#, dataobj#, owner#, name, namespace, subname, type#, ctime, mtime,
 stime, status, remoteowner, linkname, flags, oid$, spare1, spare2,
 spare3, spare4, spare5, spare6, signature, spare7, spare8, spare9)
select
 obj#, dataobj#, owner#, name, namespace, subname, type#, ctime, mtime,
 stime, status, remoteowner, linkname, flags, oid$, spare1, spare2,
 spare3, spare4, spare5, spare6' ||
case when use_new_cols 
then ', signature, spare7, spare8, spare9'
else ', null, 0, 0, 0' end 
|| 
' from obj$';

commit;

insert /*+ APPEND */ into clu$mig (AVGCHN,BLOCK#,COLS,DATAOBJ#,DEGREE,EXTIND,FILE#,FLAGS,FUNC,HASHFUNC,HASHKEYS,INITRANS,INSTANCES,MAXTRANS,OBJ#,PCTFREE$,PCTUSED$,SIZE$,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6,SPARE7,TS#) select AVGCHN,BLOCK#,COLS,DATAOBJ#,DEGREE,EXTIND,FILE#,FLAGS,FUNC,HASHFUNC,HASHKEYS,INITRANS,INSTANCES,MAXTRANS,OBJ#,PCTFREE$,PCTUSED$,SIZE$,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6,SPARE7,TS# from clu$;
insert /*+ APPEND */ into bootstrap$mig select * from bootstrap$;
commit;

/* Copy data for the tables created in Step 1B. */

  execute immediate '
insert /*+ APPEND */ into ind$mig 
(OBJ#,DATAOBJ#,TS#,FILE#,BLOCK#,BO#,INDMETHOD#,COLS,PCTFREE$,INITRANS,
 MAXTRANS,PCTTHRES$,TYPE#,FLAGS,PROPERTY,BLEVEL,LEAFCNT,DISTKEY,LBLKKEY,
 DBLKKEY,CLUFAC,ANALYZETIME,SAMPLESIZE,ROWCNT,INTCOLS,DEGREE,INSTANCES,
 TRUNCCNT,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6,
 EVALEDITION#, UNUSABLEBEFORE#, UNUSABLEBEGINNING#) 
select OBJ#,DATAOBJ#,TS#,FILE#,BLOCK#,BO#,INDMETHOD#,COLS,PCTFREE$,INITRANS,
 MAXTRANS,PCTTHRES$,TYPE#,FLAGS,PROPERTY,BLEVEL,LEAFCNT,DISTKEY,LBLKKEY,
 DBLKKEY,CLUFAC,ANALYZETIME,SAMPLESIZE,ROWCNT,INTCOLS,DEGREE,INSTANCES,
 TRUNCCNT,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6' ||
case when use_new_cols 
then ', EVALEDITION#, UNUSABLEBEFORE#, UNUSABLEBEGINNING#'
else ', null, null, null' end
||
' from ind$';

insert /*+ APPEND */ into icol$mig (OBJ#,BO#,COL#,POS#,SEGCOL#,SEGCOLLENGTH,OFFSET,INTCOL#,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6) select OBJ#,BO#,COL#,POS#,SEGCOL#,SEGCOLLENGTH,OFFSET,INTCOL#,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6 from icol$;
insert /*+ APPEND */ into icoldep$mig (OBJ#,BO#,INTCOL#) select OBJ#,BO#,INTCOL# from icoldep$;
insert /*+ APPEND */ into type_misc$mig (OBJ#,AUDIT$,PROPERTIES) select OBJ#,AUDIT$,PROPERTIES from type_misc$;
insert /*+ APPEND */ into library$mig (OBJ#,FILESPEC,PROPERTY,AUDIT$,AGENT,LEAF_FILENAME) select OBJ#,FILESPEC,PROPERTY,AUDIT$,AGENT,LEAF_FILENAME from library$;
insert /*+ APPEND */ into assembly$mig (OBJ#,FILESPEC,SECURITY_LEVEL,IDENTITY,PROPERTY,AUDIT$) select OBJ#,FILESPEC,SECURITY_LEVEL,IDENTITY,PROPERTY,AUDIT$ from assembly$;
insert /*+ APPEND */ into tsq$mig (TS#,USER#,GRANTOR#,BLOCKS,MAXBLOCKS,PRIV1,PRIV2,PRIV3) select TS#,USER#,GRANTOR#,BLOCKS,MAXBLOCKS,PRIV1,PRIV2,PRIV3 from tsq$;
insert /*+ APPEND */ into tab$mig (OBJ#,DATAOBJ#,TS#,FILE#,BLOCK#,BOBJ#,TAB#,COLS,CLUCOLS,PCTFREE$,PCTUSED$,INITRANS,MAXTRANS,FLAGS,AUDIT$,ROWCNT,BLKCNT,EMPCNT,AVGSPC,CHNCNT,AVGRLN,AVGSPC_FLB,FLBCNT,ANALYZETIME,SAMPLESIZE,DEGREE,INSTANCES,INTCOLS,KERNELCOLS,PROPERTY,TRIGFLAG,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6) select OBJ#,DATAOBJ#,TS#,FILE#,BLOCK#,BOBJ#,TAB#,COLS,CLUCOLS,PCTFREE$,PCTUSED$,INITRANS,MAXTRANS,FLAGS,AUDIT$,ROWCNT,BLKCNT,EMPCNT,AVGSPC,CHNCNT,AVGRLN,AVGSPC_FLB,FLBCNT,ANALYZETIME,SAMPLESIZE,DEGREE,INSTANCES,INTCOLS,KERNELCOLS,PROPERTY,TRIGFLAG,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6 from tab$;
insert /*+ APPEND */ into fet$mig (TS#,FILE#,BLOCK#,LENGTH) select TS#,FILE#,BLOCK#,LENGTH from fet$;
commit;

end;
/


/*****************************************************************************/
/* Delete and Gather Stats if Event turned on..!!!!! 
*/
/*****************************************************************************/

--
-- Initialize sys.props$ table for optional dictionary stats to
-- be done later in catuppst.sql, only if the _utlmmig_table_stats_gathering
-- event is set to true.  Here we just delete any entry that may have been
-- stored from a previous run.
--
set serveroutput on;
declare

  b_Props BOOLEAN := TRUE;
  c_POSTUPGRADE CONSTANT VARCHAR2(19) := 'CATREQ_POST_UPGRADE';

begin

  b_Props := sys.dbms_registry_sys.delete_props_data(c_POSTUPGRADE);
  IF (b_Props) THEN
    sys.dbms_output.put_line('utlmmig: delete_props_data: Success' );
  ELSE
    sys.dbms_output.put_line('utlmmig: delete_props_data: No Props Data' );
  END IF;

end;
/

--
-- Do all required operations
--
@@catrequired.sql

--
-- If no entry in the sys.props$ table then stats have been
-- recreated so repopulate tab$ and ind$.
--
set serveroutput on;
declare

  c_POSTUPGRADE CONSTANT VARCHAR2(19) := 'CATREQ_POST_UPGRADE';
  b_SelProps BOOLEAN := sys.dbms_registry_sys.select_props_data(c_POSTUPGRADE);
  sPrvVersion   registry$.prv_version%type;  -- Previous Version
  use_new_cols  boolean := FALSE;

begin

  sPrvVersion := sys.dbms_registry.prev_version('CATPROC');

  -- if db is newly created (previous version is null) or previous version is
  -- 12.1 or greater, include new 12.1 columns
  IF sPrvVersion is null OR
     dbms_registry.version_greater(sPrvVersion, '12.1') THEN
    use_new_cols := TRUE;
  END IF;

  /* Stats are stored in tab$ and ind$ so we need to copy the updated stats. */
  IF (b_SelProps = FALSE) THEN
    sys.dbms_output.put_line('utlmmig: b_SelProps    = FALSE');
    delete from tab$mig;
    insert into tab$mig (OBJ#,DATAOBJ#,TS#,FILE#,BLOCK#,BOBJ#,TAB#,COLS,CLUCOLS,PCTFREE$,PCTUSED$,INITRANS,MAXTRANS,FLAGS,AUDIT$,ROWCNT,BLKCNT,EMPCNT,AVGSPC,CHNCNT,AVGRLN,AVGSPC_FLB,FLBCNT,ANALYZETIME,SAMPLESIZE,DEGREE,INSTANCES,INTCOLS,KERNELCOLS,PROPERTY,TRIGFLAG,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6) select OBJ#,DATAOBJ#,TS#,FILE#,BLOCK#,BOBJ#,TAB#,COLS,CLUCOLS,PCTFREE$,PCTUSED$,INITRANS,MAXTRANS,FLAGS,AUDIT$,ROWCNT,BLKCNT,EMPCNT,AVGSPC,CHNCNT,AVGRLN,AVGSPC_FLB,FLBCNT,ANALYZETIME,SAMPLESIZE,DEGREE,INSTANCES,INTCOLS,KERNELCOLS,PROPERTY,TRIGFLAG,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6 from tab$;
    delete from ind$mig;

  execute immediate '
insert into ind$mig 
(OBJ#,DATAOBJ#,TS#,FILE#,BLOCK#,BO#,INDMETHOD#,COLS,PCTFREE$,INITRANS,
 MAXTRANS,PCTTHRES$,TYPE#,FLAGS,PROPERTY,BLEVEL,LEAFCNT,DISTKEY,LBLKKEY,
 DBLKKEY,CLUFAC,ANALYZETIME,SAMPLESIZE,ROWCNT,INTCOLS,DEGREE,INSTANCES,
 TRUNCCNT,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6,
 EVALEDITION#, UNUSABLEBEFORE#, UNUSABLEBEGINNING#) 
select OBJ#,DATAOBJ#,TS#,FILE#,BLOCK#,BO#,INDMETHOD#,COLS,PCTFREE$,INITRANS,
 MAXTRANS,PCTTHRES$,TYPE#,FLAGS,PROPERTY,BLEVEL,LEAFCNT,DISTKEY,LBLKKEY,
 DBLKKEY,CLUFAC,ANALYZETIME,SAMPLESIZE,ROWCNT,INTCOLS,DEGREE,INSTANCES,
 TRUNCCNT,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,SPARE6' ||
case when use_new_cols 
then ', EVALEDITION#, UNUSABLEBEFORE#, UNUSABLEBEGINNING#'
else ', null, null, null' end 
|| 
' from ind$';

    -- lrg 7149217: interval partitioning can create objects while gathering
    -- stats, so we need to copy them over to obj$mig.
    delete from obj$mig where name='_NEXT_OBJECT';

  execute immediate '
    insert into obj$mig
      (obj#, dataobj#, owner#, name, namespace, subname, type#, ctime, mtime,
       stime, status, remoteowner, linkname, flags, oid$, spare1, spare2,
       spare3, spare4, spare5, spare6, signature, spare7, spare8, spare9)
      select
       obj#, dataobj#, owner#, name, namespace, subname, type#, ctime, mtime,
       stime, status, remoteowner, linkname, flags, oid$, spare1, spare2,
       spare3, spare4, spare5, spare6' ||
case when use_new_cols 
then ', signature, spare7, spare8, spare9'
else ', null, 0, 0, 0' end 
|| 
'     from obj$
      where obj# not in (select obj# from obj$mig)';

    commit;
  ELSE
    sys.dbms_output.put_line('utlmmig: b_SelProps    = TRUE');
  END IF;

end;
/


/*****************************************************************************/
/* Step 4 - Swap the name of the new and old table/index in obj$mig
*/
/*****************************************************************************/
declare
  type vc_nst_type is table of varchar2(30);
  type nb_nst_type is table of number;
  old_name_array vc_nst_type;                       /* old object name array */
  new_name_array vc_nst_type;                       /* new object name array */
  ns_array       nb_nst_type;                     /* namespace of the object */
begin
  old_name_array := vc_nst_type('OBJ$',     'I_OBJ1', 'I_OBJ2', 
                                            'I_OBJ3', 'I_OBJ4',
                                            'I_OBJ5',
                                'USER$',    'I_USER1', 'I_USER2',
                                'COL$',     'I_COL1', 'I_COL2',
                                            'I_COL3',
                                'CLU$',
                                'CON$',     'I_CON1', 'I_CON2',
                                'BOOTSTRAP$',
                                'TAB$',     'I_TAB1',
                                'IND$',     'I_IND1',
                                'ICOL$',    'I_ICOL1',
                                'LOB$',     'I_LOB1', 'I_LOB2',
                                'COLTYPE$', 'I_COLTYPE1', 'I_COLTYPE2',
                                'SUBCOLTYPE$', 'I_SUBCOLTYPE1',
                                'NTAB$',    'I_NTAB1', 'I_NTAB2', 'I_NTAB3',
                                'REFCON$',  'I_REFCON1', 'I_REFCON2',
                                'OPQTYPE$', 'I_OPQTYPE1',
                                'ICOLDEP$', 'I_COLDEP$_OBJ',
                                'VIEWTRCOL$', 'I_VIEWTRCOL1',
                                'ATTRCOL$', 'I_ATTRCOL1',
                                'TYPE_MISC$',
                                'LIBRARY$',
                                'ASSEMBLY$',
                                'TSQ$',
--                                'TS$',      'I_TS1',
--                                'FET$',
                                'C_USER#',  'I_USER#',
                                'C_OBJ#',   'I_OBJ#',
--                                'C_TS#',    'I_TS#',
                                '_CURRENT_EDITION_OBJ',
                                '_ACTUAL_EDITION_OBJ',
                                'DBA_PART_KEY_COLUMNS_V$',
                                'DBA_SUBPART_KEY_COLUMNS_V$');
  new_name_array := vc_nst_type('OBJ$MIG',  'I_OBJ_MIG1', 'I_OBJ_MIG2',
                                            'I_OBJ_MIG3', 'I_OBJ_MIG4',
                                            'I_OBJ_MIG5',
                                'USER$MIG', 'I_USER_MIG1','I_USER_MIG2',
                                'COL$MIG',  'I_COL_MIG1', 'I_COL_MIG2',
                                            'I_COL_MIG3',
                                'CLU$MIG',
                                'CON$MIG',  'I_CON_MIG1', 'I_CON_MIG2',
                                'BOOTSTRAP$MIG',
                                'TAB$MIG',  'I_TAB1MIG',
                                'IND$MIG',  'I_IND1MIG',
                                'ICOL$MIG', 'I_ICOL1MIG',
                                'LOB$MIG',  'I_LOB1MIG', 'I_LOB2MIG',
                                'COLTYPE$MIG', 'I_COLTYPE1MIG', 'I_COLTYPE2MIG',
                                'SUBCOLTYPE$MIG', 'I_SUBCOLTYPE1MIG',
                                'NTAB$MIG', 'I_NTAB1MIG', 'I_NTAB2MIG', 
                                            'I_NTAB3MIG',
                                'REFCON$MIG',  'I_REFCON1MIG', 'I_REFCON2MIG',
                                'OPQTYPE$MIG', 'I_OPQTYPE1MIG',
                                'ICOLDEP$MIG', 'I_COLDEP$_OBJMIG',
                                'VIEWTRCOL$MIG', 'I_VIEWTRCOL1MIG',
                                'ATTRCOL$MIG', 'I_ATTRCOL1MIG',
                                'TYPE_MISC$MIG',
                                'LIBRARY$MIG',
                                'ASSEMBLY$MIG',
                                'TSQ$MIG',
--                                'TS$MIG',    'I_TS1MIG',
--                                'FET$MIG',
                                'C_USER#MIG', 'I_USER#MIG',
                                'C_OBJ#MIG', 'I_OBJ#MIG',
--                                'C_TS#MIG',  'I_TS#MIG',
                                '_CURRENT_EDITION_OBJ_MIG',
                                '_ACTUAL_EDITION_OBJ_MIG',
                                'DBA_PART_KEY_COLUMNS_V$_MIG',
                                'DBA_SUBPART_KEY_COLUMNS_V$_MIG');
  ns_array       := nb_nst_type(1,4,4,4,4,4,
                                1,4,4,
                                1,4,4,4,
                                1,
                                1,4,4,
                                1,
                                1,4,
                                1,4,
                                1,4,
                                1,4,4,
                                1,4,4,
                                1,4,
                                1,4,4,4,
                                1,4,4,
                                1,4,
                                1,4,
                                1,4,
                                1,4,
                                1,
                                1,
                                1,
                                1,
--                                1,4,
--                                1,
                                5,4,
                                5,4,
--                                5,4,
                                1,
                                1,
                                1,
                                1);

  /* Swap the name in old_name_array with new_name_array in OBJ$MIG */
  for i in old_name_array.FIRST .. old_name_array.LAST
  loop
    update obj$mig set name = 'ORA$MIG_TMP'
      where name = old_name_array(i) and owner# = 0 and namespace=ns_array(i);
    update obj$mig set name = old_name_array(i)
      where name = new_name_array(i) and owner# = 0 and namespace=ns_array(i);
    update obj$mig set name = new_name_array(i)
      where name = 'ORA$MIG_TMP'     and owner# = 0 and namespace=ns_array(i);
  end loop;

  /* Commit when we're done with the swap */
  commit;
end;
/


/*****************************************************************************/
/* Step 5 - Remove the old object entries in bootstrap$mig
*/
/*****************************************************************************/
delete from bootstrap$mig where obj# in 
 (select obj# from obj$ 
  where name in ('OBJ$',  'I_OBJ1',  'I_OBJ2', 'I_OBJ3', 'I_OBJ4', 'I_OBJ5',
                 'USER$', 'I_USER1', 'I_USER2',
                 'COL$', 'I_COL1', 'I_COL2', 'I_COL3',
                 'CLU$',
                 'CON$', 'I_CON1', 'I_CON2',
                 'TAB$', 'I_TAB1',
                 'IND$', 'I_IND1',
                 'ICOL$', 'I_ICOL1',
--                 'TS$',  'I_TS1',
--                 'FET$',
                 'C_OBJ#', 'I_OBJ#',
                 'C_USER#', 'I_USER#',
--                 'C_TS#', 'I_TS#',
                 'BOOTSTRAP$'));
commit;


/*****************************************************************************/
/* Step 6 - Insert the new object entries in bootstrap$mig
*/
/*****************************************************************************/
insert into bootstrap$mig select * from bootstrap$tmpstr;
commit;


/*****************************************************************************/
/* Step 7 - Update dependency$ directly
   Step 8 - Forward all object privil from obj$/user$ to obj$mig/user$mig
*/
/*****************************************************************************/
declare
  type vc_nst_type is table of varchar2(30);
  old_obj_num number;
  new_obj_num number;
  new_ts      timestamp;
  old_name    vc_nst_type;
  new_name    vc_nst_type;
  type pobjtype is table of number;
  pobjs  pobjtype := pobjtype();
  pobjs2 pobjtype;
begin
  old_name := vc_nst_type('OBJ$',    'USER$',    'COL$',    'CLU$',    'CON$', 
                          'BOOTSTRAP$',
                          'TAB$',    'IND$',    'ICOL$',    'LOB$',   
                          'COLTYPE$',    'SUBCOLTYPE$',    'NTAB$',   
                          'REFCON$',    'OPQTYPE$',    'ICOLDEP$',   
                          'VIEWTRCOL$',   'ATTRCOL$',     'TYPE_MISC$',
                          'LIBRARY$',    'ASSEMBLY$',
--                          'TS$', 'FET$',
                          'TSQ$', '_CURRENT_EDITION_OBJ',
                          '_ACTUAL_EDITION_OBJ',
                          'DBA_PART_KEY_COLUMNS_V$',
                          'DBA_SUBPART_KEY_COLUMNS_V$');
  new_name := vc_nst_type('OBJ$MIG', 'USER$MIG', 'COL$MIG','CLU$MIG','CON$MIG', 
                          'BOOTSTRAP$MIG',
                          'TAB$MIG', 'IND$MIG', 'ICOL$MIG', 'LOB$MIG',
                          'COLTYPE$MIG', 'SUBCOLTYPE$MIG', 'NTAB$MIG',
                          'REFCON$MIG', 'OPQTYPE$MIG', 'ICOLDEP$MIG',
                          'VIEWTRCOL$MIG', 'ATTRCOL$MIG', 'TYPE_MISC$MIG',
                          'LIBRARY$MIG', 'ASSEMBLY$MIG',
--                          'TS$MIG', 'FET$MIG',
                          'TSQ$MIG', '_CURRENT_EDITION_OBJ_MIG',
                          '_ACTUAL_EDITION_OBJ_MIG',
                          'DBA_PART_KEY_COLUMNS_V$_MIG',
                          'DBA_SUBPART_KEY_COLUMNS_V$_MIG');

  for i in old_name.FIRST .. old_name.LAST
  loop
    select obj# into old_obj_num from obj$ 
      where owner#=0 and name=old_name(i) and namespace=1 and linkname is null
        and subname is null;
    select obj#, stime into new_obj_num, new_ts from obj$
      where owner#=0 and name=new_name(i) and namespace=1 and linkname is null
        and subname is null;

    -- Step 7
    update dependency$ 
      set p_obj#      = new_obj_num, 
          p_timestamp = new_ts
      where p_obj# = old_obj_num;

    -- Step 8
    update objauth$ set obj# = new_obj_num where obj# = old_obj_num;
    
    pobjs.extend;
    pobjs(pobjs.count) := new_obj_num;
  end loop;

  commit;
  
  -- Invalidate dependents of changed objects.
  loop
    exit when pobjs.count = 0;
    
    forall i in pobjs.first .. pobjs.last
      update obj$mig
        set status = 6,
            flags = case when type# = 2 
                           then (flags - bitand(flags, 524288) + 524288)
                         else flags
                    end
        where status not in (5, 6)
          and linkname is null
          and subname is null
          and obj# in (select d_obj# from dependency$
                         where p_obj# = pobjs(i)
                           and (bitand(property, 1) = 1))
      returning obj#
      bulk collect into pobjs2;
    
    pobjs := pobjs2;
  end loop;
  
  commit;
end;
/

/*****************************************************************************/
/* Step 9 - Swap bootstrap$mig with bootstrap$
*/
/*****************************************************************************/
/* According to JKLEIN, performing 3 count(*) will ensure there are
   no dirty itl's present in bootstrap$. */
select count(*) from bootstrap$;
select count(*) from bootstrap$;
select count(*) from bootstrap$;
select count(*) from bootstrap$mig;
select count(*) from bootstrap$mig;
select count(*) from bootstrap$mig;

WHENEVER SQLERROR CONTINUE 

declare
  LS_Special_3            CONSTANT NUMBER := 11;
  LOCbldlogid             VARCHAR2(22) := NULL;
  LOCLockDownScn          NUMBER;
  rowcnt                  NUMBER;
begin
  SELECT COUNT(1) into rowcnt
  FROM SYS.V$DATABASE V
  WHERE V.LOG_MODE = 'ARCHIVELOG' and
        V.SUPPLEMENTAL_LOG_DATA_MIN != 'NO';
  IF 0 != rowcnt THEN
    -- Logminer may be mining this redo stream, so we must do a special
    -- logminer dictionary build to capture the revised obj# etc.
    sys.dbms_logmnr_internal.DO_INT_BUILD(build_op=>LS_Special_3,
                                          dictionary_filename=>NULL,
                                          dictionary_location=>NULL,
                                          bldlogid_initxid=>LOCbldlogid,
                                          LockDownScn=>LOCLockDownScn,
                                          release_locks=>FALSE);
  END IF;

  -- Now we can do the swap.
  declare
    procedure swap_bootstrap(replacement_tbl_name IN VARCHAR2)
      is language c library DBMS_DDL_INTERNAL_LIB
      name "swap_bootstrap"
      with context
        parameters(context, replacement_tbl_name String,
                   replacement_tbl_name LENGTH ub2,
                   replacement_tbl_name INDICATOR sb2);
  begin
    swap_bootstrap('BOOTSTRAP$MIG');
  end;

  -- We've completed the swap.
  -- Remove the BOOTSTRAP_UPGRADE_ERROR entry in props$.
  delete from props$ where name like 'BOOTSTRAP_UPGRADE_ERROR%';
  delete from props$ where name = 'LOGMNR_BOOTSTRAP_UPGRADE_ERROR';
  commit;
end;
/

DOC
#######################################################################
#######################################################################

   The above PL/SQL lists the SERVER components in the upgraded
   database, along with their version and status at the completion of
   the component upgrade.  Any error messages generated during the 
   component upgrade are also listed.

   Please review the status and version columns and check the details
   any errors in the spool log file.  If there are errors in the spool
   file, or any components are not VALID or not the current version,
   consult the Oracle Database Upgrade Guide for troubleshooting 
   recommendations.

#######################################################################
#######################################################################
#

DOC
#######################################################################
#######################################################################
 
   This sql script is the final step of the upgrade. Please
   review any errors in the spool log file. If there are any errors in
   the spool file, consult the Oracle Database Upgrade Guide for
   troubleshooting recommendations.
 
   Next restart for normal operation, and then run utlrp.sql to
   recompile any invalid application objects.

   If the source database had an older time zone version prior to
   upgrade, then please run the DBMS_DST package.  DBMS_DST will upgrade
   TIMESTAMP WITH TIME ZONE data to use the latest time zone file shipped
   with Oracle.
 
#######################################################################
#######################################################################
#



