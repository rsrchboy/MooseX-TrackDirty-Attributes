package MooseX::TrackDirty::Attributes::Trait::Role::Composite;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;

use MooseX::TrackDirty::Attributes::Util ':all';

# debugging...
use Smart::Comments;

with trait_for 'Role';

!!42;

__END__

requires 'apply_params';

around apply_params => sub {
    my ($orig, $self) = (shift, shift);

    my $target = $self->$orig(@_);

    ### target is: ref $target
    ### we are: ref $self

    #my @target_isa = map { $_->name } $target->meta->superclasses;
    #my @target_isa = $target->meta->superclasses;
    # ## @target_isa

    # XXX I think what we need to do here is remove the
    # composition_class_roles() from the role trait and move it into a trait
    # of its own.  That trait can then be applied where needed, and left out
    # here.

    warn;
    Moose::Util::MetaRole::apply_metaroles(
        #for            => $self->$orig(@_),
        for            => $target,
        role_metaroles => {
            role => [ trait_for 'Role' ],
            application_to_class    => [ CompositeToClass    ],
            application_to_role     => [ CompositeToRole     ],
            application_to_instance => [ CompositeToInstance ],
        },
    );

    return $target;
};


!!42;
