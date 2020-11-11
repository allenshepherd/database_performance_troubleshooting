Rem
Rem $Header: rdbms/admin/dbmsjdcu.sql /main/4 2014/02/20 12:45:46 surman Exp $
Rem
Rem dbmsjdcu.sql
Rem
Rem Copyright (c) 2000, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsjdcu.sql
Rem
Rem    DESCRIPTION
Rem      custom package procedure to process debug connection request
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsjdcu.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsjdcu.sql
Rem SQL_PHASE: DBMSJDCU
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    rpang       11/28/00 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package dbms_debug_jdwp_custom authid current_user is

  -- This is the default implementation of the custom package
  -- procedure that will be invoked to process a debug connection request
  -- that arrives in the form of an ORA_DEBUG_JDWP environment variable.
  -- This default implemenation is owned by SYS and is made available
  -- to public via a public synonym.
  --
  -- The default implementation of this procedure does not perform any
  -- additional security checks.  A request to connect the session to a
  -- debugger will be controlled only by the DEBUG CONNECT privilege
  -- requirements.  A database user who wants to perform custom security
  -- checks as well can override this default implementation by defining
  -- this same package in his or her own schema and implementing the
  -- check in that local copy.

  -- The arguments to the custom package procedure must all be of varchar2
  -- type or of types which PL/SQL can implicitly convert to varchar2.
  --
  -- A programmer who wants to customize the handling of the debug connection
  -- request may override this default implementation of the package procedure
  -- by installing the same package (specification and body) with a procedure
  -- of the same name in his own schema.  He may customize the number and
  -- names of the arguments to the package procedure.  Only the names of
  -- the package and of the procedure need to remain the same (namely
  -- (DBMS_DEBUG_JDWP_CUSTOM and CONNECT_DEBUGGER respectively).  The
  -- programmer's customized version of the package may contain overloaded
  -- versions of the procedure CONNECT_DEBUGGER with different arguments.
  --
  procedure connect_debugger(host varchar2,
                             port varchar2,
                             debug_role varchar2 := NULL,
                             debug_role_pwd varchar2 := NULL,
                             option_flags pls_integer := 0,
                             extensions_cmd_set pls_integer := 128);

end;
/
create or replace public synonym dbms_debug_jdwp_custom
   for sys.dbms_debug_jdwp_custom
/
grant execute on dbms_debug_jdwp_custom to public
/
create or replace package body dbms_debug_jdwp_custom is

  -- This is the default implementation of the custom package
  -- procedure that will be invoked to process a debug connection request
  -- that arrives in the form of an ORA_DEBUG_JDWP environment variable.
  -- This default implemenation is owned by SYS and is made available
  -- to public via a public synonym.
  --
  -- The default implementation of this procedure does not perform any
  -- additional security checks.  A request to connect the session to a
  -- debugger will be controlled only by the DEBUG CONNECT privilege
  -- requirements.  A database user who wants to perform custom security
  -- checks as well can override this default implementation by defining
  -- this same package in his or her own schema and implementing the
  -- check in that local copy.

  -- The arguments to the custom package procedure must all be of varchar2
  -- type or of types which PL/SQL can implicitly convert to varchar2.
  --
  -- A programmer who wants to customize the handling of the debug connection
  -- request may override this default implementation of the package procedure
  -- by installing the same package (specification and body) with a procedure
  -- of the same name in his own schema.  He may customize the number and
  -- names of the arguments to the package procedure.  Only the names of
  -- the package and of the procedure need to remain the same (namely
  -- (DBMS_DEBUG_JDWP_CUSTOM and CONNECT_DEBUGGER respectively).  The
  -- programmer's customized version of the package may contain overloaded
  -- versions of the procedure CONNECT_DEBUGGER with different arguments.
  --
  procedure connect_debugger(host varchar2,
                             port varchar2,
                             debug_role varchar2 := NULL,
                             debug_role_pwd varchar2 := NULL,
                             option_flags pls_integer := 0,
                             extensions_cmd_set pls_integer := 128)
  is
  begin

    -- Connects the database session to the debugger.
    --
    -- A programmer who wants to perform added security checks to decide if
    -- the debug connection request is granted (for example, by verifying
    -- that the debugger is running on a trusted host) may do so with code
    -- like
    --
    --   if (utl_inaddr.get_host_address(host) != '123.45.67.89') then
    --     raise_application_error(-20000,
    --        'debug connection to ' || host || ' no permitted');
    --   else
    --     dbms_debug_jdwp.connect_tcp(host => host,
    --                                 port => port,
    --                                 debug_role => debug_role,
    --                                 debug_role_pwd => debug_role_pwd,
    --                                 option_flags => option_flags,
    --                                 extensions_cmd_set =>
    --                                 extensions_cmd_set);
    --   end if;
    --
    dbms_debug_jdwp.connect_tcp(host => host,
                                port => port,
                                debug_role => debug_role,
                                debug_role_pwd => debug_role_pwd,
                                option_flags => option_flags,
                                extensions_cmd_set => extensions_cmd_set);
  end;

end;
/

@?/rdbms/admin/sqlsessend.sql
