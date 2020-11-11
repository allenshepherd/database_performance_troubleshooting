Rem
Rem $Header: rdbms/admin/dbmsxdba.sql /main/20 2016/07/15 11:45:10 sriksure Exp $
Rem
Rem dbmsxdba.sql
Rem
Rem Copyright (c) 2005, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxdba.sql - The Spec for the PL/SQL package DBMS_XDB_ADMIN
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxdba.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxdba.sql
Rem SQL_PHASE: DBMSXDBA
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sriksure    06/01/16 - Bug 23513536 - De-support some features from the
Rem                           spec list
Rem    joalvizo    11/04/15 - Bug 21961991: Add GetTokenTableNames
Rem                           ,MoveTokenTables and RebuildTokenTableIndexes.
Rem    prthiaga    05/19/14 - Bug 21079087: Add GetSequenceInfo
Rem    prthiaga    07/31/14 - Proj 47294: Add post_import_ddl_dml, tbs_ttset_dml
Rem                           and reencode_binary_to_central
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    qyu         12/03/12 - #15940137: move createnoncekey here
Rem    kyagoub     11/12/12 - add installDefaultWallet
Rem    yinlu       02/02/12 - add unsupported pragma for dbms_xdb_admin package
Rem    spetride    03/31/11 - move rebuildhierarchicalindex from dbms_xdb
Rem    spetride    03/17/11 - move movexdb_tablespace from dbms_xdb
Rem                         - add trace for movexdb_tablespace
Rem    attran      10/30/09 - 8533638: ClearRepositoryXMLIndex
Rem    badeoti     03/21/09 - 
Rem                           dbms_csx_admin.updateMasterTable,guidto32,guidfrom32
Rem                           moved to dbms_csx_int
Rem    badeoti     03/19/09 - move dbms_xdb_admin.createnoncekey to dbms_xdbz
Rem    thbaby      10/27/07 - add dbms_csx_admin.GatherTokenTableStats
Rem    spetride    11/01/07 - dbms_csx_admin: cleanup
Rem    spetride    09/05/06 - apis for default token table names
Rem    spetride    03/24/06 - added dbms_csx_admin
Rem    thbaby      06/21/06 - add DropRepositoryXMLIndex
Rem    thbaby      05/03/06 - repository index - add/remove path
Rem    petam       01/10/05 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE xdb.dbms_xdb_admin AUTHID CURRENT_USER IS 

--------
PRAGMA SUPPLEMENTAL_LOG_DATA(default, UNSUPPORTED_WITH_COMMIT);

---------------------------------------------
-- PROCEDURE - CreateNonceKey
--     Insert the randomly generated nonce key into XDB$NONCEKEY table
-- NOTE: Should be called by DBA only, thus in this package
---------------------------------------------
procedure CreateNonceKey;

---------------------------------------------
-- PROCEDURE - movexdb_tablespace
--     Moves xdb in the specified tablespace. The move waits for all
--     concurrent XDB sessions to exit.
-- PARAMETERS - name of the tablespace where xdb is to be moved.
--            - trace: if TRUE, use set serveroutput on to display
--                     progress status information; default FALSE
--
---------------------------------------------
PROCEDURE movexdb_tablespace(new_tablespace IN VARCHAR2, 
                             trace IN BOOLEAN := FALSE);

---------------------------------------------
-- PROCEDURE - RebuildHierarchicalIndex
--     Rebuilds the hierarchical Index; Used after
--     imp/exp since we do cannot export data from
--     xdb$h_index table since it contains rowids
-- PARAMETERS -
--
---------------------------------------------
PROCEDURE RebuildHierarchicalIndex;

