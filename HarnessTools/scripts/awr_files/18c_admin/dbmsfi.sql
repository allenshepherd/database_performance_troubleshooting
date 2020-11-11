Rem
Rem $Header: rdbms/admin/dbmsfi.sql /main/8 2017/07/13 14:43:09 skabraha Exp $
Rem
Rem dbmsfi.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsfi.sql - DBMS Frequent Itemset package Declaration
Rem
Rem    DESCRIPTION
Rem      Declaration for the frequent itemset package
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsfi.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsfi.sql
Rem SQL_PHASE: DBMSFI
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skabraha    06/29/17 - move to AnyTypeFromPersistent
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    weili       09/25/03 - support NULL cursor 
Rem    weili       12/26/02 - create synonym for dbms_frequent_itemset
Rem    jihuang     12/20/02 - support any item type
Rem    weili       11/20/02 - weili_dbms_frequent_itemset
Rem    weili       11/07/02 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql
/* the following object will be used by table functions
 * supporting anonymous item type item  SYS.AnyData);
 */
create or replace library ora_fi_lib trusted as static
/

DROP TYPE itemsets;

DROP TYPE itemset;

CREATE OR REPLACE TYPE itemset AS OBJECT(
       itemset_id NUMBER, 
       support NUMBER, 
       length NUMBER,
       total_tranx   NUMBER, 
       item  SYS.AnyData);
/

CREATE TYPE itemsets AS TABLE OF itemset;
/

create or replace type fi_categoricals as table of varchar2(4000);
/
create or replace type fi_numericals as table of number;
/

create or replace type ora_fi_t authid current_user as object
(
  type_schema  varchar2(130),
  type_name    varchar2(130),
  cnum         number,
  finished     number,
  closed       number,
  is_char      number,

  static function ODCITableDescribe(
    coll_type out SYS.AnyType,
    cur IN OUT sys_refcursor
  ) return number,

  static function ODCITablePrepare(
    sctx OUT ora_fi_t,
    ti IN SYS.ODCITabFuncInfo,
    cur sys_refcursor
  ) return number,

  static function ODCITableStart(
    sctx IN OUT ora_fi_t,
    cur IN OUT sys_refcursor
  ) return number,

  member function ODCITableFetch(
    self IN OUT ora_fi_t,
    nrows number,
    out_coll OUT SYS.AnyDataSet
  ) return number,

  member function ODCITableClose(
    self IN ora_fi_t
  ) return number
);
/

