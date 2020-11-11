Rem
Rem $Header: rdbms/admin/hangdiag.sql /main/4 2017/05/28 22:46:06 stanaya Exp $
Rem
Rem hangdiag.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      hangdiag.sql - Hang Diagnosis script
Rem
Rem    DESCRIPTION
Rem      It is generally useful (but not necessary) to run this script from a
Rem      prelim mode connection.
Rem
Rem      This script dumps data required to diagnose hangs:
Rem      1. ASH dump
Rem      2. Systemstate dump with short callstacks
Rem      3. Hang analysis results (x$ksdhng_chains)
Rem
Rem    NOTES
Rem      It is required to set PID using oradebug setmypid/setospid/setorapid
Rem      before invoking this script. 
Rem
Rem      "oradebug tracefile_name" gives the file name including the path of
Rem      the trace file containing the dumps.
Rem
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/hangdiag.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/hangdiag.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    amysoren    06/08/07 - direct_access command syntax change
Rem    avaliani    05/17/07 - bug 5499564: add x$ksdhng_chains
Rem    amysoren    01/10/07 - add ashdump, systemstate dump
Rem    amysoren    01/10/07 - Created
Rem

-- begin hang diag dump
oradebug dump hangdiag_header 1

-- dump hang analysis chains
oradebug direct_access enable trace
oradebug direct_access disable reply
oradebug direct_access set content_type = 'text/plain'
oradebug direct_access select * from x$ksdhng_chains

-- dump ash data
oradebug dump ashdump 5

-- dump systemstate with short callstacks
oradebug dump systemstate 267
