# 
# $Header: rdbms/admin/bulkimport.pl /main/4 2017/08/16 08:55:19 molagapp Exp $
#
# bulkimport.pl
# 
# Copyright (c) 2016, 2017, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      bulkimport.pl - Tool to automate the rman bulk import process 
#
#    DESCRIPTION
#      This script is used to facilitate the bulk import process. 
#      Backup piece files are required to be uploaded to an OPC container
#      prior to running the script.
#
#
#    MODIFIED   (MM/DD/YY)
#    molagapp    08/15/17 - bug 26583495
#    molagapp    06/28/17 - lrg 20003747, use marker option when
#                           scanning through OPC bucket 
#    molagapp    04/14/16 - Creation
# 

use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;     # to parse command line options
use Term::ReadKey;    # to not echo password
use IPC::Open2;       # to perform 2-way communication with SQL*Plus
use File::Spec ();

#function declaration
sub log_msg($);
sub get_login_string ($$$); 
sub opc_validation($$);
sub opc_getobjects($$$$$);
sub opc_get_counts($$);

# set all option vars to 0 to avoid "Use of uninitialized value" errors
 our ($user, $cred, $help, $debug, $host, $prefix, $libdir,
      $configfile, $container, $export, $catalog) = 
      (0) x 11;

# URL constructed for querying OPC files in container
my $opc_url;

# list of file names to be exported
my @export_files;

# full path of libopc.so
my $libpath;

# RMAN pipe handle
my $fh;
my $rh;
my $pid;

# RMAN statment to be executed
my $alloc_stmt; 
my $config_stmt; 
my @export_stmt; 
my @catalog_stmt; 
my $statement_exp;
my $statement_cata;

# return code
my $rc;


# Get Options
GetOptions ("user=s"           => \$user,       # username/[passwd] 
            "credential=s"     => \$cred,       # username/[passwd] 
            "export"           => \$export,     # do export or not 
            "catalog"          => \$catalog,    # do catalog or not 
            "help"             => \$help,       # help page
            "debug"            => \$debug,      # turn on debug
            "host=s"           => \$host,       # host 
            "prefix=s"         => \$prefix,     # file prefix 
            "libdir=s"         => \$libdir,     # directory of libopc.so 
            "configfile=s"     => \$configfile, # path/configfile.ora 
            "container=s"      => \$container   # OPC container name 
           )
     or die("Error in parsing command line arguments\n");

if (!$cred or $help)
{
   pod2usage( -verbose => 99 );
   exit 0;
}

# if export and catalog are not specified
# then do both
if (!$export and !$catalog)
{
   $export  = 1;
   $catalog = 1;
}

if (!$container)
{
   die ("bulkimport.pl: container must be specified\n");
}

if (!$configfile)
{
#Default Unix location:    $ORACLE_HOME/dbs/opc<ORACLE_SID>.ora
#Default Windows location: $ORACLE_HOME\database\opc<ORACLE_SID>.ora
#Support only Unix now
  
   my $dbhome = $ENV{ORACLE_HOME}; 
   my $dbsid = $ENV{ORACLE_SID};

   if (!$dbhome or !$dbsid)
   {
      log_msg("bulkimport.pl: ORACLE_HOME and ORACLE_SID must be specified\n");
      die "bulkimport.pl: Unexpected error encountered; exiting\n";
   }

   $configfile = $dbhome."/dbs/opc".$dbsid.".ora";
}

stat($configfile);

if (! -e _ || ! -r _)
{
   log_msg("bulkimport.pl: OPC configfile $configfile does not exist".
           " or is unreadable\n");
   die "bulkimport.pl: Unexpected error encountered; exiting\n";
}

$cred = get_login_string ($cred,1,'CRED'); 

if ($user)
{
   $user = get_login_string ($user,1,'USER'); 
}
else
{
   $user = "/";
}

if ($libdir)
{
   $libpath= File::Spec->catfile($libdir, "libopc.so");

   stat($libpath);

   if (! -e _ || ! -r _)
   {
      log_msg("bulkimport.pl: OPC library $libpath does not exist or is unreadable\n");
      die "bulkimport.pl: Unexpected error encountered; exiting\n";
   }
}
else
{
   $libpath = "libopc.so";
}

