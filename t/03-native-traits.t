#!/usr/bin/perl
#############################################################################
#
# Author:  Chris Weyl (cpan:RSRCHBOY), <cweyl@alumni.drew.edu>
# Company: No company, personal work
# Created: 10/08/2009
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

03-native-traits.t - test against native attribute helpers 

=head1 DESCRIPTION 

This test exercises...

=head1 TESTS

This module defines the following tests.

=cut

use strict;
use warnings;

use English qw{ -no_match_vars };  # Avoids regex performance penalty

use Test::More; # tests => XX;

use FindBin;
use lib "$FindBin::Bin/lib";

use TestNative;

$SIG{__WARN__} = sub { };

my %traits = %TestNative::traits; 

for my $trait (keys %traits) {

    diag "Testing $trait trait";
    my $isdirty = $trait . '_is_dirty';

    for my $write (@{$traits{$trait}->{write}}) {
        
        my $test = TestNative->new;
        my $method = $trait . '_' . $write;
        ok !$test->$isdirty, "clean before $method";
        eval { $test->$method(2 => 3); };
        ok $test->$isdirty, "dirty after $method";
    }

    for my $write (@{$traits{$trait}->{write_sub}}) {
        
        my $test = TestNative->new;
        my $method = $trait . '_' . $write;
        ok !$test->$isdirty, "clean before $method";
        #eval { $test->$method(sub { }); };
        $test->$method(sub { 1 });
        ok $test->$isdirty, "dirty after $method";
    }

    for my $read (@{$traits{$trait}->{read}}) {

        my $test = TestNative->new;
        my $method = $trait . '_' . $read;
        ok !$test->$isdirty, "clean before $method";
        $test->$method(2);
        ok !$test->$isdirty, "clean after $method";
    }

    for my $read (@{$traits{$trait}->{read_sub}}) {

        my $test = TestNative->new;
        my $method = $trait . '_' . $read;
        ok !$test->$isdirty, "clean before $method";
        $test->$method(sub { });
        ok !$test->$isdirty, "clean after $method";
    }
}

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


