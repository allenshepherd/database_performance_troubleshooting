Rem
Rem $Header: rdbms/admin/catstrr.sql /main/14 2017/07/26 10:07:21 harnesin Exp $
Rem
Rem catstrr.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catstrr.sql - Streams Rule-related catalog views
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catstrr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catstrr.sql
Rem SQL_PHASE: CATSTRR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catstr.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    harnesin    06/28/17 - Bug 25871643: Future pdb registration support
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    tianli      09/13/12 - fix bug 14625788: rename source_pdb_name to
Rem                           source_container_name
Rem    tianli      08/16/12 - fix global name in CDB
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    elu         08/31/11 - procedure LCR
Rem    lzheng      11/01/11 - add dba_goldengate_rules and all_goldengate_rules
Rem    lzheng      11/01/11 - modify dba_xstream_rules to exclude entries for GG
Rem    thoang      09/14/11 - Add source_root_name to dba_xstream_rules view 
Rem    thoang      02/27/08 - Add dba_xstream_rules view 
Rem    jinwu       11/09/06 - add sync capture catalog views
Rem    jinwu       11/09/06 - add Streams rule-related catalog views
Rem    jinwu       11/09/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


REM streams$_rule_name_s sequence is used to generate rule names for 
REM automatic creation of rule names.

CREATE SEQUENCE streams$_rule_name_s START WITH 1 NOCACHE
/

----------------------------------------------------------------------------
-- Internal unified views of streams processes
----------------------------------------------------------------------------

-- View of all streams processes and rule sets. A process will be listed
-- once for each rule set (in other words, a process will be listed twice
-- if it has both a positive and negative rule set).
-- Streams type is represented as a number (capture = 1, propagation = 2,
-- apply = 3, dequeue = 4, sync cap = 5) to simplify joins with 
-- streams$_rules and streams$_message_rules.
create or replace view "_DBA_STREAMS_PROCESSES"(
  streams_type, streams_name, rule_set_owner, rule_set_name, rule_set_type)
as
select decode(bitand(c.flags, 512), 512, 5, 1) streams_type, 
       c.capture_name streams_name, 
       c.ruleset_owner, c.ruleset_name, 'POSITIVE'
  from streams$_capture_process c 
union all
select 1 streams_type, c.capture_name streams_name, 
       c.negative_ruleset_owner, c.negative_ruleset_name, 'NEGATIVE'
  from streams$_capture_process c 
  where  bitand(c.flags, 512) != 512
union all
select 2 streams_type, p.propagation_name streams_name, 
       p.ruleset_schema, p.ruleset, 'POSITIVE'
  from streams$_propagation_process p
union all
select 2 streams_type, p.propagation_name streams_name, 
       p.negative_ruleset_schema, p.negative_ruleset, 'NEGATIVE'
  from streams$_propagation_process p
union all
select 3 streams_type, a.apply_name streams_name, 
       a.ruleset_owner, a.ruleset_name, 'POSITIVE'
  from streams$_apply_process a
union all
select 3 streams_type, a.apply_name streams_name, 
       a.negative_ruleset_owner, a.negative_ruleset_name, 'NEGATIVE'
  from streams$_apply_process a
union all
select 4 streams_type, d.streams_name, 
       d.rset_owner, d.rset_name, 'POSITIVE'
  from streams$_message_consumers d
union all
select 4 streams_type, d.streams_name, 
       d.neg_rset_owner, d.neg_rset_name, 'NEGATIVE'
  from streams$_message_consumers d
/

-- View of all streams processes
create or replace view "_ALL_STREAMS_PROCESSES"(
  streams_type, streams_name, rule_set_owner, rule_set_name, 
  negative_rule_set_owner, negative_rule_set_name) as
select 'CAPTURE' streams_type,
       capture_name, rule_set_owner, rule_set_name, 
       negative_rule_set_owner, negative_rule_set_name
  from all_capture
union all
select 'SYNC_CAPTURE' streams_type,
       capture_name, rule_set_owner, rule_set_name, 
       null negative_rule_set_owner, null negative_rule_set_name
  from all_sync_capture
union all
select 'APPLY', apply_name, rule_set_owner, rule_set_name, 
       negative_rule_set_owner, negative_rule_set_name
  from all_apply
union all
select 'PROPAGATION', propagation_name, rule_set_owner, rule_set_name, 
       negative_rule_set_owner, negative_rule_set_name
  from all_propagation
union all
select 'DEQUEUE', streams_name, rule_set_owner, rule_set_name, 
       negative_rule_set_owner, negative_rule_set_name
  from all_streams_message_consumers
/

----------------------------------------------------------------------------
-- Internal unified views of streams queues
----------------------------------------------------------------------------

-- View of all streams queues
create or replace view "_DBA_STREAMS_QUEUES"(queue_owner, queue_name)
as
select c.queue_owner queue_owner, c.queue_name queue_name
  from streams$_capture_process c
union 
select p.source_queue_schema queue_owner, p.source_queue queue_name
  from streams$_propagation_process p
union 
select a.queue_owner queue_owner, a.queue_name queue_name
  from streams$_apply_process a
union 
select d.queue_owner queue_owner, d.queue_name queue_name
  from streams$_message_consumers d
/

----------------------------------------------------------------------------
-- Unified streams rules views
----------------------------------------------------------------------------

-- view of rules used by streams processes
create or replace view "_DBA_STREAMS_RULES_H"(
  streams_type, streams_name, rule_set_type, rule_set_owner, rule_set_name, 
  rule_owner, rule_name, rule_condition)
as 
select sp.streams_type, sp.streams_name, sp.rule_set_type, 
       sp.rule_set_owner, sp.rule_set_name, 
       ru.name rule_owner, ro.name rule_name, 
       r.condition
  from "_DBA_STREAMS_PROCESSES" sp, obj$ rso, user$ rsu,
       rule$ r, obj$ ro, user$ ru, rule_map$ rm
  where sp.rule_set_owner = rsu.name
    and sp.rule_set_name = rso.name
    and rso.owner# = rsu.user#
    and rso.obj# = rm.rs_obj#
    and r.obj# = rm.r_obj#
    and ro.obj# = rm.r_obj#
    and ru.user# = ro.owner#
/

-- Used by export. Respective catalog views will select from this view.
grant select on "_DBA_STREAMS_RULES_H" to exp_full_database
/

----------------------------------------------------------------------------
-- Views on streams$_rules table
----------------------------------------------------------------------------

-- Private view select to all columns from streams$_rules
-- Used by export. Respective catalog views will select from this view.
-- Note: the streams_name and streams_type from this view may not be valid
-- (see comment in sql.bsq for streams$_rule table).
-- To get those information, internal users should join this view with 
-- "_DBA_STREAMS_PROCESSES" view and obtain the streams_name and streams_type
-- from "_DBA_STREAMS_PROCESSES".  See definition of "_DBA_STREAMS_RULES_H" 
-- for example.  

create or replace view "_DBA_STREAMS_RULES"
as select 
  streams_name, streams_type, rule_type, include_tagged_lcr, 
  source_database, rule_owner, rule_name, rule_condition, dml_condition, 
  subsetting_operation, schema_name, object_name, object_type,
  spare1, spare2, spare3, source_root_name
from sys.streams$_rules
/
grant select on "_DBA_STREAMS_RULES" to exp_full_database
/

create or replace view DBA_STREAMS_GLOBAL_RULES
  (STREAMS_NAME, STREAMS_TYPE, RULE_TYPE, INCLUDE_TAGGED_LCR,
   SOURCE_DATABASE, RULE_NAME, RULE_OWNER, RULE_CONDITION) 
