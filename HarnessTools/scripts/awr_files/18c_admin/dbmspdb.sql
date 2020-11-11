Rem
Rem
Rem dbmspdb.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmspdb.sql - dbms_pdb utility package
Rem
Rem    DESCRIPTION
Rem      This package containes procedures to examine and manipulate data
Rem      about pluggable databases
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmspdb.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmspdb.sql
Rem SQL_PHASE: DBMSPDB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: ORA-65209
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    luisgarc    11/28/17 - Bug 26650540: Add sig_mismatch argument to
Rem                           convert_to_local
Rem    pjulsaks    09/14/17 - Bug 26320209: add fatal_only to check_plug
Rem    prshanth    09/02/17 - Bug 25988806: add function check_lockdown
Rem    tianlli     08/28/17 - Bug 16192980: add clear_plugin_violations
Rem    tianlli     06/30/17 - Bug 26192553: add set_sharing_none
Rem    tianlli     06/21/17 - Bug 26242432: remove remove_link
Rem    pjulsaks    03/07/17 - Bug 25216265: add function is_valid_path
Rem    siyzhang    01/03/17 - Bug 25337345: add ORA-65209 to 
Rem                           SQL_IGNORABLE_ERRORS
Rem    pyam        08/08/16 - RTI 19634111: add convert_to_local
Rem    thbaby      05/10/16 - Bug 23254735: add SET_USER_EXPLICIT()
Rem    jmuller     10/01/15 - Fix bug 20559930: reimplement GETLONG()
Rem    jaeblee     03/10/16 - 22865673: make dbms_pdb_exec_sql invokers rights
Rem    akruglik    01/12/16 - (22132084): rename dbms_pdb.set_object_linked to
Rem                           set_data_linked
Rem    thbaby      11/19/15 - Bug 22242562: pass edition to set_metadata_linked
Rem    dgagne      09/03/15 - add support for application database - proj 47234
Rem    prshanth    04/22/15 - Bug 20823920: create default lockdown profiles
Rem    molagapp    01/24/15 - Add dbms_pdb.exportRmanBackup
Rem    gravipat    09/26/14 - Add dbms_pdb.check_nft
Rem    thbaby      09/09/14 - Proj 47234: add set_metadata_linked
Rem    pyam        05/09/14 - populate pdb_sync$ on 12.1.0.1->x upgrade
Rem    thbaby      02/13/14 - 18248970: permanent table create/drop callouts
Rem    thbaby      02/11/14 - 18190755: add update_datalink_stats
Rem    thbaby      02/11/14 - 18190755: add update_comdata_stats
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    thbaby      12/24/13 - 17987966: add createX$PermanentTables
Rem    pyam        12/10/13 - 17709180: add public synonym dbms_pdb
Rem    sankejai    11/25/13 - 17807546: added dbms_pdb_lib library
Rem    cxie        10/02/13 - add dbms_pdb.update_version
Rem    sankejai    04/01/13 - 16530655: add dbms_pdb.noncdb_to_pdb
Rem    thbaby      02/08/13 - add dbms_pdb.update_cdbvw_stats
Rem    thbaby      01/28/13 - XbranchMerge thbaby_bug_15827913_ph7 from
Rem                           st_rdbms_12.1.0.1
Rem    thbaby      01/22/13 - XbranchMerge thbaby_bug_15827913_ph4 from
Rem                           st_rdbms_12.1.0.1
Rem    thbaby      01/21/13 - lrg 8818133: sql injection in getlong
Rem    thbaby      01/16/13 - 15827913: add function getlong
Rem    gravipat    01/02/13 - 16040080: change sigature of dbms_pdb.recover
Rem    cxie        11/19/12 - change check_plug_compatibility to take pdb_name
Rem    cxie        09/20/12 - add procedure DBMS_PDB.RECOVER
Rem    thbaby      04/24/12 - add routine to perform smon task
Rem    gravipat    01/09/12 - 12991119: Add procedure check_plug_compatibility
Rem    sursridh    12/05/11 - bug 13425408: add exec_as_oracle_script.
Rem    gravipat    01/26/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


