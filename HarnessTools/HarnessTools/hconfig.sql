set echo off
set termout on pause off autotrace off heading on

rem $Header$
rem $Name$

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem


PROMPT
PROMPT Test Harness Configuration Options Setup
PROMPT ========================================
PROMPT      Enter a value for each prompt
PROMPT   or press ENTER to accept the default
PROMPT


accept htst_huser   prompt 'Enter Harness User                    : '
accept htst_hpswd   prompt 'Enter Harness User Password           : '
accept htst_inst    prompt 'Enter Database Instance               : '
accept htst_host    prompt 'Enter SQL*Plus HOST command (host,!,$): '
accept htst_rm_cmd  prompt 'Enter OS erase command (erase,del,rm) : '

PROMPT
PROMPT Enter the full path and executable program name for your preferred editor.
PROMPT The entry should be enclosed in single quotes.
PROMPT For example: 'C:\Program Files\Cool Editor v4\cooledit.exe'
PROMPT
accept htst_editor  prompt 'Enter Preferred Editor     : '

set echo off termout on heading off feedback off

update hconfig
   set HARNESS_USER = '&htst_huser',
       HARNESS_PSWD = '&htst_hpswd',
       DB_INSTANCE = '&htst_inst',
       RM_CMD = '&htst_rm_cmd' ,
       HOST_CMD = '&htst_host' ;

commit ;

update hconfig
   set EDITOR = &htst_editor ;

commit ;


set termout on heading on

col harness_user    noprint new_value hotsos_testharness_user
col harness_pswd    noprint new_value hotsos_testharness_passwd
col db_instance     noprint new_value hotsos_testharness_instance
col editor          noprint new_value _editor
col rm_cmd          noprint new_value _rm
col host_cmd        noprint new_value _hst
col config_string   format a75 word_wrapped heading 'Current Configuration Info'

select rpad('User                 : ' || harness_user,75,' ') ||
       rpad('Password             : ' || harness_pswd,75,' ') ||
       rpad('Instance             : ' || db_instance ,75,' ') ||
       rpad('File Remove Command  : ' || rm_cmd      ,75,' ') ||
       rpad('SQL*Plus HOST Command: ' || host_cmd    ,75,' ') ||
       rpad('Editor               : ' || editor      ,75,' ') AS config_string
  from hconfig ;

set term off heading off

select harness_user, harness_pswd, db_instance, editor, rm_cmd, host_cmd
  from hconfig ;

@hlogin
@henv
