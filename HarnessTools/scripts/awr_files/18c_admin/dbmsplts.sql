Rem
Rem $Header: rdbms/admin/dbmsplts.sql /main/68 2017/06/01 05:42:10 mwjohnso Exp $
Rem
Rem dbmsplts.sql
Rem
Rem Copyright (c) 1998, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsplts.sql - Pluggable Tablespace Package Specification
Rem
Rem    DESCRIPTION
Rem      This package contains procedures and functions supporting the
Rem      Pluggable Tablespace feature.  They are mostly called by import and
Rem      export, but both old and new.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsplts.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsplts.sql
Rem SQL_PHASE: DBMSPLTS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mwjohnso    03/24/17 - BUG 25697336: add whitelists add plts_newDatafile
Rem    dgagne      07/20/16 - make error numbers constant
Rem    jkrismer    01/15/16 - Bug 22549364 hwmincr signed integer overflow
Rem    dgagne      10/02/15 - remove unnecessary routine dpmode
Rem    svrrao      12/22/14 - 47110: Support encrypted tablespace export/import
Rem    adalee      09/29/14 - tablespace rekey
Rem    dgagne      04/15/14 - long identifier support
Rem    dgagne      02/05/14 - change flags field
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    dgagne      12/08/13 - add dpmode to pass in datapump mode
Rem    teclee      06/22/13 - Bug 16758465: IMC numeric overflow
Rem    mjangir     10/18/12 - bug 14785068: convert obj# to number
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    xihua       09/11/11 - change spare1 to number for seg$ query
Rem    jkaloger    06/15/11 - encryption password work for db consolidation
Rem    dgagne      05/26/11 - do not fail containment check for encrypted
Rem                           colums if full
Rem    adalee      05/24/11 - add kcp_tse_put_protect_tse_key
Rem    dgagne      05/02/11 - add workaroun to skip certain tablespaces
Rem    adalee      04/19/11 - add kcp_tse_get_protect_tse_key
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    dgagne      03/17/11 - add argument to checkpluggable
Rem    rmir        03/17/11 - Bug 10351061, datapump support for CE tables
Rem    adalee      02/16/11 - add PASSPHRASE_REWRAP_KEY to DBMS_TTS
Rem    dgagne      11/03/10 - allow export of read only database
Rem    dgagne      10/16/10 - don't make kcp_aldfts public
Rem    dgagne      03/20/07 - remove public grant
Rem    dgagne      09/19/06 - add insert_error procedure
Rem    spetride    05/15/06 - add check_csx_closure
Rem    dgagne      06/22/06 - use number when fetching number variables from 
Rem                           dictionary 
Rem    kamble      03/17/06 - 4282397: patch lob property for pre10i tts
Rem    dgagne      01/31/06 - add exception definitions and put routine
Rem                           comments before the routine definition and add
Rem                           comments to routines that don't have any
Rem    dgagne      02/28/06 - add additional optional argument to 
Rem                           checktablespace 
Rem    dgagne      02/17/06 - add sendtracemessage 
Rem    dgagne      11/18/05 - create global temp tables for plugts packages
Rem    dgagne      10/06/05 - change reclaim_temp_segment to reclaim_segment
Rem    ahwang      05/18/04 - external db char set check
Rem    jgalanes    05/11/04 - Add new fixup proc for 3573604 BITMAP index
Rem                           version lost on TTS transport
Rem    wfisher     05/05/04 - Remap tsnames and control closure checking
Rem    ahwang      03/19/04 - bug 3551627 - allow more multibyte char sets
Rem    wyang       03/01/04 - transportable db
Rem    bkhaladk    02/25/04 - support for SB Xmltype
Rem    ahwang      07/09/03 - bug 277194 - temp segment transport
Rem    jgalanes    07/22/03 - Fix 3048060 Xplatform INTCOLS
Rem    apareek     06/14/03 - add containment check for nested tables
Rem    wesmith     06/11/03 - verify_MV(): add parameter full_check
Rem    apareek     05/29/03 - add support for MVs
Rem    rasivara    04/22/03 - bug 2918098: BIG ts_list field for some
Rem                           procedures
Rem    apareek     03/03/03 - grant dbms_plugts to execute_catalog_role
Rem    apareek     09/30/02 - cross platform changes
Rem    dfriedma    05/22/02 - kfp renamed to kcp
Rem    sjhala      04/04/02 - 2198861: preserve migrated ts info with plugin
Rem    yuli        02/25/02 - add function kfp_getcomp
Rem    bmccarth    01/14/02 - Bug 802824 -move patchtablemetadata into its
Rem                           own package and set to execute public
Rem    bzane       11/05/01 - BUG 1754947: add exception 29353
Rem    rburns      10/26/01 - catch 942 exception
Rem    smuralid    09/08/01 - add patchTableMetadata
Rem    amsrivas    06/21/01 - bug 1826474: get absolute file# from file header
Rem    apareek     02/08/01 - add full_check for 2 way violations
Rem    apareek     11/10/00 - bug 1494388
Rem    jdavison    11/28/00 - Drop extra semi-colons
Rem    apareek     10/30/00 - add verify_unused_cols
Rem    apareek     07/10/00 - fix for sqlplus
Rem    apareek     05/30/00 - add extended_tts_checks
Rem    yuli        12/06/99 - bug 972035: add function kfp_getfh
Rem    jwlee       06/09/99 - bug 864670: check nchar set ID
Rem    jwlee       09/28/98 - check system and temporary tablespace
Rem    jwlee       06/25/98 - misc fixes
Rem    jwlee       06/16/98 - create temp table on the fly
Rem    jwlee       05/19/98 - add dbms_tts package
Rem    jwlee       05/03/98 - add place holder for char set name
Rem    jwlee       04/04/98 - add more exceptions
Rem    jwlee       04/02/98 - Complete coding for first phase
Rem    jwlee       03/30/98 - more
Rem    jwlee       03/30/98 - more on transportable tablespace
Rem    jwlee       03/26/98 - more
Rem    jwlee       03/19/98 - more on Pluggable Tablespace
Rem    jwlee       03/06/98 - Remove highSCN parameter from beginImport
Rem    jwlee       02/25/98 - Pluggable Tablespace Package Specification
Rem    jwlee       02/25/98 - Created
Rem
--
-- Transportable export from a read only database is a desirable feature.  This
-- was broken in 11.1.0.6 during the cleanup phases of these modules.  The code
-- was changed from using internal pl/sql tables to global temporary tables
-- Although this was a nice cleanup, it broke the read only database export
-- since information was expected to be stored in these temporary tables.
--
-- To fix this problem, the code will once again use pl/sql tables, but will
-- use a PIPELINED TABLE function around the table to make it look like a
-- database table. This code is always run on the source, so if the source is
-- version 12.2 it needs to communicate with the target that may be 12.1.  The
-- problem is that if the global temporary tables are used in 12.1 to
-- communicate with plugts and if the global temporary tables are removed from
-- this code, the older version of Data Pump can't communicate with a newer
-- version of prvtplts.  All this means that we can never get rid of the
-- global temporary tables.  What can be done though is use the pl/sql tables
-- and fill in the global temporary error table if there are errors.  If the
-- database is write locked, the remote Data Pump job will fail but the list
-- of violations will be null.
--

