Rem
Rem $Header: rdbms/admin/catpvf.sql /st_rdbms_18.0/1 2018/04/23 06:36:58 anbhasu Exp $
Rem
Rem catpvf.sql
Rem
Rem Copyright (c) 2013, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpvf.sql - Create Password Verify Function, STIG profile 
Rem
Rem    DESCRIPTION
Rem      Creates the password verify functions and their dependent functions.
Rem      This script also creates the STIG compliant user profile
Rem
Rem    NOTES
Rem       STIG profile is created with container = current which means it is 
Rem       a local object. But exception is made in PDB code similar to the 
Rem       DEFAULT profile to make sure the STIG profile is created in every 
Rem       container during DB creation time. 
Rem       
Rem       The password verify functions and their dependent functions are moved 
Rem       from utlpwdmg.sql script
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    anbhasu     04/18/18 - Backport anbhasu_bug-27522245 from main
Rem    anbhasu     02/20/18 - bug# 27522245 & 27550341 - Password len check 
Rem                           removed and Handles multibyte NLS characters
Rem    anbhasu     04/19/17 - Bug 22730089: Translated error messages
Rem    gaurameh    02/10/17 - Bug 21109302: Password len cannot exceed 30 bytes
Rem    hmohanku    04/04/16 - bug 22934473: add special char to ora12c function
Rem    aanverma    02/11/16 - Bug 22552142: STIG 12c v1 r2 new function
Rem                           ora12c_stig_verify_function
Rem    sumkumar    12/15/15 - Bug 22369990: Make all PVFs as common objects
Rem                           so as to make them available inside PDBs
Rem    sumkumar    12/26/14 - Proj 46885: inactive account time defaulted to
Rem                           30 days for STIG profile
Rem    sumkumar    11/20/14 - Bug 20075483 : Grant execute privilege on
Rem                           ora12c_strong_verify_function to PUBLIC
Rem    himagarw    02/13/14 - Bug #18237713: Raise exception if source or
Rem                           target string is longer than 128 bytes
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jkati       10/24/13 - bug#17543726 : Create password verify functions
Rem                           and STIG profile
Rem    jkati       10/24/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catpvf.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catpvf.sql 
Rem    SQL_PHASE: CATPVF
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem    END SQL_FILE_METADATA

@@?/rdbms/admin/sqlsessstart.sql

Rem *************************************************************************
Rem BEGIN Helper Function for out-of-the-box Oracle supplied PVFs
Rem *************************************************************************

Rem  Function: "ora_complexity_check" - Verifies the complexity
Rem            of a password string.
Rem
Rem  If not null, each of the following parameters specifies the minimum
Rem  number of characters of the corresponding type from input character set.
Rem  chars   -  All characters (i.e. string length)
Rem  letter  -  Alphabetic characters 
Rem  uppercase   -  Alphabetic uppercase characters 
Rem  lowercase   -  Alphabetic lowercase characters
Rem  digit   -  Numeric characters 
Rem  special -  All non alpha-numeric characters except
Rem             double quote which is a password delimiter

create or replace function ora_complexity_check
(password varchar2,
 chars    integer := null,
 letter   integer := null,
 uppercase    integer := null,
 lowercase    integer := null,
 digit    integer := null,
 special  integer := null)
return boolean is
   cnt_letter  integer := 0;
   cnt_upper   integer := 0;
   cnt_lower   integer := 0;
   cnt_digit   integer := 0;
   cnt_special integer := 0;
   delimiter   boolean := false;
   len         integer := nvl (length(password), 0);
   i           integer ;
   ch          char(1 char);
   lang        varchar2(512 byte);
   message     varchar2(512 char);
   ret         number;
   
