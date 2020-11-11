Rem
Rem $Header: rdbms/admin/dbmsrcad.sql /main/12 2016/05/20 15:40:03 achaudhr Exp $
Rem
Rem dbmsrcad.sql
Rem
Rem Copyright (c) 2005, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsrcad.sql - Result Cache ADministration
Rem
Rem    DESCRIPTION
Rem      A PL/SQL interface to manage the Result Cache.
Rem
Rem    NOTES
Rem      Use this package in conjuction with the relevant V$RESULT_CACHE_* views
Rem      (that show the contents and statistics of the Result Cache).
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsrcad.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsrcad.sql
Rem SQL_PHASE: DBMSRCAD
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    achaudhr    02/23/16 - 7305006: Add BYPASS API
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    achaudhr    02/04/10 - Add STATUS_CORR status
Rem    achaudhr    10/22/08 - Add API
Rem    achaudhr    07/23/08 - Flush: Optional global parameter
Rem    tbingol     06/18/07 - Rename open/close to enable/disable
Rem    achaudhr    05/10/07 - Change varchar to varchar2
Rem    kmuthukk    04/17/07 - add API for cache bypass
Rem    achaudhr    03/14/07 - Add (default) argument detailed to Memory_Report
Rem    achaudhr    02/02/07 - Add Memory_Report
Rem    achaudhr    09/28/05 - Result_Cache: Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


