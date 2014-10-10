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

# $Id: 11_extract_perl.pl 517 2014-10-09 13:52:18Z steffenw $

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
    "Singular\0Plural" => {
      automatic => 1,
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
      automatic => "0,",
      msgid => "[*,_1,date,dates,no date]",
      reference => {
        "files_to_extract/maketext.pl:46" => undef,
        "files_to_extract/maketext.pl:50" => undef,
        "files_to_extract/maketext.pl:54" => undef
      }
    },
    "[*,_1,date,dates]\4appointment" => {
      automatic => "1,",
      msgctxt => "appointment",
      msgid => "[*,_1,date,dates]",
      reference => {
        "files_to_extract/maketext.pl:36" => undef,
        "files_to_extract/maketext.pl:41" => undef
      }
    },
    "[_1] is programming [_2]." => {
      automatic => "'Steffen', 'Perl',",
      msgid => "[_1] is programming [_2].",
      reference => {
        "files_to_extract/maketext.pl:19" => undef
      }
    },
    "[quant,_1,date,dates]" => {
      automatic => "1,",
      msgid => "[quant,_1,date,dates]",
      reference => {
        "files_to_extract/maketext.pl:24" => undef,
        "files_to_extract/maketext.pl:28" => undef
      }
    },
    "\\' quoted text with \\\\." => {
      msgid => "\\' quoted text with \\\\.",
      reference => {
        "files_to_extract/gettext.pl:83" => undef
      }
    },
    "date\0dates\4appointment" => {
      automatic => 1,
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
    "q\\{ quoted text with {placeholders\\}}." => {
      msgid => "q\\{ quoted text with {placeholders\\}}.",
      reference => {
        "files_to_extract/gettext.pl:86" => undef
      }
    },
    "quoted text." => {
      msgid => "quoted text.",
      reference => {
        "files_to_extract/gettext.pl:89" => undef
      }
    },
    "text of no domain and no category" => {
      msgid => "text of no domain and no category",
      reference => {
        "files_to_extract/gettext.pl:107" => undef,
        "files_to_extract/gettext.pl:111" => undef,
        "files_to_extract/gettext.pl:99" => undef
      }
    },
    "{name} is programming {language}." => {
      automatic => "name => 'Steffen', language => 'Perl',",
      msgid => "{name} is programming {language}.",
      reference => {
        "files_to_extract/gettext.pl:19" => undef
      }
    },
    "{num} date\0{num} dates" => {
      automatic => "1, num => 1,",
      msgid => "{num} date",
      msgid_plural => "{num} dates",
      reference => {
        "files_to_extract/gettext.pl:34" => undef,
        "files_to_extract/gettext.pl:40" => undef
      }
    },
    "{num} date\0{num} dates\4appointment" => {
      automatic => "1, num => 1,",
      msgctxt => "appointment",
      msgid => "{num} date",
      msgid_plural => "{num} dates",
      reference => {
        "files_to_extract/gettext.pl:67" => undef,
        "files_to_extract/gettext.pl:74" => undef
      }
    },
    "{num} date\4appointment" => {
      automatic => "num => 1,",
      msgctxt => "appointment",
      msgid => "{num} date",
      reference => {
        "files_to_extract/gettext.pl:50" => undef
      }
    }
  },
  "i-default::domain d" => {
    "" => {
      msgstr => {
        nplurals => 2,
        plural => "n != 1"
      }
    },
    "text of domain d and no category" => {
      msgid => "text of domain d and no category",
      reference => {
        "files_to_extract/gettext.pl:101" => undef,
        "files_to_extract/gettext.pl:94" => undef
      }
    }
  },
  "i-default:category c:" => {
    "" => {
      msgstr => {
        nplurals => 2,
        plural => "n != 1"
      }
    },
    "text of no domain and category c" => {
      msgid => "text of no domain and category c",
      reference => {
        "files_to_extract/gettext.pl:105" => undef,
        "files_to_extract/gettext.pl:95" => undef
      }
    }
  },
  "i-default:category c:domain d" => {
    "" => {
      msgstr => {
        nplurals => 2,
        plural => "n != 1"
      }
    },
    "text of domain d and category c" => {
      msgid => "text of domain d and category c",
      reference => {
        "files_to_extract/gettext.pl:103" => undef,
        "files_to_extract/gettext.pl:109" => undef,
        "files_to_extract/gettext.pl:96" => undef
      }
    }
  }
};
