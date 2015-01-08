package Locale::TextDomain::OO::Extract::Process::Plugin::PO; ## no critic (TidyCode)

use strict;
use warnings;
use Carp qw(confess);
use Encode qw(find_encoding);
use Locale::PO;
use Locale::TextDomain::OO::Util::ExtractHeader;
use Locale::TextDomain::OO::Util::JoinSplitLexiconKeys;
use Moo;
use MooX::StrictConstructor;
use MooX::Types::MooseLike::Base qw(HashRef Str);
use namespace::autoclean;

our $VERSION = '2.003';

has category => (
    is      => 'rw',
    isa     => Str,
    lazy    => 1,
    default => q{},
);

has domain => (
    is      => 'rw',
    isa     => Str,
    lazy    => 1,
    default => q{},
);

has language => (
    is      => 'rw',
    isa     => Str,
    lazy    => 1,
    default => 'i-default',
);

has project => (
    is  => 'rw',
    isa => sub {
        my $project = shift;
        defined $project
            or return;
        return Str->($project);
    },
);

has lexicon_ref => (
    is      => 'rw',
    isa     => HashRef,
    lazy    => 1,
    default => sub { {} },
);

sub slurp {
    my ( $self, $filename ) = @_;

    defined $filename
        or confess 'Undef is not a name of a po/pot file';
    my $pos_ref = Locale::PO->load_file_asarray($filename)
        or confess "$filename is not a valid po/pot file";

    my $header = Locale::TextDomain::OO::Util::ExtractHeader
        ->instance
        ->extract_header_msgstr(
            Locale::PO->dequote(
                $pos_ref->[0]->msgstr
                    || confess "No header found in file $filename",
            ),
        );
    my $encode_obj = find_encoding( $header->{charset} );
    my $nplurals   = $header->{nplurals};
    my $plural     = $header->{plural};

    my $decode_code = sub {
        my $text = shift;
        #
        defined $text
            or return;
        length $text
            or return q{};
        #
        return $encode_obj->decode($text);
    };
    my $decode_dequote_code = sub {
        my $text = shift;
        #
        defined $text
            or return;
        $text = Locale::PO->dequote($text);
        length $text
            or return;
        #
        return $encode_obj->decode($text);
    };

    my $index = 0;
    for my $po ( @{$pos_ref} ) {
        my %entry_of = (
            (
                $index++
                    ? ()
                    : (
                        nplurals => $nplurals,
                        plural   => $plural,
                    )
            ),
            (
                map { ## no critic (ComplexMappings)
                    my $value = $decode_code->( $po->$_ );
                    defined $value
                        ? ( $_ => $value )
                        : ();
                }
                qw( automatic comment reference )
            ),
            (
                map { ## no critic (ComplexMappings)
                    my $value = $decode_dequote_code->( $po->$_ );
                    defined $value
                        ? ( $_ => $value )
                        : ();
                }
                qw( msgctxt msgid msgid_plural )
            ),
            (
                defined $po->msgid_plural
                    ? (
                        msgstr_plural => [
                            do {
                                my $msgstr_n = $po->msgstr_n;
                                map {
                                    scalar $decode_dequote_code->( $msgstr_n->{$_} );
                                }
                                0 .. ( $nplurals - 1 );
                            },
                        ],
                    )
                    : do {
                        my $value = $decode_dequote_code->( $po->msgstr );
                        defined $value
                            ? ( msgstr => $value )
                            : ();
                    }
            ),
        );
        my $key_util = Locale::TextDomain::OO::Util::JoinSplitLexiconKeys->instance;
        my $lexicon_key = $key_util->join_lexicon_key({
            category => $self->category,
            domain   => $self->domain,
            language => $self->language,
            project  => $self->project,
        });
        my ( $message_key, $message_value_ref )
            = $key_util->split_message( \%entry_of );
        $self->lexicon_ref->{$lexicon_key}->{$message_key} = $message_value_ref;
    }

    return;
}

