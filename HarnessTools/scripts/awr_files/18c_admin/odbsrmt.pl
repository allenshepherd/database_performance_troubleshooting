# 
# $Header: rdbms/admin/odbsrmt.pl /main/6 2017/09/28 11:35:38 molagapp Exp $
#
# odbsrmt.pl
# 
# Copyright (c) 2016, 2017, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      odbsrmt.pl - Oracle Database Backup Service Reporting and Maintenance Tool 
#
#    DESCRIPTION
#      This script is used to generate backup reports/and perform
#      maintenance in a easy way. 
#
#
#    MODIFIED   (MM/DD/YY)
#    molagapp    08/15/17 - bug 26583495
#    molagapp    04/26/17 - add support for DEFERED_DELETE
#    molagapp    10/05/16 - bug 25745299 
#    molagapp    10/05/16 - add option to delete backups
#    molagapp    06/14/16 - Creation
# 

use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;     # to parse command line options
use Term::ReadKey;    # to not echo password
use IPC::Open2;       # to perform 2-way communication with SQL*Plus
use XML::Parser;      # to parse XML doc
use File::Spec ();
use Cwd;

# function declaration
sub log_msg($);
sub valid_log_dir($);
sub get_log_file_base_path($$$);
sub get_login_string ($$); 
sub xml_parser($$$); 
sub xml_parser_int($); 
sub opc_validation($$); 
sub opc_get_counts($$$); 
sub opc_getcontainers($$\@);
sub opc_getobjects($$$$$$); 
sub opc_report($$$$$); 
sub opc_delete_file($$$\@); 
sub opc_filter_delete_file(\@\@); 
sub opc_delete($$$); 


# set all option vars to 0 to avoid "Use of uninitialized value" errors
our ($cred, $help, $debug, $host, $prefix,
     $container, $dir, $base, $mode, $dbid, $dbname, $exclude_deferred) = 
     (0) x 12;

# hash for backup metadata
my $DBhash = {};   # global variable used in xml_parser
my $context;       # global variable used in xml_parser
# file path and base name
my $ReportFilePathBase;
# report file handle
my $REPORTOUT;
# script mode
my $report = 0;
my $delete = 0;
# delet list
my @deletelist;
my $rc;

$prefix = "";

# initialize global hash
%$DBhash = ("Dbname"       => "", 
            "Dbid"         => "",
            "FileName"     => "", 
            "FileSize"     => "",
            "LastModified" => "",
            "BackupType"   => "",
            "Incremental"  => "", 
            "Compressed"   => "",
            "Encrypted"    => "",
            "ChunkPrefix"  => "",);
   
# Get Options
GetOptions ("credential=s"     => \$cred,       # username/[passwd] 
            "help"             => \$help,       # help page
            "debug"            => \$debug,      # turn on debug
            "host=s"           => \$host,       # host 
            "prefix=s"         => \$prefix,     # file prefix 
            "container=s"      => \$container,  # OPC container name 
            "dir=s"            => \$dir,        # Dir to store report 
            "base=s"           => \$base,       # report file base name 
            "mode=s"           => \$mode,       # mode of the script 
            "dbid=s"           => \$dbid,       # dbid to delete 
            "dbname=s"         => \$dbname,     # dbname to delete 
            "exclude_deferred" => \$exclude_deferred # ignore backups 
                                                    # in heartbeat xml
           )
     or die("Error in parsing command line arguments\n");

if (!$cred or $help)
{
   pod2usage( -verbose => 99 );
   exit 0;
}

if (!$base)
{
   log_msg("odbsrmt.pl: output file base name must be specified\n");

   pod2usage( -verbose => 99 );
   exit 0;
}

if (!$mode)
{
   log_msg("odbsrmt.pl: mode of the script name must be specified".
           ", either be report or delete\n");

   pod2usage( -verbose => 99 );
   exit 0;
}

if (lc $mode eq lc "report")
{
   $report = 1;
}
elsif (lc $mode eq lc "delete")
{
   $delete = 1;

   if (!$dbname and !$dbid)
   {
      log_msg("odbsrmt.pl: DBNAME or DBID must be specified\n");
      exit 0;
   }
}
else
{
   log_msg("odbsrmt.pl: invalid mode, either be report or delete\n");
   exit 0;
}

$cred = get_login_string ($cred,1); 

#clean host variable a little
chomp $host;

if (substr($host, -1) eq "/") 
{
   chop $host;
}

