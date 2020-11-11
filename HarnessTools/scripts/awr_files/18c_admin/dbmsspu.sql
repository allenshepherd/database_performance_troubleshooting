Rem
Rem $Header: rdbms/admin/dbmsspu.sql /main/15 2016/06/20 16:28:18 dhdhshah Exp $
Rem
Rem dbmsspu.sql
Rem
Rem Copyright (c) 2004, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsspu.sql - Space Utility procedures
Rem
Rem    DESCRIPTION
Rem      Contains utility procedures various space layer 
Rem
Rem    NOTES
Rem      Must be run when connected to SYS or INTERNAL.
Rem
Rem      The procedural option is needed to use these facilities.
Rem
Rem      All of the packages below run with the privileges of calling user,
Rem      rather than the package owner ('sys').
Rem
Rem      The dbms_utility package is run-as-caller (psdicd.c) only for
Rem      its name_resolve, compile_schema and analyze_schema
Rem      procedures.  This package is not run-as-caller
Rem      w.r.t. SQL (psdpgi.c) so that the SQL works correctly (runs as
Rem      SYS).  The privileges are checked via dbms_ddl.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsspu.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsspu.sql
Rem SQL_PHASE: DBMSSPU
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dhdhshah    06/09/16 - Bug 17036448: support for dbms_heat_map_internal
Rem    hlakshma    05/26/15 - Long identifier support for heat_map package
Rem                           (bug-21151236)
Rem    jhausman    02/10/15 - Big SQL - Local Temp dbms_space_alert package
Rem    smuthuli    02/07/15 - Project 58845: Space Cache rewrite
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    smuthuli    12/04/12 - reorder heatmap columns
Rem    smuthuli    10/01/12 - Add dbms_heat_map
Rem    smuthuli    09/25/12 - Add Object Level ILM Aggregations
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    smuthuli    07/12/10 - dbfs: df
Rem    smuthuli    03/18/10 - Add procedure to parse the segadvisor output
Rem    smuthuli    07/31/06 - add space_usage for NGLOBS
Rem    baleti      03/05/05 - Add lob column name 
Rem    nmukherj    01/14/05 - put isDatafileDroppable checks
Rem    smuthuli    06/24/04 - smuthuli_lrg_asa
Rem    smuthuli    06/17/04 - Created
Rem
-- These two types will be used by CREATE_TABLE_COST procedure

@@?/rdbms/admin/sqlsessstart.sql
drop type create_table_cost_columns
/
drop type create_table_cost_colinfo
/
create type create_table_cost_colinfo is object
  (
                         col_type varchar(200),
                         col_size number
  )
/
create type create_table_cost_columns is varray(50000) of create_table_cost_colinfo
/
create  type tablespace_list is varray (64000) of number
/
grant execute on create_table_cost_columns to public
/
grant execute on create_table_cost_colinfo to public
/
grant execute on tablespace_list to public
/

