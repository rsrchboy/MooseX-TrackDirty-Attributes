package MooseX::TrackDirty::Attributes::Util;

# ABSTRACT: Laziness.

use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [ qw{
        trait_for application
        Composite ToRole ToClass ToInstance
        AccessorNativeTrait TrackDirtyNativeTrait
    } ],
    groups => { default => ':all' },
};

sub trait_for($)            { "MooseX::TrackDirty::Attributes::Trait::$_[0]" }
sub application($)          { trait_for "Role::Application::$_[0]"           }
sub Composite()             { trait_for 'Role::Composite'                    }
sub ToInstance()            { application 'ToInstance'                       }
sub ToClass()               { application 'ToClass'                          }
sub ToRole()                { application 'ToRole'                           }
sub TrackDirtyNativeTrait() { trait_for 'Attribute::Native::Trait'           }
sub AccessorNativeTrait()   { trait_for 'Method::Accessor::Native'           }

!!42;

__END__

=for Pod::Coverage trait_for application Composite ^To.*$ TrackDirtyNativeTrait AccessorNativeTrait
