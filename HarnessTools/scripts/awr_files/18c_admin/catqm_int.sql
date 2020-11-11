Rem
Rem $Header: rdbms/admin/catqm_int.sql /main/45 2017/09/14 17:35:42 raeburns Exp $
Rem
Rem catqm_int.sql
Rem
Rem Copyright (c) 1900, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catqm_int.sql - CAtalog script for sQl xMl management 
Rem
Rem    DESCRIPTION
Rem      Creates the tables and views needed to run the XDB system 
Rem      Run this script like this:
Rem        catqm_int.sql <XDB_PASSWD> <TABLESPACE> <TEMP_TABLESPACE> <SECURE_FILES_REPO>
Rem          -- XDB_PASSWD: password for XDB user
Rem          -- TABLESPACE: tablespace for XDB 
Rem          -- TEMP_TABLESPACE: temporary tablespace for XDB 
Rem          -- SECURE_FILES_REPO: if YES and compatibility is at least 11.2,
Rem               then XDB repository will be stored as secure files;
Rem               otherwise, old LOBS are used. There is no default value for
Rem               this parameter, the caller must pass either YES or NO.
Rem    NOTES
Rem      Must be run connected as SYS 
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catqm_int.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catqm_int.sql
Rem SQL_PHASE: CATQM_INT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    09/10/17 - Bug 26255427: Store version_full for components
Rem    hxzhang     06/17/16 - bug#23085530, gather stats on xdb$element
Rem    dmelinge    02/03/16 - Tighter grant for xdb, bug 22646079
Rem    qyu         02/17/16 - #22733705: set nls_length_semantics
Rem    dmelinge    12/10/15 - No User$ access for XDB, bug 22249624
Rem    rpang       11/13/15 - Move EPG to catxrd.sql
Rem    prthiaga    05/19/15 - Bug 21116398 : Install SODA APIs
Rem    alejgarc    01/26/15 - BUG 20399894: Modifying tname for long id.
Rem    yinlu       01/07/15 - add dbms_json package
Rem    prthiaga    12/08/14 - Proj 47294: Create table for prvtxdb
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    raeburns    11/21/14 - add prvtxsch0.plb
Rem    dmelinge    11/14/14 - SetRemoteHttpPort, SR 38986558561
Rem    prthiaga    09/30/14 - Dont install SODA APIs for now
Rem    raeburns    09/02/14 - add script for RDBMS dependents
Rem                         - turn on error logging in UPGRADE mode
Rem    raeburns    07/22/14 - add files moved from catxdbv to xdbload.sql
Rem    raeburns    05/16/14 - remove xdb.migr9202status table - no longer used
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    pknaggs     11/14/13 - Bug #17476266, 14750963: IDENTIFIED BY VALUES
Rem    ckavoor     11/13/13 - 12932757:Remove xdb_installation_tab,
Rem                           xdb_installation_trigger
Rem    prthiaga    06/21/13 - Bug 16993014 - prvtxmld.sql and prvtxmlp.sql
Rem                           require prvtxslp.sql for compilation
Rem    qyu         03/18/13 - ORACLE_SCRIPT change
Rem    qyu         01/04/13 - XbranchMerge qyu_bug-16035192 from
Rem                           st_rdbms_12.1.0.1
Rem    qyu         12/26/12 - 16035192: set verify off
Rem    stirmizi    10/30/12 - add XDB.XDB$IMPORT_TT_INFO table
Rem    minx        09/27/12 - XS XDB cleanup
Rem    thbaby      06/13/12 - remove CDB view creation; done in catpend
Rem    gravipat    05/14/12 - create_cdbviews is now part of CDBView package
Rem    qyu         04/20/12 - bug 13940907: xdb recompile invalid objects 
Rem    stirmizi    04/11/12 - remove grant statements on xdb$workspace
Rem    thbaby      03/31/12 - add xdb.xdb$cdbports
Rem    dalpern     02/15/12 - proj 32719: INHERIT PRIVILEGES privilege
Rem    vhosur      02/20/12 - Include prvtxsfsclient (after CDB fix)
Rem    srirkris    11/07/11 - add dbms_xschlsb package
Rem    hxzhang     01/18/12 - grant set container to xdb
Rem    sursridh    12/07/11 - bug 13425408: grant exec on dbms_pdb_exec_sql to
Rem                           XDB
Rem    hxzhang     10/18/11 - add dbmsxdbc and dbmsxdbr
Rem    thbaby      09/08/11 - remove indexes on xdb.xdb$acl
Rem    rpang       07/25/11 - Proj 32719: grant inherit any privileges to xdb
Rem    yinlu       08/05/11 - add dbms_xlsb package
Rem    thbaby      08/03/11 - move role stuff out of catxdbc1
Rem    bhammers    04/29/11 - Create xdb manageability tools
Rem    jheng       06/26/11 - Proj 32973: grant to xdb
Rem    jmadduku    02/18/11 - Proj 32507: Grant Unlimited Tablespace privilege
Rem                           explicitly
Rem    spetride    05/16/11 - grant select to select_catalog_role
Rem    gravipat    05/09/11 - DB Consolidation: Create cdbviews
Rem    yuli        09/07/10 - raise minimum compatible to 11.0
Rem    yiru        05/09/10 - XS Drop6R cleanup before merge-down
Rem    yiru        03/31/10 - Remove DBMS_XSNST_LIB
Rem    badeoti     05/07/10 - disable xdk schema caching for inserts into csx
Rem                           tables during install
Rem    vmedi       05/06/10 - revert 9144511 changes
Rem    badeoti     04/23/10 - 9451814: adding prompt for input parameters
Rem    spetride    12/02/09 - 9144511: disable sch validation for XS
Rem    spetride    04/04/09 - turned on tracing for catzxs (for 8313801)
Rem    skabraha    02/19/09 - use event 44715 to denote XDB initialization
Rem    badeoti     03/20/09 - remove public synonyms for XDB internal packages
Rem    yiru        03/06/09 - add XS$NULL into XDB schema list
Rem    spetride    03/06/09 - 8251841: children col in xdb.xdb$h_index 
Rem                           cannot be securefile
Rem    spetride    02/06/09 - lrg 3573827: install trigger to allow sequences
Rem    spetride    01/26/09 - 7714185: document user_opt_secfiles
Rem    spetride    11/15/08 - xdb_installation_trigger: allow triggers
Rem    spetride    06/24/08 - run catxdpapp
Rem    spetride    04/29/08 - option: use secure files for xdb$resource
Rem    sipatel     09/29/08 - bug 7414934. call catxtbix
Rem    sichandr    09/23/08 - load dbmsxdbrepos
Rem    badeoti     09/21/08 - 6451792: add object validation to XDB
Rem    snadhika    07/07/08 - create library DBMS_XSNST_LIB  
Rem    achoi       03/11/08 - register ANONYMOUS as part of XDB
Rem    sidicula    01/10/08 - Grants to dba, system
Rem    thbaby      10/27/07 - split prvtxdb to create prvtxdba
Rem    vkapoor     04/27/07 - lrg 2941734
Rem    vkapoor     04/09/07 - bug 5640175
Rem    bpwang      10/19/06 - bug 5633032
Rem    thbaby      11/02/06 - move dbms_xmlindex package body into prvtxidx
Rem    pthornto    10/09/06 - move catzxs.sql to EOF
Rem    vkapoor     07/25/06 - Bug 5371725
Rem    rtjoa       05/26/06 - change prvtxdz2.plb location
Rem    rmurthy     04/21/06 - add prvtxdz2.plb 
Rem    ataracha    06/08/06 - move dbmsxidx before catxidx
Rem    rmurthy     06/02/06 - call catxdbdl for document links 
Rem    pnath       03/22/06 - add prvtxdbdl.plb 
Rem    pthornto    05/18/06 - add DBMS_XSH_LIB 
Rem    nkhandel    02/20/06 - DOM streaming APIs added 
Rem    smalde      03/09/06 - Add dbms_xmltranslations 
Rem    petam       04/07/06 - separate out the install of ResConfig from ACL 
Rem    abagrawa    03/11/06 - Add xdbready 
Rem    cchui       03/02/06 - move after resconfig package is installed 
Rem    mrafiq      03/06/06 - move catzxs after catxdbpv 
Rem    pnath       02/15/06 - remove link_props from xdb.xdb$d_link 
Rem    rmurthy     02/03/06 - add xdb.d_link table 
Rem    thbaby      02/21/06 - add NFS info into rootinfo
Rem    rtjoa       02/16/06 - Create a schedule for nfsclient cleanup job 
Rem    pnath       10/13/05 - submit job for nfs client cleanup 
Rem    sidicula    01/18/06 - Adding protocol info into rootinfo 
Rem    taahmed     01/18/06 - Extensible Security 
Rem    mrafiq      09/20/05 - merging changes for upgrade/downgrade 
Rem    thoang      09/22/04 - add dbmsxres.sql & prvtxres.plb 
Rem    ataracha    04/14/04 - add pl/sql dom, xml parser, AND xsl processor
Rem    nkandalu    07/25/05 - 4494717: set upgrade status if XDB is VALID 
Rem    sidicula    06/25/05 - No need for dbmsxadm as yet 
Rem    rmurthy     03/09/05  - drop function for patching namespace 
Rem    vkapoor     01/13/05 -  LRG 1804464 
Rem    pnath       12/01/04 - prvtxdb.sql needs prvtxmld.sql to be compiled 
Rem    pnath       11/16/04 - delete all objects created in installation 
Rem    rpang       11/18/04 - Add catepg.sql
Rem    rmurthy     11/11/04 - add dbmsxidx
Rem    petam       11/11/04 - added execution of xdbinstd.sql
Rem    najain      07/14/04 - add stateid_restart_sequence
Rem    pnath       10/22/04 - Make SYS the owner of package dbms_regxdb 
Rem    fge         10/29/04 - call prvtxdr0
Rem    attran      08/20/04 - xmlidx
Rem    rburns      08/17/04 - conditionally run dbmsxdbt 
Rem    rpang       07/16/04 - Renamed epgc to epg
Rem    fge         07/08/04 - extend xdb$h_link
Rem    sbalaram    06/10/04 - Add catxlcr - xml schema definitions for LCRs
Rem    rpang       06/07/04 - Add dbmsepgc.sql and prvtepgc.plb
Rem    smukkama    02/27/04 - move catxdbtm.sql to after prvtxdb.sql
Rem    smukkama    01/05/04 - add catxdbtm.sql for compact xml token mgmt
Rem    attran      02/17/04 - XMLIndex 
Rem    najain      01/27/04 - call prvtxdb0 and prvtxdz0
Rem    fge         08/01/03 - xdb$h_link: add secondary index on child_oid
Rem    sidicula    07/03/03 - prvtxdb to be executed after prvtxdbz
Rem    fge         05/19/03 - add catxdbeo.sql
Rem    sidicula    04/16/03 - Revoke powerful privileges from XDB
Rem    abagrawa    03/09/03 - Separate dbmsxsch and prvtxsch
Rem    njalali     02/11/03 - setting upgrade state to 1000
Rem    smuralid    01/09/03 - add dbmsxdbt
Rem    sichandr    12/16/02 - invoke pre-condition checks
Rem    njalali     11/14/02 - making sure 9.2.0.1 -> 9.2.0.2 mig. is noop
Rem    mkrishna    07/05/02 - dissallow ref cascade for resource and schema tables
Rem    fge         06/13/02 - rename prvtpidx.sql to prvtxdbp.sql
Rem    sichandr    04/14/02 - remove index on refcount
Rem    spannala    03/26/02 - tieing the xdb version to the database version
Rem    sidicula    02/22/02 - Anonymous login allowed only by HTTP
Rem    njalali     02/11/02 - removed refcount from H_INDEX
Rem    rmurthy     02/20/02 - remove owner user
Rem    fge         01/20/02 - call prvtxdbr.plb
Rem    fge         01/08/02 - rename prvtxdbpi.sql to prvtpidx.sql
Rem    spannala    01/13/02 - correcting compilation errors in prvtxreg
Rem    spannala    01/02/02 - registry
Rem    sichandr    01/11/02 - catxdbstd.sql becomes catxdbst.sql
Rem    spannala    01/11/02 - creating all types with fixed toids
Rem    rmurthy     01/18/02 - add xdbowner role
Rem    nmontoya    12/18/01 - grant select any table to xdb
Rem    spannala    12/19/01 - removing connects, creating objects in xdb schema
Rem    spannala    12/13/01 - beta showstopper cleanup
Rem    nmontoya    11/29/01 - replace calls of prvt*.sql to prvt*.plb
Rem    nmontoya    11/14/01 - changing owner ID to GUID
Rem    nmontoya    11/13/01 - reorder dbmsxdb pkg
Rem    nagarwal    11/12/01 - change ordering of packages
Rem    tsingh      11/09/01 - XDB Fake installation and cleanup.
Rem    nagarwal    11/08/01 - change ordering of catxdbpi.sql 
Rem    najain      11/08/01 - catxdbpi.sql gets loaded before catxdbz.sql
Rem    nagarwal    11/05/01 - add catxdbpi.sql
Rem    nle         09/20/01 - add versioning package
Rem    abagrawa    09/27/01 - Add catxdbc1, catxdbc2
Rem    nmontoya    10/12/01 - ADD xdbadmin role
Rem    nagarwal    09/08/01 - add catxdbpv
Rem    nmontoya    08/21/01 - ADD pl/sql dom, xml parser, AND xsl processor
Rem    nmontoya    08/16/01 - grant alter session and dbms_rls execute to xdb
Rem    nagarwal    08/10/01 - add catxdbr
Rem    esedlar     08/09/01 - XDB standard packages
Rem    njalali     07/11/01 - Resource as XMLType
Rem    spannala    05/18/01 - xmltype_p -> xmltype
Rem    njalali     05/17/01 - split schema OID in resource into two columns
Rem    rmurthy     03/09/01 - move schema related setup to catxdbs.sql
Rem    tsingh      03/01/01 - load xdb.jar
Rem    njalali     02/15/01 - reinstated the WITH ROWID in the resource table
Rem    nmontoya    02/14/01 - Add security initialization
Rem    njalali     02/13/01 - added schema OID to resource table
Rem    rmurthy     02/02/01 - add support for element ref
Rem    mkrishna    01/29/01 - remove xmlindex related stuff 
Rem    rmurthy     01/17/01 - changes to allow case-sensitive names
Rem    rmurthy     12/01/00 - grant create library to xdb
Rem    esedlar     11/01/00 - Add SQL schema
Rem    njalali     10/03/00 - removed 'datatype' from resource table
Rem    esedlar     09/27/00 - Add schema in uniqueness constraints
Rem    njalali     09/26/00 - removed the 'with rowid' in XDB$RESOURCE.
Rem    tsingh      09/22/00 - added catxdbdt.sql
Rem    nmontoya    09/18/00 - Changing default tablespace for xdb schema.
Rem    esedlar     09/05/00 - Type cache
Rem    njalali     08/15/00 - changed H_LINK to XDB$H_LINK.
Rem    tsingh      06/30/00 - Fix tablespace code.
Rem    tsingh      06/28/00 - sys to system.
Rem    tsingh      06/20/00 - Resource tables.
Rem    mkrishna    06/29/00 - add dbmsxidx 
Rem    njalali     04/20/00 - Initial revision
Rem    njalali     01/00/00 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Set up error logging installing as part of UPGRADE

