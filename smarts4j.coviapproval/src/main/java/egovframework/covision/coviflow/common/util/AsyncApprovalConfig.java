package egovframework.covision.coviflow.common.util;

import java.util.concurrent.Executor;

import javax.annotation.Resource;

import org.springframework.aop.interceptor.AsyncUncaughtExceptionHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.AsyncConfigurer;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

@Configuration
@EnableAsync
public class AsyncApprovalConfig implements AsyncConfigurer{//AsyncConfigurer를 상속받아 AsyncConfig 구현
	
	@Override
	public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
		// TODO Auto-generated method stub
		return null;
	}

	//기본 Thread 수
	private static int TASK_CORE_POOL_SIZE = 3;
	//최대 Thread 수
	private static int TASK_MAX_POOL_SIZE = 8;
	//QUEUE 수
	private static int TASK_QUEUE_CAPACITY = 10;
	//Thread Bean Name
	private static String EXECUTOR_BEAN_NAME = "executorEdmsTransfer";
	//Thread
	@Resource(name = "executorEdmsTransfer")
	private ThreadPoolTaskExecutor executorEdmsTransfer;
	
	
	
	//기본 Thread 수
	private static int TASK_CORE_POOL_SIZE2 = 3;
	//최대 Thread 수
	private static int TASK_MAX_POOL_SIZE2 = 8;
	//QUEUE 수
	private static int TASK_QUEUE_CAPACITY2 = 10;
	//Thread Bean Name
	private static String EXECUTOR_BEAN_NAME2 = "executorOpenDocConvert";
	//Thread
	@Resource(name = "executorOpenDocConvert")
	private ThreadPoolTaskExecutor executorOpenDocConvert;
	
	
	//기본 Thread 수
	private static int TASK_CORE_POOL_SIZE3 = 3;
	//최대 Thread 수
	private static int TASK_MAX_POOL_SIZE3 = 8;
	//QUEUE 수
	private static int TASK_QUEUE_CAPACITY3 = 10;
	//Thread Bean Name
	private static String EXECUTOR_BEAN_NAME3 = "executorOpenDocSend";
	//Thread
	@Resource(name = "executorOpenDocSend")
	private ThreadPoolTaskExecutor executorOpenDocSend;
	
	
	//기본 Thread 수
	private static int TASK_CORE_POOL_SIZE4 = 2;
	//최대 Thread 수
	private static int TASK_MAX_POOL_SIZE4 = 8;
	//QUEUE 수
	private static int TASK_QUEUE_CAPACITY4 = 50;
	//Thread Bean Name
	private static String EXECUTOR_BEAN_NAME4 = "executorPdfExport";
	//Thread
	@Resource(name = "executorPdfExport")
	private ThreadPoolTaskExecutor executorPdfExport;
	
/***************************************************************************************************************************************/
	
	/**
	 * Thread 생성
	 */
	@Bean(name = "executorEdmsTransfer")//Bean Name 추가
	@Override
	public Executor getAsyncExecutor(){
		ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
		executor.setCorePoolSize(TASK_CORE_POOL_SIZE);//pool size 지정
		executor.setMaxPoolSize(TASK_MAX_POOL_SIZE);//최대 pool size 지정
		executor.setQueueCapacity(TASK_QUEUE_CAPACITY);//queue size 지정
		executor.setBeanName(EXECUTOR_BEAN_NAME);//bean name 지정
		executor.initialize();
		return executor;
	}
	
	
	@Bean(name = "executorOpenDocConvert")//Bean Name 추가
	public Executor getAsyncOpenDocExecutor(){
		ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
		executor.setCorePoolSize(TASK_CORE_POOL_SIZE2);//pool size 지정
		executor.setMaxPoolSize(TASK_MAX_POOL_SIZE2);//최대 pool size 지정
		executor.setQueueCapacity(TASK_QUEUE_CAPACITY2);//queue size 지정
		executor.setBeanName(EXECUTOR_BEAN_NAME2);//bean name 지정
		executor.initialize();
		return executor;
	}
	
	@Bean(name = "executorOpenDocSend")//Bean Name 추가
	public Executor getAsyncOpenDocSendExecutor(){
		ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
		executor.setCorePoolSize(TASK_CORE_POOL_SIZE3);//pool size 지정
		executor.setMaxPoolSize(TASK_MAX_POOL_SIZE3);//최대 pool size 지정
		executor.setQueueCapacity(TASK_QUEUE_CAPACITY3);//queue size 지정
		executor.setBeanName(EXECUTOR_BEAN_NAME3);//bean name 지정
		executor.initialize();
		return executor;
	}
	
	@Bean(name = "executorPdfExport")//Bean Name 추가
	public Executor getAsyncPdfExportExecutor(){
		ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
		executor.setCorePoolSize(TASK_CORE_POOL_SIZE4);//pool size 지정
		executor.setMaxPoolSize(TASK_MAX_POOL_SIZE4);//최대 pool size 지정
		executor.setQueueCapacity(TASK_QUEUE_CAPACITY4);//queue size 지정
		executor.setBeanName(EXECUTOR_BEAN_NAME4);//bean name 지정
		executor.initialize();
		return executor;
	}
}
