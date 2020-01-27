set echo off

rem $Header$
rem $Name$      hgettrace.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Display any named trace file found in the UDUMP directory.
rem
rem Usage:
rem         SQL> @hgettrace hotsos_ora_1234.trc
rem         Modified 11/24/2013 Gpro  change \ to /
rem

set termout on feed off verify off

ed &udump/&1

clear columns
@henv
