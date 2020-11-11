Rem
Rem $Header: rdbms/admin/catdef.sql /main/46 2017/07/11 11:09:02 rthatte Exp $
Rem
Rem catdef.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catdef.sql - Create a view for default users with default passwords
Rem
Rem    DESCRIPTION
Rem      SYS.DBA_USERS_WITH_DEFPWD view shows list of users with default
Rem      passwords. This view is being used by DB Security scanners and other
Rem      tools to warn DBAs on such users.
Rem
Rem    NOTES
Rem      Each default account must have an entry in SYS.DEFAULT_PWD$ table.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catdef.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catdef.sql
Rem SQL_PHASE: CATDEF
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rthatte     06/20/17 - Bug 21587462: Add users and default passwords for 
Rem                           Oracle Hospitality Simphony
Rem    rthatte     01/18/17 - Bug 25406176: Remove entry for AUDSYS
Rem    aanverma    11/21/16 - Bug 24765440: Add users for EBS Endeca to default
Rem                           password list
Rem    aanverma    07/18/16 - Bug #24289422: Add users for OADM to default 
Rem                           password list
Rem    himagarw    04/23/15 - Bug #20887355 : Add APPS_NE, GHG, CMI, YMS to
Rem                           default password scanner
Rem    bnnguyen    04/11/15 - bug 20860190: Rename 'EXADIRECT' to 'DBSFWUSER'
Rem    jorgrive    03/27/15 - Add GGSYS to DEFAULT_PWD$
Rem    sanbhara    01/05/15 - Bug 19658618 - adding SYSRAC as default password
Rem                           user.
Rem    hmohanku    12/23/14 - bug 20183211: add user FUSION_ATGLITE to default
Rem                           password list
Rem    bnnguyen    12/08/14 - bug 19697038: Add user EXADIRECT to default
Rem                           password list 
Rem    sumkumar    10/14/14 - Bug 19811522 : mark AUDSYS as a user with no
Rem                           default password
Rem    ssonawan    09/30/14 - Bug 19678170: fix DBA_USERS_WITH_DEFPWD for CDB
Rem    jlingow     09/05/14 - adding remote_scheduler_agent proj-58146
Rem    spapadom    08/18/14 - Added sys$umf user (project 47321 - UMF) 
Rem    risgupta    04/21/14 - Bug 18594751: Add entry for new default password
Rem                           for LBACSYS
Rem    himagarw    02/11/14 - Bug #18223942: Add user OZG_BATCH to default
Rem                           password list
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    jstraub     05/10/13 - Register APEX_050000 with the Default Password
Rem                           Scanner tool
Rem    jstraub     04/30/13 - Register APEX_040200 with the Default Password
Rem                           Scanner tool
Rem    himagarw    04/29/13 - Bug #16368869 : ADD USER EUL6_US TO DEFLTPASS
Rem                           SCRIPT
Rem    minx        04/03/13 - Fix bug 16369584: mark XS$NULL no default password
Rem    himagarw    03/21/13 - Bug 16411833 : Adding OPSM users PAS and PASJMS
Rem                           default password
Rem    pradeshm    09/06/12 - Fix Bug-14562531: SHA-1 verifier change for 
Rem                           MDDATA and LBACSYS
Rem    ssonawan    07/05/12 - Bug 13843068: use SHA-1 has to detect default
Rem                           users using default passwords
Rem    surman      04/12/12 - 13615447: Add SQL patching tags
Rem    dgraj       03/29/12 - Bug 13784411 and 13784432 : Add entries for
Rem                           Oracle Transportation Management and Oracle
Rem                           Fusion Transportation Intelligence
Rem    sdball      03/16/12 - Add gsmcatuser
Rem    sanbhara    07/20/11 - Project 24121 - adding DVSYS and DVF to list of
Rem                           default accounts.
Rem    mjstewar    06/22/11 - Add accounts gsmadmin_internal and gsmuser
Rem    nalamand    04/30/11 - Populate default_pwd$ in catdef.sql rather than 
Rem                           in dsec.bsq and upgrade scripts
Rem    rkgautam    04/09/09 - Bug 8420947, removing internal references
Rem    sarchak     03/02/09 - Bug 7829203,default_pwd$ should not be recreated
Rem    ssonawan    02/24/09 - bug-8260171: add account plm/plm
Rem    rkgautam    02/03/09 - bug-8214972: adding rdw13dev/retek
Rem    rlong       09/25/08 - 
Rem    rkgautam    08/26/08 - bug-7347131: add user$ verifiers
Rem    rkgautam    08/25/08 - 
Rem    rmir        08/12/08 - bug-7218953: add additional entry for OLAPSYS 
Rem    rkgautam    07/30/08 - bug-7341968: Verifier corrected for PM
Rem    rkgautam    07/30/08 - bug-7269805: added default account ORDDATA
Rem    dsemler     06/05/08 - add appqossys to the default password table
Rem    rkgautam    05/19/08 - bug-6998975: added default account FOD
Rem    rkgautam    04/22/08 - bug-6952604: added default account SRDEMO
Rem    rkgautam    01/09/08 - bug-6659094: added missing default accounts
Rem    rkgautam    01/08/08 - 
Rem    ssonawan    07/11/07 - bug-6020455: update DBA_USERS_WITH_DEFPWD 
Rem    shan        06/21/07 - remove grant on USERS_WITH_DEFPWD and
Rem                           SYS.DEFAULT_PWD$
Rem    shan        04/30/07 - update default password list
Rem    shan        04/12/07 - users with default password view
Rem    shan        04/12/07 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- For adding entry to DEFAULT_PWD$. Please follow the below mentioned steps
-- 1) Add the entry here
--    ex: For example, if you insert a user SCOTT and his default password
--        verifier BFE9361CDAE2A11C (o3 hash value of "foobar") in this table
--        insert into SYS.DEFAULT_PWD$(user_name,pwd_verifier,pv_type, product)
--        values ('SCOTT', 'BFE9361CDAE2A11C', 0, 'RDBMS');
--        Then user SCOTT will show up in the DBA_USERS_WITH_DEFPWD view
--        as long as his password is "foobar". 
-- 2) Update the Default Password Scanner lists given below: 
--    https://stbeehive.oracle.com/content/dav/st/DB_DEFAULT_PASSWORD_LIST/
--            Public%20Documents/dbserver_default_password.xml, and 
--    https://stbeehive.oracle.com/content/dav/st/DB_DEFAULT_PASSWORD_LIST/
--            Public%20Documents/default_password_list_11.2.htm

Rem Truncate default_pwd$ and insert values afresh
truncate table default_pwd$;

insert into default_pwd$(user_name, pwd_verifier) 
 values('#INTERNAL', '38379FC3621F7DA2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('#INTERNAL', '87DADF57B623B777');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AASH', '9B52488370BB3D77');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ABA1', '30FD307004F350DE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ABM', 'D0F2982F121C7840');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AD_MONITOR', '54F0C83F51B03F49');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ADAMS', '72CDEF4A3483F60D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ADLDEMO', '147215F51929A6E8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ADMIN', 'B8B15AC9A946886A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ADMIN', 'CAC22318F162D597');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ADMINISTRATOR', '1848F0A31D1C5C62');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ADMINISTRATOR', 'F9ED601D936158BD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ADS', 'D23F0F5D871EB69F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ADSEUL_US', '4953B2EB6FCB4339');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2003Q3', '439BFE6A40F3369D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2003Q4', '7A2A4FA3107DB437');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2003Q4_REV2', 'A049F6A9FD80A0EB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2004Q1', '612984CD0B509FB3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2004Q2', 'FBD2CB3E80B4FCD4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2004Q3', '80CDFF5EACF1316B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2004Q4', 'D6E8ECACE28C16DA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2005Q1', 'BF4BF39908737842');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2005Q2', 'BAD23CEB9E037FB8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2005Q3', '689AF9293F5ED8EC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2005Q4', '97046684886134B3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2006Q1', '7B55F517727458AA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2006Q2', '1DC7343FDE68241E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2006Q3', 'B7FAEED2295F7DE3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2006Q4', 'DD06DF54E91319F8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2007Q1', 'FE00B2233FD710F1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2007Q2', '29E5A29B1D83F4DA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2007Q3', 'FCF447C836C36669');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2007Q4', 'CADBCAA5D93EED85');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2008Q1', '44A7FBBC9BC5E90C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2008Q2', '4B0743640AF2A27B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2008Q3', 'B5B9A93683ED870A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2008Q4', '56BDDD4617A3D875');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2009Q1', '4B29322708D57CB2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2009Q2', 'C0AEF73F5265BE37');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2009Q3', '92831E85D483CE76');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2009Q4', 'AACF210ACF601CDE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2010Q1', '42FF296B280E379F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2010Q1_REV2', 'AEDF3764AB197C26');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2010Q2', '2129D4E9F726D788');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AERS68_TO_2Q03', 'DB596D637A4D8102');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AHL', '7910AE63C9F7EEEE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AHM', '33C2E27CF5E401A4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AIA', '3866BBB1FB9D80C3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AK', '8FCB78BBA8A59515');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AL', '384B2C568DE4C2B5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ALA1', '90AAC5BD7981A3BA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ALHRO', '049B2397FB1A419E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ALHRW', 'B064872E7F344CAE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ALLUSERS', '42F7CD03B7D2CA0F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ALR', 'BE89B24F9F8231A9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ALT_ADMIN', '779344313F899066');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMA1', '585565C23AB68F71');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMA2', '37E458EE1688E463');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMA3', '81A66D026DC5E2ED');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMA4', '194CCC94A481DCDE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMF', 'EC9419F55CDC666B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMS', 'BD821F59270E5F34');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMS1', 'DB8573759A76394B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMS2', 'EF611999C6AD1FD7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMS3', '41D1084F3F966440');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMS4', '5F5903367FFFB3A3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMSYS', '4C1EF14ECE13B5DE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMV', '38BC87EB334A1AC4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AMW', '0E123471AACA2A62');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ANDY', 'B8527562E504BC3F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ANNE', '1EEA3E6F588599A6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ANONYMOUS', '94C33111FD9C66F3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ANONYMOUS', 'FE0E8CE7C92504E9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AOLDEMO', 'D04BBDD5E643C436');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AP', 'EED09A552944B6AD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APA1', 'D00197BF551B2A79');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APA2', '121C6F5BD4674A33');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APA3', '5F843C0692560518');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APA4', 'BF21227532D2794A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APEX_PUBLIC_USER', '084062DA5B2E2B75');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPLEAD', '5331DB9C240E093B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPLMGR', 'CB562C240E871070');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPLSYS', '0F886772980B8C79');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPLSYS', 'E153FFF4DAE6C9F7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPLSYS', 'FE84888987A6BF5A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPLSYSPUB', '78194639B5C3DF9F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPLSYSPUB', 'D2E3EF40EE87221E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPLSYSPUB', 'D5DB40BB03EA1270');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPLYSYSPUB', '78194639B5C3DF9F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPLYSYSPUB', 'A5E09E84EC486FC9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPLYSYSPUB', 'D2E3EF40EE87221E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPQOSSYS', '519D632B7EE7F63A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPS', 'D728438E8A5925E0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPS_MRC', '2FFDCBB4FD11D9DC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APPUSER', '7E2C3C2D4BF4071B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APR_USER', '0E0840494721500A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APS1', 'F65751C55EA079E6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APS2', '5CACE7B928382C8B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APS3', 'C786695324D7FB3B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('APS4', 'F86074C4F4F82D2C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AQ', '2B0C31040A1CFB48');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AQDEMO', '5140E342712061DD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AQJAVA', '8765D2543274B42E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AQUSER', '4CF13BDAC1D7511C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AR', 'BBBFE175688DED7E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ARA1', '4B9F4E0667857EB8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ARA2', 'F4E52BFBED4652CD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ARA3', 'E3D8D73AE399F7FE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ARA4', '758FD31D826E9143');
insert into default_pwd$(user_name, pwd_verifier, product)
 values('ARCHIVE', '679459CE431927F9', 'Oracle Transportation Management');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ARGUSUSER', 'AB1079A1727006AD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ARS1', '433263ED08C7A4FD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ARS2', 'F3AF9F26D0213538');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ARS3', 'F6755F08CC1E7831');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ARS4', '452B5A381CABB241');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ART', '665168849666C4F3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ASF', 'B6FD427D08619EEE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ASG', '1EF8D8BD87CF16BE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ASL', '03B20D2C323D0BFE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ASN', '1EE6AEBD9A23D4E0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ASO', 'F712D80109E3C9D8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ASP', 'CF95D2C6C85FF513');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AST', 'F13FF949563EAB3C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2005Q2', 'E51A1E73AE85FFB3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2005Q3', '9F82A35B2088B405');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2005Q4', '1E25AA864DF70007');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2006Q1', '02DFCE3E6527833D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2006Q2', '1F9B03B9AF0923E6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2006Q3', '660A71EFC181DD02');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2006Q4', '3AB5EC2155F242D3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2007Q1', 'E385584E8030DA43');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2007Q2', '1EAD80C6AF577FCA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2007Q3', '6D3BC4401E94709C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2007Q4', 'DE7A7A74273D675F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2008Q1', 'EBB83414F34A9232');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2008Q2', '242446A719FEC2B3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2008Q3', '39523393E46B440B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2008Q4', 'FE7221313B46FCC7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2009Q1', 'A22AEAE99B7B8889');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2009Q2', '75FB5B542A2880BE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2009Q3', '3E8715B358F514E8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2009Q4', '89E4E1EB42BD0DFD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2010Q1', '9BEE9122F75371FC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATC_2010Q2', 'AC836261166CB791');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ATM', '7B83A0860CF3CB71');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AUC_GUEST', '8A59D349DAEC26F7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AUDIOUSER', 'CB4F2CEC5A352488');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AURORA$JIS$UTILITY$', 'E1BAE6D95AA95F1E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AURORA$ORB$UNAUTHENTICATED', '80C099F0EADF877E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AUTHORIA', 'CC78120E79B57093');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AX', '0A8303530E86FCDD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('AZ', 'AAA18B5D51B0D5AC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('B2B', 'CC387B24E013C616');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BAM', '031091A1D1A30061');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BC4J', 'EAA333E83BF2810D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BC4J_INTERNAL', 'D15756F15F62D5BA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BCA1', '398A69209360BD9D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BCA2', '801D9C90EBC89371');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BEN', '9671866348E03616');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BI', 'FA1D2B85B70213F3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BIC', 'E84CC95CBBAC1B67');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BIL', 'BF24BCE2409BE1F7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BIM', '6026F9A8A54B9468');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BIS', '7E9901882E5F3565');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BIV', '2564B34BE50C2524');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BIX', '3DD36935EAEDE2E3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BLAKE', '9435F2E60569158E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BLEWIS', 'C9B597D7361EE067');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BMEADOWS', '2882BA3D3EE1F65A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BNE', '080B5C7EE819BF78');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BOM', '56DB3E89EAE5788E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BP01', '612D669D2833FACD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BP02', 'FCE0C089A3ECECEE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BP03', '0723FFEEFBA61545');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BP04', 'E5797698E0F8934E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BP05', '58FFC821F778D7E9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BP06', '2F358909A4AA6059');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BRIO_ADMIN', 'EB50644BE27DF70B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BRUGERNAVN', '2F11631B6B4E0B6F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BRUKERNAVN', '652C49CDF955F83A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BSC', 'EC481FD7DCE6366A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BUG_REPORTS', 'E9473A88A4DD31F2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BUYACCT', 'D6B388366ECF2F61');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BUYAPPR1', 'CB04931693309228');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BUYAPPR2', '3F98A3ADC037F49C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BUYAPPR3', 'E65D8AD3ACC23DA3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BUYER', '547BDA4286A2ECAE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('BUYMTCH', '0DA5E3B504CC7497');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CALVIN', '34200F94830271A3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CAMRON', '4384E3F9C9C9B8F1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CANDICE', 'CF458B3230215199');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CARL', '99ECCC664FFDFEA2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CARLY', 'F7D90C099F9097F1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CARMEN', '46E23E1FD86A4277');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CARRIECONYERS', '9BA83B1E43A5885B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CATADMIN', 'AF9AB905347E004F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CATALOG', '397129246919E8DA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CCT', 'C6AF8FCA0B51B32F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CDEMO82', '67B891F114BE3AEB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CDEMO82', '7299A5E2A5A05820');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CDEMO82', '73EAE7C39B42EA15');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CDEMOCOR', '3A34F0B26B951F3F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CDEMORID', 'E39CEFE64B73B308');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CDEMOUCB', 'CEAE780F25D556F8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CDOUGLAS', 'C35109FE764ED61E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CDR_DPSERVER', 'D9AA439707214B0D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CE', 'E7FDFE26A524FE39');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CEASAR', 'E69833B8205D5DD7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CENTRA', '63BF5FFE5E3EA16D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CENTRAL', 'A98B26E2F65CA4D3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CFD', '667B018D4703C739');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CFLUENTDEV', 'D930962979E34C47');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CHANDRA', '184503FA7786C82D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CHARLEY', 'E500DAA705382E8D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CHRISBAKER', '52AFB6B3BE485F81');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CHRISTIE', 'C08B79CCEC43E798');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CIDS', 'AA71234EF06CE6B3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CINDY', '3AB2C717D1BD0887');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CIS', '7653EBAF048F0A10');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CIS', 'AA2602921607EE84');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CISINFO', '3AA26FC267C5F577');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CISINFO', 'BEA52A368C31B86F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CISUSER', '0A6287850C455DFC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CLARK', '74DF527800B6D713');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CLARK', '7AAFE7D01511D73F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CLAUDE', 'C6082BCBD0B69D20');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CLIENT_STORAGE', '66AA3738639CCA31');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CLINT', '163FF8CCB7F11691');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CLN', 'A18899D42066BFCA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CN', '73F284637A54777D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CNCADMIN', 'C7C8933C678F7BF9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('COMPANY', '402B659C15EAF6CB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('COMPIERE', 'E3D0DCF4B4DBE626');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CONNIE', '982F4C420DD38307');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CONNOR', '52875AEB74008D78');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CORY', '93CE4CCE632ADCD2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CQSCHEMAUSER', '04071E7EDEB2F5CC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CQUSERDBUSER', '0273F484CD3F44B7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CRM1', '6966EA64B0DFC44E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CRM2', 'B041F3BEEDA87F72');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CRP', 'F165BDE5462AD557');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CRPB733', '2C9AB93FF2999125');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CRPCTL', '4C7A200FB33A531D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CRPDTA', '6665270166D613BC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CS', 'DB78866145D4E1C3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSADMIN', '94327195EF560924');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSAPPR1', '47D841B5A01168FF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSC', 'EDECA9762A8C79CD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSD', '144441CEBAFC91CF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSDUMMY', '7A587C459B93ACE4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSE', 'D8CC61E8F42537DA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSF', '684E28B3C899D42C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSI', '71C2B12C28B79294');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSL', 'C4D7FE062EFB85AB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSM', '94C24FC0BE22F77F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSMIG', '09B4BB013FBD0D65');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSP', '5746C5E077719DB4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSR', '0E0F7C1B1FE3FA32');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CSS', '3C6B8C73DDC6B04F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTCLASSIFY', 'A9B46E185AD36323');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTPROC', '7B1998A46F8E8237');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTS', 'E83E6CCA24F2F4B2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTSCODES', '9A13D9A4C610A60B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTSDD', '4E42022C9A5005F1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTSRM', '9065C0FD3FB4CB4D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTSRP', '299D66AB55D29DFB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTSYS', 'D306BF12BAA2EF00');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTXDEMO', 'CB6B5E9D9672FE89');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTXSYS', '24ABAB8B06281B4C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTXSYS', '71E687F036AD56E5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTXSYS', 'A13C035631643BA0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CTXTEST', '064717C317B551B6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CUA', 'CB7B2E6FFDD7976F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CUE', 'A219FE4CA25023AA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CUF', '82959A9BD2D51297');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CUG', '21FBCADAEAFCC489');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CUI', 'AD7862E01FA80912');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CUN', '41C2D31F3C85A79D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CUP', 'C03082CD3B13EC42');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CUS', '00A12CC6EBF8EDB8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CXFR_RECV', 'CC86B9D7535CB1DA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CXFR_SEND', '62C36CBD76A50C41');
