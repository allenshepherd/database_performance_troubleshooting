rem $Header$
rem $Name$      hlogoffon.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem
rem Called by do_main.sql and do_sqltest.sql to
rem disconnect/re-connect in order to generate a
rem new trace file (based on SPID).
rem
rem Normally, the first connect option should be in use.
rem However, if connection errors persist with the first option,
rem comment out that line and uncomment the second line.
rem By doing this, the instance name portion of the connect string
rem will be left to default to the value of ORACLE_SID.
rem

rem @hconnect &hotsos_testharness_user/&hotsos_testharness_passwd@&hotsos_testharness_instance

@hconnect &hotsos_testharness_user/&hotsos_testharness_passwd
