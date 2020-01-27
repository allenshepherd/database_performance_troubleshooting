select bytes chunk_size, count(*) no_of_chunks
from
(
select power(10,trunc(ln(ksmchsiz)/ln(10))) || ' to ' || (power(10,trunc(  (ln(ksmchsiz)/ln(10))+1))-1) bytes
  from x$ksmsp
 where ksmchcls != 'perm'
)
 group by bytes
 order by chunk_size
/
