# --
# Copyright (C) 2024-present mo-azfar, https://github.com/mo-azfar/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Output::HTML::Notification::AgentTicketZoomNotice;

use parent 'Kernel::Output::HTML::Base';
use Kernel::System::VariableCheck qw(IsInteger);

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
    'Kernel::System::Cache',
    'Kernel::System::CustomerUser',
);

sub Run {
    my ( $Self, %Param ) = @_;

    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Output   = '';
    my $Action   = $LayoutObject->{Action} || 0;
    my $TicketID = $LayoutObject->{TicketID} || 0;

    return $Output if $Action ne 'AgentTicketZoom';
    return $Output if !$TicketID;

    my $CacheObject        = $Kernel::OM->Get('Kernel::System::Cache');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

    # my $TicketCached = $CacheObject->Get(
    #     Type => 'Ticket',
    #     Key  => 'Cache::GetTicket' .$TicketID,
    # );

    my $TicketCached = $CacheObject->Get(
        Type => 'Ticket',
        Key  => 'Cache::GetTicket' . $TicketID . '::0::1',
    );

    my %Data;

    #generate hash from config and cache
    CONFIG:
    for my $Setting ( sort keys %{ $Param{Config}->{TicketCheck} } ) {
        next CONFIG if !$Param{Config}->{TicketCheck}->{$Setting};
        $Data{$Setting} = $TicketCached->{$Setting};
    }

    DISPLAY:
    for my $Show ( sort keys %Data ) {
        if ( $Show eq 'CustomerUserID' ) {

            my $CustomerName = $CustomerUserObject->CustomerName(
                UserLogin => $Data{CustomerUserID},
            );

            $Data{$Show} = $CustomerName || '';
        }

        next DISPLAY if $Data{$Show};

        my $ShowName = $Show;
        $ShowName =~ s/ID$//;
        $ShowName =~ s/DynamicField_//;

        $Output .= $LayoutObject->Notify(
            Priority => 'Notice',
            Data     => 'Ticket#' . $TicketCached->{TicketNumber} . ': No Data Found for ' . $ShowName,
        );

    }

    return $Output;

}

1;
