Rem $Header: rdbms/admin/dbmstf.sql /main/19 2017/11/06 18:18:42 achaudhr Exp $
Rem
Rem dbmstf.sql
Rem
Rem    NAME
Rem      dbmstf.sql - Table Function Utility Package
Rem
Rem    DESCRIPTION
Rem      This is a PL/SQL package for polymorphic table functions to consume
Rem      and produce data, and get information about its execution environment.
Rem
Rem    NOTES
Rem      The package is expected to be called from inside the implementation 
Rem      of a PTF.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    achaudhr    11/01/17 - Add tracing function Row_To_Char
Rem    sagrawal    10/24/17 - change get_env doc
Rem    achaudhr    10/11/17 - make Column_Type_Name() public
Rem    sagrawal    09/22/17 - add more type codes
Rem    sagrawal    08/23/17 - bug 26534163:Add Natural Doc
Rem    sagrawal    06/15/17 - bug 26046555 - show ptf name
Rem    sagrawal    06/23/17 - row id support
Rem    sagrawal    06/09/17 - bug 25588903:add default column length
Rem    sagrawal    04/28/17 - fix columns_metadata attributes
Rem    sagrawal    04/24/17 - add more tracing
Rem    achaudhr    04/18/17 - describe_t => default null
Rem    sagrawal    03/01/17 - Modify Describe_t to add CStore collections
Rem    achaudhr    02/27/17 - add DESCRIBE_T
Rem    sagrawal    02/15/17 - Change Xtore to ICD
Rem    achaudhr    01/23/17 - Add XStore API
Rem    sagrawal    01/20/17 - Remove Get_Execution_Id
Rem    achaudhr    03/24/16 - 2918931: disable trace_file parameter
Rem    sagrawal    01/19/16 - bug 22559697:remove unsupported API's
Rem    sagrawal    06/29/15 - fix typecodes
Rem    achaudhr    05/21/15 - add metadata support
Rem    sagrawal    03/23/15 - Add collections to represent columns
Rem    sagrawal    01/27/15 - add put_col and get_col ICDs
Rem    sagrawal    01/27/15 - add put_col and get_col ICDs
Rem    sagrawal    01/08/15 - change the name
Rem    sagrawal    01/23/14 - Polymorphic Table Functions: helper package
Rem    sagrawal    01/23/14 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmstf.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmstf.sql 
Rem    SQL_PHASE: DBMSTF
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem    END SQL_FILE_METADATA

@@?/rdbms/admin/sqlsessstart.sql  
  
