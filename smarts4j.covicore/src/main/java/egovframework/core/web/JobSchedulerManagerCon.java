package egovframework.core.web;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.httpclient.NameValuePair;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.quartz.Scheduler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.coviframework.batch.BaseQuartzServer;
import egovframework.coviframework.batch.CoviApplicationContextUtils;
import egovframework.coviframework.batch.CoviBatchUtil;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.JobSchedulerManagerSvc;
import egovframework.core.sevice.SysDomainSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpClientUtil;





@Controller
public class JobSchedulerManagerCon {
	private Logger LOGGER = LogManager.getLogger(JobSchedulerManagerCon.class);
	
	@Autowired
	private JobSchedulerManagerSvc jobSchedulerManagerSvc;
	
	@Autowired
	private SysDomainSvc sysDomainSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	String isRemote = PropertiesUtil.getGlobalProperties().getProperty("quartz.isRemote")==null?"false":PropertiesUtil.getGlobalProperties().getProperty("quartz.isRemote");
	/*
	 * 1. 스케쥴러 등록 시 또는 Y 변경 시
	 * job 등록
	 * 
	 * 2. 스케쥴러 삭제 시 또는 N 변경 시
	 * job 삭제
	 * 
	 * 
	 * 
	 * */
	
	// 페이지 이동
	/**
	 * goJobLogList : 스케줄링 작업 관리 - 작업스케쥴 로그 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "jobloglistpop.do", method = RequestMethod.GET)
	public ModelAndView goJobLogList(HttpServletRequest request, HttpServletResponse response) {
		String strJobID = request.getParameter("JobID");
		
		String returnURL = "core/jobscheduler/jobloglistpop";
		
		ModelAndView mav = new ModelAndView(returnURL);		
		
		mav.addObject("JobID", strJobID);
		
		return mav;
	}
	
	/**
	 * goJobInfo : 스케줄링 작업 관리 - 작업 스케쥴링 정보관리 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "schedulingjobinfopop.do", method = RequestMethod.GET)
	public ModelAndView goJobInfo(HttpServletRequest request, HttpServletResponse response) {		
		String strJobID = request.getParameter("JobID");
		String strDomainID = request.getParameter("DomainID");
		String strMode = request.getParameter("mode");
		
		String returnURL = "core/jobscheduler/schedulingjobinfopop";		
		
		ModelAndView mav = new ModelAndView(returnURL);	
		
		mav.addObject("JobID", strJobID);
		mav.addObject("DomainID", strDomainID);
		mav.addObject("mode", strMode);
		
		return mav;
	}
	
	/**
	 * goClusterInfo : 스케줄링 작업 관리 - 작업 스케쥴링 정보관리 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 
	@RequestMapping(value = "jobclusterinfopop.do", method = RequestMethod.GET)
	public ModelAndView goClusterInfo(HttpServletRequest request, HttpServletResponse response) {		
		String strClusterID = request.getParameter("ClusterID");
		String strMode = request.getParameter("mode");
		
		String returnURL = "core/jobscheduler/jobclusterinfopop";		
		
		ModelAndView mav = new ModelAndView(returnURL);	
		
		mav.addObject("ClusterID", strClusterID);
		mav.addObject("mode", strMode);
		
		return mav;
	}
	*/
	/**
	 * goClusterInfo : 스케줄링 작업 관리 - 작업 스케쥴링 정보관리 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	
	@RequestMapping(value = "serviceagentinfopop.do", method = RequestMethod.GET)
	public ModelAndView goAgentServerInfo(HttpServletRequest request, HttpServletResponse response) {		
		String strAgentServer = request.getParameter("AgentServer");
		String strMode = request.getParameter("mode");
		
		String returnURL = "core/jobscheduler/serviceagentinfopop";		
		
		ModelAndView mav = new ModelAndView(returnURL);	
		
		mav.addObject("AgentServer", strAgentServer);
		mav.addObject("mode", strMode);
		return mav;
	} */
	
