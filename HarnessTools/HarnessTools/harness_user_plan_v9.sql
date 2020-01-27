rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 

rem Called by harness_user_install_v9.sql
rem



rem Modify the path as needed.  Each user needs their own plan_table.
rem --@$ORACLE_HOME\rdbms\admin\utlxplan
rem 9i PLAN_TABLE

drop table plan_table ;
create table PLAN_TABLE (
	statement_id 		varchar2(30),
	timestamp    		date,
	remarks      		varchar2(80),
	operation    		varchar2(30),
	options       		varchar2(255),
	object_node  		varchar2(128),
	object_owner 		varchar2(30),
	object_name  		varchar2(30),
	object_instance 	numeric,
	object_type     	varchar2(30),
	optimizer       	varchar2(255),
	search_columns  	number,
	id					numeric,
	parent_id			numeric,
	position			numeric,
	cost				numeric,
	cardinality			numeric,
	bytes				numeric,
	other_tag       	varchar2(255),
	partition_start 	varchar2(255),
    partition_stop  	varchar2(255),
    partition_id    	numeric,
	other				long,
	distribution    	varchar2(30),
	cpu_cost			numeric,
	io_cost				numeric,
	temp_space			numeric,
    access_predicates 	varchar2(4000),
    filter_predicates 	varchar2(4000));

    
rem The following tables MUST be created for harness use.

rem Plan Table copy for scenario plans    

drop table hscenario_plan_table;
create table HSCENARIO_PLAN_TABLE (
    hscenario_id	    number,
	statement_id 		varchar2(30),
	timestamp    		date,
	remarks      		varchar2(80),
	operation    		varchar2(30),
	options       		varchar2(255),
	object_node  		varchar2(128),
	object_owner 		varchar2(30),
	object_name  		varchar2(30),
	object_instance 	numeric,
	object_type     	varchar2(30),
	optimizer       	varchar2(255),
	search_columns  	number,
	id					numeric,
	parent_id			numeric,
	position			numeric,
	cost				numeric,
	cardinality			numeric,
	bytes				numeric,
	other_tag       	varchar2(255),
	partition_start 	varchar2(255),
    partition_stop  	varchar2(255),
    partition_id    	numeric,
	other				long,
	distribution    	varchar2(30),
	cpu_cost			numeric,
	io_cost				numeric,
	temp_space			numeric,
    access_predicates 	varchar2(4000),
    filter_predicates 	varchar2(4000),
	constraint HSCENARIO_PLAN_TABLE_PK primary key (hscenario_id, id)
);

rem Plan Table copy for v$sql_plan_statistics_all snapshot for scenarios 
   
drop table hscenario_v$sql_all;
create table hscenario_v$sql_all (
    hscenario_id	    number,
    hash_value		    number,
    address				raw(4),
	statement_id 		varchar2(30),
	timestamp    		date,
	remarks      		varchar2(80),
	operation    		varchar2(30),
	options       		varchar2(255),
	object_node  		varchar2(128),
	object_owner 		varchar2(30),
	object_name  		varchar2(30),
	object_instance 	numeric,
	object_type     	varchar2(30),
	optimizer       	varchar2(255),
	search_columns  	number,
	id					numeric,
	parent_id			numeric,
	depth				numeric,
	position			numeric,
	cost				numeric,
	cardinality			numeric,
	bytes				numeric,
	other_tag       	varchar2(255),
	partition_start 	varchar2(255),
    partition_stop  	varchar2(255),
    partition_id    	numeric,
	other				long,
	distribution    	varchar2(30),
	cpu_cost			numeric,
	io_cost				numeric,
	temp_space			numeric,
    access_predicates 	varchar2(4000),
    filter_predicates 	varchar2(4000),
    EXECUTIONS                      numeric,
	LAST_STARTS                     numeric,
	STARTS                          numeric,
	LAST_OUTPUT_ROWS                numeric,
	OUTPUT_ROWS                     numeric,
	LAST_CR_BUFFER_GETS             numeric,
	CR_BUFFER_GETS                  numeric,
	LAST_CU_BUFFER_GETS             numeric,
	CU_BUFFER_GETS                  numeric,
	LAST_DISK_READS                 numeric,
	DISK_READS                      numeric,
	LAST_DISK_WRITES                numeric,
	DISK_WRITES                     numeric,
	LAST_ELAPSED_TIME               numeric,
	ELAPSED_TIME                    numeric,
	POLICY                          VARCHAR2(10),
	ESTIMATED_OPTIMAL_SIZE          numeric,
	ESTIMATED_ONEPASS_SIZE          numeric,
	LAST_MEMORY_USED                numeric,
	LAST_EXECUTION                  VARCHAR2(10),
	LAST_DEGREE                     numeric,
	TOTAL_EXECUTIONS                numeric,
	OPTIMAL_EXECUTIONS              numeric,
	ONEPASS_EXECUTIONS              numeric,
	MULTIPASSES_EXECUTIONS          numeric,
	ACTIVE_TIME                     numeric,
	MAX_TEMPSEG_SIZE                numeric,
	LAST_TEMPSEG_SIZE               numeric  );

drop view hscenario_sqlplan;	    	
create or replace view hscenario_sqlplan as
 select statement_id, timestamp, remarks, OPERATION, OPTIONS, OBJECT_NODE, 
		OBJECT_OWNER, OBJECT_NAME, object_instance, object_type, OPTIMIZER, SEARCH_COLUMNS, 
		ID, PARENT_ID, DEPTH, POSITION, COST, CARDINALITY, BYTES, OTHER_TAG, 
		PARTITION_START, PARTITION_STOP, PARTITION_ID, OTHER, DISTRIBUTION, 
		CPU_COST, IO_COST, TEMP_SPACE, ACCESS_PREDICATES, FILTER_PREDICATES 	 
   from hscenario_v$sql_all ;
	
