#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Cwd qw(getcwd chdir);

$ENV{AUTHOR_TESTING}
    or plan skip_all => 'Set $ENV{AUTHOR_TESTING} to run this test.';

plan tests => 4;

my @data = (
    {
        test   => '11_extract_perl',
        path   => 'example',
        script => '-I../lib 11_extract_perl.pl',
        result => <<'EOT',
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
EOT
    },
    {
        test   => '12_extract_tt',
        path   => 'example',
        script => '-I../lib 12_extract_tt.pl',
        result => <<'EOT',
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
EOT
    },
    {
        test   => '13_extract_js',
        path   => 'example',
        script => '-I../lib 13_extract_js.pl',
        result => <<'EOT',
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
EOT
    },
    {
        test   => '14_extract_html',
        path   => 'example',
        script => '-I../lib 14_extract_html.pl',
        result => <<'EOT',
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
EOT
    },
);

for my $data (@data) {
    my $dir = getcwd();
    chdir("$dir/$data->{path}");
    my $result = qx{perl $data->{script} 2>&3};
    chdir($dir);
    eq_or_diff
        $result,
        $data->{result},
        $data->{test};
}