create or replace package dbms_pdb authid current_user is

  ------------------------------------------------
  --  CONSTANTS for check_lockdown function(START)
  ------------------------------------------------

  -- Rule Type (kpdbRuleTyp)
  V_STATEMENT constant NUMBER := 1;
  V_OPTION    constant NUMBER := 2;
  V_FEATURE   constant NUMBER := 3;

  -- Rule Id
  -- Statement octcode
  V_ALTER_SYSTEM  constant NUMBER := 49;
  V_ALTER_SESSION constant NUMBER := 42;

  -- Rule Id
  -- Feature Id
  V_FEAT_INV                            constant NUMBER := 0;
  V_FEAT_ALL                            constant NUMBER := 1;
  V_FEAT_NETWORK_ACCESS                 constant NUMBER := 2;
  V_FEAT_COMMON_SCHEMA_ACCESS           constant NUMBER := 3;
  V_FEAT_TCP                            constant NUMBER := 4;
  V_FEAT_HTTP                           constant NUMBER := 5;
  V_FEAT_SMTP                           constant NUMBER := 6;
  V_FEAT_INADDR                         constant NUMBER := 7;
  V_FEAT_JDWP                           constant NUMBER := 8;
  V_FEAT_XDB_PROTOCOLS                  constant NUMBER := 9;
  V_FEAT_JAVA                           constant NUMBER := 10;
  V_FEAT_CTX_PROTOCOLS                  constant NUMBER := 11;
  V_FEAT_OS_ACCESS                      constant NUMBER := 12;
  V_FEAT_FILE                           constant NUMBER := 13;
  V_FEAT_EXTPROC                        constant NUMBER := 14;
  V_FEAT_JAVA_OS_ACCESS                 constant NUMBER := 15;
  V_FEAT_JAVA_RUNTIME                   constant NUMBER := 16;
  V_FEAT_TRACE_VIEWS                    constant NUMBER := 17;
  V_FEAT_AQ_PROTOCOLS                   constant NUMBER := 18;
  V_FEAT_EXT_GBL_AUTH                   constant NUMBER := 19;
  V_FEAT_SECURITY_POLICIES              constant NUMBER := 20;
  V_FEAT_CONNECTIONS                    constant NUMBER := 21;
  V_FEAT_LOCSYSOPERRESMOD               constant NUMBER := 22;
  V_FEAT_COMUSERCONN                    constant NUMBER := 23;
  V_FEAT_AWR_ACCESS                     constant NUMBER := 24;
  V_FEAT_LUSER_CSCHEMA_ACCESS           constant NUMBER := 25;
  V_FEAT_CUSER_LSCHEMA_ACCESS           constant NUMBER := 26;
  V_FEAT_DROP_TS_KEEP_DATAFILES         constant NUMBER := 27;
  V_FEAT_EXT_FILE_ACCESS                constant NUMBER := 28;
  V_FEAT_CTX_LOGGING                    constant NUMBER := 29;
  V_FEAT_LOB_FILE                       constant NUMBER := 30;
  V_FEAT_ADR_ACCESS                     constant NUMBER := 31;
  V_FEAT_FILE_TRANSFER                  constant NUMBER := 32;
  V_FEAT_XDB_DEPRECATED                 constant NUMBER := 33;
  V_FEAT_SYSDATA                        constant NUMBER := 34;
  V_FEAT_MAX                            constant NUMBER := 35;
  
  ------------------------------------------------
  --  CONSTANTS for check_lockdown function(END)
  ------------------------------------------------

  --  PROCEDURES AND FUNCTIONS
  --
  procedure describe(pdb_descr_file varchar2,
                     pdb_name varchar2 DEFAULT NULL);
  -- Generate an XML which describes the various tablespaces and the datafiles
  -- that belong to the pluggable database
  --  Input arguments:
  --    pdb_descr_file - path of the XML file which will contain description
  --                     of a Pluggable Database.
  --    pdb_name - name of a Pluggable Database to be described. If pdb_name
  --               is omitted, the Pluggable Database to which the session
  --               is connected will be described. If pdb_name is omitted,
  --               and the session is connected to the Root, an error will
  --               be returned.

  function check_plug_compatibility(pdb_descr_file IN varchar2,
                                    pdb_name IN varchar2 DEFAULT NULL,
                                    fatal_only IN boolean DEFAULT FALSE)
           return boolean;
  -- Determine whether a pluggable database described by file pdb_descr_file
  -- is compatibile with the current cdb
  --  Input arguments:
  --    pdb_descr_file - path of the XML file which will contain description
  --                     of a Pluggable Database.
  --    pdb_name       - name of the Pluggable Database to be used for the
  --                     check. If pdb_name is omitted, PDB name in the
  --                     XML file will be used. 
  --    fatal_only     - If this is TRUE, then this function will return false
  --                     only if Pluggable Database cannot be fixed after 
  --                     plugging in. 

  procedure exec_as_oracle_script(sql_stmt varchar2);
  -- NAME: 
  --   exec_as_oracle_script - execute a statement as oracle script
  --
  -- DESCRIPTION:
  --   This procedure enables execution of certain restricted statements
  --   (most DDLs) on metadata-linked objects, from within a pdb.  This is
  --   accomplished by running the statement as an oracle script (i.e. with
  --   the parameter _oracle_script set to TRUE).  This is for use by Oracle
  --   internal packages only.
  --
  -- PARAMETERS:
  --   sql_stmt (IN) - sql statement to execute
  --
  -- NOTE
  --   ************************************************************************
  --   ************************************************************************
  --   IMPORTANT, PLEASE READ!
  --   This procedure is not meant to be documented.  It is supplied for use by
  --   Oracle internal packages only to bypass some restrictions for pluggable
  --   databases.  Please talk to the package owners to determine if it is
  --   appropriate to use this procedure in your particular usage scenario.
  --   ************************************************************************
  --   ************************************************************************

  --   The following routine is related to operations done in SMON 
  --   until 11.2. But, with the introduction of PDBs in 12c and with 
  --   the possibility of having multiple PDBs in a single
  --   CDB, we want to move this cleanup out of SMON so that SMON is not 
  --   overloaded with work that can be done in some other background process. 
  --   The goal is to move everything except transaction recovery out of SMON. 

  function cleanup_task(task_id number)
    return number;

  -- NAME:
  -- cleanup_task - cleanup task previously done in SMON
  --
  -- DESCRIPTION:
  --   This procedure performs cleanup task previously done in SMON
  --
  -- PARAMETERS:
  -- task_id  - Task Id
  -- 
  -- RETURNS:
  -- 0 - if the next scheduled time for job does not need to be changed.
  -- N - if the next scheduled time for job should be N seconds from now
  -- 
  -- NOTE
  --   ************************************************************************
  --   ************************************************************************
  --   IMPORTANT, PLEASE READ!
  --   This procedure is not meant to be documented.  It is supplied for use by
  --   Oracle internal scripts only. Please talk to the package owners to 
  --   determine if it is appropriate to use this procedure in your particular 
  --   usage scenario.
  --   ************************************************************************

  procedure sync_pdb;
  -- NAME:
  -- sync_pdb - sync PDB with CDB
  --
  -- DESCRIPTION:
  --   After plug, syncs the PDB with the CDB, so that it will be ready for use.
  --   ************************************************************************

  procedure recover(pdb_descr_file varchar2, pdb_name varchar2, filenames varchar2);
  -- Recover the PDB XML file from datafile headers
  --  Input arguments:
  --    pdb_descr_file - path of the XML file which will contain description
  --                     of a Pluggable Database.
  --    pdb_name - pluggable database name to use in the XML file
  --    filenames - full path of the datafile belongs to the PDB. If there are
  --                multiple datafiles, a comma (ie ',') seperator should be
  --                inserted between two datafile paths.
  --   ************************************************************************

  function update_cdbvw_stats
    return number;

  -- NAME:
  -- update_cdbvw_stats - update CDB View Stats
  --
  -- DESCRIPTION:
  --   This procedure updates CDB View Stats
  --
  -- PARAMETERS:
  -- 
  -- RETURNS:
  -- 0 - if the next scheduled time for job does not need to be changed.
  -- N - if the next scheduled time for job should be N seconds from now
  -- 
  -- NOTE
  --   ************************************************************************
  --   ************************************************************************
  --   IMPORTANT, PLEASE READ!
  --   This procedure is not meant to be documented.  It is supplied for use by
  --   Oracle internal scripts only. Please talk to the package owners to 
  --   determine if it is appropriate to use this procedure in your particular 
  --   usage scenario.
  --   ************************************************************************

  procedure noncdb_to_pdb(phase number);

  -- NAME: 
  --   noncdb_to_pdb - Helper procedure for noncdb_to_pdb.sql
  --
  -- DESCRIPTION:
  --   This procedure is internally used by noncdb_to_pdb.sql
  --
  -- PARAMETERS:
  --   phase  (IN)  - phase of script
  --

  procedure update_version;
  -- NAME:
  -- update_version - update PDB's VSN
  --
  -- DESCRIPTION:
  --   update PDB's VSN in container$ after upgrade.
  --
  -- NOTE
  --   ************************************************************************
  --   ************************************************************************
  --   IMPORTANT, PLEASE READ!
  --   This procedure is not meant to be documented.  It is supplied for use by
  --   Oracle internal scripts only. Please talk to the package owners to 
  --   determine if it is appropriate to use this procedure in your particular 
  --   usage scenario.
  --   ************************************************************************
  --   ************************************************************************

  function update_comdata_stats
    return number;

  -- NAME:
  -- update_comdata_stats - update Stats for Common Data Views
  --
  -- DESCRIPTION:
  --   This procedure updates Common Data View stats. 
  --
  -- PARAMETERS:
  -- 
  -- RETURNS:
  -- 0 - if the next scheduled time for job does not need to be changed.
  -- N - if the next scheduled time for job should be N seconds from now
  -- 
  -- NOTE
  --   ************************************************************************
  --   ************************************************************************
  --   IMPORTANT, PLEASE READ!
  --   This procedure is not meant to be documented.  It is supplied for use by
  --   Oracle internal scripts only. Please talk to the package owners to 
  --   determine if it is appropriate to use this procedure in your particular 
  --   usage scenario.
  --   ************************************************************************

  function update_datalink_stats
    return number;

  -- NAME:
  -- update_datalink_stats - update Stats for Data Linked Views
  --
  -- DESCRIPTION:
  --   This procedure updates Data Linked View stats. It needs to be invoked 
  --   only in ROOT. If invoked in PDB, this procedure is a NO-OP.
  --
  -- PARAMETERS:
  -- 
  -- RETURNS:
  -- 0 - if the next scheduled time for job does not need to be changed.
  -- N - if the next scheduled time for job should be N seconds from now
  -- 
  -- NOTE
  --   ************************************************************************
  --   ************************************************************************
  --   IMPORTANT, PLEASE READ!
  --   This procedure is not meant to be documented.  It is supplied for use by
  --   Oracle internal scripts only. Please talk to the package owners to 
  --   determine if it is appropriate to use this procedure in your particular 
  --   usage scenario.
  --   ************************************************************************

  -- DESCRIPTION:
  --   This procedure should be called to create Permanent Tables corresponding
  --   to controlfile related Fixed Tables. It should be invoked in ROOT.
  -- NOTE
  --   ************************************************************************
  --   ************************************************************************
  --   IMPORTANT, PLEASE READ!
  --   This procedure is not meant to be documented.  It is supplied for use by
  --   Oracle internal scripts only. Please talk to the package owners to 
  --   determine if it is appropriate to use this procedure in your particular 
  --   usage scenario.
  --   ************************************************************************
  --   ************************************************************************
  --   ************************************************************************
  procedure createX$PermanentTables;

  -- DESCRIPTION:
  --   This procedure should be called to drop Permanent Tables corresponding
  --   to controlfile related Fixed Tables. It should be invoked in ROOT.
  -- NOTE
  --   ************************************************************************
  --   ************************************************************************
  --   IMPORTANT, PLEASE READ!
  --   This procedure is not meant to be documented.  It is supplied for use by
  --   Oracle internal scripts only. Please talk to the package owners to 
  --   determine if it is appropriate to use this procedure in your particular 
  --   usage scenario.
  --   ************************************************************************
  --   ************************************************************************
  --   ************************************************************************
  procedure dropX$PermanentTables;

  procedure populateSyncTable;
  -- NAME:
  -- populateSyncTable - populates pdbsync$ on upgrade from 12.1.0.1
  --
  -- DESCRIPTION:
  --   when upgrading from 12.1.0.1
  --
  -- NOTE
  --   ************************************************************************
  --   ************************************************************************
  --   IMPORTANT, PLEASE READ!
  --   This procedure is not meant to be documented.  It is supplied for use by
  --   Oracle internal scripts only. Please talk to the package owners to 
  --   determine if it is appropriate to use this procedure in your particular 
  --   usage scenario.
  --   ************************************************************************
  --   ************************************************************************
   
  procedure set_metadata_linked(schema_name  IN varchar2, 
                                object_name  IN varchar2,
                                namespace    IN number,
                                edition_name IN varchar2 DEFAULT NULL);

  -- This procedure should be used to mark an object as Metadata linked in 
  -- an App Root. It is intended to be used in migration cases where an 
  -- application was already installed in a PDB or a non-CDB, where there was 
  -- no support for application containers.

  procedure set_data_linked(schema_name  IN varchar2, 
                            object_name  IN varchar2,
                            namespace    IN number,
                            edition_name IN varchar2 DEFAULT NULL);
  -- This procedure should be used to mark an object as Data linked in 
  -- an App Root. It is intended to be used in migration cases where an 
  -- application was already installed in a PDB or a non-CDB, where there was 
  -- no support for application containers.

  procedure set_ext_data_linked(schema_name  IN varchar2, 
                                object_name  IN varchar2,
                                namespace    IN number,
                                edition_name IN varchar2 DEFAULT NULL);
  -- This procedure should be used to mark an object as Extended Data linked 
  -- in an App Root. It is intended to be used in migration cases where an 
  -- application was already installed in a PDB or a non-CDB, where there was 
  -- no support for application containers.

  procedure set_sharing_none(schema_name  IN varchar2, 
                             object_name  IN varchar2,
                             namespace    IN number,
                             edition_name IN varchar2 DEFAULT NULL);
  -- This procedure should be used to set sharing=none status on an 
  -- object in an App Root. It is intended to be used in migration 
  -- cases where an application was already installed in a PDB or a 
  -- non-CDB, where there was no support for application containers.

  procedure set_user_explicit(user_name IN varchar2);
  -- This procedure should be used to mark a user as an explicit 
  -- Application Common user. It is intended to be used in migration 
  -- cases where an application was already installed in a PDB or a 
  -- non-CDB, where there was no support for application containers.
  -- When such a PDB or non-CDB is converted into an Application Root
  -- via clone or plugin, the users would have been marked as implicit 
  -- Application Common users. This procedure should be invoked within
  -- an Application Begin/End block.

  procedure set_role_explicit(role_name IN varchar2);
  -- This procedure should be used to mark a role as an explicit 
  -- Application Common role. It is intended to be used in migration 
  -- cases where an application was already installed in a PDB or a 
  -- non-CDB, where there was no support for application containers.
  -- When such a PDB or non-CDB is converted into an Application Root
  -- via clone or plugin, the roles would have been marked as implicit 
  -- Application Common roles. This procedure should be invoked within
  -- an Application Begin/End block.

  procedure set_profile_explicit(profile_name IN varchar2);
  -- This procedure should be used to mark a profile as an explicit 
  -- Application Common profile. It is intended to be used in migration 
  -- cases where an application was already installed in a PDB or a 
  -- non-CDB, where there was no support for application containers.
  -- When such a PDB or non-CDB is converted into an Application Root
  -- via clone or plugin, the profiles would have been marked as implicit 
  -- Application Common profiles. This procedure should be invoked within
  -- an Application Begin/End block.

  procedure check_nft;
  -- NAME:
  -- check_nft - check for nofile tablespaces
  --
  -- DESCRIPTION:
  --   check and warn if pdb has nofile tablespaces.
  --
  -- NOTE
  --   ************************************************************************
  --   ************************************************************************
  --   IMPORTANT, PLEASE READ!
  --   This procedure is not meant to be documented.  It is supplied for use by
  --   Oracle internal scripts only. Please talk to the package owners to 
  --   determine if it is appropriate to use this procedure in your particular 
  --   usage scenario.
  --   ************************************************************************
  --   ************************************************************************

  procedure exportRmanBackup(pdb_name IN varchar2 DEFAULT NULL);
  --
  -- NAME: exportRmanBackup
  --
  -- DESCRIPTION:
  --    Export RMAN backup information that belong to the pluggable database
  --    to its dictionary before unplug so that pre-plugin backups can be
  --    used. The pluggable database has to be opened in read write mode. 
  --    If the database is non-cdb, then pdb_name must be omitted.
  --    If the pdb_name is omitted, then the pluggable database to which the
  --    session is connected will be exported. If the pdb_name is omitted,
  --    and the session is connected to the Root, an error will be returned.
  --
  -- INPUT ARGUMENTS:
  --    pdb_name - name of a Pluggable Database whose backup information
  --               needs to be exported. Omitted if connected to pluggable
  --               database or a non-cdb.
  --

