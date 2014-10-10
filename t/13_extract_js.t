#!perl -T

use strict;
use warnings;

use Test::More tests => 7;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Path::Tiny qw(path);

BEGIN {
    use_ok('Locale::TextDomain::OO::Extract::JavaScript');
}

my $extractor;
lives_ok
    sub {
        $extractor = Locale::TextDomain::OO::Extract::JavaScript->new;
    },
    'create extractor object';

{
    my $content = "1\n//2\n3\n4/*\n5\n*/6\n";
    # remove comments
    $extractor->content_ref(\$content);
    $extractor->preprocess;
    eq_or_diff
        $content,
        "1\n\n3\n4\n\n6\n",
        'check default preprocess';
}

# http://www.c-point.com/javascript_tutorial/special_characters.htm
{
    eq_or_diff
        $extractor->_interpolate_escape_sequence(<<"EOT"),
\\' \\\\'
\\" \\\\"
\\b \\\\b
\\f \\\\f
\\n \\\\n
\\r \\\\r
\\t \\\\t
\\001 \\\\002
\\x03 \\\\x04
\\uD0D0 \\\\uD0D0
\\ \\\\
EOT
        <<"EOT",
' \\'
" \\"
\b \\b
\f \\f
\n \\n
\r \\r
\t \\t
\001 \\002
\x03 \\x04
\x{D0D0} \\uD0D0
 \\
EOT
        'check interpolate escape sequence';
}

lives_ok
    sub {
        $extractor->filename('javascript.js');
        $extractor->content_ref(
            \( path('./t/files_to_extract/javascript.js')->slurp_utf8 ),
        );
        $extractor->extract;
    },
    'extract javascript.js';

