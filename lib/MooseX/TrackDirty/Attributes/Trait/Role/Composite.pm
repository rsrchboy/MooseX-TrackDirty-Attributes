package MooseX::TrackDirty::Attributes::Trait::Role::Composite;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;

use MooseX::TrackDirty::Attributes::Trait::Role::Application::Composite::ToClass;
use MooseX::TrackDirty::Attributes::Trait::Role::Application::Composite::ToRole;
use MooseX::TrackDirty::Attributes::Trait::Role::Application::Composite::ToInstance;

requires 'apply_params';

around apply_params => sub {
    my ($orig, $self) = (shift, shift);

    Moose::Util::MetaRole::apply_metaroles(
        for            => $self->$orig(@_),
        role_metaroles => {
            application_to_class    => [ CompositeToClass    ],
            application_to_role     => [ CompositeToRole     ],
            application_to_instance => [ CompositeToInstance ],
        },
    );
};


!!42;
