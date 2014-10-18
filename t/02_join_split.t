#!perl -T

use strict;
use warnings;

use Test::More tests => 10;
use Test::NoWarnings;
use Test::Differences;

BEGIN {
    use_ok 'Locale::TextDomain::OO::Util::JoinSplitLexiconKeys';
}

my $key_util = Locale::TextDomain::OO::Util::JoinSplitLexiconKeys->instance;

is
    $key_util->join_lexicon_key({}),
    'i-default::',
    'join empty lexicon key';
eq_or_diff
    $key_util->split_lexicon_key,
    {},
    'split undef lexicon key';
is
    $key_util->join_lexicon_key({
        language => 'de-de',
        category => 'my category',
        domain   => 'my domain',
    }),
    'de-de:my category:my domain',
    'join lexicon key';
eq_or_diff
    $key_util->split_lexicon_key('de-de:my category:my domain'),
    {
        language => 'de-de',
        category => 'my category',
        domain   => 'my domain',
    },
    'split lexicon key';

is
    $key_util->join_message_key({}),
    q{},
    'join empty message key';
eq_or_diff
    $key_util->split_message_key,
    {},
    'split undef message key';
eq_or_diff
    $key_util->join_message_key({
        msgctxt      => 'my context',
        msgid        => 'my singular',
        msgid_plural => 'my plural',
    }),
    "my singular\x00my plural\x04my context",
    'join message key';
eq_or_diff
    $key_util->split_message_key("my singular\x00my plural\x04my context"),
    {
        msgctxt      => 'my context',
        msgid        => 'my singular',
        msgid_plural => 'my plural',
    },
    'split message key';
