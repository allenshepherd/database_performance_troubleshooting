Rem
Rem $Header: rdbms/admin/catdrdaas.sql /main/2 2014/11/12 21:07:58 cbenet Exp $
Rem

Rem
Rem Copyright (c) 2011, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catdrdaas.sql - CATalog DRDA Application Server
Rem
Rem    DESCRIPTION
Rem      Customer-run .sql file to catalog the DRDA Application Server
Rem
Rem    NOTES
Rem      
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catdrdaas.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catdrdaas.sql
Rem SQL_PHASE: NONE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA

Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cbenet      11/01/14 - add METADATA
Rem    pcastro     11/03/11 - Created
Rem

Rem =====================================================================
Rem Exit immediately if there are errors in the initial checks
Rem =====================================================================

WHENEVER SQLERROR EXIT;

DOC
#######################################################################
  Customer should create the SYSIBM tablespace

Eg:
  create tablespace SYSIBM datafile 'sysibm01.dbf'
   size 70M reuse 
   extent management local 
   segment space management auto 
   online;

#######################################################################
#

@@prvtdpsadrda.plb

