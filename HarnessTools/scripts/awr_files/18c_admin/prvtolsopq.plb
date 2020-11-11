@@?/rdbms/admin/sqlsessstart.sql
CREATE LIBRARY LBACSYS.lbac$type_libt wrapped 
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
2a 61
oZ4awgZgstZOHnhWZAb3Dm2kLdkwg04I9Z7AdBjDhaHyWSs+JlZa8HL6WcXM572esstSMsyl
dCvny1J0CPVhyaambOd0Bg==

/
CREATE LIBRARY LBACSYS.lbac$label_libt wrapped 
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
2b 61
gLWkMjKNiuC81AvkeY5TgU9CRKcwg04I9Z7AdBjDhaHyWSv6oVny1/Ry+lnFzOe9nrLLUjLM
pXQr58tSdAj1Ycmmpnw/sso=

/
CREATE LIBRARY LBACSYS.lbac$privs_libt wrapped 
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
2b 61
mwy82zcsv0GO5w+fELzyRVKt2Sowg04I9Z7AdBjDhaHyWSs+FpdW1Upy+lnFzOe9nrLLUjLM
pXQr58tSdAj1Ycmmpt8WssM=

/
CREATE LIBRARY LBACSYS.lbac$lablt_libt wrapped 
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
2b 61
nUry1bTIcBSLoS4aN1qEhnBzingwg04I9Z7AdBjDhaHyWSv6oVmXPvRy+lnFzOe9nrLLUjLM
pXQr58tSdAj1YcmmpmWZspY=