as
select r.streams_name, decode(r.streams_type, 1, 'CAPTURE',
                                          2, 'PROPAGATION',
                                          3, 'APPLY',
                                          4, 'DEQUEUE', 'UNDEFINED'),
       decode(rule_type, 1, 'DML',
                         2, 'DDL', 
                         3, 'PROCEDURE', 'UNKNOWN'),
       decode(include_tagged_lcr, 0, 'NO',
                                  1, 'YES'),
       source_database, r.rule_name, r.rule_owner, sr.rule_condition
  from "_DBA_STREAMS_RULES" sr, "_DBA_STREAMS_RULES_H" r
 where sr.rule_owner = r.rule_owner and sr.rule_name = r.rule_name 
   and object_type = 3
/

comment on table DBA_STREAMS_GLOBAL_RULES is
'Global rules created by streams administrative APIs'
/
comment on column DBA_STREAMS_GLOBAL_RULES.STREAMS_NAME is
'Name of the streams process: capture/propagation/apply process'
/
comment on column DBA_STREAMS_GLOBAL_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION or APPLY'
/
comment on column DBA_STREAMS_GLOBAL_RULES.RULE_TYPE is
'Type of rule: DML, DDL or PROCEDURE'
/
comment on column DBA_STREAMS_GLOBAL_RULES.INCLUDE_TAGGED_LCR is
'Whether or not to include tagged LCR'
/
comment on column DBA_STREAMS_GLOBAL_RULES.SOURCE_DATABASE is
'Name of the database where the LCRs originated'
/
comment on column DBA_STREAMS_GLOBAL_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_STREAMS_GLOBAL_RULES.RULE_NAME is
'Name of the rule to be applied'
/
comment on column DBA_STREAMS_GLOBAL_RULES.RULE_CONDITION is
'Generated rule condition evaluated by the rules engine'
/
create or replace public synonym DBA_STREAMS_GLOBAL_RULES
  for DBA_STREAMS_GLOBAL_RULES
/
grant select on DBA_STREAMS_GLOBAL_RULES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_STREAMS_GLOBAL_RULES','CDB_STREAMS_GLOBAL_RULES');
grant select on SYS.CDB_STREAMS_GLOBAL_RULES to select_catalog_role
/
create or replace public synonym CDB_STREAMS_GLOBAL_RULES for SYS.CDB_STREAMS_GLOBAL_RULES
/

----------------------------------------------------------------------------

create or replace view ALL_STREAMS_GLOBAL_RULES
as
select r.streams_name, r.streams_type, r.rule_type, r.include_tagged_lcr,
       r.source_database, r.rule_name, r.rule_owner, r.rule_condition
 from  dba_streams_global_rules r, "_ALL_STREAMS_PROCESSES" p, all_rules ar
 where r.streams_name = p.streams_name
   and r.streams_type = p.streams_type
   and ar.rule_owner = r.rule_owner
   and ar.rule_name = r.rule_name
/

comment on table ALL_STREAMS_GLOBAL_RULES is
'Global rules created on the streams capture/apply/propagation process that interact with the queue visible to the current user'
/
comment on column ALL_STREAMS_GLOBAL_RULES.STREAMS_NAME is
'Name of the streams process: capture/propagation/apply process'
/
comment on column ALL_STREAMS_GLOBAL_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION or APPLY'
/
comment on column ALL_STREAMS_GLOBAL_RULES.RULE_TYPE is
'Type of rule: DML, DDL or PROCEDURE'
/
comment on column ALL_STREAMS_GLOBAL_RULES.INCLUDE_TAGGED_LCR is
'Whether or not to include tagged LCR'
/
comment on column ALL_STREAMS_GLOBAL_RULES.SOURCE_DATABASE is
'Name of the database where the LCRs originated'
/
comment on column ALL_STREAMS_GLOBAL_RULES.RULE_NAME is
'Name of the rule to be applied'
/
comment on column ALL_STREAMS_GLOBAL_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_STREAMS_GLOBAL_RULES.RULE_CONDITION is
'Generated rule condition evaluated by the rules engine'
/
create or replace public synonym ALL_STREAMS_GLOBAL_RULES
  for ALL_STREAMS_GLOBAL_RULES
/
grant read on ALL_STREAMS_GLOBAL_RULES to public with grant option
/

----------------------------------------------------------------------------

create or replace view DBA_STREAMS_SCHEMA_RULES
  (STREAMS_NAME, STREAMS_TYPE, SCHEMA_NAME, RULE_TYPE,
   INCLUDE_TAGGED_LCR, SOURCE_DATABASE, RULE_NAME, RULE_OWNER, RULE_CONDITION)
as
select r.streams_name, decode(r.streams_type, 1, 'CAPTURE',
                                          2, 'PROPAGATION',
                                          3, 'APPLY',
                                          4, 'DEQUEUE', 'UNDEFINED'),
       schema_name, decode(rule_type, 1, 'DML',
                                      2, 'DDL', 'UNKNOWN'),
       decode(include_tagged_lcr, 0, 'NO',
                                  1, 'YES'),
       source_database, r.rule_name, r.rule_owner, sr.rule_condition
  from "_DBA_STREAMS_RULES" sr, "_DBA_STREAMS_RULES_H" r
 where sr.rule_owner = r.rule_owner and sr.rule_name = r.rule_name 
   and object_type = 2
/

comment on table DBA_STREAMS_SCHEMA_RULES is
'Schema rules created by streams administrative APIs'
/
comment on column DBA_STREAMS_SCHEMA_RULES.STREAMS_NAME is
'Name of the streams process: capture/propagation/apply process'
/
comment on column DBA_STREAMS_SCHEMA_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION or APPLY'
/
comment on column DBA_STREAMS_SCHEMA_RULES.SCHEMA_NAME is
'Name of the schema selected by this rule'
/
comment on column DBA_STREAMS_SCHEMA_RULES.RULE_TYPE is
'Type of rule: DML or DDL'
/
comment on column DBA_STREAMS_SCHEMA_RULES.INCLUDE_TAGGED_LCR is
'Whether or not to include tagged LCR'
/
comment on column DBA_STREAMS_SCHEMA_RULES.SOURCE_DATABASE is
'Name of the database where the LCRs originated'
/
comment on column DBA_STREAMS_SCHEMA_RULES.RULE_NAME is
'Name of the rule to be applied'
/
comment on column DBA_STREAMS_SCHEMA_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_STREAMS_SCHEMA_RULES.RULE_CONDITION is
'Generated rule condition evaluated by the rules engine'
/
create or replace public synonym DBA_STREAMS_SCHEMA_RULES
  for DBA_STREAMS_SCHEMA_RULES
/
grant select on DBA_STREAMS_SCHEMA_RULES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_STREAMS_SCHEMA_RULES','CDB_STREAMS_SCHEMA_RULES');
grant select on SYS.CDB_STREAMS_SCHEMA_RULES to select_catalog_role
/
create or replace public synonym CDB_STREAMS_SCHEMA_RULES for SYS.CDB_STREAMS_SCHEMA_RULES
/

----------------------------------------------------------------------------

create or replace view ALL_STREAMS_SCHEMA_RULES
as
select sr.streams_name, sr.streams_type, sr.schema_name, sr.rule_type,
       sr.include_tagged_lcr, sr.source_database, sr.rule_name, sr.rule_owner,
       sr.rule_condition
  from dba_streams_schema_rules sr, "_ALL_STREAMS_PROCESSES" p, all_rules r
 where sr.rule_owner = r.rule_owner
   and sr.rule_name = r.rule_name
   and sr.streams_name = p.streams_name
   and sr.streams_type = p.streams_type
/

