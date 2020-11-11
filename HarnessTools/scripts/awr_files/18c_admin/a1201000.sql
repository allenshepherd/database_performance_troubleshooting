Rem
Rem $Header: rdbms/admin/a1201000.sql /main/76 2017/11/06 13:58:58 yingzhen Exp $
Rem
Rem a1201000.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      a1201000.sql - additional ANONYMOUS BLOCK dictionary upgrade
Rem                     making use of PL/SQL packages installed by
Rem                     catproc.sql.
Rem
Rem    DESCRIPTION
Rem      Additional upgrade script to be run during the upgrade of an
Rem      12.1.0.1 database to 12.1.0.2 patch release.
Rem
Rem      This script is called from catupgrd.sql and a1102000.sql
Rem
Rem      Put any anonymous block related changes here.
Rem      Any dictionary create, alter, updates and deletes  
Rem      that must be performed before catalog.sql and catproc.sql go 
Rem      in c1201000.sql
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: upgrade from 12.1.0.1 to the current release
Rem        STAGE 2: invoke script for subsequent release
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/a1201000.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/a1201000.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupprc.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       yingzhen 10/26/17 - Bug 26994266: disable index before insert for
Rem                           WRH$_SYSMETRIC_HISTORY
Rem       pyam     09/25/17 - Bug 26845712: pass in format string to to_date
Rem       amunnoli 05/26/17 - Bug 25245797: Uniaud objects are owned by AUDSYS
Rem       cmlim    05/01/17 - bug 25248712 - cut down on # of parallel slaves
Rem                           spawned
Rem       raeburns 03/09/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem       aanverma 06/23/16 - Bug 23515378: revoke select on audit views
Rem       alui     06/08/16 - bug 23491507: revoke execute privilege on
Rem                           dbms_wlm from DBA
Rem       welin    06/02/16 - invoking subsequent release
Rem       thbaby   04/13/16 - Bug 23039033: skip app object check in
Rem                           cleanup_transient_type, cleanup_transient_pkg
Rem       thbaby   04/13/16 - Bug 23030152: skip app object check in
Rem                           cleanup_online_pmo
Rem       atomar   04/11/16 - bug 22685328 with 2k block size we are supporting
Rem                           only 128 byte subscribers
Rem       raeburns 03/22/16 - Bug 22820096: Add alter table to validate queue
Rem                           tables for -T option (READ ONLY tablespaces)
Rem       rmorant  03/09/16 - bug22865302 catch expected error
Rem       desingh  03/09/16 - handle ORA-1647 during create delay index on
Rem                           upgrade
Rem       shbose   02/26/16 - lrg 19280011: correct exception block for
Rem                           create_eviction_table
Rem       aanverma 02/24/16 - Bug #22552142: STIG profile update on upgrade
Rem       atomar   02/19/16 - create_eviction_table remove storage param
Rem                           bug 22629449     
Rem       atomar   02/01/16 - bug 22642228 move upgrade unsharded AQ views to
Rem                           xrdu121.sql
Rem       atomar   01/19/16 - bug 21135445: upgrade AQ non-sharded views
Rem       rmorant  01/13/16 - Bug22345045 create partitions for new awr tables
Rem       tchorma  01/12/16 - bug 22528166:dont skip fixupcolinfo for varrays
Rem       sjanardh 11/25/15 - Replace dbms_aqadm_syscalls APIs with dbms_aqadm_sys APIs
Rem       rmorant  10/08/15 - lrg 18558353 create partitions for changes in bug
Rem                           19651064
Rem       atomar   10/06/15 - bug 21956342 upgrade single consumer queues
Rem       shbose   10/05/15 - bug 21193221: add new eviction table for sharded
Rem                           queues
Rem       yanlili  09/25/15 - Fix lrg 18552097: Do not allow grant schema
Rem                           privilege on SYS schema
Rem       jstenois 09/24/15 - 21816303: move alter of opatch_xml_inv to after
Rem                           upgrade script
Rem       shjoshi  09/09/15 - bug20540751: Do not drop auto sqltune program
Rem       desingh  09/07/15 - bug21797512: ugrade 12c view
Rem       yanlili  06/22/15 - Fix bug 20897609: grant create session privilege
Rem                           for existing RAS direct logon users
Rem       atomar   06/15/15 - bug 20512406 pre 12.1 needs NULL handling 
Rem                           during queue table upgrade.   
Rem       yanlili  05/01/15 - Bug 19880667: Drop db role xs_resource
Rem                           and grant admin_sec_policy instead
Rem       hmohanku 04/20/15 - bug 20511242: support long identifier in
Rem                           DBMS_AUDIT_MGMT, TSDP metadata tables
Rem       tchorma  02/27/15 - Bug 19696268 - Mark tables with REFs on upgrade
Rem       msoudaga 02/23/15 - Bug 16028065: Remove role DELETE_CATALOG_ROLE
Rem       amorimur 01/09/15 - bug(20319569): for RAC AWR report
Rem       atomar   01/02/15 - bug 19559576
Rem       abrown   12/23/14 - bug 20105469 requires logminer cache cleanout
Rem       atomar   12/09/14 - exception queue phase 2
Rem       youyang  12/08/14 - lrg14341300: move PA alter table from
Rem                           c1201000.sql
Rem       kyagoub  11/20/14 - bug#17526672: revoke select catolog from
Rem                           CDB_advisor_object_types
Rem       desingh  09/17/14 - proj45944:sharded queue delay
Rem       yanlili  11/30/14 - Fix bug 20019217: drop view
Rem                           DBA_XS_ENB_AUDIT_POLICIES
Rem       atomar   11/26/14 - exception queue
Rem       jorgrive 11/19/14 - Desupport Advanced Replication, invoke catnorep
Rem       cderosa  11/17/14 - Setup for incremental table prefs on Logminer
Rem                           tables.
Rem       pyam     11/17/14 - lrg 13206810: job to clean up settings$ rows
Rem       ctong    11/13/14 - bug 19926571: set FixUpNeededMask if col# and
Rem                           intcol# are mismatched
Rem       desingh  09/17/14 - proj45944:sharded queue delay
Rem       svivian  09/03/14 - bug 18529468: upgrade spill for long identifiers
Rem       dhdhshah 08/05/14 - 18718931: clean up ilmobj$ on upgrade
Rem       thbaby   07/14/14 - 18971004: drop INT$ views added for OBL support
Rem       atomar   05/30/14 - bug 18872448 dqt default val
Rem       ashrives 05/27/14 - 18543824: Create index on ilm_results$
Rem       atomar   05/22/14 - bug 18799102 correct subshard,flag,THRESHOLD 
Rem       amozes   05/11/14 - ODM 12.2 changes
Rem       pyam     05/09/14 - populate pdb_sync$ on 12.1.0.1->x upgrade
Rem       devghosh 03/27/14 - bug17709018: grant for 11.2 queue
Rem       kyagoub  03/11/14 - bug-18290927: add force to sqltune drop_program
Rem       ddadashe 02/20/14 - drop datamining programs
Rem       praghuna 01/20/13 - lrg9150974:Populate PTO recovery info         
Rem       pyam     12/10/13 - 17709180: drop public synonym htmldb_system
Rem       amullick 12/05/13 - Bug17526562: revoke grant SELECT ON 
Rem                           CDB_SECUREFILE views from SELECT_CATALOG_ROLE
Rem       yiru     11/26/13 - Bug 17515547: revoke SELECT ON CDB_XS_xxx session
Rem                           and audit views from SELECT_CATALOG_ROLE
Rem       ssonawan 11/24/13 - Bug 17513956: revoke grant ON CDB_AUDIT_MGMT
Rem                           views from SELECT_CATALOG_ROLE
Rem       jheng    09/27/13 - Bug 17515047: revoke grant SELECT ON CDB_xx PA
Rem                           views from SELECT_CATALOG_ROLE
Rem       sragarwa 10/10/13 - Bug 17303407: Revoke delete on aud$ and
Rem                           fga_log$ from delete_catalog_role
Rem       rpang    09/04/13 - Add network ACLs to noexp$
Rem       lvbcheng 08/26/13 - 17356189: Drop HTMLDB_SYSTEM when present
Rem       rpang    08/06/13 - 7185425: upgrade SQL ID/hash for SQL translation
Rem                           profiles
Rem       mthiyaga 07/09/13 - Bug 16924879: drop QSMA related public synonyms
Rem       kyagoub  06/11/13 - bug16654392: upgrade auto_sql_tuning_prog
Rem       tchorma  06/06/13 - Bug16622082 - Logminer dict - mark Top-level
Rem                           varrays on upgrade
Rem       tchorma  05/14/13 - Bug16769846 Fix Logminer krvxoa ANYDATA handling
Rem       jerrede  03/28/13 - Add Support for CDB
Rem       sdball   03/06/13 - Move GDS upgrade code to c1201000.sql
Rem       jkati    02/28/13 - bug#16080525: audit DBMS_RLS for traditional
Rem                           audit
Rem       sdball   02/14/13 - Bugs 16269799,16269848: Upgrade changes for GDS
Rem    cdilling    10/16/12

Rem *************************************************************************
Rem BEGIN a1201000.sql
Rem *************************************************************************

Rem =======================================================================
Rem Begin 18543824: Add index
Rem =======================================================================
create index i_ilmresults_status on ilm_results$(job_status)
tablespace SYSAUX
/

Rem =======================================================================
Rem End bug 18543824
Rem =======================================================================

Rem ====================================================================
Rem Begin Changes for Traditional Audit
Rem ====================================================================

Rem
Rem Support for CDB Trap for ORA-65040: operation not allowed
Rem from within a pluggable database
Rem

BEGIN
 EXECUTE IMMEDIATE 'AUDIT EXECUTE ON DBMS_RLS BY ACCESS';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -65040) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ====================================================================
Rem End Changes for Traditional Audit
Rem ====================================================================


Rem ====================================================================
Rem Begin Changes for Data Mining Java API
Rem ====================================================================
Rem 
Rem bug#18096032: drop JDM  programs if already exist. 
Rem 

begin 
  -- drop program  
  dbms_scheduler.drop_program('sys.jdm_build_program');

exception
  when others then
    if (sqlcode = -27476)     -- program does not exist
    then
      null;                   -- ignore it
    else
      raise;                  -- non expected errors
    end if;
end; 
/

begin 
  -- drop program  
  dbms_scheduler.drop_program('sys.jdm_test_program');

exception
  when others then
    if (sqlcode = -27476)     -- program does not exist
    then
      null;                   -- ignore it
    else
      raise;                  -- non expected errors
    end if;
end; 
/

begin 
  -- drop program  
  dbms_scheduler.drop_program('sys.jdm_sql_apply_program');

exception
  when others then
    if (sqlcode = -27476)     -- program does not exist
    then
      null;                   -- ignore it
    else
      raise;                  -- non expected errors
    end if;
end; 
/

