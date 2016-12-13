use utf8;
package Local::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Local::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 rating

  data_type: 'float'
  is_nullable: 1

=head2 karma

  data_type: 'float'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "username",
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "rating",
  { data_type => "float", is_nullable => 1 },
  "karma",
  { data_type => "float", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->set_primary_key("username");

=head1 RELATIONS

=head2 posts

Type: has_many

Related object: L<Local::Schema::Result::Post>

=cut

__PACKAGE__->has_many(
  "posts",
  "Local::Schema::Result::Post",
  { "foreign.username" => "self.username" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_posts

Type: has_many

Related object: L<Local::Schema::Result::UserPost>

=cut

__PACKAGE__->has_many(
  "user_posts",
  "Local::Schema::Result::UserPost",
  { "foreign.username" => "self.username" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 postnums

Type: many_to_many

Composing rels: L</user_posts> -> postnum

=cut

__PACKAGE__->many_to_many("postnums", "user_posts", "postnum");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2016-12-08 23:02:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DiQK1fJDvOBZC5Cysyft3w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
