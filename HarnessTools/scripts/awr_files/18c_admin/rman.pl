# 
# $Header: rdbms/admin/rman.pl /main/3 2017/08/16 08:55:20 molagapp Exp $
#
# rman.pl
# 
# Copyright (c) 2015, 2017, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      rman.pl - RMAN Perl script to be run against databases. 
#
#    DESCRIPTION
#      This script defines subroutines which can be used to execute one or 
#      more RMAN commands or a RMAN script in 
#      - a non-Consolidated Database, 
#      - Root of a Consolidated Database, or
#      - all Containers of a Consolidated Database, or 
#      - a specified Container of a Consolidated Database

#
#    NOTES
#
#
#    MODIFIED   (MM/DD/YY)
#    molagapp    08/15/17 - bug 26583495
#    molagapp    04/10/16 - Add all_instances option 
#    lexuxu      06/09/15 - Creation
# 

#use strict;
#use warnings;
use Pod::Usage;
use rman qw( rmanInit rmanExec rmanWrapUp rmanTest rmanRootonly rmanIgnore 
             rmanFedRoot rmanEZConnect rmanVerbose rmanHostPort rmanAllInst);
use catcon qw( set_catcon_InvokeFrom );
use File::Basename qw();
BEGIN {
  my ($name, $path, $suffix) = File::Basename::fileparse($0);
  push @INC, $path;
} 

use Getopt::Long;      # to parse command line options

# value returned by various subroutines
my $RetCode = 0;

# set all option vars to 0 to avoid "Use of uninitialized value" errors
our ($user, $catalog, $help, $debug, $script_dir, $log_dir, $con_name,
     $excon_name, $numprocess, $parallel, $all_inst, $ez_connect,
     $fed_root, $ignore_pdb, $rootonly, $host, $port, $base, $verbose) =
    (0) x 18;

#Get Options
GetOptions ("user=s"         => \$user,       # username/[passwd] 
            "catalog=s"      => \$catalog,    # catalog username/[passwd]@inst
            "help"           => \$help,       # help page
            "debug"          => \$debug,      # turn on debug
            "verbose"        => \$verbose,    # turn on verbose 
            "directory=s"    => \$script_dir, # script dir to run
            "log=s"          => \$log_dir,    # log dir
            "parallelism=i"  => \$parallel,   # parallelism 
            "numprocess=i"   => \$numprocess, # process number 
            "allinstances"   => \$all_inst,   # use all instances 
            "container=s"    => \$con_name,   # containers to run the script
            "skipcontainer=s"=> \$excon_name, # containers to be excluded
            "ezconnect=s"    => \$ez_connect, # RAC instances
            "federation=s"   => \$fed_root,   # federation root name
            "ignore"         => \$ignore_pdb, # ignore nonexist PDB
            "rootonly"       => \$rootonly,   # run scripts only in ROOT 
            "host=s"         => \$host,       # DB host name
            "port=i"         => \$port,       # DB port number 
            "base=s"         => \$base        # log file base
           )
     or die("Error in parsing command line arguments\n");

if (@ARGV < 1 or $help)
{
   pod2usage( -verbose => 99 );
   exit 0;
}

# indicator of whether we are invoking from catcon or rman 
# that will be used across the script;
# 0 - the script is called from RMAN 
# 1 - the script is called from CATCON 
use constant CATCON_INVOKEFROM_RMAN   => 0;
use constant CATCON_INVOKEFROM_CATCON => 1;
# set mode to rman inside catcon.pm, since we are using utility functions
# in catcon.pm
set_catcon_InvokeFrom(CATCON_INVOKEFROM_RMAN);

# some things must have been specified:
# - base for log file names
# - at least one sqlplus script
die "Base for log file names must be supplied" if !$base;
die "At least one file name must be supplied" if !@ARGV;

# set flag if only run scripts in PDBs 
rmanRootonly($rootonly);

# tell rmanInit whether to ignore non-existent or closed PDBs
rmanIgnore($ignore_pdb);

# pass Federation Root name, if any
rmanFedRoot($fed_root);

# pass EZConnect strings, if any, for use by rmanInit
rmanEZConnect($ez_connect);

# set allinstances flag, if any 
rmanAllInst($all_inst);

# pass Verbose flag, if any, for use by rmanInit
rmanVerbose($verbose);

# set Database host and port, if any
rmanHostPort($host, $port, $debug);

#rmanTest(1);
#exit 0;

$RetCode = rmanInit($user, $script_dir, $log_dir, $base, 0, 
                    $con_name, $excon_name, $numprocess, $parallel,
                    $debug, 0);

if ($RetCode)
{
   die "rman.pl: Unexpected error encountered in rmanInit; exiting\n";
}

# append script names with @; it is important that they have a leading @ 
# since rmanExec uses @ to distinguish script names from RMAN statements
# It is also important that we do not prepend @ to the script arguments, if any
my @Scripts;
my $NextItem; # element of @ARGV being processes
my $LookForArgs;

