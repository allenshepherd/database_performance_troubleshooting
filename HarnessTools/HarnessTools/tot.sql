select DB_NAME,CATALOG,OS_USER,BKP_TYPE,DB_ROLE,SERVER_NAME,RETCODE,START_TIME,
FINISH_TIME,SCHEDULER, PLATFORM, nvl(DD_HOST,'UNKNOWN')  from rman11r2.rman_backup_job_exit_status order by START_TIME
/