sub spew {
    my ( $self, $filename ) = @_;

    defined $filename
        or confess 'Undef is not a name of a po/pot file';

    my $key_util = Locale::TextDomain::OO::Util::JoinSplitLexiconKeys->instance;
    my $lexicon_key = $key_util
        ->instance
        ->join_lexicon_key({
            category => $self->category,
            domain   => $self->domain,
            language => $self->language,
            project  => $self->project,
        });
    my $entries_ref = $self->lexicon_ref->{$lexicon_key}
        or confess sprintf
            'No lexicon found for category "%s", domain "%s", language "%s" and project "%s"',
            $self->category,
            $self->domain,
            $self->language,
            ( defined $self->project ? $self->project : 'undef' );

    my $header = Locale::TextDomain::OO::Util::ExtractHeader
        ->instance
        ->extract_header_msgstr(
            $entries_ref->{ q{} }->{msgstr},
        )
        or confess sprintf
            'No header found in lexicon of category "%s", domain "%s", language "%s" and project "%s"',
                $self->category,
                $self->domain,
                $self->language,
                ( defined $self->project ? $self->project : 'undef');
    my $encode_obj = find_encoding( $header->{charset} );
    my $nplurals   = $header->{nplurals};

    my @po_data = map { ## no critic (ComplexMappings)
        my $entry_ref = $key_util->join_message( $_, $entries_ref->{$_} );
        if ( defined $entry_ref->{reference} ) {
            my $reference_regex = qr{
                \s*
                (
                    ( [^:]+ )
                    [:]
                    ( \d+ )
                )
            }xms;
            my @match = ref $entry_ref->{reference} eq 'HASH'
                ? (
                    map {
                        $_ =~ $reference_regex;
                    }
                    keys %{ $entry_ref->{reference} }
                )
                : $entry_ref->{reference} =~ m{ $reference_regex }xmsg;
            my @references;
            while ( my ( $reference, $name, $line ) = splice @match, 0, 3 ) { ## no critic (MagicNumbers)
                push @references, [ $reference, $name, $line ];
            }
            $entry_ref->{reference} = join "\n",
                map  { $_->[0] }
                sort { $a->[1] cmp $b->[1] || $a->[2] <=> $b->[2] }
                @references;
        }
        $entry_ref;
    }
    sort
    keys %{$entries_ref};

    my $encode_code = sub {
        my $text = shift;
        #
        defined $text
            or return;
        length $text
            or return q{};
        #
        return $encode_obj->encode($text);
    };
    Locale::PO->save_file_fromarray(
        $filename,
        [
            map { ## no critic (ComplexMappings)
                my $po_data = $_;
                Locale::PO->new(
                    (
                        map { ## no critic (ComplexMappings)
                            my $value = $po_data->{$_};
                            defined $value
                                ? ( "-$_" => scalar $encode_code->($value) )
                                : ();
                        }
                        qw( automatic comment msgctxt msgid msgid_plural reference )
                    ),
                    (
                        defined $po_data->{msgid_plural}
                            ? (
                                '-msgstr_n' => {
                                    map { ## no critic (ComplexMappings)
                                        my $value = $po_data->{msgstr_plural}->[$_];
                                        defined $value
                                            ? ( $_ => scalar $encode_code->($value) )
                                            : ();
                                    }
                                    0 .. ( $nplurals - 1 )
                                },
                            )
                            : ( '-msgstr' => scalar $encode_code->( $po_data->{msgstr} ) )
                    ),
                );
            }
            @po_data
        ],
    );

    return;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Extract::Process::Plugin::PO - MO file plugin

$Id: PO.pm 561 2014-11-11 16:12:48Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/extract/trunk/lib/Locale/TextDomain/OO/Extract/Process/Plugin/PO.pm $

=head1 VERSION

2.003

=head1 SYNOPSIS

see
L<Locale::TextDomain::OO::Extract::Process|Locale::TextDomain::OO::Extract::Process>

=head1 DESCRIPTION

PO file plugin

=head1 SUBROUTINES/METHODS

=head2 method new

=head2 rw attribute category, domain, language

The type is Str, defaults to q{} but language to 'i-default'.

=head2 rw attribute project

The type is Undef or Str.

=head2 method lexicon_ref

The type is HashRef, defaults to {}.

=head2 method slurp

Read PO file into lexicon_ref.

    $self->slurp($filename);

=head2 method spew

Write PO file from lexicon_ref.

    $self->spew($filename);

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run the *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Carp|Carp>

L<Encode|Encode>

L<Locale::PO|Locale::PO>

L<Locale::TextDomain::OO::Util::ExtractHeader|Locale::TextDomain::OO::Util::ExtractHeader>

L<Locale::TextDomain::OO::Util::JoinSplitLexiconKeys|Locale::TextDomain::OO::Util::JoinSplitLexiconKeys>

L<Moo|Moo>

L<MooX::StrictConstructor|MooX::StrictConstructor>

L<MooX::Types::MooseLike::Base|MooX::Types::MooseLike::Base>

L<namespace::autoclean|namespace::autoclean>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

not known

=head1 SEE ALSO

L<Locale::TextDomain::OO::Extract::Process|Locale::TextDomain::OO::Extract::Process>

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
