Rem
Rem $Header: rdbms/admin/dbmsxstr.sql /main/34 2017/09/06 15:27:43 jorgrive Exp $
Rem
Rem dbmsxstr.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxstr.sql - DBMS XStream Package
Rem
Rem    DESCRIPTION
Rem      This package contains the higher level APIs for creating
Rem      XStream outbound and inbound servers.
Rem
Rem    NOTES
Rem      Requires AQ and dbms_streams* related packages to have been 
Rem      previously installed.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxstr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxstr.sql
Rem SQL_PHASE: DBMSXSTR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dbmsstr.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jorgrive    08-03-17 - Bug 26370255
Rem    thoang      06/03/16 - Fix bug 23525819
Rem    lzheng      02/09/15 - remove dbms_goldengate_auth from this file. Moved
Rem                           it to dbmsgg.sql
Rem    jorgrive    08/30/14 - Add dbms_xstream_adm.delete_replication_events
Rem    romorale    04/10/14 - BigSCN. 
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    tianli      07/28/13 - bug 12816679 fix remove_*_configuration
Rem    aayalaa     03/20/13 - Bug 16355441. Changing default value
Rem                           in the parameter grant_select_privileges
Rem                           to true in dbms_goldengate_auth.grant_admin_privilege
Rem    tianli      09/13/12 - fix bug 14625788: rename source_pdb_name to
Rem                           source_container_name
Rem    tianli      08/16/12 - fix cdb dbname mapping
Rem    huntran     08/01/12 - reset position
Rem    surman      04/12/12 - 13615447: Add SQL patching tags
Rem    tianli      12/09/11 - rename container to source_database in set_param
Rem    thoang      09/20/11 - add include_dml/ddl parms to create/add_outbound
Rem    tianli      08/20/11 - add container to remove_xstream_configuration
Rem    tianli      06/20/11 - add start/stop outbound to xstream_adm
Rem    tianli      05/23/11 - add dbms_streams_adm procedures to xstream and gg adm
Rem    tianli      05/19/11 - change src_root_name to source_root_name
Rem    tianli      05/12/11 - add create_capture for dbms_xstream_adm
Rem    yurxu       04/12/11 - Add check to only allow alter_outbound change
Rem                           apply_user in 2-level privilege model
Rem    elu         04/20/11 - modify grant_admin_privileges
Rem    tianli      03/30/11 - support PDB in xstream
Rem    yurxu       03/18/11 - Bug-11922716: 2-level privilege model
Rem    huntran     02/28/11 - reset configuration constants
Rem    yurxu       03/05/10 - Bug-9469148: rename to dbms_goldengate_auth.
Rem                           grant_admin_privilege
Rem    thoang      03/05/10 - allow null qname in add_outbound
Rem    yurxu       01/12/10 - add dbms_xstream_auth.grant_privileges
Rem    juyuan      01/13/10 - remove wait_for_inflight_txns parameter
Rem    juyuan      12/23/09 - dbms_xstream_auth.grant_privileges
Rem    thoang      12/03/09 - move committed_data_only to dbms_xstream_gg
Rem    yurxu       11/10/09 - change start_scn_time to start_time
Rem    juyuan      10/31/09 - enable_gg_xstream_for_streams
Rem    thoang      10/04/09 - Add uncommitted_data argument
Rem    juyuan      10/26/09 - enable_xstream_for_streams
Rem    praghuna    10/09/09 - Added start_scn, start_scn_time-alter_outbound
Rem    thoang      11/20/08 - Change column_table to column_list
Rem    rihuang     10/28/08 - Change signature for add_subset_outbound_rules
Rem    thoang      03/15/08 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

