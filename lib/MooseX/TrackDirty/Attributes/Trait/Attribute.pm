package MooseX::TrackDirty::Attributes::Trait::Attribute;

# ABSTRACT: Track dirtied attributes

use Moose::Role;
use namespace::autoclean;
use MooseX::Types::Perl ':all';
use MooseX::AttributeShortcuts;

use Moose::Util::MetaRole;
use MooseX::TrackDirty::Attributes::Trait::Role;
use MooseX::TrackDirty::Attributes::Trait::Role::Application::ToClass;
use MooseX::TrackDirty::Attributes::Trait::Role::Application::ToRole;

# roles to help us track / do-the-right-thing when native traits are also used
Moose::Util::MetaRole::apply_metaroles(
    for            => __PACKAGE__->meta,
    role_metaroles => {
        role                    => [ MetaRoleTrait ],
        application_to_class    => [ ToClass       ],
        application_to_role     => [ ToRole        ],
        #application_to_instance => [ ToInstance   ],
    },
);


# debugging
#use Smart::Comments '###', '####';

has is_dirty       => (is => 'ro', isa => Identifier, lazy => 1, builder => 1);
has original_value => (is => 'ro', isa => Identifier);

sub _build_is_dirty { shift->name . '_is_dirty' }
#...

has value_slot => (is => 'lazy', isa => 'Str');
has dirty_slot => (is => 'lazy', isa => 'Str');

sub _build_value_slot { shift->name                        }
sub _build_dirty_slot { shift->name . '__DIRTY_TRACKING__' }

override slots => sub { (super, shift->dirty_slot) };

before set_value => sub {
    my ($self, $instance) = @_;

    my $mi = $self->associated_class->get_meta_instance;

    my $_get    = sub { $mi->get_slot_value($instance, @_)      };
    my $_set    = sub { $mi->set_slot_value($instance, @_)      };
    my $_exists = sub { $mi->is_slot_initialized($instance, @_) };

    $_set->($self->dirty_slot, $_get->($self->value_slot))
        if $_exists->($self->value_slot) && !$_exists->($self->dirty_slot);

    return;
};

after clear_value => sub { shift->clear_dirty_slot(@_) };

around _inline_clear_value => sub {
    my ($orig, $self) = (shift, shift);
    my ($instance) = @_;

    my $mi = $self->associated_class->get_meta_instance;

    return $self->$orig(@_)
        . $mi->inline_deinitialize_slot($instance, $self->dirty_slot)
        . ';'
        ;
};

sub _inline_is_dirty_set {
    my $self = shift;
    my ($instance, $value) = @_;

    # set tracker if dirty_slot is not init and value_slot value_slot is

    my $mi = $self->associated_class->get_meta_instance;
    return $mi->inline_set_slot_value($instance, $self->dirty_slot, $value);
}

sub _inline_is_dirty_get {
    my $self = shift;
    my ($instance, $value) = @_;

    # set tracker if dirty_slot is not init and value_slot value_slot is

    my $mi = $self->associated_class->get_meta_instance;
    return $mi->inline_get_slot_value($instance, $self->dirty_slot, $value);
}

sub _inline_set_dirty_slot_if_dirty {
    my ($self, $instance, $value) = @_;
    # set dirty_slot from value_slot if dirty_slot is not init and value_slot value_slot is

    ### $instance
    ### $value

    my $mi = $self->associated_class->get_meta_instance;
    my $_exists = sub { $mi->inline_is_slot_initialized($instance, shift) };

    # use our predicate method if we have one, as it may have been wrapped/etc
    my $value_slot_exists
        = $self->has_predicate
        ? "${instance}->" . $self->predicate . '()'
        : $_exists->($self->value_slot)
        ;

    my $dirty_slot_exists = $_exists->($self->dirty_slot);

    my $set_dirty_slot = $self
        ->_inline_is_dirty_set(
            $instance,
            'do { ' .  $mi->inline_get_slot_value($instance, $self->value_slot) . ' } ',
        )
        ;

    my $code =
        "do { $set_dirty_slot } " .
        "   if $value_slot_exists && !$dirty_slot_exists;"
        ;

    return $code;
}

around _inline_instance_set => sub {
    my ($orig, $self) = (shift, shift);
    my ($instance, $value) = @_;

    my $code = $self->_inline_set_dirty_slot_if_dirty(@_);
    $code = "do { $code; " . $self->$orig(@_) . " }";

    ### $code
    return $code;
};

# TODO remove_accessors

sub mark_tracking_dirty { shift->set_dirty_slot(@_) }

sub original_value_get { shift->is_dirty_get(@_) }

sub is_dirty_set {
    my ($self, $instance) = @_;

    return $self
        ->associated_class
        ->get_meta_instance
        ->set_slot_value($instance, $self->dirty_slot)
        ;
}

sub is_dirty_get {
    my ($self, $instance) = @_;

    return $self
        ->associated_class
        ->get_meta_instance
        ->get_slot_value($instance, $self->dirty_slot)
        ;
}

sub is_dirty_instance {
    my ($self, $instance) = @_;

    return $self
        ->associated_class
        ->get_meta_instance
        ->is_slot_initialized($instance, $self->dirty_slot)
        ;
}

sub clear_dirty_slot {
    my ($self, $instance) = @_;

    return $self
        ->associated_class
        ->get_meta_instance
        ->deinitialize_slot($instance, $self->dirty_slot)
        ;
}

override accessor_metaclass => sub {
    my $self = shift @_;

    my $classname = Moose::Meta::Class->create_anon_class(
        superclasses => [ super ],
        roles        => [ 'MooseX::TrackDirty::Attributes::Trait::Method::Accessor' ],
        cache        => 1,
    )->name;

    return $classname;
};

after install_accessors => sub {
    my ($self, $inline) = @_;
    my $class = $self->associated_class;

    $class->add_method(
        $self->_process_accessors('is_dirty' => $self->is_dirty, $inline)
    ) if $self->is_dirty;
    $class->add_method(
        $self->_process_accessors('original_value' => $self->original_value, $inline)
    ) if $self->original_value;

    return;
};

before remove_accessors => sub {
    my $self = shift @_;

    # stolen from Class::MOP::Attribute
    my $_remove_accessor = sub {
        my ($accessor, $class) = @_;
        if (ref($accessor) && ref($accessor) eq 'HASH') {
            ($accessor) = keys %{$accessor};
        }
        my $method = $class->get_method($accessor);
        $class->remove_method($accessor)
            if (ref($method) && $method->isa('Class::MOP::Method::Accessor'));
    };

    $_remove_accessor->($self->is_dirty,       $self->associated_class) if $self->is_dirty;
    $_remove_accessor->($self->original_value, $self->associated_class) if $self->original_value;

    return;
};


!!42;

__END__

=head1 DESCRIPTION

This is a trait for attribute metaclasses.  You really don't need to do
anything with it; you want L<MooseX::TrackDirty::Attributes>.

=head1 SEE ALSO

L<MooseX::TrackDirty::Attributes>

=cut
