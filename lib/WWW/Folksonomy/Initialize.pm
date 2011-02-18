package WWW::Folksonomy::Initialize;

use warnings;
use strict;
use Carp;
use DBI;

use WWW::Folksonomy::Util::Rearrange;

use version; our $VERSION = qv('0.0.3');

use constant MYSQL => 'mysql';

# Other recommended modules (uncomment to use):
#  use IO::Prompt;
#  use Perl6::Export;
#  use Perl6::Slurp;
#  use Perl6::Say;

sub new {
  my ($class,@args) = @_;
  my ($db,$host,$user,$auth,$create)
    = rearrange([
  		 [qw(DB DSN DATABASE)],
  		 [qw(HOST)],
  		 [qw(USERNAME USER)],
  		 [qw(PASSWORD PASS)],
		 'CREATE'
  		],@args);
  
  $host ||= 'localhost';
  _create_database($user,$auth,$host,$db) if ($create);
  my $dbh;

  if ($auth && $user) {
    $dbh = DBI->connect("dbi:mysql:$db" . ';host=' . $host,$user,$auth)
  } elsif ($user) {
    $dbh = DBI->connect("dbi:mysql:$db" . ';host=' . $host,$user);
  } else {
    $dbh = DBI->connect("dbi:mysql:$db" . ';host=' . $host);
  }
  
  $dbh or  die "Couldn't connect to the database $db\n";
  # fill in object, bless it, and send us on our way
  return bless { dbh => $dbh },$class;
}

sub initialize {
  my ($self,$erase) = @_;
  if (defined $self->{shout}) { print STDERR "Initializing database...\n"; };
  $self->drop_all if $erase;

  my $dbh = $self->dbh;
  my ($schema,$raw_schema) = $self->schema;
  foreach (values %$schema) {
    $dbh->do($_) || warn $dbh->errstr . ": $_";
  }
  1;
}


# Create the schema from scratch.
# You will need create privileges for this.
sub _create_database {
  my ($user,$auth,$host,$db) = @_;
  my $success = 1;
  my $command =<<END;
${\MYSQL} -u $user -p$auth -h $host -e "create database $db"
END

  my $failure = system($command);
  return 1 if !$failure;
  die "Couldn't create the database $db" if $failure;
}


# Drop all the tables -- dangerous!
sub drop_all {
  my $self = shift;
  my $dbh = $self->dbh;
  local $dbh->{PrintError} = 0;
  foreach ($self->tables) {
    $dbh->do("drop table $_");
  }
}

sub tables {
  my ($schema,$raw_schema) = shift->schema;
  return keys %$schema;
}


sub schema {
  my $tables = {};
  push (@{$tables->{user}},
	{  uid        =>  'int not null auto_increment' },
	{  first_name =>  'text'                        },
	{  last_name  =>  'text'                        },
	{  login      =>  'text'                        },
	{  email      =>  'text'                        },
	{  pass       =>  'text'                        },
	{ 'primary key(uid)' => 1                 },
	{ 'INDEX(last_name(12))'      => 1                 }
       );
  
  push (@{$tables->{tag}},
	{  tid                        =>  'int not null auto_increment' },
	{  raw_tag                    => 'text'                   },
	{  normalized_tag             => 'text'                   },
        {  tag_count                  => 'int'                    },
	{ 'primary key(tid)'          => 1                        },
	{ 'INDEX(raw_tag(12))'        => 1                        },
	{ "INDEX(normalized_tag(8))"  => 1                        }
       );
  
  push (@{$tables->{object}},
	{  oid               =>     'int not null auto_increment' },
	{  name              =>     'text' },
	{  class             =>     'text' },
        {  description       =>     'text' },
	{ 'primary key(oid)' => 1    },
	{ 'INDEX(name(10))'  => 1    },
	{ 'INDEX(class(8))'  => 1    },
	{ 'INDEX(class(10))'  => 1    },
       );
  
  # Join tables
  push (@{$tables->{user_object}},
	{ uid       =>     'int not null'   },
	{ oid       =>     'int not null'   },
	{ 'primary key(uid,oid)' => 1 });
  
  push (@{$tables->{object_tag}},
	{ oid       =>     'int not null'   },
	{ tid       =>     'int not null'   },
	{ 'primary key(oid,tid)' => 1 });
  
  push (@{$tables->{user_tag}},
	{ uid       =>     'int not null'   },
	{ tid       =>     'int not null'   },
	{ 'primary key(uid,tid)' => 1 });
  
  # The primary fact table
  push (@{$tables->{user_object_tag}},
	{ uid       =>     'int not null'   },
	{ tid       =>     'int not null'   },
	{ oid       =>     'int not null'   },
	{ tag_status =>    "ENUM('private','public')" },
	{ 'primary key(oid,tid,uid)' => 1 });
  
  my %schema;
  foreach my $table (keys %$tables) {
    my $create = "create table $table (";
    my $count;
    foreach my $param (@{$tables->{$table}}) {
      $count++;
      # Append a comma to the previous entry, but only if this
      # isn't the first...
      $create .= ',' if ($count > 1);
      
      my ($key) = keys %$param;
      my ($val) = values %$param;
      if ($val eq '1') {
	$create .= $key;
      } else {
	$create .= $key . ' ' . $val;
	# $create .= $key . ' ' . $val . ',';
      }
    }
    $create .= ')';
    $schema{$table} = $create;
  }
  return (\%schema,$tables);
}

