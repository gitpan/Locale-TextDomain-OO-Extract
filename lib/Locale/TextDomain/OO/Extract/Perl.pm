package Locale::TextDomain::OO::Extract::Perl; ## no critic (TidyCode)

use strict;
use warnings;
use Carp qw(confess);
use Moo;
use MooX::Types::MooseLike::Base qw(ArrayRef Str);
use namespace::autoclean;

our $VERSION = '2.002';

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

## no critic (Complex Regexes)
my $start_rule = qr{
    \b
    (?:
        (?:
            # Gettext::Loc, Gettext
            N? (?: loc_ | __ ) d? c? n? p? x?
            # Maketext::Loc, Maketext::Localise, Maketext::Localize
            | N? loc (?: ali[sz]e )? (?: _mp? )?
            # Maketext
            | N? maketext (?: _p )?
            # Getext::DomainAndCategory, Getext::Loc::DomainAndCategory
            | (?: loc_ | __ ) begin_ d? c?
        )
        \s*
        [(]
    )
    # Getext::DomainAndCategory, Getext::Loc::DomainAndCategory
    | (?: loc_ | __ ) end_ d? c?
}xms;
## use critic (Complex Regexes)

my $rules = [
    # loc_, __
    [
        qr{ \b N? (?: loc_ | __ ) ( x? ) \s* [(] \s* }xms,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? (?: loc_ | __ ) ( n x? ) \s* [(] \s* }xms,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? (?: loc_ | __ ) ( p x? ) \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? (?: loc_ | __ ) ( np x? ) \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $singular_rule,
        $comma_rule,
        $plural_rule,
        $comma_rule,
        $count_rule,
        $close_rule,
    ],

    # loc_d, __d
    'or',
    [
        qr{ \b N? (?: loc_ | __ ) ( d x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? (?: loc_ | __ ) ( dn x? ) \s* [(] \s* }xms,
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
        qr{ \b N? (?: loc_ | __ ) ( dp x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $context_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? (?: loc_ | __ ) ( dnp x? ) \s* [(] \s* }xms,
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

    # loc_c, __c
    'or',
    [
        qr{ \b N? (?: loc_ | __ ) ( c x? ) \s* [(] \s* }xms,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? (?: loc_ | __ ) ( cn x? ) \s* [(] \s* }xms,
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
        qr{ \b N? (?: loc_ | __ ) ( cp x? ) \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? (?: loc_ | __ ) ( cnp x? ) \s* [(] \s* }xms,
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

    # loc_dc, __dc
    'or',
    [
        qr{ \b N? (?: loc_ | __ ) ( dc x? ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $text_rule,
        $comma_rule,
        $category_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? (?: loc_ | __ ) ( dcn x? ) \s* [(] \s* }xms,
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
        qr{ \b N? (?: loc_ | __ ) ( dcp x? ) \s* [(] \s* }xms,
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
        qr{ \b N? (?: loc_ | __ ) ( dcnp x? ) \s* [(] \s* }xms,
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

    # maketext loc, localize, localize
    'or',
    [
        qr{ \b N? loc (?: ali[sz]e )? (?: _m )? () \s* [(] \s* }xms,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? loc (?: ali[sz]e )? _m ( p ) \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],

    # maketext
    'or',
    [
        qr{ \b N? maketext () \s* [(] \s* }xms,
        $text_rule,
        $close_rule,
    ],
    'or',
    [
        qr{ \b N? maketext_ ( p ) \s* [(] \s* }xms,
        $context_rule,
        $comma_rule,
        $text_rule,
        $close_rule,
    ],

    # begin
    'or',
    [
        qr{ \b (?: loc_ | __ ) ( begin ) _ ( [dc] ) \s* [(] \s* }xms,
        $domain_or_category_rule,
    ],
    'or',
    [
        qr{ \b (?: loc_ | __ ) ( begin ) [_] ( dc ) \s* [(] \s* }xms,
        $domain_rule,
        $comma_rule,
        $category_rule,
    ],

    # end
    'or',
    [
        qr{ \b (?: loc_ | __ ) ( end ) [_] ( [dc] ) \b }xms,
    ],
    'or',
    [
        qr{ \b (?: loc_ | __ ) ( end ) [_] ( dc ) \b }xms,
    ],
];

# remove pod and code after __END__
sub preprocess {
    my $self = shift;

    my $content_ref = $self->content_ref;

    my ($is_pod, $is_end);
    ${$content_ref} = join "\n", map {
        $_ eq '__END__'      ? do { $is_end = 1; q{} }
        : $is_end            ? ()
        : m{ = ( \w+ ) }xms  ? (
            lc $1 eq 'cut'
            ? do { $is_pod = 0; q{} }
            : do { $is_pod = 1; q{} }
        )
        : $is_pod            ? q{}
        : $_;
    } split m{ \r? \n }xms, ${$content_ref};

    return;
}

sub stack_item_mapping {
    my $self = shift;

    my $match = $_->{match};
    # The chars after __ were stored to make a decision now.
    my $extra_parameter = shift @{$match};
    @{$match}
        or return;

    if ( $extra_parameter eq 'begin' ) {
        {
            d => sub {
                push @{ $self->domain_stack }, $self->domain;
                $self->domain( shift @{$match} );
            },
            c => sub {
                push @{ $self->category_stack }, $self->category;
                $self->category( shift @{$match} );
            },
            dc => sub {
                push @{ $self->domain_stack }, $self->domain;
                $self->domain( shift @{$match} );
                push @{ $self->category_stack }, $self->category;
                $self->category( shift @{$match} );
            },
        }->{ shift @{$match} }->();
        return;
    }
    if ( $extra_parameter eq 'end' ) {
        {
            d => sub {
                @{ $self->domain_stack }
                    or confess 'Domain stack is empty because __end_d is called without __begin_d or __begin_dc before';
                $self->domain( pop @{ $self->domain_stack } );
            },
            c => sub {
                @{ $self->category_stack }
                    or confess 'Category stack is empty because __end_c is called without __begin_c or __begin_dc before';
                $self->category( pop @{ $self->category_stack } );
            },
            dc => sub {
                @{ $self->domain_stack }
                    or confess 'Domain stack is empty because __end_dc is called without __begin_d or __begin_dc before';
                @{ $self->category_stack }
                    or confess 'Category stack is empty because __end_dc is called without __begin_c or __begin_dc before';
                $self->domain( pop @{ $self->domain_stack } );
                $self->category( pop @{ $self->category_stack } );
            },
        }->{ shift @{$match} }->();
        return;
    }

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
Locale::TextDomain::OO::Extract::Perl
- Extracts internationalization data from Perl source code

$Id: Perl.pm 561 2014-11-11 16:12:48Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/extract/trunk/lib/Locale/TextDomain/OO/Extract/Perl.pm $

=head1 VERSION

2.002

=head1 DESCRIPTION

This module extracts internationalization data from Perl source code.

Implemented rules:

 loc_('...
 loc_x('...
 loc_n('...
 loc_nx('...
 loc_p('...
 loc_px('...
 loc_np('...
 loc_npx('...

 loc_d('...
 loc_dx('...
 loc_dn('...
 loc_dnx('...
 loc_dp('...
 loc_dpx('...
 loc_dnp('...
 loc_dnpx('...

 loc_c('...
 loc_cx('...
 loc_cn('...
 loc_cnx('...
 loc_cp('...
 loc_cpx('...
 loc_cnp('...
 loc_cnpx('...

 loc_dc('...
 loc_dcx('...
 loc_dcn('...
 loc_dcnx('...
 loc_dcp('...
 loc_dcpx('...
 loc_dcnp('...
 loc_dcnpx('...

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

 loc('...
 loc_mp('...

 localize('...
 localize_mp('...

 localise('...
 localise_mp('...

 maketext('...
 maketext_p('...

 loc_begin_d('
 loc_begin_c('
 loc_begin_dc('

 loc_end_d
 loc_end_c
 loc_end_dc

 __begin_d('
 __begin_c('
 __begin_dc('

 __end_d
 __end_c
 __end_dc

N before loc..., __... and maketext... is allowed. E.g. Nloc_ and so on.
Whitespace is allowed everywhere.
Quote and escape any text like: ' text {placeholder} \\ \' ' or q{ text {placeholder} \\ \} \{ }

=head1 SYNOPSIS

    use Locale::TextDomain::OO::Extract::Perl;
    use Path::Tiny qw(path);

    my $extractor = Locale::TextDomain::OO::Extract::Perl->new;
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

This method removes the POD and all after __END__.

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

L<Carp|Carp>

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