@@?/rdbms/admin/sqlsessstart.sql

DROP TYPE sys.tts_info_tab FORCE;
DROP TYPE sys.tts_info_tab_t FORCE;
DROP TYPE sys.tts_info_t FORCE;
DROP TYPE sys.tts_error_tab FORCE;
DROP TYPE sys.tts_error_tab_t FORCE;
DROP TYPE sys.tts_error_t FORCE;

--
-- Create types for user names and tablespace names
--
CREATE TYPE tts_info_t AS OBJECT(
        name   VARCHAR2(128),                   -- KUPCC.T_ID
        ts#    NUMBER,
        found  NUMBER);
/
GRANT EXECUTE ON sys.tts_info_t TO PUBLIC;

CREATE TYPE tts_info_tab_t IS TABLE OF tts_info_t;
/
GRANT EXECUTE ON sys.tts_info_tab_t TO PUBLIC;

--
-- Create types for errors
--
CREATE TYPE tts_error_t AS OBJECT(
        violations VARCHAR2(2000));             -- KUPCC.T_VIOLATION
/
GRANT EXECUTE ON sys.tts_error_t TO PUBLIC;

CREATE TYPE tts_error_tab_t IS TABLE OF tts_error_t;
/
GRANT EXECUTE ON sys.tts_error_tab_t TO PUBLIC;

