Rem
Rem $Header: rdbms/admin/dbmsadro.sql /main/6 2015/08/19 11:54:52 raeburns Exp $
Rem
Rem dbmsadro.sql
Rem
Rem Copyright (c) 2011, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsadro.sql - DBMS ADR Onjects
Rem
Rem    DESCRIPTION
Rem      Declares ADR objects used in PL/SQL interface to ADR 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsadro.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsadro.sql
Rem SQL_PHASE: DBMSADRO
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptyps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    06/09/15 - Use FORCE for types with only type dependents
Rem    svaziran    05/26/15 - 21143666: liden: user_id to 128
Rem    svaziran    03/22/15 - 19217529: update adr_log_msg_t
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    shiyadav    06/12/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


-- **********************************************************************
-- ADR home object 
--    This object represents the ADR home in ADR repository.
--    It serves as the interface to be used for ADR home operations.
--    Supports incident creation and ODL message logging.
-- **********************************************************************

CREATE OR REPLACE TYPE adr_home_t FORCE AS OBJECT
(
  product_type          VARCHAR2(8),                        /* product type */
  product_id            VARCHAR2(30),                         /* product id */
  instance_id           VARCHAR2(30),                        /* instance id */
  precedence            INTEGER,       /* precedence level of this adr home */
  adr_id                INTEGER,              /* hash value of the adr home */


-- **********************************************************************  
-- Construct an ADR home object representing ADR home at a location 
-- described by application specific naming
-- **********************************************************************

  CONSTRUCTOR FUNCTION adr_home_t
  (
    SELF IN OUT NOCOPY  adr_home_t,
    product_type        VARCHAR2,
    product_id          VARCHAR2,
    instance_id         VARCHAR2,
    precedence          INTEGER
  )
  RETURN SELF AS RESULT
);
/
show errors


-- **********************************************************************
-- Incident error arguments
-- **********************************************************************

CREATE OR REPLACE TYPE adr_incident_err_args_t FORCE AS 
  VARRAY(12) OF VARCHAR2(64);
/
show errors


-- **********************************************************************
-- Incident correlation key
-- **********************************************************************

CREATE OR REPLACE TYPE adr_incident_corr_key_t FORCE AS OBJECT
(
  name                  VARCHAR2(64),                /* correlation key name */
  value                 VARCHAR2(512),               /* correlation key value*/
  flags                 INTEGER                     /* correlation key flags */
);
/
show errors


-- **********************************************************************
-- List of incident correlation keys
-- **********************************************************************

CREATE OR REPLACE TYPE adr_incident_corr_keys_t FORCE AS 
  VARRAY(10) OF adr_incident_corr_key_t;
/
show errors


-- **********************************************************************
-- Incident file (file that contains incident diagnostic data
-- or intended to be registered with the incident)
-- **********************************************************************

CREATE OR REPLACE TYPE adr_incident_file_t FORCE AS OBJECT
(
  dirpath               VARCHAR2(512),         /* directory path of the file */
  filename              VARCHAR2(64)                            /* file name */
);
/
show errors


-- **********************************************************************
-- List of incident files
-- **********************************************************************

CREATE OR REPLACE TYPE adr_incident_files_t FORCE AS 
  VARRAY(10) OF adr_incident_file_t;
/
show errors


-- **********************************************************************
-- Internal type that holds pending incident information
-- Do not use this directly
-- **********************************************************************

CREATE OR REPLACE TYPE adr_incident_info_t FORCE AS OBJECT
(
  problem_key             VARCHAR2(64),       /* problem key of the incident */
  error_facility          VARCHAR2(10),                    /* error facility */
  error_number            INTEGER,                           /* error number */
  error_message           VARCHAR2(1024),                   /* error message */
  ecid                    VARCHAR2(64),              /* execution context id */
  signalling_component    VARCHAR2(64),              /* signalling component */
  signalling_subcomponent VARCHAR2(64),          /* signalling sub component */
  suspect_component       VARCHAR2(64),                 /* suspect component */
  suspect_subcomponent    VARCHAR2(64),             /* suspect sub component */
  error_args              adr_incident_err_args_t,        /* error arguments */
  correlation_keys        adr_incident_corr_keys_t,      /* correlation keys */
  files                   adr_incident_files_t  /* additional incident files */
);
/
show errors



