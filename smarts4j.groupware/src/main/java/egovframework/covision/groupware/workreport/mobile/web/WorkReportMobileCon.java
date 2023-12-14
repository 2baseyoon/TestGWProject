package egovframework.covision.groupware.workreport.mobile.web;

import java.text.SimpleDateFormat;
import java.util.Calendar;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.workreport.mobile.service.WorkReportMobileService;
import egovframework.covision.groupware.workreport.service.WorkReportTimeCardService;
import egovframework.covision.groupware.workreport.util.WorkReportUtils;


@Controller
@RequestMapping("/workreport/mobile")
public class WorkReportMobileCon {
	
	private Logger LOGGER = LogManager.getLogger(WorkReportMobileCon.class);
	
	@Autowired
	private WorkReportMobileService workReportMobileService;				// mobile Srv
	
	@Autowired
	private WorkReportTimeCardService workReportTimeCardService;			// timeCard Srv
	
	@RequestMapping(value="MobileWorkReport.do", method=RequestMethod.GET)
	public ModelAndView mobileWorkReport(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String strWorkReportID = "";
		String strMode = "";
		String strCalID = request.getParameter("calid");
		String strUserCode = SessionHelper.getSession("UR_Code");
				
		int calendarId = 0;
		if(strCalID!=null && !strCalID.isEmpty())
			calendarId = Integer.parseInt(strCalID);
				 
		// 차후 작업스케쥴러로 옮겨야 하는 부분
		// 주차 생성 코드 시작
		if(calendarId == 0) {
			CoviMap params = new CoviMap();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
					
			Calendar recFridayInfo = WorkReportUtils.getRecentFridayInfo(Calendar.getInstance());
			
			// 해당일자로 시작하는 데이터 있는지 검증
			params.put("Year", recFridayInfo.get(Calendar.YEAR));
			params.put("Month", recFridayInfo.get(Calendar.MONTH) + 1);
			params.put("Day", recFridayInfo.get(Calendar.DAY_OF_MONTH));
			params.put("WeekOfMonth", recFridayInfo.get(Calendar.WEEK_OF_MONTH));
			params.put("StartDate", sdf.format(recFridayInfo.getTime()));
			
			recFridayInfo.add(Calendar.DAY_OF_MONTH, 6);
			params.put("EndDate", sdf.format(recFridayInfo.getTime()));
			
			// 중복검사
			calendarId = workReportTimeCardService.chkDuplicateCalendar(params);
			if(calendarId == 0) {
				// 생성
				calendarId = workReportTimeCardService.insertCalendar(params);
			}
		}
		// 주차 생성 코드 끝
				
		// 기존에 등록된 workreportid가 존재하는지 확인
		CoviMap params = new CoviMap();
		CoviMap resultMap = null;
		Integer wrid = 0; 
		String state = "W";
		params.put("calID", calendarId);
		params.put("userCode", strUserCode);
		resultMap = workReportTimeCardService.getWorkReportIdAndStateByCalAndUser(params);
		
		wrid = resultMap.getInteger("WorkReportID");
		state = resultMap.getString("State");
		
		ModelAndView mav = null;
		// 작성된 Report가 있다면 최초 View페이지로 이동
		if(wrid > 0) {
			strWorkReportID = wrid.toString();
			
			String returnUrl = "mobile/workreport/viewMobileWorkReport";
			mav = new ModelAndView(returnUrl);
			mav.addObject("calid", calendarId);
			mav.addObject("workReportID", strWorkReportID);
			mav.addObject("userCode", strUserCode);
		} else {
			strMode = "W";
			String returnUrl = "mobile/workreport/regMobileWorkReport";
			mav = new ModelAndView(returnUrl);
			mav.addObject("calid", calendarId);
			mav.addObject("mode", strMode);
			mav.addObject("workReportID", strWorkReportID);
			mav.addObject("userCode", strUserCode);
		}
		
		return mav;
	}
	
	
	@RequestMapping(value="regMobileWorkReport.do", method=RequestMethod.GET)
	public ModelAndView regMobileWorkReport(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String strWorkReportID = request.getParameter("wrid");
		String strMode = request.getParameter("mode");
		String strCalID = request.getParameter("calid");
		String strUserCode = SessionHelper.getSession("UR_Code");
				
		
		if(strMode == null || strMode.isEmpty())
			strMode = "W";
		 
						
		// 기존에 등록된 workreportid가 존재하는지 확인
		CoviMap params = new CoviMap();
		CoviMap resultMap = null;
		Integer wrid = 0; 
		String state = "W";
		params.put("calID", strCalID);
		params.put("userCode", strUserCode);
		resultMap = workReportTimeCardService.getWorkReportIdAndStateByCalAndUser(params);
		
		wrid = resultMap.getInteger("WorkReportID");
		state = resultMap.getString("State");
		
		
		if(wrid > 0) {
			strWorkReportID = wrid.toString();
			strMode = "M";
		}
		
		// 작성중(작성, 거부 상태)이 아닐경우 View Page로 Redirect
		if(state.equalsIgnoreCase("I") || state.equalsIgnoreCase("A")) {
			response.sendRedirect(String.format("MobileWorkReport.do?wid=%s&calid=%s&uid=%s", strWorkReportID, strCalID, strUserCode).replaceAll("\r", "").replaceAll("\n", "")); //CLRF 대응
		}
		
		String returnUrl = "mobile/workreport/regMobileWorkReport";
		ModelAndView mav = new ModelAndView(returnUrl);
		mav.addObject("calid", strCalID);
		mav.addObject("mode", strMode);
		mav.addObject("workReportID", strWorkReportID);
		mav.addObject("userCode", strUserCode);
		
		
		return mav;
	}
	
	
}