begin
   -- Bug 22730089
   -- Get the current session language and use utl_lms to get the messages.
   -- Under the scenario where the language is not supported , 
   -- only the error code shall be displayed.
   lang := sys_context('userenv','lang');

   -- Classify each character in the password.
   for i in 1..len loop
      ch := substr(password, i, 1);
      if ch = '"' then
         delimiter := true;
         -- Got a delimiter, no need to validate other characters.
         exit;
         -- Observes alphabetic, numeric and special characters. 
         -- If a character is neither alphabetic nor numeric, 
         -- it is considered special.
      elsif regexp_instr(ch, '[[:alnum:]]') > 0 then
         if regexp_instr(ch, '[[:digit:]]') > 0 then
            cnt_digit := cnt_digit + 1;
         -- Certain characters can be both, numeric and alphabetic,
         -- Such characters will be counted in both categories.
         -- Ex:Roman Numerals('I'(U+2160),'II'(U+2161),'i'(U+2170),'ii'(U+2171))
         end if;
         if regexp_instr(ch, '[[:alpha:]]') > 0 then
            cnt_letter := cnt_letter + 1;
            if regexp_instr(ch, '[[:lower:]]') > 0 then
               cnt_lower := cnt_lower + 1;
            end if;
            -- Certain alphabetic characters can be both upper- or lowercase.
            -- Such characters will be counted in both categories.
            -- Ex:Latin Digraphs and Ligatures ('Nj'(U+01CB), 'Dz'(U+01F2))
            if regexp_instr(ch, '[[:upper:]]') > 0 then
               cnt_upper := cnt_upper + 1;
            end if;
         end if;
      else 
         cnt_special := cnt_special + 1;
      end if;
   end loop;

   if delimiter = true then
      ret := utl_lms.get_message(28212, 'RDBMS', 'ORA', lang, message);
      raise_application_error(-20000, message);      
   end if;
   if chars is not null and len < chars then
      ret := utl_lms.get_message(28206, 'RDBMS', 'ORA', lang, message);
      raise_application_error(-20000, utl_lms.format_message(message, CAST(chars AS PLS_INTEGER)));
   end if;

   if letter is not null and cnt_letter < letter then
      ret := utl_lms.get_message(28213, 'RDBMS', 'ORA', lang, message);
      raise_application_error(-20000, utl_lms.format_message(message, CAST(letter AS PLS_INTEGER)));
   end if;
   if uppercase is not null and cnt_upper < uppercase then
      ret := utl_lms.get_message(28214, 'RDBMS', 'ORA', lang, message);
      raise_application_error(-20000, utl_lms.format_message(message, CAST(uppercase AS PLS_INTEGER)));
   end if;
   if lowercase is not null and cnt_lower < lowercase then
      ret := utl_lms.get_message(28215, 'RDBMS', 'ORA', lang, message);
      raise_application_error(-20000, utl_lms.format_message(message, CAST(lowercase AS PLS_INTEGER)));
   end if;
   if digit is not null and cnt_digit < digit then
      ret := utl_lms.get_message(28216, 'RDBMS', 'ORA', lang, message);
      raise_application_error(-20000, utl_lms.format_message(message, CAST(digit AS PLS_INTEGER)));
   end if;
   if special is not null and cnt_special < special then
      ret := utl_lms.get_message(28217, 'RDBMS', 'ORA', lang, message);
      raise_application_error(-20000, utl_lms.format_message(message, CAST(special AS PLS_INTEGER)));
   end if;

   return(true);
end;
/
show errors;


Rem  Function: "ora_string_distance" - Calculates the Levenshtein distance
Rem            between two strings 's' and 't'.
Rem            The Levenshtein distance between two words is the minimum number 
Rem            of single-character edits (insertion, deletion, substitution) 
Rem            required to change one word into the other

create or replace function ora_string_distance
(s varchar2,
 t varchar2)
return integer is 
   s_len    integer := nvl (length(s), 0);
   t_len    integer := nvl (length(t), 0);
   type arr_type is table of number index by binary_integer;
   d_col    arr_type ;
   dist     integer := 0;
   lang     varchar2(512);
   message  varchar2(512);
   ret      number;

begin
   -- Get the cur context lang and use utl_lms for messages- Bug 22730089
   lang := sys_context('userenv','lang');
   lang := substr(lang,1,instr(lang,'_')-1);

   if s_len = 0 then
      dist := t_len;
   elsif t_len = 0 then
      dist := s_len;
   elsif s = t then 
     return(0);
   else
      for j in 1 .. (t_len+1) * (s_len+1) - 1 loop
          d_col(j) := 0 ;
      end loop;
      for i in 0 .. s_len loop
          d_col(i) := i;
      end loop;
      for j IN 1 .. t_len loop
          d_col(j * (s_len + 1)) := j;
      end loop;

      for i in 1.. s_len loop
        for j IN 1 .. t_len loop
          if substr(s, i, 1) = substr(t, j, 1)
          then
             d_col(j * (s_len + 1) + i) := d_col((j-1) * (s_len+1) + i-1) ;
          else
             d_col(j * (s_len + 1) + i) := LEAST (
                       d_col( j * (s_len+1) + (i-1)) + 1,      -- Deletion
                       d_col((j-1) * (s_len+1) + i) + 1,       -- Insertion
                       d_col((j-1) * (s_len+1) + i-1) + 1 ) ;  -- Substitution
          end if ;
        end loop;
      end loop;
      dist :=  d_col(t_len * (s_len+1) + s_len);
   end if;

   return (dist);
