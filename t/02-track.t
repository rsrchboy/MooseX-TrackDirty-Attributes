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

02-track.t -  

=head1 DESCRIPTION 

This test exercises...

=head1 TESTS

This module defines the following tests.

=cut

use strict;
use warnings;

use English qw{ -no_match_vars };  # Avoids regex performance penalty

use Test::More 0.92;

use FindBin;
use lib "$FindBin::Bin/lib";

use test1;

=head2 testfoo....

=cut

my $one = test1->new;

isa_ok $one, 'test1';
can_ok $one, 'one_is_dirty'; 

ok !$one->one_is_dirty, 'one is not dirty';

$one->one('dirrrrrty');
ok $one->one_is_dirty, 'one is dirty';

$one->clear_one;
ok !$one->one_is_dirty, 'one is not dirty after clearing';

is $one->one, 'sparkley!', 'builds correctly';
ok !$one->one_is_dirty, 'one is not dirty after builing';

done_testing;

__END__

=head1 AUTHOR

Chris Weyl  <cweyl@alumni.drew.edu>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009  <cweyl@alumni.drew.edu>

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