foreach $NextItem (@ARGV)
{
   if ($debug)
   {
      print STDERR "going over ARGV: NextItem = $NextItem\n";
   }

   if ($NextItem =~ /^--x/)
   {
      if ($debug)
      {
         print STDERR "add statement (".substr($NextItem, 3)." to Scripts\n";
      }

      push @Scripts, substr($NextItem, 3);
      
      # no arguments can be passed to statements
      $LookForArgs = 0;
   }
   elsif ($NextItem =~ /^--p/)
   {
      if (!$LookForArgs)
      {
         die "unexpected script argument ($NextItem) encountered\n";
      }

      if ($debug)
      {
         print STDERR "add script argument string ($NextItem) to Scripts\n";
      }

      push @Scripts, $NextItem;
   }
   else
   {
      if ($debug)
      {
         print STDERR "add script name ($NextItem) to Scripts\n";
      }

      push @Scripts, "@".$NextItem;

      # having seen what looks like a script name, allow for arguments
      $LookForArgs = 1; 
   }
}

# Execute script/statements
$RetCode = rmanExec(@Scripts, 0, $con_name, $excon_name);

if ($RetCode)
{
   die "rman.pl: Unexpected error encountered in rmanExec; exiting\n";
}

# Cleanup processes and resources
rmanWrapUp();

print STDERR "rman.pl: Completed successfully\n";


__END__

=pod

=head1 NAME

rman.pl - RMAN client tool to run RMAN commands/scripts 
 
=head1 SYNOPSIS

perl rman.pl [<option>] -- {rman-script | --x<RMAN-statement>}
 
=head1 DESCRIPTION

Usage: perl rman.pl [--user=username[/password]]
                    [--directory=directory] [--log=directory] 
                    [{--container |--skipcontainer}=containers] 
                    [--rootonly]
                    [--allinstances]
                    [--numprocess=number-of-processes]
                    [--parallelism=degree-of-parallelism]
                    [--ezconnect=EZConnect string]
                    [--federation=Federation-Root]
                    [--ignore]
                    [--debug] 
                    [--verbose] 
                    [--help]
                     --host=hostname --port=port
                     --base=log-file-name-base 
                     --
                    { rman-script [arguments] | --x<rman-statement> } ...

   Optional:
     --help print help information

     --user username (optional /password; otherwise prompts for password)
       used to connect to the database to run user-supplied scripts or 
       statements
       defaults to "/ as sysdba", if defaults used, secure external password
       store must be specified for each pluggable databases connection strings
       and omitting the user option is not recommended

     --directory  directory containing the script files to be run, defaults
       to the current directory if not specified 

     --log  directory to use for log files, defaults to the current directory
       if not specified

     --container container(s) in which to run RMAN scripts/statements, 
       i.e. skip all Containers not named here; for example, 
       --container='PDB1 PDB2', 

     --skipcontainer container(s) in which NOT to run RMAN scripts/statments, 
       i.e. exclude all Containers named here; for example,
       --skipcontainer='PDB2 PDB3'

       NOTE: --container and --skipcontainer are mutually exclusive

     --ignore instructs rman.pl to ignore non-existent PDBs if 
       --container or --skipcontainer is used
    
     --allinstances use all available RAC instances to perform RMAN tasks 

       NOTE: you have to specify SCAN host name in order to use all instances

     --numprocess expected number of RMAN processes to spawn

     --parallelism expected number of concurrent invocations of this 
       script on a given host

       NOTE: this parameter rarely needs to be specified

     --ezconnect blank-separated EZConnect strings corresponding to 
                 RAC instances which can be used to run scripts/statments

     --federation causes scripts/statements to run in a Federation Root 
       and all Federation PDBs belonging to it; 
       ***CANNOT*** be specified together with {--container, --skipcontainer}
       flags

     --rootonly only execute scripts/statments in CDB$ROOT if the database
       is consolidated

     --debug turns on production of debugging info while running this script

     --verbose turns on verbose mode which is less verbose than debugging mode,
       while running this script 

   Mandatory:

     --host host name that Oracle SQL*NET lisener resides 

     --port port number for Oracle SQL*NET listener 

       NOTE: --host and --port must be specifed together. The parameters
             are mandatory if the database is consolidated. Not required
             for non-consolidated database.

     --base base name (e.g. rman_test) for log and spool file names
        
     RMAN-script     - RMAN script to run OR
     RMAN-statement  - a statement to execute

   NOTES:
     - if --x<RMAN-statement> is the first non-option string, it needs to be 
       preceded with -- to avoid confusing module parsing options into 
       assuming that '-' is an option which that module is not expecting and 
       about which it will complain
     - command line parameters to RMAN scripts can be introduced using --p

     For example,
       perl rman.pl ... x.dat "--pJohn" 

=head1 NOTE

=head1 AUTHOR

Written by Lei Xu.

=cut
