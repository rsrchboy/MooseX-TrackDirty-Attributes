package MooseX::TrackDirty::Attributes::Trait::Attribute::Native::Trait;

# ABSTRACT: Compatibility trait between the track-dirty and native traits

use Moose::Role;
use namespace::autoclean;
use MooseX::TrackDirty::Attributes::Util ':all';

use Class::Load 'load_class';

# debugging...
#use Smart::Comments;

# We wrap _native_accessor_class_for() to catch the generated accessor
# classes; if they use the native Writer trait, then we apply our shim trait
# to ensure that dirtyness is properly tracked.

requires '_native_accessor_class_for';

around _native_accessor_class_for => sub {
    my ($orig, $self) = (shift, shift);
    my ($suffix) = @_;

    my $class = $self->$orig(@_);

    return $class unless $class
        ->meta
        ->does_role('Moose::Meta::Method::Accessor::Native::Writer')
        ;

    my $new_class = Moose::Meta::Class->create_anon_class(
        superclasses => [ $class              ],
        roles        => [ AccessorNativeTrait ],
        cache        => 1,
    );

    return $new_class->name;
};

!!42;
__END__