-- Note - uncomment out when replay support for Data Pump is ready
--  procedure instance_callout_imp(obj_name    IN     VARCHAR2,
--                                 obj_schema  IN     VARCHAR2,
--                                 obj_type    IN     NUMBER,
--                                 prepost     IN     PLS_INTEGER,
--                                 action      OUT    VARCHAR2,
--                                 alt_name    OUT    VARCHAR2);
  --
  -- NAME: instance_callout_imp
  --
  -- DESCRIPTION:
  --    Data Pump import callout routine to replay application roots.
  --
  -- INPUT ARGUMENTS:
  --    obj_name   - name of object to be imported
  --    obj_schema - schema of object to be imported
  --    obj_type   - type of object to be imported.
  --    prepost    - pre callout or post callout
  --
  -- OUTPUT ARGUMENTS:
  --    action     - what to do with object
  --    alt_name   - alternate name to create object with.

  procedure convert_to_local(schema_name    IN varchar2, 
                             object_name    IN varchar2,
                             namespace      IN number,
                             object_subname IN varchar2 DEFAULT NULL,
                             sig_mismatch   IN boolean DEFAULT FALSE);
  -- NAME:
  -- convert_to_local - convert a common object to local object
  --
  -- DESCRIPTION:
  --   convert common to local object
  --
  -- NOTE
  --   ************************************************************************
  --   ************************************************************************
  --   IMPORTANT, PLEASE READ!
  --   This procedure is not meant to be documented.  It is supplied for use by
  --   Oracle internal scripts only. Please talk to the package owners to 
  --   determine if it is appropriate to use this procedure in your particular 
  --   usage scenario.
  --   ************************************************************************
  --   ************************************************************************

  function is_valid_path(path_name IN varchar2)
           return boolean;
  -- NAME:
  -- is_valid_path 
  --
  -- DESCRIPTION:
  --   check whether given path_name is corresponding to the path_prefix 
  --   property

  procedure clear_plugin_violations(pdb_name IN varchar2 DEFAULT NULL);
  -- NAME:
  -- clear_plugin_violations - clean up resolved plugin violations
  --
  -- DESCRIPTION:
  --   This procedure cleans up resolved violations in PDB_PLUG_IN_VIOLATIONS
  --
  -- PARAMETERS:
  -- pdb_name - name of the PDB in which resolved violations are to be cleaned
  --            up; if null, violations in all PDBs are cleaned up

  function check_lockdown(rule_type      IN number,
                          rule_id        IN number,
                          raise_error    IN boolean,
                          init_parameter IN number,
                          events         IN boolean)
           return boolean;
  -- NAME:
  -- check_lockdown
  --
  -- DESCRIPTION:
  --   Checks if the operation is lockdown or not and return a boolean
  --   apprpriately.
  --
  -- INPUT ARGUMENTS
  --    rule_type      - STATEMENT, OPTION or FEATURE
  --    rule_id        - octcodes for STATEMENT
  --                   - VSNF_* defines for OPTIONS(vsnf.h)
  --                   - KPDB_FEAT_* defines for FEATURES(kgpdb.h)
  --    raise_error    - raise error or let client decide the action
  --    init_parameter - initialization parameter
  --    events         - check events lockdown
  --
  -- OUTPUT ARGUMENTS
  --   returns a boolean that indicates whether the current operation is
  --   is lockdown or not.