----------------------------------------------------------------------
-- XStream Admin API 
----------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_xstream_adm AUTHID CURRENT_USER AS 
  -- constants for resetting configuration
  RESET_PARAMETERS       CONSTANT BINARY_INTEGER := 1;
  RESET_HANDLERS         CONSTANT BINARY_INTEGER := 2;
  RESET_PROGRESS         CONSTANT BINARY_INTEGER := 4;
  RESET_ALL              CONSTANT BINARY_INTEGER := 2147483647;

  -- The following constants are used by set_message_tracing
  action_trace                    CONSTANT BINARY_INTEGER := 1;
  action_memory                   CONSTANT BINARY_INTEGER := 2;

  -- Procedure create_outbound creates an outbound server, necessary queue 
  -- and associated capture to allow clients to stream out LCRs from the
  -- specified source database.   
  --
  -- If no table or schema specified then the outbound server will stream
  -- all DDL and DML changes.
  --
  -- If capture_name is not specified then a capture is created using a
  -- system-generated name. If capture_name is specified and existed then 
  -- that capture is used; otherwise, a new capture is created using the 
  -- given name.
  PROCEDURE create_outbound(
    server_name             IN VARCHAR2,
    source_database         IN VARCHAR2 DEFAULT NULL,
    table_names             IN VARCHAR2 DEFAULT NULL,
    schema_names            IN VARCHAR2 DEFAULT NULL,
    capture_user            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    capture_name            IN VARCHAR2 DEFAULT NULL,
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT TRUE,
    source_root_name        IN VARCHAR2 DEFAULT NULL,
    source_container_name   IN VARCHAR2 DEFAULT NULL,
    lcrid_version           IN NUMBER DEFAULT NULL);

  PROCEDURE create_outbound(
    server_name             IN VARCHAR2,
    source_database         IN VARCHAR2 DEFAULT NULL,
    table_names             IN DBMS_UTILITY.UNCL_ARRAY,
    schema_names            IN DBMS_UTILITY.UNCL_ARRAY,
    capture_user            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    capture_name            IN VARCHAR2 DEFAULT NULL,
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT TRUE,
    source_root_name        IN VARCHAR2 DEFAULT NULL,
    source_container_name   IN VARCHAR2 DEFAULT NULL,
    lcrid_version           IN NUMBER DEFAULT NULL);

