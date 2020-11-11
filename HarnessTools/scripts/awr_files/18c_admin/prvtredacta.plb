@@?/rdbms/admin/sqlsessstart.sql
DECLARE
  blobval BLOB;
  clobval CLOB;
  nclobval NCLOB;
  fpval    NUMBER;
BEGIN
  DBMS_LOB.CREATETEMPORARY(blobval,TRUE);
  DBMS_LOB.CREATETEMPORARY(clobval,TRUE);
  DBMS_LOB.CREATETEMPORARY(nclobval,TRUE);

  DBMS_LOB.WRITE(blobval, 10, 1, UTL_RAW.CAST_TO_RAW('[redacted]'));
  DBMS_LOB.WRITE(clobval, 10, 1, '[redacted]');
  DBMS_LOB.WRITE(nclobval, 10, 1, N'[redacted]');
  
  select fpver into fpval from sys.radm_fptm_lob$;
  
  if fpval = 0 then
    update sys.radm_fptm_lob$
    set blobcol=blobval,
        clobcol=clobval,
        nclobcol=nclobval,
        fpver=1
    where fpver=0;

    commit;
  end if;

  DBMS_LOB.FREETEMPORARY(blobval);
  DBMS_LOB.FREETEMPORARY(clobval);
  DBMS_LOB.FREETEMPORARY(nclobval);
EXCEPTION
  when too_many_rows then
    delete from sys.radm_fptm_lob$
    where fpver < 2;

    insert into sys.radm_fptm_lob$ 
    values (blobval,
            clobval,
            nclobval,
            1);
    commit;
    
    DBMS_LOB.FREETEMPORARY(blobval);
    DBMS_LOB.FREETEMPORARY(clobval);
    DBMS_LOB.FREETEMPORARY(nclobval);
  when no_data_found then
    insert into sys.radm_fptm_lob$ 
    values (blobval,
            clobval,
            nclobval,
            1);
    commit;
    DBMS_LOB.FREETEMPORARY(blobval);
    DBMS_LOB.FREETEMPORARY(clobval);
    DBMS_LOB.FREETEMPORARY(nclobval);
END;
/
CREATE OR REPLACE LIBRARY dbms_redact_lib wrapped 
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
Q7rRMxW3WwEtyoW5JnbNK7R/NR4wg04I9Z7AdBjDWqGXYkqW8i6hWdH0cvpZCee9nrLLUjLM
pXQr58tSdAj1Ycmmpnu6skg=

/
CREATE OR REPLACE PACKAGE dbms_redact_int wrapped 
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
16a5 3f9
dR2HptA5OrRiUT53FBt+qBF9Dewwg81UDNDrfC+LaA/u71rn+4ArdnYXg+x7YUPGuZ+Wb0t2
V937M7WZ2vrfUrZJ0Uyzyk2fKKTXwUKqM8Pgwmr9Z/5PvHP1JLxoquTkj7w/qmdUZCvnYh5y
tQxs54kr+xUBKRpwiYrtBGvBUc6m21cuYWk49c5pSuItZrrYGTwjlroAStVnEeZkrdq6ZDYu
jo1Anj/YsWaa7YBoZTwO43BhBl6wrg7coA1hbjZMFzPTZrpEQ1TNpEM53w7h5VbFzY6JdXXq
Hu6909W7LftjgooVO8MOgYyc+nThxkRtJbilruc5zqb+sP0BazU+u5s70hyIu8ty13BtCcqI
G4+gzIkgwMwJEScj7l/JpS4280ZUY6m2dak0SsqU35EFASNhSfxO8AODHtyRvmTBEVhfazw/
Ug2XBK8JvVh/1ljvda03xieh6pbXrkcfIPN0AvStQa/YOih0BXz/rW4NcTNY7NKqkFz/RT3c
6UzIr03Lv3LAoVabYb4WnP9T99n2kzo865jUupdjKkhiibvUPuGgyaIgDjxun/BYkHTFdf6G
fZ9LqhUOVrW6FXuGYB7mYcLbOXHKQ6cOHaix3PwbvWgrAk8MliP1GvcO7knsPySY9htL3vdV
IbEloXE+fnUHq7Tuq97TH8DHpcLURL3mxz9h3hBGy61iN4Ytr8icia8EH/10U4mv5+qxPhiW
WouGgkUH5VJAKw6y4l10udRo6QgyU/0nYYHq9UlXdj3Q9GYzglqLcxQddvoVCARUsaj7iobc
pA4RJ+OsafCnK5gfoYJ/HVKiNGoq3uQ1gmpD7ev4sZtU+IelCUH6C9kitU51kMZ3QacTNKG1
0bMonZgCofozc7SQ8zgm+lWF1PLsmE/Xuwwmy9rRr2ar1ZcKOYZA2uZlCq0oJW6xEf9kIACQ
Xhwy7eNA9lnccH3e7/0pQYnce5IbhTrBpDipPVo1gSyyeomZMDG1iMr1wT0DD7SgNNI=

