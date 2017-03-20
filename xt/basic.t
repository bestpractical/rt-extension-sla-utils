use strict;
use warnings;

use RT::Extension::SLA::Utils::Test tests => undef;

use_ok('RT::Extension::SLA::Utils');
use_ok('RT::CustomField');


my $queue = RT::Test->load_or_create_queue( Name => 'General' );
ok( $queue->id, "loaded the General queue" );
ok( $queue->SetSLADisabled(0), 'SLA enabled');


# Create the Impact custom field we will use for testing per the config
my $ImpactCF = RT::CustomField->new(RT->SystemUser);
my ($cfid,$msg1) = $ImpactCF->Create(
    Queue => $queue->Id,
    LookupType  => 'RT::Queue-RT::Ticket',  # for Tickets
    Name => 'Impact',
    Type => 'SelectSingle',  # SelectSingle is the same as: Type => 'Select', MaxValues => 1
    RenderType  => 'Dropdown',
    Values      => [
        { Name => 'Critical' },
        { Name => 'Informational' },
        { Name => 'Major' },
        { Name => 'Minor' },
        { Name => 'Trivial' },
    ]
);
ok $cfid, "Created Impact custom field $msg1";

RT::Test->set_rights(
    Principal => 'Everyone',
    Right => ['CreateTicket', 'ShowTicket', 'SeeQueue', 'ReplyToTicket', 'ModifyTicket'],
);

my $ticket = RT::Ticket->new(RT->SystemUser);
my ($txid,$msg2) = $ticket->Create(
    Queue => $queue->Id,
    Requestor => 'root@localhost',
    Subject => 'test sla custom field change',
); 
ok $txid, "Created ticket $msg2";

my $cfs = $ticket->CustomFields;
is $cfs->Count, 2, "Check number of custom fields"; # Impact and SLA Overdue

my ($status1,$msg3) =$ticket->AddCustomFieldValue( Field  => 'Impact', Value => 'Trivial' );
ok $status1, "Added value Trivial $msg3";



done_testing;