/
CREATE TYPE LBACSYS.lbac_label OID '6619848A7F882205E034000077904948' 
AS OPAQUE VARYING(3889)
USING LIBRARY LBACSYS.lbac$label_libt
(
   STATIC FUNCTION new_lbac_label(num IN PLS_INTEGER)
   RETURN lbac_label,
   PRAGMA RESTRICT_REFERENCES(new_lbac_label, RNDS, WNDS, RNPS, WNPS),
   MEMBER FUNCTION to_tag(SELF IN lbac_label)
   RETURN PLS_INTEGER DETERMINISTIC,
   PRAGMA RESTRICT_REFERENCES(to_tag, RNDS, WNDS, RNPS, WNPS),
   MAP MEMBER FUNCTION lbac_label_map
   RETURN PLS_INTEGER DETERMINISTIC,
   MEMBER FUNCTION eq_sql(SELF IN lbac_label,
                          comp_label IN lbac_label)
   RETURN PLS_INTEGER,
   PRAGMA RESTRICT_REFERENCES(eq_sql, RNDS, WNDS, RNPS, WNPS),
   MEMBER FUNCTION eq(SELF IN lbac_label,
                      comp_label IN lbac_label)
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(eq, RNDS, WNDS, RNPS, WNPS)
);
/
show errors;
CREATE TYPE LBACSYS.lbac_bin_label OID '6619848A7F9C2205E034000077904948'
AS OPAQUE VARYING(*)
USING LIBRARY LBACSYS.lbac$type_libt
(
  STATIC FUNCTION new_lbac_bin_label(policy_id IN PLS_INTEGER,
                                     bin_size IN PLS_INTEGER)
  RETURN LBAC_BIN_LABEL,
  PRAGMA RESTRICT_REFERENCES(new_lbac_bin_label, RNDS, WNDS, RNPS, WNPS),
  MEMBER FUNCTION eq_sql(SELF IN lbac_bin_label,
                         comp_label IN lbac_bin_label)
  RETURN PLS_INTEGER DETERMINISTIC,
  PRAGMA RESTRICT_REFERENCES(eq_sql, RNDS, WNDS, RNPS, WNPS),
  MEMBER FUNCTION eq(SELF IN lbac_bin_label,
                     comp_label IN lbac_bin_label)
  RETURN BOOLEAN DETERMINISTIC,
  PRAGMA RESTRICT_REFERENCES(eq, RNDS, WNDS, RNPS, WNPS),
  MEMBER FUNCTION bin_size(SELF IN lbac_bin_label)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(bin_size, RNDS, WNDS, RNPS, WNPS),
  MEMBER FUNCTION set_raw(SELF      IN OUT NOCOPY lbac_bin_label,
                          position  IN PLS_INTEGER,
                          byte_len  IN PLS_INTEGER,
                          raw_label IN RAW)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(set_raw, RNDS, WNDS, RNPS, WNPS),
  MEMBER FUNCTION set_int(SELF IN OUT NOCOPY lbac_bin_label,
                          position  IN PLS_INTEGER,
                          byte_len  IN PLS_INTEGER,
                          int_label IN PLS_INTEGER)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(set_int, RNDS, WNDS, RNPS, WNPS),
  MEMBER FUNCTION to_raw(SELF     IN lbac_bin_label,
                         position IN PLS_INTEGER,
                         byte_len IN PLS_INTEGER)
  RETURN RAW,
  PRAGMA RESTRICT_REFERENCES(to_raw, RNDS, WNDS, RNPS, WNPS),
  MEMBER FUNCTION to_int(SELF     IN lbac_bin_label,
                         position IN PLS_INTEGER,
                         byte_len IN PLS_INTEGER)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(to_int, RNDS, WNDS, RNPS, WNPS),
  MEMBER FUNCTION policy_id (SELF   IN lbac_bin_label)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(policy_id, RNDS, WNDS, RNPS, WNPS)
);
/
show errors;
CREATE TYPE LBACSYS.lbac_privs OID '6619848A7FDF2205E034000077904948'
AS OPAQUE FIXED(9)
USING LIBRARY LBACSYS.lbac$privs_libt
(
   STATIC FUNCTION new_lbac_privs(policy_id IN PLS_INTEGER)
   RETURN lbac_privs,
   PRAGMA RESTRICT_REFERENCES(new_lbac_privs, RNDS, WNDS, RNPS, WNPS),
   MEMBER PROCEDURE set_priv(SELF IN OUT NOCOPY lbac_privs,
                             priv_number IN PLS_INTEGER),
   PRAGMA RESTRICT_REFERENCES(set_priv, RNDS, WNDS, RNPS, WNPS),
   MEMBER FUNCTION test_priv(SELF IN lbac_privs, 
                             priv_number IN PLS_INTEGER) 
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(test_priv, RNDS, WNDS, RNPS, WNPS),
   MEMBER FUNCTION policy_id(SELF IN lbac_privs)
   RETURN PLS_INTEGER,
   PRAGMA RESTRICT_REFERENCES(policy_id, RNDS, WNDS, RNPS, WNPS),
   MEMBER PROCEDURE clear_priv(SELF IN OUT NOCOPY lbac_privs,
                               priv_number IN PLS_INTEGER),
   PRAGMA RESTRICT_REFERENCES(clear_priv, RNDS, WNDS, RNPS, WNPS),
   MEMBER PROCEDURE union_privs(SELF IN OUT NOCOPY lbac_privs,
                                other_privs IN lbac_privs),
   PRAGMA RESTRICT_REFERENCES(union_privs, RNDS, WNDS, RNPS, WNPS),
   MEMBER PROCEDURE diff_privs(SELF IN OUT NOCOPY lbac_privs,
                                other_privs IN lbac_privs),
   PRAGMA RESTRICT_REFERENCES(diff_privs, RNDS, WNDS, RNPS, WNPS),
   MEMBER FUNCTION none(SELF IN lbac_privs)
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(none, RNDS, WNDS, RNPS, WNPS)
);
/
show errors;
CREATE TYPE LBACSYS.lbac_label_list
OID '6619848A801E2205E034000077904948'
AS OPAQUE FIXED(39)
USING LIBRARY LBACSYS.lbac$lablt_libt
(
   STATIC FUNCTION new_lbac_label_list(policy_id IN PLS_INTEGER)
   RETURN lbac_label_list,
   PRAGMA RESTRICT_REFERENCES(new_lbac_label_list, RNDS, WNDS, RNPS, WNPS),
   MEMBER PROCEDURE put(SELF IN OUT lbac_label_list,
                             label IN lbac_label, pos IN PLS_INTEGER),
   PRAGMA RESTRICT_REFERENCES(put, RNDS, WNDS, RNPS, WNPS),
   MEMBER FUNCTION get(SELF IN lbac_label_list, pos IN PLS_INTEGER)
   RETURN lbac_label,
   PRAGMA RESTRICT_REFERENCES(get, RNDS, WNDS, RNPS, WNPS),
   MEMBER FUNCTION count(SELF IN lbac_label_list)
   RETURN PLS_INTEGER,
   PRAGMA RESTRICT_REFERENCES(count, RNDS, WNDS, RNPS, WNPS),
   MEMBER FUNCTION policy_id(SELF IN lbac_label_list)
   RETURN PLS_INTEGER,
   PRAGMA RESTRICT_REFERENCES(policy_id, RNDS, WNDS, RNPS, WNPS)
);
/
show errors;
CREATE OR REPLACE TYPE LBACSYS.lbac_name_list
IS VARRAY(32) OF VARCHAR2(30);
/
CREATE OR REPLACE TYPE BODY LBACSYS.lbac_label wrapped 
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
40c 1c2
pe6TmYXDtsgtyWuapR/aaGF57Gswgw33JPZqfC+V2sFedmuE4WOEKacpFA9xN8/A0gd3t7jy
eOs+XiQQbGyVQFN3juU1066usL8kOuJsL+j8cFeBIFJ9rrsdDro7pm6AZBSKHQxkdB3rfyc3
ZSeOGnh2q2l0O5/MLbDsit9Mwl3WAQQQoR1pyyHApEsbyOk4fuc8T2pQqhp4senr8lSgTL6K
e/51sfgJFOjvD3qAQw9n7NKPHukRs+gJQdgFcUMHUa5g3KvbTtjiUwnT7S2P2+vwhoPXZl6U
Vm/cYOW7cygZzdFOeU3zkYC8GaLQgdT3GRdL7xW9sb3ND6/LwU61wNehF5UB3SWckS9YNmF4
IdQzC3tBbMhFrkUOowgnCZzWPJgUL+oDbikvVTVyuLy9e8ve7DPgo5sqqsthenesZxUELoVt
FV06uZmRWrvP

