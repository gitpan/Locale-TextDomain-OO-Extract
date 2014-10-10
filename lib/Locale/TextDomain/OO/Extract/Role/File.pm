package Locale::TextDomain::OO::Extract::Role::File; ## no critic (TidyCode)

use strict;
use warnings;
use Moo::Role;
use MooX::Types::MooseLike::Base qw(ArrayRef HashRef Str);
use namespace::autoclean;

our $VERSION = '2.001';

with qw(
    Locale::TextDomain::OO::Extract::Role::JoinSplitLexiconKeys
);

has category => (
    is      => 'rw',
    isa     => Str,
    default => q{},
    clearer => '_clear_category',
);

has category_stack => (
    is      => 'rw',
    isa     => ArrayRef,
    default => sub { [] },
    clearer => '_clear_category_stack',
);

has domain => (
    is      => 'rw',
    isa     => Str,
    default => q{},
    clearer => '_clear_domain',
);

has domain_stack => (
    is      => 'rw',
    isa     => ArrayRef,
    default => sub { [] },
    clearer => '_clear_domain_stack',
);

has filename => (
    is       => 'rw',
    isa      => Str,
    lazy     => 1,
    default  => 'unknown',
    clearer  => '_clear_filename',
);

has lexicon_ref => (
    is      => 'rw',
    isa     => HashRef,
    lazy    => 1,
    default => sub { {} },
);

sub clear {
    my $self = shift;

    $self->_clear_category;
    $self->_clear_category_stack;
    $self->_clear_domain;
    $self->_clear_domain_stack;
    $self->_clear_filename;

    return;
}

my $list_if_length = sub {
    my ($item, @list) = @_;

    defined $item or return;
    length $item or return;

    return @list;
};

sub add_message {
    my ($self, $msg_ref) = @_;

    # build the lexicon part
    my $lexicon_key = $self->join_lexicon_key({(
        map {
            $_ => $msg_ref->{$_};
        } qw( domain category )
    )});
    my $lexicon
        = $self->lexicon_ref->{$lexicon_key}
        ||= {
            q{} => {
                msgstr => {
                    nplurals => 2,
                    plural   => 'n != 1',
                }
            },
        };

    # build the message part
    my $msg_key = $self->join_message_key({(
        map {
            $_ => $msg_ref->{$_};
        } qw( msgctxt msgid msgid_plural )
    )});
    if ( exists $lexicon->{$msg_key} ) {
        $lexicon->{$msg_key}->{reference}->{ $msg_ref->{reference} } = undef;
        return;
    }
    $lexicon->{$msg_key} = {
        $list_if_length->( $msg_ref->{automatic},    automatic    => $msg_ref->{automatic} ),
        $list_if_length->( $msg_ref->{msgctxt},      msgctxt      => $msg_ref->{msgctxt} ),
        $list_if_length->( $msg_ref->{msgid},        msgid        => $msg_ref->{msgid} ),
        $list_if_length->( $msg_ref->{msgid_plural}, msgid_plural => $msg_ref->{msgid_plural} ),
        reference => { $msg_ref->{reference} => undef },
    };

    return;
}

1;

__END__

=head1 NAME
Locale::TextDomain::OO::Extract::Role::File - Gettext file related stuff

$Id: File.pm 518 2014-10-09 14:56:14Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/extract/trunk/lib/Locale/TextDomain/OO/Extract/Role/File.pm $

=head1 VERSION

2.001

=head1 DESCRIPTION

Role for gettext file related stuff.

=head1 SYNOPSIS

    with 'Locale::TextDomain::OO::Extract::Role::File';

=head1 SUBROUTINES/METHODS

=head2 method category

Set/get the default category.

=head2 method domain

Set/get the default domain.

=head2 method filename

Set/get the filename for reference.

=head2 method lexicon_ref

Set/get the extracted data as lexicon data structure.

=head2 method clear

Clears category, category_stack, domain, domain_stack and filename.
That is important before extract the next file.

=head2 method add_message

    $extractor->add_message({
        category     => 'my category', # or q{} or undef
        domain       => 'my domain',   # or q{} or undef
        reference    => 'dir/file.ext:123',
        automatic    => 'my automatic comment',
        msgctxt      => 'my context'   # or q{} or undef
        msgid        => 'my singular',
        msgid_plural => 'my plural',   # or q{} or undef
    });

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Moo::Role|Moo::Role>

L<MooX::Types::MooseLike::Base|MooX::Types::MooseLike::Base>

L<namespace::autoclean|namespace::autoclean>

L<Locale::TextDomain::OO::Extract::Role::JoinSplitLexiconKeys|Locale::TextDomain::OO::Extract::Role::JoinSplitLexiconKeys>

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