sub dbh      { shift->{dbh} }

sub DESTROY {
  my $self = shift;
  $self->dbh->disconnect if defined $self->dbh;
}

sub debug {
  my $self = shift;
  $self->dbh->debug(@_);
  $self->SUPER::debug(@_);
}




1;

__END__

=head1 NAME

WWW::Folksonomy::Initialize - database specific  tasks

=head1 VERSION

This document describes WWW::Folksonomy version 0.0.1


=head1 SYNOPSIS

   use WWW::Folksonomy::Initialize;
   my $folk = WWW::Folksonomy::DB->new(-user    => 'user',
	                	       -pass    => 'password',
		                       -host    => 'db_host',
		                       -dsn     => 'folksonomy',
		                       );

   $folk->initialize(1);

=head1 DESCRIPTION

=head1 INTERFACE 

=head2 new

Title   : new
  Usage   : $db = Folksonomy->new(@args)
  Function: create a new adaptor
  Returns : a Folksonomy object
  Args    : see below
  Status  : Public
  
  Argument    Description
  --------    -----------
  -dsn        the DBI data source, e.g. 'dbi:mysql:music_db' or "music_db"
  Also accepts DB or database as synonyms.
  -user       username for authentication
  -pass       the password for authentication

=head2 _create_database

Title   : _create_database
  Usage   : _create_database(user,pass,host,db)
  Function: create the database
  Returns : a boolean indicating the success of the operation
  Args    : username, password, host and database
  Status  : protected

Called internally by new to create the database if it does not already
exist.

=head2 initialize()

 Title   : initialize
 Usage   : $mp3->initialize(-erase=>$erase);
 Function: initialize a new database
 Returns : true if initialization successful
 Args    : a set of named parameters
 Status  : Public

This method can be used to initialize an empty database.  It takes the following
named arguments:

  -erase     A boolean value.  If true the database will be wiped clean if it
             already contains data.

A single true argument ($mp3->initialize(1) is the same as initialize(-erase=>1).
Future versions may support additional options for initialization and database
construction (ie custom schemas).

=head2 drop_all

 Title   : drop_all
 Usage   : $dbh->drop_all
 Function: empty the database
 Returns : void
 Args    : none
 Status  : protected

This method drops the tables known to this module.  Internally it
calls the abstract tables() method to get a list of all tables to
drop.

=head2 tables

 Title   : tables
 Usage   : @tables = $db->tables
 Function: return a list of tables that belong to this module
 Returns : list of tables
 Args    : none
 Status  : protected

=head2 schema

 Title   : schema
 Usage   : ($schema,$raw_schema) = $mp3->schema
 Function: return the CREATE script for the schema and 
           the raw_schema as a hashref
           for easily accessing columns in proper order.
 Returns : a hash of CREATE statements; hash of tables and parameters
 Args    : none
 Status  : protected

This method returns a list containing the various CREATE statements
needed to initialize the database tables. Each create statement
is built programatically so I can maintain all fields in a central
location . This raw schema is returned for building temporary tables
for loading.

=head2 dbh

 Title   : dbh
 Usage   : $dbh->dbh
 Function: get database handle
 Returns : a DBI handle
 Args    : none
 Status  : Public


=head2 DESTROY

 Title   : DESTROY
 Usage   : $dbh->DESTROY
 Function: disconnect database at destruct time
 Returns : void
 Args    : none
 Status  : protected

This is the destructor for the class.

=head2 debug

 Title   : debug
 Usage   : $dbh = $dbh->debug
 Function: prints out debugging information
 Returns : debugging information
 Args    : none
 Status  : Private

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
