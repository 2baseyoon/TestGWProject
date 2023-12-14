package egovframework.batch.base;

import java.util.Properties;

import egovframework.coviframework.batch.BaseQuartzServer;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.SchedulerFactory;
import org.quartz.impl.StdSchedulerFactory;

import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.baseframework.vo.DBPropertiesSet;

/**
 * @Class Name : CoviQuartzServer.java
 * @Description : 쿼츠서버설정 class
 * @Modification << 개정이력(Modification Information) >>
 * 
 *  수정일                   수정자                  수정내용
 *  ---------   ---------   -------------------------------
 *  2016.1.28   이성문                   최초작성      
 *
 * @author 이성문
 * @since 2016. 1. 28.
 * @version 1.0
 * @see
 */


public class CoviQuartzServer extends BaseQuartzServer {

	private SchedulerFactory stdSchedulerFactory;

	// quartzServer.properties 파일값
	//@Value("#{quartzInfo}") Properties prop;
	
	private Logger LOGGER = LogManager.getLogger(CoviQuartzServer.class);
	
	String quartzMode = PropertiesUtil.getGlobalProperties().getProperty("quartz.mode");
	String isClustered = PropertiesUtil.getGlobalProperties().getProperty("quartz.isClustered")==null?"false":PropertiesUtil.getGlobalProperties().getProperty("quartz.isClustered");
	/**
	 * 쿼츠 서버 init method
	 * 
	 * @param
	 * @exception
	 * @return
	 */
	public void openServer() {
		StringUtil func = new StringUtil();
		
		LOGGER.info("OPENSERVER");
		
		try {
			
			if(!func.f_NullCheck(quartzMode).equals("N")){
				Properties props = new Properties();

			    // General
		        props.put(StdSchedulerFactory.PROP_SCHED_INSTANCE_NAME, "ServerScheduler");
		        props.put(StdSchedulerFactory.PROP_SCHED_INSTANCE_ID, "AUTO");

		        // Thread pooling ?
		        props.put("org.quartz.threadPool.class", org.quartz.simpl.SimpleThreadPool.class.getName());
		        props.put("org.quartz.threadPool.threadCount", "10");
		        props.put("org.quartz.threadPool.threadPriority", "5");

		        // JobStore
		        props.put("org.quartz.jobStore.class", "org.quartz.impl.jdbcjobstore.JobStoreTX");
		        
		        // db.mapper.one => db.mapper.qrtz (default : db.mapper.one )
		        String jndiName = PropertiesUtil.getDBProperties().getProperty("db.mapper.qrtz.datasource");
		        String vendor = PropertiesUtil.getDBProperties().getProperty("db.mapper.qrtz.sql");
		        if(jndiName == null || jndiName.isEmpty()) {
			        jndiName = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.datasource");
			        vendor = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		        }
		        
		        if("mssql".equals(vendor)){
			        props.put("org.quartz.jobStore.driverDelegateClass", "org.quartz.impl.jdbcjobstore.MSSQLDelegate");
			        props.put("org.quartz.jobStore.lockHandler.class", "org.quartz.impl.jdbcjobstore.StdRowLockSemaphore");
					props.put("org.quartz.jobStore.lockHandler.selectWithLockSQL", "SELECT LOCK_NAME FROM {0}LOCKS WITH (ROWLOCK, UPDLOCK) WHERE LOCK_NAME=? ");
					props.put("org.quartz.jobStore.txIsolationLevelSerializable",true); 
					props.put("org.quartz.jobStore.acquireTriggersWithinLock",true); 
			        
		        	props.put("org.quartz.jobStore.tablePrefix", "COVI_SMART4J.dbo.QRTZ_");		//mssql인 경우 소유자 구분 필요
		        }else{
			        props.put("org.quartz.jobStore.driverDelegateClass", "org.quartz.impl.jdbcjobstore.StdJDBCDelegate");
		        	props.put("org.quartz.jobStore.tablePrefix", "QRTZ_");		//Oracle의 경우 테이블스페이스명을 Prefix가 필요
		        }

		        props.put("org.quartz.jobStore.useProperties", false);
		        props.put("org.quartz.jobStore.dataSource", "quartzDataSource");

		        props.put("org.quartz.jobStore.isClustered", isClustered);
		        props.put("org.quartz.jobStore.clusterCheckinInterval", "20000");

		        props.put("org.quartz.jobStore.misfireThreshold", "60000");
		        props.put("org.quartz.jobStore.maxMisfiresToHandleAtATime", "20");
		        
		        props.put("org.quartz.dataSource.quartzDataSource.jndiURL", jndiName);
		       
		        props.put("org.quartz.scheduler.misfirePolicy", "doNothing");
		        
		        // 간헐적 상태가 ERROR 가 빠지는 Trigger 발생시 알림메일 발송및 재처리
		        if("mysql".equals(vendor)){
		        	props.put("org.quartz.jobStore.driverDelegateClass", "egovframework.batch.base.CoviQuartzDelegate");
		        }
		        
				setStdSchedulerFactory(new StdSchedulerFactory(props));
				Scheduler scheduler = getStdSchedulerFactory().getScheduler();
				scheduler.start();
			}
		}
		catch (SchedulerException se) {
			LOGGER.error(se.getMessage());
		}
		catch (Exception ex) {
			LOGGER.error(ex.getMessage());
		}
	}

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
