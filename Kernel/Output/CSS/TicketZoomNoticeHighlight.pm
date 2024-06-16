# --
# Copyright (C) 2021 Znuny GmbH, https://github.com/mo-azfar/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::CSS::TicketZoomNoticeHighlight;

use strict;
use warnings;
use utf8;

use parent 'Kernel::Output::CSS::Base';

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
);

use Kernel::System::VariableCheck qw(:all);

=head1 NAME

Kernel::Output::CSS::State - output css state

=head2 CreateCSS()

Creates and returns a CSS string.

    my $CSS = $CSSObject->CreateCSS();

Returns:

    my $CSS = 'CSS';

=cut

sub CreateCSS {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $Action = $LayoutObject->{Action};

    return '' if $Action ne 'AgentTicketZoom';

    my $TicketID = $LayoutObject->{TicketID};

    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $CacheObject        = $Kernel::OM->Get('Kernel::System::Cache');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

    my $SettingEnabled = $ConfigObject->Get('Ticket::Frontend::TicketZoomNoticeHighlight');

    return '' if !$SettingEnabled;

    my $TicketCached = $CacheObject->Get(
        Type => 'Ticket',
        Key  => 'Cache::GetTicket' . $TicketID . '::0::1',
    );

    my $CustomerName = $CustomerUserObject->CustomerName(
        UserLogin => $TicketCached->{CustomerUserID},
    ) || '';

    return '' if $CustomerName;

    my %Data;

    $Data{ '@keyframes highlight' } = 
    {
        '0% { background' => 'red } 50% { background: yellow } 100% { background: red }',
    };

    $Data{ '#nav-People .ClusterLink, #nav-People #nav-People-container #nav-Customer' } = 
    {
        'background' => 'red',
        'animation' => 'highlight 2s infinite',
        'border-radius' => '10px',
    };

    # Expected CSS:
    # @keyframes highlight {
    #     0% { background-color: red }
    #     50% { background-color: yellow }
    #     100% { background-color: red }
    # }

    # .#nav-People > .ClusterLink,
    # .#nav-People > #nav-People-container > #nav-Customer {
    #     background-color: red;
    #     animation: highlight 2s infinite;
    #     border-radius: 10px;
    # } 

    my $CSS = $LayoutObject->ConvertToCSS(
        Data => \%Data,
    ) // '';

    return $CSS;
}

1;
