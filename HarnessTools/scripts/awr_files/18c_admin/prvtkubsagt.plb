@@?/rdbms/admin/sqlsessstart.sql
DECLARE
  pfid     NUMBER := 0;
  libfnam  VARCHAR2(128);
  pathnam  VARCHAR2(128) := '$ORACLE_HOME/lib/';
  dbcmp    VARCHAR2(32);
BEGIN
  
  
  
  SELECT platform_id INTO pfid FROM v$database;
  CASE
    
    WHEN pfid IN (7,8,12) THEN
      libfnam := 'orakubsagt' || '.dll';
    
    WHEN pfid IN (3,4,5) THEN
      libfnam := 'libkubsagt' || '.sl';
    
    ELSE
      libfnam := 'libkubsagt' || '.so';
  END CASE;

  EXECUTE IMMEDIATE ('CREATE OR REPLACE LIBRARY KUBSAGT_LIB AS '''
                     || pathnam || libfnam || '''');
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
/
CREATE OR REPLACE PACKAGE SYS.KUBSAGT wrapped 
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
a0c 270
KAscP7WZOdqyof2x2zEwNOAIywYwg9enAMBqyi8CXh6OifpZ7FMyDayU1OYOk2+u8dT+nenI
kZXf8ZuGV9x9R3htMwCP7m+RsqvppNmm7ESiGQRskRTmxvgEyDZGBgPM6UkxMEmOOaHo2+2g
InBSD+eoeaDUPVH91PSkyGimOxy28g9oVwGAXeBeZjLdU5e6D0rdgG8BklWoFCesuaEkJOLq
ehRahfduEXm0/cZN9zyVbAvlgO+/LnNazAEyV8z1RgUXafFPwV0n4R9ixZZJFkv+Q2FJXqLn
LoxGVE2eZExMQAkfaifr5dVI4y+aZRnEfdGfAF7SmScY1V8mfaQJWrZPKWGH0GXApCWYlxEB
EaONb/VQj2isWcqzTenDk1CaUwoxvG4skh57c7k4AlZ4gggDuJHJY1Zu9LqQB/SrRHQCVyR0
JsYC2lD3jOjiYQieBzq3K9pU1OXmwnW71zg/4+MCyoWhZQtb3wZeYTxXnaNotQU6exfiUkCW
y3WMmACFigBGvxwk1pjkJQZxs2fWQpWKuh0E4kg8D7r+bwdYabUT2Nl6+fLjqn4BmdsqvHyJ
x9IPNu4VC7cAuQ8wUSCcTX13zrEgEP45xumO4g==

/
GRANT EXECUTE ON SYS.KUBSAGT TO PUBLIC;
CREATE OR REPLACE PACKAGE BODY SYS.KUBSAGT wrapped 
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
1b11 4bc
+jNmHR9o9z/eAlKJk8j81699W4Qwg0N1Ll4FfC9AEv9kULisWHGFjbdW2UrjVgGRrbJxBHBo
p95bexRztY3NU4cQzOchFGyworvioDwiCjAqxpFAxxjTWIcOk42JV7HnnIwzt1ysERtE8t6h
jgx9lO7CGoyG8+ZG6m70iCciWQ5EK5EYPZF+FIKVwxo0nKJcFMMq4bZYXWUpRJPeiXWa8KKN
xZc0XIMIP7yz9POUPY3TEf/Z1Rsh1yarLdOzY+jycEpXb0I9ejZ/YeEfjqQQtTIDRflF3B49
zYZVLi4/etj874zApxbY+XopjTpVOVkCSGZ7GXpcA30X6LDjWgMZCRNPx9hHR8mVwhLk3ATa
2swnlaIiMzNJATb2JmhV90aymAsg/aWpBcl6R+rR1lFDRL/155lKYNeZNF3DU4zJhaJX+bfQ
s/qT5/du/Bvo6jXxCDQ2yHQGOtOwopaENkOebRjrw9OuxQ2J+kIKzvFRUxYJRmaHQwGGwVob
GEjfmh5VBHIeKpi1m7hQif5CxHp+yqlbRq8KmROOj0StCDR+46kfooVOwjrCNDlF4YcvACA7
yzSFowCN3ZllKUIx3RyKMWbBw34QS1fp+LlE1ao8/lu6Oyw3YQIxVIKleI9TR/hLTKlZYGWn
sFk6h8kVpxjdRqM45pOrjWVKTh80o61EOLVr+brbH4GG/Lk4DxYH9Jt9AwPnNHDLr2YryWut
hQqUtoXffAe+HEc47DsjoE61/JcjQlW76G87i++M7FlqkIDkfdCUgORGqtqSAyMQ+HnqYoDI
+FTxC61Ka9KOoS16WybjiFtY56g3cRwJ2C3W1jHX58vwZXowhqOFiZ+Gyp3wdcOTYI29r60W
eIZMli9Chr+UtvnhThhBe8eBhrd9OOTUfOixHh7WkVJalOXxXhfbwnabyXJ01IQzr9GmEWTi
Xzf72tF8HKBPoopJmOJ6xKV1cCMev7jI7WC4JyDrEL4gfUx70pVuQG57DZGcd5MKtkWdTEm8
OthV2WVQg7s0pBGZiVWaOyhhH6mhgQohtBAHml6K5BKVg7YOc6hyYYaouNPSDjAcpBZqOTHO
psfn0P7n35MHPJL1lPlu0fgp5t98/IjtUFe9JhKzfOlIHW6Z1BdxtrnqwT1BGxL1A6XxA/sJ
Ay0NNZLK7Wifv9UFVUBIv4Q6qjITwxoQ9G4QkrJfWsem

/
@?/rdbms/admin/sqlsessend.sql
