Rem
Rem $Header: rdbms/admin/catwrrwivw.sql /main/5 2014/02/20 12:45:44 surman Exp $
Rem
Rem catwrrwivw.sql
Rem
Rem Copyright (c) 2011, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catwrrwivw.sql - Catalog script for the tables required for workload
Rem                       intelligence
Rem
Rem    DESCRIPTION
Rem      It creates all the views required for workload intelligence
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catwrrwivw.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catwrrwivw.sql
Rem SQL_PHASE: CATWRRWIVW
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catwrrvw.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      04/16/12 - 13615447: Add SQL patching tags
Rem    kmorfoni    03/09/12 - Change isSimple to isTransaction
Rem    kmorfoni    11/03/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem =========================================================
Rem Creating view DBA_WI_JOBS
Rem
Rem A row in this view describes a workload-intelligence job,
Rem i.e., a task that applies the algorithms of workload
Rem intelligence on a given capture directory.
Rem
Rem JOB_ID: the job identifier
Rem JOB_NAME: a name that uniquely identifies the given job
Rem CAPTURE_DIRECTORY: path to the capture directory on which
Rem                    the given job has been applied
Rem MODEL_ORDER: the order of the markov model that describes
Rem              the workload associated with the current
Rem              job. If NULL, the corresponding order has
Rem              not been calculated yet
Rem THRESHOLD: a number in the range [0, 1] that represents
Rem            the threshold that the user has given as an
Rem            input parameter to the current job of workload
Rem            intelligence for the identification of
Rem            significant patterns. If NULL, the process of
Rem            pattern identification has not been initiated
Rem            yet
Rem =========================================================
Rem

create or replace view DBA_WI_JOBS
(JOB_ID,
 JOB_NAME,
 CAPTURE_DIRECTORY,
 MODEL_ORDER,
 THRESHOLD)
as
select j.jobid,
       j.jobname,
       j.path,
       m.modelorder,
       m.threshold
from wi$_job j,
     wi$_frequent_pattern_metadata m
where j.jobid = m.jobid (+)
/

create or replace public synonym DBA_WI_JOBS
   for sys.DBA_WI_JOBS;
grant select on DBA_WI_JOBS to select_catalog_role;



execute CDBView.create_cdbview(false,'SYS','DBA_WI_JOBS','CDB_WI_JOBS');
grant select on SYS.CDB_WI_JOBS to select_catalog_role
/
create or replace public synonym CDB_WI_JOBS for SYS.CDB_WI_JOBS
/

Rem =========================================================
Rem Creating view DBA_WI_TEMPLATES
Rem
Rem A row in this view describes a template that has been
Rem found in the workload that is related to the workload-
Rem intelligence job whose identifier is equal to JOB_ID.
Rem A template can represent either a simple query, or an
Rem entire transaction. Two queries in the given workload
Rem belong to the same template, if they exhibit trivial
Rem differences, e.g., if they contain different literal
Rem values, different bind variable names, different
Rem comments, or different white spaces.
Rem 
Rem JOB_ID: the identifier of the job in the workload of
Rem         which the given template has been found
Rem TEMPLATE_ID: the identifier of a template in a given job
Rem IS_TRANSACTION: flag that indicates whether the given
Rem template corresponds to a transaction or not
Rem =========================================================
Rem

create or replace view DBA_WI_TEMPLATES
(JOB_ID,
 TEMPLATE_ID,
 IS_TRANSACTION)
as
select jobid,
       templateid,
       istransaction
from wi$_template
/

create or replace public synonym DBA_WI_TEMPLATES
   for sys.DBA_WI_TEMPLATES;
grant select on DBA_WI_TEMPLATES to select_catalog_role;



execute CDBView.create_cdbview(false,'SYS','DBA_WI_TEMPLATES','CDB_WI_TEMPLATES');
grant select on SYS.CDB_WI_TEMPLATES to select_catalog_role
/
create or replace public synonym CDB_WI_TEMPLATES for SYS.CDB_WI_TEMPLATES
/

Rem =========================================================
Rem Creating view DBA_WI_STATEMENTS
Rem
Rem A row in this view describes a SQL statement that is part
Rem of the template with id TEMPLATE_ID, which  has been
Rem found in the workload that is related to the workload-
Rem intelligence job whose identifier is equal to JOB_ID.
Rem A template may consist of multiple statements, e.g., if
Rem represents a transaction. In this case, there is one row
Rem in this view for every one of these statements. These
Rem statements are ordered, based on the order defined by the
Rem corresponding transaction. Column SEQUENCE_NUMBER is used
Rem to describe this order.
Rem 
Rem JOB_ID: the identifier of the job in the workload of
Rem         which the given statement has been found
Rem TEMPLATE_ID: the identifier of the template in the given
Rem              job to which the current statement belongs
Rem SEQUENCE_NUMBER: a number that indicates the order of the
Rem                  current statement in the given template
Rem SQL_TEXT: the SQL text associated with the current
Rem           statement. Note that although multiple
Rem           SQLs can be classified to the same template,
Rem           we store only one row that represents them all.
Rem           This row corresponds to the first instance of
Rem           the given template that is found during parsing
Rem           of the workload.
Rem =========================================================
Rem