create or replace package dbms_space AUTHID CURRENT_USER as
  ------------
  --  OVERVIEW
  --
  --  This package provides segment space information not currently
  --  available through the standard views.

  --  SECURITY
  --
  --  The execution privilege is granted to PUBLIC. Procedures in this
  --  package run under the caller security. The user must have ANALYZE
  --  privilege on the object.

  OBJECT_TYPE_TABLE                  constant positive := 1;
  OBJECT_TYPE_NESTED_TABLE           constant positive := 2;
  OBJECT_TYPE_INDEX                  constant positive := 3;
  OBJECT_TYPE_CLUSTER                constant positive := 4;
  OBJECT_TYPE_LOB_INDEX              constant positive := 5;
  OBJECT_TYPE_LOBSEGMENT             constant positive := 6;
  OBJECT_TYPE_TABLE_PARTITION        constant positive := 7;
  OBJECT_TYPE_INDEX_PARTITION        constant positive := 8;
  OBJECT_TYPE_TABLE_SUBPARTITION     constant positive := 9;
  OBJECT_TYPE_INDEX_SUBPARTITION     constant positive := 10;
  OBJECT_TYPE_LOB_PARTITION          constant positive := 11;
  OBJECT_TYPE_LOB_SUBPARTITION       constant positive := 12;
  OBJECT_TYPE_MV                     constant positive := 13;
  OBJECT_TYPE_MVLOG                  constant positive := 14;
  OBJECT_TYPE_ROLLBACK_SEGMENT       constant positive := 15;

  SPACEUSAGE_EXACT                   constant positive := 16;
  SPACEUSAGE_FAST                    constant positive := 17;

  ----------------------------

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure unused_space(segment_owner IN varchar2, 
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         total_blocks OUT number,
                         total_bytes OUT number,
                         unused_blocks OUT number,
                         unused_bytes OUT number,
                         last_used_extent_file_id OUT number,
                         last_used_extent_block_id OUT number,
                         last_used_block OUT number,
                         partition_name IN varchar2 DEFAULT NULL
                         );
  pragma restrict_references(unused_space,WNDS);

  --  Returns information about unused space in an object (table, index,
  --    or cluster).
  --  Input arguments:
  --   segment_owner  
  --      schema name of the segment to be analyzed
  --   segment_name  
  --      object name of the segment to be analyzed
  --   partition_name  
  --      partition name of the segment to be analyzed
  --   segment_type  
  --      type of the segment to be analyzed (TABLE, INDEX, or CLUSTER)
  --  Output arguments:
  --   total_blocks  
  --      total number of blocks in the segment
  --   total_bytes  
  --      the same as above, expressed in bytes
  --   unused_blocks  
  --      number of blocks which are not used 
  --   unused_bytes  
  --      the same as above, expressed in bytes
  --   last_used_extent_file_id 
  --      the file ID of the last extent which contains data
  --   last_used_extent_block_id 
  --      the block ID of the last extent which contains data
  --   last_used_block  
  --      the last block within this extent which contains data
  procedure free_blocks (segment_owner IN varchar2, 
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         freelist_group_id IN number,
                         free_blks OUT number,
                         scan_limit IN number DEFAULT NULL,
                         partition_name IN varchar2 DEFAULT NULL
                         );
  pragma restrict_references(free_blocks,WNDS);

  --  Returns information about free blocks in an object (table, index,
  --    or cluster).
  --  Input arguments:
  --   segment_owner  
  --      schema name of the segment to be analyzed
  --   segment_name  
  --      name of the segment to be analyzed
  --   partition_name  
  --      partition name of the segment to be analyzed
  --   segment_type  
  --      type of the segment to be analyzed (TABLE, INDEX, or CLUSTER)
  --   freelist_group_id  
  --      freelist group (instance) whose free list size is to be computed
  --   scan_limit (optional)
  --      maximum number of free blocks to read
  --  Output arguments:
  --   free_blks  
  --      count of free blocks for the specified group

  --  
  -- Segment space utilization  procedures for ASSM and Securefiles.
  -- The procedures are overloaded. There are four incarnations of 
  -- space_usage procedure.
  --
  -- 1. For data and  index segments
  -- 2. Exhaustive space utilization for securefile segments  
  -- 3. Quick space utilization for securefile segments  
  -- 4. Space utilization in data and index segments showing
  --    new free space state - 100% FREE.
  --
  --

  -- Returns space utilization in data and index segments. The information
  -- returned does not show blocks in 100% free state.The blocks in 
  -- 100% free state are wrapped into 75% to 100% free state. To get
  -- accurate estimate of blocks in 100% free state, use the fourth 
  -- variant of space_usage procedure.
  --
  procedure space_usage(segment_owner IN varchar2,
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         unformatted_blocks OUT number,
                         unformatted_bytes OUT number,
                         fs1_blocks OUT number,
                         fs1_bytes  OUT number,
                         fs2_blocks OUT number,
                         fs2_bytes  OUT number,
                         fs3_blocks OUT number,
                         fs3_bytes  OUT number,
                         fs4_blocks OUT number,
                         fs4_bytes  OUT number,
                         full_blocks OUT number,
                         full_bytes OUT number,
                         partition_name IN varchar2 DEFAULT NULL
                         );
  pragma restrict_references(space_usage,WNDS);

  --  Returns information about space occupation in an object (table, index,
  --    or cluster).
  --  Input arguments:
  --   segment_owner
  --      schema name of the segment 
  --   segment_name
  --      object name of the segment 
  --   partition_name
  --      partition name of the segment 
  --   segment_type
  --      type of the segment (TABLE, INDEX, or CLUSTER)
  --  Output arguments:
  --   unformatted_blocks
  --      total number of blocks that are unformatted
  --   unformatted_bytes
  --      the same as above, expressed in bytes
  --   fs1_blocks
  --      number of blocks that have atleast 0 to 25% free space.
  --   fs1_bytes
  --      same as above, expressed in bytes
  --   fs2_blocks
  --      number of blocks that have atleast 25% to 50% free space.
  --   fs2_bytes
  --      same as above, expressed in bytes
  --   fs3_blocks
  --      number of blocks that have atleast 50% to 75% free space.
  --   fs3_bytes
  --      same as above, expressed in bytes
  --   fs4_blocks
  --      number of blocks that have atleast 75% to 100% free space.
  --   fs4_bytes
  --      same as above, expressed in bytes
  --   full_blocks
  --      total number of blocks that are full in the segment
  --   full_bytes
  --      the same as above, expressed in bytes


  --
  -- The procedure returns space utilization in a Securefile segment.
  -- The information is retrieved by reading the ondisk space metadata 
  -- blocks.
  procedure space_usage (segment_owner IN varchar2,
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         segment_size_blocks OUT number,
                         segment_size_bytes OUT number,
                         used_blocks OUT number,
                         used_bytes OUT number,
                         expired_blocks OUT number,
                         expired_bytes OUT number,
                         unexpired_blocks OUT number,
                         unexpired_bytes OUT number,
                         partition_name IN varchar2 DEFAULT NULL
                         );
  pragma restrict_references(space_usage,WNDS);
  --  Returns information about space usage in Securefile segment
  --  Input arguments:
  --   segment_owner
  --      schema name of the segment 
  --   segment_name
  --      object name of the segment 
  --   partition_name
  --      partition name of the segment 
  --   segment_type
  --      type of the segment 
  --  Output arguments:
  --   segment_size_blocks
  --      number of blocks in the segment
  --   segment_size_bytes
  --      number of bytes in the segment
  --   used_blocks
  --      number of used blocks in the segment
  --   used_bytes
  --      number of used bytes in the segment
  --   expired_blocks
  --      number of expired blocks in the segment
  --   expired_bytes
  --      number of expired bytes in the segment
  --   unexpired_blocks
  --      number of unexpired blocks in the segment
  --   unexpired_bytes
  --      number of unexpired bytes in the segment


  --
  --  Returns information about space usage in Securefile segment
  --  Optionally gets space usage faster by retreiving cached
  --  data from memory.
  procedure space_usage (segment_owner IN varchar2,
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         suoption IN number,
                         segment_size_blocks OUT number,
                         segment_size_bytes OUT number,
                         used_blocks OUT number,
                         used_bytes OUT number,
                         expired_blocks OUT number,
                         expired_bytes OUT number,
                         unexpired_blocks OUT number,
                         unexpired_bytes OUT number,
                         partition_name IN varchar2 DEFAULT NULL
                         );
  pragma restrict_references(space_usage,WNDS);
  --  Returns information about space usage in Securefile segment
  --  Optionally gets space usage faster by caching and retreiving 
  --  data from memory.
  --
  --  Input arguments:
  --   segment_owner
  --      schema name of the segment 
  --   segment_name
  --      object name of the segment 
  --   partition_name
  --      partition name of the segment 
  --   segment_type
  --      type of the segment 
  --   suoption
  --      SPACEUSAGE_EXACT: Computes space usage exhaustively
  --      SPACEUSAGE_FAST: Retrieves values from in-memory statistics
  --
  --  Output arguments:
  --   segment_size_blocks
  --      number of blocks in the segment
  --   segment_size_bytes
  --      number of bytes in the segment
  --   used_blocks
  --      number of used blocks in the segment
  --   used_bytes
  --      number of used bytes in the segment
  --   expired_blocks
  --      number of expired blocks in the segment
  --   expired_bytes
  --      number of expired bytes in the segment
  --   unexpired_blocks
  --      number of unexpired blocks in the segment
  --   unexpired_bytes
  --      number of unexpired bytes in the segment

  --
  --  Returns information about space usage in data and index segments.
  --  This is the latest (as of Release 12.2)  space usage procedure that 
  --  precisely returns blocks in 100% free state in addition to the 
  --  other freeness states.
  --
  procedure space_usage(segment_owner IN varchar2,
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         unformatted_blocks OUT number,
                         unformatted_bytes OUT number,
                         fs1_blocks OUT number,
                         fs1_bytes  OUT number,
                         fs2_blocks OUT number,
                         fs2_bytes  OUT number,
                         fs3_blocks OUT number,
                         fs3_bytes  OUT number,
                         fs4_blocks OUT number,
                         fs4_bytes  OUT number,
                         fs5_blocks OUT number,
                         fs5_bytes  OUT number,
                         full_blocks OUT number,
                         full_bytes OUT number,
                         partition_name IN varchar2 DEFAULT NULL
                         );
  pragma restrict_references(space_usage,WNDS);

  --  Returns information about space usage in an object (table, index,
  --    or cluster).
  --  Input arguments:
  --   segment_owner
  --      schema name of the segment 
  --   segment_name
  --      object name of the segment 
  --   partition_name
  --      partition name of the segment 
  --   segment_type
  --      type of the segment (TABLE, INDEX, or CLUSTER)
  --  Output arguments:
  --   unformatted_blocks
  --      total number of blocks that are unformatted
  --   unformatted_bytes
  --      the same as above, expressed in bytes
  --   fs1_blocks
  --      number of blocks that have atleast 0 to 25% free space.
  --   fs1_bytes
  --      same as above, expressed in bytes
  --   fs2_blocks
  --      number of blocks that have atleast 25% to 50% free space.
  --   fs2_bytes
  --      same as above, expressed in bytes
  --   fs3_blocks
  --      number of blocks that have atleast 50% to 75% free space.
  --   fs3_bytes
  --      same as above, expressed in bytes
  --   fs4_blocks
  --      number of blocks that have atleast 75% to 100% free space.
  --   fs4_bytes
  --      same as above, expressed in bytes
  --   fs5_blocks
  --      number of blocks that have are 100% free
  --   fs5_bytes
  --      same as above, expressed in bytes
  --   full_blocks
  --      total number of blocks that are full in the segment
  --   full_bytes

  procedure isDatafileDroppable_Name(
          filename               in varchar2,
          value                  out number);
  pragma restrict_references(isDatafileDroppable_Name,WNDS);

  -- Checks whether datafile is droppable
  -- Input args:
  -- filename               - full filename of datafile
  -- value                  - 1 if droppable, 0 if not droppable


  procedure create_table_cost (
                         tablespace_name IN varchar2,
                         avg_row_size IN number,
                         row_count IN number,
                         pct_free IN number,
                         used_bytes OUT number,
                         alloc_bytes OUT number
                         );
  pragma restrict_references(create_table_cost,WNDS);

  procedure create_table_cost (
                         tablespace_name IN varchar2,
                         colinfos IN create_table_cost_columns,
                         row_count IN number,
                         pct_free IN number,
                         used_bytes OUT number,
                         alloc_bytes OUT number
                         );
  pragma restrict_references(create_table_cost,WNDS);


  procedure create_index_cost (
                         ddl IN varchar2,
                         used_bytes OUT number,
                         alloc_bytes OUT number,
                         plan_table IN varchar2 DEFAULT NULL
                         );


  function verify_shrink_candidate (
                         segment_owner IN varchar2, 
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         shrink_target_bytes IN number,
                         partition_name IN varchar2 DEFAULT NULL
                         ) return boolean;
  pragma restrict_references(verify_shrink_candidate,WNDS);

  type verify_shrink_row is record
  (
    status     number
  );
  type verify_shrink_table is table of verify_shrink_row;

  function verify_shrink_candidate_tbf (
                         segment_owner IN varchar2, 
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         shrink_target_bytes IN number,
                         partition_name IN varchar2 DEFAULT NULL
                         ) return verify_shrink_table pipelined;
  pragma restrict_references(verify_shrink_candidate_tbf,WNDS);

  --  Primary task is to check if shrinking a segment by the given
  --  number of bytes would result in an extent being freed or an
  --  extent being truncated, and if so return true.  If the segment
  --  is not bitmap managed, then the function also returns false.
  --  However, to properly check for proper segment type and segment
  --  attributes (e.g. row movement enabled) to allow shrink, the
  --  user is expected to use the ALTER ... SHRINK CHECK statement.
  --
  --  Input arguments:
  --   segment_owner
  --      schema name of the segment to be analyzed
  --   segment_name
  --      object name of the segment to be analyzed
  --   partition_name
  --      partition name of the segment to be analyzed
  --   segment_type
  --      type of the segment to be analyzed (TABLE, INDEX, or CLUSTER)
  --  Returns:
  --   True if shrinking the segment will likely return space to the
  --   tablespace containing the segment.

  -- EM Special. Used to parse the data returned by segment advisor.
  procedure parse_space_adv_info(info                  varchar2,
                                 used_space        out varchar2,
                                 allocated_space   out varchar2,
                                 reclaimable_space out varchar2);
  pragma restrict_references(parse_space_adv_info,WNDS);

  procedure object_space_usage (
                         object_owner IN varchar2,
                         object_name IN varchar2,
                         object_type IN varchar2,
                         sample_control IN number,
                         space_used OUT number,
                         space_allocated OUT number,
                         chain_pcent     OUT number,
                         partition_name IN varchar2 DEFAULT NULL,
                         preserve_result IN boolean DEFAULT TRUE,
                         timeout_seconds IN number DEFAULT NULL
                         );
  pragma restrict_references(object_space_usage,WNDS);

  type object_space_usage_row is record
  (
    space_used       number,
    space_allocated  number,
    chain_pcent      number
  );
  type object_space_usage_table is table of object_space_usage_row;

  function object_space_usage_tbf (
                         object_owner IN varchar2,
                         object_name IN varchar2,
                         object_type IN varchar2,
                         sample_control IN number,
                         partition_name IN varchar2 DEFAULT NULL,
                         preserve_result IN varchar2 DEFAULT 'TRUE',
                         timeout_seconds IN number DEFAULT NULL
                         ) return object_space_usage_table pipelined;
  pragma restrict_references(object_space_usage_tbf,WNDS);


  type asa_reco_row is record
  (
    tablespace_name       varchar2(ORA_MAX_NAME_LEN),
    segment_owner         varchar2(ORA_MAX_NAME_LEN),
    segment_name          varchar2(ORA_MAX_NAME_LEN),
    segment_type          varchar2(18),
    partition_name        varchar2(ORA_MAX_NAME_LEN),
    allocated_space       number,
    used_space            number,
    reclaimable_space     number,
    chain_rowexcess       number,
    ioreqpm               number,
    iowaitpm              number,
    iowaitpr              number,
    recommendations       varchar2(1000),
    c1                    varchar2(1000),
    c2                    varchar2(1000),
    c3                    varchar2(1000),
    task_id               number,
    mesg_id               number
  );
  type asa_reco_row_tb is table of asa_reco_row;

  function asa_recommendations (
                         all_runs    in varchar2 DEFAULT 'TRUE',
                         show_manual in varchar2 DEFAULT 'TRUE',
                         show_findings in varchar2 DEFAULT 'FALSE'
                         ) return asa_reco_row_tb pipelined;


  --
  -- DBFS_DF : The function returns the free space in the 
  -- storage used by the tablespaces. 
  -- PARAMETERS : userid - user id of the user that can use the tablespaces
  --              ntbs   - number of tablespaces 
  --              ints_list - list of tablespace ids
  -- RETURNS : Sum of free space in KB allocatable in the list of tablespaces
  -- Free space in each tablespace is the number of KB available to theuser
  -- for creation of new objects and growth of existing objects.
  --
  -- It does not account for space already allocated to the segments
  -- in the tablespaces.
  --
  -- Functionality not supported for the following
  -- 1. Undo tablespaces
  -- 2. Temporary tablespaces
  -- 3. Dictionary managed tablespaces
  -- 4. Tablespaces with autoextensible files in file system storage.
  -- The return value for unsupported tablespaces will be 0.
  -- 

  function dbfs_df (
                  userid  IN number,
                  ntbs    IN number,
                  ints_list IN tablespace_list) return number;

  -- content of one row in dependent_segments table.
  type object_dependent_segment is record (
                       segment_owner   varchar2(ORA_MAX_NAME_LEN),
                       segment_name    varchar2(ORA_MAX_NAME_LEN),
                       segment_type    varchar2(ORA_MAX_NAME_LEN),
                       tablespace_name varchar2(ORA_MAX_NAME_LEN),
                       partition_name  varchar2(ORA_MAX_NAME_LEN),
                       lob_column_name  varchar2(ORA_MAX_NAME_LEN)
                       );

  -- dependent_segments_table is a table of dependent_segment records. There
  -- is one record for all the dependent segments of the object

  type dependent_segments_table is table of object_dependent_segment;

  function object_dependent_segments(
        objowner IN varchar2,
        objname IN varchar2,
        partname IN varchar2,
        objtype IN number
        ) return dependent_segments_table pipelined;
  -- pragma RESTRICT_REFERENCES(object_dependent_segments,WNDS,WNPS,RNPS);

  -- objowner  - owner of the object
  -- objname   - object name
  -- partname   - name of the partition or subpartition
  -- objtype   - object name space

  -- object_growth_trend_row and object_growth_trend_table are used
  --   by the object_growth_trend table function to describe its output
  type object_growth_trend_row is record (
                         timepoint      timestamp,
                         space_usage    number,
                         space_alloc    number,
                         quality        varchar(20)
                         );

  type object_growth_trend_table is table of object_growth_trend_row;

  -- object_growth_swrf_row,  object_growth_swrf_table,
  --   object_growth_swrf_cursor, object_growth_trend_curtab,
  --   and object_growth_trend_test_swrf are internal to the
  --   implementation of object_growth_trend but need to be declared
  --   here instead of in the private package body.  These internal types
  --   and procedures do not expose any internal information to the user.

  type object_growth_swrf_row is record
  (
                         timepoint timestamp,
                         delta_space_usage number,
                         delta_space_alloc number,
                         total_space_usage number,
                         total_space_alloc number,
                         instance_number number,
                         objn number
  );
  
  type object_growth_swrf_table is table of object_growth_swrf_row;
  
  type object_growth_swrf_cursor is ref cursor return object_growth_swrf_row;

  function object_growth_trend_i_to_s (
                         interv in dsinterval_unconstrained
                         ) return number;
  
  function object_growth_trend_s_to_i (
                         secsin in number
                         ) return dsinterval_unconstrained;
  
  function object_growth_trend_curtab
                         return object_growth_trend_table pipelined;
  
  function object_growth_trend_swrf (
                         object_owner IN varchar2,
                         object_name IN varchar2,
                         object_type IN varchar2,
                         partition_name IN varchar2 DEFAULT NULL
                         ) return object_growth_swrf_table pipelined;


  function object_growth_trend (
                         object_owner IN varchar2,
                         object_name IN varchar2,
                         object_type IN varchar2,
                         partition_name IN varchar2 DEFAULT NULL,
                         start_time IN timestamp DEFAULT NULL,
                         end_time IN timestamp DEFAULT NULL,
                         interval IN dsinterval_unconstrained DEFAULT NULL,
                         skip_interpolated IN varchar2 DEFAULT 'FALSE',
                         timeout_seconds IN number DEFAULT NULL,
                         single_datapoint_flag IN varchar2 DEFAULT 'TRUE'
                         ) return object_growth_trend_table pipelined;


  function object_growth_trend_cur (
                         object_owner IN varchar2,
                         object_name IN varchar2,
                         object_type IN varchar2,
                         partition_name IN varchar2 DEFAULT NULL,
                         start_time IN timestamp DEFAULT NULL,
                         end_time IN timestamp DEFAULT NULL,
                         interval IN dsinterval_unconstrained DEFAULT NULL,
                         skip_interpolated IN varchar2 DEFAULT 'FALSE',
                         timeout_seconds IN number DEFAULT NULL
                         ) return sys_refcursor;

  procedure auto_space_advisor_job_proc;

