#!/usr/bin/perl
use strict;
no strict qw(vars);
use warnings FATAL => qw(precedence);
no warnings qw(once ambiguous);

# Copyright (c) 1996 Silicon Engineering Inc.
# Copyright (c) 2001 Tau Networks, Inc.
# Copyright (c) 2009 Beyond Circuits
# Permission is granted to modify and distribute this program
# provided that this copyright message remains unaltered.
#
# Author: Peter Johnson 3 July, 1996
# $Id: vpp.pl,v 1.7 2007/07/02 22:47:35 petjohns Exp $
#
# Revision History
#	PAJ	4 July, 1996	Initial release
#	PAJ	18 July, 2001	Added -perl option
#

# Usage:
# Parses the following Verilog command line syntax:
#	+define+var
#	+define+var1+var2+...+varN
#	+define+var1=val1+var2=val2+...+varN=valN
#	+incdir+dir
#	+incdir+dir1+dir2+...+dirN
#	-f <command-file>
# Other Verilog options are accepted but ignored.
# If Verilog files are omitted, reads standard input.

# If -perl is given, then the output is a perl program which when run
# will produce the Verilog code. This allosw for loops, functions, and
# all manney of mayhem.
#
# Comments starting with //@ and continuing to end of line are copied
# literally to the output to be evaluated by the perl interpreter.
# Comments inside a /*@ @*/ pair are treated similarly.
#

=head1 NAME

vpp.pl - Verilog Pre-Processor

=head1 SYNOPSIS

B<vpp.pl> [ B<+define+>I<var> ] [ B<+define+>I<var>B<+>I<var2>B<+>...B<+>I<varN> ]
    [ B<+define+>I<var>B<=>I<val1>B<+>I<var2>B<=>I<val2>B<+>...B<+>I<varN>B<=>I<valN> ]
    [ B<+incdir+>I<dir1> ] [ B<+incdir+>I<dir1>B<+>I<dir2>B<+>...B<+>I<dirN> ]
    [ B<-f> I<command_file> ]
    [ B<-output> I<file> ]
    [ B<-perl> [ B<--perlinc> I<dir> ]+ ]
    [ B<-deps> I<file> ]
    I<file>

See below for more descriptions of the switches.

=head1 DESCRIPTION

B<vpp.pl> is a Verilog pre-processor. Without the B<-perl> option, it
reads the source file and writes it to standard output with all ifdef
statements expanded out and all include files included. With the
B<-perl> option, specially marked lines are interpreted as perl code
(see below).

=head1 OPTIONS

=head2 B<+define>

The B<+define> option defines Verilog preprocessor variables. The syntax is the same as for Verilog.

=head2 B<+incdir>

Specifies directories to search for include files. The syntax is the same as for Verilog.

=head2 B<-f> I<file>

Read I<file> and treat the contents as arguments to I<vpp.pl>

=head2 B<-output> I<file>

Write the output of the preprocessor to I<file>. By default, output is
written to standard output.

=head2 B<-perl>

Interpret Perl code in the source file.

In this mode, the source text is converted into a Perl program. This
program is then run and the resulting output is written to the output
file. Text lines are double quoted Perl strings, so all Perl variable
interpolation applies.

Code within specially marked comments is passed directly into the
generated perl program. This allows embedder Perl code within the
vpp.pl source file. These comments are either a single line comment
marked with B<//@> or comments spanning multiple lines starting with
B</*@> and ending with B<@*/>.

For example, say you needed to instantiate a model but the model uses
bit blasted ports. You could use the following construct.

  //@ for my $i (0..7) {
    .D$i(data[$i]),
  //@ }

Notice the use of $i in the line which does not contain Perl code. The
variable is interpolated into the output string. You need to be
careful if you need a Perl variable expanded but it is in a context
that makes Perl think the variable is something else. For example,
suppose the above example was two dimensional and the input words were
data0 through data7. We would need nested for loops like this.

  //@ for my $i (0..7) {
    //@ for my $j (0..7) {
      .D$i$j(data$i [$j]),
    //@ }
  //@ }

