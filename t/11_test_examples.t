#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Cwd qw(getcwd chdir);

$ENV{AUTHOR_TESTING}
    or plan skip_all => 'Set $ENV{AUTHOR_TESTING} to run this test.';

my @data = (
    {
        test   => '01_constants',
        path   => 'example',
        script => '-I../lib 01_constants.pl',
        result => <<'EOT',
$constants = {
  plural_separator => "\0",
  msg_key_separator => "\4",
  lexicon_key_separator => ":"
};
EOT
    },
    {
        test   => '02_join_split',
        path   => 'example',
        script => '-I../lib 02_join_split.pl',
        result => <<'EOT',
[
  "i-default::",
  {},
  "de-de:my category:my domain",
  {
    domain => "my domain",
    language => "de-de",
    category => "my category"
  },
  "",
  {},
  "my singular\0my plural\4my context",
  {
    msgctxt => "my context",
    msgid => "my singular",
    msgid_plural => "my plural"
  }
]
EOT
    },
    {
        test   => '03_extract_header',
        path   => 'example',
        script => '-I../lib 03_extract_header.pl',
        result => <<'EOT',
$extract = {
  plural => "n != 1",
  plural_code => sub { "DUMMY" },
  charset => "UTF-8",
  nplurals => 2
};
EOT
    },
);

plan tests => scalar @data;

for my $data (@data) {
    my $dir = getcwd;
    chdir("$dir/$data->{path}");
    my $result = qx{perl $data->{script} 2>&3};
    chdir($dir);
    eq_or_diff
        $result,
        $data->{result},
        $data->{test};
}
