package MooseX::TrackDirty::Attributes::Trait::Role::Application::Composite::ToRole;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;

use MooseX::TrackDirty::Attributes::Util ':all';

#Moose::Exporter->setup_import_methods(
#    trait_aliases => [
#        [ __PACKAGE__, 'CompositeToRole' ],
#    ],
#);

with
    #'MooseX::TrackDirty::Attributes::Trait::Role::Application::ToRole',
    #'MooseX::TrackDirty::Attributes::Trait::Role::Composite',
    #'MooseX::TrackDirty::Attributes::Trait::Role',
    #ToRole,
    trait_for 'Role',
    ;

!!42;
