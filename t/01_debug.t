#!perl -T

use strict;
use warnings;

use Test::More;
BEGIN {
    $ENV{AUTHOR_TESTING}
        or plan skip_all => 'Author test. Set $ENV{AUTHOR_TESTING} to a true value to run.';
}
use Test::NoWarnings;
use Test::Differences;

BEGIN {
    plan tests => 4;
    use_ok 'Locale::TextDomain::OO::Extract::Base::RegexBasedExtractor';
}

my $text_rule
    = [
        qr{ ' }xms,
        qr{ ( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ ) }xms,
        qr{ ' }xms,
    ];

my $start_rule = qr{ __ \( }xms;

my $rules = [
    qr{ __ \( \s* }xms,
    $text_rule,
];

my @expected_debug = (
    [
        'parser',
        'Starting at pos 1.',
    ],
    [
        'parser',
        'Set the current pos to 1.',
    ],
    [
        'parser',
        "Rule (?^msx: __ \\( \\s* ) has matched:\n__( \nThe current pos is 5.",
    ],
    [
        'parser',
        'Going to child.',
    ],
    [
        'parser',
        'Set the current pos to 5.',
    ],
    [
        'parser',
        "Rule (?^msx: ' ) has matched:\n'\nThe current pos is 6.",
    ],
    [
        'parser',
        'Set the current pos to 6.',
    ],
    [
        'parser',
        "Rule (?^msx: ( (?: \\\\\\\\ \\\\\\\\ | \\\\\\\\ ' | [^'] )+ ) ) has matched:\nfoo bar\nThe current pos is 13.",
    ],
    [
        'parser',
        'Set the current pos to 13.',
    ],
    [
        'parser',
        "Rule (?^msx: ' ) has matched:\n'\nThe current pos is 14.",
    ],
    [
        'parser',
        'No more rules found.'
    ],
    [
        'parser',
        'Going back to parent.'
    ],
    [
        'parser',
        'No more rules found.'
    ],
);
my @got_debug;
my $extractor = Locale::TextDomain::OO::Extract::Base::RegexBasedExtractor->new(
    content_ref => \q{ __( 'foo bar' ) },
    start_rule => $start_rule,
    rules      => $rules,
    debug_code => sub {
        my ( $group, $message )  = @_;
        $group eq 'stack'
            and return;
        push @got_debug, [ $group, $message ]
    },
);
$extractor->extract;

eq_or_diff
    \@got_debug,
    \@expected_debug,
    'debug output';

my @stack_data = (
    {
        line_number => 1,
        match => [
            'foo bar',
        ],
        start_pos => 1,
    },
);
eq_or_diff
    $extractor->stack,
    \@stack_data,
    'stack data';
