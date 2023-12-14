package egovframework.coviframework.batch;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.quartz.CronScheduleBuilder;
import org.quartz.JobBuilder;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.JobKey;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.Trigger;
import org.quartz.TriggerBuilder;
import org.quartz.impl.matchers.KeyMatcher;

import egovframework.baseframework.data.CoviMap;

public class CoviBatchUtil {

	private static final Logger LOGGER = LogManager.getLogger(CoviBatchUtil.class);
	private static final String JOB_GROUP_PREFIX = "AGENT_";
	private static final String JOB_NAME_PREFIX = "JOB_";
	private static final String TRIGGER_NAME_PREFIX = "TRIGGER_";
	
	/*
	 * initInfo = {
	 * 	jobInfo : {
	 * 		jobType : "",
	 * 		jobGroup : "", // "AGENT_" + agent id 
	 * 		jobName : "", //  "JOB_" + job id
	 * 		jobClass : "",
	 * 		webServiceURL : "",
	 * 		webServiceMethodName : "",
	 * 		procedureName : ""
	 * 	},
	 * 	triggerInfo : {
	 * 		triggerGroup : "", // "JOB_" + job id
	 * 		triggerName : "", // "TRIGGER_" + schedule id
	 * 		triggerTimer : ""
	 * 	},
	 * 	delay : "0"
	 * 	timeout : "",
	 * 	retryCount : "",
	 * 	repeatCount : ""
	 * 	
	 * 
	 * }
	 * */
	
	public static CoviMap setScheduleInfo(CoviMap jobInfo, CoviMap triggerInfo, String delay, String timeout, String retryCount, String repeatCount){
		CoviMap scheduleInfo = new CoviMap();
		scheduleInfo.put("jobInfo", jobInfo);
		scheduleInfo.put("triggerInfo", triggerInfo);
		scheduleInfo.put("delay", delay);
		scheduleInfo.put("timeout", timeout);
		scheduleInfo.put("retryCount", retryCount);
		scheduleInfo.put("repeatCount", repeatCount);
		
		return scheduleInfo;
	}
	
	public static CoviMap setWebServiceJobInfo(String jobType, String agentId, String jobId, String url, String methodName, String paramString){
		CoviMap jobInfo = new CoviMap();
		jobInfo.put("jobType", jobType);
		jobInfo.put("jobGroup", JOB_GROUP_PREFIX + agentId);
		jobInfo.put("jobName", JOB_NAME_PREFIX + jobId);
		jobInfo.put("jobClass", "egovframework.batch.service.impl.WebServiceJobServiceImpl");
		jobInfo.put("wsURL", url);
		jobInfo.put("wsMethodName", methodName);
		jobInfo.put("wsParameter", paramString);
		
		return jobInfo;
	}
	
	public static CoviMap setProcedureJobInfo(String jobType, String agentId, String jobId, String procedureName, String paramString){
		CoviMap jobInfo = new CoviMap();
		jobInfo.put("jobType", jobType);
		jobInfo.put("jobGroup", JOB_GROUP_PREFIX + agentId);
		jobInfo.put("jobName", JOB_NAME_PREFIX + jobId);
		jobInfo.put("jobClass", "egovframework.batch.service.impl.ProcedureJobServiceImpl");
		jobInfo.put("procName", procedureName);
		jobInfo.put("procParameter", paramString);
		
		return jobInfo;
	}
	
	public static CoviMap setTriggerInfo(String jobId, String scheduleId, String triggerTimer){
		CoviMap triggerInfo = new CoviMap();
		triggerInfo.put("triggerGroup", JOB_NAME_PREFIX + jobId);
		triggerInfo.put("triggerName", TRIGGER_NAME_PREFIX + scheduleId);
		triggerInfo.put("triggerTimer", triggerTimer);
		
		return triggerInfo;
	}
	
	public static void initScheduler(CoviMap scheduleInfo) throws Exception{
		
		if(scheduleInfo != null){
			CoviMap jobInfo = scheduleInfo.getJSONObject("jobInfo");
			//JSONObject triggerInfo = scheduleInfo.getJSONObject("triggerInfo");
			
			JobKey jobKey = new JobKey(jobInfo.getString("jobName"), jobInfo.getString("jobGroup"));
			Class jobClass;
			jobClass = Class.forName(jobInfo.getString("jobClass"));
			
			//job
			JobDetail jobDetail = JobBuilder.newJob(jobClass)
					.withIdentity(jobKey)
					.usingJobData("delay", scheduleInfo.getString("delay"))
					.usingJobData("timeout", scheduleInfo.getString("timeout"))
					.usingJobData("retryCount", scheduleInfo.getString("retryCount"))
					.usingJobData("repeatCount", scheduleInfo.getString("repeatCount"))
					.build();
			
			JobDataMap jobDataMap=  jobDetail.getJobDataMap();
			String jobType = jobInfo.getString("jobType");
			if(jobType.equalsIgnoreCase("WebService")){
				jobDataMap.put("wsURL", jobInfo.getString("wsURL"));
				jobDataMap.put("wsMethodName", jobInfo.getString("wsMethodName"));
				jobDataMap.put("wsParameter", jobInfo.getString("wsParameter"));
			} else if(jobType.equalsIgnoreCase("Procedure")){
				jobDataMap.put("procName", jobInfo.getString("procName"));
				jobDataMap.put("procParameter", jobInfo.getString("procParameter"));
			}
			
			//trigger
			Trigger trigger = initTrigger(scheduleInfo);
			
			// 스프링 빈 가져오기 & casting
			BaseQuartzServer qs = (BaseQuartzServer) CoviApplicationContextUtils
					.getApplicationContext().getBean("quartzServer");
			
			Scheduler scheduler = qs.getStdSchedulerFactory().getScheduler();
			//Listener attached to jobKey
	    	scheduler.getListenerManager().addJobListener(
	    		new CoviJobListener(), KeyMatcher.keyEquals(jobKey));
	    		
			if (!scheduler.checkExists(jobDetail.getKey()))
			{
				scheduler.scheduleJob(jobDetail, trigger);
				//System.out.println("start job : " + jobInfo.getString("jobName"));
			}
			else{
				//System.out.println("duplicated job.");
			}
		}
		
	}
	
