use Test::More tests => 9;

BEGIN {
use_ok( 'WWW::Folksonomy::Object'    );
use_ok( 'WWW::Folksonomy::Tag'       );
use_ok( 'WWW::Folksonomy::ObjectTag' );
}


diag( "Testing joins of Object and Tag via WWW::Folksonomy::ObjectTag $WWW::Folksonomy::ObjectTag::VERSION" );

# Test insertions and deletions from the perspective of a user

ok(test_connection(),'Testing database connection');

# Deliberately add a new tag to avoid possible duplicate key warnings
my $tag = WWW::Folksonomy::Tag->find_or_create({ raw_tag => 'Golden Retrievers',
                              	                 normalized_tag => 'goldenretrievers',
                                                 });

my $tid = $tag->id;
ok($tag,"Testing find_or_create of a new tag");


# Insert a test object into the DB
# Deliberately add a new object to avoid possible duplicate key warnings
my $object = WWW::Folksonomy::Object->find_or_create({ name        => 'unc-2622',
                                                     class       => 'Gene',
                                                     description => 'phosphatase'});	

my $oid = $object->id;
ok($object,"Testing find_or_create of a new object");

# Insert into the user_tag join table
my $join = WWW::Folksonomy::ObjectTag->find_or_create({ oid => $oid,
                                                        tid => $tid});

my @jid = $join->id;
ok($join,"Testing find_or_create of a new object_tag join: @jid");


# Test join methods
my @objects = $tag->objects_tagged_with();
ok(@objects,"Testing: find all objects with this tag");

my @tags = $object->associated_tags();
ok(@tags,"Testing: find all tags associated with this object");

# Clean up:
#$tag->delete;
#$object->delete;
#$join->delete;   # This should be automagically deleted.


sub test_connection {
   WWW::Folksonomy::Tag->new(-user=>'root',-pass=>'kentwashere',-dsn=>'tags');
}