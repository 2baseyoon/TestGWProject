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
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import egovframework.coviframework.batch.CoviApplicationContextUtils;
import egovframework.batch.service.CoviJobSvc;
import egovframework.baseframework.data.CoviMap;

import java.util.StringTokenizer;
//job 수행시 jobdatamap 의 내용 변경
@PersistJobDataAfterExecution 
//동시성 문제(race conditions)의 우려
@DisallowConcurrentExecution
public class ProcedureJobServiceImpl implements Job {
	
	public static final Logger LOGGER = LogManager.getLogger(ProcedureJobServiceImpl.class);
	
	@Override
	@Transactional(isolation=Isolation.DEFAULT, propagation=Propagation.REQUIRES_NEW)
	public void execute(JobExecutionContext context) throws JobExecutionException {
		ApplicationContext appCtx = CoviApplicationContextUtils.getApplicationContext();
		CoviJobSvc jobSvc = (CoviJobSvc)appCtx.getBean("jobService");
		//LOGGER.info("Procedure Job start.....");
		JobDataMap dataMap = context.getJobDetail().getJobDataMap();
		JobKey dataKey = context.getJobDetail().getKey();
		CoviMap param = new CoviMap();
		String procName = dataMap.getString("procName");

		param.addAll(dataMap);
		param.put("agentServer", dataKey.getGroup());
		param.put("jobID", dataKey.getName().replace("JOB_", ""));
		String paramString = dataMap.getString("procParameter");
		
		if (paramString != null){
			StringTokenizer stk=new StringTokenizer(paramString,"&");
			while(stk.hasMoreTokens()){
				String stkStr = stk.nextToken();
				if(stkStr.contains("=")){
					String[] tokens=stkStr.split("=");
					if(tokens.length==2) {
						String token0 = tokens[0];
						String token1 = tokens[1];
						if (token0 != null && !token0.equals("") && token1 != null && !token1.equals("")) {
							param.put(token0, token1);
						}
					}
				}
			}
		}	

		try {
			int flag = jobSvc.callProc(procName, param);
			
			//스케쥴 히스토리 데이터 INSERT
			param.put("isSuccess", "SUCCESS");
			jobSvc.createJobHistory(param);
		} catch (NullPointerException e) {
			LOGGER.error(e);
			try {
				param.put("isSuccess", "FAIL");
				String message= e.getMessage();
    			if (message != null ){
    				int iSize = 	300-10;
    				param.put("message", (message.length()>iSize)?message.substring(0,iSize)+"...":message);
    			}
				jobSvc.createJobHistory(param);
			} catch (NullPointerException e1) {
				LOGGER.error(e1);
			} catch (Exception e1) {
				LOGGER.error(e1);
			}
		} catch (Exception e) {
			LOGGER.error(e);
			try {
				param.put("isSuccess", "FAIL");
				String message= e.getMessage();
    			if (message != null ){
    				int iSize = 	300-10;
    				param.put("message", (message.length()>iSize)?message.substring(0,iSize)+"...":message);
    			}
				jobSvc.createJobHistory(param);
			} catch (NullPointerException e1) {
				LOGGER.error(e1);
			} catch (Exception e1) {
				LOGGER.error(e1);
			}
		}
	}
	
	
}
