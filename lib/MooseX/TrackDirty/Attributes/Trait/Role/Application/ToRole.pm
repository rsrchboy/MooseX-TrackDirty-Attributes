package MooseX::TrackDirty::Attributes::Trait::Role::Application::ToRole;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;
use Moose::Util::MetaRole;
use MooseX::TrackDirty::Attributes::Util ':all';

# debug...
#use Smart::Comments;

around apply => sub {
    my ($next, $self, $role1, $role2) = @_;

    ### role1 (source): $role1->name
    ### role2 (target): $role2->name

    $self->$next(
        $role1,
        Moose::Util::MetaRole::apply_metaroles(
            for            => $role2,
            role_metaroles => {
                role                    => [ trait_for 'Role' ],
                application_to_class    => [ ToClass          ],
                application_to_role     => [ __PACKAGE__      ],
                application_to_instance => [ ToInstance       ],
            },
        ),
    );

    ### check to see if our target now does the native trait...
    return
        unless $role2->does_role('Moose::Meta::Attribute::Native::Trait');

    ### applying TrackDirtyNativeTrait to: $role2->name
    TrackDirtyNativeTrait->meta->apply($role2);
    return;
};

!!42;
