#!/usr/bin/perl
#############################################################################
#
# Author:  Chris Weyl (cpan:RSRCHBOY), <cweyl@alumni.drew.edu>
# Company: No company, personal work
# Created: 10/06/2009
#
# Copyright (c) 2009  <cweyl@alumni.drew.edu>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
#############################################################################

=head1 NAME

01-moose.t - Test (meta) class construction 

=head1 DESCRIPTION 

This test exercises the Moose bits (meta, role application, etc).

=cut

use strict;
use warnings;

#use English qw{ -no_match_vars };  # Avoids regex performance penalty

use Test::More 0.92;
use Test::Moose;

use FindBin;
use lib "$FindBin::Bin/lib";
use test1; 

my $one = test1->new;

isa_ok $one, 'test1';
meta_ok $one;
does_ok $one, 'MooseX::TrackDirty::Attributes::Role::Class';
has_attribute_ok $one, '__track_dirty';

done_testing 4;

__END__

=head1 AUTHOR

Chris Weyl  <cweyl@alumni.drew.edu>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 Chris Weyl <cweyl@alumni.drew.edu>

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the 

     Free Software Foundation, Inc.
     59 Temple Place, Suite 330
     Boston, MA  02111-1307  USA

=cut


