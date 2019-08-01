# Copyright (c) 1996 Silicon Engineering Inc.
# Copyright (c) 2001 Tau Networks, Inc.
# Permission is granted to modify and distribute this program
# provided that this copyright message remains unaltered.
#
# Author: Peter Johnson 3 July, 1996 
# $Id: Vpp.pm,v 1.5 2006/04/28 18:56:54 petjohns Exp $
#
# Revision History
#	PAJ	4 July, 1996	Initial release
#	PAJ	18 July, 2001	Added -perl option
#
# Useful VPP Perl routines.
#
# Verilog system tasks and variables look like variable references to
# perl.  Here we define a number of Verilog tasks so that nobody gets
# surprised.

=head1 NAME

Vpp - Verilog Pre-Processor library

=head1 SYNOPSIS

//@ use Vpp;

=head1 DESCRIPTION

=head2 Variables

B<Vpp> is a library meant for use with the B<vpp.pl> preprocessor. The
library defines useful routines for use with B<vpp.pl> and also
defines some variable corresponding to Verilog predefined tasks so
that calls to the tasks do not need to be escaped. For example, since
C<$display> looks like a variable reference to the preprocessor,
B<Vpp> defines a variable called display whose value is
B<$display>. Thus you can say C<$display> in your code and that will
appear in the output text.

In addition, B<vpp.pl> will expand C<`ifdef> statements. This is often
not desired, so B<Vpp> defines B<$ifdef>, B<$else>, and B<$endif>
variables. The value of these variables is B<`ifdef>, B<`else>, and
B<`endif> respectively. These variables may be used to quote the
B<ifdef> constructs and prevent expansion by B<vpp.pl>.

=head2 Functions

=over

=item B<log2>(I<val>)

Returns the cieling of the log base 2 of I<val>.

Here is an example:

 //@ my $width = 20;
 //@ my $log_width = Vpp::log2($width);
 parameter width = $width;
 parameter log_width = $log_width;

=back

=cut

package Vpp;

use POSIX;

$::Date = '$Date';
$::Id = '$Id';
$::Log = '$Log';

