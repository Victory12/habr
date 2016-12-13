package Local::DataBase;

use strict;
use warnings;
use DDP;
use Local::Schema;
use Local::Web;
use DBIx::Class;
use DBIx::Class::Schema;
use DBIx::Class::Storage;
sub new {
	my $self = shift;
	my $obj = shift;
	my $site_obj = shift;
	return bless { 
		param => $obj->{param},
		value => $obj->{value},
		command => $obj->{command}, 
		user => $site_obj->{user}, 
		post => $site_obj->{post} ,
		commenters => $site_obj->{commenters}},$self;
}

sub author{
	#print "author\n";
	my $self = shift;
	my $schema = connect_db();
	my @user = $schema->resultset('User')->search(
		{"posts.postnum" => $self->{value}},
		{
			join => 'posts',
		}
	);
	return user_columns_output( $user[0] );
}
sub commenters{
	my $self = shift;
	my $schema = connect_db();
	my @value;
	my @users = $schema->resultset("User")->search(
		{ "user_posts.postnum" => $self->{value}},
		{
			join => 'user_posts',
		}
	);
	for my $user (@users){
		my @array = user_columns_output( $user );
		push @value, @array;
	}
	return \@value;
}
sub user {
	my $self = shift;
	my $schema = connect_db();	
	my @user = $schema->resultset('User')->search(
		{"me.username" => $self->{value}},
		
	);
	return user_columns_output( $user[0] );
}
sub post{
	my $self = shift;
	my $schema = connect_db();
	my @post = $schema->resultset('Post')->search(
		{"me.postnum" => $self->{value}},
		
	);
	return post_columns_output( $post[0] );
}
sub com_count{
	my $self = shift;
	my $schema = connect_db();
	my @value;
	$schema->storage->debug(1);
	my @posts = $schema->resultset("Post")->search(
		undef,
		{
			join => 'user_posts',
			having => { 'count(user_posts.postnum)' => { '>', $self->{value} } },
			group_by => [qw/user_posts.postnum/]
		}
	);
	for my $post (@posts){
		my @array = post_columns_output( $post );
		push @value, @array;
	}
	return \@value;
}

sub self_com{
	my $self = shift;
	print "in self_com\n";
	my $schema = connect_db();
	my @res;
	my @ret;
	my @posts = $schema->resultset("Post")->search(
		undef,{
			join => "username",
			columns => [qw/username postnum/]
		}
	);
	for my $elem (@posts){
		my @value = $schema->resultset("UserPost")->search({
			username => $elem->{_column_data}->{username},
			postnum =>  $elem->{_column_data}->{postnum},
		});
		push @res, $value[0]->{_column_data}->{username} if defined $value[0]->{_column_data}->{username};
	}
	for my $user (@res){
		my @users = $schema->resultset("User")->search({
			username => $user,
		});
		
		my @array = user_columns_output( $users[0] );
		push @ret, $array[0];
	}
	return \@ret;
}

sub in_user{
	print "in_user\n";
	my $self = shift;
	my $schema = connect_db();
	if ($self->db_controll($schema,"User","username", $self->{user}->{username})){
		user_columns_put ($self->{user}, $schema);
	}
}
sub in_post{
	print "in_post\n";
	my $self = shift;
	my $schema = connect_db();
	if ($self->db_controll($schema,"Post","postnum", $self->{post}->{postnum})){
		post_columns_put ($self->{post}, $schema);
	}
}
sub in_user_post{
	print "in_user_post\n";
	my $self = shift;
	my $schema = connect_db();
	for my $user (@{$self->{commenters}}){
		if ($self->db_controll($schema,"User","username", $user->{username})){
			user_columns_put ($user, $schema);
			
		}
		
		if ( $self->db_controll($schema,"UserPost","username", $user->{username}) || $self->db_controll($schema,"UserPost","postnum", $user->{username}) ){
			user_post_columns_put ($self->{post}, $user, $schema);	
		}
	}
}
sub post_columns_output{
	my @inf = @_;
	my $postnum = $inf[0]->{_column_data}->{postnum};
	my $rating = $inf[0]->{_column_data}->{rating};
	my $stars = $inf[0]->{_column_data}->{stars};
	my $views = $inf[0]->{_column_data}->{views};
	my $postname = $inf[0]->{_column_data}->{postname};
	my $username = $inf[0]->{_column_data}->{username};
	my %value = ( postnum  => $postnum, 
				  rating   => $rating, 
				  stars    => $stars, 
				  views   => $views,
				  postname => $postname, 
				  username =>$username);

	return \%value;
}
sub user_columns_output{
	my $user = shift;
	my $username = $user->{_column_data}->{username};
	my $karma = $user->{_column_data}->{karma};
	my $rating = $user->{_column_data}->{rating};
	my %value = (karma => $karma, rating => $rating, username => $username);
	return \%value;
}
sub user_columns_put{
	my $user = shift;
	my $schema = shift;
	my $users = $schema->resultset('User')->new_result({
			username => $user->{username},
			karma => $user->{karma},
			rating => $user->{rating},
	});
	$users->insert();
}
sub post_columns_put{
	my $post = shift;
	my $schema = shift;
	my $posts = $schema->resultset('Post')->new_result({
				postnum => $post->{postnum},
				rating => $post->{rating},
				stars => $post->{stars},
				views => $post->{looking},
				postname => $post->{postname},
				username => $post->{username},
			});
	$posts->insert();
}
sub user_post_columns_put{
	my $post = shift;
	my $user = shift;
	my $schema = shift;
	my $user_post = $schema->resultset('UserPost')->new_result({
				username => $user->{username},
				postnum => $post->{postnum},			
			});
	$user_post->insert();
}
sub connect_db{
	my $schema = Local::Schema->connect('dbi:mysql:data:localhost', 'root', 'testtest');
	return $schema;
}
sub db_controll{
	my $self = shift;
	my $schema = shift;
	my $name = shift;
	my $column = shift;
	my $value = shift;
	#my @qwe = $schema->resultset($name)->all;
	#p @qwe;
	my @result = $schema->resultset($name)->search({ $column => $value});
	print "exist in db\n" if $#result > -1;
	return undef if $#result > -1; 
	return 1;
}
1;