Rem
Rem $Header: rdbms/admin/dbmsappcont.sql /main/12 2017/05/17 16:07:09 aquinto Exp $
Rem
Rem dbmsappcont.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsappcont.sql - Application conituity support package
Rem
Rem    DESCRIPTION
Rem      Provides support for the 11.2.0.3 application continuity support.
Rem
Rem    NOTES
Rem      
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsappcont.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsappcont.sql
Rem SQL_PHASE: DBMSAPPCONT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aquinto     03/30/17 - Proj 67720: Transparent Application Continuity
Rem    cqi         01/23/17 - add mark_drainable to dbms_tg_dbg
Rem    sroesch     03/12/15 - Bug 20525223: Provide tg debug package
Rem    surman      12/29/13 - Bug 13922626: Update SQL metadata
Rem    sroesch     04/03/12 - Bug 13795730: Add automatic install
Rem    surman      03/27/12 - Bug 13615447: Add SQL patching tags
Rem    sroesch     01/23/12 - Bug 13619287: Ltxid exception handling cleanup
Rem    sroesch     06/14/11 - Replace force_outcome procedure with the new 
Rem                           function get_ltxid_outcome
Rem    kneel       06/09/11 - proj 32251 (app cont): add prepare_replay
Rem    sroesch     03/15/11 - Application continuity support for 12
Rem    sroesch     01/24/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE LIBRARY dbms_app_cont_lib trusted IS STATIC;
/

CREATE OR REPLACE PACKAGE dbms_app_cont AS

  ------------
  --  OVERVIEW
  --
  --  This package allows an application to determine the outcome of
  --  a transaction.

  ------------
  --  SECURITY
  --
  --  The execute privilage of the package is granted to DBA role only.

  ----------------
  --  INSTALLATION
  --
  --  This package should be installed under SYS schema.
  --
  --  SQL> @dbmsappcont
  --

  ----------------------------
  --  CONSTANTS
  --
  NOT_COMMITTED CONSTANT NUMBER(1)        := 1;
  COMMITTED CONSTANT NUMBER(1)            := 2;


  -------------------------
  --  ERRORS AND EXCEPTIONS
  --
  --  When adding errors remember to add a corresponding exception below.

  err_server_ahead       CONSTANT NUMBER := -14950;
  err_client_ahead       CONSTANT NUMBER := -14951;
  err_general_failure    CONSTANT NUMBER := -14952;

  exc_server_ahead       EXCEPTION;
  PRAGMA EXCEPTION_INIT(exc_server_ahead,    -14950);
  exc_client_ahead       EXCEPTION;
  PRAGMA EXCEPTION_INIT(exc_client_ahead,    -14951);
  exc_general_failure    EXCEPTION;
  PRAGMA EXCEPTION_INIT(exc_general_failure, -14952);


  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  PROCEDURE get_ltxid_outcome(client_ltxid        IN  RAW,
                              committed           OUT BOOLEAN,
                              user_call_completed OUT BOOLEAN);
  --  Forces the outcome of a transaction. If the transaction has not
  --  been commited yet, a fake transaction is committed. Otherwise the
  --  the state of the transaction is returned.
  --
  --  Input parameter(s):
  --    client_ltxid
  --      LTXID from the client driver.
  --
  --  Output parameter(s):
  --    committed           - Transaction has been committed
  --    user_call_completed - User call that committed the transaction has
  --                          been completed.
  --
  --  Exceptions:
  --      - SERVER_AHEAD, the server is ahead, so the transaction is an
  --                      old transaction and must have already been 
  --                      committed.
  --      - CLIENT_AHEAD, the client is ahead of the server. This can only
  --                      happen if the server has been flashbacked or the
  --                      ltxid is corrupted. In any way, the outcome
  --                      cannot be determined.
  --      - ERROR, the outcome cannot be determined. During processing an
  --               error happened.
  --    error
  --      Error code raised during the execution of force_outcome.
  --
END dbms_app_cont;
/

show errors

CREATE OR REPLACE PUBLIC SYNONYM dbms_app_cont FOR dbms_app_cont
/

 ---------------------------------
 --
 -- Grant only to DBA role
 --

GRANT EXECUTE ON dbms_app_cont TO dba;
/

-- library for ltxid-related functions (kjac)
CREATE OR REPLACE LIBRARY dbms_app_cont_prvt_lib trusted is static;
/

