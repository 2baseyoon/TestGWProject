package egovframework.covision.groupware.attend.user.service.impl;

import javax.annotation.Resource;

import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.attend.user.service.AttendUserStatusSvc;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.service.MessageService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.attend.user.service.AttendPortalSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import egovframework.covision.groupware.attend.user.web.AttendCommonCon;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.FileUtil;

@Service("AttendPortalSvc")
public class AttendPortalSvcImpl extends EgovAbstractServiceImpl implements AttendPortalSvc {
	private static final String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
	private Logger LOGGER = LogManager.getLogger(AttendPortalSvcImpl.class);
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	AttendUserStatusSvc attendUserStatusSvc;

	@Autowired
	private MessageService messageSvc;
	/**
	 * @Method Name : getUserPortal
	 * @Description : 사용자 포탈
	 */
	@Override 
	public CoviMap getUserPortal(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();

		coviMapperOne.update("attend.status.getUserAttWorkTimeProc", params);
		//CoviMap userAttWorkTime  = coviMapperOne.selectOne("attend.status.getUserAttWorkTimeProc", params); //parameter로 return 함.
		CoviMap userSchedule  = coviMapperOne.selectOne("attend.portal.getUserSchedule", params);
		CoviList commuteMstList = coviMapperOne.list("attend.commute.getCommuteMstData", params);
		if(commuteMstList.size()>0){
			resultList.put("resultCommut", commuteMstList.get(0));
		}
		params.put("todayMode", "true");
		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
		CoviList extendList = coviMapperOne.list("attend.portal.getExtensionTarget", params);		
		CoviList callingList = coviMapperOne.list("attend.portal.getCallingTarget", params);

		//resultList.put("userAttWorkTime", userAttWorkTime);
		resultList.put("userAttWorkTime", params);
		resultList.put("userCallingList", callingList);
		resultList.put("userExtendList", extendList);
		resultList.put("userSchedule", userSchedule);
		resultList.put("result", "OK");
		return resultList;
	}
	
	/**
	 * @Method Name : getUserPortal
	 * @Description : 사용자 포탈
	 */
	@Override 
	public CoviMap getUserPortalDay(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();

		coviMapperOne.update("attend.status.getUserAttWorkTimeProc", params);
		//CoviMap userAttWorkTime = coviMapperOne.selectOne("attend.status.getUserAttWorkTimeProc", params); //params로 return
		//resultList.put("userAttWorkTime", userAttWorkTime);
		resultList.put("userAttWorkTime", params);
		resultList.put("result", "OK");
		return resultList;
	}
	
	
	
	/**
	 * @Method Name : getManagerPortal
	 * @Description : 매니저 포탈
	 */
	@Override 
	public CoviMap getManagerPortalDay(CoviMap params, boolean bCompanyToday, boolean bCompanyDay, boolean bDeptDay, boolean bUserDay) throws Exception {
		//회사별 오늘의 근태(출퇴근 누락)
		//회사별 주차별 근태
		//부서별근무 현황
		//내 주차별 근태
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		//회사별 오늘의 근태(출퇴근 누락)
		if (bCompanyToday == true){
			CoviMap companyToday  = coviMapperOne.selectOne("attend.portal.getCompanyToday", params);
			params.put("authMode", "M");
			params.put("todayMode", "true");
			params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));

