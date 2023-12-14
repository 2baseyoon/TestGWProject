package egovframework.coviframework.batch;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.quartz.Scheduler;

/**
 * @Class Name  : CoviShutDownHook.java
 * @Description : 스케쥴러 비정상 종료시 스레드 종료전 스케쥴러 shutdown class
 * @Modification 
 * << 개정이력(Modification Information) >>
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
public class CoviShutDownHook implements ServletContextListener
{
	private Logger LOGGER = LogManager.getLogger(CoviShutDownHook.class);

    /**
     * 웹어플리케이션이 종료될때 스케쥴러 shoutdown
     * @param arg0 ServletContextEvent
     * @exception 
     * @return 
     */
    @Override
    public void contextDestroyed(ServletContextEvent arg0)
    {
        try
        {
        	if(CoviApplicationContextUtils.getApplicationContext() != null){
        		
        		BaseQuartzServer qs = (BaseQuartzServer) CoviApplicationContextUtils
        				.getApplicationContext().getBean("quartzServer");

        		Scheduler scheduler = qs.getStdSchedulerFactory().getScheduler();
                scheduler.shutdown(true);
                
                LOGGER.info("stopserver...");
                // Sleep for a bit so that we don't get any errors
                Thread.sleep(1000);
        	}
        }catch (NullPointerException ex){
        	LOGGER.error(ex.getMessage());
        }catch (Exception ex){
        	LOGGER.error(ex.getMessage());
        }
    }

	/**
	 * contextInitialize method
	 * @param arg0 ServletContextEvent
	 * @exception 
	 * @return 
	 */
	@Override
	public void contextInitialized(ServletContextEvent arg0) {
		// TODO Auto-generated method stub
	}

}