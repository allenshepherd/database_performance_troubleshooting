Rem
Rem $Header: rdbms/admin/dbmssqll.sql /main/13 2015/02/24 06:59:17 rpang Exp $
Rem
Rem dbmssqll.sql
Rem
Rem Copyright (c) 2009, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmssqll.sql - DBMS_SQL_transLator package specification
Rem
Rem    DESCRIPTION
Rem      This script contains package specification for DBMS_SQL_TRANSLATOR
Rem
Rem    NOTES
Rem      None
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmssqll.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmssqll.sql
Rem SQL_PHASE: DBMSSQLL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       01/15/15 - 17854208: add error logging functions
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    rpang       11/11/13 - 17637420: add translation comments APIs
Rem    rpang       08/26/12 - Rename SQL translation profile attributes
Rem    rpang       07/16/12 - API update
Rem    rpang       06/06/12 - 14165689: Add editionable attribute
Rem    rpang       04/10/12 - 13037650: Make profile object editionable
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    rpang       09/22/11 - 13015720: Add ATTR_FOREIGN_SQL_SYNTAX attr
Rem    rpang       09/15/11 - Doc update
Rem    rpang       06/13/11 - Added enabling/disabling of translations
Rem    rpang       01/05/11 - Updated
Rem    rpang       12/30/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package dbms_sql_translator authid current_user as

  /*
    Package: DBMS_SQL_TRANSLATOR

    DBMS_SQL_TRANSLATOR is the PL/SQL package for creating, configuring and
    using SQL translation profiles.

    Notes:

    DBMSL_SQL_TRANSLATOR is a invoker-rights package. The subprograms in
    DBMS_SQL_TRANSLATOR that modify a profile carry DDL transaction semantics
    and when invoked will commit any open transaction in the session.
   */

  /*----------------------------------------------------------------------
    Constant: ATTR_TRANSLATOR

    The name of the SQL translation profile attribute that specifies the
    translator package. The translator package must be a PL/SQL package with
    the following two procedures that translate SQL statements and errors. The
    names of the parameters of the translate procedures are significant.

    | PROCEDURE translate_sql(sql_text        IN  CLOB,
    |                         translated_text OUT CLOB);
    |
    | PROCEDURE translate_error(error_code          IN  BINARY_INTEGER,
    |                           translated_code     OUT BINARY_INTEGER,
    |                           translated_sqlstate OUT VARCHAR2);
    |
    | Parameters:
    |   sql_text            - SQL statement to be translated
    |   translated_text     - translated SQL statement
    |
    |   error_code          - Oracle error code
    |   translated_code     - translated error code
    |   translated_sqlstate - translated SQLSTATE

    When translating a SQL statement or error, the translator package procedure
    will be invoked with the same current user and current schema as those in
    which the SQL statement is being parsed. The owner of the translator
    package must be granted the *TRANSLATE SQL* user privilege on the current
    user. And the current user must be granted the *EXECUTE* privilege on the
    translator package also.

    When NULL is returned in translated_text, translated_code or
    translated_sqlstate, it assumes that no translation is required and the
    original SQL statement, error code or SQLSTATE is used instead.

    The name of the translator package follows the naming rules for database
    packages of the form [schema.]package_name. When the schema and package
    names are used, they are uppercased by default unless surrounded by
    double quotes. For example, when setting a translator package,
    translator => 'dbms_tsql_translator' is the same as translator =>
    'Dbms_Tsql_Translator' and translator => 'DBMS_TSQL_TRANSLATOR', but not
    the same as translator => '"dbms_tsql_translator"'. If the schema name
    is omitted, the profile owner will be assumed.

    The translator attribute is not set by default.

    ----------------------------------------------------------------------
    Constant: ATTR_FOREIGN_SQL_SYNTAX

    The name of the SQL translation profile attribute that indicates if the
    profile is for the translation of foreign SQL syntax only. If true, only
    SQL statements marked as foreign SQL will be translated. If false, all
    SQL statements executed by the client application will be translated.

    Foreign SQL syntax is true by default.

    ----------------------------------------------------------------------
    Constant: ATTR_TRANSLATE_NEW_SQL

    The name of the SQL translation profile attribute that controls if the
    profile should translate new SQL statements and errors. If so, the
    translator package, if registered, will translate a new SQL statement or
    error not already translated in custom translations, and also register
    the new translation as custom translation. If not, any new SQL statement
    or error encountered will result in a translation error.

    Translate new SQL statements and errors is true by default.

    ----------------------------------------------------------------------
    Constant: ATTR_RAISE_TRANSLATION_ERROR

    The name of the SQL translation profile attribute that controls if the
    profile should raise translation error if a SQL statement or error fails
    to be translated. If not, the profile will attempt to execute or return
    the original SQL statement or error.

    Raise translation error is false by default.

    ----------------------------------------------------------------------
    Constant: ATTR_LOG_TRANSLATION_ERROR

    The name of the SQL translation profile attribute that controls if the
    profile should log translation error in the database alert log.

    Log translation error is false by default.

    ----------------------------------------------------------------------
    Constant: ATTR_TRACE_TRANSLATION

    The name of the SQL translation profile attribute that controls tracing.
    If trace translation is true in a SQL translation profile, any SQL
    statement or error translated by the profile in a database session and
    its translation will be written to the database session's trace file.

    Trace translation is false by default.

    ----------------------------------------------------------------------
    Constant: ATTR_EDITIONABLE

    The name of the SQL translation profile attribute that specifies whether
    the SQL translation profile becomes an editioned or noneditioned object if
    editioning is later enabled for the schema object type SQL translation
    profile in the owner's schema.

    Editionable is true by default.

    ----------------------------------------------------------------------
    Constant: ATTR_LOG_ERRORS

    The name of the SQL translation profile attribute that controls if the
    profile should log errors in translation dictionary tables.

    Log errors is false by default.
  */

  ATTR_TRANSLATOR
                       constant varchar2(30) := 'TRANSLATOR';
  ATTR_FOREIGN_SQL_SYNTAX
                       constant varchar2(30) := 'FOREIGN_SQL_SYNTAX';
  ATTR_TRANSLATE_NEW_SQL
                       constant varchar2(30) := 'TRANSLATE_NEW_SQL';
  ATTR_RAISE_TRANSLATION_ERROR
                       constant varchar2(30) := 'RAISE_TRANSLATION_ERROR';
  ATTR_LOG_TRANSLATION_ERROR
                       constant varchar2(30) := 'LOG_TRANSLATION_ERROR';
  ATTR_TRACE_TRANSLATION
                       constant varchar2(30) := 'TRACE_TRANSLATION';
  ATTR_EDITIONABLE
                       constant varchar2(30) := 'EDITIONABLE';
  ATTR_LOG_ERRORS
                       constant varchar2(30) := 'LOG_ERRORS';

  /*----------------------------------------------------------------------
    Constant: ATTR_VALUE_TRUE

    The value to set a SQL translation profile attribute to true.

    --------------------------
    Constant: ATTR_VALUE_FALSE

    The value to set a SQL translation profile attribute to false.

  */
  ATTR_VALUE_TRUE      constant varchar2(30) := 'TRUE';
  ATTR_VALUE_FALSE     constant varchar2(30) := 'FALSE';

  /*----------------------------------------------------------------------
    Exception: bad_argument

      A bad argument was passed to the PL/SQL API.

    ---------------------------------
    Exception: insufficient_privilege

      The user has insufficient privilege for the operation.

    ---------------------------------
    Exception: no_such_user

      The profile owner does not exist.

    ---------------------------------
    Exception: no_such_profile

      The profile does not exist.

    ---------------------------------
    Exception: profile_exists

      The profile exists already.

    ---------------------------------
    Exception: no_translation_found

      No translation of the SQL statement or error code was found.
  */
  bad_argument           exception;
  insufficient_privilege exception;
  no_such_user           exception;
  no_such_profile        exception;
  profile_exists         exception;
  no_translation_found   exception;

  pragma exception_init(bad_argument,           -29261);
  pragma exception_init(insufficient_privilege,  -1031);
  pragma exception_init(no_such_user,            -1435);
  pragma exception_init(no_such_profile,        -24252);
  pragma exception_init(profile_exists,           -955);
  pragma exception_init(no_translation_found,   -24253);

  /*----------------------------------------------------------------------
    Procedure: create_profile

      Creates a SQL translation profile.

    Parameters:
      profile_name    - profile name
      editionable     - is the profile editionable?

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <profile_exists>

    Notes:
    - A SQL translation profile is a database schema object that resides in
      SQL translation profile namespace. Its name follows the naming rules for
      database objects of the form [schema.]name. When the schema and profile
      names are used in the DBMS_SQL_TRANSLATOR package, they are uppercased
      unless surrounded by double quotes. For example, the translation profile
      profile_name => 'tsql_application' is the same as profile_name =>
      'Tsql_Application' and profile_name => 'TSQL_APPLICATION', but not the
      same as profile_name => '"tsql_application"'.

    - SQL translation profile is an editionable object type.

    - A SQL translation profile cannot be created as a common object in a
      consolidated database.

    - To destroy a SQL translation profile, use <drop_profile>.

    Examples:
    | begin
    |   dbms_sql_translator.create_profile(profile_name => 'tsql_application');
    | end;
  */
  procedure create_profile(profile_name in varchar2,
                           editionable  in boolean default true);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_profile, AUTO_WITH_COMMIT);

  /*----------------------------------------------------------------------
    Procedure: register_sql_translation

      Registers a custom translation of a SQL statement in a SQL translation
      profile.

    Parameters:
      profile_name    - profile name
      sql_text        - SQL statement
      translated_text - translated SQL statement
      enable          - enable or disable the translation

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    Notes:
    - When the Oracle database translates a statement using a translation
      profile, it attempts to look up the registered custom translation first
      and only if no match is found will it invoke the translator package.

    - When a translation is registered in a profile, it may be disabled.
      Disabled translations will not be looked up during translation until
      they are enabled.

    - When translated_text is NULL, it means no translation is required and the
      original statement is used instead.

    - The old translation of the SQL statement, if present, will be replaced
      with the new translation.

    - SQL statements will be canonicalized before being registered or
      translated.

    - To deregister a translation, use <deregister_sql_translation>.

    Examples:
    | begin
    |   dbms_sql_translator.register_sql_translation(
    |       profile_name    => 'tsql_application',
    |       sql_text        => 'select top 5 * from emp',
    |       translated_text => 'select * from emp where rownum <= 5');
    | end;
  */
  procedure register_sql_translation(profile_name    in varchar2,
                                     sql_text        in clob,
                                     translated_text in clob    default null,
                                     enable          in boolean default true);
  PRAGMA SUPPLEMENTAL_LOG_DATA(register_sql_translation, AUTO_WITH_COMMIT);

  /*----------------------------------------------------------------------
    Procedure: enable_sql_translation

      Enables or disables a custom translation of a SQL statement in a SQL
      translation profile.

    Parameters:
      profile_name    - profile name
      sql_text        - SQL statement
      enable          - enable or disable the translation

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    Examples:
    | begin
    |   dbms_sql_translator.enable_sql_translation(
    |       profile_name => 'tsql_application',
    |       sql_text     => 'select top 5 * from emp'
    |       enable       => true);
    | end;
  */
  procedure enable_sql_translation(profile_name in varchar2,
                                   sql_text     in clob,
                                   enable       in boolean default true);
  PRAGMA SUPPLEMENTAL_LOG_DATA(enable_sql_translation, AUTO_WITH_COMMIT);

  /*----------------------------------------------------------------------
    Procedure: deregister_sql_translation

      Deregisters the custom translation of a SQL statement in a SQL
      translation profile.

    Parameters:
      profile_name    - profile name
      sql_text        - SQL statement

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    Examples:
    | begin
    |   dbms_sql_translator.deregister_sql_translation(
    |       profile_name => 'tsql_application',
    |       sql_text     => 'select top 5 * from emp');
    | end;
  */
  procedure deregister_sql_translation(profile_name in varchar2,
                                       sql_text     in clob);
  PRAGMA SUPPLEMENTAL_LOG_DATA(deregister_sql_translation, AUTO_WITH_COMMIT);

  /*----------------------------------------------------------------------
    Procedure: register_error_translation

      Registers a custom translation of an Oracle error code and SQLSTATE in a
      SQL translation profile.

    Parameters:
      profile_name        - profile name
      error_code          - Oracle error code
      translated_code     - translated error code
      translated_sqlstate - translated SQLSTATE
      enable              - enable or disable the translation

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    Notes:
    - When the Oracle database translates an Oracle error code using a
      translation profile, it attempts to look up the registered custom
      translation first and only if no match is found will it invoke the
      translator package.

    - When a translation is registered in a profile, it may be disabled.
      Disabled translations will not be looked up during translation until
      they are enabled.

    - The old translation of the error code and SQLSTATE, if present, will be
      replaced with the new translation.

    - To deregister a translation, use <deregister_error_translation>.

    Examples:
    | begin
    |   dbms_sql_translator.register_error_translation(
    |       profile_name    => 'tsql_application',
    |       error_code      => 1,
    |       translated_code => 2601);
    | end;
  */
  procedure register_error_translation(
              profile_name        in varchar2,
              error_code          in pls_integer,
              translated_code     in pls_integer default null,
              translated_sqlstate in varchar2    default null,
              enable              in boolean     default true);
  PRAGMA SUPPLEMENTAL_LOG_DATA(register_error_translation, AUTO_WITH_COMMIT);

  /*----------------------------------------------------------------------
    Procedure: enable_error_translation

      Enables or disables a custom translation of an Oracle error code in a SQL
      translation profile.

    Parameters:
      profile_name    - profile name
      error_code      - Oracle error code
      enable          - enable or disable the translation

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    Examples:
    | begin
    |   dbms_sql_translator.enable_error_translation(
    |       profile_name => 'tsql_application',
    |       error_code   => 1,
    |       enable       => true);
    | end;
  */
  procedure enable_error_translation(
              profile_name        in varchar2,
              error_code          in pls_integer,
              enable              in boolean default true);
  PRAGMA SUPPLEMENTAL_LOG_DATA(enable_error_translation, AUTO_WITH_COMMIT);

  /*----------------------------------------------------------------------
    Procedure: deregister_error_translation

      Deregisters the custom translation of an Oracle error code and SQLSTATE
      in a SQL translation profile.

    Parameters:
      profile_name    - profile name
      error_code      - Oracle error code

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    Examples:
    | begin
    |   dbms_sql_translator.deregister_error_translation(
    |       profile_name => 'tsql_application',
    |       error_code   => 1);
    | end;
  */
  procedure deregister_error_translation(
              profile_name       in varchar2,
              error_code         in pls_integer);
  PRAGMA SUPPLEMENTAL_LOG_DATA(deregister_error_translation, AUTO_WITH_COMMIT);

  /*----------------------------------------------------------------------
    Procedure: set_attribute

      Sets an attribute of a SQL translation profile.

    Parameters:
      profile_name    - profile name
      attribute_name  - attribute name
      attribute_value - attribute value

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    See also:
      <Constants>
  */
  procedure set_attribute(profile_name    in varchar2,
                          attribute_name  in varchar2,
                          attribute_value in varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(set_attribute, AUTO_WITH_COMMIT);

  /*----------------------------------------------------------------------
    Procedure: export_profile

      Exports the content of a SQL translation profile.

    Parameters:
      profile_name    - profile name
      content         - content of the profile

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    Notes:
    - The content of the SQL translation profile will be exported in XML format
      as follows. Note that the profile name will not be exported.

      | <SQLTranslationProfile Translator="translator package name"
      |                        ForeignSQLSyntax="TRUE|FALSE"
      |                        TranslateNewSQL="TRUE|FALSE"
      |                        RaiseTranslationError="TRUE|FALSE"
      |                        LogTranslationError="TRUE|FALSE"
      |                        TraceTranslation="TRUE|FALSE"
      |                        Editionable="TRUE|FALSE">
      |   <SQLTranslations>
      |     <SQLTranslation Enabled="TRUE|FALSE">
      |       <SQLText>original SQL text</SQLText>
      |       <TranslatedText>translated SQL text</TranslatedText>
      |     </SQLTranslation>
      |     ...
      |   </SQLTranslations>
      |   <ErrorTranslations>
      |     <ErrorTranslation Enabled="TRUE|FALSE">
      |       <ErrorCode>Oracle error code</ErrorCode>
      |       <TranslatedCode>translated error code</TranslatedCode>
      |       <TranslatedSQLSTATE>translated SQLSTATE</TranslatedSQLSTATE>
      |     </ErrorTranslation>
      |     ...
      |   </ErrorTranslations>
      | </SQLTranslationProfile>

    - To import the content to a SQL translation profile, use <import_profile>.

    Examples:
    | declare
    |   content CLOB;
    | begin
    |   dbms_sql_translator.export_profile(
    |       profile_name => 'tsql_application',
    |       content      => content);
    | end;
  */
  procedure export_profile(profile_name in         varchar2,
                           content      out nocopy clob);

  /*----------------------------------------------------------------------
    Procedure: import_profile

      Imports the content of a SQL translation profile.

    Parameters:
      profile_name    - profile name
      content         - content of the profile

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>

    Notes:
    - The content of the SQL translation profile should be in XML format as
      used by <export_profile>. All elements and attributes are optional.

    - If the profile does not exist, it will be created. If it exists, the
      content will override any existing attribute, translator package,
      SQL or error translation registration.

    - To export the content to a SQL translation profile, use <export_profile>.

    Examples:
    | declare
    |   content CLOB;
    | begin
    |   dbms_sql_translator.import_profile(
    |       profile_name => 'tsql_application',
    |       content      => content);
    | end;
  */
  procedure import_profile(profile_name in varchar2,
                           content      in clob);

  /*----------------------------------------------------------------------
    Procedure: drop_profile

      Drops a SQL translation profile and its contents.

    Parameters:
      profile_name    - profile name

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    Examples:
    | begin
    |   dbms_sql_translator.drop_profile(profile_name => 'tsql_application');
    | end;
  */
  procedure drop_profile(profile_name in varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(drop_profile, AUTO_WITH_COMMIT);

  /*----------------------------------------------------------------------
    Procedure: translate_sql

      Translates a SQL statement using the session's SQL translation profile.

    Parameters:
      sql_text        - SQL statement
      translated_text - translated SQL statement

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>
    - <no_translation_found>

    Examples:
    | declare
    |   translated_text CLOB;
    | begin
    |   dbms_sql_translator.translate_sql(
    |       sql_text        => 'select top 5 * from emp',
    |       translated_text => translated_text);
    | end;
  */
  procedure translate_sql(sql_text        in         clob,
                          translated_text out nocopy clob);

  /*----------------------------------------------------------------------
    Procedure: translate_error

      Translates an Oracle error code and an ANSI SQLSTATE using the session's
      SQL translation profile.

    Parameters:
      error_code          - Oracle error code
      translated_code     - translated error code
      translated_sqlstate - translated SQLSTATE

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>
    - <no_translation_found>

    Examples:
    | declare
    |   translated_code     BINARY_INTEGER;
    |   translated_sqlstate VARCHAR2(5);
    | begin
    |   dbms_sql_translator.translate_error(
    |       error_code          => 1,
    |       translated_code     => translated_code,
    |       translated_sqlstate => translated_sqlstate);
    | end;
  */
  procedure translate_error(error_code          in         pls_integer,
                            translated_code     out        pls_integer,
                            translated_sqlstate out nocopy varchar2);

  /*----------------------------------------------------------------------
    Procedure: sql_id

      Computes the SQL identifier of a SQL statement in the session's SQL
      translation profile.
      
    Parameters:
      sql_text        - SQL statement

    Returns:
      The SQL ID of the SQL statement in the session's SQL translation profile.

    Exceptions:
    - <bad_argument>

    Examples:
    | declare
    |   sqltext clob;
    |   sqlid   varchar2(13);
    | begin
    |   sqltext := 'select top 1 * from emp';
    |   sqlid   := dbms_sql_translator.sql_id(sqltext);
    | end;
  */
  function sql_id(sql_text in clob) return varchar2 deterministic;

  /*----------------------------------------------------------------------
    Procedure: sql_hash

      Computes the hash value of a SQL statement in the session's SQL
      translation profile. It may be used to speed up the lookup of a SQL
      translation in SQL translation views.
      
    Parameters:
      sql_text        - SQL statement

    Returns:
      The hash value of the SQL statement in the session's SQL translation
      profile.

    Exceptions:
    - <bad_argument>

    Examples:
    | declare
    |   sqltext clob;
    |   txltext clob;
    |   sqlhash number;
    | begin
    |   sqltext := 'select top 1 * from emp';
    |   sqlhash := dbms_sql_translator.sql_hash(sqltext);
    |
    |   select translated_text into txltext
    |     from user_sql_translations
    |    where sql_hash = sqlhash and
    |          dbms_lob.compare(sql_text, sqltext) = 0;
    | end;
  */
  function sql_hash(sql_text in clob) return number deterministic;

  /*----------------------------------------------------------------------
    Procedure: set_sql_translation_module

      Sets the module and action on a custom translation of a SQL statement in
      a SQL translation profile.

    Parameters:
      profile_name - profile name
      sql_text     - SQL statement
      module       - module
      action       - action

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    Examples:
    | begin
    |   dbms_sql_translator.set_sql_translation_module(
    |       profile_name => 'tsql_application',
    |       sql_text     => 'select top 5 * from emp',
    |       module       => 'employee report',
    |       action       => 'top 5 employees query');
    | end;
  */
  procedure set_sql_translation_module(profile_name in varchar2,
                                       sql_text     in clob,
                                       module       in varchar2,
                                       action       in varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(set_sql_translation_module, AUTO_WITH_COMMIT);

  /*----------------------------------------------------------------------
    Procedure: set_sql_translation_comment

      Sets the comment on a custom translation of a SQL statement in a SQL
      translation profile.

    Parameters:
      profile_name - profile name
      sql_text     - SQL statement
      comment      - comment

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    Examples:
    | begin
    |   dbms_sql_translator.set_sql_translation_comment(
    |       profile_name => 'tsql_application',
    |       sql_text     => 'select top 5 * from emp',
    |       comment      => 'the translation has been reviewed');
    | end;
  */
  procedure set_sql_translation_comment(profile_name in varchar2,
                                        sql_text     in clob,
                                        comment      in varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(set_sql_translation_comment, AUTO_WITH_COMMIT);

  /*----------------------------------------------------------------------
    Procedure: set_error_translation_comment

      Sets the comment on a custom translation of an Oracle error code in a SQL
      translation profile.

    Parameters:
      profile_name - profile name
      error_code   - Oracle error code
      comment      - comment

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    Examples:
    | begin
    |   dbms_sql_translator.set_error_translation_comment(
    |       profile_name => 'tsql_application',
    |       error_code   => 1,
    |       comment      => 'the translation has been reviewed');
    | end;
  */
  procedure set_error_translation_comment(profile_name in varchar2,
                                          error_code   in pls_integer,
                                          comment      in varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(set_error_translation_comment, AUTO_WITH_COMMIT);

  /*----------------------------------------------------------------------
    Procedure: set_dictionary_sql_id

      Sets the SQL identifier of the SQL text in translation dictionary used to
      translate the current SQL statement.

    Parameters:
      dictionary_sql_id - SQL identifier of the SQL text in translation
                          dictionary

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>

    Examples:
    | begin
    |   dbms_sql_translator.set_dictionary_sql_id('cprtcknftr8wf');
    | end;
  */
  procedure set_dictionary_sql_id(dictionary_sql_id in varchar2);

  /*----------------------------------------------------------------------
    Procedure: clear_sql_translation_error

      Clears the last error when the SQL was run.

    Parameters:
      profile_name    - profile name
      sql_text        - SQL statement

    Exceptions:
    - <bad_argument>
    - <insufficient_privilege>
    - <no_such_user>
    - <no_such_profile>

    Examples:
    | begin
    |   dbms_sql_translator.clear_sql_translation_error(
    |       profile_name => 'tsql_application',
    |       sql_text     => 'select top 5 * from emp');
    | end;
  */
  procedure clear_sql_translation_error(profile_name in varchar2,
                                        sql_text     in clob);
  PRAGMA SUPPLEMENTAL_LOG_DATA(clear_sql_translation_error, AUTO_WITH_COMMIT);

end;
/

create or replace public synonym dbms_sql_translator
for sys.dbms_sql_translator
/
grant execute on dbms_sql_translator to public
/

@?/rdbms/admin/sqlsessend.sql
