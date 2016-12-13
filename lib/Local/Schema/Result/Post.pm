use utf8;
package Local::Schema::Result::Post;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Local::Schema::Result::Post

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<post>

=cut

__PACKAGE__->table("post");

=head1 ACCESSORS

=head2 postnum

  data_type: 'integer'
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 30

=head2 rating

  data_type: 'float'
  is_nullable: 1

=head2 views

  data_type: 'integer'
  is_nullable: 1

=head2 stars

  data_type: 'integer'
  is_nullable: 1

=head2 postname

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=cut

__PACKAGE__->add_columns(
  "postnum",
  { data_type => "integer", is_nullable => 0 },
  "username",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 30 },
  "rating",
  { data_type => "float", is_nullable => 1 },
  "views",
  { data_type => "integer", is_nullable => 1 },
  "stars",
  { data_type => "integer", is_nullable => 1 },
  "postname",
  { data_type => "varchar", is_nullable => 1, size => 30 },
);

=head1 PRIMARY KEY

=over 4

=item * L</postnum>

=back

=cut

__PACKAGE__->set_primary_key("postnum");

=head1 RELATIONS

=head2 user_posts

Type: has_many

Related object: L<Local::Schema::Result::UserPost>

=cut

__PACKAGE__->has_many(
  "user_posts",
  "Local::Schema::Result::UserPost",
  { "foreign.postnum" => "self.postnum" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 username

Type: belongs_to

Related object: L<Local::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "username",
  "Local::Schema::Result::User",
  { username => "username" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 usernames

Type: many_to_many

Composing rels: L</user_posts> -> username

=cut

__PACKAGE__->many_to_many("usernames", "user_posts", "username");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2016-12-08 23:02:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yotirmA/Odd+H3qbTqcKtA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
