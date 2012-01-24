package MooseX::TrackDirty::Attributes::Trait::Role::Application::ToClass;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;
use Moose::Exporter;

# debug...
#use Smart::Comments;

use MooseX::TrackDirty::Attributes::Trait::Class;
use MooseX::TrackDirty::Attributes::Trait::Attribute::Native::Trait;

Moose::Exporter->setup_import_methods(
    trait_aliases => [
        [ __PACKAGE__, 'ApplicationToClass' ],
    ],
);

sub trackdirty_native_trait_role { 'MooseX::TrackDirty::Attributes::Trait::Attribute::Native::Trait' }

requires 'apply';

after apply => sub {
    my ($self, $role, $class) = @_;

    ### applying metaroles...
    Moose::Util::MetaRole::apply_metaroles(
        for => $class,
        class_metaroles => {
            class => [ MetaClassTrait ],
        },
    );

    ### check to see if our $class now does the native trait...
    return
        unless $class->does_role('Moose::Meta::Attribute::Native::Trait');

    ### applying to: $class->name 
    TrackDirtyNativeTrait->meta->apply($class);

    return;

    $self
        ->trackdirty_native_trait_role
        ->meta
        ->apply($class)
        ;
};

!!42;
