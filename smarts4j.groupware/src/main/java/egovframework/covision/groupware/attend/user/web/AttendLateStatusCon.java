package egovframework.covision.groupware.attend.user.web;

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
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;
import egovframework.covision.groupware.attend.user.service.AttendLateStatusSvc;

@Controller
@RequestMapping("/attendLateSts")
public class AttendLateStatusCon {
	
	LogHelper logHelper = new LogHelper();
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@Autowired
	AttendCommonSvc attendCommonSvc;
	
	@Autowired
	AttendLateStatusSvc attendLateStatusSvc;
	 
	/**
	  * @Method Name : getLateAttendance
	  * @작성일 : 2021. 7. 23.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 개인별 지각현황
	  * @param request
	  * @param response
	  * @return
	  */
	@SuppressWarnings("unchecked")
	@RequestMapping( value= "/getLateAttendance.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLateAttendance(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		String targetYear = request.getParameter("targetYear"); 
		String groupPath = request.getParameter("groupPath");		
		String sUserTxt = request.getParameter("sUserTxt");
		String sJobTitleCode = request.getParameter("sJobTitleCode");
		String sJobLevelCode = request.getParameter("sJobLevelCode");		
		String companyCode = SessionHelper.getSession("DN_Code");
		String lang = SessionHelper.getSession("lang");
		
		try{						
			CoviMap params = new CoviMap();
			
			params.put("TargetYear", targetYear);
			params.put("CompanyCode", companyCode);
			params.put("GroupPath", groupPath);			
			params.put("lang", lang);
			
			params.put("sUserTxt", sUserTxt);
			params.put("sJobTitleCode", sJobTitleCode);
			params.put("sJobLevelCode", sJobLevelCode);
			
			CoviList attLateList = attendLateStatusSvc.getLateAttendance(params);
			
			returnObj.put("loadCnt", attLateList.size());
			returnObj.put("data", attLateList);
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
	  * @Method Name : getMonthlyLateAttendance
	  * @작성일 : 2021. 8. 3.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 월별 지각현황
	  * @param request
	  * @param response
	  * @return
	  */
	@SuppressWarnings("unchecked")
	@RequestMapping( value= "/getMonthlyLateAttendance.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMonthlyLateAttendance(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		String targetMonth = request.getParameter("targetMonth"); 
		String groupPath = request.getParameter("groupPath");		
		String sUserTxt = request.getParameter("sUserTxt");
		String sJobTitleCode = request.getParameter("sJobTitleCode");
		String sJobLevelCode = request.getParameter("sJobLevelCode");
		
		String companyCode = SessionHelper.getSession("DN_Code");
		String lang = SessionHelper.getSession("lang");
		
		try{						
			CoviMap params = new CoviMap();
			
			params.put("TargetMonth", targetMonth);
			params.put("CompanyCode", companyCode);
			params.put("GroupPath", groupPath);			
			params.put("lang", lang);
			
			params.put("sUserTxt", sUserTxt);
			params.put("sJobTitleCode", sJobTitleCode);
			params.put("sJobLevelCode", sJobLevelCode);
				
			CoviList attMonthlyLateList = attendLateStatusSvc.getMonthlyLateAttendance(params);
			
			returnObj.put("loadCnt", attMonthlyLateList.size());
			returnObj.put("data", attMonthlyLateList);
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