insert into default_pwd$(user_name, pwd_verifier) 
 values('CZ', '9B667E9C5A0D21A6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DATA_SCHEMA', '5ECB30FD1A71CC54');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DAVIDMORGAN', 'B717BAB262B7A070');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DBI', 'D8FF6ECEF4C50809');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DBSNMP', 'E066D214D5421CCC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DBVISION', 'F74F7EF36A124931');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DCM', '45CCF86E1058D3A5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DD7333', '44886308CF32B5D4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DD7334', 'D7511E19D9BD0F90');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DD810', '0F9473D8D8105590');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DD811', 'D8084AE609C9A2FD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DD812', 'AB71915CF21E849E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DD9', 'E81821D03070818C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DDB733', '7D11619CEE99DE12');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DDD', '6CB03AF4F6DD133D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DDIC', '4F9FFB093F909574');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DDR', '834EC9EAC5998DC3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DEMO', '4646116A123897CF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DEMO8', '0E7260738FDFD678');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DEMO9', 'EE02531A80D998CA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DES', 'ABFEC5AC2274E54D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DES2K', '611E7A73EC4B425A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DESIGNER', '620BF8D9EC18E2B9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DEV2000_DEMOS', '18A0C8BD6B13BEE2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DEVB733', '7500DF89DC99C057');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DEVUSER', 'C10B4A80D00CA7A5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DGRAY', '5B76A1EB8F212B85');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DIANE', '46DC27700F2ADE28');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DIP', 'CE4A36B8E06CA59C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DISCOVERER5', 'AF0EDB66D914B731');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DISCOVERER_ADMIN', '5C1AED4D1AADAA4C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DKING', '255C2B0E1F0912EA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DLD', '4454B932A1E0E320');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DMADMIN', 'E6681A8926B40826');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DMATS', '8C692701A4531286');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DMS', '1351DC7ED400BD59');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DMSYS', 'BFBA5A553FD9E28A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DNA', 'C5E32FB2E153E257');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DOM', '51C9F2BECA78AE0E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DPF', 'E53F7C782FAA6898');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DPOND', '79D6A52960EEC216');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DPP', '9C332D64EAF7243E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DSGATEWAY', '6869F3CFD027983A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DSSYS', 'E3B6E6006B3A99E0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DTSP', '5A40D4065B3673D2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DV7333', '36AFA5CD674BA841');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DV7334', '473B568021BDB428');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DV810', '52C38F48C99A0352');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DV811', 'B6DC5AAB55ECB66C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DV812', '7359E6E060B945BA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DV9', '07A1D03FD26E5820');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DVF', 'CE6E4FB5472B20CF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DVP1', '0559A0D3DE0759A6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('DVSYS', '6C00212A449D60A5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EAA', 'A410B2C5A0958CDF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EAM', 'CE8234D92FCFB563');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EARLYWATCH', '8AA1C62E08C76445');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EAST', 'C5D5C455A1DE5F4D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EC', '6A066C462B62DD46');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ECX', '0A30645183812087');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EDR', '5FEC29516474BB3A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EDWEUL_US', '5922BA2E72C49787');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EDWREP', '79372B4AB748501F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EGC1', 'D78E0F2BE306450D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EGD1', 'DA6D6F2089885BA6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EGM1', 'FB949D5E4B5255C0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EGO', 'B9D919E5F5A9DA71');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EGR1', 'BB636336ADC5824A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EJB', '69CB07E2162C6C93');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EJSADMIN', '313F9DFD92922CD2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EJSADMIN', '4C59B97125B6641A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EM_MONITOR', '5BEEF0684A63B990');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EMP', 'B40C23C6E2B4EA3D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('END1', '688499930C210B75');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ENG', '4553A3B443FB3207');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ENI', '05A92C0958AFBCBC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ENM1', '3BDABFD1246BFEA2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ENS1', 'F68A5D0D6D2BB25B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ENTMGR_CUST', '45812601EAA2B8BD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ENTMGR_PRO', '20002682991470B3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ENTMGR_TRAIN', 'BE40A3BE306DD857');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EOPP_PORTALADM', 'B60557FD8C45005A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EOPP_PORTALMGR', '9BB3CF93F7DE25F1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EOPP_USER', '13709991FC4800A1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ESTOREUSER', '51063C47AC2628D4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EUL4_US', '89867444DCC3C48C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EUL5_US', 'B94851DE238A8AFF');
insert into default_pwd$(user_name, pwd_verifier, product)
 values('EUL6_US', '50266C5EDD640768', 
        'Oracle On Demand');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EUL_US', '28AEC22561414B29');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EVENT', '7CA0A42DA768F96D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EVM', '137CEDC20DE69F71');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXA1', '091BCD95EE112EE3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXA2', 'E4C0A21DBD06B890');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXA3', '40DC4FA801A73560');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXA4', '953885D52BDF5C86');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXAMPLE', '637417B1DC47C2E5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXFSYS', '33C758A8E388DEE5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXFSYS', '66F4EF5650C20355');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXS1', 'C5572BAB195817F0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXS2', '8FAA3AC645793562');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXS3', 'E3050174EE1844BA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXS4', 'E963BFE157475F7D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXTDEMO', 'BAEF9D34973EE4EC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('EXTDEMO2', '6A10DD2DB23880CB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FA', '21A837D0AED8F8E5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FEM', 'BD63D79ADF5262E7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FIA1', '2EB76E07D3E094EC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FII', 'CF39DE29C08F71B9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FINANCE', '6CBBF17292A1B9AA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FINPROD', '8E2713F53A3D69D5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FLM', 'CEE2C4B59E7567A3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FLOWS_030000', 'FA1D2B85B70213F3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FLOWS_FILES', '0CE415AC5D50F7A1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FND', '0C0832F8B6897321');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FNI1', '308839029D04F80C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FNI2', '05C69C8FEAB4F0B9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FOD', '9C140B8BA4ADB59B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FOO', '707156934A6318D4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FPA', '9FD6074B9FD3754C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FPT', '73E3EC9C0D1FAECF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FRM', '9A2A7E2EBE6E4F71');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FROSTY', '2ED539F71B4AA697');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FTA1', '65FF9AB3A49E8A13');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FTE', '2FB4D2C9BAE2CCCA');
insert into default_pwd$(user_name, pwd_verifier, product)
 values('FTIMASTER', 'FD9233F850AAAB12',
        'Oracle Fusion Transportation Intelligence');
insert into default_pwd$(user_name, pwd_verifier, product)
 values('FTISTAGE', '387031C841940716', 
        'Oracle Fusion Transportation Intelligence');
insert into default_pwd$(user_name, pwd_verifier, product)
 values('FTIWORK', 'A1F66AE55AA717FA',
        'Oracle Fusion Transportation Intelligence');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FTP', '958CCB397C152ED2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FUN', '8A7055CA462DB219');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FV', '907D70C0891A85B1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('FVP1', '6CC7825EADF994E8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GALLEN', 'F8E8ED9F15842428');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GCA1', '47DA9864E018539B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GCA2', 'FD6E06F7DD50E868');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GCA3', '4A4B9C2E9624C410');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GCA9', '48A7205A4C52D6B5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GCMGR1', '14A1C1A08EA915D6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GCMGR2', 'F4F11339A4221A4D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GCMGR3', '320F0D4258B9D190');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GCS', '7AE34CA7F597EBF7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GCS1', '2AE8E84D2400E61D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GCS2', 'C242D2B83162FF3D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GCS3', 'DCCB4B49C68D77E2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GEORGIAWINE', 'F05B1C50A1C926DE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GL', 'CD6E99DACE4EA3A6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GLA1', '86C88007729EB36F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GLA2', '807622529F170C02');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GLA3', '863A20A4EFF7386B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GLA4', 'DB882CF89A758377');
insert into default_pwd$(user_name, pwd_verifier, product)
 values('GLOBALREPORTUSER', '683B6BB3A55C1329',
        'Oracle Transportation Management');
insert into default_pwd$(user_name, pwd_verifier, product)
 values('GLOGDBA', 'F5C013AB59E285BB', 'Oracle Transportation Management');
insert into default_pwd$(user_name, pwd_verifier, product)
 values('GLOGDEV', 'BBE3F9C8C2D42F24', 'Oracle Transportation Management');
insert into default_pwd$(user_name, pwd_verifier, product)
 values('GLOGLOAD', '3CF67C452E273743', 'Oracle Transportation Management');
insert into default_pwd$(user_name, pwd_verifier, product)
 values('GLOGOWNER', '89886D0FA158019A', 'Oracle Transportation Management');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GLS1', '7485C6BD564E75D1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GLS2', '319E08C55B04C672');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GLS3', 'A7699C43BB136229');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GLS4', '7C171E6980BE2DB9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_AWDA', '4A06A107E7A3BB10');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_COPI', '03929AE296BAAFF2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_DPHD', '0519252EDF68FA86');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_MLCT', '24E8B569E8D1E93E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLADMA', '2946218A27B554D8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLADMH', '2F6EDE96313AF1B7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLCCA', '7A99244B545A038D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLCCH', '770D9045741499E6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLCOMA', '91524D7DE2B789A8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLCOMH', 'FC1C6E0864BF0AF2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLCONA', '1F531397B19B1E05');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLCONH', 'C5FE216EB8FCD023');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLNSCA', 'DB9DD2361D011A30');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLNSCH', 'C80D557351110D51');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLSCTA', '3A778986229BA20C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLSCTH', '9E50865473B63347');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_PLVET', '674885FDB93D34B9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_SPO', 'E57D4BD77DAF92F0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GM_STKH', 'C498A86BE2663899');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GMA', 'DC7948E807DFE242');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GMD', 'E269165256F22F01');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GME', 'B2F0E221F45A228F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GMF', 'A07F1956E3E468E1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GMI', '82542940B0CF9C16');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GML', '5F1869AD455BBA73');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GMO', '09965CDCFEAFF416');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GMP', '450793ACFCC7B58E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GMS', 'E654261035504804');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GPFD', 'BA787E988F8BC424');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GPLD', '9D561E4D6585824B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GR', 'F5AB0AA3197AEE42');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GSMADMIN_INTERNAL', '690AA9F8CC62CC2E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GSMUSER', '56D6F489B0F97093');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GSMCATUSER', '0F6108F5BBC60C1F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('GUEST', '1C0A090E404CECD0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HADES', '2485287AC1DB6756');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HCC', '25A25A7FEFAC17B6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HCPARK', '3DE1EBA32154C56B');
insert into default_pwd$(user_name, pwd_verifier, product)
 values('HDOWNER', '901D29B9D7CACF3D',
        'Oracle Fusion Transportation Intelligence');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HHCFO', '62DF37933FB35E9F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HLW', '855296220C095810');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HR', '33EBE1C63D5B7FEF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HR', '4C6D73C3E8B0F0DA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HR', '6399F3B38EDF3288');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HR', '6E0C251EABE4EBB8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HRI', '49A3A09B8FC291D0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HVST', '5787B0D15766ADFD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HXC', '4CEA0BF02214DA55');
insert into default_pwd$(user_name, pwd_verifier) 
 values('HXT', '169018EB8E2C4A77');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IA', '42C7EAFBCEEC09CC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IBA', '0BD475D5BF449C63');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IBC', '9FB08604A30A4951');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IBE', '9D41D2B3DD095227');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IBP', '840267B7BD30C82E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IBU', '0AD9ABABC74B3057');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IBW', '33261A65FA16710E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IBY', 'F483A48F6A8C51EC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ICDBOWN', '76B8D54A74465BB4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ICX', '7766E887AF4DCC46');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IDEMO_USER', '739F5BC33AC03043');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IEB', 'A695699F0F71C300');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IEC', 'CA39F929AF0A2DEC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IEM', '37EF7B2DD17279B5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IEO', 'E93196E9196653F1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IES', '30802533ADACFE14');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IEU', '5D0E790B9E882230');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IEX', '6CC978F56D21258D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IFSSYS', '1DF0D45B58E72097');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IGC', 'D33CEB8277F25346');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IGF', '1740079EFF46AB81');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IGI', '8C69D50E9D92B9D0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IGS', 'DAF602231281B5AC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IGW', 'B39565F4E3CF744B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IMAGEUSER', 'E079BF5E433F0B89');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IMC', 'C7D0B9CDE0B42C73');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IMEDIA', '8FB1DC9A6F8CE827');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IMT', 'E4AAF998653C9A72');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INFORMADAPTER0', '2B71B58F6FA6A587');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INFORMADAPTER1', '7B476D8BDE3F190C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INFORMADAPTER2', '829781FF61845DB2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INFORMADAPTER3', 'B0CE91AD6BD17BA4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INFORMADAPTER4', 'A73A2A8A65E63D7C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INFORMADAPTER5', '36AA9797C917CACD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INFORMADAPTER6', 'AE6AC5E60C4618E6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INFORMADAPTER7', '25626B56F1AB8092');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INFORMADAPTER8', 'EB30A4409A53D878');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INFORMADAPTER9', '101357153D5D3626');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INFORMADMIN', '093ABCA5B56F373B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INL', '1E0296A1C65D2DA1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INS1', '2ADC32A0B154F897');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INS2', 'EA372A684B790E2A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INTERNAL', 'AB27B53EDC5FEF41');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INTERNAL', 'E0BF7F3DDE682D3B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INTERNET_APPSERVER_REGISTRY', 'A1F98A977FFD73CD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('INV', 'ACEAB015589CF4BC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IP', 'D29012C144B58A40');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IPA', 'EB265A08759A15B4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IPD', '066A2E3072C1F2F3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IPLANET', '7404A12072F4E5E8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IPM', 'CC6375A05C243C9E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ISC', '373F527DC0CFAE98');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ISTEWARD', '8735CA4085DE3EEA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ITA', '7FF3EB385C43C19B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ITG', 'D90F98746B68E6CA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IX', '2BE6F80744E08FEB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IX', '885DA62CD26FED7E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('IZU', '66ADE345B0C57B1C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JA', '9AC2B58153C23F3D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JAKE', '1CE0B71B4A34904B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JD7333', 'FB5B8A12AE623D52');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JD7334', '322810FCE43285D9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JD9', '9BFAEC92526D027B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JDE', '7566DC952E73E869');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JDEDBA', 'B239DD5313303B1D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JE', 'FBB3209FD6280E69');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JG', '37A99698752A1CF1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JILL', 'D89D6F9EB78FC841');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JL', '489B61E488094A8D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JMF', 'E135EB82FB383423');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JMSUSER', 'A79CAEC8EC0D7A44');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JMUSER', '063BA85BF749DF8E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JOHN', '29ED3FDC733DC86D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JOHNINARI', 'B3AD4DA00F9120CE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JONES', 'B9E99443032F059D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JTF', '5C5F6FC2EBB94124');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JTI', 'B8F03D3E72C96F71');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JTM', '6D79A2259D5B4B5A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JTR', 'B4E2BE38B556048F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JTS', '4087EE6EB7F9CD7C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JUNK_PS', 'BBC38DB05D2D3A7A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JUSTOSHUM', '53369CD63902FAAA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('JWARD', 'CF9CB787BD98DA7F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('KELLYJONES', 'DD4A3FF809D2A6CF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('KEVINDONS', '7C6D9540B45BBC39');
insert into default_pwd$(user_name, pwd_verifier) 
 values('KPN', 'DF0AED05DE318728');
insert into default_pwd$(user_name, pwd_verifier) 
 values('KWALKER', 'AD0D93891AEB26D2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('L2LDEMO', '0A6B2DF907484CEE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('LABPASREPORT', '13228961C39BC9DB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('LADAMS', 'AE542B99505CDCD2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('LBA', '18E5E15A436E7157');
insert into default_pwd$(user_name, pwd_verifier) 
 values('LBACSYS', 'AC9700FD3F1410EB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('LDQUAL', '1274872AB40D4FCD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('LHILL', 'E70CA2CA0ED555F5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('LIBRARIAN', '11E0654A7068559C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('LNS', 'F8D2BC61C10941B2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('LQUINCY', '13F9B9C1372A41B6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('LSA', '2D5E6036E3127B7E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MANPROD', 'F0EB74546E22E94D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MARK', 'F7101600ACABCD74');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MASCARM', '4EA68D0DDE8AAC6B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MASTER', '9C4F452058285A74');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MDDATA', 'DF02A496267DEE66');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MDDEMO', '46DFFB4D08C33739');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MDDEMO_CLERK', '564F871D61369A39');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MDDEMO_CLERK', 'E5288E225588D11F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MDDEMO_MGR', '2E175141BEE66FF6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MDDEMO_MGR', 'B41BCD9D3737F5C4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MDSYS', '72979A94BAD2AF80');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MDSYS', '9AAEB2214DCC9A31');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ME', 'E5436F7169B29E4D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA100', '1A90B51986646E50');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA101', 'CF2345862486F0CF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA110', 'F033820CC9355E26');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA111', 'DE090CA40AA52C29');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA120', 'C503CDF23D5336EE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA121', '29653F1D6AAF22AF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA130', '8BEE273D010A3BAC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA131', 'DEABB97323287B99');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA32', '028BB52DB6FA3385');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA33', '3DE2582E7CEDDC50');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA40', 'ABC195BC3B1183DB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA50', 'A5EFF120832B814E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA51', '6E4EB9B2CBBA5CFE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA60', '22E73D9064DBC913');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA61', '506681AA3C1505C4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA70', '4932F64346969909');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA71', 'D333DE36F178489D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA80', 'CDB4F97822EE6E2E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA81', '7E72997649468AE5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA90', '35AA4835623EDDC2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MEDDRA91', '09D63EBDBA1EDEE0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MFG', 'FC1B0DD35E790847');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MGDSYS', 'C4F9B839D589AA92');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MGMT_VIEW', '5D5BC23A318B6F53');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MGMT_VIEW', '919E8A172B2AAB87');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MGR', '9D1F407F3A05BDD9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MGR1', 'E013305AB0185A97');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MGR2', '5ADE358F8ACE73E8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MGR3', '05C365C883F1251A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MGR4', 'E229E942E8542565');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MGWUSER', 'EA514DD74D7DE14C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MIGRATE', '5A88CE52084E9700');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MIKEIKEGAMI', 'AAF7A168C83D5C47');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MILLER', 'D0EFCD03C95DF106');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MJONES', 'EE7BB3FEA50A21C5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MLAKE', '7EC40274AC1609CA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MM1', '4418294570E152E7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MM2', 'C06B5B28222E1E62');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MM3', 'A975B1BD0C093DA3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MM4', '88256901EB03A012');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MM5', '4CEA62CBE776DCEC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MMARTIN', 'D52F60115FE87AA4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MMO2', '62876B0382D5B550');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MMO2', 'A0E2085176E05C85');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MMO2', 'AE128772645F6709');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MOBILEADMIN', '253922686A4A45CC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MODTEST', 'BBFF58334CDEF86D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MOREAU', 'CF5A081E7585936B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MRP', 'B45D4DF02D4E0C85');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MSC', '89A8C104725367B2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MSD', '6A29482069E23675');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MSO', '3BAA3289DB35813C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MSR', 'C9D53D00FE77D813');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MST', 'A96D2408F62BE1BC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MTH', '6FB1B758D9877D4F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MTS_USER', 'E462DB4671A51CD4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MTSSYS', '6465913FF5FF1831');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MWA', '1E2F06BE2A1D41A6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('MXAGENT', 'C5F0512A64EB0E7F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('NAMES', '9B95D28A979CC5C4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('NEILKATSU', '1F625BB9FEBC7617');
insert into default_pwd$(user_name, pwd_verifier) 
 values('NEOTIX_SYS', '05BFA7FF86D6EB32');
insert into default_pwd$(user_name, pwd_verifier) 
 values('NNEUL', '4782D68D42792139');
insert into default_pwd$(user_name, pwd_verifier) 
 values('NOM_UTILISATEUR', 'FD621020564A4978');
insert into default_pwd$(user_name, pwd_verifier) 
 values('NOME_UTILIZADOR', '71452E4797DF917B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('NOMEUTENTE', '8A43574EFB1C71C7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('NUME_UTILIZATOR', '73A3AC32826558AE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OAS_PUBLIC', '9300C0977D7DC75E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OAS_PUBLIC', 'A8116DB6E84FA95D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OBJ7333', 'D7BDC9748AFEDB52');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OBJ7334', 'EB6C5E9DB4643CAC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OBJB733', '61737A9F7D54EF5F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OCA', '9BC450E4C6569492');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OCITEST', 'C09011CB0205B347');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OCM_DB_ADMIN', '2C3A5DEF1EE57E92');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ODM', 'C252E8FA117AF049');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ODM_MTR', 'A7A32CD03D3CE8D5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ODS', '89804494ADFC71BC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ODS_SERVER', 'C6E799A949471F57');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ODSCOMMON', '59BBED977430C1A8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OE', '62FADF01C4DC1ED4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OE', '9C30855E7E0CB02D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OE', 'D1A2DFC623FDA40A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OEM_REPOSITORY', '1FF89109F7A16FEF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OEMADM', '9DCE98CCF541AAE6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OEMREP', '7BB2F629772BF2E5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OJVMSYS', 'A16E716A4E584324');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OKB', 'A01A5F0698FC9E31');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OKC', '31C1DDF4D5D63FE6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OKE', 'B7C1BB95646C16FE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OKI', '991C817E5FD0F35A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OKL', 'DE058868E3D2B966');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OKO', '6E204632EC7CA65D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OKR', 'BB0E28666845FCDC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OKS', 'C2B4C76AB8257DF5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OKX', 'F9FDEB0DE52F5D6B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OL810', 'E2DA59561CBD0296');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OL811', 'B3E88767A01403F8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OL812', 'AE8C7989346785BA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OL9', '17EC83E44FB7DB5B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OLAPDBA', '1AF71599EDACFB00');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OLAPSVR', '3B3F6DB781927D0F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OLAPSVR', 'AF52CFD036E8F425');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OLAPSYS', '3FB8EF9DB538647C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OLAPSYS', '4AC23CC3B15E2208');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OLAPSYS', 'C1510E7AC8F0D90D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OMWB_EMULATION', '54A85D2A0AB8D865');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ONT', '9E3C81574654100A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OO', '2AB9032E4483FAFC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPENSPIRIT', 'D664AAB21CE86FD2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPI', '1BF23812A0AEEDA0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPS$GUEST1', '9F7E5A6AAA14AB3F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPS$GUEST2', '0129EC7B1A376587');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPS$GUEST3', 'FB268CD96FFD8D15');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPS$GUEST4', 'A885B9C548D9D575');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPS$GUEST5', '31462E009CD7016F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPS$GUEST6', '75BB189B6BE55A3D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPS$GUEST7', '2D2B86A16BC8B14A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPS$GUEST8', '8F18911775F065A0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPS$GUEST9', 'F2A99B33E50A8076');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPS$OPAPPS', '75E951CFD55482F9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OPS$TMSBROWSER', '7602826AEE50895C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORABAM', 'D0A4EA93EF21CE25');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORABAMSAMPLES', '507F11063496F222');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORABPEL', '26EFDE0C9C051988');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORACACHE', '5A4EEC421DE68DDD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORACLE', '38E38619A12E0257');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORACLE_OCM', '5A2E026A9157958C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORACLE_OCM', '6D17CF1EB1611F94');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORADBA', 'C37E732953A8ABDB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORAESB', 'CC7FCCB3A1719EDA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORANGE', '3D9B7E34A4F7D4E9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORAOCA_PUBLIC', 'FA99021634DDC111');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORAPROBE', '2E3EA470A4CA2D94');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORAREGSYS', '28D778112C63CB15');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORASAGENT', '234B6F4505AD8F25');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORASSO', 'F3701A008AA578CF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORASSO_DS', '17DC8E02BC75C141');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORASSO_PA', '133F8D161296CB8F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORASSO_PS', '63BB534256053305');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORASSO_PUBLIC', 'C6EED68A8F75F5D3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORASTAT', '6102BAE530DD4B95');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORCLADMIN', '7C0BE475D580FBA2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORDCOMMON', '9B616F5489F90AD7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORDDATA', 'A93EC937FCD1DC2A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORDPLUGINS', '88A2B2C183431F00');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ORDSYS', '7EFA02EC7EA6B86F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OSE$HTTP$ADMIN', '05327CD9F6114E21');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OSM', '106AE118841A5D8C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OSP22', 'C04057049DF974C2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OTA', 'F5E498AC7009A217');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OUTLN', '4A3BA55E08595C81');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OWA', 'CA5D67CD878AFC49');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OWA_PUBLIC', '0D9EC1D1F2A37657');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OWAPUB', '6696361B64F9E0A9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OWBSYS', '610A3C38F301776F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OWF_MGR', '3CBED37697EB01D1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OWNER', '5C3546B4F9165300');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OZF', '970B962D942D0C75');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OZP', 'B650B1BB35E86863');