COLUMN :xdb_file NEW_VALUE xdbfile NOPRINT
VARIABLE xdb_file VARCHAR2(256);

DECLARE
  instance_mode  v$instance.status%TYPE;  -- status from v$instance
BEGIN
  SELECT status into instance_mode FROM v$instance;
  IF instance_mode = 'OPEN MIGRATE' THEN
    :xdb_file := dbms_registry_server.XDB_path || 'xdbupgrdses.sql';
  ELSE
    :xdb_file := dbms_registry.nothing_script;
  END IF;
END;
/

show errors

SELECT :xdb_file FROM SYS.DUAL;
@&xdbfile

prompt
prompt
prompt Starting Oracle XML DB Installation ...
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Enter Parameter #1 <XDB_PASSWD>, password for XDB schema:
define xdb_pass    = &1
prompt
prompt Enter Parameter #2 <TABLESPACE>, tablespace for XDB:
define res_tbs     = &2
prompt
prompt Enter Parameter #3 <TEMP_TABLESPACE>, temporary tablespace for XDB: 
define temp_tbs    = &3
prompt

variable user_opt_secfiles varchar2(30);
variable usesecfiles varchar2(3);
variable metadata_pkg_status varchar2(7);

/* use event 44715 to denote XDB initialization */
alter session set events '44715 trace name context forever';

