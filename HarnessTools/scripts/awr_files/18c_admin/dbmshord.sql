Rem Copyright (c) 2000, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmshord.sql - Online ReDefintion of Tables
Rem
Rem    DESCRIPTION
Rem      This files contains dbms_redefinition package which allows for an 
Rem      out-of-place, online redefintion of tables
Rem
Rem    NOTES
Rem      
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmshord.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmshord.sql
Rem SQL_PHASE: DBMSHORD
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tfyu        06/25/15 - 21318629
Rem    prakumar    04/01/15 - Bug 20818379: Add dml_lock_timeout parameter to
Rem                           ROLLBACK api
Rem    minwei      03/20/15 - Bug#20714189: fix incorrect parameter order in
Rem                           start_redef_table
Rem    prakumar    11/20/14 - Proj39358: add rollback()/abort_rollback()
Rem    yanxie      10/21/14 - bug 19662642
Rem    yanxie      08/08/14 - Proj39358: add cons_no_dmllock
Rem    prakumar    06/22/14 - Proj39358: Add execute_update/abort_update
Rem    tfyu        01/31/14 - 12.2 (39358): refresh dependent MVs
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    rrudd       02/29/12 - add continue_after_errors to start_redef_table
Rem                           and sync_interim_table
Rem    tfyu        10/05/11 - 12g redef_table new procedure
Rem    rrudd       08/17/11 - Bug 12879651 Adding support for
Rem                           continue_after_errors
Rem    minwei      04/18/11 - Add parameter to start_redef_table
Rem    tfyu        02/08/11 - 12g finish_redef_table support timeout
Rem    prakumar    10/29/09 - Bug 6321275: Support of redef apis in USER mode
Rem    ajadams     12/03/08 - make procedures DDL like for replication
Rem    svivian     08/15/08 - add pragmas to dbms_redefinition
Rem    wesmith     04/12/06 - support online redefintion of tables with MV logs
Rem    xan         05/06/04 - modify copy_table_dependents 
Rem    masubram    05/04/04 - support redefinition of a partition 
Rem    masubram    10/01/02 - add clone_dependent_objects
Rem    masubram    09/29/02 - order by clause for online redef complete ref
Rem    masubram    09/24/02 - add register_dependent_object
Rem    masubram    01/25/02 - add constant keyword
Rem    masubram    01/11/02 - add paramater to can_redef_table
Rem    masubram    11/14/01 - add parameter to start_redef_table
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    masubram    05/15/00 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