-- **********************************************************************
-- Incident object
-- This serves as the interface to adding data/metadata to the incident
-- **********************************************************************

CREATE OR REPLACE TYPE adr_incident_t AS OBJECT
(
  home                   adr_home_t,           /* adr home for this incident */
  id                     INTEGER,                             /* incident id */
  staged                 VARCHAR2(1),                  /* is staged incident */
  in_update              VARCHAR2(1),         /* is in the process of update */
  pending                adr_incident_info_t,            /* for internal use */
   

  -- **********************************************************************
  -- Gets the id of this incident
  -- **********************************************************************

  MEMBER FUNCTION get_id RETURN INTEGER,
  

  -- **********************************************************************
  -- Gets the path to the directory where incident diagnostic files reside
  -- Value is <ADR_HOME>/incident/incdir_<ID>
  -- **********************************************************************

  MEMBER FUNCTION get_incident_location RETURN VARCHAR2,


  -- **********************************************************************
  -- Writes diagnostics to the default incident file
  -- **********************************************************************

  MEMBER PROCEDURE dump_incident
  (
    SELF     IN OUT NOCOPY adr_incident_t,
    data     IN VARCHAR2                    /* data to dump in incident file */
  ),


  -- **********************************************************************
  -- Writes RAW diagnostics to the default incident file
  -- **********************************************************************

  MEMBER PROCEDURE dump_incident_raw
  (
    SELF     IN OUT NOCOPY adr_incident_t,
    data     IN RAW                     /* RAW data to dump in incident file */
  ),


  -- **********************************************************************
  -- Writes diagnostics to a specified incident file in the incident
  -- directory
  -- **********************************************************************

  MEMBER PROCEDURE dump_incfile
  (
    SELF     IN OUT NOCOPY adr_incident_t,
    filename IN VARCHAR2,          /* additional incident file to be created */
    data     IN VARCHAR2                       /* data to dump in above file */
  ),


  -- **********************************************************************
  -- Writes raw diagnostic data to the specified incident file in the
  -- incident directory 
  -- **********************************************************************

  MEMBER PROCEDURE dump_incfile_raw
  (
    SELF     IN OUT NOCOPY adr_incident_t,
    filename IN VARCHAR2,          /* additional incident file to be created */
    data     IN RAW                        /* RAW data to dump in above file */
  ),
 

  -- **********************************************************************
  -- Adds correlation key to this incident
  -- **********************************************************************

  MEMBER PROCEDURE add_correlation_key 
  (
    SELF     IN OUT NOCOPY adr_incident_t,
    name     IN VARCHAR2,                            /* correlation key name */
    value    IN VARCHAR2,                           /* correlation key value */
    flags    IN INTEGER DEFAULT NULL                /* correlation key flags */
  ),
  

  -- **********************************************************************
  -- Registers a file with this incident. 
  -- The file can be anywhere in ADR home.
  -- **********************************************************************

  MEMBER PROCEDURE register_file 
  (
    SELF     IN OUT NOCOPY adr_incident_t,
    dirpath  IN VARCHAR2,                      /* directory path of the file */
    filename IN VARCHAR2                                        /* file name */
  ),
  

  -- **********************************************************************
  -- Registers a file in incident directory with this incident
  -- **********************************************************************

  MEMBER PROCEDURE register_file 
  (
    SELF     IN OUT NOCOPY adr_incident_t,
    filename IN VARCHAR2                                        /* file name */
  ),


  -- **********************************************************************
  -- Marks the beginning of post-create updates to this incident
  --  This should be used to add correlation keys, adding additional
  --  incident files and other incident metadata changes after
  --  the incident has already been created
  -- **********************************************************************

  MEMBER PROCEDURE begin_update(SELF IN OUT NOCOPY adr_incident_t),
  

  -- **********************************************************************
  -- Marks the end of post-create updates to this incident
  --  begin_update and end_update must always be used together
  -- **********************************************************************

  MEMBER PROCEDURE end_update(SELF IN OUT NOCOPY adr_incident_t)
);
/
show errors

