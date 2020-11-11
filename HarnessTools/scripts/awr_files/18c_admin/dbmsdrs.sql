@@?/rdbms/admin/sqlsessstart.sql
create or replace
PACKAGE dbms_drs IS
-- DE-HEAD2  <- tell SED where to cut when generating fixed package

-------------------------------------------------------------------------------
--
-- External constant definitions. These are used by DBMS_DRS.WAIT().
-- These definitions must match those defined in rfs.h.
--
-------------------------------------------------------------------------------

--
-- Pre-defined wait events
--
WAIT_START_DMON         CONSTANT PLS_INTEGER := 1;      -- Wait for DMON
                                                        -- to start.

WAIT_STOP_DMON          CONSTANT PLS_INTEGER := 2;      -- Wait for DMON
                                                        -- to stop.

WAIT_BOOT               CONSTANT PLS_INTEGER := 3;      -- Wait for:
                                                        -- - DMON to start
                                                        -- - bootstrap bit in
                                                        --   flags_rfmp to be
                                                        --   clear.

WAIT_BOOT_ENABLED       CONSTANT PLS_INTEGER := 4;      -- Wait for:
                                                        -- - DMON to start
                                                        -- - bootstrap bit in
                                                        --   flags_rfmp to be
                                                        --   clear.
                                                        -- - standby enable
                                                        --   pending bit in
                                                        --   broker state to be
                                                        --   clear.

WAIT_PREDEFINED_MAX     CONSTANT PLS_INTEGER := 4;      -- Maximum number of
                                                        -- predefined wait
                                                        -- events.

--
-- Flag based wait events.
--
WAIT_RFMP_FLAGS         CONSTANT PLS_INTEGER := 100;
WAIT_BROKER_STATE_FLAGS CONSTANT PLS_INTEGER := 101;

--
-- Wait for flags to be set or cleared.
--
WAIT_FLAGS_CLR          CONSTANT PLS_INTEGER := 0;
WAIT_FLAGS_SET          CONSTANT PLS_INTEGER := 1;

