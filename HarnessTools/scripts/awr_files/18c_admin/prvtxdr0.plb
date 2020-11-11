@@?/rdbms/admin/sqlsessstart.sql
drop view xdb.xdb$resource_view;
drop view xdb.xdb$rv;
declare
 ct number;
begin
  select count(*) into ct from dba_indexes where owner = 'XDB' and 
    index_name = 'XDBHI_IDX';
  if ct > 0 then
    execute immediate 'disassociate statistics from ' ||
                      'indextypes xdb.xdbhi_idxtyp force';
    execute immediate 'disassociate statistics from ' ||
                      'packages xdb.xdb_funcimpl force';
    execute immediate 'drop index xdb.xdbhi_idx';
  end if;
end;
/
drop indextype xdb.xdbhi_idxtyp force;
drop operator xdb.path force;
drop operator xdb.depth force;
drop operator xdb.abspath force;
drop operator xdb.under_path force;
drop operator xdb.equals_path force;
drop package xdb.xdb_ancop;
drop package xdb.xdb_funcimpl;
drop type xdb.xdbhi_im force;
drop type xdb.path_array force;
drop type xdb.path_linkinfo force;
create or replace library xdb.resource_view_lib wrapped 
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
16
2d 65
V0UuJ00QMqKMoi9SSbjg22OFCnwwg04I9Z7AdBjDFvJi/5Zi8tzwltlZYtBy+lkJ572esstS
Msy4dCvny1J0CPVhyaamCwvLuA==

/
create or replace library xdb.path_view_lib wrapped 
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
16
29 5d
e4p07e2zDC/glqq04OxpO3TUJTswg04I9Z7AdBjDFlpW+uOW2Vli0HL6WQnnvZ6yy1IyzLh0
K+fLUnQI9WHJpqaknnQN

/
create or replace type xdb.path_linkinfo OID '00000000000000000000000000020117' wrapped 
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
d
79 aa
g0V6zG8egE2xYLkdFQIyNY27Wowwg5n0dLhcFlpW+uNy+kfZ/0cM2cHAdCulv5vAMsvuJY8J
aee4dAhpqal8xsoXKMbK77KEHe+2RC9eXltNFTFq68aVcrOxlKEC9yaI5jWpC8gKD1o0nbBt
5sgLU0BrWBucGx2mqUqkyQ==

/
create or replace type xdb.path_array OID '00000000000000000000000000020154'
as varray(32000) of xdb.path_linkinfo
/
show errors;
grant execute on xdb.path_linkinfo to public;
grant execute on xdb.path_array to public;
create or replace type xdb.xdbhi_im OID '00000000000000000000000000020118' wrapped 
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
d
d2d 37c
GpQKlAFO+SClOmqzj4QxCI/Whzowg82nDNATfC/GEoteXzOiFKAJEuV3twsbr5S02AD/hkbD
gVAA0hnQDwU03zRv363RCTYzX8EITiy2RafntT+1kk6j7fnwpnVjWRrdOzwWJsI5KnwdJ7W2
rZX/r7gbrUzdTOyQhruYFJsD21q4V1QXtvKs8r5XZr2hTShfjDdUXRUvFgxw4osx2nc1c9LL
IfE90xpiM00XhJ5YBgL2kUYtcEwOfGJdNWxpZUwEV3/XguidbPNGmUMmx59y2gRd1pVGVr9M
Vou2ZSHfWZi4AnWNxYToYRhSkC4OsvUJO5dYowezjFJ9AS/me61QWfXNkev7qUqp2070Qziv
Y4X6+nlxhaf5PLFLY0Y2dxNjE57yf8aTrdxnzEKSacoeTmQuqlt0uuiKhwQKjgOTmB7VmLBL
+0URhtkedNwF1E9k1/fAof5yuZz08o5zuipVAsWYMQkLo66840iblVG8QDHfSqgupCKE0Wfa
Wi0a2P2NX2XB2gg/ncfC30gVZ/9ds8Lv4Vv6nkawUPaUIxKscYoq67FQ4mCM2ItUkDZB1Rfe
rG4CCuPV/qG+yCS/TI6/QEWWDLoMCx6Yx3YgOcsnxVfvYxDBp/7irGwc/NhMjfu72HPpNiUD
nyh7JlK/IgCirrzumrq6C2q8mkZ2Q/fCP3qHCSBBBgafeMZKNS0/mReZIJ8DbQ0S46ksGppC
OkpE2m/8d8QykIedP54zLaxzTcuZ0nK2e3rKCFano5AusL2/hRMTtU9IFbU6fgWj+ecSsD6T
Rln20C0B6aDAERrefCQUgXlADH2WJiCE5bwFGryyLrtQGePswZfK2yyMH28kpxn9n5l94dZi
L1FV0Ja1+2mSgGI=

