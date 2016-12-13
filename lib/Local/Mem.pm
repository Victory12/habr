package Local::Mem;

use strict;
use warnings;
use DDP;
use Cache::Memcached::Fast;

my $write_access_mem = [
	{ command => 'user', 	   		param => 'name' },
	{ command => 'user', 	    	param => 'post' },
];
sub new {
	my $self = shift;
	my $obj = shift;
	my $site_obj = shift;
	return bless { 
		param => $obj->{param},
		value => $obj->{value},
		command => $obj->{command}, 
		user => $site_obj->{user}, 
		},$self;
}

sub put{
	my $self = shift;
	my $mem = $self->connect_mem;
	my $key = $self->{user}->{username};
	my $value = $self->{user};
	my $res = $mem->add($key, $value);
	print "error you cant put value in Memcached\n" unless $res == 1;
}
sub request{
	my $self = shift;
	my $mem = $self->connect_mem;
	my $data = $mem->get($self->{value});	
	return $data;
}
sub connect_mem {
	my $memd = Cache::Memcached::Fast->new({
		servers => [
		'127.0.0.1:12345',
		],
		namespace => 'my:',
		connect_timeout => 0.2,
      	close_on_error => 1,
	});
	return $memd;
}