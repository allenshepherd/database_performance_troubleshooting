@@?/rdbms/admin/sqlsessstart.sql
CREATE OR REPLACE PROCEDURE LBACSYS.lbac_frame_grant wrapped 
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
7
418 144
E0h61aZlNQiArN6CuLGdWcB/FEAwgzvxcp6sZy/U2viOx048mTCjMvECd6Uod96TMgoCLgu/
mSP428ovRRqZx+w4P8+az8cWm+eGRWdpsiAxk04TcB/XEpmg0uZZEYtCpgvu84xF5g7eGH9s
lEoApbeskT2/pxdLKKHDQZfNRl40857ldssyU7D3LNjufGzwMqaY9johgv9m1p9w4npKTflS
tqNFvLTnSGRxZIbXGnOi0doZu1m1Fy5CRS17hUr0QXjy9ctlfJbrKnaKfA2TdvFDFjhfdiNb
URyf+YccyQiAmuLKPsLe2rQ0++6hyvg=

/
BEGIN
  LBACSYS.lbac_frame_grant;
END;
/
CREATE OR REPLACE PROCEDURE LBACSYS.sa_policy_grant wrapped 
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
7
f91 264
+ErEPTjVjRhWjlj9G13sAPVQdcYwgw081xjWfC+mjwD+PsAeeQ8OSQpr5ytto7RB5ndwHbNa
05m8c+hFBSwFCRHTL6+dcqhqR5GcGyJ0Mz4204xKgqPLTW9TXMpHb/ZTvYaV4aYQ3Sx9u8fn
Fc1vOWuchBAoVngmH8GcF6F0UQ3BFweKuvbxWqFCmZs2ijMeFtKcCtBuh3+CjM39ZhH0xRlQ
b9VmzbgJKQPg1nn+Twppf1cYdxzX56eegUS7BZdKTXIqNXQf2wmD9jX/+szjk+Pxgq2VM2Ye
u21s1vPSTroDxfUt5FwskDQpbF0Svh9s/Ykb88/9zQxU7qzzvzRW0BpSBPlTaDMxntUX3+9J
H376E8uZPcgrMcb2r/j/821KiedWl4ZwVbts8yX0/MVtjM0hjYYsdkPHo4h4AYKDkA5J+PVJ
Uxk8IUhwgH+GvFGeCNwpTIkBc3rUGhXltbQuax9o5Qu5IoOB12xHtM927KHQTnJHEmWlR90x
FmVq4kzZR1i/FoLNg/BWV/6G23Q0RyjH1IMlJJAvb1q6oXXXppm0YzerM1+YyX7JAPUPasLP
cdEEW8pOUNGznFshP+2SkkQJU7iG

/
BEGIN
  LBACSYS.sa_policy_grant;
END;
/
CREATE OR REPLACE PUBLIC SYNONYM to_data_label
                     FOR LBACSYS.to_numeric_data_label;
CREATE OR REPLACE PUBLIC SYNONYM char_to_label
                     FOR LBACSYS.to_numeric_label;
CREATE OR REPLACE PUBLIC SYNONYM tagseq_to_char
                     FOR LBACSYS.numeric_label_to_char;
CREATE OR REPLACE PUBLIC SYNONYM dominates FOR LBACSYS.numeric_dominates;
CREATE OR REPLACE PUBLIC SYNONYM strictly_dominates FOR 
                         LBACSYS.numeric_strictly_dominates;
CREATE OR REPLACE PUBLIC SYNONYM dominated_by FOR LBACSYS.numeric_dominated_by;
CREATE OR REPLACE PUBLIC SYNONYM strictly_dominated_by FOR 
                         LBACSYS.numeric_strictly_dominated_by;
CREATE OR REPLACE PUBLIC SYNONYM least_ubound FOR LBACSYS.numeric_least_ubound;
CREATE OR REPLACE PUBLIC SYNONYM merge_label FOR LBACSYS.numeric_merge_label;
CREATE OR REPLACE PUBLIC SYNONYM greatest_lbound
                     FOR LBACSYS.numeric_greatest_lbound;