/* bug 22733705 : set nls_length_semantics */
ALTER SESSION SET NLS_LENGTH_SEMANTICS = BYTE;

Rem  Determine if secure files will be used for xdb.xdb$resource
Rem
prompt Enter Parameter #4 <SECURE_FILES_REPO>, YES/NO
prompt ...................If YES
prompt ...................then XDB repository will be stored as secure files.
prompt ...................Otherwise, old LOBS are used
declare
begin
  :usesecfiles := 'NO';
  :user_opt_secfiles := '&4';

  -- if no option was passed, try using secure files
  if (nvl(:user_opt_secfiles,'YES') != 'NO') then
     :usesecfiles := 'YES';
  end if;

  exception
     when others then
        return;
end;
/
prompt
prompt


Rem get the status of sys.dbms_metadata
declare
begin
  select status into :metadata_pkg_status from dba_objects where owner = 'SYS' 
  and object_name ='DBMS_METADATA' and object_type = 'PACKAGE BODY';
--  dbms_output.put_line(:metadata_pkg_status);
end;
/

SET VERIFY OFF

Rem Check for pre-conditions
@@catxdbck &xdb_pass &res_tbs &temp_tbs :usesecfiles

Rem Create XDB User.
create user xdb identified by &xdb_pass account lock password expire 
       default tablespace &res_tbs temporary tablespace &temp_tbs;