if ($report)
{
   if (!valid_log_dir($dir))
   {
      log_msg("odbsrmt.pl: unexpeced error from valid_log_dir");
      die;
   }  

   $ReportFilePathBase = 
     get_log_file_base_path($dir, $base, $debug);

   # open report file handle
   if (!open($REPORTOUT, ">>", $ReportFilePathBase.$$.".lst"))
   {
      print STDERR "set_log_file_base_path: unable to open ".$ReportFilePathBase.$$.".lst as REPORTOUT\n";
      die;
   }

   print STDERR "odbsrmt.pl: ALL report output will be written ".
                "to [".$ReportFilePathBase.$$.".lst]\n";

   # make $REPORTOUT"hot" so diagnostic and error message output does not get
   # buffered
   select((select($REPORTOUT), $|=1)[0]);

   # main routine to construct backup metadata report
   opc_report($REPORTOUT, $cred, $host, $container, undef);

   log_msg("odbsrmt.pl: ALL report output has been ".
           "written to [".$ReportFilePathBase.$$.".lst]\n");
   log_msg("odbsrmt.pl: Reporting completed\n");

   close($REPORTOUT);
}
elsif ($delete)
{
   # main routine to construct backup metadata report
   opc_report(undef, $cred, $host, $container, \@deletelist);

   if (!@deletelist)
   {
      log_msg("odbsrmt.pl: no qualifying backups found to delete, ".
              "verify whether Dbname or Dbid is correctly given\n");
      die;
   }

   if (!valid_log_dir($dir))
   {
      log_msg("odbsrmt.pl: unexpeced error from valid_log_dir");
      die;
   }  

   $ReportFilePathBase = 
     get_log_file_base_path($dir, $base, $debug);

   # open report file handle
   if (!open($REPORTOUT, ">", $ReportFilePathBase.$$.".lst"))
   {
      print STDERR "set_log_file_base_path: unable to open ".$ReportFilePathBase.$$.".lst as REPORTOUT\n";
      return 0;
   }

   print STDERR "odbsrmt.pl: ALL file names to be deleted will be written ".
                "to [".$ReportFilePathBase.$$.".lst]\n";

   # make $REPORTOUT"hot" so diagnostic and error message output does not get
   # buffered
   select((select($REPORTOUT), $|=1)[0]);

   if ($dbid)
   {
      opc_delete_file($REPORTOUT, $cred, $host, @deletelist);

      $rc =  opc_delete($cred, $host, $ReportFilePathBase.$$.".lst");

      if ($rc == -1)
      {
         log_msg("odbsrmt.pl: Deletion failed\n");
         die;
      }
   }
   elsif ($dbname and !$dbid)
   {
      my @filterdeletelist = ();

      # since a dbname may correspond to mulptiple dbids, we
      # let the user decide which dbid to delete
      opc_filter_delete_file(@deletelist, @filterdeletelist); 

      if (!@filterdeletelist) 
      {
         log_msg("odbsrmt.pl: No matched file to be deleted, quit...\n");
         die;
      }

      opc_delete_file($REPORTOUT, $cred, $host, @filterdeletelist);

      $rc =  opc_delete($cred, $host, $ReportFilePathBase.$$.".lst");

      if ($rc == -1)
      {
         log_msg("odbsrmt.pl: Deletion failed\n");
         die;
      }
   }
   else
   {
      log_msg("odbsrmt.pl: DBNAME or DBID must be specified\n");
      die;
   }

   log_msg("odbsrmt.pl: ALL file names have been ".
           "written to [".$ReportFilePathBase.$$.".lst]\n");

   log_msg("odbsrmt.pl: Deletion completed\n");

   close($REPORTOUT);
}

exit 0;

#END OF MAIN

###########################################################################
# Helper function starts here
###########################################################################
#
# log_msg - wrapper for log information and debugging output 
#
# Parameters
#   - message string 
sub log_msg($) {
   my ($LogMsg) = @_;

   print STDERR $LogMsg;
}

#
# valid_log_dir - validate the directory for log file 
#
# Parameters
#   - directory of log file 
sub valid_log_dir ($){
   my ($LogDir) = @_;

   if (!$LogDir)
   {
   # no log directory specified - can't complain of it being invalid
      return 1;
   }

   stat($LogDir);

   if (! -e _ || ! -d _) 
   {
      log_msg <<msg;
valid_log_dir: Specified log file directory ($LogDir) does not exist or 
    is not a directory
msg
      return 0;
   }

   if (! -w _) 
   {
      log_msg <<msg;
valid_log_dir: Specified log file directory ($LogDir) is unwritable
msg
    return 0;
   }

   return 1;
}

#
# get_log_file_base_path- construct the full path name of output log file 
#  if log directory is not specified, the current dir is used as default
#
# Parameters
#   - directory of log file 
#   - base name for log file
#   - debug flag 
sub get_log_file_base_path ($$$) {
   my ($LogDir, $LogBase, $DebugOn) = @_;

   if ($LogDir) 
   {
      if ($DebugOn) 
      {
         log_msg <<msg;
get_log_file_base_path: log file directory = $LogDir
msg
      }
   }
   else
   {
      $LogDir = cwd();

      if ($DebugOn) 
      {
         log_msg <<msg;
get_log_file_base_path: no log file directory was specified - using current dirctory ($LogDir)
msg
      }
   }

    return (File::Spec->catfile($LogDir, $LogBase));
}

