set markup html on spool on entmap off -
head '-
        <style type="text/css"> - 
  body {font:12pt Arial,Helvetica,sans-serif; color:black; background:C0BDD4;} -
  p {   font:12pt Arial,Helvetica,sans-serif; color:black; background:White;} -
        table,tr,td {font:10pt Arial,Helvetica,sans-serif; color:Black; background:#f7f7e7; -
        padding:0px 0px 0px 0px; margin:0px 0px 0px 0px; white-space:nowrap;} -
  th {  font:bold 12pt Arial,Helvetica,sans-serif; color:#336699; background:#cccc99; -
        padding:0px 0px 0px 0px;} -
  h1 {  font:15pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; -
        border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} -
  h2 {  font:bold 13pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; -
        margin-top:4pt; margin-bottom:0pt;} -
  a  {  font:11pt Arial,Helvetica,sans-serif; color:#663300; -
        background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
</style>' -
        body 'text=black bgcolor=C0BDD4 align=center' -
        table 'align=center width=99% border=3 bordercolor=black bgcolor=C0BDD4'-

spool /Users/z043267/artifactory.html

Set lines 220
Set pages 2000

col PLAN_HASH_VALUE for 9999999999999

--@get_time_stats_sql_id.sql
--@compare_workloads
--@iotest
@&1
PROMPT **************************************************************************************************************************************************
PROMPT **************************************************************************************************************************************************

set markup html off
spool off