/
show errors;
CREATE OR REPLACE TYPE BODY LBACSYS.lbac_bin_label wrapped 
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
69d 1a1
zgcNkVLWZAlcjX+QMBlVcPCGbK0wgz2J2SdqfC/pmDPqR2UC+TUr8Xq9HZtf4Po2v+8GJemv
0rWc94QGgBFtkNI1DS99f8e7drKeDYRQ8bFQ3wectDTtxjNQNGEOz6cBpiJNZznflBNnFd1T
0CvVtipSoPKMTK0tkfxaraZ/Vx7vUt1ip64+P9R9ZUIj1B6lxo6H4E3yQCZmyK6Aq8TbSQJO
bOLYTLCyXc9Vk5ZLUFTLPJZ71dCf694uA0pdYBtId5sE4CYz7YnD+1RfU5LygdVg3HqQwmKP
5R6pswZRdZHS4aeYlcS3Woj5W/T1AcoIUtUZrhSFGirJXn2oR+KwgKXeKvqFzVxfT4GuClO1
LpIkingiW2jpnQPZs4g+aFBBJCe4WL5Y1KDj6ZUDWTJOavPsAUZg

/
show errors;
CREATE OR REPLACE TYPE BODY LBACSYS.lbac_privs wrapped 
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
752 291
n90DGXo7QHwbrYJcXiXJdMGfV0gwg+2NLiAGfC9AEovqX2kow6PNOD39ScaI3fGIgPkReLDj
c1fD5tU244SqEM1w4wxf42Fcx/QqgoidTjDULTICaU3CQIFkPbvJAxCtiqlYs+fdVMlEB1jv
SAJmys9Ika8wXt4IkRuN8ayx8BY1L8MlIaxW/8wkzq4qo7C9RREgmdB8yojXpBPvpRHvYaIE
neKxCqoTzTh2OwmO7ClFLjgnTgA0uwXD8L8xBIFWiuFTm/21eljF6BDmbYNZUYa60hSusFWU
0Iiqd5ZNjm6TY6+OJOIHjdwDp8gGBqC8q3N8sn6cU1ZphGOUgLW9rDUF8ewEiQNnw62ZGlPl
/DYLG/ajjSjehQ1Y+BfxjJotmor5udCKB8i7UixnAI6nKhndbitDrh6knccgoyEf5NMRpZ13
DvZD5j70Xw4o09Ghub/4f3Q1vdaT5m8bdA69eLgzHf/tIE5NcgO3NZBHPxUIn055h/nPNU6y
KWFNGbc3aT+4/smN+NxQLEE8/TtJg9oD3b4OC6vACdxq0yZu6BVFmaPzh62J2d+5AdD5/hOm
XeLFgD8DzrbOVHOX0aXnJXFaIp5+gZU6nhUVZefWipSjGDGKgpGyCSry0F021TS7GaZfHTt6


/
show errors;
CREATE OR REPLACE TYPE BODY LBACSYS.lbac_label_list wrapped 
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
572 213
2owjb9cKV4hn+QpWx9I0voRH3nwwg+2JAPZqfC9A2vjqdmuEnmuEKaeh8ZbiZ/dGIloA9BpG
0y9jUPUpZGRdz75SaJER5TXfZLkAkEG3zSfwZ1yThHFHD+Zulqd/2z3Gq+NinqYe44Z0G4dl
xo029APKFjg1Lxhm50hVadWvk6QwvXGsb9+4KUvmx5zkOZB400pW3vupui+iK0HD59jMFFhm
dLzgbsY9BScAEaKvJqjoSAm0gxnBwXnybHHy6XgmyWgA+17eBcHwDvShvnar2miXjGAg8IQ9
QSKfK8Qyx5PAYG5lcCmED2kpst6PFtS/uwAtv4Z0MhheGDmgzHS3+zUSeKAWG8i9xbtKQjLC
zWC28S5bhCDYK2+Pom3/9QZzx4hkBfTPm8yCT+4Qks/aOZ2tTjFeE6qPmpopnsTSQsFRSg59
B0KveSTQ/jI6sTDu4LxQ1iaYpSxParwsWUIpDmRsYv9ikr3AJT4r+mmgGPeH41LTaaeGhqvc
fhDOPnE4+GZyeJp6rSSE

/
show errors;
@?/rdbms/admin/sqlsessend.sql