CREATE OR REPLACE PACKAGE DBMS_RESULT_CACHE as

  /**
   * NAME:
   *   Status
   * DESCRIPTION:
   *   Checks the status of the Result Cache.
   * PARAMETERS:
   *   None.
   * RETURNS:
   *   One of the following values.
   *     STATUS_DISA: Cache is NOT available. 
   *     STATUS_ENAB: Cache is available.
   *     STATUS_BYPS: Cache has been temporarily made unavailable.
   *     STATUS_SYNC: Cache is available, but is synchronizing with RAC nodes.
   *     STATUS_CORR: Cache is corrupt and thus unavailable.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   None.
   */  

  STATUS_DISA CONSTANT VARCHAR2(10) := 'DISABLED';
  STATUS_ENAB CONSTANT VARCHAR2(10) := 'ENABLED';
  STATUS_BYPS CONSTANT VARCHAR2(10) := 'BYPASS';
  STATUS_SYNC CONSTANT VARCHAR2(10) := 'SYNC';
  STATUS_CORR CONSTANT VARCHAR2(10) := 'CORRUPT';

  FUNCTION Status RETURN VARCHAR2;

  /**
   * NAME:
   *   Flush
   * DESCRIPTION:
   *   Attempts to remove all the objects from the Result Cache, and depending
   *   on the arguments retains/releases the memory and retains/clears the
   *   statistics.
   * PARAMETERS:
   *   retainMem - TRUE            => retains the free memory in the cache
   *               FALSE (default) => releases the free memory to the system
   *   retainSta - TRUE            => retains the existing cache statistics
   *               FALSE (default) => clears the existing cache statistics
   *   global    - TRUE            => flushes all caches in the RAC cluster
   *               FALSE (default) => flushes only the local instance cache
   * RETURNS:
   *   TRUE iff was successful in removing ALL the objects.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   Objects that are under an active scan are not removed. 
   */  
  FUNCTION  Flush(retainMem IN BOOLEAN DEFAULT FALSE,
                  retainSta IN BOOLEAN DEFAULT FALSE,
                  global    IN BOOLEAN DEFAULT FALSE) RETURN BOOLEAN;
  PROCEDURE Flush(retainMem IN BOOLEAN DEFAULT FALSE,
                  retainSta IN BOOLEAN DEFAULT FALSE,
                  global    IN BOOLEAN DEFAULT FALSE);

  /**
   * NAME:
   *   Memory_Report
   * DESCRIPTION:
   *   Produces the memory usage report for the Result Cache.
   * PARAMETERS:
   *   detailed - TRUE            => produces a more detailed report
   *              FALSE (default) => produces the standard report
   * RETURNS:
   *   Nothing
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   This procedure uses the DBMS_OUTPUT package; the report requires 
   *   "serveroutput" to be on in SQL*Plus.
   */  
  PROCEDURE Memory_Report(detailed IN BOOLEAN DEFAULT FALSE);


  /**
   * NAME:
   *   Delete_Dependency
   * DESCRIPTION:
   *   Deletes the specified dependency object from the Result Cache, while
   *   invalidating all results that used that dependency object.
   * PARAMETERS [Overload 0]:
   *   owner     - schema name
   *   name      - object name
   * PARAMETERS [Overload 1]:
   *   object_id - dictionary object number 
   * RETURNS:
   *   The number of objects that were invalidated.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   None.
   */  
  FUNCTION  Delete_Dependency(owner IN VARCHAR2, name IN VARCHAR2)RETURN NUMBER;
  PROCEDURE Delete_Dependency(owner IN VARCHAR2, name IN VARCHAR2);

  FUNCTION  Delete_Dependency(object_id IN NATURALN) RETURN NUMBER;
  PROCEDURE Delete_Dependency(object_id IN NATURALN);

  /**
   * NAME:
   *   Invalidate
   * DESCRIPTION:
   *   Invaidates all the result-set objects that dependent upon the specified 
   *   dependency object.
   * PARAMETERS [Overload 0]:
   *   owner     - schema name
   *   name      - object name
   * PARAMETERS [Overload 1]:
   *   object_id - dictionary object number 
   * RETURNS:
   *   The number of objects that were invalidated.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   None.
   */  
  FUNCTION  Invalidate(owner IN VARCHAR2, name IN VARCHAR2) RETURN NUMBER;
  PROCEDURE Invalidate(owner IN VARCHAR2, name IN VARCHAR2);

  FUNCTION  Invalidate(object_id IN NATURALN) RETURN NUMBER;
  PROCEDURE Invalidate(object_id IN NATURALN);

  /**
   * NAME:
   *   Invalidate_Object
   * DESCRIPTION:
   *   Invaidates the specified result-set object(s).
   * PARAMETERS [Overload 0]:
   *   id       - the address of the cache object in the Result Cache
   * PARAMETERS [Overload 1]:
   *   cache_id - the cache-id
   * RETURNS:
   *   The number of object that were invalidated.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   None.
   */  
  FUNCTION  Invalidate_Object(id IN NATURALN) RETURN NUMBER;
  PROCEDURE Invalidate_Object(id IN NATURALN);

  FUNCTION  Invalidate_Object(cache_id IN VARCHAR2) RETURN NUMBER;
  PROCEDURE Invalidate_Object(cache_id IN VARCHAR2);


  /**
   * NAME
   *   Bypass
   * DESCRIPTION
   *  Can be used to set the bypass mode for the Result Cache.
   *   o When bypass mode is turned on, it implies that cached results are
   *     no longer used and that no new results are saved in the cache.
   *   o When bypass mode is turned off, the cache resumes normal operation.
   * PARAMETERS
   *   bypass_mode - TRUE            => Result Cache usage is bypassed.
   *                 FALSE           => Result Cache usage is turned on.
   *   session     - TRUE            => Applies to current session.
   *                 FALSE (default) => Applies to all sessions.
   * RETURNS
   *  None.
   * EXCEPTIONS
   *  None.
   * NOTES
   *  This operation is database instance specific.
   *
   * USAGE SCENARIO(S):
   *
   *  (1) Hot Patching PL/SQL Code:
   *
   *   This operation can be used when there is a need to hot patch PL/SQL
   *   code in a running system. If a code-patch is applied to a PL/SQL module
   *   on which a result cached function directly or transitively depends,
   *   then the cached results  associated with the result cache function are
   *   not automatically flushed (if the instance is not restarted/bounced).
   *   This must be manually achieved.
   *   To ensure correctness during the patching process follow these steps:
   *
   *   a) Place the result cache in bypass mode, and flush existing results:
   *
   *         begin
   *           DBMS_RESULT_CACHE.Bypass(TRUE);
   *           DBMS_RESULT_CACHE.Flush;
   *         end;
   *         /
   *        This step must be performed on each instance (if in a RAC env).
   *   b) Apply the PL/SQL code patches.
   *   c) Resume use of the result cache, by turning off the cache bypass mode.
   *
   *        begin
   *          DBMS_RESULT_CACHE.Bypass(FALSE);
   *        end;
   *        /
   *      This step must be performed on each instance (if in a RAC env).
   *
   * (2) Other usage scenarios might be for debugging,
   *     diagnostic purposes.
   */
  PROCEDURE Bypass(bypass_mode IN BOOLEAN, 
                   session     IN BOOLEAN DEFAULT FALSE);

  /**
   * NAME
   *   Black_List
   * DESCRIPTION
   *   Bypass creating new results in the Result Cache with the specified cache_id.
   *     BL_Add:    Add cache_id to black-list
   *     BL_Remove: Remove cache_id from black-list
   *     BL_Clear:  Remove all cache_id's from black-list
   *     BL_Show:   List all contents of the black-list
   * PARAMETERS
   *   cache_id  - The cache_ids's to bypass
   *   global    - TRUE            => apply to all caches in the RAC cluster
   *               FALSE (default) => apply only the local instance cache
   * RETURNS
   *   None.
   * EXCEPTIONS
   *   None.
   * NOTES
   *   None.
   */
  PROCEDURE Black_List_Add   (cache_id IN VARCHAR2,
                              global   IN BOOLEAN DEFAULT FALSE);
  PROCEDURE Black_List_Remove(cache_id IN VARCHAR2,
                              global   IN BOOLEAN DEFAULT FALSE);
  PROCEDURE Black_List_Clear (global   IN BOOLEAN DEFAULT FALSE);

  type      bl_recT is record(cache_id varchar2(200));
  type      bl_tabT is table of bl_recT;
  type      bl_pvtT is table of varchar2(200);
  FUNCTION  Black_List return bl_tabT pipelined;

