CREATE OR REPLACE PACKAGE Hotsos_Sysutil AS
   ---------------------------------------------------------------------
   -- Provides several utility functions and wraps calls to SYS.DBMS_SYSTEM.KSDDDT and SYS.DBMS_SYSTEM.KSDWRT.
   ---------------------------------------------------------------------
   --
   --  HOTSOS Instrumentation Library for Oracle
   --  Copyright (C) 2006, 2007  Hotsos Enterprises Ltd.
   --
   --  This library is free software; you can redistribute it and/or
   --  modify it under the terms of the GNU Lesser General Public
   --  License as published by the Free Software Foundation; either
   --  version 2.1 of the License, or (at your option) any later version.
   --
   --  This library is distributed in the hope that it will be useful,
   --  but WITHOUT ANY WARRANTY; without even the implied warranty of
   --  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   --  Lesser General Public License for more details.
   --
   --  You should have received a copy of the GNU Lesser General Public
   --  License along with this library; if not, write to the Free Software
   --  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
   --
   ---------------------------------------------------------------------

   ---------------------------------------------------------------------
   --
   --  Naming Standards
   --    v_ <> Variables
   --    c_<>  Constants
   --    g_<>  Package Globals
   --    ex_   User defined Exceptions
   --    r_<>  Records
   --    cs_<> Cursors
   --    csp_<>   Cursor Parameters
   --    <>_T  Types
   --    <>_O  Object Types
   --

   -----------------------------------------------------------------------
   --< PUBLIC TYPES AND GLOBALS >-----------------------------------------
   -----------------------------------------------------------------------

   -----------------------------------------------------------------------
   --< PUBLIC METHODS >
   -----------------------------------------------------------------------

   ---------------------------------------------------------------------
   --< get_version >
   ---------------------------------------------------------------------
   --
   --  Purpose: Returns the version of the HOTSOS_SYSUTIL package
   --
   --   %return NUMBER	  NUMBER value that indicates version of ILO
   ---------------------------------------------------------------------
   FUNCTION get_version RETURN NUMBER;
   ---------------------------------------------------------------------
   ---------------------------------------------------------------------
   --< Get_DB_Major_Ver >
   ---------------------------------------------------------------------
   --  Purpose: We make decisions based on the major version of the
   --           database.
   --
   --  comments
   --
   --  Using this function will allow the finding of the database major
   --  version to only be executed once.
   --
   ---------------------------------------------------------------------
   FUNCTION get_db_major_ver RETURN VARCHAR2;

   ---------------------------------------------------------------------
   --< write_datestamp >
   ---------------------------------------------------------------------
   --  Purpose: Forces Oracle to write a datestamp to the trace file for
   --           the current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE write_datestamp;

   ---------------------------------------------------------------------
   --< Write_to_trace >
   ---------------------------------------------------------------------
   --  Purpose: Writes the passed string to the trace file for the current
   --           session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE write_to_trace(text IN VARCHAR2);

   ---------------------------------------------------------------------
   --< Write_to_alert >
   ---------------------------------------------------------------------
   --  Purpose: Writes the passed string to the ALERT log
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE write_to_alert(text IN VARCHAR2);

   ---------------------------------------------------------------------
   --< turn_trace_on >
   ---------------------------------------------------------------------
   --  Purpose: Turn trace on for the current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE turn_trace_on;

   ---------------------------------------------------------------------
   --< turn_trace_off >
   ---------------------------------------------------------------------
   --  Purpose: Turn trace off for the current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE turn_trace_off;

   ---------------------------------------------------------------------
   --< get_client_id >
   ---------------------------------------------------------------------
   --  Purpose: Gets Client ID values for the current session.
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_client_id RETURN VARCHAR2;

   ---------------------------------------------------------------------
   --< set_client_id >
   ---------------------------------------------------------------------
   --  Purpose: Sets Client ID values for the current session.
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE set_client_id(text IN VARCHAR2);

   ---------------------------------------------------------------------
   --< get_spid >
   ---------------------------------------------------------------------
   --  Purpose: Gets spid from v$process.
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_spid RETURN VARCHAR2;

   ---------------------------------------------------------------------
   --< get_session_type >
   ---------------------------------------------------------------------
   --  Purpose: Gets session type from V$SESSION
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_session_type RETURN VARCHAR2;
   ---------------------------------------------------------------------
   --< get_Instance_name >
   ---------------------------------------------------------------------
   --  Purpose: Gets Instance name for current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_instance_name RETURN VARCHAR2;
   ---------------------------------------------------------------------
   --< get_service_name >
   ---------------------------------------------------------------------
   --  Purpose: Gets service name for the current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_service_name RETURN VARCHAR2;
   ---------------------------------------------------------------------
   --< get_session_user >
   ---------------------------------------------------------------------
   --  Purpose: Gets session user for current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_session_user RETURN VARCHAR2;
   ---------------------------------------------------------------------
   --< get_ip_address >
   ---------------------------------------------------------------------
   --  Purpose: Gets IP address for current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_ip_address RETURN VARCHAR2;
   ---------------------------------------------------------------------
   --< get_terminal >
   ---------------------------------------------------------------------
   --  Purpose: Gets terminal for current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_terminal RETURN VARCHAR2;
   ---------------------------------------------------------------------
   --< get_session_id >
   ---------------------------------------------------------------------
   --  Purpose: Gets TERMINAL for current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_session_id RETURN VARCHAR2;
   ---------------------------------------------------------------------
   --< get_os_user >
   ---------------------------------------------------------------------
   --  Purpose: Gets TERMINAL for current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_os_user RETURN VARCHAR2;
   ---------------------------------------------------------------------
   --< Register >
   ---------------------------------------------------------------------
   --  Purpose: Wraps the DBMS_ALERT.REGISTER procedure
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE register(p_name IN varchar2);
   ---------------------------------------------------------------------
   --< waitany >
   ---------------------------------------------------------------------
   --  Purpose: Wraps the DBMS_ALERT.WAITANY procedure
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE waitany(p_name OUT varchar2, p_message OUT varchar2, p_status OUT number, p_timeout IN number);
   ---------------------------------------------------------------------
   --< waitone >
   ---------------------------------------------------------------------
   --  Purpose: Wraps the DBMS_ALERT.WAITONE procedure
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE waitone(p_name IN varchar2, p_message OUT varchar2, p_status OUT number, p_timeout IN number);
   ---------------------------------------------------------------------
   --< signal >
   ---------------------------------------------------------------------
   --  Purpose: Wraps the DBMS_ALERT.SIGNAL procedure
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE SIGNAL (p_name IN varchar2, p_message IN varchar2);
   ---------------------------------------------------------------------
   --< remove >
   ---------------------------------------------------------------------
   --  Purpose: Wraps the DBMS_ALERT.REMOVE procedure
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE remove (p_name IN varchar2);
   ---------------------------------------------------------------------
   --< removeall >
   ---------------------------------------------------------------------
   --  Purpose: Wraps the DBMS_ALERT.REMOVEALL procedure
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE removeall;
   ---------------------------------------------------------------------
   --< set_raise_exceptions >
   ---------------------------------------------------------------------
   --  Purpose: Normally, ILO will supress any exceptions raised during it's execution so that any instrumented application
   --  won't be adversely affected by an error that might occur while processing ILO. This flag actually tells ILO to raise
   --  any exceptions that it hits. This is probably most useful for testing purposes, but might have its advantages in a
   --  production environment.
   --
   --
   --   %param RAISE_EXCEPTIONS	  BOOLEAN Value that indicates whether ILO will riase exceptions (TRUE) or not (FALSE).
   --
   --   %usage_notes
   --   <li> The default for RAISE_EXCEPTIONS is FALSE.
   ---------------------------------------------------------------------
   PROCEDURE set_raise_exceptions(raise_exceptions boolean);
   ---------------------------------------------------------------------
   --< get_raise_exceptions >
   ---------------------------------------------------------------------
   --  Return the current value for RAISE_EXCEPTIONS. 
   --
   --   %param None
   --
   --   %return BOOLEAN
   --
   --   %usage_notes
   --   <li> Returns the value of RAISE_EXCEPTIONS set by the user. If the user has not called the SET_RAISE_EXCEPTIONS method, the default is FALSE.
   --
   ---------------------------------------------------------------------
   FUNCTION get_raise_exceptions RETURN boolean;
END Hotsos_Sysutil;
