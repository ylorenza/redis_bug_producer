## The Bug ##



## How to reproduce ##

 * install redis gem (for redis_trib.rb) 
   gem install redis
   
 * cd to the root of this project
  
 * Launch  init_and_launch_cluster.sh
 
 * Launch the unit test
 
 * Launch kill-random-redis-master_local.sh
 
 * Wait for the bug (No more cluster status update and no more insert)