package Locale::TextDomain::OO::Extract::Base::RegexBasedExtractor; ## no critic (TidyCode)

use strict;
use warnings;
use Clone qw(clone);
use Data::Dumper ();
use Moo;
use MooX::StrictConstructor;
use MooX::Types::MooseLike::Base qw(ArrayRef CodeRef RegexpRef ScalarRef);
use namespace::autoclean;

our $VERSION = '2.000';

has content_ref => (
    is  => 'rw',
    isa => ScalarRef,
);

has start_rule => (
    is  => 'rw',
    isa => RegexpRef,
);

has rules => (
    is  => 'rw',
    isa => ArrayRef,
);

has debug_code => (
    is      => 'rw',
    isa     => CodeRef,
    clearer => 'clear_debug_code',
);

has stack => (
    is  => 'rw',
    isa => ArrayRef,
);

sub _parse_pos {
    my $self = shift;

    my $regex       = $self->start_rule;
    my $content_ref = $self->content_ref;
    defined ${$content_ref}
        or return $self;
    my @stack;
    while ( ${$content_ref} =~ m{ \G .*? ( $regex ) }xmsgc ) {
        push @stack, {
            start_pos => pos( ${$content_ref} ) - length $1,
        };
    }
    $self->stack(\@stack);

    return $self;
}

sub _parse_rules {
    my $self = shift;

    my $content_ref = $self->content_ref;
    for my $stack_item ( @{ $self->stack } ) {
        my $rules       = clone( $self->rules );
        my $pos         = $stack_item->{start_pos};
        my $has_matched = 0;
        $self->debug_code
            and $self->debug_code->('parser', "Starting at pos $pos.");
        my (@parent_rules, @parent_pos);
        RULE: {
            my $rule = shift @{$rules};
            if (! $rule) {
                $self->debug_code
                    and $self->debug_code->('parser', 'No more rules found.');
                if (@parent_rules) {
                    $rules = pop @parent_rules;
                    ()     = pop @parent_pos;
                    $self->debug_code
                        and $self->debug_code->('parser', 'Going back to parent.');
                    redo RULE;
                }
                last RULE;
            }
            # goto child
            if ( ref $rule eq 'ARRAY' ) {
                push @parent_rules, $rules;
                push @parent_pos,   $pos;
                $rules = clone($rule);
                $self->debug_code
                    and $self->debug_code->('parser', 'Going to child.');
                redo RULE;
            }
            # alternative
            if ( lc $rule eq 'or' ) {
                if ( $has_matched ) {
                    $rules       = pop @parent_rules;
                    ()           = pop @parent_pos;
                    $has_matched = 0;
                    $self->debug_code
                        and $self->debug_code->('parser', 'Ignore alternative.');
                    redo RULE;
                }
                $self->debug_code
                    and $self->debug_code->('parser', 'Try alternative.');
                redo RULE;
            }
            pos ${$content_ref} = $pos;
            $self->debug_code
                and $self->debug_code->('parser', "Set the current pos to $pos.");
            $has_matched
                = my ($match, @result)
                = ${$content_ref} =~ m{ \G ($rule) }xms;
            if ($has_matched) {
                push @{ $stack_item->{match} }, @result;
                $pos += length $match;
                $self->debug_code
                    and $self->debug_code->(
                        'parser',
                        "Rule $rule has matched:\n$match\nThe current pos is $pos.",
                    );
                redo RULE;
            }
            $rules = pop @parent_rules;
            $pos   = pop @parent_pos;
            $self->debug_code
                and $self->debug_code->(
                    'parser',
                    "Rule $rule has not matched.\nGoing back to parent.",
                );
            redo RULE;
        }
    }

    return $self;
}

sub _cleanup_and_calculate_reference {
    my $self = shift;

    my $stack       = $self->stack;
    my $content_ref = $self->content_ref;
    @{$stack} = map {
        exists $_->{match}
        ? do {
            # calculate reference
            my $pre_match = substr ${$content_ref}, 0, $_->{start_pos};
            my $newline_count = $pre_match =~ tr{\n}{\n};
            $_->{line_number} = $newline_count + 1;
            $_;
        }
        # cleanup
        : ();
    } @{$stack};

    # debug if requested
    $self->debug_code
        or return $self;
    my $dump = Data::Dumper ## no critic (LongChainsOfMethodCalls)
        ->new([ $self->stack ], [ qw(stack) ])
        ->Indent(1)
        ->Quotekeys(0)
        ->Sortkeys(1)
        ->Useqq(1)
        ->Dump;
    chomp $dump;
    $self->debug_code->('stack', $dump);

    return $self;
}

sub extract {
    my ($self, $arg_ref) = @_;

    $self->_parse_pos;
    $self->_parse_rules;
    $self->_cleanup_and_calculate_reference;

    return $self;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME
Locale::TextDomain::OO::Extract::Base::RegexBasedExtractor
- Extract data using regexes

$Id: RegexBasedExtractor.pm 518 2014-10-09 14:56:14Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/extract/trunk/lib/Locale/TextDomain/OO/Extract/Base/RegexBasedExtractor.pm $

=head1 VERSION

2.000

=head1 DESCRIPTION

This module extracts data using regexes to store anywhere.

=head1 SYNOPSIS

    use Path::Tiny qw(path);
    use Locale::TextDomain::OO::Extract::Base::RegexBasedExtractor;

    my $extractor = Locale::TextDomain::OO::Extract::Base::RegexBasedExtractor->new(
        content_ref => \'... string to extract ...',
        start_rule  => qr{ ... }xms,
        rules       => [ qr{ ... ( ... ) ... }xms ],
        debug_code  => sub { ... },
    );
    $extractor->extract;

=head1 SUBROUTINES/METHODS

=head2 method new

All parameters are optional.

    my $extractor = Locale::TextDomain::OO::Extract::Base::RegexBasedExtractor->new(
        # how to find such lines
        start_rule => qr{ __ n?p?x? \( }xms,

        # how to find the parameters
        rules => [
            [
                # __( 'text'
                # __x( 'text'
                qr{ __ (x?) \s* \( \s* }xms,
                qr{ \s* }xms,
                # You can re-use the next reference.
                # It is a subdefinition.
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
            ],
            # The next array reference describes an alternative
            # and not a subdefinition.
            'or',
            [
                # next alternative e.g.
                # __n( 'context' , 'text'
                # __nx( 'context' , 'text'
                ...
            ],
        ],

        # debug output for other rules than perl
        debug_code => sub {
            my ($group, $message) = @_;
            # group can anything, used groups are:
            # - parser
            # - stack
        },
    );

=head2 method extract

Run the extractor

    $extractor->extract;

=head2 method content_ref

Set/get the content to extract by scalar reference to that string.

=head2 method start_rule

Set/get the rule as regex reference
that is matching the begin of expected string.

=head2 method rules

Set/get an array reference owith all the rules to extract.

=head2 method debug_code, clear_debug_code

Set/get a code reference if debugging is needed.

To switch off run method clear_debug_code.

=head2 method stack

Set/get the stack as array reference during extraction

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Clone|Clone>

L<Data::Dumper|Data::Dumper>

L<Moo|Moo>

L<MooX::StrictConstructor|MooX::StrictConstructor>

L<MooX::Types::MooseLike::Base|MooX::Types::MooseLike::Base>

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

Copyright (c) 2009 - 2014,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
