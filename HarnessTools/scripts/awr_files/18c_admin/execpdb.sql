Rem
Rem $Header: rdbms/admin/execpdb.sql /main/3 2017/03/17 08:00:27 sursridh Exp $
Rem
Rem execpdb.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execpdb.sql - Execute actions for PDB area.
Rem
Rem    DESCRIPTION
Rem      Execute actions for pdb area.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/execpdb.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/execpdb.sql
Rem    SQL_PHASE: EXECPDB
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sursridh    03/06/17 - Bug 25683998: Remove events views.
Rem    sursridh    02/27/17 - Bug 25632095: Add retention to events queue
Rem    sursridh    12/23/16 - Support for PDB event notification.
Rem    sursridh    12/23/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Payload event type.
create type pdb_mon_event_type$ as object (
  event_info clob
);
/
show errors;

-- Create/start queue for storing raw PDB events.
begin
  dbms_aqadm.create_queue_table (
    queue_table => 'pdb_mon_event_qtable$',
    queue_payload_type => 'pdb_mon_event_type$',
    multiple_consumers => true,
    storage_clause => 'tablespace sysaux',
    comment => 'Raw queue table containing event information'
  );
  dbms_aqadm.create_queue(
    queue_name => 'pdb_mon_event_queue$',
    queue_table =>'pdb_mon_event_qtable$',
    retention_time => 86400,
    comment => 'Queue for raw pdb event information'
  );
  dbms_aqadm.start_queue('pdb_mon_event_queue$');
exception
  when others then
    if sqlcode = -24001 or sqlcode = -26001
    then
      null;
    else
      raise;
    end if;
end;
/
show errors;

@?/rdbms/admin/sqlsessend.sql
 