begin 
  -- drop program  
  dbms_scheduler.drop_program('sys.jdm_export_program');

exception
  when others then
    if (sqlcode = -27476)     -- program does not exist
    then
      null;                   -- ignore it
    else
      raise;                  -- non expected errors
    end if;
end; 
/

begin 
  -- drop program  
  dbms_scheduler.drop_program('sys.jdm_import_program');

exception
  when others then
    if (sqlcode = -27476)     -- program does not exist
    then
      null;                   -- ignore it
    else
      raise;                  -- non expected errors
    end if;
end; 
/

begin 
  -- drop program  
  dbms_scheduler.drop_program('sys.jdm_xform_program');

exception
  when others then
    if (sqlcode = -27476)     -- program does not exist
    then
      null;                   -- ignore it
    else
      raise;                  -- non expected errors
    end if;
end; 
/

begin 
  -- drop program  
  dbms_scheduler.drop_program('sys.jdm_predict_program');

exception
  when others then
    if (sqlcode = -27476)     -- program does not exist
    then
      null;                   -- ignore it
    else
      raise;                  -- non expected errors
    end if;
end; 
/

begin 
  -- drop program  
  dbms_scheduler.drop_program('sys.jdm_explain_program');

exception
  when others then
    if (sqlcode = -27476)     -- program does not exist
    then
      null;                   -- ignore it
    else
      raise;                  -- non expected errors
    end if;
end; 
/

begin 
  -- drop program  
  dbms_scheduler.drop_program('sys.jdm_profile_program');

exception
  when others then
    if (sqlcode = -27476)     -- program does not exist
    then
      null;                   -- ignore it
    else
      raise;                  -- non expected errors
    end if;
end; 
/

begin 
  -- drop program  
  dbms_scheduler.drop_program('sys.jdm_xform_seq_program');

exception
  when others then
    if (sqlcode = -27476)     -- program does not exist
    then
      null;                   -- ignore it
    else
      raise;                  -- non expected errors
    end if;
end; 
/

Rem ====================================================================
Rem End Changes for Data Mining Java API
Rem ====================================================================


Rem =======================================================================
Rem  Begin Changes for Logminer
Rem =======================================================================
  
Rem Updates to LOGMNRC_GTLO and LOGMNRC_GTCS are performed in "a" scripts
Rem instead of "c" scripts for performance reason. Logminer may call 
Rem logmnr_dict_cache.cleanout in "a" scripts, which reduces the number of
Rem rows in LOGMNRC_* tables.

/* 
 * bug 20105469 requires logminer cache cleanout
 */

declare
  cursor uid_cursor is
       select logmnr_uid from system.logmnr_uid$;
begin
  for uid_rec in uid_cursor loop
    logmnr_dict_cache.cleanout(uid_rec.logmnr_uid, null, null);
    commit;
  end loop;
end;
/

  /* Bug 16769846
  * Complextypecols should have KRVX_OA_ANYDATA set whenever the table 
  * has a SYS.ANYDATA column or its PUBLIC.ANYDATA synonym.
  */
update system.logmnrc_gtlo tlo
  set tlo.complextypecols = tlo.complextypecols + 32
  where 0 = bitand (tlo.complextypecols, 32) /* KRVX_OA_ANYDATA */
        and                           /* Any opaques are present */
        8 = bitand (tlo.unsupportedcols, 8)  /* KRVX_OA_OPAQUES */
        and  /* There is a SYS.ANYDATA or PUBLIC.ANYDATA present */
        exists 
         (select 1 from  system.logmnrc_gtcs tcs
          where tcs.logmnr_uid = tlo.logmnr_uid AND
                tcs.obj# = tlo.BASEOBJ# AND
                tcs.objv# = tlo.BASEOBJV# AND
                tcs.type# = 58 /* OPAQUE */ AND
                tcs.XTYPENAME = 'ANYDATA' AND
                (tcs.XTYPESCHEMANAME = 'SYS' OR 
                 tcs.XTYPESCHEMANAME = 'PUBLIC'));
commit;

 /* Bug 16622082
  * Unsupportedcols should have the KRVX_OA_TOPLVLVARRAY bit set whenever
  * the table has a non-hidden named array type.
  */
update system.logmnrc_gtlo tlo
  set tlo.unsupportedcols = tlo.unsupportedcols + 8192
  where 0 = bitand (tlo.unsupportedcols, 8192) /* KRVX_OA_TOPLVLVARRAY */
        and                           /* Varray is present */
        128 = bitand (tlo.unsupportedcols, 128) /* KRVX_OA_NAR */
        and  /* There is a non-hidden varray present */
        exists 
         (select 1 from  system.logmnrc_gtcs tcs
          where tcs.logmnr_uid = tlo.logmnr_uid AND
                tcs.obj# = tlo.BASEOBJ# AND
                tcs.objv# = tlo.BASEOBJV# AND
                tcs.type# = 123 /* Named Array */ AND
                0 = bitand(tcs.property, 32));
commit;
/* Project 43398
 * Rebuild any indexes on Logminer tables that have been 
 * left in unusable state.
 * Setup incremental stats preferences on Logminer tables.
 */
 DECLARE
    cursor unusable_index_part_cursor is
         select case when bitand(x.flags,2) = 2 
               then 'LOGMNR_' || x.name
               else x.name end logmnr_table_name,
               snam_o.subname as partition_name
         from sys.x$krvxdta x, sys.obj$ o, sys.user$ u,
              sys.ind$ i, sys.indpart$ ip,
              sys.tabpart$ tp, sys.obj$ snam_o
         where bitand(x.flags, 1) = 1 and
               (o.name = case when bitand(x.flags,2) = 2 
                         then 'LOGMNR_' || x.name
                         else x.name end) and
               o.type# = 2 and
               o.owner# = u.user# and
               u.name = 'SYSTEM' and
               o.obj# = i.bo# and
               i.obj# = ip.bo# and
               bitand(ip.flags, 1) = 1 and
               ip.part# = tp.part# and
               o.obj# = tp.bo# and
               tp.obj# = snam_o.obj# and
               snam_o.type# = 19
         order by 1;
    cursor table_name_cursor  is
      select  x.name table_name
      from sys.x$krvxdta x
      where bitand(x.flags, 12) != 0;
BEGIN
   FOR unusable_part_rec IN unusable_index_part_cursor LOOP
        execute immediate
          'alter table SYSTEM.' ||
           DBMS_ASSERT.SIMPLE_SQL_NAME(unusable_part_rec.logmnr_table_name) ||
          ' MODIFY PARTITION ' ||
           DBMS_ASSERT.SIMPLE_SQL_NAME(unusable_part_rec.partition_name) ||
          ' REBUILD UNUSABLE LOCAL INDEXES';
      END LOOP;

   for table_name_rec in table_name_cursor loop
      begin
         DBMS_STATS.SET_TABLE_PREFS('SYSTEM', 
	 'LOGMNR_'|| table_name_rec.table_name||'', 'incremental', 'TRUE');
      end;
   end loop;
END;
/


 /* Bug 19926571: KRVX_OA_TLO_SKIP_CI_FIXUP must not be set whenever the
  * table has a different col# and intcol#.
  * Update for bug 22528166 - Tables with top-level varrays, and no other
  * OOL columns (i.e. no ADTs/XMLs) will have no hidden columns, and thus the
  * col# != intcol# check won't catch them.  It's better to check the actual
  * column types to see if the table has any ADTs, Named Array types.
  */
update system.logmnrc_gtlo tlo 
  set logmnrtloflags = logmnrtloflags - 32
  where bitand(logmnrtloflags, 32) = 32 /* KRVX_OA_TLO_SKIP_CI_FIXUP */
    and exists 
      (select 1 from system.logmnrc_gtcs tcs 
       where tcs.logmnr_uid = tlo.logmnr_uid
         and tcs.obj# = tlo.baseobj#
         and tcs.objv# = tlo.baseobjv#
         and (tcs.col# <> tcs.intcol# or
              tcs.type# = 121 /* ADT */ or
              tcs.type# = 123 /* Varray */));
commit;


 /* Bug 19696268: Set gtlo REF flag during upgrade.
  */
update system.logmnrc_gtlo tlo
  set tlo.unsupportedcols = tlo.unsupportedcols + 16384
  where 0 = bitand (tlo.unsupportedcols, 16384) /* KRVX_OA_REF */
        and                           /* REF is present */
        exists 
         (select 1 from  system.logmnrc_gtcs tcs
          where tcs.logmnr_uid = tlo.logmnr_uid AND
                tcs.obj# = tlo.BASEOBJ# AND
                tcs.objv# = tlo.BASEOBJV# AND
                tcs.type# = 111 /* REF */);
commit;

Rem =======================================================================
Rem  End Changes for Logminer
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for WLM
Rem =======================================================================

Rem Bug 23491507
Rem ORA-01927 - Cannot revoke privileges you did not grant
BEGIN
  EXECUTE IMMEDIATE 'revoke execute on dbms_wlm from dba';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1927 THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem =======================================================================
Rem  End Changes for WLM
Rem =======================================================================

Rem=========================================================================
Rem BEGIN Logical Standby upgrade items
Rem=========================================================================
Rem
Rem BUG 18529468
Rem Convert Logical Standby Ckpt data from 12.1 format to 12.2 format
Rem

begin
  sys.dbms_logmnr_internal.agespill_12to122;
end;
/

Rem Begin Drop SQL Advisor Synonyms
Rem ===============================

Rem Drop all summary advisor related public synonyms created by QSMA.JAR,
Rem which is called from $ORACLE_HOME/rdbms/admin/initqsma.sql IN 10.2.

BEGIN
   FOR cur_rec IN (SELECT synonym_name
                     FROM dba_synonyms
                    WHERE synonym_name LIKE '%oracle/qsma/Qsma%' OR
                          synonym_name LIKE '%oracle/qsma/Char%' OR
                          synonym_name LIKE '%oracle/qsma/Parse%' OR
                          synonym_name LIKE '%oracle/qsma/Token%' OR
                          synonym_name LIKE '%_QsmaReport%' OR
                          synonym_name LIKE '%_QsmaSql%'
                   )
   LOOP
      BEGIN
         IF (cur_rec.synonym_name LIKE '%oracle/qsma/Qsma%' OR
             cur_rec.synonym_name LIKE '%oracle/qsma/Char%' OR
             cur_rec.synonym_name LIKE '%oracle/qsma/Parse%' OR
             cur_rec.synonym_name LIKE '%oracle/qsma/Token%' OR
             cur_rec.synonym_name LIKE '%_QsmaReport%' OR
             cur_rec.synonym_name LIKE '%_QsmaSql%')
           THEN
              EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM '
                            || DBMS_ASSERT.ENQUOTE_NAME(cur_rec.synonym_name, FALSE);
           END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
             DBMS_SYSTEM.ksdwrt(DBMS_SYSTEM.trace_file,'FAILED: DROP '
                                  || '"'
                                  || cur_rec.synonym_name
                                  || '"');
      END;
   END LOOP;
END;
/

Rem ===============================
Rem End Drop SQL Advisor Synonyms
Rem ===============================

Rem =========================================================================
Rem BEGIN SQL Translation Framework Changes
Rem =========================================================================

Rem Upgrade SQL ID and SQL hash to 12.1.0.2
update sqltxl_sql$
   set sqlid   = dbms_sql_translator.sql_id(sqltext),
       sqlhash = dbms_sql_translator.sql_hash(sqltext);
commit;

Rem =========================================================================
Rem END SQL Translation Framework Changes
Rem =========================================================================

Rem =========================================================================
Rem BEGIN Package Removal
Rem =========================================================================

drop package sys.htmldb_system;
drop public synonym htmldb_system;

Rem =========================================================================
Rem END Package Removal
Rem =========================================================================

Rem *************************************************************************
Rem Network ACL changes for 12.1.0.2
Rem *************************************************************************

Rem Insert network ACLs to Datapump noexp$
insert into noexp$ (owner, name, obj_type)
  (select xa.owner, xa.name, 110 from dba_xs_acls xa
    where xa.security_class_owner = 'SYS'
      and xa.security_class       = 'NETWORK_SC'
      and not exists (select * from noexp$ ne
                       where ne.owner    = xa.owner
                         and ne.name     = xa.name
                         and ne.obj_type = 110));
commit;

Rem *************************************************************************
Rem END Network ACL changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN bug 17515047, 17513956, 17515547 for 12.1.0.2
Rem *************************************************************************
-- Bug 17513956: Revoke incorrect grant on CDB_AUDIT_MGMT views to SELECT_CATALOG_ROLE
CREATE OR REPLACE PROCEDURE SYS.REVOKE_SELECT_FROM_CATALOG(tablename varchar2)
AS
  cdb_root number := 0;
  stmt varchar2(4000) := 'REVOKE SELECT ON ' || tablename || ' FROM SELECT_CATALOG_ROLE';
BEGIN
  select sys_context('USERENV','CON_ID') into cdb_root from dual;
  IF (cdb_root = 1) THEN
     stmt := stmt || ' container=all'; /* add CONTAINER=ALL clause if CDB$ROOT */
  END IF;
  IF (cdb_root = 1 OR cdb_root = 0) THEN
     EXECUTE IMMEDIATE stmt;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1927 ) THEN NULL;
    /*Ignore ORA-01927: cannot REVOKE privileges you did not grant */
    ELSE RAISE;
    END IF;
END;
/

exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_AUDIT_MGMT_CONFIG_PARAMS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_AUDIT_MGMT_LAST_ARCH_TS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_AUDIT_MGMT_CLEAN_EVENTS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_AUDIT_MGMT_CLEANUP_JOBS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_USERS_WITH_DEFPWD');

-- Bug 17515047: Revoke incorrect grant to SELECT_CATALOG_ROLE on CDB$ROOT or legacy DB
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_PRIV_CAPTURES');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_USED_PRIVS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_USED_SYSPRIVS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_USED_SYSPRIVS_PATH');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_USED_OBJPRIVS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_USED_OBJPRIVS_PATH');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_USED_USERPRIVS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_USED_USERPRIVS_PATH');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_USED_PUBPRIVS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_UNUSED_PRIVS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_UNUSED_SYSPRIVS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_UNUSED_SYSPRIVS_PATH');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_UNUSED_OBJPRIVS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_UNUSED_OBJPRIVS_PATH');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_UNUSED_USERPRIVS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_UNUSED_USERPRIVS_PATH');

