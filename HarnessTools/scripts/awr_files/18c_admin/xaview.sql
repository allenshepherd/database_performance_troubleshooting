rem
rem $Header: rdbms/admin/xaview.sql /main/5 2017/05/28 22:46:13 stanaya Exp $ xaview2.sql Copyr (c) 1989 Oracle
rem

Rem ==================================================================
Rem NAME
Rem   XAVIEW.SQL
Rem FUNCTION
Rem   Create the view necessary to do XA recovery scan of prepared
Rem   and heuristically completed transactions.
Rem NOTES
Rem   The view 'XATRAN' basically combines information from two
Rem   different types of tables:
Rem      pending_trans$ & pending_sessions$
Rem      x$k2gte2
Rem   The view v$pending_xatrans$ combines and then filters information
Rem   from the table pending_trans$ and pending_sessions$ into format
Rem   that satisfy XA criteria.
Rem   Then the view v$xatrans$ combines information from x$k2gte2 and
Rem   v$pending_xatrans$.
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xaview.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xaview.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem MODIFIED
Rem   andmuell  01/24/17 - bug19603256: drop synonyms along with the views
Rem   krajaman  04/12/11 - Change view names to d$ with a synonym
Rem    ncramesh   08/04/98 - change for sqlplus
Rem   cchew     07-15-92  - added fmt column
Rem   cchew     05-22-92  - No more fmt=0 condition
Rem   cchew     01-19-92  - Creation
Rem ==================================================================


DROP SYNONYM v$xatrans$;
DROP SYNONYM v$pending_xatrans$;

DROP VIEW d$xatrans$;
DROP VIEW d$pending_xatrans$;


CREATE VIEW d$pending_xatrans$ AS
(SELECT global_tran_fmt, global_foreign_id, branch_id
   FROM   sys.pending_trans$ tran, sys.pending_sessions$ sess
   WHERE  tran.local_tran_id = sess.local_tran_id
     AND    tran.state != 'collecting'
     AND    BITAND(TO_NUMBER(tran.session_vector),
                   POWER(2, (sess.session_id - 1))) = sess.session_id)
/

create synonym v$pending_xatrans$ for d$pending_xatrans$;


CREATE VIEW d$xatrans$ AS
(((SELECT k2gtifmt, k2gtitid_ext, k2gtibid
   FROM x$k2gte2
   WHERE  k2gterct=k2gtdpct)
 MINUS
  SELECT global_tran_fmt, global_foreign_id, branch_id
   FROM   d$pending_xatrans$)
UNION
 SELECT global_tran_fmt, global_foreign_id, branch_id
   FROM   d$pending_xatrans$)
/

create synonym v$xatrans$ for d$xatrans$;

