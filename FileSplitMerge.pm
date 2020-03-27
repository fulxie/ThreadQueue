package FileSplitMerge;
use threads;
use Thread::Queue;	
use Exporter qw (import);
our @EXPORT_OK = qw(splitFile mergeFiles);
##### examples #########
# use strict;
# use warnings;
# use  FindBin qw($RealBin);
# use  lib "$RealBin";
# use  FileSplitMerge;
# ###### split file ########
# # splitFile(FileName, FileCount, OutputFolder, Prefix, ExtensionName, Theads );
# FileSplitMerge::splitFile("E:/test.fastq.gz", 7,  "temp", "test", ".tmp.gz", 6 );

# ###### merge files ########
# # mergeFiles(OutputFile, FileArrayRef);
# my @aa;
# map{ push @aa, "temp/test_".$_.".tmp.gz"} 1..7;
# FileSplitMerge::mergeFiles("temp/test.gz", \@aa);
#############

sub mergeFiles{
 my $outputFile=shift;
 my $files_ = shift;
 my @files=@$files_;
 my $file;
 unlink $outputFile;
 foreach $file(@files)
 {
	my $f=getFH($file);
	binmode ($f);
	my $content;
	read($f, $content, -s $f);
	append2BFile($content, $outputFile);
	close $f;
 }
}



sub splitFile
{
	my $fileName=shift ; #"CarolinePlate1.subset.2.fastq.gz";
	my $fileCount=shift; #6;
	my $outputFolder=shift;
	my $prefix=shift;
	my $extensionName=shift;
	my $threads =shift;	
	if($outputFolder eq '')
	{
	  $outputFolder="./";
	}
	
	$extensionName=~s/^\.+//g;
	if($extensionName eq '')
	{
		$extensionName="tmp";
	}
	
	if($threads eq '' || $threads <0)
	{
	  $threads =1
	}
	
	if(! -e $fileName)
	{
	 die "$fileName doesn't exist!";
	}
	
	my $f=getFH($fileName);
	
	my $size=-s $f;

	if( ! -d $outputFolder )
	{
	  mkdir $outputFolder
	}
	
	my %hash= splitNumber($size,$fileCount);
	my @jobs_arguments=(); 
	foreach my $i(1..$fileCount)
	{
	  my @aa=($fileName,$hash{$i}{start}, $hash{$i}{length}, "$outputFolder/$prefix"."_".$i.".".$extensionName); 
	  push @jobs_arguments, \@aa; 
	}
	RunJobs($threads, \&read_save_file, \@jobs_arguments);
}

sub append2BFile
{
	my $content=shift;
	my $fileName=shift;
	my $out;
	open $out, ">>".$fileName;
	binmode ($out);
	print $out $content;
	close $out;
} 


sub RunJobs
{
	############### example of usage #############
	### what you need to do is to define your job function and prepare parameter for each job
	# # sub DoYourJob{
	# # ## get arguments 
	# # my @args=@_; 
	# # ####do job here
	# # print    $args[0], " sdf ".$args[1]."\n";

	# # }

	# # #prepare parameters for each job and pack to an array here
	# # @jobs_arguments=(); 
	# # foreach $i(1..100)
	# # {
	# #   ##for example
	# #   my @aa=($i, "q".$i); # Two arguments
	# #   push @jobs_arguments, \@aa; 
	# # }

	# # #run jobs
	# # my $threads=20;
	#
	# # RunJobs($threads, \&DoYourJob, \@jobs_arguments);
	############### example of usage #############	
	
	use threads;
	use Thread::Queue;
	our $threadCounts = shift;	
	my  $jobName=shift;
	my  $jobs_arguments=shift;

	#define worker sub
	my  $workerSub=sub{
				  my $jobName=shift;
				  our $processQueue;
				  while ( my ($args) = $processQueue -> dequeue(1)  )
				  {
					if(not defined $args)
					{
					  last;
					}	
					$jobName->(@$args); #execute a job here
					#eval ($jobName.'($ps)'); #execute a job here for RunJobs($threads, "DoYourJob", \@jobs); 
					sleep(1);	
					#print threads -> self() -> tid(). ": pinging $server\n"; 
				  }};
				  
	our $processQueue = Thread::Queue -> new();
	my  @jobss=@$jobs_arguments;
	my $jobsCount=scalar @jobss;
	my $i;
	foreach $i(0..($jobsCount-1))
	{
	  $processQueue -> enqueue (\@{$jobss[$i]});
	}
	
	$processQueue -> end();	
	for (1..$threadCounts)
	{
	  threads ->create($workerSub, $jobName);
	}

	foreach my $thr ( threads -> list() )
	{
	  $thr -> join();
	}
	#failed queues
	# while ( my $string = $failed_q -> dequeue_nb() )
	# {
	# print "$string failed to ping\n";
	# }
}


sub read_save_file{
	my $fileName=shift;	
	my $start=shift;
	my $len=shift;
	my $tempOutFile=shift;
	my $content;
	my $f=getFH($fileName);
	binmode ($f);
	seek($f, $start, 0);
	read($f, $content, $len);
    save2BFile($content, $tempOutFile);
	close $f;
}

sub save2BFile
{
	my $content=shift;
	my $fileName=shift;  
	my $out=getOutFH($fileName);
	binmode ($out);
	print $out $content;
	close $out;
} 

sub getOutFH
{
 my $fileName=shift;
 my $lockFile=shift;  # set lockFile to 1 if need to lock File
 my $file;
 open $file, ">".$fileName;
 if($lockFile == 1) 
 {
	 flock $file, 2 or die "Unable to lock file $fileName";
 }
	 
 return $file;
}

sub splitNumber
{ 
    my $x=shift;
	my $n=shift;
	my %hash;
    if($x < $n)  
	{
        $hash{1}{'start'}=0;
	    $hash{1}{'length'}=$x;
		return %hash; 
	}
	elsif ($x % $n == 0)
	{	
		map{
		$hash{$_}{'start'}=$x/$n*($_-1);
		$hash{$_}{'length'}=$x/$n;
		} 1..$n;
		return %hash; 
	}
	else 
	{
		my  $zp = $x % $n  ;
		my  $pp =  int($x/$n) ; 
		map{
		$hash{$_}{'start'}=$pp*($_-1);
		$hash{$_}{'length'}=$pp;
		} 1..($n);

		$hash{$n}{'length'}=$zp + $pp;
		return %hash; 
	}	
}

sub getFH
{
 my $fileName=shift;
 my $lockFile=shift; # set lockFile to 1 if need to lock File
 my $file;
 open $file, $fileName;
 if($lockFile == 1) 
 {
	 flock $file, 2 or die "Unable to lock file $fileName";
 }
	 
 return $file;
}


1;
