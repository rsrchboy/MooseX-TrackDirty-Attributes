package MooseX::TrackDirty::Attributes::Trait::Role::Composite;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;

use MooseX::TrackDirty::Attributes::Util ':all';

# debugging...
#use Smart::Comments;

around apply_params => sub {
    my ($orig, $self) = (shift, shift);

    return Moose::Util::MetaRole::apply_metaroles(
        for            => $self->$orig(@_),
        role_metaroles => {
            role => [ trait_for 'Role' ],
            application_to_class    => [ ToClass    ],
            application_to_role     => [ ToRole     ],
            #application_to_instance => [ ToInstance ],
        },
    );
};


!!42;
