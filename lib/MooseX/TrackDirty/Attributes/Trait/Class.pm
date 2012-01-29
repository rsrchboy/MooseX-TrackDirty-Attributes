package MooseX::TrackDirty::Attributes::Trait::Class;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;
use Moose::Exporter;

# debug...
#use Smart::Comments;

use MooseX::TrackDirty::Attributes::Trait::Attribute::Native::Trait;

requires 'add_role_application';

# ensure that future applications of a native trait will be handled correctly
after add_role_application => sub {
    my ($self, $application) = @_;

    return unless $application
        ->role
        ->does_role('Moose::Meta::Attribute::Native::Trait::Writer')
        ;

    TrackDirtyNativeTrait->meta->apply($self);
    return;
};

!!42;
