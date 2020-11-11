Rem
Rem $Header: rdbms/admin/dbmsfus.sql /main/5 2014/02/20 12:45:42 surman Exp $
Rem
Rem dbmsfus.sql
Rem
Rem Copyright (c) 2002, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsfus.sql - User Interface for the DB Feature
Rem                    Usage PL/SQL interfaces
Rem
Rem    DESCRIPTION
Rem      Implements the dbms_feature_usage package specification.
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsfus.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsfus.sql
Rem SQL_PHASE: DBMSFUS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    mlfeng      04/26/05 - add report package
Rem    mlfeng      02/04/05 - change grant for package 
Rem    aime        04/25/03 - aime_going_to_main
Rem    mlfeng      01/31/03 - Adding test flag, convert to binary flag
Rem    mlfeng      01/13/03 - DB Feature Usage
Rem    mlfeng      01/08/03 - Creating the package to register DB features
Rem    mlfeng      10/30/02 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

--
-- Note: The description of the dbms_feature_usage PL/SQL Package 
-- is located in prvtfus.sql
--


/**************************************************
 * dbms_feature_usage_report Package Specification 
 **************************************************/
CREATE OR REPLACE PACKAGE dbms_feature_usage_report AS 

  /********************************************************************
   * FUNCTIONS
   *   display_text, display_html
   *
   * DESCRIPTION 
   *   Pipelined functions that displays the DB Feature Report in 
   *   either Text or HTML format for the inputted DBID and Version.
   *
   *   For example, to generate a report on the DB Feature Usage 
   *   data for the local database ID and Version, the following 
   *   statements can be used:
   *   
   *     -- display in Text format
   *     select output from table(dbms_feature_usage_report.display_text);
   *
   *     -- display in HTML format
   *     select output from table(dbms_feature_usage_report.display_html);
   *
   * PARAMETERS
   *   l_dbid    - Database ID to display the DB Feature Usage for.
   *               If NULL, then default to the local dbid.
   *   l_version - Version to display the DB Feature Usage for.
   *               If NULL, then default to the current version.
   *   l_options - Report options, currently no options are supported
   ********************************************************************/

  /* Displays the DB Feature Report in Text format */
  FUNCTION display_text(l_dbid    IN NUMBER   DEFAULT NULL,
                        l_version IN VARCHAR2 DEFAULT NULL,
                        l_options IN NUMBER   DEFAULT 0
                       )
  RETURN awrrpt_text_type_table PIPELINED;

  /* Displays the DB Feature Report in HTML format */
  FUNCTION display_html(l_dbid    IN NUMBER   DEFAULT NULL,
                        l_version IN VARCHAR2 DEFAULT NULL,
                        l_options IN NUMBER   DEFAULT 0
                       )
  RETURN awrrpt_html_type_table PIPELINED;

END dbms_feature_usage_report;
/

SHOW ERRORS;

CREATE OR REPLACE PUBLIC SYNONYM dbms_feature_usage_report
  FOR sys.dbms_feature_usage_report
/
GRANT EXECUTE ON dbms_feature_usage_report TO dba
/

@?/rdbms/admin/sqlsessend.sql
