Rem Copyright (c) 1995, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem   NAME
Rem     owacomm.sql - PL/SQL Gateway package installation
Rem   PURPOSE
Rem     Install the PL/SQL packages needed to run the PL/SQL
Rem     gateway for 8.x and beyond databases.
Rem   NOTES
Rem     This script installs the PL/SQL gateway toolkit 
Rem     packages (such as HTP/HTP/OWA_UTIL, WPG_DOCLOAD etc.)
Rem     it should be called BY a driver script such AS owaload.sql
Rem   IMPORTANT
Rem     Please keep this file as generic as possible. This file must be
Rem     able to run in both SQLPLUS and SVRMGRL
Rem   history
Rem     ehanks     01/18/08 -  Changing "grant all" to "grant execute" for
Rem                            security bug #6596784.
Rem     mmuppago   11/01/05 -  removed call to pubcust.sql and privcust.sql(bug#3434804)
Rem                            OWA packages should not overwrite customers OWA_CUSTOM packages
Rem     dnonkin    08/31/04 -  removed call to owadins.sql 
Rem     pkapasi    06/17/01 -  Add support for EBCDIC databases(bug#1778693)
Rem     ehlee      03/14/01 -  split handle 8.0.x databases to owacomm8.sql
Rem     ehlee      12/26/00 -  handle 8.0.x databases
Rem     rdecker    07/21/00 -  split synonym handling INTO NEW files
Rem     ehlee      05/05/00 -  fixing spelling error for "package"
Rem     ehlee      05/05/00 -  add owa_cache
Rem     rdecker    04/20/00 -  split off FROM owaload.sql
Rem

prompt In owacomm.sql
  
whenever sqlerror exit sql.sqlcode

Prompt Revoking the debug privileges

declare
   l_privilege varchar2(10) := 'DEBUG';
   l_owner varchar2(10) := 'PUBLIC';

   /** 
    * Revokes the debug privilege on specific packages
    * for which excess privileges were granted 
    * incorrectly in earlier releases.
    **/
   procedure revoke_privileges
    (
         p_privilege      in varchar2,
         p_user           in varchar2 
    )
    is
        object_name dba_tab_privs.table_name%type := null;

        -- Fetch all the specific objects  
        -- for which the user has the privilege.
        -- Here we are revoking privileges on precise objects for which
        -- privileges were granted incorrectly in earlier releases through
        -- the scripts owacomm.sql and privcust.sql.
        -- This cursor will be invoked using the 
        -- 'Debug' Privilege and 'Public' user.


        cursor  object_prv (p_privilege IN varchar2 ,p_user IN varchar2)
          is select table_name from dba_tab_privs, 
         dba_objects where privilege=p_privilege
         and grantee = p_user and table_name = 
         object_name and object_type ='PACKAGE'
         and dba_objects.OWNER ='SYS' 
         and dba_objects.OWNER = dba_tab_privs.OWNER 
         and object_name in 
         ('OWA_CUSTOM','OWA', 'HTF',
          'HTP','OWA_COOKIE','OWA_IMAGE',
          'OWA_OPT_LOCK','OWA_PATTERN','OWA_SEC',
          'OWA_TEXT','OWA_UTIL','OWA_CACHE','OWA_MATCH');

         l_revoke_cmd varchar2(4000);

    begin
         
         -- Execute the query for fetching
         -- the objects for which the user has privilege.
         open object_prv (p_privilege,p_user);

         -- Loop through the objects on which 
         -- the user has the privilege and
         -- revoke the privilege.

         loop
            fetch object_prv into object_name;
            exit when object_prv%NOTFOUND;

            -- Execute the revoke privilege command
            l_revoke_cmd := 'Revoke ' ||  p_privilege || ' on ' || object_name
                        || ' from ' ||  p_user;
            dbms_output.put_line ('Revoking privilege on ' || object_name);

            execute immediate l_revoke_cmd ;
         end loop;

         -- Close the cursor.
         close object_prv;
   exception
       when others then 
           dbms_output.put_line
               ('ERROR: owacomm.sql while revoking the  privilege on ' 
                 ||  object_name );
           dbms_output.put_line(sqlerrm );

           if object_prv%isopen then
            close object_prv;
           end if;

           raise;  
   end revoke_privileges;

   /**
    * Returns true if the user has
    * privilege on specific packages for which
    * excess privilege was granted incorrectly
    * during earlier releases.
    * False otherwise.
    */

   function has_privilege
    (
         p_privilege      in varchar2,
         p_user           in varchar2 
    )
    return boolean
    is
        l_count number := null;

        -- Fetch the count of objects (precise packages)  
        -- for which the user has the privilege.
        -- This cursor will be invoked using the 
        -- 'Debug' Privilege and 'Public' user.
        -- So this fetches the count of precise packages for which
        -- the public user has debug privileges that were 
        -- incorrectly granted in earlier releases.
        
        cursor  object_prv (p_privilege IN varchar2 ,p_user IN varchar2)
          is select count(1) from dba_tab_privs, 
         dba_objects where privilege = p_privilege
         and grantee = p_user and table_name = 
         object_name
         and dba_objects.OWNER ='SYS' 
         and dba_objects.OWNER = dba_tab_privs.OWNER 
         and object_type ='PACKAGE'
         and object_name in
         ('OWA_CUSTOM','OWA', 'HTF',
          'HTP','OWA_COOKIE','OWA_IMAGE',
          'OWA_OPT_LOCK','OWA_PATTERN','OWA_SEC',
          'OWA_TEXT','OWA_UTIL','OWA_CACHE','OWA_MATCH');

         l_has_privilege boolean := false;

    begin
        -- Get the count of owa packages
        -- for which the user has the privilege.
        -- Execute the query.
        open object_prv (p_privilege,p_user);

        -- Fetch the result.
        fetch object_prv into l_count;

        -- Close the cursor.
        close object_prv;

        -- Return true if there are packages
        -- with debug privileges for public.
        -- False otherwise.

         if l_count > 0 then
            l_has_privilege := true;
         end if;

         return l_has_privilege; 

    exception
       when others then 
           dbms_output.put_line
               ('ERROR: owacomm.sql while checking privileges.');
           dbms_output.put_line(sqlerrm );

           if object_prv%isopen then
               close object_prv;
           end if;
           raise;
    end has_privilege;

begin
      
     /* Check if the public user has debug privileges 
      * on specific packages. Skip this step if the user
      * doesn't have the debug privilege.
      */
     
     if has_privilege(l_privilege, l_owner) then

        dbms_output.put_line ('Revoking the debug privilege from PUBLIC schema.');    
        dbms_output.put_line ('Revoking debug privilege started at ' ||
                                 to_char(sysdate, 'dd-mon-yyyy HH:MI:SS'));

        -- Revoke the debug privileges from the public user. 
        revoke_privileges(l_privilege, l_owner);

        dbms_output.put_line ('Revoking debug privilege ended at ' ||
                                to_char(sysdate, 'dd-mon-yyyy HH:MI:SS'));
        
     else 

        dbms_output.put_line ('Debug Privileges not granted for PUBLIC.' ||
                              ' Skipping this step.');    

     end if;
end;    
/

whenever sqlerror continue

@@owachars.sql
@@pubht.sql
@@pubutil.sql
@@pubsec.sql
@@pubowa.sql
@@pubtext.sql
@@pubpat.sql
@@pubimg.sql
@@pubcook.sql
@@puboolk.sql
@@pubcach.sql
@@pubmat.sql
@@wpgdocs.sql
@@privht.sql
@@privowa.sql
@@privutil.sql
@@privtext.sql
@@privpat.sql
@@privimg.sql
@@privcook.sql
@@privoolk.sql
@@privsec.sql
@@privcach.sql
@@privmat.sql
@@wpgdocb.sql

prompt Granting execute privs to public
grant execute on OWA to public;
grant execute on HTF to public;
grant execute on HTP to public;
grant execute on OWA_COOKIE to public;
grant execute on OWA_IMAGE to public;
grant execute on OWA_OPT_LOCK to public;
grant execute on OWA_PATTERN to public;
grant execute on OWA_SEC to public;
grant execute on OWA_TEXT to public;
grant execute on OWA_UTIL to public;
grant execute on OWA_CACHE to public;
grant execute on OWA_MATCH to public;
grant execute on WPG_DOCLOAD to public;
prompt Done granting execute privs to public

REM CREATE PUBLIC owa synonyms
@@owacsyn

