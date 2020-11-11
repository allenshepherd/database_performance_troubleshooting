
Rem
Rem $Header: rdbms/admin/cddm.sql /main/40 2017/08/16 08:07:38 alsakha Exp $
Rem
Rem cddm.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cddm.sql - Catalog DDM.bsq views
Rem
Rem    DESCRIPTION
Rem      Data Mining Model objects.
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in ddm.bsq.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cddm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cddm.sql
Rem SQL_PHASE: CDDM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem   alsakha      08/03/17 - bug 26572133
Rem   ffeli        05/12/17 - rti-20280062: fix R model import bug
Rem   ffeli        04/16/17 - move modelalg$ creation to ddm.bsq
Rem   gayyappa     03/17/17 - remove RF metadata tables
Rem   gayyappa     12/28/16 - add random forest
Rem   dbai         12/21/16 - add exponential smoothing
Rem   ffeli        12/12/16 - Revise USER/ALL/DBA_MINING_MODELS for algorithm
Rem                           registration
Rem   ffeli        12/12/16 - Add all_mining_algorithms view
Rem   mmcracke     10/25/16 - #(24958335): model ttyp ub1 -> ub2
Rem   yacheche     10/13/16 - Add CUR decomposition algorithm
Rem   nihao        09/21/16 - add neural network
Rem   gayyappa     10/10/15 - AR transactional views
Rem   bmilenov     09/22/15 - bug-21394151: view cleanup
Rem   jiangzho     09/19/15 - #(2184627): fix ESA model import
Rem   mmcracke     07/25/15 - #(21393765) Add views
Rem   amozes       07/24/15 - #(21459410): skip model views for model tables
Rem   jiangzho     06/24/15 - #(21240327): add dba/all/user_mining_model_views
Rem    amozes      05/20/15 - xform fixes
Rem    qinwan      03/25/15 - add data mining R algorithm name
Rem    amozes      03/05/15 - #(20656462): fix all_mining_model_partitions
Rem    amozes      01/15/15 - #(20354336): changes for security project 58196
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
REM    jzhou       09/10/13 - Add a model table 65 and updated DBA_MINING_MODEL_TABLES
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    mmcracke    06/20/13 - proj 47099 partitioned model
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    amozes      02/14/12 - #(13472685) other signature datatypes
Rem    pstengar    11/30/11 - bug 13068625: support TEXT attribute_type
Rem    pstengar    09/10/11 - add support for attribute datatypes CLOB, BLOB
Rem                           and BFILE
Rem    amozes      08/31/11 - #(12906828) Add public synonyms for DBA* views
Rem    bmilenov    04/28/11 - Add expectation maximization
Rem    pstengar    04/18/11 - add support for unstructured text data
Rem    mmcracke    07/18/09 - Add ADP binning table type
Rem    bmilenov    06/15/09 - Bug-8661316: Add H inversion table to NMF
Rem    mmcracke    05/11/09 - proj 32331.1 support native double in DMF
Rem    mmcracke    12/24/08 - Add ADP table to DBA_MINING_MODEL_TABLES
Rem    bmilenov    09/25/07 - Add SVD algorithm
Rem    dmukhin     03/05/08 - bug 6620177: ADP coefficients reversal
Rem    mmcracke    07/06/06 - Add new table type ocSplitPredicate 
Rem    pstengar    05/02/06 - update system privilege numbers
Rem    bmilenov    05/26/06 - Add GLM 
Rem    dmukhin     05/17/06 - prj 18876: scoring cost matrix 
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

remark
remark  FAMILY "DATA MINING MODELS"
remark  List of models
remark

alter table modelalg$ ENABLE constraint ensure_json;

DECLARE
  str clob;
BEGIN
  str := 
'
{
    "type": "object",
    "properties": {
        "algo_name_display": { "type" : "object", 
                               "properties" : { 
                                  "language" : { "type" : "string",
                                                 "enum" : ["English", "Spanish", "French"], 
                                                 "default" : "English"},
                                  "name" : { "type" : "string"}
                                }
                             },
        "function_language": {"type": "string" }, 
        "mining_function": {
                 "type" : "object",
                 "properties" :  
                     { "type" : "object", 
                        "properties" : { 
                           "mining_function_name"  : { "type" : "string"}, 
                           "build_function": {  
                              "type": "object",
                              "properties": {
                                 "function_body": { "type": "CLOB" }
                               }
                            },
                           "detail_function": {  
                             "type" : "array",
                             "items" : [ 
                                {"type": "object",
                                 "properties": {
                                    "function_body": { "type": "CLOB" },
                                    "view_columns": { "type" : "array",
                                                      "items" : {
                                                         "type" : "object", 
                                                         "properties" : { 
                                                            "name" : { "type" : "string"},
                                                            "type" : { "type" : "string",
                                                                       "enum" : ["VARCHAR2", 
                                                                                 "NUMBER", 
                                                                                 "DATE", 
                                                                                 "BOOLEAN"]
                                                                     }
                                                      }
                                                    }
                                     }
                                   }
                                 }
                               ]
                             },
                            "score_function": {  
                               "type": "object",
                               "properties": {
                                  "function_body": { "type": "CLOB" }
                                }
                             },
                            "weight_function": {
                               "type": "object",
                               "properties": {
                                  "function_body": { "type": "CLOB" }
                                }
                             }
                        }
                   }
        },  
       "algo_setting": {
                "type" : "array",
                "items" : [ 
                    { "type" : "object", 
                       "properties" : { 
                          "name"        : { "type" : "string"}, 
                          "name_display": { "type" : "object", 
                                            "properties" : { 
                                               "language" : { "type" : "string",
                                                              "enum" : ["English", "Spanish", "French"], 
                                                              "default" : "English"},
                                               "name" : { "type" : "string"}}
                                          },
                          "data_type" : { "type" : "string",
                                          "enum" : ["string", "integer", "number", "boolean"]},
                          "optional": {"type" : "BOOLEAN",
                                       "default" : "FALSE"},    
                          "value" : { "type" :  "string"},  
                          "min_value" : { "type": "object",
                                          "properties": {
                                             "min_value": {"type": "number"},
                                             "inclusive": { "type": "boolean",
                                                            "default" : TRUE},
                                           }
                                        },
                           "max_value" : {"type": "object",
                                          "properties": {
                                             "max_value": {"type": "number"},
                                             "inclusive": { "type": "boolean",
                                                            "default" : TRUE},
                                           }
                                         },
                          "categorical choices" : { "type": "array",
                                                    "items": {
                                                       "type": "string"
                                                             }
                                                  },
                          "description_display": { "type" : "object", 
                                                   "properties" : { 
                                                      "language" : { "type" : "string",
                                                                     "enum" : ["English", "Spanish", "French"], 
                                                                     "default" : "English"},
                                                      "name" : { "type" : "string"}}
                                                 }
                        }
                    }
                 ]
          }    
    }
}
';
  update modelalg$ set mdata = str 
  where owner IS NULL and 
  name IS NULL and 
  num = 0;
END;
/

create or replace view all_mining_algorithms AS
select a.name as algorithm_name,
cast(decode(a.func, 
              1, 'CLASSIFICATION',
              2, 'REGRESSION',
              3, 'CLUSTERING',
              4, 'FEATURE_EXTRACTION',
              5, 'ASSOCIATION_RULES',
              6, 'ATTRIBUTE_IMPORTANCE', /*7 reserved for anomaly */
              8, 'TIME_SERIES',
                 'UNDEFINED') as varchar2(30)) as mining_function, 
       a.type as algorithm_type, 
       a.mdata as algorithm_metadata, 
       a.des as description 
