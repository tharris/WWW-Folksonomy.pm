use Test::More tests => 6;

BEGIN {
use_ok( 'WWW::Folksonomy::User' );
}

my $table = 'user';

diag( "Testing WWW::Folksonomy::User $WWW::Folksonomy::User::VERSION" );

ok(test_connection(),'Testing database connection');


# Test insert;
$person = WWW::Folksonomy::User->insert({ first_name => 'Test',
		  	 last_name => 'User' });

ok($person,"Testing insert into the $table table");
	
# Test update
$person->last_name('New last name');
ok($person->update,"Testing update of $table table");
ok($person->last_name eq 'New last name',"Testing update and retrieve of $table table");

# Test delete
ok($person->delete,"Testing delete from the $table table");


sub test_connection {
   WWW::Folksonomy::User->new(-user=>'root',-pass=>'kentwashere',-dsn=>'tags');
}