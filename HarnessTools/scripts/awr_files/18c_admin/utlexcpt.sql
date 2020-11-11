rem 
rem $Header: rdbms/admin/utlexcpt.sql /main/4 2017/05/28 22:46:12 stanaya Exp $ 
rem 
Rem  Copyright (c) 1991 by Oracle Corporation 
Rem    NAME
Rem      except.sql - <one-line expansion of the name>
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem    RETURNS
Rem 
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utlexcpt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlexcpt.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem     traney     04/05/11  - 35209: long identifiers dictionary upgrade
Rem     glumpkin   10/20/92 -  Renamed from EXCEPT.SQL 
Rem     epeeler    07/22/91 -         add comma 
Rem     epeeler    04/30/91 -         Creation 

create table exceptions(row_id rowid,
	                owner varchar2(128),
	                table_name varchar2(128),
		        constraint varchar2(128));
