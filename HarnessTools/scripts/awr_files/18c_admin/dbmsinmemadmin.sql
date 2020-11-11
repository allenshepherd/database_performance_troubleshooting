Rem
Rem $Header: rdbms/admin/dbmsinmemadmin.sql /main/8 2017/07/28 10:33:34 hlakshma Exp $
Rem
Rem dbmsinmemadmin.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsinmemadmin.sql - DBMS_INMEMORY_ADMIN Package
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsinmemadmin.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmsinmemadmin.sql
Rem    SQL_PHASE: DBMSINMEMADMIN
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hlakshma    06/21/17 - Bug 26353947: Procedures for configuring AIM 
Rem    aumishra    02/14/17 - Bug 25544858: Add ime_get_capture_state procedure
Rem    aumishra    01/04/17 - Add procedures for IME Window Capture
Rem    aumishra    04/29/16 - Bug 23177430: Add procedures for IME
Rem    miglees     04/16/16 - Bug 22980084: Move deallocate_versions
Rem                           from DBMS_INMEMORY_ADMIN
Rem    pbollimp    03/11/16 - Bug 22651162: add parameter in faststart_enable
Rem    pbollimp    02/23/16 - Bug 22820939: faststart checkpoint procedure
Rem    kdnguyen    02/01/16 - Bug 22643504: rename FastStart procedure names
Rem    kdnguyen    08/21/14 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

@@?/rdbms/admin/sqlsessstart.sql


