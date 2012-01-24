package MooseX::TrackDirty::Attributes::Trait::Attribute::Native::Trait;

# ABSTRACT: Compatibility trait between trackdirty and native traits

use Moose::Role;
use namespace::autoclean;

use Class::Load 'load_class';

# debugging...
#use Smart::Comments;

use MooseX::TrackDirty::Attributes::Trait::Method::Accessor::Native;

Moose::Exporter->setup_import_methods(
    trait_aliases => [
        [ __PACKAGE__, 'TrackDirtyNativeTrait' ],
    ],
);

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
