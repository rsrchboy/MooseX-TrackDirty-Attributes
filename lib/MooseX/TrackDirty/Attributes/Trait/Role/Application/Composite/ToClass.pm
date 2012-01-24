package MooseX::TrackDirty::Attributes::Trait::Role::Application::Composite::ToClass;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;

Moose::Exporter->setup_import_methods(
    trait_aliases => [
        [ __PACKAGE__, 'CompositeToClass' ],
    ],
);

with 'MooseX::TrackDirty::Attributes::Trait::Role::Application::ToClass';

!!42;
