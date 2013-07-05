package VHProxy::Handlers::HTTP;
use VHProxy::IO qw($output);
use Time::HiRes qw(usleep ualarm gettimeofday tv_interval);
sub new {
	my $self=shift;
bless ({},$self);
$self->{'Hosts'}=shift->{'Hosts'};

return $self;

}

sub proxy {
        use Data::Dumper;

    my $request_arrival_time = [gettimeofday];
    my $Class = shift;
    my $self=shift;
    my $Hosts = $Class->{'Hosts'};
    $self->render_later;

    my $Requested =
        $self->tx->req->content->headers->host;    #Requested by client
    my $RequestedURL    = $self->tx->req->url;
    my $requestedhost   = $self->tx->req->url->base->host();
    my $requestedport   = $self->tx->req->url->base->port();
    my $requestedmethod = $self->tx->req->method();
    $output->notice( "[NOTICE] "
            . $self->tx->remote_address . " "
            . $requestedmethod . " "
            . $requestedhost . ":"
            . $requestedport );
    $output->print("Got a request for $requestedhost ");

    if (exists( $Hosts->{$requestedhost} )

        #and $Hosts->{$requestedhost}->{host_port} eq $requestedport
        )
    {
        $output->print("Building the Transaction");

        ##TRANSACTION##
        my $ua = Mojo::UserAgent->new;

   #Building the query that was submitted by the user and returning the output
        my $tx =
            $ua->build_tx(
            $requestedmethod => $Hosts->{$requestedhost}->{redirect} );
        $output->print( "Redirecting to : "
                . $Hosts->{$requestedhost}->{redirect} . ":"
                . $Hosts->{$requestedhost}->{redirect_port} );

     #$tx->req->content->headers->host($Hosts->{$r1equestedhost}->{redirect});
        $tx->req->url->base->host( $Hosts->{$requestedhost}->{redirect} );
        $tx->req->url->base->port(
            $Hosts->{$requestedhost}->{redirect_port} );
        $tx->req->url->{"query"}    = $self->tx->req->url->query;
        $tx->req->{"cookies"}    = $self->tx->req->cookies;
#        $tx->req->{"content"}    = $self->tx->content;
#        $tx->req->{'content'}->{"headers"}->{"headers"}->{"host"}= [$requestedhost.":".$requestedport];

        $tx->req->url->{"path"}     = $self->tx->req->url->path;
        $tx->req->url->{"fragment"} = $self->tx->req->url->fragment;

   
       # $output->print("The request is ".Dumper($tx));
        my $res =
            $ua->inactivity_timeout(20)->max_redirects(5)
            ->connect_timeout(20)->request_timeout(10)->start($tx)
            ;    # Sending the request

        ##RENDERING THE OUTPUT
        if($res){
            $self->render( text => $res->res->body );
        } else {
            $output->error("Something went wrong when processing the request: response empty");
        }
    }
    else {
        my $Requested =
            $self->tx->req->content->headers->host;    #Requested by client
        my $requestedhost   = $self->tx->req->url->base->host();
        my $requestedport   = $self->tx->req->url->base->port();
        my $requestedmethod = $self->tx->req->method();
        $output->error(
                  "[Error] someone requested something it's not configured: "
                . $self->tx->remote_address . " "
                . $requestedmethod . " "
                . $requestedhost . ":"
                . $requestedport );
    }
    my $elapsed = tv_interval ($request_arrival_time, [gettimeofday]);

    $output->print("Elapsed time for request ".$self->tx->remote_address." :".$elapsed."s");
}

1;