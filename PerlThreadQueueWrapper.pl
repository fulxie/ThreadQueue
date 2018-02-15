#!/usr/bin/perl
# Perl Thread Queue Wrapper
# Copyright (c) Leon.
#


#Wrap Thread Queue
sub RunJobs
{
	use threads;
	use Thread::Queue;
	our $NTHREADS = shift;	
	my  $doJobName=shift;
	my  $jobs=shift;
	
	#define worker sub
    my  $workerSub=sub{
				  my $doJobName=shift;
				  our $PROCESS_QUEUE;
				  while ( my ($ps) = $PROCESS_QUEUE -> dequeue(1)  )
				  {
					if(not defined $ps)
					{
					  last;
					}	
					eval ($doJobName.'($ps)'); #execute a job here
					sleep(1);	
					#print threads -> self() -> tid(). ": pinging $server\n"; 
				  }};	
	our $PROCESS_QUEUE = Thread::Queue -> new();
	#our $failed_q = Thread::Queue -> new();
	my  @jobss=@$jobs;
	my $jobsCount=scalar @jobss;
	my $i;
	foreach $i(0..($jobsCount-1))
	{
	  $PROCESS_QUEUE -> enqueue (\@{$jobss[$i]});
	}
	$PROCESS_QUEUE -> end();	
	for (1..$NTHREADS)
	{
	  threads ->create($workerSub, $doJobName);
	}

	foreach my $thr ( threads -> list() )
	{
	  $thr -> join();
	}

	# while ( my $string = $failed_q -> dequeue_nb() )
	# {
	# print "$string failed to ping\n";
	# }
}


### what you need to do is to define your job function and prepare parameter for each job
sub DoYourJob{
	my $arg_=shift;
	
	## get arguments 
	my @args=@$arg_; 
	
	####do job here
	print    $args[0], " sdf ".$args[1]."\n";
	 
}

#prepare parameters for each job and pack to an array here
@jobs=(); 
foreach $i(1..100)
{
  ##for example
  my @aa=($i, "q".$i);
  push @jobs, \@aa; 
}

#call jobs
my $threads=20;
RunJobs($threads, "DoYourJob", \@jobs);



 