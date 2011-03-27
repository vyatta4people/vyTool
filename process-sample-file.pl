#!/usr/bin/perl
#
# Substitute keys with specified values in given file and send result to STDOUT
#
use strict;
use warnings;

# Try to open sample file and read contents
my $sample_file 	= shift;
die(qq{Usage: process-sample-file <sample_file> --<key1>=<value1> --<key2>=<value2> ... --<keyN>=<valueN>} . "\n") if $#ARGV < 0;
open (SAMPLE, $sample_file) or die(qq{$!} . "\n");
my @sample_lines	= <SAMPLE>;
my $sample_data		= join('', @sample_lines);
close(SAMPLE);

# Process keys from sample file
my @sample_key_lines    = grep(/%\([a-z][a-z0-9-]+\)/, @sample_lines);
my @sample_keys         = ();
foreach my $sample_key_line (@sample_key_lines) {
  $sample_key_line =~ s/\).*\%\(/\)\n\%\(/g;
  $sample_key_line =~ s/.*\%\(//gm;
  $sample_key_line =~ s/\).*//gm;
  push(@sample_keys, split(/\n/, $sample_key_line));
}
# Make arrey @sample_keys sorted and unique
my %seen_sample_keys    = ();
my @unique_sample_keys  = grep {! $seen_sample_keys{$_}++} @sample_keys;
@sample_keys            = sort(@unique_sample_keys);

# Process keys from command line
my @sub_pairs 	= split('--', join('', @ARGV)); shift(@sub_pairs);
my %subs	= ();
foreach (@sub_pairs) {
  die(qq{Invalid kay/value pair: $_} . "\n") if !($_ =~ m/^[a-z][a-z0-9-]+=.+$/);
  my ($sub_key, $sub_value) 	= split('=', $_);
  $subs{$sub_key}		= $sub_value;
}
my @sub_keys = sort(keys(%subs));

# Compare keys from command line and sample file (must be equal)
foreach my $element (@sample_keys) { die(qq{Key NOT found in command line: $element} . "\n") if !(grep {$_ eq $element} @sub_keys); }
foreach my $element (@sub_keys)    { die(qq{Key NOT found in sample file: $element} . "\n")  if !(grep {$_ eq $element} @sample_keys); }

# Substitute!
foreach my $sub_key (@sub_keys) { $sample_data =~ s/\%\($sub_key\)/$subs{$sub_key}/gm; }

print $sample_data;