end;
/
create or replace public synonym dbms_space for sys.dbms_space
/
grant execute on dbms_space to public
/


--
-- Package definition for Heat Map feature.
--

create or replace package dbms_heat_map AUTHID CURRENT_USER as
  ------------
  --  OVERVIEW
  --   
  --  This package provides heatmap information at block/extent/segment
  --  object and tablespace levels. It contains the definitions for
  --  processing heatmap for top N objects and tablespaces.

  --  SECURITY
  --
  --  The execution privilege is granted to PUBLIC. Procedures in this
  --  package run under the caller security.

  type hm_bls_record is record
  (
      owner           VARCHAR2(ORA_MAX_NAME_LEN ),
      segment_name    VARCHAR2(ORA_MAX_NAME_LEN ),
      partition_name  VARCHAR2(ORA_MAX_NAME_LEN ),
      tablespace_name VARCHAR2(ORA_MAX_NAME_LEN ), 
      file_id         NUMBER,
      relative_fno    NUMBER, 
      block_id        NUMBER,
      writetime       date
  );
  type hm_bls_row    is table of hm_bls_record;
  type hm_bls_tabidx is table of hm_bls_record index by PLS_INTEGER;
    
  /*
   * BLOCK_HEAT_MAP-  Table function returns the block level 
   *                  ILM statistics for a table
   *                  segment. It returns no information for segment 
   *                  types that are not
   *                  data. The stat returned today is the latest 
   *                  modification time of the block.
   * Input Parameters
   * owner           : Owner of the segment
   * segment_name    : Table name of a non partitioned table or 
   *                   (sub)partition of partitioned table. 
   *                   Returns no rows when table name is specified 
   *                   for a partitioned table.
   * partition_name  : Defaults to NULL. For a partitioned table,
   *                   specify the partition or subpartition segment name.
   * sort_columnid   : ID of the column to sort the output on. 
   *                   Valid values 1..9. Invalid values are ignored. 
   *                   No errors are raised.
   * sort_order      : Defaults to NULL. Possible values: ASC, DESC
   * 
   * Output Parameters
   * owner           : owner of the segment
   * segment_name    : segment name of the non partitioned table
   * partition_name  : partition or subpartition name
   * tablespace_name : tablespace containing the segment
   * file_id         : absolute file number of the block in the segment
   * relative_fno    : relative file number of the block in the segment
   * block_id        : block number of the block
   * writetime       : last modification time of the block
   *
   */
   function BLOCK_HEAT_MAP (owner in varchar2,
                            segment_name in varchar2,
                            partition_name in varchar2 DEFAULT NULL,
                            sort_columnid in number DEFAULT NULL,
                            sort_order in varchar2 DEFAULT NULL
                            ) return hm_bls_row pipelined;

    type hm_els_record is record
    (
      owner           VARCHAR2(ORA_MAX_NAME_LEN ),
      segment_name    VARCHAR2(ORA_MAX_NAME_LEN ),
      partition_name  VARCHAR2(ORA_MAX_NAME_LEN ),
      tablespace_name VARCHAR2(ORA_MAX_NAME_LEN ),
      file_id         NUMBER,
      relative_fno    NUMBER,
      block_id        NUMBER,
      blocks          NUMBER,
      bytes           NUMBER,
      min_writetime   date,
      max_writetime   date,
      avg_writetime   date
    );
    type hm_els_row    is table of hm_els_record;
    type hm_els_tabidx is table of hm_els_record index by PLS_INTEGER;

    /*
     * EXTENT_HEAT_MAP -Table function returns the extent level ILM
     *                  statistics for a table segment. It returns no 
     *                  information for segment types that are not
     *                  data. Aggregates at extent level including minimum 
     *                  modification time and maximum modification time are 
     *                  returned
     * Input Parameters
     * owner           : Owner of the segment
     * segment_name    : Table name of a non partitioned table or
     *                   (sub)partition of partitioned table.
     *                   Returns no rows when table name is specified for a 
     *                   partitioned table.
     * partition_name  : Defaults to NULL. For a partitioned table,
     *                   specify the partition or subpartition segment name.
     * 
     * Output Parameters
     * owner           : owner of the segment
     * segment_name    : segment name of the non partitioned table
     * partition_name  : partition or subpartition name
     * tablespace_name : tablespace containing the segment
     * file_id         : absolute file number of the block in the segment
     * relative_fno    : relative file number of the block in the segment
     * block_id        : start block number of the extent
     * blocks          : number of blocks in the extent
     * bytes           : number of bytes in the extent
     * min_writetime   : minimum of last modification time of the block
     * max_writetime   : maximum of last modification time of the block
     * avg_writetime   : average of last modification time of the block
     *
     */
    function EXTENT_HEAT_MAP(owner in varchar2,
                             segment_name in varchar2,
                             partition_name in varchar2 DEFAULT NULL
                             ) return hm_els_row pipelined;

    /* 
     * Segment Level Heat Map.
     *
     * Description     :
     * The procedure returns the heatmap attributes
     * for the give segment.
     *
     * Input Parameters:
     * tablespace_id   : tablespace containing the segment
     * header_file     : segment header relative file number
     * header_block    : segment header block number
     * segment_objd    : dataobj of the segment
     *
     * Output Parameters :
     * min_writetime   : Oldest writetime for the segment
     * max_writetime   : Latest writetime for the segment
     * avg_writetime   : Average writetime for the segment
     * avg_readtime    : Average readtime  for the segment
     * min_readtime    : Oldest readtime  for the segment
     * max_readtime    : Latest readtime  for the segment
     * min_ftstime     : Oldest ftstime   for the segment
     * max_ftstime     : Latest ftstime   for the segment
     * avg_ftstime     : Average ftstime   for the segment
     * min_lookuptime  : Oldest lookuptime for the segment
     * max_lookuptime  : Latest lookuptime for the segment
     * avg_lookuptime  : Average lookuptime for the segment
     *
     */
    PROCEDURE SEGMENT_HEAT_MAP(
                     tablespace_id  in  number,
                     header_file    in  number,
                     header_block   in  number,
                     segment_objd   in  number,
                     min_writetime  out date,
                     max_writetime  out date,
                     avg_writetime  out date,
                     min_readtime   out date,
                     max_readtime   out date,
                     avg_readtime   out date,
                     min_ftstime    out date,
                     max_ftstime    out date,
                     avg_ftstime    out date,
                     min_lookuptime out date,
                     max_lookuptime out date,
                     avg_lookuptime out date);

    -- content of one row in object_heat_map table function.
    type hm_object_row is record (
                       owner           varchar2(ORA_MAX_NAME_LEN ),
                       segment_name    varchar2(ORA_MAX_NAME_LEN ),
                       partition_name  varchar2(ORA_MAX_NAME_LEN ),
                       tablespace_name varchar2(ORA_MAX_NAME_LEN ),
                       segment_type    varchar2(20),
                       segment_size    number,
                       min_writetime   date,
                       max_writetime   date,
                       avg_writetime   date,
                       min_readtime    date,
                       max_readtime    date,
                       avg_readtime    date,
                       min_ftstime     date,
                       max_ftstime     date,
                       avg_ftstime     date,
                       min_lookuptime  date,
                       max_lookuptime  date,
                       avg_lookuptime  date
                       );

    type hm_object_table  is table of hm_object_row;
    type hm_object_tabidx is table of hm_object_row index by PLS_INTEGER;


    /*
     * Object Level Heat Map.
     *
     * Description     :
     * The table function returns the minimum, maximum and average access
     * times for all the segments belonging to the object. The object
     * must be a table. The table function raises an error if called on
     * object tables other than table.
     *
     * Input Parameters:
     * object_owner    : object owner
     * object_name     : object name
     *
     * Output Parameters :
     * segment_name    : Name of the top level segment
     * partition_name  : Name of the partition
     * tablespace_name : Name of the tablespace
     * segment_type    : Type of segment as in dba_segments.segment_type
     * segment_size    : Segment size in bytes
     * min_writetime   : Oldest writetime for the segment
     * max_writetime   : Latest writetime for the segment
     * avg_writetime   : Average writetime for the segment
     * avg_readtime    : Average readtime  for the segment
     * min_readtime    : Oldest readtime  for the segment
     * max_readtime    : Latest readtime  for the segment
     * min_ftstime     : Oldest ftstime   for the segment
     * max_ftstime     : Latest ftstime   for the segment
     * avg_ftstime     : Average ftstime   for the segment
     * min_lookuptime  : Oldest lookuptime for the segment
     * max_lookuptime  : Latest lookuptime for the segment
     * avg_lookuptime  : Average lookuptime for the segment
     *
     */

    function object_heat_map(
       object_owner      in varchar2,
       object_name       in varchar2) 
       return hm_object_table pipelined;
  
    -- content of one row in tablespace_heat_map table function.
    type hm_tablespace_row is record (
                         tablespace_name varchar2(ORA_MAX_NAME_LEN),
                         segment_count   number,
                         allocated_bytes number,
                         min_writetime   date,
                         max_writetime   date,
                         avg_writetime   date,
                         min_readtime    date,
                         max_readtime    date,
                         avg_readtime    date,
                         min_ftstime     date,
                         max_ftstime     date,
                         avg_ftstime     date,
                         min_lookuptime  date,
                         max_lookuptime  date,
                         avg_lookuptime  date
                         );
  
    type hm_tablespace_table  is table of hm_tablespace_row;
    type hm_tablespace_tabidx is table of hm_tablespace_row
                                 index by PLS_INTEGER;
  
    /*
     * Tablespace Level Heat Map.
     *
     * Description     :
     * The table function returns the minimum, maximum and average access
     * times for all the segments in the tablespace.
     *
     * Input Parameters:
     * tablespace_name : Name of the tablespace
     *
     * Output Parameters :
     * segment_count   : Total number of segments in the tablespace
     * allocated_bytes : Space used by the segments in the tablespace
     * min_writetime   : Oldest writetime for the tablespace
     * max_writetime   : Latest writetime for the tablespace
     * avg_writetime   : Average writetime for the tablespace
     * avg_readtime    : Average readtime  for the tablespace
     * min_readtime    : Oldest readtime  for the tablespace
     * max_readtime    : Latest readtime  for the tablespace
     * min_ftstime     : Oldest ftstime   for the tablespace
     * max_ftstime     : Latest ftstime   for the tablespace
     * avg_ftstime     : Average ftstime   for the tablespace
     * min_lookuptime  : Oldest lookuptime for the tablespace
     * max_lookuptime  : Latest lookuptime for the tablespace
     * avg_lookuptime  : Average lookuptime for the tablespace
     *
     */

    function tablespace_heat_map(
       tablespace_name      in varchar2)
       return hm_tablespace_table pipelined;
  
    -- Auto Advisor job to materialize heat maps
    procedure auto_advisor_heatmap_job(topn in number default 100);

