set echo on
create view SYSIBM.SYSPLAN
(
NAME,
CREATOR,
BOUNDBY,
VALID,
UNIQUE_ID,
TOTALSECT,
FORMAT,
SECT_INFO,
HOST_VARS,
ISOLATION,
BLOCK,
STANDARDS_LEVEL,
FUNC_PATH,
EXPLICIT_BIND_TIME,
LAST_BIND_TIME,
QUERYOPT,
EXPLAIN_LEVEL,
EXPLAIN_MODE,
EXPLAIN_SNAPSHOT,
SQLWARN,
CODEPAGE,
REMARKS,
SQLRULES,
SQLRULES_STRING,
INSERT_BUF,
DEFINER,
DEFAULT_SCHEMA,
MULTINODE_PLANS,
DEGREE,
RDS_LEVEL,
SQLMATHWARN,
INTRA_PARALLEL,
"VALIDATE",
DYNAMICRULES,
SQLERROR,
REFRESHAGE,
PKG_CREATE_TIME,
FEDERATED,
TRANSFORMGROUP,
TRF_GRP_PACKED_DESC,
PKGVERSION,
REOPTVAR,
OS_PTR_SIZE,
PACKED_DESC,
STATICREADONLY,
FEDERATED_ASYNCHRONY,
DEFINERTYPE,
BOUNDBYTYPE,
OPTPROFILESCHEMA,
OPTPROFILENAME,
COLLATIONID,
COLLATIONID_ORDERBY,
CONCURRENTACCESSRESOLUTION,
PKGID,
DBPARTITIONNUM,
APREUSE,
ALTER_TIME,
ANONBLOCK,
EXTENDEDINDICATOR,
LASTUSED
)
  AS SELECT
    NAME,
    COLLID                                      CREATOR,
    CREATOR                                     BOUNDBY,
    VALID, 
    CONTOKEN                                    UNIQUE_ID,
    PKSIZE                                      TOTALSECT, 
    CAST(' ' AS CHARACTER(1))                   FORMAT,
    TO_BLOB('20')                               SECT_INFO,
    TO_BLOB(NULL)                               HOST_VARS,
    CASE ISOLATION
       WHEN 'R' THEN 'RR'
       WHEN 'C' THEN 'CS'
       WHEN 'N' THEN 'UR'
       WHEN 'G' THEN 'CH' -- You'll never see this, DB2/400 only
       WHEN 'A' THEN 'RS'
       ELSE 'CS'
    END,
    BLOCKING                                    BLOCK,
    CAST(NULL AS CHARACTER(1))                  STANDARDS_LEVEL,
    TO_CLOB(' ')                                FUNC_PATH, 
    LAST_BIND_TIME                              EXPLICIT_BIND_TIME, 
    LAST_BIND_TIME,
    CAST(0 AS INTEGER)                          QUERYOPT,
    CAST(' ' AS CHARACTER(1))                   EXPLAIN_LEVEL,
    CAST(' ' AS CHARACTER(1))                   EXPLAIN_MODE,
    CAST(' ' AS CHARACTER(1))                   EXPLAIN_SNAPSHOT, 
    CAST(' ' AS CHARACTER(1))                   SQLWARN , 
    CODEPAGES                                   CODEPAGE,
    CAST(NULL AS VARCHAR(254))                  REMARKS, 
    CAST(' ' AS CHARACTER(1))                   SQLRULES,
    CAST(' ' AS VARCHAR(254))                   SQLRULES_STRING, 
    CAST(' ' AS CHARACTER(1))                   INSERT_BUF, 
    CAST(' ' AS VARCHAR(128))                   DEFINER,
    QUALIFIER                                   DEFAULT_SCHEMA,
    CAST(' ' AS CHARACTER(1))                   MULTINODE_PLANS,
    CAST(' ' AS CHARACTER(5))                   DEGREE,
    CAST(0 AS SMALLINT)                         RDS_LEVEL,
    CAST(' ' AS CHARACTER(1))                   SQLMATHWARN,
    CAST(' ' AS CHARACTER(1))                   INTRA_PARALLEL,
    CAST(' ' AS CHARACTER(1))                   "VALIDATE",
    DYNAMICRULES,
    CAST(' ' AS CHARACTER(1))                   SQLERROR,
    CAST(0 AS DECIMAL(20, 6))                   REFRESHAGE,
    CREATE_TIME                                 PKG_CREATE_TIME,
    CAST(' ' AS CHARACTER(1))                   FEDERATED,
    CAST(NULL AS VARCHAR(1024))                 TRANSFORMGROUP,
    TO_BLOB(NULL)                               TRF_GRP_PACKED_DESC,
    CAST(VRSNAM AS VARCHAR(64))                 PKGVERSION,
    CAST(' ' AS CHARACTER(1))                   REOPTVAR,
    CAST(8 AS INTEGER)                          OS_PTR_SIZE,
    TO_BLOB(NULL)                               PACKED_DESC,
    CAST(' ' AS CHARACTER(1))                   STATICREADONLY,
    CAST(0 AS INTEGER)                          FEDERATED_ASYNCHRONY,
    CAST(' ' AS CHARACTER(1))                   DEFINERTYPE,
    CAST(' ' AS CHARACTER(1))                   BOUNDBYTYPE,
    CAST(NULL AS VARCHAR(128))                  OPTPROFILESCHEMA,
    CAST(NULL AS VARCHAR(128))                  OPTPROFILENAME,
    CAST('00' AS RAW(8))                        COLLATIONID,
    CAST('00' AS RAW(8))                        COLLATIONID_ORDERBY,
    CAST(NULL AS CHARACTER(1))                  CONCURRENTACCESSRESOLUTION,
    CAST(0 AS DECIMAL(19))                      PKGID,
    CAST(0 AS SMALLINT)                         DBPARTITIONNUM,
    CAST(' ' AS CHARACTER(1))                   APREUSE,
    LAST_BIND_TIME                              ALTER_TIME,
    CAST(' ' AS CHARACTER(1))                   ANONBLOCK,
    CAST(' ' AS CHARACTER(1))                   EXTENDEDINDICATOR,
    CAST(CURRENT_DATE AS DATE)                  LASTUSED
   FROM SYSIBM.USER_DRDAASPACKAGE;
grant SELECT on SYSIBM.SYSPLAN to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSDUMMY1
AS SELECT
  'Y'                                   IBMREQD
  FROM DUAL;
grant SELECT on SYSIBM.SYSDUMMY1 to DRDAAS_USER_ROLE;
commit;