CREATE OR REPLACE PACKAGE DBMS_TF AS
  
   /*
    Package: DBMS_TF

     DBMS_TF is the PL/SQL package that provides various utility API's to
     support POLYMORPHIC TABLE functions(ptf).

   */
     
  /* Type Codes for supported types */
  TYPE_VARCHAR2            CONSTANT PLS_INTEGER :=   1;
  TYPE_NUMBER              CONSTANT PLS_INTEGER :=   2;
  TYPE_DATE                CONSTANT PLS_INTEGER :=  12;
  TYPE_RAW                 CONSTANT PLS_INTEGER :=  23;
  TYPE_ROWID               CONSTANT PLS_INTEGER :=  69;
  TYPE_CHAR                CONSTANT PLS_INTEGER :=  96;
  TYPE_BINARY_FLOAT        CONSTANT PLS_INTEGER := 100;
  TYPE_BINARY_DOUBLE       CONSTANT PLS_INTEGER := 101;
  TYPE_CLOB                CONSTANT PLS_INTEGER := 112;
  TYPE_BLOB                CONSTANT PLS_INTEGER := 113;
  TYPE_TIMESTAMP           CONSTANT PLS_INTEGER := 180;
  TYPE_TIMESTAMP_TZ        CONSTANT PLS_INTEGER := 181;
  TYPE_INTERVAL_YM         CONSTANT PLS_INTEGER := 182;
  TYPE_INTERVAL_DS         CONSTANT PLS_INTEGER := 183;
  TYPE_EDATE               CONSTANT PLS_INTEGER := 184;
  TYPE_ETIMESTAMP_TZ       CONSTANT PLS_INTEGER := 186;
  TYPE_ETIMESTAMP          CONSTANT PLS_INTEGER := 187;
  TYPE_EINTERVAL_YM        CONSTANT PLS_INTEGER := 189;
  TYPE_EINTERVAL_DS        CONSTANT PLS_INTEGER := 190;
  TYPE_TIMESTAMP_LTZ       CONSTANT PLS_INTEGER := 231;
  TYPE_ETIMESTAMP_LTZ      CONSTANT PLS_INTEGER := 232;

  /*----------------------------------------------------------------------
    Type: COLUMN_METADATA_T
  
    This type contains meta data about an existing table column or a new 
    column produced by PTF. 
  
    type:        Internal Oracle typecode for the column's type           
    max_len:     Maximum length of a column, If it is less than
                 maximum allowed length then that value will be 
                 used, if it is NULL or zero, zero will be used.
                 If it is less than zero, then maximum allowed length
                 will be used. If types(like date,float), does not care 
                 about length, then this value will be ignored.
    name:        Name of the column           
    name_len:    Length of the name     
  
    precision:   Numerical precision (applies to Numerical data)        
    scale:       Scale (applies to Numerical data)             
  
    charsetid:   Character set id (internal Oracle code, appies to
                                   string types)       
    charsetform: Character set form (internal Oracle code, appies to
                                     string types)    
    collation:  Collation id (internal Oracle code, appies to
                              string types)        
  
    schema_name:      Not used   
    schema_name_len:  Not used 
    type_name:        Not used        
    type_name_len:    Not used   
    
    */ 
    
  TYPE COLUMN_METADATA_T IS RECORD 
  (
    type               PLS_INTEGER DEFAULT TYPE_VARCHAR2,
    max_len            PLS_integer DEFAULT -1,
    name               VARCHAR2(32767),
    name_len           PLS_INTEGER,
    /* following two attributes are used for numerical data */
    precision          PLS_INTEGER,
    scale              PLS_INTEGER,
    /* following three attributes are used for character data */
    charsetid          PLS_INTEGER,
    charsetform        PLS_INTEGER,
    collation          PLS_INTEGER,
    /* following attributes may be used in future */
    schema_name        DBMS_QUOTED_ID,
    schema_name_len    PLS_INTEGER,
    type_name          DBMS_QUOTED_ID,
    type_name_len      PLS_INTEGER
  );   
     
     
    /*----------------------------------------------------------------------
    Type: COLUMN_T
    A wrapper record for the type COLUMN_METADATA_T that contains PTF specific
    attributes.

    description:           Column metadata
    pass_through:          Is the a pass thruough column
    for_read:              Is this column read by PTF
    
    */ 

  TYPE COLUMN_T          IS RECORD 
  (
    description            COLUMN_METADATA_T, /* Column metadata */
    pass_through           BOOLEAN,      /* Pass-through column? */
    for_read               BOOLEAN  /* Column data will be read? */
  );
  
  /*----------------------------------------------------------------------
    Type: TABLE_COLUMNS_T
    A collection of columns(COLUMN_T)

    */ 
  TYPE TABLE_COLUMNS_T IS TABLE OF COLUMN_T;
  
   /*----------------------------------------------------------------------
    Type: TABLE_T
    A Table descriptor. A descriptor type for table or ptf.
   
    column:       Column information 
    schema_name:  Schema name OF ptf
    package_name: Package name OF ptf
    ptf_name:     ptf name invoked

   */ 
  TYPE TABLE_T          IS RECORD
  (
    column                TABLE_COLUMNS_T,     /* Column information */
    schema_name           dbms_quoted_id,  /* the schema name OF ptf */
    package_name          dbms_quoted_id, /* the package name OF ptf */
    ptf_name              dbms_quoted_id     /* the ptf name invoked */
  );

  
  /* Collection containing columns metadata */
  TYPE COLUMNS_WITH_TYPE_T IS TABLE OF COLUMN_METADATA_T;
  
  /* Collection containing column names */
  TYPE COLUMNS_T IS TABLE OF DBMS_QUOTED_ID;
  
  /* Collection for new columns */
  TYPE COLUMNS_NEW_T IS TABLE OF COLUMN_METADATA_T INDEX BY PLS_INTEGER;
  
  /* CStore: Collections TYPE FOR compilation storage */
  TYPE CSTORE_CHR_T IS TABLE OF VARCHAR2(32767)  INDEX BY VARCHAR2(32767);
  TYPE CSTORE_NUM_T IS TABLE OF NUMBER           INDEX BY VARCHAR2(32767);
  TYPE CSTORE_BOL_T IS TABLE OF BOOLEAN          INDEX BY VARCHAR2(32767);
  TYPE CSTORE_DAT_T IS TABLE OF DATE             INDEX BY VARCHAR2(32767);
  
  /* Collection OF user defined method names */
  TYPE METHODS_T IS TABLE OF DBMS_QUOTED_ID INDEX BY DBMS_ID;
  
  /* pre-defined INDEX VALUES FOR method names */
  OPEN CONSTANT dbms_quoted_id := 'OPEN';
  FETCH_ROWS CONSTANT dbms_quoted_id := 'FETCH_ROWS';
  CLOSE  CONSTANT dbms_quoted_id := 'CLOSE';
  
  
   /*----------------------------------------------------------------------
    Type: DESCRIBE_T
    Return type from the Describe method of PTF
   
    NEW_COLUMNS:    new columns description that will be produced by ptf

    CSTORE_CHR:    CStore array key/char
    CSTORE_NUM:    CStore array key/number
    CSTORE_BOL:    CStore array key/boolean
    CSTORE_DAT:    CStore array key/date 
  
    METHOD_NAMES: Method names, if user wants to override open/fetch_rows,close 
                  methods

   */ 
  TYPE DESCRIBE_T          IS RECORD 
  (
    NEW_COLUMNS      COLUMNS_NEW_T default COLUMNS_NEW_T(),    /* new columns */

    --
    -- CStore
    --
    CSTORE_CHR       CSTORE_CHR_T  default CSTORE_CHR_T(), /* CStore: key/char */
    CSTORE_NUM       CSTORE_NUM_T  default CSTORE_NUM_T(), /* CStore: key/numb */
    CSTORE_BOL       CSTORE_BOL_T  default CSTORE_BOL_T(), /* CStore: key/bool */
    CSTORE_DAT       CSTORE_DAT_T  default CSTORE_DAT_T(), /* CStore: key/date */

    -- Open/Fetch/Close method overrides
    METHOD_NAMES     METHODS_T     default METHODS_T(),

    /* following attributes may be used in future */

    -- Row Replication Enabled?
    ROW_REPLICATION  BOOLEAN       default FALSE,

    -- Row Insertion Enabled?
    ROW_INSERTION    BOOLEAN       default FALSE
  );
   
  /* Collections for each supported types */
  TYPE TAB_VARCHAR2_T      IS TABLE OF VARCHAR2(32767)             INDEX BY PLS_INTEGER;
  TYPE TAB_NUMBER_T        IS TABLE OF NUMBER                      INDEX BY PLS_INTEGER;
  TYPE TAB_DATE_T          IS TABLE OF DATE                        INDEX BY PLS_INTEGER;
  TYPE TAB_BINARY_FLOAT_T  IS TABLE OF BINARY_FLOAT                INDEX BY PLS_INTEGER;
  TYPE TAB_BINARY_DOUBLE_T IS TABLE OF BINARY_DOUBLE               INDEX BY PLS_INTEGER;
  TYPE TAB_RAW_T           IS TABLE OF RAW(32767)                  INDEX BY PLS_INTEGER;
  TYPE TAB_CHAR_T          IS TABLE OF CHAR(32767)                 INDEX BY PLS_INTEGER;
  TYPE TAB_CLOB_T          IS TABLE OF CLOB                        INDEX BY PLS_INTEGER;
  TYPE TAB_BLOB_T          IS TABLE OF BLOB                        INDEX BY PLS_INTEGER;
  TYPE TAB_TIMESTAMP_T     IS TABLE OF TIMESTAMP_UNCONSTRAINED     INDEX BY PLS_INTEGER;
  TYPE TAB_TIMESTAMP_TZ_T  IS TABLE OF TIMESTAMP_TZ_UNCONSTRAINED  INDEX BY PLS_INTEGER;
  TYPE TAB_INTERVAL_YM_T   IS TABLE OF YMINTERVAL_UNCONSTRAINED    INDEX BY PLS_INTEGER;
  TYPE TAB_INTERVAL_DS_T   IS TABLE OF DSINTERVAL_UNCONSTRAINED    INDEX BY PLS_INTEGER;
  TYPE TAB_TIMESTAMP_LTZ_T IS TABLE OF TIMESTAMP_LTZ_UNCONSTRAINED INDEX BY PLS_INTEGER;
  TYPE TAB_BOOLEAN_T       IS TABLE OF BOOLEAN                     INDEX BY PLS_INTEGER;  
  TYPE TAB_ROWID_T         IS TABLE OF ROWID                       INDEX BY PLS_INTEGER;  
  TYPE TAB_NATURALN_T       IS TABLE OF NATURALN                   INDEX BY PLS_INTEGER;  

  /* Data for a single column (tagged-union/variant-record) */
  TYPE COLUMN_DATA_T IS RECORD
  (
    /* ::TAG:: */
    description               COLUMN_METADATA_T, 
    
    /* ::VARIANT FIELDS:: Exactly one is active */
    tab_varchar2           TAB_VARCHAR2_T,
    tab_number             TAB_NUMBER_T,
    tab_date               TAB_DATE_T,
    tab_binary_float       TAB_BINARY_FLOAT_T,
    tab_binary_double      TAB_BINARY_DOUBLE_T,
    tab_raw                TAB_RAW_T,
    tab_char               TAB_CHAR_T,
    tab_clob               TAB_CLOB_T,
    tab_blob               TAB_BLOB_T,
    tab_timestamp          TAB_TIMESTAMP_T,
    tab_timestamp_tz       TAB_TIMESTAMP_TZ_T,
    tab_interval_ym        TAB_INTERVAL_YM_T,
    tab_interval_ds        TAB_INTERVAL_DS_T,
    tab_timestamp_ltz      TAB_TIMESTAMP_LTZ_T,
    tab_rowid              TAB_ROWID_T
  );

  /* Data for a rowset */
  TYPE ROW_SET_T IS TABLE OF COLUMN_DATA_T INDEX BY PLS_INTEGER;


   /*----------------------------------------------------------------------
    Procedure: Get_Col

      Get Read Column Values

    Parameters:
      ColumnId   - The id for the column (1 .. N)
      Collection - The data for the column

    Exceptions:
    - <Wrong collection type>
 
    Notes:
    - This procedure is used to "get" the read column values in the 
      collection of scalar type.
  
    - The collection of scalar type should be of supported type only
  
    - The column numbers are in the get column order as created in 
      Describe method of PTF. 
  
    - For the same ColumnId, Get_Col and Put_Col may correspond to different
      column.

    Examples:
    |  procedure Fetch_Rows is
    |   
    |  col1 DBMS_TF.TAB_CLOB_T;
    |  col2 DBMS_TF.TAB_CLOB_T;
    |  out1 DBMS_TF.TAB_CLOB_T;
    |  out2 DBMS_TF.TAB_CLOB_T;
    |   begin
    |    DBMS_TF.Get_Col(1, col1);
    |    DBMS_TF.Get_Col(2, col2);
    |
    |    for i in 1 .. col1.Count loop
    |      out1(i) := 'ECHO-' || col1(i);
    |    end loop;
    |    for i in 1 .. col2.Count loop
    |      out2(i) := 'ECHO-' || col2(i);
    |    end loop;
    |
    |    DBMS_TF.Put_Col(1, out1);
    |    DBMS_TF.Put_Col(2, out2);
    |
    |  end;
  
  */
  PROCEDURE Get_Col(ColumnId NUMBER,     Collection IN OUT NOCOPY "<V2_TABLE_1>");
            pragma interface(c, Get_Col); 
  
   /*----------------------------------------------------------------------
    Procedure: Put_Col

      Put Column Values

    Parameters:
      ColumnId   - The id for the column (1 .. N)
      Collection - The data for the column

    Exceptions:
    - <Wrong collection type>
 
    Notes:
    - This procedure is used to "put" the  column values in the 
      collection of scalar type to RDBMS.
  
    - The collection of scalar type should be of supported type only
  
    - The column numbers are in the get column order as created in 
      Describe method of PTF. 
  
    - For the same ColumnId, Get_Col and Put_Col may correspond to different
      column.

    Examples:
    |  procedure Fetch_Rows is
    |   
    |  col1 DBMS_TF.TAB_CLOB_T;
    |  col2 DBMS_TF.TAB_CLOB_T;
    |  out1 DBMS_TF.TAB_CLOB_T;
    |  out2 DBMS_TF.TAB_CLOB_T;
    |   begin
    |    DBMS_TF.Get_Col(1, col1);
    |    DBMS_TF.Get_Col(2, col2);
    |
    |    for i in 1 .. col1.Count loop
    |      out1(i) := 'ECHO-' || col1(i);
    |    end loop;
    |    for i in 1 .. col2.Count loop
    |      out2(i) := 'ECHO-' || col2(i);
    |    end loop;
    |
    |    DBMS_TF.Put_Col(1, out1);
    |    DBMS_TF.Put_Col(2, out2);
    |
    |  end;
  
  */
  PROCEDURE Put_Col(ColumnId NUMBER,     Collection IN             "<V2_TABLE_1>");
            pragma interface(c, Put_Col); 
  
   /*----------------------------------------------------------------------
    Procedure: Get_Row_set

      Get Read Column Values

    Parameters:
     rowset    - The collection of data and meta data
     row_count - The number of rows in the columns
     col_count - The number of columns
  
    Exceptions:
    - None
 
    Notes:
    - This procedure is used to "get" the read set of column values in the 
      collection of scalar type.
  
    - The collection of scalar type are  of supported type only
  
 
    Examples:
     | procedure FETCH_ROWS(new_name IN varchar2 default 'PTF_CONCATENATE')
     |  as
     |   rowset      DBMS_TF.row_set_t;
     |   accumulator DBMS_TF.tab_VARCHAR2_t;
     |   row_count pls_integer;
     |
     |  function    Get_Value(col pls_integer, row pls_integer) return varchar2
     | as
     |  col_type  pls_integer := rowset(col).description.type;
     | begin
     |  case col_type
     |    when DBMS_TF.TYPE_VARCHAR2       then
     |        return nvl(rowset(col).tab_varchar2 (row), 'empty');
     |     else
     |       raise_application_error(-20201,'Non-Varchar Type='||col_type);
     |   end case;
     |  end;
     |  begin
     |     DBMS_TF.Get_Row_Set(rowset,row_count);
     |     if (rowset.count = 0) then return; end if;
     |    for row_num in 1 .. row_count loop accumulator(row_num) := 'empty'; end
     |     loop;
     |   for col_num in 1 .. rowset.count loop
     |      for row_num in 1 .. row_count loop
     |         accumulator(row_num) := accumulator(row_num) || Get_Value(col_num,
     |           row_num);
     |       end loop;
     |   end loop;
     |
     |
     |     -- Pushout the accumulator
     |    DBMS_TF.Put_Col(1, accumulator);
     |  end;

    
  */
  PROCEDURE Get_Row_Set(rowset    OUT NOCOPY ROW_SET_T, 
                        row_count OUT PLS_INTEGER);

  PROCEDURE Get_Row_Set(rowset    OUT NOCOPY ROW_SET_T, 
                        row_count OUT PLS_INTEGER, 
                        col_count OUT PLS_INTEGER);
  
   /*----------------------------------------------------------------------
    Procedure: Get_Row_set

      Get Read Column Values

    Parameters:
     rowset    - The collection of data and meta data

    Exceptions:
    - None
 
    Notes:
    - This procedure is used to "get" the read set of column values in the 
      collection of scalar type.
  
    - The collection of scalar type are  of supported type only
  
 
    Examples:
     | procedure Fetch_Rows
     | as
     |  rowset DBMS_TF.row_set_t;
     |  begin
     |    DBMS_TF.Get_Row_Set(rowset);
     |    DBMS_TF.Put_Row_Set(rowset);
     |  end;

  
  */
   PROCEDURE Get_Row_Set(rowset    OUT NOCOPY ROW_SET_T);
    
    /*----------------------------------------------------------------------
    Procedure: Put_Row_set

      Put the  Column Values in RDBMS

    Parameters:
     rowset             - The collection of data and meta data
     replication_factor - The replication factor per row

    Exceptions:
    - None
 
    Notes:
    - This procedure is used to "put" the read set of column values in  
      RDBMS.
  
    - The collection of scalar type are  of supported type only
  
 
    Examples:
     | procedure Fetch_Rows
     | as
     |  rowset DBMS_TF.row_set_t;
     |  begin
     |    DBMS_TF.Get_Row_Set(rowset);
     |    DBMS_TF.Put_Row_Set(rowset);
     |  end;

  
  */
  PROCEDURE Put_Row_Set(rowset             IN   ROW_SET_T); 

  PROCEDURE Put_Row_Set(rowset             IN   ROW_SET_T,
                        replication_factor IN   NATURALN);

  PROCEDURE Put_Row_Set(rowset             IN   ROW_SET_T,
                        replication_factor IN   TAB_NATURALN_T);

    /*----------------------------------------------------------------------
    Procedure: Row_Replication

      Set the Row Replication Factor

    Parameters:
     replication_factor - The replication factor per row

    Exceptions:
    - None
 
    Notes:
    - This procedure is used to set the row replication factor.
 
    Examples:
     | procedure Fetch_Rows
     | as
     |  rowset DBMS_TF.row_set_t;
     |  begin
     |    DBMS_TF.Row_Replication(replication_factor => 2);
     |  end;

  
  */
  PROCEDURE Row_Replication(replication_factor IN NATURALN);

  PROCEDURE Row_Replication(replication_factor IN TAB_NATURALN_T);

  /*----------------------------------------------------------------------
    FUNCTION Supported_Type

      tests if a specified type is supported by PTF infrastructure

    Parameters:
     type_id    - The type

    Exceptions:
    - None
 
    Return:
      TRUE iff the type_id is supported for obtaining or producing 
  
    Notes:
    - This procedure is used to "put" the read set of column values in  
      RDBMS.
  
    - The collection of scalar type are  of supported type only
      columns inside a PTF.
 
    Examples:
     | function Describe(tab   IN OUT DBMS_TF.table_t,
     |               cols  IN     DBMS_TF.columns_t)
     |      return DBMS_TF.describe_t
     | as
     |   new_cols DBMS_TF.columns_new_t;
     |   col_id   pls_integer := 1;
     |  begin
     |   for i in 1 .. tab.Count loop
     |     for j in 1 .. cols.Count loop
     |       if (tab(i).description.name = cols(j)) then
     |         if (not DBMS_TF.Supported_Type(tab(i).description.type)) then
     |           raise_application_error(-20102,
     |           'Unspported column type ['||tab(i).description.type||']');
     |         end if;
     |
     |         tab(i).for_read       := TRUE;
     |         new_cols(col_id)      := tab(i).description;
     |         new_cols(col_id).name := 'ECHO_'|| tab(i).description.name;
     |         col_id                := col_id + 1;
     |
     |         exit;
     |       end if;
     |     end loop;
     |   end loop;
     |
     |  --  Verify all columns were found 
     |  if (col_id - 1 != cols.Count) then
     |    raise_application_error(-20101,
     |     'Column mismatch ['||col_id-1||'], ['||cols.Count||']');
     |  end if;
     |
     |  return DBMS_TF.describe_t(new_columns => new_cols);
     | end;

  
  */
  FUNCTION Supported_Type(type_id PLS_INTEGER) 
           RETURN BOOLEAN;

  /*----------------------------------------------------------------------
    FUNCTION Column_Type_Name

      Coverts the column type information into a text string

    Parameters:
     col    - The column metadata

    Exceptions:
    - None
 
    Return:
      the type information as text
  
    Notes:
    - None
 
    Examples:
     | function Describe(tab   IN OUT DBMS_TF.table_t,
     |               cols  IN     DBMS_TF.columns_t)
     |      return DBMS_TF.describe_t
     | as
     |   new_cols DBMS_TF.columns_new_t;
     |   col_id   pls_integer := 1;
     |  begin
     |   for i in 1 .. tab.Count loop
     |     for j in 1 .. cols.Count loop
     |       if (tab(i).description.name = cols(j)) then
     |         if (DBMS_TF.Column_Type_Name(tab(i).description.type) != 
     |             'VARCHAR2') then
     |           raise_application_error(-20102,
     |           'Unspported column type ['||tab(i).description.type||']');
     |         end if;
     |
     |         tab(i).for_read       := TRUE;
     |         new_cols(col_id)      := tab(i).description;
     |         new_cols(col_id).name := 'ECHO_'|| tab(i).description.name;
     |         col_id                := col_id + 1;
     |
     |         exit;
     |       end if;
     |     end loop;
     |   end loop;
     |
     |  --  Verify all columns were found 
     |  if (col_id - 1 != cols.Count) then
     |    raise_application_error(-20101,
     |     'Column mismatch ['||col_id-1||'], ['||cols.Count||']');
     |  end if;
     |
     |  return DBMS_TF.describe_t(new_columns => new_cols);
     | end;

  
  */
  FUNCTION COLUMN_TYPE_NAME(col COLUMN_METADATA_T)
           RETURN VARCHAR2;

  
  SUBTYPE XID_T IS VARCHAR2(1024);
     
   /*----------------------------------------------------------------------
    FUNCTION Get_Xid
     Returns a unique execution id that can be used by the PTF to index 
     any cursor-execution specific runtime state.
      

    Parameters:
    - None
   
    Exceptions:
    - None
 
    Return:
     A unique execution id that can be used by the PTF to index 
     any cursor-execution specific runtime state.
  
    Notes:

 
    Examples:
     | procedure OPEN  is 
     |  begin 
     |   xst(DBMS_TF.Get_XID()) := 0;   
     |  end;
  */
  FUNCTION Get_Xid
           RETURN XID_T;
  
  
  /*----------------------------------------------------------------------
    Type: PARALLEL_ENV_T
  
    This record contains metadata about parallel execution  for
    polymorphic table functions. When PTF was exuted in serial SQL,
    the attributes will have predetermined default values.
    
    instance_id:      Query co-ordinator instance ID
    session_id:       Query co-ordinator  session ID
    slave_svr_grp:    Slave server group
    slave_set_no:     Slave server set number
    no_slocal_slaves: Number of sibling slaves (including self)
    global_slave_no:  Global slave number (starting with  0) 
    no_local_slaves:  Number of sibling slaves running on  instance
    local_slave_no:   Local slave number (starting with 0)
    
    */ 
  TYPE PARALLEL_ENV_T         IS RECORD
  (
    instance_id      PLS_INTEGER,                      /* QC instance ID */
    session_id       PLS_INTEGER,                       /* QC session ID */
    slave_svr_grp    PLS_INTEGER,                  /* Slave server group */
    slave_set_no     PLS_INTEGER,                /* Slave server set num */
    no_slocal_slaves PLS_INTEGER,   /* Num of sibling slaves
                                                        (including self) */
    global_slave_no  PLS_INTEGER,        /* Global slave number (base 0) */
    no_local_slaves  PLS_INTEGER,/* Num of sibling slaves running on 
                                                                instance */
    local_slave_no   PLS_INTEGER          /* Local slave number (base 0) */
  );

  TYPE TABLE_METADATA_T IS TABLE OF COLUMN_METADATA_T INDEX BY PLS_INTEGER;

  TYPE REFERENCED_COLS_T IS TABLE OF BOOLEAN           INDEX BY PLS_INTEGER;
  
   /*----------------------------------------------------------------------
    Type: ENV_T
  
    This record contains metadata about execution time properties for
    polymorphic table functions.
  
    get_columns:  meta data about the columns read by PTF.
    put_columns:  meta data about columns sent back to RDBMS.
    ref_put_col:  TRUE if the put column was referenced in the query.
    parallel_env: Various properties about Parallel query when query is
                  running in parallel.
    query_optim:  TRUE, if the query was running on behalf of optimizer.
    row_count:    Number of rows in current set.
    
    */ 
  TYPE ENV_T            IS RECORD
  (
    get_columns  TABLE_METADATA_T,         /* Metadata for the Get_Col() */
    put_columns  TABLE_METADATA_T,         /* Metadata for the Put_Col() */
    ref_put_col  REFERENCED_COLS_T,  /* TRUE => put-column is referenced */
    parallel_env PARALLEL_ENV_T,       /* Parallel Execution information */
    query_optim  BOOLEAN,   /* Is this execution for query optimization? */
    row_count    PLS_INTEGER,       /* Number of rows in current row-set */
    row_replication  BOOLEAN,                /* Row Replication Enabled? */
    row_insertion    BOOLEAN                   /* Row Insertion Enabled? */ 
  );

  
  /*----------------------------------------------------------------------
    FUNCTION Get_Env
     Returns a record containing information that may be needed during
     execution of a Polymorphic Table Function.
      

    Parameters:
    - None
   
    Exceptions:
    - None
 
    Return:
     Returns a record of type ENV_T containing information that may be needed during
     execution of a Polymorphic Table Function.
  
    Notes:

 
    Examples:
     |  procedure FETCH_ROWS is
     |    ROW_CNT constant pls_integer   := DBMS_TF.Get_Env().Row_Count;
     |    XID     constant DBMS_TF.xid_t := DBMS_TF.Get_XID();
     |    rid     pls_integer            := xst(XID);
     |    col     DBMS_TF.tab_number_t;
     |  begin
     |    for i in 1 .. ROW_CNT loop col(i) := rid + i; end loop;
     |      DBMS_TF.Put_Col(1, col);
     |      xst(XID) := rid + ROW_CNT;
     |    end;
     | end;

  */
  FUNCTION Get_Env 
           RETURN ENV_T;

  /*----------------------------------------------------------------------
    FUNCTION Col_To_Char
     
     This function converts a column data value to a string representation.

    Parameters:
     col   - The column whose value is to be converted
     rid   - Row number
     quote - Quotation mark to use for non-numeric values
   
    Exceptions:
    - None
 
    Return:
    - None
  
    Notes:
    - None
 
    Examples:
     | procedure Fetch_Rows as 
     |  rowset DBMS_TF.row_set_t;
     |  str    varchar2(32000);
     | begin
     |   DBMS_TF.Get_Row_Set(rowset);
     |   str := DBMS_TF.Col_to_Char(rowset(1), 1)
     | end;

  */
  FUNCTION Col_To_Char(col   Column_Data_t, 
                       rid   PLS_INTEGER, 
                       quote VARCHAR2 DEFAULT '"') 
           return VARCHAR2;

  /*----------------------------------------------------------------------
    FUNCTION Row_To_Char
     
     This function converts a row data value to a string representation.

    Parameters:
     rowset - The rowset whose value is to be converted
     rid    - Row number
     format - The string format (default is FORMAT_JSON)
   
    Exceptions:
    - None
 
    Return:
    - None
  
    Notes:
     Currently only the JSON format is supported.
 
    Examples:
     | procedure Fetch_Rows as 
     |  rowset DBMS_TF.row_set_t;
     |  str    varchar2(32000);
     | begin
     |   DBMS_TF.Get_Row_Set(rowset);
     |   str := DBMS_TF.Row_to_Char(rowset, 1)
     | end;

  */
  FORMAT_JSON            CONSTANT PLS_INTEGER :=   1;
  FORMAT_XML             CONSTANT PLS_INTEGER :=   2;
  FUNCTION Row_To_Char(rowset Row_Set_t, 
                       rid    PLS_INTEGER,
                       format PLS_INTEGER default FORMAT_JSON) 
           return VARCHAR2;
  
  /*----------------------------------------------------------------------
    PROCEDURE Trace
     Sundry procedures that used DBMS_OUTPUT to print out data structures
     in this package. These procedures are helpful during development
     and problem diagnosis.

    Parameters:
    - None
   
    Exceptions:
    - None
 
    Return:
    - None
  
    Notes:

 
    Examples:
     | procedure Fetch_Rows as 
     |  rowset DBMS_TF.row_set_t;
     | begin
     |   DBMS_TF.Trace('IDENTITY_PACKAGE.Fetch_Rows()', with_id => TRUE);
     |
     |   DBMS_TF.Trace(rowset);
     |   DBMS_TF.Get_Row_Set(rowset);
     |   DBMS_TF.Trace(rowset);
     |   DBMS_TF.Put_Row_Set(rowset);
     |   dbms_tf.trace(dbms_tf.get_env);
     | end;

  */
  PROCEDURE Trace(msg                   varchar2, 
                  with_id               boolean   default FALSE, 
                  separator             varchar2  default NULL,
                  prefix                varchar2  default NULL);
  PROCEDURE Trace(rowset             IN row_set_t); 
  PROCEDURE Trace(env                IN env_t);
  PROCEDURE Trace(columns_new        IN columns_new_t);
  PROCEDURE Trace(cols               IN columns_t);
  PROCEDURE Trace(columns_with_type  IN columns_with_type_t);
  PROCEDURE Trace(tab                IN table_t); 
  PROCEDURE Trace(col                IN column_metadata_t); 
  
  /*----------------------------------------------------------------------
    PROCEDURE XStore_Get
         A Key/Value Store for PTF Execution State Management

    Parameters:
    - key:   A unique chracter key
    - value: Value corrsponding to the key for supported types
   
    Exceptions:
    - None
 
    Return:
    - None
  
    Notes:
    - Gets the value associated with the key in the value out variable.
 
    Examples:
     | procedure FETCH_ROWS is
     |   ROW_CNT constant pls_integer   := DBMS_TF.Get_Env().Row_Count;
     |   XID     constant DBMS_TF.xid_t := DBMS_TF.Get_XID();
     |   mxv     pls_integer            := null;
     |   c_in    DBMS_TF.tab_number_t;
     |   c_ou    DBMS_TF.tab_number_t;
     |   begin
     |     DBMS_TF.XStore_Get('mxv', mxv);
     |     DBMS_TF.Get_Col(1, c_in);
     |     for i in 1 .. ROW_CNT loop
     |       if (c_in(i) > nvl(mxv, c_in(i)-1)) then mxv := c_in(i); end if;
     |       c_ou(i) := mxv;
     |     end loop;
     |     DBMS_TF.Put_Col(1, c_ou);
     |     DBMS_TF.XStore_Set('mxv', mxv);
     |   end;


  */
  PROCEDURE XStore_Get(key IN VARCHAR2, value IN OUT VARCHAR2);
  PROCEDURE XStore_Get(key IN VARCHAR2, value IN OUT NUMBER);
  PROCEDURE XStore_Get(key IN VARCHAR2, value IN OUT DATE);
  PROCEDURE XStore_Get(key IN VARCHAR2, value IN OUT BOOLEAN);

  /*----------------------------------------------------------------------
    PROCEDURE XStore_Set
         A Key/Value Store for PTF Execution State Management

    Parameters:
     - key:   A unique chracter key
     - value: Value corrsponding to the key for supported types
   
   
    Exceptions:
    - None
 
    Return:
    - None
  
    Notes:
    - Sets the value for the given key.
 
    Examples:
     | procedure FETCH_ROWS is
     |   ROW_CNT constant pls_integer   := DBMS_TF.Get_Env().Row_Count;
     |   XID     constant DBMS_TF.xid_t := DBMS_TF.Get_XID();
     |   mxv     pls_integer            := null;
     |   c_in    DBMS_TF.tab_number_t;
     |   c_ou    DBMS_TF.tab_number_t;
     |   begin
     |     DBMS_TF.XStore_Get('mxv', mxv);
     |     DBMS_TF.Get_Col(1, c_in);
     |     for i in 1 .. ROW_CNT loop
     |       if (c_in(i) > nvl(mxv, c_in(i)-1)) then mxv := c_in(i); end if;
     |       c_ou(i) := mxv;
     |     end loop;
     |     DBMS_TF.Put_Col(1, c_ou);
     |     DBMS_TF.XStore_Set('mxv', mxv);
     |   end;


  */
  PROCEDURE XStore_Set(key IN VARCHAR2, value IN VARCHAR2);
  PROCEDURE XStore_Set(key IN VARCHAR2, value IN NUMBER);
  PROCEDURE XStore_Set(key IN VARCHAR2, value IN DATE);
  PROCEDURE XStore_Set(key IN VARCHAR2, value IN BOOLEAN);

  
  
 
  /* Type Codes for supported types */
  XSTORE_TYPE_VARCHAR2     CONSTANT PLS_INTEGER := TYPE_VARCHAR2;
  XSTORE_TYPE_NUMBER       CONSTANT PLS_INTEGER := TYPE_NUMBER;
  XSTORE_TYPE_DATE         CONSTANT PLS_INTEGER := TYPE_DATE;
  XSTORE_TYPE_BOOLEAN      CONSTANT PLS_INTEGER := 252;
  
   /*----------------------------------------------------------------------
    PROCEDURE XStore_Exists
      Returns TRUE iff the key has an associated value. If key_type is null
      (or unknown) then check for any value, otherwise it only looks for the
      specifed type of key.

    Parameters:
     - key:   A unique chracter key
     - value: Value corrsponding to the key for supported types
   
    Exceptions:
    - None
 
    Return:
      Returns TRUE iff the key has an associated value. If key_type is null
      (or unknown) then check for any value, otherwise it only looks for the
      specifed type of key.
  
    Notes:
 
 
    Examples:
     | IF dbms_tf.XStore_exists(key('vc2') ) THEN
     |   dbms_output.put_line('======= exists with no type =  ' || key('vc2') || '  TRUE');
     | ELSE
     |  dbms_output.put_line('=======  exists with no type ' || key('vc2') ||'  FALSE');
     | END IF;

  */
  FUNCTION XStore_Exists(key IN VARCHAR2, 
                         key_type IN PLS_INTEGER default NULL)
           return BOOLEAN;

   /*----------------------------------------------------------------------
    PROCEDURE XStore_Remove
      Removes any value associated with the given value. If key_type is null
      (or unknown) then delete all corresponding keys, otherwise delete just
      the specfied key.
  
    Parameters:
     - key:   A unique chracter key
     - key_type - [Optional] The type of key to remove.
   
    Exceptions:
    - None
 
    Return:
     Removes any value associated with the given value. If key_type is null
     (or unknown) then delete all corresponding keys, otherwise delete just
     the specfied key
  
    Notes:
    
 
    Examples:
     | IF dbms_tf.XStore_exists(key('vc2') , dbms_tf.XSTORE_TYPE_VARCHAR2 ) THEN
     |    dbms_output.put_line('======= exists after remove =  ' || key('vc2') || '  TRUE');
     |  ELSE
     |    dbms_output.put_line('=======  exists after remove ' || key('vc2')  || '  FALSE');
     | END IF;

  */
  PROCEDURE XStore_Remove(key      IN VARCHAR2, 
                          key_type IN PLS_INTEGER default NULL);

  /**
   * NAME:
   *   XStore_Clear
   * DESCRIPTION:
   *   Removes all key/value pairs.
   */
  /*----------------------------------------------------------------------
    PROCEDURE XStore_Clear
       Removes all key/value pairs.
  
    Parameters:
    - None
  
    Exceptions:
    - None
 
    Return:
    - None
  
    Notes:
    
 
    Examples:
     |  dbms_tf.XStore_Clear;

  */
  PROCEDURE XStore_Clear;
  

   /*----------------------------------------------------------------------
    PROCEDURE CStore_Get
         A Key/Value Store for PTF Compilation State 

    Parameters:
    - key:   A unique chracter key
    - value: Value corrsponding to the key for supported types
   
    Exceptions:
    - None
 
    Return:
    - None
  
    Notes:
    - Gets the value associated with the key in the value out variable.
    - CStore is set during Describe time in the Describe descriptor, therefore
      it does not have have corresponding SET API's. 
    - Following example shows how to compute a running minimum and 
      maximun values for number type columns when column names are 
      specified during query time. The example is for illustration
      purposes and does not do validation/error checking etc.
 
    Examples:
     | create or replace package PTF_MIN_MAX_P is
     |  function  DESCRIBE(tab    IN OUT DBMS_TF.table_t,
     |   -- List of columns to compute maximum values
     |                     colmax    IN     DBMS_TF.columns_t,
     |   -- List od columns to compute minimum values
     |                     colmin    IN     DBMS_TF.columns_t)
     |            return DBMS_TF.describe_t;
     |  procedure FETCH_ROWS;
     | end;

     | create or replace package body PTF_MIN_MAX_P is
     |
     |  function DESCRIBE(tab    IN OUT DBMS_TF.table_t,
     |               colmax    IN     DBMS_TF.columns_t,
     |               colmin    IN     DBMS_TF.columns_t)
     |       return DBMS_TF.describe_t as
     |    descr DBMS_TF.describe_t;
     |    new   DBMS_TF.columns_new_t;
     |    cid   pls_integer := 1;
     | begin
     |  for i in 1 .. tab.column.count loop
     |    for j in 1 .. colmax.count loop
     |      if (tab.column(i).description.name = colmax(j)) then
     |         -- Mark this column to be read
     |         tab.column(i).for_read := TRUE;
     |         descr.cstore_num('getc'||i) := i;
     |         -- Create a corresponding new column
     |        new(cid).name := 'MAX_' || tab.column(i).description.name;
     |     new(cid).type := DBMS_TF.TYPE_NUMBER;
     |     descr.cstore_num('max'||cid) := cid;
     |    
     |     cid := cid + 1;
     |    end if;
     |  end loop;
     | 
     | for j in 1 .. colmin.count loop
     |    if (tab.column(i).description.name = colmin(j)) then
     |       -- Mark this column to be read
     |       tab.column(i).for_read := TRUE;
     |       descr.cstore_num('getc'||i) := i;
     |       -- Create a corresponding new column
     |      new(cid).name := 'MIN_' || tab.column(i).description.name;
     |     new(cid).type := DBMS_TF.TYPE_NUMBER;
     |     descr.cstore_num('min'||cid) := cid;
     |     cid := cid + 1;
     |    end if;
     |  end loop;
     | end loop;
     | --dbms_tf.trace(NEW);
     | descr.new_columns := new;
     | return descr;
     | end;
     |
     | procedure FETCH_ROWS IS
     |   ROW_CNT constant pls_integer   := DBMS_TF.Get_Env().Row_Count;
     |   XID     constant DBMS_TF.xid_t := DBMS_TF.Get_XID();
     |   mxv     pls_integer            := null;
     |   miv     pls_integer            := null;
     |   putcols dbms_tf.TABLE_METADATA_t := dbms_tf.Get_Env().put_columns;
     |   getcols dbms_tf.TABLE_METADATA_t := dbms_tf.Get_Env().get_columns;
     |   c_in    DBMS_TF.tab_number_t;
     |   c_ou    DBMS_TF.tab_number_t;
     |   max_col NUMBER := -1;
     |   min_col NUMBER := -1;
     |   env         dbms_tf.env_t := dbms_tf.Get_Env();
     |   fetched boolean := false;
     |  BEGIN
     |
     |    FOR j IN 1..putcols.count LOOP
     |      fetched := false;
     |      IF (dbms_tf.cstore_exists('max'||j)) THEN
     |        dbms_tf.cstore_get('max'||j, max_col);
     |      END IF;
     |      IF (j = max_col) AND
     |        (env.ref_put_col.exists(j) and
     |         env.ref_put_col(j)) then
     |           DBMS_TF.XStore_Get('mxv', mxv);
     |           IF (NOT fetched  AND j <= getcols.count) then
     |             DBMS_TF.Get_Col(j, c_in);
     |              fetched := true;
     |           END IF;
     |
     |      for i in 1 .. ROW_CNT LOOP
     |        if (c_in(i) > nvl(mxv, c_in(i)-1)) then
     |            mxv := c_in(i);
     |        end if;
     |         c_ou(i) := mxv;
     |      end loop;
     |      DBMS_TF.Put_Col(j, c_ou);
     |      DBMS_TF.XStore_Set('mxv', mxv);
     |   END IF;
     | 
     |  IF (dbms_tf.cstore_exists('min'||j)) THEN
     |     dbms_tf.cstore_get('min'||j, min_col);
     |  END IF;
     |
     |  IF (j = min_col)  AND
     |     (env.ref_put_col.exists(j) and
     |     env.ref_put_col(j)) then
     |      DBMS_TF.XStore_Get('miv', miv);
     |      IF (NOT fetched AND j <= getcols.count) then
     |         DBMS_TF.Get_Col(j, c_in);
     |      END IF;
     |      for i in 1 .. ROW_CNT LOOP
     |         if (c_in(i) < nvl(miv, c_in(i)+1)) then
     |             miv := c_in(i);
     |         end if;
     |         c_ou(i) := miv;
     |      end loop;
     |      DBMS_TF.Put_Col(j, c_ou);
     |     END IF;
     |   END LOOP;
     |  end;
     | end;
     |
     | create function PTF_MIN_MAX(t table, maxcols columns, mincols columns ) 
     |                 return table
     |                     pipelined TABLE POLYMORPHIC using PTF_MIN_MAX_P;
     |
     | select min_salary, max_salary, max_commision from ptf_min_max(employees
     |                                                partition by (salary), 
     |        columns(salary, commission_pct), columns(salary));

  */
  PROCEDURE CStore_Get(key IN VARCHAR2, value IN OUT VARCHAR2);
  PROCEDURE CStore_Get(key IN VARCHAR2, value IN OUT NUMBER);
  PROCEDURE CStore_Get(key IN VARCHAR2, value IN OUT DATE);
  PROCEDURE CStore_Get(key IN VARCHAR2, value IN OUT BOOLEAN);

  PROCEDURE CStore_Get(key_value OUT CSTORE_CHR_T);
  PROCEDURE CStore_Get(key_value OUT CSTORE_NUM_T);
  PROCEDURE CStore_Get(key_value OUT CSTORE_BOL_T);
  PROCEDURE CStore_Get(key_value OUT CSTORE_DAT_T);
  
  
  /* Type Codes for supported types */
  CSTORE_TYPE_VARCHAR2     CONSTANT PLS_INTEGER :=  TYPE_VARCHAR2;
  CSTORE_TYPE_NUMBER       CONSTANT PLS_INTEGER :=  TYPE_NUMBER;
  CSTORE_TYPE_DATE         CONSTANT PLS_INTEGER :=  TYPE_DATE;
  CSTORE_TYPE_BOOLEAN      CONSTANT PLS_INTEGER :=  252;
   /*----------------------------------------------------------------------
    PROCEDURE CStore_Exists
      Returns TRUE iff the key has an associated value. If key_type is null
      (or unknown) then check for any value, otherwise it only looks for the
      specifed type of key.

    Parameters:
     - key:   A unique chracter key
     - key_type - [Optional] The type of key
   
    Exceptions:
    - None
 
    Return:
     Returns TRUE iff the key has an associated value. If key_type is null
     (or unknown) then check for any value, otherwise it only looks for the 
      specifed type of key.
  
    Notes:
 
 
    Examples:
     |  IF (dbms_tf.cstore_exists('min'||j)) THEN
     |     dbms_tf.cstore_get('min'||j, min_col);
     |  END IF;
   

  */
  FUNCTION CStore_Exists(key      IN VARCHAR2, 
                         key_type IN PLS_INTEGER default NULL)
           return BOOLEAN;

END DBMS_TF;
/

GRANT EXECUTE ON DBMS_TF to PUBLIC;

create or replace public synonym dbms_tf for sys.dbms_tf
/


@?/rdbms/admin/sqlsessend.sql