CREATE OR REPLACE PACKAGE dbms_plugts IS

  ts_exp_begin  CONSTANT BINARY_INTEGER := 1;
  ts_exp_end    CONSTANT BINARY_INTEGER := 2;

  --
  -- Function variables
  --
  C_ADD         CONSTANT NUMBER := 1;
  C_TRUNCATE    CONSTANT NUMBER := 2;
  C_USER        CONSTANT NUMBER := 1;
  C_TABLESPACE  CONSTANT NUMBER := 2;

  /**********************************************
  **   Routines called directly by EXPORT      **
  **********************************************/

  --++
  -- Definition:  This procedure constructs the beginImport call in an
  --              anonymous PL/SQL block.
  --
  -- Inputs:      None
  --
  -- Outputs:     None
  --++
  PROCEDURE beginExport;

  --++
  -- Definition:  This procedure verifies tablespaces are read-only during
  --              export. It is called for each tablespace specified
  --
  -- Inputs:      tsname = tablespace name to verify
  --
  -- Outputs:     None
  --
  -- Possible Exceptions:
  --              ts_not_found
  --              ts_not_read_only
  --++
  PROCEDURE beginExpTablespace(
        tsname  IN VARCHAR2);

  --++
  -- Definition:  This procedure verifies objects are self-contained in the
  --              tablespaces specified.
  --
  -- Inputs:      incl_constraints = 1 if include constraints, 0 otherwise
  --              incl_triggers    = 1 if include triggers, 0 otherwise
  --              incl_grants      = 1 if include grants, 0 otherwise
  --              full_closure     = TRUE if both IN and OUT pointers are
  --                                 considered violations
  --                                 (should be TRUE for TSPITR)
  --              do_check         = 1 if check should be done, 0 if not done
  --              job_type         = DATABASE_EXPORT IF FULL TTS
  --              encryption_password = true if encryption password supplied
  --                                    on command line.
  --
  -- Outputs:     None
  --
  -- Possible Exceptions:
  --              ORA-29341 (not_self_contained)
  --              ORA-29354 (rekey_in_progress)
  --++
  PROCEDURE checkPluggable(
        incl_constraints        IN NUMBER,
        incl_triggers           IN NUMBER,
        incl_grants             IN NUMBER,
        full_check              IN NUMBER,
        do_check                IN NUMBER DEFAULT 1,
        job_type                IN VARCHAR2 DEFAULT NULL,
        encryption_password     IN BOOLEAN DEFAULT FALSE);

  --++
  -- Definition:  This function returns the next line of a block that has been
  --              previously selected for retrieval via selectBlock.
  --
  -- Inputs:      None
  --
  -- Outputs:     None
  --
  -- Returns:     A string to be appended to the export file.
  --++
  FUNCTION getLine
    RETURN VARCHAR2;

  --++
  -- Definition:  This procedures selects a particular PL/SQL anonymous block
  --              for retrieval.
  --
  -- Inputs:      blockID = the ID to pick a PL/SQL anonymous block
  --                        dbms_plugts.TS_EXP_BEGIN at the beginning of export
  --                        dbms_plugts.TS_EXP_END at the end of export
  -- Outputs:     None
  --++
  PROCEDURE selectBlock(
        blockID         IN BINARY_INTEGER);

  /**********************************************
  **   Routines called directly by IMPORT      **
  **********************************************/

  --++
  -- Definition:  The procedure informs the dbms_Plugts package about the
  --              location of a new datafile.
  --              - If PDB PATH_PREFIX property is set then the absolute path
  --                must begin with the PATH_PREFIX, otherwise an ORA-65254
  --                will be signaled.
  --              - If the file can not be found, an error will be signaled,
  --                possible at a later point.
  --
  -- Inputs:      filename = file name (including path)
  --
  -- Outputs:     None
  --
  -- Usage:       Called from C code in classic Import (imptts.c).
  --              dbms_pdb.is_valid_path() required to valid absolute path.
  --
  --++
  PROCEDURE newDatafile(
        filename        IN VARCHAR2);

  --++
  -- Definition:  The procedure informs the dbms_Plugts package about the
  --              location of a new datafile.
  --              - This is a whitelist version of newDatafile
  --                Only accessible from the sys.kupw$worker package.
  --              - If the file can not be found, an error will be signaled,
  --                possible at a later point.
  --
  -- Inputs:      filename = file name (including path)
  --
  -- Outputs:     None
  --
  --++
  PROCEDURE plts_newDatafile(
        filename        IN VARCHAR2)
     ACCESSIBLE BY (PACKAGE sys.kupw$worker);

  --++
  -- Definition:  This procedure informs the dbms_plugts package about
  --              tablespace name to be included in the job.
  --
  -- Inputs:      tsname - Tablespace name
  --
  -- Outputs:     None
  --++
  PROCEDURE newTablespace(
        tsname          IN VARCHAR2);

  --++
  -- Definition:   This procedure adds a schema to the import job.
  --
  -- Inputs:       schemaname - schema name
  --
  -- Outputs:      None
  --++
  PROCEDURE pluggableUser(
        schemaname      IN VARCHAR2);

  --++
  -- Definition:  This procedure informs the plugts package about remap_user
  --              information.
  --
  -- Inputs:      from_user - a user in FROM_USER list
  --              to_user   - the corresponding user in TO_USER list
  --
  -- Outputs:     None
  --++
  PROCEDURE mapUser(
        from_user       IN VARCHAR2,
        to_user         IN VARCHAR2);

  --++
  -- Definition:  This procedure informs the plugts package about
  --              REMAP_TABLESPACE information.
  --
  -- Inputs:      from_ts - a tablespace name to be remapped
  --              to_ts   - the new corresponding tablespace to be created
  --
  -- Outputs:     None
  --++
  PROCEDURE mapTs(
        from_ts         IN VARCHAR2,
        to_ts           IN VARCHAR2);

  /*******************************************************************
  **  Routines called automatically via the PL/SQL anonymous block  **
  *******************************************************************/
  --++
  -- Definition:  This procedure informs the plugts package about the target
  --              tablespaces and it's owner. It checks to make sure the
  --              tablespace name does not conflict with any existing
  --              tablespaces already in the database. It verifies the block
  --              size is the same as that in the target database. If all this
  --              succeeds, it begins importing metadata for the tablespace.
  --              This procedure call appears in the export file.
  --
  --              The parameter list includes all columns for ts$, except those
  --              that will be discarded (online$, undofile#, undoblock#,
  --              ownerinstance, backupowner).  The spares are included so that
  --              the interface does not have to be changed even when these
  --              spares are used in the future.
  --
  --              Three extra parameters are added for transporting migrated
  --              tablespaces. seg_fno, seg_bno and seg_blks represent the
  --              dictionary information held in SEG$ for any tablespace which
  --              was migrated from dictionary managed to locally managed. The
  --              file# and block# give the location of bitmap space header for
  --              the migrated tablespace and the blocks parameter represents
  --              the size of the space header in blocks.
  --
  -- Inputs:      tsname          - tablespace name
  --              tsID            - tablespace ID in original database
  --              owner           - owner of tablespace
  --              n_files         - number of datafiles in the tablespace
  --              contents        - contents column of ts$ (TEMP/PERMANENT)
  --              blkSize         - size of block in bytes
  --              inc_num         - incarnation number of extent
  --              clean_SCN       - tablespace clean SCN,
  --              dflminext       - default minimum number of extents
  --              dflmaxext       - default maximum number of extents
  --              dflinit         - default initial extent size
  --              dflincr         - default initial extent size
  --              dflminlen       - default minimum extent size
  --              dflextpct       - default percent extent size increase
  --              dflogging       - default logging attribute
  --              affstrength     - Affinity strength
  --              bitmapped       - If bitmapped
  --              dbID            - database ID
  --              directallowed   - allowed
  --              flags           - flags
  --              creation_SCN    - tablespace creation SCN
  --              groupname       - Group name
  --              spare1          - spare1 in ts$
  --              spare2          - spare2 in ts$
  --              spare3          - spare3 in ts$
  --              spare4          - spare4 in ts$
  --              seg_fno         - file# for space_hdr in seg$
  --              seg_bno         - block# for space_hdr in seg$
  --              seg_blks        - blocks, size of space_hdr in seg$
  --
  -- Outputs:     None
  --++
  PROCEDURE beginImpTablespace(
        tsname          IN VARCHAR2,
        tsID            IN NUMBER,
        owner           IN VARCHAR2,
        n_files         IN BINARY_INTEGER,
        contents        IN BINARY_INTEGER,
        blkSize         IN BINARY_INTEGER,
        inc_num         IN BINARY_INTEGER,
        clean_SCN       IN NUMBER,
        dflminext       IN NUMBER,
        dflmaxext       IN NUMBER,
        dflinit         IN NUMBER,
        dflincr         IN NUMBER,
        dflminlen       IN NUMBER,
        dflextpct       IN BINARY_INTEGER,
        dflogging       IN BINARY_INTEGER,
        affstrength     IN NUMBER,
        bitmapped       IN NUMBER,
        dbID            IN NUMBER,
        directallowed   IN NUMBER,
        flags           IN NUMBER,
        creation_SCN    IN NUMBER,
        groupname       IN VARCHAR2,
        spare1          IN NUMBER,
        spare2          IN NUMBER,
        spare3          IN VARCHAR2,
        spare4          IN DATE,
        seg_fno         IN NUMBER DEFAULT 0,
        seg_bno         IN NUMBER DEFAULT 0,
        seg_blks        IN NUMBER DEFAULT 0);

  --++
  -- Definition:  This procedure checks to see that the user name in the
  --              pluggable set matches that entered by the DBA via the import
  --              USERS command line option. Make sure that, after the user
  --              mappings, the required user is already in the database. This
  --              procedure call appears in the export file.
  --
  -- Inputs:      schemaname - schema name
  --
  -- Outputs:     None
  --++
  PROCEDURE checkUser(
        schemaname      IN varchar2);

  --++
  -- Definition:  This procedure passes the information about the pluggable set
  --              to the PL/SQL package. Among them is the release version of
  --              the Oracle executable that created the pluggable set, which
  --              is used for checking compatibility.  This procedure call
  --              appears in the export file.
  --
  -- Inputs:      clone_oracle_version - release version of Oracle executable
  --                                     that created the pluggable set
  --              charsetID            - character set ID
  --              ncharsetID           - nchar set ID, in varchar2 format
  --                                     (May be NULL if generated by 8.1.5)
  --              platformID           - platform ID
  --              platformName         - platform name
  --              highest_data_objnum  - highest data object # in pluggable set
  --              highest_lob_sequence - highest LOB seq # in pluggable set
  --              n_ts                 - number of tablespace to be plugged in
  --              has_clobs            - if tablespaces have CLOB data
  --              has_nchars           - if tablespaces have nchar data
  --              char_smeantics_on    - if tablespaces have char semantic data
  --
  -- Outputs:     None
  --++
  PROCEDURE beginImport(
        clone_oracle_version    IN VARCHAR2,
        charsetID               IN BINARY_INTEGER,
        ncharsetID              IN VARCHAR2,
        srcplatformID           IN BINARY_INTEGER,
        srcplatformName         IN VARCHAR2,
        highest_data_objnum     IN NUMBER,
        highest_lob_sequence    IN NUMBER,
        n_ts                    IN NUMBER,
        has_clobs               IN NUMBER DEFAULT 1,
        has_nchars              IN NUMBER DEFAULT 1,
        char_semantics_on       IN NUMBER DEFAULT 1);

  --++
  -- Definition:  This procedure checks and adjusts the version for each
  --              compatibility type. This procedure is in the export file.
  --
  -- Inputs:      compID - compatibility type name
  --              compRL - release level
  --
  -- Outputs:     None
  --++
  PROCEDURE checkCompType(
        compID          IN VARCHAR2,
        compRL          IN VARCHAR2);

  --++
  -- Definition:  This procedure calls statically linked C routines to
  --              associate the datafile with the tablespace and validates file
  --              headers. This procedure appears in the export file.
  --
  --              The parameter list includes all columns in file$, except
  --              those that will be discarded (status$, ownerinstance).
  --
  -- Inputs:      filename         - file name (excluding path)
  --              databaseID       - database ID
  --              absolute_fno     - absolute file number
  --              curFileBlks      - size of file in blocks
  --              tablespace_ID    - tablespace ID in original database
  --              relative_fno     - relative file number
  --              maxextend        - maximum file size
  --              inc              - increment amount
  --              creation_SCN     - file creation SCN
  --              checkpoint_SCN   - file checkpoint SCN
  --              reset_SCN        - file reset SCN
  --              spare1           - spare1 in file$
  --              spare2           - spare2 in file$
  --              spare3           - spare3 in file$
  --              spare4           - spare4 in file$
  --
  -- Outputs:     None
  --++
  PROCEDURE checkDatafile(
        filename        IN VARCHAR2,
        databaseID      IN NUMBER,
        absolute_fno    IN BINARY_INTEGER,
        curFileBlks     IN NUMBER,
        tablespace_ID   IN NUMBER,
        relative_fno    IN BINARY_INTEGER,
        maxextend       IN NUMBER,
        inc             IN NUMBER,
        creation_SCN    IN NUMBER,
        checkpoint_SCN  IN NUMBER,
        reset_SCN       IN NUMBER,
        spare1          IN NUMBER,
        spare2          IN NUMBER,
        spare3          IN VARCHAR2,
        spare4          IN DATE);

  --++
  -- Definition:  This procedure wraps up the tablespace check. This procedure
  --              call appears in the export file.
  --
  -- Inputs:      None
  --
  -- Outputs:     None
  --++
  PROCEDURE endImpTablespace;

  --++
  -- Definition:  This procedure calls a statically linked C routine to
  --              atomically plug-in the pluggable set. This procedure call
  --              appears in the export file.
  --
  -- Inputs:      None
  --
  -- Outputs:     None
  --++
  PROCEDURE commitPluggable;

  --++
  -- Definition:  This procedure reclaims a segment by calling the statically
  --              linked C routine kcp_plg_reclaim_segment.  This procedure
  --              call appears in the export file.
  --
  -- Inputs:      The parameters match seg$ columns exactly. See seg$
  --              description.
  --
  -- Outputs:     NOne
  --++
  PROCEDURE reclaimTempSegment(
        file_no         IN BINARY_INTEGER,
        block_no        IN BINARY_INTEGER,
        type_no         IN BINARY_INTEGER,
        ts_no           IN BINARY_INTEGER,
        blocks          IN BINARY_INTEGER,
        extents         IN BINARY_INTEGER,
        iniexts         IN BINARY_INTEGER,
        minexts         IN BINARY_INTEGER,
        maxexts         IN BINARY_INTEGER,
        extsize         IN BINARY_INTEGER,
        extpct          IN BINARY_INTEGER,
        user_no         IN BINARY_INTEGER,
        lists           IN BINARY_INTEGER,
        groups          IN BINARY_INTEGER,
        bitmapranges    IN NUMBER,
        cachehint       IN BINARY_INTEGER,
        scanhint        IN BINARY_INTEGER,
        hwmincr         IN NUMBER,
        spare1          IN NUMBER,
        spare2          IN BINARY_INTEGER);

  --++
  -- Definition:  This procedure does any final cleanup to end the import job.
  --
  -- Inputs:      None
  --
  -- Outputs:     None
  --++
  PROCEDURE endImport;

  --++
  -- Definition:  This procedure gets the db char set properties of the
  --              tablespaces in sys.tts_tbs$
  --
  -- Inputs:      None
  --
  -- Outputs:     has_clobs       - tablespaces have clobs columns
  --              has_nchars      - tablespaces have nchars columns
  --              char_semantics  - has character semantics columns
  --++
  PROCEDURE get_db_char_properties(
        has_clobs       OUT BINARY_INTEGER,
        has_nchars      OUT BINARY_INTEGER,
        char_semantics  OUT BINARY_INTEGER);

  --++
  -- Definition:  This function queries the pl/sql table and pipelines it to
  --              look like a sql table.
  --
  -- Inputs:      None
  --
  -- Outputs:     None
  --++
  FUNCTION tab_func
    RETURN sys.tts_info_tab_t pipelined;

  -- get current compatible setting
  --
  PROCEDURE kcp_getcomp(
        szcomp          OUT VARCHAR2);           -- compatible setting

  -- check if char, nchar set match (signal error is not)
  PROCEDURE kcp_chkchar(
        cid                     IN BINARY_INTEGER,      -- char ID
        ncid                    IN BINARY_INTEGER,      -- nchar ID
        chknc                   IN BINARY_INTEGER,      -- chech nchar (1 or 0)
        has_clobs               IN BINARY_INTEGER,
        has_nchars              IN BINARY_INTEGER,
        char_semantics_on       IN BINARY_INTEGER);

  /*******************************************************************
  **               Possible Exceptions                              **
  *******************************************************************/
  ts_not_found                  EXCEPTION;
  PRAGMA exception_init         (ts_not_found, -29304);
  ts_not_found_num              CONSTANT NUMBER := -29304;

  ts_not_read_only              EXCEPTION;
  PRAGMA exception_init         (ts_not_read_only, -29335);
  ts_not_read_only_num          CONSTANT NUMBER := -29335;

  internal_error                EXCEPTION;
  PRAGMA exception_init         (internal_error, -29336);
  internal_error_num            CONSTANT NUMBER := -29336;

  datafile_not_ready            EXCEPTION;
  PRAGMA exception_init         (datafile_not_ready, -29338);
  datafile_not_ready_num        CONSTANT NUMBER := -29338;

  blocksize_mismatch            EXCEPTION;
  PRAGMA exception_init         (blocksize_mismatch, -29339);
  blocksize_mismatch_num        CONSTANT NUMBER := -29339;

  exportfile_corrupted          EXCEPTION;
  PRAGMA exception_init         (exportfile_corrupted, -29340);
  exportfile_corrupted_num      CONSTANT NUMBER := -29340;

  not_self_contained            EXCEPTION;
  PRAGMA exception_init         (not_self_contained, -29341);
  not_self_contained_num        CONSTANT NUMBER := -29341;

  user_not_found                EXCEPTION;
  PRAGMA exception_init         (user_not_found, -29342);
  user_not_found_num            CONSTANT NUMBER := -29342;

  mapped_user_not_found         EXCEPTION;
  PRAGMA exception_init         (mapped_user_not_found, -29343);
  mapped_user_not_found_num     CONSTANT NUMBER := -29343;

  user_not_in_list              EXCEPTION;
  PRAGMA exception_init         (user_not_in_list, -29344);
  user_not_in_list_num          CONSTANT NUMBER := -29344;

  invalid_ts_list               EXCEPTION;
  PRAGMA exception_init         (invalid_ts_list, -29346);
  invalid_ts_list_num           CONSTANT NUMBER := -29346;

  ts_not_in_list                EXCEPTION;
  PRAGMA exception_init         (ts_not_in_list, -29347);
  ts_not_in_list_num            CONSTANT NUMBER := -29347;

  datafiles_missing             EXCEPTION;
  PRAGMA exception_init         (datafiles_missing, -29348);
  datafiles_missing_num         CONSTANT NUMBER := -29348;

  ts_name_conflict              EXCEPTION;
  PRAGMA exception_init         (ts_name_conflict, -29349);
  ts_name_conflict_num          CONSTANT NUMBER := -29349;

  sys_or_tmp_ts                 EXCEPTION;
  PRAGMA exception_init         (sys_or_tmp_ts, -29351);
  sys_or_tmp_ts_num             CONSTANT NUMBER := -29351;

  rekey_in_progress            EXCEPTION;
  PRAGMA exception_init         (rekey_in_progress, -29354);
  rekey_in_progress_num        CONSTANT NUMBER := -29354;

  ts_failure_list               EXCEPTION;
  PRAGMA exception_init         (ts_failure_list, -39185);
  ts_failure_list_num           CONSTANT NUMBER := -39185;

  ts_list_empty                 EXCEPTION;
  PRAGMA exception_init         (ts_list_empty, -39186);
  ts_list_empty_num             CONSTANT NUMBER := -39186;

  not_self_contained_list       EXCEPTION;
  PRAGMA exception_init         (not_self_contained_list, -39187);
  not_self_contained_list_num   CONSTANT NUMBER := -39187;

  encpwd_error                  EXCEPTION;
  PRAGMA exception_init         (encpwd_error, -39330);
  encpwd_error_num              CONSTANT NUMBER := -39330;

  invalid_path                  EXCEPTION;
  PRAGMA exception_init         (invalid_path, -65254);
  invalid_path_num              CONSTANT NUMBER := -65254;

  /******************************************************************
  **             Interface for testing, etc.                       **
  ******************************************************************/
  PROCEDURE init;

  --++
  -- Description:  Initialize global variables used for debugging trace
  --               messages
  --
  -- Inputs:       debug_flags: Trace/debug flags from /TRACE param or
  --                            trace/debug event, possibly including global
  --                            trace/debug flags
  --
  -- Outputs:      None
  --++
  PROCEDURE SetDebug(
        debug_flags     IN BINARY_INTEGER);

  --++
  -- Description: This procedure will send a message to the trace file using
  --              KUPF$FILE.TRACE.
  --
  -- Inputs:
  --      msg                     - message to print
  --
  -- Outputs:
  --      None
  --+
  PROCEDURE SendTraceMsg(
        msg     IN VARCHAR2);

  --++
  -- Description: This procedure will manage a plsql table
  --
  -- Inputs:
  --      function      - add or truncate
  --      plsqlTable    - user table or tablespace table
  --      name          - user to add or tablespace to add
  --      tsnum         - if tablespace, then tablespace number
  --
  -- Outputs:
  --      None
  --+
  PROCEDURE ManageplsqlTable (
    function      IN NUMBER,
    plsqlTable    IN NUMBER,
    name          IN VARCHAR2 DEFAULT NULL,
    tsnum         IN NUMBER DEFAULT NULL);

  --
  -- External C callout definitions
  --

  -- compute whether a plug into a specified db char and nchar set is
  -- compatible with current db.
  PROCEDURE kcp_check_tts_char_set_compat(
        has_clobs               IN BINARY_INTEGER,
        has_nchars              IN BINARY_INTEGER,
        char_semantics_on       IN BINARY_INTEGER,
        target_charset_name     IN VARCHAR2,
        target_ncharset_name    IN VARCHAR2);

