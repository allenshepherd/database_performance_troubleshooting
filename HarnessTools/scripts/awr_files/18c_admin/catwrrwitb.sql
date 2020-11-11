Rem
Rem $Header: rdbms/admin/catwrrwitb.sql /main/5 2014/02/20 12:45:55 surman Exp $
Rem
Rem catwrrwitb.sql
Rem
Rem Copyright (c) 2011, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catwrrwitb.sql - Catalog script for the tables required for workload
Rem                       intelligence
Rem
Rem
Rem    DESCRIPTION
Rem      It creates all the tables required for workload intelligence
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catwrrwitb.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catwrrwitb.sql
Rem SQL_PHASE: CATWRRWITB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catwrrtb.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      04/12/12 - 13615447: Add SQL patching tags
Rem    kmorfoni    03/09/12 - Add missing foreign key
Rem    kmorfoni    11/03/11 - Minor changes
Rem    kmorfoni    06/15/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem %%%%%%%
Rem WI$_JOB
Rem %%%%%%%
Rem
Rem Table that stores information about jobs in workload intelligence
Rem
create table WI$_JOB
( jobId   NUMBER         not null
 ,jobName VARCHAR2(128)  not null
 ,path    VARCHAR2(4000) not null
 ,constraint WI$_JOB_PK primary key (jobId)
 ,constraint WI$_JOB_UK_1 unique(jobName)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%
Rem WI$_TEMPLATE
Rem %%%%%%%%%%%%
Rem
Rem Table that stores information about templates in workload intelligence
Rem
create table WI$_TEMPLATE
( jobId         NUMBER  not null
 ,templateId    NUMBER  not null
 ,isTransaction CHAR(1) not null
 ,constraint WI$_TEMPLATE_PK primary key (jobId, templateId)
 ,constraint WI$_TEMPLATE_FK1 foreign key (jobId)
     references WI$_JOB on delete cascade
) tablespace SYSAUX
/
  
Rem %%%%%%%%%%%%%
Rem WI$_STATEMENT
Rem %%%%%%%%%%%%%
Rem
Rem Table that stores information about statements in workload intelligence
Rem
create table WI$_STATEMENT
( jobId      NUMBER not null
 ,templateId NUMBER not null
 ,sqlText    CLOB   not null
 ,rank       NUMBER not null
 ,constraint WI$_STATEMENT_PK primary key (jobId, templateId, rank)
 ,constraint WI$_STATEMENT_FK1 foreign key (jobId, templateId)
     references WI$_TEMPLATE on delete cascade
) tablespace SYSAUX
/

Rem %%%%%%%%%%
Rem WI$_OBJECT
Rem %%%%%%%%%%
Rem
Rem Table that stores information about objects in workload intelligence
Rem
create table WI$_OBJECT
( jobId      NUMBER      not null
 ,templateId NUMBER      not null
 ,objectId   NUMBER      not null
 ,accessType VARCHAR2(2) not null
 ,constraint WI$_OBJECT_PK primary key (jobId, templateId, objectId)
 ,constraint WI$_OBJECT_FK1 foreign key (jobId, templateId)
     references WI$_TEMPLATE on delete cascade
) tablespace SYSAUX
/
  
Rem %%%%%%%%%%%%%%%%
Rem WI$_CAPTURE_FILE
Rem %%%%%%%%%%%%%%%%
Rem
Rem Table that stores information about capture files in workload intelligence
Rem
create table WI$_CAPTURE_FILE
( jobId  NUMBER         not null
 ,fileId NUMBER         not null
 ,path   VARCHAR2(4000) not null
 ,constraint WI$_CAPTURE_FILE_PK primary key (jobId, fileId)
 ,constraint WI$_CAPTURE_FILE_FK1 foreign key (jobId)
     references WI$_JOB on delete cascade
) tablespace SYSAUX
/
  
Rem %%%%%%%%%%%%%%%%%%%
Rem WI$_EXECUTION_ORDER
Rem %%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores information about the order of executed templates in
Rem workload intelligence
Rem
create table WI$_EXECUTION_ORDER
( jobId      NUMBER not null
 ,fileId     NUMBER not null
 ,rank       NUMBER not null
 ,templateId NUMBER not null
 ,dbTime     NUMBER not null
 ,constraint WI$_EXECUTION_ORDER_PK primary key (jobId, fileId, rank)
 ,constraint WI$_EXECUTION_ORDER_FK1 foreign key (jobId, fileId)
     references WI$_CAPTURE_FILE on delete cascade
 ,constraint WI$_EXECUTION_ORDER_FK2 foreign key (jobId, templateId)
     references WI$_TEMPLATE on delete cascade
) tablespace SYSAUX
/
  
Rem %%%%%%%%%%%%%%%%%%%%
Rem WI$_FREQUENT_PATTERN
Rem %%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores information about frequent patterns in workload
Rem intelligence
Rem
create table WI$_FREQUENT_PATTERN
( jobId              NUMBER not null
 ,patternId          NUMBER not null
 ,length             NUMBER not null
 ,numberOfExecutions NUMBER not null
 ,dbTime             NUMBER not null
 ,constraint WI$_FREQUENT_PATTERN_PK primary key (jobId, patternId)
 ,constraint WI$_FREQUENT_PATTERN_FK1 foreign key (jobId)
     references WI$_JOB on delete cascade
) tablespace SYSAUX
/
  
Rem %%%%%%%%%%%%%%%%%%%%%%%%%
Rem WI$_FREQUENT_PATTERN_ITEM
Rem %%%%%%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores information about the templates that constitute a frequent
Rem pattern in workload intelligence
Rem
create table WI$_FREQUENT_PATTERN_ITEM
( jobId         NUMBER  not null
 ,patternId     NUMBER  not null
 ,rank          NUMBER  not null
 ,templateId    NUMBER  not null
 ,isFirstInLoop CHAR(1) not null
 ,isLastInloop  CHAR(1) not null
 ,constraint WI$_FREQUENT_PATTERN_ITEM_PK primary key (jobId, patternId, rank)
 ,constraint WI$_FREQUENT_PATTERN_ITEM_FK1 foreign key (jobId, patternId)
     references WI$_FREQUENT_PATTERN on delete cascade
 ,constraint WI$_FREQUENT_PATTERN_ITEM_FK2 foreign key (jobId, templateId)
     references WI$_TEMPLATE on delete cascade
) tablespace SYSAUX
/
  
Rem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rem WI$_FREQUENT_PATTERN_METADATA
Rem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores metadata about the  frequent patterns in workload
Rem intelligence
Rem
create table WI$_FREQUENT_PATTERN_METADATA
( jobId      NUMBER not null
 ,modelOrder NUMBER not null
 ,threshold  NUMBER not null
 ,constraint WI$_FREQ_PATTERN_METADATA_PK primary key (jobId)
 ,constraint WI$_FREQ_PATTERN_METADATA_FK1 foreign key (jobId)
     references WI$_JOB on delete cascade
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%
Rem WI$_JOB_ID
Rem %%%%%%%%%%%%%%%%%
Rem
Rem Sequence to generate WI$_JOB.jobId
Rem
create sequence WI$_JOB_ID
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

@?/rdbms/admin/sqlsessend.sql
