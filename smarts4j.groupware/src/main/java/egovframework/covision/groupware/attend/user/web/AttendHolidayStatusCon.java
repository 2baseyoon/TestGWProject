package egovframework.covision.groupware.attend.user.web;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.LogHelper;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;
import egovframework.covision.groupware.attend.user.service.AttendHolidayStatusSvc;

@Controller
@RequestMapping("/attendHolidaySts")
public class AttendHolidayStatusCon {
	
	LogHelper logHelper = new LogHelper();
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@Autowired
	AttendCommonSvc attendCommonSvc;
	
	@Autowired
	AttendHolidayStatusSvc attendHolidayStatusSvc;
	 
	/**
	  * @Method Name : getHolidayAttendance
	  * @작성일 : 2021. 7. 21.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 휴일 근무자 현황
	  * @param request
	  * @param response
	  * @return
	  */
	@SuppressWarnings("unchecked")
	@RequestMapping( value= "/getHolidayAttendance.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getHolidayAttendance(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		String targetDate = request.getParameter("targetDate"); 
		String groupPath = request.getParameter("groupPath");		
		String sUserTxt = request.getParameter("sUserTxt");
		String sJobTitleCode = request.getParameter("sJobTitleCode");
		String sJobLevelCode = request.getParameter("sJobLevelCode");		
		String companyCode = SessionHelper.getSession("DN_Code");
		String lang = SessionHelper.getSession("lang");
		
		try{						
			CoviMap params = new CoviMap();
			
			params.put("TargetDate", targetDate);
			params.put("CompanyCode", companyCode);
			params.put("GroupPath", groupPath);			
			params.put("lang", lang);
			
			params.put("sUserTxt", sUserTxt);
			params.put("sJobTitleCode", sJobTitleCode);
			params.put("sJobLevelCode", sJobLevelCode);
				
			CoviList attHolidayList = attendHolidayStatusSvc.getHolidayAttendance(params);
			
			returnObj.put("loadCnt", attHolidayList.size());
			returnObj.put("data", attHolidayList);
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
	
	@RequestMapping(value="/getUserDayOffDate.do", method = RequestMethod.GET)
	public @ResponseBody CoviMap getUserDayOffDate() {
		CoviMap returnObj = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("userCode", SessionHelper.getSession("UR_Code"));
		params.put("companyCode", SessionHelper.getSession("DN_Code"));
		
		SimpleDateFormat format = new SimpleDateFormat("yyyy");
		
		Calendar StartTempCal = Calendar.getInstance();
		params.put("StandardStartDate", format.format(StartTempCal.getTime()) + "-01-01");
		
		Calendar EndTempCal = Calendar.getInstance();
		EndTempCal.add(Calendar.YEAR, +1);
		params.put("StandardEndDate", format.format(EndTempCal.getTime()) + "-12-31");
		
		try {
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("dayOffInfo", attendHolidayStatusSvc.getUserDayOffDate(params));
		} catch (DataAccessException e) {
			returnObj.put("status", Return.FAIL);
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			logHelper.getCurrentClassErrorLog(e);
		}
		
		return returnObj;
	}
}