Rem Invoke Registry. The package is defined later.
EXECUTE dbms_registry.loading('XDB', 'Oracle XML Database', 'DBMS_REGXDB.VALIDATEXDB', 'XDB');
Rem Set parent rowid''s for XDB$H_LINK. Used only by upgrade.

Rem should go away soon
Rem
Rem Bug #17476266, 14750963: IDENTIFIED BY VALUES must be valid.
Rem Arbitrary strings are not allowed in the IDENTIFIED BY VALUES clause.
Rem Attempting to create an account with "no password" by using 
Rem the IDENTIFIED BY VALUES clause is kind of a misuse, because normally
Rem the only available mechanism to prevent logon is for an account to be
Rem locked.  Blank verifiers are normally only allowed for COMMON users
Rem when user$ is queried from a PDB (see txn akruglik_bug-17070445 which
Rem introduced the concept of blank verifiers to prevent the administrator
Rem of a PDB from seeing the verifiers of any COMMON user), so here we use
Rem a blank verifier for the ANONYMOUS user even though it is not
Rem necessarily a COMMON user.
Rem
create user anonymous identified by values '                ' default tablespace &res_tbs;
EXECUTE dbms_registry.loading('XDB', 'Oracle XML Database', 'DBMS_REGXDB.VALIDATEXDB', 'XDB', dbms_registry.schema_list_t('ANONYMOUS'));
grant create session to anonymous;
alter user anonymous account lock;

SET VERIFY ON

Rem Revoke automatic grant of INHERIT PRIVILEGES from public.
declare
  already_revoked exception;
  pragma exception_init(already_revoked,-01927);
begin
  execute immediate 'revoke inherit privileges on user anonymous from public';
exception
  when already_revoked then
    null;
end;
/

grant resource , UNLIMITED TABLESPACE to xdb;
grant create session to xdb;
grant alter session to xdb;
GRANT execute ON dbms_rls TO xdb;
grant unlimited tablespace to xdb;
grant create library to xdb;
grant create public synonym to xdb;
grant drop public synonym to xdb;
grant set container to xdb;

