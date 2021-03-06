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
use File::Copy;
use Mojo::UserAgent;

use constant DEBUG => 0;

my $dlist = 'info.txt'; #File of direcory listing
my $files_limit = 3; #Count of files for reduce
my $sync_dir = "YandexDisk/DB/"; #Directory for sync
my $oauth = "AQAAAAASB2MoAAUyDgVUhKPu-kgajQZ-grGk-H0";
my $syncfl = $ARGV[0] || ''; #Set flag to sync

my @struct = ();
my @dirs = ();
my @files = ();
my $source_dir = ''; #Directory source of sync fiels
my $sync_file = '';

print "Warning! Debug mode\n" if DEBUG;

open (STRUCT, "< info.txt") || die "Can't open info.txt\n";
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

#Clear sync dir
if(!DEBUG && $syncfl){
	if(chdir $sync_dir){
		unlink <*>;
		print "Clear synd dir is Ok\n";
		chdir "../../";

		# Clear Trash
		my $ua  = Mojo::UserAgent->new;
		my $tx = $ua->delete('https://cloud-api.yandex.net/v1/disk/trash/resources' => {Authorization => "OAuth $oauth", Accept => 'application/json'});
		print $tx->result->body if (DEBUG);
	};
};

foreach my $dir (@dirs){
	print "\nChange directory to $dir\n";
	if (chdir $dir) {
		@files  = <*>;
		
		$sync_file = splice (@files, -1*$files_limit); #Get file for backup

		#Deleting files from directory
		foreach my $key (@files){
			print "Unlink file: $key ...";
			unlink $key if !DEBUG;
			print "done\n";
		};

		
		$source_dir = $dir;

		#Set path to root
		$dir=~s/(\w+)/../g;
		print "Change dir to $dir\n" if DEBUG;
		chdir $dir;

		if($syncfl && $sync_file){
			print "Sync file: $sync_file\n";
			if(!DEBUG){
				my $tstamp = time;
				copy ($source_dir.$sync_file, $sync_dir.$tstamp."_".$sync_file) || die "Can't copy file: $sync_file";
			};
			$sync_file = '';
		};
	}else{
		print "Can't change directory\n";	

	};
};

print "All done. To quit press Enter.";

1;
