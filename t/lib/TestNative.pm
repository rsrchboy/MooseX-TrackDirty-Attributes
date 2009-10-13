package TestNative;

# Test the native attribute helper traits available in recent Moose.

use Moose 0.90;
use MooseX::TrackDirty::Attributes;
use namespace::autoclean;

our %traits = (
    hash => {
        read      => [ qw{ elements count is_empty get keys exists defined values kv } ],
        read_sub  => [ ],
        write     => [ qw{ set delete clear } ],
        write_sub => [ ], 
    },
    array => {
        read      => [ qw{ count is_empty elements get shuffle } ],
        read_sub  => [ qw{ sort map grep first reduce } ],
        write     => [ qw{ push pop unshift shift set clear insert splice delete } ],
        write_sub => [ qw{ sort_in_place } ],
    },
);

sub handles {
    my ($class, $trait) = @_; 

    my @keys;
    push @keys, @{$traits{$trait}->{$_}} for (qw{read write read_sub write_sub});
    my %handles = map { $trait . '_' . $_ => $_ } @keys;

    return \%handles;
}

has 'hash' => (
    traits    => ['Hash'],
    is        => 'ro',
    isa       => 'HashRef[Str]',
    lazy_build => 1,
    handles => __PACKAGE__->handles('hash'),
);

sub _build_hash { { 2 => 'two', foo => 1, bar => 'baz' } }

has 'array' => (
   traits     => ['Array'],
   is         => 'ro',
   isa        => 'ArrayRef',
   lazy_build => 1,
   handles => __PACKAGE__->handles('array'),
);

sub _build_array { [ 1, 2, 'three', 'four' ] }

__PACKAGE__->meta->make_immutable;

1;
