package VHProxy::Config;
#Handles configuration import
use YAML::Tiny;
use VHProxy::IO qw($output);
    use Data::Dumper;
use File::Find::Object;


sub new(){
	
    my $package = shift;
    bless( {}, $package );
    %{$package} = @_;

    return $package;

}

sub Hosts(){
	my $self=shift;
	return $self->{'Hosts'} if($self->{'Hosts'});
}

sub read()
{
	my $self=shift;
	my $Tiny   = YAML::Tiny->new;
	if($self->{'Dirs'}){
		my $tree = File::Find::Object->new( {}, @{$self->{'Dirs'}} );
		my $Hosts;
while ( my $r = $tree->next_obj() ) {
    if ( $r->is_file ) {
        $yaml = $Tiny->read( $r->path )
            or $output->error( "Error occourred reading " . $r->path ." YAML Syntax error?");

        #Importing data in my hash with an index by host (for convenience)
        foreach my $Key ( @{$yaml} ) {
            if(exists($Key->{listening_port})){
                $ListenPort=$Key->{listening_port};
            }


            if(exists($Key->{scheme})){
                $Scheme=$Key->{scheme};
            }

            if(exists($Key->{domain})){
                $Domain=$Key->{domain};
            }

            if(exists($Key->{host})){
                $output->print(
                        "* "
                            . $Key->{host} . ":"
                            . $Key->{host_port} . " -> "
                            . $Key->{redirect} . ":"
                            . $Key->{redirect_port},
                        "||"
                    );
                $Hosts->{ $Key->{host} }->{redirect}      = $Key->{redirect};
                $Hosts->{ $Key->{host} }->{redirect_port} = $Key->{redirect_port};
                $Hosts->{ $Key->{host} }->{host_port}     = $Key->{host_port};
            }
        }

    }
}

    $self->{'Hosts'}=$Hosts;
    return $Hosts;
	} else {
		$output->ERROR("Config dirs not defined");
        exit 1;
        caller()->app->exit();
	}

}
1;