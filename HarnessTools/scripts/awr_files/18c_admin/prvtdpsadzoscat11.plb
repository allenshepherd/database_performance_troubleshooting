create or replace view SYSIBM.SYSPLAN
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
    END                                         ISOLATION,
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
    CAST(0 AS NUMBER(4))                        RDS_LEVEL,
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
    CAST(0 AS NUMBER(4))                        DBPARTITIONNUM,
    CAST(' ' AS CHARACTER(1))                   APREUSE,
    LAST_BIND_TIME                              ALTER_TIME,
    CAST(' ' AS CHARACTER(1))                   ANONBLOCK,
    CAST(' ' AS CHARACTER(1))                   EXTENDEDINDICATOR,
    CAST(CURRENT_DATE AS DATE)                  LASTUSED
   FROM SYSIBM.USER_DRDAASPACKAGE;
grant SELECT on SYSIBM.SYSPLAN to DRDAAS_USER_ROLE;
create or replace view SYSIBM.SYSPACKAGE
  AS SELECT
    CAST(NULL AS VARCHAR(128))                  LOCATION,
    PA.COLLID,
    PA.NAME,
    PA.CONTOKEN,
    PA.OWNER,
    PA.CREATOR,
    PA.CREATE_TIME                              TIMESTAMP,
    PA.LAST_BIND_TIME                           BINDTIME,
    CAST(' ' AS VARCHAR(128))                   QUALIFIER,
    PA.PKSIZE,
    PA.PKSIZE                                   AVGSIZE,
    CAST(0 AS NUMBER(4))                        SYSENTRIES,
    PA.VALID,
    'Y'                                         OPERATIVE,
    'R'                                         "VALIDATE",
    CASE ISOLATION
       WHEN 'R' THEN 'R'
       WHEN 'C' THEN 'S'
       WHEN 'N' THEN 'U'
       WHEN 'G' THEN 'C' -- You'll never see this, DB2/400 only
       WHEN 'A' THEN 'T'
       ELSE 'S'
    END                                         ISOLATION,
    'C'                                         RELEASE,
    'N'                                         EXPLAIN,
    CASE PA.STRDEL
       WHEN '''' THEN 'N'
       ELSE 'Y'
    END                                         QUOTE,
    CASE PA.DECDEL
       WHEN '.' THEN 'N'
       ELSE 'Y'
    END                                         COMMA,
    ' '                                         HOSTLANG,
    'A'                                         CHARSET,
    'Y'                                         MIXED,
    CASE DECPRC
       WHEN 31 THEN 'Y'
       ELSE 'N'
    END                                         DEC31,
    CASE BLOCKING
       WHEN 'B' THEN 'B'
       WHEN 'F' THEN 'A'
       ELSE 'C'
    END                                         DEFERPREP,
    'C'                                         SQLERROR,
    'Y'                                         REMOTE,
    TO_TIMESTAMP('0001-01-01-00:00:00.000000',
        'YYYY-MM-DD-HH24:MI:SS.FF6')            PCTIMESTAMP,
    'N'                                         IBMREQD,
    CAST(VRSNAM AS VARCHAR(122))                VERSION,
    CAST(' ' AS VARCHAR(132))                   PDSNAME,
    CAST('ANY' AS CHAR(3))                      DEGREE,
    CAST(' ' AS VARCHAR(24))                    GROUP_MEMBER,
    'R'                                         DYNAMICRULES,
    'Y'                                         REOPTVAR,
    'Y'                                         DEFERPREPARE,
    'N'                                         KEEPDYNAMIC,
    CAST(' ' AS VARCHAR(2048))                  PATHSCHEMAS,
    ' '                                         TYPE,
    'D'                                         DBPROTOCOL,
    TO_TIMESTAMP('0001-01-01-00:00:00.000000',
        'YYYY-MM-DD-HH24:MI:SS.FF6')            FUNCTIONTS,
    CAST(' ' AS VARCHAR(128))                   OPTHINT,
    PA.CODEPAGES                                ENCODING_CCSID,
    'N'                                         IMMEDWRITE,
    'M'                                         RELBOUND,
    ' '                                         CATENCODE,
    CAST(' ' AS VARCHAR(550))                   REMARKS,
    ' '                                         OWNERTYPE,
    'E'                                         ROUNDING,
    'N'                                         DISTRIBUTE,
    CAST(CURRENT_DATE AS DATE)                  LASTUSED,
    'Y'                                         CONCUR_ACC_RES,
    'N'                                         EXTENDEDINDICATOR,
    CAST(0 AS NUMBER(9))                        COPYID,
    ' '                                         PLANMGMT,
    ' '                                         PLANMGMTSCOPE,
    'N'                                         APREUSE,
    'Y'                                         APRETAINDUP,
    'N'                                         SYSTIMESENSITIVE,
    'Y'                                         RECORDTEMPORALHIST
   FROM SYSIBM.DBA_DRDAASPACKAGE PA;
grant SELECT on SYSIBM.SYSPACKAGE to DRDAAS_USER_ROLE;
create or replace view SYSIBM.SYSPACKSTMT
  AS SELECT
    CAST(NULL AS VARCHAR(128))                  LOCATION,
    COLLID,
    NAME,
    CONTOKEN,
    CAST(0 AS NUMBER(9))                        SEQNO,
    STMTNO,
    SECTNO,
    CAST('N' AS CHARACTER(1))                   BINDERROR,
    CAST('N' AS CHARACTER(1))                   IBMREQD,
    CAST(VRSNAM AS VARCHAR(122))                VERSION,
    CAST('00' AS RAW(1))                        STMT,
    CAST(' ' AS CHARACTER(1))                   ISOLATION,
    CAST('C' AS CHARACTER(1))                   STATUS,
    CAST(' ' AS CHARACTER(1))                   ACCESSPATH,
    CAST(STMTNO AS NUMBER(9))                   STMTNOI,
    CAST((CASE
       WHEN SECTNO >= 0 THEN SECTNO
       WHEN SECTNO <  0 THEN SECTNO + 65536
    END) AS NUMBER(9))                          SECTNOI,
    CAST('N' AS CHARACTER(1))                   EXPLAINABLE,
    CAST(STMTNO AS NUMBER(9))                   QUERYNO,
    CAST('00' AS RAW(40))                       "ROWID",
    CAST(0 AS NUMBER(19))                       STMT_ID,
    STMT                                        STATEMENT,
    TO_BLOB('00')                               STMTBLOB
   FROM SYSIBM.USER_DRDAASPACKSTMT;
grant SELECT on SYSIBM.SYSPACKSTMT to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSTABLES
AS SELECT
  TA.TABLE_NAME                         NAME,
  TA.OWNER                              CREATOR,
  'T'                                   TYPE,
  CAST ('ORACLE' AS VARCHAR(24))        DBNAME,
  NVL(TABLESPACE_NAME, 'SYSTSTAB')      TSNAME,
  CAST (1 AS NUMBER(4))                 DBID,
  CAST (0 AS NUMBER(4))                 OBID,
  CAST (NVL(CO.MAXCOLS, 0) AS NUMBER(4))COLCOUNT,
  CAST (NULL AS VARCHAR(24))            EDPROC,
  CAST (NULL AS VARCHAR(24))            VALPROC,
  ' '                                   CLUSTERTYPE,
  CAST (0 AS NUMBER(9))                 CLUSTERRID,
  CAST (NVL2(NUM_ROWS,
        CASE WHEN NUM_ROWS > 2147483647 THEN 2147483647
             ELSE NUM_ROWS END, -1) AS NUMBER(10)) CARD,
  CAST (NVL2(BLOCKS,
        CASE WHEN BLOCKS > 2147483647 THEN 2147483647
             ELSE BLOCKS END, -1) AS NUMBER(10)) NPAGES,
  CAST (-1 AS NUMBER(4))                PCTPAGES,
  'N'                                   IBMREQD,
  CAST (TC.COMMENTS AS VARCHAR(762))    REMARKS,
  CAST (NVL(/* RP.PARENTCOUNT */ 0, 0) AS NUMBER(4)) PARENTS,
  CAST (NVL(/* RC.CHILDCOUNT */ 0, 0) AS NUMBER(4)) CHILDREN,
  CAST (NVL(PK.MAXKEYS, 0) AS NUMBER(4))KEYCOLUMNS,
  CAST (1 AS NUMBER(4))                 RECLENGTH,
  ' '                                   STATUS,
  CAST (0 AS NUMBER(4))                 KEYOBID,
  CAST (NULL AS VARCHAR(90))            LABEL,
  ' '                                   CHECKFLAG,
  CAST ('00000000' AS RAW(4))           CHECKRID,
  ' '                                   AUDITING,
  TA.OWNER                              CREATEDBY,
  CAST (NULL AS VARCHAR(128))           LOCATION,
  CAST (NULL AS VARCHAR(128))           TBCREATOR,
  CAST (NULL AS VARCHAR(128))           TBNAME,
  LOCALTIMESTAMP                        CREATEDTS,
  LOCALTIMESTAMP                        ALTEREDTS,
  ' '                                   DATACAPTURE,
  CAST ('000000000000' AS RAW(6))       RBA1,
  CAST ('000000000000' AS RAW(6))       RBA2,
  CAST (-1 AS NUMBER(4))                PCTROWCOMP,
  CAST (NVL(TA.LAST_ANALYZED,
        TO_TIMESTAMP('0001-01-01-00:00:00.000000',
        'YYYY-MM-DD-HH24:MI:SS.FF6'))
        AS TIMESTAMP(6)) STATSTIME,
  CAST (NVL(/* CK.CheckCount */ 0, 0) AS NUMBER(4)) CHECKS,
  CAST (NVL(NUM_ROWS, -1) AS BINARY_DOUBLE) CARDF,
  CAST ('4040404040' AS RAW(5))         CHECKRID5B,
  'U'                                   ENCODING_SCHEME,
  CAST (NULL AS VARCHAR(30))            TABLESTATUS,
  CAST (NVL(BLOCKS, -1) AS BINARY_DOUBLE) NPAGESF,
  CAST (-1 AS BINARY_DOUBLE)            SPACEF,
  CAST (NVL(AVG_ROW_LEN, -1) AS NUMBER(9)) AVGROWLEN,
  'M'                                   RELCREATED,
  CAST (0 AS NUMBER(4))                 NUM_DEP_MQTS,
  CAST (0 AS NUMBER(4))                 VERSION,
  CAST (NVL(TP.PARTITIONING_KEY_COUNT, 0) AS NUMBER(4)) PARTKEYCOLNUM,
  ' '                                   SPLIT_ROWS,
  ' '                                   SECURITY_LABEL,
  TA.OWNER                              OWNER,
  'N'                                   APPEND,
  ' '                                   OWNERTYPE,
  ' '                                   CONTROL,
  CAST (NULL AS VARCHAR(128))           VERSIONING_SCHEMA,
  CAST (NULL AS VARCHAR(128))           VERSIONING_TABLE,
  CAST (0 AS NUMBER(4))                 HASHKEYCOLUMNS
  FROM ALL_TABLES TA
        LEFT OUTER JOIN all_part_tables TP
        ON  TA.OWNER      = TP.OWNER
        AND TA.TABLE_NAME = TP.TABLE_NAME
        LEFT OUTER JOIN (select owner, table_name,
                         max(COLUMN_ID) maxcols
          from all_tab_columns
          where DATA_TYPE_OWNER is NULL
          group by owner, table_name) CO
        ON  TA.OWNER      = CO.OWNER
        AND TA.TABLE_NAME = CO.TABLE_NAME
        LEFT OUTER JOIN (select cn.owner, cn.table_name,
                         max(cc.POSITION) maxkeys
          from all_constraints cn, ALL_CONS_COLUMNS cc
          where cn.owner           = cc.owner
            and cn.CONSTRAINT_NAME = cc.CONSTRAINT_NAME
            and cn.table_name      = cc.table_name
            and cn.CONSTRAINT_TYPE = 'P'
          group by cn.owner, cn.table_name) PK
        ON  TA.OWNER      = PK.OWNER
        AND TA.TABLE_NAME = PK.TABLE_NAME,
        ALL_TAB_COMMENTS TC
     WHERE TA.OWNER      = TC.OWNER
       AND TA.TABLE_NAME = TC.TABLE_NAME
UNION ALL
SELECT
  VW.VIEW_NAME                          NAME,
  VW.OWNER                              CREATOR,
  'V'                                   TYPE,
  CAST ('ORACLE' AS VARCHAR(24))        DBNAME,
  CAST ('SYSTSTAB' AS VARCHAR(30))      TSNAME,
  CAST (1 AS NUMBER(4))                 DBID,
  CAST (0 AS NUMBER(4))                 OBID,
  CAST (NVL(CO.MAXCOLS, 0) AS NUMBER(4))COLCOUNT,
  CAST (NULL AS VARCHAR(24))            EDPROC,
  CAST (NULL AS VARCHAR(24))            VALPROC,
  ' '                                   CLUSTERTYPE,
  CAST (0 AS NUMBER(9))                 CLUSTERRID,
  CAST (-1 AS NUMBER(10))               CARD,
  CAST (-1 AS NUMBER(10))               NPAGES,
  CAST (-1 AS NUMBER(4))                PCTPAGES,
  'N'                                   IBMREQD,
  CAST (TC.COMMENTS AS VARCHAR(762))    REMARKS,
  CAST (NVL(/* RP.PARENTCOUNT */ 0, 0) AS NUMBER(4)) PARENTS,
  CAST (NVL(/* RC.CHILDCOUNT */ 0, 0) AS NUMBER(4)) CHILDREN,
  CAST (NVL(PK.MAXKEYS, 0) AS NUMBER(4))KEYCOLUMNS,
  CAST (0 AS NUMBER(4))                 RECLENGTH,
  ' '                                   STATUS,
  CAST (0 AS NUMBER(4))                 KEYOBID,
  CAST (NULL AS VARCHAR(90))            LABEL,
  ' '                                   CHECKFLAG,
  CAST ('00000000' AS RAW(4))           CHECKRID,
  ' '                                   AUDITING,
  VW.OWNER                              CREATEDBY,
  CAST (NULL AS VARCHAR(128))           LOCATION,
  CAST (NULL AS VARCHAR(128))           TBCREATOR,
  CAST (NULL AS VARCHAR(128))           TBNAME,
  LOCALTIMESTAMP                        CREATEDTS,
  LOCALTIMESTAMP                        ALTEREDTS,
  ' '                                   DATACAPTURE,
  CAST ('000000000000' AS RAW(6))       RBA1,
  CAST ('000000000000' AS RAW(6))       RBA2,
  CAST (-1 AS NUMBER(4))                PCTROWCOMP,
  TO_TIMESTAMP('0001-01-01-00:00:00.000000',
        'YYYY-MM-DD-HH24:MI:SS.FF6')    STATSTIME,
  CAST (NVL(/* CK.CheckCount */ 0, 0) AS NUMBER(4)) CHECKS,
  CAST (-1 AS BINARY_DOUBLE)            CARDF,
  CAST ('4040404040' AS RAW(5))         CHECKRID5B,
  'U'                                   ENCODING_SCHEME,
  CAST (NULL AS VARCHAR(30))            TABLESTATUS,
  CAST (-1 AS BINARY_DOUBLE)            NPAGESF,
  CAST (-1 AS BINARY_DOUBLE)            SPACEF,
  CAST (-1 AS NUMBER(9))                AVGROWLEN,
  'M'                                   RELCREATED,
  CAST (0 AS NUMBER(4))                 NUM_DEP_MQTS,
  CAST (0 AS NUMBER(4))                 VERSION,
  CAST (0 AS NUMBER(4))                 PARTKEYCOLNUM,
  ' '                                   SPLIT_ROWS,
  ' '                                   SECURITY_LABEL,
  VW.OWNER                              OWNER,
  'N'                                   APPEND,
  ' '                                   OWNERTYPE,
  ' '                                   CONTROL,
  CAST (NULL AS VARCHAR(128))           VERSIONING_SCHEMA,
  CAST (NULL AS VARCHAR(128))           VERSIONING_TABLE,
  CAST (0 AS NUMBER(4))                 HASHKEYCOLUMNS
  FROM ALL_VIEWS VW
        LEFT OUTER JOIN (select owner, table_name,
                         max(COLUMN_ID) maxcols
          from all_tab_columns
          where DATA_TYPE_OWNER is NULL
          group by owner, table_name) CO
        ON  VW.OWNER     = CO.OWNER
        AND VW.VIEW_NAME = CO.TABLE_NAME
        LEFT OUTER JOIN (select cn.owner, cn.table_name,
                         max(cc.POSITION) maxkeys
          from all_constraints cn, ALL_CONS_COLUMNS cc
          where cn.owner           = cc.owner
            and cn.CONSTRAINT_NAME = cc.CONSTRAINT_NAME
            and cn.table_name      = cc.table_name
            and cn.CONSTRAINT_TYPE = 'P'
          group by cn.owner, cn.table_name) PK
        ON  VW.OWNER     = PK.OWNER
        AND VW.VIEW_NAME = PK.TABLE_NAME,
        ALL_TAB_COMMENTS TC
     WHERE  VW.OWNER     = TC.OWNER
        AND VW.VIEW_NAME = TC.TABLE_NAME
UNION ALL
SELECT
  SN.SYNONYM_NAME                       NAME,
  SN.OWNER                              CREATOR,
  'A'                                   TYPE,
  CAST ('ORACLE' AS VARCHAR(24))        DBNAME,
  CAST ('SYSTSTAB' AS VARCHAR(30))      TSNAME,
  CAST (1 AS NUMBER(4))                 DBID,
  CAST (0 AS NUMBER(4))                 OBID,
  CAST (0 AS NUMBER(4))                 COLCOUNT,
  CAST (NULL AS VARCHAR(24))            EDPROC,
  CAST (NULL AS VARCHAR(24))            VALPROC,
  ' '                                   CLUSTERTYPE,
  CAST (0 AS NUMBER(9))                 CLUSTERRID,
  CAST (-1 AS NUMBER(10))               CARD,
  CAST (-1 AS NUMBER(10))               NPAGES,
  CAST (-1 AS NUMBER(4))                PCTPAGES,
  'N'                                   IBMREQD,
  CAST (NULL AS VARCHAR(762))           REMARKS,
  CAST (0 AS NUMBER(4))                 PARENTS,
  CAST (0 AS NUMBER(4))                 CHILDREN,
  CAST (0 AS NUMBER(4))                 KEYCOLUMNS,
  CAST (0 AS NUMBER(4))                 RECLENGTH,
  ' '                                   STATUS,
  CAST (0 AS NUMBER(4))                 KEYOBID,
  CAST (NULL AS VARCHAR(90))            LABEL,
  ' '                                   CHECKFLAG,
  CAST ('00000000' AS RAW(4))           CHECKRID,
  ' '                                   AUDITING,
  SN.OWNER                              CREATEDBY,
  DB_LINK                               LOCATION,
  TABLE_OWNER                           TBCREATOR,
  TABLE_NAME                            TBNAME,
  LOCALTIMESTAMP                        CREATEDTS,
  LOCALTIMESTAMP                        ALTEREDTS,
  ' '                                   DATACAPTURE,
  CAST ('000000000000' AS RAW(6))       RBA1,
  CAST ('000000000000' AS RAW(6))       RBA2,
  CAST (-1 AS NUMBER(4))                PCTROWCOMP,
  TO_TIMESTAMP('0001-01-01-00:00:00.000000',
        'YYYY-MM-DD-HH24:MI:SS.FF6')    STATSTIME,
  CAST (0 AS NUMBER(4))                 CHECKS,
  CAST (-1 AS BINARY_DOUBLE)            CARDF,
  CAST ('4040404040' AS RAW(5))         CHECKRID5B,
  'U'                                   ENCODING_SCHEME,
  CAST (NULL AS VARCHAR(30))            TABLESTATUS,
  CAST (-1 AS BINARY_DOUBLE)            NPAGESF,
  CAST (-1 AS BINARY_DOUBLE)            SPACEF,
  CAST (-1 AS NUMBER(9))                AVGROWLEN,
  'M'                                   RELCREATED,
  CAST (0 AS NUMBER(4))                 NUM_DEP_MQTS,
  CAST (0 AS NUMBER(4))                 VERSION,
  CAST (0 AS NUMBER(4))                 PARTKEYCOLNUM,
  ' '                                   SPLIT_ROWS,
  ' '                                   SECURITY_LABEL,
  SN.OWNER                              OWNER,
  'N'                                   APPEND,
  ' '                                   OWNERTYPE,
  ' '                                   CONTROL,
  CAST (NULL AS VARCHAR(128))           VERSIONING_SCHEMA,
  CAST (NULL AS VARCHAR(128))           VERSIONING_TABLE,
  CAST (0 AS NUMBER(4))                 HASHKEYCOLUMNS
  FROM ALL_SYNONYMS SN
  WHERE DB_LINK IS NOT NULL
    OR EXISTS (SELECT 1 FROM ALL_CATALOG AC
                 WHERE SN.TABLE_OWNER = AC.OWNER
                 AND SN.TABLE_NAME = AC.TABLE_NAME
                 AND AC.TABLE_TYPE IN ('TABLE', 'VIEW'));
grant SELECT on SYSIBM.SYSTABLES to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSSYNONYMS
AS SELECT
  SN.SYNONYM_NAME                       NAME,
  SN.OWNER                              CREATOR,
  TABLE_NAME                            TBNAME,
  TABLE_OWNER                           TBCREATOR,
  'N'                                   IBMREQD,
  SN.OWNER                              CREATEDBY,
  LOCALTIMESTAMP                        CREATEDTS,
  ' '                                   CREATORTYPE,
  'M'                                   RELCREATED
  FROM ALL_SYNONYMS SN
  WHERE 1 = 2;
grant SELECT on SYSIBM.SYSSYNONYMS to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSDUMMY1
AS SELECT
  'Y'                                   IBMREQD
  FROM DUAL;
grant SELECT on SYSIBM.SYSDUMMY1 to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSVIEWS
AS SELECT
  VIEW_NAME                     NAME,
  OWNER                         CREATOR,
  CAST(0 AS NUMBER(4))          SEQNO,
  'N'                           "CHECK",
  'N'                           IBMREQD,
  CAST(NULL AS VARCHAR (1500))  TEXT,
  CAST(NULL AS VARCHAR (2048))  PATHSCHEMAS,
  'M'                           RELCREATED,
  'V'                           TYPE,
  ' '                           REFRESH,
  ' '                           ENABLE,
  ' '                           MAINTENANCE,
  TO_TIMESTAMP('0001-01-01-00:00:00.000000',
        'YYYY-MM-DD-HH24:MI:SS.FF6') REFRESH_TIME,
  ' '        ISOLATION,
  CAST(NULL AS VARCHAR (1024))  SIGNATURE,
  CAST(1208 AS NUMBER(9))       APP_ENCODING_CCSID,
  OWNER                         OWNER,
  ' '                           OWNERTYPE,
  CAST(0 AS NUMBER(9))          ENVID,
  CAST('00' AS RAW(40))         ROWID_VIEW,
  TEXT                          STATEMENT,
  TO_BLOB(NULL)                 PARSETREE
  FROM ALL_VIEWS VW;
grant SELECT on SYSIBM.SYSVIEWS to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSINDEXES
AS SELECT
  IX.INDEX_NAME                 NAME,
  IX.OWNER                      CREATOR,
  IX.TABLE_NAME                 TBNAME,
  TABLE_OWNER                   TBCREATOR,
  CAST (CASE UNIQUENESS
    WHEN 'UNIQUE' THEN NVL(AC.CONSTRAINT_TYPE, 'U') -- 'P' Primary key or 'U'
    WHEN 'NONUNIQUE' THEN 'D'
  END AS CHAR(1))               UNIQUERULE,
  CAST (NVL(KY.MAXKEYS, 0) AS NUMBER(4)) COLCOUNT,
  CASE INDEX_TYPE
    WHEN 'CLUSTER' THEN 'Y'
    ELSE 'N'
  END                           CLUSTERING,
  ' '                           CLUSTERED,
  CAST (1 AS NUMBER(4))         DBID,
  CAST (0 AS NUMBER(4))         OBID,
  CAST (0 AS NUMBER(4))         ISOBID,
  CAST ('ORACLE' AS VARCHAR(24))DBNAME,
  NVL(TABLESPACE_NAME, 'SYSTSTAB') INDEXSPACE,
  CAST (0 AS NUMBER(9))         FIRSTKEYCARD,
  CAST (0 AS NUMBER(9))         FULLKEYCARD,
  CAST (NVL(LEAF_BLOCKS, -1) AS NUMBER(9)) NLEAF,
  CAST (NVL(BLEVEL, -1) AS NUMBER(4)) NLEVELS,
  CAST ('ORACLE' AS CHAR(8))    BPOOL,
  CAST (4096 AS NUMBER(4))      PGSIZE,
  'N'                           ERASERULE,
  CAST (NULL AS VARCHAR (24))   DSETPASS,
  'Y'       CLOSERULE,
  CAST (-1 AS NUMBER(9))        SPACE,
  'N'                           IBMREQD,
  CAST (0 AS NUMBER(4))         CLUSTERRATIO,
  IX.OWNER                      CREATEDBY,
  CAST (0 AS NUMBER(4))         IOFACTOR,
  CAST (0 AS NUMBER(4))         PREFETCHFACTOR,
  CAST (NVL(IX.LAST_ANALYZED,
        TO_TIMESTAMP('0001-01-01-00:00:00.000000',
        'YYYY-MM-DD-HH24:MI:SS.FF6'))
        AS TIMESTAMP(6)) STATSTIME,
  ' '                           INDEXTYPE,
  CAST (-1 AS BINARY_DOUBLE)    FIRSTKEYCARDF,
  CAST (NVL(DISTINCT_KEYS, -1) AS BINARY_DOUBLE) FULLKEYCARDF,
  LOCALTIMESTAMP                CREATEDTS,
  LOCALTIMESTAMP                ALTEREDTS,
  CAST (0 AS NUMBER(9))         PIECESIZE,
  'N'                           COPY,
  CAST ('000000000000' AS RAW(6)) COPYLRSN,
  CAST (0 AS BINARY_DOUBLE)     CLUSTERRATIOF,
  CAST (-1 AS BINARY_DOUBLE)    SPACEF,
  CAST (NULL AS VARCHAR (762))  REMARKS,
  'N'                           PADDED,
  CAST (0 AS NUMBER(4))         VERSION,
  CAST (0 AS NUMBER(4))         OLDEST_VERSION,
  CAST (0 AS NUMBER(4))         CURRENT_VERSION,
  'M'                           RELCREATED,
  CAST (-1 AS NUMBER(9))        AVGKEYLEN,
  CAST (0 AS NUMBER(4))         KEYTARGET_COUNT,
  CAST (0 AS NUMBER(4))         UNIQUE_COUNT,
  ' '                           IX_EXTENSION_TYPE,
  CASE COMPRESSION
    WHEN 'ENABLED' THEN 'Y'
    ELSE 'N'
  END                           "COMPRESS",
  IX.OWNER                      OWNER,
  ' '                           OWNERTYPE,
  CAST (-1 AS BINARY_DOUBLE)    DATAREPEATFACTORF,
  CAST (0 AS NUMBER(9))         ENVID,
  CAST('00' AS RAW(40))         ROWID_INDEX,
  'N'                           HASH,
  'N'                           SPARSE,
  TO_BLOB(NULL)                 PARSETREE,
  TO_BLOB(NULL)                 RTSECTION
  FROM ALL_INDEXES IX LEFT OUTER JOIN ALL_CONSTRAINTS AC
      ON  IX.OWNER      = AC.OWNER
      AND IX.INDEX_NAME = AC.INDEX_NAME
    LEFT OUTER JOIN (SELECT IC.INDEX_OWNER, IC.INDEX_NAME,
                         MAX(IC.COLUMN_POSITION) MAXKEYS
          FROM ALL_IND_COLUMNS IC
          GROUP BY IC.INDEX_OWNER, IC.INDEX_NAME) KY
        ON  IX.OWNER      = KY.INDEX_OWNER
        AND IX.INDEX_NAME = KY.INDEX_NAME;
grant SELECT on SYSIBM.SYSINDEXES to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSKEYS
AS SELECT
  INDEX_NAME                    IXNAME,
  INDEX_OWNER                   IXCREATOR,
  TC.COLUMN_NAME                COLNAME,
  CAST (TC.COLUMN_ID AS NUMBER(4)) COLNO,
  CAST (COLUMN_POSITION AS NUMBER(4)) COLSEQ,
  CASE DESCEND
     WHEN 'DESC' THEN 'D'
     WHEN 'ASC' THEN 'A'
  END                           ORDERING,
  'N'                           IBMREQD,
  ' '                           PERIOD
  FROM ALL_IND_COLUMNS IC, ALL_TAB_COLUMNS TC
     WHERE IC.TABLE_OWNER = TC.OWNER
       AND IC.TABLE_NAME  = TC.TABLE_NAME
       AND IC.COLUMN_NAME = TC.COLUMN_NAME;
grant SELECT on SYSIBM.SYSKEYS to DRDAAS_USER_ROLE;
CREATE OR REPLACE VIEW SYSIBM.SYSKEYCOLUSE
AS SELECT
  AC.CONSTRAINT_NAME               CONSTNAME,
  AC.OWNER                         TBCREATOR,
  AC.TABLE_NAME                    TBNAME,
  AC.COLUMN_NAME                   COLNAME,
  CAST (AC.POSITION AS NUMBER(4))  COLSEQ,
  CAST (KY.COLUMN_ID AS NUMBER(4)) COLNO,
  'N'                              IBMREQD,
  ' '                              PERIOD
FROM ALL_CONS_COLUMNS AC
   LEFT OUTER JOIN ALL_TAB_COLS KY
      ON  AC.OWNER       = KY.OWNER
      AND AC.TABLE_NAME  = KY.TABLE_NAME
      AND AC.COLUMN_NAME = KY.COLUMN_NAME
  WHERE AC.POSITION IS NOT NULL;
grant SELECT on SYSIBM.SYSKEYCOLUSE to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSRELS
AS SELECT
  AC1.OWNER                     CREATOR,
  AC1.TABLE_NAME                TBNAME,
  AC1.CONSTRAINT_NAME           RELNAME,
  AC2.TABLE_NAME                REFTBNAME,
  AC2.OWNER                     REFTBCREATOR,
  CAST (MAXKEYS AS NUMBER(4))   COLCOUNT,
  CASE AC1.DELETE_RULE
    WHEN 'CASCADE' THEN 'C'
    WHEN 'SET NULL' THEN 'N'
    WHEN 'NO ACTION' THEN 'A'
  END                           DELETERULE,
  'N'                           IBMREQD,
  CAST (0 AS NUMBER(4))         RELOBID1,
  CAST (0 AS NUMBER(4))         RELOBID2,
  LOCALTIMESTAMP                TIMESTAMP,
  CASE AC2.CONSTRAINT_TYPE
    WHEN 'P' THEN NULL
    ELSE AC2.OWNER
  END                           IXOWNER,
  CASE AC2.CONSTRAINT_TYPE
    WHEN 'P' THEN NULL
    ELSE AC2.INDEX_NAME
  END                           IXNAME,
  CASE AC1.STATUS
    WHEN 'ENABLED' THEN 'Y'
    WHEN 'DISABLED' THEN 'N'
  END                           ENFORCED,
  CASE AC1.VALIDATED
    WHEN 'VALIDATED' THEN 'I'
    WHEN 'NOT VALIDATED' THEN 'N'
  END                           CHECKEXISTINGDATA,
  'M'                           RELCREATED
  FROM ALL_CONSTRAINTS AC1, ALL_CONSTRAINTS AC2
    LEFT OUTER JOIN (SELECT CC.OWNER, CC.CONSTRAINT_NAME,
                         MAX(CC.POSITION) MAXKEYS
          FROM ALL_CONS_COLUMNS CC
          GROUP BY CC.OWNER, CC.CONSTRAINT_NAME) PK
        ON  AC2.OWNER           = PK.OWNER
        AND AC2.CONSTRAINT_NAME = PK.CONSTRAINT_NAME
    WHERE AC1.CONSTRAINT_TYPE = 'R'
      AND AC1.R_OWNER           = AC2.OWNER
      AND AC1.R_CONSTRAINT_NAME = AC2.CONSTRAINT_NAME
      AND AC2.CONSTRAINT_TYPE IN ('P', 'U');
grant SELECT on SYSIBM.SYSRELS to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSFOREIGNKEYS
AS SELECT
  CC.OWNER                      CREATOR,
  CC.TABLE_NAME                 TBNAME,
  CC.CONSTRAINT_NAME            RELNAME,
  TC.COLUMN_NAME                COLNAME,
  CAST (TC.COLUMN_ID AS NUMBER(4)) COLNO,
  CAST (CC.POSITION  AS NUMBER(4)) COLSEQ,
  'N'                           IBMREQD
  FROM ALL_CONS_COLUMNS CC, ALL_CONSTRAINTS AC, ALL_TAB_COLUMNS TC
     WHERE CC.POSITION IS NOT NULL
       AND CC.OWNER       = AC.OWNER
       AND CC.CONSTRAINT_NAME = AC.CONSTRAINT_NAME
       AND AC.CONSTRAINT_TYPE = 'R'
       AND CC.OWNER       = TC.OWNER
       AND CC.TABLE_NAME  = TC.TABLE_NAME
       AND CC.COLUMN_NAME = TC.COLUMN_NAME;
grant SELECT on SYSIBM.SYSFOREIGNKEYS to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSTABCONST
AS SELECT
  AC.CONSTRAINT_NAME               CONSTNAME,
  AC.OWNER                         TBCREATOR,
  AC.TABLE_NAME                    TBNAME,
  AC.OWNER                         CREATOR,
  AC.CONSTRAINT_TYPE               TYPE,
  AC.INDEX_OWNER                   IXOWNER,
  AC.INDEX_NAME                    IXNAME,
  CAST (NVL(AC.LAST_CHANGE,
        TO_TIMESTAMP('0001-01-01-00:00:00.000000',
        'YYYY-MM-DD-HH24:MI:SS.FF6'))
        AS TIMESTAMP(6))        CREATEDTS,
  'N'                           IBMREQD,
  CAST(KY.MAXCOLS AS NUMBER(4)) COLCOUNT,
  'N'                           RELCREATED
  FROM ALL_CONSTRAINTS AC
    LEFT OUTER JOIN (SELECT IC.CONSTRAINT_NAME, IC.OWNER, IC.TABLE_NAME,
                         MAX(IC.POSITION) MAXCOLS
          FROM ALL_CONS_COLUMNS IC
          GROUP BY IC.CONSTRAINT_NAME, IC.OWNER, IC.TABLE_NAME) KY
        ON  AC.CONSTRAINT_NAME  = KY.CONSTRAINT_NAME
        AND AC.OWNER            = KY.OWNER
        AND AC.TABLE_NAME       = KY.TABLE_NAME
  WHERE AC.CONSTRAINT_TYPE IN ( 'P', 'U');
grant SELECT on SYSIBM.SYSTABCONST to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSCOLUMNS
AS SELECT
  TC.COLUMN_NAME                NAME,
  TC.TABLE_NAME                 TBNAME,
  TC.OWNER                      TBCREATOR,
  CAST (COLUMN_ID AS NUMBER(4)) COLNO,
  CASE DATA_TYPE
       WHEN 'CHAR'              THEN 'CHAR'
       WHEN 'VARCHAR2'          THEN 'VARCHAR'
       WHEN 'LONG'              THEN 'LONGVAR'
       WHEN 'NCHAR'             THEN 'GRAPHIC'
       WHEN 'NVARCHAR2'         THEN 'VARG'
       WHEN 'RAW'               THEN 'BINARY'
       WHEN 'LONG RAW'          THEN 'VARBIN'
       WHEN 'ROWID'             THEN 'ROWID'
       WHEN 'DATE'              THEN 'DATE'
       WHEN 'BINARY_FLOAT'      THEN 'FLOAT'
       WHEN 'BINARY_DOUBLE'     THEN 'FLOAT'
       WHEN 'NUMBER'
         THEN CASE DATA_SCALE
           WHEN 0
             THEN CASE
               WHEN DATA_PRECISION = 1
                 THEN 'DECIMAL'
               WHEN DATA_PRECISION < 5
                 THEN 'SMALLINT'
               WHEN DATA_PRECISION < 10
                 THEN 'INTEGER'
               WHEN DATA_PRECISION < 19
                 THEN 'BIGINT'
               WHEN DATA_PRECISION < 32
                 THEN 'DECIMAL'
               ELSE 'DECFLOAT'
             END
           ELSE
             CASE
               WHEN DATA_PRECISION < 32
                 AND DATA_SCALE > 0
                 AND DATA_SCALE < 32
                 AND DATA_PRECISION >= DATA_SCALE
                 THEN 'DECIMAL'
               ELSE 'DECFLOAT'
             END
           END
       WHEN 'FLOAT'
         THEN 'DECFLOAT'
       ELSE CASE
         WHEN DATA_TYPE LIKE 'TIMESTAMP(%)' THEN 'TIMESTMP'
         WHEN DATA_TYPE LIKE 'TIMESTAMP(%) WITH LOCAL TIME ZONE' THEN 'TIMESTMP'
         WHEN DATA_TYPE LIKE 'TIMESTAMP(%) WITH TIME ZONE' THEN 'TIMESTZ'
         ELSE 'UNKNOWN'
       END
    END                         COLTYPE,
  CAST (CASE DATA_TYPE
       WHEN 'NCHAR'             THEN CHAR_LENGTH -- CHAR semantics
       WHEN 'NVARCHAR2'         THEN CHAR_LENGTH -- CHAR semantics
       WHEN 'ROWID'             THEN 18
       WHEN 'DATE'              THEN 4
       WHEN 'BINARY_FLOAT'      THEN 4
       WHEN 'BINARY_DOUBLE'     THEN 8
       WHEN 'NUMBER'
         THEN CASE DATA_SCALE
           WHEN 0
             THEN CASE
               WHEN DATA_PRECISION = 1
                 THEN DATA_PRECISION -- for DECIMAL, it's just precision
               WHEN DATA_PRECISION < 5
                 THEN 2              -- SMALLINT is 2
               WHEN DATA_PRECISION < 10
                 THEN 4              -- INTEGER is 4
               WHEN DATA_PRECISION < 19
                 THEN 8              -- BIGINT is 8
               WHEN DATA_PRECISION < 32
                 THEN DATA_PRECISION -- for DECIMAL, it's just precision
               ELSE 16               -- for DECFLOAT(34), byte length
             END
           ELSE
             CASE
               WHEN DATA_PRECISION < 32
                 AND DATA_SCALE > 0
                 AND DATA_SCALE < 32
                 AND DATA_PRECISION >= DATA_SCALE
                 THEN DATA_PRECISION -- for DECIMAL, it's just precision
               WHEN DATA_PRECISION < 17
                 THEN 8   -- for DECFLOAT(16), byte length
               ELSE 16    -- for DECFLOAT(34), byte length
             END
           END
       WHEN 'FLOAT'
         THEN CASE
           WHEN DATA_PRECISION < 54
             THEN 8                  -- for DECFLOAT(16), byte length
           ELSE 16                   -- for DECFLOAT(34), byte length
         END
       ELSE CASE
         WHEN DATA_TYPE LIKE 'TIMESTAMP(%)' THEN TRUNC((DATA_SCALE+1)/2) + 7
         WHEN DATA_TYPE LIKE 'TIMESTAMP(%) WITH LOCAL TIME ZONE'
           THEN TRUNC((DATA_SCALE+1)/2) + 7
         WHEN DATA_TYPE LIKE 'TIMESTAMP(%) WITH TIME ZONE'
           THEN TRUNC((DATA_SCALE+1)/2) + 9
         ELSE DATA_LENGTH
       END
    END           AS NUMBER(5)) LENGTH,
  CAST (NVL(CASE DATA_TYPE
              WHEN 'NUMBER'
                THEN CASE
                  WHEN DATA_SCALE <= DATA_PRECISION
                    AND DATA_SCALE > 0
                    AND DATA_PRECISION < 32
                    THEN DATA_SCALE    -- for DECIMAL, scale
                  ELSE 0
                END
              ELSE 0
            END
        , 0) AS NUMBER(4)) SCALE,
  CAST (NULLABLE AS CHAR (1))   NULLS,
  CAST (NVL2(NUM_DISTINCT,
        CASE WHEN NUM_DISTINCT > 2147483647 THEN 2147483647
             ELSE NUM_DISTINCT END, -1) AS NUMBER(10)) COLCARD,
  CAST (NULL AS VARCHAR (2000)) HIGH2KEY,
  CAST (NULL AS VARCHAR (2000)) LOW2KEY,
  'Y'                           UPDATES,
  'N'                           IBMREQD,
  CAST (CC.COMMENTS AS VARCHAR(762)) REMARKS,
  ' '       "DEFAULT",
  CAST (NVL(PK.POSITION, 0) AS NUMBER(4)) KEYSEQ,
  CASE DATA_TYPE
       WHEN 'CHAR'              THEN 'M'
       WHEN 'VARCHAR2'          THEN 'M'
       WHEN 'LONG'              THEN 'M'
       ELSE ' '
    END                         FOREIGNKEY,
  'N'                           FLDPROC,
  CAST (NULL AS VARCHAR (90))   LABEL,
  CAST (NVL(LAST_ANALYZED,
        TO_TIMESTAMP('0001-01-01-00:00:00.000000',
        'YYYY-MM-DD-HH24:MI:SS.FF6'))
         AS TIMESTAMP(6))       STATSTIME,
  CAST (NULL AS VARCHAR (1536))    DEFAULTVALUE,
  CAST (NVL(NUM_DISTINCT, -1) AS BINARY_DOUBLE) COLCARDF,
  ' '                           COLSTATUS,
  CAST (CASE DATA_TYPE
       WHEN 'ROWID'             THEN 40
       ELSE 0
    END           AS NUMBER(9)) LENGTH2, -- LOB length > 32k, ROWID 40
  CAST (CASE DATA_TYPE
       WHEN 'CHAR'              THEN 452
       WHEN 'VARCHAR2'          THEN 448
       WHEN 'LONG'              THEN 456
       WHEN 'NCHAR'             THEN 468
       WHEN 'NVARCHAR2'         THEN 464
       WHEN 'RAW'               THEN 912
       WHEN 'LONG RAW'          THEN 908
       WHEN 'ROWID'             THEN 904
       WHEN 'DATE'              THEN 384
       WHEN 'BINARY_FLOAT'      THEN 480
       WHEN 'BINARY_DOUBLE'     THEN 480
       WHEN 'NUMBER'
         THEN CASE DATA_SCALE
           WHEN 0
             THEN CASE
               WHEN DATA_PRECISION = 1
                 THEN 484
               WHEN DATA_PRECISION < 5
                 THEN 500
               WHEN DATA_PRECISION < 10
                 THEN 496
               WHEN DATA_PRECISION < 19
                 THEN 492
               WHEN DATA_PRECISION < 32
                 THEN 484
               ELSE 996
             END
           ELSE
             CASE
               WHEN DATA_PRECISION < 32
                 AND DATA_SCALE > 0
                 AND DATA_SCALE < 32
                 AND DATA_PRECISION >= DATA_SCALE
                 THEN 484
               ELSE 996
             END
           END
       WHEN 'FLOAT'
           THEN 996
       ELSE CASE
         WHEN DATA_TYPE LIKE 'TIMESTAMP(%)' THEN 392
         WHEN DATA_TYPE LIKE 'TIMESTAMP(%) WITH LOCAL TIME ZONE' THEN 392
         WHEN DATA_TYPE LIKE 'TIMESTAMP(%) WITH TIME ZONE' THEN 2448
         ELSE 0
       END
    END AS NUMBER(9))           DATATYPEID,
  CAST (0 AS NUMBER(9))         SOURCETYPEID,
  CAST ('SYSIBM' AS VARCHAR (128))TYPESCHEMA,
  CAST (NULL AS VARCHAR (128))  TYPENAME,
  LOCALTIMESTAMP                CREATEDTS,
  ' '       STATS_FORMAT,
  CAST (NVL(PC.COLUMN_POSITION, 0) AS NUMBER(4)) PARTKEY_COLSEQ,
  NVL2(PC.COLUMN_POSITION,'A',' ') PARTKEY_ORDERING,
  LOCALTIMESTAMP                ALTEREDTS,
  CAST (CASE DATA_TYPE
       WHEN 'CHAR'              THEN 1208
       WHEN 'VARCHAR2'          THEN 1208
       WHEN 'LONG'              THEN 1208
       WHEN 'NCHAR'             THEN 1200
       WHEN 'NVARCHAR2'         THEN 1200
       ELSE 0
    END AS NUMBER(9))           CCSID,
  ' '                           HIDDEN,
  'M'                           RELCREATED,
  CAST (0 AS NUMBER(9))         CONTROL_ID,
  CAST (0 AS NUMBER(9))         XML_TYPEMOD_ID,
  ' '                           PERIOD,
  ' '                           GENERATED_ATTR,
  CAST (0 AS NUMBER(4))         HASHKEY_COLSEQ
  FROM ALL_TAB_COLUMNS TC LEFT OUTER JOIN ALL_COL_COMMENTS CC
        ON  TC.OWNER      = CC.OWNER
        AND TC.TABLE_NAME = CC.TABLE_NAME
        AND TC.COLUMN_NAME = CC.COLUMN_NAME
        LEFT OUTER JOIN (select cn.owner, cn.table_name,
                         nc.COLUMN_NAME, nc.POSITION
          from all_constraints cn, all_cons_columns nc
          where cn.CONSTRAINT_TYPE = 'P'
            and cn.owner           = nc.owner
            and cn.constraint_name = nc.constraint_name
            and cn.table_name      = nc.table_name) PK
        ON  TC.OWNER       = PK.OWNER
        AND TC.TABLE_NAME  = PK.TABLE_NAME
        AND TC.COLUMN_NAME = PK.COLUMN_NAME
        LEFT OUTER JOIN ALL_PART_KEY_COLUMNS PC
        ON  TC.OWNER       = PC.OWNER
        AND TC.TABLE_NAME  = PC.NAME
        AND TC.COLUMN_NAME = PC.COLUMN_NAME
        AND PC.OBJECT_TYPE = 'TABLE'
  WHERE DATA_TYPE_OWNER IS NULL -- no user define datatypes (objects)
;
grant SELECT on SYSIBM.SYSCOLUMNS to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSROUTINES
AS SELECT
  AP.OWNER                      SCHEMA,
  AP.OWNER                      OWNER,
  AP.OBJECT_NAME                NAME,
  CASE AP.OBJECT_TYPE
    WHEN 'PROCEDURE' THEN 'P'
    WHEN 'FUNCTION'  THEN 'F'
  END                           ROUTINETYPE,
  AP.OWNER                      CREATEDBY,
  AP.OBJECT_NAME                SPECIFICNAME,
  CAST (AP.OBJECT_ID AS NUMBER(10)) ROUTINEID,
  CAST (CASE AP.OBJECT_TYPE
    WHEN 'PROCEDURE' THEN 0
    WHEN 'FUNCTION'  THEN CASE AA.DATA_TYPE
       WHEN 'CHAR'              THEN 452
       WHEN 'VARCHAR2'          THEN 448
       WHEN 'LONG'              THEN 456
       WHEN 'NCHAR'             THEN 468
       WHEN 'NVARCHAR2'         THEN 464
       WHEN 'RAW'               THEN 912
       WHEN 'LONG RAW'          THEN 908
       WHEN 'ROWID'             THEN 904
       WHEN 'DATE'              THEN 384
       WHEN 'BINARY_FLOAT'      THEN 480
       WHEN 'BINARY_DOUBLE'     THEN 480
       WHEN 'BINARY_INTEGER'    THEN 496
       WHEN 'NUMBER'
         THEN CASE AA.DATA_SCALE
           WHEN 0
             THEN CASE
               WHEN AA.DATA_PRECISION = 1
                 THEN 484
               WHEN AA.DATA_PRECISION < 5
                 THEN 500
               WHEN AA.DATA_PRECISION < 10
                 THEN 496
               WHEN AA.DATA_PRECISION < 19
                 THEN 492
               WHEN AA.DATA_PRECISION < 32
                 THEN 484
               ELSE 996
             END
           ELSE
             CASE
               WHEN  AA.DATA_PRECISION < 32
                 AND AA.DATA_SCALE > 0
                 AND AA.DATA_SCALE < 32
                 AND AA.DATA_PRECISION >= DATA_SCALE
                 THEN 484
               ELSE 996
             END
           END
       WHEN 'FLOAT'
         THEN 996
       ELSE CASE
         WHEN AA.DATA_TYPE LIKE 'TIMESTAMP' THEN 392
         WHEN AA.DATA_TYPE LIKE 'TIMESTAMP WITH LOCAL TIME ZONE' THEN 392
         WHEN AA.DATA_TYPE LIKE 'TIMESTAMP WITH TIME ZONE' THEN 2448
         ELSE 0
       END
    END
  END AS NUMBER(9))             RETURN_TYPE,
  CASE AP.OBJECT_TYPE
    WHEN 'PROCEDURE' THEN 'N'
    WHEN 'FUNCTION'  THEN 'Q'
  END                           ORIGIN,
  CASE AP.OBJECT_TYPE
    WHEN 'PROCEDURE' THEN ' '
    WHEN 'FUNCTION'  THEN
      CASE
        WHEN AP.AGGREGATE = 'YES' THEN 'C'
        WHEN AP.PIPELINED = 'YES' THEN 'T'
        ELSE 'S'
      END
  END                           FUNCTION_TYPE,
  CAST (AA2.MAXPOS AS NUMBER(4)) PARM_COUNT,
  CAST ('SQL' AS VARCHAR (24))  LANGUAGE,
  CAST (NULL AS VARCHAR (128))  COLLID,
  CAST (NULL AS VARCHAR (128))  SOURCESCHEMA,
  CAST (NULL AS VARCHAR (128))  SOURCESPECIFIC,
  CASE
     WHEN AP.DETERMINISTIC = 'YES' THEN 'Y'
     ELSE 'N'
  END                           DETERMINISTIC,
  'E'                           EXTERNAL_ACTION, -- has external side effects?
  CASE AP.OBJECT_TYPE
    WHEN 'PROCEDURE' THEN 'Y'
    WHEN 'FUNCTION'  THEN ' '
  END                           NULL_CALL,
  ' '                           CAST_FUNCTION,
  ' '                           SCRATCHPAD,
  CAST (0 AS NUMBER(9))         SCRATCHPAD_LENGTH,
  ' '                           FINAL_CALL,
  ' '                           PARALLEL,
  ' '                           PARAMETER_STYLE,
  ' '                           FENCED,
  'M'                           SQL_DATA_ACCESS,
  ' '                           DBINFO,
  ' '                           STAYRESIDENT,
  CAST (0 AS NUMBER(9))         ASUTIME,
  CAST (NULL AS VARCHAR (96))   WLM_ENVIRONMENT,
  ' '                           WLM_ENV_FOR_NESTED,
  ' '                           PROGRAM_TYPE,
  ' '                           EXTERNAL_SECURITY,
  CASE AP.OBJECT_TYPE
    WHEN 'PROCEDURE' THEN 'N'
    WHEN 'FUNCTION'  THEN ' '
  END                           COMMIT_ON_RETURN,
  CAST (0 AS NUMBER(4))         RESULT_SETS,
  CAST (0 AS NUMBER(4))         LOBCOLUMNS,
  LOCALTIMESTAMP                CREATEDTS,
  LOCALTIMESTAMP                ALTEREDTS,
  'N'                           IBMREQD,
  CAST (0 AS NUMBER(4))         PARM1,
  CAST (0 AS NUMBER(4))         PARM2,
  CAST (0 AS NUMBER(4))         PARM3,
  CAST (0 AS NUMBER(4))         PARM4,
  CAST (0 AS NUMBER(4))         PARM5,
  CAST (0 AS NUMBER(4))         PARM6,
  CAST (0 AS NUMBER(4))         PARM7,
  CAST (0 AS NUMBER(4))         PARM8,
  CAST (0 AS NUMBER(4))         PARM9,
  CAST (0 AS NUMBER(4))         PARM10,
  CAST (0 AS NUMBER(4))         PARM11,
  CAST (0 AS NUMBER(4))         PARM12,
  CAST (0 AS NUMBER(4))         PARM13,
  CAST (0 AS NUMBER(4))         PARM14,
  CAST (0 AS NUMBER(4))         PARM15,
  CAST (0 AS NUMBER(4))         PARM16,
  CAST (0 AS NUMBER(4))         PARM17,
  CAST (0 AS NUMBER(4))         PARM18,
  CAST (0 AS NUMBER(4))         PARM19,
  CAST (0 AS NUMBER(4))         PARM20,
  CAST (0 AS NUMBER(4))         PARM21,
  CAST (0 AS NUMBER(4))         PARM22,
  CAST (0 AS NUMBER(4))         PARM23,
  CAST (0 AS NUMBER(4))         PARM24,
  CAST (0 AS NUMBER(4))         PARM25,
  CAST (0 AS NUMBER(4))         PARM26,
  CAST (0 AS NUMBER(4))         PARM27,
  CAST (0 AS NUMBER(4))         PARM28,
  CAST (0 AS NUMBER(4))         PARM29,
  CAST (0 AS NUMBER(4))         PARM30,
  CAST (-1 AS BINARY_DOUBLE)    IOS_PER_INVOC,
  CAST (-1 AS BINARY_DOUBLE)    INSTS_PER_INVOC,
  CAST (-1 AS BINARY_DOUBLE)    INITIAL_IOS,
  CAST (-1 AS BINARY_DOUBLE)    INITIAL_INSTS,
  CAST (-1 AS BINARY_DOUBLE)    CARDINALITY,
  CAST (1 AS NUMBER(4))         RESULT_COLS,
  CAST (NULL AS VARCHAR (762))  EXTERNAL_NAME,
  CAST('00' AS RAW(150))        PARM_SIGNATURE,
  CAST (NULL AS VARCHAR (762))  RUNOPTS,
  CAST (NULL AS VARCHAR (762))  REMARKS,
  CAST (NULL AS VARCHAR (3072)) JAVA_SIGNATURE,
  CAST (NULL AS VARCHAR (384))  CLASS,
  CAST (NULL AS VARCHAR (128))  JARSCHEMA,
  CAST (NULL AS VARCHAR (128))  JAR_ID,
  'D'                           SPECIAL_REGS,
  CAST (0 AS NUMBER(4))         NUM_DEP_MQTS,
  CAST (-1 AS NUMBER(4))        MAX_FAILURE,
  CAST (1208 AS NUMBER(9))      PARAMETER_CCSID,
  CAST (NULL AS VARCHAR (122))  VERSION,
  CAST ('0000000000000000' AS RAW(8)) CONTOKEN,
  'Y'                           ACTIVE,
  'N'                           DEBUG_MODE,
  CAST (0 AS NUMBER(9))         TEXT_ENVID,
  CAST('00' AS RAW(40))         TEXT_ROWID,
  TO_CLOB(' ')                  TEXT,
  ' '                           OWNERTYPE,
  CAST (0 AS NUMBER(9))         PARAMETER_VARCHARFORM,
  'M'                           RELCREATED,
  CAST (NULL AS VARCHAR (4000)) PACKAGEPATH,
  'N'                           SECURE,
  ' '                           SYSTEM_DEFINED,
  CASE AP.OBJECT_TYPE
    WHEN 'PROCEDURE' THEN ' '
    WHEN 'FUNCTION'  THEN 'Y'
  END                           INLINE,
  TO_BLOB(NULL)                 PARSETREE
  FROM ALL_PROCEDURES AP LEFT OUTER JOIN ALL_ARGUMENTS AA
    ON  AP.OBJECT_ID      = AA.OBJECT_ID -- function return parameter
       AND AP.OBJECT_TYPE = 'FUNCTION'
       AND AA.PACKAGE_NAME  IS NULL
       AND AA.DATA_LEVEL  = 0
       AND AA.POSITION    = 0
    LEFT OUTER JOIN (SELECT OBJECT_ID, MAX(POSITION) MAXPOS
                       FROM ALL_ARGUMENTS
                       WHERE PACKAGE_NAME IS NULL
                          AND DATA_LEVEL = 0
                       GROUP BY OBJECT_ID) AA2
    ON  AP.OBJECT_ID      = AA2.OBJECT_ID
  WHERE OBJECT_TYPE IN ('PROCEDURE', 'FUNCTION');
grant SELECT on SYSIBM.SYSROUTINES to DRDAAS_USER_ROLE;
CREATE or replace VIEW SYSIBM.SYSPARMS
AS SELECT
  AA.OWNER                      SCHEMA,
  AA.OWNER                      OWNER,
  AA.OBJECT_NAME                NAME,
  AA.OBJECT_NAME                SPECIFICNAME,
  CASE AP.OBJECT_TYPE
    WHEN 'PROCEDURE' THEN 'P'
    WHEN 'FUNCTION'  THEN 'F'
  END                           ROUTINETYPE,
  'N'                           CAST_FUNCTION,
  AA.ARGUMENT_NAME              PARMNAME,
  CAST (AA.OBJECT_ID AS NUMBER(10)) ROUTINEID,
  CASE IN_OUT
    WHEN 'IN'     THEN 'P'
    WHEN 'OUT'
      THEN CASE
        WHEN POSITION = 0 THEN 'C' -- function return parameter
        ELSE 'O'
      END
    WHEN 'IN/OUT' THEN 'B'
  END                           ROWTYPE,
  CAST (POSITION AS NUMBER(4))  ORDINAL,
  CAST ('SYSIBM' AS VARCHAR(128)) TYPESCHEMA,
  CAST (CASE DATA_TYPE
       WHEN 'CHAR'              THEN 'CHAR'
       WHEN 'VARCHAR2'          THEN 'VARCHAR'
       WHEN 'LONG'              THEN 'LONGVAR'
       WHEN 'NCHAR'             THEN 'GRAPHIC'
       WHEN 'NVARCHAR2'         THEN 'VARG'
       WHEN 'RAW'               THEN 'BINARY'
       WHEN 'LONG RAW'          THEN 'VARBIN'
       WHEN 'ROWID'             THEN 'ROWID'
       WHEN 'DATE'              THEN 'DATE'
       WHEN 'BINARY_FLOAT'      THEN 'FLOAT'
       WHEN 'BINARY_DOUBLE'     THEN 'FLOAT'
       WHEN 'BINARY_INTEGER'    THEN 'INTEGER'
       WHEN 'NUMBER'
         THEN CASE DATA_SCALE
           WHEN 0
             THEN CASE
               WHEN DATA_PRECISION = 1
                 THEN 'DECIMAL'
               WHEN DATA_PRECISION < 5
                 THEN 'SMALLINT'
               WHEN DATA_PRECISION < 10
                 THEN 'INTEGER'
               WHEN DATA_PRECISION < 19
                 THEN 'BIGINT'
               WHEN DATA_PRECISION < 32
                 THEN 'DECIMAL'
               ELSE 'DECFLOAT'
             END
           ELSE
             CASE
               WHEN DATA_PRECISION < 32
                 AND DATA_SCALE > 0
                 AND DATA_SCALE < 32
                 AND DATA_PRECISION >= DATA_SCALE
                 THEN 'DECIMAL'
               ELSE 'DECFLOAT'
             END
           END
       WHEN 'FLOAT'
         THEN 'DECFLOAT'
       ELSE CASE
         WHEN DATA_TYPE LIKE 'TIMESTAMP' THEN 'TIMESTMP'
         WHEN DATA_TYPE LIKE 'TIMESTAMP WITH LOCAL TIME ZONE' THEN 'TIMESTMP'
         WHEN DATA_TYPE LIKE 'TIMESTAMP WITH TIME ZONE' THEN 'TIMESTZ'
         ELSE 'UNKNOWN'
       END
    END AS VARCHAR(128))        TYPENAME,
  CAST (CASE DATA_TYPE
       WHEN 'CHAR'              THEN 452
       WHEN 'VARCHAR2'          THEN 448
       WHEN 'LONG'              THEN 456
       WHEN 'NCHAR'             THEN 468
       WHEN 'NVARCHAR2'         THEN 464
       WHEN 'RAW'               THEN 912
       WHEN 'LONG RAW'          THEN 908
       WHEN 'ROWID'             THEN 904
       WHEN 'DATE'              THEN 384
       WHEN 'BINARY_FLOAT'      THEN 480
       WHEN 'BINARY_DOUBLE'     THEN 480
       WHEN 'BINARY_INTEGER'    THEN 496
       WHEN 'NUMBER'
         THEN CASE DATA_SCALE
           WHEN 0
             THEN CASE
               WHEN DATA_PRECISION = 1
                 THEN 484
               WHEN DATA_PRECISION < 5
                 THEN 500
               WHEN DATA_PRECISION < 10
                 THEN 496
               WHEN DATA_PRECISION < 19
                 THEN 492
               WHEN DATA_PRECISION < 32
                 THEN 484
               ELSE 996
             END
           ELSE
             CASE
               WHEN DATA_PRECISION < 32
                 AND DATA_SCALE > 0
                 AND DATA_SCALE < 32
                 AND DATA_PRECISION >= DATA_SCALE
                 THEN 484
               ELSE 996
             END
           END
       WHEN 'FLOAT'
         THEN 996
       ELSE CASE
         WHEN DATA_TYPE LIKE 'TIMESTAMP' THEN 392
         WHEN DATA_TYPE LIKE 'TIMESTAMP WITH LOCAL TIME ZONE' THEN 392
         WHEN DATA_TYPE LIKE 'TIMESTAMP WITH TIME ZONE' THEN 2448
         ELSE 0
       END
    END AS NUMBER(9))           DATATYPEID,
  CAST (0 AS NUMBER(9))         SOURCETYPEID,
  'N'                           LOCATOR,
  'N'                           "TABLE",
  CAST (0 AS NUMBER(4))         TABLE_COLNO,
  CAST (CASE DATA_TYPE
       WHEN 'NCHAR'             THEN CHAR_LENGTH -- CHAR semantics
       WHEN 'NVARCHAR2'         THEN CHAR_LENGTH -- CHAR semantics
       WHEN 'ROWID'             THEN 18
       WHEN 'DATE'              THEN 4
       WHEN 'BINARY_FLOAT'      THEN 4
       WHEN 'BINARY_DOUBLE'     THEN 8
       WHEN 'BINARY_INTEGER'    THEN 4 -- INTEGER is 4
       WHEN 'NUMBER'
         THEN CASE DATA_SCALE
           WHEN 0
             THEN CASE
               WHEN DATA_PRECISION = 1
                 THEN DATA_PRECISION -- for DECIMAL, it's just precision
               WHEN DATA_PRECISION < 5
                 THEN 2              -- SMALLINT is 2
               WHEN DATA_PRECISION < 10
                 THEN 4              -- INTEGER is 4
               WHEN DATA_PRECISION < 19
                 THEN 8              -- BIGINT is 8
               WHEN DATA_PRECISION < 32
                 THEN DATA_PRECISION -- for DECIMAL, it's just precision
               ELSE 16               -- for DECFLOAT(34), byte length
             END
           ELSE
             CASE
               WHEN DATA_PRECISION < 32
                 AND DATA_SCALE > 0
                 AND DATA_SCALE < 32
                 AND DATA_PRECISION >= DATA_SCALE
                 THEN DATA_PRECISION -- for DECIMAL, it's just precision
               WHEN DATA_PRECISION < 17
                 THEN 8   -- for DECFLOAT(16), byte length
               ELSE 16               -- for DECFLOAT(34), byte length
             END
           END
       WHEN 'FLOAT'
         THEN CASE
           WHEN DATA_PRECISION < 54
             THEN 8                  -- for DECFLOAT(16), byte length
           ELSE 16                   -- for DECFLOAT(34), byte length
         END
       ELSE CASE
         WHEN DATA_TYPE LIKE 'TIMESTAMP' THEN TRUNC((DATA_SCALE+1)/2) + 7
         WHEN DATA_TYPE LIKE 'TIMESTAMP WITH LOCAL TIME ZONE'
           THEN TRUNC((DATA_SCALE+1)/2) + 7
         WHEN DATA_TYPE LIKE 'TIMESTAMP WITH TIME ZONE'
           THEN TRUNC((DATA_SCALE+1)/2) + 9
         ELSE DATA_LENGTH
       END
  END           AS NUMBER(9))   LENGTH,
  CAST (NVL(CASE DATA_TYPE
              WHEN 'NUMBER'
                THEN CASE
                  WHEN DATA_SCALE <= DATA_PRECISION
                    AND DATA_SCALE > 0
                    AND DATA_PRECISION < 32
                    THEN DATA_SCALE    -- for DECIMAL, scale
                  ELSE 0
                END
              ELSE 0
            END
        , 0) AS NUMBER(4)) SCALE,
  CASE DATA_TYPE
       WHEN 'CHAR'              THEN 'M'
       WHEN 'VARCHAR2'          THEN 'M'
       WHEN 'LONG'              THEN 'M'
       ELSE ' '
  END                           SUBTYPE,
  CAST (1208 AS NUMBER(9))      CCSID,
  CAST (0 AS NUMBER(9))         CAST_FUNCTION_ID,
  'U'                           ENCODING_SCHEME,
  'N'                           IBMREQD,
  CAST (NULL AS VARCHAR(122))   VERSION,
  ' '                           OWNERTYPE
  FROM ALL_ARGUMENTS AA, ALL_PROCEDURES AP
     WHERE AA.DATA_LEVEL    =  0
       AND AA.PACKAGE_NAME  IS NULL
       AND AP.OBJECT_TYPE   IN ('PROCEDURE', 'FUNCTION')
       AND AA.OWNER         =  AP.OWNER
       AND AA.OBJECT_NAME   =  AP.OBJECT_NAME;
grant SELECT on SYSIBM.SYSPARMS to DRDAAS_USER_ROLE;
CREATE OR REPLACE FUNCTION bigint wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
8
86 ae
64o3d/xO6ai2nzCnYsM43GKD16Qwg8eZgcfLCNL+XlqXWXJH1bO40m1f/pmBXKXSXqYJ3OI1
7HGenp414qhrNXzzyKlt9uP2yGSwTxe447CCWsrdf4WzxsY9SRk9crP6xpQUXYh0ZpBxVQBz
Z3RTf3zaITs1FeI/0Tx0ptyYqAQ=

/
show errors
create or replace public synonym bigint for bigint;
grant execute on bigint to public;
commit;
