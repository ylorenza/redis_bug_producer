import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.redisson.Redisson;
import org.redisson.api.RedissonClient;
import org.redisson.client.RedisException;
import org.redisson.config.Config;
import org.redisson.config.ReadMode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigInteger;
import java.security.SecureRandom;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.concurrent.RejectedExecutionException;
import java.util.concurrent.TimeUnit;


public class RedisTest {

    private static final Logger log = LoggerFactory.getLogger(RedisTest.class);

    private final String[] NODES = {"127.0.0.1:10000", "127.0.0.1:10001",
            "127.0.0.1:10002", "127.0.0.1:10003",
            "127.0.0.1:10004", "127.0.0.1:10005"};

    private RedissonClient redissonClient;


    private SecureRandom random = new SecureRandom();

    public String nextRedisKey() {
        return new BigInteger(130, random).toString(32);
    }

    @Before
    public void setUp() throws InterruptedException {
        Config config = new Config();
        config.setUseLinuxNativeEpoll(false);
        config.useClusterServers().addNodeAddress(NODES).setReadMode(ReadMode.MASTER).setScanInterval(100);
        redissonClient = Redisson.create(config);
    }

    @Test
    public void test() throws InterruptedException {

        Executor executor = Executors.newFixedThreadPool(15);

        Runnable r = () -> {
            try {
                //printCluster();
                redissonClient.getBucket(nextRedisKey()).set("value", 15, TimeUnit.MINUTES);


            } catch (RedisException e) {
                log.error("RedisException",e);
            }
        };

        int i = 0;
        for (; ; ) {
            try {
                executor.execute(r);
                Thread.sleep(100);
            } catch (RejectedExecutionException e) {
                //System.out.println("e = " + e);
            }
        }
    }

    @After
    public void tearDown() {
        redissonClient.shutdown();
    }
}
