rem $Header$
rem $Name$

rem Copyright (c); 2006-2011 by Hotsos Enterprises, Ltd.
rem 

rem Called by harness_user_install_v10r2.sql
rem


rem Modify or remove the plan definition if needed.  
rem --@$ORACLE_HOME\rdbms\admin\utlxplan
rem 10r2 PLAN_TABLE

drop table PLAN_TABLE ;

create table PLAN_TABLE (
        statement_id       varchar2(30),
        plan_id            number,
        timestamp          date,
        remarks            varchar2(4000),
        operation          varchar2(30),
        options            varchar2(255),
        object_node        varchar2(128),
        object_owner       varchar2(30),
        object_name        varchar2(30),
        object_alias       varchar2(65),
        object_instance    numeric,
        object_type        varchar2(30),
        optimizer          varchar2(255),
        search_columns     number,
        id                 numeric,
        parent_id          numeric,
        depth              numeric,
        position           numeric,
        cost               numeric,
        cardinality        numeric,
        bytes              numeric,
        other_tag          varchar2(255),
        partition_start    varchar2(255),
        partition_stop     varchar2(255),
        partition_id       numeric,
        other              long,
        distribution       varchar2(30),
        cpu_cost           numeric,
        io_cost            numeric,
        temp_space         numeric,
        access_predicates  varchar2(4000),
        filter_predicates  varchar2(4000),
        projection         varchar2(4000),
        time               numeric,
        qblock_name        varchar2(30),
        other_xml          clob
);


rem The following tables MUST be created for harness use

rem Plan Table copy for scenario plans 
   
drop table hscenario_plan_table;
create table HSCENARIO_PLAN_TABLE (
    hscenario_id	   number,
    statement_id       varchar2(30),
    plan_id            number,
    timestamp          date,
    remarks            varchar2(4000),
    operation          varchar2(30),
    options            varchar2(255),
    object_node        varchar2(128),
    object_owner       varchar2(30),
    object_name        varchar2(30),
    object_alias       varchar2(65),
    object_instance    numeric,
    object_type        varchar2(30),
    optimizer          varchar2(255),
    search_columns     number,
    id                 numeric,
    parent_id          numeric,
    depth              numeric,
    position           numeric,
    cost               numeric,
    cardinality        numeric,
    bytes              numeric,
    other_tag          varchar2(255),
    partition_start    varchar2(255),
    partition_stop     varchar2(255),
    partition_id       numeric,
    other              long,
    distribution       varchar2(30),
    cpu_cost           numeric,
    io_cost            numeric,
    temp_space         numeric,
    access_predicates  varchar2(4000),
    filter_predicates  varchar2(4000),
    projection         varchar2(4000),
    time               numeric,
    qblock_name        varchar2(30),
    other_xml          clob,
	constraint HSCENARIO_PLAN_TABLE_PK primary key (hscenario_id, id)
);

rem Plan Table copy for v$sql_plan_statistics_all snapshot for scenarios   
 
drop table hscenario_v$sql_all;
create table hscenario_v$sql_all (
 hscenario_id	   number,
 statement_id 		varchar2(30),
 ADDRESS                                            RAW(4),
 HASH_VALUE                                         NUMBER,
 SQL_ID                                             VARCHAR2(13),
 PLAN_HASH_VALUE                                    NUMBER,
 CHILD_NUMBER                                       NUMBER,
 OPERATION                                          VARCHAR2(30),
 OPTIONS                                            VARCHAR2(30),
 OBJECT_NODE                                        VARCHAR2(40),
 OBJECT#                                            NUMBER,
 OBJECT_OWNER                                       VARCHAR2(30),
 OBJECT_NAME                                        VARCHAR2(31),
 OBJECT_ALIAS                                       VARCHAR2(65),
 OBJECT_TYPE                                        VARCHAR2(20),
 OPTIMIZER                                          VARCHAR2(20),
 ID                                                 NUMBER,
 PARENT_ID                                          NUMBER,
 DEPTH                                              NUMBER,
 POSITION                                           NUMBER,
 SEARCH_COLUMNS                                     NUMBER,
 COST                                               NUMBER,
 CARDINALITY                                        NUMBER,
 BYTES                                              NUMBER,
 OTHER_TAG                                          VARCHAR2(35),
 PARTITION_START                                    VARCHAR2(5),
 PARTITION_STOP                                     VARCHAR2(5),
 PARTITION_ID                                       NUMBER,
 OTHER                                              VARCHAR2(4000),
 DISTRIBUTION                                       VARCHAR2(20),
 CPU_COST                                           NUMBER,
 IO_COST                                            NUMBER,
 TEMP_SPACE                                         NUMBER,
 ACCESS_PREDICATES                                  VARCHAR2(4000),
 FILTER_PREDICATES                                  VARCHAR2(4000),
 PROJECTION                                         VARCHAR2(4000),
 TIME                                               NUMBER,
 QBLOCK_NAME                                        VARCHAR2(31),
 REMARKS                                            VARCHAR2(4000),
 EXECUTIONS                                         NUMBER,
 LAST_STARTS                                        NUMBER,
 STARTS                                             NUMBER,
 LAST_OUTPUT_ROWS                                   NUMBER,
 OUTPUT_ROWS                                        NUMBER,
 LAST_CR_BUFFER_GETS                                NUMBER,
 CR_BUFFER_GETS                                     NUMBER,
 LAST_CU_BUFFER_GETS                                NUMBER,
 CU_BUFFER_GETS                                     NUMBER,
 LAST_DISK_READS                                    NUMBER,
 DISK_READS                                         NUMBER,
 LAST_DISK_WRITES                                   NUMBER,
 DISK_WRITES                                        NUMBER,
 LAST_ELAPSED_TIME                                  NUMBER,
 ELAPSED_TIME                                       NUMBER,
 POLICY                                             VARCHAR2(10),
 ESTIMATED_OPTIMAL_SIZE                             NUMBER,
 ESTIMATED_ONEPASS_SIZE                             NUMBER,
 LAST_MEMORY_USED                                   NUMBER,
 LAST_EXECUTION                                     VARCHAR2(10),
 LAST_DEGREE                                        NUMBER,
 TOTAL_EXECUTIONS                                   NUMBER,
 OPTIMAL_EXECUTIONS                                 NUMBER,
 ONEPASS_EXECUTIONS                                 NUMBER,
 MULTIPASSES_EXECUTIONS                             NUMBER,
 ACTIVE_TIME                                        NUMBER,
 MAX_TEMPSEG_SIZE                                   NUMBER,
 LAST_TEMPSEG_SIZE                                  NUMBER,
 constraint hscenario_v$sql_all_pk primary key (hscenario_id, sql_id, id)
 );
	
