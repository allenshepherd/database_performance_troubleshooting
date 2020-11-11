Rem
Rem $Header: rdbms/admin/dvdbmig.sql /main/27 2017/05/31 14:01:17 youyang Exp $
Rem
Rem dvdbmig.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dvdbmig.sql - DV Database Migration script
Rem
Rem    DESCRIPTION
Rem      This performs upgrade of DV component from all prior
Rem    releases supported (for dv it starts in 10.2.0.2).
Rem    It first runs the "u" script to upgrade the tables and
Rem    types for DV and then runs the scripts to load in the new
Rem    PLSQL objects
Rem
Rem   Ugrading DV requires relinking of the executable among other steps
Rem   Please see documentation for more details.
Rem
Rem    NOTES
Rem       It is called from catdbmig.sql
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dvdbmig.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dvdbmig.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cmpupnjv.sql 
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youyang     05/18/17 - add sql meta data
Rem    namoham     09/13/16 - Add dvu122.sql
Rem    yapli       04/07/16 - Bug 23062248: Always call dbms_registry.upgraded
Rem    yapli       01/19/16 - Bug 22226617: Reload catmacr.sql
Rem    jibyun      08/05/15 - Bug 21475355: remove unnecessary grant to DVF
Rem    namoham     06/16/15 - Bug 20216779: run catmacs, catmacdd, catmacd,
Rem                           and catmaca.
Rem    kaizhuan    03/27/15 - Project 46814: Support for DV application common
Rem                           policy. Remove create view statements and grant
Rem                           statements from dvu121 and run catmacc here.
Rem    sanbhara    03/26/15 - Project 46814 - adding call to catmacc.sql here
Rem                           and removing all type and view creation from
Rem                           dvu121.sql. Also removed all grants to DV roles
Rem                           from dvu121.sql since they are present in
Rem                           catmacg.sql which is also called here.
Rem    jibyun      01/28/15 - Bug 20399973: default NLS data should be English
Rem    sanbhara    09/26/13 - Bug 16499989 - creating ORA_DV_AUDPOL here since
Rem                           catmacp and prvtmacp are run after dvu121 so will
Rem                           miss some objects.
Rem    namoham     08/01/13 - Bug 15938449: call catmacg after loading packages
Rem    kaizhuan    03/12/13 - Bug 16232283: add dvu121
Rem    yanchuan    09/13/12 - Bug 14456083: grant privileges to
Rem                           DV_DATAPUMP_NETWORK_LINK role
Rem    sanbhara    03/01/12 - Bug 13699578 - add calls to add_nls_data for each
Rem                           language.
Rem    rpang       08/16/11 - Proj 32719: Grant/revoke inherit privileges
Rem    youyang     06/14/11 - remove sync_rules
Rem    sanbhara    02/09/11 - Bug Fix 10629966.
Rem    vigaur      06/22/10 - Add dvpatch invocation
Rem    ruparame    12/18/08 - Bug 7657506
Rem    youyang     11/17/08 - remove alter ddl triggers
Rem    ssonawan    11/06/08 - bug 6938843: add sync_rules() 
Rem    vigaur      04/16/08 - Add 11.1->11.2 migrate script
Rem    ruparame    06/25/07 - Validate invalid objects during DB upgrade
Rem    mxu         04/26/07 - Fix bug 5935104
Rem    mxu         03/06/07 - Fix invalid objects
Rem    rburns      02/20/07 - fix substr compare
Rem    cdilling    01/25/07 - set session back to SYS
Rem    mxu         12/19/06 - Fix errors
Rem    rvissapr    12/01/06 - Migration script
Rem    rvissapr    12/01/06 - Created
Rem


WHENEVER SQLERROR EXIT;
GRANT EXECUTE ON dbms_registry to DVSYS;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Begin
 dbms_registry.upgrading(comp_id =>  'DV', 
                         new_name   =>  'Oracle Database Vault', 
                         new_proc   =>  'VALIDATE_DV');
End;
/

@@catmacdd.sql

-- We pass temp as default and temporary tablespace here as these values
-- are expected to be treated as dummies (i.e. we do not use these values
-- during upgrade.)
@@catmacs.sql temp temp

COLUMN :file_name NEW_VALUE comp_file NOPRINT
VARIABLE file_name VARCHAR2(12)

