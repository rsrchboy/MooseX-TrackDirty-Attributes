#!/usr/bin/perl

# we use a dummy package here and load Moose as well, so we don't have
# complaints about sugar not exporting...

package gimmesugar;

use Test::More tests => 1;
use Moose;

BEGIN {
    use_ok( 'MooseX::TrackDirty::Attributes' );
}

diag( "Testing MooseX::TrackDirty::Attributes $MooseX::TrackDirty::Attributes::VERSION, Perl $], $^X" );
