package Locale::TextDomain::OO::Util::JoinSplitLexiconKeys; ## no critic (TidyCode)

use strict;
use warnings;
use Locale::TextDomain::OO::Util::Constants;
use Moo;
use MooX::StrictConstructor;
use namespace::autoclean;

our $VERSION = '2.001';

with qw(
    MooX::Singleton
);

sub join_lexicon_key {
    my ( $self, $arg_ref ) = @_;

    my $const = Locale::TextDomain::OO::Util::Constants->instance;

    return join $const->lexicon_key_separator,
        (
            ( defined $arg_ref->{language} && length $arg_ref->{language} )
            ? $arg_ref->{language}
            : 'i-default'
        ),
        ( defined $arg_ref->{category} ? $arg_ref->{category} : q{} ),
        ( defined $arg_ref->{domain}   ? $arg_ref->{domain}   : q{} );
}

sub split_lexicon_key {
    my ( $self, $lexicon_key ) = @_;

    defined $lexicon_key
        or return {};
    my $const = Locale::TextDomain::OO::Util::Constants->instance;
    my ( $language, $category, $domain )
        = split $const->lexicon_key_separator, $lexicon_key;

    return {
        language => $language,
        category => $category,
        domain   => $domain,
    };
}

my $length_or_empty_list = sub {
    my $item = shift;

    defined $item or return;
    length $item or return;

    return $item;
};

sub join_message_key {
    my ( $self, $arg_ref ) = @_;

    my $const = Locale::TextDomain::OO::Util::Constants->instance;

    return join $const->msg_key_separator,
        (
            join $const->plural_separator,
                $length_or_empty_list->( $arg_ref->{msgid} ),
                $length_or_empty_list->( $arg_ref->{msgid_plural} ),
        ),
        $length_or_empty_list->( $arg_ref->{msgctxt} );
}

sub split_message_key {
    my ( $self, $message_key ) = @_;

    defined $message_key
        or return {};
    my $const = Locale::TextDomain::OO::Util::Constants->instance;
    my ( $text, $context )
        = split $const->msg_key_separator, $message_key;
    defined $text
        or $text = q{};
    my ( $singular, $plural )
        = split $const->plural_separator, $text;

    return {
        msgctxt      => $context,
        msgid        => $singular,
        msgid_plural => $plural,
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME
Locale::TextDomain::OO::Util::JoinSplitLexiconKeys
- Handle lexicon and message key

$Id: $

$HeadURL: $

=head1 VERSION

0.001

=head1 DESCRIPTION

Module to handle the lexicon and message key.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::Uitl::JoinSplitLexiconKeys;

    my $keys_util = Locale::TextDomain::OO::Uitl::JoinSplitLexiconKeys->instance;

=head1 SUBROUTINES/METHODS

=head2 method join_lexicon_key

    $lexicon_key = $keys_util->join_lexicon_key({
        category => 'LC_MESSAGES', # default q{}
        domain   => 'TextDomain',  # defuaut q{}
        language => 'de-de',       # default 'i-default'
    });

=head2 method split_lexicon_key

This method is the reverse implementation of method join_lexicon_key.

    $hash_ref = $keys_util->split_lexicon_key($lexicon_key);

=head2 method join_message_key

    $message_key = $keys_util->join_message_key({
        msgctxt      => 'my context',
        msgid        => 'simple text or singular',
        msgid_plural => 'plural',
    });

=head2 method split_message_key

This method is the reverse implementation of method join_message_key.

    $hash_ref = $keys_util->split_message_key($message_key);

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Locale::TextDomain::OO::Util::Constants|Locale::TextDomain::OO::Util::Constants>

L<Moo|Moo>

L<MooX::StrictConstructor|MooX::StrictConstructor>

L<namespace::autoclean|namespace::autoclean>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO|Locale::TextDoamin::OO>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2014,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
