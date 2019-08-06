package Mojolicious::Plugin::YAML;

use Mojo::Base 'Mojolicious::Plugin';

use YAML 'Dump';

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
    $$output = Dump delete $c->stash->{yaml};
  });

  # Set "handler" value automatically if "yaml" value is set already
  $app->hook(before_render => sub {
    my ($c, $args) = @_;
    $args->{handler} = 'yaml'
      if exists $args->{yaml} || exists $c->stash->{yaml};
  });
}

1;