Notice the space between the C<$i> and the C<[$j]>. This prevents Perl from
interpreting C<$i[$j]> as an array reference into the C<@i> array.

Also, sometimes you need to have a string directly follow a
variable. Suppose the data vector in the previous example was named
PI<n>data. You would use curly braces to let Perl know where the
variable ended. Like this...

  //@ for my $i (0..7) {
    //@ for my $j (0..7) {
      .D$i$j(P${i}data[$j]),
    //@ }
  //@ }

=head2 B<-perlinc> I<directory>

The B<-perlinc> option specifies a directors which should be added to
the Perl library search path when the generated Perl program is
run. This is useful for finding project specific libraries.

=head2 B<-deps> I<file>

Generate dependencies suitable for GNU Make in I<file>.

=head1 VARIABLES

B<vpp.pl> makes variables defined on the command line available to
Perl code embedded within the source text. This is done using an
associative array called C<%defines>.

=head1 SEE ALSO

Vpp.pm

=head1 AUTHOR

Pete Johnson <pete.johnson@cisco.com>

=cut

# Notes:
# This program requires perl 5 to run.
require 5;

use FindBin;
use lib "$FindBin::Bin";
use Vpp;
use Cwd qw(abs_path);
use File::Copy qw(move);
use File::Basename qw(basename dirname);

sub EmitContext {
  !$perl_mode ? "" :
    sprintf("\n# line %d %s\n",$line_number+1,$current_file) .
    sprintf("defined(\$::pragmas[0]{'lines'}) and \$::pragmas[0]{'lines'} and print qq\001`line %d \"%s\" 0\n\001;",$line_number+1,$current_file);
}

sub PushContext {
  push (@file_stack,$current_file);
  push (@line_stack,$line_number);
  $current_file = shift;
  $line_number = 0;
}

sub PopContext {
  $current_file = pop(@file_stack);
  $line_number = pop(@line_stack);
}

my @deps;
sub AddDependency {
  push(@deps,shift);
}

my $output_file = "-";
my $module_name = undef;
my $keep_includes = 0;
my $loose_includes = 0;
my $deps_file = undef;
my $perl_debug = undef;
my $perl_defines = 0;
my %perl_pragmas = ("lines" => 0, "strict" => 1);

@incdirs = (".");		# always include current directory
$" = " ";
$ARGS = "@ARGV";
$perl_mode = 0;
$line_number = 0;
$current_file = "";
@file_stack = ();
@line_stack = ();

@def_inc = ();

GetArgs(@ARGV);			# process our argiments

my $outstring = "";

if ($perl_mode) {		# emit defines from command line
  if ($perl_pragmas{"strict"} == 1) {
    $outstring .= "use warnings FATAL => qw(uninitialized);\n";
  }
  $outstring .= "BEGIN {\n";
  $outstring .= "  our \@pragmas;\n";
  for (keys %perl_pragmas) {
    $outstring .= qq{  \$pragmas[0]{"$_"} = qq\001$perl_pragmas{$_}\001;\n};
  }
  $outstring .= "  our %defines;\n";
  for (keys %defines) {
    $outstring .= qq{  \$defines{"$_"} = qq\001$defines{$_}\001;\n};
  }
  $outstring .= "}\n";

  $outstring .= "BEGIN {\n";
  for (@inc,@def_inc) {
    $outstring .= qq{  push(\@INC,"$_");\n};
  }
  $outstring .= "}\n";
}

$outstring .= EmitText("// DO NOT EDIT THIS FILE\n");
$outstring .= EmitText("/* File generated by:\n");
$outstring .= EmitText("\t$0 \\\\\n");
my $line = "";
for (split(/ /,$ARGS)) {
  if (($line ne "") and (length($line)+length($_) > 80)) {
    $outstring .= EmitText("\t$line \\\\\n");
    $line = $_;
  } else {
    $line .= " ".$_;
  }
}
if ($line ne "") {
  $outstring .= EmitText("\t$line\n");
}
$outstring .= EmitText("*/\n");
if ($#files >= 0) {
  for (@files) {
    push(@deps,$_);
    open(FILE,$_) || die ("$_: $!");
    PushContext($_);
    if (!$perl_mode) {
      $outstring .= EmitContext;
    }
    elsif ($_ =~ /\.pl$/) {
      close(FILE);
      open(FILE,"<",\"//@ require \"$_\";\n");
    }
    ScanText(*FILE,undef,0);
    PopContext;
    close(FILE);
  }
} else {
  ScanText(*STDIN,undef,0);
}