-----------------------------------------------------------------------
--  ODL log message intended to be written to ADR
-----------------------------------------------------------------------


-- **********************************************************************
-- Supplemental attribute
-- **********************************************************************

CREATE OR REPLACE TYPE adr_log_msg_suppl_attr_t FORCE AS OBJECT
(
  name       VARCHAR2(64),                                 /* attribute name */
  value      VARCHAR2(128)                                /* attribute value */
);
/
show errors


-- **********************************************************************
-- List of supplemental attributes
-- **********************************************************************

CREATE OR REPLACE TYPE adr_log_msg_suppl_attrs_t FORCE AS 
  VARRAY(32) OF adr_log_msg_suppl_attr_t;
/
show errors


-- **********************************************************************
-- Message argument
-- **********************************************************************

CREATE OR REPLACE TYPE adr_log_msg_arg_t FORCE AS OBJECT
(
  name       VARCHAR2(64),                      /* log message argument name */
  value      VARCHAR2(128)                     /* log message argument value */
);
/
show errors


-- **********************************************************************
-- List of message arguments
-- **********************************************************************

CREATE OR REPLACE TYPE adr_log_msg_args_t FORCE AS VARRAY(32) OF adr_log_msg_arg_t;
/
show errors


-- **********************************************************************
-- Execution context id
-- **********************************************************************

CREATE OR REPLACE TYPE adr_log_msg_ecid_t FORCE AS OBJECT
(
  id         VARCHAR2(100),                          /* execution context id */
  rid        VARCHAR2(100)                  /* execution context sequence id */
);
/
show errors


-- **********************************************************************
-- Error id
-- **********************************************************************

CREATE OR REPLACE TYPE adr_log_msg_errid_t FORCE AS OBJECT
(
  id         VARCHAR2(100),                             /* error instance id */
  rid        VARCHAR2(100)                              /* error sequence id */
);
/
show errors


-- **********************************************************************
-- Log message template object
--  used to store common log parameters to avoid giving values
--  to those common parameter again and again in write_log call
-- **********************************************************************

CREATE OR REPLACE TYPE adr_msg_template_t AS OBJECT
(
  org_id                 VARCHAR2(64),                    /* organization id */
  component_id           VARCHAR2(64),                       /* component id */
  instance_id            VARCHAR2(64),                        /* instance id */
  hosting_client_id      VARCHAR2(64),                  /* hosting client id */
  msg_group              VARCHAR2(64),                      /* message group */
  host_id                VARCHAR2(64),                            /* host id */
  host_nwaddr            VARCHAR2(46),                       /* host address */
  module_id              VARCHAR2(64),                         /* module id  */
  process_id             VARCHAR2(32),                        /* process id  */
  thread_id              VARCHAR2(64),                         /* thread id  */
  user_id                VARCHAR2(128),                          /* user id  */
  upstream_comp_id       VARCHAR2(64),             /* upstream component id  */
  downstream_comp_id     VARCHAR2(64),           /* downstream component id  */
  ecid                   adr_log_msg_ecid_t,        /* execution context id  */
  error_instance_id      adr_log_msg_errid_t,          /* error instance id  */
  msg_args               adr_log_msg_args_t,           /* message arguments  */
  detail_location        VARCHAR2(160),                /* detailed location  */
  suppl_detail           VARCHAR2(128),             /* supplemental details  */
  -- CDB fields
  con_uid                INTEGER,                     /* container unique ID */
  con_id                 INTEGER,                            /* container ID */
  con_name               VARCHAR2(30)                      /* container name */
);
/
show errors


-- **********************************************************************
-- Log message object
-- **********************************************************************