if ($host and $container)
{
   chomp $host;

   if (substr($host, -1) eq "/") 
   {
      chop $host;
   }

   $opc_url = $host."/".$container;
}
#elsif ($domain and $service and $container)
#{
#   $opc_url = "https://$domain.storage.oraclecloud.com/v1/".
#              "$service-$domain/$container";
#   $host    = "https://$domain.storage.oraclecloud.com/v1/".
#              "$service-$domain";
#}
else
{
   log_msg("bulkimport.pl: cannot determine URL to list files\n");
   exit 1;
}

# validate if we can access OPC
$rc = opc_validation($cred, $host);

if ($rc == -1)
{
   log_msg("bulkimport.pl: unable to connect to host $host, quit...\n");
   die;
}

$rc = opc_getobjects($cred, $host, $container,
                     $prefix, \@export_files);

if ($rc == -1)
{
   log_msg("bulkimport.pl: error processing $container\n");
   die;
}

if ($debug) 
{
   log_msg("bulkimport.pl: files to be exported/cataloged:\n");
}

if (!@export_files)
{
   log_msg("bulkimport.pl: no files to be exported/cataloged, exiting\n");
   exit 0;
}
else
{
   if ($debug)
   {
      my $file;
      foreach $file (@export_files)
      {
         log_msg("bulkimport.pl:   $file\n");
      }
   }
}

# start RMAN to perform export/catalog
# $pid = open($fh, "|-", "rman");
$pid = open2($rh, $fh, "rman");

if (!$pid)
{
   log_msg("bulkimport.pl: failed to open pipe to RMAN\n");
   die "bulkimport.pl: Unexpected error encountered; exiting\n";
}

if($debug)
{
   log_msg("bulkimport.pl: opened pipe to RMAN\n");
}

if ($configfile)
{
   if ($container)
   {
      $alloc_stmt = <<"EOF";
      ALLOCATE CHANNEL bulkimport$pid DEVICE TYPE SBT PARMS='SBT_LIBRARY=$libpath, 
      SBT_PARMS=(OPC_PFILE=$configfile, OPC_CONTAINER=$container)';
EOF

      $config_stmt = <<"EOF";
      CONFIGURE CHANNEL DEVICE TYPE SBT PARMS='SBT_LIBRARY=$libpath, 
      SBT_PARMS=(OPC_PFILE=$configfile, OPC_CONTAINER=$container)';
EOF
  }
  else
  {
      $alloc_stmt = <<"EOF";
      ALLOCATE CHANNEL bulkimport$pid DEVICE TYPE SBT PARMS='SBT_LIBRARY=$libpath, 
      SBT_PARMS=(OPC_PFILE=$configfile)';
EOF

      $config_stmt = <<"EOF";
      CONFIGURE CHANNEL DEVICE TYPE SBT PARMS='SBT_LIBRARY=$libpath, 
      SBT_PARMS=(OPC_PFILE=$configfile)';
EOF
  }

}
else
{
      $alloc_stmt = <<"EOF";
      ALLOCATE CHANNEL bulkimport$pid DEVICE TYPE SBT PARMS='SBT_LIBRARY=$libpath'; 
EOF
      $config_stmt = <<"EOF";
      CONFIGURE CHANNEL DEVICE TYPE SBT PARMS='SBT_LIBRARY=$libpath'; 
EOF

}

foreach my $filename (@export_files)
{
   my $tmpstmt1 = "SEND CHANNEL bulkimport$pid 'export backuppiece $filename';\n";
   my $tmpstmt2 = "catalog device type sbt backuppiece '$filename';\n";

   push @export_stmt, $tmpstmt1;
   push @catalog_stmt, $tmpstmt2;
}

#construct statment for export
$statement_exp = "RUN { \n";
$statement_exp = $statement_exp.$alloc_stmt;

foreach (@export_stmt)
{
   $statement_exp = $statement_exp.$_;   
}

