use strict;
use warnings;

{
    package TestClass;
    use Moose;
    use MooseX::TrackDirty::Attributes;

    has foo => (

        traits  => [ 'String' ],
        is      => 'rw',
        isa     => 'Str',
        default => 'default',
        handles => {

            foo_length => 'length',
            foo_append => 'append',
        },
    );

    has '+foo' => (

        traits  => [ TrackDirty ],
    );
}

use Test::More;
use Test::Moose::More 0.005;

require 't/funcs.pm' unless eval { require funcs };

do_tests();

done_testing;