create or replace type body ora_fi_t
is
  static function ODCITableDescribe(
    coll_type out SYS.AnyType,
    cur IN OUT sys_refcursor
  ) return number is
    itemset_type SYS.AnyType;
    elem_type SYS.AnyType;
    curnum number;
    numcols number;
    col_desc dbms_sql.desc_tab2;
  begin
    curnum := SYS.dbms_sql.to_cursor_number(cur);
    sys.dbms_sql.describe_columns2(curnum, numcols, col_desc);

    -- check 'item' column for char / number type and use the
    -- correct predefined collection in that case
    SYS.AnyType.BeginCreate(SYS.dbms_types.typecode_object, elem_type);
    if (col_desc(2).col_type = dbms_types.typecode_varchar or
        col_desc(2).col_type = dbms_types.typecode_varchar2 or 
        col_desc(2).col_type = dbms_types.typecode_char) then
      itemset_type := SYS.GetAnyTypeFromPersistent('SYS','FI_CATEGORICALS');
    else
      itemset_type := SYS.GetAnyTypeFromPersistent('SYS','FI_NUMERICALS');
    end if;
 
    elem_type.AddAttr('ITEMSET', SYS.dbms_types.typecode_table,
                      null, null, null, null, null, itemset_type);
    elem_type.AddAttr('SUPPORT', SYS.dbms_types.typecode_number,
                      null, null, null, null, null);
    elem_type.AddAttr('LENGTH', SYS.dbms_types.typecode_number,
                      null, null, null, null, null);
    elem_type.AddAttr('TOTAL_TRANX', SYS.dbms_types.typecode_number,
                      null, null, null, null, null);
    elem_type.EndCreate;

    SYS.AnyType.BeginCreate(SYS.dbms_types.typecode_table, coll_type);
    coll_type.SetInfo(null, null, null, null, null, elem_type,
                      SYS.dbms_types.typecode_object, 0);
    coll_type.EndCreate;

    cur := sys.dbms_sql.to_refcursor(curnum);

    return SYS.ODCIConst.Success;
  end;

  static function ODCITablePrepare(
    sctx OUT ora_fi_t,
    ti IN SYS.ODCITabFuncInfo,
    cur sys_refcursor
  ) return number is
    prec pls_integer;
    scale pls_integer;
    len pls_integer;
    csid pls_integer;
    csfrm pls_integer;
    attr_name varchar2(130);
    type_schema varchar2(130);
    type_name varchar2(130);
    version varchar2(130);
    num_elems pls_integer;
    tc pls_integer;
    is_char number := 0;
    elem_type SYS.AnyType;
    nescoll_type SYS.AnyType;
    neselem_type SYS.AnyType;
  begin
    -- Get element type name and schema
    tc := ti.RetType.GetAttrElemInfo(0, prec, scale, len, csid, csfrm,
                                     elem_type, attr_name);
    tc := elem_type.GetInfo(prec, scale, len, csid, csfrm, type_schema,
                            type_name, version, num_elems);
    -- Check if nested collection type is a string type
    tc := elem_type.GetAttrElemInfo(1, prec, scale, len, csid, csfrm,
                                    nescoll_type, attr_name);
    tc := nescoll_type.GetAttrElemInfo(0, prec, scale, len, csid, csfrm,
                                       neselem_type, attr_name);

    if (tc = SYS.dbms_types.typecode_char or
        tc = SYS.dbms_types.typecode_varchar or
        tc = SYS.dbms_types.typecode_varchar2) then
      is_char := 1;
    end if;

    -- Instantiate the SELF context
    sctx := ora_fi_t(type_schema, type_name, 0, 0, 0, is_char);

    return SYS.ODCIConst.Success;
  end;

  static function ODCITableStart(
    sctx IN OUT ora_fi_t,
    cur IN OUT sys_refcursor
  ) return number is
    curnum number;
  begin
    -- get cursor number
    SYS.dbms_odci.SaveRefCursor(cur, curnum);

    if (sctx is not null) then
      sctx.cnum := curnum;
      sctx.finished := 0;
      sctx.closed := 0;
    else
      -- we return error because ODCITablePrepare
      -- should have been called to initialize sctx
      return SYS.ODCIConst.Error;
    end if;

    return SYS.ODCIConst.Success;
  end;

  member function ODCITableFetch(
    self IN OUT ora_fi_t,
    nrows number,
    out_coll OUT SYS.AnyDataSet
  ) return number is
    idx number := 1;
    done boolean := false;
    itemset_id number;
    itemval_num number;
    itemval_str varchar2(4000);
    itemnum number;
    support number;
    length  number;
    total_tranx number;
    dummy number;
    item_type SYS.AnyType;
    vc2_coll fi_categoricals;
    num_coll fi_numericals;
    nes_coll SYS.AnydataSet;
    cur sys_refcursor;
    dummyval1 number;
    dummyval2 number;
    dummyval3 number;
  begin
    -- Initialize output collection to null
    out_coll := null;

    -- If we have fetched all rows, then just return
    -- the null collection
    if (self.finished != 0) then
      return SYS.ODCIConst.Success;
    end if;

    -- restore cursor number into sys_refcursor
    SYS.dbms_odci.RestoreRefCursor(cur, self.cnum);

    while (not done) loop
      if (idx > nrows) then
        -- We fetched all the required rows, so we are done
        done := true;
      elsif (cur%notfound is null or not cur%notfound) then
        -- There might be row to fetch...
        -- Start creation of AnyDataSet if we haven't done
        -- that yet
        if (out_coll is null) then
          item_type := SYS.GetAnyTypeFromPersistent(self.type_schema,
                                                    self.type_name);
          SYS.AnyDataSet.BeginCreate(SYS.dbms_types.typecode_object,
                                     item_type, out_coll);
        end if;

        -- Fetch the row values
        if (self.is_char != 0) then
          fetch cur into
            itemset_id, itemval_str, support, length, total_tranx;
        else
          fetch cur into
            itemset_id, itemval_num, support, length, total_tranx;
        end if;
        -- Skip if there are no more rows
        if (cur%notfound) then
          continue;
        end if;

        -- Add a new element
        out_coll.AddInstance;
        out_coll.Piecewise;
        -- Start creating the nested collection
        if (self.is_char != 0) then
          vc2_coll := fi_categoricals();
          vc2_coll.extend;
          vc2_coll(1) := itemval_str;
        else
          num_coll := fi_numericals();
          num_coll.extend;
          num_coll(1) := itemval_num;
        end if;

        -- Fetch all the rows in this itemset and add them to the
        -- nested collection
        for i in 1.. length - 1 loop
          if (self.is_char != 0) then
            fetch cur into
              itemset_id, itemval_str, dummyval1, dummyval2, dummyval3;
          else
            fetch cur into
              itemset_id, itemval_num, dummyval1, dummyval2, dummyval3;
          end if;

          -- We only need the item value
          if (self.is_char != 0) then
            vc2_coll.extend;
            vc2_coll(i + 1) := itemval_str;
          else
            num_coll.extend;
            num_coll(i + 1) := itemval_num;
          end if;
        end loop;

        -- itemset field
        if (self.is_char != 0) then
          out_coll.SetCollection(vc2_coll);
        else
          out_coll.SetCollection(num_coll);
        end if;
        -- support field
        out_coll.SetNumber(support);
        -- length field
        out_coll.SetNumber(length);
        -- total_tranx field
        out_coll.SetNumber(total_tranx);
      else
        -- No more rows to fetch on the cursor, so we are done.
        -- Also, set finished and closed flags
        done := true;
        self.finished := 1;
        close cur;
        self.closed := 1;
      end if;
      idx := idx + 1;
    end loop;

    if (out_coll is not null) then
      out_coll.EndCreate;
    end if;

    return SYS.ODCIConst.Success;
  end;

  member function ODCITableClose(
    self IN ora_fi_t
  ) return number is
    curnum number := SELF.cnum;
    is_closed number := SELF.closed;
    cur sys_refcursor;
  begin
    -- Was the cursor already closed?
    -- If some error occurred halfway through fetchs,
    -- then ODCITableClose will be called during cleanup
    if (is_closed = 0) then
      SYS.dbms_odci.RestoreRefCursor(cur, curnum);
      close cur;
    end if;

    return SYS.ODCIConst.Success;
  end;
