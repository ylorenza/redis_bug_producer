## The Bug ##

I have a cluster 3 master and 3 slaves, freshly created. 
You can see the conf in config dir and the creation script is init_and_launch_cluster.sh

I launch a Java junit test which use Redisson. 
The test initialise redisson (with a scan interval set to 100 ms in order to produce the bug quicker),
and insert key into the redis cluster in 15 thread.

I launch the kill-random-redis-master_local.sh script. This script kill a random master, wait 15s (nodetimeout is 10s),
relaunch the killed master, wait 10s, and start over.

In generally 10 minutes, I have this exception : 

14:42:11.742 [redisson-netty-1-6] WARN  i.n.util.concurrent.DefaultPromise - An exception was thrown by org.redisson.command.CommandAsyncService$9.operationComplete()
org.redisson.client.RedisNodeNotFoundException: Node: /127.0.0.1:10004 for slot: 5587 hasn't been discovered yet
        at org.redisson.connection.MasterSlaveConnectionManager.getEntry(MasterSlaveConnectionManager.java:703)
        at org.redisson.connection.MasterSlaveConnectionManager.connectionWriteOp(MasterSlaveConnectionManager.java:693)
        at org.redisson.command.CommandAsyncService.async(CommandAsyncService.java:503)

I can't understand why there is this exception, but it is not catch anywhere.
So the thread which handle this command is stuck in await of the countdownlatch (CountDownLatch:148)

After 15 RedisNodeNotFoundException, all my insert thread are stuck, i can't insert any more

I made a little project on github, to help people reproduce this : https://github.com/ylorenza/redis_bug_producer

Thanks for you're help


## How to reproduce ##

 * Install java8, maven, ruby
 
 * install redis gem (for redis_trib.rb) 
   gem install redis
   
 * cd to the root of this project
  
 * Launch  ./init_and_launch_cluster.sh
 
 * Launch the unit test : mvn test
 
 * Launch ./kill-random-redis-master_local.sh
 
 * Wait for the bug (No more cluster status update and no more insert)