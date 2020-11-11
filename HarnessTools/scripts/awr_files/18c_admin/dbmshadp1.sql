Rem
Rem $Header: rdbms/admin/dbmshadp1.sql /main/11 2017/10/27 12:03:42 rdecker Exp $
Rem
Rem dbmshadp1.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmshadp1.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This file is executed only on linux x-64 platforms
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmshadp1.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmshadp1.sql
Rem    SQL_PHASE: DBMSHADP1
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/dbmshadp.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: correct SQLPHASE
Rem    mthiyaga    07/02/17 - Bug 26381383
Rem    mthiyaga    05/22/17 - Bug 25445169
Rem    mthiyaga    09/27/16 - Bug 24642475
Rem    mthiyaga    06/07/16 - Remove CLUSTER_FOUND()
Rem    mthiyaga    02/11/16 - Bug 22683030
Rem    mthiyaga    09/02/15 - Bug 21151642
Rem    mthiyaga    08/14/15 - Bug 21139344
Rem    mthiyaga    07/17/15 - Contents of (old) dbmshadp.sql
Rem    mthiyaga    07/17/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- The libkubsagt.so library will be located in $ORACLE_HOME/lib
-- This library, pointing to the correct path, will be created in
-- prvthadoop1.sql. Due to the sequence in which the files are
-- loaded in db creation, we are creating a temporary library
-- here, which will be overwritten by the one created in 
-- prvthadoop1.sql.
--
-- The SQL files are loaded in the following order during DB creation:
--
-- dbmshadp1.sql (from catpdbms.sql)
--     |
--     V 
-- cathive1.sql  (from catpdeps.sql)
--     |
--     V
-- prvthadoop1.sql (from catpprvt.sql)
--
-- Even though the spec of DBMS_UTIL is created early on, its body is created much 
-- later (after cathive1.sql is called). So we can only call DBMS_UTIL.DB_VERSION() only
-- in prvthadoop1.sql.
-- 
-- 25421017: We are tightening the restrictions on PATH_PREFIX'd pdbs such that only
-- untrusted libraries that use directory objects are allowed.  So the previous definition
-- of DBMSHADOOPLIB, the one that used 'tmplib', could fail with PLS-01919.  Instead
-- create the temporary library as a trusted library, which is allowed.  Note that because
-- there is no hadoop library vector in psdsys_lvec, this trusted library is as useless at 
-- runtime as the previous temporary library.
CREATE OR REPLACE LIBRARY DBMSHADOOPLIB TRUSTED AS STATIC;
/
show errors;


DROP TYPE HiveMetadata;
DROP TYPE hiveTypeSet;
DROP TYPE hiveType;

-- hiveType matches with the datatype returned by the C pipelined table
-- function, getHiveTable()
-- Currently hiveType consists of 5 columns of NUMBER type and 11 columns
-- of VARCHAR2. This can be increased at will to accomodate any growth
-- needs in the future
--
CREATE OR REPLACE TYPE hiveType AS OBJECT
(
  C0        VARCHAR2(4000), 
  C1        VARCHAR2(4000),
  C2        VARCHAR2(4000),
  C3        VARCHAR2(4000),
  C4        VARCHAR2(4000),
  C5        VARCHAR2(4000),
  C6        NUMBER,
  C7        NUMBER,
  C8        NUMBER,
  C9        NUMBER,
  C10       VARCHAR2(4000),
  C11       VARCHAR2(4000),
  C12       VARCHAR2(4000),
  C13       VARCHAR2(4000),
  C14       NUMBER, 
  C15       VARCHAR2(4000),
  C16       VARCHAR2(4000),
  C17       SYS.AnyData
);
/

CREATE OR REPLACE TYPE hiveTypeSet AS TABLE OF hiveType;
/
show errors;