/*  NOT SUPPORTING OUT PARAMETERS FOR NOW
  
  PROCEDURE create_outbound(
    server_name             IN VARCHAR2,
    source_database         IN VARCHAR2 DEFAULT NULL,
    table_names             IN DBMS_UTILITY.UNCL_ARRAY,
    schema_names            IN DBMS_UTILITY.UNCL_ARRAY,
    capture_user            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    ddl_table_rule_names    OUT DBMS_UTILITY.UNCL_ARRAY,
    dml_table_rule_names    OUT DBMS_UTILITY.UNCL_ARRAY,
    ddl_schema_rule_names   OUT DBMS_UTILITY.UNCL_ARRAY,  
    dml_schema_rule_names   OUT DBMS_UTILITY.UNCL_ARRAY); 

  PROCEDURE create_outbound(
    server_name             IN VARCHAR2,
    source_database         IN VARCHAR2 DEFAULT NULL,
    table_names             IN VARCHAR2 DEFAULT NULL,
    schema_names            IN VARCHAR2 DEFAULT NULL,
    capture_user            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL, 
    ddl_table_rule_names    OUT VARCHAR2,
    dml_table_rule_names    OUT VARCHAR2,
    ddl_schema_rule_names   OUT VARCHAR2,
    dml_schema_rule_names   OUT VARCHAR2);  

*/

  PROCEDURE alter_outbound(
    server_name             IN VARCHAR2,
    table_names             IN DBMS_UTILITY.UNCL_ARRAY,
    schema_names            IN DBMS_UTILITY.UNCL_ARRAY,
    add                     IN BOOLEAN DEFAULT TRUE,
    capture_user            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    inclusion_rule          IN BOOLEAN  DEFAULT TRUE,  
    start_scn               IN NUMBER   DEFAULT NULL,
    start_time              IN TIMESTAMP DEFAULT NULL,
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT TRUE,
    source_database         IN VARCHAR2 DEFAULT NULL,
    source_container_name   IN VARCHAR2 DEFAULT NULL);

  PROCEDURE alter_outbound(
    server_name             IN VARCHAR2,
    table_names             IN VARCHAR2 DEFAULT NULL,
    schema_names            IN VARCHAR2 DEFAULT NULL,
    add                     IN BOOLEAN DEFAULT TRUE,
    capture_user            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    inclusion_rule          IN BOOLEAN  DEFAULT TRUE,  
    start_scn               IN NUMBER   DEFAULT NULL,
    start_time              IN TIMESTAMP DEFAULT NULL,
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT TRUE,
    source_database         IN VARCHAR2 DEFAULT NULL,
    source_container_name   IN VARCHAR2 DEFAULT NULL);

  -- Add an outbound server to an existing queue or capture.
  -- Either the queue name or capture name must be specified. If both are 
  -- specified then the capture must be local, and the queue name must match 
  -- the capture's queue.
  PROCEDURE add_outbound(
    server_name             IN VARCHAR2,
    queue_name              IN VARCHAR2 DEFAULT NULL,
    source_database         IN VARCHAR2 DEFAULT NULL,
    table_names             IN DBMS_UTILITY.UNCL_ARRAY,
    schema_names            IN DBMS_UTILITY.UNCL_ARRAY,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    capture_name            IN VARCHAR2 DEFAULT NULL,
    start_scn               IN NUMBER   DEFAULT NULL,
    start_time              IN TIMESTAMP DEFAULT NULL,
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT TRUE,
    source_root_name        IN VARCHAR2 DEFAULT NULL,
    source_container_name   IN VARCHAR2 DEFAULT NULL,
    lcrid_version           IN NUMBER DEFAULT NULL);

  PROCEDURE add_outbound(
    server_name             IN VARCHAR2,
    queue_name              IN VARCHAR2 DEFAULT NULL,
    source_database         IN VARCHAR2 DEFAULT NULL,
    table_names             IN VARCHAR2 DEFAULT NULL,
    schema_names            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    capture_name            IN VARCHAR2 DEFAULT NULL,
    start_scn               IN NUMBER   DEFAULT NULL,
    start_time              IN TIMESTAMP DEFAULT NULL,
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT TRUE,
    source_root_name        IN VARCHAR2 DEFAULT NULL,
    source_container_name   IN VARCHAR2 DEFAULT NULL,
    lcrid_version           IN NUMBER DEFAULT NULL);

  PROCEDURE drop_outbound(
    server_name             IN VARCHAR2);

  PROCEDURE add_subset_outbound_rules(
    server_name             IN VARCHAR2,
    table_name              IN VARCHAR2,
    condition               IN VARCHAR2 DEFAULT NULL,
    column_list             IN DBMS_UTILITY.LNAME_ARRAY,
    keep                    IN BOOLEAN  DEFAULT TRUE,
    source_database         IN VARCHAR2 DEFAULT NULL);

  PROCEDURE add_subset_outbound_rules(
    server_name             IN VARCHAR2,
    table_name              IN VARCHAR2,
    condition               IN VARCHAR2 DEFAULT NULL,
    column_list             IN VARCHAR2 DEFAULT NULL, 
    keep                    IN BOOLEAN  DEFAULT TRUE,
    source_database         IN VARCHAR2 DEFAULT NULL);

  -- Removes the specified subsetting rules from the given outbound server.
  -- The specified rules must have been created for the same subsetting 
  -- condition.
  PROCEDURE remove_subset_outbound_rules(
    server_name             IN VARCHAR2,
    insert_rule_name        IN VARCHAR2, 
    update_rule_name        IN VARCHAR2, 
    delete_rule_name        IN VARCHAR2);
 
  -- Create an inbound server using the specified queue. If the specified
  -- queue does not exist then this procedure will create one. 
  PROCEDURE create_inbound(
    server_name             IN VARCHAR2,
    queue_name              IN VARCHAR2,
    apply_user              IN VARCHAR2 DEFAULT NULL,  
    comment                 IN VARCHAR2 DEFAULT NULL);

  PROCEDURE alter_inbound(
    server_name             IN VARCHAR2,
    apply_user              IN VARCHAR2 DEFAULT NULL,  
    comment                 IN VARCHAR2 DEFAULT NULL);

  PROCEDURE drop_inbound(
    server_name             IN VARCHAR2);

  PROCEDURE enable_gg_xstream_for_streams(
    enable                  IN BOOLEAN DEFAULT TRUE);

  FUNCTION is_gg_xstream_for_streams RETURN BOOLEAN;

  PROCEDURE add_global_rules(
    streams_type       IN VARCHAR2,
    streams_name       IN VARCHAR2 DEFAULT NULL,
    queue_name         IN VARCHAR2 DEFAULT 'streams_queue',
    include_dml        IN BOOLEAN DEFAULT TRUE,
    include_ddl        IN BOOLEAN DEFAULT FALSE,
    include_tagged_lcr IN BOOLEAN DEFAULT TRUE,
    source_database    IN VARCHAR2 DEFAULT NULL,
    inclusion_rule     IN BOOLEAN DEFAULT TRUE,
    and_condition      IN VARCHAR2 DEFAULT NULL,
    source_root_name   IN VARCHAR2 DEFAULT NULL,
    source_container_name IN VARCHAR2 DEFAULT NULL);

  PROCEDURE add_global_rules(
    streams_type            IN  VARCHAR2,
    streams_name            IN  VARCHAR2 DEFAULT NULL,
    queue_name              IN  VARCHAR2 DEFAULT 'streams_queue',
    include_dml             IN  BOOLEAN DEFAULT TRUE,
    include_ddl             IN  BOOLEAN DEFAULT FALSE,
    include_tagged_lcr      IN  BOOLEAN DEFAULT TRUE,
    source_database         IN  VARCHAR2 DEFAULT NULL,
    dml_rule_name           OUT VARCHAR2,
    ddl_rule_name           OUT VARCHAR2,
    inclusion_rule          IN  BOOLEAN DEFAULT TRUE,
    and_condition           IN VARCHAR2 DEFAULT NULL,
    source_root_name        IN VARCHAR2 DEFAULT NULL,
    source_container_name   IN VARCHAR2 DEFAULT NULL);

  PROCEDURE add_schema_rules(
    schema_name             IN VARCHAR2,
    streams_type            IN VARCHAR2,
    streams_name            IN VARCHAR2 DEFAULT NULL,
    queue_name              IN VARCHAR2 DEFAULT 'streams_queue',
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT FALSE,
    include_tagged_lcr      IN  BOOLEAN DEFAULT TRUE,
    source_database         IN VARCHAR2 DEFAULT NULL,
    inclusion_rule          IN BOOLEAN DEFAULT TRUE,
    and_condition           IN VARCHAR2 DEFAULT NULL,
    source_root_name        IN VARCHAR2 DEFAULT NULL,
    source_container_name   IN VARCHAR2 DEFAULT NULL);

  PROCEDURE add_schema_rules(
    schema_name             IN VARCHAR2,
    streams_type            IN VARCHAR2,
    streams_name            IN VARCHAR2 DEFAULT NULL,
    queue_name              IN VARCHAR2 DEFAULT 'streams_queue',
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT FALSE,
    include_tagged_lcr      IN BOOLEAN DEFAULT TRUE,
    source_database         IN VARCHAR2 DEFAULT NULL,
    dml_rule_name           OUT VARCHAR2,
    ddl_rule_name           OUT VARCHAR2,
    inclusion_rule          IN BOOLEAN DEFAULT TRUE,
    and_condition           IN VARCHAR2 DEFAULT NULL,
    source_root_name        IN VARCHAR2 DEFAULT NULL,
    source_container_name   IN VARCHAR2 DEFAULT NULL);

  PROCEDURE add_table_rules(
    table_name              IN VARCHAR2,
    streams_type            IN VARCHAR2,
    streams_name            IN VARCHAR2 DEFAULT NULL,
    queue_name              IN VARCHAR2 DEFAULT 'streams_queue',
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT FALSE,
    include_tagged_lcr      IN BOOLEAN DEFAULT TRUE,
    source_database         IN VARCHAR2 DEFAULT NULL,
    inclusion_rule          IN BOOLEAN DEFAULT TRUE,
    and_condition           IN VARCHAR2 DEFAULT NULL,
    source_root_name        IN VARCHAR2 DEFAULT NULL,
    source_container_name   IN VARCHAR2 DEFAULT NULL);

  PROCEDURE add_table_rules(
    table_name              IN VARCHAR2,
    streams_type            IN VARCHAR2,
    streams_name            IN VARCHAR2 DEFAULT NULL,
    queue_name              IN VARCHAR2 DEFAULT 'streams_queue',
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT FALSE,
    include_tagged_lcr      IN BOOLEAN DEFAULT TRUE,
    source_database         IN VARCHAR2 DEFAULT NULL,
    dml_rule_name           OUT VARCHAR2,
    ddl_rule_name           OUT VARCHAR2,
    inclusion_rule          IN BOOLEAN DEFAULT TRUE,
    and_condition           IN VARCHAR2 DEFAULT NULL,
    source_root_name        IN VARCHAR2 DEFAULT NULL,
    source_container_name   IN VARCHAR2 DEFAULT NULL);

