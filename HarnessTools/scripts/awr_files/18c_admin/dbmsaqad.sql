Rem 
Rem $Header: rdbms/admin/dbmsaqad.sql /main/87 2017/01/27 10:05:06 ssubrama Exp $
Rem
Rem dbmsaqad.sql
Rem 
Rem Copyright (c) 1996, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsaqad.sql - package which contains the administrative
Rem                     operations of AQ
Rem
Rem    DESCRIPTION
Rem      This file contains the dbms_aqadm package.
Rem
Rem    NOTES
Rem      
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsaqad.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsaqad.sql
Rem SQL_PHASE: DBMSAQAD
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ssubrama    12/19/16 - bug 25134546 switch queue table
Rem    ssubrama    08/17/16 - bug 24290942 default NULL for repl mode
Rem    sjanardh    02/12/16 - Bug 6811960. Make dbms_aqadm Invokers Rights.
Rem    atomar      03/03/16 - remove unused argument from
Rem                           create_exception_queue
Rem    xintli      02/25/16 - Bug 22746156: rename queue parameter APIs
Rem    atomar      02/02/16 - remove STOP_MESSAGE_FORWARDING etc maintenence
Rem                           proc
Rem    xintli      01/05/16 - bug 20608436: add get_sharded_queue_parameter
Rem    mjaiswal    05/28/15 - add STOP_MESSAGE_FORWARDING,ANALYZE_MESSAGE_CACHE
Rem    ssubrama    03/19/15 - bug 20673262 active/passive queues
Rem    sjanardh    02/25/15 - Add verify_sharded_queue
Rem    ssubrama    02/02/15 - bug 20398427 pragma for OGG replication
Rem    ssubrama    12/11/14 - project 38553 replication of sharded q
Rem    ranbaner    07/07/14 - project 45944-Parameter table, cachd hint
Rem    atomar      11/27/14 - create exception qeueue api
Rem    maba        11/12/14 - add additional storage clause for dequeue log
Rem                           table sharded queue
Rem    ssubrama    11/01/14 - project 38553 active/passive queues for ogg 
Rem                           replication
Rem    maba        07/16/14 - modify create_sharded_queue api
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    baparmar    01/31/13 - Bug14837395: qobj# change from sb4 to ub4 fix
Rem    ssubrama    08/05/12 - bug 14489696 push pragma to lower function
Rem    amadan      08/03/12 - Bug 14394736: Add procedure for AQ streamspool
Rem    ssubrama    06/07/12 - bug 14160220 logical standby replication
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    maba        03/17/12 - fix bug 13857376
Rem    maba        03/12/12 - removed auto_commit from drop_sharded_queue
Rem    sjanardh    10/21/11 - Remove create_jms_queue
Rem    sjanardh    10/19/11 - Bug fix 13113861
Rem    maba        08/27/11 - move drop_sharded_queue to dbms_aqadm pkg
Rem    vbipinbh    07/01/11 - priority queue
Rem    sjanardh    03/30/11 - Introduce JMS_TYPE
Rem    maba        03/10/11 - Added create_queue, create_sharded_queue api
Rem    sjanardh    01/27/11 - JMS 12C related changes
Rem    yki         07/15/10 - dbmsaqad.sql(auto_comment)
Rem    yki         07/14/10 - add shard_count to create_table
Rem    gagarg      10/13/09 - Add multi-consumer support
Rem    jawilson    04/28/09 - 12 queues
Rem    shbose      09/18/09 - Bug 8764375: change prototype of
Rem                           recover_propagation
Rem    jawilson    10/02/07 - remove set_session_event
Rem    shbose      02/14/07 - #lrg:2450821: change argument type of
Rem                           schedule_propagation to timestamp
Rem    jawilson    10/12/06 - change defaults for schedule_propagation
Rem    jawilson    02/13/06 - add replay info API 
Rem    kmeiyyap    06/09/04 - add queue_to_queue boolean parameter 
Rem    nbhatt      06/27/04 - refresh
Rem    nbhatt      04/30/04 - support buffered queue interfaces
Rem    rvenkate    05/13/04 - add argument to alter_queue API 
Rem    rvenkate    08/04/03 - just use network name 
Rem    ksurlake    08/14/03 - declare get_prop_seqno
Rem    weiwang     07/16/03 - add q2q propagation flags
Rem    kmeiyyap    07/24/03 - grabtrans 'kmeiyyap_q2q_buff_prop'
Rem    rvenkate    07/21/03 - add network_name to get_type_info
Rem    nikeda      01/03/03 - get_type_info with NO queue_style
Rem    kmeiyyap    11/23/02 - add queue_style to get_type_info
Rem    kmeiyyap    08/14/02 - create purge_options type
Rem    kmeiyyap    07/16/02 - add purge_queue_table procedure
Rem    weiwang     04/17/02 - add add_connection_to_ldap
Rem    weiwang     03/05/02 - pass username/password to recover_propagation
Rem    bnainani    01/10/02 - add enable_jms_types
Rem    kmeiyyap    10/31/01 - remove ruleset from add_susbcriber.
Rem                           remove add_publisher APIs
Rem    bnainani    10/04/01 - add secure flag to create_queue_table
Rem    nbhatt      08/04/01 - backward comp. of alter_Subscriber
Rem    najain      07/31/01 - queue enhancements for replication
Rem    nbhatt      07/13/01 - add_publisher
Rem    nbhatt      07/19/01 - add protocol numbers
Rem    nbhatt      07/19/01 - add_sub changes
Rem    nbhatt      03/14/01 - trace recover propagation
Rem    bnainani    01/09/01 - add set_session_event proc
Rem    nbhatt      01/11/01 - add create proapgation wallet
Rem    najain      11/20/00 - scale server notification
Rem    nbhatt      11/08/00 - pass protocol, url to recover_propagation
Rem    rkambo      07/21/00 - notification presentation support
Rem    aahluwal    07/26/00 - Adding checks for null paramaters in auth functio
Rem    aahluwal    07/24/00 - Changing way protocol is specified
Rem    nbhatt      08/21/00 - add transformation to subscriber table
Rem    najain      04/26/00 - support AQ signature
Rem    aahluwal    07/12/00 - Adding AQ Auth Procs
Rem    rkambo      06/06/00 - pubsub enhancement
Rem    weiwang     02/25/00 - add LDAP support
Rem    najain      03/10/00 - support for email notification
Rem    najain      02/10/00 - remove commented types
Rem    najain      12/27/99 - support for  plsql notification
Rem    arsaxena    11/27/98 - add verify_queue_types_no_queue
Rem    ryaseen     11/20/98 - split dbms_aqadm
Rem    ato         10/21/98 - move dbms_aq_import_internal out                 
Rem    schandra    08/14/98 - default max_retries to 5
Rem    ato         07/01/98 - support altering comments in alter_queue
Rem    ryaseen     06/29/98 - add temp functions for rules export/import
Rem    nbhatt      06/02/98 - remove overloaded create_queue_table
Rem    mkamath     06/10/98 - overloading aq$_propaq for upgrade/downgrade
Rem    ato         06/07/98 - move all grants to catqueue                      
Rem    ato         06/03/98 - don't grant dbms_aqadm to PUBLIC                 
Rem    ato         05/08/98 - move create roles out
Rem    ato         05/04/98 - add grant/revoke
Rem    ryaseen     05/07/98 - add alter subscriber                             
Rem    ato         04/30/98 - remove obsoleted functions
Rem    schandra    04/15/98 - move recover propagation
Rem    arsaxena    04/28/98 - add non_persistent_q support
Rem    mkamath     04/26/98 - support for enable, disable and alter schedule
Rem    mkamath     04/26/98 - Moving prop_queue procedures to prvtaqip
Rem    mkamath     04/17/98 - Adding procedure prop_job_submit
Rem    ryaseen     04/22/98 - add rule to add_subscriber call                  
Rem    schandra    04/06/98 - grant select on aq_propagation_status to aq admin
Rem    schandra    02/16/98 - add compatilibity parameter to create_queue_table
Rem    mkamath     04/06/98 - Adding procedures for new scheduling algorithm
Rem    arsaxena    11/09/97 - change propaq to return the next date;
Rem    ato         08/20/97 - grant DBMS_AQ and DBMS_AQADM to execute_catalog_r
Rem    arsaxena    08/07/97 - change default values for propagation
Rem    nbhatt      08/13/97 -  grant v$_aq_statistics to admin
Rem    nbhatt      08/12/97 - grant select on v$aq_statistics & gv$aq_statistic
Rem    nbhatt      07/22/97 - code review changes
Rem    hrizvi      07/23/97 - dont grant package permissions to public
Rem    arsaxena    07/22/97 - Add scheduling functions for propagation
Rem    ato         05/01/97 - remove test_ac_ddl
Rem    schandra    04/29/97 - add types for displaying dequeue history
Rem    nbhatt      04/26/97 - add start_time_manager and stop_time_manager
Rem    ato         04/23/97 - recreate user view after import
Rem    ato         04/22/97 - add dbms_aq_import_internal to aqadm role
Rem    nbhatt      04/22/97 - change recipient->consumer
Rem    nbhatt      04/21/97 - restore the tracking option in create_queue as de
Rem    nbhatt      04/20/97 - final interface change
Rem    esoyleme    04/24/97 - add iot imp/exp
Rem    schandra    04/14/97 - import/export for multiple dequeuers
Rem    nbhatt      04/10/97 - make recipient enumerated type
Rem    ato         03/31/97 - add raw type queue in create_qtable
Rem    schandra    03/25/97 - support grouping by tansaction
Rem    schandra    03/11/97 - use aq_agent in admin interface
Rem    schandra    02/17/97 - add multiple dequeues clause to create_qtable
Rem    ato         04/04/97 - support for autocommit parameter
Rem    nbhatt      03/31/97 - change interface
Rem    ato         03/21/97 - remove object_type_format from create_qtable
Rem    ato         03/21/97 - remove lob_storage and lob_tspace from create_qta
Rem    ato         11/13/96 - add aq_user_role
Rem    pshah       11/07/96 - Changing a create_qtable() 
Rem                           parameter [q_adt => q_object_type]
Rem    pshah       10/21/96 - Grant execute priveleges
Rem    pshah       09/27/96 - Removing roles
Rem    ato         09/26/96 - remove grant execute any type
Rem    ato         09/25/96 - remove test_ac_ddl
Rem    pshah       09/23/96 - Adding test_ac_ddl()
Rem    ato         09/03/96 - create aq_administrator and user roles
Rem    ato         09/03/96 - add synonyms
Rem    pshah       08/28/96 - Adding parameters (ret_time and retention)
Rem                           to alter_q()
Rem    pshah       08/26/96 - Adding logic to create_q() for message retention
Rem    ato         08/20/96 - typed queues
Rem    ato         08/15/96 - add typed queues
Rem    ato         07/29/96 - add aq_import_internal
Rem    pshah       07/10/96 - Adding trusted callout procedure kwqaoprg
Rem    pshah       06/17/96 - Adding lob_storage parameter to create_qtable
Rem    pshah       06/06/96 - Adding an extra parameter to create_q()
Rem    pshah       04/23/96 - Changing 'queue' to 'q'
Rem    pshah       04/14/96 - Interating all admin functions
Rem    pshah       02/13/96 - Administrative Interface definition
Rem    pshah       02/13/96 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_aqadm AUTHID CURRENT_USER AS

  --------------------
  --  PUBLIC CONSTANT
  --
  -- payload type of the queue table
  JMS_TYPE             CONSTANT VARCHAR2(10) := 'JMS';

  -- retention
  INFINITE             CONSTANT BINARY_INTEGER := -1;

  -- message grouping
  TRANSACTIONAL        CONSTANT BINARY_INTEGER := 1;
  NONE                 CONSTANT BINARY_INTEGER := 0;

  -- queue type
  NORMAL_QUEUE               CONSTANT BINARY_INTEGER := 0;
  EXCEPTION_QUEUE            CONSTANT BINARY_INTEGER := 1;
  NON_PERSISTENT_QUEUE       CONSTANT BINARY_INTEGER := 2;

  -- non-repudiation properties
  NON_REPUDIATE_SENDER       CONSTANT BINARY_INTEGER := 1;
  NON_REPUDIATE_SNDRCV       CONSTANT BINARY_INTEGER := 2;

  -- protocols (note that FTP is not supported yet so it is not
  -- included in anyp). 
  TTC      CONSTANT BINARY_INTEGER := 0;
  HTTP      CONSTANT BINARY_INTEGER := 1;
  SMTP      CONSTANT BINARY_INTEGER := 2;
  FTP       CONSTANT BINARY_INTEGER := 4;
  ANYP      CONSTANT BINARY_INTEGER := HTTP + SMTP;
  
  LOGMINER_PROTOCOL  CONSTANT BINARY_INTEGER := 1;
  LOGAPPLY_PROTOCOL  CONSTANT BINARY_INTEGER := 2;
  TEST_PROTOCOL      CONSTANT BINARY_INTEGER := 3;  

  -- Constants for LDAP connection factory type
  AQ_QUEUE_CONNECTION  CONSTANT BINARY_INTEGER := 1;
  AQ_TOPIC_CONNECTION  CONSTANT BINARY_INTEGER := 2;

  -- Constants for delivery mode
  PERSISTENT         CONSTANT BINARY_INTEGER := 1 ;
  BUFFERED           CONSTANT BINARY_INTEGER := 2 ;
  PERSISTENT_OR_BUFFERED   CONSTANT BINARY_INTEGER := 3 ;

  -- subscriber properties. 
  QUEUE_TO_QUEUE_SUBSCRIBER          CONSTANT BINARY_INTEGER := 8;  

  -- Constants for get/set_replay_info
  LAST_ENQUEUED      CONSTANT BINARY_INTEGER := 0;
  LAST_ACKNOWLEDGED  CONSTANT BINARY_INTEGER := 1; 

  -- 12G sort_list parameter
  -- rearrange sort list values to sync with dbms_aqadm_sys.SC_* and 
  -- its corresponding KWSC_* flags in kwsc.h. 
  PRIORITY                  CONSTANT BINARY_INTEGER := 1;
  ENQ_TIME                  CONSTANT BINARY_INTEGER := 2;
  PRIORITY_ENQ_TIME         CONSTANT BINARY_INTEGER := 3;
  COMMIT_TIME               CONSTANT BINARY_INTEGER := 4;
  PRIORITY_COMMIT_TIME      CONSTANT BINARY_INTEGER := 5;
  ENQ_TIME_PRIORITY         CONSTANT BINARY_INTEGER := 7;

  -- 12G sharded queue cach hint
  AUTO                      CONSTANT BINARY_INTEGER := 1;
  CACHED                    CONSTANT BINARY_INTEGER := 2;
  UNCACHED                  CONSTANT BINARY_INTEGER := 3;

  -- OGG replicated queue
  -- Queue replication can happen in two ways replication or propagation
  -- when queue is not participating in both , the mode is NONE.
  REPLICATION_MODE    CONSTANT BINARY_INTEGER := 1 ;
  PROPAGATION_MODE    CONSTANT BINARY_INTEGER := 2;
  SWITCHOVER_FORCE    CONSTANT BINARY_INTEGER := 4;

  TYPE aq$_subscriber_list_t IS TABLE OF sys.aq$_agent
    INDEX BY BINARY_INTEGER;

  TYPE aq$_purge_options_t IS
     RECORD(block          boolean      DEFAULT FALSE,
            delivery_mode  PLS_INTEGER  DEFAULT dbms_aqadm.PERSISTENT);

  ------------------------------------------------------------------------
  -- AQ Type definitions

  TYPE QUEUE_PROPS_T IS RECORD (
    queue_type      BINARY_INTEGER DEFAULT NORMAL_QUEUE,
    retry_delay     NUMBER         DEFAULT 0,
    retention_time  NUMBER         DEFAULT 0,
    sort_list       VARCHAR2(30)   DEFAULT NULL,
    cache_hint      BINARY_INTEGER DEFAULT AUTO
    );

  PROCEDURE CREATE_SHARDED_QUEUE (
    queue_name             IN VARCHAR2,
    storage_clause         IN VARCHAR2       DEFAULT NULL,
    multiple_consumers     IN BOOLEAN        DEFAULT FALSE,
    max_retries            IN NUMBER         DEFAULT NULL,
    comment                IN VARCHAR2       DEFAULT NULL,
    queue_payload_type     IN VARCHAR2       DEFAULT JMS_TYPE,
    queue_properties       IN QUEUE_PROPS_T  DEFAULT NULL,
    replication_mode       IN BINARY_INTEGER DEFAULT NONE
    );
  PRAGMA SUPPLEMENTAL_LOG_DATA(CREATE_SHARDED_QUEUE, NONE);

  PROCEDURE CREATE_EXCEPTION_QUEUE(
    sharded_queue_name     IN VARCHAR2,
    exception_queue_name   IN VARCHAR2 DEFAULT NULL
    );
  PRAGMA SUPPLEMENTAL_LOG_DATA(CREATE_EXCEPTION_QUEUE, NONE);


  PROCEDURE ALTER_SHARDED_QUEUE(
    queue_name             IN VARCHAR2,
    max_retries            IN NUMBER         DEFAULT NULL,
    comment                IN VARCHAR2       DEFAULT NULL,
    queue_properties       IN QUEUE_PROPS_T  DEFAULT NULL,
    replication_mode       IN BINARY_INTEGER DEFAULT NONE
    );
  PRAGMA SUPPLEMENTAL_LOG_DATA(ALTER_SHARDED_QUEUE, NONE);
  
  PROCEDURE  set_queue_parameter(
    queue_name          IN VARCHAR2,
    param_name          IN VARCHAR2,
    param_value         IN NUMBER);
 

  PROCEDURE unset_queue_parameter(
    queue_name          IN VARCHAR2,
    param_name          IN VARCHAR2);

  PROCEDURE get_queue_parameter(
    queue_name          IN  VARCHAR2,
    param_name          IN  VARCHAR2,
    param_value         OUT NUMBER);
  
  PROCEDURE create_queue_table(
        queue_table                 IN     VARCHAR2,
        queue_payload_type          IN     VARCHAR2,
        storage_clause              IN     VARCHAR2 DEFAULT NULL,
        sort_list                   IN     VARCHAR2 DEFAULT NULL,
        multiple_consumers          IN     BOOLEAN DEFAULT FALSE,
        message_grouping            IN     BINARY_INTEGER DEFAULT NONE,
        comment                     IN     VARCHAR2 DEFAULT NULL,
        auto_commit                 IN     BOOLEAN  DEFAULT TRUE,
        primary_instance            IN     BINARY_INTEGER DEFAULT 0,
        secondary_instance          IN     BINARY_INTEGER DEFAULT 0,
        compatible                  IN     VARCHAR2 DEFAULT NULL,
        non_repudiation             IN     BINARY_INTEGER DEFAULT 0,
        secure                      IN     BOOLEAN DEFAULT FALSE,
        replication_mode            IN     BINARY_INTEGER DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_queue_table, NONE);

  PROCEDURE alter_queue_table(
        queue_table                 IN     VARCHAR2,
        comment                     IN     VARCHAR2       DEFAULT NULL,
        primary_instance            IN     BINARY_INTEGER DEFAULT NULL,
        secondary_instance          IN     BINARY_INTEGER DEFAULT NULL,
        replication_mode            IN     BINARY_INTEGER DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(alter_queue_table, NONE);

  PROCEDURE create_queue(
        queue_name                  IN     VARCHAR2,
        queue_table                 IN     VARCHAR2,
        queue_type                  IN     BINARY_INTEGER DEFAULT NORMAL_QUEUE,
        max_retries                 IN     NUMBER DEFAULT NULL,
        retry_delay                 IN     NUMBER DEFAULT 0,
        retention_time              IN     NUMBER DEFAULT 0,
        dependency_tracking         IN     BOOLEAN DEFAULT FALSE,
        comment                     IN     VARCHAR2 DEFAULT NULL,
        auto_commit                 IN     BOOLEAN DEFAULT TRUE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_queue, NONE);

  PROCEDURE create_np_queue(
        queue_name                  IN     VARCHAR2,
        multiple_consumers          IN     BOOLEAN DEFAULT FALSE,
        comment                     IN     VARCHAR2 DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_np_queue, NONE);

  PROCEDURE drop_queue(
        queue_name                  IN     VARCHAR2,
        auto_commit                 IN     BOOLEAN DEFAULT TRUE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(drop_queue, NONE);

  PROCEDURE drop_sharded_queue(
        queue_name                  IN     VARCHAR2,
        force                       IN     BOOLEAN DEFAULT FALSE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(drop_sharded_queue, NONE);

  PROCEDURE drop_queue_table(
        queue_table                 IN     VARCHAR2,
        force                       IN     BOOLEAN DEFAULT FALSE,
        auto_commit                 IN     BOOLEAN DEFAULT TRUE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(drop_queue_table, NONE);

  PROCEDURE start_queue(
        queue_name                  IN     VARCHAR2,
        enqueue                     IN     BOOLEAN DEFAULT TRUE,
        dequeue                     IN     BOOLEAN DEFAULT TRUE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(start_queue, NONE);
 
  PROCEDURE stop_queue(
        queue_name                  IN     VARCHAR2,
        enqueue                     IN     BOOLEAN DEFAULT TRUE,
        dequeue                     IN     BOOLEAN DEFAULT TRUE,
        wait                        IN     BOOLEAN DEFAULT TRUE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(stop_queue, NONE);

  PROCEDURE alter_queue(
        queue_name                  IN     VARCHAR2,
        max_retries                 IN     NUMBER   DEFAULT NULL,
        retry_delay                 IN     NUMBER   DEFAULT NULL,
        retention_time              IN     NUMBER   DEFAULT NULL,
        auto_commit                 IN     BOOLEAN  DEFAULT TRUE,
        comment                     IN     VARCHAR2 DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(alter_queue, NONE);

  PROCEDURE add_subscriber(
        queue_name                  IN     VARCHAR2,
        subscriber                  IN     SYS.AQ$_AGENT,
        rule                        IN     VARCHAR2 DEFAULT NULL,
        transformation              IN     VARCHAR2 DEFAULT NULL,
        queue_to_queue              IN     BOOLEAN  DEFAULT FALSE,
        delivery_mode               IN     PLS_INTEGER 
                                           DEFAULT PERSISTENT);
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_subscriber, NONE);

  -- for backward compatibility
  PROCEDURE alter_subscriber(
        queue_name                  IN     VARCHAR2,
        subscriber                  IN     SYS.AQ$_AGENT,
        rule                        IN     VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(alter_subscriber, NONE);

  PROCEDURE alter_subscriber(
        queue_name                  IN     VARCHAR2,
        subscriber                  IN     SYS.AQ$_AGENT,
        rule                        IN     VARCHAR2,
        transformation              IN     VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(alter_subscriber, NONE);

  PROCEDURE remove_subscriber(
        queue_name                  IN     VARCHAR2,
        subscriber                  IN     SYS.AQ$_AGENT);
  PRAGMA SUPPLEMENTAL_LOG_DATA(remove_subscriber, NONE);

  PROCEDURE grant_type_access(
        user_name               IN      VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(grant_type_access, AUTO);

  FUNCTION queue_subscribers(
        queue_name              IN      VARCHAR2)
        RETURN aq$_subscriber_list_t;

  PROCEDURE grant_queue_privilege(
        privilege               IN      VARCHAR2,
        queue_name              IN      VARCHAR2,
        grantee                 IN      VARCHAR2,
        grant_option            IN      BOOLEAN := FALSE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(grant_queue_privilege, NONE);

  PROCEDURE grant_system_privilege(
        privilege               IN      VARCHAR2,
        grantee                 IN      VARCHAR2,
        admin_option            IN      BOOLEAN := FALSE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(grant_system_privilege, AUTO);

  PROCEDURE revoke_queue_privilege(
        privilege               IN      VARCHAR2,
        queue_name              IN      VARCHAR2,
        grantee                 IN      VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(revoke_queue_privilege, NONE );

  PROCEDURE revoke_system_privilege(
        privilege               IN      VARCHAR2,
        grantee                 IN      VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(revoke_system_privilege, AUTO);

  PROCEDURE get_type_info(
        schema                      IN     VARCHAR2,
        qname                       IN     VARCHAR2,
        gettds                      IN     BOOLEAN,
        rc                          OUT    BINARY_INTEGER,
        toid                        OUT    RAW,
        version                     OUT    NUMBER,
        tds                         OUT    LONG RAW, 
        queue_style                 OUT    VARCHAR2,
        network_name                OUT    VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(get_type_info, NONE);

  PROCEDURE get_type_info(
        schema                      IN     VARCHAR2,
        qname                       IN     VARCHAR2,
        gettds                      IN     BOOLEAN,
        rc                          OUT    BINARY_INTEGER,
        toid                        OUT    RAW,
        version                     OUT    NUMBER,
        tds                         OUT    LONG RAW);
  PRAGMA SUPPLEMENTAL_LOG_DATA(get_type_info, NONE);

  PROCEDURE verify_queue_types(
        src_queue_name  IN      VARCHAR2,
        dest_queue_name IN      VARCHAR2,
        destination     IN      VARCHAR2 DEFAULT NULL,
        rc              OUT     BINARY_INTEGER,
        transformation  IN      VARCHAR2 DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(verify_queue_types, NONE);

  FUNCTION isShardedQueue(
        schema                       IN     VARCHAR2,
        qname                        IN     VARCHAR2) RETURN NUMBER ;

  PROCEDURE verify_sharded_queue (
                src_schema_name  IN      VARCHAR2,
                dest_queue_name IN      VARCHAR2,
                destination     IN      VARCHAR2,
                rc              OUT     NUMBER) ;

  PROCEDURE verify_queue_types_no_queue(
        src_queue_name  IN      VARCHAR2,
        dest_queue_name IN      VARCHAR2,
        destination     IN      VARCHAR2 DEFAULT NULL,
        rc              OUT     BINARY_INTEGER,
        transformation  IN      VARCHAR2 DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(verify_queue_types_no_queue, NONE);

  PROCEDURE verify_queue_types_get_nrp(
        src_queue_name  IN      VARCHAR2,
        dest_queue_name IN      VARCHAR2,
        destination     IN      VARCHAR2 DEFAULT NULL,
        rc              OUT     BINARY_INTEGER,
        transformation  IN      VARCHAR2 DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(verify_queue_types_get_nrp, NONE);

  PROCEDURE get_prop_seqno(qid    IN    NUMBER, 
                           dqname IN    VARCHAR2,
                           dbname IN    VARCHAR2,
                           seq    OUT   BINARY_INTEGER);
  PRAGMA SUPPLEMENTAL_LOG_DATA(get_prop_seqno, NONE);

  PROCEDURE recover_propagation(
        schema          IN      VARCHAR2,
        queue_name      IN      VARCHAR2,
        destination     IN      VARCHAR2,
        protocol        IN      BINARY_INTEGER default TTC,
        url             IN      VARCHAR2 default NULL,
        username        IN      VARCHAR2 default NULL,
        passwd          IN      VARCHAR2 default NULL,
        trace           IN      BINARY_INTEGER default 0,
        destq           IN      BINARY_INTEGER default 0);
   PRAGMA SUPPLEMENTAL_LOG_DATA(recover_propagation, NONE);

  PROCEDURE schedule_propagation(
    queue_name                  IN     VARCHAR2,
    destination                 IN     VARCHAR2 DEFAULT NULL,
    start_time                  IN     TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    duration                    IN     NUMBER DEFAULT NULL,
    next_time                   IN     VARCHAR2 DEFAULT NULL,
    latency                     IN     NUMBER DEFAULT 60,
    destination_queue           IN     VARCHAR2 DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(schedule_propagation, NONE);

  PROCEDURE unschedule_propagation(
        queue_name                  IN     VARCHAR2,
        destination                 IN     VARCHAR2 DEFAULT NULL,
        destination_queue           IN     VARCHAR2 DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(unschedule_propagation, NONE);

  PROCEDURE alter_propagation_schedule(
        queue_name                  IN     VARCHAR2,
        destination                 IN     VARCHAR2 DEFAULT NULL,
        duration                    IN     NUMBER DEFAULT NULL,
        next_time                   IN     VARCHAR2 DEFAULT NULL,
        latency                     IN     NUMBER DEFAULT 60,
        destination_queue           IN     VARCHAR2 DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(alter_propagation_schedule, NONE);

  PROCEDURE enable_propagation_schedule(
        queue_name                  IN     VARCHAR2,
        destination                 IN     VARCHAR2 DEFAULT NULL,
        destination_queue           IN     VARCHAR2 DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(enable_propagation_schedule, NONE);

  PROCEDURE disable_propagation_schedule(
        queue_name                  IN     VARCHAR2,
        destination                 IN     VARCHAR2 DEFAULT NULL,
        destination_queue           IN     VARCHAR2 DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(disable_propagation_schedule, NONE);

  FUNCTION aq$_propaq(
        job                         IN     NUMBER) RETURN DATE;

  -- aq$_propaq is overloaded with 8.0.5 interface to facilitate
  -- upgrade/downgrade
  FUNCTION aq$_propaq(
        job                         IN     NUMBER,
        next_date                   IN     DATE,
        qname                       IN     VARCHAR2,
        schema                      IN     VARCHAR2,
        destination                 IN     VARCHAR2 DEFAULT NULL,
        toid_char                   IN     VARCHAR2 DEFAULT NULL,
        version_char                IN     VARCHAR2 DEFAULT NULL,
        start_time                  IN     VARCHAR2,            
        duration                    IN     VARCHAR2 DEFAULT NULL,
        next_time                   IN     VARCHAR2 DEFAULT NULL,
        latency                     IN     VARCHAR2 DEFAULT '60') RETURN DATE;

  PROCEDURE start_time_manager;
  PRAGMA SUPPLEMENTAL_LOG_DATA(start_time_manager, NONE);

  PROCEDURE stop_time_manager;
  PRAGMA SUPPLEMENTAL_LOG_DATA(stop_time_manager, NONE);

  PROCEDURE migrate_queue_table( 
         queue_table               IN      VARCHAR2,
         compatible                IN      VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(migrate_queue_table, NONE);

  -- non-repudiate sender of ADT payload
  PROCEDURE nonrepudiate_sender(
         queue_name                IN      VARCHAR2,
         msgid                     IN      RAW,
         sender_info               IN      SYS.AQ$_AGENT,
         signature                 OUT     SYS.AQ$_SIG_PROP,
         payload                   OUT     "<ADT_1>");
  PRAGMA SUPPLEMENTAL_LOG_DATA(nonrepudiate_sender, NONE);

  -- non-repudiate sender of raw payload
  PROCEDURE nonrepudiate_sender(
         queue_name                IN      VARCHAR2,
         msgid                     IN      RAW,
         sender_info               IN      SYS.AQ$_AGENT,
         signature                 OUT     SYS.AQ$_SIG_PROP,
         payload                   OUT     raw);
  PRAGMA SUPPLEMENTAL_LOG_DATA(nonrepudiate_sender, NONE);

  PROCEDURE nonrepudiate_receiver(
         queue_name                IN      VARCHAR2,
         msgid                     IN      RAW,
         rcver_info                IN      SYS.AQ$_AGENT,
         signature                 OUT     SYS.AQ$_SIG_PROP,
         payload                   OUT     "<ADT_1>");
  PRAGMA SUPPLEMENTAL_LOG_DATA(nonrepudiate_receiver, NONE);

  PROCEDURE nonrepudiate_receiver(
         queue_name                IN      VARCHAR2,
         msgid                     IN      RAW,
         rcver_info                IN      SYS.AQ$_AGENT,
         signature                 OUT     SYS.AQ$_SIG_PROP,
         payload                   OUT     raw);
  PRAGMA SUPPLEMENTAL_LOG_DATA(nonrepudiate_receiver, NONE);

  PROCEDURE set_watermark(
         wmvalue                   IN      NUMBER);
  PRAGMA SUPPLEMENTAL_LOG_DATA(set_watermark, NONE);

  PROCEDURE get_watermark(
         wmvalue                   OUT     NUMBER);
  PRAGMA SUPPLEMENTAL_LOG_DATA(get_watermark, NONE);

  -- add an alias to LDAP
  PROCEDURE add_alias_to_ldap(
            alias               IN          VARCHAR2,
            obj_location        IN          VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_alias_to_ldap, NONE);
  
  -- drop an alias from LDAP
  PROCEDURE del_alias_from_ldap(
            alias               IN          VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(del_alias_from_ldap, NONE);

  -- AQ Authorization management procedures
  PROCEDURE create_aq_agent (
            agent_name                IN VARCHAR2,
            certificate_location      IN VARCHAR2 DEFAULT NULL,
            enable_http               IN BOOLEAN DEFAULT FALSE,
            enable_smtp               IN BOOLEAN DEFAULT FALSE,
            enable_anyp               IN BOOLEAN DEFAULT FALSE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_aq_agent, AUTO);

  PROCEDURE alter_aq_agent(
            agent_name                IN VARCHAR2,
            certificate_location      IN VARCHAR2 DEFAULT NULL,
            enable_http               IN BOOLEAN DEFAULT FALSE,
            enable_smtp               IN BOOLEAN DEFAULT FALSE,
            enable_anyp               IN BOOLEAN DEFAULT FALSE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(alter_aq_agent, AUTO);

  PROCEDURE drop_aq_agent (
            agent_name       IN VARCHAR2 );
  PRAGMA SUPPLEMENTAL_LOG_DATA(drop_aq_agent, AUTO);

  PROCEDURE enable_db_access (
            agent_name                IN VARCHAR2,
            db_username               IN VARCHAR2   );
  PRAGMA SUPPLEMENTAL_LOG_DATA(enable_db_access, AUTO);

  PROCEDURE disable_db_access (
            agent_name                IN VARCHAR2,
            db_username               IN VARCHAR2   );
  PRAGMA SUPPLEMENTAL_LOG_DATA(disable_db_access, AUTO);

  -- enable jms types IN anydata queue tables
  PROCEDURE enable_jms_types(
            queue_table          IN VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(enable_jms_types, NONE);
    
  -- add a connection string to LDAP directory
  PROCEDURE add_connection_to_ldap(
            connection          IN       VARCHAR2,
            host                IN       VARCHAR2,
            port                IN       BINARY_INTEGER,
            sid                 IN       VARCHAR2,
            driver              IN       VARCHAR2 default NULL,
            type                IN       BINARY_INTEGER DEFAULT 
                                         AQ_QUEUE_CONNECTION);
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_connection_to_ldap, NONE);

  -- add a connection string to LDAP directory
  PROCEDURE add_connection_to_ldap(
            connection          IN       VARCHAR2,
            jdbc_string         IN       VARCHAR2,
            username            IN       VARCHAR2 default NULL,
            password            IN       VARCHAR2 default NULL,
            type                IN       BINARY_INTEGER DEFAULT 
                                         AQ_QUEUE_CONNECTION);  
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_connection_to_ldap, NONE);

  -- drop a connection string from LDAP directory
  PROCEDURE del_connection_from_ldap(
            connection          IN          VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(del_connection_from_ldap, NONE);

  -- purge queue table
  PROCEDURE purge_queue_table(
            queue_table         IN        VARCHAR2,
            purge_condition     IN        VARCHAR2,
            purge_options       IN        aq$_purge_options_t);
  PRAGMA SUPPLEMENTAL_LOG_DATA(purge_queue_table, NONE);

  -- get a sender's replay info
  PROCEDURE get_replay_info(
            queue_name               IN      VARCHAR2,
            sender_agent             IN      sys.aq$_agent,
            replay_attribute         IN      BINARY_INTEGER,
            correlation              OUT     VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(get_replay_info, NONE);

  -- reset sender's replay info
  PROCEDURE reset_replay_info(
            queue_name               IN      VARCHAR2,
            sender_agent             IN      sys.aq$_agent,
            replay_attribute         IN      BINARY_INTEGER); 
  PRAGMA SUPPLEMENTAL_LOG_DATA(reset_replay_info, NONE);
                              
  -- Add procedures to set and get minimum/maximum AQ streams pool memory
  PROCEDURE set_min_streams_pool( value    IN    NUMBER);
  PROCEDURE set_max_streams_pool( value    IN    NUMBER);

  PROCEDURE get_min_streams_pool( value    OUT   NUMBER);
  PROCEDURE get_max_streams_pool( value    OUT   NUMBER);


END dbms_aqadm;
/


@?/rdbms/admin/sqlsessend.sql