------------------------------------------------------------------------------
--                            HiveMetadata Type                             --
------------------------------------------------------------------------------
--
-- We use the ODCI framework to execute pipelined C external procedures that
-- in turn call Java methods to fetch the Hive metadata. Data from Java is
-- converted into C format using JNI before being passed back to ODCI
--
CREATE OR REPLACE TYPE HiveMetadata
AUTHID CURRENT_USER
AS OBJECT ( key RAW(4),
STATIC FUNCTION ODCITableStart
  (
    sctx             OUT HiveMetadata,
    configDir        IN VARCHAR2,
    debugDir         IN VARCHAR2,
    clusterName      IN VARCHAR2,
    dbName           IN VARCHAR2,
    tblName          IN VARCHAR2,
    createPartitions IN VARCHAR2,
    callType         IN NUMBER
  )
  RETURN PLS_INTEGER
    AS LANGUAGE C
    LIBRARY DbmsHadoopLib
    NAME "ODCITableStart"
    WITH CONTEXT
    PARAMETERS
  (
    context,
    sctx,
    sctx INDICATOR STRUCT,
    configDir,
    debugDir,
    clusterName,
    dbName,
    tblName,
    createPartitions,
    callType,
    RETURN INT
  ),
  MEMBER FUNCTION ODCITableFetch
  (
    self IN OUT HiveMetadata,
    nrows IN NUMBER,
    outSet OUT hiveTypeSet
  )
  RETURN PLS_INTEGER
    AS LANGUAGE C
    LIBRARY DbmsHadoopLib
    NAME "ODCITableFetch"
    WITH CONTEXT
    PARAMETERS
  (
    context,
    self,
    self INDICATOR STRUCT,
    nrows,
    outSet,
    outSet INDICATOR,
    RETURN INT
  ),
  MEMBER FUNCTION ODCITableClose
  (
    self IN HiveMetadata
  )
  RETURN PLS_INTEGER
    AS LANGUAGE C
    LIBRARY DbmsHadoopLib
    NAME "ODCITableClose"
    WITH CONTEXT
    PARAMETERS
  (
    context,
    self,
    self INDICATOR STRUCT,
    RETURN INT
  )
);
/

show errors;


--
-- DBMS_HADOOP_INTERNAL is a private package that provides a number of helper functions
-- to DBMS_HADOOP. Note that it should be created with DEFINER's rights.
--
CREATE OR REPLACE PACKAGE DBMS_HADOOP_INTERNAL 
AUTHID DEFINER
--ACCESSIBLE BY (DBMS_HADOOP)
AS
--
-- NAME
--   UNIX_TS_TO_DATE
--
-- DESCRIPTION
--   Anciliary function to convert Julian date/time value to calendar date
--
-- PARAMETERS
--   julian_time   - Date/time in Julian value
--
-- RETURNS
--   date          - Calendar date
-- 
-- EXCEPTIONS
--   NONE
--
FUNCTION UNIX_TS_TO_DATE(julian_time IN NUMBER)
  RETURN DATE;

--
-- NAME: DEBUG_USER_PRIVILEDGED
--
-- DESCRIPTION:
-- Check whether a given user has WRITE privileges on the ORACLE_BIGDATA_DEBUG
-- directory
--
-- PARAMETERS: CURRENT_USER
--
-- RETURNS:
-- Returns 1 if the user has WRITE privileges on ORACLE_BIGDATA_DEBUG directory
-- 0 otherwise.
--
FUNCTION DEBUG_USER_PRIVILEGED(CURRENT_USER VARCHAR2)
RETURN NUMBER;

--
-- NAME: GET_OBJNO_FROM_ET
--
-- DESCRIPTION: Given a Hive table, this function returns the object number
--              of the Oracle external table, if one is present.
--
-- PARAMETERS:
-- CLUS_ID:     The hadoop cluster id where the Hive table is located
-- TAB_NAME:    The Hive table name (fully qualified with the db name)
--
-- RETURNS:     Returns the object no of the corresponding external table, if
--              one exists. Otherwise returns 0.
--
FUNCTION GET_OBJNO_FROM_ET(
             CLUSTER_ID IN VARCHAR2,
             TABLE_NAME IN VARCHAR2,
             XT_TAB_NAME IN VARCHAR2,
             XT_TAB_OWNER IN NUMBER
) RETURN NUMBER;


