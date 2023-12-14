package egovframework.core.util;

import java.util.concurrent.Executor;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.AsyncConfigurer;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import egovframework.baseframework.util.PropertiesUtil;

@Configuration
@EnableAsync
public class AsyncCovicoreConfig implements AsyncConfigurer{// Extends SPRING AsyncConfigurer
	
	private static int TASK1_CORE_POOL_SIZE = 5;//기본 Thread 수
	private static int TASK1_MAX_POOL_SIZE = 50;//최대 Thread 수
	private static int TASK1_QUEUE_CAPACITY = 1000;//QUEUE 수
	private static String EXECUTOR1_BEAN_NAME = "executorExternalDatabaseSync";//Thread Bean Name
	
	
	private static int TASK2_CORE_POOL_SIZE = 5;//기본 Thread 수
	private static int TASK2_MAX_POOL_SIZE = 10;//최대 Thread 수
	private static int TASK2_QUEUE_CAPACITY = 10;//QUEUE 수
	private static String EXECUTOR2_BEAN_NAME = "executorTempDelete";//Thread Bean Name
	
	private static int TASK3_CORE_POOL_SIZE = 10;//기본 Thread 수
	private static int TASK3_MAX_POOL_SIZE = 10;//최대 Thread 수
	private static int TASK3_QUEUE_CAPACITY = Integer.MAX_VALUE;//QUEUE 수
	private static String EXECUTOR3_BEAN_NAME = "coviExecutorForMessaging";//Thread Bean Name
	
	
/***************************************************************************************************************************************/
	
	/**
	 * Thread 생성
	 */
	@Bean(name = "executorExternalDatabaseSync")//Bean Name 추가
	@Override
	public Executor getAsyncExecutor(){
		ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
		
		String corePoolSize = PropertiesUtil.getGlobalProperties().getProperty("extdbsync.threadpool.core.size", String.valueOf(TASK1_CORE_POOL_SIZE));
		String maxPoolSize = PropertiesUtil.getGlobalProperties().getProperty("extdbsync.threadpool.max.size", String.valueOf(TASK1_MAX_POOL_SIZE));
		String maxQueueSize = PropertiesUtil.getGlobalProperties().getProperty("extdbsync.threadpool.queue.size", String.valueOf(TASK1_QUEUE_CAPACITY));
		
		executor.setCorePoolSize(Integer.parseInt(corePoolSize));//pool size 지정
		executor.setMaxPoolSize(Integer.parseInt(maxPoolSize));//최대 pool size 지정
		executor.setQueueCapacity(Integer.parseInt(maxQueueSize));//queue size 지정
		executor.setBeanName(EXECUTOR1_BEAN_NAME);//bean name 지정
		executor.initialize();
		return executor;
	}
	
	@Bean(name = "executorTempDelete")//Bean Name 추가
	public Executor getAsyncTempDeleteExecutor(){
		ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
		
		String corePoolSize = PropertiesUtil.getGlobalProperties().getProperty("tempdelete.threadpool.core.size", String.valueOf(TASK2_CORE_POOL_SIZE));
		String maxPoolSize = PropertiesUtil.getGlobalProperties().getProperty("tempdelete.threadpool.max.size", String.valueOf(TASK2_MAX_POOL_SIZE));
		String maxQueueSize = PropertiesUtil.getGlobalProperties().getProperty("tempdelete.threadpool.queue.size", String.valueOf(TASK2_QUEUE_CAPACITY));
		
		executor.setCorePoolSize(Integer.parseInt(corePoolSize));//pool size 지정
		executor.setMaxPoolSize(Integer.parseInt(maxPoolSize));//최대 pool size 지정
		executor.setQueueCapacity(Integer.parseInt(maxQueueSize));//queue size 지정
		executor.setBeanName(EXECUTOR2_BEAN_NAME);//bean name 지정
		executor.initialize();
		return executor;
	}
	
	@Bean(name = "coviExecutorForMessaging")//Bean Name 추가
	public Executor getAsyncMessagingExecutor(){
		ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
		
		String corePoolSize = PropertiesUtil.getGlobalProperties().getProperty("messaging.threadpool.core.size", String.valueOf(TASK3_CORE_POOL_SIZE));
		String maxPoolSize = PropertiesUtil.getGlobalProperties().getProperty("messaging.threadpool.max.size", String.valueOf(TASK3_MAX_POOL_SIZE));
		String maxQueueSize = PropertiesUtil.getGlobalProperties().getProperty("messaging.threadpool.queue.size", String.valueOf(TASK3_QUEUE_CAPACITY));
		
		executor.setCorePoolSize(Integer.parseInt(corePoolSize));//pool size 지정
		executor.setMaxPoolSize(Integer.parseInt(maxPoolSize));//최대 pool size 지정
		executor.setQueueCapacity(Integer.parseInt(maxQueueSize));//queue size 지정
		
		executor.setBeanName(EXECUTOR3_BEAN_NAME);//bean name 지정
		executor.initialize();
		return executor;
	}
	// ... avail add-on.
}
