@@?/rdbms/admin/sqlsessstart.sql
DECLARE
  obj_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(obj_not_found, -4043);
BEGIN  
  BEGIN
    execute immediate 'DROP PACKAGE prvt_awr_data';
    EXCEPTION WHEN obj_not_found THEN NULL;    
  END;
  BEGIN
    execute immediate 'DROP TYPE prvt_awr_period';
    EXCEPTION WHEN obj_not_found THEN NULL;
  END;
  BEGIN
    execute immediate 'DROP TYPE prvt_awr_inst_meta_tab';
    EXCEPTION WHEN obj_not_found THEN NULL;
  END;
  BEGIN
    execute immediate 'DROP TYPE prvt_awr_inst_meta';
    EXCEPTION WHEN obj_not_found THEN NULL;
  END;
END;
/
CREATE TYPE prvt_awr_inst_meta wrapped 
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
23e 18d
LZJKhuV05vuO0Y/Q3XiYc/Ao6ewwgwHxr9xqfHRnrf7Vz35sy3RQLwaJoNGyJ7cGVwVXk9q4
j6bmjKyasExFO1XAwpuHilfLnQ3nmpia3GGq2jrOkildTu0FrJ5xWOGbZ0anbDAUWolbsA98
wRQupqt/PAPCrRiy8LlEqQRxahy6xlFMfQLhBntqUTwUWl2FrlJHzQKlKg7Baik+DeU1dTuN
UTQJ9RPRp5P1xcFC0RyQQ3N9oA0GJbMU7j5y1+CJkhv0hNV+y75ATZp5g9JI9SEi/dp/pp6V
BIiD4GDo2FDB7XaWpXWkjZTxeP+HM5K4wIuUyWRjz2xdPPG6vBpTLEwx0PQH04qR63dnhTdW
0qgoJBT6DiErPS+A/2Apq0/i+fv3NvT+

/
show errors;
GRANT EXECUTE ON prvt_awr_inst_meta TO PUBLIC;
CREATE TYPE prvt_awr_inst_meta_tab 
AS TABLE OF prvt_awr_inst_meta;
/
show errors;
GRANT EXECUTE ON prvt_awr_inst_meta_tab TO PUBLIC;
CREATE OR REPLACE TYPE prvt_awr_xmltab
AS TABLE OF XMLTYPE;
/
show errors;
GRANT EXECUTE ON prvt_awr_xmltab TO PUBLIC;
CREATE OR REPLACE TYPE prvt_awr_evtList
AS TABLE OF VARCHAR2(64);
/
show errors;
GRANT EXECUTE ON prvt_awr_evtList TO PUBLIC;
CREATE OR REPLACE TYPE prvt_awr_numtab
AS TABLE OF NUMBER;
/
show errors;
GRANT EXECUTE ON prvt_awr_numtab TO PUBLIC;
CREATE TYPE prvt_awr_period wrapped 
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
551 2a1
Jl/RIPyFcqWGah1n+pNEgCRKHVAwg/DDLUgFfC/N2GSPb/2FyDYWGBp9uFH/3x30w0qAmFjj
pilQJjfMoJ0s8fEBCfc3uLa77etVEq4GwRyVBQiaD7WbtX2aP6SqtUKUjzCwq6ik8ycz/2b0
nth8ge/y4iuNL5DBhVb/HFq5qbkrxHgeHkbe/FDoV/KCSPdAwPC6Y+09UPjz6onMeOlSKxvP
mw5rEGGX0XTK0+cU2hHHaHSJafK6OWKzxJfAMfwezUxU6Gcx3hNBM4ruZyZd2pGldIHev52A
wpd90JLP/YH0d9PS87aSEX24ocH4S6mFiZEy1CrdMADMGwDHhWYWnki/QGryWSmjmOLL7MEO
fF4xEb02n8H6djR3egOWHaTj8Ug40wTiqp95XzxLNMKHMu2o1JXnyveoLATrdkT4phqNGcmp
2DTMqLbgpYmUd2Ke3hW2rfpA29Te+rOcJ8ky0BpZA/wHuNWQrqD1kpNHJGqFt7WI5Imar0Bf
7xw/4xPZ29LzW9I+CfM/PbfecaP5JwBlvTH3b28F8Ock4eYeo9xmCyPuGm8TGjPjclV1+8SF
aurvuuckdQ5JgChA2E9Jo0+j8HKco5VXYPbgBtyJf7cfBAsht/c+RyfgNjiraGdUCM+IjRaS
Kx4C5xC1m8vfueaA

/
show errors;
GRANT EXECUTE ON prvt_awr_period TO PUBLIC;
CREATE OR REPLACE PACKAGE prvt_awr_data wrapped 
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
af6 21f
M4H8RIiDrXRshj28+npKKi/4ILMwgw2NLtwdf3QCk/6Oh6xGU2fqSAZYvV1kLRcOCk3TW2dc
RLFJO8UUg/sIt0d7TkM6OjH0TRxLSTAx7blOM3mcT8T4Yo8W1rMO1ImFDBxY01bIH6ZVfY11
j2tJ+tARopOR/yfdFLHgdkNa+jay1IQERM9pqEipeM8f6xSILOsp2y5rbPF/QjDAK9/3p21O
mUpnHyExkoqb/ZnfLwA20dKsi7UD+/8pY0l2Cd8/5WRoq2tGYdKYolFMvQe0kezywlM/svO2
e8UyIfe85t/F7yjNaH9rb/jmz8ziSYxNr3yNOkmQC+dhg6SmnItXwA3OfIYQii2Q6ZQxnJeT
02uGp4uOu4SDkZRxdLz/pf8aDwGhfb6MiSq9qwXggASa6qtlVEfqUDJgDQiA63cnNXyNsDTX
jBaoyYcFnYHSM1OZvDrgufIzOzit1pDS5E3ODXMQKQ/FClFNxt/X4w3dHwh0Cvj8pEpb/G6N
T1c/9awKrfddKs926xZTNCNbNaIzyQ==

/
show errors;
GRANT EXECUTE ON prvt_awr_data TO PUBLIC;
@?/rdbms/admin/sqlsessend.sql