-- Bug17526562 : Revoke incorrect grant to SELECT_CATALOG_ROLE on 
-- CDB_SECUREFILE* VIEWS
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_SECUREFILE_LOGS');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_SECUREFILE_LOG_TABLES');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_SECUREFILE_LOG_INSTANCES');
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_SECUREFILE_LOG_PARTITIONS');

-- bug#17526672: revoke select catolog from CDB_advisor_object_types
exec SYS.REVOKE_SELECT_FROM_CATALOG('SYS.CDB_ADVISOR_OBJECT_TYPES');

-- drop the temporary procedure after it's used.
DROP PROCEDURE SYS.REVOKE_SELECT_FROM_CATALOG;
/

--Fix bug 17515547: revoke SELECT ON CDB_XS_xxx session and audit views from 
--SELECT_CATALOG_ROLE
DECLARE
  cdb_root number := 0;
  type obj_name_list IS VARRAY(10) OF VARCHAR2(128);
  type obj_name_list2 IS VARRAY(10) OF VARCHAR2(128);
  xs_view_list obj_name_list;
  xs_view_list2 obj_name_list2;
  buf varchar2(4000);
BEGIN
  xs_view_list := obj_name_list('CDB_XS_ACTIVE_SESSIONS',
                                'CDB_XS_AUDIT_POLICY_OPTIONS',
                                'CDB_XS_ENABLED_AUDIT_POLICIES',
                                'CDB_XS_SESSIONS',
                                'CDB_XS_SESSION_NS_ATTRIBUTES',
                                'CDB_XS_SESSION_ROLES');

  xs_view_list2 := obj_name_list2('CDB_XS_AUDIT_TRAIL');

  select sys_context('USERENV','CON_ID') into cdb_root from dual;

  IF (cdb_root = 1 OR cdb_root = 0) THEN
    FOR i IN xs_view_list.first..xs_view_list.last
     LOOP
       IF (cdb_root = 0) THEN
         buf:= 'revoke SELECT ON SYS.'|| xs_view_list(i) ||
               ' from SELECT_CATALOG_ROLE';
       ELSE
         buf:= 'revoke SELECT ON SYS.'|| xs_view_list(i) ||
               ' from SELECT_CATALOG_ROLE container=all';
       END IF;
       BEGIN
         EXECUTE IMMEDIATE buf;

       EXCEPTION
         WHEN OTHERS THEN
           IF SQLCODE IN ( -1927 ) THEN NULL;
           ELSE RAISE;
           END IF;
       END;
    END LOOP;
  END IF;

  -- Bug 25245797: XS audit trail views are now moved to AUDSYS schema
  IF (cdb_root = 1 OR cdb_root = 0) THEN
    FOR i IN xs_view_list2.first..xs_view_list2.last
     LOOP
       IF (cdb_root = 0) THEN
         buf:= 'revoke SELECT ON AUDSYS.'|| xs_view_list2(i) ||
               ' from SELECT_CATALOG_ROLE';
       ELSE
         buf:= 'revoke SELECT ON AUDSYS.'|| xs_view_list2(i) ||
               ' from SELECT_CATALOG_ROLE container=all';
       END IF;
       BEGIN
         EXECUTE IMMEDIATE buf;

       EXCEPTION
         WHEN OTHERS THEN
           IF SQLCODE IN ( -1927 ) THEN NULL;
           ELSE RAISE;
           END IF;
       END;
    END LOOP;
  END IF;

END;
/

Rem *************************************************************************
Rem END bug 17515047, 17513956, 17515547 for 12.1.0.2
Rem *************************************************************************
Rem *************************************************************************
Rem BEGIN changes for Progress Table Optimization 
Rem *************************************************************************

/* Infer the pto fields for logical standby
 * pto_recovery_scn - set to MIN_REQUIRED_CAPTURE_CHANGE# as this gets
 *                    maintained considering PTO recovery requirements.
 * pto_recovery_incarnation - incarnation of the db when commit_time was last
 *                            updated.
 *
 * All these fields will get updated during the first lwm recording time
 * after the upgrade and subsequently will get maintained there after
 *
 */
declare
  recovery_scn number;
  last_event_time date;
