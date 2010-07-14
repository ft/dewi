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
    # This sets default values for the different meaningful keys and
    # also does some error-checking on values where it makes sense.
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
    if (!main::method_exists($h->{method})) {
        die
        "register(): Unknown `method' parameter: \"" . $h->{method} . "\"\n".
        "                        Call number $reg_calls.\n";
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
use Cwd;
use File::Copy;
use File::Spec;

our $NAME = 'dewi';
our $MAJOR_VERSION = 0;
our $MINOR_VERSION = 1;
our $SUFFIX_VERSION = 'pre';
our $VERSION = $MAJOR_VERSION . '.' . $MINOR_VERSION . $SUFFIX_VERSION;

my (%opts);
our (@regfiles);

my %methods = (
    copy       => \&method_copy,
    force_copy => \&method_force_copy,
    hardlink   => \&method_hardlink,
    symlink    => \&method_symlink
);
sub method_exists {
    my ($method) = @_;

    if (defined $methods{$method}) {
        return 1;
    }
    return 0;
}

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
    set_opt('dryrun',  'no');
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

# utilities
sub xcopy {
    my ($src, $dst) = @_;

    if (get_opt_bool('dryrun')) {
        return 1;
    }
    copy($src, $dst) or die "copy() failed: $!\n";
    return 1;
}

sub xhardlink {
    my ($src, $dst) = @_;

    if (get_opt_bool('dryrun')) {
        return 1;
    }

    link $dst, $src or die "Could not create hardlink: $!\n";
}

sub xsymlink {
    my ($src, $dst) = @_;

    if (get_opt_bool('dryrun')) {
        return 1;
    }

    symlink $dst, $src or die "Could not create symlink: $!\n";
}

sub stat_names {
    my ($num) = @_;
    my @names = qw{ dev ino mode nlink uid gid rdev size
                    atime mtime ctime blksize blocks };

    return $names[$num];
}
sub xstat {
    my ($file) = @_;
    my ($i, %stat, @data);

    @data = stat($file);
    $i = 0;
    %stat = map { stat_names($i++) => $_ } @data;
    if (-e _) {
        $stat{exist} = 1;
    } else {
        $stat{exist} = 0;
    }

    $stat{plainfile} = 0;
    $stat{dir} = 0;
    if (-f _) {
        $stat{plainfile} = 1;
    } elsif (-d _) {
        $stat{dir} = 1;
    }
    return \%stat;
}

# aaaand ACTION.
sub merge_name {
    my ($dest, $file) = @_;
    return File::Spec->catfile($dest, $file);
}

sub method_copy {
    my ($src, $dst) = @_;
    my ($dstat, $sstat);

    $sstat = xstat($src);
    $dstat = xstat($dst);
    if (($dstat->{exist} == 1) && ($sstat->{ino} == $dstat->{ino})) {
        die "  _copy(): $src and $dst are the same file. Please resolve!\n";
    }
    if (($dstat->{exist} == 1) && ($sstat->{mtime} <= $dstat->{mtime})) {
        verbose("  _copy(): $dst (not newer than source, skipping)\n");
        debug("   source: $src\n");
        return 1;
    }
    verbose("  _copy(): $dst\n");
    debug("   source: $src\n");
    xcopy($src, $dst);
}

sub method_force_copy {
    my ($src, $dst) = @_;
    my ($dstat, $sstat);

    $sstat = xstat($src);
    $dstat = xstat($dst);
    if (($dstat->{exist} == 1) && ($sstat->{ino} == $dstat->{ino})) {
        die
        "  _force_copy(): $src and $dst are the same file. Please resolve!\n";
    }
    verbose("  _force_copy(): $dst\n");
    debug("         source: $src\n");
    xcopy($src, $dst);
}

sub method_hardlink {
    my ($src, $dst) = @_;
    my ($dstat, $sstat);

    $sstat = xstat($src);
    $dstat = xstat($dst);
    if (($dstat->{exist} == 1) && ($sstat->{ino} == $dstat->{ino})) {
        verbose("  _hardlink(): $dst (hardlinked to source, skipping)\n");
        debug("       source: $src\n");
        return 1;
    }
    verbose("  _hardlink(): $dst\n");
    debug("       source: $src\n");
    xhardlink($src, $dst);
}

sub method_symlink {
    my ($src, $dst) = @_;
    my ($not_a_symlink);

    if (-l $dst) {
        $not_a_symlink = 0;
        my ($sstat, $tstat, $t);
        $t = readlink $dst or die "  _symlink(): readlink() failed: $!\n";
        $tstat = xstat($t);
        $sstat = xstat($src);
        if (($tstat->{exist} == 1) && ($tstat->{ino} == $sstat->{ino})) {
            verbose("  _symlink(): $dst (symlinked to source, skipping)\n");
            debug("      source: $src\n");
            return 1;
        }
    } else {
        $not_a_symlink = 1;
    }

    if ($not_a_symlink && -e $dst) {
        die
        "  _symlink(): destination $dst exists but is not a symlink.\n" .
        "              Please resolve!\n";
    }
    verbose("  _symlink(): $dst\n");
    debug("      source: $src\n");
    xsymlink($src, $dst);
}

sub deploy_files {
    my ($base) = @_;

    print "Deploying $base...\n";
    foreach my $f (@regfiles) {
        $methods{$f->{method}}->(
            $f->{path},
            $f->{mergedname})
    }
}

sub withdraw_files {
    my ($base) = @_;
}

# the main() routine
sub main {
    if ($#ARGV < 0) {
        die "usage: dewi.pl <mode> [options]\n";
    }
    my $mode = $ARGV[0];
    my $cwd = Cwd::cwd();
    my @dirs = File::Spec->splitdir($cwd);
    my $base = $dirs[-1];
    defaults();

    if ($mode eq 'deploy' || $mode eq 'withdraw') {
        DewiFile::read_dewifile() or return 1;
    }

    if (get_opt_bool('dryrun')) {
        print "dewi: --- This is a dry run ---\n";
    }

    if ($mode eq 'deploy') {
        deploy_files($base);
    } elsif ($mode eq 'withdraw') {
        withdraw_files($base);
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
