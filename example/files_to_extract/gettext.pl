#!perl -T ## no critic (TidyCode)

use strict;
use warnings;

use Locale::TextDomain::OO;

our $VERSION = 0;

my $loc = Locale::TextDomain::OO->new(
    plugins => [ qw( Expand::Gettext ) ],
);

# run all translations
() = print map {"$_\n"}
    $loc->__(
        'This is a text.',
    ),
    $loc->__x(
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ),
    $loc->__n(
        'Singular',
        'Plural',
        1,
    ),
    $loc->__n(
        'Singular',
        'Plural',
        2,
    ),
    $loc->__nx(
        '{num} date',
        '{num} dates',
        1,
        num => 1,
    ),
    $loc->__nx(
        '{num} date',
        '{num} dates',
        2,
        num => 2,
    ),
    $loc->__p(
        'appointment',
        'date',
    ),
    $loc->__px(
        'appointment',
        '{num} date',
        num => 1,
    ),
    $loc->__np(
        'appointment',
        'date',
        'dates',
        1,
    ),
    $loc->__np(
        'appointment',
        'date',
        'dates',
        2,
    ),
    $loc->__npx(
        'appointment',
        '{num} date',
        '{num} dates',
        1,
        num => 1,
    ),
    $loc->__npx(
        'appointment',
        '{num} date',
        '{num} dates',
        2,
        num => 2,
    );

# Extract special stuff only
$loc->N__(
    '\' quoted text with \\.',
);
$loc->N__(
    q{q\{ quoted text with {placeholders\}}.},
);
$loc->N__(
    q{quoted text.},
);

# with domain and/or category
$loc->__d('domain d', 'text of domain d and no category');
$loc->__c('text of no domain and category c', 'category c');
$loc->__dc('domain d', 'text of domain d and category c', 'category c');

# preselect/unselect domain and/or category
$loc->__('text of no domain and no category');
$loc->__begin_d('domain d');
$loc->__('text of domain d and no category');
$loc->__begin_c('category c');
$loc->__('text of domain d and category c');
$loc->__end_d;
$loc->__('text of no domain and category c');
$loc->__end_c;
$loc->__('text of no domain and no category');
$loc->__begin_dc('domain d', 'category c');
$loc->__('text of domain d and category c');
$loc->__end_dc;
$loc->__('text of no domain and no category');

# $Id: $

__END__

Output:

This is a text.
Steffen is programming Perl.
Singular
Plural
1 date
2 dates
date
1 date
date
dates
1 date
2 dates
