#!/usr/local/bin/perl
# 
# $Header: rdbms/admin/catcon.pl /st_rdbms_18.0/2 2018/04/10 16:11:06 aime Exp $
#
# catcon.pl
# 
# Copyright (c) 2011, 2017, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      catcon.pl - CONtainer-aware Perl script for creating/upgrading CATalogs
#
#    DESCRIPTION
#      This script uses subroutines defined in catcon.pm to execute specified 
#      SQL*Plus scripts and/or SQL statements in 
#      - a non-CDB, 
#      - all Containers of a CDB, or 
#      - specified Containers of a CDB
#
#    NOTES
#      Single quotes get stripped on Linux but not on Windows, but double 
#      quotes get stripped on both, so if you want to quote a value of an 
#      argument to a SQL*Plus script, --p"param" should be used, rather than 
#      --p'param'.  
#
#      If the argument needs to be quoted (e.g. because it contains blanks), 
#      it must be passed like this: --p"''param with blanks''".  Shell will 
#      strip off double quotes and catcon will wrap parameter in another set 
#      of single quotes which will get stripped off by SQL*Plus, and the 
#      remaining pairs of single quotes will be treated as an escaped single 
#      quote.
#
#    MODIFIED   (MM/DD/YY)
#    akruglik    09/11/17 - Bug 26533232: if the caler has supplied name of env
#                           var containig password, set an appropriate catcon
#                           env var to its value
#    akruglik    07/07/17 - LRG 20422036: catconInit and catconInit2 need to
#                           receive script argument tag by reference so that
#                           they can return a default value to the caller if no
#                           value was provided by the caller
#    akruglik    06/14/17 - Bug 26135561: allow caller to specify path to
#                           sqlplus
#    akruglik    04/20/17 - Bug 25507396: add support for ezconn_to_pdb 
#                           option
#    akruglik    01/31/17 - Bug 25392172: getting rid of debug and verbose
#                           flags in catcon.pm
#    akruglik    11/14/16 - Add --upgrade option
#    akruglik    11/14/16 - Bug 20193612: add --all_instances option
#    akruglik    11/04/16 - XbranchMerge akruglik_cloud_fixup from
#                           st_rdbms_12.2.0.1.0cloud
#    akruglik    10/29/16 - Bug 19525930: clean up catcon code
#    akruglik    09/09/16 - Add support for --force_pdb_mode
#    akruglik    07/21/16 - XbranchMerge akruglik_lrg-19633516 from
#                           st_rdbms_12.2.0.1.0
#    akruglik    07/18/16 - LRG 19633516 : add -R option to control whether
#                           catcon should recover if a sqlplus process dies
#    akruglik    05/09/16 - Bug 23106360: allow caller to specify mode in which
#                           PDB$SEED should be opened
#    sursridh    04/13/16 - Bug 23020062: Add option to disable lockdown.
#    akruglik    11/10/15 - pass passwords inside env vars to avoid showing
#                           them on the command line
#    akruglik    07/08/15 - Bug 21283461: add a comment on use of quotes with
#                           arguments to scripts and update the description 
#                           of the script
#    akruglik    06/12/15 - Bug 21187142: add -v to produce verbose output
#    akruglik    04/29/15 - Bug 20969508: add a flag to tell catcon to not
#                           report error if certain types of violations are
#                           encountered
#    raeburns    03/11/15 - Project 46656: add Query for per-PDB condition
#    akruglik    07/23/14 - Project 47234: temporarily add support for -F flag
#                           which will cause catcon to run over all Containers
#                           in a Federation name of whose Root is passed with
#                           the flag
#    akruglik    05/12/14 - Bug 18745291: produce progress messages
#    akruglik    04/17/14 - Update a comment accompanying value of PDB$SEED
#                           mode being pased to catconInit
#    akruglik    04/09/14 - add a comment describing the -r flag
#    akruglik    04/02/14 - Bug 18488530: make sure pdb$seed is OPEN in READ
#                           ONLY mode if the catcon process gets killed
#    akruglik    03/20/14 - add support for -z flag used to supply EZConnect 
#                           strings corresponding to RAC instances which 
#                           should be used to run scripts
#    akruglik    02/24/14 - Bug 18298879: make it possible for catcon.pl to be
#                           invoked from directories besides admin
#    akruglik    01/21/14 - Bug 17898118: rename catconInit.MigrateMode to 
#                           SeedMode and change semantics
#    talliu      01/09/14 - add new option indicate whether catcon is called by
#                           cdb_sqlexec or not
#    akruglik    01/16/14 - Bug 18085409: add -r flag
#    akruglik    01/09/14 - Bug 18029946: handle -f flag
#    akruglik    01/03/14 - Bug 18003416: add support for determining whether a
#                           script ended with an uncommitted transaction
#    jerrede     11/05/13 - Add new Argument (opt_G) for catconInit.
#    akruglik    10/28/13 - Add support for migrate mode indicator
#    akruglik    10/07/13 - Bug 17550069: allow caller to specify -G flag
#    akruglik    07/19/13 - Bug 16603368: add 3 new parameters to the 
#                           interface of catconExec
#    akruglik    05/15/13 - Bug 16603368: add support for -I flag
#    akruglik    10/11/11 - Allow user to optionally specify internal connect
#                           string
#    akruglik    10/04/11 - add suport for running SQL statements
#    akruglik    10/03/11 - clean up Usage comments
#    akruglik    09/20/11 - Add support for specifying multiple containers in
#                           which to run - or not run - scripts
#    akruglik    09/20/11 - make --p and --P the default tags for regular and
#                           secret arguments
#    akruglik    06/30/11 - undo changes from the previous version
#    akruglik    06/10/11 - rename CatCon.pm to catcon.pm because oratst get
#                           macro is case-insensitive
#    akruglik    06/10/11 - set to 0 all vars populated by getopts before
#                           calling getopts so we don't get uninitialized value
#                           errors
#    akruglik    05/26/11 - Make use of subroutines in catcon.pm
#    akruglik    05/11/11 - change container query to fetch from container$;
#                           open pdb$seed read/write; wait for auxiliary 
#                           process to terminate before resetting CHLD signal 
#                           handler
#    akruglik    04/19/11 - add support for specifying ERRORLOGGING
#    akruglik    04/08/11 - add support for SQL script parameters
#    akruglik    02/18/11 - a script to run a SQL script or one or more
#                           statements in 1 or all Containers of a CDB or in a
#                           non-CDB
#    akruglik    02/18/11 - Creation
# 

