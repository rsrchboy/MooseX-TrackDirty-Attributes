package MooseX::TrackDirty::Attributes::Trait::Role;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;
use Moose::Exporter;

use MooseX::TrackDirty::Attributes::Trait::Role::Composite;
use MooseX::TrackDirty::Attributes::Trait::Role::Application::ToClass;

# debugging...
#use Smart::Comments;

Moose::Exporter->setup_import_methods(
    trait_aliases => [
        [ __PACKAGE__, 'MetaRole' ],
    ],
);

requires 'composition_class_roles';

around composition_class_roles => sub {
    my ($orig, $self) = (shift, shift);

    ### in our composition_class_roles()...
    return
        $self->$orig(@_),
        'MooseX::TrackDirty::Attributes::Trait::Role::Composite',
        ;
};

!!42;