begin
  select nvl(MIN_REQUIRED_CAPTURE_CHANGE#,current_scn) into recovery_scn from
  v$database;

  /* This should give us a time when apply was last known to have run.
   * The incarnation of the db at that time is what we want.
   */
  select max(event_time) into last_event_time from sys.dba_logstdby_events;

  update system.logstdby$apply_milestone am
  set pto_recovery_scn = recovery_scn,
      pto_recovery_incarnation = 
        (select max(incarnation#) 
         from v$database_incarnation where
          last_event_time > resetlogs_time
        )
  where bitand(flags, 1) <> 0;
  commit;
end;
/

/* Infer the pto fields for (x)streams.
 * pto_recovery_scn - set to MIN_REQUIRED_CAPTURE_CHANGE# as this gets
 *                    maintained considering PTO recovery requirements.
 * pto_recovery_incarnation - incarnation of the db when lwm_time was last
 *                            updated.
 * 
 * All these fields will get updated during the first lwm recording time
 * after the upgrade and subsequently will get maintained there after
 *
 */
declare
  recovery_scn number;
begin
  select nvl(MIN_REQUIRED_CAPTURE_CHANGE#,current_scn) into recovery_scn from
  v$database;

  update  sys.streams$_apply_milestone am
  set pto_recovery_scn = recovery_scn,
      pto_recovery_incarnation = 
        (select max(incarnation#)
         from v$database_incarnation where
          am.apply_time > resetlogs_time 
        )
  where bitand(flags, 1) <> 0;

  commit;
end;
/

Rem *************************************************************************
Rem END changes for Progress Table Optimization 
Rem *************************************************************************

-- populate the sync table with common DDLs for current state
exec dbms_pdb.populatesynctable;

Rem =========================================================================
Rem BEGIN AQ Correct grant for unflushed_dequeues
Rem =========================================================================

DECLARE
  stmt  VARCHAR2(500);
BEGIN

  -- only when it has flags multiple deq(1), multi-cosnumer(8)
  -- and 10i style queue tables(8192)
  FOR cur_rec IN (
                  SELECT distinct(schema)
                  FROM system.aq$_queue_tables
                  WHERE bitand(flags, 1)=1 and
                        bitand(flags, 8)=8 and
                        bitand(flags, 8192)=8192
                 )
  LOOP
    BEGIN
      stmt := 'GRANT SELECT ON aq$_unflushed_dequeues to ' || 
               dbms_assert.enquote_name(cur_rec.schema, FALSE);
      EXECUTE IMMEDIATE stmt;
    END;
  END LOOP;

  EXCEPTION
         WHEN OTHERS THEN
           DBMS_SYSTEM.ksdwrt(DBMS_SYSTEM.trace_file,'error in aq grant:' ||
                              sqlcode);
           RAISE;

END;
/

Rem =========================================================================
Rem END AQ Correct grant for unflushed_dequeues
Rem =========================================================================
Rem =========================================================================
Rem BEGIN AQ Correct subshard,flag,dequeue log
Rem =========================================================================
DECLARE
CURSOR dqm_qptid_to_qm_sbshid IS
SELECT qm.SUBSHARD, dqm.QUEUE_PART#,qm.queue
FROM sys.aq$_queue_partition_map qm, sys.aq$_dequeue_log_partition_map dqm
WHERE  qm.PARTITION# = dqm.QUEUE_PART# and qm.queue = dqm.queue;

BEGIN
FOR dqm_qptid_to_qm_sbshid_crec IN dqm_qptid_to_qm_sbshid LOOP
  update sys.aq$_dequeue_log_partition_map
  set SUBSHARD = dqm_qptid_to_qm_sbshid_crec.subshard
  where QUEUE_PART# = dqm_qptid_to_qm_sbshid_crec.QUEUE_PART# and
  queue=dqm_qptid_to_qm_sbshid_crec.queue;
end loop;
END;
/

commit;
update system.aq$_queues set MEMORY_THRESHOLD=2000 where sharded=1 and
NVL(MEMORY_THRESHOLD,0) = 0;
update sys.aq$_queue_shards set flags = 0;
commit;

DECLARE
CURSOR dql_alter IS
select name, TABLE_OBJNO,EVENTID from system.aq$_queues where sharded =1;
stmt               varchar2(500);
tmptabname         VARCHAR2(30);
usern              VARCHAR2(30);
tableid            number;
userid             number;
qtflags            number;
payload_type       number;
total_partitions   number;
storage_clause     VARCHAR2(800);
userdata_txt       varchar2(32000);
cr_q_tab_stmt      CLOB;
cr_q_tabidx_stmt   CLOB;
nxtval_shidseq_stmt varchar2(500);
seq_val            NUMBER;
TYPE shardCurTyp   IS REF CURSOR;  -- define weak REF CURSOR type
shard_cv           shardCurTyp;  -- declare cursor variable
shard_sel_stmt    VARCHAR2(500);
shard_id           NUMBER;

dqt                CONSTANT VARCHAR2(1) := '"';
COLUMN_NONEXISTENT exception;
 pragma EXCEPTION_INIT(COLUMN_NONEXISTENT, -904);
BEGIN
sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.ENABLE_AQ_DDL);

FOR dql_alter_rec IN dql_alter LOOP
select name,user# into usern,userid from sys.user$
where user#=(select owner# from sys.obj$ where obj#=dql_alter_rec.TABLE_OBJNO);

tmptabname := 'AQ$_' || dql_alter_rec.name ||'_L';

select o.obj# into tableid from sys.obj$ o where o.name=dql_alter_rec.name  and
owner#=userid and o.type#=2;

     -- alter the table to revalidate it if it was in a read-only tablespace
    execute immediate
       'alter table ' || DBMS_ASSERT.ENQUOTE_NAME(usern)|| '.'||
            DBMS_ASSERT.ENQUOTE_NAME(tmptabname) || ' upgrade not including data';
    stmt := 'alter table '||DBMS_ASSERT.ENQUOTE_NAME(usern)|| '.'||
            DBMS_ASSERT.ENQUOTE_NAME(tmptabname) ||
   ' modify(msgid RAW(16) default ''FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'', ' ||
   ' shard  default 4294967295, flags  default 4294967295, '  ||
   ' transaction_id VARCHAR2(30) default ''FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'', '||
   ' dequeue_user VARCHAR2(128) default ''FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'',' ||
   ' retry_count default 0) ' ;
    execute immediate stmt;
   BEGIN
   stmt := 'alter table '||DBMS_ASSERT.ENQUOTE_NAME(usern)|| '.'||
            DBMS_ASSERT.ENQUOTE_NAME(tmptabname) ||
   ' modify( subscriber#  default 4294967295)' ;
    execute immediate stmt;
   EXCEPTION WHEN COLUMN_NONEXISTENT THEN
     NULL;
   END;
    -- alter the table to revalidate it if it was in a read-only tablespace
   execute immediate
       'alter table ' || DBMS_ASSERT.ENQUOTE_NAME(usern)|| '.'||
            DBMS_ASSERT.ENQUOTE_NAME(dql_alter_rec.name) || ' upgrade not including data';

   stmt := 'alter table '||DBMS_ASSERT.ENQUOTE_NAME(usern)|| '.'||
             DBMS_ASSERT.ENQUOTE_NAME(dql_alter_rec.name) || ' rename column delay TO delivery_time';

    execute immediate stmt;

   stmt := 'alter table '||DBMS_ASSERT.ENQUOTE_NAME(usern)|| '.'||
             DBMS_ASSERT.ENQUOTE_NAME(dql_alter_rec.name) || ' add (subshard  INTEGER)';

    execute immediate stmt;
   stmt := 'alter table ' || DBMS_ASSERT.ENQUOTE_NAME(usern) || '.' ||
            DBMS_ASSERT.ENQUOTE_NAME(dql_alter_rec.name) ||
          ' add(old_msgid raw(16), exception_queue varchar2(128))';
    execute immediate stmt;

    BEGIN

      cr_q_tabidx_stmt := TO_CLOB('CREATE INDEX '                              ||
                          dbms_assert.enquote_name(usern, FALSE) || '.'     ||
                          dbms_assert.enquote_name('qt' || tableid || '_delay_idx', FALSE)  ||
                          ' ON '                                 ||
                          dbms_assert.enquote_name(dqt||usern||dqt) || '.'  ||
                          dbms_assert.enquote_name(dqt||dql_alter_rec.name||dqt)           ||
                          '(delivery_time,step_number) LOCAL ');

    EXECUTE IMMEDIATE cr_q_tabidx_stmt;

    EXCEPTION 
      WHEN OTHERS THEN
        dbms_system.ksdwrt(dbms_system.alert_file,
                       'Error in sharded queue delay index creation ' || sqlcode ||
                       ' schema ' || usern || ' queue ' || dql_alter_rec.name || ' index ' ||
                       dbms_assert.enquote_name('qt' || tableid || '_delay_idx', FALSE));

        IF SQLCODE = -1647 THEN
           dbms_system.ksdwrt(dbms_system.alert_file,
                  ' Delay Index on  schema ' || usern || ' queue ' || dql_alter_rec.name ||
                  ', index ' || dbms_assert.enquote_name('qt' || tableid || '_delay_idx', FALSE) ||
                  ' will get automatically created asynchronously in background on ' ||
                  ' first queue operation.');
         ELSE
           RAISE;
         END IF;
    END;

    stmt := 'update sys.aq$_queue_partition_map set instance = instance/1000 ' ||
            'where queue = ' || tableid || ' and instance > 256';

    execute immediate stmt;

    stmt := 'update sys.aq$_dequeue_log_partition_map set instance = instance/1000 ' ||
            'where queue = ' || tableid || ' and instance > 256';

    execute immediate stmt;
    shard_sel_stmt := 'select SHARD from sys.aq$_queue_shards ' ||
    ' where queue = :1 and delay_shard is null order by shard';
    OPEN shard_cv FOR shard_sel_stmt using dql_alter_rec.EVENTID;
    LOOP
      -- for each queue update the delay_shard from shard sequence
      FETCH shard_cv INTO shard_id;
      EXIT WHEN shard_cv%NOTFOUND;
      nxtval_shidseq_stmt :=
        'select '                                  ||
        dbms_assert.enquote_name(dqt||usern||dqt)  ||
        '.'  ||
        dbms_assert.enquote_name(dqt||dql_alter_rec.name   ||
        '_SHSEQ'||dqt) ||'.nextval from dual';
      EXECUTE IMMEDIATE nxtval_shidseq_stmt INTO seq_val;  

      stmt := 'UPDATE SYS.aq$_queue_shards set delay_shard=' ||seq_val
               || ' WHERE QUEUE =' ||dql_alter_rec.EVENTID ||'  AND SHARD =' ||shard_id;
      execute immediate stmt;
 
    END LOOP;
    commit; 
    CLOSE shard_cv;
	
end loop;

sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.DISABLE_AQ_DDL);
END;
/

/* add old_msgid column to all sharded queue tables */
DECLARE
   TYPE CurTyp  IS REF CURSOR;  -- define weak REF CURSOR type
   tab_cv          CurTyp;      -- declare cursor variable
   schemaname       varchar2(128);
   tabname      varchar2(128);
   altstmt      varchar2(500);
   sel_stmt      varchar2(500);

BEGIN
      sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.ENABLE_AQ_DDL);
      sel_stmt := 'select t.schema, t.name from system.aq$_queue_tables t where 
      bitand(flags, 67108864)=67108864';
      open tab_cv for sel_stmt;
     LOOP
       FETCH tab_cv INTO schemaname, tabname;
       EXIT WHEN tab_cv%NOTFOUND;
       -- alter the table to revalidate it if it was in a read-only tablespace
       execute immediate
           'alter table ' ||schemaname||'.'||tabname  || ' upgrade not including data';
       altstmt := 'alter table ' ||schemaname||'.'||tabname ||
                  ' add(old_msgid raw(16))';
       execute immediate altstmt;
      END LOOP;
      sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.DISABLE_AQ_DDL);
END;
/


Rem =========================================================================
Rem END AQ Correct subshard,flag,dequeue log table
Rem =========================================================================

-- Upgrade sharded queues by setting the sharded queue flag.
exec sys.dbms_aqadm_sys.upgrade_sharded_queue();

Rem =========================================================================
Rem BEGIN upgrade 12C Queue View
Rem =========================================================================

DECLARE
BEGIN

  FOR cur_rec IN (
                  SELECT t.schema, t.name, t.flags, q.eventid
                  FROM system.aq$_queue_tables t, system.aq$_queues q
                  WHERE t.objno = q.table_objno and q.sharded =1 
                 )
  LOOP
    BEGIN

      sys.dbms_prvtaqim.create_base_view_12C(
               cur_rec.schema, cur_rec.name, cur_rec.eventid,
               sys.dbms_aqadm_sys.mcq_12gJms(cur_rec.flags), cur_rec.flags);

    END;
  END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_SYSTEM.ksdwrt(DBMS_SYSTEM.trace_file,
                         'error in 12C view creation' || sqlcode);
      RAISE;

END;
/
Rem =========================================================================
Rem END upgrade 12C Queue View
Rem =========================================================================

Rem =========================================================================
Rem BEGIN Upgrade of eviction table for AQ 
Rem =========================================================================

DECLARE
   TYPE CurTyp  IS REF CURSOR;  -- define weak REF CURSOR type
   tab_cv          CurTyp;      -- declare cursor variable
   schemaname       varchar2(128);
   tabname          varchar2(128);
   sel_stmt         varchar2(500);