#use strict "vars";

use File::Basename qw();
BEGIN {
  my ($name, $path, $suffix) = File::Basename::fileparse($0);
  push @INC, $path;
} 

use Getopt::Long;      # to parse command line options

use catcon qw( catconInit catconInit2 catconExec catconWrapUp 
               catconXact catconForce 
               catconReverse catconRevertPdbModes catconEZConnect 
               catconFedRoot catconIgnoreErr catconVerbose 
               catconDisableLockdown catconRecoverFromChildDeath 
               catconPdbMode catconAllInst catconUpgrade catconEZconnToPdb
               catconNoOracleScript);

# value returned by various subroutines
my $RetCode = 0;

sub usageMsg() {
    print STDERR <<USAGE;

  Usage: catcon  [-h, --help]
                 [-u, --usr username
                   [{/password | -w, --usr_pwd_env_var env-var-name}]] 
                 [-U, --int_usr username
                   [{/password | -W, --int_usr_pwd_env_var env-var-name]] 
                 [-d, --script_dir directory] 
                 [-l, --log_dir directory] 
                 [{-c, --incl_con | -C, --excl_con} container] 
                 [-p, --catcon_instances degree-of-parallelism]
                 [-z, --ez_conn EZConnect-strings]
                 [-e, --echo] 
                 [-s, --spool]
                 [-E, --error_logging 
                   { ON | errorlogging-table-other-than-SPERRORLOG } ]
                 [-F, --app_con Application-Root]
                 [-V, --ignore_errors errors-to-ignore ]
                 [-I, --no_set_errlog_ident]
                 [-g, --diag] 
                 [-v, --verbose]
                 [-f, --ignore_unavailable_pdbs]
                 [-r, --reverse]
                 [-R, --recover]
                 [-m, --pdb_seed_mode pdb-mode]
                 [--force_pdb_mode pdb-mode]
                 [--all_instances]
                 [--upgrade]
                 [--ezconn_to_pdb pdb-name]
                 [--sqlplus_dir directory]
                 -b, --log_file_base log-file-name-base 
                 --
                 { sqlplus-script [arguments] | --x<SQL-statement> } ...

   Optional:
     -h, --help 
        print usage info and exit
     -u, --usr 
        username (optional /password; otherwise prompts for password)
        used to connect to the database to run user-supplied scripts or 
        SQL statements
        defaults to "/ as sysdba"
     -w, --usr_pwd_env_var 
        name of environment variable which contains a password for a user 
        whose name was specified with --usr; 
        NOTE: should NOT be used if --usr specified a password
     -U, --int_usr 
        username (optional /password; otherwise prompts for password)
        used to connect to the database to perform internal tasks
        defaults to "/ as sysdba"
     -W, --int_usr_pwd_env_var 
        name of environment variable which contains a password for a user 
        whose name was specified with --int_usr; 
        NOTE: should NOT be used if --int_usr specified a password
     -d, --script_dir 
        directory containing the file to be run 
     -l, --log_dir 
        directory to use for spool log files
     -c, --incl_con
        container(s) in which to run sqlplus scripts, i.e. skip all 
        Containers not named here; for example, 
          --incl_con 'PDB1 PDB2', 
     -C, --excl_con
         container(s) in which NOT to run sqlplus scripts, i.e. skip all 
        Containers named here; for example,
          --excl_con 'CDB$ROOT PDB3'

       NOTE: --incl_con and --excl_con are mutually exclusive

     -p, --catcon_instances 
        expected number of concurrent invocations of this script on a given 
        host

       NOTE: this parameter rarely needs to be specified

     -z, --ez_conn 
        blank-separated EZConnect strings corresponding to RAC instances 
        which can be used to run scripts
     -e, --echo 
        sets echo on while running sqlplus scripts
     -s, --spool 
        output of running every script will be spooled into a file whose name 
        will be 
          <log-file-name-base>_<script_name_without_extension>_[<container_name_if_any>].<default_extension>
     -E, --error_logging 
        sets errorlogging on; if ON is specified, default error logging table
        will be used, otherwise, specified error logging table (which must 
        have been created in every Container) will be used
     -F, --app_con
        causes scripts to run in a Application Root and all Application PDBs
        belonging to it; 
        ***CANNOT*** be specified concurrently with -{cC} flags
     -V, --ignore_errors
        causes catcon to ignore errors encountered during specified operations.
        The following options are supported:
          script_path == ignore errors while validating script path
     -S, --user_scripts
        running user scripts, meaning that _oracle_script will not be set and 
        all entities created by scripts will not be marked as Oracle-maintained
     -I, --no_set_errlog_ident 
        do not issue set Errorlogging Identifier (ostensibly because the 
        caller already did it and does not want us to override it)
     -g, --diag 
        turns on production of diagnostic info while running this script
     -v, --verbose 
        turns on verbose output which is less verbose than debugging output
     -f, --ignore_unavailable_pdbs 
        instructs catcon to ignore PDBs which are closed or, if --incl_con or 
        --excl_con was used, do not exist and process existing PDBs which 
        were specified (explicitly or implicitly) and are open
        
        NOTE: if this flag is not specified and some specified PDBs do not 
              exist or are not open, an error will be returned and none of 
              the Containers will be processed.
      
     -r, --reverse 
        causes scripts to be run in all PDBs and then in the Root (reverse 
        of the default order); required for running catdwgrd.sql in a CDB
     -m, --pdb_seed_mode 
        mode in which PDB$SEED should be opened; one of the following values 
        may be specified:
        - UNCHANGED - leave PDB$SEED in whatever mode it is already open
        - READ WRITE (default)
        - READ ONLY
        - UPGRADE
        - DOWNGRADE

        NOTE: if the desired mode is different from the mode in which 
              PDB$SEED is open, it is will be closed and reopened in the 
              desired mode before running any scripts; after all scripts were 
              run, it will be restored to the original mode

              --pdb_seed_mode should not be specified if --force_pdb_mode 
              is specified because mode supplied with the latter will apply 
              to PDB$SEED
     
     --force_pdb_mode
        mode in which ALL PDBs against which scripts will be run must be 
        opened; one of the following values may be specified:
        - UNCHANGED - leave PDBs in whatever mode they are already 
                      open (default) 
        - READ WRITE
        - READ ONLY
        - UPGRADE
        - DOWNGRADE

        NOTE: if the desired mode is different from the mode in which 
              some of the PDBs specified by the caller are open, they will be 
              closed and reopened in the desired mode before running any 
              scripts; after all scripts were run, they will be restored to 
              the original mode
     
              --force_pdb_mode should not be specified if --pdb_seed_mode
              is specified because mode supplied with the latter will apply 
              to PDB$SEED

     -R, --recover 
        causes catcon to recover from unexpected death of a SQL*Plus process 
        that it spawned; if not specified, such event will cause catcon to die

     -D, --disable_lockdown
       causes catcon to disable lockdown profile before running script(s) in 
       a PDB and reenable them before existing

     --all_instances
       if used to run scripts against a CDB and if --force_pdb_mode was 
       specified, catcon will attempt to run scripts on PDBs using all 
       instances on which a CDB is open

     --upgrade
       catcon is being invoked in the course of upgrading a database

     --ezconn_to_pdb
       caller is expected to provide catcon with one or more EZConnect strings 
       leading to the specified PDB; all specified scripts will be run ONLY 
       against that PDB; neither --incl_con nor --excl_con may be specified 
       concurrentrly with this flag 

     --sqlplus_dir
       directory where sqlplus binary which catcon should use can be found 
       (e.g. if $PATH does not include it or if the caller wants 
       catcon to use a particular version of sqlplus binary)

   Mandatory:
     -b, --log_file_base 
        base name (e.g. catcon_test) for log and spool file names
        
     sqlplus-script - sqlplus script to run OR
     SQL-statement  - a statement to execute

   NOTES:
     - if --x<SQL-statement> is the first non-option string, it needs to be 
       preceeded with -- to avoid confusing module parsing options into 
       assuming that '-' is an option which that module is not expecting and 
       about which it will complain
     - command line parameters to SQL scripts can be introduced using --p
     - interactive (or secret) parameters to SQL scripts can be introduced 
       using --P
     - occupying middle ground between --p and --P, parameters whose values 
       are stored in environment variables can be specified using --e 
       (as in --e"env_var_holding_password")

     For example,
       perl catcon.pl ... x.sql --p"John" --P"Enter Password for John:" ...
     or store John's password in environment variable JOHNS_PASSWORD and 
     then issue
       perl catcon.pl ... x.sql --p"John" --e"JOHNS_PASSWORD" ...

USAGE
    exit 1;
}

if (@ARGV < 1) {
  usageMsg();
}

# set all option vars to 0 to avoid "Use of uninitialized value" errors
our ($optUsr, $optUsrPwdEnvVar, $optIntUsr, $optIntUsrPwdEnvVar, 
     $optScriptDir, $optLogDir, $optLogFileBase, $optInclCon, 
     $optExclCon, $optNumProcs, $optCatconInstances, $optEcho, $optSpool, 
     $optRegArgOpt, $optSecretArgOpt, $optErrorLogging, 
     $optNoSetErrlogIdent, $optDiag, $optVerbose, $optGUI, $optUncommitedTxn, 
     $optIgnoreUnavailablePdbs, $optReverse, $optUserScripts, $optEzConn, 
     $optAppCon, $optIgnoreErrors, $optDisableLockdown, $optPdbSeedMode, 
     $optForcePdbMode, $optRecover, $optAllInst, $optUpgrade,
     $optEzConnToPdb, $optNoOraScript, $optSqlplusDir) = 
  (0) x 36;

# Parse command line arguments
#   NOTE: we are not advertising that the caller may specify number of 
#   processes, but if the caller specifies it anyway, we will use it
# NOTE: if adding more options, add $opt_* vars to the 
#         our () = (0) x <number>;
#       line above and remember to increment the <number>

# options need to be case-sensitive because before going to long option 
# names we had some options (e.g. -D and -d) that differed only by 
# case. 
#
# use reqire_order so non-options do not get mixed with options
Getopt::Long::Configure("no_ignore_case", "require_order");

if (!GetOptions('help|h'       => \&usageMsg,
                'app_con|F=s'  => \$optAppCon,
                'incl_con|c=s' => \$optInclCon,
                'excl_con|C=s' => \$optExclCon,
                'usr|u=s'      => \$optUsr,
                'usr_pwd_env_var|w=s' => \$optUsrPwdEnvVar,
                'int_usr|U=s'  => \$optIntUsr,
                'int_usr_pwd_env_var|W=s' => \$optIntUsrPwdEnvVar,
                'num_procs|n=i' => \$optNumProcs,
                'script_dir|d=s' => \$optScriptDir,
                'log_dir|l=s'    => \$optLogDir,
                'catcon_instances|p=i' => \$optCatconInstances,
                'log_file_base|b=s' => \$optLogFileBase,
                'reg_arg_opt|a=s' => \$optRegArgOpt,
                'secret_arg_opt|A=s' => \$optSecretArgOpt,
                'error_logging|E=s' => \$optErrorLogging,
                'ez_conn|z=s' => \$optEzConn,
                'ignore_errors|V=s' => \$optIgnoreErrors,
                'pdb_seed_mode|m=s' => \$optPdbSeedMode,
                'force_pdb_mode=s' => \$optForcePdbMode,
                'no_set_errlog_ident|I' => $optNoSetErrlogIdent,
                'echo|e' => \$optEcho,
                'spool|s' => \$optSpool,
                'diag|g' => \$optDiag,
                'verbose|v' => \$optVerbose,
                'GUI|G' => \$optGUI,
                'uncommited_txn|X' => \$optUncommitedTxn,
                'ignore_unavailable_pdbs|f' => \$optIgnoreUnavailablePdbs,
                'reverse|r' => \$optReverse,
                'user_scripts|S' => \$optUserScripts,
                'disable_lockdown|D' => \$optDisableLockdown,
                'recover|R' => \$optRecover,
                'all_instances' => \$optAllInst,
                'upgrade' => \$optUpgrade,
                'ezconn_to_pdb=s' => \$optEzConnToPdb,
                'no_ora_script' => \$optNoOraScript,
                'sqlplus_dir=s' => \$optSqlplusDir)) {
  print STDERR "$0: Error encountered while parsing options.\n\n";
  usageMsg();
}


# some things must have been specified:
# - base for log file names
# - at least one sqlplus script
die "Base for log file names must be supplied" if !$optLogFileBase;
die "At least one file name must be supplied" if !@ARGV;

my @PerProcInitStmts = ();
my @PerProcEndStmts = ();

# tell catconInit2 whether to ignore non-existent or closed PDBs
catconForce($optIgnoreUnavailablePdbs); 

# pass EZConnect strings, if any, for use by catconInit2
catconEZConnect($optEzConn);

# pass name of a PDB, if any, to which one or more EZConnect strings would lead
# for use by catconInit2
if ($optEzConnToPdb) {
  catconEZconnToPdb($optEzConnToPdb);
}

# tell catconInit2 that _oracle_script should not be set/cleared
if ($optNoOraScript) {
  catconNoOracleScript();
}

# pass Federation Root name, if any
catconFedRoot($optAppCon);

# if the caller requested that we display messages with log level >= VERBOSE,
# communicate it to catcon module
if ($optVerbose) {
  catconVerbose();
}

# Bug 23020062: Pass disable lockdown flag.
catconDisableLockdown($optDisableLockdown);

# LRG 19633516: pass recover from child process failure flag
catconRecoverFromChildDeath($optRecover);

# tell catcon failure to validate which inputs, if any, can be ignored
if (catconIgnoreErr($optIgnoreErrors)) {
  die "Unexpected error encountered in catconIgnoreErr; exiting\n";
}

# passwords may be specified
# - by specifying -{uU}user/passwd
# - by specifying -{uU]user and passing passwords inside env vars that 
#   catcon.pm knows about
# - by specifying -{uU}user -{wW}password_env_var

# if --usr did not include password and --usr_pwd_env_var was specified, do 
# some sanity checking and copy value of the specified env var into the env 
# var where catconInit expects to find it
if (($optUsr !~ /.*\/.*/) && $optUsrPwdEnvVar) {
  # make sure the env variable was set
  if (! (exists $ENV{$optUsrPwdEnvVar})) {
    die "user password environment variable ".$optUsrPwdEnvVar.
        " specified with --usr_pwd_env_var was undefined\n";
  }

  # Bug 26533232: copy value of supplied env var into env var where 
  # catconInit expects to find it
  $ENV{&catcon::USER_PASSWD_ENV_TAG} = $ENV{$optUsrPwdEnvVar};
}

# if --int_usr did not include password and --int_usr_pwd_env_var was 
# specified, do some sanity checking and copy value of the specified env var 
# into the env var where catconInit expects to find it
if (($optIntUsr !~ /.*\/.*/) && $optIntUsrPwdEnvVar) {
  # make sure the env variable was set
  if (!$ENV{$optIntUsrPwdEnvVar}) {
    die "user password environment variable ".$optIntUsrPwdEnvVar." specified with --int_usr_pwd_env_var was undefined\n";
  }

  # Bug 26533232: copy value of supplied env var into env var where 
  # catconInit expects to find it
  $ENV{&catcon::INTERNAL_PASSWD_ENV_TAG} = $ENV{$optIntUsrPwdEnvVar};
}

# there seems to be no reason to specify both --pdb_seed_mode and 
# --force_open_mode
if ($optPdbSeedMode && $optForcePdbMode) {
  die "at most one of --pdb_seed_mode and --force_open_mode may be ".
      "specified\n";
}

if ($optPdbSeedMode) {
  # if PDB$SEED mode was specified, uppercase it to simplify comparisons
  $optPdbSeedMode = uc $optPdbSeedMode;
} elsif ($optForcePdbMode) {
  # ditto for the mode specified for all PDBs
  $optForcePdbMode = uc $optForcePdbMode;
}

# verify that one of expected modes (or none at all) was specified for ALL PDBs
if (! exists catcon::PDB_STRING_TO_MODE_CONST->{$optForcePdbMode}) {
    die "unexpected value ($optForcePdbMode) specified with ".
        "--force_pdb_mode option\n";
}

# verify that one of expected modes (or none at all) was specified for PDB$SEED
if (! exists catcon::PDB_STRING_TO_MODE_CONST->{$optPdbSeedMode}) {
    die "unexpected value ($optPdbSeedMode) specified with ".
        "--pdb_seed_mode option\n";
}

# tell catconInit2 and catconExec if the caller indicated that ALL relevant 
# PDBs need to be open in a certain mode
#
# NOTE: this subroutine needs to be invoked BEFORE catconInit2 because knowing 
#       that a caller specified that all relevant PDBs need to be open 
#       affects how we handle PDBs that may be closed on some instance at the 
#       time catconInit2 is called and before catconExec actually causes them 
#       to become open.
if ($optForcePdbMode) {
  catconPdbMode(catcon::PDB_STRING_TO_MODE_CONST->{$optForcePdbMode});
}

# let catconInit2 and catconExec know whether the caller has instructed us that
# if we are running against a CDB, we should use all available instances to 
# run scripts against PDBs
catconAllInst($optAllInst);

# pack arguments into a hash and invoke catconInit2
my $argHashRef = 
{
 &catcon::CATCONINIT_ARG_SCRIPT_USER            => $optUsr, 
 &catcon::CATCONINIT_ARG_INTERNAL_USER          => $optIntUsr, 
 &catcon::CATCONINIT_ARG_SCRIPT_DIR             => $optScriptDir, 
 &catcon::CATCONINIT_ARG_LOG_DIR                => $optLogDir, 
 &catcon::CATCONINIT_ARG_LOG_BASE               => $optLogFileBase, 
 &catcon::CATCONINIT_ARG_INCL_CON               => $optInclCon, 
 &catcon::CATCONINIT_ARG_EXCL_CON               => $optExclCon, 
 &catcon::CATCONINIT_ARG_NUM_PROCS              => $optNumProcs, 
 &catcon::CATCONINIT_ARG_EXT_PARALLEL_DEGREE    => $optCatconInstances, 
 &catcon::CATCONINIT_ARG_ECHO_ON                => $optEcho, 
 &catcon::CATCONINIT_ARG_SPOOL_ON               => $optSpool, 
 &catcon::CATCONINIT_ARG_REGULAR_ARG_TAG_REF    => \$optRegArgOpt, 
 &catcon::CATCONINIT_ARG_SECRET_ARG_TAG_REF     => \$optSecretArgOpt, 
 &catcon::CATCONINIT_ARG_ERROR_LOGGING          => $optErrorLogging, 
 &catcon::CATCONINIT_ARG_NO_ERROR_LOGGING_IDENT => $optNoSetErrlogIdent,
 &catcon::CATCONINIT_ARG_PER_PROC_INIT_STMTS    => \@PerProcInitStmts,
 &catcon::CATCONINIT_ARG_PER_PROC_END_STMTS     => \@PerProcEndStmts,
 &catcon::CATCONINIT_ARG_SEED_MODE              => 
     catcon::PDB_STRING_TO_MODE_CONST->{$optPdbSeedMode},
 &catcon::CATCONINIT_ARG_DEBUG_ON               => $optDiag,
 &catcon::CATCONINIT_ARG_GUI                    => $optGUI,
 &catcon::CATCONINIT_ARG_USER_SCRIPTS           => $optUserScripts, 
 &catcon::CATCONINIT_ARG_UPGRADE                => $optUpgrade,
 &catcon::CATCONINIT_ARG_SQLPLUS_DIR            => $optSqlplusDir,
};

$RetCode = catconInit2($argHashRef);

if ($RetCode) {
  die "Unexpected error encountered in catconInit2; exiting\n";
}

if (@ARGV < 1) {
  die "At least one sqlplus script name or SQL statement must be supplied\n";
}

# tell catconExec whether to test for uncommitted transactions at the end of 
# scripts
catconXact($optUncommitedTxn); 

# tell catconExec whether to reverse the usual order in which Containers are 
# being processed (i.e. process all PDBs and then the Root)
catconReverse($optReverse);

# verify that neither regular nor secret argument delimiter starts with --x 
# and so can cause confusion when we try to determine whether a string 
# starting with --x represents a statement to be run or an argument to a 
# preceding script
#
# Bug 22181521: similar check for --e
if ($optRegArgOpt && ($optRegArgOpt =~ /^--x/ || $optRegArgOpt =~ /^--e/)) {
  die "regular argument delimiter may not start with --x or --e\n";
}

if ($optSecretArgOpt && 
    ($optSecretArgOpt =~ /^--x/ || $optSecretArgOpt =~ /^--e/)) {
  die "secret argument delimiter may not start with --x or --e\n";
}

# prepend script names with @; it is important that they have a leading @ 
# since catconExec uses @ to distinguish script names from SQL statements
# It is also important that we do not prepend @ to the script arguments, if any
my @Scripts;
my $NextItem; # element of @ARGV being processes

# if the user supplied regular and/or secret argument delimiters, this 
# variable will be set to true after we encounter a script name to remind 
# us to check for possible arguments
my $LookForArgs = 0;
    
foreach $NextItem (@ARGV) {

  if ($optDiag) {
    print STDERR "going over ARGV: NextItem = $NextItem\n";
  }

  if (   ($optRegArgOpt && $NextItem =~ /^$optRegArgOpt/)
      || ($optSecretArgOpt && $NextItem =~ /^$optSecretArgOpt/)
      || ($NextItem =~ /^--e/)) {
    # looks like an argument to a script; make sure we are actually 
    # looking for script arguments
    if (!$LookForArgs) {
      die "unexpected script argument ($NextItem) encountered\n";
    }

    if ($optDiag) {
      print STDERR "add script argument string ($NextItem) to Scripts\n";
    }

    push @Scripts, $NextItem;
  } elsif ($NextItem =~ /^--x/) {
    if ($optDiag) {
      print STDERR "add statement (".substr($NextItem, 3).") to Scripts\n";
    }

    push @Scripts, substr($NextItem, 3);

    # no arguments can be passed to statements
    $LookForArgs = 0;
  } else {
    
    if ($optDiag) {
      print STDERR "add script name ($NextItem) to Scripts\n";
    }

    push @Scripts, "@".$NextItem;

    # having seen what looks like a script name, allow for arguments, as long 
    # as the user supplied argument delimiter(s)
    $LookForArgs = 1 if ($optRegArgOpt || $optSecretArgOpt);
  }
}

my $ConNamesIncl;
my $ConNamesExcl;
my $CustomErrLoggingIdent;
my $skipProcQuery;

$RetCode = catconExec(@Scripts, 0, 0, 0, $ConNamesIncl, $ConNamesExcl, 
                      $CustomErrLoggingIdent, $skipProcQuery);

if ($RetCode) {
  die "catcon.pl: Unexpected error encountered in catconExec; exiting\n";
}

catconWrapUp();

print STDERR "catcon.pl: completed successfully\n";

END {
  # Bug 18488530: make sure PDB$SEED's mode gets reverted before catcon.pl 
  # process dies
  catconRevertPdbModes();
}

exit 0;
