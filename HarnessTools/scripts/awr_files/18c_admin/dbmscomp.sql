Rem
Rem $Header: rdbms/admin/dbmscomp.sql /main/26 2014/08/12 00:29:12 ptearle Exp $
Rem
Rem dbmscomp.sql
Rem
Rem Copyright (c) 2007, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmscomp.sql - DBMS Compression package
Rem
Rem    DESCRIPTION
Rem      Contains package specification for the wrapper dbms_compression
Rem      package and internal prvt_compression package. We integrate these
Rem      packages with the advisor framework.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmscomp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmscomp.sql
Rem SQL_PHASE: DBMSCOMP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ptearle     06/03/14 - 18497527: add CLEAR_ANALYSIS
Rem    pkapil      07/17/14 - bug 19230065
Rem    amylavar    04/10/14 - New IMC compression levels
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jekamp      09/27/13 - Project 35591: new syntax
Rem    hlakshma    05/21/13 - Add medium inmemory compression level
Rem    shrgauta    01/23/13 - making change in signature of get_compression_typ
Rem                           to make it compatible with older scripts
Rem    jekamp      11/27/12 - ICD to dump compression map
Rem    shrgauta    11/15/12 - changed the signature of get_compression_type for passing name of partition.
Rem    shrgauta    11/15/12 - changed the signature of get_compression_type 
Rem                           for passing name of partition.
Rem                           Added new constants for recognizing partition and subpartition name.
Rem    shrgauta    11/08/12 - added a new constant for BASIC type .
Rem    xihua       10/11/12 - Index Compression Factoring Change
Rem    amylavar    09/25/12 - Change names of ACO/HCC constants
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    xihua       09/30/11 - Compression advisor for index
Rem    amylavar    07/29/11 - add a compression level
Rem    xihua       03/17/11 - Estimate compression ratio for lobs.
Rem    kshergil    10/06/09 - get_compression_ratio changes
Rem    amylavar    05/14/09 - Add autocompress option to incremental_compress
Rem    amylavar    05/04/09 - Add incremental_compress
Rem    amylavar    04/30/09 - Add get_compression_type function to figure out compression
Rem                           level/type per ROWID
Rem    apanagar    03/02/09 - change numerical compression level to support
Rem                           low, medium, high
Rem    amitsha     01/08/09 - make the package work for partitioned tables and
Rem                           an optional parameter for specifying partitions
Rem    amitsha     04/06/08 - make compression advisor functionally complete 
Rem    vmarwah     03/31/08 - remove the SET statements
Rem    vmarwah     03/26/08 - forward merge to MAIN
Rem    amitsha     03/12/08 - Implement Compression advisor using advisor
Rem                           framework
Rem    amitsha     12/17/07 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package dbms_compression authid current_user is

COMP_NOCOMPRESS               CONSTANT NUMBER := 1;
COMP_ADVANCED                 CONSTANT NUMBER := 2;
COMP_QUERY_HIGH               CONSTANT NUMBER := 4;
COMP_QUERY_LOW                CONSTANT NUMBER := 8;
COMP_ARCHIVE_HIGH             CONSTANT NUMBER := 16;
COMP_ARCHIVE_LOW              CONSTANT NUMBER := 32; 
COMP_BLOCK                    CONSTANT NUMBER := 64; 
COMP_LOB_HIGH                 CONSTANT NUMBER := 128;
COMP_LOB_MEDIUM               CONSTANT NUMBER := 256;
COMP_LOB_LOW                  CONSTANT NUMBER := 512;
COMP_INDEX_ADVANCED_HIGH      CONSTANT NUMBER := 1024;
COMP_INDEX_ADVANCED_LOW       CONSTANT NUMBER := 2048;
COMP_BASIC                    CONSTANT NUMBER := 4096;
COMP_INMEMORY_NOCOMPRESS      CONSTANT NUMBER := 8192;
COMP_INMEMORY_DML             CONSTANT NUMBER := 16384;
COMP_INMEMORY_QUERY_LOW       CONSTANT NUMBER := 32768;
COMP_INMEMORY_QUERY_HIGH      CONSTANT NUMBER := 65536;
COMP_INMEMORY_CAPACITY_LOW    CONSTANT NUMBER := 131072;
COMP_INMEMORY_CAPACITY_HIGH   CONSTANT NUMBER := 262144;

COMP_RATIO_MINROWS            CONSTANT NUMBER := 1000000;
COMP_RATIO_ALLROWS            CONSTANT NUMBER := -1;
COMP_RATIO_LOB_MINROWS        CONSTANT NUMBER := 1000;
COMP_RATIO_LOB_MAXROWS        CONSTANT NUMBER := 5000;
COMP_RATIO_INDEX_MINROWS      CONSTANT NUMBER := 100000;

OBJTYPE_TABLE                 CONSTANT NUMBER := 1;
OBJTYPE_INDEX                 CONSTANT NUMBER := 2;           
OBJTYPE_PART                  CONSTANT NUMBER := 3;
OBJTYPE_SUBPART               CONSTANT NUMBER := 4;

