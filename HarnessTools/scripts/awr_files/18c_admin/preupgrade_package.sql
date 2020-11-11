Rem $Header: rdbms/admin/preupgrade_package.sql /st_rdbms_18.0/2 2018/04/14 07:42:32 raeburns Exp $
Rem
Rem preupgrade_package.sql
Rem
Rem Copyright (c) 2015, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      preupgrade_package.sql - Pre Upgrade Utility Package
Rem
Rem    DESCRIPTION
Rem      Procedures and functions used to perform checks on a database which
Rem      is getting ready to be upgraded.
Rem
Rem    NOTES
Rem      This file contains both the package body and defintion.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/preupgrade_package.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/preupgrade_package.sql 
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/preupgrade_driver.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      03/22/18 - Backport raeburns_bug-27523800 from main
Rem    bymotta     12/06/17 - BUG 27227129: BMMB Variable overflow fix
Rem    raeburns    02/20/18 - Bug 27523800: remove dbms_registry_basic from
Rem                           preupgrade.jar
Rem    fvallin     11/01/17 - RTI 20726707: Added else statement
Rem                           to have None value in tbs_action in 
Rem                           tablespaces_check
Rem    fvallin     10/25/17 - Bug 26957831: Added condition in
Rem    ewittenb    10/18/17 - remove fixups for psuedo-check replacements
Rem    cmlim       10/10/17 - bug 25211082: bring in pdb_archivelog_kb from
Rem                           from 12.2.0.1 preupgrade_package.sql
Rem    ewittenb    09/28/17 - bug 26812429 - rolling upgrade needs
Rem                           _allow_compatibility_adv_w_grp
Rem    welin       09/21/17 - bug 26875355: Handle duplicate entries in 
Rem                           parameters.properties
Rem    jcarey      09/06/17 - Bug 26673741 - add olap_page_pool_size
Rem    ewittenb    08/15/17 - Request 26091010 - number the action items
Rem    cmlim       08/10/17 - bug 26394379: memory recommendations too high for
Rem                           CDBs
Rem    ewittenb    08/08/17 - Bug 26193656 invalid components display
Rem    ewittenb    08/08/17 - RTI-20492129 - postupgrade_fixups did not find
Rem                           18.0
Rem    frealvar    07/25/17 - Bug 26164053 change in exclusive_mode_auth
Rem    tojhuan     07/21/17 - Bug 25515456: remove check for SQLJ obj types
Rem    ewittenb    07/17/17 - update for 18.0
Rem    ewittenb    07/17/17 - update for 18.1
Rem    ewittenb    07/17/17 - bug-26193659 - tablespace info level
Rem    psolomon    07/06/17 - Bug 24923080: pga_aggregate_limit minimum check
Rem    raeburns    06/21/17 - Bug 26194017: Restore APEX check and messages
Rem    hvieyra     06/21/17 - Modify overlap_network_acl check to not use
Rem                           detail_type and detail_info parameters from
Rem                           function get_failed_check_xml
Rem    tojhuan     06/09/17 - Bug 24623721: preupgrade check for SQLJ obj types
Rem    cmlim       05/22/17 - bug 26024333: cap DB_CACHE_SIZE and
Rem                           LARGE_POOL_SIZE; add numa pool to memory sizing
Rem    hvieyra     05/15/17 - Fix for bug 25705134 - Tablespaces check to  
Rem                           properly manage success and failure cases.
Rem    fvallin     05/08/17 - Bug 25688882: Display undo total space counting
Rem                           local undo tablespace. Removed flashback_info check 
Rem                           as it is duplicated with min_recovery_area check 
Rem    fvallin     05/03/17 - Bug 24926629: Display information on default
Rem                           number of cycles if upgrading CDB
Rem    fvallin     04/18/17 - Bug 25912284: Changed prefix in lenght
Rem    frealvar    04/12/17 - Bug 25856232 change type of c_temp_minsz to avoid
Rem                           numeric overflows
Rem    risgupta    04/07/17 - Bug 25677837: Update DV simulation check as
Rem                           post upgrade
Rem    cmlim       04/06/17 - bug 24926629: create function to return default #
Rem                           pdbs upgrading in parallel
Rem    cmlim       04/02/17 - bug 25392096: size for minimum PROCESSES value
Rem                           needed for the db upgrade
Rem    ewittenb    03/30/17 - fix null comparison issue
Rem    cmlim       03/24/17 - bug 25423323: misc fixes:
Rem                           update audit_records_check,
Rem                           post_fixed_objects_check, db_cache_size.
Rem                           remove job_queue_process_check
Rem    bymotta     03/16/17 - Bug 24923249 - PRE-UPGRADE TOOL COULD NOT BE
Rem                           EXECUTED ON A READ ONLY PDB
Rem    ewittenb    03/16/17 - bug-25714511 - rollback segments check needs to
Rem                           confirm db_undo != auto
Rem    nrcorcor    03/16/17 - rti 20172688 - change parm
Rem                           _db_new_lost_write_protect to
Rem                           _db_shadow_lost_write_protect
Rem    frealvar    03/10/17 - Bug 25594468 false alert on tablespace auto extend
Rem    fvallin     03/09/17 - Bug 25339728: Added check to increase undo space
Rem                           in non cdb
Rem    frealvar    03/10/17 - Bug 24820083 Add a check to validate stats on
Rem                           fixed objects before upgrade.
Rem    ewittenb    03/08/17 - rti-20139647
Rem    raeburns    03/08/17 - Bug 25616909: Use UTILITY for SQL_PHASE
Rem    frealvar    03/05/17 - Create generic functions select_number, select_varchar2,
Rem                           select_has_rows.
Rem    frealvar    02/29/17 - Merge fit_to_terminal() and smart_pad()
Rem    frealvar    02/29/17 - Bug 25211930 tempts_notempfile check should
Rem                           also consider tablespace groups
Rem    fvallin     02/16/17 - Bug 25546400: Added current db_version_3_dots  when
Rem                           component info is not found 
Rem    welin       02/15/17 - Move obsolete params into a datafile
Rem    ewittenb    02/02/17 - fix line formatting issues
Rem    frealvar    01/25/17 - Bug 25045534 added more info to postfixup
Rem    risgupta    01/17/17 - Proj 67579: Add check whether DV simulation
Rem                           log has no records
Rem    ewittenb    01/09/17 - Project 71055/67762 New code to remap all of the
Rem                           <InitParams> and its sub-elements
Rem    welin       01/17/17 - format fix
Rem    frealvar    12/19/16 - Bug 25252028 remove check oracle_users_quota
Rem    frealvar    12/13/16 - Bug 24559392 removed extra new lines chars of 
Rem                           the preupgrade report generated 
Rem    frealvar    12/13/16 - Bug 24007257 check for quota of default users
Rem    bymotta     12/02/16 - Bug 24923215: Set statistics concurrent to off
Rem                           when Concurrent is enabled but no Resource
Rem                           Manager configuration is enabled
Rem    ewittenb    12/01/16 - make component sizing and other data be table driven
Rem                           from components.properties.  Remove APEX from
Rem                           components upgraded by server upgrade.
Rem    raeburns    11/26/16 - Bug 25044977: add post-upgrade check for
Rem                           dependent tables
Rem                           Bug 25262869: add NOCYCLE to dependency$ query
Rem    raeburns    11/26/16 - Bug 23231337: remove automatic APEX upgrade
Rem    frealvar    11/18/16 - Fix wrong comment in code of removed params section
Rem    frealvar    11/15/16 - support for renamed tags max_version_exclusive and 
Rem    ealvarad    11/15/16 - RTI 19868924:_posting_ips removed
Rem    frealvar    11/15/16 - support por renamed tags max_version_exclusive and 
Rem                           min_version_inclusive and changed logic of comparison
Rem    frealvar    11/11/16 - Bug 25038937 fix missed tempfile issue in query
Rem    cmlim       10/30/16 - bug 24696626: remove pga_aggregate_limit
Rem                           recommendations
Rem                         - remove gather_schema_stats('SYS') from autofixup
Rem    frealvar    10/27/16 - LRG 19787764 increased max line length in xml
Rem    frealvar    10/15/16 - Bug 24762152 update obsolete/removed/deprecated
Rem                           parameters list
Rem    frealvar    10/15/16 - Bug 24695433 temp tablespace without temp file
Rem    bymotta     10/10/16 - Bug 24810548: Change label to Min Size For
Rem                           Upgrade
Rem    amunnoli    10/02/16 - Bug 24741114: do not error out for aud$unified
Rem                           table partitions
Rem    frealvar    09/30/16 - RTI 19787195 fix query that feeds all_parameters
Rem    frealvar    09/16/16 - RTI 19787818 data not found in all_parameters
Rem    hvieyra     09/07/16 - Bug 20950535. Check if JAVAVM mitigation
Rem                           patch is installed in the database.
Rem    frealvar    09/06/16 - Bug24479767 undescore deprecated/obsolete/removed params
Rem    frealvar    09/05/16 - Bug 23115292 adding new javavm preupgrade check
Rem    ewittenb    08/22/16 - XbranchMerge ewittenb_postup_12.2.0.1.0 from
Rem                           st_rdbms_12.2.0.1.0
Rem    cmlim       08/18/16 - bug 24448551: for now, do not recommend
Rem                           pga_aggregate_limit if value was default
Rem    bymotta     08/14/16 - XbranchMerge bymotta_bug_postfixup from
Rem                           st_rdbms_12.2.0.1.0
Rem    arvijaya    08/03/16 - Bug 24398111:exclude_seed_cdb_view obsolete 12201
Rem    hvieyra     08/12/16 - Fix for bug 23573843. Manage obsolete/deprecated 
Rem                           parameters that were defaulted at database startup
Rem                           but got set to spfile via alter system.
Rem    frealvar    08/10/16 - Bug 24400584 update obsolete/deprecated parameters
Rem    arvijaya    08/03/16 - Bug 24398111:exclude_seed_cdb_view obso.lete 12201
Rem    arvijaya    08/03/16 - Bug 24398111:exclude_seed_cdb_view obsolete 12201
Rem    ewittenb    08/01/16 - XbranchMerge ewittenb_postup from main
Rem    bymotta     07/27/16 - Bug 24012143: Postupgrade_fixups.sql some checks
Rem                           are not working properly. Adding automatic statistics run
Rem                           in the postfixup script, also if those statistics have been run
Rem                           posftfixup will not report it again.
Rem    ewittenb    08/01/16 - XbranchMerge ewittenb_postup from main
Rem    ewittenb    07/13/16 - bug 24340891 and 23641965 dbms_preup and preupgrade_dir must
Rem                           be present
Rem    ewittenb    06/22/16 - make run_fixup_and_report() package visible.
Rem    cmlim       06/16/16 - bug 23596360: pdbs_para cannot be 0 
Rem    bymotta     06/13/16 - Bug: 23573843 Adding Obsolete parameters
Rem    amunnoli    06/07/16 - Bug 23539027: Fix wallet query to work in 11.2
Rem    amunnoli    05/31/16 - Bug 23221566: check audit tables in encrypted ts
Rem    bymotta     05/20/16 - Bug 23278082: Add null management on a query that
Rem                           as of 12.2 will not return any value
Rem    cmlim       05/11/16 - bug 23185159: convert archive/fra info to checks
Rem    frealvar    05/10/16 - correction for fixed_objects_check
Rem    bymotta     05/10/16 - Wrong query on files_backup_mode_check fucntion
Rem    ewittenb    05/04/16 - bug 23216475
Rem    ewittenb    04/21/16 - Bug 23000563 - generation of
Rem                           preupgrade_fixups.sql and postupgrade_fixups.sql
Rem    kaizhuan    04/19/16 - lrg 19415919: check PA views existence before
Rem                           querying the views.
Rem    frealvar    04/10/16 - Bug 20669175 check for any pending dst session
Rem                           before upgrade
Rem    ewittenb    04/11/16 - Add APEX_PATCH check and tweak other surrounding
Rem                           APEX issues.
Rem    frealvar    04/10/16 - Bug 23064794 deprecated/obsoleted parameters
Rem    frealvar    04/10/16 - Bug 20984980 databases edition into the log
Rem    cmlim       04/09/16 - bug 22128117: memory sizing for upgrade to 12.2
Rem    frealvar    03/25/16 - Bug 22695570 change check for postupgrade_fixups
Rem    kaizhuan    03/23/16 - Bug 22862142: add check for Privilege Analysis
Rem    pknaggs     03/09/16 - Bug #20847187: Exclusive Mode checks for 12.2
Rem    amunnoli    03/09/16 - Bug 22899818: Check for oracle maintained bit
Rem    yanchuan    03/06/16 - Bug 20505982: remove warning message
Rem                           about disable Database Vault
Rem    hvieyra     03/02/16 - Fix for bug 22708956- Add check to detect
Rem                           datamining data in customer tablespace
Rem    tojhuan     03/02/16 - 22744959: make xdb_resource_type_check compatible
Rem                           with databases not having XDB installed
Rem    raeburns    02/29/16 - Bug 22820096: revert ALTER TYPE to default
Rem                           CASCADE
Rem    frealvar    02/15/16 - Bug 22360200  ora-06502: buffer too small
Rem    ewittenb    02/11/16 - add run_fixup_and_report() for backward
Rem                           compatibility
Rem    raeburns    02/03/16 - Bug 22322252: Add pre-upgrade check for USER
Rem                           tables dependent on Oracle-Maintained types
Rem    ewittenb    01/29/16 - use INTEGER instead of NUMBER to retain large
Rem                           scale > 32 bits and without fractions
Rem    bymotta     01/19/16 - Bug 22471732, Fix for upgrade.xml file
Rem                           truncation.
Rem    welin       01/28/15 - fix bad /main/35 with main/37
Rem    schakkap    12/23/15 - #(22454765) add check for dbms_stats method_opt
Rem                           preference
Rem    sramakri    12/15/15 - bug-22166873: check for mv refresh
Rem    welin       12/14/15 - Bug 21531270: Gather dictionary stats post upgrade
Rem    frealvar    12/10/15 - 22220833 fix call to DBMS_PREUP.PURGE_RECYCLEBIN_FIXUP
Rem                           and removed nested queries in init_resources
Rem    ewittenb    12/10/15 - exclude OFFLINE NORMAL files from
Rem                           files_need_recovery_check
Rem    rpang       12/02/15 - Bug 22292132: network_acl_priv_check return value
Rem    bymotta     11/25/15 - Bug 22125093: UPGRADE:SOME PDBS PREUPGRADE LOG
Rem                           ARE MISSING, adding messages to explain why the
Rem                           logs were not created, mostly because the DB/PDB
Rem                           was not opened.
Rem    ssonawan    11/25/15 - 21289647: REMOTE_LOGIN_PASSWORDFILE check
Rem    frealvar    11/10/15 - 22174779: changed logic used in store_removed_param
Rem                           and added utl_file_dir to the deprecated param list
Rem    rpang       10/23/15 - Bug 22061588: 12.1 network ACL migration check
Rem    frealvar    10/22/15 - frealvar_read_only_db_state: moved functions from
Rem                           preupgrade_package to dbms_registry_extended,
Rem                           linesize modified, added improvements into procedure
Rem                           store_comp and removed function is_db_readonly
Rem    frealvar    10/28/15 - 21849635: change the placeholder format used
Rem    tojhuan     10/12/15 - 21795185: if XDB.XDB$RESOURCE_T has incorrect-
Rem                           ordered attributes CheckedOutByID/BaseVersion,
Rem                           check whether we can fix it during upgrade
Rem    ewittenb    10/07/15 - fix wrong version numbers in
Rem                           oracle_reserved_users
Rem    frealvar    10/01/15 - removed references to registry$sys_inv_objs from
Rem                           invalid_objects_exist check
Rem    ewittenb    09/30/15 - fix archivelogs text output
Rem    bymotta     09/28/15 - Bug 21902277: Some auto-fixup actions are not
Rem                           working properly, this transaction makes sure all
Rem                           auto-fixups will work as expected.
Rem    ewittenb    09/28/15 - make minor tweaks as part of message enhancement
Rem    frealvar    08/25/15 - bug 21646111 check for trigger owner with no 
Rem                           administer database trigger privilege
Rem                           if the compatible value was not explicitly set
Rem    frealvar    08/24/15 - bug 21529376 added two new checks which verify
Rem                           parameters pga_aggregate_target and pga_aggregate_limit
Rem    bymotta     09/23/15 - Bug 21843339 - fix to avoid fetch when awr
Rem                           contans more than one dbid
Rem    ewittenb    09/03/15 - Modify to fix output text for rollback segments
Rem                           port fixes for bugs 21388784, 21688231 from
Rem                           from utluppkg.sql.
Rem    bymotta     09/01/15 - Adding functionality to preupgrade package
Rem    skayoor     08/28/15 - Bug 21388784: Mark O7_DICTIONARY_ACCESSIBILITY as
Rem                           deprecated
Rem    svaziran    08/25/15 - bug 21548817: check for application_trace_viewer
Rem    risgupta    08/25/15 - Lrg 18421763: Check whether OLS is installed in
Rem                           OLS version preupgrade check
Rem    amunnoli    08/24/15 - Bug 21688231: Update UNIAUD_TAB tag correctly
Rem    risgupta    07/31/15 - Bug 21178327: Add check whether OLS
Rem                           version is same as CATPROC version
Rem    frealvar    07/02/15 - bug 13022498 A new check which advise the user
Rem                           if the compatible value was not explicitly set
Rem    frealvar    06/04/15 - bug 20795508 Problem with minimum size for the
Rem                           temporary tablespace in the preupgrade.log
Rem    frealvar    05/25/15 - bug 21102514 invalid default temp tablespaces
Rem    namoham     05/12/15 - Bug 16570807: Include a filter to check default
Rem                           DV role conflicts
Rem    hvieyra     05/06/15 - Bug fix for 19581925 UNDO TS recommendation
Rem    rpang       04/27/15 - Bug 20723336: overlapping network ACLs check
Rem    welin       04/20/15 - lrg 15956167: Changing the preupgrade tool 
Rem                           to set Compatibility value to 11.2
Rem    bnnguyen    04/11/15 - bug 20860190: Rename 'EXADIRECT' to 'DBSFWUSER'
Rem    jorgrive    03/24/15 - add GGSYS and GGSYS_ROLE checks
Rem    hvieyra     03/20/15 - Fix Bug 20107503 - Precising CATNOAMD.SQL WARNING
Rem                           MESSAGE
Rem    welin       03/09/15 - Bug 20591183, JOB_QUEUE_PROCESS should be >0
Rem    hvieyra     02/10/15 - Bug fix for 18500508 Use 8 digits DB version
Rem    cmlim       01/25/15 - bug 19367547 - include pdb files in the output
Rem                           summary; change pdb file name format; support
Rem                           xml pdb files so dbua can run preupgrd.sql in
Rem                           parallel; drop text dir objs 
Rem    hvieyra     01/07/15 - Bug fix for 18961009 remove APEX/DV old version
Rem                           code
Rem    hvieyra     12/19/14 - Bug Fix 19873610 Non-Default Tablespace
Rem                           validation
Rem    jerrede     12/10/14 - Fix Bug 19499984 for vrecover_file within a CDB
Rem    hvieyra     12/04/14 - Bug Fix for 8889083 Database archiving display
Rem    jerrede     11/05/14 - Add more clarity to the compatibility check
Rem    bnnguyen    10/29/14 - bug 19697038: add check for EXADIRECT USER/ROLE
Rem    jorgrive    10/20/14 - Desupport Advanced Replication
Rem    cmlim       10/19/14 - lrg 13418229: latest time zone file version is 23
Rem    cmlim       10/06/14 - bug 19646646: update time zone MOS note from
Rem                           977512.1 to 1509653.1
Rem    jlingow     09/11/14 - proj-58146 add check for existing 
Rem                           remote_scheduler_agent
Rem    spapadom    08/18/14 - Added checks for SYS$UMF and SYSUMF_ROLE. 
Rem    cmlim       08/14/14 - bug 19195895: make sure inserts/updates are not
Rem                           done if db is read only
Rem    ewittenb    08/05/14 - Update for 12.2 support by removing support for
Rem                           direct upgrades from 11.2.0.2
Rem    ewittenb    07/30/15 - bring forward changes to utluppkg.sql - changes listed above
Rem    yanlili     06/23/15 - check xs_connect role for RAS
Rem    ewittenb    04/04/15 - initial port from utluppkg.sql
Rem
set serverout on format wrapped

CREATE OR REPLACE PACKAGE dbms_preup AS

    c_build                  CONSTANT NUMBER := 1;    -- the unique build# of this package.

    --
    --    PACKAGE Constants
    --
    debug BOOLEAN := FALSE; 
    debug_archive_fra BOOLEAN := FALSE;  -- debug for archiving/fra checks
    pDBGSizeResources BOOLEAN := FALSE;
  

    --
    --    The result of every CHECK must be c_success or c_failure.
    --    CHECK failure severities and other attributes of
    --    a check can then be looked up on the check_record_t
    --    of the failing CHECK.
    --
    c_success    CONSTANT NUMBER := 1;
    c_failure    CONSTANT NUMBER := 2;

    --
    --    Each CHECK has one SEVERITY associated with it.
    --    That severity is only meaningful when
    --    the result of the CHECK is c_failure.
    --    NOTE: Changes to these constants or the addition
    --    of new ones should be met with a reset of
    --    check_level_strings defined further below.
    --
    c_check_level_success    CONSTANT NUMBER := 1; 
    c_check_level_warning    CONSTANT NUMBER := 2;
    c_check_level_info       CONSTANT NUMBER := 3;
    c_check_level_error      CONSTANT NUMBER := 4;
    c_check_level_recommend  CONSTANT NUMBER := 5;

    c_param_type_number      CONSTANT NUMBER := 3;
    c_param_type_number_alt  CONSTANT NUMBER := 6;
    c_param_type_string      CONSTANT NUMBER := 2;
    c_param_type_version     CONSTANT NUMBER := -1;
    c_param_type_other       CONSTANT NUMBER := 0;
   
     
    C_FIXUP_SCRIPT_NAME_PRE_BASE    CONSTANT VARCHAR2(30) := 'preupgrade_fixups'; 
    C_FIXUP_SCRIPT_NAME_PRE VARCHAR2(256);

    C_FIXUP_SCRIPT_NAME_POST_BASE   CONSTANT VARCHAR2(30) := 'postupgrade_fixups'; 
    C_FIXUP_SCRIPT_NAME_POST VARCHAR2(256);

    --
    -- surrounds the substitution number, i.e. {1}, {2}, etc.
    -- inside a check message.
    --
    C_SUBSTITUTION_DELIMITER_OPEN  CONSTANT CHAR(1) := '{';
    C_SUBSTITUTION_DELIMITER_CLOSE CONSTANT CHAR(1) := '}';

    --
    -- indexes (by pool names) into mem_parameters table for the given pools
    --
    cs_idx CONSTANT V$PARAMETER.NAME%TYPE := 'db_cache_size';
    jv_idx CONSTANT V$PARAMETER.NAME%TYPE := 'java_pool_size';
    sp_idx CONSTANT V$PARAMETER.NAME%TYPE := 'shared_pool_size';
    lp_idx CONSTANT V$PARAMETER.NAME%TYPE := 'large_pool_size';
    sr_idx CONSTANT V$PARAMETER.NAME%TYPE := 'streams_pool_size';
    pt_idx CONSTANT V$PARAMETER.NAME%TYPE := 'pga_aggregate_target';
    st_idx CONSTANT V$PARAMETER.NAME%TYPE := 'sga_target';
    mt_idx CONSTANT V$PARAMETER.NAME%TYPE := 'memory_target';

    -- minimum flashback log size (in Kbytes) generated per pdb
    -- for 12.2 (and 18)
    C_MIN_FLASHBACK_KB_PER_PDB   CONSTANT NUMBER := 333 * 1024;

    -- sublist of users in 112 taken from catctl @ORACLEUSERSDATAFOR11
    orcl_usrs112 VARCHAR2(4000):= '''ANONYMOUS'',''APEX_040200'',
            ''APEX_PUBLIC_USER'',''APPQOSSYS'',
            ''AUDSYS'',''CTXSYS'',''DBHADOOP'',
            ''DBSNMP'',''DIP'',''DV_ACCTMGR'',
            ''DVF'',''DVSYS'',''EXFSYS'',
            ''FLOWS_FILES'',''GDS_CATALOG_SELECT'',
            ''GSMADMIN_INTERNAL'',''GSMCATUSER'',
            ''GSMUSER'',''LBACSYS'',''MDDATA'',
            ''MDSYS'',''OJVMSYS'',''OLAPSYS'',
            ''OPTIMIZER_PROCESSING_RATE'',
            ''ORACLE_OCM'',''ORDDATA'',
            ''ORDPLUGINS'',''ORDSYS'',
            ''OUTLN'',''PROVISIONER'',
            ''SI_INFORMTN_SCHEMA'',
            ''SPATIAL_CSW_ADMIN_USR'',
            ''SPATIAL_WFS_ADMIN_USR'',
            ''SYS'',''SYSBACKUP'',''SYSDG'',
            ''SYSKM'',''SYSTEM'',''TSMSYS'',
            ''WMSYS'',''XDB'',''XS$NULL'',
            ''XS_NSATTR_ADMIN''';

    --
    --    PACKAGE Exceptions
    --
    e_noColumnFound EXCEPTION;
    PRAGMA exception_init(           e_noColumnFound,          -904);

    nameAlreadyExists EXCEPTION;
    PRAGMA exception_init(           nameAlreadyExists,        -955);

    e_userCancel EXCEPTION;
    PRAGMA exception_init(           e_userCancel,            -1013);

    e_noParamFound EXCEPTION;
    PRAGMA exception_init(           e_noParamFound,          -2003);

    e_noOraConnect1 EXCEPTION;
    PRAGMA exception_init(           e_noOraConnect1,         -3113);

    e_noOraConnect2 EXCEPTION;
    PRAGMA exception_init(           e_noOraConnect2,         -3114);

    e_undefinedFunction EXCEPTION;
    PRAGMA exception_init(           e_undefinedFunction,     -6550);

    invalidFileOperation EXCEPTION;
    PRAGMA exception_init(           invalidFileOperation,   -29283);

    invalidFileRename EXCEPTION;
    PRAGMA exception_init(           invalidFileRename,      -29292);

    classInUse EXCEPTION;
    PRAGMA exception_init(           classInUse,             -29553);

    stringNotSimpleSQLName EXCEPTION;
    PRAGMA exception_init(           stringNotSimpleSQLName, -44003);

    --
    --    PACKAGE TYPEs
    --

    TYPE string_array_t IS TABLE OF VARCHAR2(32767);
    TYPE string_array_collection_t IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
    TYPE detail_t IS RECORD (
        detail       VARCHAR2(4000),
        detail_type  VARCHAR2(30)
    );

    TYPE number_array_t IS TABLE OF NUMBER;

    TYPE messagevalue_t is RECORD (
        position NUMBER,
        value CLOB
    );

    TYPE messagevalues_t IS TABLE OF messagevalue_t INDEX BY BINARY_INTEGER;
    TYPE message_t is RECORD (
        -- msg_text      VARCHAR2(4000),    -- aka the RULE
        -- cause         VARCHAR2(4000),    -- aka the BROKEN_RULE
        -- action        VARCHAR2(4000),
        -- detail        detail_t
        id            VARCHAR2(4000),
        messagevalues messagevalues_t
    );

    TYPE fixup_t IS RECORD (
        fixup_type VARCHAR2(30),
        fixAtStage VARCHAR2(30)
    );

    TYPE component_t IS RECORD (
      cid            VARCHAR2(30), -- component id
      cname          VARCHAR2(45), -- component name
      script         VARCHAR2(128), -- upgrade script name
      version        VARCHAR2(30), -- version
      status         VARCHAR2(15),  -- component status
      install        BOOLEAN
    );

    TYPE components_t IS TABLE OF component_t INDEX BY BINARY_INTEGER;

    TYPE tablespace_t IS RECORD (
        name         VARCHAR2(128),
        additional_size INTEGER,
        min             INTEGER,
        alloc           INTEGER,
        inc_by          INTEGER,
        fauto           BOOLEAN,
        contents        SYS.dba_tablespaces.contents%type
    );

    TYPE tablespaces_t IS TABLE OF tablespace_t INDEX BY BINARY_INTEGER;

    TYPE archivelogs_t IS RECORD (
        name         VARCHAR2(128),
        additional_size INTEGER
    );

    TYPE flashbacklogs_t IS RECORD (
        name         VARCHAR2(128),
        additional_size INTEGER
    );

    TYPE rollback_segment_t IS RECORD (
        name         VARCHAR2(128),
        tablespc     VARCHAR2(128),
        status       VARCHAR2(31),
        auto         INTEGER,
        inuse        INTEGER,
        next         INTEGER,
        max_ext      INTEGER
    );

    TYPE rollback_segments_t IS TABLE OF rollback_segment_t INDEX BY BINARY_INTEGER;

    TYPE flashback_info_t IS RECORD (
        name           VARCHAR2(513), -- name
        limit          INTEGER,       -- space limit
        used           INTEGER,       -- Used
        dsize          INTEGER,       -- db_recovery_file_dest_size
        reclaimable    INTEGER,
        files          INTEGER,       -- number of files
        min_fra_size   INTEGER
    );

    TYPE fra_info_t IS RECORD (
        name                V$RECOVERY_FILE_DEST.NAME%TYPE, -- name/path
        limit               INTEGER,  -- db_recovery_file_dest_size (bytes)
        used                INTEGER,  -- Used (bytes)
        dsize               INTEGER,  -- destination size
        reclaimable         INTEGER,  -- bytes reclaimable
        files               INTEGER,  -- number of files
        avail               INTEGER,  -- bytes available in FRA
        min_archive_gen     INTEGER,  -- minimum archive logs (bytes) estimated
                                      --   to be generate during upgrade
        min_flashback_gen   INTEGER,  -- rough minimum flashback logs (bytes)
                                      --   to be generated during upgrade
        min_fra_size        INTEGER,  -- new db_recovery_file_dest_size to set
        min_freespace_reqd  INTEGER,  -- min free space needed for logs
                                      -- to be generated during upgrade
        additional_size     INTEGER   -- additional size + limit = min_fra_size
    );

    -- TYPE ARCHive DESTination RECORD Type
    -- stores info from v$archive_dest if there's at least 1 non-fra destination
    TYPE archiveDest_info_t IS RECORD (
      dest_name          V$ARCHIVE_DEST.DEST_NAME%TYPE, -- log_archive_dest_<N>
      destination        V$ARCHIVE_DEST.DESTINATION%TYPE, -- destination <path>
      status             V$ARCHIVE_DEST.STATUS%TYPE,   -- e.g., VALID/INACTIVE
      min_archive_gen    NUMBER         -- min free space needed for archivelogs
                                        -- to be generated during upgrade
    );

    TYPE systemresource_t IS RECORD (
        tablespaces       tablespaces_t,
        archivelogs       archivelogs_t,
        flashbacklogs     flashbacklogs_t,
        rollback_segments rollback_segments_t,
        flashback_info    flashback_info_t,
        archivedest_info  archiveDest_info_t
    );

-- @@Datatype

    TYPE parameter_xml_record_t IS RECORD (
        name              V$PARAMETER.NAME%TYPE,
        value             V$PARAMETER.VALUE%TYPE,    -- used only when a parameter is being renamed.
        type              V$PARAMETER.TYPE%TYPE,
        isdefault         V$PARAMETER.ISDEFAULT%TYPE,
        is_obsoleted      BOOLEAN,
        is_deprecated     BOOLEAN,
        renamed_to_name   VARCHAR2(80),
        new_value         VARCHAR2(80),
        min_value         INTEGER,
        min_char_value    VARCHAR2(20)   -- used for COMPATIBLE whose value is a pseudo number
    );

    TYPE parameters_t IS TABLE OF parameter_xml_record_t INDEX BY BINARY_INTEGER;

    TYPE initparams_t IS RECORD (
        update_params     parameters_t,
        nonhandled_params parameters_t,    -- at 12.2, will have no params.  maintained for XML compatibility only.
        rename_params     parameters_t,
        remove_params     parameters_t
    );

    TYPE preupgradecheck_t IS RECORD  (
        id          VARCHAR2(30),    -- the CHECK name
        severity    NUMBER,          -- "status" attribute in xml
        -- message   message_t,
        rule        message_t,
        broken_rule message_t,
        action      message_t,
        detail      detail_t,
        fixup       fixup_t
    );

    TYPE preupgradechecks_t IS TABLE OF preupgradecheck_t INDEX BY BINARY_INTEGER;

    TYPE rdbmsup_t IS RECORD (
        xmlns               VARCHAR2(1000),
        version             VARCHAR2(30),
        upgradable_versions VARCHAR2(1000)
    );

    TYPE database_t IS RECORD (
        name          VARCHAR2(256),
        containerName VARCHAR2(256),
        containerId   NUMBER,
        version       VARCHAR2(30),
        compatibility VARCHAR2(30),
        blocksize     INTEGER,
        platform      VARCHAR2(100),
        timezoneVer   NUMBER,
        log_mode      VARCHAR2(30),
        readonly      BOOLEAN,
        edition_val   VARCHAR2(30)     -- SYS.REGISTRY$.EDITION%TYPE - except it is not avail on 10.2
    );

    -- this table holds computation info for the memory pools we are
    -- making sizing recommendations for
    TYPE memparameter_record_t IS RECORD (
      name       V$PARAMETER.NAME%TYPE,
      old_value  NUMBER,  -- current value
      min_value  NUMBER,  -- minimum value for upgrade
      new_value  NUMBER,  -- new/recommended value for upgrade
      dif_value  NUMBER,  -- diff of old_value - min_value
      isdefault  V$PARAMETER.ISDEFAULT%TYPE, -- is the value defaulted?
                                             -- 'TRUE'/'FALSE'
      display    BOOLEAN  -- display recommended value? T/F
    );
    TYPE memparameter_table_t IS TABLE of memparameter_record_t
      INDEX BY V$PARAMETER.NAME%TYPE;
    mem_parameters  memparameter_table_t;  -- MEMory PARAMETERS table

    db_is_cdb         BOOLEAN; -- is db a cdb? T/F
    db_is_root        BOOLEAN; -- is db a ROOT container database? T/F
    db_n_pdbs         NUMBER;  -- total Number of PDBs as queried from v$pdbs
    is_show_mem_sizes BOOLEAN := FALSE; -- SHOW/display minimum MEMory SIZES?
                                        -- init to FALSE
    is_archivelog_in_fra BOOLEAN := FALSE; -- are archive logs in FRA? T/F

    --
    --    Provide mappings from a c_check_level_* constant to its string evuivalent used
    --    for XML output only.  These strings have specific meanings to DBUA.  Do not
    --    change without corresponding change in the upgrade.xsd and DBUA buy-in.
    --    IMPORTANT: The order of these strings must correspond to the constants C_CHECK_LEVEL_*
    --
    check_level_strings string_array_t := new string_array_t('SUCCESS','WARNING','INFO','ERROR','RECOMMEND');
    TYPE check_level_ints_t IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    check_level_ints check_level_ints_t;


    --
    --    PACKAGE Procedures and Functions
    --    The actual CHECK functions will appear later.
    --
    FUNCTION  get_con_id  RETURN NUMBER;      -- get container or db id
    FUNCTION  get_con_name  RETURN VARCHAR2;  -- get container or db name
    FUNCTION  pvalue_to_number (value_string VARCHAR2) RETURN NUMBER;

    FUNCTION  get_failed_check_xml(check_name IN VARCHAR2,
                                  substitution_parameter_values IN string_array_t,
                                  detail_type IN VARCHAR2,
                                  detail_info IN VARCHAR2)
                                  RETURN CLOB;
    FUNCTION  xml_to_text(xml CLOB) RETURN CLOB;
    FUNCTION  run_fixup(check_name VARCHAR2) RETURN BOOLEAN;
    FUNCTION  run_fixup(check_name VARCHAR2, fixup_id NUMBER) RETURN BOOLEAN;
    PROCEDURE run_fixup_and_report (check_name VARCHAR2);  -- backwards compatibility
    FUNCTION  run_fixup_only(check_name IN VARCHAR2, check_result_xml IN OUT VARCHAR2) RETURN BOOLEAN;
    FUNCTION  get_invalid_objects(fromsys IN VARCHAR2) RETURN SYS_REFCURSOR;
    PROCEDURE invalid_objects;
    PROCEDURE init_mem_sizes(memvp IN OUT MEMPARAMETER_TABLE_T);
    PROCEDURE find_mem_sizes(memvp                 IN OUT MEMPARAMETER_TABLE_T,
                             display_min_mem_sizes IN OUT BOOLEAN);
    PROCEDURE find_sga_mem_values(memvp IN OUT MEMPARAMETER_TABLE_T);
    FUNCTION  get_npdbs RETURN NUMBER;
    FUNCTION  is_con_root RETURN BOOLEAN;
    FUNCTION  is_size_this_memparam (name V$PARAMETER.NAME%TYPE) RETURN BOOLEAN;
    FUNCTION  run_int_proc (statement VARCHAR2, result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN BOOLEAN;
    FUNCTION  num_pdbs_upg_in_parallel RETURN NUMBER;
    FUNCTION  num_pdb_batches_upg (pdbs_in_parallel NUMBER) RETURN NUMBER;
    PROCEDURE find_processes_value;  -- find minimum processes value
    PROCEDURE find_archive_dest_info;
    PROCEDURE find_recovery_area_info;
    FUNCTION  find_all_pdb_archive_size RETURN NUMBER;

    --
    --    The CHECK functions
    -- 
    FUNCTION run_preupgrade(output_filename IN VARCHAR2 DEFAULT null,
                        xml IN BOOLEAN DEFAULT false) RETURN BOOLEAN;

    FUNCTION run_all_checks(result_xml OUT CLOB) RETURN NUMBER;

    FUNCTION run_check(check_name IN VARCHAR2, result_xml OUT CLOB) RETURN BOOLEAN;

    FUNCTION oracle_reserved_users_check    (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION compatible_parameter_check     (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION ols_sys_move_check             (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION awr_dbids_present_check        (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION pa_profile_check               (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION em_present_check               (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION files_need_recovery_check      (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION files_backup_mode_check        (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION two_pc_txn_exist_check         (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION sync_standby_db_check          (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION ultrasearch_data_check         (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION remote_redo_check              (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION sys_default_tablespace_check   (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION sys_default_tablespace_fixup   (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN number;
    FUNCTION invalid_laf_check              (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION depend_usr_tables_check        (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION depend_usr_tables_fixup        (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN number;    
    FUNCTION invalid_usr_tabledata_fixup    (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN number;    
    FUNCTION invalid_usr_tabledata_check    (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION invalid_sys_tabledata_check    (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION invalid_sys_tabledata_fixup    (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN number;
    FUNCTION enabled_indexes_tbl_check      (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION enabled_indexes_tbl_fixup      (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN number;
    FUNCTION ordimageindex_check            (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION invalid_objects_exist_check    (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION amd_exists_check               (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION exf_rul_exists_check           (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION new_time_zones_exist_check     (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION old_time_zones_exist_check     (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION purge_recyclebin_check         (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION purge_recyclebin_fixup         (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN number;
    FUNCTION job_queue_process_0_check      (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION upg_by_std_upgrd_check         (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION xbrl_version_check             (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION apex_manual_upgrade_check         (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION default_resource_limit_check   (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION conc_res_mgr_check             (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION conc_res_mgr_fixup             (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN number;    
    FUNCTION dictionary_stats_check         (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION dictionary_stats_fixup         (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN number;
    FUNCTION hidden_params_check            (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION underscore_events_check        (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION audit_records_check            (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION post_fixed_objects_check       (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION post_dictionary_check          (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION post_dictionary_fixup          (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN number;
    FUNCTION compatible_not_set_check       (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION overlap_network_acl_check      (result_txt OUT CLOB) RETURN number;
    FUNCTION repcat_setup_check             (result_txt OUT CLOB) RETURN number;
    FUNCTION ols_version_check              (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION uniaud_tab_check               (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION jvm_mitigation_patch_check     (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION jvm_mitigation_patch_fixup     (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN number;
    FUNCTION post_jvm_mitigat_patch_check   (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION audtab_enc_ts_check            (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION trgowner_no_admndbtrg_check    (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION xdb_resource_type_check        (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION network_acl_priv_check         (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION rlp_param_check                (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION mv_refresh_check               (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION dbms_stats_method_opt_check    (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION case_insensitive_auth_check    (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION exclusive_mode_auth_check      (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION data_mining_object_check       (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION pending_dst_session_check      (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION min_archive_dest_size_check    (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION min_recovery_area_size_check   (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION javavm_status_check            (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION tempts_notempfile_check        (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION pga_aggregate_limit_check      (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION dv_simulation_check            (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION parameter_min_val_check        (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION parameter_min_val_fixup        (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN NUMBER;
    FUNCTION parameter_rename_check         (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION parameter_rename_fixup         (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN NUMBER;
    FUNCTION parameter_new_name_val_check   (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION parameter_new_name_val_fixup   (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN NUMBER;
    FUNCTION olap_page_pool_size_check       (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION parameter_obsolete_check       (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION parameter_obsolete_fixup       (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN NUMBER;
    FUNCTION parameter_deprecated_check     (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION rollback_segments_check        (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION tablespaces_check              (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION tablespaces_info_check         (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION pre_fixed_objects_check        (result_txt OUT CLOB) RETURN NUMBER;
    FUNCTION pre_fixed_objects_fixup        (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN NUMBER;
    FUNCTION cycle_number_check             (result_txt OUT CLOB) RETURN NUMBER;

    --
    --    ##NEW_CHECK## declare the new CHECK function above.  For cleanliness,
    --    please ensure that the order of CHECKs matches the order in preupgrade_messages.properties
    --    though there is no technical requirement to do that here.
    --
   
END dbms_preup;
/

show errors;

-- ***********************************************************************
--                         Package Body
-- ***********************************************************************
CREATE OR REPLACE PACKAGE BODY dbms_preup AS


--
--    Package Body Constants
--
C_TERMINAL_WIDTH NUMBER := 80;
C_FIXUP_TAG VARCHAR2(20) := '(AUTOFIXUP)';

c_kb           CONSTANT BINARY_INTEGER := 1024;       -- 1 KB
c_mb           CONSTANT number := 1048576;    -- 1 MB
c_gb           CONSTANT number := 1073741824; -- 1 GB

-- minimum size constants for tablespace sizing, in units of Kbytes and Mbytes
-- c_sysaux_minsz_kb : (500*1024)Kb = 500Mb -- minimum size for sysaux
-- c_undo_minsz_kb : (400*1024)Kb = 400Mb   -- minimum size for undo
-- c_incby_minsz_mb : 50Mb                  -- minimum size to increase by
c_sysaux_minsz_kb CONSTANT BINARY_INTEGER := 500 * c_kb;  -- (500*1024)kb =500M
c_undo_minsz_kb   CONSTANT BINARY_INTEGER := 400 * c_kb;  -- (400*1024)kb =400M
c_temp_minsz_kb CONSTANT BINARY_INTEGER := 125 * c_kb; -- (125*1024)kb =125M

C_MAX_CHECK_NAME_LENGTH CONSTANT NUMBER := 24;    -- length of function names is 30, but leave 6 characters for our suffixes
C_MSG_NA_B4_121 CONSTANT VARCHAR2(100) := 'Not Applicable in Pre-12.1 database';

--
-- Can't use this for declaring strings but can for length
-- checks
--
c_str_max                CONSTANT NUMBER := 4000;


--
--    Types
--

--
--    check_record_t holds all of the information about a CHECK
--
TYPE check_record_t IS RECORD (
                    name                VARCHAR2(24),  -- size is 24 because
                                                       -- function names
                                                       -- limited to 30,
                                                       -- less 6 for suffix
                                                       -- like "_check"
                    severity                 NUMBER,
                    rule                     VARCHAR2(4000),
                    broken_rule              VARCHAR2(4000),
                    action                   VARCHAR2(4000),
                    fixup_stage              VARCHAR2(40),
                    fixup_is_detectable      BOOLEAN,
                    auto_fixup_available     BOOLEAN,
                    min_version_inclusive    VARCHAR2(20),
                    max_version_exclusive    VARCHAR2(20)
);


--
--    Holds all the static data about the whole set of CHECKs
--
TYPE check_table_t
    IS TABLE OF check_record_t INDEX BY BINARY_INTEGER;

--
--    add a means of easily accessing check_table_t by VARCHAR2
--    as well as by BINARY_INTEGER
--
TYPE hashtable_of_ints_t
    IS TABLE OF BINARY_INTEGER INDEX BY VARCHAR2(4000);

TYPE comp_record_t IS RECORD (
  cid            VARCHAR2(30), -- component id
  cname          VARCHAR2(45), -- component name
  version        VARCHAR2(30), -- version
  status         VARCHAR2(15), -- component status
  schema         VARCHAR2(30), -- owner of component
  def_ts         VARCHAR2(30), -- name of default tablespace
  script         VARCHAR2(128), -- upgrade script name
  processed      BOOLEAN,       -- TRUE IF in the registry AND is not
                                -- status REMOVING/REMOVED, OR
                                -- TRUE IF will be in the registry because
                                -- because cmp_info().install is TRUE
  install             BOOLEAN,  -- TRUE if component to be installed in upgrade
  sys_kbytes          INTEGER,  -- upgrade size needed in system tablespace
  sysaux_kbytes       INTEGER,  -- upgrade size needed in sysaux tablespace
  def_ts_kbytes       INTEGER,  -- upgrade size needed in 'other' tablespace
  ins_sys_kbytes      INTEGER,  -- install size needed in system tablespace
  ins_def_kbytes      INTEGER,  -- install size needed in 'other' tablespace
  archivelog_kbytes   INTEGER,  -- minimum archive log space per component
  flashbacklog_kbytes INTEGER,  -- minimum flashback log size per component
  pdb_archivelog_kb   INTEGER   -- minimum archive log per component per pdb
);

TYPE comp_table_t IS TABLE of comp_record_t INDEX BY BINARY_INTEGER;
cmp_info comp_table_t;      -- Table of component information


TYPE tablespace_record_t IS RECORD (
  name    VARCHAR2(128), -- tablespace name
  inuse   NUMBER,       -- kbytes inuse in tablespace
  alloc   NUMBER,       -- kbytes allocated to tbs
  auto    NUMBER,       -- autoextend kbytes available
  avail   NUMBER,       -- total kbytes available
  delta   NUMBER,       -- kbytes required for upgrade
  inc_by  NUMBER,       -- kbytes to increase tablespace by
  min     NUMBER,       -- minimum required kbytes to perform upgrade
  addl    NUMBER,       -- additional space allocated during upgrade
  fname   VARCHAR2(513), -- filename in tablespace
  fauto   BOOLEAN,       -- TRUE if there is a file to increase autoextend
  temporary BOOLEAN,     -- TRUE if Temporary tablespace
  localmanaged BOOLEAN,
  contents SYS.dba_tablespaces.contents%type
);

TYPE tablespace_table_t IS TABLE OF tablespace_record_t
   INDEX BY BINARY_INTEGER;

ts_info tablespace_table_t; -- Tablespace information

TYPE rollback_record_t IS RECORD (
  tbs_name VARCHAR2(30), -- tablespace name
  seg_name VARCHAR2(30), -- segment name
  status   VARCHAR(30),  -- online or offline
  inuse    NUMBER, -- kbytes in use
  next     NUMBER, -- kbytes in NEXT
  max_ext  NUMBER, -- max extents
  auto     NUMBER  -- autoextend available for tablespace
);

TYPE rollback_table_t IS TABLE of rollback_record_t
  INDEX BY BINARY_INTEGER;

rs_info    rollback_table_t;  -- Rollback segment information

TYPE fb_record_t IS RECORD (
  active         BOOLEAN,                    -- ON or OFF
  file_dest      SYS.V$PARAMETER.VALUE%TYPE, -- db_recovery_file_dest
  dsize          INTEGER,                    -- db_recovery_file_dest_size
  name           SYS.V$PARAMETER.VALUE%TYPE, -- name
  limit          INTEGER,                    -- space limit
  used           INTEGER,                    -- Used
  reclaimable    INTEGER,
  files          INTEGER                     -- number of files
);
flashback_info fb_record_t;

fra_info          fra_info_t;          -- stores fra destination
archivedest_info  archiveDest_info_t;  -- stores non-fra archive destination

TYPE parameter_record_t IS RECORD (
    name              V$PARAMETER.NAME%TYPE,
    value             V$PARAMETER.VALUE%TYPE,
    type              V$PARAMETER.TYPE%TYPE,
    isdefault         V$PARAMETER.ISDEFAULT%TYPE,    -- 'FALSE' when the low version db explicitly sets it to non-default value
    isspecified       V$SPPARAMETER.ISSPECIFIED%TYPE, -- Indicates whether the parameter was specified in the spfile (TRUE) or not (FALSE)
    is_obsoleted      BOOLEAN,
    is_deprecated     BOOLEAN,
    renamed_to_name   VARCHAR2(80),
    new_value         V$PARAMETER.VALUE%TYPE,
    min_value         INTEGER
);
TYPE parameter_t IS TABLE OF parameter_record_t INDEX BY V$PARAMETER.NAME%TYPE;
all_parameters parameter_t;

TYPE cursor_t  IS REF CURSOR;

--
--    Convenient table that maps numeric severities to their string meanings
--
TYPE severity_names_t
    IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

TYPE hash_map_t
    IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(4000);

--
--    "Unchanging" VARIABLES - no changes to these once initialized.
--
C_ORACLE_HIGH_VERSION_4_DOTS VARCHAR2(30);    -- derived from dbms_registry_basic

check_table                  check_table_t;
check_table_index_by_name    hashtable_of_ints_t;
supported_component_index    hashtable_of_ints_t;
severity_names               severity_names_t;

db_name             V$DATABASE.NAME%TYPE;
db_version_4_dots   V$INSTANCE.VERSION%TYPE;    -- Complete version of the un-upgraded database.
db_version_3_dots   V$INSTANCE.VERSION%TYPE;    -- Converted version of the un-upgraded database.
db_version_2_dots   V$INSTANCE.VERSION%TYPE;    -- Converted version of the un-upgraded database.
db_version_1_dot    V$INSTANCE.VERSION%TYPE;    -- Converted version of the un-upgraded database.
db_version_0_dots   V$INSTANCE.VERSION%TYPE;    -- Converted version of the un-upgraded database.
db_compatible       V$PARAMETER.VALUE%TYPE;     -- COMPATIBILITY parameter setting
db_block_size       V$PARAMETER.VALUE%TYPE;     -- DB_BLOCK_SIZE parameter setting
db_undo             V$PARAMETER.VALUE%TYPE;     -- UNDO_MANAGEMENT parameter setting
db_undo_tbs         V$PARAMETER.VALUE%TYPE;     -- UNDO_TABLESPACE parameter setting
db_cpus             NUMBER;  -- # of cpus on the system
db_cpu_threads      NUMBER;
db_64bit            BOOLEAN;
db_32bit            BOOLEAN;
db_platform         VARCHAR2(128);
db_platform_id      NUMBER;
db_tz_version       NUMBER;                     -- timzone number
db_edition          VARCHAR2(30);               -- SYS.REGISTRY$.EDITION%TYPE but not avail on 10.2
db_log_mode         VARCHAR2(30);
db_flashback_on     BOOLEAN;
db_fra_set          BOOLEAN;  -- is fast recovery area/FRA set? T/F
                              -- TRUE if db_recovery_file_destination and
                              -- db_recovery_file_destination_size are set.
db_is_XE            BOOLEAN;
db_VLM_enabled      BOOLEAN;
db_inplace_upgrade  BOOLEAN;
db_is_readonly      BOOLEAN;
con_name            VARCHAR2(128);
con_id              NUMBER;
cdb_constraint      VARCHAR2(1000);
preupgrade_dir_path VARCHAR2(600);
pga_limit_min_dbua  NUMBER;                     -- minimum pga_aggregate_limit value for DBUA xml file
high_version_apex   VARCHAR2(40) := '&C_APEX_VERSION_4_DOTS';

pMinFlashbackLogGen INTEGER;                    -- minimum flashbacklog setting
pminArchiveLogGen   INTEGER;                    -- minimum archivelog setting

crlf VARCHAR2(2);    -- will be either a linefeed or a carriage return/linefeed depending on platform
crlf_length NUMBER;
dir_sep CHAR;

--
--    short lifespan values used during the package_body's initialization only
--    usually just to receive the value of some SELECT before it gets manipulated
--    and stuffed into some permanent global.
--
edition_str      VARCHAR2(30);            -- SYS.REGISTRY$.EDITION%TYPE is not avail on 10.2
param_as_string  V$PARAMETER.VALUE%TYPE;  -- receive v$parameter.value
flashback_off    INTEGER;
cdb_string       VARCHAR2(50);
use_indirect_data_buffers SYS.V$PARAMETER.VALUE%TYPE;
tmp_count        NUMBER;                  -- tmp variable for count(*)

properties hash_map_t;
ordered_check_names string_array_collection_t;
invalid_xml_message message_t;
preupgradecheck_failure_count  NUMBER;

fixup_cols number_array_t := new number_array_t(0,-6, 2,C_MAX_CHECK_NAME_LENGTH, 2,10, 2,32);

-- ***********************************************************************
--                  Generic Utility / Helper FUNCTIONs/PROCEDUREs
-- ***********************************************************************

FUNCTION boolean_string(bool BOOLEAN, trueResult VARCHAR2, falseResult VARCHAR2) RETURN VARCHAR2
IS
BEGIN
    IF bool THEN
        RETURN trueResult;
    ELSE
        RETURN falseResult;
    END IF;
END boolean_string;

FUNCTION boolean_string(bool BOOLEAN) RETURN VARCHAR2
IS
BEGIN
    RETURN boolean_string(bool, 'TRUE', 'FALSE');
END boolean_string;

PROCEDURE internal_error(message clob)
IS
    prefix VARCHAR2(2000); 
    adjusted_message VARCHAR2(32767);
BEGIN
    --
    --    Preupgrade encountered an unexpected serious error
    --    that will prevent processing downstream.
    --    Emit message directly to output, now, just in case
    --    the exception mechanism gets sick too.
    --
    BEGIN
        prefix := properties('INTERNAL_ERROR');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- can happen if the error precedes message initialization.
            prefix := ' ';
    END;

    IF length(message) + length(prefix) > 32600 THEN
        adjusted_message := substr(message,1, 32600) || ' (TRUNCATED)';
    ELSE
        adjusted_message := message;
    END IF;
    dbms_output.put_line(prefix || crlf || adjusted_message);

    EXECUTE IMMEDIATE 'BEGIN ' ||
                      ' RAISE_APPLICATION_ERROR (-20000, ''' || adjusted_message || '''); END;';

END internal_error;


PROCEDURE errormsg(message VARCHAR2)
IS
BEGIN
    dbms_output.put_line(message);    -- this function will be expanded in future.
END errormsg;


FUNCTION smart_pad(src CLOB, pad_width_incl_prefix NUMBER, prefix VARCHAR2) RETURN CLOB
IS
   cut_index NUMBER;
   virtual_width NUMBER;  -- since prefix is added to each line, this is width of line ignoring the prefix.
BEGIN
    IF (src IS NULL) THEN
        return null;
    END IF;

    IF prefix is NULL or length(prefix) = 0 THEN
        virtual_width := pad_width_incl_prefix;
    ELSE
        virtual_width := pad_width_incl_prefix - length(prefix);
    END IF;

    --
    --    If the source string contains a CRLF prior to the virtual width,
    --    then respect it.
    --
    cut_index := instr(src, crlf);
    IF ((cut_index > 0) AND
        (cut_index < virtual_width) ) THEN
        RETURN prefix || substr(src, 1, cut_index-1) || crlf ||
               smart_pad(substr(src, cut_index+1), pad_width_incl_prefix, prefix);
    ELSE
        IF length(src) <= virtual_width THEN
            RETURN prefix || src;
        ELSE
            --
            --    SRC is longer than virtual_width and it has no
            --    crlf before the virtual_width.  So, attempt
            --    to chop the SRC at the last space character
            --    before the virtual_width.
            --
            cut_index := virtual_width;
            WHILE ((cut_index > 0) AND
                   (substr(src, cut_index, 1) <> ' ') ) LOOP
                cut_index := cut_index - 1;
            END LOOP;

            IF (cut_index = 0) THEN
                --
                --    SPECIAL CASE: no space or crlf in entire line.  Forced to chop it off "mid-word"
                --    use all characters on the line.
                --
                RETURN prefix || substr(src, 1, virtual_width) || crlf ||
                       smart_pad(substr(src, virtual_width+1), pad_width_incl_prefix, prefix);
            ELSE
                -- the normal chop point.  We found a space character.
                RETURN prefix || substr(src, 1, cut_index-1) || crlf ||
                       smart_pad(substr(src, cut_index+1), pad_width_incl_prefix, prefix);
            END IF;
        END IF;
    END IF;
END smart_pad;


PROCEDURE format_long_output(outstr VARCHAR2)
IS
    next_line_start NUMBER := 1;
    next_crlf NUMBER := 1;  -- seed a non-zero dummy value
BEGIN
    WHILE next_crlf <> 0 LOOP
       next_crlf := instr(outstr, crlf, next_line_start);
       IF next_crlf <> 0 THEN
           dbms_output.put_line(substr(outstr, next_line_start, next_crlf - next_line_start));
           next_line_start := next_crlf + crlf_length;
       ELSE
           IF next_line_start < length(outstr) THEN
               dbms_output.put_line(substr(outstr, next_line_start));
           END IF;
       END IF;
    END LOOP;
END format_long_output;


--
-- Generic routines to handle no_data_found issues
--

FUNCTION select_varchar2(query VARCHAR2, no_data_found_value VARCHAR2) RETURN
VARCHAR2
IS
    result VARCHAR2(32767);
BEGIN
  BEGIN
    EXECUTE IMMEDIATE query into result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      result := no_data_found_value;
    WHEN OTHERS THEN
      raise;
  END;
  RETURN result;
END select_varchar2;

FUNCTION select_number(query VARCHAR2, no_data_found_value NUMBER) RETURN
NUMBER
IS
    result NUMBER;
BEGIN
  BEGIN
    EXECUTE IMMEDIATE query into result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      result := no_data_found_value;
    WHEN OTHERS THEN
      raise;
  END;
  RETURN result;
END select_number;

-- Returns true if a given query returns rows, false otherwise
FUNCTION select_has_rows(query VARCHAR2) RETURN BOOLEAN
IS
  t_null  CHAR(1);
BEGIN
  BEGIN
    EXECUTE IMMEDIATE query INTO t_null;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
    WHEN OTHERS THEN
      raise;
  END;
  RETURN TRUE;
END select_has_rows;

FUNCTION column_format(column_sizes number_array_t, column_values string_array_t) RETURN CLOB
IS
    column_num NUMBER;
    width NUMBER;
    align_left BOOLEAN;
    value CLOB;
    need_another_row BOOLEAN := true;
    subsequent_row string_array_t := column_values;
    result CLOB := '';

BEGIN
  subsequent_row := column_values;
  WHILE need_another_row LOOP
    need_another_row := false;
    FOR column_num IN 1 .. column_sizes.count LOOP
        width := column_sizes(column_num);
        value := subsequent_row(column_num);

        IF (value IS NULL) OR (width = 0) THEN
            -- do this case separately so we don't have unexpected string operations on nulls
            value := rpad(' ', abs(width));   -- doesn't matter if left/right align, even if width=0
        ELSE
            -- negative widths mean align output on the right (typical number format.)
            -- make width positive and determine which alignment we're using.
            align_left := (width > 0);
            width := abs(width);

            IF length(value) <= width THEN
                IF align_left THEN
                    value := rpad(value, width);    -- (align left = pad on right)
                ELSE
                    value := lpad(value, width);    -- (align right = pad on left)
                END IF;
                subsequent_row(column_num) := null;
            ELSE
                need_another_row := true;
                subsequent_row(column_num) := substr(value, width + 1);
                value := substr(value, 1, width);
            END IF;
        END IF;

        result := result || value;
    END LOOP;

    IF need_another_row THEN
        result := result || crlf;
    END IF;
  END LOOP;

  RETURN result;
END column_format;

FUNCTION displayBytes(bytes INTEGER) RETURN VARCHAR2
IS
    metric string_array_t := new string_array_t(' Bytes',' KB',' MB',' GB',' TB');
    thousands NUMBER := 1;
    result VARCHAR2(30) := '';
    local_bytes INTEGER;
BEGIN
    local_bytes := bytes;
    IF local_bytes < 0 THEN
        local_bytes := -local_bytes;
        result := '-';
    END IF;

    -- using 10000 as the cutoff prevents a loss of significant digits.
    -- for example, results may read as high as 9999MB before kicking to 10GB
    WHILE local_bytes >= 10000 LOOP
        thousands := thousands + 1;
        local_bytes := local_bytes / 1024;
    END LOOP;

    RETURN result || to_char(local_bytes) || metric(thousands);
END displayBytes;

--
--    Debugging info output
--
PROCEDURE DisplayDiagLine (line IN VARCHAR2)
IS
BEGIN
    dbms_output.put_line('<!-- DBG: ' || line || ' -->');
END DisplayDiagLine;


--
--    This function converts a parameter string to a number. The function takes
--    into account that the parameter string may have a 'K' or 'M' multiplier
--    character.
--
FUNCTION pvalue_to_number (value_string VARCHAR2) RETURN NUMBER
IS
  ilen NUMBER;
  pvalue_number NUMBER;

BEGIN
    -- How long is the input string?
    ilen := LENGTH ( value_string );

    -- Is there a 'K' or 'M' in last position?
    IF SUBSTR(UPPER(value_string), ilen, 1) = 'K' THEN
         RETURN (c_kb * TO_NUMBER (SUBSTR (value_string, 1, ilen-1)));

    ELSIF SUBSTR(UPPER(value_string), ilen, 1) = 'M' THEN
         RETURN (c_mb * TO_NUMBER (SUBSTR (value_string, 1, ilen-1)));
    END IF;

    -- A multiplier wasn't found. Simply convert this string to a number.
    RETURN (TO_NUMBER (value_string));
END pvalue_to_number;


--
--    This function returns TRUE if a component ID represents
--    a component that can be upgraded using the server upgrade software.
--
FUNCTION is_supported_component(cid VARCHAR2) RETURN BOOLEAN
IS
BEGIN
    return supported_component_index.exists(cid);
END is_supported_component;


--
--    This function returns TRUE if a component can be upgraded
--    by the server upgrade and is either present in the users db
--    or will be installed into the users db as part of the
--    server upgrade.  A "processed" component is one that
--    will be involved when the current DB is upgraded.
--
FUNCTION is_processed_component(cid VARCHAR2) RETURN BOOLEAN
IS
BEGIN
    IF is_supported_component(cid) THEN
        return cmp_info(supported_component_index(cid)).processed;
    ELSE
        return FALSE;
    END IF;
END is_processed_component;


--  This functions returns a cursor which contains  
--  the invalid objects from the container.
--  if FROMSYS is SYS, the function will return the sys objects
--  otherwise will return non sys objects
FUNCTION get_invalid_objects (FROMSYS IN VARCHAR2)
  RETURN SYS_REFCURSOR
AS
  OBJ_LIST SYS_REFCURSOR;
BEGIN
  IF FROMSYS = 'SYS' THEN
    OPEN OBJ_LIST FOR SELECT OWNER, OBJECT_NAME, OBJECT_TYPE
        FROM SYS.DBA_OBJECTS WHERE STATUS !='VALID' 
        AND OWNER IN ('SYS','SYSTEM')
        ORDER BY OWNER,OBJECT_NAME;
    RETURN OBJ_LIST;
  ELSE
    OPEN OBJ_LIST FOR SELECT OWNER, OBJECT_NAME, OBJECT_TYPE
        FROM SYS.DBA_OBJECTS WHERE STATUS !='VALID' 
        AND OWNER NOT IN ('SYS','SYSTEM')
        ORDER BY OWNER,OBJECT_NAME;
    RETURN OBJ_LIST;
  END IF;
END get_invalid_objects;

--
--  This function shows the SYS/SYSTEM and Non-SYS/SYSTEM
--  invalid objects by one call
--
PROCEDURE invalid_objects
IS
    SYSINV       SYS_REFCURSOR;
    NONSYSINV    SYS_REFCURSOR;
    OWNER        DBA_OBJECTS.OWNER%TYPE;
    OBJECT_NAME  DBA_OBJECTS.OBJECT_NAME%TYPE;
    OBJECT_TYPE  DBA_OBJECTS.OBJECT_TYPE%TYPE;
BEGIN

    DBMS_OUTPUT.PUT_LINE(RPAD('SYS/SYSTEM INVALID OBJECTS', 30));
    DBMS_OUTPUT.PUT_LINE(RPAD('OWNER',30)||RPAD('|OBJECT_NAME',80)||RPAD('|OBJECT_TYPE',19));
    DBMS_OUTPUT.PUT_LINE(RPAD(' ',129,'-'));
    SYSINV := GET_INVALID_OBJECTS('SYS');
    LOOP
        FETCH SYSINV INTO OWNER,OBJECT_NAME,OBJECT_TYPE;
        EXIT WHEN SYSINV%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(OWNER,30)||RPAD(OBJECT_NAME,80)||RPAD(OBJECT_TYPE,19));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(RPAD('NON SYS/SYSTEM INVALID OBJECTS', 30));
    DBMS_OUTPUT.PUT_LINE(RPAD('OWNER',30)||RPAD('|OBJECT_NAME',80)||RPAD('|OBJECT_TYPE',19));
    DBMS_OUTPUT.PUT_LINE(RPAD(' ',129,'-'));
    NONSYSINV := GET_INVALID_OBJECTS('NONSYS');
    LOOP
        FETCH NONSYSINV INTO OWNER,OBJECT_NAME,OBJECT_TYPE;
        EXIT WHEN NONSYSINV%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(OWNER,30)||RPAD(OBJECT_NAME,80)||RPAD(OBJECT_TYPE,19));
    END LOOP;
END invalid_objects;

-- Used to execute a sql statement
-- Errors are returned in sqlerrtxt and sqlerrcode
--
FUNCTION execute_sql_statement (statement VARCHAR2,
                                sqlerrtxt OUT VARCHAR2,
                                sqlerrcode OUT NUMBER) RETURN BOOLEAN
IS
BEGIN
    BEGIN
        EXECUTE IMMEDIATE statement;
        EXCEPTION WHEN OTHERS THEN
            sqlerrtxt := SQLERRM;
            sqlerrcode := SQLCODE;
            RETURN false;
    END;
    RETURN true;
END execute_sql_statement;

--
--    Convenience to shorten source code at call sites.
--    FILE IO limited to 32767 characters
PROCEDURE to_file(output_file UTL_FILE.FILE_TYPE, line IN VARCHAR2)
IS
BEGIN
    utl_file.put_line(output_file, line);
END to_file;


--
--    Formats a string with substitution characters for
--    a numbered substitution parameter for a CHECK's messsage.
--
FUNCTION make_msg_param(param_number IN NUMBER) RETURN VARCHAR2
IS
BEGIN
    return C_SUBSTITUTION_DELIMITER_OPEN || to_char(param_number) || C_SUBSTITUTION_DELIMITER_CLOSE;
END make_msg_param;


--
--    get_check_record_by_name
--
FUNCTION get_check_record_by_name(check_name in VARCHAR2) RETURN check_record_t
IS
    result check_record_t := null;
    idx NUMBER := -1;
BEGIN
    IF debug THEN
        dbms_output.put_line('In get_check_record_by_name(), check_name=' || check_name);
    END IF;

    BEGIN
        idx := check_table_index_by_name(check_name);
        result := check_table(idx);
    EXCEPTION
        WHEN OTHERS THEN
            IF debug THEN
                dbms_output.put_line('Unexpected ERROR: could not find CHECK info for ' || check_name);
                dbms_output.put_line('                  idx=' || to_char(idx));
            END IF;
    END;

    RETURN result;
END get_check_record_by_name;


--
--    if db is a cdb, return container name.
--    if db is a noncdb, return container name (which is basically the db name).
--    if db is pre-12.1, then it doesn't have a CON_NAME.  just return db name.
--    note: name returned is in uppercase.
--
FUNCTION get_con_name RETURN VARCHAR2
IS
  conName   VARCHAR2(128) := '';
BEGIN

  -- get container name
  begin
    execute immediate
      'select upper(SYS_CONTEXT(''USERENV'', ''CON_NAME'')) from sys.dual'
      into conName;
  exception
    WHEN e_noParamFound THEN conName := '';
  end;

  -- if container name is null, then this must be a pre-121 db.
  -- just get db name.
  if conName is NULL then
    execute immediate 'select upper(name) from sys.v$database' into conName;
  end if;

  return conName;
END get_con_name;

--
--    if db is a cdb, return container id.
--    if db is a noncdb, return container id (which is 0).
--    if db is pre-12.1, then it doesn't have a CON_ID.  just return 0.
--    note: a noncdb in 12.1 has a con id of 0.
--
FUNCTION get_con_id RETURN NUMBER
IS
  conId   NUMBER := 0;
BEGIN
  begin
    execute immediate
      'select SYS_CONTEXT(''USERENV'', ''CON_ID'') from sys.dual'
      into conId;
  exception
    -- Bug 23539027: Handle the exception when USERENV param is not found
    WHEN e_noParamFound THEN conId:=0;
    WHEN others THEN raise;
  end;

  return conId;
END get_con_id;


PROCEDURE read_components_properties
IS
    props_file utl_file.file_type;
    props_line VARCHAR2(32767);
    property_name VARCHAR2(4000);
    property_value VARCHAR2(32767);
    version VARCHAR2(20);   -- holds the version read from the properties file
    component_id VARCHAR2(50);  -- holds the "CID" shorthand name for the component
    attribute_name VARCHAR2(50);  -- holds the name of a field of cmp_info
    new_index BINARY_INTEGER;
    equals_index NUMBER;
    first_dot_index NUMBER;
    second_dot_index NUMBER;
BEGIN
    props_file := utl_file.fopen('PREUPGRADE_DIR', 'components.properties', 'r',32767);
    LOOP
        BEGIN
            utl_file.get_line(props_file, props_line);
            IF debug THEN
                dbms_output.put_line('READ components.properties: ' || props_line);
            END IF;

            --
            --   Skip comments in the properties file, identified by
            --   blank lines or ones starting with #
            --
            IF (props_line IS NOT NULL) AND
               (trim(substr(props_line,1, instr(props_line||'#','#')-1)) IS NOT NULL) THEN
                equals_index := instr(props_line, '=');
                property_name := upper(trim(substr(props_line, 1, equals_index-1)));
                property_value := substr(props_line, equals_index + 1);
                --
                --    Now process the line we just read in.
                --    Its value is useful only if the version it
                --    pertains to matches the database version.
                --
                version := substr(property_name, 1, instr(property_name, '.', 1, 1) - 1);
                version := replace(version, '_', '.');    -- convert the underscores to the normal dots.
                --    version 18.0+ comparisons need to match only 1 dot, before that, we need 3.
                IF ( (dbms_registry_extended.compare_versions(db_version_1_dot, '18.0', 1) >= 0) AND
                     (dbms_registry_extended.compare_versions(db_version_1_dot, version, 1) = 0) ) OR
                   (dbms_registry_extended.compare_versions(db_version_3_dots, version, 3) = 0) THEN 
                    first_dot_index :=  instr(property_name, '.', 1, 1);
                    second_dot_index := instr(property_name, '.', 1, 2);
                    component_id :=   substr(property_name, first_dot_index+1, second_dot_index - first_dot_index - 1);
                    attribute_name := substr(property_name, second_dot_index+1);

                    IF supported_component_index.exists(component_id) THEN
                        new_index := supported_component_index(component_id);
                    ELSE 
                        new_index := cmp_info.count() + 1;
                        supported_component_index(component_id) := new_index;

                        --
                        --    Create blank entry for new component
                        --
                        --    These STATIC values will be filled in by
                        --    other attributes read from this file
                        --
                        cmp_info(new_index).cid := component_id;
                        cmp_info(new_index).cname := null;
                        cmp_info(new_index).script := null;
                        cmp_info(new_index).sys_kbytes := 0;
                        cmp_info(new_index).sysaux_kbytes := 0;
                        cmp_info(new_index).def_ts_kbytes := 0;
                        cmp_info(new_index).ins_sys_kbytes := 0;
                        cmp_info(new_index).ins_def_kbytes := 0;
                        cmp_info(new_index).archivelog_kbytes := 0;
                        cmp_info(new_index).flashbacklog_kbytes := 0;
                        --
                        --    These Dynamic values (dependent on DB)
                        --    will be computer later, outside this routine
                        --
                        cmp_info(new_index).version := null;
                        cmp_info(new_index).status := null;
                        cmp_info(new_index).schema := null;
                        cmp_info(new_index).def_ts := null;
                        cmp_info(new_index).processed := FALSE;
                        cmp_info(new_index).install := FALSE;

                    END IF;

                    IF (attribute_name = 'CNAME') THEN
                        cmp_info(new_index).cname := property_value;
                    ELSIF (attribute_name = 'SCRIPT') THEN
                        cmp_info(new_index).script := property_value;
                    ELSIF (attribute_name = 'SYS_KBYTES') THEN
                        cmp_info(new_index).sys_kbytes := to_number(property_value);
                    ELSIF (attribute_name = 'SYSAUX_KBYTES') THEN
                        cmp_info(new_index).sysaux_kbytes := to_number(property_value);
                    ELSIF (attribute_name = 'DEF_TS_KBYTES') THEN
                        cmp_info(new_index).def_ts_kbytes := to_number(property_value);
                    ELSIF (attribute_name = 'INS_SYS_KBYTES') THEN
                        cmp_info(new_index).ins_sys_kbytes := to_number(property_value);
                    ELSIF (attribute_name = 'INS_DEF_KBYTES') THEN
                        cmp_info(new_index).ins_def_kbytes := to_number(property_value);
                    ELSIF (attribute_name = 'ARCHIVELOG_KBYTES') THEN
                        cmp_info(new_index).archivelog_kbytes := to_number(property_value);
                    ELSIF (attribute_name = 'FLASHBACKLOG_KBYTES') THEN
                        cmp_info(new_index).flashbacklog_kbytes := to_number(property_value);
                    ELSIF (attribute_name = 'PDB_ARCHIVELOG_KBYTES') THEN
                        cmp_info(new_index).pdb_archivelog_kb := to_number(property_value);
                    ELSE
                        internal_error('Invalid components.properties line due to unknown attribute while processing: ' || props_line);
                    END IF;
                END IF;  -- no ELSE since this property pertains to a different release,

            END IF;  -- line had a valid name=value on it.

        EXCEPTION WHEN no_data_found THEN
            utl_file.fclose(props_file);
            EXIT;
        END;
    END LOOP;


EXCEPTION
    WHEN invalidFileOperation THEN
        dbms_output.put_line('ERROR - Cannot open the ' ||
            'components.properties file from the directory object preupgrade_dir');
        RAISE;
    WHEN OTHERS THEN
        -- invalid components.xml file.
        internal_error('Invalid components.properties line processing: ' || props_line);
END read_components_properties;



PROCEDURE define_check ( name            IN VARCHAR2,
                         severity        IN VARCHAR2,
                         rule            IN VARCHAR2,
                         broken_rule     IN VARCHAR2,
                         action          IN VARCHAR2,
                         fixup_stage     IN VARCHAR2,
                         auto_fixup_available IN BOOLEAN,
                         fixup_is_detectable  IN BOOLEAN,
                         min_version_inclusive     IN VARCHAR2,
                         max_version_exclusive     IN VARCHAR2
                       )
IS
    new_index BINARY_INTEGER;
BEGIN
    IF debug THEN
        dbms_output.put_line('In define_check() for name=' || name);
    END IF;

    new_index := check_table.count() + 1;

    IF (length(name) > C_MAX_CHECK_NAME_LENGTH) THEN
        internal_error('length of ''' || name || ''' is too long for a CHECK name. Max is ' || to_char(C_MAX_CHECK_NAME_LENGTH));
    END IF;

    IF (NOT check_level_ints.exists(severity)) THEN
        internal_error('Invalid value for CHECK.' || name || '.SEVERITY in preupgrade_messages.properties');
    END IF;

    check_table(new_index).name := name;
    check_table(new_index).severity := check_level_ints(severity);
    check_table(new_index).rule := rule;
    check_table(new_index).broken_rule := broken_rule;
    check_table(new_index).action := action;
    check_table(new_index).fixup_stage := fixup_stage;
    check_table(new_index).auto_fixup_available := auto_fixup_available;
    check_table(new_index).fixup_is_detectable := fixup_is_detectable;
    check_table(new_index).min_version_inclusive := min_version_inclusive;
    check_table(new_index).max_version_exclusive := max_version_exclusive;

    check_table_index_by_name(name) := new_index;
    
END define_check;










--
--    XML related stuff
--

FUNCTION gen_rdbmsup_xml RETURN VARCHAR2
IS
    result varchar2(4000);
BEGIN
    result :=  '<RDBMSUP xmlns="http://www.oracle.com/Upgrade" ' ||
                     'version="' || C_ORACLE_HIGH_VERSION_4_DOTS || '" ' ||
                     'SupportedOracleVersions="&C_UPGRADABLE_VERSIONS">' || crlf;
    IF NOT db_is_cdb THEN
        result := '<Upgrade xmlns="http://www.oracle.com/Upgrade">' || crlf || result;
    END IF;

    RETURN result;

END gen_rdbmsup_xml;

FUNCTION gen_database_xml RETURN VARCHAR2
IS
BEGIN
    -- note: boolean_string() below is case sensitive and requires lower case items to conform to xml boolean standards.
    RETURN '<Database Name="'  || db_name || '" ' ||
             'ContainerName="' || con_name || '" ' ||
             'ContainerId="' || con_id || '" ' ||
             'Version="' || db_version_4_dots || '" ' ||
             'Compatibility="' || db_compatible  || '" ' ||
             'Blocksize="' || db_block_size || '" ' ||
             'Platform="' || db_platform || '" ' ||
             'Timezone="' || to_char(db_tz_version) || '" ' ||
             'LogMode="' || db_log_mode || '" ' ||
             'Readonly="' || boolean_string(db_is_readonly, 'true', 'false') || '" ' ||
             'Edition="' || db_edition || '" ' ||
             '/>' || crlf;
END gen_database_xml;


FUNCTION gen_components_xml RETURN VARCHAR2
IS
    status_attr VARCHAR2(50);
    result VARCHAR2(4000);
BEGIN
    result := '<Components>' || crlf;

    --
    --  By convention, if the user's db is already at the version of this script,
    --  then we need to not emit the body of components so that DBUA knows nothing
    --  is going to be upgraded.
    --  Comparing only one dot deep into the version number, regardless of C_ORACLE_HIGH_VERSION_4_DOTS
    IF dbms_registry_extended.compare_versions(db_version_1_dot, C_ORACLE_HIGH_VERSION_4_DOTS, 1) <> 0 THEN
      FOR i IN 1 .. cmp_info.count LOOP
        --
        -- 1. the "STATS" (aka MISC) component is a pseudo-component.
        --    it was created for computational convenience only.  Skip it from the XML.
        -- 2. catproc is handled as special part of catalog below.
        --
        IF (cmp_info(i).processed) AND NOT
           ((cmp_info(i).cid = 'STATS') OR
            (cmp_info(i).cid = 'CATPROC')) THEN
              --
              --    Treat CATALOG and CATPROC as one combined component
              --
              IF (cmp_info(i).cid = 'CATALOG') THEN
                IF ((cmp_info(i).status = 'VALID' OR
                     cmp_info(i).status = 'UPGRADED' ) AND
                    (cmp_info(supported_component_index('CATPROC')).status = 'VALID' OR
                     cmp_info(supported_component_index('CATPROC')).status = 'UPGRADED' )) THEN
                  status_attr := cmp_info(i).status;
                ELSE
                  status_attr := 'INVALID'; 
                END IF;
                result := result ||
                  '  <Component id="Oracle Server" type="SERVER" cid="RDBMS" version="' ||
                  db_version_4_dots || '" install="' || boolean_string(cmp_info(i).install) ||
                  '" status="' || status_attr || '"/>' || crlf;
              ELSE

                IF (cmp_info(i).status IS NULL) THEN
                  -- If we get a NULL value, don't dump out the status
                  status_attr := '';
                ELSE
                  -- Create the status= entry
                  status_attr := ' status="' || cmp_info(i).status || '"';
                END IF;
                result := result || '  <Component id="'   || cmp_info(i).cname   ||
                                  '" cid="'     || cmp_info(i).cid     ||
                                  '" script="'  || cmp_info(i).script  ||
                                  '" version="' || cmp_info(i).version ||
                                  '" install="' || boolean_string(cmp_info(i).install) ||
                                  '"' || status_attr || '/>' || crlf;
              END IF;
        END IF;
      END LOOP;
    END IF;

    result := result || '</Components>' || crlf;

    RETURN result;
END gen_components_xml;


FUNCTION gen_rollback_segs_xml RETURN VARCHAR2
IS
  result VARCHAR2(4000) := '';
BEGIN
    FOR i IN 1..rs_info.count LOOP
      result := result || '  <Rollback_segment name="' || rs_info(i).seg_name ||
                                            '" tablespace="' || rs_info(i).tbs_name ||
                                            '" status="' || rs_info(i).status ||
                                            '" auto="' || rs_info(i).auto ||
                                            '" inuse="' || rs_info(i).inuse*c_kb ||
                                            '" next="' || rs_info(i).next*c_kb ||
                                            '" max_ext="' || rs_info(i).max_ext ||
                          '" />' || crlf;
    END LOOP;

    RETURN result;
END gen_rollback_segs_xml;


FUNCTION gen_flashback_info_xml RETURN VARCHAR2
IS
  min_fra_size number;  -- minimum flashback recovery area size suggested
                        -- for the upgrade
  result VARCHAR2(32767) := '';
BEGIN

  IF pDBGSizeResources THEN
    FOR i in 1..cmp_info.count LOOP
      IF cmp_info(i).processed THEN
        DisplayDiagLine ('Archivelog:   ' || rpad(cmp_info(i).cid,10) || ' ' ||
                         lpad(cmp_info(i).archivelog_kbytes,10));
        DisplayDiagLine ('Flashbacklog: ' || rpad(cmp_info(i).cid,10) || ' ' ||
                lpad(cmp_info(i).flashbacklog_kbytes,10));
      END IF;
    END LOOP;
  END IF;

  IF flashback_info.active THEN

    -- calculate min_fra_size or minimum flashback recovery area size (in Mb)
    -- note: pMinArchiveLogGen and pMinFlashbackLogGen are in Kb
    -- note: the sum of the 2 variables above is saved into min_fra_size
    -- note: so if we divide min_fra_size by c_kb, then min_fra_size is in Mb
    min_fra_size :=
      (pMinArchiveLogGen + pMinFlashbackLogGen) * c_kb;   -- 12.1 used to divide by c_kb to set units MB.

    result := result || '  <Flashback_info name="' || flashback_info.name || '" ' ||
                                          'limit="' || flashback_info.limit || '" ' ||
                                          'used="' || flashback_info.used ||  '" ' ||
                                          'size="' || flashback_info.dsize ||  '" ' ||
                                          'reclaimable="' || flashback_info.reclaimable ||  '" ' ||
                                          'files="' || flashback_info.files || '" ' ||
                                          'min_fra_size="' || min_fra_size || '" />' || crlf;
  END IF;
  RETURN result;
END gen_flashback_info_xml;


FUNCTION gen_systemresource_xml RETURN VARCHAR2
IS
  status_attr VARCHAR2(50);
  result VARCHAR2(32767);

  resourcenum    NUMBER (38);
  changes_req BOOLEAN := FALSE;
BEGIN
    result := '<SystemResource>' || crlf;

    FOR i IN 1..ts_info.count LOOP
      result := result || '  <Tablespace name="' || ts_info(i).name ||
                          '" additional_size="' || TO_CHAR(ROUND(ts_info(i).addl)) ||
                          '" min="' || to_char(ts_info(i).min) ||
                          '" alloc="' || to_char(ts_info(i).alloc) || 
                          '" inc_by="' || to_char(ts_info(i).inc_by) ||
                          '" fauto="' || boolean_string(ts_info(i).fauto) || '"/>' || crlf;
      IF pDBGSizeResources THEN
        DisplayDiagLine(RPAD(ts_info(i).name,10) ||
                          ' used =                    ' || LPAD(ts_info(i).inuse,10));
        DisplayDiagLine(RPAD(ts_info(i).name,10) ||
                         ' delta=                    ' || LPAD(ts_info(i).delta,10));
        DisplayDiagLine(RPAD(ts_info(i).name,10) ||
                         ' total req=                ' || LPAD(ts_info(i).min,10));
        DisplayDiagLine(RPAD(ts_info(i).name,10) ||
                          ' alloc=                    ' || LPAD(ts_info(i).alloc,10));
        DisplayDiagLine(RPAD(ts_info(i).name,10) ||
                          ' auto_avail=               ' || LPAD(ts_info(i).auto,10));
        DisplayDiagLine(RPAD(ts_info(i).name,10) ||
                          ' total avail=              ' ||  LPAD(ts_info(i).avail,10));
        DisplayDiagLine(RPAD(ts_info(i).name,10) ||
                          ' additional space needed = ' || LPAD(ts_info(i).addl,10));
        DisplayDiagLine(RPAD(ts_info(i).name,10) ||
                          ' increment by =            ' || LPAD(ts_info(i).inc_by,10));
        DisplayDiagLine(RPAD(ts_info(i).name,10) ||
                          ' total avail=              ' ||  LPAD(ts_info(i).avail,10));
      END IF;
    END LOOP;
    --
    -- ArchiveLogs and Flashback info
    --
    -- bug 18038240:
    -- note: pMinArchiveLogGen and pMinFlashbackLogGen are in Kb
    -- note: DBUA expects these sizes to be in Mb (not Kb)
    -- note: so if we divide these variables by c_kb, then they will be in Mb
    --
    IF db_log_mode = 'ARCHIVELOG' THEN
      resourcenum := pMinArchiveLogGen / c_kb;
    ELSE
      resourcenum := 0;
    END IF;
    result := result || '  <ArchiveLogs name="ArchiveLogs" additional_size="' ||
                                      resourcenum || '" />' || crlf;

    IF db_flashback_on THEN
      resourcenum := pMinFlashbackLogGen / c_kb;
    ELSE
      resourcenum := 0;
    END IF;

    result := result || '  <FlashbackLogs name="FlasbackLogs" additional_size="' ||
                                        resourcenum || '" />' || crlf;

    result := result || gen_rollback_segs_xml;
    result := result || gen_flashback_info_xml;

    result := result || '</SystemResource>' || crlf;

    RETURN result;
END gen_systemresource_xml;

FUNCTION gen_initparams_xml RETURN VARCHAR2
IS
    result VARCHAR2(32767);
    this_parameter_name SYS.V$PARAMETER.NAME%TYPE;
    this_parameter parameter_record_t;
    return_string VARCHAR2(4000);
BEGIN
    result := '<InitParams>' || crlf;

    result := result || ' <Update>' || crlf;


    -- do this with a few loops because of previously agreed XML format.
    this_parameter_name := all_parameters.first;
    WHILE this_parameter_name IS NOT NULL LOOP
        this_parameter := all_parameters(this_parameter_name);

        -- 
        --    Check that any minimum values for a numeric parameter are ok.
        --
        --    If the parameter is defaulted in init.ora, then no need to tell
        --    the user about it because they will just accept the new default
        --    in the new release.
        --    ^^^ Exception: For the memory parameters we size for upgrades,
        --    if that memory parameter's current defaulted value is too low
        --    for upgrade, then that parameter and minimum value will be
        --    displayed.
        --
        --    Also note, that renamed parameters have renamed_to_name set and
        --    are not part of this <Update> list.  They're handled below.
        --
        IF ( (is_size_this_memparam(this_parameter.name) = TRUE OR
              this_parameter.isdefault = 'FALSE') AND
             (this_parameter.renamed_to_name IS NULL) ) THEN
            IF this_parameter.type IN (c_param_type_number, c_param_type_number_alt) THEN
                -- a numeric parameter.  Check if its min_value
                IF to_number(this_parameter.value) < this_parameter.min_value THEN
                  result := result || '  <Parameter name="' || this_parameter.name ||
                   '" atleast="' || to_char(this_parameter.min_value) ||
                   '" type="NUMBER"/>' || crlf;
                END IF;
            END IF;
        END IF;
 
        this_parameter_name := all_parameters.next(this_parameter_name);
    END LOOP;

    --  special case "compatible"
    IF compatible_parameter_check(return_string) <> c_success THEN
      --
      -- Display the minimum compatibility (manual mode has actual check)
      --
      result := result || '  <Parameter name="compatible" atleast="' ||
                '&C_MINIMUM_COMPATIBLE' || '" type="VERSION"/>' || crlf;
    END IF;

    -- special case "pga_aggregate_limit"
    IF pga_aggregate_limit_check(return_string) <> c_success THEN
      --
      -- Display the minimum pga_aggregate_limit value 
      --
      result := result || '  <Parameter name="pga_aggregate_limit" atleast="' ||
                to_char(pga_limit_min_dbua) || '" type="NUMBER"/>' || crlf;
    END IF;

    result := result || ' </Update>' || crlf;


    -- The obsolete Migration tag used to go here

    result := result || ' <NonHandled>' || crlf;
    --  '  <Parameter name="remote_listener"/>'
    result := result || ' </NonHandled>' || crlf;


    result := result || ' <Rename>' || crlf;
    this_parameter_name := all_parameters.first;
    WHILE this_parameter_name IS NOT NULL LOOP
        this_parameter := all_parameters(this_parameter_name);

        IF (this_parameter.renamed_to_name IS NOT NULL) AND
           (this_parameter.isdefault = 'FALSE') THEN
            result := result || '  <Parameter name="' || this_parameter.name ||
                        '" newName="' || this_parameter.renamed_to_name || '"';
            IF this_parameter.new_value IS NOT NULL THEN
                result := result || ' newValue="' || this_parameter.new_value || '"';
            END IF;

            result := result || '/>' || crlf;
        END IF;
        this_parameter_name := all_parameters.next(this_parameter_name);
    END LOOP;
    result := result || ' </Rename>' || crlf;



    result := result || ' <Remove>' || crlf;

    this_parameter_name := all_parameters.first;
    WHILE this_parameter_name IS NOT NULL LOOP
        this_parameter := all_parameters(this_parameter_name);

-- Adding the OR condition manage cases when parameter was set at db startup OR parameter had been set in spfile 
        IF (this_parameter.isdefault = 'FALSE' OR this_parameter.isspecified = 'TRUE') THEN
            IF this_parameter.is_obsoleted THEN
                result := result || '  <Parameter name="' || this_parameter.name ||
                                      '" deprecated="FALSE"/>' || crlf;
            ELSIF this_parameter.is_deprecated THEN
                result := result || '  <Parameter name="' || this_parameter.name ||
                                      '" deprecated="TRUE"/>' || crlf;
            END IF;
        END IF;

        this_parameter_name := all_parameters.next(this_parameter_name);
    END LOOP; 

    result := result || ' </Remove>' || crlf ||
                        '</InitParams>' || crlf;
    RETURN result;
END gen_initparams_xml;

-- @@generateXML


--
--    Attribute must match CASE of attr_name and be immediately followed by '='
--
FUNCTION get_xml_attribute(xml IN CLOB,
                           attr_name IN VARCHAR2,
                           default_value IN VARCHAR2,
                           start_index IN NUMBER) RETURN VARCHAR2
IS
    attr_start_index NUMBER;
    attr_end_index NUMBER;
    end_element_start_index NUMBER;
BEGIN
    end_element_start_index := instr(xml, '>', start_index);

    attr_start_index := instr(xml, attr_name||'=', start_index);

    IF (attr_start_index = 0) OR (attr_start_index > end_element_start_index) THEN
        RETURN default_value;
    END IF;

    attr_start_index := instr(xml, '"', attr_start_index)+1;
    attr_end_index := instr(xml, '"', attr_start_index);

    IF debug THEN
        dbms_output.put_line('in get_xml_attribute, attr_start_index=' || attr_start_index || ' attr_end_index=' || attr_end_index);
        dbms_output.put_line('in get_xml_attribute, returning ' || attr_name || '=' ||
            substr(xml, attr_start_index, attr_end_index-attr_start_index));
    END IF;

    RETURN substr(xml, attr_start_index, attr_end_index-attr_start_index);
END get_xml_attribute;

FUNCTION get_xml_element_body(xml IN CLOB,
                      start_index IN NUMBER,
                      end_index IN NUMBER) RETURN CLOB
IS
    body_start_index NUMBER;
    body_end_index NUMBER;
    result CLOB;
BEGIN
    body_start_index := instr(xml, '>', start_index) + 1;
    body_end_index := instr(xml, '<', body_start_index);

    IF debug THEN
        dbms_output.put_line('In get_xml_element_body, the whole element is ''' ||
            substr(xml, start_index, end_index - start_index + 1) || '''');
        dbms_output.put_line('In get_xml_element_body, returning ''' ||
            substr(xml, body_start_index, body_end_index - body_start_index) || '''');
    END IF;


        --
        --    Escape any special characters to be emitted in the XML content, otherwise the XML processing may get sick.
        --    Make sure to perform substitutions in this order, and reverse the order when reading XML back in.
        --

        result := substr(xml, body_start_index, body_end_index - body_start_index);
        result := replace(result, '&' || 'gt;',   '>');
        result := replace(result, '&' || 'lt;',   '<');
        result := replace(result, '&' || 'apos;', '''');
        result := replace(result, '&' || 'quot;', '"');
        result := replace(result, '&' || 'amp;',  '&');

    return result;
END get_xml_element_body;

--
--    returns the name of the next XML element in the xml stream
--    sets the end_of_element_index to the last character thats
--    part of that element.
--    NOTE: This function relies on the CASE of the closing tag
--    matching the case of the opening tag.
--    IF no next element is found, or the XML is not well formed,
--    the function returns NULL and sets end_of_element_index to
--    end_index.
--
FUNCTION identify_next_element(xml IN CLOB,
                               start_index IN NUMBER,
                               end_index IN NUMBER,
                               start_of_element_index OUT NUMBER,
                               end_of_element_index OUT NUMBER) RETURN VARCHAR2
IS
    element_name VARCHAR2(100) := null;
    space_index NUMBER;
    end_opening_tag_index NUMBER;
    end_element_name_index NUMBER;
BEGIN
    IF debug THEN
        dbms_output.put_line('In identify_next_element, start_index=' ||
           to_char(start_index) || ' end_index=' || to_char(end_index));
    END IF;

    start_of_element_index := instr(xml,'<', start_index);
    IF (start_of_element_index = 0) THEN
        start_of_element_index := start_index;   -- if we don't find one, set to "default" start_index
        end_of_element_index := end_index;
        RETURN null;
    END IF;

    end_opening_tag_index := instr(xml, '>', start_of_element_index);
    IF (end_opening_tag_index = 0) THEN
        start_of_element_index := start_index;
        end_of_element_index := end_index;
        RETURN null;
    END IF;

    space_index := instr(xml, ' ', start_of_element_index);
    IF (space_index = 0) THEN
        end_element_name_index := end_opening_tag_index;
    ELSE
        IF (space_index < end_opening_tag_index) THEN
            end_element_name_index := space_index;
        ELSE
            end_element_name_index := end_opening_tag_index;
        END IF;
    END IF;
        
    element_name := substr(xml, start_of_element_index+1,
                                end_element_name_index-start_of_element_index-1);

    IF (substr(xml,end_opening_tag_index-1,1) = '/') THEN
        end_of_element_index := end_opening_tag_index;
    ELSE
        end_of_element_index := instr(xml, '</' || element_name || '>',
                                end_opening_tag_index+1);
        IF (end_of_element_index = 0) THEN
            start_of_element_index := start_index;
            end_of_element_index := end_index;
            RETURN null;
        ELSE
            end_of_element_index := end_of_element_index + length(element_name) + 2;  -- skip "</"
        END IF;
    END IF;

    IF debug THEN
        dbms_output.put_line('  in identify_next_element, returning ''' ||
            element_name || ''' with start_of_element_index=' ||
            to_char(start_of_element_index) ||
            ' and end_of_element_index=' || to_char(end_of_element_index));
    END IF;

    return element_name;
END identify_next_element;



FUNCTION parse_detail_xml(xml IN CLOB,
                          start_index IN NUMBER,
                          end_index IN NUMBER) RETURN detail_t
IS
    result detail_t;
BEGIN
    result.detail_type := get_xml_attribute(xml, 'TYPE', '', start_index);
    result.detail := get_xml_element_body(xml, start_index, end_index);
    return result;
END parse_detail_xml;

FUNCTION parse_fixup_xml(xml IN CLOB,
                          start_index IN NUMBER,
                          end_index IN NUMBER) RETURN fixup_t
IS
    result fixup_t;
BEGIN
    result.fixup_type := get_xml_attribute(xml, 'Type', '', start_index);
    result.fixAtStage := get_xml_attribute(xml, 'FixAtStage', '', start_index);
    RETURN result;
END parse_fixup_xml;

FUNCTION parse_messagevalue_xml(xml IN CLOB,
                               start_index IN NUMBER,
                               end_index IN NUMBER) RETURN messagevalue_t
IS
    result messagevalue_t;
BEGIN
    --
    --    Get the message ID
    --
    result.position := get_xml_attribute(xml, 'Position', 'INVALID_XML', start_index);
    result.value := get_xml_element_body(xml, start_index, end_index);

    RETURN result;
END parse_messagevalue_xml;

FUNCTION parse_message_xml(xml IN CLOB,
                               start_index IN NUMBER,
                               end_index IN NUMBER) RETURN message_t
IS
    result                        message_t;
    next_contained_element        VARCHAR2(100);
    start_of_element_index        NUMBER;
    end_of_element_index          NUMBER;
BEGIN
    --
    --    Get the message ID
    --
    result.id := get_xml_attribute(xml, 'ID', 'INVALID_XML', start_index);


    --
    --    Now parse the text inside the MESSAGE element
    --
    next_contained_element := identify_next_element(xml,
                                  start_index + 1, end_index,
                                  start_of_element_index, end_of_element_index);

    WHILE (next_contained_element IS NOT NULL) LOOP
        next_contained_element := upper(next_contained_element);
        CASE
            WHEN next_contained_element = 'MESSAGEVALUE' THEN
                result.messagevalues(result.messagevalues.count+1) :=
                    parse_messagevalue_xml(xml, start_of_element_index, end_of_element_index);
            ELSE
                IF debug THEN
                    dbms_output.put_line('ERROR in parse_message_xml, invalid next_contained_element=' || next_contained_element);
                END IF;

                RETURN null;
        END CASE;
        next_contained_element := identify_next_element(xml,
                                      end_of_element_index + 1, end_index,
                                      start_of_element_index, end_of_element_index);
    END LOOP;

    RETURN result;

END parse_message_xml;

FUNCTION message_t_to_text(message message_t) RETURN CLOB
IS
    result CLOB;
    this_messagevalue messagevalue_t;
    standard_replacement_count NUMBER; -- number of replacements that precede any <Tableout if present.

    tableout_index NUMBER;             -- Index of "<Tableout" in message, 0 if not present
    tableout_suffix VARCHAR2(4000);    -- Message text that appears AFTER a <Tableout> tag.
    start_index NUMBER;                -- Index of "startParam=" clause in message containing <Tableout
    columns_index NUMBER;              -- Index of "columns=" clause in message containing <Tableout
    end_columns_index NUMBER;          -- Ending index of the columns= clause, if present
    starting_parameter_number NUMBER;  -- Value of the "<Tableout startParam=" clause
    column_size_array number_array_t;  -- Array of column widths - built for call to column_format()
    total_columns NUMBER := 0;
    columns_string VARCHAR2(200);      -- Value of "<Tableout columns=" clause
    column_width_string VARCHAR2(20);  -- String holding parsed value of a single column width from "<Tableout columns="
    column_width NUMBER;               -- numeric value of column_width_string
    rows PLS_INTEGER;                  -- count of rows that will appear in table.  No decimals
    real_cols_per_row PLS_INTEGER;     -- since each column value is padded with a virtual column of spaces, its 2 cols to a "real" col.  No decimals.
    row NUMBER;
    col NUMBER;
    i NUMBER;
BEGIN
    --
    --    lookup the message.id in the properties file to get its message text.
    --
    BEGIN
        result := properties(message.id);
    EXCEPTION WHEN OTHERS THEN
        internal_error('in message_t_to_text, no text available for message.id=' || message.id);
    END;


    standard_replacement_count := message.messagevalues.count;

    --
    --    See if there are any <Tableout> tags in the message and if so, prepare for them.
    --
    tableout_index := instr(result, '<Tableout', 1, 1);
    IF tableout_index > 0 THEN
        start_index := instr(result, 'startParam=', tableout_index, 1);
        columns_index := instr(result, 'columns=', start_index, 1);
        end_columns_index := instr(result, '>', columns_index, 1);

        IF debug THEN
            dbms_output.put_line(' ');
            dbms_output.put_line(message.id);
            dbms_output.put_line('start_index=' || to_char(start_index));
            dbms_output.put_line('columns_index=' || to_char(columns_index));
            dbms_output.put_line('end_columns_index=' || to_char(end_columns_index));
        END IF;

        IF (start_index = 0) or
           (columns_index = 0) or 
           (end_columns_index = 0) THEN
            internal_error('Invalid <Tableout> tag in preupgrade_messages.properties processing ' || message.id);
        END IF;

        BEGIN
            starting_parameter_number := to_number(substr(result,start_index+11,columns_index-start_index-11));
            standard_replacement_count := starting_parameter_number - 1;

            columns_string := substr(result, columns_index+8, end_columns_index-columns_index-8);
            
            column_width_string := dbms_registry_extended.element(columns_string, ',', total_columns + 1);
            column_size_array := new number_array_t();
            WHILE (column_width_string <> ',') LOOP
                column_width := to_number(column_width_string);

                column_size_array.extend();
                total_columns := total_columns + 1;
                column_size_array(total_columns) := column_width;

                column_width_string := dbms_registry_extended.element(columns_string, ',', total_columns + 1);
            END LOOP;

        EXCEPTION WHEN OTHERS THEN
            internal_error('in message_t_to_text, could not parse Tableout string in message.id=' || message.id);
        END;
    END IF;

    IF debug THEN
        dbms_output.put_line('in message_t_to_text, ' ||
            'total replacements=' || to_char(message.messagevalues.count));
    END IF;

    --
    --    Now loop through the messagevalues and perform replacements
    --    Note that this process may invalidate tableout_index, start_index,
    --    columns_index, and end_columns_index but they will be recomputed later.
    --
    FOR replacement IN 1 .. standard_replacement_count LOOP
       this_messagevalue := message.messagevalues(replacement);
       IF debug THEN
           dbms_output.put_line('in message_t_to_text, ' ||
               'this_messagevalue.position=' ||
               to_char(this_messagevalue.position) ||
               ' this_messagevalue.value=' || this_messagevalue.value);
        END IF;

       -- note that the messagevalues may not be in order,
       -- so cannot assume 'replacement = this_messagevalue.position'
       result := replace(result, make_msg_param(this_messagevalue.position),
                                 this_messagevalue.value); 
    END LOOP;     

    --
    --    Perform Tableout replacements
    --
    IF (tableout_index > 0) THEN
        --
        --    REcompute the indexes of the pieces of the <Tableout> tag.
        --    the indexes could have been altered by the standard substitution process.
        --
        tableout_index := instr(result, '<Tableout', 1, 1);
        start_index := instr(result, 'startParam=', tableout_index, 1);
        columns_index := instr(result, 'columns=', start_index, 1);
        end_columns_index := instr(result, '>', columns_index, 1);

        -- chop off the <Tableout ...> content from result temporarily to make subsequent string operations easy
        tableout_suffix := substr(result, end_columns_index + 1);
        result := substr(result,1,tableout_index - 1);

        real_cols_per_row := column_size_array.count() / 2;
        rows := (message.messagevalues.count - standard_replacement_count) / real_cols_per_row;

        IF (standard_replacement_count + rows * real_cols_per_row != message.messagevalues.count) THEN
            IF debug THEN
                FOR i in 1..message.messagevalues.count LOOP
                    dbms_output.put_line(message.messagevalues(i).value);
                END LOOP;
            END IF;
            internal_error('called message_t_to_text() for message ' || message.id ||
             ' with invalid parameter count.' || crlf ||
             ' processing <Tableout ' || crlf ||
             ' messagevalues.count=' || to_char(message.messagevalues.count) || crlf ||
             ' expecting ' || to_char(standard_replacement_count + rows * real_cols_per_row) || crlf ||
             ' standard_replacement_count=' || to_char(standard_replacement_count) || crlf ||
             ' rows=' || to_char(rows) || crlf ||
             ' real_cols_per_row=' || to_char(real_cols_per_row));
        END IF;

        FOR row IN 1..rows LOOP
            DECLARE
                -- declare here to ensure it starts clean for every row
                column_format_array string_array_t := string_array_t();
            BEGIN
                FOR col IN 1..real_cols_per_row LOOP
                    column_format_array.extend(2);
                    column_format_array(col * 2 - 1) := ' ';
                    column_format_array(col * 2    ) := message.messagevalues(standard_replacement_count + (row-1)*real_cols_per_row + col).value;

                END LOOP;

                IF (row > 1) THEN
                    -- need crlf before all table output except the first line.
                    result := result || crlf;
                END IF;

                result := result || column_format(column_size_array, column_format_array);
            END;
        END LOOP;

        -- put back any suffix that was temporarily removed
        result := result || tableout_suffix;
    END IF;

    --
    --  Perform the allowable html-like replacements of "<br>"
    --
    result := replace(result, '<br>', crlf);

    RETURN result;
END message_t_to_text;


FUNCTION parse_rdbmsup_xml(xml IN CLOB,
                                  start_index IN NUMBER,
                                  end_index IN NUMBER) RETURN rdbmsup_t
IS
    result rdbmsup_t;
BEGIN
    result.xmlns := get_xml_attribute(xml, 'xmlns', '', start_index);
    result.version := get_xml_attribute(xml, 'version', '', start_index);
    result.upgradable_versions := get_xml_attribute(xml, 'SupportedOracleVersions', '', start_index);

    RETURN result;
END parse_rdbmsup_xml;


FUNCTION parse_database_xml(xml IN CLOB,
                                   start_index IN NUMBER,
                                   end_index IN NUMBER) RETURN database_t
IS
    result database_t;
BEGIN
    result.name := get_xml_attribute(xml, 'Name', '', start_index);
    result.containerName := get_xml_attribute(xml, 'ContainerName', '', start_index);
    result.containerId := get_xml_attribute(xml, 'ContainerId', '', start_index);
    result.version := get_xml_attribute(xml, 'Version', '', start_index);
    result.compatibility := get_xml_attribute(xml, 'Compatibility', '', start_index);
    result.blocksize := get_xml_attribute(xml, 'Blocksize', '', start_index);
    result.platform := get_xml_attribute(xml, 'Platform', '', start_index);
    result.timezoneVer := get_xml_attribute(xml, 'Timezone', '', start_index);
    result.log_mode := get_xml_attribute(xml, 'LogMode', '', start_index);
    result.readonly := (lower(get_xml_attribute(xml, 'Readonly', 'false', start_index)) = 'true');  -- case sensitive
    result.edition_val := get_xml_attribute(xml, 'Edition', '', start_index);

    RETURN result;
END parse_database_xml;

FUNCTION parse_component_xml(xml IN CLOB,
                                   start_index IN NUMBER,
                                   end_index IN NUMBER) RETURN component_t
IS
    result component_t;
BEGIN
    result.cname := get_xml_attribute(xml, 'id', '', start_index);
    result.cid := get_xml_attribute(xml, 'cid', '', start_index);
    result.script := get_xml_attribute(xml, 'script', '', start_index);
    result.version := get_xml_attribute(xml, 'version', '', start_index);
    result.status := get_xml_attribute(xml, 'status', '', start_index);

    RETURN result;
END parse_component_xml;

FUNCTION parse_components_xml(xml IN CLOB,
                                   start_index IN NUMBER,
                                   end_index IN NUMBER) RETURN components_t
IS
    result components_t;
    next_contained_element VARCHAR2(100);
    start_of_element_index NUMBER;
    end_of_element_index NUMBER;
    msg_start_index NUMBER;
    msg_end_index NUMBER;
BEGIN
    --
    --    Initialize result fields.
    --
    next_contained_element := identify_next_element(xml, start_index + 1, end_index,
                                  start_of_element_index, end_of_element_index);
    WHILE (next_contained_element IS NOT NULL) LOOP
        next_contained_element := upper(next_contained_element);
        CASE
            WHEN next_contained_element = 'COMPONENT' THEN
                result(result.count+1) := parse_component_xml(xml, start_of_element_index, end_of_element_index);
            ELSE
                internal_error('invalid internal XML.  Found unexpected element "' || next_contained_element ||
                               '" while parsing <Components>.' ||
                               ' Rerun preupgrade but generate XML output instead of' ||
                               ' text to identify problem for Oracle Support.');
        END CASE;

        next_contained_element := identify_next_element(xml, end_of_element_index+1, end_index, start_of_element_index, end_of_element_index);
    END LOOP;

    RETURN result;
END parse_components_xml;

FUNCTION parse_tablespace_xml(xml IN CLOB,
                              start_index IN NUMBER,
                              end_index IN NUMBER) RETURN tablespace_t
IS
    result tablespace_t;
BEGIN
    result.name := get_xml_attribute(xml, 'name', '', start_index);
    result.additional_size := to_number(get_xml_attribute(xml, 'additional_size', '0', start_index));
    result.min := to_number(get_xml_attribute(xml, 'min', '0', start_index));
    result.alloc := to_number(get_xml_attribute(xml, 'alloc', '0', start_index));
    result.inc_by := to_number(get_xml_attribute(xml, 'inc_by', '0', start_index));
    result.fauto := (upper(get_xml_attribute(xml, 'fauto', 'FALSE', start_index)) = 'TRUE');
    result.contents := get_xml_attribute(xml, 'contents', '', start_index);

    RETURN result;
END parse_tablespace_xml;


FUNCTION parse_archivelogs_xml(xml IN CLOB,
                               start_index IN NUMBER,
                               end_index IN NUMBER) RETURN archivelogs_t
IS
    result archivelogs_t;
BEGIN
    result.name := get_xml_attribute(xml, 'name', '', start_index);
    result.additional_size := to_number(get_xml_attribute(xml, 'additional_size', '0', start_index));

    RETURN result;
END parse_archivelogs_xml;

FUNCTION parse_flashbacklogs_xml(xml IN CLOB,
                                 start_index IN NUMBER,
                                 end_index IN NUMBER) RETURN flashbacklogs_t
IS
    result flashbacklogs_t;
BEGIN
    result.name := get_xml_attribute(xml, 'name', '', start_index);
    result.additional_size := to_number(get_xml_attribute(xml, 'additional_size', '0', start_index));

    RETURN result;
END parse_flashbacklogs_xml;

FUNCTION parse_rollback_segment_xml(xml IN CLOB,
                                 start_index IN NUMBER,
                                 end_index IN NUMBER) RETURN rollback_segment_t
IS
    result rollback_segment_t;
BEGIN
    result.name := get_xml_attribute(xml, 'name', '', start_index);
    result.tablespc := get_xml_attribute(xml, 'tablespace', '', start_index);
    result.status := get_xml_attribute(xml, 'status', '', start_index);
    result.auto := to_number(get_xml_attribute(xml, 'auto', '0', start_index));
    result.inuse := to_number(get_xml_attribute(xml, 'inuse', '0', start_index));
    result.next := to_number(get_xml_attribute(xml, 'next', '0', start_index));
    result.max_ext := to_number(get_xml_attribute(xml, 'max_ext', '0', start_index));

    RETURN result;
END parse_rollback_segment_xml;

FUNCTION parse_flashback_info_xml(xml IN CLOB,
                                 start_index IN NUMBER,
                                 end_index IN NUMBER) RETURN flashback_info_t
IS
    result flashback_info_t;
BEGIN
    result.name := get_xml_attribute(xml, 'name', '', start_index);
    result.limit := get_xml_attribute(xml, 'limit', '', start_index);
    result.used := get_xml_attribute(xml, 'used', '', start_index);
    result.dsize := get_xml_attribute(xml, 'size', '', start_index);
    result.reclaimable := get_xml_attribute(xml, 'reclaimable', '', start_index);
    result.files := get_xml_attribute(xml, 'files', '', start_index);
    result.min_fra_size := get_xml_attribute(xml, 'min_fra_size', '', start_index);

    RETURN result;
END parse_flashback_info_xml;


FUNCTION parse_systemresource_xml(xml IN CLOB,
                                  start_index IN NUMBER,
                                  end_index IN NUMBER) RETURN systemresource_t
IS
    result systemresource_t;
    next_contained_element VARCHAR2(100);
    start_of_element_index NUMBER;
    end_of_element_index NUMBER;
    msg_start_index NUMBER;
    msg_end_index NUMBER;
BEGIN
    --
    --    Initialize result fields.
    --
    next_contained_element := identify_next_element(xml, start_index + 1, end_index,
                                  start_of_element_index, end_of_element_index);
    WHILE (next_contained_element IS NOT NULL) LOOP
        next_contained_element := upper(next_contained_element);
        CASE
            WHEN next_contained_element = 'TABLESPACE' THEN
                result.tablespaces(result.tablespaces.count+1) := parse_tablespace_xml(xml, start_of_element_index, end_of_element_index);
            WHEN next_contained_element = 'ARCHIVELOGS' THEN
                result.archivelogs := parse_archivelogs_xml(xml, start_of_element_index, end_of_element_index);
            WHEN next_contained_element = 'FLASHBACKLOGS' THEN
                result.flashbacklogs := parse_flashbacklogs_xml(xml, start_of_element_index, end_of_element_index);
            WHEN next_contained_element = 'ROLLBACK_SEGMENT' THEN
                result.rollback_segments(result.rollback_segments.count+1) :=
                    parse_rollback_segment_xml(xml, start_of_element_index, end_of_element_index);
            WHEN next_contained_element = 'FLASHBACK_INFO' THEN
                result.flashback_info :=
                    parse_flashback_info_xml(xml, start_of_element_index, end_of_element_index);
            ELSE
                internal_error('invalid internal XML.  Found unexpected element "' || next_contained_element ||
                               '" while parsing <SystemResource>.' ||
                               ' Rerun preupgrade but generate XML output instead of' ||
                               ' text to identify problem for Oracle Support.');
        END CASE;

        next_contained_element := identify_next_element(xml, end_of_element_index+1, end_index, start_of_element_index, end_of_element_index);
    END LOOP;

    RETURN result;
END parse_systemresource_xml;

-- @@parse
FUNCTION parse_parameter_xml(xml IN CLOB,
                                 start_index IN NUMBER,
                                 end_index IN NUMBER) RETURN parameter_xml_record_t
IS
    result parameter_xml_record_t;
    stringType VARCHAR2(50);
    deprecated VARCHAR2(30);
BEGIN
    result.name := get_xml_attribute(xml, 'name', '', start_index);
    -- result.min_value := to_number(get_xml_attribute(xml, 'atleast', '0', start_index));
    result.isdefault := get_xml_attribute(xml, 'isdefault', '', start_index);
    result.renamed_to_name := get_xml_attribute(xml, 'newName', '', start_index);
    result.new_value := get_xml_attribute(xml, 'newValue', '', start_index);
    result.value := get_xml_attribute(xml, 'oldValue', '', start_index);
    result.min_char_value := null;  -- default.  set below as needed.

    stringType := get_xml_attribute(xml, 'type', '', start_index);
    IF stringType = 'NUMBER' THEN
        result.type := c_param_type_number;
        result.new_value := '';   -- does not apply to NUMBERs this is for a STRING
        result.min_value := to_number(get_xml_attribute(xml, 'atleast', '0', start_index));
    ELSIF stringType = 'STRING' THEN
        result.type := c_param_type_string;
        result.new_value := get_xml_attribute(xml, 'newValue', '', start_index);
    ELSIF stringType = 'VERSION' THEN
        -- this stringType is used for the setting of COMPATIBLE since its value isnt really a number.
        result.type := c_param_type_version;
        result.new_value := get_xml_attribute(xml, 'atleast', '', start_index);
        result.min_char_value := get_xml_attribute(xml, 'atleast', '0', start_index);
    ELSE
        result.type := c_param_type_other;    -- stringType is null or unknown.
        result.new_value := get_xml_attribute(xml, 'newValue', '', start_index);
    END IF;

    deprecated := get_xml_attribute(xml, 'deprecated', '', start_index);
    IF (deprecated = 'TRUE') THEN
        result.is_deprecated := TRUE;
        result.is_obsoleted := FALSE;
    ELSIF (deprecated = 'FALSE') THEN
        result.is_obsoleted := TRUE;
        result.is_deprecated := FALSE;
    ELSE
        result.is_obsoleted := FALSE;
        result.is_deprecated := FALSE;
    END IF;

    RETURN result;
END parse_parameter_xml;

FUNCTION parse_parameters_xml(xml IN CLOB,
                                   start_index IN NUMBER,
                                   end_index IN NUMBER) RETURN parameters_t
IS
    result parameters_t;
    next_contained_element VARCHAR2(100);
    start_of_element_index NUMBER;
    end_of_element_index NUMBER;
    msg_start_index NUMBER;
    msg_end_index NUMBER;
BEGIN
    --
    --    Initialize result fields.
    --
    next_contained_element := identify_next_element(xml, start_index + 1, end_index,
                                  start_of_element_index, end_of_element_index);
    WHILE (next_contained_element IS NOT NULL) LOOP
        next_contained_element := upper(next_contained_element);
        CASE
            WHEN next_contained_element = 'PARAMETER' THEN
                result(result.count+1) :=
                    parse_parameter_xml(xml, start_of_element_index, end_of_element_index);
            ELSE
                internal_error('invalid internal XML.  Found unexpected element "' || next_contained_element ||
                               '" while expecting <Parameter>.' ||
                               ' Rerun preupgrade but generate XML output instead of' ||
                               ' text to identify problem for Oracle Support.');
        END CASE;

        next_contained_element := identify_next_element(xml, end_of_element_index+1, end_index, start_of_element_index, end_of_element_index);
    END LOOP;

    RETURN result;
END parse_parameters_xml;


FUNCTION parse_initparams_xml(xml IN CLOB,
                                   start_index IN NUMBER,
                                   end_index IN NUMBER) RETURN initparams_t
IS
    result initparams_t;
    next_contained_element VARCHAR2(100);
    start_of_element_index NUMBER;
    end_of_element_index NUMBER;
    msg_start_index NUMBER;
    msg_end_index NUMBER;
BEGIN
    --
    --    Initialize result fields.
    --
    next_contained_element := identify_next_element(xml, start_index + 1, end_index,
                                  start_of_element_index, end_of_element_index);
    WHILE (next_contained_element IS NOT NULL) LOOP
        next_contained_element := upper(next_contained_element);
        CASE
            WHEN next_contained_element = 'UPDATE' THEN
                result.update_params :=
                    parse_parameters_xml(xml, start_of_element_index, end_of_element_index);
            WHEN next_contained_element = 'NONHANDLED' THEN
                result.nonhandled_params :=
                    parse_parameters_xml(xml, start_of_element_index, end_of_element_index);
            WHEN next_contained_element = 'RENAME' THEN
                result.rename_params :=
                    parse_parameters_xml(xml, start_of_element_index, end_of_element_index);
            WHEN next_contained_element = 'REMOVE' THEN
                result.remove_params :=
                    parse_parameters_xml(xml, start_of_element_index, end_of_element_index);
            ELSE
                internal_error('invalid internal XML.  Found unexpected element "' || next_contained_element ||
                               '" while parsing <InitParams>.' ||
                               ' Rerun preupgrade but generate XML output instead of' ||
                               ' text to identify problem for Oracle Support.');
        END CASE;

        next_contained_element := identify_next_element(xml, end_of_element_index+1, end_index, start_of_element_index, end_of_element_index);
    END LOOP;

    RETURN result;
END parse_initparams_xml;

FUNCTION parse_preupgradecheck_xml(xml IN CLOB,
                                   start_index IN NUMBER,
                                   end_index IN NUMBER) RETURN preupgradecheck_t
IS
    result preupgradecheck_t;
    next_contained_element VARCHAR2(100);
    start_of_element_index NUMBER;
    end_of_element_index NUMBER;
    msg_start_index NUMBER;
    msg_end_index NUMBER;
    default_status_value VARCHAR2(20);
    status_xml_attribute_value VARCHAR2(100);
BEGIN
    default_status_value := check_level_strings(c_check_level_success);
    status_xml_attribute_value := get_xml_attribute(xml, 'Status', default_status_value, start_index);

    IF debug THEN
        IF (xml IS NULL) THEN
            dbms_output.put_line('In parse_preupgradecheck_xml, XML is NULL');
        END IF;
        dbms_output.put_line('Leading  characters in XML are: ' || substr(xml, start_index-20, 20));
        dbms_output.put_line('Trailing characters in XML are: ' || substr(xml, start_index, 20));
        dbms_output.put_line('default_status_value=' || default_status_value);
        dbms_output.put_line('status_xml_attribute_value=' || status_xml_attribute_value);
        dbms_output.put_line('In parse_preupgradecheck_xml.  Displaying XML text for parsing. start_index=' || start_index ||
                             ' end_index=' || end_index ||
                             ' Length of the whole XML is ' || length(xml));
        dbms_output.put_line(substr(xml,start_index, end_index));
    END IF;


    --
    --    Initialize result fields.
    --
    result.id := get_xml_attribute(xml, 'ID', '', start_index);

    result.severity := check_level_ints(status_xml_attribute_value);
    result.rule := null;
    result.broken_rule := null;
    result.action := null;
    result.fixup := null;

    --
    --    Now parse the text inside the PREUPGRADECHECK element.
    --
    next_contained_element := identify_next_element(xml,
                                  start_index + 1, end_index,
                                  start_of_element_index, end_of_element_index);
    WHILE (next_contained_element IS NOT NULL) LOOP
        next_contained_element := upper(next_contained_element);
        CASE

            WHEN next_contained_element = 'RULE' THEN
                next_contained_element := identify_next_element(xml, start_of_element_index+1,
                                          end_of_element_index, msg_start_index, msg_end_index);
                IF (upper(next_contained_element) = 'MESSAGE') THEN
                    result.rule := parse_message_xml(xml, msg_start_index, msg_end_index);
                ELSE
                    result.rule := invalid_xml_message;
                END IF;

            WHEN next_contained_element = 'BROKEN_RULE' THEN
                next_contained_element := identify_next_element(xml, start_of_element_index+1,
                                          end_of_element_index, msg_start_index, msg_end_index);
                IF (upper(next_contained_element) = 'MESSAGE') THEN
                    result.broken_rule := parse_message_xml(xml, msg_start_index, msg_end_index);
                ELSE
                    result.broken_rule := invalid_xml_message;
                END IF;

            WHEN next_contained_element = 'ACTION' THEN
                next_contained_element := identify_next_element(xml, start_of_element_index+1,
                                          end_of_element_index, msg_start_index, msg_end_index);
                IF (upper(next_contained_element) = 'MESSAGE') THEN
                    result.action := parse_message_xml(xml, msg_start_index, msg_end_index);
                ELSE
                    result.action := invalid_xml_message;
                END IF;

            WHEN next_contained_element = 'DETAIL' THEN
                result.detail := parse_detail_xml(xml, start_of_element_index, end_of_element_index);

            WHEN next_contained_element = 'FIXUP' THEN
                result.fixup := parse_fixup_xml(xml, start_of_element_index, end_of_element_index);

            ELSE
                internal_error('invalid internal XML.  Found unexpected element "' || next_contained_element ||
                               '" while parsing <Preupgradecheck>.' ||
                               ' Rerun preupgrade but generate XML output instead of' ||
                               ' text to identify problem for Oracle Support.');
        END CASE;
        next_contained_element := identify_next_element(xml,
                                      end_of_element_index + 1, end_index,
                                      start_of_element_index, end_of_element_index);
    END LOOP;

    RETURN result;
END parse_preupgradecheck_xml;



FUNCTION parse_preupgradechecks_xml(xml IN CLOB,
                                   start_index IN NUMBER,
                                   end_index IN NUMBER) RETURN preupgradechecks_t
IS
    result preupgradechecks_t;
    next_contained_element VARCHAR2(100);
    start_of_element_index NUMBER;
    end_of_element_index NUMBER;
    msg_start_index NUMBER;
    msg_end_index NUMBER;
BEGIN
    --
    --    Now parse the text inside the PREUPGRADECHECK element.
    --
    next_contained_element := identify_next_element(xml,
                                  start_index + 1, end_index,
                                  start_of_element_index, end_of_element_index);
    WHILE (next_contained_element IS NOT NULL) LOOP
        next_contained_element := upper(next_contained_element);

        IF debug THEN
            dbms_output.put_line('In parse_preupgradechecks.  Got element ' || next_contained_element);
        END IF;

        CASE

            WHEN next_contained_element = 'PREUPGRADECHECK' THEN
--                next_contained_element := identify_next_element(xml, start_of_element_index+1,
--                                          end_of_element_index, msg_start_index, msg_end_index);
--                result(result.count+1) := parse_preupgradecheck_xml(xml, msg_start_index, msg_end_index);
                result(result.count+1) := parse_preupgradecheck_xml(xml, start_of_element_index, end_of_element_index);
            ELSE
                internal_error('invalid internal XML.  Found unexpected element "' || next_contained_element ||
                               '" while parsing <Preupgradechecks>.' ||
                               ' Rerun preupgrade but generate XML output instead of' ||
                               ' text to identify problem for Oracle Support.');
        END CASE;
        next_contained_element := identify_next_element(xml,
                                      end_of_element_index + 1, end_index,
                                      start_of_element_index, end_of_element_index);
    END LOOP;

    RETURN result;
END parse_preupgradechecks_xml;


FUNCTION rdbmsup_t_to_text(rdbmsup rdbmsup_t) RETURN VARCHAR2
IS
    now VARCHAR2(60);
BEGIN
    -- do not print out xmlns or upgradable_versions
    EXECUTE IMMEDIATE 'select to_char(sysdate, ''YYYY-MM-DD"T"HH24:MI:SS'') from dual'
        INTO now;
    -- use locale default format - no, java defaults differ from plsql.
    -- EXECUTE IMMEDIATE 'select to_char(to_timestamp(sysdate)) from dual' INTO now;
    RETURN 'Report generated by Oracle Database Pre-Upgrade Information Tool Version ' ||
           rdbmsup.version || ' on ' || now || crlf ||
           crlf ||
           'Upgrade-To version: ' || rdbmsup.version || crlf ||
           crlf ||
           '=======================================' || crlf ||
           'Status of the database prior to upgrade' || crlf ||
           '=======================================' || crlf;
END rdbmsup_t_to_text;

FUNCTION database_t_to_text(my_database database_t) RETURN VARCHAR2
IS
    containerNameString VARCHAR2(200);
    containerIdString VARCHAR2(200);
BEGIN
    IF dbms_registry_extended.compare_versions(db_version_4_dots, '12.1.0.1.0', 4) = -1 THEN
        containerNameString := C_MSG_NA_B4_121;
        containerIdString := C_MSG_NA_B4_121;
    ELSE
        containerNameString := my_database.containerName;
        containerIdString := my_database.containerId;
    END IF;

    RETURN '      Database Name:  ' || my_database.name || crlf ||
           '     Container Name:  ' || containerNameString || crlf ||
           '       Container ID:  ' || containerIdString || crlf ||
           '            Version:  ' || my_database.version || crlf ||
           '         Compatible:  ' || my_database.compatibility || crlf ||
           '          Blocksize:  ' || my_database.blocksize || crlf ||
           '           Platform:  ' || my_database.platform || crlf ||
           '      Timezone File:  ' || my_database.timezoneVer || crlf ||
           '  Database log mode:  ' || my_database.log_mode || crlf ||
           '           Readonly:  ' || boolean_string(my_database.readonly) || crlf ||
           '            Edition:  ' || db_edition || crlf || crlf;
END database_t_to_text;

FUNCTION preupgradecheck_t_to_text(preupgradecheck preupgradecheck_t) RETURN CLOB
IS
    auto_fixup_text VARCHAR2(100);
    result CLOB;
    indent_width NUMBER := 6;
BEGIN
    IF debug THEN
        dbms_output.put_line('preupgradecheck.id=' || preupgradecheck.id);
        dbms_output.put_line('preupgradecheck.fixup.fixup_type=' || preupgradecheck.fixup.fixup_type);
        dbms_output.put_line('preupgradecheck.fixup.fixAtStage=' || preupgradecheck.fixup.fixAtStage);
        dbms_output.put_line('preupgradecheck.severity=' || preupgradecheck.severity);
    END IF;

    preupgradecheck_failure_count := preupgradecheck_failure_count + 1;

    IF preupgradecheck.fixup.fixup_type = 'AUTOMATIC' THEN
        auto_fixup_text := C_FIXUP_TAG || ' ';
    ELSE
        auto_fixup_text := '';
    END IF;

    result := smart_pad(auto_fixup_text ||
                        message_t_to_text(preupgradecheck.action) || crlf || crlf ||
                        message_t_to_text(preupgradecheck.broken_rule) || crlf || crlf ||
                        message_t_to_text(preupgradecheck.rule),
                        C_TERMINAL_WIDTH, rpad(' ', indent_width, ' '));
    result := '  ' || substr(to_char(preupgradecheck_failure_count) || '.   ', 1, 4) || substr(result,indent_width+1);
    RETURN result;

END preupgradecheck_t_to_text;



FUNCTION autofixup_message(is_pre_fixup boolean) RETURN VARCHAR2
IS
    result VARCHAR2(4000);
    script_line VARCHAR2(600);
    fixup_script_name VARCHAR2(100);
    before_or_after VARCHAR2(10);
    container_expr VARCHAR2(150);
    container_expr2 VARCHAR2(40);
BEGIN
    IF is_pre_fixup THEN
        fixup_script_name := C_FIXUP_SCRIPT_NAME_PRE_BASE;
        before_or_after := 'BEFORE';
    ELSE
        fixup_script_name := C_FIXUP_SCRIPT_NAME_POST_BASE;
        before_or_after := 'AFTER';
    END IF;

    IF db_is_cdb THEN
        container_expr := ' container ' || con_name;
        container_expr2 := ' from within the container';
    ELSE
        container_expr := '';
        container_expr2 := '';
    END IF;

    result := '  ORACLE GENERATED FIXUP SCRIPT' || crlf ||
              '  =============================' || crlf ||
              '  All of the issues in database ' || db_name || container_expr || crlf ||
              '  which are identified above as ' || before_or_after || ' UPGRADE "(AUTOFIXUP)" can be resolved by' || crlf ||
              '  executing the following' || container_expr2 || crlf ||
              crlf;

    script_line := 'SQL>@' || preupgrade_dir_path || dir_sep || fixup_script_name || '.sql';

    return result || smart_pad(script_line, C_TERMINAL_WIDTH, '    ') || crlf || crlf;
END autofixup_message;


FUNCTION preupgradechecks_t_to_text(preupgradechecks preupgradechecks_t, initparams initparams_t) RETURN CLOB
IS
    check_index NUMBER := 1;
    last_index NUMBER;
    previous_index NUMBER;
    displayed_header BOOLEAN;
    result CLOB;
    this_param parameter_xml_record_t;
    autofixups_available BOOLEAN := false;
BEGIN
    last_index := preupgradechecks.count;

    --
    --    Reset this to 0.  preupgradecheck_t_to_text will walk through them and increment this each time.
    --
    preupgradecheck_failure_count := 0; 

    result := '==============' || crlf ||
              'BEFORE UPGRADE' || crlf ||
              '==============' || crlf ||
              crlf ||
              '  REQUIRED ACTIONS' || crlf ||
              '  ================' || crlf;

    --
    --    REQUIRED ACTIONS are reported, even if none exist, to be clear to user.
    --
    WHILE (check_index <= last_index) AND
          ( (preupgradechecks(check_index).fixup.fixAtStage = 'PRE') OR
            (preupgradechecks(check_index).fixup.fixAtStage = 'VALIDATION') ) AND
          (preupgradechecks(check_index).severity = c_check_level_error) LOOP
        result := result || preupgradecheck_t_to_text(preupgradechecks(check_index)) || crlf || crlf;
        autofixups_available := autofixups_available OR
                                (preupgradechecks(check_index).fixup.fixup_type = 'AUTOMATIC');
        check_index := check_index + 1;
    END LOOP;

    IF (check_index = 1) THEN
        result := result || '  None' || crlf || crlf;
    END IF;

    --
    --    RECOMMENDED ACTIONS - the header is displayed only if needed.
    --
    displayed_header := false;

    WHILE (check_index <= last_index) AND
          ( (preupgradechecks(check_index).fixup.fixAtStage = 'PRE') OR
            (preupgradechecks(check_index).fixup.fixAtStage = 'VALIDATION') ) AND
          ( (preupgradechecks(check_index).severity = c_check_level_warning) OR
            (preupgradechecks(check_index).severity = c_check_level_recommend) ) LOOP
        IF NOT displayed_header THEN
            result := result || '  RECOMMENDED ACTIONS' || crlf ||
                                '  ===================' || crlf;
            displayed_header := true;
        END IF;
        result := result || preupgradecheck_t_to_text(preupgradechecks(check_index)) || crlf || crlf;
        autofixups_available := autofixups_available OR
                                (preupgradechecks(check_index).fixup.fixup_type = 'AUTOMATIC');
        check_index := check_index + 1;
    END LOOP;


    --
    --    INFORMATION ONLY
    --
    displayed_header := false;

    WHILE (check_index <= last_index) AND
          ( (preupgradechecks(check_index).fixup.fixAtStage = 'PRE') OR
            (preupgradechecks(check_index).fixup.fixAtStage = 'VALIDATION') ) AND
          (preupgradechecks(check_index).severity = c_check_level_info) LOOP
        IF NOT displayed_header THEN
            result := result || '  INFORMATION ONLY' || crlf ||
                                '  ================' || crlf;
            displayed_header := true;
        END IF;
        result := result || preupgradecheck_t_to_text(preupgradechecks(check_index)) || crlf || crlf;
        autofixups_available := autofixups_available OR
                                (preupgradechecks(check_index).fixup.fixup_type = 'AUTOMATIC');
        check_index := check_index + 1;
    END LOOP;

    IF autofixups_available THEN
        result := result || autofixup_message(true);
    END IF;

    displayed_header := false;
    autofixups_available := false;  -- reset for the AFTER upgrade fixups.

    result := result ||
              '=============' || crlf ||
              'AFTER UPGRADE' || crlf ||
              '=============' || crlf ||
              crlf ||
              '  REQUIRED ACTIONS' || crlf ||
              '  ================' || crlf;
    previous_index := check_index;
    WHILE (check_index <= last_index) AND
          (preupgradechecks(check_index).fixup.fixAtStage = 'POST') AND
          (preupgradechecks(check_index).severity = c_check_level_error) LOOP
        IF NOT displayed_header THEN
            displayed_header := true;
        END IF;
        result := result || preupgradecheck_t_to_text(preupgradechecks(check_index)) || crlf || crlf;
        autofixups_available := autofixups_available OR
                                (preupgradechecks(check_index).fixup.fixup_type = 'AUTOMATIC');
        check_index := check_index + 1;
    END LOOP;

    IF (check_index = previous_index) THEN
        result := result || '  None' || crlf || crlf;
    END IF;

    displayed_header := false;

    WHILE (check_index <= last_index) AND
          (preupgradechecks(check_index).fixup.fixAtStage = 'POST') AND
          ( (preupgradechecks(check_index).severity = c_check_level_warning) OR
            (preupgradechecks(check_index).severity = c_check_level_recommend) ) LOOP
        IF NOT displayed_header THEN
            result := result || '  RECOMMENDED ACTIONS' || crlf ||
                                '  ===================' || crlf;
            displayed_header := true;
        END IF;
        result := result || preupgradecheck_t_to_text(preupgradechecks(check_index)) || crlf || crlf;
        autofixups_available := autofixups_available OR
                                (preupgradechecks(check_index).fixup.fixup_type = 'AUTOMATIC');
        check_index := check_index + 1;
    END LOOP;

    displayed_header := false;

    WHILE (check_index <= last_index) AND
          (preupgradechecks(check_index).fixup.fixAtStage = 'POST') AND
          (preupgradechecks(check_index).severity = c_check_level_info) LOOP
        IF NOT displayed_header THEN
            result := result || '  INFORMATION ONLY' || crlf ||
                                '  ================' || crlf;
            displayed_header := true;
        END IF;
        result := result || preupgradecheck_t_to_text(preupgradechecks(check_index)) || crlf || crlf;
        autofixups_available := autofixups_available OR
                                (preupgradechecks(check_index).fixup.fixup_type = 'AUTOMATIC');
        check_index := check_index + 1;
    END LOOP;

    IF autofixups_available THEN
        result := result || autofixup_message(false);
    END IF;

    IF check_index <= last_index THEN
        result := result || 'Internal Error - ' || to_char(last_index-check_index+1) ||
                  ' preupgrade checks were generated in XML but not emitted to TEXT.';
    END IF;

    RETURN result;
END preupgradechecks_t_to_text;


FUNCTION components_t_to_text(components components_t) RETURN VARCHAR2
IS
    result VARCHAR2(4000);
    ui VARCHAR2(17);
    invalid_components BOOLEAN := FALSE;
    comp component_t;
    cols number_array_t := new number_array_t(2,38,1,17,1,14);  -- column spacing, including gaps between meaningful cols.
BEGIN
    result := column_format(cols,
                new string_array_t(' ','Oracle Component', ' ', 'Upgrade Action', ' ', 'Current Status') ) || crlf ||
              column_format(cols,
                new string_array_t(' ','----------------', ' ', '--------------', ' ', '--------------') ) || crlf;

    IF components.count = 0 THEN
        result := result ||
                  column_format(cols, new string_array_t(' ','None', ' ', ' ', ' ', ' ') ) || crlf;
    ELSE
        FOR components_index IN 1 .. components.count LOOP
            comp := components(components_index);
            IF comp.install THEN
                ui := '[to be installed]';
            ELSE
                ui := '[to be upgraded]';
            END IF;

            IF comp.status = 'INVALID' THEN
                invalid_components := TRUE;
            END IF;

            result := result ||
                      column_format(cols, new string_array_t(' ',comp.cname, ' ', ui, ' ', comp.status) ) || crlf;
        END LOOP;
    END IF;

    IF invalid_components and db_is_cdb THEN
        result := result || crlf ||
                  '  There are INVALID components.  Please attempt to recompile INVALID components' || crlf ||
                  '  from $ORACLE_HOME/rdbms/admin.  For example, :' || crlf ||
                  crlf ||
                  '    $ORACLE_HOME/perl/bin/perl catcon.pl -n 1 -e -b utlrp -d ''''''.'''''' utlrp.sql' || crlf ||
                  crlf ||
                  '  (For the best performance, you may want to set the -n value to suit your system.)' || crlf ||
                  '  Then, run the preupgrade.jar again.' || crlf;
    END IF;

    RETURN result || crlf;
END components_t_to_text;


FUNCTION tablespaces_t_to_text(tablespaces tablespaces_t) RETURN CLOB
IS
BEGIN
    RETURN '';
END tablespaces_t_to_text;

FUNCTION archivelogs_t_to_text(archivelogs archivelogs_t) RETURN VARCHAR2
IS
BEGIN
    -- we do not emit text in manual mode for this element.
    RETURN '';
END archivelogs_t_to_text;

FUNCTION flashbacklogs_t_to_text(flashbacklogs flashbacklogs_t) RETURN VARCHAR2
IS 
BEGIN
    -- we do not emit text in manual mode for this element.
    RETURN '';
END flashbacklogs_t_to_text;

FUNCTION rollback_segments_t_to_text(rollback_segments rollback_segments_t) RETURN CLOB
IS
BEGIN
    RETURN '';
END rollback_segments_t_to_text;


FUNCTION flashback_info_t_to_text(flashback_info flashback_info_t) RETURN CLOB
IS
BEGIN
    RETURN '';
END flashback_info_t_to_text;


FUNCTION systemresource_t_to_text(systemresource systemresource_t) RETURN CLOB
IS 
BEGIN
    RETURN '';
END systemresource_t_to_text;

FUNCTION initparams_t_to_text(initparams initparams_t) RETURN CLOB
IS
    this_param_name  V$PARAMETER.NAME%TYPE;  -- has * if a mem param to display
    this_param parameter_xml_record_t;
    result CLOB;
    displayed_header boolean;
    cols number_array_t := new number_array_t(5,30,2,-20);  -- determines column widths for output table
BEGIN
    RETURN '';
END initparams_t_to_text;

-- @@to_text

FUNCTION xml_to_text(xml CLOB) RETURN CLOB
IS
    result CLOB;
    element_name VARCHAR2(100);
    start_index NUMBER := 1;
    end_index NUMBER;  -- gets set to the index of the end of xml elements
    start_of_element_index NUMBER;  -- start of each element as it is found
    end_of_element_index NUMBER;  -- end of each element as it is found
    preupgradecheck preupgradecheck_t;
    preupgradechecks preupgradechecks_t;
    rdbmsup rdbmsup_t;
    my_database database_t;
    components components_t;
    systemresource systemresource_t;
    initparams initparams_t;
BEGIN
    end_index := length(xml);
    element_name := identify_next_element(xml, start_index, end_index,
                    start_of_element_index, end_of_element_index);
    WHILE (element_name IS NOT NULL) LOOP
        element_name := upper(element_name);
        IF debug THEN
            dbms_output.put_line('in xml_to_text, processing xml element: ' || element_name);
        END IF;

        CASE
            WHEN element_name = 'UPGRADE' THEN
                -- The UPGRADE element exists only on non-CDBs at the PLSQL level.  For CDBs the
                -- element is created in PreupgradeDriver.java, and is outside the visibility of this routine.
                -- so the result of UPGRADE element is just whatever content is inside the UPGRADE element.
                -- the +8 below is to skip over the current <Upgrade element.
                result := xml_to_text(substr(xml,start_of_element_index+8, end_of_element_index));
            WHEN element_name = 'RDBMSUP' THEN
                rdbmsup := parse_rdbmsup_xml(xml, start_of_element_index, end_of_element_index);
                    end_of_element_index := instr(xml, '>', start_of_element_index);
                result := result || rdbmsup_t_to_text(rdbmsup);
            WHEN element_name = 'DATABASE' THEN
                my_database := parse_database_xml(xml, start_of_element_index, end_of_element_index);
                result := result || database_t_to_text(my_database);
            WHEN element_name = 'PREUPGRADECHECKS' THEN
                preupgradechecks := parse_preupgradechecks_xml(xml, start_of_element_index, end_of_element_index);
                -- initparams was set in a previous iteration since they must precede preupgradechecks in XML.
                -- since the initparam information is not handled as a true CHECK.
                result := result || preupgradechecks_t_to_text(preupgradechecks,initparams);
            WHEN element_name = 'COMPONENTS' THEN
                components := parse_components_xml(xml, start_of_element_index, end_of_element_index);
                result := result || components_t_to_text(components);
            WHEN element_name = 'SYSTEMRESOURCE' THEN
                systemresource := parse_systemresource_xml(xml, start_of_element_index, end_of_element_index);
                result := result || systemresource_t_to_text(systemresource);
            WHEN element_name = 'INITPARAMS' THEN
                initparams := parse_initparams_xml(xml, start_of_element_index, end_of_element_index);
                result := result || initparams_t_to_text(initparams);
            ELSE
                internal_error('invalid internal XML.  Found unexpected element "' || element_name ||
                               '" while parsing outermost scope.' ||
                               ' Rerun preupgrade but generate XML output instead of' ||
                               ' text to identify problem for Oracle Support.');
        END CASE;

        --
        --    Format the output.
        -- 

        element_name := identify_next_element(xml, end_of_element_index+1, end_index,
                        start_of_element_index, end_of_element_index);
    END LOOP;

    RETURN result;
END xml_to_text;

FUNCTION get_failed_check_xml(check_name IN VARCHAR2,
                              substitution_parameter_values IN string_array_t,
                              detail_type IN VARCHAR2,
                              detail_info IN VARCHAR2)
                              RETURN CLOB
IS
    my_check check_record_t;
    broken_rule CLOB;
    action CLOB;
    idx NUMBER;
    fixup_type CLOB;
    messageValues CLOB := '';
    escapedOutput CLOB;
    detail_type_local VARCHAR2(20);
BEGIN
    FOR idx IN 1 .. substitution_parameter_values.count() LOOP
        --
        --    Escape any special characters to be emitted in the XML content, otherwise the XML processing may get sick.
        --    Make sure to perform substitutions the reverse order of how they are written.
        --
        escapedOutput := substitution_parameter_values(idx);
        escapedOutput := replace(escapedOutput, '&',  '&' || 'amp;');
        escapedOutput := replace(escapedOutput, '"',  '&' || 'quot;');
        escapedOutput := replace(escapedOutput, '''', '&' || 'apos;');
        escapedOutput := replace(escapedOutput, '<',  '&' || 'lt;');
        escapedOutput := replace(escapedOutput, '>',  '&' || 'gt;');

        messageValues := messageValues || '      <MessageValue Position="' || to_char(idx) || '">' ||
                                                 escapedOutput ||
                                                '</MessageValue>' || crlf;
    END LOOP;

    ---------------------------------
    my_check := get_check_record_by_name(check_name);

    --
    --    the text for the "broken_rule" and "action" needs to be calculated
    --    by making the substitutions for this failure context
    --
    broken_rule := my_check.broken_rule;
    action := my_check.action;
    FOR idx IN 1 .. substitution_parameter_values.count() LOOP
        broken_rule := REPLACE(broken_rule,
                               C_SUBSTITUTION_DELIMITER_OPEN || TO_CHAR(idx) || C_SUBSTITUTION_DELIMITER_CLOSE,
                               substitution_parameter_values(idx));
        action      := REPLACE(action,
                               C_SUBSTITUTION_DELIMITER_OPEN || TO_CHAR(idx) || C_SUBSTITUTION_DELIMITER_CLOSE,
                               substitution_parameter_values(idx));
    END LOOP;

    IF (my_check.auto_fixup_available) THEN
        fixup_type := 'AUTOMATIC';
    ELSE
        fixup_type := 'MANUAL';
    END IF;

    --
    --    As of 8/1/2015, all calls have detail_type = null.
    --    This is provided for backward compatibility for DBUA.
    --
    detail_type_local := detail_type;
    IF (detail_type_local IS NULL) THEN
        detail_type_local := 'TEXT';
    END IF;

    --
    --    OLD 12.1.0.2 FORMAT
    --
    -- return ('<PreUpgradeCheck ID="'      || my_check.name ||
    --                        '" Status="'  || my_check.severity  || '">' ||
    --                        crlf ||
    --             '<Message>' || crlf ||
    --                 '<Text>'   || my_check.rule  || '</Text>' || crlf || 
    --                 '<Cause>'  || broken_rule    || '</Cause>'  || crlf ||
    --                 '<Action>' || action         || '</Action>' || crlf ||
    --                 '<Detail Type="' || detail_type || '">' 
    --                     || detail_info || '</Detail>' || crlf ||
    --             '</Message>' || crlf ||
    --             '<FixUp Type="' || fixup_type  ||
    --                  '" FixAtStage="' || my_check.fixup_stage || '"/>' || crlf ||
    --         '</PreUpgradeCheck>' || crlf);    


    return '<PreUpgradeCheck ID="' || my_check.name || '" Status="'  || check_level_strings(my_check.severity)  || '">' || crlf ||
            '  <Rule>' || crlf ||
            '    <Message ID="CHECK.' || upper(my_check.name) || '.RULE">' || crlf ||
                   messageValues ||
            '    </Message>' || crlf ||
            '  </Rule>' || crlf ||
            '  <Broken_Rule>' || crlf ||
            '    <Message ID="CHECK.' || upper(my_check.name) || '.BROKEN_RULE">' || crlf ||
                   messageValues ||
            '    </Message>' || crlf ||
            '  </Broken_Rule>' || crlf ||
            '  <Action>' || crlf ||
            '    <Message ID="CHECK.' || upper(my_check.name) || '.ACTION">' || crlf ||
                   messageValues ||
            '    </Message>' || crlf ||
            '  </Action>' || crlf ||
            '  <Detail Type="' || detail_type_local || '">' || detail_info || '</Detail>' || crlf ||
            '  <FixUp Type="' || fixup_type  || '" FixAtStage="' || my_check.fixup_stage || '"/>' || crlf ||
            '</PreUpgradeCheck>' || crlf;
END get_failed_check_xml;


FUNCTION get_reserved_user (username IN VARCHAR2,
                            first_version_reserved IN VARCHAR2)
                            RETURN VARCHAR2
IS
BEGIN
    --
    --    first_version_reserved and/or last_version_reserved may be NULL to
    --    indicate that-that end of the version range is not bounded.
    --    Normally, first_version_reserved will be specified,
    --    and last_version_reserved will be null
    --

    --
    --    This CHECK identifies a problem only when the upgrade starts in
    --    a version which is BEFORE the Oracle reservation, and the upgrade
    --    destination/to/high version is EQUAL or AFTER the Oracle
    --    reservation version.
    --
    IF debug THEN
        dbms_output.put_line('in get_reserved_user: version check starting: db_version=' ||
                             db_version_4_dots);
        dbms_output.put_line('in get_reserved_user: version check starting: reserved  =' ||
                             first_version_reserved);
        dbms_output.put_line('in get_reserved_user: version check starting: high vers =' ||
                             C_ORACLE_HIGH_VERSION_4_DOTS);
        dbms_output.put_line('in get_reserved_user: compare(dbv,first)=' ||
                    to_char(dbms_registry_extended.compare_versions(db_version_4_dots, first_version_reserved)));
        dbms_output.put_line('in get_reserved_user: compare(first,high)=' || 
                    to_char(dbms_registry_extended.compare_versions(first_version_reserved,C_ORACLE_HIGH_VERSION_4_DOTS)));
    END IF;

    IF (dbms_registry_extended.compare_versions(db_version_4_dots, first_version_reserved) = -1) AND
       (dbms_registry_extended.compare_versions(C_ORACLE_HIGH_VERSION_4_DOTS, first_version_reserved) >= 0) THEN
    
        IF debug THEN
            dbms_output.put_line('in get_reserved_user, version checked, user must not exist in db');
        END IF;

        IF select_has_rows('SELECT null from SYS.USER$ WHERE name='''||username||'''') THEN
            RETURN '<br>' || username;
        END IF;
    END IF;

    RETURN '';

END get_reserved_user;



--
--    End of XML, other misc routines
--
FUNCTION open_and_start_emitting_fixup(PRE_or_POST VARCHAR2) RETURN utl_file.file_type
IS
    fixup_script utl_file.file_type;
    genline VARCHAR2(4000);
    generation_timestamp VARCHAR2(20);
    cdb_suffix VARCHAR2(200);
    con_name_as_filename VARCHAR2(128);
BEGIN
    con_name_as_filename := replace(con_name,'$','_');
    BEGIN
        IF db_is_cdb THEN
            C_FIXUP_SCRIPT_NAME_PRE := C_FIXUP_SCRIPT_NAME_PRE_BASE || '_' || con_name_as_filename || '.sql';
            C_FIXUP_SCRIPT_NAME_POST := C_FIXUP_SCRIPT_NAME_POST_BASE || '_' || con_name_as_filename || '.sql';
        ELSE
            C_FIXUP_SCRIPT_NAME_PRE := C_FIXUP_SCRIPT_NAME_PRE_BASE || '.sql';
            C_FIXUP_SCRIPT_NAME_POST := C_FIXUP_SCRIPT_NAME_POST_BASE || '.sql';
        END IF;
        IF debug THEN
            dbms_output.put_line('C_FIXUP_SCRIPT_NAME_PRE = "' || C_FIXUP_SCRIPT_NAME_PRE || '"');
            dbms_output.put_line('C_FIXUP_SCRIPT_NAME_POST = "' || C_FIXUP_SCRIPT_NAME_POST || '"');
        END IF;

        IF (PRE_or_POST = 'PRE') THEN
            fixup_script := utl_file.fopen('PREUPGRADE_DIR',REPLACE(C_FIXUP_SCRIPT_NAME_PRE,'$','_'), 'w');
        ELSIF (PRE_or_POST = 'POST') THEN
            fixup_script := utl_file.fopen('PREUPGRADE_DIR',REPLACE(C_FIXUP_SCRIPT_NAME_POST,'$','_'), 'w');

        ELSE
            internal_error('in open_and_start_emitting_fixup, PRE_or_POST=' || PRE_or_POST ||
                           ' but the only valid values are PRE and POST.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('ERROR - cannot open the ' || PRE_or_POST || ' fixup script for writing.' ||
                                 '  sqlerrm=' || sqlerrm || ' sqlcode=' || sqlcode);
            RETURN fixup_script;
    END;

    --
    --    Write header to the fixup Script
    --
    EXECUTE IMMEDIATE 'SELECT TO_CHAR(SYSTIMESTAMP,''YYYY-MM-DD HH24:MI:SS '') FROM SYS.DUAL'
                       INTO generation_timestamp;

    --
    --    a) If this is a cdb, the prefixup steps for multiple containers go into
    --    one prefixup file; and the postfixup steps for multiple containers go
    --    into one postfixup file.  In order to make this work, the fixup steps
    --    for a container will go into a IF stmt that gets executed if the
    --    container name for those fixup steps match the name of the current
    --    container connected to.
    --    b) For consistency between a non-cdb and cdb, we keep the same IF stmt
    --    format for the fixup steps for both non-cdbs and cdbs.  For
    --    non-cdbs, we match database names.  For cdbs, we match container names.
    --
    to_file(fixup_script, 'REM');
    to_file(fixup_script, 'REM    Oracle ' || PRE_or_POST || '-Upgrade Fixup Script');
    to_file(fixup_script, 'REM');
    to_file(fixup_script, 'REM    Auto-Generated by:       Oracle Preupgrade Script');
    to_file(fixup_script, 'REM                             Version: ' || C_ORACLE_HIGH_VERSION_4_DOTS ||
                                                           ' Build: ' || c_build);
    to_file(fixup_script, 'REM    Generated on:            ' || generation_timestamp);
    to_file(fixup_script, 'REM');
    to_file(fixup_script, 'REM    Source Database:         ' || db_name);
    to_file(fixup_script, 'REM    Source Database Version: ' || db_version_4_dots);
    to_file(fixup_script, 'REM    For Upgrade to Version:  ' || C_ORACLE_HIGH_VERSION_4_DOTS);
    to_file(fixup_script, 'REM');
    to_file(fixup_script, ' ');

    to_file(fixup_script, 'REM');
    to_file(fixup_script, 'REM    Setup Environment');
    to_file(fixup_script, 'REM');
    to_file(fixup_script, 'SET ECHO OFF SERVEROUTPUT ON FORMAT WRAPPED TAB OFF LINESIZE 200;' || crlf);

    to_file(fixup_script, ' ');

    --
    --    In a fixup script, there is a block with IF stmt for each database or
    --    container's fixup steps.
    --

    IF (PRE_or_POST = 'POST') THEN
      to_file(fixup_script, 'ALTER SESSION SET "_oracle_script" = TRUE;');
      to_file(fixup_script, 'VARIABLE admin_preupgrade_dir VARCHAR2(512);');
      IF db_is_cdb THEN
          to_file(fixup_script, 'VARIABLE current_container VARCHAR2(128);');
      END IF;
      to_file(fixup_script, ' ');
      to_file(fixup_script, 'REM');
      to_file(fixup_script, 'REM    point PREUPGRADE_DIR to OH/rdbms/admin');
      to_file(fixup_script, 'REM');
      to_file(fixup_script, 'DECLARE');
      to_file(fixup_script, '    oh VARCHAR2(4000);');
      to_file(fixup_script, 'BEGIN');
      to_file(fixup_script, '    dbms_system.get_env(''ORACLE_HOME'', oh);');
      to_file(fixup_script, '    :admin_preupgrade_dir := dbms_assert.enquote_literal(oh || ''/rdbms/admin'');');
      IF db_is_cdb THEN
          to_file(fixup_script, '    SELECT SYS_CONTEXT(''USERENV'', ''CON_NAME'') INTO :current_container FROM DUAL;');
      END IF;
      to_file(fixup_script, 'END;');
      to_file(fixup_script, '/');
      to_file(fixup_script, ' ');
      IF db_is_cdb THEN
          to_file(fixup_script, 'ALTER SESSION SET CONTAINER=CDB$ROOT;');
          to_file(fixup_script, ' ');
          to_file(fixup_script, 'DECLARE');
          to_file(fixup_script, '    command varchar2(4000);');
          to_file(fixup_script, 'BEGIN');
          to_file(fixup_script, '    command := ''CREATE OR REPLACE DIRECTORY PREUPGRADE_DIR SHARING=METADATA AS '' || :admin_preupgrade_dir;');
          to_file(fixup_script, '    EXECUTE IMMEDIATE command;');
          to_file(fixup_script, '    command := ''ALTER SESSION SET CONTAINER='' || :current_container;');
          to_file(fixup_script, '    EXECUTE IMMEDIATE command;');
          to_file(fixup_script, '    command := ''CREATE OR REPLACE DIRECTORY PREUPGRADE_DIR SHARING=METADATA AS '' || :admin_preupgrade_dir;');
          to_file(fixup_script, '    EXECUTE IMMEDIATE command;');
          to_file(fixup_script, 'END;');
          to_file(fixup_script, '/');
      ELSE
          to_file(fixup_script, 'DECLARE');
          to_file(fixup_script, '    command varchar2(4000);');
          to_file(fixup_script, 'BEGIN');
          to_file(fixup_script, '    command := ''CREATE OR REPLACE DIRECTORY PREUPGRADE_DIR AS '' || :admin_preupgrade_dir;');
          to_file(fixup_script, '    EXECUTE IMMEDIATE command;');
          to_file(fixup_script, 'END;');
          to_file(fixup_script, '/');
      END IF;
      to_file(fixup_script, ' ');
      to_file(fixup_script, '@?/rdbms/admin/dbms_registry_extended.sql');
      to_file(fixup_script, ' ');
      to_file(fixup_script, ' ');
      to_file(fixup_script, 'REM');
      to_file(fixup_script, 'REM    Execute the preupgrade_package from the PREUPGRADE_DIR');
      to_file(fixup_script, 'REM    This is needed because the preupgrade_messages.properties file');
      to_file(fixup_script, 'REM    lives there too, and is read by preupgrade_package.sql using');
      to_file(fixup_script, 'REM    the PREUPGRADE_DIR.');
      to_file(fixup_script, 'REM');
      to_file(fixup_script, 'COLUMN directory_path NEW_VALUE admin_preupgrade_dir NOPRINT;');
      to_file(fixup_script, 'select directory_path from dba_directories where directory_name=''PREUPGRADE_DIR'';');
      to_file(fixup_script, 'set concat ''.'';');
      -- careful not to put the ampersand in front of admin_preupgrade_dir or it will force immediate substitution.
      to_file(fixup_script, '@&' || 'admin_preupgrade_dir./preupgrade_package.sql');
      to_file(fixup_script, 'COLUMN directory_path CLEAR;');
      to_file(fixup_script, '');
    END IF;

    to_file(fixup_script, 'DECLARE');
    to_file(fixup_script, '  db_name V$DATABASE.NAME%TYPE;');
    to_file(fixup_script, '  con_name VARCHAR2(128);');
    to_file(fixup_script, '  fixup_result BOOLEAN := TRUE;');
    IF (PRE_or_POST = 'PRE') THEN
      to_file(fixup_script, '  recyclebin_cleaned BOOLEAN := TRUE;');
      to_file(fixup_script, '  check_result_xml VARCHAR2(32767);');
    END IF;
    to_file(fixup_script, 'BEGIN ');
    to_file(fixup_script, '  --');
    to_file(fixup_script, '  --    Gather the current execution context');
    to_file(fixup_script, '  --');
    to_file(fixup_script, '  EXECUTE IMMEDIATE ');
    to_file(fixup_script, '    ''SELECT name FROM v$database'' INTO db_name;');
    to_file(fixup_script, '  EXECUTE IMMEDIATE ');
    to_file(fixup_script, '    ''SELECT dbms_preup.get_con_name FROM sys.dual'' INTO con_name;');
    to_file(fixup_script, '  ');
    to_file(fixup_script, '  ');

    --
    --    If the session currently connected to is of a database or container that
    --    matches the name in the IF stmt, then stay in the block and run the
    --    fixup steps.
    --    Else, if the names do not match, then continue on to the next block in
    --    the fixup script.
    --    this execute immediate not needed.  We do this once at package body init.
    --    EXECUTE IMMEDIATE
    --     'select dbms_preup.get_con_name from sys.dual' INTO con_name;
    --


    --
    --    Now validate the execution context is the same as when the script was generated
    --
    to_file(fixup_script, ' ');
    to_file(fixup_script, '  --');
    to_file(fixup_script, '  --    Now validate that the current execution context');
    to_file(fixup_script, '  --    matches the context when this script was generated.');
    to_file(fixup_script, '  --');

    to_file(fixup_script, '  IF db_name <> ''' || db_name || ''' THEN');
    to_file(fixup_script, '    dbms_output.put_line(''WARNING - This script was generated '' ||');
    to_file(fixup_script, '      ''for database ' || db_name || '.'');');
    to_file(fixup_script, '  END IF;        -- if db_name is ' || db_name);
    to_file(fixup_script, ' ');

    -- Duplicate code? these next few lines that identify the script being run are the same lines
    -- that generate the -- script header for this fixup script.  It might be a good idea
    -- to reuse that code rather than repeat it here.  Except for the word "Executing"
    to_file(fixup_script, '  dbms_output.put_line(''Executing Oracle ' || PRE_or_POST || '-Upgrade Fixup Script'');');
    to_file(fixup_script, '  dbms_output.put_line('' '');');
    to_file(fixup_script, '  dbms_output.put_line(''Auto-Generated by:       Oracle Preupgrade Script'');');
    to_file(fixup_script, '  dbms_output.put_line(''                         Version: ' || C_ORACLE_HIGH_VERSION_4_DOTS || ' Build: ' || c_build || ''');');
    to_file(fixup_script, '  dbms_output.put_line(''Generated on:            ' || generation_timestamp || ''');');
    to_file(fixup_script, '  dbms_output.put_line('' '');');
    to_file(fixup_script, '  dbms_output.put_line(''For Source Database:     ' || db_name || ''');');
    to_file(fixup_script, '  dbms_output.put_line(''Source Database Version: ' || db_version_4_dots || ''');');
    to_file(fixup_script, '  dbms_output.put_line(''For Upgrade to Version:  ' || C_ORACLE_HIGH_VERSION_4_DOTS || ''');');
    to_file(fixup_script, '  dbms_output.put_line('' '');');
                
    to_file(fixup_script, ' ');
    IF db_is_cdb THEN
        to_file(fixup_script, '  --');
        -- do not edit or remove the following line.  PreupgradeDriver.java depends on its content.
        to_file(fixup_script, '  -- Starting PDB ' || con_name);
        to_file(fixup_script, '  --');
        to_file(fixup_script, '  IF con_name = ''' || con_name || ''' THEN');
        to_file(fixup_script, '    dbms_output.put_line (''Executing in container:  ' || con_name || ''');');
        to_file(fixup_script, '    dbms_output.put_line('' '');');
    ELSE
        to_file(fixup_script, '  -- Starting DB ' || db_name);
    END IF;

    to_file(fixup_script, ' ');
    to_file(fixup_script, '    dbms_output.put_line(''Preup                             Preupgrade                    '');');
    to_file(fixup_script, '    dbms_output.put_line(''Action                            Issue Is                      '');');
    to_file(fixup_script, '    dbms_output.put_line(''Number  Preupgrade Check Name     Remedied    Further DBA Action'');');
    to_file(fixup_script, '    dbms_output.put_line(''------  ------------------------  ----------  --------------------------------'');');

    RETURN fixup_script;
END open_and_start_emitting_fixup;

PROCEDURE finish_emitting_fixup(fixup_script IN OUT utl_file.file_type, PRE_or_POST VARCHAR2)
IS
BEGIN
    -- Footer message
    IF PRE_or_POST = 'PRE' THEN
      to_file(fixup_script, ' ');
      to_file(fixup_script, '    --');
      to_file(fixup_script, '    -- clean recyclebin in case any of the above fixups left stuff there.');
      to_file(fixup_script, '    --');
      to_file(fixup_script, '    recyclebin_cleaned := dbms_preup.run_fixup_only(''purge_recyclebin'', check_result_xml);');
      to_file(fixup_script, ' ');
      to_file(fixup_script, '    IF fixup_result = FALSE THEN');
      to_file(fixup_script, '       dbms_output.put_line('''');');
      to_file(fixup_script, '       dbms_output.put_line(''The fixup scripts have been run and resolved what they can. However,'');');
      to_file(fixup_script, '       dbms_output.put_line(''there are still issues originally identified by the preupgrade that'');');
      to_file(fixup_script, '       dbms_output.put_line(''have not been remedied and are still present in the database.'');');
      to_file(fixup_script, '       dbms_output.put_line(''Depending on the severity of the specific issue, and the nature of'');');
      to_file(fixup_script, '       dbms_output.put_line(''the issue itself, that could mean that your database is not ready'');');
      to_file(fixup_script, '       dbms_output.put_line(''for upgrade.  To resolve the outstanding issues, start by reviewing'');');
      to_file(fixup_script, '       dbms_output.put_line(''the preupgrade_fixups.sql and searching it for the name of'');');
      to_file(fixup_script, '       dbms_output.put_line(''the failed CHECK NAME or Preupgrade Action Number listed above.'');');
      to_file(fixup_script, '       dbms_output.put_line(''There you will find the original corresponding diagnostic message'');');
      to_file(fixup_script, '       dbms_output.put_line(''from the preupgrade which explains in more detail what still needs'');');
      to_file(fixup_script, '       dbms_output.put_line(''to be done.'');');
      to_file(fixup_script, '    END IF;');
    ELSE
      to_file(fixup_script, '    IF fixup_result = FALSE THEN');
      to_file(fixup_script, '       dbms_output.put_line('''');');
      to_file(fixup_script, '       dbms_output.put_line(''The fixup scripts have been run and resovled what they can. However,'');');
      to_file(fixup_script, '       dbms_output.put_line(''there are still issues originally identified by the preupgrade that'');');
      to_file(fixup_script, '       dbms_output.put_line(''have not been remedied and are still present in the database.'');');
      to_file(fixup_script, '       dbms_output.put_line(''Depending on the severity of the specific issue, and the nature of'');');
      to_file(fixup_script, '       dbms_output.put_line(''the issue itself, that could mean that your database upgrade is not'');');
      to_file(fixup_script, '       dbms_output.put_line(''fully complete.  To resolve the outstanding issues, start by reviewing'');');
      to_file(fixup_script, '       dbms_output.put_line(''the postupgrade_fixups.sql and searching it for the name of'');');
      to_file(fixup_script, '       dbms_output.put_line(''the failed CHECK NAME or Preupgrade Action Number listed above.'');');
      to_file(fixup_script, '       dbms_output.put_line(''There you will find the original corresponding diagnostic message'');');
      to_file(fixup_script, '       dbms_output.put_line(''from the preupgrade which explains in more detail what still needs'');');
      to_file(fixup_script, '       dbms_output.put_line(''to be done.'');');
      to_file(fixup_script, '    END IF;');
    END IF;

    IF db_is_cdb THEN
        to_file(fixup_script, '  END IF;      -- if con_name is ' || con_name);
        --
        -- do not remove or edit this next line.  PreupgradeDriver.java depends on its content.
        --
        to_file(fixup_Script, '  -- Done PDB.');
    END IF;

    to_file(fixup_script, 'END;');
    to_file(fixup_script, '/');
    IF (PRE_or_POST = 'POST') THEN
        -- cannot do this for PRE script since it runs in low version and _oracle_script isn't supported in 11.2
        to_file(fixup_script, 'ALTER SESSION SET "_oracle_script" = FALSE;');
    END IF;
    to_file(fixup_script, ' ');

    BEGIN
        utl_file.fclose(fixup_script);
    EXCEPTION
        WHEN OTHERS THEN
            -- only way this happens is if to_file() above works, but cannot close file.
            -- proably a bad timing window.
            dbms_output.put_line('ERROR - could not close fixup script.  Stabilize file system and retry preupgrade.');
    END;
END finish_emitting_fixup;


FUNCTION run_fixup_only(check_name IN VARCHAR2, check_result_xml IN OUT VARCHAR2) RETURN BOOLEAN
IS
    call_fixup_statement VARCHAR2(4000);
    fixup_result NUMBER;
    tSqlcode NUMBER;
BEGIN
    IF debug THEN
        dbms_output.put_line('in run_fixup_only.  check_name=' || check_name);
    END IF;

    --
    --    Call the FIXUP
    --
    BEGIN
        call_fixup_statement := 'BEGIN ' ||
            ':1 := dbms_preup.' ||
                   dbms_assert.simple_sql_name(check_name) || '_fixup (:2, :3); ' ||
                  'END;';

        EXECUTE IMMEDIATE call_fixup_statement
            USING OUT fixup_result, IN OUT check_result_xml, IN OUT tSqlcode;
    EXCEPTION
        WHEN stringNotSimpleSQLName THEN
            --
            --    The checkname is invalid somehow.  Get out.
            --
            internal_error('Pre-Upgrade Package Requested Fixup ' ||
                           check_name || ' does not exist');
        WHEN e_undefinedFunction THEN
            internal_error('check "' || check_name || '" not implemented.');
        WHEN OTHERS THEN
            --
            --    This could happen if the CHECK itself threw an exception.
            --
            RAISE;
    END;

    IF debug THEN
        dbms_output.put_line('normal return from run_fixup_only.  Returning ' ||
            boolean_string(fixup_result = c_success));
    END IF;

    RETURN (fixup_result = c_success);
END run_fixup_only;


--
--    This API to run_fixup(check_name) is provided for backward
--    compatibility.  It will set the fixup_id = 0 for all fixups.
--    that will work just fine, but the output will not number
--    the fixups.
--
FUNCTION run_fixup(check_name VARCHAR2) RETURN BOOLEAN
IS
BEGIN
    return run_fixup(check_name, 0);
END run_fixup;



FUNCTION run_fixup(check_name VARCHAR2, fixup_id NUMBER) RETURN BOOLEAN
IS
    this_check check_record_t;
    check_is_success BOOLEAN;
    fixup_is_success BOOLEAN;
    problem_remedied BOOLEAN;
    check_result_xml VARCHAR2(32767);
    original_message VARCHAR2(32767);
    dba_action       VARCHAR2(400);
    preupgradecheck preupgradecheck_t;
BEGIN
    IF debug THEN
        dbms_output.put_line('in run_fixup for check name: ' || check_name);
    END IF;

    --
    --    Before running the FIXUP, first run the CHECK again to
    --    see if the problem is still present.
    --
    this_check := get_check_record_by_name(check_name);
    check_is_success := run_check(check_name, check_result_xml);

    IF debug THEN
        dbms_output.put_line('in run_fixup for check name: ' || check_name || ' returned ' || boolean_string(check_is_success));
    END IF;

    IF (check_is_success) THEN
        -- state 1: problem previously fixed.
        problem_remedied := true;
        dba_action := 'None.';
    ELSE
        IF (NOT this_check.auto_fixup_available) THEN
            -- state 2: problem still present, but no auto-fixup routine available.
            problem_remedied := false;
            IF (this_check.severity = C_CHECK_LEVEL_ERROR) THEN
                dba_action := 'Manual fixup required.';
            ELSIF (this_check.severity = C_CHECK_LEVEL_WARNING) THEN
                dba_action := 'Manual fixup recommended.';
            ELSE
                dba_action := 'Informational only.             Further action is optional.';
            END IF;
        ELSE

            --
            --    run the fixup only
            --
            fixup_is_success := run_fixup_only(check_name, check_result_xml);

            IF (fixup_is_success) THEN
                --
                --    CHECK failed at start of this routine, the FIXUP ran
                --    and reported success.  Now, RERUN the CHECK to validate
                --    the problem has gone away.
                --
                check_is_success := run_check(check_name, check_result_xml);

                IF (check_is_success) THEN
                    -- state 3: fixup successfully run and validated.
                    problem_remedied := true;
                    dba_action := 'None.';
                ELSE
                    IF NOT this_check.fixup_is_detectable THEN
                        -- state 4: fixup reported success and fixup is fundamentally
                        -- not detectable.  Trust result of fixup.
                        problem_remedied := true;
                        dba_action := 'None. Be aware that the fixup   ' ||
                                      'has been successfully run, but  ' ||
                                      'by this fixup''s nature, its     ' ||
                                      'effects are not fully detectable' ||
                                      'in the current environment.     ' ||
                                      'Subsequent preupgrade runs will ' ||
                                      'report failure though the       ' ||
                                      'problem has been remedied for   ' ||
                                      'upgrade. Usually a DB restart is' ||
                                      'required to make the fixup fully' ||
                                      'manifest.';
                    ELSE
                        -- state 5: fixup reported success, but CHECK still fails,
                        -- and the check is supposed to be detectable.
                        problem_remedied := false;

                        dba_action := 'Unexpected failure.  Manual fixup required.  ' ||
                                      'FIXUP reports success, but a RECHECK indicated the problem still exists.';
                    END IF;
                END IF;
            ELSE
                -- state 6: fixup run, but returned failure status.
                problem_remedied := false;
                dba_action := 'Unexpected failure.  Fixup routine was run, but was unable to resolve the issue.  Manual DBA action required.';
            END IF;
        END IF;
    END IF;

    format_long_output(column_format(fixup_cols,
                         new string_array_t(' ', to_char(fixup_id) || '.',
                                            ' ', check_name,
                                            ' ', boolean_string(problem_remedied,'YES','NO'),
                                            ' ', dba_action )));
    return problem_remedied;
END run_fixup;

PROCEDURE run_fixup_and_report (check_name VARCHAR2)
IS
    --
    --    This PROCEDURE is provided for backward compatibility and
    --    convenience.  It has no way of returning a success/failure status
    --    back to the caller.  The preferred way to run fixups is
    --    to call the FUNCTION run_fixup(check_name) which
    --    returns a boolean success status.
    --
    succeeded BOOLEAN;
BEGIN
    succeeded := run_fixup(check_name);
END run_fixup_and_report;



PROCEDURE init_messages
IS
  props_file utl_file.file_type;
  props_line VARCHAR2(32767);
  property_name VARCHAR2(4000);
  property_value VARCHAR2(32767);
  equals_index NUMBER;
  check_name VARCHAR2(4000);
  check_subproperty VARCHAR2(4000);
  check_auto_fixup_available BOOLEAN;
  fixup_is_detectable BOOLEAN;
BEGIN
  BEGIN
      props_file := utl_file.fopen('PREUPGRADE_DIR', 'preupgrade_messages.properties', 'r',32767);
      LOOP
          BEGIN
              utl_file.get_line(props_file, props_line);

              IF debug THEN
                  dbms_output.put_line('READ PROPERTY: ' || props_line);
              END IF;

              --
              --   Skip comments in the properties file, identified by
              --   blank lines or ones starting with #
              --
              IF (props_line IS NOT NULL) AND
                 (trim(substr(props_line,1, instr(props_line||'#','#')-1)) IS NOT NULL) THEN
                  equals_index := instr(props_line, '=');
                  property_name := upper(trim(substr(props_line, 1, equals_index-1)));
                  property_value := substr(props_line, equals_index + 1);
                  properties(property_name) := property_value;

                  --
                  --  Process entire property file, record each check in order.
                  --
                  IF (dbms_registry_extended.element(property_name,'.',1) = 'CHECK') THEN
                      check_name := dbms_registry_extended.element(property_name, '.', 2);
                      check_subproperty := dbms_registry_extended.element(property_name, '.', 3);
                      IF (upper(check_subproperty) = 'RULE') THEN
                          ordered_check_names(ordered_check_names.count + 1) := check_name;
                      END IF;
                  END IF;
              END IF;

          EXCEPTION WHEN no_data_found THEN
              utl_file.fclose(props_file);
              EXIT;
          END;
      END LOOP;
  EXCEPTION WHEN invalidFileOperation THEN
      dbms_output.put_line('ERROR - Cannot open the ' ||
          'preupgrade_messages.properties file from the directory object preupgrade_dir');
      RAISE;
  END;


  --
  --    For each CHECK gathered from the properties file,
  --    gather all of its associated properties and call DEFINE_CHECK
  --
  IF (ordered_check_names.count = 0) THEN
      dbms_output.put_line('ERROR - could not register any CHECKs to be run');
  ELSE
      FOR check_table_index IN 1 .. ordered_check_names.count LOOP
          check_name := ordered_check_names(check_table_index);

          --
          --    Process the property.
          --    Since properties will look like, CHECK.<checkname>.RULE=value
          --    and CHECK.<checkname>.BROKEN_RULE, whenever we hit a CHECK.<checkname>.RULE,
          --    go get the other properties, and call define_check.
          --
          BEGIN
              check_auto_fixup_available := 
                  (upper(properties('CHECK.' || check_name || '.AUTO_FIXUP_AVAILABLE')) = 'TRUE');
              fixup_is_detectable := 
                  (upper(properties('CHECK.' || check_name || '.FIXUP_IS_DETECTABLE')) = 'TRUE');
              define_check ( lower(check_name),
                             properties('CHECK.' || check_name || '.SEVERITY'),
                             properties('CHECK.' || check_name || '.RULE'),
                             properties('CHECK.' || check_name || '.BROKEN_RULE'),
                             properties('CHECK.' || check_name || '.ACTION'),
                             upper(properties('CHECK.' || check_name || '.FIXUP_STAGE')),
                             check_auto_fixup_available,
                             fixup_is_detectable,
                             properties('CHECK.' || check_name || '.MIN_VERSION_INCLUSIVE'),
                             properties('CHECK.' || check_name || '.MAX_VERSION_EXCLUSIVE') );
          EXCEPTION WHEN OTHERS THEN
              internal_error('invalid preupgrade_message.properties file format' ||
                             ' processing CHECK ' || check_name ||
                             ' The most likely cause is that the file is missing one of that CHECK''s ' ||
                             ' properties like .RULE, .BROKEN_RULE, etc.');
          END;

      END LOOP;
  END IF;
END init_messages;

PROCEDURE init_components
IS
  reg_cursor cursor_t;
  c_null     CHAR(1);
  c_cid      VARCHAR2(128);
  c_version  VARCHAR2(128);
  c_schema   VARCHAR2(128);
  n_schema   NUMBER;
  n_status   NUMBER;
  c_default_tablespace SYS.DBA_USERS.DEFAULT_TABLESPACE%TYPE;
  i          NUMBER;
BEGIN
  read_components_properties();

  --
  -- Adjust XDB size numbers according to db_block_size as needed.
  --
  IF is_supported_component('XDB') AND
     db_block_size = 16384 THEN
      cmp_info(supported_component_index('XDB')).ins_def_kbytes :=
          2 * cmp_info(supported_component_index('XDB')).ins_def_kbytes;
  END IF;


  --
  -- Figure out which components will be "processed" by the upgrade.
  -- First find the components that are installed in the
  -- low version db.  Later we'll add components that
  -- need to be installed by the upgrade due to any new
  -- product dependencies.
  --
  -- Grab the Component ID (varchar2) from
  -- registry, and then see if the 
  -- schema exists in USER$ below which means its
  -- in use in this database.
  --
  -- If the status is not 99,8 = REMOVED or REMOVING
  -- 12202 - simplify nested SELECTs into a single one.
  OPEN reg_cursor FOR 
     'SELECT r.cid, r.status, r.version, r.schema#, u.name, d.default_tablespace
      FROM sys.registry$ r
      JOIN sys.user$ u on u.user#=r.schema#
      LEFT OUTER JOIN sys.dba_users d on  d.username = u.name
      WHERE r.namespace =''SERVER'' and r.status not in (99,8) and r.cid !=''APEX''';
  LOOP

    FETCH reg_cursor INTO c_cid, n_status, c_version, n_schema, c_schema, c_default_tablespace;
    EXIT WHEN reg_cursor%NOTFOUND;

    IF is_supported_component(c_cid) THEN
      -- store_comp( supported_component_index(c_cid), c_schema, c_version, n_status);
      i := supported_component_index(c_cid);
      cmp_info(i).processed := TRUE;
      cmp_info(i).status    := dbms_registry.status_name(n_status);
      cmp_info(i).version   := c_version;
      cmp_info(i).schema    := n_schema;
      cmp_info(i).def_ts    := c_default_tablespace;
    END IF;
  END LOOP;
  CLOSE reg_cursor;


  -- CML: TS: estimate for utlrp later?
    -- Consider MISC (miscellaneous) aka "STATS" in registry because
    -- cmp_info(misc).processed has to be equal to TRUE before the tablespace
    -- sizing algorithm will consider the space needed for MISC.
    -- this call will set 'cmp_info(misc).processed := TRUE;'
  -- store_comp(misc, 'SYS', NULL, NULL);
  --
  -- fake the psuedo-component "STATS" to be processed
  -- accept

  IF NOT is_supported_component('STATS') THEN
      internal_error(db_version_1_dot||' STATS component info not found in components.properties file.');
  ELSE
    i := supported_component_index('STATS');
    cmp_info(i).processed := TRUE;
    cmp_info(i).schema := 'SYS';
    EXECUTE IMMEDIATE
      'SELECT default_tablespace FROM sys.dba_users WHERE username =:1'
    INTO cmp_info(i).def_ts
    USING cmp_info(i).schema;
  END IF;


  --
  --    Figure out if any components should be "installed."
  --    If new product dependencies are introduced in a version
  --    check if that version boundary is crossed by this upgrade
  --    and if the dependency is not satisfied.
  --
  --    12.1.0.1 - no new product dependencies
  --    12.1.0.2 - no new product dependencies
  --    12.2.0.1 - no new product dependencies
  --    12.2.0.2 - no new product dependencies
  --

  -- none at this time.

END init_components;


--
-- creates a record in mem_parameters table
-- this table will contain computational info for MEMORY sizing
-- 
PROCEDURE store_memparam_record (name     VARCHAR2,
                                 minval   NUMBER,
                                 memvp    IN OUT MEMPARAMETER_TABLE_T)
IS
  message VARCHAR2(100) := '';  -- error msg if this procedure is called for a
                                -- parameter that we do not size for memory
BEGIN
  -- if we are not sizing for this memory parameter, then don't create
  -- a record for it
  IF is_size_this_memparam(name) = TRUE THEN
    memvp(name).name := name;
    memvp(name).old_value := all_parameters(name).value;
    memvp(name).min_value := minval;
    memvp(name).dif_value := 0;
    memvp(name).isdefault := all_parameters(name).isdefault;
    memvp(name).display := FALSE;
  ELSE
    message := 'parameter ' || name || ' is not recognized for memory sizing';
    RAISE_APPLICATION_ERROR (-20000, message);
  END IF;
END store_memparam_record;

PROCEDURE store_minval_param(paramname VARCHAR2, min_value INTEGER)
IS
BEGIN
  -- The purpose of recording minimum value settings for certain parameters is to
  -- ensure that the user's existing settings conform to new minimum standards in the
  -- higher release.  If the user has no setting for a parameter, there's no need to
  -- worry about whether a minimum has been violated.
  IF all_parameters.exists(paramname) THEN
    -- if the parameter does not exist its because it does not exist in this RELEASE.  No need to record it has been renamed
    all_parameters(paramname).min_value := min_value;
  END IF;
END store_minval_param;


PROCEDURE store_renamed_param (oldname VARCHAR2, newname VARCHAR2)
IS
BEGIN
  IF all_parameters.exists(oldname) THEN
    -- if the parameter does not exist its because it does not exist in this RELEASE.  No need to record it has been renamed
    all_parameters(oldname).renamed_to_name := newname;
  END IF;
END store_renamed_param;


PROCEDURE store_renamed_param_and_value (oldname  VARCHAR2, oldvalue VARCHAR2,
                                         newname  VARCHAR2, newvalue VARCHAR2)
IS
BEGIN
  -- if the parameter does not exist for the source db release version, no need to record it.
  IF all_parameters.exists(oldname) AND
     all_parameters(oldname).value = oldvalue THEN
    all_parameters(oldname).renamed_to_name := newname;
    all_parameters(oldname).new_value := newvalue;
  END IF;
END store_renamed_param_and_value;

PROCEDURE analyze_params
IS
  props_file utl_file.file_type;
  props_line VARCHAR2(800);
  param_name VARCHAR2(256);
  param_type VARCHAR2(256);
  indx NUMBER;
  comma_index NUMBER;
  prop_filename VARCHAR(32) := 'parameters.properties';
BEGIN
      props_file := utl_file.fopen('PREUPGRADE_DIR', prop_filename, 'r',32767);
      LOOP
          BEGIN
              utl_file.get_line(props_file, props_line);

              --
              --   Skip comments in the properties file, identified by
              --   blank lines or ones starting with #
              --
              IF (props_line IS NOT NULL) AND
                 (trim(substr(props_line,1, instr(props_line||'#','#')-1)) IS NOT NULL) THEN
                  comma_index := instr(props_line, ',');
                  param_name := trim(substr(props_line, 1, comma_index-1));
                  param_type := upper(substr(props_line, comma_index + 1));

                  IF all_parameters.exists(param_name) THEN
                      -- If there are duplicate entries, the later value
                      -- will override the previous value 
                      IF (param_type='DEPRECATED') THEN
                          all_parameters(param_name).is_deprecated := true; 
                          all_parameters(param_name).is_obsoleted := false;
                      ELSIF (param_type='OBSOLETE') OR (param_type='REMOVED') THEN
                          all_parameters(param_name).is_obsoleted := true;
                          all_parameters(param_name).is_deprecated := false;
                      ELSE
                          internal_error('Invalid ' || prop_filename ||
                              ' line due to unknown attribute while processing: ' || 
                              props_line);
                      END IF;
                  END IF;
              END IF;

          EXCEPTION WHEN no_data_found THEN
              utl_file.fclose(props_file);
              EXIT;
          END;
      END LOOP;
  EXCEPTION WHEN invalidFileOperation THEN
      internal_error('Cannot open the ' || prop_filename ||
          ' from the directory object preupgrade_dir');
      RAISE;
END analyze_params;


PROCEDURE init_parameters
IS
  p_name  SYS.V$PARAMETER.NAME%TYPE;
  p_type  SYS.V$PARAMETER.TYPE%TYPE;
  p_value SYS.V$PARAMETER.VALUE%TYPE;
  p_isdefault SYS.V$PARAMETER.ISDEFAULT%TYPE;
  p_isspecified SYS.V$SPPARAMETER.ISSPECIFIED%TYPE; 
  parameter_record parameter_record_t;
  param_cursor cursor_t;
  t_null CHAR(1);
BEGIN
 -- Adding an outer join to v$spparameter to 1) read isspecified column to know if a given parameter is in the spfile and 2) consider v$parameter as the complete list of parameters (some may not be present in the v$sppfile). 
  OPEN param_cursor FOR 'select distinct vp.name, vp.type, vp.value,vp.isdefault, nvl(vsp.isspecified,''NOSPF'') is_spspecified
                         from sys.v$parameter vp left outer join sys.v$spparameter vsp on vp.name=vsp.name 
                         and (vsp.sid=''*'' or vsp.sid in (select instance_name from v$instance) ) order by name';
  LOOP
    FETCH param_cursor INTO p_name, p_type, p_value, p_isdefault,p_isspecified;
    EXIT WHEN param_cursor%NOTFOUND;

    -- parameter_record := new parameter_record_t;
    -- parameter_record.name := p_name;
    -- parameter_record.type := p_type;
    -- parameter_record.value := p_value;
    -- all_parameters(p_name) := parameter_record;
    all_parameters(p_name).name := p_name;
    all_parameters(p_name).type := p_type;
    all_parameters(p_name).value := p_value;
    all_parameters(p_name).isdefault := p_isdefault;
    all_parameters(p_name).isspecified := p_isspecified;

    IF debug THEN
        dbms_output.put_line('source database has parameter: ' || p_name || '(' || p_type || ')=' || p_value);
    END IF;

  END LOOP;

  analyze_params();

  -- Sessions removed for XE upgrade only
  IF db_is_XE THEN
      IF all_parameters.exists('sessions') THEN
          all_parameters('sessions').is_obsoleted := true;
      END IF;
  END IF;


  --
  -- Load Renamed parameters
  --

  -- Initialization Parameters Renamed in Release 8.0 --
  store_renamed_param('async_read','disk_asynch_io');
  store_renamed_param('async_write','disk_asynch_io');
  store_renamed_param('ccf_io_size','db_file_direct_io_count');
  store_renamed_param('db_file_standby_name_convert','db_file_name_convert');
  store_renamed_param('db_writers','dbwr_io_slaves');
  store_renamed_param('log_file_standby_name_convert',
                    'log_file_name_convert');
  store_renamed_param('snapshot_refresh_interval','job_queue_interval');

  -- Initialization Parameters Renamed in Release 8.1.4 --
  store_renamed_param('mview_rewrite_enabled','query_rewrite_enabled');
  store_renamed_param('rewrite_integrity','query_rewrite_integrity');

  -- Initialization Parameters Renamed in Release 8.1.5 --
  store_renamed_param('nls_union_currency','nls_dual_currency');
  store_renamed_param('parallel_transaction_recovery',
                    'fast_start_parallel_rollback');

  -- Initialization Parameters Renamed in Release 9.0.1 --
  store_renamed_param('fast_start_io_target','fast_start_mttr_target');
  store_renamed_param('mts_circuits','circuits');
  store_renamed_param('mts_dispatchers','dispatchers');
  store_renamed_param('mts_max_dispatchers','max_dispatchers');
  store_renamed_param('mts_max_servers','max_shared_servers');
  store_renamed_param('mts_servers','shared_servers');
  store_renamed_param('mts_sessions','shared_server_sessions');
  store_renamed_param('parallel_server','cluster_database');
  store_renamed_param('parallel_server_instances',
                    'cluster_database_instances');

  -- Initialization Parameters Renamed in Release 9.2 --
  store_renamed_param('drs_start','dg_broker_start');

  -- Initialization Parameters Renamed in Release 10.1 --
  store_renamed_param('lock_name_space','db_unique_name');

  -- Initialization Parameters Renamed in Release 10.2 --
  -- none as of 4/1/05

  -- Initialization Parameters Renamed in Release 11.2 --

  store_renamed_param('buffer_pool_keep', 'db_keep_cache_size');
  store_renamed_param('buffer_pool_recycle', 'db_recycle_cache_size');
  store_renamed_param('commit_write', 'commit_logging,commit_wait');

  -- Initialization Parameters Renamed in Release 12.2 --
  store_renamed_param('_db_new_lost_write_protect',
                    '_db_shadow_lost_write_protect'); 
  --
  -- Initialize special initialization parameters
  --

  store_renamed_param_and_value('rdbms_server_dn',NULL,
                'ldap_directory_access','SSL');
  store_renamed_param_and_value('plsql_debug','TRUE',
                'plsql_optimize_level','1');

  --  Only use these special parameters for databases
  --  in which Very Large Memory is not enabled

  IF NOT db_VLM_enabled THEN
      store_renamed_param_and_value('db_block_buffers',NULL,
                  'db_cache_size',NULL);
      store_renamed_param_and_value('buffer_pool_recycle',NULL,
                  'db_recycle_cache_size',NULL);
      IF all_parameters.exists('db_block_buffers') THEN
          all_parameters('db_block_buffers').is_obsoleted := true;
      END IF;
      IF all_parameters.exists('buffer_pool_keep') THEN
          all_parameters('buffer_pool_keep').is_obsoleted := true;
      END IF;
  END IF;

  --
  -- for 12.1, AUDIT_TRAIL has deprecated several values
  -- that were allowed for AUDIT_TRAIL, they have new
  -- mappings.
  -- Use store_renamed_param_and_value  - bug  2631483 and set the
  -- dbua_outInUpdate flag so output_xml_initparams
  -- dumps these out
  --
  store_renamed_param_and_value('audit_trail','FALSE',
                    'audit_trail','NONE');
  store_renamed_param_and_value('audit_trail','TRUE',
                    'audit_trail','DB');
  store_renamed_param_and_value('audit_trail','DB_EXTENDED',
                    'audit_trail','DB,EXTENDED');


  --
  -- Min value for db_block_size
  --
  --store_required ('db_block_size', 2048, '', 3);

  --IF db_n_version = 102 THEN
    -- If undo_management is not specified in pre-11g database, then
    -- it needs to be specified MANUAL since the default is changing
    -- from MANUAL to AUTO starting in 11.1.
    -- store_required('undo_management', 0, 'MANUAL', 2);
  --END IF;

  -- for now, just compute memory recommendations for upgrades
  -- for non-cdb and ROOT.
  -- i.e., memory recommendations won't be listed in the
  -- pdb preupgrade_<pdb>.log for now.
  IF db_is_cdb = FALSE OR db_is_root = TRUE THEN
    init_mem_sizes(mem_parameters);
    find_mem_sizes(mem_parameters, is_show_mem_sizes);
  END IF;

  -- find minimum processes value for the upgrade
  find_processes_value();

END init_parameters;

--
--    The following couple of functions are used in the computation of
--    tablespace info
--
-------------------------- ts_has_queues ---------------------------------
-- returns TRUE if there is at least one queue in the tablespace
FUNCTION ts_has_queues (tsname VARCHAR2) RETURN BOOLEAN
IS
BEGIN
    RETURN select_has_rows('SELECT NULL FROM sys.dba_tables t
      WHERE EXISTS (SELECT 1 FROM sys.dba_queues q
         WHERE q.queue_table = t.table_name AND q.owner = t.owner)
      AND t.tablespace_name = '''||tsname||''' AND rownum <= 1');
END ts_has_queues;

-------------------------- ts_is_SYS_temporary ---------------------------------
-- returns TRUE if there is at least one queue in the tablespace

FUNCTION ts_is_SYS_temporary (tsname VARCHAR2) RETURN BOOLEAN
IS
BEGIN
    RETURN select_has_rows('SELECT NULL FROM sys.dba_users
        WHERE username = ''SYS''
        AND temporary_tablespace = '''||tsname||'''');
END ts_is_SYS_temporary;

---------------------- SYS_temp_tablespace_is_a_group ----------------------
-- returns TRUE if the given tablespace_name belongs to a group and the
-- group is the default temp tablespace

FUNCTION SYS_temp_tablespace_is_a_group (tsname VARCHAR2) RETURN BOOLEAN
IS
  flag          NUMBER;
BEGIN
   SELECT count(a.TEMPORARY_TABLESPACE) into flag
   FROM DBA_USERS A, DBA_TABLESPACE_GROUPS  B
   WHERE UPPER(USERNAME)='SYS'
   and a.TEMPORARY_TABLESPACE=B.GROUP_NAME
   and b.TABLESPACE_NAME=''||tsname||'';  
 
    -- true means temp ts belongs to the sys default temp ts group
    IF flag != 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END SYS_temp_tablespace_is_a_group;         


/* 
 *	BMMB BUG 27227129, changing INTEGERS to NUMBER
 */
PROCEDURE init_resources
IS
  idx                 BINARY_INTEGER;
  tmp_cursor          cursor_t;
  tmp_num1            NUMBER;
  tmp_num2            NUMBER;
  delta_queues        NUMBER;
  delta_kbytes        NUMBER := 0;
  p_tsname            VARCHAR2(128);
  tmp_varchar1        VARCHAR2(128);
  tmp_varchar2        VARCHAR2(128);
  tmp_filename        SYS.DBA_TEMP_FILES.FILE_NAME%TYPE;
  p_status            VARCHAR2(30);
  sum_bytes           NUMBER;
  default_tablespaces VARCHAR2(4000);
  name                VARCHAR2(128);
  contents            VARCHAR2(128);
  temporary           BOOLEAN;
  localmanaged        BOOLEAN;
  inuse               NUMBER;
  alloc               NUMBER;
  auto                NUMBER;
  avail               NUMBER;
  query               VARCHAR2(4000);
  deftmpts            VARCHAR2(30);
  deftsisgroup        VARCHAR2(5);
  grpsz_kb            NUMBER;
  c_temp_minsz        NUMBER;
BEGIN
  --
  -- Misc stand-alone values we report about
  --
  pMinFlashbackLogGen  := 0;
  pminArchiveLogGen    := 0;

  idx := 0;

  -- we know we need SYSTEM and SYSAUX in the list of tablespaces anyway, add 'em now.
  default_tablespaces := '''SYSTEM'', ''SYSAUX''';

  FOR i in 1..cmp_info.count LOOP
      IF (cmp_info(i).def_ts is not null) THEN
          -- there is not a worry about overflowing default_tablespaces or sql injection.  The values we pull from .def_ts
          -- are all hardcoded in this program, and as a result, we could just hardcode default_tablespaces too, but to
          -- make room for smooth changes in the future, this loop guarantees we pick up new def_ts's.  The current list
          -- as of 12.1.0.2 is only 'SYSTEM', 'SYSAUX'.

          -- push a new tablespace onto the list only if it doesn't exist on the list already
          IF (instr(default_tablespaces,'''' || cmp_info(i).def_ts || '''') = 0) THEN
              default_tablespaces := default_tablespaces || ',''' || cmp_info(i).def_ts || '''';
          END IF;
      END IF;
  END LOOP;

  -- Get temporary tablespace for SYS.
  SELECT TEMPORARY_TABLESPACE INTO deftmpts
  FROM DBA_USERS A
  WHERE UPPER(USERNAME)='SYS';

  -- Determine if tablespace is part of a tablespace group?
  SELECT DECODE(COUNT(1), 0,'NO','YES') INTO deftsisgroup
  FROM DBA_TABLESPACE_GROUPS
  WHERE GROUP_NAME=''||deftmpts||'';

  -- Temporary tablespace comes from a TS group
  IF deftsisgroup='YES' THEN
    -- Is the sum of the temp ts enough?
    select sum(b.bytes)/c_kb into grpsz_kb
    from dba_tablespace_groups a join dba_temp_files b
    on(a.tablespace_name=b.tablespace_name)
    where group_name=''||deftmpts||'';

    IF grpsz_kb >= c_temp_minsz_kb THEN
        -- size in bytes
        c_temp_minsz := grpsz_kb * c_kb;
        -- we have enough temp tablespace
       query := 'with 
       segments as (
         select  ds.tablespace_name, 
                 round(nvl(sum(ds.bytes) ,0)/:a,2)                                     as inuse 
         from sys.dba_segments ds
         group by ds.tablespace_name 
         ),
       tmp_tsgrp as (
         select group_name, tablespace_name, '||c_temp_minsz||' bytes, maxbytes
         from (
           select   a.group_name, a.tablespace_name, b.bytes, b.maxbytes,
                    rank() over (partition by a.group_name order by b.bytes desc) rnk
           from dba_tablespace_groups a join dba_temp_files b
           on(a.tablespace_name=b.tablespace_name)
            )
         WHERE rnk = 1 and rownum = 1
         ),
       ts_qresult as (
           SELECT dt.tablespace_name                                                   as name,
                  dt.contents                                                          as contents,
                  decode(dt.contents,''TEMPORARY'',1,0)                                as temporary,
                  decode(dt.extent_management,''LOCAL'',1,0)                           as localmanaged,
                  nvl(ds.inuse,0)                                                      as inuse,
                  nvl(round(sum(case dt.contents when ''TEMPORARY'' then 
                           dtf.bytes  
                     else  ddf.bytes end)/:b, 2),0)                                    as alloc, 
                  nvl(round(sum(case dt.contents when  ''TEMPORARY'' then 
                          decode(dtf.maxbytes, 0, 0, dtf.maxbytes-dtf.bytes)
                  else decode(ddf.maxbytes, 0, 0, ddf.maxbytes-ddf.bytes)end)/:c,2),0) as auto
           FROM   sys.dba_tablespaces    dt 
           left join segments            ds on(dt.tablespace_name=ds.tablespace_name)
           left join sys.dba_data_files ddf on(ddf.tablespace_name=dt.tablespace_name)
           left join tmp_tsgrp          dtf on(dtf.tablespace_name=dt.tablespace_name)
           WHERE   (dt.tablespace_name in (:d,' || default_tablespaces || '))
           or      (dt.tablespace_name in (  SELECT distinct T.tablespace_name 
                                         FROM sys.dba_queues Q, sys.dba_tables T 
                                         WHERE Q.queue_table=T.table_name AND 
                                         Q.owner = T.owner)) 
           or      (dtf.group_name = '''||deftmpts||''')
           group by    dt.tablespace_name,
                       dt.contents,
                       dt.extent_management,
                       ds.inuse
           )
       select tq.name, tq.contents, tq.temporary, tq.localmanaged, tq.inuse, tq.alloc, tq.auto, tq.alloc+tq.auto avail 
       from ts_qresult tq order by tq.name';
    ELSE
        -- we need to increase one temp tablespace
       query := 'with 
       segments as (
         select  ds.tablespace_name, 
                 round(nvl(sum(ds.bytes) ,0)/:a,2)                                     as inuse 
         from sys.dba_segments ds
         group by ds.tablespace_name 
         ),
       tmp_tsgrp as (
         select group_name, tablespace_name, bytes, maxbytes
         from (
           select   a.group_name, a.tablespace_name, b.bytes, b.maxbytes,
                    rank() over (partition by a.group_name order by b.bytes desc) rnk
           from dba_tablespace_groups a join dba_temp_files b
           on(a.tablespace_name=b.tablespace_name)
            )
         WHERE rnk = 1 and rownum = 1
         ),
       ts_qresult as (
           SELECT dt.tablespace_name                                                   as name,
                  dt.contents                                                          as contents,
                  decode(dt.contents,''TEMPORARY'',1,0)                                as temporary,
                  decode(dt.extent_management,''LOCAL'',1,0)                           as localmanaged,
                  nvl(ds.inuse,0)                                                      as inuse,
                  nvl(round(sum(case dt.contents when ''TEMPORARY'' then 
                           dtf.bytes  
                     else  ddf.bytes end)/:b, 2),0)                                    as alloc, 
                  nvl(round(sum(case dt.contents when  ''TEMPORARY'' then 
                          decode(dtf.maxbytes, 0, 0, dtf.maxbytes-dtf.bytes)
                  else decode(ddf.maxbytes, 0, 0, ddf.maxbytes-ddf.bytes)end)/:c,2),0) as auto
           FROM   sys.dba_tablespaces    dt 
           left join segments            ds on(dt.tablespace_name=ds.tablespace_name)
           left join sys.dba_data_files ddf on(ddf.tablespace_name=dt.tablespace_name)
           left join tmp_tsgrp          dtf on(dtf.tablespace_name=dt.tablespace_name)
           WHERE   (dt.tablespace_name in (:d,' || default_tablespaces || '))
           or      (dt.tablespace_name in (  SELECT distinct T.tablespace_name 
                                         FROM sys.dba_queues Q, sys.dba_tables T 
                                         WHERE Q.queue_table=T.table_name AND 
                                         Q.owner = T.owner)) 
           or      (dtf.group_name = '''||deftmpts||''')
           group by    dt.tablespace_name,
                       dt.contents,
                       dt.extent_management,
                       ds.inuse
           )
       select tq.name, tq.contents, tq.temporary, tq.localmanaged, tq.inuse, tq.alloc, tq.auto, tq.alloc+tq.auto avail 
       from ts_qresult tq order by tq.name';
    END IF;

  ELSE
    query := 'with 
       segments as (
         select  ds.tablespace_name, 
                 round(nvl(sum(ds.bytes) ,0)/:a,2)                                     as inuse 
         from sys.dba_segments ds
         group by ds.tablespace_name 
         ),
       ts_qresult as (
           SELECT dt.tablespace_name                                                   as name,
                  dt.contents                                                          as contents,
                  decode(dt.contents,''TEMPORARY'',1,0)                                as temporary,
                  decode(dt.extent_management,''LOCAL'',1,0)                           as localmanaged,
                  nvl(ds.inuse,0)                                                      as inuse,
                  nvl(round(sum(case dt.contents when ''TEMPORARY'' then 
                           dtf.bytes  
                     else  ddf.bytes end)/:b, 2),0)                                    as alloc, 
                  nvl(round(sum(case dt.contents when  ''TEMPORARY'' then 
                          decode(dtf.maxbytes, 0, 0, dtf.maxbytes-dtf.bytes)
                  else decode(ddf.maxbytes, 0, 0, ddf.maxbytes-ddf.bytes)end)/:c,2),0) as auto
           FROM   sys.dba_tablespaces    dt 
           left join      segments            ds on(dt.tablespace_name=ds.tablespace_name)
           left join sys.dba_data_files ddf on(ddf.tablespace_name=dt.tablespace_name)
           left join sys.dba_temp_files dtf on(dtf.tablespace_name=dt.tablespace_name)
           WHERE   (dt.tablespace_name in (:d,' || default_tablespaces || '))
           or      (dt.tablespace_name in (  SELECT distinct T.tablespace_name 
                                         FROM sys.dba_queues Q, sys.dba_tables T 
                                         WHERE Q.queue_table=T.table_name AND 
                                         Q.owner = T.owner)) 
           or      (dt.tablespace_name = '''||deftmpts||''')
           group by    dt.tablespace_name,
                       dt.contents,
                       dt.extent_management,
                       ds.inuse
           )
       select tq.name, tq.contents, tq.temporary, tq.localmanaged, tq.inuse, tq.alloc, tq.auto, tq.alloc+tq.auto avail 
       from ts_qresult tq order by tq.name';
  END IF;

  OPEN tmp_cursor FOR query USING c_kb, c_kb, c_kb, db_undo_tbs; --:a :b :c :d
  LOOP
      FETCH tmp_cursor INTO name, contents, temporary, localmanaged, inuse, alloc, auto, avail;
      EXIT WHEN tmp_cursor%NOTFOUND;
      idx := idx + 1;
      ts_info(idx).temporary      := temporary;
      ts_info(idx).localmanaged   := localmanaged;
      ts_info(idx).name           := name;
      ts_info(idx).inuse          := inuse;
      ts_info(idx).alloc          := alloc;
      ts_info(idx).auto           := auto;
      ts_info(idx).avail          := avail;
      ts_info(idx).delta          := 0;
      ts_info(idx).inc_by         := 0;
      ts_info(idx).min            := 0;
      ts_info(idx).addl           := 0;
      ts_info(idx).contents       := contents;

      IF debug THEN
        dbms_output.put_line(name || crlf ||
                          '  temp: ' || boolean_string(temporary,'TRUE','FALSE') || crlf ||
                          '  localmanaged: ' || boolean_string(localmanaged,'TRUE', 'FALSE') || crlf ||
                          '  inuse:        ' || to_char(inuse) || crlf ||
                          '  alloc:        ' || to_char(alloc) || crlf ||
                          '  auto:         ' || to_char(auto) || crlf ||
                          '  avail:        ' || to_char(avail) );
      END IF;
  END LOOP;
  CLOSE tmp_cursor;

  -- max_ts := idx;   -- max tablespaces of interest

  -- *****************************************************************
  -- Collect Public Rollback Information
  -- *****************************************************************

  idx := 0;
  IF db_undo != 'AUTO' THEN  -- using rollback segments

    OPEN tmp_cursor FOR 
        'SELECT segment_name, next_extent, max_extents, status FROM SYS.dba_rollback_segs 
            WHERE owner=''PUBLIC'' OR (owner=''SYS'' AND segment_name != ''SYSTEM'')';
    LOOP
      FETCH tmp_cursor INTO tmp_varchar1, tmp_num1, tmp_num2, p_status;
      EXIT WHEN tmp_cursor%NOTFOUND;
      BEGIN
        --- get sum of bytes and tablespace name
        EXECUTE IMMEDIATE 
            'SELECT tablespace_name, sum(bytes) FROM sys.dba_segments 
                WHERE segment_name = :1  AND ROWNUM = 1 GROUP BY tablespace_name' 
        INTO p_tsname, sum_bytes
        USING tmp_varchar1;
        IF sum_bytes < c_kb THEN
          sum_bytes := 1;
        ELSE
          sum_bytes := sum_bytes/c_kb;
        END IF;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        sum_bytes := NULL;
      END;

      IF sum_bytes IS NOT NULL THEN
        idx:=idx + 1;
        rs_info(idx).tbs_name := p_tsname;
        rs_info(idx).seg_name := tmp_varchar1;
        rs_info(idx).status   := p_status;
        rs_info(idx).next     := tmp_num1/c_kb;
        rs_info(idx).max_ext  := tmp_num2;
        rs_info(idx).inuse    := sum_bytes;
        EXECUTE IMMEDIATE 
          'SELECT ROUND(SUM(DECODE(maxbytes, 0, 0,maxbytes-bytes)/:1))
              FROM sys.dba_data_files WHERE tablespace_name=:2'
        INTO rs_info(idx).auto
        USING c_kb, p_tsname;

        EXECUTE IMMEDIATE 
          'SELECT ROUND(SUM(DECODE(maxbytes, 0, 0,maxbytes-bytes)/:1))
              FROM sys.dba_data_files WHERE tablespace_name=:2'
        INTO tmp_num1
        USING c_kb, p_tsname;
      END IF;
    END LOOP;
    CLOSE tmp_cursor;
  END IF;  -- using undo tablespace, not rollback

  -- max_rs := idx;

  -- *****************************************************************
  -- Determine free space needed if
  --   Archiving was on; 
  --   Flashback Database was on
  -- We only report the values if they are actually on.
  -- *****************************************************************

  -- calculate the minimum amount of archive and flashback logs used 
  -- for an upgrade for each component. 
  --
  find_archive_dest_info();
  find_recovery_area_info();

  -- Total recovery area needed is:
  --   pMinArchiveLogGen + pMinFlashbacklogGen;

  -- *****************************************************************
  -- Collect Flashback Information
  -- *****************************************************************

  -- initialize flashback_info
  flashback_info.active := FALSE;
  flashback_info.name := '';
  flashback_info.limit := 0;
  flashback_info.used := 0;
  flashback_info.reclaimable := 0;
  flashback_info.files := 0; 
  flashback_info.file_dest := '';
  flashback_info.dsize := 0;

  flashback_info.active := db_flashback_on;  -- is flashback active? T/F
  
  -- is fast recovery area set?
  -- note: fast recovery area can be set without flashback being turned on
  IF db_fra_set = TRUE THEN
    --
    -- Get the rest of the flashback settings
    -- 

    BEGIN
      EXECUTE IMMEDIATE 'SELECT rfd.name, rfd.space_limit, rfd.space_used, 
                  rfd.space_reclaimable, rfd.number_of_files,
                  vp1.value, vp2.value 
        FROM v$recovery_file_dest rfd, v$parameter vp1, v$parameter vp2
        WHERE UPPER(vp1.name) = ''DB_RECOVERY_FILE_DEST'' AND
               UPPER(vp2.name) = ''DB_RECOVERY_FILE_DEST_SIZE'''
       INTO flashback_info.name, flashback_info.limit, flashback_info.used,
              flashback_info.reclaimable, flashback_info.files, 
              flashback_info.file_dest, flashback_info.dsize;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN flashback_info.active := FALSE;
    END;
  END IF;

  -- *****************************************************************
  -- Calculate Tablespace Requirements
  -- *****************************************************************

  -- Look at all relevant tablespaces
  -- TS: loop per tablespace (ts_info(t).name)
  FOR t IN 1..ts_info.count LOOP
    delta_kbytes:=0;   -- initialize calculated tablespace delta

    IF ts_info(t).name = 'SYSTEM' THEN -- sum the component SYS kbytes
      FOR i IN 1..cmp_info.count LOOP

        IF pDBGSizeResources THEN
          IF cmp_info(i).processed THEN
            DisplayDiagLine (cmp_info(i).cid || ' Processed. ' || ' Default Tblspace ' || cmp_info(i).def_ts || '.');
          ELSE
            DisplayDiagLine (cmp_info(i).cid || ' NOT Processed.');
          END IF;
        END IF;

        IF cmp_info(i).processed THEN
          IF cmp_info(i).install THEN  -- if component will be installed
            delta_kbytes := delta_kbytes + cmp_info(i).ins_sys_kbytes;
            IF pDBGSizeResources THEN
              DisplayDiagLine ('SYSTEM ' || 
                  LPAD(cmp_info(i).cid, 10) || ' ToBeInstalled ' ||
                  LPAD(cmp_info(i).ins_sys_kbytes/c_kb,10) || 'Mb'); 
            END IF;
          ELSE  -- if component is already in the registry
            delta_kbytes := delta_kbytes + cmp_info(i).sys_kbytes;
            IF pDBGSizeResources THEN
              DisplayDiagLine ('SYSTEM ' || 
                     LPAD(cmp_info(i).cid, 10) || ' IsInRegistry ' ||
                     LPAD(cmp_info(i).sys_kbytes/c_kb,10) || 'Mb');
            END IF;
          END IF;
        END IF;  -- nothing to add if component is or will not be in
                 -- the registry
      END LOOP;

    END IF;  -- end of special SYSTEM tablespace processing
    -- TS: delta after looping through components in SYSTEM

    IF ts_info(t).name = 'SYSAUX' THEN -- sum the component SYSAUX kbytes
      FOR i IN 1..cmp_info.count LOOP
        IF cmp_info(i).processed AND
              (cmp_info(i).def_ts = 'SYSAUX' OR
               cmp_info(i).def_ts = 'SYSTEM') THEN
          IF cmp_info(i).sysaux_kbytes >= cmp_info(i).def_ts_kbytes THEN
            delta_kbytes := delta_kbytes + cmp_info(i).sysaux_kbytes;
          ELSE
            delta_kbytes := delta_kbytes + cmp_info(i).def_ts_kbytes;
          END IF;
          IF pDBGSizeResources THEN
            DisplayDiagLine('SYSAUX ' || 
                   LPAD(cmp_info(i).cid, 10) || ' ' ||
                   LPAD(cmp_info(i).sysaux_kbytes/c_kb,10) || 'Mb');
          END IF;
        END IF;
      END LOOP;
    END IF;  -- end of special SYSAUX tablespace processing
    -- TS: sum delta for components in SYSAUX

    -- For tablespaces that are not SYSTEM:
    -- For tablespaces that are not SYSAUX:
    -- For tablespaces that are not UNDO:
    -- Now add in component default tablespace deltas
    -- def_tablespace_name is NULL for unprocessed comps

    IF (ts_info(t).name != 'SYSTEM' AND
        ts_info(t).name != 'SYSAUX' AND
        ts_info(t).name != db_undo_tbs) THEN
      FOR i IN 1..cmp_info.count LOOP 
        IF (ts_info(t).name = cmp_info(i).def_ts AND
           cmp_info(i).processed) THEN
          IF cmp_info(i).install THEN  -- use install amount
            delta_kbytes := delta_kbytes + cmp_info(i).ins_def_kbytes;
            IF pDBGSizeResources THEN
              DisplayDiagLine( RPAD(ts_info(t).name, 10) ||
                           LPAD(cmp_info(i).cid, 10) || ' ' ||
                           LPAD(cmp_info(i).ins_def_kbytes,10));   
            END IF;

          ELSE  -- use default tablespace amount
            -- note: this section is for space calculations for
            -- tablespaces that are non-system and non-sysaux
            delta_kbytes :=  delta_kbytes + cmp_info(i).def_ts_kbytes;

            IF pDBGSizeResources THEN
              DisplayDiagLine(RPAD(ts_info(t).name, 10) ||
                      LPAD(cmp_info(i).cid, 10) || ' ' ||
                      LPAD(cmp_info(i).def_ts_kbytes/c_kb, 10) || 'Mb');
              --update_puiu_data('SCHEMA', 
              --   ts_info(t).name || '-' || cmp_info(i).schema,
              --   cmp_info(i).def_ts_kbytes);
            END IF;
          END IF;
        END IF;
      END LOOP; -- end of default tablespace calculations 
    END IF; -- end of if tblspace is not undo and not sysaux and not system
            -- then add in component default tablespace deltas

    -- TS: sum delta for install in default tablespaces other than
    --          SYSAUX

    -- For tablespaces that are not undo:
    -- Now look for queues in user schemas
    IF ts_info(t).name != db_undo_tbs THEN
      EXECUTE IMMEDIATE 'SELECT count(*) FROM sys.dba_tables tb, sys.dba_queues q
          WHERE q.queue_table = tb.table_name AND
               tb.tablespace_name = '' || ts_info(t).name || '' AND tb.owner NOT IN
                (''SYS'',''SYSTEM'',''MDSYS'',''ORDSYS'',''OLAPSYS'',''XDB'',
                ''LBACSYS'',''CTXSYS'',''ODM'',''DMSYS'', ''WKSYS'',''WMSYS'',
                 ''SYSMAN'',''EXFSYS'') '
      INTO delta_queues;

      IF delta_queues > 0 THEN
        delta_kbytes := delta_kbytes + delta_queues*48; 
        IF pDBGSizeResources THEN
          DisplayDiagLine(RPAD(ts_info(t).name, 10) ||
                  ' QUEUE count = ' || delta_queues);
        END IF;
      END IF;
    END IF;  -- end of if tablespace is not undo
             -- then look for queues in user schemas

    -- See if this is the temporary tablespace for SYS
    IF ts_is_SYS_temporary(ts_info(t).name) THEN
        -- setting the minimum amount for the sys temp tablespace
        delta_kbytes := c_temp_minsz_kb;
    END IF;

    -- check if sys ts belongs to a group
    IF SYS_temp_tablespace_is_a_group(ts_info(t).name) THEN
        -- setting the minimum amount for the sys temp tablespace
        -- which is the group
        delta_kbytes := c_temp_minsz_kb;
    END IF;

    -- See if this is the UNDO tablespace - be sure at least
    -- 400M (or c_undo_minsz_kb) is available
    IF ts_info(t).name = db_undo_tbs THEN
      ts_info(t).min := c_undo_minsz_kb;
      IF ts_info(t).alloc < ts_info(t).min THEN
        delta_kbytes := ts_info(t).min - ts_info(t).inuse;
      ELSE
        delta_kbytes := 0;
      END IF;
    END IF;  -- end of if this is the undo tablespace


    -- Put a 20% safety factor on DELTA and round it off
    delta_kbytes := ROUND(delta_kbytes*1.20);            

    -- Finally, save DELTA value
    ts_info(t).delta := delta_kbytes;

    -- Calculate here the recommendation for minimum tablespace size - it is
    -- the "delta" plus existing in use amount IF tablespace is not undo.
    -- Else if tablespace is undo, then minimum was already set above
    -- to 400M (or c_undo_minsz_kb); therefore no need to calculate here.

    -- calculate ts_info(t).min
    IF ts_info(t).name != db_undo_tbs THEN
      -- calculate minimum tablespace size IF tablespace is NOT undo
      ts_info(t).min := ts_info(t).inuse + ts_info(t).delta;

      -- See if this is the SYSAUX tablespace - be sure at least 500M allocated
      IF ts_info(t).name = 'SYSAUX' THEN
        IF ts_info(t).min < c_sysaux_minsz_kb THEN
          ts_info(t).min := c_sysaux_minsz_kb;
        END IF;
      END IF;  -- end of checking that the minimum required space for SYSAUX
               -- is at least 500Mb (or c_sysaux_minsz_kb)

    END IF;  -- end of calculate ts_info(t).min 

    -- convert to MB and round up(min required)/down (alloc,avail,inuse)
    ts_info(t).min :=   CEIL(ts_info(t).min/c_kb);
    ts_info(t).alloc := ROUND((ts_info(t).alloc+511)/c_kb);
    ts_info(t).avail := ROUND((ts_info(t).avail-512)/c_kb);
    ts_info(t).inuse := ROUND((ts_info(t).inuse)/c_kb);

    -- Determine amount of additional space needed
    -- independent of autoextend on/off
    --

    IF ts_info(t).min > ts_info(t).alloc THEN
      ts_info(t).addl  := ts_info(t).min - ts_info(t).alloc;
    ELSE
      ts_info(t).addl := 0;
    END IF;

    -- Do we have enough space in the existing tablespace?
    IF ts_info(t).min <= ts_info(t).avail  THEN
      ts_info(t).inc_by := 0;
    ELSE
       -- need to add space
       ts_info(t).inc_by := ts_info(t).min - ts_info(t).avail; 

    END IF;

    IF debug THEN
      dbms_output.put_line(crlf || '*' || ts_info(t).name || crlf ||
                        '  temp: ' || boolean_string(ts_info(t).temporary,'TRUE','FALSE') || crlf ||
                        '  localmanaged: ' || boolean_string(ts_info(t).localmanaged,'TRUE', 'FALSE') || crlf ||
                        '  inuse:        ' || to_char(ts_info(t).inuse) || crlf ||
                        '  alloc:        ' || to_char(ts_info(t).alloc) || crlf ||
                        '  auto:         ' || to_char(ts_info(t).auto) || crlf ||
                        '  avail:        ' || to_char(ts_info(t).avail) || crlf ||
                        '  min:          ' || to_char(ts_info(t).min) || crlf ||
                        '  inc_by:       ' || to_char(ts_info(t).inc_by) || crlf ||
                        '  addl:         ' || to_char(ts_info(t).addl) );
    END IF;

    -- Find at least one file in the tablespace with autoextend on.
    -- If found, then that tablespace has autoextend on; else not on.
    -- DBUA will use this information to add to autoextend
    -- or to check for total space on disk
    --
    IF ts_info(t).temporary THEN
       tmp_varchar2 := 'DBA_TEMP_FILES';
    ELSE
       tmp_varchar2 := 'DBA_DATA_FILES';
    END IF;
    BEGIN
       EXECUTE IMMEDIATE 'SELECT FILE_NAME FROM ' || tmp_varchar2 ||
                      ' WHERE TABLESPACE_NAME = :1 
                        AND AUTOEXTENSIBLE = ''YES''
                        AND ROWNUM=1'
       INTO tmp_filename USING ts_info(t).name;
       ts_info(t).fname := tmp_filename;
       ts_info(t).fauto := TRUE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
       ts_info(t).fauto := FALSE;
    END;

    -- once the joins were done if the sys temp ts belong
    -- to a group rename it to the group's name
    IF SYS_temp_tablespace_is_a_group(ts_info(t).name) THEN
        ts_info(t).name := 'TMP_GROUP['|| deftmpts||']';
    END IF;

  END LOOP;  -- end of tablespace loop

END init_resources;


-- ****************************************************************************
-- if run from the root, return total # of pdbs (including seed) in the cdb
-- if run from the pdb, then return 1
-- if this db is not a cdb or # of pdbs cannot be found, then return 0
-- note: we are just returning the total # of pdbs as see from v$pdbs
--       i.e., for now, not looking at status, etc of the pdbs 
-- ****************************************************************************
FUNCTION get_npdbs RETURN NUMBER
IS
  nPdbs   NUMBER := 0;
  e_noTblFound EXCEPTION;   -- ORA-00942: table or view does not exist
  PRAGMA exception_init(e_noTblFound, -942);
BEGIN
  begin
    execute immediate
      'select count(*) from sys.v$pdbs'
      into nPdbs;
  exception
    WHEN e_noTblFound THEN nPdbs := 0;
  end;

  return nPdbs;
END get_npdbs;


-- ****************************************************************************
-- init_mem_sizes
-- This is called from init_parameters
-- We're here because we need to initialize min values for memory sizes
-- for upgrade.
-- Note: For cdb upgrades, we are sizing for:
--       a) default -n and -N of catctl.pl 
--       b) as if all the pdbs will be upgraded with the root
-- Note: Only display memory sizing recommendations for non-cdb and ROOT, not
--       PDBs.
-- ****************************************************************************
PROCEDURE init_mem_sizes (memvp IN OUT MEMPARAMETER_TABLE_T)
IS
  minvalue    NUMBER;  -- minimum value to set
  pdbs_para   NUMBER;  -- at most # of pdbs upgrading in parallel at a time
  pdb_batches NUMBER;  -- approximate # of pdb upgrade "cycles"
  name_idx    V$PARAMETER.NAME%TYPE;
  numa_pool   NUMBER;  -- may or may not exist in the sga.  in bytes.
BEGIN
  
  BEGIN
    -- create mem_parameters records and initialize the min values to 0MB
    -- note: although we are not making minium recommendations for large pool
    --       and stream pool, we still need their values (if user-set) for
    --       sga_target calculation
  
    store_memparam_record(cs_idx, 0, memvp);  -- db_cache_size
    store_memparam_record(jv_idx, 0, memvp);  -- java_pool_size
    store_memparam_record(sp_idx, 0, memvp);  -- shared_pool_size
    store_memparam_record(lp_idx, 0, memvp);  -- large_pool_size
    store_memparam_record(sr_idx, 0, memvp);  -- streams_pool_size
    store_memparam_record(pt_idx, 0, memvp);  -- pga_aggregate_target
    store_memparam_record(st_idx, 0, memvp);  -- sga_target
    store_memparam_record(mt_idx, 0, memvp);  -- memory_target
  END;

  -- db_cache_size
  memvp(cs_idx).min_value := 48 * c_mb;

  -- streams_pool_size
  memvp(sr_idx).min_value := 0;  -- 0M

  -- numa pool
  numa_pool := 0;
  BEGIN
    execute immediate 'select sum(bytes) from v$sgastat
                         where pool=''numa pool'' group by pool'
                      into numa_pool;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN numa_pool := 0;
    WHEN OTHERS THEN RAISE;
  END;

  IF db_is_cdb = FALSE THEN  -- this db is a non-cdb

    -- large pool size
    memvp(lp_idx).min_value := 8 * c_mb;

    -- java_pool_size (96M seen but will use 112M, seen in ROOT)
    memvp(jv_idx).min_value := 112 * c_mb;

    -- shared_pool_size
    -- (RTI 18990952 [lrgcu44bdbua]: 472M shared pool was not enough on
    --  AIX.PPC64 upgrading 11.2.0.4 to 12.2. 660M worked.)
    memvp(sp_idx).min_value := (264 * 2.5) * c_mb;  -- 660Mb

    -- pga_aggregate_target
    memvp(pt_idx).min_value := 64 * c_mb;

  ELSE  -- IF db is a cdb

    pdbs_para := num_pdbs_upg_in_parallel();
    pdb_batches := num_pdb_batches_upg(pdbs_para);

    -- large pool size
    memvp(lp_idx).min_value := 64 * c_mb;

    -- java pool
    IF pdbs_para = 1 THEN
      -- ROOT needs 112M while 1 PDB upgrading at a time can use less (at 64M).
      -- if only 1 PDB in a batch, then the bigger value is needed.
      memvp(jv_idx).min_value := 112 * c_mb;
    ELSE
      -- 64M per pdb upgrading in a batch + fudge
      memvp(jv_idx).min_value := ((64 * pdbs_para) + 16) * c_mb;
    END IF;

    -- shared pool
    memvp(sp_idx).min_value := 
      ((264 * 2.5) + ((pdbs_para - 1) * 120) + (db_n_pdbs * 3)) * c_mb;
    --  constant in con id 1 + reserve per pdb upgrade
    -- + reserve for upgraded pdbs that can be mounted or left opened if errors

    -- pga_aggregate_target
    IF pdbs_para = 1 THEN
      -- same as non-cdb
      memvp(pt_idx).min_value := 64 * c_mb;
    ELSE
      memvp(pt_idx).min_value := 320 * c_mb;
    END IF;

  END IF;  -- IF db is a cdb

  memvp(st_idx).min_value :=
    memvp(cs_idx).min_value + memvp(jv_idx).min_value +
    memvp(sp_idx).min_value + memvp(lp_idx).min_value +
    memvp(sr_idx).min_value + numa_pool;

  memvp(mt_idx).min_value :=
    memvp(cs_idx).min_value + memvp(jv_idx).min_value +
    memvp(sp_idx).min_value + memvp(lp_idx).min_value +
    memvp(sr_idx).min_value + memvp(pt_idx).min_value + numa_pool;

END init_mem_sizes;


--------------------------- find_mem_sizes ------------------------------
-- Find minimum sizes for memory parameters needed for upgrades.
-- IN/OUT: memory_parameters => memvp
-- IN/OUT: is_show_mem_sizes => display_min_mem_sizes
--
PROCEDURE find_mem_sizes (memvp                 IN OUT MEMPARAMETER_TABLE_T,
                          display_min_mem_sizes IN OUT BOOLEAN)
IS
  is_db_noncdb  BOOLEAN;      -- is db a non-cdb?  TRUE if yes/FALSE if not
  name_idx      V$PARAMETER.NAME%TYPE;
  mtgval        NUMBER;       -- memory target value
BEGIN
 
  IF db_is_cdb = TRUE THEN
    is_db_noncdb := FALSE;
  ELSE
    is_db_noncdb := TRUE;
  END IF;

  -- For 11.1 and up check if MEMORY_TARGET is set and NON-ZERO 
  -- 
  -- check sga_target + pga_target (for cases where SGA_TARGET is in use)
  --
  -- memory_target in use
  -- if memory_target's oldvalue is not 0, then...
  IF memvp(mt_idx).old_value != 0 THEN
    find_sga_mem_values(memvp);

    -- If the newvalue is greater than the old value set the display TRUE
    IF memvp(mt_idx).new_value > memvp(mt_idx).old_value THEN
      memvp(mt_idx).display := TRUE;

      -- need to add extra memory or db may not start in new release due to:
      -- ORA-00838: Specified value of MEMORY_TARGET is too small...
      memvp(mt_idx).new_value := memvp(mt_idx).new_value + (256 * c_mb);

      IF (memvp(st_idx).old_value != 0) THEN -- SGA_TARGET in use
        -- compute 'newvalue' (new derived minimum) based on user-set sga_target
        -- and user-set pga_aggregate_target.
        -- for memory_target if sga_target is also set.
        -- add extra memory to ensure db will open in new release.
        -- set 'newvalue' to larger of the two new derived minimums (see above).
        mtgval := memvp(st_idx).old_value + memvp(pt_idx).old_value + 128*c_mb;
        IF (mtgval > memvp(mt_idx).new_value) THEN
          memvp(mt_idx).new_value := mtgval;
        END IF;
      END IF;

    END IF;
    -- end of mt_idx

    -- Loop through other pool sizes to ignore warnings
    --
    -- If a minimum value is required for MEMORY_TARGET then
    -- do not output a minimum value for sga_target, pga_aggregate_target,
    -- shared_pool_size, java_pool_size, db_cache_size, 
    -- large_pool_size, and streams_pool_size as these values
    -- are no longer considered once MEMORY_TARGET value is set.
    -- i.e., for params listed above, set display to FALSE if memory_target
    -- is set.
    --
    -- do not replace memory_target's newvalue with minvalue
    name_idx := memvp.first;
    WHILE name_idx IS NOT NULL LOOP
      IF (memvp(name_idx).name
            NOT IN (mt_idx,st_idx,pt_idx,sp_idx,jv_idx,cs_idx,lp_idx,sr_idx))
         AND
         (memvp(name_idx).old_value IS NULL
            OR memvp(name_idx).old_value < memvp(name_idx).min_value)
      THEN
        memvp(name_idx).display := TRUE;
        memvp(name_idx).new_value := memvp(name_idx).min_value;
      END IF;
      name_idx := memvp.next(name_idx);
    END LOOP;     

  ELSIF memvp(st_idx).old_value != 0 THEN  -- SGA_TARGET in use
    find_sga_mem_values(memvp);

    IF memvp(st_idx).new_value > memvp(st_idx).old_value THEN
      memvp(st_idx).display := TRUE;

      -- need to add extra memory or db may not start in new release due to:
      -- ORA-00821: Specified value of sga_target <value> is too small,
      memvp(st_idx).new_value := memvp(st_idx).new_value + (128 * c_mb);
    END IF;

    -- do not set display to TRUE for these params:
    --   memory_target, db_cache_size, java_pool_size,
    --   shared_pool_size, large_poolsize, and streams_pool_size
    -- do not replace sga_target's newvalue with minvalue
    name_idx := memvp.first;
    WHILE name_idx IS NOT NULL LOOP
      IF (memvp(name_idx).name
            NOT IN (st_idx,mt_idx,cs_idx,jv_idx,sp_idx,lp_idx,sr_idx))
         AND 
         (memvp(name_idx).old_value IS NULL
            OR memvp(name_idx).old_value < memvp(name_idx).min_value)
      THEN
        memvp(name_idx).display := TRUE;
        memvp(name_idx).new_value := memvp(name_idx).min_value;
      END IF;
      name_idx := memvp.next(name_idx);
    END LOOP;

  ELSE -- only pool sizes are used
    name_idx := memvp.first;
    WHILE name_idx IS NOT NULL LOOP
      -- don't print recommendations for sga_target, memory_target,
      -- large_pool_size, and streams_pool_size
      IF (memvp(name_idx).name NOT IN (st_idx,mt_idx,lp_idx,sr_idx))
         AND 
         (memvp(name_idx).old_value IS NULL
            OR memvp(name_idx).old_value < memvp(name_idx).min_value)
      THEN
        memvp(name_idx).display := TRUE;
        memvp(name_idx).new_value := memvp(name_idx).min_value;
      END IF;
      name_idx := memvp.next(name_idx);
    END LOOP;
  END IF;  -- end of if memory_target, if sga_target, or if neither is in use

  --
  -- for those memory size parmeters outside of memory_target/sga_target
  -- that won't be recommended, explicitly set DISPLAY to FALSE here (even
  -- if some had already been set to FALSE above)
  --
  --  we do not make recommendations for:
  memvp(lp_idx).display := FALSE;  -- large pool
  memvp(sr_idx).display := FALSE;  -- streams pool
  memvp(pt_idx).display := FALSE;  -- pga aggregate target
  memvp(cs_idx).display := FALSE;  -- db cache size

  -- now copy the info from mem_parameters to all_parameters.
  -- since all_parameters is only displaying the min_value variable for 
  -- memory recommendations, then just copy over mem_parameters' new_value to
  -- all_parameters' min_value.
  -- only copy the pool sizes that we want to be displayed.
  -- ^^^ Note: for now, only copy the memory info for non-cdb and ROOT (no PDB)
  --           because we don't want these values to be displayed for PDBs
  IF is_db_noncdb = TRUE OR db_is_root = TRUE THEN 
    name_idx := memvp.first;
    WHILE name_idx IS NOT NULL LOOP
      IF memvp(name_idx).display = TRUE THEN
        all_parameters(name_idx).min_value := memvp(name_idx).new_value;
        display_min_mem_sizes := TRUE;  -- there will be at least 1 minimum
                                        -- memory size to display
      END IF;
      name_idx := memvp.next(name_idx);
    END LOOP;
  END IF;

END find_mem_sizes;


--------------------------- find_sga_mem_values ------------------------------
-- This is called when sga_target or memory_target is used.

PROCEDURE find_sga_mem_values (memvp IN OUT MEMPARAMETER_TABLE_T)
IS
BEGIN

  -- We're here because sga_target/memory_target is used.
  -- Need to find new values for sga_target.

  -- First, reset min values for pools/memory related to sga_target

  -- buffer cache (cs)
  IF memvp(cs_idx).old_value > memvp(cs_idx).min_value THEN
    memvp(cs_idx).dif_value :=
      memvp(cs_idx).old_value - memvp(cs_idx).min_value;
  END IF;

  -- java pool (jv)
  IF memvp(jv_idx).old_value > memvp(jv_idx).min_value THEN
    memvp(jv_idx).dif_value :=
      memvp(jv_idx).old_value - memvp(jv_idx).min_value;
  END IF;

  -- shared pool (sp)
  IF memvp(sp_idx).old_value > memvp(sp_idx).min_value THEN
    memvp(sp_idx).dif_value :=
      memvp(sp_idx).old_value - memvp(sp_idx).min_value;
  END IF;

  -- large pool (lp)
  IF memvp(lp_idx).old_value > memvp(lp_idx).min_value THEN
    memvp(lp_idx).dif_value :=
      memvp(lp_idx).old_value - memvp(lp_idx).min_value;
  END IF;

  -- streams pool (sr)
  IF memvp(sr_idx).old_value > memvp(sr_idx).min_value THEN
    memvp(sr_idx).dif_value :=
      memvp(sr_idx).old_value - memvp(sr_idx).min_value;
  END IF;

  -- pga_aggregate_target (pt)
  IF memvp(pt_idx).old_value > memvp(pt_idx).min_value THEN
    memvp(pt_idx).dif_value :=
      memvp(pt_idx).old_value - memvp(pt_idx).min_value;
  END IF;

  -- calculate sga_target 'newvalue' (new derived minimum) based on
  -- st_idx.min_value and user-specified pool sizes.
  memvp(st_idx).new_value := 
      memvp(st_idx).min_value + memvp(cs_idx).dif_value
      + memvp(jv_idx).dif_value + memvp(sp_idx).dif_value
      + memvp(lp_idx).dif_value + memvp(sr_idx).dif_value;

  -- calculate memory_target 'newvalue' (new derived minimum) based on
  -- mt_idx.min_value and user-specified pool sizes.
  memvp(mt_idx).new_value :=
    memvp(mt_idx).min_value + memvp(cs_idx).dif_value
    + memvp(jv_idx).dif_value + memvp(sp_idx).dif_value
    + memvp(lp_idx).dif_value + memvp(sr_idx).dif_value
    + memvp(pt_idx).dif_value;

  -- Note: Although sga_target and memory_target values are found here, we
  -- don't set DISPLAY in memvp in this procedure.  This setting is done
  -- in find_mem_sizes.

END find_sga_mem_values;


--
-- is current container CDB$ROOT?
-- if db is a cdb and current container connected to is root, return TRUE.
-- else return FALSE.
--
FUNCTION is_con_root RETURN BOOLEAN
IS
  b_isCdb    BOOLEAN  := FALSE;
  b_retStat  BOOLEAN  := FALSE;
  conId      NUMBER;
BEGIN
  IF db_is_cdb = FALSE THEN -- this db is a non-cdb
    b_retStat := FALSE;  -- no, it can't be the ROOT
  ELSE  -- this db is a cdb
    conId := sys.dbms_preup.get_con_id;  -- check con id
    IF (conId = 1) THEN  -- ROOT's con id is 1
      b_retStat := TRUE;  -- yes, current container is CDB$ROOT
    END IF;
  END IF;
  return b_retStat;
END is_con_root;


--
-- is SIZE-ing THIS MEMory PARAMeter for upgrade?
-- if yes, return TRUE else return FALSE.
-- note: if that parameter's value will not be displayed, its
--        mem_parameters.display would have been set to FALSE
FUNCTION  is_size_this_memparam (name V$PARAMETER.NAME%TYPE) RETURN BOOLEAN
IS
BEGIN

  -- these are the parameters we size or use for sizing for memory
  IF (name IN (cs_idx, jv_idx, sp_idx, lp_idx, sr_idx, pt_idx, st_idx, mt_idx))
  THEN
    return TRUE;
  END IF;

  return FALSE;
END is_size_this_memparam;

--
-- return # of PDBs upgrading in parallel
--
FUNCTION num_pdbs_upg_in_parallel RETURN NUMBER
IS
  pdbs_para   NUMBER;  -- at most # of pdbs upgrading in parallel at a time
BEGIN

  -- if this is a non-cdb, then return 0
  IF (db_is_cdb = FALSE) THEN
    return 0;
  END IF;

  -- if this is a cdb...

  -- find # of pdbs that at most will be upgrading at a time.
  -- using the default as defined in catctl.pl.
  -- will size for default, which is at most smallest integer of cpu_count/2
  -- of pdbs upgrading at a time.
  -- for example,
  --   if cdb has 33 pdbs and # of cpus is 32, then pdbs_para=32/2=16
  IF db_n_pdbs >= trunc(db_cpus/2) THEN  -- if # of pdbs >= (# of cpus/2)
    IF db_cpus = 1 THEN
      -- on 1 cpu mach, default is at most 1 pdb upgrading in parallel
      pdbs_para := 1;
    ELSE
      pdbs_para := trunc(db_cpus/2);
    END IF;
  ELSE    -- if # of pdbs < (# of cpus/2)
    -- if we know there's more cpus/2 on this system than pdbs, then lets
    -- just size for a smaller # of pdbs upgrading in parallel (pdbs_para).
    -- e.g., cdb has 10 pdbs and # of cpus is 32, then size for pdbs_para=10.
    pdbs_para := db_n_pdbs;
  END IF;

  return pdbs_para;
END num_pdbs_upg_in_parallel;


--
-- input: # of pdbs upgrading in parallel.
-- if input is 0, return 0.
-- if input is -1, then this function will ignore input argument and
--   determine # of pdbs upgrading in parallel.
--
-- return # of PDB batches/cycles to upgrade.
--
FUNCTION num_pdb_batches_upg (pdbs_in_parallel NUMBER) RETURN NUMBER
IS
  pdbs_para    NUMBER;  -- at most # of pdbs upgrading in parallel at a time
  pdb_batches  NUMBER;  -- # of batches spent to upgrade PDBs
BEGIN

  pdbs_para := pdbs_in_parallel;

  -- if input arg is 0, then return 0 batches
  -- OR
  -- if this is a non-cdb, then return 0
  IF (pdbs_para = 0) OR (db_is_cdb = FALSE) THEN
    return 0;
  END IF;

  -- if input is -1, then caller wants this function to calculate # of pdbs
  -- upgrading in parallel
  IF (pdbs_para = -1) THEN
    pdbs_para := num_pdbs_upg_in_parallel();
  END IF;

  -- estimate # of pdb upgrade cycles

  -- for example, if upgrading 16 pdbs at a time,
  -- then if total # of pdbs is 32, it's 2 pdb cycles
  -- then if total # of pdbs is 33, it's 3 pdb cycles

  pdb_batches := ceil(db_n_pdbs/pdbs_para);

  return pdb_batches;
END num_pdb_batches_upg;

--
-- ***********************************************************************
--                         Actual CHECK FUNCTIONs
-- ***********************************************************************
--


FUNCTION run_preupgrade(output_filename IN VARCHAR2 DEFAULT null,
                        xml IN BOOLEAN DEFAULT false) RETURN BOOLEAN
IS
    result CLOB;
    check_count NUMBER;
    output_file UTL_FILE.FILE_TYPE;
    result_length NUMBER;
    this_line clob;
    this_line_start_index NUMBER := 1;
    this_line_end_index NUMBER;
    split_line VARCHAR2(32766);
    line_number NUMBER;
    output_is_file BOOLEAN;
    preupgrade_result BOOLEAN := false;
    result_clob CLOB;
    clob_length INTEGER;
    v_buffer varchar2(32000);
    chunk_size BINARY_INTEGER := 3000;
    clob_position INTEGER := 1;	
    text_output_mode BOOLEAN;

BEGIN 
    BEGIN
        text_output_mode := not XML;
        output_is_file := (output_filename IS NOT NULL);

        -- open the file now, its always annoying to wait for a
        -- potentially slow routine (run_all_checks) only to
        -- find out we couldn't open the output file.

        IF (output_is_file) THEN
            output_file := utl_file.fopen('PREUPGRADE_DIR',output_filename, 'w', 32767);
        END IF;

        check_count := run_all_checks(result);

        IF (text_output_mode) THEN
            result := xml_to_text(result);
        END IF;

        result := result || crlf;   -- make it end with a crlf so the loop below handles all output.
        result_length := length(result);
	result_clob := result;
        this_line_end_index := instr(result_clob, crlf, this_line_start_index);
        WHILE (this_line_end_index <> 0) LOOP
            IF this_line_end_index-this_line_start_index > 32767 - crlf_length THEN
                -- could only happen in the XML formatted output if a single XML element body
                -- is less than 32767, but when adding in the length of the surrounding XML tag,
                -- on a single line exceeds 32767.  There aren't any such elements, but just in case...
                dbms_output.put_line('Warning: output line too long.  Truncating the following:');
                this_line := substr(result_clob, this_line_start_index, 
                                                 32767 - crlf_length);
            ELSE
                this_line := substr(result_clob, this_line_start_index, 
                                                 this_line_end_index-this_line_start_index);
            END IF;

            IF text_output_mode THEN
                --
                --  this_line may be too long to emit directly to the terminal.
                --  so chop it up.
                --
                this_line := smart_pad(this_line, C_TERMINAL_WIDTH, NULL);
            END IF;

            IF (output_is_file) THEN
                to_file(output_file, this_line);
            ELSE
                dbms_output.put_line(this_line);
        END IF;

            this_line_start_index := this_line_end_index + crlf_length;
            this_line_end_index := instr(result_clob, crlf, this_line_start_index);
        END LOOP;

    IF (output_is_file) THEN
        utl_file.fflush(output_file);
        utl_file.fclose(output_file);
    END IF;

        preupgrade_result := true;

    EXCEPTION
        WHEN invalidFileOperation THEN
            dbms_output.put_line('ERROR - cannot open output filename ' || output_filename || ' in preupgrade_dir');
            preupgrade_result := false;
        WHEN OTHERS THEN
            --
            --    This is essentially the preupgrade's catch-all handler.
            --
            dbms_output.put_line(dbms_utility.format_error_backtrace);
            internal_error(SQLERRM);
            preupgrade_result := false;
    END;

    return preupgrade_result;

END run_preupgrade;

--
--    This function runs all registered checks and generates FIXUP scripts
--    as needed.
--
FUNCTION run_all_checks(result_xml OUT CLOB) RETURN NUMBER
IS
    successful_checks NUMBER := 0;
    failed_checks_pre NUMBER := 0;         -- number of failed checks whose check_type=PRE
    failed_checks_validation NUMBER := 0;  -- number of failed checks whose check_type=VALIDATION
    failed_checks_post NUMBER := 0;        -- number of failed checks whose check_type=POST
    check_result BOOLEAN;
    check_result_xml CLOB;
    check_index NUMBER;
    this_check check_record_t;
    preupgradecheck preupgradecheck_t;
    original_message CLOB;
    final_suffix VARCHAR2(100);
    next_line_start NUMBER;
    next_crlf NUMBER;

    fixup_script_pre  utl_file.file_type;
    fixup_script_post utl_file.file_type;
    fixup_script      utl_file.file_type;   -- will be equal to either fixup_script_pre or fixup_script_post

BEGIN
    result_xml := '';

    result_xml := result_xml || gen_rdbmsup_xml
                             || gen_database_xml
                             || gen_components_xml
                             || gen_systemresource_xml
                             || gen_initparams_xml
                             || '<PreUpgradeChecks>' || crlf;

    --
    --    Reset this to 0.  preupgradecheck_t_to_text will walk through them and increment this each time.
    --
    preupgradecheck_failure_count := 0; 

    FOR check_index IN 1..check_table.count LOOP
        this_check := check_table(check_index);

        IF debug THEN
            dbms_output.put_line('in run_all_checks, about to run_check on ' || this_check.name);
        END IF;

        --
        --    Run individual check
        --
        check_result := run_check(this_check.name, check_result_xml);

        IF debug THEN
            dbms_output.put_line('run_check(' || this_check.name || ') returned:' || boolean_string(check_result));
            dbms_output.put_line(check_result_xml);
        END IF;

        result_xml := result_xml || check_result_xml;

        IF check_result THEN
            successful_checks := successful_checks + 1;
        ELSE

            --
            --    If the CHECK failed, generate the FIXUP code.
            --
            IF (this_check.fixup_stage = 'PRE') THEN
                failed_checks_pre := failed_checks_pre + 1;
                IF (failed_checks_pre + failed_checks_validation = 1) THEN
                    fixup_script_pre := open_and_start_emitting_fixup(this_check.fixup_stage);
                END IF;
                fixup_script := fixup_script_pre;
            ELSIF (this_check.fixup_stage = 'POST') THEN
                failed_checks_post := failed_checks_post + 1;
                IF (failed_checks_post = 1) THEN
                    fixup_script_post := open_and_start_emitting_fixup(this_check.fixup_stage);
                END IF;
                fixup_script := fixup_script_post;
            ELSIF (this_check.fixup_stage = 'VALIDATION') THEN
                -- these "validation" phase fixups are like PRE's except they're "JUST BEFORE" upgrade.
                failed_checks_validation := failed_checks_validation + 1;
                IF (failed_checks_pre + failed_checks_validation = 1) THEN
                    fixup_script_pre := open_and_start_emitting_fixup('PRE');
                END IF;
                fixup_script := fixup_script_pre;
            ELSE
                internal_error('unknown fixup_stage value, ' || this_check.fixup_stage || '.');
            END IF;

            preupgradecheck := parse_preupgradecheck_xml(check_result_xml, 1, length(check_result_xml));
            IF (preupgradecheck.id IS NULL) THEN
                original_message := 'Unknown message';
            ELSE
                original_message := preupgradecheck_t_to_text(preupgradecheck);
            END IF;
            original_message := smart_pad(original_message, 200, '    --  ');

            --
            --    Emit the code near the call to the CHECK-specific fixup routine.
            --    this way the user knows/remembers the specific context of the original failure.
            --
            utl_file.put_line(fixup_script, ' ');
            utl_file.put_line(fixup_script, '    --');
            utl_file.put_line(fixup_script, '    --    CHECK/FIXUP name: ' || this_check.name);
            utl_file.put_line(fixup_script, '    --');
            utl_file.put_line(fixup_script, '    --    The call to run_fixup below will test whether');
            utl_file.put_line(fixup_script, '    --    the following issue originally identified by');
            utl_file.put_line(fixup_script, '    --    the preupgrade tool is still present');
            utl_file.put_line(fixup_script, '    --    and if so, it will attempt to perform the action');
            utl_file.put_line(fixup_script, '    --    necessary to resolve it.');
            utl_file.put_line(fixup_script, '    --');
            utl_file.put_line(fixup_script, '    --    ORIGINAL PREUPGRADE ISSUE:');

            next_line_start := 1;
            next_crlf := 1;  -- seed a non-zero dummy value
            WHILE next_crlf <> 0 LOOP
               next_crlf := instr(original_message, crlf, next_line_start);
               IF next_crlf <> 0 THEN
                   utl_file.put_line(fixup_script, substr(original_message, next_line_start, next_crlf - next_line_start));
                   next_line_start := next_crlf + crlf_length;
               END IF;
            END LOOP;
            utl_file.put_line(fixup_script, substr(original_message, next_line_start));

            utl_file.put_line(fixup_script, '    --');
            utl_file.put_line(fixup_script, '    fixup_result := dbms_preup.run_fixup(''' ||
                                             this_check.name || ''',' ||
                                             preupgradecheck_failure_count  || ') AND fixup_result;');

        END IF;
    END LOOP;

    --
    --    Close the FIXUP scripts if we wrote them.
    --
    IF (failed_checks_pre > 0) or (failed_checks_validation > 0) THEN
        finish_emitting_fixup(fixup_script_pre, 'PRE');
    END IF;
    IF (failed_checks_post > 0) THEN
        finish_emitting_fixup(fixup_script_post, 'POST');
    END IF;

    final_suffix := '</PreUpgradeChecks>' || crlf || '</RDBMSUP>' || crlf;
    IF NOT db_is_cdb THEN
        final_suffix := final_suffix || '</Upgrade>' || crlf;
    END IF;

    result_xml := result_xml || final_suffix;

    return successful_checks + failed_checks_pre + failed_checks_validation + failed_checks_post;
END run_all_checks;

FUNCTION run_check(check_name IN VARCHAR2, result_xml OUT CLOB) RETURN BOOLEAN
IS
    this_check_record check_record_t;
    check_stmt VARCHAR2(300);
    check_result NUMBER;
    min_version_inclusive_ok BOOLEAN;
    max_version_exclusive_ok BOOLEAN;
BEGIN
    IF debug THEN
        dbms_output.put_line('in run_check for check name: ' || check_name);
    END IF;

    this_check_record := get_check_record_by_name(check_name);
    IF (this_check_record.name IS NULL) THEN
        internal_error('In run_check, Pre-Upgrade Package Requested Check "' || check_name || '" does not exist');
    END IF;
    --
    --    Decide whether this CHECK is applicable to this db_version
    --
    min_version_inclusive_ok := (this_check_record.min_version_inclusive = 'NONE') OR
                      (dbms_registry_extended.compare_versions(db_version_4_dots,
                                        this_check_record.min_version_inclusive,
                                        dbms_registry_extended.occurs(this_check_record.min_version_inclusive, '.')) >= 0 );

    max_version_exclusive_ok := (upper(this_check_record.max_version_exclusive) = 'NONE') OR
                      (dbms_registry_extended.compare_versions(db_version_4_dots,
                                        this_check_record.max_version_exclusive,
                                        dbms_registry_extended.occurs(this_check_record.max_version_exclusive, '.')) < 0 );

    IF (min_version_inclusive_ok AND max_version_exclusive_ok) THEN
        --
        --    Call the CHECK
        --
        BEGIN
            check_stmt := 'BEGIN ' || ':1 := dbms_preup.' ||
                              dbms_assert.simple_sql_name(this_check_record.name) || '_check (:2); ' ||
                          'END;';

            EXECUTE IMMEDIATE check_stmt
                USING OUT check_result, IN OUT result_xml;
        EXCEPTION
            WHEN stringNotSimpleSQLName THEN
                --
                --    The checkname is invalid somehow.  Get out.
                --
                internal_error('preupgrade check "' || check_name || '" not valid.');
            WHEN e_undefinedFunction THEN
                internal_error('check "' || check_name || '" not implemented.');
            WHEN OTHERS THEN
                --
                --    This could happen if the CHECK itself threw an exception.
                --
                dbms_output.put_line('check "' || check_name ||
                                     '" raised the following exception and did not complete. ' || crlf ||
                                     sqlerrm);
                dbms_output.put_line(dbms_utility.format_error_backtrace);
                dbms_output.put_line('preupgrade will attempt to continue from that error');
                result_xml := '';
                RETURN false;
        END;

        IF debug THEN
            dbms_output.put_line('Check ' || check_name || ' was called.  Returning ' ||
                boolean_string(check_result = c_success) );
        END IF;

    ELSE
        check_result := c_success;  -- the check does not appply to this version, so it essentially "passes".

        IF debug THEN
            dbms_output.put_line('Not running check ' || this_check_record.name ||
                ' because it does not apply to this database version.');
        END IF;
    END IF;

    RETURN (check_result = c_success);

END run_check;


FUNCTION oracle_reserved_users_check (result_txt OUT CLOB) RETURN NUMBER
IS
    users VARCHAR2(4000);
BEGIN
    users := '';

    --
    --    The version numbers in the second parameter to get_reserved_user()
    --    should have 4 dots in them.
    --
    -- users := users || get_reserved_user('ORACLE_OCM',         '10.2.0.4.0');
    -- users := users || get_reserved_user('APPQOSSYS',          '11.2.0.1.0');
    users := users || get_reserved_user('AUDSYS',             '12.1.0.1.0');
    users := users || get_reserved_user('AUDIT_ADMIN',        '12.1.0.1.0');
    users := users || get_reserved_user('AUDIT_VIEWER',       '12.1.0.1.0');
    users := users || get_reserved_user('SYSBACKUP',          '12.1.0.1.0');
    users := users || get_reserved_user('SYSDG',              '12.1.0.1.0');
    users := users || get_reserved_user('SYSKM',              '12.1.0.1.0');
    users := users || get_reserved_user('CAPTURE_ADMIN',      '12.1.0.1.0');
    users := users || get_reserved_user('GSMCATUSER',         '12.1.0.1.0');
    users := users || get_reserved_user('GSMUSER',            '12.1.0.1.0');
    users := users || get_reserved_user('GSMADMIN_INTERNAL',  '12.1.0.1.0');
    users := users || get_reserved_user('GSMUSER_ROLE',       '12.1.0.1.0');
    users := users || get_reserved_user('GSMPOOLADMIN_ROLE',  '12.1.0.1.0');
    users := users || get_reserved_user('GSMADMIN_ROLE',      '12.1.0.1.0');
    users := users || get_reserved_user('GDS_CATALOG_SELECT', '12.1.0.1.0');
    users := users || get_reserved_user('PROVISIONER',        '12.1.0.1.0');
    users := users || get_reserved_user('XS_RESOURCE',        '12.1.0.1.0');
    users := users || get_reserved_user('XS_SESSION_ADMIN',   '12.1.0.1.0');
    users := users || get_reserved_user('XS_NAMESPACE_ADMIN', '12.1.0.1.0');
    users := users || get_reserved_user('XS_CACHE_ADMIN',     '12.1.0.1.0');
    users := users || get_reserved_user('EM_EXPRESS_BASIC',   '12.1.0.1.0');
    users := users || get_reserved_user('EM_EXPRESS_ALL',     '12.1.0.1.0');
    users := users || get_reserved_user('DV_AUDIT_CLEANUP',   '12.1.0.1.0');
    users := users || get_reserved_user('DV_DATAPUMP_NETWORK_LINK', '12.1.0.1.0');
    users := users || get_reserved_user('SYSRAC',             '12.2.0.0.0');
    users := users || get_reserved_user('SYS$UMF',            '12.2.0.0.0');
    users := users || get_reserved_user('SYSUMF_ROLE',        '12.2.0.0.0');
    users := users || get_reserved_user('DBSFWUSER',          '12.2.0.0.0');
    users := users || get_reserved_user('DBSFWUSER_ROLE',     '12.2.0.0.0');
    users := users || get_reserved_user('REMOTE_SCHEDULER_AGENT','12.2.0.0.0');
    users := users || get_reserved_user('GGSYS',              '12.2.0.0.0');
    users := users || get_reserved_user('GGSYS_ROLE',         '12.2.0.0.0');
    users := users || get_reserved_user('DV_POLICY_OWNER',    '12.2.0.0.0');
    users := users || get_reserved_user('XS_CONNECT',         '12.2.0.0.0');
    -- users := users || get_reserved_user('APPLICATION_TRACE_VIEWER', '12.2.0.0.0');

    
    IF (users IS NULL) THEN
        RETURN c_success;
    ELSE
        result_txt := get_failed_check_xml('oracle_reserved_users',
                      new string_array_t(users, db_version_4_dots),
                      null, null);
        RETURN c_failure;
    END IF;
END oracle_reserved_users_check;

FUNCTION get_addl_undo_space RETURN NUMBER

-- Get additional undo space requirement based on # of objects in the database
-- according to undo_space_rows and undo_space_extra constants.

IS
    --
    -- Rows per every 40M extra for undo space
    --
    undo_space_rows          CONSTANT NUMBER := 75000;
    undo_space_extra         CONSTANT NUMBER := 40;
    objects NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM OBJ$' INTO objects;
    return ROUND((objects / undo_space_rows) * undo_space_extra);
END get_addl_undo_space;

FUNCTION supported_version_check(result_txt OUT CLOB) RETURN NUMBER
IS
BEGIN
    IF debug THEN
        dbms_output.put_line('in supported_version_check');
    END IF;

    IF (instr(',&C_UPGRADABLE_VERSIONS,',
              ',' || db_version_3_dots || ',') = 0) THEN
        IF debug THEN
            dbms_output.put_line('in supported_version_check, version not supported.');
        END IF;

        --
        --    The database version is not supported for upgrade.
        --
        result_txt := get_failed_check_xml('supported_version',
                          new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS,
                                   '&C_UPGRADABLE_VERSIONS',
                                   db_version_4_dots),
                null, null);
        IF debug THEN
            dbms_output.put_line('in supported_version_check, version not supported. result_txt=' || result_txt);
        END IF;

        RETURN c_failure;
    ELSE
        result_txt := '';
        RETURN c_success;
    END IF;
END supported_version_check;



FUNCTION compatible_parameter_check (result_txt OUT CLOB) RETURN NUMBER
IS
    status NUMBER;
BEGIN
    --
    --    If we have the correct min compat and not debug and not XML
    --    return success.
    --
    IF (dbms_registry_extended.compare_versions(db_compatible,
                         '&C_MINIMUM_COMPATIBLE',
                         dbms_registry_extended.occurs('&C_MINIMUM_COMPATIBLE','.') ) >= 0) THEN
        RETURN c_success;
    END IF;

    result_txt := get_failed_check_xml('compatible_parameter',
                      new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS,
                          '&C_MINIMUM_COMPATIBLE',
                          db_compatible),
                      null, null);
    RETURN c_failure;
END compatible_parameter_check;


FUNCTION ols_sys_move_check (result_txt OUT CLOB) RETURN NUMBER
IS
    preaud_cnt       INTEGER := 0;
    status           NUMBER  := -1;
    condition_exists BOOLEAN := FALSE;
BEGIN
    BEGIN
        -- Check if OLS is installed in previous version
        EXECUTE IMMEDIATE 'SELECT status FROM sys.registry$ WHERE cid=''OLS''
                           AND namespace=''SERVER'''
             INTO status;
        EXCEPTION WHEN OTHERS THEN NULL;
    END;

    --
    --    bug 16317592: check if SYS.aud$ already exists. may be upgrade
    --    script was run before. If SYS.aud$ exists, don't do anything
    --
    SELECT count(*) INTO preaud_cnt FROM dba_tables
           WHERE table_name = 'AUD$' AND owner = 'SYS';

    IF ((status != -1) AND (preaud_cnt != 1)) THEN
        BEGIN
            --
            -- This check means the ols script has not been executed
            --
            EXECUTE IMMEDIATE 'SELECT count(*) FROM dba_tables where OWNER=''SYS'' AND table_name=''PREUPG_AUD$'''
              into preaud_cnt;
            IF preaud_cnt = 0 THEN
              condition_exists := TRUE;
            END IF;
        END;
    END IF;

    IF (NOT condition_exists) THEN
        RETURN c_success;
    END IF;

    result_txt := get_failed_check_xml('ols_sys_move',
                      new string_array_t(db_version_4_dots,
                          C_ORACLE_HIGH_VERSION_4_DOTS,
                          to_char(preaud_cnt)),
                      null, null);
    RETURN c_failure;

END ols_sys_move_check;


FUNCTION awr_dbids_present_check (result_txt OUT CLOB) RETURN NUMBER
IS
BEGIN
  IF NOT select_has_rows('SELECT distinct NULL FROM sys.wrm$_wr_control
    WHERE dbid != (SELECT dbid FROM v$database)') THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('awr_dbids_present',
                      new string_array_t(),
                      null, null);
    RETURN c_failure;
  END IF;
END awr_dbids_present_check;


FUNCTION pa_profile_check (result_txt OUT CLOB) RETURN NUMBER
IS
  c             NUMBER;
  d             NUMBER;
  v_tab         DBMS_SQL.VARCHAR2_TABLE;
  enabled_count NUMBER := 0;
  tab_name      VARCHAR2(130);
  v_count       NUMBER := 0;
  row_count     NUMBER := 0;
  issue_found   BOOLEAN := FALSE;
  pa_view       VARCHAR2(128) := 'SYS.DBA_PRIV_CAPTURES';
BEGIN
  -- return success if view DBA_PRIV_CAPTURES does not exist
  SELECT COUNT(*) INTO v_count 
    FROM DBA_OBJECTS 
    WHERE OWNER = 'SYS' AND OBJECT_NAME = 'DBA_PRIV_CAPTURES' AND OBJECT_TYPE = 'VIEW';

  IF v_count = 0 THEN
    RETURN c_success;
  END IF;

  -- return success if view DBA_SECUREFILE_LOG_TABLES does not exist
  SELECT COUNT(*) INTO v_count 
    FROM DBA_OBJECTS 
    WHERE OWNER = 'SYS' AND OBJECT_NAME = 'DBA_SECUREFILE_LOG_TABLES' AND OBJECT_TYPE = 'VIEW';
  IF v_count = 0 THEN
    RETURN c_success;
  END IF;

  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(name) FROM ' || pa_view || ' WHERE enabled=''Y''' INTO enabled_count;
  EXCEPTION
      WHEN OTHERS THEN NULL;
  END;

  c := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(c, 'SELECT table_name
                     FROM dba_securefile_log_tables
                     WHERE log_name LIKE ''ORA$PA_%'' OR log_name LIKE ''ORA$PRIV_CAPTURE_%''', 
                 DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_ARRAY(c, 1, v_tab, 1, 1);

  /* execute SQL statement */
  d := DBMS_SQL.EXECUTE(c);

  /* retrieve column values to column table */
  LOOP
    EXIT WHEN DBMS_SQL.FETCH_ROWS(c) = 0;
    row_count := row_count + 1;
    DBMS_SQL.COLUMN_VALUE(c, 1, v_tab);
  END LOOP;

  DBMS_SQL.CLOSE_CURSOR(c);

  FOR i IN 1..row_count LOOP
    tab_name := DBMS_ASSERT.ENQUOTE_NAME(v_tab(i), FALSE);
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || tab_name INTO v_count;
    IF v_count > 0 THEN
      issue_found := TRUE;
      EXIT;
    END IF;
  END LOOP;

  IF (enabled_count > 0 OR issue_found) THEN
    result_txt := get_failed_check_xml('pa_profile',
                      new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS),
                      null, null);
    RETURN c_failure;
  ELSE
    RETURN c_success;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF DBMS_SQL.IS_OPEN(c) THEN
      DBMS_SQL.CLOSE_CURSOR(c);
    END IF;
    RETURN c_failure;
END pa_profile_check;


FUNCTION em_present_check (result_txt OUT CLOB) RETURN NUMBER
IS
BEGIN
  IF NOT select_has_rows('SELECT NULL FROM sys.registry$ WHERE cid=''EM''
      AND status NOT IN (99,8)') THEN
    -- EM not here.
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('em_present',
                      new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS, db_version_4_dots),
                      null, null);
    RETURN c_failure;
  END IF;
END em_present_check;



FUNCTION files_need_recovery_check (result_txt OUT CLOB) RETURN NUMBER
IS
  c_recover_sql_text CONSTANT VARCHAR2(250) :=
        'SELECT NULL FROM v$recover_file WHERE ((error <> ''OFFLINE NORMAL'') or (error is null)) and rownum <=1';
  c_recover_sql_cdb  CONSTANT VARCHAR2(250) :=
        ' AND con_id = sys.dbms_preup.get_con_id()';
  stmttext    VARCHAR2(200) := c_recover_sql_text;
BEGIN
  --
  -- Cdb Database add con id check
  --
  IF db_is_cdb THEN
      stmttext := stmttext || c_recover_sql_cdb;
  END IF;

  IF NOT select_has_rows(stmttext) THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('files_need_recovery',
                      new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS),
                      null, null);
    RETURN c_failure;
  END IF;
END files_need_recovery_check;


FUNCTION files_backup_mode_check (result_txt OUT CLOB) RETURN NUMBER
IS
BEGIN
  IF NOT select_has_rows('SELECT NULL FROM v$backup  WHERE
           status = ''ACTIVE'' AND rownum <=1') THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('files_backup_mode',
                      new string_array_t(),
                      null, null);
    RETURN c_failure;
  END IF;
END files_backup_mode_check;


FUNCTION two_pc_txn_exist_check (result_txt OUT CLOB) RETURN NUMBER
IS
BEGIN

  IF NOT select_has_rows('SELECT NULL FROM sys.dba_2pc_pending
    WHERE rownum <=1') THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('two_pc_txn_exist',
                      new string_array_t(),
                      null, null);
    RETURN c_failure;
  END IF;

END two_pc_txn_exist_check;


FUNCTION sync_standby_db_check (result_txt OUT CLOB) RETURN NUMBER
IS
  t_null                 CHAR(1);
  status                 NUMBER := 0;
  unsynch_standby_count  NUMBER := 0;
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'SELECT NULL FROM v$parameter WHERE
       name LIKE ''log_archive_dest%'' AND upper(value) LIKE ''SERVICE%''
       AND rownum <=1'
    INTO t_null;

    EXECUTE IMMEDIATE 'SELECT NULL FROM v$database WHERE
       database_role=''PRIMARY'''
    INTO t_null;

    EXECUTE IMMEDIATE 'SELECT COUNT(*)
                         FROM V$ARCHIVE_DEST_STATUS DS, V$ARCHIVE_DEST D
                         WHERE DS.DEST_ID = D.DEST_ID
                               AND D.TARGET = ''STANDBY''
                               AND NOT (DS.STATUS = ''VALID'' AND DS.GAP_STATUS = ''NO GAP'')'
    INTO unsynch_standby_count;
    IF (unsynch_standby_count > 0) THEN
        status := 1;
    END IF;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN status := 0;
  END;

  IF (status = 0) THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('sync_standby_db',
                      new string_array_t(),
                      null, null);
    RETURN c_failure;
   END IF;
END sync_standby_db_check;


FUNCTION ultrasearch_data_check (result_txt OUT CLOB) RETURN NUMBER
IS
  status  NUMBER := 0;
  i_count INTEGER;
BEGIN
  --
  -- Once Ultra Search instance is created, wk$instance table is populated.
  -- The logic determines if Ultra Search has data or not by looking up
  -- wk$instance table. WKSYS.WK$INSTANCE table exists when Ultra Search is
  -- installed. If it's not installed, WKSYS.WK$INSTANCE doesn't exist and the
  -- pl/sql block raises exception.
  --
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM wksys.wk$instance'
      INTO i_count;
    -- count will be 0 when there are no rows in wksys.wk$instance
    -- Otherwise there is at least one row in
    -- and an ultra search warning should be displayed
    IF (i_count != 0) THEN
       status := 1;
    END IF;
    EXCEPTION WHEN OTHERS THEN NULL;
  END;

  IF (status = 0) THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('ultrasearch_data',
                      new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS),
                      null, null);

    RETURN c_failure;
   END IF;
END ultrasearch_data_check;


FUNCTION remote_redo_check (result_txt OUT CLOB) RETURN NUMBER
IS
  tmp_varchar1 VARCHAR2(100);
  t_count      INTEGER;
  status       NUMBER := 0;
BEGIN
  --
  -- Check to detect if REDO configuration is supported with beyond
  -- 11.2
  --
  --  For 11.2, REDO has changed its maximum number of remote redo transport
  --  destinations from 9 to 30, we need to see if 10 is being used, and what
  --  its default is, if its local, there is an error.
  --
  -- Condition 1) Archiving of log files is enabled
  --
  -- Condition 2) DB_RECOVERY_FILE_DEST is defined
  --
  -- Condition 3) No local destinations are defined
  --
  -- Condition 4) LOG_ARCHIVE_DEST_1 is in use, and is a remote destition
  --
  --
  -- Only continue if archive logging is on
  --

  IF select_varchar2('SELECT LOG_MODE FROM v$database','NOARCHIVELOG') != 'ARCHIVELOG' THEN
    RETURN c_success;
  END IF;

  --
  -- Check for db_recovery_file_dest
  --
  tmp_varchar1 := select_varchar2('SELECT vp.value FROM v$parameter vp WHERE
               UPPER(vp.NAME) = ''DB_RECOVERY_FILE_DEST''',NULL);

  IF tmp_varchar1 IS NOT NULL OR tmp_varchar1 != '' THEN
    --
    -- See if there are any local destinations defined
    -- Note the regexp_like
    --
    EXECUTE IMMEDIATE '
      SELECT count(*) FROM v$parameter v
        WHERE v.NAME  LIKE ''log_archive_dest_%'' AND
        REGEXP_LIKE(v.VALUE,''*[ ^]?location([ ])?=([ ])?*'')'
    INTO t_count;

    IF t_count > 0 THEN
      --
      -- Next is _1 in use, and remote
      --
      EXECUTE IMMEDIATE '
        SELECT count(*) FROM v$archive_dest ad
        WHERE ad.status=''VALID'' AND ad.dest_id=1 AND
                 ad.target=''STANDBY'''
      INTO t_count;

      IF t_count = 1 THEN
        --
        -- There is an issue to report.
        --
        status := 1;
      END IF;
    END IF; -- t_count = 1
  END IF;  -- having local dest values set

  IF (status = 0) THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('remote_redo',
                      new string_array_t(db_version_4_dots,C_ORACLE_HIGH_VERSION_4_DOTS),
                      null, null);

    RETURN c_failure;
   END IF;
END remote_redo_check;


FUNCTION sys_default_tablespace_check (result_txt OUT CLOB) RETURN NUMBER
IS
  t_ts1       VARCHAR2(30);
  t_ts2       VARCHAR2(30);
  status      NUMBER;
BEGIN

  EXECUTE IMMEDIATE 'SELECT default_tablespace FROM sys.dba_users WHERE username = ''SYS'''
  INTO t_ts1;
  EXECUTE IMMEDIATE 'SELECT default_tablespace FROM sys.dba_users WHERE username = ''SYSTEM'''
  INTO t_ts2;

  IF (t_ts1 = 'SYSTEM') AND (t_ts2 = 'SYSTEM') THEN
    -- Everything is fine.
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('sys_default_tablespace',
                      new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS,db_version_4_dots,t_ts1,t_ts2),
                      null, null);

    RETURN c_failure;
  END IF;
END sys_default_tablespace_check;

FUNCTION sys_default_tablespace_fixup (
         result_txt IN OUT VARCHAR2,
         pSqlcode    IN OUT NUMBER) RETURN number
IS
  t_result_txt VARCHAR2(1000);
  t_ts1        VARCHAR2(128);
  rval         BOOLEAN;
BEGIN
  --
  --  Check both SYS and SYSTEM and reset if needed
  --
  result_txt := '';
  pSqlcode := 1;
  EXECUTE IMMEDIATE 'SELECT default_tablespace FROM sys.dba_users WHERE username = ''SYS'''  
  INTO t_ts1;
  IF (t_ts1 != 'SYSTEM') THEN
    result_txt := 'Altering SYS schema default tablespace.  Result: ';
    rval := execute_sql_statement ('ALTER USER SYS DEFAULT TABLESPACE SYSTEM', t_result_txt, pSqlcode);
    result_txt := result_txt || TO_CHAR(pSqlcode);
  END IF;

  EXECUTE IMMEDIATE 'SELECT default_tablespace FROM sys.dba_users WHERE username = ''SYSTEM'''  
  INTO t_ts1;
  IF (t_ts1 != 'SYSTEM') THEN
    result_txt := result_txt || crlf || 'Altering SYSTEM schema default tablespace Result: ';
    rval := execute_sql_statement ('ALTER USER SYSTEM DEFAULT TABLESPACE SYSTEM', t_result_txt, pSqlcode);
    result_txt := result_txt || TO_CHAR(pSqlcode);
  END IF;
  --
  -- If both were executed, only the last status is returned.
  --
  if (rval = TRUE) then
     return c_success;
  else
     return c_failure;
  end if;

END sys_default_tablespace_fixup;

FUNCTION invalid_laf_check (result_txt OUT CLOB) RETURN NUMBER
IS
  laf_format   VARCHAR2(4000);
  tmp_varchar1 VARCHAR2(512);
  t_null       CHAR(1);
  status       NUMBER := 0;
BEGIN

   --
   -- invalid log_archive_format check
   --
   -- for 9.x, RDBMS set a default value which did not include %r,
   -- which is required by 11.2.
   -- Grab the format string, and if its defaulted or not,
   -- Only report an error if its NOT defaulted (user set) and it is
   -- missing the %r.
   --
   BEGIN
     EXECUTE IMMEDIATE
        'SELECT value, isdefault FROM v$parameter WHERE name = ''log_archive_format'''
     INTO laf_format, tmp_varchar1;
   EXCEPTION WHEN OTHERS THEN NULL;
   END;

   IF (tmp_varchar1 = 'FALSE') AND
      (instr (LOWER(laf_format), '%r') = 0) THEN
     --
     -- no %[r|R] and we are not defaulted by the system - we have to report something...
     --
     status := 1;
   END IF;

  IF (status = 0) THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('invalid_laf',
                      new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS,laf_format),
                      null, null);
 
    RETURN c_failure;
  END IF;
END invalid_laf_check;


FUNCTION depend_usr_tables_check (result_txt OUT CLOB) RETURN NUMBER
IS
  t_null varchar2(1);
BEGIN
  -- Look for any user tables dependent on Oracle-Maintained types.
  -- If there are any, then IF the -T option is used to set user tablespaces to
  -- READ ONLY during the upgrade, then a post-upgrade action to run 
  -- utluptabdata.sql is required.

 IF sys.dbms_registry.release_version = '&C_ORACLE_HIGH_VERSION_4_DOTS' THEN
   -- Perform post-upgrade check:
   --   If -T has NOT been used, then all tables should be already upgraded.
   --   If -T was used, and utluptabdata.sql was run successfully, then all
   --       tables should already be upgraded. 
   --   If -T was used but utluptabdata.sql was NOT run to upgrade all of the
   --       remaining tables, then this check will fail post upgrade.
   SELECT NULL into t_null
   FROM sys.obj$ o, sys.user$ u, sys.col$ c, sys.coltype$ t
   WHERE bitand(t.flags,256) = 256 AND -- UPGRADED = NO
         t.intcol# = c.intcol# AND
         t.col# = c.col# AND
         t.obj# = c.obj# AND
         c.obj# = o.obj# AND
         o.owner# = u.user# AND
         o.owner# NOT IN -- Not an Oracle-Supplied user
            (SELECT user# FROM sys.user$
             WHERE type#=1 AND bitand(spare1, 256)= 256) AND
         o.obj# IN  -- A dependent of an Oracle-Maintained type
            (SELECT d.d_obj#  
             FROM sys.dependency$ d, sys.obj$ do
             WHERE do.obj# = d.d_obj#
               AND do.type# IN (2,13)
             START WITH d.p_obj# IN -- Oracle-Maintained types
                (SELECT obj# from sys.obj$ 
                 WHERE type#=13 AND 
                       owner# IN -- an Oracle-Supplied user 
                           (SELECT user# FROM sys.user$
                            WHERE type#=1 AND 
                            bitand(spare1, 256)= 256))             
             CONNECT BY NOCYCLE PRIOR d.d_obj# = d.p_obj#);
  -- Found a dependent table
  result_txt := get_failed_check_xml('depend_usr_tables',
                      new string_array_t(db_version_4_dots),
                      null, null);
  RETURN c_failure;   

 ELSE -- Perform preupgrade check
  SELECT NULL into t_null
  FROM sys.obj$
  WHERE type# = 2
    AND owner# NOT IN 
       (SELECT schema# FROM sys.registry$ WHERE namespace = 'SERVER'
        UNION
        SELECT schema# FROM sys.registry$schemas WHERE namespace = 'SERVER'
        UNION
        SELECT user# FROM user$ WHERE type#=1 AND bitand(spare1,256)=256)
    AND obj# IN
        (SELECT do.obj# FROM sys.dependency$ d, sys.obj$ do
          WHERE do.obj# = d.d_obj#
            AND do.type# IN (2,13)
         START WITH d.p_obj# IN -- Oracle-Maintained types
           (SELECT obj# from sys.obj$ 
            WHERE type#=13  
              AND owner# IN
                 (SELECT schema# FROM sys.registry$ 
                  WHERE namespace = 'SERVER'
                  UNION
                  SELECT schema# FROM sys.registry$schemas 
                  WHERE namespace = 'SERVER'
                  UNION
                  SELECT user# FROM sys.user$
                  WHERE type#=1 AND bitand(spare1,256)=256))
         CONNECT BY NOCYCLE PRIOR d.d_obj# = d.p_obj#)
    AND rownum <=1;
  -- Found a dependent table
  result_txt := get_failed_check_xml('depend_usr_tables',
                      new string_array_t(db_version_4_dots),
                      null, null);
  RETURN c_failure;   
 END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN 
     -- No rows found, so no dependent tables
     RETURN c_success;
  WHEN OTHERS THEN
     result_txt := get_failed_check_xml('depend_usr_tables',
                         new string_array_t(db_version_4_dots),
                         null, null);
     RETURN c_failure;   
END depend_usr_tables_check;

--
-- Post upgrade Fixup depend_usr_tables_fixup
--
FUNCTION depend_usr_tables_fixup (
         result_txt IN OUT VARCHAR2,
         pSqlcode    IN OUT NUMBER) RETURN NUMBER
IS
  t_full_name  VARCHAR2(256);
  t_sqltxt     VARCHAR2(4000);
  t_new_err    VARCHAR2(500);
  t_error      BOOLEAN := FALSE;
  t_took_error BOOLEAN := FALSE;
  t_sqlcode    NUMBER;  -- The last sql error we took
  t_len        NUMBER;
  CURSOR t_tabs IS
     SELECT DISTINCT u.name owner, o.name name
     FROM sys.obj$ o, sys.user$ u, sys.col$ c, sys.coltype$ t
     WHERE bitand(t.flags,256) = 256 -- DATA_UPGRADED = 'NO'
       AND t.intcol# = c.intcol# AND t.col# = c.col#
       AND t.obj# = c.obj# AND  c.obj# = o.obj# 
       AND o.owner# = u.user# AND o.type# = 2
       AND o.owner# NOT IN  -- Not an Oracle-Supplied user
           (SELECT user# FROM sys.user$ 
            WHERE type#=1 AND bitand(spare1,256)=256)
       AND  o.obj# IN  -- A dependent of an Oracle-mainted type
           (SELECT do.obj# 
            FROM sys.dependency$ d, sys.obj$ do
            WHERE do.obj# = d.d_obj#
              AND do.type# IN (2,13)
            START WITH d.p_obj# IN 
                (SELECT obj# from sys.obj$ 
                 WHERE type#=13 AND owner# IN
                   (SELECT schema# FROM sys.registry$ 
                    WHERE namespace = 'SERVER'
                    UNION
                    SELECT schema# FROM sys.registry$schemas 
                    WHERE namespace = 'SERVER'
                    UNION
                    SELECT user# FROM sys.user$ 
                    WHERE type#=1 AND bitand(spare1,256)=256))
              CONNECT BY NOCYCLE PRIOR d.d_obj# = d.p_obj#);
BEGIN
  result_txt := '';

  FOR tab IN t_tabs LOOP
    --
    -- Put quotes around the schema and table name
    --
    t_full_name :=  dbms_assert.enquote_name(tab.owner, FALSE) || '.' ||
                    dbms_assert.enquote_name(tab.name,FALSE);
    BEGIN
      EXECUTE IMMEDIATE 'ALTER TABLE ' || t_full_name
                || ' UPGRADE INCLUDING DATA';
      EXCEPTION WHEN OTHERS THEN
        t_error  := TRUE;
        t_sqltxt := SQLERRM;
        t_sqlcode  := SQLCODE;
        t_took_error := TRUE;
    END;

    IF t_error THEN
      IF result_txt IS NOT NULL THEN
        -- If not the first, add a crlf
        result_txt := result_txt || crlf;
      END IF;

      t_new_err :=
            '  Error upgrading: ' || t_full_name || crlf ||
            '  Error Text:      ' || t_sqltxt || crlf;

      --
      --  length returns NULL (and not zero) for null varchar2's
      --
      t_len := NVL(length(result_txt), 0);

      IF (t_len + length (t_new_err) <= c_str_max) THEN
        --
        -- will fit into our buffer
        --
        result_txt := result_txt || t_new_err;
      ELSE
        t_new_err := crlf ||
           '  *** Too Many Tables ***' || crlf ||
           '  *** Run rdbms/admin/utluptabdata.sql instead *** ';
        --
        -- see if this will fit on the end (should be
        -- shorter than the actual error)
        --
        IF (t_len + length (t_new_err) < c_str_max) THEN
          -- Fits
          result_txt := result_txt || t_new_err;
        ELSE
          --
          -- Won't fit, cut some off and add the above error
          --
          result_txt := substr (result_txt, 1, t_len -
                                    length(t_new_err));
          result_txt := result_txt || t_new_err;
        END IF;
        -- We are done.
        EXIT;   -- Out of the loop
      END IF;
      t_error := FALSE;  -- Reset error
    END IF;
  END LOOP;

  IF t_took_error THEN
    pSqlcode := t_sqlcode;  -- Return the last failure code
    RETURN c_failure;
  ELSE
    RETURN c_success;
  END IF;
END depend_usr_tables_fixup;

FUNCTION invalid_usr_tabledata_check (result_txt OUT CLOB) RETURN NUMBER
IS
  t_null  NUMBER;
BEGIN
  --
  -- Include only tables dependent on Oracle-Maintained types
  -- by looking through dependency$ for types owned by schemas in
  -- registry$ or user$ (12.1) Oracle-Maintained flag.
 BEGIN
  SELECT NULL into t_null
  FROM SYS.OBJ$ o, SYS.COL$ c, SYS.COLTYPE$ t
  WHERE BITAND(t.FLAGS, 256) = 256 -- DATA_UPGRADED = NO
    AND o.OBJ# = t.OBJ# AND c.OBJ# = t.OBJ# 
    AND c.COL# = t.COL# AND t.INTCOL# = c.INTCOL#
    AND o.type# = 2 AND o.owner# NOT IN  -- Not an Oracle-Supplied user
       (SELECT schema# FROM sys.registry$ WHERE namespace = 'SERVER'
        UNION
        SELECT schema# FROM sys.registry$schemas WHERE namespace = 'SERVER'
        UNION
        SELECT user# FROM user$ WHERE type#=1 AND bitand(spare1,256)=256)
    AND o.obj# IN  --A dependent of an Oracle-maintained type
        (SELECT do.obj# 
         FROM sys.dependency$ d, sys.obj$ do
         WHERE do.obj# = d.d_obj#
           AND do.type# IN (2,13)
         START WITH d.p_obj# IN 
          (SELECT obj# from sys.obj$
           WHERE type#=13 AND owner# IN
             (SELECT schema# FROM sys.registry$ WHERE namespace = 'SERVER'
              UNION
              SELECT schema# FROM sys.registry$schemas WHERE namespace = 'SERVER'
              UNION
              SELECT user# FROM user$ WHERE type#=1 AND bitand(spare1,256)=256))
        CONNECT BY NOCYCLE PRIOR d.d_obj# = d.p_obj#)
    AND ROWNUM <=1;
    -- A row found, so the check fails
    result_txt := get_failed_check_xml('invalid_usr_tabledata',
                  new string_array_t(db_version_4_dots),
                  null, null);
    RETURN c_failure;
 EXCEPTION  -- No user tables dependent on Oracle-Maintained types need upgrading
    WHEN NO_DATA_FOUND THEN RETURN c_success;
 END;
END invalid_usr_tabledata_check;

--
-- Fixup invalid_usr_tabledata_fixup
--
FUNCTION invalid_usr_tabledata_fixup (
         result_txt IN OUT VARCHAR2,
         pSqlcode    IN OUT NUMBER) RETURN NUMBER
IS
  t_full_name  VARCHAR2(256);
  t_sqltxt     VARCHAR2(4000);
  t_new_err    VARCHAR2(500);
  t_error      BOOLEAN := FALSE;
  t_took_error BOOLEAN := FALSE;
  t_sqlcode    NUMBER;  -- The last sql error we took
  t_len        NUMBER;
  CURSOR t_tabs IS
     SELECT DISTINCT u.name owner, o.name name
     FROM sys.obj$ o, sys.user$ u, sys.col$ c, sys.coltype$ t
     WHERE bitand(t.flags,256) = 256 -- DATA_UPGRADED = 'NO'
       AND t.intcol# = c.intcol# AND t.col# = c.col#
       AND t.obj# = c.obj# AND  c.obj# = o.obj# 
       AND o.owner# = u.user# AND o.type# = 2
       AND o.owner# NOT IN  -- Not an Oracle-Supplied user
             (SELECT schema# FROM sys.registry$ WHERE namespace = 'SERVER'
              UNION
              SELECT schema# FROM sys.registry$schemas WHERE namespace = 'SERVER'
              UNION
              SELECT user# FROM sys.user$ WHERE type#=1 AND bitand(spare1,256)=256)
       AND  o.obj# IN  -- A dependent of an Oracle-mainted type
           (SELECT do.obj# 
            FROM sys.dependency$ d, sys.obj$ do
            WHERE do.obj# = d.d_obj#
              AND do.type# IN (2,13)
            START WITH d.p_obj# IN 
                (SELECT obj# from sys.obj$ 
                 WHERE type#=13 AND owner# IN
                   (SELECT schema# FROM sys.registry$ 
                    WHERE namespace = 'SERVER'
                    UNION
                    SELECT schema# FROM sys.registry$schemas 
                    WHERE namespace = 'SERVER'
                    UNION
                    SELECT user# FROM sys.user$ 
                    WHERE type#=1 AND bitand(spare1,256)=256))
              CONNECT BY NOCYCLE PRIOR d.d_obj# = d.p_obj#);
BEGIN
  result_txt := '';

  FOR tab IN t_tabs LOOP
    --
    -- Put quotes around the schema and table name
    --
    t_full_name :=  dbms_assert.enquote_name(tab.owner, FALSE) || '.' ||
                    dbms_assert.enquote_name(tab.name,FALSE);
    BEGIN
      EXECUTE IMMEDIATE 'ALTER TABLE ' || t_full_name
                || ' UPGRADE INCLUDING DATA';
      EXCEPTION WHEN OTHERS THEN
        t_error  := TRUE;
        t_sqltxt := SQLERRM;
        t_sqlcode  := SQLCODE;
        t_took_error := TRUE;
    END;

    IF t_error THEN
      IF result_txt IS NOT NULL THEN
        -- If not the first, add a crlf
        result_txt := result_txt || crlf;
      END IF;

      t_new_err :=
            '  Error upgrading: ' || t_full_name || crlf ||
            '  Error Text:      ' || t_sqltxt || crlf;

      --
      --  length returns NULL (and not zero) for null varchar2's
      --
      t_len := NVL(length(result_txt), 0);

      IF (t_len + length (t_new_err) <= c_str_max) THEN
        --
        -- will fit into our buffer
        --
        result_txt := result_txt || t_new_err;
      ELSE
        t_new_err := crlf ||
           '  *** Too Many Tables ***' || crlf ||
           '  *** Cleanup and re-execute to see more tables *** ';
        --
        -- see if this will fit on the end (should be
        -- shorter than the actual error)
        --
        IF (t_len + length (t_new_err) < c_str_max) THEN
          -- Fits
          result_txt := result_txt || t_new_err;
        ELSE
          --
          -- Won't fit, cut some off and add the above error
          --
          result_txt := substr (result_txt, 1, t_len -
                                    length(t_new_err));
          result_txt := result_txt || t_new_err;
        END IF;
        -- We are done.
        EXIT;   -- Out of the loop
      END IF;
      t_error := FALSE;  -- Reset error
    END IF;
  END LOOP;

  IF t_took_error THEN
    pSqlcode := t_sqlcode;  -- Return the last failure code
    RETURN c_failure;
  ELSE
    RETURN c_success;
  END IF;
END invalid_usr_tabledata_fixup;

FUNCTION invalid_sys_tabledata_check (result_txt OUT CLOB) RETURN NUMBER
IS
  query  VARCHAR2(4000);
BEGIN
  -- Use schemas from registry$ tables and from user$ (12.1)
  query := 'SELECT NULL 
  FROM sys.obj$ o, sys.col$ c, sys.coltype$ t       
  WHERE BITAND(t.flags, 256) = 256 -- DATA_UPGRADED = NO            
    AND o.obj# = t.obj# AND c.OBJ# = t.obj#         
    AND c.COL# = t.col# AND t.intcol# = c.intcol#   
    AND o.type# = 2 AND o.owner# IN                 
       (SELECT schema# FROM sys.registry$ WHERE namespace = ''SERVER''              
        UNION                                         
        SELECT schema# FROM sys.registry$schemas WHERE namespace = ''SERVER''
        UNION
        SELECT user# FROM user$ WHERE type#=1 AND bitand(spare1,256)=256)
    AND ROWNUM <=1';

  IF NOT select_has_rows(query) THEN
      RETURN c_success;
  END IF;
  -- An Oracle-Supplied table needing to be upgraded has been found
  result_txt := get_failed_check_xml('invalid_sys_tabledata',
                      new string_array_t(db_version_4_dots),
                      null, null);
  RETURN c_failure;
END invalid_sys_tabledata_check;

--
-- Fixup invalid_sys_tabledata_fixup
--
FUNCTION invalid_sys_tabledata_fixup (
         result_txt IN OUT VARCHAR2,
         pSqlcode    IN OUT NUMBER) RETURN number
IS
  t_full_name  VARCHAR2(261); -- extra for quotes and . 
  t_sqltxt     VARCHAR2(4000);
  t_new_err    VARCHAR2(500);
  t_error      BOOLEAN := FALSE;
  t_took_error BOOLEAN := FALSE;
  t_sqlcode    NUMBER;  -- The last sql error we took
  t_len        NUMBER;
  CURSOR t_tabs IS
     SELECT DISTINCT u.name owner, o.name name
     FROM sys.obj$ o, sys.user$ u, sys.col$ c, sys.coltype$ t
     WHERE bitand(t.flags,256) = 256  -- NOT upgraded
       AND t.intcol# = c.intcol# AND t.col# = c.col# 
       AND t.obj# = c.obj# AND c.obj# = o.obj# 
       AND o.type# = 2 AND o.owner# = u.user#
       AND o.owner# IN 
          (SELECT distinct schema# FROM sys.registry$ WHERE NAMESPACE = 'SERVER'
           UNION 
           SELECT DISTINCT schema# FROM sys.registry$schemas WHERE NAMESPACE = 'SERVER'
           UNION
           SELECT user# FROM user$ WHERE type#=1 AND bitand(spare1,256)=256);
BEGIN
  result_txt := '';

  FOR tab IN t_tabs LOOP
    BEGIN
      t_full_name :=  dbms_assert.enquote_name(tab.owner, FALSE) || '.' || 
                      dbms_assert.enquote_name(tab.name,FALSE);
      EXECUTE IMMEDIATE 'ALTER TABLE ' ||  t_full_name 
                 || ' UPGRADE INCLUDING DATA';
      EXCEPTION WHEN OTHERS THEN
        t_error  := TRUE;
        t_sqltxt := SQLERRM;
        t_sqlcode  := SQLCODE;
        t_took_error := TRUE;
    END;

    IF t_error THEN
      IF result_txt IS NOT NULL THEN
        -- If not the first, add a crlf
        result_txt := result_txt || crlf;
      END IF;

      t_new_err := 
            '  Error upgrading: ' || t_full_name || crlf ||
            '  Error Text:      ' || t_sqltxt || crlf;

      --
      --  length returns NULL (and not zero) for null varchar2's 
      --
      t_len := NVL(length(result_txt), 0);

      IF (t_len + length (t_new_err) <= c_str_max) THEN
        --
        -- will fit into our buffer
        --
        result_txt := result_txt || t_new_err;
      ELSE
        t_new_err := crlf || 
           '  *** Too Many Tables ***' || crlf ||
           '  *** Cleanup and re-execute to see more tables *** ';
        --
        -- see if this will fit on the end (should be 
        -- shorter than the actual error)
        --
        IF (t_len + length (t_new_err) < c_str_max) THEN
          -- Fits
          result_txt := result_txt || t_new_err;  
        ELSE 
          -- 
          -- Won't fit, cut some off and add the above error
          --
          result_txt := substr (result_txt, 1, t_len - 
                              length(t_new_err) - 1);
          result_txt := result_txt || t_new_err;
        END IF;
        -- We are done.
        EXIT;   -- Out of the loop
      END IF;
      t_error := FALSE;  -- Reset error
    END IF;
  END LOOP;

  IF t_took_error THEN
    pSqlcode := t_sqlcode;  -- Return the last failure code
    return c_failure;
  ELSE
    return c_success;
  END IF;
END;

FUNCTION enabled_indexes_tbl_check (result_txt OUT CLOB) RETURN NUMBER
IS
  status  NUMBER := 0;
  t_count   INTEGER;
BEGIN
    --
    -- Check for pre-existing temporary table sys.enabled$indexes.
    -- If it exists, then warn the user to DROP SYS.ENABLED$INDEXES.
    --
    BEGIN
        EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM sys.enabled$indexes'
        INTO t_count;
        IF (t_count >= 0) THEN
            status := 1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    IF (status = 0) THEN
        RETURN c_success;
    ELSE
         result_txt := get_failed_check_xml('enabled_indexes_tbl',
                      new string_array_t(),
                      null, null);
    return c_failure;
    END IF;
END enabled_indexes_tbl_check;

--
-- Fixup enabled_indexes_tbl_fixup
--
FUNCTION enabled_indexes_tbl_fixup (
         result_txt IN OUT VARCHAR2,
         pSqlcode    IN OUT NUMBER) RETURN NUMBER
IS
    drop_result BOOLEAN;
BEGIN
   drop_result := execute_sql_statement ('DROP TABLE sys.enabled$indexes', result_txt, pSqlcode);
   IF drop_result THEN
       RETURN c_success;
   ELSE
       RETURN c_failure;
   END IF;
END enabled_indexes_tbl_fixup;



FUNCTION ordimageindex_check (result_txt OUT CLOB) RETURN NUMBER
IS
  t_count NUMBER := 0;
  status  NUMBER;
BEGIN
  --
  -- The upgrade will remove them, so the misc warning section will
  -- let them know.
  --
  BEGIN
    EXECUTE IMMEDIATE
     'SELECT COUNT(*) FROM sys.dba_indexes WHERE index_type = ''DOMAIN''
         and ityp_name = ''ORDIMAGEINDEX'''
   INTO t_count;
  EXCEPTION
     WHEN OTHERS THEN NULL;
  END;

  IF (t_count = 0) THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('ordimageindex',
                      new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS),
                      null, null);
    RETURN c_failure;
   END IF;
END ordimageindex_check;



FUNCTION invalid_objects_exist_check (result_txt OUT CLOB) RETURN NUMBER
IS
  t_null              CHAR(1);
  invalid_objs        BOOLEAN := FALSE;
  t_invalid_objs      NUMBER;
BEGIN
  --
  -- Check for INVALID objects
  -- For "inplace" upgrades check for invalid objects that can be excluded
  -- as they may have changed between releases and don't need to be reported.
  --
  -- For all other types of upgrades, use the simple query below to
  -- eliminate running the intricate queries except when they are needed.
  --
  BEGIN
    IF NOT db_inplace_upgrade  THEN
      EXECUTE IMMEDIATE 'SELECT NULL FROM sys.dba_objects
          WHERE status = ''INVALID'' AND object_name NOT LIKE ''BIN$%'' AND
             rownum <=1'
      INTO t_null;
      -- For patch release - update the objects in the query below
    ELSE
      -- V_$ROLLNAME special cased because of references  to x$ tables
      EXECUTE IMMEDIATE 'SELECT NULL FROM SYS.DBA_OBJECTS
           WHERE status = ''INVALID'' AND object_name NOT LIKE ''BIN$%'' AND
              rownum <=1 AND
              object_name NOT IN
                 (SELECT name FROM SYS.dba_dependencies
                    START WITH referenced_name IN (
                         ''V$LOGMNR_SESSION'', ''V$ACTIVE_SESSION_HISTORY'',
                         ''V$BUFFERED_SUBSCRIBERS'',  ''GV$FLASH_RECOVERY_AREA_USAGE'',
                         ''GV$ACTIVE_SESSION_HISTORY'', ''GV$BUFFERED_SUBSCRIBERS'',
                         ''V$RSRC_PLAN'', ''V$SUBSCR_REGISTRATION_STATS'',
                         ''GV$STREAMS_APPLY_READER'',''GV$ARCHIVE_DEST'',
                         ''GV$LOCK'',''DBMS_STATS_INTERNAL'',''V$STREAMS_MESSAGE_TRACKING'',
                         ''GV$SQL_SHARED_CURSOR'',''V$RMAN_COMPRESSION_ALGORITHM'',
                         ''V$RSRC_CONS_GROUP_HISTORY'',''V$PERSISTENT_SUBSCRIBERS'',''V$RMAN_STATUS'',
                         ''GV$RSRC_CONSUMER_GROUP'',''V$ARCHIVE_DEST'',''GV$RSRCMGRMETRIC'',
                         ''GV$RSRCMGRMETRIC_HISTORY'',''V$PERSISTENT_QUEUES'',''GV$CPOOL_CONN_INFO'',
                         ''GV$RMAN_COMPRESSION_ALGORITHM'',''DBA_BLOCKERS'',''V$STREAMS_TRANSACTION'',
                         ''V$STREAMS_APPLY_READER'',''GV$SGA_DYNAMIC_FREE_MEMORY'',''GV$BUFFERED_QUEUES'',
                         ''GV$RSRC_PLAN_HISTORY'',''GV$ENCRYPTED_TABLESPACES'',''V$ENCRYPTED_TABLESPACES'',
                         ''GV$RSRC_CONS_GROUP_HISTORY'',''GV$RSRC_PLAN'',
                         ''GV$RSRC_SESSION_INFO'',''V$RSRCMGRMETRIC'',''V$STREAMS_CAPTURE'',
                         ''V$RSRCMGRMETRIC_HISTORY'',''GV$STREAMS_TRANSACTION'',''DBMS_LOGREP_UTIL'',
                         ''V$RSRC_SESSION_INFO'',''GV$STREAMS_CAPTURE'',''V$RSRC_PLAN_HISTORY'',
                         ''GV$FLASHBACK_DATABASE_LOGFILE'',''V$BUFFERED_QUEUES'',
                         ''GV$PERSISTENT_SUBSCRIBERS'',''GV$FILESTAT'',''GV$STREAMS_MESSAGE_TRACKING'',
                         ''V$RSRC_CONSUMER_GROUP'',''V$CPOOL_CONN_INFO'',''DBA_DML_LOCKS'',
                         ''V$FLASHBACK_DATABASE_LOGFILE'',''GV$HM_RECOMMENDATION'',
                         ''V$SQL_SHARED_CURSOR'',''GV$PERSISTENT_QUEUES'',''GV$FILE_HISTOGRAM'',
                         ''DBA_WAITERS'',''GV$SUBSCR_REGISTRATION_STATS'')
                                AND referenced_type in (''VIEW'',''PACKAGE'') OR
                          name = ''V_$ROLLNAME''
                             CONNECT BY
                               PRIOR name = referenced_name and
                               PRIOR type = referenced_type)'
      INTO t_null;
    END IF;
    invalid_objs := TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
  END;

 -- look for invalid objects
  EXECUTE IMMEDIATE 'SELECT count(*) FROM sys.dba_objects 
  WHERE status !=''VALID'' ' INTO t_invalid_objs;

  --
  -- Now get back to reporting the issue if we need to.
  --
  IF invalid_objs = FALSE THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('invalid_objects_exist',
                      new string_array_t(db_version_4_dots, t_invalid_objs),
                      null, null);

    RETURN c_failure;
  END IF;
END invalid_objects_exist_check;


FUNCTION amd_exists_check (result_txt OUT CLOB) RETURN NUMBER
IS
  n_status NUMBER := -1;
BEGIN
  --
  -- Is AMD around?
  --
  BEGIN
    EXECUTE IMMEDIATE
       'SELECT  status FROM sys.registry$ WHERE cid=''AMD''
          AND namespace=''SERVER'''
       INTO n_status;
  EXCEPTION
      WHEN OTHERS THEN NULL; -- AMD not in registry
  END;

  IF (n_status = -1) THEN
    -- AMD not in registry
    -- or output is XML, return success
    RETURN c_success;
  END IF;

  --
  -- This is a manual only check
  --
  result_txt := get_failed_check_xml('amd_exists',
                    new string_array_t(db_version_4_dots),
                    null, null);

  RETURN c_failure;
END amd_exists_check;


FUNCTION exf_rul_exists_check (result_txt OUT CLOB) RETURN NUMBER
IS
  n_status NUMBER := -1;
BEGIN
  --
  -- See if EXF and/or RUL components exist, they will be
  -- removed during the upgrade so let them know they can remove them
  -- before the upgrade.
  --
  BEGIN
    EXECUTE IMMEDIATE
       'SELECT  status FROM sys.registry$ WHERE (cid=''RUL'' OR cid=''EXF'')
          WHERE namespace=''SERVER'''
       INTO n_status;
  EXCEPTION
      WHEN OTHERS THEN NULL; -- EXF or RUL not in registry
  END;

  IF (n_status = -1) THEN
    --
    -- does not exist
    --
    RETURN c_success;
  END IF;

  result_txt := get_failed_check_xml('exf_rul_exists',
                    new string_array_t(),
                    null, null);

  RETURN c_failure;
END exf_rul_exists_check;


FUNCTION new_time_zones_exist_check (result_txt OUT CLOB) RETURN NUMBER
IS
  status NUMBER;
BEGIN
  IF (db_tz_version <= &C_LTZ_CONTENT_VER) THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('new_time_zones_exist',
                    new string_array_t(db_version_4_dots, to_char(db_tz_version),C_ORACLE_HIGH_VERSION_4_DOTS,to_char(&C_LTZ_CONTENT_VER)),
                    null, null);
    RETURN c_failure;
  END IF;
END new_time_zones_exist_check;


FUNCTION old_time_zones_exist_check (result_txt OUT CLOB) RETURN NUMBER
IS
  status  NUMBER;
BEGIN
  --
  -- Do we have a valid time zone for an upgrade
  --
  IF (db_tz_version >= &C_LTZ_CONTENT_VER) THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('old_time_zones_exist',
                    new string_array_t(db_version_4_dots, to_char(db_tz_version),C_ORACLE_HIGH_VERSION_4_DOTS,to_char(&C_LTZ_CONTENT_VER)),
                    null, null);
    RETURN c_failure;
  END IF;
END old_time_zones_exist_check;


FUNCTION olap_page_pool_size_check (result_txt OUT CLOB) RETURN NUMBER
IS
  status NUMBER;
BEGIN
     -- skip check if olap_page_pool_size not in all_parameters
     IF (all_parameters.exists('olap_page_pool_size') = FALSE) THEN
       RETURN c_success;
     END IF;

    -- if olap_page_pool_size has not been set explicitly, return success
    IF (all_parameters('olap_page_pool_size').isdefault = 'TRUE') THEN
      RETURN c_success;
    END IF;
      
    -- if olap_page_pool_size is non-zero, then return failure
    IF (all_parameters('olap_page_pool_size').value > 0) THEN
      result_txt := get_failed_check_xml('olap_page_pool_size',
                        new string_array_t(), null, null);
      RETURN c_failure;
    ELSE
      RETURN c_success;
    END IF;
END olap_page_pool_size_check;

FUNCTION purge_recyclebin_check (result_txt OUT CLOB) RETURN NUMBER
IS
  obj_count NUMBER;
BEGIN
   EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM sys.recyclebin$'
     INTO obj_count;

  IF (obj_count = 0) THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('purge_recyclebin',
                    new string_array_t(to_char(obj_count)),
                    null, null);
    RETURN c_failure;
  END IF;
END purge_recyclebin_check;

FUNCTION purge_recyclebin_fixup (
         result_txt IN OUT VARCHAR2,
         pSqlcode    IN OUT NUMBER) RETURN number
IS
    fixup_result BOOLEAN;
BEGIN
   fixup_result := execute_sql_statement ('PURGE DBA_RECYCLEBIN', result_txt, pSqlcode);
   if fixup_result then
      return c_success;
   else
      return c_failure;
   end if;
END purge_recyclebin_fixup;


FUNCTION job_queue_process_0_check (result_txt OUT CLOB) RETURN NUMBER
IS
BEGIN

  IF select_number('SELECT value FROM v$parameter WHERE
          name=''job_queue_processes''', -1) <> 0 THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('job_queue_process_0',
                    new string_array_t(),
                    null, null);

    RETURN c_failure;
  END IF;
END job_queue_process_0_check;


FUNCTION upg_by_std_upgrd_check (result_txt OUT CLOB) RETURN NUMBER
IS
  my_components_list VARCHAR2(4000) := ' ';
  not_my_components_list VARCHAR2(4000) := ' ';
  all_components_mine BOOLEAN := TRUE;
  not_my_comps_cursor cursor_t;
  c_cname SYS.REGISTRY$.CNAME%TYPE;
  select_stmt VARCHAR2(500);
BEGIN
  BEGIN
    -- construct a quoted and comma separated list of components that will
    -- be upgraded by the upgrade script.
    -- since the list of my components is known, this code won't overflow
    -- the my_components_list stringsize
    FOR i in 1..cmp_info.count LOOP
        IF cmp_info(i).cid = 'STATS' THEN
          --
          -- the "STATS" (aka MISC) component is a pseudo-component.
          -- it was created for computational convenience only.  Skip it from the XML.
          --
          continue;
        END IF;

        if (i > 1) THEN
            my_components_list := my_components_list || ',';
        END IF;
        IF debug THEN
            dbms_output.put_line('In upg_by_std_upgrd check,i=' || to_char(i));
        END IF;

        my_components_list := my_components_list || dbms_assert.enquote_literal(cmp_info(i).cid);
    END LOOP;

    IF debug THEN
        dbms_output.put_line('In upg_by_std_upgrd check, my_components_list=' || my_components_list);
    END IF;

    select_stmt := 'SELECT cname FROM sys.registry$ WHERE namespace=' ||
                   dbms_assert.enquote_literal('SERVER') ||
                   ' AND cid NOT IN (' ||
                   my_components_list ||
                   ')';
    OPEN not_my_comps_cursor FOR select_stmt;

    LOOP
        FETCH not_my_comps_cursor INTO c_cname;
        EXIT WHEN not_my_comps_cursor%NOTFOUND;

        IF debug THEN
            dbms_output.put_line('In upg_by_std_upgrd check, processing non-std component: ' || c_cname);
        END IF;

        IF (LENGTH(not_my_components_list) >= (c_str_max-length(c_cname)-12)) THEN
            -- the 12 above is the length of ' plus others ' below.  Save space for it
            -- in case we need it.
            not_my_components_list := not_my_components_list || ' plus others';
            EXIT;
        ELSE
            IF (NOT all_components_mine) THEN
                not_my_components_list := not_my_components_list || ',';
            END IF;
            not_my_components_list := not_my_components_list || c_cname;
        END IF;
        all_components_mine := FALSE;
    END LOOP;
    CLOSE not_my_comps_cursor;
  END;
  IF (all_components_mine) THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('upg_by_std_upgrd',
                    new string_array_t(not_my_components_list),
                    null, null);


    RETURN c_failure;
  END IF;
END upg_by_std_upgrd_check;


FUNCTION xbrl_version_check (result_txt OUT CLOB) RETURN NUMBER
IS
BEGIN
  IF NOT select_has_rows('SELECT NULL FROM sys.user$ WHERE name=''XBRLSYS''') THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('xbrl_version',
                    new string_array_t(),
                    null, null);
    RETURN c_failure;
  END IF;

END xbrl_version_check;


FUNCTION apex_manual_upgrade_check  (result_txt OUT CLOB) RETURN NUMBER
IS
  db_full_apex_version VARCHAR2(40);
BEGIN
  BEGIN
    SELECT version INTO db_full_apex_version 
    FROM sys.registry$ WHERE cid = 'APEX' and namespace='SERVER';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- no APEX, no problem.
      return c_success;
  END;
  
  --
  -- If the APEX major version is less than the required APEX minimum version, then
  -- the check does not pass, and customers must upgrade APEX before upgrading to
  -- the new SERVER release.
  --

  IF (dbms_registry_extended.compare_versions(db_full_apex_version, high_version_apex, 1) < 0)
    THEN
    result_txt := get_failed_check_xml('apex_manual_upgrade',
                    new string_array_t(db_full_apex_version, high_version_apex),
                    null, null);
    return c_failure;
  ELSE
    return c_success;
  END IF;
END apex_manual_upgrade_check;

-- *****************************************************************
--     default_resource_limit Section
--
-- 1) Initialization parameter RESOURCE_LIMIT 's default value is
--    changing from FALSE to TRUE starting in 12.1.0.2.
-- 2) Will warn customers about the default value changing.
--    This would only affect customers who have applied a resource limit
--    to a user and does not already have resource_limit set in their
--    parameter file.  If they don't have resource_limit set, which
--    means default is FALSE in pre-12102 but TRUE in 12102 and post-12102.
--
-- *****************************************************************
FUNCTION default_resource_limit_check (result_txt OUT CLOB) RETURN NUMBER
IS
  ret_val      NUMBER := 0;     -- return value from check_stmt
  check_stmt   VARCHAR2(1000);  -- check if resource_limit warning is needed
BEGIN

  --
  --    RESOURCE_LIMIT warning is needed IF 1 is returned because all conditions
  --    are met:
  --    a) if RESOURCE_LIMIT init parameter is currently using the default value
  --       AND
  --    b) there are non-default/non-unlimited customized resource limits
  --       applied to 1 or more users
  --       AND
  --    c) db-to-be-upgraded's version is at 12.1.0.1 or older
  --
  check_stmt :=
    'SELECT 1 FROM sys.v$parameter ' ||
    'WHERE ' ||
    '( ' ||                                                 -- criteria (a)
    '    (upper(name) = ''RESOURCE_LIMIT'' AND isdefault = ''TRUE'') ' ||
    '  AND ' ||                                             -- criteria (b)
    '    0 < (SELECT count(*) ' ||
    '         FROM sys.dba_users ' ||
    '         WHERE profile in ' ||
    '           (SELECT unique(profile) ' ||
    '            FROM sys.dba_profiles ' ||
    '            WHERE resource_type = ''KERNEL'' and ' ||
    '                  limit not in (''UNLIMITED'', ''DEFAULT'')) ' ||
    '        ) ' ||
    '  AND ' ||                                             -- criteria (c)
    '    1 = (SELECT count(*) ' ||
    '         FROM sys.registry$ ' ||
    '         WHERE ' ||
    '           upper(cid) = ''CATPROC'' AND ' ||
    '           (substr(version, 1, 4) in (''10.2'', ''11.1'', ''11.2'') ' ||
    '            OR substr(version, 1, 8) = ''12.1.0.1'') ' ||
    '        ) ' ||
    ')';

  -- check if a warning - about RESOURCE_LIMIT defaulting to TRUE starting
  -- in 12102 - needs to be generated
  BEGIN
    EXECUTE IMMEDIATE
       check_stmt
       INTO ret_val;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ret_val := 0;
    WHEN OTHERS THEN
      dbms_output.put_line('ORA' || SQLCODE ||
                           ': Error in DEFAULT_RESOURCE_LIMITS check_stmt:');
      dbms_output.put_line(SQLERRM);
  END; 

  -- return success status if check returns a 0
  -- i.e., don't generate warning if ret_val is 0 and do generate warning
  -- if ret_val is 1.
  IF (ret_val = 0) THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('default_resource_limit',
                    new string_array_t(db_version_4_dots),
                    null, null);

    RETURN c_failure;
  END IF;
END default_resource_limit_check;

--
-- BMMB
-- Bug 24923215: PREUPGADE TOOL TO SET_GLOBAL_PREFS('CONCURRENT','OFF'); FOR GATHER STATS
-- The conc_res_mgr check and its fixup handle when the Concurrent statistics preference
-- is enabled but Resoucer Manager is disabled.
--
FUNCTION conc_res_mgr_check (result_txt OUT CLOB) RETURN NUMBER
IS
    v_is_conc_on_boolean boolean := FALSE;
    v_is_res_man_on_boolean boolean := FALSE;
    v_conc_on_text varchar2(20);
    v_res_man_on_text V$PARAMETER.VALUE%TYPE;
    disable_conc_stats_text varchar2(75);
    
BEGIN
    --
    -- is concurrent preference set to on?
    -- 
    BEGIN
        EXECUTE IMMEDIATE
         'SELECT DBMS_STATS.GET_PREFS(''CONCURRENT'') FROM DUAL'
         INTO v_conc_on_text;
        
        -- 
        -- In 11.2 concurrent statistics preference had only two values, TRUE and FALSE.
        -- Starting 12.1 It can have four values: MANUAL, AUTOMATIC, ALL and OFF.
        -- FALSE or OFF mean that the concurrent preference is disabled
        IF (v_conc_on_text not in ('OFF', 'FALSE' )) THEN  -- If it is disabled.
            v_is_conc_on_boolean := TRUE;
        ELSE
	    return c_success;  -- CONCURRENT STATS ARE DISABLED so we do not need to check anything further.
        END IF;
        
    -- The query should return any value (FALSE OR OFF) if not it means 
    -- something happened at db level. Raise an exception.   
    END;
    --
    -- is Resourcer manager on?
    --
    BEGIN
        EXECUTE IMMEDIATE
         'select nvl(value, ''DISABLED'') from v$parameter where name = ''resource_manager_plan'''
         INTO v_res_man_on_text;
         
        IF (v_res_man_on_text != 'DISABLED') THEN
            v_is_res_man_on_boolean := TRUE;
        END IF;        
    -- IF Resource manager is disabled the query will return no values. 
    -- If there is any other error then raise an exception.
    END;
    
    IF (db_version_1_dot = '11.2') THEN
        disable_conc_stats_text := 'DBMS_STATS.SET_GLOBAL_PREFS(''CONCURRENT'',''FALSE'')';
    ELSE
        disable_conc_stats_text := 'DBMS_STATS.SET_GLOBAL_PREFS(''CONCURRENT'',''OFF'')';
    END IF;    
    
    --
    -- check if the concurrent statistics preferences is on
    -- and if Resource Manager is enabled
    -- The validation that will trigger the c_failure condition is:
    -- is_conc_pref is TRUE and is_res_man is FALSE
    --
    IF (v_is_conc_on_boolean AND NOT v_is_res_man_on_boolean) THEN
        result_txt := get_failed_check_xml('conc_res_mgr',
                    new string_array_t(v_conc_on_text, disable_conc_stats_text),
                    null, null);
        return c_failure;
    END IF;
    
    return c_success;
EXCEPTION WHEN NO_DATA_FOUND THEN
        internal_error('Could not determine the status of Concurrent statistics or Resource manager.');
    WHEN OTHERS THEN
        RAISE; 
           
END conc_res_mgr_check;

FUNCTION conc_res_mgr_fixup             (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN number
IS
    disable_conc_stats_result BOOLEAN;
    disable_conc_stats_text varchar2(50);
BEGIN

  IF (db_version_1_dot = '11.2') THEN
    disable_conc_stats_text := 'DBMS_STATS.SET_GLOBAL_PREFS(''CONCURRENT'',''FALSE'')';
  ELSE
    disable_conc_stats_text := 'DBMS_STATS.SET_GLOBAL_PREFS(''CONCURRENT'',''OFF'')';
  END IF;

   disable_conc_stats_result := run_int_proc(disable_conc_stats_text, result_txt, pSqlcode);
   
   IF (disable_conc_stats_result) THEN
       RETURN c_success;
   ELSE
       RETURN c_failure;
   END IF; 

EXCEPTION WHEN OTHERS THEN 
    RAISE;    

END conc_res_mgr_fixup;

FUNCTION dictionary_stats_check (result_txt OUT CLOB) RETURN NUMBER
IS
dictionary_stats_recent  NUMBER;
doc_name                 VARCHAR2(80) := '';  -- holds the name of the doc that
                                              -- points to the section on
                                              -- managing optimizer statistics

BEGIN
  dictionary_stats_recent := select_number(' select 1 from dual where exists(
          select distinct operation 
        from DBA_OPTSTAT_OPERATIONS 
            where operation =''gather_dictionary_stats'' 
            and start_time > systimestamp -  INTERVAL ''24''  HOUR) ' , 0);

  IF (dictionary_stats_recent = 1)
  THEN
    RETURN c_success;
  ELSE

  doc_name := db_version_3_dots;
  IF (db_version_1_dot = '11.2') THEN
    doc_name := doc_name || ' Oracle Database Performance Tuning Guide';
  ELSIF (db_version_1_dot = '12.1' OR db_version_3_dots = '12.2.0.1') THEN
    doc_name := doc_name || ' Oracle Database SQL Tuning Guide';
  ELSE
    doc_name := doc_name || ' Oracle Database Upgrade Guide';
  END IF;

  result_txt := get_failed_check_xml('dictionary_stats',
                                      new string_array_t(doc_name),  -- {1}
                                      null, null);
  RETURN c_failure;


  END IF;
END dictionary_stats_check;


-- *****************************************************************
--     This fixup executes dictionary stats pre upgrade
-- *****************************************************************
FUNCTION dictionary_stats_fixup          (
         result_txt IN OUT VARCHAR2,
         pSqlcode    IN OUT NUMBER) RETURN NUMBER
IS
    stats_result BOOLEAN;
    sys_string varchar2(5):='SYS';
BEGIN
   stats_result := run_int_proc('DBMS_STATS.GATHER_DICTIONARY_STATS', result_txt, pSqlcode);
   
   IF (stats_result) THEN
       RETURN c_success;
   ELSE
       RETURN c_failure;
   END IF; 
END dictionary_stats_fixup;

FUNCTION hidden_params_check (result_txt OUT CLOB) RETURN NUMBER
IS
  hidden_params_cursor  cursor_t;
  hidden_param          SYS.V$PARAMETER.NAME%TYPE;
  hidden_param_count    NUMBER := 0;
  hidden_params         VARCHAR2(4000) := '';
  in_rolling_upgrade    VARCHAR2(10);
BEGIN

    OPEN hidden_params_cursor FOR 'SELECT name FROM sys.v$parameter WHERE ' ||
        'name LIKE ''\_%'' ESCAPE ''\'' AND name <> ''_oracle_script'' AND ismodified != ''MODIFIED''';

    LOOP
        FETCH hidden_params_cursor INTO hidden_param;
        EXIT WHEN hidden_params_cursor%NOTFOUND;
        BEGIN
            -- Verify the hidden_param is not marked as obsolete
            -- because it could be removed, if so, avoid put it
            -- in the recommendation section to do not cause confusion
            IF NOT all_parameters(hidden_param).is_obsoleted OR
               all_parameters(hidden_param).is_obsoleted IS NULL THEN

                IF hidden_param = '_allow_compatibility_adv_w_grp' THEN
                    -- if we're in a rolling upgrade context
                    -- do not flag _allow_compatibility_adv_w_grp as a
                    -- hidden parameter.
                    BEGIN
                        EXECUTE IMMEDIATE 'SELECT sys_context(''userenv'',''IS_DG_ROLLING_UPGRADE'') FROM DUAL'
                            INTO in_rolling_upgrade;
                        IF in_rolling_upgrade = 'TRUE' THEN
                            CONTINUE;
                        END IF;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            -- pre 12.1.0.1 versions of Oracle do not have IS_DG_ROLLING_UPGRADE
                            NULL;
                    END;
                END IF;
                hidden_param_count := hidden_param_count + 1;
                IF (hidden_param_count > 1) THEN
                    hidden_params := hidden_params || '<br>';
                END IF;
                -- more than 48 might cause overflow, max name length 80 chars
                IF ( hidden_param_count > 48 ) THEN
                    hidden_params := hidden_params || '(list truncated)';
                    exit;
                ELSE
                    hidden_params := hidden_params || hidden_param;
                END IF;
            END IF;
         EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;    

    END LOOP;
    CLOSE hidden_params_cursor;

    IF (hidden_param_count = 0) THEN
        RETURN c_success;
    ELSE
        result_txt := get_failed_check_xml('hidden_params',
                        new string_array_t(hidden_params),
                        null, null);
        RETURN c_failure;
    END IF;
END hidden_params_check;


FUNCTION underscore_events_check (result_txt OUT CLOB) RETURN NUMBER
IS
    underscore_event_count NUMBER := 0;
BEGIN
    --
    -- underscore events that are set.
    --
    BEGIN
      EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM sys.v$parameter2 WHERE (UPPER(name) = ''EVENT''
           OR UPPER(name)=''_TRACE_EVENTS'') AND isdefault=''FALSE'''
      INTO underscore_event_count;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

    IF (underscore_event_count = 0) THEN
        RETURN c_success;
    ELSE
        result_txt := get_failed_check_xml('underscore_events',
                        new string_array_t(db_version_4_dots),
                        null, null);
        RETURN c_failure;
    END IF;
END underscore_events_check;


FUNCTION audit_records_check (result_txt OUT CLOB) RETURN NUMBER
IS
  t_boolean BOOLEAN;
  t_status  NUMBER;
  audit_record_threshold NUMBER := 250000;
  audit_record_count NUMBER;
BEGIN
    t_boolean := FALSE;
    t_status := 0;
    -- There are three checks here - for various options of audit records.
    BEGIN
      EXECUTE IMMEDIATE 'SELECT count(*) FROM sys.aud$ WHERE dbid is null'
      INTO t_status;
      IF t_status > audit_record_threshold THEN
        t_boolean := TRUE;
        audit_record_count := t_status;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
    BEGIN
      -- Standard Auditing, only when Oracle Label Security (OLS)
      -- and/or Database Vault (DV) is installed
      EXECUTE IMMEDIATE 'SELECT count(*) FROM system.aud$ WHERE dbid is null'
      INTO t_status;
      IF t_status > audit_record_threshold THEN
        t_boolean := TRUE;
        audit_record_count := t_status;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
    BEGIN
      -- Fine Grained Auditing
      EXECUTE IMMEDIATE 'SELECT count(*) FROM sys.fga_log$ WHERE dbid is null'
      INTO t_status;
      IF t_status > audit_record_threshold THEN
        t_boolean := TRUE;
        audit_record_count := t_status;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

    IF t_boolean THEN
        result_txt := get_failed_check_xml('audit_records',
                        new string_array_t(to_char(audit_record_count)),
                        null, null);
        RETURN c_failure;
    ELSE
        RETURN c_success;
    END IF;
END audit_records_check;

-- *****************************************************************
--     FIXED_OBJECTS_CHECK Section
-- This check recommends gathering fixed objetcs stats post upgrade
-- *****************************************************************
FUNCTION post_fixed_objects_check            (result_txt OUT CLOB) RETURN NUMBER
IS
doc_name              VARCHAR2(80) := '';

BEGIN
-- this CHECK always fails... it always produces the recommendations.

   doc_name := db_version_3_dots;

   IF (db_version_1_dot = '11.2') THEN
     doc_name := doc_name || ' Oracle Database Performance Tuning Guide';
   ELSIF (db_version_1_dot = '12.1' OR db_version_3_dots = '12.2.0.1') THEN
     doc_name := doc_name || ' Oracle Database SQL Tuning Guide';
   ELSE
     doc_name := doc_name || ' Oracle Database Upgrade Guide';
   END IF;

   result_txt := get_failed_check_xml('post_fixed_objects',
                                      new string_array_t(doc_name),
                                      null, null);

   RETURN c_failure;
END post_fixed_objects_check;


-- *****************************************************************
--     POST_DICTIONARY_CHECK Section
--     This check recommends re-gathering dictionary stats post upgrade
--     The logic in the query is:  Check if statistics has been taken
--     after upgrade, if not report it and generate the fixup in the
--     postupgrade fixup script, after the fixup run, it will not fail
--     and therefore it will report this check as successfull.
-- *****************************************************************
FUNCTION post_dictionary_check (result_txt OUT CLOB) RETURN NUMBER
IS
dictionary_stats_recent  NUMBER;
correct_version boolean := TRUE;

BEGIN
  IF dbms_registry_extended.compare_versions(db_version_4_dots, C_ORACLE_HIGH_VERSION_4_DOTS, 4) < 0 THEN
     correct_version := FALSE; 
  END IF;

  dictionary_stats_recent := select_number('select 1 from dual where exists(
          select distinct operation 
        from DBA_OPTSTAT_OPERATIONS 
            where operation =''gather_dictionary_stats'' 
            and start_time > (select max(OPTIME) from registry$log
            where cid =''UPGRD_END'')) ', 0);

  IF (dictionary_stats_recent = 1 and correct_version)
  THEN
    RETURN c_success;
  ELSE
    -- this CHECK always fails... it always produces the recommendations.
    result_txt := get_failed_check_xml('post_dictionary',
                    new string_array_t(),
                    null, null);

    RETURN c_failure;
  END IF; 
END post_dictionary_check;

-- *****************************************************************
--     This fixup executes dictionary stats post upgrade
-- *****************************************************************
FUNCTION post_dictionary_fixup (
         result_txt IN OUT VARCHAR2,
         pSqlcode    IN OUT NUMBER) RETURN NUMBER
IS
    stats_result BOOLEAN;
    sys_string varchar2(5):='SYS';
BEGIN
   stats_result := run_int_proc('DBMS_STATS.GATHER_DICTIONARY_STATS', result_txt, pSqlcode);
   IF (stats_result) THEN
       RETURN c_success;
   ELSE
       RETURN c_failure;
   END IF; 
END post_dictionary_fixup;


-- *****************************************************************
--     This function is meant to run any internal  procedure 
--     such as dbms_stats and others, calls execute_sql_statement
--     but let the function to run procedures and returns a boolean
--     to report if the procedure could run or not.
-- *****************************************************************

FUNCTION run_int_proc (statement VARCHAR2,
         result_txt IN OUT VARCHAR2,
         pSqlcode    IN OUT NUMBER) RETURN BOOLEAN
IS
    stats_result BOOLEAN;
BEGIN
   stats_result := execute_sql_statement ('begin '|| statement ||'; end;', 
                                           result_txt,   pSqlcode);
   RETURN stats_result;
END run_int_proc;

-- *****************************************************************
--     COMPATIBLE_NOT_SET_CHECK Section
-- This check verifies that the compatible parameter is defined,
-- if is not set, the check alerts to the user through an error
-- *****************************************************************
FUNCTION compatible_not_set_check (result_txt OUT CLOB) RETURN NUMBER
IS
BEGIN
    -- TRUE means default, FALSE means parameter was set manually    
    IF (all_parameters.exists('compatible') AND
        all_parameters('compatible').isdefault = 'FALSE') THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('compatible_not_set',
                    new string_array_t(),
                    null, null);
    RETURN c_failure;
  END IF;
END compatible_not_set_check;


FUNCTION overlap_network_acl_check (result_txt OUT CLOB) RETURN number
IS
  overlap_acl_exists NUMBER := 0;

BEGIN
  BEGIN
    EXECUTE IMMEDIATE
      'select 1 from dual where exists
      (select * from sys.net$_acl n1, sys.net$_acl n2
        where n1.host = n2.host and
        not (n1.lower_port = n2.lower_port and n2.upper_port = n1.upper_port) and
        ((n1.lower_port <= n2.lower_port and n2.lower_port <= n1.upper_port) or
         (n1.lower_port <= n2.upper_port and n2.upper_port <= n1.upper_port) or
         (n2.lower_port <= n1.lower_port and n1.lower_port <= n2.upper_port) or
         (n2.lower_port <= n1.upper_port and n1.upper_port <= n2.upper_port)))'
      INTO overlap_acl_exists;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  IF (overlap_acl_exists = 0)
  THEN
    RETURN c_success;
  ELSE

    result_txt := get_failed_check_xml('overlap_network_acl',
                  new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS),
                  null, null);
        RETURN c_failure;
  END IF;
END overlap_network_acl_check;


FUNCTION repcat_setup_check (result_txt OUT CLOB) RETURN NUMBER
IS
  repcat_setup NUMBER; 
  master_site number;
  masterdef number;
  mv_site number;
  mv_master number;
  detail varchar2(1000) := '';
BEGIN
  repcat_setup := 0;

  EXECUTE IMMEDIATE 'select count(*) from dba_repsites'
      INTO repcat_setup;

  IF repcat_setup = 0
  THEN
     RETURN c_success;
  ELSE
     master_site := 0;
     masterdef := 0;
     mv_site := 0;
     mv_master := 0;

     EXECUTE IMMEDIATE 'select count(*) from dba_repsites where dblink = ora_database_name and master = ''Y'' '
         INTO master_site;

     EXECUTE IMMEDIATE 'select count(*) from dba_repsites where dblink = ora_database_name and masterdef = ''Y'' '
         INTO masterdef;

     EXECUTE IMMEDIATE  'select count(*) from dba_repobject where type = ''MATERIALIZED VIEW'' '
         INTO mv_site;

     EXECUTE IMMEDIATE 'select count(*) from dba_repsites where dblink = ora_database_name and snapmaster = ''Y'' '
         INTO mv_master;

     IF masterdef > 0 THEN
         detail := detail ||
           '     o Master definition found.'||crlf||
           '       it is advised to remove all Master sites first.'||crlf||
           '       for more information look at section 7-31 of the '||crlf||
           '       Oracle Database Advanced Replication Management API Reference.';

     ELSIF master_site > 0 THEN
         detail := detail ||
           '     o Master site found.'||crlf||
           '       Steps to remove a Master site can be found' ||crlf||
           '       at section 7-31 of the Oracle Database Advanced Replication'
                   ||crlf||
           '       Management API Reference.';
     END IF;

     IF mv_master > 0 THEN
         detail := detail ||
           '     o Materialized View Master found.'
                 ||crlf||
           '       It is advised to remove all Materialized View sites first.'
                 ||crlf||
           '       for more information look at sections 8-1 to 8-10 of the'
                 ||crlf||
           '       Oracle Database Advanced Replication Management API Reference.';

     ELSIF mv_site > 0 THEN
         detail := detail ||
             '   o Materialized View site found.'
                   ||crlf||
             '     Steps to remove a MV site can be found'
                   ||crlf||
             '     at section 8-8 of the Oracle Database Advanced Replication'
                   ||crlf||
             '     Management API Reference.';
     END IF;

     result_txt := get_failed_check_xml('repcat_setup',
                     new string_array_t(),
                     'TEXT', detail);

     RETURN c_failure;
  END IF; 

  RETURN c_success;

 EXCEPTION WHEN OTHERS THEN  
   IF sqlcode = -942 THEN
     return c_success;
   END IF;
END repcat_setup_check;



-- *****************************************************************
--     OLS_VERSION_CHECK Section
-- This check verifies that the OLS version is same as CATPROC version
-- or is supported for direct upgrade. If not, the check alerts to the
-- user through an error.
-- *****************************************************************
FUNCTION ols_version_check (result_txt OUT CLOB) RETURN NUMBER
IS
catproc_version    sys.registry$.version%type;
ols_version        sys.registry$.version%type;
ols_version_3_dots sys.v$instance.version%type;
BEGIN
-- Lrg 18421763: Check whether OLS is installed
IF dbms_registry.is_loaded('OLS') IS NOT NULL THEN
  SELECT version INTO catproc_version FROM sys.registry$ 
  WHERE cid = 'CATPROC';

  SELECT version INTO ols_version FROM sys.registry$
  WHERE cid = 'OLS';

  ols_version_3_dots :=
    dbms_registry_extended.convert_version_to_n_dots(ols_version, 3);

  IF ((ols_version = catproc_version) OR 
     (instr(',&C_UPGRADABLE_VERSIONS,',
            ',' || ols_version_3_dots || ',') != 0))
  THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('ols_version',
                    new string_array_t(), null, null);
    RETURN c_failure;
  END IF;
ELSE
  RETURN c_success;
END IF;
END ols_version_check;


-- *****************************************************************
--     AUDSYS.AUD$UNIFIED Section
-- *****************************************************************
-- Bug 24741114: Do not raise pre-upgrade error if audsys.aud$unified table's
-- partitions are not Oracle maintained.
FUNCTION UNIAUD_TAB_check (result_txt OUT CLOB) RETURN number
IS
BEGIN

  IF NOT select_has_rows('SELECT NULL FROM sys.obj$ o WHERE o.NAME = ''AUD$UNIFIED''
    and ((o.namespace = 1 or o.type# = 2) and o.type# != 19) and o.owner# IN 
    (select u.user# from sys.user$ u where u.name = ''AUDSYS'') 
    and (bitand(o.flags, 4194304) != 4194304)') THEN
    RETURN c_success;
  END IF;
  result_txt := get_failed_check_xml('uniaud_tab',
                    new string_array_t(),
                    null, null);
  RETURN c_failure;
END UNIAUD_TAB_check;

-- ***********************************************************************
-- Bug 20950535 - HAVE PREUPGRD SCRIPT CHECK FOR MITIGATION PATCH 19721304 
-- This check verifies if javavm mitigation patch is installed and active 
-- in the DB.
-- ***********************************************************************
FUNCTION jvm_mitigation_patch_check (result_txt OUT CLOB) RETURN NUMBER
IS
BEGIN
    IF NOT select_has_rows('select null from sys.dba_triggers
        where trigger_name=''DBMS_JAVA_DEV_TRG'' and owner=''SYS''
        and status=''ENABLED''') THEN
        RETURN c_success;
    END IF;
    -- Java development is not allowed
    result_txt := get_failed_check_xml('jvm_mitigation_patch',
                    new string_array_t(db_version_4_dots,C_ORACLE_HIGH_VERSION_4_DOTS),
                    null, null);

    RETURN c_failure;
END jvm_mitigation_patch_check;

FUNCTION post_jvm_mitigat_patch_check (result_txt OUT CLOB) RETURN NUMBER
IS
BEGIN
    IF NOT select_has_rows('select null from sys.dba_triggers
    where trigger_name=''DBMS_JAVA_DEV_TRG'' and owner=''SYS''
    and status=''ENABLED''') THEN
        RETURN c_success;
    END IF;
    -- Java development is not allowed
    result_txt := get_failed_check_xml('post_jvm_mitigat_patch',
                    new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS),
                    null, null);
    RETURN c_failure;
END post_jvm_mitigat_patch_check;


--
-- Fixup javavm_mitigat_patch
--
FUNCTION jvm_mitigation_patch_fixup (
         result_txt IN OUT VARCHAR2,
         pSqlcode    IN OUT NUMBER) RETURN NUMBER
IS
    enable_java_dev_result BOOLEAN;
BEGIN
    enable_java_dev_result := run_int_proc('SYS.DBMS_JAVA_DEV.ENABLE', result_txt, pSqlcode);

   IF (enable_java_dev_result) THEN
       RETURN c_success;
   ELSE
       RETURN c_failure;
   END IF;
END jvm_mitigation_patch_fixup;


-- *****************************************************************
--  AUDTAB_ENC_TS Section (Bug 23221566)
-- This check reminds user to remember to reopen the Oracle Encryption 
-- Wallet after the db has been opened in upgrade mode in the target 
-- Oracle home because some of the audit tables are stored into an
-- encrypted tablespace. Else db upgrade will abort.
-- *****************************************************************
FUNCTION AUDTAB_ENC_TS_check (result_txt OUT CLOB) RETURN NUMBER
IS
  aud_ts_encrypted NUMBER := 0;
  uniaud_ts_encrypted NUMBER := 0;
  wallet_open_status NUMBER := 0;
  uniaud_is_part NUMBER := 0;
  db_version     VARCHAR2(5);

BEGIN
  -- Get the current db version
  SELECT SUBSTR(version,1,4) INTO db_version FROM sys.registry$
  WHERE cid = 'CATPROC';

  IF db_version IN ('11.2') THEN
    -- Bug 23539027:Do not reference WALLET_TYPE column of V$ENCRYPTION_WALLET
    -- view as it does not exist in 11.2* DB vesrions
    -- Check if Oracle Encryption Wallet is Open
    EXECUTE IMMEDIATE 'SELECT count(*) FROM ' ||
    '(SELECT status, wrl_type FROM v$encryption_wallet ORDER BY ' ||
    ' wrl_type DESC) ks WHERE ROWNUM < 2 and ' ||
    'ks.status <> ''OPEN''' INTO wallet_open_status; 
  ELSE
    EXECUTE IMMEDIATE 'SELECT count(*) FROM v$encryption_wallet WHERE ' ||
    'status <> ''OPEN'' AND ' ||
    'wallet_type IN (''PRIMARY'', ''SINGLE'', ''UNKNOWN'')' INTO 
    wallet_open_status;
  END IF;

  IF (wallet_open_status > 0) THEN -- Wallet Not Open

    -- Check if AUD$/FGA_LOG$ is stored into an Encrypted Tablespace
    SELECT count(*) INTO aud_ts_encrypted FROM sys.ts$ t1, sys.tab$ t2
    WHERE (t1.ts# = t2.ts#)
    AND (bitand(t1.flags, 16384)=16384) -- encrypted tablespace bit check
    AND t2.obj# IN (SELECT o.obj# FROM sys.obj$ o WHERE
                    o.name IN ('AUD$', 'FGA_LOG$') AND (o.type# = 2)
                    AND o.owner# IN (SELECT u.user# FROM sys.user$ u
                    WHERE u.name IN ('SYS', 'SYSTEM') AND (u.type# = 1)));

    IF (aud_ts_encrypted > 0) THEN
      result_txt := get_failed_check_xml('audtab_enc_ts',
                                         new string_array_t(), null, null);
      return c_failure;
    END IF;

    -- Check if AUDSYS.AUD$UNIFIED is stored into an Encrypted Tablespace
    -- Before that, first check if AUDSYS.AUD$UNIFIED is Partitioned
    SELECT count(*) INTO uniaud_is_part FROM
    sys.partobj$ p, sys.obj$ o, sys.user$ u WHERE
    (p.obj# = o.obj#) AND (o.type# = 2) AND (o.name = 'AUD$UNIFIED') AND
    (o.owner# = u.user#) AND (u.name = 'AUDSYS') AND (u.type# = 1);

    IF (uniaud_is_part > 0) THEN  -- AUDSYS.AUD$UNIFIED is Partitioned
      SELECT count(*) INTO uniaud_ts_encrypted FROM
      sys.ts$ t1, sys.tabpart$ t2, sys.obj$ o, sys.user$ u
      WHERE (t1.ts# = t2.ts#) AND (bitand(t1.flags, 16384)=16384) AND
      (t2.bo# = o.obj#) AND (o.type# = 2) AND (o.name = 'AUD$UNIFIED') AND
      (o.owner# = u.user#) AND (u.name='AUDSYS') AND (u.type# = 1);
    ELSE
      SELECT count(*) INTO uniaud_ts_encrypted FROM
      sys.ts$ t1, sys.tab$ t2, sys.obj$ o, sys.user$ u
      WHERE (t1.ts# = t2.ts#) AND (bitand(t1.flags, 16384)=16384) AND
      (t2.obj# = o.obj#) AND (o.type# = 2) AND (o.name = 'AUD$UNIFIED')
      AND (o.owner# = u.user#) AND (u.name = 'AUDSYS') AND (u.type# = 1);
    END IF;

    IF (uniaud_ts_encrypted > 0) THEN
      result_txt := get_failed_check_xml('audtab_enc_ts',
                                         new string_array_t(), null, null);
      return c_failure;
    END IF;
  END IF;
  RETURN c_success;
EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN c_success;
END AUDTAB_ENC_TS_check;

-- *****************************************************************
--     TRGOWNER_NO_ADMNDBTRG Section
-- This check verifies whether there are database triggers created,
-- by users which didn't receive the privilege directly
-- *****************************************************************
FUNCTION trgowner_no_admndbtrg_check (result_txt OUT CLOB) RETURN NUMBER
IS
    TRG_EXISTS     NUMBER := 0;
    TRGADM_QUERY   VARCHAR2(300) :='';
BEGIN
    TRGADM_QUERY:= 'SELECT COUNT(OWNER) TRG_EXISTS FROM DBA_TRIGGERS 
                    WHERE BASE_OBJECT_TYPE=''DATABASE'' AND 
                    OWNER NOT IN (SELECT GRANTEE FROM DBA_SYS_PRIVS 
                    WHERE PRIVILEGE=''ADMINISTER DATABASE TRIGGER'')';
    EXECUTE IMMEDIATE TRGADM_QUERY INTO TRG_EXISTS; 
    IF TRG_EXISTS = 0 THEN
        RETURN c_success;
    ELSE
        result_txt := get_failed_check_xml('trgowner_no_admndbtrg',
                    new string_array_t(),
                    null, null);
        RETURN c_failure;
    END IF;
END trgowner_no_admndbtrg_check;

-- *****************************************************************
--     XDB_RESOURCE_TYPE Section
-- This check verifies whether the attribute order of
-- XDB.XDB$RESOURCE_T is either correct or feasible for patch
-- *****************************************************************

FUNCTION xdb_resource_type_check (result_txt OUT CLOB) RETURN NUMBER
 IS
   res_obj_cnt    number;
   res_attr_cnt   number;
   attr_no_RCL    number;
   attr_no_COBI   number;
   attr_no_BV     number;
   dep_tab_cnt    number;
   non_null_cnt   number;
   need_patch     boolean;
BEGIN
  select count(*) into res_obj_cnt from SYS.DBA_OBJECTS
  where  owner = 'XDB' and
         ((object_name = 'XDB$RESOURCE'   and object_type = 'TABLE') or
          (object_name = 'XDB$RESOURCE_T' and object_type = 'TYPE'));

  -- 22744959: XDB is not installed, and hence no wrong-ordered attributes
  if (res_obj_cnt <> 2) then
    return c_success;
  end if;

  select count(*) into res_attr_cnt from SYS.DBA_TYPE_ATTRS 
  where  owner = 'XDB' and type_name = 'XDB$RESOURCE_T' and
         attr_name in ('RCLIST', 'CHECKEDOUTBYID', 'BASEVERSION');

  -- 22744959: wrong-ordered attributes are not introduced yet
  if (res_attr_cnt = 0) then
    return c_success;

  elsif (res_attr_cnt = 3) then
    select attr_no into attr_no_RCL  from SYS.DBA_TYPE_ATTRS 
    where  owner = 'XDB' and type_name = 'XDB$RESOURCE_T' and
           attr_name = 'RCLIST';

    select attr_no into attr_no_COBI from SYS.DBA_TYPE_ATTRS
    where  owner = 'XDB' and type_name = 'XDB$RESOURCE_T' and
           attr_name = 'CHECKEDOUTBYID';

    select attr_no into attr_no_BV   from SYS.DBA_TYPE_ATTRS
    where  owner = 'XDB' and type_name = 'XDB$RESOURCE_T' and
           attr_name = 'BASEVERSION';

    select count(*) into dep_tab_cnt from SYS.DBA_DEPENDENCIES
    where referenced_owner = 'XDB' and referenced_name  = 'XDB$RESOURCE_T' and
          type = 'TABLE' and (owner != 'XDB' or name != 'XDB$RESOURCE');

    execute immediate
      'select count(*) from XDB.XDB$RESOURCE R
       where R.xmldata.checkedoutbyid is not null or
             R.xmldata.baseversion    is not null'
      into non_null_cnt;

    need_patch :=  (attr_no_RCL > attr_no_COBI) OR (attr_no_COBI > attr_no_BV);

    -- wrong-ordered attributes exist and can be repaired during upgrade
    if (not need_patch) or (dep_tab_cnt = 0 and non_null_cnt = 0) then
      return c_success;
    end if;

  end if;

  -- wrong-ordered attributes exist but beyond repair
  result_txt := get_failed_check_xml('xdb_resource_type',
                                     new string_array_t(), null, null);
  return c_failure;
END xdb_resource_type_check;

-- *****************************************************************
--     CASE_INSENSITIVE_AUTH Section
-- This check returns c_failure if the instance initialization parameter
-- SEC_CASE_SENSITIVE_LOGON has the value FALSE, meaning that the server
-- is configured to ignore the case of the password during authentication.
--
-- *****************************************************************
FUNCTION case_insensitive_auth_check (result_txt OUT CLOB) RETURN NUMBER
IS
  sec_case_sensitive_logon           number;
BEGIN
  --
  -- Get the value of the SEC_CASE_SENSITIVE_LOGON initialization parameter.
  --
  select decode (VALUE, 'FALSE', 0, 1) into sec_case_sensitive_logon
    from V$SYSTEM_PARAMETER
   where NAME='sec_case_sensitive_logon';

  if (sec_case_sensitive_logon = 1) then
    return c_success;
  end if;

  result_txt := get_failed_check_xml('case_insensitive_auth',
                                     new string_array_t(), null, null);
  return c_failure;
END case_insensitive_auth_check;

-- *****************************************************************
--     NETWORK_ACL_PRIV Section
-- This check looks for existing network ACLs in 11g to issue warnings
-- about a change in format in 12c.
-- *****************************************************************
FUNCTION network_acl_priv_check (result_txt OUT CLOB) RETURN NUMBER
IS
  net_acl_count    NUMBER := 0;
  wallet_acl_count NUMBER := 0;
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'select count(*) from sys.net$_acl where rownum <= 1'
       INTO net_acl_count;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  BEGIN
    EXECUTE IMMEDIATE 'select count(*) from sys.wallet$_acl where rownum <= 1'
       INTO wallet_acl_count;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  IF (net_acl_count = 0 AND wallet_acl_count = 0)
  THEN
    RETURN c_success;
  END IF;

  result_txt := get_failed_check_xml('network_acl_priv',
                  new string_array_t(),
                  null, null);
  RETURN c_failure;

END network_acl_priv_check;

-- *****************************************************************
-- Bug 21289647 REMOTE_LOGIN_PASSWORDFILE parameter check
-- This check verifies that REMOTE_LOGIN_PASSWORDFILE is not SHARED
-- *****************************************************************
FUNCTION rlp_param_check (result_txt OUT CLOB) RETURN number
IS
  is_rlp_shared    NUMBER := 0;
BEGIN

  BEGIN
    EXECUTE IMMEDIATE
     'SELECT 1 FROM sys.v$parameter WHERE upper(name) = ''REMOTE_LOGIN_PASSWORDFILE'' AND upper(value) = ''SHARED''' INTO is_rlp_shared;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  IF (is_rlp_shared = 0)
  THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('rlp_param', new string_array_t(), null, null);
    RETURN c_failure;
  END IF;

END rlp_param_check;

-- *****************************************************************
-- Bug 22166873 - ADD PREUPGRADE CHECK FOR MATERIALIZED VIEWS REFRESH 
-- This check verifies all mv's are fresh and sumdelta$ is empty.
-- *****************************************************************
FUNCTION mv_refresh_check (result_txt OUT CLOB) RETURN number
IS
  num_notfresh_mvs    NUMBER := 0;
  num_sumdelta_rows   NUMBER := 0;
BEGIN

  BEGIN
    EXECUTE IMMEDIATE
     'select count(*) from (select mview_name from all_mviews where staleness
      <> ''FRESH'')' into num_notfresh_mvs;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  BEGIN
    EXECUTE IMMEDIATE
     'select count(*) from sys.sumdelta$' into num_sumdelta_rows;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  IF (num_notfresh_mvs = 0 AND num_sumdelta_rows = 0)
  THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('mv_refresh', new string_array_t(), null, null);
    RETURN c_failure;
  END IF;

END mv_refresh_check;

-- ****************************************************************************
-- #(22454765) - ADD PREUPGRADE CHECK FOR METHOD_OPT preference of dbms_stats.
-- dbms_stats was not raising error properly when users set invalid value for 
-- this preference. For example, it was not raising error when user use FOR
-- COLUMNS clause when setting global prefernce. This is fixed in #(5917009).
-- However users were able to set the invalid value and it was causing errors
-- when gathering statistics during upgrade. This preupgrade check warns the
-- users during pre upgrade check if their database has wrong setting for this
-- preference. Currently it complains only if FOR COLUMNS clause is present
-- in the preference value.
-- ****************************************************************************
FUNCTION dbms_stats_method_opt_check (result_txt OUT CLOB) RETURN number
IS
  pvalue    varchar2(32000);        -- global preference value
  valid     boolean;                -- is preference value valid?
BEGIN

  -- This script may run against db that does not have get_prefs function.
  -- So use old get_param function.
  pvalue := dbms_stats.get_param('METHOD_OPT');

  -- Check if global prefrence has FOR COLUMNS clause
  IF (pvalue is not null and regexp_like(pvalue, 'FOR[ ]+COLUMNS', 'i'))
  THEN
    valid := false;
  else
    valid := true;
  END IF;

  IF (valid)
  THEN
    RETURN c_success;
  ELSE
    result_txt := get_failed_check_xml('dbms_stats_method_opt', 
                    new string_array_t(pvalue),
                    null, null);
    RETURN c_failure;
  END IF;

END dbms_stats_method_opt_check;


-- ***********************************************************************
-- Bug 22708956 - ADD INFORMATIONAL MESSAGES ABOUT DATA MININING OBJECTS
-- This check verifies the existance of data mining objects on customer TS
-- ***********************************************************************
FUNCTION data_mining_object_check (result_txt OUT CLOB) RETURN NUMBER
IS
BEGIN
    IF NOT select_has_rows('select null from modeltab$ m,  ts$ t, sys_objects s  
    where m.obj#=s.object_id and s.ts_number=t.ts#
        and t.name not in (''SYSTEM'',''SYSAUX'')
        and rownum <=1') THEN
        RETURN c_success;
    END IF;
    -- There are data mining objects in the database
    result_txt := get_failed_check_xml('data_mining_object',
                      new string_array_t(),
                      null, null);
  RETURN c_failure;
END data_mining_object_check;

-- *****************************************************************
--     PENDING_DST_SESSION Section
-- Bug 20669175 check for any pending dst session before upgrade
-- *****************************************************************
FUNCTION pending_dst_session_check (result_txt OUT CLOB) RETURN NUMBER
IS
    DST_US_VALUE      VARCHAR2(4000) :='';
BEGIN
    EXECUTE IMMEDIATE 'SELECT property_value
                    FROM DATABASE_PROPERTIES
                    WHERE PROPERTY_NAME = ''DST_UPGRADE_STATE'''
    INTO DST_US_VALUE;

    IF DST_US_VALUE = 'NONE' THEN
        RETURN c_success;
    ELSE
        result_txt := get_failed_check_xml('pending_dst_session',
                    new string_array_t(DST_US_VALUE),
                    null, null);
        RETURN c_failure;
    END IF;
END pending_dst_session_check;

-- *****************************************************************
--     EXCLUSIVE_MODE_AUTH Section
-- This check returns c_failure if any account has only the 10G password
-- version (and neither the 11G nor the 12C password version).
--
-- The 10G password version is no longer accepted when the server
-- runs in Exclusive Mode, and starting with Oracle Database release 12.2
-- Exclusive Mode is the default password-based authentication mode,
-- so these accounts would become inaccessible
-- (an ORA-1017 "invalid username/password" error would be raised)
-- unless the customer relaxed the server's SQLNET.ORA setting for
-- the SQLNET.ALLOWED_LOGON_VERSION_SERVER parameter to a more
-- permissive setting (e.g. a value of 11). The default value for
-- the SQLNET.ALLOWED_LOGON_VERSION_SERVER parameter is 12 in Oracle
-- release 12.2.
--
-- In the DBA_USERS query, note the spaces within the
-- strings '10G ' and '10G HTTP ', and the use of the 
-- equality condition in the predicates.
--
-- The reason for including the PASSWORD_VERSIONS = '10G HTTP ' predicate
-- is that after the fix for 12.2 bug 22176897, the DBA_USERS view also
-- displays the presence of the HTTP password version (this password
-- version is unrelated to the O5LOGON protocol, it is only used by 
-- XDB for HTTP digest authentication).
--
--       select USERNAME, PASSWORD_VERSIONS
--         from DBA_USERS
--        where (PASSWORD_VERSIONS = '10G '
--           or  PASSWORD_VERSIONS = '10G HTTP ')
--          and (USERNAME <> 'ANONYMOUS');
--
-- Note that the ANONYMOUS user is excluded from the result set, as prior
-- to the fix for 12.2 bug 22176897 the ANONYMOUS user is reported by 
-- DBA_USERS as having a 10G password version. Also, AND has precedence
-- over OR, so parentheses are needed around the OR part of the predicate.
-- 
-- *****************************************************************
FUNCTION exclusive_mode_auth_check (result_txt OUT CLOB) RETURN NUMBER
IS
  only_10g_password_ver_present number;
  sqlnetvalue VARCHAR2(20):='';
  file        utl_file.file_type;
BEGIN
  --read buffer
  file := utl_file.fopen('PREUPGRADE_DIR','checksBuffer.tmp','R');
  if utl_file.is_open(file) then
    loop
      begin
        -- get value of sqlnet.ora found from java
        utl_file.get_line(file, sqlnetvalue);
        exception when no_data_found then exit;
      end;
    end loop;
    utl_file.fclose(file);
  end if;
  --
  -- Check if any account has only a 10G password version.
  --
  select count(*) into only_10g_password_ver_present
    from sys.dual                          
   where exists 
     (select 1
        from DBA_USERS
       where (PASSWORD_VERSIONS = '10G '
          or  PASSWORD_VERSIONS = '10G HTTP ')
         and (USERNAME <> 'ANONYMOUS'));

  if ((sqlnetvalue = '8' or sqlnetvalue = '9' or 
       sqlnetvalue = '10' or sqlnetvalue = '11') 
       and only_10g_password_ver_present > 0) then
      -- throw error
      result_txt := get_failed_check_xml('exclusive_mode_auth',
                new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS),
                null, null);
      return c_failure;
  else
     return c_success;
  end if;
END exclusive_mode_auth_check;


-- *****************************************************************
--     min_archive_dest_size_check Section
--
-- Determine free space needed for when Archivelog is on and destination
-- is NOT in the recovery area
--
-- *****************************************************************

FUNCTION min_archive_dest_size_check (result_txt OUT CLOB) RETURN NUMBER
IS
  dest_name          VARCHAR2(256) := '';  -- e.g. LOG_ARCHIVE_DEST_1
  destination        VARCHAR2(256) := '';  -- path to archived logs
  min_archivelog_gen INTEGER := 0;     -- min archive log bytes to be generated

BEGIN

  result_txt := '';

  destination        := archivedest_info.destination;
  dest_name          := archivedest_info.dest_name;
  min_archivelog_gen := archivedest_info.min_archive_gen;

  -- as an informational msg, let user know archiving is on
  -- and they need to ensure there is enough disk space to cover the amount
  -- of logs generated during the upgrade

  -- only generate a result string IF archive log size to be generated is > 0
  -- AND the archive log destination outside of fra is specified
  IF (min_archivelog_gen > 0)
     AND (dest_name IS NOT NULL)
  THEN
    result_txt :=
      get_failed_check_xml(
        'min_archive_dest_size',
        new string_array_t(destination,                        -- {1}
                           dest_name,                          -- {2}
                           displayBytes(min_archivelog_gen)),  -- {3}
        null, null);
    RETURN c_failure;
  ELSE
    RETURN c_success;
  END IF;

END min_archive_dest_size_check;


/**
	Displays information about the number of cycles that the upgrade
	will take for the cdb upgrade of ROOT, SEED, and PDBs.
**/
FUNCTION cycle_number_check (result_txt OUT CLOB) RETURN NUMBER
IS
	pdbs_para NUMBER;
	n_cycles NUMBER;
BEGIN
	pdbs_para := num_pdbs_upg_in_parallel();
	IF(db_is_cdb) THEN
		result_txt := get_failed_check_xml('cycle_number',
	      			  new string_array_t(db_n_pdbs, pdbs_para),
	        		  null, null);
		RETURN C_FAILURE;
	END IF;
	RETURN C_SUCCESS;
END cycle_number_check;


-- *****************************************************************
--     min_recovery_area_size_check Section
--
-- Determine minimum free space needed for when:
--  a) Archivelog is on
--  b) Flashback Database is on
--
-- *****************************************************************

FUNCTION min_recovery_area_size_check (result_txt OUT CLOB) RETURN NUMBER
IS
  db_recovery_modes  VARCHAR2(80)  := '';  -- archivelog, flashback
  db_recovery_logs   VARCHAR2(80)  := '';  -- archived logs, flashback logs

BEGIN

  -- archive logs can be in the archive destination
  -- or in db recovery area (fra).  so lets find out
  IF db_log_mode = 'ARCHIVELOG' THEN  -- if ARCHIVING ON
    db_recovery_modes := 'archivelog mode';  -- recovery mode: archive only
    -- what type of logs are in FRA?
    IF is_archivelog_in_fra = TRUE THEN
      db_recovery_logs := 'archived logs';  -- archived logs
    ELSE
      db_recovery_logs := '';  -- not archived logs
    END IF;
  END IF;

  -- flashback logs can only be in fra.
  -- but are the archivelogs in the fra too?
  IF db_flashback_on = TRUE THEN  -- if FLASHBACK on
    db_recovery_modes := 'archivelog and flashback';  -- recovery mode: both
    -- what type of logs are in FRA?
    IF is_archivelog_in_fra = TRUE THEN
      db_recovery_logs  := 'archived and flashback logs';  -- logs: both types
    ELSE
      db_recovery_logs  := 'flashback logs';  -- only flashback logs
    END IF;
  END IF;

  IF (fra_info.additional_size > 0) THEN
    result_txt :=
      get_failed_check_xml(
        'min_recovery_area_size',
        new string_array_t(db_recovery_modes,                    -- {1}
                           db_recovery_logs,                     -- {2}
                           fra_info.name,                        -- {3}
                           displayBytes(fra_info.limit),         -- {4}
                           displayBytes(fra_info.used),          -- {5}
                           displayBytes(fra_info.avail),         -- {6}
                           displayBytes(fra_info.min_fra_size)), -- {7}
        null, null);
    RETURN c_failure;
  ELSE
    RETURN c_success;
  END IF;
END min_recovery_area_size_check;


-- *****************************************************************
--     javavm_status_check Section
--
-- Determine whether the javavm state is the appropriated to upgrade
--
-- *****************************************************************
FUNCTION javavm_status_check (result_txt OUT CLOB) RETURN NUMBER
IS
  javavm      VARCHAR2(20):='ok';
  error       VARCHAR2(20);
  message     VARCHAR2(1000);
BEGIN

    IF sys.dbms_registry.is_loaded('JAVAVM') IS NOT NULL THEN
        BEGIN
            EXECUTE IMMEDIATE 'declare junk varchar2(10):=dbms_java.longname(''foo''); begin null; end;';
        EXCEPTION
            WHEN OTHERS THEN 
                javavm  := 'notok'; 
                error   := SQLCODE;
                message := SQLERRM;
        END;
    END IF;

    if (javavm='ok') then
        RETURN c_success;
    end if;
        result_txt := get_failed_check_xml('javavm_status',
                         new string_array_t(error, message), null, null);
    RETURN c_failure;
END javavm_status_check;

-- *****************************************************************
--     tempts_notempfile_check Section
-- Detects where the default temporary tablespace has no temp file
-- *****************************************************************
FUNCTION tempts_notempfile_check (result_txt OUT CLOB) RETURN NUMBER
IS
  deftsisgroup      VARCHAR2(5):='';
  valid_scenario    VARCHAR2(5):='';
  deftmpts          VARCHAR2(4000):='';
  t_deftmpts        VARCHAR2(4000):='';
  p_tablespace_name VARCHAR2(30):='';
  xcursor           SYS_REFCURSOR;
  groupts           NUMBER:=0;
  inv_ts            NUMBER:=0;
  cols              number_array_t:= new number_array_t(0,30,0,30,12);
BEGIN
    -- Get temporary tablespace for SYS.
    SELECT TEMPORARY_TABLESPACE INTO deftmpts
    FROM DBA_USERS A
    WHERE UPPER(USERNAME)='SYS';

    -- Determine if tablespace is part of a tablespace group?
    SELECT DECODE(COUNT(1), 0,'NO','YES') INTO deftsisgroup
    FROM DBA_TABLESPACE_GROUPS
    WHERE GROUP_NAME=''||deftmpts||'';

    -- Temporary tablespace comes from a TS group
    IF deftsisgroup='YES' THEN

        -- Get how many tablespaces of the group have
        -- temp files associated, we need at least one
        SELECT COUNT(A.TABLESPACE_NAME) INTO groupts
        FROM DBA_TABLESPACE_GROUPS A JOIN DBA_TEMP_FILES B
        ON(A.TABLESPACE_NAME=B.TABLESPACE_NAME)
        WHERE A.GROUP_NAME=''||deftmpts||'';

        -- how many ts are there in the group that have a
        -- temp file associated?
        IF groupts = 0 THEN
            -- No ts with a temp file found, error
            valid_scenario:='NO';
            -- Adding headers to table
            t_deftmpts := column_format(cols, new 
                string_array_t(' ', 'GROUP_NAME', ' ', 'TABLESPACE_NAME', ' '));

            -- Get list of ts without temp file
            OPEN xcursor FOR SELECT TABLESPACE_NAME 
                             FROM DBA_TABLESPACE_GROUPS
                             WHERE GROUP_NAME=''||deftmpts||'';

            LOOP
                FETCH xcursor INTO p_tablespace_name;
                EXIT WHEN xcursor%NOTFOUND;
                  t_deftmpts := t_deftmpts || column_format(cols, new 
                  string_array_t(' ', deftmpts, ' ', p_tablespace_name, ' '));
            END LOOP;
            CLOSE xcursor;
            -- send  t_deftmpts to be displayed
            deftmpts := t_deftmpts;
        ELSE
            -- at least one ts has a temp file, all fine
            valid_scenario:='YES';
        END IF;

    -- Temporary tablespace is not part of a tablespace group
    ELSE

        -- Check how many temp files the ts has
        -- associated 
        SELECT COUNT(TABLESPACE_NAME) INTO inv_ts
        FROM DBA_TEMP_FILES
        WHERE TABLESPACE_NAME=''||deftmpts||'';

        -- Does the ts has a temp file?
        IF inv_ts > 0 THEN
            -- yes, it has at least one, all fine
            valid_scenario:='YES';
        ELSE
            -- No, it hasn't, error
            valid_scenario:='NO';
        END IF;

    END IF;

    IF valid_scenario='YES' THEN
        RETURN c_success;
    ELSE
        result_txt := get_failed_check_xml('tempts_notempfile',
                    new string_array_t(deftmpts), null, null);
        return c_failure;
    END IF;

END tempts_notempfile_check;

-- *****************************************************************
--     pga_aggregate_limit_check Section
-- Detects where the user has specified pga_aggregate_limit in spfile
-- that is too small.
-- *****************************************************************
FUNCTION pga_aggregate_limit_check (result_txt OUT CLOB) RETURN NUMBER
IS
    pga_limit_min         NUMBER := 0;
    processes             NUMBER := 0;
    memory_max_target     NUMBER := 0;
    pga_limit_default_min NUMBER := 0;
    pga_limit_proc_min    NUMBER := 0;
BEGIN

    -- skip check if pga_aggregate_limit not in all_parameters
    IF (all_parameters.exists('pga_aggregate_limit') = FALSE) THEN
      RETURN c_success;
    END IF;
    
    -- if pga_aggregate_limit has not been set explicitly, return success
    IF (all_parameters('pga_aggregate_limit').isdefault = 'TRUE') THEN
      RETURN c_success;
    END IF;

    IF (all_parameters('memory_target').value > 0) THEN
      pga_limit_min := all_parameters('memory_max_target').value;
    ELSE

      IF (all_parameters('pga_aggregate_target').value > 0) THEN
        pga_limit_min := all_parameters('pga_aggregate_target').value * 2; 
      END IF;

    END IF;

    -- pga_aggregate_limit must be at least 2GB
    pga_limit_default_min := (2 * c_gb);

    IF (pga_limit_min < pga_limit_default_min) THEN
      pga_limit_min := pga_limit_default_min;
    END IF;

    -- pga_aggregate_limit must be at least (3M * processes)
    processes := all_parameters('processes').value;
    pga_limit_proc_min := (processes * (3 * c_mb));

    IF (pga_limit_min < pga_limit_proc_min) THEN
      pga_limit_min := pga_limit_proc_min; 
    END IF;

    -- user specified value must be >= calculated default
    IF (all_parameters('pga_aggregate_limit').value >= pga_limit_min) THEN
      RETURN c_success;
    ELSE
      result_txt := get_failed_check_xml(
        'pga_aggregate_limit',
        new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS,                -- {1}
                           all_parameters('pga_aggregate_limit').value, -- {2}
                           pga_limit_min),                              -- {3}
        null, null);

      -- set the value for the DBUA xml file
      pga_limit_min_dbua := pga_limit_min; 

      RETURN c_failure;
    END IF;

END; 

-- *****************************************************************
--     dv_simulation_check Section
-- This function checks whether simulation log records prior to upgrade
-- have been moved to DVSYS.OLD_SIMULATION_LOG$ and lets the customer
-- know that post-upgrade.
-- *****************************************************************
FUNCTION dv_simulation_check (result_txt OUT CLOB) RETURN NUMBER
IS
BEGIN
    IF ((sys.dbms_registry.is_loaded('DV') IS NOT NULL) AND
        (sys.dbms_registry.get_progress_value('DV', 'SIMULATION LOGS') =
  'The existing simulation logs have been moved to dvsys.old_simulation_log$'))
    THEN
      result_txt := get_failed_check_xml('dv_simulation',
                       new string_array_t(), null, null);
      RETURN c_failure;
    ELSE
      RETURN c_success;
    END IF;
END dv_simulation_check;

FUNCTION parameter_min_val_check (result_txt OUT CLOB) RETURN NUMBER
IS
    this_parameter_name SYS.V$PARAMETER.NAME%TYPE;
    this_parameter parameter_record_t;
    message_parameters string_array_t;
    message_parameters_index NUMBER;
    found_problem BOOLEAN := false;
    upgrade_requirement VARCHAR2(1);
BEGIN
    message_parameters := new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS);

    message_parameters_index := message_parameters.count();

    this_parameter_name := all_parameters.first;
    WHILE this_parameter_name IS NOT NULL LOOP
        this_parameter := all_parameters(this_parameter_name);

        -- 
        --    Check that any minimum values for a numeric parameter are ok.
        --
        --    If the parameter is defaulted in init.ora, then no need to tell
        --    the user about it because they will just accept the new default
        --    in the new release.
        --    ^^^ Exception: For the memory parameters we size for upgrades,
        --    if that memory parameter's current defaulted value is too low
        --    for upgrade, then that parameter and minimum value will be
        --    displayed.
        --
        --    Also note, that renamed parameters have renamed_to_name set and
        --    are not part of this <Update> list.  They're handled below.
        --
        IF ( (is_size_this_memparam(this_parameter.name) = TRUE OR
              this_parameter.isdefault = 'FALSE') AND
             (this_parameter.renamed_to_name IS NULL) ) THEN
            IF this_parameter.type IN (c_param_type_number, c_param_type_number_alt) THEN
                -- a numeric parameter.  Check its min_value
                IF to_number(this_parameter.value) < this_parameter.min_value THEN
                    --
                    --    parameter fails to meet minimum.  add parameter info to array for message.
                    --
                    found_problem := true;

                    --
                    --    we will put an asterisk next to parameters whose minimum
                    --    value settings are required only for the Upgrade (as opposed to
                    --    meeting a minimum setting for the new release in general)
                    --
                    IF (db_is_cdb = FALSE OR db_is_root = TRUE) AND
                       (sys.dbms_preup.is_size_this_memparam(this_parameter.name))
                    THEN
                        upgrade_requirement := '*';
                    ELSE
                        upgrade_requirement := ' ';
                    END IF;

                    message_parameters.extend(4);    -- about to add 4 new indexes in code below
                    message_parameters(message_parameters_index+1) := upgrade_requirement;
                    message_parameters(message_parameters_index+2) := this_parameter.name;
                    message_parameters(message_parameters_index+3) := to_char(this_parameter.value);
                    message_parameters(message_parameters_index+4) := to_char(this_parameter.min_value);
                    message_parameters_index := message_parameters_index + 4;
                END IF;
            END IF;
        END IF;
        this_parameter_name := all_parameters.next(this_parameter_name);
    END LOOP;

    IF found_problem THEN
        result_txt := get_failed_check_xml('parameter_min_val', message_parameters, null, null);
        RETURN c_failure;
    ELSE
        RETURN c_success;
    END IF;
END parameter_min_val_check;


FUNCTION parameter_min_val_fixup        (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN NUMBER
IS
BEGIN
    -- at this time, we are relying on DBUA to perform the fixup since the
    -- <InitParams> is still present.
    return c_success;
END parameter_min_val_fixup;


FUNCTION parameter_rename_check (result_txt OUT CLOB) RETURN NUMBER
IS
    this_parameter_name SYS.V$PARAMETER.NAME%TYPE;
    this_parameter parameter_record_t;
    message_parameters string_array_t;
    message_parameters_index NUMBER;
    found_problem BOOLEAN := false;
    upgrade_requirement VARCHAR2(1);
BEGIN
    message_parameters := new string_array_t(db_version_3_dots,
        dbms_registry_extended.convert_version_to_n_dots(C_ORACLE_HIGH_VERSION_4_DOTS,3) );

    message_parameters_index := message_parameters.count();

    this_parameter_name := all_parameters.first;
    WHILE this_parameter_name IS NOT NULL LOOP
        this_parameter := all_parameters(this_parameter_name);

        IF ( (this_parameter.isdefault = 'FALSE') AND
             (this_parameter.renamed_to_name IS NOT NULL) AND
             (this_parameter.new_value IS NULL) ) THEN
            --
            --    parameter has been RENAMED and may or may not requre a new VALUE
            --    add parameter info to array for message.
            --
            found_problem := true;

            message_parameters.extend(2);    -- about to add new indexes in code below
            message_parameters(message_parameters_index+1) := this_parameter.name;
            message_parameters(message_parameters_index+2) := this_parameter.renamed_to_name;
            message_parameters_index := message_parameters_index + 2;
        END IF;


        this_parameter_name := all_parameters.next(this_parameter_name);
    END LOOP;

    IF found_problem THEN
        result_txt := get_failed_check_xml('parameter_rename', message_parameters, null, null);
        RETURN c_failure;
    ELSE
        RETURN c_success;
    END IF;
END parameter_rename_check;


FUNCTION parameter_rename_fixup        (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN NUMBER
IS
BEGIN
    -- at this time, we are relying on DBUA to perform the fixup since the
    -- <InitParams> is still present.
    return c_success;
END parameter_rename_fixup;


FUNCTION parameter_new_name_val_check (result_txt OUT CLOB) RETURN NUMBER
IS
    this_parameter_name SYS.V$PARAMETER.NAME%TYPE;
    this_parameter parameter_record_t;
    message_parameters string_array_t;
    message_parameters_index NUMBER;
    found_problem BOOLEAN := false;
    upgrade_requirement VARCHAR2(1);
BEGIN
    message_parameters := new string_array_t(C_ORACLE_HIGH_VERSION_4_DOTS);

    message_parameters_index := message_parameters.count();

    this_parameter_name := all_parameters.first;
    WHILE this_parameter_name IS NOT NULL LOOP
        this_parameter := all_parameters(this_parameter_name);

        IF ( (this_parameter.isdefault = 'FALSE') AND
             (this_parameter.renamed_to_name IS NOT NULL) AND
             (this_parameter.new_value IS NOT NULL) ) THEN
            --
            --    parameter has been RENAMED and may or may not requre a new VALUE
            --    add parameter info to array for message.
            --
            found_problem := true;

            message_parameters.extend(3);    -- about to add new indexes in code below
            message_parameters(message_parameters_index+1) := this_parameter.name;
            message_parameters(message_parameters_index+2) := this_parameter.renamed_to_name;
            message_parameters(message_parameters_index+3) := this_parameter.new_value;
            message_parameters_index := message_parameters_index + 3;
        END IF;


        this_parameter_name := all_parameters.next(this_parameter_name);
    END LOOP;

    IF found_problem THEN
        result_txt := get_failed_check_xml('parameter_new_name_val', message_parameters, null, null);
        RETURN c_failure;
    ELSE
        RETURN c_success;
    END IF;
END parameter_new_name_val_check;


FUNCTION parameter_new_name_val_fixup        (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN NUMBER
IS
BEGIN
    -- at this time, we are relying on DBUA to perform the fixup since the
    -- <InitParams> is still present.
    return c_success;
END parameter_new_name_val_fixup;


FUNCTION parameter_obsolete_check (result_txt OUT CLOB) RETURN NUMBER
IS
    this_parameter_name SYS.V$PARAMETER.NAME%TYPE;
    this_parameter parameter_record_t;
    message_parameters string_array_t;
    message_parameters_index NUMBER;
    found_problem BOOLEAN := false;
    upgrade_requirement VARCHAR2(1);
BEGIN
    message_parameters := new string_array_t();

    message_parameters_index := message_parameters.count();

    this_parameter_name := all_parameters.first;
    WHILE this_parameter_name IS NOT NULL LOOP
        this_parameter := all_parameters(this_parameter_name);

        IF ( (this_parameter.isdefault = 'FALSE') AND
             (this_parameter.is_obsoleted) ) THEN
            --
            --    parameter has been RENAMED and may or may not requre a new VALUE
            --    add parameter info to array for message.
            --
            found_problem := true;

            message_parameters.extend(1);    -- about to add new indexes in code below
            message_parameters(message_parameters_index+1) := this_parameter.name;
            message_parameters_index := message_parameters_index + 1;

        END IF;


        this_parameter_name := all_parameters.next(this_parameter_name);
    END LOOP;

    IF found_problem THEN
        result_txt := get_failed_check_xml('parameter_obsolete', message_parameters, null, null);
        RETURN c_failure;
    ELSE
        RETURN c_success;
    END IF;
END parameter_obsolete_check;


FUNCTION parameter_obsolete_fixup        (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN NUMBER
IS
BEGIN
    -- at this time, we are relying on DBUA to perform the fixup since the
    -- <InitParams> is still present.
    return c_success;
END parameter_obsolete_fixup;


FUNCTION parameter_deprecated_check (result_txt OUT CLOB) RETURN NUMBER
IS
    this_parameter_name SYS.V$PARAMETER.NAME%TYPE;
    this_parameter parameter_record_t;
    message_parameters string_array_t;
    message_parameters_index NUMBER;
    found_problem BOOLEAN := false;
    upgrade_requirement VARCHAR2(1);
BEGIN
    message_parameters := new string_array_t();

    message_parameters_index := message_parameters.count();

    this_parameter_name := all_parameters.first;
    WHILE this_parameter_name IS NOT NULL LOOP
        this_parameter := all_parameters(this_parameter_name);

        IF ( (this_parameter.isdefault = 'FALSE') AND
             (this_parameter.is_deprecated) ) THEN
            --
            --    parameter has been RENAMED and may or may not requre a new VALUE
            --    add parameter info to array for message.
            --
            found_problem := true;
            message_parameters.extend(1);    -- about to add new indexes in code below

            message_parameters(message_parameters_index+1) := this_parameter.name;
            message_parameters_index := message_parameters_index + 1;

        END IF;

        this_parameter_name := all_parameters.next(this_parameter_name);
    END LOOP;

    IF found_problem THEN
        result_txt := get_failed_check_xml('parameter_deprecated', message_parameters, null, null);
        RETURN c_failure;
    ELSE
        RETURN c_success;
    END IF;
END parameter_deprecated_check;

FUNCTION rollback_segments_check (result_txt OUT CLOB) RETURN NUMBER
IS
    segment_name     SYS.DBA_ROLLBACK_SEGS.SEGMENT_NAME%TYPE;
    tablespace_name  SYS.DBA_SEGMENTS.TABLESPACE_NAME%TYPE;
    status           SYS.DBA_ROLLBACK_SEGS.STATUS%TYPE;
    autox            INTEGER;
    inuse            INTEGER;
    next_extent      SYS.DBA_ROLLBACK_SEGS.NEXT_EXTENT%TYPE;
    max_extents      SYS.DBA_ROLLBACK_SEGS.MAX_EXTENTS%TYPE;
    segment_cursor   cursor_t;

    message_parameters string_array_t;
    message_parameters_index NUMBER;
    found_problem BOOLEAN := false;
BEGIN
    IF db_undo = 'AUTO' THEN  
        return c_success;
    END IF;

    message_parameters := new string_array_t();
    message_parameters_index := message_parameters.count();

    OPEN segment_cursor FOR
        'SELECT r.segment_name, t.tablespace_name, r.status, ' ||
                'round(SUM(DECODE(d.maxbytes, 0, 0, d.maxbytes-d.bytes)/' || to_char(c_kb) || ')) as autox, ' ||
                'ceil(sum(t.bytes)/' || to_char(c_kb) || ') as inuse, ' ||
                'r.next_extent, r.max_extents ' ||
         'FROM SYS.dba_rollback_segs r ' ||
         'JOIN SYS.dba_segments t on r.segment_name = t.segment_name ' ||
         'JOIN sys.dba_data_files d on d.tablespace_name = t.tablespace_name ' ||
         'WHERE r.owner=''PUBLIC'' OR ' ||
               '(r.owner=''SYS'' AND r.segment_name != ''SYSTEM'') ' ||
         'GROUP BY r.segment_name, t.tablespace_name, r.status, r.next_extent, r.max_extents ' ||
         'ORDER BY t.tablespace_name, r.segment_name';
    LOOP
        FETCH segment_cursor INTO segment_name, tablespace_name, status,
                                  autox, inuse, next_extent, max_extents;

        EXIT WHEN segment_cursor%NOTFOUND;

        -- put rollback info in array
        found_problem := true;
        message_parameters.extend(8);    -- about to add new indexes in code below

        message_parameters(message_parameters_index+1) := tablespace_name || '/' || segment_name;
        message_parameters(message_parameters_index+2) := segment_name;
        message_parameters(message_parameters_index+3) := tablespace_name;
        message_parameters(message_parameters_index+4) := status;
        message_parameters(message_parameters_index+5) := boolean_string(autox > 0, 'ON', 'OFF');
        message_parameters(message_parameters_index+6) := displayBytes(inuse * c_kb);
        message_parameters(message_parameters_index+7) := next_extent;
        message_parameters(message_parameters_index+8) := max_extents;


        message_parameters_index := message_parameters_index + 8;

        EXIT WHEN message_parameters_index >= 88;
    END LOOP;
    CLOSE segment_cursor;

    result_txt := get_failed_check_xml( 'rollback_segments', message_parameters, null, null);
    RETURN c_failure;

END rollback_segments_check;



FUNCTION tablespaces_check (result_txt OUT CLOB) RETURN NUMBER
IS
    this_tablespace tablespace_record_t;
    message_parameters string_array_t;
    message_parameters_index NUMBER;
    total_space NUMBER; -- Stores minimum tablespace size needed or the new minimum space needed depending on OBJ$ view.
    local_undo_enabled NUMBER;
    pdbs_para NUMBER;
    inc_by_cnt  NUMBER :=0; -- Counter to store the number of tablespaces needing additional space.
    tbs_action VARCHAR2(30);--The value for this variable could be None, Extend, or Adjust datafile MAXBYTES.
BEGIN
    message_parameters := new string_array_t();
    pdbs_para := num_pdbs_upg_in_parallel();
    message_parameters_index := message_parameters.count();
    execute immediate 'SELECT COUNT(*) FROM DATABASE_PROPERTIES
					   WHERE PROPERTY_NAME=''LOCAL_UNDO_ENABLED'' AND PROPERTY_VALUE=''TRUE'''
  	into local_undo_enabled;
    FOR i IN 1..ts_info.count LOOP
        this_tablespace := ts_info(i);
        IF (this_tablespace.name = db_undo_tbs) THEN
            total_space := this_tablespace.min + get_addl_undo_space();
            --If local undo is enabled, each PDB will have its own UNDO tablespace and reported on its respective log.
            --If local undo is disabled, this means all PDB's are sharing same UNDO tablespace which is created in cdb$root.
            --We will size UNDO tablespace based on the default number of PDB's being upgraded in parallel,
            --the recommended undo space size will be total_space multiplied by the number of pdbs upgraded in parallel. 
            IF (local_undo_enabled = 0 AND pdbs_para > 1) THEN 
            	total_space := total_space * pdbs_para;
            END IF;
        ELSE
            total_space := this_tablespace.min;
        END IF;
        --If the tablespace autoextend is disabled and the inc_by column is bigger than 0, 
        --then the action is to extend the tablespace
        IF ((this_tablespace.inc_by > 0) AND (NOT this_tablespace.fauto)) THEN
        	tbs_action := 'Extend';
        --If it has autoextend enabled but the maxbytes are not enough for the total space
        --then the action is to increase MAXBYTES in the datafile
        ELSIF (this_tablespace.fauto AND (this_tablespace.avail < total_space)) THEN
        	tbs_action := 'Adjust  datafileMAXBYTES';
        ELSE
                tbs_action := 'None';
        END IF;
        IF (tbs_action != 'None') THEN
            inc_by_cnt :=  inc_by_cnt + 1;

            message_parameters.extend(6);    -- about to add new indexes in code below
            message_parameters(message_parameters_index + 1) := this_tablespace.name;
            message_parameters(message_parameters_index + 2) := displayBytes(this_tablespace.alloc * c_mb);
            message_parameters(message_parameters_index + 3) := boolean_string(this_tablespace.fauto, 'ENABLED','DISABLED');        
            message_parameters(message_parameters_index + 4) := displayBytes(total_space * c_mb);
            message_parameters(message_parameters_index + 5) := tbs_action;
            message_parameters(message_parameters_index + 6) := to_char(round(ts_info(i).addl));  -- not displayed
            message_parameters_index := message_parameters_index + 6;
        END IF;
    END LOOP;
    IF (inc_by_cnt > 0) THEN -- If there are tablespaces in the need of adding space, we will print tablespace table and mark check as failed, hence respective preupgrade fixup will be reported. 
    	result_txt := get_failed_check_xml('tablespaces', message_parameters, null, null);
    	RETURN c_failure;
    ELSE 
    	RETURN c_success;
    END IF;

END tablespaces_check;



FUNCTION tablespaces_info_check (result_txt OUT CLOB) RETURN NUMBER
IS
    this_tablespace tablespace_record_t;
    message_parameters string_array_t;
    message_parameters_index NUMBER;
    total_space NUMBER; -- Stores minimum tablespace size needed or the new minimum space needed depending on OBJ$ view.
    local_undo_enabled NUMBER;
    pdbs_para NUMBER;
    inc_by_cnt  NUMBER :=0; -- Counter to store the number of tablespaces needing additional space.
BEGIN
    message_parameters := new string_array_t();
    pdbs_para := num_pdbs_upg_in_parallel();
    message_parameters_index := message_parameters.count();
    execute immediate 'SELECT COUNT(*) FROM DATABASE_PROPERTIES
					   WHERE PROPERTY_NAME=''LOCAL_UNDO_ENABLED'' AND PROPERTY_VALUE=''TRUE'''
  	into local_undo_enabled;
    FOR i IN 1..ts_info.count LOOP
        this_tablespace := ts_info(i);
        IF (this_tablespace.name = db_undo_tbs) THEN
            total_space := this_tablespace.min + get_addl_undo_space();
            --If local undo is enabled, each PDB will have its own UNDO tablespace and reported on its respective log.
            --If local undo is disabled, this means all PDB's are sharing same UNDO tablespace which is created in cdb$root.
            --We will size UNDO tablespace based on the default number of PDB's being upgraded in parallel,
            --the recommended undo space size will be total_space multiplied by the number of pdbs upgraded in parallel. 
            IF (local_undo_enabled = 0 AND pdbs_para > 1) THEN 
            	total_space := total_space * pdbs_para;
            END IF;
        ELSE
            total_space := this_tablespace.min;
        END IF;
         --Only tablespaces that have AUTOEXTEND enabled, the allocated space is less than the total space
        --and MAXBYTES in datafile are not big enough to cover total space needed for upgrade
        --will be shown here as information in order to take in count before the upgrade.
        IF (this_tablespace.fauto) AND
            (total_space > this_tablespace.alloc) AND
            (total_space < this_tablespace.avail) THEN
            inc_by_cnt :=  inc_by_cnt + 1;

            message_parameters.extend(4);    -- about to add new indexes in code below
            message_parameters(message_parameters_index + 1) := this_tablespace.name;
            message_parameters(message_parameters_index + 2) := displayBytes(this_tablespace.alloc * c_mb);
            message_parameters(message_parameters_index + 3) := displayBytes(total_space * c_mb);
            message_parameters(message_parameters_index + 4) := to_char(round(ts_info(i).addl));  -- not displayed
            message_parameters_index := message_parameters_index + 4;
        END IF;
    END LOOP;
    IF (inc_by_cnt > 0) THEN -- If there are autoextend tablespaces in the need of adding space, fail this check.
    	result_txt := get_failed_check_xml('tablespaces_info', message_parameters, null, null);
    	RETURN c_failure;
    ELSE 
    	RETURN c_success;
    END IF;

END tablespaces_info_check;



FUNCTION pre_fixed_objects_check (result_txt OUT CLOB) RETURN NUMBER
IS
  has_stats_cnt  number := 0;  -- # of fixed object tables that have stats
  doc_name       VARCHAR2(80) := '';
BEGIN
  -- find # of fixed object tables that have had stats collected
  execute immediate 'select count(*) from sys.dba_tab_statistics
               where owner = ''SYS'' and table_name like ''X$%''
               and last_analyzed is not null'
  into has_stats_cnt;

  -- if none of the fixed obj tables have had stats collected
  -- then gather fixed objects stats
  -- else do nothing
  if has_stats_cnt > 0 then
     RETURN C_SUCCESS;
  else
      doc_name := db_version_3_dots;
      IF (db_version_1_dot = '11.2') THEN
        doc_name := doc_name || ' Oracle Database Performance Tuning Guide';
      ELSIF (db_version_1_dot = '12.1' OR db_version_3_dots = '12.2.0.1') THEN
        doc_name := doc_name || ' Oracle Database SQL Tuning Guide';
      ELSE
        doc_name := doc_name || ' Oracle Database Upgrade Guide';
      END IF;
      result_txt := get_failed_check_xml('pre_fixed_objects',
                    new string_array_t(doc_name),
                    null, null);
      RETURN C_FAILURE;
  end if;
END pre_fixed_objects_check;

FUNCTION pre_fixed_objects_fixup (result_txt IN OUT VARCHAR2, pSqlcode IN OUT NUMBER) RETURN NUMBER
IS
BEGIN
    sys.dbms_stats.gather_fixed_objects_stats;
    RETURN C_SUCCESS;
END pre_fixed_objects_fixup;


--
-- bug 25392096: size for minimum PROCESSES value - 300 or more
-- 
PROCEDURE find_processes_value
IS
  processes_value_now       NUMBER := 0;  -- current value of PROCESSES
  processes_value_to_set    NUMBER := 0;  -- min PROCESSES value to set
  n_background_proc_running NUMBER := 0;  -- # of oracle processes 
                                          --   (minus parallel slaves) running
  n_para_slaves_running     NUMBER := 0;  -- # of parallel slaves running
  n_max_para_slaves_can_run NUMBER := 0;  -- max # of parallel slaves that can
                                          --   run
  n_min_para_slaves_can_run NUMBER := 0;  -- min # of parallel slaves that can
                                          --   run
  para_threads_per_cpu      NUMBER := 0;  -- parallel threads per cpu
  pdbs_para                 NUMBER := 0;  -- default # PDBs that can upgrade
                                          --   in parallel
  n_para_slaves_can_run     NUMBER := 0;  -- estimated # of parallel slaves
                                          --   that can run during the upgrade
  n_user_proc_to_run        NUMBER := 0;  -- estimated # of user processes to
                                          --   to run during the upgrade
  n_total_proc_to_run       NUMBER := 0;  -- total # processes to spawn
                                          --   during upgrade
BEGIN

  -- minimum value for PROCESSES for the upgrade is 300
  store_minval_param('processes', &C_DEFAULT_PROCESSES);

  -- find value of PROCESSES currently set
  execute immediate 'select value from sys.v$parameter  
                       where name = ''processes'''
                    into processes_value_now;

  -- if PROCESSES currently set is less than our minimum (300) THEN set
  -- min value to 300
  IF processes_value_now < all_parameters('processes').min_value THEN
    processes_value_now := all_parameters('processes').min_value;
  END IF;

  -- find # of oracle processes (minus parallel slaves) running
  execute immediate 'select count(*) from sys.v$process 
                       where pname is not null and pname not like ''P0%'''
                    into n_background_proc_running;

  -- find # of parallel slaves currently running in lower version home
  execute immediate 'select count(*) from sys.v$process 
                       where pname like ''P0%'''
                    into n_para_slaves_running;

  -- find min # of parallel slaves that can run
  execute immediate 'select value from sys.v$parameter  
                         where name = ''parallel_min_servers'''
                      into n_min_para_slaves_can_run;

  -- if # of parallel slaves currently running (n_para_slaves_running) is 0
  --   OR less than parallel_min_servers (n_min_para_slaves_can_run), then
  --   lets set n_para_slaves_running to the higher value
  -- in upgrade mode, looks like there's 0 parallel slaves running even if
  --   parallel_min_servers is not 0.
  IF (n_para_slaves_running < n_min_para_slaves_can_run) THEN
    n_para_slaves_running := n_min_para_slaves_can_run;
  END IF;

  IF debug THEN
    dbms_output.put_line('CML 5 PROCESSES: para slaves '
                         || n_para_slaves_running);
  END IF;

  -- find max # of parallel slaves that can run
  execute immediate 'select value from sys.v$parameter  
                       where name = ''parallel_max_servers'''
                    into n_max_para_slaves_can_run;

  -- find value of parallel_threads_per_cpu
  execute immediate 'select value from sys.v$parameter  
                       where name = ''parallel_threads_per_cpu'''
                    into para_threads_per_cpu;

  -- at most # of PDBs upgrading at a time
  pdbs_para := num_pdbs_upg_in_parallel();

  -- estimated # of parallel slaves that can run during the upgrade
  -- there's a SQL in a1201000.sql with parallel hint of 2
  n_para_slaves_can_run := (db_cpus * para_threads_per_cpu) + (pdbs_para * 2);
  IF n_para_slaves_can_run >= n_max_para_slaves_can_run THEN
    n_para_slaves_can_run := n_max_para_slaves_can_run;
  END IF;

  -- # of user processes to run during the upgrade process
  IF pdbs_para = 0 THEN 
    n_user_proc_to_run := 4;  -- 2 catctl.pl processes + 1 datapatch + 1 fudge
  ELSE
    n_user_proc_to_run := pdbs_para * 4;  -- 2 sqlplus sessions + 1 datapatch
                                          -- + 1 fudge
  END IF;

  IF debug THEN
    dbms_output.put_line('CML1 PROCESSES: ' || n_background_proc_running
                         ||  ' ' || n_user_proc_to_run 
                         || ' ' || n_para_slaves_can_run
                         || ' ' || n_para_slaves_running);
  END IF;

  -- # of max processes that can run during upgrade
  IF (n_para_slaves_can_run <= n_para_slaves_running)
  THEN
    n_total_proc_to_run := n_background_proc_running + n_user_proc_to_run
                           + n_para_slaves_running;
    IF debug THEN
      dbms_output.put_line('CML2 PROCESSES: ' || n_total_proc_to_run);
    END IF;
  ELSE
    n_total_proc_to_run := n_background_proc_running + n_user_proc_to_run
                           + n_para_slaves_can_run;
    IF debug THEN
      dbms_output.put_line('CML3 PROCESSES: ' || n_total_proc_to_run);
    END IF;
  END IF;

  -- set new minimum value for PROCESSES if estimate is greater than value set
  -- OR greater than 300
  IF n_total_proc_to_run > processes_value_now THEN
    processes_value_to_set := n_total_proc_to_run;
    store_minval_param('processes', processes_value_to_set);
    IF debug THEN
      dbms_output.put_line('CML4 PROCESSES: ' || processes_value_to_set);
    END IF;
  END IF;
  
END find_processes_value;


-- *****************************************************************
--     find_all_pdb_archive_size
--  o return estimated minimum amount of archivelog size to be generated
--    for all pdbs.
-- *****************************************************************
FUNCTION find_all_pdb_archive_size RETURN NUMBER
IS
  check_stmt             VARCHAR2(500);    -- sql stmt to run
  rowcount               NUMBER := 0;      -- number of rows returned
  i                      NUMBER := 0;      -- loop counter
  min_pdb_archivelog_gen INTEGER:= 0;      -- estimated minimum amount of
                                           -- archivelog to be generated in pdbs
BEGIN

  IF debug_archive_fra = TRUE THEN
    dbms_output.put_line('ARCHIVE/FRA: begin of find_all_pdb_archive_size');
  END IF;

  check_stmt := 
    'SELECT count(*) FROM sys.cdb_registry ' ||
    '  WHERE namespace =''SERVER'' AND CON_ID <> 2 AND comp_id =:1 ';

  --
  -- because each pdb may have a subset of root's components...
  -- for each "processed" component in the registry for ROOT
  --   o find the # of pdbs that has this component
  --   o since seed may not be in cdb_registry, assume root's components are
  --     same as seed
  --   o apex sizes should not be included here since apex is not included
  --     in db upgrades to 18 and higher
  --
  FOR i in 1..cmp_info.count LOOP
    IF cmp_info(i).processed THEN
      BEGIN
        EXECUTE IMMEDIATE
          check_stmt
        INTO rowcount
        USING cmp_info(i).cid;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          rowcount := 0;
      END;

      IF debug_archive_fra = TRUE THEN
        dbms_output.put_line('ARCHIVE/FRA: ' || cmp_info(i).cid || ' ' ||
                             '# of pdbs ' || rowcount);
      END IF;
 
      min_pdb_archivelog_gen :=
        min_pdb_archivelog_gen +
            ((cmp_info(i).pdb_archivelog_kb * c_kb) * rowcount);

      IF debug_archive_fra = TRUE THEN
        dbms_output.put_line('ARCHIVE/FRA: ' || cmp_info(i).cid ||
                             ' pdb archive size ' ||
                             cmp_info(i).pdb_archivelog_kb);
        dbms_output.put_line('ARCHIVE/FRA: min_pdb_archivelog_gen ' ||
                             min_pdb_archivelog_gen);
      END IF;
    END IF;
  END LOOP;

  IF debug_archive_fra = TRUE THEN
    dbms_output.put_line('ARCHIVE/FRA: end of find_all_pdb_archive_size');
  END IF;

  -- return estimated minimum of archivelog size generated for all pdbs for now
  RETURN min_pdb_archivelog_gen;

END find_all_pdb_archive_size;


-- *****************************************************************
--     find_archive_dest_info Section
--
--
-- *****************************************************************

PROCEDURE find_archive_dest_info
IS
  dest_name          VARCHAR2(256) := '';  -- e.g. LOG_ARCHIVE_DEST_1
  destination        VARCHAR2(256) := '';  -- path to archived logs
  continue_check     BOOLEAN := TRUE;  -- continue checking if alert is needed 
  check_stmt         VARCHAR2(1000);   -- check if alert is needed
  min_archivelog_gen     NUMBER := 0;  -- min non-cdb/root archive bytes
  min_allpdb_archive_gen INTEGER:= 0;  -- min archivelog bytes for all pdbs

BEGIN

  IF debug_archive_fra = TRUE THEN
    dbms_output.put_line('ARCHIVE/FRA: begin of find_archive_dest_info');
  END IF;

  --
  -- step 0: initialize archivedest_info record
  --
  archivedest_info.dest_name := '';
  archivedest_info.destination := '';
  archivedest_info.status := 'INACTIVE';
  archivedest_info.min_archive_gen := 0;


  --
  -- step 1A:
  -- if db is a pdb, then no need to continue as this is a global check
  --
  IF (db_is_cdb = TRUE AND db_is_root = FALSE) THEN
    IF debug_archive_fra = TRUE THEN
      dbms_output.put_line('ARCHIVE/FRA: exiting because in pdb');
    END IF;
    RETURN;
  END IF;


  --
  -- step 1B:
  -- if db is not in archivelog mode. then no need to contiue
  --
  IF db_log_mode <> 'ARCHIVELOG' THEN
    IF debug_archive_fra = TRUE THEN
      dbms_output.put_line('ARCHIVE/FRA: exiting because db not in ' ||
                           'archivelog mode');
    END IF;
    RETURN;
  END IF;

  IF debug_archive_fra = TRUE THEN
    dbms_output.put_line('ARCHIVE/FRA: find_archive_dest_info: db_n_pdbs '
                         || db_n_pdbs);
  END IF;


  --
  -- step 2:
  -- calculate the minimum amount of archive logs for the upgrade
  -- that can be generated if ARCHIVING is on
  min_archivelog_gen := 0;   -- in bytes
  FOR i in 1..cmp_info.count LOOP
    IF cmp_info(i).processed THEN
      min_archivelog_gen := min_archivelog_gen
                            + (cmp_info(i).archivelog_kbytes * c_kb);
      IF debug_archive_fra = TRUE THEN
        dbms_output.put_line('ARCHIVE/FRA: ' || cmp_info(i).cid ||
                             ' archive size ' || cmp_info(i).archivelog_kbytes);
      END IF; 
    END IF;
  END LOOP;

  -- if there's at least 1 PDB in the CDB (seed counts as a PDB too), then
  -- return pdb archivelog minimum size for all PDBs.
  -- the size returned is in bytes.
  IF db_n_pdbs >= 1 THEN
    min_allpdb_archive_gen := find_all_pdb_archive_size;
  END IF; 

  IF debug_archive_fra = TRUE THEN
    dbms_output.put_line('ARCHIVE/FRA: min_archivelog_gen without pdbs ' ||
                         min_archivelog_gen);
    dbms_output.put_line('ARCHIVE/FRA: min_allpdb_archive_gen for all pdbs ' ||
                         min_allpdb_archive_gen);
    dbms_output.put_line('ARCHIVE/FRA: db_n_pdbs ' || db_n_pdbs);
  END IF;

  -- total estimated minimum amount of archive log size generated in upgrade.
  -- min_archivelog_gen is in bytes for non-cdb and cdb.
  -- for now, caculate as if the entire cdb is upgrading.
  min_archivelog_gen := min_archivelog_gen + min_allpdb_archive_gen;

  archivedest_info.min_archive_gen := min_archivelog_gen;

  -- min_archivelog_gen is in bytes; pMinArchiveLogGen is in KBytes
  pMinArchiveLogGen := min_archivelog_gen / c_kb;


  --
  -- step 3:
  -- Determine whether archive destination outside of FRA is set.
  -- note: we only want 1 log_archive_dest_N to be returned
  -- note: we only care about TARGET='PRIMARY' because we want to exclude
  --       those cases when there is a standby in the configuration.
  --
  check_stmt :=
    'SELECT dest_name, destination, status ' || 
    'FROM sys.v$archive_dest ' ||
    'WHERE ' ||
      'upper(status) <> ''INACTIVE'' ' ||
      'AND destination IS NOT NULL ' ||
      'AND destination <> ''USE_DB_RECOVERY_FILE_DEST'' ' ||
      'AND destination NOT IN ' ||
      '  (select value from v$parameter ' ||
      '     where name = ''db_recovery_file_dest'' AND value IS NOT NULL) ' ||
      'AND target=''PRIMARY'' ' ||
      'AND rownum = 1';

  BEGIN
    EXECUTE IMMEDIATE
       check_stmt
       INTO archivedest_info.dest_name,
            archivedest_info.destination,
            archivedest_info.status;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      continue_check := FALSE;
  END; 

  IF (continue_check = FALSE) THEN
    -- no need to go further, as archive destination(s) outside of
    -- recovery area is not used
    IF debug_archive_fra = TRUE THEN
      dbms_output.put_line('ARCHIVE/FRA: exiting because archived logs ' ||
                           'are not going to a destination outside of fra');
    END IF;
    RETURN;
  END IF;

  -- if we're here, then there is at least one LOG_ARCHIVE_DEST_<N> specified
  IF debug_archive_fra = TRUE THEN
    dbms_output.put_line('ARCHIVE/FRA: name ' || archivedest_info.dest_name);
    dbms_output.put_line('ARCHIVE/FRA: dest ' || archivedest_info.destination);
    dbms_output.put_line('ARCHIVE/FRA: status ' || archivedest_info.status);
  END IF;
    

  --
  -- step 4: return.
  -- If we're here, then note:
  -- archive logs destination is outside of FRA and
  -- the size cap is NOT controlled by DB_RECOVERY_FILE_DEST_SIZE.
  --

  IF debug_archive_fra = TRUE THEN
    dbms_output.put_line('ARCHIVE/FRA: pMinArchiveLogGen ' ||
                         pMinArchiveLogGen);
    dbms_output.put_line('ARCHIVE/FRA: end of find_archive_dest_info');
  END IF;

  RETURN;

END find_archive_dest_info;


-- *****************************************************************
--     find_recovery_area_info
--
-- Determine minimum free space needed for when:
--  a) Archivelog is on
--  b) Flashback Database is on
--
-- *****************************************************************

PROCEDURE find_recovery_area_info
IS
  row_count          NUMBER  := 0;     -- row found if row count >= 1

  space_limit        NUMBER := 0;     -- bytes in db_recovery_file_dest_size
  space_used         NUMBER := 0;     -- bytes used from space_limit 
  space_reclaimable  NUMBER := 0;     -- bytes reclaimable from space_used
  space_avail        NUMBER := 0;     -- bytes avail from space_limit (bytes)
  fra_files          NUMBER := 0;     -- # of files in recovery area
  new_spacelimit     NUMBER := 0;     -- new minimum space_limit in bytes

  check_stmt  VARCHAR2(1000);                        -- check if alert is needed
  fra_dest    V$RECOVERY_FILE_DEST.NAME%TYPE := '';  -- dba_recovery_file_dest

  min_archivelog_gen     NUMBER := 0;  -- min archivelog bytes to be generated
  min_flashback_gen      NUMBER := 0;  -- min flashback bytes to be generated
  min_freespace_reqd     NUMBER := 0;  -- min free space needed for fra to grow
                                       -- sum of archivelog + flashbacklog bytes
  additional_size        NUMBER := 0;  -- size to be added to
                                       -- db_recovery_file_dest_size

BEGIN

  IF debug_archive_fra = TRUE THEN
    dbms_output.put_line('ARCHIVE/FRA: begin of find_recovery_area');
  END IF;


  --
  -- step 0: initialize fra_info record
  --
  fra_info.name               := '';  -- destination name/path
  fra_info.limit              := 0;   -- db_recovery_file_dest_size (bytes)
  fra_info.used               := 0;   -- Used (bytes)
  fra_info.dsize              := 0;   -- db_recovery_file_dest_size (bytes)
  fra_info.reclaimable        := 0;   -- bytes reclaimable
  fra_info.files              := 0;   -- number of files
  fra_info.avail              := 0;   -- bytes available in FRA
  fra_info.min_archive_gen    := 0;   -- minimum archive logs (bytes) estimated
  fra_info.min_flashback_gen  := 0;   -- rough minimum flashback logs (bytes)
  fra_info.min_fra_size       := 0;   -- new db_recovery_file_dest_size to set
  fra_info.min_freespace_reqd := 0;   -- min free space needed for logs
  fra_info.additional_size    := 0;   -- additional size + limit = min_fra_size


  --
  -- step 1A:
  -- if db is a pdb, then no need to continue as this is a global check
  --
  IF (db_is_cdb = TRUE AND db_is_root = FALSE) THEN
    IF debug_archive_fra = TRUE THEN
      dbms_output.put_line('ARCHIVE/FRA: exiting because in pdb');
    END IF;
    RETURN;
  END IF;


  --
  -- step 1B:
  -- no need to continue if FRA is not enabled
  -- i.e. db_recovery_file_dest nor db_recovery_file_dest_size are not set
  --
  IF (db_fra_set = FALSE) THEN
    IF debug_archive_fra = TRUE THEN
      dbms_output.put_line('ARCHIVE/FRA: exiting because fra not set');
    END IF;
    RETURN;
  END IF;


  --
  -- step 2:
  -- db is not in archivelog mode.
  -- and if archivelog is not on, then flashback cannot be on.
  -- then no need to continue with the checks as no archive nor flashback
  -- logs will be generated into FRA 
  --
  IF db_log_mode <> 'ARCHIVELOG' THEN
    IF debug_archive_fra = TRUE THEN
      dbms_output.put_line('ARCHIVE/FRA: exit because archivelog mode not set');
    END IF;
    RETURN; 
  END IF;


  --
  -- step 3:
  -- find info about recovery area
  -- is recovery area set?
  --
  check_stmt :=
  'SELECT r.name, r.space_limit, r.space_used, r.space_reclaimable, ' ||
  '  r.number_of_files ' ||
  'FROM sys.v$recovery_file_dest r, sys.v$parameter p '||
  'WHERE ' ||
    'r.name = p.value ' ||
    '  AND p.name = ''db_recovery_file_dest'' ' ;

  BEGIN
    EXECUTE IMMEDIATE
       check_stmt
       INTO fra_dest, space_limit, space_used, space_reclaimable, fra_files;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- something wrong if FRA is enabled but no data returned... 
      -- no need to go further, as failure to find recovery area info.
      -- internal_error will raise error and exit
      internal_error('Error in FIND_RECOVERY_AREA step 3a');
    WHEN OTHERS THEN
      -- no need to go further, as failure to find recovery area info.
      -- internal_error will raise error and exit
      internal_error('Error in FIND_RECOVERY_AREA step 3b');
  END; 


  --
  -- step 4:
  -- there can be 1 or more destinations for archive logs.
  -- we just want to know if one of the archive log destination(s) is FRA?
  -- note: we only care about TARGET='PRIMARY' because we want to exclude
  --       those cases when there is a standby in the configuration.
  -- 
  check_stmt :=
    'SELECT count(*) ' || 
    'FROM sys.v$archive_dest ' ||
    'WHERE ' ||
      '(destination = ''USE_DB_RECOVERY_FILE_DEST'' ' ||
      '   OR destination = ' ||
      '      (select value from v$parameter ' ||
      '       where name = ''db_recovery_file_dest'' ' ||
      '         AND value IS NOT NULL)) '||
      'AND target=''PRIMARY'' ' ||
      'AND upper(status) <> ''INACTIVE'' ';

  BEGIN
    EXECUTE IMMEDIATE
       check_stmt
       INTO row_count;
  EXCEPTION
    WHEN OTHERS THEN
      -- something wrong if can't find the info here
      -- raise error and then exit
      internal_error('Error in FIND_RECOVERY_AREA step 4');
  END; 
 

  --
  -- step 5:
  -- if one of the archive log destination(s) is FRA, then determine
  -- how much free space is required in FRA for archive logs: 
  is_archivelog_in_fra := FALSE;  -- initialize
  IF row_count >= 1 THEN
    is_archivelog_in_fra := TRUE;  -- set global variable

    -- min_archive_gen is in bytes
    -- min_freespace_reqd is in bytes
    -- pMinArchiveLogGen is in KBytes
    min_archivelog_gen := pMinArchiveLogGen * c_kb;
    min_freespace_reqd := min_archivelog_gen;
  ELSE
    min_freespace_reqd := 0;
  END IF;

  IF debug_archive_fra = TRUE THEN
    IF is_archivelog_in_fra = TRUE THEN
      dbms_output.put_line('ARCHIVE/FRA: is_archivelog_in_fra is TRUE');
    ELSE
      dbms_output.put_line('ARCHIVE/FRA: is_archivelog_in_fra is FALSE');
    END IF;
  END IF;

  --
  -- step 6:
  -- calculate the minimum amount of flashback logs for the upgrade
  -- that can be generated if FLASHBACK is on
  --
  IF db_flashback_on = TRUE THEN
    FOR i in 1..cmp_info.count LOOP
      -- this is for non-cdb OR ROOT
      IF cmp_info(i).processed THEN
        -- min_flashback_gen is in bytes
        min_flashback_gen := min_flashback_gen
                                + (cmp_info(i).flashbacklog_kbytes * c_kb);
        IF debug_archive_fra = TRUE THEN
          dbms_output.put_line('ARCHIVE/FRA: ' || cmp_info(i).cid ||
                               ' flashback size ' ||
                               cmp_info(i).flashbacklog_kbytes);
        END IF; 
      END IF;
    END LOOP;

    IF debug_archive_fra = TRUE THEN
      dbms_output.put_line('ARCHIVE/FRA: min_flashback_gen without pdbs ' ||
                           min_flashback_gen);
    END IF;

    -- include an estimate for flasbhback logs generated for SEED and PDBs
    -- min_flashback_gen is in bytes
    min_flashback_gen := min_flashback_gen +
                            ((C_MIN_FLASHBACK_KB_PER_PDB * c_kb) * db_n_pdbs);
 
    -- min_flashback_gen is in bytes; pMinFlashbackLogGen is in KBytes
    pMinFlashbackLogGen  := min_flashback_gen / c_kb;

    IF debug_archive_fra = TRUE THEN
      dbms_output.put_line('ARCHIVE/FRA: min_freespace_reqd with archive ' ||
                           'in fra is ' || min_freespace_reqd);
      dbms_output.put_line('ARCHIVE/FRA: min_flashback_gen with pdbs ' ||
                           min_flashback_gen);
      dbms_output.put_line('ARCHIVE/FRA: final pMinFlashbackLogGen ' ||
                           pMinFlashbackLogGen);
    END IF;
  END IF;


  --
  -- step 7:
  -- mathematical calculations
  --

  -- from step 5, add up min freespace needed for archive logs (if any) +
  -- min freespace needed for flashback logs in fra
  min_freespace_reqd := min_freespace_reqd + min_flashback_gen;

  -- note: space_avail can be negative # if space_used > space_limit
  space_avail := space_limit - space_used;

  IF space_avail >= min_freespace_reqd THEN
    new_spacelimit  := min_freespace_reqd + space_used;
    additional_size := 0;
  ELSE  -- space_avail < min_freespace_reqd
    new_spacelimit  := space_limit + (min_freespace_reqd - space_avail);
    additional_size := new_spacelimit - space_limit;
  END IF;

  IF debug_archive_fra = TRUE THEN
    dbms_output.put_line('ARCHIVE/FRA: space_limit ' || space_limit);
    dbms_output.put_line('ARCHIVE/FRA: space_used '  || space_used);
    dbms_output.put_line('ARCHIVE/FRA: space_avail ' || space_avail);
    dbms_output.put_line('ARCHIVE/FRA: min_freespace_reqd ' ||
                         min_freespace_reqd);
    dbms_output.put_line('ARCHIVE/FRA: new_spacelimit '  || new_spacelimit);
    dbms_output.put_line('ARCHIVE/FRA: additional_size ' || additional_size);
  END IF;


  --
  -- step 8: assign values back to fra_info
  --
  fra_info.name               := fra_dest;
  fra_info.limit              := space_limit;
  fra_info.used               := space_used;
  fra_info.dsize              := space_limit;
  fra_info.reclaimable        := space_reclaimable;
  fra_info.files              := fra_files;
  IF space_avail >= 0 THEN  -- do not display a negative value for avail space
    fra_info.avail            := space_avail;
  ELSE
    fra_info.avail            := 0;
  END IF;
  fra_info.min_archive_gen    := min_archivelog_gen;  -- generated in fra
  fra_info.min_flashback_gen  := min_flashback_gen;   -- generated in fra
  fra_info.min_fra_size       := new_spacelimit;
  fra_info.min_freespace_reqd := min_freespace_reqd;
  fra_info.additional_size    := additional_size;

  IF debug_archive_fra = TRUE THEN
    dbms_output.put_line('ARCHIVE/FRA: end of find_recovery_area');
  END IF;

  RETURN; 

END find_recovery_area_info;


--
--    ##NEW_CHECK## - add new *_check functions above here
--                    and optionally, the *_fixup function right after it.
--

BEGIN
  pDBGSizeResources := debug;

  check_level_ints( check_level_strings(c_check_level_success) ) := c_check_level_success;
  check_level_ints( check_level_strings(c_check_level_warning) ) := c_check_level_warning;
  check_level_ints( check_level_strings(c_check_level_info) ) := c_check_level_info;
  check_level_ints( check_level_strings(c_check_level_error) ) := c_check_level_error;
  check_level_ints( check_level_strings(c_check_level_recommend) ) := c_check_level_recommend;

  C_ORACLE_HIGH_VERSION_4_DOTS := '&C_ORACLE_HIGH_VERSION_4_DOTS';
  EXECUTE IMMEDIATE 'SELECT version FROM v$instance' INTO db_version_4_dots;
  db_version_3_dots := dbms_registry_extended.convert_version_to_n_dots(db_version_4_dots,3);
  db_version_2_dots := dbms_registry_extended.convert_version_to_n_dots(db_version_4_dots,2);
  db_version_1_dot  := dbms_registry_extended.convert_version_to_n_dots(db_version_4_dots,1);
  db_version_0_dots := dbms_registry_extended.convert_version_to_n_dots(db_version_4_dots,0);

  db_inplace_upgrade := (dbms_registry_extended.compare_versions(C_ORACLE_HIGH_VERSION_4_DOTS, db_version_4_dots, 3 ) = 0);

  EXECUTE IMMEDIATE 'SELECT name    FROM v$database' INTO db_name;
  EXECUTE IMMEDIATE 'SELECT dbms_preup.get_con_name FROM sys.dual' INTO con_name;
  EXECUTE IMMEDIATE 'SELECT dbms_preup.get_con_id FROM sys.dual' INTO con_id;

  EXECUTE IMMEDIATE 'SELECT value   FROM v$parameter WHERE name = ''compatible'''
     INTO db_compatible;

  EXECUTE IMMEDIATE 'SELECT value FROM v$parameter WHERE name = ''db_block_size'''
     INTO db_block_size;
  EXECUTE IMMEDIATE 'SELECT value FROM v$parameter WHERE name = ''undo_management'''
       INTO db_undo;
  EXECUTE IMMEDIATE 'SELECT UPPER(value) FROM v$parameter WHERE name = ''undo_tablespace'''
       INTO db_undo_tbs;
  EXECUTE IMMEDIATE 'SELECT value FROM sys.v$parameter WHERE name = ''cpu_count'''
        INTO param_as_string;
  db_cpus := to_number (param_as_string);
  EXECUTE IMMEDIATE
     'SELECT value FROM v$parameter WHERE name = ''parallel_threads_per_cpu'''
  INTO param_as_string;
  db_cpu_threads := pvalue_to_number(param_as_string);
  EXECUTE IMMEDIATE 'SELECT version from v$timezone_file'
    INTO db_tz_version;
  EXECUTE IMMEDIATE 'SELECT LOG_MODE from v$database'
     INTO db_log_mode;

  BEGIN
    db_is_XE := FALSE;
    EXECUTE IMMEDIATE
       'SELECT edition FROM sys.registry$ WHERE cid=''CATPROC'''
       INTO edition_str;
      IF edition_str = 'XE' THEN
         db_is_XE := TRUE;
      END IF; -- XE edition
  EXCEPTION
      WHEN OTHERS THEN
          NULL;
  END;

/***************************************************************************************
* Bug 23278082 - PREUPGRADE TOOL: PREUPGRADE_DRIVER.SQL ON 12.2.0.1 
*                DB: ORA-01403: NO DATA FOUND 
*
* The following query returns no rows in 12.2+, the solution is to add null management
* to the query, making it an anonymous procedure.
* 
****************************************************************************************/
  db_VLM_enabled := select_varchar2('SELECT value FROM v$parameter WHERE name =
    ''use_indirect_data_buffers''','NO_DATA') = 'TRUE';

  EXECUTE IMMEDIATE 'SELECT open_mode FROM sys.v$database' INTO param_as_string;
  db_is_readonly := (SUBSTR(param_as_string, 1, 9) = 'READ ONLY');

/***************************************************************************************
* BUG 22124723: UPGRADE:THE NEW PREUPGRADE TOOL REPORT WRONG OPEN MODE OF PDB$SEED
*
* If PDB is SEED and due to the catcon or sqlplus approaches need to have the SEED in 
* read write mode, changing the logic to report as READ ONLY.
****************************************************************************************/

  IF (con_name like 'PDB%SEED') AND (NOT db_is_readonly) THEN
    db_is_readonly := TRUE;
  END IF;
  

  BEGIN
    EXECUTE IMMEDIATE 'select cdb from v$database' into cdb_string;
    db_is_cdb := (cdb_string = 'YES');
  EXCEPTION
    WHEN OTHERS THEN
      db_is_cdb := FALSE;
      cdb_constraint := '';
  END;

  IF db_is_cdb THEN
    cdb_constraint := ' AND origin_con_id IN (SELECT MAX(origin_con_id) FROM dba_directories ' ||
                      ' WHERE directory_name=''PREUPGRADE_DIR'' AND owner=''SYS'' AND ' ||
                      ' ((origin_con_id = 1) OR (origin_con_id = ' || to_char(con_id) || ')))';
  ELSE
    cdb_constraint := '';
  END IF;

  -- if this is a cdb, then query cdb/pdb info and assign to "global" variables
  IF db_is_cdb THEN
    db_n_pdbs  := sys.dbms_preup.get_npdbs;    -- # of pdbs as seen in v$pdbs
    db_is_root := sys.dbms_preup.is_con_root;  -- is container db ROOT? T/F
  ELSE
    db_n_pdbs  := 0;
    db_is_root := FALSE;
  END IF;


  --
  -- Flashback on can have several 'on' states, but only one 'off' so check
  -- for NO.
  -- Put inside begin/end to catch execution on pre 10.x DB's where undo_tablespace
  -- is not defined yet.
  --
  BEGIN
    EXECUTE IMMEDIATE 'SELECT count(*) FROM v$database  WHERE flashback_on = ''NO'''
      INTO flashback_off;
    db_flashback_on := (flashback_off = 0);
    EXCEPTION
      WHEN OTHERS THEN
        db_flashback_on := TRUE;
  END;


  -- find out if fast recovery area (or FRA) is set
  -- note: answer is yes if init parameters db_recovery_file_dest_size
  --       and db_recovery_file_dest are set
  db_fra_set := FALSE;  -- initialize, FRA not set
  tmp_count  := 0;      -- initialize, 0 rows returned
  BEGIN
    EXECUTE IMMEDIATE
      'SELECT count(*)
       FROM sys.v$parameter
       WHERE (name = ''db_recovery_file_dest'' AND value IS NOT NULL)'
    INTO tmp_count;

    -- IF tmp_count >= 1, then db_recovery_file_dest is set.
    -- IF db_recovery_file_dest is set, then find out if
    -- db_recovery_file_dest_size is set.  If yes, then set db_fra_set to TRUE.
    IF tmp_count >= 1 THEN
      tmp_count := 0;  -- initialize, # of rows returned
      EXECUTE IMMEDIATE
        'SELECT count(*)
         FROM sys.v$parameter
         WHERE (name = ''db_recovery_file_dest_size'' AND value <> ''0'')'
      INTO tmp_count;
      -- IF tmp_count >= 1, then db_recovery_file_dest_size is set.
      IF tmp_count >= 1 THEN
        db_fra_set := TRUE;
      END IF;
    ELSE  -- tmp_count = 0
      db_fra_set := FALSE;  -- db_recovery_file_dest is not set
    END IF;

    IF debug_archive_fra = TRUE THEN
      IF db_fra_set = TRUE THEN
        dbms_output.put_line('ARCHIVE/FRA: fra set is TRUE');
      ELSIF db_fra_set = FALSE THEN
        dbms_output.put_line('ARCHIVE/FRA: fra set is FALSE');
      ELSE
        dbms_output.put_line('ARCHIVE/FRA: fra set is BLANK');
      END IF;
    END IF;
  END;
  -- end of setting db_fra_set


  EXECUTE IMMEDIATE 'SELECT platform_id, platform_name
           FROM v$database'
  INTO db_platform_id, db_platform;
  IF db_platform_id NOT IN (1,7,10,15,16,17) THEN
    db_64bit := TRUE;
  ELSE
    db_64bit := FALSE;
  END IF;
  db_32bit := NOT db_64bit;

  --
  -- Set the newline and dir separator depending on platform
  --
  IF INSTR(db_platform, 'WINDOWS') != 0 THEN
    crlf := CHR(13) || CHR(10);       -- Windows gets the \r and \n
    crlf_length := 2;
    dir_sep := '\';
  ELSE
    crlf := CHR (10);                 -- Just \n for the rest of the world
    crlf_length := 1;
    dir_sep := '/';
  END IF ;

  BEGIN
      EXECUTE IMMEDIATE 
    	'select substr(regexp_substr(banner, ''[^ ]+'', 1, 4),1,1) || 
    	substr(regexp_substr(banner, ''[^ ]+'', 1, 5),1,1)
        from v$version
        where regexp_like(banner, ''Oracle Database.*'', ''i'')' 
       INTO db_edition;
  EXCEPTION
      WHEN OTHERS THEN
          db_edition := '';
  END;

  BEGIN
      EXECUTE IMMEDIATE 'select directory_path from dba_directories
                         where directory_name=''PREUPGRADE_DIR'' and user=''SYS'' '
      INTO preupgrade_dir_path;
      IF substr(preupgrade_dir_path,length(preupgrade_dir_path),1) = dir_sep THEN
          preupgrade_dir_path := substr(preupgrade_dir_path,1,length(preupgrade_dir_path)-1);
      END IF;
  EXCEPTION
      WHEN OTHERS THEN
          -- the PreupgradeDriver.java takes care of setting
          -- PREUPGRADE_DIR, the code here should never execute
          -- and the value is given for debugging help.
          preupgrade_dir_path := 'PREUPGRADE_DIR_is_not_defined';
  END;

  severity_names(C_CHECK_LEVEL_SUCCESS) :=   'SUCCESS';
  severity_names(C_CHECK_LEVEL_INFO) :=      'INFORMATION USEFUL';
  severity_names(C_CHECK_LEVEL_WARNING) :=   'DBA ACTION HIGHLY RECOMMENDED';
  severity_names(C_CHECK_LEVEL_ERROR) :=     'DBA ACTION REQUIRED';
  severity_names(C_CHECK_LEVEL_RECOMMEND) := 'DBA ACTION RECOMMENDED';

  invalid_xml_message.id := 'INVALID_XML';

  init_messages();
  init_components();
  init_resources();
  init_parameters();

  --
  --    Find the properties file with all the CHECK properties
  --



END dbms_preup;
/

show errors;