end;
/
show errors;
create or replace public synonym dbms_heat_map for sys.dbms_heat_map
/
grant execute on dbms_heat_map to public
/


-- We support 5 DML operations with these procedures.  The functionality
-- exactly matches the DML performed locally in kelt.c.  The 5 operations
-- are:
--    insert_into_alert_outstanding
--    insert_into_alert_history
--    update_alert_outstanding
--    delete_from_alert_outstanding
--    delete_from_alert_history 

-- TBD: setup remote db link when supported
--drop public database link hub;
--create public database link hub connect to system identified by
--   manager using 'inst1';


-- Package declaration
create or replace package dbms_space_alert as
  procedure  insert_into_alert_outstanding
   (
    p_object_id                    NUMBER,   
    p_subobject_id                 NUMBER,   
    p_internal_instance_number     NUMBER,   
    p_owner                        VARCHAR2,  
    p_object_name                  VARCHAR2,  
    p_subobject_name               VARCHAR2,  
    p_sequence_id                  NUMBER,   
    p_reason_argument_1            VARCHAR2,  
    p_reason_argument_2            VARCHAR2,  
    p_reason_argument_3            VARCHAR2,  
    p_reason_argument_4            VARCHAR2,  
    p_reason_argument_5            VARCHAR2,  
    p_time_suggested               TIMESTAMP, 
    p_creation_time                TIMESTAMP, 
    p_action_argument_1            VARCHAR2,  
    p_action_argument_2            VARCHAR2,  
    p_action_argument_3            VARCHAR2,  
    p_action_argument_4            VARCHAR2,  
    p_action_argument_5            VARCHAR2,  
    p_message_level                NUMBER,   
    p_hosting_client_id            VARCHAR2,  
    p_process_id                   VARCHAR2,  
    p_host_id                      VARCHAR2,  
    p_host_nw_addr                 VARCHAR2,  
    p_instance_name                VARCHAR2,  
    p_instance_number              NUMBER,   
    p_user_id                      VARCHAR2,  
    p_execution_context_id         VARCHAR2,  
    p_error_instance_id            VARCHAR2,  
    p_context                      RAW, 
    p_metric_value                 NUMBER,   
    p_reason_id                    NUMBER,   
    p_state_transition_number      NUMBER,   
    p_pdb_name                     VARCHAR2,  
    p_con_id                       NUMBER   
  ) ;   
  -- ??? pragma restrict_references(insert_into_alert_outstanding, WNDS, RNDS);

  procedure insert_into_alert_history
  (
    p_sequence_id                  NUMBER,  
    p_owner                        VARCHAR2,  
    p_object_name                  VARCHAR2,  
    p_subobject_name               VARCHAR2,  
    p_reason_argument_1            VARCHAR2,  
    p_reason_argument_2            VARCHAR2,  
    p_reason_argument_3            VARCHAR2,  
    p_reason_argument_4            VARCHAR2,  
    p_reason_argument_5            VARCHAR2,  
    p_time_suggested               TIMESTAMP, 
    p_creation_time                TIMESTAMP, 
    p_action_argument_1            VARCHAR2,  
    p_action_argument_2            VARCHAR2,  
    p_action_argument_3            VARCHAR2,  
    p_action_argument_4            VARCHAR2,  
    p_action_argument_5            VARCHAR2,  
    p_message_level                NUMBER,  
    p_hosting_client_id            VARCHAR2,  
    p_process_id                   VARCHAR2,  
    p_host_id                      VARCHAR2,  
    p_host_nw_addr                 VARCHAR2,  
    p_instance_name                VARCHAR2,  
    p_instance_number              NUMBER,  
    p_user_id                      VARCHAR2,  
    p_execution_context_id         VARCHAR2,  
    p_error_instance_id            VARCHAR2,  
    p_resolution                   NUMBER,  
    p_metric_value                 NUMBER,  
    p_state_transition_number      NUMBER,   
    p_reason_id                    NUMBER,  
    p_pdb_name                     VARCHAR2,  
    p_con_id                       NUMBER 
  );
  -- ??? pragma restrict_references(insert_into_alert_history, WNDS, RNDS);

  procedure update_alert_outstanding
  (
    -- IN params 
    i_reason_argument_1          VARCHAR2,   
    i_reason_argument_2          VARCHAR2,   
    i_reason_argument_3          VARCHAR2,   
    i_reason_argument_4          VARCHAR2,   
    i_reason_argument_5          VARCHAR2,   
    i_time_suggested             TIMESTAMP, 
    i_action_argument_1          VARCHAR2,   
    i_action_argument_2          VARCHAR2,   
    i_action_argument_3          VARCHAR2,   
    i_action_argument_4          VARCHAR2,   
    i_action_argument_5          VARCHAR2,   
    i_message_level              NUMBER,   
    i_hosting_client_id          VARCHAR2,   
    i_process_id                 VARCHAR2,   
    i_host_id                    VARCHAR2,   
    i_host_nw_addr               VARCHAR2,   
    i_instance_name              VARCHAR2,   
    i_instance_number            NUMBER,  
    i_user_id                    VARCHAR2,   
    i_execution_context_id       VARCHAR2,   
    i_context                    RAW, 
    i_metric_value               NUMBER,  
    i_reason_id                  NUMBER,    
    i_object_id                  NUMBER,    
    i_subobject_id               NUMBER,    
    i_internal_instance_number   NUMBER,     
    i_con_id                     NUMBER,       
    -- OUT params  
    o_owner                      OUT   VARCHAR2, 
    o_object_name                OUT   VARCHAR2, 
    o_subobject_name             OUT   VARCHAR2, 
    o_sequence_id                OUT   NUMBER, 
    o_error_instance_id          OUT   VARCHAR2, 
    o_state_transition_number    OUT   NUMBER, 
    o_creation_time              OUT   TIMESTAMP, 
    o_pdb_name                   OUT   VARCHAR2
  ) ;   
  -- ??? pragma restrict_references(update_alert_outstanding, WNDS, RNDS);

  procedure delete_from_alert_outstanding
  (
    -- IN params
    i_reason_id                 NUMBER,  
    i_object_id                 NUMBER,  
    i_subobject_id              NUMBER,  
    i_internal_instance_number  NUMBER,  
    i_con_id                    NUMBER,  
    -- OUT params 
    o_owner                     OUT VARCHAR2,  
    o_object_name               OUT VARCHAR2,  
    o_subobject_name            OUT VARCHAR2,  
    o_sequence_id               OUT NUMBER,  
    o_error_instance_id         OUT VARCHAR2,  
    o_state_transition_number   OUT NUMBER,  
    o_creation_time             OUT TIMESTAMP, 
    o_pdb_name                  OUT VARCHAR2  
  );
  -- ??? pragma restrict_references(delete_from_alert_outstanding, WNDS, RNDS);

  procedure  delete_from_alert_history 
  (  i_time_suggested   TIMESTAMP ); 
  -- ??? pragma restrict_references(delete_from_alert_history, WNDS, RNDS);
end; 
/ 

create or replace public synonym dbms_space_alert for sys.dbms_space_alert
/


-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY dbms_space_alert_LIB TRUSTED AS STATIC;
/


@?/rdbms/admin/sqlsessend.sql
