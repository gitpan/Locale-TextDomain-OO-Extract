#!perl ## no critic (TidyCode)

use strict;
use warnings;

use Data::Dumper ();
use Locale::TextDomain::OO::Util::ExtractHeader;

our $VERSION = 0;

my $extractor = Locale::TextDomain::OO::Util::ExtractHeader->instance;

() = print {*STDOUT} Data::Dumper ## no critic (LongChainsOfMethodCalls)
    ->new(
        [
            $extractor->extract_header_msgstr(<<'EOT'),
Content-Type: text/plain; charset=UTF-8
Plural-Forms: nplurals=2; plural=n != 1
EOT
        ],
        [ qw( extract ) ],
    )
    ->Indent(1)
    ->Quotekeys(0)
    ->Useqq(1)
    ->Dump;

# $Id$

__END__

Output:

$extract = {
  plural => "n != 1",
  plural_code => sub { "DUMMY" },
  charset => "UTF-8",
  nplurals => 2
};