#
# get_login_string- construct the login credentials to get access 
#                   to OPC containers
#  if the password is not specified explicitly, the user will need
#  to type it manually.
#
# Parameters
#   - OPC credential username/[password]
#   - flag of password hidden indicator 
sub get_login_string ($$) {
   my ($user, $hidePasswd) = @_;

   my $password;
   my $connect;              # assembled connect string for rman
  
   if ($user) 
   {
      if ($user =~ /(.*)\/(.*)/)
      {
         # user/password
         $user = $1;
         $password = $2;
      } 
      else 
      {
         print "Enter OPC Credential Password: ";

         if ($hidePasswd)
         {
            ReadMode 'noecho';
         }

         $password = ReadLine 0;
         chomp $password;
         if ($hidePasswd) 
         {
            ReadMode 'normal';
         }

         print "\n";
      }

      $connect = $user.":".$password;
   }
   else
   {
      $password = undef;
      $connect = undef;
   }

   return $connect;
}

#
# xml_parser - parse metadata.xml into a hash variable for further process.
# parse one xml file in each call. NOte this function is designed specifically
# for OPC metadata.xml since it utilizes the fact that this xml entry is
# recorded in one line so easy to parse. DO NOT try to export this function
# for other parsing purpose.
#
# Parameters
#   - OPC credential
#   - OPC REST end point URL
#   - XML file name
sub xml_parser($$$) {
   my ($cred, $url, $file) = @_;

   my $curlcmd;
   my $line;
   my $pid;
   my $rc;
   my $xmlstring = "";

   if (!$cred or !$url or !$file)
   {
      return -1;
   }
   
   $curlcmd = "curl -u ".$cred." ".$url."/".$file;

   $pid = open2(\*Reader, undef, "$curlcmd");

   if ($debug) 
   {
      log_msg("odbsrmt.pl: opened Reader and Writer\n");
      log_msg("odbsrmt.pl: requesting $url"."/"."$file\n");
   }

   while (<Reader>) 
   {
      $xmlstring .= $_;
   }

   close Reader;

   if ($debug) 
   {
      log_msg("odbsrmt.pl: closed Reader\n");
   }

   waitpid( $pid, 0 );

   $rc = xml_parser_int($xmlstring);

   if ($rc == -1)
   { return -1; }

   return 0;
}

sub xml_parser_int($) {
   my ($xmlstring) = @_;

   my $parser = XML::Parser->new( Handlers => {
                Init =>    undef,
                Final =>   undef,
                Start =>   \&handle_elem_start,
                End =>     \&handle_elem_end,
                Char =>    \&handle_char_data,
                });
 
   $parser->parse($xmlstring);
}

sub handle_elem_start {
    my( $expat, $name, %atts ) = @_;
    $context = $name;
}

sub handle_char_data {
    my( $expat, $text ) = @_;

    $text =~ s/^\s+//g;
    $text =~ s/\s+$//g;

    # !!!note here we are filling xml parsing informtion
    # into global vairable $DBhash, make sure
    # it is initialized and cleared properly
    # before calling xml_parser/xml_parser_int
    $DBhash->{ $context } .= $text;
}

sub handle_elem_end {
    my( $expat, $name ) = @_;
    return; 
}


#
# opc_validation- validate if we can access the endpoint 
#
# Parameters
#   - OPC credential 
#   - OPC host/url 
sub opc_validation($$) {
   my ($cred, $host) = @_;

   my $pid;
   my $curl;
   my $rc = 0;

   #Query OPC metadata for validation first 
   $curl = "curl -u ".$cred." -i -I ".$host;

   $pid = open2(my $head, undef, "$curl");

   if ($debug) 
   {
      log_msg("odbsrmt.pl: opened Reader to query $host metadata\n");
      log_msg("odbsrmt.pl: requesting $host\n");
   }

   while (<$head>) 
   {
      if ($_ =~ /HTTP\/1.1 (\d+) (.*)/)
      {
         if ($1 >= 400)
         {
            log_msg("odbsrmt.pl: HTTPS return code $1\n");
            log_msg("odbsrmt.pl: unable to connect to endpoint $host\n");
            $rc = -1;
         }
         else
         {
            if ($debug)
            {
               log_msg("odbsrmt.pl: HTTPS return code $1\n");
            }
         }

         last;
      }
   }

   close ($head);

   if ($debug) 
   {
      log_msg("odbsrmt.pl: closed Reader\n");
   }

   waitpid($pid, 0);

   if ($debug)
   {
      log_msg("odbsrmt.pl: waitpid returned\n");
   }

   return $rc;

#my $ua = LWP::UserAgent->new(protocols_allowed => ['https'],);
#my $req = HTTP::Request->new(GET => "$host");
#$req->authorization_basic('molagappan.Storageadmin', 'welcome1');
#print $ua->request($req)->as_string;
}


