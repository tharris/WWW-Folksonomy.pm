package WWW::Folksonomy::Template;

# Generate some pretty templates
# This will include:
#    three inline panels (user, public, electronic)

# A page which shows all tags for a user as an alphabetical list
# A page which shows all tags for a user as a tag cloud
# A page which shows the most popular tags for an object as a tag cloud or list
# A page which show the most popular tags as a tag cloud


use strict;
use CGI;
use Template;


# We have one method, which returns everything you need to send to
# STDOUT, including the Content-Type: header.

sub output {
  my ($class, %args) = @_;
  
  my $config = Bookworms::Config->new;
  my $template_path = $config->get_var( "template_path" );
  my $tt = Template->new( { INCLUDE_PATH => $template_path } );
  
  my $tt_vars = $args{vars} || {};
  $tt_vars->{site_name} = $config->get_var( "site_name" );
  
  my $header = CGI::header;
  
  my $output;
  $tt->process( $args{template}, $tt_vars, \$output)
    or croak $tt->error;
  return $header . $output;
}

