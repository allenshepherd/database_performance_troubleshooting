PROMPT ______________________________________________________________________________________________________
PROMPT SGA INCREASE/DECREASE GUIDE - The below query will give you helpful information regarding any memory 
PROMPT  changes that you may want to consider regarding a given database.
PROMPT ______________________________________________________________________________________________________
 select inst_id, sga_size,
  to_char((sga_size_factor-1)*100)||'% increase' sga_size_factor,
  to_char((1-estd_db_time_factor)*100)||'% improvement' estd_db_time_factor
  from gv$sga_target_advice
 order by 1,sga_size asc
/