#
# opc_get_counts- get the object/container counts in OPC 
#
# Parameters
#   - OPC credential 
#   - OPC URL 
#   - mode of the function, if mode=1 return container count
#                           if mode=2, return object count 
sub opc_get_counts($$$) {
   my ($cred, $opc_url, $mode) = @_;

   my $objcount = 0;
   my $curl;
   my $pid;
   my $pattern;

   # mode = 1 for getting root statistics for # of containers
   # mode = 2 for getting object counts in certain container 
   if ($mode == 1)
   {
      $pattern = "X-Account-Container-Count:";

   }
   elsif ($mode == 2)
   {
      $pattern = "X-Container-Object-Count:";
   }
   else
   {
      die "odbsrmt.pl: Internal Error. Invalide mode type in opc_get_counts\n";
   }

   #Query OPC metadata to get object counts first
   $curl = "curl -u ".$cred." -i -I ".$opc_url;

   $pid = open2(my $head,undef, "$curl");

   if ($debug) 
   {
      log_msg("odbsrmt.pl: opened Reader to query metadata\n");
      log_msg("odbsrmt.pl: requesting $opc_url\n");
   }

   while (<$head>) 
   {
      if ($_ =~ /$pattern (\d+)/)
      {
         $objcount = $1;
      }
   }

   return  $objcount;
}


#
# opc_getcontainers - get the list of containers in OPC 
#
# Parameters
#   - OPC credential 
#   - OPC host 
#   - list of containers 
sub opc_getcontainers($$\@) {
   my ($cred, $host, $containerarray) = @_;

   my $pid;
   my $curl;
   my $curltemplate;
   my $objcount;
   my $remaincount;
   my $loop;
   my $mark;
   my $containername;

   $objcount = opc_get_counts($cred, $host, 1);

   if (!$objcount)
   {
      log_msg("odbsrmt.pl: Unable to get container count in ".
              "host $host or no container has been created\n");
      exit 0;
   }

   log_msg("odbsrmt.pl: container count = $objcount in ".
           "host $host\n");

   $curltemplate = "curl -u ".$cred." "."\'$host?marker=%s&limit=10000\'";

   $remaincount = $objcount;
   $loop = 0; 
   $mark = "";

   while (1)
   {
      #bump up loop counter
      $loop++;

      if ($loop > int($objcount/10000) + 1)
      {
         log_msg("odbsrmt.pl: exceed max loop ".
                 "count in $host scan\n");
         die;
      }

      $curl = sprintf($curltemplate, $mark);

      $pid = open2(\*Reader, undef, "$curl");

      if ($debug) 
      {
         log_msg("odbsrmt.pl: opened Reader to list containers\n");
         log_msg("odbsrmt.pl: requesting $host\n");
      }

      while (<Reader>) 
      {
         $containername= $_;
         chomp $containername;
         $mark = $containername;

         # ignore empty line
         if (!$containername or $containername =~ /^\s+$/)
         { next; }

         $remaincount = $remaincount - 1;

         # if string has a trailing tab
         if (substr($containername, -1) eq "\r") 
         {
            chop $containername;
         }

         if ($debug)
         {
            log_msg("odbsrmt.pl: found CONTAINER $containername\n");
         }

         push @$containerarray, $containername;
      }

      close Reader;

      if ($debug) 
      {
         log_msg("odbsrmt.pl: closed Reader\n");
      }

      waitpid($pid, 0);   #makes your program cleaner

      if ($debug)
      {
         log_msg("odbsrmt.pl: waitpid returned\n");
      }

      if ($remaincount == 0)
      {
         log_msg("odbsrmt.pl: scanned all containers in $host\n");
         last;
      }

   } # end of while loop of remaincount
}

