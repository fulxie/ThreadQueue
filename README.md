# ThreadQueue
a lightweight wrapper of Perl Thread Queue

you just need to define job function and prepare a parameter array for each job.


eg:


### define your job function

sub DoYourJob{

	my $arg_=shift;
	
	## get arguments 
	my @args=@$arg_; 
	
	####do job here
	print    $args[0], " and ".$args[1]."\n";
	 
}

#prepare parameters for each job and pack to an array here
@jobs=(); 

foreach $i(1..100)

{

  ##for example
  
  my @aa=($i, "q".$i);
  
  push @jobs, \\@aa; 
  
}


#run jobs

my $threads=20;

RunJobs($threads, "DoYourJob", \\@jobs);




############ split and merge files #############

use strict;

use warnings;

use  FindBin qw($RealBin);

use  lib "$RealBin";

use  FileSplitMerge;

#splitFile(FileName, FileCount, OutputFolder, Prefix, ExtensionName, Theads );
 
FileSplitMerge::splitFile("E:/test.fastq.gz", 7,  "temp", "test", ".tmp.gz", 6 );


#mergeFiles(OutputFile, FileArrayRef);

my @aa;

map{ push @aa, "temp/test_".$_.".tmp.gz"} 1..7;

FileSplitMerge::mergeFiles("temp/test.gz", \@aa);