PROCEDURE add_subset_rules(
  table_name                 IN VARCHAR2,
  dml_condition              IN VARCHAR2,
  streams_type               IN VARCHAR2 DEFAULT 'APPLY',
  streams_name               IN VARCHAR2 DEFAULT NULL,
  queue_name                 IN VARCHAR2 DEFAULT 'streams_queue',
  include_tagged_lcr         IN BOOLEAN DEFAULT TRUE,
  source_database            IN VARCHAR2 DEFAULT NULL,
  source_root_name           IN VARCHAR2 DEFAULT NULL,
  source_container_name      IN VARCHAR2 DEFAULT NULL);

PROCEDURE add_subset_rules(
  table_name                 IN     VARCHAR2,
  dml_condition              IN     VARCHAR2,
  streams_type               IN     VARCHAR2 DEFAULT 'APPLY',
  streams_name               IN     VARCHAR2 DEFAULT NULL,
  queue_name                 IN     VARCHAR2 DEFAULT 'streams_queue',
  include_tagged_lcr         IN     BOOLEAN DEFAULT TRUE,
  source_database            IN VARCHAR2 DEFAULT NULL,
  insert_rule_name              OUT VARCHAR2,
  update_rule_name              OUT VARCHAR2,
  delete_rule_name              OUT VARCHAR2,
  source_root_name           IN VARCHAR2 DEFAULT NULL,
  source_container_name      IN VARCHAR2 DEFAULT NULL);

