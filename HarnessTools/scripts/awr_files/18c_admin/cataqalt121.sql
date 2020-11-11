Rem
Rem $Header: rdbms/admin/cataqalt121.sql /main/6 2017/10/25 18:01:32 raeburns Exp $
Rem
Rem cataqalt121.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cataqalt121.sql - Long identifier alter aq types
Rem
Rem    DESCRIPTION
Rem      This file needs to be executed after all dependent aq type creation
Rem      to maintain old/new type hashcodes.  It is required by export/import
Rem      and jdbc driver to pick correct type definition. This needs to be
Rem      executed after catqueue/catrule/cataqjms scripts.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cataqalt121.sql 
Rem    SQL_SHIPPED_FILE:rdbms/admin/cataqalt121.sql 
Rem    SQL_PHASE: CATAQALT121
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE:rdbms/admin/catpspec.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: correct SQLPHASE
Rem    raeburns    02/29/16 - Bug 22820096: revert ALTER TYPE to default
Rem                           CASCADE
Rem    skabraha    11/23/15 - RTI 18785613 upgrade aq$_replay_info
Rem    raeburns    11/11/15 - RTI 18745976: move ALTER TABLE for
Rem                           sys.aq_event_table
Rem    raeburns    09/25/15 - add NOT INCLUDING TABLE DATA
Rem    atomar      08/24/15 - alter aq types
Rem    atomar      08/24/15 - Created
Rem

Rem  
@@?/rdbms/admin/sqlsessstart.sql

alter type sys.aq$_event_message modify attribute 
           (sub_name varchar2(512),
            queue_name varchar2(261), 
            consumer_name varchar2(512), 
            exception_queue varchar2(128),
            agent_name varchar2(512)) 
            CASCADE;
alter type sys.aq$_agent modify attribute 
           (name varchar2(512)) CASCADE;
alter type sys.aq$_dequeue_history modify attribute 
           (consumer varchar2(512)) CASCADE;
alter type sys.msg_prop_t modify attribute 
           (exception_queue varchar2(128)) CASCADE;
alter type sys.aq$_descriptor modify attribute 
           (queue_name varchar2(261),
            consumer_name varchar2(512)) CASCADE;
alter type sys.aq$_reg_info modify attribute 
           (name varchar2(512)) CASCADE;
alter type sys.aq$_post_info modify attribute 
           (name varchar2(512)) CASCADE;
alter type aq$_srvntfn_message modify attribute 
          (queue_name varchar2(261),
           consumer_name varchar2(512), 
           exception_queue varchar2(128),
           agent_name varchar2(512), 
           sub_name varchar2(512)) CASCADE;
alter type sys.aq$_subscriber modify attribute 
           (name varchar2(512),
            trans_name varchar2(261), 
            rule_name varchar2(128)) CASCADE;
alter type sys.re$rule_hit modify attribute 
           (rule_name varchar2(261)) CASCADE;
alter type sys.re$nv_node modify attribute 
           (nvn_name varchar2(128)) CASCADE;
alter type sys.re$name_array modify element type varchar2(128) 
           CASCADE;
alter type sys.re$table_alias modify attribute 
          (table_alias varchar2(130),
           table_name varchar2(261)) CASCADE;
alter type sys.re$variable_type modify attribute 
          (variable_name varchar2(130)) CASCADE;
alter type sys.re$table_value modify attribute 
           (table_alias varchar2(130)) CASCADE;
alter type sys.re$column_value modify attribute 
           (table_alias varchar2(130)) CASCADE;
alter type sys.re$variable_value modify attribute 
           (variable_name varchar2(130)) CASCADE;
alter type sys.re$attribute_value modify attribute 
           (variable_name varchar2(130)) CASCADE;
alter type sys.re$rule_list modify element type varchar2(261) 
           CASCADE;

@?/rdbms/admin/sqlsessend.sql
