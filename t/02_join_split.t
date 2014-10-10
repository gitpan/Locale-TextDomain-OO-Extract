#!perl -T

use strict;
use warnings;

use Moo;
use Test::More tests => 9;
use Test::NoWarnings;
use Test::Differences;

with qw(
    Locale::TextDomain::OO::Extract::Role::JoinSplitLexiconKeys
);

my $object = __PACKAGE__->new;

is
    $object->join_lexicon_key({}),
    'i-default::',
    'join empty lexicon key';
eq_or_diff
    $object->split_lexicon_key,
    {},
    'split undef lexicon key';
is
    $object->join_lexicon_key({
        language => 'de-de',
        category => 'my category',
        domain   => 'my domain',
    }),
    'de-de:my category:my domain',
    'join lexicon key';
eq_or_diff
    $object->split_lexicon_key('de-de:my category:my domain'),
    {
        language => 'de-de',
        category => 'my category',
        domain   => 'my domain',
    },
    'split lexicon key';

is
    $object->join_message_key({}),
    q{},
    'join empty message key';
eq_or_diff
    $object->split_message_key,
    {},
    'split undef message key';
eq_or_diff
    $object->join_message_key({
        msgctxt      => 'my context',
        msgid        => 'my singular',
        msgid_plural => 'my plural',
    }),
    "my singular\x00my plural\x04my context",
    'join message key';
eq_or_diff
    $object->split_message_key("my singular\x00my plural\x04my context"),
    {
        msgctxt      => 'my context',
        msgid        => 'my singular',
        msgid_plural => 'my plural',
    },
    'split message key';