PROCEDURE add_subset_propagation_rules(
  table_name                 IN VARCHAR2,
  dml_condition              IN VARCHAR2,
  streams_name               IN VARCHAR2 DEFAULT NULL,
  source_queue_name          IN VARCHAR2,
  destination_queue_name     IN VARCHAR2,
  include_tagged_lcr         IN BOOLEAN DEFAULT TRUE,
  source_database            IN VARCHAR2 DEFAULT NULL,
  queue_to_queue             IN BOOLEAN DEFAULT NULL);

PROCEDURE add_subset_propagation_rules(
  table_name                 IN     VARCHAR2,
  dml_condition              IN     VARCHAR2,
  streams_name               IN     VARCHAR2 DEFAULT NULL,
  source_queue_name          IN     VARCHAR2,
  destination_queue_name     IN     VARCHAR2,
  include_tagged_lcr         IN     BOOLEAN DEFAULT TRUE,
  source_database            IN     VARCHAR2 DEFAULT NULL,
  insert_rule_name              OUT VARCHAR2,
  update_rule_name              OUT VARCHAR2,
  delete_rule_name              OUT VARCHAR2,
  queue_to_queue             IN BOOLEAN DEFAULT NULL);

PROCEDURE add_table_propagation_rules(
  table_name              IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT TRUE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

PROCEDURE add_table_propagation_rules(
  table_name              IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT TRUE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  dml_rule_name           OUT VARCHAR2,
  ddl_rule_name           OUT VARCHAR2,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

PROCEDURE add_schema_propagation_rules(
  schema_name             IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT TRUE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

PROCEDURE add_schema_propagation_rules(
  schema_name             IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT TRUE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  dml_rule_name           OUT VARCHAR2,
  ddl_rule_name           OUT VARCHAR2,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

PROCEDURE add_global_propagation_rules(
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT TRUE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

PROCEDURE add_global_propagation_rules(
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT TRUE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  dml_rule_name           OUT VARCHAR2,
  ddl_rule_name           OUT VARCHAR2,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

PROCEDURE purge_source_catalog(
  source_database    IN VARCHAR2,
  source_object_name IN VARCHAR2,
  source_object_type IN VARCHAR2,
  source_root_name   IN VARCHAR2);

PROCEDURE remove_xstream_configuration(
  container          IN VARCHAR2 DEFAULT 'CURRENT',
  xstream_only       IN BOOLEAN DEFAULT TRUE);

PROCEDURE remove_rule(
  rule_name          IN VARCHAR2,
  streams_type       IN VARCHAR2,
  streams_name       IN VARCHAR2,
  drop_unused_rule   IN BOOLEAN DEFAULT TRUE,
  inclusion_rule     IN BOOLEAN DEFAULT TRUE);

PROCEDURE set_up_queue(
  queue_table         IN VARCHAR2 DEFAULT 'streams_queue_table',
  storage_clause      IN VARCHAR2 DEFAULT NULL,
  queue_name          IN VARCHAR2 DEFAULT 'streams_queue',
  queue_user          IN VARCHAR2 DEFAULT NULL,
  comment             IN VARCHAR2 DEFAULT NULL);

PROCEDURE remove_queue(
  queue_name               IN VARCHAR2,
  cascade                  IN BOOLEAN DEFAULT FALSE,
  drop_unused_queue_table  IN BOOLEAN DEFAULT TRUE);


/*split off a propagation. If any of cloned_propagation_name, 
  cloned_capture_namei, cloned_queue_name are null, we will 
  generate a name for it*/
PROCEDURE split_streams (
  propagation_name         IN     VARCHAR2,
  cloned_propagation_name  IN     VARCHAR2 DEFAULT NULL,
  cloned_queue_name        IN     VARCHAR2 DEFAULT NULL,
  cloned_capture_name      IN     VARCHAR2 DEFAULT NULL,
  perform_actions          IN     BOOLEAN  DEFAULT TRUE,
  script_name              IN     VARCHAR2 DEFAULT NULL,
  script_directory_object  IN     VARCHAR2 DEFAULT NULL,
  auto_merge_threshold     IN     NUMBER   DEFAULT NULL,
  schedule_name            IN OUT VARCHAR2,
  merge_job_name           IN OUT VARCHAR2);

/* merge the propagation */
PROCEDURE merge_streams (
  cloned_propagation_name IN VARCHAR2,
  propagation_name        IN VARCHAR2 DEFAULT NULL,
  queue_name              IN VARCHAR2 DEFAULT NULL,
  perform_actions         IN BOOLEAN  DEFAULT TRUE,
  script_name             IN VARCHAR2 DEFAULT NULL,
  script_directory_object IN VARCHAR2 DEFAULT NULL);

/* This function is called by a merge streams job to merge two streams */
PROCEDURE merge_streams_job (
  cloned_propagation_name        IN VARCHAR2,
  propagation_name               IN VARCHAR2 DEFAULT NULL,
  queue_name                     IN VARCHAR2 DEFAULT NULL,
  merge_threshold                IN NUMBER,
  schedule_name                  IN VARCHAR2 DEFAULT NULL,
  merge_job_name                 IN VARCHAR2 DEFAULT NULL);

  PROCEDURE rename_schema(
    rule_name                 IN VARCHAR2,
    from_schema_name          IN VARCHAR2,
    to_schema_name            IN VARCHAR2,
    step_number               IN NUMBER DEFAULT 0,
    operation                 IN VARCHAR2 DEFAULT 'ADD'); 

  PROCEDURE rename_table(
    rule_name          IN VARCHAR2,
    from_table_name    IN VARCHAR2,
    to_table_name      IN VARCHAR2,
    step_number        IN NUMBER DEFAULT 0,
    operation          IN VARCHAR2 DEFAULT 'ADD');

  PROCEDURE delete_column(
    rule_name          IN VARCHAR2,
    table_name         IN VARCHAR2,
    column_name        IN VARCHAR2,
    value_type         IN VARCHAR2 DEFAULT '*',
    step_number        IN NUMBER DEFAULT 0,
    operation          IN VARCHAR2 DEFAULT 'ADD'); 

  PROCEDURE keep_columns(
    rule_name          IN VARCHAR2,
    table_name         IN VARCHAR2,
    column_table       IN DBMS_UTILITY.LNAME_ARRAY,
    value_type         IN VARCHAR2 DEFAULT '*',
    step_number        IN NUMBER DEFAULT 0,
    operation          IN VARCHAR2 DEFAULT 'ADD'); 

  PROCEDURE keep_columns(
    rule_name          IN VARCHAR2,
    table_name         IN VARCHAR2,
    column_list        IN VARCHAR2,
    value_type         IN VARCHAR2 DEFAULT '*',
    step_number        IN NUMBER DEFAULT 0,
    operation          IN VARCHAR2 DEFAULT 'ADD'); 

  PROCEDURE rename_column(
    rule_name          IN VARCHAR2,
    table_name         IN VARCHAR2,
    from_column_name   IN VARCHAR2,
    to_column_name     IN VARCHAR2,
    value_type         IN VARCHAR2 DEFAULT '*',
    step_number        IN NUMBER DEFAULT 0,
    operation          IN VARCHAR2 DEFAULT 'ADD');   

  PROCEDURE add_column(
    rule_name       IN VARCHAR2,
    table_name      IN VARCHAR2,
    column_name     IN VARCHAR2,
    column_value    IN SYS.ANYDATA,
    value_type      IN VARCHAR2 DEFAULT 'NEW',
    step_number     IN NUMBER DEFAULT 0,
    operation       IN VARCHAR2 DEFAULT 'ADD');  

  PROCEDURE add_column(
    rule_name       IN VARCHAR2,
    table_name      IN VARCHAR2,
    column_name     IN VARCHAR2,
    column_function IN VARCHAR2,
    value_type      IN VARCHAR2 DEFAULT 'NEW',
    step_number     IN NUMBER DEFAULT 0,
    operation       IN VARCHAR2 DEFAULT 'ADD');  

  PROCEDURE set_message_tracking(
    tracking_label  IN VARCHAR2 DEFAULT 'xstream_tracking',
    actions         IN NUMBER   DEFAULT action_memory);

  FUNCTION get_message_tracking RETURN VARCHAR2;

  PROCEDURE set_tag(tag IN RAW DEFAULT NULL);

  FUNCTION get_tag RETURN RAW;

  -- Start the capture and/or apply process associated with the specified
  -- outbound server.
  -- If the given server is in committed data mode, then start the apply.
  -- If the capture associated with the outbound server is colocated then
  -- start the capture as well.
  PROCEDURE start_outbound(
    server_name             IN VARCHAR2);
    
  -- Stop the client from receiving data from the specified outbound server.
  -- In addition, if force is TRUE then stop the capture and/or apply
  -- associated with the specified outbound server.
  PROCEDURE stop_outbound(
    server_name             IN VARCHAR2,
    force                   IN BOOLEAN DEFAULT FALSE);

  -- procedure for setting capture or apply process parameters
  -- streams_name - The name of the capture or apply process.
  -- streams_type - The type of process: capture or apply
  -- value=NULL will set the parameter to its default value.
  -- no_wait=TRUE will bypass the 3 second wait when altering the capture/apply
  -- process KGL object.
  PROCEDURE set_parameter(
    streams_name            IN VARCHAR2,
    streams_type            IN VARCHAR2,             /* 'CAPTURE' or 'APPLY' */
    parameter               IN VARCHAR2,                   /* parameter name */
    value                   IN VARCHAR2 DEFAULT NULL, 
    no_wait                 IN BOOleAN DEFAULT FALSE,
    source_database         IN VARCHAR2 DEFAULT NULL);

  PROCEDURE recover_operation(
    script_id IN RAW,
    operation_mode IN VARCHAR2 DEFAULT 'FORWARD');

  --  Will compare two LCRID values. These LCRIDs can have different versions.
  --  The provided position must be a valid LCRID for 12.2.
  -- INPUT
  --   postion1        - Position 1
  --   position2       - Position 2
  -- OUTPUT
  --   0 if both values are equal, -1 if position1  is less than position2,
  --   or 1 if position1 is greater than position 2.
  FUNCTION compare_position(position1   IN RAW,
                            position2   IN RAW) RETURN BINARY_INTEGER;

  -- Converts an LCRID value to the specified version (1 or 2). 
  -- The provided LCRID must be a valid LCRID for 12.2.
  -- INPUT
  --   position         - Position
  --   version          - LCRID Version (1 or 2)
  -- OUTPUT
  --   newposition      - Converted Position
  FUNCTION convert_position(position   IN RAW,
                            version    IN BINARY_INTEGER) RETURN RAW;
  -- purge repl$_process_events
  -- Parameters:
  --  streams_name : the name of the streams process
  --  streams_type : streams type, CAPTURE or APPLY
  --  process_type : Capture, Capture Server, Apply Reader, 
  --                 Apply Server, Apply Network Receiver, 
  --                 Apply Coordinator.
  --  event_name : START, STOP,CREATE, DROP.
  --  include_errors : include error events, default true.
  --  event_time : delete events older than this timestamp.
  --
  -- Note: NULL will consier all possible values, i.e.
  --       if streams_type => NULL
  --       then STREAMS,XSTREAM and GOLDENGATE events will be deleted.
  --       same applies for streams_name, process_type, event_name, event_time
  PROCEDURE delete_replication_events(streams_name IN varchar2 default NULL,
                                      streams_type IN varchar2 default NULL,
                                      process_type IN varchar2 default NULL,
                                      event_name IN varchar2 default NULL,
                                      include_error IN BOOLEAN default TRUE,
                                      event_time IN timestamp default NULL);

FUNCTION get_is_xstream RETURN BOOLEAN;

END dbms_xstream_adm;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_xstream_adm FOR sys.dbms_xstream_adm
/
GRANT EXECUTE ON sys.dbms_xstream_adm TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_xstream_auth AUTHID CURRENT_USER AS 

-- Grants the privileges needed by a user to be an administrator for streams.
-- Optionally generates a script whose execution has the same effect.
-- INPUT:
--   grantee          - the user to whom privileges are granted
--   privilege_type   - CAPTURE, APPLY, both(*)
--   grant_select_privileges - should the select_catalog_role be granted?
--   do_grants        - should the privileges be granted ?
--   file_name        - name of the file to which the script will be written
--   directory_name   - the directory where the file will be written
--   grant_optional_privileges - comma-separated list of optional prvileges
--                               to grant: XBADMIN, DV_XSTREAM_ADMIN,
--                               DV_GOLDENGATE_ADMIN
-- OUTPUT:
--   if grant_select_privileges = TRUE
--     grant select_catalog_role to grantee
--   if grant_select_privileges = FALSE
--     grant a min set of privileges to grantee
--   if do_grants = TRUE
--     the grant statements are to be executed.
--   if do_grants = FALSE
--     the grant statements are not executed.
--   If file_name is not NULL, 
--     then the script is written to it.
-- NOTES:
--   An error is raised if do_grants is false and file_name is null.
--   The file i/o is done using the package utl_file.
--   The file is opened in append mode.
--   The CREATE DIRECTORY command should be used to create directory_name.
--   If do_grants is true, each statement is appended to the script
--     only if it executed successfully.
PROCEDURE grant_admin_privilege(
  grantee          IN VARCHAR2,
  privilege_type   IN VARCHAR2 DEFAULT '*',
  grant_select_privileges IN BOOLEAN DEFAULT FALSE,
  do_grants        IN BOOLEAN DEFAULT TRUE,
  file_name        IN VARCHAR2 DEFAULT NULL,
  directory_name   IN VARCHAR2 DEFAULT NULL,
  grant_optional_privileges IN VARCHAR2 DEFAULT NULL,
  container        IN VARCHAR2 DEFAULT 'CURRENT');

-- Revokes the privileges needed by a user to be an administrator for streams.
-- Optionally generates a script whose execution has the same effect.
-- INPUT:
--   grantee           - the user from whom the privileges are revoked
--   privilege_type    - CAPTURE, APPLY, both(*)
--   revoke_select_privileges - should the select_catalog_role be revoked?
--   do_revokes        - should the privileges be revoked ?
--   file_name         - name of the file to which the script will be written
--   directory_name    - the directory where the file will be written
--   revoke_optional_privileges - comma-separated list of optional prvileges
--                                to revoke: XBADMIN, DV_XSTREAM_ADMIN,
--                                DV_GOLDENGATE_ADMIN
-- OUTPUT:
--   if revoke_select_privileges = TRUE
--     revoke select_catalog_role from grantee
--   if revoke_select_privileges = FALSE
--     revoke a min set of privileges from grantee
--   if do_revokes = TRUE
--     the revoke statements are to be executed.
--   if do_revokes = FALSE
--     the revoke statements are not executed.
--   If file_name is not NULL, 
--     then the script is written to it.
-- NOTES:
--   An error is raised if do_revokes is false and file_name is null.
--   The file i/o is done using the package utl_file.
--   The file is opened in append mode.
--   The CREATE DIRECTORY command should be used to create directory_name.
--   If do_revoke is true, each statement is appended to the script 
--     only if it executed successfully.
PROCEDURE revoke_admin_privilege(
  grantee           IN VARCHAR2,
  privilege_type    IN VARCHAR2 DEFAULT '*',
  revoke_select_privileges IN BOOLEAN DEFAULT FALSE,
  do_revokes        IN BOOLEAN DEFAULT TRUE,
  file_name         IN VARCHAR2 DEFAULT NULL,
  directory_name    IN VARCHAR2 DEFAULT NULL,
  revoke_optional_privileges IN VARCHAR2 DEFAULT NULL,
  container        IN VARCHAR2 DEFAULT 'CURRENT');

-- Grantss the privileges that allow a Streams administrator at another
-- database to perform remote Streams administration at this database
-- using the grantee through a database link.
-- INPUT:
--   grantee          - the user to whom privileges are granted
-- OUTPUT:
--   grantee is added to DBA_STREAMS_ADMINISTRATOR with ACCESS_FROM_REMOTE
--   set to YES.
PROCEDURE grant_remote_admin_access(grantee    IN VARCHAR2);

-- Revokes the privileges that allow a Streams administrator at another
-- database to perform remote Streams administration at this database
-- using the grantee through a database link.
-- INPUT:
--   grantee          - the user from whom the privileges are revoked
-- OUTPUT:
--   set ACCESS_FROM_REMOTE to NO for user in DBA_STREAMS_ADMINISTRATOR.
--   if user also does not have LOCAL_PRIVILEGES then remove entry for
--   user from DBA_STREAMS_ADMINISTRATOR.
PROCEDURE revoke_remote_admin_access(grantee    IN VARCHAR2);

END dbms_xstream_auth;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_xstream_auth FOR sys.dbms_xstream_auth
/

@?/rdbms/admin/sqlsessend.sql
