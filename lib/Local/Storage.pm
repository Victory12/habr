package Local::Storage;

use strict;
use warnings;
use DDP;

use Local::Schema;
use Local::Web;
use Local::DataBase;
use Local::Mem;
use DBIx::Class;
use DBIx::Class::Schema;

my $read_access_site = [
	{ command => 'user', 	    	param => 'name' },
	{ command => 'user', 	    	param => 'post' },
	{ command => 'commenters',  	param => 'post' },
	{ command => 'post', 	    	param => 'id' },
];
my $read_access_db_user = [
	{ command => 'user', 	   		param => 'name' },
];
my $read_access_db_commenters = [
	{ command => 'commenters',  	param => 'post' },
];
my $read_access_db_post = [
	{ command => 'post', 	    	param => 'id' },
];
my $read_access_db_author = [
	{ command => 'user', 	    	param => 'post' },
];
my $read_access_db_count = [
	{ command => 'desert_posts',    param => 'n' }
];
my $read_access_db_selfcom = [
	{ command => 'self-commentors', param => 'param' }
];
my $read_access_mem = [
	{ command => 'user', 	   		param => 'name' },
];
my $write_access_mem = [
	{ command => 'user', 	   		param => 'name' },
	{ command => 'user', 	    	param => 'post' },
];
sub new {
	my $self = shift;
	my $command = shift;
	my $param = shift;
	my $value = shift;
	return bless { param => $param, command => $command, value => $value },$self;
}

sub access{
	my $self = shift;
	my $access_array = shift;
	for my $hash ( @$access_array ) {
		return 1 if ( $hash->{param} eq $self->{param} ) and ( $hash->{command} eq $self->{command} );		
	}
	return 0;
}
sub from_mem{
	print "from mem\n";
	my $self = shift;
	my $data;
	if ( $self->access( $read_access_mem ) == 1 ) {
		my $mem_obj = Local::Mem->new ($self);
		$data = $mem_obj->request;
	}
	return $data;
}
sub from_db{
	print "from db\n";
	my $self = shift;
	my $data;
	my $db_obj = Local::DataBase->new ($self);
	$data = $db_obj->author if $self->access( $read_access_db_author ) == 1;	
	$data = $db_obj->commenters if $self->access( $read_access_db_commenters ) == 1;
	$data = $db_obj->user if $self->access( $read_access_db_user ) == 1;
	$data = $db_obj->post if $self->access( $read_access_db_post ) == 1;
	$data = $db_obj->self_com if $self->access( $read_access_db_selfcom ) == 1;
	$data = $db_obj->com_count if $self->access( $read_access_db_count ) == 1;
	return $data;
}
sub from_site{
	print "from site\n";
	my $self = shift;
	my $data;
	return undef if $self->access( $read_access_site ) == 0;
	my $site_obj = Local::Web->new;
	$site_obj->request_info( $self->{command}, $self->{param}, $self->{value} );
	my $db_obj = Local::DataBase->new ($self, $site_obj);
	$db_obj->in_user if defined $db_obj->{user};
	$db_obj->in_post if defined $db_obj->{post};
	$db_obj->in_user_post if defined $db_obj->{commenters};
	
	if ( $self->access( $write_access_mem ) == 1 ) {
		my $mem_obj = Local::Mem->new ($self, $site_obj);
		$mem_obj->put;
	}
	$data = $self->from_db unless defined $data;
	return $data;
	

}
1;