create or replace view DBA_WI_STATEMENTS
(JOB_ID,
 TEMPLATE_ID,
 SEQUENCE_NUMBER,
 SQL_TEXT)
as
select jobid,
       templateid,
       rank,
       sqltext
from wi$_statement
/

create or replace public synonym DBA_WI_STATEMENTS
   for sys.DBA_WI_STATEMENTS;
grant select on DBA_WI_STATEMENTS to select_catalog_role;



execute CDBView.create_cdbview(false,'SYS','DBA_WI_STATEMENTS','CDB_WI_STATEMENTS');
grant select on SYS.CDB_WI_STATEMENTS to select_catalog_role
/
create or replace public synonym CDB_WI_STATEMENTS for SYS.CDB_WI_STATEMENTS
/

Rem =========================================================
Rem Creating view DBA_WI_OBJECTS
Rem
Rem A row in this view represents a database object (table)
Rem that is accessed by the given template in the given
Rem workload-intelligence job
Rem 
Rem JOB_ID: the identifier of the job in the workload of
Rem         which the given object has been accessed
Rem TEMPLATE_ID: the identifier of the template in the given
Rem              job by which the current object has been
Rem              accessed
Rem OBJECT_ID: the identifier of the current object
Rem ACCESS_TYPE: A value that can be 'R' indicating that the
Rem              current object has been accessed for reading
Rem              by the given template, 'W' indicating that
Rem              the current object has been accessed for
Rem              writing by the given template, or 'RW'
Rem              indicating that the current object has been
Rem              accessed for both reading and writing by the
Rem              given template
Rem =========================================================
Rem

create or replace view DBA_WI_OBJECTS
(JOB_ID,
 TEMPLATE_ID,
 OBJECT_ID,
 ACCESS_TYPE)
as
select jobid,
       templateid,
       objectid,
       accesstype
from wi$_object
/

create or replace public synonym DBA_WI_OBJECTS
   for sys.DBA_WI_OBJECTS;
grant select on DBA_WI_OBJECTS to select_catalog_role;



execute CDBView.create_cdbview(false,'SYS','DBA_WI_OBJECTS','CDB_WI_OBJECTS');
grant select on SYS.CDB_WI_OBJECTS to select_catalog_role
/
create or replace public synonym CDB_WI_OBJECTS for SYS.CDB_WI_OBJECTS
/

Rem =========================================================
Rem Creating view DBA_WI_CAPTURE_FILES
Rem
Rem A row in this view represents a capture file that belongs
Rem to the workload analyzed in the current workload-
Rem intelligence job.
Rem 
Rem JOB_ID: the identifier of the job in the workload of
Rem         which the given capture file belongs
Rem FILE_ID: the identifier of the current capture file
Rem FILE_PATH: the path of the current capture fileRem 
Rem =========================================================
Rem

create or replace view DBA_WI_CAPTURE_FILES
(JOB_ID,
 FILE_ID,
 FILE_PATH)
as
select jobid,
       fileid,
       path
from wi$_capture_file
/

create or replace public synonym DBA_WI_CAPTURE_FILES
   for sys.DBA_WI_CAPTURE_FILES;
grant select on DBA_WI_CAPTURE_FILES to select_catalog_role;



execute CDBView.create_cdbview(false,'SYS','DBA_WI_CAPTURE_FILES','CDB_WI_CAPTURE_FILES');
grant select on SYS.CDB_WI_CAPTURE_FILES to select_catalog_role
/
create or replace public synonym CDB_WI_CAPTURE_FILES for SYS.CDB_WI_CAPTURE_FILES
/

Rem =========================================================
Rem Creating view DBA_WI_TEMPLATE_EXECUTIONS
Rem
Rem One row in this view represents an execution of a
Rem template in a capture that belongs to the workload that
Rem is associated with the current workload-intelligence job.
Rem 
Rem JOB_ID: the identifier of the job in the workload of
Rem         which the current execution of the given template
Rem         belongs
Rem CAPTURE_FILE_ID: the identifier of the capture file in
Rem                  which we found the current execution of
Rem                  the given template
Rem SEQUENCE_NUMBER: a number that indicates the order of the
Rem                  current execution in the given capture
Rem                  file
Rem TEMPLATE_ID: the identifier of the template that was
Rem              executed in the execution represented by the
Rem              current row
Rem DB_TIME: the time that the current execution consumed on
Rem          the database server
Rem =========================================================
Rem

