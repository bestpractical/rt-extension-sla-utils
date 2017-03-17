use strict;
use warnings;

### after: use lib qw(@RT_LIB_PATH@);
use lib qw(/Users/jbrandt/rts/rt440-test/local/lib /Users/jbrandt/rts/rt440-test/lib);

package RT::Extension::SLA::Utils::Test;

our @ISA;
BEGIN {
    local $@;
    eval { require RT::Test; 1 } or do {
        require Test::More;
        Test::More::BAIL_OUT(
            "requires 3.8 to run tests. Error:\n$@\n"
            ."You may need to set PERL5LIB=/path/to/rt/lib"
        );
    };
    push @ISA, 'RT::Test';
}

sub import {
    my $class = shift;
    my %args  = @_;

    $args{'requires'} ||= [];
    if ( $args{'testing'} ) {
        unshift @{ $args{'requires'} }, 'RT::Extension::SLA::Utils';
    } else {
        $args{'testing'} = 'RT::Extension::SLA::Utils';
    }

    $class->SUPER::import( %args );
    $class->export_to_level(1);

    require RT::Extension::SLA::Utils;
}

sub bootstrap_more_config{
    my $self = shift;
    my $config = shift;
    my $args_ref = shift;

    my $sla = <<"CONFIG";
Set(%ServiceAgreements, (
    Default => 'Informational',
    QueueDefault => {
        'General' => 'Informational',
    },
    Levels => {
        # The "Initial" period handled by RT::Action::SLA::SetDue
        'Critical' => {
            Starts      => { RealMinutes => 0     },
            Initial     => { RealMinutes => 10    }, # Initial Response
            FirstResponse    => { RealMinutes => 30    }, # First Response
            KeepInLoop  => { RealMinutes => 60*1  }, # Updates
            Resolve     => { RealMinutes => 60*4  }, # Resolution
        },
        'Major' => {
            Starts      => { RealMinutes => 0     },
            Initial     => { RealMinutes => 15    }, # Initial Response
            FirstResponse    => { RealMinutes => 30    }, # First Response
            KeepInLoop  => { RealMinutes => 60*24 }, # Updates
            Resolve     => { RealMinutes => 60*48 }, # Resolution
        },
        'Minor' => {
            Starts      => { RealMinutes => 0     },
            Initial     => { RealMinutes => 60    }, # Initial Response
            FirstResponse    => { RealMinutes => 60*2  }, # First Response
            KeepInLoop  => { RealMinutes => 60*24 }, # Updates
            Resolve     => { RealMinutes => 60*48 }, # Resolution
        },
        'Informational' => {
            Starts      => { RealMinutes => 0     },
            Initial     => { RealMinutes => 60    }, # Initial Response
            FirstResponse    => { RealMinutes => 60*8  }, # First Response
            KeepInLoop  => { RealMinutes => 60*24 }, # Updates
            Resolve     => { RealMinutes => 60*72 }, # Resolution
        },
        'Trivial' => {
         # all ignored; this level is N/A via SLAIgnoreLevels configuration value
            Starts      => { RealMinutes => 0 },
            Initial     => { RealMinutes => 1 },
            FirstResponse    => { RealMinutes => 2 },
            KeepInLoop  => { RealMinutes => 3 },
            Resolve     => { RealMinutes => 4 },
        }
    },
));
Set(\$SLACustomField, 'Impact');
Set(\$SLAIngnoreLevels, 'Trivial');
CONFIG

    print $config $sla;
    
    # Create the Impact custom field we will use for testing per the config
    my $cf = CustomField->new(RT->SystemUser);
    $cf->Create(
        LookupType  => 'RT::Queue-RT::Ticket',  # for Tickets
        Name => 'Impact',
        Type => 'SelectSingle',  # SelectSingle is the same as: Type => 'Select', MaxValues => 1
        RenderType  => 'Dropdown',
        Values      => [
            { Name => 'Critical' },
            { Name => 'Informational' },
            { Name => 'Major' },
            { Name => 'Minor' },
            { Name => 'Order to Activation' },
        ]
    );

    my $queue = RT::Queue->new(RT->SystemUser);
    $queue->Load('General');            # apply Impact to General queue
    $cf->SetContextObject($queue);

    return;
}

1;
