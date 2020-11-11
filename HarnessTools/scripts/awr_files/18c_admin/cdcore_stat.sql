Rem
Rem cdcore_stat.sql
Rem
Rem Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      cdcore_stat.sql - Statistics views needed at startup 
Rem
Rem    DESCRIPTION
Rem      This file contains dummy views that are created for 
Rem    "Statistics Encryption" project. We call it dummy because the encrypted
Rem    statistics are not decrypted in these view definitions. 
Rem
Rem    We are not creating dummy views on history statistics as it is not
Rem    referenced in the early database creation stage.
Rem 
Rem    We are now replacing all references of hist_head$ with
Rem    "_HIST_HEAD_DEC" and histgrm$ table with "_HISTGRM_DEC" 
Rem    views where the statistical data is accessed. 
Rem   
Rem    The views created later on in catost.sql will show the right (in clear)
Rem    statistics. That is because the DBMS_CRYPTO_STATS_INT package is 
Rem    available and we could call into the decryptNum and decryptRaw APIs.
Rem
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cdcore_stat.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/cdcore_stat.sql 
Rem    SQL_PHASE: CDCORE_STAT
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/cdcore.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sudurai     09/23/15 - Bug 21805805: Encrypt NUMBER data type in
Rem                           statistics tables
Rem    sudurai     06/22/15 - Bug 21258745: Moving STATS crypto APIs from
Rem                           DBMS_STATS_INTERNAL -> DBMS_CRYPTO_STATS_INT
Rem    sudurai     01/29/15 - proj 49581 - optimizer stats encryption
Rem    sudurai     01/29/15 - Created
Rem


@@?/rdbms/admin/sqlsessstart.sql


create or replace force view "_HIST_HEAD_DEC" 
(
  obj#, 
  col#, 
  bucket_cnt,
  row_cnt, 
  cache_cnt, 
  null_cnt, 
  timestamp#, 
  sample_size, 
  minimum, 
  maximum, 
  distcnt, 
  lowval, 
  hival, 
  density, 
  intcol#, 
  spare1, 
  spare2, 
  avgcln, 
  spare3, 
  spare4 
)
as
select 
  obj#, 
  col#, 
  bucket_cnt, 
  row_cnt, 
  cache_cnt, 
  null_cnt, 
  timestamp#, 
  sample_size, 
  minimum,
  maximum,
  distcnt,
  lowval,
  hival,
  density, 
  intcol#, 
  spare1, 
  spare2, 
  avgcln, 
  spare3, 
  spare4 
from hist_head$;


create or replace force view "_HISTGRM_DEC"
(
  obj#,
  col#,
  row#,
  bucket,
  endpoint,
  intcol#,
  epvalue,
  ep_repeat_count,
  epvalue_raw,
  spare1,
  spare2
)
as
select
  obj#,
  col#,
  row#,
  bucket,
  endpoint,
  intcol#,
  epvalue,
  ep_repeat_count,
  epvalue_raw, 
  spare1,
  spare2
from histgrm$ hg;

/

show errors;

@?/rdbms/admin/sqlsessend.sql