$::async = '$async';
$::and = '$and';
$::array = '$array';
$::bitstoreal = '$bitstoreal';
$::countdrivers = '$countdrivers';
$::disable_warnings = '$disable_warnings';
$::display = '$display';
$::dist_exponential = '$dist_exponential';
$::dist_normal = '$dist_normal';
$::dist_poisson = '$dist_poisson';
$::dist_uniform = '$dist_uniform';
$::dumpall = '$dumpall';
$::dumpchange = '$dumpchange';
$::dumpfile = '$dumpfile';
$::dumpflush = '$dumpflush';
$::dumplimit = '$dumplimit';
$::dumpoff = '$dumpoff';
$::dumpon = '$dumpon';
$::dumpports = '$dumpports';
$::dumpportsall = '$dumpportsall';
$::dumpportsflush = '$dumpportsflush';
$::dumpportslimit = '$dumpportslimit';
$::dumpportsoff = '$dumpportsoff';
$::dumpportson = '$dumpportson';
$::dumpvars = '$dumpvars';
$::enable_warnings = '$enable_warnings';
$::fclose = '$fclose';
$::fdisplay = '$fdisplay';
$::fflush = '$fflush';
$::fflushall = '$fflushall';
$::finish = '$finish';
$::stop = '$stop';
$::fmonitor = '$fmonitor';
$::fopen = '$fopen';
$::fstobe = '$fstobe';
$::fwrite = '$fwrite';
$::getpattern = '$getpattern';
$::gr_waves = '$gr_waves';
$::hold = '$hold';
$::Id = '$Id';
$::itor = '$itor';
$::log = '$log';
$::lsi_dumpports = '$lsi_dumpports';
$::monitor = '$monitor';
$::monitoroff = '$monitoroff';
$::monitoron = '$monitoron';
$::nolog = '$nolog';
$::period = '$period';
$::q_add = '$q_add';
$::q_exam = '$q_exam';
$::q_full = '$q_full';
$::q_initialize = '$q_initialize';
$::q_remove = '$q_remove';
$::random = '$random';
$::readmemb = '$readmemb';
$::readmemh = '$readmemh';
$::realtime = '$realtime';
$::realtobits = '$realtobits';
$::recovery = '$recovery';
$::recrem = '$recrem';
$::reset = '$reset';
$::reset_count = '$reset_count';
$::reset_value = '$reset_value';
$::rtoi = '$rtoi';
$::save = '$save';
$::sdf_annotate = '$sdf_annotate';
$::setup = '$setup';
$::setuphold = '$setuphold';
$::sformat = '$sformat';
$::skew = '$skew';
$::sreadmemb = '$sreadmemb';
$::sreadmemh = '$sreadmemh';
$::stime = '$stime';
$::stop = '$stop';
$::strobe = '$strobe';
$::sync = '$sync';
$::nor = '$nor';
$::plane = '$plane';
$::system = '$system';
$::test = '$test';
$::plusargs = '$plusargs';
$::time = '$time';
$::timeformat = '$timeformat';
$::vcdplusautoflushoff = '$vcdplusautoflushoff';
$::vcdplusautoflushon = '$vcdplusautoflushon';
$::vcdplusclose = '$vcdplusclose';
$::vcdplusdeltacycleoff = '$vcdplusdeltacycleoff';
$::vcdplusdeltacycleon = '$vcdplusdeltacycleon';
$::vcdplusevent = '$vcdplusevent';
$::vcdplusfile = '$vcdplusfile';
$::vcdplusflush = '$vcdplusflush';
$::vcdplusglitchoff = '$vcdplusglitchoff';
$::vcdplusglitchon = '$vcdplusglitchon';
$::vcdplusmemorydump = '$vcdplusmemorydump';
$::vcdplusoff = '$vcdplusoff';
$::vcdpluson = '$vcdpluson';
$::vcdplustraceoff = '$vcdplustraceoff';
$::vcdplustraceon = '$vcdplustraceon';
$::width = '$width';
$::write = '$write';
$::writememb = '$writememb';
$::writememh = '$writememh';

$::ifdef = '`ifdef';
$::ifndef = '`ifndef';
$::else = '`else';
$::endif = '`endif';
$::include = '`include';

$::Date = '$Date';
$::Id = '$Id';
$::Log = '$Log';

$::ln = '$ln';
$::log10 = '$log10';
$::exp = '$exp';
$::sqrt = '$sqrt';
$::pow = '$pow';
$::floor = '$floor';
$::ceil = '$ceil';
$::sin = '$sin';
$::cos = '$cos';
$::tan = '$tan';
$::asin = '$asin';
$::acos = '$acos';
$::atan = '$atan';
$::atan2 = '$atan2';
$::hypot = '$hypot';
$::sinh = '$sinh';
$::cosh = '$cosh';
$::tanh = '$tanh';
$::asinh = '$asinh';
$::acosh = '$acosh';
$::atanh = '$atanh';


# this gives ceiling of log base 2 (returns -1 for zero)
sub log2 {
  my $val = shift;
  my $log;
  if (($val & ($val-1)) != 0) { $val <<= 1; }
  for ($log = 0; $val != 0; $val >>= 1, $log++){}
  $log-1;
}

sub count_to {
  my $val = shift;
  $val++;
  my $log;
  if (($val & ($val-1)) != 0) { $val <<= 1; }
  for ($log = 0; $val != 0; $val >>= 1, $log++){}
  $log-1;
}

