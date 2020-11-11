Rem
Rem $Header: plsql/admin/utllms.sql /main/6 2014/02/20 12:46:21 surman Exp $
Rem
Rem utllms.sql
Rem
Rem Copyright (c) 2002, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utllms.sql - UTL_LMS message retrieve utility.
Rem
Rem    DESCRIPTION
Rem      Routines to get LMS messages
Rem 
Rem    NOTES
Rem      The package must be created under SYS.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: plsql/admin/utllms.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/utllms.sql
Rem SQL_PHASE: UTLLMS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/13/14 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    lvbcheng    11/08/04 - Specify default behavior for language parameter
Rem    agardner    10/21/04 - Bug#3861541: add usage notes to package spec 
Rem    ywu         10/02/02 - change to varargs
Rem    ywu         09/30/02 - add format message function
Rem    ywu         09/26/02 - ywu_utllms
Rem    ywu         08/07/02 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

/* 
 * PACKAGE: UTL_LMS 
 * Package for retrieving and formatting error messages
 */

CREATE OR REPLACE PACKAGE utl_lms AS
   /*
    * FUNCTION: GET_MESSAGE
    * Retrieve a LMS message based on error number, product, facility 
    * and language.
    *
    * PARAMETERS
    *    errnum   - The error number, for example, 972 for ORA-00972 message.
    *    product  - Product of the LMS message. For example, 'rdbms'.
    *    facility - Facility of the LMS message. For example, 'ora'.
    *    language - Language of the LMS message. By default, it is NULL.
    *               Note: if this parameter is left null, the language
    *               used will be derived from the character set of the
    *               message parameter.
    *    message  - Output the retrieved message.
    * RETURN
    *   0   when success
    *   -1  when fail
    * EXCEPTIONS
    *   miscellaneous runtime exceptions.
    * NOTES
    *   A nls_lang style value can be supplied as the 'language' argument,
    *   though only the language element is functionally significant to the
    *   result. Any character set secified in the language value is ignored
    *   as the encoding of the output mesage is determined by the context
    *   of the plsql call.
    */
   FUNCTION get_message(errnum   IN  PLS_INTEGER,
                        product  IN  VARCHAR2,
                        facility IN  VARCHAR2,
                        language IN  VARCHAR2,
                        message  OUT NOCOPY VARCHAR2 CHARACTER SET ANY_CS)
        RETURN PLS_INTEGER;

   /* 
    *  FUNCTION: 
    *  Format the retrieved LMS message. 
    *   
    *  Format string special characters
    *    '%s'   - substitute next string argument
    *    '%d'   - substitute next integer argument
    *    '%%'   - special character '%'
    *
    *  PARAMETERS
    *    format - Formatting string.
    *    args   - Subtitution arguments list.
    *  RETURN
    *    Fomatted result    on success.
    *    NULL               on failure.
    * EXCEPTIONS
    *   miscellaneous runtime exceptions.
    */
    FUNCTION format_message(format IN VARCHAR2 CHARACTER SET ANY_CS,
                           args ...)
      RETURN VARCHAR2 CHARACTER SET format%CHARSET; 
  
END utl_lms;
/
GRANT EXECUTE ON sys.utl_lms TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_lms FOR sys.utl_lms; 

@?/rdbms/admin/sqlsessend.sql
