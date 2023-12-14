package egovframework.batch.web;


import static org.quartz.TriggerBuilder.newTrigger;

import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.Enumeration;

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
import org.quartz.impl.matchers.KeyMatcher;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.coviframework.batch.CoviApplicationContextUtils;
import egovframework.coviframework.batch.CoviBatchUtil;
import egovframework.coviframework.batch.CoviJobListener;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.batch.base.CoviQuartzServer;
import egovframework.batch.service.CoviJobSvc;
import egovframework.core.sevice.JobSchedulerManagerSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpURLConnectUtil;

import java.net.URLDecoder;


@Controller
public class CoviJobCon {
	private Logger LOGGER = LogManager.getLogger(CoviJobCon.class);
	
	@Autowired
	private JobSchedulerManagerSvc jobSchedulerManagerSvc;
	
	@Autowired
	private CoviJobSvc jobSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "batch/testAPI.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap testAPI(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String jobID  = request.getParameter("JobID");
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			@SuppressWarnings({ "rawtypes" })
			Enumeration Eparams = request.getParameterNames();

			while(Eparams.hasMoreElements())
			{
				String strParamName = (String) Eparams.nextElement();
				//System.out.println("key=" + strParamName + ", value="+request.getParameter(strParamName));
			}
		
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다:"+jobID);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	
	@RequestMapping(value = "batch/remoteJob/{method}", method={RequestMethod.POST})
	public void addRemoteJob(HttpServletResponse response, HttpServletRequest request, @PathVariable String method) throws Exception
	{
		CoviMap params = new CoviMap();
		params.put("JobID",request.getParameter("JobID"));
		params.put("AgentServer",request.getParameter("AgentServer"));
		params.put("JobType",request.getParameter("JobType"));
		params.put("Path",request.getParameter("Path"));
		params.put("Method",request.getParameter("Method"));
		params.put("Params",ComUtils.ConvertOutputValue(URLDecoder.decode(request.getParameter("Params"),"UTF-8")));
		params.put("ScheduleID",request.getParameter("ScheduleID"));
		params.put("Reserved1",request.getParameter("Reserved1"));
		params.put("TimeOut",request.getParameter("TimeOut"));
		params.put("RetryCnt",request.getParameter("RetryCnt"));
		params.put("RepeatCnt",request.getParameter("RepeatCnt"));
		params.put("Delay",request.getParameter("Delay"));
		params.put("IsUse",request.getParameter("IsUse"));
		
		switch (method){
			case "add":
				if(params.getString("IsUse").equalsIgnoreCase("Y")){
					CoviBatchUtil.addScheduler(params);
				}	
				break;
			case "mod":
				CoviBatchUtil.deleteScheduler(params.getString("AgentServer"), params.getString("JobID"));
				if(params.getString("IsUse").equalsIgnoreCase("Y")){
					CoviBatchUtil.addScheduler(params);
				}	
				break;
			case "del":
				CoviBatchUtil.deleteScheduler(params.getString("AgentServer"), params.getString("JobID"));
				break;
			case "stop":
				CoviBatchUtil.stopJob(params.getString("AgentServer"), params.getString("JobID"));
				break;
			case "resume":		
				CoviBatchUtil.resumeJob(params);
				break;
				
			default : 
				break;
		}
		
/*		CoviBatchUtil.addScheduler(params);*/
	}
	
/*	@RequestMapping(value = "batch/remoteJob/mod.do", method={RequestMethod.POST})
	public void modRemoteJob(HttpServletResponse response, HttpServletRequest request) throws Exception
	{
		CoviMap params = new CoviMap();
		params.put("JobID",request.getParameter("JobID"));
		params.put("AgentServer",request.getParameter("AgentServer"));
		params.put("JobType",request.getParameter("JobType"));
		params.put("Path",request.getParameter("Path"));
		params.put("Method",request.getParameter("Method"));
		params.put("Params",ComUtils.ConvertOutputValue(URLDecoder.decode(request.getParameter("Params"),"UTF-8")));
		params.put("ScheduleID",request.getParameter("ScheduleID"));
		params.put("Reserved1",request.getParameter("Reserved1"));
		params.put("TimeOut",request.getParameter("TimeOut"));
		params.put("RetryCnt",request.getParameter("RetryCnt"));
		params.put("RepeatCnt",request.getParameter("RepeatCnt"));
		params.put("Delay","60000");

		CoviBatchUtil.deleteScheduler(params.getString("AgentServer"), params.getString("JobID"));
		CoviBatchUtil.addScheduler(params);
	}
	
	@RequestMapping(value = "batch/remoteJob/del.do", method={RequestMethod.POST})
	public void delRemoteJob(HttpServletResponse response, HttpServletRequest request) throws Exception
	{

		String JobID  		= request.getParameter("JobID");
		String AgentServer  = request.getParameter("AgentServer");
		CoviBatchUtil.deleteScheduler(AgentServer, JobID);
	}
	
	@RequestMapping(value = "batch/remoteJob/stop.do", method={RequestMethod.POST})
	public void stopRemoteJob(HttpServletResponse response, HttpServletRequest request) throws Exception
	{

		String JobID  		= request.getParameter("JobID");
		String AgentServer  = request.getParameter("AgentServer");
		CoviBatchUtil.stopJob(AgentServer, JobID);
	}
	
	@RequestMapping(value = "batch/remoteJob/resume.do", method={RequestMethod.POST})
	public void resumeRemoteJob(HttpServletResponse response, HttpServletRequest request) throws Exception
	{

		String JobID  		= request.getParameter("JobID");
		String AgentServer  = request.getParameter("AgentServer");
		//CoviBatchUtil.resumeJob(AgentServer, JobID);
	}
	*/
	/**
	 * getJobSchedulerData : 작업 스케줄링 정보 관리 - 기본정보조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "batch/startJob.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap startJob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String jobID  = request.getParameter("JobID");
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			initJob();
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	@RequestMapping(value = "batch/stopJob.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap stopJob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String jobID  = request.getParameter("JobID");
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			stopJob();
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch(SchedulerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	@RequestMapping(value = "batch/deleteJob.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteJob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String jobID  = request.getParameter("JobID");
		String agentID  = request.getParameter("AgentID");
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviBatchUtil.deleteScheduler(agentID, jobID);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch(SchedulerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	// 관리자페이지에서 수동실행용으로 활용
	@RequestMapping(value = "batch/callProc.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap callProc(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String procName  = request.getParameter("ProcName");
		
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		for(Entry<String, String> entry : paramMap.entrySet()) {
			params.put(entry.getKey(), entry.getValue());
		}
		try {
			jobSvc.callProc(procName, params);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "처리되었습니다");
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	// 관리자페이지에서 수동실행용으로 활용
	@RequestMapping(value = "batch/callWebservice.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap callWebservice(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String JobID  = request.getParameter("JobID");
		
		CoviMap returnList = new CoviMap();
		CoviMap params= new CoviMap();
		params.put("JobID", JobID);
		CoviMap dataMap = jobSchedulerManagerSvc.getJobSchedulerData(params);
		
		
		String sendUrl = dataMap.getString("Path");
		String inputParamString = dataMap.getString("Params");
		int readTime =  Integer.parseInt(dataMap.getString("TimeOut"));
		
		readTime = readTime *1000;
		if (readTime < 10000) readTime = 10000;
				
		try {
			HttpURLConnectUtil url = new HttpURLConnectUtil();

			CoviMap result = url.httpURLConnect(sendUrl, "POST", 15000, readTime, inputParamString, "");
			if (url.getResponseType().equals("SUCCESS")){
				returnList.put("status", Return.SUCCESS);
			}	
			else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", "["+result.get("ResultState")+"]"+ result.get("ResponseMsg"));
			}
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e);
		}
		
		return returnList;
		
	}
	
	private void initJob(){
		
		try {
			/*
			 * initInfo = {
			 * 	jobInfo : {
			 * 		jobGroup : "",
			 * 		jobKey : "",
			 * 		jobClass : ""
			 * 	},
			 * 	triggerInfo : {
			 * 		triggerGroup : "",
			 * 		triggerName : "",
			 * 		triggerTimer : ""
			 * 	},
			 * 	delay : ""
			 * 	timeout : "",
			 * 	retryCount : "",
			 * 	repeatCount : ""
			 * 
			 * }
			 * */
			
