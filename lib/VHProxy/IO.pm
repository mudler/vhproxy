package VHProxy::IO;
use Term::ANSIColor;
use Log::Any::Adapter ( 'File', './vhproxy.log' );
use Log::Any qw($log);
sub new {
	bless ({},shift);
}

sub import(){
	  my $class  = shift;
    my $caller = caller();
	my $varname= "$caller\::output";
            *$varname = \$class;
}

sub print(){

    my $self = shift;

        print colored( "[",  "magenta on_black bold" )
            . colored( $_[1] || "**" , "green on_black bold" )
            . colored( "]",  "magenta on_black bold" )
            . colored( " (", "magenta on_black bold" )
            	            . colored( $_[0], "blue on_black bold" )

            . colored( ") ",  "magenta on_black bold" ) . "\n";
    
    $log->info( $_[0]);
}

sub print_ascii(){
  my $self  = shift;
    my $FH    = $_[0];
    my $COLOR = $_[1];

        while ( my $line = <$FH> ) {
            print colored( $line, $COLOR );

            #  print "\0($COLOR)$line";
        }
}



sub AUTOLOAD {
    our $AUTOLOAD;
    my $self=shift;

    (my $method = $AUTOLOAD) =~ s/.*:://s; # remove package name
    my $printable=uc($method);
    $self->print("[$method] ".join(" ",@_));
    eval{
    	$log->$method(@_);
    }
  	
}

return 1;

__DATA__
____    ____  __    __  .______   .______        ______   ___   ___ ____    ____ 
\   \  /   / |  |  |  | |   _  \  |   _  \      /  __  \  \  \ /  / \   \  /   / 
 \   \/   /  |  |__|  | |  |_)  | |  |_)  |    |  |  |  |  \  V  /   \   \/   /  
  \      /   |   __   | |   ___/  |      /     |  |  |  |   >   <     \_    _/   
   \    /    |  |  |  | |  |      |  |\  \----.|  `--'  |  /  .  \      |  |     
    \__/     |__|  |__| | _|      | _| `._____| \______/  /__/ \__\     |__|     
                                                                                 
