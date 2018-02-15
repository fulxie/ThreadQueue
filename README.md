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

