Rem
Rem $Header: rdbms/admin/dbmsapre.sql /main/3 2016/08/25 16:22:23 yulcho Exp $
Rem
Rem dbmsapre.sql
Rem
Rem Copyright (c) 2015, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsapre.sql - Application Resilience API
Rem
Rem    DESCRIPTION
Rem      PL/SQL interface for disrupting sessions and/or services
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsapre.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yulcho      06/07/16 - default value of 'instance_names' is changed
Rem    yulcho      02/26/16 - user_names is added in disrupt_sessions
Rem    yulcho      01/28/16 - remove callback parameters
Rem    yulcho      10/20/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_disrupt AUTHID DEFINER IS

  ---------------------------
  -- PROCEDURES AND FUNCTIONS
  --
  PROCEDURE disrupt_sessions(
              job_name       IN VARCHAR2,
              user_names     IN VARCHAR2 := '?',
              service_names  IN VARCHAR2 := '*',
              instance_names IN VARCHAR2 := '?',
              module_names   IN VARCHAR2 := '*',
              percentage     IN NUMBER,
              sleep_interval IN NUMBER,
              duration       IN NUMBER   := 0,
              output_file    IN VARCHAR2 := NULL
            );

  PROCEDURE disrupt_sessions_immediate(
              user_names     IN VARCHAR2 := '*',
              service_names  IN VARCHAR2 := '*',
              instance_names IN VARCHAR2 := '?',
              module_names   IN VARCHAR2 := '*',
              percentage     IN NUMBER,
              output_file    IN VARCHAR2 := NULL);

  PROCEDURE disrupt_sessions_cancel(
              job_name       IN VARCHAR2 := '*'
            );

  PROCEDURE disrupt_services(
              job_name       IN VARCHAR2,
              service_names  IN VARCHAR2 := '*',
              instance_names IN VARCHAR2 := '?',
              percentage     IN NUMBER,
              sleep_interval IN NUMBER,
              stop_interval  IN NUMBER   := 0,
              duration       IN NUMBER   := 0,
              output_file    IN VARCHAR2 := NULL
            );

  PROCEDURE disrupt_services_immediate(
              job_name       IN VARCHAR2,
              service_names  IN VARCHAR2 := '*',
              instance_names IN VARCHAR2 := '?',
              percentage     IN NUMBER,
              stop_interval  IN NUMBER,
              output_file    IN VARCHAR2 := NULL);

  PROCEDURE disrupt_services_cancel(
              job_name       IN VARCHAR2 := '*'
            );

  PROCEDURE wake_up_service(
              service_name   IN VARCHAR2,
              instance_name  IN VARCHAR2,
              output_file    IN VARCHAR2 := NULL);

  -------------
  -- CONSTANTS
  --
  all_users       CONSTANT VARCHAR2(2) := '*';
  cur_user        CONSTANT VARCHAR2(2) := '?';
  all_instances   CONSTANT VARCHAR2(2) := '*';
  cur_instance    CONSTANT VARCHAR2(2) := '?';
  all_services    CONSTANT VARCHAR2(2) := '*';
  all_modules     CONSTANT VARCHAR2(2) := '*';

END;
/

@?/rdbms/admin/sqlsessend.sql
