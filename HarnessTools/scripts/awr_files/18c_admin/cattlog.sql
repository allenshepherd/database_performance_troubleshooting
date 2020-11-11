Rem
Rem $Header: rdbms/admin/cattlog.sql /main/9 2017/06/26 16:01:19 pjulsaks Exp $
Rem
Rem cattlog.sql
Rem
Rem Copyright (c) 2008, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cattlog.sql 
Rem
Rem    DESCRIPTION
Rem      This script creates the metadata tables, views, sequences needed
Rem      by Common Logging Infrastructure
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cattlog.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cattlog.sql
Rem SQL_PHASE: CATTLOG
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    sankejai    04/15/12 - bug13022221: Use GUID for ktli, instead of DB Id
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    amullick    01/05/12 - bug13549280: move table and sequence creation
Rem                           to dtlog.bsq
Rem    mabhatta    03/01/11 - add cli_tab$
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    mabhatta    04/21/09 - create views
Rem    mabhatta    12/23/08 - partitioning support
Rem    mabhatta    08/07/08 - tsmap segmentation on securefile/basicfiles
Rem    mabhatta    07/22/08 - add catalog for instances
Rem    mabhatta    06/18/08 - add fixed-size flag
Rem    mabhatta    06/10/08 - add message property as type
Rem    mabhatta    05/20/08 - increase logname to 30
Rem    mabhatta    05/06/08 - create mesg array types
Rem    mabhatta    04/03/08 - inmem to securfile
Rem    mabhatta    01/14/08 - In-mem logging
Rem    mabhatta    01/14/08 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


