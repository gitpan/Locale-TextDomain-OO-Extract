#!perl ## no critic (TidyCode)

use strict;
use warnings;

use Data::Dumper ();
use Locale::TextDomain::OO::Extract::Perl;
use Path::Tiny qw(path);

our $VERSION = 0;

my $extractor = Locale::TextDomain::OO::Extract::Perl->new(
    # In case of multiple extractors extract into the same array reference.
    # Parameter lexicon_ref is optional. If not set, there is a default.
    # Get back all of this by: $extractor->lexicon_ref
    lexicon_ref => \my %lexicon,
);

my @files
    = map { path($_) }
    qw(
        ./files_to_extract/gettext.pl
        ./files_to_extract/maketext.pl
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

# $Id: 11_extract_perl.pl 291 2010-01-17 10:44:30Z steffenw $

__END__

Output:

$lexicon_ref = {
  "i-default::" => {
    "" => {
      msgstr => {
        nplurals => 2,
        plural => "n != 1",
        plural_code => sub { "DUMMY" }
      }
    },
    "Singular\0Plural" => {
      msgid => "Singular",
      msgid_plural => "Plural",
      reference => {
        "files_to_extract/gettext.pl:24" => undef,
        "files_to_extract/gettext.pl:29" => undef
      }
    },
    "This is a text." => {
      msgid => "This is a text.",
      reference => {
        "files_to_extract/gettext.pl:16" => undef,
        "files_to_extract/maketext.pl:16" => undef
      }
    },
    "[*,_1,date,dates,no date]" => {
      msgid => "[*,_1,date,dates,no date]",
      reference => {
        "files_to_extract/maketext.pl:46" => undef,
        "files_to_extract/maketext.pl:50" => undef,
        "files_to_extract/maketext.pl:54" => undef
      }
    },
    "[*,_1,date,dates]\4appointment" => {
      msgctxt => "appointment",
      msgid => "[*,_1,date,dates]",
      reference => {
        "files_to_extract/maketext.pl:36" => undef,
        "files_to_extract/maketext.pl:41" => undef
      }
    },
    "[_1] is programming [_2]." => {
      msgid => "[_1] is programming [_2].",
      reference => {
        "files_to_extract/maketext.pl:19" => undef
      }
    },
    "[quant,_1,date,dates]" => {
      msgid => "[quant,_1,date,dates]",
      reference => {
        "files_to_extract/maketext.pl:24" => undef,
        "files_to_extract/maketext.pl:28" => undef
      }
    },
    "\\' quoted text with \\." => {
      msgid => "\\' quoted text with \\.",
      reference => {
        'gettext.pl:83' => undef
      }
    },
    "date\0dates\4appointment" => {
      msgctxt => "appointment",
      msgid => "date",
      msgid_plural => "dates",
      reference => {
        "files_to_extract/gettext.pl:55" => undef,
        "files_to_extract/gettext.pl:61" => undef
      }
    },
    "date\4appointment" => {
      msgctxt => "appointment",
      msgid => "date",
      reference => {
        "files_to_extract/gettext.pl:46" => undef,
        "files_to_extract/maketext.pl:32" => undef
      }
    },
    "{name} is programming {language}." => {
      msgid => "{name} is programming {language}.",
      reference => {
        "files_to_extract/gettext.pl:19" => undef
      }
    },
    "{num} date\0{num} dates" => {
      msgid => "{num} date",
      msgid_plural => "{num} dates",
      reference => {
        "files_to_extract/gettext.pl:34" => undef,
        "files_to_extract/gettext.pl:40" => undef
      }
    },
    "{num} date\0{num} dates\4appointment" => {
      msgctxt => "appointment",
      msgid => "{num} date",
      msgid_plural => "{num} dates",
      reference => {
        "files_to_extract/gettext.pl:67" => undef,
        "files_to_extract/gettext.pl:74" => undef
      }
    },
    "{num} date\4appointment" => {
      msgctxt => "appointment",
      msgid => "{num} date",
      reference => {
        "files_to_extract/gettext.pl:50" => undef
      }
    }
  }
};