	/**
	 * goJobList : 작업 클러스터 관리 - 스케줄링 작업 iframe
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "gojoblist.do", method = RequestMethod.GET)
	public ModelAndView goJobList(HttpServletRequest request, HttpServletResponse response) {		
		String strClusterID = request.getParameter("ClusterID");
		String strIndex = request.getParameter("index");
		
		String returnURL = "core/jobscheduler/jobclustermanage_joblist";		
		
		ModelAndView mav = new ModelAndView(returnURL);	
		
		mav.addObject("ClusterID", strClusterID);
		mav.addObject("index", strIndex);
		
		return mav;
	}
	
	// 스케줄링 작업 관리(목록 조회, 항목 조회, 추가, 수정, 삭제)
	/**
	 * getJobSchedulerList : 스케줄링 작업 관리 - 스케줄링 작업 관리 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@SuppressWarnings("null")
	@RequestMapping(value = "admin/jobscheduler/getjobschedulerlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getJobSchedulerList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "Seq";
		String strSortDirection = "ASC";
		String strPageNo = request.getParameter("pageNo");
		String strPageSize = request.getParameter("pageSize");
		String strIsPaging = request.getParameter("isPaging");

		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
			params.put("pageNo", strPageNo);
			params.put("pageSize", strPageSize);
			params.put("IsPaging", strIsPaging);
			params.put("domain", request.getParameter("domain"));
			
			resultList = jobSchedulerManagerSvc.getJobSchedulerList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", (CoviList) resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
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
	
	/**
	 * getJobSchedulerData : 작업 스케줄링 정보 관리 - 기본정보조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "admin/jobscheduler/getjobschedulerdata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getJobSchedulerData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String JobID  = request.getParameter("JobID");
		
		CoviMap resultMap= new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();

			params.put("JobID", JobID);
			
			resultMap = jobSchedulerManagerSvc.getJobSchedulerData(params);
			
			returnList.put("data", resultMap);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
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
	
	/**
	 * insertJobScheduler : 스케줄링 작업 관리 - 스케줄링 작업 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/jobscheduler/insertschedulingjob.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertJobScheduler(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			//StringUtil.replaceNull(request.getParameter("ProcessID"),""); 
			CoviMap params = new CoviMap();
			params.put("DomainID", request.getParameter("DomainID"));
			CoviMap resultList = sysDomainSvc.selectOne(params);
			CoviMap domainMap = (CoviMap)((CoviList)resultList.get("map")).get(0);

			String  DN_Code = (String)domainMap.get("DomainCode");
			String DomainID  = request.getParameter("DomainID");
			String JobTitle  = request.getParameter("JobTitle");
			String JobType  = request.getParameter("JobType");
			String IsUse  = StringUtil.replaceNull(request.getParameter("IsUse"),"Y");

			String TimeOut  = StringUtil.replaceNull(request.getParameter("TimeOut"),"0");
			String Path  = request.getParameter("Path");
			String Method  = request.getParameter("Method");
			String Params  = "DN_ID="+request.getParameter("DomainID")+"&DN_Code="+DN_Code+"&"+request.getParameter("Params");
			String Description  = request.getParameter("Description");
			
			String ScheduleTitle  = request.getParameter("ScheduleTitle");
//			String ScheduleType  = request.getParameter("ScheduleType");
			
			String UR_Code  = SessionHelper.getSession("UR_Code");
			String reserved1  = request.getParameter("Reserved1");//cron
			
//			String IsDelayRun  = StringUtil.replaceNull(request.getParameter("IsDelayRun"),"Y");
//			String RetryCnt  = StringUtil.replaceNull(request.getParameter("RetryCnt"),"0");
//			String RepeatCnt  = StringUtil.replaceNull(request.getParameter("RepeatCnt"),"0");
			
			params.put("AgentServer"  , "WEB01");
			params.put("DomainID"  , DomainID);
			params.put("EventID"  , 0);		//event에서 상속받는게 아니기 때문에 0으로 세팅
			params.put("JobTitle"  , JobTitle);
			params.put("JobType"  , JobType);
			params.put("IsUse"  , IsUse);
			params.put("TimeOut"  , TimeOut);
			params.put("Seq"  , 0);
			params.put("IsDelayRun"  , "Y");
			params.put("RetryCnt"  , 0);
			params.put("RepeatCnt"  , 0);
			params.put("Path"  , Path);
			params.put("Method"  , Method);
			params.put("Params"  , Params);
			params.put("Description"  , Description);
			params.put("ScheduleTitle"  , ScheduleTitle);
			params.put("ScheduleType"  , "Interval");
			params.put("IntervalSec"  , "60");

			params.put("UR_Code"  , UR_Code);
			params.put("Reserved1"  , reserved1);
			
			/*
			 * quartz 서버 처리
			 * 1. job 생성
			 * 2. trigger 생성
			 * 3. scheduler 시작
			 * */
			CoviMap resultMap = jobSchedulerManagerSvc.insertJobScheduler(params);
			String jobId = resultMap.getString("JobID");
			String schId = resultMap.getString("ScheduleID");
			
