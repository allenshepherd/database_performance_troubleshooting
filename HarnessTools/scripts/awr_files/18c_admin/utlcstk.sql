Rem
Rem $Header: plsql/admin/utlcstk.sql /main/6 2015/07/01 20:57:56 traney Exp $
Rem
Rem utlcstk.sql
Rem
Rem Copyright (c) 2009, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlcstk.sql - UTiLity Call STacK routines
Rem
Rem    DESCRIPTION
Rem      PL/SQL package to provide information about currently executing
Rem    subprograms. Individual functions return subprogram names, unit names,
Rem    owner names, edition names, and line numbers for given
Rem    dynamic depths. More functions return error stack information.
Rem
Rem    NOTES
Rem    
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: plsql/admin/utlcstk.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/utlcstk.sql
Rem SQL_PHASE: UTLCSTK
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    traney      06/15/15 - 17061888: actual_edition replaces current_edition
Rem    surman      01/09/14 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    traney      01/28/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


/*
  Package: utl_call_stack
  
  PL/SQL package to provide information about currently executing subprograms.
  Individual functions return subprogram names, unit names, owner names, edition
  names, and line numbers for given dynamic depths. More functions return error 
  stack information.

  Key Concepts:

  Dynamic Depth - The dynamic depth of an executing instance of a PL/SQL
  subprogram is defined recursively. 

        - The dynamic depth of the currently executing subprogram instance is
        one. 

        - Otherwise, the dynamic depth of the subprogram instance is one more
        than the dynamic depth of the subprogram it invoked.  
        
        - If there is a SQL, Java, or other non-PL/SQL context that invoked or
        was invoked by an executing subprogram, it occupies a level on the
        call stack as if it were a subprogram.

  Consider a call stack in which A calls B calls C calls D calls E calls F
  calls E. The stack can be written as a line with the dynamic depths written
  underneath: 

  >  A B C D E F E 
  >  7 6 5 4 3 2 1

  Lexical Depth - The lexical depth of a PL/SQL subprogram is defined
  recursively.

        - The lexical depth of a unit, an anonymous block, trigger, or ADT is
        one (1).

        - The lexical depth of a subprogram defined within another object is
        one plus the lexical depth of that object.

  Blocks do not affect lexical depth.

  Error Depth - The error depth is the number of errors on the error stack.

  For example, consider the following anonymous block.

  > begin
  >   begin
  >     ... (1)
  >     raise zero_divide;
  >   exception
  >     when others then
  >       raise no_data_found;
  >   end;
  > exception
  >   when others then
  >     ... (2) 
  > end;

  The error depth at (1) is zero and at (2) is two.

  Backtrace - The backtrace is a trace from where the exception was thrown
  to where the backtrace was examined.

  Consider a call stack in which A calls B calls C and C raises an exception.
  If the backtrace was examined in C, the backtrace would have one unit, C,
  and backtrace depth would be one. If it was examined in A, it would have
  three units, A, B and C, and backtrace depth would be three.

  The depth of a backtrace is zero in the absence of an exception.

  Notes:
  Compiler optimizations can change lexical, dynamic and backtrace depth.

  UTL_CALL_STACK is not supported past RPC boundaries. For example, if A calls
  remote procedure B, B will not be able to obtain information about A using
  UTL_CALL_STACK.

  Lexical unit information is available through the PL/SQL conditional
  compilation feature and is therefore not exposed through UTL_CALL_STACK.

  Security Model:

  UTL_CALL_STACK will not show passed wrapped units. 

  For example, consider a call stack in which A calls B calls C and C calls
  UTL_CALL_STACK to determine the subprogram list.  If B is wrapped, the
  subprogram list would only show C.  

*/