comment on table ALL_STREAMS_SCHEMA_RULES is
'Rules created by streams administrative APIs on all user schemas'
/
comment on column ALL_STREAMS_SCHEMA_RULES.STREAMS_NAME is
'Name of the streams process: capture/propagation/apply process'
/
comment on column ALL_STREAMS_SCHEMA_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION or APPLY'
/
comment on column ALL_STREAMS_SCHEMA_RULES.SCHEMA_NAME is
'Name of the schema selected by this rule'
/
comment on column ALL_STREAMS_SCHEMA_RULES.RULE_TYPE is
'Type of rule: DML or DDL'
/
comment on column ALL_STREAMS_SCHEMA_RULES.INCLUDE_TAGGED_LCR is
'Whether or not to include tagged LCR'
/
comment on column ALL_STREAMS_SCHEMA_RULES.SOURCE_DATABASE is
'Name of the database where the LCRs originated'
/
comment on column ALL_STREAMS_SCHEMA_RULES.RULE_NAME is
'Name of the rule to be applied'
/
comment on column ALL_STREAMS_SCHEMA_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_STREAMS_SCHEMA_RULES.RULE_CONDITION is
'Generated rule condition evaluated by the rules engine'
/
create or replace public synonym ALL_STREAMS_SCHEMA_RULES
  for ALL_STREAMS_SCHEMA_RULES
/
grant read on ALL_STREAMS_SCHEMA_RULES to public with grant option
/

----------------------------------------------------------------------------

-- The following view lists all the table rules and the STREAMS process that 
-- uses the corresponding rule. If the same rule is used by multiple
-- STREAMS processes then that table rule will be listed multiple times.  

create or replace view DBA_STREAMS_TABLE_RULES
  (STREAMS_NAME, STREAMS_TYPE, TABLE_OWNER, TABLE_NAME, RULE_TYPE,
   DML_CONDITION, SUBSETTING_OPERATION, INCLUDE_TAGGED_LCR,
   SOURCE_DATABASE, RULE_NAME, RULE_OWNER, RULE_CONDITION)
as
select r.streams_name, decode(r.streams_type, 1, 'CAPTURE',
                                          2, 'PROPAGATION',
                                          3, 'APPLY',
                                          4, 'DEQUEUE', 
                                          5, 'SYNC_CAPTURE', 
                                          'UNDEFINED'),
       schema_name, object_name, decode(rule_type, 1, 'DML',
                                                   2, 'DDL', 'UNKNOWN'),
       dml_condition, decode(subsetting_operation, 1, 'INSERT',
                                                   2, 'UPDATE',
                                                   3, 'DELETE'),
       decode(include_tagged_lcr, 0, 'NO',
                                  1, 'YES'),
       source_database, r.rule_name, r.rule_owner, sr.rule_condition
  from "_DBA_STREAMS_RULES" sr, "_DBA_STREAMS_RULES_H" r
 where sr.rule_owner = r.rule_owner and sr.rule_name = r.rule_name 
   and object_type = 1
/

comment on table DBA_STREAMS_TABLE_RULES is
'Table rules created by streams administrative APIs'
/
comment on column DBA_STREAMS_TABLE_RULES.STREAMS_NAME is
'Name of the streams process: capture/propagation/apply process'
/
comment on column DBA_STREAMS_TABLE_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION or APPLY'
/
comment on column DBA_STREAMS_TABLE_RULES.TABLE_OWNER is
'Owner of the table selected by this rule'
/
comment on column DBA_STREAMS_TABLE_RULES.TABLE_NAME is
'Name of the table selected by this rule'
/
comment on column DBA_STREAMS_TABLE_RULES.RULE_TYPE is
'Type of rule: DML or DDL'
/
comment on column DBA_STREAMS_TABLE_RULES.DML_CONDITION is
'Row subsetting condition'
/
comment on column DBA_STREAMS_TABLE_RULES.SUBSETTING_OPERATION is
'DML operation for row subsetting'
/
comment on column DBA_STREAMS_TABLE_RULES.INCLUDE_TAGGED_LCR is
'Whether or not to include tagged LCR'
/
comment on column DBA_STREAMS_TABLE_RULES.SOURCE_DATABASE is
'Name of the database where the LCRs originated'
/
comment on column DBA_STREAMS_TABLE_RULES.RULE_NAME is
'Name of the rule to be applied'
/
comment on column DBA_STREAMS_TABLE_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_STREAMS_TABLE_RULES.RULE_CONDITION is
'Generated rule condition evaluated by the rules engine'
/
create or replace public synonym DBA_STREAMS_TABLE_RULES
  for DBA_STREAMS_TABLE_RULES
/
grant select on DBA_STREAMS_TABLE_RULES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_STREAMS_TABLE_RULES','CDB_STREAMS_TABLE_RULES');
grant select on SYS.CDB_STREAMS_TABLE_RULES to select_catalog_role
/
create or replace public synonym CDB_STREAMS_TABLE_RULES for SYS.CDB_STREAMS_TABLE_RULES
/

----------------------------------------------------------------------------

create or replace view ALL_STREAMS_TABLE_RULES
as
select tr.streams_name, tr.streams_type, tr.table_owner, tr.table_name,
       tr.rule_type, tr.dml_condition, tr.subsetting_operation,
       tr.include_tagged_lcr, tr.source_database, tr.rule_name,
       tr.rule_owner, tr.rule_condition
  from dba_streams_table_rules tr, "_ALL_STREAMS_PROCESSES" p, all_rules ar
 where tr.rule_owner = ar.rule_owner
   and tr.rule_name = ar.rule_name
   and tr.streams_name = p.streams_name
   and tr.streams_type = p.streams_type
/

comment on table ALL_STREAMS_TABLE_RULES is
'Rules created by streams administrative APIs on tables visible to the current user'
/
comment on column ALL_STREAMS_TABLE_RULES.STREAMS_NAME is
'Name of the streams process: capture/propagation/apply process'
/
comment on column ALL_STREAMS_TABLE_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION or APPLY'
/
comment on column ALL_STREAMS_TABLE_RULES.TABLE_OWNER is
'Owner of the table selected by this rule'
/
comment on column ALL_STREAMS_TABLE_RULES.TABLE_NAME is
'Name of the table selected by this rule'
/
comment on column ALL_STREAMS_TABLE_RULES.RULE_TYPE is
'Type of rule: DML or DDL'
/
comment on column ALL_STREAMS_TABLE_RULES.DML_CONDITION is
'Row subsetting condition'
/
comment on column ALL_STREAMS_TABLE_RULES.SUBSETTING_OPERATION is
'DML operation for row subsetting'
/
comment on column ALL_STREAMS_TABLE_RULES.INCLUDE_TAGGED_LCR is
'Whether or not to include tagged LCR'
/
comment on column ALL_STREAMS_TABLE_RULES.SOURCE_DATABASE is
'Name of the database where the LCRs originated'
/
comment on column ALL_STREAMS_TABLE_RULES.RULE_NAME is
'Name of the rule to be applied'
/
comment on column ALL_STREAMS_TABLE_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_STREAMS_TABLE_RULES.RULE_CONDITION is
'Generated rule condition evaluated by the rules engine'
/
create or replace public synonym ALL_STREAMS_TABLE_RULES
  for ALL_STREAMS_TABLE_RULES
/
grant read on ALL_STREAMS_TABLE_RULES to public with grant option
/

----------------------------------------------------------------------------
-- Views on streams$_message_rules tables
----------------------------------------------------------------------------

-- Private view select to all columns from streams$_message_rules.
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_STREAMS_MESSAGE_RULES"
as select * from sys.streams$_message_rules
/
grant select on "_DBA_STREAMS_MESSAGE_RULES" to exp_full_database
/

