Rem
Rem $Header: rdbms/admin/dbmsjdmp.sql /main/3 2014/02/20 12:45:39 surman Exp $
Rem
Rem dbmsjdmp.sql
Rem
Rem Copyright (c) 2002, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsjdmp.sql - DBMS_JAVA_DUMP
Rem
Rem    DESCRIPTION
Rem      Package API to request various dumps from the Java VM.
Rem
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsjdmp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsjdmp.sql
Rem SQL_PHASE: DBMSJDMP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    dalpern     10/12/02 - support triggering java dumps via kga
Rem    dalpern     10/11/02 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


create or replace package dbms_java_dump authid current_user is

  --  Note: This package allows the user to request various Java VM
  --  dumps from any active database session.  No special privilege
  --  is needed to do so other than the ability to invoke this package.
  --
  --  Oracle's installation deliberately does not grant EXECUTE
  --  privilege on this package to anyone beyond SYS.  A DBA can choose
  --  to grant EXECUTE on this package to either specific users or
  --  to PUBLIC, but should consider:
  --
  --    a) Heap dumps can contain sensitive data.  Be sure the
  --       dump destination directory area can only be read by a
  --       sufficiently trustable audience.
  --
  --    b) Heap dumps can be large.  Be sure having large files
  --       written to the dump destination directory area won't risk
  --       the stability of your server.
  --
  --    c) Writing dumps can noticably slow down program execution.
  --       Permitting someone to request that a random session write
  --       dumps can allow denial-of-service attacks.
  --
  --  


  -- DBMS_JAVA_DUMP.DUMP:

  -- Request that the specified session dump info about its Java VM
  -- when it is next able to do so.
  --
  -- To make a request to the current session itself, you can pass NULL
  -- to both the session_id and session_serial parameters or just leave
  -- them to default.
  --
  -- The request flags passed in each call will be ORed together with
  -- those from any other pending requests to the same session.  If
  -- multiple requests are made to the same session before it has a
  -- chance to act on the first, most likely the various requested dumps
  -- will be written together.
  --
  -- Currently this routine returns after the request is made, not
  -- after the dump is actually written.  No feedback is available
  -- currently as to whether or when the dump is successfully written.
  --

  procedure dump(request_flags pls_integer,
                 session_id pls_integer := NULL,
                 session_serial pls_integer := NULL);

  -- Values for request_flags argument:
  --   These may be added together to select multiple dump choices.

  java_dump_db_interface_info           constant pls_integer := 1;
  java_dump_stack                       constant pls_integer := 2;
  java_dump_memory_manager_state        constant pls_integer := 4;
  java_dump_heap                        constant pls_integer := 8;
  java_dump_threads_and_monitors        constant pls_integer := 16;

end;
/
create or replace public synonym dbms_java_dump for sys.dbms_java_dump
/

@?/rdbms/admin/sqlsessend.sql
