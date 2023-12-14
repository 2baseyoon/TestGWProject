package egovframework.covision.groupware.attend.user.web;

import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;
import egovframework.covision.groupware.attend.user.service.AttendReqSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import egovframework.covision.groupware.vacation.user.service.VacationSvc;
@Controller
public class AttendReqCon {
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private Logger LOGGER = LogManager.getLogger(AttendReqCon.class);
	
	@Autowired 
	AttendCommonSvc attendCommonSvc;

	@Autowired 
	AttendReqSvc attendReqSvc;

	@Autowired
	VacationSvc vacationSvc;

	//연장관리 요청화면
	@RequestMapping(value = "attendReq/AttendReqOTPopup.do", method = RequestMethod.GET)
	public ModelAndView attendReqOTPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendReqOTPopup";

		ModelAndView mav = new ModelAndView(returnURL);
		String extenUnit = RedisDataUtil.getBaseConfig("ExtenUnit");
		if (extenUnit.equals("") || extenUnit.equals("0")) extenUnit="1";
		mav.addObject("extenUnit", extenUnit);
		mav.addObject("extenRestYn", RedisDataUtil.getBaseConfig("ExtenRestYn"));
		mav.addObject("extenWorkTime", RedisDataUtil.getBaseConfig("ExtenWorkTime"));
		mav.addObject("extenRestTime", RedisDataUtil.getBaseConfig("ExtenRestTime"));
		mav.addObject("extenStartTime", RedisDataUtil.getBaseConfig("ExtenStartTime"));
		mav.addObject("extenStartHour", RedisDataUtil.getBaseConfig("ExtenStartTime").substring(0,2));
		mav.addObject("extenEndTime", RedisDataUtil.getBaseConfig("ExtenEndTime"));
		mav.addObject("extenEndHour", RedisDataUtil.getBaseConfig("ExtenEndTime").substring(0,2));
		mav.addObject("extenMaxTime", RedisDataUtil.getBaseConfig("ExtenMaxTime"));
		mav.addObject("UR_ManagerName", SessionHelper.getSession("UR_ManagerName"));
		