--
--
-- NAME: IS_PARTITION_COMPATIBLE
--
-- DESCRIPTION: Given a Hive table and its corresponding Oracle
--              external table, this function tells whether
--              the external table is partition compatible with
--              the hive table.
--
--              If the XT is exactly identical to the Hive table
--              this function will return FALSE - the reason is
--              that the user does not need to call the SYNC API.
--
-- PARAMETERS:
-- MDATA_COMPATIBLE Are Hive table and XT metadata compatible?
-- PARTNS_ADDED Any new partitions added to the hive table
-- PARTNS_DROPPED Any partitions dropped from the hive table
--
-- RETURNS:     Returns 'TRUE' if there are any partitions added
--              or dropped
--
FUNCTION IS_PARTITION_COMPATIBLE(
              MDATA_COMPATIBLE IN VARCHAR2,
              PARTNS_ADDED IN CLOB,
              PARTNS_DROPPED IN CLOB
) RETURN VARCHAR2;

--
--
-- NAME: GET_INCOMPATIBILITY
--
-- DESCRIPTION: Given a Hive table and its corresponding Oracle
--              external table, this function returns the first
--              incompatibility that is encountered.
--
-- PARAMETERS:
-- CLUS_ID:     Hadoop cluster id where the Hive table is located
-- DB_NAME:     Database where the Hive table is located
-- HIVE_TBL_NAME:   Hive table name
-- ET_TBL_NAME: External table name
-- ET_TBL_OWNER: External table owner
--
-- RETURNS:     Returns a CLOB containing the first metadata 
--              incompatibility encountered
--
FUNCTION GET_INCOMPATIBILITY(
                     CLUS_ID IN VARCHAR2,
                     DB_NAME IN VARCHAR2,
                     HIVE_TBL_NAME IN VARCHAR2,
                     ET_TBL_NAME IN VARCHAR2,
                     ET_TBL_OWNER IN VARCHAR2
) RETURN CLOB;


--
-- NAME: IS_METADATA_COMPATIBLE
--
-- DESCRIPTION: Given a Hive table and its corresponding Oracle external
--              table, this function checks whether the external table is
--              metadata-compatible with the Hive table. Metadata 
--              compatibility  means (a) every column in the external table
--              must be present in the Hive table (b) the datatype of each
--              external table column must be the same or compatible with
--              the datatype of the hive table column. (c) The partition
--              keys in the external table must be in the same order as the
--              partition keys in the hive table.
--
-- PARAMETERS:
-- TABLE_OWNER: Owner of the external table
-- TABLE_NAME:  External table name
-- CLUS_ID:     Hadoop cluster id where the Hive table is located
-- DB_NAME:     Database where the Hive table is located
-- TBL_NAME:    Hive table name
--
-- RETURNS:     Returns 'TRUE' if XT metadata is compatible with that of the
--              Hive table; FALSE otherwise.
--
-- ***************************** IMPORTANT NOTE ******************************
-- Note that this function cannot be used standalone. It can only be used
-- in the script that creates the view XXX_XT_HIVE_TABLES_VALIDATION as
-- this script contains additional checks (joins) that guarantee that
-- the external table corresponds to the hive table in the argument.
-- ***************************************************************************
--
FUNCTION IS_METADATA_COMPATIBLE(
                     CLUS_ID IN VARCHAR2,
                     DB_NAME IN VARCHAR2,
                     HIVE_TBL_NAME IN VARCHAR2,
                     ET_TBL_NAME IN VARCHAR2,
                     ET_TBL_OWNER IN VARCHAR2
) RETURN VARCHAR2;


--
--
-- NAME: DROPPED_PARTNS
--
-- DESCRIPTION: Given a Hive table, this function returns all the partitions 
--              that appear in the corresponding Oracle external table, but 
--              in the given Hive table.
--
-- PARAMETERS:
-- CLUS_ID:     The hadoop cluster id where the Hive table is located
-- DB_NAME:     The database where the Hive table is located
-- TAB_NAME:    The Hive table name
-- ET_NAME:     The external table name
-- ET_OWNER:    External table owner
-- MDATA_COMPATIBLE: Indicate if XT and Hive tables are metadata compatible
--
-- RETURNS:     Returns a CLOB containing all the dropped partitions
--
FUNCTION DROPPED_PARTNS(
                     CLUS_ID IN VARCHAR2,
                     DB_NAME IN VARCHAR2,
                     TAB_NAME IN VARCHAR2,
                     ET_NAME IN VARCHAR2,
                     ET_OWNER IN VARCHAR2,
                     MDATA_COMPATIBLE IN VARCHAR2
) RETURN CLOB;


