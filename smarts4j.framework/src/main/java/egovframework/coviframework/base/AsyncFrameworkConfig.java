package egovframework.coviframework.base;

import java.util.concurrent.Executor;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

@Configuration
@EnableAsync
public class AsyncFrameworkConfig {
	
	private static int TASK_ENCRYPT_CORE_POOL_SIZE = 10;//기본 Thread 수
	private static int TASK_ENCRYPT_MAX_POOL_SIZE = 10;//최대 Thread 수
	private static int TASK_ENCRYPT_QUEUE_CAPACITY = Integer.MAX_VALUE;//QUEUE 수
	private static String EXECUTOR_ENCRYPT_BEAN_NAME = "coviExecutorFileEncrypt";//Thread Bean Name
	
	private static int TASK_FILEDELETE_CORE_POOL_SIZE = 30;//기본 Thread 수
	private static int TASK_FILEDELETE_MAX_POOL_SIZE = 30;//최대 Thread 수
	private static int TASK_FILEDELETE_QUEUE_CAPACITY = Integer.MAX_VALUE;//QUEUE 수
	private static String EXECUTOR_FILEDELETE_BEAN_NAME = "coviExecutorFileDelete";//Thread Bean Name
	
	/**
	 * Thread 생성
	 */
	@Bean(name = "coviExecutorFileEncrypt")//Bean Name 추가
	public Executor getAsyncFileEncyptorExecutor(){
		ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
		
		executor.setCorePoolSize(TASK_ENCRYPT_CORE_POOL_SIZE);//pool size 지정
		executor.setMaxPoolSize(TASK_ENCRYPT_MAX_POOL_SIZE);//최대 pool size 지정
		executor.setQueueCapacity(TASK_ENCRYPT_QUEUE_CAPACITY);//queue size 지정
		
		executor.setBeanName(EXECUTOR_ENCRYPT_BEAN_NAME);//bean name 지정
		executor.initialize();
		return executor;
	}
	
	@Bean(name = "coviExecutorFileDelete")//Bean Name 추가
	public Executor getAsyncFileDeleteExecutor(){
		ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
		
		executor.setCorePoolSize(TASK_FILEDELETE_CORE_POOL_SIZE);//pool size 지정
		executor.setMaxPoolSize(TASK_FILEDELETE_MAX_POOL_SIZE);//최대 pool size 지정
		executor.setQueueCapacity(TASK_FILEDELETE_QUEUE_CAPACITY);//queue size 지정
		
		executor.setBeanName(EXECUTOR_FILEDELETE_BEAN_NAME);//bean name 지정
		executor.initialize();
		return executor;
	}
	// ... avail add-on.

}