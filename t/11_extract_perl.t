#!perl -T

use strict;
use warnings;

use Test::More tests => 7;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Path::Tiny qw(path);

BEGIN {
    use_ok('Locale::TextDomain::OO::Extract::Perl');
}

my $extractor;
lives_ok
    sub {
        $extractor = Locale::TextDomain::OO::Extract::Perl->new;
    },
    'create extractor object';

{
    my $content = "1\n=pod\n3\n=cut\n5\n__END__\n7\n";
    $extractor->content_ref(\$content);
    # remove POD and all after __END__
    $extractor->preprocess;
    eq_or_diff
       $content,
        "1\n\n\n\n5\n",
        'check default preprocess';
}

lives_ok
    sub {
        $extractor->filename('gettext.pl');
        $extractor->content_ref(
            \( path('./t/files_to_extract/gettext.pl')->slurp_raw ),
        );
        $extractor->extract;
    },
    'extract gettext.pl';

lives_ok
    sub {
        $extractor->clear;
        $extractor->filename('maketext.pl');
        $extractor->content_ref(
            \( path('./t/files_to_extract/maketext.pl')->slurp_raw ),
        );
        $extractor->extract;
    },
    'extract maketext.pl';

my $expected_lexicon_ref = {
    'i-default::' => {
        q{} => {
            msgstr => {
                nplurals => 2,
                plural => 'n != 1',
            },
        },
        "Singular\x00Plural" => {
            automatic => '1',
            msgid => 'Singular',
            msgid_plural => 'Plural',
            reference => {
                'gettext.pl:24' => undef,
                'gettext.pl:29' => undef,
            },
        },
        'This is a text.' => {
            msgid => 'This is a text.',
            reference => {
                'gettext.pl:16' => undef,
                'maketext.pl:16' => undef,
            },
        },
        '[*,_1,date,dates,no date]' => {
            automatic => '0,',
            msgid => '[*,_1,date,dates,no date]',
            reference => {
                'maketext.pl:46' => undef,
                'maketext.pl:50' => undef,
                'maketext.pl:54' => undef,
            },
        },
        "[*,_1,date,dates]\x04appointment" => {
            automatic => '1,',
            msgctxt => 'appointment',
            msgid => '[*,_1,date,dates]',
            reference => {
                'maketext.pl:36' => undef,
                'maketext.pl:41' => undef,
            },
        },
        '[_1] is programming [_2].' => {
            automatic => q{'Steffen', 'Perl',},
            msgid => '[_1] is programming [_2].',
            reference => {
                'maketext.pl:19' => undef,
            },
        },
        '[quant,_1,date,dates]' => {
            automatic => '1,',
            msgid => '[quant,_1,date,dates]',
            reference => {
                'maketext.pl:24' => undef,
                'maketext.pl:28' => undef,
            },
        },
        "\\' quoted text with \\\\." => {
            msgid => "\\' quoted text with \\\\.",
            reference => {
                'gettext.pl:83' => undef,
            },
        },
        "date\x00dates\x04appointment" => {
            automatic => '1',
            msgctxt => 'appointment',
            msgid => 'date',
            msgid_plural => 'dates',
            reference => {
                'gettext.pl:55' => undef,
                'gettext.pl:61' => undef,
            },
        },
        "date\x04appointment" => {
            msgctxt => 'appointment',
            msgid => 'date',
            reference => {
                'gettext.pl:46' => undef,
                'maketext.pl:32' => undef,
            },
        },
        'q\\{ quoted text with {placeholders\\}}.' => {
          msgid => 'q\\{ quoted text with {placeholders\\}}.',
          reference => {
            'gettext.pl:86' => undef
          }
        },
        'quoted text.' => {
          msgid => 'quoted text.',
          reference => {
            'gettext.pl:89' => undef
          }
        },
        'text of no domain and no category' => {
            msgid => 'text of no domain and no category',
            reference => {
                'gettext.pl:108' => undef,
                'gettext.pl:116' => undef,
                'gettext.pl:120' => undef,
            },
        },
        '{name} is programming {language}.' => {
            automatic => q{name => 'Steffen', language => 'Perl',},
            msgid => '{name} is programming {language}.',
            reference => {
                'gettext.pl:19' => undef,
            },
        },
        "{num} date\x00{num} dates" => {
            automatic => '1, num => 1,',
            msgid => '{num} date',
            msgid_plural => '{num} dates',
            reference => {
                'gettext.pl:34' => undef,
                'gettext.pl:40' => undef,
            },
        },
        "{num} date\x00{num} dates\x04appointment" => {
            automatic => '1, num => 1,',
            msgctxt => 'appointment',
            msgid => '{num} date',
            msgid_plural => '{num} dates',
            reference => {
                'gettext.pl:67' => undef,
                'gettext.pl:74' => undef,
            },
        },
        "{num} date\x04appointment" => {
            automatic => 'num => 1,',
            msgctxt => 'appointment',
            msgid => '{num} date',
            reference => {
                'gettext.pl:50' => undef,
            },
        },
    },
    'i-default::domain d' => {
        q{} => {
            msgstr => {
                nplurals => 2,
                plural => 'n != 1',
            },
        },
        "singular dn\x00plural dn" => {
            automatic => '0',
            msgid => 'singular dn',
            msgid_plural => 'plural dn',
            reference => {
                'gettext.pl:96' => undef,
            },
        },
        "singular dnp\x00plural dnp\x04context dnp" => {
            automatic => '0',
            msgctxt => 'context dnp',
            msgid => 'singular dnp',
            msgid_plural => 'plural dnp',
            reference => {
                'gettext.pl:97' => undef,
            },
        },
        'text d' => {
            msgid => 'text d',
            reference => {
                'gettext.pl:94' => undef,
            },
        },
        "text dp\x04context dp" => {
            msgctxt => 'context dp',
            msgid => 'text dp',
            reference => {
                'gettext.pl:95' => undef,
            },
        },
        'text of domain d and no category' => {
            msgid => 'text of domain d and no category',
            reference => {
                'gettext.pl:110' => undef,
            },
        },
    },
    'i-default:category c:' => {
        q{} => {
            msgstr => {
                nplurals => 2,
                plural => 'n != 1',
            },
        },
        "singular cn\x00plural cn" => {
            automatic => '0',
            msgid => 'singular cn',
            msgid_plural => 'plural cn',
            reference => {
                'gettext.pl:99' => undef,
            },
        },
        "singular cnp\x00plural cnp\x04context cnp" => {
            automatic => '0',
            msgctxt => 'context cnp',
            msgid => 'singular cnp',
            msgid_plural => 'plural cnp',
            reference => {
                'gettext.pl:101' => undef,
            },
        },
        'text c' => {
            msgid => 'text c',
            reference => {
                'gettext.pl:98' => undef,
            },
        },
        "text cp\x04context cp" => {
            msgctxt => 'context cp',
            msgid => 'text cp',
            reference => {
                'gettext.pl:100' => undef,
            },
        },
        'text of no domain and category c' => {
            msgid => 'text of no domain and category c',
            reference => {
                'gettext.pl:114' => undef,
            },
        },
    },
    'i-default:category c:domain d' => {
        q{} => {
            msgstr => {
                nplurals => 2,
                plural => 'n != 1',
            },
        },
        "singular dcn\x00plural dcn" => {
            automatic => '0',
            msgid => 'singular dcn',
            msgid_plural => 'plural dcn',
            reference => {
                'gettext.pl:103' => undef,
            },
        },
        "singular dcnp\x00plural dcnp\x04context dcnp" => {
            automatic => '0',
            msgctxt => 'context dcnp',
            msgid => 'singular dcnp',
            msgid_plural => 'plural dcnp',
            reference => {
                'gettext.pl:105' => undef,
            },
        },
        'text dc' => {
            msgid => 'text dc',
            reference => {
                'gettext.pl:102' => undef,
            },
        },
        "text dcp\x04context dcp" => {
            msgctxt => 'context dcp',
            msgid => 'text dcp',
            reference => {
                'gettext.pl:104' => undef,
            },
        },
        'text of domain d and category c' => {
            msgid => 'text of domain d and category c',
            reference => {
                'gettext.pl:112' => undef,
                'gettext.pl:118' => undef,
            },
        },
    },
};
eq_or_diff
    $extractor->lexicon_ref,
    $expected_lexicon_ref,
    'data of both files';
