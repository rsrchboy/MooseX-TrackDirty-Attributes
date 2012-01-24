package MooseX::TrackDirty::Attributes::Trait::Method::Accessor::Native;

# ABSTRACT: Shim trait for handling native trait's writer accessor classes

use Moose::Role;
use namespace::autoclean;

# debugging...
#use Smart::Comments;

Moose::Exporter->setup_import_methods(
    trait_aliases => [
        [ __PACKAGE__, 'AccessorNativeTrait' ],
    ],
);

requires '_inline_optimized_set_new_value';

around _inline_optimized_set_new_value => sub {
    my ($orig, $self) = (shift, shift);
    my ($inv, $new, $slot_access) = @_;

    my $original = $self->$orig(@_);

    ### @_
    ### $original

    my $code = $self
        ->associated_attribute
        ->_inline_set_dirty_slot_if_dirty(@_)
        ;

    $code = "do { $code; $original };";

    ### $code
    return $code;
};

!!42;

__END__

