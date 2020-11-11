@@?/rdbms/admin/sqlsessstart.sql
SET SERVEROUTPUT ON
SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
DECLARE
  table_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(table_exists, -955);
BEGIN
execute immediate '
create table XDB.XDB_INDEX_DDL_CACHE
(
  ROOT_TABLE_NAME          VARCHAR2(128), --the parent (user input)
                                          --xmltype table/relational table
  ROOT_TABLE_OWNER         VARCHAR2(128), --the paretn table owner
  ROOT_COL_NAME            VARCHAR2(128), --the relational column name 
                                          -- NULL for xmltype tables
  TABLE_NAME               VARCHAR2(128), --table name (inlcuding nested 
                                          --and OOL tables
  TABLE_OWNER              VARCHAR2(128), --table owner
  IDX_OWNER                VARCHAR2(128), --index owner
  IDX_TABLE_NAME           VARCHAR2(128), --table on which the index is
  IDX_NAME                 VARCHAR2(128),  
  IDX_TYPE                 VARCHAR2(27),  
  CONSTR_NAME              VARCHAR2(128),
  CONSTR_OWNER             VARCHAR2(128) 
) 
';

EXCEPTION
     when table_exists then null;
     when others then raise;
END;
/
grant select,insert,delete on XDB.XDB_INDEX_DDL_CACHE to public
/
grant select on  sys.obj$ to xdb;
grant select on  sys.ntab$ to xdb;
grant select on  sys.col$ to xdb;
grant select on  sys.coltype$ to xdb;
grant select on  sys.all_users to xdb;
grant select on  sys.attrcol$ to xdb;
grant select on  sys.pdb_inv_type$ to xdb;
create or replace package body XDB.DBMS_XDB_CONSTANTS wrapped 
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
ffc 2cd
lvaPFzlB5v5hlVFJN/rzTDw/Ysgwgw2nLvEayi9gF0ywj55e87Z/8+3mWnngjnTdiPaVcyCz
TeM9+VDDt4ajmu/XXdZBwiSg+wk++co0/F/9QkN18dQJ3rJri58KW/rYafGpkRiZMVOvPJ36
wYDWpKAUqibJu8OavVuZRbYJBNV1xsi6zw2sYIWBHd9qaBg/TtP5n4vkSV1y+GTaSoLdZaAV
TaejtSPi0iWIobPy4g12J3ugb7CDpgwwbM3d0ok3XuzCb+g+Fv5IVh9EvQ05jDnXpoxdjY1s
M5khiqR7GMpK2FYDtSQR+IUDwm4M6rhua2qTJL72CD+bl5cqba1yBhGUWOo8DIIA6Sdiqxpr
h3C+lcfMsVfNy0toLg09X0sKMyoshH6I9DXEtdlVxWAX6y1+6/ZNlVMNWozotPKdb66Ytcgb
ATjC92QNXmEkkJQwKb4ItpsEHYzudSbCm7KulwvTX2BwOQx3bV0OAiZ3dCrDKyIMpyLG3YXM
Xmxheq1IOFjYSIed983XwWj1S4rLf4k4D9ZsOCIZjp6/v0BOMKiEiKCWR1DmH9QFrKDi0/H8
gDcw+1Pd2aCjBHmhDev+WJdy7WIe/P9TPhCnvmAKa6reRtFMgvxpsRRY5ZvV3cg2dyZAowrp
KlQWsaJ3JuMm4iA49TOzhGt9iA1T5NpyRVUpW4sFwrcDjlluGJNzhh0ni/uI

/
show errors
CREATE OR REPLACE PACKAGE body XDB.DBMS_XMLSCHEMA_ANNOTATE wrapped 
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
17672 2148
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

/
SHOW ERRORS;
grant execute on XDB.DBMS_XMLSCHEMA_ANNOTATE to public;
/  
SHOW ERRORS;
create or replace package XDB.PRVT_DBMS_MANAGE_XMLSTORAGE wrapped 
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
137 eb
/e0W8RAwooIABognR9LW5cxkuoowg5BKAMvWfHQC2seeKKQYwzJ9l5GsOsy3yHs5Avr+nem2
RmmxPCX95OQ6MfvXmVus3QoRsUVNyxDfIa39AYtlalRcpnMG8FkDBzfbR9FU8sJEZgxKNLQ+
8kD/RUQAymKJZYFpiQsMD2p4RxSZElpM+IVFHFkxs/EKJeTHJLz+BFT31+PkNGq56YLxaus7
qs8aZpoqnCh8LK4R

/
grant execute on XDB.PRVT_DBMS_MANAGE_XMLSTORAGE to public;
show errors
create or replace package body XDB.PRVT_DBMS_MANAGE_XMLSTORAGE wrapped 
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
2697 6bb
X6uzf/pFtmmHYkwDer8UK7XyReMwg1Wj2cCMey/t9rzmbZNnjdltk4fqb8LIfyoEBBTPt5S1
tR/qlmfT5ijGWFPUXCYErKOwurCuxAUpqJJE1XT/TDr7ku7csJvP7+uyYYq50j/25805+aYU
k6dM1G+zRfb7ihJop1OveGgl6Bshna78JwacDkg1eAmlh0HQisFbgqIkI3qyzmb5IrOEOTMP
/r1MHughLrkFxc9hOVnGa4HYIjtI7v4cYUM7C0FDcxQ/lpmVlAWZer+C9c0nRunn+KGHNlUQ
ZTasqtBTTGdHnKqrYCr1C2R84/4Py48CvaSiTy1GeoblSDFhRljpjspafZ5meFGEfCrix9Wf
zzvNZRTAqnkgnnKyGWD539+gi7pfYpno68JqtVT4YCNybWg1LTx3Ys2pKY1TqohF/cosXVRK
Szh6UM7gIhDxPGXU8F6n6LZSgOfYspTPLPa3MfUJojFIM7sTF5OHpe38mWkcHD0J4Sfhg0qs
n36rZ2RUHM48oO1KEws3kRs62t4Sy5rMoZpkRSGKH5I5y2Qx38ukVXWO4lN8QJv5j4MNpSPC
fcFqvFSsinz4AvlaB1ZPRhwki1/RHkUtZDKvkNe5ej8aNp0JnwMqEXZaeKmeXvRPLI0rBFPU
p8jmystwjd0x5cCjnoh7pqhqyXyeqdsVteIw3VY0nHaUj7JoOIIGdiqVSaJAYr58peOxVNfW
6B6S5z+hlGCACPhtWpVrFOv8s2H8ASYqEnDxbUaFDVfRKekrI4ioPqYt52ArrPcXL18WrDs/
FMxfNByVJbqLH2YfD6g+OP7cb7unBgugRbR984H+XzWKbtlYnIC0ITQR/D3ZfsxCbOtiXU7f
uO5hod5IzOYHGGRYOrOG8YTcGWLjFVvDlgj7oDrfc+STwfnYkWwFy2+WfQ3ZGAJfn8oTXBY2
BJOp6nZ7cUGjCtFY+PpfPggCWK1Uv1s/v1RjJ9fi4cMltJ5jxUSnOK9mQYvDFySedNkrOopL
5aMN5ewGpdaXKz4BXljxFPZcZzxHC86MZsYTN7k8eM6QmOIgl6O2Ogfey54o0Wk18mmtbGfo
vGJl209XgibzmE1HQXitedD2qpiloYNPQynm6ETdNdptS6YnbwY2fKGB4fo+dyBtDqVr5J+B
Ba8GRHM7/MHb7gLVAUdtPPRVAAXAmj3yoCAUM1prnzSfJv1xJofejigDImlO7xUvnOevVMiu
1GbRB0Hrw6KibBvrrH81T1+hWfEia/ZS7VR5RwZnQPjsVnQh6LBS7UcixmwASpXpiz1Uk/zM
sQkrJ9DY/d1iOHM19UzZemUBH9rBA/cQtei1rrhRMBbhoSrrHznx00DwZTbgNeAL8w+f/lYU
dwsPV2nyV1bM5zYdlTnvwhq74rUM9hClJno+DSSNfdretVViZ8/jhYao8vM3pKEw9P/KwkCw
52qCGhXvHKoS+Mg6C8ramXKEoQZ9imCfwYD8mQHN7zp65rhHnNLzRB0BsvAvQ0h+W4iwQm+g
P5mwKKgzvKzHSnlX03IkgXb+W1aDpydlGmDFr/vIIroJrz5dpk3M6eaTwABNqm2cfHRmnZVa
RGjuqeK4zkLjlz4tSg7VvK8BARV9hXg3g0fHd/QetY1wZHLg5xQ6jK7FiR4gcL2EYZHxOm7A
gS6/5Ik7gUxOaICrgqAinjEcb05rm+8zflKSwapuTAjA

/
SHOW ERRORS;
create or replace package body XDB.DBMS_XMLSTORAGE_MANAGE wrapped 
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
1d6b9 5234
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
uXQpT3O1gbX7DpSN7Q==

/
SHOW ERRORS;
grant execute on XDB.DBMS_XMLSTORAGE_MANAGE to public;
@?/rdbms/admin/sqlsessend.sql