			params.put("JobID"  , jobId);
			params.put("ScheduleID"  , schId);

			returnList = setBatchSchedule(params, "add", isDevMode);
			
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * updateJobScheduler : 스케줄링 작업 관리 - 스케줄링 작업 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/jobscheduler/updateschedulingjob.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateJobScheduler(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
 
			//StringUtil.replaceNull(request.getParameter("ProcessID"),""); 
			String JobID  = request.getParameter("JobID");
			String JobTitle  = request.getParameter("JobTitle");
			String JobType  = request.getParameter("JobType");
			String IsUse  = StringUtil.replaceNull(request.getParameter("IsUse"),"Y");
			String ClusterID  = request.getParameter("ClusterID");
			String AgentServer  = request.getParameter("AgentServer");
			String Seq  = StringUtil.replaceNull(request.getParameter("Seq"),"0");
			String TimeOut  = StringUtil.replaceNull(request.getParameter("TimeOut"),"0");
			String IsDelayRun  = StringUtil.replaceNull(request.getParameter("IsDelayRun"),"Y");
			String RetryCnt  = StringUtil.replaceNull(request.getParameter("RetryCnt"),"0");
			String RepeatCnt  = StringUtil.replaceNull(request.getParameter("RepeatCnt"),"0");
			String Path  = request.getParameter("Path");
			String Method  = request.getParameter("Method");
			String Params  = request.getParameter("Params");
			String CommandText  = request.getParameter("CommandText");
			String Description  = request.getParameter("Description");
			String ScheduleID  = request.getParameter("ScheduleID");
			String ScheduleTitle  = request.getParameter("ScheduleTitle");
			String ScheduleType  = request.getParameter("ScheduleType");
			String IntervalSec  = StringUtil.replaceNull(request.getParameter("IntervalSec"),"0");
			String StartDate  = StringUtil.replaceNull(request.getParameter("StartDate"), "0000-00-00 00:00:00");
			String EndDate  = StringUtil.replaceNull(request.getParameter("EndDate"), "0000-00-00 00:00:00");
			String StartHour  = StringUtil.replaceNull(request.getParameter("StartHour"),"0");
			String StartMinute  = StringUtil.replaceNull(request.getParameter("StartMinute"),"0");
			String EndHour  = StringUtil.replaceNull(request.getParameter("EndHour"),"0");
			String EndMinute  = StringUtil.replaceNull(request.getParameter("EndMinute"),"0");
			String RepeatDays  = StringUtil.replaceNull(request.getParameter("RepeatDays"),"0");
			String EveryHour  = StringUtil.replaceNull(request.getParameter("EveryHour"),"0");
			String EveryMinute  = request.getParameter("EveryMinute");
			String[] Weeks = null;
			if(StringUtil.isNotNull(request.getParameter("Weeks"))){
				Weeks  = request.getParameter("Weeks").split(",");
			}
			String RepeatWeeks  = StringUtil.replaceNull(request.getParameter("RepeatWeeks"),"0");
			String WeekOfMonth  = StringUtil.replaceNull(request.getParameter("WeekOfMonth"),"1");
			String[] Months = null;
			if(StringUtil.isNotNull(request.getParameter("Months"))){
				Months = request.getParameter("Months").split(",");
			}
			String[] Days = null;
			if(StringUtil.isNotNull(request.getParameter("Days"))){				
				Days = request.getParameter("Days").split(",");
			}
			String UR_Code  = SessionHelper.getSession("UR_Code");
			String reserved1  = request.getParameter("Reserved1");
			
			CoviMap params = new CoviMap();
		
			params.put("JobID"  , JobID);
			params.put("JobTitle"  , JobTitle);
			params.put("JobType"  , JobType);
			params.put("IsUse"  , IsUse);
			params.put("ClusterID"  , ClusterID);
			params.put("AgentServer"  , AgentServer);
			params.put("Seq"  , Seq);
			params.put("TimeOut"  , TimeOut);
			params.put("IsDelayRun"  , IsDelayRun);
			params.put("RetryCnt"  , RetryCnt);
			params.put("RepeatCnt"  , RepeatCnt);
			params.put("Path"  , Path);
			params.put("Method"  , Method);
			params.put("Params"  , Params);
			params.put("CommandText"  , CommandText);
			params.put("Description"  , Description);
			params.put("ScheduleTitle"  , ScheduleTitle);
			params.put("ScheduleType"  , ScheduleType);
			params.put("IntervalSec"  , IntervalSec);
			params.put("StartDate"  , StartDate);
			params.put("EndDate"  , EndDate);
			params.put("StartHour"  , StartHour);
			params.put("StartMinute"  , StartMinute);
			params.put("EndHour"  , EndHour);
			params.put("EndMinute"  , EndMinute);
			params.put("RepeatDays"  , RepeatDays);
			params.put("EveryHour"  , EveryHour);
			params.put("EveryMinute"  , EveryMinute);
			params.put("Weeks"  , Weeks);			
			params.put("RepeatWeeks"  , RepeatWeeks);
			params.put("WeekOfMonth"  , WeekOfMonth);
			params.put("Months"  , Months);
			params.put("Days"  , Days);
			params.put("UR_Code"  , UR_Code);
			params.put("Reserved1"  , reserved1);
	
			returnList.put("object", jobSchedulerManagerSvc.updateJobScheduler(params));
			params.put("ScheduleID"  , ScheduleID);
			/*
			 * quartz 서버 처리
			 * 1. scheduler 삭제
			 * 2. job 생성
			 * 3. trigger 생성
			 * 4. scheduler 시작
			 * */
			returnList = setBatchSchedule(params, "mod", isDevMode);
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", (isDevMode.equalsIgnoreCase("Y")?"스케쥴러 작동여부 확인":DicHelper.getDic("msg_apv_030")));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", (isDevMode.equalsIgnoreCase("Y") && e.getMessage()!= null) ?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * deleteJobScheduler : 스케줄링 작업 관리 - 스케줄링 작업 삭제
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/jobscheduler/deleteschedulingjob.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteJobScheduler(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		String[] deleteArray  = new String[0];
		ArrayList<String> jobIds = new ArrayList<>();
		CoviMap returnList = new CoviMap();
		
		try {
			if(StringUtil.isNotNull(request.getParameter("DeleteObj"))){
				deleteArray  = request.getParameter("DeleteObj").split(",");
			}
			
			for (int i = 0; i < deleteArray.length; i++) {
				String deleteItem = deleteArray[i];
				jobIds.add(deleteItem.split(":")[0]);
			}
			
			/*
			 * quartz 서버 처리
			 * 1. scheduler 삭제
			 * */
			for (int i = 0; i < deleteArray.length; i++) {
				String deleteItem = deleteArray[i];
				CoviMap paramsQrtz = new CoviMap();
				paramsQrtz.put("JobID"  , deleteItem.split(":")[0]);
				paramsQrtz.put("AgentServer"  , deleteItem.split(":").length>1?deleteItem.split(":")[1]:"");
				returnList = setBatchSchedule(paramsQrtz, "del", isDevMode);
/*				if (isRemote.equals("true")){
					returnList = setRemoteSchedule(params, "del", isDevMode);
				}
				else{
				    CoviBatchUtil.deleteScheduler(deleteItem.split(":")[1], deleteItem.split(":")[0]);
				}    */
			}
			
			CoviMap params = new CoviMap();
			params.put("JobID"  , jobIds);
			returnList.put("object", jobSchedulerManagerSvc.deleteJobScheduler(params));

			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}

	/**
	 * changeIsUseJobScheduler : 스케줄링 작업 관리 - 스케줄링 작업 사용여부 변경
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/jobscheduler/updateisuse_job.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap changeIsUseJobScheduler(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{		 
		String jobID  = request.getParameter("JobID");
		String agentServer  = request.getParameter("AgentServer");
		String isUse  = request.getParameter("IsUse");
		
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
		
			params.put("JobID", jobID);
			params.put("IsUse", isUse);
	
			/*
			 * quartz 서버 처리
			 * 1. job 상태 확인
			 * 2. job stop / resume
			 * */
			params.put("AgentServer"  , agentServer);

			params.put("JobType",request.getParameter("JobType"));
			params.put("Path",request.getParameter("Path"));
			params.put("Method",request.getParameter("Method"));
			params.put("Params",request.getParameter("Params"));
			params.put("ScheduleID",request.getParameter("ScheduleID"));
			params.put("Reserved1",request.getParameter("Reserved1"));
			params.put("TimeOut",request.getParameter("TimeOut"));
			params.put("RetryCnt",request.getParameter("RetryCnt"));
			params.put("RepeatCnt",request.getParameter("RepeatCnt"));
			if(StringUtil.replaceNull(isUse).equalsIgnoreCase("Y")){
				returnList = setBatchSchedule(params, "resume", isDevMode);
				/*if (isRemote.equals("true")){
					returnList = setRemoteSchedule(params,"resume", isDevMode);
				}
				else{
					CoviBatchUtil.resumeJob(agentServer, jobID);
				}	*/
			} else {
				returnList = setBatchSchedule(params, "stop", isDevMode);
				/*if (isRemote.equals("true")){
					returnList = setRemoteSchedule(params,"stop", isDevMode);
				}
				else{
					CoviBatchUtil.stopJob(agentServer, jobID);
				}	
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "저장되었습니다.");*/
			}
			returnList.put("object", jobSchedulerManagerSvc.changeIsUseJobScheduler(params));
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * goJobInfo : 스케줄링 작업 관리 - 작업 스케쥴링 정보관리 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "SchedulingEventInfoPop.do", method = RequestMethod.GET)
	public ModelAndView goEventInfo(HttpServletRequest request, HttpServletResponse response) {		
		String strEventID = request.getParameter("EventID");
		String strMode = request.getParameter("mode");
		
		String returnURL = "core/jobscheduler/SchedulingEventInfoPop";		
		
		ModelAndView mav = new ModelAndView(returnURL);	
		
		mav.addObject("EventID", strEventID);
		mav.addObject("mode", strMode);
		
		return mav;
	}
	
	@RequestMapping(value = "SchedulingEventJobList.do", method = RequestMethod.GET)
	public ModelAndView goSchedulingEventJobList(HttpServletRequest request, HttpServletResponse response) {		
		String strEventID = request.getParameter("EventID");
		String strIsCopy = request.getParameter("IsCopy");
		
		String returnURL = "core/jobscheduler/SchedulingEventJobList";		
		
		ModelAndView mav = new ModelAndView(returnURL);	
		
		mav.addObject("EventID", strEventID);
		mav.addObject("IsCopy", strIsCopy);
		return mav;
	}
	
	// 스케줄링 작업 관리(목록 조회, 항목 조회, 추가, 수정, 삭제)
	/**
	 * getJobSchedulerList : 스케줄링 작업 관리 - 스케줄링 작업 관리 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@SuppressWarnings("null")
	@RequestMapping(value = "admin/jobscheduler/getJobSchedulerEventList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getJobSchedulerEventList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviMap page = new CoviMap();
		
		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "";
		String strSortDirection = "";
		String strPageNo = request.getParameter("pageNo");
		String strPageSize = request.getParameter("pageSize");
		String strIsPaging = request.getParameter("isPaging");

		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		try {
		
			CoviMap params = new CoviMap();
			params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
			
			params.put("pageNo", strPageNo);
			params.put("pageSize", strPageSize);
			params.put("IsPaging", strIsPaging);
			
			params.put("domain", request.getParameter("domain"));
			
			resultList = jobSchedulerManagerSvc.getJobSchedulerEventList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * getJobSchedulerData : 작업 스케줄링 정보 관리 - 기본정보조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "admin/jobscheduler/getJobSchedulerEventData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getJobSchedulerEventData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String EventID  = request.getParameter("EventID");
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();

			params.put("EventID", EventID);
			
			resultList = jobSchedulerManagerSvc.getJobSchedulerEventData(params);
			
			returnList.put("data", resultList.get("data"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * insertJobScheduler : 스케줄링 작업 관리 - 스케줄링 작업 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/jobscheduler/insertJobSchedulerEvent.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertJobSchedulerEvent(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			//StringUtil.replaceNull(request.getParameter("ProcessID"),""); 
			CoviMap params = new CoviMap();
			String JobTitle  = request.getParameter("JobTitle");
			String JobType  = request.getParameter("JobType");
			String IsUse  = StringUtil.replaceNull(request.getParameter("IsUse"),"Y");
			String IsCopy  = StringUtil.replaceNull(request.getParameter("IsCopy"),"Y");
			String AgentServer  = request.getParameter("AgentServer");
			String TimeOut  = StringUtil.replaceNull(request.getParameter("TimeOut"),"0");
			String RetryCnt  = StringUtil.replaceNull(request.getParameter("RetryCnt"),"0");
			String RepeatCnt  = StringUtil.replaceNull(request.getParameter("RepeatCnt"),"0");
			String Path  = request.getParameter("Path");
			String Description  = request.getParameter("Description");
			String ScheduleTitle  = request.getParameter("ScheduleTitle");
			String UR_Code  = SessionHelper.getSession("UR_Code");
			String CronExpr  = request.getParameter("CronExpr");
			
//			CoviMap params = new CoviMap();

			params.put("JobTitle"  , JobTitle);
			params.put("JobType"  , JobType);
			params.put("IsUse"  , IsUse);
			params.put("IsCopy"  , IsCopy);
			params.put("AgentServer"  , AgentServer);
			params.put("TimeOut"  , TimeOut);
			params.put("RetryCnt"  , RetryCnt);
			params.put("RepeatCnt"  , RepeatCnt);
			params.put("Path"  , Path);
			params.put("Description"  , Description);
			params.put("ScheduleTitle"  , ScheduleTitle);
			params.put("CronExpr"  , CronExpr);
			params.put("UR_Code"  , UR_Code);
			
			CoviMap resultMap = jobSchedulerManagerSvc.insertJobSchedulerEvent(params);
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * updateJobScheduler : 스케줄링 작업 관리 - 스케줄링 작업 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/jobscheduler/updateJobSchedulerEvent.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateJobSchedulerEvent(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String EventID  = request.getParameter("EventID");
			String JobTitle  = request.getParameter("JobTitle");
			String JobType  = request.getParameter("JobType");
			String IsUse  = StringUtil.replaceNull(request.getParameter("IsUse"),"Y");
			String AgentServer  = request.getParameter("AgentServer");
			String TimeOut  = StringUtil.replaceNull(request.getParameter("TimeOut"),"0");
			String RetryCnt  = StringUtil.replaceNull(request.getParameter("RetryCnt"),"0");
			String RepeatCnt  = StringUtil.replaceNull(request.getParameter("RepeatCnt"),"0");
			String Path  = request.getParameter("Path");
			String Description  = request.getParameter("Description");
			String ScheduleTitle  = request.getParameter("ScheduleTitle");
			String CronExpr  = request.getParameter("CronExpr");
			String IsCopy  = StringUtil.replaceNull(request.getParameter("IsCopy"),"Y");

			String UR_Code  = SessionHelper.getSession("UR_Code");
			
			CoviMap params = new CoviMap();
		
			params.put("EventID"  , EventID);
			params.put("JobTitle"  , JobTitle);
			params.put("JobType"  , JobType);
			params.put("IsUse"  , IsUse);
			params.put("AgentServer"  , AgentServer);
			params.put("TimeOut"  , TimeOut);
			params.put("RetryCnt"  , RetryCnt);
			params.put("RepeatCnt"  , RepeatCnt);
			params.put("Path"  , Path);
			params.put("Description"  , Description);
			params.put("ScheduleTitle"  , ScheduleTitle);
			params.put("CronExpr"  , CronExpr);
			params.put("IsCopy"  , IsCopy);
			params.put("UR_Code"  , UR_Code);
	
			returnList.put("object", jobSchedulerManagerSvc.updateJobSchedulerEvent(params));
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", (isDevMode.equalsIgnoreCase("Y")?"스케쥴러 작동여부 확인":DicHelper.getDic("msg_apv_030")));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", (isDevMode.equalsIgnoreCase("Y") && e.getMessage()!= null) ?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
//	
	@RequestMapping(value = "admin/jobscheduler/deleteJobSchedulerEvent.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteJobSchedulerEvent(@RequestBody Map<String, Object> paramMap, HttpServletRequest request) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			List jsonObject = (List)paramMap.get("dataList");
			String UR_Code  = SessionHelper.getSession("UR_Code");
			for (int j=0 ; j< jsonObject.size();j++){
				Map map = (Map)jsonObject.get(j);
				String eventId = (String)map.get("EventID");
				
				CoviMap params = new CoviMap();
				params.put("EventID"  , eventId);
				//등록된 스케쥴 가져오기
				CoviList resultList = jobSchedulerManagerSvc.getJobSchedulerEventJobList(params);
				/*
				 * quartz 서버 처리
				 * 1. scheduler 삭제
				 * */
				for (int i = 0; i < resultList.size(); i++) {
					CoviMap deleteItem = (CoviMap)resultList.get(i);
					CoviMap delParams = new CoviMap();
					delParams.put("AgentServer"  , deleteItem.get("AgentServer"));
					delParams.put("JobID"  , deleteItem.get("JobID"));
					if (deleteItem.get("JobState") != null){ 
						returnList = setBatchSchedule(delParams, "del", isDevMode);
					}	
					ArrayList<String> jobIds = new ArrayList<>();
					jobIds.add(deleteItem.getString("JobID"));
					
					delParams.put("JobID"  , jobIds);
					jobSchedulerManagerSvc.deleteJobScheduler(delParams);
				}
				jobSchedulerManagerSvc.deleteJobSchedulerEvent(params);
			}	
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
			return returnList;	
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	// 스케줄링 작업 관리(목록 조회, 항목 조회, 추가, 수정, 삭제)
	/**
	 * getJobSchedulerList : 스케줄링 작업 관리 - 스케줄링 작업 관리 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@SuppressWarnings("null")
	@RequestMapping(value = "admin/jobscheduler/getJobSchedulerEventJob.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getJobSchedulerEventJob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "";
		String strSortDirection = "";
		String strPageNo = request.getParameter("pageNo");
		String strPageSize = request.getParameter("pageSize");
		String strIsPaging = request.getParameter("isPaging");

		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		try {
		
			CoviMap params = new CoviMap();
		
			if (!ComUtils.RemoveSQLInjection(strSortColumn, 100).equals("")){
				params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
			}	
			params.put("pageNo", strPageNo);
			params.put("pageSize", strPageSize);
			params.put("IsPaging", strIsPaging);
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("EventID", request.getParameter("EventID"));
			params.put("IsCopy", request.getParameter("IsCopy"));
			
			resultList = jobSchedulerManagerSvc.getJobSchedulerEventJob(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}

	/**
	 * deleteJobScheduler : 스케줄링 작업 관리 - 스케줄링 작업 등록
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/jobscheduler/insertJobSchedulerEventJob.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertJobSchedulerEventJob(@RequestBody Map<String, Object> paramMap, HttpServletRequest request) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			List jsonObject = (List)paramMap.get("dataList");
			String UR_Code  = SessionHelper.getSession("UR_Code");
			CoviMap params = new CoviMap();
			params.put("dataList"  , jsonObject);
			params.put("UR_Code"  , UR_Code);
			params.put("EventID"  , paramMap.get("EventID"));
			returnList.put("object", jobSchedulerManagerSvc.insertJobSchedulerEventJob(params));
			/*
			 * quartz 서버 처리
			 * 1. scheduler 삭제
			 *
			for (int i = 0; i < deleteArray.length; i++) {
				String deleteItem = deleteArray[i];
				CoviMap paramsQrtz = new CoviMap();
				paramsQrtz.put("AgentServer"  , deleteItem.split(":")[1]);
				paramsQrtz.put("JobID"  , deleteItem.split(":")[0]);
//				returnList = setBatchSchedule(paramsQrtz, "del", isDevMode);

			}
			 */
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	// 스케줄링 작업 로그 조회
	/**
	 * getJobLogList : 스케줄링 작업 관리 - 작업스케쥴 로그 조회 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "admin/jobscheduler/getjobloglist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getJobLogList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String JobID = request.getParameter("JobID");
		String AgentServer = request.getParameter("AgentServer");
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "JobID";
		String strSortDirection = "ASC";
		String strPageNo = request.getParameter("pageNo");
		String strPageSize = request.getParameter("pageSize");

		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		int pageSize = 1;
		int pageNo =  1;
		
		if(strPageNo != null && !strPageNo.equals("0") && strPageNo.length() > 0) {
			pageNo = Integer.parseInt(strPageNo);
		}
		if (strPageSize != null && strPageSize.length() > 0){
			pageSize = Integer.parseInt(strPageSize);	
		}
		
		try {
			CoviMap params = new CoviMap();
		
			params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			params.put("JobID",JobID);
			params.put("AgentServer",AgentServer);
			
			resultList = jobSchedulerManagerSvc.getJobLogList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", (CoviList) resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}	
	
	/**
	 * deleteJobLog : 작업스케쥴로그팝업 - 작업스케쥴로그 삭제
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/jobscheduler/deletejoblog.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteJobLog(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String JobID  = request.getParameter("JobID");
		String AgentServer  = request.getParameter("AgentServer");
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
		
			params.put("JobID", JobID);
			params.put("AgentServer", AgentServer);
							
			returnList.put("object", jobSchedulerManagerSvc.deleteJobLog(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	public CoviMap setBatchSchedule(CoviMap params, String method, String isDevMode){
		String qrtzUrl = PropertiesUtil.getGlobalProperties().getProperty("quartz.url");
		CoviMap returnList = new CoviMap();
		String delay = "60000"; // 60초

		try{
			if (!isRemote.equals("true")){
				params.put("Delay"  , delay);
				params.put("Params",ComUtils.ConvertOutputValue(params.getString("Params")));
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
				
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "저장되었습니다.");
			}
			else{
				String sURL = qrtzUrl + "/covicore/batch/remoteJob/"+method+".do";
				
				NameValuePair[] data = {
					    new NameValuePair("JobID", params.getString("JobID")),
					    new NameValuePair("JobType", params.getString("JobType")),
					    new NameValuePair("AgentServer", params.getString("AgentServer")),
					    new NameValuePair("Path", params.getString("Path")),
					    new NameValuePair("Method", params.getString("Method")),
					    new NameValuePair("Params", URLEncoder.encode(params.getString("Params"), "UTF-8")),
					    new NameValuePair("ScheduleID", params.getString("ScheduleID")),
					    new NameValuePair("Reserved1", params.getString("Reserved1")),
					    new NameValuePair("TimeOut", params.getString("TimeOut")),
					    new NameValuePair("RetryCnt", params.getString("RetryCnt")),
					    new NameValuePair("RepeatCnt", params.getString("RepeatCnt")),
					    new NameValuePair("IsUse", params.getString("IsUse")),
					    new NameValuePair("Delay",delay)
			    };
				
				HttpClientUtil httpClient = new HttpClientUtil();
				CoviMap resultList = httpClient.httpClientConnect(sURL, "furl", "POST", data, 6);
				int status = (int) resultList.get("status");
				String body =  resultList.get("body").toString();
				
				LOGGER.debug(sURL+":"+resultList);
				if (status > 299){
					returnList.put("result", "fail");
					returnList.put("status", Return.FAIL);
					returnList.put("message", (isDevMode.equalsIgnoreCase("Y")&&!body.equals("")?body:DicHelper.getDic("msg_apv_030")));
					return returnList;	
				}
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "저장되었습니다.");
			}	
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "admin/jobscheduler/initQuartServer.do", method = {RequestMethod.POST})	
	public @ResponseBody CoviMap initQuartServer(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
		
			BaseQuartzServer qs = (BaseQuartzServer) CoviApplicationContextUtils
					.getApplicationContext().getBean("quartzServer");

			Scheduler scheduler = qs.getStdSchedulerFactory().getScheduler();
			scheduler.clear();

			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
}