-------------------------------------------------------------------------------
-- FUNCTION - installDefaultWallet
--    Install a certificate in the default xdb the wallet stored in 
--    the default XDB wallet directory.
--    Directory name where the XDB wallet is stored is prefixed either 
--    by ORACLE_BASE when it is defined else ORACLE_HOME. 
--    Then it is followed by "/admin/<db_name>/xdb_wallet" where <db_name>
--    is the unique database name.
--    This function can be called if the xdb self-sign on and auto-login wallet
--    installed in the default location or if the existing one expired.  
--
-- PARAMETERS 
--    None
-- 
-- NOTE  
--    - Only sys can intall/replace the default wallet    
--    - This function replaces the wallet if one exists in the default 
--      xdb wallet location.
--    - Two files are expected to be created in the default location: 
--        - cwallet.sso 
--        - ewallet.p12 
-------------------------------------------------------------------------------
procedure installDefaultWallet;

end dbms_xdb_admin;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XDB_ADMIN FOR xdb.dbms_xdb_admin
/
GRANT EXECUTE ON xdb.dbms_xdb_admin TO DBA
/
show errors;



CREATE OR REPLACE PACKAGE xdb.dbms_csx_admin AUTHID CURRENT_USER IS

 DEFAULT_LEVEL  CONSTANT BINARY_INTEGER := 0;
 TAB_LEVEL      CONSTANT BINARY_INTEGER := 1;
 TBS_LEVEL      CONSTANT BINARY_INTEGER := 2;
 NOREG_LEVEL    CONSTANT BINARY_INTEGER := 3;

 NO_CREATE      CONSTANT BINARY_INTEGER := 0;
 NO_INDEXES     CONSTANT BINARY_INTEGER := 1;
 WITH_INDEXES   CONSTANT BINARY_INTEGER := 2;

 DEFAULT_TOKS   CONSTANT BINARY_INTEGER := 0;
 NO_DEFAULT_TOKS  CONSTANT BINARY_INTEGER := 1;      

---------------------------------------------
-- TTS support: multiple token repositories
----------------------------------------------
-- PROCEDURE RegisterTokenTableSet 
--     Registers a token table set: adds an entry in XDB$TTSET corresponding
--     to the new token table set, and creates (if required) the token tables
--     (with the corresponding indexes).
-- PARAMETERS
--  tstabno  - tablespace/table number of the tablespace/table using 
--           - the set of token table we register
--  guid     - globally unique identifier of the token table set
--           - if NULL, a new identifier is created, provided the user is SYS
--  flags    - TAB_LEVEL for table level, 
--           - TBS_LEVEL for tablespace level
--           - NOREG_LEVEL if the TTSET table needs not be updated
--  tocreate - NO_CREATE if no token tables are created
--           - NO_INDEXES if token tables are created, but no indexes
--           - WITH_INDEXES if token tables and corresponding indexes are created 
--  defaulttoks - if DEFAULT_TOKS, insert default token mappings 
-- NOTE
--     It is an error if flags = DEFAULT_LEVEL since the default token table set
--     already exists if XDB is installed.
----------------------------------------------
 procedure RegisterTokenTableSet(tstabno IN NUMBER DEFAULT NULL,
                                 guid IN RAW DEFAULT NULL, 
                                 flags IN NUMBER DEFAULT TBS_LEVEL, 
                                 tocreate IN NUMBER DEFAULT WITH_INDEXES,
                                 defaulttoks IN NUMBER DEFAULT DEFAULT_TOKS);

 procedure CopyDefaultTokenTableSet(tsno IN NUMBER,
                                    qnametable OUT VARCHAR2,
                                    nmspctable OUT VARCHAR2,
                                    pttable OUT VARCHAR2);


-------------------------------------------------------------------
-- PROCEDURE MoveTokenTables 
--      Given the table name, the owner and tablespace name, 
--      move the xml token set tables to differente tablespace
-- NOTE 
--   Needs SYS privileges. 
-------------------------------------------------------------------

 procedure MoveTokenTables(ownername IN VARCHAR2, tablename IN VARCHAR2,
                           tsname IN VARCHAR2);


-------------------------------------------------------------------
-- PROCEDURE RebuildTokenTablesIndexes                            
--      Given the table name and the owner,
--      rebuild the indexes of the xml token set tables
-- NOTE                                                            
--   Needs SYS privileges.
-------------------------------------------------------------------
 procedure RebuildTokenTablesIndexes(ownername IN VARCHAR2, 
                                    tablename IN VARCHAR2);