Rem Grant INHERIT ANY PRIVILEGES to xdb to inherit privileges of callers of its
Rem invoker rights routines. Revoke automatic grant of INHERIT PRIVILEGES from
Rem public.
grant inherit any privileges to xdb;
grant inherit privileges on user sys to xdb;

declare
  already_revoked exception;
  pragma exception_init(already_revoked,-01927);
begin
  execute immediate 'revoke inherit privileges on user xdb from public';
exception
  when already_revoked then
    null;
end;
/

Rem If CTXSYS is already installed, grant it inherit privileges on XDB.
declare
  v varchar2(100);
begin
  select u.name into v from user$ u, registry$ r where u.user# = r.schema# and
        u.name = 'CTXSYS';
  execute immediate 'grant inherit privileges on user xdb to ctxsys';
exception when NO_DATA_FOUND then
    null;
end;
/

grant execute on dbms_streams_control_adm to xdb;

--Proj 32973: dbms_priv_capture APIs are used in xdb packages.
grant execute on dbms_priv_capture to xdb;

CREATE role xdbadmin;
GRANT xdbadmin TO dba;

-- Pseudo user that can be used in ACLs to refer to the resource owner
-- create user owner identified by values 'OWNER';

-- Needed for prvtxdbz
grant administer database trigger to xdb;

-- Needed for catxdbj
--GRANT javauserpriv TO xdb;

-- Needed by catxdbr and catxdbpi
grant create view to xdb;
grant query rewrite to xdb;
grant create operator to xdb;
grant create indextype to xdb;

-- Needed by prvtxdb
grant execute on dbms_pdb_exec_sql to xdb;

/* REF CASCADE IS DISSALLOWED FOR SCHEMA AND RESOURCE TABLES */

/* turn off the REF cascade semantics for resource$ */
alter session set events '22830 trace name context forever, level 4';

-- XDB$ROOT_INFO table
create table xdb.xdb$root_info 
(resource_root rowid,
 rclist raw(2000),
 ftp_port number(5),
 ftp_protocol varchar2(4000),
 http_port number(5),
 http_protocol varchar2(4000),
 http_host varchar2(4000),
 http2_port number(5),
 http2_protocol varchar2(4000),
 http2_host varchar2(4000),
 nfs_port number(5),
 nfs_protocol varchar2(4000),
 rhttp_port number(5),
 rhttp_protocol varchar2(4000),
 rhttp_host varchar2(4000),
 rhttps_port number(5),
 rhttps_protocol varchar2(4000),
 rhttps_host varchar2(4000)
);

-- XDB$XDB_READY table
create table xdb.xdb$xdb_ready
(data CLOB
);

-- xdb.xdb$cdbports
create table xdb.xdb$cdbports
(pdb     number,
 service number,
 port    number);

-- XDB.XDB$IMPORT_TT_INFO table
-- needed by prvtxdb
create table xdb.xdb$import_tt_info
(guid         raw(16), 
 nmspcid      raw(8),
 localname    varchar2(2000),
 flags        raw(4),
 id           raw(8));

grant select,insert,update,delete on xdb.xdb$import_tt_info to public;