END dbms_plugts;
/

GRANT EXECUTE ON dbms_plugts TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_plugtsp IS

  --++
  -- Definition:  This procedure will finish things up after objects have been
  --              created.  Patchup table metadata after table has been created
  --              at the import site. This procedure is called by import
  --
  -- Inputs:      schemaname     - schema name
  --              tablename      - table name
  --              mdClob         - data pump's metadata
  --              expSrvrEndian  - export endian
  --              impSrvrEndian  - import endian
  --
  -- Outputs:     None
  --++
  PROCEDURE patchTableMetadata(
        schemaname      IN VARCHAR2,
        tablename       IN VARCHAR2,
        mdClob          IN CLOB,
        expSrvrEndian   IN BINARY_INTEGER,
        impSrvrEndian   IN BINARY_INTEGER);

  --++
  -- Description:  This procedure wil fixup various things that get lost across
  --               transport due to no relevant syntax (i.e. options/versions
  --               based on compatibility rather than explicit syntax).  This
  --               is called during TTS import.
  --
  -- Inputs:       str1
  --               str2
  --               str3
  --               str4
  --               str5
  --               str6
  --               str7
  --               bin1
  --
  -- Outputs:      None
  --++
  PROCEDURE patchDictionary(
        str1    IN VARCHAR2,
        str2    IN VARCHAR2,
        str3    IN VARCHAR2,
        str4    IN VARCHAR2,
        str5    IN VARCHAR2,
        str6    IN VARCHAR2,
        str7    IN VARCHAR2,
        bin1    IN BINARY_INTEGER);

  --++
  -- Definition:  Patch up lob property after table has been created at the
  --              import site.  This procedure is called by import for pre 10i
  --              tts dump files
  --
  -- Inputs:      schemaname  - schema name
  --              tablename   - table name
  --
  -- Outputs:     None
  --++
  PROCEDURE patchLobProp(
        schemaname      IN VARCHAR2,
        tablename       IN VARCHAR2);

