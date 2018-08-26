#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: fsrotate.pl
#
#        USAGE: ./fsrotate.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: emark.github.com
#       AUTHOR: Sviridenko Maxim 
# ORGANIZATION: 
#      VERSION: 0.1
#      CREATED: 26.08.2018 19:45:41
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use constant DEBUG => 1;

my $dlist = 'info.txt'; #File of direcory listing
my $files_limit = 3; #Count of files for reduce

my @struct = ();
my @dirs = ();
my @files = ();

open (STRUCT, "< info.txt") || die "Can't open info.txt";
@struct = <STRUCT>;
close STRUCT;

#Parsing dlist file
foreach my $key (@struct){
	my ($flag, $dir, $description) = split(" ",$key);
	print "$flag, $dir\n" if DEBUG;
	if ($flag eq '+'){
		push @dirs, $dir;
	};
};

foreach my $key (@dirs){
	print "\nChange directory to $key\n";
	if (chdir $key) {
		@files  = <*>;
		splice (@files, $files_limit);	

		foreach my $key (@files){
			print "Unlink file: $key ...";
			unlink $key if !DEBUG;
			print "done\n";

		};
		chdir "../";
	}else{
		print "Can't change directory";	

	};
};

1;
