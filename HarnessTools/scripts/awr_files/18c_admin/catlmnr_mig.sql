Rem
Rem $Header: rdbms/admin/catlmnr_mig.sql /main/1 2015/04/02 11:20:57 huntran Exp $
Rem
Rem catlmnr_mig.sql
Rem
Rem Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      catlmnr_mig.sql - catlmnr migration views
Rem
Rem    DESCRIPTION
Rem      Creates catlmnr views whose definitions are dependent on columns in
Rem      bootstrap tables.
Rem
Rem    NOTES
Rem      Run from catlmnr.sql and utlmmigtbls.sql.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catlmnr_mig.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catlmnr_mig.sql 
Rem    SQL_PHASE: CATLMNR_MIG
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catlmnr.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dvoss       03/13/15 - add COLLID and COLLINTCOL#
Rem    smangala    03/07/15 - proj 58812: track auto cdr columns
Rem    smangala    03/06/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- view LOGMNR_GTCS_CAT_SUPPORT
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
  new_col_str varchar2(100);
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='COL$' and linkname is null;
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='ACDRRESCOL#';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    new_col_str := 'lc.collid, lc.collintcol#, lc.acdrrescol#';
  else
    new_col_str := 'null, null, null';
  end if;

  execute immediate q'!
  create or replace force view logmnr_gtcs_cat_support_v$
      (logmnr_uid,
       obj#,
       objv#,
       segcol#,
       intcol#,
       col#,
       colname,
       type#,
       length,
       precision,
       scale,
       interval_leading_precision,
       interval_trailing_precision,
       property,
       charsetid,
       charsetform,
       logmnrcolflags,
       XTypeSchemaName,
       XTypeName,
       XFQColName,
       XTopIntCol,
       XReffedTableObjn,
       XReffedTableObjv,
       XColTypeFlags,
       XOpqTypeType,
       XOpqTypeFlags,
       XOpqLobIntcol,
       XOpqObjIntcol,
       XXMLIntCol,
       EaOwner#,
       EaMKeyId,
       EaEncAlg,
       EaIntAlg,
       EaColKlc,
       EaKLcLen,
       EaFlags,
       LogmnrDerivedFlags,
       collid,
       collintcol#,
       acdrrescol#)
  as
  select
       0 as logmnr_uid,
       o.obj#,
       o.spare2,
       lc.segcol#,
       lc.intcol#,
       lc.col#,
       lc.name,
       lc.type#,
       lc.length,
       lc.precision#,
       lc.scale,
       lc.spare2,  /* INTERVAL_LEADING_PRECISION */
       lc.spare1,  /* INTERVAL_TRAILING_PRECISION */
       lc.property,
       lc.charsetid,
       lc.charsetform,
       NULL LogmnrColFlags,   /* THIS IS BEING SET IN C */
       case lc.type# 
            when 1 /* DTYCHR */ then NULL  /* shortcut for most common */
            when 2 /* DTYNUM */ then NULL
            when 12 /* DTYDAT */ then NULL
            when 58 /* DTYOPQ - XMLType, ANYDATA, etc. */ then
             (select lv.data_type_owner
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
            when 121 /* DTYADT */ then
             (select lv.data_type_owner
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
            when 122 /* DTYNTB */ then
             (select lv.data_type_owner
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
            when 123 /* DTYNAR */ then
             (select lv.data_type_owner
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
            when 111 /* DTYIREF */ then  /*needed? copied from dba_tab_cols*/
             (select lv.data_type_owner
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
         else NULL end XTypeSchemaName,
       case lc.type# 
            when 1 /* DTYCHR */ then NULL  /* shortcut for most common */
            when 2 /* DTYNUM */ then NULL
            when 12 /* DTYDAT */ then NULL
            when 58 /* DTYOPQ - XMLType, ANYDATA, etc. */ then
             (select lv.data_type
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
            when 121 /* DTYADT */ then
             (select lv.data_type
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
            when 122 /* DTYNTB */ then
             (select lv.data_type
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
            when 123 /* DTYNAR */ then
             (select lv.data_type
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
            when 111 /* DTYIREF */ then  /*needed? copied from dba_tab_cols*/
             (select lv.data_type
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
         else NULL end XTypeName,
       case bitand(lc.property, 1029) 
            when 0 then
             null
            when 1 then
             (select lv.qualified_col_name
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
            when 5 then
             (select lv.qualified_col_name
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
            when 4 then
             (select lv.qualified_col_name
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
            when 1024 then
             (select lv.qualified_col_name
               from sys.logmnr_tab_cols_cat_support lv
               where lv.obj# = lc.obj# and
                     lv.internal_column_id = lc.intcol#)
          else NULL end XFQColName,
       /* topintcol */
       case when (bitand(lt.property,1) = 0)  /* typed table bit not set */
          then /* relational table */
               /* most columns are not hidden and thus do not have */
               /* an associated topintcol.  Certain special columns */
               /* where col# = 0 also do not have topintcol */
             case when
                  (bitand(lc.property,32) = 0) or  /* not hidden column */
                  (lc.col# = 0)then                /* special column */
                NULL /* do not set topintcol */
             else /* it is hidden and is not col# = 0 (ie special) */
                  /* so find the covering user visible column */
                  (select min(sc.intcol#) /* min for speedup only */
                   from sys.col$ sc
                   where sc.obj# = lc.obj# and
                         sc.col# = lc.col# and
                         bitand(sc.property,1) = 0 and /*not an attribute*/
                         bitand(sc.property, 32) = 0)  /* not hidden */
             end
       else /* typed table */
            /* everything gets rowinfo$ column as topintcol except */
            /* for the rowinfo$ itself, and the oid */
          case when
               (bitand(lc.property,2) = 0) and    /* not an oid */
               (bitand(lc.property,512) = 0) then /* not rowinfo$ */
             (select min(sc.intcol#) /* min for speedup only */
                from sys.col$ sc
               where sc.obj# = lc.obj# and
                     bitand(sc.property, 512) = 512) /* rowinfo col */
          else NULL end  /* oid/rowinfo, leave topintcol null */
       end XTopIntCol,
       case LC.TYPE# when 111 /* DTYIREF */ then
             (select oo.obj#
              from sys.obj$ oo, sys.refcon$ r
              where oo.oid$ = r.stabid and
                    r.intcol# = lc.intcol# and 
                    r.obj# = o.obj#) 
           else NULL end XReffedTableObjn,
       case LC.TYPE# when 111 /* DTYIREF */ then
             (select oo.spare2
              from sys.obj$ oo, sys.refcon$ r
              where oo.oid$ = r.stabid and
                    r.intcol# = lc.intcol# and 
                    r.obj# = o.obj#)
           else NULL end XReffedTableObjv,
       case LC.TYPE# when 58 /* DTYOPQ */ then
            (select ct.flags 
             from sys.coltype$ ct
             where ct.obj# = o.obj# and
                   ct.intcol# = lc.INTCOL#)
          else NULL end XColTypeFlags,
       case LC.TYPE# when 58 /* DTYOPQ */ then
            (select ot.type
             from sys.opqtype$ ot
             where ot.obj# = o.obj# and
                   ot.intcol# = lc.intcol#)
          else NULL end XOpqTypeType,
       case LC.TYPE# when 58 /* DTYOPQ */ then
            (select ot.flags
             from sys.opqtype$ ot
             where ot.obj# = o.obj# and
                   ot.intcol# = lc.intcol#)
          else NULL end XOpqTypeFlags,
       case LC.TYPE# when 58 /* DTYOPQ */ then
            (select ot.lobcol
             from sys.opqtype$ ot
             where ot.obj# = o.obj# and
                   ot.intcol# = lc.intcol#)
          else NULL end XOpqLobIntcol,
       case LC.TYPE# when 58 /* DTYOPQ */ then
            (select ot.objcol
             from sys.opqtype$ ot
             where ot.obj# = o.obj# and
                   ot.intcol# = lc.intcol#)
          else NULL end XOpqObjIntcol,
       /* xmlintcol */
       case when (bitand(lt.property,1) = 0)  /* typed table bit not set */
          then /* relational table */
               /* most columns are not hidden and thus do not have */
               /* an associated topintcol/xmlintocol. */
             case when
                  (bitand(lc.property,32) = 0) then  /* not hidden column */
                NULL /* do not set XMLintcol */
             else /* it is hidden and is not col# = 0 (ie special) */
                  /* so find the covering user visible column */
                  /* if it is not XML, then we want/get NULL */
                  (select min(sc.intcol#)
                   from sys.col$ sc, sys.opqtype$ opq
                   where sc.obj# = lc.obj# and        /* same obj# */
                         opq.obj# = lc.obj# and       /* same obj# */
                         sc.col# = lc.col# and        /* same col# */
                         sc.intcol# = opq.intcol# and
                         bitand(sc.property,1) = 0 and /*not an attribute*/
                         sc.type# = 58 and              /* opaque type */
                         opq.type = 1)                  /* XML */
             end
       else /* typed table */
             (select min(sc.intcol#)  /* NULL if topintocl is not XML */
              from sys.col$ sc, sys.opqtype$ opq
              where sc.obj# = lc.obj# and
                    opq.obj# = lc.obj# and
                    opq.intcol# = sc.intcol# and
                    bitand(sc.property, 512) = 512 and /* rowinfo col */
                    sc.type# = 58 and  /* opaque type */
                    opq.type = 1)    /* XML */
          end XXMLIntCol,
       case when (bitand(lc.property, 67108864) = 67108864) /* encrypt col */
         then 
       (select ea.owner#
             from sys.enc$ ea
             where ea.obj# = o.obj#)
           else NULL end EaOwner#,
       case when (bitand(lc.property, 67108864) = 67108864) 
         then 
       (select ea.mkeyid
             from sys.enc$ ea
             where ea.obj# = o.obj#)
           else NULL end EaMKeyId,
       case when (bitand(lc.property, 67108864) = 67108864) 
         then 
       (select ea.encalg
             from sys.enc$ ea
             where ea.obj# = o.obj#)
           else NULL end EaEncAlg,
       case when (bitand(lc.property, 67108864) = 67108864) 
         then 
       (select ea.intalg
             from sys.enc$ ea
             where ea.obj# = o.obj#)
           else NULL end EaIntAlg,
       case when (bitand(lc.property, 67108864) = 67108864)
         then 
       (select ea.colklc
             from sys.enc$ ea
             where ea.obj# = o.obj#)
           else NULL end EaColKlc,
       case when (bitand(lc.property, 67108864) = 67108864) 
         then 
       (select ea.klclen
             from sys.enc$ ea
             where ea.obj# = o.obj#)
           else NULL end EaKLcLen,
       case when (bitand(lc.property, 67108864) = 67108864) 
         then 
       (select nvl(ea.flag,0)
             from sys.enc$ ea
             where ea.obj# = o.obj#)
           else NULL end EaFlags,
       0 as LogmnrDerivedFlags,
  !' -- drop back into PL/SQL to define the columns conditionally
  || new_col_str ||
  q'!
  from
   sys.col$ lc, sys.tab$ lt, sys.obj$ o
  where 
   o.obj# = lt.obj# AND
   o.obj# = lc.obj#
  order by o.obj#, lc.intcol#
  !';
exception
  when success_with_error then
    null;
end;
/

@?/rdbms/admin/sqlsessend.sql
