package egovframework.batch.service.impl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.quartz.DisallowConcurrentExecution;
import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.JobKey;
import org.quartz.PersistJobDataAfterExecution;
import org.springframework.context.ApplicationContext;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.batch.CoviApplicationContextUtils;
import egovframework.batch.service.CoviJobSvc;
import egovframework.coviframework.util.HttpURLConnectUtil;

//job 수행시 jobdatamap 의 내용 변경
@PersistJobDataAfterExecution 
//동시성 문제(race conditions)의 우려
@DisallowConcurrentExecution
public class WebServiceJobServiceImpl implements Job {
	
	public static final Logger LOGGER = LogManager.getLogger(WebServiceJobServiceImpl.class);
	
	@Override
	public void execute(JobExecutionContext context) throws JobExecutionException {
				
		try {
			final JobExecutionContext _context = context;
        	try {
        		ApplicationContext appCtx = CoviApplicationContextUtils.getApplicationContext();
    			CoviJobSvc jobSvc = (CoviJobSvc)appCtx.getBean("jobService");
    			
        		JobDataMap dataMap = _context.getJobDetail().getJobDataMap();
        		JobKey dataKey = _context.getJobDetail().getKey();
    			String url = dataMap.getString("wsURL");
    			String paramString = dataMap.getString("wsParameter");
    			CoviMap params = new CoviMap();
    			
    			sendPost(url, paramString, params, Integer.parseInt(dataMap.getString("timeout")));		//Job Method, Proc, URL 호출
    			
    			params.addAll(dataMap);
    			params.put("agentServer", dataKey.getGroup());
    			params.put("jobID", dataKey.getName().replace("JOB_", ""));
    			if (params.get("message") != null ){
    				int iSize = 	300-10;
        			params.put("message", (((String)params.get("message")).length()>iSize)?((String)params.get("message")).substring(0,iSize)+"...":(String)params.get("message"));
    			}
    			//스케쥴 히스토리 데이터 INSERT
    			jobSvc.createJobHistory(params);
			}
        	catch (NullPointerException e1) {
				LOGGER.error(e1.getLocalizedMessage(), e1);
				throw e1;
			}
        	catch (Exception e1) {
        		LOGGER.error(e1.getLocalizedMessage(), e1);
				throw e1;
			}

		} catch (NullPointerException e) {
			throw new JobExecutionException(e);
		} catch (Exception e) {
			throw new JobExecutionException(e);
		}
	}
	
	private void sendPost(String urlString, String inputParamString, CoviMap params, int readTime) {
		try {
			HttpURLConnectUtil url = new HttpURLConnectUtil();
    		readTime = readTime *1000;
			if (readTime < 10000) readTime = 10000;
			
			url.httpURLConnect(urlString, "POST", 15000, readTime, inputParamString, "");
			params.setConvertJSONObject(false);
			params.put("isSuccess", url.getResponseType());
			params.put("message", url.getResponseMessage());
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
    		LOGGER.error(e.getLocalizedMessage(), e);
		}
	}
}
