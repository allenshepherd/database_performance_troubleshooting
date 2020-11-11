Rem Copyright (c) 2009, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsadr.sql - Administrative interface for Auto. Diag. Repository
Rem
Rem    DESCRIPTION
Rem      Declares the dbms_adr package (src/server/diagfw/adr/ami/prvtadr.sql)
Rem
Rem    NOTES
Rem      The PL/SQL diagnosability API declared in this package is intended
Rem      for use by internal RDBMS PL/SQL applications only.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsadr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsadr.sql
Rem SQL_PHASE: DBMSADR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    svaziran    07/21/16 - bug 24325197: remove non const pkg variables
Rem    svaziran    05/05/16 - bug 23192127: support purge
Rem    svaziran    03/22/15 - bug 19217529: add cdb support for write_log
Rem    svaziran    02/26/15 - bug 20584304: support tracefile_identifier
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    shiyadav    12/09/10 - PL/SQL diag
Rem    mfallen     04/12/09 - bug 6976775: add downgrade
Rem    mfallen     04/12/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

/**************************************************************************
 *      Package DBMS_ADR                                                  *
 **************************************************************************/

CREATE OR REPLACE PACKAGE dbms_adr AS

  -- **********************************************************************
  -- ODL message type constants 
  -- These are for use in adr_home_t.log(msg_type => ...)
  -- **********************************************************************

  log_msg_type_unknown      CONSTANT INTEGER := 1;                /* Unknown */
  log_msg_type_incident     CONSTANT INTEGER := 2;               /* Incident */
  log_msg_type_error        CONSTANT INTEGER := 3;                  /* Error */
  log_msg_type_warning      CONSTANT INTEGER := 4;                /* Warning */
  log_msg_type_notification CONSTANT INTEGER := 5;           /* Notification */
  log_msg_type_trace        CONSTANT INTEGER := 6;                  /* Trace */

  -- last call did not return an error
  NOERROR                   CONSTANT INTEGER := 0;

  -- purge default threshold
  PURGE_DEFAULT_THRESHOLD   CONSTANT NUMBER := 90;

  -- **********************************************************************  
  -- create_incident
  --    This routine creates an incident in the current ADR Home,
  --    which is always the RDBMS ADR home. It returns the incident 
  --    handle, which can be used for further manipulation of the 
  --    incident, e.g. registering additional files in the incident.
  -- **********************************************************************

  FUNCTION create_incident
  (
    problem_key             IN VARCHAR2,             /* incident problem key */
    error_facility          IN VARCHAR2 DEFAULT NULL,      /* error facility */
    error_number            IN INTEGER  DEFAULT NULL,        /* error number */
    error_message           IN VARCHAR2 DEFAULT NULL,       /* error message */
    error_args              IN adr_incident_err_args_t DEFAULT NULL,
                                                          /* error arguments */
    ecid                    IN VARCHAR2 DEFAULT NULL,/* execution context id */
    signalling_component    IN VARCHAR2 DEFAULT NULL,/* signalling component */
    signalling_subcomponent IN VARCHAR2 DEFAULT NULL, /* signalling subcomp. */
    suspect_component       IN VARCHAR2 DEFAULT NULL,   /* suspect component */
    suspect_subcomponent    IN VARCHAR2 DEFAULT NULL,    /* suspect subcomp. */
    correlation_keys        IN adr_incident_corr_keys_t DEFAULT NULL,
                                                         /* correlation keys */
    files                   IN adr_incident_files_t DEFAULT NULL
                                                /* additional incident files */
  )
  RETURN adr_incident_t;


  -- **********************************************************************
  -- write_trace
  --    This routine is used to write trace lines to the trace file
  --    in the ADR home.
  -- **********************************************************************

  PROCEDURE write_trace
  (
        trace_data          IN VARCHAR2
  );


  -- **********************************************************************
  -- write_log
  --    This routine is used to write log entries to the alert log
  --    in the ADR home.
  -- **********************************************************************

  PROCEDURE write_log
  (
    -- Mandatory ODL fields without defaults
    msg_id                  IN VARCHAR2,                       /* message id */
    msg_type                IN INTEGER,                      /* message type */
    msg_level               IN INTEGER,                     /* message level */
    msg_text                IN VARCHAR2,                     /* message text */
    
    -- Optional ODL fields and mandatory ones with defaults
    timestamp_originating   IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
                                                         /* time originating */
    timestamp_normalized    IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
                                                          /* time normalized */
    org_id                  IN VARCHAR2 DEFAULT NULL,     /* organization id */
    component_id            IN VARCHAR2 DEFAULT NULL,        /* component id */
    instance_id             IN VARCHAR2 DEFAULT NULL,         /* instance id */
    hosting_client_id       IN VARCHAR2 DEFAULT NULL,   /* hosting client id */
    msg_group               IN VARCHAR2 DEFAULT NULL,       /* message group */
    host_id                 IN VARCHAR2 DEFAULT NULL,             /* host id */
    host_nwaddr             IN VARCHAR2 DEFAULT NULL,        /* host address */
    module_id               IN VARCHAR2 DEFAULT NULL,           /* module id */
    process_id              IN VARCHAR2 DEFAULT NULL,          /* process id */
    thread_id               IN VARCHAR2 DEFAULT NULL,           /* thread id */
    user_id                 IN VARCHAR2 DEFAULT NULL,             /* user id */
    suppl_attrs             IN adr_log_msg_suppl_attrs_t DEFAULT NULL,
                                                  /* supplemental attributes */
    problem_key             IN VARCHAR2 DEFAULT NULL,         /* problem key */
    upstream_comp_id        IN VARCHAR2 DEFAULT NULL,   /* upstream comp. id */
    downstream_comp_id      IN VARCHAR2 DEFAULT NULL, /* downstream comp. id */
    ecid                    IN adr_log_msg_ecid_t DEFAULT NULL, 
                                                     /* execution context id */
    error_instance_id       IN adr_log_msg_errid_t DEFAULT NULL,
                                                        /* error instance id */
    msg_args                IN adr_log_msg_args_t DEFAULT NULL,
                                                        /* message arguments */
    detail_location         IN VARCHAR2 DEFAULT NULL,   /* detailed location */
    suppl_detail            IN VARCHAR2 DEFAULT NULL, /* supplemental detail */
    msg_template_obj        IN adr_msg_template_t DEFAULT NULL,
                                                  /* message template object */
    con_uid                 IN INTEGER DEFAULT NULL,  /* container unique ID */
    con_id                  IN INTEGER DEFAULT NULL,         /* container ID */
    con_name                IN VARCHAR2 DEFAULT NULL       /* container name */
  );


  -- **********************************************************************
  -- set_log_msg_template
  --    This routine creates a log message template object which can
  --    be used in the write_log API call. The purpose of the log message 
  --    template object is to avoid have to specify common parameters in
  --    each call to write_log. When passing a template object, optional
  --    parameters that were not set explicitly will be copied from the
  --    template object instead.
  -- **********************************************************************

  FUNCTION set_log_msg_template
  (
    org_id                  IN VARCHAR2 DEFAULT NULL,
    component_id            IN VARCHAR2 DEFAULT NULL,
    instance_id             IN VARCHAR2 DEFAULT NULL,
    hosting_client_id       IN VARCHAR2 DEFAULT NULL,
    msg_group               IN VARCHAR2 DEFAULT NULL,
    host_id                 IN VARCHAR2 DEFAULT NULL,
    host_nwaddr             IN VARCHAR2 DEFAULT NULL,
    module_id               IN VARCHAR2 DEFAULT NULL,
    process_id              IN VARCHAR2 DEFAULT NULL,
    thread_id               IN VARCHAR2 DEFAULT NULL,
    user_id                 IN VARCHAR2 DEFAULT NULL,
    upstream_comp_id        IN VARCHAR2 DEFAULT NULL,
    downstream_comp_id      IN VARCHAR2 DEFAULT NULL,
    ecid                    IN adr_log_msg_ecid_t DEFAULT NULL,
    error_instance_id       IN adr_log_msg_errid_t DEFAULT NULL,
  
    msg_args                IN adr_log_msg_args_t DEFAULT NULL,
    detail_location         IN VARCHAR2 DEFAULT NULL,
    suppl_detail            IN VARCHAR2 DEFAULT NULL,
    con_uid                 IN INTEGER DEFAULT NULL,
    con_id                  IN INTEGER DEFAULT NULL,
    con_name                IN VARCHAR2 DEFAULT NULL
  )
  RETURN adr_msg_template_t;


  -- **********************************************************************
  -- get_trace_location
  --    This routine returns the complete path of the trace directory in the
  --    ADR home.
  -- **********************************************************************

  FUNCTION get_trace_location RETURN VARCHAR2;


  -- **********************************************************************
  -- get_log_location
  --    This routine returns the complete path of the log directory in the
  --    ADR home.
  -- **********************************************************************

  FUNCTION get_log_location RETURN VARCHAR2;


  -- **********************************************************************
  -- set_exception_mode
  --    This routine sets the exception mode for the package.
  --    If exception mode is set to true, then all the exceptions 
  --    will be raised to client. If it is set to false, then all the 
  --    exceptions will be suppressed, and the client will not see any
  --    exception, even if underlying APIs are raising exceptions.
  -- 
  --    Since this is a diagnosability API, clients might not expect these
  --    API calls to raise their own exceptions.
  --    By default, exception mode will be set to false.
  --    Clients can change it any time by calling this function.
  -- **********************************************************************

  PROCEDURE set_exception_mode
  (
    exc_mode                IN BOOLEAN DEFAULT FALSE       /* exception mode */
  ); 

  -- **********************************************************************
  -- set_tracefile_identifier
  --    This routine is used to set a custom trace file identifier
  --    for the active tracefile.
  -- **********************************************************************

  PROCEDURE set_tracefile_identifier
  (
    trc_identifier          IN VARCHAR2
  );

  -- **********************************************************************
  -- run_purge
  --    This routine is used to purge diagnostics for the current
  --    container
  -- **********************************************************************

  PROCEDURE run_purge
  (
    threshold IN NUMBER DEFAULT PURGE_DEFAULT_THRESHOLD
  );

  -- **********************************************************************
  -- get_call_status
  --    This routine is used to obtain the status of the last call to the
  --    DBMS_ADR API. In case the previous call was successful, the value
  --    of this call will be NOERROR(0).
  -- **********************************************************************
  FUNCTION get_call_status RETURN NUMBER;

  -- **********************************************************************
  -- get_call_error_msg
  --    This routine is used to obtain the error message if the last call
  --    to DBMS_ADR API returned an error. In case the previous call was
  --    successful, the value returned by this API will be NULL.
  -- **********************************************************************
  FUNCTION get_call_error_msg RETURN VARCHAR2;
  
  -- **********************************************************************
  -- migrate_schema
  --   This routine migrates the ADR home to the current version.
  --
  -- Input arguments:
  --   none
  -- **********************************************************************

  PROCEDURE migrate_schema;


  -- **********************************************************************
  -- downgrade_schema
  --   This routine downgrades the ADR home by restoring files.
  --
  -- Input arguments:
  --   none
  -- **********************************************************************

  PROCEDURE downgrade_schema;


  -- **********************************************************************
  -- recover_schema
  --   This routine tries to bring the ADR home to a consistent state
  --   after a failed migrate or downgrade operation.
  --
  -- Input arguments:
  --   none
  -- **********************************************************************

  PROCEDURE recover_schema;


  -- **********************************************************************
  -- cleanout_schema()
  --   This routine recreates the ADR home, without any diagnostic contents.
  --
  -- Input arguments:
  --   none
  -- **********************************************************************

  PROCEDURE cleanout_schema;


END dbms_adr;
/


-- **********************************************************************
-- create public synonyms
-- **********************************************************************

CREATE OR REPLACE PUBLIC SYNONYM dbms_adr FOR sys.dbms_adr;

-- **********************************************************************
-- grant permissions to dba
-- **********************************************************************

GRANT EXECUTE ON dbms_adr TO dba;

CREATE OR REPLACE LIBRARY dbms_adr_lib TRUSTED IS STATIC;
/
show errors;




@?/rdbms/admin/sqlsessend.sql