insert into default_pwd$(user_name, pwd_verifier) 
 values('OZS', '0DABFF67E0D33623');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PA', '8CE2703752DB36D8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PABLO', '5E309CB43FE2C2FF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PAIGE', '02B6B704DFDCE620');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PAM', '1383324A0068757C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PANAMA', '3E7B4116043BEAFF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PARRISH', '79193FDACFCE46F6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PARSON', 'AE28B2BD64720CD7');
insert into default_pwd$(user_name, pwd_verifier, product)
values ('PAS', 'D9F82FCE636766EA',
        'Oracle Pedigree And Serialization Manager');
insert into default_pwd$(user_name, pwd_verifier, product)
values ('PASJMS', '20634D3199F83899',
        'Oracle Pedigree And Serialization Manager');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PAT', 'DD20769D59F4F7BF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PATORILY', '46B7664BD15859F9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PATRICKSANCHEZ', '47F74BD3AD4B5F0A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PATROL', '0478B8F047DECC65');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PATSY', '4A63F91FEC7980B7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PAUL', '35EC0362643ADD3F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PAULA', 'BB0DC58A94C17805');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PAXTON', '4EB5D8FAD3434CCC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PCA1', '8B2E303DEEEEA0C0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PCA2', '7AD6CE22462A5781');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PCA3', 'B8194D12FD4F537D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PCA4', '83AD05F1D0B0C603');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PCS1', '2BE6DD3D1DEA4A16');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PCS2', '78117145145592B1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PCS3', 'F48449F028A065B1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PCS4', 'E1385509C0B16BED');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PD7333', '5FFAD8604D9DC00F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PD7334', 'CDCF262B5EE254E1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PD810', 'EB04A177A74C6BCB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PD811', '3B3C0EFA4F20AC37');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PD812', 'E73A81DB32776026');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PD9', 'CACEB3F9EA16B9B7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PDA1', 'C7703B70B573D20F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PEARL', 'E0AFD95B9EBD0261');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PEG', '20577ED9A8DB8D22');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PENNY', 'BB6103E073D7B811');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PEOPLE', '613459773123B38A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PERCY', 'EB9E8B33A2DDFD11');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PERFSTAT', 'AC98877DE1297365');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PERRY', 'D62B14B93EE176B6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PERSTAT', 'A68F56FBBCDC04AB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PETE', '4040619819A9C76E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PEYTON', 'B7127140004677FC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PFDBADMIN', '5CC0735860058E12');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PFT', 'F5B571D73A38C13F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PHIL', '181446AE258EE2F6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PJI', '5024B1B412CD4AB9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PJM', '021B05DBB892D11F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PLANNING', '71B5C2271B7CFF18');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PLEX', '99355BF0E53FF635');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PLM', '53544627CD6E8B7F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PLSQL', 'C4522E109BCF69D0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PM', '72E382A52E89575A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PM', 'C7A235E6D2AF6018');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PM', 'F67E035BF8352CB4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PMI', 'A7F7978B21A6F65E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PN', 'D40D0FEF9C8DC624');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PO', '355CBEC355C10FEF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PO7', '6B870AF28F711204');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PO8', '7E15FBACA7CDEBEC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('POA', '2AB40F104D8517A0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('POLLY', 'ABC770C112D23DBE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('POM', '123CF56E05D4EF3C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PON', '582090FD3CC44DA3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL', 'A96255A27EC33614');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL30', '969F9C3839672C6D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL30', 'D373ABE86992BE68');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL30_ADMIN', '7AF870D89CABF1C7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL30_DEMO', 'CFD1302A7F832068');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL30_PS', '333B8121593F96FB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL30_PUBLIC', '42068201613CA6E2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL30_SSO', '882B80B587FCDBC8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL30_SSO_ADMIN', 'BDE248D4CCCD015D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL30_SSO_PS', 'F2C3DC8003BC90F8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL30_SSO_PUBLIC', '98741BDA2AC7FFB2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL_APP', '831A79AFB0BD29EC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL_DEMO', 'A0A3A6A577A931A3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL_PUBLIC', '70A9169655669CE8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PORTAL_SSO_PS', 'D1FB757B6E3D8E2F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('POS', '6F6675F272217CF7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('POWERCARTUSER', '2C5ECE3BEC35CE69');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PPM1', 'AA4AE24987D0E84B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PPM2', '4023F995FF78077C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PPM3', '12F56FADDA87BBF9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PPM4', '84E17CB7A3B0E769');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PPM5', '804C159C660F902C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PRIMARY', '70C3248DFFB90152');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PRISTB733', '1D1BCF8E03151EF5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PRISTCTL', '78562A983A2F78FB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PRISTDTA', '3FCBC379C8FE079C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PRODB733', '9CCD49EB30CB80C4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PRODCTL', 'E5DE2F01529AE93C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PRODDTA', '2A97CD2281B256BA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PRODUSER', '752E503EFBF2C2CA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PROJMFG', '34D61E5C9BC7147E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PRP', 'C1C4328F8862BC16');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PS', '0AE52ADF439D30BD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PS810', '90C0BEC7CA10777E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PS810CTL', 'D32CCE5BDCD8B9F9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PS810DTA', 'AC0B7353A58FC778');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PS811', 'B5A174184403822F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PS811CTL', '18EDE0C5CCAE4C5A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PS811DTA', '7961547C7FB96920');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PS812', '39F0304F007D92C8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PS812CTL', 'E39B1CE3456ECBE5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PS812DTA', '3780281C933FE164');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PSA', 'FF4B266F9E61F911');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PSB', '28EE1E024FC55E66');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PSBASS', 'F739804B718D4406');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PSEM', '40ACD8C0F1466A57');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PSFT', '7B07F6F3EC08E30D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PSFTDBA', 'E1ECD83073C4E134');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PSP', '4FE07360D435E2F0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTADMIN', '4C35813E45705EBA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTCNE', '463AEFECBA55BEE8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTDMO', '251D71390034576A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTE', '380FDDB696F0F266');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTESP', '5553404C13601916');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTFRA', 'A360DAD317F583E3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTG', '7AB0D62E485C9A3D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTGER', 'C8D1296B4DF96518');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTJPN', '2159C2EAF20011BF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTUKE', 'D0EF510BCB2992A3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTUPG', '2C27080C7CC57D06');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTWEB', '8F7F509D4DC01DF6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PTWEBSERVER', '3C8050536003278B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PUBSUB', '80294AE45A46E77B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PUBSUB1', 'D6DF5BBC8B64933E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PV', '76224BCC80895D3D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PXFR_RECV', '5EDCD7C0194DB324');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PXFR_SEND', '7FD8C5F5108B8E15');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PY7333', '2A9C53FE066B852F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PY7334', 'F3BBFAE0DDC5F7AC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PY810', '95082D35E94B88C2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PY811', 'DC548D6438E4D6B7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PY812', '99C575A55E9FDA63');
insert into default_pwd$(user_name, pwd_verifier) 
 values('PY9', 'B8D4E503D0C4FCFD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QA', 'C7AEAA2D59EB1EAE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QDBA', 'AE62CB8167819595');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QOT', 'B27D0E5BA4DC8DEA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QP', '10A40A72991DCA15');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QPR', '9D58E13752C8A432');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QRM', '098286E4200B22DE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS', '4603BCD2744BDE4F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS', '8B09C6075BDF2DC4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS', 'ACBD635B3A25405D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_ADM', '3990FB418162F2A0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_ADM', '991CDDAD5C5C32CA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_ADM', 'BB424460EFEC9080');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_CB', '870C36D8E6CD7CF5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_CB', 'A2A1265A6BDC8F36');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_CB', 'CF9CFACF5AE24964');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_CBADM', '20E788F9D4F1D92C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_CBADM', '58C823BA7A2D3D7F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_CBADM', '7C632AFB71F8D305');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_CS', '2CA6D0FC25128CF3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_CS', '5D85C7E8FB28375F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_CS', '91A00922D8C0F146');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_ES', '723007181C44715C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_ES', '9A5F2D9F5D1A9EF4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_ES', 'E6A6FA4BB042E3C2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_OS', '0EF5997DC2638A61');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_OS', '7ABBCF4BEB7854B2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_OS', 'FF09F3EB14AE5C26');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_WS', '0447F2F756B4F460');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_WS', '24ACF617DD7D8F2F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('QS_WS', '8CF13718CDC81090');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RDW13DEV', 'FEAC65EA45E13825');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RDWDEV', '0EB196C95E3E3F68');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RDWDM', 'FDD277EC7AAF5E38');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RDWSYS', '91C718625D7E26DA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RE', '933B9A9475E882A6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RENE', '9AAD141AB0954CF0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('REP_MANAGER', '2D4B13A8416073A1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('REP_OWNER', '88D8F06915B1FE30');
insert into default_pwd$(user_name, pwd_verifier) 
 values('REP_OWNER', 'BD99EC2DD84E3B5C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('REP_USER', '57F2A93832685ADB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('REPADMIN', '915C93F34954F5F8');
insert into default_pwd$(user_name, pwd_verifier, product)
 values('REPORTOWNER', '9275F9346708BBB4', 'Oracle Transportation Management');
insert into default_pwd$(user_name, pwd_verifier) 
 values('REPORTS', '0D9D14FE6653CF69');
insert into default_pwd$(user_name, pwd_verifier) 
 values('REPORTS_USER', '635074B4416CD3AC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RESTRICTED_US', 'E7E67B60CFAFBB2D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('REVIEWADMIN', '89CF8BDF46ED7128');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RG', '0FAA06DA0F42F21F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RHX', 'FFDF6A0C8C96E676');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RLA', 'C1959B03F36C9BB2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RLM', '4B16ACDA351B557D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RM1', 'CD43500DAB99F447');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RM2', '2D8EE7F8857D477E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RM3', '1A95960A95AC2E1D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RM4', '651BFD4E1DE4B040');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RM5', 'FDCC34D74A22517C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RMAIL', 'DA4435BBF8CAE54C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RMAN', 'E7B5D92911C831E1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ROB', '94405F516486CA24');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RPARKER', 'CEBFE4C41BBCC306');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RRS', '5CA8F5380C959CA9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RWA1', 'B07E53895E37DBBB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXA_ACCESS', 'F502B0CF72A32DE3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXA_DES', '27CE2AC19A98CE9C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXA_LR', 'D13AF40CCA5F3915');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXA_RAND', '6345DA1B5503537B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXA_READ', '6D8E49FC0F60ED57');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXC', '043FA64BA9C19AB9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXC_COMMON', '7A5E40AD77667314');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXC_DISC_REP', '8769BDF187623626');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXC_MAA', '4F7E585AF66C8D1A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXC_PD', '62D0273BFE2D71EA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXC_REP', '47FE00E292BD12BF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXC_SERVLETSP', '8CBCAC11A95CBF3B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('RXC_SERVLETST', 'E1D2A7B96C1DBA94');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SALLYH', '21457C94616F5716');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SAM', '4B95138CB6A4DB94');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SAMPLE', 'E74B15A3F7A19CA8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SAP', 'B1344DC1B5F3D903');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SAP', 'BEAA1036A464F9F0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SAPR3', '58872B4319A76363');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SARAHMANDY', '60BE21D8711EE7D9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SCM1', '507306749131B393');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SCM2', 'CBE8D6FAC7821E85');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SCM3', '2B311B9CDC70F056');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SCM4', '1FDF372790D5A016');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SCOTT', '7AA1A84E31ED7771');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SCOTT', 'F894844C34402B67');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SDAVIS', 'A9A3B88C6A550559');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SDOS_ICSAP', 'C789210ACC24DA16');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SECDEMO', '009BBE8142502E10');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SEDWARDS', '00A2EDFD7835BC43');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SELLCM', '8318F67F72276445');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SELLER', 'B7F439E172D5C3D0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SELLTREAS', '6EE7BA85E9F84560');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SERVICECONSUMER1', '183AC2094A6BD59F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SERVICES', 'B2BE254B514118A5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SETUP', '9EA55682C163B9A3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SH', '1729F80C5FA78841');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SH', '54B253CBBAAA8C48');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SH', '9793B3777CD3BD1A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SI_INFORMTN_SCHEMA', '84B8CBCA4D477FA3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SID', 'CFA11E6EBA79D33E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SITEMINDER', '061354246A45BBAB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SKAYE', 'ED671B63BDDB6B50');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SKYTETSUKA', 'EB5DA777D1F756EC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SLIDE', 'FDFE8B904875643D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SLSAA', '99064FC6A2E4BBE8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SLSMGR', '0ED44093917BE294');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SLSREP', '847B6AAB9471B0A5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SPATIAL_CSW_ADMIN_USR', '1B290858DD14107E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SPATIAL_WFS_ADMIN_USR', '7117215D6BEE6E82');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SPIERSON', '4A0A55000357BB3E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SRABBITT', '85F734E71E391DF5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SRALPHS', '975601AA57CBD61A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SRAY', 'C233B26CFC5DC643');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SRDEMO', '7C3269BF04F441BD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SRIVERS', '95FE94ADC2B39E08');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SSA1', 'DEE6E1BEB962AA8B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SSA2', '96CA278B20579E34');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SSA3', 'C3E8C3B002690CD4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SSC1', '4F7AC652CC728980');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SSC2', 'A1350B328E74AE87');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SSC3', 'EE3906EC2DA586D8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SSOSDK', '7C48B6FF3D54D006');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SSP', '87470D6CE203FB4D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SSS1', 'E78C515C31E83848');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SST', '2DACCD0C919B4435');
insert into default_pwd$(user_name, pwd_verifier) 
 values('STARTER', '6658C384B8D63B0A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('STRAT_USER', 'AEBEDBB4EFB5225B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SUPERUSER', '84DEF330533B56EF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SUPPLIER', '2B45928C2FE77279');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SVM7333', '04B731B0EE953972');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SVM7334', '62E2A2E886945CC8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SVM810', '0A3DCD8CA3B6ABD9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SVM811', '2B0CD57B1091C936');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SVM812', '778632974E3947C9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SVM9', '552A60D8F84441F1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SVMB733', 'DD2BFB14346146FE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SVP1', 'F7BF1FFECE27A834');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SWPRO', '4CB05AA42D8E3A47');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SWUSER', '783E58C29D2FC7E1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SY810', 'D56934CED7019318');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SY811', '2FDC83B401477628');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SY812', '812B8D7211E7DEF1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SY9', '3991E64C4BC2EC5D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYMPA', 'E7683741B91AF226');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '0B4409DDD5688913');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '12CFB5AE1D087BA3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '1FA22316B703EBDD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '2563EFAAE44E785A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '2905ECA56A830226');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '3522F32DD32A9706');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '380E3D3AD5CE32D4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '41B328CA13F70713');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '43BE121A2A135FF3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '43CA255A7916ECFE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '4DE42795E66117AE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '5638228DAF52805F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '57D7CFA12BB5BABF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '5AC333703DE0DBD4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '64074AF827F4B74A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '66BC3FF56063CE97');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '691C5E7E424B821A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '6CFF570939041278');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', '8A8F025737A9097A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', 'A9A57E819B32A03D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', 'BE29E31B2B0EDA33');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', 'D4C5016086B2DC6A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS', 'E7686462E8CD2F5E');
insert into default_pwd$(user_name, pwd_verifier)
 values('SYSBACKUP', '23AA48ACB42ADCF9');
insert into default_pwd$(user_name, pwd_verifier)
 values('SYSDG', '6C6198D0644CF9B4');
insert into default_pwd$(user_name, pwd_verifier)
 values('SYSKM', 'F2DCB573DBFEDD9E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS7333', 'D7CDB3124F91351E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS7334', '06959F7C9850F1E3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYS_ADMIN', '4B85054970355BBD');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSADM', 'BA3E855E93B5B9B0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSADMIN', 'DC86E8DEAA619C1A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSB733', '7A7F5C90BEC02F0E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSMAN', '447B729161192C24');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSMAN', '639C32A115D2CA57');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSMAN', 'EB258E708132DD2D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '02AB2DB93C952A8F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '10B0C2DA37E11872');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '135176FFB5BA07C9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '1B9F1F9A5CB9EB31');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '203CD8CF183E716C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '2D594E86F93B17A1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '4438308EE0CAFB7F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '4861C2264FB17936');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '49B70B505DF0247F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '4D27CA6E3E3066E6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '604101D3AACE7E88');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '66A490AEAA61FF72');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '685657E9DC29E185');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '69C27FA786BA774C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '86FDB286770CD4B9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '8BF0DA8E551DE1B9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', '970BAA5B81930A40');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', 'B171042374D7E6A2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', 'B49C4279EBD8D1A8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', 'D4DF7931AB130E37');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', 'D5DD57A09A63AA38');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', 'D7C18B3B3F2A4D4B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', 'E4519FCD3A565446');
insert into default_pwd$(user_name, pwd_verifier) 
 values('SYSTEM', 'FAAD7ADAF48B5F45');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TAHITI', 'F339612C73D27861');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TALBOT', '905475E949CF2703');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TDEMARCO', 'CAB71A14FA426FAE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TDOS_ICSAP', '7C0900F751723768');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TDX', 'C54CC64803BD0EEB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TEC', '9699CFD34358A7A7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TEST', '26ED9DD4450DD33C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TEST', '7A0F2B316C212D67');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TEST_USER', 'C0A0F776EBBBB7FB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TESTCTL', '205FA8DF03A1B0A6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TESTDTA', 'EEAF97B5F20A3FA3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TESTPILOT', 'DE5B73C964C7B67D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('THINSAMPLE', '5DCD6E2E26D33A6E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TIBCO', 'ED4CDE954630FA82');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TIP37', 'B516D9A33679F56B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TMS', 'CD5EB4CEAB7AAA3C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TOPIC_WORKFLOW', 'B2C5C84617D2C002');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TRA1', 'BE8EDAE6464BA413');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TRACESVR', 'F9DA8977092B7B81');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TRAVEL', '97FD0AE6DFF0F5FE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TRBM1', 'B10ED16CD76DBB60');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TRCM1', '530E1F53715105D0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TRDM1', 'FB1B8EF14CF3DEE7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TRRM1', '4F29D85290E62EBE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TSDEV', '29268859446F5A8C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TSMSYS', '3DF26A8B17D0F29F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TSUSER', '90C4F894E2972F08');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TURBINE', '76F373437F33F347');
insert into default_pwd$(user_name, pwd_verifier) 
 values('TWILLIAMS', '6BF819CE663B8499');
insert into default_pwd$(user_name, pwd_verifier) 
 values('UDDISYS', 'BF5E56915C3E1C64');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ULTIMATE', '4C3F880EFA364016');
