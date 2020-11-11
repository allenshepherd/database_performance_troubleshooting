Rem
Rem $Header: rdbms/admin/dvpatch.sql /main/14 2017/05/28 22:45:57 stanaya Exp $
Rem
Rem dvpatch.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dvpatch.sql - Oracle Database Vault Patch Script
Rem
Rem    DESCRIPTION
Rem       This script is used to apply bugfixes to the DV component.It is run 
Rem      in the context of catpatch.sql, after the RDBMS catalog.sql and 
Rem      catproc.sql scripts are run. It is run with a special EVENT set which
Rem      causes CREATE OR REPLACE statements to only recompile objects if the 
Rem      new source is different than the source stored in the database.
Rem      Tables, types, and public interfaces should not be changed here.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dvpatch.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dvpatch.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    sanbhara    09/26/13 - Bug 16499989 - creating ORA_DV_AUDPOL here since
Rem                           catmacp and prvtmacp are run after dvu121 so will
Rem                           miss some objects.
Rem    jheng       09/24/13 - Bug 17471255: reload dv functions and packages
Rem    kaizhuan    03/12/13 - Bug 16232283: add dvu121
Rem    sanbhara    02/10/11 - Bug Fix 10629966.
Rem    vigaur      06/22/10 - Handle patch changes during release upgrade
Rem    vigaur      06/01/10 - Bug 6503742
Rem    jheng       04/05/10 - fix bug 9481210: insert DV datapump types in
Rem                           metaview$
Rem    vigaur      12/17/09 - Bug 8706788 - Remove WKSYS and WKUSER from ODD
Rem    jheng       12/01/09 - fix bug 9092184: insert into dvsys.code$
Rem    youyang     10/05/09 - bug8635726: add command rule for changing
Rem                           password
Rem    vigaur      11/21/08 - XbranchMerge vigaur_lrg-3392573 from
Rem                           st_rdbms_11.1.0
Rem    vigaur      01/09/08 - LRG 3205969 
Rem    mxu         01/26/07 - Fix errors
Rem    rvissapr    12/01/06 - DV patch
Rem    rvissapr    12/01/06 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

--
-- Add Database Vault to the registry
--

Begin
 DBMS_REGISTRY.LOADING(comp_id     =>  'DV', 
                       comp_name   =>  'Oracle Database Vault', 
                       comp_proc   =>  'VALIDATE_DV', 
                       comp_schema =>  'DVSYS',
                       comp_schemas =>  dbms_registry.schema_list_t('DVF'));
End;
/



@@dvu121.sql

--
-- Reload all the packages, functions and procedures from current release.
--
ALTER SESSION SET CURRENT_SCHEMA = DVSYS;

@@dvmacfnc.plb

@@catmacp.sql

@@prvtmacp.plb

@@catmacg.sql

@@catmact.sql




-- Please do not run any scripts that will create new DV objects below this.
DECLARE
  CURSOR cur IS SELECT OWNER, OBJECT_NAME, OBJECT_TYPE from sys.dba_objects where OBJECT_TYPE IN 
             ('TABLE','VIEW','PACKAGE','FUNCTION','PROCEDURE','SEQUENCE','LIBRARY') and
             OWNER IN ('DVSYS','LBACSYS') order by OWNER,OBJECT_TYPE,OBJECT_NAME;
BEGIN
  EXECUTE IMMEDIATE 'create audit policy ORA_DV_AUDPOL actions AUDIT on DVF.DBMS_MACSEC_FUNCTION'; 
 -- this audit policy will capture all actions performed ON DVSYS, LBACSYS and DVF objects
 -- not including F$* factor functions in DVF schema. 

  FOR row IN cur LOOP
    IF row.object_type = 'TABLE' THEN
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions ALTER on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions AUDIT on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions COMMENT on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions DELETE on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions GRANT on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions INDEX on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions INSERT on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions RENAME on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions UPDATE on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
 
 -- Views named CDB_* are special types of views that consolidate dictionary information from all PDBs.
 -- Internally these views behave like fixed views and hence audit policy cannot be created on them.
    ELSIF row.object_type = 'VIEW' THEN
      IF row.object_name NOT LIKE 'CDB_%' THEN
        EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions AUDIT on '||
          dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
        EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions COMMENT on '||
          dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
        EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions DELETE on '||
          dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
        EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions GRANT on '||
          dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
        EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions INSERT on '||
          dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
        EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions RENAME on '||
          dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
        EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions UPDATE on '||
          dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      END IF;

    ELSIF row.object_type IN ('PACKAGE','FUNCTION','PROCEDURE') THEN
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions AUDIT on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions GRANT on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions RENAME on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);

    ELSIF row.object_type = 'SEQUENCE' THEN
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions ALTER on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions AUDIT on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions GRANT on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);

    ELSE 
      EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions all on '||
        dbms_assert.enquote_name(row.owner, FALSE)||'.'||dbms_assert.enquote_name(row.object_name, FALSE);
    END IF;
  END LOOP;

  EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions GRANT on DVF.DBMS_MACSEC_FUNCTION';
  EXECUTE IMMEDIATE 'alter audit policy ORA_DV_AUDPOL add actions RENAME on DVF.DBMS_MACSEC_FUNCTION';

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -46358) THEN NULL; --ignore if audit policy already exists
     ELSE RAISE;
     END IF;

END;
/

--
-- Done Loading DV. Now Validate 
--
DECLARE
    num number;
    cursor dv_dba_invalid_objects is
      select o.object_id from dba_objects o
       where status = 'INVALID'
         and owner IN ('DVSYS', 'DVF');
BEGIN
    dbms_registry.loaded('DV');

    -- Validate all invalid objects during upgrade 
    FOR row IN dv_dba_invalid_objects LOOP
       dbms_utility.validate(row.object_id);
    END LOOP;

    sys.validate_dv;
END;
/

ALTER SESSION SET CURRENT_SCHEMA = SYS;

COMMIT;

