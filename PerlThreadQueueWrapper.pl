#!/usr/bin/perl
# Perl Thread Queue Wrapper
# Author: Leon Xie
# 2/14/2018


#Wrap Thread Queue
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


### what you need to do is to define your job function and prepare parameter for each job
sub DoYourJob{
	my @args=@_; 		 
	 print    $args[0], " sdf ".$args[1]."\n";	 
}

#prepare parameters for each job and pack to an array here
@jobs=(); 
foreach $i(1..100)
{
  ##for example
   my @aa=($i, "q".$i, "xiexie".$i); # three arguments for DoYourJob
 
  push @jobs, \@aa; 
}

#run jobs
my $threads=20;
RunJobs($threads, \&DoYourJob, \@jobs);



 