sub priority_encoder {
  my $input = shift;
  my $output = shift;
  my $valid = shift;
  my $width = shift;
  my $prefix = shift;

  my $t;
  $t = POSIX::floor(($width+1)/2);

  print "// BEGIN GENERATED PRIORITY ENCODER\n";
  print qq{// priority_encoder("$input", "$output", "$valid", $width, "$prefix");\n};

  printf("  reg [%d:0] ${prefix}valid_1;\n",$t-1);
  printf("  reg [%d:0] ${prefix}stage_1;\n",$t-1);

  print "  always @($input) begin\n";
  for ($j=0; $j<$t; $j++) {
    printf("    ${prefix}stage_1[%d] = !%s[%d];\n",$j,$input,2*$j);
    if ($j+1 == $t && ($width%2==1)) {
      printf("    ${prefix}valid_1[%d] = %s[%d];\n",
	     $j,$input,2*$j,$input);
    }
    else {
      printf("    ${prefix}valid_1[%d] = %s[%d] | %s[%d];\n",
	     $j,$input,2*$j,$input,2*$j+1);
    }
  }
  print "  end\n\n";

  for ($i=2;$i<=log2($width);$i++) {
    my $odd_stage = $t%2 == 1;
    my $limit = POSIX::floor($t/2);
    $t = POSIX::floor(($t+1)/2);
    $im1 = $i-1;
    printf("  reg [%d:0] ${prefix}valid_$i;\n",$t-1);
    printf("  reg [%d:0] ${prefix}stage_$i;\n\n",$t*$i-1);
    printf("  always @(${prefix}valid_%d or ${prefix}stage_%d) begin\n",$i-1,$i-1);
    for ($j=0; $j<$limit; $j++) {
      printf("    ${prefix}stage_${i}[%d:%d] = {!${prefix}valid_${im1}[%d],".
	     "(${prefix}valid_${im1}[%d] ? ${prefix}stage_${im1}[%d:%d]".
	     " : ${prefix}stage_${im1}[%d:%d])};\n",
	     $i*($j+1)-1,$i*$j,2*$j,2*$j,
	     (2*$j+1)*$im1-1,2*$j*$im1,
	     2*($j+1)*$im1-1,(2*$j+1)*$im1);
      printf("    ${prefix}valid_${i}[%d] = ${prefix}valid_${im1}[%d] | ${prefix}valid_${im1}[%d];\n",$j,2*$j,2*$j+1);
    }
    if ($odd_stage) {
      printf("    ${prefix}stage_${i}[%d:%d] = {!${prefix}valid_${im1}[%d],".
	     "${prefix}stage_${im1}[%d:%d]};\n",
	     $i*($j+1)-1,$i*$j,
	     2*$j,
	     (2*$j+1)*$im1-1,2*$j*$im1);
      printf("    ${prefix}valid_${i}[%d] = ${prefix}valid_${im1}[%d];\n",
	     $j,2*$j);
    }
    printf("  end\n\n");
  }

  $im1 = $i-1;
  print "  always @(${prefix}stage_$im1) $output = ${prefix}stage_$im1;\n";
  print "  always @(${prefix}valid_$im1) $valid = ${prefix}valid_$im1;\n\n";
  print "// END GENERATED PRIORITY ENCODER\n\n";
}

sub priority_encoder2 {
  my $input = shift;
  my $output = shift;
  my $valid = shift;
  my $width = shift;
  my $prefix = shift;

  my $t;
  $t = POSIX::floor(($width+1)/2);

  print "// BEGIN GENERATED PRIORITY ENCODER\n";
  print qq{// priority_encoder("$input", "$output", "$valid", $width, "$prefix");\n};

  printf("  reg [%d:0] ${prefix}valid_1;\n",$t-1);
  printf("  reg [%d:0] ${prefix}stage_1;\n",$t-1);

  print "  always @($input) begin\n";
  for ($j=0; $j<$t; $j++) {
    printf("    ${prefix}stage_1[%d] = !%s[%d];\n",$j,$input,2*$j);
    if ($j+1 == $t && ($width%2==1)) {
      printf("    ${prefix}valid_1[%d] = %s[%d];\n",
	     $j,$input,2*$j,$input);
    }
    else {
      printf("    ${prefix}valid_1[%d] = %s[%d] | %s[%d];\n",
	     $j,$input,2*$j,$input,2*$j+1);
    }
  }
  print "  end\n\n";

  for ($i=2;$i<=log2($width);$i++) {
    my $odd_stage = $t%2 == 1;
    my $limit = POSIX::floor($t/2);
    $t = POSIX::floor(($t+1)/2);
    $im1 = $i-1;
    printf("  reg [%d:0] ${prefix}valid_$i;\n",$t-1);
    printf("  reg [%d:0] ${prefix}stage_$i;\n\n",$t*$i-1);
    printf("  always @(${prefix}valid_%d or ${prefix}stage_%d) begin\n",$i-1,$i-1);
    for ($j=0; $j<$limit; $j++) {
      printf("    ${prefix}stage_${i}[%d] = !${prefix}valid_${im1}[%d];\n",
	     $i*($j+1)-1,2*$j);
      my $k;
      for ($k=1; $k<$i; $k++) {
	printf("    ${prefix}stage_${i}[%d] = ${prefix}valid_${im1}[%d] ? ${prefix}stage_${im1}[%d] : ${prefix}stage_${im1}[%d];\n",
	       $i*($j+1)-1-$k,2*$j,(2*$j+1)*$im1-$k,2*($j+1)*$im1-$k);
      }
      printf("    ${prefix}valid_${i}[%d] = ${prefix}valid_${im1}[%d] | ${prefix}valid_${im1}[%d];\n",$j,2*$j,2*$j+1);

    }
    if ($odd_stage) {
      printf("    ${prefix}stage_${i}[%d] = !${prefix}valid_${im1}[%d];\n",
	     $i*($j+1)-1,2*$j);
      my $k;
      for ($k=1; $k<$i; $k++) {
	printf("    ${prefix}stage_${i}[%d] = ${prefix}stage_${im1}[%d];\n",
	       $i*($j+1)-$k-1,(2*$j+1)*$im1-$k);
      }
      printf("    ${prefix}valid_${i}[%d] = ${prefix}valid_${im1}[%d];\n",
	     $j,2*$j);
    }
    printf("  end\n\n");
  }

  $im1 = $i-1;
  print "  always @(${prefix}stage_$im1) $output = ${prefix}stage_$im1;\n";
  print "  always @(${prefix}valid_$im1) $valid = ${prefix}valid_$im1;\n\n";
  print "// END GENERATED PRIORITY ENCODER\n\n";
}

sub priority_selector {
  my $lowprio = shift;
  my $input = shift;
  my $output = shift;
  my $valid = shift;
  my $width = shift;
  my $prefix = shift;
  my $i;

  printf("wire [%d:0] %svector;\n",2*$width-1,$prefix);
  printf("wire [%d:0] %smask;\n",$width-1,$prefix);
  for ($i=0; $i<$width; $i++) {
    printf("assign %smask[%d] = (%d > %s);\n",$prefix,$i,$i,$lowprio);
    printf("assign %svector[%d] = %s[%d] && %smask[%d];\n",
	   $prefix,$i,$input,$i,$prefix,$i);
    printf("assign %svector[%d] = %s[%d] && ~%smask[%d];\n",
	   $prefix,$i+$width,$input,$i,$prefix,$i);
  }

  printf("reg [%d:0] ${prefix}wide_encoded;\n",log2($width));

  priority_encoder("${prefix}vector", "${prefix}wide_encoded",
		  $valid,2*$width,$prefix);
  print qq{
always @(${prefix}wide_encoded) 
  $output = (${prefix}wide_encoded >= $width) ?
    ${prefix}wide_encoded - $width : 
    ${prefix}wide_encoded;
  }
}

sub one_hot_encoder {
  my $input = shift;
  my $output = shift;
  my $width = shift;

  print "// BEGIN GENERATED ONE HOT ENCODER\n";
  print qq{// one_hot_encoder("$input", "$output", $width);\n};

  print "  always @($input) begin\n";
  for ($i=0;$i<log2($width);$i++) {
    $mask = sprintf("%d'b%s",$width,
		    substr(scalar(("1" x (1<<$i)).("0" x (1<<$i))) x
			   ((1<<(log2($width)))>>($i+1)),-$width,$width));
    printf("    %s[%d] = |(${input} & ${mask});\n", $output, $i);
  }
  print "  end\n\n";

  print "// END GENERATED ONE HOT ENCODER\n\n";
}

sub lfsr {
  my $reg = shift;
  my $width = shift;
  my $polynomial = shift;
  my $enable = shift;

  print qq{  always @(posedge clk or negedge resetN)\n};
  print qq{  if ($enable)\n} if defined $enable;
  printf "%s <= {%s[%d:0],1'b0}^({{%d}%s[%d]}&%s);\n",$reg,$reg,$width-2,$width,$reg,$width-1,$polynomial
}

sub sizeof {
  my $type = shift;

  return 1 if $type eq "";
  return 1 if $type =~ m/^[^:]*$/;
  $type =~ m/\[?(.*):([^]]*)\]?/;
  my $left = eval $1;
  my $right = eval $2;
  if ($left > $right) {
    return $left - $right + 1;
  } else {
    return $right - $left + 1;
  }
}

sub arrayof {
  my $type = shift;
  my $count = shift;
  my $size = sizeof($type);
  $size *= $count;
  sprintf ("[%d:0]",$size-1);
}

sub idx {
  my $type = shift;
  my $idx = shift;
  my $type_size = sizeof($type);
  sprintf ("%d:%d",($idx+1)*$type_size-1,$idx*$type_size);
}

sub each_bit {
  my $type = shift;
  $type =~ m/\[(.*):(.*)\]/;
  my $left = eval $1;
  my $right = eval $2;
  my ($upper, $lower);
  if ($left < $right) {
    $lower = $left; $upper = $right;
  } else {
    $lower = $right; $upper = $left;
  }
  return ($lower..$upper);
}

sub type_mask {
  my $type = shift;
  $type =~ m/\[(.*):(.*)\]/;
  my $left = eval $1;
  my $right = eval $2;
  my ($upper, $lower);
  if ($left < $right) {
    $lower = $left; $upper = $right;
  } else {
    $lower = $right; $upper = $left;
  }
  return ((1<<($upper-$lower))-1)<<$lower;
}

# Commonly used Verilog code
$declare{"log2"} = "
   function integer log2;
      input [31:0] value;
      integer result;
      begin
	 value = value-1;
	 for (result=0; value>0; result=result+1)
	   value = value>>1;
	 log2 = result;
      end
   endfunction
";

sub to_decimal {
  my $val = shift;
  return undef unless defined $val;
  $val =~ s/(\d)_(\d)/$1$2/g;
  $val =~ s/(\d*)\'b([01]+)/oct("0b$2")/ge;
  $val =~ s/(\d*)\'o([0-7]+)/oct("0$2")/ge;
  $val =~ s/(\d*)\'d([0-9]+)/$2/g;
  $val =~ s/(\d*)\'h([0-9A-Fa-f]+)/oct("0x$2")/ge;

  $val =~ s,\bdiv\b,/,g;
  $val =~ s,\bmod\b,%,g;

  $val = eval $val;
  return "" unless defined $val;
  return $val;
}

sub to_verilog {
  my $val = shift;
  return undef unless defined $val;
  if ($val =~ /^0x(.*)/) {
    return "'h$1";
  } elsif ($val =~ /0(.+)/) {
    return oct("'o$1");
  } else {
    return "'d$val";
  }
}

sub pad_right {
    my $var = shift;
    my $type = shift;
    my $width = shift;
    if (sizeof($type) > $width) {
	sprintf("%s[%d:%d]",$var,sizeof($type)-1,sizeof($type)-$width);
    } elsif (sizeof($type) < $width) {
	sprintf("{%s,%d'h0}",$var,$width-sizeof($type));
    } else {
	$var;
    }
}

sub real_to_int {
    int($_[0]);
}

1;