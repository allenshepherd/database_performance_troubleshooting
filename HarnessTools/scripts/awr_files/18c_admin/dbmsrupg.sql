Rem
Rem $Header: rdbms/admin/dbmsrupg.sql /main/6 2014/02/20 12:45:54 surman Exp $
Rem
Rem dbmsrupg.sql
Rem
Rem Copyright (c) 2011, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsrupg.sql - DBMS Rolling UPGrade package
Rem
Rem    DESCRIPTION
Rem      dbms_rolling package definition.
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsrupg.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsrupg.sql
Rem SQL_PHASE: DBMSRUPG
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    sslim       10/11/12 - Bug 14582187: Rollback support and UI changes
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    sslim       03/23/12 - Define additional signature for set_parameter
Rem    sslim       09/28/11 - show errors on package creation
Rem    sslim       09/01/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE sys.dbms_rolling AUTHID CURRENT_USER AS

--
-- NAME 
--   rollback_plan
--
-- DESCRIPTION
--   This procedure rolls back the group of DBMS_ROLLING administered
--   databases to their initial state.  The DBMS_ROLLING package will 
--   create an initial set of guaranteed restore points for all participating
--   databases.  This procedure will flashback all databases in the leading 
--   change group to their respective restore points.  This procedure will only
--   permit the rollback if the switchover has not been performed.
--
PROCEDURE rollback_plan;

--
-- NAME 
--   build_plan
--
-- DESCRIPTION
--   This procedure either builds a complete upgrade plan or modifies the
--   remaining unprocessed portion of an existing plan.  The build procedure
--   interprets the configured rolling upgrade parameters to produce a 
--   customized upgrade plan.
--
PROCEDURE build_plan;

--
-- NAME 
--   destroy_plan
--
-- DESCRIPTION
--   This procedure purges all rolling upgrade state from the database.  It
--   is called upon completion of the rolling upgrade.
--
PROCEDURE destroy_plan;

--
-- NAME 
--   finish_plan
--
-- DESCRIPTION
--   This procedure executes the FINISH phase instructions in the upgrade 
--   plan.  It is called after the START and SWITCHOVER phase instructions
--   have completed, and the user has restarted the original primary and 
--   physical standbys of the primary on their higher version binaries.
--   Upon completion of this procedure, the original primary and its 
--   physical standbys will have completed recovery of the ugprade redo.
--
PROCEDURE finish_plan;

--
-- NAME 
--   init_plan
--
-- DESCRIPTION
--   This procedure is the first procedure that must be called to prepare
--   for a DBMS_ROLLING administered rolling upgrade.  It communicates 
--   with the complete set of databases in the DG_CONFIG, and creates a
--   default set of rolling upgrade parameters for building rolling 
--   upgrade plans.
--
PROCEDURE init_plan (future_primary IN VARCHAR2);

--
-- NAME 
--   set_parameter
--
-- DESCRIPTION
--   This procedure is called to set and unset rolling upgrade parameters.
--   Changes to the plan parameters, however, do not take effect until the
--   user re-invokes the BUILD procedure to reconstruct the upgrade plan.
--
PROCEDURE set_parameter (scope IN VARCHAR2, name IN VARCHAR2,
                         value IN VARCHAR2);
PROCEDURE set_parameter (name IN VARCHAR2, value IN VARCHAR2);


--
-- NAME 
--   start_plan
--
-- DESCRIPTION
--   This procedure executes the START phase instructions in the upgrade plan.
--   It is the first procedure that is called to initiate the rolling upgrade.
--   Upon completion of this phase, the future primary will be ready to be 
--   ugpraded.
--
PROCEDURE start_plan;

--
-- NAME 
--   switchover
--
-- DESCRIPTION
--   This procedure executes the SWITCHOVER phase instructions in the upgrade
--   plan.  It is called once the START procedure has completed execution of
--   all START phase instructions.  It is responsible for switching the 
--   configuration over to the new primary which will have been upgraded by
--   the time this procedure is called.  Upon completion of this procedure,
--   the future primary will be the new primary, and the original primary
--   and physicals of the original primary will be ready for restart on
--   their higher version binaries.
--
PROCEDURE switchover;

END dbms_rolling;
/
show errors

CREATE OR REPLACE PUBLIC SYNONYM dbms_rolling FOR sys.dbms_rolling
/
GRANT EXECUTE ON dbms_rolling TO dba
/
CREATE OR REPLACE LIBRARY sys.dbms_rolling_lib trusted is static
/


@?/rdbms/admin/sqlsessend.sql