create or replace view dba_securefile_logs
  (guid, user_name, log_name, client#, log_id, persist, threaded, partition, auto_partition,
   use_securefile, retention, partition_size, high_tab#) as
  select d.guid, u.name , d.name, d.client#, d.log#, 
         decode(bitand(d.flags, 7), 
                  1, 'NEVER',
                  2, 'OVERFLOW',
                  4, 'ALWAYS',
                  'UNKNOWN'),
         decode(bitand(d.flags, 32), 32, 'THREADED', 'NON-THREADED'),
         decode(bitand(d.flags, 512), 512, 'NO-PARITION', 'PARTITION'),
         decode(bitand(d.flags, 1024), 1024, 'NO-AUTO-PARTITION',
                'AUTO-PARTITION'),
         decode(bitand(d.flags, 128), 128, 'ONLY_SECUREFILE', 
                'PREFER_SECUREFILE'),
         retention, part_size, high_tab# from cli_log$ d, user$ u 
         where u.user# = d.user#;
/


execute CDBView.create_cdbview(false,'SYS','DBA_SECUREFILE_LOGS','CDB_SECUREFILE_LOGS');

create or replace view dba_securefile_log_tables
   (guid, user_name, log_name, log_id, table_sequence, table_version, table_name,
    split, fixed_size, flush, mem_read,
    sfile_cache, sfile_log, sfile_deduplicate, sfile_compress, 
    high_tsname, table_crt_scn, table_crt_time, 
    min_record_scn, min_record_time, 
    high_part_no, num_parts) as
    select i.guid, u.name, l.name, i.log#, i.tab#, i.ver#, i.name,
    decode(bitand(i.flags, 8), 8, 'NO-SPLIT', 'SPLIT'),
         decode(bitand(i.flags, 16), 16, 'FIXED_MSG', 'VARIABLE_MSG'),
         decode(bitand(i.flags, 64), 64, 'BACKGROUND_FLUSH', 
                'FOREGROUND_FLUSH'),
         decode(bitand(i.flags, 256), 256, 'ALLOW_MEM_READS', 'NO_MEM_READS'),
         decode(bitand(i.lob_flags, 2), 2, 'SFILE_CACHE', 'SFILE_NOCACHE'),
         decode(bitand(i.lob_flags, 12), 
                    4, 'SFILE_NOLOGGED',
                    8, 'SFILE_FS_LOGGED',
                    'SFILE_LOGGED'),
         decode(bitand(i.lob_flags, 16), 16, 'DEDUPLICATE',
                'NO_DEDUPLICATE'),
         decode(bitand(i.lob_flags, 224), 
                  32, 'SFILE_COMPRESS_HIGH',
                  64, 'SFILE_COMPRESS_LOW',
                  128, 'SFILE_COMPRESS_MEDIUM',
                  'SFILE_NOCOMPRESS'),
         t.name, i.crt_scn, i.crt_time, i.min_scn, i.min_time,
         i.high_part#, i.num_parts        
    from cli_tab$ i, cli_log$ l, ts$ t, user$ u
    where i.log# = l.log# and  i.cur_ts# = t.ts# and i.user# = u.user# ;
         

execute CDBView.create_cdbview(false,'SYS','DBA_SECUREFILE_LOG_TABLES','CDB_SECUREFILE_LOG_TABLES');

create or replace view dba_securefile_log_instances
   (guid, user_name, log_name, log_id, inst, split, fixed_size, flush, mem_read,
    max_bucket_no, num_buckets, inc_scn, inc_time, 
    crt_scn, crt_time, inc#) as
  select i.guid, u.name, d.name, d.log#, i.inst#,  
         decode(bitand(i.flags, 8), 8, 'NO-SPLIT', 'SPLIT'),
         decode(bitand(i.flags, 16), 16, 'FIXED_MSG', 'VARIABLE_MSG'),
         decode(bitand(i.flags, 64), 64, 'BACKGROUND_FLUSH', 
                'FOREGROUND_FLUSH'),
         decode(bitand(i.flags, 256), 256, 'ALLOW_MEM_READS', 'NO_MEM_READS'),
         i.max_bucket#, i.num_buckets, i.inc_scn, i.inc_time,
         i.crt_scn, i.crt_time, i.inc# 
         from cli_log$ d, cli_inst$ i, user$ u
          where d.log# = i.log#
          and   i.user# = u.user#;

execute CDBView.create_cdbview(false,'SYS','DBA_SECUREFILE_LOG_INSTANCES','CDB_SECUREFILE_LOG_INSTANCES');

/          

create or replace view dba_securefile_log_partitions
  (guid, user_name, log_name, log_id, tab_name, part_no, tsname, 
   sfile_cache, sfile_log, sfile_deduplicate, sfile_compress,
   part_name, part_scn, part_time,
   part_min_scn, part_min_time) as
  select p.guid, u.name, d.name, p.log#, tb.name, p.part#, t.name, 
  decode(bitand(p.lob_flags, 2), 2, 'SFILE_CACHE', 'SFILE_NOCACHE'),
         decode(bitand(p.lob_flags, 12), 
                    4, 'SFILE_NOLOGGED',
                    8, 'SFILE_FS_LOGGED',
                    'SFILE_LOGGED'),
         decode(bitand(p.lob_flags, 16), 16, 'DEDUPLICATE',
                'NO_DEDUPLICATE'),
         decode(bitand(p.lob_flags, 224), 
                  32, 'SFILE_COMPRESS_HIGH',
                  64, 'SFILE_COMPRESS_LOW',
                  128, 'SFILE_COMPRESS_MEDIUM',
                  'SFILE_NOCOMPRESS'),
  p.name, p.part_scn, p.part_time, p.min_scn, p.min_time
         from cli_log$ d, cli_part$ p, ts$ t, user$ u, cli_tab$ tb
         where d.log# = p.log# and p.log# = tb.log# and p.tab# = tb.tab# and p.user# = u.user#
          and  p.ts#  = t.ts#; 
/

execute CDBView.create_cdbview(false,'SYS','DBA_SECUREFILE_LOG_PARTITIONS','CDB_SECUREFILE_LOG_PARTITIONS');


@?/rdbms/admin/sqlsessend.sql
