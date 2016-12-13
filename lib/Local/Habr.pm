package Local::Habr;

use strict;
use warnings;

use DDP;

use Local::Web;
use Local::Storage;
use DBIx::Class;
use JSON::XS;

my $print_post = [
	{ command => 'post', 	    	param => 'id' },
];
my $print_user = [
	{ command => 'user', 	   		param => 'name' },
	{ command => 'user', 	    	param => 'post' },
];
my $print_users = [
	{ command => 'self-commentors', param => 'param' }
	
];
my $print_posts = [
	{ command => 'desert_posts',    param => 'n' }
];
sub new{
	my $self = shift;
	my $command = shift;
	my $param = shift;
	my $format = undef;
	my $refresh = undef;
	my $parametr;
	if (exists $param->{format}) {
		$format = $param->{format};
		delete $param->{format};
	}
	if (exists $param->{refresh}) {
		$refresh = $param->{refresh};
		delete $param->{refresh};
	}
	for my $key (keys %$param) { $parametr = $key; }
	return bless { param => $parametr, param_value => $param->{$parametr}, command => $command, format => $format, refresh => $refresh },$self;
}
sub get {
	my $self = shift;
	my $data =[];
	my $storage = Local::Storage->new ($self->{command}, $self->{param}, $self->{param_value});
	if (defined $self->{refresh}) {
		$data = $storage->from_site;
	}
	else{
		$data = $storage->from_mem;
		if (ref $data eq "ARRAY"){
			$data = $storage->from_db unless defined $data->[0];
		}
		else{
			$data = $storage->from_db unless defined $data->{username}
		}
		if (ref $data eq "ARRAY"){
			$data = $storage->from_site unless defined $data->[0];
		}
		else{
			$data = $storage->from_site unless defined $data->{username};
		}
		
	}
	$self->{data} = $data;
}
sub printout{
	my $self = shift;
	my $file = shift;
	$file = "defined" unless defined $file;
	unless ( defined $self->{format} ){
		p $self->{data};
	}
	else{
		if ($self->{format} eq "json"){
			p $self->{data};
		}
		elsif ($self->{format} eq "csv"){
			open (my $fh, ">", $file);
			print $fh $self->{command}.";";
			for my $elem (@{$self->{data}}){
				print $fh $elem.";";
			}
			close $fh;
		}
		elsif ($self->{format} eq "ddp"){
			p $self->{data};
		}
		elsif ($self->{format} eq "jsonl"){
			if (ref $self->{data} eq "ARRAY"){
				for my $elem (@{$self->{data}}){
					my $kek = JSON::XS->new->utf8->encode($elem);
					p $kek;
				}
			}
			else{
				my $kek = JSON::XS->new->utf8->encode($self->{data});
				p $kek;
			}
		}
	}
}

1;