#
# opc_getobjects - get the list of objects in OPC containers, 
#                  when xmlfiles arg exists, find the xml files and feed
#                  it into a list 
#                  when objlist/objprefix arg exists, fill objlist
#                  with objects prefixed with objprefix
#
# Parameters
#   - OPC credential 
#   - OPC host 
#   - container name 
#   - object prefix, if any
#   - output xml file list, if any 
#   - output object list, if any 
sub opc_getobjects($$$$$$) {
   my ($cred, $host, $container, $objprefix, $xmlfiles, $objlist) = @_;

   my $curl;
   my $curltemplate;
   my $curltemplate_nomarker;
   my $opc_url;
   my $objcount = 0;
   my $remaincount;
   my $loop;
   my $mark;
   my $file;
   my $foundcontent = 0;
   my $foundobj = 0;
   my $foundxml = 0;
   my $include_heartbeat;
   my $pid;

   # xmlfile and $objlist cannot both exist
   if ($xmlfiles and $objlist)
   {
      log_msg("odbsrmt.pl: Internal error, xmlfiles ".
              "and objlist cannot both exist\n");
      die;
   }

   log_msg("odbsrmt.pl: gathering information from container $container...\n");

   if ($cred and $host and $container)
   {
      $opc_url = $host."/".$container;
   }
   else
   {
      log_msg("odbsrmt.pl: cannot determine URL to list files for $container"
              .", try next container...\n");
      return -1;
   }

   # get object counts from the container
   $objcount = opc_get_counts($cred, $opc_url, 2);

   if (!$objcount)
   {
      log_msg("odbsrmt.pl: Unable to get object count in ".
              "container $container or no object has been created\n");
      return -1;
   }

   log_msg("odbsrmt.pl: object count = $objcount in ".
           "container $container\n");

   if ($objprefix)
   {
      $curltemplate = "curl -u ".$cred." ".
                      "\'$opc_url?marker=%s&limit=10000&prefix=$objprefix\'";
      $curltemplate_nomarker = "curl -u ".$cred." ".
                      "\'$opc_url?limit=10000&prefix=$objprefix\'";
   }
   else
   {
      $curltemplate = "curl -u ".$cred." ".
                      "\'$opc_url?marker=%s&limit=10000\'";
      $curltemplate_nomarker = "curl -u ".$cred." ".
                      "\'$opc_url?limit=10000\'";
   }

   # By default, report mode skips heartbeat metadata
   # delete mode includes heartbeat metadata unless
   # exclude_deferred is specified
   if ($report)
   {
      $include_heartbeat = 0;
   }
   elsif ($exclude_deferred)
   {
      $include_heartbeat = 0;
   }
   else
   {
      $include_heartbeat = 1;
   }

   $remaincount = $objcount;
   $loop = 0; 
   $mark = "";

   while (1)
   {
      #bump up loop counter
      $loop++;

      if ($loop > int($objcount/10000) + 2)
      {
         log_msg("odbsrmt.pl: exceed max loop ".
                 "count in $opc_url scan\n");
         die;
      }

      if ($mark)
      {
         $curl = sprintf($curltemplate, $mark);
      }
      else
      {
         $curl = $curltemplate_nomarker;
      }

      $pid = open2(\*Reader, undef, "$curl");

      if ($debug) 
      {
         log_msg("odbsrmt.pl: opened Reader to list XML files\n");
         log_msg("odbsrmt.pl: requesting $opc_url\n");
      }

      $foundobj = 0;

      while (<Reader>) 
      {
         $file = $_;
         chomp $file;

         # ignore empty line
         if (!$file or $file =~ /^\s+$/)
         { next; }

         $mark = $file;

         # if we reach here, we find some nonempty $file
         $foundobj = 1;

         $remaincount = $remaincount - 1;

         if ($xmlfiles)
         {
            # xml files under sbt_catalog
            if (($file !~ /(sbt_catalog\/.*metadata\.xml)/) and
                ($file !~ /(heartbeat\/.*\.xml)/ ))
            { next; }

            if (substr($file, -1) eq "\r") 
            {
               chop $file;
            }

            # if we decide to include heartbeat data
            if ($include_heartbeat)
            {
               # this is global variable prefix input by user
               if ($prefix)
               {
                  if ($file =~ /heartbeat\/.*\/$prefix.*\/.*\.xml/)
                  { 
                     push @$xmlfiles, $file;
                     $foundxml = 1;
                     log_msg("odbsrmt.pl:   $file\n") if ($debug);
                  }
               }
               else
               {
                  if ($file =~ /heartbeat\/.*\.xml/)
                  {
                     push @$xmlfiles, $file;
                     $foundxml = 1;
                     log_msg("odbsrmt.pl:   $file\n") if ($debug);
                  }
               }
            }

            # this is global variable prefix input by user
            if ($prefix)
            {
               if ($file =~ /sbt_catalog\/$prefix.*metadata\.xml/)
               { 
                  push @$xmlfiles, $file;
                  $foundxml = 1;
                  log_msg("odbsrmt.pl:   $file\n") if ($debug);
               }
            }
            else
            {
               if ($file =~ /sbt_catalog\/.*metadata\.xml/)
               {
                  push @$xmlfiles, $file;
                  $foundxml = 1;
                  log_msg("odbsrmt.pl:   $file\n") if ($debug);
               }
            }
         }

         if ($objlist)
         {
           if ($objprefix)
           {
              if ($file =~ /^$objprefix/)
              {
                 push @$objlist, $file;
                 $foundcontent = 1;
                 log_msg("odbsrmt.pl:   $file\n") if ($debug);
              }
           }
           else
           {
              push @$objlist, $file;
              $foundcontent = 1;
              log_msg("odbsrmt.pl:   $file\n") if ($debug);
           }
         }
      }

      close Reader;

      if ($debug) 
      {
         log_msg("odbsrmt.pl: closed Reader\n");
      }

      waitpid($pid, 0);   #makes your program cleaner

      if ($debug)
      {
         log_msg("odbsrmt.pl: waitpid returned\n");
      }

      if ($remaincount == 0)
      {
         log_msg("odbsrmt.pl: scanned all entries in $container\n");
         last;
      }

      if ($foundobj == 0)
      {
         log_msg("odbsrmt.pl: scanned all entries in $container\n");
         last;
      }

   } # end of while loop of remaincount

   if ($xmlfiles and !$foundxml)
   {
      log_msg("odbsrmt.pl: no XML metadata files found in $container".
              "\n");
      return -1;
   }

   if ($objlist and !$foundcontent)
   {
      log_msg("odbsrmt.pl: no backup chunks files found in $container ".
              "with prefix $objprefix\n");
      return -1;
   }

   return 0;
}


