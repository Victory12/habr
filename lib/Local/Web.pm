package Local::Web;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use DDP;
use Mojo::DOM;
use Mojo::Collection;

sub new {
	my $self = shift;
	my $param = shift;
	my $param_value = shift;
	return bless {},  $self;
}
sub request_info{
	my $self = shift;
	my $command = shift;
	my $param = shift;
	my $param_value = shift;
	my $url = create_url( $param, $param_value);
	my $dom = request_html ($url);  #site
	if ($command eq "user" and $param eq "name"){
		$self->request_user( $dom );
	}
	elsif ($command eq "user" and $param eq "post"){
		$self->request_user( $dom );
	}
	elsif ($command eq "commenters" and $param eq "post"){
		$self->request_user( $dom );
		$self->request_post($param_value, $dom );
	}
	elsif ($command eq "post" and $param eq "id"){
		$self->request_user( $dom );
		$self->request_post($param_value, $dom );
	}
	else{
		die print "something wrong with url\n";
	}

}
sub request_user{
	my $self = shift;
	my $dom = shift;
	$self->{user}->{username} = $dom->at('a.author-info__nickname')->text;
	$self->{user}->{username} =~ s/@//;
	$self->{user}->{karma} = $dom->at(".voting-wjt__counter-score")->text;
	$self->{user}->{rating} = $dom->at(".statistic__value")->text;	
}
sub request_post_user{
	my $self = shift;
	my $dom = shift;
	my $i = shift;
	$self->{commenters}->[$i]->{username} = $dom->at('a.author-info__nickname')->text;
	$self->{commenters}->[$i]->{username}=~ s/@//;
	$self->{commenters}->[$i]->{karma} = $dom->at(".voting-wjt__counter-score")->text;
	$self->{commenters}->[$i]->{rating} = $dom->at(".statistic__value")->text;
}
sub request_post{
	my $self = shift;
	my $param_value = shift;
	my $dom = shift;
	
	$self->{post}->{stars} = $dom->at(".favorite-wjt__counter")->text;
	$self->{post}->{postnum} = $param_value;
	$self->{post}->{looking} = $dom->at(".views-count_post")->text;
	$self->{post}->{postname} = $dom->at("a.post__flow")->text;
	$self->{post}->{rating} = $dom->at(".voting-wjt__counter-score")->text;
	$self->{post}->{username} = $dom->at('a.author-info__nickname')->text;
	$self->{post}->{username} =~ s/@//;

	$self->{post}->{comments} = $dom->at("#comments_count")->text;
	my @qwe = $dom->find(".comment-item__username")->map('text')->each;
	my $i = 0;
	my %tmp;
	@qwe = grep {!$tmp{$_}++ } @qwe;
	for my $commenter (@qwe) {
		my $url = create_url( "name", $commenter);
		my $dom1 = request_html ($url);
		$self->request_post_user($dom1, $i);
		$i++;
	}
}
sub request_html{
	my $url = shift;
	my $ua = LWP::UserAgent->new;
    $ua->agent("MSIE 7.0 "); 
    my $req = HTTP::Request->new(GET =>$url); 
    $req->header('Accept'=>'text/html');
    my $res = $ua->request($req);
    my @res = $res->content;
    my $dom = Mojo::DOM->new(@res);
    return $dom;
}
sub create_url{
	my $param = shift;
	my $param_value = shift;
	my $url;
	if ( $param eq "name" ){
		$url = "https://habrahabr.ru/users/$param_value/";
	}
	elsif (  $param eq "post" or  $param eq "id" ){
		$url = "https://habrahabr.ru/post/$param_value/";
	}
	return $url;
}
1;