/
show errors;
create or replace type body xdb.xdbhi_im wrapped 
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
e
81f 217
iq2zdhutWBf0y5ZAs27tdApsyY0wg9eJJCDWfC+V2sFeaDlaFoTUUctKEKFM8/0xgOxZ9+XL
11DtLJ35jGA3pmuo5ZeRuUft/utq6BACS3fgKA+7ICzGagjHG2JHplZ/8XYrDQYUDeFiU3Hv
oekRK1+MLgE+YjfivYoZ/xAPlg/It5YXPzapNeXw4VwgpxHKy4cGo+W0SrYcT3s5GtcJ7FP+
FAfbnBrTU7oUkytubc7LsZclaDxoOgO8bfJxe5bJAM84fHiF51763OLmk+WN/2vgyQs42XSq
ycn3WxDDBesrxP+jd9guAIPSWJA42dj1EdZKkGEo5d7Ppb2CKEWe8vNsnaLNWlgxG7kRJQ5X
dMVf4iNXgFTHlK1idGQkimnFbUAjeqs+o/MWz1XCZYpVefLAB3+dMyQyzF854zP5q6hbEDOT
nwCNmJvnVi3+Z3gwUVPRlZaCved406K//mYEmbgA9yZXhHoybLSiQX9bsIbA7KxvTB+1qdiN
h3Iu/tZC72MKbyiaA9Cemg==

/
show errors;
grant execute on xdb.xdbhi_im to public;
create or replace package XDB.XDB_FUNCIMPL wrapped 
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
29c 11f
uWG4peqUXpc5hxCiVwZLyLK8Sgowg9fxr54VfHRAAPiOrcWONWTaPd/irzsK3mZOd/6qmZgt
beMdr9YCXS/55PqA7NiYg2840sHAs31NrqRUjWccbmULiVGIiBYg+xsCUC81jIDR+vJ1mJ9f
iJvvLNS8t4DmHRy3NuODT/eyWRVWdL/Z0VQiiE3JLCwxMfalSk3/iJBfOcDXZ/M5jd4xhPBn
ApIyCs8pgwFtED1/GMBxntefAn3OStKk25Y+vN3dE4NIzXyqDDezneQVyU42QcdYuA==

/
show errors;
grant execute on XDB.XDB_FUNCIMPL to public ; 
create or replace package xdb.xdb_ancop wrapped 
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
87e 160
Fjxc+LYCpqtxloJcyFg6+wpjIPEwgz2NLUoVfHRAWEKe0MpcdMRlvqEOPGPeQ1NQ3D1Vf8df
eiJ59y+E+/uE5hqiwnZz+XZzwPLDmlPfuGhzYST4nbUdDgc+3eXA8k24aVGReSwNXZHonpm8
CG17xCWJG/t58vrdXEInV4jREji0ygp0OtUpY2Bv7g4JEeldoCaNd73OuTbAacPhDdwfVf9N
YzTZ2IqSCYS2HYafGT4D9xhVY4PAidp6Tv1N7u5Axp55qVL3W2FXF0ghto3VQRSy10A81HyU
h2Xpln/d74LfeAUYlxyWgoCEWJLQKkd9aTRIFvm1QyJ5yiKG0sDA4Roa8/8=

/
show errors;
grant execute on xdb.xdb_ancop to public ; 
alter type xdb.xdbhi_im compile;
@?/rdbms/admin/sqlsessend.sql