end;
/

CREATE OR REPLACE TYPE ora_fi_RImp_t AS OBJECT
(
  dummy NUMBER,

  STATIC FUNCTION ODCITableDescribe(typ OUT SYS.AnyType, cur SYS_REFCURSOR)
    RETURN PLS_INTEGER
  IS
  LANGUAGE C
  LIBRARY ora_fi_lib
  NAME "ODCITableDescribe"
  WITH CONTEXT
  PARAMETERS (
    CONTEXT,
    typ,
    typ INDICATOR,
    cur,
    cur TDO,
    RETURN INT
  ),

  STATIC FUNCTION ODCITableRewrite(
    sctx               OUT  ora_fi_RImp_t,
    ti                  IN  SYS.ODCITabFuncInfo,
    str                OUT  CLOB,
    tranx_cursor        IN  SYS_REFCURSOR,
    support_threshold   IN  NUMBER,
    itemset_length_min  IN  NUMBER,
    itemset_length_max  IN  NUMBER,
    including_items     IN  SYS_REFCURSOR,
    excluding_items     IN  SYS_REFCURSOR
  ) RETURN PLS_INTEGER
  IS
  LANGUAGE C
  LIBRARY ora_fi_lib
  NAME "ODCITableRewrite"
  WITH CONTEXT
  PARAMETERS (
    CONTEXT,
    sctx,
    sctx INDICATOR STRUCT,
    ti,
    ti INDICATOR STRUCT,
    str,
    str INDICATOR,
    tranx_cursor,
    tranx_cursor TDO,
    support_threshold,
    support_threshold INDICATOR,
    itemset_length_min,
    itemset_length_min INDICATOR,
    itemset_length_max,
    itemset_length_max INDICATOR,
    including_items,
    including_items TDO,
    excluding_items,
    excluding_items TDO,
    RETURN INT
  )
);
/

