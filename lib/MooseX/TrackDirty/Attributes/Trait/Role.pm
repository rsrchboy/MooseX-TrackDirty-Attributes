package MooseX::TrackDirty::Attributes::Trait::Role;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;
use Moose::Exporter;

use MooseX::TrackDirty::Attributes::Util ':all';

# debugging...
use Smart::Comments;

with trait_for 'Role::Application';

# ensure that future applications of a native trait will be handled correctly
after add_role => sub {
    my ($self, $other) = @_;

    #my $role = $appli->role;

    warn;
    ### checking: $other->name
    return unless $other
        #->role
        ->does_role('Moose::Meta::Attribute::Native::Trait')
        ;

    ### applying to self...
    TrackDirtyNativeTrait->meta->apply($self);
    return;
};


around composition_class_roles => sub {
    my ($orig, $self) = (shift, shift);

    ### in our composition_class_roles()...
    return
        $self->$orig(@_),
        'MooseX::TrackDirty::Attributes::Trait::Role::Composite',
        ;
};

!!42;

__END__
