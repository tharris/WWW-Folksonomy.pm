#!/usr/bin/perl

use WWW::Folksonomy::Initialize;
use Pod::Usage;
use Getopt::Long;
use strict;

my ($adaptor,$dsn,$user,$pass,$host);
GetOptions('adaptor=s' => \$adaptor,
	   'dsn=s'     => \$dsn,
	   'user=s'    => \$user,
	   'pass=s'    => \$pass,
	   'host=s'    => \$host,
	  );

pod2usage( -verbose=> 2 ) unless ($dsn);

my $factory = WWW::Folksonomy::Initialize->new(-user   => $user,
				               -pass   => $pass,
				               -host   => $host,
				               -dsn    => $dsn,
				               -create => 1);

# Initialize the database with the default schema
$factory->initialize(1);

__END__


=pod

=head1 NAME

create_schema.pl -- create a new database with the default
WWW::Folksonomy schema

=head1 SYNPOSIS

 create_schema.pl --user todd --pass password --dsn mytags

=head1 OPTIONS

Options:
   adaptor  either dbi::sqlite or dbi::mysql
   dsn      the name of your database
   user     database username if necessary
   pass     database password if necessary
   host     database host, if other than localhost

=head1 AUTHOR

 Todd Harris (harris@cshl.edu)
 $Id$

=cut

