package MooseX::TrackDirty::Attributes::Trait::Role::Application::ToClass;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;
use MooseX::TrackDirty::Attributes::Util ':all';

# debug...
#use Smart::Comments;

after apply => sub {
    my ($self, $role, $target) = @_;

    ### in Application--ToClass...

    ### role:   $role->name
    ### target: $target->name

    ### applying metaroles to: $target->name
    Moose::Util::MetaRole::apply_metaroles(
        for => $target,
        class_metaroles => {
            class  => [ trait_for 'Class'  ],
        },
    );

    my @roles = map { $_->name } $target->calculate_all_roles;
    ### @roles

    ### check to see if our target now does the native trait...
    return
        unless $target->does_role('Moose::Meta::Attribute::Native::Trait');

    ### applying to: $target->name
    TrackDirtyNativeTrait->meta->apply($target);
    return;
};

!!42;

__END__