END dbms_plugtsp;
/
GRANT EXECUTE on dbms_plugtsp TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_tts IS

  --
  -- Type that containes a list of oracle object names.
  --
  TYPE ts_names_tab_t IS TABLE OF VARCHAR2(128) INDEX BY BINARY_INTEGER;

  --
  -- Input formats for passphrase in set_passphrase procedure.
  --
  obfuscated    CONSTANT PLS_INTEGER := 1;  -- obfuscated binary value
  encrypted     CONSTANT PLS_INTEGER := 2;  -- encrypted binary value

  -- This package checks if the transportable set is self-contained.  All
  -- violations are inserted into pl/sql table that can be selected from view
  -- transport_set_violations.
  --

  --++
  -- Definition: This procedure checks if a tablespace is temporary or if it is
  --             a tablespace that can not be exported using transportable
  --             tablespace mode.
  --
  -- Inputs:     tsname   - tablespace name
  --             ts_num   - tablespace id number
  --             upcase   - allow upcasing of username or not
  --
  -- Outputs:    None
  --++
  PROCEDURE checkTablespace(
        tsname          IN VARCHAR2,
        ts_num          IN OUT NUMBER,
        upcase          IN BOOLEAN DEFAULT FALSE);

  --++
  -- Definition:  This procedure performs a Diffie-Hellman key exchange.
  --              Data Pump worker process on target system executes this
  --              procedure over a network link on the remote source system.
  --              Once this key exchange has taken place, both sides can
  --              transmit sensitive data securely.
  --
  -- Inputs:      source_key       - public key of the source process. In this
  --                                 case "source" refers to the initiator
  --                                 of the key exchange, which is the  worker
  --                                 on the local system.
  -- Outputs:     target_key       - public key of the target process. In this
  --                                 case "target" refers to the process with
  --                                 which the "source" end wishes to exchange
  --                                 keys, which is the worker on the remote
  --                                 system.
  --              digest           - digest/verifier of the shared key.
  --
  -- Possible Exceptions:
  --              Internal errors
  --++
  PROCEDURE dh_key_exchange(
        source_key      IN VARCHAR2,
        target_key      OUT VARCHAR2,
        digest          OUT VARCHAR2);

  --++
  -- Definition: This procedure sets the passphrase in a package state
  --             variable. Subsequent calls to get/put protected routines
  --             can pass the obfuscated passphrase to their respective
  --             C callouts as needed.
  --
  -- Inputs:     passphrase       - passphrase that is placed in a package
  --                                state variable and passed to the get/put
  --                                protected routines in subsequent calls.
  --             passphraseFmt    - passphrase is either in obfuscated or
  --                                encrypted format. Valid values are:
  --                                  - SYS.DBMS_TTS.OBFUSCATED
  --                                  - SYS.DBMS_TTS.ENCRYPTED
  --                                If the format is encrypted, this procedure
  --                                decrypts the passphrase and then obfuscates
  --                                it before placing into the package state
  --                                variable. The key used for decrypting
  --                                should have been setup via a previous
  --                                call to dh_key_exchange.
  --
  -- Possible Exceptions:
  --             Internal errors
  --++
  PROCEDURE set_passphrase(
        passphrase      IN RAW,
        passphraseFmt   IN PLS_INTEGER DEFAULT OBFUSCATED);

  --++
  -- Definition:  This procedure verifies that the tablespace list provided is
  --              a closed set.  Any violations will be stored in the
  --              sys.tts_error$ table.
  --
  -- Inputs:      ts_list          - comma separated tablespace name list
  --              incl_constraints - include constraints or not
  --              full_check       - perform a full check or not
  --
  -- Outputs:     None
  --++
  PROCEDURE transport_set_check(
        ts_list                 IN CLOB,
        incl_constraints        IN BOOLEAN DEFAULT FALSE,
        full_check              IN BOOLEAN DEFAULT FALSE);

  --++
  -- Definition:  This function verifies that the tablespace list provided is
  --              a closed set.  If called from within a datapump job then all
  --              violations will be in the sys.tts_error$ table and false will
  --              be returned. Otherwise, false will be returned on the first
  --              violation detected and no information is stored in the
  --              sys.tts_error$ table.
  --
  -- Inputs:      ts_list          - comma separated tablespace name list
  --              incl_constraints - include constraints or not
  --              full_check       - perform a full check or not
  --              job_type         = DATABASE_EXPORT IF FULL TTS
  --              encryption_password = true if encryption password supplied
  --                                    on command line.
  --
  -- Outputs:     None
  --
  -- Return:      True if self contained, false if not.
  --++
  FUNCTION isSelfContained(
        ts_list                 IN CLOB,
        incl_constraints        IN BOOLEAN,
        full_check              IN BOOLEAN,
        job_type                IN VARCHAR2 DEFAULT NULL,
        encryption_password     IN BOOLEAN DEFAULT FALSE)
    RETURN BOOLEAN;

  --
  -- Description:  This procedure checks if the transportable set is compatible
  --               with the specified char sets. Result is displayed in output.
  --               Must set serveroutput on.
  --
  -- Inputs:       ts_list      - comma separated tablespace name list
  --               target_db_char_set_name
  --               target_db_nchar_set_name
  --
  -- Outputs:      None
  --++
  PROCEDURE transport_char_set_check_msg(
        ts_list                         IN CLOB,
        target_db_char_set_name         IN VARCHAR2,
        target_db_nchar_set_name        IN VARCHAR2);

  --++
  -- Definition:  This function returns TRUE if char set is compatible. msg is
  --              set to OK or error message.
  --
  -- Inputs:       ts_list      - comma separated tablespace name list
  --               target_db_char_set_name
  --               target_db_nchar_set_name
  --
  -- Outputs:      None
  --
  -- Returns:      True if compatible, false otherwise
  --++
  FUNCTION transport_char_set_check(
        ts_list                         IN CLOB,
        target_db_char_set_name         IN VARCHAR2,
        target_db_nchar_set_name        IN VARCHAR2,
        err_msg                         OUT VARCHAR2)
    RETURN BOOLEAN;

  --
  -- Description:  This procedure adds an error to sys.tts_error$ if the error
  --               was not already previously added.
  --
  -- Inputs:       exp_err_num - expected error number
  --               err_num     - error number raised
  --               err_msg     - error text to insert
  --
  -- Outputs:      None
  --
  -- Return:       TRUE = expected error -- FALSE = error not expected
  --++
  FUNCTION insert_error(
        exp_err_num     IN NUMBER,
        err_num         IN NUMBER,
        err_msg         IN VARCHAR2)
    RETURN BOOLEAN;

  --++
  -- Procedure:    get_protected_ce_tab_key
  --
  -- Description:  This trusted callout provides an interface to get the 
  --               column encryption table keys in the protected form.
  --               The table key is extracted from the enc$, unwrapped with the
  --               Master Key, re-wrapped with the passphrase setup in a
  --               previous call to dbms_tts.set_passphrase.
  --               
  -- Inputs:       schemaname   - schema name
  --               tablename    - table name
  --
  -- Outputs:      protTableKey - protected table key
  --
  -- Note:         If not executed within dbms_datapump, it is a no-op.
  --
  --               If the procedure is executed successfully, the protected 
  --               table key is returned to the caller.
  --
  --               Errors are signaled otherwise.
  --++
  -- internal version is the trusted callout, not to be called directly
  -- by the user
  PROCEDURE  get_protected_ce_tab_key(
        schemaname      IN VARCHAR2,
        tablename       IN VARCHAR2,
        protTableKey    OUT RAW);

  --++
  -- Procedure:    add_protected_ce_tab_key
  --
  -- Description:  This trusted callout provides an interface to add the 
  --               column encryption table key to the TDE dictionary table.
  --               The table key is unwrapped with the passphrase setup in 
  --               a previous call to dbms_tts.set_passphrase, re-wrapped 
  --               with the Master Key and added to enc$.
  --               
  -- Inputs:       schemaname   - schema name
  --               tablename    - table name
  --               protTableKey - protected table key
  --
  -- Outputs:      None.
  --
  -- Note:         If not executed within dbms_datapump, it is a no-op.
  --
  --               If the procedure is executed successfully, the protected 
  --               table key is added to TDE dictionary table.
  --
  --               Errors are signaled otherwise.
  --++
  -- internal version is the trusted callout, not to be called directly
  -- by the user
  PROCEDURE  add_protected_ce_tab_key(
        schemaname      IN VARCHAR2,
        tablename       IN VARCHAR2,
        protTableKey    IN RAW);

  --++
  -- Procedure:    get_protected_tse_key
  --
  -- Description:  This trusted callout provides an interface to get the 
  --               tablespace encryption keys in the protected form. The
  --               TSE key is rewrapped using the passphrase setup in a 
  --               previous call to dbms_tts.set_passphrase.
  --               
  -- Inputs:       ts_num - tablespace number
  --
  -- Outputs:      protTablespaceKey - protected tablespace key
  --
  -- Note:         If not executed within dbms_datapump, it is a no-op.
  --
  --               If the procedure is executed successfully, the protected 
  --               tablespace key is returned to the caller.
  --
  --               Errors are signaled otherwise.
  --++
  -- internal version is the trusted callout, not to be called directly
  -- by the user
  PROCEDURE  get_protected_tse_key(
        ts_num                  IN NUMBER,      -- tablespace number
        protTablespaceKey       OUT RAW);       -- protected Tablespace Key

  --++
  -- Description:  This procedure provides an interface to rewrap tablespace
  --               key from a passphrase protected key to target DB wallet
  --               and write it to the file header
  --               Must operate on a datafile file before plugin
  --               Must be executed within the context of dbms_datapump.
  --               This procedure uses a passphrase setup in a previous
  --               call to dbms_tts.set_passphrase.
  --
  -- Inputs:       filename   - fully-qualified absolute path datafile name
  --               protTablespaceKey - protected tablespace key
  --
  -- Outputs:      None
  --               If the procedure executed successfully, the tablespace key
  --               in the file header has been rewrapped by the target DB 
  --               wallet and is ready to be plugged in.
  --
  --               Errors are signaled otherwise.
  --++
  PROCEDURE  put_protected_tse_key(
        filename                IN VARCHAR2,    -- data file name
        protTablespaceKey       IN RAW)         -- protected Tablespace Key
     ACCESSIBLE BY (PACKAGE sys.kupw$worker);

  --++
  -- Procedure:    get_afn_dbid
  --
  -- Description:  This trusted callout gets the absolute file number and the
  --               database id for a given file
  --               
  -- Inputs:       datafile file name
  --
  -- Outputs:      absolute file number
  --               database id
  --
  -- Note:         If not executed within dbms_datapump, it is a no-op.
  --
  --               Errors are signaled otherwise.
  --++
  PROCEDURE  get_afn_dbid(
        filename        IN VARCHAR2,
        afn             OUT NUMBER,                     -- absolute file number
        dbid            OUT NUMBER)                     -- database id
     ACCESSIBLE BY (PACKAGE sys.kupw$worker);

  --++
  -- Procedure:    get_afn_dbidxendian
  --
  -- Description:  This trusted callout gets the absolute file number and the
  --               database id for a given file x-plat
  --               
  -- Inputs:       datafile file name
  --
  -- Outputs:      absolute file number
  --               database id
  --
  -- Note:         If not executed within dbms_datapump, it is a no-op.
  --
  --               Errors are signaled otherwise.
  --++
  PROCEDURE  get_afn_dbidxendian(
        filename        IN VARCHAR2,
        afn             OUT NUMBER,                     -- absolute file number
        dbid            OUT NUMBER)                     -- database id
     ACCESSIBLE BY (PACKAGE sys.kupw$worker);

  --++
  -- Description:  NULL
  --
  -- Inputs:       None
  --
  -- Outputs:      None
  --++
  PROCEDURE downgrade;

  --++
  -- Definition:  This function queries the pl/sql table and pipelines it to
  --              look like a sql table.
  --
  -- Inputs:      None
  --
  -- Outputs:     None
  --++
  FUNCTION tab_func_error
    RETURN sys.tts_error_tab_t pipelined;