end;
/
show errors;

Rem *************************************************************************
Rem END Helper Function for out-of-the-box Oracle supplied PVFs
Rem *************************************************************************
              
Rem *************************************************************************
Rem BEGIN Password Verification Functions
Rem *************************************************************************

Rem Function: "ora12c_verify_function" - provided from 12c onwards
Rem
Rem This function makes the minimum complexity checks like
Rem the minimum length of the password, password not same as the
Rem username, etc. The user may enhance this function according to
Rem the need.
Rem This function must be created in SYS schema.
Rem connect sys/<password> as sysdba before running the script

CREATE OR REPLACE FUNCTION ora12c_verify_function
(username     varchar2,
 password     varchar2,
 old_password varchar2)
RETURN boolean IS
   differ   integer; 
   db_name  varchar2(40);
   i        integer;
   reverse_user dbms_id;
   canon_username dbms_id := username;
   lang     varchar2(512);
   message  varchar2(512);
   ret      number;

BEGIN
   -- Get the cur context lang and use utl_lms for messages- Bug 22730089
   lang := sys_context('userenv','lang');
   lang := substr(lang,1,instr(lang,'_')-1);

   -- Bug 22369990: Dbms_Utility may not be available at this point, so switch
   -- to dynamic SQL to execute canonicalize procedure.
   IF (substr(username,1,1) = '"') THEN
     execute immediate 'begin dbms_utility.canonicalize(:p1,  :p2, 128); end;'
                        using IN username, OUT canon_username;
   END IF;
   IF NOT ora_complexity_check(password, chars => 8, letter => 1, digit => 1,
                               special => 1) THEN
      RETURN(FALSE);
   END IF;

   -- Check if the password contains the username
   IF regexp_instr(password, canon_username, 1, 1, 0, 'i') > 0 THEN
      ret := utl_lms.get_message(28207, 'RDBMS', 'ORA', lang, message);
      raise_application_error(-20000, message);
   END IF;

   -- Check if the password contains the username reversed
   FOR i in REVERSE 1..length(canon_username) LOOP
     reverse_user := reverse_user || substr(canon_username, i, 1);
   END LOOP;
   IF regexp_instr(password, reverse_user, 1, 1, 0, 'i') > 0 THEN
      ret := utl_lms.get_message(28208, 'RDBMS', 'ORA', lang, message);
      raise_application_error(-20000, message);
   END IF;

   -- Check if the password contains the server name
   select name into db_name from sys.v$database;
   IF regexp_instr(password, db_name, 1, 1, 0, 'i') > 0 THEN
      ret := utl_lms.get_message(28209, 'RDBMS', 'ORA', lang, message);
      raise_application_error(-20000, message);
   END IF;

   -- Check if the password contains 'oracle'
   IF regexp_instr(password, 'oracle', 1, 1, 0, 'i') > 0 THEN
      ret := utl_lms.get_message(28210, 'RDBMS', 'ORA', lang, message);
      raise_application_error(-20000, message);
   END IF;

   -- Check if the password differs from the previous password by at least
   -- 3 characters
   IF old_password IS NOT NULL THEN
     differ := ora_string_distance(old_password, password);
     IF differ < 3 THEN
        ret := utl_lms.get_message(28211, 'RDBMS', 'ORA', lang, message);
        raise_application_error(-20000, utl_lms.format_message(message, 'three'));
     END IF;
   END IF ;

   RETURN(TRUE);
END;
/
show errors;

GRANT EXECUTE ON ora12c_verify_function TO PUBLIC container=current;

Rem Function: "verify_function_11G" - provided from 11G onwards.
Rem 
Rem This function makes the minimum complexity checks like
Rem the minimum length of the password, password not same as the
Rem username, etc. The user may enhance this function according to
Rem the need.

CREATE OR REPLACE FUNCTION verify_function_11G
(username varchar2,
 password varchar2,
 old_password varchar2)
RETURN boolean IS
   differ integer;
   db_name varchar2(40);
   i integer;
   i_char varchar2(10);
   simple_password varchar2(10);
   reverse_user dbms_id;
   canon_username dbms_id := username;