-- library for Application Continuity Management functions (kpoxc)
CREATE OR REPLACE LIBRARY dbms_app_cont_prvt_lib2 trusted is static;
/

CREATE OR REPLACE PACKAGE dbms_app_cont_prvt AS

  ------------
  --  OVERVIEW
  --
  --  This package is an internal package for applicaton continuity.
  --

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --

  FUNCTION partition_exists(part_id NUMBER) RETURN NUMBER;
  -- Determines if a partition in the transaction history table exists.

  ----------------------------
  --  11.2.0.3 SELECT ONLY PROCEDURES AND FUNCTIONS
  --

  procedure monitor_txn;
  -- Enables the monitoring of transactions in the server

  procedure prepare_replay(client_ltxid       IN RAW, 
                           attempting_replay  IN BOOLEAN,
                           commit_on_success  IN BOOLEAN,
                           call_fncode        IN BINARY_INTEGER,
                           sql_text           IN VARCHAR2,
                           committed         OUT BOOLEAN,
                           embedded          OUT BOOLEAN,
                           signature_flags    IN NUMBER := NULL,
                           client_signature   IN NUMBER := NULL,
                           server_signature   IN NUMBER := NULL);
  --
  --  Asks server to check status of last action and prepare for replay.
  --
  --  If necessary -- if the named call could have committed -- then
  --  forces the outcome of a transaction (see force_outcome).
  --
  --  Input parameter(s):
  --    client_ltxid      - LTXID from the client driver.
  --    attempting_replay - client is attempting replay. If false, just
  --                        checking the ltxid
  --    commit_on_success - last call submitted with OCI_COMMIT_ON_SUCCES
  --    call_fncode       - O* function call (see opidef.h) for last call
  --    sql text          - SQL text if last call was SQL execute
  --    signature_flags   - Session state signature flags
  --    client_signature  - Session state client signature
  --    server_signature  - Session state server signature
  --
  --  Output parameter(s):
  --    committed - Transaction has been committed
  --    embedded  - Transaction commit was embedded
  --
  --  Exceptions:
  --      - SERVER_AHEAD, the server is ahead, so the transaction is an
  --                      old transaction and must have already been 
  --                      committed.
  --      - CLIENT_AHEAD, the client is ahead of the server. This can only
  --                      happen if the server has been flashbacked or the
  --                      ltxid is corrupted. In any way, the outcome
  --                      cannot be determined.
  --      - ERROR, the outcome cannot be determined. During processing an
  --               error happened.
  --    error
  --      Error code raised during the execution of force_outcome.
  --

  procedure begin_replay;
  -- Enables the replay mode in the server. While in replay mode, no
  -- transactions can be either started or committed.

  procedure end_replay;
  -- Disables the replay mode.

END dbms_app_cont_prvt;
/

show errors

CREATE OR REPLACE PUBLIC SYNONYM dbms_app_cont_prvt FOR dbms_app_cont_prvt
/

 ---------------------------------
 --
 -- Grant public role
 --

GRANT EXECUTE ON dbms_app_cont_prvt TO public
/

-- Library for transaction guard debugging functions (kjac)
CREATE OR REPLACE LIBRARY dbms_tg_dbg_lib trusted is static;
/

-- Package for transaction guard debugging
CREATE OR REPLACE PACKAGE dbms_tg_dbg AS

  ------------
  --  OVERVIEW
  --
  --  This package is an internal package for transaction guard debugging.
  --

  -- Constants for failpoints. The failpoint constant values need to be a power
  -- of two so that they can be or'ed together and more than one value can be
  -- specified.
  TG_FAILPOINT_PRE_COMMIT      CONSTANT NUMBER(2) := 1;
  TG_FAILPOINT_POST_COMMIT     CONSTANT NUMBER(2) := 2;
  TG_FAILPOINT_FORCE_OUTCOME   CONSTANT NUMBER(2) := 4;

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --

  PROCEDURE set_failpoint(failpoint NUMBER,
                          sid       NUMBER DEFAULT NULL,
                          serial    NUMBER DEFAULT NULL);
  -- Sets the failpoint

  PROCEDURE clear_failpoint;
  -- Clear all failpoints

  PROCEDURE set_session_drainable;
  -- Set the current session as drainable

END dbms_tg_dbg;
/

show errors

CREATE OR REPLACE PUBLIC SYNONYM dbms_tg_dbg FOR dbms_tg_dbg
/



@?/rdbms/admin/sqlsessend.sql
