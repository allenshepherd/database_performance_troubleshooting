# $Header: rdbms/admin/catctl.pl /st_rdbms_18.0/3 2018/05/02 12:52:06 akruglik Exp $
#
# catctl.pl
# 
# Copyright (c) 2005, 2018, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      catctl.pl - Catalog Control Perl program
#
#    DESCRIPTION
#      This perl program processes sqlplus files and organizes
#      them for parallel processing based on annotations within
#      the files.
#
#      Below is the Basic Flow of upgrade.
#
#      Traditional Database
#
#         Run Database upgrade in parallel (-n option) passing in catupgrd.sql.
#             Minimum parallel SQL process count is 1.
#             Maximum parallel SQL process count is 8.
#             Default parallel SQL process count is 4.
#         Run Post Upgrade Procedure.
#
#         1)  The database must be first started in upgrade mode
#             by the database administrator.
#         2)  After the upgrade completes data patch will run
#             in upgrade mode, upgrade the dictionary if neccessary and
#             shutdown the database.
#         3)  The database is then restarted in restricted normal mode.
#         4)  Run data patch in normal mode and then run the post
#             upgrade procedure (catuppst.sql).
#         5)  Shutdown the database.
#
#      Multitenant Database (CDB)
#
#         Run Database upgrade in parallel (-n option) passing in catupgrd.sql.
#             Minimum parallel SQL process count is 1.
#             No Maximum parallel SQL process count.
#             Default parallel SQL process count is cpu_count.
#                 This is calculated by Number of Cpu's on your system.
#         Run Upgrade on CDB$ROOT.
#             The Maximum parallel SQL process count is 8.
#             If there are any errors in the CDB$ROOT upgrade the
#             entire upgrade process is stopped.
#         Run Upgrades in all the PDB's.
#             The number of PDB's that run together is calculated by
#             dividing the parallel SQL process count (-n option) by the
#             parallel PDB SQL process count (-N option).
#             -n Defaults to (cpu_count).
#             -N Defaults parallel PDB SQL process count to 2.
#
#             For example:
#             Assume a system with CPU_COUNT of 24.
#             Default with no parameters specified for -n or -N:
#                12  PDB's will be upgraded together (cpu_count/2)
#                 2  parallel SQL processes per pdb
#             User specifies -n 64 -N 4:
#                16  PDB's will be upgraded together (64/4)
#                 4  parallel SQL processes per pdb
#             User specifies -n 20 -N 2:
#                10  PDB's will be upgraded together (20/2)
#                 2  parallel SQL processes per PDB
#             User specifies -n 10 -N 4:
#                 2 PDBs will be upgraded together integer value of (10/4)
#                 4 parallel SQL processes per PDB
#             User specifies -N 1 without specifying -n:
#                24 PDBs will be upgraded together (cpu_count/1)
#                 1 SQL process per PDB
#             User specifies -n 20 without specifying -N:
#                10 PDBs will be upgraded together (20/2)
#                 2 SQL process per PDB
#
#         For the PDB$SEED only we will force the running of utlprp.sql.
#         The number of threads that run in utlprp.sql is set
#         equal to the value of -N (Maximum number of parallel SQL processes
#         to use per PDB during the upgrade).  This value is used to avoid
#         overloading the system.
#
#         If there are any errors in the upgrade the post
#         upgrade procedure will always run for that specific container.
#
#         The below steps occur when updating an entire CDB.
# 
#         1)  The database and its PDB's must be first started in upgrade mode
#             by the database adminstrator.
#         2)  After the upgrade of CDB$ROOT completes data patch will run
#             in upgrade mode, upgrade the CDB$ROOT dictionary if neccessary
#             and shutdown the database.
#         3)  The database is then restarted with CDB$ROOT opened in normal
#             mode.
#         4)  Post upgrade procedure (catuppst.sql) is run in CDB$ROOT.
#         5)  PDB's are re-opened in upgrade mode.
#         6)  Upgrade is performed on the PDB, data patch will run
#             in upgrade mode, upgrade the dictionary if neccessary
#             and shutdown the PDB.
#         7)  PDB is then re-opened in normal restricted mode.
#         8)  Data patch will run in normal mode and then the post upgrade
#             procedure (catuppst.sql) is run in PDB.
#         9)  Shutdown the PDB.
#         10) After the entire upgrade completes only the CDB$ROOT
#             will remain open in case database administrators
#             wish to bring up an upgraded PDB to run utlrp.
#
#         Support for upgrading specific PDB's.
#
#         Options 'c' and 'C' are used for this purpose.
#
#         -c = Inclusion list
# 
#         This specifies which PDB's you wish to upgrade.
#         For example:
#
#         -c 'PDB1 PDB2'
#
#         This example will upgrade PDB1 and PDB2 only.
#
#         -C = Exclusion list
#
#         This specifies which PDB's you wish to exclude from the upgrade.
#         For Example:
#
#         -C = 'CDB$ROOT PDB$SEED'
#
#         This example will upgrade all the PDB's except CDB$ROOT and
#         PDB$SEED.
#
#         The flow of this processing is the same as above depending
#         on what the list contains in it. Examples are as follows.
#
#         CDB$ROOT steps 1-4 are performed.
#         PDB$SEED steps 5-10 are performed.
#         CDB$ROOT and PDB$SEED steps 1-10 are performed.
#         CDB$ROOT and PDB$SEED and PDB steps 1-10 are performed.
#         CDB$ROOT and PDB steps 1-10 are performed.
#         PDB$SEED and PDB steps 5-10 are performed.
#         PDB steps 5-10 are performed.
#
#      Annotations are the following within a .sql file(s):
#
#      --CATCTL -S
#         Run Sql in Serial Mode one Process
#      --CATCTL -M
#         Run Sql in Multiple Processes
#      --CATFILE -X
#         Sql contains multiprocessing
#      --CATCTL -R
#         Bounce the Sql Process
#      --CATCTL -CS
#         Turns Compile Off (Defaults to on)
#      --CATCTL -CE
#         Turns Compile On
#      --CATCTL -SES
#         Session files for phases
#      --CATFILE -SESS
#         Start a new session for a given phase
#      --CATFILE -SESE
#         Ends a session phase
#      --CATCTL -PSE
#        Run Sql in Serial Mode for post upgrade
#        only executed in catctl.pl. Command  can
#        be replaced by nothing.sql depending on
#        the input parameters.
#      --CATCTL -PME
#        Run Sql in Parallel Mode for post upgrade
#        only executed in catctl.pl. Command  can
#        be replaced by nothing.sql depending on
#        the input parameters.
#      --CATCTL -SE
#        Run Sql in Serial Mode
#        only executed in catctl.pl
#      --CATCTL -ME
#        Run Sql in Parallel Mode for post upgrade
#        only executed in catctl.pl
#      --CATCTL -CP <CID>
#        Run the <CID>upgrd.sql upgrade script for component <CID> 
#        if it is in the db.
#      --CATCTL -CP <CID> -X
#        The top level <CID>upgrd.sql script contains --CATCTL annotations
#        Requires a <CID>upgrdses.sql script to run in each parallel process
#      --CATCTL -D "Description"
#        Phase Description
#
#      In order to keep Sql dependencies in check catctl.pl enforces phases.
#      A phase is bunch of Sql files that are loaded into the database in
#      parallel (using multiple Sql Processes) or serial (utilizing just one
#      Sql Process).  Each phase must complete before proceeding
#      to the next phase.
#
#    Default Logging Algorithm
#
#    1) Get Oracle Home
#       a) Run orahome image to get the Oracle Home.
#       b) If Oracle Home environmental variable is not present
#          Try two directories up from where catctl.pl is run to
#          derive the Oracle Home.
#       c) If Oracle Home still not found then we will look at the catctl
#          -d parameter.  If passed we try and derive it from this by going
#          up two directories from the -d parameter.
#       d) If Oracle Home still not present we will stop processing and ask
#          DBA to set the ORACLE_HOME enviromental variable.
#
#   2) Get the default directory to be used for logging.
#      a) Run the orabasehome image to get the Oracle Base Home.
#      b) If Oracle Base Home not present then run the
#         orabase image to get the Oracle Base Home.
#      c) If Oracle Base Home is not present then default log files to:
#         /tmp on Unix
#         TEMP environmental variable on Windows ie (C:\TEMP).
#
#   3) Get unique database name from the v$parameter table.
#         Use the database name to create the directory scheme.
#           orabase_home/cfgtoollogs/dbname/upgradeDateTime
#
#   4) User can override this default logging with the -l option in catctl.pl
#
#    Default Logging Search Algorithm
#
#    Search for Oracle Base home
#    if Found
#       Use orabase_home/cfgtoollogs/dbname/upgradeDateTime
#       otherwise use orabase_home/rdbms/log/cfgtoollogs/dbname/upgradeDateTime
#       otherwise use /tmp/cfgtoollogs/dbname/upgradeDateTime
#    otherwise
#       Use /tmp/cfgtoollogs/dbname/upgradeDateTime
#
#    NOTES
#      Connects to database specified by ORACLE_SID environment variable
#
#    MODIFIED   (MM/DD/YY)
#    akruglik    04/24/18 - backport changes from akruglik_catcon_on_rac_3
#    akruglik    01/25/18 - Bug 26634841: if upgrading a RAC CDB, do not append
#                           pdb names to log file name
#    akruglik    01/25/18 - pass names of multiple PDBs to catcon and let it
#                           assign them to different instances and upgrade them
#                           in parallel
#    raeburns    09/29/17 - Bug 26815460: use version_full for DIAG
#    akruglik    09/19/17 - Bug 26527096: group PDBs by UPGRADE_LEVEL
#    frealvar    07/15/17 - Bug 26194033 add datapatch error expression
#                           to catctlprepErrTblInsert
#    pjulsaks    08/28/17 - Bug 25578247: change get_prop to call in PDB
#    pjulsaks    08/28/17 - Bug 25777236: change PDB_UPGRADE_SYNC to counter
#    welin       08/18/17 - Bug 25046338: Output OS info to upgrade log
#    pyam        08/10/17 - Bug 26270025: replay upg: support for DBUA markers
#    hvieyra     07/27/17 - Fix for bug 26492762. Allow freshly created DB
#                           validation to act when emulating upgrade.
#    raeburns    07/03/17 - Bug 26255427: Remove dbms_registry_extended.pm
#    hvieyra     06/29/17 - lrg19723621: Allow override default behavior of not
#                           allowing run upgrade on a fresh created database on
#                           current release.
#    pyam        06/04/17 - Bug 25578235: support for replay upgrade
#    thbaby      05/30/17 - Bug 26145615: handle App Root Clone upgrade
#    frealvar    05/23/17 - Bug 26131477 remove stderr analysis due to
#                           noise in the output in catctlReviewDPExecution
#    welin       05/10/17 - bug 26031947: remove at the end of the sql
#                           statement so it will be execute twice at catcon
#    frealvar    05/03/17 - RTI 20261681 ignore empty strings in prepErrTblInsert
#    frealvar    04/24/17 - Bug 25671133 display datapatch errors in upg_summary
#    jerrede     04/14/17 - Bug 25742401 uninitialized variable when emulating
#    welin       02/03/17 - Bug 25371956: Include datapatch execution time in
#                           post upgrade status output
#    akruglik    12/16/16 - Bug 25243199: temporarily remove changes made to 
#                           fix bug 20193612
#    pyam        11/29/16 - 70732: pass upgrade flag to catcon
#    akruglik    11/17/16 - Bug 20193612: pass names of multiple PDBs to
#                           catcon and let it assign them to different
#                           instances and upgrade them in parallel
#    hvieyra     10/12/16 - Fix bug 24750231. Do not allow upgrade actions on a
#                           fresh legacy database.
#    jerrede     09/06/16 - Better handling of errors during PDB Upgrades
#    jerrede     06/29/16 - Fix Relative Path for catcon
#    hvieyra     06/27/16 - Fix bug 23201071. Avoid incomplete query build
#                           results.
#    hvieyra     06/20/16 - Fix bug 23065124. Do not allow upgrade actions on
#                           fresh release created pdbs.
#    frealvar    05/15/16 - Bug 23185218 Create a fresh pfile at the very end
#                           of the upgrade to capture any change before the
#                           db restart.
#    frealvar    05/09/16 - Bug23195290 wrong behavior using -L -c and pdb$seed
#    hvieyra     05/02/16 - Fix for bug 23145112. cdbroot open mode when
#                           simulating upgrade
#    frealvar    04/29/16 - Bug 23112322 if -c lists a pdb that does not exist
#                           in the db, then abort catctl.pl
#    frealvar    04/29/16 - Bug 23143447 printed inaccurately with -L parameter
#    hvieyra     04/14/16 - Fix for bug 23109809. Right message when upgrade
#                           restart from phase 0.
#    sursridh    04/13/16 - Bug 23020062: Disable PDB lockdown during upgrade.
#    hvieyra     04/12/16 - Fix for bug 23074468. Do not ignore error ORA-00001
#    bymotta     04/05/16 - Bug 23041298: Adding wrong parameter handling.
#    jerrede     03/31/16 - Allow catctl.pl to abort a current running upgrade
#    frealvar    03/08/16 - bug22826562  unable to run ./orahome
#    hvieyra     03/04/16 - Fix for bug 22815673. Corrects -R parameter behavior
#    			    on CDB with success and failed pdbs upgrades.
#    hvieyra     02/26/16 - Fix for bug 22708956- Exclude Datamining
#                           tablespaces from RO
#    surman      02/08/16 - 22359063: Support for XML descriptor in datapatch
#    jerrede     01/22/16 - Bug 22577957 Fix Display of priority number.
#                           catcon tag changes effected this.
#    hvieyra     12/14/15 - Fix for bug 22311039
#    jerrede     12/11/15 - Bug 22116552 Additional checking for stats during
#                           upgrade
#    bymotta     11/25/15 - Bug 22272138: adding /ade/b/4199531934/oracle/bin
#                           to path
#    jerrede     11/10/15 - Bug 22082379 Force Upgrade on PDB's
#                           when errors are found in CDB$ROOT.
#    jerrede     10/27/15 - Bug 22100998 Trying to close
#                           down Pdb when shutting down root.
#    jerrede     10/19/15 - Fix Bug 21917884 Add Datapatch support for user
#                           other than default authentication via upgrade
#    bymotta     10/13/15 - Bug: 21857235, uninitialized variables in
#                           catctlsetenvvars
#    jerrede     10/08/15 - Bug 21446778 PDB opens in parallel
#    jerrede     10/01/15 - Bug 21968834 Fix Read-Only Tablespaces Drop
#                           table done to early in upgrade
#    jerrede     09/22/15 - Make priority PDB's start at 1
#    frealvar    08/11/15 - bug21274752: Added two new tags to start and end
#                           sessions, added a function to optimize the
#                           session_files array and a message realocated from 
#                           catcon.pm to catctl.pl
#    jerrede     08/27/15 - Bug 21386584 catctl fails if -N is not passed
#                           for root upgrade and -n is set to 1.  
#                           Bug 21438133 Upgrade Log Naming Convention to
#                           preserve uniqueness
#    jerrede     08/26/15 - Add echo and set timings to read only tablespaces
#                           Fix 11 query for read only tables.  Failing
#                           because line is to long.
#    jerrede     07/17/15 - Add reference support for priority inclusion lists.
#    jerrede     07/02/15 - Add SQL Constant for user table spaces
#    raeburns    06/09/15 - LRG 16537610: Skip upgrade if file not in OH
#    jerrede     05/14/15 - Bug 21091219 support read only table spaces
#                           (-T) option removed (-t and -x) options
#                           no longer used.
#    hvieyra     05/11/15 - Auto Upgrade resume functionality - Bug fix 20688203
#    jerrede     04/29/15 - Bug 20969508 Ignore certain types of violations.
#                           than Sql Process count
#    jerrede     04/24/15 - Fix Bug 18906970. Add Default Processing for
#                           priority lists.
#    jerrede     04/22/15 - Bug 20936569 Only Delete Log files greater
#                           than Sql Process count
#    jerrede     03/18/15 - Add support for combinations of inclusion
#                           and exclusion lists with priority lists.
#    jerrede     03/10/15 - Bug 18877911 mandatory post upgrade
#    jerrede     03/09/15 - Simulate the run
#    jerrede     03/09/15 - Create priority lists
#    bymotta     03/04/15 - Bug 19171538 Integrating *nix/Windows CatCtl  
#			    wrapper and environment settings
#    raeburns    01/15/15 - add APEX upgrade
#                         - use cmp session scripts only for -X invocation
#    jerrede     01/13/15 - Calculate -n/-N to determine the total number
#                           of PDB upgrades.
#    raeburns    12/20/14 - Project 46656: enable SDO parallel upgrade
#                         - pass query to catconExec to conditionalize
#    raeburns    12/10/14 - Project 46657: add ORDIM parallel upgrade
#                         - run component session script automatically
#    jerrede     11/18/14 - Bug #19426592, Creating directories
#                           From Perl. Bug #20132912 Display exclusion
#                           list incorrectly.
#    jerrede     11/18/14 - Project #48820 Support Read-Only Oracle Home
#    jerrede     11/06/14 - Close pdb before we open it
#    jerrede     10/06/14 - Bug 19990037 Apply all Patches when post upgrade not
#                           run
#    jerrede     09/05/14 - Remove shutting down the PDBs before upgrading
#                           the root. We shutdown the PDBs by submitting an
#                           exclusion list to catconExec. This exclusion list
#                           contains CDB$ROOT. This indicates to shutdown all
#                           the PDBs except for CDB$ROOT. In the DBUA case,
#                           all the PDBs were already shutdown so the resulting
#                           container list on which to apply the shutdown
#                           was empty. This broke the DBUA when validating
#                           container names. The error returned by catconExec
#                           was 'Unexpected error' due to the fact that the
#                           list of PDBs returned by validate_con_names was
#                           empty. catconForce is supposed to override this
#                           condition but it does not.
#    akruglik    09/04/14 - Bug 19525627: change API of catconQuery to allow
#                           specification of the PDB in which to run the query
#    jerrede     08/22/14 - Use Constants for Build Version
#    surman      08/20/14 - 19409212: Quote root
#    jerrede     08/19/14 - Bug 19050649 Psu Fixes
#                           Enable strict warnings, Create stack trace on
#                           a crash and ensure that stderr is written to
#                           the log files, Display Start/End Times, Shutdown
#                           Pdb's when upgrading root, Ignore down pdb's
#                           correctly, Fix Inclusion and Exclusion list
#                           displays.
#    surman      08/08/14 - 19390567: Fix sqlpatch command
#    raeburns    07/29/14 - add component script invocation
#    surman      07/12/14 - 19178851: More library path variables
#    surman      07/10/14 - 19189317: Properly quote -pdbs
#    surman      06/17/14 - 18986292: Set LD_LIBRARY_PATH
#    jerrede     06/13/14 - Bug 18969473.
#                           Fix container name passing for Windows.
#    jerrede     06/02/14 - Only one upgrade allowed per database. To allow
#                           mutiple upgrades on separated databases at the
#                           same time prefix with an identifier.  Only one
#                           writer to summary report.
#    jerrede     05/27/14 - Bug 18790704 don't delete log files if this is a
#                           PDB Upgrade
#    jerrede     05/15/14 - Bug 18756451 Fix rerun of post upgrade when
#                           specifying phase after the pfile is created
#    surman      05/13/14 - 17277459: Call datapatch
#    jerrede     05/05/14 - Bug 18687127 Make sure root has been upgraded
#    jerrede     04/29/14 - When Parsing CDB lists ignore pdbs not in upgrade
#                           mode.  Also added additional checking for removing
#                           upgrade summary report.
#    jerrede     04/24/14 - Fix leaving PDB open when (-o) open mode specified 
#    jerrede     04/18/14 - Bug 18617421 Kick out Upgrade if CDB$ROOT not upgrade
#    jerrede     04/02/14 - Bug 18500239 Run utlprp in PDB$SEED
#    ewittenb    03/12/14 - fix bug 18363959
#    jerrede     03/11/14 - Bug 18369331 Open seed in read write restricted
#                           mode. Bug 18369292 Reorganize Total time display.
#    sankejai    03/11/14 - Bug 18348157: ignore ORA-24344 when opening PDB
#    jerrede     03/05/14 - Add catctl.pl tracing.
#    jerrede     02/27/14 - Bug 18321633 After upgrade bring up the seed in
#                           read only mode.
#    jerrede     02/26/14 - Bug 18309547 Add Grand total to the end of report
#    jerrede     02/12/14 - Bug 18247889 Add option to upgrade entire
#                           Multitenant database in upgrade mode.  Allow
#                           no user access until all the containers have
#                           been upgraded.
#    jerrede     01/30/14 - Bug 18160117 Incorrectly Parsing Exclusion lists
#    jerrede     01/27/14 - Upgrade seed and pdb's together
#    jerrede     01/22/14 - Bug 17898118: Set PDB$SEED read/write for
#                           post upgrade.
#    jerrede     01/21/14 - Fix Boolean Expression
#    jerrede     01/17/14 - Fix Bug 18071399 Add Post Upgrade Report Time
#    jerrede     01/10/14 - Fix lrg 11214367 Open Database even if we are not
#                           doing post upgrade for CDB
#    jerrede     01/08/14 - Fix bug 18044666 Summary Report not displayed
#    talliu      01/15/13 - 14223369: catconInit interface change
#    jerrede     10/16/13 - Instances of catctl.pl
#    jerrede     10/15/13 - Bug 17550069: Pass Gui Flag to catcon
#    jerrede     10/02/13 - Performance Improvements bug 17551016.
#    jerrede     08/19/13 - Fix Bug 17209379 Row Lock Issue when updating table
#                           using -t qualifier and lrg 9527629.
#    jerrede     07/17/13 - Lrg 9410354 Remove Execute Immediate alter session
#                           for setting cdb root
#    jerrede     06/24/13 - Root First Upgrade
#    jerrede     06/21/13 - Add Display Args
#    jerrede     04/23/13 - Rewritten to use common catcon routines.
#    jerrede     01/14/13 - XbranchMerge jerrede_bug-16097914 from
#                           st_rdbms_12.1.0.1	
#    jerrede     01/10/13 - Ignore sqlsessstart and sqlsessend in driver files
#    jerrede     12/11/12 - xbranchmerge of jerrede_lrg-7343558	
#    jerrede     11/30/12 - Add Clearer Error Messages	
#    jerrede     11/06/12 - Add Display option for patch group	
#    bmccarth    10/30/12 - call utlucdir	
#    jerrede     10/16/12 - Fix lrg 7284666	
#    jerrede     10/11/12 - Fix Security bug 14750812	
#    jerrede     10/03/12 - Fix lrg 7291461	
#    jerrede     08/28/12 - Mandatory Post upgrade.	
#    jerrede     07/19/12 - Remove Passing Password at Command Line	
#                           Use /n\/n as the SQL Terminator for all	
#                           Sql Statements	
#    jerrede     05/24/12 - Add Display of SQL File Executing	
#    jerrede     10/18/11 - Parallel Upgrade ntt Changes	
#    jerrede     09/12/11 - Fix Bug 12959399	
#    jerrede     09/01/11 - Parallel Upgrade Project no 23496	
#    rburns      10/23/07 - remove multiple processes; fix password mgmt
#    rburns      10/20/06 - add session script	
#    rburns      12/16/05 - perl script for parallel sqlplus processing 
#    rburns      12/16/05 - Creation
# 
#
######################################################################
# Include Package definitions 
######################################################################

use strict;
use warnings;
use English;
use Getopt::Std;             # To parse command line options
use threads;                 # Threads
use Cwd;                     # Get Current working directory
use File::Basename;          # Get Base File Name
use lib dirname (__FILE__);  # Add Dir Name of catctl.pl onto lib path
                             # So we can find catcon.pm in the event
                             # we are not running out of the same directory
use File::Spec;
use File::Path;              # Remove file path
use Fcntl qw(:flock);        # File Lock
use Carp qw(confess);        # For Stack trace
use Scalar::Util qw(looks_like_number);  #Verify number
use IPC::Open2;              # Perform 2-way communication with Sqlpatch

use catcon qw( catconInit
               catconExec
               catconWrapUp
               catconBounceProcesses
               catconRunSqlInEveryProcess
               catconShutdown
               catconIsCDB
               catconGetConNames
               catconQuery
               catconUpgForce
               catconSkipRevertingPdbModes
               catconUpgEndSessions
               catconUpgStartSessions
               catconUpgSetPdbOpen
               catconUserPass
               catconGetUsrPasswdEnvTag
               catconForce
               catconIgnoreErr
               catconDisableLockdown
               catconPdbMode
               catconUpgrade
               catconGroupByUpgradeLevel
               catconPdbType
               catconAllInst
               catconMultipleInstancesFeasible); #Common routines for cdb and upgrade


#
# Constants, generated from catconst.pm.pp
#
use catconst qw( CATCONST_BUILD_VERSION
                 CATCONST_BUILD_STATUS
                 CATCONST_BUILD_LABEL
                 CATCONST_MAXPDBS 
                 @AVAILABLE_CIDS );  

#
# POSIX class
#
use POSIX;

######################################################################
# Save Args before we process them
######################################################################
my $CATCTL_SUCCESS = 0;
my $CATCTL_ERROR   = 1;
my @gArgs;
my $gArgsNo = 0;

foreach $gArgsNo (0 .. $#ARGV)
{
  push (@gArgs, $ARGV[$gArgsNo]);
}


######################################################################
# Check Arg's
######################################################################
if (@ARGV < 1) {
    printUsage();
}

######################################################################
# 
# printUsage 
#
# Description: prints the command line syntax and exits.
#
# Parameters:
#   - None
######################################################################
sub printUsage {
  print STDERR <<USAGE;

  Usage: catctl [-c QuotedSpaceSeparatedInclusionListOfPDBs]
                [-C QuotedSpaceSeparatedExclusionListOfPDBs]
                [-d Directory]
                [-e EchoOff]
                [-E Simulate]
                [-F Forced cleanup]
                [-i Identifier]
                [-l LogDirectory] 
                [-L PriorityList]
                [-M UpgradeMode]
                [-n Processes]
                [-N PDB Processes]
                [-p StartPhase]
                [-P EndPhase]
                [-R UpgradeAutoResume]
                [-s Script]
                [-S SerialUpgrade]
                [-T ReadOnlyTablespaces]
                [-u UserName]  
                [-y DIsplayPhases]
                [-z CatconDebug]
                [-Z 1 CatctlDebug]
                FileName

  Supported Options:

     -c  Inclusion list of containers.  Run filename in the quoted,
         space separated argument list of containers only, omitting
         all other containers of the CDB. For example,
         Unix:
           -c 'PDB1 PDB2'
         Windows:
           -c "PDB1 PDB2"
         This switch is mutually exclusive with -C

     -C  Exclusion list of containers.  Run filename in all containers
         in the CDB, EXCEPT those explicitly listed in the quoted, space
         separated argument.  For example, 
         Unix:
           -C 'CDB\$ROOT PDB3'
         Windows:
           -C "CDB\$ROOT PDB3"
         This switch is mutually exclusive with -c

     -d  Directory containing the files to be run
     -e  Sets echo off while running the scripts
     -E  Simulate the upgrade
         For traditional databases this parameter is ignored
     -F  Force a cleanup of previous upgrade errors. This option is used
         with an inclusion list (-c option) for CDB containers.  For traditional
         databases only the -F option is required.
     -i  Identifier to use when creating spool log files
     -l  Directory to use for spool log files
     -L  Priority list file name in priority number and Pdb Name format. List
         will be sorted and upgrades will be processed by priority number.
         The lower priority numbers will be upgraded first. For example in
         the list below PDB1 PDB2 will be upgraded first and PDB3 and PDB4
         will be upgraded second. CDB\$ROOT and PDB\$SEED are always priorities
         1 and 2 and cannot be changed.  CDB\$ROOT will alway be processed first,
         PDB\$SEED will always be processed in the first set of upgrades.
         All other PDBs not included in the list will be processed last.
         PDB priorities must start at 1.
           1,PDB1
           1,PDB2
           2,PDB3
           2,PDB4
         To quickly generate a priority list file place the
         following lines in a file like priority.sql file.
         Then execute priority.sql in sqlplus.

           SET NEWPAGE 0 SPACE 0 PAGESIZE 0 FEEDBACK OFF
           SET HEADING OFF VERIFY OFF ECHO OFF TERMOUT OFF
           SPOOL priority_list.txt
           SELECT CON_ID || ',' || NAME FROM V\$CONTAINERS;
           SPOOL off

           SQLPLUS > \@priority.sql

         Modify priority_list.txt and adjust the priority numbers
         to your specifications.

         For traditional databases this parameter is ignored

     -M  CDB\$ROOT is set to upgrade mode while upgrading all containers
         If -M is unspecified then CDB\$ROOT defaults to normal mode
         while upgrading all containers
     -n  Maximum number of parallel SQL processes to use when upgrading the
         database. Multitenant database defaults to total number of CPUs on
         your system. Traditional database defaults to 4.
     -N  Maximum number of parallel SQL processes to use per PDB during its
         upgrade in multitenant environment defaults to 2. Ignored for
         traditional databases.
     -p  Start phase (skip successful phases on a rerun)
     -P  Stop phase (phase you want to stop on)
     -R  Automatically resumes an upgrade from the first failed phase. Automatic 
         upgrade resume is turn off by default. 
         This switch is mutually exclusive with -p  
     -s  SQL script to initialize sessions
     -S  Run Sql in Serial Mode
            Note: As of 12.2 catupgrd.sql is no supported using this option.
     -T  Places user table space(s) in read-only mode during upgrade
     -u  username (prompts for password)
     -y  Display phases only
     -z  Turns on production catcon.pm debugging info while running this script
     -Z  Turns on catctl debug tracing while running this script. Set to number
         1 for debugging -Z 1
        
     filename top-level sqlplus script to run

USAGE
    exit $CATCTL_ERROR;  # Error Get Out
}


######################################################################
# Global Variables and Constants
######################################################################

#
# Intialize Args
#
our $opt_a  = 0;
our $opt_c  = 0;
our $opt_C  = 0;
our $opt_d  = 0;
our $opt_e  = 1;  # Turn Echo on By Default
our $opt_E  = 0;
our $opt_f  = 0;
our $opt_F  = 0;
our $opt_i  = 0;
our $opt_I  = 0;
our $opt_l  = 0;
our $opt_L  = 0;
our $opt_M  = 0;
our $opt_n  = 0;
our $opt_N  = 0;
our $opt_o  = 0;
our $opt_O  = 0;
our $opt_p  = 0;
our $opt_P  = 0;
our $opt_r  = 0;
our $opt_R  = 0;
our $opt_s  = 0;
our $opt_S  = 0;
our $opt_T  = 0;
our $opt_u  = 0;
our $opt_y  = 0;
our $opt_z  = 0;
our $opt_Z  = 0;

#
# Constants
#
my $SINGLE      = 1;
my $MULTI       = 2;
my $TRUE        = 1;
my $FALSE       = 0;
my $NEXTPHASE   = $TRUE;      # Next Phase
my $NOCDBCONID  = 0;          # No CDB Con Id
my $MAXPROC_NO_CDB = 8;       # Max SQL Processes for Non-CDB
my $DEFPROC_NO_CDB = 4;       # Default SQL Processes for Non-CDB
my $DEFPROC_PDB    = 2;       # Default SQL Processes for PDB's
my $MAXPROC_PDB    = $MAXPROC_NO_CDB; # Max SQL Processes for PDB
my $MAXROOT_CDB    = $MAXPROC_NO_CDB; # Max SQL Processes for Root.
my $MINROOT_CDB    = $DEFPROC_NO_CDB; # Min SQL Processes for Root.
my $MINPROC        = 0;       # No SQL Processes specified (Use Def. values)
my $MINPDBINSTANCES  = 1;     # Min # of concurrent PDB upgrades
my $RUNROOTONLY      = 1;     # Run in Root Only
my $RUNEVERYWHERE    = 0;     # Run Everywhere
my $CATCONSERIAL     = 1;     # Run Serial
my $CATCONPARALLEL   = 0;     # Run Parallel
my $DBOPENNORMAL     = 1;     # Open Database In Normal Mode or Restricted Mode
my $DBOPENUPGPDB     = 2;     # Open Database Pdb's in upgrade mode
my $DBOPENROSEED     = 3;     # Reopen Seed Read only
my $PRICDBROOT       = 0;     # Root Priority
my $PRIPDBSEED       = 1;     # Seed Priority
my $LASTARYELEMENT   = -1;    # Last array element
my $RESTART     = "ora_restart.sql";
my $LOADCOMPILEOFF = "ora_load_without_comp.sql";
my $LOADCOMPILEON  = "ora_load_with_comp.sql";
my $TWOSPACE    = "  ";
my $SPACE       = " ";
my $NOSPACE     = "";
my $SQLTERM     = "\n/\n";
my $NONE        = "NONE";
my $UNIXSLASH   = "/";
my $WINDOWSLASH = "\\";
my $SLASH       = File::Spec->catfile('',''); # OS Slash
my $PWDSLASH    = $UNIXSLASH;
my $ORABASEIMG      = "orabase";
my $ORABASEHOMEIMG  = "orabasehome";
my $ORAHOMEIMG      = dirname(File::Spec->rel2abs(__FILE__)).$SLASH."orahome";
my $ORACLEIMG       = "oracle";
my $UPGREPORT       = "upg_summary.log";
my $UPGRADEMODE     = "OPEN MIGRATE";
my $SINGLEQUOTE = "'";
my $DOUBLEQUOTE = "\"";
my $CONTAINERQUOTE  = $SINGLEQUOTE;
my $LOADWITHOUTCOMP = qq/ALTER SESSION SET "_LOAD_WITHOUT_COMPILE" = plsql;\n/;
my $LOADWITHCOMP    = qq/ALTER SESSION SET "_LOAD_WITHOUT_COMPILE" = none;\n/;
my $ORCLSCIPTFALSE  = qq/ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE;\n/;
my $ORCLSCIPTTRUE   = qq/ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;\n/;
my $CATCTLPL        = "catctl.pl";
my $SETSTATEMENTS   = "SET ECHO ON TIME ON TIMING ON;\n";
my $REGISTRYTBL       = "sys.registry\$";
my $REGISTRYTBLTAG    = $REGISTRYTBL;
my $INSTANCETBL       = "sys.v\$instance";
my $INSTANCETBLTAG    = $INSTANCETBL;
my $ERRORTABLE        = "sys.registry\$error";
my $ERRORTABLETAG     = $ERRORTABLE;
my $SUMMARYTBL        = "sys.registry\$upg_summary";
my $SUMMARYTBLTAG     = $SUMMARYTBL;
my $RESUMETBL        = "sys.registry\$upg_resume";
my $RESUMETBLTAG     = $RESUMETBL;
my $phase0_starttime = 0;
my $CDBROOT           = "CDB\$ROOT";
my $CDBROOTTAG        = $CDBROOT;
my $PDBSEED           = "PDB\$SEED";
my $PDBSEEDTAG        = $PDBSEED;
my $CDBSETROOT        = qq/ALTER SESSION SET CONTAINER = "$CDBROOT";\n/;
my $TIMEENDCPU        = qq/SELECT 'PHASE_TIME_CPUEND %proc ' || TO_CHAR(SYSTIMESTAMP,'YY-MM-DD HH:MI:SS') AS catctl_timestamp FROM SYS.DUAL;\n/;
my $COMMITCMD         = qq/COMMIT;\n/;       # Commit command
my $CATCTLTAG         = "--CATCTL";
my $CATCTLMTAG        = "-M";
my $CATCTLCPTAG       = "-CP";               # Process component upgrade
my $CATCTLCPTAGLEN    = length($CATCTLCPTAG);
my $CATCTLCSTAG       = "-CS";
my $CATCTLCETAG       = "-CE";
my $CATCTLPSETAG      = "-PSE";
my $CATCTLPMETAG      = "-PME";
my $CATCTLSETAG       = "-SE";
my $CATCTLMETAG       = "-ME";
my $CATCTLRESTARTTAG  = "-R";
my $CATCTLDTAG        = "-D";
my $CATCTLDTAGLEN    = length($CATCTLDTAG);
my $EOLTAG            = "EOL";
my $CONTAINERTAG      = "==== Current Container = "; # Container tag
my $CONTAINERIDTAG    = " Id = ";                # Container Id Tag
my $ENDCONTAINERTAG   = " ====";               # End Container tag
my $CATCONDSPTAG      = qq/select '$CONTAINERTAG' || SYS_CONTEXT('USERENV','CON_NAME') || '$CONTAINERIDTAG' || SYS_CONTEXT('USERENV','CON_ID') || '$ENDCONTAINERTAG' AS now_connected_to from sys.dual;\n/;
my $CATSQLDSPERR      = qq/select '** Post Upgrade Unable to run **' AS upgrade_error from sys.dual;\n/;
my $CATCTLATTAG       = "@";
my $CATCTLATATTAG     = "$CATCTLATTAG$CATCTLATTAG";
my $CATCTLCATFILETAG  = "--CATFILE";
my $CATCTLSESSIONTAG  = "-SES";
my $CATCTLSESSTAG     = "-SESS";
my $CATCTLSESETAG     = "-SESE";
my $CATCTLERRORTAG    = "CATCTL ERROR COUNT=";    # Error Tag
my $CATCTLERRORTAGEND = "CATCTL END OF ERROR COUNT "; # Error Tag end
my $PFILETAG          = "CATCTL PFILE=";          # PFile Tag
my $CATCTLXTAG        = "-X";
my $SQLEXTNTAG        = ".sql";
my $ORA00001TAG       = "ORA-00001";              # Duplicated indexes
my $ORA00001TAGLEN    = length($ORA00001TAG);     # Tag Len
my $SELERR1           = 
    "SELECT count(distinct(substr(to_char(message),1,$ORA00001TAGLEN)))\n";
my $SELERR2           = " into cnt";
my $SELERR3           = " from $ERRORTABLE\n";
my $BANNERTAG         = "++++++++++++++++++++++++++++++++++++++++++++++++++++++";
my $LINETAG           = "------------------------------------------------------";
my $SERIAL            = "Serial   ";
my $PARALLEL          = "Parallel ";
my $BOUNCE            = "Restart  ";
my $DSPSECS           = "s";
my $DSPMINS           = "m";
my $DSPHRS            = "h";
my $DSPDAYS           = "d";
my $LASTRDBMSJOB      = "\@cmpupstr.sql";
my $FIRSTRDBMSJOB     = "\@catupstr.sql";
my $LASTJOB           = "\@catupend.sql";
my $SHUTDOWNJOB       = "\@catshutdown.sql";
my $SHUTDOWNPDBJOB    = "\@catshutdownpdb.sql";
my $NOTHINGNAM        = "nothing.sql";
my $NOTHINGJOB        = "\@nothing.sql";
my $CATRESULTSJOB     = "\@catresults.sql";
my $POSTUPGRADEJOB    = "\@catuppst.sql";
my $POSTUPGRADEDSP    = "catuppst.sql";
my $UTLPRPDSP         = "utlprp.sql";
my $SESFILESUFIX      = "upgrdses.sql";
my $POSTUPGERRMSG     = "$POSTUPGRADEDSP unable to run in Database: ";
my $CONTAINERMSG      = "[CONTAINER NAMES]";
my $SESSIONSTARTSQL   = "sqlsessstart.sql";
my $SESSIONENDSQL     = "sqlsessend.sql";
my $CATCTLDBGENV      = 'CATCTLDEBUG';
my $ORACLE_SID_VAR    = "ORACLE_SID";
my $ORACLE_HOME_VAR   = "ORACLE_HOME";
my $ORACLE_BASE_VAR   = "ORACLE_BASE";
my $CONFIGDIR         = "cfgtoollogs"; # tools directory
my $UPGRADEDIR        = "upgrade";     # upgrade directory
my $RDBMSDIR          = "rdbms";       # rdbms directory
my $LOGDIR            = "log";         # rdbms/log directory
my $PRIORITYFILE      = "catctl_priority";
my $IGNORESP20310ERR  = "script_path"; # Ignore Missing Files
my $TOTALTIME         = "Time: ";
my $CATCTLUSER11TBL   = "sys.registryuser11\$";
my $ABORTFILE         = "catctl_abort.txt";   # Abort File
my $UPGRADEREPLAYJOB  = "\@upgrdpdb.sql";

#
# Constant Fatal Messages
#
my $MSGFUNEXPERR                = "Unexpected error encountered in";
my $MSGFINVARGS  = "\nRequired sqlplus script name (ie. catupgrd.sql) must be supplied\n";
my $MSGFSERIALOPT  = "\n\n$MSGFUNEXPERR catctlSetFileNameToExecute;\ncatupgrd.sql is not supported when using the -S option \n";
my $MSGFCATCONINIT              = "\n$MSGFUNEXPERR catconInit; exiting\n";
my $MSGFCATCONEXEC              = "\n$MSGFUNEXPERR catconExec; exiting\n";
my $MSGFCATCONBOUNCEPROCESSES   = "\n$MSGFUNEXPERR catconBounceProcesses; exiting\n";
my $MSGFCATCONRUNSQLINEVERYPROC = "\n$MSGFUNEXPERR catconRunSqlInEveryProcess; exiting\n";
my $MSGFCATCONSHUTDOWN          = "\n$MSGFUNEXPERR catconShutdown; exiting\n";
my $MSGFCATCONISCDB             = "\n$MSGFUNEXPERR catconIsCDB; exiting\n";
my $MSGFCATCONGETCONNAMES = "\n$MSGFUNEXPERR catconGetConNames; exiting\n";
my $MSGFCATCONQUERY             = "\n$MSGFUNEXPERR catconQuery; exiting\n";
my $MSGFCATCONUPGSTARTSES       = "\n$MSGFUNEXPERR catconUpgStartSessions; exiting\n";
my $MSGFCATCONUPGSETPDBOPEN     = "\n$MSGFUNEXPERR catconUpgSetPdbOpen; exiting\n";
my $MSGFCATCTLREADLOGFILES = "\n$MSGFUNEXPERR catctlReadLogFiles; Can't Find Log File; exiting ";
my $MSGFCATCTLWRITESTDERRMSGS = "\n$MSGFUNEXPERR catctlWriteStdErrMsgs; Can't Find Log File; exiting ";
my $MSGFCATCTLDIED = "\n$MSGFUNEXPERR catctlMain; Error Stack Below; exiting\n";
my $MSGFCATCTLWRITELOGFILES = "\n$MSGFUNEXPERR catctlWriteStdErrMsgs; Can't Append Screen Messages to Log File; exiting\n";
my $MSGFCATCTLWRITETRACEFILES = "\n$MSGFUNEXPERR catctlWriteTraceMsg; Can't Append Screen Messages to Log File; exiting\n";
my $MSGFCATCTLSETFILELOGFILES = "\n$MSGFUNEXPERR catctlSetLogFiles; Log file directory does not exist or is not writeable; exiting\n";
my $MSGFCATCTLSCANSQLFILES = "\n$MSGFUNEXPERR catctlScanSqlFiles; exiting Failed to open";
my $MSGFCATCTLREADFILES    = "\n$MSGFUNEXPERR catctlSetConnectStr; exiting Failed to open";
my $MSGFCATCTLSETFILENAMETOEXECUTE = "\n$MSGFUNEXPERR catctlSetFileNameToExecute; exiting Directory does not exist; exiting\n";
my $MSGFCATCTLCREATESQLFILE = "\n$MSGFUNEXPERR catctlCreateSqlFile; exiting Failed to open";
my $MSGFCATCTLUPDRPTNAME  = "\n$MSGFUNEXPERR catctlUpdRptName; exiting Failed to execute";
my $MSGFCATCTLCREATEDBGFILE = "\n$MSGFUNEXPERR catctlDebugTrace; exiting";
my $MSGFCATCTLPRIFILE = "\n$MSGFUNEXPERR catctlLoadPriorityFile; ".
                        "exiting Failed to open Priority File";
my $MSGFCATCTLSETTBLSPACE = "\n$MSGFUNEXPERR catctlSetUserTableSpace; ".
                        "exiting Failed to set Tablespaces";
my $MSGFCATCTLNAMETOLONG = "\n$MSGFUNEXPERR catctlSetUserReadOnlyTableSpace; Name To Long".
                        "exiting Failed to set Tablespaces";
my $MSGFCATCTLSETPROCESSLIMITS = "\n$MSGFUNEXPERR catctlSetProcessLimits; Check catctl -N -n parameters; exiting\n";
my $MSGFBADSYNTAX = "Invalid command line syntax in the vicinity of";
my $MSGFNOORACLEHOME = "\n$MSGFUNEXPERR catctlInit;\n".
 "    Cannot run $ORAHOMEIMG image\n".
 "    $ORAHOMEIMG image should be located in YourOracleHome/rdbms/admin".
 "    OR specify  -d (directory) option when running catctl.pl\n".
 "        catctl.pl -d YourOracleHome/rdbms/admin catupgrd.sql\n\n"; 
my $MSGFCONTAINERLIST = "Container inclusion list is required with (-p -P) options\n".
 "Only one inclusion item is allowed. Exclusion lists are not allowed.\n"; 
my $MSGFORCEDCONLIST = "\n$MSGFUNEXPERR catctlRunForcedCleanup Container inclusion list is required with (-F) option\n"; 
my $MSGFROOTINVALID = "[PDB] cannot be upgraded because [$CDBROOTTAG] is INVALID.\n".
 "                 [Probable Causes]\n".
 "    1) $CDBROOTTAG upgrade failed.\n".
 "    2) $CDBROOTTAG upgrade contains unresolved errors from a previous attempt\n".
 "       to upgrade.\n".
 "                 [Possible Solutions]\n".
 "    1) Identify and resolve upgrade errors by reviewing the upgrade summary\n".
 "       report (upg_summary.log).  To regenerate the report do the following:\n".
 "           ALTER SESSION SET CONTAINER = $CDBROOTTAG;\n".
 "           @\$ORACLE_HOME/rdbms/admin/catresults.sql\n".
 "    2) Identify and resolve upgrade errors by reviewing the upgrade log\n". 
 "       files (catupgrd*.log)\n".
 "    3) Rerun the upgrade in $CDBROOTTAG.\n\n".
 "    Once upgrade errors have been resolved in $CDBROOTTAG. You may have to delete\n".
 "    errors from a previous upgrade in order to proceed with the PDB upgrades.\n".
 "    Invoke catctl.pl with the -F option\n\n".
 "        \$ORACLE_HOME/perl/bin/perl catctl.pl -F -c '$CDBROOTTAG' catupgrd.sql\n\n".
 "    NOTE: This command does not run the upgrade but removes errors found in\n".
 "          $ERRORTABLETAG from a previous upgrade run.\n";
my $MSGFCANFINDPFILE = "Unable to locate Pfile to startup the database\n".
 "or errors found during the upgrade. Please check log files.\n\n".
 "To rerun just the post upgrade procedure specify the post upgrade phase.\n".
 "For example:\n    ".
 "\$ORACLE_HOME/perl/bin/perl catctl.pl -p <N> -P <N> catupgrd.sql\n".
 "In the above example $POSTUPGRADEDSP would run in phase <N>.  To obtain which\n".
 "phase the $POSTUPGRADEDSP is run in display the phases in the following manner:\n".
 "    \$ORACLE_HOME/perl/bin/perl catctl.pl -y catupgrd.sql\n".
 "Pick the phase number that runs $POSTUPGRADEDSP and use that\n".
 "phase number as the input into catctl.pl -p and -P options\n";
my $MSGFANOTHERPROCESS = "\n$MSGFUNEXPERR catctlGetUpgLockFile; ".
                         "Exiting due to another upgrade process running.\n".
                         "Unable to lock file"; 
my $MSGFERROPENLOCKFILE = "\n$MSGFUNEXPERR catctlGetUpgLockFile;\n".
                         "Unable to Open File"; 
my $MSGFANOTHERCMP = "\n$MSGFUNEXPERR catctlScanSqlFiles; ".
                         "Exiting due to another component scan.\n".
                         "Nested components not supported"; 
my $MSGFERRRPTLOCKFILE = "\n$MSGFUNEXPERR catctlGetRptLockFile;\n".
                         "Unable to Open File"; 
my $MSGFINVPRIORITYVALUE = "\n$MSGFUNEXPERR abs exiting Invalid Priority Value".
                           "\nIn Priority List File";
my $MSGFINVPRIORITYCONID = "\n$MSGFUNEXPERR catctlLoadPriorityFile exiting ".
                           "Invalid Priority Container Id".
                           "\nIn Priority List File";
my $MSGFINVOPTIONVALUE = "\n$MSGFUNEXPERR catctlInit exiting Invalid number, Invalid Input Argument";
my $MSGFINVPHASENAME = "\n$MSGFUNEXPERR catctlGetPhaseNo exiting Invalid Phase Name";
my $MSGFATALERROR    = "\n$LINETAG\nCATCTL FATAL ERROR\n$LINETAG\n\n";

#
# Constant Warning Messages
#
my $MSGWSCRIPTSFOUND     = "scripts found in file";
my $MSGWNOSCRIPTSFOUND   = "No $MSGWSCRIPTSFOUND";
my $MSGWNEXTPATH         = "Next path:";
my $MSGWLINENOTPROCESSED = "Line not processed:";
my $MSGWCOMPNOTPROCESSED = "Component not processed:";
my $MSGWCOMPFILENOTEXIST = "Component not processed - component file does not exist:";
my $MSGWSQLPATCHNOTRUN   = "\n$MSGFUNEXPERR catctlDatapatch Unable to run ".
                           "DataPatch open2 failed";
my $ERRMSGWPMSG = "\n\n*** WARNING: ERRORS FOUND DURING UPGRADE ***\n\n".
                  " 1. Evaluate the errors found in the upgrade logs\n".
                  "    and determine the proper action.\n".
                  " 2. Rerun the upgrade when the problem is resolved\n";
my $MSGFCATCONGRPBYUPGLVL = "\n$MSGFUNEXPERR catconGroupByUpgradeLevel; ".
                            "exiting\n";
my $MSGFCATCONPDBTYPE = "\n$MSGFUNEXPERR catconPdbType; exiting\n";

#
# Constant Info Messages
#
my $MSGIVERSION       = "catctl.pl VERSION: [".CATCONST_BUILD_VERSION."]\n".
    "           STATUS: [".CATCONST_BUILD_STATUS."]\n".
    "            BUILD: [".CATCONST_BUILD_LABEL."]\n";
my $MSGIREPORT        = "Upgrade Summary Report Located in:";
my $MSGIPHASENO       = "Phase #:";
my $MSGIGRANDTIME     = "Grand Total $TOTALTIME";
my $MSGITOTALFILES    = "Files:";
my $MSGIDISP1         = "\n[phase";
my $MSGIDISP2         = "] type is";
my $MSGIDISP3         = "with";
my $MSGIDISP4         = "Files\n";
my $MSGIANALYZINGFILE = "\nAnalyzing file";
my $MSGIREVERSEODER   = "Running multiprocess phases in reverse order.\n";
my $MSGIUSING         = "Using";
my $MSGIPROCESSES     = "processes.\n";
my $MSGILOGFILES      = "\nLog file directory =";
my $MSGIRUNSERIAL     = "Running File In Serial Order FileName is";
my $MSGIREVERTROT     = "\nThere were tablespaces put in Read Only mode during the upgrade. In case of a failure, \n".
                        "the following commands can be issued to put them back to their original state:\n";
my $MSGIPDBERRORS     = "Pdb Upgrades With Errors";
my $MSGITBLSPACESNONE = "No User Table Spaces Found\n";
my $MSGITBLSPACESFOUND = "User Table Spaces Found\n";
my $MSGITBLSPACEQUERY = "User Table Spaces Query\n";
my $MSGRWTABLESPACES  = "\nList of User Tablespaces Maintained in READ WRITE during Upgrade:";
my $MSGIFORCEDCLEANUP = "\nForced Cleanup of previous upgrade errors";
my $MSGINVALIDPDBSEPARATOR = "\n Invalid separator on pdb inclusion list.". 
			     " List of PDBs must be separated with a space rather than comma(,). \n";
my $MSGNOTEXISTPDBNAME = "\n PDBs not found in the database:";

# 17277459: Messages for printing datapatch output to log
my $MSGIDP_OUT_UPGRADE =
  "stdout from running datapatch to install upgrade SQL patches and PSUs:";
my $MSGIDP_ERR_UPGRADE =
  "stderr from running datapatch to install upgrade SQL patches and PSUs:";
my $MSGIDP_OUT_NORMAL =
  "stdout from running datapatch to install non-upgrade SQL patches and PSUs:";
my $MSGIDP_ERR_NORMAL =
  "stderr from running datapatch to install non-upgrade SQL patches and PSUs:";
my $MSGIUNABLETOPARSEDESC = "Unable To Parse Description";
my $MSGICONVERTDICT = "   Executing Change Scripts   ";
my $MSGIDBNOREUPGRADENEED = "\nDatabase was already upgraded successfully.". 
                          " If you still want to reupgrade, run catctl.pl without the -R option.\n";
my $MSGIDBNOTUPGRADED = "\nDatabase has not been upgraded! Run catctl.pl without the -R option.\n";
my $MSGINVALIDOPTS_STARTPHASE_AUTOUPGRADE ="\nInvalid upgrade options. -p and -R options are mutually exclusive.".
				           " Execute catctl.pl by specifying only one of them.\n";
#
# Booleans
#
my $gbLoadWithoutComp = $FALSE;
my $gbLoadWithComp    = $TRUE;
my $gbUpgrade         = $TRUE;   # Upgrade Run
my $gbFoundPfile      = $FALSE;  # Assume Pfile Not Found
my $gbCreatePfile     = $FALSE;  # Assume Pfile Not Created
my $gbErrorFound      = $FALSE;  # Assume no Error Found
my $gbRegErrFound     = $FALSE;
my $gbCdbDatabase     = $FALSE;  # Assume no CDB Database
my $gbShutDownDB      = $FALSE;  # Did we shutdown the Database once already
my $gbRootProcessing  = $FALSE;  # Assume no Root Processing
my $gbSavRootProcessing = $FALSE;  # Assume no Root Processing
my $gbSeedProcessing  = $FALSE;  # Assume no Seed Processing
my $gbPdbProcessing   = $FALSE;  # Assume no Pdb  Processing
my $gbListProcessing  = $FALSE;  # Assume no Include and Exclude lists
my $gbStartStopPhase  = $FALSE;  # User gave a start or stop phase
my $gbRootOpenInUpgMode=$FALSE;  # Root Started In Migration Mode
my $gbWrapUp          = $FALSE;  # Call catconWrapUp
my $gbUseCmpDir       = $FALSE;  # Use ORACLE_HOME based directory for components
my $gbFatalError      = $FALSE;  # Fatal Error Flag
my $gbCatctlDieError  = $FALSE;  # Catctl Cause the fatal error
my $gbLogErrors       = $FALSE;  # Have we log errors yet
my $gbLogon           = $FALSE;  # Have we log into the database
my $gbWindows         = $FALSE;  # Windows Platform

#
# String Variables
#
my $gsLoadComp        = $LOADWITHCOMP;
my $gsPadChr          = $SPACE;
my $gsDspPhase        = $SERIAL;
my $gsCatconEnvTag    = "";
my $gsReportName      = ""; # Summary report name
my $gUserPass         = ""; # Pass to Datapatch
my $gUserName         = ""; # Pass to DataPatch
my $gsPostUpgMsg      = ""; # Post Upgrade Message 
my $gsPath            = 0;
my $gsSpoolLog        = 0;  # Spool Log without Log Dir
my $gsErrorLog        = 0;  # Error Log without Log Dir
my $gsSpoolLogDir     = 0;  # Log Dir plus Spool Log
my $gsErrorLogDir     = 0;  # Log Dir plus Error Log
my $gsSpoolDir        = 0;  # Log Dir
my $gspFileName       = 0;  # Pfile Name
my $gsPostUpgCmds     = ""; # Post Upgrade Commands
my $gsPrintCmds       = ""; # STDERR Commands
my $gsNoQuery;              # No Query
my $gsNoInclusion;          # No Inclusions
my $gsNoIdentifier;         # No Identifier
my $gsNoExclusion;          # No Exclusion
my $gsRTInclusion     = ""; # Runtime Inclusions
my $gsRTExclusion     = ""; # Runtime Exclusions
my $gsRTIdentifier    = ""; # Runtime Exclusions
my $gsParsedInclusion = 0;  # Parsed Inclusion List for Containers
my $gsParsedExclusion = 0;  # Parsed Exclusion List for Containers
my $gsSelectErrors    = ""; # Sql Error Checking statement
my $gsTempDir         = ""; # Temp Directory
my $gsOrabaseDir      = 0;  # Orabase Base Directory
my $gsOracleHomeDir   = 0;  # Oracle Home
my $gsUpgLockFile     = ""; # Upgrade Lock File to prevent 2 upgrades on same DB
my $gsRptLockFile     = ""; # Report Lock File to prevent multiple writers 
my $gsDbName          = 0;  # Database Name
my $gsCmp             = ""; # Component ID
my $gsCmpDir          = ""; # Component Directory 
my $gsCmpFile         = ""; # Component File Name
my $gsCmpSesFile      = ""; # Component Session File Name
my $gsCmpTestFile     = ""; # Component existence Test File
my $gsCmpNoFile       = ""; # Component Empty Test File
my $gsFatalErrorMsg   = 0;  # Fatal Error Message
my $gsPdbSumMsg       = ""; # Pdb Summary Messages
my $gsUpgradeSyncPdbs = ""; # if $gbInstance, names of PDBs which have 
                            # PDB_UPGRADE_SYNC property enabled
my $gsNoUpgradeSyncPdbs = ""; # if $gbInstance, names of PDBs which have 
                            # PDB_UPGRADE_SYNC property disabled

#
# File Handles
#
my $ghUpgLockFile = undef;  # Upgrade Lock File Handle
my $ghRptLockFile = undef;  # Report Lock File Handle

# Outputs from running datapatch in upgrade mode
my $gsDatapatchLogUpgrade = "";
my $gsDatapatchErrUpgrade = "";

# Outputs from running datapatch in normal mode
my $gsDatapatchLogNormal = "";
my $gsDatapatchErrNormal = "";

#
# Integer Variables
#
my $giStartPhase      = 0;  # User Input Start Phase
my $giStopPhase       = 0;  # User Input Stop  Phase
my $giStartPhaseNo    = 0;  # Calculated Start Phase
my $giStopPhaseNo     = 0;  # Calculated Stop  Phase
my $giEndPhaseNo      = 0;  # Calculated End Phase
my $giUseDir          = 0;
my $giProcess         = 0;  # Number of sql processors
my $giPdbProcess      = 0;  # Number of PDB sql processors
my $giCpus            = 0;  # Number of Cpu's
my $giDBMajorVer      = 0;  # Database Major Version
my $giPdbInstances    = 0;  # Number of PDB Instances
my $giph              = 0;
my $gidepth           = 0;  # degree of nested scripts (-X control)
my $giNumOfPhaseFiles = 0;  # Number of files in phase
my $giRetCode         = 0;
my $giLastNumOfPhaseFiles = 0;
my $giDelimiter1      = 0;
my $giDelimiter2      = 0;
my $giLastJob         = 0;  # Last Job Phase Number
my $giPostJob         = 0;  # Post Upgrade Phase Number

#
# Date and time Variabes
#
my $gtLastTime        = time();
my $gtSTime           = 0;
my $gtSDifSec         = 0;
my $gtTotSec          = 0;

#
# Parse command line arguments
# Bug 23041298 Handling wrong parameters
#
printUsage() if (!getopts("u:n:N:d:l:s:f:p:P:i:c:C:Z:L:earozyISMETFRO"));

#
#  Print out Arguments.
#
catctlPrintMsg ("\nArgument list for [$0]\n",$TRUE,$TRUE);
catctlPrintMsg ("Run in                c = $opt_c\n",$TRUE,$TRUE);
catctlPrintMsg ("Do not run in         C = $opt_C\n",$TRUE,$TRUE);
catctlPrintMsg ("Input Directory       d = $opt_d\n",$TRUE,$TRUE);
catctlPrintMsg ("Echo OFF              e = $opt_e\n",$TRUE,$TRUE);
catctlPrintMsg ("Simulate              E = $opt_E\n",$TRUE,$TRUE);
catctlPrintMsg ("Forced cleanup        F = $opt_F\n",$TRUE,$TRUE);
catctlPrintMsg ("Log Id                i = $opt_i\n",$TRUE,$TRUE);
catctlPrintMsg ("Child Process         I = $opt_I\n",$TRUE,$TRUE);
catctlPrintMsg ("Log Dir               l = $opt_l\n",$TRUE,$TRUE);
catctlPrintMsg ("Priority List Name    L = $opt_L\n",$TRUE,$TRUE);
catctlPrintMsg ("Upgrade Mode active   M = $opt_M\n",$TRUE,$TRUE);
catctlPrintMsg ("SQL Process Count     n = $opt_n\n",$TRUE,$TRUE);
catctlPrintMsg ("SQL PDB Process Count N = $opt_N\n",$TRUE,$TRUE);
catctlPrintMsg ("Open Mode Normal      o = $opt_o\n",$TRUE,$TRUE);
catctlPrintMsg ("Start Phase           p = $opt_p\n",$TRUE,$TRUE);
catctlPrintMsg ("End Phase             P = $opt_P\n",$TRUE,$TRUE);
catctlPrintMsg ("Reverse Order         r = $opt_r\n",$TRUE,$TRUE);
catctlPrintMsg ("AutoUpgrade Resume    R = $opt_R\n",$TRUE,$TRUE);
catctlPrintMsg ("Script                s = $opt_s\n",$TRUE,$TRUE);
catctlPrintMsg ("Serial Run            S = $opt_S\n",$TRUE,$TRUE);
catctlPrintMsg ("RO User Tablespaces   T = $opt_T\n",$TRUE,$TRUE);
catctlPrintMsg ("Display Phases        y = $opt_y\n",$TRUE,$TRUE);
catctlPrintMsg ("Debug catcon.pm       z = $opt_z\n",$TRUE,$TRUE);
catctlPrintMsg ("Debug catctl.pl       Z = $opt_Z\n",$TRUE,$TRUE);


#
#  Global Args
#
my $gUser             = $opt_u; # User
my $gSrcDir           = $opt_d; # Directory where scripts are located
my $gLogDir           = $opt_l; # Log File Directory
my $gScript           = $opt_s; # User Session Init Script
my $gbDebugCatcon     = $opt_z; # Debug catcon
my $giDebugCatctl     = $opt_Z; # Debug catctl
my $gPwdFile          = $opt_f; # File
my $gbDBUA            = $opt_a; # DBUA flag
my $gbDisplayPhases   = $opt_y; # Display phases only
my $gbOpenModeNormal  = $opt_o; # Open Mode normal and leave database open
my $gIdentifier       = $opt_i; # Unique Identifier
my $gCInclusion       = $opt_c; # Cdb Inclusion Containers
my $gCExclusion       = $opt_C; # Cdb Exclusion Containers
my $gbInstance        = $opt_I; # Instance
my $gbSerialRun       = $opt_S; # Serial Run
my $gbUpgradeMode     = $opt_M; # CDB$ROOT is opened in upgrade mode
my $gsPriFile         = $opt_L; # Priority File Name
my $gbEmulate         = $opt_E; # Simulate the run
my $gbROTblSpace      = $opt_T; # User Read tablespace
my $gbAutoRstUpg      = $opt_R; # Automatically resume upgrade from failed phase
my $gbForcedCleanup   = $opt_F; # Forced Cleanup of upgrade errors
my $gbOverNotUpgrade  = $opt_O; # Allow override not to Upgrade a freshly created database 


#
# Arguments
#
my $gsFile = $ARGV[0] or catctlDie("$MSGFINVARGS $!");
if (@ARGV > 1) {
    catctlDie("$MSGFBADSYNTAX '$ARGV[0]' or '$ARGV[1]'.  Exiting.\n");
}
 
#
#  Arrays
#

#
# SQL statements which need to be executed in every process before it runs 
# any scripts.  These statements may contain 0 or more instances of %proc 
# string which will be replaced with a process number.
#
my @PerProcInitStmts = ();

#
# SQL statements which need to be executed in every process after it finishes 
# running all scripts assigned to it. These statements may contain 0 or more 
# instances of %proc string which will be replaced with a process number.
#
my @PerProcEndStmts = ();
my @SqlAry;                   # Sql to be feed to each process
my @phase_type;               # Multi or single
my @phase_compile;            # Load with or without compile 
my @phase_files;              # References to file name array
my @phase_files_ro;           # Phase files in reverse order
my @phase_desc;               # Phase description
my @session_files;            # Sql Session Files
my @session_start_phase;      # Sql Session Phase to start running in
my @session_stop_phase;       # Sql Session Phase to stop running 
my @files_to_delete;          # Files to delete
my @AryContainerNames;        # Catcon Containers Names
my @AryParsedList;            # Inclusion Or Exclusion List array
my @AryPDBInstanceList;       # Inclusion Or Exclusion List array
my @AryCmps;                  # Components using -CP and <CID>upgrd.sql
my @AryCmpDirs;               # Corresponding component Directories
my @AryCmpPrefs;              # Corresponding component file prefix
my @AryCmpFile;               # Corresponding component exist test file
my @AryTblSpaces = ();        # Array of Table Spaces
my @SortedPdbPriData;         # Sort Array
my %HashPdbPriData;           # Priority hash data
my %CIDinstalledCmp = ();     # List of installed components in each container
my @pAryPDBInstanceFresh ;    # List of pdbs already on current version

# hash with keys consisting of names of App Roots which have already 
# been closed once (at the end of upgrade phase) and should not be closed 
# again (at the end of post-upgrade) because App Root Clones and App PDBs 
# get upgraded after App Roots and depend on App Root being open
my %AppRootsNotToClose;    

#
# Initialize phases and scripts array
#
push (@phase_compile, $gbLoadWithComp); # Default first phase to compile on
push (@phase_type,    $SINGLE);         # Default first phase to single threaded
push (@phase_files,   []);              # Default a reference to an empty array
push (@phase_files_ro,[]);              # Default a reference to an empty array
push (@phase_desc, "$MSGICONVERTDICT"); # Initial Phase
push (@SqlAry,      $LOADWITHCOMP);     # Default to load with compile on
#push (@PerProcEndStmts, $TIMEENDCPU);  Track End time for CPU

# Initialize Component list
# The full list of SERVER components is defined in catcrsc.sql as constants
# in the DBMS_REGISTRY_SERVER package.  The information about the subset of 
# components using CATCTL to drive the component upgrade are included here
# because the list is needed before the package is available.

push (@AryCmps, 'JAVAVM');
push (@AryCmpDirs, '/javavm/install/');
push (@AryCmpPrefs, 'jvm');
push (@AryCmpFile, $gsCmpNoFile);

push (@AryCmps, 'XDB');
push (@AryCmpDirs, '/rdbms/admin/');
push (@AryCmpPrefs, 'xdb');
push (@AryCmpFile, $gsCmpNoFile);

push (@AryCmps, 'ORDIM');
push (@AryCmpDirs, '/ord/im/admin/');
push (@AryCmpPrefs, 'im');
push (@AryCmpFile, $gsCmpNoFile);

push (@AryCmps, 'SDO');
push (@AryCmpDirs, '/md/admin/');
push (@AryCmpPrefs, 'sdo');
push (@AryCmpFile, 'catmd.sql');    # If catmd.sql is missing, then no SDO upgrade (SE)

push (@AryCmps, 'APEX');
push (@AryCmpDirs, '/apex/');
push (@AryCmpPrefs, 'apx');
push (@AryCmpFile, $gsCmpNoFile);

push (@AryCmps, 'ZZ');   # for testing a component that is valid for catctl, but not in DB
push (@AryCmpDirs, '/work/');
push (@AryCmpPrefs, 'zz');
push (@AryCmpFile, $gsCmpNoFile);

####################################################################
# Start of MAIN Routine
####################################################################


    #
    # Trap Errors display and write to file
    #
    eval
    {
        local $SIG{__DIE__}  = \&Carp::confess;
        catctlMain();
    };
    if ($@)
    {
        $gsFatalErrorMsg = $MSGFCATCTLDIED."$@";
    }

    #
    # Check for Error and get out.
    #
    if ($gsFatalErrorMsg)
    {
        $gbFatalError = $TRUE;
        catctlFatalError($gsFatalErrorMsg);
        catctlEnd();
    }

    #
    # Exit Success or Failure
    #
    if (($gbErrorFound) || ($gbFatalError))
    {
        exit ($CATCTL_ERROR); 
    }

    exit ($CATCTL_SUCCESS);

####################################################################
# End of MAIN Routine
####################################################################

######################################################################
# 
# catctlMain - Main Routine for catctl.pl
#
# Description:
#   This is the main routine for catctl.
#
# Parameters:
#   - None
######################################################################
sub catctlMain
{

    #
    # Catctl Initialize
    #
    catctlInit();

    #
    # Log into the database
    #
    if (!$gbDisplayPhases)
    {   
        catctlLogon();
    }
    else
    {
        return (0); # Success
    }

    #
    # Run Force, Serial or Parallel
    #
    if ($gbForcedCleanup)
    {
        catctlRunForcedCleanup();
    }
    elsif ($gbSerialRun)
    {
        #
        # Run command file from start to finish no phases
        #
        catctlRunSerial();
    }
    else
    {
        #
        #  Put OS and Database info to upgrade log
        #
        my $sIncList = $gbInstance ? $gsRTInclusion : $gsNoInclusion;
        catctlDisplaySupportInfo($sIncList);

        #
        #  Create Pfile
        #
        catctlCreatePFile();

        #
        # Run Phases for CDB and Non-cdb Database
        #
        catctlRunMainPhases();

        #
        # Run the PDB Upgrade Instances 
        #
        catctlRunPDBInstances($giPdbProcess);
    }

    #
    # End it
    #
    catctlEnd();

    return (0);
}

######################################################################
# 
# catctlCheckPostUpgrade - Check to see if we need to call the
#                          post upgrade procedure.
#
# Description:
#   Check to see if we should run the Post Upgrade.
#
# Parameters:
#   - phase number (IN)
#   - number phase files (IN)
#   - Inclusion list (IN)
#   - Exclusion list (IN)
#   - Start Phase (IN)
#   - Stop Phase (IN)
# Returns:
#   - TRUE  = Move onto Next Phase if the following is true.
#                No files to process within phase.
#                Nothing.sql is the job (no opt).
#                Run the Upgrade summary report.
#     FALSE = Process this phase
#                This is not the post upgrade job.
#                Errors were found in the upgrade.
#
######################################################################
sub catctlCheckPostUpgrade
{
    my $phaseNo       = $_[0];   # Phase No
    my $phaseNoFiles  = $_[1];   # Number of Phase Files
    my $pInclusion    = $_[2];   # Inclusion List for Containers
    my $pExclusion    = $_[3];   # Exclusion List for Containers
    my $pStartPhaseNo = $_[4];   # Start Phase Number
    my $pStopPhaseNo  = $_[5];   # Stop Phase Number
    my $bRetStat      = $FALSE;
    my $TmpFileName   = 0;
    my $AtTmpFileName = 0;
    my $ErrMsg        = "";      # Error Message

    #
    # If no files to process then Next Phase
    #
    if ($phaseNoFiles == 0)
    {
        return($NEXTPHASE);
    }

    #
    # Delete any old message from the registry$error
    #
    if ($pStartPhaseNo == $phaseNo)
    {
        catctlDeleteMsgFromRegistryError($pInclusion);   
    }

    #
    # Do Nothing Next Phase
    #
    if (catctlIsPhase($phaseNo,$NOTHINGJOB))
    {
        return($NEXTPHASE);
    }

    #
    # Log Errors and Run Report Phase
    #
    if (catctlIsPhase($phaseNo,$CATRESULTSJOB))
    {
        #
        # Set User Table Spaces back to Read Write
        #
        if ($gbROTblSpace)
        {
            my $sIncList = $gbCdbDatabase ? $pInclusion : $gsNoInclusion;
            catctlSetUserWriteTableSpace($sIncList,
                                         \@AryTblSpaces,
                                         $#AryTblSpaces,
                                         $giDBMajorVer);
        }

        #
        # Log Error so we can display them
        #
        catctlLogErrors($pInclusion,
                        $pExclusion,
                        $gsNoIdentifier);
        #
        # Get a lock before we run the report
        #
        catctlGetRptLockFile();
        return($bRetStat);
    }

    #
    # Get out if not post upgrade job
    #
    if (!catctlIsPhase($phaseNo,$POSTUPGRADEJOB))
    {
        return($bRetStat);
    }

    #
    # Close Report Lock files. We don't want
    # to hold it while running the post upgrade
    # Let it go after the report has run.
    # The close will release any locks held on the
    # file.  If catctl.pl crashes perl
    # will automatically release the lock.
    #
    if ($ghRptLockFile)
    {
        close ($ghRptLockFile);
        $ghRptLockFile = undef;
    }

    #
    # Setup for the Post Upgrade
    # If we are running the post upgrade
    # procedure only then just run in the
    # current opened database as instructed
    # by DBA and don't startup the database.
    #
    if ($pStartPhaseNo != $phaseNo)
    {
        #
        # Setup for the Post Upgrade
        #
        catctlPostUpgrade($pInclusion,
                          $pExclusion,
                          $DBOPENNORMAL,
                          $gbUpgradeMode,
                          $gbErrorFound);

    }

    # Record timestamp for datapatch begin in normal mode
    catctlTimestamp("DP_NOR_BGN", $pInclusion);

    #
    # 17277459: Call datapatch again in normal mode, this time to install any
    # remaining PSUs or bundles that did not require upgrade mode.
    #
    catctlDatapatch("normal",$gUserName,$gUserPass,$pInclusion,"DP_NOR_BGN");

    # Record timestamp for datapatch end in normal mode
    catctlTimestamp("DP_NOR_END", $pInclusion);

    #
    # Create Post Upgrade Commands File
    #
    $TmpFileName = catctlCreateSqlFile($gsPostUpgCmds,"catuppst");
    $AtTmpFileName = "\@".$TmpFileName;
    catctlSetPhaseToJob($phaseNo,$AtTmpFileName);
    $giPostJob = $phaseNo;
    push (@files_to_delete, $TmpFileName);

    return($bRetStat);

} # End of catctlCheckPostUpgrade

######################################################################
# 
# catctlCheckShutdown - Calls Shutdown
#
# Description:
#   Check to see if we should Shutdown the database
#
# Parameters:
#   - phase number (IN)
#   - pInclusion   (IN) Inclusion List for Containers
#   - pExclusion   (IN) Exclusion List for Containers
# Returns:
#   - TRUE  = Move onto Next Phase
#     FALSE = Process this phase
#
######################################################################
sub catctlCheckShutdown
{
    my $phaseNo      = $_[0];       # Phase No
    my $pInclusion   = $_[1];       # Inclusion List for Containers
    my $pExclusion   = $_[2];       # Exclusion List for Containers
    my $bRetStat     = $FALSE;

    #
    # Shutdown pdb's.
    #
    if (catctlIsPhase($phaseNo,$SHUTDOWNPDBJOB))
    {
        #
        # Shutdown pdb's
        #
        if ($gbCdbDatabase)
        {
          # Bug 26527096: $pInclusion may contain name(s) of 
          #   - App Root(s) which need to be closed as a part of being 
          #     bounced after running upgrade but not after post-upgrade or  
          #   - App Root Clone(s) which cannot be closed at all
          foreach my $pdb (split(' ', $pInclusion)) {
            # determine if PDB $pdb should be closed

            # obtain type of $pdb
            my $pdbType = catconPdbType($pdb);
              
            if (! defined $pdbType) {
              catctlDie("$MSGFCATCONPDBTYPE $!");
            }

            # should the PDB be closed?
            my $closeIt = $TRUE;

            if ($pdbType == catcon::CATCON_PDB_TYPE_APP_ROOT) {
              # App Roots should be closed after completing upgrade but not 
              # after post-upgrade (to simplify performing post-upgrade on 
              # App Root Clones and App PDBs)
              if (exists $AppRootsNotToClose{$pdb}) {
                catctlPrintMsg("PDB $pdb is an App Root which has ".
                               "undergone post-upgrade and\n".
                               "which will not be closed to ensure that we ".
                               "can upgrade any App Root Clones\n".
                               "associated with it\n", $TRUE, $FALSE);

                $closeIt = $FALSE;
              } else {
                # remember that this App Root should not be closed in the 
                # future
                $AppRootsNotToClose{$pdb} = 1;
              }
            } elsif ($pdbType == catcon::CATCON_PDB_TYPE_APP_ROOT_CLONE) {
              # can't close App Root Clones - they are open in the same 
              # mode as the App Root and will be closed when the App Root 
              # is closed
              $closeIt = $FALSE;

              catctlPrintMsg("PDB $pdb is an App Root Clone which ".
                             "cannot be closed\n", $TRUE, $FALSE);
            }
            
            if ($closeIt) {
              catctlShutDownDatabase($SHUTDOWNPDBJOB,
                                     $RUNEVERYWHERE,
                                     $pdb,
                                     $pExclusion);
            }
          }
        }
        return($NEXTPHASE);
    }

    #
    # Shutdown database.
    #
    if (catctlIsPhase($phaseNo,$SHUTDOWNJOB))
    {
        #
        # Shutdown database once.  In the CDB Case only
        # if we are upgrading the root. 
        # 
        if ($gbCdbDatabase)
        {
            if ($gbRootProcessing)
            {
                #
                # Only shutdown the root once
                #
                if (!$gbShutDownDB)
                {
                    #
                    # Close all session except one
                    #
                    $giRetCode = catconUpgEndSessions();

                    catctlShutDownDatabase($SHUTDOWNJOB,
                                           $RUNROOTONLY,
                                           $gsNoInclusion,
                                           $gsNoExclusion);
                    $gbShutDownDB = $TRUE;
                }
            }
        }
        else
        {
            #
            # Close all session except one
            #
            $giRetCode = catconUpgEndSessions();

            catctlShutDownDatabase($SHUTDOWNJOB,
                                   $RUNROOTONLY,
                                   $gsNoInclusion,
                                   $gsNoExclusion);

        }
        return($NEXTPHASE);
    }


    return($bRetStat);
} # End of catctlCheckShutdown

######################################################################
# 
# catctlCheckRestartSqlProcesses - Check for Restarting SQL Processor
#
# Description - Check to see if we need to bounce the SQL Processors.
#
# Parameters:
#   - phase number (IN)
# Returns:
#   - TRUE  = Move onto Next Phase
#     FALSE = Process this phase
#
######################################################################
sub catctlCheckRestartSqlProcesses
{
    my $phaseNo  = $_[0];       # Phase No
    my $bRetStat = $FALSE;

    #
    # Restart Sql Process
    #
    if ($phase_files[$phaseNo][0] eq $RESTART)
    {
        $giRetCode = catconBounceProcesses();
        if ($giRetCode)
        {
            catctlDie("$MSGFCATCONBOUNCEPROCESSES $!");
        }
        return($NEXTPHASE);
    }

    return($bRetStat);
} # End of catctlCheckRestartSqlProcesses

######################################################################
# 
# catctlCheckLoadCompile - Check for loading compile option
#
# Description:
#   Check for loading with or without compiling.
#
# Parameters:
#   - phase number (IN)
# Returns:
#   - TRUE  = Move onto Next Phase
#     FALSE = Process this phase
#
######################################################################
sub catctlCheckLoadCompile
{
    my $phaseNo  = $_[0];       # Phase No
    my $bRetStat = $FALSE;


    #
    # No Opts for us just send the alter session command
    #
    if (($phase_files[$phaseNo][0] eq $LOADCOMPILEOFF) ||
        ($phase_files[$phaseNo][0] eq $LOADCOMPILEON))
    {
        return($NEXTPHASE);
    }

    return($bRetStat);
} # End of catctlCheckLoadCompile

######################################################################
# 
# catctlRunForcedCleanup - Cleanup previous registry errors
#
# Description:
#   This routine will cleanup old registry errors
#   Set Upgrade status from INVALID to UPGRADED.
#
# Parameters:
#   - None
# Returns:
#   - Status
#
######################################################################
sub catctlRunForcedCleanup
{

    $giStartPhase = @phase_type;
    $gtLastTime = time();
    $gsRTExclusion = $gsNoExclusion;
    my $UPDRPTSTARTTIME = 
        "UPDATE $SUMMARYTBL SET con_name = SYS_CONTEXT('USERENV','CON_NAME'), ".
        "ENDTIME = SYSDATE WHERE con_id = -1 AND starttime = endtime;\n";
    my $CLEANREGISTRY  = "DELETE FROM $ERRORTABLE;\n";
    my $SqlCmd = $SETSTATEMENTS.$UPDRPTSTARTTIME.$CLEANREGISTRY.$COMMITCMD;

    #
    # Return if not upgrade
    #
    if (!$gbUpgrade)
    {
        return($giRetCode);
    }

    #
    # Display Message
    #
    catctlPrintMsg("$MSGIFORCEDCLEANUP Started",$TRUE,$TRUE);

    #
    # Cdb or Traditional Database
    #
    if ($gbCdbDatabase)
    {
        if (!$gCInclusion)
        {
            catctlPrintMsg("\n$MSGFORCEDCONLIST\n",$TRUE,$TRUE);
            $gbWrapUp = $FALSE;
            catconWrapUp();
            exit($CATCTL_ERROR);
        }
        #
        # Add in ROOT 
        #
        if ($gbRootProcessing)
        {
            if ($gsRTInclusion)
            {
                $gsRTInclusion = $CDBROOT." ".$gsRTInclusion;
            }
            else
            {
                $gsRTInclusion = $CDBROOT;
            }
        }

    }
    else
    {
        $gsRTInclusion = $gsNoInclusion;
    }

    #
    # If not upgrade then just get out
    #
    $giRetCode = 0;

    #
    # Create and Execute Sql File
    #
    $SqlAry[0] = $SqlCmd;
    $giRetCode = catctlExecSqlFile(\@SqlAry,
                                   0,
                                   $gsRTInclusion,
                                   $gsNoExclusion,
                                   $RUNEVERYWHERE,
                                   $CATCONSERIAL);
    #
    # Display inclusion list to process
    #
    if (!$gsRTInclusion)
    {
        $gsRTInclusion = $gsDbName;
    }

    catctlPrintMsg("$MSGIFORCEDCLEANUP Completed [$gsRTInclusion]\n",
                   $TRUE,$TRUE);
    
    return($giRetCode);


} # End of catctlRunForcedCleanup

######################################################################
# 
# catctlRunSerial - Run command in serially
#
# Description:
#   Does not break files into phase but just runs file as is.
#
# Parameters:
#   - None
# Returns:
#   - None
#
######################################################################
sub catctlRunSerial
{

    my @SqlArray;

    $giStartPhase = @phase_type;
    $gtLastTime = time();

    #
    # Display Serial inclusion if any take directly from user.
    #
    catctlPrintMsg(
        "PDB Serial Inclusion:[$gCInclusion] Exclusion:[$gCExclusion]\n",
         $TRUE,$TRUE);

    #
    # run all scripts in this phase single-threaded
    #
    catctlPrintMsg("$MSGIRUNSERIAL $gsPath\n",$TRUE,$TRUE);

    push (@SqlArray, "\@$gsPath");

    $giRetCode =
        catconExec(@SqlArray,
                   $CATCONSERIAL,      # run single-threaded
                   0,  # run in every Container if the DB is Consolidated
                   0,  # Don't issue process init/completion statements
                   $gCInclusion,       # Inclusion list 
                   $gCExclusion,       # Exclusion List
                   $gsNoIdentifier,    # No SQL Identifier
                   $gsNoQuery);        # No Query


    if ($giRetCode)
    {
        catctlDie("$MSGFCATCONEXEC $!");
    }

} # End of catctlRunSerial


######################################################################
# 
# catctlRunPhase - Run SQL Phase
#
# Description:
#   Run Sql Phase.
#
# Parameters:
#   - phase number (IN)
#   - Number of files in phase (IN)
#   - Inclusion List for Containers (IN)
#   - Exclusion List for Containers (IN)
#   - SQL identifier (IN)
# Returns:
#   - None
#
######################################################################
sub catctlRunPhase
{
    my $phaseNo         = $_[0];  # Phase No
    my $numOfPhaseFiles = $_[1];  # No of Phase Files
    my $pInclusion      = $_[2];  # Inclusion List for Containers
    my $pExclusion      = $_[3];  # Exclusion List for Containers
    my $SqlIdentifier   = $_[4];  # SQL Identifier

    #
    # Start Phase Info After shutdown only the
    # one process is active errors on all the
    # others.
    #
    catctlStartPhase($phaseNo,
                     $pInclusion,
                     $pExclusion);

    #
    # Check if the phase has some files to process
    #
    if ($numOfPhaseFiles > 0)
    {
        # Execute phase files
        catctlExecutePhaseFiles($phaseNo,
                                $numOfPhaseFiles,
                                $pInclusion,
                                $pExclusion,
                                $SqlIdentifier);
    }

    # registry$upg_resume table is not yet created when phase 0 starts running,
    # respective row in the table is deferred to previous of the phase end.
    if ($phaseNo == 0)
    {
	   catctlAutoPhaseTrace ($phaseNo,"I",$phase0_starttime,$gsRTInclusion);
    }

    #
    # End Phase Info
    #
    catctlEndPhase($phaseNo,
                   $pInclusion,
                   $pExclusion);

} # End of catctlRunPhase

######################################################################
# 
# catctlRunPhases - Runs SQL Phases
#
# Description:
#   Runs Sql Phases. Driver routine for running all phases.
#
# Parameters:
#   - Starting phase no (IN)
#   - End phase no (IN)
#   - Catctl Last Job (IN)
#   - Inclusion List for Containers (IN)
#   - Exclusion List for Containers (IN)
#   - SQL identifier (IN)
# Returns:
#   - None
#
######################################################################
sub catctlRunPhases
{
    my $StartPhaseNo  = $_[0];     # Start Phase
    my $StopPhaseNo   = $_[1];     # Stop Phase
    my $LastJob       = $_[2];     # Last Phase Job
    my $DspStopPhaseNo = ($StopPhaseNo - 1); 
    my $pInclusion    = $_[3];     # Inclusion List for Containers
    my $pExclusion    = $_[4];     # Exclusion List for Containers
    my $SqlIdentifier = $_[5];     # SQL Identifier
    my $DateTime      = 0;         # Time Data
    my $pInc = $pInclusion ? $pInclusion : $NONE;
    my $pExc = $pExclusion ? $pExclusion : $NONE;
    my $CdbMsg = $gbCdbDatabase ? 
        "Container Lists Inclusion:[$pInc] Exclusion:[$pExc]\n" :
        "";
    my $AbortFile = $gsSpoolDir.$SLASH.$ABORTFILE;

    #
    # Display Info To Screen
    #
    if ($StartPhaseNo < $StopPhaseNo)
    {
        $DateTime  = "        Start Time:[".catctlGetDateTime(0)."]";
        catctlPrintMsg("\n$LINETAG\n".
                       "Phases [$StartPhaseNo-$DspStopPhaseNo] $DateTime\n".
                       $CdbMsg.
                       "$LINETAG\n", $TRUE,$TRUE);
    }

    #
    # Loop Through the phases
    #
    for ($giph = $StartPhaseNo; $giph < $StopPhaseNo; $giph++)
    {
        #
        # Abort if abort file is present
        #
        if (-e $AbortFile)
        {
            $DateTime  = "[".catctlGetDateTime(0)."]";
            catctlPrintMsg("\n$LINETAG\n".
                           "Upgrade on $gsDbName aborted on Phase [$giph] ".
                           "at $DateTime due to the presence of [$AbortFile]\n".
                           "$LINETAG\n", $TRUE,$TRUE);
            $giph =  $StopPhaseNo;
            next;
        }

        #
        # Set Number of Files
        #
        $giNumOfPhaseFiles = @{$phase_files[$giph]};

        #
        # Check to see if we move onto the next phase
        #
        if (catctlCheckPostUpgrade($giph,
                                   $giNumOfPhaseFiles,
                                   $pInclusion,
                                   $pExclusion,
                                   $StartPhaseNo,
                                   $StopPhaseNo) == $NEXTPHASE)
        {
            next;
        }

        #
        # Display Info To Screen
        #
        catctlDisplayPhaseInfo($giph,
                               $giNumOfPhaseFiles,
                               $pInclusion,
                               $pExclusion,
                               $gsDbName);

        #
        # Check For Shutdown
        #
        if (catctlCheckShutdown($giph, $pInclusion,
                                $pExclusion) == $NEXTPHASE)
        {
            next;
        }

        #
        # Check For Restart Sql Processes
        #
        if (catctlCheckRestartSqlProcesses($giph) == $NEXTPHASE)
        {
            next;
        }

        #
        # Check Loading with Compile on or off
        #
        if (catctlCheckLoadCompile($giph) == $NEXTPHASE)
        {
            next;
        }

        catctlRunPhase($giph,
                       $giNumOfPhaseFiles,
                       $pInclusion,
                       $pExclusion,
                       $SqlIdentifier);

        #
        # Update the Report Name after running first phase
        #
        if ($giph == $StartPhaseNo)
        {
            $giRetCode = catctlUpdRptName($gsReportName,
                                          $pInclusion,
                                          $pExclusion);
        }

        #
        # Make sure these routines get called when and end phase is specified
        #
        if ((($giph+1) == $StopPhaseNo) && ($LastJob != $StopPhaseNo))
        {
            #
            # Set User Table Spaces back to Read Write
            #
            if ($gbROTblSpace)
            {
                my $sIncList = $gbCdbDatabase ? $pInclusion : $gsNoInclusion;
                catctlSetUserWriteTableSpace($sIncList,
                                             \@AryTblSpaces,
                                             $#AryTblSpaces);
            }
            #
            # Log Errors
            #
            catctlLogErrors($pInclusion,
                            $pExclusion,
                            $gsNoIdentifier);
        }
    }

    #
    # Collect Timings
    #
    $gtSTime   = time();
    $gtSDifSec = $gtSTime  - $gtLastTime;
    $gtTotSec  = $gtTotSec + $gtSDifSec;
    catctlPrintMsg("    $TOTALTIME$gtSDifSec$DSPSECS\n",
                   $TRUE,$TRUE);
    $gtLastTime = time();

   #
   # Display Info To Screen
   #
   if ($StartPhaseNo < $StopPhaseNo)
   {
       $DateTime  = "        End Time:[".catctlGetDateTime(0)."]";
       catctlPrintMsg("\n$LINETAG\n".
                      "Phases [$StartPhaseNo-$DspStopPhaseNo] $DateTime\n".
                      $CdbMsg.
                      "$LINETAG\n", $TRUE,$TRUE);
   }


} # End of catctlRunPhases

######################################################################
## The following subroutines are here to support Replay Upgrade

#
# get_prop
#   
# Description
#   Obtain value of a specified property from DATABASE_PROPERTIES
#
# Parameters:
#   - property name
#   - a command to create a file whose existence will indicate that the 
#     last statement of the script has executed (needed by exec_DB_script())
#   - base for a name of a "done" file (see above)
#
# Returns
#   Value of the specified property
#
sub get_prop {
    my $propName = $_[0];
    my $pdbName = $_[1];
    my $propSql = "select property_value from database_properties ".
                  "where property_name='".$propName."'";
    # Bug 25578247: call catctlQuery with pdbName
    my $propVal = catctlQuery($propSql, $pdbName);
     
    return $propVal;
}

#
# replay_enabled
#   
# Description
#   Returns whether Replay Upgrade is enabled, checking a database property
#
# Returns
#   a string consisting of names of PDBs in which PDB_UPGRADE_SYNC is enabled
#   and a string consisting of names of PDBs in which PDB_UPGRADE_SYNC is 
#   disabled; either (but not both) may be empty
#
sub replay_enabled {
    # Replay Upgrade is disabled if resume/start phase/end phase are explicit
    if ($opt_p or $opt_P or $opt_R)
    {
        return (undef, $_[0]);
    }

    # strings which will contain names of PDBs with PDB_UPGRADE_SYNC 
    # enabled and disabled
    my $enabled = "";
    my $disabled = "";

    # obtain value of PDB_UPGRADE_SYNC property in PDBs whose names were 
    # supplied by the caller
    #
    # NOTE: $_[0] may contain multiple PDB names.  Some of these PDBs may have 
    #       PDB_UPGRADE_SYNC property set, while others don't

    my @pdbArr = split(/  */, $_[0]);
    
    foreach my $pdb (@pdbArr) {
      my $pdbUpgradeSync = get_prop("PDB_UPGRADE_SYNC", $pdb);

      # Bug 25376281: check if $pdbUpgradeSync is defined (since get_prop 
      #   will return undef if database_properties did not contain a row 
      #   for PDB_UPGRADE_SYNC) before attempting to compare it with TRUE
      # Bug 25777236: check if PDB_UPGRADE_SYNC has value more than 0 instead
      if ((defined $pdbUpgradeSync) && $pdbUpgradeSync > 0) {
        $enabled .= " $pdb";
      } else {
        $disabled .= " $pdb";
      }
    }

    if ($enabled) {
      # get rid of the leading blank since in some places code does not expect 
      # to find a PDB name preceeded by a blank
      $enabled =~ s/^\s+//g;
    }

    if ($disabled) {
      # get rid of the leading blank since in some places code does not expect 
      # to find a PDB name preceeded by a blank
      $disabled =~ s/^\s+//g;
    }

    return ($enabled, $disabled);
}

#
# catctlPrintPhaseTiming
#   
# Description
#   Used for Replay Upgrade. Using the contents of registry$upg_resume, prints
#   out timing information for each phase that has been replayed.
#
sub catctlPrintPhaseTiming
{
    my $pdb = $_[0]; # PDB name
    
    # get from registry$upg_resume
    my $phasenoSql = "select phaseno from registry\$upg_resume order by phaseno";
    # get phase times (sysdate to convert to days, then 24 * 60 * 60 for seconds)
    my $phasetimesSql =
           "select round((sysdate + (endtime-starttime)*1000 - sysdate)*86.4) time ".
           "from registry\$upg_resume order by phaseno";

    my @phasenos = catctlAryQuery($phasenoSql, $pdb);
    my @phasetimes = catctlAryQuery($phasetimesSql, $pdb);
    my $i = 0;
    
    $giLastJob    = @phase_type;
    $giEndPhaseNo = $giStopPhase ? ($giStopPhase+1) : $giLastJob;
    
    for my $giph (0 .. $giEndPhaseNo)
    {
        # update time since start of run
        $gtSTime  = time();
        $gtSDifSec = $gtSTime - $gtLastTime;
        $gtTotSec = $gtTotSec + $gtSDifSec;
        
        # if we have the timing info
        if ($i <= $#phasenos && $giph == $phasenos[$i])
        {
          $giNumOfPhaseFiles = @{$phase_files[$giph]};

          catctlDisplayPhaseInfo($giph, $giNumOfPhaseFiles, $pdb, "", $gsDbName);
          catctlPrintMsg("    $TOTALTIME" . $phasetimes[$i] . "$DSPSECS\n",
                         $TRUE,$TRUE);
          $i = $i + 1;
        }
        # otherwise, still display the phase description if applicable
        else
        {
          catctlDisplayPhaseDesc($giph);
        }
    }
}

#
# catctlRunReplayUpgrade
#   
# Description
#   Executes Replay Upgrade.
#   Runs upgrdpdb.sql, prints out phase timing, executes post-upgrade 
#
sub catctlRunReplayUpgrade
{
    my $Inclusion    = $_[0];     # Inclusion List for Containers
    my $Exclusion    = $_[1];     # Exclusion List for Containers
    my $SqlIdentifier = $_[2];     # SQL Identifier

    my $DateTime      = 0;         # Time Data
    my @SqlAry;               # Sql Array
    my $CdbMsg = $gbCdbDatabase ? 
        "Container Lists Inclusion:[$Inclusion] Exclusion:[$Exclusion]\n" :
        "";
    my $CLOSEPDB = "alter pluggable database close immediate instances=all";
    my $OPENPDBUPG = "alter pluggable database open upgrade";

    # App Roots get upgraded before App Root Clones and App PDBs, which means 
    # that they need to be open in UPGRADE mode after their post-upgrade 
    # phase (so that App Root Clones and App PDBs can be upgraded) and the 
    # App PDBs need to be reopened in UPGRADE mode after App Root gets closed 
    # and reopened for UPGRADE
    my $OPEN_APP_PDBS_UPG = "alter pluggable database %s open upgrade";

    my $OPENPDBNOR = "alter pluggable database open";

    # $Inclusion should just contain one PDB, so append dir name with that
    my $DIRNAME = "upg\$spool\$dir\$$Inclusion";
    my $CREATEUPGDIR =
                "create or replace directory $DIRNAME as '$gsSpoolDir'";
    my $DROPUPGDIR = "drop directory $DIRNAME";
    
    # table containing one row, for the first log file name
    # use line breaks for catctlExecSqlFile
    my $CREATELOGTBL = "create table upg\$spool\$log (filename varchar2(256));\n";
    my $DELLOGTBL = "delete from upg\$spool\$log;\n";
    my $INSLOGFILE = "insert into upg\$spool\$log values ".
                     "('" . $gsSpoolLog . "0.log');\n".$COMMITCMD;
    my $DROPLOGTBL = "drop table upg\$spool\$log\n";

    my $rootInclusion = "CDB\$ROOT " . $Inclusion;

    # create temporary directory object for $gsSpoolDir. This directory
    # needs to be common, as Path Prefix PDBs cannot use local directories
    # with absolute paths
    @SqlAry = ($CREATEUPGDIR);
    $giRetCode =
        catconExec(@SqlAry,
                   $CATCONSERIAL,   # run single-threaded
                   0,  # run in every Container if the DB is Consolidated
                   0,  # Don't issue process init/completion statements
                   $rootInclusion, # Inclusion List for Containers
                   $Exclusion,      # Exclusion List for Containers
                   $SqlIdentifier,  # SQL Identifier
                   $gsNoQuery);     # component query for PDB (no query)

    # create table containing log file name
    @SqlAry = ($CREATELOGTBL . $DELLOGTBL . $INSLOGFILE);
    $giRetCode =
        catctlExecSqlFile(\@SqlAry,
                          0,
                          $Inclusion,
                          $Exclusion,
                          0,
                          $CATCONSERIAL);

    $DateTime  = "        Start Time:[".catctlGetDateTime(0)."]";
    $gtLastTime = time();
    catctlPrintMsg("\n$LINETAG\n".
                   "$DateTime\n".
                   $CdbMsg.
                   "$LINETAG\n", $TRUE,$TRUE);

    @SqlAry = ($UPGRADEREPLAYJOB);

    # run all scripts in this phase single-threaded
    $giRetCode =
        catconExec(@SqlAry,
                   $CATCONSERIAL,   # run single-threaded
                   0,  # run in every Container if the DB is Consolidated
                   0,  # Don't issue process init/completion statements
                   $Inclusion,      # Inclusion List for Containers
                   $Exclusion,      # Exclusion List for Containers
                   $SqlIdentifier,  # SQL Identifier
                   $gsNoQuery);     # component query for PDB (no query)

    # insert upg_summary location, and
    # run catresults.sql to generate upg_summary.log
    @SqlAry = ($CATRESULTSJOB); 

    $giRetCode = catctlUpdRptName($gsReportName,
                                  $Inclusion,
                                  $Exclusion);

    $giRetCode =
        catconExec(@SqlAry,
                   $CATCONSERIAL,   # run single-threaded
                   0,  # run in every Container if the DB is Consolidated
                   0,  # Don't issue process init/completion statements
                   $Inclusion,      # Inclusion List for Containers
                   $Exclusion,      # Exclusion List for Containers
                   $SqlIdentifier,  # SQL Identifier
                   $gsNoQuery);     # component query for PDB (no query)

    # output phase information
    catctlPrintPhaseTiming($Inclusion);

    # drop temporary directory object for $gsSpoolDir
    @SqlAry = ($DROPUPGDIR);
    $giRetCode =
        catconExec(@SqlAry,
                   $CATCONSERIAL,   # run single-threaded
                   0,  # run in every Container if the DB is Consolidated
                   0,  # Don't issue process init/completion statements
                   $rootInclusion, # Inclusion List for Containers
                   $Exclusion,      # Exclusion List for Containers
                   $SqlIdentifier,  # SQL Identifier
                   $gsNoQuery);     # component query for PDB (no query)

    # drop table containing log file
    @SqlAry = ($DROPLOGTBL);
    $giRetCode =
        catconExec(@SqlAry,
                   $CATCONSERIAL,   # run single-threaded
                   0,  # run in every Container if the DB is Consolidated
                   0,  # Don't issue process init/completion statements
                   $Inclusion,      # Inclusion List for Containers
                   $Exclusion,      # Exclusion List for Containers
                   $SqlIdentifier,  # SQL Identifier
                   $gsNoQuery);     # component query for PDB (no query)

    # Bug 26527096: if we are about to close and reopen a PDB, we need to 
    #   determine if the PDB is an App Root Clone which cannot be closed or 
    #   opened (but its App Root, from which it inherits the mode in which it 
    #   is open, is expected to be open in the correct mode)
    my $appRootClone = $FALSE;
    my $appRoot = $FALSE;
    my $appPdb = $FALSE;

    if ($Inclusion) {
      my $pdbType = catconPdbType($Inclusion);
          
      if (! defined $pdbType) {
        catctlDie("$MSGFCATCONPDBTYPE $!");
      }
          
      if ($pdbType == catcon::CATCON_PDB_TYPE_APP_ROOT_CLONE) {
        # remember that the current PDB is an App Root Clone
        $appRootClone = $TRUE;
      } elsif ($pdbType == catcon::CATCON_PDB_TYPE_APP_ROOT) {
        $appRoot = $TRUE;
      } elsif ($pdbType == catcon::CATCON_PDB_TYPE_APP_PDB) {
        $appPdb = $TRUE;
      }
    } else {
      catctlPrintMsg("Replay Upgrade: Inclusion was not set\n", $TRUE, $FALSE);
    }

    # Upgrade mode datapatch: close and reopen in migrate mode (unless 
    # the PDB is an App Root Clone)
    if (!$appRootClone) {
      @SqlAry = ($CLOSEPDB, $OPENPDBUPG); 
      $giRetCode =
        catconExec(@SqlAry,
                   $CATCONSERIAL,   # run single-threaded
                   0,  # run in every Container if the DB is Consolidated
                   0,  # Don't issue process init/completion statements
                   $Inclusion,      # Inclusion List for Containers
                   $Exclusion,      # Exclusion List for Containers
                   $SqlIdentifier,  # SQL Identifier
                   $gsNoQuery);     # component query for PDB (no query)
    }

    # Record timestamp for datapatch begin in upgrade mode
    catctlTimestamp("DP_UPG_BGN", $Inclusion);
    
    # Upgrade mode Datapatch
    catctlDatapatch("upgrade",$gUserName,$gUserPass,$Inclusion,"DP_UPG_BGN");

    # Record timestamp for datapatch end in upgrade mode
    catctlTimestamp("DP_UPG_END", $Inclusion);

    # close and reopen in normal mode unless (bug 26527096) the PDB is an
    # - App Root Clone, in which case it cannot be closed or opened (but 
    #   its App Root, from which it inherits the mode in which it is open, is 
    #   expected to be open in the correct mode) or
    # - App PDB, in which case we need to open it for UPGRADE instead of RW, or
    # - App Root, in which case we need to open it and all of its App PDBs 
    #   for UPGRADE
    #
    #   We are doing it to App Roots to accommodate performing 
    #   upgrade on App Root Clones (which cannot be opened independently but 
    #   are open in the same mode as their App Roots) and App PDBs
    #   which happen after App Root has been upgraded.  Having done 
    #   it to App Roots, we have little choice but to also do it to 
    #   App PDBs

    if ($appRootClone) {
      # do not close/open App Root Clones
      catctlPrintMsg("Replay Upgrade: PDB $Inclusion is an App Root Clone ".
                     "which cannot be closed or opened\n", $TRUE, $FALSE);
      @SqlAry = (); 
    } elsif ($appPdb) {
      my $msg = "Replay Upgrade: PDB $Inclusion is an App PDB and needs to ".
        "be open for UPGRADE\n";
      catctlPrintMsg($msg, $TRUE, $FALSE);

      @SqlAry = ($CLOSEPDB, $OPENPDBUPG); 
    } elsif ($appRoot) {
      # in addition to opening the App Root for UPGRADE, we need to reopen
      # for UPGRADE any of its App PDBs which were open before we bounced the 
      # App Root since they will be upgraded after App Root post-upgrade is 
      # completed and are expected to be opened for UPGRADE

      # a query (which will be run from the App Root) to obtain names of 
      # App PDBs belonging to the App Root which are currently open
      my $findOpenAppPdbsQuery = 
        "select app_pdbs.pdb_name ".
          "from sys.dba_pdbs app_pdbs, sys.dba_pdbs app_root, ".
          "     sys.v\$pdbs pdbs ".
         "where app_root.pdb_name = '".$Inclusion."' ".
           "and app_pdbs.application_root_con_id = app_root.pdb_id ".
           "and app_pdbs.application_clone = 'NO' ".
           "and app_pdbs.pdb_id = pdbs.con_id ".
           "and pdbs.open_mode != 'MOUNTED'";

      my $msg = "Replay Upgrade: PDB $Inclusion is an App Root and it ";

      my @appPdbs = catctlAryQuery($findOpenAppPdbsQuery, undef);

      if (@appPdbs) {
        my $appPdbList = join(',', @appPdbs);

        @SqlAry = ($CLOSEPDB, $OPENPDBUPG, 
                   sprintf($OPEN_APP_PDBS_UPG, $appPdbList));

        $msg .= "and its App PDBs which are currently open ($appPdbList) ".
          "need ";
      } else {
        @SqlAry = ($CLOSEPDB, $OPENPDBUPG); 

        $msg .= "needs ";
      }

      $msg .= "to be reopened for UPGRADE\n";

      catctlPrintMsg($msg, $TRUE, $FALSE);
    } else {
      catctlPrintMsg("Replay Upgrade: PDB $Inclusion is a regular PDB ".
                     "and will be open RW\n", $TRUE, $FALSE);
      @SqlAry = ($CLOSEPDB, $OPENPDBNOR); 
    }

    if (@SqlAry) {
      $giRetCode =
        catconExec(@SqlAry,
                   $CATCONSERIAL,   # run single-threaded
                   0,  # run in every Container if the DB is Consolidated
                   0,  # Don't issue process init/completion statements
                   $Inclusion,      # Inclusion List for Containers
                   $Exclusion,      # Exclusion List for Containers
                   $SqlIdentifier,  # SQL Identifier
                   $gsNoQuery);     # component query for PDB (no query)
    }

    #
    # Setup for the Post Upgrade
    #
    catctlPostUpgrade($Inclusion,
                      $Exclusion,
                      $DBOPENNORMAL,
                      $gbUpgradeMode,
                      $gbErrorFound);

    # Record timestamp for datapatch begin in normal mode
    catctlTimestamp("DP_NOR_BGN", $Inclusion);

    #
    # 17277459: Call datapatch again in normal mode, this time to install any
    # remaining PSUs or bundles that did not require upgrade mode.
    #
    catctlDatapatch("normal",$gUserName,$gUserPass,$Inclusion,"DP_NOR_BGN");

    # Record timestamp for datapatch end in normal mode
    catctlTimestamp("DP_NOR_END", $Inclusion);
}

## End subroutines that support Replay Upgrade
######################################################################

######################################################################
# 
# catctlRunMainPhases - Runs Root Phases and non-cdb phases 
#
# Description:
#   This routine runs the Root or Non-cdb phases 
#
# Parameters:
#   - None
# Returns:
#   - None
#
######################################################################
sub catctlRunMainPhases
{
my $pInclusion = $gbInstance ? $gsRTInclusion : $gsDbName;

	if ($gbAutoRstUpg and $opt_p)
	{
    		catctlDie("$MSGINVALIDOPTS_STARTPHASE_AUTOUPGRADE Exiting.\n");
	}

    #
    # If we are not processing the root and this is not
    # an instance then get out
    #
    if ($gbCdbDatabase)
    {
       if ((!$gbRootProcessing) && (!$gbInstance))
       {
           return;
       }

       #
       # Process the root only
       #
       if ($gbRootProcessing)
       {
           #
           # This causes problems for DBUA because the DBUA does
           # not have any PDBs open when it upgrades CDB$ROOT. The resulting
           # list was empty thus causing the following errors.
           #  catconExec - Unexpected error returned by validate_con_names
           #  validate_con_names - returned an empty list of PDBs
           # catconForce should override this condition and continue
           # but it does not.
           #
           #catctlShutDownDatabase($SHUTDOWNJOB,
           #                       $RUNEVERYWHERE,
           #                       $gsNoInclusion,
           #                       $CDBROOT);
           $gsRTInclusion = $CDBROOT;
           $gsRTExclusion = $gsNoExclusion;
 	   $pInclusion    = $gsRTInclusion;
       }
    }

    # Determine if this is an upgrade resume (coming from a failed upgrade).
    # If so, failed phase will be identified and set for -p parameter to 
    # start re-upgrade from failed phase. It will also delete failed phase
    # row from registry$upg_resume table.
    if ($gbAutoRstUpg)
    {
        $giStartPhase = catctlAutoIsRestart($pInclusion);
        if ($giStartPhase<-2)
        {
                $giStartPhase= abs($giStartPhase);
                $gbStartStopPhase = $TRUE;
                catctlAutoRestartMaint($giStartPhase,$pInclusion);
		catctlPrintMsg("\n** Database $pInclusion has already been upgraded successfully. **\n",$TRUE,$TRUE);
        }
        elsif ($giStartPhase==-2)
        {
                catctlDie("$MSGIDBNOTUPGRADED Exiting.\n");
        }
        else
        {
        $gbStartStopPhase = $TRUE;
        catctlAutoRestartMaint($giStartPhase,$pInclusion);
        catctlPrintMsg("\n*******Upgrade being restarted on database $pInclusion from failed phase " . $giStartPhase ."*******\n",$TRUE,$TRUE);
        }
    }

    #
    # Set User Table Spaces Read-Only Only pass inclusion list
    # if upgrading a pdb make sure that we are setting the 
    # correct table space for the PDB by passing in the
    # inclustion list.
    #
    if ($gbROTblSpace)
    {
        my $sIncList = $gbInstance ? $gsRTInclusion : $gsNoInclusion;
        @AryTblSpaces = catctlSetUserReadOnlyTableSpace($sIncList,$giDBMajorVer,'RO');
    }

    #
    # If upgrading PDB(s) and PDB_UPGRADE_SYNC was set for some of them, 
    # perform replay upgrade instead of phases.
    #
    if ($gsUpgradeSyncPdbs)
    {
      catctlRunReplayUpgrade($gsUpgradeSyncPdbs,
                             $gsRTExclusion,
                             $gsRTIdentifier);

      if (!$gsNoUpgradeSyncPdbs) {
        # if PDB_UPGRADE_SYNC was set for all PDBs in $gsRTInclusion, we 
        # are done
        return;
      }
    }
   
    #
    # Run the phases For CDB Root or Non-CDB Database
    #
    $giLastJob    = @phase_type;
    $giEndPhaseNo = $giStopPhase ? ($giStopPhase+1) : $giLastJob;
    
        if (catctlIsNonCDBOkay())
        {
                 # if processing PDB(s), pass names of PDBs for which 
                 # PDB_UPGRADE_SYNC was not set; otherwise pass $gsRTInclusion
                 catctlRunPhases($giStartPhase,
                                 $giEndPhaseNo,
                         	 $giLastJob,
                         	 $gbInstance ? $gsNoUpgradeSyncPdbs 
                                             : $gsRTInclusion,
                         	 $gsRTExclusion,
                         	 $gsRTIdentifier);
        }
    #
    # Set Root Processing False
    # We are done processing the
    # root we are now moving onto
    # the Pdb's.
    #
    $gbRootProcessing = $FALSE;

}

######################################################################
# 
# catctlRunPDBInstances - Runs PDB Instances 
#
# Description:
#   This routine runs the PDB upgrade in a separate catctl.pl instance. 
#
# Parameters:
#   Input: PDB Process Count.
#
# Returns:
#   - None
#
######################################################################
sub catctlRunPDBInstances
{
    my $pPdbProcess = $_[0]; # PDB Process count
    my $ErrMsg      = "";    # Error Message

    #
    # Get out if we are already running a PDB Instance
    #
    if ($gbInstance)
    {
        return;
    }

    #
    # Only Do for CDB databases and when
    # No Start and Stop phases have been
    # specified.
    #
    if (($gbCdbDatabase    == $FALSE) ||
        ($gbErrorFound     == $TRUE))
    {
        return;
    }


    #
    # Troll Log Files for errors
    #
    $ErrMsg = catctlReadLogFiles($gsSpoolLogDir);

    #
    # If Errors found get out.
    #
    if ($gbErrorFound     == $TRUE)
    {
        return;
    }

    #
    # Reset Inclusion/Exclusion lists back to the PDB's
    #
    $gsRTInclusion = $gsParsedInclusion;
    $gsRTExclusion = $gsParsedExclusion;

    #
    # Startup the Instances
    #
    catctlStartPdbInstances($pPdbProcess);

} # End of catctlRunPDBInstances

######################################################################
# 
# catctlStartPdbInstances - Start PDB Instances          
#
# Description:
#
#   This starts the PDB instances that runs Parallel within a PDB.
#
# Parameters:
#   Input: PDB Process Count.
#
# Returns:
#   - None
#
######################################################################
sub catctlStartPdbInstances
{
    my  $pPdbProcess =  $_[0]; # PDB Process count
    my  $CatctlArgs = ""; # Construct Catctl Command
    my  $argno = 0;
    my  $argcnt = $#gArgs;
    my  $argloop = ($argcnt -1);
    my  $tmp = "";
    my  $bIgnore = $FALSE;
    my  @threads;
    my  $PdbFileName;
    my  $CatctlProgram = $^X." ".$0;
    my  $iSubmitted = 0;
    my  $PriRunFile = $gsSpoolDir.$SLASH.$PRIORITYFILE."_run.lst"; # Run File
    my  $Msg = "";

    if ($gbEmulate)
    {
        #
        # Open the run priority file
        #
        open (FileRun, '>', $PriRunFile) or 
            catctlDie("$MSGFCATCTLPRIFILE - $PriRunFile $!");
        if ($gbSavRootProcessing)
        {
            print FileRun "$HashPdbPriData{$CDBROOT},$CDBROOT\n";
            print FileRun "$LINETAG\n";
        }
    }
    else
    {
        #
        # Can't emulate Priority upgrades from the database
        # since column UPGRADE_PRIORITY won't be in table
        # container$ until after 12.2.  After 12.2 we will
        # be able to emulate from the database without a
        # priority list but for now we will update container$
        # for the customer so on the next upgrade he won't need
        # the priority list.
        #
        if ($gsPriFile)
        {
            catctlUpdPriorityList();
        }
    }

    #
    # Close all sessions except one. PDB's will start their own.
    #
    $giRetCode = catconUpgEndSessions();

    # remember whether catcon has determined that it may be able to use 
    # multiple instances to upgrade PDBs
    my $multInst = catconMultipleInstancesFeasible();

    if (! defined $multInst) {
      catctlPrintMsg("catconMultipleInstancesFeasible returned undef\n", 
                     $TRUE, $FALSE);
    } else {
      catctlPrintMsg("catconMultipleInstancesFeasible returned ".
                     "$multInst", $TRUE, $FALSE);
    }

    #
    # Wrap up sessions in master catctl controller we are done.
    #
    catconWrapUp();
    $gbLogon  = $FALSE;
    $gbWrapUp = $FALSE;

    # maximum number of threads that may be running at the same time
    # if only 1 instance will be used, we will spawn $giPdbInstances threads; 
    # otherwise, we will spawn just 1 thread
    my $maxThreads = ($multInst ? 1 : $giPdbInstances);

    # Bug 26527096: group PDBs by UPGRADE_LEVEL

    # array of references to arrays of PDB names at a given UPGRADE_LEVEL 
    # sorted by UPGRADE_PRIORITY within each UPGRADE_LEVEL
    my @pdbsGroupedByUpgradeLevel;

    $giRetCode = catconGroupByUpgradeLevel(\@AryPDBInstanceList, 
                                           \@pdbsGroupedByUpgradeLevel);
    if ($giRetCode) {
      catctlDie("$MSGFCATCONGRPBYUPGLVL $!");
    }

    catctlPrintMsg ("pdbsGroupedByUpgradeLevel contains ".
                    @pdbsGroupedByUpgradeLevel." elements\n",
                    $TRUE, $FALSE);

    for my $upgradeLevel (0 .. $#pdbsGroupedByUpgradeLevel) {
      # if no PDBs mapped to the current UPGRADE_LEVEL, skip to the next level
      if (!$pdbsGroupedByUpgradeLevel[$upgradeLevel]) {
        catctlPrintMsg ("no PDBs at UPGRADE_LEVEL $upgradeLevel\n",
                        $TRUE, $FALSE);

        next;
      }

      catctlPrintMsg ("processing PDBs at UPGRADE_LEVEL $upgradeLevel\n",
                      $TRUE, $FALSE);

      # reference to an array of PDB names at the current UPGRADE_LEVEL
      my $pdbsAtCurrUpgLvlRef = $pdbsGroupedByUpgradeLevel[$upgradeLevel];

      # index into array of names of PDBs at the current UPGRADE_LEVEL of 
      # the first PDB which will be assigned to the thread
      my $currPdb = 0;

      # number of PDBs at the current UPGRADE_LEVEL
      my $numPdbs = @$pdbsAtCurrUpgLvlRef;

      # if the CDB will be upgraded using a single instance, each thread will 
      # handle one PDB; otherwise a thread will handle ALL PDBs on a given 
      # Upgrade Level using multiple RAC instances
      my $pdbsPerThread = ($multInst ? $numPdbs : 1);
    
      # process all PDBs at the current UPGRADE_LEVEL
      while ($currPdb < $numPdbs)
      {
        # index of the last PDB which will be assigned to the thread
        my $lastPdb = $currPdb + $pdbsPerThread - 1;

        # if the number of PDBs left to be processed is less than the number 
        # of PDBs we would like to assign to the thread, adjust $lastPdb 
        # accordingly
        if ($pdbsPerThread > 1 && $lastPdb > $numPdbs - 1)
        {
          $lastPdb = $numPdbs - 1;
        }

        # names of PDBs which will be processed during this iteration
        my $pdbNames = join($SPACE, @$pdbsAtCurrUpgLvlRef[$currPdb..$lastPdb]);

        if ($currPdb == $lastPdb) {
          catctlPrintMsg ("processing PDB $pdbNames\n", $TRUE, $FALSE);
        } else {
          catctlPrintMsg ("processing PDBs ( $pdbNames )\n", $TRUE, $FALSE);
        }

        #
        # Initialize for each PDB
        #
        $bIgnore    = $FALSE;
        $tmp        = "";
        $CatctlArgs = "";

        #
        # Construct base filename by appending to the value supplied by the 
        # caller
        # - the PDB name if CDB is running on a single instance or
        # - string "RAC" otherwise.  catcon will append <pdb_name>[01] to the 
        #   base file name when constructing names of log files produced by 
        #   running scripts against individual PDBs
        #
        if (!$multInst)
        {
          $PdbFileName = lc($pdbsAtCurrUpgLvlRef->[$currPdb]);
          $PdbFileName =~ s/\W/_/g;
        }
        else
        {
          $PdbFileName = "";
        }

        #
        # Construct the PDB instance by
        # re-assembling the command
        #
        foreach $argno (0 .. $argloop)
        {
            #
            # Skip Next Arg
            #
            if ($bIgnore)
            {
                $bIgnore = $FALSE;
                next;
            }

            #
            # Take Arg by default
            #
            $tmp = " ".$gArgs[$argno];

            #
            # Contruct base file name
            #
            if ($gArgs[$argno] eq "-i")
            {
                $bIgnore = $TRUE;
                $tmp = " -i "."$gArgs[$argno+1]"."$PdbFileName";
            }

            #
            # Set Process count equal to Pdb Process count
            #
            if ($gArgs[$argno] eq "-n")
            {
                $bIgnore = $TRUE;
                $tmp = " -n $pPdbProcess";
            }

            #
            # Set Inclusion Container
            #
            if ($gArgs[$argno] eq "-c")
            {
                $bIgnore = $TRUE;
                $tmp = " -c ".$CONTAINERQUOTE.$pdbNames.$CONTAINERQUOTE;
            }

            #
            # Ignore Exclusion Container
            #
            if ($gArgs[$argno] eq "-C")
            {
                $bIgnore = $TRUE;
                $tmp = "";
            }

            #
            # Concat the command
            #
            $CatctlArgs = $CatctlArgs.$tmp;
            $tmp = "";

            #
            # Call Child in debug mode
            #
            if ($gArgs[$argno] eq "-Z")
            {
                $CatctlProgram = $^X." -d ".$0;
            }

        } # End foreach arg

        #
        # Identify myself as a PDB Instance
        #
        $CatctlArgs = $CatctlArgs." -I";

        #
        # Set Base Filename
        #
        if (!$opt_i)
        {
            # if scripts will be run using all available RAC instances, 
            # catcon will append PDB name to log files
            if (!$multInst)
            {
              $CatctlArgs = $CatctlArgs." -i $PdbFileName";
            }
        }

        #
        # Set process count equal to PDB Process count
        #
        if (!$opt_n)
        {
            $CatctlArgs = $CatctlArgs." -n $pPdbProcess";
        }

        #
        # Set Inclusion PDB
        #
        if (!$opt_c)
        {
            $CatctlArgs = $CatctlArgs.
              " -c ".$CONTAINERQUOTE.$pdbNames.$CONTAINERQUOTE;
        }

        #
        # Set Log File Directory
        #
        if (!$opt_l)
        {
            $CatctlArgs = $CatctlArgs." -l $gsSpoolDir";
        }

        #
        # Add Filename to execute in PDB
        #
        $CatctlArgs = $CatctlArgs." ".$gArgs[$argcnt];

        #
        # Now start the instance in a thread
        #
        push(@threads,
             threads->create (\&catctlProcessInstance,
                              $CatctlProgram, $CatctlArgs, $pdbNames));

        if ($gbEmulate)
        {
            foreach my $pdb (@$pdbsAtCurrUpgLvlRef[$currPdb..$lastPdb])
            {
                print FileRun "$HashPdbPriData{$pdb},$pdb\n";
            }

            if (++$iSubmitted == $maxThreads)
            {
                print FileRun "$LINETAG\n";
                $iSubmitted = 0;
            }
        }

        #
        # run no more than $maxThreads threads at a time
        #
        sleep(1) while(scalar threads->list(threads::running) >= $maxThreads);

        # skip past PDB(s) which have been processed above
        $currPdb = $lastPdb + 1;
      } # End for all PDBs at the current UPGRADE_LEVEL

      # unless we ran out of PDBs at the highest UPGRADE_LEVEL, wait until 
      # all PDBs at the current level has been processed before moving on 
      # to the next level
      if ($upgradeLevel < $#pdbsGroupedByUpgradeLevel) {
        catctlPrintMsg ("wait until all PDBs at UPGRADE_LEVEL $upgradeLevel ".
                        "are processed\n",
                        $TRUE, $FALSE);

        sleep(1) while(scalar threads->list(threads::running) > 0);
      }
    } # End for all UPGRADE_LEVELs

    #
    # Thread cleanup This is where we will make
    # decision if the upgrade was a success or
    # failure by setting the gbErrorFound field
    # to TRUE if any PDB failed.  We are looping
    # Through all the pdb threads to see if anyone
    # failed.  
    #
    foreach (threads->list())
    { 
        my @ThreadRetData = $_->join();

        if ($ThreadRetData[0] != $CATCTL_SUCCESS)
        {   
            $gbErrorFound = $TRUE;

            #
            # Construct base filename by replacing
            # illegal character with _
            #
            $PdbFileName = lc($ThreadRetData[1]);
            $PdbFileName =~ s/\W/_/g;

            $Msg = "Upgrade Error In [".
                $ThreadRetData[1].
                "] Status is [".$ThreadRetData[0]."] ".
                "Check Log Files\n    [".
                $gsSpoolLogDir.$PdbFileName."*.log]\n";
            $gsPdbSumMsg = $gsPdbSumMsg.$Msg;
        }
    }
    delete $ENV{$gsCatconEnvTag};

    if ($gbEmulate)
    {
        print FileRun "$LINETAG\n";
        close (FileRun);
        catctlPrintMsg("\nRun file is [$PriRunFile]\n", $TRUE,$TRUE);
        if (-e $PriRunFile)
        {
            my $Line;
            #
            # Open the run priority file and print it out
            #
            open (FileRun, '<', $PriRunFile) or 
                catctlDie("$MSGFCATCTLPRIFILE - $PriRunFile $!");
            while (<FileRun>)
            {
                $Line = $_;
                chomp ($Line);
                catctlPrintMsg("$Line\n", $TRUE,$TRUE);
            }
            close (FileRun);
        }
    }


} # end of catctlStartPdbInstances

######################################################################
# 
# catctlFatalError - Catctl Ending statements for fatal errors 
#
# Description:
#
#   This procedure is executed in a fatal error.
#
# Parameters:
#   Input:   $psErrorMsg - Trace Message
#
# Returns:
#   - None
#
######################################################################
sub catctlFatalError
{
    my $psErrorMsg   = $_[0];   # Trace Message

    #
    # Single Fatal Error Message
    #
    catctlWriteTraceMsg($psErrorMsg);

    #
    # Set User Table Spaces back to Read Write
    #
    if (($gbROTblSpace) && ($gbWrapUp))
    {
        my $sIncList = $gbCdbDatabase ? $gsRTInclusion : $gsNoInclusion;
        catctlSetUserWriteTableSpace($sIncList,
                                     \@AryTblSpaces,
                                     $#AryTblSpaces,
                                     $giDBMajorVer);
    }

}  # end of catctlFatalError

######################################################################
# 
# catctlEnd - Catctl Ending statements         
#
# Description:
#
#   This is the final statements run in the perl script.
#
# Parameters:
#
#
# Returns:
#   - None
#
######################################################################
sub catctlEnd
{
    my $RtDisplay = "";
    my $ErrMsg    = "";      # Error Message
    my $bWriteMsg = $TRUE;   # Write messages
    my $PostMsg   = "\n";    # Post Message
    my $RptName   = "\n";    # Report Name

    #
    # Read Error log to get Error Messages
    #
    $ErrMsg = catctlReadLogFiles($gsSpoolLogDir);
    if ($ErrMsg)
    {
        $gsPostUpgMsg = $gsPostUpgMsg.$ErrMsg;
    }

    #
    # On Errors Re-Start database in upgrade mode
    #
    catctlReStartDatabase($gbErrorFound,
                          $gbCdbDatabase,
                          $gbSavRootProcessing,
                          $gbInstance,
                          $gsRTInclusion,
                          $gbSeedProcessing,
                          $gbUpgradeMode);
    #
    # Collect Timings
    #
    $gtSTime   = time();
    $gtSDifSec = $gtSTime  - $gtLastTime;
    $gtTotSec  = $gtTotSec + $gtSDifSec;

    #
    # Calculate ROOT and Pdb Times
    #
    if (($gbCdbDatabase) && (!$gbInstance))
    {
        $gtSTime   = $gtTotSec - $gtSDifSec;
        catctlPrintMsg("\n", $TRUE,$TRUE);
        if ($gbSavRootProcessing)
        {
            catctlPrintMsg(
                  "     $TOTALTIME$gtSTime$DSPSECS For $CDBROOT\n",
                  $TRUE,$TRUE);
        }
        if ($gbPdbProcessing)
        {
            catctlPrintMsg(
                  "     $TOTALTIME$gtSDifSec$DSPSECS For PDB(s)\n",
                  $TRUE,$TRUE);
        }

    }

    #
    # Display Grand Totals
    #
    $RtDisplay = "$MSGIGRANDTIME$gtTotSec$DSPSECS ";
    if ($gbInstance)
    {
        #
        # Keep Perl happy if we CTRL C out
        #
        if (!$gsRTInclusion)
        {
            $gsRTInclusion = $NONE;
        }
        $RtDisplay = $RtDisplay."[".$gsRTInclusion."]";
    }
    catctlPrintMsg("\n$RtDisplay\n",$TRUE,$TRUE);


    #
    # Display Post Upgrade Message and summary report name
    #
    if ($gbUpgrade)
    {

        #
        # Don't Display messages if this is cdb database
        # and we are not processing the root.  The instances
        # will display the messages to the user.
        #
        if (($gbCdbDatabase) && 
            (!$gbInstance)   &&
            (!$gbSavRootProcessing))
        {
            $bWriteMsg = $FALSE;
        }

        #
        # Display Error Messages
        #
        if (($bWriteMsg) && ($gbErrorFound))
        {
            $PostMsg = "\n$ERRMSGWPMSG \nREASON:\n $gsPostUpgMsg\n";
        }

        catctlPrintMsg($PostMsg, $TRUE,$TRUE);
        catctlPrintMsg(" LOG FILES: ($gsSpoolDir$SLASH$gsSpoolLog*.log)\n",
                       $TRUE,$TRUE);

        if (-e $gsReportName)
        {
            if ($bWriteMsg)
            {
                $RptName = "\n$MSGIREPORT\n$gsReportName\n";
            }
            catctlPrintMsg($RptName,$TRUE,$TRUE);
        }
    }

    #
    # That's a wrap
    #
    catctlCleanUp();
    catctlWriteStdErrMsgs();

    if ($gbWrapUp)
    {
        #
        # We have to be careful on fatal errors if catcon dies
        # with a signal error and we call catconWrapup we won't
        # return and caller will never get a status back even
        # if we trap with an eval.
        # We will only wrapup on a fatal error if we caused
        # the fatal error to happen.  If catcon caused it we
        # won't wrapup.
        #
        if ($gbFatalError)
        {
            #
            # Did we caused the fatal error through catctldie
            #
            if ($gbCatctlDieError)
            {
                catconWrapUp();
            }
        }
        else
        {
            catconWrapUp();
        }
    }
}  # end of catctlEnd


######################################################################
# 
# catctlProcessInstance - Process PDB instances in a thread          
#
# Description:
#
#   This starts the PDB instance in a thread and waits till completion.
#
# Parameters:
#
# Input
#   pCatctlProgram = catctl.pl
#   pCatctlArgs    = Arguments to catctl.pl
#   pPdbNames      = names of PDBs being processed
#
# Returns:
#   - None
#
######################################################################
sub catctlProcessInstance($$$)
{
    my ($pCatctlProgram,$pCatctlArgs,$pPdbNames) = @_;
    my $retstatus = $CATCTL_SUCCESS;
    
    #
    #
    #
    catctlPrintMsg ("\nStart processing of PDBs ($pPdbNames)\n",1,1);
    catctlPrintMsg ("[$pCatctlProgram$pCatctlArgs]\n",1,1);

    #
    # Call system to execute the command and wait
    # Trap any errors and warn user of the error.
    # We can't die here because we want the other
    # PDB's to run.
    #
    # Note: The return code from a system call is
    # interpreted as 0 success and nonzero as failure.
    # The real return code, if nonzero, is returned in the
    # high-order byte of the return code. To get the actual exit
    # value, shift right by eight. So if catctl.pl returns 1
    # you will get 256 return by the system command. For Example:
    #    $retstatus = 256;
    #    $retstatus = $retstatus >> 8;
    #  The end result of this shift would make $retstatus be equal to 1
    #  and that would be the real error.
    #
    eval
    {
        $retstatus = system("$pCatctlProgram$pCatctlArgs");
        if ($retstatus == -1)
        {
            catctlPrintMsg ("\nError Executing $@\n[$pCatctlProgram$pCatctlArgs".
                            " for PDB(s) ($pPdbNames)] Return Status: [$?] ".
                            "Shifted Status: [$retstatus] Reason: [FAILED TO EXECUTE]\n",
                            1,1);
        }
        elsif ($retstatus & 127)
        {
            catctlPrintMsg ("\nError Executing $@\n[$pCatctlProgram$pCatctlArgs".
                            " for PDB(s) ($pPdbNames)] Return Status: [$?] ".
                            "Shifted Status: [$retstatus] Reason: [SIGNAL ERROR]\n",
                            1,1);
        }
        else
        {
            #
            # Return catctl.pl Exit Status code
            #
            if ($retstatus != $CATCTL_SUCCESS)
            {
                $retstatus = $retstatus >> 8;
            }
        }
    };
    if ($@)
    {
        $retstatus = $?;
        if ($retstatus == -1)
        {
            catctlPrintMsg ("\nError Executing $@\n[$pCatctlProgram$pCatctlArgs".
                            " for PDB(s) ($pPdbNames)] Return Status: [$?] ".
                            "Shifted Status: [$retstatus] Reason: [FAILED TO EXECUTE]\n",
                            1,1);
        }
        elsif ($retstatus & 127)
        {
            catctlPrintMsg ("\nError Executing $@\n[$pCatctlProgram$pCatctlArgs".
                            " for PDB(s) ($pPdbNames)] Return Status: [$?] ".
                            "Shifted Status: [$retstatus] Reason: [SIGNAL ERROR]\n",
                            1,1);
        }
        else
        {
            #
            # Return catctl.pl Exit Status code
            #
            if ($retstatus != $CATCTL_SUCCESS)
            {
                $retstatus = $retstatus >> 8;
            }
            catctlPrintMsg ("\nError Executing $@\n[$pCatctlProgram$pCatctlArgs".
                            " for PDB(s) ($pPdbNames)] Return Status: [$?] ".
                            "Shifted Status: [$retstatus] Reason: [$!]\n",
                            1,1);
        }
        warn();
    }

    #
    # Status and pdb names will be returned to the main thread.
    # Main thread will look at the status and decide if the
    # upgrade was a success or failure.
    #
    return ($retstatus, $pPdbNames);

} # End of catctlProcessInstance

######################################################################
# 
# catctlDBLogon - Logon onto the database
#
# Description:
#   Logs into the database
#
# Parameters:
#   - $pSrcDir        - Source directory
#   - $psSpoolDir     - Spool Logs Directory
#   - $psSpoolLog     - Spool Log file
#   - $psInclusion    - Inclusion List
#   - $psExclusion    - Exclusion List
#   - $piProcess      - Number of SQL Processes
######################################################################
sub catctlDBLogon
{
    my $pSrcDir        = $_[0];
    my $psSpoolDir     = $_[1];
    my $psSpoolLog     = $_[2];
    my $psInclusion    = $_[3];
    my $psExclusion    = $_[4];
    my $piProcess      = $_[5];

    #
    # Initialize 
    #
    $gbWrapUp = $FALSE;
    $gbLogon  = $FALSE;

    #
    # Don't enforce validation on PDB's
    #
    catconForce($TRUE);
    if ($gbInstance)
    {
        catconUpgForce($TRUE);
        
        # catctl wants to control the mode in which a PDB is open (after, 
        # perhaps, having catcon open it for UPGRADE), so we need to instruct 
        # catcon to not revert PDB to the mode in which it was originally 
        # open when we call catcon to wrap up
        catconSkipRevertingPdbModes($TRUE);
    }

    #
    # Ignore Missing Files
    #
    catconIgnoreErr($IGNORESP20310ERR); 

    # Bug 23020062: Disable pdb lockdown, so upgrade of PDBs will go
    # through even in the presence of lockdown.
    #
    # Bug 20193612: tell catcon that if upgrading a CDB, it should use all 
    # available instances when upgrading PDBs and open all PDBs for UPGRADE 
    #
    # Bug 26145615: Force PDB mode so that upgrade of Application Root Clone 
    # is handled correctly. An Application Root Clone is a special PDB that 
    # is in Read Only mode and cannot be opened in UPGRADE mode by the user.
    # By forcing PDB to be in UPGRADE mode, catcon is able to open Application 
    # Root Clone correctly.
    # 
    if ($gbUpgrade)
    {
      catconDisableLockdown($TRUE);

      # tell catcon to use all RAC instances (if upgrading a RAC CDB) only if 
      # CATCON_USE_ALL_RAC_INSTANCES is set
      if (defined $ENV{CATCON_USE_ALL_RAC_INSTANCES}) {
        catconAllInst($TRUE);
      }

      catconPdbMode(catcon::CATCON_PDB_MODE_UPGRADE);
    }

    #
    # Login, setup Sql processors etc...
    #
    $giRetCode =
        catconInit($gUser,            # UserName and Password
                   undef,             # UserName and Password
                   $pSrcDir,          # Script directory
                   $psSpoolDir,       # Log directory
                   $psSpoolLog,       # Base of spool log file name
                   $psInclusion,      # Container names included
                   $psExclusion,      # Container names excluded
                   $piProcess,        # Processes
                   0,                 # Simultaneous invocations
                   $opt_e,            # Echo on or off
                   undef,             # Spool On
                   $giDelimiter1,     # regular argument delimiter
                   $giDelimiter2,     # secret argument delimiter
                   $ERRORTABLE,       # Error Logging
                   1,                 # Turn off setting Error Logging Id
                   @PerProcInitStmts, # Init statements per process
                   @PerProcEndStmts,  # End statements per process
                   0,                 # PDB$SEED will not be re-opened
                   $gbDebugCatcon,    # Debugging flag
                   $gbDBUA,           # Dbua Flag
                   0,                 # cdb_sqlexec flag
                   1);                # running upgrade

    if ($giRetCode)
    {
        catctlDie("$MSGFCATCONINIT $!");
    }

    #
    # We have Logged in
    #
    $gbLogon = $TRUE;
    #
    # Wrap up can now be called
    #
    $gbWrapUp = $TRUE;

    #
    # Set up communications with catcon
    #
    if ($gUser)
    {
        $gsCatconEnvTag = catconGetUsrPasswdEnvTag(); 
        $gUserPass = catconUserPass();
        $ENV{$gsCatconEnvTag} = $gUserPass;
    }


} # End of catctlProcessInstance 


######################################################################
# 
# catctlLogon - Logon onto the database
#
# Description:
#   Logs into the database and initializes 
#
# Parameters:
#   - None
######################################################################
sub catctlLogon
{

    $gCInclusion = catctlValidateList($gCInclusion);
    if (defined $gCInclusion) {
      catctlPrintMsg("catctlLogon: ".
                     "gCInclusion = [$gCInclusion]\n", 
                     $TRUE, $FALSE);
    } else {
      catctlPrintMsg("catctlLogon: gCInclusion undefined\n", 
                     $TRUE, $FALSE);
    }

    $gCExclusion = catctlValidateList($gCExclusion);
    #
    # Log Into Database
    #
    catctlDBLogon($gSrcDir,
                  $gsSpoolDir,
                  $gsSpoolLog,
                  $gCInclusion,
                  $gCExclusion,
                  $giProcess);

    #
    # Get Cores
    #
    $giCpus = catctlGetCpus();

    #
    # Get Database Name
    #
    $gsDbName = catctlGetDbName();

    #
    # Get Database Major Version
    #
    $giDBMajorVer = catctlGetMajorVersion();

    #
    # No User Specified log file
    #
    if (!$gLogDir)
    {
        #
        # Providing we have the name
        # we will Reset log files
        #
        if ($gsDbName)
        {
            #
            # Spool log directory is pointing to
            # the temp directory.
            #
            my $TempSpoolDir    = $gsSpoolDir;

            #
            # Reset log files to point to
            # the /cfgtoollogs/unique_name/upgrade
            # Since ORACLE_SID was not defined.
            #
            catctlSetLogFiles($gsTempDir,
                              $gLogDir,
                              $gsFile,
                              $gIdentifier,
                              $gsDbName,
                              $gsOrabaseDir);
            #
            # Start up all the sessions with new log directory info
            #
            $giRetCode = catconUpgStartSessions($giProcess,1,
                                                $gsSpoolDir,
                                                $gsSpoolLog,
                                                $gbDebugCatcon);
            if ($giRetCode)
            {
                catctlDie("$MSGFCATCONUPGSTARTSES Cannot Reset Logs $!");
            }

            catctlPrintMsg ("$MSGILOGFILES [$gsSpoolDir]\n\n",$TRUE,$TRUE);

            #
            # Remove the temporary Upgrade Dir only along with log files.
            # We can only safely delete the directory where the temporary
            # log files live since we may have just re-created new directory
            # under the very same directory with the dbname just added
            # into the directory scheme.  We can't just blindly blow that
            # away since we share this directory with DBUA.
            #
            if (-e $TempSpoolDir)
            {
                rmtree($TempSpoolDir);
            }
        }
    }

    #
    # Get Upgrade Lock File
    #
    catctlGetUpgLockFile();

    #
    # Set Calculated Thread Based in Cores
    #
    $giPdbProcess = catctlSetPDBProcessLimits($giProcess,$giPdbProcess);
    $giProcess = catctlSetProcessLimits($giCpus, $giProcess, $giPdbProcess);

    #
    # Startup the Pdb in upgrade mode
    # and set the catcon open flag to 'Y'
    # or Clean out the Summary Report
    #
    if ($gbUpgrade)
    {
        if ($gbInstance)
        {
            $gbCdbDatabase = $TRUE;

            if (!$gCInclusion) {
              catctlPrintMsg("Operating on a CDB, but gCInclusion was not ".
                             "set\n", $TRUE, $FALSE);
            }

            catctlStartDatabase($gCInclusion,
                                $gsNoExclusion,
                                $DBOPENUPGPDB,
                                $gbUpgradeMode,
                                $FALSE);
            catconUpgForce($FALSE);
            $giRetCode = catconUpgSetPdbOpen($gCInclusion,$gbDebugCatcon);
            if ($giRetCode)
            {
                catctlDie("$MSGFCATCONUPGSETPDBOPEN Can't set $gCInclusion to open $!");
            }
        }
        else
        {
            catctlDeleteReport($gsReportName);
        }
    }

    if (catconIsCDB())
    {
        catctlSetCDBLists($gsPriFile);
        #
        # Get and Verify Installed components
        #
        if (($gbInstance))
        {
            %CIDinstalledCmp = catctlGetCIDs($gCInclusion,
                                             $gbInstance); # For Pdb's
            catctlCmpVerification();
        }
        else
        {
            if ($gbRootProcessing)
            {
                %CIDinstalledCmp = catctlGetCIDs($CDBROOT,
                                                 $gbInstance); # For Root
                catctlCmpVerification();
            }
        }
    }
    else
    {
        %CIDinstalledCmp = catctlGetCIDs($gsDbName,
                                         $gbInstance); # For Database
        catctlCmpVerification();
    }

    #
    # Set up the post upgrade commands
    #
    $gsPostUpgCmds = $CATCONDSPTAG.
        "VARIABLE catuppst_name VARCHAR2(256)\n".
        "COLUMN  :catuppst_name NEW_VALUE catuppst_file NOPRINT\n".
        "VARIABLE utlrp_name VARCHAR2(256)\n".
        "COLUMN  :utlrp_name NEW_VALUE utlrp_file NOPRINT\n".
        "DECLARE\n".
        "cnt         NUMBER:=0;\n".
        "BEGIN\n".
        ":catuppst_name := '?/rdbms/admin/$POSTUPGRADEDSP';\n".
        ":utlrp_name    := '?/rdbms/admin/$UTLPRPDSP $giPdbProcess';\n".
        $gsSelectErrors.
        "IF cnt > 0 THEN\n".
        " :utlrp_name    := dbms_registry.nothing_script;\n".
        "END IF;\n".
        "END;".$SQLTERM;

    $gsPostUpgCmds = $gsPostUpgCmds."SELECT :catuppst_name FROM sys.dual;\n".
                     "@@&catuppst_file\n";

    #
    #  If this is the PDB$SEED we also run utlprp. This recompiles any
    #  procedure that is mark as invalid.  We want to avoid any customer
    #  interaction with the PDB$SEED.  We force the running of 
    #  utlprp by, In the DBUA case they will no longer run utlprp post upgrade
    #  operations for the PDB$SEED.  We will do it for them.  The process count
    #  allocated to pdb ($giPdbProcess) is used as the input into utlprp. This way
    #  pdb$seed won't hog all the resources while running the recompilation phase
    #  but only use the resources that have been allocated to it.
    #
    if (($gbSeedProcessing) && ($gbInstance))
    {
       $gsPostUpgCmds = $gsPostUpgCmds.
          "SET ERRORLOGGING ON TABLE $ERRORTABLE IDENTIFIER 'UTLRP';\n".
          "SELECT :utlrp_name FROM sys.dual;\n".
          "@@&utlrp_file\n";
    }

    #
    # If this is for a PDB, and PDB_UPGRADE_SYNC property is set, then
    # use Upgrade Replay instead of phases.
    # 
    if (($gbInstance))
    {
        ($gsUpgradeSyncPdbs, $gsNoUpgradeSyncPdbs) = 
          replay_enabled($gCInclusion);
        
        if ($gsUpgradeSyncPdbs) {
          catctlPrintMsg("Replay Upgrade enabled for ".
                         ($gsNoUpgradeSyncPdbs ? "" : "all ")."PDB(s): ".
                         "$gsUpgradeSyncPdbs\n", $TRUE, $FALSE);
        }

        if ($gsNoUpgradeSyncPdbs) {
          catctlPrintMsg("Replay Upgrade disabled for ".
                         ($gsUpgradeSyncPdbs ? "" : "all ")."PDB(s): ".
                         "$gsNoUpgradeSyncPdbs\n", $TRUE, $FALSE);
        }
    }
} # End of catctlLogon

######################################################################
# 
# catctlInit - General Initialization
#
# Description:
#   This subroutine is where startup initialization occurs
#
# Parameters:
#   - None
######################################################################
sub catctlInit
{
    my $DebugEnvValue = 0;

    #
    # Display Version
    #
    catctlPrintMsg ("\n$MSGIVERSION\n\n",$TRUE,$TRUE);

    #
    # Set OS Environment
    #
    catctlSetOSEnv();

    #
    # Set input Params
    #
    catctlSetInputParameters();

    #
    # Set up default log files in temp directory
    #
    catctlSetLogFiles($gsTempDir,
                      $gLogDir,
                      $gsFile,
                      $gIdentifier,
                      $gsDbName,
                      $gsOrabaseDir);

    #
    # Get Oracle Home or Die
    #
    $gsOracleHomeDir = catctlGetOracleHome($gsTempDir);
 
    if (!$gsOracleHomeDir)
    {
        catctlDie("$MSGFNOORACLEHOME");
    }

    #
    # Set Oracle Home
    #
    $ENV{$ORACLE_HOME_VAR} = $gsOracleHomeDir;

    #
    # Get Oracle Base
    #
    $gsOrabaseDir = catctlGetOrabase($gsTempDir,$gsOracleHomeDir);

    #
    # Set Oracle Base
    #
    $ENV{$ORACLE_BASE_VAR} = $gsOrabaseDir;

    #
    # Set up SQL Error message query
    #
    $gsSelectErrors = $SELERR1.$SELERR2.$SELERR3.";\n";

    #
    # Added by: bymotta as part of Bug 19171538 
    # Call routine to setup environment variables.
    #    
    catctlSetEnvVars();

    #
    # Setup Process Number
    #
    catctlSetProcessNo();

    #
    # Set up sql file to execute
    #
    catctlSetFileNameToExecute();

    #
    # Print Message
    #
    catctlPrintMsg ("$MSGIANALYZINGFILE $gsPath\n",$TRUE,$TRUE);
    catctlPrintMsg ("$MSGILOGFILES [$gsSpoolDir]\n\n",$TRUE,$TRUE);


    #
    # Set Connect String
    #
    catctlSetConnectStr();
        

    #
    # Set Start Phase
    #
    if ($opt_p)
    {
        $giStartPhase = abs($opt_p) or catctlDie("$MSGFINVOPTIONVALUE [-p] $!");
        $gbStartStopPhase = $TRUE;
    }

    if ($opt_P)
    {
        $giStopPhase = abs($opt_P) or catctlDie("$MSGFINVOPTIONVALUE [-P] $!");
        $gbStartStopPhase = $TRUE;
    }

    #
    # Add User Session File
    #
    if ($gScript)
    {
        my $tmpvar = $giUseDir ? "@".$gSrcDir.$SLASH.$gScript : "@".$gScript;
        push (@session_files, $tmpvar);  # Session File
        push (@session_start_phase, 0);  # Session Start Phase
        push (@session_stop_phase, 0);   # Session Stop Phase (never)
    }

    #
    # Set Default Runtime Args for catconExec
    #
    catctlSetDefRTArgs();

    #
    # Set Debug Flag or Environment Variable set
    #
    $DebugEnvValue = catctlGetEnv($CATCTLDBGENV);
    if (($giDebugCatctl > 0) || ($DebugEnvValue))
    {
        catctlUnSetEnv($CATCTLDBGENV);
        #
        # Exit if we can't find debug file for tracing
        #
        if (!catctlDebugTrace($DebugEnvValue,$gsSpoolDir))
        {
            exit($CATCTL_ERROR);
        }
        exit($CATCTL_SUCCESS);
    }

    #
    # If not doing a Replay Upgrade, scan Sql File for phase information
    #
    if (!$gbSerialRun)
    {
        catctlScanSqlFiles($gsPath);   # recursively scan through control files
        catctlLoadPhasesRO();          # Load Phases in reverse order
        catctlDisplayPhases();         # Display Phases
    }

} # End of catctlInit

######################################################################
#
#  catctlSetEnvVars  Set environment variables.
#  Added by: bymotta as part of Bug 19171538 
#  Description:
#    Sub that adds functionality to add Oracle libraries to 
#    the Library path environment variable
#    Capable of determine the *nix flavor 
#    also set the Oracle bin path to the OS
#    PATH on *nix, and PATH and PERL5LIB on Windows.
#
######################################################################

sub catctlSetEnvVars
{
    my $os= lc $^O;


######################################################################
#
#   Bug	21857235
#   Description:
#	Adding Functionality to avoid null variables, causing 
#	warnings on catctl.pl execution output.
######################################################################

    my $oracle_home = $gsOracleHomeDir.$SLASH;
    my $path = catctlGetEnv("PATH");
    my $library_path = catctlGetEnv("LD_LIBRARY_PATH");
    my $library_path_64 = catctlGetEnv("LD_LIBRARY_PATH_64");
    my $lib_path = catctlGetEnv("LIBPATH");
    my $ohlib = $oracle_home."lib:";
    my $ohlib_32 = $oracle_home."lib32:";
    $ENV{PERL5LIB} = $oracle_home."perl".$SLASH."lib";

    if($os =~/win/){  
	if($path){
	   $ENV{PATH}= $oracle_home."bin;".$path;
	} else {
	   $ENV{PATH}= $oracle_home."bin;";
	}
    } else{
     my($kernel, $hostname, $release, $version, $hardware) = uname();
     my $arch = $hardware;
     
     unless ($arch){
	catctlPrintMsg("Unable to identify system architecture, setting LD_LIBRARY_PATH ");
	$arch = "UNKNOWN";
     }

     if ( $os =~ 'linux' ){
         if ( $arch =~ 'ppc64' or $arch =~ 's390x'){
	     $ENV{LD_LIBRARY_PATH} = ($library_path ? $ohlib_32.$library_path : $ohlib_32);
	 } else {
	    $ENV{LD_LIBRARY_PATH} = ($library_path ? $ohlib.$library_path : $ohlib);
	 }
     } elsif ( $os =~ 'sunos'){
	 if ($library_path_64){
	   $ENV{LD_LIBRARY_PATH_64}= $ohlib.$library_path_64;
	 }
	 if ($library_path){
	   $ENV{LD_LIBRARY_PATH}= $ohlib.$library_path;
	 }
     } elsif ($os =~ 'aix') {
	if ($lib_path){
	   $ENV{LIBPATH}= $ohlib.$lib_path;
  	}
     } else  {
	if ($library_path){
	  if (-d "$gsOracleHomeDir/lib32"){
	     $ENV{LD_LIBRARY_PATH}= $ohlib_32.$library_path;
	  } else {
	     $ENV{LD_LIBRARY_PATH}= $ohlib.$library_path;
	  }
	}
      }

     $ENV{PATH} = ($path ? $oracle_home."bin".$ohlib.$path : $oracle_home."bin".$ohlib);

    }

}

# End of catctlSetEnvVars sub


######################################################################
# 
# catctlSetUserTableSpace - Set User Table spaces
#
# Description:
#   This subroutine sets user tables spaces
#   to read only or read write depending on
#   input flag.
#
# Parameters:
#   - Input PDB Name
######################################################################
sub catctlSetUserTableSpace
{
    my $psPdb         = $_[0];              # Pdb
    my $pbReadOnly    = $_[1];              # Read Only Flag
    my $pAryTblSpaces = $_[2];              # Array of Table Spaces
    my $sTblSpaceName = "";                 # Table Space name
    my $SqlROCmd = "";                      # Read Only Table Space Command
    my $SqlRWCmd = "";                      # Read Write Table Space Command
    my $SqlCmd   = $SETSTATEMENTS;          # Table Space Command
    my $bExecSqlCmd = $FALSE;               # Execute Sql Command
    my $WhereToRun  = $RUNROOTONLY;         # Where to Run
    my $TblSpaceMode = "";                  # Table Space Mode
    my $ErrorMsg =  $MSGFCATCTLSETTBLSPACE; # Error Message
    my $READ_ONLY  = " READ ONLY";          # Read Only Table Spaces
    my $READ_WRITE = " READ WRITE";         # Read Write Table Spaces

    #
    # Set Error Message
    #
    if ($psPdb)
    {
        $ErrorMsg = $ErrorMsg." [$psPdb]";
        $WhereToRun = $RUNEVERYWHERE;
    }

    #
    # Set tablespace to read only or read write
    #
    if ($pbReadOnly)
    {
        $TblSpaceMode = $READ_ONLY;
    }
    else
    {
        $TblSpaceMode = $READ_WRITE;
    }

    #
    # Set Error Message
    #
    $ErrorMsg = $ErrorMsg.$TblSpaceMode;

    #
    # Create the Sql alter tablespace commands
    #
    foreach $sTblSpaceName (@$pAryTblSpaces)
    {
        if ($pbReadOnly)
        {
            $SqlCmd   = $SqlCmd."ALTER TABLESPACE ".
                $sTblSpaceName.$READ_ONLY.";\n";
            $SqlROCmd = $SqlCmd;
            $SqlRWCmd = $SqlRWCmd."ALTER TABLESPACE ".
                $sTblSpaceName.$READ_WRITE.";\n";
        }
        else
        {
            $SqlCmd   = $SqlCmd."ALTER TABLESPACE ".
                $sTblSpaceName.$READ_WRITE.";\n";
            $SqlRWCmd = $SqlCmd;
            $SqlROCmd = $SqlROCmd."ALTER TABLESPACE ".
                $sTblSpaceName.$READ_ONLY.";\n";
        }
    }


    #
    # Display information message to log file
    #
    if ($pbReadOnly)
    {
        catctlPrintMsg ($MSGIREVERTROT, $TRUE, $FALSE);
        catctlPrintMsg ($SqlRWCmd, $TRUE, $FALSE);
    }

    #
    # Create and Execute Sql File
    #
    $SqlAry[0] = $SqlCmd;
    $giRetCode = catctlExecSqlFile(\@SqlAry,
                                   0,
                                   $psPdb,
                                   $gsNoExclusion,
                                   $WhereToRun,
                                   $CATCONSERIAL);
    #
    # Check for Error
    #
    if ($giRetCode)
    {
        catctlDie ("$ErrorMsg $!");
    }

}




######################################################################
# 
# catctlDisplaySupportInfo - Put OS and Database info into upgrade log
#
# Description:
#   This subroutine put OS and Database info into upgrade log.
#
# Parameters:
#   - Input String PDB Name
#
# Return
#   - None
######################################################################
sub catctlDisplaySupportInfo
{
    my $psPdb         = $_[0];            # Pdb
    my $WhereToRun  = $RUNROOTONLY;       # Where to Run

    #
    # Run it on Pdb
    #
    if ($psPdb)
    {
        $WhereToRun = $RUNEVERYWHERE;
    }

    #
    # OS Info
    #
    use Config;

    #
    # Database Version Before Upgrade
    #
    my $SqlString = "SELECT version FROM registry\$ WHERE cid='CATPROC'";
    my $SqlDBBeforeVerVal = catctlQuery($SqlString, $psPdb);

    #
    # Database Time Zone Version
    #
    $SqlString = "SELECT version FROM v\$timezone_file";
    my $SqlTZVerVal = catctlQuery($SqlString, $psPdb);

    #
    # Database Instance Name
    #
    $SqlString = "SELECT instance_name FROM v\$instance";
    my $SqlInsNameVal = catctlQuery($SqlString, $psPdb);

    #
    # Database Version After Upgrade
    #
    $SqlString = "SELECT version_full FROM v\$instance";
    my $SqlDBAfterVerVal = catctlQuery($SqlString, $psPdb);

    my $PrintCmd = "DOC\n".
                "#####################################################\n".
                "#####################################################\n\n".
                "    DIAG OS Version: ".$Config{osname}." ".
                $Config{archname}." ".$Config{osvers}."\n".
                "    DIAG Database Instance Name: ".$SqlInsNameVal."\n".
                "    DIAG Database Time Zone Version: ".$SqlTZVerVal."\n".
                "    DIAG Database Version Before Upgrade: ".
                $SqlDBBeforeVerVal."\n".
                "    DIAG Database Version After Upgrade: ".$SqlDBAfterVerVal."\n".
                "#####################################################\n".
                "#####################################################\n".
                "#\n";

    #
    # Create and Execute Sql File
    #
    $SqlAry[0] = $PrintCmd;
    $giRetCode = catctlExecSqlFile(\@SqlAry,
                                   0,
                                   $psPdb,
                                   $gsNoExclusion,
                                   $WhereToRun,
                                   $CATCONSERIAL);
} # End of catctlDisplaySupportInfo


######################################################################
# 
# catctlSetUserReadOnlyTableSpace - Set User Table spaces to read only
#
# Description:
#   This subroutine gets user tables spaces
#   and sets them to read only.
#
# Parameters:
#   - Input String PDB Name
#           Integer Database Major Version
#
# Return
#   - Array of Table Spaces
######################################################################
sub catctlSetUserReadOnlyTableSpace
{
    my $psPdb         = $_[0];     # Pdb
    my $piDBMajorVer  = $_[1];     # Database Major Version
    my @RetAryTblSpaces;           # Return Array of Table Spaces
    my @RetAryRWTblSpaces;         # Return Array of Table Spaces Kept on RW During Upgrade
    my $sTblSpaceName = "";
    my $OracleUsers ="";           # Oracle Users
    my $TblSpaceQuery = "";        # Table Space Query
    my $USERNAMELEN = 30;
    # Main query piece 1. It factorizes Oracle maintained users list.
    my $ROTQRY1 = "with rot_users as (select user#,name from user\$ where name in ";
    my $SqlCmd  = $SETSTATEMENTS;
                                   # Get Oracle owned Users on a pre 12.1 release
    my $OracleUser = "";           # Oracle User
    my $CREATEUSER11TABLE = "CREATE TABLE ".$CATCTLUSER11TBL." (NAME VARCHAR2(".$USERNAMELEN.") NOT NULL);\n";
    my $DELETEUSER11DATA  = "DELETE FROM ".$CATCTLUSER11TBL.";\n";
    # Main query piece 2.1 . List of Oracle maintained users to be used for pre 12 databases.
    my @ORACLEUSERSDATAFOR11 = ("ADM_PARALLEL_EXECUTE_TASK","ANONYMOUS", 
       "APEX_040200","APEX_ADMINISTRATOR_ROLE",
       "APEX_GRANTS_FOR_NEW_USERS_ROLE","APEX_PUBLIC_USER","APPQOSSYS",
       "AQ_ADMINISTRATOR_ROLE","AQ_USER_ROLE","AUDIT_ADMIN",
       "AUDIT_VIEWER","AUDSYS","AUTHENTICATEDUSER","CAPTURE_ADMIN",
       "CDB_DBA","CONNECT","CSW_USR_ROLE","CTXAPP","CTXSYS",
       "DATAPUMP_EXP_FULL_DATABASE","DATAPUMP_IMP_FULL_DATABASE",
       "DBA","DBFS_ROLE","DBHADOOP","DBSNMP","DELETE_CATALOG_ROLE",
       "DIP","DVF","DVSYS","DV_ACCTMGR","DV_ADMIN","DV_AUDIT_CLEANUP",
       "DV_DATAPUMP_NETWORK_LINK","DV_GOLDENGATE_ADMIN",
       "DV_GOLDENGATE_REDO_ACCESS","DV_MONITOR","DV_OWNER",
       "DV_PATCH_ADMIN","DV_PUBLIC","DV_REALM_OWNER","DV_REALM_RESOURCE",
       "DV_SECANALYST","DV_STREAMS_ADMIN","DV_XSTREAM_ADMIN","EJBCLIENT",
       "EM_EXPRESS_ALL","EM_EXPRESS_BASIC","EXECUTE_CATALOG_ROLE","EXFSYS",
       "EXP_FULL_DATABASE","FLOWS_FILES","GATHER_SYSTEM_STATISTICS",
       "GDS_CATALOG_SELECT","GLOBAL_AQ_USER_ROLE","GSMADMIN_INTERNAL",
       "GSMADMIN_ROLE","GSMCATUSER","GSMUSER","GSMUSER_ROLE",
       "GSM_POOLADMIN_ROLE","HS_ADMIN_EXECUTE_ROLE","HS_ADMIN_ROLE",
       "HS_ADMIN_SELECT_ROLE","IMP_FULL_DATABASE","JAVADEBUGPRIV",
       "JAVAIDPRIV","JAVASYSPRIV","JAVAUSERPRIV","JAVA_ADMIN","JAVA_DEPLOY",
       "JMXSERVER","LBACSYS","LBAC_DBA","LOGSTDBY_ADMINISTRATOR","MDDATA",
       "MDSYS","OEM_ADVISOR","OEM_MONITOR","OJVMSYS","OLAPSYS","OLAP_DBA",
       "OLAP_USER","OLAP_XS_ADMIN","OPTIMIZER_PROCESSING_RATE","ORACLE_OCM",
       "ORDADMIN","ORDDATA","ORDPLUGINS","ORDSYS","OUTLN","PROVISIONER",
       "PUBLIC","RECOVERY_CATALOG_OWNER","RESOURCE","SCHEDULER_ADMIN",
       "SELECT_CATALOG_ROLE","SI_INFORMTN_SCHEMA","SPATIAL_CSW_ADMIN",
       "SPATIAL_CSW_ADMIN_USR","SPATIAL_WFS_ADMIN","SPATIAL_WFS_ADMIN_USR",
       "SYS","SYSBACKUP","SYSDG","SYSKM","SYSTEM","WFS_USR_ROLE","TSMSYS",
       "WMSYS","WM_ADMIN_ROLE","XDB","XDBADMIN","XDB_SET_INVOKER",
       "XDB_WEBSERVICES","XDB_WEBSERVICES_OVER_HTTP",
       "XDB_WEBSERVICES_WITH_PUBLIC","XS\$NULL","XS_CACHE_ADMIN",
       "XS_NSATTR_ADMIN","XS_RESOURCE","XS_SESSION_ADMIN");
    my $ROTQRY2 = 
       # Main query piece 3. Get list of tablespaces to be put in RO mode. It already filters known TS (system,syaux,undo,etc)
       "SELECT \'C:A:T:C:O:N\' || ts.name FROM ". 
       "sys.ts\$ ts, sys.x\$kcfistsa tsattr ".
       "WHERE ts.online\$ != 3  AND bitand(ts.flags,2048) != 2048 AND ".
       "ts.ts# = tsattr.tsid AND decode(ts.contents\$, 0,".
       "(decode(bitand(ts.flags, 4503599627370512),16, 'UNDO',".
       "4503599627370496, 'LOST WRITE PROTECTION','PERMANENT')), 1,'TEMPORARY') ".
       "!= 'UNDO' AND decode(ts.contents\$, 0,(decode(bitand(ts.flags,".
       "4503599627370512),16, 'UNDO',4503599627370496,'LOST WRITE PROTECTION',".
       "'PERMANENT')), 1, 'TEMPORARY')!= 'TEMPORARY' AND ts.online\$ = 1 AND ".
       "ts.name != 'SYSTEM' AND ts.name != 'SYSAUX' AND ts.name NOT IN ". 
       # Big subquery starting in below line will contain all TS we DO NOT want to be put in RO.
         #Subquery 1. Get default DATABASE tablespace.
       "(SELECT value\$ FROM props\$ WHERE NAME = 'DEFAULT_PERMANENT_TABLESPACE' ".
         #Subquery 2. Get DEFAULT tablespace for Oracle maintained users.
       "UNION\nSELECT unique(dts.name) from sys.user\$ u left outer join ".
       "sys.resource_group_mapping\$ cgm on (cgm.attribute = 'ORACLE_USER' ".
       "and cgm.status = 'ACTIVE' and cgm.value = u.name),sys.ts\$ dts,sys.ts\$ tts,".
       "sys.profname\$ p,sys.user_astatus_map m, sys.profile\$ pr,sys.profile\$ dp ".
       "where u.datats# = dts.ts# and u.resource\$ = p.profile# and ".
       "u.tempts# = tts.ts# and ((u.astatus = m.status#) or ".
       "(u.astatus = (m.status# + 16 - BITAND(m.status#, 16)))) ".
       "and u.type# = 1 and u.resource\$ = pr.profile# and ".
       "dp.profile# = 0 and dp.type#=1 and dp.resource#=1 and ".
       "pr.type# = 1 and pr.resource# = 1 AND ".
       "u.name IN (select name from rot_users) UNION\n".
         #Subquery 3. Get all tablespaces where Oracle maintained users have segments placed.
       "(select ts.name from sys.user\$ u,sys.obj\$ o,sys.ts\$ ts,".
       "sys.sys_objects so,sys.seg\$ s,sys.file\$ f ".
       "where s.file# = so.header_file and s.block# = so.header_block ".
       "and s.ts# = so.ts_number and s.ts# = ts.ts# and o.obj# = so.object_id ".
       "and o.owner# = u.user# (+) and s.type# = so.segment_type_id and ".
       "o.type# = so.object_type_id and s.ts# = f.ts# and s.file# = f.relfile# ".
       "and u.user# in (select user# from rot_users) ".
       "union\nselect ts.name from sys.user\$ u, sys.ts\$ ts, sys.undo\$ un, ".
       "sys.seg\$ s, sys.file\$ f where s.file# = un.file# and ".
       "s.block# = un.block# and s.ts# = un.ts# and s.ts# = ts.ts# and ".
       "s.user# = u.user# (+) and s.type# in (1, 10) and un.status\$ != 1 and ".
       "un.ts# = f.ts# and un.file# = f.relfile# and ".
       "u.name in (select name from rot_users) union\nall select ts.name ".
       "from sys.user\$ u, sys.ts\$ ts, sys.seg\$ s, sys.file\$ f ".
       "where s.ts# = ts.ts# and s.user# = u.user# (+) and ".
       "s.type# not in (1, 5, 6, 8, 10, 11) and s.ts# = f.ts# and ".
       "s.file# = f.relfile# and u.name in (select name from rot_users) ".
       "union\nall select ts.name from sys.user\$ u, sys.ts\$ ts, sys.seg\$ s, ". 
       "sys.file\$ f where s.ts# = ts.ts# and s.user# = u.user# (+) and ".
       "s.type# = 11 and s.ts# = f.ts# and s.file# = f.relfile# and ".
       "u.name in (select name from rot_users) union\n".
        ## Subquery 4. Query to get tablespaces with Datamining user data
       "select distinct t.name from modeltab\$ m,  ts\$ t, sys_objects s ". 
       "where m.obj#=s.object_id and s.ts_number=t.ts#))";
    my $ORACLEQUERYUSERS11 = "(select name from ". $CATCTLUSER11TBL.")";
                                   # Get Oracle own users in 12.1 
                                   # release and above
    # Main query piece 2.2. Get list of Oracle maintained users for databases 12.1 and above
    my $ORACLEQUERYUSERS = "(select name from sys.user\$ ".
       "where bitand(spare1,256)=256) and type#=1";

       my $RWTQRY = "SELECT ts.name FROM ".
       "sys.ts\$ ts, sys.x\$kcfistsa tsattr ".
       "WHERE ts.online\$ != 3  AND bitand(ts.flags,2048) != 2048 AND ".
       "ts.ts# = tsattr.tsid AND decode(ts.contents\$, 0,".
       "(decode(bitand(ts.flags, 4503599627370512),16, 'UNDO',".
       "4503599627370496, 'LOST WRITE PROTECTION','PERMANENT')), 1,'TEMPORARY') ".
       "!= 'UNDO' AND decode(ts.contents\$, 0,(decode(bitand(ts.flags,".
       "4503599627370512),16, 'UNDO',4503599627370496,'LOST WRITE PROTECTION',".
       "'PERMANENT')), 1, 'TEMPORARY')!= 'TEMPORARY' AND ts.online\$ = 1 AND ".
       "ts.name != 'SYSTEM' AND ts.name != 'SYSAUX'";
    #
    # Set Oracle Users based on major version id
    #
    if ($piDBMajorVer > 11)
    {
        $OracleUsers = $ORACLEQUERYUSERS;
    }
    else
    {
        #
        # Create and populate user table for 11
        # We have to create the table to avoid the
        # dreaded line to long error from sqlplus.
        # oracle-error-sp2-0027-input-is-too-long-2499-characters-line-ignored
        # Once we place in a table we can use a very short
        # command to retrieve the data rather than hard
        # coded into the sql.
        #
        $SqlCmd = $SqlCmd.$CREATEUSER11TABLE.$DELETEUSER11DATA;
        foreach $OracleUser (@ORACLEUSERSDATAFOR11)
        {
            if (length($OracleUser) > $USERNAMELEN)
            {
                 catctlDie("$MSGFCATCTLNAMETOLONG $OracleUser");
            }
            $SqlCmd = $SqlCmd."INSERT INTO ".$CATCTLUSER11TBL." VALUES ('".$OracleUser."');\n";
        }
        $SqlCmd = $SqlCmd.$COMMITCMD;

        #
        # Create and Populate user table for 11.
        #
        $SqlAry[0] = $SqlCmd;
        $giRetCode = catctlExecSqlFile(\@SqlAry,
                                       0,
                                       $psPdb,
                                       $gsNoExclusion,
                                       $RUNEVERYWHERE,
                                       $CATCONSERIAL);
        if ($giRetCode)
        {
            catctlDie("$MSGFCATCONEXEC $!");
        }

        $OracleUsers =  $ORACLEQUERYUSERS11;
    }

    #
    # Query the database for user tablespaces
    # Build final query. Put main query pieces (1,2(2.1 or 2.2) and 3) together.
    #
    $TblSpaceQuery = $ROTQRY1.$OracleUsers.") ".$ROTQRY2; 
    @RetAryTblSpaces = catctlAryQuery($TblSpaceQuery,$psPdb);

    #
    # Write Query to Log file
    #
    if($giDebugCatctl > 0)
    {
    	catctlPrintMsg("$MSGITBLSPACEQUERY $TblSpaceQuery\n",
                   $TRUE,$FALSE);
    }

    #
    # 
    #
    if ($#RetAryTblSpaces != -1)
    {
        #
        # Table spaces found
        #
        # Set User Tablespaces read only
        #
        catctlSetUserTableSpace($psPdb,
                                $TRUE,
                                \@RetAryTblSpaces);
        @RetAryRWTblSpaces = catctlAryQuery($RWTQRY,$psPdb); 
        catctlPrintMsg("\n $MSGRWTABLESPACES",$TRUE,$FALSE);
        foreach $sTblSpaceName (@RetAryRWTblSpaces)
  	{
	catctlPrintMsg("\n $sTblSpaceName",$TRUE,$FALSE);
        }
    }

    #
    # Return the results array
    #
    return @RetAryTblSpaces;

} # End of catctlSetUserReadOnlyTableSpace

######################################################################
# 
# catctlUnionArys - Union two arrays
#
# Description:
#   Return the union of two arrays
#
#   If we have a need to return a intersection array or a
#   difference array.  We we add the following code in the
#   second loop.
#        if ($count{$AryElement} > 1)
#        {
#            push (@RetIntersectAry, $AryElement);
#        }
#        else
#        {
#            push (@RetDifferenceAry, $AryElement);
#        }
#
# Parameters:
#   - Input Array one
#           Array two
#
# Return
#   - Union of two arrays
######################################################################
sub catctlUnionArys
{
    my $pAry1 = $_[0];     # Array 1
    my $pAry2 = $_[1];     # Array 2
    my @RetUnionAry = ();  # Return Union Array
    my $AryElement;
    my %count = ();

    #
    # Add to count hash array
    #
    foreach $AryElement (@$pAry1)
    {
        $count{$AryElement}++;
    }

    #
    # Add to count hash array
    #
    foreach $AryElement (@$pAry2)
    {
        $count{$AryElement}++;
    }

    #
    # Now take the union of the two arrays
    #
    foreach $AryElement (keys %count) 
    {
        push (@RetUnionAry, $AryElement);
    }

    return @RetUnionAry;


} # End of catctlUnionArys

######################################################################
# 
# catctlSetUserWriteTableSpace - Set User Table spaces to read write
#
# Description:
#   This subroutine set user tables spaces back to read write
#
# Parameters:
#   - Input PDB Name
#   - Array of table spaces
#   - Array Count
#   - Integer Database Major id
#
# Return
#   - Array of Table Spaces
######################################################################
sub catctlSetUserWriteTableSpace
{
    my $psPdb         = $_[0];     # Pdb
    my $pAryTblSpaces = $_[1];     # Array of Table Spaces
    my $pAryCnt       = $_[2];     # Array Count
    my $piDBMajorVer  = $_[3];     # Database Major Version

    #
    #  Nothing to do just get out
    #
    if ($pAryCnt == -1)
    {
        return;
    }


    #
    # Delete user table for 11
    #
    if ($piDBMajorVer == 11)
    {
        my $DELETEUSER11TABLE = $SETSTATEMENTS."TRUNCATE TABLE ".$CATCTLUSER11TBL.
            ";\n DROP TABLE ".$CATCTLUSER11TBL.";\n";
        #
        # Create and Execute Sql File
        #
        $SqlAry[0] = $DELETEUSER11TABLE;
        $giRetCode = catctlExecSqlFile(\@SqlAry,
                                       0,
                                       $psPdb,
                                       $gsNoExclusion,
                                       $RUNEVERYWHERE,
                                       $CATCONSERIAL);
        if ($giRetCode)
        {
            catctlDie("$MSGFCATCONEXEC $!");
        }   
    }


    #
    # Set User Tablespaces read write
    #
    catctlSetUserTableSpace($psPdb,
                            $FALSE,
                            $pAryTblSpaces);

    #
    # Clear out the Array
    #
    @$pAryTblSpaces = ();


} # End of catctlSetUserWriteTableSpace

######################################################################
# 
# catctlLoadPriorityFile - Load Priority File
#
# Description:
#   Loads up Priority file and sorts it according to priority number
#   File has to be in the following format:
#
#   #,Pdb Name
#
# Parameters:
#   - None
######################################################################
sub catctlLoadPriorityFile
{
    my $psPriFile = $_[0];        # Priority File
    my $printParseLists = $_[1];  # Print ParseLists flag
    my $Line;                     # Line of Data
    my $bFirstime = $TRUE;        # Set First time Flag
    my $PriSortFile = $gsSpoolDir.$SLASH.
     $PRIORITYFILE."_sorted.lst"; # Sorted User Priority File
    my $PdbCount  = 0;
    my $PRISKIPIT  = 0;           # Skip this Container
    my $IncList    = "";          # Inclution List
    my $ExcList    = "";          # Exclution List
    my $PDBLISTONLY  = "CATCTL_LISTONLY";# Only process what is in the list.
    my $bPdbListOnly = $FALSE;    # Process list only
    my $bCdbRoot   = $TRUE;       # Process Root
    my $bPdbSeed   = $TRUE;       # Process Seed
    my $bExcludePdb = $FALSE;     # Exclude Pdb Flag
    my $bIncludePdb = $TRUE;      # Include Pdb Flag
    my $sPdbListName = "";        # List Name
    my $sPdbPriName = "";         # Pdb Priority Name
    my $sConName = "";            # Container Name
    my @LocalAryParsedList;       # Local ary Parsed List
    my @LocalAryPDBInstanceList;  # Local ary PDB Instance List
    my @LocalAryExcList;          # Local ary Exclusion List
    my @LocalAryIncList;          # Local ary Inclusion List
    my $idx = 0;                  # Index Counter
    my $i   = 0;                  # Index Counter

    #
    # Get out if this is a PDB instance.  Only
    # Main instance should process priority list
    # files.
    #
    if ($gbInstance)
    {
        return;
    }

    #
    # Open the priority file
    #
    open (FileIn, '<', $psPriFile) or 
        catctlDie("$MSGFCATCTLPRIFILE - $psPriFile $!");

    if (defined $gCInclusion) {
      catctlPrintMsg("catctlLoadPriorityFile(1): ".
                     "gCInclusion = [$gCInclusion]\n", 
                     $TRUE, $FALSE);
    } else {
      catctlPrintMsg("catctlLoadPriorityFile(1): gCInclusion undefined\n", 
                     $TRUE, $FALSE);
    }

    #
    # Process user Inclusion and exclusion lists
    #
    if ($gCInclusion)
    {
        $IncList = $gCInclusion;
        @LocalAryIncList  = split(' ', $IncList);
        #
        # Set Root and seed to be excluded
        # by default when include list specified
        #
        $bCdbRoot = $FALSE;
        $bPdbSeed = $FALSE;
    }
    if ($gCExclusion)
    {
        $ExcList = $gCExclusion;
        @LocalAryExcList  = split(' ', $ExcList);
    }

    #
    # Process each line of the priority file and place in hash array
    #
    $ExcList = "";
    catctlPrintMsg("\nInput Priority List File\n",$TRUE,$FALSE);
    while (<FileIn>)
    {
        #
        # Trim out the data
        #
        $Line = $_;
        chomp ($Line);
        $Line = catctlTrim($Line); 
        catctlPrintMsg("$Line\n",$TRUE,$FALSE);

        #
        # Split out priority and PDB name
        #
        my ($iPriority, @sPdbPriNames) = split(',',$Line);

        #
        # Process PDB's by priority grouping
        #   Example: 4,pdb1,pdb2,pdb3
        # or in a singular list
        #   Example: 4,pdb1
        #            4,pdb2
        #            4,pdb3
        # or a pdbname could be a con_id
        #   Example: 4,3,4,5
        #
        $i = 0;
        for $sPdbPriName (@sPdbPriNames)
        {
            #
            # If this is a con-id query to get the pdbname
            #
            if (looks_like_number($sPdbPriName))
            {
                $sConName = catctlGetContainerName($sPdbPriName);
                if (!$sConName)
                {
                    catctlDie("$MSGFINVPRIORITYCONID [$psPriFile]-[$sPdbPriName] $!");
                }
                #
                # Set the Pdb Name
                #
                $sPdbPriName      = $sConName;
                $sPdbPriNames[$i] = $sConName;
            }

            #
            # Initialize,Increment counter and uppercase pdb name
            #
            $bExcludePdb = $FALSE;
            $i++;
            $sPdbPriName  = uc($sPdbPriName);

            #
            # Check to see inclusion pdb is in priority list
            #
            if ($gCInclusion)
            {
                $idx = 0;
                $bIncludePdb = $FALSE;

                for $sPdbListName (@LocalAryIncList)
                {
                    $sPdbListName = uc($sPdbListName);
                    #
                    # Already In Priority list
                    #
                    if ($sPdbPriName eq $sPdbListName)
                    {
                        #
                        # Set Root to be included
                        #
                        if ($sPdbListName eq $CDBROOTTAG)
                        {
                            $bCdbRoot = $TRUE;
                        }
                        #
                        # Set Seed to be included
                        #
                        if ($sPdbListName eq $PDBSEEDTAG)
                        {
                            $bPdbSeed = $TRUE;
                        }

                        $LocalAryIncList[$idx] = "";
                        $bIncludePdb = $TRUE;
                        last;
                    }
                    $idx++;
                }

                #
                # Priority list Pdb not in Inclusion list
                # Exclude the priority list PDB only process
                # what is in the inclusion list according to
                # its priority.
                #
                if (!$bIncludePdb)
                {
                    next;
                }
            }

            #
            # Check to see if exclusion pdb is in priority list
            #
            if ($gCExclusion)
            {
                $bExcludePdb = $FALSE;
                for $sPdbListName (@LocalAryExcList)
                {
                    $sPdbListName = uc($sPdbListName);
                    #
                    # Exclude from Priority list
                    #
                    if ($sPdbPriName eq $sPdbListName)
                    {
                        $bExcludePdb = $TRUE;
                        last;
                    }
                }

                #
                # Exclude this one from priority list
                #
                if ($bExcludePdb)
                {
                    next;
                }
            }
            #
            # If we are not skipping then Validate Priority
            # and Place in Hash Array otherwise PDB is put
            # on the exclusion list.
            #
            $iPriority = abs($iPriority) or 
                catctlDie("$MSGFINVPRIORITYVALUE [$psPriFile]-[$Line] $!");
            if (($iPriority    <  $PRIPDBSEED) && 
                ($sPdbPriName  ne $CDBROOTTAG) &&
                ($sPdbPriName  ne $PDBSEEDTAG))
            {
                catctlDie("$MSGFINVPRIORITYVALUE [$psPriFile]-[$Line] Priority Value ".
                          "Start Priority at [$PRIPDBSEED] $!");
            }
            $HashPdbPriData{$sPdbPriName} = $iPriority;
        } # End loop on pdb names
    } # End loop reading priority file
    close (FileIn);


    #
    # Inclusion lists are treated as a reference list
    # into the priority list.  They will be processed
    # according to its priority from within the priority
    # list.  We will not process any PDB's outside the
    # inclusion list.  This turns the priority list
    # into a subset inclusion only priority list.
    # 
    #
    if ($gCInclusion)
    {
        $idx = 0;
        $bPdbListOnly = $TRUE; 
        for $sPdbListName (@LocalAryIncList)
        {
            #
            # Set the priority for the included PDB
            # Not in the priority list
            #
            if ($sPdbListName ne "")
            {
                $sPdbListName = uc($sPdbListName);

                #
                # This is a inclusion only priority list
                # Set flag and get next pdb.
                #
                if ($sPdbListName eq $PDBLISTONLY)
                {
                    $bPdbListOnly = $TRUE;
                    next;
                }

                #
                # Set Root to be included
                #
                if ($sPdbListName eq $CDBROOTTAG)
                {
                    $bCdbRoot = $TRUE;
                }
                #
                # Set Seed to be included
                #
                if ($sPdbListName eq $PDBSEEDTAG)
                {
                    $bPdbSeed = $TRUE;
                }

                #
                # Set Priority
                #
                $HashPdbPriData{$sPdbListName} = 
                    catctlGetPriority($sPdbListName);
            }
        }
    }

    #
    # Add in exclusions list
    #
    if ($gCExclusion)
    {
        for $sPdbListName (@LocalAryExcList)
        {
            $sPdbListName = uc($sPdbListName);

            #
            # This is a inclusion only priority list
            # Set flag and get next pdb.
            #
            if ($sPdbListName eq $PDBLISTONLY)
            {
                $bPdbListOnly = $TRUE;
                next;
            }

            #
            # Add to Exclusion list
            #
            $ExcList = $ExcList.$sPdbListName." ";

            #
            # Set Root to be excluded
            #
            if ($sPdbListName eq $CDBROOTTAG)
            {
                $bCdbRoot = $FALSE;
            }
            #
            # Set Seed to be excluded
            #
            if ($sPdbListName eq $PDBSEEDTAG)
            {
                $bPdbSeed = $FALSE;
            }
        }
    }

    #
    # Sort data by priority number
    #
    @SortedPdbPriData = sort 
    {
        $HashPdbPriData{$a} <=> $HashPdbPriData{$b}
    } keys %HashPdbPriData; 

    $IncList = "";
    #
    # Create inclusion list from sorted list
    #
    for $sPdbPriName (@SortedPdbPriData)
    {
        #
        # Skip Root and Seed Add them later
        #
        if (($sPdbPriName eq $CDBROOTTAG)  ||
            ($sPdbPriName eq $PDBSEEDTAG))
        {
            next;
        }

        if ($bFirstime)
        {
            $IncList     = $sPdbPriName;
            $bFirstime   = $FALSE;
        }
        else
        {
            $IncList = $IncList." ".$sPdbPriName;
        }
    }

    #
    # Include Seed
    #
    if ($bPdbSeed)
    {
        $IncList = $PDBSEED." ".$IncList;
        $HashPdbPriData{$PDBSEED} = $PRIPDBSEED;
    }

    #
    # Include Root
    #
    if ($bCdbRoot)
    {
        $IncList = $CDBROOT." ".$IncList;
        $HashPdbPriData{$CDBROOT} = $PRICDBROOT;
    }


    #
    # Set the Inclusion List
    #
    $gCExclusion = 0;
    $gCInclusion = $IncList; 

    if (defined $gCInclusion) {
      catctlPrintMsg("catctlLoadPriorityFile(2): ".
                     "gCInclusion = [$gCInclusion]\n", 
                     $TRUE, $FALSE);
    } else {
      catctlPrintMsg("catctlLoadPriorityFile(2): gCInclusion undefined\n", 
                     $TRUE, $FALSE);
    }

    #
    # Now lets get the rest of the PDB's to upgrade
    # by given the inclusion list generated above
    # as and exclusion list.  This will give us
    # the remainder of the PDB's which will be
    # prioritized last.  Will do this unless
    # list was specified as a priority inclusion list only.
    #
    if (!$bPdbListOnly)
    {
        $ExcList = $ExcList.$IncList;

        catctlPrintMsg("Invoking catctlParseLists with empty Inclusion List ".
                       "and Exclusion List = [$ExcList]\n", $TRUE, $FALSE);
 
        catctlParseLists($gsNoInclusion,
                         $ExcList, 
                         \@LocalAryParsedList,
                         \@AryContainerNames,
                         \@LocalAryPDBInstanceList,
                         0,
                         $printParseLists);

        #
        # Process rest of the PDB's
        #
        @LocalAryParsedList = split(' ', $gsRTExclusion);

        #
        # Add in the rest of the PDB's, Given them the
        # lowest priority.
        #
        for $sPdbPriName (@LocalAryParsedList)
        {
            #
            # Don't add in Seed and Root we already
            # did it above.
            #
            if (($sPdbPriName ne $CDBROOTTAG) &&
                ($sPdbPriName ne $PDBSEEDTAG))
            {
                $HashPdbPriData{$sPdbPriName} = CATCONST_MAXPDBS;
                $gCInclusion = $gCInclusion." ".$sPdbPriName;
            }
        }

        if (defined $gCInclusion) {
          catctlPrintMsg("catctlLoadPriorityFile(3): ".
                         "gCInclusion = [$gCInclusion]\n", 
                         $TRUE, $FALSE);
        } else {
          catctlPrintMsg("catctlLoadPriorityFile(3): gCInclusion undefined\n", 
                         $TRUE, $FALSE);
        }
    }

    #
    # Print out the order of the upgrade in the log file
    #
    @LocalAryParsedList = split(' ', $gCInclusion);

    catctlPrintMsg("\nOutput Generated Priority List File\n",$TRUE,$FALSE);

    for $sPdbPriName (@LocalAryParsedList)
    {
        catctlPrintMsg("$HashPdbPriData{$sPdbPriName},$sPdbPriName\n",
                       $TRUE,$FALSE);
    }

    #
    # Emulate the upgrade order
    #
    if ($gbEmulate)
    {
        catctlPrintMsg("\nSorted priority list file is $PriSortFile\n",
                       $TRUE,$FALSE);

        #
        # Open the sorted priority file
        #
        open (FileOut, '>', $PriSortFile) or 
            catctlDie("$MSGFCATCTLPRIFILE - $PriSortFile $!");

        #
        # Print out the sorted order
        #
        for $sPdbPriName (@LocalAryParsedList)
        {
            catctlPrintMsg("$HashPdbPriData{$sPdbPriName},$sPdbPriName\n",
                           $TRUE,$FALSE);
            print FileOut "$HashPdbPriData{$sPdbPriName},$sPdbPriName\n";

            #
            # If Root then print linetag and
            # process next PDB. Root is processed
            # by itself.
            #
            if ($sPdbPriName eq $CDBROOT)
            {
                catctlPrintMsg("$LINETAG\n",
                               $TRUE,$FALSE);
                print FileOut "$LINETAG\n";
                next;
            }

            $PdbCount++;
            if ($PdbCount == $giPdbInstances)
            {
                $PdbCount = 0;
                catctlPrintMsg("$LINETAG\n",
                               $TRUE,$FALSE);
                print FileOut "$LINETAG\n";
            }

        }
        catctlPrintMsg("$LINETAG\n",
                        $TRUE,$FALSE);
        print FileOut "$LINETAG\n";

        close(FileOut);
    }

}  # End of catctlLoadPriorityFile

######################################################################
# 
# catctlDisplayPhaseDesc - Display Phase Description
#
# Description:
#   Display Phase Description to Screen
#
# Parameters:
#   - phase number (IN)
######################################################################
sub catctlDisplayPhaseDesc
{
    my $phaseno = $_[0];           # phase no
    my $x = 0;

    if ($phase_desc[$phaseno])
    {
        for ($x = length($phase_desc[$phaseno]); $x < 52; $x++)
        {
            if ($x % 2 == 1)
            {
                $phase_desc[$phaseno] = '*'.$phase_desc[$phaseno];
            }
            else
            {
                $phase_desc[$phaseno] = $phase_desc[$phaseno].'*';
            }
        }
        catctlPrintMsg("$phase_desc[$phaseno]\n", $TRUE, $TRUE);
    }
}




######################################################################
# 
# catctlDisplayPhaseInfo - Load phase with or without compilation of sql files
#
# Description:
#   Display Phase Info to Screen
#
# Parameters:
#   - phase number (IN)
#   - Number of phase files (IN)
#   - Inclusion List (IN)
#   - Exclusion List (IN)
######################################################################
sub catctlDisplayPhaseInfo
{
   my $phaseno = $_[0];           # phase no
   my $numofphasefiles = $_[1];   # Number of phase files
   my $pInclusion    = $_[2];     # Inclusion List for Containers
   my $pExclusion    = $_[3];     # Exclusion List for Containers
   my $psDbName      = $_[4];     # Database Name
   my $pList = "";                # Inc or Exc List

   #
   # Set List up to Display
   #
   if ($gbCdbDatabase)
   {
       if($pExclusion)
       {
           $pList = $pExclusion;
       }

       if ($pInclusion)
       {
           $pList = $pInclusion;
       }
   }
   else
   {
       $pList = $psDbName;
   }

   if ($phaseno != 0)
   {
       $gtSTime  = time();
       $gtSDifSec = $gtSTime - $gtLastTime;
       $gtTotSec = $gtTotSec + $gtSDifSec;

       $gsPadChr = $SPACE;
       if ($giLastNumOfPhaseFiles < 10)
       {
           $gsPadChr = $SPACE.$SPACE.$SPACE;
       }
       else
       {
           if ($giLastNumOfPhaseFiles < 100)
           {
               $gsPadChr = $SPACE.$SPACE;
           }
       }
  
       if (!$gbInstance || $gsNoUpgradeSyncPdbs)
       {
           # not processing PDBs or processed some PDB(s) which have 
           # PDB_UPGRADE_SYNC disabled
           catctlPrintMsg(
              "$gsPadChr$TOTALTIME$gtSDifSec$DSPSECS\n",
               $TRUE,$TRUE);
       }
   }

   $gtLastTime = time();
   $giLastNumOfPhaseFiles = $numofphasefiles;
 

   if ($opt_r || $giProcess == 1)
   {
       $gsDspPhase = $SERIAL;
   }
   else
   {
       if ($phase_files[$phaseno][0] eq $RESTART)
       {
           $gsDspPhase = $BOUNCE;
       }
       else
       {
           $gsDspPhase = ($phase_type[$phaseno] == $MULTI) 
               ? $PARALLEL : $SERIAL;
       }
   }

   $gsPadChr = $SPACE;
   if ($phaseno < 10)
   {
       $gsPadChr = $SPACE.$SPACE.$SPACE;
   }
   else
   {
       if ($phaseno < 100)
       {
           $gsPadChr = $SPACE.$SPACE;
       }
   }

   catctlDisplayPhaseDesc($phaseno);

   catctlPrintMsg("$gsDspPhase$MSGIPHASENO$phaseno$gsPadChr [$pList] ".
                  "$MSGITOTALFILES$numofphasefiles ",
                  $TRUE,$TRUE);

} # End of catctlDisplayPhaseInfo

######################################################################
# 
# catctlExecutePhaseFiles - Execute the sql scripts for the phase.
#
# Description:
#   This subroutine decides how to run the sql scripts with a phase.
#
# Parameters:
#   - phase number (IN)
#   - Number of Phase Files (IN)
#   - Inclusion List for Containers (IN)
#   - Exclusion List for Containers (IN)
#   - SQL identifier (IN)
######################################################################
sub catctlExecutePhaseFiles
{
   my $phaseno    = $_[0];   # phase no
   my $numoffiles = $_[1];   # Num of Phase Files
   my $Inclusion = $_[2];    # Inclusion List for Containers
   my $Exclusion = $_[3];    # Exclusion List for Containers
   my $SqlIdentifier = $_[4];    # SQL Identifier
   my @SqlAry;               # Sql Array
   my $Cmp;                  # component id associated with phase
   my $CmpQuery = $gsNoQuery; # Query for component in PDB
   my $x          = 0;       # Index

   # check for component files (first script checked)
   # set query for catconExec to check prior to running script array
   if (substr($phase_files[$phaseno][0],0,$CATCTLCPTAGLEN) eq "$CATCTLCPTAG") {
       $Cmp = substr($phase_files[$phaseno][0],$CATCTLCPTAGLEN,
                      index($phase_files[$phaseno][0],"$CATCTLATTAG")-$CATCTLCPTAGLEN);
       $CmpQuery = 
         "select sys.dbms_registry_sys.catcon_query".
                "(sys.dbms_assert.simple_sql_name(\'$Cmp\')) from sys.dual;";
   }       
   
   if ($phase_type[$phaseno] == $SINGLE)
   {
       #
       # Create Pfile if last job.
       #
       if (catctlIsPhase($phaseno,$LASTJOB))
       {
           # Record timestamp for datapatch begin in upgrade mode
           catctlTimestamp("DP_UPG_BGN", $Inclusion);

           #
           # 17277459: Call datapatch in upgrade mode, to install any pending
           # PSUs or patches that require upgrade mode
           # 
           catctlDatapatch("upgrade",$gUserName,$gUserPass,$Inclusion,"DP_UPG_BGN");

           # Record timestamp for datapatch end in upgrade mode
           catctlTimestamp("DP_UPG_END", $Inclusion);

           #
           #  Re-create Pfile
           #  Bug 23185218
           catctlCreatePFile();
       }

       # Load files in Sql Array
       for ($x = 0; $x < $numoffiles; $x++)
       {
          # Add to SqlAry after fix up for component
          catctlAddToSqlAry($phase_files[$phaseno][$x],\@SqlAry);
       }

       #
       # If Emulating get out
       #
       if ($gbEmulate)
       {
           return();
       }

       # run all scripts in this phase single-threaded
       $giRetCode =
           catconExec(@SqlAry, 
                      $CATCONSERIAL,   # run single-threaded
                      0,  # run in every Container if the DB is Consolidated
                      0,  # Don't issue process init/completion statements
                      $Inclusion,      # Inclusion List for Containers
                      $Exclusion,      # Exclusion List for Containers
                      $SqlIdentifier,  # SQL Identifier
                      $CmpQuery);      # component query for PDB

       if ($giRetCode)
       {
           catctlDie("$MSGFCATCONEXEC $!");
       }
   }
   else
   {  # script in this phase run in serial reverse order
      # to catch dependency problems
       if ($opt_r)
       {
           # Load files in Sql Array
           for ($x = 0; $x < $numoffiles; $x++)
           {
              # Add to SqlAry after fix up for component
              catctlAddToSqlAry($phase_files_ro[$phaseno][$x],\@SqlAry);
           }

           #
           # If Emulating get out
           #
           if ($gbEmulate)
           {
               return();
           }

           # run all scripts in this phase single-threaded
           $giRetCode =
               catconExec(@SqlAry, 
                          $CATCONSERIAL,   # run single-threaded
                          0,  # run in every Container if DB is Consolidated
                          0,  # Don't issue process init/completion statements
                          $Inclusion,      # Inclusion List for Containers
                          $Exclusion,      # Exclusion List for Containers
                          $SqlIdentifier,  # SQL Identifier
                          $CmpQuery);      # component query for PDB
           if ($giRetCode)
           {
               catctlDie("$MSGFCATCONEXEC $!");
           }
       }
       # scripts in this phase may be run in parallel
       else
       {
           # Load files in Sql Array
           for ($x = 0; $x < $numoffiles; $x++)
           {
               # Add to SqlAry after fix up for component loaded
               catctlAddToSqlAry($phase_files[$phaseno][$x],\@SqlAry);
           }

           #
           # If Emulating get out
           #
           if ($gbEmulate)
           {
               return();
           }

           $giRetCode =
               catconExec(@SqlAry, 
                          $CATCONPARALLEL, # run multi-threaded
                          0,  # run in every Container if Consolidated
                          0,  # Don't issue process init/completion statements
                          $Inclusion,      # Inclusion List for Containers
                          $Exclusion,      # Exclusion List for Containers
                          $SqlIdentifier,  # SQL Identifier
                          $CmpQuery);      # component query for PDB
           if ($giRetCode)
           {
               catctlDie("$MSGFCATCONEXEC $!");
           }
       }
   }

} # End of catctlExecutePhaseFiles


######################################################################
# 
# catctlStartPhase - Send a bunch of Sql Commands to processors.
#
# Description: Sends Sql commands to do the following:
#              Update internal phase tables
#              Display start phase times in log files
#              Run Sql Session init script.
#   
#
# Parameters:
#   - phase number (IN)
#   - Inclusion List for Containers (IN)
#   - Exclusion List for Containers (IN)
######################################################################
sub catctlStartPhase
{
    my $ph = $_[0];         # phase no
    my $pInclusion = $_[1]; # Inclusion List
    my $pExclusion = $_[2]; # Exclusion List
    my $TIMESTART = qq/SELECT 'PHASE_TIME___START $ph ' || TO_CHAR(SYSTIMESTAMP,'YY-MM-DD HH:MI:SS') AS catctl_timestamp FROM SYS.DUAL;\n/;
    my $SQL_PHASE0_STARTTIME="SELECT TO_CHAR(SYSTIMESTAMP,'YY-MM-DD-HH:MI:SS') AS catctl_phase0_sysdate FROM SYS.DUAL;\n/";
    my $Sql           = "";
    my $x             = 0;  # Index counter
    my $DMLINS        = "I";# DML operation in registry$upg_resume
    my %cp;                 # Component
    my $cid = "";           # Actual CID

    #
    # Don't turn on load with compile switch until
    # after phase 0 otherwise we get errors
    #
    if ($ph != 0)
    {
        #
        # Turn on and off Compile switch as script dictates
        #
        $gsLoadComp = ($phase_compile[$ph] == $gbLoadWithComp) 
            ? $LOADWITHCOMP 
            : $LOADWITHOUTCOMP;

        #
        # Load without Compile is turn on in phase 1
        # We will get errors if we turn on before phase 1.
        #
        $SqlAry[0] = $gsLoadComp;
        $giRetCode = catconRunSqlInEveryProcess(@SqlAry);
        if ($giRetCode)
        {
           catctlDie("$MSGFCATCONRUNSQLINEVERYPROC $!");
        }
    }

    #
    # Show Time Start in Log Files
    #

    $SqlAry[0] = $TIMESTART;
    $giRetCode = catconRunSqlInEveryProcess(@SqlAry);
    if ($giRetCode)
    {
        catctlDie("$MSGFCATCONRUNSQLINEVERYPROC $!");
    }

    # For phase 0 we just track the start time to later call catctlAutoPhaseTrace in
    # subroutine catctlRunPhase. For any phase >0 catctlAutoPhaseTrace is called here.
    if ($ph == 0)
    {
	if ($gbInstance)
	{
 		 $phase0_starttime="'" . catctlQuery($SQL_PHASE0_STARTTIME,$gsRTInclusion) . "'";
	}
	else
	{
		$phase0_starttime="'" . catctlQuery($SQL_PHASE0_STARTTIME,undef) . "'";
	}
	
    }
    else
    {
	catctlAutoPhaseTrace ($ph, $DMLINS,undef,$gsRTInclusion);
    }

    #
    # run session initialization script in every process
    # except for phase 0. phase 0 is a single process by default
    # NOTE: even if this phase is single-threaded, multiple processes may be 
    #       involved in executing its scripts if we are operating on a 
    #       Consolidated DB
    if (($ph != 0) && (!$gbEmulate))
    {
        # Here is created the session file's array, the key is the filename
        # and the value is the cid, only the session files have this struture 
        @cp{ split( $SPACE, join( $SESFILESUFIX.$SPACE, @AryCmpPrefs ).$SESFILESUFIX.$SPACE ) } = @AryCmps;
         for ($x = 0; $x < @session_files; $x++) 
         {
            my $runScript = 1;
            # Run only in the start to stop phases (stop phase 0 always)
            if (($ph >= $session_start_phase[$x]) &&
                (($ph <= $session_stop_phase[$x]) ||
                 ($session_stop_phase[$x] == 0)))
            {
                # Creating the skip query for components run-time check
                my($filename, $dirs, $suffix) = fileparse( $session_files[$x] );
                # if filename is a valid session file name it will return the cid as value
                if ( $cp{$filename} ) {
                    $cid = $cp{$filename};
                    $Sql = "select sys.dbms_registry_sys.catcon_query 
                    (sys.dbms_assert.simple_sql_name('$cid')) from sys.dual";
                    $pInclusion = (!defined $pInclusion or $pInclusion eq 'CDB$ROOT')? '' : $pInclusion;
                    my @result = catconQuery($Sql,$pInclusion);
                    if ($result[0] eq "") {
                       $runScript = 0;   # do not run any of the scripts
                    }
                }
                #
                # run session files in every process
                #
                if ($runScript) {
                    $SqlAry[0] = $session_files[$x];
                    $giRetCode = catconRunSqlInEveryProcess(@SqlAry);
                    if ($giRetCode)
                    {
                        catctlDie("$MSGFCATCONRUNSQLINEVERYPROC $!");
                    }
                }
            }
        }
    }

} # End of catctlStartPhase

######################################################################
# 
# catctlEndPhase - Send Sql Commands at the end of phase.
#
# Description: Sends Sql commands to do the following:
#              Update internal phase tables
#              Display end phase times in log files
#   
#
# Parameters:
#   - phase number (IN)
#   - Inclusion List for Containers (IN)
#   - Exclusion List for Containers (IN)
######################################################################
sub catctlEndPhase
{
    my $ph = $_[0];   # phase no
    my $pInclusion = $_[1]; # Inclusion List
    my $pExclusion = $_[2]; # Exclusion List
    my $TIMEEND = qq/SELECT 'PHASE_TIME___END $ph ' ||TO_CHAR(SYSTIMESTAMP,'YY-MM-DD HH:MI:SS')  AS catctl_timestamp FROM SYS.DUAL;\n/;
    my $Sql           = "";
    my $DMLUPD        = "U";  # DML operation in registry$upg_resume

    #
    # Show End Start in Log Files
    #
    $SqlAry[0] = $TIMEEND;
    $giRetCode = catconRunSqlInEveryProcess(@SqlAry);
    if ($giRetCode)
    {
        catctlDie("$MSGFCATCONRUNSQLINEVERYPROC $!");
    }
  # Call catctlAutoPhaseTrace to update phase end running time and errors (if any) 
  # in registry$upg_resume table.
  
	catctlAutoPhaseTrace ($ph, $DMLUPD,undef,$gsRTInclusion);
 
} # End of catctlEndPhase


######################################################################
# 
# catctlSetDefRTArgs - Set Default RunTime Arguments
#
# Description:
#   This subroutine sets the default RunTime Arguments for catconExec.
#
#
# Parameters:
#   - None
######################################################################
sub catctlSetDefRTArgs {

    $gsRTInclusion  = $gsNoInclusion;
    $gsRTExclusion  = $gsNoExclusion;
    $gsRTIdentifier = $gsNoIdentifier;

} # end catctlSetDefRTArgs


######################################################################
# 
# catctlSetCDBLists - Set up Inclusion and Exclusion Lists
#
# Description:
#   This subroutine sets up Inclusion and Exclusion Lists for us
#   to run ROOT first.  Also it detects if user list contains root
#   for inclusion or execlusion.  It must parse out the root information
#   and set the appropriate flags to indicate what the user has passed.
#   We only want PDB's in the Inclusion and Exclusion Lists.  The
#   Root procession will be controlled by us.
#
#
# Parameters:
#   - psPriFile - Priority File Input
######################################################################
sub catctlSetCDBLists {

    my $psPriFile = $_[0];   # Priority File
    my $idx = 0;
    my $bRootValid = $TRUE;
    my $Msg = "";
    my $MsgCnt = 0;
    my $printParseLists = ($psPriFile)?$FALSE:$TRUE; # Print ParseList flag

    #
    # Get Container Names
    #
    @AryContainerNames = catconGetConNames();

    #
    # Print Out the Container Names
    #
    catctlPrintMsg ("\n$CONTAINERMSG\n\n",$TRUE,$FALSE);
    for ($idx = 0; $idx < @AryContainerNames; $idx++)
    {
        $Msg = $Msg.$AryContainerNames[$idx]." ";
        $MsgCnt++;
        if ($MsgCnt == 4)
        {
            catctlPrintMsg ("$Msg\n",
                            $TRUE,
                            $FALSE);
            $MsgCnt = 0;
            $Msg    = "";
        }
    }

    if ($MsgCnt)
    {
        catctlPrintMsg ("$Msg\n",
                        $TRUE,
                        $FALSE);
        $MsgCnt = 0;
        $Msg    = "";
    }

    #
    # Load priority File
    #
    if ($psPriFile)
    {
        catctlLoadPriorityFile($psPriFile,$printParseLists);
        $printParseLists = $TRUE;
    }

    #
    # Set Flags
    #
    $gbCdbDatabase    = $TRUE;
    $gbRootProcessing = $TRUE;
    $gbSeedProcessing = $TRUE;
    $gbPdbProcessing  = $FALSE;


    #
    # If Inclusion and Exlcusion Lists
    #
    my $parseListMsg = "Invoking catctlParseLists with ";
    if (defined $gCInclusion) {
      $parseListMsg .= "Inclusion List = [$gCInclusion]\n";
    } else {
      $parseListMsg .= "undefined Inclusion List\n";
    }

    if (defined $gCExclusion) {
      $parseListMsg .= "and Exclusion List = [$gCExclusion]\n";
    } else {
      $parseListMsg .= "and undefined Exclusion List";
    }

    catctlPrintMsg($parseListMsg, $TRUE, $FALSE);
 
    catctlParseLists($gCInclusion,
                     $gCExclusion, 
                     \@AryParsedList,
                     \@AryContainerNames,
                     \@AryPDBInstanceList,
                     $psPriFile,
                     $printParseLists);

    #
    # Is Root opened in upgrade mode?
    #
    $gbRootOpenInUpgMode = catctlGetRootOpenMode();

    #
    # Start and stop phases must have an
    # a container list for CDBs.
    #
    if ($gbStartStopPhase)
    {
        #
        # Set Inclusions to be that of the users
        # Don't override
        #
        $gsRTInclusion = $gCInclusion;
        $gsRTExclusion = $gCExclusion;

        #
        # When specifying Start and Stop phases we must have a container
        # inclusion list when upgrading a CDB or PDB only one inclusion
        # list item is allowed per CDB.
        #
        if ( ($gbListProcessing == $FALSE) ||
             (!$gCInclusion)               ||
             (@AryParsedList != 1) ) 
        {
            catctlPrintMsg("\n$MSGFCONTAINERLIST\n",$TRUE,$TRUE);
            $gbWrapUp = $FALSE;
            catconWrapUp();
            exit($CATCTL_ERROR);
        }
    }

    #
    # Check to make sure Root is valid
    #
    $bRootValid = catctlIsRootValid($gbUpgrade,
                                    $gbRootProcessing,
                                    $gbPdbProcessing,
                                    $gbInstance);

    #
    # Get out if CDB$ROOT is invalid
    #
    if (!$bRootValid)
    {
        catctlPrintMsg("\n$MSGFROOTINVALID\n",$TRUE,$TRUE);
        $gbWrapUp = $FALSE;
        catconWrapUp();
        exit($CATCTL_ERROR);
    }

} # end catctlSetCDBLists

######################################################################
# 
# catctlPrioritizeLists - Prioritize Lists
#
# Description:
#   Prioritize Lists since container names will be in priority order
#   we have to organize the user list in priority order.
#
#
# Parameters:
#   pAryParsedList      - IN/OUT Parsed Array list
#   pAryContainerNames  - IN Container Names
# Returns
#   - None
######################################################################
sub catctlPrioritizeLists {

    my $pAryParsedList     = $_[0];  # Parsed Array
    my $pAryContainerNames = $_[1];  # Container names in priority order
    my @ContainerIdx;                # Container Index
    my @SortedContainerIdx;          # Sorted Container Index
    my $idx         = 0;             # Index Counter
    my $ConIdx      = 0;             # Index counter
    my $AryItem     = "";            # Exclusion or Inclusion list item
    my $ConItem     = "";            # Container List item


    #
    # Sort Array according to priority
    # Loop through list
    #
    foreach $AryItem (@$pAryParsedList)
    {
        #
        # Compare against sorted priority Names
        #
        $idx = 0;
        foreach $ConItem (@$pAryContainerNames)
        {
            #
            # When we find a match store
            # the Container idx
            #
            if ($ConItem eq $AryItem)
            {
                push (@ContainerIdx,$idx);
            }
            $idx++;
        }
    }

    #
    # Sort the Container index
    #
    @SortedContainerIdx = sort @ContainerIdx;
    $idx = 0;

    #
    # Reorder list according to it's priority
    #
    foreach $ConIdx (@SortedContainerIdx)
    {
        @$pAryParsedList[$idx] = @$pAryContainerNames[$ConIdx];
        $idx++;
    }


}  # End catctlPrioritizeLists


######################################################################
# 
# catctlParseIncLists - Parse Inclusion Lists
#
# Description:
#   Parse Inclusion Lists
#
#
# Parameters:
#   pAryParsedList      - IN/OUT Parsed Inclusion list
#   pAryContainerNames  - IN Container Names
#   pAryPDBInstanceList - IN/OUT Generated Inclusion list
#   psPriFile           - IN Priority File
# Returns
#   - None
######################################################################
sub catctlParseIncLists {

    my $pAryParsedList       = $_[0];     # Parsed Inclusion List
    my $pAryContainerNames   = $_[1];     # Container names
    my $pAryPDBInstanceList  = $_[2];     # Generated Inclusion List
    my $psPriFile            = $_[3];     # Priority File
    my $bFirstTime           = $TRUE;     # First Time Flag
    my $AryItem              = "";        # Inclusion list item
    my $ConItem              = "";        # Container List item
    my $iPriorityNo          = 0;         # PriorityNoAryItem
    my $isFreshDB            = 0;         # To determine if this is a newly created PDB.

    #
    # Initialize Globals
    #
    $gbRootProcessing  = $FALSE;
    $gbSeedProcessing  = $FALSE;

    if (!$psPriFile)
    {
        catctlPrioritizeLists($pAryParsedList, $pAryContainerNames);
    }

    #
    # Check Inclusion List
    #
    foreach $AryItem (@$pAryParsedList)
    {
        #
        # Found Root Tag Including ROOT
        #
        if ($AryItem eq $CDBROOTTAG)
        {
	   if (catctlIsROOTOkay($AryItem))
           {
                $gbRootProcessing = $TRUE;
           }
        }

        #
        # Found Seed Tag Including SEED
        #
        if ($AryItem eq $PDBSEEDTAG)
        {
            $gbSeedProcessing = $TRUE;
        }

        if ($AryItem ne $CDBROOTTAG)
        {
            if (catctlIsPDBOkay($AryItem,$giStartPhase))
            {
               	 if ($bFirstTime)
                 {
                    	$bFirstTime    = $FALSE;
                    	$gsRTInclusion = $AryItem;
                 }
                 else
                 {
                 	$gsRTInclusion = $gsRTInclusion." ".$AryItem;
                 }

               	 if (!$psPriFile)
                 {	
                 	#
                 	# Get the Priority Number
                 	#
                  	$iPriorityNo = catctlGetPriority($AryItem);
                  	$HashPdbPriData{$AryItem} = $iPriorityNo;
               	 }

                #
                # Store pdb Item in list
                #
                push(@$pAryPDBInstanceList, $AryItem);
                $gbPdbProcessing  = $TRUE;
	    }
        }
    } # end for AryItem

   if(@pAryPDBInstanceFresh>0)
   {
         catctlPrintMsg("\nContainer Database is already at version: ".CATCONST_BUILD_VERSION.". No UPGRADE actions will be performed on PDBs:\n[@pAryPDBInstanceFresh] \n",$TRUE,$TRUE);
   }

}  # End catctlParseIncLists


######################################################################
# 
# catctlParseExcLists - Parse Exclusion Lists
#
# Description:
#   Parse Exclusion Lists
#
#
# Parameters:
#   pAryParsedList      - IN/OUT Parsed Exlusion list
#   pAryContainerNames  - IN Container Names
#   pAryPDBInstanceList - IN/OUT Generated Inclusion list
#   psPriFile           - IN Priority File
# Returns
#   - None
######################################################################
sub catctlParseExcLists {

    my $pAryParsedList       = $_[0];     # Parsed Exclusion List
    my $pAryContainerNames   = $_[1];     # Container names
    my $pAryPDBInstanceList  = $_[2];     # Generated Inclusion List
    my $psPriFile            = $_[3];     # Priority File
    my $bFirstTime           = $TRUE;     # First Time Flag
    my $bFound               = $TRUE;     # Found Flag
    my $AryItem              = "";        # Inclusion list item
    my $ConItem              = "";        # Container List item
    my $iPriorityNo          = 0;         # PriorityNo

    #
    # Initialize Globals
    #
    $gbRootProcessing  = $TRUE;
    $gbSeedProcessing  = $TRUE;

    #
    # Take everything in the container list
    # except what is in the exclusion list
    #
   
    #
    # Check exclusion list for root or seed
    #
    foreach $AryItem (@$pAryParsedList)
    {
        #
        # Found Root Tag Excluding ROOT
        #
        if ($AryItem eq $CDBROOTTAG)
        {
            $gbRootProcessing = $FALSE;
        }

        #
        # Found Seed Tag Excluding SEED
        #
        if ($AryItem eq $PDBSEEDTAG)
        {
            $gbSeedProcessing = $FALSE;
        }
    } # end for AryItem

    #
    # Check exclusion list
    #
    foreach $ConItem (@$pAryContainerNames)
    {
        $bFound = $FALSE;
        foreach $AryItem (@$pAryParsedList)
        {
            if ($AryItem eq $ConItem)
            {
                $bFound = $TRUE;
                last;
            }
        }

        #
        # Not Found add it to the list
        #
        if (!$bFound) 
        {

            if ($ConItem eq $CDBROOTTAG)
            {
                if (!catctlIsROOTOkay($ConItem))
                {
                	$gbRootProcessing = $FALSE;
                }
            }

            if ($ConItem ne $CDBROOTTAG)
            {
                if (catctlIsPDBOkay($ConItem,$giStartPhase))
                {
                    if ($bFirstTime)
                    {
                        $bFirstTime    = $FALSE;
                        $gsRTExclusion = $ConItem;
                    }
                    else
                    {
                        $gsRTExclusion = $gsRTExclusion." ".$ConItem;
                    }

                    #
                    # Get the Priority Number
                    #
                    if (!$psPriFile)
                    {
                        $iPriorityNo = catctlGetPriority($ConItem);
                        $HashPdbPriData{$ConItem} = $iPriorityNo;
                    }

                    #
                    # Store pdb Item in list
                    #
                    push(@$pAryPDBInstanceList, $ConItem);
                    $gbPdbProcessing  = $TRUE;
                }
            } 
        } # End if Not Found
    } # end for ConItem
 

   if(@pAryPDBInstanceFresh>0)
   {
         catctlPrintMsg("\nContainer Database is already at current version. No UPGRADE actions will be performed on PDBs:\n[@pAryPDBInstanceFresh] \n",$TRUE,$TRUE);
   }

}  # End catctlParseExcLists

######################################################################
# 
# catctlParseNoLists - Process all containers
#
# Description:
#   Process all containers
#
#
# Parameters:
#   pAryContainerNames     - IN Container Names
#   pAryPDBInstanceList - IN/OUT Generated Inclusion list
#   psPriFile              - IN Priority File
# Returns
#   - None
######################################################################
sub catctlParseNoLists {

    my $pAryContainerNames   = $_[0];     # Container names
    my $pAryPDBInstanceList  = $_[1];     # Generated Inclusion List
    my $psPriFile            = $_[2];     # Priority File
    my $bFirstTime           = $TRUE;     # First Time Flag
    my $bFound               = $TRUE;     # Found Flag
    my $ConItem              = "";        # Container List item
    my $iPriorityNo          = 0;         # PriorityNo
    my $isFreshDB            = 0;	  # To determine if this is a newly created PDB. 

    #
    # Initialize
    #
    $gbRootProcessing  = $FALSE;
    $gbSeedProcessing  = $FALSE;


    #
    # No List take everything in container list
    # but the root.
    #
    foreach $ConItem (@$pAryContainerNames)
    {
        #
        # Found Root Tag Including ROOT
        #
        if ($ConItem eq $CDBROOTTAG)
        {
           if (catctlIsROOTOkay($ConItem))
           {
                $gbRootProcessing = $TRUE;
           }
        }

        #
        # Found Seed Tag Including SEED
        #
        if ($ConItem eq $PDBSEEDTAG)
        {
            $gbSeedProcessing = $TRUE;
        }

        #
        # Everything in list but ROOT
        #
        if ($ConItem ne $CDBROOTTAG)
        {
            if (catctlIsPDBOkay($ConItem,$giStartPhase))
            {
               	if ($bFirstTime)
               	{
                 	$bFirstTime    = $FALSE;
                    	$gsRTInclusion = $ConItem;
               	}
               	else
                {
               		$gsRTInclusion = $gsRTInclusion." ".$ConItem;
               	}
               	#
               	# Get the Priority Number
               	#
               	if (!$psPriFile)
               	{
                	$iPriorityNo = catctlGetPriority($ConItem);
                    	$HashPdbPriData{$ConItem} = $iPriorityNo;
               	}
               	#
               	# Store pdb Item in list
               	#
               	push(@$pAryPDBInstanceList, $ConItem);
               	$gbPdbProcessing  = $TRUE;
	    }
        }
    }  # End for conitem

   if(@pAryPDBInstanceFresh>0)
   {
  	 catctlPrintMsg("\nContainer Database is already at current version. No UPGRADE actions will be performed on PDBs:\n[@pAryPDBInstanceFresh] \n",$TRUE,$TRUE);
   }

}  # End catctlParseNoLists

######################################################################
# 
# catctlParseLists - Parse Inclusion and Exclusion Lists
#
# Description:
#   Parse Inclusion and Exclusion Lists
#
#
# Parameters:
#   pInclusion          - IN  Inclusion list
#   pExclusion          - IN  Exclusion list
#   pAryParsedList      - IN/OUT Parsed Exlusion list
#   pAryContainerNames  - IN Container Names
#   pAryPDBInstanceList - IN/OUT Generated Inclusion list
#   psPriFile           - IN  Priority  file
# Returns
#   - None
######################################################################
sub catctlParseLists {

    my $pInclusion           = $_[0];       # Inclusion List
    my $pExclusion           = $_[1];       # Exclusion List
    my $pAryParsedList       = $_[2];       # Parsed Exclusion List
    my $pAryContainerNames   = $_[3];       # Container names
    my $pAryPDBInstanceList  = $_[4];       # Generated Inclusion List
    my $psPriFile            = $_[5];       # Priority File
    my $printParseLists      = $_[6];       # Print ParseList flag
    my $pList                = $pInclusion; # Default to Inclusion List

    #
    # Initialize Lists
    #
    $gsRTInclusion     = "";
    $gsRTExclusion     = "";
    $gsParsedInclusion = "";
    $gsParsedExclusion = "";
    $HashPdbPriData{$CDBROOT} = $PRICDBROOT;

    #
    # Set List to Exclusion if present
    #
    if ($pExclusion)
    {
        $pList = $pExclusion;
    }

    #
    # Parse out the array lists
    #
    if ($pList)
    {
        #
        # Split out list into an array
        #
        $gbListProcessing  = $TRUE;
        $pList =~ s/^'(.*)'$/$1/;  # strip single quotes
        $pList =~ s/^"(.*)"$/$1/;  # strip double quotes

        @$pAryParsedList = split(' ', $pList);

        #
        # All the PDB names must exist in the database
        #
        my %fpdb = map{$_=>1} @$pAryContainerNames;
        my @fke_pdbs = grep (!defined $fpdb{$_}, @$pAryParsedList);
        if (@fke_pdbs)
        {
            catctlDie("$MSGNOTEXISTPDBNAME [@fke_pdbs]\n Exiting.\n");
        }

        #
        # Take All PDB's excluding root.
        # If this is an inclusion list.
        #
        if ($pInclusion)
        {
            catctlParseIncLists ($pAryParsedList,
                                 $pAryContainerNames,
                                 $pAryPDBInstanceList,
                                 $psPriFile);
        } # end if inclusion list

        #
        # Take everything in the container list
        # except what is in the exclusion list
        #
        if ($pExclusion)
        {
            catctlParseExcLists ($pAryParsedList,
                                 $pAryContainerNames,
                                 $pAryPDBInstanceList,
                                 $psPriFile);
        }
    } # end if list
    else
    {
        catctlParseNoLists ($pAryContainerNames,
                            $pAryPDBInstanceList,
                            $psPriFile);
    } # End else for lists


    #
    # Save Original Root Processing value
    #
    $gbSavRootProcessing = $gbRootProcessing;

    #
    # Set the Parsed Inclusion/Exclusion Lists
    #
    $gsParsedInclusion = $gsRTInclusion;
    $gsParsedExclusion = $gsRTExclusion;

    $pList = $gsParsedInclusion ? $gsParsedInclusion : $gsParsedExclusion;
    $pList = $pList ? $pList : $NONE;

    if ($printParseLists)
    {
      catctlPrintMsg("Generated PDB Inclusion:[$pList]\n",$TRUE,$TRUE);
    }
    else
    {
      catctlPrintMsg("Generated PDB Inclusion:[$pList]\n",$TRUE,$FALSE);
    }

}  # End catctlParseLists

######################################################################
# 
# catctlSetProcessNo - Set Process Number
#
# Description: Set the number of sql processors to start up.
#              0 runs catupgrd.sql the old fashion way.
#
# Parameters:
#   - None
######################################################################
sub catctlSetProcessNo
{
    #
    # Sql Processors
    #
    if ($opt_n)
    {
        $giProcess = abs($opt_n) or catctlDie("$MSGFINVOPTIONVALUE [-n] $!");
    }


    #
    # Sql PDB Processors
    #
    if ($opt_N)
    {
        $giPdbProcess = abs($opt_N) or catctlDie("$MSGFINVOPTIONVALUE [-N] $!");
    }

    #
    # Serial Run
    #
    if ($gbSerialRun)
    {
        $giProcess   = 1;
    }


} # End of catctlSetProcessNo


######################################################################
# 
# catctlSetFileNameToExecute - Set Filename to execute
#
# Description: Parse out the file to execute.
#
# Parameters:
#   - None
######################################################################
sub catctlSetFileNameToExecute
{
    my $mFile = '';
    my $CATCTLENV_VAR  = "CATCTL";
    my $CATCATCTLVALUE = "UpGradeToday";

    if ($gSrcDir)
    {
        #
        # Parse Out File Spec without directory info and .sql extension
        #
        if (-r "${gSrcDir}")
        {
            $giUseDir = 1;
            $gsFile = fileparse($gsFile,".sql").".sql";
            $gsPath = $gSrcDir.$SLASH.$gsFile;
        }
        else
        {
            catctlDie("$MSGFCATCTLSETFILENAMETOEXECUTE $!");
        }
    }
    else
    {
        $gsPath = $gsFile;
    }

    #
    # Check for Upgrade and set
    # CATCTL environment variable
    #
    $mFile = lc($gsFile); # Lower Case File
    if (rindex($mFile, "catupgrd") == -1)
    {
        $gbUpgrade = $FALSE;
    }
    else
    {
        $ENV{$CATCTLENV_VAR} = $CATCATCTLVALUE;
    }

    #
    # If running serially check for
    # catupgrd.sql and add parallel=no
    #
    if ($gbSerialRun)
    {
        if (rindex($mFile, "catupgrd") != -1)
        {
            catctlDie("$MSGFSERIALOPT");
        }
    }


} # End of catctlSetFileNameToExecute


######################################################################
# 
# catctlSetLogFiles - Set Log files
#
# Description: Parse out the Log file(s).
#
# Parameters:
#   INPUTS: pTempDir       = Temp Directory
#           pLogDir        = User Log Dir
#           pFile          = Run File (ie catupgrd.sql)
#           pIdentifier    = Log File Identifier
#           pDbName        = Oracle Unique DB Name
#           pOracleBaseDir = Oracle Base Home Directory
#
######################################################################
sub catctlSetLogFiles
{

    my $pTempDir       = $_[0];         # Temp Log Directory
    my $pLogDir        = $_[1];         # User Log Directory
    my $pFile          = $_[2];         # File To Run
    my $pIdentifier    = $_[3];         # Log File Identifier
    my $pDbName        = $_[4];         # Oracle Unique DB Name
    my $pOracleBaseDir = $_[5];         # Oracle Base Dir
    my $DirName        = $pLogDir;      # Set equal to user Log Dir
    my $RdbmsLogDir    = "";            # rdbms/log directory
    my $BaseDir        = "";            # BaseDir
    my $TempDirName    = "";            # Temp Dir Name
    my $UpgradeDatedDir   = $UPGRADEDIR.catctlGetDateTime(1); # Upgrade Date and Time Directory


    #
    # Parse Out File Spec without directory info and .sql extension
    #
    $gsSpoolLog = fileparse($pFile,".sql");


    #
    # Add in unique log identifier
    # Ie catupgrd(Sid)#.log
    #
    if ($gIdentifier)
    {
        $gsSpoolLog = $gsSpoolLog.$pIdentifier;
        $gsErrorLog = $gsSpoolLog."_err.log";
    }
    
    #
    # Create Defaut Directory
    #
    if (!$DirName)
    {
        #
        # Set to orabase (/cfgtoollogs/sid/upgrade) or tmp 
        #
        if ($pOracleBaseDir)
        {
            $BaseDir     = $pOracleBaseDir;
            $RdbmsLogDir = $pOracleBaseDir.$SLASH.$RDBMSDIR.$SLASH.$LOGDIR;
        }
        else
        {
            $BaseDir     = $pTempDir;
        }

        #
        # Set the directory Names
        #
        if ($pDbName)
        {
            $DirName = $BaseDir.$SLASH.$CONFIGDIR.
                $SLASH.$pDbName.$SLASH.$UpgradeDatedDir;
        }
        else
        {
            $DirName = $BaseDir.$SLASH.$CONFIGDIR.
                $SLASH.$UpgradeDatedDir;
        }

        #
        # Make Directory if not present
        #
        if (! -d $DirName)
        {
            #
            # Create Base Directory
            #
            $DirName = catctlCreateDir($BaseDir,$pDbName,$UpgradeDatedDir,$CONFIGDIR);

            #
            # Check Directories
            #
            if ($pOracleBaseDir)
            {
                #
                # Check for writeable directory
                #
                if (!catctlValidDir($DirName,"W"))
                {
                    catctlPrintMsg ("\nUnable to Create [$DirName]\n".
                                    "Defaulting to [$RdbmsLogDir]\n",
                                    $TRUE,$TRUE);

                    $DirName = $RdbmsLogDir;

                    #
                    #  Check for writeable rdbms log directory
                    #
                    if (catctlValidDir($DirName,"W"))
                    {
                        $DirName = catctlCreateDir($DirName,$pDbName,$UpgradeDatedDir,$CONFIGDIR);
                    }
                    
                    #
                    # Check for writable rdbms\log directory
                    #
                    if (!catctlValidDir($DirName,"W"))
                    {
                        catctlPrintMsg ("\nUnable to Log to [$DirName]\n".
                                        "Defaulting to [$TempDirName]\n",
                                        $TRUE,$TRUE);

                        #
                        # Create temporary directory with default dir structure
                        #
                        $DirName = catctlCreateDir($pTempDir,$pDbName,$UpgradeDatedDir,$CONFIGDIR);

                        #
                        # If not writable default to the temporary directory
                        #
                        if (!catctlValidDir($DirName,"W"))
                        {
                            catctlPrintMsg ("\nUnable to Create [$DirName]\n".
                                            "Defaulting to [$pTempDir]\n",,
                                            $TRUE,$TRUE);
                            $DirName = $pTempDir;
                        }
                    }
                }
            }
            else
            {
                #
                # If not writable default to the temporary directory
                #
                if (!catctlValidDir($DirName,"W"))
                {
                    catctlPrintMsg ("\nUnable to Create [$DirName]\n".
                                    "Defaulting to [$pTempDir]\n",
                                    $TRUE,$TRUE);
                    $DirName = $pTempDir;
                }
            }
        } # End if Make Directory if not present
    } # End Create Default Directory

    #
    # Check Log Directory or Current Directory to make sure
    # it is valid for writing files
    #
    if (catctlValidDir($DirName,"W"))
    {
        $gsSpoolLogDir = $DirName.$SLASH.$gsSpoolLog;
        $gsErrorLogDir = $DirName.$SLASH.$gsErrorLog;
        $gsSpoolDir    = $DirName;
        $gsReportName  = $gsSpoolDir.$SLASH.$UPGREPORT;

        $gsDatapatchLogUpgrade = $gsSpoolLogDir . "_datapatch_upgrade.log";
        $gsDatapatchErrUpgrade = $gsSpoolLogDir . "_datapatch_upgrade.err";
        $gsDatapatchLogNormal  = $gsSpoolLogDir . "_datapatch_normal.log";
        $gsDatapatchErrNormal  = $gsSpoolLogDir . "_datapatch_normal.err";
    }
    else
    {
        catctlDie("$MSGFCATCTLSETFILELOGFILES catctlValidDir [$DirName] $!");
    }

} # End of catctlSetLogFiles

######################################################################
# 
# catctlCreateDir - Create Directory
#
# Description: Create Directory
#
# Parameters:
# Inputs
#   pBaseDir         - Base Directory to create
#   pDbName          - Oracle Unique DB Name
#   pUpgradeDatedDir - Upgrade directory with date and time
#   pConfigDir       - Config Directory
# Returns
#   None.
######################################################################
sub catctlCreateDir
{
    my $pBaseDir         = $_[0];         # Base log Directory
    my $pDbName          = $_[1];         # Oracle Unique DB Name
    my $pUpgradeDatedDir = $_[2];         # Dated Upgrade Directory
    my $pConfigDir       = $_[3];         # Config directory
    my $DirName          = "";            # Directory Name
    my $BaseDir          = $pBaseDir;     # Local Base Directory
    my $MASK             = 0755;          # o:rwx g:rx w:x
    my $LastChar       = "";            # Last character

    $LastChar = substr($BaseDir,length($BaseDir)-1,1);
    #
    # Remove Slash if found
    #
    if ($LastChar eq $SLASH)
    {
        $BaseDir = substr($BaseDir,0,length($BaseDir)-1);
    }

    #
    # Create basedir/cfgtoollogs directory
    #
    if ($pConfigDir)
    {
        $DirName = $BaseDir.$SLASH.$pConfigDir;
        if (! -d $DirName)
        {
            mkdir($DirName);
            chmod($MASK,$DirName);
        }
    }

    #
    # Create basedir/cfgtoollogs/dbname directory
    #
    if ($pDbName)
    {
        $DirName = $DirName.$SLASH.$pDbName;
        if (! -d $DirName)
        {
            mkdir($DirName);
            chmod($MASK,$DirName);
        }
    }

    #
    # Create basedir/cfgtoollogs/dbname/upgradeDateTime directory
    #
    $DirName = $DirName.$SLASH.$pUpgradeDatedDir;
    if (! -d $DirName)
    {
        mkdir($DirName);
        chmod($MASK,$DirName);
    }

    return ($DirName);

}  # end catctlCreateDir

######################################################################
# 
# catctlValidDir - Validate Directory
#
# Description: Validate Directory
#
# Parameters:
#   DirName (IN)
#   ReadOrWrite (IN) Values "W" - Write "R" - Read
# Returns
#   TRUE  - Directory Okay
#   FALSE - Directory Not Okay
######################################################################
sub catctlValidDir
{
    my $DirName     = $_[0];     # Directory Name
    my $ReadOrWrite = $_[1];     # Read Or Write directory

    #
    # No directory name specified
    #
    if (!$DirName)
    {
        return ($FALSE);
    }

    stat($DirName);

    #
    # Directory does not exits or is not a directory
    #
    if (! -e _ || ! -d _)
    {
        return ($FALSE);
    }


    #
    # Directory is not writeable
    #
    if ($ReadOrWrite eq "W")
    {
        if (! -w _)
        {
            return ($FALSE);
        }
    }

    return ($TRUE);

}  # End catctlValidDir


######################################################################
# 
# catctlDebugTrace - Create Perl Debug File
#
# Description: Create Perl Debug File and fire up the debug image
#
# Another way to do this is to set the enviromental variable
#    PERLDB_OPT "NonStop AutoTrace=1 frame=2 LineInfo=catctl_trace.log"
#
# Parameters:
#   None
# Returns
#   TRUE  - Ran in Debug Mode
#   FALSE - Could Not Run In Debug Mode
######################################################################
sub catctlDebugTrace
{
    my $pDebugEnvValue     = $_[0];          # Environmental Variable
    my $pLogDir            = $_[1];          # Log Directory
    my $mode               = 0400;           # Owner gets read privs
    my $delmode            = 0777;           # All Privs to del file
    my $PerlDebugNameUnix  = ".perldb";      # Perl Unix Name Unix
    my $PerlDebugNameWin   = "perldb.ini";   # Perl Windows Name
    my $PerlDebugName      = $PerlDebugNameUnix;   # Perl Windows Name
    my $CatctlProgram      = $^X." -d ".$0;  # Catctl Program
    my $CatctlArgs         = "";             # Construct Catctl Command
    my $argno              = 0;              # Index
    my $argcnt             = $#gArgs;        # Arg Count
    my $argloop            = ($argcnt -1);   # Max Arg Loop
    my $RetStat            = $TRUE;          # Return Status
    my $bContainer         = $FALSE;         # Processing Containers
    my $bAddSpace          = $TRUE;          # Add Space
    my $dash               = "";             # Dash field
    my $HomeDir            = catctlGetEnv("HOME"); # Home Directory of user
    my $LastChar           = "";
    my $LogDirTemp         = $pLogDir;
    my $HomeDirTemp        = $HomeDir;
    my $SlashTemp          = $SLASH;
    my $next_arg           = $FALSE;

    #
    # Make Sure HOME environmental variable is set
    #
    if (!$HomeDir)
    {
        catctlPrintMsg ("Please set enviromental variable HOME\n",
                         $TRUE,$TRUE);
        catctlPrintMsg ("Windows SET HOME=C:\\\n".
                        "Unix setenv HOME YourHome or\n".
                        "     export HOME=YourHome\n",
                         $TRUE,$TRUE);
        exit($CATCTL_ERROR);
    }

    #
    # Bug In Perl you should not have to do this
    # Double up on slashes for Windows.
    #
    if ($gbWindows)
    {
        $PerlDebugName = $PerlDebugNameWin;
        $SlashTemp     = $SLASH.$SLASH;
        $LogDirTemp    =~ s/\\/\\\\/g;
        $HomeDirTemp   =~ s/\\/\\\\/g;
        $HomeDirTemp   = $HomeDirTemp;
    }

    #
    # Check to see if we have to add a slash to the
    # home directory.  Perl debugger will trace if
    # trace startup file is located in the user's home
    # directory or in the current directory where
    # catctl.pl is running. We can't place it there anymore
    # because of Read only oracle homes.
    #
    $LastChar = substr($HomeDirTemp,length($HomeDirTemp)-1,1);
    if ($LastChar eq $SLASH)
    {
        $PerlDebugName = $HomeDirTemp.$PerlDebugName;
    }
    else
    {
        $PerlDebugName = $HomeDirTemp.$SlashTemp.$PerlDebugName;
    }

    $LastChar = substr($LogDirTemp,length($LogDirTemp)-1,1);
    if ($LastChar ne $SLASH)
    {
        $LogDirTemp = $LogDirTemp.$SlashTemp;
    }

    #
    # If file present change mode which allow us
    # to delete the file
    #
    if (-e  $PerlDebugName)
    {
        chmod($delmode,$PerlDebugName);
        unlink ($PerlDebugName);
    }

    #
    # Create Perl Debug file
    #
    open(FileOut, '>', $PerlDebugName) or 
            catctlDie("$MSGFCATCTLCREATEDBGFILE - $PerlDebugName $!");
    print FileOut "print STDERR \"\\n\";\n";
    print FileOut "print STDERR \"Running $PerlDebugName\";\n";

    #
    # Create Trace File in the format catctl_YYYYMMDDHHMNSC_pid_trace.log
    #
    print FileOut 
        "(\$s,\$m,\$h,\$md,\$mon,\$y,\$wd,\$yday,\$isd)=localtime();\n";
    print FileOut 
        "\$f=sprintf(\"%04d%02d%02d%02d%02d%02d\",\$y+1900,\$mon+1,\$md,\$h,\$m,\$s);\n";
    print FileOut "\$di=\"$LogDirTemp\";\n";
    print FileOut 
        "\$t=\$di.\"catctl_\".\$f.\"_\".\$\$.\"_trace.log\";\n";
    print FileOut "print STDERR \"\\n\";\n";
    print FileOut "print STDERR \"FileName generated is:[\$t]\";\n";
    print FileOut "print STDERR \"\\n\";\n";
    print FileOut 
        "parse_options(\"NonStop Autotrace frame=16 LineInfo=\$t\");\n";
    close(FileOut);

    #
    # Change protection
    #
    chmod($mode,$PerlDebugName);

    #
    # Display Creation Message
    #
    catctlPrintMsg("\nFileName: [$PerlDebugName] has been created\n", $TRUE,$TRUE);

    #
    # Trace Message Displayed
    #
    catctlPrintMsg("This will produce a debug trace file In the following format:\n",
                   $TRUE,$TRUE);
    catctlPrintMsg("    (catctl_YYYYMMDDHHMNSC_pid_trace.log)\n\n",
                   $TRUE,$TRUE);

    #
    # Construct the arg and
    # re-assembling the command
    # so we can invoke the tracing
    # debugger
    #
    foreach $argno (0 .. $argloop)
    {
        #
        # If an argument was processed, the next iteration
        # is omitted (because it will be the argument)
        #
        if ($next_arg)
        {
           $next_arg = $FALSE;
           next;
        }

        #
        # Parse out first character in argument
        #
        $dash = substr($gArgs[$argno], 0, 1);

        #
        # Evaluate the arguments
        #
        if ($gArgs[$argno] eq "-Z")
        {
            #
            # Prevent Infinite loop when we call ourselves by
            # replacing 1 with 0 so we don't trigger
            # the debugging in the main loop when we call ourselves
            #
            $CatctlArgs = $CatctlArgs." ".$gArgs[$argno];
            $gArgs[$argno+1] = 0;
        }
        elsif ($gArgs[$argno] eq "-c" || $gArgs[$argno] eq "-C")
        {
            #
            # Adding single quotes to lists -c/-C
            #
            my $tmp_plist = $CONTAINERQUOTE.$gArgs[$argno+1].$CONTAINERQUOTE;
            $CatctlArgs = $CatctlArgs." ".$gArgs[$argno]." ".$tmp_plist;
            $next_arg = $TRUE;
        }
        elsif ($bAddSpace)
        {
            #
            # Add Space and Argument 
            #
            $CatctlArgs = $CatctlArgs." ".$gArgs[$argno];
        }
        else
        {
            #
            # Add just the Argument
            #
            $CatctlArgs = $CatctlArgs.$gArgs[$argno];
            $bAddSpace  = $TRUE;
        }

    } # End Foreach Args

    #
    # Add -Z 0 argument if invoked by the
    # environmental variable
    #
    if ($pDebugEnvValue)
    {
        $CatctlArgs = $CatctlArgs." -Z 0";
    }

    #
    # Add Filename to execute in PDB
    #
    $CatctlArgs = $CatctlArgs." ".$gArgs[$argcnt];

    #
    # Display Starting Message
    #
    catctlPrintMsg ("\nStarting in Debug Mode\n[$CatctlProgram$CatctlArgs]\n",
                    $TRUE,$TRUE);

    eval { system("$CatctlProgram$CatctlArgs") };
    if ($@)
    {
        $RetStat = $FALSE;
        catctlPrintMsg ("\nError Executing In Debug Mode $@\n[$CatctlProgram$CatctlArgs]\n",
                         $TRUE,$TRUE);
        warn();
    }

    return ($RetStat);

}  # End catctlDebugTrace

######################################################################
# 
# catctlDelLogFiles - Delete Log files
#
# Description: Delete Old Log Files
#
# Parameters:
#   Starting Index (IN)
#   Ending  Index (IN)
#   Spool Log Directory (IN)
######################################################################
sub catctlDelLogFiles
{
    my $pStartIdx = $_[0];     # Start Index
    my $pEndIdx   = $_[1];     # End Index
    my $psSpoolLogDir = $_[2]; # Spool Log Directory
    my $x         = 0;         # Counter
    my $LogFile   = "";        # Log File

    for ($x = $pStartIdx; $x <= $pEndIdx; $x++)
    {
        $LogFile = $psSpoolLogDir.$x.".log";
        if (-e $LogFile)
        {
            unlink($LogFile);
        }
    }

} # End of catctlDelLogFiles

######################################################################
# 
# catctlSetConnectStr - Set Log files
#
# Description: Add Password to UserName
#
# Parameters:
#   - None
######################################################################
sub catctlSetConnectStr
{
    #
    # User from upgraded database
    #
    if ($gUser)
    {
        if ($gPwdFile)
        {
            my $password;
            open (FileIn, '<', $gPwdFile) or 
                catctlDie("$MSGFCATCTLREADFILES - $gPwdFile $!");
            $password = <FileIn>;
            close (FileIn);
            chomp $password;
            $gUser = $gUser.$PWDSLASH.$password;
        }

        #
        # Remove Slash so we can pass to datapatch
        #
        $gUserName = $gUser;
        if ($gUserName =~ /(.*)\//) 
        {
            $gUserName = $1;
        }
    }

} # End of catctlSetConnectStr

######################################################################
# 
# catctlDisplayPhases - Display Phase Files.
#
# Description: This displays Sql Files that will execute
#              for each phase.
#
# Parameters:
#   - None
######################################################################
sub catctlDisplayPhases
{
    my $numofphasefiles = 0;
    my $bLogtoScreen    = $FALSE;
    my $i               = 0;
    my $x               = 0;
    my $j               = 0;
    my $z               = 0;
    my $fldsize         = 0;
    my $strsize         = 0;
    my $TOTAL_PHASES    = "\nTotal Number of Phases:";

    if ($gbDisplayPhases)
    {
        $bLogtoScreen = $TRUE;
    }

    #
    # Return if this is a PDB instance
    #
    if ($gbInstance)
    {
        return;
    }

    for ($i = 0; $i < @phase_type; $i++) 
    {
        $numofphasefiles = @{$phase_files[$i]};
        catctlPrintMsg(
         "$MSGIDISP1 $i$MSGIDISP2 $phase_type[$i] $MSGIDISP3 $numofphasefiles $MSGIDISP4\n",
         $TRUE,$bLogtoScreen);

        if ($numofphasefiles > 0)
        {
            $x = 0;
            $fldsize = 21;

            for ($j = 0; $j < $numofphasefiles; $j++)
            {
                if ($opt_r)
                {
                    $strsize = length($phase_files_ro[$i][$j]);
                    catctlPrintMsg("$phase_files_ro[$i][$j] ",$TRUE,$bLogtoScreen);
                }
                else
                {
                    $strsize = length($phase_files[$i][$j]);
                    catctlPrintMsg("$phase_files[$i][$j] ",$TRUE,$bLogtoScreen);
                }
                $x++;
                if ($x == 4)
                {
                    catctlPrintMsg("\n",$TRUE,$bLogtoScreen);
                    $x = 0;
                }
                else
                {
                    # Space out fields
                    for ($z = $strsize; $z < $fldsize; $z++)
                    {
                        catctlPrintMsg("$SPACE",$TRUE,$bLogtoScreen);
                    }
                }
            }
            catctlPrintMsg("\n",$TRUE,$bLogtoScreen);
        }
    }

    if($opt_r)
    {
        catctlPrintMsg("\n$MSGIREVERSEODER",$TRUE,$bLogtoScreen);
    }

    #
    # Print the total number of phases
    #
    $numofphasefiles = @phase_type;
    catctlPrintMsg("$TOTAL_PHASES $numofphasefiles\n",$TRUE,$bLogtoScreen);

} # End of catctlDisplayPhases


######################################################################
# 
# catctlLoadPhasesRO - Load Phases in reverse order
#
# Description: Load Reverse order array from phase_files array.
#
# Parameters:
#   - None
######################################################################
sub catctlLoadPhasesRO
{

    my $numofphasefiles = 0;
    my $i = 0;
    my $j = 0;

    for ($i = 0; $i < @phase_type; $i++) 
    {
        $numofphasefiles = @{$phase_files[$i]};
        if ($numofphasefiles > 0)
        {
            for ($j = $numofphasefiles-1; $j >= 0; $j--)
            {
                push(@{$phase_files_ro[$i]}, $phase_files[$i][$j]);
            }
        }
    }

} # End of catctlLoadPhasesRO

######################################################################
# 
# catctlInsertMsgIntoRegistryError - Insert message written
#                                    by catctl.pl into REGISTRY$ERROR
#
# Description: Insert message written to REGSITRY$ERROR with catctl.pl
#              as the scriptname.  We only do this if we see a fatal error
#              like ORA-06000 and nothing has been written to REGISTRY$ERROR
#              to dectect the problem.
#
# Parameters:
#  None
# Return - Status of catconExec
#          0 = Success
#          1 = Failure
#
######################################################################
sub catctlInsertMsgIntoRegistryError
{
    my $pPdb          = $_[0];   # Pdb to invalidate
    my $SqlStmts      = $SETSTATEMENTS;
    my $AlterSession  = 0;       # Alter Session Set Container
    my $WriteRegistry = 0;       # Write to Registry
    my $bFoundContainer = $FALSE;

    #
    # Initialize
    #
    $giRetCode = 0;

    #
    # Make Sure we have log in
    #
    if (!$gbLogon)
    {
        return ($giRetCode);
    }

    #
    # If fatal error then just get out.
    # I don't know if we have a connection
    # to restart the database
    #
    if ($gbFatalError)
    {
        return ($giRetCode);
    }

    #
    # If we found errors in registry$error
    # then we don't need to do anything
    #
    if ($gbRegErrFound)
    {
        return ($giRetCode);
    }

    #
    # If not upgrade return
    #
    if (!$gbUpgrade)
    {
        return($giRetCode);
    }
    
    #
    # Add an entry in the error registry.  Since I don't
    # know where we died I will just add the message to CATPROC.
    #
    $WriteRegistry = 
        "INSERT INTO $ERRORTABLE VALUES ".
        "('SYS', SYSDATE, '$CATCTLPL', 'CATPROC',".
        " 'Invalid Upgrade Check catupgrd*.log',".
        " 'Invalid Upgrade');\n";

    #
    # Alter session on a cdb database
    #
    if ($gbCdbDatabase)
    {
        $AlterSession = 
            "ALTER SESSION SET CONTAINER = \"$pPdb\";\n";
        $SqlStmts = $SqlStmts.$AlterSession;
    }

    $SqlStmts = $SqlStmts.$WriteRegistry;
    $SqlStmts = $SqlStmts.$COMMITCMD;

    #
    # Alter session on a cdb database
    #
    if ($gbCdbDatabase)
    {
        $SqlStmts = $SqlStmts.$CDBSETROOT;
    }

    #
    # Create and Execute Sql File
    #
    $SqlAry[0] = $SqlStmts;
    $giRetCode = catctlExecSqlFile(\@SqlAry,
                                   0,
                                   $gsNoInclusion,
                                   $gsNoExclusion,
                                   $RUNROOTONLY,
                                   $CATCONSERIAL);

    return ($giRetCode);

}

######################################################################
# 
# catctlReadLogFiles - Read Log Files
#
# Description: Read Log Files looking for errors or Pfile.
#
# Parameters:
#   - Upgrade Log File (IN)
#
#   RETURNS 
#     Error Messages
######################################################################
sub catctlReadLogFiles
{
  my $pUpgradeLogFile = $_[0];  # Upgrade Log File
  my @TAGS = ("ORA-03114",      # Not Connected
              "SP2-0640:",      # Not Connected
              "ORA-03113",      # End of Communication
              "ORA-00600",      # Internal Error
              "ORA-01012",      # Not Log in
              "ORA-01034",      # Not Available
              "ORA-01092",      # Instance Teminated
              "ORA-01119",      # Error Creating Database file
              "SP2-1519:",      # Can't write to registry$error
              "ORA-07445");     # Exception Encountered
  my $TAGLEN = 9;
  my $TagIdx = 0;
  my $Tag;
  my $LogFile;
  my $CATCTLERRORTAGLEN = length($CATCTLERRORTAG); # Error Tag Len
  my $CATCTLERRORTAGENDLEN = length($CATCTLERRORTAGEND); # Error Tag End Len
  my $line          = 0;                       # Line of data
  my $LineNo        = 0;                       # Line Number
  my $CompareStr    = 0;                       # Compare String
  my $bFatalError   = $FALSE;                  # Anything in $TAGS
  my $bRegErrFound  = $FALSE;                  # Found Registry Errors
  my $bRegErrSearch = $FALSE;                  # Catctl registry$error search
  my $RetMsg        = "";                      # Return Message

  #
  # Open and Read Upgrade 0 log file.
  #
  $LogFile = $pUpgradeLogFile."0.log";
  $LineNo  = 0;


  #
  # Create Log File if not present
  #
  if (!-e $LogFile)
  {
      open (FileOut, '>', $LogFile);
      close (FileOut);
  }

  #
  # If Log File still not found then just get out
  #
  if (!-e $LogFile)
  {
      print STDERR "$MSGFCATCTLREADLOGFILES $LogFile\n";
      return ($RetMsg);
  }

  open (FileIn, '<', $LogFile);

  #
  # Search for errors in the upgrade.
  #
  while (<FileIn>)
  {
      #
      # Store the line
      #
      $line = $_;
      chomp($line);
      $LineNo++;

      #
      # Get all registry$errors until we find the end tag
      #
      if ($bRegErrSearch)
      {
          #
          # Look for Tag at the beginning of line only
          # We are done processing the errors when we
          # find the end tag so we can fall out of this loop
          #
          if (length($line) > ($CATCTLERRORTAGENDLEN-1))
          {
              $CompareStr = substr($line, 0, $CATCTLERRORTAGENDLEN);
              if ($CompareStr eq $CATCTLERRORTAGEND)
              {
                  $bRegErrSearch = $FALSE;
                  next;
              }
          }

          #
          # Store the errors
          #
          $RetMsg = $RetMsg.$line."\n";
          next;
      }

      #
      # Search for any errors in the Tag Array
      #
      if ((!$bFatalError) && (length($line) > $TAGLEN))
      {
          #
          # Look for Tag at the beginning of line only
          #
          $CompareStr = substr($line, 0, $TAGLEN);
          foreach $Tag (@TAGS)
          {
              if ($CompareStr eq $Tag)
              {
                  $bFatalError = $TRUE;
                  last;
              }
          }

          #
          # Something very bad happened here
          #
          if ($bFatalError)
          {
              $gbErrorFound      = $TRUE;
              $RetMsg            = $RetMsg.
                  "     ERRORS FOUND: During Upgrade \n".
                  "         FILENAME: $LogFile AT LINE NUMBER: $LineNo\n";
              next;
          }
      }

      #
      # Look for Errors found from registry$error unless we have
      # already have them.
      #
      if ((!$bRegErrFound) && (length($line) > $CATCTLERRORTAGLEN)) 
      {
          #
          # Look for Tag at the beginning of line only
          #
          $CompareStr = substr($line, 0, $CATCTLERRORTAGLEN);

          #
          # If we find the catctl error tag
          #
          if ($CompareStr eq $CATCTLERRORTAG)
          {
              $RetMsg            = $RetMsg.
                  "     ERRORS FOUND: During Upgrade \n".
                  "         FILENAME: $LogFile AT LINE NUMBER: $LineNo\n";
              $gbErrorFound  = $TRUE;
              $bRegErrSearch = $TRUE;
              $bRegErrFound  = $TRUE;
              $gbRegErrFound = $TRUE;
          }
      } # end if for registry$error 

  } # End of reading log file

  #
  # Close file
  #
  close (FileIn);

  return ($RetMsg);


} # End of catctlReadLogFiles


######################################################################
# 
# catctlScanSqlFiles - Subroutine to recursive scan through the 
#                      .sql control files
#
# Description: This routines parses the .sql files looking for the
#              --CATCTL and --CATFILE tags.  Placement of these
#              specific tags in .sql files determines how to
#              group the .sql and .plb files.  These groups make
#              up each of the phases.
#
# Parameters:
#   - None
######################################################################
sub catctlScanSqlFiles
{

   # global $gidepth variable tracks recursion of -X scripts
 
   my $path = $_[0];   # first argument is file name
   my $thread;
   my @scripts;        # Sql scripts Array
   my @x;              # Depth Counter Array
   my $i = 0;          # Index

   # open the file to read from and load lines starting with @
   open (FileIn, '<', $path) or catctlDie("$MSGFCATCTLSCANSQLFILES $path: $!");
   @{$scripts[$gidepth]}= grep { /^@/ | /--CAT/ }<FileIn>;
   close (FileIn);

   if ($gbDisplayPhases)
   {
       if ( $#{$scripts[$gidepth]} < 0) {
           catctlPrintMsg("$MSGWNOSCRIPTSFOUND $path\n",$FALSE,$TRUE);
           return;  ## no scripts found
       } else {
           catctlPrintMsg("$#{$scripts[$gidepth]} $MSGWSCRIPTSFOUND $path\n",
                          $FALSE,$TRUE);
       }
   }

   # analyze scripts for control commands and populate control arrays
   for ($x[$gidepth] = 0; $x[$gidepth] < @{$scripts[$gidepth]}; $x[$gidepth]++) 
   {
     $i = $x[$gidepth];
     my $thread = $SINGLE;
     my $new_path;
     my $file;
     my $noofcompile;
     my $dTagIdx = 0;
     my $descStartLen = -1;
     my $descEndLen   = -1;

     #
     # Ignore sqlsessstart.sql and sqlsessend.sql for our driver files.
     # We don't want them involved in the processing of the SQL.
     # ORACLE_SCRIPT is set in our session scripts for these files.
     #
     if (index($scripts[$gidepth][$i], $SESSIONSTARTSQL) != -1 ||
         index($scripts[$gidepth][$i], $SESSIONENDSQL)   != -1)
     {
         next;
     }

     #
     # only @@ scripts or --CATCTL lines can be in catctl files
     #
     if (substr($scripts[$gidepth][$i],0,8) eq "$CATCTLTAG") {
         # new phase
         if ((index($scripts[$gidepth][$i], "$CATCTLMTAG") > 0)  ||
             (index($scripts[$gidepth][$i], "$CATCTLMETAG") > 0) ||
             (index($scripts[$gidepth][$i], "$CATCTLPMETAG") >0))
         {
              $thread = $MULTI;
         }
         else
         {
              $thread = $SINGLE;  # default to Single
         }
         push(@phase_type,$thread);
         push(@phase_files,[]);
         push (@phase_compile, $gbLoadWithComp);
         push (@phase_desc, "");

         #
         # Parse out Phase Description
         #
         $dTagIdx = index($scripts[$gidepth][$i], "$CATCTLDTAG");
         if ($dTagIdx > 0)
         {
             #
             # Parse out the description in the format
             # --CATCTL -M -D "This is the description"
             #
             $descStartLen = $dTagIdx+$CATCTLDTAGLEN;
             $descStartLen = index($scripts[$gidepth][$i], 
                                   $DOUBLEQUOTE, 
                                   $descStartLen);

             if ($descStartLen == -1)
             {
                 $phase_desc[$#phase_type] = $MSGIUNABLETOPARSEDESC;
             }
             else
             {
                 $descStartLen = $descStartLen + 1; # Skip Quote
                 #
                 # Get End Length
                 #
                 $descEndLen = index($scripts[$gidepth][$i],
                                     $DOUBLEQUOTE, 
                                     $descStartLen);
                 if ($descEndLen == -1)
                 {
                     $phase_desc[$#phase_type] = $MSGIUNABLETOPARSEDESC;
                 }
             }

             #
             # Check to make sure we are good to go
             #
             if ($descEndLen != -1)
             {
                 $phase_desc[$#phase_desc] = substr($scripts[$gidepth][$i],
                                               $descStartLen,
                                               ($descEndLen-$descStartLen));
                 $phase_desc[$#phase_desc] = $SPACE.$SPACE.$SPACE.$phase_desc[$#phase_desc].
                                             $SPACE.$SPACE.$SPACE;
             }
         }

         $noofcompile = $#phase_compile;

         #
         # Want to look at the last entry to
         # carry it forward to the next phase
         #
         if ($noofcompile != 0)
         {
             $phase_compile[$noofcompile] = $phase_compile[$noofcompile-1];
         }

         #
         # Start Load without Compile
         #
         if (index($scripts[$gidepth][$i], "$CATCTLCSTAG") > 0) {
             push(@{$phase_files[$#phase_files]}, $LOADCOMPILEOFF);
             $phase_compile[$noofcompile] = $gbLoadWithoutComp;
         }

         #
         # End Load without Compile
         #
         if (index($scripts[$gidepth][$i], "$CATCTLCETAG") > 0) {
             push(@{$phase_files[$#phase_files]}, $LOADCOMPILEON);
             $phase_compile[$noofcompile] = $gbLoadWithComp;
         }

         #
         # Run This file in catctl.pl only. Does not run in catupgrd.sql
         # Format is --CATCTL -SE filename.sql filename.sql ... EOL
         # We execute an -SE tag the same as we execute the -S tag the
         # only difference is that the sql found under this tag is the form of
         # a comment and does not get executed if the script is run at the
         # SQL command prompt.
         #
         catctlScanSilentTags($gbOpenModeNormal,
                              $scripts[$gidepth][$i]);

         # This tells us to restart the sql process
         if (index($scripts[$gidepth][$i], "$CATCTLRESTARTTAG") > 0) {
             push(@{$phase_files[$#phase_files]}, $RESTART);
         }

         # Run the connditional upgrade of the specified component
         if (index($scripts[$gidepth][$i], "$CATCTLCPTAG") > 0) {
             # get component id
             my $idx = index($scripts[$gidepth][$i],"$CATCTLCPTAG")+$CATCTLCPTAGLEN+1;
             my $ctl = index($scripts[$gidepth][$i],"$CATCTLXTAG");
             my $len = $ctl > 0 ? $ctl-$idx-1 : length($scripts[$gidepth][$i])-$idx-1;
             $gsCmp = substr($scripts[$gidepth][$i],$idx,$len);
             # -CP annotations cannot be nested
             if ($gbUseCmpDir) {
                catctlDie("$MSGFANOTHERCMP - $gsCmp");
	     }
             if (catctlGetCmpInfo($gsCmp)) # get comp dir and path
             {
                # Check existence file to be sure component is in the OH
                if (($gsCmpTestFile) && 
                    ((! -e $gsCmpDir.$SLASH.$gsCmpTestFile) ||
                     (! -r $gsCmpDir.$SLASH.$gsCmpTestFile))) {
                        catctlPrintMsg("\n$MSGWCOMPFILENOTEXIST: [$gsCmp] - [$gsCmpTestFile]",
                                       $TRUE, $TRUE);
                } else { 
                   # process component scripts
                   $gbUseCmpDir = $TRUE;
                   $path = $gsCmpDir.$gsCmpFile;
                   if ($ctl > 0) {      # process file as CATCTL file
                     if ($gbDisplayPhases)
                     {
                        catctlPrintMsg("$MSGWNEXTPATH $path\n",$FALSE,$TRUE);
                     }
                     # Set Component Session File
                     push (@session_files,$giUseDir ?  "@".$gSrcDir.$SLASH.$gsCmpSesFile : 
                                 "@".$gsCmpSesFile);
                     push (@session_start_phase, $#phase_type); # Set Start Phase
                     # recursively scan files
                     $gidepth++;
                     catctlScanSqlFiles($path);
                     $gidepth--;
                     push(@session_stop_phase,$#phase_type); # set stop phase
                   } else {   # just add file to list of files with full path name and tag
                     push(@{$phase_files[$#phase_files]}, 
                            "$CATCTLCPTAG".$gsCmp."$CATCTLATTAG".$path);
                   } # end path processing
                   # no longer use directory
                   $gbUseCmpDir = $FALSE;   # reset for next component
                } # end check test file existence
             } else {   # component not in supported list
                catctlPrintMsg("\n$MSGWCOMPNOTPROCESSED: $gsCmp",$TRUE, $TRUE);
             } # end supported component
	   } # end -CP tag
        
     } else {
        # new script
        if (substr($scripts[$gidepth][$i],0,2) eq "$CATCTLATATTAG") {
           # process script
           my $ctl = index($scripts[$gidepth][$i],"$CATCTLCATFILETAG");
           my $idx = index($scripts[$gidepth][$i]," ");
           $idx = $idx > 0 ? $idx : index($scripts[$gidepth][$i],"\n");
           $file = substr($scripts[$gidepth][$i],2,$idx-2);

           # add .sql if no suffix
           $idx = index($scripts[$gidepth][$i],".");
           $file = $idx > 0 ? $file : $file . "$SQLEXTNTAG";

           # add component directory
           $file = $gbUseCmpDir ? $gsCmpDir.$file : $file;  

           if ($ctl > 0)
           {
              # Only process -X files, -I files are ignored
              if (index($scripts[$gidepth][$i], "$CATCTLXTAG", $ctl) > 0) {
         	  if ($gbUseCmpDir) {  # directory already appended for component script
                     $new_path = $file;
		  } else {
                     $new_path = $giUseDir ? $gSrcDir.$SLASH.$file : $file;  
                  }
                  if ($gbDisplayPhases)
                  {
                      catctlPrintMsg("$MSGWNEXTPATH $new_path\n",$FALSE,$TRUE);
                  }
                  $gidepth++;
                  catctlScanSqlFiles($new_path);
                  $gidepth--;
              }

              # Process Session Files
              # This function modify the start and stop phases according to 
              # the tags used in catupgrd.sql
              catctlScanSessionFiles($scripts[$gidepth][$i],$file);


           } else {  # add file to array of files for current phase
              # store script to run
              if ($gbUseCmpDir) {
                 push(@{$phase_files[$#phase_files]}, 
                       "$CATCTLCPTAG".$gsCmp."$CATCTLATTAG".$file);   
              } else {
                 push(@{$phase_files[$#phase_files]}, "$CATCTLATTAG".$file);   
	      }
	    }
           } else {  # not @@ or --CATCTL
              catctlPrintMsg(
               "$MSGWLINENOTPROCESSED $scripts[$gidepth][$i]\n",
               $FALSE,$TRUE);
	 }
     }  # end of line check
   }  # end of for loop
}  # End of catctlScanSqlFiles

######################################################################
# 
# catctlScanSilentTags - Subroutine to process silent commands
#
# Description: This routines parses the .sql files looking for the
#              --CATCTL silent commands ie -SE and -ME commands
#              Silent tags are run just like normal -S and -M tags
#              except they don't run in catupgrd.sql.
#
# Parameters:
#   - INPUT
#       $pbOpenModeNormal = Leave Database Open Flag
#       $pScript          = Script command line
######################################################################
sub catctlScanSilentTags
{
    my $pbOpenModeNormal = $_[0];  # Leave Database Open Flag
    my $pScript          = $_[1];  # Script line --CATCTL -PSE @catuppst.sql EOL
    my $Tag       = "";
    my $Files     = "";
    my $File      = "";
    my $idx       = 0;
    my $TagType   = 0;
    my $TagName   = "";
    my $SETAG     = 1;
    my $METAG     = 2;
    my $PSETAG    = 3;
    my $PMETAG    = 4;

    #
    #  Look for tags
    #
    $TagType = $PSETAG;
    $TagName = $CATCTLPSETAG;
    $idx     = index($pScript, "$TagName");

    if ($idx == -1)
    {
        $TagType = $SETAG;
        $TagName = $CATCTLSETAG;
        $idx     = index($pScript, "$TagName");
    }
    if ($idx == -1)
    {
        $TagType = $METAG;
        $TagName = $CATCTLMETAG;
        $idx     = index($pScript, "$TagName");
    }
    if ($idx == -1)
    {
        $TagType = $PMETAG;
        $TagName = $CATCTLPMETAG;
        $idx = index($pScript, "$TagName");
    }

    #
    # Tags not found get out
    #
    if ($idx == -1)
    {
        return;
    }

    #
    # Set the tag info
    #
    $Tag = $CATCTLTAG." ".$TagName." ";

    # Skip tag info and parse out first file
    $Files = substr($pScript, length($Tag));
    $idx   = index($Files, " ");
    $File  = substr($Files, 0, $idx);

    #
    # While not at end of line add files into phase
    #
    while ($File ne $EOLTAG)
    {
        #
        # Don't shutdown the database if open mode is normal
        # Only done after post upgrade has run.
        #
        if (($pbOpenModeNormal) && 
            (($File eq $SHUTDOWNPDBJOB) ||
             ($File eq $SHUTDOWNJOB)))
        {
            $File = $NOTHINGJOB;
        }
        #
        # Add File to the phase
        #
        push(@{$phase_files[$#phase_files]}, $File);
        #
        # Move to the next file
        #
        $Files = substr($Files, $idx+1);
        $idx   = index($Files, " ");
        $File  = substr($Files, 0, $idx);
    }
}



######################################################################
# 
# catctlPostUpgrade - Call post upgrade routine
#
# Description:
#   This subroutine calls the startup database routine
#
#
# Parameters:
#   - Inclusion list (IN)
#   - Exclusion list (IN)
#   - Open Database Mode (IN)
#   - Open Database in upgrade Mode (IN) -M
#       If root is opened in Upgrade Mode the everything needs to
#       opened in upgrade mode.
#   - Errors Found (IN)
#       Current Not Used. 
######################################################################
sub catctlPostUpgrade {

    my $pInclusion    = $_[0];   # Inclusion List for Containers
    my $pExclusion    = $_[1];   # Exclusion List for Containers
    my $pDBOpenMode   = $_[2];   # Open Database Mode
    my $pbUpgradeMode = $_[3];   # Open Database in upgrade mode -M
    my $pbErrorFound  = $_[4];   # Errors Found

    #
    # Return if emulating
    #
    if ($gbEmulate)
    {
        return;
    }

    #
    # Startup the database, Override Error Found Flag and set to FALSE
    # We will bring up the database in normal mode to do the post
    # upgrade.  At the Very End of the upgrade we will restart the
    # database in upgrade mode if there were errors.
    #
    if ($gbCdbDatabase && !$pInclusion) {
      catctlPrintMsg("Operating on a CDB, but pInclusion was not ".
                     "set\n", $TRUE, $FALSE);
    }

    catctlStartDatabase($pInclusion,
                        $pExclusion,
                        $pDBOpenMode,
                        $pbUpgradeMode,
                        $FALSE);

} # end catctlPostUpgrade


######################################################################
# 
# catctlCreateSqlFile - Create Sql File
#
# Description:
#   This subroutine create a Random Sql File given with the contents
#   of pSql.
#
#
# Parameters:
#   pSql - Sql to write to file (IN)
#   pFileName - Sql Filename to Append (IN)
#   Returns Sql File Name
######################################################################
sub catctlCreateSqlFile {

    my $pSql = $_[0];      # Sql to write to file
    my $pFileName = $_[1]; # Filename to append
    my $RandomNo = rand();
    my $RetFileName = $gsSpoolLog.$giProcess.$RandomNo.".sql"; # Ret Filename
    my $TmpFh = 0;

    #
    # Use Filename to create Temp file
    #
    if ($pFileName)
    {
        $RetFileName = $gsSpoolLog.$pFileName.$giProcess.$RandomNo.".sql";
    }

    #
    # Create File in the Spool Directory
    #
    $RetFileName = $gsSpoolDir.$SLASH.$RetFileName;

    #
    # Create Sql File
    #
    $TmpFh = open (FileOut, '>', $RetFileName) or 
                catctlDie("$MSGFCATCTLCREATESQLFILE - $RetFileName $!");

    #
    # Output to Temp File
    #
    print FileOut "$pSql";

    #
    # Close the Temp File
    #
    close(FileOut);

    return $RetFileName;
  

} # end catctlCreateSqlFile

######################################################################
# 
# catctlLogErrors - Log Errors
#
# Description:
#   This subroutine logs errors found in the upgrade at the time
#   it was called.
#
#
# Parameters:
#   - Inclusion List for Containers (IN)
#   - Exclusion List for Containers (IN)
#   - SQL identifier (IN)
#   - Error Log File (IN)
######################################################################
sub catctlLogErrors {

    my $pInclusion      = $_[0];  # Inclusion List for Containers
    my $pExclusion      = $_[1];  # Exclusion List for Containers
    my $pSqlIdentifier  = $_[2];  # SQL Identifier
    my $SqlCmd = "";

    #
    # Check to see if we need to log errors
    #
    if ($gbLogErrors)
    {
        return;
    }
    $gbLogErrors = $TRUE;

    #
    # Run everywhere
    #    
    $SqlCmd = "set linesize 5000;\nset serveroutput on;\nset echo off;\n";
    $SqlCmd = $SqlCmd.$CATCONDSPTAG;
    $SqlCmd = $SqlCmd."declare\n";
    $SqlCmd = $SqlCmd."cnt         NUMBER:=0;\n";
    $SqlCmd = $SqlCmd."begin sys.dbms_output.put_line ('$BANNERTAG');\n";
    #
    # Check for errors
    #
    $SqlCmd = $SqlCmd.$gsSelectErrors;
    $SqlCmd = $SqlCmd."if cnt > 0 then sys.dbms_output.put_line ";
    $SqlCmd = $SqlCmd."('$CATCTLERRORTAG' || cnt);\n";
    $SqlCmd = $SqlCmd."for i in (select identifier,message,statement,timestamp,script ";
    $SqlCmd = $SqlCmd."from $ERRORTABLE order by timestamp)\n loop\n";
    $SqlCmd = $SqlCmd."sys.dbms_output.put_line ('$LINETAG');\n";
    $SqlCmd = $SqlCmd.
        "sys.dbms_output.put_line('Identifier ' || substr(i.identifier,1,10)
                                  || ' ' || 
                                  to_char(i.timestamp,'YY-MM-DD HH:MI:SS'));\n";
    $SqlCmd = $SqlCmd.
        "sys.dbms_output.put_line('SCRIPT    = [' || i.script || ']');\n";
    $SqlCmd = $SqlCmd.
        "sys.dbms_output.put_line('ERROR     = [' || i.message || ']');\n";
    $SqlCmd = $SqlCmd.
        "sys.dbms_output.put_line('STATEMENT = [' || i.statement || ']');\n";
    $SqlCmd = $SqlCmd."sys.dbms_output.put_line ('$LINETAG');\nend loop;\n";
    $SqlCmd = $SqlCmd."sys.dbms_output.put_line('$CATCTLERRORTAGEND ERRORS');\n";
    $SqlCmd = $SqlCmd."else\n";
    $SqlCmd = $SqlCmd."sys.dbms_output.put_line('NO ERRORS IN $ERRORTABLE');\n";
    $SqlCmd = $SqlCmd."end if;\n";
    $SqlCmd = $SqlCmd."sys.dbms_output.put_line ('$BANNERTAG');\n";
    $SqlCmd = $SqlCmd."end;";
    $SqlCmd = $SqlCmd.$SQLTERM;
    $SqlCmd = $SqlCmd."set serveroutput off;\nset echo on";


    #
    # Create and Execute Sql File
    #
    $SqlAry[0] = $SqlCmd;
    $giRetCode = catctlExecSqlFile(\@SqlAry,
                                   0,
                                   $pInclusion,
                                   $pExclusion,
                                   $RUNEVERYWHERE,
                                   $CATCONSERIAL);

    #
    # Check Return Code
    #
    if ($giRetCode)
    {
        catctlDie("$MSGFCATCONEXEC $!");
    }
}

######################################################################
# 
# catctlCreatePFile - Create database pfile
#
# Description:
#   This subroutine create the database pfile from memory using SQL and
#   writes the status to the spool log.
#
#
# Parameters:
#   - None
######################################################################
sub catctlCreatePFile {

    my $PfileCmd = "";


    #
    # Return if emulating
    #
    if ($gbEmulate)
    {
        return;
    }

    #
    # Just get out if this is an pdb instance
    #
    if ($gbInstance)
    {
        return;
    }

    #
    # Generated Pfile Name
    #
    $gspFileName = $gsSpoolLogDir."_".
        catctlGetDateTime(1)."_".$$.".ora";

    #
    # Problem ORA-65040 operation not allowed in a plugable database.
    # Because we commented out in Andre's code.  Run in Root Only
    #
    #
    # Alter session on a cdb database
    #
    if ($gbCdbDatabase)
    {
        $PfileCmd = $CDBSETROOT;
    }

    #
    # Create Pfile
    #
    $PfileCmd = $PfileCmd."DOC\n".
                "#####################################################\n".
                "#####################################################\n\n".
                "    CREATING PFILE\n\n".
                "#####################################################\n".
                "#####################################################\n".
                "#\n";

    $PfileCmd = $PfileCmd.
        "CREATE PFILE = '$gspFileName' FROM MEMORY;\n";

    #
    # Create and Execute Sql File
    #
    $SqlAry[0] = $PfileCmd;
    $giRetCode = catctlExecSqlFile(\@SqlAry,
                                   0,
                                   $gsNoInclusion,
                                   $gsNoExclusion,
                                   $RUNROOTONLY,
                                   $CATCONSERIAL);
    #
    # Check Return Code
    #
    if ($giRetCode)
    {
        catctlDie("$MSGFCATCONEXEC $!");
    }

    #
    # Found it we are good to go
    #
    if (-e $gspFileName)
    {
        $gbFoundPfile = $TRUE;
        push (@files_to_delete, $gspFileName);
    }
    else
    {
        $gsPostUpgMsg    = $gsPostUpgMsg.$MSGFCANFINDPFILE;
        $gbErrorFound    = $TRUE;
    }

    $gbCreatePfile = $TRUE;

} # end catctlCreatePFile

######################################################################
# 
# catctlReStartDatabase - ReStart the Database in upgrade mode 
#
# Description:
#   This subroutine will restart the database in upgrade
#   mode if there was an error.
#
# Parameters:
#   - Error flag (IN)
#   - Cdb database flag (IN)
#   - Root processing flag (IN)
#   - Pdb processing flag (IN)
#   - Seed processing flag (IN)
#   - Upgrade Mode (IN)
######################################################################
sub catctlReStartDatabase {

    my $pbErrorFound        = $_[0];  # Error Flag
    my $pbCdbDatabase       = $_[1];  # Cdb Database
    my $pbRootProcessing    = $_[2];  # Root processing
    my $pbInstance          = $_[3];  # Pdb processing
    my $psRTInclusion       = $_[4];  # Include Pdb Name
    my $pbSeedProcessing    = $_[5];  # Seed Processing
    my $pbUpgradeMode       = $_[6];  # Upgrade Mode (-M)
    my $PdbItem;                      # Pdb Item

    #
    # Make Sure we have log in
    #
    if (!$gbLogon)
    {
        return;
    }

    #
    # If fatal error then just get out.
    # I don't know if we have a connection
    # to restart the database
    #
    if ($gbFatalError)
    {
        return;
    }

    #
    # If not upgrade return
    #
    if (!$gbUpgrade)
    {
        return($giRetCode);
    }

    #
    # No Errors 
    #
    if (!$pbErrorFound)
    {
        #
        # Bring up the PDB$SEED database in read only mode
        #
        if (($pbInstance)    &&
            ($pbSeedProcessing))
        {
            catctlStartDatabase($PDBSEED,
                                $gsNoExclusion,
                                $DBOPENROSEED,
                                $pbUpgradeMode,
                                $pbErrorFound);
        }
        return;
    }


    #
    # If errors are found re-open the database in upgrade mode
    #
    if ($pbCdbDatabase)
    {
        if ($pbInstance)
        {
            #
            # Open the pdb container in upgrade mode
            #
            if (!$psRTInclusion) {
              catctlPrintMsg("Operating on a CDB, but psRTInclusion was not ".
                             "set\n", $TRUE, $FALSE);
            }

            catctlStartDatabase($psRTInclusion,
                                $gsNoExclusion,
                                $DBOPENUPGPDB,
                                $pbUpgradeMode,
                                $pbErrorFound);

            #
            # Add message to the registry$error to signal something when wrong
            #
            $giRetCode = catctlInsertMsgIntoRegistryError($psRTInclusion);
        }
        else
        {

            #
            # Shutdown Root database and then restart
            # By default we only shutdown the root database
            # once.
            #
            $giRetCode = catconUpgEndSessions();
            catctlShutDownDatabase($SHUTDOWNJOB,
                                   $RUNROOTONLY,
                                   $gsNoInclusion,
                                   $gsNoExclusion);

            #
            # Open the Root in upgrade mode
            #
            catctlStartDatabase($CDBROOT,
                                $gsNoExclusion,
                                $DBOPENNORMAL,
                                $pbUpgradeMode,
                                $pbErrorFound);

            #
            # Add message to the registry$error to signal something when wrong
            #
            $giRetCode = catctlInsertMsgIntoRegistryError($CDBROOT);

            #
            # Open the PDB's back up upgrade mode
            #
            foreach $PdbItem (@AryPDBInstanceList)
            {
                if (!$PdbItem) {
                  catctlPrintMsg("Operating on a CDB, but PdbItem was not ".
                                 "set\n", $TRUE, $FALSE);
                }

                catctlStartDatabase($PdbItem,
                                    $gsNoExclusion,
                                    $DBOPENUPGPDB,
                                    $pbUpgradeMode,
                                    $pbErrorFound);
            }
        }
    }
    else
    {
        #
        # Open Traditional database in upgrade mode
        #
        catctlStartDatabase($gsNoInclusion,
                            $gsNoExclusion,
                            $DBOPENNORMAL,
                            $pbUpgradeMode,
                            $pbErrorFound);
        #
        # Add message to the registry$error to signal something when wrong
        #
        $giRetCode = catctlInsertMsgIntoRegistryError($gsNoInclusion);
    }


} #end of catctlReStartDatabase

######################################################################
# 
# catctlStartDatabase - Start the Database 
#
# Description:
#   This subroutine starts up the database given a pfile.
#   By default the database is open in normal mode with
#   restricted access.  If the open flag is set the database
#   is opened in normal mode without the restricted access.
#
# Parameters:
#   - Inclusion list (IN)
#   - Exclusion list (IN)
#   - Open Database Mode (IN)
#   - Open Database in upgrade Mode Flag (IN) -M
#       If root is opened in Upgrade Mode the everything needs to
#       opened in upgrade mode.
#   - Errors Found Flag (IN)
#       If Errors found in Upgrade then open everything in upgrade Mode.
#
######################################################################
sub catctlStartDatabase {

    my $pInclusion     = $_[0];   # Inclusion List for Containers
    my $pExclusion     = $_[1];   # Exclusion List for Containers
    my $pDBOpenMode    = $_[2];   # Open Database Mode
    my $pbUpgradeMode  = $_[3];   # Open Container in Upgrade Mode (-M)
    my $pbErrorFound   = $_[4];   # Errors Found Flag
    my $OpenCommand    = "";
    my $PlugCommand    = "";
    my $PlugCommand2   = "";
    my $sInclusion     = $gsNoInclusion;  # Default no Inclusion List
    my $sExclusion     = $gsNoExclusion;  # Default no Inclusion List
    my $runwhere       = $RUNROOTONLY;    # Default Run Root Only
    my $bDBRestarted   = $TRUE;           # Assume True
    my $x = 0;
    my $CLOSESEEDPDB = "begin execute immediate 'alter pluggable ".
        "database $PDBSEED close immediate instances=all';\n".
        "exception when others then if sqlcode = -65020 then null;\n".
        "else raise; end if; end;";       # Close PDB SEED
    my $CLOSEPDB1 = "begin execute immediate ".
        "'alter pluggable database ";     # Close PDB Part 1
    my $CLOSEPDB2 = " close immediate instances=all';\n".
        "exception when others then if sqlcode = -65020 then null;\n".
        "else raise; end if; end;";       # Close PDB Part 2
    my $CLOSEPDB = $CLOSEPDB1.$CLOSEPDB2; # Close PDB
    my $OPENUPGPDB1 = "begin execute immediate ".
        "'alter pluggable database ";     # Open Upgrade Part 1
    my $OPENUPGPDB2 = " open upgrade';\n".
          "exception when others then ".
          "if sqlcode = -65019 or sqlcode = -24344 then null;\n".
          "else raise; end if;\n end;";  # Open Upgrade Part 2

    # App Roots get upgraded before App Root Clones and App PDBs, which means 
    # that they need to be open in UPGRADE mode after their post-upgrade 
    # phase (so that App Root Clones and App PDBs can be upgraded) and the 
    # App PDBs need to be reopened in UPGRADE mode after App Root gets closed 
    # and reopened for UPGRADE
    my $OPEN_APP_PDBS_UPG = "alter pluggable database %s open upgrade";

    #
    # Return if emulating
    #
    if ($gbEmulate)
    {
        return;
    }

    #
    # Close all session except one
    #
    $giRetCode = catconUpgEndSessions();

    # if upgrading a CDB and $pInclusion is set, we need to process one PDB 
    # at a time
    
    # will be populated with names of PDB found in $pInclusion if upgrading 
    # a CDB and $pInclusion is set
    my @pdbs;

    # if upgrading a CDB and $pInclusion is set, will contain name of the PDB 
    # being processed
    my $pdb;

    if ($gbCdbDatabase && $pInclusion) {
      @pdbs = split(' ', $pInclusion);
      $pdb = shift @pdbs;
    } else {
      @pdbs = ();
      $pdb = $pInclusion;
    }

    # if upgrading a CDB and $pInclusion is set, having processed PDB $pdb, 
    # we will shift the next element of @pdbs into $pdb and jump to this label
PROC_NEXT_PDB:

    # Bug 26527096:
    # if asked to close and reopen a PDB, we need to determine if the PDB is 
    # an 
    # - App Root Clone, in which case it cannot be closed or opened (but 
    #   its App Root, from which it inherits the mode in which it is open, is 
    #   expected to be open in the correct mode) or
    # - App Root or App PDB, in which case we need to open it for UPGRADE 
    #   instead of RW [RESTRICTED].
    #
    #   We are doing it to App Roots to accommodate performing 
    #   upgrade on App Root Clones (which cannot be opened independently but 
    #   are open in the same mode as their App Roots) and App PDBs
    #   which happen after App Root has been upgraded.  Having done 
    #   it to App Roots, we have little choice but to also do it to 
    #   App PDBs
    my $appRootClone = $FALSE;
    my $appRoot = $FALSE;
    my $appPdb = $FALSE;

    #
    # Open Mode Normal or Restricted (or UPGRADE, as described above)
    #
    if ($gbCdbDatabase)
    {
        #
        # Start Root database in upgrade mode or normal mode.
        # If there are errors restart in upgrade mode. Database
        # will not be shutdown if errors are present.
        #
        if (($pbUpgradeMode) || ($pbErrorFound))
        {
            $OpenCommand  = "startup upgrade pfile=$gspFileName;\n";
            $gbRootOpenInUpgMode = $TRUE;
        }
        else
        {
            $OpenCommand  = "startup pfile=$gspFileName;\n";
        }

        if ($pdb) {
          # Bug 26527096: determine if the PDB is an App Root, App Root Clone 
          #   or App PDB
          my $pdbType = catconPdbType($pdb);
          
          if (! defined $pdbType) {
            catctlDie("$MSGFCATCONPDBTYPE $!");
          }
          
          if ($pdbType == catcon::CATCON_PDB_TYPE_APP_ROOT_CLONE) {
            # remember that the current PDB is an App Root Clone
            $appRootClone = $TRUE;
          } elsif ($pdbType == catcon::CATCON_PDB_TYPE_APP_ROOT) {
            $appRoot = $TRUE;
          } elsif ($pdbType == catcon::CATCON_PDB_TYPE_APP_PDB) {
            $appPdb = $TRUE;
          }
        } else {
          catctlPrintMsg("pInclusion was not set\n", $TRUE, $FALSE);
        }

        #
        # Pdb Processing
        #
        if ($appRootClone) {
          # do not close/open App Root Clones
          catctlPrintMsg("PDB $pdb is an App Root Clone which ".
                         "cannot be closed or opened\n", $TRUE, $FALSE);
        } elsif ($appPdb) {
            my $msg = "PDB $pdb is an App PDB and needs to be open ".
              "for UPGRADE\n";
            catctlPrintMsg($msg, $TRUE, $FALSE);

            $PlugCommand2 = 
              $CLOSEPDB.$SQLTERM.
              "alter pluggable database open upgrade".$SQLTERM;
        } elsif ($appRoot) {
            # in addition to opening the App Root for UPGRADE, we need to 
            # reopen for UPGRADE any of its App PDBs which were open before 
            # we bounced the App Root since they will be upgraded after 
            # App Root post-upgrade is completed and are expected to be 
            # opened for UPGRADE

            # a query (which will be run from the App Root) to obtain names of 
            # App PDBs belonging to the App Root which are currently open
            my $findOpenAppPdbsQuery = 
              "select app_pdbs.pdb_name ".
                "from sys.dba_pdbs app_pdbs, sys.dba_pdbs app_root, ".
                "     sys.v\$pdbs pdbs ".
               "where app_root.pdb_name = '".$pdb."' ".
                 "and app_pdbs.application_root_con_id = app_root.pdb_id ".
                 "and app_pdbs.application_clone = 'NO' ".
                 "and app_pdbs.pdb_id = pdbs.con_id ".
                 "and pdbs.open_mode != 'MOUNTED'";

            my $msg = "PDB $pdb is an App Root and it ";

            my @appPdbs = catctlAryQuery($findOpenAppPdbsQuery, undef);

            if (@appPdbs) {
              my $appPdbList = join(',', @appPdbs);

              $PlugCommand2 = 
                $CLOSEPDB.$SQLTERM.
                "alter pluggable database open upgrade".$SQLTERM.
                sprintf($OPEN_APP_PDBS_UPG, $appPdbList).$SQLTERM;

              $msg .= "and its App PDBs which are currently open ".
                "($appPdbList) need ";
            } else {
              $PlugCommand2 = 
                $CLOSEPDB.$SQLTERM.
                "alter pluggable database open upgrade".$SQLTERM;

              $msg .= "needs ";
            }

            $msg .= "to be reopened for UPGRADE\n";

            catctlPrintMsg($msg, $TRUE, $FALSE);
        } elsif ($gbOpenModeNormal) {
          catctlPrintMsg("PDB $pdb is a regular PDB and will be ".
                         "open RW\n", $TRUE, $FALSE);
          $PlugCommand2 = 
            $CLOSEPDB.$SQLTERM."alter pluggable database open;\n";
        }
        else
        {
            catctlPrintMsg("Container $pdb is a regular PDB and will ".
                           "be open RW restricted because restricted mode ".
                           "was requested\n", $TRUE, $FALSE);
            $PlugCommand2 = 
              $CLOSEPDB.$SQLTERM."alter pluggable database open restricted;\n";
        }

        #
        # If Root opened in upgrade mode then everybody
        # else must be opened in upgrade mode.
        # If there are errors restart in upgrade mode. Pdb
        # will not be shutdown if errors are present.
        #
        if ((($gbRootOpenInUpgMode) || ($pbErrorFound)) && !$appRootClone)
        {
            $PlugCommand2 = $CLOSEPDB.$SQLTERM.
              "alter pluggable database open upgrade;\n";
        }

        #
        # Seed Processing
        #
        # NOTE: $gbSeedProcessing will be set if PDB$SEED is one of PDBs 
        #       passed to a catctl thread.  If catcon is using a single 
        #       instance to run scripts, each thread will be handed a single 
        #       PDB to process, and this flag accurately indicates whether 
        #       the current thread is handling PDB$SEED.  However, if catcon 
        #       will be using muiltiple instances, a thread will be asked to 
        #       handle multiple PDBs, and $gbSeedProcessing will be set if 
        #       one of them is PDB$SEED, which makes it neccessary to check 
        #       whether the current PDB is, in fact, PDB$SEED before running 
        #       code applicable to PDB$SEED
        if ($gbSeedProcessing && $pdb eq $PDBSEEDTAG)
        {
            #
            # Open Read write or Upgrade
            # If there are errors restart in upgrade mode. Seed
            # will not be shutdown if errors are present.
            #
            if (($gbRootOpenInUpgMode) || ($pbErrorFound))
            {
                $PlugCommand2  = 
                  $CLOSESEEDPDB.$SQLTERM.
                  "alter pluggable database $PDBSEED open upgrade;\n";
            }
            else
            {
                $PlugCommand2  = 
                  $CLOSESEEDPDB.$SQLTERM.
                  "alter pluggable database $PDBSEED open read write restricted;\n";
            }
        }
    }
    else
    {
        #
        # Startup in upgrade,normal or restricted mode
        # If there are errors restart in upgrade mode. Database
        # will not be shutdown if errors are present.
        #
        if ($pbErrorFound)
        {
            $OpenCommand  = "startup upgrade pfile=$gspFileName;\n";
        }
        else
        {
            if ($gbOpenModeNormal)
            {
                $OpenCommand  = "startup pfile=$gspFileName;\n";
            }
            else
            {
                $OpenCommand  = "startup restrict pfile=$gspFileName;\n";
            }
        }
    }

    #
    # Don't startup the database in a CDB if we are not
    # processing the root.  We didn't shut it down.
    #
    if (($gbCdbDatabase) && 
        (!$gbSavRootProcessing) && 
        ($pDBOpenMode == $DBOPENNORMAL))
    {
        $OpenCommand  = "";
        $PlugCommand  = $PlugCommand2;   # Startup PDB's for Post Upgrade
        $bDBRestarted = $FALSE;          # DataBase Not Restarted
        $sInclusion   = $pdb;     # Inclusion List
        $sExclusion   = $pExclusion;     # Exclusion List
        $runwhere     = $RUNEVERYWHERE;  # Run Everywhere
    }

    #
    # Root already started in normal mode 
    # Open Seed database in read only mode
    #
    if (($gbCdbDatabase) &&
	($pDBOpenMode == $DBOPENROSEED))
    {
        #
        # Close any instances on the seed
        # and reopen read only
        #
        $OpenCommand  = "";
        $PlugCommand  = $CLOSESEEDPDB.$SQLTERM."alter pluggable database $PDBSEED ".
                        "open read only instances=all;\n";

        #
        # If Root opened in upgrade mode then everybody
        # else must be opened in upgrade mode
        # If there are errors restart in upgrade mode. Database
        # will not be shutdown if errors are present.
        #
        if (($gbRootOpenInUpgMode) || ($pbErrorFound))
        {
            $PlugCommand = $CLOSESEEDPDB.$SQLTERM.
                "alter pluggable database open upgrade;\n";
        }

        $bDBRestarted = $FALSE;          # DataBase Not Restarted
        $sInclusion   = $pdb;     # Inclusion List
        $sExclusion   = $pExclusion;     # Exclusion List
        $runwhere     = $RUNEVERYWHERE;  # Run Everywhere 
    }

    #
    # Root already started in normal mode
    # Startup the PDB in Upgrade Mode ignore
    # PDB already open messages. If already
    # in upgrade mode then do nothing.
    # Ignore ORA-24344 if the PDB is opened
    # with warnings.
    #
    if (($gbCdbDatabase) && 
        ($pDBOpenMode == $DBOPENUPGPDB))
    {
        #
        # Create the commands to do the Pdb upgrade open
        #
        $OpenCommand  = "";
        
        if ($appRootClone) {
          catctlPrintMsg("PDB $pdb is an App Root Clone which ".
                         "cannot be closed or opened\n", $TRUE, $FALSE);

          $PlugCommand = "";
        } else {
          $PlugCommand  = "ALTER SESSION SET CONTAINER = \"$pdb\";\n".
              "DECLARE\n stat VARCHAR2(30) := '';\n".
              "BEGIN\n select status into stat from v\$instance;\n".
              "  IF (stat != '$UPGRADEMODE') AND (stat != 'MOUNTED') THEN\n".
              "    ".$CLOSEPDB1.$pdb.$CLOSEPDB2.
              "  END IF;\n".
              "  IF stat != '$UPGRADEMODE' THEN\n".
              "    ".$OPENUPGPDB1.$pdb.$OPENUPGPDB2.
              "  END IF;\n END;\n".$SQLTERM;
        }
        $bDBRestarted = $FALSE;          # DataBase Not Restarted
        $sInclusion   = $pdb;     # Inclusion List
        $sExclusion   = $gsNoExclusion;  # No Exclusion List
        $runwhere     = $RUNEVERYWHERE;  # Run Everywhere
    }

    #
    # Open Database and PDB's
    #
    if ($gbCdbDatabase)
    {
        #
        # Only set oracle script if
        # we are not restarting the
        # database
        #
        if ($bDBRestarted)
        {
            $OpenCommand = $OpenCommand.$PlugCommand;
        }
        else
        {   
          # prepend $ORCLSCIPTTRUE.$SETSTATEMENTS to $OpenCommand.$PlugCommand 
          # only if a least one of $OpenCommand or $PlugCommand is non-empty
          if ($OpenCommand || $PlugCommand) {
            $OpenCommand = $ORCLSCIPTTRUE.$SETSTATEMENTS.
                           $OpenCommand.$PlugCommand;
          }
        }
    }

    #
    # Create and Execute Sql File if there are any statements to execute
    #
    if ($OpenCommand) {
      $SqlAry[0] = $OpenCommand;
      # clearing upgrade flag when invoking the PDB Open script
      catconUpgrade(0);
      $giRetCode = catctlExecSqlFile(\@SqlAry,
                                     0,
                                     $sInclusion,
                                     $sExclusion,
                                     $runwhere,
                                     $CATCONSERIAL);
      # setting upgrade flag after invoking the PDB Open script
      catconUpgrade(1);

      if ($giRetCode)
      {
        catctlDie("$MSGFCATCONEXEC $!");
      }
    }

    if (@pdbs) {
      # if there are more PDBs to process, shift the next PDB off @pdbs and 
      # go back to PROC_NEXT_PDB
      $pdb = shift @pdbs;
      goto PROC_NEXT_PDB;
    }

    #
    # Restart and Bounce the Sessions
    #
    $giRetCode = catconUpgStartSessions($giProcess,0,
                                        undef,undef,$gbDebugCatcon);
    if ($giRetCode)
    {
        catctlDie("$MSGFCATCONUPGSTARTSES $!");
    }
    $giRetCode = catconBounceProcesses();
    if ($giRetCode)
    {
        catctlDie("$MSGFCATCONBOUNCEPROCESSES $!");
    }

} # end catctlStartDatabase

######################################################################
# 
# catctlShutDownDatabase - ShutDown the Database
#
# Description:
#   Shutdown the database
#
# Parameters:
#   pSqlScript   - Sql Shutdown Script to Run
#   pWhereToRun  - Flag to Run in Root or everywhere
#   pInclusion   = (IN) Inclusion List for Containers
#   pExclusion   = (IN) Exclusion List for Containers
######################################################################
sub catctlShutDownDatabase {

    my $pSqlScript   = $_[0];  # Sql Script to run
    my $pWhereToRun  = $_[1];  # Run in Root Only or EveryWhere
    my $pInclusion   = $_[2];  # Inclusion List for Containers
    my $pExclusion   = $_[3];  # Exclusion List for Containers

    #
    # Return if emulating
    #
    if ($gbEmulate)
    {
        return;
    }

    #
    # Guarantee Process complete before
    # we shutdown the database
    #
    $giRetCode = catconBounceProcesses();
    if ($giRetCode)
    {
        catctlDie("$MSGFCATCONBOUNCEPROCESSES $!");
    }

    #
    # Flush out left over processors
    #
    $SqlAry[0] = $NOTHINGJOB;
    $giRetCode =
        catconExec(@SqlAry, 
                   $CATCONSERIAL,   # run single-threaded
                   $pWhereToRun,    # Where to run command
                   0, # Don't issue process init/completion statements
                   $pInclusion,     # Inclusion list 
                   $pExclusion,     # Exclusion List
                   $gsNoIdentifier, # No SQL Identifier
                   $gsNoQuery);     # No Query

    if ($giRetCode)
    {
        catctlDie("$MSGFCATCONEXEC $!");
    }

    $SqlAry[0] = $pSqlScript;
    $giRetCode =
        catconExec(@SqlAry, 
                   $CATCONSERIAL,   # run single-threaded
                   $pWhereToRun,    # Where to run command
                   0, # Don't issue process init/completion statements
                   $pInclusion,     # Inclusion list 
                   $pExclusion,     # Exclusion List
                   $gsNoIdentifier, # No SQL Identifier
                   $gsNoQuery);     # No Query

    if ($giRetCode)
    {
        catctlDie("$MSGFCATCONEXEC $!");
    }

} # end catctlShutDownDatabase


######################################################################
# 
# catctlDie - Print Message to user and die.
#
# Description:
#   Print Message to Screen and die
#
# Parameters:
#   pMsg     - Message to Print
######################################################################
sub catctlDie {
    my $pMsg     = $_[0];    # Message to Print

    #
    # Set Fatal Error Flag
    #
    $gbFatalError     = $TRUE;
    $gbCatctlDieError = $TRUE;

    #
    # Print Message to screen
    #
    catctlPrintMsg("\n$pMsg\n", $FALSE,$TRUE);

    #
    # Now Die Status returned
    #
    die ();
}


######################################################################
# 
# catctlPrintMsg - Print Message to STDERR and store results.
#
# Description:
#   Print Message to Screen and store results.  This will allows
#   us to dump messages to log file.
#
# Parameters:
#   pMsg     - Message to Print
#   pbLogMsg - Log Message to catupgrd0.log
#   pbLogScreen -  Log Message to screen
######################################################################
sub catctlPrintMsg {
    my $pMsg     = $_[0];    # Message to Print
    my $pbLogMsg = $_[1];    # Log Message to file
    my $pbLogScreen = $_[2]; # Print to Screen

    #
    # Accumlate message to write to log file
    #
    if ($pbLogMsg)
    {
        $gsPrintCmds =  $gsPrintCmds.$pMsg;
    }

    #
    # Print message to screen
    #
    if ($pbLogScreen)
    {
        print STDERR "$pMsg";
    }
}  #End catctlPrintMsg

######################################################################
# 
# catctlWriteTraceMsg - Write trace messages to log files.
#
# Description:
#   Write trace messages to log files.
#
# Parameters:
#   Input:   $psErrorMsg - Trace Message
#
# Returns:
#   - None
######################################################################
sub catctlWriteTraceMsg
{
        my $psErrorMsg   = $_[0];   # Trace Message
        my $TraceLogFile = $gsSpoolLogDir."_trace.log";
        my $SpoolLogFile = $gsSpoolLogDir."0.log";
        my $CatConLogFile = $gsSpoolLogDir."_catcon_".$$.".lst";

        #
        # Write Trace File and Message to User
        #
        catctlPrintMsg("$psErrorMsg", $TRUE,$TRUE);
        catctlPrintMsg("$MSGFATALERROR", $TRUE, $TRUE);
        catctlPrintMsg(" LOG FILES: ($gsSpoolDir$SLASH$gsSpoolLog*.log)\n".
                       "TRACE FILE: ($TraceLogFile)\n\n",
                       $TRUE,$TRUE);
        #
        # Write catcon output to user
        #
        if (-e $CatConLogFile)
        {
            open (FileIn, '<', $CatConLogFile);
            while (<FileIn>)
            {
                print STDERR "$_";
            }
            close (FileIn);
        }

        #
        # Write trace file
        #
        open (FileOut, '>', $TraceLogFile);
        print FileOut "\n$psErrorMsg\n";
        close (FileOut);

        #
        # Write Trace Message to Log File
        #
        open (FileOut, '>>', $SpoolLogFile);
        print FileOut "\nStart of Trace Message\n$LINETAG\n";
        print FileOut "\n$psErrorMsg\n";
        print FileOut "\nEnd of Trace Message\n$LINETAG\n";
        close (FileOut);

}  #End catctlWriteTraceMsg

######################################################################
# 
# catctlWriteStdErrMsgs - Write STDERR Messages to log file.
#
# Description:
#   Write all STDERR Msgs to the end of the log file.
#
# Parameters:
#   None
######################################################################
sub catctlWriteStdErrMsgs {

    my $LogFile = $gsSpoolLogDir."0.log";
    my $CatConLogFile = $gsSpoolLogDir."_catcon_".$$.".lst";
    my $Line = "";
    my $TOTALTAG = "Total Upgrade Time: ";
    my $idx1 = 0;
    my $counter = 0;
    my @GrandTotals;
    my @SortedTotals;
    my $Days  = int($gtTotSec/(24*60*60));
    my $Hours = ($gtTotSec/(60*60))%24;
    my $Mins  = ($gtTotSec/60)%60;
    my $Sec   = $gtTotSec%60;
    my $TotalTime = "Grand $TOTALTAG   [";

    #
    # Create Log File if not present
    #
    if (!-e $LogFile)
    {
        open (FileOut, '>', $LogFile);
        close (FileOut);
    }

    #
    # If Log File still not found then just get out
    #
    if (!-e $LogFile)
    {
        print STDERR "$MSGFCATCTLWRITESTDERRMSGS $LogFile\n";
        return;
    }

    #
    # If a pdb is being processed
    # then just say total upgrade
    # time.
    #
    if ($gbInstance)
    {
        $TotalTime = "$TOTALTAG         [";
    }

    #
    # Put together the display for the user
    #
    $TotalTime = $TotalTime.$Days.$DSPDAYS.":".
                 $Hours.$DSPHRS.":".$Mins.$DSPMINS.":".
                 $Sec.$DSPSECS."]";
    #
    # Display Total Time in human readable format
    #
    catctlPrintMsg ("\n$TotalTime\n",$TRUE,$TRUE);

    #
    # Write out PDB Error messages
    #
    if (($gsPdbSumMsg) && ($gbCdbDatabase) && (!$gbInstance))
    {
        $gsPdbSumMsg = "\n$MSGIPDBERRORS\n$LINETAG\n".$gsPdbSumMsg.
            "\n$LINETAG\n";
        catctlPrintMsg($gsPdbSumMsg, $TRUE, $TRUE);
    }

    #
    # Open catupgrd0.log and Write stderr messages and close file
    #
    open (FileOut, '>>', $LogFile);
    print FileOut "\nStart of Input Commands\n$LINETAG\n";
    print FileOut "\n$gsPrintCmds\n";
    print FileOut "\nEnd of Input Commands\n$LINETAG\n";


    print FileOut "\nStart of DataPatch Logs\n$LINETAG\n";
    # 17277459: Append datapatch logs also
    if (-e $gsDatapatchLogUpgrade) {
      print FileOut "$MSGIDP_OUT_UPGRADE\n";
      open (FileIn, '<', $gsDatapatchLogUpgrade);
      while (<FileIn>)
      {
        print FileOut $_;
      }
      close (FileIn);
    }

    if (-e $gsDatapatchErrUpgrade) {
      print FileOut "$MSGIDP_ERR_UPGRADE\n";
      open (FileIn, '<', $gsDatapatchErrUpgrade);
      while (<FileIn>)
      {
        print FileOut $_;
      }
      close (FileIn);
    }

    if (-e $gsDatapatchLogNormal) {
      print FileOut "$MSGIDP_OUT_NORMAL\n";
      open (FileIn, '<', $gsDatapatchLogNormal);
      while (<FileIn>)
      {
        print FileOut $_;
      }
      close (FileIn);
    }

    if (-e $gsDatapatchErrNormal) {
      print FileOut "$MSGIDP_ERR_NORMAL\n";
      open (FileIn, '<', $gsDatapatchErrNormal);
      while (<FileIn>)
      {
        print FileOut $_;
      }
      close (FileIn);
    }

    print FileOut "\nEnd of DataPatch Logs\n$LINETAG\n";
    close (FileOut);

    #
    # Open catupgrd0.log and Write Summary report at the end
    # of our log file.  We don't do it for individual PDB's
    # wanted to avoid the overhead.
    #
    if ((-e $gsReportName) && (!$gbInstance))
    {
        open (FileOut, '>>', $LogFile);
        open (FileIn, '<', $gsReportName);
        print FileOut "\nStart of Summary Report\n$LINETAG\n";
        while(<FileIn>)
        {
             #
             # Store the line
             #
             $Line = $_;
             chomp($Line);

             #
             # Combine Grand Totals for a CDB database
             #
             if ($gbCdbDatabase)
             {
                 $idx1 = index($Line, $TOTALTAG);
                 if ($idx1 != -1)
                 {
                     $counter++;
                     push(@GrandTotals, $Line."\n");
                 }
             }

             #
             # Write the line to log file
             #
             print FileOut "$Line\n";

        }

        #
        # Write combined grand totals at the end catupgrd0.log
        #
        if (($gbCdbDatabase) && ($counter > 1))
        {
            # sort by time at position 21 (note the 20) for length of 8
            # sort in reverse (descending) order, hence the b before a in
            # sort{ cmp } statement
            @SortedTotals = map{$_->[0]}
                            sort {$b->[1] cmp $a->[1]}
                            map {[$_,substr($_,20,8)]} @GrandTotals;

            print FileOut "\nUpgrade Times Sorted In Descending Order\n\n";
            print FileOut @SortedTotals;
        }

        #
        # Write Total Time to catupgrd*0 log file
        #
        print FileOut "$TotalTime\n";
        print FileOut "\nEnd of Summary Report\n$LINETAG\n";

        #
        # Close Files
        #
        close (FileIn);
        close (FileOut);

        open (FileOut, '>>', $gsReportName);

        #
        # Write combined grand totals at the end of summary report
        #
        if (($gbCdbDatabase) && ($counter > 1))
        {
            print FileOut "\nUpgrade Times Sorted In Descending Order\n\n";
            print FileOut @SortedTotals;
        }

        #
        # Write Total Time to upgrade summary report file
        #
        print FileOut "$TotalTime\n";
        close(FileOut);
    }

    #
    # Write catcon output to catupgrd0.log file
    #
    if (-e $CatConLogFile)
    {
        open (FileOut, '>>', $LogFile) or 
            catctlDie("$MSGFCATCTLWRITELOGFILES - Writing catcon $LogFile $!");
        open (FileIn, '<', $CatConLogFile) or
            catctlDie("$MSGFCATCTLWRITELOGFILES - Reading catcon ".
                      "$CatConLogFile $!");
        print FileOut "\nStart of catcon Errors\n$LINETAG\n";
        while (<FileIn>)
        {
            print FileOut $_;
        }
        print FileOut "\nEnd of catcon Errors\n$LINETAG\n";
        close (FileIn);
        close (FileOut);
    }
}


######################################################################
# 
# catctlGetDisplayMode - Get open mode of the database
#
# Description:  Return the mode of the database
#
# Parameters:
#
#   INPUT - Container Name
#
# Returns:
#   - Database Mode (READ WRITE) (MIGRATE) etc...
#
######################################################################
sub catctlGetDisplayMode
{
    my $pContainerName = $_[0];    # Container Name
    my $ReturnMode = "";

    $ReturnMode = catctlGetOpenMode ($pContainerName);
    if (!$ReturnMode)
    {
        $ReturnMode = "NOT OPENED";
    }

    return($ReturnMode);

}  # End catctlGetDisplayMode


######################################################################
# 
# catctlGetOpenMode  - Returns database Open mode
#
# Description:
#
# Returns the database Open mode
#
# Parameters:
#   Pdb
#
# Returns:
#   - Database Mode
#   - ""   If not opened
#
######################################################################
sub catctlGetOpenMode
{
    my $pPdb = $_[0];
    my $Mode;
    my $Sql = "select status from v\$instance";


    #
    # Set Sql for PDB's if specified
    #
    if ($pPdb)
    {
        $Sql = "select open_mode from v\$containers ".
               "where name = \'$pPdb\'";
    }

    $Mode = catctlQuery ($Sql,undef);

    return ($Mode);

}  # End of catctlGetOpenMode

######################################################################
# 
# catctlGetRootOpenMode  - Tell us if database is in Migration Mode
#
# Description:
#
#   Tell me weather the root is open in migration mode.
#   If an Inclusion/Exclusion list is used and the rootctl
#   is open in upgrade mode then we can only open the PDB's
#   in upgrade mode.  We must detect this an perform
#   post upgrade procedures in upgrade mode.
#
# Parameters:
#
# Returns:
#   - TRUE  - Root in Upgrade mode
#   - FALSE - Root not in Upgrade mode
#
######################################################################
sub catctlGetRootOpenMode
{
    my $Mode    = "";

    #
    # Must be in migration mode
    #
    if (!$gbCdbDatabase)
    {
        return ($TRUE);
    }

    #
    # If Processing Root we will restart
    # the database in the correct mode
    # just return false.
    #
    if ($gbRootProcessing)
    {
        return ($FALSE);
    }

    #
    # If we are processing a inclusion list then
    # the root database may have been started
    # in upgrade mode we have to be able
    # to handle that and force the PDB's to
    # start in upgrade mode when we the post upgrade.
    #
    $Mode =  catctlGetOpenMode(undef);

    if (!$Mode)
    {
        catctlPrintMsg ("$CDBROOT  Open Mode = [NOT OPENED]\n",$TRUE,$TRUE);
        return ($FALSE);
    }

    if ($Mode eq $UPGRADEMODE)
    {
        if (!$gbEmulate)
	{	
       	    catctlPrintMsg ("$CDBROOT  Open Mode = [$Mode]\n",$TRUE,$TRUE);
            return ($TRUE);
	}
	else 
	{
	    if (!$gbUpgradeMode)	
	    {
       	   	catctlPrintMsg ("$CDBROOT  Open Mode = [OPEN]\n",$TRUE,$TRUE);
            	return ($TRUE);
            }
	    else
	    {
       	   	catctlPrintMsg ("$CDBROOT  Open Mode = [$Mode]\n",$TRUE,$TRUE);
            	return ($TRUE);
            }
	}		
    }

    catctlPrintMsg ("$CDBROOT  Open Mode = [$Mode]\n",$TRUE,$TRUE);
    return ($FALSE);

}  # End of catctlGetRootOpenMode

######################################################################
# 
# catctlIsPDBOkay - Is PDB in migrate mode for upgrade or 
#                   read write for post upgrade.
#
# Description:  We call this routine for a container list that
#               is provided to us by the user.  This routine
#               will ensure that the containers specified in
#               the list are in upgrade mode or read write mode
#               for the post upgrade procedures.  If a re-run
#               of an upgrade was specified and any of the
#               pdb containers were in mounted state catcon
#               would kick out the mounted pdb as invalid and
#               stop the re-run.  So now we will only process
#               Pdb's within a list that are in upgrade
#               mode or read write mode for the post upgrade.
#               An example of a case where this would happen
#               is as follows:
#                 perl catctl.pl -C 'CDB$ROOT' catupgrd.sql
#               This means upgrade all the Pdb's. If any of the Pdb's
#               were in mounted state the entire upgrade would have
#               been stopped.
#
# Parameters:
#
#   INPUT - 
#      pContainerName - Container Name
#      pStartPhaseNo  - Start Phase #
#
# Returns:
#   - TRUE  PDB okay to upgrade or run post upgrade
#   - FALSE PDB not okay
#
######################################################################
sub catctlIsPDBOkay
{
    my $pContainerName = $_[0];     # Container Name
    my $pStartPhaseNo  = $_[1];     # Start Phase No
    my $RetStat        = $FALSE;    # Assume Bad
    my $Msg            = "";        # Message
    my $OpenMode       = "";        # Open Mode
    my $isFreshDB      = 0;         # Is PDB freshly created in this release

    #
    # Check to see if user specified post upgrade run
    # if yes then check pdb is in write mode or
    # upgrade mode.  If no then make sure pdb is in
    # upgrade mode.
    #
    if (catctlIsPhase($pStartPhaseNo,$POSTUPGRADEJOB))
    {
        $Msg = "NO POST UPGRADE WILL BE PERFORMED";
        if (catctlIsWrite($pContainerName) || 
            catctlIsMigrate($pContainerName))
        {
            $RetStat = $TRUE;
        }
    }
    else
    {
        $Msg = "NO UPGRADE WILL BE PERFORMED";

        if (!catctlIsMounted($pContainerName))
	{
       	    $isFreshDB=catctlIsFreshDB($pContainerName);
	}
        if (catctlIsMigrate($pContainerName))
        {
	    if ( $isFreshDB == 0)
	    {
                 $RetStat = $TRUE;
	    }
	    else
	    {
	 	if( $gbOverNotUpgrade == 1)
		{
			$RetStat = $TRUE;
		}
		else
		{
		
                 	$RetStat = $FALSE;
            	 	push(@pAryPDBInstanceFresh,$pContainerName);
		}
	    }
        }
	else
	{
           $RetStat = $FALSE;
	    	if ($isFreshDB == 1)
	    	{
            	   push(@pAryPDBInstanceFresh,$pContainerName);
	    	}
	}
    }


    #
    # Not in the correct mode
    #
    if (!$gbInstance && !$RetStat && @pAryPDBInstanceFresh==0) 
    {
        $OpenMode = catctlGetDisplayMode($pContainerName);
        catctlPrintMsg ("$pContainerName Open Mode = [$OpenMode] ".
                        "$Msg\n", $TRUE,$TRUE);
    }

    return ($RetStat);
}

######################################################################
# 
# catctlGetPriority - Get priority of the container
#
# Description:  Return the priority number of the container
#
# Parameters:
#
#   INPUT - Container Name
#
# Returns:
#   - Priority Number
#
######################################################################
sub catctlGetPriority
{
    my $pContainerName = $_[0];    # Container Name
    my $Sql = "select c.upgrade_priority from ".
              "v\$containers v, sys.container\$ c ".
              "where v.name = \'$pContainerName\' and ".
              "v.con_id = c.con_id# and c.upgrade_priority is not null";
    my $iPriorityNo = 0;
    my $iDefaultPri = CATCONST_MAXPDBS;


    #
    # Get Priority Number
    #
    $iPriorityNo = catctlQuery ($Sql,undef);

    #
    # Set to Max PDBS if priority not set
    # This makes it a low priority by default.
    #
    if (!$iPriorityNo)
    {
        $iPriorityNo = $iDefaultPri;
    }

    #
    # Not a number default it. Cover case when
    # column has not yet been defined.
    #
    if (!looks_like_number($iPriorityNo))
    {
        $iPriorityNo = $iDefaultPri;
    }

    #
    # Show PDB's with priority
    #
    if ($iPriorityNo != $iDefaultPri)
    {
        catctlPrintMsg ("Priority is [$iPriorityNo] for $pContainerName\n",
                        $TRUE,
                        $FALSE);
    }

    return($iPriorityNo);

}  # End catctlGetPriority

######################################################################
# 
# catctlGetContainerName - Get name of the container
#
# Description:  Return the container name of the container
#
# Parameters:
#
#   INPUT - Container ID (con_id)
#
# Returns:
#   - Container Name
#
######################################################################
sub catctlGetContainerName
{
    my $pConId = $_[0];    # Container Id
    my $Sql = "select v.name from ".
              "v\$containers v, sys.container\$ c ".
              "where v.con_id = c.con_id# and v.con_id = $pConId";
    my $RetContainerName = "";

    $RetContainerName = catctlQuery ($Sql,undef);

    return($RetContainerName);

}  # End catctlGetContainerName

######################################################################
# 
# catctlIsMigrate - Is PDB in upgrade mode.
#
# Description:  Check to see if we are in upgrade mode.
#
# Parameters:
#
#   INPUT - Container Name
#
# Returns:
#   - TRUE  PDB in Upgrade Mode
#   - FALSE PDB not in Upgrade Mode
#
######################################################################
sub catctlIsMigrate
{
    my $pContainerName = $_[0];    # Container Name
    my $MIGRATEMODE = "MIGRATE";
    my $OpenMode =  catctlGetOpenMode ($pContainerName);
    my $RetStat  =  $FALSE;


    if (($OpenMode) && ($OpenMode eq $MIGRATEMODE))
    {
        $RetStat = $TRUE;
    }

    #
    # Return TRUE or FALSE
    #
    return $RetStat;
}  # End of catctlIsMigrate

######################################################################
# 
# catctlIsWrite - Is Database in write mode.
#
# Description:  Check to see if the database is in write mode.
# Parameters:
#
#   INPUT - Container Name
#
# Returns:
#   - TRUE  Database/PDB in write mode
#   - FALSE Database/PDB not in write mode
#
######################################################################
sub catctlIsWrite
{
    my $pContainerName = $_[0];    # Container Name
    my $WRITEMODE = "READ WRITE";
    my $OpenMode =  catctlGetOpenMode ($pContainerName);
    my $RetStat  =  $FALSE;

    if (($OpenMode) && ($OpenMode eq $WRITEMODE))
    {
        $RetStat = $TRUE;
    }

    #
    # Return TRUE or FALSE
    #
    return $RetStat;
}  # End of catctlIsWrite

####################################################################
# 
# catctlIsMounted - Is PDB in mounted mode.
#
# Description:  Check to see if we are in mounted mode.
#
# Parameters:
#
#   INPUT - Container Name
#
# Returns:
#   - TRUE  PDB in MOUNTED Mode
#   - FALSE PDB not in MOUNTED mode
#
######################################################################
sub catctlIsMounted
{
    my $pContainerName = $_[0];    # Container Name
    my $MOUNTEDMODE = "MOUNTED";
    my $OpenMode =  catctlGetOpenMode ($pContainerName);
    my $RetStat  =  $FALSE;


    if (($OpenMode) && ($OpenMode eq $MOUNTEDMODE))
    {
        $RetStat = $TRUE;
    }

    #
    # Return TRUE or FALSE
    #
    return $RetStat;
}  # End of catctlIsMounted

######################################################################
# 
# catctlIsPhase - Return the Post Upgrade Phase.
#
# Description:    Given a phase number and name compare to
#                 see if we have a match with the phase_files.
# Parameters:
#
#   pPhaseNo   - (INPUT) Phase No
#   pPhaseName - (INPUT) Phase Name 
#
#   None
#
# Returns:
#   - $TRUE  -  Phase Found
#   - $FALSE -  Phase Not Found
#
######################################################################
sub catctlIsPhase
{
    my $pPhaseNo   =  $_[0];     # Phase No
    my $pPhaseName =  $_[1];     # Phase Name
    my $RetStat    =  $FALSE;    # Set to False
    my $NumOfPhaseFiles;         # Number of phase files

    $NumOfPhaseFiles = @{$phase_files[$pPhaseNo]};

    #
    # Make sure phase has files to process
    #
    if ($NumOfPhaseFiles > 0)
    {
        #
        # Return True if phase is equal to phase name
        #
        if ($phase_files[$pPhaseNo][0] eq $pPhaseName)
        {
            $RetStat    =  $TRUE;
        }
    }

    return ($RetStat);

}  # End catctlIsPhase

######################################################################
# 
# catctlGetPhaseNo - Return the Post Upgrade Phase.
#
# Description:    Given a phase number and name compare to
#                 see if we have a match with the phase_files.
# Parameters:
#
#   pPhaseName - (INPUT) Phase Name 
#
#   None
#
# Returns:
#   - Phase Number assoiated with the name
#
######################################################################
sub catctlGetPhaseNo
{
    my $pPhaseName =  $_[0];     # Phase Name
    my $idx = 0;

    for ($idx = 0; $idx < @phase_type; $idx++)
    {
        if (catctlIsPhase($idx,$pPhaseName))
        {
            return ($idx);
        }
    }
 
    #
    # Should never get here if we do thier is a problem
    #
    catctlDie("$MSGFINVPHASENAME $pPhaseName $!");


}  # End catctlGetPhaseNo

######################################################################
# 
# catctlSetPhaseToJob - Set Phase to Job.
#
# Description:    Given a phase number and a phase job
#                 Set that phase to the job.
# Parameters:
#
#   pPhaseNo  - (INPUT) Phase No
#   pPhaseJob - (INPUT) Phase Job 
#
#   None
#
# Returns:
#   - None
#
######################################################################
sub catctlSetPhaseToJob
{
    my $pPhaseNo  =  $_[0];     # Phase No
    my $pPhaseJob =  $_[1];     # Phase Job

    $phase_files[$pPhaseNo][0] = $pPhaseJob;

}  # End catctlSetPhaseToJob

######################################################################
# 
# catctlGetCpus      - Get Number of cpus        
#
# Description:
#
# Parameters:
#
# Returns:
#   - Number of cpus
#
######################################################################
sub catctlGetCpus
{
    my $Sql = "select p.value from v\$parameter p where p.name=\'cpu_count\'";
    my $NumCores = catctlQuery ($Sql,undef);

    if (!$NumCores)
    {
        catctlPrintMsg ("\nNumber of Cpus        = Unknown Defaulting\n",$TRUE,$TRUE);
        $NumCores = 8;
    }
 
    catctlPrintMsg ("\nNumber of Cpus        = $NumCores\n",$TRUE,$TRUE);

    #
    # Return Number of cpus
    #
    return $NumCores;
}  # End of catctlGetCpus

######################################################################
# 
# catctlGetMajorVersion      - Get Major Version Number of the database       
#
# Description:  Get the Major Number of the database
#
# Parameters:
#
# Returns:
#   - Major Number
#
######################################################################
sub catctlGetMajorVersion
{
    my $Sql = "select version from $REGISTRYTBL where cid = \'CATPROC\'";
    my $Version = catctlQuery ($Sql,undef);
    my $RetVersion = 11;
    my $MajorVerLen = 2;

    if ($Version)
    {
        if (length($Version) > $MajorVerLen)
        {
            $RetVersion = abs(substr($Version,0,$MajorVerLen));
        }
    }
 
    catctlPrintMsg ("DataBase Version      = $Version\n",$TRUE,$TRUE);

    #
    # Return Major Version
    #
    return $RetVersion;

}  # End of catctlGetMajorVersion


######################################################################
# 
# catctlGetDbName - Get Database Name        
#
# Description:  Return Database Unique name
#
# Parameters:
#
# Returns:
#   - Database Name
#
######################################################################
sub catctlGetDbName
{

    #
    # Look up database name if not called yet.
    #
    if (!$gsDbName)
    {
        my $Sql = "select p.value from v\$parameter p ".
            "where p.name=\'db_unique_name\'";
        $gsDbName = catctlQuery ($Sql,undef);
        if (!$gsDbName)
        {
            catctlPrintMsg ("Database Name         = Unknown Defaulting\n",$TRUE,$TRUE);
            $gsDbName = catctlGetEnv($ORACLE_SID_VAR);
            if (!$gsDbName)
            {
                $gsDbName = "oracle_".catctlGetDateTime(1);
            }
        }
        catctlPrintMsg ("Database Name         = $gsDbName\n",$TRUE,$TRUE);
    }

    #
    # Return Database Name
    #
    return $gsDbName;
}  # End of catctlGetDbName


######################################################################
# 
# catctlQuery      - Query returning results
#
# Description:  Simple Query statements return a result set.
#
# Parameters:
#   Input: Sql Statement.
#   Input: Pdb Name
#
# Returns:
#   - Result
#
######################################################################
sub catctlQuery
{
    my $pSql = $_[0];       # Sql Query
    my $pPdb = $_[1];       # Pdb
    my @RetResults;         # Return Results

    @RetResults = catctlAryQuery ($pSql, $pPdb);

    #
    # Return Results
    #
    return $RetResults[0];

}  # End of catctlQuery


######################################################################
# 
# catctlAryQuery - Query returning Array results
#
# Description:  Return an array of the results
#
# Parameters:
#   Input: Sql Statement.
#   Input: Pdb Name
#
# Returns:
#   - Result
#
######################################################################
sub catctlAryQuery
{
    my $pSql = $_[0];       # Sql Query
    my $Pdb  = $_[1];       # Pdb
    my @RetResults;         # Return Results

    @RetResults = catconQuery ($pSql, $Pdb);

    #
    # Return Results
    #
    return @RetResults;

}  # End of catctlAryQuery

######################################################################
# 
# catctlSetPDBProcessLimits  -  Set PDB process limits
#
# Description:  Set the process limits for how many sql processes
#               will be used during the PDB upgrade.
#
# For PDB.
#
#   Default SQL Processes  = DEFPROC_PDB (2)
#   Max Sql Processes      = MAXPROC_PDB (8)
#
#
# Parameters:
#   pProcess     = Total Number of SQL Processes (Input)
#   pPdbProcess  = Total Number of SQL PDB Processes (Input)
#
# Returns:
#   - The number of PDB SQL Processors
#
######################################################################
sub catctlSetPDBProcessLimits
{
    my $pProcess    = $_[0];  # Number of SQL Process from user
    my $pPdbProcess = $_[1];  # Number of PDB SQL Process from user
    my $RetSqlProcs = 0;      # Return Number of SQL processors

    #
    # Get out if running serial
    #
    if ($gbSerialRun == $TRUE)
    {
        return($pProcess);
    }

    #
    # Return Number of SQL processors for the PDB
    # If a PDB Instance.
    # Everything already calculated in Main thread.
    #
    if ($gbInstance)
    {
        return($pProcess);
    }

    #
    # Set Equal to what user passed
    #
    $RetSqlProcs = $pPdbProcess;

    #
    # No More than the max
    #
    if ($pPdbProcess > $MAXPROC_PDB)
    {
        $RetSqlProcs = $MAXPROC_PDB;
    }

    #
    # Check for no user input then default
    # the value.
    #
    if ($pPdbProcess == $MINPROC)
    {
        #
        # Make sure process count (-n) is not less than the default value
        # (-N) for PDB's.  If it is then set default value of the PDB's
        # to -n otherwise default PDB to DEFPROC_PDB.
        # Edge case condition (ie) catctl -n 1 -c 'CDB$ROOT'
        #
        if (($pProcess != $MINPROC) && ($pProcess < $DEFPROC_PDB))
        {
            $RetSqlProcs = $pProcess;
        }
        else
        {
            $RetSqlProcs = $DEFPROC_PDB;
        }
    }

    #
    # Return Value
    #
    return ($RetSqlProcs);

}

######################################################################
# 
# catctlSetProcessLimits      -  Set process limits
#
# Description:  Set the process limits for how many sql processes
#               will be used during the upgrade.
#
# For Non CDB.
#
#   Default SQL Processes  = DEFPROC_NO_CDB (4)
#   Max Sql Processes      = MAXPROC_NO_CDB (8)
#
# For CDB.
#
#   Default SQL Processes  = # Cpus
#   Max Sql Processes      = None 
#
#   PDB Instances (Number of PDB upgrades running at the same time)
#   are calculated as follows
#
#   Number of Instances    = (pProcess/pPdbProcess)
#   Each Instance          = 1-8 SQL Processes
#
#   Max Sql Processes for  = $MAXROOT_CDB (8)
#   CDB$ROOT
#   
#
# Parameters:
#
#   pCpus        = The Number of CPU's (Input)
#   pProcess     = Total Number of SQL Processes (Input)
#   pPdbProcess  = Total Number of SQL PDB Processes (Input)
#
# Returns:
#   - The number of SQL Processors
#
######################################################################
sub catctlSetProcessLimits
{
    my $pCpus       = $_[0];  # Cpu Count
    my $pProcess    = $_[1];  # Number of SQL Process from user
    my $pPdbProcess = $_[2];  # Number of PDB SQL Process from user
    my $RetSqlProcs = 0;      # Return Number of SQL processors
    my $LogNumber = $pCpus*2; # Number of Logs

    #
    # Get out if running serial
    #
    if ($gbSerialRun == $TRUE)
    {
        return($pProcess);
    }

    #
    # Return Number of SQL processors for the PDB
    # If a PDB Instance.
    #
    if ($gbInstance)
    {
        #
        # Delete old Log Files greater than or
        # equal to process count.  Make sure you don't delete
        # Logs that will be created.  If you do DBUA can't
        # get status and lose their file handle(s) to the log files.
        # Everything already calculated in Main thread.
        catctlDelLogFiles($pProcess, $MAXPROC_NO_CDB-1,$gsSpoolLogDir); 
        return($pProcess);
    }

    #
    # Set Equal to what user passed
    #
    $RetSqlProcs = $pProcess;

    #
    # Set Log number to the higher number
    #
    if ($pProcess > $LogNumber)
    {
        $LogNumber = $pProcess;
    }

    #
    # Set Log number to the higher number
    #
    if ($MAXPROC_NO_CDB > $LogNumber)
    {
        $LogNumber = $MAXPROC_NO_CDB;
    }
    
    #
    # Calculate Processors
    #
    if (catconIsCDB())
    {
        #
        # Set Default PDB Instances
        # Equal number of CPUs
        #
        $giPdbInstances = $pCpus;

        #
        # Check for no user input
        #
        if ($pProcess == $MINPROC)
        {
            $RetSqlProcs = $pCpus;
            #
            # Check for less than minimum
            #
            if ($RetSqlProcs < $MINROOT_CDB)
            {
                $RetSqlProcs = $MINROOT_CDB;
            }
            #
            # Divide Number of CPU by Pdb Processors
            #
            if ($pCpus > $pPdbProcess)
            {
                $giPdbInstances = int($pCpus/$pPdbProcess);
            }
            else
            {
                catctlPrintMsg ("PDB Parallel SQL Process Count ".
                                "= [$pPdbProcess] is higher or ".
                                "equal to CPU Count = [$pCpus]\n",
                                $TRUE,$TRUE);
                catctlPrintMsg ("Concurrent PDB Upgrades defaulting ".
                                "to CPU Count [$giPdbInstances]\n",
                                $TRUE,$TRUE);
            }
        }
        else
        {
            #
            # Divide Total Sql Processors by Pdb Processors
            #
            if ($pProcess >= $pPdbProcess)
            {
                $giPdbInstances = int($pProcess/$pPdbProcess);
            }
            else
            {
                catctlPrintMsg ("PDB Parallel SQL Process Count ".
                                "= [$pPdbProcess] is higher than Maximum ".
                                "parallel SQL processes = [$pProcess]\n",
                                $TRUE,$TRUE);
                catctlPrintMsg ("$MSGFCATCTLSETPROCESSLIMITS",
                                $TRUE,$TRUE);
                catctlDie("$MSGFCATCTLSETPROCESSLIMITS  $!");
            }
        }

        #
        # Caclulate PDB Instances and make sure it not
        # less the the minimun PDB Instances.
        #
        if ($giPdbInstances < $MINPDBINSTANCES)
        {
            catctlPrintMsg ("Concurrent PDB Upgrades reset from ".
                            "[$giPdbInstances] to minimum value ".
                            "[$MINPDBINSTANCES]\n",
                            $TRUE,$TRUE);
            $giPdbInstances = $MINPDBINSTANCES;
        }

        #
        # Set Root Processing down
        # to the max threads
        #
        if ($RetSqlProcs > $MAXROOT_CDB)
        {
            $RetSqlProcs = $MAXROOT_CDB;
        }

        #
        # Print out the Process counts
        #
        catctlPrintMsg ("Parallel SQL Process Count (PDB)      = $pPdbProcess\n",
                        $TRUE,$TRUE);
        catctlPrintMsg ("Parallel SQL Process Count ($CDBROOT) = $RetSqlProcs\n",
                        $TRUE,$TRUE);
        catctlPrintMsg("Concurrent PDB Upgrades               = $giPdbInstances\n",
                       $TRUE,$TRUE);

    }
    else
    {
        #
        # Check for the MAX allowed otherwise
        # take the default processors.
        #
        if ($pProcess > $MAXPROC_NO_CDB)
        {
            $RetSqlProcs = $MAXPROC_NO_CDB;
        }

        #
        # Check for no user input then default
        # to what we used to do.
        #
        if ($pProcess == $MINPROC)
        {
            $RetSqlProcs = $DEFPROC_NO_CDB;
        }

        #
        # Print the given SQL process Count
        #
        catctlPrintMsg ("Parallel SQL Process Count            = $RetSqlProcs\n",$TRUE,$TRUE);
    }

    #
    # We only need to do adjust SQL processors if 
    # different than what user gave us or what
    # was caluclate by catcon when given default 0.
    #
    if ($RetSqlProcs != $pProcess)
    {

        #
        # End all the Sql session except 1
        #
        $giRetCode = catconUpgEndSessions();

        #
        # Start up all the sessions with new SQL Process count
        #
        $giRetCode = catconUpgStartSessions($RetSqlProcs,0,
                                            undef,undef,$gbDebugCatcon);
        if ($giRetCode)
        {
            catctlDie("$MSGFCATCONUPGSTARTSES $!");
        }

        #
        # Clean up Extra Log Files. Make sure you don't delete
        # Logs that will be created.  If you do DBUA can't
        # get status and lose thier file handle(s) to the log files.
        #
        catctlDelLogFiles($RetSqlProcs, $LogNumber-1,$gsSpoolLogDir); 
    }
    else
    {
        #
        # Delete old Log Files greater than or
        # equal to process count.  Make sure you don't delete
        # Logs that will be created.  If you do DBUA can't
        # get status and lose thier file handle(s) to the log files.
        #
        catctlDelLogFiles($RetSqlProcs, $MAXPROC_NO_CDB-1,$gsSpoolLogDir); 
    }

    #
    # Return the number of SQL Processors
    #
    return($RetSqlProcs);

}  # End of catctlSetProcessLimits


######################################################################
# 
# catctlGetEnv     - Get Environmental Variable
#
# Description:     Get Environmental Variable
#
# Note:
#
# Parameters:
#   INPUT - Environmental Variable
#
# Returns:
#   NULL   - not Found
#   Value  - Value of environmental Variable
#
######################################################################
sub catctlGetEnv
{
    my $pEnvVar     = $_[0];    # Environmental Variable
    my $EnvValue    = $ENV{$pEnvVar};

    return ($EnvValue);

} # catctlGetEnv

######################################################################
# 
# catctlUnSetEnv - Set Environmental Variable
#
# Description:       UnSet Environmental Variable
#
# Note:  Only for this process parent process will remain set.
#
# Parameters:
#   INPUT
#      Environmental Variable
#
# Returns:
#   None
#
######################################################################
sub catctlUnSetEnv
{
    my $pEnvVar     = $_[0];    # Environmental Variable

    delete $ENV{$pEnvVar};

} # catctlUnSetEnv

######################################################################
# 
# catctlSetOSEnv - Set Operating System environment
#
# Description:     Set Operating System environment
#                      Set temp directory.
#
#
# Parameters:
#   None
#
# Returns:
#   None
#
######################################################################
sub catctlSetOSEnv
{
    #
    #   Assume Unix Temp Directory
    #
    $gsTempDir         = "/tmp";

    #
    # Set Windows Environment
    #
    if ($^O eq 'MSWin32')
    {
        $SLASH          = $WINDOWSLASH;
        $CONTAINERQUOTE = $DOUBLEQUOTE;
        $ORABASEIMG     = "orabase.exe";
        $ORABASEHOMEIMG = "orabasehome.exe";
        $ORACLEIMG      = "oracle.exe";
        $ORAHOMEIMG     = dirname(File::Spec->rel2abs(__FILE__)).$SLASH."orahome.exe";
        $gsTempDir      = catctlGetEnv("TEMP");
        $gbWindows      = $TRUE;
    }

} # end of catctlSetOSEnv

######################################################################
# 
# catctlSetInputParameters - Set catctl input parameters
#
# Description:     Set catctl input parameters
#
#    Derive -d qualifier from input sql file
#    spec.  For Example we can derive -d
#    qualifier when the user specifies the following
#    perl catctl.pl $ORACLE_HOME/rdbms/admin/catupgrd.sql
#    -d would equal $ORACLE_HOME/rdbms/admin
#
#    Also if the -d qualifier is specified we
#    remove the last character if it is a directory
#    separator.
#
# Parameters:
#   None
#
# Returns:
#   None
#
######################################################################
sub catctlSetInputParameters
{
    my $LastChar = "";

    #
    # If the -d qualifier is not specified then
    # derive it if they gave a file spec with
    # the upgrade file.
    #
    if (!$gSrcDir)
    {
        ($gsFile,$gSrcDir) = fileparse($gsFile,".sql");
        $gsFile = $gsFile.".sql";
        #
        # Make the relative path into an absolute path
        #
        if ($gSrcDir eq ".\/")
        {
            $gSrcDir = cwd();
        }
    }

    #
    # Remove Ending slash from -d qualifier if present
    #
    if ($gSrcDir)
    {
        #
        # Remove lead or trailing blanks
        #
        $gSrcDir = catctlTrim($gSrcDir);

        $LastChar = substr($gSrcDir,length($gSrcDir)-1,1);
        #
        # Remove last character if slash found
        #
        if ($LastChar eq $SLASH)
        {
            $gSrcDir =  substr($gSrcDir,0,length($gSrcDir)-1);
        }
    }

} # end of catctlSetInputParameters

######################################################################
# 
# catctlGetUpgLockFile - Get Lock File to protect against multiple
#                        upgrades on a database.
#
# Description:     Get an exclusive lock on a file to prevent multiple
#                  upgrades on a database.  We will use the database
#                  unique name when creating the lock file so we can
#                  ensure the lock is held for the correct database.
#
#
# Parameters:
#   None
#
# Returns:
#   None
#
######################################################################
sub catctlGetUpgLockFile
{

    #
    # Don't do if catctl instance
    #
    if ($gbInstance)
    {
        return;
    }

    #
    # Lock file is used to prevent two upgrades
    # running at the same time on the same database.
    # Two upgrades may be run on the same system
    # using different databases.
    #

    #
    # Construct the lock file
    #
    $gsUpgLockFile = $gsTempDir.$SLASH.catctlGetDbName().".dat";

    #
    # Open file
    #
    open ($ghUpgLockFile, '>', $gsUpgLockFile) or
        catctlDie("$MSGFERROPENLOCKFILE $gsUpgLockFile\n $!\n");

    #
    # Obtain an exclusive lock or kill ourselves.
    # Only one catctl upgrade per database.  We
    # take out an exclusive lock in non-blocking
    # mode so we don't wait for the lock.  If we
    # cannot get an exclusive lock on the file
    # then we kill ourselves notifying the user
    # that another upgrade process is running.
    # This is done for both CDB and traditional
    # databases.
    #
    flock ($ghUpgLockFile, LOCK_EX|LOCK_NB) or 
        catctlDie("$MSGFANOTHERPROCESS $gsUpgLockFile\n $!\n");

    #
    # Delete File at the end
    #
    push (@files_to_delete, $gsUpgLockFile);

} # end of catctlGetUpgLockFile


######################################################################
# 
# catctlGetRptLockFile - Get Report Lock File to protect against multiple
#                        writes to the summary file.
#
# Description:     Get an exclusive lock on a file to prevent multiple
#                  upgrades on a database.  We will use the database
#                  unique name when creating the lock file so we can
#                  ensure the lock is held for the correct database.
#                  This lock will spin and wait until it can get the
#                  lock.
#
#
# Parameters:
#   None
#
# Returns:
#   None
#
######################################################################
sub catctlGetRptLockFile
{

    my $pEnvVar     = $_[0];    # Environmental Variable

    #
    # Only needed for pdb's
    #
    if (!$gbInstance)
    {
        return;
    }

    #
    # Lock file is used to prevent process writing
    # to the summary report at the same time.
    #

    #
    # Construct the lock file
    #
    $gsRptLockFile = $gsTempDir.$SLASH.catctlGetDbName().".rpt";

    #
    # Open file
    #
    open ($ghRptLockFile, '>', $gsRptLockFile) or
        catctlDie("$MSGFERRRPTLOCKFILE $gsRptLockFile\n $!\n");

    #
    # Obtain an exclusive lock and wait if we can't get it.
    # Only one catctl instance can write to the summary
    # report.  We take out an exclusive lock in blocking
    # mode so we wait for the lock. This is done for the
    # PDB databases only.
    #
    flock ($ghRptLockFile, LOCK_EX);

    #
    # Delete File at the end
    #
    push (@files_to_delete, $gsRptLockFile);

} # end of catctlGetRptLockFile


######################################################################
# 
# catctlDeleteReport - Delete summary report
#
# Description:     Delete summary report.
#
# Parameters:
#   psReportName = Report Name
#
# Returns:
#   None
#
######################################################################
sub catctlDeleteReport
{
    my $psReportName = $_[0];    # Report Name

    #
    # If present then delete it
    #
    if (-e $psReportName)
    {
        unlink($psReportName);
    }

}  # End of catctlDeleteReport

######################################################################
# 
# catctlGetOracleHome - Get Oracle Home
#
# Description:     Determine the Oracle Home
#
# Note:            
#
# Parameters:
#
# Returns:
#   Returns Oracle Home
#
######################################################################
sub catctlGetOracleHome
{
    my $pTempDir      = $_[0]; # Temp Directory
    my $CatctlDir     = "";
    my $OracleImage   = "";


    #
    # Return Oracle Home if we already have it
    #
    if ($gsOracleHomeDir)
    {
        return($gsOracleHomeDir);
    }

    #
    # Try to resolve using the orahome image.
    #
    $gsOracleHomeDir = catctlRunOraImage($pTempDir,undef,$ORAHOMEIMG);
    if ($gsOracleHomeDir)
    {
        #
        # Check for the oracle image
        #
        $OracleImage = $gsOracleHomeDir.$SLASH."bin".$SLASH.$ORACLEIMG;

        #
        # Return oracle home if image is found
        #
        if (-e $OracleImage)
        {
            return($gsOracleHomeDir);
        }
    }

    #
    # If Oracle Home still not set then Derive it from
    # where catctl.pl lives and go up two directories from
    # catctl.pl
    #
    $CatctlDir       = dirname(File::Spec->rel2abs(__FILE__));
    $gsOracleHomeDir = dirname(File::Spec->rel2abs($CatctlDir));
    $gsOracleHomeDir = dirname(File::Spec->rel2abs($gsOracleHomeDir));

    #
    # Return Oracle Home if we can get derive it from catctl.pl
    # Up two directories.
    #
    if ($gsOracleHomeDir)
    {
        #
        # Check for the oracle image
        #
        $OracleImage = $gsOracleHomeDir.$SLASH."bin".$SLASH.$ORACLEIMG;

        #
        # Return oracle home if image is found
        #
        if (-e $OracleImage)
        {
            catctlPrintMsg ( "\nDERIVED ORACLE HOME catctl   = [$gsOracleHomeDir]\n",
                             $TRUE,$TRUE);
            return($gsOracleHomeDir);
        }
    }

    #
    # Last Ditch effort if they gave us a directory where
    # the upgrade scripts live we will use that to determine
    # oracle home just like we do when we calculate it for
    # catctl.pl.
    #
    if ($gSrcDir)
    {
        $CatctlDir       = $gSrcDir;
        $gsOracleHomeDir = dirname(File::Spec->rel2abs($CatctlDir));
        $gsOracleHomeDir = dirname(File::Spec->rel2abs($gsOracleHomeDir));

        #
        # Check for the oracle image
        #
        $OracleImage = $gsOracleHomeDir.$SLASH."bin".$SLASH.$ORACLEIMG;

        #
        # Return oracle home if image is found
        #
        if (-e $OracleImage)
        {
            catctlPrintMsg ("\nDERIVED ORACLE HOME -d       = [$gsOracleHomeDir]\n",
                            $TRUE,$TRUE);
            return($gsOracleHomeDir);
        }
    }

    #
    # Temporary until windows label can create the orahome image
    #
    $gsOracleHomeDir = catctlGetEnv($ORACLE_HOME_VAR);
    if ($gsOracleHomeDir)
    {
        return($gsOracleHomeDir);
    }

    #
    # Not Found
    #
    return(0);
}


######################################################################
# 
# catctlRunOraImage - Run orabase image to get the Oracle Home/Base
#
# Description:     Determine the Oracle Home/Base
#
# Note:            
#
# Parameters:
#   INPUT - pTempDir    = Temp Directory
#   INPUT - pOhDir      = Oracle Home Directory
#   INPUT - pOraImage   = Image name to run
#
# Returns:
#   Returns Value From orabase
#
######################################################################
sub catctlRunOraImage
{
    my $pTempDir      = $_[0];         # Temp Directory
    my $pOHDir        = $_[1];         # Oracle Home Directory
    my $pOraImage     = $_[2];         # Oracle Image to run
    my $RandomNo      = rand();        # Random Number
    my $LogFile       = $pTempDir.$SLASH."orahome".$RandomNo.".log";  # Log File
    my $OraImage      = "";            # Oracle Image to run
    my $ReturnDir     = 0;

    if ($pOHDir)
    {
        $OraImage      = $pOHDir.$SLASH."bin".$SLASH.$pOraImage;
    }
    else
    {
        $OraImage      = $pOraImage; # orabase image
    }

    
    #
    # If we can't find the orabase home image in
    # ORACLE_HOME then default it and hope
    # for the best.
    #
    if (! -e $OraImage)
    {
        $OraImage = $pOraImage;
    }


    #
    # Trap any errors and continue
    #
    eval
    {
        #
        # Run orabase and store results in log file.
        # If File found then read it into a variable
        # and validate the directory.
        #
        system("$OraImage > $LogFile 2>&1");
        if (-e $LogFile)
        {
            open (FileIn, '<', $LogFile);
            $ReturnDir = <FileIn>;
            close (FileIn);
            chomp $ReturnDir;
            if (!catctlValidDir($ReturnDir, "R"))
            {
                $ReturnDir = "Unable to run $pOraImage or directory invalid\n".
                             $ReturnDir."]\nContinuing...\n";
                catctlPrintMsg ("$OraImage = [$ReturnDir]\n",
                                $TRUE,$TRUE); 
                $ReturnDir = 0;
            }
            unlink($LogFile);
        }


    };
    if ($@)
    {
        warn();
    }

    if ($ReturnDir)
    {
        catctlPrintMsg ("$OraImage = [$ReturnDir]\n",$TRUE,$TRUE);
    }

    # 
    # Return orabase directory output
    #
    return ($ReturnDir);

}  # End of catctlRunOraImage

######################################################################
# 
# catctlGetOrabase - Get orabase directory to get the Oracle Home/Base
#
# Description:     Determine the Oracle Base Directory
#
# Note:            
#
# Parameters:
#
# Returns:
#   Returns Value From orabase
#
######################################################################
sub catctlGetOrabase
{
    my $pTempDir      = $_[0];         # Temp Directory
    my $pOHDir        = $_[1];         # Oracle Home Directory
    my $ReturnDir     = 0;             # Return Directory

    #
    # If already found get out
    #
    if ($gsOrabaseDir)
    {
        return($gsOrabaseDir);
    }


    #
    # Try to resolve using the orabasehome image.
    #
    $ReturnDir = catctlRunOraImage($pTempDir,$pOHDir,$ORABASEHOMEIMG);

    #
    # Try to resolve using the orabase image.
    #
    if (!$ReturnDir)
    {
        $ReturnDir = catctlRunOraImage($pTempDir,$pOHDir,$ORABASEIMG);
    }

    #
    # If not found set to temp directory
    # otherwise set orabase directories
    #
    if (!$ReturnDir)
    {
        $ReturnDir = $pTempDir;
    }

    #
    # Print it out
    #
    catctlPrintMsg ("catctlGetOrabase = [$ReturnDir]\n",$TRUE,$TRUE);

    return($ReturnDir);
    

} #End of catctlGetOrabase


######################################################################
#
# catctlAddToSqlAry   - add a file to the SqlAry after checking
#                       for component presence in the DB
#
# Description: If the file name is preceded by a -CP<comp_id> then
#              only add it to the array if the component is in
#              the database.
#
# Parameters: File to run
#
# Returns:
# 
######################################################################
sub catctlAddToSqlAry
{
   my $phase_file = $_[0];    # file from phase_file array to processes
   my $Ary = $_[1];           # reference to SqlAry

   # Add to SqlAry after fix up for comp
   if (substr($phase_file,0,$CATCTLCPTAGLEN) eq "$CATCTLCPTAG") {
     my $pos = index($phase_file,"$CATCTLATTAG");  #start of filename
     push (@$Ary, substr($phase_file,$pos));
   } else {
     push (@$Ary, $phase_file);
   }
  
}  # end of catctlAddToSqlAry

######################################################################
#
# catctlGetCmpInfo - Get Directory and file name for specified component
#
# Description: Looks up the relative path, prefix, and test file
#              for the component scripts
#
# Parameters: Comp_id
#
# Returns:
#   TRUE if comp info in lists
#   FALSE if comp not in  list
#
######################################################################
sub catctlGetCmpInfo
{
  my $id = $_[0];   # Component Id argument
  my $ret = $FALSE; # Empty return path
  my $x = 0;

  for ($x = 0; $x < @AryCmps; $x++)
    {
    if ($id eq $AryCmps[$x]) {
       $gsCmpDir = catctlGetOracleHome($gsTempDir).$AryCmpDirs[$x];  
       $gsCmpFile = $AryCmpPrefs[$x].'upgrd.sql';
       $gsCmpSesFile = $AryCmpPrefs[$x].'upgrdses.sql';
       $gsCmpTestFile = $AryCmpFile[$x];
       $ret = $TRUE;
       last;
       }
    }
  return($ret);

}  # end of catctlGetCmpInfo

######################################################################
# 
# catctlUpdPriorityList - Update Priority Lists
#
# Description: Update priority lists in sys.container$.
#
#
# Parameters:
#   None
#
# Returns:
#   SUCCESS or FAILURE
#
######################################################################
sub catctlUpdPriorityList
{
    my $UpdateSql    = "";          # Update Sql 
    my $PdbItem      = "";          # Pdb item
    my $idx          = 0;           # Counter
    my $MAXCOUNT     = 100;         # Update 100 at a time
    
    #
    # Update Priorities in sys.container$
    #
    foreach $PdbItem (@AryPDBInstanceList)
    {
        #
        # Ignore updates on CDB$ROOT and PDB$SEED
        #
        if (($PdbItem eq $CDBROOTTAG) ||
            ($PdbItem eq $PDBSEEDTAG))
        {
            next;
        }
        $UpdateSql = $UpdateSql.
                     "alter pluggable database $PdbItem upgrade priority ".
                     $HashPdbPriData{$PdbItem}.";\n";
        $idx++;

        #
        # Update $MAXCOUNT at a time
        #
        if ($idx == $MAXCOUNT)
        {
            $UpdateSql = $UpdateSql.$COMMITCMD;
            #
            # Create and Execute Sql File
            #
            $SqlAry[0] = $UpdateSql;
            $giRetCode = catctlExecSqlFile(\@SqlAry,
                                           0,
                                           $gsNoInclusion,
                                           $gsNoExclusion,
                                           $RUNROOTONLY,
                                           $CATCONSERIAL);
            $UpdateSql = "";
            $idx = 0;
        }
    }

    #
    # Update Last Batch
    #
    $UpdateSql = $UpdateSql.$COMMITCMD;
    $SqlAry[0] = $UpdateSql;
    $giRetCode = catctlExecSqlFile(\@SqlAry,
                                   0,
                                   $gsNoInclusion,
                                   $gsNoExclusion,
                                   $RUNROOTONLY,
                                   $CATCONSERIAL);

    return($giRetCode);
 
}  # End of catctlUpdPriorityList



######################################################################
# 
# catctlUpdRptName - Update Summary Report Name
#
# Description: Update the summary report name in registry$upg_summary
#              table.
#
# Location is in the format of 
#    Default to $ORACLE_BASE_HOME/cfgtoollogs/<db-unique-name>/upgrade
#
# Report Name
#    upg_summary.log
#
# Parameters:
#    psReportName = Report Name
#    pInclusion   = Inclusion List 
#    pExclusion   = Exclusion List 
#
# Returns:
#   None
#
######################################################################
sub catctlUpdRptName
{
    my $psReportName = $_[0];       # Report Name
    my $pInclusion   = $_[1];       # Inclusion List
    my $pExclusion   = $_[2];       # Exclusion List
    my $UPDSUMRYTBL  = "UPDATE $SUMMARYTBL SET reportname = '$psReportName' ".
                       "where con_id=-1;\n".$COMMITCMD;
    my $DataBaseRptName = 0;        # Database Report Name

    #
    # If not upgrade then just get out
    #
    $giRetCode = 0;
    if (!$gbUpgrade)
    {
        return($giRetCode);
    }

    #
    # Create and Execute Sql File
    #
    $SqlAry[0] = $UPDSUMRYTBL;
    $giRetCode = catctlExecSqlFile(\@SqlAry,
                                   0,
                                   $pInclusion,
                                   $pExclusion,
                                   $RUNEVERYWHERE,
                                   $CATCONSERIAL);

    return($giRetCode);
 
}  # End of catctlUpdRptName



######################################################################
# 
# catctlDeleteMsgFromRegistryError - Remove message written
#                                    by catctl.pl from REGISTRY$ERROR.
#                                    
#
# Description: Remove message written to REGSITRY$ERROR with catctl.pl
#              as the scriptname.  We only do this if we see a fatal error
#              like ORA-06000 and nothing has been written to REGISTRY$ERROR
#              to dectect the problem.
#
# Parameters:
#    pInclusion   = Inclusion List 
#
# Returns:
#   1 = FAILURE
#   0 = SUCCESS
#
######################################################################
sub catctlDeleteMsgFromRegistryError
{
    my $pInclusion   = $_[0];       # Inclusion List
    my $CLEANREGISTRY="DELETE FROM $ERRORTABLE;\n";
    my $SqlCmd = $SETSTATEMENTS.$CLEANREGISTRY.$COMMITCMD;
    my $sRTInclusion = $gbInstance ? $pInclusion : $gsNoInclusion;
    my $WhereToRun   = $gbInstance ? $RUNEVERYWHERE : $RUNROOTONLY;

    #
    # If not upgrade then just get out
    #
    $giRetCode = 0;
    if (!$gbUpgrade)
    {
        return($giRetCode);
    }

    #
    # Create and Execute Sql File
    #
    $SqlAry[0] = $SqlCmd;
    $giRetCode = catctlExecSqlFile(\@SqlAry,
                                   0,
                                   $sRTInclusion,
                                   $gsNoExclusion,
                                   $WhereToRun,
                                   $CATCONSERIAL);

    if ($giRetCode)
    {
        catctlDie("$MSGFCATCONEXEC $!");
    }
    return($giRetCode);
 
}  # End of catctlDeleteMsgFromRegistryError


######################################################################
# 
# catctlExecSqlFile - Creates and Executes a Sql file.
#
# Description:
#   This subroutine takes a given sql command and
#   create the a sql file and then executes it. 
#
# Returns
#   Status code
#
# Parameters:
#   pArySql - Array of SQL Statements (IN)
#   pFileName - Sql Filename to Append (IN)
#   pInclusion - Inclusion List (IN) 
#   pExclusion - Exclusion List (IN)
#   pWhereToRun  - Flag to Run in Root or everywhere (IN)
#   pSerialOrParallel - 1 Run Serial 0 Run Parallel
#
######################################################################
sub catctlExecSqlFile
{
    my $pArySql     = $_[0];      # Array of SQL Statements
    my $pFileName   = $_[1];      # Filename to append
    my $pInclusion  = $_[2];      # Inclusion List
    my $pExclusion  = $_[3];      # Exclusion List
    my $pWhereToRun = $_[4];      # Flag to Run in Root or everywhere
    my $pSerialOrParallel = $_[5];# 1 is Serial 0 is Parallel   
    my $TmpFileName = "";         # Temporary File Name
    my $AtTmpFileName = "";       # Temporary File Name with @ sign
    my @SqlAryFile;               # And Array of Sql files from the array of sql commands
    my $SqlStatement;             # Single Sql Statement from the arrary

    #
    # Return if emulating
    #
    if ($gbEmulate)
    {
        return(0);
    }


    #
    # Create the Temporary Sql File
    #
    foreach $SqlStatement (@$pArySql)
    {
        $TmpFileName = catctlCreateSqlFile($SqlStatement,$pFileName);
        $AtTmpFileName = "\@".$TmpFileName;
        push (@SqlAryFile, $AtTmpFileName);
    }

    #
    # Execute the Temporary Sql File
    #
    $giRetCode =
        catconExec(@SqlAryFile,
                   $pSerialOrParallel, # run single threaded
                   $pWhereToRun,       # Where to run command 
                   0, # don't issue process init/completion stmts
                   $pInclusion,        # Inclusion list 
                   $pExclusion,        # Exclusion List
                   $gsNoIdentifier,    # No SQL Identifier
                   $gsNoQuery);        # No Query
    #
    # Delete Temp File
    #
    foreach $AtTmpFileName (@SqlAryFile)
    {
        #
        # Strip out the @
        #
        $TmpFileName = substr($AtTmpFileName, 1);

        if (-e $TmpFileName)
        {
            unlink($TmpFileName);
        }
    }

    return ($giRetCode);
}

######################################################################
# 
# catctlTrim - Trims Leading and trailing whitespaces.
#
# Description:
#   This subroutine takes a given string and removes
#   leading and trailing whitespaces. 
#
# Returns
#   Trimmed String
#
# Parameters:
#   pString - String to trim (IN)
#
######################################################################
sub catctlTrim()
{
    my $pString   = $_[0];      # String to Trim
    my $RetString = $pString;

    #
    # Remove Leading spaces
    #
    $RetString =~ s/^\s+//;

    #
    # Remove Trailing spaces
    #
    $RetString =~ s/\s+$//;

    return $RetString;

}   # End catctlTrim

######################################################################
# 
# catctlLtrim - Left trim function to remove leading whitespace.
#
# Description:
#   This subroutine takes a given string and removes
#   leading whitespaces. 
#
# Returns
#   Trimmed String
#
# Parameters:
#   pString - String to ltrim (IN)
#
######################################################################
sub catctlLtrim()
{
    my $pString   = $_[0];      # String to ltrim
    my $RetString = $pString;

    $RetString =~ s/^\s+//;
    return $RetString;

}   # End catctlLtrim

######################################################################
# 
# catctlRtrim - Right trim function to remove trailing whitespace.
#
# Description:
#   This subroutine takes a given string and removes
#   Trailing whitespaces. 
#
# Returns
#   Trimmed String
#
# Parameters:
#   pString - String to rtrim (IN)
#
######################################################################
sub catctlRtrim()
{
    my $pString   = $_[0];      # String to rtrim
    my $RetString = $pString;

    $RetString =~ s/\s+$//;;
    return $RetString;

}  # End catctlRtrim

######################################################################
# 
# catctlGetDateTime - Get Date and Time
#
# Description: Get Date and Time in YYMMDD HH:MN:SC format.
#
#
# Parameters:
#
#   INPUT DspFormat
#
#         0 = YYYY_MM_DD HH:MN:SC
#         1 = YYYYMMDDHHMNSC
#
# Returns:
#   Returns Current Data and Time.
#
######################################################################
sub catctlGetDateTime
{
    my $pDspFormat = $_[0]; # Display Format
    my $sec   = 0;          # Seconds of minutes 0 to 61
    my $min   = 0;          # Minutes of the hour 0 to 59
    my $hour  = 0;          # Hours of day 0 to 24
    my $day   = 0;          # Day of month from 1 to 31
    my $month = 0;          # Month of year from 0 to 11
    my $year1900  = 0;      # Year since 1900
    my $wday  = 0;          # Days since sunday
    my $yday  = 0;          # Days since January 1st
    my $isdst = 0;          # Hours of daylight savings time
    my $RetDate = "";       # Return Date

    ($sec,$min,$hour,$day,$month,$year1900,$wday,$yday,$isdst)=localtime();

    if ($pDspFormat == 0)
    {
        $RetDate = sprintf("%04d_%02d_%02d %02d:%02d:%02d",
                           $year1900+1900,
                           $month+1,
                           $day,
                           $hour,
                           $min,
                           $sec);
    }
    else
    {
        $RetDate = sprintf("%04d%02d%02d%02d%02d%02d",
                           $year1900+1900,
                           $month+1,
                           $day,
                           $hour,
                           $min,
                           $sec);
    }

    return ($RetDate);

}  # End of catctlGetDateTime


######################################################################
# 
# catctlIsRootValid - 
#
# Description: Determine if the CDB$ROOT has be upgraded.
#
# Parameters:
#   INPUT - Boolean Upgrade Flag
#   INPUT - Boolean CDB$ROOT Flag
#   INPUT - Boolean PDB processing flag
#   INPUT - Boolean PDB Instance Flag
#
# Returns:
#   TRUE   - CDB$ROOT has been upgraded.
#   FALSE  - CDB$ROOT has not been upgraded.
#
######################################################################
sub catctlIsRootValid
{
    my $pbUpgrade  = $_[0];         # Upgrade Mode
    my $pbRootProcessing = $_[1];   # Root Processing
    my $pbPdbProcessing = $_[2];    # Pdb Processing
    my $pbInstance = $_[3];         # Pdb Instance
    my $RetCode = $TRUE;            # Assume all is well with the world

    #
    # Check the following:
    #   1) Upgrading
    #   2) This is not a pdb instance
    #   3) CDB$ROOT is not being upgraded
    #   4) We are going to upgrade PDB(s)
    #   Make sure that the CDB$ROOT has
    #   been upgraded before proceeding.
    #   If we are upgrading the CDB$ROOT or
    #   we are currently upgrading a PDB
    #   then just return TRUE.
    #
    if (($pbUpgrade)          && 
        (!$pbInstance)        && 
        (!$pbRootProcessing)  &&
        ($pbPdbProcessing))
    {
        $RetCode = catctlIsDBUpgraded(undef);
    }

    #
    # Return
    #
    return ($RetCode);

}  # End of catctlIsRootValid

######################################################################
# 
# catctlIsDBUpgraded - 
#
# Description: Determine if the CDB$ROOT or Pdb has be upgraded using the
#              following criteria:
#
#              Protect against upgrading a PDB before the CDB$ROOT has been
#              upgraded successfully.
#
#              1) Compare the version of CATPROC in registry$ table
#                 with the version from v$instance table.
#                   SELECT version FROM registry$ WHERE cid = 'CATPROC' 
#                   AND version = (select version from v$instance)
#
#                   Fail Check if version does not match.
#
#              2) Are there any errors in the registry$error table.
#                   SELECT count(distinct(substr(to_char(message),1,9)))
#                   FROM registry$error
#
#                   Fail Check if upgrade errors have been logged
#
#              3) Have we completed the upgrade
#                   SELECT count(*) FROM registry$upg_summary 
#                   WHERE con_id = -1 and starttime = endtime)=0
#
#                   At the beginning of the the upgrade we set
#                   starttime and endtime equal.  At the end of
#                   the upgrade we update the endtime.  If the
#                   upgrade dies in the middle then this check
#                   will fail.
#
#                CDB$ROOT has to satisfy all three conditions
#                to let a PDB upgrade proceed.
#
# Parameters:
#   Input: Pdb Name
#
# Returns:
#   TRUE   - CDB$ROOT or pdb has been upgraded successfully.
#   FALSE  - CDB$ROOT or pdb has not been upgraded successfully.
#
######################################################################
sub catctlIsDBUpgraded
{
    my $pPdb = $_[0];       # Pdb
    my $RPTSTARTTIME = 
        "SELECT count(*) FROM $SUMMARYTBL ".
        "WHERE con_id = -1 AND starttime = endtime";
    my $Sql = 
        "SELECT version FROM $REGISTRYTBL WHERE cid = 'CATPROC' AND ".
        "version = (SELECT version FROM $INSTANCETBL) AND (".
        $SELERR1.$SELERR3.") = 0 AND ($RPTSTARTTIME) = 0";
    my $RegistryVersion = "";
    my $RetCode = $FALSE;

    #
    # Send the query and check for a return version.
    # If version is not returned then database has
    # not been upgraded.
    #
    $RegistryVersion = catctlQuery($Sql,$pPdb);
    if ($RegistryVersion)
    {
        $RetCode = $TRUE;   
    }

    #
    # Return
    #
    return ($RetCode);

}  # End of catctlIsDBUpgraded



######################################################################
# 
# catctlCleanUp    - Cleanup 
#
# Description:     Cleanup at the end of the upgrade
#
#                  Cleanup generated files.  Post upgrade and
#                  pfile.
#
# Parameters:
#
# Returns:
#   None
#
######################################################################
sub catctlCleanUp
{
    my $x = 0;

    #
    # Close Lock files.  This will
    # release any locks held on the
    # file.  If catctl.pl crashes perl
    # will automatically release the lock.
    #
    if ($ghUpgLockFile)
    {
        close($ghUpgLockFile);
        $ghUpgLockFile = undef;
    }
    if ($ghRptLockFile)
    {
        close ($ghRptLockFile);
        $ghRptLockFile = undef;
    }

    #
    # Delete any files we created on the fly
    #
    for ($x = 0; $x < @files_to_delete; $x++)
    {
        if (-e  $files_to_delete[$x])
        {
            unlink($files_to_delete[$x]);
            $files_to_delete[$x] = 0;
        }
    }

} # end of catctlCleanUp

######################################################################
#
# catctlTimestamp - Record timestamp into registry$log
#
# Description:
#   Record timestamp into registry$log
#
# Parameters:
#   - Timestamp Name (IN)
#   - Inclusion list (IN)
# Returns:
#   None
#
#######################################################################
sub catctlTimestamp
{
    my $pTimestampName = $_[0];     # Timestamp Name
    my $pInclusion = $_[1];         # Inclusion List fro Containers
    my $Sqltimestamp = "SELECT dbms_registry_sys.time_stamp(\'$pTimestampName\') AS timestamp FROM SYS.DUAL";

    if (!$gbInstance)
    {
        catctlQuery($Sqltimestamp, undef);
    }
    else
    {
        catctlQuery($Sqltimestamp, $pInclusion);
    }
}

######################################################################
#
# catctlDatapatch - Call datapatch to install SQL patches
#
# Description:      Calls datapatch in either normal or upgrade mode
#                   to apply or rollback any necessary SQL patches or
#                   bundles.
#
# Parameters:
#   - mode (IN) "normal"    - Apply normal mode patches.
#                             Database opened in normal mode.
#               "upgrade"   - Apply upgrade mode patches.
#                             Database opened in upgrade mode. 
#               "all"       - Apply both normal and upgrade mode
#                             patches.
#                             Database opened in upgrade mode.
#  - User (IN)  pUser        - Username to log into the database.
#  - User (IN)  pUserPass    - Username password
#  - Container  pInclusion   - Current Container
#  - StartTag   startTag     - DP_NOR_BGN/DP_UPG_BGN
#
# Returns:
#   None
#
######################################################################
sub catctlDatapatch
{
  my $mode  = $_[0];         # mode in which to call datapatch
  my $pUser = $_[1];         # Username to log into database
  my $pUserPass = $_[2];     # Password to log into database
  my $pInclusion = $_[3];    # Inclusion List from Containers
  my $startTag   = $_[4];    # DP_NOR_BGN/DP_UPG_BGN
  my $SqlPatchChildPid = 0;  #Sqlpatch Child Pid
  my $SqlPatchUserPass = $pUserPass; # Local Password
  local (*SQLPATCH_STDOUT);  #Handle to stdout/stderr
  local (*SQLPATCH_STDIN);   #Handle to stdin

  # We need to find the location of the sqlpatch perl script sqlpatch.pl.
  # In a shiphome we can do this based on the location of catctl.pl
  # itself, which is ?/rdbms/admin.  But customers may copy this script
  # somewhere else (which we also do in our testing), so if we can't find
  # it based on ?/rdbms/admin then look in the same directory as catctl.pl.
  my $catctl_dir = dirname(File::Spec->rel2abs(__FILE__));

  # First look in ../../sqlpatch
  my $sqlpatch_dir = File::Spec->catdir($catctl_dir,
                                        File::Spec->updir(),
                                        File::Spec->updir(),
                                        "sqlpatch");

  my $sqlpatch_pl = File::Spec->catfile($sqlpatch_dir, "sqlpatch.pl");
  my $sqlpatch_cmd = "";

  #
  # Return if emulating
  #
  if ($gbEmulate)
  {
      return;
  }

  if (-e $sqlpatch_pl) {
    # 18986292: Ensure that $ORACLE_HOME/lib is in LD_LIBRARY_PATH
    # for non Windows systems
    if (!$gbWindows) {
      my $oh_dir = 
        Cwd::realpath(File::Spec->catdir($sqlpatch_dir, File::Spec->updir()));

      my $lib_dir = File::Spec->catfile($oh_dir, "lib");
    
      $sqlpatch_cmd =
        "LD_LIBRARY_PATH=$lib_dir; export LD_LIBRARY_PATH; ";

      # 19178851: Other flavors of unix use different variables, so set
      # those too.  They will do no harm if we are not on those platforms.
      
      # AIX
      $sqlpatch_cmd .=
        "LIBPATH=$lib_dir; export LIBPATH; ";

      # Solaris
      $sqlpatch_cmd .=
        "LD_LIBRARY_PATH_64=$lib_dir; export LD_LIBRARY_PATH_64; ";

      # Darwin
      $sqlpatch_cmd .=
        "DYLD_LIBRARY_PATH=$lib_dir; export DYLD_LIBRARY_PATH; ";
    }

    # 22359063: Include sqlpatch/lib
    my $sqlpatch_lib_dir = File::Spec->catdir($sqlpatch_dir, "lib");

    $sqlpatch_cmd .=
      "$^X -I $catctl_dir -I $sqlpatch_dir -I $sqlpatch_lib_dir $sqlpatch_pl";

  }
  else {
    # Now check in the same directory
    $sqlpatch_pl = File::Spec->catfile($catctl_dir, "sqlpatch.pl");
    if (-e $sqlpatch_pl) {
      # 22359063: Include sqlpatch/lib
      my $lib_dir = File::Spec->catdir($catctl_dir, "lib");

      $sqlpatch_cmd = "$^X -I $catctl_dir -I $lib_dir $sqlpatch_pl";
    }
    else {
      catctlPrintMsg(
        "Could not find sqlpatch.pl in $sqlpatch_dir or\n", $TRUE, $TRUE);
      catctlPrintMsg(
        "$catctl_dir, not installing any SQL patches\n", $TRUE, $TRUE);
      return;
    }
  }

  $sqlpatch_cmd .= " -verbose";

  if ($mode eq "upgrade")
  {
    $sqlpatch_cmd .= " -upgrade_mode_only";
  }

  if ($mode eq "all")
  {
    $sqlpatch_cmd .= " -skip_upgrade_check";
  }

  if ($pUser)
  {
    $sqlpatch_cmd .= " -userid $pUser";
  }

  if ($gbCdbDatabase)
  {
    # Set -pdbs parameter.
    if ($gbSavRootProcessing)
    {
      # 19409212: Quote pdb name to escape dollar signs.
      $sqlpatch_cmd .= " -pdbs '" . $CDBROOT . "'";
    }
    else
    {
      # 19189317: Enclose the pdbs in single quotes to escape any dollar signs
      # in the PDB names.  On Unix the quotes will be absorbed by the shell,
      # on windows they will end up being passed through to sqlpatch, which
      # can handle them.
      $sqlpatch_cmd .= " -pdbs '" . join(',', @AryPDBInstanceList) . "'"
    }
  }

  if (($gbDebugCatcon > 0) || ($giDebugCatctl > 0)) {
    $sqlpatch_cmd .= " -debug";
  }

  # Setup log files
  if (($mode eq "upgrade") || ($mode eq "all"))
  {
     $sqlpatch_cmd .= " > $gsDatapatchLogUpgrade 2> $gsDatapatchErrUpgrade";
  }
  else
  {
     $sqlpatch_cmd .= " > $gsDatapatchLogNormal 2> $gsDatapatchErrNormal";
  }

  # Log the call
  catctlPrintMsg("Calling sqlpatch with $sqlpatch_cmd\n", $TRUE, $FALSE);

  # First save and then remove the SIGCHLD handler installed by catcon
  my $saved_handler = $SIG{CHLD};
  $SIG{CHLD} = 'DEFAULT';

  #
  # Use two-way communcation for Unix to handle passwords
  #
  if (!$gbWindows)
  {

      # Start the child sqlpatch process
      $SqlPatchChildPid = open2(\*SQLPATCH_STDOUT,
                                \*SQLPATCH_STDIN,
                                $sqlpatch_cmd);

      # Make Sure we have a pid
      if ($SqlPatchChildPid)
      {
          # Strip double quotes
          $SqlPatchUserPass =~ tr/"//d;

          # Send Password to child
          print SQLPATCH_STDIN $SqlPatchUserPass;

          # Close stdin we are done here
          close (SQLPATCH_STDIN);

          # Read Stdout/Stderr
          while (<SQLPATCH_STDOUT>)
          {
          }

          # Close Stdout/Stderr
          close (SQLPATCH_STDOUT);

          # Wait for child to complete
          waitpid($SqlPatchChildPid, 0);
      }
      else
      {
          # Print Error messages
          catctlPrintMsg("$MSGWSQLPATCHNOTRUN $!\n", $TRUE, $TRUE);
      }
  } # end if not Windows
  else
  {
      system($sqlpatch_cmd);
  } # Windows

  # Review stderr looking for error during cmd execution
  catctlReviewDPExecution($pInclusion, $startTag);

  # Now restore the original handler
  $SIG{CHLD} = $saved_handler;
  catctlPrintMsg("returned from sqlpatch\n", $TRUE, $FALSE);

  return;

} # end of catctlDatapatch

######################################################################
#
# catctlAutoPhaseTrace - Track phase related information
#
# Description:         - Subroutine will handle information related to each phase 
#                        execution like start time, errors and end time.
#                        It will only track those phases processing sql files.
#                  
#
# Parameters:
#	- Phase number 
#	- DML operation in registry$upg_resume table (INSERT,UPDATE)
#	- Start time only for phase 0
#	- Database name
# Returns:
#   None
#
######################################################################
sub catctlAutoPhaseTrace
{
my $phaseNo=$_[0];
my $tblDML=$_[1];
my $phase0st=$_[2];
my $pInclusion=$_[3];
my $WriteRestart = 0;
my $InstanceVersion=0;
my $phase_errcnt=0;
my $query_phase_errcnt=0;
my $SqlStmts      = "";
my $Sqlver="SELECT version FROM $INSTANCETBL";
my $Sqlerr="SELECT count(1) FROM $ERRORTABLE re, $RESUMETBL  rr WHERE re.timestamp between rr.starttime and rr.endtime and phaseno=$_[0]";

  if ($tblDML eq "I")
  {
        if (!$gbInstance)
	{ 
		$InstanceVersion = "'" . catctlQuery($Sqlver,undef) . "'";
 	}
       else 
	{
	       $InstanceVersion = "'" . catctlQuery($Sqlver,$pInclusion) . "'";
        }

        if ($phaseNo == 0)
        {
        	$WriteRestart =
        	"INSERT INTO $RESUMETBL ".
                "(version, phaseno,errorcnt,starttime,endtime) ".
                "SELECT $InstanceVersion, 0, -1, starttime, starttime from ".
                "$SUMMARYTBL;\n";
        }
        else
        {
        	$WriteRestart =
        	"INSERT INTO $RESUMETBL (version, phaseno,errorcnt,starttime,endtime) VALUES ".
        	"($InstanceVersion, $phaseNo,-1, sysdate, sysdate);\n";
        }
  
        $SqlStmts = $SqlStmts.$WriteRestart;
        $SqlStmts = $SqlStmts.$COMMITCMD;
        $SqlAry[0]=$SqlStmts;

        if (!$gbInstance )
	{
       		 $giRetCode = catctlExecSqlFile(\@SqlAry,0,$gsNoInclusion,$gsNoExclusion,$RUNROOTONLY,$CATCONSERIAL);
  	}
        else
	{
		$giRetCode = catctlExecSqlFile(\@SqlAry,0,$pInclusion,$gsNoExclusion,$RUNEVERYWHERE,$CATCONSERIAL);
	}
	}
  elsif ($tblDML eq "U")
  {
     	$WriteRestart =
       	"UPDATE $RESUMETBL SET endtime=sysdate ".
       	"WHERE phaseno=$phaseNo;\n";

       	$SqlStmts = $SqlStmts.$WriteRestart;
       	$SqlStmts = $SqlStmts.$COMMITCMD;
       	$SqlAry[0]=$SqlStmts;
      	 if (!$gbInstance)
         {
                 $giRetCode = catctlExecSqlFile(\@SqlAry,0,$gsNoInclusion,$gsNoExclusion,$RUNROOTONLY,$CATCONSERIAL);
        	 $query_phase_errcnt = catctlQuery($Sqlerr,undef);
		 if ($query_phase_errcnt)
		 {
		 	$phase_errcnt = $query_phase_errcnt;
		 }

		 $WriteRestart =
        	"UPDATE $RESUMETBL SET errorcnt=$phase_errcnt ".
        	"WHERE phaseno=$phaseNo;\n";

        	$SqlStmts = $SqlStmts.$WriteRestart;
        	$SqlStmts = $SqlStmts.$COMMITCMD;
        	$SqlAry[0]=$SqlStmts;
        	$giRetCode = catctlExecSqlFile(\@SqlAry,0,$gsNoInclusion,$gsNoExclusion,$RUNROOTONLY,$CATCONSERIAL);
         }
         else
         {
                 $giRetCode = catctlExecSqlFile(\@SqlAry,0,$pInclusion,$gsNoExclusion,$RUNEVERYWHERE,$CATCONSERIAL);
                 $query_phase_errcnt = catctlQuery($Sqlerr,$pInclusion);
		 if ($query_phase_errcnt)
                 {
                        $phase_errcnt = $query_phase_errcnt;
                 }

                 $WriteRestart =
                "UPDATE $RESUMETBL SET errorcnt=$phase_errcnt ".
                "WHERE phaseno=$phaseNo;\n";

                $SqlStmts = $SqlStmts.$WriteRestart;
                $SqlStmts = $SqlStmts.$COMMITCMD;
                $SqlAry[0]=$SqlStmts;
                $giRetCode = catctlExecSqlFile(\@SqlAry,0,$pInclusion,$gsNoExclusion,$RUNEVERYWHERE,$CATCONSERIAL);
         }
  }
} #End of catctlAutoPhaseTrace 

#######################################################################
#
# catctlAutoIsRestart - Identifies phase in which an upgrade failed. 
#
# Description:    - Subroutine will identify the lowest phase where
#                   upgrade failed or that phase which didn't finished
#                   (start time = end time). Re-upgrade will start from 
#                   this phase on.
#                   It will return an error message in case upgrade is 
#                   restarted after a successfull upgrade.
#
# Parameters:
#		- Database name
# Returns:
#   - Phase number where upgrade failed.
#   - Error in case re-upgrade is tried on a successful upgrade.
#
#######################################################################
sub catctlAutoIsRestart
{
my $pInclusion=$_[0];
my $Sqlisrestart="SELECT decode(min(phaseno),null,-1,min(phaseno)) FROM $RESUMETBL WHERE (errorcnt !=0 ) ".
                 "or (version=(select version from $INSTANCETBL) and (starttime = endtime) and errorcnt=-1)";
my $Sqlwasupgraded="SELECT count(1) FROM obj\$ where name='REGISTRY\$UPG_RESUME' and owner#=(select user# from user\$ where name= 'SYS')";
my $Sqltblrows="SELECT count(1) FROM $RESUMETBL ";
## In order to manage upgrades successfully without having catctl fail, we need to add the maximum phase.
## Not all phases are tracked in registry$upg_resume, as most of them do not process any scripts, they just run the restart script in 
## preparation for the next phase. For this reason, we need to pass a "fake" phase so that shutdown steps are not performed.
my $SqlmaxphaseNo="SELECT max(phaseno+3) FROM  $RESUMETBL";
my $phaseNo = -1; 
my $tblval = 0;	
my $tblrows = 0;
my $maxphaseNo = -1;
my $sRTInclusion = $gbInstance ? $pInclusion : $gsNoInclusion;

        $tblval  = catctlQuery($Sqlwasupgraded,$sRTInclusion);
        $phaseNo = catctlQuery($Sqlisrestart,$sRTInclusion);
        $tblrows = catctlQuery($Sqltblrows,$sRTInclusion);
        
        if ($tblval == 1)
        {
        	if($phaseNo >=0)
        	{
        		 $phaseNo = abs($phaseNo);
        	 	 return $phaseNo;
        	}
                elsif($tblrows==0)
                {
                        return 0;
                }
                else
                {
                        $maxphaseNo = catctlQuery($SqlmaxphaseNo,$sRTInclusion);
			## We need to manage maximum phase as negative in order to properly print and manage successful scenarios.
                        $maxphaseNo = ($maxphaseNo*-1);
                        return ($maxphaseNo);
                }
       }
       else 
       {
                 catctlPrintMsg("\n** Database $pInclusion has not been upgraded. **",$TRUE,$TRUE);
                 return -2; 
       } 
}#End of catctlAutoIsRestart

######################################################################
#
# catctlAutoRestartMaint  - Maintains registry$upg_resume table 
#
# Description:       - Deletes from registry$upg_resume table the row
#                      of the failed phase (returned by suborutine
#                      catctlIsRestart).
#
# Parameters:
#          - Phase where upgrade failed.
#	   - Database name
#
# Returns:
#   None
#
########################################################################
sub catctlAutoRestartMaint  
{
my $DeleteRestartPhase = 0;
my $phaseNo=$_[0];
my $pInclusion=$_[1];
my $SqlStmts      = "";

        $DeleteRestartPhase= "DELETE $RESUMETBL WHERE phaseno=$phaseNo;\n";
        $SqlStmts = $SqlStmts.$DeleteRestartPhase;
        $SqlStmts = $SqlStmts.$COMMITCMD;
        $SqlAry[0]=$SqlStmts;
        if (!$gbInstance)
	{
        $giRetCode = catctlExecSqlFile(\@SqlAry,0,$gsNoInclusion,$gsNoExclusion,$RUNROOTONLY,$CATCONSERIAL);
        }
	else
	{		
        $giRetCode = catctlExecSqlFile(\@SqlAry,0,$pInclusion,$gsNoExclusion,$RUNEVERYWHERE,$CATCONSERIAL);
	}
}#End of catctlAutoRestartMaint

######################################################################
# 
# catctlScanSessionFiles    -  Scan text lines from catupgrd.sql
#                      
# Description:  -  This function analyze a given line from catupgrd.sql 
#             looking for tags to manage the session arrays and modify
#             the start and stop phases in function of the tags seen
# Parameters:
#   String:   A line of text from catupgrd.sql
#   String:   Name of the actual file
# Returns:
#   None 
#
######################################################################
sub catctlScanSessionFiles {
    my $line = $_[0]; #line to be analyzed
    my $file = $_[1]; #actual script name
    # Process Session Files
    if ($line =~ $CATCTLSESSIONTAG) {
        # If we find a -SES or -SESS tag we will add new values
        # into the arrays, you need to add -SES or -SESS tag if you want
        # add a session duration for a session script
        # session tags usage in front of session files
        # StartSession: [ -SES | -SESS ]
        # EndSession:   [-SESE | <StartSession> ]
        # session tags usage in front of files which are not session files
        # EndSession:   [-SESE ]
        if ($line =~ s/$CATCTLSESSIONTAG\s// or $line =~ $CATCTLSESSTAG ) {
            my $tmpvar = $giUseDir ? "@".$gSrcDir.$SLASH.$file : "@".$file;
            push (@session_files, $tmpvar);            # Session File
            push (@session_start_phase, $#phase_type); # Session Start Phase
            push (@session_stop_phase, 0);             # no Stop Phase
        }
        # If the -SESS tag is found it means that we need to put a mark
        # to know in which element is the one that will be modified
        # in a next iteration
        if ($line =~ $CATCTLSESSTAG) {
            $session_stop_phase[$LASTARYELEMENT]  = $CATCTLSESSTAG;
        }
        # When we found a -SESE, it means that we need to finish the search
        # of a -SESS mark in the array, this give us the chance of end
        # and start session first occurrence in the same line
        if ($line =~ $CATCTLSESETAG) {
            for (1..$#session_stop_phase) {
                if ($session_stop_phase[$_] eq $CATCTLSESSTAG) {
                    # The value we are going to use is the value which is in
                    # the next position where the mark was seen minus one
                    # because we want finish the session before the new
                    # session get started
                    $session_stop_phase[$_] = $session_start_phase[$_+1]-1;
                    # We only want replace the first occurrence of the mark,
                    # the array could have more than one and the second will
                    # belong of a newer phase than the actual
                    last;
                }
            }
        }
    }
}

######################################################################
# 
# catctlGetCIDs    - Installed Componets 
#
# Description:     - Obtains a list of the installed components in
#                    all cobntainers
# Parameters:
#   Array: List of containers to look in
# Returns:
#   Hash:  Hash of arrays where the key is the container name and 
#          the values are the components found
######################################################################
sub catctlGetCIDs {
    # Inlcusion list
    my $pDbName = $_[0];    # Database/Pdb Name
    my $pbInstance = $_[1]; # Pdb Instance

    my @base_cids = @AVAILABLE_CIDS;
    # creation of a components list to restrict the query
    my $listOfCIds = "'".join("','",@base_cids)."'";
    # temporal hash that saves all the components as hash of arrays
    my %AllCmpCID;
    my $Sql="select CID from registry\$ where (CID in($listOfCIds)
     and cid != 'RAC') or (status=1 and cid='RAC')";

    #
    # creation of hash of array of each pdb/database that will be upgraded
    #
    if ($pbInstance)
    {
      # split contents of $pDbName into an array of PDB names
      my @pdbArr = split(/  */, $pDbName);

      foreach my $pdb (@pdbArr) {
        push( @{ $AllCmpCID{$pdb} }, catctlAryQuery($Sql,$pdb) );
      }
    }
    else
    {
        push( @{ $AllCmpCID{$pDbName} }, catctlAryQuery($Sql,undef) );
    }

    return %AllCmpCID;
}

######################################################################
# 
# catctlCmpVerification    - Shows information about the database
#                            componets
# Description:             - This function shows to the user information
#                          about the components found in the database,
#                          it uses a global array that contains all
#                          the list of CID as reference
# Parameters:
#   None
# Returns:
#   None
#
######################################################################
sub catctlCmpVerification {
    my %InstalledCID;   #components installed in the actual container
    my @base_cids = @AVAILABLE_CIDS; 
    # containers name is sorted by name
    foreach my $db_name (sort keys %CIDinstalledCmp) {
        # creating a hash from the array to use a minus between hash
        my %InstalledCID  = map {$_=>1} @{$CIDinstalledCmp{$db_name}};
        my %Allcomponents = map {$_=>1} @base_cids;
        my $InstalledCmps = "";
        my $NotInstalledCmps = "";
        # message that will be shown about components found
        foreach my $cmp (sort keys %Allcomponents) {
            if ($InstalledCID{$cmp}) {
                $InstalledCmps = $InstalledCmps.$cmp." ";
            }else{
                $NotInstalledCmps = $NotInstalledCmps.$cmp." ";
            }
        }

        my $message = "Components in [$db_name]\n";
        catctlPrintMsg($message,$TRUE,$TRUE);
        # sending to output
        if (!$InstalledCmps) {
            $InstalledCmps = "None ";
        }
        $InstalledCmps = substr($InstalledCmps,0,length($InstalledCmps)-1);
        $message = "    Installed [$InstalledCmps]\n";
        catctlPrintMsg($message,$TRUE,$TRUE);
        if (!$NotInstalledCmps) {
            $NotInstalledCmps = "None ";
        }
        $NotInstalledCmps = substr($NotInstalledCmps,0,length($NotInstalledCmps)-1);
        $message = "Not Installed [$NotInstalledCmps]\n";
        catctlPrintMsg($message,$TRUE,$TRUE);
    }
}
######################################################################
##
## catctlValidateList - Validate format of listed PDBs
##
## Description:
##   Validate format of catctl options which accepts a list of pdbs.
##
## Parameters:
##   - List of pdbs
#######################################################################
sub catctlValidateList
{
    my $invlseparator = 0;
    my $pdbList = $_[0];
    # Get out if passing PDBs list separated by comma(,) instead of space.
    if (($invlseparator = index ($pdbList,"\,"))>-1)
    {
     catctlDie("$MSGINVALIDPDBSEPARATOR Exiting.\n");
    }

    #
    # Upper Case, strip off single and double qutoes in lists
    #
    $pdbList = uc($pdbList);
    $pdbList =~ s/^'(.*)'$/$1/;  # strip single quotes
    $pdbList =~ s/^"(.*)"$/$1/;  # strip double quotes
    $pdbList =~ s/^\s+|\s+$//g;  # removing white spaces

    return $pdbList;
}
########################################################################
#
# catctlIsFreshDB - Determine if database was freshly created in current 
#		    version.
# Description:
#   Validate if database was created in current version.
# Parameters:
#       - Container name
# Returns:
#  	- 1 if database is freshly created in current version. No 
#  	  upgrade needed.
#  	- 0 if database comes from previous version. Candidate to be 
#  	  upgraded.
########################################################################
sub catctlIsFreshDB
{
    my $pInclusion=$_[0];
    my $RegistryVersion="";
    my $Sql="SELECT count(1) FROM $REGISTRYTBL r,$INSTANCETBL i WHERE r.version=i.version  and r.cid='CATPROC' and r.prv_version is null";
    #
    ## Send the query and check for a return version.
    ## If version is not returned then database has
    ## not been upgraded.
    ##
    $RegistryVersion = catctlQuery($Sql,$pInclusion);
    if($RegistryVersion)
    {
    	if ($RegistryVersion eq "1")
    	{
            return 1;
    	}
    	else
    	{
            return 0;
    	}
    }
    else
    {
        return 0;
    }
}  # End of catctlIsFreshDB
########################################################################
#
# catctlIsROOTOkay - Was CDB$ROOT freshly created in current release
#
# Description:
#   This routine validates if cdb$root was created in current release,
#   if it was, then cdb$root will not be upgraded as part of upgrade 
#   process.
# Parameters:
#       - Container name
# Returns:
#       - Flag do determine cdb$root upgrade processing
########################################################################
sub catctlIsROOTOkay
{
    my $pContainerName = $_[0];     # Container Name
    my $RetStat        = $TRUE;     # Assume Good
    my $isFreshDB      = 0;         # Is PDB freshly created in current version

    $isFreshDB=catctlIsFreshDB();
    if($isFreshDB == 1 and $gbOverNotUpgrade == 0)
    {
       $RetStat = $FALSE; 
       push(@pAryPDBInstanceFresh,$pContainerName);
    }
    return ($RetStat);
}
########################################################################
#
# catctlIsNonCDBOkay - Was nonCDB freshly created in current release
#
# Description:
#   This routine validates if nonCDB was created in current release,
#   if it was, then database will not be upgraded.
#   process.
# Parameters:
#       - 
# Returns:
#       - Flag do determine if a nonCDB must be uprgaded.
########################################################################
sub catctlIsNonCDBOkay
{
    my $RetStat        = $TRUE;     # Assume Good
    my $isFreshDB      = 0;         # Is PDB freshly created in current version

    if(!$gbCdbDatabase)
    {
      $isFreshDB=catctlIsFreshDB(undef);
      if($isFreshDB == 1 and $gbOverNotUpgrade == 0)
      {
         catctlPrintMsg("\n\n Database $gsDbName is already at version: ".CATCONST_BUILD_VERSION.". No UPGRADE actions are required.\n\n",$TRUE,$TRUE);	
         $RetStat = $FALSE;
      }
    }
    return ($RetStat);
}
########################################################################
#
# catctlReviewDatapatchExecution - Review datapatch execution
#
# Description:
#   This routine review the datapatch's stderr/stdout looking for errors,
#   if there are errors they will be added into registry$error
#
# Parameters:
#       $pInclusion - current container
#       $startTag   - tag to differentiate the execution context
# Returns:
#       -
########################################################################
sub catctlReviewDPExecution
{
   my $pInclusion = $_[0];         # Inclusion List from containers
   my $startTag   = $_[1];         # DP_NOR_BGN/DP_UPG_BGN
   my $insertSql  = "";
   my $SqlStmts = $SETSTATEMENTS;
   #
   # scan logs and save the erros into hashes
   #
   # Look for errors in upgrade mode execution
   if ($startTag eq "DP_UPG_BGN")
   {
      # datapatch stdout
      $insertSql .= catctlprepErrTblInsert('DATAPATCH_UPG',
                                          $gsDatapatchLogUpgrade);
   }
   # Look for errors in normal mode execution
   if ($startTag eq "DP_NOR_BGN")
   {
      # datapatch stdout
      $insertSql .= catctlprepErrTblInsert('POSTUP_DATAPATCH',
                                          $gsDatapatchLogNormal);
   }
   if ($insertSql eq "")
   {
      return;
   }
   #
   # add the commit code
   #
   $SqlStmts = $SqlStmts.$insertSql;
   $SqlStmts = $SqlStmts.$COMMITCMD;
   $SqlAry[0]=$SqlStmts;
   #
   # Execute insert into errors table
   #
   if (!$gbInstance)
   {
      $giRetCode = catctlExecSqlFile(\@SqlAry,
                                     0,
                                     $gsNoInclusion,
                                     $gsNoExclusion,
                                     $RUNROOTONLY,
                                     $CATCONSERIAL);
   }
   else
   {
      $giRetCode = catctlExecSqlFile(\@SqlAry,
                                     0,
                                     $pInclusion,
                                     $gsNoExclusion,
                                     $RUNEVERYWHERE,
                                     $CATCONSERIAL);
   }
}
########################################################################
#
# catctlprepErrTblInsert - Prepare Errors Table Insert
#
# Description:
#   This routine read a stderr/stdout file looking for content, 
#   and builds a insert statement pointing to registry$error
#
# Parameters:
#       $identifier - Identifier for the insertion
#       $sourceFile - File to be scanned
# Returns:
#       Insert SQL
########################################################################
sub catctlprepErrTblInsert
{
   my $identifier = $_[0]; # Identifier for the insertion
   my $sourceFile = $_[1]; # File to be scanned
   my $buffer     = "";    # Content to be inserted
   my $isql       = "";    # Insert SQL
   # checking to see if file has non-zero size.
   if (-e $sourceFile and -s $sourceFile)
   {
      # open the source file and read its content
      open(my $file, $sourceFile);
      while (<$file>)
      {
         # search ORA errors in file
         if ($_ =~ /^ORA\-|^Warning|^SP2|^Error:/)
         {
            $_ =~ tr/^//; # remove ^ from string
            $buffer .= $_;
         }
      }
      close $file;
      # create sql only if the buffer is not empty
      if ($buffer ne "")
      {
         $isql = "insert into $ERRORTABLE (USERNAME, TIMESTAMP,
               SCRIPT, IDENTIFIER, MESSAGE, STATEMENT)
               values ('SYS', SYSDATE, '$sourceFile',
               '$identifier',
               q'^$buffer^', null);\n";
      }
   }
   return $isql;
}
