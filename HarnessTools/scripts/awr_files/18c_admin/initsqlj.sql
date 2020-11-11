Rem
Rem $Header: sqlj/install/sqljutl.sql /main/4 2017/04/16 23:09:21 prramakr Exp $
Rem
Rem sqljutl.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      sqljutl.sql - PL/SQL package for sqlj functions
Rem
Rem    DESCRIPTION
Rem      This file creates the SQLJUTL package during db creation. 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    prramakr    04/12/17 - Bug 25547955: qualify the objects
Rem    ssahu       08/12/15 - bug 21157922
Rem    sonkumar    09/03/13 - File for SQLJUTL package creation
Rem    sonkumar    09/03/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: sqlj/install/sqljutl.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

--
-- CREATE SQLJUTL PACKAGE
--
create or replace package sqljutl authid current_user as

   -- The following is required at translate-time for SQLJ

   function has_default(l_owner varchar2,
                        proc varchar2,
                        seq number,
                        ovr varchar2 DEFAULT NULL,
                        pkg_nm varchar2 DEFAULT NULL) return number;

   -- The following is required at translate-time for JPublisher
   procedure get_typecode(tid raw, code OUT number,
                          class OUT varchar2, typ OUT number);

   -- The following might be used at runtime for converting
   -- between SQL and PL/SQL types 
   function bool2int(b boolean) return integer;
   function int2bool(i integer) return boolean;
   function ids2char(iv DSINTERVAL_UNCONSTRAINED) return CHAR;
   function char2ids(ch CHAR) return DSINTERVAL_UNCONSTRAINED;
   function iym2char(iv YMINTERVAL_UNCONSTRAINED) return CHAR;
   function char2iym(ch CHAR) return YMINTERVAL_UNCONSTRAINED;
   function uri2vchar(uri SYS.URITYPE) return VARCHAR2;
end sqljutl;
/

--
--Create SQLJUTL package body
--


create or replace package body sqljutl is

   function has_default(l_owner varchar2,
                        proc varchar2,
                        seq number,
                        ovr varchar2 DEFAULT NULL,  
                        pkg_nm varchar2 DEFAULT NULL) return number is
            def char := NULL;
begin
   begin
      if pkg_nm IS NULL
      then
        if ovr is NULL
        then
           select upper(DEFAULTED) INTO def FROM SYS.ALL_ARGUMENTS
           WHERE OBJECT_NAME = proc AND OWNER = l_owner
           AND SEQUENCE = seq and OVERLOAD is NULL and PACKAGE_NAME is NULL;
        else
           select upper(DEFAULTED) INTO def FROM SYS.ALL_ARGUMENTS
           WHERE OBJECT_NAME = proc AND OWNER = l_owner
           AND SEQUENCE = seq  and OVERLOAD = ovr and PACKAGE_NAME IS NULL;
        end if;
      else
        if ovr is NULL
        then
           select upper(DEFAULTED) INTO def FROM SYS.ALL_ARGUMENTS
           WHERE OBJECT_NAME = proc AND OWNER = l_owner
           AND SEQUENCE = seq and OVERLOAD is NULL and PACKAGE_NAME = pkg_nm;
        else
           select upper(DEFAULTED) INTO def FROM SYS.ALL_ARGUMENTS
           WHERE OBJECT_NAME = proc AND OWNER = l_owner
           AND SEQUENCE = seq  and OVERLOAD = ovr and PACKAGE_NAME = pkg_nm;
        end if;

      end if;

      EXCEPTION 
	WHEN NO_DATA_FOUND THEN 
           return 0;
        WHEN OTHERS THEN
           raise_application_error(-20001,'Error - '||SQLCODE||' -ERROR- '||SQLERRM);         
      
   end;

      if def = 'N'
      then return 0;
      else return 1;
      end if;
    return 0; 
   end has_default;

   procedure get_typecode
               (tid raw, code OUT number,
                class OUT varchar2, typ OUT number) is
      m NUMBER;
   begin
      SELECT typecode, externname, externtype INTO code, class, typ
      FROM SYS.TYPE$ WHERE toid = tid;
   exception
      WHEN TOO_MANY_ROWS
      THEN
      begin
        SELECT max(version#) INTO m FROM SYS.TYPE$ WHERE toid = tid;
        SELECT typecode, externname, externtype INTO code, class, typ
        FROM SYS.TYPE$ WHERE toid = tid AND version# = m;
      end;
   end get_typecode;

   function bool2int(b BOOLEAN) return INTEGER is
   begin if b is null then return null;
         elsif b then return 1;
         else return 0; end if;
   end bool2int;

   function int2bool(i INTEGER) return BOOLEAN is
   begin if i is null then return null;
         else return i<>0;
         end if;
   end int2bool;

   function ids2char(iv DSINTERVAL_UNCONSTRAINED) return CHAR is
      res CHAR(19);
   begin
      res := iv;
      return res;
   end ids2char;


   function char2ids(ch CHAR) return DSINTERVAL_UNCONSTRAINED is
      iv DSINTERVAL_UNCONSTRAINED;
   begin
      iv := ch;
      return iv;
   end char2ids;

   function iym2char(iv YMINTERVAL_UNCONSTRAINED) return CHAR is
      res CHAR(9);
   begin
      res := iv;
      return res;
   end iym2char;

   function char2iym(ch CHAR) return YMINTERVAL_UNCONSTRAINED is
      iv YMINTERVAL_UNCONSTRAINED;
   begin
      iv := ch;
      return iv;
   end char2iym;

   -- SYS.URITYPE and VARCHAR2
   function uri2vchar(uri SYS.URITYPE) return VARCHAR2 is
   begin
      return uri.geturl;
   end uri2vchar;

end sqljutl;
/

grant execute on sqljutl to public ;



