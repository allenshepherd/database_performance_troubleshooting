col BLOCKING_INFO for a150 trunc
SELECT 
w.sid, w.id1 BLOCK_ID, '     '||t.owner||'.'||t.object_name||' which is a '||t.OBJECT_TYPE BLOCKING_INFO FROM gv$lock w, dba_objects t WHERE w.TYPE='TM' and t.object_id=w.id1
and w.sid in (SELECT s.sid FROM gv$session s WHERE blocking_session IS NOT NULL)
/

col ALTER_COMMAND for a120 trunc
select 'ALTER SYSTEM KILL SESSION ''' || s1.sid || ', ' || s1.serial# || ', @' || s1.inst_id || ''' IMMEDIATE /*blocking a total of '|| count(*)||' sessions.*/;' Alter_Command
    FROM gv$lock l1, gv$session s1, gv$lock l2, gv$session s2
    WHERE s1.sid=l1.sid AND s2.sid=l2.sid
    AND l1.BLOCK=1 AND l2.request > 0
    AND l1.id1 = l2.id1
    AND l1.id2 = l2.id2
    group by s1.sid,s1.serial# ,s1.inst_id
/

set pages 0 
set feedback off

SELECT
     'SID ' || l1.sid || ' on instance #' || l1.inst_id ||' is currently '||decode(state, 'WAITING','Not Working','Working') ||' while blocking others with a'|| decode(s1.SQL_ID,NULL, ' a previous query hash of '||s1.PREV_SQL_ID, ' current query hash of '||s1.SQL_ID) ||' with a current wait event of '''||s1.WAIT_CLASS||''' and a wait time of '||decode(s1.TIME_REMAINING_MICRO,-1, 'INDEFINITE WAIT',s1.TIME_REMAINING_MICRO) "BLOCKING_SESSIONS_BY_TIME"
  FROM
    gv$lock l1, 
    gv$lock l2, 
    gv$session s1
  WHERE
     l1.inst_id=s1.inst_id AND
      l1.sid=s1.sid and
     l1.block = 1 AND
     l2.request > 0 AND
     l1.id1 = l2.id1 AND
     l1.id2 = l2.id2
/

prompt -

prompt -

PROMPT -.  
PROMPT Kill Sessions if you must. I would suggest by killing the single session having the most  sessions blocked and rechecking to see if some/all blocks have cleared up.
PROMPT -  Finally, if you find that these blocks have only been in around for a little while, then I would not suggest killing them. Engage app team to inform them
PROMPT -  of there row locking characteristics.
PROMPT -. 
PROMPT -. 

set feedback on
set lines 220 pages 50000