--++
-- Procedure:    Convert Encrypted Datafile Copy
--
-- Description:  This procedure will convert an encrypted datafile from
--               different endian values and then re-encrypt.
--
-- Inputs:       data file name
--               output directory
--               tablespace name
--               absolute file number
--               file db id
--               foreign dbname,
--               platform source name
--               platform target name
--               change endian
--               datafile encrypted
--               rewrapped key
--
-- Outputs:      new data file
--
-- Note:         If not executed within dbms_datapump, it is a no-op.
--
--               Errors are signaled otherwise.
--++
procedure ConvertEncryptedDataFileCopy(
        fname          IN VARCHAR2,
        outputdir      IN VARCHAR2,
        l_afn          IN BINARY_INTEGER,
        l_file_dbid    IN BINARY_INTEGER,
        endian_change  IN  BOOLEAN,
        encrypted      IN BOOLEAN,
        rewrapped_key  IN RAW,
        outfile        OUT VARCHAR2)
   ACCESSIBLE BY (PACKAGE sys.kupw$worker);

END dbms_tts;
/
GRANT EXECUTE ON dbms_tts TO execute_catalog_role
/

/*****************************************************************************/
 -- The following package contains procedures and packages supporting
 -- additional checks for the transportable tablespace feature. It adds support
 -- to capture any objects that would prevent the transportable feature to be
 -- used because of dependencies between objects in the transportable set and
 -- those not contained in the transportable set
 --
 --  Note that these are in addition to the ones that are captured by the
 --  dbms_tts.straddling_ts_objects
 --
 -- If a new feature is introduced, developers should write a new function to
 -- build a tablespace list associated with any object that is part of the
 -- feature and ensure its self containment by using the function
 -- dbms_extended_tts_checks.objectlist_Contained
 --
 --  ********************************************************************
 --  * The following shows example usage:                               *
 --  *                                                                  *
 --  * New Feature --> Extensible Index                                 *
 --  *                                                                  *
 --  * New Function                                                     *
 --  * Function dbms_extended_tts_checks.verify_Exensible               *
 --  *                                                                  *
 --  *   The above function ensures that all objects associated with    *
 --  *   extensible index are self contained. It                        *
 --  *     - Identifies objects of type Extensible indexes (o1,o2..oN)  *
 --  *     - Gets a list of dependent objects for each object oI        *
 --  *     - Generates a dependent tablespace list for that object      *
 --  *     - Ensures that the dependent list is either fully contained  *
 --  *       or fully outside the list of tablespaces to be transported *
 --  *       using dbms_extended_tts_checks.objectlist_Contained        *
 --  *                                                                  *
 --  * The above function should then be invoked from the function      *
 --  * dbms_tts.straddling_ts_objects                                   *
 --  ********************************************************************
 --
 -- Current functions that identify tablespaces containing a base object
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_tab
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_ind
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_tabpart
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_indpart
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_tabsubpart
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_indsubpart
 --
 -- For any new objects that take up storage, a function that identifies the
 -- storage tablespace must be added
 --
 /****************************************************************************/
