#!/usr/bin/perl
#
# Validate Vyatta config.boot
#
use lib "/opt/vyatta/share/perl5/";
use Vyatta::Config;
use Vyatta::ConfigLoad;
use Vyatta::TypeChecker;

use strict;
use warnings;

my $config_file = '/opt/vyatta/etc/config/config.boot';
$config_file 	= $ARGV[0] if defined($ARGV[0]);

my %config_hierarchy 	= getStartupConfigStatements($config_file);
my @all_set_nodes 	= @{ $config_hierarchy{set} };
if (scalar(@all_set_nodes) == 0) { exit 1; }

my $validation_code 	= 0;
my $config 		= new Vyatta::Config;
foreach (@all_set_nodes) {
  my ($node_path_ref) 	= @$_;
  my $element_count 	= scalar(@$node_path_ref);
  my @non_leaf_elements = @$node_path_ref[0 .. ($element_count - 2)];
  my $node_path 	= join(' ', @non_leaf_elements); $node_path =~ s/'//g;
  my $node_value	= @$node_path_ref[$element_count - 1]; $node_value =~ s/'//g;
  my $node_tmpl_ref 	= $config->parseTmplAll($node_path);

  if ((defined($node_tmpl_ref->{type})) && ($node_tmpl_ref->{type} ne 'txt')) { 
    if (!validateType($node_tmpl_ref->{type}, $node_value, 1)) {
      print(qq{$node_path: "$node_value" is not a valid value of type "$node_tmpl_ref->{type}"} . "\n");
      $validation_code++;
    }
  }
}
exit($validation_code);