BEGIN
      sys.dbms_aqadm_sys.Mark_Internal_Tables
      (dbms_aqadm_sys.ENABLE_AQ_DDL);
      sel_stmt := 'select t.schema, t.name from system.aq$_queue_tables t where 
                   bitand(flags, 67108864)=67108864';
      open tab_cv for sel_stmt;
     LOOP
       FETCH tab_cv INTO schemaname, tabname;
       EXIT WHEN tab_cv%NOTFOUND;
       BEGIN

       sys.dbms_aqadm_sys.create_eviction_table(schemaname, tabname);
       commit;

       EXCEPTION
         WHEN OTHERS THEN
           dbms_system.ksdwrt(dbms_system.alert_file,
                          'error in sharded queue eviction table' || sqlcode ||
                          ' schema ' || schemaname || ' tabname ' ||
                          tabname); 
           
           IF SQLCODE = -1647 THEN
              dbms_system.ksdwrt(dbms_system.alert_file,
                          ' Eviction table for' || schemaname || '.' ||
                          tabname || 
                          ' will get automatically created on next access');
            ELSE
              sys.dbms_aqadm_sys.Mark_Internal_Tables
             (dbms_aqadm_sys.DISABLE_AQ_DDL);
              RAISE;
            END IF;
       END;
     END LOOP;
      sys.dbms_aqadm_sys.Mark_Internal_Tables
      (dbms_aqadm_sys.DISABLE_AQ_DDL);
END;
/

Rem =========================================================================
Rem END Upgrade of eviction table for AQ
Rem =========================================================================

Rem =======================================================================
Rem  18971004: Begin Changes for CDB Object Linked Views
Rem =======================================================================

DROP VIEW INT$DBA_ALERT_HISTORY;
DROP VIEW INT$DBA_ALERT_HISTORY_DETAIL;
DROP VIEW INT$DBA_CPOOL_INFO;
DROP VIEW INT$DBA_HIST_ACT_SESS_HISTORY;
DROP VIEW INT$DBA_HIST_APPLY_SUMMARY;
DROP VIEW INT$DBA_HIST_ASH_SNAPSHOT;
DROP VIEW INT$DBA_HIST_ASM_BAD_DISK;
DROP VIEW INT$DBA_HIST_ASM_DG_STAT;
DROP VIEW INT$DBA_HIST_ASM_DISKGROUP;
DROP VIEW INT$DBA_HIST_BASELINE;
DROP VIEW INT$DBA_HIST_BASELINE_DETAILS;
DROP VIEW INT$DBA_HIST_BASELINE_METADATA;
DROP VIEW INT$DBA_HIST_BASELINE_TEMPLATE;
DROP VIEW INT$DBA_HIST_BG_EVENT_SUMMARY;
DROP VIEW INT$DBA_HIST_BUFFERED_QUEUES;
DROP VIEW INT$DBA_HIST_BUFFER_POOL_STAT;
DROP VIEW INT$DBA_HIST_BUF_SUBSCRIBERS;
DROP VIEW INT$DBA_HIST_CAPTURE;
DROP VIEW INT$DBA_HIST_CELL_CFG_DETAIL;
DROP VIEW INT$DBA_HIST_CELL_CONFIG;
DROP VIEW INT$DBA_HIST_CELL_DB;
DROP VIEW INT$DBA_HIST_CELL_DISKTYPE;
DROP VIEW INT$DBA_HIST_CELL_DISK_NAME;
DROP VIEW INT$DBA_HIST_CELL_DISK_SUMMARY;
DROP VIEW INT$DBA_HIST_CELL_GLBL_SUMMARY;
DROP VIEW INT$DBA_HIST_CELL_GLOBAL;
DROP VIEW INT$DBA_HIST_CELL_IOREASON;
DROP VIEW INT$DBA_HIST_CELL_IOREASON_NM;
DROP VIEW INT$DBA_HIST_CELL_METRIC_DESC;
DROP VIEW INT$DBA_HIST_CELL_NAME;
DROP VIEW INT$DBA_HIST_CELL_OPEN_ALERTS;
DROP VIEW INT$DBA_HIST_CLUSTER_INTERCON;
DROP VIEW INT$DBA_HIST_COLORED_SQL;
DROP VIEW INT$DBA_HIST_COMP_IOSTAT;
DROP VIEW INT$DBA_HIST_CR_BLOCK_SERVER;
DROP VIEW INT$DBA_HIST_CURR_BLK_SERVER;
DROP VIEW INT$DBA_HIST_DATABASE_INSTANCE;
DROP VIEW INT$DBA_HIST_DATAFILE;
DROP VIEW INT$DBA_HIST_DB_CACHE_ADVICE;
DROP VIEW INT$DBA_HIST_DISPATCHER;
DROP VIEW INT$DBA_HIST_DLM_MISC;
DROP VIEW INT$DBA_HIST_DYN_RE_STATS;
DROP VIEW INT$DBA_HIST_LMS_STATS;
DROP VIEW INT$DBA_HIST_ENQUEUE_STAT;
DROP VIEW INT$DBA_HIST_EVENT_HISTOGRAM;
DROP VIEW INT$DBA_HIST_EVENT_NAME;
DROP VIEW INT$DBA_HIST_FILESTATXS;
DROP VIEW INT$DBA_HIST_FM_HISTORY;
DROP VIEW INT$DBA_HIST_IC_CLIENT_STATS;
DROP VIEW INT$DBA_HIST_IC_DEVICE_STATS;
DROP VIEW INT$DBA_HIST_IC_PINGS;
DROP VIEW INT$DBA_HIST_IC_TRANSFER;
DROP VIEW INT$DBA_HIST_IM_SEG_STAT;
DROP VIEW INT$DBA_HIST_IM_SEG_STAT_OBJ;
DROP VIEW INT$DBA_HIST_INSTANCE_RECOVERY;
DROP VIEW INT$DBA_HIST_IOSTAT_DETAIL;
DROP VIEW INT$DBA_HIST_IOSTAT_FILETYPE;
DROP VIEW INT$DBA_HIST_IOSTAT_FN_NAME;
DROP VIEW INT$DBA_HIST_IOSTAT_FT_NAME;
DROP VIEW INT$DBA_HIST_IOSTAT_FUNCTION;
DROP VIEW INT$DBA_HIST_JAVA_POOL_ADVICE;
DROP VIEW INT$DBA_HIST_LATCH;
DROP VIEW INT$DBA_HIST_LATCH_CHILDREN;
DROP VIEW INT$DBA_HIST_LATCH_NAME;
DROP VIEW INT$DBA_HIST_LATCH_PARENT;
DROP VIEW INT$DBA_HIST_LAT_M_SUMMARY;
DROP VIEW INT$DBA_HIST_LIBRARYCACHE;
DROP VIEW INT$DBA_HIST_LOG;
DROP VIEW INT$DBA_HIST_MEMORY_RESIZE_OPS;
DROP VIEW INT$DBA_HIST_MEM_DYNAMIC_COMP;
DROP VIEW INT$DBA_HIST_MEM_TGT_ADVICE;
DROP VIEW INT$DBA_HIST_METRIC_NAME;
DROP VIEW INT$DBA_HIST_MTTR_TGT_ADVICE;
DROP VIEW INT$DBA_HIST_MUTEX_SLEEP;
DROP VIEW INT$DBA_HIST_MVPARAMETER;
DROP VIEW INT$DBA_HIST_OPTIMIZER_ENV;
DROP VIEW INT$DBA_HIST_OSSTAT;
DROP VIEW INT$DBA_HIST_OSSTAT_NAME;
DROP VIEW INT$DBA_HIST_PARAMETER;
DROP VIEW INT$DBA_HIST_PARAMETER_NAME;
DROP VIEW INT$DBA_HIST_PDB_INSTANCE;
DROP VIEW INT$DBA_HIST_PERSISTENT_QUEUES;
DROP VIEW INT$DBA_HIST_PERSISTENT_SUBS;
DROP VIEW INT$DBA_HIST_PERS_QMN_CACHE;
DROP VIEW INT$DBA_HIST_PGASTAT;
DROP VIEW INT$DBA_HIST_PGA_TARGET_ADVICE;
DROP VIEW INT$DBA_HIST_PLAN_OPTION_NAME;
DROP VIEW INT$DBA_HIST_PLAN_OP_NAME;
DROP VIEW INT$DBA_HIST_PMEM_SUMMARY;
DROP VIEW INT$DBA_HIST_REPORTS;
DROP VIEW INT$DBA_HIST_REPORTS_DETAILS;
DROP VIEW INT$DBA_HIST_REPORTS_TIMEBANDS;
DROP VIEW INT$DBA_HIST_REP_TBL_STATS;
DROP VIEW INT$DBA_HIST_REP_TXN_STATS;
DROP VIEW INT$DBA_HIST_RESOURCE_LIMIT;
DROP VIEW INT$DBA_HIST_ROWCACHE_SUMMARY;
DROP VIEW INT$DBA_HIST_RSRC_CON_GROUP;
DROP VIEW INT$DBA_HIST_RSRC_PLAN;
DROP VIEW INT$DBA_HIST_RULE_SET;
DROP VIEW INT$DBA_HIST_SEG_STAT;
DROP VIEW INT$DBA_HIST_SEG_STAT_OBJ;
DROP VIEW INT$DBA_HIST_SERVICE_NAME;
DROP VIEW INT$DBA_HIST_SERVICE_STAT;
DROP VIEW INT$DBA_HIST_SESS_SGA_STATS;
DROP VIEW INT$DBA_HIST_SESS_TIME_STATS;
DROP VIEW INT$DBA_HIST_SGA;
DROP VIEW INT$DBA_HIST_SGASTAT;
DROP VIEW INT$DBA_HIST_SGA_TARGET_ADVICE;
DROP VIEW INT$DBA_HIST_SHRD_SVR_SUMMARY;
DROP VIEW INT$DBA_HIST_SM_HISTORY;
DROP VIEW INT$DBA_HIST_SNAPSHOT;
DROP VIEW INT$DBA_HIST_SNAP_ERROR;
DROP VIEW INT$DBA_HIST_SPOOL_ADVICE;
DROP VIEW INT$DBA_HIST_SQLCOMMAND_NAME;
DROP VIEW INT$DBA_HIST_SQLSTAT;
DROP VIEW INT$DBA_HIST_SQLTEXT;
DROP VIEW INT$DBA_HIST_SQL_BIND_METADATA;
DROP VIEW INT$DBA_HIST_SQL_PLAN;
DROP VIEW INT$DBA_HIST_SQL_SUMMARY;
DROP VIEW INT$DBA_HIST_SQL_WA_HSTGRM;
DROP VIEW INT$DBA_HIST_STAT_NAME;
DROP VIEW INT$DBA_HIST_STREAMS_APPLY_SUM;
DROP VIEW INT$DBA_HIST_STREAMS_CAPTURE;
DROP VIEW INT$DBA_HIST_STRPOOL_ADVICE;
DROP VIEW INT$DBA_HIST_SVC_WAIT_CLASS;
DROP VIEW INT$DBA_HIST_SYSMETRIC_HISTORY;
DROP VIEW INT$DBA_HIST_SYSMETRIC_SUMMARY;
DROP VIEW INT$DBA_HIST_SYSSTAT;
DROP VIEW INT$DBA_HIST_SYSTEM_EVENT;
DROP VIEW INT$DBA_HIST_SYS_TIME_MODEL;
DROP VIEW INT$DBA_HIST_TABLESPACE;
DROP VIEW INT$DBA_HIST_TABLESPACE_STAT;
DROP VIEW INT$DBA_HIST_TBSPC_SPACE_USAGE;
DROP VIEW INT$DBA_HIST_TEMPFILE;
DROP VIEW INT$DBA_HIST_TEMPSTATXS;
DROP VIEW INT$DBA_HIST_THREAD;
DROP VIEW INT$DBA_HIST_TOPLEVELCALL_NAME;
DROP VIEW INT$DBA_HIST_UNDOSTAT;
DROP VIEW INT$DBA_HIST_WAITSTAT;
DROP VIEW INT$DBA_HIST_WCM_HISTORY;
DROP VIEW INT$DBA_HIST_WR_CONTROL;
DROP VIEW INT$DBA_OUTSTANDING_ALERTS;
DROP VIEW INT$DBA_PDBS;
DROP VIEW INT$DBA_PDB_SAVED_STATES;

