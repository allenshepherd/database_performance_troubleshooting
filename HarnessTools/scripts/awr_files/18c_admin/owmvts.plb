@@?/rdbms/admin/sqlsessstart.sql
create or replace package wmsys.owm_vt_pkg wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
39c 10f
lDVfZ4bhc+Og6buGQh2o+HDuBLcwgw33LcsVfHSiWPiUHDXmWkufGNPEDRGQj1fK6Ep056+p
j/69pJjKQDCY6ymQ9cvUuS5tuKqa1LHHz3GWcPGfXd04hF/hjgoppuzbK/qCbkCzIyuEdpw4
EwF6xi7fHZ5CxEBLExLVL3cUdNsYeeh7w4k3dVHxAiNKxoRlED4w1RHAZ9pqAqu8f/RXKarV
yflk5RnM64m53QSZ4irKJyYP+O/yIOY+NI6TneafaZYiA8iScg==

/
declare
  procedure initOperator(operator varchar2, retschema varchar2 default null, rettype varchar2 default 'INTEGER') is
    cnt integer ;

    pubsyn exception ;
    PRAGMA EXCEPTION_INIT(pubsyn, -01432);
  begin
    select count(*) into cnt
    from dba_opbindings
    where owner = 'WMSYS' and
          operator_name = operator and
          replace(function_name, '"', '') = 'WMSYS.OWM_VT_PKG.' || operator and
          ((return_schema is null and retschema is null) or return_schema = retschema) and
          return_type = rettype ;

    if (cnt=0) then
      begin
        execute immediate 'drop public synonym ' || operator ;
      exception when pubsyn then null;
      end ;

      execute immediate 'create or replace operator wmsys.' || operator || ' binding (wmsys.wm_period, wmsys.wm_period)' ||
                        ' return ' || (case when retschema is not null then retschema || '.' else null end) || rettype || ' using wmsys.owm_vt_pkg.' || operator ;
    end if ;
  end;
begin
  initOperator('WM_OVERLAPS') ;
  initOperator('WM_INTERSECTION', 'WMSYS', 'WM_PERIOD') ;
  initOperator('WM_LDIFF', 'WMSYS', 'WM_PERIOD') ;
  initOperator('WM_RDIFF', 'WMSYS', 'WM_PERIOD') ;
  initOperator('WM_CONTAINS') ;
  initOperator('WM_MEETS') ;
  initOperator('WM_LESSTHAN') ;
  initOperator('WM_GREATERTHAN') ;
  initOperator('WM_EQUALS') ;
end;
/
@@?/rdbms/admin/sqlsessend.sql
