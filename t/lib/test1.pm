package test1;

use Moose;
use MooseX::TrackDirty::Attributes;
use namespace::autoclean;

has one => (is => 'rw', lazy_build => 1);

sub _build_one { 'sparkley!' }

has lazy => (is => 'rw', lazy_build => 1);



1;
