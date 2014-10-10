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

# $Id: 13_extract_js.pl 517 2014-10-09 13:52:18Z steffenw $

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
    "One file deleted.\n\0%d files deleted.\n" => {
      automatic => "count",
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
      automatic => "count",
      msgid => "one banana",
      msgid_plural => "%1 bananas",
      reference => {
        "files_to_extract/javascript.js:22" => undef
      }
    },
    "singular {foo}\0plural {foo}" => {
      automatic => "count, {'foo' : 'bar'}",
      msgid => "singular {foo}",
      msgid_plural => "plural {foo}",
      reference => {
        "files_to_extract/javascript.js:40" => undef
      }
    },
    "singular {foo}\0plural {foo}\4context" => {
      automatic => "count, {'foo' : 'bar'}",
      msgctxt => "context",
      msgid => "singular {foo}",
      msgid_plural => "plural {foo}",
      reference => {
        "files_to_extract/javascript.js:42" => undef
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
    "text only" => {
      msgid => "text only",
      reference => {
        "files_to_extract/javascript.js:35" => undef
      }
    },
    "text {foo}" => {
      automatic => "{'foo' : 'bar'}",
      msgid => "text {foo}",
      reference => {
        "files_to_extract/javascript.js:37" => undef
      }
    },
    "this will get translated" => {
      msgid => "this will get translated",
      reference => {
        "files_to_extract/javascript.js:6" => undef
      }
    }
  },
  "i-default::domain" => {
    "" => {
      msgstr => {
        nplurals => 2,
        plural => "n != 1"
      }
    },
    "singular {foo}\0plural {foo}\4context" => {
      automatic => "count, {'foo' : 'bar'}",
      msgctxt => "context",
      msgid => "singular {foo}",
      msgid_plural => "plural {foo}",
      reference => {
        "files_to_extract/javascript.js:44" => undef
      }
    }
  },
  "i-default:context:domain" => {
    "" => {
      msgstr => {
        nplurals => 2,
        plural => "n != 1"
      }
    },
    "singular {foo}\0plural {foo}\4context" => {
      automatic => "count, {'foo' : 'bar'}",
      msgctxt => "context",
      msgid => "singular {foo}",
      msgid_plural => "plural {foo}",
      reference => {
        "files_to_extract/javascript.js:46" => undef
      }
    }
  }
};
