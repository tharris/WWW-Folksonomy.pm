#!/usr/bin/perl

use strict;

use WWW::Folksonomy::User;

WWW::Folksonomy::User->new(-user=>'root',-pass=>'kentwashere',-dsn=>'tags');


my $person = WWW::Folksonomy::User->insert({ first_name => 'Test',
					     last_name => 'User' });

print $person->last_name;
