set echo off

rem $Header$
rem $Name$			hstatslevel.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 
rem Must have DBA or explicit privileges granted to execute this script


COLUMN statistics_name      FORMAT A30 HEADING "Statistics Name"
COLUMN session_status       FORMAT A10 HEADING "Session|Status"
COLUMN system_status        FORMAT A10 HEADING "System|Status"
COLUMN activation_level     FORMAT A10 HEADING "Activation|Level"
COLUMN session_settable     FORMAT A10 HEADING "Session|Settable"

SELECT statistics_name,
       session_status,
       system_status,
       activation_level,
       session_settable
FROM   v$statistics_level
ORDER BY statistics_name
/

clear columns

@henv
