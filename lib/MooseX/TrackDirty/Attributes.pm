package MooseX::TrackDirty::Attributes;

use warnings;
use strict;

use namespace::autoclean;
use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use Carp;

# debugging
use Smart::Comments '###', '####';

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

    has master => (
        is              => 'rw',
        isa             => 'Str',
        lazy_build      => 1,
        is_clear_master => 1,
    );

    my @opts = (
        is => 'ro', isa => 'Str', clear_master => 'master', lazy_build => 1,
    );

    has sub1 => @opts; 
    has sub2 => @opts;
    has sub3 => @opts;

    sub _build_sub1 { shift->master . "1" }
    sub _build_sub2 { shift->master . "2" }
    sub _build_sub3 { shift->master . "3" }

    sub some_sub {
        # ... 

        # clear master, sub[123] in one fell swoop
        $self->clear_master;

    }

=head1 WARNING!

This module should be considered alpha at the moment.  I'm still trying to
figure out the best way to do this -- in particular, tracking attribute status
with a hardcoded base class role feels, well, dirty...  It seems like I should
be able to use L<MooseX::Role::Parameterized> to make this a touch more
flexible.

I'll try to preserve this modules behaviour, but no promises at the moment.

=head1 DESCRIPTION

MooseX::TrackDirty::Attributes does the necessary metaclass fiddling to allow an
clearing one attribute to be cascaded through to other attributes as well,
calling their clearers.  

The intended purpose of this is to assist in situations where the value of one
attribute is derived from the value of another attribute -- say a situation
where the secondary value is expensive to derive and is thus lazily built.  A
change to the primary attribute's value would invalidate the secondary value
and as such the secondary should be cleared.  While it could be argued that
this is trivial to do manually for a few attributes, once we consider
subclassing and adding in roles the ability to "auto-clear", as it were, is
a valuable trait.  (Sorry, couldn't resist.)

=head1 CAVEAT

We don't yet trigger a cascade clear on a master attribute's value being set
through a setter/accessor accessor.  This will likely be available as an
option in the not-too-distant-future.

=head1 ATTRIBUTE OPTIONS

We install an attribute metaclass trait that provides two additional
atttribute options, as well as wraps the generated clearer method for a
designated "master" attribute.  By default, use'ing this module causes this
trait to be installed for all attributes in the package.

=over 4

=item is_clear_master => (0|1)

If set to 1, we wrap this attribute's clearer with a sub that looks for other
attributes to clear.

=item clear_master => Str

Marks this attribute as one that should be cleared when the named attribute's
clearer is called.  Note that no checking is done to ensure that the named
master is actually an attribute in the class.

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


=head1 ACKNOWLEDGEMENTS

L<MooseX::AlwaysCoerce>, for inspiring me to do this in a slightly more sane
fashion than I was previously.

And of course the L<Moose> team, who have made my life significantly easier
(and more fun!) since 0.17 :)

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