--
-- NAME: ADDED_HIVE_PARTNS
--
-- DESCRIPTION: Given a Hive table, this function returns all the partitions 
--              that appear in the Hive table, but missing in the 
--              corresponding Oracle external table. We use the function
--              ADDED_PARTNS() to obtain the hashed partitioned names from
--              DBA_HIVE_TAB_PARTITIONS and then find the corresponding
--              original partition specs.
--
-- PARAMETERS:
-- CLUS_ID:     The hadoop cluster id where the Hive table is located
-- DB_NAME:     The database where the Hive table is located
-- TAB_NAME:    The Hive table name
-- partnList:   Newly added hive partition names
-- MDATA_COMPATIBLE: Indicate if XT and Hive are metadata compatible
--
-- RETURNS:     Returns a CLOB containing all the added partitions in Hive
--
FUNCTION ADDED_HIVE_PARTNS(
                     CLUS_ID IN VARCHAR2,
                     DB_NAME IN VARCHAR2,
                     TAB_NAME IN VARCHAR2,
                     partnList IN CLOB,
                     MDATA_COMPATIBLE IN VARCHAR2
) RETURN CLOB;


--
-- NAME: ADDED_PARTNS
--
-- DESCRIPTION: Given a Hive table, this function returns all the partitions 
--              that appear in the Hive table, but missing in the 
--              corresponding Oracle external table
--
-- PARAMETERS:
-- CLUS_ID:     The hadoop cluster id where the Hive table is located
-- DB_NAME:     The database where the Hive table is located
-- TAB_NAME:    The Hive table name
-- ET_NAME:     The external table name
-- ET_OWNER:    External table owner
-- MDATA_COMPATIBLE: Indicate if XT and Hive are metadata compatible
--
-- RETURNS:     Returns a CLOB containing all the added partitions
--
FUNCTION ADDED_PARTNS(
                     CLUS_ID IN VARCHAR2,
                     DB_NAME IN VARCHAR2,
                     TAB_NAME IN VARCHAR2,
                     ET_NAME IN VARCHAR2,
                     ET_OWNER IN VARCHAR2,
                     MDATA_COMPATIBLE IN VARCHAR2
) RETURN CLOB;

--
FUNCTION SYNC_USER_PRIVILEGED(XT_TAB_NAME IN VARCHAR2,
                              XT_TAB_OWNER IN VARCHAR2,
                              CURRENT_USER IN VARCHAR2)
RETURN NUMBER;

PROCEDURE DO_SYNC_PARTITIONS(
                     PARTNLIST IN CLOB,
                     SYNCMODE IN NUMBER,
                     XT_TAB_NAME IN VARCHAR2,
                     XT_TAB_OWNER IN VARCHAR2
);

FUNCTION GETNUMBEROFITEMS(INSTR IN CLOB,
                          BOUNDARYKEY IN CHAR
)
RETURN NUMBER;


FUNCTION GET_HIVE_PKEYS(CLUS_ID IN VARCHAR2,
                        DATABASE_NAME IN VARCHAR2,
                        TBL_NAME IN VARCHAR2
)
RETURN CLOB;


FUNCTION GET_XT_PKEYS(ORIG_DDL IN CLOB
)
RETURN CLOB;


FUNCTION XT_COLUMNS_MATCHED(CLUS_ID IN VARCHAR2,
                            DB_NAME IN VARCHAR2,
                            HIVE_TBL_NAME IN VARCHAR2,
                            ORIG_DDL IN CLOB
)
RETURN VARCHAR2;

