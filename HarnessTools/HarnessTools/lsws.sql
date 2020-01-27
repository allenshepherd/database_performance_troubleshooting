set echo off

rem $Header$
rem $Name$		lsws.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 

set pages 100 heading on feedback on termout on

col workspace format a30
col num_scenarios heading '# Scenarios'

select workspace, count(*) num_scenarios
  from hscenario
 group by workspace;

clear columns
@henv
