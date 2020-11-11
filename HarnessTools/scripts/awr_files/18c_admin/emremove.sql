Rem
Rem $Header: rdbms/admin/emremove.sql /main/5 2017/05/28 22:46:05 stanaya Exp $
Rem
Rem emremove.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem emremove.sql - This script removes EM Schema from RDBMS
Rem
Rem    DESCRIPTION
Rem This script will drop the Oracle Enterprise Manager related schemas and objects.
Rem This script might take few minutes to complete; it has 6 phases to complete the process.
Rem The script may take longer if you have SYSMAN and related sessions are active 
Rem from Oracle Enterprise Manager(OEM) application.
Rem
Rem    NOTES
Rem Please do following two steps  before running this script 
Rem set serveroutput on
Rem set echo on
Rem 
Rem 
Rem 
Rem    RECOMMENDATIONS
Rem 
Rem You are recommended to shutdown DB Control application immediately before running this 
Rem OEM repository removal script.
Rem To shutdown DB Control application, you need to run emctl stop dbconsole
Rem 
Rem 
Rem Steps to be performed manually (after this script is run)
Rem 
Rem 
Rem Please note that you need to remove the DB Control Configuration Files 
Rem manually to remove DB Control completly; remove the following
Rem directories from your filesystem
Rem <ORACLE_HOME>/<hostname_sid>
Rem <ORACLE_HOME>/oc4j/j2ee/OC4J_DBConsole_<hostname>_<sid>
Rem  
Rem If the dbcontrol is upgraded from lower version, for example, from 10.2.0.3 to 10.2.0.4, 
Rem then the following directory also needs to be removed from the file system.
Rem <ORACLE_HOME>/<hostname_sid>.upgrade
Rem <ORACLE_HOME>/oc4j/j2ee/OC4J_DBConsole_<hostname>_<sid>.upgrade
Rem 
Rem On Microsoft platforms, also delete the DB Console service, generally with name 
Rem OracleDBConsole<sid>
Rem 
Rem #############################################################################################
Rem  
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/emremove.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/emremove.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    spramani    01/17/17 - fix for 24518751
Rem    spramani    08/03/16 - fix # 24330891
Rem    spramani    07/20/12 - more fix
Rem    spramani    12/21/11 - Created
Rem 


DEFINE EM_REPOS_USER ="SYSMAN"
DEFINE LOGGING = "VERBOSE"

