
sub RunProcesses
{
	# ############### example of usage #############
	# # what you need to do is to define your job function and prepare parameter for each job
	# sub DoYourJob{
	# ## get arguments 
	# my @args=@_; 
	# ####do job here
	# print    $args[0], " sdf ".$args[1]." $args[2]\n";

	# }

	# #prepare parameters for each job and pack to an array here
	# @jobs_arguments=(); 
	# foreach $i(1..100)
	# {
	  # ##for example
	  # my @aa=($i, "q".$i, "xiexie".$i); # Two arguments
	  # push @jobs_arguments, \@aa; 
	# }

	# #run jobs
	# my $processCount=20;
	# print "############\n";
	# RunProcesses($processCount, \&DoYourJob, \@jobs_arguments);
	############### example of usage #############	

    use POSIX ":sys_wait_h";
	our $process_cnt = shift;
	my $jobName=shift;
	my $jobs_arguments=shift;
	our $current_cnt = 0; 
 
	sub processpool_waitforall{
	       our $current_cnt;
			while($current_cnt > 0){
					my $code = waitpid(-1, WNOHANG);
					if( $code > 0){
							$current_cnt --;
					}elsif( $code == -1 ){
							$current_cnt = 0;
					}else{
							sleep(1);
					}
			}
	}
	
     sub processpool_run_task{	    
        my $func = shift @_;
        my @params =@{ $_[0] };
		our $current_cnt;
		our $process_cnt;
        while($current_cnt >= $process_cnt){
                my $code = waitpid(-1, WNOHANG);
                if( $code > 0 ){
                        $current_cnt --;
						 
                }elsif( $code == -1 ){
                        $current_cnt = 0;
                }elsif( $code == 0 ){
                       sleep(1);
                }
        }
        #do job 
        my $pid = fork;
        if( ! defined($pid) ){
                print "Process create FAILED: $func @params\n";
                return 1;
        }
        if( $pid == 0 ){
                #child process 
                my $res =  $func->(@params);
                exit $res;
        }
        $current_cnt++;
        return 0;
	}
   	
	my  @jobss=@$jobs_arguments;
	my $jobsCount= scalar @jobss;
    foreach $i(0..($jobsCount-1))
	{
	  processpool_run_task($jobName,\@{$jobss[$i]});
	}
	processpool_waitforall();
}