			String vJobKey = ""; // 고유 스케쥴 키
			String vJobGroup = ""; // 스케쥴 그룹
			String vJobClass = ""; // 스케쥴 잡 클래스

			String vTrgName = ""; // 트리거 이름
			String vTrgGroup = "";
			String vTrgTimer = ""; // 트리거 시간 설정
			
			//jobinf.properties에서 가져온 값 셋팅
			vJobKey = "SendMessage";
			vJobGroup = "MessageService";
			vJobClass = "egovframework.batch.service.impl.WebServiceJobServiceImpl";

			vTrgName = "cronTrigger";
			vTrgGroup = "Work";
			vTrgTimer = "0 0/1 * * * ?"; //매 1분마다 실행

			JobKey jobKey = new JobKey(vJobKey, vJobGroup);
			Class jobClass;
			jobClass = Class.forName(vJobClass);
			
			//5번 재시도 실패시재실행은 exception에 있고 try안에 강제exception발생시키면됨
			JobDataMap cm2 = new JobDataMap();
			
			//totalCount : 총 메일수
			//minCount : 한번에 보낼 메일수
			//delayTime : 한번 메일 보낸후 지연시간
			JobDetail jobDetail = JobBuilder.newJob(jobClass)
					.withIdentity(jobKey)
					.usingJobData("delayTime", 10)
					.usingJobData("totalCount", 6)
					.usingJobData("repeatCount", 3)
					.usingJobData("timeout", 3000)
					.usingJobData("count", 2)
					.usingJobData("minCount", 3).build();
			
			Trigger trigger = newTrigger().withIdentity(vTrgName, vTrgGroup)
					.startNow().withPriority(3)
					.withSchedule(CronScheduleBuilder.cronSchedule(vTrgTimer))
					.build();
			
			// 스프링 빈 가져오기 & casting
			CoviQuartzServer qs = (CoviQuartzServer) CoviApplicationContextUtils
					.getApplicationContext().getBean("quartzServer");
			
			Scheduler scheduler = qs.getStdSchedulerFactory().getScheduler();
			//Listener attached to jobKey
	    	scheduler.getListenerManager().addJobListener(
	    		new CoviJobListener(), KeyMatcher.keyEquals(jobKey));
	    		
			if (!scheduler.checkExists(jobDetail.getKey()))
			{
				scheduler.scheduleJob(jobDetail, trigger);
				//LOGGER.info("start : MessageService.SendMessage");
				//System.out.println("start : MessageService.SendMessage");
			}
			else{
				//System.out.println("checkExist() : true");
			}			
			
		}
		catch(SchedulerException e) {
			LOGGER.error(e);
		}
		catch (Exception e) {
			LOGGER.error(e);
		}
		
	}
	
	private void stopJob() throws SchedulerException{
		CoviQuartzServer qs = (CoviQuartzServer) CoviApplicationContextUtils
				.getApplicationContext().getBean("quartzServer");

		Scheduler scheduler = qs.getStdSchedulerFactory().getScheduler();
		scheduler.deleteJob(new JobKey("JOB_86", "AGENT_DEVWEB"));
		//System.out.println("stop job");
	}
	
}