create or replace view DBA_STREAMS_MESSAGE_RULES
  (STREAMS_NAME, STREAMS_TYPE, MESSAGE_TYPE_NAME, MESSAGE_TYPE_OWNER,
   MESSAGE_RULE_VARIABLE, RULE_NAME, RULE_OWNER, RULE_CONDITION)
as
select r.streams_name, decode(r.streams_type, 2, 'PROPAGATION',
                                          3, 'APPLY', 
                                          4, 'DEQUEUE', 'UNDEFINED'),
       msg_type_name, msg_type_owner, msg_rule_var, r.rule_name, 
       r.rule_owner, sr.rule_condition
  from "_DBA_STREAMS_MESSAGE_RULES" sr, "_DBA_STREAMS_RULES_H" r
 where sr.rule_owner = r.rule_owner and sr.rule_name = r.rule_name 
/

comment on table DBA_STREAMS_MESSAGE_RULES is
'Rules for Streams messaging'
/
comment on column DBA_STREAMS_MESSAGE_RULES.STREAMS_NAME is
'Name of the streams process : propagation/apply/dequeue'
/
comment on column DBA_STREAMS_MESSAGE_RULES.STREAMS_TYPE is
'Type of the streams process: PROPAGATION, APPLY, or DEQUEUE'
/
comment on column DBA_STREAMS_MESSAGE_RULES.MESSAGE_TYPE_NAME is
'Name of the message type'
/
comment on column DBA_STREAMS_MESSAGE_RULES.MESSAGE_TYPE_OWNER is
'Owner of the message type'
/
comment on column DBA_STREAMS_MESSAGE_RULES.MESSAGE_RULE_VARIABLE is
'Name of variable in the message rule'
/
comment on column DBA_STREAMS_MESSAGE_RULES.RULE_NAME is
'Name of the rule'
/
comment on column DBA_STREAMS_MESSAGE_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_STREAMS_MESSAGE_RULES.RULE_CONDITION is
'Rule condition'
/
create or replace public synonym DBA_STREAMS_MESSAGE_RULES
  for DBA_STREAMS_MESSAGE_RULES
/
grant select on DBA_STREAMS_MESSAGE_RULES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_STREAMS_MESSAGE_RULES','CDB_STREAMS_MESSAGE_RULES');
grant select on SYS.CDB_STREAMS_MESSAGE_RULES to select_catalog_role
/
create or replace public synonym CDB_STREAMS_MESSAGE_RULES for SYS.CDB_STREAMS_MESSAGE_RULES
/

----------------------------------------------------------------------------

create or replace view ALL_STREAMS_MESSAGE_RULES
as
select mr.*
  from dba_streams_message_rules mr, "_ALL_STREAMS_PROCESSES" p, all_rules ar
 where mr.rule_owner = ar.rule_owner
   and mr.rule_name  = ar.rule_name
   and mr.streams_name = p.streams_name
   and mr.streams_type = p.streams_type
/

comment on table ALL_STREAMS_MESSAGE_RULES is
'Rules for Streams messaging visible to the current user'
/
comment on column ALL_STREAMS_MESSAGE_RULES.STREAMS_NAME is
'Name of the streams process : propagation/apply/dequeue'
/
comment on column ALL_STREAMS_MESSAGE_RULES.STREAMS_TYPE is
'Type of the streams process: PROPAGATION, APPLY, or DEQUEUE'
/
comment on column ALL_STREAMS_MESSAGE_RULES.MESSAGE_TYPE_NAME is
'Name of the message type'
/
comment on column ALL_STREAMS_MESSAGE_RULES.MESSAGE_TYPE_OWNER is
'Owner of the message type'
/
comment on column ALL_STREAMS_MESSAGE_RULES.MESSAGE_RULE_VARIABLE is
'Name of variable in the message rule'
/
comment on column ALL_STREAMS_MESSAGE_RULES.RULE_NAME is
'Name of the rule'
/
comment on column ALL_STREAMS_MESSAGE_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_STREAMS_MESSAGE_RULES.RULE_CONDITION is
'Rule condition'
/
create or replace public synonym ALL_STREAMS_MESSAGE_RULES
  for ALL_STREAMS_MESSAGE_RULES
/
grant read on ALL_STREAMS_MESSAGE_RULES to public with grant option
/

----------------------------------------------------------------------------
-- Unified streams rules views
----------------------------------------------------------------------------

-- This view of all the rules used by streams processes assumes that
-- rule names are unique over streams$_rules and streams$_message_rules.
-- Column same_rule_condition compares the original rule condition (ORC) 
-- to the current rule condition (CRC), and has value 'Y' if they
-- are the same, 'N' if they are different, and NULL if it cannot be
-- determined. The algorithm used to find the value of the column is:
--   if ORC is NULL then 
--     same_rule_condition = NULL;
--   else
--     if ORC = CRC then
--       same_rule_condition = 'Y';
--     else 
--       if length(CRC) > 4000
--         -- ORC only stores the first 4000 bytes, so unable to compare
--         -- if length(CRC) > 4000
--         same_rule_condition = NULL;
--       else
--         same_rule_condition = 'N';
--       end if;
--     end if;
--   end if;
create or replace view DBA_STREAMS_RULES
as
select decode(r.streams_type, 1, 'CAPTURE',
                              2, 'PROPAGATION',
                              3, 'APPLY', 
                              4, 'DEQUEUE',
                              5, 'SYNC_CAPTURE') streams_type,
       r.streams_name, r.rule_set_owner, r.rule_set_name,
       r.rule_owner, r.rule_name, r.rule_condition, r.rule_set_type,        
       decode(sr.object_type, 1, 'TABLE',
                              2, 'SCHEMA',
                              3, 'GLOBAL',
                              4, 'PROCEDURE') streams_rule_type,
       sr.schema_name, sr.object_name,
       decode(sr.subsetting_operation, 1, 'INSERT',
                                       2, 'UPDATE',
                                       3, 'DELETE') subsetting_operation, 
       sr.dml_condition,
       decode(sr.include_tagged_lcr, 0, 'NO',
                                     1, 'YES') include_tagged_lcr,
       sr.source_database, 
       decode(sr.rule_type, 1, 'DML',
                            2, 'DDL',
                            3, 'PROCEDURE') rule_type,
       smr.msg_type_owner message_type_owner, 
       smr.msg_type_name message_type_name, 
       smr.msg_rule_var message_rule_variable,
       NVL(sr.rule_condition, smr.rule_condition) original_rule_condition, 
       decode(NVL(sr.rule_condition, smr.rule_condition), 
              NULL, NULL,
              dbms_lob.substr(r.rule_condition), 'YES',
              decode(least(4001,dbms_lob.getlength(r.rule_condition)), 
                     4001, NULL, 'NO')) same_rule_condition
  from "_DBA_STREAMS_RULES_H" r, streams$_rules sr, streams$_message_rules smr
  where r.rule_name = sr.rule_name(+) 
    and r.rule_owner = sr.rule_owner(+)
    and r.rule_name = smr.rule_name(+)
    and r.rule_owner = smr.rule_owner(+)
    and (r.streams_type NOT IN (1, 3) or 
         r.streams_name in 
           (select apply_name from dba_apply
            where purpose NOT IN ('XStream Out', 'XStream In',
                                  'GoldenGate Capture', 'GoldenGate Apply')
            union 
            select capture_name from dba_capture
            where purpose NOT IN ('XStream Out','GoldenGate Capture')))
/

