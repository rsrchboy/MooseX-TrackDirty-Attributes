package MooseX::TrackDirty::Attributes::Trait::Class;

# ABSTRACT: Attribute metaclass helper metaclass helper trait

use Moose::Role;
use namespace::autoclean;
use MooseX::TrackDirty::Attributes::Util ':all';

# debug...
#use Smart::Comments;

=method add_role_application

This method is extended to ensure that if our attribute metaclass starts doing
a native trait, that our native trait compatibility trait is also applied.

=cut

# ensure that future applications of a native trait will be handled correctly
after add_role_application => sub {
    my ($self, $application) = @_;

    #my @roles = map { $_->name } $self->calculate_all_roles;
    ### @roles

    ### in add_role_application (after)...
    return unless $self->does_role('Moose::Meta::Attribute::Native::Trait');
    return if $self->does_role(TrackDirtyNativeTrait);

    ### applying TrackDirtyNativeTrait to self: $self->name
    TrackDirtyNativeTrait->meta->apply($self);
    return;
};

!!42;
