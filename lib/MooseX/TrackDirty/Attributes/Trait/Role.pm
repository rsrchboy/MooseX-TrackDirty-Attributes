package MooseX::TrackDirty::Attributes::Trait::Role;
# Dist::Zilla: +PkgVersion

use Moose::Role;
use namespace::autoclean;

use MooseX::TrackDirty::Attributes::Util ':all';

# debugging...
#use Smart::Comments;

# ensure that future applications of a native trait will be handled correctly
after add_role => sub {
    my ($self, $other) = @_;

    ### checking: $self->name
    return unless $self->does_role('Moose::Meta::Attribute::Native::Trait');

    ### applying to self...
    TrackDirtyNativeTrait->meta->apply($self);
    return;
};

around composition_class_roles => sub {
    my ($orig, $self) = (shift, shift);

    ### in our composition_class_roles()...
    return ($self->$orig(@_), Composite);
};

!!42;

__END__