CREATE OR REPLACE TYPE adr_log_msg_t AS OBJECT
(
  -- Header attributes  
  timestamp_originating  TIMESTAMP WITH TIME ZONE,       /* time originating */
  timestamp_normalized   TIMESTAMP WITH TIME ZONE,        /* time normalized */
  org_id                 VARCHAR2(64),                    /* organization id */
  component_id           VARCHAR2(64),                       /* component id */
  instance_id            VARCHAR2(64),                        /* instance id */
  hosting_client_id      VARCHAR2(64),                  /* hosting client id */
  msg_id                 VARCHAR2(64),                         /* message id */
  msg_type               INTEGER,                            /* message type */
  msg_group              VARCHAR2(64),                      /* message group */
  msg_level              INTEGER,                           /* message level */
  host_id                VARCHAR2(64),                            /* host id */
  host_nwaddr            VARCHAR2(46),                       /* host address */
  module_id              VARCHAR2(64),                         /* module id  */
  process_id             VARCHAR2(32),                        /* process id  */
  thread_id              VARCHAR2(64),                         /* thread id  */
  user_id                VARCHAR2(128),                          /* user id  */
  suppl_attrs            adr_log_msg_suppl_attrs_t,
                                                  /* Supplemental attributes */
  
  -- Correlation data fields
  problem_key            VARCHAR2(64),                        /* problem key */
  upstream_comp_id       VARCHAR2(64),             /* upstream component id  */
  downstream_comp_id     VARCHAR2(64),           /* downstream component id  */
  ecid                   adr_log_msg_ecid_t,        /* execution context id  */
  error_instance_id      adr_log_msg_errid_t,          /* error instance id  */
  
  -- Payload
  msg_text               VARCHAR2(2048),                     /* message text */
  msg_args               adr_log_msg_args_t,            /* message arguments */
  detail_location        VARCHAR2(160),                /* detailed location  */
  suppl_detail           VARCHAR2(128),             /* supplemental details  */

  -- CDB fields
  con_uid                INTEGER,                     /* container unique ID */
  con_id                 INTEGER,                            /* container ID */
  con_name               VARCHAR2(30)                      /* container name */
);
/
show errors


CREATE OR REPLACE PUBLIC SYNONYM adr_home_t FOR sys.adr_home_t;
CREATE OR REPLACE PUBLIC SYNONYM adr_incident_t FOR sys.adr_incident_t;
CREATE OR REPLACE PUBLIC SYNONYM adr_incident_err_args_t 
  FOR sys.adr_incident_err_args_t;
CREATE OR REPLACE PUBLIC SYNONYM adr_incident_files_t 
  FOR sys.adr_incident_files_t;
CREATE OR REPLACE PUBLIC SYNONYM adr_incident_corr_keys_t 
  FOR sys.adr_incident_corr_keys_t;
CREATE OR REPLACE PUBLIC SYNONYM adr_log_msg_t FOR sys.adr_log_msg_t;
CREATE OR REPLACE PUBLIC SYNONYM adr_log_msg_ecid_t FOR sys.adr_log_msg_ecid_t;
CREATE OR REPLACE PUBLIC SYNONYM adr_log_msg_errid_t 
  FOR sys.adr_log_msg_errid_t;
CREATE OR REPLACE PUBLIC SYNONYM adr_log_msg_arg_t FOR sys.adr_log_msg_arg_t;
CREATE OR REPLACE PUBLIC SYNONYM adr_log_msg_args_t FOR sys.adr_log_msg_args_t;
CREATE OR REPLACE PUBLIC SYNONYM adr_log_msg_suppl_attrs_t 
  FOR sys.adr_log_msg_suppl_attrs_t;
CREATE OR REPLACE PUBLIC SYNONYM adr_log_msg_suppl_attr_t 
  FOR sys.adr_log_msg_suppl_attr_t;


GRANT EXECUTE ON adr_home_t TO dba;
GRANT EXECUTE ON adr_incident_t TO dba;
GRANT EXECUTE ON adr_incident_info_t TO dba;
GRANT EXECUTE ON adr_incident_files_t TO dba;
GRANT EXECUTE ON adr_incident_corr_keys_t TO dba;
GRANT EXECUTE ON adr_log_msg_t TO dba;
GRANT EXECUTE ON adr_log_msg_ecid_t TO dba;
GRANT EXECUTE ON adr_log_msg_errid_t TO dba;
GRANT EXECUTE ON adr_log_msg_args_t TO dba;
GRANT EXECUTE ON adr_log_msg_arg_t TO dba;
GRANT EXECUTE ON adr_log_msg_suppl_attrs_t TO dba;
GRANT EXECUTE ON adr_log_msg_suppl_attr_t TO dba;
/

show errors;

@?/rdbms/admin/sqlsessend.sql
