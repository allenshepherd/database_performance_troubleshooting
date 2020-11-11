Rem
Rem $Header: rdbms/admin/utlexpt1.sql /main/4 2017/05/28 22:46:12 stanaya Exp $
Rem
Rem utlexpt1.sql
Rem
Rem Copyright (c) 1998, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlexpt1.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utlexpt1.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlexpt1.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    echong      06/24/99 - rename
Rem    echong      06/05/98 - exceptions table with urowid type
Rem    echong      06/05/98 - Created
Rem

create table exceptions(row_id urowid,
	                owner varchar2(128),
	                table_name varchar2(128),
		        constraint varchar2(128));

