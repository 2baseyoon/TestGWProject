package egovframework.coviframework.batch;

import java.io.PrintWriter;
import java.io.StringWriter;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.JobListener;

/**
 * @Class Name : CoviJobListener.java
 * @Description : 스케쥴러 job에 대한 Listener class
 * @Modification << 개정이력(Modification Information) >>
 * 
 *               수정일 수정자 수정내용 --------- ---------
 *               ------------------------------- 2016.2.8 고아라 최초작성
 *
 * @author ara
 * @since 2016. 2. 8.
 * @version 1.0
 * @see
 */

public class CoviJobListener implements JobListener {
	private Logger LOGGER = LogManager.getLogger(CoviJobListener.class);

	public static final String LISTENER_NAME = "CoviJobListener";// JobListener이름

	/**
	 * LISTENER_NAME getter
	 * 
	 * @param
	 * @exception
	 * @return String LISTENER_NAME
	 */
	@Override
	public String getName() {
		return LISTENER_NAME; // must return a name
	}

	/**
	 * job 실행되기 전 호출
	 * 
	 * @param context
	 *            JobExecutionContext
	 * @exception
	 * @return
	 */
	@Override
	public void jobToBeExecuted(JobExecutionContext context) {
		String jobName = context.getJobDetail().getKey().toString();
		LOGGER.info("jobToBeExecuted ");
		LOGGER.info("Job : " + jobName + " is going to start.");

	}

	/**
	 * job 중단되었을 때 호출
	 * 
	 * @param
	 * @exception
	 * @return
	 */
	@Override
	public void jobExecutionVetoed(JobExecutionContext context) {
		String jobName = context.getJobDetail().getKey().toString();

		LOGGER.info("Job : " + jobName + " is jobExecutionVetoed.");
	}

	/**
	 * job 실행된 후 호출
	 * 
	 * @param
	 * @exception
	 * @return
	 */
	@Override
	public void jobWasExecuted(JobExecutionContext context,
			JobExecutionException jobException) {

		LOGGER.info("jobWasExecuted");

		String jobName = context.getJobDetail().getKey().toString();
		String className = context.getTrigger().getClass().toString();

		if (jobException != null) {
			if (!jobException.getMessage().equals("")) {
				// 에러발생시
				LOGGER.info(" Exception thrown by: " + jobName + " Exception: "
						+ jobException.getMessage());
			}
		} else {
			LOGGER.info("Job : " + jobName + " is successful.");
		}

		LOGGER.info("Job : " + jobName + " is finished  ...");
	}

	/**
	 * Creates and returns a {@link java.lang.String} from t’s stacktrace
	 * 
	 * @param t
	 *            Throwable whose stack trace is required
	 * @return String representing the stack trace of the exception
	 */
	public String getStackTrace(Throwable t) {
		StringWriter stringWritter = new StringWriter();
		PrintWriter printWritter = new PrintWriter(stringWritter, true);
		t.printStackTrace(printWritter);
		printWritter.flush();
		stringWritter.flush();

		return stringWritter.toString();
	}
}
