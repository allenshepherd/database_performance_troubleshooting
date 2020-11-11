Rem
Rem $Header: rdbms/admin/dbmsilm.sql /main/27 2015/04/17 16:30:01 vinisubr Exp $
Rem
Rem dbmsilm.sql
Rem
Rem Copyright (c) 2011, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsilm.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <DBMS_ILM package definition>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsilm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsilm.sql
Rem SQL_PHASE: DBMSILM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vinisubr    03/25/15 - Project 58876: Support for flushing column stats
Rem    hlakshma    01/08/15 - Add constants for controlling resource
Rem                           comsumption by ADO (bug-17395601)
Rem    dhdhshah    09/04/14 - 19032029: extend stop_ilm to stop a specific job
Rem    hlakshma    03/10/14 - Change the default for ADO job limit
Rem    dhdhshah    03/04/14 - 16887946: fix for execution privilege of package
Rem                           dbms_ilm_admin
Rem    hlakshma    02/27/14 - Change the name of the parameter PURGE_INTERVAL
Rem                           to RETENTION_TIME
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    hlakshma    11/22/13 - Procedure to purge ADO metadata
Rem    hlakshma    05/14/13 - Backport fixes from 12.1 to MAIN
Rem    prgaharw    03/07/13 - XbranchMerge prgaharw_supilm from
Rem                           st_rdbms_12.1.0.1
Rem    vradhakr    01/21/13 - XbranchMerge vradhakr_bug-16067485 from
Rem                           st_rdbms_12.1.0.1
Rem    vradhakr    12/26/12 - Heat map maintenance.
Rem    prgaharw    12/17/12 - 16005897 - ILM and Supplementary logging checks
Rem    vraja       10/15/12 - add archive_state_archived and
Rem                           archive_state_active constants to dbms_ilm
Rem    hlakshma    10/09/12 - Fix ILM procedure signatures
Rem    smuthuli    10/01/12 - move heatmap APIs to dbms_heat_map
Rem    smuthuli    09/06/12 - rename ILM statistics APIs
Rem    smuthuli    08/25/12 - Add BlockLevelStats APIs
Rem    prgaharw    05/31/12 - Bug 13855243 - fix ilm_execute (obj/policy)
Rem    hlakshma    05/25/12 - Add execution mode to ILM API
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    liaguo      02/22/12 - default subobject_name
Rem    hlakshma    01/11/12 - Additional procedures to faciliate manual
Rem                           override in ILM workflow
Rem    hlakshma    12/22/11 - Add ilm admin package
Rem    liaguo      10/10/11 - parameter name change
Rem    liaguo      07/05/11 - Proj 32788 DB ILM: activity tracking
Rem    hlakshma    01/10/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package dbms_ilm authid current_user is

    /* constants specifying ROW ARCHIVAL state */
    archive_state_active   constant varchar2(1) := '0';
    archive_state_archived constant varchar2(1) := '1'; 
    
    /*
     *  description - Given a value for the ORA_ARCHIVE_STATE column this
     *   function returns the mapping for the value.  
     * 
     *  value - "0", "1" or other values from the ORA_ARCHIVE_STATE column of
     *          a row archival enabled table
     *  returns either "archive_state_active" or "archive_state_archived" 
     */
    function archiveStateName(value in varchar2) return varchar2;

    /* constants specifying the scope of ilm execution*/
    
    /* execute all ilm policies in the database */
    SCOPE_DATABASE  constant  number  :=  1;
    /* execute all ilm policies in the scope */
    SCOPE_SCHEMA    constant  number  := 2;

    /* ILM Execution mode constants */
    ILM_EXECUTION_OFFLINE  constant number      := 1;
    ILM_EXECUTION_ONLINE   constant number      := 2;
    ILM_EXECUTION_DEFAULT  constant number      := 3;

    /* Denote all ILM executions. -1 is not a valid execution id */
    ILM_ALL_EXECUTIONS constant number := -1;

    /* Constant specifying all ILM policies of an object*/
    ILM_ALL_POLICIES     constant varchar2(20) := 'ALL POLICIES';
 
    /* constants specifying when ILM task should be scheduled */
    
    /* Schedule ILM task for immediate execution */ 
    SCHEDULE_IMMEDIATE  constant number := 1;
    
    
     procedure preview_ilm(
          task_id              out         number,
          ilm_scope            in          number default SCOPE_SCHEMA
          );
    /*
     *  description - Evaluate all ilm policies in the scope specified 
     *  through an argument
     * 
     * ilm_scope - identifies the scope of execution. should be a constant
     *  specified in the package definition
     * execution_id - Identifies a particular execution of ILM
     */


    procedure add_to_ilm(
           task_id            in    number,
           own                in    varchar2,
           objname            in    varchar2,
           subobjname         in    varchar2 default null);
    /*
     * description - Add an object to a particular ILM task 
     * 
     * p_execution_id - Identify the particular ILM task
     * own            - owner of the object
     * objname        - name of the object
     * subobjname     - name of the subobject (partition name in the case of
     *                    partitioned tables)
     */
    
      procedure remove_from_ilm(
           task_id            in    number,
           own                in    varchar2,
           objname            in    varchar2,
           subobjname         in    varchar2 default null);
    /*
     * description - Remove an object to a particular ILM task
     * 
     * execution_id   - Identify the particular ILM task
     * own            - owner of the object
     * objname        - name of the object
     * subobjname     - name of the subobject (partition name in the case of
     *                    partitioned tables)
     */
     
     procedure execute_ilm_task(
          task_id              in         number,
          execution_mode       in         number default ILM_EXECUTION_ONLINE,
          execution_schedule   in         number default SCHEDULE_IMMEDIATE);
    /*
     *  description - execute all ilm policies in a previously evaluated 
     *                ILM task. The ILM policies would not be evaluated again
     *  
     * 
     *  execution_id        - Identifies an ILM task
     *  execution_schedule  - Identifies when the ILM task should be executed.
     *                        The choices available are identified using 
     *                        constants defined in the package. The choices 
     *                        include , schedule the ILM task for immediate
     *                        execution or use the background ILM scheduling 
     *                        infrastructure to schedule the ILM task execution
     */

     procedure execute_ilm(
         task_id             out         number, 
         ilm_scope           in          number  default SCOPE_SCHEMA, 
         execution_mode      in          number  default ILM_EXECUTION_ONLINE
         );
    /*
     *  description - execute all ilm policies in the scope specified 
     *  through an argument
     * 
     * ilm_scope - identifies the scope of execution. should be a constant
     *  specified in the package definition
     * execution_id - Identifies a particular execution of ILM
     */
     
     procedure execute_ILM(
       owner          in     varchar2,
       object_name    in     varchar2,
       task_id        out    number,
       subobject_name in     varchar2 default null,
       policy_name    in     varchar2 default ILM_ALL_POLICIES,
       execution_mode in     number   default ILM_EXECUTION_ONLINE
       );
    /*
     * description - execute all ilm policies for an object in the calling 
     * schema.
     *
     * owner          - owner of the object
     * object_name    - name of the object
     * subobject_name - name of the subobject (partition name in the case of
     *                    partitioned tables)
     */
 
    procedure stop_ilm (
         task_id               in         number default ILM_ALL_EXECUTIONS, 
         p_drop_running_jobs   in         boolean default false,
         p_jobname             in         varchar2 default null);
    /*
     * description - stop ilm related jobs created for a specific
     *               executio.     
     *
     * 
     * execution_id        -  number that uniquely identifies a particular 
     *                        ilm execution
     * p_drop_running_jobs -  should running jobs be dropped?
     * p_jobname           -  name of a particular job to be stopped
     */

    /*****************************************************************
     * Activity Tracking
     *****************************************************************/

     procedure flush_all_segments;
    /*
     * description - flush all in-memory segment access tracking info
     */

     procedure flush_segment_access(owner_name IN VARCHAR2,
                                    object_name IN VARCHAR2,
                                    subobject_name IN VARCHAR2 default NULL);
    /*
     * description: flush in-memory access tracking info for the object
     * 
     *  owner_name  - Name of the object owner
     *  object_name - Name of the object
     *  subobject_name - Name of the sub-object e.g. partition name
     */

     procedure flush_rowmaps;
    /*
     * description - flush all in-memory segment rowid bitmaps info
     */

     procedure flush_segment_rowmap(owner_name IN VARCHAR2,
                                    object_name IN VARCHAR2,
                                    subobject_name IN VARCHAR2 default NULL);
    /*
     * description: flush in-memory rowid bitmap for the object
     * 
     *  owner_name  - Name of the object owner
     *  object_name - Name of the object
     *  subobject_name - Name of the sub-object e.g. partition name
     */
 
     procedure flush_col_stats;
     /*
      * description: flush all in-memory column statistics to COLUMN_STAT$. 
      * This is in the DBMS_ILM package because column statistics will primarily
      * be used by ADO to perform ILM functionality such as eviction/bringing
      * a column into memory. 
      */
     
    /* exceptions:
     *
     * dbms_ilm api operations can raise any one of the following top-level
     * exceptions.
     *
     */
     /* invalid arugment value */
     invalid_argument_value  exception;
     pragma exception_init(invalid_argument_value, -38327);

     /* inconsistent dictionary state */
     invalid_ilm_dictionary  exception;
     pragma exception_init(invalid_ilm_dictionary, -38328);

     /* internal error */
     internal_ilm_error      exception;
     pragma exception_init(internal_ilm_error, -38329);

     /* insufficient privileges */
     insufficient_privileges exception;
     pragma exception_init(insufficient_privileges, -38330);

     /* ADO online mode unsupported with Supplemental Logging */
     unsupported_ilm_supl    exception;
     pragma exception_init(unsupported_ilm_supl, -38343);

