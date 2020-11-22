clear screen
PROMPT ___________________________________________SHEPHERD'S__SUITE________________________________________________________________
PROMPT  A collection of helpful PL/SQLs that provide information regarding 
PROMPT
PROMPT   -                        CONNECTIVITY TOOLS
PROMPT   ------------------------------------------------------------------------

PROMPT   *   @blocks  - Use this to IDENTIFY any blocking sessions across all instances (note, it doesnt kill for you) 
PROMPT   *   @sessions  - Use this to identify which sessions are connected and where
PROMPT   ------------------------------------------------------------------------

PROMPT   -                        AWR/SQL STATISTICS TOOLS

PROMPT   ------------------------------------------------------------------------

PROMPT   *  @awr_top10 - Use this to perform a quick check across a given time period for top performing queries
PROMPT   *  @awr_topevents - Use this to grab top wait events for a given time frame
PROMPT   *  @get_time_stats_sql_id - Use this to see specifics regarding a specific SQL
PROMPT   *  @get_bind - Use this to get bind values for a particular sql
PROMPT   *  @gather_table_stats - Use this query to get table statistics 
PROMPT   ------------------------------------------------------------------------

PROMPT   -                        DATAGUARD/REPLICATION AND RMAN TOOLS
PROMPT   ------------------------------------------------------------------------

PROMPT   *   @dgsync    - Use this to see if standby is in sync/diagnosis
PROMPT   *   @ggsync    - Use this to see if golen gate is in sync/diagnosis
PROMPT   *   @ckrman    - Use this to see what is running for RMAN and how long/much is remaining
PROMPT   ------------------------------------------------------------------------

PROMPT   -                        TABLESPACE/TABLE, INDEX, AND USER TOOLS
PROMPT   ------------------------------------------------------------------------

PROMPT   *   @checktablespace     - Use this to see current utilization of tablespace
PROMPT   *   @checktablefrag      - Use this to see if golen gate is in sync/diagnosis
PROMPT   *   @hstats              - Use this to see a specific table specific (author - Hotsos)
--PROMPT   *   @user_roles_privs    - Use this to see a privileges related to users and roles
PROMPT   ------------------------------------------------------------------------

PROMPT   -                        CONFIGURATION TOOLS
PROMPT   ------------------------------------------------------------------------

PROMPT   *   @redolog_advisor    - Use this to make check/changes to redo_log configs
PROMPT   *   @sga_advisor    - Use this to see what are the effects of changes to SGA
PROMPT   ------------------------------------------------------------------------

PROMPT   -                        I/O AND STORAGE TOOLS

PROMPT   ------------------------------------------------------------------------

PROMPT   *   @check_io_speed    - Use this to check current I/O disk performance
PROMPT   *   @check_past_io    - Use this to see how much IO this DB has performed across time frame
PROMPT   *   @check_storage ????    - Use this to check current I/O disk performance
PROMPT   ------------------------------------------------------------------------

PROMPT ___________________________________________SHEPHERD'S__SUITE________________________________________________________________

PROMPT ____________________________________________________________________________________________________________________________