CREATE OR REPLACE PACKAGE dbms_redefinition AUTHID CURRENT_USER IS
  ------------
  --  OVERVIEW
  --
  -- This package provides the API to perform an online, out-of-place
  -- redefinition of a table

  --- =========
  --- CONSTANTS
  --- =========
  -- Constants for the options_flag parameter of start_redef_table
  cons_use_pk    CONSTANT PLS_INTEGER := 1;
  cons_use_rowid CONSTANT PLS_INTEGER := 2;

  -- Constants for the copy_vpd_opt parameter of start_redef_table
  cons_vpd_none    CONSTANT PLS_INTEGER := 1;
  cons_vpd_auto    CONSTANT PLS_INTEGER := 2;
  cons_vpd_manual  CONSTANT PLS_INTEGER := 4;

  -- Constants used for the object types in the register_dependent_object
  cons_index      CONSTANT PLS_INTEGER := 2;
  cons_constraint CONSTANT PLS_INTEGER := 3;
  cons_trigger    CONSTANT PLS_INTEGER := 4;
  cons_mvlog      CONSTANT PLS_INTEGER := 10;

  -- constants used to specify the method of copying indexes
  cons_orig_params CONSTANT PLS_INTEGER := 1;

  -- constants for ROLLBACK
  cons_no_rollback     CONSTANT PLS_INTEGER := 1;
  cons_online_rollback CONSTANT PLS_INTEGER := 2;
  
  -- constants used to specify lock free in finish_redef_table
  -- this constant is used by the parameter 'dml_time_lockout'
  cons_no_dmllock  CONSTANT PLS_INTEGER := -1;

  PRAGMA SUPPLEMENTAL_LOG_DATA(default, AUTO_WITH_COMMIT);

  -- NAME:     can_redef_table - check if given table can be re-defined
  -- INPUTS:   uname        - table owner name
  --           tname        - table name
  --           options_flag - flag indicating user options to use
  --           part_name    - partition name
  PROCEDURE can_redef_table(uname        IN VARCHAR2,
                            tname        IN VARCHAR2,
                            options_flag IN PLS_INTEGER := 1,
                            part_name    IN VARCHAR2 := NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(can_redef_table, NONE);

  -- NAME:     redef_table - push-button api for the table online 
  --                         re-organization
  -- INPUTS:   uname        - schema name
  --           tname        - name of table to be re-organized
  --        (1)table_compression_type - text of the table compression clause 
  --        (2)table_part_tablespace - tablespace name for the entire table
  --                                   or partitions 
  --        (3)index_key_compression_type - text string of the compression 
  --                                     clause for all indexes on the table 
  --        (4)index_tablespace - tablespace name for all indexes on the table
  --        (5)lob_compression_type - text string of the compression clause 
  --                                  for all lobs in the entire table 
  --        (6)lob_tablespace - the tablespace name for all lobs in the table
  --        (7)lob_store_as - specify lob store as 'SECUREFILE' or 'BASICFILE' 
  --        (8)refresh_dep_mviews - refresh qualified dependent MVs? 'Y' or 'N'
  --        (9)dml_lock_timeout - max # of seconds waiting for dml lock
  PROCEDURE redef_table(uname                      IN VARCHAR2,
                        tname                      IN VARCHAR2,
                        table_compression_type     IN VARCHAR2 := NULL,
                        table_part_tablespace      IN VARCHAR2 := NULL,
                        index_key_compression_type IN VARCHAR2 := NULL,
                        index_tablespace           IN VARCHAR2 := NULL,
                        lob_compression_type       IN VARCHAR2 := NULL,
                        lob_tablespace             IN VARCHAR2 := NULL,
                        lob_store_as               IN VARCHAR2 := NULL,
                        refresh_dep_mviews         IN VARCHAR2 := 'N',
                        dml_lock_timeout           IN PLS_INTEGER := NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(redef_table, NONE);

  -- NAME:     set_param - set a parameter with a given value used
  --                       in redefinition
  -- INPUTS:   REDEFINITION_ID - redefinition id
  --           PARAM_NAME      - parameter name
  --           PARAM_VALUE     - parameter value
  PROCEDURE set_param (REDEFINITION_ID          IN VARCHAR2,
                       PARAM_NAME               IN VARCHAR2,
                       PARAM_VALUE              IN VARCHAR2);

  -- NAME:     start_redef_table - start the online re-organization
  -- INPUTS:   uname        - schema name 
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           col_mapping  - select list col mapping
  --           options_flag - flag indicating user options to use
  --           orderby_cols - comma separated list of order by columns
  --                          followed by the optional ascending/descending 
  --                          keyword
  --           part_name    - name of the partition to be redefined
  --           continue_after_errors - Continue redefining after errors? 
  --           copy_vpd_opt    - copy VPD policy option 
  --           refresh_dep_mviews - refresh qualified dependent MVs? 'Y' or 'N'
  --           enable_rollback - Can rollback the changes after 
  --                             finish_redef_table
  PROCEDURE start_redef_table(uname        IN VARCHAR2,
                              orig_table   IN VARCHAR2,
                              int_table    IN VARCHAR2,
                              col_mapping  IN VARCHAR2 := NULL,
                              options_flag IN BINARY_INTEGER := 1,
                              orderby_cols IN VARCHAR2 := NULL,
                              part_name    IN VARCHAR2 := NULL,
                              continue_after_errors  IN BOOLEAN := FALSE,
                              copy_vpd_opt IN BINARY_INTEGER := 1,
                              refresh_dep_mviews     IN VARCHAR2 := 'N',
                              enable_rollback IN BOOLEAN := FALSE);

  -- NAME:     finish_redef_table - complete the online re-organization
  -- INPUTS:   uname        - schema name 
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           part_name    - name of the partition being redefined
  --           dml_lock_timeout - max # of seconds waiting for dml lock
  --           continue_after_errors - Continue redefining after errors? 
  --           disable_rollback  - Disable rollback ? (Default FALSE)
  PROCEDURE finish_redef_table(uname          IN VARCHAR2,
                               orig_table     IN VARCHAR2,
                               int_table      IN VARCHAR2,
                               part_name      IN VARCHAR2 := NULL,
                               dml_lock_timeout IN PLS_INTEGER := NULL,
                               continue_after_errors  IN BOOLEAN := FALSE,
                               disable_rollback IN BOOLEAN := FALSE);

  -- NAME:     abort_redef_table - clean up after errors or abort the 
  --                               online re-organization
  -- INPUTS:   uname        - schema name 
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           part_name    - name of the partition being redefined
  PROCEDURE abort_redef_table(uname        IN VARCHAR2,
                              orig_table   IN VARCHAR2,
                              int_table    IN VARCHAR2,
                              part_name    IN VARCHAR2 := NULL);

  -- NAME:     sync_interim_table - synchronize interim table with the original
  --                                table
  -- INPUTS:   uname        - schema name 
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           part_name    - name of the partition being redefined
  --           continue_after_errors - Continue redefining after errors? 
  PROCEDURE sync_interim_table(uname       IN VARCHAR2,
                               orig_table  IN VARCHAR2,
                               int_table   IN VARCHAR2,
                               part_name   IN VARCHAR2 := NULL,
                               continue_after_errors  IN BOOLEAN := FALSE);

  -- NAME:     register_dependent_object - register dependent object
  --
  -- INPUTS:   uname        - schema name 
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           dep_type     - type of the dependent object
  --           dep_owner    - name of the dependent object owner
  --           dep_orig_name- name of the dependent object defined on table
  --                          being re-organized
  --           dep_int_name - name of the corressponding dependent object on
  --                          the interim table
  PROCEDURE register_dependent_object(uname         IN VARCHAR2,
                                      orig_table    IN VARCHAR2,
                                      int_table     IN VARCHAR2,
                                      dep_type      IN PLS_INTEGER,
                                      dep_owner     IN VARCHAR2,
                                      dep_orig_name IN VARCHAR2,
                                      dep_int_name  IN VARCHAR2);

  -- NAME:     unregister_dependent_object - unregister dependent object
  --
  -- INPUTS:   uname        - schema name 
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           dep_type     - type of the dependent object
  --           dep_owner    - name of the dependent object owner
  --           dep_orig_name- name of the dependent object defined on table
  --                          being re-organized
  --           dep_int_name - name of the corressponding dependent object on
  --                          the interim table
  PROCEDURE unregister_dependent_object(uname         IN VARCHAR2,
                                        orig_table    IN VARCHAR2,
                                        int_table     IN VARCHAR2,
                                        dep_type      IN PLS_INTEGER,
                                        dep_owner     IN VARCHAR2,
                                        dep_orig_name IN VARCHAR2,
                                        dep_int_name  IN VARCHAR2);

  --  NAME:     copy_table_dependents
  --
  --  INPUTS:  uname             - schema name 
  --           orig_table        - name of table to be re-organized
  --           int_table         - name of interim table
  --           copy_indexes      - integer value indicating whether to 
  --                               copy indexes
  --                               0 - don't copy
  --                               1 - copy using storage params/tablespace
  --                                   of original index
  --           copy_triggers      - TRUE implies copy triggers, FALSE otherwise
  --           copy_constraints   - TRUE implies copy constraints, FALSE
  --                                otherwise
  --           copy_privileges    - TRUE implies copy privileges, FALSE 
  --                                otherwise
  --           ignore errors      - TRUE implies continue after errors, FALSE
  --                                otherwise
  --           num_errors         - number of errors that occurred while 
  --                                cloning ddl
  --           copy_statistics    - TRUE implies copy table statistics, FALSE
  --                                otherwise.
  --                                If copy_indexes is 1, copy index
  --                                related statistics, 0 otherwise.
  --           copy_mvlog         - TRUE implies copy table's MV log, FALSE
  --                                otherwise.
  PROCEDURE copy_table_dependents(uname              IN  VARCHAR2,
                                  orig_table         IN  VARCHAR2,
                                  int_table          IN  VARCHAR2,
                                  copy_indexes       IN  PLS_INTEGER := 1,
                                  copy_triggers      IN  BOOLEAN := TRUE,
                                  copy_constraints   IN  BOOLEAN := TRUE,
                                  copy_privileges    IN  BOOLEAN := TRUE,
                                  ignore_errors      IN  BOOLEAN := FALSE,
                                  num_errors         OUT PLS_INTEGER,
                                  copy_statistics    IN  BOOLEAN := FALSE,
                                  copy_mvlog         IN  BOOLEAN := FALSE);

  --  NAME:    execute_update - Executes an UPDATE statement
  --
  --  INPUTS:  update_stmt       - update statement
  --
  --  OUTPUTS: none
  --
  --  NOTES:   UPDATE stmt run using execute_update will take up lesser
  --           REDO than the conventional method.
  --           Should be used only when >80% of the rows in the table
  --           will be affected by UPDATE
  --         
  PROCEDURE execute_update(update_stmt IN CLOB);
  PRAGMA SUPPLEMENTAL_LOG_DATA(execute_update, UNSUPPORTED);

  -- NAME:   abort_update - Cleansup any residual objects 
  --
  -- INPUT:  update_stmt - update statement
  --
  -- OUTPUT: none
  --
  -- NOTES:  Mainly used when execute_update fails with error/crash.
  --         This will cleanup any objects created during execute_update
  --        
  PROCEDURE abort_update(update_stmt IN CLOB);
  PRAGMA SUPPLEMENTAL_LOG_DATA(abort_update, UNSUPPORTED);

  -- Usage of ROLLBACK()/ABORT_ROLLBACK() api
  --
  --   start_redef_table(enable_rollback=>TRUE)
  --               V
  --   copy_table_dependents/sync_interim_table/register_table_dependents
  --               V
  --   finish_table_redef()
  --               V
  --   Optional, sync_interim_table can be run to keep pulling changes
  --   from the new original table to interim table
  --               V
  --   Satisfied with the online redef changes ?
  --               |
  --              / \
  --            NO   YES
  --           /       \
  --     rollback    abort_rollback

  -- NAME: rollback - ROLLBACK the changes made during online re-organization
  --
  -- INPUTS: uname        - schema name
  --         orig_table   - name of table to be re-organized
  --         int_table    - name of interim table
  --         part_name    - name of the partition being redefined
  -- 
  -- OUTPUT: none
  --
  -- NOTE: Can be run only after finish_redef_table
  --       Use the same set of parameters used in finish_redef_table
  --
  PROCEDURE rollback(uname          IN VARCHAR2,
                     orig_table     IN VARCHAR2,
                     int_table      IN VARCHAR2 := NULL,
                     part_name      IN VARCHAR2 := NULL,
                     dml_lock_timeout IN PLS_INTEGER := NULL,
                     continue_after_errors  IN BOOLEAN := FALSE);

  -- NAME: abort_rollback - Abort the intention to ROLLBACK the changes made
  --                        during online re-organization
  --
  -- INPUTS:   uname        - schema name
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           part_name    - name of the partition being redefined
  -- 
  -- OUTPUT: none
  --
  -- NOTE: Can be run only after finish_redef_table
  --       Use the same set of parameters used in abort_redef_table
  --
  PROCEDURE abort_rollback(uname          IN VARCHAR2,
                           orig_table     IN VARCHAR2,
                           int_table      IN VARCHAR2 := NULL,
                           part_name      IN VARCHAR2 := NULL);

END;
/
SHOW ERRORS;

GRANT EXECUTE ON dbms_redefinition TO execute_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_redefinition FOR dbms_redefinition
/

@?/rdbms/admin/sqlsessend.sql
