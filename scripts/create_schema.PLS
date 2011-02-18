#!perl
use Config;
use File::Basename qw(&basename &dirname);
use Cwd;

$origdir = cwd;
chdir dirname($0);
$file = basename($0, '.PL','.PLS');
$file .= $^O eq 'VMS' ? '.com' : '.pl';

open OUT,">$file" or die "Can't create $file: $!";

print "Extracting $file (with variable substitutions)\n";

print OUT <<"!GROK!THIS!";
$Config{startperl}
!GROK!THIS!

# In the following, perl variables are not expanded during extraction.

print OUT <<'!NO!SUBS!';

use WWW::Folksonomy::Initialize;
use Pod::Usage;
use Getopt::Long;
use strict;

my ($dsn,$user,$pass,$host);
GetOptions('dsn=s'     => \$dsn,
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

!NO!SUBS!
close OUT or die "Can't close $file: $!";
chmod 0755, $file or die "Can't reset permissions for $file: $!\n";
exec("$Config{'eunicefix'} $file") if $Config{'eunicefix'} ne ':';
chdir $origdir;