		if (RedisDataUtil.getBaseConfig("ExtenStartTime").equals("0000") && RedisDataUtil.getBaseConfig("ExtenEndTime").equals("0000")){
			mav.addObject("extenEndHour", "23");
		}
		mav.addObject("UR_ManagerName", SessionHelper.getSession("UR_ManagerName"));
		return mav;
	}
	
	//휴일근무 요청화면
	@RequestMapping(value = "attendReq/AttendReqHolidayPopup.do", method = RequestMethod.GET)
	public ModelAndView attendReqHolidayPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendReqHolidayPopup";

		ModelAndView mav = new ModelAndView(returnURL);
		String extenUnit = RedisDataUtil.getBaseConfig("ExtenUnit");
		
		if (extenUnit.equals("") || extenUnit.equals("0")) extenUnit="1";
		mav.addObject("extenUnit", extenUnit);
		mav.addObject("holiRestYn", RedisDataUtil.getBaseConfig("HoliRestYn"));
		mav.addObject("holiWorkTime", RedisDataUtil.getBaseConfig("HoliWorkTime"));
		mav.addObject("holiRestTime", RedisDataUtil.getBaseConfig("HoliRestTime"));
		mav.addObject("extenStartTime", RedisDataUtil.getBaseConfig("ExtenStartTime"));
		mav.addObject("extenStartHour", RedisDataUtil.getBaseConfig("ExtenStartTime").substring(0,2));
		mav.addObject("extenEndTime", RedisDataUtil.getBaseConfig("ExtenEndTime"));
		mav.addObject("extenEndHour", RedisDataUtil.getBaseConfig("ExtenEndTime").substring(0,2));
		mav.addObject("extenMaxTime", RedisDataUtil.getBaseConfig("ExtenMaxTime"));
		mav.addObject("UR_ManagerName", SessionHelper.getSession("UR_ManagerName"));
		
		if (RedisDataUtil.getBaseConfig("ExtenStartTime").equals("0000") && RedisDataUtil.getBaseConfig("ExtenEndTime").equals("0000")){
			mav.addObject("extenEndHour", "23");
		}
		return mav;
	}
	
	//근무상태 요청화면
	@RequestMapping(value = "attendReq/AttendReqJobPopup.do", method = RequestMethod.GET)
	public ModelAndView attendReqJobPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendReqJobPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("authType", request.getParameter("authType"));
		mav.addObject("JobStsSeq", request.getParameter("JobStsSeq"));
		mav.addObject("JobStsName", request.getParameter("JobStsName"));
		mav.addObject("UR_ManagerName", SessionHelper.getSession("UR_ManagerName"));
		return mav;
	}
	
	//휴가신청 요청화면
	@RequestMapping(value = "attendReq/AttendReqVacationPopup.do", method = RequestMethod.GET)
	public ModelAndView attendReqVacationPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendReqVacationPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		
		String VacYear = ComUtils.GetLocalCurrentDate("yyyy");
		CoviMap params = new CoviMap();
		params.put("VacYear", VacYear);
		params.put("UserCode", SessionHelper.getSession("USERID"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		params.put("lang", SessionHelper.getSession("lang"));

		CoviMap req = new CoviMap();
		req.put("CompanyCode", params.getString("CompanyCode"));
		req.put("getName", "CreateMethod");
		String CreateMethod = vacationSvc.getVacationConfigVal(req);
		if(CreateMethod==null || CreateMethod.equals("")){
			CreateMethod = "F";
		}
		CoviMap returnList = new CoviMap();
		if(CreateMethod.equals("J")){
			returnList = attendReqSvc.getVacationInfoV2(params);
		}else {
			returnList = attendReqSvc.getVacationInfo(params);
		}
		
		mav.addObject("VacYear", VacYear);
		mav.addObject("authType", request.getParameter("authType"));
		mav.addObject("UserCode", SessionHelper.getSession("USERID"));
		mav.addObject("vacInfo", returnList.get("data"));
		mav.addObject("UR_ManagerName", SessionHelper.getSession("UR_ManagerName"));

		return mav;
	}
	
	// 소진된 연차 표시 팝업
	@RequestMapping(value = "attendReq/AttendReqUsedVacationPopup.do", method = RequestMethod.GET)
	public ModelAndView attendReqUsedVacationPopup(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		ModelAndView mav = new ModelAndView("user/attend/AttendReqUsedVacationPopup");
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	//소명신청 요청화면
	@RequestMapping(value = "attendReq/AttendReqCallPopup.do", method = RequestMethod.GET)
	public ModelAndView attendReqCallPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendReqCallPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("UR_ManagerName", SessionHelper.getSession("UR_ManagerName"));
		return mav;
	}
			
	//근로일정 요청화면
	@RequestMapping(value = "attendReq/AttendReqSchedulePopup.do", method = RequestMethod.GET)
	public ModelAndView attendReqSchedulePopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendReqSchedulePopup";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("UR_ManagerName", SessionHelper.getSession("UR_ManagerName"));
		
		return mav;
	}
	
	//사용자 지정 템플릿
	@RequestMapping(value = "attendReq/AttendCustomSchedulePopup.do", method = RequestMethod.GET)
	public ModelAndView attendCustomSchedulePopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendCustomSchedulePopup";
		ModelAndView mav = new ModelAndView(returnURL);
		CoviMap reqMap = new CoviMap();
		reqMap.put("ValidYn", "Y");
		reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		reqMap.put("UserCode", SessionHelper.getSession("USERID"));
		reqMap.put("DeptID", SessionHelper.getSession("DEPTID"));

		Object jsonData = attendCommonSvc.getScheduleList(reqMap);
		mav.addObject("list",	jsonData);

		//간주근로 유형
		CoviList assList= attendCommonSvc.getAssList();
		mav.addObject("assList",	assList);
		
		return mav;
	}
	
	//사용자 지정 템플릿 저장

	/**
	* @Method Name : addCustomSchedule
	* @Description : 근무제추가
	*/
	@RequestMapping(value = "attendReq/addCustomSchedule.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap addCustomSchedule(HttpServletRequest request,HttpServletResponse response,	@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("UserCode",		SessionHelper.getSession("UR_Code"));
			params.put("AllocType",		"UR");
			params.put("AllocID",		SessionHelper.getSession("UR_Code"));

			if (params.get("AssSeq").equals("")) params.remove("AssSeq");
			if (params.get("AttDayAC").equals(""))params.put("AttDayAC",		"0");
			if (params.get("AttDayIdle").equals(""))params.put("AttDayIdle",		"0");
			if (params.get("AllowRadius").equals(""))params.put("AllowRadius",		"0");

			returnList  = attendReqSvc.addCustomSchedule(params);
			returnList.put("result", "ok");
			returnList.put("message", "저장");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
		
	
	/**
	* @Method Name : getAttendJob
	* @작성일 : 2019. 7. 1.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 근무제리스트 조회
	* @param request
	* @param response
	* @return
	* @throws Exception
	*/
	@RequestMapping(value = "attendReq/getScheduleList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getScheduleList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("ValidYn", "Y");
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("DeptID", SessionHelper.getSession("DEPTID"));
			params.put("SchName", request.getParameter("SchName"));
			
			Object jsonData = attendCommonSvc.getScheduleList(params);
			returnList.put("list", jsonData);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//요청 목록 데이타 생성
	public List makeRequestList(Map<String, Object> map) throws Exception {
		List ReqData = (List)map.get("ReqData");
		for (int i=0; i <ReqData.size(); i++){
			Map detailMap = (Map)ReqData.get(i);
			
			if(detailMap.get("ReqUserCode") != null && !"".equals(detailMap.get("ReqUserCode").toString())) {
				detailMap.put("UserCode", detailMap.get("ReqUserCode"));
				detailMap.remove("ReqUserCode");
			} else {
				detailMap.put("UserCode", SessionHelper.getSession("USERID"));
			}
			
			if(detailMap.get("ReqUserName") != null && !"".equals(detailMap.get("ReqUserName").toString())) {
				detailMap.put("UrName", URLDecoder.decode(detailMap.get("ReqUserName").toString(), "UTF-8"));
				detailMap.remove("ReqUserName");
			} else {
				detailMap.put("UrName", SessionHelper.getSession("USERNAME"));
			}
			
			detailMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			detailMap.put("Comment", map.get("Comment"));
			
			ReqData.set(i, detailMap);
		}
		return ReqData;
	}
	
	/**
	* @Method Name : requestOverTime
	* @Description : 연장근무신청
	*/
	@RequestMapping(value = "attendReq/requestOverTime.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap requestOverTime(@RequestBody Map<String, Object> map, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			List ReqData = makeRequestList(map);
/*			for (int i=0; i <ReqData.size(); i++){
				Map detailMap = (Map )ReqData.get(i);
				detailMap.put("UserCode", SessionHelper.getSession("USERID"));
				detailMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
				detailMap.put("Comment", map.get("Comment"));
				
				ReqData.set(i, detailMap);
			}*/
			CoviMap params = makeRequestParam("Exten", map);
			
			returnList = attendReqSvc.requestOverTime(params, ReqData, (String)params.get("ReqStatus"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	* @Method Name : requestHoliday
	* @Description : 휴일근무신청
	*/
	@RequestMapping(value = "attendReq/requestHolidayWork.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap requestHolidayWork(@RequestBody Map<String, Object> map, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			List ReqData = makeRequestList(map);
			CoviMap params = makeRequestParam("Holi", map);

			returnList = attendReqSvc.requestHolidayWork(params, ReqData, (String)params.get("ReqStatus"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	* @Method Name : requestVacation
	* @Description : 휴가신청신청
	*/
	@RequestMapping(value = "attendReq/requestVacation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap requestVacation(@RequestBody Map<String, Object> map, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = makeRequestTargetParam("Vac", map);
			
			returnList = attendReqSvc.requestVacation(params, (List)params.get("ReqData"), (String)params.get("ReqStatus"));
			
			// 소진된 연차 조회
			if (params.getString("AuthType").equalsIgnoreCase("ADMIN")) {
				CoviMap vacParams = new CoviMap();
				
				vacParams.put("VacYear", map.get("VacYear"));
				vacParams.put("UserCodeList", params.get("UserCodeList"));
				vacParams.put("lang", SessionHelper.getSession("lang"));
				vacParams.put("CompanyCode", SessionHelper.getSession("DN_Code"));
				
				int usedCnt = attendReqSvc.getUsedVacationListCnt(vacParams);
				
				returnList.put("userCodeList", String.join(";", (ArrayList<String>)params.get("UserCodeList")));
				returnList.put("usedCnt", usedCnt);
			}
			
			if (returnList.get("status") != Return.FAIL) {
				returnList.put("status", Return.SUCCESS);
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	* @Method Name : requestCall
	* @Description : 소명신청
	*/
	@RequestMapping(value = "attendReq/requestCall.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap requestCall(@RequestBody Map<String, Object> map, HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			List ReqData = makeRequestList(map);
			CoviMap params = makeRequestParam("CommuMod", map);
			
			String commuteIp = request.getHeader("X-FORWARDED-FOR");
			if (commuteIp == null){ 
				commuteIp = request.getRemoteAddr(); 
			}
			
			params.put("CommuteIp", commuteIp);

			returnList = attendReqSvc.requestCall(params, ReqData, (String)params.get("ReqStatus"));
		
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}	
	
	/**
	* @Method Name : requestSchedule
	* @Description : 근무일정신청
	*/
	@RequestMapping(value = "attendReq/requestSchedule.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap requestSchedule(@RequestBody Map<String, Object> map, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			List ReqData = makeRequestList(map);
			CoviMap params = makeRequestParam("Work", map);

			returnList = attendReqSvc.requestSchedule(params, ReqData, (String)params.get("ReqStatus"));
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}	
	
	/**
	* @Method Name : requestSchedule
	* @Description : 근무일정신청
	*/
	@RequestMapping(value = "attendReq/requestScheduleRepeat.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap requestScheduleRepeat(@RequestBody Map<String, Object> map, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			List ReqData = makeRequestList(map);
			CoviMap params = makeRequestParam("Work", map);

			returnList = attendReqSvc.requestScheduleRepeat(params, ReqData, (String)params.get("ReqStatus"));

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	* @Method Name : requestJobStatus
	* @Description : 근무상태신청
	*/
	@RequestMapping(value = "attendReq/requestJobStatus.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap requestJobStatus(@RequestBody Map<String, Object> map, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = makeRequestTargetParam("", map);
			
			returnList = attendReqSvc.requestJobStatus(params, (List)params.get("ReqData"), (String)params.get("ReqStatus"));
			
			if (returnList.get("status") != Return.FAIL) {
				returnList.put("status", Return.SUCCESS);
			}
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	//요청 테이블 용 데이타 생성
	public CoviMap makeRequestParam(String ReqCd, Map<String, Object> map){
		CoviMap params = new CoviMap();
		List ReqData = (List)map.get("ReqData");
		
		String ReqType = (String)map.get("ReqType");
		String ReqGubun = (String)map.get("ReqGubun");
		String ReqMethod = "";
		String ReqTitle = "";
		if (ReqType.equals("J"))		 {
			ReqTitle = getRequestTitle(ReqType, ReqGubun, (String)((Map)ReqData.get(0)).get("JobStsName"));
			try{
				CoviMap reqParams = new CoviMap();
				reqParams.put("ValidYn", "Y");
				reqParams.put("JobStsSeq", (String)((Map)ReqData.get(0)).get("JobStsSeq"));
				CoviList jobList = attendCommonSvc.getOtherJobList(reqParams); 
				
				if (jobList.size()>0){
					switch (ReqGubun)
					{
						case "C":				ReqMethod = (String)((CoviMap)jobList.get(0)).get("ReqMethod");break;
						case "U":				ReqMethod = (String)((CoviMap)jobList.get(0)).get("UpdMethod");break;
						case "D":				ReqMethod = (String)((CoviMap)jobList.get(0)).get("DelMethod");break;
						default : break;
					}
				}	
			} catch(NullPointerException e){
				ReqMethod = "Request";
			} catch(Exception e){
				ReqMethod = "Request";
			}
		}
		else {
			ReqTitle = getRequestTitle(ReqType, ReqGubun);
			ReqMethod = getReqMethod(ReqCd, ReqGubun);
		}
		
		String reqUserName = ((Map)ReqData.get(0)).get("UrName") != null && !"".equals(((Map)ReqData.get(0)).get("UrName").toString()) ? ((Map)ReqData.get(0)).get("UrName").toString() : SessionHelper.getSession("UR_Name");
		ReqTitle = ReqTitle + "_" + reqUserName + "("+(((Map)ReqData.get(0)).get("WorkDate")!=null?((Map)ReqData.get(0)).get("WorkDate"):((Map)ReqData.get(0)).get("StartDate"))+")";
		String ReqStatus = "ApprovalRequest";
		
		if (ReqMethod.equals("None")){	//승인없음이면
			ReqStatus = "Approval";
		}
		
		params.put("ReqType", ReqType);
		params.put("ReqGubun", ReqGubun);
		params.put("ReqMethod", ReqMethod);
		
		params.put("UserCode", SessionHelper.getSession("USERID"));
		params.put("UrName", SessionHelper.getSession("UR_Name"));
		params.put("RegisterCode", SessionHelper.getSession("USERID"));
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		params.put("ReqTitle", ReqTitle);
		params.put("ReqStatus", ReqStatus);
		String reqDataStr = AttendUtils.getJsonArrayFromList(ReqData).toString();
		reqDataStr = reqDataStr.replace("\"","\\\"");
		params.put("ReqDataStr",reqDataStr);
		params.put("Comment", map.get("Comment"));
		return params;
	}
	
	// 대상자 데이터 포함된 파라미터 데이터 생성
	public CoviMap makeRequestTargetParam(String ReqCd, Map<String, Object> map){
		CoviMap params = new CoviMap();
		List ReqData = (List)map.get("ReqData");
		
		String ReqType = (String)map.get("ReqType");
		String ReqGubun = (String)map.get("ReqGubun");
		String ReqMethod = "";
		String ReqTitle = "";
		String authType = map.get("AuthType") == null ? "USER" : (String)map.get("AuthType");
		
		if (ReqType.equals("J")) {
			ReqTitle = getRequestTitle(ReqType, ReqGubun, (String)((Map)ReqData.get(0)).get("JobStsName"));
			
			try {
				CoviMap reqParams = new CoviMap();
				reqParams.put("ValidYn", "Y");
				reqParams.put("JobStsSeq", ((Map)ReqData.get(0)).get("JobStsSeq"));
				
				CoviList jobList = attendCommonSvc.getOtherJobList(reqParams); 
				
				if (jobList.size() > 0) {
					switch (ReqGubun) {
						case "C": ReqMethod = (String)((CoviMap)jobList.get(0)).get("ReqMethod"); break;
						case "U": ReqMethod = (String)((CoviMap)jobList.get(0)).get("UpdMethod"); break;
						case "D": ReqMethod = (String)((CoviMap)jobList.get(0)).get("DelMethod"); break;
						default : break;
					}
				}
			} catch(NullPointerException e) {
				ReqMethod = "Request";
			} catch(Exception e) {
				ReqMethod = "Request";
			}
		} else {
			ReqTitle = getRequestTitle(ReqType, ReqGubun);
			ReqMethod = getReqMethod(ReqCd, ReqGubun);
		}
		
		String ReqStatus = "ApprovalRequest";
		
		if (ReqMethod.equals("None")) {	//승인없음이면
			ReqStatus = "Approval";
		}
		
		params.put("ReqType", ReqType);
		params.put("ReqGubun", ReqGubun);
		params.put("ReqMethod", ReqMethod);
		params.put("ReqStatus", ReqStatus);
		params.put("ReqTitle", ReqTitle);
		
		params.put("AuthType", authType);
		params.put("Comment", map.get("Comment"));
		params.put("RegisterCode", SessionHelper.getSession("USERID"));
		params.put("UserCode", SessionHelper.getSession("USERID"));
		params.put("UrName", SessionHelper.getSession("USERNAME"));
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		params.put("DomainID", SessionHelper.getSession("DN_ID"));
		
		List<Map<String, Object>> reqTargetList = new ArrayList<>();
		Map<String, Object> targetMap = null;
		
		if (authType.equals("ADMIN")) {
			List TargetData = (List)map.get("TargetData");
			List<Map<String, Object>> reqDataList = new ArrayList<>();
			
			CoviList targetUserList = attendReqSvc.getTargetUserList(TargetData);
			ArrayList<String> userCodeList = new ArrayList<>();
			
			params.put("ReqMethod", "None");
			params.put("ReqStatus", "Approval");
			
			for (int i = 0; i < targetUserList.size(); i++) {
				List<Map<String, Object>> reqTempList = new ArrayList<>();
				CoviMap targetUser = targetUserList.getJSONObject(i);
				targetMap = new HashMap<>();
				
				// ReqData Deep Copy
				for (int j = 0; j < ReqData.size(); j++) {
					Map<String, Object> tempMap = new HashMap<>();
					tempMap.putAll((Map)ReqData.get(j));
					reqTempList.add(tempMap);
				}
				
				String subReqTitle = String.format("%s_%s(%s)", ReqTitle, targetUser.getString("Name"), ((reqTempList.get(0)).get("WorkDate") != null ? (reqTempList.get(0)).get("WorkDate") : (reqTempList.get(0)).get("StartDate")));
				
				// ReqData 수정
				for (int j = 0; j < reqTempList.size(); j++) {
					Map detailMap = reqTempList.get(j);
					detailMap.put("UserCode", targetUser.getString("Code"));
					detailMap.put("UrName", targetUser.getString("Name"));
					detailMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
					detailMap.put("Comment", map.get("Comment"));
					detailMap.put("ReqTitle", subReqTitle);
					
					reqTempList.set(j, detailMap);
				}
				
				targetMap.put("UserCode", targetUser.getString("Code"));
				targetMap.put("UrName", targetUser.getString("Name"));
				targetMap.put("CompanyCode", targetUser.getString("Domain"));
				targetMap.put("ReqTitle", subReqTitle);
				String reqDataStr = AttendUtils.getJsonArrayFromList(reqTempList).toString();
				reqDataStr = reqDataStr.replace("\"","\\\"");
				targetMap.put("ReqDataStr", reqDataStr);
				
				userCodeList.add(targetUser.getString("Code"));
				reqTargetList.add(targetMap);
				reqDataList.addAll(reqTempList);
			}
			
			params.put("UserCodeList", userCodeList);
			params.put("ReqData", reqDataList);
		} else {
			targetMap = new HashMap<>();
			
			// ReqData 수정
			for (int i = 0; i < ReqData.size(); i++) {
				Map detailMap = (Map)ReqData.get(i);
				detailMap.put("UserCode", SessionHelper.getSession("USERID"));
				detailMap.put("UrName", SessionHelper.getSession("USERNAME"));
				detailMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
				detailMap.put("Comment", map.get("Comment"));
				
				ReqData.set(i, detailMap);
			}
			
			String subReqTitle = String.format("%s_%s(%s)", ReqTitle, SessionHelper.getSession("USERNAME"), (((Map)ReqData.get(0)).get("WorkDate") != null ? ((Map)ReqData.get(0)).get("WorkDate") : ((Map)ReqData.get(0)).get("StartDate")));
			
			targetMap.put("UserCode", SessionHelper.getSession("USERID"));
			targetMap.put("UrName", SessionHelper.getSession("USERNAME"));
			targetMap.put("ReqTitle", subReqTitle);
			String reqDataStr = AttendUtils.getJsonArrayFromList(ReqData).toString();
			reqDataStr = reqDataStr.replace("\"","\\\"");
			targetMap.put("ReqDataStr", reqDataStr);
			
			reqTargetList.add(targetMap);
			params.put("ReqData", ReqData);
		}
		
		params.put("ReqTargetList", reqTargetList);
		
		return params;
	}
	
	public String getRequestTitle(String reqType, String reqGubun, String reqName){
		String requestTitle = "신청서";
		try {
			requestTitle =reqName+ " " + RedisDataUtil.getBaseCodeDic("AttendReqGubun", reqGubun, "ko") + " "+	requestTitle; //RedisDataUtil.getBaseCodeDic()+" 신청서";
		} catch (NullPointerException e){
			LOGGER.warn(e.getLocalizedMessage(), e);
		} catch (Exception e){
			LOGGER.warn(e.getLocalizedMessage(), e);
		}
		return requestTitle;
	}
	
	public String getRequestTitle(String reqType, String reqGubun){
		String requestTitle = "신청서";
		try {
			requestTitle =RedisDataUtil.getBaseCodeDic("AttendReqType", reqType, "ko")+ " " + RedisDataUtil.getBaseCodeDic("AttendReqGubun", reqGubun, "ko") + " "+	requestTitle; //RedisDataUtil.getBaseCodeDic()+" 신청서";
		} catch (NullPointerException e){
			LOGGER.warn(e.getLocalizedMessage(), e);
		} catch (Exception e){
			LOGGER.warn(e.getLocalizedMessage(), e);
		}
		return requestTitle;
	}
	
	public String getReqMethod(String ReqCd, String ReqGubun){
		String key ;
		if (!ReqCd.equals("Work")){
			key = ReqCd+(ReqGubun.equals("U")?"Upd":(ReqGubun.equals("D")?"Del":"Req"))+"Method";
		}
		else{
			switch (ReqGubun){
				case "U":key= "WorkModMethod";break;
				case "D":key= "WorkDelMethod";break;
				default: key= "WorkReqMethod";break;
			}
		}
		//System.out.println(key);
		String ReqMethod = RedisDataUtil.getBaseConfig(key);
		//System.out.println(key+":"+ReqMethod);
		if (ReqMethod.equals("")) ReqMethod = "Request";
		return ReqMethod;
	}
	
	/**
	* @Method Name : requestCommute
	* @Description : 근무지 외 지역에서 출퇴근 승인 요청하는 경우
	*/
	@RequestMapping(value = "attendReq/requestCommute.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap requestCommute(@RequestBody CoviMap params, HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviList reqDataList = params.getJSONArray("ReqData");
			CoviMap reqData = reqDataList.getJSONObject(0);
			
			String ReqType = params.getString("ReqType");
			String ReqCd = "Att"; // "A".equals(params.getString("ReqType"))
			String ReqStatus = "ApprovalRequest";
			
			String commuteIp = request.getHeader("X-FORWARDED-FOR");
			if (commuteIp == null){ 
				commuteIp = request.getRemoteAddr(); 
			}
			
			if("L".equals(ReqType)) {
				ReqCd = "Leave";
			}
			
			String ReqGubun = params.getString("ReqGubun");
			String ReqTitle = getRequestTitle(ReqType, ReqGubun); // 요청관리에 제목으로 들어갈 데이터
			String ReqMethod = getReqMethod(ReqCd, ReqGubun);
			
			if(ReqMethod.equals("None")) { // 요청관리 승인없음
				ReqStatus = "Approval";
			} else if(ReqMethod.equals("Disable")) { // 요청관리 사용안함
				ReqStatus = "ApprovalDeny";
			}

			ReqTitle = ReqTitle+"_"+SessionHelper.getSession("UR_Name") + "(" + (reqData.get("WorkDate")!=null?reqData.getString("WorkDate"):reqData.getString("StartDate")) + ")";
			
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("UrName", SessionHelper.getSession("UR_Name"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("ReqTitle", ReqTitle);
			params.put("ReqStatus", ReqStatus);
			params.put("ReqMethod", ReqMethod);
			params.put("CommuteIp", commuteIp);
			
			String reqDataStr = reqDataList.toString();
			reqDataStr = reqDataStr.replace("\"","\\\"");
			
			params.put("ReqDataStr", reqDataStr);
			
			returnList = attendReqSvc.requestCommute(params, reqData);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	* @Method Name : getVacationInfo
	* @Description : 휴가 정보 조회
	*/
	@RequestMapping(value = "attendReq/getVacationInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationInfo(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String CompanyCode = request.getParameter("domain");
			if(CompanyCode==null || CompanyCode.equals("")){
				CompanyCode = SessionHelper.getSession("DN_Code");
			}
			params.put("UserCode", request.getParameter("code"));
			params.put("CompanyCode", CompanyCode);
			params.put("VacYear", request.getParameter("vacYear"));
			params.put("VacFlag", request.getParameter("vacFlag"));
			params.put("lang",SessionHelper.getSession("lang"));

			CoviMap req = new CoviMap();
			req.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			req.put("getName", "CreateMethod");
			String CreateMethod = vacationSvc.getVacationConfigVal(req);
			if(CreateMethod==null || CreateMethod.equals("")){
				CreateMethod = "F";
			}

			if(CreateMethod.equals("J")) {
				returnList = attendReqSvc.getVacationInfoV2(params);
			}else{
				returnList = attendReqSvc.getVacationInfo(params);
			}
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * @Method Name : getUsedVacationList
	 * @Description : 소진된 휴가 목록 조회
	 */
	@RequestMapping(value = "attendReq/getUsedVacationList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUsedVacationList(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			String sortColumn = StringUtil.isNotNull(sortBy) ? sortBy.split(" ")[0] : "";
			String sortDirection = StringUtil.isNotNull(sortBy) ? sortBy.split(" ")[1] : "";
			String userCodeList = StringUtil.replaceNull(request.getParameter("userCodeList"), "");
			CoviMap params = new CoviMap();
			
			params.put("VacYear", request.getParameter("vacYear"));
			params.put("UserCodeList", userCodeList.split(";"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			returnList = attendReqSvc.getUsedVacationList(params);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * @Method Name : downloadUsedVacExcel
	 * @Description : 엑셀 다운로드
	 */
	@RequestMapping(value = "attendReq/downloadUsedVacExcel.do", method = RequestMethod.GET)
	public ModelAndView downloadUsedVacExcel(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		
		try {
			String returnURL = "UtilExcelView";
			String[] headerNames = StringUtil.replaceNull(request.getParameter("headerName"), "").split("†");
			String[] headerKeys = StringUtil.replaceNull(request.getParameter("headerKey"), "").split(",");
			String userCodeList = StringUtil.replaceNull(request.getParameter("userCodeList"), "");
			
			
			CoviMap params = AttendUtils.requestToCoviMap(request);
			CoviMap viewParams = new CoviMap();
			
			params.put("VacYear", request.getParameter("vacYear"));
			params.put("UserCodeList", userCodeList.split(";"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(request.getParameter("sortColumn"), 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(request.getParameter("sortDirection"), 100));
			
			CoviMap resultList = attendReqSvc.getUsedVacationList(params);
			CoviList cList = (CoviList)resultList.get("list");
			
			viewParams.put("list", CoviSelectSet.coviSelectJSON(cList, request.getParameter("headerKey")));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("headerKey",	headerKeys);
			viewParams.put("title", request.getParameter("title"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}
}
