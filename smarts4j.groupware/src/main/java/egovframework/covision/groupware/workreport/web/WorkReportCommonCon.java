package egovframework.covision.groupware.workreport.web;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.workreport.service.WorkReportTimeCardService;
import egovframework.covision.groupware.workreport.util.WorkReportUtils;



/**
 * @Class Name : WorkReportCommonCon.java
 * @Description : 업무보고 일반적 요청 처리
 * @Modification Information 
 * @ 2017.04.24 최초생성
 *
 * @author 코비젼 협업팀
 * @since 2017. 04.24
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("/workreport")
public class WorkReportCommonCon {

	// log4j obj 
	private Logger LOGGER = LogManager.getLogger(WorkReportCommonCon.class);
	
	@Autowired
	private WorkReportTimeCardService workReportTimeCardService;
	
	
	@RequestMapping(value = "/workreporthome.do", method = RequestMethod.GET)
	public ModelAndView workReportHome() throws Exception {
		
		String returnUrl = "workreport/workreport.workreport";
		ModelAndView mav = new ModelAndView(returnUrl);
		
		return mav;
	}
	
	
	
	@RequestMapping(value = "/workreport_{strPage}.do", method = RequestMethod.GET)
	public ModelAndView directWorkReportLeftMenu(@PathVariable String strPage) throws Exception{
	
		// 차후 작업스케쥴러로 옮겨야 하는 부분
		// 주차 생성 코드 시작
		int cnt = 0;
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
		cnt = workReportTimeCardService.chkDuplicateCalendar(params);
		if(cnt == 0) {
			// 생성
			workReportTimeCardService.insertCalendar(params);
		}
		// 주차 생성 코드 끝
		
		String returnUrl = "workreport/" + strPage + ".workreport";
		ModelAndView mav = new ModelAndView(returnUrl);
		
		
		return mav;
	}
	
	@RequestMapping(value = "/workreportheader.do", method = RequestMethod.GET)
	public ModelAndView getHeader() throws Exception {
		String returnUrl = "cmmn/menu/workreportheader";
		
		String userId = SessionHelper.getSession("UR_Code");
		String userName = SessionHelper.getSession("UR_Name");
		String userDeptCode = SessionHelper.getSession("GR_Code");
		String userDeptName = SessionHelper.getSession("GR_Name");
		
		String userJobPosition = SessionHelper.getSession("UR_JobPositionName");
		
		
		CoviMap params = new CoviMap();
		params.put("userCode", userId);
		params.put("groupCode", userDeptCode);
		
		CoviList resultList = workReportTimeCardService.getTeamMembers(params);
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		if(resultList.size() > 0) {
			CoviMap result = resultList.getJSONObject(0);
			if(result.get("RecentState") != null && !result.getString("RecentState").isEmpty()) {
				mav.addObject("recentMonth", result.get("RecentMonth"));
				mav.addObject("recentWeekOfMonth", result.get("RecentWeekOfMonth"));
				mav.addObject("recentState", result.get("RecentState"));
				mav.addObject("notReportCnt", result.get("NotReportCnt"));
			}
		}
		
		
		mav.addObject("userId", userId);
		mav.addObject("userName", userName);
		mav.addObject("userDeptCode", userDeptCode);
		mav.addObject("userDeptName", userDeptName);
		mav.addObject("userJobPosition", userJobPosition);
		
		return mav;
	}
	
	@RequestMapping(value = "/workreportleft.do", method = RequestMethod.GET)
	public ModelAndView getLeftMenu(HttpServletRequest request) throws Exception {
		String returnUrl = "cmmn/menu/workreportleft";
		
		String strMenuPath = request.getParameter("mnp");
		
		// 임시 - 관리자
		String strManagerList = RedisDataUtil.getBaseConfig("TempWorkReportManager");
		boolean isViewManager = false;
		
		// 임시 - 레포팅 메뉴 조회자
		String strReportingList = RedisDataUtil.getBaseConfig("TempReportViewer");
		boolean isViewReporting = false;
		
		// 팀장 JobTitleCodes
		String strTeamManager = RedisDataUtil.getBaseConfig("WorkReportTMJobTitle");
		boolean isViewTeamReport = false;
		
		
		String grCode = SessionHelper.getSession("GR_Code");
		String urCode = SessionHelper.getSession("UR_Code");
		String jobTitleCode = SessionHelper.getSession("UR_JobTitleCode");
		
		
		if(strMenuPath == null || strMenuPath.isEmpty()) {
			strMenuPath = "0";
		}
		
		StringTokenizer stringTokenizer = new StringTokenizer(strTeamManager, "|");
		
		// 팀장 권한 확인
		while(stringTokenizer.hasMoreTokens()) {
			String strJobTitle = stringTokenizer.nextToken();
			
			if(jobTitleCode.equalsIgnoreCase(strJobTitle)) {
				isViewTeamReport = true;
				break;
			}
		}
		
		
		stringTokenizer = new StringTokenizer(strManagerList, "|");
		
		// 관리자 권한 확인
		while(stringTokenizer.hasMoreTokens()) {
			String strCode = stringTokenizer.nextToken();
			
			String[] arrCode = strCode.split(":");
			
			if(arrCode.length == 2) {
				if(arrCode[0].equalsIgnoreCase("UR")) {
					if(arrCode[1].equalsIgnoreCase(urCode)){
						isViewManager = true;
						break;
					}
				} else if (arrCode[0].equalsIgnoreCase("GR")) {
					if(arrCode[1].equalsIgnoreCase(grCode)){
						isViewManager = true;
						break;
					}
				}
			}
		}
		
		
		stringTokenizer = new StringTokenizer(strReportingList, "|");
		
		// 레포팅 권한 확인
		while(stringTokenizer.hasMoreTokens()) {
			String strCode = stringTokenizer.nextToken();
			
			String[] arrCode = strCode.split(":");
			
			if(arrCode.length == 2) {
				if(arrCode[0].equalsIgnoreCase("UR")) {
					if(arrCode[1].equalsIgnoreCase(urCode)){
						isViewReporting = true;
						break;
					}
				} else if (arrCode[0].equalsIgnoreCase("GR")) {
					if(arrCode[1].equalsIgnoreCase(grCode)){
						isViewReporting = true;
						break;
					}
				}
			}
		}
				
		
		// 예외사항 ( 손광훈 차장 & 황희철 차장님 팀장대행 직책 줄 수 없어서 권한 강제 추가 )
		if(urCode.equalsIgnoreCase("khson") || urCode.equalsIgnoreCase("shpark1") || urCode.equalsIgnoreCase("superadmin") || urCode.equalsIgnoreCase("hhcley")  || urCode.equalsIgnoreCase("kybaek")) {
			isViewTeamReport = true;
		}
		
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		StringBuilder sbMenuHtml = new StringBuilder();
		sbMenuHtml.append("<ul id='workReportMenu' class='ulWorkReportMenuList' style='display:none;'>");
		
		// 아무값도 넘어오지 않았을때 최초페이지 세팅
		sbMenuHtml.append("	<li data-mnid='0' data-mnurl='workreport_workreport.do' onclick='moveMenuUrl(this)'>");
		sbMenuHtml.append("		업무보고");
		sbMenuHtml.append("	</li>");
		sbMenuHtml.append("	<li data-mnid='1' data-mnurl='workreport_myworksetting.do' onclick='moveMenuUrl(this)'>");
		sbMenuHtml.append("		나의 업무 설정");
		sbMenuHtml.append("	</li>");
		
		if(isViewTeamReport) {
			sbMenuHtml.append("	<li data-mnid='2' data-mnurl='workreport_teamworkreport.do' onclick='moveMenuUrl(this)'>");
			sbMenuHtml.append("		팀 업무보고");
			sbMenuHtml.append("	</li>");
		}
		
		// 외주직원 업무보고 추가 2017-06-19
		sbMenuHtml.append("	<li data-mnid='15' data-mnurl='workreport_osworkreport.do' onclick='moveMenuUrl(this)'>");
		sbMenuHtml.append("		외주직 업무보고");
		sbMenuHtml.append("	</li>");
		// 외주직원 업무보고 끝
		
		if(isViewManager) {
			sbMenuHtml.append("	<li data-mnid='3' onclick='viewLowDepthMenu(this)'>");
			sbMenuHtml.append("		관리도구");
			sbMenuHtml.append("		<span class='closemenu' style='float:right; display:inline-block; width:30px; height:40px;'></span>");
			sbMenuHtml.append("		<ul class='ulWorkReportMenuListDept2' style='display:none;'>");
			sbMenuHtml.append("			<li data-mnid='4' data-mnurl='workreport_jobmanage.do' onclick='moveMenuUrl(this)'>");
			sbMenuHtml.append("				- 업무 관리");
			sbMenuHtml.append("			</li>");
			sbMenuHtml.append("			<li data-mnid='5' data-mnurl='workreport_reggrade.do' onclick='moveMenuUrl(this)'>");
			sbMenuHtml.append("				- 정직원 단가 관리");
			sbMenuHtml.append("			</li>");
			sbMenuHtml.append("			<li data-mnid='6' data-mnurl='workreport_osgrade.do' onclick='moveMenuUrl(this)'>");
			sbMenuHtml.append("				- 외주직원 단가 관리");
			sbMenuHtml.append("			</li>");
			sbMenuHtml.append("			<li data-mnid='7' data-mnurl='workreport_outsourcing.do' onclick='moveMenuUrl(this)'>");
			sbMenuHtml.append("				- 외주직원 관리");
			sbMenuHtml.append("			</li>");
			sbMenuHtml.append("			<li data-mnid='8' data-mnurl='workreport_workdaysetting.do' onclick='moveMenuUrl(this)'>");
			sbMenuHtml.append("				- 기준일 설정");
			sbMenuHtml.append("			</li>");
			sbMenuHtml.append("			<li data-mnid='16' data-mnurl='workreport_approvalsetting.do' onclick='moveMenuUrl(this)'>");
			sbMenuHtml.append("				- 승인자 설정");
			sbMenuHtml.append("			</li>");
			sbMenuHtml.append("		</ul>");
			sbMenuHtml.append("	</li>");
		}
		
		if(isViewReporting || isViewTeamReport) {
			sbMenuHtml.append("	<li data-mnid='9' onclick='viewLowDepthMenu(this)'>");
			sbMenuHtml.append("		레포팅");
			sbMenuHtml.append("		<span class='closemenu' style='float:right; display:inline-block; width:30px; height:40px;'></span>");
			sbMenuHtml.append("		<ul class='ulWorkReportMenuListDept2' style='display:none;'>");
			
			if(isViewTeamReport) {
				sbMenuHtml.append("			<li data-mnid='10' data-mnurl='workreportteamproject.do' onclick='moveMenuUrl(this)'>");
				sbMenuHtml.append("				- 팀원 프로젝트 분석");
				sbMenuHtml.append("			</li>");
				sbMenuHtml.append("			<li data-mnid='11' data-mnurl='workreportreportbyteam.do' onclick='moveMenuUrl(this)'>");
				sbMenuHtml.append("				- 팀별 원가관리 > 인건비");
				sbMenuHtml.append("			</li>");
			}
			
			if(isViewReporting) {
				sbMenuHtml.append("			<li data-mnid='12' data-mnurl='workreport_reportproject.do' onclick='moveMenuUrl(this)'>");
				sbMenuHtml.append("				- 프로젝트 투입현황");
				sbMenuHtml.append("			</li>");
				sbMenuHtml.append("			<li data-mnid='17' data-mnurl='workreport_projecttime.do' onclick='moveMenuUrl(this)'>");
				sbMenuHtml.append("				- 프로젝트 투입시간");
				sbMenuHtml.append("			</li>");
				sbMenuHtml.append("			<li data-mnid='13' data-mnurl='workreport_projectcost.do' onclick='moveMenuUrl(this)'>");
				sbMenuHtml.append("				- 프로젝트 원가관리 > 인건비");
				sbMenuHtml.append("			</li>");
				sbMenuHtml.append("			<li data-mnid='14' data-mnurl='workreport_projectcostos.do' onclick='moveMenuUrl(this)'>");
				sbMenuHtml.append("				- 프로젝트 원가관리 > 외주비");
				sbMenuHtml.append("			</li>");
				sbMenuHtml.append("		</ul>");
				sbMenuHtml.append("	</li>");
			}
		}
		sbMenuHtml.append("</ul>");
		
		
		mav.addObject("menuStr", sbMenuHtml.toString());
		mav.addObject("menuPath", strMenuPath);
		return mav;
	}
	
	@RequestMapping(value = "/workreportcatepop.do", method = RequestMethod.GET)
	public ModelAndView cateManagePop() throws Exception {
		String returnUrl = "user/workreport/jobcatemanage";
		ModelAndView mav = new ModelAndView(returnUrl);
	
		return mav;
	}
	
	@RequestMapping(value = "/workreportjobregistpop.do", method = RequestMethod.GET)
	public ModelAndView jobRegistPop() throws Exception {
		String returnUrl = "user/workreport/jobregist";
		ModelAndView mav = new ModelAndView(returnUrl);
	
		return mav;
	}
	
	@RequestMapping(value="WorkReportUtilExcelView.do", method=RequestMethod.POST)
	public ModelAndView workReportExcelDownload(HttpServletRequest request) throws Exception {
		String returnUrl = "WorkReportUtilExcelView";
		ModelAndView mav = new ModelAndView(returnUrl);
		String strExcelData = request.getParameter("excelData");
		String strFileName = request.getParameter("fileName");
		
		if(strFileName == null || strFileName.isEmpty()) {
			Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
			
			strFileName = dateFormat.format(today);
		}
		
		mav.addObject("fileName", strFileName);
		mav.addObject("excelData", strExcelData);
		
		return mav;
	}
	
	@RequestMapping(value = "/workSearchPop.do", method = RequestMethod.GET)
	public ModelAndView workSearchPop(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String num = request.getParameter("num");
		String selDevID = request.getParameter("selDevID");
		
		String returnUrl = "user/workreport/workSearchPop";
		ModelAndView mav = new ModelAndView(returnUrl);
		mav.addObject("num", num);
		mav.addObject("selDevID", selDevID);
	
		return mav;
	}
	
}
