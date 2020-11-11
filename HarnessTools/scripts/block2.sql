col BLOCKING_SESSIONS_BY_TIME for a190
SELECT 
   'SID ' || l1.sid || ' on instance #' || l1.inst_id || ' is blocking SID ' || l2.sid ||' on instance #' || l2.inst_id  || ' for '|| round((l2.ctime/60),2) || ' minutes with a lock type of "'||decode(l1.type,'TM','TM - DML enqueue','TX','TX - Transaction enqueue','UL','UL - User supplied','unknown') ||'" in current mode of "'|| decode(l1.lmode,0,'none',1,'NULL',2,'row-S (SS)',3,'row-X (SX)',4,'share (S)',5,'S/Row-X (SSX)',6,'exclusive (X)','unknown')||'"' BLOCKING_SESSIONS_BY_TIME
FROM 
  gv$lock l1, gv$lock l2
WHERE
   l1.block = 1 AND
   l2.request > 0 AND
   l1.id1 = l2.id1 AND
   l1.id2 = l2.id2
/
