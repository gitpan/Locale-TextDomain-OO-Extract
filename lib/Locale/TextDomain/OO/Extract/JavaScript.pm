package Locale::TextDomain::OO::Extract::JavaScript; ## no critic (TidyCode)

use strict;
use warnings;
use Moo;
use MooX::Types::MooseLike::Base qw(ArrayRef Str);
use namespace::autoclean;

our $VERSION = '2.000';

extends qw(
    Locale::TextDomain::OO::Extract::Base::RegexBasedExtractor
);
with qw(
    Locale::TextDomain::OO::Extract::Role::File
);

my $category_rule
    = my $context_rule
    = my $domain_rule
    = my $plural_rule
    = my $singular_rule
    = my $text_rule
    = [
        [
            qr{
                ["]
                (
                    [^\\"]*              # normal text
                    (?: \\ . [^\\"]* )*  # maybe followed by escaped char and normal text
                )
                ["]
            }xms,
        ],
        'or',
        [
            qr{
                [']
                (
                    [^\\']*              # normal text
                    (?: \\ . [^\\']* )*  # maybe followed by escaped char and normal text
                )
                [']
            }xms,
        ],
    ];
my $comma_rule = qr{ \s* , \s* }xms;
my $count_rule = qr{ \s* ( [^,)]+ ) \s* }xms;
my $close_rule = qr{ \s* [,]? \s* ( [^)]* ) [)] }xms;

my $start_rule = qr{ \b N? (?: _ d? c? n? p? x? | d? c? n? p? gettext ) \s* [(] }xms;

my $rules = [
    # _
    [
        qr{ \b N? _ ( x? ) \s* [(] \s* }xms,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? _ ( n x? ) \s* [(] \s* }xms,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? _ ( p x? ) \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? _ ( np x? ) \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $close_rule,
    ],

    # _d
    'or',
    [
        qr{ \b N? _ ( d x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? _ ( dn x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? _ ( dp x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $context_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? _ ( dnp x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $context_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $close_rule,
    ],

    # _c
    'or',
    [
        qr{ \b N? _ ( c x? ) \s* [(] \s* }xms,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? _ ( cn x? ) \s* [(] \s* }xms,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? _ ( cp x? ) \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? _ ( cnp x? ) \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],

    # _dc
    'or',
    [
        qr{ \b N? _ ( dc x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? _ ( dcn x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? _ ( dcp x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $context_rule,
        $comma_rule,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? _ ( dcnp x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $context_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],

    # gettext
    'or',
    [
        qr{ \b N? () gettext \s* [(] \s* }xms,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? ( n ) gettext \s* [(] \s* }xms,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? ( p ) gettext \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? ( np ) gettext \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $close_rule,
    ],

    # dgettext
    'or',
    [
        qr{ \b N? ( d ) gettext \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? ( dn ) gettext \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? ( dp ) gettext \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $context_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? ( dnp ) gettext \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $context_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $close_rule,
    ],

    # cgettext
    'or',
    [
        qr{ \b N? ( c ) gettext [(] \s* }xms,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? ( cn ) gettext \s* [(] \s* }xms,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? ( cp ) gettext \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? ( cnp ) gettext \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],

    # dcgettext
    'or',
    [
        qr{ \b N? ( dc ) gettext \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? ( dcn ) gettext \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? ( dcp ) gettext \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $context_rule,
        $comma_rule,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? ( dcnp ) gettext \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $context_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
];

# remove comment code
sub preprocess {
    my $self = shift;

    my $content_ref = $self->content_ref;

    ${$content_ref} =~ s{ // [^\n]* $ }{}xmsg;
    ${$content_ref} =~ s{
        / [*] ( .*? ) [*] /
    }{
        join q{}, $1 =~ m{ ( \n ) }xmsg;
    }xmsge;

    return $self;
}

my %char_of = (
    b => "\b",
    f => "\f",
    n => "\n",
    r => "\r",
    t => "\t",
);

sub _interpolate_escape_sequence {
    my ($self, $string) = @_;

    # nothing to interpolate
    defined $string
        or return;

    ## no critic (ComplexRegexes)
    $string =~ s{
        \\
        (?:
            ( [bfnrt] ) # Backspace
                        # Form feed
                        # New line
                        # Carriage return
                        # Horizontal tab
            | u ( [\dA-Fa-f]{4} ) # Unicode sequence (4 hex digits: dddd)
            | x ( [\dA-Fa-f]{2} ) # Hexadecimal sequence (2 digits: dd)
            |   ( [0-3][0-7]{2} ) # Octal sequence (3 digits: ddd)
            | (.) # Backslash itself
                  # Single quotation mark
                  # Double quotation mark
                  # anything else that needs no escape
        )
    }{
       $1   ? $char_of{$1}
       : $2 ? chr hex $2
       : $3 ? chr hex $3
       : $4 ? chr oct $4
       :      $5
    }xmsge;
    ## use critic (ComplexRegexes)

    return $string;
}

sub stack_item_mapping {
    my $self = shift;

    my $match = $_->{match};
    my $extra_parameter = shift @{$match};
    @{$match}
        or return;

    my $count;
    $self->add_message({
        reference    => ( sprintf '%s:%s', $self->filename, $_->{line_number} ),
        domain       => $extra_parameter =~ m{ d }xms
            ? scalar $self->_interpolate_escape_sequence( shift @{$match} )
            : $self->domain,
        msgctxt      => $extra_parameter =~ m{ p }xms
            ? scalar $self->_interpolate_escape_sequence( shift @{$match} )
            : undef,
        msgid        => scalar $self->_interpolate_escape_sequence(
            shift @{$match},
        ),
        msgid_plural => $extra_parameter =~ m{ n }xms
            ? do {
                my $plural = $self->_interpolate_escape_sequence(
                    shift @{$match},
                );
                $count = $self->_interpolate_escape_sequence( shift @{$match} );
                $plural;
            }
            : undef,
        category     => $extra_parameter =~ m{ c }xms
            ? scalar $self->_interpolate_escape_sequence( shift @{$match} )
            : $self->category,
        automatic    => do {
            my $placeholders = $self->_interpolate_escape_sequence(
                shift @{$match},
            );
            my $string = join ', ', map { ## no critic (MutatingListFunctions)
                defined $_
                ? do {
                    s{ \s+ }{ }xmsg;
                    s{ \s+ \z }{}xms;
                    length $_ ? $_ : ();
                }
                : ();
            } ( $count, $placeholders );
            $string =~ s{ \A ( .{70} ) .+ \z }{$1 ...}xms;
            $string;
        },
    });

    return;
}

sub extract {
    my $self = shift;

    $self->start_rule($start_rule);
    $self->rules($rules);
    $self->preprocess;
    $self->SUPER::extract;
    for ( @{ $self->stack } ) {
        $self->stack_item_mapping;
    }

    return;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Extract::JavaScript
- Extracts internationalization data from JavaScript code

$Id: $

$HeadURL: $

=head1 VERSION

2.000

=head1 DESCRIPTION

This module extracts internationalization data from JavaScript code.

Implemented Rules:

 _('...
 _x('...
 _n('...
 _nx('...
 _p('...
 _px('...
 _np('...
 _npx('...

 _d('...
 _dx('...
 _dn('...
 _dnx('...
 _dp('...
 _dpx('...
 _dnp('...
 _dnpx('...

 _c('...
 _cx('...
 _cn('...
 _cnx('...
 _cp('...
 _cpx('...
 _cnp('...
 _cnpx('...

 _dc('...
 _dcx('...
 _dcn('...
 _dcnx('...
 _dcp('...
 _dcpx('...
 _dcnp('...
 _dcnpx('...

 gettext('...
 ngettext('...
 pgettext('...
 npgettext('...

 dgettext('...
 dngettext('...
 dpgettext('...
 dnpgettext('...

 cgettext('...
 cngettext('...
 cpgettext('...
 cnpgettext('...

 dcgettext('...
 dcngettext('...
 dcpgettext('...
 dcnpgettext('...

Whitespace is allowed everywhere.
Quote and escape any text like: C<' text {placeholder} \\ \' ' or " text {placeholder} \\ \" }>
Also possible all functions with N in front like N_, Ngettext, ... to prepare only.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::Extract::JavaScript;
    use Path::Tiny qw(path);

    my $extractor = Locale::TextDomain::OO::Extract::JavaScript->new;
    for ( @files ) {
        $extractor->clear;
        $extractor->filename($_);
        $extractor->content_ref( \( path($_)->slurp_utf8 ) );
        $exttactor->category('LC_Messages'); # set defaults or q{} is used
        $extractor->domain('default');       # set defaults or q{} is used
        $extractor->extract;
    }
    ... = $extractor->lexicon_ref;

=head1 SUBROUTINES/METHODS

=head2 method new

All parameters are optional.
See Locale::TextDomain::OO::Extract to replace the defaults.

=head2 method preprocess

This method removes all comments.

=head2 method stack_item_mapping

This method maps the matched stuff as lexicon item.

=head2 method extract

This method runs the extraction.

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Moo|Moo>

L<MooX::Types::MooseLike::Base|MooX::Types::MooseLike::Base>

L<namespace::autoclean|namespace::autoclean>

L<Locale::TextDomain::OO::Extract::Base::RegexBasedExtractor|Locale::TextDomain::OO::Extract::Base::RegexBasedExtractor>

L<Locale::TextDomain::OO::Extract::Role::File|Locale::TextDomain::OO::Extract::Role::File>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO|Locale::TextDoamin::OO>

L<http://jsgettext.berlios.de/>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 - 2014,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