--
-- NAME: USER_PRIVILEDGED
--
-- DESCRIPTION:
-- Check whether a given user has READ privileges on the specified hadoop 
-- cluster. The user should have READ permission on the oracle directory
-- object, ORACLE_BIGDATA_CONFIG.
--
-- PARAMETERS:
-- CLUSTER_ID: The hadoop cluster id which the user is trying to access
-- CURRENT_USER: The name of the current user
--
-- RETURNS:
-- Returns 1 if the user has READ privileges on the specified hadoop cluster,
-- 0 otherwise.
--
FUNCTION USER_PRIVILEGED(CLUSTER_ID IN VARCHAR2,
                         CURRENT_USER IN VARCHAR2)
RETURN NUMBER;

FUNCTION GET_DEBUG_DIR(CURRENT_USER VARCHAR2)
  RETURN VARCHAR2;

FUNCTION GET_CONFIG_DIR
  RETURN VARCHAR2;

-- getHiveTable()  
--
-- DESCRIPTION
--   getHiveTable() is a pipelined table function that returns the rows back
--   from C external procedures via ODCI to PL/SQL. The rows sent from C 
--   external procedures actually originate from various Hive metastores and
--   fetched via JNI calls made from hotspot JVM 
--
-- PARAMETERS
--   configDir   - The absolute path of the ORACLE_BIGDATA_CONFIG directory
--   debugDir    - The absolute path of the ORACLE_BIGDATA_DEBUG directory
--   clusterName - The name of the Hadoop cluster where data is coming from
--   dbName      - The Hive database name where the data is coming from
--   tblName     - The Hive table where the data is coming from
--   createPartitions - Indicates whether to create partitions while creating
--                 the external table DDL.
--   callType    - one of (0, 1, 2, 3, 4, 5).
--               - 0: Will fetch only database related Hive metadata
--               - 1: Will fetch only table related Hive metadata
--               - 2: Will fetch only column related Hive metadata
--               - 3: Will generate a create external table DDL for a 
--                    specified Hive table
--               - 4: Will fetch only table partition related Hive metadata
--               - 5: Will fetch only part. key cols related Hive metadata
--
-- RETURNS
--  hiveTypeSet as pipelined rows
--
FUNCTION getHiveTable
(
  configDir        IN VARCHAR2,
  debugDir         IN VARCHAR2,
  clusterName      IN VARCHAR2,
  dbName           IN VARCHAR2,
  tblName          IN VARCHAR2,
  createPartitions IN VARCHAR2,
  callType         IN NUMBER
)
RETURN hiveTypeSet PIPELINED USING HiveMetadata;

FUNCTION GET_DDL(secureConfigDir VARCHAR2, 
                 secureDebugDir VARCHAR2, 
                 secureClusterId VARCHAR2,
                 secureDbName VARCHAR2,
                 secureHiveTableName VARCHAR2,
                 createPartitions VARCHAR2
                )
RETURN CLOB; 


FUNCTION GET_PARTN_SPEC(CLUST_ID VARCHAR2,
                        DB_NAME VARCHAR2,
                        HIVE_TABLE_NAME VARCHAR2,
                        TEXT_OF_DDL_IP CLOB
                       )
RETURN CLOB;

FUNCTION GET_HIVE_TAB_INFO(XT_TAB_NAME VARCHAR2, XT_TAB_OWNER VARCHAR2)
RETURN VARCHAR2;

PROCEDURE GET_NAME(NAME IN VARCHAR2, MYOWNER IN OUT VARCHAR2,
                   MYNAME IN OUT VARCHAR2, DOWNER IN VARCHAR2);

-- NAME: remove_double_quote
--
-- DESCRIPTION:
-- Removes the double quotes from an enquoted name
--
-- PARAMETERS: string
--
-- RETURNS:
-- string with double quote stripped
-- 
-- NOTES:
-- Double quotes stripped string should be used only in case of binds
--
FUNCTION remove_double_quote(str VARCHAR2) RETURN VARCHAR2;



-- NAME: GET_XT_COLUMNS
--
-- DESCRIPTION:
-- Returns all the external table columns
--
-- PARAMETERS: ORIG_DDL - DDL used to create the given XT
-- RETURNS:
--             All the columns found in the external table
--
FUNCTION GET_XT_COLUMNS(
    ORIG_DDL IN CLOB
)
  RETURN CLOB;



