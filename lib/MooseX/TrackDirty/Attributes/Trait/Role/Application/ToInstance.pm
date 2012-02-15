package MooseX::TrackDirty::Attributes::Trait::Role::Application::ToInstance;

# ABSTRACT: Application to instance helper trait

use Moose::Role;
use namespace::autoclean;
use MooseX::TrackDirty::Attributes::Util ':all';

# debug...
#use Smart::Comments;

after apply => sub {
    my ($self, $role, $object) = @_;

    my $object_meta = Class::MOP::class_of($object);

    ### Application to instance...
    ### role:   $role->name
    ### target: $object_meta->name

    ### applying metaroles to: $object_meta->name
    Moose::Util::MetaRole::apply_metaroles(
        for => $object_meta,
        class_metaroles => {
            class => [ trait_for 'Class' ],
        },
    );

    #my @roles = map { $_->name } $object_meta->calculate_all_roles_with_inheritance;
    ### @roles
    #my @meta_roles = map { $_->name } $object_meta->meta->calculate_all_roles_with_inheritance;
    ### @meta_roles

    $object->remove_accessors;
    Moose::Util::apply_all_roles($object, TrackDirtyNativeTrait)
        if $object_meta->does_role('Moose::Meta::Attribute::Native::Trait');
    $object->install_accessors;

    return;
};

!!42;

__END__


