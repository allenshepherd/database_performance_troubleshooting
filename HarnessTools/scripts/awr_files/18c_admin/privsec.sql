rem
rem
Rem Copyright (c) 1996, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem    NAME
Rem      privsec.sql
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa_sec - Utitility procedures/functions to provide security
Rem                     to procedures accessed via the PL/SQL Agent.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     akatti     11/22/05 -  Bug fix#4722130 validate arguments of
Rem                            set_protection_realm
Rem     rpang      06/29/96 -  Creation
Rem

create or replace package body OWA_SEC is

   /*  NL_CHAR can be computed from a Unicode string in a portable manner. */
   NL_CHAR constant varchar2(10) := owa_cx.nl_char;
   /* Constant is set here instead of owachars to avoid invalid objects */
   CR_CHAR constant varchar2(10) := chr(13);

     /*******************************************************************/
    /* Procedure to specify the PL/SQL Agent's authorization scheme    */
   /*******************************************************************/
   procedure set_authorization(scheme in integer) is
   begin
      owa.auth_scheme := scheme;
   end;

     /*******************************************************************/
    /* Functions to obtain the Web client's authentication information */
   /*******************************************************************/
   function get_user_id return varchar2 is
   begin
      return owa.user_id;
   end;

   function get_password return varchar2 is
   begin
      return owa.password;
   end;

   function get_client_ip return owa_util.ip_address is
   begin
      return owa.ip_address;
   end;

   function get_client_hostname return varchar2 is
   begin
      return owa.hostname;
   end;

     /*******************************************************************/
    /* Procedure to specify the dynamic page's protection realm        */
   /*******************************************************************/
   procedure set_protection_realm(realm in varchar2) is
      l_realm varchar2(32767);
   begin
      -- validate argument
      l_realm := owa_util.validate_arg(realm);
      owa.protection_realm := l_realm;
   end;

end;
/
show errors
