package egovframework.covision.groupware.attend.user.web;

import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.LogHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.attend.user.service.AttendClosedDayStatusSvc;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;

@Controller
@RequestMapping("/attendClosedDaySts")
public class AttendClosedDayStatusCon {
	
	LogHelper logHelper = new LogHelper();
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@Autowired
	AttendCommonSvc attendCommonSvc;
	
	@Autowired
	AttendClosedDayStatusSvc attendClosedDayStatusSvc;
	 
	/**
	  * @Method Name : getClosedDayAttendance
	  * @작성일 : 2021. 7. 27.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 휴무일 근무자 현황
	  * @param request
	  * @param response
	  * @return
	  */
	@SuppressWarnings("unchecked")
	@RequestMapping( value= "/getClosedDayAttendance.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getClosedDayAttendance(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		String stDate = request.getParameter("stDate");
		String edDate = request.getParameter("edDate");
		
		String groupPath = request.getParameter("groupPath");		
		String sUserTxt = request.getParameter("sUserTxt");
		String sJobTitleCode = request.getParameter("sJobTitleCode");
		String sJobLevelCode = request.getParameter("sJobLevelCode");
		
		String companyCode = SessionHelper.getSession("DN_Code");
		String lang = SessionHelper.getSession("lang");		
		String normalWork = request.getParameter("normalWork");
		
		try{						
			CoviMap params = new CoviMap();
			
			params.put("stDate", stDate);
			params.put("edDate", edDate);	
			
			CoviList header = attendClosedDayStatusSvc.getClosedDayHeader(params);			
			
			ArrayList<String> headerList = new ArrayList<String>();			
			for(int i = 0; i < header.size(); i++) {
				headerList.add(header.getMap(i).get("Header").toString());
			}
			
			params.put("headerList", headerList);
			params.put("CompanyCode", companyCode);
			params.put("GroupPath", groupPath);			
			params.put("lang", lang);
			
			params.put("sUserTxt", sUserTxt);
			params.put("sJobTitleCode", sJobTitleCode);
			params.put("sJobLevelCode", sJobLevelCode);
			
			params.put("normalWork", normalWork);
				
			CoviList attClosedDayList = attendClosedDayStatusSvc.getClosedDayAttendance(params);
			
			returnObj.put("loadCnt", attClosedDayList.size());
			returnObj.put("header", header);
			returnObj.put("data", attClosedDayList);
			returnObj.put("status", Return.SUCCESS);
		} catch(NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch(Exception e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		}
		
		return returnObj;
	}
	
	/**
	  * @Method Name : getClosedDayPlan
	  * @작성일 : 2021. 7. 29.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 휴무일 근무계획
	  * @param request
	  * @param response
	  * @return
	  */
	@SuppressWarnings("unchecked")
	@RequestMapping( value= "/getClosedDayPlan.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getClosedDayPlan(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		String stDate = request.getParameter("stDate");
		String edDate = request.getParameter("edDate");
		
		String groupPath = request.getParameter("groupPath");		
		String sUserTxt = request.getParameter("sUserTxt");
		String sJobTitleCode = request.getParameter("sJobTitleCode");
		String sJobLevelCode = request.getParameter("sJobLevelCode");
		
		String companyCode = SessionHelper.getSession("DN_Code");
		String lang = SessionHelper.getSession("lang");
		
		try{						
			CoviMap params = new CoviMap();
			
			params.put("stDate", stDate);
			params.put("edDate", edDate);
			
			CoviList header = attendClosedDayStatusSvc.getClosedDayHeader(params);
			
			ArrayList<String> headerList = new ArrayList<String>();			
			for(int i = 0; i < header.size(); i++) {
				headerList.add(header.getMap(i).get("Header").toString());
			}
			
			params.put("headerList", headerList);
			params.put("CompanyCode", companyCode);
			params.put("GroupPath", groupPath);			
			params.put("lang", lang);
			
			params.put("sUserTxt", sUserTxt);
			params.put("sJobTitleCode", sJobTitleCode);
			params.put("sJobLevelCode", sJobLevelCode);
				
			CoviList attClosedDayPlanList = attendClosedDayStatusSvc.getClosedDayPlan(params);
			
			returnObj.put("loadCnt", attClosedDayPlanList.size());
			returnObj.put("header", header);
			returnObj.put("data", attClosedDayPlanList);
			
			CoviList attClosedDayPlanStatusList = attendClosedDayStatusSvc.getClosedDayPlanStatus(params);
			
			returnObj.put("loadStsCnt", attClosedDayPlanStatusList.size());
			returnObj.put("dataSts", attClosedDayPlanStatusList);			
			returnObj.put("status", Return.SUCCESS);
		} catch(NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch(Exception e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		}
		
		return returnObj;
	}

}