			CoviMap  companyCallingCnt=  coviMapperOne.selectOne ("attend.portal.getCallingTargetCnt" , params);
			CoviList companyCalling = coviMapperOne.list("attend.portal.getCallingTarget", params);		
			resultList.put("companyToday", companyToday); 
			resultList.put("companyCalling", companyCalling); 
			resultList.put("companyCallingCnt", companyCallingCnt); 
		}	
		
		if (bCompanyDay == true){
			CoviMap companyDay  = coviMapperOne.selectOne("attend.portal.getCompanyDay", params);
			resultList.put("companyDay", companyDay); 
		}	

		if (bDeptDay == true){
			String queryId = "";
			if (params.get("DeptType").equals("D")){	//일간
				queryId = "getDeptAttendList";
			}
			else{	//월간
				queryId = "getDeptAttendDay";
			}

			if (params.get("pageNo") != null && params.get("pageSize") != null){
				int cnt			= 0;
				cnt		= (int) coviMapperOne.getNumber("attend.portal."+queryId+"Cnt" , params);
				page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
				params.addAll(page);
			}

			String DayNightStartTime = RedisDataUtil.getBaseConfig("DayNightStartTime")+"";
			String DayNightEndTime = RedisDataUtil.getBaseConfig("DayNightEndTime")+"";
			if(DayNightStartTime.equals("")){
				DayNightStartTime = RedisDataUtil.getBaseConfig("NightStartTime")+"";
			}
			if(DayNightEndTime.equals("")){
				DayNightEndTime = RedisDataUtil.getBaseConfig("NightEndTime")+"";
			}
			params.put("NightStartDate", DayNightStartTime);
			params.put("NightEndDate", DayNightEndTime);
			params.put("HolNightStartDate", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
			params.put("HolNightEndDate", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
			params.put("ExtNightStartDate", RedisDataUtil.getBaseConfig("NightStartTime"));
			params.put("ExtNightEndDate", RedisDataUtil.getBaseConfig("NightEndTime"));
			
			CoviList deptAttendList  = coviMapperOne.list("attend.portal."+queryId, params);
			resultList.put("deptAttendList", deptAttendList); 
			resultList.put("deptAttendPage",	page);
		}	

		if (bUserDay == true){
			coviMapperOne.update("attend.status.getUserAttWorkTimeProc", params);
			//CoviMap userAttWorkTime  = coviMapperOne.selectOne("attend.status.getUserAttWorkTimeProc", params); //params로 return
			//resultList.put("userAttWorkTime", userAttWorkTime);
			resultList.put("userAttWorkTime", params);
		}	

		resultList.put("result", "OK");
		return resultList;
	}

	/**
	 * @Method Name : getUserPortal
	 * @Description : 사용자 포탈/오늘의 근무제	 */
	@Override 
	public CoviMap getDeptUserAttendList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();

		CoviList deptAttendList  = coviMapperOne.list("attend.portal.getDeptUserAttendList", params);
		for(int i=0; i<deptAttendList.size(); i++) {
			CoviMap tmpMap = (CoviMap) deptAttendList.get(i);
			String vacFlag = tmpMap.getString("VacFlag");
			String vacNames = "";
			List<String> vacNamesArr = new ArrayList<String>();
			if(vacFlag.indexOf("|") > 0) {
				String[] tmpFlag = vacFlag.split("\\|");
				for (int j=0; j<tmpFlag.length; j++) {
					vacNamesArr.add(RedisDataUtil.getBaseCodeDic("VACATION_TYPE", tmpFlag[j], SessionHelper.getSession("lang")));
				}
				vacNames = StringUtils.join(vacNamesArr, "|");
				tmpMap.put("VacFlagName", vacNames);
			}

		}
		resultList.put("data", deptAttendList); 
		return resultList;
	}
	
	@Override 
	public CoviMap getCallingTarget(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list			= new CoviList();

		CoviMap page			= new CoviMap();
		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			CoviMap mapCnt		=  coviMapperOne.selectOne ("attend.portal.getCallingTargetCnt" , params);
			cnt = Integer.parseInt(mapCnt.getString("Cnt"));
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
			params.addAll(page);
		}
		list	= coviMapperOne.list("attend.portal.getCallingTarget", params);	
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList;
	}
	
	@Override 
	public CoviMap sendCallingTarget(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		List list			;

		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
		if (params.get("dataList") == null){
			list	= coviMapperOne.list("attend.portal.getCallingTarget", params);	
		}
		else{
			list    = (List)params.get("dataList");
		}

 		String receiversCode = "";

 		CoviMap mailform =coviMapperOne.selectOne("attend.adminSetting.getAttendMngMst", params);	

		for (int i =0 ; i < list.size(); i++){
			Map newObject = (Map)list.get(i);
			Object jobDate= (Object)newObject.get("JobDate");
			CoviMap sendParams = new CoviMap();
			sendParams.put("ServiceType", "Approval");
			sendParams.put("MsgType", "AttendCallTarget");
			sendParams.put("IsUse", "Y");
			sendParams.put("IsDelay", "N");
	        sendParams.put("ApprovalState", "P");
	        sendParams.put("XSLPath", "");
//	         params.put("Width", "");
//	         params.put("Height", "");
	        sendParams.put("PopupURL", "");
	        sendParams.put("GotoURL", "");
	        sendParams.put("MobileURL", "");
	        sendParams.put("OpenType", "");
	        sendParams.put("MessageContext", "");
	        sendParams.put("ReservedStr1", newObject.get("UserCode"));
	        sendParams.put("ReservedStr2", jobDate);
	        sendParams.put("ReservedStr3", "");
	        sendParams.put("ReservedStr4", "");
	        
			String mailSubject =  mailform.getString("MailTitle").equals("")? "소명대상 안내 -"+jobDate:mailform.getString("MailTitle");
	        String mailContents = setMailForm(jobDate, mailform.getString("MailBody"));
			
	        sendParams.put("SenderCode", params.get("senderCode"));	//발송자
	        sendParams.put("RegistererCode", params.get("senderCode"));
	        sendParams.put("ReceiversCode",newObject.get("UserCode"));//수신자
			
	        sendParams.put("MessagingSubject", mailSubject);
	        sendParams.put("ReceiverText", mailSubject);
	        sendParams.put("MessageContext", mailContents);
			messageSvc.insertMessagingData(sendParams);
		}	
		resultList.put("cnt", list.size());
		return resultList;
	}
	
	private String setMailForm(Object receiverText, String mailBody)  throws Exception {
		String filePath ="";
		String fileContents ="";
		try{
			if(osType.equals("WINDOWS")){
				filePath = RedisDataUtil.getBaseConfig("attendCallEMAIL_Windows");
			} else {
				filePath = RedisDataUtil.getBaseConfig("attendCallEMAIL_Unix");
			}
			fileContents = FileUtil.getFileContents(filePath);
		} catch(NullPointerException e){
			LOGGER.debug(e);
		} catch(Exception e) {
			LOGGER.debug(e);
		}
		StringBuffer sbHTML = new StringBuffer("");
		if (fileContents == null || fileContents.equals("")){
			if (mailBody == null || mailBody.equals("")){
				sbHTML.append("<html xmlns='http://www.w3.org/1999/xhtml'>");
				sbHTML.append("<head><meta http-equiv='Content-Type' content='text/html; charset=utf-8' />");
				sbHTML.append("</head>");
				sbHTML.append("<div style='border:1px solid #c9c9c9; width:1000px; padding-bottom:10px;'>");
				sbHTML.append("<div style='width:100%; height: 50px; background-color : #2b2e34; font-weight:bold; font-size:16px; color:white; line-height:50px; padding-left:20px; box-sizing:border-box;'>");
				sbHTML.append("	CoviSmart² - 소명신청 대상-@@RECEIVE_TEXT@@");
				sbHTML.append("</div>");
				sbHTML.append("<div style='padding: 10px 10px; max-width: 1000px; font-size:13px;'>");
				sbHTML.append("</div>");
			
				sbHTML.append("<div style='padding: 0px 10px; max-width: 1000px;' id='divContextWrap'>");
				sbHTML.append("<div style='padding: 10px 10px; max-width: 1000px; font-size:13px;'>"+
						"<p>안녕하세요. 인사팀입니다.</p>"+
						"<br>"+
						"<p>@@RECEIVE_TEXT@@ 에 소명대상 건이 있어 안내드립니다.</p>"+
						"<p>소명내용 확인 후에 소명신청서 작성 부탁드립니다. (결재선 : 팀장-본부장)</p>"+
						"<br>"+
						"<p>원활한 근태관리를 위해 철저한 근태체크 부탁드립니다.</p>"+
						"<br>"+
						"<p>[참고사항]</p>"+
						"<p>- 실제 지각이 아니었는데 지각으로 뜨는 경우의 대부분은 본사 출근하였는데, 고객사 출근시간으로 셋팅되어 있기 때문입니다.&nbsp;</p>"+
						"<p>&nbsp; 이런 경우에는 본인의 근무일정 시간에 맞게 소명신청 하시길 바랍니다.</p>"+
						"<p>- 업무상 혹은 외근/출장 등으로 인하여 일시적으로 근무시간이 변경된 경우에는, 원래 근무시간에 맞게(9시-18시) 모바일로 출퇴근체크를 해주시기 바랍니다.</p>"+
						"<p>- 고객사 상주 기간 중에 본사에 출근하실 경우, 고객사 근무시간에 맞게 출근체크 해주십시오.</p>"+
						"</div>");
		
				sbHTML.append("</div>");
			}else{
				sbHTML = new StringBuffer(mailBody);
			}
		}	
		else {
			sbHTML = new StringBuffer(fileContents);
		}
		
		return sbHTML.toString().replaceAll("@@RECEIVE_TEXT@@",(String)receiverText);
	}
	
	@Override 
	public CoviMap getUserStatus(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list			= new CoviList();

		CoviMap page			= new CoviMap();
		String sqlId = "getUserCommStatusList";
		if (params.getString("Status").equals("VAC")) sqlId = "getUserVacList"; //휴가이면
			
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("attend.portal."+sqlId+"Cnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
			params.addAll(page);
		}
		list	= coviMapperOne.list("attend.portal."+sqlId, params);	
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList;
	}
	
	
	@Override 
	public CoviMap getAttendDataWebpart(CoviMap userDataObj) throws Exception {

		CoviMap resultList	= new CoviMap();
		CoviMap params = new CoviMap();
		CoviMap myAttStatusParams = new CoviMap();

		String targetDateTime = ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat, 0, userDataObj.getString("UR_TimeZone"));
		String targetDate = ComUtils.GetLocalCurrentDate(ComUtils.UR_DateSimpleFormat, 0, userDataObj.getString("UR_TimeZone"));
		String targetYear = ComUtils.GetLocalCurrentDate("yyyy", 0, userDataObj.getString("UR_TimeZone"));
		String lang = StringUtil.replaceNull(userDataObj.getString("lang"));
		String companyCode = StringUtil.replaceNull(userDataObj.getString("DN_Code"));
		String domainID = StringUtil.replaceNull(userDataObj.getString("DN_ID"));
		String deptCode = StringUtil.replaceNull(userDataObj.getString("DEPTID"));
		String userCode = StringUtil.replaceNull(userDataObj.getString("USERID"));

		CoviList userAttListCodeList = new CoviList();
		CoviMap userAttListUserMap = new CoviMap();
		userAttListUserMap.put("UserCode", userCode);
		userAttListUserMap.put("DeptCode", deptCode);
		userAttListCodeList.add(userAttListUserMap);

		params.put("lang", lang);
		params.put("CompanyCode", companyCode);
		params.put("UR_TimeZone", targetDateTime);
		params.put("UserCode", userCode);

		params.put("DateTerm", "W");
		params.put("TargetDate", targetDate);
		
		params.put("StartDate", targetDate);
		params.put("EndDate", targetDate);
		params.put("domainID", domainID);
		params.put("userCodeList", userAttListCodeList);
		
		params.put("todayMode", "true");
		params.put("authMode", "A");

		String dayScope = coviMapperOne.selectOne("attend.status.getDayScope", params);
		myAttStatusParams.put("UserCode",userCode);
		myAttStatusParams.put("CompanyCode",companyCode);
		myAttStatusParams.put("StartDate", dayScope.split("/")[0]);
		myAttStatusParams.put("EndDate", dayScope.split("/")[1]);
		coviMapperOne.update("attend.status.getUserAttWorkTimeProc", myAttStatusParams);
		resultList.put("myAttStatusMap", myAttStatusParams);

		CoviList userAttList = coviMapperOne.list("attend.status.getUserAttStatus", params);
		if (userAttList.size() == 1) {
			resultList.put("v_AttStartTime",	userAttList.getMap(0).getString("v_AttStartTime"));
			resultList.put("v_AttEndTime",		userAttList.getMap(0).getString("v_AttEndTime"));
		}
		
		resultList.put("callCnt",	coviMapperOne.list("attend.portal.getCallingTarget", params).size());
		
		return resultList;
	}

	@Override
	public CoviMap getDeptAttStatusWebpart(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("attend.portal.getDeptAttStatusWebpart", params);
		resultList.put("list", list);
		
		return resultList;
	}
}
