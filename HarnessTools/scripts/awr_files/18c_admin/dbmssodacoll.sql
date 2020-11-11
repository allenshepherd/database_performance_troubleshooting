Rem
Rem $Header: rdbms/admin/dbmssodacoll.sql /st_rdbms_18.0/1 2018/04/11 10:34:37 sriksure Exp $
Rem
Rem dbmssodacoll.sql
Rem
Rem Copyright (c) 2014, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmssodacoll.sql - DBMS SODA COLLections package specification
Rem
Rem    DESCRIPTION
Rem      Interface to the DBMS_SODA_ADMIN package
Rem
Rem    NOTES
Rem      This package should be used to manage collection metadata.
Rem      Direct access to the metadata table should not be done.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmssodacoll.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmssodacoll.sql
Rem    SQL_PHASE: DBMSSODACOLL
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catsodacoll.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sriksure    04/02/18 - Bug 27698424: Backport SODA bugs from main
Rem    prthiaga    08/02/16 - Bug 24350036: Add DROP_DANGLING_COLLECTIONS and
Rem                           DELETE_COLLECTION_METADATA
Rem    morgiyan    05/11/16 - Bug 23151039: Add drop_collections
Rem    prthiaga    02/10/15 - Bug 22675745: Add SQL_RESOURCE_BUSY
Rem    prthiaga    06/02/15 - Bug 21188761: Add P_VERBOSE to CREATE_COLLECTION
Rem    prthiaga    05/20/15 - Bug 21116398 :Move SODA_APP creation to 
Rem                           catsodaddl.sql
Rem    prthiaga    05/19/15 - Bug 21116398: Add GET_SCN 
Rem    prthiaga    03/17/15 - Bug 20703629: Add SODA_APP
Rem    prthiaga    07/29/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package XDB.DBMS_SODA_ADMIN authid current_user as

  --
  -- Error messages which we can ignore 
  --
  SQL_OBJECT_EXISTS         constant number := -955;
  SQL_OBJECT_NOT_EXISTS     constant number := -942;
  SQL_INDEX_OUT_OF_BOUNDS   constant number := -6513;

  -- ORA-00054: resource busy and acquire with
  -- NOWAIT specified or timeout expired exception
  SQL_RESOURCE_BUSY         constant number := -54;

  --
  type VCTAB is table of varchar2(32767) index by binary_integer;
  type NVCTAB is table of nvarchar2(32767) index by binary_integer;

  type VCNTAB is table of varchar2(32767);
  type NVCNTAB is table of nvarchar2(32767);
  type NUMNTAB is table of number;

  --
  -- List collections by returning a cursor which delivers two
  -- columns: the URI name and a JSON descriptor. The results
  -- are returning in URI string order.
  -- An optional argument can be used to specify a starting URI string
  -- (possibly useful for paginated reading of large schemas).
  --
  procedure LIST_COLLECTIONS(P_START_NAME in  varchar2 default null,
                             P_RESULTS    out SYS_REFCURSOR);
  --
  -- Describe a single collection. The input collection name is
  -- case-sensitive. If a match is found, the case-sensitive actual
  -- URI name is returned along with the descriptor body.
  --
  procedure DESCRIBE_COLLECTION(P_URI_NAME   in out nvarchar2,
                                P_DESCRIPTOR    out varchar2);
  --
  -- Create a collection for a specified URI name, with a specified
  -- descriptor. The URI name is case-sensitive.
  -- Note that the descriptor stored in the table may differ from
  -- from the input descriptor if values are defaulted during validation.
  --
  procedure CREATE_COLLECTION(P_URI_NAME    in     nvarchar2,
                              P_CREATE_MODE in     varchar2 default 'MAP',
                              P_DESCRIPTOR  in out varchar2,
                              P_CREATE_TIME out    varchar2,
                              P_VERBOSE     in     boolean  default false);
  --
  -- Drop a collection given the name. This forcibly drops the
  -- the collection regardless of the drop policy, which must
  -- be enforced by the calling code layer.
  --
  procedure DROP_COLLECTION(P_URI_NAME in nvarchar2);
  --
  -- Drops all collections in the current user's schema.
  --
  -- P_COLLECTIONS and P_ERRORS out parameters contain
  -- an array of names of the collections that could not be
  -- dropped, and an array of errors encountered when dropping
  -- these collections (P_ERRORS), respectively.
  -- These two arrays are always of the same size and correlated 
  -- by the index value. For example, if returned P_COLLECTIONS 
  -- and P_ERRORS are both of size 2, then 2 collections could not 
  -- be dropped. In this case, P_COLLECTIONS(0) and P_ERRORS(0) will 
  -- contain the name of one of these two collections that could
  -- not be dropped, and the associated error, respectively. 
  -- Similarly, P_COLLECTIONS(1) and P_ERRORS(1) will return 
  -- the name of another collection that could not be dropped, 
  -- and the associated error. If the arrays are of size 0, then
  -- all collections were dropped successfully.
  --
  -- P_FORCE parameter, if set to true, will
  -- result in collection metadata table being cleared of
  -- all collections in the user schema, even if collections
  -- could not to be dropped due to errors encountered 
  -- when attempting to drop their underlying tables/views/packages.
  --
  procedure DROP_COLLECTIONS(P_COLLECTIONS out NVCNTAB,
                             P_ERRORS out VCNTAB,
                             P_FORCE in varchar2);
  --
  -- Returns RDBMS parameters as name/value pairs.
  -- Currently returns 3 values:
  --       PKEY             P_VALUE
  --   (1) "VARCHAR2_MAX"   4000 or 32767
  --   (2) "RAW_MAX"        2000 or 32767
  --   (3) "NVARCHAR2_MAX"  2000, 4000, 16383, or 32767
  --
  procedure GET_PARAMETERS (P_KEY   in out VCTAB, 
                            P_VALUE in out VCTAB);
  --
  -- Returns the database SCN value 
  --
  procedure GET_SCN(P_SCN out NUMBER);

  --
  -- Deletes metadata for collections that no longer have tables 
  -- or views backing them up belonging to the schema it 
  -- was called from.
  --
  procedure DROP_DANGLING_COLLECTIONS;
  --
  -- Deletes all entries in XDB.JSON$COLLECTION_METADATA 
  -- belonging to the schema it was called from.
  --
  procedure DELETE_COLLECTION_METADATA (P_KEY in VARCHAR2);

  procedure GET_SQL_TEXT(P_SQLTEXT out varchar2);

  --
  -- Create an index based on an index specification, for a
  -- collection with the supplied URI name.
  --
  procedure CREATE_INDEX(P_URI_NAME    in  nvarchar2,
                         P_INDEX_SPEC  in  varchar2,
                         P_VERBOSE     in  boolean  default false);

end DBMS_SODA_ADMIN;
/

grant execute on XDB.DBMS_SODA_ADMIN to SODA_APP;
/

create public synonym DBMS_SODA_ADMIN for XDB.DBMS_SODA_ADMIN
/

@?/rdbms/admin/sqlsessend.sql
