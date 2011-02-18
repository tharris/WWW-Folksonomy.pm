use Test::More tests => 9;

BEGIN {
use_ok( 'WWW::Folksonomy::User'       );
use_ok( 'WWW::Folksonomy::Object'     );
use_ok( 'WWW::Folksonomy::UserObject' );
}


diag( "Testing joins of User and Object via WWW::Folksonomy::UserObject $WWW::Folksonomy::UserObject::VERSION" );

# Test insertions and deletions from the perspective of a user

ok(test_connection(),'Testing database connection');

# Insert a user into the primary table
my $user = WWW::Folksonomy::User->find_or_create({ first_name => 'Test',
                                                   last_name  => 'User'});

my $uid = $user->id;
ok($user,"Testing find_or_create of a new user");

# Deliberately add a new object to avoid possible duplicate key warnings
my $object = WWW::Folksonomy::Object->find_or_create({ name        => 'unc-2622',
                                                     class       => 'Gene',
                                                     description => 'phosphatase'});	

my $oid = $object->id;
ok($object,"Testing find_or_create of a new object");

# Insert into the user_object join table
my $join = WWW::Folksonomy::UserObject->find_or_create({ uid => $uid,
                                                         oid => $oid});

my @jid = $join->id;
ok($join,"Testing find_or_create of a new user_object join: @jid");


# Test join methods of the classes
my @tagged_objects = $user->tagged_objects();
ok(@tagged_objects,"Testing: find all objects tagged by this user");

my @all_users = $object->users_who_have_tagged();
ok(@all_users,"Testing: find all users who have tagged this object");


# Alternatively, using the tagged_objects method of User...
#my $object = $user->add_to_tagged_objects({ name        => 'unc-2622',
#                                            class       => 'Gene',
#                                            description => 'phosphatase'});	
#
#ok($object,"Testing insertion into user_object join and object table");


# Clean up:
#$user->delete;
#$object->delete;
##$join->delete;   # This should be automagically deleted.


sub test_connection {
   WWW::Folksonomy::User->new(-user=>'root',-pass=>'kentwashere',-dsn=>'tags');
}