Rem =======================================================================
Rem  18971004: End Changes for CDB Object Linked Views
Rem =======================================================================

Rem =======================================================================
Rem Bug 23039033: drop and re-create scheduler job cleanup_transient_type
Rem               drop and re-create scheduler job cleanup_transient_pkg
Rem =======================================================================

execute dbms_scheduler.disable('CLEANUP_TRANSIENT_TYPE', TRUE);
BEGIN
  dbms_scheduler.stop_job('CLEANUP_TRANSIENT_TYPE', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; -- Suppress job not running error
  ELSE
    raise;
  END IF;
END;
/

execute dbms_scheduler.drop_job('CLEANUP_TRANSIENT_TYPE', TRUE);

-- create scheduler job to cleanup transient types
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'CLEANUP_TRANSIENT_TYPE';

  select count(*) into exist 
  from   dba_scheduler_jobs 
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then 
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_CLNUP_TRANS_TYP
             -- Bug 23039033: skip app object check by setting parameter
             job_action => 
               'declare 
                  myinterval number; 
                begin 
                  execute immediate ''alter session set "_skip_app_object_check"=true'';
                  myinterval := dbms_pdb.cleanup_task(4); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(150, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 2',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS', 
             enabled => TRUE,
             comments => 'Cleanup Transient Types');
  end if;
end;
/

execute dbms_scheduler.disable('CLEANUP_TRANSIENT_PKG', TRUE);
BEGIN
  dbms_scheduler.stop_job('CLEANUP_TRANSIENT_PKG', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; -- Suppress job not running error
  ELSE
    raise;
  END IF;
END;
/

execute dbms_scheduler.drop_job('CLEANUP_TRANSIENT_PKG', TRUE);

-- create scheduler job to cleanup cursor transient packages
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'CLEANUP_TRANSIENT_PKG';

  select count(*) into exist 
  from   dba_scheduler_jobs 
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then 
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_CLNUP_TRANS_PKG
             -- Bug 23039033: skip app object check by setting parameter
             job_action => 
               'declare 
                  myinterval number; 
                begin 
                  execute immediate ''alter session set "_skip_app_object_check"=true'';
                  myinterval := dbms_pdb.cleanup_task(5); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(160, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 2',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS', 
             enabled => TRUE,
             comments => 'Cleanup Transient Packages');
  end if;
end;
/

Rem =======================================================================
Rem Bug 23039033: drop and re-create scheduler job cleanup_transient_type
Rem               drop and re-create scheduler job cleanup_transient_pkg
Rem =======================================================================

Rem =======================================================================
Rem Bug 23030152: drop and re-create scheduler job cleanup_online_pmo
Rem =======================================================================

execute dbms_scheduler.disable('CLEANUP_ONLINE_PMO', TRUE);
BEGIN
  dbms_scheduler.stop_job('CLEANUP_ONLINE_PMO', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; -- Suppress job not running error
  ELSE
    raise;
  END IF;
END;
/

execute dbms_scheduler.drop_job('CLEANUP_ONLINE_PMO', TRUE);

-- create scheduler job to perform online PMO cleanup
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'CLEANUP_ONLINE_PMO';

  select count(*) into exist 
  from   dba_scheduler_jobs 
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then 
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_ONLINE_PMOP
             -- Bug 23030152: skip app object check by setting parameter
             job_action => 
               'declare 
                  myinterval number; 
                begin 
                  execute immediate ''alter session set "_skip_app_object_check"=true'';
                  myinterval := dbms_pdb.cleanup_task(6); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(170, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 1',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS', 
             enabled => TRUE,
             comments => 'Cleanup after Failed PMO');
  end if;
end;
/

Rem =======================================================================
Rem Bug 23030152: drop and re-create scheduler job cleanup_online_pmo
Rem =======================================================================

Rem =====================
Rem Begin ODM changes
Rem =====================

Rem  ODM model upgrades
exec dmp_sys.upgrade_models('12.2.0');
/

Rem =====================
Rem End ODM changes
Rem =====================


Rem =========================================================================
Rem BEGIN cleanup ilmobj$
Rem =========================================================================

exec prvt_ilm.ilm_dict_cleanup_check(ilm_upgrade => TRUE);

Rem =========================================================================
Rem END cleanup ilmobj$
Rem =========================================================================

Rem =========================================================================
Rem BEGIN replication changes
Rem =========================================================================

Rem drop Advanced Replication objects
@@catnorep.sql

Rem =========================================================================
Rem END replication changes
Rem =========================================================================

Rem =========================================================================
Rem BEGIN add job to cleanup unneeded common object metadata
Rem =========================================================================

declare
  exist    number;
  jobname  varchar2(128);
  pdbcheck varchar2(128);
begin
  -- only do this in a PDB
  select sys_context('USERENV', 'CDB_NAME') into pdbcheck
    from dual
    where sys_context('USERENV', 'CDB_NAME') is not null;
  select sys_context('USERENV', 'CON_NAME') into pdbcheck
    from dual
    where sys_context('USERENV','CON_NAME') <> 'CDB$ROOT';

  jobname := 'CLEANUP_UNNEEDED_122_METADATA';

  select count(*) into exist
  from   dba_scheduler_jobs
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_CLNUP_122_META
             -- only needs to be done once. Callback will return 1
             -- if successfully finished.
             job_action =>
               'declare 
                  myinterval number; 
                begin 
                  myinterval := dbms_pdb.cleanup_task(8); 
                  if myinterval = 1 then
                    next_date := to_date(''31-JAN-4000'', ''DD-MON-YYYY'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(120, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 4',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS',
             enabled => TRUE,
             comments => 'Cleanup unnecessary common object metadata');
  end if;
exception
  when no_data_found then
    null;
end;
/
Rem ====================================================================
Rem BEGIN changes for AQ long identifier support
Rem script will modify all AQ table columns to new limit 128 byte for 
Rem identifiers and 512 bytes for subscribers
Rem ====================================================================
declare
  cursor alltables is
  select name,obj#,owner# from sys.obj$ where type# = 2 and name like 'AQ$%';
  tabname varchar2(300);
  usern varchar2(128);
  namelen integer;
  suffix varchar2(2);
  altstmt varchar2(500);
  coltype number;
  db_block_size       NUMBER;
  sublen   NUMBER;

  TABLE_NONEXISTENT exception;
  INVALID_IDEN exception;
  pragma EXCEPTION_INIT(TABLE_NONEXISTENT, -942);
  pragma EXCEPTION_INIT(INVALID_IDEN, -904);
begin
  sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.ENABLE_AQ_DDL);
  for alltables_row in alltables loop
    begin
      select name into usern from sys.user$ where user#= alltables_row.owner#;

      tabname := DBMS_ASSERT.ENQUOTE_NAME(usern) || '.' ||
                 DBMS_ASSERT.ENQUOTE_NAME(alltables_row.name);
      -- alter the table to revalidate it if it was in a read-only tablespace
      execute immediate
         'alter table ' || tabname || ' upgrade not including data';
      namelen := length(alltables_row.name);
      suffix := substr(alltables_row.name,namelen-1,2);

      if(suffix = '_G') then
        altstmt := 'alter table ' || tabname || ' modify(name varchar2(512))';
        execute immediate altstmt;
      end if;

      if(suffix = '_L') then
        select type# into coltype from sys.col$ where name like
        'DEQUEUE_USER' and obj#=alltables_row.obj#;

        if(coltype = 1) then
          altstmt := 'alter table ' || tabname || 
                     ' modify(dequeue_user varchar2(128))';
          execute immediate altstmt;
        end if;
        altstmt := 'alter table ' || tabname || 
                   ' modify(name varchar2(512))';
        execute immediate altstmt;
      end if;

      if(suffix = '_S') then
        altstmt := 'alter table ' || tabname || 
                   ' modify(queue_name varchar2(128), '
                  ||' name varchar2(512), '
                  ||' rule_name varchar2(128), trans_name varchar2(261),'
                  ||' ruleset_name varchar2(261),' 
                  ||' negative_ruleset_name varchar2(261))';
        execute immediate altstmt;
      end if;

      if(suffix = '_I') then
        altstmt := 'alter table ' || tabname || ' modify(name varchar2(512))';
        execute immediate altstmt;
        altstmt := 'alter table ' || tabname ||
                   ' modify(msg_qname varchar2(128))';
        execute immediate altstmt;
      end if;
      if(suffix = '_H') then
      --not able to fit 512 sub in 2k block iot
      --supported length is 128 byte with 2k block size   
        db_block_size := sys.dbms_aqadm_var.get_db_block_size();    
        IF db_block_size <= 2048 then
          sublen := 128;
        ELSE
          sublen := 512;
        END IF;        
           
        select type# into coltype from sys.col$ where name like 'DEQUEUE_USER'
        and obj#=alltables_row.obj#;
        if(coltype = 1) then
            altstmt := 'alter table ' || tabname || 
                       ' modify(name varchar2('||sublen||'), '||
                       ' dequeue_user varchar2(128))';
          execute immediate altstmt;
        end if;
      end if;

      if(alltables_row.name = 'AQ$_MEM_MC') then
        altstmt := 'alter table ' || tabname || ' modify(q_name varchar2(128),'
        ||'  exception_qschema varchar2(128), exception_queue varchar2(128),'
        ||' sender_name varchar2(128))';
        execute immediate altstmt;
      end if;

    EXCEPTION
      WHEN TABLE_NONEXISTENT THEN
        NULL;
      WHEN INVALID_IDEN THEN
        NULL;
      WHEN OTHERS THEN
        raise;
    end;
  end loop;
  sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.DISABLE_AQ_DDL);
  end;
/

declare
  cursor allqueues is
  select t.schema schema, q.name qname , q.table_objno qobj, t.flags qt_flags,
  q.usage qtype
  from system.aq$_queues q, system.aq$_queue_tables t
  WHERE q.table_objno = t.objno AND NVL(q.sharded,0)=0;

  tabn varchar2(128);
  owner number;
  usern varchar2(128);
  qtabnm varchar2(300);
  altstmt  varchar2(500);
  COLUMN_NONEXISTENT EXCEPTION;
  TABLE_NONEXISTENT EXCEPTION;

  pragma EXCEPTION_INIT(COLUMN_NONEXISTENT, -904);
  pragma EXCEPTION_INIT(TABLE_NONEXISTENT, -942);
begin
  sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.ENABLE_AQ_DDL);
  for allrow in allqueues loop
    begin
    select owner# into owner from sys.obj$ where obj#= allrow.qobj;
    select name into usern from sys.user$ where user# =owner;
    select name into tabn from sys.obj$ where obj#= allrow.qobj;

    qtabnm := DBMS_ASSERT.ENQUOTE_NAME(usern) || '.' || 
              DBMS_ASSERT.ENQUOTE_NAME(tabn);
    -- alter the table to revalidate it if it was in a read-only tablespace
    execute immediate
       'alter table ' || qtabnm || ' upgrade not including data';
    if(tabn = 'AQ_EVENT_TABLE' or tabn = 'DEF$_AQCALL' or tabn = 'DEF$_AQERROR') 
    then
      altstmt := 'alter table ' || qtabnm || ' modify(q_name varchar2(128),' ||
               ' exception_qschema varchar2(128),'||
               '  exception_queue varchar2(128))';
      execute immediate altstmt;
    else
      altstmt := ' alter table ' || qtabnm || 
                 ' modify(sender_name varchar2(128),' ||
                 ' q_name varchar2(128), exception_qschema varchar2(128), ' || 
                 'exception_queue varchar2(128))';
      execute immediate altstmt;
    end if;
    IF bitand(allrow.qt_flags, 8192) = 8192 THEN
      BEGIN 
      altstmt := ' alter table ' || qtabnm ||
                 ' modify(enq_uid varchar2(128),' ||
                 ' deq_uid varchar2(128))';
      execute immediate altstmt;
      exception  when COLUMN_NONEXISTENT then
      NULL;
      END; 
    END IF;

    exception  when COLUMN_NONEXISTENT then
      NULL;
    when TABLE_NONEXISTENT then
      NULL;
    when OTHERS THEN
     raise;
    end;
  end loop;
  sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.DISABLE_AQ_DDL);