my $expected_lexicon_ref = {
    'i-default::' => {
        q{} => {
            msgstr => {
                nplurals => 2,
                plural => 'n != 1',
            },
        },
        'Hello %1' => {
            msgid => 'Hello %1',
            reference => {
                'javascript.js:9' => undef,
            },
        },
        "Hello World!\n" => {
            msgid => "Hello World!\n",
            reference => {
                'javascript.js:8' => undef,
            },
        },
        'MSGID %0 %1' => {
            automatic => '\'placeholder 0\', \'placeholder 1\'',
            msgid => 'MSGID %0 %1',
            reference => {
                'javascript.js:71' => undef,
            },
        },
        "MSGID n\x00PLURAL n" => {
            automatic => 'COUNT',
            msgid => 'MSGID n',
            msgid_plural => 'PLURAL n',
            reference => {
                'javascript.js:72' => undef,
            },
        },
        "MSGID np\x00PLURAL np\x04MSGCTXT" => {
            automatic => 'COUNT',
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID np',
            msgid_plural => 'PLURAL np',
            reference => {
                'javascript.js:74' => undef,
            },
        },
        "MSGID p\x04MSGCTXT" => {
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID p',
            reference => {
                'javascript.js:73' => undef,
            },
        },
        MSGID_ => {
            msgid => 'MSGID_',
            reference => {
                'javascript.js:35' => undef,
            },
        },
        "MSGID_n\x00PLURAL_n" => {
            automatic => 'COUNT',
            msgid => 'MSGID_n',
            msgid_plural => 'PLURAL_n',
            reference => {
                'javascript.js:37' => undef,
            },
        },
        "MSGID_np\x00PLURAL_np\x04MSGCTXT" => {
            automatic => 'COUNT',
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_np',
            msgid_plural => 'PLURAL_np',
            reference => {
                'javascript.js:41' => undef,
            },
        },
        "MSGID_npx\x00PLURAL_npx\x04MSGCTXT" => {
            automatic => 'COUNT',
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_npx',
            msgid_plural => 'PLURAL_npx',
            reference => {
                'javascript.js:42' => undef,
            },
        },
        "MSGID_nx\x00PLURAL_nx" => {
            automatic => 'COUNT',
            msgid => 'MSGID_nx',
            msgid_plural => 'PLURAL_nx',
            reference => {
                'javascript.js:38' => undef,
            },
        },
        "MSGID_p\x04MSGCTXT" => {
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_p',
            reference => {
                'javascript.js:39' => undef,
            },
        },
        "MSGID_px\x04MSGCTXT" => {
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_px',
            reference => {
                'javascript.js:40' => undef,
            },
        },
        "MSGID_x {key1} {key2}" => {
            automatic => q{{ 'key1' : 'value1', 'key2' : 'value2' }},
            msgid => 'MSGID_x {key1} {key2}',
            reference => {
                'javascript.js:36' => undef,
            },
        },
        "One file deleted.\n\x00%d files deleted.\n" => {
            automatic => 'count',
            msgid => "One file deleted.\n",
            msgid_plural => "%d files deleted.\n",
            reference => {
                'javascript.js:11' => undef,
                'javascript.js:15' => undef,
            },
        },
        'This is the %1 %2' => {
            msgid => 'This is the %1 %2',
            reference => {
                'javascript.js:10' => undef,
            },
        },
        "View\x04Noun: A View" => {
            msgctxt => 'Noun: A View',
            msgid => 'View',
            reference => {
                'javascript.js:20' => undef,
            },
        },
        "View\x04Verb: To View" => {
            msgctxt => 'Verb: To View',
            msgid => 'View',
            reference => {
                'javascript.js:19' => undef,
            },
        },
        "one banana\x00%1 bananas" => {
            automatic => 'count',
            msgid => 'one banana',
            msgid_plural => '%1 bananas',
            reference => {
                'javascript.js:22' => undef,
            },
        },
        'some string' => {
            msgid => 'some string',
            reference => {
                'javascript.js:3' => undef,
                'javascript.js:4' => undef,
                'javascript.js:5' => undef,
            },
        },
        text => {
            msgid => 'text',
            reference => {
                'javascript.js:7' => undef,
            },
        },
        'this will get translated' => {
            msgid => 'this will get translated',
            reference => {
                'javascript.js:6' => undef,
            },
        },
    },
    'i-default::TEXTDOMAIN' => {
        q{} => {
            msgstr => {
                nplurals => 2,
                plural => 'n != 1',
            },
        },
        'MSGID d' => {
            msgid => 'MSGID d',
            reference => {
                'javascript.js:76' => undef,
            },
        },
        "MSGID dn\x00PLURAL dn" => {
            automatic => 'COUNT',
            msgid => 'MSGID dn',
            msgid_plural => 'PLURAL dn',
            reference => {
                'javascript.js:77' => undef,
            },
        },
        "MSGID dp\x04MSGCTXT" => {
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID dp',
            reference => {
                'javascript.js:78' => undef,
            },
        },
        "MSGID dpn\x00PLURAL dpn\x04MSGCTXT" => {
            automatic => 'COUNT',
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID dpn',
            msgid_plural => 'PLURAL dpn',
            reference => {
                'javascript.js:79' => undef,
            },
        },
        MSGID_d => {
            msgid => 'MSGID_d',
            reference => {
                'javascript.js:44' => undef,
            },
        },
        "MSGID_dn\x00PLURAL_dn" => {
            automatic => 'COUNT',
            msgid => 'MSGID_dn',
            msgid_plural => 'PLURAL_dn',
            reference => {
                'javascript.js:46' => undef,
            },
        },
        "MSGID_dnp\x00PLURAL_dnp\x04MSGCTXT" => {
            automatic => 'COUNT',
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_dnp',
            msgid_plural => 'PLURAL_dnp',
            reference => {
                'javascript.js:50' => undef,
            },
        },
        "MSGID_dnpx\x00PLURAL_dnpx\x04MSGCTXT" => {
            automatic => 'COUNT',
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_dnpx',
            msgid_plural => 'PLURAL_dnpx',
            reference => {
                'javascript.js:51' => undef,
            },
        },
        "MSGID_dnx\x00PLURAL_dnx" => {
            automatic => 'COUNT',
            msgid => 'MSGID_dnx',
            msgid_plural => 'PLURAL_dnx',
            reference => {
                'javascript.js:47' => undef,
            },
        },
        "MSGID_dp\x04MSGCTXT" => {
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_dp',
            reference => {
                'javascript.js:48' => undef,
            },
        },
        "MSGID_dpx\x04MSGCTXT" => {
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_dpx',
            reference => {
                'javascript.js:49' => undef,
            },
        },
        MSGID_dx => {
            msgid => 'MSGID_dx',
            reference => {
                'javascript.js:45' => undef,
            },
        },
    },
    'i-default:CATEGORY:' => {
        q{} => {
            msgstr => {
                nplurals => 2,
                plural => 'n != 1',
            },
        },
        "MSGID cn\x00PLURAL cn" => {
            automatic => 'COUNT',
            msgid => 'MSGID cn',
            msgid_plural => 'PLURAL cn',
            reference => {
                'javascript.js:82' => undef,
            },
        },
        "MSGID cnp\x00PLURAL cnp\x04MSGCTXT" => {
            automatic => 'COUNT',
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID cnp',
            msgid_plural => 'PLURAL cnp',
            reference => {
                'javascript.js:84' => undef,
            },
        },
        "MSGID cp\x04MSGCTXT" => {
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID cp',
            reference => {
                'javascript.js:83' => undef,
            },
        },
        MSGID_c => {
            msgid => 'MSGID_c',
            reference => {
                'javascript.js:53' => undef,
            },
        },
        "MSGID_cn\x00PLURAL_cn" => {
            automatic => 'COUNT',
            msgid => 'MSGID_cn',
            msgid_plural => 'PLURAL_cn',
            reference => {
                'javascript.js:55' => undef,
            },
        },
        "MSGID_cnp\x00PLURAL_cnp\x04MSGCTXT" => {
            automatic => 'COUNT',
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_cnp',
            msgid_plural => 'PLURAL_cnp',
            reference => {
                'javascript.js:59' => undef,
            },
        },
        "MSGID_cnpx\x00PLURAL_cnpx\x04MSGCTXT" => {
            automatic => 'COUNT',
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_cnpx',
            msgid_plural => 'PLURAL_cnpx',
            reference => {
                'javascript.js:60' => undef,
            },
        },
        "MSGID_cnx\x00PLURAL_cnx" => {
            automatic => 'COUNT',
            msgid => 'MSGID_cnx',
            msgid_plural => 'PLURAL_cnx',
            reference => {
                'javascript.js:56' => undef,
            },
        },
        "MSGID_cp\x04MSGCTXT" => {
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_cp',
            reference => {
                'javascript.js:57' => undef,
            },
        },
        "MSGID_cpx\x04MSGCTXT" => {
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_cpx',
            reference => {
                'javascript.js:58' => undef,
            },
        },
        MSGID_cx => {
            msgid => 'MSGID_cx',
            reference => {
                'javascript.js:54' => undef,
            },
        },
    },
    'i-default:CATEGORY:TEXTDOMAIN' => {
        q{} => {
            msgstr => {
                nplurals => 2,
                plural => 'n != 1',
            },
        },
        'MSGID dc' => {
            msgid => 'MSGID dc',
            reference => {
                'javascript.js:86' => undef,
            },
        },
        "MSGID dcn\x00PLURAL dcn" => {
            automatic => 'COUNT',
            msgid => 'MSGID dcn',
            msgid_plural => 'PLURAL dcn',
            reference => {
                'javascript.js:87' => undef,
            },
        },
        "MSGID dcnp\x00PLURAL dcnp\x04MSGCTXT" => {
            automatic => 'COUNT',
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID dcnp',
            msgid_plural => 'PLURAL dcnp',
            reference => {
                'javascript.js:89' => undef,
            },
        },
        "MSGID dcp\x04MSGCTXT" => {
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID dcp',
            reference => {
                'javascript.js:88' => undef,
            },
        },
        MSGID_dc => {
            msgid => 'MSGID_dc',
            reference => {
                'javascript.js:62' => undef,
            },
        },
        "MSGID_dcn\x00PLURAL_dcn" => {
            automatic => 'COUNT',
            msgid => 'MSGID_dcn',
            msgid_plural => 'PLURAL_dcn',
            reference => {
                'javascript.js:64' => undef,
            },
        },
        "MSGID_dcnp\x00PLURAL_dcnp\x04MSGCTXT" => {
            automatic => 'COUNT',
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_dcnp',
            msgid_plural => 'PLURAL_dcnp',
            reference => {
                'javascript.js:68' => undef,
            },
        },
        "MSGID_dcnpx\x00PLURAL_dcnpx\x04MSGCTXT" => {
            automatic => 'COUNT',
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_dcnpx',
            msgid_plural => 'PLURAL_dcnpx',
            reference => {
                'javascript.js:69' => undef,
            },
        },
        "MSGID_dcnx\x00PLURAL_dcnx" => {
            automatic => 'COUNT',
            msgid => 'MSGID_dcnx',
            msgid_plural => 'PLURAL_dcnx',
            reference => {
                'javascript.js:65' => undef,
            },
        },
        "MSGID_dcp\x04MSGCTXT" => {
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_dcp',
            reference => {
                'javascript.js:66' => undef,
            },
        },
        "MSGID_dcpx\x04MSGCTXT" => {
            msgctxt => 'MSGCTXT',
            msgid => 'MSGID_dcpx',
            reference => {
                'javascript.js:67' => undef,
            },
        },
        MSGID_dcx => {
            msgid => 'MSGID_dcx',
            reference => {
                'javascript.js:63' => undef,
        },
    },
}};
eq_or_diff
    $extractor->lexicon_ref,
    $expected_lexicon_ref,
    'data of both files';
