use strict;
use warnings;

use Test::More skip_all => 'native traits not supported (yet?)';

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