#
# opc_report- main function for odbsrmt.pl
#             when mode=report, write output to file handle
#             when mode=delete, create delete list that 
#             contains a list of backup pieces metdata data 
#             By default, report mode skips heartbeat metadata
#             delete mode includes heartbeat metadata unless
#             exclude_deferred is specified
#
# Parameters
#   - output file handle 
#   - OPC credential 
#   - OPC host 
#   - OPC container, can be null 
#   - output list of pre-qualifying metadata for deletion
sub opc_report($$$$$) {
   my ($fh, $cred, $host, $container, $deletelist) = @_;

   my $template = "%-25s%-12s%-15s%-30s%-18s%-28s%-28s%-13s%-13s%-12s\n";
   my $record;
   my $file;
   my $opc_url;
   # meta data xml files 
   my @xmlfiles;
   # container list
   my @containerlist;
   # sum of total storage
   my $totalmb = 0;
   my $totalgb;
   my $include_heartbeat = 0;
   my $rec;
   my $rc;
   my $rc1;
   my $rc2 = -1;

   # By default, report mode skips heartbeat metadata
   # delete mode includes heartbeat metadata unless
   # exclude_deferred is specified
   if ($report)
   {
      $include_heartbeat = 0;
   }
   elsif ($exclude_deferred)
   {
      $include_heartbeat = 0;
   }
   else
   {
      $include_heartbeat = 1;
   }

   if ($fh)
   {
      #print header
      $record = sprintf($template, "Container", "Dbname", "Dbid",
                "FileName", "FileSize", "LastModified",
                "BackupType", "Incremental", "Compressed",
                "Encrypted");

      print $fh $record; 
   }

   # validate if we can access OPC
   $rc = opc_validation($cred, $host);

   if ($rc == -1)
   { 
      log_msg("odbsrmt.pl: unable to connect to host $host, quit...\n");
      die;
   }

   if (!$container)
   {
      opc_getcontainers($cred, $host, @containerlist);
   }
   else
   {
     push @containerlist, $container; 
   }

   if (!@containerlist)
   {
      log_msg("odbsrmt.pl: cannot find any containers to process, quit...");
      die;
   }

   foreach $container (@containerlist)
   {
      # clear previous list
      @xmlfiles = ();

      if ($host and $container)
      {
         $opc_url = $host."/".$container;
      }
      else
      {
         log_msg("odbsrmt.pl: cannot determine URL to list files for".
                 " $container, try next...\n");
         next;
      }

      log_msg("odbsrmt.pl: gathering information from ".
              "container $container...\n");

      $rc1 = opc_getobjects($cred, $host, $container, 
                            "sbt_catalog/".$prefix, \@xmlfiles, undef);

      # by default rc2=-1, such that when heartbeat is not includeded
      # and sbt_catalog/.*.xml does not find anything, error out and 
      # got to next container
      if ($include_heartbeat)
      {
         $rc2 = opc_getobjects($cred, $host, $container, 
                               "heartbeat/", \@xmlfiles, undef);
      }

      if ($rc1 == -1 and $rc2 == -1)
      {
         log_msg("odbsrmt.pl: error processing $container, try next...\n");
         next;
      }

      foreach $file (@xmlfiles)
      {
         # validate file
         $rc = opc_validation($cred, $opc_url."/".$file);
    
         if ($rc == -1)
         { 
            log_msg("odbsrmt.pl: error processing $file, try next...\n");
            next; 
         }

         # clear DBhash
         foreach my $key (keys(%$DBhash))
         {
            $DBhash->{$key} = "";
         }

         $rc = xml_parser($cred, $opc_url, $file);

         if ($rc == -1)
         { 
            log_msg("odbsrmt.pl: error processing $file, try next...\n");
            next; 
         }

         if ($fh)
         {
            $record = sprintf($template, $container, $DBhash->{"Dbname"}, 
                      $DBhash->{"Dbid"}, $DBhash->{"FileName"}, 
                      $DBhash->{"FileSize"}, $DBhash->{"LastModified"},
                      $DBhash->{"BackupType"}, $DBhash->{"Incremental"}, 
                      $DBhash->{"Compressed"}, $DBhash->{"Encrypted"});
   
            print $fh $record; 

            # bump up storage count
            $totalmb = $totalmb + ($DBhash->{"FileSize"}/1024/1024);
         }

         if ($deletelist)
         {
            $rec = {};
            $rec->{"Dbname"} = $DBhash->{"Dbname"};
            $rec->{"Dbid"} = $DBhash->{"Dbid"};
            $rec->{"FileName"} = $DBhash->{"FileName"};
            $rec->{"ChunkPrefix"} = $DBhash->{"ChunkPrefix"}; 
            $rec->{"Container"} = $container; 
            $rec->{"Xmlfile"} = $file; 

            if ($dbname and $dbid)
            {
               if ((lc $dbname eq lc $DBhash->{"Dbname"}) and
                   ($dbid == $DBhash->{"Dbid"}))
               {
                  push @$deletelist, $rec; 
               } 
            }
            elsif ($dbname and !$dbid)
            {
               if (lc $dbname eq lc $DBhash->{"Dbname"})
               {
                  push @$deletelist, $rec; 
               } 
            }
            elsif (!$dbname and $dbid)
            {
               if ($dbid == $DBhash->{"Dbid"})
               {
                  push @$deletelist, $rec; 
               } 
            }
         }
      }
   }

   if ($fh)
   {
      #print total storage information at the end
      #convert to GB
      $totalgb = $totalmb/1024;

      $totalgb = sprintf("%.2f",$totalgb);

      print $fh "Total Storage: $totalgb GB\n";
   }
}