insert into default_pwd$(user_name, pwd_verifier) 
 values('UM_ADMIN', 'F4F306B7AEB5B6FC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('UM_CLIENT', '82E7FF841BFEAB6C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USER', '74085BE8A9CF16B4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USER0', '8A0760E2710AB0B4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USER1', 'BBE7786A584F9103');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USER2', '1718E5DBB8F89784');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USER3', '94152F9F5B35B103');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USER4', '2907B1BFA9DA5091');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USER5', '6E97FCEA92BAA4CB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USER6', 'F73E1A76B1E57F3D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USER7', '3E9C94488C1A3908');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USER8', 'D148049C2780B869');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USER9', '0487AFEE55ECEE66');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USER_NAME', '96AE343CA71895DA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('USUARIO', '1AB4E5FD2217F7AA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('UTILITY', '81F2423D6811246D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('UTLBSTATU', 'C42D1FA3231AB025');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20030630', 'CDF997929CB32296');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20030830', '0296B70EDF2F6D12');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20030930', '9A3132568CBD8671');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20040228', '2082CA57AC3B539D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20040730', '6A5382B2D26F5C2F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20041231', 'CA90ACC53F05939B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20050331', '88F83DE4C7C1078D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20050831', 'F53F3146B1E588D6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20051130', '18287AD3ECB05973');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20060430', '36C3BFD4C70F837A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20060831', 'C5EA79CB93383376');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20061231', '6A284BC493532EE9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20070430', '8BCA034F0C849F28');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20070630', '0164A811FE2DC07C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20070930', '8F0C41ACDC9EE245');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20071231', '773214F8A58D83BF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20080331', '9D5CBCF847477CD3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20080630', '1F0FDE06936F622C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20080930', '12AC4AB3A4EB614F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20081231', 'F47015B16B9BF2EB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20090331', '507E782DB2C0C6D5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20090630', '198BB4B0CC9DD584');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20090731', '7AEE5F28445ECD48');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20090831', 'B491B87D024A3932');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20090930', '0A85B2890E01B3AA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20091031', '553655F120A1EB62');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20091130', 'FDAFF6A0342D3730');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20091229', '55D8C7CB0E6596FA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20100126', 'C43D5575EB26D840');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20100226', '5AF1099CB8BB22F8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20100330', 'BD9A77D38C6C900B');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20100428', '4091537BCA98EEF5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20100525', '1B3070771E7469BC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20100609', '1ADC35D4F79E62CC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20100630', '3586DA8C0CA004EE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20100731', '066FE66637730875');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20100831', '17F4FC2D74F88DD3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VAERS_20100929', 'E984FE429A34AD85');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VEA', 'D38D161C22345902');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VEH', '72A90A786AAE2914');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VERTEX_LOGIN', 'DEF637F1D23C0C59');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIDEO31', '2FA72981199F9B97');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIDEO4', '9E9B1524C454EEDE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIDEO5', '748481CFF7BE98BB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIDEOUSER', '29ECA1F239B0F7DF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIF_DEVELOPER', '9A7DCB0C1D84C488');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2004Q1', '4B930EA0BE7FECC0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2004Q2', 'CDEF239EF7E020AA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2004Q4', 'C803B977B7D2B886');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2005Q1', 'A0FED62B094E2289');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2005Q2', 'D94B7723B29C2026');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2005Q3', 'F4FD430B66276735');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2006Q1', '1CAC460D5B9359EB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2006Q2', '2A64E8ED0637CCB9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2006Q3', '1948C80A083BC35F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2006Q4', '599F49341CF69297');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2007Q1', '52AF59E4F71FA115');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2007Q2', '1A8ACFEEFEAD6869');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2007Q4', '65791B5D0ECFE92D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2008Q1', 'B038C499DE0172B1');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2008Q2', 'C9F912BE179351A6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2008Q3', 'FB03D019DB5CC845');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2008Q4', '152D25FBCED23D0F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2009Q1', 'B1EF2B764D669C17');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2009Q2', '784638E86EA277A8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2009Q3', 'B89646A8F99E149C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2009Q4', 'CC14A3B78AFAADA7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2010Q1', 'DAEF55DED52361C6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2010Q2', 'A36B41E6A2BE0B58');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_2010Q3', '281D440F69271FB0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIGIBASE_4Q03', 'CAEF79B487B4FAB7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VIRUSER', '404B03707BF5CEA3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VP1', '3CE03CD65316DBC7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VP2', 'FCCEFD28824DFEC5');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VP3', 'DEA4D8290AA247B2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VP4', 'F4730B0FA4F701DC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VP5', '7DD67A696734AE29');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VP6', '45660DEE49534ADB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VPD_ADMIN', '571A7090023BCD04');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VRR1', '3D703795F61E3A9A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VRR1', '3DA1893A5FCA23BF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('VRR1', '811C49394C921D66');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WAA1', 'CF013DC80A9CBEE3');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WAA2', '6160E7A17091741A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WCRSYS', '090263F40B744BD8');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WEBCAL01', 'C69573E9DEC14D50');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WEBDB', 'D4C4DCDD41B05A5D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WEBREAD', 'F8841A7B16302DE6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WEBSDM', 'B206E5E0464DD604');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WEBSYS', '54BA0A1CB5994D64');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WEBSYS', 'A97282CE3D94E29E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WEBUSER', 'FD0C7DB4C69FA642');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WEBVDME', '3D47789E3901C113');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WENDYCHO', '7E628CDDF051633A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WEST', 'DD58348364219102');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WFADMIN', 'C909E4F104002876');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WH', '91792EFFCB2464F9');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WHODD_2009Q3', 'FF3D721BC94FAB0A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WHODD_2009Q4', 'A14FB6ACBC4AE580');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WHODD_2010Q1', 'FB3A696AF4D38414');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WHODD_2010Q2', 'B7EADA25FE921B10');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WHODD_2010Q3', '979988427DFFA0FC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WIP', 'D326D25AE0A0355C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WIRELESS', '1495D279640E6C3A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WIRELESS', 'EB9615631433603E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WK_PROXY', '3F9FBD883D787341');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WK_SYS', '79DF7A1BD138CF11');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WK_TEST', '29802572EB547DBF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WKADMIN', '888203D36F64C5F6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WKPROXY', '18F0B0E50B9F7B12');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WKPROXY', 'AA3CB2A4D9188DDB');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WKPROXY', 'B97545C4DD2ABE54');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WKSYS', '545E13456B7DDEA0');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WKSYS', '69ED49EE1851900D');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WKUSER', '8B104568E259B370');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WMS', 'D7837F182995E381');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WMSYS', '7C9BA362F8314299');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WOB', 'D27FA6297C0313F4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WPS', '50D22B9D18547CF7');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WSH', 'D4D76D217B02BD7A');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WSM', '750F2B109F49CC13');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WWW', '6DE993A60BC8DBBF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('WWWUSER', 'F239A50072154BAC');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XADEMO', 'ADBC95D8DCC69E66');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XDB', '88D8364765FCE6AF');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XDB', 'FD6C945857807E3C');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XDO', 'E9DDE8ACFA7FE8E4');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XDP', 'F05E53C662835FA2');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XLA', '2A8ED59E27D86D41');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XLE', 'CEEBE966CC6A3E39');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XNB', '03935918FA35C993');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XNC', 'BD8EA41168F6C664');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XNI', 'F55561567EF71890');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XNM', '92776EA17B8B5555');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XNP', '3D1FB783F96D1F5E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XNS', 'FABA49C38150455E');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XPRT', '0D5C9EFC2DFE52BA');
insert into default_pwd$(user_name, pwd_verifier) 
 values('XTR', 'A43EE9629FA90CAE');
insert into default_pwd$(user_name, pwd_verifier) 
 values('YCAMPOS', 'C3BBC657F099A10F');
insert into default_pwd$(user_name, pwd_verifier) 
 values('YSANCHEZ', 'E0C033C4C8CC9D84');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ZFA', '742E092A27DDFB77');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ZPB', 'CAF58375B6D06513');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ZSA', 'AFD3BD3C7987CBB6');
insert into default_pwd$(user_name, pwd_verifier) 
 values('ZX', '7B06550956254585');

commit;

-- Accounts for nologin users with no default password
insert into default_pwd$(user_name, pwd_verifier, pv_type)
 values ('XS$NULL', 'NOLOGIN000000000', -1);

commit;

-- Accounts that should be skipped
insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
 values ('APEX_040200', 'NOLOGIN000000000', 'Oracle Application Express', -1);
insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
 values ('APEX_050000', 'NOLOGIN000000000', 'Oracle Application Express', -1);

commit;

-- Insert SHA-1 hash values of Default account's default passwords.
--
-- For most accounts, we store the SHA-1 hash of the default password. 
--   Note that as part of the enhancement bug-13843068, we inserted SHA-1 hash
--   values for trivial default passwords, namely <account_user_name>,
--   'welcome', 'welcome1', 'change_on_install', and 'tiger'. For rest of the
--   non-trivial default passwords, we will need to inform the owners of
--   default accounts (and probably file bugs), for adding SHA-1 hash values
--   into default_pwd$. We will document the required procedure for generating
--   the SHA-1 hash of default passwords.
--   For example - DBMS_CRYPTO.HASH (paintext_password, DBMS_CRYPTO.HASH_SH1)
--   api can be used.
--   Example : select dbms_crypto.hash(utl_raw.cast_to_raw('welcome1'),3) from dual;
-- 
-- In 12.1, 10G (O3LOGON) verifiers would continue to exist in default_pwd$ for
--   default accounts, whose SHA-1 hash is not available.
-- Eventually the plan is to remove all 10G verifiers from default_pwd$, once
--   SHA-1 hash for all default accounts are available, probably in the next
--   major release.
--
-- IMPORTANT NOTE: For default accounts, which have multiple default passwords,
--     the SHA-1 hash values MUST be added for all passwords at once.

insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AASH', '93836BF1AD4995401B2176D2A2080CE592B10861', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ABA1', '429D486402E600CBC7B6A0DAEFF0288CA14B71A6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ABM', 'DCD67D1087E07B87A59BB90A9324A369479CCB75', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ADLDEMO', '5BF04A065A51B45D1545205A3CBAF16B9D319B40', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ADS', '6DFEBD9FC5E36A9FA75BF79090DB66496C27A436', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2003Q3', '629DA034F42947ED770946FEEBF043B4AAE2A768', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2003Q4', 'EFFDCCC720EE8614582C5ADEFDD11B44B43E0445', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2003Q4_REV2', 'C60A2FB0BDC9C8A25EF1B9E8E5D1D4310D30DDE4', 
1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2004Q1', '7584F51AA7F785114ECE212D592EC9CBD6EC2786', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2004Q2', 'FDBE1FDFD10F8706723CA6ABB81D11C6C7932441', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2004Q3', '8108500B74225DEBBF0A9525D0ABA9DDC70E534E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2004Q4', 'CD3CC9FA1B620718FB047DDC3F4C6C31B34AA362', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2005Q1', '5B4DC43A496B8C89F80D8E76D117980A882B83B3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2005Q2', 'E1CB16D0F9A2102B8FA17E2E0EB0006089583899', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2005Q3', 'D88EDFBB04B4210DE3895E07E7C1DE7D4D0EBE16', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2005Q4', 'F0F7373BFF11E668706C037B37E042DC4D6A985C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2006Q1', '7F7100EA14486F5B0533F184E570E421EDF49B85', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2006Q2', 'E8D89D3F729B9BCCF45D63D4CAD525DDDD7548C7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2006Q3', '72158737FBCF88CAA8385A94526CA5C392965018', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2006Q4', '2B6E1C2F99AC110619A287CD8615AA484BC6583C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2007Q1', 'FE23E2DD7ED6E724F150610E2B8E6436A244128D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2007Q2', '806741D92F9A6F329B0E65A96B126A08E79F9D2C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2007Q3', '210A8DC790A093EA750FFA078F989E04DFF7C7C0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2007Q4', 'A952D663288EB007F1605B87527BAC81E3B55271', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2008Q1', 'CEC6BEE5B07449CB73A47F973B8FAEBF2ED991DE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2008Q2', '581477AAA82E79DF99DD7ACEA7B621D86EB258A5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2008Q3', '5EA48502876F84910B2B742632B9B771C8DFCDF0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2008Q4', '65E2270D860BDBEAB325518CB0BBAC027191A5C3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2009Q1', '31A5870A3DCF8CCB4B4DF49D7AC00A265EF5C497', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2009Q2', '8878C5293F5B32A7BC5996D4F5B18044B1520E51', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2009Q3', '8B46E507585374EBA02C320F2B464D624DBE0CC2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2009Q4', '52818BFF492F17124B751C40D107C89048E8B2B2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2010Q1', '1AE83566CC3D57D78399301CC27BA5551202C6E6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2010Q1_REV2', '1E50EC2A65980667EF013651467CB5866451344C', 
1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2010Q2', 'A23795ECA10F6438EF2AD0C05ADC0F69E2CFA72D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AERS68_TO_2Q03', 'CE224DEE3C39DF423B357C793701DA42B74AA9DA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AHL', 'D7C4A3DCEA713213A353CF0E8875E3BB8B34EFBE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AHM', 'CD290E205D4B7D97975383C26F2402ACF1BAE679', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AIA', 'D7F0FDFF69A6EA34C5C7E1B1D25C31E452F90BEF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AK', '0474AEE45985F5AE829F53849DF476200E876990', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AL', '2F9EE2B336682012CB445DA6F3A0A52C68CAF471', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ALA1', '3442CCEA318347436A2F109D244141CE2991778A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ALLUSERS', 'C58AF50F8E4EBCFD619EDAF06017F95750F2E79B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ALR', 'DD5BCEB0AFB06692016B47627ACE3B52EFD7C1F7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMA1', 'ACEDA6EC3C69E4CE79A1B5090FAC9F3E7FF44A22', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMA2', 'F2799425B72177F6D0FB86D2E4C0DBE8D8E1C5C8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMA3', '91513167C269454A7C208F0660C2D87C9A226B7C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMA4', 'F3C5E50D67291C0C7AC6D3821CB058047426D164', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMF', 'BF20BE8C57C92F523B3D479CAD942C9F5E98B422', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMS', '044A2F5446224495D6813D561C55539F695C57CE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMS1', '866E49D9CAF518400E3C0B185F8D5BC3628167A5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMS2', 'EDA46E07EDDF74E4F455BBAB2F668ED629F3761B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMS3', 'A4E42E56095434251CEEB7B350548E5900BF0120', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMS4', 'D08D9EB064D80EB1162611CD98D08BE8F4F0D9DD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMSYS', '02EEC7263BA46C40FA3892C9FEA327A7C93431BF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMV', 'C6F9348399D3643272D0027A4D48A7F6531F72DD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AMW', '9B69439A17287C6CD9F1ED196F93DEA77D02F1DB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ANNE', '96657FD33D4351FB0EC777FD7064E03B0ADC3A35', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AOLDEMO', '2F413744D8D2603F36412A0F49F9C0AE8FBAEECD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AP', 'AC78B022715C5B8357B4DCA8045E8463B4DE2124', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('APA1', '1BA9C6BBC50522B9FEE2F1A5972BCE3AAFB17AB8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('APA2', 'AC9B3DF8539D95701743E8D58120477F72267EC9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('APA3', '2AC5EACE06C5ABCC999ED5D8155E5F96C7947338', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('APA4', '6354F3241581A663527324C18748321D0B7A21F2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('APPLEAD', 'A8D55F7BE44C373F8F3C4C51BAD6E2C24E83E7AE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('APPLMGR', '3FC39C34816210385A1BE141D5C15F7316E31F0C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('APPQOSSYS', 'C1C085E2D6C3D7960D2A6C49F9B311BECE722E66', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('APPS', '8025087A9E2E8D0E95E2DA2152E8BE2F55276616', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('APPS_NE', '2B1031CB468CC13FE315F2589F632019DD40AF9E', 
        'Oracle E-Business Suite', 1);

insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('APS1', 'A13D48262798E0394286C20366AD462B5F2735ED', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('APS2', '61183194BB211DCF0F798171270963D284E376DF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('APS3', 'AEB135ACBD3A87150E584132526992A865134CE2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('APS4', '8DCD011FC125CF9E3FAB1311D74122672BC9EF74', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AQ', 'B3A7C645306726EF4965C7BE7E859EC0EFD9AF5B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AQDEMO', '096E8959879DDB4D1EE0BCF4B52A62482BEB7C92', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AQJAVA', '629646E5DE8716995550FD12000591A84B2C4606', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AQUSER', '9B0BCB74117736172175EC10D9F5B7962E088A89', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AR', '23D8E0156062165CA3736E9F1E364D414E1D82D5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ARA1', '8CDA64E8DAE18D2DF8CCF71E64DB26F1FAA76EB7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ARA2', '0B7680B4C98F5A6D20B8717DAC526B310C144D11', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ARA3', '02B90A7C66DA5EC208C4E970C1A8AF0808B55EAD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ARA4', '08C04EB094A15C78134EC18D942D0BF5ACE84D89', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('ARCHIVE', 'EBFB55F4432B592119A10592E4F26272CC72359E',
        'Oracle Transportation Management', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ARS1', '81A1670B9E023CA6F01905F9D416EB88E929110B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ARS2', '8C544CC749EA6D673C1EB8F8CFD847AA14E7DB79', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ARS3', '4F95DA4A72C4DBEA410AEEA58878C68A05A4F3CD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ARS4', '909E818D06DE694489399A57311BE008313185EF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ART', '4F468A6824D620BF0F58640C0BC423BCB35DC48F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ASF', '74DC916419A178D22CB0FC8A04F62D345784AD7D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ASG', 'F14D672A97C92AAFF11D4CCEF8A5013F039AE2F0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ASL', 'ACC4BDF2058907EBA316B34CA508F3909CDC47CE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ASN', '5BE00DDC76278CF6077F5047CA3384A88460C671', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ASO', 'F8828BA42980393B1CE4B6C56B700EB35349EE30', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ASP', '8CBA0C656CA9CECD80F976C0B66CDBDC03D3BB83', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AST', 'C24C0248770AE98831F8A654310D4C2E07514C61', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2005Q2', '57217EED66F3E757D8A594176D8D7961630555D7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2005Q3', '0CB2FBFD5DD1B68BD2E5B10FFF4A789494A7C677', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2005Q4', 'ABB97D0430FDE5AE5B2AC3F03C6DF00C7645E710', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2006Q1', '38C7A7C8DEFCABAA0AF9A78EA96AE4EB48F31485', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2006Q2', '1E6EF3667B1B88A69BCCC43B93786EC9E52AB2B0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2006Q3', '52270C117AD47C92FD560833E27AC365706F0147', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2006Q4', 'F08A5CFAB82BD38E0B4CFFC52BB8F45843059DE4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2007Q1', 'FC485D631C8EEFAD31B35DB469688ABC15E39ADA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2007Q2', 'A1C01231BDE577F934B45F8389FA7521021B169F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2007Q3', 'B436AABECA54E4BD7790E758470FB1BB83290D51', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2007Q4', '4ED0B8A17AC77B3833496F78A1E57612AD8684D3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2008Q1', '375216726B3672CE36CF4A317CBD69022CB745D4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2008Q2', 'A4B0348C3CCFE9E0ED22F0551809EDBD7156E000', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2008Q3', '6A577770377CA10602D4A337FC36161B121B8C93', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2008Q4', '05BC0822622F9D5D11044715F5F3DBDB98624681', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2009Q1', '529EA7701BD7E4A1D67DD19A67A9A5B3F2A91D22', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2009Q2', '3E1E50D5D0C3FBCE264C972A2C1AEDE96A486958', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2009Q3', '0BA9CB0D2AC835CDEFB113E10B1BA6313A1152DC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2009Q4', 'AED55B2D0835D6685232E40FDF407389E8613320', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2010Q1', '1DA57815201D761E01CEBDFEE33A3C37B2337AC9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ATC_2010Q2', '9102CD501587480F1C98F3D21B8E9245759ABB10', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AUC_GUEST', '6B7F0CC0949E594C4AB3FA8E70912CAFD61A9099', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AUDIOUSER', 'A96654A3FFB37249526516107E6AF8556C93E125', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AUTHORIA', '648BD154F588A260C6870D4C5776B9B26F258CDB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AX', '2A2E1206B4222B0D7CC8C8A1D8B302EE70CFE817', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('AZ', '90283840D90DE49B8E7984BD99B47FEE0D4BD50D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('B2B', '5717E672F7D956071DB0E6ADCE74FEBDA48D174E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BAM', '7AF258594B50FF874A047B54A92442E81F458CFB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BC4J', '3F96D86BFF92C05AA09344E3BE0F398CCE782A57', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BCA1', '3B2D530883D1F373AFB63EEE37879C1B3004FCE8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BCA2', 'F431969F3E2C6664C5F360AAAB4DD765EBABC400', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BEN', '73675DEBCD8A436BE48EC22211DCF44FE0DF0A64', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BIC', '4879099D57F427429E87DEA5C0390256D00C8984', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BIL', '525298336F32B2571F53CE0A7C9BFC8B0FB4E709', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BIM', '65614E8ECB984D01581C4443E9E91284F8802C06', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BIS', '1094CD06521B8BAC30018B3F8E57245E0B416F21', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BIV', '5D4426F4EC63AB6F60A4171C1B02AA4B0DF1C96E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BIX', 'D2C6E78FB7D6FC51A8FE16CC27E61EE8673B4C9A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BLEWIS', '3A388D65EA5FA2D139AD1397C694C6BF06203449', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BMEADOWS', 'E850601504505837F1CE3A045A4255DD2CD729C3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BNE', '26718D3C7A5A040DF30607D5E6A2B533388640B0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BOM', 'E9AAB82CDD01BE804CF30D307BD41242CCB48030', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BP01', 'FEBDA22EB97DDBBD6C6CE765E15FB2B63D50A10D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BP02', 'DCFA91040D1EB577AEF7C4033D284221D7FE2D01', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BP03', '21E08E0FD994BF388D3D95157D1C073714806817', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BP04', '5E7B543028FD857DBAD2E29D57D1BD177ADB8E39', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BP05', 'A7865D641F2F11BFD2A7932A4D1D64AA015EBFA4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BP06', 'B2B32C7C7B102DEC24D4BDD88CE12967642AF761', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BRIO_ADMIN', '74F226FDFEC2AEC5BFF623BA1D1747764A9D884A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BSC', '06C8FEEAECC6210C100ABB3FC66D032EACA43AB2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BUG_REPORTS', 'E5F2DD14F271E81D3539E1A38FCEAB6970C4C648', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BUYACCT', '51BFE4044ECCC29A0BF868421F1249A4DDD76296', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BUYAPPR1', '1B29CEA1AC9D20F6BAE0A6306AD65548E43DD108', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BUYAPPR2', 'BCDD3607333F799191699C481BF98BB73A3B3B92', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BUYAPPR3', 'AF400ED771FD6ADF8F50FA75D802708096503939', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BUYER', '9B165E49DA3C5629A2DCE8F7D7ABBDD7025973D5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BUYMTCH', '6BD3D68218EAEBD71E776BFFF146C491CE66C98E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CAMRON', 'CD793270FAC693B5C263E23D7626E00CAE3974AC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CANDICE', '95B1CE07083615380ABBAEE8594C78BB0C849619', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CARL', 'DE187642E6C75F60D10F29E52CAB54CDF676870D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CARLY', '9B42B220353322C31FC307C1579E31378B7932DC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CARMEN', 'F1196A8A993E28D05BD187B7B130720E5DD34147', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CARRIECONYERS', '80FB4450265E26DC860BB427EDB0C684DDB9F4C0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CATADMIN', '180A2F6C67D75A1C8E938A4A5783E199AF54423B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CATALOG', '41DABAE7B9269B285D97D343465FADF2FC075403', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CCT', '7F4761DE4411C6F1B57D4F6441AE77403F2A9389', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CDEMOCOR', '93C49B92297A51C95BDBA8CCB5713B93E051351C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CDEMORID', 'AB82683764D4D117FF6A68B2C454A3283D468C66', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CDEMOUCB', 'C893EEA2E6334FC34EAC70CBA216A79D7518C31C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CDOUGLAS', '67EB27410B7A0DC9BD1502CD854D1F8A1803D384', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CDR_DPSERVER', 'B0456CD9F732C762B19ADE2A76AD8CD925CFCE7C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CE', 'B452D6B23B3C28F85872FFFD99BDAF90CE0AD44A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CEASAR', '4EEF14ED6FD7DFBDF6C7AACEED1708507945089B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CENTRA', '9520F6384D0DC5A856B1262A8D4B3F57A94295CB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CENTRAL', '233EC5BDA5FA468329234788B4EE61711EA3041E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CFD', '260476B04D097F0CE6CAF10E8013652613EFCB5A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CFLUENTDEV', '737822012EE0D85B9B1696E6F9ACC5946B10D1B3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CHANDRA', '83887BB2D75A1E112132CA1E7E0326D8838DDC50', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CHARLEY', 'A2702B31297A8BEA4230CB2EBC954564264FD4B7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CHRISBAKER', '967F77A94FD61C87731C187E240FC1204EF6C264', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CHRISTIE', '734DE996CD326D39434B0F192FE069D6B567C24B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CIDS', 'E62A3F6CB73EDE63968F989B2C9584F32EC8C420', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CINDY', '08419F95F54BA7772A69A52CE1114111BF996B10', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CISUSER', '3397941CCB45C8D919D02BAC10FBBA6F23ABBC98', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CLAUDE', 'F1DDA22F6C87388A4EA6486ED19DFD0F6F6DF13D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CLIENT_STORAGE', 'FE9CD89C36D127ACABB4EC97CB69489E7EC5418D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CLINT', '1E115FEEAB9474B9D680E5528024201AF6E7722F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CLN', 'A30A39605565E9AE6550C7602A0CC3F30BA29A07', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('CMI', 'AF784114AD1A32BC6EB69761559C1DB1F2EE309E',
        'Oracle E-Business Suite', 1);

insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CN', 'B0BC9ABD90E2F7B3BFD695191E2D0034BB1B2F52', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CNCADMIN', '6F57767798BA70B1F68F5FF9DDE24E3F6BA57545', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('COMPANY', '71B21161FFA1E6516BCC072AAF5EF38CBE85B511', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('COMPIERE', '24B1F0C6A17C275B77C1F5DF6A28959634EB0B78', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CONNIE', '41A53AFFE46E1521428FCD2DC4C1450C97605A57', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CONNOR', '3777601FDBA3FE60E662FE93AD715E9272AB7C4B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CORY', 'D3CD8C1BB1103C73918D4961BC0326A234DE6ECB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CRM1', '8B08366B5A4B15B9A6535036D3730670B8235C8D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CRM2', '4D65F47081C3E6BE899D85C2FC4EDE9F6BC4AFFE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CRP', '06087587FD507799BCD6B8A3F8AF1B73D357AE96', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CRPB733', 'AA5AAEFC5C11550AED2D2B77AA5D69F8E6DAE3C4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CRPCTL', 'A6CA645FBB582A54EEE80255AEADD6CA7ED83927', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CRPDTA', '19A927B1182D7B833775E2A9A805D9A2EB1027D4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CS', '67F994533A5D976EED69AEAE05E381BF6FA851E8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSADMIN', '37263F1D75CC50EDAEB3F9B62522DDA3E48B1634', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSAPPR1', 'A1EC559B5120602ADA280AE4E104546C0F855CE7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSC', '7018D9174FB00AAA4B853B352D90B923967AB4C7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSD', '9F4921B51C2E573CEAD9AF22C0E0D1A14AD7B643', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSDUMMY', '7D4E5D033D9EAD0778B2529713BEA642D41D4986', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSE', '85ECD6D2618F55B416513A664CC4D7866F54FEDA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSF', 'E6FE8C2477900B754D901F07DCC61A8A82D4BACD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSI', '3CFE9D1883C5819DD5FDCC3C57FA7A892DB0C56C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSL', '09CC4F1A800D3F82E9B88E97195191C205E004C9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSM', 'B5F787BAD412BFE7ABAD9DEBB95439FA9889D6E1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSMIG', 'CEBFA59FFD0D35B347B51902DFAC93F5A2902836', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSP', '5FA036A3902F737E09BC005FD75B097B4A843A40', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSR', '4FE486F255F36F8787D5C5CC1185E3D5D5C91C03', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CSS', '2F84417A9E73CEAD4D5C99E05DAFF2A534B30132', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CTCLASSIFY', '231C044C59E535064B89496F0A7D1515A4E7CAF9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CTS', '70460C6BA8049D797B3B0F2922DCCA0387F2D258', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CTSCODES', '99502AD1F901EDE64B86967E0B67E1DE31F849E5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CTSDD', 'E5C74F50FF949D3D9F3003B4F8B9B5692E0CB289', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CTSRM', '39F333ABC7B01C37179683FB1692E34E03D20C8F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CTSRP', 'A510E9CBCF50AAF20C92A2623BFDC9203FE0003E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CTSYS', 'F59C849052950F5B34BDE49D801F4B50722FA89B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CTXDEMO', '90FCF4E3578F50DFD76AA1D325A0B02E7C3835CE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CTXTEST', '5424E22C844BA534ED18E6D5FC8FFB44054C8384', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CUA', 'D969D26757907AA87DD64584660E2C37F53057FD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CUE', '9F8D4E15A56DD462E34AA5996E287175E079553A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CUF', 'F65555FB67BFE1F7568368E81C932B47C9D0885E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CUG', 'D560C2DF67B8B588570ECD3B83CDBBFFE1837215', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CUI', '7C34B5D52E03DCCCCE8545670BEB1F8D037A6D92', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CUN', '5F1C3CC986F15FA8B571DDF46BF0AF7D1F3522D1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CUP', 'AD00C690D667F9DC6834A33AA36F56E2D3DF78D9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CUS', '0C12E642CA5B7ED4436E5F23F568AE10066608D3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CXFR_RECV', 'C483146ECAB6CD47C34E2C1307428F8B7DEA15A0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CXFR_SEND', '863303BA3E596D7025861D039C6EB71222011A5A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('CZ', '763E59C2E07C2124503B3BEF9E81977DFCBCA6BD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DAVIDMORGAN', 'C99F6EAD588E81CA6564615E2A62F86DF17041F2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DBSNMP', '70469C25E2D6FE4F5BDEE1D6BA8883300FB77862', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DBVISION', '4EE70FD59AD27365B3A96EE5F5BB89C3CC2CA20C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DCM', '13BBDE7EBA65CA4914749E79F9D581AB6F132601', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DD7333', '39369E5F2FCB5706CCDDA3002B960D6BDDAF9CFC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DD7334', '8365DF2B645F2EC6EA58BA131A9D084A97F606C0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DD810', '2239A8CAD112EC7DBBEC26165E5B96DF79B02E67', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DD811', '5C425A18335C2DAC805E72F94A75F636A4895820', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DD812', '8E3AE46929B4753EBFE62538AD6FE2B7E44D7F83', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DD9', '9965B9B0D41075E2022CA0F34F0C65D9DDB27758', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DDB733', '6A64547BB1515BAC5B68305DBEE62F2733D02973', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DDD', '9C969DDF454079E3D439973BBAB63EA6233E4087', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DDR', '040611A6DA7349A16E88B62549FBB1CDFAFF6B31', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DEMO', '89E495E7941CF9E40E6980D14A16BF023CCD4C91', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DEMO8', '1F0BB119FC4F9F23D3F6C2A2CF54563F45B6D62D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DEMO9', '9F1C4DF770EF43590C2D6AFDA28CC114D04EA604', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DES', 'E9D596E7807A846BC76A51E845FCC844F24DFDAA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DES2K', 'B0761E50E64E543E4E7155A4CB2963B9B49B21E6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DESIGNER', '1EC1E366509D9A83C84C6416696800D4F116AA92', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DEV2000_DEMOS', '57BDB45B47F5BB163031EA50B6AE1AF3CF2C168F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DEVB733', '963B33C23CB32E8315A77E0363440F3D9EF151F1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DEVUSER', '6E304E0AD2823B2DAAC2A3431992B2E562DA1255', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DIP', '6B665E89F23E1731F93655AC8D4D94BEDF4E1042', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DISCOVERER5', '810775232F6C2C237F0CA5D7F66B6FC34A3C2D42', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DISCOVERER_ADMIN', '7811384A14131A590AC2B5B793E8AE1FA16C4BB4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DKING', 'A3CD222EA982FEF7E4D761FBE5435903B90070AC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DLD', 'C4A82F8E649C6BB6B7CFE156B0ED27E29250F577', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DMATS', '0234CBDBB3DB45BCA8328351AFA20DE803C21FA5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DMS', '95C90C669677CCB62C95B44EB5E0545208A626E3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DMSYS', '47240A5729DF101C630DBA76CA6EC28E803DF222', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DNA', 'E521E1E5AAD683C75F5705C3B310F97CFF92B3BE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DOM', 'BE65D27AE088A0E03FD8E1331D90B01649464CB6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DPOND', '8061DB4F9595C95A8DF85C3EA71B9D4866C2529B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DPP', 'A378D430A3CAB642076A9D1BCB44AF26F0C5D008', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DSGATEWAY', 'A14678DE490D606B1C48FDF1FAA3360D0FEAC560', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DSSYS', 'BF8701EC12FD749AE9E4B9269A37C3807A8725EA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DTSP', 'ADD13B5BD76D770E9582B92CA87C0E1CD03F1EA7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DV7333', 'BC3EA03945576F0804C2B69D27BF75B7A5C7D56A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DV7334', '1784578CE8EF8756BCB3FEE71BEB850DC380BC17', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DV810', 'AECBE6B857A5D903710B095AB4F27B234D213897', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DV811', 'F703A6E1193928D88053AEBC5C3B2C1F4FFFBC29', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DV812', 'A5A28F3C8BCDB7F4BF5A52FDE02320A57606324A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DV9', '3C2F79364F9677B78E17E54A4EA5CD8CECA55E59', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DVP1', '456E0646BA34A19D51B91F773FA9D3EB340198C4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EAA', '6AAF2320CBD356952BB697AB1C880716599B85D0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EAM', '3CFBA047AAC84A1AB57474E4BD4888B5CEDEC14B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EAST', '25038D9DA4649A8FF094569A1FD3242C375F5FF2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EC', '7DD84750EE8571116CD2B06F62F56F472DF8BF0A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ECX', '4DA1C6FF01F14166925548020B84440A14519D8C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EDR', '5DB9A2B1E813F125B6A4BC288A866C9EDD9B9937', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EDWEUL_US', '075E7FF2C8B90D40B56EE4E9A4873B57556023EF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EDWREP', 'BDF4D65E472E43D05A0527A66C5A7CAC4BBDCE68', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EGC1', '23B91AAA96F78B46B6568E9957EE73C7695BE936', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EGD1', 'E15252C13D6D28C003F1EE47B918073E0E79DA70', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EGM1', 'F95C6241785B204448088D01041A1AA34FDD065E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EGO', 'C13571DBFFA0EB89C7F8EEBDCE482897B0F5A685', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EGR1', '109AF8B7F39941F59438E104CE3C43B4436FB2C5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EJB', '19F9A42870B2351122EDD83D3856869330FDCE2A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EMP', '2714379C50BF21B94AC61A5A5456D02A4BE96CC3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('END1', '6864EC0252611E2C16E9E0314F4583CB1B93EC86', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ENG', 'A4CD2AB840E08A5CBEE3BD3D914E8C4145DD58E5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ENI', 'ED078A55E38B83258445E5C84A52C0BA42A2F881', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ENM1', '9C757072CDD56B840944D8CB2C7D784A36D855D2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ENS1', 'B25E4CDD2A04C29FDBEA55DE2A26CD7A0C2E408D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ENTMGR_CUST', 'BA320AD747FD9199211F6999C283E555369E14C5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ENTMGR_PRO', '3783B746082FAE662F560F46B2D550B6EAFCC226', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ENTMGR_TRAIN', '592729C258691E2C66FB98000CA8C1788E669EAA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EOPP_PORTALADM', '78620AC8FAD50B6E8068002EB57EC19CEF6D1B16', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EOPP_PORTALMGR', '2EE2AE472DC94C6D9BB25D662DF420F2CF9CCDC0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EOPP_USER', '4E9066449A9735359C41591505C55737E4BACBEE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EUL4_US', '6DC279A7D8F19A921B7F0EA706DFA55FA8BDA964', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EUL5_US', 'E04B172ECE3B8E08716CAD8B0AC7011D2C744E46', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('EUL6_US', '65C7AC961D1F738D9E10DACC0AC11224570AA10A' , 
        'Oracle On Demand', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EUL_US', 'A7EAE890D0D34A3088992C31EF5898F80FED8D47', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EVENT', '5006ED0248A019713B762563076292379DAF07B4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EVM', '7A1D07549C26C3CFC6A630872F16D3D5C4D84E25', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EXA1', '657B252ACE5E273F183F4777C162F0CF70EF69FC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EXA2', '5362CCB9B7B8F54346B52ADBA328795CDFE916A7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EXA3', '5308AD1839837A45C2142AFA6027E26AF1892D4F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EXA4', '5D7DBE256FB2A0324B24FCB48DF87B360E88A6D1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EXAMPLE', 'C3499C2729730A7F807EFB8676A92DCB6F8A3F8F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EXS1', 'A49221E52634EED6E590EDB04DBDF11A292EAF8F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EXS2', '9C206F250D632526E0ABD4E833533F3511727E91', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EXS3', '36CE9EA5ACA9A093C1341F599B6B1C4E56A21272', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EXS4', 'B0F86EA66938886819D0ECECAFD92B3108F26FBA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EXTDEMO', '3E9C1B3838EC76CEBD376D583F9898D7D1DCF679', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('EXTDEMO2', '5FB688C625CECCCD2E33EF15402F2F038A44808D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FA', '215A956168F77421253E947C2436371D56AA7EA1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FEM', 'F4CE065B1DDAC900E9A9AF57CEEF34798CB7AC32', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FIA1', '929F337AE0CA2679B6F0F48807A6D5E5DB40B905', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FII', '9A1713670DFBEA244CFF5335E88B9E6A67644394', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FINANCE', 'A1CF62AF599E2C2403CD6542A3BBE8F828511BE8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FINPROD', 'F01A35A13F75D87E866BB2AD597C2C31FCC2A8F5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FLM', 'A2E8EC92E7D84DDAD76884CB1C7BC886D3F84BD5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FND', '8D1893DA33B92382795B4F4BECA1E6D051E3034E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FNI1', 'CE71BE10C6DDC8D28B6316552F0392686E27C2EB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FNI2', '633C6A8E7B0AD157EF4CCB7B4F501464B2E09790', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FPA', '49A9BAC4DD0E26F66BA0382517884241162A9868', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FPT', 'AE97E99D472A5CDE9BC56178F12EA81F1D848C8D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FRM', 'A534AC461DB4899DC18C1C5DCEDD00DF960F479E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FTA1', 'DABC0C0EFC75FCF46C8C95409D2C9391045C5A20', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FTE', '0B5BA6B7C946DC44BBFB4D173E848E585B0742EA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('FTIMASTER', '34EF8C3D51726073B8C5A85E1403918153378139',
        'Oracle Fusion Transportation Intelligence', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('FTISTAGE', '227A32D1E827BC8B16E3C85749F86CA7216330EB',
        'Oracle Fusion Transportation Intelligence', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('FTIWORK', '5D0093D59582E2CD23FAA593E08F270236EAC899',
        'Oracle Fusion Transportation Intelligence', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FTP', '7616BB87BD05F6439E3672BA1B2BE55D5BEB68B3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FUN', 'C84C50D5A767A23BDA0EA5CA348FED54C6DB9AAB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FV', '1BF1B0E203341358FC92932F29E888EAB36E6823', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('FVP1', 'ACA8E7FF0C064D64B8238BE227726362AA5A2EF7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GALLEN', '0B7D46B3F30CFE0520A3032DDE4CB3BC14DA529B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GCA1', '5B62B6967106EB9E39F3D6185E0602A84475D8B1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GCA2', 'D53E53203CD65CE4D03CA7A5653B6218CEDE8C31', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GCA3', '0D7502B37F5F5B77ADDAC5A0449185E8B864C914', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GCA9', 'EFAE759B4AD7E881C537EE58598D68CA7CB2CB72', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GCMGR1', 'F664FDCDD21ABDA1BB3C4B1C99FCD444D414B7C4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GCMGR2', '22366152A94DA7F875D5DDEDC436B5A0CA769C36', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GCMGR3', 'E0F421DB45ECF1CE0D049E46EB9ACAC28A6E6694', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GCS', '0FB84BD8524BD64B6571903270D70CD1836C4402', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GCS1', 'B175EC499DB414174504994EBCD6154069EEF2CB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GCS2', '8B681B1EFEE2DF8BB727C24D0FFEF409E5660FF6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GCS3', 'C17D90F514732561E823D4A0BF5C0D1D21AB8DB8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GEORGIAWINE', '40D6DDDCA7829DDC475DFF6235E72F19218A16A2', 1);

insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values('GGSYS', '4365A2A1F857CE9FA60C56AAF65EA3CD509056CB',1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('GHG', 'A872A7091157142C51B19AA6FD9AC48D9D34DA1C', 
        'Oracle E-Business Suite', 1);

insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GL', '5644A3F6D24DCD489C4300BDF0BEE118EB558724', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GLA1', '1D4DB523F815E479BFC30D99AD6A93DB351C7AC3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GLA2', '9FC17BC1281D896AB13F361E4CEBF0F366F733C3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GLA3', '65520E5E13E346BD82676B1A7473D7EBB7E0FD6B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GLA4', '33ADCE60BB7F4E6DEB24E7B91BA4C143031CDD47', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('GLOBALREPORTUSER', 'FCBD0EF1C6F55DE7575E4C14B6D424662C7CD2C2',
        'Oracle Transportation Management', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('GLOGDBA', '0A89EE853C0F983ACA580EA7AE992D5F63894ADC',
        'Oracle Transportation Management', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('GLOGDEV', 'D386D1BF49AD683125B3DBCEEAF9E3220E9D4519',
        'Oracle Transportation Management', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('GLOGLOAD', '5D4C5BBB912057C524498CD76F5A4B5D636AE0D3',
        'Oracle Transportation Management', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('GLOGOWNER', '76E028220FF5AF7C49D99871CC871E194F1033BA',
        'Oracle Transportation Management', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GLS1', '49DF0494FE480109283185BC54BB9C623128F1CA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GLS2', 'BB1BAF85B90E1CF427CCF6A3A9FB2A8F8F68D050', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GLS3', '073B37B52AC808C490056F84EDD9A6B0DA5BB024', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GLS4', 'FDA1D5E5FC7520831F2CDA943215D7CCAB459F70', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GMA', '07130962B269944FCB2AADC9DC4E10124B0C72AB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GMD', 'C2355FE56B85D48B36A272F6A925C533461A432D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GME', '1968E080303DD98561FF8AF7C34F61EA312573FF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GMF', '2E949D6BE63639A4FBD968C6E05F01139ABD4FAC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GMI', 'FC51EAB3DA07AFD5B9383CDA6374111E3280CA49', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GML', 'ABFC08E6EB08FB4FFFF6E389E1245C2FE40B8E1D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GMO', 'C17D6B71F407F37237418896CF19AB90B791A485', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GMP', '35CED0A2F0AD35BDC9AE075EE213EA4B8E6C2839', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GMS', 'BA8E5EA89B871D3E1BDBDF28B6431FF4FD2330F3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_AWDA', '7144EAC2C76610BEBFD191031CF1C0A9352F2F15', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_COPI', 'B58BC71BE2980C4921A83B024D21EC4E6D001E65', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_DPHD', '56A5AE08B65EB6677088863D0900F51EC3770052', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_MLCT', '93BDCFD1D74C742C07335EE9AC788543E5DC5806', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLADMA', '7F70AE50F33C7B3218C8E257841C6343826C8E99', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLADMH', '5E40B52969565676D965C46FCD8B7C0B1326F440', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLCCA', 'C12C5A910BC544BC9C91F061F4F60F02459715E8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLCCH', 'F899F7CD10A48223E01E377FE73BCCE6BEDC0FC8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLCOMA', '00545FFCF68FB583EEC274AD0739F8FB9FA2EBAF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLCOMH', '5CACB6F5767BDE53F566AF483EE9DE94BB08EF84', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLCONA', '0FE15DAB76DE5C32971DFFA93B39A683010AC0D7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLCONH', 'BC6717D50546DC0D6A1733D3AD49CE636C119662', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLNSCA', '2181DC30714C9C20840740FFC7EFD7C9915C343F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLNSCH', '79A28E16B24915F6721D61C1CD1CDBD4D713BDD3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLSCTA', '7CDDEE6D4283862212EC762EC69309D9EF513C52', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLSCTH', '352DCCFF9E72D39AE5B2D1D9EBBC8A37B338C7C7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_PLVET', '76F31F98134EEE7706A1CD478F7A9167835D3836', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_SPO', '2A4B8BA783680F5E0112D9122937784960041BCA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GM_STKH', 'EA38DAFA34650AE1688F48F5989F675BCFF7F3D1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GPFD', '2EA5AB6193FFF921AC2C58521CCC1744D9C2C596', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GPLD', 'AD0114F964A0F521E81C16ECA9290CC2ED2A86D9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GR', 'DE06109890D26A134F724246C64E1C553881974A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('GUEST', '35675E68F4B5AF7B995D9205AD0FC43842F16450', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('HADES', '5A957D5D3F8412885CE074F10B0DF9579DF530A1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('HCC', 'D55992BB08156A3C61266DC8DA14A49AEC014A92', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('HCPARK', '3E2DDB4977DADC853C085B2F7512AA7A44B04295', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('HDOWNER', '1F0F4191E1E217D9012306E4307A0E3D1614CF81', 
        'Oracle Fusion Transportation Intelligence', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('HHCFO', '7A7676DCC26850148DF308C7453338746B52B7D0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('HLW', '260C9A2F94883CE2184E5EBB400DCD4F915BB9E3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('HRI', '87D9D838CD4E04DFE2B7B803627E4FD1F5EFF6B3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('HVST', 'A4110A14D656926A22985CD2D3A652287948B0E1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('HXC', 'AD87A13EAAC82EBA4D92F723DB49A7D492ED542D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('HXT', 'A3315747720B11C4235C73A3A9F8BEB7ACE3A7CB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IA', 'F30ACCB48E68B071CB68125F46F669D5522B9EE8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IBA', 'FAFF30A7B98CF40DE60333AAC06D01BCE710188B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IBC', 'BBF10F9DD022293126972F5AA57DD6C643E646C8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IBE', '76940AB40759F4118A7CF955EC26C1D19D5110C8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IBP', '9B9D1CF3B0FD7F1C9329194290A847F6B3618A32', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IBU', '88E1F924153F511808FB2466274D34485BEC3EF1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IBW', '167CC4F24F42550F603BB4C823C71663FD26AB57', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IBY', '57078F1F26922DFA7C93D7FF5E296D6FEF6A23B5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ICDBOWN', 'AEE1655924AECB0DE95E07C892602236952AE4A8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ICX', '2C5B213C5057E28D0AED4542A3C35FA20B356069', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IDEMO_USER', 'E03111983ADC61A6CFC9AC7B97086191A813DEDF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IEB', 'EA89FA4F14EEDA4CD48F6FD0AB02285AA2963C06', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IEC', '74816052DEBA8FF23D97103DE6FFBFF005A91EBC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IEM', '2D614DEA573E469AD3814712CF5EA874A703CF28', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IEO', 'C5FA132D9337FFA1BA4CD760C2DCFD961BA5CF15', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IES', 'BAC544F4672681DF0F07C14E3A62649090860E9C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IEU', 'ADD342F1FE2E5E158B6CD9EAC5E3335B8515A204', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IEX', 'ACBD04C724182A778C4016212F1DB544EAF7F51E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IFSSYS', '9ECE8544D5F3DD3225109003A30EB07E3DCBF217', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IGC', 'D0DE39F20E3C054483B6B2BAAF5B42348D1083EA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IGF', 'F8BCB441D98D2FE555809A3502F0098A8CCBF754', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IGI', 'EB713A96BEBA9F266CC5590FE68ACC3850D7B970', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IGS', '18B6F4EC1E4FE13A869505A303160856EE612FA2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IGW', '7A4D83BFAE2C407B9D0C5270EB1D1A08527CE9DB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IMAGEUSER', 'F03602A8DC64F44A2BC11DCAB255D84E12732CE4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IMC', '38733843F40840AAC5F4771CA054F794403B5728', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IMEDIA', '88ABF1D1CFE175381F67F7CD995B666185520DF8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IMT', '480694AF7B57C758B4A358D1F28867A0BBFBFB18', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INFORMADAPTER0', 'F5D326D452D46E047FB82625B177E2E626F272A1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INFORMADAPTER1', 'D8499D0D4A373E00FC8DB6943DA7AA9A182EFD4E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INFORMADAPTER2', '852AFFEBA19277B09EF6F456FE1BDDD6B472A4AC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INFORMADAPTER3', '8A109E68234DDE3EFAD5A7B191CB162F3D97F7CC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INFORMADAPTER4', 'B23E3C40AB5B36FAFD9F5F4E4D8F0B63DEA3F3AD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INFORMADAPTER5', '3D36171A3E01585C41F8320421A3B7BA907C59C7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INFORMADAPTER6', '563B10A195AEF00E8F0C59371C1020FCA9FE91B5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INFORMADAPTER7', 'EE1594B6903C9CE1A874629BC6B31BD5AE815C9B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INFORMADAPTER8', '44487AF71FFA016CDEB95F56B070DB5CB842ACB9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INFORMADAPTER9', '69DEAA192E4754A3EFDF019E3F1BF628F2CA78CB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INFORMADMIN', '85785078CE5CC979A0EAC43DE64588D4D50AA98D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INL', 'E8991FEF22044EA57B312ED52A9E547201889FD2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INS1', '3B413F9A5BC7E69AAF3F15404090440A1BD80235', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INS2', 'AECA9E468DD3BB5E8286EEEC5F2FD87F3D1DCC4B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INTERNET_APPSERVER_REGISTRY', 
'745EC4FB7AD32B96273CE70247584560DA307C83', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('INV', 'A22C81F9E58D3E183314100CDA7DF50C66582B16', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IP', 'F9ABA3F1299B4A48E75EE40EF3BAF522152A817C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IPA', '2E47E3B74C32847A77F6ECD252BDD9099EAC37E3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IPD', '0EC8A763C4952F20E0EB6C4ED251412F15D30815', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IPLANET', '8BC4922B356CEA9ECA4429956274CB50518A798B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IPM', 'E7ED8EA81D5E633674573F0BAF3E81606534A7DA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ISC', '58D6C8EE619167C029D3B679A36609EC2930494F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ISTEWARD', '933B9E8B420983B305B867CC18866FA5D1885960', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ITA', 'C30F9CAC5A3355A4214A6070577466F86DF5BA41', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ITG', '630215735CB2E882F5042F0D08B9F45A5D8CBF75', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IX', 'D4F506D11F53BEFFB8D67EDA0740AF3A887A992E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IZU', '9FD6D28A66C1EAD5A979490B5EF1CD52E35B038E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JA', '84572EF2253EF81E2D8CD8C65849F4D9A3881F47', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JD7333', 'E9D896E977AFC01B2F8EA7FAAEC0552C9B5923D7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JD7334', '85AA5477DFD771E2945EE541BAC9CB385A5F2781', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JD9', '88973DB3898DF0F9F80804774906F3F5FF05B8D5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JDE', 'E64525F0749D51060E37ECF30BB67D5EC20F5B99', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JDEDBA', '7F48587268FCB09DEC1EF5A6CC1E77857F85B623', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JE', '68D2AD23B5E1102797FF78D3D0D55D97BA75C268', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JG', '10F507E71980D391161C979D35809259368B6261', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JL', '9F0D208CF30F99C24F65DE1BC3FBE5D25526AC82', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JMF', 'D80943125A911844A3C3DEAF419AB4E1AF1E85AA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JMSUSER', 'DF9E87A5A1C628876D3BC06BA9636183AEBCB238', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JMUSER', 'D59EC6918A77E6C38DAD828EEAB51440D399ABA7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JOHN', 'A51DDA7C7FF50B61EAEA0444371F4A6A9301E501', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JOHNINARI', 'D2D66744A4FB8E9B18DF8242EC3096FA97094041', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JTF', '9CC3BFAE85CC1240FF651EAF1847F8DBAF920D1B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JTI', '75739C05C2DA34DF44055823F63F418E36C89FA4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JTM', 'F754A2D4DD2759D68C8E925DA6207D6F5EDCAB62', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JTR', '2F233B070319A14C744DC0204123CC5FB7427CFA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JTS', '929448792D7A2FB954C104D72D4F3BD966B362FD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JUNK_PS', 'F1B0156187B4ECA937487D7D93284DECD49A7331', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('JUSTOSHUM', '3CC79CA8922F27E1166417B1E7DDF02763249767', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('KELLYJONES', 'E16D8574F0EC808867025A3520586A879204A757', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('KEVINDONS', 'F6091D8572BD5CB50E2CF144C7C364C6B06FA5AB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('KPN', 'A7F9D25B873131479C8CDC80F01CA55D7C7C5349', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('KWALKER', '7F62A1B902528BC2CD503D5762CFE82EEA89E2AA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('L2LDEMO', '4692F16E0BC9BEEDE7A4D4466988AB4DDA9427DE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('LADAMS', 'BB96CD1F8D99699F1E1153DE576FA8F3D2FD919F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('LBA', '68DA5ACAFF450FADDD6025D01ADCBA59967DA6A2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('LBACSYS', '7B6E7B03FAC206728A4C15C78F72C805CDB22C10', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('LBACSYS', '2EE91707728BFED1A8F222D3563E55ED90391F5E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('LDQUAL', '11AC19D0508509533A3D47BCBECD3EDEFED0B535', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('LHILL', '19551C903B4CFC45F6C9FFF64B332E735BF5A2A2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('LNS', 'A07C4859A36FAD672F8E7EB8BC60B3DA4FCCC871', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('LQUINCY', 'CDEDE4807697C6D9CB7FDE3BF74B2DF112881E00', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('LSA', 'AA33E71ED7CDDCC84FA9063C44620F961E61D499', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MANPROD', '0AA11C1C774BEC64B7C707B91C2DB00C4678503C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MDDATA', 'A8ABECCCB6246821CCF6AE48FDD88D6C958E6AD1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MDDEMO', '170585987BBFBD333DF3EC774C1A49A219443496', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ME', 'B1C1D8736F20DB3FB6C1C66BB1455ED43909F0D8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA100', 'AC15135B82B41023D0A749C21A7A0195CC247BAE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA101', '988A019F47CC8A642D656F162A1EC018984DFDB7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA110', '6CEACC994AAB686ECF86B33CBAB5649D836D46B7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA111', 'BDBA319C13B685DE56903DC431F4C2F2F2C66067', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA120', '5E989A69BFDD9B4088010869242853B3A53C27F8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA121', '2E819C333091BEF8DA30E6516434A97BD796B9AB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA130', '7B72B078AA96E8ACBC2CD67E0F47F1205BAD7964', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA131', 'B8EBDFE42BE14741B729AB0C625F48C24C7D7955', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA32', 'DE0EB8A47A5DDD3B199AC247C615CF6CA5D67823', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA33', 'B1A83838CC5DFF37CCFF1AC99E4C2DB11788769D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA40', 'E9BDDEFAEEFCCBCEAF1EBAEDE0FEEE3923FE3710', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA50', '8432F0D4783E4DB763A90A912B5C28F2FCCA6B58', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA51', '2038D5D3D44020C9BAB938D3A80860B47B9BDE25', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA60', '602C1BAD820961FAB2A958F54FEDD77DE943E180', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA61', 'E158909CBF0D7501794679E6F4D57F6371D29705', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA70', 'C4B98FF3E49CDA697D19A3CB97C1FF6986410F1A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA71', '44BA896DF58314E4C3A41C5B26E19140F18908EC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA80', 'A52D4BBDF82428F0E4FD9197B0D8138FAEFFEB17', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA81', '1BAD4B617313DA16DB40130C5BD3252DC7D0F9FD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA90', '1A880F761B17F1C6D3D250BC8F08581244EEBF7E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MEDDRA91', '5C5AED3BAB592304CA8EA97D4194C4E8D25A1722', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MFG', '28BFD0031D38C6100A0491CF5B18FA6EF861002D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MGDSYS', '5F0884BFC721B8C6E20917ACD547C1F307915AEC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MGR', '5BFCFBE428CCE428952787978643F2A5993438AA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MGR1', 'C21B268E5273DF8F792ABA5EB0B919FFDD34A76D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MGR2', '6C2DC2ED462870B87E74D9691F9330D951E7FB24', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MGR3', '9E34510D7E35DA0077BC62B433E01DCD41A68339', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MGR4', '550A114EB65E9BD9779191793E721CC22B0C22C6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MGWUSER', 'B6882D5CD0166BE4D7D7A18638EE83A8613E9256', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MIGRATE', 'CE5070EF8A0CF3E595AE4CF3F73F6A0ECA87E346', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MIKEIKEGAMI', 'B189721B9FAB8EB6F9EC0C94FF7F0EC67F37E6AD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MILLER', 'ABCCF54B832D256110CD9DB45C5391DA9AB6AB33', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MJONES', '6922AA976E27347D17D401CE49CD8CC76D24E3DA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MLAKE', '23824826CA77F23D7F9CC35B20A2BFEBC58F7F0C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MM1', '4A02DD63F13333760BFCB0B12F52A0F81B196030', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MM2', '23E171E318915B186A6C7D4F447B194EF2624F14', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MM3', 'CBA800906E4CF6C443E13AB62DDC40072AC2C242', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MM4', '9202FE5D272B5FCCEC0C7FD28C14047DCAF7371C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MM5', '286F2F6E1421861D81F4B5340608AAC30BCA08DA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MMARTIN', '74302E836F4304EB1088B5616CCE11424C294DAC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MOREAU', '1B36093D0B3BCAFD90C8C8E952A0A5DABCB0183A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MRP', '1EC2E6CC028EBB5F598436BE9098F775D7BCACC6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MSC', '531577E2EA6A1EEF9CDABCE582A2B074021A1180', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MSD', '1F43791077A7CFB4C9A91F3C0A60AED45BF96DEB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MSO', '0287E6F69B8D608A1E4E4582519F4154D1A04408', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MSR', 'B7CDECD2F3449609E17D97D62DBC330FA800B77C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MST', '255103E50249E3D658441816E0597170EBFC16EF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MTH', '9B11140652F228372E7D979D7BC66BCCFC356D14', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MTSSYS', '8EA8202B865AF484E81388510246B0EA717FA3D0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MWA', 'CB0F2B0216B0F8AFC3D09EB3A8AC7170E812AEA8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MXAGENT', 'D87CE7CB5FCCD0177FC32B24ED4259756012D62A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('NAMES', '237A4713B1838C73332635AD4FCCC63A5EF2A397', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('NEILKATSU', 'ECC2736498A7C60E9E76D86B3398BE79F454CE07', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('NEOTIX_SYS', 'C9F6F0F1C085028A0DCC1590928B06E239AB3F4F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OBJ7333', 'A5BDD91299B3D4C26FE194127F7AEE6B82618479', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OBJ7334', 'B8A5E60DF6186FADD7197DA8EC8890E6D6C77D74', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OBJB733', '81DC9EB2B40DBC949E1104AAE999A312201B870A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OCA', '104E54046DF9774CE93344AA7B07179670F87599', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OCITEST', 'FAC7207D208DAA1FCC80B2167020631868A5411C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OCM_DB_ADMIN', '079FB40E15D3C5F5524F2A02C5AA4702FAA1519D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ODM', '03DBC86D00088B27A2881A25FA94D25F346B7DF6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ODS', '86DE42E9188EA20F00E068706A6F6C40EA22FEC4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ODSCOMMON', 'F51E9973B727F4953C657D63AB89BE38BE45BC50', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OEMADM', 'BDF731EB4DCDBF7276450D02D1B20CAC20FA816E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OEMREP', '24F1B5CF9F27067994EA8753DC595FD8B93FCCC9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OKB', '6DCB282DBD0ABA99AF41F6376EFC66A68E99891F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OKC', 'E8898EAA471744FF003235691598F7AEB84D5872', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OKE', '6D73D34E71CD212D35F709B9DFF6A52B2AA582EC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OKI', 'B49458A3171C65D27EEA97C7A221FBF14DBACAC6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OKL', 'EE37913AAB12598C0C06AE5784344B8470E60336', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OKO', '10AC5100CFD51D6F612B7B8B62409DCDA9F09403', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OKR', '031022A29CEEEBB43DF79E1858A59377585416D3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OKS', 'DDE894F48EDE2A8A0DC1951AF037C1AEE3A09CD5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OKX', 'FF403EEB5F4F9D6F84BD5B735197ABC08BDB8FDA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OL810', 'C1C5768007523BD7BBE3B9624C0534907A273410', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OL811', 'C072C59C1A8DE29CA70C356F8A390C277F0EA2C6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OL812', 'BA1F15656967D55FBEB44207683D32B237B055E2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OL9', '0726DD6ECF93E1076E5BD17A13E05BF752B2A8D9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OLAPDBA', '7FB3B421525A5EA02F61AD5F0068375B80E14C83', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ONT', '5B78082A866A522DC2FAED3435E672C81A5008A6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OO', '0343BB07C98F8A943E8EB80C0BA3D9758D372D22', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OPENSPIRIT', '6DC77A9A5D5E9DD98CE5972FBE9AB2A5F3EF9FF8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OPI', 'EFB7808356AFE49464D5A059624EEC0D5DAB5FE1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORABAM', '124C23FB9549B61F1542033100A99AEE44181E9A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORABAMSAMPLES', 'AB2368EACB690CF83B49E586143E99FF70456B72', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORABPEL', '7C6BBE48559CC2DB61E94038E65D709A63CE8C68', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORACACHE', '1A7B2F13D7218F7AD1F3BE8AAE4E3F7B8769560B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORACLE', '431364B6450FC47CCDBF6A2205DFDB1BAEB79412', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORAESB', '32FAC751C957955C46735A925BE61122FB4FB1EE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORAOCA_PUBLIC', '50493974080030CDFDBF986DF794B1A57DF8C87D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORAPROBE', 'EB300A990C001A8B3366C076E83F8B42160957E7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORAREGSYS', '8C92E18EAF7D19540A01D99D401AE016449D5017', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORASAGENT', '92B52AC2EC6CD2E17506BE816EA002DB5A56AD00', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORASSO', '15CAAD32F8E389B884CEB23AEC1B6AC6A98248AE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORASSO_DS', '81F3B9D49461072FE5FF7800587607D7E73B5DE6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORASSO_PA', 'AF6A4C8B58B4D7C87EBFACB8C9C4F2270F980094', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORASSO_PS', '36E061A1DD3447581B0E0190C63634DAB80030FC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORASSO_PUBLIC', '99259ACA5B8EC67D71F54A532C1D4F2EC7963F16', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORASTAT', 'C168E2893F77BFF0616E8DF3C0D5CD910418188D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORDCOMMON', 'D06D9D95A3576A08C7AD0DE127787437742DF802', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORDDATA', '4D2B628E9AACEFFDB3E33063A5CFE9473CFD5BE4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORDPLUGINS', '76F65BD6EE92E5A03C6BAE5195BF9B79DA28D6F5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORDSYS', '7EDB5BDC885F74E2153257C34A5E4F48C51343DF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OSM', '1FB4298673BDFA67BBDE2253E6A472C3EFA4878C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OSP22', '3C60033D53883942230A175949B85E6EB0C6AD0A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OTA', '6F6B8EE5172ECC32444789396D86C3D30FB0B907', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OUTLN', 'FB145076B2267176994FA654EECD034C0A7EA44F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OWA', '3506D1E3BCF88CF7D6C391DAA7F55D2EFF12F587', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OWAPUB', '3B2967641CED31F1C4FB5E98915EBD713A695754', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OWA_PUBLIC', 'E7B2CE8DD45B1669394B8FD68BB014538D3B4544', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OWBSYS', '660408AFFC420CF1267B0E07AB09EB77C5657B32', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OWF_MGR', 'AD9D14EDD1F3D2A8D06FBAF338E07D864C3CEF32', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OWNER', '579233B2C479241523CBA5E3AF55D0F50F2D6414', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OZF', '24DAE18625BBB9D5657504C4C74B4D44B0E05787', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('OZG_BATCH', 'ACCBE27C9D7D69FAB99469E9C7ADF9A4EB99D738',
        'Oracle Health Insurance Back Office', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OZP', 'CECC3D41354B74E502A96540BC55567942F94DAC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('OZS', '39AC3102333591F7213770F353C4B7800304418F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PA', '379FC0D5299A71AC0F171FBB5AFB262829B4E765', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PABLO', '707D14912BB250CAF67DFE0EA4035681FBFC4F56', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PAIGE', 'CE3EF379B1F40008112376AA381C79D5E8CB9F8C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PAM', 'BD5CE5FDAA0AFBC20F82707E9543A688450BCB12', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PANAMA', '04E211BE7C0964A2686BADEC91C70403A08A703D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PARRISH', '32555483111472F46FD08C81AFFAE380D968672B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PARSON', '3B90D530BDEC383AF40BDD242268D22E40840D48', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PAS', '19C2A0DBD8E3A41B25D504744C57DF8853E36677',
        'Oracle Pedigree And Serialization Manager', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PASJMS', '19C2A0DBD8E3A41B25D504744C57DF8853E36677',
        'Oracle Pedigree And Serialization Manager', 1);

insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PAT', '7FFE1BA40F2584B96991DEC44AC44FE7E8D6BC68', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PATORILY', 'DE4401E52CC62E98A97B66B6AB20737C5607D9B4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PATRICKSANCHEZ', 'CCE58E055FE07C0FE65982F95DAA6C5B209C652B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PATROL', '378373635D00507B124B65AA64205D8E16FD5AC9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PATSY', '52D4524700FEDEBED3B29DA3B6B97EAC7B2DB334', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PAUL', 'A027184A55211CD23E3F3094F1FDC728DF5E0500', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PAULA', '62E52D2AC616F25DFDDD0968A947FA7E84E5C086', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PAXTON', 'BA92EE6A08F0969D08B01FDB69815768800BA33F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PCA1', 'AB8CC3263C405F821087B57245DBA418D58C94AC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PCA2', '95A1A182D3771C316F91CEC90FE5551543E338DA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PCA3', 'F42BB83DC3E385D1E3C269BB8BC121D04D7A87B0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PCA4', '6DBE22CD0BBF6953DB941228879D9755A75A8A21', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PCS1', 'F6C7BE904A7DA18F864B8E140CBDDA7935252E43', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PCS2', '3F573DF47E04AD88C57D8092B3F588D9DEF1DE9A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PCS3', '5BAA49C12420C978C87E59188E1316D8A582FE6A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PCS4', '8E26D4B97309610BB834BCEF1DDC7FD1E4C69D2C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PD7333', 'C079707CF93D56269D35936EABA8576D269FBD95', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PD7334', 'C6ACD66B3CEB9D7D864E12FBE0BE404D121DC27A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PD810', '201657BFCF38635699FDE4E7280082344D84767C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PD811', '9E51ECAFBF47A44149A2D19E0672DBD32FEF47BF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PD812', 'F14D0D5D05260BEDA64D3AE559DC0F83A1E28DC8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PD9', '3ACBCD9529DB7A67D5CCBE78B129D04C614589A1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PDA1', 'F0CF13EA7F34BD09354EE9588E2EA2BAA46FE7BB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PEARL', '4DDC5D84096CB270103079731103F93082D8B099', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PEG', 'AE8D391039D042682DBCC8E7B6215C6FF48578F6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PENNY', 'D96C88EE0DD006414CEE59BA9C2EF07174408F73', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PERCY', 'B8E14B053916CB17B3E091E8913BFD8C54605618', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PERFSTAT', 'B6479014AD84B7244ED6219541E0C79B1C70FB16', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PERRY', 'EF248FE27323D9D6D85E87A348C764C793BD79B4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PETE', 'E3B6CDA228242C30B711AC17CB264F1DBADFD0B6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PEYTON', '3E7D0EF6F0969752B79CC88DD2B65D9E3E943F64', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PFDBADMIN', '249379B19A97FBA8BCB5E067D47AAB25B8AAD42D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PFT', '4C2D0A3DAA8066775E11A9B5422398C8CFCF77DA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PHIL', 'E888D2BD6F13F82CAA51A37C03D034C76F661BA3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PJI', '899AF269E0226E33DECE58229B2FB73530A3B11E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PJM', 'D1DFB43AEF0F88007A729EB4B25D6D7BE510E833', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PLANNING', 'BDF5C73D18F44E2997E2DD1348B16D350106F6E2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PLEX', 'AEBDA823A279B219476C565BE863D83739999502', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PLM', '5F1D7BD4D939A7212AD72A0DE839E66EBB05F960', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PMI', '95CC5F64EDA5BD57AF4590B861ECE82CC38250E5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PN', '51D55774E645E23CE66930847BC1811C89594314', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PO', '13A5D51391F6A6FF5A94394B0DEE6A35BF66FD73', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PO7', '0B9A39AC77FC2CA7ADB1C15B447F8325DD652EC8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PO8', 'B2DA7C1763F42C2761319666468A83901EDF9BDF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('POA', '6ABBD2F38650BAAE5B85FAC37400AA0E26455BE6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('POLLY', '63329542BE9113041D0F202B54E7D705C4FE88A6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('POM', 'ACB4A94F3C944150FB89F07D87B019E224C73A27', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PON', '1BB7E1AD00B615968D8F6FA5853108F7999045FF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL', '23F3FD77A464CBE250150F60D785F08978D07E40', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL30_ADMIN', 'C7FAEB634CF9C6AFAB01FC7457BFCC62A87A37B3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL30_DEMO', 'B8F909EF2E064313B1477F4BA6163B506D8A9229', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL30_PS', '384983653D13FDAF443E3E647CB1AFF089A34E1F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL30_PUBLIC', '7140D8E136D33AF198BE2BF9910EA83EE235C1D1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL30_SSO', '817801F74BD964952678C7DA72D47EE6E9F18E8E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL30_SSO_ADMIN', '135AA0DF92030C199DC94A945A25BBDE7A8F9F5D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL30_SSO_PS', 'BCDBAC5C034286E0B0F4C533D9DDDB229C3F11C0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL30_SSO_PUBLIC', '9A5C88DAA3BA9EAA5A8FCAEA4E48213FCB3980E4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL_APP', 'ECBE0671E8F211E7174BA0E70800127A86D8020F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL_DEMO', 'F6A5F73467115042805A301F6A3FD5E316360ECC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL_PUBLIC', '696D23F815C6E15F9AF4F81CC5839D894B1D6123', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PORTAL_SSO_PS', '9AF4A8E6FA163F1F518FB477E74F7D0998CB1816', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('POS', '1478C028A16709CB32D8B1A69CCCA032CA1D9EF5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('POWERCARTUSER', '044DDB5A92CF7BB1A32E604788C50922E188EE24', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PPM1', '6610683F26D7D6604EEF48A08363C7B4C94C7CC7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PPM2', '6A12DA83480D7871673231B8CF8B015C9A41298E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PPM3', 'DBD62BBE6490887FF94C5D46AC0CAB6E2D385FC9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PPM4', '7D8656630E16BADA179986A524A04A6A45231195', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PPM5', 'FBD9824F0159E8BC1F5BDC14EB0D20A3C0C33A02', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PRIMARY', 'E3B7C980D763196E9D134C3EC1C3DE0DED54E5CE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PRISTB733', '88F344363866E1CCC4AD8C1717F48FA0F0AEF63C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PRISTCTL', 'D581235D18745216CEBD24467DBAC0576A3DA47A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PRISTDTA', '7A9C94273F0E86FB1077838900126DB25BFA1C27', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PRODB733', '62B02728738314CDE2DC1118EFCAC2924EAE4476', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PRODCTL', 'D11471828343680A28AF44651E83B80FE32E82E2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PRODDTA', '841340C303A37B6B48DC7FFC43AC2B5536A10F5F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PRODUSER', '462C50C633DDE50592C623897B1EC28F18915751', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PRP', 'CF9BB9A5E9432FC22C35A6372EA2278CB065FB1F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PS', 'C67F1EE17880030CE11821DCC9BE7AF90B863D9B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PS810', 'DDF1170C7C5E5380E07AC8AF6CC59AEB349E3D54', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PS810CTL', 'BBA5FF38473FE047D5DCCF78783E71C67ADE3290', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PS810DTA', '7ADFB64E2F3518168537EC54213858084243BA46', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PS811', '3FBCD36576660493961EF165C23B209378C517A3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PS811CTL', '4FABDC3579FF53EA87E30E67CC98295744F417EA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PS811DTA', 'A7DFBD047EE00026B5D6F7C38278DAD79F62D6A8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PS812', '4B150A285BC6E1DB7C0A316315A0CCA0CDD121D8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PS812CTL', 'E75C41CD22BF35A35C5D927EB143F5250678045F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PS812DTA', '08983814BAA77FD40F1380847DBA4904D0361A9F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PSA', 'E9FE30818AF39C9BE74FAFFEAEFE4ADAD7D8B32F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PSB', 'DA3756493F6108757E8F374679D9E59426017FEC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PSBASS', '64EDFDED63B390BFFC2BCF583150088879300083', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PSEM', '6B433DC602403E17DE122A8A86A37965970FEFAC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PSFT', 'FC7F5BA46A6DE857AA07CE9503CCF370CF8CDA9B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PSFTDBA', '0F2EAF3E56E4C2DFB3327781B4B013EE18F92EBE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PSP', 'B373E56B141C8F60566D3AF138DC6936F0482959', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTADMIN', '4E51D42E6D0B7EF5A3B27B92AB73131BBB93C3E6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTCNE', '49AA3B915A66C729878FD46F124AB73E0C120BB3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTDMO', '0E34CA41C6C99443AF3995BF845FEE5A5327E218', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTE', '390236A133463630C64942C52AD8B91753AE2D50', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTESP', '63B09F673C35DF6F53E9744837CAB67D5C827AA4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTFRA', 'F195960364AACBDF7AF44ECB43ECA91B09AFD85A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTG', 'B08E20B33C24EDD42C68EE5D1F2813CEAB59A4AD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTGER', 'F9745A5D5CBAF554645534A5B42B97DF16719CC2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTJPN', 'E8784AE77E94092669E48C0145CE3B51C36922EA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTUKE', '90741B22ECFB78D982BBE73E68C1493F5D74366A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTUPG', 'DB3D7CE9068EDA751998D0361BC0263208626087', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTWEB', '14E7200D61F0DFEBA1F25E6B3508581004D7D95A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PTWEBSERVER', 'AAAAA28B3DEBC36D90DC59878BB6E377AEE771C3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PUBSUB', '1982B5A745A1C88FEF26D98EEABDACB9994EC98A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PUBSUB1', 'B289E20B8738BB7FB01F747455540CDE5EBA824F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PV', '9B879864942A33D1BCCDA3C057D3629E5092B9BA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PXFR_RECV', '9AFAA173769FF2DE8BE30D1C698668D97D99ACC9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PXFR_SEND', '434A6D8855C21657E3063001BB4C757A93FFF083', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PY7333', '37E8B98D873B86F8984F482EF55975BB0B6149C9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PY7334', 'E02F2186A72F1B62FA2BD948ACDB031F1B23B91C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PY810', 'F1D513403CC2269B32CF9A42CA37E43AA9C7D532', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PY811', '41FD4AE542F7CC708931B95C2A72D745C07D9F85', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PY812', '32CC29ADF9B8210958EC6F3093273C9F3DCDCB82', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PY9', '2360B0C6FBDE1DEAB3F417C973B1140045474B9E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('QA', 'D3C583412A36313AB5E24293924C39A36B842C56', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('QDBA', '225EB5988137D255F29DB09514508CA37F01808E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('QOT', '1FB8EF73F118C5DE1F9BA4939A76B3F3B0BC7444', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('QP', '5CC9B0673329E50CE9CBBCDD262F5255F54B1B4F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('QPR', '1385733245F6A359C3FCD6725499C7670831AF3D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('QRM', '9569BE64E5544E2E44808D3CC78E6AB8CEEC874B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RE', 'C387C982A132D05CBD5F88840AEF2C8157740049', 1);

Rem proj-58146
insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
 values( 'REMOTE_SCHEDULER_AGENT', 'FA41BF00775D6FB86FB0CF90D5CB3340BD8DC5D1',
         'Oracle Scheduler', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RENE', 'FAD9A0A6F25DF623A055091FE7E403534C7E9536', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('REPADMIN', 'A1E7A13FEFE48C810D4FD56266B613A5B304855F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('REPORTOWNER', '89A901CB140965396019B9BD9DEDE524A7578D09',
        'Oracle Transportation Management', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('REPORTS', '0B7EC688EEB9119F72F32B5B0F62681AF8CDE1A4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RESTRICTED_US', '7484DA84E897EAB7F764438BC029D8D8247BCF27', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('REVIEWADMIN', 'E5265B5F6883F497FEF3D678DF6597DF2567171D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RG', 'F84DE6B0717EF339A618828E50F85C015A8F06CE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RHX', '2AC010AA679210ECCE8B10B9230C73EFFDFADBEF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RLA', '42B87E9EFD7EC228364B49A82A813120C8C041CA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RLM', '1C245B2071FD39AB22A1A1CE23C1E1647AFCA883', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RM1', 'FCC478CF7D945E6FA2DBCF0802B5F916ECE61418', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RM2', '36B8972F952B6558832C49263D333DEFBC4A9034', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RM3', 'C62B3CA0932B6F27B4EF97DCDA82EE91FC3D884D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RM4', 'CACA24E691956A8218B527442337A89D5ED99778', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RM5', '74B871EFC1E62EE15417D6294F6E14E35B1F11AF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RMAIL', '43BF078D8914FCF0D8C51596880900D69331B18F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RMAN', '438A2FB7E7D975B9BF12A813169F53222D821B54', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ROB', '7E09C9D3E96378BF549FC283FD6E1E5B7014CC33', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RPARKER', '236227846E25BF892DBE12A6606708E950D6C9B3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RRS', '518914B96E4AB0614FFCD5152EAEB47FB68E15BF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('RWA1', 'A2AC1C9AD675212EF4CCD330B6F99538BF7705A4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SALLYH', '1BFEF6E766022821D492F84B2BF8A02D4EE193EF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SAM', 'F16BED56189E249FE4CA8ED10A1ECAE60E8CEAC0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SAMPLE', '8151325DCDBAE9E0FF95F9F9658432DBEDFDB209', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SARAHMANDY', '29D51E4423FD672EA4A48C43A21BA835B99D0B32', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SCM1', '9D7C0EAB9E49910E673DBB5C91833845AD97F3F8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SCM2', 'E68FE3F9EE27037A9AE40CEEFD7C4B121EBDBDC9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SCM3', 'DEA7310057168DF5BE58F7174FE3AF73838F8842', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SCM4', '1217550C3A2746F786F6D240D5EC8889E98662DD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SDAVIS', 'FBEBC7EAFCCBD8DAD47A22522998E3D6BF671114', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SDOS_ICSAP', 'F16651186703F9DEDB9527EA96120260A99CED66', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SECDEMO', '2B90FD17EAB8FA860B69535240AC46988B833390', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SEDWARDS', '5D0EDD06AFB74AC1E98536249C2EF70A181BFF0C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SELLCM', 'AA87D54643D49DFED4AEE8DE4E71947FDC2002D5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SELLER', '2E7464A5E9BAC192F1251866FEA0C255DB0CBD83', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SELLTREAS', '5BD9427767416ACB0508191C1F492B40EB38860C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SERVICECONSUMER1', 'E22369DFF00D91751A496ED1890A2112E35E329C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SETUP', '80437A44A661D141174209119D54125A59A64B2A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SID', 'DA58B0C134CED9FA3847C7D85A083541CD9A0663', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SITEMINDER', '1021D944B647F1D74B0580ABE31F471E7C814CF4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SI_INFORMTN_SCHEMA', 'F5818A9DAA63959CBE8245057E6F9DA44DB9461A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SKAYE', 'A0523E21DDF36AF2D65FC7EE110F94BE67FDD028', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SKYTETSUKA', 'B9D8C096823192588E66824DF7621E2E87F7C5C0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SLSAA', 'C599850F30E0419573B77F40BAF35D821F64D4C1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SLSMGR', '83930E64DEAECC527BAA3E93C44682CC9A871F5A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SLSREP', '817C2E243219669879568FBB8C0FDF239A2333BA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SPATIAL_CSW_ADMIN_USR', '0B4B301156D02C1389A7EE197EEDA5FADD7A69E4', 
1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SPATIAL_WFS_ADMIN_USR', '7D04118DAFDF1A2BEF35AC89D1E519FDBBB11636', 
1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SPIERSON', 'E852FB90F0AD3CAB70F17EEBBE690EB4B5CB3A7D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SRABBITT', '5C59231328A3E2E7C6B8850A25A024F68CF861AF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SRALPHS', '55A72155B014CEA050A034EC8ADA1D69B69814AA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SRAY', '1F0E3B568AE50B5AFB479745130329823F238EB7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SRIVERS', 'D6B864146517D35772FD972690DF971D283443A3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SSA1', '6BF9C6B966F43F0C03F28899FE2C85B7F887F6A8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SSA2', 'C33C496529E94134F0CDE1D0ABA7BD418D292BB6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SSA3', '9743A4F434E22B34F0B069D4732FA8EA1434F920', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SSC1', '377E252414EC1E5B2F5790184F60BFBC3B1F5837', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SSC2', '3844664200DD016267FB6615FCA7B288449225CA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SSC3', '71D829098CE9A74F9339A77E452D453AA4CBCD12', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SSOSDK', '3DF57D50243E9B3BA70C44E394214FEBA764C3E7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SSP', '793D0520344D4E35AE49BC18FD51C9131B00BD2A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SSS1', 'FD71E49BF6897A24006E5418825DF2722B8EECBD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SST', '837631C17EE79FEDCA43BFE4B9B5C80000C354F7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('STARTER', 'F16ECBA5A2D660C0A728D9CAE2B4666E8CB8459C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SUPPLIER', 'E2979E759574B094B7C50F54846AF43EF8EFF1A0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SVM7333', '89627A0E536D27B69102ECF3C5B31540C3957EC9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SVM7334', '45445903693F8A005E12607478EA5A5019DBFA28', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SVM810', 'E9F4F9CD1A4682CADE453EA9767302272BE89281', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SVM811', 'F1BEA15D2491451BCCE8C0F992A70C2997121BA7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SVM812', '117A2479D377D513F4FAA87D6E11741AFCCBD5E9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SVM9', '268B34833E12C7A3A1B4F7163066B20C987FF518', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SVMB733', '808F833B52347D18C7BE58C118D2A3A5394C4483', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SVP1', 'F1A0EBD0B0D869A294C61F23854588CA69332315', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SWPRO', '655669E33FAB4D7BDB4C8ECA1C8F61243194D435', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SWUSER', 'DDAFD951ADBAAB15B0A228BCAF916F807E5A1731', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SY810', '4DA20ABABAB4319F8EFD738760BEF6FAB45EACB2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SY811', 'A5EF5EB6233378A00A3541FAB13526B94858573B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SY812', 'E007FCFDF305FC0EA6405AD8EA6F399FCB8B575F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SY9', '4D0F8A43BEB5ECADAF8ED7613CAEBCB8ACED8531', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SYMPA', '35BC724730476A47CF18F92F486CD9E7745D4F15', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SYS7333', '9C3C6992697D78CB1ACE95008B2A036CB6130D6A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SYS7334', 'AF55341C0E083BB5A25B64E32DAA357EA18F702D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SYSADM', 'FC6783B3CABD4C09AC7A7DA84529F783C0E11EB2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SYSADMIN', 'A159B7AE81BA3552AF61E9731B20870515944538', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SYSB733', 'FD0674919A0F9CD135067A2934E53A47B0D32A70', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SYSRAC', '58EFDB931FE74F6154DC84B3CF91B2600B438710', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TAHITI', '04F2932875453E4DC7514BC272430EDB878420F1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TDEMARCO', 'B7753BA6EF7D89B52D30404AA1C353E331A276F0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TDOS_ICSAP', 'C7F2B1D728FA587D007F3D0DE18597BC010B53CF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TESTCTL', 'B1B909B6472BA9270E514ECCCD800E88F49A0E92', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TESTDTA', 'F54CC0E265F00AF2F7FFE225E22C969595FCD8FD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TESTPILOT', '9554A58B789BF588B0E1AC447D3CCD0BAFCA953B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TEST_USER', '31676025316FB555E0BFA12F0BCFD0EA43C4C20E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TIBCO', 'BDABA0634142383A4AA1578DD58D6A598D019AFC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TIP37', 'AECC29DC9A3986729EA4FDD604B0BF7177112E8C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TOPIC_WORKFLOW', '270077782E1DF0C2AA83BED9076ED8A69020F5E6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TRA1', '9E0CCD91FFD003C18B76D004E57D1D27B056D04C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TRAVEL', 'F7956B2763E6FF1741381E063233BB4D3C512568', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TRBM1', '0F8AB9FCD72493F8E64C00439F3C1B4F569AF0D6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TRCM1', 'F8FB94809D95BF84F461ECC362D16C28E8F47618', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TRDM1', '786A86A2CF59257857768681458FE7EDB464E4A1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TRRM1', '3927C01CDD60C04CC963B1FCF0D3051BD08AF4BA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TSDEV', '3DEF6C3FDD712D46A87DFE5D3B4533C7EEFE7F12', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TSMSYS', '8EC52BEE15545EFC488F4E7484D9A9B725DECDE5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TSUSER', '47B2A3E7E18DEB9CEE00E67C20781F0F6E4D2FAE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TURBINE', 'E2F519EC7BE19A22ADFD6E785F2BB3EE8CDA9A15', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('TWILLIAMS', '2241B7D596EC9A2D16022A38AB621833B6259DE3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('UDDISYS', '5128C4ED80833EE2F0616AF6AE0ED1F9674CF471', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ULTIMATE', '74537D34D075F94BA764F63E4374749CCB9C8E6B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('UM_ADMIN', 'C722AE0BE58FA49785CC18684B0D8BB51D9C3D95', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('UM_CLIENT', 'EFC6B74067DE3A30929D11FBF0C5FCC3A07C64D2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('USER0', '9C031D62A3C4909B216E1D86B7F69B982BDCA0F9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('USER1', 'B3DAA77B4C04A9551B8781D03191FE098F325E67', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('USER2', 'A1881C06EEC96DB9901C7BBFE41C42A3F08E9CB4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('USER3', '0B7F849446D3383546D15A480966084442CD2193', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('USER4', '06E6EEF6ADF2E5F54EA6C43C376D6D36605F810E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('USER5', '7D112681B8DD80723871A87FF506286613FA9CF6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('USER6', '312A46DC52117EFA4E3096EDA510370F01C83B27', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('USER7', '7BDEECC97CF8F9B9188BA2751AA1755DAD9FF819', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('USER8', 'A14C955BDA572B817DECCC3A2135CC5F2518C1D3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('USER9', '86F28434210631FA6BDA6DB990ABA7391F512774', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('UTILITY', '8884FD30D64E5CF97054C14E8A217A1FB0CD7E16', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20030630', 'AF38C9276B60C986A9CD0667F3F9A15411D25627', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20030830', '31F77CF1E5248815851D552A7EB9910DBBF7CC26', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20030930', '806558BF5DD4669801F61E6C5DC76E9EB1F653AE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20040228', '6BEEDEAC897F7B07A9EE1F940024279DB077F7BA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20040730', 'CC0E0F89B17CF179B40DE600BA987ED664436DFD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20041231', '9ADBB10DA8574F000C932782B7FA6D799B9F8972', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20050331', 'EC12C60E147E3BE03BCC850630A32B346B6C35BD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20050831', 'E67AF4998C7CAECD4F7E0C9B3BFBED6DDFDFA554', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20051130', 'B22C104E42ADF8B36BA28ED22A994BE0E8909B5C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20060430', '26AA8D18E74AD778FF6C6C4C34925487FB52209E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20060831', '17D94B3779F430F2C30870E1CF1294D2289F671C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20061231', 'D651BE3FEE706367911D3FF10F2F96CAFA4D43DA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20070430', '9B3F979BD19721F7A997FEE266F37B3BD5FCC5F0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20070630', 'FD823B47A4E9563F9CB3297BAC98159989F934C1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20070930', 'A7AB9188674F9020F2349741A62CA2A628929007', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20071231', '7CDBC3CF384DA61E8EC21BF16BAE380EA9FA9256', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20080331', 'A519D46FF53996833C9AFD3FC0347EBF1EFD7D32', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20080630', '6D26360D4DB975369C01FA6481DB631C2FD79CE6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20080930', '7E951A08ADBC48A149DD9D8D832B9B46A152E25D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20081231', 'F2B400E4736128E912EFF1EAA00EF0FF3D754417', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20090331', 'CBEB454378824E33FBD7F5A9971867F693A8B75B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20090630', 'AA9E9BFC2BD409BA83AF6DB36798026A6E426B65', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20090731', '30E6D853B827D83724B0FADD61B24D6C92088E6A', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20090831', 'AC1F9C7EF090FDDE0E137AC6AB0A06ABE79874A6', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20090930', 'CEA08788B16CEA76228190D80821564A359F3860', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20091031', 'EFCDF384C409789152C1F508B9D83CEDC39D154F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20091130', '3259C0183DF69C6E1B1561D8139F48956EEF091F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20091229', '3078F89FA1B1F942139035C192AA08082FDFF300', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20100126', 'CAA085C29A74FAF3DC53D1D1DC1D2F8B3CC74AD1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20100226', '7C14B058E816E63590BF1EEA0D1CBD97B44B7A38', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20100330', '0E563896A03C0167C90C374E08F71BD0ADB02576', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20100428', '69095B7777B822A32CFBC8E671D802C67006E3CE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20100525', 'B44AA1F6323E89B120D82A0CBADEBEA20A613004', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20100609', '57FC4E5BD704A4C426EC94DB5277E439B9D43E6C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20100630', '56EF23CEE000D1F91E168A71E373DA5B9CF9FF96', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20100731', '51620CD892ED6512C7BCE016EF45F0E0B36373E3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20100831', 'E20879515C6B07412E0360489CED49EC6F94E04F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VAERS_20100929', 'AB166D092945D68E4BF134945F444E8D5EA8B714', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VEA', '9B78E686069AE3ED8777CBBAFEB6821C0FDAF370', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VEH', '4F975E3B22B389C24C3461901DC14BF10039C35C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VERTEX_LOGIN', 'F79BD3B5B8DCB902001E633E9067E839BC57206E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIDEO31', '87421A6A1D612B7B06C6D62D33496B9DA8CCC25E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIDEO4', 'F515026BA534DB6816539EE10822AE7182003B05', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIDEO5', '199BC29BABF959762AF699D5F4586562A1163EAF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIDEOUSER', 'C69DACAEAD2AD4FDF00858788F7D87B89BC8A643', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2004Q1', 'EC2E9672BEA0A5F543C7F8ECF030433003CB1DEE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2004Q2', 'BE78B18F34609981C4D91A42C2748E4F154DCFB4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2004Q4', 'C0A7ACD8E11BFAB2BA56FC034ADAA3AA2D9D358F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2005Q1', '4E7D84FA54FAA06826D42725565295EB3F2F418E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2005Q2', 'E0D4606B17E303584E3749616FE07C79908A5F35', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2005Q3', 'B577109657ACBC22C89BC271278187A04E57CC2C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2006Q1', '1206F01C9F9519B955A3650CF6AE923B83AFDAB7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2006Q2', 'B7263ADE73B905CD45B80D32235B1311BE134FA9', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2006Q3', '4DF84FEFCA4CB752ABC44EFA7FAD7B1D27987B30', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2006Q4', '91E6A35BCCF5083B225C9C71EBAF1446F7F64E11', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2007Q1', '88B7AD74EFA2F7FFA0117E9C4B781631179B8F66', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2007Q2', '9F489A0A5470AD7C3D9D9BFE00C46BEC6E8E37E8', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2007Q4', '81BDC5EB17A8F2A8E893CD9B70C4241EC82F7086', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2008Q1', 'FD1738FDD777CB93E51B4CA2A6280CF5163696E2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2008Q2', 'CD874584DBB210C598EB84B7F1F2792218604016', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2008Q3', '46712D356043E81F9206A04C1E678DBB08903FB5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2008Q4', 'DCCE9A529B1D436B0DAB293132A8E3571150BD79', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2009Q1', 'F8A58C66506DAA862E4D58F2C658107881090C75', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2009Q2', '2362B39A6C48FF019E05943EE698C992183B4692', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2009Q3', '4BA7B560AE22CB94F6AB35E339DC5DA313C66E9E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2009Q4', 'B5BC6C9240B9ED363BECE645FC81A88306843659', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2010Q1', 'CB86F877945CE1E1298A0E9959AAF0F04F2AE6F7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2010Q2', '64D4A12717FF3C8A0FC51D5DF8913408EC9E841C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_2010Q3', 'F59CC2DDD2C73F7D15095D54B328DB851D730423', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIGIBASE_4Q03', '59656AADFFE4EB69D7A0EB51E083A2C556F98DDB', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VIRUSER', '946D2D03FC60E8DC88AB3367B5D0375CBF704ECE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VP1', '9D7B6B1D9F6F5D8B23B6C74BAE8498649631A31B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VP2', '4EE91C0C57058C840ADCD39E4EA97C98C625FFDA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VP3', '268E4781B3AE6814AF2F06DA5B96A3105A99F465', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VP4', 'B14FCCF52601C1B52D6D8E11D64CEBD7FF838277', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VP5', 'FE9D8A59799BCF54407DE07AA5D99D1863E0A6A0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('VP6', '3E26709FF67C699F3F5418670C8AB368FB93B5DE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WAA1', 'F7D5F1F1C897D1844F445AE33C31E15392513DF7', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WAA2', 'A594B45CE76476FFCDC0AE04C74311F963A1B52F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WCRSYS', '98BCC9345F6BEAA46C975653AA38658F54F0BEE3', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WEBCAL01', '20D742E6517CE07796D795F2BDE5D2016B000139', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WEBDB', '12842086BEDB7A8BCB5D66AFA6B4F74851F3DD16', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WEBREAD', '98D165F7A4B61057A72CB4664A894E4412A0CB82', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WENDYCHO', '440BFBA89F785549460656D23349422229261A81', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WEST', 'D63EBA28AFC025843DEEAEC9B4016122524BDDBF', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WFADMIN', 'AC9ECCD4956ED16ABC645A74C0950FFA9BF5EE1D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WH', 'D764022E72480FA96081956C8A34FAFD708E8FCD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WHODD_2009Q3', 'A0251FC45A33D8014D4A0C65511DBED8B3B8C69F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WHODD_2009Q4', '962A4624E355F6CAE051E7F12C0ADD5967FC37DE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WHODD_2010Q1', 'AC1854D51C84AEE8E4B95322CD9BD89627CFDCCE', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WHODD_2010Q2', '6060443968EC2A5473B47E789D5A7DFAD8E3A7F4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WHODD_2010Q3', '0CE89A2F941816F487563E4CF16A7DB6D7BB2955', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WIP', '6DB60D0DFD87CA5119B04AA3AE27AF7A102D61DC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WIRELESS', '9F56B812E82F09A351291C993C20248FE067A948', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WKADMIN', 'EBD870541F33C77D04C50D14A2A80443DBC695F4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WKUSER', '88A28721A836C53E5438A16EB6EAFF771704D1CD', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WK_TEST', '0D8047CE9EB3A07803BCE81451FF4314F0F9F44C', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WMS', '9DA8013D1DCE337249F3C6D794FDFBF1E8D55234', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WMSYS', '2CF33C53CE8D70C190CAC23D129759A42B52B86D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WOB', '15EAD165ECE3DF55B61DA237DB93FBBA034EDEAC', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WPS', 'CD9C0E1D36B4ADCE3C5590998C8D377F7FF32833', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WSH', 'CA8B0A60D3BC1B1D892C371C1DF5FAB47E110A2F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WSM', 'E5EDEE2C030441C7B555A3566832B078E8E5AE3E', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WWW', 'C50267B906A652F2142CFAB006E215C9F6FDC8A0', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WWWUSER', 'CBE79B415EB12F3AFBCB89A928F34A9A7695BD60', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XADEMO', '1D54EB4059B65DED8BC4BDCFEAE1F7A546F2FFF5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XDO', 'A1A56FD5AF677733FCC9FCE69C49C5E66D550EFA', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XDP', '0643F79FC8B4FA703580CA6DAA72B2F1D4EBD299', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XLA', '5CDD98A68988E411A3E784C84CDAE7F24B35FDF4', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XLE', 'F6A7D3F30ED86E81EEBD8AF541227CA8D19FA7E2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XNB', '001737FABE504BEB5F0DBD0A2D919EFE2391CB04', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XNC', 'AF5EE30A87DE8C6ECF8881B098B29F2B8B8F91D1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XNI', '652DE6D25B8814957A74AEC4DF441698FFDADCF1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XNM', 'EA6DE35F6F896896682BB54D9C7AD95550A61F4D', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XNP', '49D98BAAA35E18C63A8A2E7FF7A8EBA428280BE1', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XNS', 'E2669B6617EE70ADD579C20EE31B019F587A0E36', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XPRT', 'AFB2C1464281C091D001AB7880E4728B8F345658', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('XTR', '486E46CC3F1E9705E0E005ACADEA5F58E8F3AE3F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('YCAMPOS', '756457A49EE2CE4B9238AA5D0283FF409D492E11', 1);
 
insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('YMS', '637150425BA073E1C1C0AC29B8ECB017AEDD6915', 
        'Oracle E-Business Suite', 1);

insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('YSANCHEZ', 'BABA4567E469A3EAFFF64225120F59C02FCF40F2', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ZFA', 'B25D5C9DC9B57F3EBCD6172977EA90C45902D3C5', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ZPB', 'EFA96C0B291678738CDD35E751A27184891BD235', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ZSA', 'E713340E1F34C9063384C1372023F86C082E498F', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ZX', '81428D187ADAC7683E39E04D7AD9315094920990', 1);

insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ADSEUL_US', 'C0B137FE2D792459F26FF763CCE44574A5B5AB03', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('DGRAY', 'C0B137FE2D792459F26FF763CCE44574A5B5AB03', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('MOBILEADMIN', 'C0B137FE2D792459F26FF763CCE44574A5B5AB03', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('ORCLADMIN', 'C0B137FE2D792459F26FF763CCE44574A5B5AB03', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('PROJMFG', 'C0B137FE2D792459F26FF763CCE44574A5B5AB03', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('SERVICES', 'C0B137FE2D792459F26FF763CCE44574A5B5AB03', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WIRELESS', 'C0B137FE2D792459F26FF763CCE44574A5B5AB03', 1);

insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('BI', '00854CEF181979BF44A949EB1D6E2110ED175D1B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('IX', '00854CEF181979BF44A949EB1D6E2110ED175D1B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WK_PROXY', '00854CEF181979BF44A949EB1D6E2110ED175D1B', 1);
 
insert into default_pwd$(user_name, pwd_verifier, pv_type) 
values ('WK_SYS', '00854CEF181979BF44A949EB1D6E2110ED175D1B', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('SYS$UMF', '59895200565003F534ADEFBE03F6D5D3FA6EA6A2', 
        'Unified Manageability Framework',1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('DBSFWUSER','BE2303410737055976CFF28874DED4C71A8A8DF6',
        'DB Service FireWall USER', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('FUSION_ATGLITE', 'F7E6FDF149A3289F9C9F2E0927DACF47AC31AA00',
        'Oracle Application Core ATG Lite', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('OADM_SYS', 'EC337BEDFD798793D2E4EE9538892E7861E12697',
        'Oracle Airlines Data Model', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('OADM_USER', '98F562A8372E30B2E794BEA921BBDF0DDD82CAB9',
        'Oracle Airlines Data Model', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('OADM_REPORT', '7E36F14D3E18738B60388ABB3F7A60EF1CF07CB1',
        'Oracle Airlines Data Model', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('OADM_SAMPLE', '3AA9150CB141F4D68EE9857B91576D17325500A7',
        'Oracle Airlines Data Model', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('EBS_EID_STUDIO', '57C795854FAE40D3E2F2A023B437F30894C4E016',
        'EBS Endeca', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type) 
values ('EBS_EID_INTEGRATOR', '48E9EECD36554D88C8548F3737E06CA1F8588049',
        'EBS Endeca', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROS', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MICROSDB', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('MCRSCACHE', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SIMADMIN', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('UTIL', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('AGGREGATE_DB', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BIREPOS', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('COREDB', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('LOCATION_ACTIVITY_DB', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('PORTAL_DB', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('QUARTZ', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('RTA', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('BLITZ', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYS', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony' , 1);

insert into default_pwd$(user_name, pwd_verifier, pv_type)
values ('SYS', 'CDCDF63019576031CF6BFEBC22DA1A2362DF97FA', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '6E05F10B8CEEBAE66CC534DBF6C42B0547BC4B5A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '831288C93386B20808F56042D7EAF01040614396',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '618DCDFB0CD9AE4481164961C4796DD8E3930C8D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '3C8101ACB51E8F51363933E63BFB9106EC64D6E4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'C78296AA3AA7F4083D9C41486953ADED522A1F26',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'E6402EE50E78B6141DB94C840CA7903762665732',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '2DBD76E41756796A0B1ED09F68AE94D3B8C62B56',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'EF790789A74B37EEA9FDC56DF13548BEF099A10D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '3828481FC4C7981DDDFD3428CB65D58215A83F17',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '82451B41FD7878180B6AA2B54E369CBEC4E8032C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'DA4DBFBC4FDC56237451CF5E9F9933B2B64F1BA6',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '8882E4BB2A3AB29B02AC332AE19A66CDB130DBAD',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '0588C79A3E946B1B688A44A61A4F464E495C0B34',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '36D6C94BD832F61B6DE064679CCDD74E04DEE95C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '7D7289B5DE4D3205E23EDA3AE03D26244F7D52E3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '416EB4FBB0D20FB6CBF65353FA89369F6DBB843B',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'B7A875FC1EA228B9061041B7CEC4BD3C52AB3CE3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'FC707FC0B8C62CFEEAFFFDE7273978D29D6D2374',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '1ED2015A7FCE1784BF6C6506B97267552BC47BCA',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '22B2504AA64D713827AC0BA54CE589AE67D1759C',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'EC4EB7EC924A35785DE1284AAD546894EE67F6C3',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '9AECE0ED325CCD44BAA9C9C1AF480DBDF695EAD8',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'F92ED21F533A9A8472D0C080B2C6AAD703D906F0',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'B28B7AF69320201D1CF206EBF28373980ADD1451',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '3264C1A062DC9992E36052FC0E4AE4116AEE787F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '1B1B4F15BCEA30258DB9E4800637C627E74949DF',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'D5B9481FDA7404D6062496B909A3D49020FDACDE',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '22C3BCFED71C3E30645EFF0838AB7165FBE5E81F',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'AD6229BE4331B9C009762134D1EEA642E6FEFB83',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '06706546C1798DF49ACECD2F8EA2B8D65C5054B1',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'A9937DE3C5D9A091A742E0696B2B64071260B30D',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '7EDDBF483901549A212B1E9A709995B330036932',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '7E94DF839034EE66C40DA9AF178C8118983223F4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'C2DA13E2CFB31C7E8ED1B0401136920D17ABB86A',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '8958BA2C8459A92CA4BC8EE109E90AB1A590DBF5',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '183459CAF7DC269FAD467275BC78F670A9E971C4',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', 'DAA79D1AE211DBE52C3E1496811BCCC46A76D17E',
        'Oracle Hospitality Simphony', 1);

insert into default_pwd$(user_name, pwd_verifier, product, pv_type)
values ('SYSTEM', '09D5DFF74DA20F9A979CA8601E5BF0E0C8A1A1FE',
        'Oracle Hospitality Simphony', 1);


commit;

-- Create a DBA view to show what users are still using their passwords

-- Bug 19678170: Make sure the followings when DBA_USERS_WITH_DEFPWD is queried
-- #1. when queried from non-CDB, display all users with default password
-- #2. when queried from CDB's Root, display all common users who are using
--     default password
-- #3. when queried from CDB's PDB, display all local users who are using
--     default password
CREATE OR REPLACE VIEW SYS.DBA_USERS_WITH_DEFPWD (USERNAME, PRODUCT) AS
  SELECT DISTINCT u.name, dp.product 
    FROM SYS.user$ u, SYS.default_pwd$ dp
    WHERE (u.type#  = 1) AND (u.name = dp.user_name) AND
          (bitand(u.astatus, 16) = 16) AND dp.pv_type >= 0 AND
          ((sys_context('userenv', 'con_id') = 0)  OR         /* #1: non-CDB */
                                          /* #2: CDB$ROOT and User is Common */
           ((sys_context('userenv', 'con_id') = 1)
             AND (bitand(u.spare1, 128) = 128)) OR 
                                          /* #3: CDB's PDB and User is Local */
           ((sys_context('userenv', 'con_id') > 1)
            AND (bitand(u.spare1, 128) != 128)));

-- Add comments on the DBA view

COMMENT ON TABLE DBA_USERS_WITH_DEFPWD is 
'Users that are still using their default passwords';


COMMENT ON COLUMN DBA_USERS_WITH_DEFPWD.USERNAME is
'Name of the user';

COMMENT ON COLUMN DBA_USERS_WITH_DEFPWD.PRODUCT is
'Name of the product the user belongs to';

-- Create public synonym for DBA_USERS_WITH_DEFPWD view

CREATE OR REPLACE PUBLIC SYNONYM DBA_USERS_WITH_DEFPWD 
   FOR SYS.DBA_USERS_WITH_DEFPWD;

-- Grant privs on the view and the base table we newly created
-- GRANT select ON DBA_USERS_WITH_DEFPWD TO dba;
-- GRANT select, insert, delete, update ON  SYS.DEFAULT_PWD$ TO dba;


execute CDBView.create_cdbview(false,'SYS','DBA_USERS_WITH_DEFPWD','CDB_USERS_WITH_DEFPWD');
create or replace public synonym CDB_USERS_WITH_DEFPWD for SYS.CDB_USERS_WITH_DEFPWD
/


@?/rdbms/admin/sqlsessend.sql
