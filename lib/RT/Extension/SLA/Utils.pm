use strict;
use warnings;
package RT::Extension::SLA::Utils;

our $VERSION = '0.01';

=head1 NAME

RT-Extension-SLA-Utils - additional SLA utilities

=head1 DESCRIPTION

The RT::Extension::SLA::Utils plugin adds additional
scrip actions and conditions to trigger SLA changes 
off of a Custom Field change, and support tracking
which tickets SLAs are overdue.


=head1 RT VERSION

Works with RT 4.4.0 and newer.

=head1 INSTALLATION

=over

=item C<perl Makefile.PL>

=item C<make>

=item C<make install>

=item C<make initdb>

May need root permissions

=item Edit your F</opt/rt4/etc/RT_SiteConfig.pm>

If you are using RT 4.2 or greater, add this line:

    Plugin('RT::Extension::SLA::Utils');

or add C<RT::Extension::SLA::Utils> to your existing C<@Plugins> line.

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=back

=head1 CONFIGURATION

=head2 Setting a Custom Field to Map to SLA

This extension allows you to define another custom field, like Impact or
Severity, and have changes in that field trigger a change in SLA.

First, you need to set the name of the custom field that will trigger SLA changes:

    Set($SLACustomField, 'my field name');

And if you want any SLA levels to not trigger changes:

    Set($SLAIgnoreLevels, 'level 1', 'some other level');

Then assign the mapping of custom field values to SLA levels. If they are the same, like:

Impact: Low, Medium, High

SLA Levels: Low, Medium, High

Then you don't need to define the mapping. If they are different, add configuration like:

    Set(%SLA_CF_Mapping,
        'Low' => '48-hour',
        'Medium' => '24-hour',
        'High' => '8-hour',
    );

where the first value is a configured custom field value, and the second is the desired
corresponding SLA.

=head2 Setup rt-crontool to Run Overdue Checks

To have the B<SLA Overdue> field set automatically, you can have rt-crontool
run the checks periodically to update the field.  You can use rt-crontool with cron
such as:

    rt-crontool --search RT::Search::ActiveTicketsInQueue --search-arg <queue_name> \
        --condition RT::Condition::SLA::Overdue --action RT::Action::SLA::SetOverdue

Replace the <queue_name> with the name of the queue you would like the check run on,
such as 'General'.  If you want to run the checks on multiple queues, you will need
a line for each queue. 

Schedule the job at the frequency that you want to catch SLA violations. If you want to
record a value within 5 minutes of a violation, schedule the job to run every 5 minutes.

=head1 AUTHOR

Best Practical Solutions, LLC E<lt>modules@bestpractical.comE<gt>

=head1 BUGS

All bugs should be reported via email to

    L<bug-RT-Extension-SLA-Utils@rt.cpan.org|mailto:bug-RT-Extension-SLA-Utils@rt.cpan.org>

or via the web at

    L<rt.cpan.org|http://rt.cpan.org/Public/Dist/Display.html?Name=RT-Extension-SLA-Utils>.

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2017 Best Practical Solutions

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

1;