end;
/

Rem =========================================================================
Rem END add job to cleanup unneeded common object metadata
Rem =========================================================================

Rem =========================================================================
Rem BEGIN BUG 20019217
Rem =========================================================================

drop view DBA_XS_ENB_AUDIT_POLICIES;
drop view CDB_XS_ENB_AUDIT_POLICIES;

Rem =========================================================================
Rem END BUG 20019217
Rem =========================================================================

Rem =========================================================================
Rem BEGIN Privilege Analysis Changes
Rem =========================================================================

Rem ==========================
Rem From 12.1 to 12.2
Rem ==========================

update sys.priv_used_path$ set run_seq#=0;

update sys.priv_unused$ set run_seq#=0;

update sys.priv_unused_path$ set run_seq#=0;

commit;

Rem =========================================================================
Rem END Privilege Analysis Changes
Rem =========================================================================

Rem =========================================================================
Rem BEGIN BUG 20511242
Rem Modify the table AUDTAB$TBS$FOR_EXPORT_TBL to support long identifiers
Rem Since the table directly references bootstrapped tables like obj$, user$
Rem the changes cannot go into c1201000.sql as they are not updated when the
Rem upgrade script is run
Rem =========================================================================

alter table sys.audtab$tbs$for_export_tbl modify(owner varchar2(128));
alter table sys.audtab$tbs$for_export_tbl modify(name varchar2(128));

Rem =========================================================================
Rem END BUG 20511242
Rem =========================================================================

Rem =========================================================================
Rem BEGIN BUG 20511352
Rem Modify the tables DBA_SENSITIVE_DATA_TBL, DBA_TSDP_POLICY_PROTECTION_TBL
Rem to support long identifiers. Since the table directly references
Rem bootstrapped tables like obj$, user$ the changes cannot go into
Rem c1201000.sql as they are not updated when the upgrade script is run
Rem =========================================================================

alter table sys.dba_sensitive_data_tbl modify(schema_name varchar2(128));
alter table sys.dba_sensitive_data_tbl modify(table_name varchar2(128));
alter table sys.dba_sensitive_data_tbl modify(column_name varchar2(128));

alter table sys.dba_tsdp_policy_protection_tbl modify(schema_name varchar2(128));
alter table sys.dba_tsdp_policy_protection_tbl modify(table_name varchar2(128));
alter table sys.dba_tsdp_policy_protection_tbl modify(column_name varchar2(128));

Rem =========================================================================
Rem END BUG 20511352
Rem =========================================================================

Rem ====================================================================
Rem Begin Bug 19880667
Rem ====================================================================

Rem
Rem Grant admin_sec_policy to db users who have xs_resource role and
Rem then drop xs_resource role 
Rem

DECLARE
CURSOR xs_resource_dbusers IS
select distinct u1.name grantee 
from sys.user$ u1, sys.sysauth$ s 
where s.grantee# = u1.user# and u1.type#=1 and u1.name != 'SYS'
start with s.privilege# = (select user# from sys.user$ 
                           where name = 'XS_RESOURCE')
connect by prior s.grantee# = s.privilege#;

BEGIN
FOR xs_resource_dbusers_crec IN xs_resource_dbusers LOOP
  sys.xs_admin_util.grant_system_privilege('admin_sec_policy', 
                                       xs_resource_dbusers_crec.grantee, 
                                       xs_admin_util.ptype_db, 
                                       xs_resource_dbusers_crec.grantee);
END LOOP;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP ROLE XS_RESOURCE';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1919 THEN NULL;
       -- suppress error for non-existent role for earlier versions
  ELSE raise;
  END IF;
END;
/
commit;

Rem ====================================================================
Rem End Bug 19880667
Rem ====================================================================

Rem ====================================================================
Rem Begin Bug 20897609
Rem ====================================================================

Rem
Rem Grant create session privilege to existing RAS direct logon user
Rem

DECLARE
CURSOR xs_direct_logon_users IS
select name from dba_xs_users where DIRECT_LOGON_USER = 'YES';

BEGIN
FOR xs_direct_logon_users_crec IN xs_direct_logon_users LOOP
  sys.xs_principal.grant_roles(xs_direct_logon_users_crec.name, 'XSCONNECT');
END LOOP;
END;
/

Rem ====================================================================
Rem End Bug 20897609
Rem ====================================================================

Rem *************************************************************************
Rem 17675121: alter table to include characterset utf8 
Rem           so that after upgrade we use right characterset.
Rem 18403520: alter table to modify readsize, higher readsize 
Rem           might cause ORA-4031 
Rem *************************************************************************
alter table opatch_xml_inv
    ACCESS PARAMETERS
    (
      RECORDS DELIMITED BY NEWLINE CHARACTERSET UTF8
      DISABLE_DIRECTORY_LINK_CHECK
      READSIZE 8388608
      preprocessor opatch_script_dir:'qopiprep.bat'
      BADFILE opatch_script_dir:'qopatch_bad.bad'
      LOGFILE opatch_log_dir:'qopatch_log.log'
      FIELDS TERMINATED BY 'UIJSVTBOEIZBEFFQBL'
      MISSING FIELD VALUES ARE NULL
      REJECT ROWS WITH ALL NULL FIELDS
      (
        xml_inventory    CHAR(100000000)
      )
    )
    LOCATION(opatch_script_dir:'qopiprep.bat');
Rem *************************************************************************
Rem End 17675121
Rem *************************************************************************

Rem =======================================================================
Rem Bug 19651064 - Create partitions for WRH$_SYSMETRIC_HISTORY table
Rem =======================================================================

-- Turn off partition check
alter session set events  '14524 trace name context forever, level 1';

declare
cursor c is select dbid from wrm$_wr_control;
begin
  for tab in c
  loop
    execute immediate 'alter table WRH$_SYSMETRIC_HISTORY split partition '
    || 'WRH$_SYSME_HIST_MXDB_MXSN at (' || tab.dbid || ', MAXVALUE) into '
    || '(partition WRH$_SYSMET_' || tab.dbid || '_0 tablespace SYSAUX, '
    || 'partition WRH$_SYSME_HIST_MXDB_MXSN tablespace SYSAUX) update indexes';
  end loop;
  commit;
exception when others then null;
end;
/

Rem bug 25248712 - Move the copy for bug 19651064 from catuppst.sql (run
Rem                in normal mode) to here (run in upgrade mode).  
Rem                Control number of parallel slaves spawned better to reduce
Rem                resource access limits/contention and to reduce chance of
Rem                exceeding PROCESSES.
Rem                Job scheduler (which can spawn parallel slaves) does not
Rem                run in upgrade mode, hence chance of fewer parallel slaves
Rem                running here.
Rem =======================================================================
Rem Bug 19651064 - Copy data to new WRH$_SYSMETRIC_HISTORY table
Rem =======================================================================

DECLARE
  num_cpu          NUMBER        := 0;
  sql_str          VARCHAR2(240) := '';
  con_id           VARCHAR2(100) := '0';
  is_pdb           BOOLEAN       := FALSE;
  hint1            VARCHAR2(80)  := '';
  hint2            VARCHAR2(80)  := '';

BEGIN

  -- Bug 25248712 - cut down on number of parallel slaves spawned
  BEGIN
    execute immediate
      'select value from v$parameter where name=''cpu_count''' into num_cpu;
  
    con_id := sys_context('USERENV', 'CON_ID');
    IF (con_id <> '0') AND (con_id <> '1') THEN
      is_pdb := TRUE;
    END IF;
  
    IF (is_pdb = FALSE) THEN  -- db is a non-cdb or ROOT
      IF num_cpu < 8 THEN  -- if less than 8 cpus
        hint1 := ' /*+ APPEND parallel enable_parallel_dml */ ';
        hint2 := ' /*+ PARALLEL */ ';
      ELSE                 
        -- lets spawn 32 parallel slaves for this copy for non-CDB/ROOT
        hint1 := ' /*+ APPEND parallel(32) enable_parallel_dml */ ';
        hint2 := ' /*+ PARALLEL(32) */ ';
      END IF;
    ELSE                      -- db is a PDB
      -- lets spawn 2 parallel slaves for this copy per PDB

      -- note:
      -- have tested with 4 million (4,058,580) rows in TMP_SYSMETRIC_HISTORY
      -- on linux host of 2 cpus.
      -- no parallel hint at all: Elapsed: 00:05:03.99
      -- parallel(2) in both insert and select clauses: Elapsed: 00:00:56.19
      -- parallel(4) in both insert and select clauses: Elapsed: 00:00:54.63
      -- parallel(5) in both insert and select clauses: Elapsed: 00:00:58.20
      --
      hint1 := ' /*+ APPEND parallel(2) enable_parallel_dml */ ';
      hint2 := ' /*+ PARALLEL(2) */ ';
    END IF;
  
    sql_str := 'insert ' || hint1 || ' into WRH$_SYSMETRIC_HISTORY ' ||
                 ' select ' || hint2 || ' * from TMP_SYSMETRIC_HISTORY';
  END;  -- end of Bug 25248712 - cut down on number of parallel slaves spawned

  
  -- Bug 19651064 - Copy data to new WRH$_SYSMETRIC_HISTORY table
    begin
    execute immediate 'drop index WRH$_SYSMETRIC_HISTORY_INDEX';
    execute immediate sql_str;
    execute immediate 'drop index TMP_SYSMETRIC_HISTORY_INDEX';
    execute immediate 'drop table TMP_SYSMETRIC_HISTORY';
    execute immediate 'create index WRH$_SYSMETRIC_HISTORY_INDEX '
    || 'on WRH$_SYSMETRIC_HISTORY '
    || '(dbid, snap_id, instance_number, group_id, '
    || 'metric_id, begin_time, con_dbid) '
    || 'local tablespace SYSAUX '
    || 'parallel 2 ';
    commit;
  exception when others then
    if sqlcode in (-942, -1418) then null;
    else raise;
    end if;
  end;  -- end of Bug 19651064 - Copy data from TMP_SYSMETRIC_HISTORY table

