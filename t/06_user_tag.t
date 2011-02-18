use Test::More tests => 9;

BEGIN {
use_ok( 'WWW::Folksonomy::User'       );
use_ok( 'WWW::Folksonomy::Tag'     );
use_ok( 'WWW::Folksonomy::UserTag' );
}


diag( "Testing joins of User and Tag via WWW::Folksonomy::UserTag $WWW::Folksonomy::UserObject::VERSION" );

# Test insertions and deletions from the perspective of a user

ok(test_connection(),'Testing database connection');

# Insert a user into the primary table
my $user = WWW::Folksonomy::User->find_or_create({ first_name => 'Test',
                                                   last_name  => 'User'});

my $uid = $user->id;
ok($user,"Testing find_or_create of a new user");

# Deliberately add a new object to avoid possible duplicate key warnings
my $tag = WWW::Folksonomy::Tag->find_or_create({ raw_tag => 'Golden Retrievers',
                              	                 normalized_tag => 'goldenretrievers',
                                                 });

my $tid = $tag->id;
ok($tag,"Testing find_or_create of a new tag");

# Insert into the user_tag join table
my $join = WWW::Folksonomy::UserTag->find_or_create({ uid => $uid,
                                                      tid => $tid});

my @jid = $join->id;
ok($join,"Testing find_or_create of a new user_object join: @jid");


# Test join methods of the classes
my @tags = $user->tags_in_use();
ok(@tags,"Testing: find all tags in use by this user");

my @users = $tag->users();
ok(@tags,"Testing: find all users who have added this tag");

# Clean up:
#$user->delete;
#$tag->delete;
###$join->delete;   # This should be automagically deleted.


sub test_connection {
   WWW::Folksonomy::User->new(-user=>'root',-pass=>'kentwashere',-dsn=>'tags');
}