END DBMS_RESULT_CACHE;
/
show errors;

create or replace public synonym DBMS_RESULT_CACHE for SYS.DBMS_RESULT_CACHE;
grant execute on DBMS_RESULT_CACHE to DBA;


CREATE OR REPLACE PACKAGE DBMS_RESULT_CACHE_API as

  /**
   * NAME:
   *   Get
   * DESCRIPTION:
   *   Finds a given object in the cache or (optionally) creates one if one
   *   is not found.
   * PARAMETERS 
   *   name      - the key of the value to fetch
   *   value     - the value (or object) corresponding to the key
   *   isPublic  - 1(TRUE)          => result is public available all schemas 
   *               0(FALSE) DEFAULT => result is private to creator's schema
   *   noCreate  - 1(TRUE)          => does not create a new object
   *               0(FALSE) DEFAULT => creates a new object when one isn't found
   *   noFetch   - 1(TRUE)          => does not return the value 
   *               0(FALSE) DEFAULT => returns the value
   * RETURNS:
   *    0 => Failed to find/create.
   *    1 => Found the requested object.
   *    2 => Created an (empty) new object with the given key.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   None.
   */  
  FUNCTION Get(key      IN         VARCHAR2, 
               value    OUT NOCOPY RAW,
               isPublic IN         NUMBER DEFAULT 0,
               noCreate IN         NUMBER DEFAULT 0,
               noFetch  IN         NUMBER DEFAULT 0) RETURN NUMBER;
  pragma interface(C, Get);

  FUNCTION GetC(key      IN         VARCHAR2, 
                value    OUT NOCOPY VARCHAR2,
                isPublic IN         NUMBER DEFAULT 0,
                noCreate IN         NUMBER DEFAULT 0,
                noFetch  IN         NUMBER DEFAULT 0) RETURN NUMBER;
  pragma interface(C, GetC);

  /**
   * NAME:
   *   Set
   * DESCRIPTION:
   *   Stores the value with the key specified with the last
   *   call to Find (which had created an empty new object).
   * PARAMETERS 
   *   value   - the value (or object) to be stored
   *   discard - 1(TRUE)          => invalidates the key/value
   *             0(FALSE) DEFAULT => publishes the key/value
   * RETURNS:
   *   0      => Result was NOT published.
   *   Others => Result was published.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   None.
   */  
  FUNCTION Set(value   IN  RAW, 
               discard IN  NUMBER DEFAULT 0) RETURN NUMBER;
  pragma interface(C, Set);

  FUNCTION SetC(value   IN  VARCHAR2, 
                discard IN  NUMBER DEFAULT 0) RETURN NUMBER;
  pragma interface(C, SetC);

                   

END DBMS_RESULT_CACHE_API;
/
show errors;

create or replace public synonym DBMS_RESULT_CACHE_API for SYS.DBMS_RESULT_CACHE_API;
grant execute on DBMS_RESULT_CACHE_API to PUBLIC;


@?/rdbms/admin/sqlsessend.sql
