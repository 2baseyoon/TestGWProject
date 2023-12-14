package egovframework.covision.groupware.workreport.web;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
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
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.workreport.service.WorkReportTimeCardService;
import egovframework.covision.groupware.workreport.util.WorkReportUtils;


@Controller
@RequestMapping("/workreport")
public class WorkReportTimeCardCon {
	
	private Logger LOGGER = LogManager.getLogger(WorkReportTimeCardCon.class);
	
	@Autowired
	private WorkReportTimeCardService workReportTimeCardService;
	
	@RequestMapping(value="regWorkReport.do", method=RequestMethod.GET)
	public ModelAndView regWorkReport(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strWorkReportID = request.getParameter("wrid");
		String strMode = request.getParameter("mode");
		String strCalID = request.getParameter("calid");
		String strUserCode = request.getParameter("uid");
		String strIsCors = request.getParameter("isCors");		// 외부 호출 여부
		
		if(strIsCors == null || strIsCors.isEmpty())
			strIsCors = "N";
		
		String currentUserId = SessionHelper.getSession("UR_Code");
		String currentUR_Name = SessionHelper.getSession("UR_Name");
		
		if(strUserCode == null || strUserCode.isEmpty()) {
			strUserCode = currentUserId;
		} else {
			// 넘겨받은 userCode가 Session 사용자값이 아닌경우 검증처리
			if(!strUserCode.equalsIgnoreCase(currentUserId)) {
				
				// 해당 Session 사용자가 넘겨받은 userCode의 담당자인지 확인 : 아닐 경우 파라미터 변조로 보고 자신의 세션아이디로 대체함
				CoviMap userParam = new CoviMap();
				userParam.put("usercode", strUserCode);
				userParam.put("currentUser", currentUserId);
				int chkVal = workReportTimeCardService.chkIsManagerByUserCode(userParam);
				if(chkVal == 0) {
					strUserCode = currentUserId;
				}
			}
		}
		
		int calendarId = 0;
		if(strCalID!=null && !strCalID.isEmpty())
			calendarId = Integer.parseInt(strCalID);
		
		if(strMode == null || strMode.isEmpty())
			strMode = "W";
		 
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
			// params.put("WeekOfMonth", recFridayInfo.get(Calendar.WEEK_OF_MONTH));
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
		
		
		if(wrid > 0) {
			strWorkReportID = wrid.toString();
			strMode = "M";
		}
		
		// 작성중이 아닐경우 View Page로 Redirect
		if(state.equalsIgnoreCase("I") || state.equalsIgnoreCase("A")) {
			response.sendRedirect(String.format("viewWorkReport.do?wid=%s&calid=%s&uid=%s&isCors=%s", strWorkReportID, calendarId, strUserCode, strIsCors).replaceAll("\r", "").replaceAll("\n", ""));
		}		
		
		String returnUrl = "user/workreport/regworkreport";
		ModelAndView mav = new ModelAndView(returnUrl);
		mav.addObject("currentUserCode", currentUserId);
		mav.addObject("currentUserName", currentUR_Name);
		mav.addObject("calid", calendarId);
		mav.addObject("mode", strMode);
		mav.addObject("workReportID", strWorkReportID);
		mav.addObject("userCode", strUserCode);
		mav.addObject("isCors", strIsCors);
		
		return mav;
	}
	
	@RequestMapping(value="getWorkReportCalendarInfo.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkReportCalendarInfo(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strCalID = request.getParameter("calID");
		
		CoviMap params = new CoviMap();
		params.put("calID", strCalID);
		
		CoviMap result = workReportTimeCardService.selectCalendarInfo(params); 
		returnObj.put("calendar", result);
		
		return returnObj;
	}
	
	
	@RequestMapping(value="getWorkReportBeforeAndNextCalInfo.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkReportBeforeAndNextCalInfo(HttpServletRequest request) throws Exception {
		String strCalID = request.getParameter("calID");
		
		CoviMap params = new CoviMap();
		params.put("calID", strCalID);
		
		return workReportTimeCardService.selectCalendarBeforeAndNextInfo(params);
	}
	
