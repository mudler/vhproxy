package VHProxy::Handlers::HTTP;
use VHProxy::IO qw($output);
use Time::HiRes qw(usleep ualarm gettimeofday tv_interval);

sub new {
    my $package = shift;
    bless( {}, $package );
    %{$package} = @_;

    return $package;

}

sub proxy {
    my $request_arrival_time = [gettimeofday];
    my $Class                = shift;
    my $self                 = shift;
    my $Hosts                = $Class->{'Hosts'};
    $self->render_later;

    if (exists( $Hosts->{ $self->tx->req->url->base->host() } )

        #and $Hosts->{$requestedhost}->{host_port} eq $requestedport
        )
    {
        $Class->_forge_request($self);
    }
    else {
        my $Requested =
            $self->tx->req->content->headers->host;    #Requested by client
        my $requestedhost   = $self->tx->req->url->base->host();
        my $requestedport   = $self->tx->req->url->base->port();
        my $requestedmethod = $self->tx->req->method();
        $output->error(
                  "Someone requested something it's not configured: "
                . $self->tx->remote_address . " "
                . $requestedmethod . " "
                . $requestedhost . ":"
                . $requestedport );
       return $self->render_exception('Your request is soooo wrong!');
    }

    my $elapsed = tv_interval( $request_arrival_time, [gettimeofday] );

    $output->print( "Elapsed time for request "
            . $self->tx->remote_address . " :"
            . $elapsed
            . "s" );
}

sub _forge_request {
    my $Class = shift;
    my $self  = shift;

    my $Hosts = $Class->{'Hosts'};

    my $Requested =
        $self->tx->req->content->headers->host;    #Requested by client
    my $RequestedURL     = $self->tx->req->url;
    my $RequestedURLPath = $self->tx->req->url->path;

    my $requestedhost   = $self->tx->req->url->base->host();
    my $requestedport   = $self->tx->req->url->base->port();
    my $requestedmethod = $self->tx->req->method();
    $output->notice( $self->tx->remote_address . " "
            . $requestedmethod . " "
            . $requestedhost . ":"
            . $requestedport );

    #Start forging

    #my $tx= $self->ua->build_tx( $requestedmethod => $requestedhost);
    #$tx->req($self->tx->req->clone());
    my $tx = Mojo::Transaction::HTTP->new;
    $tx->req( $self->tx->req->clone() )
        ;    #this is better, we keep also the same request

    # $output->DEBUG("Cookie ".Dumper($self->tx->req));
    # foreach my $c( keys %{$self->tx->req->{"cookies"}})
    # {
    #   #  $Cookies.=$self->tx->req->{"cookies"}->{$c}[0]->to_string."; ";

    #     $tx->req->cookies($self->tx->req->{"cookies"}->{$c}[0]);
    # }
    #$tx->req->headers->cookie($Cookies);

    #$tx->req->{'content'} = $self->tx->req->{'content'};

    $tx->req->url->parse( $Class->{'Scheme'} . "://"
            . $Hosts->{$requestedhost}->{redirect} . ":"
            . $Hosts->{$requestedhost}->{redirect_port}
            );
    $tx->req->url->path($RequestedURLPath);
    $tx->req->url->query( $self->tx->req->params );
    my $res =
        $self->ua->inactivity_timeout(20)->max_redirects(5)
        ->connect_timeout(20)->request_timeout(10)->start(
        $tx

#i had to comment the async task because on code 401 we got nothing than error (no prompt for password auth)
#,
#             sub {  my ($ua, $tx) = @_;
#    if ($tx->res->error) {
#                 $output->error("Something went wrong when processing the request: ".join(" ",@{$tx->res->{'error'}}));

            #         }else {
            #             $output->debug("Transaction: ".Dumper($tx));

            #                       $self->tx->res($tx->res);
            #                    $self->rendered;
            #         }

         #               #$output->print("The build request is ".Dumper($tx));

            # }
        );
    if ( $tx->res->error ) {
        $output->error( "Something went wrong when processing the request: "
                . join( " ", @{ $tx->res->{'error'} } ) );

    }

        $self->tx->res( $tx->res );
        $self->rendered;
    

}

1;
