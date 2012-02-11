package MooseX::TrackDirty::Attributes::Trait::Class;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;
use MooseX::TrackDirty::Attributes::Util ':all';

# debug...
#use Smart::Comments;

requires 'add_role_application';

# ensure that future applications of a native trait will be handled correctly
after add_role_application => sub {
    my ($self, $application) = @_;

    my @roles = map { $_->name } $self->calculate_all_roles;
    ### @roles

    ### in add_role_application (after)...
    return unless $self->does_role('Moose::Meta::Attribute::Native::Trait');
    return if $self->does_role(TrackDirtyNativeTrait);

    ### applying TrackDirtyNativeTrait to self: $self->name
    TrackDirtyNativeTrait->meta->apply($self);
    return;
};

!!42;
