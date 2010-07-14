#!/usr/bin/perl
# Copyright (c) 2010
# Frank Terbeck <ft@bewatermyfriend.org>, All rights reserved.
# Terms for redistribution and use can be found in `LICENCE'.

###########################################################################
package DewiFile;

use strict;
use warnings qw(all);
use English '-no_match_vars';
use File::Glob qw{ bsd_glob };
use File::Spec;

my $reg_calls = 0;

# output
sub verbose {
    main::verbose(@_);
    return 1;
}

sub debug {
    main::debug(@_);
    return 1;
}

# option handling
sub set_opt {
    my ($key, $val) = @_;

    main::set_opt($key, $val);
    print "rc.perl: Set option '$key' to \"$val\"\n"
        if (main::get_opt_bool('debug'));
    return 1;
}

sub get_opt {
    return main::get_opt(@_);
}

sub get_opt_bool {
    return main::get_opt_bool(@_);
}

# predefined `glob' code
sub regularfiles {
    my ($glob) = @_;

    return grep { -f } bsd_glob($glob);
}

# predefined `transform' code
sub notransform {
    return $_[0];
}

sub makedotfile {
    return '.' . $_[0];
}

# The `register()' subroutine
sub __register_defaults {
    my ($h) = @_;

    if (!defined $h->{glob}) {
        die "Cannot call register() without `glob' argument.\n"
    }
    if (ref($h->{glob}) eq 'CODE' && !defined &{ $h->{glob} }) {
        die
        "register(): Unknown coderef in `glob'.\n".
        "                        Call number $reg_calls.\n";
    }

    if (!defined $h->{destination}) {
        $h->{destination} = '~/';
        debug("register(): Setting default `destination': ~/\n");
    }

    if (!defined $h->{method}) {
        $h->{method} = 'copy';
        debug("register(): Setting default `method': copy\n");
    }

    if (!defined $h->{transform}) {
        $h->{transform} = \&notransform;
        debug("register(): Setting default `transform': `notransform'\n");
    }

    if (!defined &{ $h->{transform} }) {
        die
        "register(): Unknown coderef in `transform'.\n".
        "                        Call number $reg_calls.\n";
    }

    if (!defined $h->{globarg}) {
        $h->{globarg} = '';
        debug("register(): Setting default `globarg': (empty string)\n");
    }

    return 1;
}

sub __register {
    my ($h) = @_;
    my (@files);

    if (ref($h->{glob}) eq 'CODE') {
        @files = $h->{glob}->($h->{globarg});
    } else {
        @files = bsd_glob($h->{glob});
    }

    $h->{destination} =~ s!^~!$ENV{HOME}!;
    $h->{destination} = File::Spec->canonpath($h->{destination});
    foreach my $path (@files) {
        my $new = {};
        my ($volume,$directories,$file) = File::Spec->splitpath( $path );

        $new->{path} = $path;
        $new->{name} = $file;
        $new->{transformed} = $h->{transform}->($file);
        $new->{destination} = $h->{destination};
        $new->{mergedname} =
        main::merge_name($h->{destination}, $new->{transformed});
        $new->{method} = $h->{method};

        debug(
            "register(): \""      . $new->{path}        . "\"\n" .
            "           Name: \"" . $new->{name}        . "\"\n" .
            "    Transformed: \"" . $new->{transformed} . "\"\n" .
            "    Destination: \"" . $new->{destination} . "\"\n" .
            "    Merged-Name: \"" . $new->{mergedname}  . "\"\n" .
            "         Method: "   . $new->{method}      . "\n");

        push @main::regfiles, $new;
    }

    return 1;
}

sub register {
    $reg_calls++;
    if ($#_ != 0) {
        die "usage: register( { foo => val0, bar => val1, ... } );\n";
    }
    my ($arg) = @_;
    my $type = ref $arg;

    if ($type eq '') {
        my $hr = { glob => "$arg" };
        __register_defaults($hr);
        __register($hr);
    } elsif ($type eq 'HASH') {
        __register_defaults($arg);
        __register($arg);
    } else {
        die
        "The argument to the register function must be either a\n".
        "scalar or a hash reference.\n";
    }

    return 1;
}