#
# opc_delete_file- write to a file with all the file names to be deleted 
#
# Parameters
#   - output file handle 
#   - OPC credential 
#   - OPC host 
#   - delete list hash 
sub opc_delete_file($$$\@) {
   my ($fh, $cred, $host, $deletelist) = @_;

   my $ref;
   my $containername;
   my $chunkprefix;
   my @objlist;
   my $obj;
   my $filename;
   my $xmlfilename;
   my $rc;

   if (!$fh)
   {
      log_msg("odbsrmt.pl: Internal error, file handle missing\n");
      die;
   }

   # loop through all elements in deletelist, note each element
   # represents a backup piece to be deleted in OPC
   foreach $ref (@$deletelist)
   {
      @objlist = ();
      $containername = $ref->{"Container"};
      $chunkprefix   = $ref->{"ChunkPrefix"};
      $filename      = $ref->{"FileName"};
      $xmlfilename   = $ref->{"Xmlfile"};


      if (!$xmlfilename)
      {
         log_msg("odbsrmt.pl: Internal error, empty xml file name\n");
         die;
      }

      if ($xmlfilename =~ /cleaner.xml/)
      {
         # if heartbeat/cleaner.xml skip it.
         next;
      }
      else
      {
         # include the metadata.xml too
         print $fh "$containername/$xmlfilename\n";
      }

      if (!$chunkprefix)
      {
         log_msg("odbsrmt.pl: warning, ".
                 "empty chunk prefix in ".
                 "$containername/$xmlfilename \n");
      }
      else
      {
         # given chunkprefix, find all the objects and put into objlist
         $rc = opc_getobjects($cred, $host, $containername, 
                              $chunkprefix, undef, \@objlist);

         if ($rc == -1)
         {
            log_msg("odbsrmt.pl: error processing file $filename".
                 " in container $containername, try next...\n");
            next;
         }

         foreach $obj (@objlist)
         {
            print $fh "$containername/$obj\n"; 
         }
      }
   }
}

#
# opc_delete- delete OPC objects listed in the delete file 
#
# Parameters
#   - OPC credential 
#   - OPC host 
#   - delete file name 
sub opc_delete($$$) {
   my ($cred, $host, $filename) = @_;

   my $curl;
   my $pid;
   my $code = 0;

   # curl command to delete 
   $curl = "curl -u ".$cred." -i -X DELETE ".
           " -H \"Content-Type: text/plain\" ".
           " -T $filename "."\'$host?bulk-delete\'";

   $pid = open2(my $head, undef, "$curl");

   if ($debug) 
   {
      log_msg("odbsrmt.pl: opened Reader to delete objects\n");
      log_msg("odbsrmt.pl: requesting $host\n");
   }

   while (<$head>) 
   {
      if ($_ =~ /Response Status: (\d+) (.*)/)
      {
         $code= $1;

         if (!$debug)
         {
            last;
         }
      }

      if ($debug)
      {
         log_msg("odbsrmt.pl: $_");
      }
   }

   close ($head);

   if ($debug) 
   {
      log_msg("odbsrmt.pl: closed Reader\n");
   }

   waitpid($pid, 0);

   if ($debug)
   {
      log_msg("odbsrmt.pl: waitpid returned\n");
   }

   if (!$code)
   {
      log_msg("odbsrmt.pl: cannot get valid response code for ".
              "a delete request\n");
      return -1;
   }
   elsif ($code >= 400)
   {
      log_msg("odbsrmt.pl: error, response code $code for a delete request\n");
      return -1;
   }

   return 0;
}