from sys.modelalg$ a;

GRANT READ ON all_mining_algorithms TO PUBLIC;

create or replace public synonym all_mining_algorithms for all_mining_algorithms 
/ 

create or replace view USER_MINING_MODELS
    (MODEL_NAME, MINING_FUNCTION, ALGORITHM, ALGORITHM_TYPE, 
     CREATION_DATE, BUILD_DURATION, MODEL_SIZE, PARTITIONED, COMMENTS)
as
select o.name,
       cast(decode(func, /* Mining Function */
              1, 'CLASSIFICATION',
              2, 'REGRESSION',
              3, 'CLUSTERING',
              4, 'FEATURE_EXTRACTION',
              5, 'ASSOCIATION_RULES',
              6, 'ATTRIBUTE_IMPORTANCE', /*7 reserved for anomaly */
              8, 'TIME_SERIES',
                 'UNDEFINED') as varchar2(30)),
       cast(decode(alg, /* Mining Algorithm */
              1, 'NAIVE_BAYES',
              2, 'ADAPTIVE_BAYES_NETWORK',
              3, 'DECISION_TREE',
              4, 'SUPPORT_VECTOR_MACHINES',
              5, 'KMEANS',
              6, 'O_CLUSTER',
              7, 'NONNEGATIVE_MATRIX_FACTOR',
              8, 'GENERALIZED_LINEAR_MODEL',
              9, 'APRIORI_ASSOCIATION_RULES',
             10, 'MINIMUM_DESCRIPTION_LENGTH',
             11, 'SINGULAR_VALUE_DECOMP',
             12, 'EXPECTATION_MAXIMIZATION',
             13,  NVL(s.value, 'R_EXTENSIBLE'),
             14, 'EXPLICIT_SEMANTIC_ANALYS',
             15, 'RANDOM_FOREST',
             16, 'NEURAL_NETWORK',
             17, 'EXPONENTIAL_SMOOTHING',
             18, 'CUR_DECOMPOSITION',
                 'UNDEFINED') as varchar2(30)),
       cast(decode(alg, 13, 'R', 'NATIVE') as varchar2(10)),
       o.ctime, bdur, msize,
       decode(bitand(m.properties,1),1,'YES','NO'), c.comment$
from sys.model$ m, sys.obj$ o, sys.com$ c,
         (select mod#, value from sys.modelset$
          where bitand(properties,2) != 2 and name = 'ALGO_NAME') s 
where o.obj#=m.obj#
  and o.obj#=c.obj#(+)
  and o.type#=82
  and o.obj#=s.mod#(+)
  and o.owner#=userenv('SCHEMAID')
/
comment on table USER_MINING_MODELS is
'Description of the user''s own models'
/
comment on column USER_MINING_MODELS.MODEL_NAME is
'Name of the model'
/
comment on column USER_MINING_MODELS.MINING_FUNCTION is
'Mining function of the model'
/
comment on column USER_MINING_MODELS.ALGORITHM is
'Algorithm of the model'
/
comment on column USER_MINING_MODELS.ALGORITHM_TYPE is
'Algorithm type of the model'
/
comment on column USER_MINING_MODELS.CREATION_DATE is
'Creation date of the model'
/
comment on column USER_MINING_MODELS.BUILD_DURATION is
'Model build time (in seconds)'
/
comment on column USER_MINING_MODELS.MODEL_SIZE is
'Model size (in Mb)'
/
comment on column USER_MINING_MODELS.COMMENTS is
'Model comments'
/
create or replace public synonym USER_MINING_MODELS for USER_MINING_MODELS
/
grant read on USER_MINING_MODELS to public;
/
create or replace view ALL_MINING_MODELS
    (OWNER, MODEL_NAME, MINING_FUNCTION, ALGORITHM, ALGORITHM_TYPE, 
     CREATION_DATE, BUILD_DURATION, MODEL_SIZE, PARTITIONED, COMMENTS)
as
select u.name, o.name,
       cast(decode(func, /* Mining Function */
              1, 'CLASSIFICATION',
              2, 'REGRESSION',
              3, 'CLUSTERING',
              4, 'FEATURE_EXTRACTION',
              5, 'ASSOCIATION_RULES',
              6, 'ATTRIBUTE_IMPORTANCE', /*7 reserved for anomaly */
              8, 'TIME_SERIES',
                 'UNDEFINED') as varchar2(30)),
       cast(decode(alg, /* Mining Algorithm */
              1, 'NAIVE_BAYES',
              2, 'ADAPTIVE_BAYES_NETWORK',
              3, 'DECISION_TREE',
              4, 'SUPPORT_VECTOR_MACHINES',
              5, 'KMEANS',
              6, 'O_CLUSTER',
              7, 'NONNEGATIVE_MATRIX_FACTOR',
              8, 'GENERALIZED_LINEAR_MODEL',
              9, 'APRIORI_ASSOCIATION_RULES',
             10, 'MINIMUM_DESCRIPTION_LENGTH',
             11, 'SINGULAR_VALUE_DECOMP',
             12, 'EXPECTATION_MAXIMIZATION',
             13,  NVL(s.value, 'R_EXTENSIBLE'),
             14, 'EXPLICIT_SEMANTIC_ANALYS',
             15, 'RANDOM_FOREST',
             16, 'NEURAL_NETWORK',
             17, 'EXPONENTIAL_SMOOTHING',
             18, 'CUR_DECOMPOSITION',
                 'UNDEFINED') as varchar2(30)),
       cast(decode(alg, 13, 'R', 'NATIVE') as varchar2(10)),
       o.ctime, bdur, msize,
       decode(bitand(m.properties,1),1,'YES','NO'), c.comment$  
from sys.model$ m, sys.obj$ o, sys.user$ u, sys.com$ c,
         (select mod#, value from sys.modelset$
          where bitand(properties,2) != 2 and name = 'ALGO_NAME') s 
where o.obj#=m.obj#
  and o.obj#=c.obj#(+)
  and o.type#=82
  and o.owner#=u.user#
  and o.obj#=s.mod#(+)
  and (o.owner#=userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
      )
/
comment on table ALL_MINING_MODELS is
'Description of the models accessible to the user'
/
comment on column ALL_MINING_MODELS.MODEL_NAME is
'Name of the model'
/
comment on column ALL_MINING_MODELS.MINING_FUNCTION is
'Mining function of the model'
/
comment on column ALL_MINING_MODELS.ALGORITHM is
'Algorithm of the model'
/
comment on column ALL_MINING_MODELS.ALGORITHM_TYPE is
'Algorithm type of the model'
/
comment on column ALL_MINING_MODELS.CREATION_DATE is
'Creation date of the model'
/
comment on column ALL_MINING_MODELS.BUILD_DURATION is
'Model build time (in seconds)'
/
comment on column ALL_MINING_MODELS.MODEL_SIZE is
'Model size (in Mb)'
/
comment on column ALL_MINING_MODELS.COMMENTS is
'Model comments'
/
create or replace public synonym ALL_MINING_MODELS for ALL_MINING_MODELS
/
grant read on ALL_MINING_MODELS to public;
/
create or replace view DBA_MINING_MODELS
    (OWNER, MODEL_NAME, MINING_FUNCTION, ALGORITHM, ALGORITHM_TYPE, 
     CREATION_DATE, BUILD_DURATION, MODEL_SIZE, PARTITIONED, COMMENTS)