-- XDB.XDB$TSETMAP table
-- needed by prvtxdb 
create table xdb.xdb$tsetmap(
 guid   raw(16) not null,
 type   number not null,
 obj#   number not null);

-- XDB.XDB$TTSET table
-- needed by prvtxdb
create table xdb.xdb$ttset
(guid     raw(16), 
 toksuf   varchar(26), 
 flags    number, 
 obj#     number unique);

-- XDB$RCLIST view
create view xdb.xdb$rclist_v as (select rclist from xdb.xdb$root_info);

-- This is needed for users to be able to query the repository's rclist
grant read on xdb.xdb$rclist_v to public;

-- XDB$H_INDEX table
-- Note: chidren column cannot be securefiles for now
variable param_secf varchar2(4000);
select value from v$parameter  where name='db_securefile';
begin 
 select value into :param_secf from v$parameter where UPPER(name)='DB_SECUREFILE'; 
end;
/
alter system set db_securefile='NEVER';

create table xdb.xdb$h_index 
  (
    oid raw(16), 
    acl_id raw(16), 
    owner_id raw(16),
    flags raw(4), 
    children BLOB
  ) 
  pctfree 99 pctused 1;

-- revert
declare
  s varchar2(4100);
begin
  s := 'alter system set db_securefile=''' || :param_secf || ''' ';
execute immediate s;
end;
/


CREATE INDEX xdb.xdb$h_index_oid_i ON xdb.xdb$h_index (OID);

create type xdb.xdb$link_t OID '00000000000000000000000000020151' AS OBJECT
(
    parent_oid    raw(16),
    child_oid     raw(16),
    name          varchar2(256),
    flags         raw(4),
    link_sn       raw(16),
    child_acloid  raw(16),
    child_ownerid raw(16),
    parent_rids   raw(2000)
);
/

create table xdb.xdb$h_link of xdb.xdb$link_t
(
    constraint xdb_pk_h_link primary key (parent_oid, name)
);

create index xdb.xdb_h_link_child_oid on xdb.xdb$h_link(child_oid);

-- create document links table
create table xdb.xdb$d_link 
(
  source_id    raw(16),
  target_id    raw(16),
  target_path  varchar2(4000),
  flags        raw(8)
);

create index xdb.xdb$d_link_source_id on xdb.xdb$d_link(source_id);

create index xdb.xdb$d_link_target_id on xdb.xdb$d_link(target_id);

------------------------------------------------------------------------------
create sequence xdb.stateid_restart_sequence
  increment by 1
  start with 1
  minvalue 1
  nocycle
/

create sequence xdb.clientid_sequence
  increment by 1
  start with 1
  minvalue 1
  cache 10
  nocycle
/

Rem Create XML schema related types and tables
@@catxdbs.sql

Rem Add XDB schema for schemas
@@catxdbdt.sql

Rem Create XML resource schema related types and tables
@@catxdbrs.sql :usesecfiles

Rem Add XDB schema for resources
@@catxdbdr.sql

/* turn off the ref cascade event */
alter session set events '22830 trace name context off';

Rem Add the schema registration/compilation module
@@dbmsxsch.sql

Rem Add the security module
@@dbmsxdbz.sql

@@dbmsxmlu.sql
@@dbmsxmls.sql
@@dbmsxmld.sql

@@dbmsxres.sql

Rem Add definition for various xdb utilities  
@@dbmsxdb.sql
@@dbmsxdbc.sql
@@dbmsxdbr.sql

Rem Add definition for various xdb administrative utilities
@@dbmsxdba.sql

Rem Add definition for repository rolling upgrade
@@dbmsxlsb.sql

Rem Add definition for xmlschema replication
@@dbmsxschlsb.sql

Rem Create Path Index
@@catxdbpi

-- Load the dbms_xdbutil_int specification
@@prvtxdb0.plb

-- Load the dbms_xdbz0 specification
@@prvtxdz0.plb

Rem Implementation of XDB Security modules
@@prvtxdbz.plb

REM ADD pl/sql dom, xml parser, AND xsl processor
@@dbmsxmlp.sql
@@dbmsxslp.sql
@@prvtxmlstreams.plb
@@prvtxslp.plb
@@prvtxmld.plb
@@prvtxmlp.plb

Rem Implementation of DBMS_XDBResource 
@@prvtxres.plb

Rem Implementation of XDB Utilities Package
@@prvtxdb.plb

Rem Implementation of XDB Admin Package
@@prvtxdba.plb

Rem Implementation of dbms_xlsb for repository rolling upgrade
@@prvtxlsb.plb

Rem Implementation of dbms_xschlsb 
@@prvtxschlsb.plb

Rem Definition and implementation of DBMS_JSON package
@@dbmsjson.sql
@@prvtjson.plb

Rem Create the Compact XML Token Manager tables
@@catxdbtm.sql

Rem Create tables for Application users and roles
@@catxdbapp.sql

Rem Implementation of schema registration/compilation module
@@prvtxsch0.plb
@@prvtxsch.plb

Rem Resource View
@@prvtxdr0.plb
@@catxdbr.sql 

Rem Resource view implementaion
@@prvtxdbr.plb

-- set xdk schema cache event
ALTER SESSION SET EVENTS='31150 trace name context forever, level 0x8000';

Rem add xdb_dltrig_pkg - pre-update trigger to invoke document link proc
@@prvtxdbdl.plb

Rem XDB Path Index Implementation
@@prvtxdbp.plb 

Rem Initialize bootstrap acl
@@catxdbz.sql 

Rem Initialize ResConfig 
@@catxev

Rem Initialize XDB standard packages (Configuration, Servlets, etc.)
@@catxdbst.sql

Rem Create the Versioning Package 
@@catxdbvr.sql

Rem Create Path View
@@catxdbpv

Rem Initialize document links support
@@catxdbdl.sql

Rem Create helper package for xml index
@@dbmsxidx
Rem Load body of xmlindex helper package (dbms_xmlindex)
@@prvtxidx.plb

Rem Create the XMLIndex
@@catxidx

Rem Create the Structured XMLIndex tables
@@catxtbix

Rem Initialize extensible optimizer
@@catxdbeo.sql


Rem create roles
Rem these roles were in catxdbc1

-- create the "virtual" authenticated user role we use in servlets
create role authenticatedUser;
-- create role for web services. Must be granted to users for web services use
create role XDB_WEBSERVICES;
-- grant XDB_WEBSERVICES to xdb;
create role XDB_WEBSERVICES_WITH_PUBLIC;
create role XDB_WEBSERVICES_OVER_HTTP;

Rem Initialize XDB configuration management
@@catxdbc1
@@catxdbc2

Rem Setup XDB Digest Authentication
@@xdbinstd.sql

Rem Add the various views to be created on xdb data
@@catxdbv

-- Script invocations no longer in catxdbv
Rem ALL_OBJECTS depends on xml_schema_name_present. Recreate the package 
Rem body, nothing will get invalidated
Rem Bug 8368788: wrap xml_schema_name_present
@@prvtxschnpb.plb
rem create xdb manageability view
@@catvxutil.sql
rem create metadata API views
@@catmetx.sql
-- End of script invocations no longer in catxdbv

Rem Create the DBMS_RESCONFIG package
@@dbmsxrc
@@prvtxrc.plb

Rem Create the DBMS_XEVENT package
@@dbmsxev
@@prvtxev.plb

Rem Create the dbms_xmltranslations package
@@dbmsxtr
@@prvtxtr.plb

-- XDB$REPOS table
CREATE TABLE XDB.XDB$REPOS
(
   obj#         NUMBER NOT NULL,
   flags        NUMBER,
   rootinfo#    NUMBER,
   hindex#      NUMBER,
   hlink#       NUMBER,
   resource#    NUMBER,
   acl#         NUMBER,
   config#      NUMBER,
   dlink#       NUMBER,
   nlocks#      NUMBER,
   stats#       NUMBER,
   checkouts#   NUMBER,
   resconfig#   NUMBER,
   wkspc#       NUMBER,
   vershist#    NUMBER,
   params       XMLType
);

-- XDB$MOUNTS table
CREATE TABLE XDB.XDB$MOUNTS
(
   dobj#        NUMBER,
   dpath        VARCHAR2(4000),
   sobj#        NUMBER,
   spath        VARCHAR2(4000),
   flags        NUMBER
);

Rem Create the DBMS_XDBREPOS package
@@dbmsxdbrepos
@@prvtxdbrepos.plb

Rem Create helper package for text index on xdb resource data
COLUMN xdb_name NEW_VALUE xdb_file NOPRINT;
SELECT dbms_registry.script('CONTEXT','@dbmsxdbt.sql') AS xdb_name FROM DUAL;
@&xdb_file

Rem install the JSON PL/SQL Collection API 
@@catsodacoll.sql

Rem Create a schedule for cleanup of expired nfs clients job
Rem Disabling the job for 11gR1. It needs to be reenabled 
Rem explicitly by customers, or enabled automatically by NFS
Rem server in 11gR2.
Rem dbms_scheduler.enable('nfsclient_cleanup_job');

DECLARE
  c number;
BEGIN  
  select count(*) into c
  from ALL_SCHEDULER_JOB_CLASSES
  where JOB_CLASS_NAME = 'XMLDB_NFS_JOBCLASS';

  if c = 0 then
    dbms_scheduler.create_job_class(
      job_class_name  => 'SYS.XMLDB_NFS_JOBCLASS',
      logging_level   => DBMS_SCHEDULER.LOGGING_FAILED_RUNS);
  end if;

  select count(*) into c
  from ALL_SCHEDULER_JOBS
  where JOB_NAME = 'XMLDB_NFS_CLEANUP_JOB';

  if c = 0 then
    dbms_scheduler.create_job(
        job_name => 'SYS.XMLDB_NFS_CLEANUP_JOB' ,
        job_type=>'STORED_PROCEDURE',  
        job_action=>'xdb.dbms_xdbutil_int.cleanup_expired_nfsclients',
        job_class=>'SYS.XMLDB_NFS_JOBCLASS',
        repeat_interval=>'Freq=minutely;interval=5');
  end if;
  execute immediate 'delete from noexp$ where name = :1' using 'XMLDB_NFS_JOBCLASS';
  execute immediate 'insert into noexp$ (owner, name, obj_type) values(:1, :2, :3)' using 'SYS', 'XMLDB_NFS_JOBCLASS', '68';
end;   
/

Rem Create the registry package and the validation procedure
@@dbmsxreg

grant execute on dbms_registry to xdb;

@@prvtxreg.plb

Rem Create xdb manageability tools
@@catremxutil.sql
@@dbmsxutil.sql
@@prvtxutil.plb

Rem Include dbfs content api client for FTP, HTTP access of DBFS
@@prvtxsfsclient.plb

revoke administer database trigger from xdb;

Rem recompile dbms_metadata package body if it becomes invalid
DECLARE
  pkg_status varchar2(7);
BEGIN
  select status into pkg_status from dba_objects where owner = 'SYS'
  and object_name ='DBMS_METADATA' and object_type = 'PACKAGE BODY';

  IF (pkg_status = 'INVALID' and :metadata_pkg_status = 'VALID') THEN 
    execute immediate 'ALTER PACKAGE SYS.DBMS_METADATA COMPILE BODY';
  END IF;
END;
/

Rem drop objects created to track object creation during XDB
Rem installation
drop table dropped_xdb_instll_tab;
drop package xdb.xdb$bootstrap;
drop package xdb.xdb$bootstrapres;
drop function xdb.xdb$getPickledNS;

commit;

-- Explicit grants to DBA,System; "any" privileges are no more applicable for 
-- XDB tables. Listing these specifically since there are certain tables
-- for which we dont grant full access by default even to DBA & System.
-- (eg, purely-dictionary tables like XDB$SCHEMA, XDB$TTSET etc.)
-- Specify privileges granted.  bug 22646079
grant select,insert,update,delete on XDB.XDB$RESOURCE to dba;
grant select,insert,update,delete on XDB.XDB$RESOURCE to system
        with grant option;
grant select,insert,update,delete on XDB.XDB$H_INDEX to dba;
grant select,insert,update,delete on XDB.XDB$H_INDEX to system
        with grant option;
grant select,insert,update,delete on XDB.XDB$H_LINK to dba;
grant select,insert,update,delete on XDB.XDB$H_LINK to system with grant option;
grant select,insert,update,delete on XDB.XDB$D_LINK to dba;
grant select,insert,update,delete on XDB.XDB$D_LINK to system with grant option;
grant select,insert,update,delete on XDB.XDB$NLOCKS to dba;
grant select,insert,update,delete on XDB.XDB$NLOCKS to system with grant option;
grant select,insert,update,delete on XDB.XDB$CHECKOUTS to dba;
grant select,insert,update,delete on XDB.XDB$CHECKOUTS to system
        with grant option;
grant select,insert,update,delete on XDB.XDB$ACL to dba;
grant select,insert,update,delete on XDB.XDB$ACL to system with grant option;
grant select,insert,update,delete on XDB.XDB$CONFIG to dba;
grant select,insert,update,delete on XDB.XDB$CONFIG to system with grant option;
grant select,insert,update,delete on XDB.XDB$RESCONFIG to dba;
grant select,insert,update,delete on XDB.XDB$RESCONFIG to system
        with grant option;

declare
  suf  varchar2(26);
  stmt varchar2(2000);
begin
  select toksuf into suf from xdb.xdb$ttset where flags = 0;
  stmt := 'grant select,insert,update,delete on XDB.X$PT' || suf || ' to DBA';
  execute immediate stmt;
  stmt := 'grant select,insert,update,delete on XDB.X$PT' || suf || ' to SYSTEM WITH GRANT OPTION';
  execute immediate stmt;
end;
/

Rem Data Pump has the new requirement that users granted 
Rem DATAPUMP_FULL_EXP_DATABASE be able to export in FULL mode
Rem tables in the XDB schema. The advise is actually to grant
Rem SELECT on XDB tables to the SELECT_CATALOG_ROLE, which in 
Rem turn is granted to DATAPUMP_FULL_EXP_DATABASE, to be in sync
Rem with other components to be supported by FULL export.
Rem Some XDB tables are actually allowing PUBLIC access, so this
Rem grant will be a noop for them, but some do not. 
Rem If other XDB scripts are run beyond this point (outside of catqm.sql),
Rem it is the responsability of the script developer to allow similar
Rem grants on any XDB-owned tables that may get created in the script.
Rem
prompt Granting SELECT on XDB tables to SELECT_CATALOG_ROLE
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set serveroutput on
/*tname can't have dbms_id or dbms_quoted_id since it requires to hold more */
/*than just an identifier*/
declare
  type    cur_type is ref cursor;
  cur     cur_type;
  tname   varchar2(134);
  stmt    varchar2(2000);
begin
  open cur for 'select table_name from dba_tables where owner=:1 union ' ||
               'select table_name from dba_object_tables where owner=:2 ' 
    using 'XDB', 'XDB';
  loop
    fetch cur into tname;
    exit when cur%NOTFOUND;

    tname := 'XDB."' ||    tname || '"';
    stmt := 'grant select on ' || tname || ' to SELECT_CATALOG_ROLE';
    begin
       execute immediate stmt;
       exception
          when OTHERS then
             if ((SQLCODE != -22812) and (SQLCODE != -30967)) then
               dbms_output.put_line(stmt);
               dbms_output.put_line(SQLERRM);
             end if;
    end;
  end loop;
end;
/

set serveroutput off

/* reset event 44715 to indicate XDB initialization complete */
alter session set events '44715 trace name context off';

prompt
prompt
prompt Triggering Extensible Security (XS) Installation ...
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Always keep this at the end. XS
Rem Initialize bootstrap extensible security
@@catzxs.sql

-- Add XS$NULL to XDB schema list
BEGIN
   dbms_registry.update_schema_list('XDB',
     dbms_registry.schema_list_t('ANONYMOUS', 'XS$NULL'));
END;
/

prompt Extensible Security (XS) Installation completed
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt

prompt Installing RDBMS Features dependent on XDB
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@@catxrd.sql

prompt RDBMS Feature Installation completed
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Rem Indicate that xdb has been Loaded
Rem Bug 26255427 use default versions and banner
begin
  sys.dbms_registry.loaded('XDB');
end;
/

set serveroutput on
set long 10000

Rem at catqm.sql, Invoke Validation for registry.
execute sys.dbms_regxdb.validatexdb;

/* bug#23085530, re-gather stats for XDB$ELEMENT                      */
/* so patchupschema during deleteschema could pick up the right plan  */
BEGIN
 dbms_stats.gather_table_stats('xdb', 'xdb$element');
 EXCEPTION WHEN OTHERS THEN NULL;
END;
/

set serveroutput off
set long 80

prompt XML DB Installation completed
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


@?/rdbms/admin/sqlsessend.sql