sub EmitText {
  my $text = shift;
  if ($perl_mode) {
    $text =~ s/\\n/\\\\n/g;
    $text =~ s/\$$/\\\$/;
    return "print qq\001".$text."\001;";
  } else {
    return $text;
  }
}

sub ScanText {
  my $file = shift;		# filehandle to read from
  my $scanTo = shift;		# stop when input matches this (never if undefined)
  my $ignore = shift;		# true if we should ignore what we see
  my $firstPlainEmit = $perl_mode;

  while (<$file>) {
    s/\r//;
    s/[ 	]*$//;
    $line_number++;
    return $_ if (defined $scanTo && /$scanTo/);
    if (/^\s*`ifdef\s+([a-zA-z_][A-Za-z0-9_]*)/) { # `) {
      my $defined = (defined $defines{$1});
      $_ = ScanText($file,"^\\s*`(endif|else)\\b",$ignore || !$defined);
      next unless (/^\s*`else\b/); # `/);
      ScanText($file,"^\\s*`endif\\b",$ignore || $defined);
      next;
    }
    if ($perl_mode && /^=/) {
      while (<$file>) { last if (/^=cut/); }
      next;
    }
    next if $ignore;
    if (m{^\s*`define\s+([a-zA-z_][A-Za-z0-9_]*|\\\S*)(\s*(.*))(//.*)?}) { # `) {
      my $token = $1;
      my $value = $3;
      if (defined $value && $value !~ /^\s*$/) {
        while ($value =~ /\\\s*$/) {
          chomp(substr($value, -1) = <$file>);
        }
        $defines{$token} = $value;
        $outstring .= qq{\$defines{\"$token\"} = qq{$value};} if ($perl_mode);
      } else {
        $defines{$token} = 1;
        $outstring .= qq{\$defines{\"$token\"} = 1;} if ($perl_mode);
      }
      $outstring .= EmitText($_);
      next;
    }
    if (/^\s*`include\s*("?)(\S*)\1/) { # `) {
      my $quoted = $1;
      my $dir;
      my $file = $2;
      my $rest;
      # if no quotes were used in the include, then eval the argument
      # this allows using a +define to specify an include file.
      # Note that perl code within the .vs file cannot specify the include
      # because that code is not evaluated at this point.
      if ($quoted eq "") { $file = eval $file; }
      local *INCLUDE;
      if ($file =~ /^\// && -e $file) {
        $dir = "";
        substr($file, 0, 1) = "";
        $rest = $file;
      }
      else {
        $rest = $file;
        ($dir) = grep {-e "$_/${file}"} @incdirs;
        if (!defined $dir && $file =~ /\.[^.]*vh$/) {
          if ($perl_mode) {
            ($dir) = grep {-e "$_/${file}p"} @incdirs;
          }
          if (defined $dir) {
            $file .= "p";
          }
          elsif ($loose_includes) {
            my ($base) = $file =~ /^(.+?)(?:\.[^.]*)?$/;
            my $pattern;
            if ($file !~ /^\//) {
              $pattern = "{" . join(",", @incdirs) . "}/$base.*";
            }
            else {
              $pattern = "$base.*";
              $rest = basename($file)
            }
            my @files = glob($pattern);
            if (@files) {
              $dir = dirname($files[0]);
            }
          }
        }
      }
      defined $dir || die "$0: \"${file}\": could not find included file.\n";
      $outstring .= EmitText("// begin (" . ($#{file_stack}+1) .  ") include of " . abs_path("$dir/${rest}") . "\n");
      push(@deps,abs_path("$dir/${file}"));
      PushContext("$dir/${file}");
      if (!$loose_includes || -e "$dir/${file}") {
        open(INCLUDE,"$dir/${file}") || die "$0: ${file}: $!\n";
        $outstring .= EmitContext;
        ScanText(*INCLUDE,undef,0);
        close(INCLUDE);
      }
      $outstring .= EmitText("// end (" . $#{file_stack} . ") include of " . abs_path("$dir/${rest}") . "\n");
      PopContext;
      $outstring .= EmitContext;
      next;
    }
  again:
    if ($perl_mode && /^(.*)\/\/@(.*)/) {
      my $leadin = $1;
      my $special = $2;
      if ($leadin !~ /^\s*$/) {
        $outstring .= EmitText($leadin);
      }
      if ($special =~ /^\s*pragma\s+(\S+)(?:\s+(.+?))?\s*$/) {
        if ($1 eq "push") {
          $outstring .= "unshift(\@pragmas, \\%{{%{\$pragmas[0]}}});\n";
        }
        elsif ($1 eq "pop") {
          $outstring .= "shift(\@pragmas);\n";
        }
        else {
          $outstring .= "\$pragmas[0]{'$1'} = $2;\n";
        }
      }
      else {
        $outstring .= $special;
        $outstring .= EmitContext;
      }
    } elsif ($perl_mode && /^(.*?)\/\*@(.*?)@\*\/(.*)/) {
      $outstring .= EmitText($1);
      $outstring .= $2;
      $_ = $3."\n";
      $outstring .= EmitContext;
      goto again;
    } elsif ($perl_mode && /^(.*?)\/\*@(.*)/s) {
      $outstring .= EmitText($1);
      $outstring .= $2;
      while (1) {
        $_ = <$file>;
        $line_number++;
        if (/(.*?)@\*\/(.*)/) {
          $outstring .= $1;
          $_ = $2;
          $outstring .= EmitContext;
          goto again;
        } else {
          $outstring .= $_;
        }
      }
    } else {
      if ($firstPlainEmit) {
        $firstPlainEmit = 0;
        $line_number--;
        $outstring .= EmitContext;
        $line_number++;
      }
      $outstring .= EmitText($_);
    }
  }
}

if ($perl_mode) {
  if (defined $perl_debug) {
    my $dbfile;
    if (!open ($dbfile,">$perl_debug")) {
      warn "$perl_debug: $!\n";
    } else {
      print $dbfile $outstring;
    }
  }

  open BUFFER, ">", \$buffer;

  *CORE::GLOBAL::require = sub {
    my $expr = $_[0];
    if ($expr =~ /^(?!\/).*\.pl$/) {
      my $found;
      foreach my $prefix (@INC) {
        if (-f "$prefix/$expr") {
          $expr = "$prefix/$expr";
          $dir = dirname($expr);
          if (!grep {abs_path($_) eq abs_path($dir)} @INC) {
            push(@INC, $dir);
          }
          $found = 1;
          last;
        }
      }
      if (!$found && $loose_includes) {
        my ($base) = $expr =~ /^(.+?)(?:\.[^.]*)?$/;
        my $pattern = "{" . join(",", @incdirs) . "}/$base.*";
        my @files = glob($pattern);
        if (@files) {
          $INC{$expr} = dirname($files[0]) . "/" . $expr;
        }
      }
    }
    if (CORE::require($expr)) {
      print("// begin require of " . abs_path($INC{$expr}) . "\n");
      print("// end require of " . abs_path($INC{$expr}) . "\n");
      push(@deps, abs_path($INC{$expr}));
    }
  };

  %existing_scalars = ();
  foreach my $name (grep {ref(\${main::{$_}}) eq 'GLOB'} keys %main::) {
    if (defined ${*{$main::{$name}}{SCALAR}}) {
      $existing_scalars{$name} = 1;
    }
  }

  select BUFFER;
  @saved_INC = @INC;
  push(@INC,@incdirs);

  if (!defined eval $outstring) {
    die "$@\n";
  }

  @INC = @saved_INC;
  select STDOUT;

  $outstring = $buffer;

  if ($perl_defines) {
    my $guard_name = "_" . basename($output_file) . "_";
    $guard_name =~ s/[^A-Za-z0-9]/_/g;
    $guard_name = uc($guard_name);
    $outstring .= "`ifndef $guard_name\n";
    $outstring .= "`define $guard_name\n";
    foreach my $name (grep {ref(\${main::{$_}}) eq 'GLOB'} sort keys %main::) {
      if (defined ${*{$main::{$name}}{SCALAR}}) {
        if (not exists $existing_scalars{$name} and $name =~ /^[A-Za-z][0-9A-Za-z]*_/) {
            $outstring .= "`ifndef " . uc($name) . "\n";
            $outstring .= "`define " . uc($name) . " " . ${*{$main::{$name}}{SCALAR}} . "\n";
            $outstring .= "`endif\n";
        }
      }
    }
    $outstring .= "`endif // $guard_name\n";
  }
}

if (defined $module_name) {
  $outstring =~ s/^(\s*module\s+)[A-Za-z_][A-Za-z0-9_]*/$1$module_name/m;
}

if ($keep_includes) {
  $outstring =~ s/^(\/\/ begin (\(\d+\)) include of ([^\n]+)(?<!\.vhp)\n).*?^(\/\/ end \2 include of \3)/$1`include "$3"\n$4/msg;
}

if ($output_file eq "-") {
  print $outstring;
} else {
  my $tmp_file = "/tmp/vpp." . (getpwuid($<) || $<) . time . ".$$";
  open FILE, ">$tmp_file" or die "$tmp_file: $!\n";
  print FILE $outstring;
  close FILE;
  move $tmp_file, $output_file;
  utime undef, undef, $output_file;
}

if (defined $deps_file) {
    open DEPS,">$deps_file" or die "$deps_file: $!\n";
    local $, = " ";
    print DEPS "$output_file: @deps\n";
    close DEPS;
}

# GetArgs -- read command line arguments.
# files go into @files, include dirs into @incdirs,
# and defines into %defines.
# No check on recursive -f, so watch out!
sub GetArgs {
  while ($_ = shift) {
    if (/^\+define\+(.*)/) {
      for (split(/\+/,$1)) {
        /([^=]*)(=(.*?)\s*$)?/;
        $defines{$1} = defined $3 ? $3 : "";
      }
    } elsif (/^\+incdir\+(.*)/) {
      push(@incdirs,split(/\+/,$1));
    } elsif (/^[^+-]/) {
      push(@files,$_);
    } elsif (/^-f$/) {		# get options from file
      local *ARGS;
      open(ARGS,$_=shift) || die "$0: $_: $!\n";
      @args = <ARGS>;
      GetArgs(split(/\s+/,"@args"));
      close(ARGS);
    } elsif (/^-[iklrvy]$/) {	# Verilog options with args
      shift;			# ignore the argument
    } elsif (/^-output/) {
      $output_file = shift;
    } elsif (/^-module/) {
      $module_name = shift;
    } elsif (/^-deps/) {
      $deps_file = shift;
    } elsif (/^-keepincludes/) {
      $keep_includes = 1;
    } elsif (/^-looseincludes/) {
      $loose_includes = 1;
      $perl_pragmas{"strict"} = 0;
    } elsif (/^-perl/) {
      $perl_mode = 1;
    } elsif (/^--perlinc/) {
      push(@inc, shift);
    } elsif (/^--perldebug/) {
      $perl_debug = shift;
    } elsif (/^--perlvar/) {
      shift =~ /([^=]*)(=(.*?)\s*$)?/;
      eval("tie(\${$1}, 'PerlVar', defined \$3 ? \$3 : 1)");
    } elsif (/^--perlpragma/) {
      shift =~ /([^=]*)(=(.*?)\s*$)?/;
      $perl_pragmas{$1} = defined $3 ? int($3) : 1;
    } elsif (/^--perldefines/) {
      $perl_defines = 1;
    }
  }
}



package PerlVar;

sub TIESCALAR {
    my $class = shift(@_);
    my $value = shift(@_);
    if (!defined($value)) {
      $value = 1;
    }
    return bless({"value" => $value}, $class);
}

sub FETCH {
    my $self = shift(@_);
    return $self->{"value"};
}

sub STORE {
}
