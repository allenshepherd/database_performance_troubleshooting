Rem
Rem $Header: rdbms/admin/dbmsgen.sql /main/1 2015/04/12 11:36:35 jorgrive Exp $
Rem
Rem dbmsgen.sql
Rem
Rem Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      dbmsgen.sql - Replication code generators.
Rem
Rem    DESCRIPTION
Rem     Routines to generate shadow tables, triggers, and packages for
Rem     table replication.
Rem     Routines to generate wrappers for replication of standalone procedure
Rem     invocations, and packaged procedure invocations.
Rem     Routines which support generated replication code.
Rem
Rem    NOTES
Rem      The procedural option is needed to use this facility.
Rem
Rem      This package is installed by sys (connect internal).
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsgen.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmsgen.sql
Rem    SQL_PHASE: DBMSGEN
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/dbmsrepl.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     jorgrive   02/11/15  - restore package 
Rem     surman     12/29/13  - 13922626: Update SQL metadata
Rem     jovillag   05/28/13  - 16681267: Remove execute grant from
Rem                            dbms_reputil and dbms_reputil2 
Rem     surman     03/27/12  - 13615447: Add SQL patching tags
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     rvenkate   01/30/01  - add bit() that returns number
Rem     liwong     11/22/00  - enhance bit
Rem     avaradar   12/20/98  - add gowner to ensure_normal_status              
Rem     liwong     05/04/98  - remove version in make_internal_pkg
Rem     liwong     02/11/98  - remove set_from_remote                          
Rem     liwong     12/17/97  - internal packages                               
Rem     jstamos    05/14/97 -  bug 493190: replace choose3 with get_final
Rem     jstamos    05/13/97 -  bug 433036: add more pure functions
Rem     sbalaram   04/27/97 -  add nchar procedures for append site and seq
Rem     jstamos    11/20/96 -  nchar support
Rem     jstamos    09/16/96 -  send on update/delete
Rem     jstamos    08/08/96 -  add LOBs to dbms_reputil2
Rem     ldoo       05/08/96 -  Add support for exp/imp replication triggers
Rem     jstamos    05/07/96 -  minimize update communication
Rem     ldoo       05/09/96 -  New security model
Rem     ldoo       02/13/96 -  Add a new parameter to rep_begin
Rem     ldoo       01/17/96 -  Replace replication_is_on with ugaknt
Rem     hasun      08/17/95 -  Add better quiesce check for all sync objects
Rem     hasun      06/01/95 -  merge changes from branch 1.4.720.3
Rem     hasun      04/20/95 -  Move package spec of dbms_defergen to prvtgen.sq
Rem     hasun      03/13/95 -  Fix checkin problems from last revision
Rem     ldoo       01/24/95 -  Modify trigger generator for Object Groups
Rem     jstamos    12/23/94 -  merge all changes from 7.2
Rem     jstamos    11/11/94 -  merge changes from branch 1.1.710.7
Rem     adowning   10/13/94 -  merge rev 1.1.710.4
Rem     adowning   09/21/94 -  improved comments
Rem     ldoo       08/18/94 -  Changed to use columns in the column group
Rem                            instead of parameter columns in the if
Rem                            ignore_discard_flag then section of user funcs.
Rem     adowning   08/10/94 -  Move dbms_maint_gen to prvt from dbms
Rem     ldoo       07/19/94 -  Took out FLOAT as a valid column datatype.
Rem     ldoo       06/23/94 -  Added automatic conflict resolution.
Rem     ldoo       05/09/94 -  Changed the generated trigger by replacing
Rem                            dbms_defer arg calls with dbms_reputil arg
Rem                            calls.  Hence reduce size and enhance speed.
Rem                            Added arg call procedures in dbms_reputil pkg.
Rem     ldoo       03/02/94 -  The argument$.type for ROWID is 69 not 11.
Rem                         -  Default for generate_wrapper_package.procedure_
Rem                            prefix should be NULL.
Rem                         -  Proper error message for attempt to wrap func.
Rem     ldoo       02/25/94 -  Fixed plsql parser bug workaround.
Rem                         -  Do not validate generate_trigger.package_name.
Rem     ldoo       02/18/94 -  Skip LONG and LONG RAW columns in row/col repl.
Rem                         -  Fixed hanging is_dest_node_provided function.
Rem     ldoo       02/17/94 -  Workaround plsql parser bug by adding () to
Rem                            every ten AND clauses in the generated package.
Rem     ldoo       01/21/94 -  Fixed to support mixed-case object names.
Rem     ldoo       01/18/94 -  Added 2 more in parameters to 
Rem                              generate_wrapper_package.
Rem                            Use array parsing.
Rem                            Removed commit statement.
Rem                            Replaced some functions with shared ones.
Rem     ldoo       12/17/93 -  Fixed bug about having extra ');' for
Rem                              column-level replication.
Rem                            Fixed bug about not preserving user-assigned
Rem                              package_name and trigger_name.  
Rem                            Uppercased 'p', '$rp', 't' and '$rt'.
Rem                            Validated IN parameter values.
Rem                            Defaulted USER if output_table is not prefixed
Rem                              with schema name.
Rem                            Double quoted column names in generated trigger.
Rem                            Modified already_exists() to use dba views. 
Rem                            Loop until generated package/trigger name is
Rem                              unique.
Rem     ldoo       10/18/93 -  Eliminated IN OUT parameters.  Supports Remote-
Rem                            Only, Synchronous, and Mixed Replications. 
Rem     dsdaniel   09/01/93 -  split into multiple packages, merged in dbmsrepu
Rem     ldoo       08/25/93 -  Coded to the 8/20 version of spec.
Rem     bsouder    08/13/93 -  minor beautification, corrected dbms_snapshot
Rem                            call
Rem     celsbern   08/13/93 -  added comments
Rem     ldoo	   08/13/93 -  Creation to RDBMS spec.
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

@@?/rdbms/admin/sqlsessstart.sql
CREATE OR REPLACE PACKAGE dbms_reputil AS

  ------------
  --  OVERVIEW
  --
  --  This package is referenced only by the generated code.

  ---------------------------
  -- PROCEDURES AND FUNCTIONS
  --

  PROCEDURE replication_on;
  -- Turn on replication.

  PROCEDURE replication_off;
  -- Turn off replication.

  FUNCTION replication_is_on
    RETURN BOOLEAN;
  -- Check if replication is on.

END dbms_reputil;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_reputil FOR dbms_reputil
/

@?/rdbms/admin/sqlsessend.sql
