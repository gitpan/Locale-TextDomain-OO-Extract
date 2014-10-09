#!perl
#!perl -T

use strict;
use warnings;
use utf8;

use Test::More tests => 5;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Path::Tiny qw(path);

BEGIN {
    use_ok('Locale::TextDomain::OO::Extract::TT');
}

my $extractor;
lives_ok
    sub {
        $extractor = Locale::TextDomain::OO::Extract::TT->new;
    },
    'create extractor object';

lives_ok
    sub {
        $extractor->filename('template.tt');
        $extractor->content_ref(
            \( path('./t/files_to_extract/template.tt')->slurp_utf8 ),
        );
        $extractor->extract;
    },
    'extract template.tt';

my $expected_lexicon_ref = {
    'i-default::' => {
        q{} => {
            msgstr => {
                nplurals => 2,
                plural => 'n != 1',
            },
        },
        'Text Ä' => {
            msgid => 'Text Ä',
            reference => {
                'template.tt:9' => undef,
            },
        },
        'Text Ö' => {
            msgid => 'Text Ö',
            reference => {
                'template.tt:13' => undef,
            },
        },
        'Text Ü' => {
            msgid => 'Text Ü',
            reference => {
                'template.tt:16' => undef,
            },
        },
    },
};
eq_or_diff
    $extractor->lexicon_ref,
    $expected_lexicon_ref,
    'data of file';
