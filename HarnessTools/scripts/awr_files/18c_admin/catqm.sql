Rem
Rem $Header: rdbms/admin/catqm.sql /main/110 2014/02/20 12:46:25 surman Exp $
Rem
Rem catqm.sql
Rem
Rem Copyright (c) 1900, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catqm.sql - CAtalog script for sQl xMl management 
Rem
Rem    DESCRIPTION
Rem      Creates the tables and views needed to run the XDB system 
Rem      Run this script like this:
Rem        catqm.sql <XDB_PASSWD> <TABLESPACE> <TEMP_TABLESPACE> <SECURE_FILES_REPO>
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
Rem SQL_SOURCE_FILE: rdbms/admin/catqm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catqm.sql
Rem SQL_PHASE: CATQM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpend.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         03/20/13 - Common start and end scripts
Rem    thbaby      09/08/11 - remove indexes on xdb.xdb$acl
Rem    hxzhang     09/19/11 - move code to catqm_int.sql
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

prompt
prompt
prompt Starting Oracle XML DB Installation ...
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Enter Parameter #1 <XDB_PASSWD>, password for XDB schema:
prompt
prompt Enter Parameter #2 <TABLESPACE>, tablespace for XDB:
prompt
prompt Enter Parameter #3 <TEMP_TABLESPACE>, temporary tablespace for XDB:
prompt

variable xdb_pass varchar2(128);
variable res_tbs varchar2(128);
variable temp_tbs varchar2(128); 
variable user_opt_secfiles varchar2(30);
variable usesecfiles varchar2(3);

/* use event 44715 to denote XDB initialization */
alter session set events '44715 trace name context forever';

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
 
Rem
Rem Invoke catqm.sql to install XDB during installs only.
Rem
VARIABLE dbinst_name VARCHAR2(256)
COLUMN :dbinst_name NEW_VALUE dbinst_file NOPRINT

DECLARE
BEGIN
  :xdb_pass := '&1';
  :res_tbs := '&2';
  :temp_tbs := '&3';
  IF (dbms_registry.is_loaded('XDB') IS NULL) THEN
     :dbinst_name := dbms_registry_server.XDB_path ||
                     'catqm_int.sql ' || :xdb_pass || ' ' || :res_tbs || ' ' || :temp_tbs || ' ' || :usesecfiles;
  ELSE
     :dbinst_name := dbms_registry.script('CONTEXT','@dbmsxdbt.sql');
  END IF;
END;
/
SELECT :dbinst_name FROM DUAL;
@&dbinst_file

@?/rdbms/admin/sqlsessend.sql
