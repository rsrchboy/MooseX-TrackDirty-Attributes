package MooseX::TrackDirty::Attributes::Trait::Role::Application::ToRole;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;
use Moose::Exporter;

# debug...
#use Smart::Comments;

use MooseX::TrackDirty::Attributes::Trait::Role;
use MooseX::TrackDirty::Attributes::Trait::Attribute::Native::Trait;

Moose::Exporter->setup_import_methods(
    trait_aliases => [
        [ __PACKAGE__, 'ToRole' ],
    ],
);

requires 'apply';

after apply => sub {
    my ($self, $role, $class) = @_;

    ### applying metaroles...
    Moose::Util::MetaRole::apply_metaroles(
        for => $class,
        role_metaroles => {
            role => [ MetaRoleTrait ],
        },
    );

    ### check to see if our $class now does the native trait...
    return
        unless $class->does_role('Moose::Meta::Attribute::Native::Trait');

    ### applying to: $class->name
    TrackDirtyNativeTrait->meta->apply($class);
    return;
};

!!42;
