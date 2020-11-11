Rem
Rem $Header: plsql/admin/utlmatch.sql /main/3 2017/10/27 14:10:49 lvbcheng Exp $
Rem
Rem utlmatch.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlmatch.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: plsql/admin/utlmatch
Rem SQL_SHIPPED_FILE: rdbms/admin/utlmatch.sql
Rem SQL_PHASE: UTLMATCH
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lvbcheng    10/05/17 - Deprecate the package
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    rdecker     05/28/04 - rdecker_utl_match
Rem    rdecker     03/02/04 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE utl_match IS
   pragma deprecate(UTL_MATCH);
   FUNCTION edit_distance(s1 IN VARCHAR2, s2 IN VARCHAR2)
                          RETURN pls_integer;
   PRAGMA interface(c, edit_distance);
   
   FUNCTION jaro_winkler(s1 IN VARCHAR2, s2 IN VARCHAR2)
                         RETURN binary_double;
   PRAGMA interface(c, jaro_winkler);
   
   FUNCTION edit_distance_similarity(s1 IN VARCHAR2, s2 IN VARCHAR2)
                                     RETURN pls_integer;
   PRAGMA interface(c, edit_distance_similarity);

   FUNCTION jaro_winkler_similarity(s1 IN VARCHAR2, s2 IN VARCHAR2)
                                    RETURN pls_integer;
   PRAGMA interface(c, jaro_winkler_similarity);

END utl_match;
/
show errors;

GRANT EXECUTE ON utl_match TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_match FOR sys.utl_match;

@?/rdbms/admin/sqlsessend.sql