-- NAME: GET_HIVE_COLUMNS
--
-- DESCRIPTION: Returns all the columns found in the given hive table
--
-- PARAMETERS: CLUS_ID  - Hadoop cluster id
--             DB_NAME  - Database where the hive table is located
--             TBL_NAME - Hive table name
-- RETURNS:
--         All hive columns
--
FUNCTION GET_HIVE_COLUMNS(
    CLUS_ID IN VARCHAR2,
    DB_NAME IN VARCHAR2,
    TBL_NAME IN VARCHAR2
)
  RETURN CLOB;

-- NAME: getPartKeyValues
--
-- DESCRIPTION:
-- Returns the values of a given partition key
--
-- PARAMETERS:  curKey   - partition key
--              partnCnt - count of how may columns are in curKey
--
-- RETURNS: key value list 
--
FUNCTION getPartKeyValues(curKey IN CLOB, partnCnt IN NUMBER)
RETURN CLOB;


END DBMS_HADOOP_INTERNAL;
/
show errors;


GRANT EXECUTE ON DBMS_HADOOP_INTERNAL TO EXECUTE_CATALOG_ROLE
/
show errors;


CREATE OR REPLACE PACKAGE DBMS_HADOOP 
AUTHID CURRENT_USER
IS
--
-- NAME
--   CREATE_EXTDDL_FOR_HIVE
--
-- DESCRIPTION
--   Declaration for the CREATE_EXTDDL_FOR_HIVE procedure. This procedure 
--   allows one to generate the CREATE EXTERNAL TABLE ... DDL statement for
--   a given Hive table. The procedure invokes a pipelined C function
--   (getHiveTable()), which in turns fetches the necessary metadata from
--   the concerned hive metastore via JNI calls. The metadata pieces from
--   Hive are assembled to generate a syntatically correct CREATE EXTERNAL
--   TABLE statement.
--
-- PARAMETERS
--   CLUSTER_ID      - The hadoop cluster id where the hive table is located.
--   DB_NAME         - The database name where the hive table belongs to.
--   HIVE_TABLE_NAME - The name of the hive table, for which the CREATE
--                     EXTERNAL TABLE statement is being generated
--   HIVE_PARTITION  - This is a boolean value, indicating whether the hive
--                     table partitions need to be included in the CREATE
--                     EXTERNAL TABLE statement
--   TABLE_NAME      - If TABLE_NAME is NULL, then the HIVE_TABLE_NAME will be
--                     the name of the Oracle external table. Otherwise, 
--                     TABLE_NAME will be the name of the Oracle external
--                     table
--   PERFORM_DDL     - This is a boolean value, indicating whether to execute
--                     the generated DDL on Oracle and immediately create
--                     an external table
--   TEXT_OF_DDL     - This is the output of the procedure, where the 
--                     generated CREATE EXTERNAL TABLE ... statement is stored
--
-- RETURNS
--   NONE
--
-- EXCEPTIONS
--   HIVE_TABLE_NOT_FOUND
--   INVALID_USER
--   INVALID_CLUSTER
--  

PROCEDURE CREATE_EXTDDL_FOR_HIVE(
             CLUSTER_ID IN VARCHAR2,
             DB_NAME IN VARCHAR2,
             HIVE_TABLE_NAME IN VARCHAR2,
             HIVE_PARTITION IN BOOLEAN,
             TABLE_NAME IN VARCHAR2,
             PERFORM_DDL IN BOOLEAN := FALSE,
             TEXT_OF_DDL OUT CLOB
           );



PROCEDURE SYNC_PARTITIONS_FOR_HIVE(
             XT_TAB_NAME IN VARCHAR2,
             XT_TAB_OWNER IN VARCHAR2
);

END DBMS_HADOOP;
/

GRANT EXECUTE ON DBMS_HADOOP TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM DBMS_HADOOP FOR DBMS_HADOOP
/

show errors;

@?/rdbms/admin/sqlsessend.sql

