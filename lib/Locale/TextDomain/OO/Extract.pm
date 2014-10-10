package Locale::TextDomain::OO::Extract; ## no critic (TidyCode)

use strict;
use warnings;

our $VERSION = '2.001';

1;

__END__

=head1 NAME
Locale::TextDomain::OO::Extract - Extracts internationalization data

$Id: Extract.pm 518 2014-10-09 14:56:14Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/extract/trunk/lib/Locale/TextDomain/OO/Extract.pm $

=head1 VERSION

2.001

=head1 DESCRIPTION

This module extracts internationalization data.

The extractor runs the following steps:

 * preprocess the file
 * find all possible positions in content
 * match exactly and create a stack
 * map the stack to a lexicon entry

If you want to write the lexicon structure to pot files
see folder example of this distribution how it works.

=head1 SYNOPSIS

There are different extract module for different files.
All this extracted data are stored into one or selective lexicons.
At the end of extraction this lexicons
can be stored into pot files or anywhere else.

=head2 Use an existing extractor

    use strict;
    use warnings;
    use Locale::TextDomain::OO::Extract::...;
    use Path::Tiny qw(path);

    my $extractor = Locale::TextDomain::OO::Extract::...->new(
        # all parameters are optional
        lexicon_ref => \my %lexicon,  # default is {}
        domain      => 'MyDomain',    # default is q{}
        category    => 'LC_MESSAGES', # default is q{}
        debug_code  => sub {          # default is undef
            my ($group, $message) = @_;
            print $group, ', ', $message, "\n";
            return;
        },
    );

    my @files = (
        'relative_dir/filename1.suffix',
        'relative_dir/filename2.suffix',
    );
    for ( @files ) {
        $extractor->clear;
        $extractor->filename($_);
        $extractor->content_ref( \( path($_)->slurp_utf8 ) );
        $extractor->extract;
    }

    # do something with that
    # maybe write a pot file using Locale::PO
    ... = extractor->lexicon_ref;

=head2 Write your own extractor

    package MyExtractor;

    use Moo;

    extends qw(
        Locale::TextDomain::OO::Extract::Base::RegexBasedExtractor
    );
    with qw(
        Locale::TextDomain::OO::Extract::Role::File
    );

Optional method to uncomment or interpolate the file content or anything else.

    sub preprocess {
        my $self = shift;

        my $content_ref = $self->content_ref;
        # modify anyhow
        ${$content_ref}=~ s{\\n}{\n}xmsg;

        return;
    }

Map the reference, all the matches or defaults.
See Perl extractor how it works.
Maybe ignore some stack entries.

    sub stack_item_mapping {
        my $self = shift;

        my $match = $_->{match};
        $self->add_message({
            reference    => ...,
            domain       => ...,
            category     => ...,
            msgctxt      => ...,
            msgid        => ...,
            msgid_plural => ...,
        });

        return;
    }

Match all positions, the searched string is starting with.
You can match to the end of the searched string but there is no need for.

    my $start_rule = qr{ ... }xms;

Match exactly the different things.
All the values from () are stored in stack.
Prepare the stack in a way you are able to merge the data.
Maybe an empty match helps to have all on the right position.

'or' means: if not then try the following.
'or' is only allowed between 2 array references.

    my $rules = [
        [
            qr{ ... ( ... ) ...}xms, # match this
            qr{ ... ( ... ) ...}xms, # and then that
        ]
        'or',
        [
            [
                qr{ ... ( ... ) ... }xms,
            ],
            'or',
            [
                qr{ ... ( ... ) ... }xms,
            ],
        ],
    ];

Tell your extractor what steps he should run.

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

=head1 SUBROUTINES/METHODS

none

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

none

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
