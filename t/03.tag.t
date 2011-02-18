use Test::More tests => 6;

BEGIN {
use_ok( 'WWW::Folksonomy::Tag' );
}

my $table = 'tag';

diag( "Testing WWW::Folksonomy::Tag $WWW::Folksonomy::Tag::VERSION" );

ok(test_connection(),'Testing database connection');


# Test insert;
$tag = WWW::Folksonomy::Tag->insert({ raw_tag => 'Paradise Valley, MT',
		  	 normalized_tag => 'paradisevalleymt' });

ok($tag,"Testing insert into the $table table");
	
# Test update
$tag->raw_tag("Cold Spring Harbor, NY");
$tag->normalized_tag("coldspringharborny");
ok($tag->update,"Testing update of $table table");
ok($tag->normalized_tag eq 'coldspringharborny',"Testing update and retrieve of $table table");

# Test delete
ok($tag->delete,"Testing delete from the $table table");


sub test_connection {
   WWW::Folksonomy::Tag->new(-user=>'root',-pass=>'kentwashere',-dsn=>'tags');
}