end dbms_ilm;
/

show errors

create or replace public synonym dbms_ilm for sys.dbms_ilm
/

grant execute on dbms_ilm to public
/

CREATE OR REPLACE LIBRARY dbms_ilm_lib trusted as static
/ 

show errors;

create or replace package dbms_ilm_admin authid definer 
as 

   /*
    * Parameters for controling ILM execution
    */
    
    EXECUTION_INTERVAL constant number      := 1;
    RETENTION_TIME     constant number      := 2;    
    EXECUTION_MODE     constant number      := 4;
    JOBLIMIT           constant number      := 5;
    ENABLED            constant number      := 7;
    TBS_PERCENT_USED   constant number      := 8;
    TBS_PERCENT_FREE   constant number      := 9;
    DEG_PARALLEL       constant number      := 10;
    POLICY_TIME        constant number      := 11;
    ABS_JOBLIMIT       constant number      := 12;
    JOB_SIZELIMIT      constant number      := 13;

   /*
    * Constants for parameter values
    */ 
   
   /* ILM Execution mode constants */
    ILM_EXECUTION_OFFLINE  constant number      := 1;
    ILM_EXECUTION_ONLINE   constant number      := 2;
    ILM_EXECUTION_DEFAULT  constant number      := 3;
   
    ILM_ENABLED            constant number      := 1;
    ILM_DISABLED           constant number      := 2;

    ILM_LIMIT_DEF          constant number      := 2;

    ILM_POLICY_IN_DAYS     constant number      := 0;
    ILM_POLICY_IN_SECONDS  constant number      := 1;
    
    /* ADO execution data is purged periodically for all completed jobs 
     * older then the ILM_RETENTION_TIME */
    ILM_RETENTION_TIME     constant number      := 30;

    /* Denote default value for the parameter*/
    ILM_DEFAULT            constant number      := -1;

   /*
    * description - Customize environment for ILM execution by specifying 
    *               the values for ILM execution related parameters. These
    *               values take effect for the next background ILM execution
    *           
    *  parameter - One of the constants defined in this package
    *  value     - Value of this parameter.        
    */  
    procedure customize_ilm(
          parameter                           number,
          value                in             number);

   /* Procedure to turn off background ILM */
    procedure disable_ilm;
    
   /* Procedure to turn on background ILM */
    procedure enable_ilm;        

   /* Heat map segment access constants */
    HEAT_MAP_SEG_WRITE  constant number      := 1;
    HEAT_MAP_SEG_READ   constant number      := 2;
    HEAT_MAP_SEG_SCAN   constant number      := 4;
    HEAT_MAP_SEG_LOOKUP constant number      := 8;

   /* Procedure to delete all rows except the dummy row. */
    procedure clear_heat_map_all;

   /* Procedure to Update/insert heat map rows for all tables */
    procedure set_heat_map_all(
          access_date            IN DATE, 
          segment_access_summary IN number);

   /* Procedure to update/insert a row for this table/segment. */
    procedure set_heat_map_table(
          owner                  IN VARCHAR2,
          tablename              IN VARCHAR2,
          partition              IN VARCHAR2 default '',
          access_date            IN DATE,
          segment_access_summary IN number);

   /*
    * Procedure to clear all/some statistics for table: deletes rows for 
    * given table/segment which match given pattern or all such rows 
    */
    procedure clear_heat_map_table(
          owner                  IN VARCHAR2,
          tablename              IN VARCHAR2,
          partition              IN VARCHAR2 default '',
          access_date            IN DATE default NULL,
          segment_access_summary IN number default NULL);

   /*
    * Procedure to set start date of heat map data
    */
    procedure set_heat_map_start(start_date            IN DATE);

  
   /* exceptions:
    *
    * dbms_ilm_admin api operations can raise any one of the following 
    * top-level exceptions.
    *
    */

    /* insufficient privileges */
    insufficient_privileges exception;
    pragma exception_init(insufficient_privileges, -38330);

    /* invalid arugment value */
    invalid_argument_value  exception;
    pragma exception_init(invalid_argument_value, -38327);

    /* invalid dictionary state */
    invalid_ilm_dictionary  exception;
    pragma exception_init(invalid_ilm_dictionary, -38328);

    /* ADO online mode unsupported with Supplemental Logging */
    unsupported_ilm_supl    exception;
    pragma exception_init(unsupported_ilm_supl, -38343);

end dbms_ilm_admin;
/

create or replace public synonym dbms_ilm_admin for sys.dbms_ilm_admin
/

grant execute on dbms_ilm_admin to dba
/

show errors;


@?/rdbms/admin/sqlsessend.sql
