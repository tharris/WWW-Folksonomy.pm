use Test::More tests => 6;

BEGIN {
use_ok( 'WWW::Folksonomy::Object' );
}

my $table = 'object';

diag( "Testing WWW::Folksonomy::Object $WWW::Folksonomy::Object::VERSION" );

ok(test_connection(),'Testing database connection');


# Test insert;
$object = WWW::Folksonomy::Object->insert({ name  => 'unc-26',
		  	                    class => 'Gene',
                                            description => 'synaptojanin' });

ok($object,"Testing insert into the $table table");
	
# Test update
$object->name('WBGene0000040');
ok($object->update,"Testing update of $table table");
ok($object->name eq 'WBGene0000040',"Testing update and retrieve of $table table");

# Test delete
ok($object->delete,"Testing delete from the $table table");


sub test_connection {
   WWW::Folksonomy::Object->new(-user=>'root',-pass=>'kentwashere',-dsn=>'tags');
}