as
select u.name, o.name,
       cast(decode(func, /* Mining Function */
              1, 'CLASSIFICATION',
              2, 'REGRESSION',
              3, 'CLUSTERING',
              4, 'FEATURE_EXTRACTION',
              5, 'ASSOCIATION_RULES',
              6, 'ATTRIBUTE_IMPORTANCE', /*7 reserved for anomaly */
              8, 'TIME_SERIES',
                 'UNDEFINED') as varchar2(30)),
       cast(decode(alg, /* Mining Algorithm */
              1, 'NAIVE_BAYES',
              2, 'ADAPTIVE_BAYES_NETWORK',
              3, 'DECISION_TREE',
              4, 'SUPPORT_VECTOR_MACHINES',
              5, 'KMEANS',
              6, 'O_CLUSTER',
              7, 'NONNEGATIVE_MATRIX_FACTOR',
              8, 'GENERALIZED_LINEAR_MODEL',
              9, 'APRIORI_ASSOCIATION_RULES',
             10, 'MINIMUM_DESCRIPTION_LENGTH',
             11, 'SINGULAR_VALUE_DECOMP',
             12, 'EXPECTATION_MAXIMIZATION',
             13,  NVL(s.value, 'R_EXTENSIBLE'),
             14, 'EXPLICIT_SEMANTIC_ANALYS',
             15, 'RANDOM_FOREST',
             16, 'NEURAL_NETWORK',
             17, 'EXPONENTIAL_SMOOTHING',
             18, 'CUR_DECOMPOSITION',
                 'UNDEFINED') as varchar2(30)),
       cast(decode(alg, 13, 'R', 'NATIVE') as varchar2(10)),
       o.ctime, bdur, msize,
       decode(bitand(m.properties,1),1,'YES','NO'), c.comment$
from sys.model$ m, sys.obj$ o, sys.user$ u, sys.com$ c,
         (select mod#, value from sys.modelset$
          where bitand(properties,2) != 2 and name = 'ALGO_NAME') s 
where o.obj#=m.obj#
  and o.obj#=c.obj#(+)
  and o.type#=82
  and o.owner#=u.user#
  and o.obj#=s.mod#(+)
/
comment on table DBA_MINING_MODELS is
'Description of all the models in the database'
/
comment on column DBA_MINING_MODELS.OWNER is
'Owner of the model'
/
comment on column DBA_MINING_MODELS.MODEL_NAME is
'Name of the model'
/
comment on column DBA_MINING_MODELS.MINING_FUNCTION is
'Mining function of the model'
/
comment on column DBA_MINING_MODELS.ALGORITHM is
'Algorithm of the model'
/
comment on column DBA_MINING_MODELS.ALGORITHM_TYPE is
'Algorithm type of the model'
/
comment on column DBA_MINING_MODELS.CREATION_DATE is
'Creation date of the model'
/
comment on column DBA_MINING_MODELS.BUILD_DURATION is
'Model build time (in seconds)'
/
comment on column DBA_MINING_MODELS.MODEL_SIZE is
'Model size (in Mb)'
/
comment on column DBA_MINING_MODELS.COMMENTS is
'Model comments'
/
create or replace public synonym DBA_MINING_MODELS for DBA_MINING_MODELS
/
grant select on DBA_MINING_MODELS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_MINING_MODELS','CDB_MINING_MODELS');
grant select on SYS.CDB_MINING_MODELS to select_catalog_role
/
create or replace public synonym CDB_MINING_MODELS for SYS.CDB_MINING_MODELS
/

remark  List of model attributes
remark
create or replace view USER_MINING_MODEL_ATTRIBUTES
    (MODEL_NAME, ATTRIBUTE_NAME, ATTRIBUTE_TYPE, DATA_TYPE,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, USAGE_TYPE, TARGET,
     ATTRIBUTE_SPEC)