CREATE OR REPLACE PACKAGE utl_call_stack IS

  /* 
    Exception: BAD_DEPTH_INDICATOR
    
    This exception is raised when a provided depth is out of bounds.
        - Dynamic and lexical depth are positive integer values.
        - Error and backtrace depths are non-negative integer values
        and are zero only in the absence of an exception.

  */
  BAD_DEPTH_INDICATOR EXCEPTION;
    pragma EXCEPTION_INIT(BAD_DEPTH_INDICATOR, -64610);
  
  /* 
    Type: UNIT_QUALIFIED_NAME
    
    This data structure is a varray whose individual elements are, in order,
    the unit name, any lexical parents of the subprogram, and the subprogram
    name.

    For example, consider the following contrived PL/SQL procedure.

    > procedure topLevel is
    >   function localFunction(...) returns varchar2 is
    >     function innerFunction(...) returns varchar2 is
    >       begin
    >         declare
    >           localVar pls_integer;
    >         begin
    >           ... (1)
    >         end;
    >       end;
    >   begin
    >     ... 
    >   end;

   The unit qualified name at (1) would be

   >    ["topLevel", "localFunction", "innerFunction"]

   Note that the block enclosing (1) does not figure in the unit qualified
   name.

   If the unit were an anonymous block, the unit name would be "__anonymous_block"

  */
  TYPE UNIT_QUALIFIED_NAME IS VARRAY(256) OF VARCHAR2(32767);
  
  /* 
    Function: subprogram
    
    Returns the unit-qualified name of the subprogram at the specified dynamic 
    depth.
    
    Parameters:
    
      dynamic_depth - The depth in the call stack.
      
    Returns:
    
      The unit-qualified name of the subprogram at the specified dynamic depth.
 
    Exception:

      Raises <BAD_DEPTH_INDICATOR>
   */
  FUNCTION subprogram(dynamic_depth IN PLS_INTEGER) RETURN UNIT_QUALIFIED_NAME;
  
  /* 
    Function: concatenate_subprogram
    
    Convenience function to concatenate a unit-qualified name, a varray, into
    a varchar2 comprising the names in the unit-qualified name, separated by
    dots.
    
    Parameters:
    
      qualified_name - A unit-qualified name.
      
    Returns:
    
      A string of the form "UNIT.SUBPROGRAM.SUBPROGRAM...LOCAL_SUBPROGRAM".

   */
  FUNCTION concatenate_subprogram(qualified_name IN UNIT_QUALIFIED_NAME)
           RETURN VARCHAR2;
  
  /* 
    Function: owner
    
    Returns the owner name of the unit of the subprogram at the specified 
    dynamic depth.
    
    Parameters:
    
      dynamic_depth - The depth in the call stack.
      
    Returns:
    
      The owner name of the unit of the subprogram at the specified dynamic 
      depth.

    Exception:

      Raises <BAD_DEPTH_INDICATOR>.
   */
  FUNCTION owner(dynamic_depth IN PLS_INTEGER) RETURN VARCHAR2;
  
  /* 
    Function: current_edition
    
    Returns the current edition name of the unit of the subprogram at the 
    specified dynamic depth.
    
    Parameters:
    
      dynamic_depth - The depth in the call stack.
      
    Returns:
    
      The current edition name of the unit of the subprogram at the specified 
      dynamic depth.

    Exception:

      Raises <BAD_DEPTH_INDICATOR>.
   */
  FUNCTION current_edition(dynamic_depth IN PLS_INTEGER) RETURN VARCHAR2;
    pragma deprecate(current_edition,
                     'UTL_CALL_STACK.CURRENT_EDITION is deprecated!');
  
  /* 
    Function: actual_edition
    
    Returns the name of the edition in which the unit of the subprogram at the 
    specified dynamic depth is actual.
    
    Parameters:
    
      dynamic_depth - The depth in the call stack.
      
    Returns:
    
      The name of the edition in which the unit of the subprogram at the 
      specified dynamic depth is actual.

    Exception:

      Raises <BAD_DEPTH_INDICATOR>.
   */
  FUNCTION actual_edition(dynamic_depth IN PLS_INTEGER) RETURN VARCHAR2;
  
  /* 
    Function: unit_line
    
    Returns the line number of the unit of the subprogram at the specified 
    dynamic depth.
    
    Parameters:
    
      dynamic_depth - The depth in the call stack.
      
    Returns:
    
      The line number of the unit of the subprogram at the specified dynamic 
      depth.

    Exception:

      Raises <BAD_DEPTH_INDICATOR>.
   */
  FUNCTION unit_line(dynamic_depth IN PLS_INTEGER) RETURN PLS_INTEGER;
  
  /* 
    Function: unit_type
    
    Returns the type of the unit of the subprogram at the specified dynamic
    depth.
    
    Parameters:
    
      dynamic_depth - The depth in the call stack.
      
    Returns:
    
      The type of the unit of the subprogram at the specified dynamic depth.

    Exception:

      Raises <BAD_DEPTH_INDICATOR>.
   */
  FUNCTION unit_type(dynamic_depth IN PLS_INTEGER) RETURN VARCHAR2;
  
  /* 
    Function: dynamic_depth
    
    Returns the number of subprograms on the call stack.
    
    Parameters:
      
    Returns:
    
      The number of subprograms on the call stack.

   */
  FUNCTION dynamic_depth RETURN PLS_INTEGER;
  
  /* 
    Function: lexical_depth
    
    Returns the lexical nesting depth of the subprogram at the specified dynamic
    depth.
    
    Parameters:
    
      dynamic_depth - The depth in the call stack.
      
    Returns:
    
      The lexical nesting depth of the subprogram at the specified dynamic 
      depth.

    Exception:

      Raises <BAD_DEPTH_INDICATOR>.
   */
  FUNCTION lexical_depth(dynamic_depth IN PLS_INTEGER) RETURN PLS_INTEGER;
  
  /* 
    Function: error_depth
    
    Returns the number of errors on the error stack.
    
    Parameters:
      
    Returns:
    
      The number of errors on the error stack.

   */
  FUNCTION error_depth RETURN PLS_INTEGER;
  
  /* 
    Function: error_number
    
    Returns the error number of the error at the specified error depth.
    
    Parameters:
    
      error_depth - The depth in the error stack.
      
    Returns:
    
      The error number of the error at the specified error depth.

    Exception:
      
      Raises <BAD_DEPTH_INDICATOR>.
   */
  FUNCTION error_number(error_depth IN PLS_INTEGER) RETURN PLS_INTEGER;
  
  /* 
    Function: error_msg
    
    Returns the error message of the error at the specified error depth.
    
    Parameters:
    
      error_depth - The depth in the error stack.
      
    Returns:
    
      The error message of the error at the specified error depth.

    Exception:
      
      Raises <BAD_DEPTH_INDICATOR>.
   */
  FUNCTION error_msg(error_depth IN PLS_INTEGER) RETURN VARCHAR2;
  
  /* 
    Function: backtrace_depth
    
    Returns the number of backtrace items in the backtrace.
    
    Parameters:
      
    Returns:

      The number of backtrace items in the backtrace, zero in the absence of
      an exception.

   */
  FUNCTION backtrace_depth RETURN PLS_INTEGER;
  
  /* 
    Function: backtrace_unit
    
    Returns the name of the unit at the specified backtrace depth.
    
    Parameters:
    
      backtrace_depth - The depth in the backtrace.
      
    Returns:
    
      The name of the unit at the specified backtrace depth.

    Exception:

      Raises <BAD_DEPTH_INDICATOR>. Note that backtrace_unit(0); always raises
      this exception.

   */
  FUNCTION backtrace_unit(backtrace_depth IN PLS_INTEGER) RETURN VARCHAR2;
  
  /* 
    Function: backtrace_line
    
    Returns the line number of the unit at the specified backtrace depth.
    
    Parameters:
    
      backtrace_depth - The depth in the backtrace.
      
    Returns:
    
      The line number of the unit at the specified backtrace depth.

    Exception:

      Raises <BAD_DEPTH_INDICATOR>. Note that backtrace_line(0); always raises
      this exception.
   */
  FUNCTION backtrace_line(backtrace_depth IN PLS_INTEGER) RETURN PLS_INTEGER;
    
END;
/

GRANT EXECUTE ON utl_call_stack TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_call_stack FOR sys.utl_call_stack;

@?/rdbms/admin/sqlsessend.sql