comment on table DBA_STREAMS_RULES is
'Rules used by Streams processes'
/
comment on column DBA_STREAMS_RULES.STREAMS_TYPE is
'Type of the Streams process: CAPTURE, PROPAGATION, APPLY or DEQUEUE'
/
comment on column DBA_STREAMS_RULES.STREAMS_NAME is
'Name of the Streams process'
/
comment on column DBA_STREAMS_RULES.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column DBA_STREAMS_RULES.RULE_SET_NAME is
'Name of the rule set'
/
comment on column DBA_STREAMS_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_STREAMS_RULES.RULE_NAME is
'Name of the rule'
/
comment on column DBA_STREAMS_RULES.RULE_CONDITION is
'Current rule condition'
/
comment on column DBA_STREAMS_RULES.RULE_SET_TYPE is
'Type of the rule set: POSITIVE or NEGATIVE'
/
comment on column DBA_STREAMS_RULES.STREAMS_RULE_TYPE is
'For global, schema or table rules, type of rule: TABLE, SCHEMA or GLOBAL'
/
comment on column DBA_STREAMS_RULES.SCHEMA_NAME is
'For table and schema rules, the schema name'
/
comment on column DBA_STREAMS_RULES.OBJECT_NAME is
'For table rules, the table name'
/
comment on column DBA_STREAMS_RULES.SUBSETTING_OPERATION is
'For subset rules, the type of operation: INSERT, UPDATE, or DELETE'
/
comment on column DBA_STREAMS_RULES.DML_CONDITION is
'For subset rules, the row subsetting condition'
/
comment on column DBA_STREAMS_RULES.INCLUDE_TAGGED_LCR is
'For global, schema or table rules, whether or not to include tagged LCRs'
/
comment on column DBA_STREAMS_RULES.SOURCE_DATABASE is
'For global, schema or table rules, the name of the database where the LCRs originated'
/
comment on column DBA_STREAMS_RULES.RULE_TYPE is
'For global, schema or table rules, type of rule: DML, DDL or PROCEDURE'
/
comment on column DBA_STREAMS_RULES.MESSAGE_TYPE_OWNER is
'For message rules, the owner of the message type'
/
comment on column DBA_STREAMS_RULES.MESSAGE_TYPE_NAME is
'For message rules, the name of the message type'
/
comment on column DBA_STREAMS_RULES.MESSAGE_RULE_VARIABLE is
'For message rules, the name of the variable in the message rule'
/
comment on column DBA_STREAMS_RULES.ORIGINAL_RULE_CONDITION is
'For rules created by Streams administrative APIs, the original rule condition when the rule was created'
/
comment on column DBA_STREAMS_RULES.SAME_RULE_CONDITION is
'For rules created by Streams administrative APIs, whether or not the current rule condition is the same as the original rule condition'
/
create or replace public synonym DBA_STREAMS_RULES
  for DBA_STREAMS_RULES
/
grant select on DBA_STREAMS_RULES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_STREAMS_RULES','CDB_STREAMS_RULES');
grant select on SYS.CDB_STREAMS_RULES to select_catalog_role
/
create or replace public synonym CDB_STREAMS_RULES for SYS.CDB_STREAMS_RULES
/

----------------------------------------------------------------------------

create or replace view ALL_STREAMS_RULES as
select r.* 
  from dba_streams_rules r, "_ALL_STREAMS_PROCESSES" p
where r.streams_type = p.streams_type
  and r.streams_name = p.streams_name
/
 
comment on table ALL_STREAMS_RULES is
'Rules used by streams processes'
/
comment on column ALL_STREAMS_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION, APPLY or DEQUEUE'
/
comment on column ALL_STREAMS_RULES.STREAMS_NAME is
'Name of the Streams process'
/
comment on column ALL_STREAMS_RULES.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column ALL_STREAMS_RULES.RULE_SET_NAME is
'Name of the rule set'
/
comment on column ALL_STREAMS_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_STREAMS_RULES.RULE_NAME is
'Name of the rule'
/
comment on column ALL_STREAMS_RULES.RULE_CONDITION is
'Current rule condition'
/
comment on column ALL_STREAMS_RULES.RULE_SET_type is
'Type of the rule set: POSITIVE or NEGATIVE'
/
comment on column ALL_STREAMS_RULES.STREAMS_RULE_TYPE is
'For global, schema or table rules, type of rule: TABLE, SCHEMA or GLOBAL'
/
comment on column ALL_STREAMS_RULES.SCHEMA_NAME is
'For table and schema rules, the schema name'
/
comment on column ALL_STREAMS_RULES.OBJECT_NAME is
'For table rules, the table name'
/
comment on column ALL_STREAMS_RULES.SUBSETTING_OPERATION is
'For subset rules, the type of operation: INSERT, UPDATE, or DELETE'
/
comment on column ALL_STREAMS_RULES.DML_CONDITION is
'For subset rules, the row subsetting condition'
/
comment on column ALL_STREAMS_RULES.INCLUDE_TAGGED_LCR is
'For global, schema or table rules, whether or not to include tagged LCRs'
/
comment on column ALL_STREAMS_RULES.SOURCE_DATABASE is
'For global, schema or table rules, the name of the database where the LCRs originated'
/
comment on column ALL_STREAMS_RULES.RULE_TYPE is
'For global, schema or table rules, type of rule: DML, DDL or PROCEDURE'
/
comment on column ALL_STREAMS_RULES.MESSAGE_TYPE_OWNER is
'For message rules, the owner of the message type'
/
comment on column ALL_STREAMS_RULES.MESSAGE_TYPE_NAME is
'For message rules, the name of the message type'
/
comment on column ALL_STREAMS_RULES.MESSAGE_RULE_VARIABLE is
'For message rules, the name of the variable in the message rule'
/
comment on column ALL_STREAMS_RULES.ORIGINAL_RULE_CONDITION is
'For rules created by Streams administrative APIs, the original rule condition when the rule was created'
/
comment on column ALL_STREAMS_RULES.SAME_RULE_CONDITION is
'For rules created by Streams administrative APIs, whether or not the current rule condition is the same as the original rule condition'
/
create or replace public synonym ALL_STREAMS_RULES
  for ALL_STREAMS_RULES
/
grant read on ALL_STREAMS_RULES to public with grant option
/


----------------------------------------------------------------------------
-- view to get sync capture tables
----------------------------------------------------------------------------
create or replace view DBA_SYNC_CAPTURE_TABLES
  (TABLE_OWNER, TABLE_NAME, ENABLED)
as
 SELECT distinct sr.table_owner, sr.table_name, 
   decode(bitand(t.trigflag, 32), 32, 'YES', 'NO')
 FROM dba_streams_table_rules sr, obj$ tob, user$ tu, tab$ t
 WHERE streams_type = 'SYNC_CAPTURE' 
   AND sr.table_owner = tu.name AND sr.table_name = tob.name
   AND tob.owner# = tu.user# AND tob.obj# = t.obj#
/
comment on table DBA_SYNC_CAPTURE_TABLES is
'All tables that are captured by synchronous streams captures.'
/
comment on column DBA_SYNC_CAPTURE_TABLES.TABLE_OWNER is
'Owner of the sync capture table'
/ 
comment on column DBA_SYNC_CAPTURE_TABLES.TABLE_NAME is
'Name of the sync capture table'
/ 
comment on column DBA_SYNC_CAPTURE_TABLES.ENABLED is
'Is synchronous Streams capture enabled for this table?'
/ 
create or replace public synonym DBA_SYNC_CAPTURE_TABLES
  for DBA_SYNC_CAPTURE_TABLES
/
grant read on DBA_SYNC_CAPTURE_TABLES to public with grant option
/


execute CDBView.create_cdbview(false,'SYS','DBA_SYNC_CAPTURE_TABLES','CDB_SYNC_CAPTURE_TABLES');
grant read on SYS.CDB_SYNC_CAPTURE_TABLES to public with grant option 
/
create or replace public synonym CDB_SYNC_CAPTURE_TABLES for SYS.CDB_SYNC_CAPTURE_TABLES
/

