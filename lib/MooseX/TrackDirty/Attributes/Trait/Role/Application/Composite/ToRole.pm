package MooseX::TrackDirty::Attributes::Trait::Role::Application::Composite::ToRole;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;

Moose::Exporter->setup_import_methods(
    trait_aliases => [
        [ __PACKAGE__, 'CompositeToRole' ],
    ],
);

!!42;
