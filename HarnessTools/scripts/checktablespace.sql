
select df.tablespace_name "Tablespace",
totalusedspace "Used MB",
(df.totalspace - tu.totalusedspace) "Free MB",
df.totalspace "Total MB",
round(100 * ( (df.totalspace - tu.totalusedspace)/ df.totalspace))
"Pct. Free"
from
(select tablespace_name,
round(sum(bytes) / 1048576) TotalSpace
from dba_data_files 
group by tablespace_name) df,
(select round(sum(bytes)/(1024*1024)) totalusedspace, tablespace_name
from dba_segments 
group by tablespace_name) tu
where df.tablespace_name = tu.tablespace_name and df.totalspace <>0 
order by 1
/

select inst_id, tablespace_name, total_blocks, used_blocks, free_blocks  from gv$sort_segment
/
