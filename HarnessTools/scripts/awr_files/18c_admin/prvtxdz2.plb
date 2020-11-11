@@?/rdbms/admin/sqlsessstart.sql
create or replace package xdb.xdb$acl_pkg_int wrapped 
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
d3 fb
59oBLkvGtJDKlRQZlFcOp+ca3P8wgy5KAJkVZy+iO7vqfjjzmMqfJjzZ1FaHPAsgrqCeP6nj
Zm9v+c+35i11yY/tWOM/8NWs/jpXAG65c06fKWTQnGp+YrGPA8X0ga334Um4YdA2+iG4wi18
cTmsLh26w5pR/23pk6cDlyqTNAhgPxhNVkHvQDbyp1w/7IX34Zk9qsMYXYiE0CKOhHCxAlIj
MwFsv9nuCS5ggy10qzON7yYK+lvU6Xt+

/
create or replace package body xdb.xdb$acl_pkg_int wrapped 
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
b
2a5 21b
Tnj6Uc/blg81mj99IlMW7WrKwkYwg2PMs9wVfI6BWGRTqBsF02hQzkbua/UfeYqD6M02QW9G
JqL7HW3uTnnayuzOi2phuUHHue3Bw/OSWrnzYGVPrzg6z60Pz8NPu2Q9J+v1dTfL3VOOd2U+
qaejjEuNJVlp6Od4DrOno6kt7IILNX8Cbr1Ha43hEfrMyOHu9BGSZ9IuzwW7/rfaW0qlQfSn
QzJKe/TvXEpXjMzK5E2cOTJudgoLJjeTVt36C9Z2JrLHcNgB+8nJCdbUU/DVDyq9uD5cafl9
ff0aHCTf6fdbGUywVdoETsgd5s121sxaiO6Ua3qfKFmZSBeet14EUVZgTaiAbUVwFUMVTdmG
dzNGKEC52zqt9KksVXHa9is5nx7OkVaWvSAMt1t351cyzfDIrZJcIy8BufnCklB3E0P5/AHE
TIAAV6Nb48se0Nc/tBD27HI1pwKd9ZjH8XtMfrFYmKpkrij4AXjycH0zuMzECOStEbxNAz2L
Chkqtf1O1fW1rVu7Dx+aeATi+Q==

/
grant execute on xdb.xdb$acl_pkg_int to public;
declare
  lev     BINARY_INTEGER;
  newlvls varchar2(20);
  lvls    varchar2(20);
BEGIN
  dbms_system.read_ev(31150, lev);
  lvls := '0x' || 
           ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0');

  
  newlvls := '0x' ||
      ltrim(to_char(rawtohex(utl_raw.bit_or(
                               utl_raw.cast_from_binary_integer(lev),
                               utl_raw.cast_from_binary_integer(4)))), '0');

  execute immediate 
    'alter session set events ''31150 trace name context forever, level ' || 
    newlvls || ''' ';

  dbms_output.put_line('event 31150: old level = ' || lvls || ', new = ' || newlvls);
end;
/
DECLARE
 lev BINARY_INTEGER;
BEGIN
  dbms_system.read_ev(31150, lev);
  dbms_output.put_line('0x' ||
      ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0'));
END;
/
declare
  cur integer;
  rc  integer;
begin
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(cur,
     'create index xdb.xdb$acl_xidx on xdb.xdb$acl(object_value) '||
     'indextype is xdb.xmlindex '||
     'parameters(''PATH TABLE XDBACL_PATH_TAB VALUE INDEX XDBACL_PATH_TAB_VALUE_IDX'') ',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
end;
/
declare
  cur integer;
  rc  integer;
begin
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(cur,
     'create index xdb.xdb$acl_spidx on xdb.xdb$acl(xdb.xdb$acl_pkg_int.special_acl(object_value), object_id)',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
end;
/
@?/rdbms/admin/sqlsessend.sql
