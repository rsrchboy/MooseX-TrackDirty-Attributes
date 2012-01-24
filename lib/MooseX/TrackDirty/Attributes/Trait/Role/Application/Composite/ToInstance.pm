package MooseX::TrackDirty::Attributes::Trait::Role::Application::Composite::ToInstance;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;

Moose::Exporter->setup_import_methods(
    trait_aliases => [
        [ __PACKAGE__, 'CompositeToInstance' ],
    ],
);

!!42;
