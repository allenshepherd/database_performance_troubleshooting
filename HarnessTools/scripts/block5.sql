col ALTER_COMMAND for a150 trunc
select 'ALTER SYSTEM KILL SESSION ''' || s1.sid || ', ' || s1.serial# || ', @' || s1.inst_id || ''' IMMEDIATE /*User '||s1.schemaname ||' from service '|| s1.service_name||'.*/;' Alter_Command
    FROM  gv$session s1
    WHERE 
    s1.SCHEMANAME='&1' AND
    s1.status='INACIVE' 
    AND s1.LAST_CALL_ET>(*60*60)
/


