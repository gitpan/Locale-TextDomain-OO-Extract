#!perl ## no critic (TidyCode)

use strict;
use warnings;

use Data::Dumper ();
use Locale::TextDomain::OO::Extract::JavaScript;
use Path::Tiny qw(path);

our $VERSION = 0;

my $extractor = Locale::TextDomain::OO::Extract::JavaScript->new(
    # In case of multiple extractors extract into the same array reference.
    # Parameter lexicon_ref is optional. If not set, there is a default.
    # Get back all of this by: $extractor->lexicon_ref
    lexicon_ref => \my %lexicon,
);

my @files
    = map { path($_) }
    qw(
        ./files_to_extract/javascript.js
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

# $Id: 13_extract_js.pl 286 2010-01-16 09:12:47Z steffenw $

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
    "Hello %1" => {
      msgid => "Hello %1",
      reference => {
        "files_to_extract/javascript.js:9" => undef
      }
    },
    "Hello World!\n" => {
      msgid => "Hello World!\n",
      reference => {
        "files_to_extract/javascript.js:8" => undef
      }
    },
    "MSGID 1" => {
      msgid => "MSGID 1",
      reference => {
        "files_to_extract/javascript.js:35" => undef
      }
    },
    "MSGID 10\4MSGCTXT" => {
      msgctxt => "MSGCTXT",
      msgid => "MSGID 10",
      reference => {
        "files_to_extract/javascript.js:44" => undef
      }
    },
    "MSGID 11\4MSGCTXT" => {
      msgctxt => "MSGCTXT",
      msgid => "MSGID 11",
      reference => {
        "files_to_extract/javascript.js:45" => undef
      }
    },
    "MSGID 12\0MSGID_PLURAL\4MSGCTXT" => {
      msgctxt => "MSGCTXT",
      msgid => "MSGID 12",
      msgid_plural => "MSGID_PLURAL",
      reference => {
        "files_to_extract/javascript.js:46" => undef
      }
    },
    "MSGID 13\0MSGID_PLURAL\4MSGCTXT" => {
      msgctxt => "MSGCTXT",
      msgid => "MSGID 13",
      msgid_plural => "MSGID_PLURAL",
      reference => {
        "files_to_extract/javascript.js:47" => undef
      }
    },
    "MSGID 2" => {
      msgid => "MSGID 2",
      reference => {
        "files_to_extract/javascript.js:36" => undef
      }
    },
    "MSGID 3\0MSGID_PLURAL" => {
      msgid => "MSGID 3",
      msgid_plural => "MSGID_PLURAL",
      reference => {
        "files_to_extract/javascript.js:37" => undef
      }
    },
    "MSGID 4\4MSGCTXT" => {
      msgctxt => "MSGCTXT",
      msgid => "MSGID 4",
      reference => {
        "files_to_extract/javascript.js:38" => undef
      }
    },
    "MSGID 5\0MSGID_PLURAL\4MSGCTXT" => {
      msgctxt => "MSGCTXT",
      msgid => "MSGID 5",
      msgid_plural => "MSGID_PLURAL",
      reference => {
        "files_to_extract/javascript.js:39" => undef
      }
    },
    "MSGID 6" => {
      msgid => "MSGID 6",
      reference => {
        "files_to_extract/javascript.js:40" => undef
      }
    },
    "MSGID 7" => {
      msgid => "MSGID 7",
      reference => {
        "files_to_extract/javascript.js:41" => undef
      }
    },
    "MSGID 8\0MSGID_PLURAL" => {
      msgid => "MSGID 8",
      msgid_plural => "MSGID_PLURAL",
      reference => {
        "files_to_extract/javascript.js:42" => undef
      }
    },
    "MSGID 9\0MSGID_PLURAL" => {
      msgid => "MSGID 9",
      msgid_plural => "MSGID_PLURAL",
      reference => {
        "files_to_extract/javascript.js:43" => undef
      }
    },
    "One file deleted.\n\0%d files deleted.\n" => {
      msgid => "One file deleted.\n",
      msgid_plural => "%d files deleted.\n",
      reference => {
        "files_to_extract/javascript.js:11" => undef,
        "files_to_extract/javascript.js:15" => undef
      }
    },
    "This is the %1 %2" => {
      msgid => "This is the %1 %2",
      reference => {
        "files_to_extract/javascript.js:10" => undef
      }
    },
    "View\4Noun: A View" => {
      msgctxt => "Noun: A View",
      msgid => "View",
      reference => {
        "files_to_extract/javascript.js:20" => undef
      }
    },
    "View\4Verb: To View" => {
      msgctxt => "Verb: To View",
      msgid => "View",
      reference => {
        "files_to_extract/javascript.js:19" => undef
      }
    },
    "one banana\0%1 bananas" => {
      msgid => "one banana",
      msgid_plural => "%1 bananas",
      reference => {
        "files_to_extract/javascript.js:22" => undef
      }
    },
    "some string" => {
      msgid => "some string",
      reference => {
        "files_to_extract/javascript.js:3" => undef,
        "files_to_extract/javascript.js:4" => undef,
        "files_to_extract/javascript.js:5" => undef
      }
    },
    text => {
      msgid => "text",
      reference => {
        "files_to_extract/javascript.js:7" => undef
      }
    },
    "this will get translated" => {
      msgid => "this will get translated",
      reference => {
        "files_to_extract/javascript.js:6" => undef
      }
    }
  }
};
