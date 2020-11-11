Rem
Rem $Header: rdbms/admin/catnoratmask.sql /main/2 2015/01/27 12:25:17 surman Exp $
Rem
Rem catnoratmask.sql
Rem
Rem Copyright (c) 2010, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnoratmask.sql - CATalog script to remove RAT masking tables
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catnoratmask.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catnoratmask.sql
Rem SQL_PHASE: CATNORATMASK
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/15 - 20386160: Add SQL metadata tags
Rem    sburanaw    12/09/10 - add wri$_sts_masking_errors
Rem    sburanaw    11/21/10 - Created
Rem


DROP TABLE wrr$_masking_definition;
DROP TABLE wrr$_masking_parameters;
DROP TABLE wri$_sts_granules
DROP TABLE WRI$_STS_SENSITIVE_SQL;
DROP TABLE WRI$_MASKING_SCRIPT_PROGRESS;
DROP TABLE WRI$_STS_MASKING_STEP_PROGRESS;
DROP TABLE WRR$_MASKING_BIND_CACHE;
DROP TABLE WRR$_MASKING_FILE_PROGRESS;
DROP TABLE WRI$_STS_MASKING_ERRORS;
DROP TABLE WRI$_STS_MASKING_EXCEPTIONS;

DROP SEQUENCE WRI$_SQLSET_RATMASK_SEQ;
