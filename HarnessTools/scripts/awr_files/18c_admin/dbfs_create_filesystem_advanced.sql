Rem
Rem $Header: rdbms/admin/dbfs_create_filesystem_advanced.sql /main/8 2017/05/28 22:46:04 stanaya Exp $
Rem
Rem dbfs_create_filesystem.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbfs_create_filesystem_advanced.sql - DBFS create filesystem
Rem
Rem    DESCRIPTION
Rem      DBFS create filesystem script
Rem      Usage: sqlplus @dbfs_create_filesystem_advanced.sql  
Rem             <tablespace_name> <table_name> 
Rem             <compress-high | compress-medium  | nocompress> 
Rem             <deduplicate | nodeduplicate> <encrypt | noencrypt>
Rem             <non-partition | partition | partition-by-itemname | 
Rem              partition-by-guid, partition-by-path>
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbfs_create_filesystem_advanced.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbfs_create_filesystem_advanced.sql
Rem    SQL_PHASE: DBFS_CREATE_FILESYSTEM_ADVANCED
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    siteotia    06/02/15 - Bug 21143599: Rewrote the script.
Rem    weizhang    09/24/12 - bug 14666696: fix sql injection security bug
Rem    xihua       10/13/10 - Bug 10104462: improved method for dropping all
Rem                           filesystems
Rem    weizhang    03/11/10 - bug 9220947: tidy up
Rem    weizhang    06/12/09 - Package name change
Rem    weizhang    04/06/09 - Created
Rem

SET ECHO OFF
SET VERIFY OFF
SET FEEDBACK OFF
SET TAB OFF
SET SERVEROUTPUT ON

define ts_name      = &1   /* Tablespace name */
define fs_name      = &2   /* Store name */
define fs_compress  = &3   /* Compression enabled ? */
define fs_dedup     = &4   /* Deduplication enabled ? */
define fs_encrypt   = &5   /* Encryption enabled ? */
define fs_partition = &6   /* Partitioned ? */

declare

  mnt_dir         varchar2(100);
  stmt            varchar2(32000);
  mnt_mode        integer;
  ret             integer;

  do_compress_v   varchar2(32);
  do_compress_v1  boolean;

  compression_v   varchar2(32);

  do_dedup_v      varchar2(32);
  do_dedup_v1     boolean;
  
  do_encrypt_v    varchar2(32);
  do_encrypt_v1   boolean;
  
  do_partition_v  varchar2(32);
  do_partition_v1 boolean;
  
  partition_key_v number;

begin

  mnt_dir         := '&fs_name';
  mnt_mode        := 16895;
  do_compress_v1  := true;
  do_dedup_v1     := true;
  do_encrypt_v1   := true;
  do_partition_v1 := true;
 
  select decode(lower('&fs_compress'), 
                'compress', 'true',
                'compress-high', 'true',
                'compress-medium', 'true',
                'compress-low', 'true',
                'nocompress', 'false',
                'false')
      into do_compress_v from dual;
      
  select decode(lower('&fs_compress'), 
                'compress', dbms_dbfs_sfs.compression_default, 
                'compress-high', dbms_dbfs_sfs.compression_high, 
                'compress-medium', dbms_dbfs_sfs.compression_medium,
                'compress-low', dbms_dbfs_sfs.compression_low,
                dbms_dbfs_sfs.compression_default) 
      into compression_v from dual;
      
  select decode(lower('&fs_dedup'), 
                'deduplicate', 'true', 
                'nodeduplicate', 'false', 
                'false') 
      into do_dedup_v from dual;
      
  select decode(lower('&fs_encrypt'), 
                'encrypt', 'true', 
                'noencrypt', 'false', 
                'false') 
      into do_encrypt_v from dual;
      
  select decode(lower('&fs_partition'), 
                'partition', 'true', 
                'partition-by-itemname', 'true', 
                'partition-by-path', 'true', 
                'partition-by-guid', 'true', 
                'non-partition', 'false', 
                'false') 
      into do_partition_v from dual;
      
  select decode(lower('&fs_partition'), 
                'partition', dbms_dbfs_sfs.partition_by_item, 
                'partition-by-itemname', dbms_dbfs_sfs.partition_by_item, 
                'partition-by-path', dbms_dbfs_sfs.partition_by_path, 
                'partition-by-guid', dbms_dbfs_sfs.partition_by_guid, 
                dbms_dbfs_sfs.partition_by_item) 
      into partition_key_v from dual;
 
  -- get the boolean equivalent of compress/dedup/partition/encrypt
  if(do_compress_v = 'false') then
    do_compress_v1 := false;
  end if;
  
  if(do_dedup_v = 'false') then
    do_dedup_v1 := false;
  end if;
  
  if(do_partition_v = 'false') then
    do_partition_v1 := false;
  end if;
  
  if(do_encrypt_v = 'false') then
    do_encrypt_v1 := false;
  end if;

  -- create file store.
  dbms_dbfs_sfs.createFilesystem(store_name    => '&fs_name',
                                 tbl_tbs       => '&ts_name',
                                 lob_tbs       => '&ts_name',
                                 do_partition  => do_partition_v1,
                                 partition_key => partition_key_v,
                                 do_compress   => do_compress_v1,
                                 compression   => compression_v,
                                 do_dedup      => do_dedup_v1,
                                 do_encrypt    => do_encrypt_v1);
                                 
  -- register the file store with CAPI.
  dbms_dbfs_content.registerStore(store_name       => '&fs_name', 
                                  provider_name    => 'sample1', 
                                  provider_package => 'dbms_dbfs_sfs');

  -- mount the store with CAPI.
  dbms_dbfs_content.mountStore(store_name  => '&fs_name', 
                               store_mount => mnt_dir);
  
  commit;

  ret := dbms_fuse.fs_chmod(path    => ('/' || mnt_dir), 
                            st_mode => to_char(mnt_mode));
  
  commit;

exception

  when others then
    rollback;
    dbms_output.put_line('ERROR: ' || sqlcode || ' msg: ' || sqlerrm);
    raise;

end;
/

show errors;

commit;

undefine ts_name
undefine fs_name
undefine fs_compress
undefine fs_dedup
undefine fs_encrypt
undefine fs_partition