declare

  l_username dba_role_privs.grantee%type;
  l_user_name dba_role_privs.grantee%type;
  l_sql varchar2(1024);
  l_sysman_user number;
  l_mgmt_users_src number;
  l_sid number;
  l_serial number;
  err number;
  err_msg varchar2(128);
  c number;
  l_removejobs varchar2(1024);
  l_set_context varchar2(1024);
  l_client varchar2(16) := ' ';
  l_context integer := 5;
  l_verbose boolean := FALSE;
  l_msg varchar2(1024);
  l_open_acc number := 0;
  
  TYPE SESSION_REC IS RECORD
   (sid     v$session.sid%type, 
    serial_no v$session.serial#%type);  
  TYPE  SESSION_TYPE IS TABLE OF SESSION_REC;
  l_sessions SESSION_TYPE;
  


  l_job_process_count NUMBER ;
  TYPE TBSP_ARRAY IS TABLE OF varchar2(64) INDEX BY BINARY_INTEGER ;
  l_tablespaces TBSP_ARRAY;

    PROCEDURE set_job_process_count(p_count IN NUMBER)
    IS
    BEGIN
      --scope=memory so it will be reset on instance startup
      -- SID=* to take care of RAC
      IF p_count >=0
      THEN
        EXECUTE IMMEDIATE 'ALTER SYSTEM SET job_queue_processes='
                    ||p_count||' SID=''*'' scope=memory' ;
      END IF ;
    EXCEPTION WHEN OTHERS THEN NULL ;
    END set_job_process_count ;

    PROCEDURE LOG_MESSAGE (verbose boolean, message varchar2)
    IS
    BEGIN
        IF (verbose = TRUE)
        THEN
            DBMS_OUTPUT.PUT_LINE(message);
        END IF;
    END LOG_MESSAGE;

    FUNCTION get_job_process_count
    RETURN NUMBER
    IS
    l_value NUMBER ;
    BEGIN
      SELECT value
        INTO l_value
        FROM v$parameter
       WHERE name = 'job_queue_processes' ;
       RETURN(l_value) ;
    EXCEPTION
    WHEN OTHERS THEN
       RETURN(10) ;
    END get_job_process_count ;
begin
    IF (upper('&LOGGING') = 'VERBOSE')
    THEN
      l_verbose := TRUE;
    END IF;

    LOG_MESSAGE(l_verbose,' This script will drop the Oracle Enterprise Manager related schemas and objects.');
    LOG_MESSAGE(l_verbose, ' This script might take few minutes to complete; it has 6 phases to complete the process.');
    LOG_MESSAGE(l_verbose,' The script may take longer if you have SYSMAN and related sessions are active');
    LOG_MESSAGE(l_verbose,' from Oracle Enterprise Manager(OEM) application.');
    LOG_MESSAGE(l_verbose,' ');
    LOG_MESSAGE(l_verbose,' ');
    LOG_MESSAGE(l_verbose,' Recommendations:');
    LOG_MESSAGE(l_verbose,' ');
    LOG_MESSAGE(l_verbose,' ');
    LOG_MESSAGE(l_verbose,' You are recommended to shutdown DB Control application immediately before running this');
    LOG_MESSAGE(l_verbose,' OEM repository removal script.');
    LOG_MESSAGE(l_verbose,' To shutdown DB Control application, you need to run: emctl stop dbconsole');
    LOG_MESSAGE(l_verbose,' ');
    LOG_MESSAGE(l_verbose,' ');
    LOG_MESSAGE(l_verbose,' Steps to be performed manually (after this script is run):');
    LOG_MESSAGE(l_verbose,' ');
    LOG_MESSAGE(l_verbose,' ');
    LOG_MESSAGE(l_verbose,' Please note that you need to remove the DB Control Configuration Files');
    LOG_MESSAGE(l_verbose,' manually to remove DB Control completly; remove the following');
    LOG_MESSAGE(l_verbose,' directories from your filesystem:');
    LOG_MESSAGE(l_verbose,' <ORACLE_HOME>/<hostname_sid>');
    LOG_MESSAGE(l_verbose,' <ORACLE_HOME>/oc4j/j2ee/OC4J_DBConsole_<hostname>_<sid>');
    LOG_MESSAGE(l_verbose,' ');
    LOG_MESSAGE(l_verbose,' If the dbcontrol is upgraded from lower version, for example, from 10.2.0.3 to 10.2.0.4,');
    LOG_MESSAGE(l_verbose,' then the following directory also needs to be removed from the file system.');
    LOG_MESSAGE(l_verbose,' <ORACLE_HOME>/<hostname_sid>.upgrade');
    LOG_MESSAGE(l_verbose,' <ORACLE_HOME>/oc4j/j2ee/OC4J_DBConsole_<hostname>_<sid>.upgrade');
    LOG_MESSAGE(l_verbose,' ');
    LOG_MESSAGE(l_verbose,' On Microsoft platforms, also delete the DB Console service, generally with name');
    LOG_MESSAGE(l_verbose,' OracleDBConsole<sid>');


    LOG_MESSAGE(l_verbose,'Starting phase 1 : Dropping AQ related objests, EM jobs and all Oracle Enterprise Manager related schemas; except SYSMAN ...');
    
    c := 0;
    BEGIN 
        select count(1) into l_sysman_user from all_users where username='SYSMAN';
    IF (l_sysman_user > 0 ) THEN
    BEGIN

        BEGIN
            LOG_MESSAGE(l_verbose,'dropping AQ related objests from SYSMAN ...');

            DBMS_AQADM.DROP_QUEUE_TABLE(queue_table=>'SYSMAN.MGMT_NOTIFY_QTABLE',force=>TRUE);
        EXCEPTION
            WHEN OTHERS THEN
             err := SQLCODE;
             LOG_MESSAGE(l_verbose,'found [sqlcode:'||err||']: AQ related objects are dropped already or not found');
        END;
    
        BEGIN 
            -- reduce job_queue_processes to zero
           l_job_process_count := get_job_process_count ;
           set_job_process_count(0) ;
           LOG_MESSAGE(l_verbose,'saved job_queue_process=' || l_job_process_count || ', set to 0, now removing Oracle EM jobs ...');
           l_removejobs := 'BEGIN ' ||  'SYSMAN' || '.emd_maintenance.remove_em_dbms_jobs; END;';
           execute immediate l_removejobs;
        EXCEPTION
           WHEN OTHERS THEN
               err := SQLCODE;
               LOG_MESSAGE(l_verbose,'found [sqlcode:'||err||']: EM jobs are dropped already or not found');
        END;
    
    END;
    END IF;
    END;

    -- First, drop all users, except SYSMAN who have MGMT_USER role and
    -- are created by EM. All users created by EM will have a record
    -- in MGMT_CREATED_USERS table
    --
     
    BEGIN 
        select count(1) into l_sysman_user from all_users where username='SYSMAN';
        IF (l_sysman_user > 0 ) THEN      
        BEGIN

        LOOP  --  part 1 main loop
              -- handle SYSMAN is partially dropped
             select count(1) into l_mgmt_users_src from all_objects where object_name='MGMT_CREATED_USERS' and owner='SYSMAN';
             IF(l_mgmt_users_src = 0 ) THEN
                 EXIT;
             END IF;
        BEGIN
          LOG_MESSAGE(l_verbose,'finding users who needs to be dropped ...');
          l_username := '';
          BEGIN
              execute immediate 'select grantee
                 from sys.dba_role_privs
                 where granted_role ='||DBMS_ASSERT.ENQUOTE_LITERAL('MGMT_USER')||
                  ' AND grantee IN (SELECT user_name
                               FROM SYSMAN.MGMT_CREATED_USERS
                                WHERE SYSTEM_USER=0)
                  AND ROWNUM=1'
                  into l_user_name;
               LOG_MESSAGE(l_verbose,'found user name: ' || l_user_name);
                  l_username := DBMS_ASSERT.ENQUOTE_NAME(l_user_name, FALSE);

               EXECUTE IMMEDIATE 'ALTER USER '||l_username||' ACCOUNT LOCK' ;
          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    LOG_MESSAGE(l_verbose,l_username || ' IS ALREADY DROPPED');
                EXIT; -- THEN RETURN ;
          END ; 


          FOR cnt in 1 .. 150 LOOP -- session kill loop 

            BEGIN
              -- FOR crec in (SELECT sid, serial#
              --               FROM v$session
              --              WHERE username=l_username
              --                AND status NOT IN('KILLED'))
            
              l_sql := 'SELECT sid, serial#
                             FROM v$session
                            WHERE username='|| DBMS_ASSERT.ENQUOTE_LITERAL(l_user_name)||'
                            AND status NOT IN(''KILLED'')'; 
              execute immediate l_sql BULK COLLECT INTO l_sessions;
              
              FOR i in 1..l_sessions.COUNT
              LOOP   --  cursor loop 
              BEGIN
                   LOG_MESSAGE(l_verbose,'killing related sessions : sid= ' || l_sessions(i).sid || ' serial#= ' || l_sessions(i).serial_no || ' ...');
                     EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ' || DBMS_ASSERT.ENQUOTE_LITERAL(l_sessions(i).sid || ',' || l_sessions(i).serial_no)||' IMMEDIATE';
              EXCEPTION
                      WHEN OTHERS THEN
                         err := SQLCODE;
                         IF err != -30 THEN
                            LOG_MESSAGE(l_verbose,'found [sqlcode:'||err||']: no session found; or already killed.');
                            EXIT;
                         END IF;
              END;
              COMMIT;
              END LOOP; -- end cursor loop 

            EXCEPTION
                WHEN OTHERS THEN
                  err := SQLCODE;
                  IF err != -30 THEN
                    LOG_MESSAGE(l_verbose,'found [sqlcode:'||err||']: no session found; or already killed.');       
                    EXIT;
                  END IF;
            END;

            IF SQL%NOTFOUND THEN
               LOG_MESSAGE(l_verbose,'found [sql%notfound]: no session found; or already killed.');
               EXIT;
            END IF;

          COMMIT;

          END LOOP;  -- end session killing loop
          LOG_MESSAGE(l_verbose,' Dropping user : ' || l_username || '...');

          EXECUTE IMMEDIATE 'drop user ' || l_username || ' cascade';
          exit;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              LOG_MESSAGE(l_verbose,'found [no_data_found]: no user/corresponding sessions found related to DB Control');
               EXIT;
            WHEN OTHERS THEN
              err := SQLCODE;
              IF err = -1918 THEN
               LOG_MESSAGE(l_verbose,'found [sqlcode:'||err||']: no DB Control user/corresponding sessions found related to DB Control');
                EXIT;
              ELSE
                IF err = -1940 THEN
                  NULL;
                ELSE
                  -- keep count of try to drop EM related user and sessions
                  -- give up after 50 try

                  c := c+1;
                  IF c > 50 THEN
                     RAISE;
                  END IF;
                END IF;
              END IF;
        END;
        END LOOP; -- end part main loop
       END;
       ELSE 
               LOG_MESSAGE(l_verbose,'SYSMAN IS ALREADY DROPPED');
       END IF;
   END;

   BEGIN 
       -- Now, drop the SYSMAN user 
       LOG_MESSAGE(l_verbose,'Finished phase 1');
       LOG_MESSAGE(l_verbose,'Starting phase 2 : Dropping SYSMAN schema ...');
    
       c := 0;
       -- validate user exists
       select count(1) into l_sysman_user from all_users where username='SYSMAN';
       IF (l_sysman_user > 0 ) THEN
       BEGIN
    
           BEGIN
             --  SELECT username
             --   INTO l_username
             --   FROM dba_users
             --   WHERE username = 'SYSMAN';
                -- l_user_name := 'SYSMAN';
                -- l_username = DBMS_ASSERT.ENQUOTE_NAME(l_user_name);
                EXECUTE IMMEDIATE 'ALTER USER SYSMAN ACCOUNT LOCK' ;
           EXCEPTION
                WHEN NO_DATA_FOUND THEN 
                    LOG_MESSAGE(l_verbose,'SYSMAN IS ALREADY DROPPED');
                -- THEN RETURN ; 
           END ;
           

           BEGIN
               LOOP  -- main loop
                   BEGIN
                       FOR cnt in 1 .. 150 LOOP -- session kill loop
                           BEGIN
                               FOR crec in (SELECT sid, serial#
                                   FROM gv$session
                                     WHERE (username='SYSMAN' OR
                                        schemaname='SYSMAN')
                                     AND status != 'KILLED')
                               LOOP   --cursor loop
                                   BEGIN
                                       LOG_MESSAGE(l_verbose,'killing related sessions : sid= ' || crec.sid || ' serial#= ' || crec.serial#  || ' ...');
                                       EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ' ||
                                         DBMS_ASSERT.ENQUOTE_LITERAL(crec.sid || ',' || crec.serial#)|| ' IMMEDIATE';
                                   EXCEPTION
                                   WHEN OTHERS THEN
                                       err := SQLCODE;
                                       IF err != -30 THEN
                                           LOG_MESSAGE(l_verbose,'found [sqlcode:'||err||']: SYSMAN related sessions are already killed; no session found');
                                           EXIT;
                                       END IF;
                                  END;
                                  COMMIT;
                               END LOOP;  -- cursor loop ends
                           EXCEPTION
                              WHEN OTHERS THEN
                                 err := SQLCODE;
                                 IF err != -30 THEN
                                     LOG_MESSAGE(l_verbose,'found [sqlcode:'||err||']: SYSMAN related sessions are already killed; no session found');
                                     EXIT;
                                 END IF;
                           END;
                           IF SQL%NOTFOUND THEN
                                LOG_MESSAGE(l_verbose,'found [sql%notfound]: SYSMAN related sessions are already killed; no session found');
                                EXIT;
                          END IF;
                          COMMIT;
                       END LOOP;  -- end of session kill loop

                       -- END;
                       LOG_MESSAGE(l_verbose,'dropping user :  ' || l_user_name || '...');
                       execute immediate 'drop user SYSMAN cascade';
                       set_job_process_count(l_job_process_count) ;
                       exit;

   	               -- >> START - Dropping the Tablespaces
                       LOG_MESSAGE(l_verbose,'Finished phase 2');
                       LOG_MESSAGE(l_verbose,'Starting phase 3 : Dropping Oracle Enterprise Manager related tablespaces ...');
     
	               LOG_MESSAGE(l_verbose,'No seperate TABLESPACES Exist for EM;  all in SYSAUX; no action taken');
	               -- >> END - Dropping the Tablespaces

                   EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          LOG_MESSAGE(l_verbose,'found [ no_data_found]: no sysman/corresponding sessions');
                          EXIT;
                      WHEN OTHERS THEN
                      err := SQLCODE; 
                      IF err = -1918 THEN
                          LOG_MESSAGE(l_verbose,'found [sqlcode:1918]: no sysman/corresponding sessions');
                          EXIT;
                      ELSIF err = -1940 THEN
                              NULL;
                      ELSE
                          LOG_MESSAGE(l_verbose,'found [sqlcode:'||err||']: no sysman/corresponding sessions');
                          c := c+1;
                          IF c > 50 THEN
                              RAISE;
                          END IF;
                      END IF;
                   END;
               END LOOP;  -- end of main loop
           END;
           LOG_MESSAGE(l_verbose,'SYSMAN dropped');
           commit;
       END;
    ELSE
      LOG_MESSAGE(l_verbose,'SYSMAN is already dropped');
    END IF; 
    EXCEPTION
        WHEN OTHERS THEN
        set_job_process_count(l_job_process_count) ;
        RAISE ;
    END;

BEGIN
      
    -- Drop basic roles.
    LOG_MESSAGE(l_verbose,'Finished phase 3');
    LOG_MESSAGE(l_verbose,'Starting phase 4 : Dropping Oracle Enterprise Manager related MGMT_USER role ...');
     
    BEGIN 
      execute immediate 'drop role MGMT_USER';
    EXCEPTION 
          WHEN OTHERS THEN
          LOG_MESSAGE(l_verbose,'Role MGMT_USER already dropped');
    END;
    --
    -- Drop the following synonyms related to REPOS Schema
    --
    LOG_MESSAGE(l_verbose,'Finished phase 4');
    LOG_MESSAGE(l_verbose,'Starting phase 5 : Dropping Oracle Enterprise Manager related public synonyms ...');
     

    BEGIN 
      FOR crec in (SELECT synonym_name,table_owner,table_name
                   FROM dba_synonyms 
                   WHERE owner = 'PUBLIC'
                   AND table_owner = 'SYSMAN')
      LOOP 
          BEGIN 
              LOG_MESSAGE(l_verbose,'Dropping synonym : ' || crec.synonym_name || ' ... ');
              EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM ' || DBMS_ASSERT.SIMPLE_SQL_NAME(crec.synonym_name);

          EXCEPTION 
	      when others then
              LOG_MESSAGE(l_verbose,'Public synonym ' || crec.synonym_name || 
				   ' cannot be dropped');
              -- continue dropping other synonyms.
          END;
      END LOOP;
    END;

    BEGIN 
      LOG_MESSAGE(l_verbose,'Finished phase 5');
      LOG_MESSAGE(l_verbose,'Starting phase 6 : Dropping Oracle Enterprise Manager related other roles ...');
      FOR crec in (select role from sys.dba_roles where role like 'MGMT_%')
      LOOP 
        LOG_MESSAGE(l_verbose,'Dropping role: ' || crec.role ||' ...');
        execute immediate 'drop role ' || DBMS_ASSERT.SIMPLE_SQL_NAME(crec.role);
        commit;
      END LOOP;
    EXCEPTION  
        when NO_DATA_FOUND THEN
          LOG_MESSAGE(l_verbose,'Roles like MGMT% do not exist');
        WHEN OTHERS THEN
          err := SQLCODE;
          LOG_MESSAGE(l_verbose,'found [sqlcode: '||SQLCODE||']: no MGMT% roles to drop');
    END;
   
    -- lock DBSNMP user 
    BEGIN 
        BEGIN 
           LOG_MESSAGE(l_verbose,'Process DBSNMP user');
           select count(1) into l_open_acc  from DBA_USERS where USERNAME ='DBSNMP' and ACCOUNT_STATUS='OPEN';
        EXCEPTION 
           when NO_DATA_FOUND THEN
              LOG_MESSAGE(l_verbose,'User DBSNMP does not exist');
           WHEN OTHERS THEN 
                err := SQLCODE;
                LOG_MESSAGE(l_verbose,'found [sqlcode: '||SQLCODE||']: while checking DBSNMP user status');

        END;

        IF (l_open_acc > 0 ) THEN
            BEGIN 
                execute immediate 'ALTER USER DBSNMP PASSWORD EXPIRE'; 
                 LOG_MESSAGE(l_verbose,'DBSNMP user password is made expired');
            EXCEPTION
                WHEN OTHERS THEN
                    err := SQLCODE;
                    LOG_MESSAGE(l_verbose,'found [sqlcode: '||SQLCODE||']: while expiring DBSNMP user password');
            END;

            BEGIN 
                execute immediate 'ALTER USER DBSNMP ACCOUNT LOCK'; 
                 LOG_MESSAGE(l_verbose,'User DBSNMP is locked');
            EXCEPTION
                WHEN OTHERS THEN
                    err := SQLCODE;
                    LOG_MESSAGE(l_verbose,'found [sqlcode: '||SQLCODE||']: while locking DBSNMP user');
            END;

        END IF; 
        LOG_MESSAGE(l_verbose,'Done processing DBSNMP user');
    END;

    LOG_MESSAGE(l_verbose,'Finished phase 6');
    LOG_MESSAGE(l_verbose,'The Oracle Enterprise Manager related schemas and objects are dropped.');
    LOG_MESSAGE(l_verbose,'Do the manual steps to studown the DB Control if not done before running this script and then delete the DB Control configuration files');
    commit;
END;
END;
/