-- View of all sync capture tables
create or replace view ALL_SYNC_CAPTURE_TABLES
  (TABLE_OWNER, TABLE_NAME, ENABLED)
as
 SELECT distinct sr.table_owner, sr.table_name, 
   decode(bitand(t.trigflag, 32), 32, 'YES', 'NO')
 FROM all_streams_table_rules sr, obj$ tob, user$ tu, tab$ t
 WHERE streams_type = 'SYNC_CAPTURE' 
   AND sr.table_owner = tu.name AND sr.table_name = tob.name
   AND tob.owner# = tu.user# AND tob.obj# = t.obj#
/
comment on table ALL_SYNC_CAPTURE_TABLES is
'All tables that are captured by synchronous streams captures.'
/
comment on column ALL_SYNC_CAPTURE_TABLES.TABLE_OWNER is
'Owner of the synchronous capture table'
/ 
comment on column ALL_SYNC_CAPTURE_TABLES.TABLE_NAME is
'Name of the synchronous capture table'
/ 
comment on column ALL_SYNC_CAPTURE_TABLES.ENABLED is
'Is synchronous Streams capture enabled for this table?'
/ 
create or replace public synonym ALL_SYNC_CAPTURE_TABLES
  for ALL_SYNC_CAPTURE_TABLES
/
grant select on ALL_SYNC_CAPTURE_TABLES to select_catalog_role
/

----------------------------------------------------------------------------
--  DBA_XSTREAM_RULES and ALL_XSTREAM_RULES VIEW
----------------------------------------------------------------------------

create or replace view "_DBA_STREAMS_RULES_H2"
as
select decode(r.streams_type, 1, 'CAPTURE',
                              2, 'PROPAGATION',
                              3, 'APPLY', 
                              4, 'DEQUEUE',
                              5, 'SYNC_CAPTURE') streams_type,
       r.streams_name, r.rule_set_owner, r.rule_set_name,
       r.rule_owner, r.rule_name, r.rule_condition, r.rule_set_type,        
       decode(sr.object_type, 1, 'TABLE',
                              2, 'SCHEMA',
                              3, 'GLOBAL',
                              4, 'PROCEDURE') streams_rule_type,
       sr.schema_name, sr.object_name,
       decode(sr.subsetting_operation, 1, 'INSERT',
                                       2, 'UPDATE',
                                       3, 'DELETE') subsetting_operation, 
       sr.dml_condition,
       decode(sr.include_tagged_lcr, 0, 'NO',
                                     1, 'YES') include_tagged_lcr,
       sr.source_database, 
       decode(sr.rule_type, 1, 'DML',
                            2, 'DDL',
                            3, 'PROCEDURE') rule_type,
       sr.rule_condition original_rule_condition, 
       decode(sr.rule_condition, 
              NULL, NULL,
              dbms_lob.substr(r.rule_condition), 'YES',
              decode(least(4001,dbms_lob.getlength(r.rule_condition)), 
                     4001, NULL, 'NO')) same_rule_condition,
       sr.source_root_name
  from "_DBA_STREAMS_RULES_H" r, streams$_rules sr
  where r.rule_name = sr.rule_name(+) 
    and r.rule_owner = sr.rule_owner(+)
/

create or replace view dba_xstream_rules
as select
  r1.streams_name, r1.streams_type, r1.streams_rule_type,
  r1.rule_set_owner, r1.rule_set_name, r1.rule_set_type,
  r1.rule_owner, r1.rule_name, r1.rule_type, r1.rule_condition,
  r1.schema_name, r1.object_name, r1.include_tagged_lcr,
  r1.subsetting_operation, r1.dml_condition, r1.source_database,
  r1.original_rule_condition, r1.same_rule_condition, r1.source_root_name,
  dm.source_container_name
from "_DBA_STREAMS_RULES_H2" r1, repl$_dbname_mapping dm
  where ((r1.streams_type = 'CAPTURE') or
         (r1.streams_type = 'APPLY')) and
        ((r1.streams_type, r1.streams_name) IN
      (select 'APPLY', apply_name from dba_apply 
       where purpose in ('XStream Out', 'XStream In')
         union
       select 'CAPTURE', capture_name from dba_capture 
       where purpose in ('XStream Out'))) and
       r1.source_root_name = dm.source_root_name(+) and
       r1.source_database = dm.source_database_name(+)
/
comment on table DBA_XSTREAM_RULES is
'Details about the XStream server rules'
/
comment on column DBA_XSTREAM_RULES.STREAMS_NAME is
'Name of the Streams process'
/
comment on column DBA_XSTREAM_RULES.STREAMS_TYPE is
'Type of the Streams process: CAPTURE or APPLY'
/
comment on column DBA_XSTREAM_RULES.STREAMS_RULE_TYPE is
'For global, schema or table rules, type of rule: TABLE, SCHEMA or GLOBAL'
/
comment on column DBA_XSTREAM_RULES.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column DBA_XSTREAM_RULES.RULE_SET_NAME is
'Name of the rule set'
/
comment on column DBA_XSTREAM_RULES.RULE_SET_type is
'Type of the rule set: POSITIVE or NEGATIVE'
/
comment on column DBA_XSTREAM_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_XSTREAM_RULES.RULE_NAME is
'Name of the rule'
/
comment on column DBA_XSTREAM_RULES.RULE_TYPE is
'For global, schema or table rules, type of rule: DML, DDL or PROCEDURE'
/
comment on column DBA_XSTREAM_RULES.RULE_CONDITION is
'Current rule condition'
/
comment on column DBA_XSTREAM_RULES.SCHEMA_NAME is
'For table and schema rules, the schema name'
/
comment on column DBA_XSTREAM_RULES.OBJECT_NAME is
'For table rules, the table name'
/
comment on column DBA_XSTREAM_RULES.INCLUDE_TAGGED_LCR is
'For global, schema or table rules, whether or not to include tagged LCRs'
/
comment on column DBA_XSTREAM_RULES.SUBSETTING_OPERATION is
'For subset rules, the type of operation: INSERT, UPDATE, or DELETE'
/
comment on column DBA_XSTREAM_RULES.DML_CONDITION is
'For subset rules, the row subsetting condition'
/
comment on column DBA_XSTREAM_RULES.SOURCE_DATABASE is
'For global, schema or table rules, the name of the database where the LCRs originated'
/
comment on column DBA_XSTREAM_RULES.ORIGINAL_RULE_CONDITION is
'For rules created by Streams administrative APIs, the original rule condition when the rule was created'
/
comment on column DBA_XSTREAM_RULES.SAME_RULE_CONDITION is
'For rules created by Streams administrative APIs, whether or not the current rule condition is the same as the original rule condition'
/
comment on column DBA_XSTREAM_RULES.SOURCE_ROOT_NAME is
'Root Database where the transactions originated'
/
comment on column DBA_XSTREAM_RULES.SOURCE_CONTAINER_NAME is
'The short container name of the database where the LCRs originated'
/
create or replace public synonym dba_xstream_rules
  for dba_xstream_rules
/
grant select on dba_xstream_rules to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_XSTREAM_RULES','CDB_XSTREAM_RULES');
grant select on SYS.CDB_xstream_rules to select_catalog_role
/
create or replace public synonym CDB_xstream_rules for SYS.CDB_xstream_rules
/

create or replace view ALL_XSTREAM_RULES as
select r.*
  from dba_xstream_rules r, "_ALL_STREAMS_PROCESSES" p
where r.streams_type = p.streams_type
  and r.streams_name = p.streams_name
/