CREATE OR REPLACE PACKAGE SYS.DBMS_EXTENDED_TTS_CHECKS IS

  --++
  -- Definition:  This function verifies Schema based XMLType tables that are
  --              part of the transport set are self contained. i.e. the out of
  --              line pieces that the table points to are also part of the
  --              transport set. This will ensure that the SB XMLType table is
  --              self contained.
  --
  -- Inputs:      tsnames - plsql table of tablespace names
  --              fromexp - stop after first violation found
  --
  -- Outputs:     None
  --
  -- Returns:     If fromExp is true, return false if violation found, true
  --              for all other cases(even if violations have been found).
  --++
  FUNCTION verify_XMLSchema(
        tsnames         IN dbms_tts.ts_names_tab_t,
        fromExp         IN BOOLEAN)
    RETURN BOOLEAN;

  --++
  -- Function      check_csx_closure
  --
  -- Description:  Verifies that all token manager tables for XML tables and
  --               columns with binary storage (CSX) are also contained in the
  --               transported tablespaces. This is needed so that data at the
  --               import site can be decoded without a full remapping.
  --
  --               To be combined with verify_XMLSchema. 
  --
  -- Inputs:       tsnames  - comma separated list of tablespace names
  --               fromExp  - being called by export?
  --
  -- Outputs:      None
  --
  -- Results       True if contained, otherwise false.
  --               As for verify_XMLSchema, even if violation is found, returns
  --               true if from Exp is false.
  --++
  FUNCTION check_csx_closure(
        tsnames         IN dbms_tts.ts_names_tab_t,
        fromExp         IN BOOLEAN )
    RETURN BOOLEAN;

  --++
  -- Definition:  This function verifies secondary objects that are associated
  --              with an extensible index are contained in the list of
  --              tablespaces or fully outside the list. This guarantees self
  --              containment of all or none of the secondary objects
  --              associated with the extensible index. For simple types like
  --              tables and indexes it is clear why this check works. What may
  --              not be so obvious is that this works even for objects like
  --              partitions, lobs etc.  For e.g. if Table T1 is partitioned
  --              two ways P1 and P2, has a lob object L1 and Table T2 is an
  --              IOT, and extensible index E1 is associated with L1 and T2
  --              then it is sufficient just check that tablespace(L1) and
  --              tablespace(T2) are either fully contained or fully out of
  --              the tts set. Self Containment of T1 and T2 is guaranteed by
  --              the straddling_rs_objects function
  --
  -- Inputs:      fromexp - stop after first violation found
  --
  -- Outputs:     None
  --
  -- Returns:     If fromExp is true, return false if violation found, true
  --              for all other cases (even if violations have been found).
  --++
  FUNCTION verify_Extensible(
        fromExp IN BOOLEAN)
    RETURN BOOLEAN;

  --++
  -- Definition :  This function verifies that:
  --               1. Materialized view logs stored as tables and the
  --                  corresponding master tables are self contained. The
  --                  containment check is similar to tables and its indexes:
  --                  If full_check is TRUE, then BOTH the MV log and the
  --                  master table must be in or both must be out of the
  --                  transportable set. If full_check is FALSE, then it is ok
  --                  for the MV log to be out of the transportable set but it
  --                  is NOT ok for the MV log to be in and its master table to
  --                  be out of the set.
  --               2. Updateable Materialized view tables and their
  --                  corresponding logs are fully contained in the
  --                  transportable set.
  --
  --               If fromExp is false, populate the violation table with the
  --               offending violation object information for each violation.
  --
  --               Note that it is ok to transport just the MVs and not their
  --               masters or vice versa. It is also ok to just transport
  --               master tables without the mv logs, but NOT vice versa.
  --
  -- Inputs:      fromexp    - stop after first violation found
  --              full_check - perform full check - described above
  --
  -- Outputs:     None
  --
  -- Returns:     If fromExp is true, return false if violation found, true
  --              for all other cases (even if violations have been found).
  --++
  FUNCTION verify_MV(
        fromExp         IN BOOLEAN,
        full_check      IN BOOLEAN) 
    RETURN BOOLEAN;

  --++
  -- Definition:  This function verifies that all nested tables are fully in or
  --              out of the tts set.
  --
  -- Inputs:      fromexp    - stop after first violation found
  --
  -- Outputs:     None
  --
  -- Returns:     If fromExp is true, return false if violation found, true
  --              for all other cases (even if violations have been found).
  --++
  FUNCTION verify_NT(
        fromExp IN BOOLEAN)
    RETURN BOOLEAN;

  --
  -- The following get_tablespace_* functions take information about an object
  -- that takes up physical storage in the database and returns the tablespace
  -- name associated with the object.
  --

  --++
  -- Definition:  This function checks if table is non partitioned and not an
  --              IOT then return its tablespace.  If the TABLE is an IOT or
  --              partitioned then just return the tablespace associated with
  --              the index or the first partition respectively. If a specific
  --              tablespace is needed then the get_tablespace_tabpart routine
  --              should be invoked by the caller.
  --
  -- Inputs:      objnum      - obj# of object to check
  --              schemaname  - owner of object
  --              objname     - object name
  --              subname     - object subname (partition or subpartition)
  --              objtype     - object type
  --
  -- Outputs:     None
  --
  -- Returns:     Tablespace name
  --++
  FUNCTION get_tablespace_tab(
        objnum          IN NUMBER,
        schemaname      IN VARCHAR2,
        objname         IN VARCHAR2,
        subname         IN VARCHAR2,
        objtype         IN VARCHAR2)
    RETURN VARCHAR2;