end;
/
grant execute on dbms_pdb to execute_catalog_role
/

------------------------- dbms_pdb_exec_sql -----------------------------------
-- NAME: 
--   dbms_pdb_exec_sql - execute a sql statement within pdb
--
-- DESCRIPTION:
--   This procedure is a wrapper around dbms_pdb.exec_as_oracle_script
--
-- PARAMETERS:
--   sql_stmt (IN) - sql statement to execute
--
-- NOTE:
--   Internal developers who need to run restricted sql statements from within
--   PDBs need to use this procedure to do so.
-------------------------------------------------------------------------------
create or replace procedure dbms_pdb_exec_sql (sql_stmt varchar2) 
  authid current_user as
begin
  dbms_pdb.exec_as_oracle_script(sql_stmt);
end;
/

create or replace public synonym dbms_pdb_exec_sql for dbms_pdb_exec_sql
/

------------------------- dbms_pdb_is_valid_path ------------------------------
-- NAME: 
--   dbms_pdb_is_valid_path - check given path against PATH_PREFIX
--
-- DESCRIPTION:
--   This function is a wrapper around dbms_pdb.is_valid_path
--
-- PARAMETERS:
--   path_name (IN) - path name
--
-- NOTE:
--
-------------------------------------------------------------------------------
create or replace function dbms_pdb_is_valid_path (path_name varchar2)
  return boolean authid current_user is 