--Record for calculating an individual index cr on a table
type compRec is record(
  ownname           varchar2(255),
  objname           varchar2(255),
  blkcnt_cmp        PLS_INTEGER,
  blkcnt_uncmp      PLS_INTEGER,
  row_cmp           PLS_INTEGER,
  row_uncmp         PLS_INTEGER,
  cmp_ratio         NUMBER,
  objtype           PLS_INTEGER
);

type compRecList is table of compRec; 

  --Get compression ratio for an object: table/index. Default is table.
  PROCEDURE get_compression_ratio(
    scratchtbsname        IN     varchar2,
    ownname               IN     varchar2,
    objname               IN     varchar2,
    subobjname            IN     varchar2,
    comptype              IN     number,
    blkcnt_cmp            OUT    PLS_INTEGER,
    blkcnt_uncmp          OUT    PLS_INTEGER,
    row_cmp               OUT    PLS_INTEGER,
    row_uncmp             OUT    PLS_INTEGER,
    cmp_ratio             OUT    NUMBER,
    comptype_str          OUT    varchar2,
    subset_numrows        IN     number  DEFAULT COMP_RATIO_MINROWS,
    objtype               IN     PLS_INTEGER DEFAULT OBJTYPE_TABLE
  );

  --Get compression ratio for lobs
  PROCEDURE get_compression_ratio(
    scratchtbsname        IN     varchar2,
    tabowner              IN     varchar2,
    tabname               IN     varchar2,
    lobname               IN     varchar2,
    partname              IN     varchar2,
    comptype              IN     number,
    blkcnt_cmp            OUT    PLS_INTEGER,
    blkcnt_uncmp          OUT    PLS_INTEGER,
    lobcnt                OUT    PLS_INTEGER,
    cmp_ratio             OUT    NUMBER,
    comptype_str          OUT    varchar2,
    subset_numrows        IN     number DEFAULT COMP_RATIO_LOB_MAXROWS
  );


  --Get compression ratio for all indexes on a table. The compression
  --ratios will be returned as a collection.
  PROCEDURE get_compression_ratio(
    scratchtbsname        IN     varchar2,
    ownname               IN     varchar2,
    tabname               IN     varchar2,
    comptype              IN     number,
    index_cr              OUT    compRecList,
    comptype_str          OUT    varchar2,
    subset_numrows        IN     number DEFAULT COMP_RATIO_INDEX_MINROWS
  );
  
  function get_compression_type (
    ownname         IN varchar2,
    tabname         IN varchar2,
    row_id          IN rowid,
    subobjname      IN varchar2 DEFAULT NULL
  )
    return number;

  PROCEDURE dump_compression_map (
    ownname         IN varchar2,
    tabname         IN varchar2,
    comptype        IN number
  );

/*      SYNTAX:                                                                                                                 
          call incremental_compress(<Owner name>, <Table name>, <Partition Name>, <Column Name>, [Dump], [Auto Compress], [Where Clause]);                   
          <Owner Name>:     Name of the owner of the table
          <Table Name>:     Name of table under consideration
          <Partition Name>: If the table is partitioned (or sub-partitioned), specify the specific partition (or sub-partition)
                            name here. If the table is sub-partitioned, then each sub-partition will have to be compressed
                            separately. For tables that are not partitioned, this parameter is ignored, so a '' can be specified.
                            NOTE: Each partition or subpartition will have to be compressed separately. It is erroneous to                                          
                            specify a partition name for a table with sub-partitions. The specific sub-partition name will                                 
                            have to be specified.
          <Column Name>:    This column can be any column name in the table. An update statement of the type
                            'update table_name set column_name = column_name' will be run, so choosing any column name should
                            not make any functional difference.
          [Dump]:           An optional parameter that dumps out the space saved in each block into the trace files. It is turned                             
                            OFF by default (set to 0). It is advised not to turn this feature on for large tables or partitions
                            because of excessive logging.
          [Auto Compress]:  If table is not created compressed or compression was never used on this table/partition, setting this to 1 will 
                            force an alter table to switch on and then switch off compression on this table/partition.
          [Where Clause]:   An optional where clause supplied to the update statement. */

  PROCEDURE incremental_compress (
        ownname            IN dba_objects.owner%type,
        tabname            IN dba_objects.object_name%type,
        partname           IN dba_objects.subobject_name%type,
        colname            IN varchar2,
        dump_on            IN number default 0,
        autocompress_on    IN number default 0,
        where_clause       IN varchar2 default '');

  PROCEDURE clear_analysis (
        ownname         IN varchar2,
        tabname         IN varchar2,
        comptype        IN number default 0);


end dbms_compression;
/

create or replace public synonym dbms_compression for sys.dbms_compression
/

grant execute on dbms_compression to public
/

show errors;

@?/rdbms/admin/sqlsessend.sql
