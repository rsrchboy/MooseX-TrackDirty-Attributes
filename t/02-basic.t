
use strict;
use warnings;

{
    package TestClass;

    use Moose;
    use MooseX::TrackDirty::Attributes;
    use namespace::autoclean;

    has one => (
        traits     => [TrackDirty],
        is         => 'rw',

        original_value => 'original_value_of_one',
    );

    sub _build_one { 'sparkley!' }

    has lazy => (is => 'rw', lazy_build => 1);

}

use Test::More 0.92;
use Test::Moose;

with_immutable {

    my $one = TestClass->new();

    ok !$one->one_is_dirty, 'one is not dirty yet';
    is $one->original_value_of_one, undef, 'no original value yet';

    $one->one('Set!');

    ok !$one->one_is_dirty, 'one is not dirty yet';
    is $one->original_value_of_one, undef, 'no original value yet';

    $one->one('And again!');

    ok $one->one_is_dirty, 'one is dirty';
    is $one->original_value_of_one, 'Set!', 'original value is correct';

} 'TestClass';

done_testing;
