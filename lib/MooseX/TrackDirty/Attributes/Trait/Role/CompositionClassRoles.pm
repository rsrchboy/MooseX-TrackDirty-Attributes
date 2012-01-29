package MooseX::TrackDirty::Attributes::Trait::Role::CompositionClassRoles;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;
use Moose::Exporter;

use MooseX::TrackDirty::Attributes::Util ':all';

# debugging...
use Smart::Comments;

around composition_class_roles => sub {
    my ($orig, $self) = (shift, shift);

    ### in our composition_class_roles()...
    return
        $self->$orig(@_),
        'MooseX::TrackDirty::Attributes::Trait::Role::Composite',
        ;
};

!!42;
