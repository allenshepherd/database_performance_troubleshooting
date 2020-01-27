rem $Header$
rem $Name$          harness_sys_install.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem The following packages should be installed but are
rem not included in this installation script:
rem   1) dbms_support
rem   2) dbms_pipe
rem   3) dbms_monitor (v10)
rem   4) dbms_lock
rem   5) dbms_space
rem
rem All the packages should be installed and have public
rem synonyms created.  The grants to access these
rem packages are found in the harness_grant_privs.sql script.
rem
rem You must be logged in as SYS (with SYSDBA) or with a DBA privileged
rem account for these objects to install properly.
rem
rem If you are installing this with a DBA privileged account (not SYS)
rem then the account must have permissions granted explicitly on certain
rem objects in order for the install to complete properly.  Execute
rem @harness_dba_privs <dba account> while logged in as SYS to grant the
rem DBA account the appropriate privileges before installing the harness.
rem

SET ERRORLOGGING on IDENTIFIER HARNESS_INSTALL_SYS_INSTALL

set echo off
set termout on feed off

spool harness_sys_install.log

rem ****** CHANGE ME ******
rem Change the following DEFINE variable values as appropriate

rem What is the command for your operating system that will delete/remove a file?
rem What is the command for your operating system that will open a host prompt?
rem UNComment the appropriate lines for your operating system
define _rm='erase'     -- ****** Use for Windows ******
define _hst='$'        -- ****** Use for Windows ******
rem define _rm='rm'    -- ****** Use for UNIX ******
rem define _hst='host' -- ****** Use for UNIX ******

rem This code determines the USER_DUMP_DEST directory.
column value new_val p_udump noprint
select value from v$parameter where UPPER(name) = 'USER_DUMP_DEST';

rem ****** CHANGE ME ******
rem Change the filename column definition to match your OS
rem (HP in particular requires a change for filename format here)
rem
rem Note that the do.sql script sets the tracefile_identifier
rem to 'harness' so that trace files created via the harness
rem are easily differentiated from non-harness trace files
rem

set feed on echo on

drop view session_trace_file_name ;

rem The default filename format = mydb_ora_1234_harness.trc
create view session_trace_file_name
as
select lower(d.instance_name || '_ora_' || ltrim(to_char(a.spid)) || '_harness.trc') filename
  from v$process a, v$session b, v$instance d
 where a.addr = b.paddr
   and b.audsid = sys_context('userenv','sessionid') ;

rem Path must match USER_DUMP_DEST
drop directory UDUMP_DIR ;
create or replace directory UDUMP_DIR
as '&p_udump' ;

drop table avail_trace_files ;
create table avail_trace_files (
 username   varchar2(30) default user,
 filename   varchar2(512),
 dt         date default sysdate,
 hscenario_id number,
 trc_type   number,
 constraint avail_trace_files_pk primary key (username, hscenario_id, trc_type)
)
 organization index ;

drop view user_avail_trace_files ;
create view user_avail_trace_files
as
select * from avail_trace_files
 where username = user;

drop public synonym user_avail_trace_files ;
create public synonym user_avail_trace_files for user_avail_trace_files ;
grant select on user_avail_trace_files to public ;

drop table trace_file_text ;
create global temporary table trace_file_text
( id number primary key,
  hscenario_id number,
  trc_type number,
  text varchar(4000)
) ;

drop public synonym trace_file_text ;
create public synonym trace_file_text for trace_file_text ;
grant select on trace_file_text to public;

rem Package for Hotsos Tools Pack scripts.
drop package hotsos_pkg;

set termout off verify off heading off feed off

rem located in \harnesstools
@hotsospkg

spool harness_sys_install2.log

set termout on feed on heading on echo on

drop public synonym hotsos_pkg ;
create public synonym hotsos_pkg for hotsos_pkg ;

rem This grant is made when running harness_grant_privs.sql to a specified ID only.
rem Uncomment to provide package access to public.
grant execute on hotsos_pkg to public;

rem The following output verifies the installation status of the required harness objects
set head on echo off
column object_name format a25
column object_type format a20
column status format a10

select status, object_name, object_type
  from dba_objects
 where object_name IN ('HOTSOS_PARAMETERS','HOTSOS_PKG',
                       'TRACE_FILE_TEXT', 'USER_AVAIL_TRACE_FILES',
                       'AVAIL_TRACE_FILES','SESSION_TRACE_FILE_NAME');

show parameter user_dump_dest

column directory_name format a10 heading 'DIRECTORY'
column directory_path format a60 heading 'PATH'

select directory_name, directory_path from dba_directories
 where directory_name = 'UDUMP_DIR';

spool off

undefine p_udump

clear columns
@henv