END;
/

-- Turn on partition check
alter session set events  '14524 trace name context off';

Rem =======================================================================
Rem Bug 19651064 - End
Rem =======================================================================

Rem =======================================================================
Rem Bug 22345045  - Create partitions for new tables
Rem =======================================================================

-- Turn off partition check
alter session set events  '14524 trace name context forever, level 1';

declare
cursor c is select dbid from wrm$_wr_control;
begin
  for tab in c
  loop
    execute immediate 'alter table WRH$_CELL_GLOBAL_SUMMARY split partition '
    || 'WRH$_CELL_GLOB_SUMM_MXDB_MXSN at (' || tab.dbid || ', MAXVALUE) into '
    || '(partition WRH$_CELL_G_' || tab.dbid || '_0 tablespace SYSAUX, '
    || 'partition WRH$_CELL_GLOB_SUMM_MXDB_MXSN tablespace SYSAUX) '
    || 'update indexes';

    execute immediate 'alter table WRH$_CELL_DISK_SUMMARY split partition '
    || 'WRH$_CELL_DISK_SUMM_MXDB_MXSN at (' || tab.dbid || ', MAXVALUE) into '
    || '(partition WRH$_CELL_D_' || tab.dbid || '_0 tablespace SYSAUX, '
    || 'partition WRH$_CELL_DISK_SUMM_MXDB_MXSN tablespace SYSAUX) '
    || 'update indexes';

    execute immediate 'alter table WRH$_CELL_GLOBAL split partition '
    || 'WRH$_CELL_GLOBAL_MXDB_MXSN at (' || tab.dbid || ', MAXVALUE) into '
    || '(partition WRH$_CELL_G_' || tab.dbid || '_0 tablespace SYSAUX, '
    || 'partition WRH$_CELL_GLOBAL_MXDB_MXSN tablespace SYSAUX) '
    || 'update indexes';

    execute immediate 'alter table WRH$_CELL_IOREASON split partition '
    || 'WRH$_CELL_IOREASON_MXDB_MXSN at (' || tab.dbid || ', MAXVALUE) into '
    || '(partition WRH$_CELL_I_' || tab.dbid || '_0 tablespace SYSAUX, '
    || 'partition WRH$_CELL_IOREASON_MXDB_MXSN tablespace SYSAUX) '
    || 'update indexes';

    execute immediate 'alter table WRH$_CELL_DB split partition '
    || 'WRH$_CELL_DB_MXDB_MXSN at (' || tab.dbid || ', MAXVALUE) into '
    || '(partition WRH$_CELL_D_' || tab.dbid || '_0 tablespace SYSAUX, '
    || 'partition WRH$_CELL_DB_MXDB_MXSN tablespace SYSAUX) update indexes';

    execute immediate 'alter table WRH$_CELL_OPEN_ALERTS split partition '
    || 'WRH$_CELL_DB_MXDB_MXSN at (' || tab.dbid || ', MAXVALUE) into '
    || '(partition WRH$_CELL_O_' || tab.dbid || '_0 tablespace SYSAUX, '
    || 'partition WRH$_CELL_DB_MXDB_MXSN tablespace SYSAUX) update indexes';

    execute immediate 'alter table WRH$_IM_SEG_STAT split partition '
    || 'WRH$_IM_SEG_STAT_MXDB_MXSN at (' || tab.dbid || ', MAXVALUE) into '
    || '(partition WRH$_IM_SEG_' || tab.dbid || '_0 tablespace SYSAUX, '
    || 'partition WRH$_IM_SEG_STAT_MXDB_MXSN tablespace SYSAUX) update indexes';
  end loop;
  commit;
exception when others then 
  --if partitions already exist then continue or if partitions already perform
  -- split partition continue
  if sqlcode in (-14080, -2149) then 
    null;
  else
    raise;
  end if;
end;
/

-- Turn on partition check
alter session set events  '14524 trace name context off';

Rem =======================================================================
Rem Bug 22345045  - End
Rem =======================================================================

Rem =======================================================================
Rem BEGIN changes for bug #22552142
Rem =======================================================================

begin
  execute immediate 'alter profile ora_stig_profile limit
                     inactive_account_time 35
                     password_verify_function ora12c_stig_verify_function';
exception
  when others then
    if sqlcode in (-2376) then 
      null;
    else 
      raise;
    end if;
end;
/

Rem =======================================================================
Rem End changes for bug #22552142
Rem =======================================================================

Rem *************************************************************************
Rem Bug 23515378: revoke select on audit views - START
Rem *************************************************************************
Rem Following changes are related to the views in catamgt.sql, cataudit.sql, 
Rem catfga.sql, catuat.sql, cdfixed.sql, rxsviews.sql

DECLARE
  stmt VARCHAR2(100);
  TYPE obj_name_list  IS VARRAY(100) OF VARCHAR2(64);
  TYPE obj_name_list2 IS VARRAY(10) OF VARCHAR2(64); 
  views_list  obj_name_list;
  views_list2 obj_name_list2;
BEGIN
  -- Make a list of views for revoking select privilege later
  views_list := obj_name_list('DBA_AUDIT_MGMT_CONFIG_PARAMS', 
                              'CDB_AUDIT_MGMT_CONFIG_PARAMS',
                              'DBA_AUDIT_MGMT_LAST_ARCH_TS',
                              'CDB_AUDIT_MGMT_LAST_ARCH_TS',
                              'DBA_AUDIT_MGMT_CLEANUP_JOBS',
                              'CDB_AUDIT_MGMT_CLEANUP_JOBS',
                              'DBA_AUDIT_MGMT_CLEAN_EVENTS',
                              'CDB_AUDIT_MGMT_CLEAN_EVENTS',
                              'DBA_AUDIT_TRAIL',
                              'CDB_AUDIT_TRAIL',
                              'AUDIT_UNIFIED_POLICIES',
                              'AUDIT_UNIFIED_ENABLED_POLICIES',
                              'AUDIT_UNIFIED_CONTEXTS',
                              'AUDIT_UNIFIED_POLICY_COMMENTS',
                              'DBA_FGA_AUDIT_TRAIL',
                              'CDB_FGA_AUDIT_TRAIL',
                              'DBA_COMMON_AUDIT_TRAIL',
                              'CDB_COMMON_AUDIT_TRAIL',
                              'gv_$asm_audit_clean_events',
                              'v_$asm_audit_clean_events',
                              'gv_$asm_audit_cleanup_jobs',
                              'v_$asm_audit_cleanup_jobs',
                              'gv_$asm_audit_config_params',
                              'v_$asm_audit_config_params',
                              'gv_$asm_audit_last_arch_ts',
                              'v_$asm_audit_last_arch_ts',
                              'v_$unified_audit_trail',
                              'gv_$unified_audit_trail',
                              'v_$unified_audit_record_format',
                              'DBA_XS_AUDIT_POLICY_OPTIONS',
                              'CDB_XS_AUDIT_POLICY_OPTIONS',
                              'DBA_XS_ENABLED_AUDIT_POLICIES',
                              'CDB_XS_ENABLED_AUDIT_POLICIES');

  -- Bug 25245797: UNIFIED_AUDIT_TRAIL and CDB_UNIFIED_AUDIT_TRAIL views are
  -- now owned by AUDSYS
  views_list2 := obj_name_list2('UNIFIED_AUDIT_TRAIL',
                                'CDB_UNIFIED_AUDIT_TRAIL',
                                'DBA_XS_AUDIT_TRAIL',
                                'CDB_XS_AUDIT_TRAIL');

  -- Loop through all the views in the list and revoke select privilege
  FOR i IN views_list.first..views_list.last
  LOOP
    BEGIN
      -- Revoke select privilege from audit_admin
      stmt := 'REVOKE SELECT ON SYS.' || views_list(i) || ' FROM audit_admin';
      EXECUTE IMMEDIATE stmt;

      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = -1927 THEN
          -- Ignore ORA-01927: cannot REVOKE privileges you did not grant
            NULL;
          ELSE
            RAISE;
          END IF;
    END;

    BEGIN
      -- Revoke select privilege from audit_viewer
      stmt := 'REVOKE SELECT ON SYS.' || views_list(i) || ' FROM audit_viewer';
      EXECUTE IMMEDIATE stmt;

      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = -1927 THEN
          -- Ignore ORA-01927: cannot REVOKE privileges you did not grant
            NULL;
          ELSE
            RAISE;
          END IF;
    END;
  END LOOP;

  -- Loop through all the views in the list and revoke select privilege
  FOR i IN views_list2.first..views_list2.last
  LOOP
    BEGIN
      -- Revoke select privilege from audit_admin
      stmt := 'REVOKE SELECT ON AUDSYS.' || views_list2(i) || 
              ' FROM audit_admin';
      EXECUTE IMMEDIATE stmt;

      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = -1927 THEN
          -- Ignore ORA-01927: cannot REVOKE privileges you did not grant
            NULL;
          ELSE
            RAISE;
          END IF;
    END;

    BEGIN
      -- Revoke select privilege from audit_viewer
      stmt := 'REVOKE SELECT ON AUDSYS.' || views_list2(i) || 
              ' FROM audit_viewer';
      EXECUTE IMMEDIATE stmt;

      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = -1927 THEN
          -- Ignore ORA-01927: cannot REVOKE privileges you did not grant
            NULL;
          ELSE
            RAISE;
          END IF;
    END;
  END LOOP;

END;
/


Rem *************************************************************************
Rem Bug 23515378: revoke select on audit views - END
Rem *************************************************************************


Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem Invoke 12.2.0 upgrade script

@@a1202000.sql

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================


Rem *************************************************************************
Rem END a1201000.sql
Rem *************************************************************************