as
select o.name, a.name,
       decode(atyp, /* attribute type */
              1, 'NUMERICAL',
              2, 'CATEGORICAL',
              3, 'TEXT',
              4, 'MIXED',
              5, 'PARTITION',
                 'UNDEFINED'),
       case when bitand(a.properties,8) = 8
       then
         decode(dtyp, /* nested data type */
                1, 'DM_NESTED_CATEGORICALS',
                2, 'DM_NESTED_NUMERICALS',
              100, 'DM_NESTED_BINARY_FLOATS',
              101, 'DM_NESTED_BINARY_DOUBLES')
       else
         decode(dtyp, /* data type */
                       1, decode(bitand(a.properties,16), 16, 
                                 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(a.scale, null,
                                 decode(a.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       4, 'FLOAT',
                       8, 'LONG',
                       9, decode(bitand(a.properties,16), 16, 
                                 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       69, 'ROWID',
                       96, decode(bitand(a.properties,16), 16, 
                                  'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       112, decode(bitand(a.properties,16), 16, 
                                   'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       178, 'TIME(' ||a.scale|| ')',
                       179, 'TIME(' ||a.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||a.scale|| ')',
                       181, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||a.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||a.precision#||') TO SECOND(' ||
                             a.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED')
       end,
       a.length,
       a.precision#,
       a.scale,
       decode(bitand(a.properties,3),0,'INACTIVE','ACTIVE'),
       decode(bitand(a.properties,2),2,'YES','NO'),
       a.attrspec
from sys.modelatt$ a, sys.obj$ o
where o.obj#=a.mod#
  and o.owner#=userenv('SCHEMAID')
  and bitand(a.properties, 3) != 0
/
comment on table USER_MINING_MODEL_ATTRIBUTES is
'Description of the user''s own model attributes'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.MODEL_NAME is
'Name of the model to which the attribute belongs'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_NAME is
'Name of the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_TYPE is
'Mining type of the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.DATA_TYPE is
'Data type of the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.DATA_LENGTH is
'Data length of the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.DATA_PRECISION is
'Data precision of the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.DATA_SCALE is
'Data scale of the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.USAGE_TYPE is
'Usage type for the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_SPEC is
'Attribute specification for the attribute'
/
create or replace public synonym USER_MINING_MODEL_ATTRIBUTES
  for USER_MINING_MODEL_ATTRIBUTES
/
grant read on USER_MINING_MODEL_ATTRIBUTES to public
/
create or replace view ALL_MINING_MODEL_ATTRIBUTES
    (OWNER, MODEL_NAME, ATTRIBUTE_NAME, ATTRIBUTE_TYPE, DATA_TYPE,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, USAGE_TYPE, TARGET,
     ATTRIBUTE_SPEC)
as
select u.name, o.name, a.name,
       decode(atyp, /* attribute type */
              1, 'NUMERICAL',
              2, 'CATEGORICAL',
              3, 'TEXT',
              4, 'MIXED',
              5, 'PARTITION',
                 'UNDEFINED'),
       case when bitand(a.properties,8) = 8
       then
         decode(dtyp, /* nested data type */
                1, 'DM_NESTED_CATEGORICALS',
                2, 'DM_NESTED_NUMERICALS',
              100, 'DM_NESTED_BINARY_FLOATS',
              101, 'DM_NESTED_BINARY_DOUBLES')
       else
         decode(dtyp, /* data type */
                       1, decode(bitand(a.properties,16), 16, 
                                 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(a.scale, null,
                                 decode(a.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       4, 'FLOAT',
                       8, 'LONG',
                       9, decode(bitand(a.properties,16), 16, 
                                 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       69, 'ROWID',
                       96, decode(bitand(a.properties,16), 16, 
                                  'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       112, decode(bitand(a.properties,16), 16, 
                                   'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       178, 'TIME(' ||a.scale|| ')',
                       179, 'TIME(' ||a.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||a.scale|| ')',
                       181, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||a.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||a.precision#||') TO SECOND(' ||
                             a.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED')
       end,
       a.length,
       a.precision#,
       a.scale,
       decode(bitand(a.properties,3),0,'INACTIVE','ACTIVE'),
       decode(bitand(a.properties,2),2,'YES','NO'),
       a.attrspec
from sys.modelatt$ a, sys.obj$ o, sys.user$ u
where o.obj#=a.mod#
  and o.owner#=u.user#
  and (o.owner#=userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
      )
  and bitand(a.properties, 3) != 0
/
comment on table ALL_MINING_MODEL_ATTRIBUTES is
'Description of all the model attributes accessible to the user'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.MODEL_NAME is
'Name of the model to which the attribute belongs'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_NAME is
'Name of the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_TYPE is
'Mining type of the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.DATA_TYPE is
'Data type of the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.DATA_LENGTH is
'Data length of the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.DATA_PRECISION is
'Data precision of the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.DATA_SCALE is
'Data scale of the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.USAGE_TYPE is
'Usage type for the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_SPEC is
'Attribute specification for the attribute'
/
create or replace public synonym ALL_MINING_MODEL_ATTRIBUTES
  for ALL_MINING_MODEL_ATTRIBUTES
/
grant read on ALL_MINING_MODEL_ATTRIBUTES to public
/
create or replace view DBA_MINING_MODEL_ATTRIBUTES
    (OWNER, MODEL_NAME, ATTRIBUTE_NAME, ATTRIBUTE_TYPE,
     DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE,
     USAGE_TYPE, TARGET, ATTRIBUTE_SPEC)
as
select u.name, o.name, a.name,
       decode(atyp, /* attribute type */
              1, 'NUMERICAL',
              2, 'CATEGORICAL',
              3, 'TEXT',
              4, 'MIXED',
              5, 'PARTITION',
                 'UNDEFINED'),
       case when bitand(a.properties,8) = 8
       then
         decode(dtyp, /* nested data type */
                1, 'DM_NESTED_CATEGORICALS',
                2, 'DM_NESTED_NUMERICALS',
              100, 'DM_NESTED_BINARY_FLOATS',
              101, 'DM_NESTED_BINARY_DOUBLES')
       else
         decode(dtyp, /* data type */
                       1, decode(bitand(a.properties,16), 16, 
                                 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(a.scale, null,
                                 decode(a.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       4, 'FLOAT',
                       8, 'LONG',
                       9, decode(bitand(a.properties,16), 16, 
                                 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       69, 'ROWID',
                       96, decode(bitand(a.properties,16), 16, 
                                  'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       112, decode(bitand(a.properties,16), 16, 
                                   'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       178, 'TIME(' ||a.scale|| ')',
                       179, 'TIME(' ||a.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||a.scale|| ')',
                       181, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||a.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||a.precision#||') TO SECOND(' ||
                             a.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED')
       end,
       a.length,
       a.precision#,
       a.scale,
       decode(bitand(a.properties,3),0,'INACTIVE','ACTIVE'),
       decode(bitand(a.properties,2),2,'YES','NO'),
       a.attrspec
from sys.modelatt$ a, sys.obj$ o, sys.user$ u
where o.obj#=a.mod#
  and o.owner#=u.user#
  and bitand(a.properties, 3) != 0
/
comment on table DBA_MINING_MODEL_ATTRIBUTES is
'Description of all the model attributes in the database'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.MODEL_NAME is
'Name of the model to which the attribute belongs'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_NAME is
'Name of the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_TYPE is
'Mining type of the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.DATA_TYPE is
'Data type of the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.DATA_LENGTH is
'Data length of the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.DATA_PRECISION is
'Data precision of the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.DATA_SCALE is
'Data scale of the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.USAGE_TYPE is
'Usage type for the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_SPEC is
'Attribute specification for the attribute'
/
create or replace public synonym DBA_MINING_MODEL_ATTRIBUTES 
  for DBA_MINING_MODEL_ATTRIBUTES
/
grant select on DBA_MINING_MODEL_ATTRIBUTES to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_MINING_MODEL_ATTRIBUTES','CDB_MINING_MODEL_ATTRIBUTES');
grant select on SYS.CDB_MINING_MODEL_ATTRIBUTES to select_catalog_role
/
create or replace public synonym CDB_MINING_MODEL_ATTRIBUTES for SYS.CDB_MINING_MODEL_ATTRIBUTES
/

remark  List of model settings
remark
create or replace view USER_MINING_MODEL_SETTINGS
    (MODEL_NAME, SETTING_NAME, SETTING_VALUE, SETTING_TYPE)
as
select o.name, s.name, s.value,
       decode(bitand(s.properties,1),1,'INPUT','DEFAULT')
from sys.modelset$ s, sys.obj$ o
where s.mod#=o.obj#
  and o.owner#=userenv('SCHEMAID')
  and bitand(s.properties,2) != 2
/
comment on table USER_MINING_MODEL_SETTINGS is
'Description of the user''s own model settings'
/
comment on column USER_MINING_MODEL_SETTINGS.MODEL_NAME is
'Name of the model to which the setting belongs'
/
comment on column USER_MINING_MODEL_SETTINGS.SETTING_NAME is
'Name of the setting'
/
comment on column USER_MINING_MODEL_SETTINGS.SETTING_VALUE is
'Value of the setting'
/
comment on column USER_MINING_MODEL_SETTINGS.SETTING_TYPE is
'Type of the setting'
/
create or replace public synonym USER_MINING_MODEL_SETTINGS
  for USER_MINING_MODEL_SETTINGS
/
grant read on USER_MINING_MODEL_SETTINGS to public
/
create or replace view ALL_MINING_MODEL_SETTINGS
    (OWNER, MODEL_NAME, SETTING_NAME, SETTING_VALUE, SETTING_TYPE)
as
select u.name, o.name, s.name, s.value,
       decode(s.properties,1,'INPUT','DEFAULT')
from sys.modelset$ s, sys.obj$ o, sys.user$ u
where s.mod#=o.obj#
  and o.owner#=u.user#
  and (o.owner#=userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
      )
  and bitand(s.properties,2) != 2
/
comment on table ALL_MINING_MODEL_SETTINGS is
'Description of all the settings accessible to the user'
/
comment on column ALL_MINING_MODEL_SETTINGS.MODEL_NAME is
'Name of the model to which the setting belongs'
/
comment on column ALL_MINING_MODEL_SETTINGS.SETTING_NAME is
'Name of the setting'
/
comment on column ALL_MINING_MODEL_SETTINGS.SETTING_VALUE is
'Value of the setting'
/
comment on column ALL_MINING_MODEL_SETTINGS.SETTING_TYPE is
'Type of the setting'
/
create or replace public synonym ALL_MINING_MODEL_SETTINGS
  for ALL_MINING_MODEL_SETTINGS
/
grant read on ALL_MINING_MODEL_SETTINGS to public
/
create or replace view DBA_MINING_MODEL_SETTINGS
    (OWNER, MODEL_NAME, SETTING_NAME, SETTING_VALUE, SETTING_TYPE)
as
select u.name, o.name, s.name, s.value,
       decode(s.properties,1,'INPUT','DEFAULT')
from sys.modelset$ s, sys.obj$ o, sys.user$ u
where s.mod#=o.obj#
  and o.owner#=u.user#
  and bitand(s.properties,2) != 2
/
comment on table DBA_MINING_MODEL_SETTINGS is
'Description of all the model settings in the database'
/
comment on column DBA_MINING_MODEL_SETTINGS.MODEL_NAME is
'Name of the model to which the setting belongs'
/
comment on column DBA_MINING_MODEL_SETTINGS.SETTING_NAME is
'Name of the setting'
/
comment on column DBA_MINING_MODEL_SETTINGS.SETTING_VALUE is
'Value of the setting'
/
comment on column DBA_MINING_MODEL_SETTINGS.SETTING_TYPE is
'Type of the setting'
/
create or replace public synonym  DBA_MINING_MODEL_SETTINGS
  for DBA_MINING_MODEL_SETTINGS
/
grant select on DBA_MINING_MODEL_SETTINGS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_MINING_MODEL_SETTINGS','CDB_MINING_MODEL_SETTINGS');
grant select on SYS.CDB_MINING_MODEL_SETTINGS to select_catalog_role
/
create or replace public synonym CDB_MINING_MODEL_SETTINGS for SYS.CDB_MINING_MODEL_SETTINGS
/

remark
create or replace view DBA_MINING_MODEL_TABLES
    (OWNER, MODEL_NAME, TABLE_NAME, TABLE_TYPE)
as
select u.name,
       o1.name,
       o2.name,
       decode(typ#,
              1, 'categoricalMapTable',
              2, 'explosionMapTable',
              3, 'rulesTable',
              4, 'priorsTable',
              5, 'emAttrImportance',
              6, 'emAttrPairs',
              7, 'clDescriptionTable',
              8, 'clCentroidTable',
              9, 'clTaxonomyTable',
             10, 'clParameterTable',
             11, 'clHistogramTable',
             12, 'clBinBoundaryTable',
             13, 'clRuleTable',
             14, 'clPredicateTable',
             15, 'clCentModeTable',
             16, 'treeTgtMap',
             17, 'treeTgtHist',
             18, 'treeSplit',
             19, 'treeSplitCat',
             20, 'treeParams',
             21, 'svmParams',
             22, 'svmSettings',
             23, 'svmCoefficients',
             24, 'svmSqnorm',
             25, 'svmAlphas',
             26, 'supportVectors',
             27, 'nmfEncodedMatrix',
             28, 'costTable',
             29, 'itemBinTable',
             30, 'itemSetTable',
             31, 'itemSetItemTable',
             32, 'ocClusterTable',
             33, 'ocRulesTable',
             34, 'aiTable',
             35, 'xformTable',
             36, 'costScoreTable',
             37, 'glmGlobDiagTable',
             38, 'glmModelDiagTable', 
             39, 'glmFisherTable',
             40, 'glmMappingTable',
             41, 'glmFtrCmpTable',
             42, 'glmScoreInfoTable',
             43, 'glmTgtMapTable',
             44, 'ocSplitPredicateTable',
             45, 'xfNorm',
             46, 'adpDataTable',
             47, 'nmfInvertedMatrix',
             48, 'adpBinDataTable',
             49, 'svdSMatrixTable',
             50, 'svdVMatrixTable',
             51, 'svdUMatrixTable',
             52, 'svdGlobInfoTable',  
             53, 'textTable',
             54, 'emPriorTable',
             55, 'emMeanTable',
             56, 'emCovarTable',
             57, 'emHistTable',
             58, 'emGlobInfoTable',
             59, 'ColumnMapTable',
             60, 'QuantileBinTable',
             61, 'TopNBinTable',
             62, 'EquiWidthBinTable',
             63, 'ProjectionTable',
             64, 'rulesTable2',
             65, 'svmBases',
             66, 'globalInfo',
             67, 'adpBinRDataTable',
             68, 'rGlue',
             69, 'glmRowDiagClass',
             70, 'glmRowDiagRegr',
             71, 'esaTopicMapping',
             72, 'esaTopicWeights',
             73, 'serializedModelObject',
             74, 'forestVariableImp',  
             75, 'forestParams',
             76, 'nnFirstLayerWeights',
             77, 'nnWeights',
             78, 'nnArchitecture',
             79, 'exponentialSmoothing',
             80, 'CURattributes',
             81, 'CURrows',  
                 'UNDEFINED')
from sys.model$ m, sys.modeltab$ t, sys.obj$ o1, sys.obj$ o2, sys.user$ u
where m.obj#=o1.obj#
  and m.obj#=t.mod#
  and t.obj#=o2.obj#
  and t.typ# < 100
  and o1.owner#=u.user#;
/
comment on table DBA_MINING_MODEL_TABLES is
'Description of all the mining model tables in the system'
/
comment on column DBA_MINING_MODEL_TABLES.OWNER is
'Name of the owner to which the table belongs'
/
comment on column DBA_MINING_MODEL_TABLES.MODEL_NAME is
'Name of the model to which the table belongs'
/
comment on column DBA_MINING_MODEL_TABLES.TABLE_NAME is
'Name of the model table'
/
comment on column DBA_MINING_MODEL_TABLES.TABLE_TYPE is
'Name of the mining model table type'
/
grant select on DBA_MINING_MODEL_TABLES to select_catalog_role
/
create or replace public synonym DBA_MINING_MODEL_TABLES
 for DBA_MINING_MODEL_TABLES
/

execute CDBView.create_cdbview(false,'SYS','DBA_MINING_MODEL_TABLES','CDB_MINING_MODEL_TABLES');
grant select on SYS.CDB_MINING_MODEL_TABLES to select_catalog_role
/
create or replace public synonym CDB_MINING_MODEL_TABLES for SYS.CDB_MINING_MODEL_TABLES
/

create or replace view USER_MINING_MODEL_VIEWS
    (MODEL_NAME, VIEW_NAME, VIEW_TYPE)
as
select 
       o1.name,
       o2.name,
       cast(decode(typ#-32767,
	        1 , 'Clustering Description',
	        2 , 'Clustering Attribute Statistics',
	        3 , 'Clustering Histograms',
	        4 , 'Clustering Rules',
	        5 , 'Model Build Alerts',
	        6 , 'Computed Settings',
	        7 , 'Global Name-Value Pairs',
	        8 , 'Classification Targets',
	        9 , 'Scoring Cost Matrix',
	       10 , 'Decision Tree Build Cost Matrix',
	       11 , 'Text Features',
	       12 , 'Normalization and Missing Value Handling',
	       13 , 'Automatic Data Preparation Binning',
	       14 , 'Decision Tree Hierarchy',
	       15 , 'Decision Tree Statistics',
	       16 , 'Decision Tree Nodes',
	       17 , 'Association Rules',
	       18 , 'Association Rule Itemsets',
	       19 , 'SVM Linear Coefficients',
	       20 , 'Expectation Maximization Components',
	       21 , 'Expectation Maximization Projections',
	       22 , 'GLM Regression Attribute Diagnostics',
	       23 , 'GLM Regression Row Diagnostics',
	       24 , 'GLM Classification Attribute Diagnostics',
	       25 , 'GLM Classification Row Diagnostics',
           26 , 'Extensible R Algorithm',
           27 , 'Attribute Importance',
           28 , 'Naive Bayes Target Priors',
           29 , 'Naive Bayes Conditional Probabilities',
           30 , 'Explicit Semantic Analysis Matrix',
           31 , 'Explicit Semantic Analysis Features',
           32 , 'Singular Value Decomposition U Matrix',
           33 , 'Singular Value Decomposition S Matrix',
           34 , 'Singular Value Decomposition V Matrix',
           35 , 'k-Means Scoring Centroids',
           36 , 'Non-Negative Matrix Factorization H Matrix',
           37 , 'Non-Negative Matrix Factorization Inverse H Matrix',
           38 , 'Expectation Maximization Gaussian parameters',
           39 , 'Expectation Maximization Bernoulli parameters',
           40 , 'Unsupervised Attribute Importance',
           41 , 'Attribute Pair Kullback-Leibler Divergence',
           42 , 'Association Rule Itemsets For Transactional Data',
           43 , 'Association Rules For Transactional Data',
           44 , 'Neural Network Weights',
           45 , 'Exponential Smoothing Forecast',
           46 , 'CUR Decomposition-Based Attribute Importance',
           47 , 'CUR Decomposition-Based Row Importance',
           48 , 'Variable Importance',
           49 , 'Extensible R Algorithm View 1',
           50 , 'Extensible R Algorithm View 2',
           51 , 'Extensible R Algorithm View 3',
           52 , 'Extensible R Algorithm View 4',
           53 , 'Extensible R Algorithm View 5',
           54 , 'Extensible R Algorithm View 6',
           55 , 'Extensible R Algorithm View 7',
           56 , 'Extensible R Algorithm View 8',
           57 , 'Extensible R Algorithm View 9',
           58 , 'Extensible R Algorithm View 10',
                 'UNDEFINED') as varchar2(128))
from sys.model$ m, sys.modeltab$ t, sys.obj$ o1, sys.obj$ o2
where m.obj#=o1.obj#
  and m.obj#=t.mod#
  and t.obj#=o2.obj#
  and t.typ# >= 32767
  and o1.owner#=userenv('SCHEMAID')
/
create or replace public synonym USER_MINING_MODEL_VIEWS for USER_MINING_MODEL_VIEWS;

grant read on USER_MINING_MODEL_VIEWS to public;
/

comment on table USER_MINING_MODEL_VIEWS is
'Description of the user''s own model views'
/
comment on column USER_MINING_MODEL_VIEWS.MODEL_NAME is
'Name of the model to which model views belongs'
/
comment on column USER_MINING_MODEL_VIEWS.VIEW_NAME is
'Name of the model view'
/
comment on column USER_MINING_MODEL_VIEWS.VIEW_TYPE is
'Type of the model view'
/

create or replace view ALL_MINING_MODEL_VIEWS
    (OWNER, MODEL_NAME, VIEW_NAME, VIEW_TYPE)
as
select u.name,
       o1.name,
       o2.name,
       cast(decode(typ#-32767,
            1 , 'Clustering Description',
	        2 , 'Clustering Attribute Statistics',
	        3 , 'Clustering Histograms',
	        4 , 'Clustering Rules',
	        5 , 'Model Build Alerts',
	        6 , 'Computed Settings',
	        7 , 'Global Name-Value Pairs',
	        8 , 'Classification Targets',
	        9 , 'Scoring Cost Matrix',
	       10 , 'Decision Tree Build Cost Matrix',
	       11 , 'Text Features',
	       12 , 'Normalization and Missing Value Handling',
	       13 , 'Automatic Data Preparation Binning',
	       14 , 'Decision Tree Hierarchy',
	       15 , 'Decision Tree Statistics',
	       16 , 'Decision Tree Nodes',
	       17 , 'Association Rules',
	       18 , 'Association Rule Itemsets',
	       19 , 'SVM Linear Coefficients',
	       20 , 'Expectation Maximization Components',
	       21 , 'Expectation Maximization Projections',
	       22 , 'GLM Regression Attribute Diagnostics',
	       23 , 'GLM Regression Row Diagnostics',
	       24 , 'GLM Classification Attribute Diagnostics',
	       25 , 'GLM Classification Row Diagnostics',
           26 , 'Extensible R Algorithm',
           27 , 'Attribute Importance',
           28 , 'Naive Bayes Target Priors',
           29 , 'Naive Bayes Conditional Probabilities',
           30 , 'Explicit Semantic Analysis Matrix',
           31 , 'Explicit Semantic Analysis Features',
           32 , 'Singular Value Decomposition U Matrix',
           33 , 'Singular Value Decomposition S Matrix',
           34 , 'Singular Value Decomposition V Matrix',
           35 , 'k-Means Scoring Centroids',
           36 , 'Non-Negative Matrix Factorization H Matrix',
           37 , 'Non-Negative Matrix Factorization Inverse H Matrix',
           38 , 'Expectation Maximization Gaussian parameters',
           39 , 'Expectation Maximization Bernoulli parameters',
           40 , 'Unsupervised Attribute Importance',
           41 , 'Attribute Pair Kullback-Leibler Divergence',
           42 , 'Association Rule Itemsets for transactional data',
           43 , 'Association Rules for transactional data',
           44 , 'Neural Network Weights',
           45 , 'Exponential Smoothing Forecast',
           46 , 'CUR Decomposition-Based Attribute Importance',
           47 , 'CUR Decomposition-Based Row Importance',
           48 , 'Variable Importance',
           49 , 'Extensible R Algorithm View 1',
           50 , 'Extensible R Algorithm View 2',
           51 , 'Extensible R Algorithm View 3',
           52 , 'Extensible R Algorithm View 4',
           53 , 'Extensible R Algorithm View 5',
           54 , 'Extensible R Algorithm View 6',
           55 , 'Extensible R Algorithm View 7',
           56 , 'Extensible R Algorithm View 8',
           57 , 'Extensible R Algorithm View 9',
           58 , 'Extensible R Algorithm View 10',
                 'UNDEFINED') as varchar2(128))
from sys.model$ m, sys.modeltab$ t, sys.obj$ o1, sys.obj$ o2, sys.user$ u
where m.obj#=o1.obj#
  and m.obj#=t.mod#
  and t.obj#=o2.obj#
  and o1.owner#=u.user#
  and t.typ# >= 32767
  and (o1.owner#=userenv('SCHEMAID')
       or o1.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          ora_check_sys_privilege (o1.owner#, o1.type#) = 1
     )
/


comment on table  ALL_MINING_MODEL_VIEWS is
'Description of all the model views accessible to the user'
/
comment on column ALL_MINING_MODEL_VIEWS.MODEL_NAME is
'Name of the model to which model views belongs'
/
comment on column ALL_MINING_MODEL_VIEWS.VIEW_NAME is
'Name of the model view'
/
comment on column ALL_MINING_MODEL_VIEWS.VIEW_TYPE is
'Type of the model view'
/

create or replace public synonym ALL_MINING_MODEL_VIEWS for ALL_MINING_MODEL_VIEWS;

grant read on ALL_MINING_MODEL_VIEWS to public
/


create or replace view DBA_MINING_MODEL_VIEWS
    (OWNER, MODEL_NAME, VIEW_NAME, VIEW_TYPE)
as
select u.name,
       o1.name,
       o2.name,
       cast(decode(typ#-32767,
            1 , 'Clustering Description',
            2 , 'Clustering Attribute Statistics',
            3 , 'Clustering Histograms',
	        4 , 'Clustering Rules',
	        5 , 'Model Build Alerts',
	        6 , 'Computed Settings',
	        7 , 'Global Name-Value Pairs',
	        8 , 'Classification Targets',
	        9 , 'Scoring Cost Matrix',
	       10 , 'Decision Tree Build Cost Matrix',
	       11 , 'Text Features',
	       12 , 'Normalization and Missing Value Handling',
	       13 , 'Automatic Data Preparation Binning',
	       14 , 'Decision Tree Hierarchy',
	       15 , 'Decision Tree Statistics',
	       16 , 'Decision Tree Nodes',
	       17 , 'Association Rules',
	       18 , 'Association Rule Itemsets',
	       19 , 'SVM Linear Coefficients',
	       20 , 'Expectation Maximization Components',
	       21 , 'Expectation Maximization Projections',
	       22 , 'GLM Regression Attribute Diagnostics',
	       23 , 'GLM Regression Row Diagnostics',
	       24 , 'GLM Classification Attribute Diagnostics',
	       25 , 'GLM Classification Row Diagnostics',
           26 , 'Extensible R Algorithm',
           27 , 'Attribute Importance',
           28 , 'Naive Bayes Target Priors',
           29 , 'Naive Bayes Conditional Probabilities',
           30 , 'Explicit Semantic Analysis Matrix',
           31 , 'Explicit Semantic Analysis Features',
           32 , 'Singular Value Decomposition U Matrix',
           33 , 'Singular Value Decomposition S Matrix',
           34 , 'Singular Value Decomposition V Matrix',
           35 , 'k-Means Scoring Centroids',
           36 , 'Non-Negative Matrix Factorization H Matrix',
           37 , 'Non-Negative Matrix Factorization Inverse H Matrix',
           38 , 'Expectation Maximization Gaussian parameters',
           39 , 'Expectation Maximization Bernoulli parameters',
           40 , 'Unsupervised Attribute Importance',
           41 , 'Attribute Pair Kullback-Leibler Divergence',
           42 , 'Association Rule Itemsets for transactional data',
           43 , 'Association Rules for transactional data',
           44 , 'Neural Network Weights',
           45 , 'Exponential Smoothing Forecast',
           46 , 'CUR Decomposition-Based Attribute Importance',
           47 , 'CUR Decomposition-Based Row Importance',
           48 , 'Variable Importance',
           49 , 'Extensible R Algorithm View 1',
           50 , 'Extensible R Algorithm View 2',
           51 , 'Extensible R Algorithm View 3',
           52 , 'Extensible R Algorithm View 4',
           53 , 'Extensible R Algorithm View 5',
           54 , 'Extensible R Algorithm View 6',
           55 , 'Extensible R Algorithm View 7',
           56 , 'Extensible R Algorithm View 8',
           57 , 'Extensible R Algorithm View 9',
           58 , 'Extensible R Algorithm View 10',
                 'UNDEFINED') as varchar2(128))
from sys.model$ m, sys.modeltab$ t, sys.obj$ o1, sys.obj$ o2, sys.user$ u
where m.obj#=o1.obj#
  and m.obj#=t.mod#
  and t.obj#=o2.obj#
  and o1.owner#=u.user#
  and t.typ# >= 32767
 /

comment on table  DBA_MINING_MODEL_VIEWS is
'Description of all the model views in the database'
/
comment on column DBA_MINING_MODEL_VIEWS.MODEL_NAME is
'Name of the model to which the model views belongs'
/
comment on column DBA_MINING_MODEL_VIEWS.VIEW_NAME is
'Name of the model view'
/
comment on column DBA_MINING_MODEL_VIEWS.VIEW_TYPE is
'Type of the model view'
/
create or replace public synonym DBA_MINING_MODEL_VIEWS for DBA_MINING_MODEL_VIEWS
/
grant select on DBA_MINING_MODEL_VIEWS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_MINING_MODEL_VIEWS','CDB_MINING_MODEL_VIEWS');
grant select on SYS.CDB_MINING_MODEL_VIEWS to select_catalog_role
/
create or replace public synonym CDB_MINING_MODEL_VIEWS for SYS.CDB_MINING_MODEL_VIEWS
/


create or replace view DM_USER_MODELS
    (NAME, FUNCTION_NAME, ALGORITHM_NAME, CREATION_DATE,
     BUILD_DURATION, TARGET_ATTRIBUTE, MODEL_SIZE)
as
select m.model_name, mining_function, algorithm,
     creation_date, build_duration, attribute_name, model_size
from user_mining_models m, user_mining_model_attributes a
where m.model_name=a.model_name(+)
  and target(+)='YES'
/
create or replace public synonym DM_USER_MODELS for SYS.DM_USER_MODELS
/
grant read on DM_USER_MODELS to public
/
remark  List of user mining model partitions
remark
create or replace view USER_MINING_MODEL_PARTITIONS
    (MODEL_NAME, PARTITION_NAME, POSITION, COLUMN_NAME, COLUMN_VALUE)
as
select model_name, partition_name, position, column_name, hiboundval from (
select o.name model_name,
       o.subname partition_name,
       mp.pos#  position,
       mpc.name column_name,
       hiboundval       
from modelpart$ mp, obj$ o, modelpartcol$ mpc
where mp.obj#=o.obj#
  and o.owner#=userenv('SCHEMAID')
  and mp.mod#=mpc.obj#
  and mp.pos#=mpc.pos#
  and mp.pos# is not null)
/
comment on table USER_MINING_MODEL_PARTITIONS is
'Description of the user''s own model partitions'
/
comment on column USER_MINING_MODEL_PARTITIONS.MODEL_NAME is
'Name of the model'
/
comment on column USER_MINING_MODEL_PARTITIONS.PARTITION_NAME is
'Name of the model partition'
/
comment on column USER_MINING_MODEL_PARTITIONS.POSITION is
'Column position number for partitioning column'
/
comment on column USER_MINING_MODEL_PARTITIONS.COLUMN_NAME is
'Name of the column used for partitioning'
/
comment on column USER_MINING_MODEL_PARTITIONS.COLUMN_VALUE is
'Value of the column for this partition'
/
create or replace public synonym USER_MINING_MODEL_PARTITIONS for USER_MINING_MODEL_PARTITIONS
/
grant read on USER_MINING_MODEL_PARTITIONS to public;
/
remark  List of all mining model partitions
remark
create or replace view ALL_MINING_MODEL_PARTITIONS
    (OWNER, MODEL_NAME, PARTITION_NAME, POSITION, COLUMN_NAME, COLUMN_VALUE)
as
select owner, model_name, partition_name, position, column_name, hiboundval from (
select u.name owner,
       o.name model_name,
       o.subname partition_name,
       mp.pos#  position,
       mpc.name column_name,
       hiboundval       
from modelpart$ mp, obj$ o, modelpartcol$ mpc, sys.user$ u
where mp.obj#=o.obj#
  and o.owner#=u.user#
  and (o.owner#=userenv('SCHEMAID')
    or mp.mod# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
      )
  and mp.mod#=mpc.obj#
  and mp.pos#=mpc.pos#
  and mp.pos# is not null)
/
comment on table ALL_MINING_MODEL_PARTITIONS is
'Description of all the partitions accessible to the user'
/
comment on column ALL_MINING_MODEL_PARTITIONS.OWNER is
'Name of the model owner'
/
comment on column ALL_MINING_MODEL_PARTITIONS.MODEL_NAME is
'Name of the model'
/
comment on column ALL_MINING_MODEL_PARTITIONS.PARTITION_NAME is
'Name of the model partition'
/
comment on column ALL_MINING_MODEL_PARTITIONS.POSITION is
'Column position number for partitioning column'
/
comment on column ALL_MINING_MODEL_PARTITIONS.COLUMN_NAME is
'Name of the column used for partitioning'
/
comment on column ALL_MINING_MODEL_PARTITIONS.COLUMN_VALUE is
'Value of the column for this partition'
/
create or replace public synonym ALL_MINING_MODEL_PARTITIONS for ALL_MINING_MODEL_PARTITIONS
/
grant read on ALL_MINING_MODEL_PARTITIONS to public;
/
remark  List of dba mining model partitions
remark
create or replace view DBA_MINING_MODEL_PARTITIONS
    (OWNER, MODEL_NAME, PARTITION_NAME, PARTITION_NUMBER, POSITION, COLUMN_NAME, COLUMN_VALUE)
as
select owner, model_name, partition_name, partition_number, position,
       column_name, hiboundval from (
select u.name owner,
       o.name model_name,
       o.subname partition_name,
       mp.part# partition_number,
       mp.pos#  position,
       mpc.name column_name,
       hiboundval       
from modelpart$ mp, obj$ o, modelpartcol$ mpc, sys.user$ u
where mp.obj#=o.obj#
  and o.owner#=u.user#
  and mp.mod#=mpc.obj#
  and mp.pos#=mpc.pos#
  and mp.pos# is not null)
/
comment on table DBA_MINING_MODEL_PARTITIONS is
'Description of all the partitions accessible to the system'
/
comment on column DBA_MINING_MODEL_PARTITIONS.OWNER is
'Name of the model owner'
/
comment on column DBA_MINING_MODEL_PARTITIONS.MODEL_NAME is
'Name of the model'
/
comment on column DBA_MINING_MODEL_PARTITIONS.PARTITION_NAME is
'Name of the model partition'
/
comment on column DBA_MINING_MODEL_PARTITIONS.POSITION is
'Column position number for partitioning column'
/
comment on column DBA_MINING_MODEL_PARTITIONS.COLUMN_NAME is
'Name of the column used for partitioning'
/
comment on column DBA_MINING_MODEL_PARTITIONS.COLUMN_VALUE is
'Value of the column for this partition'
/
create or replace public synonym DBA_MINING_MODEL_PARTITIONS for DBA_MINING_MODEL_PARTITIONS
/
grant select on DBA_MINING_MODEL_PARTITIONS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_MINING_MODEL_PARTITIONS','CDB_MINING_MODEL_PARTITIONS');
grant select on SYS.CDB_MINING_MODEL_PARTITIONS to select_catalog_role
/
create or replace public synonym CDB_MINING_MODEL_PARTITIONS for SYS.CDB_MINING_MODEL_PARTITIONS
/

remark
remark  FAMILY "DATA MINING MODEL TRANSFORMATIONS"
remark  User-specified embedded transformations
remark
create or replace view USER_MINING_MODEL_XFORMS
    (MODEL_NAME, ATTRIBUTE_NAME, ATTRIBUTE_SUBNAME, 
     ATTRIBUTE_SPEC, EXPRESSION, REVERSE)
as
select o.name, x.attr, x.subn, x.attrspec, x.expr,
       decode(bitand(x.properties,16),16,'YES','NO')
from sys.obj$ o, sys.modelxfm$ x
where o.obj#=x.mod#
  and o.owner#=userenv('SCHEMAID')
  and bitand(x.properties,256) != 0
/
comment on table USER_MINING_MODEL_XFORMS is
'User-specified transformations embedded with the user''s own models'
/
comment on column USER_MINING_MODEL_XFORMS.MODEL_NAME is
'Name of the model'
/
comment on column USER_MINING_MODEL_XFORMS.ATTRIBUTE_NAME is
'Name of the attribute used in the transformation'
/
comment on column USER_MINING_MODEL_XFORMS.ATTRIBUTE_SUBNAME is
'Subame of the attribute used in the transformation'
/
comment on column USER_MINING_MODEL_XFORMS.ATTRIBUTE_SPEC is
'Attribute specification provided to model training'
/
comment on column USER_MINING_MODEL_XFORMS.EXPRESSION is
'Forward expression provided to model training'
/
comment on column USER_MINING_MODEL_XFORMS.REVERSE is
'Reverse expression'
/
create or replace public synonym USER_MINING_MODEL_XFORMS for USER_MINING_MODEL_XFORMS
/
grant read on USER_MINING_MODEL_XFORMS to public;
/
create or replace view ALL_MINING_MODEL_XFORMS
    (OWNER, MODEL_NAME, ATTRIBUTE_NAME, ATTRIBUTE_SUBNAME,
     ATTRIBUTE_SPEC, EXPRESSION, REVERSE)
as
select u.name, o.name, x.attr, x.subn, x.attrspec, x.expr,
       decode(bitand(x.properties,16),16,'YES','NO')
from sys.obj$ o, sys.user$ u, sys.modelxfm$ x
where o.obj#=x.mod#
  and o.owner#=u.user#
  and bitand(x.properties,256) != 0
  and (o.owner#=userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
      )
/
comment on table ALL_MINING_MODEL_XFORMS is
'User-specified transformations embedded in all models accessible to the user'
/
comment on column ALL_MINING_MODEL_XFORMS.OWNER is
'Name of the model owner'
/
comment on column ALL_MINING_MODEL_XFORMS.MODEL_NAME is
'Name of the model'
/
comment on column ALL_MINING_MODEL_XFORMS.ATTRIBUTE_NAME is
'Name of the attribute used in the transformation'
/
comment on column ALL_MINING_MODEL_XFORMS.ATTRIBUTE_SUBNAME is
'Subame of the attribute used in the transformation'
/
comment on column ALL_MINING_MODEL_XFORMS.ATTRIBUTE_SPEC is
'Attribute specification provided to model training'
/
comment on column ALL_MINING_MODEL_XFORMS.EXPRESSION is
'Forward expression provided to model training'
/
comment on column ALL_MINING_MODEL_XFORMS.REVERSE is
'Reverse expression'
/
create or replace public synonym ALL_MINING_MODEL_XFORMS for ALL_MINING_MODEL_XFORMS
/
grant read on ALL_MINING_MODEL_XFORMS to public;
/
create or replace view DBA_MINING_MODEL_XFORMS
    (OWNER, MODEL_NAME, ATTRIBUTE_NAME, ATTRIBUTE_SUBNAME,
     ATTRIBUTE_SPEC, EXPRESSION, REVERSE)
as
select u.name, o.name, x.attr, x.subn, x.attrspec, x.expr,
       decode(bitand(x.properties,16),16,'YES','NO')
from sys.obj$ o, sys.user$ u, sys.modelxfm$ x
where o.obj#=x.mod#
  and o.owner#=u.user#
  and bitand(x.properties,256) != 0
/
comment on table DBA_MINING_MODEL_XFORMS is
'User-specified transformations embedded in all models accessible to the user'
/
comment on column DBA_MINING_MODEL_XFORMS.OWNER is
'Name of the model owner'
/
comment on column DBA_MINING_MODEL_XFORMS.MODEL_NAME is
'Name of the model'
/
comment on column DBA_MINING_MODEL_XFORMS.ATTRIBUTE_NAME is
'Name of the attribute used in the transformation'
/
comment on column DBA_MINING_MODEL_XFORMS.ATTRIBUTE_SUBNAME is
'Subame of the attribute used in the transformation'
/
comment on column DBA_MINING_MODEL_XFORMS.ATTRIBUTE_SPEC is
'Attribute specification provided to model training'
/
comment on column DBA_MINING_MODEL_XFORMS.EXPRESSION is
'Forward expression provided to model training'
/
comment on column DBA_MINING_MODEL_XFORMS.REVERSE is
'Reverse expression'
/
create or replace public synonym DBA_MINING_MODEL_XFORMS for DBA_MINING_MODEL_XFORMS
/
grant select on DBA_MINING_MODEL_XFORMS to select_catalog_role;
/

execute CDBView.create_cdbview(false,'SYS','DBA_MINING_MODEL_XFORMS','CDB_MINING_MODEL_XFORMS');
grant select on SYS.CDB_MINING_MODEL_XFORMS to select_catalog_role
/
create or replace public synonym CDB_MINING_MODEL_XFORMS for SYS.CDB_MINING_MODEL_XFORMS
/

@?/rdbms/admin/sqlsessend.sql