BEGIN
   -- Bug 22369990: Dbms_Utility may not be available at this point, so switch
   -- to dynamic SQL to execute canonicalize procedure.
   IF (substr(username,1,1) = '"') THEN
     execute immediate 'begin dbms_utility.canonicalize(:p1,  :p2, 128); end;'
                        using IN username, OUT canon_username;
   END IF;
   IF NOT ora_complexity_check(password, chars => 8, letter => 1, digit => 1) THEN
      RETURN(FALSE);
   END IF;

   -- Check if the password is same as the username or username(1-100)
   IF NLS_LOWER(password) = NLS_LOWER(canon_username) THEN
     raise_application_error(-20002, 'Password same as or similar to user');
   END IF;
   FOR i IN 1..100 LOOP
      i_char := to_char(i);
      if NLS_LOWER(canon_username)|| i_char = NLS_LOWER(password) THEN
        raise_application_error(-20005, 'Password same as or similar to ' || 
                                        'username ');
      END IF;
   END LOOP;

   -- Check if the password is same as the username reversed
   FOR i in REVERSE 1..length(canon_username) LOOP
     reverse_user := reverse_user || substr(canon_username, i, 1);
   END LOOP;
   IF NLS_LOWER(password) = NLS_LOWER(reverse_user) THEN
     raise_application_error(-20003, 'Password same as username reversed');
   END IF;

   -- Check if the password is the same as server name and or servername(1-100)
   select name into db_name from sys.v$database;
   if NLS_LOWER(db_name) = NLS_LOWER(password) THEN
      raise_application_error(-20004, 'Password same as or similar ' ||
                                      'to server name');
   END IF;
   FOR i IN 1..100 LOOP
      i_char := to_char(i);
      if NLS_LOWER(db_name)|| i_char = NLS_LOWER(password) THEN
        raise_application_error(-20005, 'Password same as or similar ' || 
                                        'to server name ');
      END IF;
   END LOOP;

   -- Check if the password is too simple. A dictionary of words may be
   -- maintained and a check may be made so as not to allow the words
   -- that are too simple for the password.
   IF NLS_LOWER(password) IN ('welcome1', 'database1', 'account1', 'user1234',
                              'password1', 'oracle123', 'computer1', 
                              'abcdefg1', 'change_on_install') THEN
      raise_application_error(-20006, 'Password too simple');
   END IF;

   -- Check if the password is the same as oracle (1-100)
    simple_password := 'oracle';
    FOR i IN 1..100 LOOP
      i_char := to_char(i);
      if simple_password || i_char = NLS_LOWER(password) THEN
        raise_application_error(-20006, 'Password too simple ');
      END IF;
    END LOOP;

   -- Check if the password differs from the previous password by at least
   -- 3 letters
   IF old_password IS NOT NULL THEN
     differ := ora_string_distance(old_password, password);
     IF differ < 3 THEN
         raise_application_error(-20011, 'Password should differ from the ' ||  
                                 'old password by at least 3 characters');
     END IF;
   END IF;

   RETURN(TRUE);
END;
/
show errors;

GRANT EXECUTE ON verify_function_11G TO PUBLIC container=current;

-- Below is the older version of the script

-- This script sets the default password resource parameters
-- This script needs to be run to enable the password features.
-- However the default resource parameters can be changed based 
-- on the need.
-- A default password complexity function is also provided.
-- This function makes the minimum complexity checks like
-- the minimum length of the password, password not same as the
-- username, etc. The user may enhance this function according to
-- the need.
-- This function must be created in SYS schema.
-- connect sys/<password> as sysdba before running the script

CREATE OR REPLACE FUNCTION verify_function
(username varchar2,
 password varchar2,
 old_password varchar2)
RETURN boolean IS
   differ integer;
   canon_username dbms_id := username;