comment on table ALL_XSTREAM_RULES is
'Details about the XStream server rules visible to user'
/
comment on column ALL_XSTREAM_RULES.STREAMS_NAME is
'Name of the Streams process'
/
comment on column ALL_XSTREAM_RULES.STREAMS_TYPE is
'Type of the Streams process: CAPTURE or APPLY'
/
comment on column ALL_XSTREAM_RULES.STREAMS_RULE_TYPE is
'For global, schema or table rules, type of rule: TABLE, SCHEMA or GLOBAL'
/
comment on column ALL_XSTREAM_RULES.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column ALL_XSTREAM_RULES.RULE_SET_NAME is
'Name of the rule set'
/
comment on column ALL_XSTREAM_RULES.RULE_SET_type is
'Type of the rule set: POSITIVE or NEGATIVE'
/
comment on column ALL_XSTREAM_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_XSTREAM_RULES.RULE_NAME is
'Name of the rule'
/
comment on column ALL_XSTREAM_RULES.RULE_TYPE is
'For global, schema or table rules, type of rule: DML, DDL or PROCEDURE'
/
comment on column ALL_XSTREAM_RULES.RULE_CONDITION is
'Current rule condition'
/
comment on column ALL_XSTREAM_RULES.SCHEMA_NAME is
'For table and schema rules, the schema name'
/
comment on column ALL_XSTREAM_RULES.OBJECT_NAME is
'For table rules, the table name'
/
comment on column ALL_XSTREAM_RULES.INCLUDE_TAGGED_LCR is
'For global, schema or table rules, whether or not to include tagged LCRs'
/
comment on column ALL_XSTREAM_RULES.SUBSETTING_OPERATION is
'For subset rules, the type of operation: INSERT, UPDATE, or DELETE'
/
comment on column ALL_XSTREAM_RULES.DML_CONDITION is
'For subset rules, the row subsetting condition'
/
comment on column ALL_XSTREAM_RULES.SOURCE_DATABASE is
'For global, schema or table rules, the name of the database where the LCRs originated'
/
comment on column ALL_XSTREAM_RULES.ORIGINAL_RULE_CONDITION is
'For rules created by Streams administrative APIs, the original rule condition when the rule was created'
/
comment on column ALL_XSTREAM_RULES.SAME_RULE_CONDITION is
'For rules created by Streams administrative APIs, whether or not the current rule condition is the same as the original rule condition'
/
comment on column ALL_XSTREAM_RULES.SOURCE_ROOT_NAME is
'Root Database where the transactions originated'
/
create or replace public synonym all_xstream_rules
  for all_xstream_rules
/
grant select on all_xstream_rules to select_catalog_role
/

create or replace view dba_goldengate_rules 
as select 
  r1.streams_name component_name, r1.streams_type component_type, 
  r1.streams_rule_type component_rule_type, 
  r1.rule_set_owner, r1.rule_set_name, r1.rule_set_type,
  r1.rule_owner, r1.rule_name, r1.rule_type, r1.rule_condition, 
  r1.schema_name, r1.object_name, r1.include_tagged_lcr,
  r1.subsetting_operation, r1.dml_condition, r1.source_database,
  r1.original_rule_condition, r1.same_rule_condition, r1.source_root_name,
  dm.source_container_name
from "_DBA_STREAMS_RULES_H2" r1, repl$_dbname_mapping dm
  where ((r1.streams_type = 'CAPTURE') or
         (r1.streams_type = 'APPLY')) and
        ((r1.streams_type, r1.streams_name) IN 
      (select 'APPLY', apply_name from dba_apply
       where purpose in ('GoldenGate Capture', 'GoldenGate Apply')
         union
       select 'CAPTURE', capture_name from dba_capture
       where purpose = 'GoldenGate Capture')) and
       r1.source_root_name = dm.source_root_name(+) and
       r1.source_database = dm.source_database_name(+)
/
comment on table DBA_GOLDENGATE_RULES is
'Details about the GoldenGate server rules'
/
comment on column DBA_GOLDENGATE_RULES.COMPONENT_NAME is
'Name of the GoldenGate process'
/
comment on column DBA_GOLDENGATE_RULES.COMPONENT_TYPE is
'Type of the GoldenGate process: CAPTURE or APPLY'
/
comment on column DBA_GOLDENGATE_RULES.COMPONENT_RULE_TYPE is
'For global, schema or table rules, type of rule: TABLE, SCHEMA or GLOBAL'
/
comment on column DBA_GOLDENGATE_RULES.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column DBA_GOLDENGATE_RULES.RULE_SET_NAME is
'Name of the rule set'
/
comment on column DBA_GOLDENGATE_RULES.RULE_SET_type is
'Type of the rule set: POSITIVE or NEGATIVE'
/
comment on column DBA_GOLDENGATE_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_GOLDENGATE_RULES.RULE_NAME is
'Name of the rule'
/
comment on column DBA_GOLDENGATE_RULES.RULE_TYPE is
'For global, schema or table rules, type of rule: DML, DDL or PROCEDURE'
/
comment on column DBA_GOLDENGATE_RULES.RULE_CONDITION is
'Current rule condition'
/
comment on column DBA_GOLDENGATE_RULES.SCHEMA_NAME is
'For table and schema rules, the schema name'
/
comment on column DBA_GOLDENGATE_RULES.OBJECT_NAME is
'For table rules, the table name'
/
comment on column DBA_GOLDENGATE_RULES.INCLUDE_TAGGED_LCR is
'For global, schema or table rules, whether or not to include tagged LCRs'
/
comment on column DBA_GOLDENGATE_RULES.SUBSETTING_OPERATION is
'For subset rules, the type of operation: INSERT, UPDATE, or DELETE'
/
comment on column DBA_GOLDENGATE_RULES.DML_CONDITION is
'For subset rules, the row subsetting condition'
/
comment on column DBA_GOLDENGATE_RULES.SOURCE_DATABASE is
'For global, schema or table rules, the name of the database where the LCRs originated'
/
comment on column DBA_GOLDENGATE_RULES.ORIGINAL_RULE_CONDITION is
'For rules created by GoldenGate administrative APIs, the original rule condition when the rule was created'
/
comment on column DBA_GOLDENGATE_RULES.SAME_RULE_CONDITION is
'For rules created by GoldenGate administrative APIs, whether or not the current rule condition is the same as the original rule condition'
/
comment on column DBA_GOLDENGATE_RULES.SOURCE_ROOT_NAME is
'Root Database where the transactions originated'
/
comment on column DBA_GOLDENGATE_RULES.SOURCE_CONTAINER_NAME is
'The short container name of the database where the LCRs originated'
/
create or replace public synonym dba_goldengate_rules
  for dba_goldengate_rules
/
grant select on dba_goldengate_rules to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_GOLDENGATE_RULES','CDB_GOLDENGATE_RULES');
grant select on SYS.CDB_goldengate_rules to select_catalog_role
/
create or replace public synonym CDB_goldengate_rules for SYS.CDB_goldengate_rules
/

create or replace view ALL_GOLDENGATE_RULES as
select r.*
  from dba_goldengate_rules r, "_ALL_STREAMS_PROCESSES" p
where r.component_type = p.streams_type
  and r.component_name = p.streams_name
/