CREATE OR REPLACE PUBLIC SYNONYM dom FOR LBACSYS.numeric_dominates;
CREATE OR REPLACE PUBLIC SYNONYM s_dom FOR  LBACSYS.numeric_strictly_dominates;
CREATE OR REPLACE PUBLIC SYNONYM dom_by FOR LBACSYS.numeric_dominated_by;
CREATE OR REPLACE PUBLIC SYNONYM s_dom_by
                     FOR LBACSYS.numeric_strictly_dominated_by;
CREATE OR REPLACE PUBLIC SYNONYM lubd FOR LBACSYS.numeric_least_ubound;
CREATE OR REPLACE PUBLIC SYNONYM glbd FOR LBACSYS.numeric_greatest_lbound;
CREATE OR REPLACE PUBLIC SYNONYM ols_dominates FOR LBACSYS.numeric_dominates;
CREATE OR REPLACE PUBLIC SYNONYM ols_strictly_dominates FOR
                         LBACSYS.numeric_strictly_dominates;
CREATE OR REPLACE PUBLIC SYNONYM ols_dominated_by
                     FOR LBACSYS.numeric_dominated_by;
CREATE OR REPLACE PUBLIC SYNONYM ols_strictly_dominated_by FOR 
                         LBACSYS.numeric_strictly_dominated_by;
CREATE OR REPLACE PUBLIC SYNONYM ols_dom FOR LBACSYS.numeric_dominates;
CREATE OR REPLACE PUBLIC SYNONYM ols_s_dom
                     FOR LBACSYS.numeric_strictly_dominates;
CREATE OR REPLACE PUBLIC SYNONYM ols_dom_by FOR LBACSYS.numeric_dominated_by;
CREATE OR REPLACE PUBLIC SYNONYM ols_s_dom_by
                     FOR LBACSYS.numeric_strictly_dominated_by;
CREATE OR REPLACE PUBLIC SYNONYM ols_least_ubound
                     FOR LBACSYS.numeric_least_ubound;
CREATE OR REPLACE PUBLIC SYNONYM ols_greatest_lbound
                     FOR LBACSYS.numeric_greatest_lbound;
CREATE OR REPLACE PUBLIC SYNONYM ols_lubd FOR LBACSYS.numeric_least_ubound;
CREATE OR REPLACE PUBLIC SYNONYM ols_glbd FOR LBACSYS.numeric_greatest_lbound;
CREATE OR REPLACE PUBLIC SYNONYM ols_label_dominates
                     FOR LBACSYS.ols_label_dominates;
DECLARE
  
  lbacsys_schema number;
BEGIN
  SELECT user# INTO lbacsys_schema FROM sys.user$ WHERE name = 'LBACSYS';





  BEGIN
    INSERT INTO sys.objauth$ (obj#, grantor#, grantee#, privilege#, sequence#)
      VALUES
      ( (SELECT obj# FROM sys.obj$ WHERE name = 'LBAC_SERVICES'
         AND owner# = lbacsys_schema AND type# = 9), lbacsys_schema, 0, 12,
        sys.object_grant.nextval );
  EXCEPTION
    WHEN OTHERS THEN
    IF SQLCODE IN (-00001) THEN NULL;   
    ELSE RAISE;
    END IF;
  END;

  BEGIN
    INSERT INTO sys.objauth$ (obj#, grantor#, grantee#, privilege#, sequence#)
      VALUES
      ( (SELECT obj# FROM sys.obj$ WHERE name = 'LBAC_STANDARD'
         AND owner# = lbacsys_schema AND type# = 9), lbacsys_schema, 0, 12,
        sys.object_grant.nextval );
  EXCEPTION
    WHEN OTHERS THEN
    IF SQLCODE IN (-00001) THEN NULL;   
    ELSE RAISE;
    END IF;
  END;
END;
/
COMMIT;
@?/rdbms/admin/sqlsessend.sql