BEGIN
 IF substr(dbms_registry.version('DV'),1,6)='10.2.0' THEN
  :file_name := 'dvu102.sql';
 ELSIF substr(dbms_registry.version('DV'),1,6)='11.1.0' THEN
  :file_name := 'dvu111.sql';
 ELSIF substr(dbms_registry.version('DV'),1,6)='11.2.0' THEN
  :file_name := 'dvu112.sql';
 ELSIF substr(dbms_registry.version('DV'),1,6)='12.1.0' THEN
  :file_name := 'dvu121.sql';
 ELSIF substr(dbms_registry.version('DV'),1,6)='12.2.0' THEN
  :file_name := 'dvu122.sql';
 ELSE
  :file_name := 'nothing.sql';
 END IF;
END;
/

SELECT :file_name FROM DUAL;
@@?/rdbms/admin/sqlsessstart.sql
@@&comp_file
@?/rdbms/admin/sqlsessend.sql

--
-- Reload all the packages, functions and procedures, etc.
--
ALTER SESSION SET CURRENT_SCHEMA = DVSYS;

@@dvmacfnc.plb

@@catmacc.sql

@@catmacp.sql

@@prvtmacp.plb

@@catmacg.sql

@@catmacr.sql

@@catmacd.sql

@@catmact.sql

@@catmaca.sql

-- Bug 13699578 - loading updated metadata on new version.
DECLARE
  eng_loaded BOOLEAN := FALSE;
BEGIN
  FOR lang in (select unique language from realm_t$) LOOP
    IF ( lang.language = 'us' ) THEN
      IF (eng_loaded = FALSE) THEN
        dvsys.dbms_macadm.add_nls_data('ENGLISH');
        eng_loaded := TRUE;
      END IF;
    ELSIF ( lang.language = 'd' ) THEN
      dvsys.dbms_macadm.add_nls_data('GERMAN'); 
    ELSIF ( lang.language = 'e' ) THEN
      dvsys.dbms_macadm.add_nls_data('SPANISH'); 
    ELSIF ( lang.language = 'f' ) THEN
      dvsys.dbms_macadm.add_nls_data('FRENCH'); 
    ELSIF ( lang.language = 'i' ) THEN
      dvsys.dbms_macadm.add_nls_data('ITALIAN'); 
    ELSIF ( lang.language = 'ja' ) THEN
      dvsys.dbms_macadm.add_nls_data('JAPANESE'); 
    ELSIF ( lang.language = 'ko' ) THEN
      dvsys.dbms_macadm.add_nls_data('KOREAN'); 
    ELSIF ( lang.language = 'ptb' ) THEN
      dvsys.dbms_macadm.add_nls_data('BRAZILIAN PORTUGUESE'); 
    ELSIF ( lang.language = 'zhs' ) THEN
      dvsys.dbms_macadm.add_nls_data('SIMPLIFIED CHINESE'); 
    ELSIF ( lang.language = 'zht' ) THEN
      dvsys.dbms_macadm.add_nls_data('TRADITIONAL CHINESE'); 
    ELSE
      -- For any other languages, load ENGLISH version.
      -- If ENGLISH has already been loaded, skip.
      IF (eng_loaded = FALSE) THEN
        dvsys.dbms_macadm.add_nls_data('ENGLISH'); 
        eng_loaded := TRUE;
      END IF;
    END IF;        
  END LOOP;
END;
/

-- Bug 20216779 - improve error handling during upgrade
-- avoid revalidation of invalid objects as utlrp.sql is called later.
-- Right after DV is upgraded, status for now (until utlrp.sql is called) will
-- be UPGRADED if no errors found during DV upgrade; else INVALID.
-- Bug 23062248: Errors or not, always call sys.dbms_registry.upgraded,
-- which also updates the version and puts a date_upgraded timestamp into the 
-- registry$ table, indicating that the upgrade script has run to completion.
BEGIN
  sys.dbms_registry.upgraded('DV');
  IF (sys.dbms_registry.count_errors_in_registry('DV') > 0) THEN
      sys.dbms_registry.invalid('DV');
  END IF;
END;
/

commit;

ALTER SESSION SET CURRENT_SCHEMA = SYS;