create or replace view DBA_WI_TEMPLATE_EXECUTIONS
(JOB_ID,
 CAPTURE_FILE_ID,
 SEQUENCE_NUMBER,
 TEMPLATE_ID,
 DB_TIME)
as
select jobid,
       fileid,
       rank,
       templateid,
       dbtime
from wi$_execution_order
/

create or replace public synonym DBA_WI_TEMPLATE_EXECUTIONS
   for sys.DBA_WI_TEMPLATE_EXECUTIONS;
grant select on DBA_WI_TEMPLATE_EXECUTIONS to select_catalog_role;



execute CDBView.create_cdbview(false,'SYS','DBA_WI_TEMPLATE_EXECUTIONS','CDB_WI_TEMPLATE_EXECUTIONS');
grant select on SYS.CDB_WI_TEMPLATE_EXECUTIONS to select_catalog_role
/
create or replace public synonym CDB_WI_TEMPLATE_EXECUTIONS for SYS.CDB_WI_TEMPLATE_EXECUTIONS
/

Rem =========================================================
Rem Creating view DBA_WI_PATTERNS
Rem
Rem A row in this view represents a pattern that has been
Rem identified by workload intelligence as significant in the
Rem workload associated with the given job. Such a pattern
Rem consists of one or more templates. These templates that
Rem comprise the given pattern are described in the related
Rem view DBA_WI_PATTERN_ITEMS.
Rem 
Rem JOB_ID: the identifier of the job in the workload of
Rem         which the current pattern has been found
Rem PATTERN_ID: the identifier of the current pattern
Rem LENGTH: the length of the pattern, i.e., the number of
Rem         items (templates) it consists of
Rem NUMBER_OF_EXECUTIONS: the number of times the current
Rem                       pattern has been executed in the
Rem                       given workload
Rem DB_TIME: the total time consumed in the database server
Rem          by all the executions of the current pattern in
Rem          the given workload
Rem =========================================================
Rem

create or replace view DBA_WI_PATTERNS
(JOB_ID,
 PATTERN_ID,
 LENGTH,
 NUMBER_OF_EXECUTIONS,
 DB_TIME)
as
select jobid,
       patternid,
       length,
       numberOfExecutions,
       dbtime
from wi$_frequent_pattern
/

create or replace public synonym DBA_WI_PATTERNS
   for sys.DBA_WI_PATTERNS;
grant select on DBA_WI_PATTERNS to select_catalog_role;



execute CDBView.create_cdbview(false,'SYS','DBA_WI_PATTERNS','CDB_WI_PATTERNS');
grant select on SYS.CDB_WI_PATTERNS to select_catalog_role
/
create or replace public synonym CDB_WI_PATTERNS for SYS.CDB_WI_PATTERNS
/

Rem =========================================================
Rem Creating view DBA_WI_PATTERN_ITEMS
Rem
Rem A row in this view represents a template that
Rem participates in a significant pattern that has been found
Rem by the given workload-intelligence job.
Rem 
Rem JOB_ID: the identifier of the job in the workload of
Rem         which the current pattern has been found
Rem PATTERN_ID: the identifier of the pattern to which the
Rem             current item (i.e., template) belongs
Rem SEQUENCE_NUMBER: number that indicates the position of
Rem                  the current item in the given pattern
Rem TEMPLATE_ID: the identifier of the template that
Rem              participates in the given position of the
Rem              current pattern
Rem IS_FIRST_IN_LOOP: a flag that indicates whether or not
Rem                   the current item marks the beginning of
Rem                   a loop in the given pattern
Rem IS_LAST_IN_LOOP: a flag that indicates whether or not the
Rem                  current item marks the end of a loop in
Rem                  the given pattern
Rem =========================================================
Rem

create or replace view DBA_WI_PATTERN_ITEMS
(JOB_ID,
 PATTERN_ID,
 SEQUENCE_NUMBER,
 TEMPLATE_ID,
 IS_FIRST_IN_LOOP,
 IS_LAST_IN_LOOP)
as
select jobid,
       patternid,
       rank,
       templateid,
       isfirstinloop,
       islastinloop
from wi$_frequent_pattern_item
/

create or replace public synonym DBA_WI_PATTERN_ITEMS
   for sys.DBA_WI_PATTERN_ITEMS;
grant select on DBA_WI_PATTERN_ITEMS to select_catalog_role;

execute CDBView.create_cdbview(false,'SYS','DBA_WI_PATTERN_ITEMS','CDB_WI_PATTERN_ITEMS');
grant select on SYS.CDB_WI_PATTERN_ITEMS to select_catalog_role
/
create or replace public synonym CDB_WI_PATTERN_ITEMS for SYS.CDB_WI_PATTERN_ITEMS
/


@?/rdbms/admin/sqlsessend.sql