CREATE OR REPLACE TYPE ora_fi_Imp_t AS OBJECT
(
  dummy NUMBER,

  STATIC FUNCTION ODCITableDescribe(typ OUT SYS.AnyType, cur SYS_REFCURSOR)
    RETURN PLS_INTEGER
  IS
  LANGUAGE C
  LIBRARY ora_fi_lib
  NAME "ODCITableDescribe"
  WITH CONTEXT
  PARAMETERS (
    CONTEXT,
    typ,
    typ INDICATOR,
    cur,
    cur TDO,
    RETURN INT
  )
);
/

CREATE or REPLACE PACKAGE dbms_frequent_itemset AUTHID CURRENT_USER AS

FUNCTION fi_transactional(
  tranx_cursor          IN  SYS_REFCURSOR,
  support_threshold     IN  NUMBER,
  itemset_length_min    IN  NUMBER,
  itemset_length_max    IN  NUMBER,
  including_items       IN  SYS_REFCURSOR DEFAULT NULL,
  excluding_items       IN  SYS_REFCURSOR DEFAULT NULL)
RETURN SYS.AnyDataSet pipelined parallel_enable using ora_fi_RImp_t;
 
FUNCTION fi_horizontal(
  tranx_cursor          IN  SYS_REFCURSOR,
  support_threshold     IN  NUMBER,
  itemset_length_min    IN  NUMBER,
  itemset_length_max    IN  NUMBER,
  including_items       IN  SYS_REFCURSOR DEFAULT NULL,
  excluding_items       IN  SYS_REFCURSOR DEFAULT NULL)
RETURN SYS.AnyDataSet pipelined parallel_enable using ora_fi_RImp_t;

FUNCTION fi_transactional_inner(
  tranx_cursor          IN  SYS_REFCURSOR,
  support_threshold     IN  NUMBER,
  itemset_length_min    IN  NUMBER,
  itemset_length_max    IN  NUMBER,
  including_items       IN  SYS_REFCURSOR DEFAULT NULL,
  excluding_items       IN  SYS_REFCURSOR DEFAULT NULL)
RETURN itemsets pipelined parallel_enable using ora_fi_Imp_t;

FUNCTION fi_horizontal_inner(
  tranx_cursor          IN  SYS_REFCURSOR,
  support_threshold     IN  NUMBER,
  itemset_length_min    IN  NUMBER,
  itemset_length_max    IN  NUMBER,
  including_items       IN  SYS_REFCURSOR DEFAULT NULL,
  excluding_items       IN  SYS_REFCURSOR DEFAULT NULL)
RETURN itemsets pipelined parallel_enable using ora_fi_Imp_t;


function fi_transactional_outer(
  cur sys_refcursor
) return SYS.AnyDataSet pipelined using ora_fi_t;

END;
/

CREATE or REPLACE PUBLIC SYNONYM dbms_frequent_itemset for sys.dbms_frequent_itemset
/

GRANT EXECUTE on dbms_frequent_itemset TO PUBLIC
/

GRANT EXECUTE on ora_fi_Imp_t TO PUBLIC
/

GRANT EXECUTE on ora_fi_RImp_t TO PUBLIC
/

GRANT EXECUTE on fi_categoricals TO PUBLIC
/

GRANT EXECUTE on fi_numericals TO PUBLIC
/

GRANT EXECUTE on itemsets TO PUBLIC
/

GRANT EXECUTE on itemset TO PUBLIC
/

GRANT EXECUTE on ora_fi_t TO PUBLIC
/

@?/rdbms/admin/sqlsessend.sql
