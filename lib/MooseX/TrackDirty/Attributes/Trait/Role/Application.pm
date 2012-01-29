package MooseX::TrackDirty::Attributes::Trait::Role::Application;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;
use Moose::Exporter;

# debug...
use Smart::Comments;

use MooseX::TrackDirty::Attributes::Util ':all';

requires 'apply';

after apply => sub {
    #my ($self, $source, $target) = @_;
    my ($self, $target) = @_;

    ### applying metaroles to: $target->name
    Moose::Util::MetaRole::apply_metaroles(
        for => $target,
        class_metaroles => {

            #class => [ MetaClassTrait ],
            class  => [ trait_for 'Class'  ],
        },
        role_metaroles => {

            role                    => [ trait_for 'Role'      ],
            application_to_class    => [ application 'ToClass' ],
            application_to_role     => [ application 'ToRole'  ],
            #application_to_instance => [                       ],
        },
    );


    ### torole: ToRole()
    ### mrt:    trait_for('Role')

    #my @roles = map { $_->name } TrackDirtyNativeTrait->meta->get_roles;
    #my @roles = TrackDirtyNativeTrait->meta->get_roles;
    my @roles = map { $_->name } $target->calculate_all_roles;
    #TrackDirtyNativeTrait->meta->calculate_all_roles;
    ### @roles

    ### check to see if our target now does the native trait...
    return
        unless $target->does_role('Moose::Meta::Attribute::Native::Trait');

    ### applying to: $target->name
    TrackDirtyNativeTrait->meta->apply($target);
    return;
};

!!42;