# Dewifile reader
sub read_dewifile {
    my ($file, $d, $rc);

    our $NAME = $main::NAME;
    our $MAJOR_VERSION = $main::MAJOR_VERSION;
    our $MINOR_VERSION = $main::MINOR_VERSION;
    our $SUFFIX_VERSION = $main::SUFFIX_VERSION;
    our $VERSION = $main::VERSION;

    $file = 'Dewifile';

    $rc = do $file;
    if (!defined $rc && $EVAL_ERROR) {
        warn qq{Could not parse $file:\n  - Reason: $@\n};
        return 0;
    } elsif (!defined $rc) {
        if ($@ eq '') {
            warn qq{$file empty?\n};
        } else {
            warn qq{Could not read $file:\n  - Reason: $!\n};
        }
        return 0;
    } elsif ($rc != 1) {
        warn qq{Reading $file did not return 1.\n}
        ."  While this is not a fatal problem, it is good practice, to let\n"
        ."  perl script files return 1. Just put a '1;' into the last line\n"
        ."  of this file to get rid of this warning.\n";
    }

    return 1;
}

# place holder function for the bootstrapping functionality
sub dewifile_is_empty {
    print
"This Dewifile is empty. Is was probably created by dewi's bootstrap mode.\n".
"You will need to register the files you want dewi to deploy. This is\n".
"merely a placeholder.   Thanks for your attention.\n";
}

# a glorified '1;' for the end of Dewifiles
sub end {
    return 1;
}

###########################################################################
package main;

use strict;
use warnings qw(all);
use English '-no_match_vars';
use File::Spec;

our $NAME = 'dewi';
our $MAJOR_VERSION = 0;
our $MINOR_VERSION = 1;
our $SUFFIX_VERSION = 'pre';
our $VERSION = $MAJOR_VERSION . '.' . $MINOR_VERSION . $SUFFIX_VERSION;

my (%opts);
our (@regfiles);

# output
sub verbose {
    print @_ if (get_opt_bool('verbose') || get_opt_bool('debug'));
    return 1;
}

sub debug {
    print @_ if (get_opt_bool('debug'));
    return 1;
}

# option handling
sub defaults {
    set_opt('debug',   'no');
    set_opt('verbose', 'no');
}

sub get_opt {
    my ($key) = @_;
    return $opts{$key};
}

sub get_opt_bool {
    my ($key) = @_;
    my ($v);

    $v = get_opt($key);
    return 0 if (!defined $v || $v eq 'no' || $v eq 'no_thanks' || $v eq 'off'
        || $v eq 'false' || $v eq '1');
    return 1 if ($v eq 'yes' || $v eq 'yes_please' || $v eq 'on'
        || $v eq 'true' || $v eq '1');

    warn "Unknown value for boolean option \"$key\" ($v). Assuming false.\n";
    return 0;
}

sub set_opt {
    my ($key, $val) = @_;
    $opts{$key} = $val;
}

# help the user
sub help_header {
    print
"  +-------------------------------------------------+\n".
"  | dewi - deploy and withdraw configuration files  |\n".
"  +-------------------------------------------------+\n";
}

sub help_footer {
    print
"\n".
"Other targets may be available if a `local_dewi.mk' file exists.\n";
}

sub parent_help {
    help_header();
    print
"\n".
"Built-in make targets:\n".
"    deploy    - Deploy files from every subdirectory that has\n".
"                a working dewi setup.\n".
"    withdraw  - Withdraw files from every subdirectory with a\n".
"                working dewi setup.\n".
"    bs        - Bootstrap a subdirectory for dewi. Example:\n".
"                make bs d=thissubdirectory\n".
"    update    - Update the dewi-related Makefiles.\n".
"    all       - Display this help text.\n";
    help_footer();
}

sub child_help {
    help_header();
    print
"\n".
"Built-in make targets:\n".
"    deploy    - Deploy the files as configured in `Dewifile'.\n".
"    withdraw  - Remove the configured files from their deployment places.\n".
"    all       - Display this help text.\n";
    help_footer();
}

# aaaand ACTION.
sub merge_name {
    my ($dest, $file) = @_;
    return File::Spec->catfile($dest, $file);
}

sub method_copy {
    my ($from, $to) = @_;
}

sub method_force_copy {
    my ($from, $to) = @_;
}

sub method_hardlink {
    my ($from, $to) = @_;
}

sub method_symlink {
    my ($from, $to) = @_;
}

sub deploy_files {
}

sub withdraw_files {
}

# the main() routine
sub main {
    if ($#ARGV < 0) {
        die "usage: dewi.pl <mode> [options]\n";
    }
    my $mode = $ARGV[0];
    defaults();

    if ($mode eq 'deploy' || $mode eq 'withdraw') {
        DewiFile::read_dewifile() or return 1;
    }

    if ($mode eq 'deploy') {
        deploy_files();
    } elsif ($mode eq 'withdraw') {
        withdraw_files();
    } elsif ($mode eq 'parent_help') {
        parent_help();
    } elsif ($mode eq 'child_help') {
        child_help();
    } else {
        die "Unknown mode of operation: \"$mode\".\n";
    }

    return 0;
}
exit main();