	@RequestMapping(value="getWorkReportDateInfo.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkReportDateInfo(HttpServletRequest request) throws Exception {
		String strDateInfo = request.getParameter("date");
		
		CoviMap params = new CoviMap();
		params.put("date", strDateInfo);
		
		return workReportTimeCardService.selectCalendarDateInfo(params);
	}
	
	
	@RequestMapping(value="getWorkReportGrade.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkReportGrade(HttpServletRequest request) throws Exception {
		String userId = request.getParameter("userid");
		String memberType = "O";
		CoviMap returnObj = null;
		
		String currentUserCode = SessionHelper.getSession("UR_Code"); 
		
		// 빈값일 경우 Session 값으로 대체
		if(userId == null || userId.isEmpty() || userId.equalsIgnoreCase(currentUserCode)) {
			userId = currentUserCode;
			memberType = "R";
		}
		
		CoviMap params = new CoviMap();
		params.put("userid", userId);
		params.put("memberType", memberType);
		
		// 정규직일 경우 Session 정보를 Parameter로 넘김
		if(memberType.equalsIgnoreCase("R")) {
			//params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			params.put("DN_Code", SessionHelper.getSession("DN_Code"));
			params.put("JobPositionCode", SessionHelper.getSession("UR_JobPositionCode"));
		}
		
		returnObj = workReportTimeCardService.getGrade(params);
		
		return returnObj;
	}
	
	
	@RequestMapping(value="workReportSave.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap workReportSave(@RequestBody List<Map<String, String>> paramList) throws Exception {
		int key = 0;
		CoviMap returnObj = new CoviMap();
		CoviMap baseReport = new CoviMap();
		ArrayList<CoviMap> liTimeSheet = new ArrayList<CoviMap>();
		// 배열 index 0 - 기초 보고데이터
		Map<String, String> baseReportParam = paramList.remove(0);
		baseReport.put("CalID", baseReportParam.get("calId"));
		baseReport.put("LastWeekPlan", WorkReportUtils.convertInputValue(baseReportParam.get("lastWeekPlan")));
		baseReport.put("NextWeekPlan", WorkReportUtils.convertInputValue(baseReportParam.get("nextWeekPlan")));
		baseReport.put("MonDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("monReport")));
		baseReport.put("TuesDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("tueReport")));
		baseReport.put("WedDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("wedReport")));
		baseReport.put("ThuDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("thuReport")));
		baseReport.put("FriDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("friReport")));
		baseReport.put("SatDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("satReport")));
		baseReport.put("SunDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("sunReport")));
		baseReport.put("MemberType", baseReportParam.get("memberType"));
		baseReport.put("JobPositionCode", baseReportParam.get("jobPositionCode"));
		baseReport.put("GradeKind", baseReportParam.get("gradeKind"));
		
		// UR_Code 값을 넘겨받지 않은경우 사용자 세션값 사용
		String creatorCode = baseReportParam.get("creator");
		String creatorDeptCode = "";
		
		String currentUserCode = SessionHelper.getSession("UR_Code");
		
		if(creatorCode == null || creatorCode.isEmpty() || creatorCode.equalsIgnoreCase(currentUserCode)) {
			creatorCode = currentUserCode;
			creatorDeptCode = SessionHelper.getSession("GR_Code");
		}
		
		baseReport.put("UR_Code", creatorCode);
		
		// 외주의 경우 GR_Code가 존재하지 않음
		baseReport.put("GR_Code", creatorDeptCode);
		
		
		// 배열  index 1 ~ n - timesheet 데이터
		CoviMap timeParam = null;
		for(Map<String, String> time : paramList) {
			timeParam = new CoviMap();
			timeParam.put("workReportId", time.get("workReportId"));
			timeParam.put("divisionCode", time.get("divisionCode"));
			timeParam.put("jobId", time.get("jobId"));
			timeParam.put("jobType", time.get("jobType"));
			timeParam.put("year", time.get("year"));
			timeParam.put("month", time.get("month"));
			timeParam.put("day", time.get("day"));
			timeParam.put("hour", time.get("hour"));
			timeParam.put("weekOfMonth", time.get("weekOfMonth"));
			timeParam.put("workDate", time.get("workDate"));
			timeParam.put("yearMonth", time.get("yearMonth"));
			
			liTimeSheet.add(timeParam);
		}
		
		key = workReportTimeCardService.insertWorkReport(baseReport, liTimeSheet);
		
		returnObj.put("insertKey", key);
		
		
		return returnObj;
	}
	
	@RequestMapping(value="workReportUpdate.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap workReportUpdate(@RequestBody List<Map<String, String>> paramList) throws Exception {
		int key = 0;
		CoviMap returnObj = new CoviMap();
		CoviMap baseReport = new CoviMap();
		ArrayList<CoviMap> liTimeSheet = new ArrayList<CoviMap>();
		
		ArrayList<CoviMap> liReduceTimeSheet = new ArrayList<CoviMap>();
		
		// 배열 index 0 - 기초 보고데이터
		Map<String, String> baseReportParam = paramList.remove(0);
		baseReport.put("WorkReportID", baseReportParam.get("workReportId"));
		baseReport.put("CalID", baseReportParam.get("calId"));
		baseReport.put("LastWeekPlan", WorkReportUtils.convertInputValue(baseReportParam.get("lastWeekPlan")));
		baseReport.put("NextWeekPlan", WorkReportUtils.convertInputValue(baseReportParam.get("nextWeekPlan")));
		baseReport.put("MonDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("monReport")));
		baseReport.put("TuesDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("tueReport")));
		baseReport.put("WedDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("wedReport")));
		baseReport.put("ThuDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("thuReport")));
		baseReport.put("FriDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("friReport")));
		baseReport.put("SatDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("satReport")));
		baseReport.put("SunDayReport", WorkReportUtils.convertInputValue(baseReportParam.get("sunReport")));
		
		// UR_Code 값을 넘겨받지 않은경우 사용자 세션값 사용
		String creatorCode = baseReportParam.get("creator");
		String creatorDeptCode = "";
		if(creatorCode == null || creatorCode.isEmpty()) {
			creatorCode = SessionHelper.getSession("UR_Code");
			creatorDeptCode = SessionHelper.getSession("GR_Code");
		}
		baseReport.put("UR_Code", creatorCode);
		
		// 외주의 경우 GR_Code가 존재하지 않음
		baseReport.put("GR_Code", creatorDeptCode);
		
		
		// 배열  index 1 ~ n - timesheet 데이터
		CoviMap timeParam = null;
		CoviMap beforeTime = null;
		for(Map<String, String> time : paramList) {
			timeParam = new CoviMap();
			timeParam.put("workReportId", time.get("workReportId"));
			timeParam.put("divisionCode", time.get("divisionCode"));
			timeParam.put("jobId", time.get("jobId"));
			timeParam.put("jobType", time.get("jobType"));
			timeParam.put("year", time.get("year"));
			timeParam.put("month", time.get("month"));
			timeParam.put("day", time.get("day"));
			timeParam.put("hour", time.get("hour"));
			timeParam.put("weekOfMonth", time.get("weekOfMonth"));
			timeParam.put("workDate", time.get("workDate"));
			timeParam.put("yearMonth", time.get("yearMonth"));
			
			// 삭제대상을 추리기 위해 등록되는 코드그룹 중복제거
			if(beforeTime == null) {
				beforeTime = timeParam;
				liReduceTimeSheet.add(beforeTime);
			} else {
				if(!(time.get("divisionCode").equals(beforeTime.get("divisionCode"))
				   &&time.get("jobId").equals(beforeTime.get("jobId"))
				   &&time.get("jobType").equals(beforeTime.get("jobType")))) {
					beforeTime = timeParam;
					liReduceTimeSheet.add(beforeTime);
				}
			}
			
			liTimeSheet.add(timeParam);
		}
		
		workReportTimeCardService.updateWorkReport(baseReport, liTimeSheet, liReduceTimeSheet);
		
		returnObj.put("message", "success");
		
		
		return returnObj;
	}
	
	@RequestMapping(value="initApprovalWorkreport.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap initApproval(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviMap obj = new CoviMap();
		obj.put("WorkReportID", request.getParameter("workReportId"));
		obj.put("CalID", request.getParameter("calId"));
		workReportTimeCardService.initApprovalWorkreport(obj);
		returnObj.put("message", "success");
		return returnObj;
	}
	
	@RequestMapping(value="viewWorkReport.do", method=RequestMethod.GET)
	public ModelAndView viewWorkReport(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnUrl = "user/workreport/viewworkreport";
		
		String strWorkReportId = request.getParameter("wrid");
		String strCalId = request.getParameter("calid");
		String strUid = request.getParameter("uid");
		String strManagerPage = request.getParameter("mp");
		String strCurrentUser = SessionHelper.getSession("UR_Code");
		String strCheckUserId = request.getParameter("checkUserId"); // 관리자) 특정 사용자 지정
		
		String strIsCors = request.getParameter("isCors");		// 외부 호출 여부
		
		if(strIsCors == null || strIsCors.isEmpty())
			strIsCors = "N";
		
		if(strManagerPage == null || strManagerPage.isEmpty()) {
			strManagerPage = "U";
		}
				
		String isManager = "N";
		
		if(strUid == null || strUid.isEmpty()) {
			if(strCheckUserId == null || strCheckUserId.isEmpty()) {
				strUid = strCurrentUser;
			} else {
				strUid = strCheckUserId;
			}
		}
			
		
				
		// 기존에 등록된 workreportid가 존재하는지 확인
		CoviMap params = new CoviMap();
		CoviMap resultMap = null;
		Integer wrid = 0; 
		String state = "W";
		params.put("calID", strCalId);
		params.put("userCode", strUid);
		resultMap = workReportTimeCardService.getWorkReportIdAndStateByCalAndUser(params);
		
		wrid = resultMap.getInteger("WorkReportID");
		state = resultMap.getString("state");
		
		String strSelUserInfoName = resultMap.getString("UR_Name");
		String strSelUserInfoJobPositionName = resultMap.getString("JobPositionName");
		
		
		if(wrid > 0) {
			strWorkReportId = wrid.toString();
		} else {
			// workReportID 가 없을경우 작성창으로 redirect
			response.sendRedirect(String.format("regWorkReport.do?calid=%s&uid=%s&isCors", strCalId, strUid, strIsCors).replaceAll("\r", "").replaceAll("\n", ""));
		}
		
		String currentUR_Code = strCurrentUser;
		String currentUR_Name = SessionHelper.getSession("UR_Name");
		
		// 팀장여부 전달
		boolean isManagerFlag = false;

		params.put("workReportID", strWorkReportId);
		String strManagerCode = workReportTimeCardService.selectTeamManagerByUid(params);
		
		String[] arrManagers = strManagerCode.split(";");
		
		for(String mCode : arrManagers) {
			if(mCode.equalsIgnoreCase(currentUR_Code)) {
				isManagerFlag = true;
				break;
			}
		}
		
		if(strManagerPage.equalsIgnoreCase("M") && isManagerFlag) {
			isManager = "Y";
		}
		
		// 팀장여부 전달
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		// front 단 script 처리 성능저하로 session값 전달
		mav.addObject("currentUser", currentUR_Code);
		mav.addObject("currentUserName", currentUR_Name);
		
		mav.addObject("workReportId", strWorkReportId);
		mav.addObject("calId", strCalId);
		mav.addObject("userCode", strUid);
		mav.addObject("isManager", isManager);
		mav.addObject("isCors", strIsCors);

		// 선택된 유저 정보
		mav.addObject("selUserInfoName", strSelUserInfoName);
		mav.addObject("selUserInfoJobPositionName", strSelUserInfoJobPositionName);
		
		return mav;
	}
	
	
	@RequestMapping(value="getWorkReportBaseReport.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkReportBaseReport(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		// Parameter Setting
		String strWorkReportId = paramMap.get("workReportID");
		String strCalId = paramMap.get("calID");
		String strUserCode = paramMap.get("userCode");
		
		
		String currentUserCode = SessionHelper.getSession("UR_Code");
		
		// userCode가 넘어오지 않을경우 자기자신의 업무보고를 가져옴
		if(strUserCode == null || strUserCode.isEmpty() || strUserCode.equalsIgnoreCase(currentUserCode)) {
			strUserCode = currentUserCode;
		}
		
		CoviMap params = new CoviMap();
		params.put("workReportID", strWorkReportId);
		params.put("calID", strCalId);
		params.put("userCode", strUserCode);
		
		CoviMap resultMap = workReportTimeCardService.getBaseReport(params);
		returnObj.put("baseReport", resultMap);
		
		return returnObj;
	}
	
	@RequestMapping(value="getWorkReportTimeSheetReport.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkReportTimeSheetReport(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		// Parameter Setting
		String strWorkReportId = paramMap.get("workReportID");
		String strCalId = paramMap.get("calID");
		
		CoviMap params = new CoviMap();
		params.put("workReportID", strWorkReportId);
		params.put("calID", strCalId);
		
		CoviList resultList = workReportTimeCardService.getTimeSheetReport(params);
		returnObj.put("timeSheetReport", resultList);
		
		return returnObj;
	}
	
	
	@RequestMapping(value="getManageUsers.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getManageUsers(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		// Parameter Setting
		String strCalId = paramMap.get("calId");
		String strCurrentUser = SessionHelper.getSession("UR_Code");
		
		CoviMap params = new CoviMap();
		params.put("currentUser", strCurrentUser);
		params.put("calId", strCalId);
		
		CoviList resultList = workReportTimeCardService.getManageUsers(params);
		returnObj.put("manageList", resultList);
		
		return returnObj;
	}
	
	
	@RequestMapping(value="getWorkReportMylist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getWorkReportMylist(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters
		String strStartDate = StringUtil.replaceNull(request.getParameter("startDate"), "");
		String strEndDate = StringUtil.replaceNull(request.getParameter("endDate"), "");
		String strDivision = StringUtil.replaceNull(request.getParameter("division"), "");
		String strJobId = StringUtil.replaceNull(request.getParameter("jobid"), "");
		String strType = StringUtil.replaceNull(request.getParameter("type"), "");
		
		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = "StartDate";
		String strSortDirection = "DESC";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));

		String checkUserId = StringUtil.replaceNull(request.getParameter("checkUserId"), SessionHelper.getSession("UR_Code"));
		params.put("userCode", checkUserId);
		
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		params.put("division", strDivision); 
		params.put("jobid", strJobId); 
		params.put("type", strType);
				
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));

		CoviMap listData = workReportTimeCardService.selectWorkReportMyList(params);
		
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	
	
	@RequestMapping(value="reportWorkReport.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap reportWorkReport(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strWorkReportID = paramMap.get("workReportId");
		String strCurrentState = paramMap.get("currentState");
		String strUserCode = paramMap.get("userCode");
		String strCalId = paramMap.get("calId");
		
		if(!(strCurrentState.equalsIgnoreCase("W") || strCurrentState.equalsIgnoreCase("R"))) {
			// 현재상태가 작성중 ( W ) 또는 거부 ( R ) 이 아닌경우 보고할 수 없음
			returnObj.put("result", "FAIL");
			returnObj.put("message", "이미 승인 요청되었거나 완료된 보고 입니다.");
		} else if (!strUserCode.equalsIgnoreCase(SessionHelper.getSession("UR_Code"))) {
			// 자기자신의 업무만 보고할 수 있음
			returnObj.put("result", "FAIL");
			returnObj.put("message", "비 정상적인 접근입니다.");
		} else {
			// 자기자신의 업무만 보고할 수 있음
			CoviMap params = new CoviMap();
			params.put("workReportID", strWorkReportID);
			params.put("userCode", strUserCode);
			params.put("userName", SessionHelper.getSession("UR_Name"));
			params.put("deptCode", SessionHelper.getSession("GR_Code"));
			params.put("calID", strCalId);
			
			int cnt = workReportTimeCardService.reportWorkReport(params);
			if(cnt > 0) {
				returnObj.put("result", "OK");
				returnObj.put("message", "보고 되었습니다.");
			}
		}
		return returnObj;
	}
	
	@RequestMapping(value="collectWorkReport.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap collectWorkReport(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strWorkReportID = paramMap.get("workReportId");
		String strCurrentState = paramMap.get("currentState");
		String strUserCode = paramMap.get("userCode");
		
		if(!strCurrentState.equalsIgnoreCase("I")) {
			// 현재상태가 작성중 ( W ) 또는 거부 ( R ) 이 아닌경우 보고할 수 없음
			returnObj.put("result", "FAIL");
			returnObj.put("message", "회수 할 수 없는 보고 입니다.");
		} else if (!strUserCode.equalsIgnoreCase(SessionHelper.getSession("UR_Code"))) {
			// 자기자신의 업무만 보고할 수 있음
			returnObj.put("result", "FAIL");
			returnObj.put("message", "비 정상적인 접근입니다.");
		} else {
			// 자기자신의 업무만 보고할 수 있음
			CoviMap params = new CoviMap();
			params.put("workReportId", strWorkReportID);
			int cnt = workReportTimeCardService.collectWorkReport(params);
			if(cnt > 0) {
				returnObj.put("result", "OK");
				returnObj.put("message", "회수 되었습니다.");
			}
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="workReportTeamMembers.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap workReportTeamMembers(@RequestParam Map<String, String> paramMap) throws Exception {
		// 자신과 같은팀 소속의 Member 정보 조회
		
		CoviMap returnObj = new CoviMap();
		String strGRCode = paramMap.get("groupCode");
		
		if(strGRCode == null || strGRCode.isEmpty())
			strGRCode = SessionHelper.getSession("GR_GroupPath"); // 부서depth
		
		CoviMap params = new CoviMap();
		// params.put("userCode", strURCode);
		params.put("groupCode", strGRCode);
		
		CoviList list = workReportTimeCardService.getTeamMembers(params);
		
		returnObj.put("members", list);
		
		return returnObj;
	}
	
	
	@RequestMapping(value="workReportApprovalTargets.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap workReportApprovalTargets() throws Exception {
		// 자신과 같은팀 소속의 Member 정보 조회
		
		CoviMap returnObj = new CoviMap();
		String strURCode = "";
		
		if(strURCode == null || strURCode.isEmpty())
			strURCode = SessionHelper.getSession("UR_Code");
		
		CoviMap params = new CoviMap();
		params.put("userCode", strURCode);
		
		CoviList list = workReportTimeCardService.getApprovalTargets(params);
		
		returnObj.put("members", list);
		
		return returnObj;
	}
	
	
	
	@RequestMapping(value="getWorkReportTeamlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getWorkReportTeamlist(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters
		String strStartDate = StringUtil.replaceNull(request.getParameter("startDate"), "");
		String strEndDate = StringUtil.replaceNull(request.getParameter("endDate"), "");
		String strDivision = StringUtil.replaceNull(request.getParameter("division"), "");
		String strJobId = StringUtil.replaceNull(request.getParameter("jobid"), "");
		String strType = StringUtil.replaceNull(request.getParameter("type"), "");
		
		String strMemberList = StringUtil.replaceNull(request.getParameter("memberList"), "");
		String strState = StringUtil.replaceNull(request.getParameter("state"), "");
		
		
		String[] arrMembers = strMemberList.split(",");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		
		params.put("userCode", SessionHelper.getSession("UR_Code"));
		
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		params.put("division", strDivision); 
		params.put("jobid", strJobId); 
		params.put("type", strType);
		
		params.put("members", arrMembers);
		params.put("state", strState);
				
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		
		CoviMap listData = workReportTimeCardService.selectWorkReportTeamList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	@RequestMapping(value="approvalWorkReport.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap approvalWorkReport(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strWorkReportID = paramMap.get("workReportId");
		String strCurrentState = paramMap.get("currentState");
		String strUserCode = paramMap.get("userCode");
		String strComment = paramMap.get("comment");
		
		String[] arrWorkReportIDs = strWorkReportID.split(",");
		
		// 승인을 사용할 수 있는 사용자인지 검증 필요 - Service 단에서 검사
		
		// Comment Convert
		if(strComment != null && !strComment.isEmpty()) {
			strComment = WorkReportUtils.convertInputValue(strComment);
		}
		
		if(!strCurrentState.equalsIgnoreCase("I")) {
			// 현재상태가 작성중 ( W ) 또는 거부 ( R ) 이 아닌경우 보고할 수 없음
			returnObj.put("result", "FAIL");
			returnObj.put("message", "승인 할 수 없는 보고 입니다.");
		} else {
			CoviMap params = new CoviMap();
			params.put("workReportIds", arrWorkReportIDs);
			params.put("comment", strComment);
			params.put("userCode", strUserCode);
			params.put("approvorCode", SessionHelper.getSession("UR_Code"));
			returnObj = workReportTimeCardService.approvalWorkReport(params);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="rejectWorkReport.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap rejectWorkReport(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strWorkReportID = paramMap.get("workReportId");
		String strCurrentState = paramMap.get("currentState");
		String strUserCode = paramMap.get("userCode");
		String strComment = paramMap.get("comment");
		
		String[] arrWorkReportIDs = strWorkReportID.split(",");
		
		// 승인을 사용할 수 있는 사용자인지 검증 필요
		
		// Comment Convert
		if(strComment != null && !strComment.isEmpty()) {
			strComment = WorkReportUtils.convertInputValue(strComment);
		}

		
		if(!strCurrentState.equalsIgnoreCase("I")) {
			// 현재상태가 작성중 ( W ) 또는 거부 ( R ) 이 아닌경우 보고할 수 없음
			returnObj.put("result", "FAIL");
			returnObj.put("message", "거부 할 수 없는 보고 입니다.");
		} else {
			CoviMap params = new CoviMap();
			params.put("workReportIds", arrWorkReportIDs);
			params.put("comment", strComment);
			params.put("userCode", strUserCode);
			params.put("approvorCode", SessionHelper.getSession("UR_Code"));
			returnObj = workReportTimeCardService.rejectWorkReport(params);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="getLastWeekPlan.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getLastWeekPlan(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strCalId = paramMap.get("calID");
		String strUserCode = paramMap.get("userCode");
		
		CoviMap params = new CoviMap();
		params.put("calID", strCalId);
		params.put("userCode", strUserCode);
		
		CoviMap result = workReportTimeCardService.getLastWeekPlan(params);
		
		returnObj.put("lastWeekPlan", result);
		
		return returnObj;
	}	
	
	
	@RequestMapping(value="checkDuplicateWorkReport.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap checkDuplicateWorkReport(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();

		String strCalId = paramMap.get("calId");
		String strUid = paramMap.get("userCode");
		
		// 기존에 등록된 workreportid가 존재하는지 확인
		CoviMap params = new CoviMap();
		CoviMap resultMap = null;
		Integer wrid = 0; 
		String state = "W";
		params.put("calID", strCalId);
		params.put("userCode", strUid);
		resultMap = workReportTimeCardService.getWorkReportIdAndStateByCalAndUser(params);
		
		
		
		returnObj.put("wrid", resultMap.getInteger("WorkReportID"));
		
		return returnObj;
	}
}