END DBMS_EXTENDED_TTS_CHECKS;
/

/***************************************************************************
 -- NAME
 --   dbms_tdb - Transportable DataBase
 -- DESCRIPTION
 --  This package is used to check if a database if ready to be transported.
 **************************************************************************/
CREATE OR REPLACE PACKAGE SYS.DBMS_TDB IS
  --++
  -- Description:  This function checks if a database is ready to be
  --               transported to a target platform. If the database is not
  --               ready to be transported and serveroutput is on, a detailed
  --               description of the reason why the database cannot be
  --               transported and possible ways to fix the problem will be
  --               displayed
  --
  -- Inputs:       target_platform - name of the target platform
  --
  -- Outputs:      None
  --
  -- Returns:      TRUE if the datababase is ready to be transported.
  --               FALSE otherwise.
  --++
  skip_none             CONSTANT NUMBER := 0;
  skip_inaccessible     CONSTANT NUMBER := 1;
  skip_offline          CONSTANT NUMBER := 2;
  skip_readonly         CONSTANT NUMBER := 3;

  FUNCTION check_db(
        target_platform_name    IN VARCHAR2,
        skip_option             IN NUMBER)
    RETURN BOOLEAN;

  FUNCTION check_db(
        target_platform_name    IN VARCHAR2)
    RETURN BOOLEAN;

  FUNCTION check_db
    RETURN BOOLEAN;

  --++
  -- Description:  This function checks if a database has external tables,
  --               directories or BFILEs. It will use dbms_output.put_line to
  --               output the external objects and their owners.
  --
  -- Inputs:       None
  --
  -- Outputs:      None
  --
  -- Returns:      TRUE if the datababase has external tables, directories or
  --               BFILEs. FALSE otherwise.
  --++
  FUNCTION check_external
    RETURN BOOLEAN;

  --++
  -- Description:  This procedure is used in transport script to throw a SQL
  --               error so that the transport script can exit.
  --
  -- Inputs:       should_exit - whether to exit from transport script
  --
  -- Outputs:      None
  --
  -- EXCEPTIONS:   ORA-9330
  --++
  PROCEDURE exit_transport_script(
        should_exit     IN VARCHAR2);
END;
/
GRANT EXECUTE ON SYS.DBMS_TDB TO dba;

Rem ===========================================================================
Rem                                                                           #
Rem     VIEW NAME       TRANSPORT_SET_VIOLATIONS                              #
Rem                                                                           #
Rem ===========================================================================

CREATE OR REPLACE VIEW transport_set_violations (violations) AS
SELECT violations FROM TABLE(sys.dbms_tts.tab_func_error());

GRANT SELECT ON transport_set_violations TO SELECT_CATALOG_ROLE;

@?/rdbms/admin/sqlsessend.sql