begin
  return dbms_pdb.is_valid_path(path_name);
end;
/

grant execute on dbms_pdb_is_valid_path to public;

create or replace public synonym dbms_pdb_is_valid_path 
  for dbms_pdb_is_valid_path
/

------------------------- dbms_pdb_is_valid_path ------------------------------
-- For comments look at the declaration section of dbms_pdb.check_lockdown
create or replace function dbms_pdb_check_lockdown (rule_type      number,
                                                    rule_id        number,
                                                    raise_error    boolean,
                                                    init_parameter number,
                                                    events         boolean)
  return boolean authid current_user is
begin
  return dbms_pdb.check_lockdown(rule_type, rule_id, raise_error,
                                 init_parameter, events);
end;
/

grant execute on dbms_pdb_check_lockdown to public;

create or replace public synonym dbms_pdb_check_lockdown
  for dbms_pdb_check_lockdown
/

create or replace function getlong( opcode  in number,
                                    p_rowid in rowid ) return varchar2
as
begin
    return CDBView.getlong(opcode, p_rowid);
end getlong;
/

create or replace public synonym dbms_pdb for sys.dbms_pdb
/

-- define the three default lockdown profiles
DECLARE
  l_is_cdb    VARCHAR(4) := 'NO';
  l_con_id    NUMBER;
BEGIN
  -- Check first to see if connected to a PDB.
  BEGIN
    execute immediate 'SELECT UPPER(CDB), SYS_CONTEXT(''USERENV'',''CON_ID'') FROM V$DATABASE' into l_is_cdb, l_con_id;
  EXCEPTION
    WHEN OTHERS THEN
       null;
  END;
  -- YES and con_id = 1, means connected to root container.
  -- YES and con_id > 1, means connected to a PDB.
  IF l_is_cdb = 'YES' and l_con_id = 1 THEN
    execute immediate 'create lockdown profile PRIVATE_DBAAS';
    execute immediate 'create lockdown profile SAAS';
    execute immediate 'create lockdown profile PUBLIC_DBAAS';
  END IF;
END;
/

@?/rdbms/admin/sqlsessend.sql
