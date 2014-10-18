package Locale::TextDomain::OO::Util::ExtractHeader; ## no critic (TidyCode)

use strict;
use warnings;
use Carp qw(confess);
use English qw(-no_match_vars $EVAL_ERROR);
use Locale::TextDomain::OO::Util::Constants;
use Moo;
use MooX::StrictConstructor;
require Safe;
use namespace::autoclean;

our $VERSION = '0.001';

with qw(
    MooX::Singleton
);

my $perlify_plural_forms_ref__code_ref = sub {
    my $plural_forms_ref = shift;

    ${$plural_forms_ref} =~ s{ \b ( nplurals | plural | n ) \b }{\$$1}xmsg;

    return;
};

my $nplurals__code_ref = sub {
    my $plural_forms = shift;

    $perlify_plural_forms_ref__code_ref->(\$plural_forms);
    my $code = <<"EOC";
        my \$n = 0;
        my (\$nplurals, \$plural);
        $plural_forms;
        \$nplurals;
EOC
    my $nplurals = Safe->new->reval($code)
        or confess "Code of Plural-Forms $plural_forms is not safe, $EVAL_ERROR";

    return $nplurals;
};

my $plural__code_ref = sub {
    my $plural_forms = shift;

    return $plural_forms =~ m{ \b plural= ( [^;\n]+ ) }xms;
};

my $plural_code__code_ref = sub {
    my $plural_forms = shift;

    $perlify_plural_forms_ref__code_ref->(\$plural_forms);
    my $code = <<"EOC";
        sub {
            my \$n = shift;

            my (\$nplurals, \$plural);
            $plural_forms;

            return 0 + \$plural;
        }
EOC
    my $code_ref = Safe->new->reval($code)
        or confess "Code $plural_forms is not safe, $EVAL_ERROR";

    return $code_ref;
};

sub extract_header_msgstr {
    my ( $self, $header_msgstr ) = @_;

    defined $header_msgstr
        or confess 'Header is not defined';
    ## no critic (ComplexRegexes)
    my ( $plural_forms ) = $header_msgstr =~ m{
        ^
        Plural-Forms:
        [ ]*
        (
            nplurals [ ]* [=] [ ]* \d+   [ ]* [;]
            [ ]*
            plural   [ ]* [=] [ ]* [^;\n]+ [ ]* [;]?
            [ ]*
        )
        $
    }xms
        or confess 'Plural-Forms not found in header';
    ## use critic (ComplexRegexes)
    my ( $charset ) = $header_msgstr =~ m{
        ^
        Content-Type:
        [^;]+ [;] [ ]*
        charset [ ]* = [ ]*
        ( [^ ]+ )
        [ ]*
        $
    }xms
        or confess 'Content-Type with charset not found in header';
    my ( $multiplural_nplurals ) = $header_msgstr =~ m{
        ^ X-Multiplural-Nplurals: [ ]* ( \d+ ) [ ]* $
    }xms;

    return {(
        nplurals    => $nplurals__code_ref->($plural_forms),
        plural      => $plural__code_ref->($plural_forms),
        plural_code => $plural_code__code_ref->($plural_forms),
        charset     => $charset,
        (
            $multiplural_nplurals
            ? ( multiplural_nplurals => $multiplural_nplurals )
            : ()
        ),
    )};
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Util::ExtractHeader - Gettext header extractor

$Id: $

$HeadURL: $

=head1 VERSION

0.001

=head1 DESCRIPTION

This module is extracting charset and plural date from gettext header.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::Util::ExtractHeader;

    my $extractor = Locale::TextDomain::OO::Util::ExtractHeader->instance;

=head1 SUBROUTINES/METHODS

=head2 method extract_header_msgstr

    $hash_ref = $extractor->extract_header_msgstr($header_msgstr);

That hash_ref contains:

    nplurals    => $count_of_plural_forms,
    plural      => $the_original_formula,
    plural_code => $code_ref__to_select_the_right_plural_form,
    charset     => $charset,

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

confess

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Carp|Carp>

L<English|English>

L<Locale::TextDomain::OO::Util::Constants|Locale::TextDomain::OO::Util::Constants>

L<Moo|Moo>

L<MooX::StrictConstructor|MooX::StrictConstructor>

L<Safe|Safe>

L<namespace::autoclean|namespace::autoclean>

L<MooX::Singleton|MooX::Singleton>

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