/
show errors;
CREATE OR REPLACE PACKAGE BODY dbms_redact_int wrapped 
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
3900 a07
KgWNnDMsu3vTcG2DOJLX49Zubycwg82jDF5oVy8Zgp3mjV2mul4myIPrCcdQhaul1AvaYXZ1
cXEUyOXDWubzwLRzgQUjtDzrPKVuVd37yRq5PIb4vCvZ6NtdsiIaEcwU9vUz7h7QM/zkitKG
Mvg6BSoVgcuDNU3Ynua36FHnSaG6b5PyPFBfUEgtzm3TPDxd4+J8/Koldu1qlK0VPfY4eF6f
rYfMRmCKkYoRmEY8GvIMp2++ebB6tW6MNPplKekY2JNDC7OANN929jFdRgVhfkwJC9jp7IYn
VeitjAegBof64FzElC58OJacSEbT6nwLYAp74HEjCSug4piTOb/IizD3iAVQcmQWZRgSv+P/
5UDyZJ7ozwkVXwRZSdBVNUNcs2VqRmEqCiXkfDwKVvyJ3tkIuY+87gkvJcOU172kUkIBU9h8
74Bq3K7A5tsXeV7WzYXRHp957Daxytj+27ugYNJGu9GnC6gUzpKK2SQJdbAXF3LDgKfRxedR
TrAC3z0SbsLvop4Ej0aoPd9p3rAT2eJlKf3J+8wfFI2FradhDnqn+zgSVh02M1Q5XXYgWIuh
8nzVxcOWhyg8+yk8bSQbeehm7AkzRyEWIyBoqeMTlflwtsjYF4oOU+0LW6KkSh6XqlbiYhIL
/tYmOFZRkJTP81VHf2+z3KvuDZgplf14uNgCgV0c8hlTN+9W2Im0U/khfW0erkZ7ORJb2mA7
98PpiMx+ojyr92NAeW+ct3LivA9IQYkgkLcLgsB+Ip/NprYKpkdwUbrM4eAVioJm5d0GbNiR
OnkYFc1iu9TyJg/tfpg9DTheZIBW85bicmQcqCx5OPAEd23+epldjowJMOV7T8WXsBibnQnM
7D0M8TzkFSFcndt30X8y2bJt+nIk3CRxbrUPHqEdL0I3kNhJjBj6TfKbychuqhKOogal44QL
q20BvqzYCZ33fBpCMUufk8PIEc+mIVkev0Vj/tpuKncHdCw56CW8ax79C5spmx6x6ywPuR+O
xx/PMAT4j398vxULcLnpdlkuvKRna1QaPz/4bC0nlzaCg5sMT6NJlsLbpsBsmEIDo906RC5M
I/FihXN/SB+4eFTJRMmXx1Ni4zzMnRoRMP+UStZPfrKSUlD4k54kGaxQd3qUD3vq/v+OpdnX
+zq8Rjkhc0f7vg8RZ2quj5HY0MRZZNA97JylCykYPHRkl72dCzMZVJqPSTbdnVH+6dxi5MLg
OP+3xFlyt1c/FJeWeKREy/uAVdCwuNpidaHuwUMxsE8fH2VsX2w2SaRX+t3yRIIMXspeMdN9
/lxRYbzbwWcPhQ+xWOR2fdI5SzYXwavqyEEEp+NuBEqFen9W+9p/djf4izirvk5L6R70OL2O
4KWnZ2R4rGxclDceVnDz4+Dnsf2V8WHQHOh2qJ4hkQJLmbTOk9PzB6LbLZG58IYa4XhKerVf
78jDiQuMxSXuUl96+W6LCNorj97/20RnbeKa5hAXzEe2NLIsXfAkcoS39MJzMDI/IxAZh0Ga
gOJ2W93M/FemSjpXpv3s+ER8GPcTKoB/q0GkpUlbheqXAAhXznEjrNS4jySzzrPe2O3D8GwI
FjW5uddgohtdZJPE1mf+9JwCBNHZfjuEPMKsnd00T8Rk6yCEv9Qz2bdtHI9jVDYy3JaWlvk5
uaAsnZrZkO+phOMv+1es5AiM009kYPp6MjAAuLzT5LsZWmuEg5ih1G2W3zFd72oYwuj8QQ7n
3OOLP8MxqMbKVGJej08bW1V+opbXmiftIBOss6IENbusHOg6SsnPZKqSWPW1Wqn2VMsSvc3P
K1EgtLdYzg/X7dYZTFMhVtcJYT+99tHApoIMmutV0aXYmhiIlxE/hUpvEJpB4dtBwy6CDmS0
tMGmHdWSAIcrlfLPQjdK0BYalhzJGSDf/7bbmkwiT7v+af5TJgQ01ov0U/IEIaazdVZpWfIq
hWJ5lQmiQGC/rvOaZBZaDVxUDhmyGjyWAhZf5aZc2malRnKWGpPn6wZXW8VH2sMwtrsKDFl9
z0+qnEuhig/vhRubhiybl7Qd7weyCabTOK43HIKc4SO8X2OpdO0ujlArUv6OUMxb3ThWRDSD
W/t6z0HhHOeCu2frxOpAszd28uyryPUPeCTOHlSa1SBtYjO94LOEsA4Z/+8VQp6wcDsNKIl9
BvuSgzrJ4u22QKuEWJcgTJITqHnVe1ukkwkhrQVzEK7mCq4Mj7rukT3CXQI5LTlNplOOdfaY
JmPQ9d5Gbozq46SzuX5Zx9zercB4yN3+OllgAiRoEK4x2bFmkOJrxwQDtVE1Y5sE1/y5+hM0
USgL+9dd506mMd9xgi+Ip9gWpMotsKmxdFW1AuOoAEW6PBIY+sjXVdWMcsK6UXVB2Sfgl6E/
HiZNeYhdjxP6X34bgrPl0040DOi8jJGE8/E1RsUjZGBl6GCtRAyN0S7UXKGJxZVaTqmrSMTp
jOYygKDcG/HMcUKRTCRN3ACSm97ZsLfwlcBtghv7mx3CxFehYOD3165sy58vZwRf/h7EEA7/
ryC14TI/W28=

/
show errors;
CREATE OR REPLACE PACKAGE BODY dbms_redact wrapped 
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
33fb 800
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
HV4K

/
show errors;
@?/rdbms/admin/sqlsessend.sql
