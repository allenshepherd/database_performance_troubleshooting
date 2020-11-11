Rem
Rem $Header: rdbms/admin/cathive1.sql /main/8 2017/10/25 18:01:32 raeburns Exp $
Rem
Rem cathive1.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cathive1.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Scripts to create various oracle catalog views for hive metadata
Rem
Rem    NOTES
Rem      None
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cathive1.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/cathive1.sql
Rem    SQL_PHASE: CATHIVE1
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/cathive.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: correct SQLPHASE
Rem    mthiyaga    07/03/17 - Bug 26381383
Rem    mthiyaga    06/07/16 - Remove HIVE_URI$ dependency
Rem    mthiyaga    09/29/15 - Bug 21916906
Rem    mthiyaga    09/02/15 - Add ORACLE_COLUMN_TYPE to
Rem                           DBA_HIVE_PART_KEY_COLUMNS
Rem    mthiyaga    08/14/15 - Bug 21139344
Rem    mthiyaga    07/17/15 - Contents of (old) cathive.sql
Rem    mthiyaga    07/17/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


-------------------------------------------------------------------------------
--                           HIVE_TABLES VIEWS
-------------------------------------------------------------------------------
--
-- DBA_HIVE_TABLES
--
CREATE OR REPLACE VIEW DBA_HIVE_TABLES
(
  CLUSTER_ID,                     /* User supplied hive identifier           */
  DATABASE_NAME,                  /* Hive database name                      */
  TABLE_NAME,                     /* Hive table name                         */
  LOCATION,                       /* Location of hive table                  */
  NO_OF_COLS,                     /* Number of columns in table              */
  CREATION_TIME,                  /* Creation time of hive table             */
  LAST_ACCESSED_TIME,             /* Last accessed time of hive table        */
  OWNER,                          /* Hive table owner                        */
  TABLE_TYPE,                     /* Table type                              */
  PARTITIONED,                    /* Is this hive table partitioned?         */
  NO_OF_PART_KEYS,                /* Number of partition cols                */
  INPUT_FORMAT,                   /* Input format of the hive table          */
  OUTPUT_FORMAT,                  /* Output format of the hive table         */
  SERIALIZATION,                  /* Serialization info of the hive table    */
  COMPRESSED,                     /* Is this hive table compressed?          */
  HIVE_URI                        /* URI of the hive metastore db            */
)
AS
SELECT HT.C15 AS CLUSTER_ID, 
       HT.C0 AS DATABASE_NAME,
       HT.C1 AS TABLE_NAME, 
       HT.C5 AS LOCATION, 
       HT.C6 AS NO_OF_COLS,
       DBMS_HADOOP_INTERNAL.UNIX_TS_TO_DATE(HT.C8) AS CREATION_TIME,
       DBMS_HADOOP_INTERNAL.UNIX_TS_TO_DATE(HT.C9) AS LAST_ACCESSED_TIME,
       HT.C2 AS OWNER, 
       HT.C3 AS TABLE_TYPE,
       HT.C10 AS PARTITIONED,
       HT.C7 AS NO_OF_PART_KEYS,
       HT.C11 AS INPUT_FORMAT, 
       HT.C12 AS OUTPUT_FORMAT, 
       HT.C13 AS SERIALIZATION,
       HT.C14 AS COMPRESSED,
       HT.C16 AS HIVE_URI
  FROM
    (SELECT DIRECTORY_PATH AS configDir
     FROM DBA_DIRECTORIES 
     WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_CONFIG') HU, 
    (SELECT DIRECTORY_PATH AS debugDir
     FROM DBA_DIRECTORIES
     WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_DEBUG' 
     UNION ALL
     SELECT 'InvalidDir' FROM DUAL WHERE 
           NOT EXISTS (SELECT DIRECTORY_PATH AS debugDir
                       FROM DBA_DIRECTORIES
                       WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_DEBUG')
    ) HV,
     LATERAL(SELECT * FROM 
         TABLE(DBMS_HADOOP_INTERNAL.GetHiveTable(HU.configDir, HV.debugDir, '*', '*', '*', 'TRUE', 1))) HT
/

COMMENT ON TABLE DBA_HIVE_TABLES is 'All hive tables in the given database'
/
COMMENT ON  COLUMN DBA_HIVE_TABLES.CLUSTER_ID is 'Hadoop cluster name'
/
COMMENT ON  COLUMN DBA_HIVE_TABLES.DATABASE_NAME is 'Database where hive table resides'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.TABLE_NAME is 'Hive table name'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.LOCATION is 'Physical location of the hive table'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.NO_OF_COLS is 'Number of columns in the hive table'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.CREATION_TIME is 'Creation time of the hive table'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.LAST_ACCESSED_TIME is 'Last accessed time of hive table'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.OWNER is 'Owner of hive table'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.TABLE_TYPE is 'Type of hive table'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.PARTITIONED is 'Is this hive table partitioned?'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.NO_OF_PART_KEYS is 'No of partition keys in hive table'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.INPUT_FORMAT is 'Hive table input format'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.OUTPUT_FORMAT is 'Hive table output format'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.SERIALIZATION is 'Hive table serialization'
/

COMMENT ON  COLUMN DBA_HIVE_TABLES.COMPRESSED is 'Is this hive table compressed?'
/

CREATE  OR REPLACE PUBLIC SYNONYM DBA_HIVE_TABLES FOR DBA_HIVE_TABLES
/

GRANT SELECT ON DBA_HIVE_TABLES TO select_catalog_role
/

EXECUTE CDBView.create_cdbview(false, 'SYS', 'DBA_HIVE_TABLES', 'CDB_HIVE_TABLES');

grant select on SYS.CDB_HIVE_TABLES to select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM CDB_HIVE_TABLES for SYS.CDB_HIVE_TABLES
/


--
-- USER_HIVE_TABLES
--

CREATE  OR REPLACE VIEW USER_HIVE_TABLES
AS SELECT M.* FROM DBA_HIVE_TABLES M, SYS.USER$ U
WHERE U.user# = USERENV('SCHEMAID') AND
-- Current user has system privileges
      ((
        ora_check_sys_privilege(U.user#, 2) = 1
       )
       OR
-- If current user is neither SYS nor DBA, then do the following checks
-- User must have read privilege on ORACLE_BIGDATA_CONFIG directory.
      (
       ((U.NAME IN (SELECT GRANTEE FROM
                               ALL_TAB_PRIVS
                               WHERE TABLE_NAME = 'ORACLE_BIGDATA_CONFIG' AND
                                     PRIVILEGE = 'READ')) OR
        ('PUBLIC' IN (SELECT GRANTEE FROM
                               ALL_TAB_PRIVS
                               WHERE TABLE_NAME = 'ORACLE_BIGDATA_CONFIG' AND
                                     PRIVILEGE = 'READ')))))
/


COMMENT ON  TABLE USER_HIVE_TABLES is 'All hive tables in the given database'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.CLUSTER_ID is 'Hadoop cluster name'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.DATABASE_NAME is 'Database where hive table resides'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.TABLE_NAME is 'Hive table name'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.LOCATION is 'Physical location of the hive table'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.NO_OF_COLS is 'Number of columns in the hive table'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.CREATION_TIME is 'Creation time of the hive table'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.LAST_ACCESSED_TIME is 'Last accessed time of hive table'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.OWNER is 'Owner of hive table'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.TABLE_TYPE is 'Type of hive table'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.PARTITIONED is 'Is this hive table partitioned?'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.NO_OF_PART_KEYS is 'No of partition keys in hive table'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.INPUT_FORMAT is 'Hive table input format'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.OUTPUT_FORMAT is 'Hive table output format'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.SERIALIZATION is 'Hive table serialization'
/

COMMENT ON  COLUMN USER_HIVE_TABLES.COMPRESSED is 'Is this hive table compressed?'
/


CREATE  OR REPLACE PUBLIC SYNONYM USER_HIVE_TABLES FOR USER_HIVE_TABLES
/

GRANT READ ON USER_HIVE_TABLES TO PUBLIC WITH GRANT OPTION
/


--
-- ALL_HIVE_TABLES
--
-- The view, ALL_HIVE_TABLES, displays information  about those hive tables the current user
-- can access.  For a user to access a hive table, the user must have SYS or DBA privileges or 
-- the user has READ permission on ORACLE_BIGDATA_CONFIG
--
CREATE  OR REPLACE VIEW ALL_HIVE_TABLES
AS SELECT * FROM USER_HIVE_TABLES
/


COMMENT ON  TABLE ALL_HIVE_TABLES is 'All hive tables in the given database'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.CLUSTER_ID is 'Hadoop cluster name'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.DATABASE_NAME is 'Database where hive table resides'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.TABLE_NAME is 'Hive table name'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.LOCATION is 'Physical location of the hive table'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.NO_OF_COLS is 'Number of columns in the hive table'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.CREATION_TIME is 'Creation time of the hive table'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.LAST_ACCESSED_TIME is 'Last accessed time of hive table'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.OWNER is 'Owner of hive table'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.TABLE_TYPE is 'Type of hive table'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.PARTITIONED is 'Is this hive table partitioned?'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.NO_OF_PART_KEYS is 'No of partition keys in hive table'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.INPUT_FORMAT is 'Hive table input format'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.OUTPUT_FORMAT is 'Hive table output format'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.SERIALIZATION is 'Hive table serialization'
/

COMMENT ON  COLUMN ALL_HIVE_TABLES.COMPRESSED is 'Is this hive table compressed?'
/


CREATE  OR REPLACE PUBLIC SYNONYM ALL_HIVE_TABLES FOR ALL_HIVE_TABLES
/

GRANT READ ON ALL_HIVE_TABLES TO PUBLIC WITH GRANT OPTION
/



--
-- DBA_HIVE_COLUMNS
--

CREATE  OR REPLACE VIEW DBA_HIVE_COLUMNS
(
  CLUSTER_ID,                     /* User supplied hive identifier           */
  DATABASE_NAME,                  /* Hive database name                      */
  TABLE_NAME,                     /* Hive table name                         */
  COLUMN_NAME,                    /* Hive column name                        */
  HIVE_COLUMN_TYPE,               /* Hive column type                        */
  ORACLE_COLUMN_TYPE,             /* Oracle column type                      */
  LOCATION,                       /* Location of hive table                  */
  OWNER,                          /* Hive table owner                        */
  CREATION_TIME,                  /* Creation time of hive table             */
  HIVE_URI                        /* URI of the hive metastore db            */
)
AS
SELECT HT.C15 AS CLUSTER_ID,
       HT.C0 AS DATABASE_NAME,
       HT.C1 AS TABLE_NAME,
       HT.C3 AS COLUMN_NAME,
       HT.C4 AS HIVE_COLUMN_TYPE,
       HT.C10 AS ORACLE_COLUMN_TYPE,
       HT.C5 AS LOCATION,
       HT.C2 AS OWNER,
       DBMS_HADOOP_INTERNAL.UNIX_TS_TO_DATE(HT.C8) AS CREATION_TIME, 
       HT.C16 AS HIVE_URI
  FROM
  (SELECT DIRECTORY_PATH AS configDir
     FROM DBA_DIRECTORIES 
     WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_CONFIG') HU, 
  (SELECT DIRECTORY_PATH AS debugDir
     FROM DBA_DIRECTORIES
     WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_DEBUG'
     UNION ALL
     SELECT 'InvalidDir' FROM DUAL WHERE
           NOT EXISTS (SELECT DIRECTORY_PATH AS debugDir
                       FROM DBA_DIRECTORIES
                       WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_DEBUG')
  ) HV,
     LATERAL(SELECT * FROM 
       TABLE(DBMS_HADOOP_INTERNAL.GetHiveTable(HU.configDir, HV.debugDir, '*', '*', '*', 'TRUE', 2))) HT
/


COMMENT ON  TABLE DBA_HIVE_COLUMNS is 'All hive columns in the given database'
/

COMMENT ON  COLUMN DBA_HIVE_COLUMNS.CLUSTER_ID is 'User supplied identifier for this hive metastore'
/

COMMENT ON  COLUMN DBA_HIVE_COLUMNS.DATABASE_NAME is 'Database where owning hive table resides'
/

COMMENT ON  COLUMN DBA_HIVE_COLUMNS.TABLE_NAME is 'Hive table name where the column belongs to'
/

COMMENT ON  COLUMN DBA_HIVE_COLUMNS.COLUMN_NAME is 'Hive column name'
/

COMMENT ON  COLUMN DBA_HIVE_COLUMNS.HIVE_COLUMN_TYPE is 'Data type of the hive column' 
/

COMMENT ON  COLUMN DBA_HIVE_COLUMNS.ORACLE_COLUMN_TYPE is 'Equivalent Oracle data type of the hive column'
/

COMMENT ON  COLUMN DBA_HIVE_COLUMNS.LOCATION is 'Physical location of the hive table'
/

COMMENT ON  COLUMN DBA_HIVE_COLUMNS.OWNER is 'Owner of hive table'
/

COMMENT ON  COLUMN DBA_HIVE_COLUMNS.HIVE_URI is 'The connection string (URI and port no) for metastore db'
/


CREATE  OR REPLACE PUBLIC SYNONYM DBA_HIVE_COLUMNS FOR DBA_HIVE_COLUMNS
/

GRANT SELECT ON DBA_HIVE_COLUMNS TO select_catalog_role
/


EXECUTE  CDBView.create_cdbview(false, 'SYS', 'DBA_HIVE_COLUMNS', 'CDB_HIVE_COLUMNS');

grant select on SYS.CDB_HIVE_COLUMNS to select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM CDB_HIVE_COLUMNS for SYS.CDB_HIVE_COLUMNS
/


--
-- USER_HIVE_COLUMNS
--

CREATE  OR REPLACE VIEW USER_HIVE_COLUMNS
AS SELECT M.* FROM DBA_HIVE_COLUMNS M, SYS.USER$ U
WHERE U.user# = USERENV('SCHEMAID') AND
-- Current user has system privileges
      ((
        ora_check_sys_privilege(U.user#, 2) = 1
       )
       OR
-- If current user is neither SYS nor DBA, then do the following checks
-- User must have read privilege on ORACLE_BIGDATA_CONFIG directory.
      (((U.NAME IN (SELECT GRANTEE FROM
                               ALL_TAB_PRIVS
                               WHERE TABLE_NAME = 'ORACLE_BIGDATA_CONFIG' AND
                                     PRIVILEGE = 'READ')) OR
        ('PUBLIC' IN (SELECT GRANTEE FROM
                               ALL_TAB_PRIVS
                               WHERE TABLE_NAME = 'ORACLE_BIGDATA_CONFIG' AND
                                     PRIVILEGE = 'READ')))))
/



COMMENT ON  TABLE USER_HIVE_COLUMNS is 'All hive columns in the given database'
/

COMMENT ON  COLUMN USER_HIVE_COLUMNS.CLUSTER_ID is 'User supplied identifier for this hive metastore'
/

COMMENT ON  COLUMN USER_HIVE_COLUMNS.DATABASE_NAME is 'Database where owning hive table resides'
/

COMMENT ON  COLUMN USER_HIVE_COLUMNS.TABLE_NAME is 'Hive table name where the column belongs to'
/

COMMENT ON  COLUMN USER_HIVE_COLUMNS.COLUMN_NAME is 'Hive column name'
/

COMMENT ON  COLUMN USER_HIVE_COLUMNS.HIVE_COLUMN_TYPE is 'Data type of the hive column'
/

COMMENT ON  COLUMN USER_HIVE_COLUMNS.ORACLE_COLUMN_TYPE is 'Equivalent Oracle data type of the hive column'
/

COMMENT ON  COLUMN USER_HIVE_COLUMNS.LOCATION is 'Physical location of the hive table'
/

COMMENT ON  COLUMN USER_HIVE_COLUMNS.OWNER is 'Owner of hive table'
/

COMMENT ON  COLUMN USER_HIVE_COLUMNS.HIVE_URI is 'The connection string (URI and port no) for metastore db'
/



CREATE  OR REPLACE PUBLIC SYNONYM USER_HIVE_COLUMNS FOR USER_HIVE_COLUMNS
/

GRANT READ ON USER_HIVE_COLUMNS TO PUBLIC WITH GRANT OPTION
/



--
-- ALL_HIVE_COLUMNS
--
-- The view, ALL_HIVE_COLUMNS, displays information  about those hive columns the current user
-- can access.  For a user to access a hive table, the user must have SYS or DBA privileges or 
-- the user has READ permission on ORACLE_BIGDATA_CONFIG
--

CREATE  OR REPLACE VIEW ALL_HIVE_COLUMNS
AS SELECT * FROM USER_HIVE_COLUMNS
/



COMMENT ON  TABLE ALL_HIVE_COLUMNS is 'All hive columns in the given database'
/

COMMENT ON  COLUMN ALL_HIVE_COLUMNS.CLUSTER_ID is 'User supplied identifier for this hive metastore'
/

COMMENT ON  COLUMN ALL_HIVE_COLUMNS.DATABASE_NAME is 'Database where owning hive table resides'
/

COMMENT ON  COLUMN ALL_HIVE_COLUMNS.TABLE_NAME is 'Hive table name where the column belongs to'
/

COMMENT ON  COLUMN ALL_HIVE_COLUMNS.COLUMN_NAME is 'Hive column name'
/

COMMENT ON  COLUMN ALL_HIVE_COLUMNS.HIVE_COLUMN_TYPE is 'Data type of the hive column'
/

COMMENT ON  COLUMN ALL_HIVE_COLUMNS.ORACLE_COLUMN_TYPE is 'Equivalent Oracle data type of the hive column'
/

COMMENT ON  COLUMN ALL_HIVE_COLUMNS.LOCATION is 'Physical location of the hive table'
/

COMMENT ON  COLUMN ALL_HIVE_COLUMNS.OWNER is 'Owner of hive table'
/

COMMENT ON  COLUMN ALL_HIVE_COLUMNS.HIVE_URI is 'The connection string (URI and port no) for metastore db'
/



CREATE  OR REPLACE PUBLIC SYNONYM ALL_HIVE_COLUMNS FOR ALL_HIVE_COLUMNS
/

GRANT READ ON ALL_HIVE_COLUMNS TO PUBLIC WITH GRANT OPTION
/



--
-- DBA_HIVE_DATABASES
--

CREATE  OR REPLACE VIEW DBA_HIVE_DATABASES
(
  CLUSTER_ID,                      /* User supplied cluster identifier       */
  DATABASE_NAME,                   /* Hive database name                     */
  DESCRIPTION,                     /* Database description                   */
  DB_LOCATION,                     /* DB location                            */
  HIVE_URI                         /* URI of the hive metastore db           */
)
AS
SELECT UNIQUE HT.C15 AS CLUSTER_ID,
       HT.C0 AS DATABASE_NAME,
       HT.C4 AS DESCRIPTION,
       HT.C5 AS DB_LOCATION,
       HT.C16 AS HIVE_URI
    FROM
    (SELECT DIRECTORY_PATH AS configDir
     FROM DBA_DIRECTORIES
     WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_CONFIG') HU,
    (SELECT DIRECTORY_PATH AS debugDir
     FROM DBA_DIRECTORIES
     WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_DEBUG'
     UNION ALL
     SELECT 'InvalidDir' FROM DUAL WHERE
           NOT EXISTS (SELECT DIRECTORY_PATH AS debugDir
                       FROM DBA_DIRECTORIES
                       WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_DEBUG')
    ) HV,
     LATERAL(SELECT * FROM 
    TABLE(DBMS_HADOOP_INTERNAL.GetHiveTable(HU.configDir,  HV.debugDir, '*', '*', '*', 'TRUE', 0))) HT
/



COMMENT ON  TABLE DBA_HIVE_DATABASES is 'All hive schemas in the given hadoop cluster'
/

COMMENT ON  COLUMN DBA_HIVE_DATABASES.DATABASE_NAME is 'Hive database'
/

COMMENT ON  COLUMN DBA_HIVE_DATABASES.DESCRIPTION is 'Description of hive database'
/

COMMENT ON  COLUMN DBA_HIVE_DATABASES.DB_LOCATION is 'Physical location of hive database'
/

COMMENT ON  COLUMN DBA_HIVE_DATABASES.CLUSTER_ID is 'User supplied identifier for this hive metastore'
/

COMMENT ON  COLUMN DBA_HIVE_DATABASES.HIVE_URI is 'The connection string (URI and port no) for metastore db'
/


CREATE  OR REPLACE PUBLIC SYNONYM DBA_HIVE_DATABASES FOR DBA_HIVE_DATABASES
/

GRANT SELECT ON DBA_HIVE_DATABASES TO SELECT_CATALOG_ROLE
/


EXECUTE CDBView.create_cdbview(false, 'SYS', 'DBA_HIVE_DATABASES', 'CDB_HIVE_DATABASES');

grant select on SYS.CDB_HIVE_DATABASES to select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM CDB_HIVE_DATABASES for SYS.CDB_HIVE_DATABASES
/


--
-- USER_HIVE_DATABASES
--

CREATE  OR REPLACE VIEW USER_HIVE_DATABASES
AS SELECT M.* FROM DBA_HIVE_DATABASES M, SYS.USER$ U
WHERE U.user# = USERENV('SCHEMAID') AND
-- Current user has system privileges
      ((
        ora_check_sys_privilege(U.user#, 2) = 1
       )
       OR
-- If current user is neither SYS nor DBA, then do the following checks
-- User must have read privilege on ORACLE_BIGDATA_CONFIG directory 
      (((U.NAME IN (SELECT GRANTEE FROM
                               ALL_TAB_PRIVS
                               WHERE TABLE_NAME = 'ORACLE_BIGDATA_CONFIG' AND
                                     PRIVILEGE = 'READ')) OR
        ('PUBLIC' IN (SELECT GRANTEE FROM
                               ALL_TAB_PRIVS
                               WHERE TABLE_NAME = 'ORACLE_BIGDATA_CONFIG' AND
                                     PRIVILEGE = 'READ')))))
/



COMMENT ON  TABLE USER_HIVE_DATABASES is 'All hive schemas in the given hadoop cluster'
/

COMMENT ON  COLUMN USER_HIVE_DATABASES.DATABASE_NAME is 'Hive database'
/

COMMENT ON  COLUMN USER_HIVE_DATABASES.DESCRIPTION is 'Description of hive database'
/

COMMENT ON  COLUMN USER_HIVE_DATABASES.DB_LOCATION is 'Physical location of hive database'
/

COMMENT ON  COLUMN USER_HIVE_DATABASES.CLUSTER_ID is 'User supplied identifier for this hive metastore'
/  

COMMENT ON  COLUMN USER_HIVE_DATABASES.HIVE_URI is 'The connection string (URI and port no) for metastore db'
/



CREATE  OR REPLACE PUBLIC SYNONYM USER_HIVE_DATABASES FOR USER_HIVE_DATABASES
/

GRANT READ ON USER_HIVE_DATABASES TO PUBLIC WITH GRANT OPTION
/


--
-- ALL_HIVE_DATABASES
--
-- The view, ALL_HIVE_DATABASES, displays information  about those hive 
-- databases the current user can access.  For a user to access a hive table, 
-- the user has READ permission on ORACLE_BIGDATA_CONFIG
-- Therefore, the view ALL_HIVE_DATABASES is identical to the view, USER_HIVE_DATABASES
--

CREATE  OR REPLACE VIEW ALL_HIVE_DATABASES
AS SELECT * FROM USER_HIVE_DATABASES
/


COMMENT ON  TABLE ALL_HIVE_DATABASES is 'All hive schemas in the given hadoop cluster'
/

COMMENT ON  COLUMN ALL_HIVE_DATABASES.DATABASE_NAME is 'Hive database'
/

COMMENT ON  COLUMN ALL_HIVE_DATABASES.DESCRIPTION is 'Description of hive database'
/

COMMENT ON  COLUMN ALL_HIVE_DATABASES.DB_LOCATION is 'Physical location of hive database'
/

COMMENT ON  COLUMN ALL_HIVE_DATABASES.CLUSTER_ID is 'User supplied identifier for this hive metastore'
/

COMMENT ON  COLUMN ALL_HIVE_DATABASES.HIVE_URI is 'The connection string (URI and port no) for metastore db'
/


CREATE  OR REPLACE PUBLIC SYNONYM ALL_HIVE_DATABASES FOR ALL_HIVE_DATABASES
/

GRANT READ ON ALL_HIVE_DATABASES TO PUBLIC WITH GRANT OPTION
/



-------------------------------------------------------------------------------
--                           HIVE_TAB_PARTITIONS
-------------------------------------------------------------------------------
--
-- DBA_HIVE_TAB_PARTITIONS
--
-------------------------------------------------------------------------------
--
-- DBA_HIVE_TAB_PARTITIONS
--

CREATE  OR REPLACE VIEW DBA_HIVE_TAB_PARTITIONS
(
  CLUSTER_ID,                     /* User supplied hive identifier           */
  DATABASE_NAME,                  /* Hive database name                      */
  TABLE_NAME,                     /* Hive table name                         */
  LOCATION,                       /* Location of hive partition              */
  OWNER,                          /* Hive table owner                        */
  PARTITION_SPECS,                /* Partition specifications                */
  PART_SIZE,                      /* Size of partition in bytes              */
  CREATION_TIME                   /* Creation time of hive partition         */
)
AS
SELECT HT.C15 AS CLUSTER_ID,
       HT.C0 AS DATABASE_NAME,
       HT.C1 AS TABLE_NAME,
       HT.C5 AS LOCATION,
       HT.C2 AS OWNER,
--       'P_' || ORA_HASH(HT.C13, 99999) AS PART_NAME,
       HT.C13 AS PARTITION_SPECS,
       HT.C7 AS PART_SIZE,
       DBMS_HADOOP_INTERNAL.UNIX_TS_TO_DATE(HT.C8) AS CREATION_TIME
  FROM
    (SELECT DIRECTORY_PATH AS configDir
     FROM DBA_DIRECTORIES
     WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_CONFIG') HU,
    (SELECT DIRECTORY_PATH AS debugDir
     FROM DBA_DIRECTORIES
     WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_DEBUG'
     UNION ALL
     SELECT 'InvalidDir' FROM DUAL WHERE
           NOT EXISTS (SELECT DIRECTORY_PATH AS debugDir
                       FROM DBA_DIRECTORIES
                       WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_DEBUG')
    ) HV,
     LATERAL(SELECT * FROM 
      TABLE(DBMS_HADOOP_INTERNAL.GetHiveTable(HU.configDir, HV.debugDir,'*', '*', '*', 'TRUE', 4))) HT
/



COMMENT ON  TABLE DBA_HIVE_TAB_PARTITIONS is 'All hive table partitions'
/

COMMENT ON  COLUMN DBA_HIVE_TAB_PARTITIONS.CLUSTER_ID is 'Hadoop cluster name'
/

COMMENT ON  COLUMN DBA_HIVE_TAB_PARTITIONS.DATABASE_NAME is 'Database where hive table resides'
/

COMMENT ON  COLUMN DBA_HIVE_TAB_PARTITIONS.TABLE_NAME is 'Hive table name'
/

COMMENT ON  COLUMN DBA_HIVE_TAB_PARTITIONS.LOCATION is 'Physical location of the hive partition'
/

COMMENT ON  COLUMN DBA_HIVE_TAB_PARTITIONS.OWNER is 'Owner of hive table'
/

COMMENT ON  COLUMN DBA_HIVE_TAB_PARTITIONS.PARTITION_SPECS is 'Spec of the currrent Hive partition'
/

COMMENT ON  COLUMN DBA_HIVE_TAB_PARTITIONS.PART_SIZE is 'Partition size in bytes'
/


CREATE  OR REPLACE PUBLIC SYNONYM DBA_HIVE_TAB_PARTITIONS FOR DBA_HIVE_TAB_PARTITIONS
/

GRANT SELECT ON DBA_HIVE_TAB_PARTITIONS TO select_catalog_role
/

EXECUTE CDBView.create_cdbview(false, 'SYS', 'DBA_HIVE_TAB_PARTITIONS', 'CDB_HIVE_TAB_PARTITIONS');

grant select on SYS.CDB_HIVE_TAB_PARTITIONS to select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM CDB_HIVE_TAB_PARTITIONS for SYS.CDB_HIVE_TAB_PARTITIONS
/


--
-- USER_HIVE_TAB_PARTITIONS
--

CREATE  OR REPLACE VIEW USER_HIVE_TAB_PARTITIONS
AS SELECT M.* FROM DBA_HIVE_TAB_PARTITIONS M, SYS.USER$ U
WHERE U.user# = USERENV('SCHEMAID') AND
-- Current user has system privileges
      ((
        ora_check_sys_privilege(U.user#, 2) = 1
       )
       OR
-- If current user is neither SYS nor DBA, then do the following checks
-- User must have read privilege on ORACLE_BIGDATA_CONFIG directory
      (((U.NAME IN (SELECT GRANTEE FROM
                               ALL_TAB_PRIVS
                               WHERE TABLE_NAME = 'ORACLE_BIGDATA_CONFIG' AND
                                     PRIVILEGE = 'READ')) OR
        ('PUBLIC' IN (SELECT GRANTEE FROM
                               ALL_TAB_PRIVS
                               WHERE TABLE_NAME = 'ORACLE_BIGDATA_CONFIG' AND
                                     PRIVILEGE = 'READ')))))
/


COMMENT ON  TABLE USER_HIVE_TAB_PARTITIONS is 'All hive table partitions'
/

COMMENT ON  COLUMN USER_HIVE_TAB_PARTITIONS.CLUSTER_ID is 'Hadoop cluster name'
/

COMMENT ON  COLUMN USER_HIVE_TAB_PARTITIONS.DATABASE_NAME is 'Database where hive table resides'
/

COMMENT ON  COLUMN USER_HIVE_TAB_PARTITIONS.TABLE_NAME is 'Hive table name'
/

COMMENT ON  COLUMN USER_HIVE_TAB_PARTITIONS.LOCATION is 'Physical location of the hive partition'
/

COMMENT ON  COLUMN USER_HIVE_TAB_PARTITIONS.OWNER is 'Owner of hive table'
/

COMMENT ON  COLUMN USER_HIVE_TAB_PARTITIONS.PARTITION_SPECS is 'Spec of the currrent Hive partition'
/

COMMENT ON  COLUMN USER_HIVE_TAB_PARTITIONS.PART_SIZE is 'Partition size in bytes'
/


CREATE  OR REPLACE PUBLIC SYNONYM USER_HIVE_TAB_PARTITIONS FOR USER_HIVE_TAB_PARTITIONS
/

GRANT READ ON USER_HIVE_TAB_PARTITIONS TO PUBLIC WITH GRANT OPTION
/


--
-- ALL_HIVE_TAB_PARTITIONS
--
-- The view, ALL_HIVE_TAB_PARTITIONS, displays information about those hive tables partitions
-- the current user can access. For a user to access a hive table, 
-- the user has READ permission on ORACLE_BIGDATA_CONFIG
-- Therefore, the view ALL_HIVE_TAB_PARTITIONS is identical to the view, USER_HIVE_TAB_PARTITIONS
--

CREATE  OR REPLACE VIEW ALL_HIVE_TAB_PARTITIONS
AS SELECT * FROM USER_HIVE_TAB_PARTITIONS
/


COMMENT ON  TABLE ALL_HIVE_TAB_PARTITIONS is 'All hive table partitions'
/

COMMENT ON  COLUMN ALL_HIVE_TAB_PARTITIONS.CLUSTER_ID is 'Hadoop cluster name'
/

COMMENT ON  COLUMN ALL_HIVE_TAB_PARTITIONS.DATABASE_NAME is 'Database where hive table resides'
/

COMMENT ON  COLUMN ALL_HIVE_TAB_PARTITIONS.TABLE_NAME is 'Hive table name'
/

COMMENT ON  COLUMN ALL_HIVE_TAB_PARTITIONS.LOCATION is 'Physical location of the hive partition'
/

COMMENT ON  COLUMN ALL_HIVE_TAB_PARTITIONS.OWNER is 'Owner of hive table'
/

COMMENT ON  COLUMN ALL_HIVE_TAB_PARTITIONS.PARTITION_SPECS is 'Spec of the currrent Hive partition'
/

COMMENT ON  COLUMN ALL_HIVE_TAB_PARTITIONS.PART_SIZE is 'Partition size in bytes'
/


CREATE  OR REPLACE PUBLIC SYNONYM ALL_HIVE_TAB_PARTITIONS FOR ALL_HIVE_TAB_PARTITIONS
/

GRANT READ ON ALL_HIVE_TAB_PARTITIONS TO PUBLIC WITH GRANT OPTION
/


-------------------------------------------------------------------------------
--                           HIVE_PART_KEY_COLUMNS
-------------------------------------------------------------------------------
--
-- DBA_HIVE_PART_KEY_COLUMNS
--

CREATE  OR REPLACE VIEW DBA_HIVE_PART_KEY_COLUMNS
(
  CLUSTER_ID,                     /* User supplied hive identifier           */
  DATABASE_NAME,                  /* Hive database name                      */
  TABLE_NAME,                     /* Hive table name                         */
  OWNER,                          /* Hive table owner                        */
  COLUMN_NAME,                    /* Hive column name                        */
  COLUMN_TYPE,                    /* Hive column type                        */
  COLUMN_POSITION,                /* Position of the column within the 
                                     partitioning key                        */
  ORACLE_COLUMN_TYPE              /* Equivalent oracle column type           */
)
AS
SELECT HT.C15 AS CLUSTER_ID,
       HT.C0 AS DATABASE_NAME,
       HT.C1 AS TABLE_NAME,
       HT.C2 AS OWNER,
       HT.C4 AS COLUMN_NAME,
       HT.C5 AS COLUMN_TYPE,
       HT.C8 AS COLUMN_POSITION,
       HT.C10 AS ORACLE_COLUMN_TYPE
  FROM
    (SELECT DIRECTORY_PATH AS configDir
     FROM DBA_DIRECTORIES
     WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_CONFIG') HU,
    (SELECT DIRECTORY_PATH AS debugDir
     FROM DBA_DIRECTORIES
     WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_DEBUG'
     UNION ALL
     SELECT 'InvalidDir' FROM DUAL WHERE
           NOT EXISTS (SELECT DIRECTORY_PATH AS debugDir
                       FROM DBA_DIRECTORIES
                       WHERE UPPER(DIRECTORY_NAME) = 'ORACLE_BIGDATA_DEBUG')
    ) HV,
     LATERAL(SELECT * FROM 
             TABLE(DBMS_HADOOP_INTERNAL.GetHiveTable(HU.configDir,  HV.debugDir, '*', '*', '*', 'TRUE', 5))) HT
/



COMMENT ON  TABLE DBA_HIVE_PART_KEY_COLUMNS is 'DBA hive table partition columns'
/

COMMENT ON  COLUMN DBA_HIVE_PART_KEY_COLUMNS.CLUSTER_ID is 'Hadoop cluster name'
/

COMMENT ON  COLUMN DBA_HIVE_PART_KEY_COLUMNS.DATABASE_NAME is 'Database where hive table resides'
/

COMMENT ON  COLUMN DBA_HIVE_PART_KEY_COLUMNS.TABLE_NAME is 'Hive table name'
/

COMMENT ON  COLUMN DBA_HIVE_PART_KEY_COLUMNS.OWNER is 'Owner of hive table'
/

COMMENT ON  COLUMN DBA_HIVE_PART_KEY_COLUMNS.COLUMN_NAME is 'Partition column name'
/

COMMENT ON  COLUMN DBA_HIVE_PART_KEY_COLUMNS.COLUMN_TYPE is 'Partition column type'
/

COMMENT ON  COLUMN DBA_HIVE_PART_KEY_COLUMNS.COLUMN_POSITION is 'Partition column position'
/


CREATE  OR REPLACE PUBLIC SYNONYM DBA_HIVE_PART_KEY_COLUMNS FOR DBA_HIVE_PART_KEY_COLUMNS
/

GRANT SELECT ON DBA_HIVE_PART_KEY_COLUMNS TO select_catalog_role
/

EXECUTE CDBView.create_cdbview(false, 'SYS', 'DBA_HIVE_PART_KEY_COLUMNS', 'CDB_HIVE_PART_KEY_COLUMNS');

grant select on SYS.CDB_HIVE_PART_KEY_COLUMNS to select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM CDB_HIVE_PART_KEY_COLUMNS for SYS.CDB_HIVE_PART_KEY_COLUMNS
/


--
-- USER_HIVE_PART_KEY_COLUMNS
--

CREATE  OR REPLACE VIEW USER_HIVE_PART_KEY_COLUMNS
AS SELECT M.* FROM DBA_HIVE_PART_KEY_COLUMNS M, SYS.USER$ U
WHERE U.user# = USERENV('SCHEMAID') AND
-- Current user has system privileges
      ((
        ora_check_sys_privilege(U.user#, 2) = 1
       )
       OR
-- If current user is neither SYS nor DBA, then do the following checks
-- User must have read privilege on ORACLE_BIGDATA_CONFIG directory
      (((U.NAME IN (SELECT GRANTEE FROM
                               ALL_TAB_PRIVS
                               WHERE TABLE_NAME = 'ORACLE_BIGDATA_CONFIG' AND
                                     PRIVILEGE = 'READ')) OR
        ('PUBLIC' IN (SELECT GRANTEE FROM
                               ALL_TAB_PRIVS
                               WHERE TABLE_NAME = 'ORACLE_BIGDATA_CONFIG' AND
                                     PRIVILEGE = 'READ')))))
/


COMMENT ON  TABLE USER_HIVE_PART_KEY_COLUMNS is 'USER hive table partition columns'
/

COMMENT ON  COLUMN USER_HIVE_PART_KEY_COLUMNS.CLUSTER_ID is 'Hadoop cluster name'
/

COMMENT ON  COLUMN USER_HIVE_PART_KEY_COLUMNS.DATABASE_NAME is 'Database where hive table resides'
/

COMMENT ON  COLUMN USER_HIVE_PART_KEY_COLUMNS.TABLE_NAME is 'Hive table name'
/

COMMENT ON  COLUMN USER_HIVE_PART_KEY_COLUMNS.OWNER is 'Owner of hive table'
/

COMMENT ON  COLUMN USER_HIVE_PART_KEY_COLUMNS.COLUMN_NAME is 'Partition column name'
/

COMMENT ON  COLUMN USER_HIVE_PART_KEY_COLUMNS.COLUMN_TYPE is 'Partition column type'
/

COMMENT ON  COLUMN USER_HIVE_PART_KEY_COLUMNS.COLUMN_POSITION is 'Partition column position'
/


CREATE  OR REPLACE PUBLIC SYNONYM USER_HIVE_PART_KEY_COLUMNS FOR USER_HIVE_PART_KEY_COLUMNS
/

GRANT READ ON USER_HIVE_PART_KEY_COLUMNS TO PUBLIC WITH GRANT OPTION
/



CREATE  OR REPLACE VIEW ALL_HIVE_PART_KEY_COLUMNS
AS SELECT * FROM USER_HIVE_PART_KEY_COLUMNS
/


COMMENT ON  TABLE ALL_HIVE_PART_KEY_COLUMNS is 'ALL hive table partition columns'
/

COMMENT ON  COLUMN ALL_HIVE_PART_KEY_COLUMNS.CLUSTER_ID is 'Hadoop cluster name'
/

COMMENT ON  COLUMN ALL_HIVE_PART_KEY_COLUMNS.DATABASE_NAME is 'Database where hive table resides'
/

COMMENT ON  COLUMN ALL_HIVE_PART_KEY_COLUMNS.TABLE_NAME is 'Hive table name'
/ 

COMMENT ON  COLUMN ALL_HIVE_PART_KEY_COLUMNS.OWNER is 'Owner of hive table'
/ 

COMMENT ON  COLUMN ALL_HIVE_PART_KEY_COLUMNS.COLUMN_NAME is 'Partition column name'
/ 

COMMENT ON  COLUMN ALL_HIVE_PART_KEY_COLUMNS.COLUMN_TYPE is 'Partition column type'
/

COMMENT ON  COLUMN ALL_HIVE_PART_KEY_COLUMNS.COLUMN_POSITION is 'Partition column position'
/


CREATE  OR REPLACE PUBLIC SYNONYM ALL_HIVE_PART_KEY_COLUMNS FOR ALL_HIVE_PART_KEY_COLUMNS
/

GRANT READ ON ALL_HIVE_PART_KEY_COLUMNS TO PUBLIC WITH GRANT OPTION
/




-------------------------------------------------------------------------------
--                           XT_HIVE_TABLES_VALIDATION
-------------------------------------------------------------------------------
--
-- DBA_XT_HIVE_TABLES_VALIDATION 
--

--

CREATE  OR REPLACE VIEW DBA_XT_HIVE_TABLES_VALIDATION
(
  CLUSTER_ID,                     /* User supplied hive identifier           */
  DATABASE_NAME,                  /* Hive database name                      */
  HIVE_TABLE_NAME,                /* Hive table name                         */
  TABLE_NAME,                     /* External table name                     */
  TABLE_OWNER,                    /* External table owner                    */
  METADATA_COMPATIBLE,            /* Has Hive table changed?                 */
  HIVE_XT_INCOMPATIBILITY,        /* First error encountered, if any         */
  PARTITION_COMPATIBLE,           /* Need to sync XT partitions?             */
  PARTITIONS_ADDED,               /* New partitions on Hive table            */
  PARTITIONS_DROPPED,             /* XT partitions not in Hive               */
  LAST_SYNC_TIME                  /* Timestamp of last sync                  */
)
AS
SELECT HI.CLUSTER_ID AS CLUSTER_ID,
       HI.DB_NAME AS DATABASE_NAME,
       HI.HIVE_TABLE_NAME AS HIVE_TABLE_NAME,
       HI.XT_NAME AS TABLE_NAME,
       HI.XT_OWNER AS TABLE_OWNER,
       DBMS_HADOOP_INTERNAL.IS_METADATA_COMPATIBLE(HI.CLUSTER_ID, HI.DB_NAME, 
                                HI.HIVE_TABLE_NAME, HI.XT_NAME, HI.XT_OWNER),
       DBMS_HADOOP_INTERNAL.GET_INCOMPATIBILITY(HI.CLUSTER_ID, 
                    HI.DB_NAME, HI.HIVE_TABLE_NAME, HI.XT_NAME, HI.XT_OWNER),
       DBMS_HADOOP_INTERNAL.IS_PARTITION_COMPATIBLE('TRUE',
          DBMS_HADOOP_INTERNAL.ADDED_PARTNS(HI.CLUSTER_ID, HI.DB_NAME, 
             HI.HIVE_TABLE_NAME, HI.XT_NAME, HI.XT_OWNER, 'TRUE'),
       DBMS_HADOOP_INTERNAL.DROPPED_PARTNS(HI.CLUSTER_ID, HI.DB_NAME, 
             HI.HIVE_TABLE_NAME, HI.XT_NAME, HI.XT_OWNER, 'TRUE')),
       DBMS_HADOOP_INTERNAL.ADDED_HIVE_PARTNS(HI.CLUSTER_ID, HI.DB_NAME, 
             HI.HIVE_TABLE_NAME, 
             DBMS_HADOOP_INTERNAL.ADDED_PARTNS(HI.CLUSTER_ID, HI.DB_NAME, 
               HI.HIVE_TABLE_NAME, HI.XT_NAME, HI.XT_OWNER, 'TRUE'), 'TRUE'),
       DBMS_HADOOP_INTERNAL.DROPPED_PARTNS(HI.CLUSTER_ID, HI.DB_NAME, 
             HI.HIVE_TABLE_NAME, HI.XT_NAME, HI.XT_OWNER, 'TRUE'),
       HI.MTIME AS LAST_SYNC_TIME
  FROM
  -- Extract CLUSTER_ID, DB_NAME and HIVE_TABLE_NAME from EXTERNAL_TAB$.
  -- Note that this assumes that PARAM_CLOB will not change its format
  -- in the future. If the format changes, tests in lrgxadp4 will break.
  --
     (SELECT ET.obj# AS OBJNO, O.NAME AS XT_NAME, U.NAME AS XT_OWNER, 
             O.MTIME AS MTIME,
           DBMS_LOB.SUBSTR(SUBSTR(ET.param_clob, INSTR(ET.param_clob, '=', 1, 1)+1,
             INSTR(ET.param_clob, 'com', 1, 2)-1 - INSTR(ET.param_clob, '=', 1, 1)-1), 
                      4000, 1) AS CLUSTER_ID,
           DBMS_LOB.SUBSTR(SUBSTR(ET.param_clob, INSTR(ET.param_clob, '=', 1, 2)+1, 
                      INSTR(ET.param_clob, '.', INSTR(ET.param_clob, '=', 1, 2)+1)-1
                      - INSTR(ET.param_clob, '=', 1, 2)), 4000, 1) AS DB_NAME,
           DBMS_LOB.SUBSTR(SUBSTR(ET.param_clob, INSTR(ET.param_clob, '.', -1, 1)+1), 
                      4000, 1) AS HIVE_TABLE_NAME
      FROM EXTERNAL_TAB$ ET, OBJ$ O, USER$ U
         WHERE ET.TYPE$ = 'ORACLE_HIVE' AND
               ET.OBJ# IN (SELECT bo# FROM TABPART$) AND
               ET.OBJ# = O.OBJ# AND
               O.OWNER# = U.USER# ORDER BY OBJNO) HI
/

COMMENT ON  TABLE DBA_XT_HIVE_TABLES_VALIDATION is 'DBA hive tables validation'
/


COMMENT ON COLUMN DBA_XT_HIVE_TABLES_VALIDATION.CLUSTER_ID is 'Hadoop cluster name'
/


COMMENT ON COLUMN DBA_XT_HIVE_TABLES_VALIDATION.DATABASE_NAME is 'Database where hive table resides'
/


COMMENT ON COLUMN DBA_XT_HIVE_TABLES_VALIDATION.TABLE_NAME is 'External table name'
/


COMMENT ON COLUMN DBA_XT_HIVE_TABLES_VALIDATION.TABLE_OWNER is 'Owner of external table'
/


COMMENT ON COLUMN DBA_XT_HIVE_TABLES_VALIDATION.METADATA_COMPATIBLE is 'Is XT metadata compatible with Hive'
/


COMMENT ON COLUMN DBA_XT_HIVE_TABLES_VALIDATION.HIVE_XT_INCOMPATIBILITY is 'First error encountered, if any'
/


COMMENT ON COLUMN DBA_XT_HIVE_TABLES_VALIDATION.PARTITION_COMPATIBLE is 'Need to sync XT partitions?'
/


COMMENT ON COLUMN DBA_XT_HIVE_TABLES_VALIDATION.PARTITIONS_ADDED is 'New partitions on Hive table'
/


COMMENT ON COLUMN DBA_XT_HIVE_TABLES_VALIDATION.PARTITIONS_DROPPED is 'XT partitions non in Hive'
/


COMMENT ON COLUMN DBA_XT_HIVE_TABLES_VALIDATION.LAST_SYNC_TIME is 'Timestamp of the last sync operation'
/


CREATE  OR REPLACE PUBLIC SYNONYM DBA_XT_HIVE_TABLES_VALIDATION FOR DBA_XT_HIVE_TABLES_VALIDATION
/


GRANT SELECT ON DBA_XT_HIVE_TABLES_VALIDATION TO select_catalog_role
/

EXECUTE CDBView.create_cdbview(false, 'SYS', 'DBA_XT_HIVE_TABLES_VALIDATION', 'CDB_XT_HIVE_TABLES_VALIDATION');

grant select on SYS.CDB_XT_HIVE_TABLES_VALIDATION to select_catalog_role
/

CREATE OR REPLACE PUBLIC SYNONYM CDB_XT_HIVE_TABLES_VALIDATION for SYS.CDB_XT_HIVE_TABLES_VALIDATION
/


--
-- USER_XT_HIVE_TABLES_VALIDATION
--

CREATE  OR REPLACE VIEW USER_XT_HIVE_TABLES_VALIDATION
AS SELECT M.* FROM DBA_XT_HIVE_TABLES_VALIDATION M, SYS.USER$ U
WHERE U.user# = USERENV('SCHEMAID') AND
-- Current user has system privileges
      ((
        ora_check_sys_privilege(U.user#, 2) = 1
       )
       OR
-- If current user is neither SYS nor DBA, then do the following checks
-- User must have read privilege on ORACLE_BIGDATA_CONFIG directory
      (((U.NAME IN (SELECT GRANTEE FROM
                               ALL_TAB_PRIVS
                               WHERE TABLE_NAME = 'ORACLE_BIGDATA_CONFIG' AND
                                     PRIVILEGE = 'READ')) OR
        ('PUBLIC' IN (SELECT GRANTEE FROM
                               ALL_TAB_PRIVS
                               WHERE TABLE_NAME = 'ORACLE_BIGDATA_CONFIG' AND
                                     PRIVILEGE = 'READ')))))
/


COMMENT ON TABLE USER_XT_HIVE_TABLES_VALIDATION is 'USER hive tables validation' 
/


COMMENT ON COLUMN USER_XT_HIVE_TABLES_VALIDATION.CLUSTER_ID is 'Hadoop cluster name'
/


COMMENT ON COLUMN USER_XT_HIVE_TABLES_VALIDATION.DATABASE_NAME is 'Database where hive table resides'
/


COMMENT ON COLUMN USER_XT_HIVE_TABLES_VALIDATION.TABLE_NAME is 'External table name'
/


COMMENT ON COLUMN USER_XT_HIVE_TABLES_VALIDATION.TABLE_OWNER is 'Owner of external table'
/


COMMENT ON COLUMN USER_XT_HIVE_TABLES_VALIDATION.METADATA_COMPATIBLE is 'Is XT metadata compatible with Hive'
/


COMMENT ON COLUMN USER_XT_HIVE_TABLES_VALIDATION.HIVE_XT_INCOMPATIBILITY is 'First error encountered, if any'
/


COMMENT ON COLUMN USER_XT_HIVE_TABLES_VALIDATION.PARTITION_COMPATIBLE is 'Need to sync XT partitions?'
/


COMMENT ON COLUMN USER_XT_HIVE_TABLES_VALIDATION.PARTITIONS_ADDED is 'New partitions on Hive table'
/


COMMENT ON COLUMN USER_XT_HIVE_TABLES_VALIDATION.PARTITIONS_DROPPED is 'XT partitions non in Hive'
/


COMMENT ON COLUMN USER_XT_HIVE_TABLES_VALIDATION.LAST_SYNC_TIME is 'Timestamp of the last sync operation'
/


CREATE  OR REPLACE PUBLIC SYNONYM USER_XT_HIVE_TABLES_VALIDATION FOR USER_XT_HIVE_TABLES_VALIDATION
/


GRANT READ ON USER_XT_HIVE_TABLES_VALIDATION TO PUBLIC WITH GRANT OPTION
/



CREATE OR REPLACE VIEW ALL_XT_HIVE_TABLES_VALIDATION
AS SELECT * FROM USER_XT_HIVE_TABLES_VALIDATION
/


COMMENT ON TABLE ALL_XT_HIVE_TABLES_VALIDATION is 'ALL hive tables validation' 
/


COMMENT ON COLUMN ALL_XT_HIVE_TABLES_VALIDATION.CLUSTER_ID is 'Hadoop cluster name'
/


COMMENT ON COLUMN ALL_XT_HIVE_TABLES_VALIDATION.DATABASE_NAME is 'Database where hive table resides'
/


COMMENT ON COLUMN ALL_XT_HIVE_TABLES_VALIDATION.TABLE_NAME is 'External table name'
/


COMMENT ON COLUMN ALL_XT_HIVE_TABLES_VALIDATION.TABLE_OWNER is 'Owner of external table'
/


COMMENT ON COLUMN ALL_XT_HIVE_TABLES_VALIDATION.METADATA_COMPATIBLE is 'Is XT metadata compatible with Hive'
/



COMMENT ON COLUMN ALL_XT_HIVE_TABLES_VALIDATION.HIVE_XT_INCOMPATIBILITY is 'First error encountered, if any'
/


COMMENT ON COLUMN ALL_XT_HIVE_TABLES_VALIDATION.PARTITION_COMPATIBLE is 'Need to sync XT partitions?'
/


COMMENT ON COLUMN ALL_XT_HIVE_TABLES_VALIDATION.PARTITIONS_ADDED is 'New partitions on Hive table'
/


COMMENT ON COLUMN ALL_XT_HIVE_TABLES_VALIDATION.PARTITIONS_DROPPED is 'XT partitions non in Hive'
/


COMMENT ON COLUMN ALL_XT_HIVE_TABLES_VALIDATION.LAST_SYNC_TIME is 'Timestamp of the last sync operation'
/


CREATE OR REPLACE PUBLIC SYNONYM ALL_XT_HIVE_TABLES_VALIDATION FOR ALL_XT_HIVE_TABLES_VALIDATION
/


GRANT READ ON ALL_XT_HIVE_TABLES_VALIDATION TO PUBLIC WITH GRANT OPTION
/

@?/rdbms/admin/sqlsessend.sql