comment on table ALL_GOLDENGATE_RULES is
'Details about the GoldenGate server rules visible to user'
/
comment on column ALL_GOLDENGATE_RULES.COMPONENT_NAME is
'Name of the GoldenGate process'
/
comment on column ALL_GOLDENGATE_RULES.COMPONENT_TYPE is
'Type of the GoldenGate process: CAPTURE or APPLY'
/
comment on column ALL_GOLDENGATE_RULES.COMPONENT_RULE_TYPE is
'For global, schema or table rules, type of rule: TABLE, SCHEMA or GLOBAL'
/
comment on column ALL_GOLDENGATE_RULES.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column ALL_GOLDENGATE_RULES.RULE_SET_NAME is
'Name of the rule set'
/
comment on column ALL_GOLDENGATE_RULES.RULE_SET_type is
'Type of the rule set: POSITIVE or NEGATIVE'
/
comment on column ALL_GOLDENGATE_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_GOLDENGATE_RULES.RULE_NAME is
'Name of the rule'
/
comment on column ALL_GOLDENGATE_RULES.RULE_TYPE is
'For global, schema or table rules, type of rule: DML, DDL or PROCEDURE'
/
comment on column ALL_GOLDENGATE_RULES.RULE_CONDITION is
'Current rule condition'
/
comment on column ALL_GOLDENGATE_RULES.SCHEMA_NAME is
'For table and schema rules, the schema name'
/
comment on column ALL_GOLDENGATE_RULES.OBJECT_NAME is
'For table rules, the table name'
/
comment on column ALL_GOLDENGATE_RULES.INCLUDE_TAGGED_LCR is
'For global, schema or table rules, whether or not to include tagged LCRs'
/
comment on column ALL_GOLDENGATE_RULES.SUBSETTING_OPERATION is
'For subset rules, the type of operation: INSERT, UPDATE, or DELETE'
/
comment on column ALL_GOLDENGATE_RULES.DML_CONDITION is
'For subset rules, the row subsetting condition'
/
comment on column ALL_GOLDENGATE_RULES.SOURCE_DATABASE is
'For global, schema or table rules, the name of the database where the LCRs originated'
/
comment on column ALL_GOLDENGATE_RULES.ORIGINAL_RULE_CONDITION is
'For rules created by GoldenGate administrative APIs, the original rule condition when the rule was created'
/
comment on column ALL_GOLDENGATE_RULES.SAME_RULE_CONDITION is
'For rules created by GoldenGate administrative APIs, whether or not the current rule condition is the same as the original rule condition'
/
comment on column ALL_GOLDENGATE_RULES.SOURCE_ROOT_NAME is
'Root Database where the transactions originated'
/
create or replace public synonym all_goldengate_rules
  for all_goldengate_rules
/
grant select on all_goldengate_rules to select_catalog_role
/

--------------------------------------------------------------------------------
-- DBA_GOLDENGATE_CONTAINER_RULES
--------------------------------------------------------------------------------
create or replace view dba_goldengate_container_rules
as select
  rule# as rule_id, capture_name, filter_rule, 
  decode(inclusion_rule, 0, 'NO',
                         1, 'YES') as include_rule,
  escape_char
  from goldengate$_container_rules
/
comment on table DBA_GOLDENGATE_CONTAINER_RULES is
'Details about goldengate container inclusion/exclusion rules'
/
comment on column DBA_GOLDENGATE_CONTAINER_RULES.RULE_ID is
'Rule identifier'
/
comment on column DBA_GOLDENGATE_CONTAINER_RULES.CAPTURE_NAME is
'Capture instance name'
/
comment on column DBA_GOLDENGATE_CONTAINER_RULES.FILTER_RULE is
'Wilcard card expression for inclusion or exclusion'
/
comment on column DBA_GOLDENGATE_CONTAINER_RULES.INCLUDE_RULE is
'Whether an inclusion or exclusion rule'
/
comment on column DBA_GOLDENGATE_CONTAINER_RULES.ESCAPE_CHAR is
'Escape character used in the filter rule'
/
create or replace public synonym DBA_GOLDENGATE_CONTAINER_RULES
  for DBA_GOLDENGATE_CONTAINER_RULES
/
grant select on DBA_GOLDENGATE_CONTAINER_RULES to select_catalog_role
/


execute CDBView.create_cdbview(false, 'SYS', 'DBA_GOLDENGATE_CONTAINER_RULES', 'CDB_GOLDENGATE_CONTAINER_RULES');
grant select on SYS.CDB_GOLDENGATE_CONTAINER_RULES to select_catalog_role
/
create or replace public synonym CDB_GOLDENGATE_CONTAINER_RULES for SYS.CDB_GOLDENGATE_CONTAINER_RULES
/

create or replace view ALL_GOLDENGATE_CONTAINER_RULES as
select r.*
  from dba_goldengate_container_rules r, all_capture c
 where r.capture_name = c.capture_name
/

comment on table ALL_GOLDENGATE_CONTAINER_RULES is
'Details about goldengate container inclusion/exclusion rules visible to user'
/
comment on column ALL_GOLDENGATE_CONTAINER_RULES.RULE_ID is
'Rule identifier'
/
comment on column ALL_GOLDENGATE_CONTAINER_RULES.CAPTURE_NAME is
'Capture instance name'
/
comment on column ALL_GOLDENGATE_CONTAINER_RULES.FILTER_RULE is
'Wilcard card expression for inclusion or exclusion'
/
comment on column ALL_GOLDENGATE_CONTAINER_RULES.INCLUDE_RULE is
'Whether an inclusion or exclusion rule'
/
comment on column ALL_GOLDENGATE_CONTAINER_RULES.ESCAPE_CHAR is
'Escape character used in the filter rule'
/
create or replace public synonym ALL_GOLDENGATE_CONTAINER_RULES
  for ALL_GOLDENGATE_CONTAINER_RULES
/
grant select on ALL_GOLDENGATE_CONTAINER_RULES to select_catalog_role
/

----------------------------------------------------------------------------
--  DBA_REPL_DBNAME_MAPPING
----------------------------------------------------------------------------
create or replace view dba_repl_dbname_mapping
  (source_root_name, source_database_name, source_container_name)
as select
  source_root_name, source_database_name, source_container_name
from repl$_dbname_mapping
/
comment on table DBA_REPL_DBNAME_MAPPING is
'Details about the database name mapping'
/
comment on column DBA_REPL_DBNAME_MAPPING.SOURCE_ROOT_NAME is
'The fully qualified global name of the root container in a consolidated database where the LCRs originated'
/
comment on column DBA_REPL_DBNAME_MAPPING.SOURCE_DATABASE_NAME is
'The fully qualified global name of the database where the LCRs originated'
/
comment on column DBA_REPL_DBNAME_MAPPING.SOURCE_CONTAINER_NAME is
'The short container name of the database where the LCRs originated'
/
create or replace public synonym dba_repl_dbname_mapping
  for dba_repl_dbname_mapping
/
grant select on dba_repl_dbname_mapping to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_REPL_DBNAME_MAPPING','CDB_REPL_DBNAME_MAPPING');
grant select on SYS.CDB_repl_dbname_mapping to select_catalog_role
/
create or replace public synonym CDB_repl_dbname_mapping for SYS.CDB_repl_dbname_mapping
/

----------------------------------------------------------------------------
create or replace view all_repl_dbname_mapping
  (source_root_name, source_database_name, source_container_name)
as select
  source_root_name, source_database_name, source_container_name
from repl$_dbname_mapping
/
comment on table ALL_REPL_DBNAME_MAPPING is
'Details about the database name mapping'
/
comment on column ALL_REPL_DBNAME_MAPPING.SOURCE_ROOT_NAME is
'The fully qualified global name of the root container in a consolidated database where the LCRs originated'
/
comment on column ALL_REPL_DBNAME_MAPPING.SOURCE_DATABASE_NAME is
'The fully qualified global name of the database where the LCRs originated'
/
comment on column ALL_REPL_DBNAME_MAPPING.SOURCE_CONTAINER_NAME is
'The short container name of the database where the LCRs originated'
/
create or replace public synonym all_repl_dbname_mapping
  for all_repl_dbname_mapping
/

grant read on ALL_REPL_DBNAME_MAPPING to public with grant option
/

@?/rdbms/admin/sqlsessend.sql
