package Mojolicious::Plugin::YAML;

use Mojo::Base 'Mojolicious::Plugin';

use Carp ();

our $YAML;
BEGIN {
  if (eval { require YAML::PP::LibYAML; 1 }) {
    $YAML = 'YAML::PP::LibYAML';
  } elsif (eval { require YAML::PP; 1 }) {
    $YAML = 'YAML::PP';
  } else {
    Carp::croak 'One of YAML::PP or YAML::PP::LibYAML is required';
  }
}

sub register {
  my ($plugin, $app, $conf) = @_;
  my $types = [qw[
    text/yaml
    text/x-yaml
    text/vnd.yaml
    application/yaml
    application/x-yaml
    application/vnd.yaml
  ]];
  $app->types->type($_ => $types) for qw/yml yaml/;

  my $yaml = $YAML->new;
  $app->helper('yaml.dump' => sub { $yaml->dump_string($_[1]) });

  $app->renderer->add_handler(yaml => sub {
    my ($renderer, $c, $output, $options) = @_;

    # Disable automatic encoding
    delete $options->{encoding};

    my $app = $c->app;
    $app->types->content_type($c, {ext => 'yaml'});
    $$output = $app->renderer->get_helper('yaml.dump')->($c, delete $c->stash->{yaml});
  });

  # Set "handler" value automatically if "yaml" value is set already
  $app->hook(before_render => sub {
    my ($c, $args) = @_;
    $args->{handler} = 'yaml'
      if exists $args->{yaml} || exists $c->stash->{yaml};
  });
}

1;