-----------------------------------------------------------------------------
-- PROCEDURE  GetTokenTableNames
--           Given the table name and the owner, returns the guid of the
--           token table set where token mappings for this table can be found.
--           Returns also the names of the token tables, and whether the token
--           table set is the default one.
-- NOTE
--       It should be called only for CSX tables; otherwise, it will return an
--       error.
--  Needs SYS privileges.
-----------------------------------------------------------------------------
                                                                               
 procedure GetTokenTableNames(ownername IN VARCHAR2, tablename IN VARCHAR2,    
                              qnametable OUT VARCHAR2, nmspctable OUT VARCHAR2,
                              pttable OUT VARCHAR2);
-------------------------------------------------
-- PROCEDURE  GetTokenTableInfo
--           Given the table name and the owner, returns the guid of the 
--           token table set where token mappings for this table can be found.
--           Returns also the names of the token tables, and whether the token
--           table set is the default one. 
-- NOTE
--       It should be called only for CSX tables; otherwise, it will not return an
--       error, just the default guid and token table names.
--       Returns error if there is no default token table set.
--  Needs SYS privileges.
-------------------------------------------------


 procedure GetTokenTableInfo(ownername IN VARCHAR2, tablename IN VARCHAR2,
                             guid OUT RAW, qnametable OUT VARCHAR2, nmspctable OUT VARCHAR2,
                             pttable OUT VARCHAR2, level OUT NUMBER, tabno OUT NUMBER);

 function GetTokenTableInfo(tabno IN NUMBER, guid OUT RAW) return BOOLEAN;


---------------------------------------------------------------
-- PROCEDURE GetTokenTableInfoByTablespace
--     Given a tablespace number, returns the guid and the token
--     table names for this tablespace. If there is no entry
--     in XDB$TTSET for this tablespace, it assumes the default 
--     guid is isued, and returns TRUE in isdefault.
--     containTokTabs is set to TRUE if the token tables for guid
--     are actually in this tablespace. (This is needed for procedural actions
--     for TTS.)
-- NOTE
--   Requires SYS privileges.
---------------------------------------------------------------

 procedure GetTokenTableInfoByTablespace(tsname IN VARCHAR2, tablespaceno IN NUMBER,
                                         guid OUT RAW, qnametable OUT VARCHAR2, 
                                         nmspctable OUT VARCHAR2,
                                         isdefault OUT BOOLEAN,
                                         containTokTab OUT BOOLEAN);

  FUNCTION instance_info_exp(name       IN  VARCHAR2,
                             schema     IN  VARCHAR2,
                             prepost    IN  PLS_INTEGER,
                             isdba      IN  PLS_INTEGER,
                             version    IN  VARCHAR2,
                             new_block  OUT PLS_INTEGER) RETURN VARCHAR2;

-- returns default path-id token table
  function PathIdTable return varchar2;
-- returns default qname-id token table
  function QnameIdTable return varchar2;
-- returns default namespace-id token table
  function NamespaceIdTable return varchar2;
-- procedure to gather stats on default token tables
  procedure GatherTokenTableStats;
-- returns the dml to be run on the import side 
-- for xdb$ttset and xdb$tsetmap
  function tbs_ttset_dml(name varchar2,
                         schema varchar2) RETURN VARCHAR2;
-- returns calls the right dml generator based on 
-- the type of CSX tables on the export side
-- (Central/Table/Tablespace level)
  function post_import_ddl_dml (name    IN  VARCHAR2,
                                schema  IN  VARCHAR2) RETURN VARCHAR2;
-- returns the sequence information about a 12.2 style token table
-- We need this to construct a SQL stmt which would run on the 
-- import side
  procedure GetSequenceInfo(guid IN RAW, seqowner OUT VARCHAR2, 
                            seqname OUT VARCHAR2, seqstart OUT NUMBER);

END dbms_csx_admin;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_CSX_ADMIN FOR xdb.dbms_csx_admin
/
GRANT EXECUTE ON xdb.dbms_csx_admin TO DBA
/
show errors;

@?/rdbms/admin/sqlsessend.sql
