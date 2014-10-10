#!perl ## no critic (TidyCode)

use strict;
use warnings;

use Data::Dumper ();
use Locale::TextDomain::OO::Extract::HTML;
use Path::Tiny qw(path);

our $VERSION = 0;

my $extractor = Locale::TextDomain::OO::Extract::HTML->new(
    # In case of multiple extractors extract into the same array reference.
    # Parameter lexicon_ref is optional. If not set, there is a default.
    # Get back all of this by: $extractor->lexicon_ref
    lexicon_ref => \my %lexicon,
);

my @files
    = map { path($_) }
    qw(
        ./files_to_extract/text.html
    );

for my $file (@files) {
    $extractor->filename( $file->relative( q{./} )->stringify );
    $extractor->content_ref( \( $file->slurp_utf8 ) );
    $extractor->extract;
}

() = print {*STDOUT} Data::Dumper ## no critic (LongChainsOfMethodCalls)
    ->new( [ $extractor->lexicon_ref ], [ 'lexicon_ref' ] )
    ->Indent(1)
    ->Quotekeys(0)
    ->Sortkeys(1)
    ->Useqq(1)
    ->Dump;

# $Id: 14_extract_html.pl 517 2014-10-09 13:52:18Z steffenw $

__END__

Output:

$lexicon_ref = {
  "i-default::" => {
    "" => {
      msgstr => {
        nplurals => 2,
        plural => "n != 1"
      }
    },
    "This is a p text." => {
      msgid => "This is a p text.",
      reference => {
        "files_to_extract/text.html:8" => undef
      }
    },
    "This is an a text." => {
      msgid => "This is an a text.",
      reference => {
        "files_to_extract/text.html:10" => undef,
        "files_to_extract/text.html:13" => undef
      }
    }
  }
};
