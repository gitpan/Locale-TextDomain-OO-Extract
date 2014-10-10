#!perl ## no critic (TidyCode)

use strict;
use warnings;
use utf8;

use Data::Dumper ();
use Locale::TextDomain::OO::Extract::TT;
use Path::Tiny qw(path);

our $VERSION = 0;

my $extractor = Locale::TextDomain::OO::Extract::TT->new(
    # In case of multiple extractors extract into the same array reference.
    # Parameter lexicon_ref is optional. If not set, there is a default.
    # Get back all of this by: $extractor->lexicon_ref
    lexicon_ref => \my %lexicon,
);

my @files
    = map { path($_) }
    qw(
        ./files_to_extract/template.tt
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

# $Id: 12_extract_tt.pl 517 2014-10-09 13:52:18Z steffenw $

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
    "Text \x{c4}" => {
      msgid => "Text \x{c4}",
      reference => {
        "files_to_extract/template.tt:9" => undef
      }
    },
    "Text \x{d6}" => {
      msgid => "Text \x{d6}",
      reference => {
        "files_to_extract/template.tt:13" => undef
      }
    },
    "Text \x{dc}" => {
      msgid => "Text \x{dc}",
      reference => {
        "files_to_extract/template.tt:16" => undef
      }
    }
  }
};
