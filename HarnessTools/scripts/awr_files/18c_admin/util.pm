# 
# $Header: rdbms/admin/util.pm /main/1 2016/02/11 20:04:35 hohung Exp $
#
# util.pm
# 
# Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      util.pm - utility module
#
#    DESCRIPTION
#      module of convenient helper functions
#
#    NOTES
#      <other useful comments, qualifications, etc.>
#
#    MODIFIED   (MM/DD/YY)
#    hohung      02/05/16 - Creation
#
package util;

use strict;
use warnings;

# trim whitespaces from both ends
sub trim {
  my $s = shift;
  $s =~ s/^\s+|\s+$//g;
  return $s;
}

# split a string into an array of strings delimited by comma, space, or colon
sub splitToArray {
  my @temp = map(uc, split(/[:,\s]+/, $_[0]));
  return map {trim($_)} @temp;
}

1;
