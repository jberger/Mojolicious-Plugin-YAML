package Mojolicious::Plugin::YAML;

use Mojo::Base 'Mojolicious::Plugin';

use Carp ();

our $YAML;
BEGIN {
  if (eval { require YAML::PP::LibYAML; 1 }) {
    $YAML = YAML::PP::LibYAML->new;
  } elsif (eval { require YAML::PP; 1 }) {
    $YAML = YAML::PP->new;
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

  $app->renderer->add_handler(yaml => sub {
    my ($renderer, $c, $output, $options) = @_;

    # Disable automatic encoding
    delete $options->{encoding};

    $c->app->types->content_type($c, {ext => 'yaml'});
    $$output = $YAML->dump_string(delete $c->stash->{yaml});
  });

  # Set "handler" value automatically if "yaml" value is set already
  $app->hook(before_render => sub {
    my ($c, $args) = @_;
    $args->{handler} = 'yaml'
      if exists $args->{yaml} || exists $c->stash->{yaml};
  });
}

1;

