package MooseX::TrackDirty::Attributes;

use warnings;
use strict;

use namespace::autoclean;
use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use Carp;

# debugging
#use Smart::Comments '###', '####';

Moose::Exporter->setup_import_methods;

=head1 NAME

MooseX::TrackDirty::Attributes - Track dirtied attributes 

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Moose;
    use MooseX::TrackDirty::Attributes;

    # one_is_dirty() is generated w/lazy_build
    has one => (is => 'rw', lazy_build => 1);
    
    # dirtyness "accessor" is generated as two_isnt_clean()
    has two => (is => 'rw', default => 'foo', dirty => 'two_isnt_clean');

    # we do not track three's cleanliness
    has three => (is => 'rw', default => 'foo', track_dirty => 0);

    # ...etc

=head1 WARNING!

This module should be considered alpha at the moment.  I'm still trying to
figure out the best way to do this -- in particular, tracking attribute status
with a hardcoded base class role feels, well, dirty...  It seems like I should
be able to use L<MooseX::Role::Parameterized> to make this a touch more
flexible.

I'll try to preserve this modules behaviour, but no promises at the moment.

=head1 DESCRIPTION

MooseX::TrackDirty::Attributes does the necessary metaclass fiddling to track
if attributes are dirty; that is, if they're set to some value not from a
builder, default, or construction.  An attribute can be returned to a clean
state by invoking its clearer.

=head1 CAVEAT

We don't yet trigger a cascade clear on a master attribute's value being set
through a setter/accessor accessor.  This will likely be available as an
option in the not-too-distant-future.

=head1 ATTRIBUTE OPTIONS

We install an attribute metaclass trait that provides two additional
atttribute options, as well as wraps the generated clearer and writer/accessor 
methods of the attribute.  By default, use'ing this module causes this
trait to be installed for all attributes defined in the package.

=over 4

=item track_dirty => (0|1)

If true (the default), we track this attrbutes dirtiness and wrap any
generated clearer, setter or accessor methods.

=item dirty => Str

If set, create a "dirtiness accessor".  Default is to not create one.  If
lazy_build is specified, a method is generated with "foo_is_dirty", where foo
is the attribute name.

=back

=cut

{
    package MooseX::TrackDirty::Attributes::Role::Meta::Attribute;
    use namespace::autoclean;
    use Moose::Role;

    has track_dirty     => (is => 'rw', isa => 'Bool', default => 1);
    has dirty           => (is => 'ro', isa => 'Str',  predicate => 'has_dirty');

    after install_accessors => sub {  
        my ($self, $inline) = @_;

        ### in install_accessors, installing if: $self->track_dirty
        return unless $self->track_dirty;

        my $class = $self->associated_class;
        my $name  = $self->name;

        # our is_dirty "accessor"
        ### is_dirty: $self->dirty || ''
        $class->add_method($self->dirty, sub { shift->_is_dirty($name) }) 
            if $self->has_dirty;

        # if we're cleared, we're clean again
        my $clearer_name = $self->has_clearer ? $self->clearer : 'clear_value';
        $class->add_after_method_modifier(
            $clearer_name => sub { shift->_mark_clean($name) }
        );

        # if we're set, we're dirty (cach both writer/accessor
        $class->add_after_method_modifier(
            $self->writer => sub { shift->_mark_dirty($name) }
        ) if $self->has_writer;
        $class->add_after_method_modifier(
            $self->accessor => 
                sub { $_[0]->_mark_dirty($name) if defined $_[1] }
        ) if $self->has_accessor;

        return;

        #$self->associated_class->add_after_method_modifier($self->clearer, sub { 
    };
}
{
    package MooseX::TrackDirty::Attributes::Role::Meta::Class;
    use namespace::autoclean;
    use Moose::Role;

    around add_attribute => sub {
        my $next = shift;
        my $self = shift;
        my ($what, %opts) = @_;

        ### in class role: $opts{lazy_build}
        $opts{dirty} = $what.'_is_dirty' 
            unless exists $opts{dirty} || !$opts{lazy_build};

        $self->$next($what, %opts);
    };

    #sub get_all_dirty_attributes { warn }
}
{
    package MooseX::TrackDirty::Attributes::Role::Class;
    use namespace::autoclean;
    use Moose::Role;

    has __track_dirty => (
        traits => [ 'Hash' ],
        is      => 'rw',
        isa     => 'HashRef',
        builder => '__build_track_dirty',
        #default => sub { { } },

        handles => {
            _is_dirty             => 'exists',
            _mark_clean           => 'delete',
            _mark_all_clean       => 'clear',
            _has_dirty_attributes => 'count',
            _all_attributes_clean => 'is_empty',
            _dirty_attributes     => 'keys',
            __set_dirty           => 'set',
       },
    );   

    sub __build_track_dirty { { } }
    sub _mark_dirty { shift->__set_dirty(shift, 1) }
}
# can we prevent the clearer from being inlined?  Do we need to?  Are we?

sub init_meta {
    shift;
    my %options = @_;
    my $for_class = $options{for_class};

    ### in init_meta: $options{for_class} 
    Moose->init_meta(%options);

    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class => $options{for_class},
        metaclass_roles =>
            ['MooseX::TrackDirty::Attributes::Role::Meta::Class'],
        attribute_metaclass_roles =>
            ['MooseX::TrackDirty::Attributes::Role::Meta::Attribute'],
    );

    Moose::Util::MetaRole::apply_base_class_roles( 
        for_class => $options{for_class}, 
        roles     => ['MooseX::TrackDirty::Attributes::Role::Class'],
    );

    ### applied traits, returning...
    return $for_class->meta;
}

=head1 AUTHOR

Chris Weyl, C<< <cweyl at alumni.drew.edu> >>

=head1 BUGS

Please report any bugs or feature requests to 
C<bug-moosex-trackdirty-attributes at rt.cpan.org>, or through
the web interface at 
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-TrackDirty::Attributes>.  
I will be notified, and then you'llautomatically be notified of progress 
on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MooseX::TrackDirty::Attributes


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MooseX-TrackDirty::Attributes>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MooseX-TrackDirty::Attributes>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MooseX-TrackDirty::Attributes>

=item * Search CPAN

L<http://search.cpan.org/dist/MooseX-TrackDirty::Attributes/>

=back

=head1 COPYRIGHT & LICENSE

Copyright (c) 2009, Chris Weyl C<< <cweyl@alumni.drew.edu> >>.

This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free 
Software Foundation; either version 2.1 of the License, or (at your option) 
any later version.

This library is distributed in the hope that it will be useful, but WITHOUT 
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
OR A PARTICULAR PURPOSE.

See the GNU Lesser General Public License for more details.  

You should have received a copy of the GNU Lesser General Public License 
along with this library; if not, write to the 

    Free Software Foundation, Inc., 
    59 Temple Place, Suite 330, 
    Boston, MA  02111-1307 USA

=cut

1; # End of MooseX::TrackDirty::Attributes
