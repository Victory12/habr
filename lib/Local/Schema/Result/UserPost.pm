use utf8;
package Local::Schema::Result::UserPost;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Local::Schema::Result::UserPost

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<user_post>

=cut

__PACKAGE__->table("user_post");

=head1 ACCESSORS

=head2 username

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 30

=head2 postnum

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "username",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 30,
  },
  "postnum",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</username>

=item * L</postnum>

=back

=cut

__PACKAGE__->set_primary_key("username", "postnum");

=head1 RELATIONS

=head2 postnum

Type: belongs_to

Related object: L<Local::Schema::Result::Post>

=cut

__PACKAGE__->belongs_to(
  "postnum",
  "Local::Schema::Result::Post",
  { postnum => "postnum" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 username

Type: belongs_to

Related object: L<Local::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "username",
  "Local::Schema::Result::User",
  { username => "username" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2016-12-08 21:17:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eg07+H0+xLc+tVNeAA+2IA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
