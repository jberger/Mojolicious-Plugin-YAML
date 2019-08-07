use Mojolicious::Lite;

use Test::More;
use Test::Mojo;

plugin 'YAML';

use YAML::PP;

get '/' => { yaml => { content => "Mojo \x{2764} YAML" } };

my $t = Test::Mojo->new;

$t->get_ok('/')
  ->status_is(200)
  ->content_type_is('text/yaml');

my $got = YAML::PP->new->load_string($t->tx->res->body);
is_deeply $got, { content => 'Mojo ❤ YAML' }, 'simple yaml document rendered correctly';

done_testing;

