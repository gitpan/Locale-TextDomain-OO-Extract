package Locale::TextDomain::OO::Extract::HTML; ## no critic (TidyCode)

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

my $text_rule = qr{ \s* ( [^<]+ ) }xms;

## no critic (ComplexRegexes)
my $start_rule = qr{
    [<] [^>]*?
    \b class \s* = \s*
    (?:
        ["] [^"]*? \b loc \b [^"]*? ["]
        |
        ['] [^']*? \b loc \b [^']*? [']
    )
}xms;
## use critic (ComplexRegexes)

my $rules = [
    [
        [
            qr{ [<] [^>]*? \b class \s* = \s* " [^"]*? \b loc \b [^"]*? ["] [^>]* [>] }xms,
        ],
        'or',
        [
            qr{ [<] [^>]*? \b class \s* = \s* ' [^']*? \b loc \b [^']*? ['] [^>]* [>] }xms,
        ],
    ],
    $text_rule,
];

sub stack_item_mapping {
    my $self = shift;

    my $match = $_->{match};
    @{$match}
        or return;

    $self->add_message({
        reference    => ( sprintf '%s:%s', $self->filename, $_->{line_number} ),
        msgid        => do {
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

$Id: HTML.pm 518 2014-10-09 14:56:14Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/extract/trunk/lib/Locale/TextDomain/OO/Extract/HTML.pm $

=head1 VERSION

2.000

=head1 DESCRIPTION

This module extracts internationalization data from HTML.

Implemented rules:

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

parent

L<Locale::TextDomain::OO::Extract|Locale::TextDomain::OO::Extract>

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

Copyright (c) 2014,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
