package Locale::TextDomain::OO::Extract::TT; ## no critic (TidyCode)

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
    = my $domain_or_category_rule
    = my $plural_rule
    = my $singular_rule
    = my $text_rule
    = [
        [
            # 'text with 0 .. n escaped chars'
            qr{
                [']
                (
                    [^\\']*              # normal text
                    (?: \\ . [^\\']* )*  # maybe followed by escaped char and normal text
                )
                [']
            }xms,
        ],
        'or',
        [
            # q{text with 0 .. n {placeholders} and/or 0 .. n escaped chars}
            ## no critic (EscapedMetacharacters)
            qr{
                [q] \{                # q curly bracked quoted
                (
                    (?:
                        [^\{\}\\]     # normal text
                        | \\ .        # escaped char
                        | \{ (?-1) \} # any paars of curly brackets with the same stuff inside
                    )*
                )
                \}                    # end of quote
            }xms,
            ## use critic (EscapedMetacharacters)
        ],
    ];
my $comma_rule = qr{ \s* , \s* }xms;
my $count_rule = qr{ \s* ( [^,)]+ ) \s* }xms;
my $close_rule = qr{ \s* [,]? \s* ( [^)]* ) [)] }xms;

my $start_rule = qr{
    \b
    (?:
        N? __ d? c? n? p? x?
        | l
    )
    \s*
    [(]
}xms;

my $rules = [
    # __
    [
        qr{ \b N? __ ( x? ) \s* [(] \s* }xms,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? __ ( n x? ) \s* [(] \s* }xms,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? __ ( p x? ) \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? __ ( np x? ) \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $close_rule,
    ],

    # __d
    'or',
    [
        qr{ \b N? __ ( d x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? __ ( dn x? ) \s* [(] \s* }xms,
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
        qr{ \b N? __ ( dp x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $context_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? __ ( dnp x? ) \s* [(] \s* }xms,
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

    # __c
    'or',
    [
        qr{ \b N? __ ( c x? ) \s* [(] \s* }xms,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? __ ( cn x? ) \s* [(] \s* }xms,
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
        qr{ \b N? __ ( cp x? ) \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? __ ( cnp x? ) \s* [(] \s* }xms,
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

    # __dc
    'or',
    [
        qr{ \b N? __ ( dc x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? __ ( dcn x? ) \s* [(] \s* }xms,
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
        qr{ \b N? __ ( dcp x? ) \s* [(] \s* }xms,
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
        qr{ \b N? __ ( dcnp x? ) \s* [(] \s* }xms,
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

    # l
    'or',
    qr{ \b l () \s* [(] \s* }xms,
    $text_rule,
    $close_rule,
];

sub stack_item_mapping {
    my $self = shift;

    my $match = $_->{match};
    # The chars after __ were stored to make a decision now.
    my $extra_parameter = shift @{$match};
    @{$match}
        or return;

    my $count;
    $self->add_message({
        reference    => ( sprintf '%s:%s', $self->filename, $_->{line_number} ),
        domain       => $extra_parameter =~ m{ d }xms
            ? shift @{$match}
            : $self->domain,
        msgctxt      => $extra_parameter =~ m{ p }xms
            ? shift @{$match}
            : undef,
        msgid        => shift @{$match},
        msgid_plural => $extra_parameter =~ m{ n }xms
            ? do {
                my $plural = shift @{$match};
                $count = shift @{$match};
                $plural;
            }
            : undef,
        category     => $extra_parameter =~ m{ c }xms
            ? shift @{$match}
            : $self->category,
        automatic    => do {
            my $placeholders = shift @{$match};
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
Locale::TextDomain::OO::Extract::TT
- Extracts internationalization data from TemplateToolkit code

$Id: TT.pm 518 2014-10-09 14:56:14Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/extract/trunk/lib/Locale/TextDomain/OO/Extract/TT.pm $

=head1 VERSION

2.000

=head1 DESCRIPTION

This module extracts internationalization data from Template code.

Implemented rules:

 __('...
 __x('...
 __n('...
 __nx('...
 __p('...
 __px('...
 __np('...
 __npx('...

 __d('...
 __dx('...
 __dn('...
 __dnx('...
 __dp('...
 __dpx('...
 __dnp('...
 __dnpx('...

 __c('...
 __cx('...
 __cn('...
 __cnx('...
 __cp('...
 __cpx('...
 __cnp('...
 __cnpx('...

 __dc('...
 __dcx('...
 __dcn('...
 __dcnx('...
 __dcp('...
 __dcpx('...
 __dcnp('...
 __dcnpx('...

 l('...

Anything before __ is allowed, e.g. N__ and so on.
Whitespace is allowed everywhere.
Quote and escape any text like: ' text {placeholder} \\ \' ' or q{ text {placeholder} \\ \} \{ }

=head1 SYNOPSIS

    use Locale::TextDomain::OO::Extract::TT;
    use Path::Tiny qw(path);

    my $extractor = Locale::TextDomain::OO::Extract::TT->new;
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

L<Template|Template>

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
