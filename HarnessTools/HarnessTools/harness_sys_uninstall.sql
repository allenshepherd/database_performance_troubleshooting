rem $Header$
rem $Name$

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 
rem Drop all SYS owned Hotsos SQL Test Harness objects

SET ERRORLOGGING on IDENTIFIER HARNESS_INSTALL_SYS_UNINSTALL

drop view hotsos_parameters ;
drop directory UDUMP_DIR ;
drop view session_trace_file_name ;
drop table avail_trace_files ;
drop view user_avail_trace_files ;
drop public synonym user_avail_trace_files ;
drop table trace_file_text ;
drop public synonym trace_file_text ;
drop package hotsos_pkg;
drop public synonym hotsos_pkg ;