$statement_exp = $statement_exp." }\n";

#construct statment for catalog 
$statement_cata = $config_stmt."\n";

foreach (@catalog_stmt)
{
   $statement_cata = $statement_cata.$_;   
}

if ($debug)
{
   if ($export)
   {
      log_msg("bulkimport.pl: RMAN statement to export files:\n");
      log_msg("$statement_exp\n");
   }

   if ($catalog)
   {
      log_msg("bulkimport.pl: RMAN statement to catalog files:\n");
      log_msg("$statement_cata\n");
   }
}

print $fh "CONNECT TARGET $user\n";

if ($export)
{
   log_msg("bulkimport.pl: Starting to export backup files...\n");
   print $fh "$statement_exp\n"; 
}

if ($catalog)
{
   log_msg("bulkimport.pl: Starting to catalog backup files...\n");
   print $fh "$statement_cata\n";
}

print $fh "exit;\n";

close $fh;

if ($debug)
{
   while (<$rh>)
   {
      log_msg("$_\n");
   }
}

close $rh;

waitpid($pid, 0);   #makes your program cleaner

log_msg("bulkimport.pl: Completed\n");

exit 0;

#END OF MAIN


sub log_msg($) {
   my ($LogMsg) = @_;

   print STDERR $LogMsg;
}

sub get_login_string ($$$) {
   my ($user, $hidePasswd, $flag) = @_;

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
         if ($flag eq 'CRED')
         {
            print "Enter OPC Credential Password: ";
         }
         elsif ($flag eq 'USER'){
            print "Enter RMAN User Password: ";
         }
         else
         {
            log_msg("Internal Error: invalid flag\n");
         }

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

      if ($flag eq 'CRED')
      {
         $connect = $user.":".$password;
      }
      elsif ($flag eq 'USER')
      {
         $connect = $user."/".$password;
      }
      else
      {
         log_msg("Internal Error: invalid flag\n");
      }
   }
   else
   {
      $password = undef;
      $connect = undef;
   }

   return $connect;
}

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
      log_msg("bulkimport.pl: opened Reader to query $host metadata\n");
      log_msg("bulkimport.pl: requesting $host\n");
   }

   while (<$head>)
   {
      if ($_ =~ /HTTP\/1.1 (\d+) (.*)/)
      {
         if ($1 >= 400)
         {
            log_msg("bulkimport.pl: HTTPS return code $1\n");
            log_msg("bulkimport.pl: unable to connect to endpoint $host\n");
            $rc = -1;
         }
         else
         {
            if ($debug)
            {
               log_msg("bulkimport.pl: HTTPS return code $1\n");
            }
         }

         last;
      }
   }

   close ($head);

   if ($debug)
   {
      log_msg("bulkimport.pl: closed Reader\n");
   }

   waitpid($pid, 0);

   if ($debug)
   {
      log_msg("bulkimport.pl: waitpid returned\n");
   }

   return $rc;
}

