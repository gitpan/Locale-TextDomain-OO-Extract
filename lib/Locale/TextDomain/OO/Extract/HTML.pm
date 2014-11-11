package Locale::TextDomain::OO::Extract::HTML; ## no critic (TidyCode)

use strict;
use warnings;
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

my $text_rule = qr{ \s* ( [^<]+ ) }xms;

## no critic (ComplexRegexes)
my $start_rule = qr{
    [<] [^>]*?
    \b class \s* = \s*
    (?:
        ["] [^"]*? \b (?: loc_ | __ | loc ) \b [^"]*? ["]
        |
        ['] [^']*? \b (?: loc_ | __ | loc ) \b [^']*? [']
    )
}xms;

my $rules = [
    [
        [
            qr{
                [<] [^>]*?
                \b class \s* = \s* " [^"]*?
                \b (?: loc_ | __ | loc ) \b
                [^"]*? ["]
                [^>]* [>]
            }xms,
        ],
        'or',
        [
            qr{
                [<] [^>]*?
                \b class \s* = \s* ' [^']*?
                \b (?: loc_ | __ | loc ) \b
                [^']*? [']
                [^>]* [>]
            }xms,
        ],
    ],
    $text_rule,
];
## use critic (ComplexRegexes)

sub stack_item_mapping {
    my $self = shift;

    my $match = $_->{match};
    @{$match}
        or return;

    $self->add_message({
        reference => ( sprintf '%s:%s', $self->filename, $_->{line_number} ),
        msgid     => do {
            my $string = shift @{$match};
            $string =~ s{ \s+ \z }{}xms;
            $string;
        },
    });

    return $self;
}

sub extract {
    my $self = shift;

    $self->start_rule($start_rule);
    $self->rules($rules);

    $self->SUPER::extract;
    for ( @{ $self->stack } ) {
        $self->stack_item_mapping($_);
    }

    return $self;
}

1;

__END__

=head1 NAME
Locale::TextDomain::OO::Extract::HTML
- Extracts internationalization data from HTML

$Id: HTML.pm 561 2014-11-11 16:12:48Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/extract/trunk/lib/Locale/TextDomain/OO/Extract/HTML.pm $

=head1 VERSION

2.002

=head1 DESCRIPTION

This module extracts internationalization data from HTML.

Implemented rules:

Gettext::Loc

 <any_tag ... class="... loc_ ..." ... > ... text to extract ... <

Gettext

 <any_tag ... class="... __ ..." ... > ... text to extract ... <

Maketext

 <any_tag ... class="... loc ..." ... > ... text to extract ... <

Whitespace is allowed everywhere.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::Extract::HTML;

=head1 SUBROUTINES/METHODS

=head2 method new

All parameters are optional.
See Locale::TextDomain::OO::Extract to replace the defaults.

    my $extractor = Locale::TextDomain::OO::Extract::HTML->new;

=head2 method extract

Call

    $extractor->filename('dir/filename for reference');
    $extractor->extract;

=head2 method stack_item_mapping

    $self->stack_item_mapping($stack_item);

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

L<HTML::Zoom|HTML::Zoom>

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
