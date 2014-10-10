#!perl -T

use strict;
use warnings;

use Test::More tests => 5;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Path::Tiny qw(path);

BEGIN {
    use_ok('Locale::TextDomain::OO::Extract::HTML');
}

my $extractor;
lives_ok
    sub {
        $extractor = Locale::TextDomain::OO::Extract::HTML->new;
    },
    'create extractor object';

lives_ok
    sub {
        $extractor->filename('text.html');
        $extractor->content_ref(
            \( path('./t/files_to_extract/text.html')->slurp_raw ),
        );
        $extractor->extract;
    },
    'extract text.html';

my $expected_lexicon_ref = {
    'i-default::' => {
        q{} => {
            msgstr => {
                nplurals => 2,
                plural => 'n != 1',
            },
        },
        'This is a p text.' => {
            msgid => 'This is a p text.',
            reference => {
                'text.html:8' => undef,
            },
        },
        'This is an a text.' => {
            msgid => 'This is an a text.',
            reference => {
                'text.html:10' => undef,
                'text.html:13' => undef,
            },
        },
    },
};
eq_or_diff
    $extractor->lexicon_ref,
    $expected_lexicon_ref,
    'data of file';