--
-- Status values returned from DBMS_DRS.WAIT().
--
-- NOTE: these definitions exactly match those defined in rferr.h. If
-- these errors are changes in rferr.h, they should be changed here as well.
--
RFC_DRSF_STATUS_BADARG          CONSTANT NUMBER := 16540;
RFC_DRSF_STATUS_TOUT            CONSTANT NUMBER := 16509;
RFC_DRSF_STATUS_NODRC           CONSTANT NUMBER := 16532;
RFC_DRSF_STATUS_NOTMEMBER       CONSTANT NUMBER := 16596;
RFC_DRSF_STATUS_ILLPRMYOP       CONSTANT NUMBER := 16585;

  -- ------------
  -- OVERVIEW
  -- ------------
  --
  -- This package contains procedures used in the DR Server (Hot Standby).
  -- There are two forms of each major function; one is a blocking procedure,
  -- which does not return until the command is completed. The other is a 
  -- non-blocking function which returns with a request identifier which may
  -- be used to return the result of the command. 
  --
  --------------------------
  -- NON-BLOCKING FUNCTIONS
  --------------------------
  -- 
  -- There is 1 non-blocking function:
  --    do_control
  -- 
  -- These functions take an incoming document type described in the
  -- Design Specification for DR Server API. Before the document is parsed
  -- and processed, it is added to a request queue with a request id returned.
  -- Therefore, the only reason why the non-blocking functions would raise 
  -- an exception is when the request cannot be added to the request queue.
  -- 
  -- Once all pieces of the outgoing document have been retrieved, the
  -- user should delete the request using the 'delete_request' procedure.
  --
  --------------------------
  -- BLOCKING PROCEDURES
  --------------------------
  -- 
  -- There are several blocking procedures:
  --    do_control
  --    delete_request
  --    cancel_request
  --    get_property
  -- 
  -- With the exception of delete_request, cancel_request and get_property*, 
  -- all the blocking procedures work the same way: as with the 
  -- non-blocking functions, each command takes an incoming document type 
  -- described in the Design Specification for the DR Server API. 
  -- Unlike the non-blocking functions, the blocking functions wait until 
  -- the command completes before returning the first piece of the document. 
  -- All initial requests should request the first piece (piece=1). 
  --
  -- If there is only one piece of the outgoing document, then the procedure 
  -- returns the first and only piece with a NULL request id. The request id 
  -- is automatically deleted prior to returning from the procedure.
  --
  -- If there is more than one piece of the outgoing document, then the 
  -- procedure returns the request id along with the first piece of the 
  -- outgoing document. The user should continue to call the blocking function
  -- with increasing piece numbers until the last piece is retrieved. Prior
  -- to returning the last piece, the function autmatically deletes the request
  -- id and a NULL request id is returned to the user.
  --
  -- As with the non-blocking functions, the blocking procedures will not
  -- raise an exception unless they cannot make the request. The user should
  -- check the outgoing document for the results of the command issued.
  --
  -- The remaining blocking functions (delete_request, cancel_request,
  -- get_property*) may
  -- be used to delete, cancel a request, or get a named non-XML property 
  -- respectively. delete_request may be used with a valid request id that 
  -- was retrieved using either the blocking or non-blocking functions. 
  -- Deleting a request that hasn't completed is not permitted and will 
  -- raise an exception. To cancel a request that is in progress, use the 
  -- cancel_request function. The cancel request function will automatically 
  -- delete the request information after cancelling the request.
  --
  -- Note: Do not mix blocking and non-blocking functions using the request_id.
  --
  -- get_property* returns the first piece of a named property value that is
  -- identified by name rather than by object id. 
  --
  --
  -- ------------------------
  -- EXAMPLES
  -- ------------------------
  --
  -- ------------------------
  -- Non-blocking example
  -- ------------------------
  --
  -- declare
  --  rid integer;
  --  indoc varchar2(4000);
  --  outdoc varchar2(4000);
  --  p integer;
  -- begin
  --  indoc:='<dummy>foo</dummy>';
  --
  --  rid :=dbms_drs.do_control(indoc);
  --  dbms_output.put_line('Request_id = '|| rid);
  --
  --  outdoc :=NULL;
  --  p:=1;
  --  while (outdoc is null)
  --  loop
  --    -- should really sleep a couple of ms
  --
  --    outdoc:=dbms_drs.get_response(rid,p);
  --  end loop;
  --
  --  dbms_output.put_line(outdoc);
  --  begin
  --    while (outdoc is not NULL)
  --    loop
  --      p:=p+1;
  --    
  --      outdoc:=dbms_drs.get_response(rid,p);
  --
  --      dbms_output.put_line(outdoc);
  --    end loop;
  --  exception
  --    when no_data_found then
  --    -- we got past last piece
  --    NULL;
  --  end;
  --  dbms_drs.delete_request(rid);
  -- end;
  --
  -- ------------------------
  -- Blocking example
  -- ------------------------
  -- 
  -- declare
  --  rid integer;
  --  indoc varchar2(4000);
  --  outdoc varchar2(4000);
  --  p integer;
  -- begin
  --  p:=1;
  --  indoc:='<dummy>foo</dummy>';
  --  dbms_drs.do_control(indoc,outdoc,rid,p);
  --  dbms_output.put_line(outdoc);
  --
  --  p:=2;
  --  while(rid is NOT NULL)
  --  loop
  --    dbms_drs.do_control(indoc,outdoc,rid,p);
  --    dbms_output.put_line(outdoc);
  --    p:=p+1;
  --  end loop;
  -- end;
  --
  --
  -- ------------------------
  -- PROCEDURES AND FUNCTIONS
  -- ------------------------

  PROCEDURE do_control(
        indoc      IN     VARCHAR2,
        outdoc     OUT    VARCHAR2, 
        request_id IN OUT INTEGER,
        piece      IN     INTEGER,
        context    IN     VARCHAR2 default NULL );
  -- Control blocking API - OBSELETE, for test use only 
  --                      - See do_control_raw below
  -- Perform a control operation. This is the blocking form of the procedure.
  -- Input parameters:
  --    indoc      - the document containing the control commands. The 
  --                 document type (DDT) is DO_CONTROL.
  --    request_id - the request id for returning multiple output pieces 
  --                 must be NULL for the first piece.
  --    piece      - the piece of the output document to return. For new
  --                 requests, the piece must be 1. For values greater than
  --                 1, a valid request_id must be supplied.
  --    context    - the context of command, usually NULL.
  -- Output parameters:
  --    outdoc - the result of the command. DDT may be either RESULT or VALUE. 
  --    request_id - the request id for returning the next output piece
  --                 will be NULL if the current piece does not exist
  --                 or is the last piece.
  -- Exceptions:
  --   bad_request (ORA-16508)
  --

  PROCEDURE do_control_raw(
        indoc      IN     RAW,
        outdoc     OUT    RAW,
        request_id IN OUT INTEGER,
        piece      IN     INTEGER,
        context    IN     VARCHAR2 default NULL,
        client_id  IN     INTEGER  default 0 );
  -- Control blocking API - designed for solving NLS problem
  -- Send DG Broker control request. It is blocking call.
  -- Input parameters:
  --    indoc      - the document containing the control commands. The 
  --                 document type (DDT) is DO_CONTROL.
  --    request_id - the request id for returning multiple output pieces 
  --                 must be NULL for the first piece.
  --    piece      - the piece of the output document to return. For new
  --                 requests, the piece must be 1. For values greater than
  --                 1, a valid request_id must be supplied.
  --    context    - the context of command, usually NULL.
  --    client_id  - For clients to identify itself - GUI or CLI.
  --                 Default value is 0, which means not GUI nor CLI.
  --
  -- Output parameters:
  --    outdoc - the result of the command. DDT may be either RESULT or VALUE. 
  --    request_id - the request id for returning the next output piece
  --                 will be NULL if the current piece does not exist
  --                 or is the last piece.
  -- Exceptions:
  --   bad_request (ORA-16508)
  --

  FUNCTION do_control(indoc IN VARCHAR2) RETURN INTEGER;
  -- Control non-blocking API - OBSELETE, for test use only 
  --                          - See do_control_raw below
  -- Perform a control operation. This is the non-blocking form of the 
  -- procedure.
  -- Input parameters:
  --    indoc      - the document containing the control commands. The 
  --                 document type (DDT) is DO_CONTROL.
  -- Return Value: The request id for the request.
  --
  -- Exceptions:
  --   bad_request (ORA-16508)
  -- 

  FUNCTION do_control_raw( indoc IN RAW ) RETURN INTEGER;
  -- Control non-blocking API - designed for solving NLS problem
  -- Perform a control operation. This is the non-blocking form of the 
  -- procedure.
  -- Input parameters:
  --    indoc      - the document containing the control commands. The 
  --                 document type (DDT) is DO_CONTROL.
  -- Return Value: The request id for the request.
  --
  -- Exceptions:
  --   bad_request (ORA-16508)
  -- 

  FUNCTION get_response(rid IN INTEGER, piece IN INTEGER) RETURN VARCHAR2;
  -- Get Result (non-blocking) - OBSELETE, for test use only 
  --                           - See get_repsonse_raw below
  -- Get the result of a non-blocking command. If the command hasn't finished,
  -- the answer will be NULL. If the piece is beyond the end of the document
  -- the answer will be NULL.
  -- Input parameters:
  --    rid      - the request to delete.
  --    piece    - the piece to get, starting from 1.
  -- Returns:
  --    outdoc   - the answer to the request, if any, or NULL otherwise.
  -- 
  -- Exceptions:
  --   bad_request (ORA-16508)
  -- 

  FUNCTION get_response_raw(rid IN INTEGER, piece IN INTEGER) RETURN RAW;
  -- Get Result (non-blocking) - designed for solving NLS problem
  -- Get the result of a non-blocking command. If the command hasn't finished,
  -- the answer will be NULL. If the piece is beyond the end of the document
  -- the answer will be NULL.
  -- Input parameters:
  --    rid      - the request to delete.
  --    piece    - the piece to get, starting from 1.
  -- Returns:
  --    outdoc   - the answer to the request, if any, or NULL otherwise.
  -- 
  -- Exceptions:
  --   bad_request (ORA-16508)
  -- 

  PROCEDURE delete_request(rid in integer);
  -- Delete Request (blocking). 
  -- Input parameters:
  --    rid      - the request to delete.
  --
  -- Exceptions:
  --   bad_request (ORA-16508)
  -- 

  PROCEDURE cancel_request(rid in integer);
  -- Cancel Request (blocking).
  -- Input parameters:
  --    rid      - The request to cancel.
  --
  -- Exceptions:
  --   bad_request (ORA-16508)
  -- 
 
  FUNCTION get_property( site_name IN VARCHAR2, 
                     resource_name IN VARCHAR2,
                     property_name IN VARCHAR2) RETURN VARCHAR2;
  -- get_property 
  -- get a named property. This function is equivalent to using
  -- getid to return the object id, followed by a <do_monitor><property>
  --   request.
  --
  -- Input parameters:
  --    site_name  - The name of the site (optional). If omitted,
  --                 resource_name must be NULL and DRC properties are 
  --                 retrieved.
  --    resource_name  - The name of the resource (optional). If omitted,
  --                 then site DRC properties are retrieved. Otherwise,
  --                 resource properties are retrieved.
  --
  --    property_name - the name of the property to return. 
  --                 
  -- Output parameters:
  --    none
  -- Returns:
  --    The property value converted to a string. If the value_type is XML
  --    then the first 4000 bytes of the XML document are returned.
  -- Exceptions:
  --
 
  FUNCTION get_property_obj(object_id IN INTEGER,
   property_name IN VARCHAR2) RETURN VARCHAR2;
  -- get_property 
  -- get a named property. This function is equivalent to 
  -- calling a <DO_MONITOR><PROPERTY>...
  --   request and parsing the resulting string.
  --
  -- Input parameters:
  --    object_id  - The object_handle. 
  --    property_name - the name of the property to return. 
  --                 
  -- Output parameters:
  --    none
  -- Returns:
  --    The property value converted to a string. If the value_type is XML
  --    then the first 4000 bytes of the XML document are returned.
  -- Exceptions:
  --

  FUNCTION dg_broker_info( info_name IN VARCHAR2 ) RETURN VARCHAR2;
  -- get Data Guard Broker Information
  -- It now recognizes the following information names:
  --   'VERSION'   - the version of Data Guard Broker;
  --   'DMONREADY' - whether Data Guard Broker is ready to receive requests.
  -- Returns:
  --   The requested information specified by info_name, or
  --   'UNSUPPORTED' if info_name is not supported
  -- Exceptions:
  --   none
  --

  PROCEDURE sleep(seconds IN INTEGER);
  --
  -- Sleep (blocking).
  --
  -- Input parameters:
  --    seconds         - Number of seconds to sleep.
  --
  -- Output parameters:
  --    none
  --
  -- Exceptions:
  --   none
  -- 

  PROCEDURE dump_meta( options  IN INTEGER,
                       metafile IN VARCHAR2,
                       dumpfile IN VARCHAR2 );
  --
  -- DUMP data guard broker METAdata file content into a readable text file.
  --
  -- Input parameters:
  --    options         - Indicates which metafile(s) to be dumped
  --                        1 - the "current" metadata file
  --                        2 - the "alternate" metadata file
  --                        3 - first the "current", then the "alternate"
  --
  --    metafile        - Metadata filespec to be dumped. Must be NULL
  --                      since this feature is not supported.
  --
  --    dumpfile        - The readable output filespec.
  --
  -- Output parameters:
  --    None.
  --
  
  PROCEDURE Ping(iObid     IN  BINARY_INTEGER, 
                 iVersion  IN  BINARY_INTEGER,
                 iFlags    IN  BINARY_INTEGER,
                 iMiv      IN  BINARY_INTEGER,
                 oVersion  OUT BINARY_INTEGER,
                 oFlags    OUT BINARY_INTEGER,
                 oFoCond   OUT VARCHAR2,
                 oStatus   OUT BINARY_INTEGER);
  --
  -- The old ping procedure that was used in 12.1.0.1 and prior to 11.2.0.4.
  --
  -- This is the FSFO Ping procedure called by the observer on a periodic
  -- basis. The observer pings the primary and standby every 3 seconds to
  -- monitor the FSFO state and determine whether a FSFO state change is
  -- required, or whether FSFO is required.
  -- 
  -- Input parameters:
  --    iObid           - The Obsever ID (OBID).
  --
  --    iVersion        - The FSFO state version known to the observer.
  --
  --    iFlags          - The FSFO state flags known to the observer.
  --
  --    iMiv            - The FSFO Metadata Incarnation Version. This
  --                      argument is used to determine whether the observer
  --                      needs to refresh its FSFO-related property value
  --                      cache.
  --
  -- Output parameters:
  --    oVersion        - The FSFO state version known to the server. The
  --                      FSFO state version is used by the server and the
  --                      observer to determine which party has the most
  --                      recent FSFO state.
  --
  --    oFlags          - The FSFO state flags known to the server.
  --
  --    oFoCond         - This outpout parameter is used to let the observer
  --                      know whether a configurable FSFO condition was been
  --                      detected on the primary database.
  --
  --    ostatus         - Status returned by performing a ping operation.
  --

  PROCEDURE Ping(iObid     IN  BINARY_INTEGER, 
                 iVersion  IN  BINARY_INTEGER,
                 iFlags    IN  BINARY_INTEGER,
                 iMiv      IN  BINARY_INTEGER,
                 iWaitStat IN  BINARY_INTEGER,
                 oVersion  OUT BINARY_INTEGER,
                 oFlags    OUT BINARY_INTEGER,
                 oFoCond   OUT VARCHAR2,
                 oStatus   OUT BINARY_INTEGER);
  --
  -- Ping procedure since 12.1.0.2 ( and 11.2.0.4 )
  --
  -- This is the FSFO Ping procedure called by the observer on a periodic
  -- basis. The observer pings the primary and standby every 3 seconds to
  -- monitor the FSFO state and determine whether a FSFO state change is
  -- required, or whether FSFO is required.
  --
  -- Input parameters:
  --    iObid           - The Obsever ID (OBID).
  --
  --    iVersion        - The FSFO state version known to the observer.
  --
  --    iFlags          - The FSFO state flags known to the observer.
  --
  --    iMiv            - The FSFO Metadata Incarnation Version. This
  --                      argument is used to determine whether the observer
  --                      needs to refresh its FSFO-related property value
  --                      cache.
  --
  --    iWaitTime       - The amount of time in seconds that has passed
  --                      since the last FSFO ping.
  --
  -- Output Parameters:
  --    oVersion        - The FSFO state version known to the server. The
  --                      FSFO state version is used by the server and the
  --                      observer to determine which party has the most
  --                      recent FSFO state.
  --
  --    oFlags          - The FSFO state flags known to the server.
  --
  --    oFoCond         - This output parameter is used to let the observer
  --                      know whether a configurable FSFO condition was been
  --                      detected on the primary database.
  --
  --    ostatus         - Status returned by performing a ping operation.
  --

  PROCEDURE ReadyToFailover(iObid    IN  BINARY_INTEGER, 
                            iVersion IN  BINARY_INTEGER,
                            iFlags   IN  BINARY_INTEGER,
                            iMiv     IN  BINARY_INTEGER,
                            iFoCond  IN  VARCHAR2,
                            oStatus  OUT BINARY_INTEGER);
  --
  -- ReadyToFailover procedure prior to 12.2.
  --  
  -- This procedure is called by the obsever on the target standby database
  -- determine if the target standby database is ready for failover.
  --
  -- Input parameters:
  --    iObid           - The Obsever ID (OBID).
  --
  --    iVersion        - The FSFO state version known to the observer.
  --
  --    iFlags          - The FSFO state flags known to the observer.
  --
  --    iMiv            - The FSFO Metadata Incarnation Version. This
  --                      argument is used to determine whether the observer
  --                      needs to refresh its FSFO-related property value
  --                      cache.
  --
  --    iFoCond         - Contains the reason code a failover is necessary
  --                      if a configurable failover condition was detected
  --                      on the primary.
  --
  -- Output parameters:
  --    oStatus         - FSFO readiness status.
  --


  PROCEDURE StateChangeRecorded(iObid IN BINARY_INTEGER, 
                                iVersion IN BINARY_INTEGER);
  --
  -- StateChangeRecored procedure prior to 12.2.
  --
  -- This procedure is called by the observer to indicate that it has
  -- locally persisted a state change. The database is free to persist
  -- that state change as well.
  --
  -- An example use case for this function is when the primary database
  -- needs to move to the unsynchronized state. The observer detects this
  -- state change request via the Ping procedure. The observer then records
  -- that state change it its "books" (i.e. locally), and then calls this
  -- procedure to let the primary know it's aware of the state change and
  -- the primary is now free to persist the state change in the primary's
  -- "books".
  --
  -- Input parameters:
  --    iObid           - The Obsever ID (OBID).
  --
  --    iVersion        - The FSFO state version known to the observer.
  --
  -- Output parameters:
  --    None.
  --

  PROCEDURE fs_failover_for_hc_cond(hc_cond IN BINARY_INTEGER,
                             status OUT BINARY_INTEGER);
  --
  -- This procedure is used to determine whether the broker will handle
  -- a health check condition that may be enabled for FSFO, e.g. lost
  -- write. The expected caller of this function is Oracle Clusterware as
  -- it needs to know whether the broker will handle the specified condition
  -- or whether Clusterware should handle the condition.
  --
  -- Input parameters:
  --    hc_cond         - The health check condition that the caller has
  --                       become aware of.
  --
  -- Output parameters:
  --    status          - Effectively a boolean value to indicate whether
  --                      the broker will handle the existence of the
  --                      specified health check condition.
  --

  FUNCTION fs_failover_for_hc_cond(hc_cond IN BINARY_INTEGER) RETURN BOOLEAN;
  --
  -- This function is used to determine whether the broker will handle
  -- a health check condition that may be enabled for FSFO, e.g. lost
  -- write. The expected caller of this function is Oracle Clusterware as
  -- it needs to know whether the broker will handle the specified condition
  -- or whether Clusterware should handle the condition.
  --
  -- Input parameters:
  --    hc_cond         - The health check condition that the caller has
  --                       become aware of.
  --
  -- Returns:
  --    status          - a boolean value to indicate whether
  --                      the broker will handle the existence of the
  --                      specified health check condition.
  --

  PROCEDURE initiate_fs_failover(condstr IN VARCHAR2,
                                 status  OUT BINARY_INTEGER);
  --
  -- This procedure is used to initiate a fast-start failover. It can
  -- be called on the primary database or the target standby database.
  --
  -- Input parameters:
  --    condstr         - A character string that contains the reason a
  --                      fast-start failover is being initiated.
  --
  -- Output parameters:
  --    status          - An Oracle error number indicating that a fast-
  --                      start failover was initiated, or a why one could
  --                      not be initiated.
  --

  PROCEDURE do_observe (indoc      IN     RAW,
                        outdoc     OUT    RAW);
  --			
  -- Observer operation API - observer's operation to control FSFO
  --                          since 12.2.
  --
  -- This API replaces the following deprecated observer's procedures.
  -- The followings are used only for supporting older version observers:
  --     Ping()
  --     ReadyToFailover()
  --     StateChangeRecorded()
  --     
  -- Perform an observer operation.
  --    indoc           - the document containing an observer command.
  -- Output parameters:
  --    outdoc          - the result of the command.
  --


  FUNCTION add_database(database_name IN VARCHAR2,
                        database_ci IN VARCHAR2) RETURN BINARY_INTEGER;
  --
  -- This function is used to add a standby database to a broker
  -- configuration.
  --
  -- Input parameters:
  --    database_name   - A character string that specifies the
  --                      db_unique_name parameter value of the database
  --                      to be added to the configuration.
  --
  --    database_ci     - A connect identifier to connect to the standby
  --                      database to be added to the broker configuration.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      database was successfully added to the configuration.
  --

  FUNCTION add_far_sync(far_sync_name IN VARCHAR2,
                        far_sync_ci IN VARCHAR2) RETURN BINARY_INTEGER;
  --
  -- This function is used to add a far sync instance to a broker
  -- configuration.
  --
  -- Input parameters:
  --    far_sync_name   - A character string that specifies the
  --                      db_unique_name parameter value of the far sync
  --                      instance to be added to the configuration.
  --
  --    far_sync_ci     - A connect identifier to connect to the far sync
  --                      instance to be added to the broker configuration.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      far sync instance was successfully added to the
  --                      configuration.
  --

  FUNCTION create_configuration(config_name IN VARCHAR2,
                                primary_ci IN VARCHAR2) RETURN BINARY_INTEGER;
  --
  -- This function is used to create a broker configuration. The primary
  -- database will be automatically added to the configuration by this
  -- procedure. It's db_unique_name initializaiton paramter value will be
  -- fetched from the database. This routine be called on a primary database.
  --
  -- Input parameters:
  --    config_name     - A character string that specifies the name of
  --                      the configuration.
  --
  --    primary_ci      - A connect identifier that allows another member
  --                      of the broker configuration to reach the primary
  --                      database.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      configuration was successfully created with the
  --                      primary database.
  --

  FUNCTION disable_fs_failover(
                        force IN BOOLEAN DEFAULT FALSE )
         RETURN BINARY_INTEGER;
  --
  -- This function is used to disable (including forcibly) fast-start
  -- failover.
  --
  -- Input parameters:
  --    force
  --                    - A boolean value to indicate whether fast-start
  --                      failover should be disabled forcibly.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether
  --                      fast-start failover was disabled.
  --

  FUNCTION enable_configuration RETURN BINARY_INTEGER;
  --
  -- This function is used to enable broker management of a Data Guard
  -- configuration. It must be called on the primary database.
  --
  -- Input parameters:
  --    None.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      configuration was successfully enabled.
  --

  FUNCTION enable_database(database_name in VARCHAR2) RETURN BINARY_INTEGER;
  --
  -- This function is used to enable broker management of a database
  -- within the broker configuration. It must be called on the primary
  -- database.
  --
  -- Input parameters:
  --    database_name   - A character string that specifies the
  --                      db_unique_name parameter value of the database
  --                      to be enabled.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      database was successfully enabled.
  --

  FUNCTION enable_far_sync(far_sync_name in VARCHAR2) RETURN BINARY_INTEGER;
  --
  -- This function is used to enable broker management of a far sync instance
  -- within the broker configuration. It must be called on the primary
  -- database.
  --
  -- Input parameters:
  --    far_sync_name   - A character string that specifies the
  --                      db_unique_name parameter value of the far sync
  --                      instance to be enabled.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      far sync instance was successfully enabled.
  --

  FUNCTION enable_fs_failover 
         RETURN BINARY_INTEGER;
  --
  -- This function is used to enable fast-start failover.
  --
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether
  --                      fast-start failover was enabled.
  --

  FUNCTION remove_configuration (
        preserve_destinations  IN BOOLEAN DEFAULT FALSE )
        RETURN BINARY_INTEGER;
  --
  -- This function is used to remove a broker configuration. It must be
  -- called on the primary database.
  --
  -- Input parameters:
  --    preserve_destinations
  --                    - A boolean value to indicate whether the
  --                      log_archive_destination parameter settings should
  --                      be preserved or cleared. A value of TRUE means the
  --                      settings will be preserved, while a value of
  --                      FALSE means the settings will be cleared.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      configuration was successfully removed.
  --

  FUNCTION remove_database( database_name in VARCHAR2,
        preserve_destination IN BOOLEAN DEFAULT FALSE ) RETURN BINARY_INTEGER;
  --
  -- This function is used to remove a database from the broker configuration.
  -- It must be called on the primary database.
  --
  -- Input parameters:
  --    database_name   - A character string that specifies the
  --                      db_unique_name parameter value of the database
  --                      to be removed.
  --
  --    preserve_destinations
  --                    - A boolean value to indicate whether the
  --                      log_archive_destination parameter settings should
  --                      be preserved or cleared. A value of TRUE means the
  --                      settings will be preserved, while a value of
  --                      FALSE means the settings will be cleared.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      database was successfully removed.
  --

  FUNCTION remove_far_sync( far_sync_name in VARCHAR2,
        preserve_destination IN BOOLEAN DEFAULT FALSE ) RETURN BINARY_INTEGER;
  --
  -- This function is used to remove a far sync instance from the broker
  -- configuration. It must be called on the primary database.
  --
  -- Input parameters:
  --    far_sync_name   - A character string that specifies the
  --                      db_unique_name parameter value of the far sync
  --                      instance to be removed.
  --
  --    preserve_destinations
  --                    - A boolean value to indicate whether the
  --                      log_archive_destination parameter settings should
  --                      be preserved or cleared. A value of TRUE means the
  --                      settings will be preserved, while a value of
  --                      FALSE means the settings will be cleared.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      far sync instance was successfully removed.
  --

  FUNCTION set_configuration_property( property_name in VARCHAR2,
        value in VARCHAR2 ) RETURN BINARY_INTEGER;
  --
  -- This function is used to set configuration-level property (i.e.
  -- not a property of a database or far sync instance). Note, this
  -- function can be used to set both integer and character string properties.
  --
  -- Input parameters:
  --    property_name   - A character string that specifies the name of the
  --                      property whose value is to be changed.
  --
  --    value           - The value the specified property should be set to.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      configuration property was successfully changed.
  --

  FUNCTION set_database_property( database_name in VARCHAR2,
        property_name in VARCHAR2,
        value in VARCHAR2 ) RETURN BINARY_INTEGER;
  --
  -- This function is used to set a database configurable property.  Note, this
  -- function can be used to set both integer and character string properties.
  --
  -- Input parameters:
  --    database_name   - A character string that specifies the
  --                      db_unique_name parameter value of the database
  --                      whose property is to be changed.
  --    property_name   - A character string that specifies the name of the
  --                      property whose value is to be changed.
  --  
  --    value           - The value the specified property should be set to.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      configuration property was successfully changed.
  --

  FUNCTION set_far_sync_property( far_sync_name in VARCHAR2,
        property_name in VARCHAR2,
        value in VARCHAR2 ) RETURN BINARY_INTEGER;
  --
  -- This function is used to set a far sync instance configurable property.
  -- Note, this function can be used to set both integer and character string
  -- properties.
  --
  -- Input parameters:
  --    far_sync_name   - A character string that specifies the
  --                      db_unique_name parameter value of the far sync
  --                      instance whose property is to be changed.
  --
  --    property_name   - A character string that specifies the name of the
  --                      property whose value is to be changed.
  --
  --    value           - The value the specified property should be set to.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      configuration property was successfully changed.
  --

  FUNCTION set_protection_mode ( protection_mode  IN VARCHAR2 )
        RETURN BINARY_INTEGER;
  --
  -- This function changes the protection mode of the configuration to
  -- specified mode.
  --
  -- To prevent having to include logic that restarts a daabase, this
  -- procedure does not support the promotion of the protection mode from
  -- maximum performance to maximum protection mode.
  --
  -- Input parameters:
  --    protection_mode - A character string indicating the protection mode
  --                      to set. Valid values include MaxPeroformance,
  --                      MaxAvailability, and MaxProtection.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      protection mode was successfully set.
  --

  PROCEDURE startup_for_relocate;
  -- 
  -- This procedure is called when an instance is being started up in the
  -- course of a relocate operation.  The other instance will be stopped in 
  -- short order.  If this is a standby database, this is the opportunity to
  -- gracefully relocate the apply services to the new instance that is being
  -- started up.  In the event this is the standby that is supporting 
  -- MaxProtection mode, deregister the other instance as the critical 
  -- instance and register this instance so that the subsequent shutdown
  -- can proceed smoothly while ensuring the primary continues to be
  -- protected.
  -- 
  -- Input parameters:
  --    None.
  --
  -- Returns:
  --    None.
  --

  FUNCTION wait(event_type IN BINARY_INTEGER,
        max_wait_time IN BINARY_INTEGER) RETURN BINARY_INTEGER;
  --
  -- This function waits up to the number of seconds specified by
  -- the max_wait_time argument for the event specified by the event_type
  -- parameter to prevail.
  --
  -- Input parameters:
  --    
  --    event_type (IN)                 An event type to wait on. Can be one
  --                                    of:
  --                                    - wait for DMON to complete bootstrap
  --                                    - wait for DMON to start
  --
  --    max_wait_time (IN)              Maximum number of seconds to wait
  --                                    for event condition to prevail.
  --
  -- Returns:
  --    Status returned from rfs_wait().
  --    RFC_DRSF_STATUS_OK: if condition specifiied by event_type prevails
  --    in less time than specified by the max_wait_time argument.
  --
  --    RFC_DRSF_STATUS_TOUT: if condition specified by event_type does not
  --    prevail before the time specified by the max_wait_time argument
  --    elapses.
  --
  --    RFC_DRSF_STATUS_BADARG: if a bogus wait condition is specified.
  --

  FUNCTION wait(event_type IN BINARY_INTEGER,
        max_wait_time IN BINARY_INTEGER,
        flags in BINARY_INTEGER,
        set_or_clear in BINARY_INTEGER) RETURN BINARY_INTEGER;
  --
  -- This function waits up to the number of seconds specified by
  -- the max_wait_time argument for the event specified by the event_type
  -- parameter to prevail.
  --
  -- Input parameters:
  --    
  --    event_type (IN)                 An event type to wait on. Can be one
  --                                    of:
  --                                    - wait for DMON to complete bootstrap
  --                                    - wait for DMON to start
  --                                    - wait for a set of flags in rfmsp
  --                                      to be set or cleared
  --                                    - wait for a set of broker state flags
  --                                      to be set or cleared
  --
  --    max_wait_time (IN)              Maximum number of seconds to wait
  --                                    for event condition to prevail.
  --
  --    flags (IN)                      Set of flags to be checked. This
  --                                    argument must be specified if
  --                                    FLAGS_RFMP or FLAGS_BROKER_STATE is
  --                                    specified.
  --    set_or_clear (IN)               Flags specified in flags argument are
  --                                    either set or cleared. This argument
  --                                    must be specified if FLAGS_RFMP or
  --                                    FLAGS_BROKER_STATE is specified.
  --
  -- Returns:
  --    Status returned from rfs_wait().
  --    RFC_DRSF_STATUS_OK: if condition specifiied by event_type prevails
  --    in less time than specified by the max_wait_time argument.
  --
  --    RFC_DRSF_STATUS_TOUT: if condition specified by event_type does not
  --    prevail before the time specified by the max_wait_time argument
  --    elapses.
  --

  PROCEDURE wait(event_type IN BINARY_INTEGER,
        max_wait_time IN BINARY_INTEGER);
  --
  -- This procedure waits up to the number of seconds specified by
  -- the max_wait_time argument for the event specified by the event_type
  -- parameter to prevail.
  --
  -- Input parameters:
  --    
  --    event_type (IN)                 An event type to wait on. Can be one
  --                                    of:
  --                                    - wait for DMON to complete bootstrap
  --                                    - wait for DMON to start
  --                                    - wait for a set of flags in rfmsp
  --                                      to be set or cleared
  --                                    - wait for a set of broker state flags
  --                                      to be set or cleared
  --
  --    max_wait_time (IN)              Maximum number of seconds to wait
  --                                    for event condition to prevail.
  -- Signals:
  --    RFC_DRSF_STATUS_OK: if condition specifiied by event_type prevails
  --    in less time than specified by the max_wait_time argument.
  --
  --    RFC_DRSF_STATUS_TOUT: if condition specified by event_type does not
  --    prevail before the time specified by the max_wait_time argument
  --    elapses.
  --
  --    RFC_DRSF_STATUS_BADARG: if a bogus wait condition is specified.
  --

  PROCEDURE wait(event_type IN BINARY_INTEGER,
        max_wait_time IN BINARY_INTEGER,
        flags in BINARY_INTEGER,
        set_or_clear in BINARY_INTEGER);
  --
  -- This procedure waits up to the number of seconds specified by
  -- the max_wait_time argument for the event specified by the event_type
  -- parameter to prevail.
  --
  -- Input parameters:
  --    
  --    event_type (IN)                 An event type to wait on. Can be one
  --                                    of:
  --                                    - wait for DMON to complete bootstrap
  --                                    - wait for DMON to start
  --                                    - wait for a set of flags in rfmsp
  --                                      to be set or cleared
  --                                    - wait for a set of broker state flags
  --                                      to be set or cleared
  --
  --    max_wait_time (IN)              Maximum number of seconds to wait
  --                                    for event condition to prevail.
  --
  --    flags (IN)                      Set of flags to be checked. This
  --                                    argument must be specified if
  --                                    FLAGS_RFMP or FLAGS_BROKER_STATE is
  --                                    specified.
  --    set_or_clear (IN)               Flags specified in flags argument are
  --                                    either set or cleared. This argument
  --                                    must be specified if FLAGS_RFMP or
  --                                    FLAGS_BROKER_STATE is specified.
  --
  -- Errors Generated:
  --    None if condition specifiied by event_type prevails in less time than
  --    specified by the max_wait_time argument.
  --
  --    RFC_DRSF_STATUS_TOUT: if condition specified by event_type does not
  --    prevail before the time specified by the max_wait_time argument
  --    elapses.
  -- Returns:
  --    Status returned from rfs_wait().
  --

  FUNCTION wait_sync(member_name IN VARCHAR2,
        affirm IN BOOLEAN,
        max_wait_time IN BINARY_INTEGER) RETURN BINARY_INTEGER;

  --
  -- This function is used to wait for the specified member to be
  -- synchronized. If the keyword ANY is specified, this routine will wait
  -- for any destination to be synchronized.
  --
  -- This function calls the rfs_wait_sync() ICD to perform the actual
  --
  -- Input parameters:
  --    
  --    member_name (IN)                A character string containing the
  --                                    db_unique_name of the member to
  --                                    be checked for redo transport
  --                                    synchronization or the keyword ANY.
  --
  --    affirm (IN)                     AFFIRM attribute is set on the
  --                                    destination.
  --
  --    max_wait_time (IN)              Maximum number of seconds to wait
  --                                    for event condition to prevail.
  --
  -- Returns:
  --    RFC_DRSF_STATUS_OK: if condition specifiied by event_type prevails
  --    in less time than specified by the max_wait_time argument.
  --
  --    RFC_DRSF_STATUS_TOUT: if condition specified by event_type does not
  --    prevail before the time specified by the max_wait_time argument
  --    elapses.
  --
  --    RFC_DRSF_STATUS_BADARG: if a bogus member name or wait time is
  --    is specified.
  --
  --    RFC_DRSF_STATUS_NODRC: no configuration exists.
  --
  --    RFC_DRSF_STATUS_NOTMEMBER: if the specified member is not part of
  --    the Data Guard Broker configuration.
  --
  --    RFC_DRSF_STATUS_ILLPRMYOP: the specified member is the current primary
  --    database.
  --

  PROCEDURE wait_sync(member_name VARCHAR2,
        affirm IN BOOLEAN,
        max_wait_time IN BINARY_INTEGER);
  --
  -- This procedure is used to wait for the specified member to be
  -- synchronized. If the keyword ANY is specified, this routine will wait
  -- for any destination to be synchronized.
  --
  -- This procedures calls the wait_sync() function to perform the actual
  -- wait and "is synchronized" check.
  --
  -- Input parameters:
  --    
  --    member_name (IN)                A character string containing the
  --                                    db_unique_name of the member to
  --                                    be checked for redo transport
  --                                    synchronization or the keyword ANY.
  --
  --    affirm (IN)                     AFFIRM attribute is set on the
  --                                    destination.
  --
  --    max_wait_time (IN)              Maximum number of seconds to wait
  --                                    for event condition to prevail.
  --
  -- Signals:
  --    RFC_DRSF_STATUS_OK: if condition specifiied by event_type prevails
  --    in less time than specified by the max_wait_time argument.
  --
  --    RFC_DRSF_STATUS_TOUT: if condition specified by event_type does not
  --    prevail before the time specified by the max_wait_time argument
  --    elapses.
  --
  --    RFC_DRSF_STATUS_BADARG: if a bogus member name or wait time is
  --    is specified.
  --
  --    RFC_DRSF_STATUS_NODRC: no configuration exists.
  --
  --    RFC_DRSF_STATUS_NOTMEMBER: if the specified member is not part of
  --    the Data Guard Broker configuration.
  --
  --    RFC_DRSF_STATUS_ILLPRMYOP: the specified member is the current primary
  --    database.
  --

  FUNCTION reset_configuration_property( property_name in VARCHAR2 )
        RETURN BINARY_INTEGER;
  --
  -- This function is used to reset configuration-level property (i.e.
  -- not a property of a database or far sync instance) to its default value.
  --
  -- Input parameters:
  --    property_name   - A character string that specifies the name of the
  --                      property whose value is to be reset.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      configuration property was successfully reset.
  --

  FUNCTION reset_database_property( database_name in VARCHAR2,
        property_name in VARCHAR2 ) RETURN BINARY_INTEGER;
  --
  -- This function is used to reset a database configurable property to its
  -- default value.
  --
  -- Input parameters:
  --    database_name   - A character string that specifies the
  --                      db_unique_name parameter value of the database
  --                      whose property is to be reset.
  --    property_name   - A character string that specifies the name of the
  --                      property whose value is to be reset.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      configuration property was successfully reset.
  --

  FUNCTION reset_far_sync_property( far_sync_name in VARCHAR2,
        property_name in VARCHAR2 ) RETURN BINARY_INTEGER;
  --
  -- This function is used to reset a far sync instance configurable property
  -- to its default value.
  --
  -- Input parameters:
  --    far_sync_name   - A character string that specifies the
  --                      db_unique_name parameter value of the far sync
  --                      instance whose property is to be reset.
  --
  --    property_name   - A character string that specifies the name of the
  --                      property whose value is to be reset.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      configuration property was successfully reset.
  --

  FUNCTION stop_observer( ob_name in VARCHAR2 )
        RETURN BINARY_INTEGER;
  --
  -- This function is used to stop fast-start failover observers in a 
  -- data guard broker configuration.
  --
  -- Input parameters:
  --    ob_name         - A character string that specifies the name of the 
  --                      observer to be stopped.  If an empty string is
  --                      passed in, an observer will be stopped only if there
  --                      is only one registered observer in this
  --                      configuration.  If 'ALL' is passed in, all observers
  --                      in this configuration will be stopped.
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether the
  --                      observer was successfully stopped.
  --

  FUNCTION replace_member_name_in_props(old_member_name IN VARCHAR2,
                          new_member_name IN VARCHAR2) RETURN BINARY_INTEGER;
  --
  -- This function is used to replace a member name with another member name
  -- in all broker properties.
  --
  -- Input parameters:
  --    old_member_name (IN)            A character string containing the
  --                                    db_unique_name of the member to
  --                                    be replaced with new_member_name
  --                                    in all broker properties.
  --
  --    new_member_name (IN)            A character string containing the
  --                                    db_unique_name of the member to
  --                                    replace old_member_name in all broker
  --                                    properties.
  --
  -- Returns:
  --    RFC_DRSF_STATUS_OK: the old member name was successfully replaced with
  --                        the new mamber name.
  --
  --    RFC_DRSF_STATUS_BADARG: if a bogus member name is specified.
  --


  PROCEDURE check_connect(member_name   IN VARCHAR2,
                          instance_name IN VARCHAR2);
  --
  -- This procedure is used to check network connectivity to the specified
  -- member.
  --
  -- Input parameters:
  --    
  --    member_name (IN)                A character string containing the
  --                                    name of a broker's member to be
  --                                    checked to be connected to.
  --
  --    instance_name (IN)              A character string containing the
  --		      			name of an broker's instance to be
  --                                    checked to be connected to.
  --
  --

  
  --
  -- This function is used to dump broker-related SGA variables and metadata
  -- to trace files.
  --
  -- Input parameters:
  --    
  --    type (IN)       - The metadata dump type
  --                      RFRDM_DO_NONE:      do not dump metadata file
  --                      RFRDM_DO_CURRENT:   dump "current" metadata file
  --                      RFRDM_DO_ALTERNATE: dump "alternate" metadata file
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether
  --                      dump is done.
  --
  PROCEDURE dump_broker(
        dump_type    IN    BINARY_INTEGER,
        oStatus      OUT   VARCHAR2);

  --
  -- This function is used to dump critical internal data of client-side
  -- observer process to a file.
  --
  -- Input parameters:
  --    
  --    all_ob (IN)     - Whether all observers of current broker configuration
  --                      will do state dumping.  If FALSE, the parameter
  --                      ob_name specifies the observer to do state dumping
  --
  --    ob_name(IN)     - When all_ob is FALSE, ob_name specifies the observer
  --                      to do state dumping. If ob_name is NULL or an empty
  --                      string, observer state dumping will be triggered
  --                      only if there is only one started observer for the
  --                      current configuration.
  -- 
  --
  -- Returns:
  --    status          - An Oracle error number indicating whether
  --                      dump is done.
  --
  PROCEDURE dump_observer(
        all_ob       IN    BOOLEAN,
        ob_name      IN    VARCHAR2,
        oStatus      OUT   VARCHAR2);

pragma TIMESTAMP('2006-05-17:20:20:00');

end;
/
@?/rdbms/admin/sqlsessend.sql
