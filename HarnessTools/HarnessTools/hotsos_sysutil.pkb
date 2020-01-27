CREATE OR REPLACE PACKAGE BODY Hotsos_Sysutil AS
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

   --------------------------------------------------------------------
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
   ---------------------------------------------------------------------
   --< PRIVATE TYPES AND GLOBALS >--------------------------------------
   ---------------------------------------------------------------------
   g_db_major_ver  VARCHAR2(5);
   g_db_prod       VARCHAR2(15);
   g_db_ver        VARCHAR2(64);
   g_spid          VARCHAR2(12);
   g_session_type  VARCHAR2(255);
   g_instance_name VARCHAR2(255);
   g_service_name  VARCHAR2(255);
   g_session_user  VARCHAR2(30);
   g_terminal      VARCHAR2(255);
   g_ip_address    VARCHAR2(15);
   g_session_id	   VARCHAR2(64);
   g_os_user	   VARCHAR2(64);
   g_raise_exceptions BOOLEAN := FALSE;
   
   ---------------------------------------------------------------------
   --< PRIVATE METHODS >------------------------------------------------
   ---------------------------------------------------------------------
   ---------------------------------------------------------------------
   --< Set_DBVer >
   ---------------------------------------------------------------------
   --  Purpose: We make decisions what calls will be executed based on
   --           version of the database. Incorporating into util so that
   --           we only need to do thisonceper session and therefore
   --           reduce the executions over and over.
   --
   --  Comments:
   --
   --
   ---------------------------------------------------------------------
   PROCEDURE set_dbver IS
      v_db_ver            VARCHAR2(64);
      v_compat_ver        VARCHAR2(64);
      v_db_major          VARCHAR2(5);
      v_db_minor          VARCHAR2(5);
      v_db_ver_minusmajor VARCHAR2(10);
      v_idx               PLS_INTEGER;
      v_del               VARCHAR2(2) := '.';
   BEGIN
      DBMS_UTILITY.DB_VERSION(v_db_ver, v_compat_ver);
      v_idx               := INSTR(v_db_ver, v_del);
      v_db_major          := SUBSTR(v_db_ver, 1, v_idx - 1);
      v_db_ver_minusmajor := SUBSTR(v_db_ver, v_idx + 1, LENGTH(v_db_ver));
      v_idx               := INSTR(v_db_ver_minusmajor, v_del);
      v_db_minor          := SUBSTR(v_db_ver_minusmajor, 1, v_idx - 1);
      -- Setting the major number
      g_db_major_ver := v_db_major;
      -- Setting the major and minor number as a product number
      g_db_prod := v_db_major || '.' || v_db_minor;
      -- Setting the entire db verion
      g_db_ver := v_db_ver;
   END set_dbver;
   
   ---------------------------------------------------------------------
   --< PUBLIC METHODS >------------------------------------------------
   ---------------------------------------------------------------------
   ---------------------------------------------------------------------
   --< get_version >
   ---------------------------------------------------------------------
   --
   --  Purpose: Returns the version of the HOTSOS_SYSUTIL package
   --
   --   %return NUMBER	  NUMBER value that indicates version of ILO
   ---------------------------------------------------------------------
   FUNCTION get_version 
      RETURN NUMBER
   IS
   BEGIN
      RETURN 2.0;
   EXCEPTION
      WHEN OTHERS THEN
         if hotsos_sysutil.get_raise_exceptions then 
            raise;
         else
            RETURN NULL;
         end if;
   END get_version;

   ---------------------------------------------------------------------
   --< Get_DB_Major_Ver >
   ---------------------------------------------------------------------
   --  Purpose: We make decisions based on the major version of the
   --           database.
   --
   --  Comments:
   --
   --  Using this function will allow the finding of the database major
   --  version to only be executed once.
   --
   ---------------------------------------------------------------------
   FUNCTION get_db_major_ver RETURN VARCHAR2 IS
      v_major_version VARCHAR2(5);
   BEGIN
      IF g_db_major_ver IS NULL THEN
         set_dbver;
         v_major_version := g_db_major_ver;
      ELSE
         v_major_version := g_db_major_ver;
      END IF;
      RETURN v_major_version;
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            RETURN '9';
         end if;
   END get_db_major_ver;

   ---------------------------------------------------------------------
   --< write_datestamp >
   ---------------------------------------------------------------------
   --  Purpose: Forces Oracle to write a datestamp to the trace file for
   --           the current session
   --
   --  Comments:
   --
   ---------------------------------------------------------------------
   PROCEDURE write_datestamp IS
   BEGIN
      SYS.Dbms_System.ksdddt;
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            NULL;
         end if;
   END write_datestamp;

   ---------------------------------------------------------------------
   --< Write_to_trace >
   ---------------------------------------------------------------------
   --  Purpose: Writes the passed string to the trace file for the current
   --           session
   --
   --  Comments:
   --
   ---------------------------------------------------------------------
   PROCEDURE write_to_trace(text IN VARCHAR2) IS
   BEGIN
      SYS.Dbms_System.ksdwrt(1, text);
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            NULL;
         end if;
   END write_to_trace;

   ---------------------------------------------------------------------
   --< Write_to_alert >
   ---------------------------------------------------------------------
   --  Purpose: Writes the passed string to the ALERT log
   --
   --  Comments:
   --
   ---------------------------------------------------------------------
   PROCEDURE write_to_alert(text IN VARCHAR2) IS
   BEGIN
      SYS.Dbms_System.ksdwrt(2, text);
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            NULL;
         end if;
   END write_to_alert;

   ---------------------------------------------------------------------
   --< turn_trace_on >
   ---------------------------------------------------------------------
   --  Purpose: Turn trace on for the current session
   --
   --  Comments:
   --
   ---------------------------------------------------------------------
   PROCEDURE turn_trace_on IS
      exec_str       VARCHAR2(100);
      v_db_major_ver VARCHAR2(5) := get_db_major_ver;
   BEGIN
      IF v_db_major_ver >= 10 THEN
         -- V10 +
         exec_str := 'BEGIN dbms_monitor.session_trace_enable (NULL, NULL, TRUE, TRUE); END;';
      ELSE
         -- V7 - V9
         exec_str := 'BEGIN dbms_support.start_trace (TRUE, TRUE); END;';
      END IF;
      EXECUTE IMMEDIATE exec_str;
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            NULL;
         end if;
   END turn_trace_on;

   ---------------------------------------------------------------------
   --< turn_trace_off >
   ---------------------------------------------------------------------
   --  Purpose: Turn trace off for the current session
   --
   --  Comments:
   --
   ---------------------------------------------------------------------
   PROCEDURE turn_trace_off IS
      exec_str       VARCHAR2(100);
      v_db_major_ver VARCHAR2(5) := get_db_major_ver;
   BEGIN
      IF v_db_major_ver >= 10 THEN
         -- V10 +
         exec_str := 'BEGIN dbms_monitor.session_trace_disable (NULL, NULL); END;';
      ELSE
         -- V7 - V9
         exec_str := 'BEGIN dbms_support.stop_trace; END;';
      END IF;
      EXECUTE IMMEDIATE exec_str;
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            NULL;
         end if;
   END turn_trace_off;

   ---------------------------------------------------------------------
   --< get_client_id >
   ---------------------------------------------------------------------
   --  Purpose: Gets Client ID values for the current session.
   --
   --  Comments:
   --
   ---------------------------------------------------------------------
   FUNCTION get_client_id RETURN VARCHAR2 IS
      v_os_user      VARCHAR2(64);
      v_ip_address   VARCHAR2(20);
      v_program      VARCHAR2(200);
      v_service      VARCHAR2(20);
      v_client_id    VARCHAR2(200);
      v_db_major_ver VARCHAR2(5) := get_db_major_ver;
   BEGIN
      -- See if a client_id has been previously set
      -- If the client_identifier is already set then just return the value.
      v_client_id := SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER');
      IF v_client_id IS NULL THEN
         v_ip_address := NVL(get_ip_address, get_terminal );

         SELECT program
         INTO   v_program
         FROM   SYS.V_$SESSION
         WHERE  audsid = TO_NUMBER(get_session_id)
         AND    ROWNUM = 1;

         v_os_user := get_os_user; -- SYS_CONTEXT('USERENV', 'OS_USER');

         IF v_db_major_ver >= 10 THEN
            -- 8 and 9 don't know about service_name
            v_service   := get_service_name;
            v_client_id := v_os_user || '~' || v_ip_address || '~' ||
                           v_program || '~' || v_service;
         ELSE
            v_client_id := v_os_user || '~' || v_ip_address || '~' ||
                           v_program;
         END IF;

      END IF;
      RETURN v_client_id;
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            RETURN 'Error retrieving client id.';
         end if;
   END get_client_id;

   ---------------------------------------------------------------------
   --< set_client_id >
   ---------------------------------------------------------------------
   --  Purpose: Sets Client ID values for the current session.
   --
   --  Comments:
   --
   ---------------------------------------------------------------------
   PROCEDURE set_client_id(text IN VARCHAR2) IS
   BEGIN
      -- See if a client_id has been previously set
      EXECUTE IMMEDIATE 'BEGIN DBMS_SESSION.SET_IDENTIFIER(:client_id); END;'
         USING text;
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            NULL;
         end if;
   END set_client_id;

   ---------------------------------------------------------------------
   --< get_spid >
   ---------------------------------------------------------------------
   --  Purpose: Gets spid from V_$PROCESS.
   --
   --  Comments:
   --
   ---------------------------------------------------------------------
   FUNCTION get_spid RETURN VARCHAR2 IS
      v_spid VARCHAR2(12);

   BEGIN
      IF G_SPID IS NULL THEN
         SELECT a.spid
         INTO   v_spid
         FROM   sys.v_$process a, sys.v_$session b
         WHERE  a.addr = b.paddr
         AND    b.audsid = USERENV('sessionid');
         g_SPID := v_spid;
      ELSE
         V_SPID := G_SPID;
      END IF;

      RETURN v_spid;
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            RETURN -1;
         end if;
   END get_spid;

   ---------------------------------------------------------------------
   --< get_session_type >
   ---------------------------------------------------------------------
   --  Purpose: Gets session type from V_$SESSION
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_session_type RETURN VARCHAR2 IS
   BEGIN
      IF g_session_type IS NULL THEN
         SELECT b.TYPE
         INTO   g_session_type
         FROM   sys.v_$session b
         WHERE  b.audsid = USERENV('sessionid');
      END IF;
      RETURN g_session_type;
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            RETURN -1;
         end if;
   END get_session_type;

   ---------------------------------------------------------------------
   --< get_Instance_name >
   ---------------------------------------------------------------------
   --  Purpose: Gets Instance name for current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_instance_name RETURN VARCHAR2 IS
       v_instance_name sys.v_$instance.instance_name%TYPE;
   BEGIN
      IF g_instance_name IS NULL THEN
         SELECT instance_name
           INTO g_instance_name
           FROM sys.v_$instance;
      END IF;
      RETURN g_instance_name;
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            RETURN 'ERROR';
         end if;
   END get_instance_name;
   ---------------------------------------------------------------------
   --< get_service_name >
   ---------------------------------------------------------------------
   --  Purpose: Gets service name for the current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_service_name RETURN VARCHAR2 IS
       v_db_major_ver VARCHAR2(5) := get_db_major_ver;
   BEGIN
   -- If we're on Version 10 or above, then we can get the service name
   IF v_db_major_ver >= 10 THEN
      -- If the Global service name has not already been set for the session
      -- Then get it using sys_context and then set the global
      IF g_service_name IS NULL THEN
         g_service_name := sys_context('USERENV','SERVICE_NAME');
      END IF;
      RETURN g_service_name;
   ELSE
      RETURN NULL;
   END IF;
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            RETURN NULL;
         end if;
   END get_service_name;
   ---------------------------------------------------------------------
   --< get_session_user >
   ---------------------------------------------------------------------
   --  Purpose: Gets session user for current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_session_user RETURN VARCHAR2 IS
   BEGIN
   IF g_session_user IS NULL THEN
        g_session_user := sys_context('USERENV','SESSION_USER');
   END IF;

   RETURN g_session_user;

   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            RETURN NULL;
         end if;
   END get_session_user;
   ---------------------------------------------------------------------
   --< get_ip_address >
   ---------------------------------------------------------------------
   --  Purpose: Gets IP Address for current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_ip_address RETURN VARCHAR2 IS
   BEGIN
   IF g_ip_address IS NULL THEN
        g_ip_address := SYS_CONTEXT('USERENV', 'IP_ADDRESS');
   END IF;

   RETURN g_ip_address;

   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            RETURN NULL;
         end if;
   END get_ip_address;
   ---------------------------------------------------------------------
   --< get_terminal >
   ---------------------------------------------------------------------
   --  Purpose: Gets TERMINAL for current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_terminal RETURN VARCHAR2 IS
   BEGIN
   IF g_terminal IS NULL THEN
        g_terminal := SYS_CONTEXT('USERENV', 'TERMINAL');
   END IF;

   RETURN g_terminal;

   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            RETURN 'Not Available';
         end if;
   END get_terminal;
   ---------------------------------------------------------------------
   --< get_session_id >
   ---------------------------------------------------------------------
   --  Purpose: Gets TERMINAL for current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_session_id RETURN VARCHAR2 IS
   BEGIN
   IF g_session_id IS NULL THEN
        g_session_id := SYS_CONTEXT('USERENV', 'SESSIONID');
   END IF;

   RETURN g_session_id;

   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            RETURN NULL;
         end if;
   END get_session_id;
   ---------------------------------------------------------------------
   --< get_os_user >
   ---------------------------------------------------------------------
   --  Purpose: Gets TERMINAL for current session
   --
   --  comments
   --
   ---------------------------------------------------------------------
   FUNCTION get_os_user RETURN VARCHAR2 IS
   BEGIN
   IF g_os_user IS NULL THEN
        g_os_user := SYS_CONTEXT('USERENV', 'OS_USER');
   END IF;

   RETURN g_os_user;

   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            RETURN NULL;
         end if;
   END get_os_user;
   ---------------------------------------------------------------------
   --< Register >
   ---------------------------------------------------------------------
   --  Purpose: Wraps the DBMS_ALERT.REGISTER procedure
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE register(p_name IN varchar2) IS
   BEGIN
      dbms_alert.register(p_name);
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            NULL;
         end if;
   END register;
   
   ---------------------------------------------------------------------
   --< waitany >
   ---------------------------------------------------------------------
   --  Purpose: Wraps the DBMS_ALERT.WAITANY procedure
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE waitany(p_name OUT varchar2, p_message OUT varchar2, p_status OUT number, p_timeout IN number) IS
   BEGIN
      dbms_alert.WAITANY(p_name, p_message, p_status, p_timeout);
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            NULL;
         end if;
   END WAITANY;
   ---------------------------------------------------------------------
   --< waitone >
   ---------------------------------------------------------------------
   --  Purpose: Wraps the DBMS_ALERT.WAITONE procedure
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE waitone(p_name IN varchar2, p_message OUT varchar2, p_status OUT number, p_timeout IN number) IS
   BEGIN
      dbms_alert.waitone(p_name, p_message, p_status, p_timeout);
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            NULL;
         end if;
   END WAITONE;
   ---------------------------------------------------------------------
   --< signal >
   ---------------------------------------------------------------------
   --  Purpose: Wraps the DBMS_ALERT.SIGNAL procedure
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE SIGNAL (p_name IN varchar2, p_message IN varchar2) IS
   BEGIN 
      dbms_alert.signal(p_name, p_message);
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            NULL;
         end if;
   END SIGNAL;
   ---------------------------------------------------------------------
   --< remove >
   ---------------------------------------------------------------------
   --  Purpose: Wraps the DBMS_ALERT.REMOVE procedure
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE remove (p_name IN varchar2) IS
   BEGIN
      dbms_alert.remove(p_name);
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            NULL;
         end if;
   END remove;
   ---------------------------------------------------------------------
   --< removeall >
   ---------------------------------------------------------------------
   --  Purpose: Wraps the DBMS_ALERT.REMOVEALL procedure
   --
   --  comments
   --
   ---------------------------------------------------------------------
   PROCEDURE removeall IS
   BEGIN
      dbms_alert.removeall;
   EXCEPTION
      WHEN OTHERS THEN
         if get_raise_exceptions then 
            raise;
         else
            NULL;
         end if;
   END REMOVEALL;
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
   PROCEDURE set_raise_exceptions(raise_exceptions boolean)
   IS
   BEGIN
      g_raise_exceptions := NVL (raise_exceptions, g_raise_exceptions);
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END set_raise_exceptions;

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
   FUNCTION get_raise_exceptions RETURN boolean
      IS
   BEGIN
      RETURN g_raise_exceptions;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
   END get_raise_exceptions;

END Hotsos_Sysutil;