sub opc_get_counts($$) {
   my ($cred, $opc_url) = @_;

   my $objcount = 0;
   my $curl;
   my $pid;
   my $pattern;

   $pattern = "X-Container-Object-Count:";

      $curl = "curl -u ".$cred." -i -I ".$opc_url;

   $pid = open2(my $head,undef, "$curl");

   if ($debug)
   {
      log_msg("bulkimport.pl: opened Reader to query metadata\n");
      log_msg("bulkimport.pl: requesting $opc_url\n");
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
# opc_getobjects - get the list of objects in OPC containers, 
#                  when prefix arg exists, fill export file list 
#                  with objects prefixed with prefix
#
# Parameters
#   - OPC credential 
#   - OPC host 
#   - container name 
#   - object prefix, if any
#
sub opc_getobjects($$$$$) {
   my ($cred, $host, $container, $objprefix, $export_files) = @_;

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
   my $pid;

   log_msg("bulkimport.pl: scanning files from container $container...\n");

   if ($cred and $host and $container)
   {
      $opc_url = $host."/".$container;
   }
   else
   {
      log_msg("bulkimport.pl: cannot determine URL to list files"
              ." for $container\n");
      return -1;
   }

   # get object counts from the container
   $objcount = opc_get_counts($cred, $opc_url);
   
   if (!$objcount)
   {
      log_msg("bulkimport: Unable to get object count in ".
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

   $remaincount = $objcount;
   $loop = 0;
   $mark = "";

   while (1)
   {
      #bump up loop counter
      $loop++;

      if ($loop > int($objcount/10000) + 2)
      {
         log_msg("bulkimport.pl: exceed max loop ".
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
         log_msg("bulkimport.pl: opened Reader to list files\n");
         log_msg("bulkimport.pl: requesting $opc_url\n");
      }

      $foundobj = 0;

      while (<Reader>)
      {
         $file = $_;
         chomp $file;

         if (substr($file, -1) eq "\r") 
         {
            chop $file;
         }

         # ignore empty line
         if (!$file or $file =~ /^\s+$/)
         { next; }

         # ignore sbtcatalog or filechunks sub dir 
         if ($file =~ /(sbt_catalog|file_chunk|xml)/ or $file !~ /(\w)/)
         { next; }

         $mark = $file;

         # if we reach here, we find some nonempty $file
         $foundobj = 1;

         $remaincount = $remaincount - 1;

         if ($export_files)
         {
           if ($objprefix)
           {
              if ($file =~ /^$objprefix/)
              {
                 push @$export_files, $file;
                 $foundcontent = 1;
                 log_msg("bulkimport.pl:   $file\n") if ($debug);
              }
           }
           else
           {
              push @$export_files, $file;
              $foundcontent = 1;
              log_msg("bulkimport.pl:   $file\n") if ($debug);
           }
         }
      }

      close Reader;

      if ($debug)
      {
         log_msg("bulkimport.pl: closed Reader\n");
      }

      waitpid($pid, 0);   #makes your program cleaner

      if ($debug)
      {
         log_msg("bulkimport.pl: waitpid returned\n");
      }

      if ($remaincount == 0)
      {
         log_msg("bulkimport.pl: scanned all entries in $container\n");
         last;
      }

      if ($foundobj == 0)
      {
         log_msg("bulkimport.pl: scanned all entries in $container\n");
         last;
      }

   } # end of while loop of remaincount

   if ($export_files and !$foundcontent)
   {
      log_msg("bulkimport.pl: no backup files found in $container ".
              "with prefix $objprefix\n");
      return -1;
   }

   return 0;
}


__END__

=pod

=head1 NAME

bulkimport.pl - RMAN client tool for bulk import 
 
=head1 SYNOPSIS

perl bulkimport.pl <option> 
 
=head1 DESCRIPTION

Usage: perl bulkimport.pl  --credential=username[/password]
                           --host=opc_host
                           --container=name_of_container
                          [--export|catalog]
                          [--libdir=libopc_directory]
                          [--configfile=name_of_configfile]
                          [--user=username[/password]]
                          [--prefix=prefix_string]
                          [--debug] 
                          [--help]

     --credential username (optional /password; otherwise prompts for password)
       used to connect to Oracle Public Cloud and perform the bulk import process 

     --host OPC_HOST parameter 

     --container specify the container that contains the files to be exported 
       and cataloged 

   Optional:

     --export|catalog specify the operation that bulkimport.pl will perform, 
       if not specified, then perform both

     --prefix export and catalog files with the specified prefix. If not 
       specified, all files in the container are included

     --libdir the location of OPC libraray, e.g. '$ORACLE_HOME/lib'

     --configfile the name of configuration file including file name and its
       path, e.g. '$ORACLE_HOME/dbs/opctest.ora'

     --user username (optional /password; otherwise prompts for password)
       used to connect to RMAN and perform the bulk import process, default
       to " / " if not specified 

     --help print help information

     --debug turns on production of debugging info while running this script

=head1 NOTE 
     bulkimport.pl currently support Linux/Unix platforms only

=head1 AUTHOR

Written by Lei Xu.


=cut

