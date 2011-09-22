=head1 DESCRIPTION

This test exercises the Moose bits (meta, role application, etc).

=cut

use strict;
use warnings;

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

done_testing;