#
# opc_filter_delete_file- filter delete list, let user choose dbids to delete 
#                         its backup pieces
#
# Parameters
#   - original delete list 
#   - output, filtered delete list 
sub opc_filter_delete_file(\@\@) {
   my ($deletelist, $filterdeletelist) = @_;

   my $ref;
   my %dbidhash;
   my $dbname;
   my $dbid;
   my $read_dbids;
   my @dbid_list;
   my $id;
   my $iter;
   my $tryagain;

   foreach $ref (@$deletelist)
   {
      $dbname = $ref->{"Dbname"};
      $dbid   = $ref->{"Dbid"};
   
      if (!(exists $dbidhash{$dbid}))
      {
         $dbidhash{$dbid} = "";
      }
   }

   log_msg("odbsrmt.pl: LIST OF DBIDs ASSOCIATED WITH DBNAME $dbname:\n");
   foreach my $key (keys %dbidhash)
   {
      log_msg("odbsrmt.pl: $key\n");
   }

   log_msg("\n");

   for ($iter = 1; $iter <= 3; $iter++) 
   {
      log_msg("odbsrmt.pl: Enter DBID YOU WISH TO INCLUDE ".
              "(SPACE SEPARATED, ENTER FOR NONE):\n");

      ReadMode 'normal';

      $read_dbids = ReadLine 0;
      chomp $read_dbids;

      @dbid_list = split(/\s+/, $read_dbids);

      if (!@dbid_list)
      {
         log_msg("odbsrmt.pl: NO DBID WAS PROVIDED, QUIT...\n");
         die;
      }

      $tryagain = 0;

      # validate the dbid_list
      foreach $id (@dbid_list)
      {
         if (!(exists $dbidhash{$id}))
         {
            log_msg("odbsrmt.pl: INVALID DBID=$id PROVIDED, ".
                    "PLEASE TRY AGAIN...\n");

            $tryagain = 1;
         }
      }

      if ($tryagain)
      {
         next;
      }
      else
      {
         last;
      }
   }

   if ($iter == 4)
   {
      log_msg("odbsrmt.pl: EXCEED MAXIMUM TRIAL ATTEMPTS, QUIT...\n");
      die;
   }

   # @dbid_list is what user really wants, now create filter_delte_List
   foreach $ref (@deletelist)
   {
      $dbname = $ref->{"Dbname"};
      $dbid   = $ref->{"Dbid"};

      foreach $id (@dbid_list)
      {
         if ($dbid == $id)
         {
            push @$filterdeletelist, $ref;
            last;
         }
      }
   }
}


__END__

=pod

=head1 NAME

odbsrmt.pl - Oracle Database Backup Service Reporting and Maintenance Tool 
 
=head1 SYNOPSIS

perl odbsrmt.pl <option> 
 
=head1 DESCRIPTION

Usage: perl odbsrmt.pl  --credential=username[/password]
                        --host=opc_host
                        --base=file_base_name
                        --mode=mode_of_script
                        [--dbname=database_name]
                        [--dbid=database_id]
                        [--container=name_of_container]
                        [--dir=directory]
                        [--prefix=prefix_string]
                        [--exclude_deferred]
                        [--debug] 
                        [--help]

     --credential username (optional /password; otherwise prompts for password)
       used to connect to Oracle Public Cloud 

     --host OPC end point 

     --base report/delete file base name

     --mode be either "report" or "delete" 
            report mode lists all metadata information about backup pieces stored
            in OPC.
            delete mode removes certain backup pieces in one operation
            --dbname and/or --dbid must be provided. Backup pieces associated with
            the dbname and/or dbid will be deleted.
            
     Note: you can provide either --dbname or --dbid, or both. If you provide
           --dbname only, a list of dbids associated with the dbname will be 
           prompted. Users will need to choose dbids from the list to proceed.

   Optional:
     --dbname specifies the database name that contains the backup files, for mode=delete

     --dbid   specifies the database ID that contains the backup files, for mode=delete

     --container specifies the container that contains the backup files

     --dir directory where the report or delete file will be stored. If omitted, the current
       directory will be used

     --prefix reports only files with the specified prefix (of the backup piece name). 
       If not specified, all files in the container will be scanned 

     --exclude_deferred ignore backups that are deleted by RMAN when _OPC_DEFERED_BACKUP 
       is set to TRUE but still exists in OPC container
       By default, report mode skips heartbeat metadata while delete mode includes 
       heartbeat metadata unless exclude_deferred is specified

     --help prints help information

     --debug turns on production of debugging info while running this script

=head1 NOTE 
     odbsrmt.pl currently supports Linux/Unix platforms only

=cut

