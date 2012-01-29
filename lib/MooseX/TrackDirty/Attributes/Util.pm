package MooseX::TrackDirty::Attributes::Util;

# ABSTRACT: Laziness.

use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [ qw{
        trait_for application
        ToRole ToClass ToInstance
        CompositeToClass CompositeToRole CompositeToInstance
        TrackDirtyNativeTrait
    } ],
    groups => { default => ':all' },
};

sub trait_for($) { "MooseX::TrackDirty::Attributes::Trait::$_[0]" }

sub application($) { trait_for "Role::Application::$_[0]"  }
sub ToInstance()   { application 'ToInstance'              }
sub ToClass()      { application 'ToClass'                 }
sub ToRole()       { trait_for 'Role::Application::ToRole' }

sub TrackDirtyNativeTrait() { trait_for 'Attribute::Native::Trait' }

sub composite($)          { application "Composite::$_[0]" }
sub CompositeToClass()    { composite 'ToClass'            }
sub CompositeToRole()     { composite 'ToRole'             }
sub CompositeToInstance() { composite 'ToInstance'         }

!!42;

__END__
