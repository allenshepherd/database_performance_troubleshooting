#!/usr/local/bin/perl
# $Header: rdbms/admin/catconst.pm
#
# catconst.pm.pp
#
# Copyright (c) 2017, 2018, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      catconst.pm.pp - Declare Build Constants.
#
#    DESCRIPTION
#      catconst.pm is created from catconst.pm.pp by 
#      dbms_registry_make.pl
#
#      catconst.pm declares constants shared by datapatch
#      and upgrade.
#
#    NOTES
#      Currently used for Version Information
#
#    MODIFIED   (MM/DD/YY)
#    surman      04/12/18 - RTI 19714523: Add more version constants
#    raeburns    06/30/17 - Bug 26255427: convert to ".pp" file
#    surman      12/14/15 - 19219946: Add CATCONST_CURRENT_YEAR
#    jerrede     06/25/15 - Generate User Tablespaces SQL
#    jerrede     08/21/14 - Added CATCONST_MAXPDBS
#    jerrede     08/21/14 - Create catconst.pm
#    jerrede     08/21/14 - Creation
#

package catconst;

use strict;
use warnings;
require Exporter;

#
# Export the Constants
#
our @ISA = qw( Exporter );
our @EXPORT = qw( CATCONST_BUILD_VERSION
                  CATCONST_BUILD_STATUS
                  CATCONST_BUILD_LABEL
                  CATCONST_MAXPDBS
                  CATCONST_CURRENT_YEAR 
                  @AVAILABLE_CIDS );

#
# Database Release Version
#
use constant CATCONST_BUILD_VERSION => '18.0.0.0.0';
#
# Database Full Release Version
#
use constant CATCONST_FULL_VERSION => '18.3.1.0.0';
#
# Database Feature Version (first digit)
#
use constant CATCONST_FEATURE_VERSION => 18;
#
# Database RU Version (second digit)
#
use constant CATCONST_RU_VERSION => 3;
#
# Database RUR Version (third digit)
#
use constant CATCONST_RUR_VERSION => 1;
#
# Database Release or Beta Status
#
use constant CATCONST_BUILD_STATUS  => 'Production';
#
# Database Build Label
#
use constant CATCONST_BUILD_LABEL   => 'RDBMS_18.3.0.0.0DBRUR_LINUX.X64_180910';
#
# Max Number of PDBs
#
# obtain from rdbms/include/kgpdb.h
use constant CATCONST_MAXPDBS       => 4098;
#
# Current year as defined by the Makefile
#
use constant CATCONST_CURRENT_YEAR  => 2018;

#
#  Current list of components for upgrade
#
our @AVAILABLE_CIDS = qw(APEX APS CATALOG CATJAVA CATPROC CONTEXT DV JAVAVM OLS ORDIM OWM RAC SDO XDB XML XOQ ODM MGW WK EM);



1;
