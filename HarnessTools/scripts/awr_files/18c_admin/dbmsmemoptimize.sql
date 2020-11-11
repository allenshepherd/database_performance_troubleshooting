Rem
Rem $Header: rdbms/admin/dbmsmemoptimize.sql /st_rdbms_18.0/1 2017/11/29 18:12:34 miglees Exp $
Rem
Rem dbmsmemoptimize.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsmemoptimize.sql - DBMS_MEMOPTIMIZE Package Definition
Rem
Rem    DESCRIPTION
Rem      This package is written as part of Project 68493:
Rem         1. Fast Lookups
Rem         2. Fast Data Ingestion
Rem
Rem    NOTES
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsmemoptimize.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsmemoptimize.sql
Rem SQL_PHASE: DBMSMEMOPTIMIZE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    miglees     11/27/17 - XbranchMerge miglees_bug-27051964 from main
Rem    miglees     11/05/17 - Bug 27051964: Remove Memoptimize for Write
Rem                           functionality
Rem    kshergil    05/28/17 - 25632497: package cleanup
Rem    siteotia    06/07/17 - Bug 25394535: add drop_object for hashindex.
Rem    kshergil    05/08/17 - 25994649: fix ingest hwm APIs
Rem    siteotia    02/17/17 - Bugs 25368492, 25367835:Exceptions for populate
Rem    miglees     12/05/16 - Add Fast Ingest APIs
Rem    kshergil    11/05/16 - Add test write path
Rem    siteotia    10/18/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


create or replace package dbms_memoptimize authid current_user as

/*
 *
 * Bugs 25368492 and 25367835: Define Exceptions
 *
 */
          schema_name_invalid         exception;
              pragma  exception_init(schema_name_invalid,
                                     -62135);

          table_name_invalid         exception;
              pragma  exception_init(table_name_invalid,
                                     -62136);



/*********************************************************************
 *                                                                   *
 *           START - APIs for fast lookup project                    *
 *                                                                   *
 ********************************************************************/


/*--------------------------POPULATE----------------------------------
 *
 * Procedure:
 *   DBMS_MEMOPTIMZE.POPULATE()
 *
 * Description:
 *   Used for populating the in-memory hash index with object's data
 *
 * Parameters:
 *   schema_name    --     Name of object owner of the object
 *   table_name     --     Name of table whose data is to be stored 
 *                         into in-memory hash index.
 *   partition_name --     Name of the table partition. If not NULL, 
 *                         the data from this particular partition 
 *                         will be stored in in-memory hash index.
 * 
 *------------------------------------------------------------------*/


      PROCEDURE populate(
          schema_name       in      varchar2,
          table_name        in      varchar2,
          partition_name    in      varchar2 DEFAULT NULL
       );


/*--------------------------DROP_OBJECT-------------------------------
 *
 * Procedure:
 *   DBMS_MEMOPTIMZE.DROP_OBJECT()
 *
 * Description:
 *   Used for dropping an object (table, partition, subpartition) from
 *   in-memory hashindex.
 *
 * Parameters:
 *   schema_name    --     Name of object owner of the object
 *   table_name     --     Name of table whose data is to be stored 
 *                         into in-memory hash index.
 *   partition_name --     Name of the table partition. If not NULL, 
 *                         the data from this particular partition 
 *                         will be stored in in-memory hash index.
 * 
 *------------------------------------------------------------------*/


      PROCEDURE drop_object(
          schema_name       in      varchar2,
          table_name        in      varchar2,
          partition_name    in      varchar2 DEFAULT NULL
       );



/********************************************************************
 *                                                                  *
 *           END - APIs for fast lookup project                     *
 *                                                                  *
 *******************************************************************/






end dbms_memoptimize;
/
grant execute on sys.dbms_memoptimize to public;
/
create or replace public synonym dbms_memoptimize for sys.dbms_memoptimize
/
create or replace library DBMS_MEMOPTIMIZE_LIB trusted as static;
/
show errors
/

@?/rdbms/admin/sqlsessend.sql
 
