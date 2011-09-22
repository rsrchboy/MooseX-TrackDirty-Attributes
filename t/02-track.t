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
ok !$one->one_is_dirty, 'one is not dirty after building';

done_testing;
