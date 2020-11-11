# 
# $Header: rdbms/admin/catcon.pm /st_rdbms_18.0/7 2018/05/02 12:52:06 akruglik Exp $
#
# catcon.pm
# 
# Copyright (c) 2011, 2018, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      catcon.pm - CONtainer-aware Perl Module for creating/upgrading CATalogs
#
#    DESCRIPTION
#      This module defines subroutines which can be used to execute one or 
#      more SQL statements or a SQL*Plus script in 
#      - a non-Consolidated Database, 
#      - all Containers of a Consolidated Database, or 
#      - a specified Container of a Consolidated Database
#
#    NOTES
#      Subroutines which handle invocation of SQL*Plus scripts may be invoked 
#      from other scripts (e.g. catctl.pl) or by invoking catcon.pl directly.  
#      Subroutines that execute one or more SQL statements may only be 
#      invoked from other Perl scripts.
#
#      The following environment variables may be used to communicate with
#      catcon.pm:
#        CATCON_ALL_PDB_MODE - may be set to a CATCON_PDB_MODE_* constant 
#          representing a mode in which ALL pdbs should be opened before 
#          running scripts against them; ignored if catconPdbMode() was called
#        CATCON_DIAG_MSG_BUF_SIZE - may be set to a non-negative integer or a 
#          string UNLIMITED to control size of a buffer used to retain 
#          diagnostic messages which will be displayed if an error condition 
#          is encountered
#        CATCON_DEBUG - if true, will cause production of diagnostic output 
#                       by catcon
#        CATCONUSERPASSWD - environment variable containing user password
#        CATCONINTERNALPASSWD - environment variable containing internal 
#          password
#
#    MODIFIED   (MM/DD/YY)
#    akruglik    04/24/18 - backport changes from akruglik_catcon_on_rac_3
#    apfwkr      03/22/18 - Backport
#                           akruglik_ci_backport_27679664_12.2.0.1.0adwbp from
#                           st_rdbms_pt-dwcs
#    apfwkr      03/15/18 - Backport akruglik_bug-27634676 from main
#    akruglik    03/14/18 - Backport akruglik_bug-27679664 from main
#    akruglik    03/12/18 - Bug 27679664: ignore PDBs which have status other
#                           than NEW or NORMAL
#    akruglik    03/04/18 - Bug 27634676: reset_pdb_modes should not reopen
#                           PDBs which were not open in the desired mode on
#                           instances other than the default instance if told
#                           to open PDBs using the default instance
#    akruglik    03/04/18 - add support for --open_pdb_with_no_svcs
#    akruglik    12/28/17 - LRG 20886252: remove code forcing production of
#                           diagnostic messages
#    akruglik    09/19/17 - Bug 26527096: define catconGroupByUpgradeLevel +
#                           modify code altering mode in which App Root Clones
#                           are opened to reflect the fact that they inherit 
#                           the mode from the App Root
#    akruglik    09/11/17 - change USER_PASSWD_ENV_TAG and 
#                           INTERNAL_PASSWD_ENV_TAG into constants 
#    akruglik    09/01/17 - Bug 26634841: during wrapup delete logs
#                           corresponding to processes that were never used +
#                           if using multiple RAC instances, spool output into
#                           PDB-specific log files
#    akruglik    08/28/17 - Bug 26551708: modify exec_DB_script to not 
#                           restrict characters that may precede a marker to 
#                           only blank characters
#    akruglik    08/22/17 - Bug 26533232: first attempt failed to handle case
#                           where SYS AS <role other than SYSDBA> was specified
#    akruglik    07/19/17 - Allow connect strings with any admin role
#    akruglik    07/12/17 - Bug 26120968: having constructed a user connect
#                           string, verify that it will allow us to connect to
#                           the database
#    akruglik    07/07/17 - LRG 20422036: catconInit and catconInit2 need to
#                           receive script argument tag by reference so that
#                           they can return a default value to the caller if no
#                           value was provided by the caller
#    akruglik    07/05/17 - LRG 20421900: add comment describing find_in_path
#                           and change name of last arg to reflect the fact
#                           that it can be used to find binaries besides
#                           sqlplus
#    akruglik    06/29/17 - Bug 26238195: close CATCONOUT in catconWrapup
#    akruglik    06/14/17 - Bug 26135561: allow caller to specify path to
#                           sqlplus
#    akruglik    06/14/17 - Bug 26275415: in force_pdb_modes, avoid adding to
#                           revertPdbModes description of a PDB MOUNTED on a
#                           non-default instance
#    akruglik    06/05/17 - LRG 20238914: wrap connect with set define off/on
#                           to deal with passwords containing ampersands
#    akruglik    05/30/17 - Bug 25368019: use default values for NEWPAGE and
#                           PAGESIZE sqlplus settings when running internal
#                           queries
#    akruglik    05/18/17 - Bug 26095985: modify text of message generated in
#                           end_processes so as to avoid confusing DBUA into
#                           not reporting status of each DB component during
#                           the upgrade
#    akruglik    05/10/17 - Bug 25696936: escape newline chars in a statement
#                           to be executed when issuing alter session set
#                           application action
#    akruglik    05/09/17 - Bug 26030086: mask passwords when displaying
#                           parameters passed to catconInit
#    akruglik    04/27/17 - Bug 25942890: change catconRevertPdbModes to
#                           produce messages at DEBUG log level
#    akruglik    04/20/17 - Bug 25507396: add support for --ezconn_to_pdb flag
#    akruglik    04/17/17 - Bug 25700335: log_file_base may not contain any 
#                           directory names
#    akruglik    04/04/17 - If connected to a RAC database and the caller
#                           requested that we utilize all available instances,
#                           use srvctl to discover and open RAC instances that
#                           are closed and use them in running scripts
#    thbaby      03/23/17 - unless running user scripts, reset_pdb_modes needs
#                           to set _oracle_script in case it is called to
#                           reopen an App Root Clone; also, we want to skip 
#                           App Root Clones in get_con_info if running user 
#                           scripts
#    molagapp    03/07/17 - reduce duplicate functions in rman.pm
#    akruglik    02/22/17 - Bug 25392172: correct reset_pdb_modes to avoid
#                           opening PDBs in UPGRADE mode on more than one
#                           instance
#    akruglik    01/24/17 - Bug 25396566: modify validate_script_path to
#                           recognize both / and \ in script name
#    akruglik    01/17/17 - Bug 25404458: avoid references to $CDBorFedRoot
#                           unless it is defined
#    akruglik    01/11/17 - Bug 25376281: check whether get_prop returned undef
#                           before attempting to compare the return value
#    akruglik    01/09/17 - Bug 25366291: do not report an error if
#                           gen_inst_conn_strings fetches no rows; force all 
#                           processing to occur on the default instance
#    akruglik    01/09/17 - Bug 25363697: avoid sending diagnostics statements
#                           to sqlplus process immediately after executing
#                           catshutdown.sql even if it was executed by a
#                           separate call to catconExec
#    akruglik    01/04/17 - Bug 25315864: Instead of trying to set ORACLE_SID,
#                           use connect strings
#    akruglik    12/20/16 - Bug 25259127: do not quote name of the errorlogging
#                           table since it may contain owner name
#    akruglik    12/16/16 - Bug 25243199: temporarily disable --all_instances
#    akruglik    11/29/16 - Bug 20193612: if running on a RAC database, make
#                           use of multiple instances when processing PDBs
#    akruglik    11/29/16 - Bug 25132308: 12.1.0.1 does not support specifying 
#                           FORCE in ALTER PDB CLOSE, so we will avoid using 
#                           FORCE (or INSTANCES clause) when closing PDBs in 
#                           a 12.1 CDB
#    akruglik    11/28/16 - Bug 25117295: do not specify FORCE if connected to
#                           12.1 CDB and closing a PDB on multiple instances
#    akruglik    11/23/16 - Bug 25086870: account for maximum number of
#                           sessions and the number of existing sessions when
#                           computing number of sqlplus processes to spawn
#    akruglik    11/16/16 - Bug 25089301: use gv$pdbs rather than x$con in
#                           curr_pdb_mode_info
#    akruglik    11/14/16 - Add --upgrade option
#    akruglik    11/09/16 - Bug 25061922: due to an apparent bug in 12.1 code
#                           processing ALTER PDB OPEN/CLOSE
#                           INSTANCES=(inst-list), we cannot use this syntax if
#                           working on a 12.1 DBMS
#    akruglik    11/04/16 - XbranchMerge akruglik_cloud_fixup from
#                           st_rdbms_12.2.0.1.0cloud
#    akruglik    10/29/16 - Bug 19525930: clean up catcon code
#    akruglik    09/12/16 - Add support for --force_pdb_open
#    akruglik    09/08/16 - XbranchMerge akruglik_lrg-19650060 from
#                           st_rdbms_12.2.0.1.0
#    akruglik    09/06/16 - LRG 19650060: Remove invalid Signal handler + 
#                           ignore SIGPIPE if catcon needs to exit because 
#                           some SQL*Plus process died.
#    hohung      08/08/16 - Bug24385625: Look for catcon_kill_sess_gen.sql in
#                           script directory
#    akruglik    08/01/16 - XbranchMerge akruglik_bug-24341339 from
#                           st_rdbms_12.2.0.1.0
#    akruglik    07/29/16 - Modify caller of openSpoolFile to deal with cases
#                           where the spool file was not available
#    akruglik    07/27/16 - XbranchMerge akruglik_bug23711335_12.2.0.1.0 from
#                           st_rdbms_12.2.0.1.0
#    akruglik    07/21/16 - XbranchMerge akruglik_lrg-19633516 from
#                           st_rdbms_12.2.0.1.0
#    akruglik    07/18/16 - LRG 19633516: allow caller to determine whether
#                           death of a spawned sqlplus process should cause
#                           catcon to die
#    akruglik    07/14/16 - Bug 23711335: modify code constructing kill session
#                           script to avoid delays due to concurrent file
#                           access
#    akruglik    06/23/16 - Bug 23614674: verify that a file exists befroe
#    akruglik    06/23/16 - Bug 23614674: verify that a file exists before
#                           attempting to remove it
#    akruglik    06/21/16 - Bug 23292787: modify catconExec to handle cases
#                           where -c or -C and -r was specified
#    akruglik    06/06/16 - Bug 22887047: if a SQLPlus process dies, start a
#                           new one in its place
#    akruglik    05/25/16 - Bug 23326538: use syntax acceptable to Perl 5.6.1
#                           to declare constants
#    akruglik    05/09/16 - Bug 23106360: do not try to open PDB$SEED in READ
#                           WRITE mode if the CDB is open READ ONLY
#    sursridh    04/13/16 - Bug 23020062: Add option to disable pdb lockdown.
#    akruglik    02/10/16 - (22132084): modify get_log_file_base_path to use
#                           cwd if the caller has not supplied LogDir
#    jerrede     01/26/16 - Add Parsing Comment for Andre
#    akruglik    01/08/16 - Bug 22330680: modify exec_DB_script to not assume 
#                           that lines containing a marker start with it
#    akruglik    11/13/15 - (22203085): do not display values of hidden
#                           arguments in diagnostic output
#    akruglik    11/09/15 - Define catconSqlplus
#    jerrede     10/10/15 - Bug 21446778 when catconForce is used don't 
#                           validatate pdb when all pdbs are not opened. 
#                           Functionality needed for upgrade when opening 
#                           PDBs in parallel.
#    juilin      09/23/15 - bug-21485248: replace federation with application
#    frealvar    08/11/15 - bug21274752: message which warns when a component
#                           is not in the database was moved to catctl.pl
#    akruglik    07/16/15 - Bug 21447540: in validate_script_path, if the file
#                           could not be found and we were told to ignore it,
#                           skip other file checks
#    akruglik    06/12/15 - Bug 21202842: avoid displaying passwords
#    akruglik    05/06/15 - Bug 20782683: in validate_con_names, distinguish
#                           case where some specified PDBs were not open from
#                           the case where all PDBs were excluded
#    akruglik    04/29/15 - Bug 20969508: add a flag to tell catcon to not
#                           report error if certain types of violations are
#                           encountered
#    akruglik    04/17/15 - Bug 20905400: modify exec_DB_script to return log
#                           of the output
#    raeburns    03/06/15 - Add query to catconExec to skip running scripts
#    jerrede     02/23/15 - Add no directory prepend for full Windows paths
#    jerrede     02/23/15 - Fix Rae's change to not append the src directory
#                           to a file.  This fails on Windows.
#    akruglik    02/02/15 - Bug 20307059: ensure that container name and its
#                           mode do not get split across multiple lines
#    raeburns    10/22/14 - allow full path names even with -d directory
#    jerrede     10/15/14 - Read Only Oracle Homes
#    akruglik    09/04/14 - Bug 19525627: change API of catconQuery to allow
#                           specification of the PDB in which to run the query
#    akruglik    09/03/14 - Bug 19525987: use upgrade_priority to order
#                           Containers
#    akruglik    07/23/14 - Project 47234: add support for -F flag which will 
#                           cause catcon to run over all Containers in a 
#                           Federation name of whose Root is passed with
#                           the flag
#    jerrede     06/13/14 - Bug 18969473.
#                           Workaround Windows Perl problem:
#                           open2: Can not call method "close" on an undefined
#                           value at /perl/lib/IPC/Open3.pm line 415. This
#                           happens when specifing a container list of 1 item.
#                           catcon.pm dies in Open2 call via catconInit,
#                           get_instance_status and exec_DB_script.
#    akruglik    06/12/14 - Bug 18960833: get rid of excessive messages which
#                           were introduced by a fix for bug 18745291
#    akruglik    05/19/14 - add support for -z flag used to supply EZConnect
#                           strings corresponding to RAC instances which should
#                           be used to run scripts
#    akruglik    05/01/14 - Bug 18672126: having unlinked a file in 
#                           sureunlink, give it some time to disappear
#    akruglik    05/12/14 - Bug 18745291: produce progress messages
#    akruglik    04/17/14 - Bug 18606911: when deciding whether PDB$SEED is 
#                           already open in correct mode, treat READ WRITE as 
#                           a special case of UPGRADE
#    akruglik    04/11/14 - Bug 18548396: set $catcon_RevertSeedPdbMode before 
#                           calling reset_seed_pdb_mode
#    akruglik    04/09/14 - Bug 18545783: change extension of catcon log file
#                           from out to lst
#    akruglik    04/02/14 - Bug 18488530: make sure pdb$seed is OPEN in READ
#                           ONLY mode if the catcon process gets killed
#    akruglik    03/26/14 - Bug 18011217: address unlink issues on Windows by
#                           embedding process id in names of various "done"
#                           files
#    dkeswani    03/14/14 - Bug 18011217: unlink issues on windows
#    akruglik    01/21/14 - Bug 17898118: rename catconInit.MigrateMode to 
#                           SeedMode and change semantics
#    talliu      01/09/13 - 14223369: add new parameter in catconInit to 
#                           indicated whether it is called by cdb_sqlexec.pl 
#    akruglik    01/16/14 - Bug 18085409: add support for running scripts
#                           against ALL PDBs and then the Root
#    akruglik    01/13/14 - Bug 18070841: modify get_pdb_names to ensure that
#                           PDB name and open_mode appear on the same line
#    dkeswani    01/13/14 - Diagnostic txn for intermittent issue in sureunlink
#                           PDB name and open_mode appear on the same line
#    akruglik    01/09/14 - Bug 18029946: add support for ignoring non-existent
#                           or closed PDBs
#    akruglik    01/07/14 - Bug 18020158: provide for a better default
#                           mechanism for internal connect string
#    akruglik    01/06/14 - Bug 17976046: get rid of Term::ReadKey workaround
#    akruglik    01/03/14 - Bug 18003416: add support for determining whether a
#                           script ended with an uncommitted transaction
#    jerrede     12/25/13 - Stripe Comma's from container name
#    akruglik    12/13/13 - Bug 17898041: use user connect string when starting
#                           SQLPlus processes
#    akruglik    12/13/13 - Bug 17898041: use "/ AS SYSDBA" as the default 
#                           connect string
#    akruglik    12/12/13 - Bug 17898118: once a process finishes running a
#                           script in a CDB, force it to switch into the Root
#    akruglik    12/09/13 - Bug 17810688: detect the case where sqlplus is not
#                           in the PATH
#    jerrede     12/05/13 - Don't override set timing values
#    akruglik    11/26/13 - modify get_connect_string to fetch password from
#                           the environment variable, if it is set
#    akruglik    11/20/13 - Bug 17637320: remove workaround added to
#                           additionalInitStmts eons ago
#    jerrede     11/18/13 - Comment out workaround additionalInitStmts
#                           Causing problems when writing to the
#                           seed database. When running post upgrade
#                           in read write mode we were unable to
#                           write to the database when calling
#                           the post upgrade procedure.
#    jerrede     11/06/13 - Move Dangling Flush Statement
#    akruglik    10/28/13 - Add support for migrate mode indicator; add
#                           subroutine to return password supplied by the user
#    akruglik    10/20/13 - Back out ReadKey-related changes
#    akruglik    10/07/13 - Bug 17550069: accept an indicator that we are being
#                           called from a GUI tool which on Windows means that
#                           the passwords and hidden parameters need not be
#                           hidden
#    jerrede     10/02/13 - Performance Improvements
#    akruglik    09/06/13 - in get_num_procs, don't impose a fixed maximum on a
#                           number of processes which may be started
#    akruglik    08/20/13 - ensure that subroutines expected to return a value
#                           do so under all cercumstances
#    jerrede     07/29/13 - Add End Process to Avoid Windows communication
#                           errors
#    akruglik    07/19/13 - add 3 new parameters to the interface of 
#                           catconExec + define catconIsCDB, catconGetConNames 
#                           and catconQuery
#    jerrede     06/18/13 - Fix shutdown checks.
#    akruglik    05/15/13 - Bug 16603368: add support for -I flag
#    akruglik    03/19/13 - do not quote the password if the user has already
#                           quoted it
#    akruglik    03/07/13 - use v$database.cdb to determine whether a DB is a
#                           CDB
#    akruglik    02/08/13 - Bug 16177906: quote user-supplied password in case
#                           it contains any special characters
#    akruglik    12/03/12 - (LRG 8526376): replace calls to
#                           DBMS_APPLICATION_INFO.SET_MODULE/ACTION with
#                           ALTER SESSION SET APPLICATION MODULE/ACTION
#    akruglik    11/15/12 - (LRG 8522365) temporarily comment out calls to
#                           DBMS_APPLICATION_INFO
#    surman      11/09/12 - 15857388: Resolve Perl typo warning
#    akruglik    11/09/12 - (LRG 7357087): PDB$SEED needs to be reopened READ
#                           WRITE unless it is already open READ WRITE or
#                           READ WRITE MIGRATE
#    akruglik    11/08/12 - use DBMS_APPLICATION_INFO to store info about
#                           processes used to run SQL scripts
#    akruglik    11/08/12 - if debugging is turned on, make STDERR hot
#    akruglik    11/08/12 - (15830396): read and ignore output in
#                           exec_DB_script if no marker was passed, to avoid
#                           hangs on Windows
#    surman      10/29/12 - 14787047: Save and restore stdout
#    mjungerm    09/10/12 - don't assume unlink will succeed - lrg 7184718
#    dkeswani    08/13/12 - Bug 14380261 : delete LOCAL variable on WINDOWS
#    akruglik    08/02/12 - (13704981): report an error if database is not open
#    sankejai    07/23/12 - 14248297: close/open PDB$SEED on all RAC instances
#    akruglik    06/26/12 - modify exec_DB_script to check whether @Output
#                           contains at least 1 element before attempting to
#                           test last character of its first element
#    akruglik    05/23/12 - rather than setting SQLTERMINATOR ON, use /
#                           instead of ; to terminate SQL statements
#    akruglik    05/18/12 - add SET SQLTERMINATOR ON after every CONNECT to
#                           ensure that SQLPLus processes do not hang if the
#                           caller sets SQLTERMINATOR to something other than
#                           ON in glogin.sql or login.sql
#    akruglik    04/18/12 - (LRG 6933132) ignore row representing a non-CDB
#                           when fetching rows from CONTAINER$
#    gravipat    03/20/12 - Rename x$pdb to x$con
#    akruglik    02/22/12 - (13745315): chop @Output in exec_DB_script to get 
#                           rid of trailing \r which get added on Windows
#    akruglik    12/09/11 - (13404337): in additionalInitStmts, set SQLPLus
#                           vars to their default values
#    akruglik    10/31/11 - modify additionalInitStmts to set more of SQLPlus
#                           system vars to prevent values set in a script run
#                           against one Container from affecting output of
#                           another script or a script run against another
#                           Container
#    prateeks    10/21/11 - MPMT changes : connect string
#    akruglik    10/14/11 - Bug 13072385: if PDB$SEED was reopened READ WRITE
#                           in concatExec, it will stay that way until
#                           catconWrapUp
#    akruglik    10/11/11 - Allow user to optionally specify internal connect
#                           string
#    akruglik    10/03/11 - address 'Use of uninitialized value in
#                           concatenation' error
#    akruglik    09/20/11 - Add support for specifying multiple containers in
#                           which to run - or not run - scripts
#    akruglik    09/20/11 - make --p and --P the default tags for regular and
#                           secret arguments
#    akruglik    09/20/11 - make default number of processes a function of
#                           cpu_count
#    akruglik    08/24/11 - exec_DB_script was hanging on Windows because Perl
#                           does not handle CHLD signal on Windows
#    pyam        08/08/11 - don't run scripts AS SYSDBA unless running as sys
#    akruglik    08/03/11 - unset TWO_TASK to ensure that connect without
#                           specifyin a service results in a connection to the
#                           root
#    akruglik    07/01/11 - encapsulate common code into subroutines
#    akruglik    06/30/11 - temporarily suspend use of Term::ReadKey
#    akruglik    06/10/11 - rename CatCon.pm to catcon.pm because oratst get
#                           macro is case-insensitive
#    akruglik    06/10/11 - Add support for spooling output of individual
#                           scripts into separate files
#    akruglik    05/26/11 - Creation
#

package catcon;

use 5.006;
use strict;
use warnings;
use English;
use IO::Handle;       # to flush buffers
use Term::ReadKey;    # to not echo password
use IPC::Open2;       # to perform 2-way communication with SQL*Plus
use File::Spec ();    # for fix of bug 17810688
use File::Basename;
use Cwd;
use Fcntl;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration       use catcon ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
        
) ] );

our @EXPORT_OK = qw ( catconInit catconInit2 catconExec 
                      catconRunSqlInEveryProcess 
                      catconShutdown catconBounceProcesses catconWrapUp 
                      catconIsCDB catconGetConNames catconQuery catconUpgForce 
                      catconUpgEndSessions catconUpgStartSessions 
                      catconUserPass catconUpgSetPdbOpen 
                      catconSkipRevertingPdbModes 
                      catconGetUsrPasswdEnvTag catconGetIntPasswdEnvTag 
                      catconXact catconForce catconReverse 
                      catconRevertPdbModes catconEZConnect 
                      catconFedRoot catconIgnoreErr catconVerbose 
                      catconSqlplus catconDisableLockdown 
                      catconRecoverFromChildDeath catconPdbMode catconAllInst
                      catconUpgrade TimeStamp set_catcon_InvokeFrom 
                      catconImportRmanVariables get_connect_string 
                      sureunlink exec_DB_script print_exec_DB_script_output 
                      get_instance_status_and_name get_CDB_indicator 
                      get_con_id find_in_path send_sig_to_procs get_num_procs 
                      build_connect_string valid_src_dir valid_log_dir 
                      validate_script_path get_log_file_base_path 
                      get_fed_root_info get_fed_pdb_names catconEZconnToPdb
                      catconNoOracleScript catconGroupByUpgradeLevel 
                      catconPdbType catconUsingMultipleInstances
                      catconMultipleInstancesFeasible );

our @EXPORT = qw(
        
);

# this subroutine will open this file and attempt to obtain its version from 
# the $Header line
sub get_catcon_version {
  # absolute path of this catcon.pm
  my $file = File::Spec->rel2abs(__FILE__);

  # open catcon.pm to read the $Header line
  my $hndl;
  die "could not open ($!) $file for reading\n\tadditional info: $^E" 
    if (!open($hndl, "<", $file));

  # extract $Header line
  my @hdr = grep {/# \$Header/} <$hndl>;

  # and close catcon.pm - we no longer need it
  close($hndl);

  # obtain file version from the $Header line
  my $ver;

  if ($#hdr < 0) {
    $ver = 'Unknown (no \$Header lines)';
  } else {
    # In some cases a file may end up with multiple $Header lines - we will 
    # use the first one

    # get rid of leading/trailing blanks and new-line char
    chomp $hdr[0];

    my @hdrTokens = split(/ /, $hdr[0]);

    # $Header line is expected to look like this:
    #   # $Header <file name> <file version> <other stuff>
    # We will not attempt to ascertain that the line is "well formed" beyond 
    # making sure that it has at least 4 tokens and extracting the 4th 
    # token, presumed to be the file version
    if ($#hdrTokens < 3) {
      $ver = "Unknown (badly formatted \$Header line ($hdr[0]))";
    } else {
      $ver = $hdrTokens[3];
    }
  }
  
  return $ver;
}

# obtain version from $Header line of catcon.pm
our $VERSION = get_catcon_version();


# forward declarations of subroutines used to log messages since these 
# subroutines get used before they get declared

# NOTE: not to be used directly - only through log_msg_{debug|verbose|etc}
sub log_msg_($$$);

sub log_msg_debug($);
sub log_msg_verbose($);
sub log_msg_info($);
sub log_msg_console($);
sub log_msg_no_log4j($);
sub log_msg_banner($);
sub log_msg_warn($);
sub log_msg_error($);
sub log_msg_fatal($);

# Preloaded methods go here.

# forward declarations
sub catconBounceDeadProcess($);
sub get_rac_instance_state($$$);
sub alter_rac_instance_state($$$);

# global constant definition

# indicator of whether we are invoking from catcon or rman 
# that will be used across the script;
# 0 - the script is called from RMAN 
# 1 - the script is called from CATCON 
use constant CATCON_INVOKEFROM_RMAN   => 0;
use constant CATCON_INVOKEFROM_CATCON => 1;

# trim whitespaces from both ends
sub trim {
  my $s = shift;
  $s =~ s/^\s+|\s+$//g;
  return $s;
}

#
# get_connect_string
#
# Description:
#   If user supplied a user[/password] [as <admin-role, e.g. sysdba>] string
#     If user-supplied string contained a password, 
#       get user name and password from that string
#     else if constructing a user connect string and the appropriate 
#       environment variable was set, set user name to the user-supplied 
#       string and get the password from that variable
#     else 
#       set user name to the user-supplied string and prompt user for a 
#       password
#     end if
#     construct the connect string as a concatenation of 
#     - caller-supplied user,
#     - '/', 
#     - password, 
#     - "@%s" (placeholder which can be relpalced with an EZConnect string 
#         to generate a connect string for connecting to a specific instance) 
#         if $Instances is true, and
#     - AS SYSDBA if user name was SYS or 
#     - AS <admin-role, e.g. SYSDBA> if user-supplied connect string 
#       included "as <admin-role>".
#   Otherwise,
#     set connect string to '/ AS SYSDBA' for sqlplus, '/' from rman
#
# Parameters:
#   - user name, optionally with password and AS <admin-role>; may be undefined
#   - a flag indicating whether to NOT echo a password if a user has to enter 
#     it
#   - password value obtained from the appropriate environment variable, if any
#   - an indicator of whether this string may need to accommodate 
#     specification of EZConnect strings for connecting to various instances
#
# Returns:
#   two sets of Connect strings as described above, for RMAN and SQL*Plus,
#   where RMAN connect string is used in rman.pm, 
#   the same string with redacted password, and the password.
#   In catcon, rman connect strings are simply dropped.
#
sub get_connect_string ($$$$) {
  my ($user, $hidePasswd, $envPasswd, $Instances) = @_;

  my $password;

  my $sqlconnect;               # assembled connect string for sqlplus
  my $rmanconnect;              # assembled connect string for rman
  my $sqlconnectDiag;           # assembled connect string for sqlplus
                                # (password hidden for diagnostic output)
  my $rmanconnectDiag;          # assembled connect string for rman
                                # (password hidden for diagnostic output)
  my $asAdmin;                  # connect as SYSDBA|SYSOPER|SYSKM|etc

  if ($user) {
    # Bug 25507396: if AS SYSDBA was specified, remember it and strip 
    # AS SYSDBA from $user
    # 
    # Code has been modified to handle all admin roles
    if ($user =~ /as (sys.*)/i && $user !~ /\/as $1/i) {
      $asAdmin = $1;
      $user =~ s/as $1//i;
    }

    # user name specified, possibly followed by /password
    #
    # if the password was not supplied, try to get it from the environment 
    # variable, or, failing that, by prompting the user

    if ($user =~ /(.*)\/(.*)/) {
      # user/password
      $user = trim($1);
      $password = trim($2);
    } elsif ($envPasswd) {
      $password = $envPasswd;
      $password =~ tr/"//d;  # strip double quotes
    } else {
      # prompt for password
      print "Enter Password: ";

      # do not enter noecho mode if told to not hide password
      if ($hidePasswd) {
        ReadMode 'noecho';
      }

      $password = ReadLine 0;
      chomp $password;

      # do not restore ReadMode if told to not hide password
      if ($hidePasswd) {
        ReadMode 'normal';
      }

      print "\n";
    }

    # if specified user is SYS, we will need to add AS SYSDBA unless the 
    # caller has supplied <admin-role> (e.g. sys as SYSKM)
    if (uc($user) eq "SYS" && !$asAdmin) {
      $asAdmin = "sysdba";
    }
   
    # quote the password unless the user has done it for us or unless he hit 
    # return without entering any characters.  We assume that 
    # passwords cannot contain double quotes and trust the user to not play 
    # games with us and only half-quote the password
    if (length($password) > 0 && substr($password,1,1) ne '"') {
      $password = '"'.$password.'"'
    }
    
    if ($Instances) {
      # if caller supplied "/ as <admin-role>", both user and password will be 
      # empty, and we need to report an error since OS authentication cannot 
      # be used if the user wants to run scripts using specified instances
      if (!$user) {
        $sqlconnectDiag = $sqlconnect = $rmanconnectDiag = $rmanconnect = 
          undef;

        log_msg_error("OS authentication cannot be used with specified ".
                      "instances");
      } else {
        # add a placeholder for an EZConnect string so we can use it 
        # to connect to a specific instance
        $sqlconnect = $rmanconnect = $user."/"."$password"."@%s";

        $sqlconnectDiag = $rmanconnectDiag = $user."/"."########"."@%s";
      }
    } else {
      $sqlconnect = $rmanconnect = $user."/"."$password";

      # if caller supplied "/ as <admin-role>", both user and password will be 
      # empty and connect string used for diagnostic purposes should be the 
      # same as the actual connect string
      if (!$user) {
        $sqlconnectDiag = $rmanconnectDiag = $sqlconnect;
      } else {
        $sqlconnectDiag = $rmanconnectDiag = $user."/"."########";
      }
    }
  } else {
    # default to OS authentication

    # OS authentication cannot be used if the user wants to run scripts using
    # specified instances
    if ($Instances) {
      $sqlconnectDiag = $sqlconnect = $rmanconnectDiag = $rmanconnect = undef;

      log_msg_error("OS authentication cannot be used with specified ".
                    "instances");
    } else {
      $sqlconnectDiag = $sqlconnect = $rmanconnectDiag = $rmanconnect = "/";
    }

    $password = undef;
    $asAdmin = "sysdba";
  } 

  # $connect may be undefined if the caller has not supplied user[/password] 
  # while the user specified instances on which to run scripts
  if ($asAdmin && $sqlconnect) {
    $sqlconnect = $sqlconnect . " AS $asAdmin";
    $sqlconnectDiag = $sqlconnectDiag . " AS $asAdmin";
  }

  return ($sqlconnect, $sqlconnectDiag, $rmanconnect, $rmanconnectDiag,
          $password);
}

# a file produced by spooling output from SQL*Plus commands may not have 
# been created even though a script that spooled its output into it has 
# completed, so if we need to open such file, we may need to wait a tad 
# until it exists and is non-empty
sub openSpoolFile ($) {
  my ($spoolFile) = @_;

  my $iters = 0;
  my $MAX_ITERS = 1000;
  my $fh;
  my $exists;
  my $fsize = 0;

  while ((!($exists = -e $spoolFile) || !($fsize = -s $spoolFile)) && 
         $iters < $MAX_ITERS) { 
    $iters++;
    if (($iters % 1) == 100) {
      if (!$exists) {
        log_msg_debug("file ($spoolFile) was not found after ".
                      $iters." attempts\n\twill try again");
      } else {
        log_msg_debug("file ($spoolFile) was found but it was ".
                      "empty ($fsize bytes) after $iters attempts\n".
                      "\twill try again");
      }
    }
 
    select (undef, undef, undef, 0.01);
  }

  if ($iters < $MAX_ITERS) {
    # file exists and is not empty; try to open it and return the file handle
    if (open ($fh, "<", "$spoolFile")) {
      return $fh;
    } else {
      log_msg_error("file ($spoolFile) exists and has non-zero (".
                    $fsize." bytes) size, but it could not be opened");

      return undef;
    }
  } else {
    if (!$exists) {
      log_msg_error("file ($spoolFile) was not found after ".
                    $iters." attempts\n\tGiving up");
    } else {
      log_msg_error("file ($spoolFile) was found but it was ".
                    "empty ($fsize bytes) after $iters attempts\n\tgiving up");
    }

    return undef;
  }
}

# A wrapper over unlink to retry if it fails, as can happen on Windows
# apparently if unlink is attempted on a .done file while the script is
# is still writing to it.  Silent failure to unlink a .done file can
# cause incorrect sequencing leading to problems like lrg 7184718
sub sureunlink ($) {
  my ($DoneFile) = @_;

  my $iters = 0;
  my $MAX_ITERS = 120;

  while (!unlink($DoneFile) && $iters < $MAX_ITERS) { 
    # Bug 23614674: if unlink failed because the file no longer exists, there 
    # is nothing left to do
    if (! -e $DoneFile) {
      log_msg_debug("$DoneFile does not exist");

      return;
    }

    $iters++;

    log_msg_debug("unlink($DoneFile) failed after $iters attempts due ".
                  "to $!");

    sleep(1);
  }

  # Bug 18672126: it looks like sometimes on Windows unlink returns 1 
  # indicating that the file has been deleted, but a subsequent -e test seems 
  # to indicate that it still exists, causing us to die.  
  # 
  # One alternative would be to trust unlink and not perform the -e test at 
  # all, but I am concerned that if things really get out of whack, we may 
  # mistakenly conclude that the next script sent to a given SQL*Plus process 
  # has completed simply because the "done" file created to indicate 
  # completion of previous script took too long to go away
  #
  # To alleviate this conern, I will, instead, give the file a bit of time to 
  # really go away by running a loop while -e returns TRUE for the same 
  # number of iterations as we used above to allow unlink to succeed

  if ($iters < $MAX_ITERS) {
    log_msg_debug("unlink($DoneFile) succeeded after ".($iters + 1).
                  " attempt(s)");
    log_msg_debug("verify that the file really no longer exists");

    $iters = 0;
    while ((-e $DoneFile) && $iters < $MAX_ITERS) {
      $iters++;
      log_msg_debug("unlinked file ($DoneFile) appears to still exist ".
                    "after $iters checks");
      sleep(1);
    }

    if ($iters < $MAX_ITERS) {
      log_msg_debug("confirmed that $DoneFile no longer exists after ".
                    ($iters + 1)." attempts");
    } else {
      log_msg_debug("$DoneFile refused to go away, despite unlink ".
                    "apparently succeeding");
    }
  }  else {
    log_msg_error("could not unlink $DoneFile - $!");
  }

  die "could not unlink $DoneFile - $!" if (-e $DoneFile);
}

#
# exec_DB_script
#
# Description:
#   Connect to a database using connect string supplied by the caller, run 
#   statement(s) supplied by the caller, and if caller indicated interest in 
#   some of the output produced by the statements, return a list, possibly 
#   empty, consisting of results returned by that query which contain 
#   specified marker
#
# Parameters:
#   - a reference to a list of statements to execute
#   - a string (marker) which will mark values of interest to the caller; 
#     if no value is supplied, an uninitialized list will be returned
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   - If marker was supplied, a list consisting of values returned by the 
#     query, stripped of the marker; uninitialized otherwise
#   - List of lines of output produced by running the specified list of 
#     statements; this list is expected to be used by the caller if the 
#     list of values in the first output argument has something unexpected 
#     about it (like consisting of fewer or more rows than expected)
#
sub exec_DB_script (\@$$$$) {
  my ($statements, $marker, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  # file whose existence will indicate that all statements in caller's 
  # script have executed
  my $DoneFile = $DoneFilePathBase."_exec_DB_script.done";

  my @Output;
  my @Spool;

  local (*Reader, *Writer);

  # if the "done" file exists, delete it
  if (-e $DoneFile) {
    sureunlink($DoneFile);

    log_msg_debug("deleted $DoneFile before running a script");
  } else {
    log_msg_debug("$DoneFile did not need to be deleted before ".
                  "running a script");
  }

  my $pid = open2(\*Reader, \*Writer, "$sqlplus /nolog");

  log_msg_debug("opened Reader and Writer");

  # Bug 25368019: default settings to prevent unexpected formatting of output
  my @dfltSettings = (
    "set newpage 1\n",
    "set pagesize 14\n",
  );

  # execute default setting statement followed by statements supplied by the 
  # caller
  foreach (@dfltSettings, @$statements) {
    my $stmt = $_;

    # remember if $stmt is a connect statement that needs to be masked 
    # (i.e. because it contains a password) when producing a diagnostic message
    my $maskConnect =
      (uc($stmt) =~ /^CONN/ && uc($stmt) !~ 'CONNECT / AS SYS');

    # add a PROMPT statement to make it easier to read output produced by 
    # SQL*Plus
    my $printableStmt;
    
    if ($maskConnect) {
      $printableStmt = "connect";
    } else {
      $printableStmt = $stmt;
      
      # mask the marker if the statement contains it so as to avoid 
      # confusing the code below that assumes that a line with the marker 
      # contains data that needs to be returned to the caller
      if ((defined $marker) && $printableStmt =~ /$marker/) {
        $printableStmt =~ s/$marker/#marker#/;
      }

      # mask \n
      $printableStmt =~ s/\n/#LF#/g; 
    }

    my $prompt = qq{prompt $printableStmt\n};
    print Writer $prompt;

    # LRG 20865842: if executing a connect statement containing a password, 
    #   the password may contain &, so the connect statement may need to be 
    #   surrounded with SET DEFINE OFF/ON statements to prevent SQL*Plus from 
    #   treating the password (or a portion thereof) as a substitution 
    #   variable and displaying it (sans &)  while prompting for its value
    if ($maskConnect) {
      # send the CONNECT statement itself
      print Writer @{connect_escaping_ampersands($stmt, undef, 0)};

      log_msg_debug("sent CONNECT statement");
    } else {
      # send the statement itself
      print Writer $stmt;

      chomp $stmt;
      log_msg_debug("sent $stmt");
    }
  }

  # send a statement to generate a "done" file
  print Writer qq/$DoneCmd $DoneFile\n/;

  log_msg_debug("sent $DoneCmd $DoneFile to Writer");

  # send EXIT
  print Writer qq/exit\n/;

  log_msg_debug("sent -exit- to Writer");

  close Writer;       #have to close Writer before read

  log_msg_debug("closed Writer");

  if ($marker) {
    log_msg_debug("marker = $marker - examine output");

    # have to read one line at a time
    while (<Reader>) { 
      # bug 22330680: can't assume that a line containing a marker starts 
      # with a marker, so we look for a marker anywhere in the line and 
      # then remove anything that precedes the end of the marker, i.e. if 
      # the marker is C:A:T:C:O:N and the line looks like this:
      #   x233068-SQL>        C:A:T:C:O:NOPEN	   x233068
      # we will strip off 
      #   x233068-SQL>        C:A:T:C:O:N
      chomp;
      if ($_ =~ /^.*$marker/) {
        log_msg_debug("line contains marker: $_");
        
        # remove characters up to and including the end of the marker
        s/$marker(.*)//;
        # and add it to the list
        push @Output, $1;
        # and to the Spool
        push @Spool, $1;
      } else {
        log_msg_debug("line does not match marker: $_");

        # add output line to the Spool
        push @Spool, $_;
      }
    }

    # (13745315) on Windows, values fetched from SQL*Plus contain trailing 
    # \r, but the rest of the code does not expect these \r's, so we will 
    # chop them here
    if (@Output && substr($Output[0], -1) eq "\r") {
      chop @Output;
      chop @Spool;
    }
  } else {
    log_msg_debug("marker was undefined; read and ignore output, ".
                  "if any");

    # (15830396) read anyway
    while (<Reader>) {
      # add output line to the Spool
      push @Spool, $_;
     }

    log_msg_debug("finished reading and ignoring output");
  }

  log_msg_debug("waiting for child process to exit");

  # wait until the process running SQL statements terminates
  # 
  # NOTE: Instead of waiting for CHLD signal which gets issued on Linux, 
  #       we wait for a "done" file to be generated because this should 
  #       work on Windows as well as Linux (and other Operating Systems, 
  #       one hopes)
  select (undef, undef, undef, 0.01)    until (-e $DoneFile);

  log_msg_debug("child process exited");

  sureunlink($DoneFile);

  log_msg_debug("deleted $DoneFile after running a script");

  close Reader;

  log_msg_debug("closed Reader");

  waitpid($pid, 0);   #makes your program cleaner

  log_msg_debug("waitpid returned");

  return (\@Output, \@Spool);
}

# 
# print_exec_DB_script_output
#
# Description:
#   Print script output returned to the caller of this function by 
#   exec_DB_script
#
# Parameters:
#   - name of a function that called exec_DB_script
#   - reference to a script output buffer
#   - an indicator whether this subroutine is being called because calling 
#     function detected an error during invocation of exec_DB_script
#
# Returns:
#   none
#
sub print_exec_DB_script_output ($$$) {

  my ($callerName, $Spool_ref, $err) = @_;

  if ($err) {
    log_msg_debug("$callerName: unexpected error in exec_DB_script");
  } else {
    log_msg_debug("$callerName: ");
  }

  log_msg_debug("  output produced in exec_DB_script [");
  for my $SpoolLine ( @$Spool_ref ) {
    # lines in the Spool buffer are already \n terminated, so don't add 
    # another \n here
    log_msg_debug("    $SpoolLine");
  }

  if ($err) {
    log_msg_error("  ] end of output produced in exec_DB_script");
  } else {
    log_msg_debug("  ] end of output produced in exec_DB_script");
  }
}

#
# get_instance_status
#   
# Description
#   Obtain instance status.
#
# Parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   String found in V$INSTANCE.STATUS
#
sub get_instance_status (\@$$$) {

  my ($connectString, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @GetInstStatusStatements = (
    "connect ".$connectString->[0]."\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || status from v\$instance\n/\n",
  );

  my ($InstStatus_ref, $Spool_ref) = 
    exec_DB_script(@GetInstStatusStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$InstStatus_ref || $#$InstStatus_ref != 0) {
    # instance status could not be obtained; if this was due to the 
    # fact that the instance was idle (ORA-01034 reported), return Idle as 
    # Instance Status; otherwise, report an error
    if (!@$InstStatus_ref) {
      for my $SpoolLine ( @$Spool_ref ) {
        if ($SpoolLine =~ /ORA-01034/) {
          return ("Idle");
        }
      }
    }

    print_exec_DB_script_output("get_instance_status", $Spool_ref, 1);
    undef @$InstStatus_ref;
  }

  return $$InstStatus_ref[0];
}

#
# get_instance_status_and_name
#   
# Description
#   Obtain instance status and name.
#
# Parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   Strings found in V$INSTANCE.STATUS and V$INSTANCE.INSTANCE_NAME
#
sub get_instance_status_and_name (\@$$$) {

  my ($connectString, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @GetInstStatusStatements = (
    "connect ".$connectString->[0]."\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || status||\'##\'||instance_name ".
      "from v\$instance\n/\n",
  );

  # should return exactly 1 row
  my ($out_ref, $Spool_ref) = 
    exec_DB_script(@GetInstStatusStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  my $InstStatus;
  my $InstName;

  if (!@$out_ref || $#$out_ref != 0) {
    # instance status and name could not be obtained; if this was due to the 
    # fact that the instance was idle (ORA-01034 reported), return Idle as 
    # InstStatus; otherwise, report an error
    if (!@$out_ref) {
      for my $SpoolLine ( @$Spool_ref ) {
        if ($SpoolLine =~ /ORA-01034/) {
          return ("Idle", "N/A");
        }
      }
    }
    
    print_exec_DB_script_output("get_instance_status_and_name", $Spool_ref, 1);
  } else {
    # split the row into instance status and instance name
    ($InstStatus, $InstName) = split /##/, $$out_ref[0];
  }

  return ($InstStatus, $InstName);
}

#
# get_dbms_version
#   
# Description
#   Obtain DBMS version
#
# Parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   String found in V$INSTANCE.VERSION
#
sub get_dbms_version(\@$$$) {

  my ($connectString, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @GetInstStatusStatements = (
    "connect ".$connectString->[0]."\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || version from v\$instance\n/\n",
  );

  # should return exactly 1 row
  my ($out_ref, $Spool_ref) = 
    exec_DB_script(@GetInstStatusStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$out_ref || $#$out_ref != 0) {
    # DBMS version could not be obtained
    print_exec_DB_script_output("get_dbms_version", $Spool_ref, 1);
    undef @$out_ref;
  }

  return $$out_ref[0];
}

#
# get_database_type
#   
# Description
#   Obtain database type from v$instance
#
# Parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   String found in V$INSTANCE.DATABASE_TYPE
#
sub get_database_type(\@$$$) {

  my ($connectString, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @GetInstStatusStatements = (
    "connect ".$connectString->[0]."\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || database_type from v\$instance\n/\n",
  );

  # should return exactly 1 row
  my ($out_ref, $Spool_ref) = 
    exec_DB_script(@GetInstStatusStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$out_ref || $#$out_ref != 0) {
    # database type could not be obtained
    print_exec_DB_script_output("get_database_type", $Spool_ref, 1);
    undef @$out_ref;
  }

  return $$out_ref[0];
}

#
# get_db_param
#   
# Description
#   Obtain value of a parameter from v$parameter
#
# Parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - parameter name
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   String found in V$PARAMETER.VALUE for the specified parameter
#
sub get_db_param(\@$$$$) {

  my ($connectString, $ParamName, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @GetInstStatusStatements = (
    "connect ".$connectString->[0]."\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || value from v\$parameter ".
     "where name = \'$ParamName\'\n/\n",
  );

  # should return exactly 1 row
  my ($out_ref, $Spool_ref) = 
    exec_DB_script(@GetInstStatusStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$out_ref || $#$out_ref != 0) {
    # parameter value could not be obtained
    print_exec_DB_script_output("get_db_param", $Spool_ref, 1);
    undef @$out_ref;
  }

  return $$out_ref[0];
}

#
# get_db_unique_name
#   
# Description
#   Obtain db_unique_name from v$database
#
# Parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   String found in V$DATABASE.DB_UNIQUE_NAME
#
sub get_db_unique_name(\@$$$) {

  my ($connectString, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @GetInstStatusStatements = (
    "connect ".$connectString->[0]."\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || db_unique_name from v\$database\n/\n",
  );

  # should return exactly 1 row
  my ($out_ref, $Spool_ref) = 
    exec_DB_script(@GetInstStatusStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$out_ref || $#$out_ref != 0) {
    # db_unique_name could not be obtained
    print_exec_DB_script_output("get_db_unique_name", $Spool_ref, 1);
    undef @$out_ref;
  }

  return $$out_ref[0];
}

#
# runCmd
#   
# Description
#   Run the command supplied by the caller and store its output in a file 
#   whose name was supplied by the caller
sub runCmd($) {
  my ($cmd) = @_;

  # name of the subroutine from which runCmd was called
  my $callerName = (caller(2))[3];

  log_msg_debug("executing\n\t$cmd\nsupplied by $callerName");

  my @lines = `$cmd`;

  # display output produced by running the caller-supplied command
  log_msg_debug("output produced in runCmd [");

  for my $line (@lines) {
    log_msg_debug("\t$line");
  }

  log_msg_debug("  ] end of output produced in runCmd");

  return @lines;
}

#
# get_rac_instance_state
#   
# Description
#   Obtain names of RAC instances, separating idle instances from those that 
#   are up
#
# Parameters:
#   - dbUniqueName (IN)
#       DB unique name
#   - idleInstances (OUT)
#       a reference to an array which will be populated with names of idle RAC 
#       instances; may be returned uninitialized if all RAC instances are 
#       running
#   - runningInstances (OUT) 
#       a reference to an array which will be populated with names of running 
#       RAC instances; may be returned uninitialized if all RAC instances are 
#       idle
#
# Returns
#   0 if status of one or more RAC instances was successfully obtained
#   1 otherwise
#
sub get_rac_instance_state($$$) {
  my ($dbUniqueName, $idleInstances, $runningInstances) = @_;

  # statement to obtain status of RAC instances
  my $stmt = "srvctl status database -db $dbUniqueName\n";

  # runCmd will run the command and display its output if the logging level 
  # is set to DEBUG
  my @out = runCmd($stmt);

  # "srvctl status database" should return status of at least one instance
  if ($#out < 0) {
    log_msg_error("No instance status returned by srvctl status command");
    return 1;
  }

  # Parse output produced by running the above command and save names of 
  # instances which are idle and which are running in @$idleInstances and
  # @$runningInstances, respectively.
  foreach my $line (@out) {
    if ($line =~ /Instance ([^ ]*) is ([^ ]*)[ ]*running on node (.*)$/) {
      #instance name
      my $instName = $1;
      # empty string if the instance is running, "not" otherwise 
      my $notRunning = $2;  
      # node on which the instance is or is not running
      my $nodeName = $3;
      if ($notRunning eq "") {
        log_msg_debug("RAC instance $instName is running on node $nodeName");

        # remember names of instances which are running
        push @$runningInstances, $instName;
      } elsif ($notRunning eq "not") {
        log_msg_debug("RAC instance $instName is NOT running on node ".
                      "$nodeName");

        # remember names of instances which are idle and will need to be
        # started before we commence processing and stopped before catcon 
        # wraps things up
        push @$idleInstances, $instName;
      } else {
        log_msg_error("Unexpected output\n\t$line\n".
                      "produced by srvctl status command");
        return 1;
      }
    } else {
      log_msg_error("Unexpected output\n\t$line\n".
                    "produced by srvctl status command");
      return 1;
    }
  }

  return 0; # success
}

#
# alter_rac_instance_state
#   
# Description
#   Start or stop RAC instances
#
# Parameters:
#   - dbUniqueName (IN)
#       DB unique name
#   - instances (IN)
#       a reference to an array of names of RAC instances which need to be 
#       started or stopped
#   - start (IN)
#       true if instances are to be started; false if they are to be stopped
#
# Returns
#   0 if status of one or more RAC instances was successfully obtained
#   1 otherwise
#
sub alter_rac_instance_state($$$) {
  my ($dbUniqueName, $instances, $start) = @_;

  # remember whether instances need to be started or stopped
  my $cmd = $start ? "start" : "stop";

  log_msg_debug("will $cmd the following instances:\n\t".
                join(', ', @$instances));

  # statement to start/stop instances
  my $stmt = "srvctl $cmd instance -db $dbUniqueName -i ";

  foreach my $inst (@$instances) {
    # runCmd will run the command and display its output if the logging level 
    # is set to DEBUG
    my @out = runCmd($stmt.$inst."\n");

    # "srvctl start/stop instance" should produce no output
    if ($#out >= 0) {
      log_msg_error("Unexpected output produced by\n".
                    "\tsrvctl $cmd command");
      return 1;
    } else {
      log_msg_debug("\tprocessed instance $inst");
    }
  }

  return 0; # success
}

#
# get_CDB_indicator
#   
# Description
#   Obtain an indicator of whether a DB is a CDB
#
# Parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   String found in V$DATABASE.CDB
#
sub get_CDB_indicator (\@$$$) {

  my ($connectString, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  # We used to rely on CONTAINER$ not returning any rows, but in 
  # a non-CDB from a shiphome, CONTAINER$ will have a row representing 
  # CDB$ROOT (because we ship a single Seed which is a CDB and unlink 
  # PDB$SEED if a customer wants a non-CDB; you could argue that we 
  # could have purged CDB$ROOT from CONTAINER$ the same way we purged 
  # SEED$PDB, but things are the way they are, and it is more robust 
  # to query V$DATABASE.CDB)

  my @GetIsCdbStatements = (
    "connect $connectString->[0]\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || cdb from v\$database\n/\n",
  );

  my ($IsCDB_ref, $Spool_ref) = 
    exec_DB_script(@GetIsCdbStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$IsCDB_ref || $#$IsCDB_ref != 0) {
    # CDB Indicator could not be obtained
    print_exec_DB_script_output("get_CDB_indicator", $Spool_ref, 1);
    undef @$IsCDB_ref;
  }
  
  return $$IsCDB_ref[0];
}

#
# validate_credentials
#   
# Description
#  Determine whether given credentials will allow us to connect to the database
#
# Parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   1 if user credentials allow us to connect to the database; 0 otherwise
#
sub validate_credentials (\@$$$) {

  my ($connectString, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @ConnectStmt = (
    "connect $connectString->[0]\n",
  );

  my $Spool_ref;

  (undef, $Spool_ref) = 
    exec_DB_script(@ConnectStmt, undef, $DoneCmd, $DoneFilePathBase, $sqlplus);

  # we need to examine output to see if it contained any errors. 
  # Since the "script" we are executing just does a connect, an error would 
  # indicate that credentials supplied by the caller are invalid (or the DB 
  # is down, or some other error precluding the use from connecting to the 
  # database, but the important thing is that we are unlikely to be able to 
  # connect to the database using those credentials)
  if (!$Spool_ref || !@$Spool_ref) {
    log_msg_error("exec_DB_script produced no output");
    return 0;
  }

  my @errors = grep {/ORA-[0-9]/} @$Spool_ref;

  if (@errors) {
    # we were unable to connect using caller-supplied credentials
    print_exec_DB_script_output("validate_credentials", $Spool_ref, 1);
    return 0;
  }
  
  return 1;
}

#
# get_prop
#   
# Description
#   Obtain value of a specified property from DATABASE_PROPERTIES
#
# Parameters:
#   - property name
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   Value of the specified property
#
sub get_prop ($\@$$$) {
  my ($propName, $connectString, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @GetPropStatements = (
    "connect $connectString->[0]\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || property_value from database_properties ".
      "where property_name='".$propName."'\n/\n",
  );

  my ($Prop_ref, $Spool_ref) = 
    exec_DB_script(@GetPropStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$Prop_ref || $#$Prop_ref != 0) {
    # value of the property could not be obtained, which does not constitute 
    # an error but will be treated by the caller as if the default value was 
    # specified
    print_exec_DB_script_output("get_prop", $Spool_ref, 0);
    undef @$Prop_ref;
  }
  
  return $$Prop_ref[0];
}

#
# get_CDB_open_mode
#   
# Description
#   Obtain CDB's open mode
#
# Parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   String found in V$DATABASE.OPEN_MODE
#
sub get_CDB_open_mode (\@$$$) {

  my ($connectString, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @GetCdbOpenModeStatements = (
    "connect $connectString->[0]\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || open_mode from v\$database\n/\n",
  );

  my ($openMode_ref, $Spool_ref) = 
    exec_DB_script(@GetCdbOpenModeStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$openMode_ref || $#$openMode_ref != 0) {
    # CDB open mode could not be obtained
    print_exec_DB_script_output("get_CDB_open_mode", $Spool_ref, 1);
    undef @$openMode_ref;
  }
  
  return $$openMode_ref[0];
}

#
# get_dbid
#   
# Description
#   Obtain database' DBID
#
# Parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   Database' DBID (V$DATABASE.DBID)
#
sub get_dbid (\@$$$) {

  my ($connectString, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @GetDbIdStatements = (
    "connect ".$connectString->[0]."\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || dbid from v\$database\n/\n",
  );

  my ($DBID_ref, $Spool_ref) = 
    exec_DB_script(@GetDbIdStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$DBID_ref || $#$DBID_ref != 0) {
    # instance status could not be obtained
    print_exec_DB_script_output("get_dbid", $Spool_ref, 1);
    undef @$DBID_ref;
  }

  return $$DBID_ref[0];
}

#
# get_con_id
#   
# Description
#   Obtain id of a CDB Container to which we will connect using a specified 
#   Connect string
#
# Parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   CON_ID of the container to which we are connected.
#
sub get_con_id (\@$$$) {

  my ($connectString, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @GetConIdStatements = (
    "connect ".$connectString->[0]."\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || sys_context(\'USERENV\', \'CON_ID\') as con_id from dual\n/\n",
  );

  my ($CON_ID_ref, $Spool_ref) = 
    exec_DB_script(@GetConIdStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$CON_ID_ref || $#$CON_ID_ref != 0) {
    # CON_ID could not be obtained
    print_exec_DB_script_output("get_con_id", $Spool_ref, 1);
    undef @$CON_ID_ref;
  }

  return $$CON_ID_ref[0];
}

#
# get_con_name
#   
# Description
#   Obtain name of a CDB Container to which we will connect using a specified 
#   Connect string
#
# Parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   CON_NAME of the container to which we are connected.
#
sub get_con_name (\@$$$) {

  my ($connectString, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @GetConIdStatements = (
    "connect ".$connectString->[0]."\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || sys_context(\'USERENV\', \'CON_NAME\') ".
      "as con_name from dual\n/\n",
  );

  my ($CON_NAME_ref, $Spool_ref) = 
    exec_DB_script(@GetConIdStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$CON_NAME_ref || $#$CON_NAME_ref != 0) {
    # CON_NAME could not be obtained
    print_exec_DB_script_output("get_con_name", $Spool_ref, 1);
    undef @$CON_NAME_ref;
  }

  return $$CON_NAME_ref[0];
}

#
# build_connect_string
#   
# Description
#    Build a Connect String, possibly including an EZConnect String
#
# Parameters:
#   - connect string template - a string that looks like 
#     - user/password [AS <admin-role>] or "/ AS SYSDBA" if EZConnect strings 
#       were not supplied by the caller or
#     - user/password@%s [AS <admin-role>] otherwise
#   - an EZConnect string corresponding to an instance or an empty string if 
#       the default instance is to be used
#   - an indicator of whether diagnostic output should be produced (since it 
#     may contain sensitive data)
# Returns
#   A connect string which can be used to connect to the instance with 
#   specified EZConnect string or to the default instance
#
sub build_connect_string ($$$) {
  my ($connStrTemplate, $EZConnect, $okToProduceDiagOutput) = @_;
  
  if ($okToProduceDiagOutput) {
    log_msg_debug <<build_connect_string_DEBUG;
running build_connect_string(
  connStrTemplate = $connStrTemplate, 
  EZConnect       = $EZConnect)
build_connect_string_DEBUG
  }

  if (!$EZConnect || ($EZConnect eq "")) {
    # caller has not supplied an EZConnect string. Make sure that 
    # $connStrTemplate does not contain a placeholder for one
    if (index($connStrTemplate, "@%s") != -1) {
      log_msg_error <<msg;
connect string template includes an EZConnect 
    placeholder but the caller has supplied an empty EZConnect String
msg
      return undef;
    }

    # EZConnect string was not supplied, nor was it expected, so just use 
    # the default instance
    if ($okToProduceDiagOutput) {
      log_msg_debug <<msg;
return caller-supplied string ($connStrTemplate)
    as the connect string
msg
    }

    return $connStrTemplate;
  } 
    
  # caller has supplied an EZConnect string. Make sure that $connStrTemplate 
  # contains a placeholder for one
  if (index($connStrTemplate, "@%s") == -1) {
    log_msg_error <<msg;
connect string template does not include an EZConnect 
    placeholder but the caller has supplied an EZConnect String
msg
    return undef;
  }
  
  # construct a connect string by replacing the placeholder with the 
  # supplied EZConnect string
  
  my $outStr = sprintf($connStrTemplate, $EZConnect);

  if ($okToProduceDiagOutput) {
    log_msg_debug("return ".$outStr." as the connect string");
  }

  return $outStr;
}

#
# get_num_procs_int
#   
# Description
#   Compute default number of SQL*Plus sessions to be started by picking the 
#   lesser of (2*<cpu_count parameter>) and <sessions parameter> and 
#   subtracting from it the number of active sessions currently connected to 
#   the instance
#
# Parameters:
#   - reference to an array of connect strings:
#       [0] used to connect to a DB
#       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - an indicator of whether we should determine number of processes that 
#     can be opened on all of CDB's instances
#   - reference to a hash mapping instance names to, among other things, a 
#     reference to a hash representing the number of SQL*Plus processes that 
#     will be allocated for that instance if $getProcsOnAllInstances is 
#     set (OUT)
#   - number of processes specified by the caller of get_num_procs; will be 
#     consulted ONLY IF get_num_procs told us to  determine number of 
#     processes that can be opened on all of CDB's instances (recall that in 
#     that case get_num_procs does not blindly satisfy the caller's request 
#     to open specified number of processes but instead calls this function 
#     to determine how many sqlplus processes can be started on every instance)
#   - indicator of whether we are running catcon or rman 
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns
#   number of processes which will be used to run script(s)
#
sub get_num_procs_int ($$$$$$$$) {
  my ($connectString, $DoneCmd, $DoneFilePathBase, 
      $getProcsOnAllInstances, $InstProcMap_ref, $NumProcs, 
      $catcon_InvokeFrom, $sqlplus) = @_;

  # Bug 20193612: if asked to determine how many processes can be started on 
  #   all of CDB's instances, determine how many processes can be started 
  #   on every instance and return a sum of these numbers; 
  #   otherwise, compute number of sessions that can be created on the current 
  #   instance
  if ($getProcsOnAllInstances) {
    log_msg_debug("using all available instances;");

    my $retNumProcs = 0;
    
    # if we have already determined how many processes can be started on each 
    # instance, skip trying to compute them again - just add up numbers for 
    # each instance and return the result
    if ($InstProcMap_ref && %$InstProcMap_ref) {
      log_msg_debug("using MAX_PROCS values from InstProcMap constructed ".
                    "during earlier invocation:");

      foreach my $inst (sort keys %$InstProcMap_ref) {
        foreach my $k (sort keys %{$InstProcMap_ref->{$inst}}) {
          log_msg_debug("\t$inst => ($k => $InstProcMap_ref->{$inst}->{$k})");
        }

        # we expect a MAX_PROCS entry created for every instance
        if (! exists $InstProcMap_ref->{$inst}->{MAX_PROCS}) {
          log_msg_error("InstProcMap_ref->{$inst} does not contain a ".
                        "MAX_PROCS entry");

          return undef;
        }

        # and that entry had beeter be non-negative (0 for instances on which 
        # we can spawn no processes, positive integers on instances where we 
        # can)
        if ($InstProcMap_ref->{$inst}->{MAX_PROCS} < 0) {
          log_msg_error("InstProcMap_ref->{$inst}->{MAX_PROCS} is negative");

          return undef;
        }

        $retNumProcs += $InstProcMap_ref->{$inst}->{MAX_PROCS};
      }

      return $retNumProcs;
    }
    
    log_msg_debug("invoke get_inst_procs to determine how many\n".
                  "\tprocesses can be allocated to every instance");

    my $instProcs_ref = 
      get_inst_procs($catcon_InvokeFrom, $connectString, $DoneCmd, 
                     $DoneFilePathBase, $sqlplus);

    if ((! defined $instProcs_ref) || !%$instProcs_ref || 
        (keys %$instProcs_ref < 1)) {
      if (! defined $instProcs_ref) {
        log_msg_error("undefined reference returned by get_inst_procs");
      } elsif (!%$instProcs_ref) {
        log_msg_error("hash, reference to which was returned by ".
                      "get_inst_procs was undefined");
      } else {
        log_msg_error("hash, reference to which was returned by ".
                      "get_inst_procs had no entries");
      }

      return undef;
    }

    # Hash contains at least one entry.  Traverse the hash adding up 
    # positive number of processes that can be allocated to an instance
    log_msg_debug("examine hash mapping instance names to the number of ".
                  "SQL*Plus processes that can be allocated to that ".
                  "instance:");

    foreach my $inst (sort keys %$instProcs_ref) {
      my $procs = $instProcs_ref->{$inst}->{MAX_PROCS};
      log_msg_debug("\t$inst => $procs");

      if ($procs > 0) {
        $retNumProcs += $procs;
      } else {
        log_msg_debug("\tno processes can be allocated to this instance");

        # in the unlikely case that this entry contains a negative number, 
        # zero it out
        $instProcs_ref->{$inst}->{MAX_PROCS} = 0 
          if ($instProcs_ref->{$inst}->{MAX_PROCS} < 0);
      }
    }

    # if
    #   - some processes can be started on at least one instance but
    #   - that number is less than the caller-specified number of sqlplus 
    #     processes to start
    # we will increase the number of processes on every instance on which 
    # some processes can be started until we reach the number specified by 
    # the caller
    if ($retNumProcs > 0 && $NumProcs > $retNumProcs) {
      log_msg_debug <<msg;
total number of processes determined by get_inst_procs ($retNumProcs)
    is below the number of processes specified by the caller ($NumProcs) - 
    increase number of processes allocated for instances to which some
    processes have been allocated to meet the number of processes 
    specified by the caller:
msg

      while ($NumProcs > $retNumProcs) {
        foreach my $inst (sort keys %$instProcs_ref) {
          if ($instProcs_ref->{$inst}->{MAX_PROCS}) {
            $instProcs_ref->{$inst}->{MAX_PROCS}++;
            $retNumProcs++;
            
            log_msg_debug("\tincrease number of processes for instance $inst ".
                          "to ".$instProcs_ref->{$inst}->{MAX_PROCS});
          }
        }
      }
    }

    %$InstProcMap_ref = %$instProcs_ref;

    log_msg_debug("handing the resulting hash to the caller:");

    foreach my $inst (sort keys %$InstProcMap_ref) {
      foreach my $k (sort keys %{$InstProcMap_ref->{$inst}}) {
        log_msg_debug("\t$inst => ($k => $InstProcMap_ref->{$inst}->{$k})");
      }
    }

    # NOTE: if it looks like there are no instances for which we can allocate 
    #       processes (a highly unlikely scenario), we will return 0 to the 
    #       caller and let him deal with it
    return $retNumProcs;
  } else {
    my @GetNumProcsStatements = (
      "connect ".$connectString->[0]."\n",
      "set echo off\n",
      "set heading off\n",
      "select \'C:A:T:C:O:N\' || ".
              "least(cpu_param.value*2, sess_param.value-sess.num_sessions) ".
        "from v\$parameter cpu_param, v\$parameter sess_param, ".
             "(select count(*) as num_sessions ".
                "from v\$session ".
                "where status=\'ACTIVE\') sess ".
        "where cpu_param.name=\'cpu_count\' ".
          "and sess_param.name=\'sessions\'\n/\n",  
    );

    my ($NumProcs_ref, $Spool_ref) = 
      exec_DB_script(@GetNumProcsStatements, "C:A:T:C:O:N", 
                     $DoneCmd, $DoneFilePathBase, $sqlplus);

    if (!@$NumProcs_ref || $#$NumProcs_ref != 0) {
      # number of processes could not be obtained
      if (!@$NumProcs_ref) {
        log_msg_error("array a reference to which was ".
                      "returned by exec_DB_script was not defined");
      } else {
        log_msg_error("array a reference to which was ".
                      "returned by exec_DB_script did not contain exactly 1 ".
                      "row");
      }

      print_exec_DB_script_output("get_num_procs_int", $Spool_ref, 1);
      undef @$NumProcs_ref;
    }

    return $$NumProcs_ref[0];
  }
}

#
# get_num_procs - determine number of processes which should be created
#
# parameters:
#   - number of processes, if any, supplied by the user
#   - number of concurrent script invocations, as supplied by the user 
#     (external degree of parallelism)
#   - reference to an array of connect strings:
#       [0] used to connect to a DB, 
#       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - an indicator of whether we should determine number of processes that 
#     can be opened on all of CDB's instances
#   - reference to a hash mapping instance names to, among other things, a 
#     reference to a hash representing the number of SQL*Plus processes that 
#     will be allocated for that instance if $getProcsOnAllInstances is 
#     set (OUT)
#   - an indicator of whether we are running catcon or rman 
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
sub get_num_procs ($$$$$$$$$) {
  my ($NumProcs, $ExtParaDegree, $ConnectString, $DoneCmd, 
      $DoneFilePathBase, $getProcsOnAllInstances, $InstProcMap_ref, 
      $catcon_InvokeFrom, $sqlplus) = @_;

  # minimum number of processes; if the caller has supplied a number of 
  # processes to be started, we will start at least that many processes on 
  # every instance; otherwise, at least 1 process will be starfted on every 
  # instance
  my $MinNumProcs = ($NumProcs > 0) ? $NumProcs : 1;

  my $ProcsToStart;       # will be returned to the caller

  # compute the number of processes to be started
  if (!$getProcsOnAllInstances && $NumProcs > 0) {

    # caller supplied a number of processes; 
    $ProcsToStart = $NumProcs;

    log_msg_debug("caller-supplied number of processes ".
                  "(not final) = $NumProcs");
  } else {
    # first obtain a default value for number of processes based on 
    # hardware characteristics
    $ProcsToStart = get_num_procs_int($ConnectString, $DoneCmd, 
                                      $DoneFilePathBase, 
                                      $getProcsOnAllInstances, 
                                      $InstProcMap_ref, $NumProcs, 
                                      $catcon_InvokeFrom, $sqlplus);
      
    if (!(defined $ProcsToStart)) {
      log_msg_error("unexpected error in get_num_procs_int");
      return -1;
    }
    
    log_msg_debug("computed number of processes (not final) = ".
                  "$ProcsToStart");

    # if called interactively and the caller has provided the number of 
    # concurrent script invocations on this host, compute number of 
    # processes which will be started in this invocation
    #
    # This option is not used much (if at all), and we will skip this 
    # recalculation if using all available instances

    if ($ExtParaDegree && !$getProcsOnAllInstances) {
      log_msg_debug("number of concurrent script invocations = ".
                    "$ExtParaDegree");

      $ProcsToStart = int ($ProcsToStart / $ExtParaDegree);

      log_msg_debug <<msg;
adjusted for external parallelism, number of processes (still 
    not final) for this invocation of the script = $ProcsToStart
msg
    }
  }

  # use number of processes which was either supplied by the user or 
  # computed by get_num_procs_int() unless it is too small
  #
  # if using all available instances and get_num_procs_int 
  # determined how many processes can be allocated to various instances, we 
  # will not secondguess it, unless it determined that no processes can be 
  # created on any intance, in which case we will tell the caller that a 
  # minimum number of processes can be allocated on the current instance
  if ($getProcsOnAllInstances) {
    if (!$ProcsToStart) {
      # obtain name of the current instance
      my $currInst;
      
      (undef, $currInst) = 
        get_instance_status_and_name(@$ConnectString, $DoneCmd, 
                                     $DoneFilePathBase, $sqlplus);

      if (!$currInst) {
        log_msg_error("unexpected error in get_instance_status_and_name");
        return -1;
      }
      
      log_msg_debug <<msg;
standard computation determined that no sqlplus processes can be allocated
    to any instance; will record that a minimum number of processes should be
    started and allocated to the current instance ($currInst)
msg

      # remember how many sqlplus processes can be allocated to the current 
      # instance
      my %maxProcsHash = (MAX_PROCS => $MinNumProcs);

      $InstProcMap_ref->{$currInst} = \%maxProcsHash;

      $ProcsToStart = $MinNumProcs;

      log_msg_debug("added $currInst => (MAX_PROCS => ".
                    $MinNumProcs.") entry to the hash");
    }
  } elsif ($ProcsToStart < $MinNumProcs) {
    $ProcsToStart = $MinNumProcs;
  }

  # $InstProcMap_ref will be undefined for a non-CDB case so we need to check
  # whether $InstProcMap_ref is defined before attempting to dereference it
  if ($InstProcMap_ref && %$InstProcMap_ref) {
    log_msg_debug("handing instance-to-process hash to the caller:");

    foreach my $inst (sort keys %$InstProcMap_ref) {
      foreach my $k (sort keys %{$InstProcMap_ref->{$inst}}) {
        log_msg_debug("\t$inst => ($k => $InstProcMap_ref->{$inst}->{$k})");
      }
    }
  }

  log_msg_debug("will start $ProcsToStart processes (final)");

  return $ProcsToStart;
}

#
# get_num_cdb_procs - determine number of processes which should be created 
#                     to run scripts against a CDB
#
# parameters:
#   $NumProcesses - 
#     number of processes, if any, supplied by the user
#   $AllInstReqd - 
#     an indicator of whether the user requested that catcon use all 
#     available instances of a RAC database to run scripts against specified 
#     PDBs and we had no reason to ignore that request
#   $MultInstFeasible - 
#     an indicator of whether we determined that we can, in fact, use multiple 
#     available RAC instances
#   $IntConnStr_ref - 
#     a reference to an array of internal connect strings
#       [0] used to connect to a DB, 
#       [1] can be used to produce diagnostic message
#   $IsRac - 
#     an indicator of whether we are operating on a RAC database
#   $NumRacInstances -
#     number of instances on which RAC DB is open or can be open
#   $ExtParallelDegree -
#     degree of external parallelism for catcon
#   $DoneCmd -
#     a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   $LogFilePathBase - 
#     base for names of log and other files generated by catcon
#   $InstProcMap_ref (OUT) - 
#     if connected to a RAC DB and the caller requested that SQL*Plus processes
#     be open on all available instances, this hash will map instance names 
#     to a hash containing an entry (having string MAX_PROCS for a key) 
#   $InvokeFrom - 
#     an indicator of whether we are running catcon or rman 
#   $sqlplus -
#     s"sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
sub get_num_cdb_procs ($$$$$$$$$$$$) {
  my ($NumProcesses, $AllInstReqd, $MultInstFeasible, $IntConnStr_ref, $IsRac, 
      $NumRacInstances, $ExtParallelDegree, $DoneCmd, $LogFilePathBase, 
      $InstProcMap_ref, $InvokeFrom, $sqlplus) = @_;

  log_msg_debug <<msg;
call get_num_procs to determine number of processes that will be started
msg

  # if the caller specified a number of processes to start (P) and 
  # asked us to use all available instances (I), he must have expected us 
  # to start P processes on each of I instances; if we determined 
  # that we will not be able to start processes on all instances, we will 
  # start P*I processes on the default instance
  my $ProcsToStart = $NumProcesses;

  if ($NumProcesses && $IsRac eq "TRUE" && $AllInstReqd && 
      !$MultInstFeasible) {
    $ProcsToStart *= $NumRacInstances;

    log_msg_debug <<msg;
increasing number of processes from $NumProcesses to $ProcsToStart because the 
    caller requested that we use all $NumRacInstances instances but we were 
    unable to do so
msg
  }

  # prefix of "done" file name
  my $doneFileNamePrefix = done_file_name_prefix($LogFilePathBase, $$);

  $NumProcesses = 
    get_num_procs($ProcsToStart, $ExtParallelDegree, 
                  $IntConnStr_ref, $DoneCmd, $doneFileNamePrefix, 
                  $AllInstReqd && $MultInstFeasible, $InstProcMap_ref, 
                  $InvokeFrom, $sqlplus);
  
  if ($NumProcesses == -1) {
    log_msg_error("unexpected error in get_num_procs");
    return -1;
  }

  if ($NumProcesses < 1) {
    log_msg_error("invalid number of processes ".
                  "($NumProcesses) returned by get_num_procs");
    return -1;
  } 

  if (%$InstProcMap_ref) {
    log_msg_debug("get_num_procs determined that ".
                  "$NumProcesses processes can be started on ".
                  (scalar keys %$InstProcMap_ref).
                  " available instances");
  } else {
    log_msg_debug("get_num_procs determined that ".
                  "$NumProcesses processes can be started on this ".
                  "instance");
  }

  return $NumProcesses;
} 

#
# gen_inst_conn_strings - construct connect strings for instances on which 
#                         a DB is running
#
# parameters:
#   - reference to an array of connect strings:
#       [0] used to connect to a DB, 
#       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - reference to a hash mapping instance names to connect strings (OUT)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
sub gen_inst_conn_strings ($$$$$) {
  my ($ConnectString, $DoneCmd, $DoneFilePathBase, $InstConnStrMap_ref,
      $sqlplus) = @_;

  # It looks like on Windows having exec_DB_script exhibit (by using PROMPT 
  # statement) the query which is used to obtain instance connection strings 
  # followed by actually sending the query to the SQL*Plus process via a pipe 
  # overflows the pipe and causes catcon to hang.  setvbuf(), which allows 
  # one to increase thepipe buffer size is not available on all platforms 
  # where we expect catcon to run, so I will instead create a temporary file 
  # into which I will write the query and then invoke that file from 
  # @GetInstConnStrStmts

  my $queryFile = $DoneFilePathBase."_gen_inst_conn_strings_query.sql";
  my $queryHndl;
  
  if (!open($queryHndl, ">", $queryFile)) {
    log_msg_error("query file ($queryFile) could not be open");
    return undef;
  }

  my $query = 
    "select \'C:A:T:C:O:N\' || ".
             "instance.instance_name || \'@\' || ".
             "\'(DESCRIPTION=\' || ".
             "regexp_substr(local_listener.value, ".
               "\'\\(ADDRESS=(\\([^()]+\\))+\\)\', 1, 1, \'i\') || ".
             "\'(CONNECT_DATA=(SERVICE_NAME=\' || ".
             "regexp_substr(service_name.value, \'[^,]+\', 1, 1) || ".
             "\')))\' ".
        "from gv\$instance instance, gv\$listener_network local_listener, ".
             "gv\$parameter service_name ".
       "where instance.inst_id = local_listener.inst_id ".
         "and instance.inst_id = service_name.inst_id ".
         "and local_listener.type=\'LOCAL LISTENER\' ".
         "and service_name.name=\'service_names\' ".
         "and local_listener.con_id in (0,1) ".
         "and service_name.con_id in (0,1)\n/\n";

  print $queryHndl $query;

  close($queryHndl);

  my @GetInstConnStrStmts = (
      "connect $ConnectString->[0]\n",
      "set echo off\n",
      "set heading off\n",
      "set lines 1000\n",
      "@".$queryFile."\n",
    );

  my ($retValues_ref, $Spool_ref) = 
    exec_DB_script(@GetInstConnStrStmts, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  # Bug 25366291: in some cases the above query may return no rows (causing 
  #   @$retValues_ref to be undefined.)  Rather than treating it as an error, 
  #   we will force all processing to occur on the default instance
  if (!$retValues_ref) {
    log_msg_error("no data was obtained");
    print_exec_DB_script_output("gen_inst_conn_strings", $Spool_ref, 1);
    return 0;
  }

  foreach my $row (@$retValues_ref) {
    # $row should consist of an instance name and a connect string, 
    # separated by @
    my @vals = split(/@/, $row);

    if ($#vals != 1) {
      log_msg_error("data contained ".
                    "an element ($row) with unexpected format");
      print_exec_DB_script_output("gen_inst_conn_strings", $Spool_ref, 1);
      return undef;
    }

    # gv$listener_network may contain multiple rows for a given instance (one 
    # per local listener) so we want to add a representation of this row to 
    # the hash only if it does not already contain an entry for this instance
    if (! exists $InstConnStrMap_ref->{$vals[0]}) {
      $InstConnStrMap_ref->{$vals[0]} = $vals[1];

      log_msg_debug("mapping instance $vals[0] to ".
                    $InstConnStrMap_ref->{$vals[0]});
    } else {
      log_msg_debug("InstConnStrMap_ref already contains an ".
                    "entry for instance\n\t".
                    $vals[0]." described by row (".$row.")\n".
                    "keeping the existing mapping");
    }
  }

  # names of instances represented by %$InstConnStrMap_ref
  my @instances = sort keys %$InstConnStrMap_ref;

  if ($#instances == 0) {
    # database runs on a single instance so the connect string is unnecessary:
    # (SQL*Plus processes to run scripts will be started using the default 
    # instance and force_pdb_modes() will connect to the default instance 
    # before issuing ALTER PDB CLOSE statements if running against a 12.1 CDB)
    $InstConnStrMap_ref->{$instances[0]} = ' ';

    log_msg_debug("DB running on a single instance,\n".
                  "\tconnect string for instance $instances[0] will be ".
                  "discarded");
  } elsif ($#instances  == -1) {
      log_msg_debug("No instance connect strings were fetched.\n".
                    "\tAll processing will occur on the default instance");
  }

  # return number of instances on which a DB is running
  return $#instances+1;
}

#
# valid_src_dir make sure source directory exists and is readable
#
# Parameters:
#   - source directory name; may be undefined
#
# Returns
#   1 if valid; 0 otherwise
#
sub valid_src_dir ($) {
  my ($SrcDir) = @_;

  if (!$SrcDir) {
    # no source directory specified - can't complain of it being invalid
    return 1;
  }

  # if a directory for sqlplus script(s) has been specified, verify that it 
  # exists and is readable
  stat($SrcDir);

  if (! -e _ || ! -d _) {
    log_msg_error("Specified source file directory ($SrcDir) does ".
                  "not exist or is not a directory");
    return 0;
  }

  if (! -r _) {
    log_msg_error("Specified source file directory ($SrcDir) is ">
                  "unreadable");
    return 0;
  }

  return 1;
}

#
# valid_log_dir make sure log directory exists and is writable
#
# Parameters:
#   - log directory name; may be undefined
#
# Returns
#   1 if valid; 0 otherwise
#
sub valid_log_dir ($) {
  my ($LogDir) = @_;

  if (!$LogDir) {
    # no log directory specified - can't complain of it being invalid
    return 1;
  }

  stat($LogDir);

  if (! -e _ || ! -d _) {
    log_msg_error("Specified log file directory ($LogDir) does not exist or ".
                  "is not a directory");
    return 0;
  }

  if (! -w _) {
    log_msg_error("Specified log file directory ($LogDir) is ".
                  "unwritable");
    return 0;
  }

  return 1;
}

#
# validate_con_names - determine whether Container name(s) supplied
#     by the caller are valid (i.e. that the DB is Consolidated and contains a 
#     Container with specified names) and modify a list of Containers against 
#     which scripts/statements will be run as directed by the caller:  
#     - if the caller indicated that a list of Container names to be validated
#       refers to Containers against which scripts/statements should not be 
#       run, remove them from $Containers
#     - otherwise, remove names of Containers which did not appear on the 
#       list of Container names to be validated from $Containers
#
# Parameters:
#   - string containing space-delimited Container name(s)
#   - an indicator of whether the above list refers to Containers against 
#     which scripts/statements should not be run
#   - an array of Container names, if any
#   - reference to a hash of indicators of whether a given 
#     Container is open (Y/N); may be undefined if the caller specified that 
#     all relevant PDBs need to be open before being operated upon
#   - an indicator of whether non-existent and closed PDBs should be ignored
#   - an indicator of whether all PDBs should be ignored 
#
# Returns:
#   An empty list if an error was encountered or if the list of names of 
#   Containers to be excluded consisted of names of all Containers of a CDB.
#   A list of names of Containers which were either explicitly included or 
#   were NOT explicitly excluded by the caller
#
sub validate_con_names (\$$\@$$$) {
  my ($ConNameStr, $Exclude, $Containers, $IsOpen, $Force, $ForceUpg) = @_;

  log_msg_debug <<validate_con_names_DEBUG;
running validate_con_names(
  ConNameStr   = $$ConNameStr, 
  Exclude      = $Exclude, 
  Containers   = @$Containers,
  Force        = $Force,
  ForceUpg     = $ForceUpg)
validate_con_names_DEBUG

  if (!${$ConNameStr}) {
    # this subroutine should not be called unless there are Container names to 
    # validate
    log_msg_error("missing Container name string");

    return ();
  }

  my $SkippedClosedPDBs = 0; # were any PDBs skipped because they were not open

  my $LocConNameStr = $$ConNameStr;
  $LocConNameStr =~ s/^'(.*)'$/$1/;  # strip single quotes
  # extract Container names into an array
  my @ConNameArr = split(' ', $LocConNameStr);

  if (!@ConNameArr) {
    # string supplied by the caller contained no Container names
    log_msg_error("no Container names to validate");

    return ();
  }

  # string supplied by the caller contained 1 or more Container names

  if (!@$Containers) {
    # report error and quit since the database is not Consolidated
    log_msg_error("Container name(s) supplied but the DB is ".
                  "not a CDB");

    return ();
  } 
    
  log_msg_debug("Container name string consisted of the ".
                "following names {");
  foreach (@ConNameArr) {
    log_msg_debug("\t$_");
  }
  log_msg_debug("}");

  #
  # Trust that user knows what they are doing and don't validate
  # the pdbs just get out.  Needed to open when PDB's are closed
  # during upgrade.
  #
  if ($ForceUpg){
      log_msg_debug("No Validation, since ForceUpg is ".
                    "specified, just return given array");
      return @ConNameArr;
  }

  # so here's a dilemma: 
  #   we need to 
  #   (1) verify that all names in @ConNameArr are also in @$Containers AND
  #   (2) compute either 
  #       @$Containers - @ConNameArr (if $Exclude != 0) or 
  #       @$Containers <intersect> @ConNameArr (if $Exclude == 0)
  #
  #       In either case, I would like to ensure that CDB$ROOT, if it ends up 
  #       in the resulting set, remains the first element of the array (makes 
  #       it easier when we nnee to decide at what point we can parallelize 
  #       execution across all remaining PDBs) and that PDBs are ordered by 
  #       their Container ID (I am just used to processing them in that order)
  #
  #   (1) would be easiest to accomplish if I were to store contents of 
  #   @$Containers in a hash and iterate over @ConNameArr, checking against 
  #   that hash.  However, (2) requires that I traverse @$Containers and 
  #   decide whether to keep or remove an element based on whether it occurs 
  #   in @ConNameArr (which would require that I construct a hash using 
  #   contents of @ConNameArr) and the value of $Exclude
  #
  # I intend to implement the following algorithm:
  # - store contents of @ConNameArr in a hash (%ConNameHash)
  # - create a new array which will store result of (2) (@ConOut)
  # - for every element C in @$Containers
  #   - if %ConNameHash contains an entry for C
  #     - if !$Exclude
  #       - append C to @ConOut
  #   - else
  #     - if $Exclude
  #       - append C to @ConOut
  # - if, after we traverse @$Containers, %ConNameHash still contains some 
  #   entries which were not matched, report an error since it indicates that 
  #   $$ConNameStr contained some names which do not refer to existing 
  #   Container names
  # - if @ConOut is empty, report an error since there will be no Containers 
  #   in which to run scripts/statements
  # - return @ConOut which will by now contain names of all Containers in which
  #   scripts/statements will need to be run
  #

  my %ConNameHash;   # hash of elements of @ConNameArr

  foreach (@ConNameArr) {
    undef $ConNameHash{uc $_};
  }

  # array of Container names against which scripts/statements should be run
  my @ConOut = ();
  my $matched = 0;   # number of elements of @$Containers found in %ConNameHash

  for (my $CurCon = 0; $CurCon <= $#$Containers; $CurCon++) {

    my $Con = uc $$Containers[$CurCon];
    my $Open = ($IsOpen && defined $IsOpen->{$Con}) ? $IsOpen->{$Con} : "Y";
    
    # if we have matched every element of %ConNameHash, there is no reason to 
    # check whether it contains $Con
    if (($matched < @ConNameArr) && exists($ConNameHash{$Con})) {
      $matched++; # remember that one more element of @$Containers was found

      # remove $Con from %ConNameHash so that if we end up not matching some 
      # specified Container names, we can list them as a part of error message
      delete $ConNameHash{$Con};

      log_msg_debug("$$Containers[$CurCon] was matched");

      # add matched Container name to @ConOut if caller indicated that 
      # Containers whose names were specified are to be included in the set 
      # of Containers against which scripts/statements will be run
      if (!$Exclude) {
        # Bug 18029946: will run scripts against this Container only if it is 
        # open
        if ($Open eq "Y") {
          push(@ConOut, $$Containers[$CurCon]); 

          log_msg_debug("Added $$Containers[$CurCon] to ".
                        "ConOut");
        } elsif ($Force) {
          log_msg_debug("$$Containers[$CurCon] is not Open, ".
                        "but Force is specified, so skip it");

          # Bug 20782683: remember that we skipped at least one candidate PDB; 
          # if we end up with an empty list, we will mention all specified 
          # PDBs were closed 
          $SkippedClosedPDBs = 1;
        } else {
          log_msg_error("$$Containers[$CurCon] is not open");
          
          return ();
        }
      }
    } else {
      log_msg_debug("$$Containers[$CurCon] was not matched");

      # add unmatched Container name to @ConOut if caller indicated that 
      # Containers whose names were specified are to be excluded from the set 
      # of Containers against which scripts/statements will be run
      if ($Exclude) {
        # Bug 18029946: will run scripts against this Container only if it is 
        # open
        if ($Open eq "Y") {
          push(@ConOut, $$Containers[$CurCon]); 

          log_msg_debug("Added $$Containers[$CurCon] to ConOut");
        } elsif ($Force) {
          log_msg_debug("$$Containers[$CurCon] is not Open, ".
                        "but Force is specified, so skip it");

          # Bug 20782683: remember that we skipped at least one candidate PDB; 
          # if we end up with an empty list, we will mention all specified 
          # PDBs were closed 
          $SkippedClosedPDBs = 1;
        } else {
          log_msg_error("$$Containers[$CurCon] is not open");
          
          return ();
        }
      }
    }
  }

  # if any of specified Container names did not get matched, report an error
  if ($matched != @ConNameArr) {
    # Bug 18029946: print the list of unmatched Container names if were not 
    # told to ignore unmatched Container names or if debug flag is set
    my $msg = "some specified Container names do not ".
              "refer to existing Containers:";
    if (!$Force) {
      log_msg_error($msg);
    } else {
      log_msg_debug($msg);
    }
    for (sort keys %ConNameHash) {
      if (!$Force) {
        log_msg_error("\t$_"); 
      } else {
        log_msg_debug("\t$_"); 
      }
    }

    if ($Force) {
      log_msg_debug("unmatched Container names ignored ".
                    "because Force was specified");
    }

    # Bug 18029946: unless told to ignore unmatched Container names, return 
    # an empty list which will cause the caller to report an error
    if (!$Force) {
      return ();
    }
  }

  # if @ConOut is empty (which could happen if we were asked to exclude every 
  # Container or if all existing PDBs which matched caller's criteria were 
  # closed)
  if (!@ConOut) {
    if ($SkippedClosedPDBs == 1) {
      log_msg_error("all existing PDBs matching caller's ".
                    "criteria were closed");
    } else {
      log_msg_error("resulting Container list is empty");
    }

    return ();
  }

  log_msg_debug("resulting Container set consists of the ".
                "following Containers {");
  foreach (@ConOut) {
    log_msg_debug("\t$_");
  }
  log_msg_debug("}");

  return @ConOut;
}

#
# split_root_and_pdbs
#
# This subroutine will split an array of Container names a reference to which 
# was passed by the caller into Root (if any) variable and PDBs (if any) array 
# and will return them to the caller
#
# Parameters:
#   - an array of Container names (note: this subroutine assumes that the 
#     caller has verified that these names actually refer to Containers - its 
#     job is to spluit Root from everything else)
#   - name of the Root Container (we all know it is CDB$ROOT, but in case it 
#     ever changes, or we decide to use this array to separate one Container 
#     from the rest, we will ask the caller to provide us with the name)
#
# Returns:
#   A variable which will be set to $$rootName if a @$containers contained 
#   $$rootName and a reference to an array of names (if any) found in 
#   @$containers which did not match $$rootName
#
sub split_root_and_pdbs(\@\$) {
  my ($containers, $rootName) = @_;

  my $root;
  my @pdbs; 

  for (my $curCon = 0; $curCon <= $#$containers; $curCon++) {
    if ($$containers[$curCon] ne $$rootName) {
      push @pdbs, $$containers[$curCon];
    } else {
      $root = $$rootName;
    }
  }

  return ($root, \@pdbs);
}

#
# get_con_info - query V$CONTAINERS to get info about all Containers
#
# parameters:
#   $myConnect (IN) - 
#     reference to an array of connect strings:
#       [0] used to connect to a DB, 
#       [1] can be used to produce diagnostic message
#   $DoneCmd (IN) - 
#     a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   $DoneFilePathBase (IN) - 
#     base for a name of a "done" file (see above)
#   $ConNames (OUT) - 
#     reference to an array of Container names; may be undef if the caller is 
#     not interested in Container names (e.g. because he has already obtained 
#     them)
#   $AppRootInfo (OUT) -
#     reference to a hash with keys consisting of names of App Roots; may be 
#     undef if the caller is not interested in this information (e.g. because 
#     he has already obtained it)
#   $AppRootCloneInfo (OUT) -
#     reference to a hash mapping names of App Root Clones to names of App 
#     Roots; may be undef if the caller is not interested in this 
#     information (e.g. because he has already obtained it)
#   $AppPdbInfo (OUT) -
#     reference to a hash mapping names of App PDBs to names of App 
#     Roots; may be undef if the caller is not interested in this 
#     information (e.g. because he has already obtained it)
#   $IsOpen (OUT) - 
#     reference to a hash of indicators of whether a given Container is open
#   $userScript (IN) - 
#     indicator of whether we will be running user scripts (meaning that
#     CDB$ROOT and PDB$SEED should be skipped, as will be App Root clones)
#   $ezConnToPdb (IN) - 
#     name of a PDB for which a caller specified an EZConnect string to 
#     ensure that scripts are run ONLY in that PDB
#   $sqlplus (IN) - 
#     "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
sub get_con_info (\@$$$$$$$$$$) {
  my ($myConnect, $DoneCmd, $DoneFilePathBase, $ConNames, $AppRootInfo, 
      $AppRootCloneInfo, $AppPdbInfo, $IsOpen, $userScript, $ezConnToPdb, 
      $sqlplus) = @_;

  # con_id for the first Container whose name and open_mode needs to be fetched
  my $firstConId = $userScript ? 3 : 1;

  # NOTE: it is important that we do not fetch data from dictionary views 
  #       (e.g. DBA_PDBS) because views may yet to be created if this 
  #       procedure is used when running catalog.sql
  # NOTE: since a non-CDB may also have a row in CONTAINER$ with con_id#==0,
  #       we must avoid fetching a CONTAINER$ row with con_id==0 when looking 
  #       for Container names 
  #
  # Bug 18070841: "SET LINES" was added to make sure that both the PDB name 
  #               and the open_mode are on the same line.  500 is way bigger 
  #               than what is really needed, but it does not hurt anything.
  #
  # Bug 20307059: append mode to C:A:T:C:O:N<container-name> to ensure that the
  #               two do not get split across multiple lines

  my @GetConInfoStmts = (
    "connect ".$myConnect->[0]."\n",
    "set echo off\n",
    "set heading off\n",
    "set lines 9999\n",
  );

  my $Spool_ref;

  # we would like to use CONTAINER$.UPGRADE_PRIORITY to order Containers 
  # whose names and open modes get fetched from V$CONTAINERS, but if we 
  # are upgrading to 12.2, that column nmay not have been created yet, in 
  # which case we have little choice but to order Containers by their CON_ID.
  # In order to decide which query to use, we need to determine if 
  # CONTAINER$.UPGRADE_PRIORITY exists
  #
  # Bug 25507396: if ezConnToPdb is defined, our query will return a single 
  #   PDB, so we don't really need to order names of Containers
  if (!$ezConnToPdb) {
    my @UpgPrioColExistsStmts = (
      "connect ".$myConnect->[0]."\n",
      "set echo off\n",
      "set heading off\n",
      "select \'C:A:T:C:O:N\' || count(*) from sys.obj\$ o, sys.col\$ c ".
      "  where o.name = 'CONTAINER\$' and o.owner#=0 and o.type#=2 ".
      "    and o.obj# = c.obj# and c.name='UPGRADE_PRIORITY'\n/\n",
    );

    my $upgPrioColCnt_ref;

    ($upgPrioColCnt_ref, $Spool_ref) = 
      exec_DB_script(@UpgPrioColExistsStmts, "C:A:T:C:O:N", 
                     $DoneCmd, $DoneFilePathBase, $sqlplus);

    if (!@$upgPrioColCnt_ref || $#$upgPrioColCnt_ref != 0) {
      # count could not be obtained
      print_exec_DB_script_output("get_con_info(1)", $Spool_ref, 1);
    
      return 1;
    }

    # depending on the result returned by the above query, add an appropriate 
    # query to @GetConInfoStmts
    # The queries are identical except for the ORDER-BY clause
    #
    # NOTE: exclude App Root Clones if running user scripts
    #
    # Bug 27679664: skip PDBs not marked as NEW or NORMAL
    my $QueryWithoutOrderByClause = 
      "select \'C:A:T:C:O:N\' || v.name || ".
      "       decode(v.open_mode, 'MOUNTED', ' N', ' Y') ".
      "  from v\$containers v, sys.container\$ c ".
      "  where v.con_id = c.con_id# and v.con_id >= ".$firstConId.
      "    and ($userScript = 0 or v.application_root_clone = 'NO') ".
      "    and c.status in (1, 2) ";
    
    if ($$upgPrioColCnt_ref[0] eq "1") {
      my $OrderByUpgPrioQuery = 
        $QueryWithoutOrderByClause.
        "  order by c.upgrade_priority, v.con_id\n/\n";

      push @GetConInfoStmts, $OrderByUpgPrioQuery;

      log_msg_debug("CONTAINER\$.UPGRADE_PRIORITY exists - use it and ".
                    "CON_ID to order Container names");
    } else {
      my $OrderByConIdQuery = 
        $QueryWithoutOrderByClause.
        "  order by v.con_id\n/\n";

      push @GetConInfoStmts, $OrderByConIdQuery;

      log_msg_debug("CONTAINER\$.UPGRADE_PRIORITY does NOT exist - ".
                    "use CON_ID to order Container names");
    }
  } else {
    # Bug 25507396: if ezConnToPdb is set, we expect to be running this query 
    #  in a user PDB, so if a user specified CDB$ROOT or PDB$SEED, 
    #  we want to fetch 0 rows and report an error

    my $EZconnToPdbQuery = 
      "select \'C:A:T:C:O:N\' || v.name || ".
      "       decode(v.open_mode, 'MOUNTED', ' N', ' Y') ".
      "  from v\$containers v ".
      "  where v.name not in ('CDB\$ROOT', 'PDB\$SEED')".
      "    and v.name = '".uc($ezConnToPdb)."'\n/\n";

    push @GetConInfoStmts, $EZconnToPdbQuery;

    log_msg_debug <<msg;
Caller supplied ezConnToPdb ($ezConnToPdb), so only the
    description of that PDB should be fetched
msg
  }

  # each row consists of a Container name and Y/N indicating whether it is open
  my $rows_ref;

  ($rows_ref, $Spool_ref) = 
    exec_DB_script(@GetConInfoStmts, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$rows_ref || $#$rows_ref < 0) {
    # Container info could not be obtained
    print_exec_DB_script_output("get_con_info(2)", $Spool_ref, 1);
    
    return 1;
  }

  for my $row ( @$rows_ref ) {
    # split a row into a Container name and an indicator of whether it is open
    my ($name, $open) = split /\s+/, $row;
    push @$ConNames, $name if ($ConNames);
    $IsOpen->{$name} = $open;
  }

  # if 
  #   - we may be asked to process App Root Clones (i.e. if we are not 
  #     processing user scripts) and the caller has 
  #     requested that we construct a hash mapping names of App Root Clones 
  #     to names of their App Roots or
  #   - the caller requested that we construct a hash mapping App PDB names 
  #     to their App Roots or
  #   - the caller has requested that we construct a hash with keys 
  #     consisting of names of App Roots, 
  # attempt to construct these hashes
  
  # if we do not need to provide caller with info about App Root Clones, make 
  # sure that $AppRootCloneInfo is undefined
  if ($userScript && $AppRootCloneInfo) {
    undef $AppRootCloneInfo;
  }

  if ($AppRootInfo || $AppRootCloneInfo || $AppPdbInfo) {
    my @GetAppRootInfoStmts = (
      "connect ".$myConnect->[0]."\n",
      "set echo off\n",
      "set heading off\n",
      "set lines 9999\n",
      "select 'C:A:T:C:O:N' || r.name || ' ' || p.name  || ' ' ".
                           "|| p.application_root_clone ".
      "  from v\$containers p right join v\$containers r ".
      "    on p.application_root_con_id = r.con_id ".
      " where r.application_root = 'YES' ".
      "   and r.application_root_clone = 'NO'\n/\n",
    );

    ($rows_ref, $Spool_ref) = 
      exec_DB_script(@GetAppRootInfoStmts, "C:A:T:C:O:N", 
                     $DoneCmd, $DoneFilePathBase, $sqlplus);

    # it's OK for exec_DB_script return no rows - simply means that the CDB 
    # contains no App Containers

    for my $row ( @$rows_ref ) {
      # each row will consist of at least App Root name which may be followed 
      # by an App PDB name and an indicator of whether the App PDB is an App 
      # Root Clone
      my ($AppRoot, $AppPdb, $IsAppRootClone) = split /\s+/, $row;
      
      if ($AppRootInfo && (! exists $AppRootInfo->{$AppRoot})) {
        $AppRootInfo->{$AppRoot} = 1;
      }

      if ($AppPdb) {
        # $row contained, in addition to the name of an App Root, a name of 
        # an App PDB and an indicator of whether it is an App Root Clone
        if ($IsAppRootClone eq 'YES') {
          if ($AppRootCloneInfo) {
            $AppRootCloneInfo->{$AppPdb} = $AppRoot;
          }
        } elsif ($AppPdbInfo) {
          $AppPdbInfo->{$AppPdb} = $AppRoot;
        }
      }
    }
  }

  if ($ezConnToPdb) {
    # Bug 25507396: some code expects CDB$ROOT to always be the first entry 
    #   in the arrays of names/open modes returned by this subroutine
    log_msg_debug <<msg;
ezConnToPdb ($ezConnToPdb) was specified, meaning that the list of 
  Containers was collected in the PDB and did not include CDB\$ROOT 
  which is expected to be the first entry in the list of Containers.
  Fabricate ConNames and IsOpen entries for CDB\$ROOT
msg
    unshift @$ConNames, 'CDB$ROOT' if ($ConNames);
    $IsOpen->{'CDB$ROOT'} = 'Y';
  }

  return 0;
}

#
# get_fed_root_info - query V$CONTAINERS to obtain an indicator of whether 
#                     specified Container is a Federation Root and get its 
#                     CON ID
#
# parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - name of a supposed Federation Root (IN)
#   - reference to an indicator of whether a Container is a Federation 
#     Root (OUT)
#   - reference to CON ID of the specified Container (OUT)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
sub get_fed_root_info (\@$$$\$\$$) {
  my ($myConnect, $DoneCmd, $DoneFilePathBase, $ConName, $IsFedRoot, 
      $ConId, $sqlplus) = @_;

  my @GetFedRootInfoStmts = (
    "connect ".$myConnect->[0]."\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || application_root, con_id from v\$containers where name = '".$ConName."'\n/\n",
  );

  # each row consists of a Container name and Y/N indicating whether it is open
  my ($rows_ref, $Spool_ref) = 
    exec_DB_script(@GetFedRootInfoStmts, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$rows_ref || $#$rows_ref != 0) {
    # App Root info could not be obtained
    print_exec_DB_script_output("get_fed_root_info", $Spool_ref, 1);
        
    return 1;
  }

  # split the row into a Federation Root indicator and CON ID (make sure a 
  # single row was fetched, let caller decide what to do if that was not the 
  # case)
  ($$IsFedRoot, $$ConId) = split /\s+/, $$rows_ref[0];

  return 0;
}

#
# get_fed_pdb_names - query V$CONTAINERS to get names of Federation PDBs 
#                     belonging to a Federation Root with specified CON ID
#
# parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - CON ID of a Federation Root (IN)
#   - reference to an array of Federation PDB names (OUT)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
sub get_fed_pdb_names (\@$$$\@$) {
  my ($myConnect, $DoneCmd, $DoneFilePathBase, $FedRootConId, 
      $FedPdbNames, $sqlplus) = @_;

  my @GetFedPdbNamesStmts = (
    "connect ".$myConnect->[0]."\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || name from v\$containers where application_root_con_id = $FedRootConId order by con_id\n/\n",
  );

  # each row consists of a Container name and Y/N indicating whether it is open
  my ($rows_ref, $Spool_ref) = 
    exec_DB_script(@GetFedPdbNamesStmts, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!@$rows_ref || $#$rows_ref < 0) {
    # App PDB names could not be obtained
    print_exec_DB_script_output("get_fed_pdb_names", $Spool_ref, 1);
    
    return 1;
  }

  for my $row ( @$rows_ref ) {
    push @$FedPdbNames, $row;
  }

  return 0;
}

#
# get_inst_procs - obtain number of SQL*Plus processes that can be started on 
#                  every OPEN instance
#
# parameters:
#   - indicator whether we are running catcon or rman 
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns:
#   A hash consisting of 
#   <instance name> => <number of sessions that can connect to instance-name> 
#   entries;
#   return undef if pertinent info could not be found
#
sub get_inst_procs($$$$$) {
  my ($catcon_InvokeFrom, $myConnect, $DoneCmd, $DoneFilePathBase,
      $sqlplus) = @_;

  my @InstProcsStatements;

  # if called from catcon, all instances are assumed to be open when 
  # we call the following code
  # if called from rman, we do not assume all instances to be open, 
  # it can also be in mount status to perform backup/restore jobs, 
  # but we will skip instances that are closed or nomounted
  if ($catcon_InvokeFrom == CATCON_INVOKEFROM_CATCON) {
    @InstProcsStatements = (
      "connect $myConnect->[0]\n",
      "set echo off\n",
      "set heading off\n",
      "select \'C:A:T:C:O:N\' || inst.instance_name || \' \' || ".
           "least(cpu_param.value*2, sess_param.value-sess.num_sessions) ".
      "from gv\$instance inst, gv\$parameter cpu_param, ".
           "gv\$parameter sess_param, ".
             "(select inst_id, count(*) as num_sessions ".
                "from gv\$session group by inst_id) sess ".
      "where cpu_param.name=\'cpu_count\' ".
        "and sess_param.name=\'sessions\' ".
        "and sess_param.inst_id=sess.inst_id ".
        "and cpu_param.inst_id=sess.inst_id ".
        "and inst.inst_id=sess.inst_id\n/\n",
    );
  }
  else {
    @InstProcsStatements = (
      "connect $myConnect->[0]\n",
      "set echo off\n",
      "set heading off\n",
      "select \'C:A:T:C:O:N\' || inst.instance_name || \' \' || ".
           "least(cpu_param.value*2, sess_param.value-sess.num_sessions) ".
      "from gv\$instance inst, gv\$parameter cpu_param, ".
           "gv\$parameter sess_param, ".
           "(select inst_id, count(*) as num_sessions ".
              "from gv\$session group by inst_id) sess ".
      "where cpu_param.name=\'cpu_count\' ".
        "and sess_param.name=\'sessions\' ".
        "and inst.status in (\'OPEN\', \'MOUNTED\') ".
        "and sess_param.inst_id=sess.inst_id ".
        "and cpu_param.inst_id=sess.inst_id ".
        "and inst.inst_id=sess.inst_id\n/\n",
    );
  }


  my ($retValues_ref, $Spool_ref) = 
    exec_DB_script(@InstProcsStatements, "C:A:T:C:O:N", 
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!$retValues_ref || !@$retValues_ref) {
    log_msg_error("no data was obtained");
    print_exec_DB_script_output("get_inst_procs", $Spool_ref, 1);
    return undef;
  }

  my %instProc;

  foreach my $row (@$retValues_ref) {
    # $row should consist of instance name and number of processes which will 
    # be allocated to run scripts on PDBs open on that instance
    my @vals = split(' ', $row);

    if ($#vals != 1) {
      log_msg_error("data contained an element ($row) with unexpected format");
      print_exec_DB_script_output("get_inst_procs", $Spool_ref, 1);
      return undef;
    }

    # remember how many sqlplus processes can be allocated to this instance
    my %maxProcsHash = (MAX_PROCS => $vals[1]);

    # map instance name to a hash representing number of processes which can 
    # be started on this instance (to which an entry reprsenting an offset 
    # of the id of the first of these processes in @catcon_ProcIds will be 
    # added when we start these processes in start_processes)
    $instProc{$vals[0]} = \%maxProcsHash;

    log_msg_debug("added $vals[0] => (MAX_PROCS => ".
                  $vals[1].") entry to the hash");
  }

  return \%instProc;
}

# handler for SIGINT while resetting PDB mode(s)
sub handle_sigint_for_pdb_mode () {
  log_msg_debug("Caught SIGINT while changing PDB mode(s)");

  # reregister SIGINT handler in case we are running on a system where 
  # signal(3) acts in "the old unreliable System V way", i.e. clears the 
  # signal handler
  $SIG{INT} = \&handle_sigint_for_pdb_mode;

  return;
}

#
# reset_seed_pdb_mode - close PDB$SEED on all instances and open it in the 
#                       specified mode
#
# parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - mode in which PDB$SEED is to be opened
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# returns:
# - 0 if it appears that all went well
# - 1 if an error was encountered
# - 2 if PDB$SEED could not be opened in the requested mode (which would have 
#     to be something other that READ ONLY) because the CDB is open READ ONLY 
#     (bug 23106360)
#
# Bug 14248297: close PDB$SEED on all RAC instances. If the PDB$SEED is to be
# opened on all instances, then the 'seedMode' argument must specify it.
#
sub reset_seed_pdb_mode (\@$$$$) {
  my ($myConnect, $seedMode, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  # if resetting PDB$SEED to a mode other than READ ONLY, make sure the CDB 
  # itself is not open READ ONLY
  if ($seedMode !~ /READ ONLY/) {
    my $cdbOpenMode = 
      get_CDB_open_mode(@$myConnect, $DoneCmd, $DoneFilePathBase, $sqlplus);

    if (!(defined $cdbOpenMode)) {
      log_msg_error("unexpected error in get_CDB_open_mode");
      return 1;
    }

    if ($cdbOpenMode eq 'READ ONLY') {
      log_msg_warn("PDB\$SEED can not be opened in ".
                   "$seedMode because the CDB is open READ ONLY");
      return 2;
    }
  }

  my @ResetSeedModeStatements = (
    "connect ".$myConnect->[0]."\n",
    qq#alter session set "_oracle_script"=TRUE\n/\n#,
    "alter pluggable database pdb\$seed close immediate instances=all\n/\n",
    "alter pluggable database pdb\$seed $seedMode\n/\n",
  );

  # temporarily reset $SIG{INT} to avoid dying while PDB$SEED is in transition
  my $saveIntHandlerRef = $SIG{INT};
  
  $SIG{INT} = \&handle_sigint_for_pdb_mode;

  log_msg_debug("temporarily reset SIGINT handler");

  my ($ignoreOutputRef, $spoolRef) = 
    exec_DB_script(@ResetSeedModeStatements, undef, $DoneCmd, 
                   $DoneFilePathBase, $sqlplus);

  print_exec_DB_script_output("reset_seed_pdb_mode", $spoolRef, 0);

  # 
  # restore INT signal handler 
  #
  $SIG{INT} = $saveIntHandlerRef;

  log_msg_debug("restored SIGINT handler");

  return 0;
}

# values that can be used when requesting that PDBs be open in a certain 
# mode:
#   - 0 - leave it alone (caller responsible for opening PDBs in the correct 
#         mode before calling catcon)
#   - 1 - PDBs must be open READ WRITE; if any of them are not, catconExec will
#         reopen them READ WRITE and catconWrapUp will restore their modes 
#   - 2 - PDBs must be open READ ONLY; if any of them are not, catconExec will
#         reopen them READ ONLY and catconWrapUp will restore their modes
#   - 3 - PDBs must be open for UPGRADE; if any of them are not open MIGRATE 
#         (currently we do not distinguish between UPGRADE and DOWNGRADE), 
#         catconExec will reopen them UPGRADE and catconWrapUp will restore 
#         their modes
#   - 4 - PDBs must be open for UPGRADE; if any of them are not open MIGRATE 
#         (currently we do not distinguish between UPGRADE and DOWNGRADE), 
#         catconExec will reopen them UPGRADE and catconWrapUp will restore 
#         their modes
use constant CATCON_PDB_MODE_UNCHANGED  => 0;
use constant CATCON_PDB_MODE_READ_WRITE => 1;
use constant CATCON_PDB_MODE_READ_ONLY  => 2;
use constant CATCON_PDB_MODE_UPGRADE    => 3;
use constant CATCON_PDB_MODE_DOWNGRADE  => 4;
# no value was supplied
use constant CATCON_PDB_MODE_NA         => 99;

# minimum/maximum CATCON_PDB_MODE_* values representing PDB mode
use constant CATCON_PDB_MODE_MIN        => CATCON_PDB_MODE_UNCHANGED;
use constant CATCON_PDB_MODE_MAX        => CATCON_PDB_MODE_DOWNGRADE;

# value of x$con.state if a PDB is mounted
use constant CATCON_PDB_MODE_MOUNTED    => 0;

# hash mapping CATCON_PDB_MODE_* value corresponding to a valid PDB mode 
# (READ WRITE, READ ONLY, UPGRADE) to a corresponding string

use constant PDB_MODE_CONST_TO_STRING  => {
    # caller cannot request this mode; however, a PDB may be in MOUNTED mode, 
    # and if we need to display a string representing that state, this mapping
    # will be used
    0   => "MOUNTED",

    # PDB modes that a user can request
    1   => "READ WRITE",
    2   => "READ ONLY",
    3   => "UPGRADE",
    # in RDBMS, we do not distinguish between UPGRADE and DOWNGRADE
    4   => "UPGRADE",
};

# and the inverse map (used to convert a string representing a mode into a
# corresponding CATCON_PDB_MODE_* value
use constant PDB_STRING_TO_MODE_CONST  => {
    # if no value was specified, the option flag will remain set to 0
    0            => CATCON_PDB_MODE_NA,

    'MOUNTED'    => CATCON_PDB_MODE_MOUNTED,
    'UNCHANGED'  => CATCON_PDB_MODE_UNCHANGED,
    'READ WRITE' => CATCON_PDB_MODE_READ_WRITE,
    'READ ONLY'  => CATCON_PDB_MODE_READ_ONLY,
    'MIGRATE'    => CATCON_PDB_MODE_UPGRADE,
    'UPGRADE'    => CATCON_PDB_MODE_UPGRADE,
    'DOWNGRADE'  => CATCON_PDB_MODE_DOWNGRADE,
};

# environment variable which may be set to a CATCON_PDB_MODE_* constant 
# representing a mode in which ALL pdbs should be opened before running 
# scripts against them
use constant ALL_PDB_MODE_ENV_TAG => "CATCON_ALL_PDB_MODE";

# validate PDB mode supplied by the caller
sub valid_pdb_mode($) {
  my ($mode) = @_;

  return ($mode =~ /[0-9]+/ && $mode >= catcon::CATCON_PDB_MODE_MIN && 
          $mode <= catcon::CATCON_PDB_MODE_MAX);
}


# while catcon.pl will prevent a user from specifying both --pdb_seed_mode 
# and --force_open_mode, I cannot guarantee that other users of catcon.pm 
# subroutines will do the same, so this subroutine will return mode in 
# which PDB$SEED should be open based on values stored in $catcon_SeedPdbMode 
# and $catcon_AllPdbMode
#
# NOTE: when determining mode in which PDB$SEED and the rest of PDBs should 
#       be open, it's important that we call seed_pdb_mode_to_use before 
#       all_pdb_mode_to_use() since the latter will set the "all PDBs" mode 
#       to a value other than CATCON_PDB_MODE_NA (even if no value for 
#       "all PDBs" mode was specified) which can then influence the mode in 
#       which we will open PDB$SEED
sub seed_pdb_mode_to_use($$) {
  my ($seed_mode, $all_pdb_mode) = @_;

  # if the caller specified mode in which all PDBs should be open or 
  # specified that they should be left in whatever mode they were, return 
  # that value
  if ($all_pdb_mode != CATCON_PDB_MODE_NA) {
    return $all_pdb_mode;
  }

  # if $all_pdb_mode was not set (by calling catconPdbMode()), see if
  # $CATCON_ALL_PDB_MODE was set to a valid value
  if (exists $ENV{&ALL_PDB_MODE_ENV_TAG} && 
      valid_pdb_mode($ENV{&ALL_PDB_MODE_ENV_TAG})) {
    return $ENV{&ALL_PDB_MODE_ENV_TAG};
  }

  # PDB mode for PDB$SEED defaults to CATCON_PDB_MODE_READ_WRITE
  return ($seed_mode != CATCON_PDB_MODE_NA) ? $seed_mode 
                                            : CATCON_PDB_MODE_READ_WRITE;
}

# determine mode in which all PDBs need to be opened before running scripts
sub all_pdb_mode_to_use($) {
  my ($all_pdb_mode) = @_;

  # if $all_pdb_mode was set (by calling catconPdbMode()), use that value
  if ($all_pdb_mode != CATCON_PDB_MODE_NA) {
    return $all_pdb_mode;
  }

  # if $all_pdb_mode wasn't set, see if $CATCON_ALL_PDB_MODE was set to a 
  # valid value
  if (exists $ENV{&ALL_PDB_MODE_ENV_TAG} && 
      valid_pdb_mode($ENV{&ALL_PDB_MODE_ENV_TAG})) {
    return $ENV{&ALL_PDB_MODE_ENV_TAG};
  }
  
  # if all else fails, PDB mode for all PDBs defaults to 
  # CATCON_PDB_MODE_UNCHANGED
  return CATCON_PDB_MODE_UNCHANGED;
}

# this subroutine will dump contents of a 
# instance-name => ref @pdb-names hash that 
# is used to describe which PDBs are open on which instances
sub inst_pdbs_hash_dump($$$) {
  my ($instPdbsHashRef, $funcName, $hashName) = @_;

  log_msg_debug("$funcName: contents of $hashName hash:");

  if (!%$instPdbsHashRef) {
    log_msg_debug("\tnone");

    return;
  }

  foreach my $inst (sort keys %$instPdbsHashRef) {
    log_msg_debug("instance = $inst");

    my $pdbs = $instPdbsHashRef->{$inst};

    foreach my $pdb (@$pdbs) {
      log_msg_debug("\tPDB = $pdb");
    }
  }
}

# this subroutine will dump contents of a 
# instance-name => number-of-processes hash that 
# is used to describe how many processes can be opened on each instance
sub inst_proc_hash_dump($$$) {
  my ($instProcHashRef, $funcName, $hashName) = @_;

  log_msg_debug("$funcName: contents of $hashName hash:");

  foreach my $inst (sort keys %$instProcHashRef) {
    log_msg_debug("\tinstance $inst - ".$instProcHashRef->{$inst}.
                  " processes");
  }
}

# this subroutine will dump contents of a 
# (mode.' '. restricted) => ref {instance-name => ref @pdb-names} hash that 
# is used to describe how to reset PDB modes
sub pdb_mode_hash_dump($$$) {
  my ($pdbModeHashRef, $funcName, $hashName) = @_;

  log_msg_debug("$funcName: contents of $hashName hash:");

  foreach my $modeAndRestr (sort keys %$pdbModeHashRef) {
    my @modeAndRestrArr = split(' ', $modeAndRestr);
    my $modeString = PDB_MODE_CONST_TO_STRING->{$modeAndRestrArr[0]};
    my $restrString = 
      ($modeAndRestrArr[1] == 0) ? "unrestricted" : "restricted";

    log_msg_debug("\tmode = $modeString $restrString");
      
    my $instToPdbMapRef = $pdbModeHashRef->{$modeAndRestr};

    foreach my $inst (sort keys %$instToPdbMapRef) {
      log_msg_debug("\t  instance = $inst");

      my $pdbs = $instToPdbMapRef->{$inst};

      foreach my $pdb (@$pdbs) {
        log_msg_debug("\t    PDB = $pdb");
      }
    }
  }
}

#
# curr_pdb_mode_info - obtain mode (0 - MOUNTED, 1 - READ WRITE, 2 - READ ONLY
#                      3 - MIGRATE) in which a given PDB is open and an 
#                      indicator of whether it is open Restricted (0 - NO, 
#                      1 - YES, 2 - if PDB is MOUNTED) on every instance
#
# parameters:
#   $myConnect (IN) - 
#     reference to an array of connect strings:
#     - [0] used to connect to a DB,
#     - [1] can be used to produce diagnostic message
#   $pdbName (IN) - 
#     PDB name
#   $DoneCmd (IN) - 
#     a command to create a file whose existence will indicate that the
#     last statement of the script has executed (needed by exec_DB_script())
#   $DoneFilePathBase (IN) - 
#     base for a name of a "done" file (see above)
#   $sqlplus (IN) - 
#     "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns:
#   A hash consisting of instance-name => (mode, restricted) entries;
#   return undef if info pertaining to the specified PDB could not be found
#
sub curr_pdb_mode_info (\@$$$$) {
  my ($myConnect, $pdbName, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @SeedModeStateStatements = (
    "connect $myConnect->[0]\n",
    "set echo off\n",
    "set heading off\n",
    "select \'C:A:T:C:O:N\' || p.open_mode || ',' || ".
                              "nvl(p.restricted, 'NO') || ',' || ".
                              "i.instance_name ".
      "from gv\$pdbs p, gv\$instance i ".
      "where p.name='".$pdbName."' and p.inst_id = i.inst_id\n/\n",
  );


  my ($retValues_ref, $Spool_ref) =
    exec_DB_script(@SeedModeStateStatements, "C:A:T:C:O:N",
                   $DoneCmd, $DoneFilePathBase, $sqlplus);

  if (!$retValues_ref || !@$retValues_ref) {
    log_msg_error("no data was obtained for PDB $pdbName");
    print_exec_DB_script_output("curr_pdb_mode_info", $Spool_ref, 1);
    return undef;
  }

  my %currPdbModeInfo;

  foreach my $row (@$retValues_ref) {
    # $row should consist of PDB mode (string), an indicator of whether
    # the PDB is open restricted, and an instance name, separated by commas
    my @vals = split(/,/, $row);

    if ($#vals != 2) {
      log_msg_error("data returned for PDB $pdbName contained ".
                    "an element ($row) with unexpected format");
      print_exec_DB_script_output("curr_pdb_mode_info", $Spool_ref, 1);
      return undef;
    }

    # map instance name to (mode restricted)
    $currPdbModeInfo{$vals[2]} =
      PDB_STRING_TO_MODE_CONST->{$vals[0]}." ".($vals[1] eq "NO" ? 0 : 1);

    log_msg_debug("added $vals[2] => ".
                  $currPdbModeInfo{$vals[2]}."(".$vals[0]." ".$vals[1].") ".
                  "element to the hash");
  }

  return \%currPdbModeInfo;
}

# single_inst_need_pdb_mode_check has determined that the specified PDB may 
# need to be reopened in the requested mode
use constant SINGLE_INST_NEED_PDB_MODE_CHECK_PDB => 0;

# single_inst_need_pdb_mode_check has determined that the specified PDB is
# already open in the correct mode and no further processing is needed
use constant SINGLE_INST_NEED_PDB_MODE_CHECK_NONE => 1;

# single_inst_need_pdb_mode_check has determined that the specified PDB is 
# an App PDB and it, and its App Root, may need to be reopened in the 
# requested mode
use constant SINGLE_INST_NEED_PDB_MODE_CHECK_APP_ROOT => 2;

# determine if we need to check the mode in which a PDB (and, if it is an 
# App PDB, its App Root) is open before deciding if it needs to be reopened 
# in requested mode if all PDBs will be processed using a single instance
#
# Parameters:
#   $pdbName (IN) - 
#     name of a PDB whose node may need to be changed
#   $beingProcessed (IN/OUT) -
#     reference to a hash whose keys represent names of PDBs being processed 
#     during the current invocation; may be modified as follows:
#     - if $pdbName has not been processed during this invocation, it will be 
#       added to this hash
#     - if $pdbName refers to an App Root Clone or App PDB whose App Root has 
#       neither already been processed during this invocation nor had its 
#       mode set during a preceeding one, name of the App Root will be added 
#       to this hash
#   $alreadyInRightMode (IN) -
#     reference to a hash whose keys represent names of PDBs which are 
#     already open in desired mode
#   $appRootCloneInfo (IN) -
#     reference to a hash mapping names of App Root Clones to their App Roots
#   $appPdbInfo (IN) -
#     reference to a hash mapping names of App PDBs to their App Roots
#
# Returns:
#   See SINGLE_INST_NEED_PDB_MODE_CHECK_* constants above
sub single_inst_need_pdb_mode_check($$$$$) {
  my ($pdbName, $beingProcessed, $alreadyInRightMode, $appRootCloneInfo, 
      $appPdbInfo) = @_;

  # assume that PDB mode will need to be checked
  my $retVal = SINGLE_INST_NEED_PDB_MODE_CHECK_PDB;

  if (exists $beingProcessed->{$pdbName}) {
    # names of PDBs whose mode may need changing are expected to be unique, 
    # so the only way that $pdbName may have already been seen during the 
    # current invocation is that $pdbName refers to an App Root whose Clone 
    # or App PDB occurred ahead of it in the list of PDBs
    log_msg_debug <<msg;
A single instance will be used to process all PDBs, and $pdbName is an 
    App Root whose Clone or App PDB was already encountered during current 
    invocation, so we don't need to process it separately
msg
    return SINGLE_INST_NEED_PDB_MODE_CHECK_NONE;
  }
            
  # this PDB will be processed during the current invocation
  $beingProcessed->{$pdbName} = 1;

  log_msg_debug("Added $pdbName to the list of PDBs which will be processed ".
                "during the current invocation which now\n".
                "represents the following PDBs:\n    ".
                join(", ", sort keys %$beingProcessed));

  if ($appRootCloneInfo && (exists $appRootCloneInfo->{$pdbName})) {
    my $appRoot = $appRootCloneInfo->{$pdbName};

    log_msg_debug <<msg;
$pdbName is an App Root Clone - if its mode needs to be changed,
    the operation will involve the corresponding App Root ($appRoot)
msg

    # if the App Root to which this Clone belongs was already opened in 
    # the desired mode during previous invocation of this function or had 
    # been processed earlier during the current invocation, we don't need 
    # to change mode in which $pdbName is open
    if (exists $alreadyInRightMode->{$appRoot}) {
      log_msg_debug <<msg;
A single instance will be used to process all PDBs, and $pdbName is an 
    App Root Clone whose App Root ($appRoot) has been processed during an 
    earlier invocation, so we don't need to process it again
msg
      return SINGLE_INST_NEED_PDB_MODE_CHECK_NONE;
    }

    if (exists $beingProcessed->{$appRoot}) {
      log_msg_debug <<msg;
A single instance will be used to process all PDBs, and $pdbName is an 
    App Root Clone whose App Root ($appRoot) has been processed earlier during 
    this invocation, so we don't need to process it again
msg

      return SINGLE_INST_NEED_PDB_MODE_CHECK_NONE;
    }

    # mark the App Root to which App Root Clone $pdbName belongs as 
    # having been processed during the current invocation
    #
    # Note that in this case this function will return 
    #   SINGLE_INST_NEED_PDB_MODE_CHECK_PDB and not 
    #   SINGLE_INST_NEED_PDB_MODE_CHECK_APP_ROOT because we do not need to check 
    #   separately whether the App Root is open since App Root Clone is always 
    #   open in the same mode as the App Root
    $beingProcessed->{$appRoot} = 1;
    
    log_msg_debug("Added App Root $appRoot to which Clone $pdbName\n".
                  "belongs to the list of PDBs which will be processed ".
                  "during the current invocation which now\n".
                  "represents the following PDBs:\n    ".
                  join(", ", sort keys %$beingProcessed));
  } elsif ($appPdbInfo && (exists $appPdbInfo->{$pdbName})) {
    my $appRoot = $appPdbInfo->{$pdbName};

    log_msg_debug <<msg;
$pdbName is an App PDB - if its mode needs to be changed,
    we will need to ensure that its App Root ($appRoot) is open in the 
    same mode
msg

    # if the App Root to which this App PDB belongs was already opened in 
    # the desired mode during previous invocation of this function or had 
    # been processed earlier during the current invocation, we won't need 
    # to change mode in which $appRoot is open, but we will still need to 
    # change the mode in which App PDB itself is open
    if (exists $alreadyInRightMode->{$appRoot}) {
      log_msg_debug <<msg;
A single instance will be used to process all PDBs, and $pdbName is an 
    App PDB whose App Root ($appRoot) has been processed during an earlier 
    invocation, so we will not need to process the App Root, but the App PDB 
    will still need to be processed
msg
    } elsif (exists $beingProcessed->{$appRoot}) {
      log_msg_debug <<msg;
A single instance will be used to process all PDBs, and $pdbName is an 
    App PDB whose App Root ($appRoot) has been processed earlier during this
    invocation, so we will not need to process the App Root, but the App PDB 
    will still need to be processed
msg
    } else {
      # mark the App Root to which App PDB $pdbName belongs as 
      # having been processed during the current invocation
      $beingProcessed->{$appRoot} = 1;
    
      log_msg_debug("App Root $appRoot may need to have its mode reset.");

      log_msg_debug("Added App Root $appRoot to which App PDB $pdbName\n".
                    "belongs to the list of PDBs which will be processed ".
                    "during the current invocation which now\n".
                    "represents the following PDBs:\n    ".
                    join(", ", sort keys %$beingProcessed));

      # Note that in this case, before checking whether the App PDB is open, 
      #   we will also need to check if the App Root is open (the reason for 
      #   this order is that if App Root needs to be open, it needs to happen 
      #   before opening the App PDB)
      $retVal = SINGLE_INST_NEED_PDB_MODE_CHECK_APP_ROOT;
    }
  }

  log_msg_debug("PDB $pdbName may need to have its mode reset.");
  
  return $retVal;
}

# determine whether the specified PDB is open in the specified mode
#
# Parameters:
#   $pdbName (IN) - 
#     name of a PDB the mode in which it is open is to be checked
#   $reqMode (IN) - 
#     requested mode 
#   $revertPdbModes (OUT) - 
#     (mode, restricted) => {instance-name => @pdb-names} hash describing PDBs
#     whose modes need to be changed which may be updated by this subroutine 
#     if the specified PDB is not open in requested mode
#   $dfltInstName (IN) - 
#     name of the default instance; defined if processing will be taking 
#     place on the default instance
#   $connString (IN) - 
#     reference to a connect string array
#   $doneCmd (IN) - 
#     "done" command
#   $doneFileNamePrefix (IN) - 
#     prefix to be used to construct names of "done" files
#   $sqlplus (IN) -
#     "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#   $useMultipleInstances (IN) - 
#     indicator of whether processing will involve all available instances 
#   $pdbsOpenInUpgradeMode (OUT) -
#     a reference to a hash representing PDBs currently open in UPGRADE mode 
#     which we decided to leave alone
#
# Returns:
#   1 if an error was encountered; 0 otherwise
sub verify_pdb_mode($$$$$$$$$$) {
  my ($pdbName, $reqMode, $revertPdbModes, $dfltInstName, $connString, 
      $doneCmd, $doneFileNamePrefix, $sqlplus, $useMultipleInstances,
      $pdbsOpenInUpgradeMode) = @_;

  # string corresponding to the mode specified by the caller
  my $reqModeString = PDB_MODE_CONST_TO_STRING->{$reqMode};

  log_msg_debug("determine mode(s) in which PDB $pdbName is ".
                "open on all instances.");

  # Bug 18011217: append _catcon_$logFileSuffix to $logFilePathBase to avoid 
  # conflicts with other catcon processes running on the same host
  my $currPdbModeInfo = 
    curr_pdb_mode_info(@$connString, $pdbName, $doneCmd, 
                       $doneFileNamePrefix, $sqlplus);
  if (! (defined $currPdbModeInfo)) {
    log_msg_error("unexpected error in curr_pdb_mode_info");
    return 1;
  }

  # If on some instance the PDB is open in a mode different from that 
  # requested by the caller, remember to which mode it needs to be restored 
  # when we are done
  my @instances = sort keys %$currPdbModeInfo;

  log_msg_debug("curr_pdb_mode_info has returned modes in which PDB\n".
                "\t$pdbName is open on instances (".join(', ', @instances).
                ")");

  foreach my $inst (@instances) {
    my @modeAndRestr = split(/ /, $currPdbModeInfo->{$inst});
    my $currMode = $modeAndRestr[0];
    my $currModeString = PDB_MODE_CONST_TO_STRING->{$currMode};
    my $currRestrString = 
      ($modeAndRestr[1] == 0) ? "unrestricted" : "restricted";

    log_msg_debug("on instance $inst, PDB $pdbName is open ".
                  "$currModeString, $currRestrString");

    #
    # NOTE: if the PDB is open in UPGRADE or DOWNGRADE mode, $currMode 
    # will be set to 3 since we don't currently distinguish between 
    # UPGRADE and DOWNGRADE
    #
    # Bug 18606911: if a PDB is open in UPGRADE mode and the caller 
    # asked that it be open in READ WRITE mode, there is no need to 
    # change the PDB's mode
    #
    # Bug 20193612: if we decided to spread PDBs across multiple 
    # OPEN instances, we will ignore whether the PDB is already open in the 
    # requested mode on some instance.  It is much simpler to close it 
    # across the board and then open it on the instance of our choosing
    #
    # Bug 25392172: if all processing will take place on the default 
    #   instance and the PDB is OPEN for UPGRADE on an instance other than 
    #   the default instance, we need to close it on the instance on which 
    #   it is currently open and then reopen it on the default instance
    #
    # Bug 26275415: if all processing will take place on the default 
    #   instance, and the PDB is MOUNTED on an instance other than the
    #   default instance, there is no need to add it to revertPdbModes, 
    #   since it does not need to be closed and it will not be opened.  
    #
    #   Furthermore, doing so would result in an error when 
    #   catconRevertPdbModes tries to open PDBs if the PDB is already open 
    #   in the desired mode on the default instance (since in such case it 
    #   will not get closed on the default instance, and trying to open an 
    #   already open PDB without specifying FORCE is not allowed, while 
    #   catconRevertPdbModes does not use FORCE since it assumes that the 
    #   PDBs to be open are closed on the instance in which they are being 
    #   opened.)
    if (   $useMultipleInstances 
        || ($reqMode != $currMode &&
            !(   (   $reqMode == CATCON_PDB_MODE_DOWNGRADE 
                  || $reqMode == CATCON_PDB_MODE_READ_WRITE)
              && $currMode == CATCON_PDB_MODE_UPGRADE) &&
            !($currMode == CATCON_PDB_MODE_MOUNTED && !$useMultipleInstances &&
              $dfltInstName ne $inst)) 
        || $currMode == CATCON_PDB_MODE_UPGRADE && !$useMultipleInstances &&
           $dfltInstName ne $inst) {

      log_msg_debug <<msg;
on instance $inst, PDB $pdbName will need to be closed
    and possibly reopened in $reqModeString mode.
msg
        
      # determine if %$revertPdbModes hash contains an entry for mode and 
      # restricted flag corresponding to $inst
      if (exists $revertPdbModes->{$currPdbModeInfo->{$inst}}) {
        # locate hash mapping instance names to PDB names for 
        # (mode restricted) pair
        my $instToPdbMapRef = $revertPdbModes->{$currPdbModeInfo->{$inst}};

        log_msg_debug <<msg;
revertPdbModes contains an entry for ($currModeString, $currRestrString) pair
msg

        # if the mapping already includes an element for the current 
        # instance, add the current PDB to that mapping; otherwise, create 
        # a new mapping and add a reference to it to %$instToPdbMapRef
        if (exists $instToPdbMapRef->{$inst}) {
          my $pdbArrRef = $instToPdbMapRef->{$inst};

          log_msg_debug <<msg;
revertPdbModes entry for ($currModeString, $currRestrString) 
    contains an entry for instance $inst; will add PDB $pdbName to 
    (@$pdbArrRef.)
msg

          push @$pdbArrRef, $pdbName;
        } else {
          my @pdbArr;

          push @pdbArr, $pdbName;
          $instToPdbMapRef->{$inst} = \@pdbArr;

          log_msg_debug <<msg;
revertPdbModes entry for ($currModeString, $currRestrString) 
    did not contain an entry for instance $inst; added $inst => @pdbArr to it
msg
        }
      } else {
        my %instToPdbMap;
        my @pdbNameArr;

        # construct a hash mapping instance name to array consisting of the
        # PDB name
        push @pdbNameArr, $pdbName;
        $instToPdbMap{$inst} = \@pdbNameArr;

        # add to %$revertPdbModes an entry mapping (mode restricted) to 
        # a reference to the above hash 
        $revertPdbModes->{$currPdbModeInfo->{$inst}} = \%instToPdbMap;

        log_msg_debug <<msg;
revertPdbModes did not contain an entry for 
    ($currModeString, $currRestrString) pair which was then created
    and initialized with $inst => @pdbNameArr
msg
      }
    } else {
      log_msg_debug <<msg;
on instance $inst, PDB $pdbName is open $currModeString and will not need 
    to be closed and reopened in $reqModeString mode.
msg
      if ($currMode == CATCON_PDB_MODE_UPGRADE) {
        # PDB is open in UPGRADE mode on the default instance so we should  
        # not try to open it on any other instance
        $pdbsOpenInUpgradeMode->{$pdbName} = $inst;

        log_msg_debug <<msg;
PDB $pdbName is open in UPGRADE mode on instance $inst.
    It will remain open on that instance and will not be open on any other 
    instance, so we skip checking its status on any remaining instance
msg

        # if the PDB is open in UPGRADE mode on this instance, it is 
        # guaranteed to be closed on all other instances, and we will not be 
        # trying to open it there, so there is no reason to check whether 
        # this PDB is open on remaining instances or to remember its state 
        # since it will not (and cannot) be changed 
        last;
      }
    }
  }

  return 0;
}

# force PDB(s) to be open in specified mode
#
# Parameters:
#   $Containers (IN) - 
#     reference to an array of PDB names
#   $firstPDB (IN) - 
#     index of the first PDB to be processed
#   $lastPDB (IN) - 
#     index of the last PDB to be processed
#   $appRootCloneInfo (IN) - 
#     reference to a hash mapping names of App Root Clones (if any) to names 
#     of their App Roots; since App Root Clones inherit their mode from their 
#     App Roots, whenever we need to close or open an App Root Clone, we will 
#     operate on its App Root instead
#   $appPdbInfo (IN) - 
#     reference to a hash mapping names of App PDBs (if any) to names 
#     of their App Roots; since App PDBs rely on their App Roots for various 
#     metadata, whenever we need to open an App PDB on a given instance, we 
#     will ensure that the App Root is open on that instance in the same mode
#   $reqMode (IN) - 
#     requested mode 
#   $revertPdbModes (OUT) - 
#     (mode, restricted) => {instance-name => @pdb-names} hash describing PDBs
#     whose modes were changed to the requested mode by this subroutine and 
#     which will need to be reset in catconWrapUp() 
#   $logFileSuffix (IN) - 
#     log file suffix - used to avoid conflicts in log file names 
#   $logFilePathBase (IN) - 
#     log file path base 
#   $connString (IN) - 
#     reference to a connect string array
#   $doneCmd (IN) - 
#     "done" command
#   $oracleScript (IN)  - 
#     indicator of whether _ORACLE_SCRPT needs to be set before (and cleared 
#     after) resetting PDB mode(s)
#   $pdbsOpenInReqMode (IN/OUT) - 
#     hash used to keep track of all PDBs which we know to be opened in 
#     requested mode and which may be updated to reflect additional PDBs 
#     specified in @$Containers[$firstPDB..$lastPDB]
#   $isConOpen (IN/OUT) - 
#     reference to a hash used to keep track of whether a given PDB is open; 
#     may be updated to reflect new PDBs opened in the desired mode
#   $dbmsVersion (IN) - 
#     RDBMS version; used to ensure that SQL statements that we generate are 
#     compatible with the version of the RDBMS to which we are connected
#   $MorePdbs (IN) - 
#     an indicator of whether there are more PDBs to be opened following this 
#     invocation (meaning that if we are opening PDBs on multiple instances, 
#     we will close specified PDBs during this invocation but delay reopening 
#     them until there are no more PDBs to process at which point we will 
#     reopen all of them)
#   $InstProcMap_ref (IN) - 
#     a reference to a hash mapping names of instances to the number of 
#     processes allocated to each of these instances which will be set ONLY IF 
#     we were told to process PDBs using all available instances
#   $InstConnStrMap_ref (IN) - 
#     a reference to a hash mapping instance names to instance connect strings
#   $dfltInstName (IN) - 
#     name of the default instance
#   $sqlplus (IN) - 
#     "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
# Returns:
#   (status, inst-to-PDB-Hash_ref)
#   where 
#     status may be one of
#       -1 - no PDBs had to be reopened, with inst-to-PDB-Hash_ref undefined
#        0 - some/all PDBs had to be reopened, with inst-to-PDB-Hash_ref, if 
#            defined, referencing a hash that can be used to determine which 
#            PDBs are open on each instance
#        1 - an unexpected error was encountered, with inst-to-PDB-Hash_ref 
#            undefined
sub force_pdb_modes(\@$$$$$$$$\@$$\%\%$$$$$$) {
  my ($Containers, $firstPDB, $lastPDB, $appRootCloneInfo, $appPdbInfo, 
      $reqMode, $revertPdbModes, $logFileSuffix, $logFilePathBase, $connString,
      $doneCmd, $oracleScript, $pdbsOpenInReqMode, $isConOpen, 
      $dbmsVersion, $MorePdbs, $InstProcMap_ref, $InstConnStrMap_ref,
      $dfltInstName, $sqlplus) = @_;

  # first check if @$Containers[$firstPDB..$lastPDB] includes any PDBs we 
  # haven't seen before
  my @newPDBs = 
    grep {! exists $pdbsOpenInReqMode->{$_}} @$Containers[$firstPDB..$lastPDB];
  
  if ($#newPDBs < 0) {
    # no new PDBs to process
    log_msg_debug("PDBs whose mode has been previously verified ".
                  "to match requested mode:\n\t".
                  join("\n\t", sort (keys %$pdbsOpenInReqMode)));
    log_msg_debug("PDBs whose names were supplied by the ".
                  "caller:\n\t".
                  join("\n\t", @$Containers[$firstPDB..$lastPDB])."\n".
                  "contained no new PDBs ... returning.");

    return (-1, undef);
  } else {
    log_msg_debug("PDBs whose mode has been previously verified ".
                  "to match requested mode:\n\t".
                  join("\n\t", sort (keys %$pdbsOpenInReqMode)));
    log_msg_debug("PDBs whose names were supplied by the ".
                  "caller:\n\t".
                  join("\n\t", sort @$Containers[$firstPDB..$lastPDB]));
    log_msg_debug("PDBs which will have to be processed:\n\t".
                  join("\n\t", @newPDBs));
  }

  my $doneFileNamePrefix = 
    done_file_name_prefix($logFilePathBase, $logFileSuffix);

  # Bug 20193612: if we decided to run scripts on all available instances 
  # (i.e. if %$InstProcMap_ref has been populated) we will try to spread 
  # PDBs across all available instances
  my $useMultipleInstances = 0;

  if (%$InstProcMap_ref) {
    log_msg_debug("processing PDBs using all available instances");

    # number of instances on which the CDB is open
    my $numOpenInstances = scalar keys %$InstProcMap_ref;

    if ($numOpenInstances > 1) {
      $useMultipleInstances = 1;

      log_msg_debug <<msg;
CDB is open on $numOpenInstances instances all of 
    which may be used to process PDBs
msg
    } else {
      log_msg_debug("CDB is open on 1 instance which will be used to process ".
                    "PDBs");
    }
  }

  # string corresponding to the mode specified by the caller
  my $reqModeString = PDB_MODE_CONST_TO_STRING->{$reqMode};

  # if a PDB is open in UPGRADE mode and we decide to leave it alone 
  # (i.e. because the requested mode is UPGRADE, DOWNGRADE, or READ WRITE), 
  # we need to remember that this PDB should not be open on any other instance
  # (since a PDB can be open in UPGRADE mode on ONLY one instance)
  my %pdbsOpenInUpgradeMode;
          
  log_msg_debug <<msg;
check if specified PDB(s) need to be reopened in $reqModeString ($reqMode) mode
msg
   
  # Bug 26527096: 
  #   If @newPDBs includes some App Root Clones or App Roots, things will 
  #   get a little more complicated: 
  #
  #   - Since App Root Clones inherit their mode from their App Roots, 
  #     instead of opening/closing the former, we need to open/close the 
  #     latter, but while doing that, we need to be prepared to handle cases 
  #     where the App Root name occurs in 
  #     - %$pdbsOpenInReqMode (this means that the PDB was open in the 
  #       desired mode during an earlier invocation of this subroutine) or
  #     - @newPDBs itself, either before or after the App Root Clone
  #
  #     To simplify handling of App Root Clones, reset_pdb_modes will handle 
  #     translating names of App Root Clones into those of corresponding 
  #     App Roots for both single and multiple instance cases. 
  #
  #   - While closing App PDBs does not require that we close their App Roots, 
  #     opening them (before opening the App PDB) does, which means that some 
  #     of the issues we confront when dealing with App Root Clones also need 
  #     to be addressed when dealing with App PDBs.
  #
  #   Processing App Root Clones and App PDBs using a single instance:
  #
  #     For the single instance case, we will maintain a hash 
  #     (%singleInstProcdPDBs) of names of PDBs,
  #     including App Roots whose App Root Clones and/or App PDBs were 
  #     represented in @newPDBs, which have already been processed during this 
  #     invocation to enable us to avoid trying to close/open an App Root more 
  #     than once (which will spare us the need to reopen App PDBs associated 
  #     with that App Root which were opened during preceding invocations.)  
  #     It will also make it easier for us to add both App Root Clones, App 
  #     PDBs, and their corresponding App Roots to %$pdbsOpenInReqMode when we 
  #     are done so as to accurately reflect which PDBs are known to be open 
  #     in the correct mode
  #
  #   Processing App Root Clones and App PDBs using multiple instances:
  #
  #     In general, once we closed a PDB and opened it in the correct mode, we 
  #     don't want to reopen it again, but, if using multiple instances and 
  #     there are several App Root Clones and/or App PDBs associated with a 
  #     given App Root that need to be processed, we don't want to force them 
  #     all to be processed using a single instance, meaning that the App Root 
  #     may get opened on several instances
  #
  #     An exception to this is a case the caller requested that an App Root 
  #     and/or App Root Clones be opened for UPGRADE, in which case we have 
  #     no choice but to open App Root and all specified App PDBs belonging 
  #     to it on a single instance. 
  #   
  #     If we were asked to open only App PDBs (but not the App Root itself 
  #     or its Clone(s)) associated with some App Root for UPGRADE, we will 
  #     open App Root for RW on multiple instances, allowing us to spread
  #     App PDBs across multiple instances.
  #

  # names of PDBs (including App Roots whose App Root Clones and/or App PDBs
  # were represented in @newPDBs) processed so far if processing all PDBs 
  # using a single instance
  my %singleInstProcdPDBs;

  for (my $pdbIdx = 0; $pdbIdx <= $#newPDBs; $pdbIdx++) {
    # current PDB name
    my $pdbName = $newPDBs[$pdbIdx];

    if (!$useMultipleInstances) {
      # if processing will utilize a single instance, determine whether the 
      # $pdbName has been [determined to be] opened in the requested mode 
      # during an ealier invocation of this function or has been seen earlier 
      # during the current invocation, in which case we can skip to the next 
      # entry. If not, we will need to check the mode in which it is currently 
      # open to see if it needs to be opened in the requested mode during 
      # this invocation.  
      #
      # Furthermore, if $pdbName is an App PDB whose App Root has not been 
      # [determined to be] opened in the requested mode during an ealier 
      # invocation of this function and has not been seen earlier during the 
      # current invocation, we will need to check the mode in which it is 
      # currently open to see if it needs to be opened in the requested 
      # mode during this invocation. 
      my $ret = 
        single_inst_need_pdb_mode_check($pdbName, \%singleInstProcdPDBs, 
                                        $pdbsOpenInReqMode, $appRootCloneInfo,
                                        $appPdbInfo); 
      if ($ret == SINGLE_INST_NEED_PDB_MODE_CHECK_NONE) {
        # $pdbName does not need to be processed
        log_msg_debug("Skip checking if PDB $pdbName is open in the ".
                      "requested mode");
        next;
      } elsif ($ret == SINGLE_INST_NEED_PDB_MODE_CHECK_APP_ROOT) {
        my $appRootToCheck = $appPdbInfo->{$pdbName};

  log_msg_debug <<msg;
Will check whether the App Root $appRootToCheck is open in the 
    requested mode before checking the App PDB $pdbName
msg

        if (verify_pdb_mode($appRootToCheck, $reqMode, $revertPdbModes, 
                            $dfltInstName, $connString, $doneCmd, 
                            $doneFileNamePrefix, $sqlplus, 
                            $useMultipleInstances, \%pdbsOpenInUpgradeMode)) {
          log_msg_error("unexpected error in verify_pdb_mode(App Root PDB ".
                        "$appRootToCheck)");
          return (1, undef);
        }
      } else {
        log_msg_debug(" Will check whether PDB $pdbName is open in the ".
                      "requested mode");
      }
    }
    
    if (verify_pdb_mode($pdbName, $reqMode, $revertPdbModes, $dfltInstName, 
                        $connString, $doneCmd, $doneFileNamePrefix, $sqlplus, 
                        $useMultipleInstances, \%pdbsOpenInUpgradeMode)) {
      log_msg_error("unexpected error in verify_pdb_mode(PDB $pdbName)");
      return (1, undef);
    }
  }

  # if there are no PDBs whose mode needs to be reset, we are done
  if (!%$revertPdbModes) {
    log_msg_debug("no PDB modes need changing ... returning.");

    # we need to update the hash of PDBs which are known to be opened in the 
    # requested mode.  If using multiple instances, %$revertPdbModes will 
    # never be empty because we populkate it regard,less of the mode in which 
    # PDBs in @newPDBs are currently olpen, so it must be case that PDBs will 
    # be procesed using a single instance
    if ($useMultipleInstances) {
      log_msg_error("revertPdbModes was left empty even though PDBs were to ".
                    "be processed using muptiple instances");
      return (1, undef);
    }

    # if processing PDBs using a single instance, %singleInstProcdPDBs 
    # represents all PDBs which have been determined to be already open 
    # in the desired mode, including App Roots to which any App Root Clones 
    # in @newPDBs belonged
    @$pdbsOpenInReqMode{keys %singleInstProcdPDBs} = 
      values %singleInstProcdPDBs;

    return (-1, undef);
  }

  pdb_mode_hash_dump($revertPdbModes, "force_pdb_modes", "revertPdbModes");

  log_msg_debug("constructing hash to reset PDB modes");

  # next we use contents of %$revertPdbModes to construct a hash which will 
  # be passed to reset_pdb_modes() to reopen in required mode all PDBs that 
  # need to be so reopened.
  #
  # To that end, we will examine every entry in %$revertPdbModes and populate
  # hash mapping instance name to an array of PDB names
  #
  # When we finish processing %$revertPdbModes, we will construct a hash 
  # that looks like $catcon_RevertUserPdbModes (but has a single entry - 
  # specifying the requested mode) and pass it to reset_pdb_modes

  # will be populated with inst => PDB array entries as we traverse 
  # %$revertPdbModes
  my %instToPdbMap;

  # (mode, restricted) pairs of PDBs whose mode needs to be changed
  my @modesAndRestr = sort keys %$revertPdbModes;

  log_msg_debug("(mode, restricted) pairs of PDBs whose mode ".
                "needs to be changed: ".join(', ', @modesAndRestr));

  foreach my $modeAndRestr (@modesAndRestr) {
    log_msg_debug("processing (mode, restricted) pair: $modeAndRestr");

    # instances and PDBs on those instances whose mode needs to be reset
    my $instToPdbMapRef = $revertPdbModes->{$modeAndRestr};

    my @instances = sort keys %$instToPdbMapRef;

    log_msg_debug("instances on which some PDBs are opened ".
                  "$modeAndRestr: ".join(', ', @instances));

    foreach my $inst (@instances) {
      log_msg_debug("processing PDBs on instance $inst");

      my $pdbsToConsider = $instToPdbMapRef->{$inst};

      log_msg_debug("pdbs from instToPdbMapRef ".
                    "whose mode may need to be changed on instance $inst:\n\t".
                    join("\n\t", @{$pdbsToConsider}));

      # PDBs whose mode will need to be reset; will be set to 
      # @$pdbsToConsider minus <PDBs represented in %pdbsOpenInUpgradeMode>
      my @pdbsToReopen;

      if (%pdbsOpenInUpgradeMode) {
        # if some PDBs were open in UPGRADE mode and we decided to leave them
        # alone, before we try to add PDB names found in @$pdbsToConsider to 
        # @$pdbsRef, make sure none of them are already open in UPGRADE 
        # mode or have been previously added to $instToPdbMap on some 
        # instance and so should not be reopened on this instance

        if ($reqMode == CATCON_PDB_MODE_UPGRADE) {
          log_msg_debug("opening PDBs in $reqModeString mode;");
        } else {
          log_msg_debug("opening PDBs in $reqModeString ".
                        "mode, but some PDBs will be left in UPGRADE mode;");
        }

        log_msg_debug("check if any PDBs in pdbsToConsider should NOT have ".
                      "their mode reset");

        # names of PDBs which should not be reopened on this instance; will 
        # be set to PDBs that both are in @$pdbsToConsider and have entries 
        # in %pdbsOpenInUpgradeMode
        my @pdbsNotToReopen = 
          grep {exists $pdbsOpenInUpgradeMode{$_}} @$pdbsToConsider;

        if ($#pdbsNotToReopen >= 0) {
          # at least some of the PDBs in @$pdbsToConsider should not be 
          # reopened
          if ($#pdbsNotToReopen == $#$pdbsToConsider) {
            log_msg_debug <<msg;
all PDBs in pdbsToConsider are open for UPGRADE - no PDBs 
    need to be reopened in instance $inst
msg

            next; # move on to the next instance
          } else {
            @pdbsToReopen = 
              grep {! exists $pdbsOpenInUpgradeMode{$_}} @$pdbsToConsider;

            log_msg_debug("some PDBs\n\t(".
                          join("\n\t", @pdbsNotToReopen).")\n".
                          "in pdbsToConsider are open for UPGRADE;\n".
                          "remaining PDBs\n\t(".
                          join("\n\t", @pdbsToReopen).")\n". 
                          "need to be reopened in instance $inst");
          }
        } else {
          log_msg_debug("no PDBs from pdbsToConsider are ".
                        " open in UPGRADE mode, so PDBs\n\t(".
                        join("\n\t", @{$pdbsToConsider}).")\n". 
                        "will be reopened");

          @pdbsToReopen = @$pdbsToConsider;
        }
      } else {
        log_msg_debug("no PDBs are open in UPGRADE mode, ".
                      "so all PDBs\n\t(".join("\n\t", @{$pdbsToConsider}).
                      ")\nwill be reopened");

        @pdbsToReopen = @$pdbsToConsider;
      }

      if (exists $instToPdbMap{$inst}) {
        log_msg_debug("instToPdbMap contains an entry for ".
                      "inst=$inst");

        # add list of PDBs from $revertPdbModes to the list in %instToPdbMap
        my $pdbsRef = $instToPdbMap{$inst};
        log_msg_debug("pdbs in instToPdbMap entry:\n\t".
                      join("\n\t", @{$pdbsRef}));

        push(@$pdbsRef, @pdbsToReopen);

        log_msg_debug("resulting pdbs in instToPdbMap entry:\n\t".
                      join("\n\t", @{$pdbsRef}));
      } else {
        log_msg_debug("pdbs from pdbsToReopen\n\t(".
                      join("\n\t", @pdbsToReopen).")\nwill be assigned ".
                      "to instToPdbMap{$inst}");

        $instToPdbMap{$inst} = \@pdbsToReopen;
      }
    }
  }

  # if all PDBs whose mode we thought needed to be reset were open in UPGRADE 
  # mode in the default instance, there is no need to call reset_pdb_modes - 
  # we are done
  if (!%instToPdbMap) {
    log_msg_debug <<msg;
ALL PDBs whose mode we were going to reset to $reqModeString 
    were opened for UPGRADE in the default instance, so no PDB modes need 
    changing after all ... returning.
msg

    # we need to update the hash of PDBs which are known to be opened in the 
    # requested mode

    if ($useMultipleInstances) {
      # If processing PDBs using multiple instances, @newPDBs represents all 
      # PDBs which had been discovered to be open in the acceptable mode and 
      # not needing to be reopened during the current invocation
      %$pdbsOpenInReqMode = (%$pdbsOpenInReqMode, map {($_, 1)} @newPDBs);
    } else {
      # if processing PDBs using a single instance, %singleInstProcdPDBs 
      # represents all PDBs which have been discovered to be already open 
      # in the acceptable mode and not needing to be reopened, including 
      # App Roots to which any App Root Clones in @newPDBs belonged
      
      @$pdbsOpenInReqMode{keys %singleInstProcdPDBs} = 
        values %singleInstProcdPDBs;
    }

    return (-1, undef);
  }

  # this hash will be used to map (mode.' '.0) to a reference to a hash 
  # mapping instance names to a reference to array of names of PDBs on these 
  # instances whose [PDBs'] mode needs to be reset
  my %resetPdbModes;
  
  my $ret;

  if ($useMultipleInstances) {
    # Bug 20193612: if we will be processing PDBs using multiple RAC 
    # instances, we need to first close all PDBs on all Instances where they 
    # are open and then open them evenly across the available instances
    $resetPdbModes{CATCON_PDB_MODE_MOUNTED.' '.0} = \%instToPdbMap;

    log_msg_debug("processing PDBs using multiple instances; ".
                  "first, all PDBs will be closed");
    log_msg_debug("calling reset_pdb_modes");

    # close all PDBs

    # Bug 18011217: append _catcon_$logFileSuffix to 
    # $logFilePathBase to avoid conflicts with other catcon 
    # processes running on the same host
    $ret = 
      reset_pdb_modes($connString, \%resetPdbModes, $doneCmd, 
                      $doneFileNamePrefix, 
                      $oracleScript, $dbmsVersion, 0, $dfltInstName,
                      $InstConnStrMap_ref, $sqlplus, $appRootCloneInfo, 0);

    # we do not expect reset_pdb_modes to return 2 because we did not try to 
    # open any PDBs
    if ($ret == 1) {
      log_msg_error("unexpected error reported by reset_pdb_modes");
      return (1, undef);
    }

    # if we will be processing PDBs using multiple instances, and there are 
    # more PDBs to be processed (in a subsequent invocation), we will avoid 
    # opening PDBs during this invocation because they will need to be closed 
    # and reopened during the subsequent invocation
    if ($MorePdbs) {
      log_msg_debug("having closed specified PDBs, delay ".
                    "reopening them\n\tuntil the final invocation of this ".
                    "subroutine");

      # %instToPdbMap needs to be undefined to let the caller know that 
      # PDBs specified by the caller were not really open
      undef %instToPdbMap;

      # Note that by jumping to this label we temporarily cause 
      # %$pdbsOpenInReqMode and %$isConOpen to reflect reality that is yet 
      # to happen, i.e. that PDBs represented by @newPDBs have been opened in 
      # the requested mode.  The reality will catch up once this subroutine is 
      # called to reopen remaining PDBs.
      goto force_pdb_modes_done;
    }

    # delete previously added entry from %resetPdbModes since we will be 
    # calling reset_pdb_modes once more (to open PDBs on available instances), 
    # and we do not want it to try to close them
    delete $resetPdbModes{CATCON_PDB_MODE_MOUNTED.' '.0};

    # next we will purge %instToPdbMap of PDB names for all instances and 
    # then distribute PDBs across instances taking into consideration number 
    # of processes allocated for every instance

    log_msg_debug("remove PDB names from instToPdbMap");

    foreach my $inst (sort keys %instToPdbMap) {
      $#{$instToPdbMap{$inst}} = -1;
      log_msg_debug("\tclear PDBs associated with instance $inst ".
                    "from instToPdbMap");
    }
    
    # it is possible that some (but definitely not all) entries in
    # %$InstProcMap_ref represent the fact that no processes could be 
    # allocated to an instance. For purposes of assigning PDBs to instances, 
    # it will simplify things greatly if such entries were eliminated before 
    # attempting the assignment.  To that end, we will construct a hash mapping
    # names of instances which have some processes allocated for them to the
    # number of processes allocated to each of these instances
    my %procsOnAvailInst;
    
    foreach my $inst (sort keys %$InstProcMap_ref) {
      if (! exists $InstProcMap_ref->{$inst}->{NUM_PROCS}) {
        log_msg_error("InstProcMap_ref for instance $inst has ".
                      "no NUM_PROCS entry");
        return (1, undef);
      }

      if ($InstProcMap_ref->{$inst}->{NUM_PROCS} > 0) {
        $procsOnAvailInst{$inst} = $InstProcMap_ref->{$inst}->{NUM_PROCS};
      }
    }

    # as we assign PDBs to instances, we want to decrement number of processes 
    # still available for that instance so that instances with fewer processes
    # allocated for them get fewer PDBs assigned to them.  To accomplish this, 
    # we make a copy of %procsOnAvailInst which we can modify without losing
    # info about the number of processes allocated to every open instance
    my %tempInstProcs;
    
    # names of instances for which sqlplus processes have been allocated
    my @instances;

    # index into @instances
    my $instIdx;

    # PDBs that need to be opened belong to a union of key %$pdbsOpenInReqMode 
    # (i.e. PDBs which were open or were discovered to be open in the 
    # requested mode during previous invocation of force_pdb_modes) and 
    # @newPDBs (PDBs which newly specified during this invocation)
    my @pdbsToOpen = sort keys %$pdbsOpenInReqMode;
    push @pdbsToOpen, @newPDBs;

    log_msg_debug("preparing to assign PDBs\n\t(".
                  join("\n\t", @pdbsToOpen).")\nto instances\n\t(".
                  join(', ', (sort keys %procsOnAvailInst)).")");

    foreach my $pdbName (@pdbsToOpen) {
      if (!@instances || $#instances < 0) {
        # there were more PDBs than there were processes started for all 
        # instances, so we need to start another round of assignments of PDBs 
        # to instances
        %tempInstProcs = %procsOnAvailInst;
        @instances = sort keys %procsOnAvailInst;
        $instIdx = 0;

        log_msg_debug("starting a new round of PDB to instance ".
                      "assignments");
      } elsif ($instIdx > $#instances) {
        $instIdx = 0;

        log_msg_debug("reached the end of instance list; ".
                      "starting over");
      }      

      log_msg_debug("instance-to-#-of-processes mapping:");
      foreach my $inst (@instances) {
        log_msg_debug("\t$inst : ".$tempInstProcs{$inst});
      }

      # current instance name
      my $inst = $instances[$instIdx];
 
      log_msg_debug("preparing to assign PDB $pdbName to ".
                    "instance $inst (instIdx = $instIdx)");

      # at this point we expect that $tempInstProcs{$inst} is > 0 (i.e. the 
      # current instance has at least one remaining process allocated for it 
      # which will be available to process the current PDB)
      if (! exists $tempInstProcs{$inst}) {
        log_msg_error("tempInstProcs contains no entry for ".
                      "instance $inst");
        return (1, undef);
      } elsif ($tempInstProcs{$inst} <= 0) {
        log_msg_error("unexpected number of processes (".
                      $tempInstProcs{$inst}.") in tempInstProcs for ".
                      "instance $inst");
        return (1, undef);
      }

      if (exists $instToPdbMap{$inst}) {
        my $pdbsRef = $instToPdbMap{$inst};
        log_msg_debug("instToPdbMap contains an entry for ".
                      "inst=$inst (as expected)");
        log_msg_debug("before adding current PDB, pdbs in ".
                      "instToPdbMap entry for instance $inst:\n\t".
                      join("\n\t", @{$pdbsRef}));

        # add the current PDB to the list of PDBs which will be open on the
        # current instance
        push(@$pdbsRef, $pdbName);

        log_msg_debug("added $pdbName to instToPdbMap entry ".
                      "for instance $inst");
      } else {
        # this is unexpected
        log_msg_error("instToPdbMap did not contain an entry for ".
                      "instance $inst");
        return (1, undef);
      }

      # decrement number of processes available for this instance; if there 
      # are no more processes left for this instance, remove its name from 
      # @instances
      if (!--$tempInstProcs{$inst}) {
        log_msg_debug("no more processes left for instance $inst");

        splice @instances, $instIdx, 1;

        # $instIdx should not be advanced since it is pointing to the 
        # instance name (if any) following the one to which we have just 
        # assigned the PDB 
      } else {
        $instIdx++;

        if ($instIdx <= $#instances) {
          log_msg_debug("advancing to instance ".
                        $instances[$instIdx]." (instIdx = $instIdx)");
        }
      }
    }
  }
  
  $resetPdbModes{$reqMode.' '.0} = \%instToPdbMap;

  log_msg_debug("calling reset_pdb_modes");

  # finally reset PDB mode(s)

  # Bug 18011217: append _catcon_$logFileSuffix to 
  # $logFilePathBase to avoid conflicts with other catcon 
  # processes running on the same host
  $ret = 
    reset_pdb_modes($connString, \%resetPdbModes, $doneCmd, 
                    $doneFileNamePrefix, 
                    $oracleScript, $dbmsVersion, 
                    !$useMultipleInstances, $dfltInstName,
                    $InstConnStrMap_ref, $sqlplus, $appRootCloneInfo, 1);

  # bug 23106360: reset_pdb_modes may return 
  # - 1 if an error was encountered, 
  # - 2 if it could not reopen PDB(s) in requested mode because it 
  #     would be incompatible with the mode in which CDB is open, and
  # - 0 if everything appears to have gone well
  #
  # to make it possible for DBUA to work with no changes against a 
  # standby CDB, we will not treat 2 as an error (but we will remember 
  # that we did not change PDB(s)' mode, and so we do not need to 
  # revert it before exiting catcon)
  if ($ret == 1) {
    log_msg_error("unexpected error reported by reset_pdb_modes");
    return (1, undef);
  }

force_pdb_modes_done:

  if ($ret == 0) {
    log_msg_verbose("reset_pdb_modes completed successfully");

    # we need to update the hash of PDBs which we have successfully processed 
    # and the hash of PDBs which are known to be opened
    if ($useMultipleInstances) {
      # If processing PDBs using multiple instances, @newPDBs represents all 
      # PDBs which have been opened in the desired mode (or were discovered 
      # to be opened in the acceptable mode)
      %$pdbsOpenInReqMode = (%$pdbsOpenInReqMode, map {($_, 1)} @newPDBs);
      %$isConOpen = (%$isConOpen, map {($_, "Y")} @newPDBs);
    } else {
      # If processing PDBs using a single instance, %singleInstProcdPDBs 
      # represents all PDBs which were discoverd to be open in the desired 
      # (or, at least, acceptable) mode or have been opened in the desired 
      # mode, including App Roots to which any App Root Clones in @newPDBs 
      # belonged
      @$pdbsOpenInReqMode{keys %singleInstProcdPDBs} = 
        values %singleInstProcdPDBs;
      @$isConOpen{keys %singleInstProcdPDBs} = 
        ("Y") x (scalar values %singleInstProcdPDBs);
    }
  } else {
    log_msg_verbose <<msg;
reset_pdb_modes could not change PDB modes to $reqModeString 
    mode because it would conflict with the mode in which the CDB is open
msg
  }

  log_msg_debug("returning: ret = $ret");
  inst_pdbs_hash_dump(\%instToPdbMap, "force_pdb_modes", "instToPdbMap");

  return ($ret, \%instToPdbMap);
}

#
# exec_reset_pdb_mode_stmts - execute an array of statements to change mode of 
#                             one or more PDBs
#
# Parameters:
#   Stmts - reference to an array of statements to execute
#   DoneCmd - a command to create a file whose existence will indicate that the
#     last statement of the script has executed (needed by exec_DB_script())
#     (IN)
#   DoneFilePathBase - base for a name of a "done" file (see above) (IN)
#   sqlplus - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used (IN)
#
# Returns:
#   0 if statements appear to have executed successfully; 1 otherwise
#
sub exec_reset_pdb_mode_stmts($$$$) {
  my ($Stmts, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  # temporarily reset $SIG{INT} to avoid dying while PDB$SEED is in transition
  my $saveIntHandlerRef = $SIG{INT};
  
  $SIG{INT} = \&handle_sigint_for_pdb_mode;

  log_msg_debug("temporarily reset SIGINT handler");

  my ($ignoreOutputRef, $spoolRef) = 
    exec_DB_script(@$Stmts, undef, $DoneCmd, $DoneFilePathBase, $sqlplus);

  print_exec_DB_script_output("exec_reset_pdb_mode_stmts", $spoolRef, 0);

  # 
  # restore INT signal handler 
  #
  $SIG{INT} = $saveIntHandlerRef;

  log_msg_debug("restored SIGINT handler");

  # check if any errors were reported when executing SQL statements 
  # assembled above
  log_msg_debug("examine spool array returned by exec_DB_script ".
                "to determine if it contains any error messages");

  for my $spoolLine (@$spoolRef) {
    # look for lines reporting an error message other than ORA-65020 which 
    # gets issued if a PDB we are trying to close is already closed, which 
    # we can ignore (because if running against a 12.1 CDB we cannot specify 
    # FORCE in ALTER PDB CLOSE)
    if ($spoolLine =~ "^ORA-[0-9]" && $spoolLine !~ "^ORA-65020") {
      log_msg_error("error reported while attempting to ".
                    "reset PDB modes:");
      log_msg_error("  output produced by ALTER PDB statements:");

      for my $errLine (@$spoolRef) {
        log_msg_error("\t$errLine");
      }

      return 1;
    }
  }

  return 0;
}

# 
# get_inst_conn_string - generate a connect string for connecting to a 
#                        specified instance
#
# parameters:
#   connStr - user-supplied connect string
#   InstConnStrMap_ref - a reference to a hash mapping instance names to 
#     connect strings
#   inst - name of the instance to which we need to connect
#
sub get_inst_conn_string($$$) {
  my ($connStr, $InstConnStrMap_ref, $inst) = @_;
  
  if (using_OS_authentication($connStr)) {
    # if using OS authentication, just return the connect string since we 
    # cannot make use of instance-specific connect string
    return $connStr;
  }

  my $numInstances = scalar keys %$InstConnStrMap_ref;

  # Bug 25366291: in some cases %$InstConnStrMap_ref may be left undefined, 
  #   in which case all processing will occur on the default instance
  if ($numInstances <= 1) {
    # if a DB is running on one instance, just return the connect string since 
    # we need not use instance-specific connect string
    return $connStr;
  }

  my $asAdmin;
          
  # if the caller-supplied connect string includes AS <admin-role>, we need 
  # to strip it off before adding an instance-specific connect string 
  # and then add it back on
  if ($connStr =~ /AS (SYS.*)/i) {
    $asAdmin = $1;
    $connStr =~ s/AS $asAdmin//ig;
  }
  
  # append instance-specific connect string
  $connStr .= "@".$InstConnStrMap_ref->{$inst};
  
  # append AS <admin-role> if we stripped it above
  if ($asAdmin) {
    $connStr .= " AS $asAdmin"; 
  }
  
  return $connStr;
}

#
# replace_app_root_clones - replace names of App Root Clones (if any) in the 
#   supplied array with corresponding App Roots, eliminate duplicates (if any),
#   and return the resulting list
#
# Description:
#   List of PDBs may include App Root Clones which should not be opened or 
#   closed directly; instead, a corresponding App Root should be closed or 
#   opened.  In addition, it is possible for the list of PDBs associated 
#   with a given instance to include more than one App Root Clone 
#   associated with a given App Root or one or more App Root Clones and an 
#   App Root to which they belong.  
#
#   All such entries need to be collapsed into a single entry representing 
#   the App Root.  To that end, we will scan the list of PDBs associated 
#   with a given instance, replace references to App Root Clones with 
#   corresponding App Roots and add them to a hash to eliminate duplicates.  
#   Keys of that hash will then be returned to the caller to ensure that we 
#   close or open a correct set of PDBs
#
# parameters:
#   $appRootCloneInfo (IN) -
#     reference to a hash mapping names of App Root Clones (if any) to names 
#     of their App Roots
#   $pdbs (IN) -
#     reference to an array of PDB names which may contain App Root Clones
#
# Returns:
#   reference to the resulting array of PDB names
#
sub replace_app_root_clones($$) {
  my ($appRootCloneInfo, $pdbs) = @_;
  
  log_msg_debug("will examine PDBs (".join(", ", @$pdbs).")\n".
                "  to determine if any of them are App Root Clones that\n".
                "  need to be replaced with corresponding App Roots");

  my $numAppRootClones = 0;

  if ($appRootCloneInfo) {
    # list of PDBs may include App Root Clones, so we need to map any 
    # such PDBs into corresponding App Roots and eliminate any duplicates

    my %pdbHash;

    log_msg_debug("will map App Root Clones (if any) into ".
                  "corresponding App Roots and eliminate duplicates");

    foreach my $pdb (@$pdbs) {
      if ($appRootCloneInfo && (exists $appRootCloneInfo->{$pdb})) {
        # $pdb is an App Root Clone - add name of the corresponding 
        # App Root to the hash
        log_msg_debug("replacing App Root Clone ($pdb) with its ".
                      "App Root ($appRootCloneInfo->{$pdb}})");
        $pdbHash{$appRootCloneInfo->{$pdb}} = 1;

        $numAppRootClones++;
      } else {
        # add $pdb to the hash
        log_msg_debug("adding $pdb to the hash");
        $pdbHash{$pdb} = 1;
      }
    }

    if ($numAppRootClones > 0) {
      my @pdbNames = keys %pdbHash;

      log_msg_debug("$numAppRootClones App Root Clones were replaced; ".
                    "returning list of PDBs (".
                    join(", ", @pdbNames).") to the caller");
      return \@pdbNames;
    } else {
      log_msg_debug("no App Root Clones were found; returning original list ".
                    "of PDBs to the caller");
    }
  } else {
    log_msg_debug("CDB contains no App Root Clones; returning original list ".
                  "of PDBs to the caller");
  }

  # list of PDBs did not (or could not) include any App Root Clones, so 
  # return $pdbs to the caller
  return $pdbs;
}

#
# reset_pdb_modes - close specified PDBs on all instances and reopen them in 
#                   specified modes on specified instances.
#
# parameters:
#   $myConnect (IN) - 
#     reference to an array of internal connect strings - [0] used to connect 
#     to a DB, [1] can be used to produce diagnostic message
#   $pdbModeHashRef (IN) - 
#     reference to a (mode.' '. restricted) => ref {instance-name => 
#     ref @pdb-names} hash describing PDBs whose mode needs to be reset
#   $DoneCmd (IN) - 
#     a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   $DoneFilePathBase (IN) - 
#     base for a name of a "done" file (see above)
#   $OracleScript (IN) - 
#     indicator of whether _ORACLE_SCRPT needs to be set before (and cleared 
#     after) resetting PDB mode(s)
#   $dbmsVersion (IN) - 
#     RDBMS version; used to ensure that SQL statements that we generate are 
#     compatible with the version of the RDBMS to which we are connected
#   $openUsingDfltInst (IN) - 
#     indicator of whether PDBs should be opened using the default instance;
#     will cause this function to open PDBs without specifying the 
#     INSTANCES-clause; 
#     will be used if opening PDBs for running scripts if the user did not 
#     instruct us to use all available instances or if there is only one 
#     instance to be had
#   $dfltInstName (IN) -
#     name of the default instance; this argument serves 2 purposes:
#     - when reset_pdb_modes is called from force_pdb_modes (before we ran any 
#       scripts), the caller is expected to supply us with the name of the 
#       default instance, and we will avoid attempting to reopen any PDBs 
#       which were not open in the desired mode on instances other than the 
#       default instance 
#     - when called at wrapup time, the caller will tell us to reopen PDBs on 
#       all instances on which they were not open in the desired mode and 
#       pass undef as the default instance name to communicate to us that 
#       PDBs which were not open in the desired mode should definitely be 
#       reopened on all instances (short-circuiting code that may decide to 
#       ignore the caller's request to NOT restrict opening PDBs to just the
#       default instance if we could not determine connect strings 
#       corresponding to all instances; this actually makes a lot of sense: 
#         if we discover that we do not have connect strings for other 
#         instances before running scripts, we will not be able to utilize 
#         other instances to run them, so there is no reason to open PDBs on 
#         other instances; however, at wrapup time, inability to determine 
#         connect strings for all instances does not matter - since we closed 
#         PDBs on other instances before running scripts, we unconditionally 
#         need to reopen them on those instances at wrapup) (IN)
#   $InstConnStrMap_ref (IN) - 
#     a reference to a hash mapping instance names to instance connect strings 
#   $sqlplus (IN) - 
#     "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#   $appRootCloneInfo (IN) -
#     reference to a hash mapping names of App Root Clones (if any) to names 
#     of their App Roots; since App Root Clones inherit their mode from their 
#     App Roots, whenever we need to close or open an App Root Clone, we will 
#     operate on its App Root instead
#   $openPdbsWithNoSvcs (IN) -
#     an indicator of whether PDBs that need to be opened in the specified 
#     mode should be open without starting any services
#
# returns:
# - 0 if it appears that all went well
# - 1 if an error was encountered
# - 2 if PDB(s) could not be opened in the requested mode (which would have 
#     to be something other that READ ONLY) because the CDB is open READ ONLY 
#     (bug 23106360)
#
# Bug 14248297: close PDB$SEED on all RAC instances. If the PDB$SEED is to be
# opened on all instances, then the 'seedMode' argument must specify it.
#
sub reset_pdb_modes($$$$$$$$$$$$) {
  my ($myConnect, $pdbModeHashRef, $DoneCmd, $DoneFilePathBase, $OracleScript, 
      $dbmsVersion, $openUsingDfltInst, $dfltInstName, $InstConnStrMap_ref, 
      $sqlplus, $appRootCloneInfo, $openPdbsWithNoSvcs) = @_;
  
  pdb_mode_hash_dump($pdbModeHashRef, "reset_pdb_modes", "pdbModeHashRef");

  # %$pdbModeHashRef is keyed on (mode.' '. restricted)
  my @modeInfoArr = sort keys %$pdbModeHashRef;

  # used to remember if we were called to close all PDBs
  my $closingAllPdbs = 1;

  # if asked to open some PDB(s) to a mode other than READ ONLY, make sure 
  # the CDB itself is not open READ ONLY
  foreach my $modeInfo (@modeInfoArr) {
    my @modeAndRestr = split(' ', $modeInfo);
    my $pdbMode = $modeAndRestr[0];

    if ($closingAllPdbs && $pdbMode != CATCON_PDB_MODE_MOUNTED) {
      $closingAllPdbs = 0;
    }

    if ($pdbMode == CATCON_PDB_MODE_MOUNTED) {
      log_msg_debug("processing pdbModeHashRef entry for PDBs ".
                    "which need to be closed");
    } else {
      my $modeString = PDB_MODE_CONST_TO_STRING->{$pdbMode};
      my $restrString = 
        ($modeAndRestr[1] == 0) ? "unrestricted" : "restricted";

      log_msg_debug("processing pdbModeHashRef entry for PDBs ".
                    "which need to be reopened $modeString $restrString");
    }

    if ($pdbMode != CATCON_PDB_MODE_MOUNTED && 
        $pdbMode != CATCON_PDB_MODE_READ_ONLY) {

      log_msg_debug("call get_CDB_open_mode to determine if ".
                    "the PDB(s) may be opened in desired mode");

      my $cdbOpenMode = 
        get_CDB_open_mode(@$myConnect, $DoneCmd, $DoneFilePathBase, $sqlplus);

      if (!(defined $cdbOpenMode)) {
        log_msg_error("unexpected error in get_CDB_open_mode");
        return 1;
      }

      if ($cdbOpenMode eq 'READ ONLY') {
        log_msg_warn("PDBs cannot be opened in ".
                     PDB_MODE_CONST_TO_STRING->{$pdbMode}.
                     " mode because the CDB is open READ ONLY");
        return 2;
      }

      # if we got here, the CDB must be open READ WRITE/UPGRADE, so we 
      # passed the check and there is no reason to process the rest of 
      # entries (if any) in @modeInfoArr
      if ($#modeInfoArr) {
        log_msg_debug("CDB is open in $cdbOpenMode mode which ".
                      "will satisfy all remaining pdbModeHashRef entries");
      }

      last;
    }
  }

  # Bug 25061922: remember if we are connected to a 12.1 CDB
  my $cdb_12_1 = ($dbmsVersion =~ "^12.1") ? 1 : 0;
  my $cdb_12_1_0_1 = $cdb_12_1 && ($dbmsVersion =~ "^12.1.0.1");

  # if a 12.1 CDB is running on just one instance, we do not need to use an 
  # instance-specific connect string to connect to the DB
  #
  # NOTE: Bug 25366291: in some cases %$InstConnStrMap_ref may be left 
  #   undefined, in which case we will force all processing to occur on the 
  #   default instance
  my $numInstConnStrings = scalar keys %$InstConnStrMap_ref;

  # if caller wants us to use "/ AS SYSDBA" to connect to a 12.1 CDB running 
  # on multiple RAC instances, we cannot use instance-specific connect 
  # strings and will resort to using INSTANCES=ALL in ALTER PDB CLOSE 
  # statements
  my $usingOsAuthentication = ($myConnect->[0] eq '/ AS SYSDBA');

  # if running against a post-12.1 CDB or a 12.1 CDB running on a single
  # instance or the connect string supplied by the caller relies on OS 
  # authentication (/ AS SYSDBA), start constructing a set of statements to be 
  # executed. 
  #
  # Otherwise, connect statement will need to use an instance-specific 
  # connect string for every instance and so will be constructed in 
  # the loop that iterates over instances
  my @ResetPdbModeStatements;
  
  if (!$cdb_12_1 || $numInstConnStrings <= 1 || $usingOsAuthentication) {

    log_msg_debug("setting first statements in ResetPdbModeStatements for\n".
                  "\tPDBs open on all instances because");
    if (!$cdb_12_1) {
      log_msg_debug("\twe are connected to a post-12.1 CDB");
    } elsif ($numInstConnStrings == 1) {
      log_msg_debug("\tCDB is open on only one instance");
    } elsif ($numInstConnStrings == 0) {
      log_msg_debug("\tinstance connect strings could not be fetched, so ".
                    "all\nprocessing will occur on the default instance");
    } else {
      log_msg_debug("\tuser-supplied connect string relies on OS ".
                    "authentication");
    }

    @ResetPdbModeStatements = ("connect ".$myConnect->[0]."\n");
    log_msg_debug("added\n\tconnect ".$myConnect->[1]);

    # if changing PDB mode requires that _oracle_script be set, do it
    if ($OracleScript) {
      push @ResetPdbModeStatements, 
        qq#alter session set "_oracle_script"=TRUE\n/\n#;

      log_msg_debug("added\n\t$ResetPdbModeStatements[1]");
    }
  }
  
  # Bugs 25132308, 25117295: if connected to a 12.1* CDB, we will be 
  #   generating a separate script for PDBs connected to every instance 
  #   (except when opening PDBs if we were instructed to open them all on the 
  #   default instance), and each of them will need to start with connect, 
  #   optionally followed by ALTER SESSION SET "_ORACLE_SCRIPT"... which we 
  #   will store in this array
  my @firstStmts_12_1;

  if ($cdb_12_1) {
    # save statements with which a script closing or opening PDBs on a 
    # given instance needs to start, assuming we added some statements to 
    # @ResetPdbModeStatements; otherwise, we will be generating connect 
    # statement, and possibly ALTER SESSION SET "_oracle_script" for every 
    # instance on which a 12.1 CDB is running and to which we need to connect 
    if (@ResetPdbModeStatements) {
      @firstStmts_12_1  = @ResetPdbModeStatements;
      
      log_msg_debug("copied ResetPdbModeStatements to firstStmts_12_1");
    }

    log_msg_debug("processing PDBs in a ".
                  ($cdb_12_1_0_1 ? "12.1.0.1" : "12.1.0.2")." CDB");
  }

  # first we need to generate statements to close specified PDBs on all 
  # specified instances
  log_msg_debug("generate statements to close specified PDBs on ".
                "all specified instances:");

  foreach my $modeInfo (@modeInfoArr) {
    # instances and PDBs on those instances whose mode needs to be reset
    my $instToPdbMapRef = $pdbModeHashRef->{$modeInfo};
    my @instances = sort keys %$instToPdbMapRef;

    foreach my $inst (@instances) {
      if ($#{$instToPdbMapRef->{$inst}} == -1) {
        log_msg_debug("  no PDBs to close on instance $inst - skip it");

        next;
      }

      log_msg_debug("closing PDBs on instance $inst");

      if ($cdb_12_1) {
        log_msg_debug("  for ".($cdb_12_1_0_1 ? "12.1.0.1" : "12.1.0.2")." :");

        if (!@firstStmts_12_1) {
          # need to generate a connect statement using an instance-specific 
          # connect string and possibly set _oracle_script
          
          my $instConnStr = 
            get_inst_conn_string($myConnect->[0], $InstConnStrMap_ref, $inst);

          my $instConnStrDbg = 
            get_inst_conn_string($myConnect->[1], $InstConnStrMap_ref, 
                                 $inst);
          
          log_msg_debug("    will connect as $instConnStrDbg");

          @ResetPdbModeStatements = ("connect ".$instConnStr."\n",);

          # if changing PDB mode requires that _oracle_script be set, do it
          if ($OracleScript) {
            push @ResetPdbModeStatements, 
              qq#alter session set "_oracle_script"=TRUE\n/\n#;

            log_msg_debug("    and set _oracle_script");
          }
        }
      }

      # Bugs 25132308, 25117295: in 12.1.0.1, FORCE cannot be specified with 
      #   ALTER PDB CLOSE and in 12.1.0.2 it cannot be specified with 
      #   multiple instances.  To address these issues (and to simplify code),
      #   I will modify code dealing with 12.1* CDB to
      #     - not use the INSTANCES clause at all and 
      #     - if connected to a 12.1.0.1 CDB, to not specify FORCE
      #   Instead, if connected to a 12.1* CDB, I collect statements 
      #   pertaining to PDBs that need to be closed on a given instance and 
      #   execute them against that instance (by connecting to the DB using a 
      #   connect string corresponding to $inst - fix for bug 25315864) 
      #   rather than assembling statements closing PDBs across all instances.
      #
      #   In addition, rather than issuing a single ALTER PDB statement for 
      #   all PDBs on a given instance, we will issue a separate ALTER PDB 
      #   statement for every PDB because this will 
      #     - ensure that if one of 12.1.0.1 PDBs is already closed, the rest 
      #       of PDBs will not be affected by the error and
      #     - prevent us from generating an overly long statement if 
      #       there are lots of PDBs that need to be closed
      #
      # NOTE: fix for bugs 25132308 and 25117295 pretty much replaces changes 
      #       made to address bug 25061922

      # Bug 25315864: if the caller supplied "/ AS SYSDBA" as the connect 
      #               string, we cannot use instance-specific connect strings 
      #               to connect to individual instances. In such cases, we 
      #               will connect to the default instance and add 
      #               INSTANCES=ALL to ALTER PDB CLOSE statements (which is 
      #               what we used to do in reset_seed_pdb_mode)

      # Bug 26527096: replace references, if any, to App Root Clones in the 
      #   array of PDBs associated with this instance with their App Roots 
      #   and eliminate duplicates, if any
      my $pdbsToClose = 
        replace_app_root_clones($appRootCloneInfo, 
                                \@{$instToPdbMapRef->{$inst}});

      foreach my $pdb (@$pdbsToClose) {
        # need to issue ALTER PDB CLOSE IMMEDIATE regardless of whether we 
        # are connected to a 12.1* CDB
        my $stmt = "alter pluggable database $pdb close immediate";
        
        if ($cdb_12_1) {
          # if connected to a 12.1 RAC CDB running on multiple instances and 
          # the connect string specified by the caller relies on OS 
          # authentication, add INSTANCES=ALL
          #
          # Bug 25366291: ditto if we failed to obtain instance connect strings
          if (($numInstConnStrings > 1 && $usingOsAuthentication) ||
              $numInstConnStrings == 0) {
            $stmt .= " instances = all";
          } elsif (!$cdb_12_1_0_1) {
            # unless we are connected to a 12.1.0.1 CDB (where 
            # ALTER PDB CLOSE FORCE is not supported) OR we had to add 
            # INSTANCES=ALL above (in 12.1.0.2 specifying FORCE when
            # closing a PDB on multiple instances results in a confusing 
            # ORA-65145), add FORCE
            $stmt .= " force";
          }

          $stmt .= "\n/\n";
        } else {
          # for post 12.1 CDBs, we will specify both FORCE and 
          # INSTANCES-clause and execute ALTER PDB statements for all 
          # instances as one script
          $stmt .= " force instances=('$inst')\n/\n";
        }
        
        push @ResetPdbModeStatements, $stmt;

        log_msg_debug("\t$stmt");
      }

      # if operating against a 12.1.* CDB, statements in 
      # @ResetPdbModeStatements need to be run against instance $inst
      if ($cdb_12_1) {
        log_msg_debug("execute statements to close PDBs on ".
                      "instance $inst of a 12.1 CDB");

        if (exec_reset_pdb_mode_stmts(\@ResetPdbModeStatements, $DoneCmd, 
              $DoneFilePathBase."_close_".$inst."_pdbs", $sqlplus)) {
          log_msg_error("unexpected error in exec_reset_pdb_mode_stmts");
          return 1;
        }
        
        # having executed statements to close PDBs on this instance, set 
        # @ResetPdbModeStatements to @firstStmts_12_1 for the next series of 
        # statements to close or open PDBs (and if statements to connect to 
        # the CDB and possibly set _oracle_script have to be generated anew 
        # for every instance, this simply undefines @ResetPdbModeStatements, 
        # preparing it for the next series)
        @ResetPdbModeStatements = @firstStmts_12_1;
      }
    }
  }

  if ($closingAllPdbs) {
    log_msg_debug("called to close all specified PDBs\n".
                  "\tskip code trying to generate statements to reopen PDBs");

    goto issueResetPdbModesStmts;
  }

  # Bug 25366291: if instance connect strings could not be obtained, all PDBs 
  #     will be open using the default instance, unless we are being called 
  #     at wrapup time (which would be signalled by $dfltInstName being set 
  #     to undef), in which case inability to obtain connect strings for all 
  #     instances should not preclude us from reopening PDBs which were 
  #     closed on those instances
  if ($numInstConnStrings == 0 && !$openUsingDfltInst && $dfltInstName) {
    $openUsingDfltInst = 1;

    log_msg_debug("instance connect strings are not available, ".
                  "so all PDBs\n".
                  "\twill be opened on the default instance, even though\n".
                  "\tthe caller has not requested it");
  }

  # this hash will be used to keep track of 
  # - PDBs for which we have already generated statements to open them in 
  #   UPGRADE mode so as to avoid trying to open them in that mode on any 
  #   other instance (because a PDB can be open in UPGRADE mode on only 1 
  #   instance)
  # - PDBs for which we have already generated statements to open them in the 
  #   default instance if the caller has instructed us to do so, so as to 
  #   avoid issuing multiple ALTER PDB OPEN statements for the same PDB on 
  #   the default instance
  my %pdbsAlreadyOpen;

  # next, generate statements to open all specified PDBs in desired mode on 
  # specified instances
  log_msg_debug("generate statements to open specified PDBs in ".
                "desired modes on specified instances:");

  # if connected to a 12.1 CDB and 
  # - the user-supplied connect string relies on OS authentication or 
  # - we were told to open PDBs using the default instance
  # all ALTER PDB OPEN statements will be executed as a part of one script 
  # which means that the initial statements (CONNECT and possibly 
  # ALTER SESSION SET _oracle_script) need to be generated only once, before 
  # we start generating ALTER PDB OPEN statements. 
  #
  # If @firstStmts_12_1 is defined (as would be the case if the user-supplied 
  # connect string relies on OS authentication), these initial statements have 
  # already been added to @ResetPdbModeStatements above; otherwise, we need 
  # to do it now
  if ($cdb_12_1 && !@firstStmts_12_1 && $openUsingDfltInst) {
    log_msg_debug("setting first statements in ".
                  "ResetPdbModeStatements for\n".
                  "\topening PDBs using the default instance of a ".
                  ($cdb_12_1_0_1 ? "12.1.0.1" : "12.1.0.2")." CDB:");

    @ResetPdbModeStatements = ("connect ".$myConnect->[0]."\n",);

    log_msg_debug("  will connect as ".$myConnect->[1]);

    # if changing PDB mode requires that _oracle_script be set, do it
    if ($OracleScript) {
      push @ResetPdbModeStatements, 
        qq#alter session set "_oracle_script"=TRUE\n/\n#;

      log_msg_debug("  and set _oracle_script");
    }
  }

  foreach my $modeInfo (@modeInfoArr) {
    my @modeAndRestr = split(' ', $modeInfo);
    my $pdbMode  = $modeAndRestr[0];
    my $restr = $modeAndRestr[1];
    my $modeString = PDB_MODE_CONST_TO_STRING->{$pdbMode};
    my $restrString = ($restr) ? " restricted" : "";

    log_msg_debug("\tPDBs which need to be opened $modeString $restrString -");

    # if this entry indicates that PDBs are to be closed, they have already 
    # been closed, so we can skip this entry
    if ($pdbMode == CATCON_PDB_MODE_MOUNTED) {
      next;
    }

    # instances and PDBs on those instances whose mode needs to be reset
    my $instToPdbMapRef = $pdbModeHashRef->{$modeInfo};
    my @instances = sort keys %$instToPdbMapRef;
    foreach my $inst (@instances) {
      if ($#{$instToPdbMapRef->{$inst}} == -1) {
        log_msg_debug("\t  no PDBs to reopen on instance $inst - skip it");
      
        next;
      }

      if ($openUsingDfltInst && $inst ne $dfltInstName) {
        log_msg_debug("\t  PDBs should be reopened only on default instance\n".
                      "\t  $dfltInstName - skip PDBs which were not open in ".
                      "the\n".
                      "\t  desired mode on instance $inst\n");
      
        next;
      }

      if ($cdb_12_1) {
        log_msg_debug("  for ".($cdb_12_1_0_1 ? "12.1.0.1" : "12.1.0.2").
                      " instance $inst:");
        
        # if a 12.1 CDB is open on multiple instances and the connect string 
        # supplied by the caller does not rely on OS authentication, 
        # @firstStmts_12_1 will not be defined since while we were closing 
        # PDBs, we needed to generate CONNECT statements using 
        # instance-specific connect strings.  During the opening stage, the 
        # same reasoning applies, unless we were told to open PDBs using the 
        # default instance
        if (!@firstStmts_12_1 && !$openUsingDfltInst) {
          my @instConnStr;

          # need to generate a connect statement using an instance-specific 
          # connect string
          $instConnStr[0] = 
            get_inst_conn_string($myConnect->[0], $InstConnStrMap_ref, $inst);

          $instConnStr[1] = 
            get_inst_conn_string($myConnect->[1], $InstConnStrMap_ref, 
                                 $inst);

          @ResetPdbModeStatements = ("connect ".$instConnStr[0]."\n",);

          log_msg_debug("    will connect as ".$instConnStr[1]);

          # if changing PDB mode requires that _oracle_script be set, do it
          if ($OracleScript) {
            push @ResetPdbModeStatements, 
              qq#alter session set "_oracle_script"=TRUE\n/\n#;

            log_msg_debug("    and set _oracle_script");
          }
        }
      }

      my @pdbsToOpen;

      if ($openUsingDfltInst || $pdbMode == CATCON_PDB_MODE_UPGRADE ||
         ($cdb_12_1 && $usingOsAuthentication)) {
        # determine if any of the PDBs that should be open only once (because 
        # - we were instructed to open all PDBs on the default instance or 
        # - we are opening them for UPGRADE or 
        # - we are connected to a 12.1 CDB and the user-supplied connect 
        #   string relies on OS authentication, so we cannot connect to a 
        #   specific RAC instance) 
        # have already been opened
        my @newPDBs = 
          grep {! exists $pdbsAlreadyOpen{$_}} @{$instToPdbMapRef->{$inst}};

        if ($#newPDBs < 0) {
          # no new PDBs to open

          my $msg = "all PDBs (".
                    join(',', @{$instToPdbMapRef->{$inst}}).")\n".
                    "\tcorresponding to instance $inst have ".
                    "already been opened ";

          if ($pdbMode == CATCON_PDB_MODE_UPGRADE) {
            $msg .= "in UPGRADE mode";
          } elsif ($openUsingDfltInst) {
            $msg .= "on the default instance";
          } else {
            $msg .= "in a 12.1 CDB using OS authentication";
          }

          log_msg_debug($msg);

          next;
        } else {
          # generate diagnostic info
          if ($#newPDBs < $#{$instToPdbMapRef->{$inst}}) {
            my @alreadyOpened = grep {! exists $pdbsAlreadyOpen{$_}} 
              @{$instToPdbMapRef->{$inst}};

            my $msg = "of PDBs (".
                      join(',', @{$instToPdbMapRef->{$inst}}).")\n".
                      "\tcorresponding to instance $inst, some ( ".
                      join(',', @alreadyOpened).")\n".
                      "\thave already been opened ";

            if ($pdbMode == CATCON_PDB_MODE_UPGRADE) {
              $msg .= "in UPGRADE mode";
            } elsif ($openUsingDfltInst) {
              $msg .="on the default instance";
            } else {
              $msg .="in a 12.1 CDB using OS authentication";
            }

            log_msg_debug($msg."\n\tso only (". join(',', @newPDBs).
                          ") will be opened");
          } else {
            my $msg = "of PDBs (".
                      join(',', @{$instToPdbMapRef->{$inst}}).")\n".
                      "\tcorresponding to instance $inst, none have already ".
                      "been opened ";

            if ($pdbMode == CATCON_PDB_MODE_UPGRADE) {
              $msg .="in UPGRADE mode";
            } elsif ($openUsingDfltInst) {
              $msg .= "on the default instance";
            } else {
              $msg .= "in a 12.1 CDB using OS authentication";
            }

            log_msg_debug($msg." so all will need to be opened");
          }
        }

        @pdbsToOpen = @newPDBs;

        # remember that PDBs listed in @newPDBs should not be opened again
        %pdbsAlreadyOpen = (%pdbsAlreadyOpen, map {($_, 1)} @newPDBs);
      } else {
        @pdbsToOpen = @{$instToPdbMapRef->{$inst}};
      }

      # Rather than issuing a single ALTER PDB statement for 
      # all PDBs on a given instance, we will issue a separate ALTER PDB 
      # statement for every PDB because this will prevent us from generating 
      # an overly long statement if there are lots of PDBs that need to be 
      # opened
      #
      # Bug 25392172: Even though we computed the array of names of PDBs that 
      #   needed to be open, we were still iterating over 
      #   @{$instToPdbMapRef->{$inst}} rather than @pdbsToOpen.  As a result, 
      #   even though we knew that we have already opened a PDB for UPGRADE 
      #   in another instance (so its name would have been added to 
      #   %pdbsAlreadyOpen after it was open in that other instance and would 
      #   not be included in @pdbsToOpen for this instance), it was 
      #   theoretically possible that we would attempt to open it for UPGRADE 
      #   again.

      # Bug 26527096: replace references, if any, to App Root Clones in the 
      #   array of PDBs associated with this instance with their App Roots 
      #   and eliminate duplicates, if any
      my $pdbs = replace_app_root_clones($appRootCloneInfo, \@pdbsToOpen);

      foreach my $pdb (@$pdbs) {
        # need to issue ALTER PDB OPEN <mode> [restricted] regardless of 
        # whether we are operating against a 12.1* CDB
        my $stmt = "alter pluggable database $pdb open ".
          PDB_MODE_CONST_TO_STRING->{$pdbMode}.$restrString;
        
        # if we were instructed to open PDBs on the default instance, do not 
        # specify INSTANCES-clause
        #
        # Bug 25061922: ditto if connected to a 12.1 CDB, where a bug 
        #   precludes us from specifying instance names
        if (!$openUsingDfltInst && !$cdb_12_1) {
          $stmt .= " instances=('$inst')";
        }

        # if the caller requested that the PDBs be open without starting any
        # services, add a clause to convey that
        # NOTE: because of the way code that parses ALTER PDB statement is 
        #       written, "services" clause" must follow "instances" clause, 
        #       if any
        if ($openPdbsWithNoSvcs) {
          $stmt .= " services=NONE\n/\n";
        } else {
          $stmt .= "\n/\n";
        }

        push @ResetPdbModeStatements, $stmt;

        log_msg_debug("\t\t$stmt");
      }

      # Bug 25061922, 25315864: if 
      #   - connected to a 12.1 CDB and 
      #   - we were not instructed to open all PDBs on the default instance, 
      #     and
      #   - the user-supplied connect string does not rely on OS authentication
      #     (so we can connect to a specific RAC instance)
      #   we will execute statements pertaining to PDBs that need to be 
      #   opened on a given instance and execute them against that instance 
      #   (which was assured when we constructed a CONNET statement using an 
      #   instance-specific connect string) rather than assembling statements 
      #   opening PDBs across all instances.  
      if ($cdb_12_1 && !$openUsingDfltInst && !$usingOsAuthentication) {
        log_msg_debug("execute statements to open PDBs on ".
                      "instance $inst of a 12.1 CDB");

        if (exec_reset_pdb_mode_stmts(\@ResetPdbModeStatements, $DoneCmd, 
              $DoneFilePathBase."_open_".$inst."_pdbs", $sqlplus)) {
          log_msg_error("unexpected error in ".
                        "exec_reset_pdb_mode_stmts");
          return 1;
        }
        
        # having executed statements to open PDBs on this instance, set 
        # to @firstStmts_12_1 for the next series of statements to open PDBs
        # (and if statements to connect to the CDB and possibly set 
        # _oracle_script have to be generated anew for every instance, this 
        # simply undefines @ResetPdbModeStatements, preparing it for the next 
        # series)
        @ResetPdbModeStatements = @firstStmts_12_1;
      }
    }
  }

issueResetPdbModesStmts:

  # NOTE: if 
  #       - operating against a 12.1 CDB and 
  #       - we were not instructed to open PDBs on the default instance and 
  #       - the user-supplied connect string does  not rely on OS 
  #         authentication (so we can connect to a specific RAC instance), 
  #       statements to open PDBs have already  been executed; otherwise, we 
  #       execute them now
  if ((!$cdb_12_1 || $openUsingDfltInst || $usingOsAuthentication) && 
      exec_reset_pdb_mode_stmts(\@ResetPdbModeStatements, $DoneCmd, 
                                $DoneFilePathBase, $sqlplus)) {
    log_msg_error("unexpected error in exec_reset_pdb_mode_stmts");
    return 1;
  }

  return 0;
}

#
# shutdown_db - shutdown the database in specified mode
#
# parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - shutdown mode
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
sub shutdown_db (\@$$$$) {
  my ($myConnect, $shutdownMode, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @ShutdownStatements = (
    "connect ".$myConnect->[0]."\n",
    "SHUTDOWN $shutdownMode\n",
  );

  exec_DB_script(@ShutdownStatements, undef, $DoneCmd, 
                 $DoneFilePathBase, $sqlplus);
}

#
# kill_sqlplus_sessions - kill all SQL*Plus sessions started by us
#
# parameters:
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - name of the "kill all sessions script"
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
sub kill_sqlplus_sessions (\@$$$$) {
  my ($myConnect, $killSessScript, $DoneCmd, $DoneFilePathBase, $sqlplus) = @_;

  my @KillSessionsStatements = (
    "connect ".$myConnect->[0]."\n",
    "set echo on\n",
    "@@".$killSessScript."\n",
  );

  my ($ignoreOutputRef, $spoolRef) = 
    exec_DB_script(@KillSessionsStatements, undef, $DoneCmd, 
                   $DoneFilePathBase, $sqlplus);

  print_exec_DB_script_output("kill_sqlplus_sessions", $spoolRef, 0);
}

# validate_script_path
#
# Parameters:
#   $FileName - name of file to validate
#   $Dir      - directory, if any, in which the file is expected to be found
#   $Windows  - an indicator of whether we are running under Windows
#   $IgnoreValidErr - if TRUE, validation errors will be reported but ignored
#
# Description:
#   construct file's path using its name and optional directory and determine 
#   if it exists and is readable
#
# Returns:
#   file's path
sub validate_script_path ($$$$) {
  my ($FileName, $Dir, $Windows, $IgnoreValidErr) = @_;

  my $Path;                                    # file path
  my $IgnoredErrors = 0;                       # were any errors ignored
    
  if (!$FileName) {
    log_msg_error("Script name was not supplied");
    return undef;
  }

  log_msg_debug("getting ready to construct path for script $FileName");

  if ($Dir) {
    log_msg_debug("Caller supplied directory ($Dir)");
  }

  # Bug 25396566: prepend directory, if supplied, only if $FileName is a 
  #   simple file name

  my ($vol, $dirStr, $file) = File::Spec->splitpath($FileName);

  if ($dirStr || $vol) {
    log_msg_debug("Script name ($FileName) is not a simple file name");

    if ($Dir) {
      log_msg_debug("Ignoring directory ($Dir) supplied by the caller");
    }

    $Path = $FileName;
  } elsif ($Dir) {
    log_msg_debug <<msg; 
Script name ($FileName) is a simple file name; will construct path 
  by prepending directory name ($Dir) supplied by the caller
msg
    my $canonicDir = File::Spec->canonpath($Dir);
    
    if ($canonicDir ne $Dir) {
      log_msg_debug <<msg;
canonpath turned $Dir to $canonicDir which will be used to 
  construct script path
msg
    }

    # split $canonicDir into volume and directory so we can use catpath to put 
    # together the absolute file path
    my ($dirVol, $dirDirStr) = File::Spec->splitpath($canonicDir, 1);

    $Path = File::Spec->catpath($dirVol, $dirDirStr, $FileName);
  } else {
    my $curDir = File::Spec->curdir();

    log_msg_debug <<msg;
Script name ($FileName) is a simple file name and directory was not 
  supplied. Will look for $FileName in the current directory ($curDir)
msg
    $Path = $FileName;
  }

  log_msg_debug("getting ready to validate script $Path");

  stat($Path);

  if (! -e _ || ! -r _) {
    my $msg = "sqlplus script $Path does not exist or is unreadable";

    if (!$IgnoreValidErr) {
      log_msg_error($msg);
      return undef;
    } else {
      log_msg_warn($msg);
      $IgnoredErrors = 1;
    }
  }

  if (!($IgnoredErrors || -f $Path)) {
    my $msg = "supposed sqlplus script $Path is not a regular file";

    if (!$IgnoreValidErr) {
      log_msg_error($msg);
      return undef;
    } else {
      log_msg_warn($msg);
      $IgnoredErrors = 1;
    }
  }

  if (!$IgnoredErrors) {
    log_msg_debug("successfully validated script $Path");
  } else {
    log_msg_debug("errors encountered and ignored while ".
                  "validating script $Path");
  }

  return $Path;
}

#
# err_logging_tbl_stmt - construct and issue SET ERRORLOGGING ON [TABLE ...]
#                        statement, if any, that needs to be issued to create 
#                        an Error Logging table
#
# parameters:
#   - an indicator of whether to save error logging information, which may be 
#     set to ON to create a default error logging table or to the name of an 
#     existing error logging table (IN)
#   - reference to an array of file handles containing a handle to which to 
#     send SET ERRORLOGGING statement (IN)
#   - process number (IN)
#   - an indicator of whether _oracle_script is set (meaning that 
#     it may need to be temporarily reset in this subroutine) (IN)
#   - name of a Federation Root if it was supplied by the caller of catcon to 
#     indicate that scripts are to be run against Containers comprising a 
#     Federation rooted in that Container; if set, _federation_script may be 
#     set and so needs to be temporarily reset in this subroutine (IN)
#   - an indicator of whether logging level is set to DEBUG (IN)
#
sub err_logging_tbl_stmt ($$$$$$) {
  my ($ErrLogging, $FileHandles_REF, $CurProc, $OracleScriptIsSet, $FedRoot,
      $LogLevelDebug) =  @_;

  # NOTE:
  # I have observed that if you issue 
  #   SET ERRORLOGGING ON IDENTIFIER ...
  # in the current Container after issuing
  #   SET ERRORLOGGING ON [TABLE ...] in a different Container, 
  # the error logging table will not be created in the current 
  # Container.  
  # 
  # To address this issue, I will first issue 
  #   SET ERRORLOGING ON [TABLE <table-name>]
  # and only then issue SET ERRORLOGGING ON [IDENTIFIER ...]
  #
  # If running an Oracle-supplied script, in order to make sure that the 
  # error logging table does not get created as a Metadata Link, I will 
  # temporarily reset 
  # _ORACLE_SCRIPT parameter before issuing 
  #   SET ERRORLOGING ON [TABLE <table-name>]
  #
  # Similarly, in order to make sure that the error logging table does not 
  # get created as a Federation Metadata Link if running a script against 
  # Containers comprising a Federation rooted in a specified Container, I 
  # will temporarily reset _FEDERATION_SCRIPT before issuing 
  #   SET ERRORLOGING ON [TABLE <table-name>]

  my $ErrLoggingStmt;

  if ($ErrLogging) {

    log_msg_debug("ErrLogging = $ErrLogging");

    # if ERRORLOGGING is to be enabled, construct the SET ERRORLOGGING 
    # statement which will be sent to every process
    $ErrLoggingStmt = "SET ERRORLOGGING ON ";

    # Bug 25259127: $ErrLogging should not be quoted because it may specify 
    # owner.table. If a user is concerned about case folding, he needs to 
    # appropriately quote value of the parameter supplied to catcon
    if ((lc $ErrLogging) ne "on") {
      $ErrLoggingStmt .= qq#TABLE $ErrLogging#;
    }

    log_msg_debug <<msg;
ErrLoggingStmt = $ErrLoggingStmt
    temporarily resetting _parameter before issuing 
    SET ERRORLOGGING ON [TABLE ...] in process $CurProc
msg

    # if _ORACLE_SCRIPT is set, 
    #   reset it
    # else if Federation Root name was supplied
    #   _FEDERATION_SCRIPT will be set, so reset it
    if ($OracleScriptIsSet) {
      printToSqlplus("err_logging_tbl_stmt", $FileHandles_REF->[$CurProc],
                     qq#ALTER SESSION SET "_ORACLE_SCRIPT"=FALSE#,
                     "\n/\n", $LogLevelDebug);
    } elsif ($FedRoot){
      printToSqlplus("err_logging_tbl_stmt", $FileHandles_REF->[$CurProc],
                     qq#ALTER SESSION SET "_FEDERATION_SCRIPT"=FALSE#,
                     "\n/\n", $LogLevelDebug);
    }

    # send SET ERRORLOGGING ON [TABLE ...] statement
    log_msg_debug("sending $ErrLoggingStmt to process $CurProc");

    printToSqlplus("err_logging_tbl_stmt", $FileHandles_REF->[$CurProc],
                   $ErrLoggingStmt, "\n", $LogLevelDebug);

    log_msg_debug("setting _parameter after issuing ".
                  "SET ERRORLOGGING ON [TABLE ...] in process $CurProc");

    # if _ORACLE_SCRIPT was set,
    #   restore it
    # else if Federation Root name was supplied
    #   _FEDERATION_SCRIPT was set, so restore it
    if ($OracleScriptIsSet) {
      printToSqlplus("err_logging_tbl_stmt", $FileHandles_REF->[$CurProc],
                     qq#ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE#,
                     "\n/\n", $LogLevelDebug);
    } elsif ($FedRoot){
      printToSqlplus("err_logging_tbl_stmt", $FileHandles_REF->[$CurProc],
                     qq#ALTER SESSION SET "_FEDERATION_SCRIPT"=TRUE#,
                     "\n/\n", $LogLevelDebug);
    }
  }

  return $ErrLoggingStmt;
}

# log_file_name - generate file name for a log which will be populated by a 
#                 given SQL*Plus process
sub log_file_name($$) {
  my ($base, $ps) = @_;

  return $base.$ps.".log";
}

#
# connect_escaping_ampersands - issue a connect statement wrapped in 
#                               SET DEFINE OFF/ON if it contains ampersands
#
# Parameters:
#   $connStr (IN) -
#     connect string
#   $fh (IN) -
#     file handle to which to send statements; may be undefined if the caller 
#     is contructing an array of statements which will then be executed
#   $addConnect (IN) -
#     an indicator of whether the $connStr needs to be preceded by "connect" 
#     keyword because it does not already contain it
#
# Returns:
#   if $fh is undefined, a reference to an array of statements which should 
#     be executed to connect with the specified connect string; undef otherwise
#
sub connect_escaping_ampersands($$$) {
  my ($connStr, $fh, $addConnect) = @_;

  # current statement
  my $stmt; 

  # array of statements a refernce to which will be returned if the file 
  # handle was not supplied
  my @stmts; 

  # does the connect string contain ampersand(s), necessitating wrapping the
  # connect statement in SET DEFINE OFF/ON
  my $ampersandInConnStr = ($connStr =~ /&/);

  if ($ampersandInConnStr) {
    $stmt = "set define off\n";

    if ($fh) {
      print $fh $stmt;
    } else {
      push @stmts, $stmt;
    }
  }

  $stmt = ($addConnect ? "connect " : "").$connStr;

  if ($fh) {
    print $fh $stmt;
  } else {
    push @stmts, $stmt;
  }

  if ($ampersandInConnStr) {
    $stmt = "set define on\n";

    if ($fh) {
      print $fh $stmt;
    } else {
      push @stmts, $stmt;
    }
  }
  
  if ($fh) {
    return undef;
  }

  return \@stmts;
}

# delete_idle_logs - delete log files corresponding to processes that were 
#                    not used to execute any user scripts or statements
#
# NOTE: this subrotine should not be invoked before SQL*Plus processes have 
#       been terminated
sub delete_idle_logs($$$$) {
  my ($numProcs, $fileHandles, $activeProcs, $logFilePathBase) = @_;

  for (my $ps = 0; $ps < $numProcs; $ps++) {
    my $logFileName = log_file_name($logFilePathBase, $ps);
    if (-e $logFileName && ! exists $activeProcs->[$ps]) {
      log_msg_debug <<msg;
Deleting log file $logFileName because SQL*Plus process for which 
  it was created did no work
msg
      sureunlink($logFileName);
    }
  }
}

#
# start_processes - start processes
#
# parameters:
#   - number of processes to start (IN)
#   - base for constructing log file names (IN)
#   - reference to an array of file handles; will be obtained as a 
#     side-effect of calling open() (OUT)
#   - reference to an array of process ids; will be obtained by calls 
#     to open (OUT)
#   - reference to an array of Container names; array will be empty if 
#     we are operating against a non-Consolidated DB (IN)
#   - name of the Root Container; undefined if operating against a non-CDB (IN)
#   - connect string used to connect to a DB (IN)
#   - an indicator of whether SET ECHO ON should be sent to SQL*Plus 
#     process (IN)
#   - an indicator of whether to save ERRORLOGGING information (IN)
#   - logging level (IN)
#   - an indicator of whether processes are being started for the first 
#     time (IN)
#   - an indicator of whether _oracle_script should be set (IN)
#   - name of a Federation Root if called to run scripts against all 
#     Containers comprising a Federation rooted in the specified Container
#   - command used to generate a "done" file
#   - "disable lockdown profile" indicator
#   - index into @$ProcIds of a dead process which is being replaced
#     - -1 if not dealing with a dead process, so $NumProcs processes need to 
#       be started and their ids need to be added to @$ProcIds
#     - otherwise, only one process will be started and its id will be stored 
#       in $ProcIds->[$DeadProc] 
#   - if $DeadProc != -1, id of a process that died unexpectedly and will be 
#     replaced by the process started here; undef (and should not be 
#     referenced) otherwise
#   - name of a script that needs to be invoked to add 
#       ALTER SYSTEM KILL SESSION 
#     statement for every process that we start to the "kill session script" 
#   - "kill all sessions script" name
#   - reference to a hash mapping instance names to a hash representing useful
#     facts aboiut processes associated with it (namely, number of SQL*Plus 
#     processes that will be allocated for that instance) 
#     when processing PDBs using all available instances; 
#
#     this subroutine will add a hash representing an offset into @$ProcIds of 
#     the first sqlplus process created for a given instance (IN/OUT)
#   - reference to a hash mapping ids of sqlplus processes to names of 
#     instances for which they were allocated when processing PDBs 
#     using all available instances; existing entry in this hash will be 
#     used if replacing a dead process; new entries will be added as new 
#     processes are started (IN/OUT)
#   - a reference to a hash mapping instance names to instance connect strings 
#     (IN)
#   - absolute path of sqlplus binary to be used
#
# Returns: 1 if an error is encountered
#
sub start_processes ($$\@\@\@$\@$$$$$$$$$$$$$$$$) {
  my ($NumProcs, $LogFilePathBase, $FileHandles, $ProcIds, $Containers, $Root,
      $ConnectString, $EchoOn, $ErrLogging, $LogLevel, $FirstTime, 
      $SetOracleScript, $FedRoot, $DoneCmd, $DisableLockdown,
      $DeadProc, $DeadProcId, $genKillSessScript, $killAllSessScript,
      $InstProcMap_ref, $ProcInstMap_ref, $InstConnStrMap_ref, $sqlplus) =  @_;

  my $ps;

  my $CurrentContainerQuery = qq#select '==== Current Container = ' || SYS_CONTEXT('USERENV','CON_NAME') || ' Id = ' || SYS_CONTEXT('USERENV','CON_ID') || ' ' || TO_CHAR(SYSTIMESTAMP,'YY-MM-DD HH:MI:SS') || ' ====' AS now_connected_to from sys.dual;\n/\n#;

  # indexes of the first and last elements of @$ProcIds and @$FileHandles 
  # which will be populated with ids of newly started processes and their 
  # correspoinding file handles
  my $FirstProcIdx;
  my $LastProcIdx;

  # if processing PDBs using all available instances, we need to keep track 
  # of the instance for which every process is allocated as well as how many 
  # more processes will be allocated to the current instance
  my @instances;

  # index into @instances of the instance for which sqlplus processes are 
  # being created
  my $currInstIdx;

  # name of the current instance
  my $inst;

  # number of processes yet to be started for the current instance
  my $numProcsForCurrInst;

  # ids of processes allocated for the current instance
  my @procsForCurrInst;
  
  if ($DeadProc == -1) {
    # will start $NumProcs processes
    $FirstProcIdx = 0;
    $LastProcIdx = $NumProcs - 1;

    log_msg_debug("will start $NumProcs processes");
    
    if (%$InstProcMap_ref) {
      log_msg_debug("will create processes for instances used ".
                    "to process PDBs");
      
      @instances = sort keys %$InstProcMap_ref;
      
      log_msg_debug("before any processes were started, contents of\n".
                    "    InstProcMap_ref were:");

      foreach my $inst (sort keys %$InstProcMap_ref) {
        foreach my $k (sort keys %{$InstProcMap_ref->{$inst}}) {
          log_msg_debug("\t$inst => ".
                        "($k => $InstProcMap_ref->{$inst}->{$k})");
        }
      }

      # start with the first instance; it's possible that no processes can be 
      # allocated for it - this will be dealt with before we start creating 
      # processes
      $currInstIdx = 0;
      $inst = $instances[$currInstIdx];
      
      # remember how many processes need to be created for this instance
      $numProcsForCurrInst = $InstProcMap_ref->{$inst}->{MAX_PROCS};

      # remember that no processes have been created for this instance
      $InstProcMap_ref->{$inst}->{NUM_PROCS} = 0;
    
      # remember the offset into @$ProcIds where the id of first process 
      # (if any) for this instance will be stored
      if ($numProcsForCurrInst > 0) {
        $InstProcMap_ref->{$inst}->{FIRST_PROC} = $FirstProcIdx;

        log_msg_debug("will create $numProcsForCurrInst ".
                      "processes for instance $inst\n".
                      "\twith id of the first such process stored at offset ".
                      "$FirstProcIdx in ProcIds");

        log_msg_debug("contents of InstProcMap_ref->{$inst} after ".
                      "FIRST_PROC and NUM_PROCS\n".
                      "    entries have been initialized:");

        foreach my $k (sort keys %{$InstProcMap_ref->{$inst}}) {
          log_msg_debug("\t$inst => ".
                        "($k => $InstProcMap_ref->{$inst}->{$k})");
        }
      } else {
        # if no processes will be created for this instance, there is no need 
        # to have an entry representing offset of the first process created 
        # for it
        delete $InstProcMap_ref->{$inst}->{FIRST_PROC}
          if (exists $InstProcMap_ref->{$inst}->{FIRST_PROC});

        log_msg_debug("will create 0 processes for instance $inst");
      }
    }
  } else {
    # will start only 1 process and store its info in $DeadProc elements of 
    # @$ProcIds and @$FileHandles
    $FirstProcIdx = $LastProcIdx = $DeadProc;

    log_msg_debug("replacing dead process; will start one ".
                  "process and store its id in ProcIds[$DeadProc]");
    
    if (%$InstProcMap_ref) {
      # remember the instance for which the newly dead process was created 
      # (and for which the new process will be started)
      if (! exists $ProcInstMap_ref->{$DeadProcId}) {
        log_msg_error("instance for which the dead process ".
                      "$DeadProcId was allocated is not known");
        return 1;
      }

      $inst = $ProcInstMap_ref->{$DeadProcId};
      log_msg_debug("replacing process $DeadProcId which was ".
                    "created for instance $inst");
      
      # replacing 1 process; this will not affect the offset into @$ProcIds 
      # of the first process allocated for this instance
      $numProcsForCurrInst = 1;
    }
  }

  # 14787047: Save STDOUT so we can restore it after we start each process
  if (!open(SAVED_STDOUT, ">&STDOUT")) {
    log_msg_error("failed to open ($!) SAVED_STDOUT");
    log_msg_error("\tadditional info: $^E");
    return 1;
  }

  # Keep Perl happy and avoid the warning "SAVED_STDOUT used only once"
  print SAVED_STDOUT "";

  # remember whether processes will be running against one or more Containers 
  # of a CDB, starting with the Root
  my $switchIntoRoot = (@$Containers && ($Containers->[0] eq $Root));

  for ($ps=$FirstProcIdx; $ps <= $LastProcIdx; $ps++) {
    # if creating processes for instances used to process PDBs, determine if 
    # there are more processes to be created for the current instance
    if (%$InstProcMap_ref) {
      if ($numProcsForCurrInst > 0) {
        log_msg_debug("$numProcsForCurrInst more processes ".
                      "to be started for instance $inst");
      } else {
        log_msg_debug("no more processes to be started for instance $inst\n".
                      "\twill look for the next instance for which at least ".
                      "one process can be created");

        for ($currInstIdx++; $currInstIdx <= $#instances; $currInstIdx++) {
          $inst = $instances[$currInstIdx];
      
          # remember how many processes need to be created for this instance
          $numProcsForCurrInst = $InstProcMap_ref->{$inst}->{MAX_PROCS};
    
          # remember that no processes have been created for this instance
          $InstProcMap_ref->{$inst}->{NUM_PROCS} = 0;
    
          # remember the offset into @$ProcIds where the id of first process 
          # (if any) for this instance will be stored
          if ($numProcsForCurrInst > 0) {
            $InstProcMap_ref->{$inst}->{FIRST_PROC} = $ps;

            log_msg_debug("will create $numProcsForCurrInst ".
                          "processes for instance $inst\n".
                          "\twith id of the first such process stored at ".
                          "offset $ps in ProcIds");

            log_msg_debug("contents of InstProcMap_ref->{$inst} after ".
                          "FIRST_PROC and NUM_PROCS\n".
                          "    entries have been initialized:");

            foreach my $k (sort keys %{$InstProcMap_ref->{$inst}}) {
              log_msg_debug("\t$inst => ".
                            "($k => $InstProcMap_ref->{$inst}->{$k})");
            }

            last;
          } else {
            # if no processes will be created for this instance, there is no 
            # need to have an entry representing offset of the first process 
            # created for it
            delete $InstProcMap_ref->{$inst}->{FIRST_PROC}
              if (exists $InstProcMap_ref->{$inst}->{FIRST_PROC});
            
            log_msg_debug("no processes to be created for instance $inst");
          }
        }

        if ($currInstIdx > $#instances) {
          # there appears to be a mismatch between the number of processes 
          # that the caller requested to start and the number of processes 
          # allocated to RAC instances
          log_msg_error("number of processes (".
                        ($LastProcIdx - $FirstProcIdx + 1).") requested by\n".
                        "\tthe caller exceeds the number of processes ".
                        "allocated to all available instances.");
          return 1;
        }
      }
    }

    my $LogFile = log_file_name($LogFilePathBase, $ps);

    # If starting for the first time, open for write; otherwise append
    if ($FirstTime) {
      if (!sysopen(STDOUT, $LogFile, O_CREAT | O_RDWR | O_TRUNC, 0600)) {
        log_msg_error("failed to open ($!) STDOUT (1)");
        log_msg_error("\tadditional info: $^E");
        return 1;
      }
    } else {
      close (STDOUT);
      if (!sysopen(STDOUT, $LogFile, O_CREAT | O_RDWR | O_APPEND, 0600)) {
        log_msg_error("failed to open ($!) STDOUT (2)");
        log_msg_error("\tadditional info: $^E");
        return 1;
      }
    }

    my $id = open ($FileHandles->[$ps], "|-", "$sqlplus /nolog");

    if (!$id) {
      log_msg_error("failed to open ($!) pipe to SQL*Plus");
      log_msg_error("\tadditional info: $^E");
      return 1;
    }

    # file handle for the current process
    my $fh = $FileHandles->[$ps];

    # if creating new processes, add new process id to @$ProcIds
    # otherwise, if creating a new process to replace a process that died 
    # unexpectedly, store the new process' id in the slot that used to be 
    # occupied by the dead process
    if ($DeadProc == -1) {
      push(@$ProcIds, $id);

      log_msg_debug("process $ps (id = $ProcIds->[$#$ProcIds]) ".
                    "will use log file $LogFile");
    } else {
      # before we replace dead process' id with the id of the newly started 
      # process, ensure that information about the process which died and is
      # being replaced gets recorded in the process' log file
      print $fh "prompt\n";
      print $fh "prompt WARNING: process $DeadProcId has died unexpectedly\n";
      print $fh "prompt          and was replaced with process $id\n";
      print $fh "prompt\n";
      $ProcIds->[$DeadProc] = $id;

      log_msg_debug("process $ps (id = $id) which will replace newly dead ".
                    "process $DeadProcId will use log file $LogFile");
    }
    
    # connect string passed to CONNECT statement
    my $connStr;

    # if processing PDBs using all available instances, decrement number 
    # of processes yet to be created for the current instance and update 
    # %$ProcInstMap_ref to indicate an instance for which this process 
    # was created
    if (%$InstProcMap_ref) {
      $numProcsForCurrInst--;

      # if replacing a dead process, remove mapping for its id from 
      # %$ProcInstMap_ref
      if ($DeadProc != -1) {
        delete $ProcInstMap_ref->{$DeadProcId};
      } else {
        # increment number of processes started for $inst
        $InstProcMap_ref->{$inst}->{NUM_PROCS}++;
      }

      $ProcInstMap_ref->{$id} = $inst;

      # apply an instance-specific connect string to the user-specified 
      # connect string
      $connStr = 
        get_inst_conn_string($ConnectString->[0], $InstConnStrMap_ref, $inst);
    } else {
      # otherwise, use user-specified connect string
      $connStr = $ConnectString->[0];
    }

    # send initial commands to the sqlplus session
    
    # LRG 20238914: if password contains 1 or more ampersands, issue 
    #   SET DEFINE OFF before connect and SET DEFINE ON after connect to avoid 
    #   having sqlplus interpret what follows & as the substitution string
    connect_escaping_ampersands($connStr."\n", $fh, 1);

    {
      my $connStrDbg;

      if (%$InstProcMap_ref) {
        $connStrDbg = 
          get_inst_conn_string($ConnectString->[1], $InstConnStrMap_ref, 
                               $inst);
      } else {
        $connStrDbg = $ConnectString->[1];
      }

      log_msg_debug(qq#connected using $connStrDbg#);
    }

    # use ALTER SESSION SET APPLICATION MODULE/ACTION to identify this process
    printToSqlplus("start_processes", $fh,
                   qq#ALTER SESSION SET APPLICATION MODULE = 'catcon(pid=$PID)'#,
                   "\n/\n", $LogLevel == &CATCON_LOG_LEVEL_DEBUG);

    log_msg_debug("issued ALTER SESSION SET APPLICATION MODULE = ".
                  "'catcon(pid=$PID)'");

    printToSqlplus("start_processes", $fh,
                   qq#ALTER SESSION SET APPLICATION ACTION = 'started'#,
                   "\n/\n", $LogLevel == &CATCON_LOG_LEVEL_DEBUG);

    log_msg_debug("issued ALTER SESSION SET APPLICATION ACTION = 'started'");

    # bug 21871308: create a "kill session script" for this process which will 
    # contain ALTER SYSTEM KILL SESSION statement to gracefully bring down 
    # this process
    my $killSessScript = kill_session_script_name($LogFilePathBase, $ps);

    printToSqlplus("start_processes", $fh, 
                   "@@".$genKillSessScript." ".$killSessScript." ".$id, 
                   "\n", $LogLevel == &CATCON_LOG_LEVEL_DEBUG);

    log_msg_debug("created a kill_session script (".
                  $killSessScript.") for this process");

    if ($EchoOn) {
      printToSqlplus("start_processes", $fh, qq#SET ECHO ON#, "\n", 
                     $LogLevel == &CATCON_LOG_LEVEL_DEBUG);

      log_msg_debug("SET ECHO ON has been issued");
    }
    
    # if running scripts against one or more Containers of a Consolidated 
    # Database, 
    # - if the Root is among Containers against which scripts will 
    #   be run (in which case it will be found in $Containers->[0]), switch 
    #   into it (because code in catconExec() expects that to be the case); 
    #   if scripts will not be run against the Root, there is no need to 
    #   switch into any specific Container - catconExec will handle that case 
    #   just fine all by itself
    # - turn on the "secret" parameter to ensure correct behaviour 
    #   of DDL statements; it is important that we do it after we issue 
    #   SET ERRORLOGGING ON to avoid creating error logging table as a 
    #   Common Table
    if (@$Containers) {
      if ($switchIntoRoot) {
        printToSqlplus("start_processes", $fh, 
                       qq#ALTER SESSION SET CONTAINER = $Root#, "\n/\n", 
                       $LogLevel == &CATCON_LOG_LEVEL_DEBUG);
        log_msg_debug(qq#switched into Container $Root#);
      }
      
      # if told to set _oracle_script
      #   set it now
      # else if Federation Root name was supplied
      #   _FEDERATION_SCRIPT needs to be set
      if ($SetOracleScript) {
        printToSqlplus("start_processes", $fh, 
                       qq#ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE#, "\n/\n", 
                       $LogLevel == &CATCON_LOG_LEVEL_DEBUG);

        log_msg_debug("_oracle_script was set");
      } elsif ($FedRoot) {
        printToSqlplus("start_processes", $fh, 
                       qq#ALTER SESSION SET "_FEDERATION_SCRIPT"=TRUE#, 
                       "\n/\n", $LogLevel == &CATCON_LOG_LEVEL_DEBUG);

        log_msg_debug("_federation_script was set");
      }

      if ($DisableLockdown) {
        printToSqlplus("start_processes", $fh, 
                       qq#ALTER SESSION SET PDB_LOCKDOWN=''#, 
                       "\n/\n", $LogLevel == &CATCON_LOG_LEVEL_DEBUG);
        log_msg_debug("pdb_lockdown was disabled");
      }
    }

    $fh->flush;
  }

  # we created a "kill session" script for every process we spawned to avoid 
  # possibiliy of contention between processes that were spawned.  Now that 
  # they have all been spawned, we are ready to coalesce them into a single 
  # "kill all sessions" script

  # open the "kill all sessions" script
  my $killAllSessFh;
  if (!open ($killAllSessFh,"+>>", "$killAllSessScript")) {
    log_msg_error("failed to open ($!) kill_all_sessions script (".
                  $killAllSessScript.")");
    log_msg_error("\tadditional info: $^E");
    return 1;
  }

  for ($ps=$FirstProcIdx; $ps <= $LastProcIdx; $ps++) {
    # open next "kill session" script
    my $killSessScript = kill_session_script_name($LogFilePathBase, $ps);
    my $killSessFh = openSpoolFile($killSessScript);
    if (!$killSessFh) {
      log_msg_warn("failed to open ($!) kill_session script (".
                   $killSessScript.")");
      # in some cases the spool file takes too long to materialize.  We cannot 
      # wait forever, and aborting processing seems too harsh, so we will 
      # settle for a warning message in the log file
      next;
    }
    
    print $killAllSessFh $_ while <$killSessFh>;

    close ($killSessFh);

    log_msg_debug("appended ".$killSessScript." to ".$killAllSessScript);

    # having concatenated this "kill session script", delete it
    sureunlink($killSessScript);

    log_msg_debug("deleted ".$killSessScript);
  }

  close($killAllSessFh);
      
  if (!open ($killAllSessFh,"<", "$killAllSessScript")) {
    log_msg_error("failed to open ($!) kill_all_sessions script ".
                  "(".$killAllSessScript.")");
    log_msg_error("\tadditional info: $^E");
    return 1;
  }

  log_msg_debug("contents of kill_all_sessions script(".
                $killAllSessScript."): {");

  log_msg_debug("\t".$_) while <$killAllSessFh>;

  log_msg_debug("}");

  close($killAllSessFh);

  # 14787047: Restore saved stdout
  close (STDOUT);
  open (STDOUT, ">&SAVED_STDOUT");

  return create_done_files($FirstProcIdx, $LastProcIdx, $LogFilePathBase,
                           $FileHandles, $ProcIds, 
                           $LogLevel, $DoneCmd);
}

#
# done_file_name_prefix - generate prefix of a name for a "done" file using 
#                         file name base and the id of a process to which 
#                         the "done" file belongs
#
sub done_file_name_prefix($$) {
    my ($FilePathBase, $ProcId) =  @_;

  return $FilePathBase."_catcon_".$ProcId;
}

#
# done_file_name - generate name for a "done" file using file name base 
#                  and the id of a process to which the "done" dile belongs
#
sub done_file_name($$) {
    my ($FilePathBase, $ProcId) =  @_;

  return done_file_name_prefix($FilePathBase, $ProcId).".done";
}

#
# proc_log_file_name - generate name of a log file that will be used by a 
#                      catcon process
# Parameters:
#   $filePathBase (IN) - 
#     log file base
#
sub proc_log_file_name($) {
    my ($filePathBase) =  @_;

  return $filePathBase."_catcon_".$$.".lst";
}

#
# child_log_dir - generate name of a directory where child process log files 
#   will be stored and create it if it does not already exist
#
# Parameters:
#   $filePathBase (IN) - 
#     log file base
#
sub child_log_dir($) {
  my ($filePathBase) =  @_;

  # first we need to obtain the directory path from $filePathBase
  my ($vol,$dirStr,$file) = File::Spec->splitpath($filePathBase);

  # directory names comprising $dirStr
  my @dirs = File::Spec->splitdir($dirStr);
    
  # child process logs will be created in child_logs subdirectory of $dirStr
  push @dirs, "child_logs";

  # name of a directory where child process log files will be created
  my $childLogDir = File::Spec->catdir(@dirs);
    
  log_msg_debug("child process log files will be created in directory ".
                $childLogDir);
    
  log_msg_debug("ensure that the child process log directory exists");

  stat($childLogDir);

  if (! -e _) {
    log_msg_debug("child process log directory needs to be created");
        
    if (!mkdir($childLogDir)) {
      log_msg_error("unable to create ($!) child process log directory ".
                    $childLogDir);

      return undef;
    }

    log_msg_debug("child process log directory successfully created");
  } elsif (! -d _) {
    log_msg_error("$childLogDir already exists but is not a directory");
    return undef;
  } else {
    log_msg_debug("child process log directory already exists");
  }

  return $childLogDir;
}

#
# child_log_file_name - generate name of a log file that will be used by a 
#                       child process forked in catconExec
# Parameters:
#   $logDir (IN) - 
#     directory where child process log files will be created
#   $pdbToUpgrade (IN) -
#     name of a PDB being upgraded when upgrading PDBs of a RAC CDB using 
#     all available instances; expected to contain an empty string otherwise
#   $childPID (IN) -
#     PID of child process
#
sub child_log_file_name($$$) {
  my ($logDir, $pdbToUpgrade, $childPID) =  @_;

  # name of log file
  my $logFileName = "${pdbToUpgrade}_catcon_${childPID}.lst";

  return File::Spec->catfile(File::Spec->splitdir($logDir), $logFileName);
}

#
# child_done_file_name - generate name of a file that will be used by a 
#                        child process forked in catconExec to communicate to 
#                        the parent that it is done
#
sub child_done_file_name($$) {
    my ($FilePathBase, $ChildPid) =  @_;

  return $FilePathBase."_catcon_".$ChildPid.".done";
}

#
# kill_session_script_name - generate name for a "kill session script" which 
#                            will be run if we need to gracefully terminate 
#                            SQL*Plus processes in the course of handling 
#                            SIGINT/SIGTERM/SIGQUIT (bug 21871308)
#
sub kill_session_script_name($$) {
  my ($FilePathBase, $ProcIdx) =  @_;

  return $FilePathBase."_catcon_kill_sess_".$$."_".$ProcIdx.".sql";
}

#
# create_done_files - Creates "done" files to be created for all processes.
#                     next_proc() will look for these files to determine
#                     whether a given process is available to take on the
#                     next script or SQL statement
#
# parameters:
#   - index of the first element of @$ProcIds_REF "done" files for which need 
#     to be created (IN)
#   - index of the last element of @$ProcIds_REF "done" files for which need 
#     to be created (IN)
#   - base for constructing log file names (IN)
#   - reference to an array of file handles (IN)
#   - reference to an array of process ids (IN)
#   - logging level (IN)
#   - Done Command (IN)
#
sub create_done_files ($$$$$$$) {

    my ($FirstProcIdx, $LastProcIdx, $LogFilePathBase, $FileHandles_REF, 
        $ProcIds_REF, $LogLevel, $DoneCmd) =  @_;

    # Loop through processors
    for (my $CurProc = $FirstProcIdx; $CurProc <= $LastProcIdx; $CurProc++) {
      
      # file which will indicate that process $CurProc finished its work and 
      # is ready for more
      #
      # Bug 18011217: append _catcon_$ProcIds_REF->[$CurProc] to 
      # $LogFilePathBase to avoid conflicts with other catcon processes 
      # running on the same host
      my $DoneFile = 
        done_file_name($LogFilePathBase, $ProcIds_REF->[$CurProc]);

      # create a "done" file unless it already exists
      if (! -e $DoneFile) {
        # "done" file does not exist - cause it to be created
        printToSqlplus("create_done_files", $FileHandles_REF->[$CurProc],
                       qq/$DoneCmd $DoneFile/, "\n", 
                       $LogLevel == &CATCON_LOG_LEVEL_DEBUG);

        # flush the file so a subsequent test for file existence does 
        # not fail due to buffering
        $FileHandles_REF->[$CurProc]->flush;

        log_msg_debug <<msg;
sent "$DoneCmd $DoneFile"
    to process $CurProc (id = $ProcIds_REF->[$CurProc]) to indicate its 
    availability
msg
      } elsif (! -f $DoneFile) {
        log_msg_error(qq#"done" file name collision:#.$DoneFile);
        return 1;
      } else {
        log_msg_debug(qq#"done" file $DoneFile already exists#);
      }
    }
    return 0;
}

#
# end_processes - end process(es)
#
# parameters:
#   - index of the first process to end (IN)
#   - index of the last process to end (IN)
#   - reference to an array of file handles (IN)
#   - reference to an array of process ids; will be cleared of its 
#     elements (OUT)
#   - an indicator of whether logging level is set to DEBUG (IN)
#   - log file path base
#   - index into @$ProcIds of a dead process which is being replaced
#     - -1 if not dealing with a dead process, so all processes between 
#       $FirstProcIdx and $LastProcIdx will be ended and their entries in 
#       @$ProcIds will be deleted
#     - otherwise, only the process whose id is in $ProcIds->[$DeadProc] will 
#       be "ended" and its spot in @$ProcIds will be retained, albeit reset 
#       to -1
#   - reference to a hash mapping instance names to a hash representing useful
#     facts aboiut processes associated with it (namely, number of SQL*Plus 
#     processes that will be allocated for that instance and an offset into 
#     @$ProcIds of the first sqlplus process allocated to a given instance
#     when processing PDBs using all available instances; 
#
#     if all processes associated with a given instance are ended, the entry 
#     reprsenting ofset of the first process created or that instance will be 
#     deleted (IN/OUT)
#   - reference to a hash mapping ids of sqlplus processes to names of 
#     instances for which they were allocated;
#
#     entries mapping ids of processes that we "end" to instances for which 
#     they were created will be deleted (IN/OUT)
#
sub end_processes ($$\@\@$$$$$) {
  my ($FirstProcIdx, $LastProcIdx, $FileHandles, $ProcIds, $LogLevelDebug,
      $LogFilePathBase, $DeadProc,
      $InstProcMap_ref, $ProcInstMap_ref) =  @_;

  my $ps;

  if ($DeadProc != -1) {
    # we were called to "end" a process which apepars to have died 
    # unexpectedly, so we only need to handle that process
    $FirstProcIdx = $LastProcIdx = $DeadProc;
  }

  if ($FirstProcIdx < 0) {
    log_msg_error("FirstProcIdx ($FirstProcIdx) was less than 0");
    return 1;
  }

  if ($LastProcIdx < $FirstProcIdx) {
    log_msg_error("LastProcIdx ($LastProcIdx) was less than ".
                  "FirstProcIdx ($FirstProcIdx)");
    return 1;
  }

  if ($DeadProc == -1) {
    log_msg_debug("will end processes $FirstProcIdx to $LastProcIdx");
  } else {
    log_msg_debug("will end dead process $DeadProc ".
                  "(id=$ProcIds->[$DeadProc])");
  }

  for ($ps = $FirstProcIdx; $ps <= $LastProcIdx; $ps++) {
    if ($FileHandles->[$ps]) {
      # LRG 19650060: if the caller didn't tell us that the process is dead,
      #               check if it is really alive since end_processes may be 
      #               called to end processes after some process was found to 
      #               be dead and the caller did not instruct us to recover 
      #               from SQL*Plus process failure
      my $procAlive;

      if ($DeadProc != -1) {
        $procAlive = 0;
      } else {
        log_msg_debug("check if process $ps (id=$ProcIds->[$ps]) is alive");

        $procAlive = kill 0, $ProcIds->[$ps];

        log_msg_debug("process $ps (id=$ProcIds->[$ps]) is ".
                      ($procAlive ? "alive" : "dead"));
      }

      # Bug 22887047: no point trying to write to a process that died (all 
      # you get out of it is a "Broken pipe" message and catcon dying)
      if ($procAlive) {
        print {$FileHandles->[$ps]} 
          "PROMPT ========== Process Terminated by catcon ==========\n";

        printToSqlplus("end_processes", $FileHandles->[$ps],
                       "EXIT", "\n", $LogLevelDebug);

        log_msg_debug("write EXIT to process $ps (id=$ProcIds->[$ps])");

        print {$FileHandles->[$ps]} "EXIT\n";

        log_msg_debug("close file handle for process $ps ".
                      "(id=$ProcIds->[$ps])\n");

        close ($FileHandles->[$ps]);
      }

      log_msg_debug("setting FileHandle[$ps] to undef");

      $FileHandles->[$ps] = undef;
    } else {
      log_msg_debug("process $ps has already been stopped");
    }

    # if processing PDBs using all available instances, delete an entry 
    # mapping this process to the instance for which it was created from 
    # %$ProcInstMap_ref
    if ((%$ProcInstMap_ref) && 
        (exists $ProcInstMap_ref->{$ProcIds->[$ps]})) {
      delete $ProcInstMap_ref->{$ProcIds->[$ps]};

      log_msg_debug("deleted entry for process ".
                    $ProcIds->[$ps]." from ProcInstMap_ref");
    }
  }

  if ($DeadProc == -1) {
    log_msg_debug("done with processes $FirstProcIdx to $LastProcIdx");
  } else {
    log_msg_debug("done with dead process $DeadProc ".
                  "(id=$ProcIds->[$DeadProc])");
  }

  # clean up completion files
  clean_up_compl_files($LogFilePathBase, $ProcIds, $FirstProcIdx, 
                       $LastProcIdx);
  
  # delete @$ProcIds entries corresponding to processes which were ended, 
  # unless we are handling a dead process which will be replaced with a new 
  # process, in which case we want to preserve its spot (since that's where 
  # we will place id of the process that will be started in its place)
  if ($DeadProc == -1) {
    splice @$ProcIds, $FirstProcIdx, $LastProcIdx - $FirstProcIdx + 1;

    # if processing PDBs using all available instances, update 
    # $InstProcMap_ref to accurately describe offset in @$ProcIds of the 
    # first process created for a given instance
    if (%$InstProcMap_ref) {
      my @instances = sort keys %$InstProcMap_ref;

      if ($#instances < 0) {        
        log_msg_error("instance-to-process map contains no entries");
        return 1;
      }

      # first, we delete FIRST_PROC entries and reset to 0 NUM_PROCS entries
      # for every instance
      foreach my $inst (@instances) {
        if (exists $InstProcMap_ref->{$inst}->{FIRST_PROC}) {
          delete $InstProcMap_ref->{$inst}->{FIRST_PROC};

          log_msg_debug("deleted FIRST_PROC entry for instance ".
                        $inst." from InstProcMap_ref");
        }

        $InstProcMap_ref->{$inst}->{NUM_PROCS} = 0;

        log_msg_debug("reset to 0 NUM_PROCS entry for instance ".
                      $inst." in InstProcMap_ref");
      }

      # next, for instances not all of whose processes got killed, FIRST_PROC 
      # entries will be created and NUM_PROCS entries will be updated to 
      # reflect the number of processes left running on that instance
      my $currInst;

      for (my $pidIdx = 0; $pidIdx <= $#$ProcIds; $pidIdx++) {
        my $pid = $ProcIds->[$pidIdx];

        if (! exists $ProcInstMap_ref->{$pid}) {
          log_msg_error("ProcInstMap_ref does not contain an ".
                        "entry for process $pid\n".
                        "which is represented by an element of ProcIds");
          return 1;
        }

        my $inst = $ProcInstMap_ref->{$pid};

        # NOTE: we are assuming that all processes running on a given 
        #       instance will occupy contiguoys slots in @$ProcIds
        if ((! defined $currInst) || $inst ne $currInst) {
          # first process created for instance $inst
          $InstProcMap_ref->{$inst}->{FIRST_PROC} = $pidIdx;
          $currInst = $inst;

          log_msg_debug("id ($pid) of the first process started ".
                        "for instance $inst\n".
                        "was found in ProcIds at offset $pidIdx");
        }

        $InstProcMap_ref->{$inst}->{NUM_PROCS}++;

        log_msg_debug("incremented NUM_PROCS entry for instance ".
                      $inst." in InstProcMap_ref to ".
                      $InstProcMap_ref->{$inst}->{NUM_PROCS});
      }
    }
  } else {
    # we did not delete the @$ProcIds entry corresponding to the dead process, 
    # so reset it to -1 to make sure we do not assume that it represents a 
    # valid process id
    $ProcIds->[$DeadProc] = -1;
  }

  log_msg_debug("ended processes $FirstProcIdx to $LastProcIdx");

  return 0;
}

#
# clean_up_compl_files - purge files indicating completion of processes.
#                        Purging will start from the first process given
#                        and end at the last process given.
#
# parameters:
#   - base of process completion file name
#   - reference to an array of process ids
#   - First process whose completion files are to be purged
#   - Last processes whose completion files are to be purged
#
sub clean_up_compl_files ($$$$) {
  my ($FileNameBase, $ProcIds, $FirstProc, $LastProc) =  @_;

  my $ps;

  log_msg_debug(qq#FileNameBase = $FileNameBase, FirstProc =#.
                qq#$FirstProc, LastProc = $LastProc#);

  for ($ps=$FirstProc; $ps <= $LastProc; $ps++) {
    my $DoneFile = done_file_name($FileNameBase, $ProcIds->[$ps]);
    
    if (-e $DoneFile && -f $DoneFile) {
      log_msg_debug(qq#call sureunlink to remove $DoneFile#);

      sureunlink($DoneFile);
      
      log_msg_debug(qq#removed $DoneFile#);
    }
  }
}

#
# get_log_file_base_path - determine base path for log files
#
# Parameters:
#   - log directory, as specified by the user
#   - base for log file names
#
# Returns:
#   base path for log files; undef if an error was encountered
#
sub get_log_file_base_path ($$) {
  my ($LogDir, $LogBase) = @_;

  # $LogBase may not contain any directory names, i.e. it must be a string 
  # which we can modify to construct name of a log file which will be stored 
  # in $LogDir
  my ($vol,$dirs,$file) = File::Spec->splitpath($LogBase);

  if ($vol || $dirs || !$file) {
    log_msg_error <<msg;
log file base may not contain any directories
  <$LogBase> is not a valid log file base
msg
    return undef;
  }

if ($LogDir) {
    log_msg_debug("log file directory = $LogDir");
  } else {
    # if LogDir was not specified, use current directory; returning unqualified
    # $LogBase (like we used to do when LogDir was not supplied) sometimes 
    # caused catcon.pl to hang waiting for the SQL*Plus process to complete, 
    # presumably because it could not write the .done file
    $LogDir = cwd();

    log_msg_debug <<msg;
no log file directory was specified - using current directory ($LogDir)
msg
  }

  log_msg_debug("log file base = $LogBase");

  return (File::Spec->catfile(File::Spec->splitdir($LogDir), $LogBase));
}

#
# send_sig_to_procs - given an array of process ids, send specified signal to 
#                     these processes 
#
# Parameters:
#   - reference to an array of process ids
#   - signal to send
#
# Returns:
#   number of processes whose ids were passed to us which got the signal
#
sub send_sig_to_procs (\@$) {
  my ($ProcIds, $Sig)  =  @_;
  
  return  kill($Sig, @$ProcIds);
}

#
# next_proc - determine next process which has finished work assigned to it
#             (and is available to execute a script or an SQL statement)
#
# Description:
#   This subroutine will look for a file ("done" file) indicating that the 
#   process has finished running a script or a statement which was sent to it.
#   Once such file is located, it will be deleted and a number of a process 
#   to which that file corresponded will be returned to the caller
#
# Parameters:
#   - number of processes from which we may choose the next available process
#   - total number of processes which were started (used when we try to
#     determine if some processes may have died)
#   - number of the process starting with which to start our search; if the 
#     supplied number is greater than $ProcsUsed, it will be reset to 0
#   - reference to an array of booleans indicating status of which processes 
#     should be ignored; may be undefined
#   - base for names of files whose presense will indicate that a process has 
#     completed
#   - reference to an array of process ids
#   - an indicator of whether to recover from death of a child process
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - name of the "kill session script"
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
sub next_proc ($$$$$$$\@$$$) {
  my ($ProcsUsed, $NumProcs, $StartingProc, $ProcsToIgnore, 
      $FilePathBase, $ProcIds, $RecoverFromChildDeath, 
      $IntConnectString, $KillSessScript, $DoneCmd, $sqlplus) = @_;

  log_msg_debug <<next_proc_DEBUG;
  running next_proc(ProcsUsed    = $ProcsUsed, 
                    NumProcs     = $NumProcs,
                    StartingProc = $StartingProc,
                    FilePathBase = $FilePathBase,
                    RecoverFromChildDeath = $RecoverFromChildDeath,
                    KillSessScript = $KillSessScript,
                    DoneCmd      = $DoneCmd);
next_proc_DEBUG
  
  # process number; will be used to construct names of "done" files
  # before executing the while loop for the first time, it will be set to 
  # $StartingProc.  If that number is outside of [0, $ProcsUsed-1], 
  # it [$CurProc] will be reset to 0; for subsequent iterations through the 
  # while loop, $CurProc will start with 0
  my $CurProc = ($StartingProc >= 0 && $StartingProc <= $ProcsUsed-1) 
    ? $StartingProc : 0;
    
  # look for *.done files which will indicate which processes have 
  # completed their work

  # we may end up waiting a while before finding an available process and if 
  # debugging is turned on, user's screen may be flooded with 
  #     next_proc: Skip checking process ...
  # and
  #     next_proc: Checking if process ... is available
  # messages.  
  #
  # To avoid this, we will print this message every 10 second or so.  Since 
  # we check for processes becoming available every 0.01 of a second (or so), 
  # we will report generate debugging messages every 1000-th time through the 
  # loop
  my $itersBetweenMsgs = 1000;

  for (my $numIters = 0; ; $numIters++) {
    #
    # Bug 22887047: now that we no longer try to catch SIGCHLD, we will check 
    #   if the next process is still alive, and if it is not, we will start a 
    #   new process in its place and proceed as if nothing happened
    # 

    for (; $CurProc < $ProcsUsed; $CurProc++) {
        
      if (   $ProcsToIgnore && @$ProcsToIgnore 
          && $ProcsToIgnore->[$CurProc]) {
        if ($numIters % $itersBetweenMsgs == 0) {
          log_msg_debug("Skip checking process $CurProc");
        }

        next;
      }

      # Bug 22887047: check if the next process is still alive;  if it is no 
      #   longer with us, start a new process in its place
      my $procAlive = kill 0, $ProcIds->[$CurProc];

      # catconBounceDeadProcess will return non-zero only if 
      # catconBounceProcesses was unable to bounce it, in which case we will 
      # report an error to the caller
      if (!$procAlive) {
        log_msg_debug("process $CurProc (PID=$ProcIds->[$CurProc]) is dead");

        # LRG 19633516: check whether the caller indicated that death of a 
        # child process should result in death of catcon
        if (!$RecoverFromChildDeath) {
          log_msg_debug <<msg;
caller has not requested recovery from death of SQL*Plus processes -
           will release resources and exit
msg

          # LRG 19650060: need to ignore SIGPIPE. Even though I am avoiding 
          #   sending any new commands to the process once I know that it is 
          #   dead, it's likely that the command to generate "done" file which
          #   was sent before the process has encountered a statement that 
          #   caused it to die is causing SIGPIPE
          log_msg_debug("SIGPIPE will be ignored");

          $SIG{PIPE} = 'IGNORE';

          # release resources (including sending EXIT to each SQL*Plus 
          # process still running
          log_msg_debug("invoking catconWrapUp");
          
          catconWrapUp();

          # in case some of the processes did not react to EXIT 
          # (e.g. because they were running some script), use 
          # ALTER SYSTEM KILL SESSION to terminate them
          if ($KillSessScript && (-e $KillSessScript)) {
            log_msg_debug("invoking kill_sqlplus_sessions");

            kill_sqlplus_sessions(@$IntConnectString, 
                                  $KillSessScript, $DoneCmd, 
                                  done_file_name_prefix($FilePathBase, $$),
                                  $sqlplus);
          }

          # if any of them are still around, send SIGKILL to them
          log_msg_debug("sending SIGKILL to SQL*Plus processes");
          
          send_sig_to_procs(@$ProcIds, 9);

          log_msg_debug("returning -1 to the caller");

          return -1;
        }

        log_msg_debug <<msg;
caller has requested recovery from death of SQL*Plus processes
msg

        # id of the apparently dead process
        my $deadProcId = $ProcIds->[$CurProc];

        log_msg_debug <<msg;
SQL*Plus process $deadProcId (ProcIds[$CurProc]) appears 
           to have died. Will try to start another process in its place
msg

        if (catconBounceDeadProcess($CurProc)) {
          log_msg_error <<msg;
Attempt to start a new SQL*Process to take place of process 
           $deadProcId (ProcIds[$CurProc]) failed
msg
          
          return -1;
        }

        log_msg_debug <<msg;
new SQL*Plus process $ProcIds->[$CurProc] was successfully started 
           to take place of process $deadProcId (ProcIds[$CurProc]) which 
           appears to have died
msg
      }

      # file which will indicate that process $CurProc finished its work
      #
      # Bug 18011217: append _catcon_$ProcIds->[$CurProc] to $FilePathBase 
      # to avoid conflicts with other catcon processes running on the same 
      # host
      my $DoneFile = done_file_name($FilePathBase, $ProcIds->[$CurProc]);

      if ($numIters % $itersBetweenMsgs == 0) {
        log_msg_debug("Checking if process $CurProc ".
                      "(id = $ProcIds->[$CurProc]) is available");
      }

      #
      # Is file is present, remove the "done" file (thus making this process 
      # appear "busy") and return process number to the caller.
      #
      if (-e $DoneFile) {
        log_msg_debug("call sureunlink to remove $DoneFile");

        sureunlink($DoneFile);

        log_msg_debug("process $CurProc is available");

        return $CurProc;
      }
    }
    select (undef, undef, undef, 0.01);

    $CurProc = 0;
  }
  
  return -1;  # this statement will never be reached
}

#
# wait_for_completion - wait for completion of processes
#
# Description:
#   This subroutine will wait for processes to indicate that they've 
#   completed their work by creating a "done" file.  Since it will use 
#   next_proc() (which deleted "done" files of processes whose ids it returns) 
#   to find processes which are done running, this subroutine will generate 
#   "done" files once all processes are done to indicate that they are 
#   available to take on more work.
#
# Parameters:
#   - number of processes which were used (and whose completion we need to 
#     confirm)
#   - total number of processes which were started
#   - base for generating names of files whose presense will indicate that a 
#     process has completed
#   - references to an array of process file handles
#   - reference to a array of process ids
#   - command which will be sent to a process to cause it to generate a 
#     "done" file
#   - reference to an array of statements, if any, to be issued when a process 
#     completes
#   - if connected to a CDB, name of the Root Container into which we should 
#     switch (Bug 17898118: ensures that no process is connected to a PDB 
#     which may get closed by some script (which would run only if there are 
#     no processes running scripts in that PDB))
#   - internal connect strings - [0] used to connect to a DB, 
#                                [1] can be used to produce diagnostic message
#   - an indicator of whether to recover from death of a child process
#   - name of the "kill session script"
#   - an indicator of whether the instance may be shut down in which case we 
#     do not want to echo "done" statement to the sql log file
#   - an indicator of whether logging level is set to DEBUG (IN)
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
#
sub wait_for_completion ($$$\@\@$\@$\@$$$$$) {
  my ($ProcsUsed, $NumProcs, $FilePathBase, $ProcFileHandles, 
      $ProcIds, $DoneCmd, $EndStmts, $Root, $InternalConnectString, 
      $RecoverFromChildDeath, $KillSessScript, $InstShutDown, 
      $LogLevelDebug, $sqlplus) = @_;

  my $RootVal = (defined $Root) ? $Root : "undefined";

  log_msg_debug <<wait_for_completion_DEBUG;
  running wait_for_completion(ProcsUsed             = $ProcsUsed, 
                              FilePathBase          = $FilePathBase,
                              DoneCmd               = $DoneCmd,
                              Root                  = $RootVal,
                              InternalConnectString = $InternalConnectString->[1],
                              RecoverFromChildDeath = $RecoverFromChildDeath,
                              KillSessScript        = $KillSessScript,
                              LogLevelDebug         = $LogLevelDebug);
wait_for_completion_DEBUG

  # process number
  my $CurProc = 0;
    
  log_msg_debug("waiting for $ProcsUsed processes to complete");

  # look for *.done files which will indicate which processes have 
  # completed their work

  my $NumProcsCompleted = 0;  # how many processes have completed

  # this array will be used to keep track of processes which have completed 
  # so as to avoid checking for existence of files which have already been 
  # seen and removed
  my @ProcsCompleted = (0) x $ProcsUsed;

  while ($NumProcsCompleted < $ProcsUsed) {
    $CurProc = next_proc($ProcsUsed, $NumProcs, $CurProc + 1, \@ProcsCompleted,
                         $FilePathBase, $ProcIds, $RecoverFromChildDeath,
                         @$InternalConnectString, $KillSessScript, $DoneCmd,
                         $sqlplus);

    if ($CurProc < 0) {
      log_msg_error(qq#unexpected error in next_proc()#);
      return 1;
    }

    # if the caller has supplied us with statements to run after a 
    # process finished its work, do it now
    if ($EndStmts && $#$EndStmts >= 0) {

      log_msg_debug("sending completion statements to process $CurProc:");

      foreach my $Stmt (@$EndStmts) {

        # $Stmt may contain %proc strings which need to be replaced with 
        # process number, but we don't want to modify the statement in 
        # @$EndStmts, so we modify a copy of it
        my $Stmt1;

        ($Stmt1 = $Stmt) =~ s/%proc/$CurProc/g;
        
        log_msg_debug("\t$Stmt1");

        printToSqlplus("wait_for_completion", $ProcFileHandles->[$CurProc],
                       $Stmt1, "\n", $LogLevelDebug);
      }

      $ProcFileHandles->[$CurProc]->flush; # flush the buffer
    }

    # Bug 17898118: if connected to a CDB, switch the process into the Root
    # to avoid getting caught connected to a PDB that gets closed. 
    #
    # Before switching, however, we need to check to make sure the CDB is 
    # open (some scripts shut down the CDB, and trying to switch into the 
    # Root while the CDB is closed results in errors
    #
    # Bug 18011217: append _catcon_$ProcIds->[0] to $FilePathBase to avoid 
    # conflicts with other catcon processes running on the same host
    if ($Root) {
      my $instanceStatus = 
        get_instance_status(@$InternalConnectString, $DoneCmd, 
                            done_file_name_prefix($FilePathBase, 
                                                  $ProcIds->[0]),
                            $sqlplus);
      if ((defined $instanceStatus)) {
        if ($instanceStatus =~ /^OPEN/) {
          log_msg_debug("switching process $CurProc into $Root");

          print {$ProcFileHandles->[$CurProc]} 
            qq#ALTER SESSION SET CONTAINER = "$Root"\n/\n#;
          $ProcFileHandles->[$CurProc]->flush; # flush the buffer
        } else {
          log_msg_debug("process $CurProc not switched into ".
                        "$Root because the CDB is not open");
        }
      } else {
        # instance status could not be obtained
        log_msg_error("unexpected error in get_instance_status");
        return 1;
      }
    }

    log_msg_debug("process $CurProc is done");

    $NumProcsCompleted++; # one more process has comleted

    # remember that this process has completed so next_proc does not try to 
    # check its status
    $ProcsCompleted[$CurProc] = 1;
  }

  log_msg_debug("All $NumProcsCompleted processes have completed");
  
  # issue statements to cause "done" files to be created to indicate
  # that all $ProcsUsed processes are ready to take on more work
  for ($CurProc = 0; $CurProc < $ProcsUsed; $CurProc++) {

    # file which will indicate that process $CurProc finished its work
    #
    # Bug 18011217: append _catcon_$ProcIds->[$CurProc] to $FilePathBase to 
    # avoid conflicts with other catcon processes running on the same host
    my $DoneFile = done_file_name($FilePathBase, $ProcIds->[$CurProc]);

    printToSqlplus("wait_for_completion", $ProcFileHandles->[$CurProc],
                   qq/$DoneCmd $DoneFile/,
                   "\n", $LogLevelDebug);

    # flush the file so a subsequent test for file existence does 
    # not fail due to buffering
    $ProcFileHandles->[$CurProc]->flush;

    log_msg_debug <<msg;
sent "$DoneCmd $DoneFile" 
    to process $CurProc (id = $ProcIds->[$CurProc]) to indicate that it is 
    available to take on more work
msg
  }

  return 0;
}

#
# return a timestamp in yyyy-mm-dd h24:mi:sec format
#
sub TimeStamp {
  my ($sec,$min,$hour,$mday,$mon,$year)=localtime(time);

  return sprintf "%4d-%02d-%02d %02d:%02d:%02d",
                 $year+1900,$mon+1,$mday,$hour,$min,$sec;
}

#
# getSpoolFileNameSuffix - generate suffix for a spool file names using 
#   container name supplied by the caller
#
# Parameters:
# - container name (IN)
#
sub getSpoolFileNameSuffix ($) {
 my ($SpoolFileNameSuffix) = @_;

 # $SpoolFileNameSuffix may contain characters which may be 
 # illegal in file name - replace them all with _
 $SpoolFileNameSuffix =~ s/\W/_/g;

 return lc($SpoolFileNameSuffix);
}

#
# pickNextProc - pick a process to run next statement or script
#
# Parameters:
#   (IN) unless indicated otherwise
#   - number of processes from which we may choose the next available process 
#   - total number of processes which were started (used when we try to
#     determine if some processes may have died)
#   - number of the process starting with which to start our search; if the 
#     supplied number is greater than $ProcsUsed, it will be reset to 0
#   - base for names of files whose presense will indicate that a process has 
#     completed
#   - reference to an array of process ids
#   - an indicator of whether to recover from death of a child process
#   - connect strings - [0] used to connect to a DB, 
#                       [1] can be used to produce diagnostic message
#   - name of the "kill session script"
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - "sqlplus" (if we have not tried to locate sqlplus in $PATH or in 
#     directory specified by the caller of catcon) or absolute path of 
#     sqlplus binary to be used
# 
sub pickNextProc ($$$$$$\@$$$) {
  my ($ProcsUsed, $NumProcs, $StartingProc, $FilePathBase, 
      $ProcIds, $RecoverFromChildDeath, $IntConnectString, $KillSessScript, 
      $DoneCmd, $sqlplus) = @_;

  # find next available process
  my $CurProc = next_proc($ProcsUsed, $NumProcs, $StartingProc, undef,
                          $FilePathBase, $ProcIds, $RecoverFromChildDeath, 
                          @$IntConnectString, $KillSessScript, $DoneCmd,
                          $sqlplus);
  if ($CurProc < 0) {
    # some unexpected error was encountered
    log_msg_error("unexpected error in next_proc");

    return -1;
  }

  return $CurProc;
}

#
# firstProcUseStmts - issue statements to a process that is being used for 
#                     the first time
# Parameters:
#   - value of IDENTIFIER if ERRORLOGGING is enabled (IN)
#   - value of custom Errorlogging Identifier; if defined, $ErrLoggingIdent 
#     will be used as is, without appending "InitStmts" (IN)
#   - name of error logging table, if defined (IN)
#   - reference to an array of file handle references (IN)
#   - number of the process about to be used (IN)
#   - reference to an array of statements which will be executed in every 
#     process before it is asked to run the first script (IN)
#   - array used to keep track of processes to which statements contained in 
#     @$PerProcInitStmts_REF need to be sent because they [processes]
#     have not been used in the course of this invocation of catconExec()
#   - an indicator of whether _oracle_script is set (meaning that 
#     err_logging_tbl_stmt will need to temporarily reset it) (IN)
#   - name of a Federation Root if it was supplied by the caller of catcon to 
#     indicate that scripts are to be run against Containers comprising a 
#     Federation rooted in that Container; if set, _federation_script may be 
#     set and so needs to be temporarily reset in err_logging_tbl_stmt (IN)
#   - an indicator of whether logging level is set to DEBUG (IN)
#
sub firstProcUseStmts ($$$$$$$$$$) {
  my ($ErrLoggingIdent, $CustomErrLoggingIdent, $ErrLogging, $FileHandles_REF, 
      $CurProc, $PerProcInitStmts_REF, $NeedInitStmts_REF, $OracleScriptIsSet, 
      $FedRoot, $LogLevelDebug) = @_;
  
  if ($ErrLogging) {
    # construct and issue SET ERRORLOGGING ON [TABLE...] statement
    err_logging_tbl_stmt($ErrLogging, $FileHandles_REF, $CurProc, 
                         $OracleScriptIsSet, $FedRoot, $LogLevelDebug);

    if ($ErrLoggingIdent) {
      # send SET ERRORLOGGING ON IDENTIFIER ... statement
      my $Stmt;
      if ($CustomErrLoggingIdent) {
        # NOTE: if the caller of catconExec() has supplied a custom 
        #       Errorlogging Identifier, it has already been copied into 
        #       $ErrLoggingIdent which was then normalized, so our use of 
        #       $ErrLoggingIdent rather than $CustomErrLoggingIdent below is 
        #       intentional
        $Stmt = "SET ERRORLOGGING ON IDENTIFIER '".substr($ErrLoggingIdent, 0, 256)."'";
      } else {
        $Stmt = "SET ERRORLOGGING ON IDENTIFIER '".substr($ErrLoggingIdent."InitStmts", 0, 256)."'";
      }

      log_msg_debug("sending $Stmt to process $CurProc");

      printToSqlplus("firstProcUseStmts", $FileHandles_REF->[$CurProc],
                     $Stmt, "\n", $LogLevelDebug);
    }
  }

  log_msg_debug("sending init statements to process $CurProc:");

  foreach my $Stmt (@$PerProcInitStmts_REF) {

    # $Stmt may contain %proc strings which need to be replaced with 
    # process number, but we don't want to modify the statement in 
    # @$PerProcInitStmts_REF, so we modify a copy of its element
    my $Stmt1;

    ($Stmt1 = $Stmt) =~ s/%proc/$CurProc/g;

    log_msg_debug("\t$Stmt1");

    printToSqlplus("firstProcUseStmts", $FileHandles_REF->[$CurProc],
                   $Stmt1, "\n", $LogLevelDebug);
  }

  # remember that "initialization" statements have been run for this 
  # process
  $NeedInitStmts_REF->[$CurProc] = 0;

  return;
}

sub printToSqlplus ($$$$$) {
  my ($func, $fh, $stmt, $tail, $DebugOn) = @_;

  if ($DebugOn) {
    my $printableStmt = $stmt;
    $printableStmt  =~ s/\n/#LF#/g; # mask \n
    my $debugQry = qq{prompt $func(): $printableStmt\n};
    print {$fh} $debugQry;
  }

  print {$fh} qq#$stmt$tail#;
}

#
# additionalInitStmts - issue additional initialization statements after 
#   picking a new process to run a script in a given Container
#
# Parameters: (all parameters are IN unless noted otherwise)
#   - reference to an array of file handles used to communicate to processes
#   - process number of the process which was picked to run the next script
#   - name of the container against which the next script will be run
#     (can be null if running against ROOT or in a non-CDB
#   - query which will identify current container in the log
#     (can be null if running against ROOT or in a non-consolidated DB)
#   - process id of the process hich was picked to run the next script
#   - an indicator of whether logging level is set to DEBUG (IN)
#   - an indicator of whether _oracle_script should be set (IN)
#   - name of a Federation Root if called to run scripts against all 
#     Containers comprising a Federation rooted in the specified Container
#
sub additionalInitStmts ($$$$$$$$$) {
  my ($FileHandles_REF, $CurProc, $CurConName,
      $CurrentContainerQuery, $CurProcId, $EchoOn, $LogLevelDebug, 
      $SetOracleScript, $FedRoot) = @_;

  # if told to set _ORACLE_SCRIPT,
  #   do so now
  # else if Federation Root name was supplied
  #   _FEDERATION_SCRIPT needs to be set
  if ($SetOracleScript) {
    printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                   qq#ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE#, "\n/\n", 
                   $LogLevelDebug);
  } elsif ($FedRoot) {
    printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                   qq#ALTER SESSION SET "_FEDERATION_SCRIPT"=TRUE#, "\n/\n", 
                   $LogLevelDebug);
  }

  # set tab and trimspool to on, so that spooled log files start 
  # with a consistent setting
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#SET TAB ON#, "\n", 
                 $LogLevelDebug);

  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#SET TRIMSPOOL ON#, "\n", 
                 $LogLevelDebug);

  # ensure that common SQL*PLus vars that affect appearance of log files are 
  # set to consistent values.  This will ensure that vars modified in one 
  # script do not affect appearance of log files produced by running another 
  # script or running the same script in a different Container
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set colsep ' '#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set escape off#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set feedback 6#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set heading on#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set linesize 80#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set long 80#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set newpage 1#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set numwidth 10#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set pagesize 14#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set recsep wrapped#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set showmode off#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set sqlprompt "SQL> "#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set termout on#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set trimout on#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set underline on#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set verify on#, "\n", 
                 $LogLevelDebug);
  printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                 qq#set wrap on#, "\n", 
                 $LogLevelDebug);
          
  if ($CurConName) {
    # in case $CurConName refers to an App Root Clone, we need to set 
    # _ORACLE_SCRIPT to true before issuing SET CONTAINER and clear it 
    # immediately thereafter
    printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                   qq#alter session set "_oracle_script"=TRUE#, "\n/\n", 
                   $LogLevelDebug);

    printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                   qq#ALTER SESSION SET CONTAINER = "$CurConName"#, "\n/\n", 
                   $LogLevelDebug);

    printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                   qq#alter session set "_oracle_script"=FALSE#, "\n/\n", 
                   $LogLevelDebug);

    log_msg_debug("process $CurProc (id = $CurProcId) ".
                  "connected to Container $CurConName");
  }

  if ($CurrentContainerQuery) {
    print {$FileHandles_REF->[$CurProc]} $CurrentContainerQuery;
  }

  if ($EchoOn) {
    printToSqlplus("additionalInitStmts", $FileHandles_REF->[$CurProc], 
                   qq#SET ECHO ON#, "\n", 
                   $LogLevelDebug);
  }

  return;
}

#
# find_in_path - locate specified binary in $PATH or, if the caller 
#                specified the directory where the desired version of the 
#                binary should is supposed to be present, verify that the
#                specified directory really contains it.
#
# parameters:
#   $exec - name of the binary; on Windows we will try to locate the 
#           specified binary with standard Windows extensions
#   $windows - an indicator of whether we are running on a Windows machine
#   $dirToUse - if provided, the specified binary must be present in this 
#               directory (rather than in $PATH)
#
sub find_in_path($$$) {
  my ($exec, $windows, $dirToUse) = @_;
  my @pathext = ('');

  # for Windows, look for $exec.<one of extensions (e.g. .exe or .bat)>
  if ($windows) {
    if ( $ENV{PATHEXT} ) {
      push @pathext, split ';', $ENV{PATHEXT};
    } else {
      # if PATHEXT is not set use one of .com, .exe or .bat
      push @pathext, qw{.com .exe .bat};
    }
  }

  my @path;

  # bug 26135561: if the caller specified directory where the binary we should 
  #   use is supposed to be located, limit our search to that directory; 
  #   otherwise, attempt to locate it in one of directories comprising $PATH
  if ($dirToUse) {
    @path = ( File::Spec->rel2abs($dirToUse) );
  } else {
    @path = File::Spec->path;

    if ($windows) {
      unshift @path, File::Spec->curdir;
    }
  }
 
  foreach my $base ( map { File::Spec->catfile($_, $exec) } @path ) {
    for my $ext ( @pathext ) {
      my $file = $base.$ext;
 
      # We don't want dirs (as they are -x)
      next if -d $file;
      
      if (
          # Executable, normal case
          -x _
          or (
              (
               $windows
               and
               grep {$file =~ /$_\z/i} @pathext[1..$#pathext])
              # DOSish systems don't pass -x on
              # non-exe/bat/com files. so we check -e.
              # However, we don't want to pass -e on files
              # that aren't in PATHEXT, like README.
              and -e _)
         ) {
        return $file;
      }
    }
  }

  return undef;
}

#
# log_script_execution - produce a message indicating script or statement about
#                        to be executed as well as the name of a Container 
#                        (if applicable) in which it is being executed
#
sub log_script_execution (\$$$) {
  my ($FilePath, $ConName, $ProcIdx) = @_;

  my $msg;
  
  $msg = "executing".(($$FilePath =~ /^@/) ? " " : " statement ");
  $msg .= "\"".$$FilePath."\" in ".($ConName ? "container ".$ConName : "non-CDB");
  
  log_msg_verbose($msg." using process $ProcIdx");
}

# 
# os_dependent_stuff: set OS-dependent variables
#
# Parameters:
#   - reference to a variable storing an indication of whether we are 
#     running on Windows
#   - reference to a variable storing a command which must be set to SQL*Plus 
#     to cause a "done" file to be created
#   - absolute path of sqlplus binary to be used
#
sub os_dependent_stuff(\$\$$) {
  my ($isWindows, $doneCmd, $sqlplus) = @_;

  my $UnixDoneCmd = "\nhost $sqlplus -v >";
  my $WindowsDoneCmd = "\nhost $sqlplus/nolog -v >";

  # figure out if we are running under Windows and set $catcon_DoneCmd
  # accordingly

  $$doneCmd = ($$isWindows = ($OSNAME =~ /^MSWin/)) ? $WindowsDoneCmd : $UnixDoneCmd;

  return;
}

# compute number of processes which will be used to run 
# script/statements specified by the caller in all remaining PDBs; 
# value returned by this subroutine will be used to determine when all 
# processes finished their work
sub compute_procs_used_for_pdbs($$$$) {
  my ($singleThreaded, $numPDBs, $numProcs, $scriptPaths) = @_;

  my $ProcsUsed;
  
  if ($singleThreaded) {
    $ProcsUsed = ($numPDBs > $numProcs) ? $numProcs : $numPDBs;
  } else {
    $ProcsUsed = ($scriptPaths * $numPDBs > $numProcs) 
      ? $numProcs : $scriptPaths * $numPDBs;
  }
  
  return $ProcsUsed;
}

# this subroutine will determine whether a connect string relies on OS 
# auhentication (for now, catcon only recognizes / AS SYSDBA)
sub using_OS_authentication($) {
  my ($id) = @_;
  
  return uc($id) eq '/ AS SYSDBA';
}

# return supplied connect string with password, if any, masked using #'s
sub mask_user_passwd($) {
  my ($connStr) = @_;

  # if connect string was not supplied, "undefined" will be displayed
  if (! defined $connStr || !$connStr) {
    return "undefined";
  }

  if ($connStr =~ /(.*)\/(.*)/ && $1 && $2) {
    # connect string with password masked using #'s
    my $maskedStr = "$1/########";

    # if AS <admin-role> was specified, make sure it gets displayed
    if ($connStr =~ / as.*(sys[a-z]*)(.*)/i) {
      $maskedStr .= " AS $1".$2;
    }

    return $maskedStr;
  } else {
    # $connStr does not contain a password so it's safe to display
    return $connStr;
  }
}

sub thread_rec_dump($$) {
  my ($threadRec_ref, $comment) = @_;

  log_msg_debug("$comment:");
  log_msg_debug("\tInstance: $threadRec_ref->{INSTANCE}");
  log_msg_debug("\tMaximum number of PDBs: $threadRec_ref->{MAX_PDBS}");
  log_msg_debug("\tPDBs: ".join("\n\t      ", @{$threadRec_ref->{PDBS}}));
  log_msg_debug("\tOffset of the first SQL*Plus process: ".
                "$threadRec_ref->{FIRST_PROC}");
  log_msg_debug("\tOffset of the last SQL*Plus process: ".
                "$threadRec_ref->{LAST_PROC}");
}

#
# all_inst_requested - did the caller request that we use all available 
#   instances
#
# Parameters:
#   $AllInst (IN) -
#     see $catcon_AllInst
#   $AllPdbMode (IN) -
#     see $catcon_AllPdbMode
#
sub all_inst_requested($$) {
  my ($AllInst, $AllPdbMode) = @_;
  
  return ($AllInst && $AllPdbMode != CATCON_PDB_MODE_UNCHANGED);
}

#
# ignore_all_inst_request - should we ignore a caller's request that all 
#   available instances be used
#
# Description:
#   We will ignore this request if running upgrade and the number of 
#   processes supplied by the caller is 0 (which corresponds to the first 
#   invocation of catconInit from catctl - the process invoking catconInit 
#   will not be upgrading any PDBs but will, instead, fork 1 or more catctl 
#   threads to do actual work)
# 
# Parameters:
#   $Upgrade (IN) - 
#     are we running an upgrade
#   $NumProcs (IN) -
#     number of proceses specified by the caller
#
sub ignore_all_inst_request($$) {
  my ($Upgrade, $NumProcs) = @_;

  return ($Upgrade && $NumProcs == 0);
}

# show_undef - return value of a supplied argument if it is defined or a 
#   string "undefined" otherwise
sub show_undef($) {
  my ($val) = @_;

  return ((defined $val) ? $val : "undefined");
}

#
# mult_inst_feasible - is use of multiple RAC instances 
#   feasible based on parameters supplied by the caller and characteristics 
#   of the CDB (but not taking into consideration special restrictions 
#   (i.e. if we are running UPGRADE and the caller has supplied 0 as the 
#   number of processes) which could cause us to ignore caller's request
#
#   NOTE: unlike catconMultipleInstancesFeasible, this subroutine does not 
#         check whether catconInit2 has been run (because we need to use it 
#         before catconInit2 has scompleted but by the tinme it gets called, 
#         all relevant parameters are expected to have been set
#
# Parameters:
#   $AllInstRequested (IN) -
#     did the caller request that we use all available instances
#   $InternalConnStr_ref (IN) -
#     see @catcon_InternalConnectString
#   $InstConnStr_ref (IN) -
#     see %catcon_InstConnStr
#   $UserConnStr_ref (IN) -
#     see @catcon_UserConnectString
#   $DbmsVersion (IN) -
#     see $catcon_DbmsVersion
#
sub mult_inst_feasible($$$$$) {
  my ($AllInstRequested, $InternalConnStr_ref, $InstConnStr_ref,
      $UserConnStr_ref, $DbmsVersion) = @_;

  log_msg_debug("determining whether use of multiple instances is feasible");

  log_msg_debug("\tAllInstRequested = ".(show_undef($AllInstRequested)));

  log_msg_debug("\tInternalConnStr_ref->[1] = ". $InternalConnStr_ref->[1]);
  log_msg_debug("\tInstConnStr is defined = ".
                (%$InstConnStr_ref ? "TRUE" : "FALSE"));
    
  if (%$InstConnStr_ref) {
    log_msg_debug("\tnumber of entries in InstConnStr = ".
                  (scalar keys %$InstConnStr_ref));
  }

  my $userConnStrUsingOsAuth = using_OS_authentication($UserConnStr_ref->[0]);

  log_msg_debug("\tusing_OS_authentication(UserConnStr[0]) = ".
                $userConnStrUsingOsAuth);

  log_msg_debug("\tDbmsVersion = $DbmsVersion");

  my $internalConnStrUsingOsAuth = 
    using_OS_authentication($InternalConnStr_ref->[0]);

  log_msg_debug("\tusing_OS_authentication(InternalConnStr[0]) = ".
                $internalConnStrUsingOsAuth);

  # return true only if
  #   - the caller requested that we use all available instances
  #   - a specific instance was not specified,
  #   - we were able to obtain instance connect strings for more than one 
  #     instance (which will enable us to connect to those instances to 
  #     start sqlplus processes),
  #   - user connect string does not rely on OS authentication (which 
  #     would prevent us from being able to start sqlplus processes on 
  #     instances other than the default instance), and
  #   - we are connected to a post-12.1 CDB or (i.e. if we are connected to
  #     a 12.1 CDB), the internal connect string does not rely on OS 
  #     authentication (which would prevent us from opening PDBs in 
  #     reset_pdb_modes on 12.1 instances other than the default instance)

  my $multInstFeasible;

  if ($AllInstRequested && 
      $InternalConnStr_ref->[0] !~ /@/ &&
      %$InstConnStr_ref && (scalar keys %$InstConnStr_ref) > 1 &&
      !$userConnStrUsingOsAuth &&
      !($DbmsVersion =~ "^12.1" && $internalConnStrUsingOsAuth)) {
    $multInstFeasible = 1;
  } else {
    $multInstFeasible = 0;
  }

  log_msg_debug("returning $multInstFeasible");

  return $multInstFeasible;
}

# subroutines which may be invoked by callers outside this file and variables 
# that need to persist across such invocations
{
  # log level values

  # catcon-defined default logging level
  use constant CATCON_LOG_LEVEL_DFLT       => 0;

  use constant CATCON_LOG_LEVEL_DEBUG      => 1;
  use constant CATCON_LOG_LEVEL_VERBOSE    => 2;

  use constant CATCON_LOG_LEVEL_INFO       => 3;
  use constant CATCON_LOG_LEVEL_WARN       => 4;
  use constant CATCON_LOG_LEVEL_ERROR      => 5;
  use constant CATCON_LOG_LEVEL_FATAL      => 6;

  # lowest log level
  use constant CATCON_MIN_LOG_LEVEL => CATCON_LOG_LEVEL_DEBUG;

  # strings corresponding to log levels
  use constant LOG_LEVEL_TO_STRING  => {
    &CATCON_LOG_LEVEL_DEBUG      => 'DEBUG',
    &CATCON_LOG_LEVEL_VERBOSE    => 'VERBOSE',
    &CATCON_LOG_LEVEL_INFO       => 'INFO',
    &CATCON_LOG_LEVEL_WARN       => 'WARN',
    &CATCON_LOG_LEVEL_ERROR      => 'ERROR',
    &CATCON_LOG_LEVEL_FATAL      => 'FATAL',
  };

  # flags modifying behaviour of log_msgs

  # only print the message to Console (STDERR)
  use constant LOG_MSG_F_CONSOLE_ONLY    => 1;

  # only print the message to the log file
  use constant LOG_MSG_F_LOG_FILE_ONLY   => 2;

  # print message without prepending log4j-style info
  use constant LOG_MSG_F_NO_LOG4J_PREFIX => 4;
  
  # indicator of whether we are invoking from catcon or rman 
  my $catcon_InvokeFrom = CATCON_INVOKEFROM_CATCON;

  # have all the vars that need to persist across calls been initialized?
  # computed
  my $catcon_InitDone;
  
  # name of the directory for sqlplus script(s), as supplied by the caller
  my $catcon_SrcDir;

  # name of the directory for log file(s), as supplied by the caller
  my $catcon_LogDir;

  # base for paths of log files
  my $catcon_LogFilePathBase;

  # number of processes which will be used to run sqlplus script(s) or SQL 
  # statement(s) using this instance of catcon.pl, as supplied by the caller; 
  my $catcon_NumProcesses;

  # external degree of parallelism, i.e. if more than one script using 
  # catcon will be invoked simultaneously on a given host, this parameter 
  # should contain a number of such simultaneous invocations; 
  # may remain undefined;
  my $catcon_ExtParallelDegree;

  # indicator of whether echo should be turned on while running sqlplus 
  # script(s) or SQL statement(s), as supplied by the caller
  my $catcon_EchoOn;

  # indicator of whether output of running scripts should be spooled into 
  # Container- and script-specific spool files, as supplied by the caller
  my $catcon_SpoolOn;

  # catcon logging level setting. If a message level is >= $catcon_LogLevel, 
  # log_msg will write it to STDERR and $CATCONOUT; 
  # 
  # CATCON_LOG_LEVEL_INFO will be the default (and the highest) catcon logging
  # level. (At least for now) WARN/ERROR/FATAL will be used only to specify 
  # logging level of individual messages, i.e. at the very least, INFO 
  # messages will be written to STDERR and $CATCONOUT
  my $catcon_LogLevel = CATCON_LOG_LEVEL_DFLT;

  # If the catcon log level is set to its lowest possible setting (DEBUG), 
  # all messages sent to log_msg_ will get printed to STDERR and/or $CATCONOUT.
  # However, if catcon log level is not set to the lowest setting, messages 
  # with lower log level will not autimatically get printed to 
  # STDERR/CATCONOUT, but it is desirable to have access to them if an error 
  # condition is encountered.
  #
  # To that end, we will maintain a circular buffer (@catcon_DiagMsgs) which 
  # will be used to store messages, regardless of whether they got printed to 
  # STDERR or $CATCONOUT. Contents of this buffer which will be written to 
  # STDERR and CATCONOUT before the error message itself to facilitate 
  # diagnosing the cause of the error.  
  #
  # By default, @catcon_DiagMsgs will store the last 1000 messages, but a user 
  # can overwrite it by setting an environment variable 
  # CATCON_DIAG_MSG_BUF_SIZE to
  # - a non-negative integer which will indicate the number of messages which 
  #   will be saved (no messages will be saved if it is set to 0) or
  # - a word UNLIMITED (regardless of case) which will case catcon to save 
  #   ALL messages
  #
  # If $CATCON_DIAG_MSG_BUF_SIZE is set to a value not described above, a 
  # warning message will be generated anbd the default number of messages 
  # will be preserved.
  #
  # After an error message is reported and contents of @catcon_DiagMsgs are
  # written to STDERR and CATCONOUT, $catcon_LogLevel will be set to the 
  # lowest level and @catcon_DiagMsgs will be undefined (since it will no 
  # longer be needed as the latter will cause all subsequent messages to be 
  # written to STDERR and/or CATCONOUT.) 
  #
  my @catcon_DiagMsgs;

  # will be set to the maximum number of messages which will be retained in 
  # @catcon_DiagMsgs unless the caller indicated that its size should be 
  # UNLIMITED in which case it will be undef'd
  my $catcon_DiagMsgsSize = 1000;

  # position within @catcon_DiagMsgs where the next message should be stored 
  # (and, unless it points past the last element of @catcon_DiagMsgs, where 
  # the earliest message retained in @catcon_DiagMsgs can be found; otherwise, 
  # earliest message will be found in $catcon_DiagMsgs[0])
  my $catcon_DiagMsgsNext = 0;

  # an indicator of whether we are being invoked from a GUI tool which on 
  # Windows means that the passwords and hidden parameters need not be hidden
  my $catcon_GUI;

  # indicator of whether the caller wants us to check whether scripts end 
  # without committing the current transaction; caller can modify by calling 
  # catconXact
  my $catcon_UncommittedXactCheck = 0;

  # indicator of whether we were instructed to run scripts in ALL PDBs and 
  # then in Root; caller can modify by calling catconReverse
  my $catcon_PdbsThenRoot = 0;

  # indicator of whether non-existent and closed PDBs should be ignored when 
  # constructing a list of Containers against which to run scripts
  # defaults to FALSE; caller can modify by calling catconForce
  my $catcon_IgnoreInaccessiblePDBs = 0;

  # indicator to ignored all validation of Pdb's when 
  # constructing a list of Containers against which to run scripts
  my $catcon_IgnoreAllInaccessiblePDBs = 0;

  # indicator of whether catcon should avoid reverting modes of PDBs; defaults
  # to FALSE; can be modified by calling catconSkipRevertingPdbModes if the 
  # caller modified mode in which PDBs are opened after calling catcon to run 
  # some scripts on them, in which case the caller will assume 
  # responsibility for the mode in which they will be open when catcon exits
  my $catcon_SkipRevertingPdbModes = 0;

  my $catcon_EZConnect;

  # Bug 25507396: if defined, this variable is expected to contain a name of 
  #   a PDB to which EZConnect strings contained in $catcon_EZConnect (which 
  #   MUST be defined if this variable is defined) will take us. 
  #
  #   All scripts will be run ONLY against this PDB, likely, but not 
  #   necessarily, using credentials of a local user; if this variable is 
  #   defined, catcon will avoid issuing ALTER SESSION SET CONTAINER to 
  #   switch to the PDB before running a script (which should be unnecessary 
  #   since the EZConnect string will take us directly to it) and to the Root 
  #   after a script has been run.
  #
  #   If this variable is defined, there is little reason to provide an 
  #   inclusive/exclusive Container list, so an attempt to supply those when 
  #   this variable contains a name of a PDB will result in an error
  my $catcon_EZconnToPdb;

  # an indicator of whether _oracle_script should NOT be set even if we are 
  # not running user scripts (in which case it is never set.)
  my $catcon_NoOracleScript = 0;

  # errors that a caller can instruct us to ignore; for example, 
  # if a caller indicates that we can ignore script_path errors, 
  # $catcon_ErrorsToIgnore{script_path} will get set to 1 and if 
  # validate_script_path cannot validate the specified script path, the 
  # errors will be reported but ignored
  my %catcon_ErrorsToIgnore = (
      script_path => 0
    );

  # name of a Root of a Federation against members of which script(s) are 
  # to be run; if defined and $catcon_UserScript is not set, _federation_script
  # will be set
  my $catcon_FedRoot;

  # Array of 2 elements: 
  # - connect string used when running SQL for internal statements: this
  #   should be done as sys
  # - same as above, but with password redacted - will be used when producing 
  #   diagnostic output (bug 21202842)
  # computed
  my @catcon_InternalConnectString;        

  # Array of 2 elements: 
  # - connect string used when running sqlplus script(s) or SQL statement(s) in
  #   the context of the user passed in.
  # - same as above, but with password redacted - will be used when producing 
  #   diagnostic output (bug 21202842)
  # computed
  my @catcon_UserConnectString;

  # password used when connecting to the database to run sqlplus script(s) or 
  # SQL statement(s)
  my $catcon_UserPass;

  # names of ALL containers of a CDB if connected to one; empty if connected 
  # to a non-CDB;
  # computed
  my @catcon_AllContainers;

  # hash with keys consisting of names of App Roots
  my %catcon_AppRootInfo;

  # hash mapping names of App Root Clones to their App Roots. Will remain 
  # undefined if processing user scripts
  my %catcon_AppRootCloneInfo;

  # hash mapping names of App PDBs to their App Roots.
  my %catcon_AppPdbInfo;

  # indicators (Y or N) of whether a Container in @catcon_AllContainers is open
  my %catcon_IsConOpen;

  # empty if connected to a non-CDB; same as @catcon_AllContainers if the 
  # user did not specify -c or -C flag, otherwise, consists of 
  # names of Containers explicitly included (-c) or not explicitly 
  # excluded (-C);
  #
  # NOTE:
  #   by default, catconExec will run scripts/statements in all Containers 
  #   whose names are found in catcon_Containers; however, this can be 
  #   modified by passing to catconExec a list of Containers to include or 
  #   exclude during the current invocation 
  # computed
  my @catcon_Containers;

  # environment variable containing EZConnect Strings for instances to be 
  # used to run scripts
  my $EZCONNECT_ENV_TAG = "CATCONEZCONNECT";

  # name of the Root if operating on a Consolidated DB
  my $catcon_Root;

  # array of file handle references; 
  my @catcon_FileHandles;

  # Not all SQL*Plus processes that we spawn end up doing any work.  This 
  # array will be used to keep track of which processes actually got to do 
  # some work so that in the end we can delete log files pertaining to 
  # processes that did not
  my @catcon_ActiveProcesses;

  # array of process ids
  my @catcon_ProcIds;

  # are we running on Windows?
  my $catcon_Windows;
  my $catcon_DoneCmd;

  # string introducing an argument to SQL*PLus scripts which will be supplied 
  # using clear text
  my $catcon_RegularArgDelim;

  # string introducing an argument to SQL*PLus scripts which will have to be 
  # specified by the user at run-time
  my $catcon_SecretArgDelim;

  # if strings used to introduce "regular" as well as secret arguments are 
  # specified and one is a prefix of the other and we encounter a string 
  # that could be either a regular or a secret argument, we will resolve in 
  # favor of the longer string.  
  # $catcon_ArgToPick will be used to determine how to resolve such conflicts, 
  # should they occur; it will remain set to 0 if such conflicts cannot occur 
  # (i.e. if both strings are not specified or if neither is a prefix of the 
  # other)

  # pick regular argument in the event of conflict
  my $catcon_PickRegularArg;
  # pick secret argument in the event of conflict
  my $catcon_PickSecretArg;

  my $catcon_ArgToPick = 0;

  # reference to an array of statements which will be executed in every 
  # process before it is asked to run the first script
  my $catcon_PerProcInitStmts;

  # reference to an array of statements which will be executed in every 
  # process after it finishes runing the last script
  my $catcon_PerProcEndStmts;

  # if defined, will contain name of error logging table
  my $catcon_ErrLogging;

  # if set, SET ERRORLOGGING ON IDENTIFIER statement will NOT be issued
  my $catcon_NoErrLogIdent;

  # force_pdb_modes() gets handed an array of names of PDBs which need to be 
  # open in a specified mode (see catcon_AllPdbMode) before running scripts 
  # against them.  
  #
  # Some of these PDBs may already be open in the desired mode, while others 
  # may need to be closed and reopened in the desired mode. Since catconExec 
  # (which invokes force_pdb_modes() if $catcon_AllPdbMode indicates that the 
  # caller has requested that all relevant PDBs be open in a specified mode) 
  # may be invoked repeatedly with different lists of Containers on which to 
  # operate, we need to be able to compute a list of PDBs whose mode needs to 
  # be checked and possibly changed without checking PDBs which have 
  # previously been determined to be open in the correct mode.
  #
  # This hash will be used to keep track of PDBs which we know to be open 
  # in requested mode
  my %catcon_PdbsOpenInReqMode;

  # mode in which all PDBs (including PDB$SEED, so if one insists on setting 
  # both $catcon_SeedPdbMode and $catcon_AllPdbMode, the latter will take 
  # precedence) to be operated upon should be open
  #
  # This variable does not get set in catconInit (to avoid changing its 
  # signature), so we initialize it in such a way that if the caller does 
  # not invoke the subroutine that sets it, it will end up being set to the 
  # same value as if the caller were to invoke it and tell us that the user 
  # has not specified mode in which all PDBs should be opened
  my $catcon_AllPdbMode = CATCON_PDB_MODE_NA;

  # $catcon_SeedPdbMode serves the same purpose as $catcon_AllPdbMode, but 
  # only for PDB$SEED 
  #
  # NOTE: if a caller specifies a value for $catcon_AllPdbMode, it will 
  #       override whatever value was specified for $catcon_SeedPdbMode, so 
  #       there is never a reason to set them both
  my $catcon_SeedPdbMode = CATCON_PDB_MODE_NA;

  # $catcon_RevertUserPdbModes will be used to store 
  #   (mode.' '. restricted) => ref {instance-name => ref @pdb-names}
  # records for user PDBs on which we need to operate and which were not open 
  # in the mode specified by the caller. Contents of this hash will act as a 
  # reminder that these PDBs need to be reopened in their erstwhile modes as 
  # a part of catconRevertPdbModes().
  # The reason for choosing this hash layout is to minimize number of
  #  ALTER PDB OPEN <mode> [RESTRICTDED] INSTANCES=...
  # statements that need to be issued to restore user PDB modes in 
  # catconRevertPdbModes.
  #
  # NOTE: if a PDB was not opened in desired mode (as indicated by 
  #       $catcon_AllPdbMode) when catconExec() discovers for the first time 
  #       that it needs to run some scripts or statements against it, it will 
  #       call force_pdb_modes() which will call reset_pdb_modes() which will 
  #       close it and then reopen in desired mode on all instances.  From 
  #       that point on, that PDB will remain in that mode until it gets 
  #       reset to its original mode in catconRevertPdbModes().  
  #
  #       It is IMPORTANT that restoring PDB's mode happens AFTER all 
  #       processes opened in catconInit2() have been killed because otherwise 
  #       ALTER PDB CLOSE IMMEDIATE issued by reset_pdb_modes() will 
  #       cause any of the processes which happen to be connected to that PDB
  #       to become unusable (they will be disconnected from the database 
  #       and any statements sent to them will fail.)  
  #       As a side note, before we fixed bug 13072385, reset_pdb_modes() 
  #       used to issue ALTER PDB CLOSE (without IMMEDIATE), which hung if 
  #       any process was connected to PDB$SEED (which was the only PDB on 
  #       which it was operating (and at that time the subroutine was called 
  #       reset_seed_pdb_mode))
  #
  my %catcon_RevertUserPdbModes;

  # %catcon_RevertSeedPdbMode serves the same purpose as 
  # %catcon_RevertUserPdbModes but only for PDB$SEED
  my %catcon_RevertSeedPdbMode;

  # environment variable containing user password
  use constant USER_PASSWD_ENV_TAG => 'CATCONUSERPASSWD';

  # environment variable containing internal password
  use constant INTERNAL_PASSWD_ENV_TAG => 'CATCONINTERNALPASSWD';

  # a global variable indicates whether catcon is called by cdb_sqlexec
  # If true then the _oracle_script will not be set and it will not execute 
  # in Root or PDB$SEED
  my $catcon_UserScript = 0;

  # this hash will be used to save signal handlers in effect before catconInit2
  # was invoked so that they can be restored at the end of catconWrapUp
  my %catcon_SaveSig;

  # catcon log file handle
  my $CATCONOUT;
  my $RMANOUT;

  # Bug 23020062: variable indicating whether pdb_lockdown should be disabled
  # while running script.
  my $catcon_DisableLockdown = 0;

  # LRG 19633516: variable indicating whether death of a spawned SQL*Plus 
  # process should result in catcon dying
  my $catcon_RecoverFromChildDeath = 0;

  # Bug 22887047: an index of an entry in @catcon_ProcIds that contains id of
  #   a process that died unexpectedly; will be set to -1 unless it gets set 
  #   by catconBounceDeadProcess when it gets called from next_proc upon 
  #   encountering a dead process
  my $catcon_DeadProc = -1;

  # Bug 22887047: id of a process that died unexpectedly; should not be 
  #   referenced unless $catcon_DeadProc != -1
  my $catcon_DeadProcId;

  # 
  # Bug 21871308: every SQL*Plus process that we start (in start_processes), 
  #   will add a line to the "kill all sessions script" which will be run from 
  #   the END block if SIGINT/SIGTERM/SIGQUIT is caught causing catcon to die. 
  #   Running the "kill all sessions script" will ensure that all SQL*Plus 
  #   processes started by us end gracefully, releasing their resources.
  #
  my $catcon_KillAllSessScript;

  # Bug 21871308: name of a script that will be invoked to generate a
  #   "kill session script" for a new SQL*Plus process
  my $catcon_GenKillSessScript;

  # Oracle DBMS version. Used to ensure that SQL statements generated by this
  # script are compatible with the version of the RDBMS to which we connect
  my $catcon_DbmsVersion;

  # an indicator of whether catcon should open PDBs in the mode indicated by 
  # $catcon_AllPdbMode (as long as that mode is not set to 
  # CATCON_PDB_MODE_UNCHANGED) on all available instances of a RAC database.
  my $catcon_AllInst;

  # hash mapping names of instances to 
  # - number of SQL*Plus processes that can be allocated for that instance;
  #   will be set by get_num_procs_int
  #   ($catcon_InstProcMap{$inst}->{MAX_PROCS})
  # - number of SQL*Plus processes spawned on that instance;
  #   will be 
  #   - created or updated by start_processes as new processes get spawned and 
  #   - updated by end_processes as processes get killed
  #   ($catcon_InstProcMap{$inst}->{NUM_PROCS})
  # - offset of the id of the first such process in @catcon_ProcIds
  #   this entry will be
  #   - created if at least one SQL*PLus process has been spawned on a 
  #     given instance, 
  #   - updated by end_processes as processes get killed, 
  #   - deleted if all processes on a given instance get killed (e.g. when 
  #     catconUpgEndSessions kills all but one SQL*Plus process)
  #   ($catcon_InstProcMap{$inst}->{FIRST_PROC})
  # if we are processing PDBs using all available instances
  my %catcon_InstProcMap;

  # hash mapping ids of processes (found in @catcon_ProcIds) to names of 
  # instances to which they are connected; currently will be used when we are
  # trying to recover from a death of a SQL*Plus process if it is posible 
  # that not all of them are connected to the same instance, i.e. if 
  # %catcon_InstProcMap is defined
  my %catcon_ProcInstMap;

  # Bug 20193612: this variable will be used to save a reference to
  # instance->pdbs hash returned by force_pdb_modes.  
  #
  # The reason for saving it in this variable instead of just using value
  # returned by force_pdb_modes is that force_pdb_modes will not compute 
  # it if catconExec gets invoked repeatedly with the same set of PDBs 
  # (or with a subsequent set of PDBs being a subset of an earlier set), but 
  # we still may need this information for forking of child processes to 
  # handle processing PDBs open in different instances 
  #
  # NOTE: The reference will be saved only if the hash represents more 
  #       than 1 instance (since if it represents only 1 instance, all 
  #       processing will take place on the default instance, and the 
  #       inst->pdb mapping is unnecessary)
  my $catcon_ForcePdbModeInstPdbMap;

  # will be set to 1 in a forked child process; 
  # will be used by log_msg to deduce that it should not be writing output to 
  # STDERR to avoid confusion which would arise from multiple child processes 
  # dumping output to the same STDERR
  my $catcon_ChildProc;

  # an indicator of whether catcon was called in the course of upgrade
  my $catcon_RunningUpgrade;

  # Bug 25315864: hash mapping instance name to a connect string:
  # - if connected to a DB open on a single instance, instance name will be 
  #   mapped to an empty string 
  #
  #    NOTE: in some cases (bug 25366291), gen_inst_conn_strings which is 
  #          responsible for populating this hash may fetch 0 rows from the 
  #          RDBMS and leave this hash undefined.  Rather than treating it as 
  #          an error, we will force all processing to occur on the default 
  #          instance
  # - otherwise, instance name(s) will be mapped to <connect-string>(s)
  my %catcon_InstConnStr;

  # Bug 25363697: this variable will be used to remember whether the last 
  #  script run by catconExec in a given container was catshutdown.sql, which 
  #  will tell us to not send diagnostic statements to sqlplus processes 
  #  until the next script is run in that container (the assumption being 
  #  that that script will start the Container making it safe to send 
  #  diagnostic statements to a sqlplus process connected to the container.  
  #
  #  Prior to this change, code in catconExec tried to handle this by keeping 
  #  track of scripts executed during its current invocation, but that failed 
  #  to account for the script invoked during the preceeding invocation
  my %catcon_CatShutdown;

  # Bug 25392172: this variable will be used to store name of the default 
  #   instance
  my $catcon_DfltInstName;

  # Bug 26135561: this variable will contain absolute path of sqlplus binary;
  # 
  # NOTE: catconInit2 invokes find_in_path to set this variable before 
  #       calling any subroutines that invoke sqlplus, but if any subroutine
  #       in this package which call sqlplus can be invoked without first 
  #       calling catconInit2, we want it to use sqlplus found in $PATH
  my $catcon_Sqlplus = "sqlplus";

  # If the caller requested that all available RAC instances be used, this 
  # variable will contain an indicator of whether we are, indeed, connected 
  # to a RAC database
  my $catcon_IsRac = "";

  # If the caller requested that all available RAC instances be used, this 
  # array will contain names of instances which were stopped and need to be 
  # started before running scripts and then stopped again when catcon wraps 
  # things up
  my @catcon_IdleRacInstances;

  # If the caller requested that all available RAC instances be used, this 
  # array will contain names of RAC instances that were running when catcon 
  # was invoked
  my @catcon_RunningRacInstances;

  # DB unique name
  my $catcon_DbUniqueName;

  # If catcon is called in the course of running upgrade, the client 
  # (catctl.pl) expects that the number of SQL*Plus processes involved in 
  # processing each PDB is determined by the value that was passed to 
  # catconInit as $NumProcesses, unless, of course, catconUpgEndSessions 
  # was invoked, in which case only a single process should be involved 
  # in processing of each PDB.  
  #
  # The situation gets more complicated if the caller also asked us to 
  # use all available RAC instances, and the database on which wwe will be 
  # operating is, indeed, a RAC CDB with multiple instances, because in such 
  # cases we ignore the number of processes supplied by the caller and start 
  # as many processes on each instance so that we can upgrade multiple PDBs 
  # in parallel using processes started on available RAC instances.  
  #
  # Firstly, we don't really want to shut down (in catconUpgEndSessions) and 
  # restart (in catconUpgStartSessions) dozens of SQL*Plus processes. 
  #
  # Secondly, we want to be sure to have a correct number 
  # (catconInit::$NumProcesses if catconUpgEndSessions was not called 
  # or if the more recent call to catconUpgEndSessions was followed 
  # by a call to catconUpgStartSessions and 1 otherwise) of SQL*Plus
  # processes dedicated to running scripts against every PDB.
  #
  # To that end, we will
  # - define 2 variables which will be used if the caller of catconInit 
  #   indicated that catcon will be involved in running upgrade using all 
  #   available RAC instances:
  #   - catcon_DfltProcsPerUpgPdb which will used to remember number of 
  #     processes that the caller wants to be involved in upgrading a PDB 
  #     (i.e. catconInit::$NumProcesses) and
  #   - catcon_ProcsPerUpgPdb which will be set to catcon_DfltProcsPerUpgPdb 
  #     in catconInit and catconUpgStartSessions and to 1 in 
  #     catconUpgEndSessions and will be used in catconExec to ensure that 
  #     each thread spawned to run scripts against a given PDB is assigned a 
  #     correct number of SQL*Plus processes
  my $catcon_DfltProcsPerUpgPdb;
  my $catcon_ProcsPerUpgPdb;

  # print contents of a @catcon_DiagMsgs
  sub dumpDiagMsgs($) {
    my ($fileHndl) = @_;

    print $fileHndl "Diagnostic output produced in conjunction with ".
                    "reporting an error message:\n{\n\n";
          
    # print contents of @catcon_DiagMsgs using specified file handle

    # will contain offset of the next message to be displayed
    my $msgIdx;
    
    # if @catcon_DiagMsgs buffer size is unlimited, the earliest message 
    # will be found in $catcon_DiagMsgs[0]; otherwise, unless 
    # $catcon_DiagMsgsNext points past the end of @catcon_DiagMsgs, the 
    # earliest message in the circular buffer will be found in 
    # $catcon_DiagMsgs[$catcon_DiagMsgsNext]
    if (defined $catcon_DiagMsgsSize) {
      for ($msgIdx = $catcon_DiagMsgsNext; 
           $msgIdx <= $#catcon_DiagMsgs; $msgIdx++) {
        print $fileHndl $catcon_DiagMsgs[$msgIdx];
      }
    }

    # print remaining messages
    for ($msgIdx = 0; $msgIdx < $catcon_DiagMsgsNext; $msgIdx++) {
      print $fileHndl $catcon_DiagMsgs[$msgIdx];
    }

    print $fileHndl "}\nEnd of diagnostic output\n\n";
  }

  #
  # log_msg_
  #
  # NOTE: this subroutine is not meant to be invoked directly (otherwise 
  #       message will not display correct package, subroutine and line 
  #       number info.)  
  #       Please use log_msg_{debug|verbose|info|console|no_console|warn|error|
  #       fatal}
  #
  # Description:
  #   This subroutine will write supplied message to both STDERR and 
  #   $Handle if its logging level is at least as high as the catcon 
  #   logging level.
  #
  #   If catcon logging level is not set to the lowest possible value, it will
  #   also insert the message into @catcon_DiagMsgs for use if an error 
  #   message gets reported
  #
  #   If this subroutine is called to log an ERROR or FATAL message while 
  #   logging level is not at its lowest possible setting (meaning that 
  #   @catcon_DiagMsgs may contain messages which were not sent to STDERR and 
  #   Handle),
  #   - contents of @catcon_DiagMsgs will get dumped to STDERR and Handle,
  #     after which @catcon_DiagMsgs will get undef'd as its contents will be 
  #     of no further use,
  #   - $catcon_LogLevel will get reset to the lowest possible setting 
  #     (causing all subsequent messages to be written to STDERR and Handle)
  #
  sub log_msg_($$$) {
    my ($LogMsg, $MsgLogLvl, $Flags) = @_;

    my $Handle;

    # OUTPUT FILE Handle may either be called from catcon.pm or rman.pm
    # decide which file handle to use 
    if ($catcon_InvokeFrom == CATCON_INVOKEFROM_CATCON) {
      $Handle = $CATCONOUT;
    }
    elsif ($catcon_InvokeFrom == CATCON_INVOKEFROM_RMAN) {
      $Handle = $RMANOUT;
    }

    # if an ERROR or FATAL message was received and we have accumulated 
    # messages in @catcon_DiagMsgs, we need to display them on the console 
    # and print them to Handle, then undef @catcon_DiagMsgs which will no 
    # longer be needed
    my $printAllSavedMsgs = 0;

    if ($catcon_LogLevel == CATCON_LOG_LEVEL_DFLT) {
      # if an error is being reported before we had a chance to set 
      # $catcon_LogLevel, default to DEBUG
      $catcon_LogLevel = CATCON_LOG_LEVEL_DEBUG;
    }

    if (($MsgLogLvl == CATCON_LOG_LEVEL_ERROR || 
        $MsgLogLvl == CATCON_LOG_LEVEL_FATAL) &&
        $catcon_LogLevel > CATCON_MIN_LOG_LEVEL) {
      # ERROR or FATAL message being reported while catcon log level is 
      # not set to its lowest possible value, meaning that there may be some 
      # messages saved in @catcon_DiagMsgs which need to be displayed before
      # displaying the ERROR or FATAL message

      # reset catcon log level to its lowest possible setting so all future 
      # messages sent to log_msg get written to STDERR and/or CATCONOUT
      $catcon_LogLevel = CATCON_MIN_LOG_LEVEL;

      # if any messages were saved in @catcon_DiagMsgs, remember that they 
      # need to be printed before displaying a message supplied by the caller
      if (@catcon_DiagMsgs)  {
        $printAllSavedMsgs = 1;
      }
    }

    # if writing a message to $Handle or appending it to @catcon_DiagMsgs, 
    # we need to prepend date, time and message tag (based on its log level) 
    # to the caller's message
    my $msgPrefix;

    # subroutine where a message was generated
    my $subroutine;

    # construct message prefix similar to that generated by log4j:
    #   date time log_level> file:line package:subroutine - 
    #
    # NOTE:
    #   caller(1) returns file and line# of the call to log_msg_* subroutine,
    #   but if we were to use package:subroutine returned by caller(1), we 
    #   would see log_msg_*, which is not very useful, so to get names of 
    #   the package and subroutine from which log_msg_* was called, we need 
    #   to reach to the next frame
    my ($fileName, $line) = (caller(1))[1..2];
    $subroutine = (caller(2))[3];
    
    $msgPrefix = TimeStamp()." ".LOG_LEVEL_TO_STRING->{$MsgLogLvl}."> ".
                 $fileName.":".$line.' '.$subroutine." - ";

    # if $LogMsg contains \n chars, output written to the log file or 
    # appended to @catcon_DiagMsgs needs to have each line start with 
    # $msgPrefix; $multiLineMsg will keep track of whether a message contains 
    # embedded \n's
    my $multiLineMsg;

    if ($MsgLogLvl >= $catcon_LogLevel) {
      # if displaying saved messages, always print them to the console
      # NOTE: if we decided to dump contents of @catcon_DiagMsgs above, we 
      #       also reset $catcon_LogLevel to its minimum value, so the above 
      #       test will succeed
      if ($printAllSavedMsgs) {
        # display contents of @catcon_DiagMsgs on the console
        dumpDiagMsgs(*STDERR);
      }

      #
      # A message supplied by the caller will be written to STDERR if
      # - Handle is not defined (we want to be sure it gets written 
      #   somewhere) or
      # - the message's log level indicates that it is to be written ONLY to 
      #   the console or
      # - the message is not being issued by a child process and $Flags
      #   does NOT indicate that it is NOT to be written to console
      if (! defined $Handle|| $Flags & LOG_MSG_F_CONSOLE_ONLY ||
          (!$catcon_ChildProc && !($Flags & LOG_MSG_F_LOG_FILE_ONLY))) {
        print STDERR $subroutine.": ".$LogMsg."\n\n";
      }

      # this subroutine may get called before $Handle has been initialized, 
      # so check if it has been defined before trying to print to it
      if (defined $Handle) {
        # if displaying saved messages, print them to $Handle
        if ($printAllSavedMsgs) {
          # print contents of @catcon_DiagMsgs to $Handle
          dumpDiagMsgs($Handle);
        }

        # print message supplied by the caller to $Handle unless we were 
        # instructed to only print it to the console
        if (!($Flags & LOG_MSG_F_CONSOLE_ONLY)) {
          if ($Flags & LOG_MSG_F_NO_LOG4J_PREFIX) {
            print $Handle $LogMsg."\n\n";
          } else {
            # if $LogMsg contains \n chars, ensure that each line starts with 
            # $msgPrefix
            ($multiLineMsg = $LogMsg) =~ s/\n/\n$msgPrefix/g;
            
            print $Handle $msgPrefix.$multiLineMsg."\n\n";
          }
        }
      }
    }

    if ($printAllSavedMsgs) {
      # messages saved in @catcon_DiagMsgs have been printed to the console 
      # and, if feasible, to $Handle, so now we want to undefine 
      # @catcon_DiagMsgs since it will no longer be needed
      undef @catcon_DiagMsgs;
    } elsif ($catcon_LogLevel > CATCON_MIN_LOG_LEVEL) {
      # unless all messages get written to STDERR and/or Handle, insert 
      # this message into @catcon_DiagMsgs whose contents will be written to 
      # STDERR and/or Handle if an ERROR or FATAL message is reported

      # if $LogMsg contains \n chars, ensure that each line starts with 
      # $msgPrefix
      if (!$multiLineMsg) {
        ($multiLineMsg = $LogMsg) =~ s/\n/\n$msgPrefix/g;
      }

      if (! defined $catcon_DiagMsgsSize) {
        # retaining all messages
        push @catcon_DiagMsgs, $msgPrefix.$multiLineMsg."\n\n";
        $catcon_DiagMsgsNext++;
      } elsif ($catcon_DiagMsgsSize) {
        # retaining last $catcon_DiagMsgsSize (> 0) messages
        if ($catcon_DiagMsgsNext == $catcon_DiagMsgsSize) {
          # need to wrap around to the beginning of the circular buffer
          $catcon_DiagMsgsNext = 0;
        }

        $catcon_DiagMsgs[$catcon_DiagMsgsNext++] = 
          $msgPrefix.$multiLineMsg."\n\n";
      }
    }
  }

  #
  # log_msg_debug - log a message with DEBUG logging level
  # 
  sub log_msg_debug($) {
    log_msg_($_[0], CATCON_LOG_LEVEL_DEBUG, 0);
  }

  #
  # log_msg_verbose - log a message with VERBOSE logging level
  # 
  sub log_msg_verbose($) {
    log_msg_($_[0], CATCON_LOG_LEVEL_VERBOSE, 0);
  }

  #
  # log_msg_info - log a message with INFO logging level
  # 
  sub log_msg_info($) {
    log_msg_($_[0], CATCON_LOG_LEVEL_INFO, 0);
  }

  #
  # log_msg_console - log a message with INFO logging level ONLY to the console
  # 
  sub log_msg_console($) {
    log_msg_($_[0], CATCON_LOG_LEVEL_INFO, LOG_MSG_F_CONSOLE_ONLY);
  }

  #
  # log_msg_console - log a message with INFO logging level to the console 
  #                   AND to the log file without prepending log4j-style info
  # 
  sub log_msg_no_log4j($) {
    log_msg_($_[0], CATCON_LOG_LEVEL_INFO, LOG_MSG_F_NO_LOG4J_PREFIX);
  }

  #
  # log_msg_banner - log a message with INFO level only to the log file 
  #                  without prepending log4j-style info; used to print a 
  #                  catcon banner 
  # 
  sub log_msg_banner($) {
    log_msg_($_[0], CATCON_LOG_LEVEL_INFO, 
             LOG_MSG_F_LOG_FILE_ONLY | LOG_MSG_F_NO_LOG4J_PREFIX);
  }

  #
  # log_msg_warn - log a message with WARN logging level
  # 
  sub log_msg_warn($) {
    log_msg_($_[0], CATCON_LOG_LEVEL_WARN, 0);
  }

  #
  # log_msg_error - log a message with ERROR logging level
  # 
  sub log_msg_error($) {
    log_msg_($_[0], CATCON_LOG_LEVEL_ERROR, 0);
  }

  #
  # log_msg_fatal - log a message with FATAL logging level
  # 
  sub log_msg_fatal($) {
    log_msg_($_[0], CATCON_LOG_LEVEL_FATAL, 0);
  }

  #
  # set_log_file_base_path
  #
  # Parameters:
  #   - log directory, as specified by the user
  #   - base for log file names
  #
  # Returns
  #   - 0  ERROR 
  #   - Log Base File Name
  #
  sub set_log_file_base_path ($$) {
    my ($LogDir, $LogBase) = @_;

    my $RetLogFilePathBase = 0;

    # NOTE:
    #   log directory and base for log file names is handled first since we 
    #    need them to open the catcon output file

    # if directory for log file(s) has been specified, verify that it exists 
    # and is writable
    if (!valid_log_dir($LogDir)) {
      log_msg_error("Unexpected error returned by valid_log_dir");
      return 0;
    }

    # determine base for log file names
    # the same base will be used for spool file names if $SpoolOn is true
    $RetLogFilePathBase = get_log_file_base_path($LogDir, $LogBase);

    if (!$RetLogFilePathBase) {
      log_msg_error("Unexpected error encountered in get_log_file_base_path");
      return 0;
    }

    # name of log file that will be created for this process
    my $procLogFileName = proc_log_file_name($RetLogFilePathBase);

    # open $CATCONOUT.  If opened successfully, all messages generated by 
    # catcon with log level not lower than $catcon_LogLevel should be written 
    # to $CATCONOUT to ensure that we can find it after running an lrg 
    # involving catcon on the farm or through some other Perl script
    if (!sysopen($CATCONOUT, $procLogFileName, 
                 O_CREAT | O_RDWR | O_APPEND, 0600)) {
      # message will be written to STDERR
      log_msg_error("unable to open ($!) $procLogFileName as CATCONOUT");
      log_msg_error("\tadditional info: $^E");
      return 0;
    }

    # last message which may be seen only on the console (if catcon log level 
    # is greater than log level of any messages generated during its execution)
    log_msg_console("ALL catcon-related output will be written to [".
                    "$procLogFileName]");

    # make $CATCONOUT "hot" so diagnostic and error message output does not 
    # get buffered
    select((select($CATCONOUT), $|=1)[0]);

    log_msg_no_log4j("catcon: See [${RetLogFilePathBase}*.log] files for ".
                     "output generated by scripts");
    log_msg_no_log4j("catcon: See [${RetLogFilePathBase}_*.lst] files for ".
                     "spool files, if any");

    my $ts = TimeStamp();

    # do not dump the banner to STDERR
    log_msg_banner <<msg;

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

catcon version: $VERSION
\tcatconInit2: start logging catcon output at $ts

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

msg

    return $RetLogFilePathBase;
  }

  # catconInit's signature contained a bunch (22 at the last count) arguments 
  # which was unwieldy and required that all callers be modified every time 
  # we needed to change its signature (which explains numerous functions used 
  # to initialize various catcon_* vars outside of catconInit)
  #
  # For backward compatibility, we will preserve catconInit as a wrapper for 
  # catconInit2 - a preferred way to initialize catcon - which accepts a 
  # reference to an argument hash 
  #

  # catconInit_Get_Arg
  #
  #   Obtain value (if any) of specified argument passed to catconInit2 inside 
  #   argument hsh
  #
  # Parameters:
  #   $argHash_ref - reference to the argument hash
  #   $argName    - argument name
  #
  sub catconInit_Get_Arg($$) {
    my ($argHash_ref, $argName) = @_;

    # if argument was not supplied, let the caller know (not an error, though, 
    # since many of them are optional)
    if (! exists $argHash_ref->{$argName}) {
      return 0;
    }

    return $argHash_ref->{$argName};
  }

  # user name, optionally with password and AS <admin-role>, supplied by the 
  # caller; may be undefined (default / AS SYSDBA)
  #
  # type: string

  # LEGACY ARG (1)
  use constant CATCONINIT_ARG_SCRIPT_USER => 'ScriptUser';

  sub catconInit_Get_Script_User($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_SCRIPT_USER);
  }

  # internal user name, optionally with password and AS <admin-role>; may be 
  # undefined (default / AS SYSDBA)
  #
  # type: string

  # LEGACY ARG (2)
  use constant CATCONINIT_ARG_INTERNAL_USER => 'InternalUser'; 

  sub catconInit_Get_Internal_User($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_INTERNAL_USER);
  }

  # directory containing sqlplus script(s) to be run; may be undefined
  #
  # type: string

  # LEGACY ARG (3)
  use constant CATCONINIT_ARG_SCRIPT_DIR => 'ScriptDir';  

  sub catconInit_Get_Script_Dir($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_SCRIPT_DIR);
  }

  # directory to use for spool and log files; may be undefined
  #
  # type: string

  # LEGACY ARG (4)
  use constant CATCONINIT_ARG_LOG_DIR => 'LogDir';

  sub catconInit_Get_Log_Dir($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_LOG_DIR);
  }

  # base for spool and log file name; MUST be specified
  #
  # type: string

  # LEGACY ARG (5)
  use constant CATCONINIT_ARG_LOG_BASE => 'LogBase';  

  sub catconInit_Get_Log_Base($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_LOG_BASE);
  }

  # name(s) of container(s) (separated by one or more spaces) in which to run 
  # sqlplus script(s) and SQL statement(s) (i.e. skip containers not 
  # referenced in this list)
  #
  # type: string

  # LEGACY ARG (6)
  use constant CATCONINIT_ARG_INCL_CON => 'InclCon';  

  sub catconInit_Get_Containers_To_Include($) {
    return trim(catconInit_Get_Arg($_[0], CATCONINIT_ARG_INCL_CON));
  }

  # container(s) (names separated by one or more spaces) in which NOT to 
  # run sqlplus script(s) and SQL statement(s) (i.e. skip containers
  # referenced in this list)
  #
  # type: string
  # 
  # NOTE: lists of Containers to Include/Exclude are mutually exclusive; 
  #   if neither is defined, sqlplus script(s) and SQL statement(s) will be 
  #   run in the non-Consolidated Database or all Containers of a Consolidated 
  #   Database

  # LEGACY ARG (7)
  use constant CATCONINIT_ARG_EXCL_CON => 'ExclCon';  

  sub catconInit_Get_Containers_To_Exclude($) {
    return trim(catconInit_Get_Arg($_[0], CATCONINIT_ARG_EXCL_CON));
  }

  # number of processes to be used to run sqlplus script(s) and SQL 
  # statement(s);  may be undefined (default value will be computed based 
  # on host's hardware characteristics, number of concurrent sessions, 
  # and whether the subroutine is getting invoked interactively)
  #
  # type: number

  # LEGACY ARG (8)
  use constant CATCONINIT_ARG_NUM_PROCS => 'NumProcs';  

  sub catconInit_Get_Num_Procs($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_NUM_PROCS);
  }

  # external degree of parallelism, i.e. if more than one script using 
  # catcon will be invoked simultaneously on a given host, this parameter 
  # should contain a number of such simultaneous invocations; 
  # may be undefined;
  # will be used to determine number of processes to start;
  # this parameter MUST be undefined or set to 0 if the preceding 
  # parameter (number of processes) is non-zero
  #
  # type: number
  #
  # NOTE: this argument is very rarely (if ever) used

  # LEGACY ARG (9)
  use constant CATCONINIT_ARG_EXT_PARALLEL_DEGREE => 'ExtParallelism'; 

  sub catconInit_Get_Ext_Parallel_Degree($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_EXT_PARALLEL_DEGREE);
  }

  # indicator of whether echo should be set ON while running script(s) 
  # and SQL statement(s)
  #
  # type: number

  # LEGACY ARG (10)
  use constant CATCONINIT_ARG_ECHO_ON => 'EchoOn';

  sub catconInit_Get_Echo_On($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_ECHO_ON);
  }

  # indicator of whether output of running scripts should be spooled in 
  # files stored in the same directory as that used for log files and 
  # whose name will be constructed as follows:
  #   <log-file-name-base>_<script_name_without_extension>_[<container_name_if_any>].<default_extension>
  #
  # type: number

  # LEGACY ARG (11)
  use constant CATCONINIT_ARG_SPOOL_ON => 'SpoolOn';

  sub catconInit_Get_Spool_On($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_SPOOL_ON);
  }

  # reference to a string used to introduce an argument to SQL*Plus 
  # scripts which will be supplied using clear text (i.e. not require 
  # user to input them at run-time)
  #
  # type: string
  #
  # NOTE: if the string was not supplied by the caller, it will default to --p;
  #       the string will be used by the caller and by catcon subroutines to 
  #       recognize sqlplus script arguments 

  # LEGACY ARG (12)
  use constant CATCONINIT_ARG_REGULAR_ARG_TAG_REF => 'RegularArgTag_ref';

  sub catconInit_Get_Regular_Arg_Tag_Ref($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_REGULAR_ARG_TAG_REF);
  }

  # reference to a string used to introduce an argument (such as a 
  # password) to SQL*Plus scripts which will require user to input them 
  # at run-time
  #
  # type: string
  #
  # NOTE: if the string was not supplied by the caller, it will default to --P;
  #       the string will be used by the caller and by catcon subroutines to 
  #       recognize secret sqlplus script arguments 

  # LEGACY ARG (13)
  use constant CATCONINIT_ARG_SECRET_ARG_TAG_REF => 'SecretArgTag_ref';

  sub catconInit_Get_Secret_Arg_Tag_Ref($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_SECRET_ARG_TAG_REF);
  }

  # indicator of whether ERRORLOGGING should be set ON while running 
  # script(s) and SQL statement(s); if non-zero, 
  # default error logging table (SPERRORLOG) will be used, otherwise 
  # specified value will be treated as the name of the error logging 
  # table which should have been pre-created in every Container
  #
  # type: number

  # LEGACY ARG (14)
  use constant CATCONINIT_ARG_ERROR_LOGGING => 'ErrorLogging';

  sub catconInit_Get_Error_Logging($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_ERROR_LOGGING);
  }

  # indicator of whether the caller has instructed us to NOT set 
  # Errorlogging Identifier
  #
  # type: number

  # LEGACY ARG (15)
  use constant CATCONINIT_ARG_NO_ERROR_LOGGING_IDENT => 'NoErrorLoggingIdent';

  sub catconInit_Get_No_Error_Logging_Ident($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_NO_ERROR_LOGGING_IDENT);
  }

  # SQL statements which will be executed in every 
  # process before it is asked to run the first script; if operating on a 
  # CDB, statements will be executed against the Root; statements may 
  # contain 0 or more instances of string %proc which will be replaced 
  # with process number
  #
  # type: reference to an array of strings

  # LEGACY ARG (16)
  use constant CATCONINIT_ARG_PER_PROC_INIT_STMTS => 'PerProcInitStmts';

  sub catconInit_Get_Per_Proc_Init_Stmts($) {
    my $array_ref = 
      catconInit_Get_Arg($_[0], CATCONINIT_ARG_PER_PROC_INIT_STMTS);

    if (!$array_ref) {
      # argument was not specified - return a reference to an empty hash
      return ({});
    }

    if (ref($array_ref) eq '') {
      die CATCONINIT_ARG_PER_PROC_INIT_STMTS." argument is expected to be a ".
          "reference to an ARRAY; passed value was not a reference";
    } elsif (ref($array_ref) ne 'ARRAY') {
      die CATCONINIT_ARG_PER_PROC_INIT_STMTS." argument is expected to be a ".
          "reference to an ARRAY; passed value was a reference to ".
          (ref($array_ref));
    }

    return $array_ref;
  }

  # SQL statements which will be executed in every 
  # process after it finishes runing the last script; if operating on a 
  # CDB, statements will be executed against the Root; statements may 
  # contain 0 or more instances of string %proc which will be replaced 
  # with process number
  #
  # type: reference to an array of strings

  # LEGACY ARG (17)
  use constant CATCONINIT_ARG_PER_PROC_END_STMTS => 'PerProcEndStmts';

  sub catconInit_Get_Per_Proc_End_Stmts($) {
    my $array_ref = 
      catconInit_Get_Arg($_[0], CATCONINIT_ARG_PER_PROC_END_STMTS);

    if (!$array_ref) {
      # argument was not specified - return a reference to an empty hash
      return ({});
    }

    if (ref($array_ref) eq '') {
      die CATCONINIT_ARG_PER_PROC_END_STMTS." argument is expected to be a ".
          "reference to an ARRAY; passed value was not a reference";
    } elsif (ref($array_ref) ne 'ARRAY') {
      die CATCONINIT_ARG_PER_PROC_END_STMTS." argument is expected to be a ".
          "reference to an ARRAY; passed value was a reference to ".
          (ref($array_ref));
    }

    return $array_ref;
  }

  # indicator of the mode in which PDB$SEED needs to be open before 
  # running scripts (see description of catcon_SeedPdbMode for details)
  #
  # type: string

  # LEGACY ARG (18) 
 use constant CATCONINIT_ARG_SEED_MODE => 'SeedMode';

  sub catconInit_Get_Seed_Mode($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_SEED_MODE);
  }

  # indicator of whether to produce debugging messages
  #
  # type: number

  # LEGACY ARG (19)
  use constant CATCONINIT_ARG_DEBUG_ON => 'DebugOn';

  sub catconInit_Get_Debug_On($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_DEBUG_ON);
  }

  # an indicator of whether we are being called from a GUI tool which on 
  # Windows means that the passwords and hidden parameters need not be 
  # hidden
  #
  # type: number

  # LEGACY ARG (20)
  use constant CATCONINIT_ARG_GUI => 'GUI';

  sub catconInit_Get_GUI($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_GUI);
  }

  # an indicator of whether we were called to run user scripts
  #
  # type: number

  # LEGACY ARG (21)
  use constant CATCONINIT_ARG_USER_SCRIPTS => 'UserScripts';

  sub catconInit_Get_User_Scripts($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_USER_SCRIPTS);
  }

  # an indicator of whether we were called in the course of running upgrade
  #
  # type: number

  # LEGACY ARG (22)
  use constant CATCONINIT_ARG_UPGRADE => 'Upgrade';

  sub catconInit_Get_Upgrade($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_UPGRADE);
  }

  # directory where sqlplus binary which catcon should use can be found 
  #
  # type: string

  use constant CATCONINIT_ARG_SQLPLUS_DIR => 'SqlplusDir';

  sub catconInit_Get_Sqlplus_Dir($) {
    return catconInit_Get_Arg($_[0], CATCONINIT_ARG_SQLPLUS_DIR);
  }

  #
  # catconInit - initialize and validate catcon static vars and start 
  #              SQL*Plus processes
  #
  # NOTE: 
  #   This subroutine is kept for backward compatibility. It acts as a 
  #   wrapper around catconInit2() which is the preferred way to initialize 
  #   catcon
  #
  #   catconInit will handle calls which rely on the signature in effect when 
  #   support for argument hash was added (CATCONINIT_ARG_* constants for 
  #   arguments which comprise that signature are tagged with
  #     # LEGACY ARG <position in legacy signature> 
  #   above.)
  #
  #   Existing callers of catconInit who do not need to pass new arguments 
  #   can continue calling it the way they have been up till now, but 
  #   new code invoking catconInit should be avoided - use catconInit2 instead,
  #   passing it a reference to an argument hash using CATCONINIT_ARG_* 
  #   constants as keys (see catcon.pl for an example) 
  #
  # Parameters:
  #   See CATCONINIT_ARG_* constants which are tagged with
  #         # LEGACY ARG <position in legacy signature> 
  #   above.
  #

  sub catconInit ($$$$$$$$$$$\$\$$$\@\@$$$$$) {
    my ($User, $InternalUser, $SrcDir, $LogDir, $LogBase, 
        $ConNamesIncl, $ConNamesExcl, 
        $NumProcesses, $ExtParallelDegree,
        $EchoOn, $SpoolOn, $RegularArgDelim_ref, $SecretArgDelim_ref, 
        $ErrLogging, $NoErrLogIdent, $PerProcInitStmts, 
        $PerProcEndStmts, $SeedMode, $DebugOn, $GUI, $UserScript, 
        $Upgrade) = @_;

    # pack arguments into a hash and invoke catconInit2
    my $argHashRef = 
    {
      &CATCONINIT_ARG_SCRIPT_USER            => $User,
      &CATCONINIT_ARG_INTERNAL_USER          => $InternalUser,
      &CATCONINIT_ARG_SCRIPT_DIR             => $SrcDir,
      &CATCONINIT_ARG_LOG_DIR                => $LogDir,
      &CATCONINIT_ARG_LOG_BASE               => $LogBase,
      &CATCONINIT_ARG_INCL_CON               => $ConNamesIncl,
      &CATCONINIT_ARG_EXCL_CON               => $ConNamesExcl,
      &CATCONINIT_ARG_NUM_PROCS              => $NumProcesses,
      &CATCONINIT_ARG_EXT_PARALLEL_DEGREE    => $ExtParallelDegree,
      &CATCONINIT_ARG_ECHO_ON                => $EchoOn,
      &CATCONINIT_ARG_SPOOL_ON               => $SpoolOn,
      &CATCONINIT_ARG_REGULAR_ARG_TAG_REF    => $RegularArgDelim_ref,
      &CATCONINIT_ARG_SECRET_ARG_TAG_REF     => $SecretArgDelim_ref,
      &CATCONINIT_ARG_ERROR_LOGGING          => $ErrLogging,
      &CATCONINIT_ARG_NO_ERROR_LOGGING_IDENT => $NoErrLogIdent,
      &CATCONINIT_ARG_PER_PROC_INIT_STMTS    => $PerProcInitStmts,
      &CATCONINIT_ARG_PER_PROC_END_STMTS     => $PerProcEndStmts,
      &CATCONINIT_ARG_SEED_MODE              => $SeedMode,
      &CATCONINIT_ARG_DEBUG_ON               => $DebugOn,
      &CATCONINIT_ARG_GUI                    => $GUI,
      &CATCONINIT_ARG_USER_SCRIPTS           => $UserScript,
      &CATCONINIT_ARG_UPGRADE                => $Upgrade,
    };

    return catconInit2($argHashRef);
  }

  #
  # catconInit2 - initialize and validate catcon static vars and start 
  #               SQL*Plus processes
  #
  #
  # Parameters:
  #   - reference to an argument hash using CATCONINIT_ARG_* constants (above) 
  #     as keys
  #
  sub catconInit2($) {

    my ($User, $InternalUser, $SrcDir, $LogDir, $LogBase, 
        $ConNamesIncl, $ConNamesExcl, 
        $NumProcesses, $ExtParallelDegree,
        $EchoOn, $SpoolOn, $RegularArgDelim_ref, $SecretArgDelim_ref, 
        $ErrLogging, $NoErrLogIdent, $PerProcInitStmts, 
        $PerProcEndStmts, $SeedMode, $DebugOn, $GUI, $UserScript, 
        $Upgrade, $sqlplusDir);

    if ($catcon_InitDone) {
      # if catconInit2 has already been called, $CATCONOUT must be available
      # send it to STDERR as well to increase likelihood of it being noticed
      log_msg_error <<msg;
script execution state has already been initialized; call 
    catconWrapUp before invoking catconInit2
msg
      return 1;
    }

    # Assign arguments passed by the caller to local variables.  
    if (ref($_[0]) ne "HASH") {
      my $refType = ref($_[0]);

      if ($refType eq '') {
        log_msg_error <<msg;
argument was expected to be a reference to a HASH; passed argument was not a 
    reference
msg
      } else {
        log_msg_error <<msg;
argument was expected to be a reference to a HASH; passed argument was a 
    reference to $refType
msg
      }
      return 1;
    }

    # copy contenbts of argument hash into local variables
    $User = catconInit_Get_Script_User($_[0]);
    $InternalUser = catconInit_Get_Internal_User($_[0]); 
    $SrcDir = catconInit_Get_Script_Dir($_[0]);
    $LogDir = catconInit_Get_Log_Dir($_[0]);
    $LogBase = catconInit_Get_Log_Base($_[0]);
    $ConNamesIncl = catconInit_Get_Containers_To_Include($_[0]);
    $ConNamesExcl = catconInit_Get_Containers_To_Exclude($_[0]);
    $NumProcesses = catconInit_Get_Num_Procs($_[0]);
    $ExtParallelDegree = catconInit_Get_Ext_Parallel_Degree($_[0]);
    $EchoOn = catconInit_Get_Echo_On($_[0]);
    $SpoolOn = catconInit_Get_Spool_On($_[0]);
    $RegularArgDelim_ref = catconInit_Get_Regular_Arg_Tag_Ref($_[0]);
    $SecretArgDelim_ref = catconInit_Get_Secret_Arg_Tag_Ref($_[0]);
    $ErrLogging = catconInit_Get_Error_Logging($_[0]);
    $NoErrLogIdent = catconInit_Get_No_Error_Logging_Ident($_[0]);
    $PerProcInitStmts = catconInit_Get_Per_Proc_Init_Stmts($_[0]);
    $PerProcEndStmts = catconInit_Get_Per_Proc_End_Stmts($_[0]);
    $SeedMode = catconInit_Get_Seed_Mode($_[0]);

    $DebugOn = catconInit_Get_Debug_On($_[0]);

    # if parameters passed to catconInit2 did not indicate that that we 
    # should produce diagnostic output, check if the caller set CATCON_DEBUG 
    # environment var iable
    if (!$DebugOn && exists $ENV{CATCON_DEBUG} && $ENV{CATCON_DEBUG}) {
      $DebugOn = 1;
    }

    $GUI = catconInit_Get_GUI($_[0]);
    $UserScript = catconInit_Get_User_Scripts($_[0]);
    $Upgrade = catconInit_Get_Upgrade($_[0]);
    $sqlplusDir = catconInit_Get_Sqlplus_Dir($_[0]);

    # if caller requested that we display messages with log level >= DEBUG, 
    # set the log level accordingly
    #
    # if catconVerbose has been called before catconInit2 to set catcon 
    # log level to VERBOSE, we will override it (since DEBUG log level is 
    # lower and will cover messages which would be displayed at VERBOSE 
    # level + it will be backward compatible), but if neither --verbose nor 
    # --diag was specified, we will default log level to INFO
    if ($DebugOn) {
      $catcon_LogLevel = CATCON_LOG_LEVEL_DEBUG;
    } elsif ($catcon_LogLevel == CATCON_LOG_LEVEL_DFLT) {
      # by default, set log level to INFO
      $catcon_LogLevel = CATCON_LOG_LEVEL_INFO;
    }

    # having set $catcon_LogLevel, we need to determine whether the caller has 
    # set $CATCON_DIAG_MSG_BUF_SIZE to override default size of 
    # @catcon_DiagMsgs circular buffer
    if (defined $ENV{CATCON_DIAG_MSG_BUF_SIZE}) {
      my $bufSize = $ENV{CATCON_DIAG_MSG_BUF_SIZE};
      
      # get rid of leading/trailing blanks
      $bufSize =~ s/^\s+|\s+$//g;

      if ($bufSize == 0 || $bufSize =~ /^[1-9][0-9]+$/) {
        # override default size of @catcon_DiagMsgs buffer
        $catcon_DiagMsgsSize = $bufSize;
        log_msg_debug("will retain last $catcon_DiagMsgsSize log messages");
      } elsif (uc($bufSize) eq 'UNLIMITED') {
        # @catcon_DiagMsgs will be used to store all messages
        undef $catcon_DiagMsgsSize;
        log_msg_debug("will retain last ALL log messages");
      } else {
        log_msg_warn("unexpected value ($ENV{CATCON_DIAG_MSG_BUF_SIZE}) ".
                     "found in CATCON_DIAG_MSG_BUF_SIZE env var; will ".
                     "retain default value ($catcon_DiagMsgsSize)");
      }
    } else {
      log_msg_debug("will retain last $catcon_DiagMsgsSize log messages by ".
                    "default");
    }

    # make STDERR "hot" so diagnostic and error message output does not get 
    # buffered
    select((select(STDERR), $|=1)[0]);

    # set Log File Path Base
    $catcon_LogFilePathBase = set_log_file_base_path($LogDir,$LogBase);

    # check to make sure we have a Log File Path Base
    if (!$catcon_LogFilePathBase) {
      log_msg_error("Unexpected error returned by set_log_file_base_path");
      return 1;
    }
    
    # Set Log directory
    $catcon_LogDir = $LogDir;

    my $ts = TimeStamp();

    log_msg_verbose("start initializing catcon");

    log_msg_debug("base for log and spool file names = ".
                  "$catcon_LogFilePathBase");

    # in case $SpoolOn and $InternalUser are undefined, N/A will be printed
    my $spoolOnStr = (defined $SpoolOn) ? $SpoolOn : "undefined";

    # bug 26030086: mask user and internal user passwords if they were supplied

    # user and internal user credentials with masked passwords, if any
    my $maskedUser = mask_user_passwd($User);
    my $maskedInternalUser = mask_user_passwd($InternalUser);

    # display arguments passed by the caller
    log_msg_debug("  running catconInit2(");

    foreach my $argName (sort keys %{$_[0]}) {
      if ($argName eq CATCONINIT_ARG_SCRIPT_USER) {
        log_msg_debug("                      $argName = ".
                      mask_user_passwd($User));
      } elsif ($argName eq CATCONINIT_ARG_INTERNAL_USER) {
        log_msg_debug("                      $argName = ".
                      mask_user_passwd($InternalUser));
      } elsif (ref($_[0]->{$argName}) eq "ARRAY") {
        # a couple of arguments are array references
        my $arrRef = $_[0]->{$argName};
        if ($#$arrRef < 0) {
          log_msg_debug("                      $argName = <empty array>");
        } else {
          log_msg_debug("                      $argName = \n  (\n    ".
                        join("\n    ", @$arrRef).
                        "\n  )");
        }
      } else {
        if (! defined $argName) {
          log_msg_warn("Undefined argument name");
        } elsif (! defined $_[0]->{$argName}) {
          log_msg_debug("                      $argName: undefined");
        } else {
          log_msg_debug("                      $argName = $_[0]->{$argName}");
        }
      }
    }
    
    log_msg_debug("                     )\t\t($ts)");

    # remember whether catconInit2 is called by cdb_sqlexec.pl
    $catcon_UserScript = $UserScript;

    # let catconInit2 and catconExec know whether the caller has informed us
    # that we are being called in the course of upgrade
    catconUpgrade($Upgrade);

    # if the caller indicated that catcon will be involved in running an 
    # upgrade using all available RAC instances (if any) and specified 
    # the number of SQL*Plus processes that should be dedicated to 
    # processing every PDB, store the the number of SQL*Plus processes that 
    # should be dedicated to processing every PDB to help catconExec 
    # determine how many processes should be assigned to upgrading every PDB
    if ($Upgrade && $catcon_AllInst && $NumProcesses > 0) {
      $catcon_DfltProcsPerUpgPdb = $catcon_ProcsPerUpgPdb = $NumProcesses;

      log_msg_debug <<msg;
Running upgrade, possibly utilizing multiple RAC instances, if any: 
  catcon_DfltProcsPerUpgPdb = catcon_ProcsPerUpgPdb = $catcon_DfltProcsPerUpgPdb
msg
    }

    # will contain an indicator of whether a DB is a CDB (v$database.cdb)
    my $IsCDB;

    # base for log file names must be supplied
    if (!$LogBase) {
      log_msg_error("Base for log file names must be supplied");
      return 1;
    }

    # if caller indicated that we are to start a negative number of processes,
    # it is meaningless, so replace it with 0
    if ($NumProcesses < 0) {
      log_msg_debug("Caller supplied negative number of processes ".
                    "($NumProcesses) - reset to 0");
      $NumProcesses = 0;
    }

    if ($NumProcesses && $ExtParallelDegree) {
      log_msg_error <<msg;
you may not specify both the number of processes ($NumProcesses) 
    and the external degree of parallelism ($ExtParallelDegree)
msg
      return 1;
    }

    $catcon_ExtParallelDegree = $ExtParallelDegree;

    # save EchoOn indicator in a variable that will persist across calls
    $catcon_EchoOn = $EchoOn;

    # save SpoolOn indicator in a variable that will persist across calls
    $catcon_SpoolOn = $SpoolOn;

    # initialize indicators used to determine how to resolve conflicts 
    # between regular and secret argument delimiters
    $catcon_PickRegularArg = 1; 
    $catcon_PickSecretArg = 2;  

    # 
    # set up signal handler in case SQL process crashes
    # before it completes its work
    #
    # Bug 18488530: add a handler for SIGINT
    # Bug 18548396: add handlkers for SIGTERM and SIGQUIT
    # Bug 22887047: we will no longer try to handle SIGCHLD; instead we will 
    #   ignore it and deal with any dead child processes when we come across 
    #   them in the course of trying to pick a next process to do perform some 
    #   task (next_proc())
    #
    # save original handlers for SIGCHLD, SIGINT, SIGTERM, and SIGQUIT before 
    # resetting them
    $catcon_SaveSig{CHLD} = $SIG{CHLD} if (exists $SIG{CHLD});

    $catcon_SaveSig{INT}  = $SIG{INT}  if (exists $SIG{INT});

    $catcon_SaveSig{TERM} = $SIG{TERM} if (exists $SIG{TERM});

    $catcon_SaveSig{QUIT} = $SIG{QUIT} if (exists $SIG{QUIT});

    $SIG{CHLD} = 'IGNORE';
    $SIG{INT} = \&catcon_HandleSigINT;
    $SIG{TERM} = \&catcon_HandleSigTERM;
    $SIG{QUIT} = \&catcon_HandleSigQUIT;

    # figure out if we are running under Windows and set $catcon_DoneCmd
    # accordingly
    os_dependent_stuff($catcon_Windows, $catcon_DoneCmd, $catcon_Sqlplus);

    log_msg_debug("running on $OSNAME; DoneCmd = $catcon_DoneCmd");

    #
    # unset TWO_TASK or LOCAL if it happens to be set to ensure that CONNECT
    # which does not specify a service results in a connection to the Root
    #

    if($catcon_Windows) {
      if ($ENV{LOCAL}) {
         log_msg_debug("LOCAL was set to $ENV{LOCAL} - unsetting it");

         delete $ENV{LOCAL};
      } else {
        log_msg_debug("LOCAL was not set, so there is not need to unset it");
      }
    }

    if ($ENV{TWO_TASK}) {
      log_msg_debug("TWO_TASK was set to $ENV{TWO_TASK} - unsetting it");

      delete $ENV{TWO_TASK};
    } else {
      log_msg_debug("TWO_TASK was not set, so there is no need to unset it");
    }

    if (!$$RegularArgDelim_ref) {
      $$RegularArgDelim_ref = '--p';

      log_msg_debug("regular argument delimiter was not specified - ".
                    "defaulting to $$RegularArgDelim_ref");
    }

    if (!$$SecretArgDelim_ref) {
      $$SecretArgDelim_ref = '--P';

      log_msg_debug("secret argument delimiter was not specified - ".
                    "defaulting to $$SecretArgDelim_ref");
    }

    # save strings used to introduce arguments to SQL*Plus scripts
    if ($$RegularArgDelim_ref ne "--p" || $$SecretArgDelim_ref ne "--P") {

      log_msg_debug("either regular ($$RegularArgDelim_ref) or secret ".
                    "($$SecretArgDelim_ref) argument delimiters were ".
                    "explicitly specified");

      # if both are specified, they must not be the same
      if ($$RegularArgDelim_ref eq $$SecretArgDelim_ref) {
        log_msg_error <<msg;
string introducing regular script argument ($$RegularArgDelim_ref) 
    may not be \nthe same as a string introducing a secret script 
    argument ($$SecretArgDelim_ref)
msg
        return 1;
      }

      # if one of the strings is a prefix of the other, remember which one to 
      # pick if an argument supplied by the user may be either
      if ($$RegularArgDelim_ref =~ /^$$SecretArgDelim_ref/) {
        $catcon_ArgToPick = $catcon_PickRegularArg;

        log_msg_debug <<msg;
secret argument delimiter ($$SecretArgDelim_ref) is a prefix of 
    regular argument delimiter ($$RegularArgDelim_ref); if in doubt, 
    will pick regular
msg
      } elsif ($$SecretArgDelim_ref =~ /^$$RegularArgDelim_ref/) {
        $catcon_ArgToPick = $catcon_PickSecretArg;

        log_msg_debug <<msg;
regular argument delimiter ($$RegularArgDelim_ref) is a prefix of 
    secret argument delimiter ($$SecretArgDelim_ref); if in doubt, will 
    pick secret
msg
      }
    }

    # argument delimiters may not start with @
    if ($$RegularArgDelim_ref =~ /^@/) {
      log_msg_error("regular argument delimiter ($$RegularArgDelim_ref) ".
                    "begins with @ which is not allowed");
      return 1;
    }

    if ($$SecretArgDelim_ref =~ /^@/) {
      log_msg_error("secret argument delimiter ($$SecretArgDelim_ref) ".
                    "begins with @ which is not allowed");
      return 1;
    }

    $catcon_RegularArgDelim = $$RegularArgDelim_ref;
    $catcon_SecretArgDelim = $$SecretArgDelim_ref;

    # remember whether ERRORLOGGING should be set 
    $catcon_ErrLogging = $ErrLogging;

    # remember whether the caller has instructed us to NOT issue 
    # SET ERRORLOGGING ON IDENTIFIER ...
    $catcon_NoErrLogIdent = $NoErrLogIdent;

    # saves references to arrays of statements which should be executed 
    # before using sending a script to a process for the first time and 
    # after a process finishes executing the last script assigned to it
    # in the course of running catconExec()
    $catcon_PerProcInitStmts = $PerProcInitStmts;
    $catcon_PerProcEndStmts = $PerProcEndStmts;

    # process EZConnect strings, if any

    my @ezConnStrings;

    if ($catcon_EZConnect || $ENV{$EZCONNECT_ENV_TAG}) {
      # store a list of EZConnect strings in @ezConnStrings for use when 
      # determining which instance will be picked for running scriptrs
      if ($catcon_EZConnect) {
        # use a list of EZConnect strings supplied by the caller
        @ezConnStrings = split(' ',$catcon_EZConnect);
      
        # $catcon_EZConnect should have contained at least 1 string
        if ($#ezConnStrings < 0) {
          log_msg_error("EZConnect string list must contain at least 1 ".
                        "string");
          return 1;
        }

        log_msg_debug("EZConnect strings supplied by the user:\n".
                      "\t".join("\n\t", @ezConnStrings));
      } else {
        @ezConnStrings = split(' ', $ENV{$EZCONNECT_ENV_TAG});
          
        # $ENV{$EZCONNECT_ENV_TAG} should have contained at least 1 string
        if ($#ezConnStrings < 0) {
          log_msg_error("$EZCONNECT_ENV_TAG environment variable must ".
                        "contain at least 1 string");
          return 1;
        }

        log_msg_debug("EZConnect strings found in ".
                      "$EZCONNECT_ENV_TAG env var\n\t".
                      join("\n\t", @ezConnStrings));
      }

      log_msg_verbose("finished processing EZConnect strings");
    } else {
      if ($catcon_EZconnToPdb) {
        # bug 25507396: if $catcon_EZconnToPdb is defined, $catcon_EZConnect 
        #   must also be defined
        log_msg_error <<msg;
name of a PDB ($catcon_EZconnToPdb) to which EZConnect string(s) 
    should take us was specified, but no EZConnect strings were supplied
msg
        return 1;
      }

      # having $ezConnStrings[0] eq "" serves as an indicator that we will
      # use the default instance
      push @ezConnStrings, "";

      log_msg_debug("no EZConnect strings supplied - using default instance");
    }

    # construct a user connect string and store it as well as the password 
    # (so catconUserPass() can return it), if any, in variables which will 
    # persist across calls.  
    #
    # NOTE: If ezConnStrings does not represent the default instance, 
    #       $catcon_UserConnectString will contain a placeholder (@%s) for 
    #       the EZConnect string corresponding to the instance which we will 
    #       eventually pick.
    ($catcon_UserConnectString[0], $catcon_UserConnectString[1],
     undef , undef, 
     $catcon_UserPass) = 
      get_connect_string($User, !($catcon_Windows && $GUI), 
                         $ENV{&USER_PASSWD_ENV_TAG}, 
                         $ezConnStrings[0] ne "");

    if (!$catcon_UserConnectString[0]) {
      # NOTE: $catcon_UserConnectString may be set to undef
      #       if the caller has not supplied a value 
      #       for $USER (which would lead get_connect_string() to return 
      #       "/ AS SYSDBA" as the connect string while specifying instances 
      #       on which scripts are to be run (by means of passing one or more 
      #       EZConnect strings)
      log_msg_error("Empty user connect string returned by ".
                    "get_connect_string");
      return 1;
    }

    if ($catcon_UserPass && length($catcon_UserPass) < 1) {
      # unless user will be connecting using "/ AS SYSDBA" (in which case 
      # $catcon_UserPass would end up being undefined), password consisting 
      # of at least 1 character must have been specified
      log_msg_error("Empty user password was specified");
      return 1;
    }

    log_msg_debug("User Connect String = $catcon_UserConnectString[1]");

    # bug 18591655: if user password was not supplied, display 
    #   appropriate message
    log_msg_debug("User password ".
                  ($catcon_UserPass ? "specified" : "not specified"));

    # Bug 18020158: generating internal connect string is complicated by the 
    # fact that catctl does not accept it as a parameter.  There are two 
    # distinct cases to consider:
    # - the caller supplied <internal user> and possibly <internal password> 
    #   inside $InternalUser:
    #   - if both internal user and password were supplied, use them
    #   - otherwise, if <internal password> was not supplied, we will try to 
    #     obtain it from $ENV{&INTERNAL_PASSWD_ENV_TAG}, and failing that, 
    #     prompt the user to enter it
    # - otherwise:
    #   - recycle user connect string as the internal connect string
    if ($InternalUser) {
      my $InternalPass; # used to accept a value returned by get_connect_string

      # NOTE: If ezConnStrings does not represent the default instance, 
      #       $catcon_InternalConnectString will contain a placeholder (@%s) 
      #       for the EZConnect string corresponding to the instance which 
      #       we will eventually pick.

      ($catcon_InternalConnectString[0], $catcon_InternalConnectString[1],
       $InternalPass) = 
        get_connect_string($InternalUser, !($catcon_Windows && $GUI), 
                           $ENV{&INTERNAL_PASSWD_ENV_TAG}, 
                           $ezConnStrings[0] ne "");

      if (!$catcon_InternalConnectString[0]) {
        log_msg_error("Empty internal connect string returned by ".
                      "get_connect_string");
        return 1;
      }

      if ($InternalPass && length($InternalPass) < 1) {
        # unless internal user will be connecting using "/ AS SYSDBA" (in 
        # which case $InternalPass would end up being undefined), password 
        # consisting of at least 1 character must have been specified
        log_msg_error("Empty internal password was specified");
        return 1;
      }

      log_msg_debug("Internal Connect String = ".
                    "$catcon_InternalConnectString[1]");

      # bug 18591655: if internal password was not supplied, display 
      #   appropriate message
      log_msg_debug("Internal password ".
                    ($InternalPass ? "specified" : "not specified"));
    } else {
      @catcon_InternalConnectString = @catcon_UserConnectString;

      log_msg_debug("setting Internal Connect String to User Connect String");
    }

    log_msg_verbose("finished constructing connect strings");

    if (!valid_src_dir($catcon_SrcDir = $SrcDir)) {
      log_msg_error("Unexpected error returned by valid_src_dir");
      return 1;
    }

    if ($catcon_SrcDir) {
      log_msg_debug("source file directory = $catcon_SrcDir");
    } else {
      log_msg_debug("no source file directory was specified");
    }

    # Bug 17810688: make sure sqlplus is in $PATH 
    # Bug 26135561: or in the directory specified by the caller
    if ($sqlplusDir) {
      log_msg_debug("verify that $sqlplusDir contains sqlplus binary");
    } else {
      log_msg_debug("locate directory in \$PATH that contains sqlplus binary");
    }

    $catcon_Sqlplus = find_in_path("sqlplus", $catcon_Windows, $sqlplusDir);
    if (!$catcon_Sqlplus) {
      if ($sqlplusDir) {
        log_msg_error("sqlplus not in directory specified by the caller ".
                      "($sqlplusDir)");
      } else {
        log_msg_error("sqlplus not in PATH.");
      }
      return 1;
    }

    log_msg_debug("will use $catcon_Sqlplus binary");

    # if the caller specified mode in which PDB$SEED should be opened, 
    # validate it
    if (! defined $SeedMode ||
        ($SeedMode != CATCON_PDB_MODE_NA && !valid_pdb_mode($SeedMode))) {
      log_msg_error("Unexpected value ($SeedMode) for SeedMode");
      return 1;
    }

    # finalize modes in which PDB$SEED and all other PDBs that we will be 
    # operating upon should be opened.
    #
    # NOTE: after the next 2 statements are executed, $catcon_SeedPdbMode 
    #       and $catcon_AllPdbMode are guaranteed to NOT be set to 
    #       CATCON_PDB_MODE_NA
    $catcon_SeedPdbMode = seed_pdb_mode_to_use($SeedMode, $catcon_AllPdbMode);

    log_msg_debug("PDB\$SEED will be open in ".
                  PDB_MODE_CONST_TO_STRING->{$catcon_SeedPdbMode}." mode");

    $catcon_AllPdbMode = all_pdb_mode_to_use($catcon_AllPdbMode);

    log_msg_debug("All other PDBs will be open in ".
                  PDB_MODE_CONST_TO_STRING->{$catcon_AllPdbMode}." mode");

    # prefix of "done" file name
    #
    # Bug 18011217: append _catcon_$$ (process id) to $catcon_LogFilePathBase
    # to avoid conflicts with other catcon processes running on the same host
    my $doneFileNamePrefix = 
      done_file_name_prefix($catcon_LogFilePathBase, $$);

    log_msg_debug("Names of \"done\" files will start with ".
                  "$doneFileNamePrefix");

    # For each EZConnect String (or "" for default instance) stored in 
    # @ezConnStrings, connect to the instances represented by the string and 
    # - verify that the database is open on that instance, 
    # - if processing the first EZConnect string 
    #   - determine whether the database is a CDB 
    # - if @ezConnStrings contains more than one string, 
    #   - verify that the current EZConnect string takes us to the same DB 
    #     as the preceding one
    # - if the EZConnect string takes us to a CDB, 
    #   - verify that it takes us to the CDB's Root, 
    #     unless (bug 25507396) $catcon_EZconnToPdb is set, in which case we 
    #     need to verify that the EZConnect string takes us to the specified 
    #     PDB
    #   - if we are yet to determine which Instance to use
    #     - determine which Containers are open on this Instance
    #     - if there is only one EZConnect string (which may or may not  
    #       represent the default instance)
    #       - determine the set of Containers against which scripts will be 
    #         run, honoring the caller's directive regarding reporting of 
    #         errors due to some PDBs not being accessible
    #       - remember that this is the instance which we will be using
    #     - else
    #       - if processing the first EZConnect string,
    #         - determine the set of Containers against which scripts will be 
    #           run WITHOUT taking into consideration whether these Containers 
    #           are open on the instance corresponding to this EZConnect string
    #  
    #           the reason we are choosing to ignore open mode of Containers on
    #           this Instance is because we do not want to report an error if 
    #           some Container is not open on this instance - all desired 
    #           Containers may very well be open on some other instance - we 
    #           just need a list of Containers after taking into account the 
    #           inclusive or exclusive Container list (if any) + we DO want to 
    #           report an error if either of these lists included an unknown 
    #           Container and the caller has NOT instructed us to ignore such 
    #           Containers
    #       - determine if ALL Containers against which scripts need to be run 
    #         are open on this Instance
    #       - if all desired Containers are open on this Instance
    #         - remember that this is the instance which we will be using
    #     - if we finally determined the instance which will be using, 
    #       determine how many processes may be started on it
    # - else (i.e. not connecting to a CDB)
    #   - determine the number of processes that can be started on this 
    #     instance, and if it is greater than that for all preceding 
    #     instances (if any), remember that this is the instance we will 
    #     want to use (unless we find an instance on which an even greater 
    #     number of processes can be started)
    # - endif

    # set to 0 in case we were called to run scripts against a non-CDB and need
    # to look for an instance that can support the greatest number of processes
    $catcon_NumProcesses = 0;

    # If considering more than one instance, $dbid will be used to verify 
    # that all instances are connected to the same database
    my $dbid;

    # EZConnect string corresponding to the instance which we picked to run 
    # scripts. If still not set when we exit the loop, report an error
    my $ezConnToUse;

    for (my $currInst = 0; $currInst <= $#ezConnStrings; $currInst++) {
      my $EZConnect = $ezConnStrings[$currInst];

      log_msg_debug("considering EZConnect string ".$EZConnect);

      # internal connect string using the current EZConnect string
      my @intConnectString;

      # construct an internal connect string which will be used to obtain 
      # information about the current instance, the database which is running 
      # on it, etc.
      #
      # Bug 21202842: construct connect string with/without redacted password
      $intConnectString[0] = 
        build_connect_string($catcon_InternalConnectString[0], $EZConnect, 0);
      $intConnectString[1] = 
        build_connect_string($catcon_InternalConnectString[1], $EZConnect, 1);

      # build_connect_string may return undef, in which case we will return 1 
      # (to indicate that an error was encountered)
      if (!$intConnectString[0]) {
        log_msg_error("unexpected error encountered in build_connect_string ".
                      "when trying to construct an internal connect string");
        return 1;
      }

      # (13704981) verify that the instance is open

      log_msg_debug("call get_instance_status_and_name");

      # status and name of the instance (v$instance.status and 
      # v$instance.instance_name)
      my ($instanceStatus, $instanceName) = 
        get_instance_status_and_name(@intConnectString, $catcon_DoneCmd, 
                                     $doneFileNamePrefix, $catcon_Sqlplus);

      if (!$instanceStatus) {
        log_msg_error("unexpected error in get_instance_status_and_name");
        return 1;
      } elsif ($instanceStatus !~ /^OPEN/) {
        my $msg = "database is not open ";

        if ($EZConnect eq "") {
          # default instance
          $msg .= "on the default instance (".$instanceName.")";
        } else {
          $msg .= "on instance ".$instanceName." with EZConnect string = ".
                  $EZConnect;
        }

        log_msg_error($msg);
        return 1;
      }

      log_msg_debug("instance $instanceName (EZConnect = ".
                    $EZConnect.") has status $instanceStatus");

      # determine whether a DB is a CDB.  Do it only once (before obtaining 
      # database' DBID).
      #
      # Bug 26120968: at the same time, validate user credentials
      if (!$dbid) {
        log_msg_debug("processing first instance - call get_CDB_indicator");

        $IsCDB = 
          get_CDB_indicator(@intConnectString, $catcon_DoneCmd, 
                            $doneFileNamePrefix, $catcon_Sqlplus);

        if (!(defined $IsCDB)) {
          log_msg_error("unexpected error in get_CDB_indicator");
          return 1;
        }

        log_msg_debug("database is ".
                      (($IsCDB eq 'NO') ? "non-" : "")."Consolidated");

        # user connect string using the current EZConnect string
        my @usrConnectString;

        # construct a user connect string which will be used to verify that  
        # user credentials supplied by the caller are valid

        $usrConnectString[0] = 
          build_connect_string($catcon_UserConnectString[0], $EZConnect, 0);
        $usrConnectString[1] = 
          build_connect_string($catcon_UserConnectString[1], $EZConnect, 1);

        # build_connect_string may return undef, in which case we will return 1
        # (to indicate that an error was encountered)
        if (!$usrConnectString[0]) {
          log_msg_error("unexpected error encountered in ".
                        "build_connect_string when trying to construct a ".
                        "user connect string");
          return 1;
        }

        log_msg_debug("processing first instance - call validate_credentials");

        my $ValidUserCredentials = 
          validate_credentials(@usrConnectString, $catcon_DoneCmd, 
                               $doneFileNamePrefix, $catcon_Sqlplus);

        if (!$ValidUserCredentials) {
          log_msg_error("unexpected error in validate_credentials when ".
                        "trying to validate user credentials");
          return 1;
        }

        log_msg_debug("user credentials appear to be valid");
      }

      log_msg_debug("call get_dbid");

      # obtain DBID of the database to which the current instance is 
      # connected and compare id to DBID of preceding instances, if any
      my $currDBID = 
        get_dbid(@intConnectString, $catcon_DoneCmd, $doneFileNamePrefix,
                 $catcon_Sqlplus);

      if (!(defined $currDBID)) {
        # DBID could not be obtained
        log_msg_error("unexpected error in get_dbid");
        return 1;
      }

      if (!$dbid) {
        # first EZ Connect string (or "", representing the default instance)
        $dbid = $currDBID;

        log_msg_debug("DBID = $dbid");
      } elsif ($dbid ne $currDBID) {
        # at least 2 EZConnect strings were specified, and not all of them 
        # correspond to the same database
        log_msg_error <<msg;
EZConnect string = $EZConnect (instance $instanceName)
    is connected to a database with DBID = $currDBID which is different
    from DBID ($dbid) of the database to which preceding instances are 
    connected
msg
        return 1;
      }

      # CDB-specific stuff (see above)
      if ($IsCDB eq "YES") {
        log_msg_verbose("start CDB-specific processing");

        if ($catcon_EZconnToPdb) {
          # make sure that the current EZConnect string will take us to the 
          # specified PDB.
          log_msg_debug <<msg;
ezconn_to_pdb was specified; call get_con_name to verify that the current
    EZConnect string will take us to the specified PDB ($catcon_EZconnToPdb)
msg

          my $conName = get_con_name(@intConnectString, $catcon_DoneCmd, 
                                     $doneFileNamePrefix, $catcon_Sqlplus);

          if (!(defined $conName)) {
            # con_name could not be obtained
            log_msg_error("unexpected error in get_con_name");
            return 1;
          }

          if (uc($catcon_EZconnToPdb) ne $conName) {
            # EZConnect string is not taking us to the specified PDB
            log_msg_error <<msg;
ezconn_to_pdb ($catcon_EZconnToPdb) was specified, but 
    EZConnect string = $EZConnect points to Container $conName
msg
            return 1;
          }
        } else {
          # make sure that the current EZConnect string will take us to the 
          # Root.
          log_msg_debug("call get_con_id to verify that the current ".
                        "EZConnect string will take us to the Root");

          my $conId = get_con_id(@intConnectString, $catcon_DoneCmd, 
                                 $doneFileNamePrefix, $catcon_Sqlplus);

          if (!(defined $conId)) {
            # con_id could not be obtained
            log_msg_error("unexpected error in get_con_id");
            return 1;
          }

          if ($conId != 1) {
            # EZConnect string is not taking us to a CDB's Root
            log_msg_error <<msg;
EZConnect string = $EZConnect (Instance $instanceName)
    points to a Container with CON_ID of $conId instead of the Root
msg
            return 1;
          }
        }

        # the rest of this block has to do with finding an Instance on which 
        # all desired Containers are open.  If such Instance has already been 
        # located, process the next EZConnect string (if any)
        if (defined $ezConnToUse) {
          log_msg_debug <<msg;
skip to the next EZConnect string since we have already determined 
    which EZConnect string to use
msg
          next;
        }

        # indicators of which Containers are open on this instance
        my %isConOpen;

        if (!@catcon_AllContainers) {

          # we are processing the first EZConnect string, so obtain names of 
          # ALL Containers in the CDB along with indicators of which of these 
          # Containers are open on this instance
          log_msg_debug("call get_con_info to obtain container ".
                        "names and open indicators");

          if (get_con_info(@intConnectString, $catcon_DoneCmd, 
                           $doneFileNamePrefix, \@catcon_AllContainers, 
                           \%catcon_AppRootInfo, \%catcon_AppRootCloneInfo, 
                           \%catcon_AppPdbInfo, \%isConOpen, 0, 
                           $catcon_EZconnToPdb, $catcon_Sqlplus)) {
            log_msg_error("unexpected error in get_con_info(1)");
            return 1;
          }

          # save name of the Root (it will always be in the 0-th element of 
          # @catcon_AllContainers because its contents are sorted by 
          # v$containers.con_id)
          $catcon_Root = $catcon_AllContainers[0];

          if ($catcon_UserScript) {
            # if running user- (rather than Oracle-) supplied scripts, discard 
            # the first 2 elements of @catcon_AllContainers (CDB$ROOT and 
            # PDB$SEED) and corresponding elements of %isConOpen
            #
            # if the CDB does not contain any other Containers, report an error
            # because there are no PDBs against which to run user scripts
            if ($#catcon_AllContainers < 2) {
              log_msg_error("cannot run user scripts against a CDB ".
                            "which contains no user PDBs");
              return 1;
            }

            delete $isConOpen{shift @catcon_AllContainers};
            delete $isConOpen{shift @catcon_AllContainers};

            log_msg_debug <<msg;
running customer scripts, so purged the first 2 entries from 
    catcon_AllContainers and deleted corresponding entries from isConOpen
msg
          }

          # - if a list of names of Containers in which to run (or not to run) 
          #   scripts has been specified, 
          #   - make sure both of them have NOT been specified (since they are 
          #     mutually exclusive) and
          # - if there is only one EZConnect string to consider
          #   - if an inclusive or exclusive Container list was specified,
          #     - verify that the desired Containers actually exist and are 
          #       open on this instance (taking into consideration caller's 
          #       request (if any) to ignore non-existent Containers mentioned 
          #       in the inclusive/exclusive list and Containers which are not 
          #       open on this instance)
          #   - else
          #     - verify that all Containers are open on this instance (taking 
          #       into consideration caller's request (if any) to ignore 
          #       Containers which are not open on this instance)
          if ($ConNamesIncl && $ConNamesExcl) {
            log_msg_error <<msg;
both a list of Containers in which to run scripts and a list of 
    Containers in which NOT to run scripts were specified, which is disallowed
msg
            return 1;
          } else {
            if ($catcon_EZconnToPdb) {
              if ($ConNamesIncl || $ConNamesExcl) {
                # bug 25507396: if $catcon_EZconnToPdb is defined, neither 
                #   $ConNamesIncl nor $ConNamesExcl should be defined
                log_msg_error <<msg;
name of a PDB ($catcon_EZconnToPdb) to which EZConnect string(s) 
    should take us was specified, but so was a list of Containers to 
    include ($ConNamesIncl) or exclude ($ConNamesExcl)
msg
                return 1;
              }

              # bug 25507396: now that we verified that the caller has not 
              #   specified inclusive/exclusive lists, we will set the 
              #   inclusive list to the name of the PDB against which all 
              #   scripts need to run, which will allow us to take advantage of
              #   existing code that handles the inclusive list
              $ConNamesIncl = $catcon_EZconnToPdb;
            }

            if ($catcon_FedRoot) {
              # if Federation Root name was supplied, verify that neither 
              #   inclusive nor exclusive list of Container name has been 
              #   supplied
              # - confirm that the specified Container exists and is, indeed, 
              #   a Federation Root
              # - construct a string consisting of the name of the specified 
              #   Federation Root and all Federation PDBs belonging to it and 
              #   set $ConNamesIncl to that string (as if it were specified by 
              #   the caller, so we can take advantage of existing code 
              #   handling caller-supplied inclusive Container name list)
              if ($ConNamesIncl || $ConNamesExcl) {
                log_msg_error <<msg;
Federation Root name and either a list of Containers in which to 
    run scripts or a list of Containers in which NOT to run scripts were 
    specified, which is disallowed
msg
                return 1;
              }
  
              log_msg_debug("confirm that $catcon_FedRoot is an App Root");
             
              for (my $curCon = 0; $curCon <= $#catcon_AllContainers; 
                   $curCon++) 
              {
                if ($catcon_AllContainers[$curCon] eq $catcon_FedRoot) {
                  # specified Container appears to exist; next we will 
                  # - verify that the specified Container name refers to a 
                  #   Federation Root and obtain its CON ID
                  # - construct $ConNamesIncl by appending to the name of the 
                  #   Federation Root names of all Federation PDBs 
                  #   belonging to this Federation Root (so we can take 
                  #   advantage of existing code handling caller-supplied 
                  #   inclusive Container name list)
                  log_msg_debug <<msg;
Container specified as a Federation Root exists
    verify that it is a Federation Root
msg
                  
                  my $IsFedRoot;
                  my $FedRootConId;
  
                  if (get_fed_root_info(@intConnectString, $catcon_DoneCmd,
                                        $doneFileNamePrefix, 
                                        $catcon_FedRoot, $IsFedRoot, 
                                        $FedRootConId, $catcon_Sqlplus)) {
                    log_msg_error("unexpected error in get_fed_root_info");
                    return 1;
                  }
  
                  if (!$IsFedRoot) {
                    log_msg_error <<msg;
Purported App Root $catcon_FedRoot has disappeared
msg
                    return 1;
                  }
  
                  if ($IsFedRoot ne "YES") {
                    log_msg_error("Purported App Root $catcon_FedRoot is ".
                                  "not\n");
                    return 1;
                  }
  
                  log_msg_debug <<msg;
Container $catcon_FedRoot is indeed an App Root;
    calling get_fed_pdb_names
msg
  
                  my @FedPdbNames;
  
                  if (get_fed_pdb_names(@intConnectString, $catcon_DoneCmd,
                                        $doneFileNamePrefix, 
                                        $FedRootConId, @FedPdbNames,
                                        $catcon_Sqlplus)) {
                    log_msg_error("unexpected error in get_fed_pdb_names");
                    return 1;
                  }
  
                  # place Federation Root name at the beginning of 
                  # $ConNamesIncl
                  $ConNamesIncl = $catcon_FedRoot;
  
                  # append Federation PDB names to $ConNamesIncl
                  for my $FedPdbName ( @FedPdbNames ) {
                    $ConNamesIncl .= " ".$FedPdbName;
                  }
  
                  log_msg_debug <<msg;
ConNamesIncl reset to names of Containers comprising 
    Federation rooted in $catcon_FedRoot:
        $ConNamesIncl
msg
                }
              }
  
              # if the specified Container was a Federation Root, $ConNamesIncl
              # should be set to a list consisting of the name of the 
              # Federation Root followed by the names of its Federation PDBs, 
              # but if that Container did not exist, then $ConNamesIncl will be
              # still undefined
              if (!$ConNamesIncl) {
                log_msg_error <<msg;
Purported Federation Root $catcon_FedRoot does not exist
msg
                return 1;
              }
            }
          }

          if ($#ezConnStrings == 0) {
            log_msg_debug("only one instance to choose from; checking if ".
                          "all desired \n\tContainers are open on it");

            if ($ConNamesExcl) {
              if (!(@catcon_Containers = 
                    validate_con_names($ConNamesExcl, 1, @catcon_AllContainers,
                        $catcon_AllPdbMode == CATCON_PDB_MODE_UNCHANGED
                          ? \%isConOpen : undef, 
                        $catcon_IgnoreInaccessiblePDBs,
                        $catcon_IgnoreAllInaccessiblePDBs))) {
                log_msg_error("Unexpected error returned by ".
                              "validate_con_names for exclusive Container ".
                              "list");
                return 1;
              }
            } elsif ($ConNamesIncl) {
              if (!(@catcon_Containers = 
                    validate_con_names($ConNamesIncl, 0, @catcon_AllContainers,
                        $catcon_AllPdbMode == CATCON_PDB_MODE_UNCHANGED
                          ? \%isConOpen : undef, 
                        $catcon_IgnoreInaccessiblePDBs,
                        $catcon_IgnoreAllInaccessiblePDBs))) {
                log_msg_error("Unexpected error returned by ".
                              "validate_con_names for inclusive Container ".
                              "list");
                return 1;
              } 
            } else {
              # we know that all desired Containers (i.e. Containers in 
              # @catcon_AllContainers) exist, so we just need to check if 
              # they are open

              my $AllConStr = join(" ", @catcon_AllContainers);

              if (!(@catcon_Containers = 
                    validate_con_names($AllConStr, 0, @catcon_AllContainers, 
                        $catcon_AllPdbMode == CATCON_PDB_MODE_UNCHANGED
                          ? \%isConOpen : undef, 
                        $catcon_IgnoreInaccessiblePDBs,
                        $catcon_IgnoreAllInaccessiblePDBs))) {
                log_msg_error("Unexpected error returned by ".
                              "validate_con_names");
                return 1;
              } 
            }

            # there are no apparent obstacles to using this Instance. 
            # Remember that we found a satisfactory instance and copy a 
            # list of open Container indicators for future use
            $ezConnToUse = $EZConnect;
            %catcon_IsConOpen = %isConOpen;
            
            log_msg_debug <<msg;
instance $instanceName represented by the only EZConnect
    string has all desired Containers open on it
msg
          }
        } else {
          # at least one EZConnect string has been processed, so we no longer
          # need to fetch names of all Containers.  We do, however, need to 
          # determine which of the Containers are open on this instance and 
          # populate %isConOpen accordingly

          log_msg_debug("Obtain open container indicators");

          if (get_con_info(@intConnectString, $catcon_DoneCmd, 
                           $doneFileNamePrefix, undef, undef, undef, undef,
                           \%isConOpen, $catcon_UserScript, 
                           $catcon_EZconnToPdb, $catcon_Sqlplus)) {
            log_msg_error("unexpected error in get_con_info(2)");
            return 1;
          }
        }
        
        log_msg_debug("on instance ".$instanceName.
                      ", Container names and open indicators are {");

        for (my $curCon = 0; $curCon <= $#catcon_AllContainers; $curCon++) {
          log_msg_debug("\t\t$catcon_AllContainers[$curCon] -- ".
                        "$isConOpen{$catcon_AllContainers[$curCon]}");
        }
        log_msg_debug("}");

        if (defined $ezConnToUse) {
          # there is nothing more to do for this EZConnect string, and no 
          # more string to process (I could have called last earlier, but I 
          # did not want to duplicate code dumping Container names and modes)
          if ($ezConnToUse eq "") {
            log_msg_debug <<msg;
all desired Containers are open on the default instance 
    ($instanceName) - skip the remainder of EZConnect string processing
msg
          } else {
            log_msg_debug <<msg;
all desired Containers are open on instance ($instanceName)
    corresponding to the only eZConnect string - skip the remainder of 
    EZConnect string processing
msg
          }

          last;
        }

        # if this is the first (of many) EZConnect strings, determine the list 
        # of desired Containers
        if ($currInst == 0) {
            log_msg_debug <<msg;
processing the first of many EZConnect strings - determine names 
    of desired Containers
msg

          if ($ConNamesExcl) {
            if (!(@catcon_Containers = 
                  validate_con_names($ConNamesExcl, 1, 
                                     @catcon_AllContainers, undef,
                                     $catcon_IgnoreInaccessiblePDBs,
                                     $catcon_IgnoreAllInaccessiblePDBs))) {
              log_msg_error("Unexpected error returned by validate_con_names ".
                            "for exclusive Container list");
              return 1;
            }
          } elsif ($ConNamesIncl) {
            if (!(@catcon_Containers = 
                  validate_con_names($ConNamesIncl, 0, 
                                     @catcon_AllContainers, undef,
                                     $catcon_IgnoreInaccessiblePDBs,
                                     $catcon_IgnoreAllInaccessiblePDBs))) {
              log_msg_error("Unexpected error returned by validate_con_names ".
                            "for inclusive Container list");
              return 1;
            } 
          } else {
            # we know that all desired Containers (i.e. Containers in 
            # @catcon_AllContainers) exist, and we don't care whether they 
            # are open, so just copy @catcon__AllContainers into 
            # @catcon_Containers
            @catcon_Containers = @catcon_AllContainers;
          }

          log_msg_debug("scripts need to be run in the following ".
                        "Containers:\n\t".
                        join("\n\t", @catcon_Containers));
        }

        log_msg_debug("check if desired Containers are open on this ".
                      "instance:");

        # unless the caller indicated that all relevant PDBs must be opened 
        # prior to running scripts against them, determine if all desired 
        # Containers (whose names are stored in @catcon_Containers) are open 
        # on this Instance
        if ($catcon_AllPdbMode != CATCON_PDB_MODE_UNCHANGED) {
          $ezConnToUse = $EZConnect;
        } elsif ($ConNamesExcl || $ConNamesIncl) {
          # Containers whose names are stored in @catcon_Containers need to be 
          # open

          my $curCon;             #index into @catcon_Containers

          for ($curCon = 0; $curCon <= $#catcon_Containers; $curCon++) {
            if ($isConOpen{$catcon_Containers[$curCon]} eq "N") {
              # this Container is not open - no need to look further
              log_msg_debug("\tContainer ".$catcon_Containers[$curCon].
                            " is not open - skip the rest");
              last;
            } else {
              log_msg_debug("\tContainer ".$catcon_Containers[$curCon].
                            " is open");
            }
          }
          
          if ($curCon > $#catcon_Containers) {
            # all desired Containers are open on this Instance, so use it
            $ezConnToUse = $EZConnect;
          }
        } else {
          # ALL Containers need to be open, so we simply need to run down 
          # @isConOpen and hope not to find a single indicator containing "N"
          my $curCon;

          for ($curCon = 0; 
               $curCon <= $#catcon_AllContainers && 
               $isConOpen{$catcon_AllContainers[$curCon]} eq "Y"; 
               $curCon++) {
            log_msg_debug("\tContainer ".$catcon_AllContainers[$curCon].
                          " is open");
          }

          if ($curCon > $#catcon_AllContainers) {
            # all desired Containers are open on this Instance, so use it
            $ezConnToUse = $EZConnect;
          } else {
            log_msg_debug("\tContainer ".$catcon_AllContainers[$curCon].
                          " is not open - skip the rest");
          }
        }
        
        if (defined $ezConnToUse) {
          # we found our instance - copy a list of open Container indicators 
          # for future use
          %catcon_IsConOpen = %isConOpen;

          log_msg_debug <<msg;
all desired Containers are open on instance ($instanceName) 
    which will be picked to run all scripts
msg
        }

        log_msg_verbose("end CDB-specific processing");
      } else {
        log_msg_verbose("start non-CDB-specific processing");

        # will run scripts against a non-CDB

        # compute number of processes that can be started on this instance if 
        # this is the first instance or if the caller has not specified a 
        # number of processes to start (which may result in us discovering 
        # that this instance may support a larger number of processes than 
        # previously processed instances) 
        if ($currInst == 0 || $NumProcesses == 0) {
          my $msg = "call get_num_procs to determine number of ".
                    "processes that may be started on this Instance ".
                    "because\n";

          if ($currInst == 0) {
            $msg .= "\tthis is the first instance being processed";
          } else {
            $msg .= "\tuser did not specify a number of processes";
          }

          log_msg_debug($msg);

          # NOTE: in the non-CDB case, we will not ask get_num_procs to 
          #       determine how many processes can be allocated to various 
          #       instances (because in case of upgrade (the initial target 
          #       of changes to enable scripts to be run on multiple 
          #       instances), a non-CDB can only be open on one instance 
          #       and we will leave it open where it is)
          my $numProcs = 
            get_num_procs($NumProcesses, $ExtParallelDegree, 
                          \@intConnectString, 
                          $catcon_DoneCmd, $doneFileNamePrefix, 
                          0, undef, $catcon_InvokeFrom, $catcon_Sqlplus);

          if ($numProcs == -1) {
            log_msg_error("unexpected error in get_num_procs");
            return 1;
          } elsif ($numProcs < 1) {
            log_msg_error("invalid number of processes ($numProcs) ".
                          "returned by get_num_procs");
            return 1;
          } else {
            log_msg_debug("get_num_procs determined that $numProcs ".
                          "processes can be started on this instance");
          }
            
          if ($numProcs > $catcon_NumProcesses) {
            # this instance will support a greater number of processes than
            # preceding instance (if any) - remember the number of 
            # processes as well as the EZConnect string of the instance we 
            # will want to use
            $catcon_NumProcesses = $numProcs;
            $ezConnToUse = $EZConnect;
            
            log_msg_debug("remember this instance as supporting the ".
                          "greatest number of processes so far");
          }
        }

        log_msg_verbose("end non-CDB-specific processing");
      }
    }

    # make sure we found a suitable Instance
    if (!(defined $ezConnToUse)) {
      # none of the instances had all of the desired Containers open
      log_msg_error("multiple instances were specified, but none of ".
                    "them had all of the desired Containers open");
      return 2;
    }

    log_msg_verbose("finished examining instances which can be used to ".
                    "run scripts/SQL statements.");

    # if EZConnect strings were specified, $catcon_InternalConnectString and 
    # $catcon_UserConnectString contain placeholders for the EZConnect string 
    # corresponding to the instance that we pick.  Now that we have 
    # settled on a specific instance, replace these placeholders with the 
    # actual EZConnect string
    if (@ezConnStrings) {
      # Bug 21202842: do not produce diagnostic output when generating real 
      #               connect strings to avoid displaying passwords
      $catcon_InternalConnectString[0] = 
        build_connect_string($catcon_InternalConnectString[0], $ezConnToUse, 
                             0);
      $catcon_UserConnectString[0] = 
        build_connect_string($catcon_UserConnectString[0], $ezConnToUse, 0);

      # Bug 21202842: pass the real debug setting since here we are using 
      #               connect strings with redacted password
      $catcon_InternalConnectString[1] = 
        build_connect_string($catcon_InternalConnectString[1], $ezConnToUse, 
                             1);
      $catcon_UserConnectString[1] = 
        build_connect_string($catcon_UserConnectString[1], $ezConnToUse, 1);
      
      log_msg_debug <<msg;
finalized connect strings:
    Internal Connect String = $catcon_InternalConnectString[1]
    User Connect String = $catcon_UserConnectString[1]
msg
    }

    # if the caller has requested that we use all available instances, we 
    # need to
    # - determine whether we are connected to a RAC database in which case 
    #   we need to
    #   - obtain db_unique_name of the database (needed for communicating 
    #     with srvctl)
    #   - obtain names of instances which are NOT running and nodes on which 
    #     they are not running and for every such instance
    #     - start that instance
    #     - add that instance to the list of instances that need to be 
    #       stopped before finishing catcon processing
    if ($catcon_AllInst) {
      log_msg_debug("call get_db_param to obtain value of cluster_database ".
                    "parameter");

      $catcon_IsRac = 
        get_db_param(@catcon_InternalConnectString, 'cluster_database',
                     $catcon_DoneCmd, $doneFileNamePrefix, $catcon_Sqlplus);

      if (!$catcon_IsRac) {
        log_msg_error("unexpected error in get_db_param");
        return 1;
      }

      log_msg_debug("value of cluster_database parameter = $catcon_IsRac");
      
      if ($catcon_IsRac eq "TRUE") {
        # obtain DB_UNIQUE_NAME
        log_msg_debug("call get_db_unique_name");

        $catcon_DbUniqueName = 
          get_db_unique_name(@catcon_InternalConnectString, $catcon_DoneCmd, 
                             $doneFileNamePrefix, $catcon_Sqlplus);

        if (!$catcon_DbUniqueName) {
          log_msg_error("unexpected error in get_db_unique_name");
          return 1;
        }

        log_msg_debug("DB unique name = $catcon_DbUniqueName");

        # obtain information on RAC instances which are not running 
        log_msg_debug("call get_rac_instance_state");

        if (get_rac_instance_state($catcon_DbUniqueName, 
                                   \@catcon_IdleRacInstances, 
                                   \@catcon_RunningRacInstances)) {
          log_msg_error("unexpected error in get_rac_instance_state");
          return 1;
        }

        if (@catcon_IdleRacInstances && $#catcon_IdleRacInstances >= 0) {
          log_msg_debug("call alter_rac_instance_state to start instances ".
                        "that are not running");

          # at least one of RAC instances needs to be started
          if (alter_rac_instance_state($catcon_DbUniqueName, 
                                       \@catcon_IdleRacInstances, 1)) {
            log_msg_error("unexpected error in alter_rac_instance_state");
            return 1;
          }
        } else {
          log_msg_debug("all instances are already running");
        }
      }
    }

    # bug 25315864: determine connect strings which need to be used to ensure 
    # connection to a given instance name

    log_msg_debug("call gen_inst_conn_strings to obtain instance ".
                  "connect strings");

    # Bug 25366291: in some cases, gen_inst_conn_strings may fetch no rows, 
    #   causing @catcon_InstConnStr to remain undefined and 
    #   gen_inst_conn_strings to return 0. 
    #
    #   Rather than treating it as an error, we will force all processing to 
    #   occur on the default instance
    if (! defined gen_inst_conn_strings(\@catcon_InternalConnectString, 
                                        $catcon_DoneCmd, $doneFileNamePrefix, 
                                        \%catcon_InstConnStr, 
                                        $catcon_Sqlplus)) {
      log_msg_error("unexpected error in gen_inst_conn_strings");
      return 1;
    }

    # Bug 25061922: obtain DBMS version to help catcon to use 
    # backward-compatible syntax if working on earlier version DBMS
    log_msg_debug("call get_dbms_version to obtain DBMS version");

    $catcon_DbmsVersion = 
      get_dbms_version(@catcon_InternalConnectString, 
                       $catcon_DoneCmd, $doneFileNamePrefix,
                       $catcon_Sqlplus);

    if (!(defined $catcon_DbmsVersion)) {
      log_msg_error("unexpected error in get_dbms_version");
      return 1;
    }

    log_msg_verbose("DBMS version: $catcon_DbmsVersion.");

    # if we haven't determined the number of processes which may be started 
    # on the chosen Instance (which would imply that we will be running 
    # against a CDB since for non-CDBs we select the instance to use based on 
    # the number of processes that can be started on it), do it now
    if (!$catcon_NumProcesses) {
      # Bug 20193612, 25392172: if 
      #   - connected to a CDB (we would not find ourselves here if it were 
      #     not the case),
      #   - the caller has requested that we use multiple instances (and we 
      #     have no grounds for ignoring that request), and
      #   - use of multiple instances is feasible based on parameters 
      #     supplied by the caller and characteristics of the CDB
      # we will ignore number of processes supplied by the caller and let 
      # get_num_procs determine number of processes that can be opened on 
      # all of CDB's instances
      #
      # NOTE: $multInstFeasible checks for conditions listed above but 
      #       does NOT check for special restrictions (i.e. if we are running 
      #       UPGRADE and the caller has supplied 0 as the number of 
      #       processes) which could cause us to ignore caller's request
      my $multInstFeasible = 
        mult_inst_feasible(all_inst_requested($catcon_AllInst, 
                                              $catcon_AllPdbMode), 
                           \@catcon_InternalConnectString, 
                           \%catcon_InstConnStr, \@catcon_UserConnectString,
                           $catcon_DbmsVersion);

      log_msg_debug <<msg;
call get_num_cdb_procs to determine number of processes that will be started
msg

      # NOTE: the caller may have requested that we use all available 
      #       instances, but we may choose to ignore his request

      $catcon_NumProcesses = 
        get_num_cdb_procs($NumProcesses, 
          (all_inst_requested($catcon_AllInst, $catcon_AllPdbMode) && 
           !ignore_all_inst_request($catcon_RunningUpgrade, $NumProcesses)),
          $multInstFeasible, \@catcon_InternalConnectString, 
          $catcon_IsRac, 
          @catcon_IdleRacInstances + @catcon_RunningRacInstances, 
          $catcon_ExtParallelDegree, $catcon_DoneCmd, $catcon_LogFilePathBase, 
          \%catcon_InstProcMap, $catcon_InvokeFrom, $catcon_Sqlplus);

      if ($catcon_NumProcesses == -1) {
        log_msg_error("unexpected error in get_num_cdb_procs");
        return 1;
      }

      log_msg_debug("get_num_cdb_procs determined that $catcon_NumProcesses ".
                    "processes should be started.");
    }

    # generate "kill all sessions script" name
    $catcon_KillAllSessScript = 
      kill_session_script_name($catcon_LogFilePathBase, "ALL");

    # save name of a script that will be used to generate a 
    # "kill session script"
    $catcon_GenKillSessScript = 
      $ENV{ORACLE_HOME}."/rdbms/admin/catcon_kill_sess_gen.sql";

    # look for catcon_kill_sess_gen.sql in the current catcon.pm file directory
    # if ORACLE_HOME has not yet been properly setup
    if (!-e $catcon_GenKillSessScript) {
      my $catcon_dir = dirname(File::Spec->rel2abs(__FILE__));
      $catcon_GenKillSessScript = $catcon_dir."/catcon_kill_sess_gen.sql";
      log_msg_debug("catcon_kill_sess_gen.sql not found at ".
                    "ORACLE_HOME, will instead use $catcon_GenKillSessScript");
    }

    # Bug 25392172: determine if all processing should take place on the 
    #   default instance, i.e. if we decided to not construct 
    #   instance-to-process mapping or if there is only 1 instance on which 
    #   the CDB is open
    # 
    # Bug 27634676: we will obtain default instance name regardless of 
    #   whether all processing will be occurring on the default instance
    #
    # NOTE: $catcon_DfltInstName will not longer be used as an indicator of 
    #       whether processing will take place only on the default 
    #       instance - 
    #         (!%catcon_InstProcMap || (scalar keys %catcon_InstProcMap) < 2)
    #       should be checked for that purpose
    {
      log_msg_debug("call get_instance_status_and_name to obtain\n".
                    "\tname of the default instance");
      
      my $instStatus;

      ($instStatus, $catcon_DfltInstName) =
        get_instance_status_and_name(@catcon_InternalConnectString, 
                                     $catcon_DoneCmd, $doneFileNamePrefix,
                                     $catcon_Sqlplus);

      if (!$instStatus) {
        log_msg_error("unexpected error in get_instance_status_and_name");
        return 1;
      } elsif ($instStatus !~ /^OPEN/) {
        log_msg_error("database is not open on the default instance (".
                      $catcon_DfltInstName.")");
        return 1;
      }
    }

    my $msg = "processing will take place on ";

    if (!%catcon_InstProcMap || (scalar keys %catcon_InstProcMap) < 2) {
      $msg .= "the default instance $catcon_DfltInstName";
    } else {
      $msg .= "all available instances";
    }

    log_msg_debug($msg);

    # it is possible that we may start more processes than there are PDBs (or 
    # more than 1 process when operating on a non-CDB.)  It's OK since a user 
    # can tell catconExec() that some scripts may be executed concurrently, 
    # so we may have more than one process working on the same Container (or 
    # non-CDB.)  If a user does not want us to start too many processes, he 
    # can tell us how many processes to start (using -n option to catcon.pl, 
    # for instance)

    # start processes
    if (start_processes($catcon_NumProcesses, $catcon_LogFilePathBase, 
                        @catcon_FileHandles, @catcon_ProcIds,
                        @catcon_Containers, $catcon_Root,
                        @catcon_UserConnectString, 
                        $catcon_EchoOn, $catcon_ErrLogging, $catcon_LogLevel, 
                        1, (!$catcon_UserScript && !$catcon_NoOracleScript), 
                        $catcon_FedRoot, 
                        $catcon_DoneCmd, $catcon_DisableLockdown,
                        -1, undef, $catcon_GenKillSessScript,
                        $catcon_KillAllSessScript, \%catcon_InstProcMap, 
                        \%catcon_ProcInstMap, \%catcon_InstConnStr, 
                        $catcon_Sqlplus)) {
      return 1;
    }

    log_msg_verbose("started SQL*Plus processes.");

    # remember whether we are being invoked from a GUI tool which on Windows 
    # means that the passwords and hidden parameters need not be hidden
    $catcon_GUI = $GUI;

    # remember that initialization has completed successfully
    $catcon_InitDone = 1;
    
    # catctl will use catconMultipleInstancesFeasible to determine whether 
    # multiple instances will be used when it invokes catcon to process PDBs,
    # so make sure we return the correct value
    log_msg_debug("Processing PDBs may ".
                  (catconMultipleInstancesFeasible() ? "be" : "not be").
                  " able to use multiple instances");

    log_msg_verbose("initialization completed successfully (".TimeStamp().")");

    #
    # Workaround for bug 18969473
    #
    if ($catcon_Windows) {
      open(STDIN, "<", "NUL") || die "open NUL: $!";
    }

    # success
    return 0;
  }

  #
  # catconXact - set a flag indicating whether we should check for scripts 
  #     ending with uncommitted transaction
  #
  # Parameters:
  #   - value to assign to $catcon_UncommittedXactCheck
  #
  sub catconXact ($) {
    my ($UncommittedXactCheck) = @_;

    # remember whether the caller wants us to check for uncommitted 
    # transactions at the end of scripts
    $catcon_UncommittedXactCheck = $UncommittedXactCheck;
  }

  #
  # catconReverse - set a flag indicating whether we should run the script 
  # against all PDBs and then against the Root
  #
  # Parameters:
  #   - value to assign to $catcon_PdbsThenRoot
  #
  sub catconReverse ($) {
    my ($f) = @_;

    # remember whether the caller wants us to check for uncommitted 
    # transactions at the end of scripts
    $catcon_PdbsThenRoot = $f;
  }

  #
  # catconPdbMode - remember the mode in which all PDBs being operated upon 
  #                 must be opened
  #
  # Parameters:
  #   - value to assign to $catcon_AllPdbMode
  #
  sub catconPdbMode ($) {
    my ($mode) = @_;
   
    # verify that the specified mode is valid
    if (!valid_pdb_mode($mode)) {
      log_msg_error("Unexpected value ($mode) for mode");
      return 1;
    }
    
    # we don't want to change the mode in which PDBs are to be opened once it 
    # has been set so as to avoid resetting mode of PDBs after it has been 
    # already changed
    if ($catcon_AllPdbMode != CATCON_PDB_MODE_NA) {
      log_msg_error("may not be called more than once ".
                    "(current mode = $catcon_AllPdbMode)");
      return 1;
    }

    $catcon_AllPdbMode = $mode;

    return 0;
  }

  #
  # catconAllInst - remember whether the caller has informed us that if 
  #                 running against a CDB, PDBs should be open using all 
  #                 available instances
  #
  # Parameters:
  #   - value to assign to $catcon_AllInst
  #
  sub catconAllInst ($) {
    my ($allInst) = @_;

    # The following issues need to be addressed:
    # - log files for SQL*PLus processes which were not assigned any work 
    #   should be removed
    # - names of log files created during upgrade should be the same as they 
    #   are in a non-RAC case to avoid having to make changes to DBUA
    # - time it takes to upgrade a PDB in a RAC CDB should be no worse than 
    #   that in a non-RAC CDB

    $catcon_AllInst = $allInst;
  }

  #
  # catconUpgrade - remember whether the caller has informed us that we are 
  # being called in the course of upgrade
  #
  # Parameters:
  #   - value to assign to $catcon_RunningUpgrade
  #
  sub catconUpgrade ($) {
    my ($upgrade) = @_;
   
    $catcon_RunningUpgrade = $upgrade;
  }

  #
  # catconForce - set a flag indicating whether we should ignore closed or 
  # non-existent PDBs when constructing a list of Containers against which to 
  # run scripts
  #
  # Parameters:
  #   - value to assign to $catcon_IgnoreInaccessiblePDBs
  #
  sub catconForce ($) {
    my ($Ignore) = @_;

    # remember whether the caller wants us to ignore closed and 
    # non-existent PDBs 
    $catcon_IgnoreInaccessiblePDBs = $Ignore;
  }


  #
  # catconUpgForce - set a flag indicating whether we should ignore all PDBs
  # when constructing a list of Containers against which to 
  # run scripts
  #
  # Parameters:
  #   - value to assign to $catcon_IgnoreAllInaccessiblePDBs
  #
  sub catconUpgForce ($) {
    my ($Ignore) = @_;

    # remember whether the caller wants us to ignore all PDB's 
    $catcon_IgnoreAllInaccessiblePDBs = $Ignore;
  }

  #
  # catconUpgSetPdbOpen - Marks as open PDB(s) which were opened by upgrade 
  #                       after we called catconInit.
  # Parameters:
  #   - space separated list of names of PDB(s) to mark as open
  #
  # Returns:
  #   1 - Failure
  #   0 - Success
  #
  sub catconUpgSetPdbOpen ($$) {
    my ($pPdbs,$DebugOn) = @_;

    my $curCon; # index for catcon_AllContainers array

    #
    # Check to make sure catconInit2 has been called
    #
    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return 1;
    }

    log_msg_debug <<catconUpgSetPdbOpen_DEBUG;
  running catconUpgSetPdbOpen(pPdbs  = $pPdbs,
                              Debug  = $DebugOn);
catconUpgSetPdbOpen_DEBUG

    # split contents of $pPdbs into an array of PDB names
    my @pdbArr = split(' ', $pPdbs);

    foreach my $pdb (@pdbArr) {
      #
      # If the specified PDB exists, set open flag
      # 
      if (exists $catcon_IsConOpen{$pdb}) {
        $catcon_IsConOpen{$pdb} = 'Y';
      } else {
        #
        # Pdb not found
        #
        log_msg_error("Cannot set Pdb to open. [$pdb] is not found");
        return 1;
      }
    }

    return 0;
  }

  #
  # catconEZConnect - store a string consisting of EZConnect strings 
  # corresponding to RAC instances to be used to run scripts
  #
  # Parameters:
  #   - value to assign to $catcon_EZConnect
  #
  sub catconEZConnect ($) {
    my ($EZConnect) = @_;

    $catcon_EZConnect = $EZConnect;
  }

  #
  # catconEZconnToPdb - store name of a PDB, if any, to which EZConnect 
  #                     strings should lead and against which all specified 
  #                     scripts will be run
  #
  # Parameters:
  #   - value to assign to $catcon_EZconnToPdb
  #
  sub catconEZconnToPdb ($) {
    my ($pdb) = @_;

    $catcon_EZconnToPdb = $pdb;
  }

  #
  # catconNoOracleScript - set an indicator to preclude _oracle_script from 
  #                        being set even if running non-user-supplied script
  #
  # Parameters:
  #   none
  #
  sub catconNoOracleScript () {
    $catcon_NoOracleScript = 1;
  }

  #
  # catconVerbose - set catcon log level to VERBOSE (so only messages with 
  #                 log level >= VERBOSE are displayed.)
  #
  #  NOTE: this may get overwritten by catconInit2 if the caller also requested
  #        that messages with log level >= DEBUG are displayed
  #
  # Parameters:
  #   none
  #
  sub catconVerbose () {
    if ($catcon_LogLevel == CATCON_LOG_LEVEL_DFLT) {
      # log level has not been set, so set it to VERBOSE
      $catcon_LogLevel = CATCON_LOG_LEVEL_VERBOSE;
    } else {
      log_msg_error("this subroutine should not be invoked after\n".
                    "\tlog level has been set to $catcon_LogLevel (".
                    LOG_LEVEL_TO_STRING->{$catcon_LogLevel}.")");
      die;
    }
  }

  #
  # catconIgnoreErr - remember which errors should be ignored
  #
  # Parameters:
  #   - space-separated list of indicators of which errors should be ignored
  #
  sub catconIgnoreErr($) {
    my ($Indicators) = @_;

    # if no indicators were supplied, we are done
    if (!$Indicators) {
      return 0;
    }

    my @IndArr = split(' ', $Indicators);

    # iterate over indicators, marking corresponding %catcon_ErrorsToIgnore 
    # elements
    for my $Ind ( @IndArr ) {
      if (!(defined $catcon_ErrorsToIgnore{$Ind})) {
        # unrecognized indicator
        print STDERR "catconIgnoreErr: unrecognized indicator - $Ind\n";
        print STDERR "\t The following indicators are supported:\n";
        for my $ValidInd (sort keys %catcon_ErrorsToIgnore) {
          print STDERR "\t\t$ValidInd \n";
        }
        return 1;
      }

      $catcon_ErrorsToIgnore{$Ind} = 1;
    }

    return 0;
  }

  #
  # catconFedRoot - store name of a Root of a Federation against members of 
  #                 which script(s) are to be run
  #
  # Parameters:
  #   - value to assign to $catcon_FedRoot
  #
  sub catconFedRoot ($) {
    my ($FedRoot) = @_;

    $catcon_FedRoot = $FedRoot;
  }

  #
  # catconDisableLockdown - store boolean indicating whether lockdown needs to
  #                         be disabled.
  #
  # Parameters:
  #   - value to assign to $catcon_DisableLockdown
  #
  sub catconDisableLockdown ($) {
    my ($DisableLockdown) = @_;

    $catcon_DisableLockdown = $DisableLockdown;
  }

  #
  # catconRecoverFromChildDeath - store boolean indicating whether death of a 
  #                               spawned sqlplus process should cause catcon
  #                               to die.
  #
  # Parameters:
  #   - value to assign to $catcon_RecoverFromChildDeath
  #
  sub catconRecoverFromChildDeath ($) {
    my ($recoverFromChildDeath) = @_;

    $catcon_RecoverFromChildDeath = $recoverFromChildDeath;
  }

  # if scripts will be executed against PDBs using multiple RAC instances, 
  # "done" file constructed by the child process before exiting will contain 
  # info for the parent.  The following constants will be used to identify 
  # data contained in such files
  
  # line containing return value will look like this:
  #   RETVAL:<value>
  use constant CATCONEXEC_CHILD_DONE_FILE_RETVAL => "RETVAL";

  # Line containing an indicator that a SQL*Plus process allocated to the child
  # process was involved in running some statements or scripts will look like
  # this:
  #  ACTIVE_PROC:<offset into child process' @catcon_ProcIds>
  use constant CATCONEXEC_CHILD_DONE_FILE_ACTIVE_PROC => "ACTIVE_PROC";

  # catconExec - run specified sqlplus script(s) or SQL statements
  #
  # If connected to a non-Consolidated DB, each script will be executed 
  # using one of the processes connected to the DB.
  #
  # If connected to a Consolidated DB and the caller requested that all 
  # scripts and SQL statements be run against the Root (possibly in addition 
  # to other Containers), each script and statement will be executed in the 
  # Root using one of the processes connected to the Root.
  #
  # If connected to a Consolidated DB and were asked to run scripts and SQL 
  # statements in one or more Containers besides the Root, all scripts and 
  # statements will be run against those PDBs in parallel.
  #
  # Bug 18085409: if connected to a CDB and $catcon_PdbsThenRoot is set, the 
  #   order will be reversed and we will run scripts against all PDBs and 
  #   then against the Root.  
  #   To accomplish this without substantially rewriting catconExec, I 
  #   - moved the whole catconExec into catconExec_int() and
  #   - changed catconExec to call catconExec_int as follows:
  #     - if not connected to a CDB or if $catcon_PdbsThenRoot is not set,
  #       - just call catconExec_int
  #     - else (i.e. connected to a CDB and $catcon_PdbsThenRoot is set)
  #       - call catconExec_int passing it name of the Root as a Container 
  #         in which not to run scripts
  #       - if the preceding call does not report an error, call 
  #         catconExec_int telling it to run scripts only in the Root
  #
  # Parameters:
  #   - a reference to an array of sqlplus script name(s) or SQL statement(s); 
  #     script names are expected to be prefixed with @
  #   - an indicator of whether scripts need to be run in order
  #       TRUE => run in order
  #   - an indicator of whether scripts or SQL statements need to be run only 
  #     in the Root if operating on a CDB (temporarily overriding whatever 
  #     was set by catconInit2) 
  #       TRUE => if operating on a CDB, run in Root only
  #   - an indicator of whether per process initialization/completion 
  #     statements need to be issued
  #     TRUE => init/comletion statements, if specified, will be issued
  #   - a reference to a list of names of Containers in which to run scripts 
  #     and statements during this invocation of catconExec; does not 
  #     overwrite @catcon_Containers so if no value is supplied for this or 
  #     the next parameter during subsequent invocations of catconExec, 
  #     @catcon_Containers will be used
  #
  #     NOTE: This parameter should not be defined if
  #           - connected to a non-CDB
  #           - caller told us to run statements/scripts only in the Root
  #           - caller has supplied us with a list of names of Containers in 
  #             which NOT to run scripts
  #
  #   - a reference to a list of names of Containers in which NOT to run 
  #     scripts and statements during this invocation of catconExec; does not 
  #     overwrite @catcon_Containers so if no value is supplied for this or 
  #     the next parameter during subsequent invocations of catconExec, 
  #     @catcon_Containers will be used
  #
  #     NOTE: This parameter should not be defined if
  #           - connected to a non-CDB
  #           - caller told us to run statements/scripts only in the Root
  #           - caller has supplied us with a list of names of Containers in 
  #             which NOT to run scripts
  #
  #   - a reference to a custom Errorlogging Identifier; if specified, we will
  #     use the supplied Identifier, ignoring $catcon_NoErrLogIdent
  #   - a query to run within a container to determine if the array should
  #     be executed in that container.  A NULL return value causes the
  #     script array to NOT be run.
  #
  sub catconExec(\@$$$\$\$\$\$) {

    my ($StuffToRun, $SingleThreaded, $RootOnly, $IssuePerProcStmts, 
        $ConNamesIncl, $ConNamesExcl, $CustomErrLoggingIdent, 
        $skipProcQuery) = @_;

    log_msg_verbose("start executing scripts/SQL statements");

    log_msg_debug("\tScript names/SQL statements:");
    foreach (@$StuffToRun) {
      log_msg_debug("\t\t$_");
    }

    log_msg_debug("\tSingleThreaded        = $SingleThreaded");
    log_msg_debug("\tRootOnly              = $RootOnly");
    log_msg_debug("\tIssuePerProcStmts     = $IssuePerProcStmts");
    if ($$ConNamesIncl) {
      log_msg_debug("\tConNamesIncl          = $$ConNamesIncl");
    } else {
      log_msg_debug("\tConNamesIncl            undefined");
    }
    if ($$ConNamesExcl) {
      log_msg_debug("\tConNamesExcl          = $$ConNamesExcl");
    } else {
      log_msg_debug("\tConNamesExcl            undefined");
    }
    if ($$CustomErrLoggingIdent) {
      log_msg_debug("\tCustomErrLoggingIdent = $$CustomErrLoggingIdent");
    } else {
      log_msg_debug("\tCustomErrLoggingIdent   undefined");
    }
    if ($$skipProcQuery) {
      log_msg_debug("\tskipProcQuery = $$skipProcQuery");
    }  else {
      log_msg_debug("\tskipProcQuery   undefined");
    }

    log_msg_debug("\t(".TimeStamp().")");

    # there must be at least one script or statement to run
    if (!@$StuffToRun || $#$StuffToRun == -1) {
      log_msg_error("At least one sqlplus script name or SQL statement ".
                    "must be supplied");
      return 1;
    }

    # catconInit2 had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return 1;
    }

    # a number of checks if either a list of Containers in which to run 
    # scripts or a list of Containers in which NOT to tun scripts was specified
    if ($$ConNamesIncl || $$ConNamesExcl) {
      if (!@catcon_Containers) {
        # Container names specified even though we are running against a 
        # non-CDB
        log_msg_error("Container names specified for a non-CDB");
        return 1;
      }

      if ($RootOnly) {
        # Container names specified even though we were told to run ONLY 
        # against the Root
        log_msg_error("Container names specified while told to run ".
                      "only against the Root");
        return 1;
      }

      if ($catcon_PdbsThenRoot) {
        # Container names specified even though we were told to run in 
        # ALL PDBs and then in the Root
        log_msg_error("Container names specified while told to run in ".
                      "ALL PDBs and then in Root");
        return 1;
      }

      if ($catcon_EZconnToPdb) {
        # bug 25507396: if $catcon_EZconnToPdb is defined, neither 
        #   $ConNamesIncl nor $ConNamesExcl should be defined
        log_msg_error <<msg;
name of a PDB ($catcon_EZconnToPdb) to which EZConnect string(s) 
    should take us was specified, but so was a list of Containers to 
    include ($$ConNamesIncl) or exclude ($$ConNamesExcl)
msg
        return 1;
      }

      # only one of the lists may be defined
      if ($$ConNamesIncl && $$ConNamesExcl) {
        log_msg_error <<msg;
both inclusive
        $$ConNamesIncl
    and exclusive
        $$ConNamesExcl
    Container name lists are defined
msg
        return 1;
      }
    }

    if ($RootOnly && $catcon_PdbsThenRoot) {
      # RootOnly may not be specified if were told to run in ALL PDBs and 
      # then in the Root
      log_msg_error <<msg;
Caller asked to run only in the Root while also indicating that 
    scripts must be run in ALL PDBs and then in Root
msg
      return 1;
    }

    my $RetVal;

    if (!@catcon_Containers || !$catcon_PdbsThenRoot) {
      # non-CDB or not told to reverse the order of Containers - just pass 
      # parameters on to catconExec_int
      $RetVal = catconExec_int($StuffToRun, $SingleThreaded, $RootOnly, 
                               $IssuePerProcStmts, $ConNamesIncl, 
                               $ConNamesExcl, $CustomErrLoggingIdent,
                               $skipProcQuery);
    } else {
      # connected to a CDB and need to run scripts in ALL PDBs and then in
      # the Root

      # bug 23292787: it is possible that the caller of catcon.pl has supplied
      #   both -c/-C and -r, in which case we need to determine whether the 
      #   set of Containers produced by processing -c/-C (and contained in 
      #   @catcon_Containers) includes the Root and one or more PDBs.  
      #   If we discover that it contained at least one PDB, we will process 
      #   PDBs. If we discover that it also contained Root, we will then 
      #   process the Root
      log_msg_debug("caller requested that we run scripts in PDBs ".
                    "and then in Root");
      log_msg_debug("\twill determine if the set of Containers in which we ".
                    "need to run includes Root and PDBs");

      my ($root, $pdbs) = split_root_and_pdbs(@catcon_Containers, 
                                              $catcon_Root);

      if (@$pdbs) {
        my $pdb_list = join(' ', @$pdbs);

        log_msg_debug("set of Containers included at least one PDB, ".
                      "so run scripts in ($pdb_list) first");

        # first call catconExec_int to run scripts in all Containers other than
        # the Root
        $RetVal = catconExec_int($StuffToRun, $SingleThreaded, $RootOnly, 
                                 $IssuePerProcStmts, \$pdb_list, 
                                 $ConNamesExcl, $CustomErrLoggingIdent,
                                 $skipProcQuery);
      }

      # skip processing the Root if running in a child process forked in 
      # catconExec to process PDBs open on a single instance
      if (defined $root && !$catcon_ChildProc) {
        # if catconExec_int reported an error, no further processing is needed
        if (!$RetVal) {
          # finally, call catconExec_int to run scirpts only in the Root
          log_msg_debug("set of Containers included the Root, ".
                        "so run it in $catcon_Root");

          $RetVal = catconExec_int($StuffToRun, $SingleThreaded, 1,
                                   $IssuePerProcStmts, $ConNamesIncl, 
                                   $ConNamesExcl, $CustomErrLoggingIdent,
                                   $skipProcQuery);
        } else {
          log_msg_debug("set of Containers included the Root, but an error\n". 
                        "\twas encountered while processing PDBs so no\n".
                        "\tattempt will be made to run it in $catcon_Root");
        }
      }
    }

    if ($RetVal) {
      log_msg_verbose("an error (".$RetVal.") was encountered");
    } else {
      log_msg_verbose("finished executing scripts/SQL statements")
    }

    # if running in a child process, exit
    # 
    # NOTE: unfortunately, (at least as far as I can tell) on Linux, exit does 
    #       not seem to cause the forked process to exit (as can be seen by 
    #       examining its log file), so I force it to commit suicide by 
    #       sending SIGKILL to itself
    if ($catcon_ChildProc) {
      log_msg_debug("child process $$ exiting with $RetVal");

      # commit suicide
      my @me;
      push @me, $$;

      # construct a "done" file informing the parent that this child process 
      # finished its work
      my $childDoneFile = child_done_file_name($catcon_LogFilePathBase, $$);
      my $childDoneFileFH;
      
      if (sysopen($childDoneFileFH, $childDoneFile, 
                  O_CREAT | O_WRONLY | O_TRUNC, 0600)) {
        # report return value to the parent
        print $childDoneFileFH CATCONEXEC_CHILD_DONE_FILE_RETVAL.":$RetVal\n";

        # report which of the SQL*Plus processes allocated to the child 
        # process were involved in executing some statement or script
        for (my $ps = 0; $ps < $catcon_NumProcesses; $ps++) {
          if (exists $catcon_ActiveProcesses[$ps]) {
            print $childDoneFileFH 
              CATCONEXEC_CHILD_DONE_FILE_ACTIVE_PROC.":$ps\n";
          }
        }

        close($childDoneFileFH);
      } else {
        log_msg_warn("child process finished with return value = ".
                     $RetVal.", but done file could not be created");
      }

      send_sig_to_procs(@me, 9);
    }

    return $RetVal;
  }

  # NOTE: catconExec_int() should ONLY be called via catconExec which 
  #       performs error checking to ensure that catconExec_int is not 
  #       presented with a combination of arguments which it is not prepared 
  #       to handle
  sub catconExec_int (\@$$$\$\$\$\$) {

    my ($StuffToRun, $SingleThreaded, $RootOnly, $IssuePerProcStmts, 
        $ConNamesIncl, $ConNamesExcl, $CustomErrLoggingIdent, $skipProcQuery) 
      = @_;

     #Hack add con_id
    my $CurrentContainerQuery = qq#select '==== Current Container = ' || SYS_CONTEXT('USERENV','CON_NAME') || ' Id = ' || SYS_CONTEXT('USERENV','CON_ID') || ' ====' AS now_connected_to from sys.dual;\n/\n#;

    # this array will be used to keep track of processes to which statements 
    # contained in @$PerProcInitStmts need to be sent because they [processes]
    # have not been used in the course of this invocation of catconExec()
    my @NeedInitStmts = ();
    my $bInitStmts = 0;

    # script invocations (together with parameters) and/or SQL statements 
    # which will be executed
    my @ScriptPaths;

    # same as @ScriptPaths but secret parameters will be replaced with prompts
    # so as to avoid storing sensitive data in log files (begin_running and 
    # end_running queries) and error logging tables (in identifier column)
    my @ScriptPathsToDisplay;

    # if $catcon_SpoolOn is set, we will spool output produced by running all 
    # scripts into spool files whose names will be stored in this array
    my @SpoolFileNames;

    my $NextItem;

    # validate script paths and add them, along with parameters and 
    # SQL statements, if any, to @ScriptPaths

    log_msg_debug("validating scripts/statements supplied by the caller");

    # if the user supplied regular and/or secret argument delimiters, this 
    # variable will be set to true after we encounter a script name to remind 
    # us to check for possible arguments
    my $LookForArgs = 0;
    
    # indicators of whether a string may be a regular or a secret script 
    # argument or an argument whose value is contained in an env var
    my $RegularScriptArg;
    my $SecretScriptArg;
    my $EnvScriptArg;

    foreach $NextItem (@$StuffToRun) {

      log_msg_debug("going over StuffToRun: NextItem = $NextItem");

      if ($NextItem =~ /^@/) {
        # leading @ implies that $NextItem contains a script name
        
        # name of SQL*Plus script
        my $FileName;

        log_msg_debug("next script name = $NextItem");

        # strip off the leading @ before prepending source directory name to 
        # script name
        ($FileName = $NextItem) =~ s/^@//;

        # validate path of the sqlplus script and add it to @ScriptPaths
        my $Path = 
          validate_script_path($FileName, $catcon_SrcDir, $catcon_Windows, 
                               $catcon_ErrorsToIgnore{script_path});

        if (!$Path) {
          log_msg_error <<msg;
empty Path returned by validate_script_path for 
    SrcDir = $catcon_SrcDir, FileName = $FileName
msg
          return 1;
        }

        push @ScriptPaths, "@".$Path;

        # before pushing a new element onto @ScriptPathsToDisplay, replace 
        # single and double quotes in the previous element (if any) with # 
        # to avoid errors in begin/end_running queries and in 
        # SET ERRORLOGGING ON IDENTIFIER ... statements
        if ($#ScriptPathsToDisplay >= 0) {
          $ScriptPathsToDisplay[$#ScriptPathsToDisplay] =~ s/['"]/#/g;
        }

        # assuming it's OK to show script paths
        push @ScriptPathsToDisplay, "@".$Path; 

        log_msg_debug("full path = $Path");
        
        # if caller requested that output of running scripts be spooled, 
        # construct prefix of a spool file name and add it to @SpoolFileNames 
        if ($catcon_SpoolOn) {
          # spool files will get stored in the same directory as log files, 
          # and their names will start with "log file base" followed by '_'
          my $SpoolFileNamePrefix = $catcon_LogFilePathBase .'_';

          log_msg_debug("constructing spool file name prefix: log file ".
                        "path base +' _' = $SpoolFileNamePrefix");
          
          # script file name specified by the caller may contain directories;
          # since we want to store spool files in the same directory as log
          # files, we will replace slashes with _
          my $Temp = $FileName;

          $Temp =~ s/[\/\\]/_/g;

          log_msg_debug("constructing spool file name prefix: script ".
                        "name without slashes = $Temp");

          # we also want to get rid of script file name extension, so we look 
          # for the last occurrence of '.' and strip off '.' along with 
          # whatever follows it
          my $DotPos = rindex($Temp, '.');

          if ($DotPos > 0) {
            # script name should not start with "." (if it does, I will let it 
            # be, I guess)
            $Temp = substr($Temp, 0, $DotPos);

            log_msg_debug <<msg
constructing spool file name prefix: 
    after stripping off script file name extension, script name = $Temp
msg
          } else {
            log_msg_debug("constructing spool file name prefix: script ".
                          "file name contained no extension");
          }

          push @SpoolFileNames, $SpoolFileNamePrefix.$Temp.'_';

          log_msg_debug <<msg;
constructing spool file name prefix: 
    added $SpoolFileNames[$#SpoolFileNames] to the list
msg
        }

        if ($catcon_RegularArgDelim || $catcon_SecretArgDelim) {
          # remember that script name may be followed by argument(s)
          $LookForArgs = 1;

          log_msg_debug("prepare to handle arguments");
        }
      } elsif (   ($RegularScriptArg = 
                     (   $catcon_RegularArgDelim 
                      && $NextItem =~ /^$catcon_RegularArgDelim/))
               || ($SecretScriptArg = 
                     (   $catcon_SecretArgDelim 
                      && $NextItem =~ /^$catcon_SecretArgDelim/))
               || ($EnvScriptArg = ($NextItem =~ /^--e/))) {
        # looks like an argument to a script; make sure we are actually 
        # looking for script arguments
        if (!$LookForArgs) {
          log_msg_error("unexpected script argument ($NextItem) encountered");
          return 1;
        }

        log_msg_debug("processing script argument string ($NextItem)");

        # because of short-circuiting of logical operators, if 
        # $RegularScriptArg got set to TRUE, we will never even try to 
        # determine if this string could also represent a secret argument, so 
        # if code in catconInit2 has determined that a regular argument 
        # delimiter is a prefix of secret argument delimiter, we need to 
        # determine whether this string may also represent a secret argument
        # (and if a regular argument delimiter is NOT a prefix of secret 
        # argument delimiter, reset $SecretScriptArg in case the preceding 
        # item represented a secret argument)
        if ($RegularScriptArg) {
          $SecretScriptArg = 
               ($catcon_ArgToPick == $catcon_PickSecretArg) 
            && ($NextItem =~ /^$catcon_SecretArgDelim/);
        }

        # If this argument could be either (i.e. one of the 
        # argument-introducing strings is a prefix of the other), use 
        # $catcon_ArgToPick to decide how to treat this argument
        # argument stripped off the string marking it as such
        if ($RegularScriptArg && $SecretScriptArg) {

          if ($catcon_ArgToPick == $catcon_PickRegularArg) {
            $SecretScriptArg = undef;  # treat this arg as a regular arg

            log_msg_debug <<msg;
(catcon_ArgToPick = $catcon_ArgToPick, catcon_PickRegularArg = $catcon_PickRegularArg) 
    argument string ($NextItem) could be represent either regular or secret 
    argument - treat as regular
msg
          } else {
            $RegularScriptArg = undef; # treat this arg as a secret arg

            log_msg_debug <<msg;
argument string ($NextItem) could be represent either
    regular or secret argument - treat as secret
msg
          }
        }

        # - if it is a secret argument, prompt the user to enter its value 
        #   and append the value entered by the user to the most recently 
        #   added element of @ScriptPaths
        # - if it is a "regular" argument, append this argument to the most 
        #   recently added element of @ScriptPaths
        # - if it is an "env" argument, obtain value of the specified 
        #   environment variable and append it to the most recently added 
        #   element of @ScriptPaths
        # In all cases, we will strip off the string introducing the 
        # argument and quote the string before adding it to 
        # $ScriptPaths[$#@ScriptPaths] in case it contains embedded blanks.
        # 
        my $Arg;
    
        if ($SecretScriptArg) {
          ($Arg = $NextItem) =~ s/^$catcon_SecretArgDelim//;

          log_msg_debug("prepare to obtain value for secret argument ".
                        "after issuing ($Arg)");

          # get the user to enter value for this argument
          log_msg_info("$Arg: ");

          # do not set ReadMode to noecho if invoked on Windows from a GUI 
          # tool which requires that we do not hide passwords and hidden 
          # parameters
          if (!($catcon_Windows && $catcon_GUI)) {
            ReadMode 'noecho';
          }

          my $ArgVal = ReadLine 0;
          chomp $ArgVal;

          # do not restore ReadMode if invoked on Windows from a GUI tool 
          # which requires that we do not hide passwords and hidden parameters
          if (!($catcon_Windows && $catcon_GUI)) {
            ReadMode 'normal';
          }

          print "\n";

          # quote value entered by the user and append it to 
          # $ScriptPaths[$#ScriptPaths]
          $ScriptPaths[$#ScriptPaths] .= " '" .$ArgVal."'";

          # instead of showing secret parameter value supplied by the user, 
          # we will show the prompt in response to which the value was 
          # supplied
          $ScriptPathsToDisplay[$#ScriptPathsToDisplay] .= " '" .$Arg."'";

          log_msg_debug("added secret argument to script invocation string");
        } elsif ($RegularScriptArg) {
          ($Arg = $NextItem) =~ s/^$catcon_RegularArgDelim//;

          # quote regular argument and append it to 
          # $ScriptPaths[$#ScriptPaths]
          $ScriptPaths[$#ScriptPaths] .= " '" .$Arg."'";

          $ScriptPathsToDisplay[$#ScriptPathsToDisplay] .= " '" .$Arg."'";

          log_msg_debug("added regular argument to script invocation string");
        } else {
          # bug 22181521 - argument whose value is contained in the 
          # specified environment variable

          # name of the environment variable
          my $envVar = substr($NextItem, 3);

          # make sure the env variable was set
          if ((! exists $ENV{$envVar}) || (! defined $ENV{$envVar})) {
            log_msg_error("user parameter environment variable ".
                          $envVar." specified with --e was undefined");
            return 1;
          }

          # quote value of the environment variable specified by the user 
          # and append it to $ScriptPaths[$#ScriptPaths]
          $ScriptPaths[$#ScriptPaths] .= " '" .$ENV{$envVar}."'";

          # instead of showing value of the environment variable, we will 
          # display its name
          $ScriptPathsToDisplay[$#ScriptPathsToDisplay] .= " '\$" .$envVar."'";

          log_msg_debug("added environment argument to script ".
                        "invocation string");
        }

        log_msg_debug("script invocation string constructed so far:\n".
                      "\t$ScriptPathsToDisplay[$#ScriptPathsToDisplay]");
      } else {
        # $NextItem must contain a SQL statement which we will copy into 
        # @ScriptPaths (a bit of misnomer in this case, sorry)

        log_msg_debug("next SQL statement = $NextItem");

        push @ScriptPaths, $NextItem;

        # before pushing a new element onto @ScriptPathsToDisplay, replace 
        # single and double quotes in the previous element (if any) with # 
        # to avoid errors in begin/end_running queries and in 
        # SET ERRORLOGGING ON IDENTIFIER ... statements
        if ($#ScriptPathsToDisplay >= 0) {
          $ScriptPathsToDisplay[$#ScriptPathsToDisplay] =~ s/['"]/#/g;
        }

        # assuming it's ok to display SQL statements; my excuse: SET 
        # ERRORLOGGING already does it for statements which result in errors
        push @ScriptPathsToDisplay, $NextItem;

        # we expect no arguments following a SQL statement
        $LookForArgs = 0;

        log_msg_debug("saw SQL statement - do not expect any arguments");

        if ($catcon_SpoolOn) {
          push @SpoolFileNames, "";

          log_msg_debug("saw SQL statement - added empty spool file ".
                        "name prefix to the list");
        }
      }
    }
    
    # replace single and double quotes in the last element of 
    # @ScriptPathsToDisplay with # to avoid errors in begin/end_running 
    # queries and in SET ERRORLOGGING ON IDENTIFIER ... statements
    $ScriptPathsToDisplay[$#ScriptPathsToDisplay] =~ s/['"]/#/g;

    log_msg_verbose("finished examining scripts/SQL statements to be ".
                    "executed.");

    # if running against a non-Consolidated Database
    #   - each script/statement will be run exactly once; 
    # else 
    #   - if the caller instructed us to run only in the Root, temporarily 
    #     overriding the list of Containers specified when calling catconInit2,
    #     or if the Root is among the list of Containers against which we are 
    #     to run
    #     - each script/statement will be run against the Root
    #   - then, if running against one or more PDBs
    #     - each script/statement will be run against all such PDBs in parallel

    # offset into the array of process file handles
    my $CurProc = 0;

    # compute number of processes which will be used to run script/statements 
    # specified by the caller; used to determine when all processes finished 
    # their work
    my $ProcsUsed;

    # if the caller requested that we generate spool files for output 
    # produced by running supplied scripts, an array of spool file name 
    # prefixes has already been constructed.  All that's left is to determine 
    # the suffix:
    #   - if running against a non-Consolidated DB, suffix will be an empty 
    #     string
    #   - otherwise, it needs to be set to the name of the Container against 
    #     which script(s) will be run
    my $SpoolFileNameSuffix;

    # initialize array used to keep track of whether we need to send 
    # initialization statements to a process used for the first time during 
    # this invocation of catcon
    if (   $IssuePerProcStmts 
        && $catcon_PerProcInitStmts && $#$catcon_PerProcInitStmts >= 0) {
      @NeedInitStmts = (1) x $catcon_NumProcesses;
    }
        
    # if ERORLOGGING is enabled, this will be used to store IDENTIFIER
    my $ErrLoggingIdent;

    # normally this will be set to @catcon_Containers, but if the caller
    # specified names of Containers in which to run or not to run scripts 
    # and/or statements during this invocation of catconExec, it will get 
    # modified to reflect this
    my @Containers;

    @Containers = @catcon_Containers;
    if ($$ConNamesIncl || $$ConNamesExcl) {
      if ($$ConNamesExcl) {
        if (!(@Containers = 
                validate_con_names($$ConNamesExcl, 1, @catcon_AllContainers, 
                    $catcon_AllPdbMode == CATCON_PDB_MODE_UNCHANGED
                      ? \%catcon_IsConOpen : undef, 
                    $catcon_IgnoreInaccessiblePDBs,
                    $catcon_IgnoreAllInaccessiblePDBs))) {
          log_msg_error("Unexpected error returned by validate_con_names");
          return 1;
        }
      } else {
        if (!(@Containers = 
                validate_con_names($$ConNamesIncl, 0, @catcon_AllContainers, 
                    $catcon_AllPdbMode == CATCON_PDB_MODE_UNCHANGED
                      ? \%catcon_IsConOpen : undef, 
                    $catcon_IgnoreInaccessiblePDBs,
                    $catcon_IgnoreAllInaccessiblePDBs))) {
          log_msg_error("Unexpected error returned by validate_con_names");
          return 1;
        } 
      }

      log_msg_debug("During this invocation ONLY, run only ".
                    "against the following Containers {");
      foreach (@Containers) {
        log_msg_debug("\t$_");
      }
      log_msg_debug("}");
    }

    # if connected to a CDB, save name of a CDB Root or, if told to run 
    # scripts in a Federation Root and all Federation PDBs that belong to it,
    # of the Federation Root
    my $CDBorFedRoot;

    if (@Containers) {
      $CDBorFedRoot = ($catcon_FedRoot) ? $catcon_FedRoot : $catcon_Root;
    }

    # skip the portion of the code that deals with running all scripts in the 
    # Root, Federation Root or in a non-CDB if we need to run it in one or 
    # more PDBs but not in the Root or in explicitly specified Federation Root
    if (   @Containers && !$RootOnly 
        && ($Containers[0] ne $CDBorFedRoot)) {
      log_msg_debug("skipping single-Container portion of catconExec");

      goto skipSingleContainerRun;
    }

    if ($SingleThreaded) {
      # use 1 process to run all script(s) against a non-Consolidated DB or in 
      # the Root or the specified Container of a Consolidated DB
      $ProcsUsed = 1;
    } else {
      # each script may be run against a non-Consolidated DB or in the Root or
      # the specified Container of a Consolidated DB using a separate process
      $ProcsUsed = (@ScriptPaths > $catcon_NumProcesses) 
        ? $catcon_NumProcesses : @ScriptPaths;
    }

    # if running against a CDB, we need to connect to the Root in every 
    # process, UNLESS we were called to invoke a script in a Federation Root 
    # and all of its Federation PDBs, in which case we need to connect to the 
    # Federation Root
    #
    # bug 25507396: if $catcon_EZconnToPdb is set, we don't want 
    #   to switch into $CDBorFedRoot
    if (@Containers) {
      for ($CurProc = 0; $CurProc < $ProcsUsed; $CurProc++) {
        if (((index($ScriptPathsToDisplay[0], "catupgrd") == -1) &&
             (index($ScriptPathsToDisplay[0], "catshutdown") == -1)) && 
            !$catcon_EZconnToPdb)
        {
          printToSqlplus("catconExec", $catcon_FileHandles[$CurProc], 
                         qq#ALTER SESSION SET CONTAINER = "$CDBorFedRoot"#, 
                         "\n/\n", $catcon_LogLevel == &CATCON_LOG_LEVEL_DEBUG);

          print {$catcon_FileHandles[$CurProc]} $CurrentContainerQuery;
          $catcon_FileHandles[$CurProc]->flush;
          $bInitStmts = 1;
        }

        if ($catcon_EZconnToPdb) {
          log_msg_debug("process $CurProc (id = ".
                        "$catcon_ProcIds[$CurProc]) connected to ".
                        "Container $catcon_EZconnToPdb");
        } elsif ($catcon_FedRoot) {
          log_msg_debug("process $CurProc (id = ".
                        "$catcon_ProcIds[$CurProc]) connected to App Root ".
                        "Container $catcon_FedRoot");
        } else {
          log_msg_debug("process $CurProc (id = ".
                        "$catcon_ProcIds[$CurProc]) connected to Root ".
                        "Container $catcon_Root");
        }
      }
    }

    # run all scripts in 
    # - a non-Consolidated DB or
    # - the Root of a Consolidated DB, if caller specified that they be run 
    #   only in the Root OR if Root is among multiple Containers where scripts 
    #   need to be run or
    # - in Federation Root if the user asked us to run in Federation Root 
    #   and all Federation PDBs belonging to it

    if (!@Containers) {
      log_msg_verbose("will run all scripts/statements against a non-CDB");

      if ($catcon_SpoolOn) {
        $SpoolFileNameSuffix = "";
        log_msg_debug("non-CDB - set SpoolFileNameSuffix to empty string");
      }
    } else {
      # it must be the case that 
      #         $RootOnly 
      #      || ($Containers[0] eq $CDBorFedRoot)
      # for otherwise we would have jumped to skipSingleContainerRun above

      if ($catcon_FedRoot) {
        log_msg_verbose("will run all scripts/statements against App ".
                        "Root $catcon_FedRoot");
      } else {
        log_msg_verbose("will run all scripts/statements against the ".
                        "Root (Container $catcon_Root) of a CDB");
      }

      if ($catcon_SpoolOn) {
        # set spool file name suffix to the name of the Container in which 
        # we will be running
        $SpoolFileNameSuffix = getSpoolFileNameSuffix($CDBorFedRoot);

        log_msg_debug("CDB - set SpoolFileNameSuffix to ".
                      "$SpoolFileNameSuffix");
      }
    }
    
    if ($catcon_ErrLogging) {
      # do not mess with $ErrLoggingIdent if $$CustomErrLoggingIdent is set 
      # since once the user provides a value for the Errorlogging Identifier, 
      # he is fully in charge of its value
      # 
      # Truth table describing how we determine whether to set the 
      # ERRORLOGGING Identifier, and if so, whether to use a default 
      # identifier or a custom identifier
      # N\C 0   1
      #   \--------
      #  0| d | c |
      #   ---------
      #  1| - | c |
      #   ---------
      #
      # N = is $catcon_NoErrLogIdent set?
      # C = is $$CustomErrLoggingIdent defined?
      # d = use default ERRORLOGGING Identifier
      # c = use custom ERRORLOGGING Identifier
      # - = do not set ERRORLOGGING Identifier
      #
      # NOTE: it's important that we we assign $$CustomErrLoggingIdent to 
      #       $ErrLoggingIdent and test the result BEFORE we test 
      #       $catcon_NoErrLogIdent because  if $$CustomErrLoggingIdent is 
      #       $defined, we will ignore catcon_NoErrLogIdent, so it's necessary 
      #       that $ErrLoggingIdent gets set to $$CustomErrLoggingIdent 
      #       regardless of whether $catcon_NoErrLogIdent is set
      if (!($ErrLoggingIdent = $$CustomErrLoggingIdent) && 
          !$catcon_NoErrLogIdent) {
        if (!@Containers) {
          $ErrLoggingIdent = "";
        } else {
          $ErrLoggingIdent = $CDBorFedRoot."::";
        }
      }

      # replace single and double quotes in $ErrLoggingIdent with # to avoid 
      # confusion
      if ($ErrLoggingIdent && $ErrLoggingIdent ne "") {
        $ErrLoggingIdent =~ s/['"]/#/g;
      }

      log_msg_debug("ErrLoggingIdent prefix ".
                    ((defined $ErrLoggingIdent) ? "= $ErrLoggingIdent" 
                                                : "undefined"));
    }

    # $CurProc == -1 (any number < 0 would do, really, since such numbers 
    # could not be used to refer to a process) will indicate that we are yet 
    # to obtain a number of a process to which to send the first script (so we 
    # need to call pickNextProc() even if running single-threaded; once 
    # $CurProc >= 0, if running single-threaded, we will not be trying to 
    # obtain a new process number)
    $CurProc = -1; 

    # index into @ScriptPathsToDisplay array which will be kept in sync with 
    # the current element of @ScriptPaths
    # this index will also be used to access elements of @SpoolFileNames in 
    # sync with elements of the list of scripts and SQL statements to be 
    # executed
    my $ScriptPathDispIdx = -1;


    # check to see if the scripts should be run 
    if ($$skipProcQuery) {
        my @result = catconQuery($$skipProcQuery);
        if ($result[0] eq "") {
        	return 0;   # do not run any of the scripts
        }
    }

    # was the previous script that we ran catshutdown (meaning that the DB 
    # may be down before the current script finishes so we need to be careful 
    # about issuing statements that need to run in sqlplus)
    my $prevCatShutdown = 0;
  
    # Bug 25404458: key used to access %catcon_CatShutdown entry corresponding 
    #   to the Container being processed (CDB$ROOT or name of the App Root, if 
    #   operating on a CDB or non-CDB if operating on one)
    my $rootOrNonCdb = (defined $CDBorFedRoot) ? $CDBorFedRoot : "non-CDB";

    # processing catupgrd?
    my $currCatUpgrd = 0;
    
    foreach my $FilePath (@ScriptPaths) {
      # remember if the last script ran was catshutdown
      $prevCatShutdown = $catcon_CatShutdown{$rootOrNonCdb};

      # remember if the current script is catshutdown or catupgrd
      if (index($FilePath, "catshutdown") != -1) {
        $catcon_CatShutdown{$rootOrNonCdb} = 1;
        $currCatUpgrd = 0;
      } elsif (index($FilePath, "catupgrd") != -1) {
        $currCatUpgrd = 1;
        $catcon_CatShutdown{$rootOrNonCdb} = 0;
      } else {
        $currCatUpgrd = $catcon_CatShutdown{$rootOrNonCdb} = 0;
      }

      if (!$SingleThreaded || $CurProc < 0) {
        # find next available process
        $CurProc = pickNextProc($ProcsUsed, $catcon_NumProcesses, $CurProc + 1,
                                $catcon_LogFilePathBase, \@catcon_ProcIds, 
                                $catcon_RecoverFromChildDeath, 
                                @catcon_InternalConnectString, 
                                $catcon_KillAllSessScript,
                                $catcon_DoneCmd, $catcon_Sqlplus);

        if ($CurProc < 0) {
          # some unexpected error was encountered
          log_msg_error("unexpected error in pickNextProc");
          return 1;
        }

        # remember that this process will be involved in running at least one 
        # script or query
        if (! exists $catcon_ActiveProcesses[$CurProc]) {
          log_msg_debug <<msg;
Process $CurProc will be involved in executing at least one statement 
    or script, so its log will be preserved
msg
          $catcon_ActiveProcesses[$CurProc] = 1;
        }

        # if this is the first time we are using this process and 
        # the caller indicated that one or more statements need to be executed 
        # before using a process for the first time, issue these statements now
        if ($#NeedInitStmts >= 0 && $NeedInitStmts[$CurProc]) {
          firstProcUseStmts($ErrLoggingIdent, $$CustomErrLoggingIdent,
                            $catcon_ErrLogging, 
                            \@catcon_FileHandles, $CurProc, 
                            $catcon_PerProcInitStmts, \@NeedInitStmts, 
                            (!$catcon_UserScript && !$catcon_NoOracleScript), 
                            $catcon_FedRoot, 
                            $catcon_LogLevel == &CATCON_LOG_LEVEL_DEBUG);
        }
      }

      # element of @ScriptPathsToDisplay which corresponds to $FilePath
      my $FilePathToDisplay = $ScriptPathsToDisplay[++$ScriptPathDispIdx];

      if (!$currCatUpgrd)
      {
        # run additional init statements (set tab on, set _oracle_script, etc.)
        additionalInitStmts(\@catcon_FileHandles, $CurProc,
                            0, 0,
                            $catcon_ProcIds[$CurProc], $catcon_EchoOn,
                            $catcon_LogLevel == &CATCON_LOG_LEVEL_DEBUG, 
                            (!$catcon_UserScript && !$catcon_NoOracleScript), 
                            $catcon_FedRoot);

        if ($catcon_FedRoot) {
          print {$catcon_FileHandles[$CurProc]} qq#select '==== CATCON EXEC FEDERATION ROOT $catcon_FedRoot ====' AS catconsection from dual\n/\n#;
        } else {
          print {$catcon_FileHandles[$CurProc]} qq#select '==== CATCON EXEC ROOT ====' AS catconsection from dual\n/\n#;
        }

        # bracket script or statement with strings intended to make it easier 
        # to determine origin of output in the log file

        print {$catcon_FileHandles[$CurProc]} qq#select '==== $FilePathToDisplay' || ' Container:' || SYS_CONTEXT('USERENV','CON_NAME') || ' Id:' || SYS_CONTEXT('USERENV','CON_ID') || ' ' || TO_CHAR(SYSTIMESTAMP,'YY-MM-DD HH:MI:SS') || ' Proc:$CurProc ====' AS begin_running from sys.dual;\n/\n#;

      }

      if ($catcon_ErrLogging) {
        # construct and issue SET ERRORLOGGING ON [TABLE...] statement

        if ($bInitStmts)
        {
          err_logging_tbl_stmt($catcon_ErrLogging, \@catcon_FileHandles, 
                               $CurProc, 
                               (!$catcon_UserScript && 
                                  !$catcon_NoOracleScript), $catcon_FedRoot,
                               $catcon_LogLevel == &CATCON_LOG_LEVEL_DEBUG);
        }

        if ($ErrLoggingIdent) {
          # send SET ERRORLOGGING ON IDENTIFIER ... statement

          my $Stmt;

          if ($$CustomErrLoggingIdent) {
            # NOTE: if the caller of catconExec() has supplied a custom 
            #       Errorlogging Identifier, it has already been copied into 
            #       $ErrLoggingIdent which was then normalized, so our use of 
            #       $ErrLoggingIdent rather than $CustomErrLoggingIdent below 
            #       is intentional
            $Stmt = "SET ERRORLOGGING ON IDENTIFIER '".substr($ErrLoggingIdent, 0, 256)."'";
          } else { 
            $Stmt = "SET ERRORLOGGING ON IDENTIFIER '".substr($ErrLoggingIdent.$FilePathToDisplay, 0, 256)."'";
          }

          log_msg_verbose("sending $Stmt to process $CurProc");

          printToSqlplus("catconExec", $catcon_FileHandles[$CurProc], 
                 $Stmt, "\n", $catcon_LogLevel == &CATCON_LOG_LEVEL_DEBUG);
        }
      }

      # statement to start/end spooling output of a SQL*Plus script
      my $SpoolStmt;

      # if the caller requested that we generate a spool file and we are about 
      # to execute a script, issue SPOOL ... REPLACE
      if ($catcon_SpoolOn && $SpoolFileNames[$ScriptPathDispIdx] ne "") {
        $SpoolStmt = "SPOOL '" . $SpoolFileNames[$ScriptPathDispIdx] . 
                     $SpoolFileNameSuffix . "' REPLACE";

        log_msg_debug("sending $SpoolStmt to process $CurProc");

        printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                 $SpoolStmt, "\n", $catcon_LogLevel == &CATCON_LOG_LEVEL_DEBUG);

        # remember that after we execute the script, we need to turn off 
        # spooling
        $SpoolStmt = "SPOOL OFF \n";
      }

      # value which will be used with ALTER SESSION SET APPLICATION ACTION
      my $AppInfoAction;

      my $LastSlash; # position of last / or \ in the script name
      
      if ($FilePath !~ /^@/) {
        $AppInfoAction = $FilePath;
      } elsif (($LastSlash = rindex($FilePath, '/')) >= 0 ||
               ($LastSlash = rindex($FilePath, '\\')) >= 0) {
        $AppInfoAction = substr($FilePath, $LastSlash + 1);
      } else {
        # FilePath contains neither backward nor forward slashes, so use it 
        # as is
        $AppInfoAction = $FilePath;
      }

      # $AppInfoAction may include parameters passed to the script. 
      # These parameters will be surrounded with single quotes, which will 
      # cause a problem since $AppInfoAction is used to construct a 
      # string parameter used with ALTER SESSION SET APPLICATION ACTION.
      # To prevent this from happening, we will replace single quotes found
      #in $AppInfoAction with #
      $AppInfoAction =~ s/[']/#/g;

      # Bug 25696936: if the next item to be executed is a statement, it 
      # may contain \n chars which will be replaced with a single space
      $AppInfoAction =~ s/\n/ /g;

      if (!@Containers) {
        $AppInfoAction = "non-CDB::".$AppInfoAction;
      } else {
        $AppInfoAction = $CDBorFedRoot."::".$AppInfoAction;
      }

      # use ALTER SESSION SET APPLICATION MODULE/ACTION to identify process, 
      # Container, if any, and script or statement being run

      if (!$currCatUpgrd && !$catcon_CatShutdown{$rootOrNonCdb}) {
        printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                       qq#ALTER SESSION SET APPLICATION MODULE = 'catcon(pid=$PID)'#,
                       "\n/\n", $catcon_LogLevel == &CATCON_LOG_LEVEL_DEBUG);
      }

      log_msg_debug("issued ALTER SESSION SET APPLICATION MODULE = ".
                    "'catcon(pid=$PID)'");

      if (!$currCatUpgrd && !$catcon_CatShutdown{$rootOrNonCdb}) {
        printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                       "ALTER SESSION SET APPLICATION ACTION = '$AppInfoAction'",
                       "\n/\n", $catcon_LogLevel == &CATCON_LOG_LEVEL_DEBUG);
      }

      log_msg_debug("issued ALTER SESSION SET APPLICATION ACTION = ".
                    "'$AppInfoAction'");

      # execute next script or SQL statement
      log_script_execution($FilePathToDisplay, 
                           $CDBorFedRoot ? $CDBorFedRoot : undef, 
                           $CurProc);

      # if catcon_LogLevel is set to DEBUG, printToSqlplus will normally issue 
      #   select "catconExec() ... as catcon_statement from dual"
      # which we need to avoid if we just finished running  catshutdown
      printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                     $FilePath, "\n", 
                     $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);

      # if executing a statement, follow the statement with "/"
      if ($FilePath !~ /^@/) {
        print {$catcon_FileHandles[$CurProc]} "/\n";
      }

      # if we started spooling before running the script, turn it off after 
      # it is done
      if ($SpoolStmt) {
        log_msg_debug("sending $SpoolStmt to process $CurProc");

        printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                       $SpoolStmt, "", 
                       $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
      }

      if (!$catcon_CatShutdown{$rootOrNonCdb})
      {
        print {$catcon_FileHandles[$CurProc]} qq#select '==== $FilePathToDisplay' || ' Container:' || SYS_CONTEXT('USERENV','CON_NAME') || ' Id:' || SYS_CONTEXT('USERENV','CON_ID') || ' ' || TO_CHAR(SYSTIMESTAMP,'YY-MM-DD HH:MI:SS') || ' Proc:$CurProc ====' AS end_running from sys.dual;\n/\n#;

      }

      if ($FilePath =~ /^@/ && $catcon_UncommittedXactCheck) {
        # if asked to check whether a script has ended with uncommitted 
        # transaction, do so now
        printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
               qq#SELECT decode(COUNT(*), 0, 'OK', 'Script ended with uncommitted transaction') AS uncommitted_transaction_check FROM v\$transaction t, v\$session s, v\$mystat m WHERE t.ses_addr = s.saddr AND s.sid = m.sid AND ROWNUM = 1#, 
               "\n/\n", $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
      }

      # unless we are running single-threaded, we need a "done" file to be 
      # created after the current script or statement completes so that 
      # next_proc() would recognize that this process is available and 
      # consider it when picking the next process to run a script or SQL 
      # statement
      if (!$SingleThreaded) {
        # file which will indicate that process $CurProc finished its work and 
        # is ready for more
        #
        # Bug 18011217: append _catcon_$catcon_ProcIds[$CurProc] to 
        # $catcon_LogFilePathBase to avoid conflicts with other catcon 
        # processes running on the same host
        my $DoneFile = 
          done_file_name($catcon_LogFilePathBase, $catcon_ProcIds[$CurProc]);

        # if catcon_LogLevel is set to DEBUG, printToSqlplus will normally 
        # issue 
        #   select "catconExec() ... as catcon_statement from dual"
        # which we need to avoid if we are running catshutdown
        printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                       qq/$catcon_DoneCmd $DoneFile/, "\n", 
                       $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
      
        log_msg_debug <<msg;
sent "$catcon_DoneCmd $DoneFile" to process 
    $CurProc (id = $catcon_ProcIds[$CurProc]) to indicate its availability 
    after completing $FilePath
msg
      }

      $catcon_FileHandles[$CurProc]->flush;
    }

    # if we are running single-threaded, we need a "done" file to be 
    # created after the last script or statement sent to the current Container 
    # completes so that next_proc() would recognize that this process is 
    # available and consider it when picking the next process to run a script 
    # or SQL statement
    if ($SingleThreaded) {
      # file which will indicate that process $CurProc finished its work and 
      # is ready for more
      #
      # Bug 18011217: append _catcon_$catcon_ProcIds[$CurProc] to 
      # $catcon_LogFilePathBase to avoid conflicts with other catcon 
      # processes running on the same host
      my $DoneFile = 
        done_file_name($catcon_LogFilePathBase, $catcon_ProcIds[$CurProc]);

      # if catcon_LogLevel is set to DEBUG, printToSqlplus will normally issue 
      #   "select 'catconExec() ... as catcon_statement from dual"
      # which we need to avoid if the last script we ran was catshutdown
      printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                     qq/$catcon_DoneCmd $DoneFile/, "\n", 
                     $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);

      # flush the file so a subsequent test for file existence does 
      # not fail due to buffering
      $catcon_FileHandles[$CurProc]->flush;
      
      log_msg_debug <<msg;
sent "$catcon_DoneCmd $DoneFile" to process 
    $CurProc (id = $catcon_ProcIds[$CurProc]) to indicate its availability
msg
    }
  
    # if 
    #   - there are no additional Containers in which we need to run scripts 
    #     and/or SQL statements and 
    #   - the user told us to issue per-process init and completion statements 
    #     and 
    #   - there are such statements to send, 
    # they need to be passed to wait_for_completion
    my $EndStmts;

    if (   ($RootOnly || !(@Containers && $#Containers > 0))
           && $IssuePerProcStmts) {
      $EndStmts = $catcon_PerProcEndStmts;
    } else {
      $EndStmts = undef;
    }

    # wait_for_completion uses calls printToSqlplus to send "done" command to 
    # processes and if catcon_LogLevel is set to DEBUG, printToSqlplus will 
    # normally issue 
    #   "select 'catconExec() ... as catcon_statement from dual"
    # which we need to avoid if the last script we ran was catshutdown
    #
    # bug 25507396: if $catcon_EZconnToPdb is set, we don't want 
    #   wait_for_completion to switch into Root
    if (wait_for_completion($ProcsUsed, $catcon_NumProcesses, 
          $catcon_LogFilePathBase, 
          @catcon_FileHandles, @catcon_ProcIds,
          $catcon_DoneCmd, @$EndStmts, 
          ($CDBorFedRoot && !$catcon_EZconnToPdb) ? $CDBorFedRoot : undef,
          @catcon_InternalConnectString,
          $catcon_RecoverFromChildDeath,
          $catcon_KillAllSessScript, 
          index($ScriptPaths[$#ScriptPaths], "catshutdown") != -1,
          $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG,
          $catcon_Sqlplus) == 1) {
      # unexpected error was encountered, return
      log_msg_error("unexpected error in wait_for_completion");

      return 1;
    }

    # will jump to this label if scripts/stataments need to be run against one
    # or more PDBs, but not against Root or Federation Root
skipSingleContainerRun:

    # if 
    # - running against a Consolidated DB and 
    # - caller has not instructed us to run ONLY in the Root, 
    # - the list of Containers against which we need to run includes at 
    #   least one PDB (which can be establsihed by verifying that either 
    #   @Containers contains more than one element or the first
    #   element is not CDB$ROOT or the explicitly specified Federation Root 
    #   ($CDBorFedRoot would be set to $catcon_Root unless $catcon_FedRoot was 
    #   set, so comparing first element to $CDBorFedRoot with cover both cases)
    # run all scripts/statements against all remaining Containers (i.e. PDBs, 
    # since we already took care of the Root or Federation Root, unless the 
    # user instructed us to skip it)    
    if (   @Containers 
        && !$RootOnly 
        && (   $#Containers > 0 
            || ($Containers[0] ne $CDBorFedRoot)))
    {
      # A user may have excluded the Root (and possibly some other PDBs, but 
      # the important part is the Root) from the list of Containers against 
      # which to run scripts, in which case $Containers[0] would 
      # contain name of a PDB, and we would have skipped the single-container 
      # part of this subroutine.  
      #
      # It is important that we keep it in mind when deciding across how many 
      # Containers we need to run and whether to skip the Container whose 
      # name is stored in $Containers[0].

      # offset into @Containers of the first PDB name
      my $firstPDB = ($Containers[0] eq $CDBorFedRoot) ? 1 : 0;

      # number of PDB names in @Containers
      my $numPDBs = $#Containers + 1 - $firstPDB;

      # offset into @Containers of the first user (i.e. not PDB$SEED) PDB name;
      # subsequent code may test for equality of $firstPDB and $firstUserPDB to
      # determine if @Containers has PDB$SEED as it's first PDB name
      my $firstUserPDB = 
        ($Containers[$firstPDB] eq q/PDB$SEED/) ? $firstPDB + 1 : $firstPDB;
      
      log_msg_verbose("run all scripts/statements against remaining ".
                      "$numPDBs PDBs");

      # compute number of processes which will be used to run 
      # script/statements specified by the caller in all remaining PDBs; 
      # used to determine when all processes finished their work
      $ProcsUsed = 
        compute_procs_used_for_pdbs($SingleThreaded, $numPDBs, 
                                    $catcon_NumProcesses, $#ScriptPaths+1);

      # one of the PDBs against which we will run scripts/SQL statements may be
      # PDB$SEED; before we attempt to run any statements against it,
      # we need to make sure it is open in the mode specified by the caller via
      # catconInit2.SeedMode parameter.  
      #
      # Since PDB$SEED has con_id of 2, it will be the first PDB in the list.
      #
      # NOTE: as a part of fix for bug 13072385, I moved code to revert 
      #       PDB$SEED mode back to its original mode into catconWrapUp(), 
      #       but I am leaving code that changes its mode here in 
      #       catconExec() (rather than moving it into catconInit2()) because 
      #       the caller may request that scripts/statements be run against 
      #       PDB$SEED even if it was not one of the Containers specified 
      #       when calling catconInit2().  Because of that possibility, I have 
      #       to keep this code here, so I see no benefit from also adding it 
      #       to catconInit2().

      if ($firstPDB < $firstUserPDB) {
        if ($catcon_SeedPdbMode != CATCON_PDB_MODE_UNCHANGED) {
          log_msg_debug("invoke force_pdb_modes to reopen ".
                        "(if necessary) PDB\$SEED in ".
                        PDB_MODE_CONST_TO_STRING->{$catcon_SeedPdbMode}.
                        " mode");

          # Bug 26527096: we are passing undef's in place of a references for 
          #   %catcon_AppRootCloneInfo and %catcon_AppPdbInfo because PDB$SEED 
          #   cannot be an App Root Clone or an App PDB so nothing will be 
          #   gained by trying to look it up in either
          my ($ret, $instPdbHash_ref) = 
            force_pdb_modes(@Containers, $firstPDB, $firstPDB, undef, undef,
                            $catcon_SeedPdbMode, \%catcon_RevertSeedPdbMode, 
                            $catcon_ProcIds[0]."_seed_pdb", 
                            $catcon_LogFilePathBase, 
                            @catcon_InternalConnectString, 
                            $catcon_DoneCmd, 1, 
                            %catcon_PdbsOpenInReqMode, 
                            %catcon_IsConOpen, $catcon_DbmsVersion,
                            $firstUserPDB <= $#Containers,
                            \%catcon_InstProcMap, \%catcon_InstConnStr,
                            $catcon_DfltInstName, $catcon_Sqlplus);
          log_msg_debug("force_pdb_modes returned");

          if ($ret == 1) {
            log_msg_error("unexpected error in force_pdb_modes when ".
                          "trying to reopen PDB\$SEED");
            return 1;
          } elsif ($ret == 0 && $instPdbHash_ref) {
            if (%$instPdbHash_ref) {
              if ((scalar keys %$instPdbHash_ref) > 1) {
                # save references to the hash mapping instance names to PDBs 
                # open on those instances
                log_msg_debug <<msg;
PDBs may be open on multiple instances - saving instance->pdb mapping in 
    \$catcon_ForcePdbModeInstPdbMap
msg

                $catcon_ForcePdbModeInstPdbMap = $instPdbHash_ref;
              } else {
                log_msg_debug <<msg;
PDBs may be open on only 1 instance - leave \$catcon_ForcePdbModeInstPdbMap
    uninitialized
msg
              }

              log_msg_debug("PDB\$SEED was opened in ".
                            PDB_MODE_CONST_TO_STRING->{$catcon_SeedPdbMode}.
                            " mode");
            } else {
              # NOTE: If 
              #       - we are going to use all available instances, and 
              #       - force_pdb_modes discovered that the CDB is open on more
              #         than one instance, and 
              #       - we told force_pdb_modes that there are PDBs besides 
              #         PDB$SEED that will need to be processed, 
              #       it closed PDB$SEED but did not reopen it (and 
              #       communicated this to us by undefining %$instPdbHash_ref),
              #       in which case it will fall upon the invocation of 
              #       force_pdb_modes that will handle user PDBs (below) to 
              #       open PDB$SEED
              log_msg_debug("PDB\$SEED was left closed and will be ".
                            "opened in ".
                            PDB_MODE_CONST_TO_STRING->{$catcon_SeedPdbMode}.
                            " mode together with user PDBs");
            }
          } elsif ($ret == -1) {
            log_msg_debug("PDB\$SEED has been previously opened in ".
                          PDB_MODE_CONST_TO_STRING->{$catcon_SeedPdbMode}.
                          " mode");
          }
        } else {
          log_msg_debug("PDB\$SEED mode will be left unchanged, per ".
                        "user directive");
        }
      }

      # do the same for any user PDBs that will be operated upon
      if ($firstUserPDB <= $#Containers) {
        if ($catcon_AllPdbMode != CATCON_PDB_MODE_UNCHANGED) {
          log_msg_debug("invoke force_pdb_modes to reopen ".
                        "(if necessary) user PDBs in ".
                        PDB_MODE_CONST_TO_STRING->{$catcon_AllPdbMode}.
                        " mode");

          # NOTE: 
          #       We are instructing force_pdb_modes to NOT set _ORACLE_SCRIPT 
          #       before changing mode in which specified PDBs are open ONLY IF
          #       catcon was invoked to execute non-Oracle scripts (in 
          #       which case the caller would not be able to specify that 
          #       scripts be run in any of the PDBs changing mode of which 
          #       requires that _ORACLE_SCRIPT be set + it is possible that 
          #       the user under whose auspicies ALTER PDB statements will be 
          #       issued may not have privileges required to set 
          #       _ORACLE_SCRIPT.) 
          #
          #       Otherwise, even though we are calling force_pdb_modes to only
          #       verify that user PDBs are open in required mode, if we were 
          #       instructed to use all available instances, it may end up 
          #       closing and reopening PDB$SEED (currently the only PDB 
          #       changing mode of which requires that _ORACLE_SCRIPT be set)
          my ($ret, $instPdbHash_ref) = 
            force_pdb_modes(@Containers, $firstUserPDB, $#Containers, 
                            \%catcon_AppRootCloneInfo, \%catcon_AppPdbInfo,
                            $catcon_AllPdbMode, \%catcon_RevertUserPdbModes, 
                            $catcon_ProcIds[0]."_user_pdbs", 
                            $catcon_LogFilePathBase, 
                            @catcon_InternalConnectString, 
                            $catcon_DoneCmd, !$catcon_UserScript, 
                            %catcon_PdbsOpenInReqMode, 
                            %catcon_IsConOpen, $catcon_DbmsVersion, 0,
                            \%catcon_InstProcMap, \%catcon_InstConnStr,
                            $catcon_DfltInstName, $catcon_Sqlplus);

          log_msg_debug("force_pdb_modes returned");

          if ($ret == 1) {
            log_msg_error("unexpected error in force_pdb_modes when ".
                          "trying to reopen user PDBs");
            return 1;
          } elsif ($ret == 0 && $instPdbHash_ref) {
            if ((scalar keys %$instPdbHash_ref) > 1) {
              # save reference to the hash mapping instance names to PDBs 
              # open on those instances
              log_msg_debug <<msg;
PDBs may be open on multiple instances - saving instance->pdb mapping in 
    \$catcon_ForcePdbModeInstPdbMap
msg

              $catcon_ForcePdbModeInstPdbMap = $instPdbHash_ref;
            } else {
              log_msg_debug <<msg;
PDBs may be open on only 1 instance - leave \$catcon_ForcePdbModeInstPdbMap
    uninitialized
msg
            }

            log_msg_debug("user PDBs were opened in ".
                          PDB_MODE_CONST_TO_STRING->{$catcon_AllPdbMode}.
                          " mode");
          } elsif ($ret == -1) {
            log_msg_debug("user PDBs have been previously opened in ".
                          PDB_MODE_CONST_TO_STRING->{$catcon_SeedPdbMode}.
                          " mode");
          }
        } else {
          log_msg_debug("user PDB(s) mode will be left unchanged, per ".
                        "user directive");
        }
      }

      # Bug 20193612: if the caller requested that we utilize all available 
      # instances and $catcon_ForcePdbModeInstPdbMap is set (indicating that 
      # the PDBs on which we will be working can be open on more than 1 
      # instance), we will fork one process per instance, passing to each 
      # names of PDBs open on that instance and ids of processes which were 
      # allocated to that instance (based on value of cpu_count obtained 
      # from that instance)
      
      if ($catcon_AllInst && $catcon_ForcePdbModeInstPdbMap) {
        # this hash will be used to store contents of a hash describing 
        # PDBs and instances on which they are open and where they should be 
        # processed
        my %instPdbMap = %$catcon_ForcePdbModeInstPdbMap;

        inst_pdbs_hash_dump(\%instPdbMap, "catconExec_int", "instPdbMap");

        # %instPdbMap may contain references to PDBs which were not specified 
        # during current invocation of catconExec (e.g. if catconExec were 
        # invoked to run some scripts in PDB$SEED and then invoked again to 
        # run scripts in PDB1, %instPdbMap will map some instance to PDB$SEED 
        # and another instance to PDB1.)  
        # 
        # We want %$catcon_ForcePdbModeInstPdbMap to contain this information 
        # in case catconExec is invoked again to run script(s) on a subset of 
        # PDBs which have been distributed among available instances, but we 
        # definitely need to avoid running scripts specified during this 
        # invocation of catconExec against PDBs which were NOT specified
        # during this invocation of catconExec.
        {
          # will be used to remember whether some PDBs referenced in 
          # %instPdbMap has to be purged from it
          my $somePdbsPurged = 0;

          log_msg_debug <<msg;
Purge \%instPdbMap of references (if any) to PDBs which were not specified 
    during the current invocation of catconExec
msg
          # hash representing names of all Containers specified (or implied) 
          # during this invocation of catconExec
          my %conNames = map { $_ => undef } @Containers;

          # traverse %instPdbMap, removing references to PDBs not specified 
          # during this invocation of catconExec
          foreach my $inst (sort keys %instPdbMap) {
            if (@{$instPdbMap{$inst}}) {
              log_msg_debug("PDBs mapped to instance $inst: ".
                            join(',', @{$instPdbMap{$inst}}));

              my @pdbsToKeep = 
                grep { exists $conNames{$_} } @{$instPdbMap{$inst}};
              if (@{$instPdbMap{$inst}} != @pdbsToKeep) {
                log_msg_debug("One or more PDB(s) which not specified ".
                              "during current invocation of\n".
                              "catconExec were removed, leaving ".
                              join(',', @pdbsToKeep).
                              " mapped to instance $inst");
                $instPdbMap{$inst} = \@pdbsToKeep;
                $somePdbsPurged = 1;
              } else {
                log_msg_debug <<msg;
All PDBs mapped to instance $inst were specified during the current 
    invocation of catconExec
msg
              }
            } else {
              log_msg_debug("No PDBs were mapped to instance $inst");
            }
          }

          if ($somePdbsPurged) {
            log_msg_debug("References to some PDBs had to be removed from ".
                          "\%instPdbMap");
            inst_pdbs_hash_dump(\%instPdbMap, "catconExec_int", "instPdbMap");
          } else {
            log_msg_debug("No references to PDBs had to be removed from ".
                          "\%instPdbMap");
          }
        }

        # if catcon was invoked in the course of running an upgrade, each 
        # thread must handle just one PDB and use $catcon_ProcsPerUpgPdb 
        # SQL*Plus processes spawned on the instance where he PDB is open 
        # to accomplish it; otherwise, each thread will handle all PDBs 
        # opened on a given instance and will utilize all SQL*PLus processes 
        # spawned on that instance

        # Before commensing processing, we will construct 
        # 1. an array which will contain descriptions of threads which are
        #    yet to be forked to run scripts against PDBs specified by the 
        #    caller (@threadRecs);
        #    each thread description will consist of:
        #    - name of the instance on which PDB(s) which will be procesed 
        #      by this thread are open 
        #      ($threadRec{INSTANCE})
        #    - maximum number of PDBs which can be handled by this thread 
        #      ($threadRec{MAX_PDBS})
        #    - reference to an array of names of PDBs which will be handled 
        #      by this thread 
        #      ($threadRec{PDBS})
        #    - offset into @catcon_ProcIds of the first process which was 
        #      spawned on the instance on which PDB(s) which will be processed 
        #      by this thread were open which will be used by this thread 
        #      ($threadRec{FIRST_PROC})
        #    - offset into @catcon_ProcIds of the last process which was 
        #      spawned on the instance on which PDB(s) which will be processed 
        #      by this thread were open which will be used by this thread 
        #      ($threadRec{LAST_PROC})
        # 2. a hash mapping instance names to offsets into 
        #    @{$instPdbMap{<instance>}} of the next PDB which was opened on 
        #    a given instance that is yet to be processed (%instToNextPdbMap); 
        #    NOTE: if no PDBs were open on a given instance, %instToNextPdbMap 
        #          will not contain an entry for that instance; 
        #          if all PDBs opened on a given instance have been processed, 
        #          the entry for that instance will be deleted from 
        #          %instToNextPdbMap
        my @threadRecs;
        my %instToNextPdbMap;

        foreach my $pdbInst (sort keys %instPdbMap) {
          if (!@{$instPdbMap{$pdbInst}}) {
            log_msg_debug("No PDBs were opened on instance $pdbInst, so ".
                          "neither\n".
                          "\tthread records nor instToNextPdbMap entry will ".
                          "\tbe created for that instance");
            next;
          }

          if ((! exists $catcon_InstProcMap{$pdbInst}->{MAX_PROCS}) ||
              !$catcon_InstProcMap{$pdbInst}->{MAX_PROCS}) {
            # this should never happen because force_pdb_modes should not be 
            # assigning PDBs to instances to which no sqlplus processes can 
            # be allocated.
            log_msg_error("PDBs ".join(', ', @{$instPdbMap{$pdbInst}})."\n".
                          "\twere assigned to instance $pdbInst even though ".
                          "no sqlplus processes could be allocated to it");
            return 1;
          }

          if ((! exists $catcon_InstProcMap{$pdbInst}->{NUM_PROCS}) ||
              !$catcon_InstProcMap{$pdbInst}->{NUM_PROCS}) {
            # This should never happen either.
            log_msg_error("PDBs ".join(', ', @{$instPdbMap{$pdbInst}})."\n".
                          "\twere assigned to instance $pdbInst but no ".
                          "sqlplus processes are running on it");
            return 1;
          }

          if (! exists $catcon_InstProcMap{$pdbInst}->{FIRST_PROC}) {
            # this should never happen because force_pdb_modes should not be 
            # assigning PDBs to instances to which no sqlplus processes were 
            # allocated
            log_msg_error("PDBs ".join(', ', @{$instPdbMap{$pdbInst}})."\n".
                          "\twere assigned to instance $pdbInst even though ".
                          "the offset of the first sqlplus process\n".
                          "\tallocated to it is not known");
            return 1;
          }

          # number of PDBs open on $pdbInst
          my $numPdbs = @{$instPdbMap{$pdbInst}};

          # number of SQL*Plus proceses spawned on instance $pdbInst
          my $numProcs = $catcon_InstProcMap{$pdbInst}->{NUM_PROCS};

          # offset into @catcon_ProcIds of the first process allocated to 
          # processing PDBs open on this instance
          my $firstProc = $catcon_InstProcMap{$pdbInst}->{FIRST_PROC};

          # offset into @catcon_ProcIds of the last process allocated to 
          # processing PDBs open on this instance
          my $lastProc = $firstProc + $numProcs - 1;

          if ($catcon_ProcsPerUpgPdb) {
            # construct descriptions of threads to be spawned to process PDBs 
            # opened on $pdbInst

            # first thread forked to process PDBs opened on $pdbInst will 
            # start with the first PDB found in @{$instPdbMap{$pdbInst}}
            $instToNextPdbMap{$pdbInst} = 0;

            # offset of the next process open on $pdbInst to assign to a thread
            my $nextProc = $firstProc;

            # we will keep constructing thread records until we run out of 
            # PDBs that are open on $pdbInst or SQL*Plus processes that were 
            # spawned on $pdbInst
            while ($numPdbs && $numProcs >= $catcon_ProcsPerUpgPdb) {
              # description of the next thread
              my %threadRec;
            
              $threadRec{INSTANCE}   = $pdbInst;
              
              # for upgrade, each thread will handle exactly one PDB
              $threadRec{MAX_PDBS}   = 1;

              # obtain index of the next PDB to be processed + increment index 
              # of the next PDB opened on this instance to be processed
              my $nextPdb = $instToNextPdbMap{$pdbInst}++;
              $threadRec{PDBS}       = 
                [@{$instPdbMap{$pdbInst}}[$nextPdb..$nextPdb]];

              $threadRec{FIRST_PROC} = $nextProc;
              $threadRec{LAST_PROC}  = $nextProc + $catcon_ProcsPerUpgPdb - 1;

              push @threadRecs, \%threadRec;

              thread_rec_dump(\%threadRec, 
                              "Thread record created for upgrading a PDB");

              # remember that there are 1 fewer PDBs for which a thread 
              # record needs to be created
              $numPdbs--;

              # remember that there are fewer processes left to be assigned to
              # additional threads
              $numProcs -= $catcon_ProcsPerUpgPdb;

              # next thread record, if any, created for a PDB open on 
              # $pdbInst will use the next $catcon_ProcsPerUpgPdb 
              # SQL*Plus processes
              $nextProc += $catcon_ProcsPerUpgPdb;
            }

            # if thread records have been created for all PDBs on $pdbInst, 
            # delete %instToNextPdbMap entry for $pdbInst to reflect that fact
            if (!$numPdbs) {
              delete $instToNextPdbMap{$pdbInst};
              
              log_msg_debug("Thread records for all PDBs opened on instance ".
                            "$pdbInst have been created,\n".
                            "\tso instToNextPdbMap entry for this instance ".
                            "has been deleted");
            } else {
              log_msg_debug("Number of processes (".
                            $catcon_InstProcMap{$pdbInst}->{NUM_PROCS}.
                            ") spawned on instance $pdbInst was inadequate\n".
                            "\tto process all ".@{$instPdbMap{$pdbInst}}.
                            "PDBs open on this instance, so additional\n".
                            "\t threads will be forked to process remaining ".
                            "$numPdbs PDBs once some of the threads ".
                            "dedicated to processing PDBs on this\n".
                            "\tinstance successfully complete");
            }
          } else {
            # we are not running an upgrade, so a single thread will be 
            # forked to process all PDBs open on $pdbInst using all 
            # SQL*Plus processes spawned on $pdbInst
            
            # description of that thread
            my %threadRec;
            
            $threadRec{INSTANCE}   = $pdbInst;
            $threadRec{MAX_PDBS}   = $numPdbs;
            $threadRec{PDBS}       = $instPdbMap{$pdbInst};
            $threadRec{FIRST_PROC} = $firstProc;
            $threadRec{LAST_PROC}  = $lastProc;

            log_msg_debug <<msg;
A single thread will be used to process all PDBs open on instance $pdbInst:
msg
            push @threadRecs, \%threadRec;

            thread_rec_dump(\%threadRec, 
                            "Thread record created for processing all PDBs ".
                            "open on an instance");

            # this thread will handle all PDBs opened on $pdbInst, so no 
            # $instToNextPdbMap entry for this instance will be created
          }
        }

        # will map process ids of forked processes to thread records, which 
        # will allow us to reuse thread records for additional PDBs, if any
        my %forkedProcIds;

        log_msg_debug("will fork off processes to handle PDBs open on ".
                      "various RAC instance");

        # make sure that the child process log directory exists
        my $childProcLogDir = child_log_dir($catcon_LogFilePathBase);

        if (! defined $childProcLogDir) {
          log_msg_error("unexpected error in child_log_dir");
          return 1;
        }

FORK_PDB_THREADS:        
        # proc id of the parent process which will be used to form names of 
        # log files created for child processes (getppid() is not 
        # portable)
        my $parentPID = $$;

        foreach my $threadRec_ref (@threadRecs) {
          # instance on which PDBs which will be handled by this thread 
          # are open.
          my $pdbInst = $threadRec_ref->{INSTANCE};

          # store thread-specific info in variables which will be used to 
          # communicate it to forked processes

          # PDBs which will be handled by this thread
          my @childContainers = @{$threadRec_ref->{PDBS}};

          log_msg_debug("process ".$$." preparing to fork off a ".
                        "process to handle PDBs\n\t(".
                        join(', ', @childContainers).
                        ")\n\topen on instance $pdbInst");

          # offset into @catcon_ProcIds of the first process allocated to 
          # this thread
          my $firstSqlplusProc = $threadRec_ref->{FIRST_PROC};

          # offset into @catcon_ProcIds of the last process allocated to 
          # this thread
          my $lastSqlplusProc = $threadRec_ref->{LAST_PROC};

          my $childCatconNumProcesses = 
            $lastSqlplusProc - $firstSqlplusProc + 1;

          my @childCatconProcIds = 
            @catcon_ProcIds[$firstSqlplusProc..$lastSqlplusProc];

          log_msg_debug("this thread ".
                        "will use $childCatconNumProcesses processes,\n".
                        "\t$firstSqlplusProc to $lastSqlplusProc (".
                        join(', ', @childCatconProcIds).")");

          my @childCatconFileHandles = 
            @catcon_FileHandles[$firstSqlplusProc..$lastSqlplusProc];
          

          # if the caller requested that we generate spool files, pass this 
          # info to the child, unless we are upgrading PDBs, in which case we 
          # will spool output produced by running scripts against the PDB 
          # which will be processed by this thread into a single spool file, 
          # ignoring user's request (catctl does not generally request that 
          # we generate spool files, so it should not be an issue, but if it 
          # ever does, we will ignore it because we cannot generate both 
          # per-PDB log file and per-script spool file since generating both 
          # involves using SPOOL command)
          my $childSpoolOn = $catcon_SpoolOn;

          # if upgrading PDBs using multiple RAC instances (so eath thread 
          # will process a single PDB) this string will be appended to 
          # $catcon_LogFilePathBase to construct spool and log file names 
          # to look like they do when catctl appends PDB name to the log 
          # base name when it is upgrading PDBs using a single thread per PDB
          # otherwise it will remain set to an empty string
          my $pdbForFileName = "";

          if ($catcon_ProcsPerUpgPdb) {
            if ($childSpoolOn) {
              log_msg_debug <<msg;
Caller's request to generate per-script spool files will be ignored in order
    to generate per-PDB log files while upgrading PDBs using multiple RAC 
    instances
msg

              $childSpoolOn = 0;
            }

            # the new thread will be used to upgrade a PDB, meaning that we 
            # need to spool output produced by running script(s) into log 
            # file(s) whose names follow the naming convention to which DBUA 
            # and upgrade users are accustomed (i.e. 
            # $catcon_LogFilePathBase.<pdb name>.
            # <offset of the SQL*Plus process>)

            $pdbForFileName = getSpoolFileNameSuffix($childContainers[0]);

            for (my $ps = 0; $ps < $childCatconNumProcesses; $ps++) {
              my $spoolFileName = 
                $catcon_LogFilePathBase.$pdbForFileName.$ps.".log";
            
              my $SpoolStmt = "SPOOL '".$spoolFileName."' APPEND\n";
            
              log_msg_debug("sending $SpoolStmt to process $ps of the child ".
                            "thread");

              printToSqlplus("catconExec", $childCatconFileHandles[$ps],
                             $SpoolStmt, "", 
                             $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
            }
          }

          my $pid = fork();
          
          if (! defined $pid) {
            log_msg_error("failed to fork a process to handle ".
                          "processing PDBs open on instance $pdbInst");
            return 1;
          }

          if ($pid) {
            # parent process

            # remember that we forked this process
            $forkedProcIds{$pid} = $threadRec_ref;
            
            thread_rec_dump($threadRec_ref, 
                            "Process $pid was forked for thread");

            log_msg_info("output produced by this child process will ".
                         "be written to ".
                         (child_log_file_name($childProcLogDir, 
                                              $pdbForFileName, $pid)));
          } else {
            # child process; use instance-specific data passed by the parent 
            # to overwrite certain variables and proceed with processing PDBs 
            # open on a given instance

            # remember that we are running in a child process
            $catcon_ChildProc = 1;

            # reset @catcon_ActiveProcesses so we don't inherit parent process'
            # indicators of which processes have seen some action and so 
            # should have their log files preserved
            $#catcon_ActiveProcesses = -1;

            # reset @catcon_DiagMsgs so we don't inherit parent process' 
            # diagnostic messages;
            #
            # NOTE: this needs to happen before the first call to log_msg_*
            #       to avoid dumping parent process' diagniostic messages
            $#catcon_DiagMsgs = -1;

            # also need to reset the offset into @catcon_DiagMsgs where the 
            # next message reported in the child process should be saved
            $catcon_DiagMsgsNext = 0;

            # name of log file created for a child process will contain
            # - name of PDB which it is tasked with processing if we are 
            #   upgrading PDBs of a RAC CDB using all available RAC instances
            # - PID of the child process
            # - PID of the parent process
            my $childProcLog = 
              child_log_file_name($childProcLogDir, $pdbForFileName, $$);

            # open $CATCONOUT for this child process.  
            undef $CATCONOUT;
            if (!sysopen($CATCONOUT, $childProcLog,
                         O_CREAT | O_RDWR | O_APPEND, 0600)) {
              log_msg_error("unable to open ($!) ".$childProcLog." ".
                            "as CATCONOUT for child process ".$$);
              log_msg_error("\tadditional info: $^E");
              return 1;
            }

            # make $CATCONOUT "hot" so diagnostic and error message output 
            # does not get buffered
            select((select($CATCONOUT), $|=1)[0]);

            # PDBs opened on the instance assigned to this child process
            @Containers = @childContainers;
            $firstPDB = 0;

            # number of PDBs open on this instance
            $numPDBs = $#Containers + 1;

            # number of SQL*Plus processes allocated or PDBs open on this 
            # instance
            $catcon_NumProcesses = $childCatconNumProcesses;

            $ProcsUsed = 
              compute_procs_used_for_pdbs($SingleThreaded, $numPDBs, 
                                          $catcon_NumProcesses, 
                                          $#ScriptPaths+1);

            @catcon_ProcIds = @childCatconProcIds;

            @catcon_FileHandles = @childCatconFileHandles;

            # parent may have decided to override caller's request to 
            # generate per-script spool files
            $catcon_SpoolOn = $childSpoolOn;

            goto runScriptsInPDBs;
          }
        }

        # in parent process
        
        # all threads in @threadRecs have been spawned; delete them from 
        # @threadRecs so that if additional threads need to be spawned, we 
        # can add their descriptions to @threadRecs
        @threadRecs = ();

        log_msg_debug("having forked ".
                      (scalar keys %forkedProcIds)." ".
                      "child processes, wait for them to return");

        # parent return value will be set to 0 if all child processes return 0
        # inside their done files; otherwise it will be set to 1 to indicate 
        # a potential problem
        my $parentRetVal = 0;

        while (keys %forkedProcIds) {
          foreach my $childPid (sort keys %forkedProcIds) {
            
            # check if the child process' "done" file exists and contains the 
            # return value
            my $childDoneFile = 
              child_done_file_name($catcon_LogFilePathBase, $childPid);

            if ((-e $childDoneFile) && (-s $childDoneFile)) {
              # remember description of the thread that has completed in 
              # case we need to fork off another thread to process additional 
              # PDB(s)
              my $threadRec_ref = $forkedProcIds{$childPid};

              # delete description of the process in which this thread ran 
              # since we have no further use for it (and don't want to keep 
              # checking if it has completed)
              delete $forkedProcIds{$childPid};

              # offset into @catcon_ProcIds of the first process allocated to 
              # this thread
              my $firstSqlplusProc = $threadRec_ref->{FIRST_PROC};

              # offset into @catcon_ProcIds of the last process allocated to 
              # this thread
              my $lastSqlplusProc = $threadRec_ref->{LAST_PROC};

              # number of SQL*Plus processe assigned to this thread
              my $childNumProcesses = $lastSqlplusProc - $firstSqlplusProc + 1;

              # if we were called to upgrade PDBs using multiple RAC intances, 
              # before forking the child process that has just completed we 
              # turned on spooling of output produced by running scripts into 
              # files whose names include name of the PDB being upgraded.  
              #
              # Since a different PDB may be assigned next to this thread 
              # descriptor, we need to stop spooling to a log file associated 
              # with the PDB which was processed by the child process by the 
              # SQL*Plus processes associated with this thread descriptor
              if ($catcon_ProcsPerUpgPdb) {
                for (my $ps = $firstSqlplusProc;
                     $ps <= $lastSqlplusProc;
                     $ps++) {
                  my $SpoolStmt = "SPOOL OFF\n";
            
                  log_msg_debug("sending $SpoolStmt to process $ps");

                  printToSqlplus("catconExec", $catcon_FileHandles[$ps],
                                 $SpoolStmt, "", 
                                 $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
                }
              }
              
              log_msg_debug("attempt to open $childDoneFile to ".
                            "determine value returned by child process ".
                            "$childPid");
              
              # open the "done" file and extract info reported by the child 
              # process
              my $childFH;

              if (!open($childFH, '<', $childDoneFile)) {
                log_msg_error("child process done file $childDoneFile ".
                              "could not be opened ($!);\n". 
                              "child process appears to have completed, ".
                              "though");
                log_msg_error("\tadditional info: $^E");
                log_msg_error("parent process will report error to the ".
                              "caller");
                $parentRetVal = 1;
              } else {
                my @lines = <$childFH>;

                # did we see the line reporting child process return value?
                my $childRetVal = 0;

                log_msg_debug("child process done file contents:");

                for (@lines) {
                  log_msg_debug("\t".$_);

                  # get rid of \n
                  chomp($_);

                  # split the line into a key and value
                  my ($key, $val) = split(':', $_);
                  
                  if ($key eq CATCONEXEC_CHILD_DONE_FILE_RETVAL) {
                    if ($childRetVal) {
                      log_msg_error <<msg;
Child "done" file contained multiple lines reporting the return value; 
    parent process will report error to the caller
msg
                      $parentRetVal = 1;
                      next;
                    }

                    # remember that we saw the line reporting child process 
                    # return value
                    $childRetVal = 1;

                    if (! defined $val) {
                      log_msg_error <<msg;
Return value line did not contain a return value; parent process will report
    error to the caller
msg
                      $parentRetVal = 1;
                      next;
                    } 

                    log_msg_debug("child process $childPid exited with ".
                                  "return value ". $val);
      
                    if ($val != 0) {
                      log_msg_error <<msg;
Since child return value ($val) did not indicate success, parent process
    will report error to the caller
msg
                      $parentRetVal = 1;
                    } else {
                      log_msg_debug("Child return value ($val) indicated ".
                                    "success");
                    }
                  } elsif ($key eq CATCONEXEC_CHILD_DONE_FILE_ACTIVE_PROC) {
                    if (! defined $val) {
                      log_msg_error <<msg;
Active process line did not contain a process offset; parent process will 
    report error to the caller
msg
                      $parentRetVal = 1;
                      next;
                    } 

                    if ( $val !~ /^[0-9]+$/ ) {
                      log_msg_error <<msg;
Active process line contained a value which was not a positive integer; 
    parent process will report error to the caller
msg
                      $parentRetVal = 1;
                      next;
                    }
                    
                    # $val must represent an offset into a list of process ids
                    # assigned to the child process
                    if ($val >= $childNumProcesses) {
                      log_msg_error <<msg;
Active process line contained a value which was greater than the offset of 
    the last SQL*Plus process assigned to the child process; parent process 
    will report error to the caller
msg
                      $parentRetVal = 1;
                      next;
                    }

                    # translate value found in the line (offset into child's 
                    # @catcon_ProcIds) into an offset into parent's 
                    # @catcon_ProcIds
                    my $parentProcOffset = $val + $firstSqlplusProc;

                    log_msg_debug <<msg;
Offset $val into child's catcon_ProcIds corresponds to offset $parentProcOffset
    into parent's catcon_ProcIds
msg

                    # remember that this process was involved in running 
                    # at least one script or query so its log file does not 
                    # get discarded
                    if (! exists $catcon_ActiveProcesses[$parentProcOffset]) {
                      log_msg_debug <<msg;
Process $parentProcOffset was involved in executing at least one statement 
    or script inside the child process, so its log will be preserved
msg
                      $catcon_ActiveProcesses[$parentProcOffset] = 1;
                    }
                  } else {
                    log_msg_error <<msg;
Child "done" file contained a line with unexpected key ($key); parent process 
    will report error to the caller
msg
                    $parentRetVal = 1;
                    next;
                  }
                }

                # make sure that we saw a line reporting child process' 
                # return value
                if (!$childRetVal) {
                  log_msg_error <<msg;
Child "done" file did not contain a line reporting the return value; 
    parent process will report error to the caller
msg
                  $parentRetVal = 1;
                }

                # since we were able to open and examine child process' done 
                # file, delete it
                sureunlink($childDoneFile);

                # if no error has been encountered so far, determine if there 
                # are more PDBs that need to be processed on the instance 
                # associated with the thread that has just completed, and if 
                # so, 
                # - update the thread record describe PDB(s) that will need 
                #   to be processed, 
                # - add it to @threadRecs and 
                # - cause another thread to be forked
                if (!$parentRetVal) {
                  # instance on which PDB(s) were processed by the newly 
                  # completed thread were open
                  my $pdbInst = $threadRec_ref->{INSTANCE};

                  # check if there are more PDBs on this instance that need 
                  # to be processed
                  if (exists $instToNextPdbMap{$pdbInst}) {
                    # update thread record to describe additional PDB(s) that 
                    # will be processed by this thread
                    
                    # first PDB that will be processed by this thread can be 
                    # found at offset $instToNextPdbMap{$pdbInst} into 
                    # $instPdbMap{$pdbInst}
                    my $firstPdb = $instToNextPdbMap{$pdbInst};

                    # number of PDBs which will be assigned to this thread is 
                    # the smaller of the number of PDBs that may be assigned 
                    # to this thread and the number of PDBs opened on 
                    # $pdbInst thread records for which are yet to be created
                    my $lastPdb;
                    
                    if (@{$instPdbMap{$pdbInst}} - $firstPdb <= 
                        $threadRec_ref->{MAX_PDBS}) {
                      # all unaccounted for PDBs open on $pdbInst will be 
                      # handled by this thread
                      $lastPdb = @{$instPdbMap{$pdbInst}} - 1;

                      # number of PDBs that will be handled by this thread
                      my $numPdbs = $lastPdb - $firstPdb +1;
                      
                      # store name(s) of PDB(s) in the thread record
                      $threadRec_ref->{PDBS} = 
                        [@{$instPdbMap{$pdbInst}}[$firstPdb..$lastPdb]];
                      
                      push @threadRecs, $threadRec_ref;

                      thread_rec_dump($threadRec_ref, 
                                      "Thread record created for additional ".
                                      "PDBs");

                      # after this thread has been forked, no additional 
                      # threads dedicated to processing PDBs opened on 
                      # $pdbInst will need to be forked, so we can delete 
                      # %instToNextPdbMap entry for $pdbInst
                      delete $instToNextPdbMap{$pdbInst};
              
                      log_msg_debug("Thread record for the last remaining ".
                                    "$numPdbs PDBs open\n".
                                    "\ton instance $pdbInst have been ".
                                    "created, so instToNextPdbMap entry for\n".
                                    "\tthis instance has been deleted");
                    } else {
                      # number of PDBs which will be assigned to this thread 
                      # will be determined by the maximum number of PDBs that 
                      # can be handled by it, with some PDBs) left for other 
                      # threads to process
                      $lastPdb = $firstPdb + $threadRec_ref->{MAX_PDBS} - 1;

                      # number of PDBs that will be handled by this thread
                      my $numPdbs = $lastPdb - $firstPdb +1;
                      
                      # store name(s) of PDB(s) in the thread record
                      $threadRec_ref->{PDBS} = 
                        [@{$instPdbMap{$pdbInst}}[$firstPdb..$lastPdb]];
                      
                      push @threadRecs, $threadRec_ref;

                      thread_rec_dump($threadRec_ref, 
                                      "Thread record created for additional ".
                                      "PDBs");

                      # adjust $instToNextPdbMap{$pdbInst} to reflect number 
                      # of PDBs which will be processed by this thread
                      log_msg_debug("Adjust offset of the first PDB open on ".
                                    "instance $pdbInst which will be\n".
                                    "\tprocessed by a future thread from ".
                                    "$instToNextPdbMap{$pdbInst} to ".
                                    ($instToNextPdbMap{$pdbInst} + 
                                     $threadRec_ref->{MAX_PDBS}));
                      $instToNextPdbMap{$pdbInst} += 
                        $threadRec_ref->{MAX_PDBS};
                    }
                      
                    goto FORK_PDB_THREADS;
                  }
                }
              }
            }
          }
        }

        # all processing has been done by child processes
        log_msg_debug("all child processes have completed.\n".
                      "\tReturning $parentRetVal...");

        return $parentRetVal;
      } else {
        # either the user did not request that we use all available instances,
        # or he specified that all PDBs are to be left in the mode in which 
        # they are open (which causes us to ignore a request to use all 
        # available instances), and so we will process all PDBs using the 
        # current catcon process

        my $msg;

        if (!$catcon_AllInst) {
          $msg = "user did not request that we use all available instances\n";
        } else {
          $msg = "catcon_ForcePdbModeInstPdbMap was not set\n";
        }
        
        log_msg_debug($msg.
                      "\twill run scripts using the current catcon process");
      }

runScriptsInPDBs:

      # offset into the array of remaining Container names
      my $CurCon;

      # set it to -1 so the first time next_proc is invoked, it will start by 
      # examining status of process 0
      $CurProc = -1;

      # NOTE: $firstPDB contains offset of the first PDB in the list, but 
      #       $#Containers still represents the offset of the last PDB
      for ($CurCon = $firstPDB; $CurCon <= $#Containers; $CurCon++) {

        # if there is a query to run to see if the scripts should be run
        # in this PDB, run the query and exit if it returns NULL

        if ($$skipProcQuery) {
            my @result = catconQuery($$skipProcQuery, $Containers[$CurCon]);
            if ($result[0] eq "") {
                next;   # do not run any of the scripts in this PDB
            }
        }

        # if we were told to run single-threaded, switch into the right 
        # Container; all scripts and SQL statement to be executed in this
        # Container will be sent to the same process
        if ($SingleThreaded) {
          # as we are starting working on a new Container, find next 
          # available process
          $CurProc = pickNextProc($ProcsUsed, $catcon_NumProcesses, 
                                  $CurProc + 1,
                                  $catcon_LogFilePathBase, \@catcon_ProcIds, 
                                  $catcon_RecoverFromChildDeath,
                                  @catcon_InternalConnectString, 
                                  $catcon_KillAllSessScript,
                                  $catcon_DoneCmd, $catcon_Sqlplus);
          
          if ($CurProc < 0) {
            # some unexpected error was encountered
            log_msg_error("unexpected error in pickNextProc");
            return 1;
          }

          # remember that this process will be involved in running at least 
          # one script or query
          if (! exists $catcon_ActiveProcesses[$CurProc]) {
            if ($catcon_ChildProc) {
              log_msg_debug <<msg;
Process $CurProc used by a child process will be involved in executing at 
    least one statement or script, so its log will be preserved
msg
            } else {
              log_msg_debug <<msg;
Process $CurProc will be involved in executing at least one statement or 
    script, so its log will be preserved
msg
            }

            $catcon_ActiveProcesses[$CurProc] = 1;
          }

          # bug 25507396: if $catcon_EZconnToPdb is set, we don't want 
          #   additionalInitStmts to switch into $Containers[$CurCon]
          additionalInitStmts(\@catcon_FileHandles, $CurProc, 
                              $catcon_EZconnToPdb 
                                ? undef : $Containers[$CurCon], 
                              $CurrentContainerQuery, 
                              $catcon_ProcIds[$CurProc],
                              $catcon_EchoOn, 
                              $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG,
                              (!$catcon_UserScript && !$catcon_NoOracleScript),
                              $catcon_FedRoot);
        }

        # determine prefix of ERRORLOGGING identifier, if needed
        if ($catcon_ErrLogging) {
          # do not mess with $ErrLoggingIdent if $$CustomErrLoggingIdent is set
          # since once the user provides a value for the Errorlogging 
          # Identifier, he is fully in charge of its value
          # do not mess with $ErrLoggingIdent if $$CustomErrLoggingIdent is set
          # since once the user provides a value for the Errorlogging 
          # Identifier, he is fully in charge of its value
          # 
          # Truth table describing how we determine whether to set the 
          # ERRORLOGGING Identifier, and if so, whether to use a default 
          # identifier or a custom identifier
          # N\C 0   1
          #   \--------
          #  0| d | c |
          #   ---------
          #  1| - | c |
          #   ---------
          #
          # N = is $catcon_NoErrLogIdent set?
          # C = is $$CustomErrLoggingIdent defined?
          # d = use default ERRORLOGGING Identifier
          # c = use custom ERRORLOGGING Identifier
          # - = do not setuse ERRORLOGGING Identifier
          #
          # NOTE: it's important that we we assign $$CustomErrLoggingIdent to 
          #       $ErrLoggingIdent and test the result BEFORE we test 
          #       $catcon_NoErrLogIdent because  if $$CustomErrLoggingIdent is 
          #       $defined, we will ignore catcon_NoErrLogIdent, so it's 
          #       necessary that $ErrLoggingIdent gets set to 
          #       $$CustomErrLoggingIdent regardless of whether 
          #       $catcon_NoErrLogIdent is set
          if (!($ErrLoggingIdent = $$CustomErrLoggingIdent) && 
              !$catcon_NoErrLogIdent) {
            $ErrLoggingIdent = "{$Containers[$CurCon]}::";
          }

          # replace single and double quotes in $ErrLoggingIdent with # to 
          # avoid confusion
          if ($ErrLoggingIdent && $ErrLoggingIdent ne "") {
            $ErrLoggingIdent =~ s/['"]/#/g;
          }

          log_msg_debug("ErrLoggingIdent prefix ".
                        ((defined $ErrLoggingIdent) ? "= $ErrLoggingIdent" 
                                                    : "not specified"));
        }

        my $ScriptPathDispIdx = -1;

        $currCatUpgrd = 0;
    
        foreach my $FilePath (@ScriptPaths) {
          # remember if the last script ran was catshutdown
          $prevCatShutdown = $catcon_CatShutdown{$Containers[$CurCon]};

          # remember if the current script is catshutdown or catupgrd
          if (index($FilePath, "catshutdown") != -1) {
            $catcon_CatShutdown{$Containers[$CurCon]} = 1;
            $currCatUpgrd = 0;
          } elsif (index($FilePath, "catupgrd") != -1) {
            $currCatUpgrd = 1;
            $catcon_CatShutdown{$Containers[$CurCon]} = 0;
          } else {
            $currCatUpgrd = $catcon_CatShutdown{$Containers[$CurCon]} = 0;
          }

          # switch into the right Container if we were told to run 
          # multi-threaded; each script or SQL statement may be executed 
          # using a different process
          if (!$SingleThreaded) {
            # as we are starting working on a new script or SQL statement, 
            # find next available process
            $CurProc = pickNextProc($ProcsUsed, $catcon_NumProcesses, 
                                    $CurProc + 1,
                                    $catcon_LogFilePathBase, \@catcon_ProcIds, 
                                    $catcon_RecoverFromChildDeath,
                                    @catcon_InternalConnectString, 
                                    $catcon_KillAllSessScript,
                                    $catcon_DoneCmd, $catcon_Sqlplus);

            if ($CurProc < 0) {
              # some unexpected error was encountered
              log_msg_error("unexpected error in pickNextProc");
              return 1;
            }

            # remember that this process will be involved in running at least 
            # one script or query
            if (! exists $catcon_ActiveProcesses[$CurProc]) {
              if ($catcon_ChildProc) {
                log_msg_debug <<msg;
Process $CurProc used by a child process will be involved in executing at 
    least one statement or script, so its log will be preserved
msg
              } else {
                log_msg_debug <<msg;
Process $CurProc will be involved in executing at least one statement or 
    script, so its log will be preserved
msg
              }

              $catcon_ActiveProcesses[$CurProc] = 1;
            }

            # bug 25507396: if $catcon_EZconnToPdb is set, we don't want 
            #   additionalInitStmts to switch into $Containers[$CurCon]
            additionalInitStmts(\@catcon_FileHandles, $CurProc, 
                                $catcon_EZconnToPdb 
                                  ? undef : $Containers[$CurCon], 
                                $CurrentContainerQuery, 
                                $catcon_ProcIds[$CurProc],
                                $catcon_EchoOn, 
                                $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG,
                                (!$catcon_UserScript && 
                                   !$catcon_NoOracleScript), 
                                $catcon_FedRoot);
          }

          # if this is the first time we are using this process and 
          # the caller indicated that one or more statements need to be 
          # executed before using a process for the first time, issue these 
          # statements now
          if ($#NeedInitStmts >= 0 && $NeedInitStmts[$CurProc]) {
            firstProcUseStmts($ErrLoggingIdent, $$CustomErrLoggingIdent,
                              $catcon_ErrLogging, 
                              \@catcon_FileHandles, $CurProc, 
                              $catcon_PerProcInitStmts, \@NeedInitStmts, 
                              (!$catcon_UserScript && !$catcon_NoOracleScript),
                              $catcon_FedRoot, 
                              $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
          }

          print {$catcon_FileHandles[$CurProc]} qq#select '==== CATCON EXEC IN CONTAINERS ====' AS catconsection from dual\n/\n#;

          # element of @ScriptPathsToDisplay which corresponds to $FilePath
          my $FilePathToDisplay = $ScriptPathsToDisplay[++$ScriptPathDispIdx];

          # bracket script or statement with strings intended to make it 
          # easier to determine origin of output in the log file

          print {$catcon_FileHandles[$CurProc]} qq#select '==== $FilePathToDisplay' || ' Container:' || SYS_CONTEXT('USERENV','CON_NAME') || ' Id:' || SYS_CONTEXT('USERENV','CON_ID') || ' ' || TO_CHAR(SYSTIMESTAMP,'YY-MM-DD HH:MI:SS') || ' Proc:$CurProc ====' AS begin_running from sys.dual;\n/\n#;

          if ($catcon_ErrLogging) {
            # construct and issue SET ERRORLOGGING ON [TABLE...] statement
            if ($bInitStmts)
            {
              err_logging_tbl_stmt($catcon_ErrLogging, \@catcon_FileHandles, 
                                   $CurProc, 
                                   (!$catcon_UserScript && 
                                      !$catcon_NoOracleScript),
                                   $catcon_FedRoot, 
                                   $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
            }

            if ($ErrLoggingIdent) {
              # send SET ERRORLOGGING ON IDENTIFIER ... statement

              my $Stmt;

              if ($$CustomErrLoggingIdent) {
                # NOTE: if the caller of catconExec() has supplied a custom 
                #       Errorlogging Identifier, it has already been copied 
                #       into $ErrLoggingIdent which was then normalized, so 
                #       our use of $ErrLoggingIdent rather than 
                #       $CustomErrLoggingIdent below is intentional
                $Stmt = "SET ERRORLOGGING ON IDENTIFIER '".substr($ErrLoggingIdent, 0, 256)."'";
              } else {
                $Stmt = "SET ERRORLOGGING ON IDENTIFIER '".substr($ErrLoggingIdent.$FilePathToDisplay, 0, 256)."'";
              }
              
              log_msg_verbose("sending $Stmt to process $CurProc");

              printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                             $Stmt, "\n", 
                             $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
            }
          }

          # statement to start/end spooling output of a SQL*Plus script
          my $SpoolStmt;

          # if the caller requested that we generate a spool file and we are 
          # about to execute a script, issue SPOOL ... REPLACE
          if ($catcon_SpoolOn && $SpoolFileNames[$ScriptPathDispIdx] ne "") {
            my $SpoolFileNameSuffix = 
              getSpoolFileNameSuffix($Containers[$CurCon]);

            $SpoolStmt = "SPOOL '" . $SpoolFileNames[$ScriptPathDispIdx] . $SpoolFileNameSuffix . "' REPLACE\n";
            
            log_msg_debug("sending $SpoolStmt to process $CurProc");

            printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                           $SpoolStmt, "", 
                           $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);

            # remember that after we execute the script, we need to turn off 
            # spooling
            $SpoolStmt = "SPOOL OFF \n";
          }

          # if executing a query, will be set to the text of the query; 
          # otherwise, will be set to the name of the script with parameters, 
          # if any
          my $AppInfoAction;

          my $LastSlash; # position of last / or \ in the script name
      
          if ($FilePath !~ /^@/) {
            $AppInfoAction = $FilePath;
          } elsif (($LastSlash = rindex($FilePath, '/')) >= 0 ||
                   ($LastSlash = rindex($FilePath, '\\')) >= 0) {
            $AppInfoAction = substr($FilePath, $LastSlash + 1);
          } else {
            # FilePath contains neither backward nor forward slashes, so use 
            # it as is
            $AppInfoAction = $FilePath;
          }

          # $AppInfoAction may include parameters passed to the script. 
          # These parameters will be surrounded with single quotes, which will 
          # cause a problem since $AppInfoAction is used to construct a 
          # string parameter being used with 
          # ALTER SESSION SET APPLICATION ACTION.
          # To prevent this from happening, we will replace single quotes found
          #in $AppInfoAction with #
          $AppInfoAction =~ s/[']/#/g;

          # Bug 25696936: if the next item to be executed is a statement, it 
          # may contain \n chars which will be replaced with a single space
          $AppInfoAction =~ s/\n/ /g;

          # use ALTER SESSION SET APPLICATION MODULE/ACTION to identify 
          # process, Container and script or statement being run
          if (!$currCatUpgrd && !$catcon_CatShutdown{$Containers[$CurCon]}) {
            printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                           "ALTER SESSION SET APPLICATION MODULE = 'catcon(pid=$PID)'",
                           "\n/\n", 
                           $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
          }

          log_msg_debug("issued ALTER SESSION SET APPLICATION MODULE = ".
                        "'catcon(pid=$PID)'");

          if (!$currCatUpgrd && !$catcon_CatShutdown{$Containers[$CurCon]}) {
            printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                           "ALTER SESSION SET APPLICATION ACTION = '$Containers[$CurCon]::$AppInfoAction'",
                           "\n/\n", 
                           $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
          }

          log_msg_debug("issued ALTER SESSION SET APPLICATION ACTION = ".
                        "'$Containers[$CurCon]::$AppInfoAction'");

          # execute next script or SQL statement

          log_script_execution($FilePathToDisplay, $Containers[$CurCon], 
                               $CurProc);

          # if catcon_LogLevel is set to DEBUG, printToSqlplus will normally 
          # issue 
          #   select "catconExec() ... as catcon_statement from dual"
          # which we need to avoid if we just finished running  catshutdown
          printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                         $FilePath, "\n", 
                         $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);

          # if executing a statement, follow the statement with "/"
          if ($FilePath !~ /^@/) {
            print {$catcon_FileHandles[$CurProc]} "/\n";
          }

          # if we started spooling before running the script, turn it off after
          # it is done
          if ($SpoolStmt) {
            log_msg_debug("sending $SpoolStmt to process $CurProc");
            
            printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                           $SpoolStmt, "", 
                           $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
          }

          if (!$catcon_CatShutdown{$Containers[$CurCon]})
          {
            print {$catcon_FileHandles[$CurProc]} qq#select '==== $FilePathToDisplay' || ' Container:' || SYS_CONTEXT('USERENV','CON_NAME') || ' Id:' || SYS_CONTEXT('USERENV','CON_ID') || ' ' || TO_CHAR(SYSTIMESTAMP,'YY-MM-DD HH:MI:SS') || ' Proc:$CurProc ====' AS end_running from sys.dual;\n/\n#;
          }

          if ($FilePath =~ /^@/ && $catcon_UncommittedXactCheck) {
            # if asked to check whether a script has ended with uncommitted 
            # transaction, do so now
            printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
               qq#SELECT decode(COUNT(*), 0, 'OK', 'Script ended with uncommitted transaction') AS uncommitted_transaction_check FROM v\$transaction t, v\$session s, v\$mystat m WHERE t.ses_addr = s.saddr AND s.sid = m.sid AND ROWNUM = 1#, 
               "\n/\n", $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
          }

          # unless we are running single-threaded, we a need a "done" file to 
          # be created after the current script or statement completes so that 
          # next_proc() would recognize that this process is available and 
          # consider it when picking the next process to run a script or SQL 
          # statement
          if (!$SingleThreaded) {
            # file which will indicate that process $CurProc finished its 
            # work and is ready for more
            #
            # Bug 18011217: append _catcon_$catcon_ProcIds[$CurProc] to 
            # $catcon_LogFilePathBase to avoid conflicts with other catcon 
            # processes running on the same host
            my $DoneFile = 
              done_file_name($catcon_LogFilePathBase, 
                             $catcon_ProcIds[$CurProc]);

            # if catcon_LogLevel is set to DEBUG, printToSqlplus will normally 
            # issue 
            #   "select 'catconExec() ... as catcon_statement from dual"
            # which we need to avoid if we are running catshutdown
            printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                           qq/$catcon_DoneCmd $DoneFile/,
                           "\n", 
                           $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);

            log_msg_debug <<msg;
sent "$catcon_DoneCmd $DoneFile" to process 
    $CurProc (id = $catcon_ProcIds[$CurProc]) to indicate its availability 
    after completing $FilePath
msg
          }

          $catcon_FileHandles[$CurProc]->flush;
        }

        # if we are running single-threaded, we a need a "done" file to be 
        # created after the last script or statement sent to the current 
        # Container completes so that next_proc() would recognize that this 
        # process is available and consider it when picking the next process 
        # to run a script or SQL statement
        if ($SingleThreaded) {
          # file which will indicate that process $CurProc finished its work 
          # and is ready for more
          #
          # Bug 18011217: append _catcon_$catcon_ProcIds[$CurProc] to 
          # $catcon_LogFilePathBase to avoid conflicts with other catcon 
          # processes running on the same host
          my $DoneFile = 
            done_file_name($catcon_LogFilePathBase, $catcon_ProcIds[$CurProc]);

          # if catcon_LogLevel is set to DEBUG, printToSqlplus will normally 
          # issue 
          #   select "catconExec() ... as catcon_statement from dual"
          # which we need to avoid if the last script we ran was catshutdown
          printToSqlplus("catconExec", $catcon_FileHandles[$CurProc],
                         qq/$catcon_DoneCmd $DoneFile/,
                         "\n", 
                         $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);

          # flush the file so a subsequent test for file existence does 
          # not fail due to buffering
          $catcon_FileHandles[$CurProc]->flush;
      
            log_msg_debug <<msg;
sent "$catcon_DoneCmd $DoneFile" to process 
    $CurProc (id = $catcon_ProcIds[$CurProc]) to indicate its availability
msg
        }
      }

      # if 
      #   - the user told us to issue per-process init and completion 
      #     statements and 
      #   - there are any such statements to send, 
      # they need to be passed to wait_for_completion
      my $EndStmts = $IssuePerProcStmts ? $catcon_PerProcEndStmts : undef;

      # wait_for_completion uses calls printToSqlplus to send "done" command to
      # processes and if catcon_LogLevel is set to DEBUG, printToSqlplus will 
      # normally issue 
      #   "select 'catconExec() ... as catcon_statement from dual"
      # which we need to avoid if the last script we ran was catshutdown
      #
      # bug 25507396: if $catcon_EZconnToPdb is set, we don't want 
      #   wait_for_completion to switch into Root
      if (wait_for_completion($ProcsUsed, $catcon_NumProcesses, 
            $catcon_LogFilePathBase, 
            @catcon_FileHandles, @catcon_ProcIds,
            $catcon_DoneCmd, @$EndStmts, 
            (@catcon_Containers && !$catcon_EZconnToPdb) 
                ? $CDBorFedRoot : undef,
            @catcon_InternalConnectString,
            $catcon_RecoverFromChildDeath,
            $catcon_KillAllSessScript, 
            index($ScriptPaths[$#ScriptPaths], "catshutdown") != -1,
            $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG,
            $catcon_Sqlplus) == 1) {
        # unexpected error was encountered, return
        log_msg_error("unexpected error in wait_for_completion");
        return 1;
      }
    }

    # success
    return 0;
  }

  #
  # catconRunSqlInEveryProcess - run specified SQL statement(s) in every 
  #                              process
  #
  # Parameters:
  #   - reference to a list of SQL statement(s) which should be run in every 
  #     process
  # Returns
  #   1 if some unexpected error was encountered; 0 otherwise
  #
  sub catconRunSqlInEveryProcess (\@) {
    my ($Stmts) = @_;

    my $ps;

    # there must be at least one statement to execute
    if (!$Stmts || !@$Stmts || $#$Stmts == -1) {
      log_msg_error("At least one SQL statement must be supplied");
      return 1;
    }

    log_msg_debug("running catconRunSqlInEveryProcess\n    SQL statements:");
    foreach (@$Stmts) {
      log_msg_debug("\t$_");
    }

    # catconInit2 had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return 1;
    }

    # send each statement to each process
    foreach my $Stmt (@$Stmts) {
      for ($ps=0; $ps < $catcon_NumProcesses; $ps++) {
        printToSqlplus("catconRunSqlInEveryProcess", $catcon_FileHandles[$ps],
                       $Stmt, "\n", 
                       $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG);
      }    
    }

    return 0;
  }

  #
  # catconShutdown - shutdown the database
  #
  # Parameters:
  #   - shutdown flavor (e.g. ABORT or IMMEDIATE)
  # 
  # Returns
  #   1 if some unexpected error was encountered; 0 otherwise
  #
  sub catconShutdown (;$) {

    my ($ShutdownFlavor) = @_;
      
    # catconInit2 had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return 1;
    }

    # free up all resources
    catconWrapUp();

    # if someone wants to invoke any catcon subroutine, they will need 
    # to invoke catconInit2 first

    log_msg_verbose("will shutdown database using SHUTDOWN $ShutdownFlavor");

    # shutdown_db needs to be called after catconWrapUp() to make sure that 
    # all processes have exited.
    #
    # Bug 18011217: append _catcon_$catcon_ProcIds[0] to 
    # $catcon_LogFilePathBase to avoid conflicts with other catcon processes 
    # running on the same host
    shutdown_db(@catcon_InternalConnectString, $ShutdownFlavor,
                $catcon_DoneCmd, 
                done_file_name_prefix($catcon_LogFilePathBase, 
                                      $catcon_ProcIds[0]),
                $catcon_Sqlplus);

    return 0;
  }

  #
  # catconUsingMultipleInstances - are multiple RAC instances being used to 
  #                                process PDBs.
  #
  # Parameters:
  #   - None
  #
  sub catconUsingMultipleInstances () {
    # catconInit had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit has not been run");
      return undef;
    }

    return (%catcon_InstProcMap ? 1 : 0);
  }

  #
  # catconMultipleInstancesFeasible - is use of multiple RAC instances 
  #   feasible based on parameters supplied by the caller and characteristics 
  #   of the CDB (but not taking into consideration special restrictions 
  #   (i.e. if we are running UPGRADE and the caller has supplied 0 as the 
  #   number of processes) which could cause us to ignore caller's request
  #
  sub catconMultipleInstancesFeasible() {
    # catconInit had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit has not been run");
      return undef;
    }

    return mult_inst_feasible(all_inst_requested($catcon_AllInst, 
                                                 $catcon_AllPdbMode), 
                              \@catcon_InternalConnectString, 
                              \%catcon_InstConnStr, \@catcon_UserConnectString,
                              $catcon_DbmsVersion);
  }

  #
  # catconUpgEndSessions - Ends all sessions except one.
  #
  # Parameters:
  #   - None
  #
  sub catconUpgEndSessions () {
 
    # catconInit2 had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return 1;
    }

    my $multInst = catconUsingMultipleInstances();
      
    log_msg_debug("PDBs are being upgraded using ".
                  ($multInst ? "multiple" : "a single")." instance");

    log_msg_debug("catcon_DfltProcsPerUpgPdb = ".
                  (show_undef($catcon_DfltProcsPerUpgPdb)));

    if ($multInst && $catcon_DfltProcsPerUpgPdb) {
      # if we are running upgrade on a CDB using all available RAC instances, 
      # we will forego killing (numerous) processes which were started on 
      # various instances and will, instead, remember that until 
      # catconUpgStartSessions gets called, threads dispatched to run scripts 
      # on PDBs should be assigned a single SQL*Plus process
      $catcon_ProcsPerUpgPdb = 1;

    log_msg_verbose <<msg;
Since we are upgrading a CDB using all available RAC instances, rather than 
    killing all but one SQL*Plus process, we will simply remember that 
    threads forked to upgrade PDBs should be assigned just 1 SQL*Plus process
msg

      return 0;
    }

    log_msg_verbose("Will end all sessions but one");

    #
    # End Every Process but 1.
    #
    if ($catcon_NumProcesses > 1) {
 
        my $ps;
        for ($ps = 1; $ps <= $catcon_NumProcesses - 1; $ps++) {
          if ($catcon_FileHandles[$ps]) {
              print {$catcon_FileHandles[$ps]} "PROMPT ========== PROCESS ENDED ==========\n";
          }
        }

        # End All Sql Processors but one
        end_processes(1, $catcon_NumProcesses - 1, @catcon_FileHandles, 
                      @catcon_ProcIds, 
                      $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG, 
                      $catcon_LogFilePathBase, -1, \%catcon_InstProcMap, 
                      \%catcon_ProcInstMap);

        # Set Number of processors to 1
        $catcon_NumProcesses = 1;
    }
    return 0;

  }


  #
  # catconUpgStartSessions - Starts all Sessions.
  #
  # Returns = 1 Error
  #           0 Success
  # Parameters:
  #   - $NumProcesses  = How many process to start
  #   - $ResetLogs     = Reset Logs TRUE(1) or FALSE(0)
  #   - $LogDir        = New Log Directory
  #   - $LogBase       = Log Base
  #   - $DebugOn       = catcon.pm Debugging
  #
  sub catconUpgStartSessions ($$$$$) {

    my ($NumProcesses,$ResetLogs,$LogDir,$LogBase,$DebugOn) = @_;
    my $FirstTime = 0;

    # catconInit2 had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return 1;
    }

    # in case $LogDir and $LogBase are undefined, N/A will be printed
    my $logDirStr = (defined $LogDir) ? $LogDir : "N/A";
    my $logBaseStr = (defined $LogBase) ? $LogBase : "N/A";

    my $ts = TimeStamp();

    log_msg_debug <<catconUpgStartSessions_DEBUG;
  running catconUpgStartSessions(NumProcesses   = $NumProcesses, 
                                 ResetLogs      = $ResetLogs,
                                 LogDir         = $logDirStr, 
                                 LogBase        = $logBaseStr, 
                                 Debug          = $DebugOn)\t\t($ts)
catconUpgStartSessions_DEBUG
      
    # we need to save value of $catcon_LogFilePathBase here in case $ResetLogs 
    # is set since end_processes() uses $LogFilePathBase when cleaning up 
    # completion files generated by processes being "ended."  
    # Of course, if the old log directory has been deleted before this function
    # was called, we won't get much for our trouble, but at least we tried.
    my $saveLogFilePathBase = $catcon_LogFilePathBase;
    
    # are multiple instances being used to upgrade PDBs?
    my $multInst = catconUsingMultipleInstances();
      
    log_msg_debug("PDBs are being upgraded using ".
                  ($multInst ? "multiple" : "a single")." instance");

    # Reset Log Directory
    if ($ResetLogs)
    {
        # Set First Time to True
        # And don't override the
        # number of processors.
        # We are only switching the
        # log files.
        $FirstTime = 1;
        $NumProcesses = $catcon_NumProcesses;

        # Close error log file
        close ($CATCONOUT);

        # set Log File Path Base
        $catcon_LogFilePathBase = set_log_file_base_path($LogDir,$LogBase);

        if (!$catcon_LogFilePathBase) {
          log_msg_error("Unexpected error returned by set_log_file_base_path");
          return 1;
        }

        # Set Log directory
        $catcon_LogDir = $LogDir;
    } elsif ($multInst && $catcon_DfltProcsPerUpgPdb) {
      # unless caller requested that we reset logs, if we are running 
      # upgrade on a CDB using all available RAC instances, we will 
      # forego killing and starting (numerous) processes which were 
      # started on various instances and will, instead, remember that 
      # threads dispatched to run scripts on PDBs should be assigned 
      # number of SQL*Plus process which were supplied as $NumProcesses
      # to catconInit
      $catcon_ProcsPerUpgPdb = $catcon_DfltProcsPerUpgPdb;

      log_msg_verbose <<msg;
Since the caller has not requested that we reset logs, and we are upgrading 
    a CDB using all available RAC instances, rather than killing and 
    restarting SQL*Plus process on all RAC instances, we will simply remember 
    that threads forked to upgrade PDBs should be assigned 
    $catcon_DfltProcsPerUpgPdb SQL*Plus processes
msg

      return 0;
    }

    #
    # End current session
    #
    end_processes(0, $catcon_NumProcesses - 1, @catcon_FileHandles, 
                  @catcon_ProcIds, $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG, 
                  $saveLogFilePathBase, -1, \%catcon_InstProcMap, 
                  \%catcon_ProcInstMap);

    # delete the "kill all sessions script" since all processes it would try 
    # to kill are now gone
    sureunlink($catcon_KillAllSessScript);

    if ($ResetLogs)
    {
        # we want to keep $catcon_KillAllSessScript 
        # in sync with $catcon_LogFilePathBase (because in some cases, the old 
        # log directory may no longer be around which will cause us to get 
        #     start_processes: failed to open (2) kill_all_sessions script
        # message when we try to append ALTER SYSTEM KILL SESSION statements 
        # to the kill_all_sessions script in start_processes().
        #
        # We waited until now to do it because of sureunlink() call above that 
        # tries to delete the kill_all_sessions script after end_processes()
        # returns
        $catcon_KillAllSessScript = 
            kill_session_script_name($catcon_LogFilePathBase, "ALL");
    }    
    
    #
    # Set number of Processors; if processing a non-CDB, use the number 
    # supplied by the caller; otherwise, call get_num_cdb_procs which will 
    # take into consideration whether the CDB is running on a RAC and how 
    # heavily individual RAC instances are loaded
    #
    if (!catconIsCDB()) {
      log_msg_debug("upgrading a non-CDB - use caller-supplied number of ".
                    "processes ($NumProcesses)");
      $catcon_NumProcesses = $NumProcesses;
    } else {
      log_msg_debug("upgrading a CDB - determine number of SQL*Plus ".
                    "processses to be started");

      $catcon_NumProcesses = 
        get_num_cdb_procs($NumProcesses, 
          $catcon_AllInst && ($catcon_AllPdbMode != CATCON_PDB_MODE_UNCHANGED),
          %catcon_InstProcMap, \@catcon_InternalConnectString, $catcon_IsRac, 
          @catcon_IdleRacInstances + @catcon_RunningRacInstances, 
          $catcon_ExtParallelDegree, $catcon_DoneCmd, $catcon_LogFilePathBase, 
          \%catcon_InstProcMap, $catcon_InvokeFrom, $catcon_Sqlplus);

      if ($catcon_NumProcesses == -1) {
        log_msg_error("unexpected error in get_num_cdb_procs");
        return 1;
      }

      log_msg_debug("get_num_cdb_procs determined that $catcon_NumProcesses ".
                    "processes should be started.");
    }

    #
    # Bug 22887047: we set SIG{CHLD} to 'IGNORE' in catconInit2, and that's 
    #   where we want to leave it since we will deal with any dead child 
    #   processes when we come across them in the course of trying to pick a 
    #   next process to do perform some task (next_proc())
    #

    # start processes
    if (start_processes($catcon_NumProcesses, $catcon_LogFilePathBase, 
                        @catcon_FileHandles, @catcon_ProcIds, 
                        @catcon_Containers, $catcon_Root,
                        @catcon_UserConnectString, 
                        $catcon_EchoOn, $catcon_ErrLogging,
                        $catcon_LogLevel, $FirstTime,
                        (!$catcon_UserScript && !$catcon_NoOracleScript), 
                        $catcon_FedRoot,
                        $catcon_DoneCmd, $catcon_DisableLockdown,
                        -1, undef, $catcon_GenKillSessScript,
                        $catcon_KillAllSessScript, \%catcon_InstProcMap, 
                        \%catcon_ProcInstMap, \%catcon_InstConnStr,
                        $catcon_Sqlplus)) {
      return 1;
    }

    log_msg_verbose("finished starting $catcon_NumProcesses processes");

    return 0;

  }


  #
  # catconBounceProcesses - bounce all processes
  # 
  # Returns
  #   1 if some unexpected error was encountered; 0 otherwise
  #
  sub catconBounceProcesses () {

    # catconInit2 had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return 1;
    }

    if ($catcon_DeadProc == -1) {
      log_msg_verbose("will bounce $catcon_NumProcesses processes");
    } else {
      log_msg_verbose("will replace dead process ".
                      "$catcon_DeadProc (id=$catcon_DeadProcId)");
    }

    # end processes
    end_processes(0, $catcon_NumProcesses - 1, @catcon_FileHandles, 
                  @catcon_ProcIds, $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG, 
                  $catcon_LogFilePathBase, $catcon_DeadProc, 
                  \%catcon_InstProcMap, \%catcon_ProcInstMap);

    if ($catcon_DeadProc == -1) {
      # delete the "kill all sessions script" since all processes it would 
      # try to kill are now gone
      sureunlink($catcon_KillAllSessScript);
      log_msg_debug("$catcon_KillAllSessScript was ".
                    "deleted because all processes listed in it have been ".
                    "ended");
    }

    #
    # Bug 22887047: we set SIG{CHLD} to 'IGNORE' in catconInit2, and that's 
    #   where we want to leave it since we will deal with any dead child 
    #   processes when we come across them in the course of trying to pick a 
    #   next process to do perform some task (next_proc())
    #

    # start processes
    if (start_processes($catcon_NumProcesses, $catcon_LogFilePathBase, 
                        @catcon_FileHandles, @catcon_ProcIds, 
                        @catcon_Containers, $catcon_Root,
                        @catcon_UserConnectString, 
                        $catcon_EchoOn, $catcon_ErrLogging, $catcon_LogLevel, 
                        0, (!$catcon_UserScript && !$catcon_NoOracleScript), 
                        $catcon_FedRoot, 
                        $catcon_DoneCmd, $catcon_DisableLockdown,
                        $catcon_DeadProc, $catcon_DeadProcId,
                        $catcon_GenKillSessScript, 
                        $catcon_KillAllSessScript, \%catcon_InstProcMap, 
                        \%catcon_ProcInstMap, \%catcon_InstConnStr,
                        $catcon_Sqlplus)) {
      return 1;
    }

    if ($catcon_DeadProc == -1) {
      log_msg_verbose("finished bouncing $catcon_NumProcesses processes");
    } else {
      log_msg_verbose("finished replacing dead process ".
                      "$catcon_DeadProc (id=$catcon_DeadProcId)");
    }

    return 0;
  }

  #
  # bounce a process that died unexpectedly
  #
  # Parameters:
  # - index into catcon_ProcIds of the process that needs bouncing
  #
  sub catconBounceDeadProcess ($) {
    my ($deadProc) = @_;

    # remember that we need to bounce a dead process and save its id so we 
    # can produce a warning message in start_processes when we start a 
    # replacement process
    $catcon_DeadProc = $deadProc;
    $catcon_DeadProcId = $catcon_ProcIds[$deadProc];

    my $ret = catconBounceProcesses();

    # attempt to bounce the dead process has been made (successfully or 
    # otherwise)
    $catcon_DeadProc = -1;
    undef $catcon_DeadProcId;

    return ($ret) ? 1 : 0;
  }

  #
  # catconWrapUp - free any resources which may have been allocated by 
  #                various catcon.pl subroutines
  # 
  # Returns
  #   1 if some unexpected error was encountered; 0 otherwise
  #
  sub catconWrapUp () {

    # catconInit2 had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return 1;
    }

    log_msg_verbose("(PID=$$) about to free up all resources");


    my $ps;
    for ($ps = 0; $ps <= $catcon_NumProcesses - 1; $ps++) {
      if ($catcon_FileHandles[$ps]) {
          print {$catcon_FileHandles[$ps]} "PROMPT ========== PROCESS ENDED ==========\n";
      }
    }

    # end processes
    end_processes(0, $catcon_NumProcesses - 1, @catcon_FileHandles, 
                  @catcon_ProcIds, $catcon_LogLevel == CATCON_LOG_LEVEL_DEBUG, 
                  $catcon_LogFilePathBase, -1, \%catcon_InstProcMap, 
                  \%catcon_ProcInstMap);

    # If we were using multiple RAC instances to run scripts or statements, 
    # having ended processes, get rid of log files which corresponded to 
    # processes which didn't get to execute any statements or scripts
    if (catconUsingMultipleInstances()) {
      delete_idle_logs($catcon_NumProcesses, \@catcon_FileHandles, 
                       \@catcon_ActiveProcesses, $catcon_LogFilePathBase);
    }
    
    # delete the "kill all sessions script" since all processes it would try 
    # to kill are now gone
    sureunlink($catcon_KillAllSessScript);

    # if we reopened PDBs in modes specified by the caller in catconExec(), 
    # revert them to their original modes, unless the caller has explicitly 
    # instructed us to not do it 
    if (!$catcon_SkipRevertingPdbModes) {
      catconRevertPdbModes();
    } else {
      # If we had to change mode in which some PDBs were open before trying 
      # to run scripts on them, "forget" that information in case the caller 
      # decides to invoke catconInit2 again
      if (%catcon_RevertSeedPdbMode) {
        undef %catcon_RevertSeedPdbMode;
      }

      if (%catcon_RevertUserPdbModes) {
        undef %catcon_RevertUserPdbModes;
      }
    }

    # if one or more RAC instances were started, they need to be stopped
    # we wait for PDBs which may have been opened by us on those instances 
    # to be closed before stopping such instances
    if (@catcon_IdleRacInstances && $#catcon_IdleRacInstances >= 0) {
      log_msg_debug("call alter_rac_instance_state to stop instances ".
                    "which were started by us");
      if (alter_rac_instance_state($catcon_DbUniqueName, 
                                   \@catcon_IdleRacInstances, 0)) {
        log_msg_error("unexpected error in alter_rac_instance_state");

        # undef @catcon_IdleRacInstances so the code in the END block does 
        # not try to stop these instances again
        undef @catcon_IdleRacInstances;

        return 1;
      } else {
        log_msg_debug("all instances which were started by us were ".
                      "successfully stopped");

        # undef @catcon_IdleRacInstances so the code in the END block does 
        # not try to stop these instances again
        undef @catcon_IdleRacInstances;
      }
    }
    
    # restore signal handlers which were reset in catconInit2
    # NOTE: if, for example, $SIG{CHLD} existed but was not defined in 
    #       catconInit2, I would have liked to undef $SIG{CHLD} here, but that 
    #       results in "Use of uninitialized value in scalar assignment" error,
    #       so I was forced to delete the $SIG{} element instead

    if ((exists $catcon_SaveSig{CHLD}) && (defined $catcon_SaveSig{CHLD})) {
      $SIG{CHLD}  = $catcon_SaveSig{CHLD};
    } else {
      delete $SIG{CHLD};
    }

    if ((exists $catcon_SaveSig{INT}) && (defined $catcon_SaveSig{INT})) {
      $SIG{INT}  = $catcon_SaveSig{INT};
    } else {
      delete $SIG{INT};
    }

    if ((exists $catcon_SaveSig{TERM}) && (defined $catcon_SaveSig{TERM})) {
      $SIG{TERM}  = $catcon_SaveSig{TERM};
    } else {
      delete $SIG{TERM};
    }

    if ((exists $catcon_SaveSig{QUIT}) && (defined $catcon_SaveSig{QUIT})) {
      $SIG{QUIT}  = $catcon_SaveSig{QUIT};
    } else {
      delete $SIG{QUIT};
    }

    # no catcon* subroutines should be invoked without first calling 
    # catconInit2
    $catcon_InitDone = 0;

    log_msg_verbose("done");

    # bug 26238195: close catcon log file handle
    close ($CATCONOUT);
    undef $CATCONOUT;

    return 0;
  }

  #
  # catconIsCDB - return an indicator of whether the database to which we are 
  # connected is a CDB
  #
  sub catconIsCDB () {

    # catconInit2 had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return undef;
    }

    if (@catcon_AllContainers) {
      return 1;
    } else {
      return 0;
    }
  }

  #
  # catconGetConNames - return an array of Container names if connected to a 
  #                     CDB
  #
  sub catconGetConNames () {

    # catconInit2 had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return undef;
    }

    return @catcon_AllContainers;
  }

  #
  # catconQuery - run a query supplied by the caller 
  #
  # Parameters:
  #   - query to run (IN)
  #     NOTE: query needs to start with "select" with nothing preceding it.  
  #           Failure to do so will cause the function to return no results
  #   - name of PDB, if any, in which to run the query.  If not specified, 
  #     query will be run in CDB$ROOT.
  #
  # Returns:
  #   Output of the query.
  #
  sub catconQuery($$) {
    my ($query, $pdb) = @_;

    my $pdbNameString = $pdb ? $pdb : "unspecified";
    log_msg_debug <<catconQuery_DEBUG;
running catconQuery(
  query = $query, 
  pdb   = $pdbNameString)
catconQuery_DEBUG

    # catconInit2 had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return undef;
    }

    # each row returned by the query needs to start with the "marker" 
    # (C:A:T:C:O:N) which identifies rows returned by the query (as opposed 
    # to various rows produced by SQL*PLus), so we replace "select" which 
    # start the query with "select 'C:A:T:C:O:N' ||"
    #
    # NOTE: PLEASE NOTIFY THE UPGRADE GROUP IF THIS TAG 'C:A:T:C:O:N' CHANGES.
    #       Upgrade is using the tag to support read only tablespaces.
    #       The tag is used in conjunction with a sql with clause.
    #       If we do not add the correct tag to the with clause
    #       the parsing of the return data will fail.
    #
    $query =~ s/^select/select 'C:A:T:C:O:N' ||/i;

    # If the DB is running on a single instance, we need to connect to the 
    # default instance using the internal connect string.  
    # However, if the caller supplied a PDB name and the CDB runs on 
    # multiple RAC instances, the specified PDB may not be open on the 
    # default instance so we need to generate a connect string that would 
    # take us to the instance where the PDB is open
    my $connStr = $catcon_InternalConnectString[0];

    # if the caller supplied a PDB name, verify that the specified PDB exists
    # and is open
    if ($pdb) {
      # make sure only one PDB name was specified
      my @PdbNameArr = split(' ', $pdb);

      if ($#PdbNameArr != 0) {
        log_msg_error("exactly one PDB name can be specified");
        return undef;
      }

      # make sure we are connected to a CDB
      if (!catconIsCDB()) {
        log_msg_error("PDB name was specified while connected to a non-CDB");
        return undef;
      }

      # make sure specified name does not refer to the Root
      if ((uc $PdbNameArr[0]) eq (uc $catcon_Root)) {
        log_msg_error("specified PDB name may not refer to the Root");
        return undef;
      }

      if (!(@catcon_Containers = 
            validate_con_names($pdb, 0, @catcon_AllContainers, 
                \%catcon_IsConOpen, 
                0, # do not ignore non-existent or closed PDBs
                # Ignore all PDBs
                $catcon_IgnoreAllInaccessiblePDBs))) { 
                
        log_msg_error($pdb." does not refer to an existing and open PDB");
        return undef;
      } else {
        log_msg_debug("verified that PDB $pdb exists and is open (on some ".
                      "instance)");
      }

      # if the CDB is running on a single instance, we should be able to use 
      # $catcon_InternalConnectString[0]; otherwise, obtain info about modes 
      # in which the PDB is open on various instances and construct a connect 
      # string to take us to an instance where the PDB is open
      if ((scalar keys %catcon_InstConnStr) > 1) {
        my $doneFileNamePrefix = 
          done_file_name_prefix($catcon_LogFilePathBase, 
                                $catcon_ProcIds[0]."_catconQuery");

        my $currPdbModeInfo = 
          curr_pdb_mode_info(@catcon_InternalConnectString, $pdb, 
                             $catcon_DoneCmd, $doneFileNamePrefix, 
                             $catcon_Sqlplus);
        if (! (defined $currPdbModeInfo)) {
          log_msg_error("unexpected error in curr_pdb_mode_info");
          return undef;
        }

        # find an instance on which the PDB is open 
        my $found = 0;

        foreach my $inst (sort keys %$currPdbModeInfo) {
          # mode and restricted flag
          my @modeAndRestr = split(' ', $currPdbModeInfo->{$inst});

          # mode in which the PDB is open (or not)
          my $currMode = $modeAndRestr[0];

          if ($currMode != CATCON_PDB_MODE_MOUNTED) {
            # $pdb is open in some mode on $inst.  We don't care in which 
            # mode it is open, just as long as it is open.
            $found = 1;

            # connect string that will be used to connect to $inst
            $connStr = 
              get_inst_conn_string($catcon_InternalConnectString[0], 
                                   \%catcon_InstConnStr, $inst);

            # connect string with obfuscated password
            my $connStrDbg = 
              get_inst_conn_string($catcon_InternalConnectString[1], 
                                   \%catcon_InstConnStr, $inst);

            my $currModeString = PDB_MODE_CONST_TO_STRING->{$currMode};

            log_msg_debug <<msg;
will use connect string $connStrDbg to connect to PDB $pdb on 
  instance $inst where the PDB is open for $currModeString
msg
            last;
          }
        }

        if (!$found) {
          log_msg_error("PDB $pdb is not open on any instance");
          return undef;
        }
      } else {
        log_msg_debug("CDB runs on 1 instance - use the internal connect ".
                      "string");
      }
    }

    my @statements = (
      "connect $connStr\n".
      "set echo off\n",
      "set heading off\n",
    );

    # if the caller supplied a PDB name, add 
    #   ALTER SESSION SET CONTAINER = <PDB name>
    if ($pdb) {
      # in case $pdb refers to an App Root Clone, we need to set 
      # _ORACLE_SCRIPT to true before issuing SET CONTAINER and clear it 
      # immediately thereafter
      push @statements, qq#alter session set "_oracle_script"=TRUE\n/\n#;
      push @statements, "alter session set container=".$pdb."\n/\n";
      push @statements, qq#alter session set "_oracle_script"=FALSE\n/\n#;
    }

    # finally, add the query
    push @statements, "$query\n/\n";

    # Bug 18011217: append _catcon_$catcon_ProcIds[0] to  
    # $catcon_LogFilePathBase to avoid conflicts with other catcon processes 
    # running on the same host
    my ($Out_ref, $Spool_ref) = 
      exec_DB_script(@statements, "C:A:T:C:O:N", $catcon_DoneCmd, 
                     done_file_name_prefix($catcon_LogFilePathBase,
                                           $catcon_ProcIds[0]),
                     $catcon_Sqlplus);
    log_msg_debug("returning ".($#$Out_ref+1)." rows {");

    foreach (@$Out_ref) {
      log_msg_debug("\t$_");
    }

    log_msg_debug("}");

    return @$Out_ref;
  }

  #
  # catconUserPass - return password used when running user scripts or 
  #                  statements
  #
  # Parameters:
  #   - None
  #
  sub catconUserPass() {
      
    # catconInit2 had better been invoked
    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return undef;
    }

    return $catcon_UserPass;
  }

  #
  # catconSkipRevertingPdbModes - set a flag that tells catcon whether to 
  # revert modes in which PDbs are opened
  #
  # Parameters:
  #   $doNotRevert (IN) - 
  #     a flag indicating whether to revert PDB modes
  #
  sub catconSkipRevertingPdbModes($) {
    my ($doNotRevert) = @_;

    $catcon_SkipRevertingPdbModes = $doNotRevert;
  }

  # return tag for the environment variable containing password for a user 
  # connect string
  sub catconGetUsrPasswdEnvTag () {
    return &USER_PASSWD_ENV_TAG;
  }

  # return tag for the environment variable containing password for the 
  # internal connect string
  sub catconGetIntPasswdEnvTag () {
    return &INTERNAL_PASSWD_ENV_TAG;
  }

  sub catcon_HandleSigINT () {
    log_msg_info("Signal INT was received.");

    # Bug 18488530: END block (which gets called when we call die) will take 
    # care of resetting PDB$SEED's mode

    # ignore signals that may interrupt our signal handling code
    $SIG{INT} = 'IGNORE';
    $SIG{TERM} = 'IGNORE';
    $SIG{QUIT} = 'IGNORE';

    die;  
  }

  sub catcon_HandleSigTERM () {
    log_msg_info("Signal TERM was received.");

    # Bug 18488530: END block (which gets called when we call die) will take 
    # care of resetting PDB$SEED's mode

    # ignore signals that may interrupt our signal handling code
    $SIG{INT} = 'IGNORE';
    $SIG{TERM} = 'IGNORE';
    $SIG{QUIT} = 'IGNORE';

    die;  
  }

  sub catcon_HandleSigQUIT () {
    log_msg_info("Signal QUIT was received.");

    # Bug 18488530: END block (which gets called when we call die) will take 
    # care of resetting PDB$SEED's mode

    # ignore signals that may interrupt our signal handling code
    $SIG{INT} = 'IGNORE';
    $SIG{TERM} = 'IGNORE';
    $SIG{QUIT} = 'IGNORE';

    die;  
  }

  # In addition to being called from catconWrapUp, this subroutine should be 
  # invoked as a part of handling SIGINT to ensure that PDBs get reverted to
  # modes in which they were open before catcon started manipulating it. 
  # assembled above
  #
  # A call to this function should be added to the END block to ensure that 
  # PDB modes get restored after die is invoked.
  sub catconRevertPdbModes() {
    # if catconInit2 was not run (ever or after last invocation of 
    # catconWrapup) or we are not connected to a CDB, there is nothing to do
    if (!$catcon_InitDone || !catconIsCDB()) {
      return;
    }

    # if we reopened PDB$SEED in a mode specified by the caller in 
    # catconExec(), revert it to the original mode
    #
    # NOTE: normally, we need to wait for all processes to be killed before 
    #       calling reset_pdb_modes() (because it closes PDBs before reopening 
    #       them in desired mode, and if any process is connected to such PDB
    #       while we are closing it, ALTER PDB CLOSE will hang), but if catcon 
    #       process itself is getting killed, there is no room for such 
    #       niceties.
    if (%catcon_RevertSeedPdbMode) {
      # Bug 18011217: append _catcon_$$_revertPdbModes_seed_pdb to 
      # $catcon_LogFilePathBase to avoid conflicts with other catcon 
      # processes running on the same host or with the subsequent call to 
      # reset_pdb_modes() or with calls from force_pdb_modes
      my $ret = 
        reset_pdb_modes(\@catcon_InternalConnectString,
                        \%catcon_RevertSeedPdbMode, $catcon_DoneCmd, 
                        done_file_name_prefix($catcon_LogFilePathBase, 
                                              $$."_revertPdbModes_seed_pdb"),
                        1, $catcon_DbmsVersion, 0, undef, \%catcon_InstConnStr,
                        $catcon_Sqlplus, undef, 0);
    
      if ($ret == 1) {
        log_msg_error("unexpected error trying to reopen ".
                      "PDB\$SEED in original mode");
        # not returning error code since we are wrapping things up
      } elsif ($ret == 0) {
        log_msg_debug("reverted PDB\$SEED to original mode");
      } else {
            log_msg_debug <<msg;
PDB\$SEED could NOT be reopened in original mode
    because it would conflict with the mode in which the CDB is open
    (this should never happen because that was the mode in which it was open 
    when catcon was called)
msg
      }

      undef %catcon_RevertSeedPdbMode;
    } else {
      log_msg_debug("catcon_RevertSeedPdbMode was not set");
    }

    # ditto for user PDBs
    #
    # NOTE: if running Oracle scripts, reset_pdb_modes needs to set 
    #       _ORACLE_SCRIPT because it may end up changing mode of an App Root 
    #       Clone (which cannot be done unless _ORACLE_SCRIPT is set.) User 
    #       scripts should not be run in App Root Clones, so we don't really 
    #       want reset_pdb_modes to reopen them before running such scripts
    if (%catcon_RevertUserPdbModes) {
      my $ret = 
        reset_pdb_modes(\@catcon_InternalConnectString,
                        \%catcon_RevertUserPdbModes, $catcon_DoneCmd, 
                        done_file_name_prefix($catcon_LogFilePathBase, 
                                              $$."_revertPdbModes_user_pdbs"),
                        !$catcon_UserScript, $catcon_DbmsVersion, 0, undef,
                        \%catcon_InstConnStr, $catcon_Sqlplus,
                        \%catcon_AppRootCloneInfo, 0);
    
      if ($ret == 1) {
        log_msg_error("unexpected error trying to reopen ".
                      "user PDBs in original mode");
        # not returning error code since we are wrapping things up
      } elsif ($ret == 0) {
        log_msg_debug("reverted user PDBs to original mode");
      } else {
        log_msg_debug <<msg;
user PDBs could NOT be reopened in original modes
    because it would conflict with the mode in which the CDB is open
    (this should never happen because those were the modes in which they 
     were open when catcon was called)
msg
      }

      undef %catcon_RevertUserPdbModes;
    } else {
      log_msg_debug("catcon_RevertUserPdbModes was not set");
    }
  }

  #
  # catconSqlplus - run a SQL*Plus script supplied by the caller.
  #
  # Parameters:
  #   - a reference to a list of statements (i.e. a script) to execute; 
  #     the script needs to include CONNECT and/or SET CONTAINER 
  #     statements to get to the container in which statements need to be 
  #     executed
  #   - base for a name of a file which will be created to indicate that the 
  #     script has completed
  #
  # Returns:
  #   none
  #
  sub catconSqlplus(\@$) {
    my ($script, $DoneFilePathBase) = @_;

    my $isWindows; # are we running on Windows?

    # command which exec_DB_script will write to SQL*Plus so it would 
    # generate a "done" file (signalling to exec_DB_script that the script 
    # has completed)
    my $doneCmd;   

    # determine doneCmd appropriate to the OS on which we are running
    os_dependent_stuff($isWindows, $doneCmd, $catcon_Sqlplus);

    # NOTE: appending process id to $DoneFilePathBase to avoid conflicts with 
    #       other processes running on the same host
    my ($Out_ref, $Spool_ref) = 
      exec_DB_script(@$script, undef, $doneCmd, 
                     done_file_name_prefix($DoneFilePathBase, $PID),
                     $catcon_Sqlplus);
    return;
  }

  # 
  # set_catcon_InvokeFrom - set mode whether we are running catcon or rman 
  #
  # Parameters:
  #   - mode, 1 indicates running in catcon mode, 0 indicates running in rman
  #     mode, set to 1 by default; 
  sub set_catcon_InvokeFrom($) {
    my ($mode) = @_;

    if (($mode == CATCON_INVOKEFROM_CATCON) || 
        ($mode == CATCON_INVOKEFROM_RMAN)) {
      $catcon_InvokeFrom = $mode;
    }
    else {
      $catcon_InvokeFrom = CATCON_INVOKEFROM_CATCON; 
      print STDERR 
            "set mode to CATCON_INVOKEFROM_CATCON by default\n";
      return 1;
    }
    return 0;
  }

  # catconImportRmanVariables - import varibles from rman.pm, since
  # catcon utility functions are called from rman 
  #
  # Parameters:
  #   - RMAN OUPUT file handle, this is to pass to log_msg for log output 
  #   - Debug Flag 
  sub catconImportRmanVariables($$) {
    my($handle, $debugp) = @_;

    if (defined $handle) {
      $RMANOUT = $handle;
    }

    # if caller requested that we display messages with log level >= DEBUG, 
    # set the log level accordingly
    #
    # if catconVerbose has been called before this to set catcon 
    # log level to VERBOSE, we will override it (since DEBUG log level is 
    # lower and will cover messages which would be displayed at VERBOSE 
    # level + it will be backward compatible), but if neither --verbose nor 
    # --diag was specified, we will default log level to INFO
    if ($debugp) {
      $catcon_LogLevel = CATCON_LOG_LEVEL_DEBUG;
    } else {
      # by default, set log level to INFO
      $catcon_LogLevel = CATCON_LOG_LEVEL_INFO;
    }

    # having set $catcon_LogLevel, we need to determine whether the caller has 
    # set $CATCON_DIAG_MSG_BUF_SIZE to override default size of 
    # @catcon_DiagMsgs circular buffer
    if (defined $ENV{CATCON_DIAG_MSG_BUF_SIZE}) {
      my $bufSize = $ENV{CATCON_DIAG_MSG_BUF_SIZE};
      
      # get rid of leading/trailing blanks
      $bufSize =~ s/^\s+|\s+$//g;

      if ($bufSize == 0 || $bufSize =~ /^[1-9][0-9]+$/) {
        # override default size of @catcon_DiagMsgs buffer
        $catcon_DiagMsgsSize = $bufSize;
        log_msg_debug("will retain last $catcon_DiagMsgsSize log messages");
      } elsif (uc($bufSize) eq 'UNLIMITED') {
        # @catcon_DiagMsgs will be used to store all messages
        undef $catcon_DiagMsgsSize;
        log_msg_debug("will retain last ALL log messages");
      } else {
        log_msg_warn("unexpected value ($ENV{CATCON_DIAG_MSG_BUF_SIZE}) ".
                     "found in CATCON_DIAG_MSG_BUF_SIZE env var; will ".
                     "retain default value ($catcon_DiagMsgsSize)");
      }
    } else {
      log_msg_debug("will retain last $catcon_DiagMsgsSize log messages by ".
                    "default");
    }
  }

  # catconGroupByUpgradeLevel - group Containers whose names were supplied 
  #                             by the caller based on their UPGRADE_LEVEL
  #
  # Parameters:
  #  $conNames_ref (IN) - 
  #    reference to an array of Container names
  #  $conNamesByUpgLvl_ref (OUT) -
  #    reference to an array of references to arrays of names of Container 
  #    grouped by their UPGRADE_LEVEL (i.e. $conNamesByUpgLvl_ref->[N] yields 
  #    a reference to an array of name of Containers whose UPGRADE_LEVEL is N)
  #
  # NOTE: legitimate upgrade levels start with 1, so if v$containers 
  #       includes UPGRADE_LEVEL column, $conNamesByUpgLvl_ref->[0] will not 
  #       be populated while some of the other elements of 
  #       @$conNamesByUpgLvl_ref will contain references to arrays of 
  #       container names; otherwise, $conNamesByUpgLvl_ref->[0] will be set 
  #       to $conNames_ref
  sub catconGroupByUpgradeLevel($$) {
    my($conNames_ref, $conNamesByUpgLvl_ref) = @_;

    my $Spool_ref;

    # statements to determine whether V$CONTAINERS contains UPGRADE_LEVEL 
    # column
    my @UpgLvlColExistsStmts = (
      "connect ".$catcon_InternalConnectString[0]."\n",
      "set echo off\n",
      "set heading off\n",
      "select \'C:A:T:C:O:N\' || count(*) from sys.dba_tab_columns ".
      "  where owner='SYS' and table_name = 'V_\$CONTAINERS' ".
      "    and column_name= 'UPGRADE_LEVEL'\n/\n",
    );

    my $upgLvlColCnt_ref;

    ($upgLvlColCnt_ref, $Spool_ref) = 
      exec_DB_script(@UpgLvlColExistsStmts, "C:A:T:C:O:N", 
                     $catcon_DoneCmd, 
                     done_file_name_prefix($catcon_LogFilePathBase, $$), 
                     $catcon_Sqlplus);

    if (!@$upgLvlColCnt_ref || $#$upgLvlColCnt_ref != 0) {
      # count could not be obtained
      print_exec_DB_script_output("catconGroupByUpgradeLevel(1)", 
                                  $Spool_ref, 1);
    
      return 1;
    }
    
    if ($$upgLvlColCnt_ref[0] eq "0") {
      # V$CONTAINERS does not include UPGRADE_LEVEL column - lump all 
      # Containers supplied by the caller into one group which does NOT 
      # corespond to a legitimate Upgrade Level
      log_msg_debug("V\$CONTAINERS.UPGRADE_LEVEL does not exist - lump all ".
                    "Containers into a single group");
      $conNamesByUpgLvl_ref->[0] = $conNames_ref;
      return 0;
    }

    my @GetUpgLvlStmts = (
      "connect ".$catcon_InternalConnectString[0]."\n",
      "set echo off\n",
      "set heading off\n",
      "set lines 9999\n",
      "select \'C:A:T:C:O:N\' || name || ' ' || upgrade_level ".
      "  from v\$containers \n/\n",
    );

    log_msg_debug("V\$CONTAINERS.UPGRADE_LEVEL exists - use it to group ".
                  "Containers");

    # each row consists of a Container name and UPGRADE_LEVEL
    my $rows_ref;

    ($rows_ref, $Spool_ref) = 
    exec_DB_script(@GetUpgLvlStmts, "C:A:T:C:O:N", 
                   $catcon_DoneCmd, 
                   done_file_name_prefix($catcon_LogFilePathBase, $$), 
                   $catcon_Sqlplus);

    if (!@$rows_ref || $#$rows_ref < 0) {
      # UPGRADE_LEVEL for Containrs could not be obtained
      print_exec_DB_script_output("catconGroupByUpgradeLevel(2)", $Spool_ref, 
                                  1);
    
      return 1;
    }

    # hash mapping  names of Containers to their UPGRADE_LEVEL
    my %conUpgLvlMap;

    # split each row into a Container name and Upgrade Level and use it to 
    # populate %conUpgLvlMap
    for my $row ( @$rows_ref ) {
      my ($conName, $upgLvl) = split /\s+/, $row;
      $conUpgLvlMap{$conName} = $upgLvl;
    }

    # finally, populate $conNamesByUpgLvl_ref
    foreach my $conName (@$conNames_ref) {
      if (! exists $conUpgLvlMap{$conName}) {
        log_msg_error("Container $conName specified by the caller does not ".
                      "exist");
        return 1;
      }

      # Upgrade Level of Container $conName
      my $upgLvl = $conUpgLvlMap{$conName};

      log_msg_debug("Add $conName to the array of names of Containers with ".
                    "UPGRADE_LEVEL = $upgLvl");
      if (!$conNamesByUpgLvl_ref->[$upgLvl]) {
        log_msg_debug("$conName is the first Container with UPGRADE_LEVEL = ".
                      "$upgLvl");
        $conNamesByUpgLvl_ref->[$upgLvl] = [ $conName ];
      } else {
        push @{$conNamesByUpgLvl_ref->[$upgLvl]}, $conName;
      }
    }
    
    for (my $upgLvl = 0; $upgLvl <= $#$conNamesByUpgLvl_ref; $upgLvl++) {
      if (!$conNamesByUpgLvl_ref->[$upgLvl]) {
        log_msg_debug("no PDBs with UPGRADE_LEVEL of $upgLvl were found");
        next;
      }
      
      log_msg_debug((scalar @{$conNamesByUpgLvl_ref->[$upgLvl]}).
                    " PDBs with UPGRADE_LEVEL of $upgLvl were found:".
                    join("\n\t", @{$conNamesByUpgLvl_ref->[$upgLvl]}));
    }

    return 0;
  }

  # values that may be returned by catconPdbType
  use constant CATCON_PDB_TYPE_APP_ROOT        => 1;
  use constant CATCON_PDB_TYPE_APP_ROOT_CLONE  => 2;
  use constant CATCON_PDB_TYPE_APP_PDB         => 3;
  use constant CATCON_PDB_TYPE_NON_APP_PDB     => 4;

  # catconPdbType - provide caller with an indicator of the type of a PDB 
  #   whose name was supplied
  #
  # Parameters:
  #   $pdbName (IN) - name of a PDB whose type is to be determined
  #
  # Returns:
  #   One of CATCON_PDB_TYPE_* constants
  sub catconPdbType($) {
    my ($pdbName) = @_;

    if (!$catcon_InitDone) {
      log_msg_error("catconInit2 has not been run");
      return undef;
    }

    if (! defined $pdbName) {
      log_msg_error("pdbName was not defined");
      return undef;
    }

    if (!exists $catcon_IsConOpen{$pdbName}) {
      log_msg_error("Specified container $pdbName does not exist in the DB");
      return undef;
    }

    if (%catcon_AppRootInfo) {
      if (exists $catcon_AppRootInfo{$pdbName}) {
        log_msg_debug("$pdbName is an App Root");
        return CATCON_PDB_TYPE_APP_ROOT;
      } else {
        log_msg_debug("$pdbName was not among keys of catcon_AppRootInfo, ".
                      "so it is not an App Root");
      }
    } else {
      log_msg_debug("catcon_AppRootInfo is not initialized, meaning that ".
                    "the database contains no App Roots");
    }

    if (%catcon_AppRootCloneInfo) { 
      if (exists $catcon_AppRootCloneInfo{$pdbName}) {
        log_msg_debug("$pdbName is an App Root Clone");
        return CATCON_PDB_TYPE_APP_ROOT_CLONE;
      } else {
        log_msg_debug("$pdbName was not among keys of ".
                      "catcon_AppRootCloneInfo, so it is not an App Root ".
                      "Clone");
      }
    } else {
      log_msg_debug("catcon_AppRootCloneInfo is not initialized, meaning ".
                    "that the database contains no App Root Clones");
    }

    if (%catcon_AppPdbInfo) {
      if (exists $catcon_AppPdbInfo{$pdbName}) {
        log_msg_debug("$pdbName is an App PDB");
        return CATCON_PDB_TYPE_APP_PDB;
      } else {
        log_msg_debug("$pdbName was not among keys of ".
                      "catcon_AppPdbInfo, so it is not an App PDB");
      }
    } else {
      log_msg_debug("catcon_AppPdbInfo is not initialized, meaning ".
                    "that the database contains no App PDBs");
    }

    # must be a non-App PDB
    log_msg_debug("$pdbName is a non-App PDB");
    return CATCON_PDB_TYPE_NON_APP_PDB;
  }

  END {
    # rman.pl will just end here
    if ($catcon_InvokeFrom == CATCON_INVOKEFROM_RMAN)
    {
       exit (0);
    }

    # ignore signals that may interrupt our signal handling code
    $SIG{INT} = 'IGNORE';
    $SIG{TERM} = 'IGNORE';
    $SIG{QUIT} = 'IGNORE';

    # Bug 21871308: if Ctrl-C was hit after we started one or more processes, 
    #   ensure that they all die gracefully, releasing all resources
    if ($catcon_KillAllSessScript && (-e $catcon_KillAllSessScript)) {
      kill_sqlplus_sessions(@catcon_InternalConnectString, 
                            $catcon_KillAllSessScript,
                            $catcon_DoneCmd, 
                            done_file_name_prefix($catcon_LogFilePathBase, 
                                                  $$),
                            $catcon_Sqlplus);
    }

    # If we were using multiple RAC instances to run scripts or statements, 
    # having ended processes, get rid of log files which corresponded to 
    # processes which didn't get to execute any statements or scripts unless 
    # it was already done in catconWrapup
    if ($catcon_NumProcesses && $catcon_InitDone && 
        catconUsingMultipleInstances()) {
      delete_idle_logs($catcon_NumProcesses, \@catcon_FileHandles, 
                       \@catcon_ActiveProcesses, $catcon_LogFilePathBase);
    }

    # Bug 18488530: make sure PDB modes gets reverted before catcon process 
    # dies, unless the caller has explicitly instructed us to not do it 
    if (!$catcon_SkipRevertingPdbModes) {
      catconRevertPdbModes();
    }

    # if one or more RAC instances were started, they need to be stopped
    # we wait for PDBs which ,may have been opened by us on those instances 
    # to be closed before stopping such instances
    if (@catcon_IdleRacInstances && $#catcon_IdleRacInstances >= 0) {
      log_msg_debug("call alter_rac_instance_state to stop instances ".
                    "which were started by us");
      if (alter_rac_instance_state($catcon_DbUniqueName, 
                                   \@catcon_IdleRacInstances, 0)) {
        log_msg_error("unexpected error in alter_rac_instance_state");
      } else {
        log_msg_debug("all instances which were started by us were ".
                      "successfully stopped");
      }
    }
  }
}

1;