	public static Trigger initTrigger(CoviMap scheduleInfo){
		//JSONObject jobInfo = scheduleInfo.getJSONObject("jobInfo");
		CoviMap triggerInfo = scheduleInfo.getJSONObject("triggerInfo");
		
		TriggerBuilder<Trigger> builder = TriggerBuilder.newTrigger()
				.withIdentity(triggerInfo.getString("triggerName"), triggerInfo.getString("triggerGroup"));
		
		if (scheduleInfo.has("delay")) {
			builder.startAt(new java.util.Date(System.currentTimeMillis() + Long.parseLong(scheduleInfo.getString("delay"))));
	    } else {
	    	builder.startAt(new java.util.Date(System.currentTimeMillis() + 60000*5)); //기본 delay 1분
	    }

	    //if (opts.has(UNTIL)) {
	    //    builder.endAt(opts.getDate(UNTIL));
	    //}

		if (triggerInfo.has("triggerTimer")) {
	        builder.withSchedule(CronScheduleBuilder.cronSchedule(triggerInfo.getString("triggerTimer")));
	    }/* else if (opts.has(EVERY)) {
	        SimpleScheduleBuilder schedule =
	                SimpleScheduleBuilder.simpleSchedule()
	                        .withIntervalInMilliseconds(opts.getInt(EVERY));
	        if (opts.has(LIMIT)) {
	            schedule.withRepeatCount(opts.getInt(LIMIT) - 1);
	        } else {
	            schedule.repeatForever();
	        }
	        builder.withSchedule(schedule);
	    }*/

	    return builder.build();
	}
	
	public static void addScheduler(CoviMap params) throws SchedulerException{
		//job 생성 분기 처리 - webservice, procedure
		String  JobID = params.getString("JobID");
		String  JobType = params.getString("JobType");
		String  AgentServer = params.getString("AgentServer");
		String  TimeOut = params.getString("TimeOut" );
		String  Path = params.getString("Path" );
		String  Method = params.getString("Method");
		String  Params = params.getString("Params");
		String  ScheduleID = params.getString("ScheduleID" );
		String  Reserved1 = params.getString("Reserved1");
		String  RetryCnt = params.getString("RetryCnt"  );
		String  RepeatCnt = params.getString("RepeatCnt");
		String  Delay = params.getString("Delay");
		try{
			CoviMap jobInfo = null;
			if(JobType.equalsIgnoreCase("WebService")){
				jobInfo = setWebServiceJobInfo(JobType, AgentServer, JobID, Path, Method, Params);
			} else if(JobType.equalsIgnoreCase("Procedure")){
				jobInfo = setProcedureJobInfo(JobType, AgentServer, JobID, Path, Params);
			}
			CoviMap triggerInfo = setTriggerInfo(JobID, ScheduleID, Reserved1);
			CoviMap scheduleInfo = setScheduleInfo(jobInfo, triggerInfo, Delay, TimeOut, RetryCnt, RepeatCnt);
			initScheduler(scheduleInfo);
		} catch (java.io.IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}		
	
	public static void deleteScheduler(String agentId, String jobId) throws SchedulerException{
		BaseQuartzServer qs = (BaseQuartzServer) CoviApplicationContextUtils
				.getApplicationContext().getBean("quartzServer");

		Scheduler scheduler = qs.getStdSchedulerFactory().getScheduler();
		scheduler.deleteJob(new JobKey(JOB_NAME_PREFIX + jobId, JOB_GROUP_PREFIX + agentId));
		//System.out.println("deleteJob : " + JOB_NAME_PREFIX + jobId);
	}
	
	public static void stopJob(String agentId, String jobId) throws SchedulerException{
		BaseQuartzServer qs = (BaseQuartzServer) CoviApplicationContextUtils
				.getApplicationContext().getBean("quartzServer");

		Scheduler scheduler = qs.getStdSchedulerFactory().getScheduler();
		scheduler.pauseJob(new JobKey(JOB_NAME_PREFIX + jobId, JOB_GROUP_PREFIX + agentId));
		//System.out.println("stopJob : " + JOB_NAME_PREFIX + jobId);
	}
	
	public static void resumeJob(CoviMap params) throws SchedulerException{
		String  JobID = params.getString("JobID");
		String  AgentServer = params.getString("AgentServer");
		
		BaseQuartzServer qs = (BaseQuartzServer) CoviApplicationContextUtils
				.getApplicationContext().getBean("quartzServer");

		Scheduler scheduler = qs.getStdSchedulerFactory().getScheduler();
		//qurt에 없으면 생성하기
		if (scheduler.checkExists(new JobKey(JOB_NAME_PREFIX + JobID, JOB_GROUP_PREFIX + AgentServer))){
			scheduler.resumeJob(new JobKey(JOB_NAME_PREFIX + JobID, JOB_GROUP_PREFIX + AgentServer));
		}
		else{
			addScheduler(params);
		}
	}
	
}