CREATE OR REPLACE PACKAGE dbms_inmemory_admin AUTHID CURRENT_USER AS 

  -------------------------------------------------------------------------
  -- AIM Feature constants : Begin
  -------------------------------------------------------------------------
 -- Predefined constant(s) for idenfying the parameters controlling AIM 
 -- behavior. The constants are used to populate the column param# in the 
 -- table sys.ado_imparam$
 --   
 -- Special row for enabling concurrent AIM config operations. This parameter 
 -- cannot be modified using this package.
    AIM_SERIALIZATION  constant   number := 0;
 -- Denotes the AIM sliding stats window in days
    AIM_STATWINDOW_DAYS    constant   number := 1;
 
 -- Default values for the AIM parameters. 
    AIM_STATWINDOW_DAYS_DEFAULT constant number := 31;
  -------------------------------------------------------------------------
  -- AIM Feature constants: End
  -------------------------------------------------------------------------

  -------------------------------------------------------------------------
  -- PROCEDURE faststart_enable
  -------------------------------------------------------------------------
  -- Description :
  --   Enables the faststart mechanism for the specified tablespace. If the 
  --   nologging parameter is set to TRUE, then it creates the FastStart 
  --   lob with logging option. If it is set to FALSE, or by default, the 
  --   lob would be create with nologging option.
  --
  -- Input parameters:
  --   tbs_name       - tablespace name
  --   nologging      - if the faststart lob is to be in nologging mode

  procedure faststart_enable(tbs_name in varchar2, 
                             nologging in boolean DEFAULT TRUE);

  -------------------------------------------------------------------------
  -- PROCEDURE faststart_migrate
  -------------------------------------------------------------------------
  -- Description :
  --   Migrate the faststart mechanism for the specified tablespace.
  --
  -- Input parameters:
  --   tbs_name       - tablespace name

  procedure faststart_migrate_storage(tbs_name in varchar2);

  -------------------------------------------------------------------------
  -- PROCEDURE faststart_disable
  -------------------------------------------------------------------------
  -- Description : 
  --   Disables the faststart mechanism
  --
  -- Input parameters:
  --   none

  procedure faststart_disable;

  -------------------------------------------------------------------------
  -- PROCEDURE get_faststart_tablespace
  -------------------------------------------------------------------------
  -- Description : 
  --   Returns the tablespace assigned to FastStart. If the feature is
  --   disabled, the function will return "NOT ENABLED"
  --
  -- Input parameters:
  --   none

  function get_faststart_tablespace return varchar;

  
  -------------------------------------------------------------------------
  -- PROCEDURE faststart_checkpoint
  -------------------------------------------------------------------------
  -- Description : 
  --   Checkpoint all deferred write pending tasks immediately
  --
  -- Input parameters:
  --   global       - In case of RAC, is the flush global or just local to 
  --                  the instance

  procedure faststart_checkpoint(global in boolean DEFAULT TRUE);

  -------------------------------------------------------------------------
  -- PROCEDURE deallocate_versions
  -------------------------------------------------------------------------
  -- Description :
  --   Walk through all in-memory segments in the instance
  --   and deallocate in-memory extents for 
  --   old SMU and IMCU versions 
  -- Input parameters:
  --   spcpressure    - If TRUE, will break retention of IMCUs


  procedure deallocate_versions(
        spcpressure      in boolean DEFAULT FALSE);

  -------------------------------------------------------------------------
  -- PROCEDURE ime_capture_expressions
  -------------------------------------------------------------------------
  -- Description :
  --   This is a procedure for the In-Memory Expressions feature that allows
  --   a DBA to capture hot expressions across the database. 
  -- Input parameters:
  --   Snapshot - either CUMULATIVE or CURRENT or WINDOW

  procedure ime_capture_expressions(snapshot in varchar2);

  -------------------------------------------------------------------------
  -- PROCEDURE ime_drop_all_expressions
  -------------------------------------------------------------------------
  -- Description :
  --   This is a procedure for the In-Memory Expressions feature that allows
  --   a DBA to drop all SYS_IME hidden VCs across all tables in the database
  --   regardless of whether they are marked for in-memory or not. This is a
  --   safety switch in case too many SYS_IMEs linger around consuming intcol#s
  --
  -- Input parameters:
  --   NONE

  procedure ime_drop_all_expressions;

 -------------------------------------------------------------------------
  -- PROCEDURE ime_populate_expressions
  -------------------------------------------------------------------------
  -- Description :
  --   This procedure allows the DBA to populate all hot expressions that were
  --   captured in the latest iteration, into the IM column store. Without a
  --   call to this procedure, the expressions will be gradually populated as 
  --   and when the IMCUs for the involved segments are repopulated.
  --
  -- Input parameters:
  --   NONE

  procedure ime_populate_expressions;

  -------------------------------------------------------------------------
  -- PROCEDURE ime_open_capture_window
  -------------------------------------------------------------------------
  -- Description :
  --   This is a procedure for the In-Memory Expressions feature that allows
  --   a DBA to open an expression monitoring window.
  --  
  -- Input parameters:
  --   NONE

  procedure ime_open_capture_window;

  -------------------------------------------------------------------------
  -- PROCEDURE ime_close_capture_window
  -------------------------------------------------------------------------
  -- Description :
  --   This is a procedure for the In-Memory Expressions feature that allows
  --   a DBA to close an expression monitoring window that is already closed.
  --  
  -- Input parameters:
  --   NONE

  procedure ime_close_capture_window;

  -------------------------------------------------------------------------	
  -- PROCEDURE ime_get_capture_state	
  -------------------------------------------------------------------------	
  -- Description:
  --   This is a procedure for the In-Memory Expressions feature that allows
  --   a DBA to get the current state of the expression monitoring window
  --
  -- Output parameters:	
  --   p_capture_state - Current capture state for window capture
  --   p_last_modified - Last modified timestamp of the capture state
  
  procedure ime_get_capture_state(p_capture_state out varchar2,
                                  p_last_modified out timestamp);

  -------------------------------------------------------------------------	
  -- PROCEDURE aim_set_env	
  -------------------------------------------------------------------------	
  -- Description:
  --   This is a procedure for customizing the AIM execution env. In 18.1,
  --   this would be primarily used to customize the sliding stats window
  --   in days for the Automatic In-Memory Management (AIM) feature. AIM uses 
  --   this  duration to filter (heat map) statistics for IM enabled objects 
  --   as part of its algorithms. As an example, if the duration is set to 7 
  --   days, then AIM considers only statistics of the past 7 days for 
  --   its algorithms
  --  
  -- 
  --   Input parameters:	
  --   param - This should be one of the predefined constants identifying the 
  --           parameter that controls the AIM behavior 
  --   value - The value to set this parameter to

  procedure aim_set_parameter(parameter in number, value in number);

   -------------------------------------------------------------------------	
  -- Procedure aim_get_param	
  -------------------------------------------------------------------------	
  -- Description:
  --   This is a procedure for getting the current values of the AIM 
  --   parameters that controls the AIM behavior. 
  --  
  -- 
  --   Output parameters:	
  --   parameter - This should be one of the predefined constants identifying 
  --   the parameter that controls the AIM behavior
  -- 
  --   value  - The current value for the parameter
  
  procedure aim_get_parameter(parameter in number, value out number);

END dbms_inmemory_admin;
/

create or replace public synonym dbms_inmemory_admin for sys.dbms_inmemory_admin
/

grant execute on dbms_inmemory_admin to dba
/

@?/rdbms/admin/sqlsessend.sql
