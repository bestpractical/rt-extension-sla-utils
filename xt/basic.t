use strict;
use warnings;

use RT::Extension::SLA::Utils::Test tests => undef;

use_ok('RT::Extension::SLA::Utils');
use_ok('RT::CustomField');


my $queue = RT::Test->load_or_create_queue( Name => 'General' );
ok( $queue->id, "loaded the General queue" );
ok( $queue->SetSLADisabled(0), 'SLA enabled');


# Create the Impact custom field we will use for testing per the config
my $cf = RT::CustomField->new(RT->SystemUser);
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
$cf->AddToObject($queue);

RT::Test->set_rights(
    Principal => 'Everyone',
    Right => ['CreateTicket', 'ShowTicket', 'SeeQueue', 'ReplyToTicket', 'ModifyTicket'],
);


done_testing;
