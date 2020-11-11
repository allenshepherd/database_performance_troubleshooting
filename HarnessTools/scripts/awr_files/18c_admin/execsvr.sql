Rem
Rem $Header: rdbms/admin/execsvr.sql /main/5 2016/10/03 10:44:21 sroesch Exp $
Rem
Rem execsvr.sql
Rem
Rem Copyright (c) 2006, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execsvr.sql - run PL/sql and sql in order to define
Rem                    and activate the Kernel Service Workgroup 
Rem                    Services.   
Rem
Rem    DESCRIPTION
Rem      Defines and starts the AQ queues required to support
Rem      the Kernel Service Workgroup Services.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/execsvr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/execsvr.sql
Rem SQL_PHASE: EXECSVR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sroesch     09/12/16 - 24539642: Check if queue already exists
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    arogers     10/23/06 - 5572026 - issue sql instead of kswssetupaq
Rem    arogers     10/23/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Clean up any previous definitions.
DECLARE
  num_queues       NUMBER;
  num_queue_tables NUMBER;
  num_subscribers  NUMBER;
  num_trans        NUMBER;

  ok               BOOLEAN;

  subscriber       sys.aq$_agent;
BEGIN
  -- Determine if RLB queue is already defined
  select count (*)
    into num_queues
    from dba_queues
   where owner       = 'SYS'
     and name        = 'SYS$SERVICE_METRICS'
     and queue_table = 'SYS$SERVICE_METRICS_TAB'
     and queue_type  = 'NORMAL_QUEUE';

  -- Determine if RLB queue table has been defined
  select count(*)
    into num_queue_tables
    from dba_queue_tables
   where owner       = 'SYS'
     and queue_table = 'SYS$SERVICE_METRICS_TAB'
     and type        = 'OBJECT';

  -- Determine the number of RLB queue subscribers
  select count(*)
    into num_subscribers
    from dba_queue_subscribers
   where owner       = 'SYS'
     and queue_name  = 'SYS$SERVICE_METRICS'
     and queue_table = 'SYS$SERVICE_METRICS_TAB'
     and consumer_name in ('SCHEDULER$_LBAGT', 'SYS$RLB_GEN_SUB');

  -- Determine the number of RLB transformations
  select count(*)
    into num_trans
    from dba_transformations
   where owner = 'SYS'
     and name in('SYS$SERVICE_METRICS_TS', 'SYS$SERVICE_METRICS_GEN_TS');

  -- Check if all the expected objects have been created
  ok :=     (num_queues       = 1)
        and (num_queue_tables = 1)
        and (num_subscribers  = 2)
        and (num_trans        = 2);

  -- Clean up any previous definitions if required
  IF NOT ok THEN
    BEGIN
     dbms_aqadm.remove_subscriber(
       queue_name => 'SYS$SERVICE_METRICS',
       subscriber => sys.aq$_agent('SYS$RLB_GEN_SUB', null, null));
    EXCEPTION
    WHEN others THEN
      IF sqlcode = -24035  or sqlcode = -24010 THEN NULL;
         -- suppress error for non-existent subscriber/queue
      ELSE raise;
      END IF;
    END;

    BEGIN
     dbms_transform.drop_transformation('SYS','SYS$SERVICE_METRICS_GEN_TS');
    EXCEPTION
    WHEN others THEN
      IF sqlcode = -24185 THEN NULL;
           -- suppress error for non-existent transformation
      ELSE raise;
      END IF;
    END;

    BEGIN
     dbms_transform.drop_transformation('SYS','SYS$SERVICE_METRICS_TS');
    EXCEPTION
    WHEN others THEN
      IF sqlcode = -24185 THEN NULL;
           -- suppress error for non-existent transformation
      ELSE raise;
       END IF;
    END;

    BEGIN
     dbms_aqadm.stop_queue('SYS$SERVICE_METRICS');
    EXCEPTION
      WHEN others THEN
      IF sqlcode = -24010 THEN NULL;
           -- suppress error for non-existent queue
      ELSE raise;
      END IF;
    END;

    BEGIN
     dbms_aqadm.drop_queue('SYS$SERVICE_METRICS');
    EXCEPTION
    WHEN others THEN
      IF sqlcode = -24010 THEN NULL;
         -- suppress error for non-existent queue
      ELSE raise;
      END IF;
    END;

    BEGIN
     dbms_aqadm.drop_queue_table('SYS$SERVICE_METRICS_TAB');
    EXCEPTION
    WHEN others THEN
      IF sqlcode = -24002 THEN NULL;
        -- suppress error for non-existent queue table
      ELSE raise;
      END IF;
    END;

    -- Define queues, types and start.
    EXECUTE IMMEDIATE 'CREATE OR REPLACE TYPE SYS$RLBTYP as object (srv VARCHAR2(1024), payload VARCHAR2(4000))';

    BEGIN
      DBMS_AQADM.CREATE_QUEUE_TABLE(
        'SYS$SERVICE_METRICS_TAB',
        'SYS$RLBTYP',
        'tablespace sysaux, storage (INITIAL 1M next 1M pctincrease 0)',
        NULL, TRUE);
    END;

    BEGIN
      DBMS_AQADM.CREATE_QUEUE('SYS$SERVICE_METRICS',
                              queue_table    => 'SYS$SERVICE_METRICS_TAB',
                              retention_time => 3600);
    END;
  END IF;

  -- Start the queue
  BEGIN
    DBMS_AQADM.START_QUEUE('SYS$SERVICE_METRICS', TRUE, TRUE);
  END;

  IF NOT ok
  THEN
    BEGIN
      DBMS_TRANSFORM.CREATE_TRANSFORMATION(
        'SYS',
        'SYS$SERVICE_METRICS_TS',
        'SYS',
        'SYS$RLBTYP',
        'SYS',
        'VARCHAR2',
        'source.user_data.payload');
    END;

    BEGIN
      DBMS_TRANSFORM.CREATE_TRANSFORMATION(
        'SYS',
        'SYS$SERVICE_METRICS_GEN_TS',
        'SYS',
        'SYS$RLBTYP',
        'SYS',
        'SYS$RLBTYP',
        'source.user_data');
    END;

    BEGIN
      subscriber := sys.aq$_agent('SYS$RLB_GEN_SUB', NULL, NULL);

      dbms_aqadm_sys.add_subscriber(
        queue_name     => 'SYS.SYS$SERVICE_METRICS',
        subscriber     => subscriber,
        transformation => 'SYS.SYS$SERVICE_METRICS_GEN_TS');
    END;
  END IF;
END;
/

@?/rdbms/admin/sqlsessend.sql
