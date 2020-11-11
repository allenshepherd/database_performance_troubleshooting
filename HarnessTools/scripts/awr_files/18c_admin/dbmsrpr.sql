--
-- $Header $
--
-- dbmsrpr.sql
--
-- Copyright (c) 1996, 2014, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--      dbmsrpr.sql - RDBMS Repair Package Specification
--
--    DESCRIPTION
--      Defines the interface for the repair functions
--
--    NOTES
--
--
-- BEGIN SQL_FILE_METADATA
-- SQL_SOURCE_FILE: rdbms/admin/dbmsrpr.sql
-- SQL_SHIPPED_FILE: rdbms/admin/dbmsrpr.sql
-- SQL_PHASE: DBMSRPR
-- SQL_STARTUP_MODE: NORMAL
-- SQL_IGNORABLE_ERRORS: NONE
-- SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
-- END SQL_FILE_METADATA
--
--    MODIFIED   (MM/DD/YY)
--    ptearle    01/28/14 - 17866999: correct cluster indexes after
--                          cross-endian conversion
--    surman     12/29/13 - 13922626: Update SQL metadata
--    surman     03/27/12 - 13615447: Add SQL patching tags
--    kshergil   09/16/04 - 3805539: add online_index_clean
--    jklein     06/04/04 - queue index rebuild 
--    smuthuli   10/14/00 - add segment_fix_status
--    lcprice    11/02/98 - modify default orphan table name
--    lcprice    05/06/98 - creation

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_repair
  
  IS
  ----------------------------------
  --  OVERVIEW
  --
  --  The DBMS_REPAIR package consists of data corruption repair procedures
  --
  --  SECURITY
  -- 
  --  The package is owned by SYS.  
  --  Execution privilege is not granted to other users.
  ---------------------------------- 
  --
  --  ENUMERATION TYPES:
  --
  --  Object Type Specification
  --
  TABLE_OBJECT constant binary_integer := 1;
  INDEX_OBJECT constant binary_integer := 2;
  CLUSTER_OBJECT constant binary_integer := 4;

  --
  -- Flags Specification
  --
  SKIP_FLAG    constant binary_integer := 1;
  NOSKIP_FLAG  constant binary_integer := 2;
  
  --
  -- Admin Action Specification 
  --
  CREATE_ACTION constant binary_integer := 1;
  PURGE_ACTION  constant binary_integer := 2;
  DROP_ACTION   constant binary_integer := 3;

  --
  -- Admin Table Type Specification
  --
  REPAIR_TABLE constant binary_integer :=1;
  ORPHAN_TABLE constant binary_integer :=2;

  --
  -- Object Id Specification
  --
  ALL_INDEX_ID constant binary_integer :=0;

  -- 
  -- Lock Wait Specification
  -- 
  LOCK_NOWAIT constant binary_integer := 0;
  LOCK_WAIT   constant binary_integer := 1;

  -- 
  -- Check Level Specification
  -- 
  NO_CHECKING        constant binary_integer := 1;
  CHECK_AND_CORRECT  constant binary_integer := 2;
  CHECK_AND_REPORT   constant binary_integer := 3;
  BYTESWAP_NO_CHECK  constant binary_integer := 4;

  -----------------------------------
  --
  -- PROCEDURES AND FUNCTIONS
  --
  --
  
  --
  -- NOTE: default table_name will be 'REPAIR_TABLE' when table_type is 
  -- REPAIR_TABLE, and will be 'ORPHAN_KEY_TABLE' when table_type is 
  -- ORPHAN_TABLE
  procedure admin_tables(
    table_name IN varchar2 DEFAULT 'GENERATE_DEFAULT_TABLE_NAME',
    table_type IN binary_integer,
    action IN binary_integer,
    tablespace IN varchar2 DEFAULT NULL);

  --
  procedure check_object(
    schema_name IN varchar2,
    object_name IN varchar2,
    partition_name IN varchar2 DEFAULT NULL,
    object_type IN binary_integer DEFAULT TABLE_OBJECT,
    repair_table_name IN varchar2 DEFAULT 'REPAIR_TABLE',
    flags IN binary_integer DEFAULT NULL,
    relative_fno IN binary_integer DEFAULT NULL,
    block_start IN binary_integer DEFAULT NULL,
    block_end IN binary_integer DEFAULT NULL,
    corrupt_count OUT binary_integer);

  --
  procedure dump_orphan_keys(
    schema_name IN varchar2,
    object_name IN varchar2,
    partition_name IN varchar2 DEFAULT NULL,
    object_type IN binary_integer DEFAULT INDEX_OBJECT,
    repair_table_name IN varchar2 DEFAULT 'REPAIR_TABLE',
    orphan_table_name IN varchar2 DEFAULT 'ORPHAN_KEY_TABLE',
    flags IN binary_integer DEFAULT NULL,
    key_count OUT binary_integer);

  --
  procedure fix_corrupt_blocks(
    schema_name IN varchar2,
    object_name IN varchar2,
    partition_name IN varchar2 DEFAULT NULL, 
    object_type IN binary_integer DEFAULT TABLE_OBJECT,
    repair_table_name IN varchar2 DEFAULT 'REPAIR_TABLE',
    flags IN binary_integer DEFAULT NULL,
    fix_count OUT binary_integer);

  --
  procedure rebuild_freelists(
    schema_name IN varchar2,
    object_name IN varchar2,
    partition_name IN varchar2 DEFAULT NULL,
    object_type IN binary_integer DEFAULT TABLE_OBJECT);

  --
  procedure skip_corrupt_blocks(
    schema_name IN varchar2,
    object_name IN varchar2,
    object_type IN binary_integer DEFAULT TABLE_OBJECT,
    flags IN binary_integer DEFAULT SKIP_FLAG);

  --
  procedure segment_fix_status(
    segment_owner IN varchar2,
    segment_name  IN varchar2,
    segment_type   IN binary_integer DEFAULT TABLE_OBJECT,
    file_number    IN binary_integer DEFAULT NULL,
    block_number   IN binary_integer DEFAULT NULL,
    status_value   IN binary_integer DEFAULT NULL, 
    partition_name IN varchar2 DEFAULT NULL);

  --
  procedure rebuild_shc_index(
    segment_owner  IN varchar2,
    cluster_name   IN varchar2);

  --
  function online_index_clean(
    object_id      IN binary_integer DEFAULT ALL_INDEX_ID, 
    wait_for_lock  IN binary_integer DEFAULT LOCK_WAIT) 
    return boolean;
  --   Example Usage of online_index_clean:
  --   DECLARE
  --     isClean BOOLEAN;
  --   BEGIN
  -- 
  --     isClean := FALSE;
  --     WHILE isClean=FALSE
  --     LOOP
  --       isClean := DBMS_REPAIR.ONLINE_INDEX_CLEAN(DBMS_REPAIR.ALL_INDEX_ID,
  --                                                 DBMS_REPAIR.LOCK_WAIT);
  --       DBMS_LOCK.SLEEP(10);
  --     END LOOP;
  -- 
  --     EXCEPTION
  --      WHEN OTHERS THEN
  --      RAISE;
  --   END;
  --   /

  --
  procedure repair_cluster_index_keycount(
    index_owner  IN varchar2,
    index_name   IN varchar2,
    check_level  IN binary_integer);


END dbms_repair;
/
    


@?/rdbms/admin/sqlsessend.sql
