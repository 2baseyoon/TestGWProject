package egovframework.coviframework.batch;

import org.quartz.SchedulerFactory;

public abstract class BaseQuartzServer {
	private SchedulerFactory stdSchedulerFactory;
	
	
	// 상속받는 클래스에서 재정의하여 사용
	public abstract void openServer();
	
	
	/**
	 * SchedulerFactory getter
	 * 
	 * @param
	 * @exception
	 * @return SchedulerFactory
	 */
	public SchedulerFactory getStdSchedulerFactory() {
		return stdSchedulerFactory;
	}

	/**
	 * SchedulerFactory setter
	 * 
	 * @param stdSchedulerFactory
	 *            SchedulerFactory
	 * @exception
	 * @return
	 */
	public void setStdSchedulerFactory(SchedulerFactory stdSchedulerFactory) {
		this.stdSchedulerFactory = stdSchedulerFactory;
	}
}
