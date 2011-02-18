package WWW::Folksonomy::User;

use warnings;
use strict;
use Carp;
use base 'WWW::Folksonomy';

use WWW::Folksonomy::Util::Rearrange;

use version; our $VERSION = qv('0.0.3');

# Declare the table to Class::DBI
__PACKAGE__->table('user');
__PACKAGE__->columns(All => qw/uid first_name last_name login pass/);
__PACKAGE__->columns(Primary => qw/uid/);
__PACKAGE__->columns(Others  => qw/last_name/);

# has_many relationships (tables that store our primary key)
# Find all objects tagged by this user
__PACKAGE__->has_many(tagged_objects =>
		      ['WWW::Folksonomy::UserObject' => 'oid']);

# Find all tags added by this user
__PACKAGE__->has_many(tags_in_use =>
		      ['WWW::Folksonomy::UserTag' => 'tid']);






# Find all tags for a given user and object
# This is going to require some custom SQL statements
__PACKAGE__->has_many(object_tags =>
			       ['WWW::Folksonomy::UserObjectTag' => 'uid']);


# Find all tags for a given object and user
__PACKAGE__->set_sql(all_user_tags_for_object => qq{ SELECT
raw_tag,normalized_tag,tag_count
FROM
tag,user_object_tag
WHERE user_object_tag.uid=?
AND user_object_tag.oid=?
AND user_object_tag.tid=tag.tid});

# Find all PRIVATE tags for a given object and user
__PACKAGE__->set_sql(all_private_user_tags_for_object => qq{ SELECT
raw_tag,normalized_tag,tag_count
FROM
tag,user_object_tag
WHERE user_object_tag.uid=?
AND user_object_tag.oid=?
AND user_object_tag.tid=tag.tid
AND tag_status="private"});


1;

__END__

=head1 NAME

WWW::Folksonomy::User

=head1 VERSION

This document describes WWW::Folksonomy::User version 0.0.1

=head1 SYNOPSIS

use WWW::Folksonomy::User;
WWW::Folksonomy::User->new(-user=>'user',-pass=>'pass',-dsn=>$dsn);

my $user = WWW::Folksonomy::User->find_or_create(-last_name=>'User',
                                                 -first_name=>'Test');

# Get all objects that this user has tagged
my @objects = $user->tagged_objects();

# Get all tags in use by this user
my @tags = $user->tags_in_use();

# Display them as a tag cloud...

=head1 DESCRIPTION

__PACKAGE__ provides a table-to-class mapping of the "user" table in
the WWW::Folksonomy schema. Instances of this class can be used to:

1. Insert a new user into the database
2. Find and display all objects that a specific user has tagged
3. Find and display all tags that a specific user has applied
4. Find all tags for a single object that a specific user has applied

See the method descriptions below for additional details.

=head1 INTERFACE 

=head2 new(@options)

   FILL THIS IN

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
WWW::Folksonomy requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-www-folksonomy@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Todd W. Harris  C<< <harris@cshl.edu> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Todd W. Harris C<< <harris@cshl.edu> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