BEGIN
   -- Bug 22369990: Dbms_Utility may not be available at this point, so switch
   -- to dynamic SQL to execute canonicalize procedure.
   IF (substr(username,1,1) = '"') THEN
     execute immediate 'begin dbms_utility.canonicalize(:p1,  :p2, 128); end;'
                        using IN username, OUT canon_username;
   END IF;
   -- Check if the password is same as the username
   IF NLS_LOWER(password) = NLS_LOWER(canon_username) THEN
     raise_application_error(-20001, 'Password same as or similar to user');
   END IF;

   -- Check if the password contains at least four characters, including
   -- one letter, one digit and one punctuation mark.
   IF NOT ora_complexity_check(password, chars => 4, letter => 1, digit => 1,
                           special => 1) THEN
      RETURN(FALSE);
   END IF;

   -- Check if the password is too simple. A dictionary of words may be
   -- maintained and a check may be made so as not to allow the words
   -- that are too simple for the password.
   IF NLS_LOWER(password) IN ('welcome', 'database', 'account', 'user', 
                              'password', 'oracle', 'computer', 'abcd') THEN
      raise_application_error(-20002, 'Password too simple');
   END IF;

   -- Check if the password differs from the previous password by at least
   -- 3 letters
   IF old_password IS NOT NULL THEN
     differ := ora_string_distance(old_password, password);
     IF differ < 3 THEN
         raise_application_error(-20004, 'Password should differ by at' ||
                                         'least 3 characters');
     END IF;
   END IF;

   RETURN(TRUE);
END;
/
show errors;

GRANT EXECUTE ON verify_function TO PUBLIC container=current;

Rem
Rem Function: "ora12c_strong_verify_function" - provided from 12c onwards for
Rem           stringent password check requirements.
Rem 

create or replace function ora12c_strong_verify_function
(username     varchar2,
 password     varchar2,
 old_password varchar2)
return boolean IS
   differ   integer;
   lang     varchar2(512);
   message  varchar2(512);
   ret      number;

begin
   -- Get the cur context lang and use utl_lms for messages- Bug 22730089
   lang := sys_context('userenv','lang');
   lang := substr(lang,1,instr(lang,'_')-1);

   if not ora_complexity_check(password, chars => 9, uppercase => 2, 
                           lowercase => 2, digit => 2, special => 2) then 
      return(false);
   end if;

   -- Check if the password differs from the previous password by at least
   -- 4 characters
   if old_password is not null then 
      differ := ora_string_distance(old_password, password);
      if differ < 4 then
         ret := utl_lms.get_message(28211, 'RDBMS', 'ORA', lang, message);
         raise_application_error(-20000, utl_lms.format_message(message, 'four'));
      end if;
   end if;

   return(true);
end;
/
show errors;

GRANT EXECUTE ON ora12c_strong_verify_function TO PUBLIC container=current;

Rem
Rem Function: "ora12c_stig_verify_function" - provided from 12c onwards for
Rem           stringent password check requirements to meet 
Rem           "STIG for Oracle 12c" password complexity check requirement.
Rem 
Rem This function is provided to give stronger password complexity function
Rem that would take into consideration recommendations from Department of
Rem Defense Database Security Technical Implementation Guide (STIG) v1 r2
Rem released on 22-Jan-2016.

create or replace function ora12c_stig_verify_function
 ( username     varchar2,
   password     varchar2,
   old_password varchar2)
 return boolean IS
   differ  integer;
   lang    varchar2(512);
   message varchar2(512);
   ret     number;

begin
   -- Get the cur context lang and use utl_lms for messages- Bug 22730089
   lang := sys_context('userenv','lang');
   lang := substr(lang,1,instr(lang,'_')-1);

   if not ora_complexity_check(password, chars => 15, uppercase => 1, 
                           lowercase => 1, digit => 1, special => 1) then 
      return(false);
   end if;

   -- Check if the password differs from the previous password by at least
   -- 8 characters
   if old_password is not null then 
      differ := ora_string_distance(old_password, password);
      if differ < 8 then
         ret := utl_lms.get_message(28211, 'RDBMS', 'ORA', lang, message);
         raise_application_error(-20000, utl_lms.format_message(message, 'eight'));
      end if;
   end if;

   return(true);
end;
/
show errors;

GRANT EXECUTE ON ora12c_stig_verify_function TO PUBLIC container=current;

Rem *************************************************************************
Rem END Password Verification Functions
Rem *************************************************************************

Rem
Rem STIG Compliant User Profile. If the profile already exists,
Rem do nothing as the update of inactive_account_time and 
Rem password_verify_function is moved to the upgrade script
Rem a1201000.sql
Rem

declare
  profile_exists exception;
  pragma exception_init(profile_exists, -02379);
begin
  execute immediate 'create profile ora_stig_profile limit
                     password_life_time 60
                     password_grace_time 5
                     password_reuse_time 365
                     password_reuse_max 10
                     failed_login_attempts 3
                     password_lock_time unlimited
                     inactive_account_time 35
                     idle_time 15
                     password_verify_function ora12c_stig_verify_function
                     container=current';
exception
  when profile_exists then
    null;
end;
/
show errors;

@?/rdbms/admin/sqlsessend.sql
