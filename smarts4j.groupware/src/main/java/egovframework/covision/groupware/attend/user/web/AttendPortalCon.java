package egovframework.covision.groupware.attend.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import net.sf.jxls.transformer.XLSTransformer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.LogHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.baseframework.util.json.JSONParser;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;

import egovframework.covision.groupware.attend.user.service.AttendAdminSettingSvc;
//import egovframework.core.sevice.LoginSvc;
//import egovframework.core.sevice.ControlSvc;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;
import egovframework.covision.groupware.attend.user.service.AttendPortalSvc;
import egovframework.covision.groupware.attend.user.service.AttendScheduleSvc;
import egovframework.covision.groupware.attend.user.service.AttendUserStatusSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;

@Controller
public class AttendPortalCon {
	private Logger LOGGER = LogManager.getLogger(AttendPortalCon.class); 
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@Autowired 
	AttendCommonSvc attendCommonSvc;

	@Autowired
	AttendUserStatusSvc attendUserStatusSvc;

	@Autowired
	AttendPortalSvc attendPortalSvc;

	@Autowired
	AttendScheduleSvc attendScheduleSvc;
	
	@Autowired
	AttendAdminSettingSvc attendAdminSettingSvc;

	//포탈화면-사용자에 따라 분기
	@RequestMapping(value = "attend/attendHome.do")
	public @ResponseBody ModelAndView attendHome(HttpServletRequest request,		HttpServletResponse response,HttpSession session) throws Exception {
		String returnURL = "attend/AttendPortalUser.user.content" ;
		String userAuth  = attendCommonSvc.getUserAuthType();
		String jobType = attendCommonSvc.getUserJobAuthType();
		if (request.getParameter("AuthMode") == null){
			if (userAuth.equals("ADMIN") || jobType.equals("TEAM") || jobType.equals("DEVISION")) returnURL = "attend/AttendPortalManager.user.content" ;
		}
		else{
			if ("U".equals(request.getParameter("AuthMode"))) returnURL = "attend/AttendPortalUser.user.content" ;
		}
			
		SessionHelper.setSession("isAttendAdmin", userAuth);
		/*
		CoviMap cmap = attendCommonSvc.getMyManagerName(SessionHelper.getSession("UR_ManagerCode"));//UR_ManagerName
		session.setAttribute("isAdmin2", userAuth);
		if (cmap != null){
			session.setAttribute("UR_ManagerName", cmap.get("DisplayName"));
		}*/	
		String dateTerm = "W";
		String userCode = SessionHelper.getSession("USERID");
		String deptCode = SessionHelper.getSession("DEPTID");
		String companyCode = SessionHelper.getSession("DN_Code");
		String domainID = SessionHelper.getSession("DN_ID");
		String targetDate = ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
		String targetDateTime = ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss");
		
		CoviMap params = new CoviMap();

		params.put("lang",  SessionHelper.getSession("lang"));

		CoviMap dateMap= attendUserStatusSvc.setDayParams(dateTerm,targetDate,companyCode);
		
		String sDate = dateMap.getString("sDate");
		String eDate = dateMap.getString("eDate");
		String dayWeek = dateMap.getString("dayWeek");

		params.put("TargetDate",targetDate);
		params.put("TargetDateTime",targetDateTime);
		params.put("UserCode",userCode);
		params.put("CompanyCode",companyCode);
		params.put("domainID", domainID);
		params.put("StartDate", sDate);
		params.put("EndDate", eDate);
		params.put("authMode", "A");		
		params.put("LimitSize", 6);
		CoviMap portalMap = attendPortalSvc.getUserPortal(params);
		
		String weekDays = DicHelper.getDic("lbl_sch_"+dayWeek.toLowerCase());

		ModelAndView mav = new ModelAndView(returnURL);
		CoviMap workMap = (CoviMap)portalMap.get("userAttWorkTime");
		mav.addObject("TargetDate",AttendUtils.maskDate(targetDate));
		mav.addObject("StartDate",sDate);
		mav.addObject("EndDate",eDate);
		mav.addObject("TargetWeek",weekDays);

		mav.addObject("userCallingList", portalMap.get("userCallingList"));
		mav.addObject("userExtendList", portalMap.get("userExtendList"));
		mav.addObject("RemainTime", AttendUtils.convertSecToStr(workMap.get("RemainTime"),"H"));
		mav.addObject("FixWorkTime", workMap.get("FixWorkTime")==null?0:workMap.getInt("FixWorkTime"));
		mav.addObject("userSchedule", portalMap.get("userSchedule"));
		
		
		if (portalMap.get("resultCommut") != null){
			CoviMap commuteData = (CoviMap)portalMap.get("resultCommut");
			mav.addObject("StartSts", (String)commuteData.get("StartSts"));
			
		}
		else  {
			mav.addObject("StartSts","lbl_unAttended");
		}
		
		CoviMap schList =  attendScheduleSvc.getAttendScheduleList(params);
		mav.addObject("MngMst",	attendAdminSettingSvc.getAttendMngMst());
		mav.addObject("SchList", schList.get("list"));

		
		return mav;
	}
	
	//포탈화면-관리자 근태 현황
	@RequestMapping(value = "attendPortal/getMangerAttStatus.do")
	public @ResponseBody CoviMap getMangerAttStatus(@RequestBody Map<String, Object> paramMap, HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();

		Map reqMap = (Map)paramMap.get("companyMap");
		boolean bCompanyToday = false;
		boolean bCompanyDay = false;
		boolean bDeptDay = false;
		boolean bUserDay = false;
		
		switch  ((String)paramMap.get("queryType")){
			case "A":	//전체 조회
				bCompanyToday=true;
				bCompanyDay=true;
				bDeptDay=true;
				bUserDay=false;
				params.put("DeptType", ((Map)paramMap.get("deptMap")).get("pageType"));
				break;
			case "C":	//회사
				bCompanyDay=true;
				break;
			case "U":	//사용자
				bUserDay=true;
				reqMap = (Map)paramMap.get("userMap");
				break;
			case "D":	//부서
				bDeptDay=true;
				reqMap = (Map)paramMap.get("deptMap");
				params.put("DeptType", reqMap.get("pageType"));
				break;
			default : 
				break;
		}
		

		String userCode = SessionHelper.getSession("USERID");

		String dateTerm = (String)reqMap.get("pageType");
		String targetDate = (String)reqMap.get("targetDate");
		
		String deptCode = (String)paramMap.get("deptCode");
		String companyCode = SessionHelper.getSession("DN_Code");
		String deptUpCode =(String)paramMap.get("deptUpCode");
		String deptUpCodeWork =(String)paramMap.get("deptUpCodeWork");
		
		CoviMap dateMap = attendUserStatusSvc.setDayParams(dateTerm,targetDate,companyCode);
		
		String sDate = dateMap.getString("sDate");
		String eDate = dateMap.getString("eDate");

		params.put("TargetDate",targetDate);
		params.put("UserCode",userCode);
		params.put("CompanyCode",companyCode);
		params.put("DeptUpCode",deptUpCode);
		params.put("DeptUpCodeWork",deptUpCodeWork);
		params.put("StartDate", sDate);
		params.put("EndDate", eDate);
		params.put("SearchText", (String)paramMap.get("searchText"));
		params.put("SchSeq", (String)paramMap.get("schSeq"));
		
		if(paramMap.containsKey("schCheckList")) {
			params.put("schCheckList", paramMap.get("schCheckList"));
		}

		params.put("pageSize", (String)paramMap.get("pageSize"));
		params.put("pageNo", paramMap.get("pageNo"));
		params.put("LimitSize", 5);
		
		params.put("lang", SessionHelper.getSession("lang"));
		
		List list = new ArrayList();
		String gmJobArray = RedisDataUtil.getBaseConfig("AttendanceGMJobTiltle");
		StringTokenizer gmJob = new StringTokenizer(gmJobArray, "|");
		while(gmJob.hasMoreTokens()) {
			list.add(gmJob.nextToken());
		}
		params.put("execptJob", list);


		List list2 = new ArrayList();
		String gmJobArray2 = RedisDataUtil.getBaseConfig("AttPortalDailyJobTitle");
		StringTokenizer gmJob2 = new StringTokenizer(gmJobArray2, "|");
		while(gmJob2.hasMoreTokens()) {
			list2.add(gmJob2.nextToken());
		}
		params.put("attPortalDailyJobTitle", list2);
		
		String domainID = SessionHelper.getSession("DN_ID");

		String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
		if(!orgMapOrderSet.equals("")) {
		                String[] orgOrders = orgMapOrderSet.split("\\|");
		                params.put("orgOrders", orgOrders);
		}

		try{
			returnList = attendPortalSvc.getManagerPortalDay(params, bCompanyToday, bCompanyDay, bDeptDay, bUserDay);
			returnList.put("TargetDate", targetDate);
			returnList.put("StartDate", sDate);
			returnList.put("EndDate", eDate);
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
		
	//포탈화면-사용자 근태 현황
	@RequestMapping(value = "attendPortal/getMyAttStatus.do")
	public @ResponseBody CoviMap getMyAttStatus(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();

		String dateTerm = StringUtil.replaceNull(request.getParameter("dateTerm"), "");
		String targetDate = StringUtil.replaceNull(request.getParameter("targetDate"), "");
		String userCode = SessionHelper.getSession("USERID");
		String deptCode = SessionHelper.getSession("DEPTID");
		String companyCode = SessionHelper.getSession("DN_Code");
		
		CoviMap params = new CoviMap();
		CoviMap dateMap= attendUserStatusSvc.setDayParams(dateTerm,targetDate,companyCode);
		
		String sDate = dateMap.getString("sDate");
		String eDate = dateMap.getString("eDate");

		params.put("TargetDate",targetDate);
		params.put("UserCode",userCode);
		params.put("CompanyCode",companyCode);
		params.put("StartDate", sDate);
		params.put("EndDate", eDate);
		params.put("LimitSize", 6);
		
		try{
			CoviMap portalMap = attendPortalSvc.getUserPortalDay(params);
			returnList.put("userAttWorkTime", portalMap.get("userAttWorkTime"));
			returnList.put("StartDate", sDate);
			returnList.put("EndDate", eDate);
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
		
	//근무일정수정
	@RequestMapping(value = "attendPortal/AttendPortalDetailPopup.do", method = RequestMethod.GET)
	public ModelAndView attendPortalDetailPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendPortalDetailPopup";
		String StartDate = StringUtil.replaceNull(request.getParameter("StartDate"), "");
		String EndDate = StringUtil.replaceNull(request.getParameter("EndDate"), "");

		ModelAndView mav = new ModelAndView(returnURL);
		CoviMap reqMap = new CoviMap();
		reqMap.put("StartDate", StartDate);
		reqMap.put("EndDate", EndDate);
		reqMap.put("UserCode", request.getParameter("UserCode"));
		reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		reqMap.put("domainID", SessionHelper.getSession("DN_ID"));
		String printDN = request.getParameter("printDN");
		reqMap.put("printDN", printDN);

		String DayNightStartTime = RedisDataUtil.getBaseConfig("DayNightStartTime")+"";
		String DayNightEndTime = RedisDataUtil.getBaseConfig("DayNightEndTime")+"";
		if(DayNightStartTime.equals("")){
			DayNightStartTime = RedisDataUtil.getBaseConfig("NightStartTime")+"";
		}
		if(DayNightEndTime.equals("")){
			DayNightEndTime = RedisDataUtil.getBaseConfig("NightEndTime")+"";
		}
		reqMap.put("NightStartDate", DayNightStartTime);
		reqMap.put("NightEndDate", DayNightEndTime);
		reqMap.put("HolNightStartDate", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
		reqMap.put("HolNightEndDate", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
		reqMap.put("ExtNightStartDate", RedisDataUtil.getBaseConfig("NightStartTime"));
		reqMap.put("ExtNightEndDate", RedisDataUtil.getBaseConfig("NightEndTime"));
		
		CoviMap jsonData = attendPortalSvc.getDeptUserAttendList(reqMap);

		mav.addObject("data",	jsonData.get("data"));
		mav.addObject("printDN",	printDN);
		mav.addObject("UserCode",	request.getParameter("UserCode"));
		mav.addObject("UserName",	request.getParameter("UserName"));
		mav.addObject("DeptName",	request.getParameter("DeptName"));
		mav.addObject("StartDate",	AttendUtils.maskDate(StartDate));
		mav.addObject("EndDate",	AttendUtils.maskDate(EndDate));
		return mav;
	}
		
		
	//근태 누락
	@RequestMapping(value = "attendPortal/AttendPortalSendPopup.do", method = RequestMethod.GET)
	public ModelAndView attendPortalSendPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendPortalSendPopup";
		String StartDate = StringUtil.replaceNull(request.getParameter("StartDate"), "");
		String EndDate = StringUtil.replaceNull(request.getParameter("EndDate"), "");
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("StartDate",	AttendUtils.maskDate(StartDate));
		mav.addObject("EndDate",	AttendUtils.maskDate(EndDate));
		mav.addObject("MngMst",	attendAdminSettingSvc.getAttendMngMst());
		//
		return mav;
	}
	
	@RequestMapping(value = "attendPortal/getCallingTarget.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAttendJob(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);

			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("lang", SessionHelper.getSession("lang"));
			List execptJob = new ArrayList();
			String gmJobArray = RedisDataUtil.getBaseConfig("AttendanceGMJobTiltle");
			StringTokenizer gmJob = new StringTokenizer(gmJobArray, "|");
			while(gmJob.hasMoreTokens()) {
				execptJob.add(gmJob.nextToken());
			}
			params.put("execptJob", execptJob);
			CoviMap resultList = attendPortalSvc.getCallingTarget(params);
			if (resultList.get("page") != null){
				returnList.put("page", resultList.get("page"));
			}	

			returnList.put("list", resultList.get("list"));
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

	@RequestMapping(value = "attendPortal/getCallingTargetExcel.do")
	public void excelAttendJob(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		CoviMap excelMap= new CoviMap();
		excelMap.put("title", "근무일정(일간)");
		String FileName="AttendStsList";
		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);

			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			List list = new ArrayList();
			String gmJobArray = RedisDataUtil.getBaseConfig("AttendanceGMJobTiltle");
			StringTokenizer gmJob = new StringTokenizer(gmJobArray, "|");
			while(gmJob.hasMoreTokens()) {
				list.add(gmJob.nextToken());
			}
			params.put("execptJob", list);

			CoviMap resultList = attendPortalSvc.getCallingTarget(params);

			excelMap.put("StartDate", params.get("StartDate"));
			excelMap.put("EndDate", params.get("EndDate"));
			excelMap.put("list", resultList.get("list"));

			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//"+FileName+"_templete.xlsx");
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, excelMap);
			resultWorkbook.write(baos);

			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setContentType("application/vnd.ms-excel;charset=utf-8");
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();

		}  finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	//근태 상세
	@RequestMapping(value = "attendPortal/AttendPortalStatusPopup.do", method = RequestMethod.GET)
	public ModelAndView attendPortalStatusPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendPortalStatusPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		String SearchStatus = StringUtil.replaceNull(request.getParameter("SearchStatus"), "");
		String StartDate = StringUtil.replaceNull(request.getParameter("StartDate"), "");
		String EndDate = StringUtil.replaceNull(request.getParameter("EndDate"), "");
		
		if (SearchStatus.contains("VAC")) SearchStatus="VAC";
		
		mav.addObject("SearchStatus",	SearchStatus);
		mav.addObject("DeptUpCode",	request.getParameter("DeptUpCode"));
		mav.addObject("StartDate",	AttendUtils.maskDate(StartDate));
		mav.addObject("EndDate",	AttendUtils.maskDate(EndDate));
		return mav;
	}
		
	/**
	 * @param params
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "attendPortal/sendMessageTarget.do")
	public  @ResponseBody CoviMap sendMessageTarget(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap resultList = new CoviMap();
		
		try {
			String senderName  = SessionHelper.getSession("UR_Name");
			String senderMail  = SessionHelper.getSession("UR_Mail");
			String companyCode = SessionHelper.getSession("DN_Code");

			CoviMap sendParams = new CoviMap();
			sendParams.put("StartDate", params.get("StartDate"));
			sendParams.put("EndDate", params.get("EndDate"));
			sendParams.put("DeptUpCode", params.get("DeptUpCode"));
			sendParams.put("CommStatus", params.get("CommStatus"));
			sendParams.put("dataList", params.get("dataList"));
			sendParams.put("lang", SessionHelper.getSession("lang"));

			List jobList = new ArrayList();
			String gmJobArray = RedisDataUtil.getBaseConfig("AttendanceGMJobTiltle");
			StringTokenizer gmJob = new StringTokenizer(gmJobArray, "|");
			while(gmJob.hasMoreTokens()) {
				jobList.add(gmJob.nextToken());
			}
			sendParams.put("execptJob", jobList);

			sendParams.put("CompanyCode", companyCode);
			sendParams.put("senderCode",  SessionHelper.getSession("USERID"));
			sendParams.put("senderName", senderName);
			sendParams.put("senderMail", senderMail);
			sendParams.put("DomainID", SessionHelper.getSession("DN_ID"));
			
			CoviMap list = attendPortalSvc.sendCallingTarget(sendParams);
			resultList.put("result", "ok");
			resultList.put("status", Return.SUCCESS);
			resultList.put("sendCnt", list.get("cnt"));

		} catch (NullPointerException ex) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return resultList;
	}
	
	@RequestMapping(value = "attendPortal/getUserStatus.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserStatus(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);
			String StartDate = StringUtil.replaceNull(request.getParameter("StartDate"), "");
			String EndDate = StringUtil.replaceNull(request.getParameter("EndDate"), "");

			params.put("UR_TimeZone", AttendUtils.removeMaskAll(ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat)).substring(0,8));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("StartDate", AttendUtils.removeMaskAll(StartDate)); 
			params.put("EndDate",  AttendUtils.removeMaskAll(EndDate)); 
			CoviMap resultList = attendPortalSvc.getUserStatus(params);
			if (resultList.get("page") != null){
				returnList.put("page", resultList.get("page"));
			}	

			returnList.put("list", resultList.get("list"));
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

	//엑셀
	//포탈화면-관리자 근태 현황
	@RequestMapping(value = "attendPortal/excelPortalDept.do", method = RequestMethod.POST)
	public void excelPortalDept(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap params = new CoviMap();

		boolean bCompanyToday = false;
		boolean bCompanyDay = false;
		boolean bDeptDay = true;
		boolean bUserDay = false;
		
		params.put("DeptType", request.getParameter("pageType"));

		String userCode = SessionHelper.getSession("USERID");
		String dateTerm = (String)request.getParameter("pageType");
		String targetDate = (String)request.getParameter("targetDate");
		String deptCode = (String)request.getParameter("deptCode");
		String companyCode = SessionHelper.getSession("DN_Code");
		String deptUpCode =(String)request.getParameter("deptUpCode");
		String deptUpCodeWork =(String)request.getParameter("deptUpCodeWork");
		String printDN = StringUtil.replaceNull(request.getParameter("printDN"), "");
		String sDate = request.getParameter("sDate");
		String eDate = request.getParameter("eDate");
		String pageType = StringUtil.replaceNull(request.getParameter("pageType"), "");
		
		List<String> schCheckList = new ArrayList<String>();
		
		if(request.getParameterMap().containsKey("schCheckList")) {
			for(String schCheck : request.getParameterValues("schCheckList")) {
				if(StringUtil.isNotEmpty(schCheck)) {
					schCheckList.add(schCheck);
				}
			}
		}
		
		if(schCheckList.size() > 0) {
			params.put("schCheckList", schCheckList);
		}
		
		params.put("TargetDate",targetDate);
		params.put("UserCode",userCode);
		params.put("CompanyCode",companyCode);
		params.put("DeptUpCode",deptUpCode);
		params.put("DeptUpCodeWork",deptUpCodeWork);
		params.put("StartDate", sDate);
		params.put("EndDate", eDate);
		params.put("SearchText", (String)request.getParameter("searchText"));
		params.put("SchSeq", (String)request.getParameter("schSeq"));

		params.put("lang", SessionHelper.getSession("lang"));
		
		try{
			resultList = attendPortalSvc.getManagerPortalDay(params, bCompanyToday, bCompanyDay, bDeptDay, bUserDay);
			
			CoviList cList = (CoviList)resultList.get("deptAttendList");
			String FileName ;
			if (pageType.equals("D"))
				FileName = "AttendPortalDay";
			else	
				FileName = "AttendPortalMonth";
			resultList.put("TargetDate", targetDate);
			
			SXSSFWorkbook workbook = new SXSSFWorkbook();
			Sheet sheet = workbook.createSheet();
			Font ttlFont= workbook.createFont(); //폰트 객체 생성
			CellStyle ttlStyle = workbook.createCellStyle();
			
			Font textFont= workbook.createFont(); //폰트 객체 생성
			CellStyle textStyle = workbook.createCellStyle();

			ArrayList<HashMap> excelHeader = 	new ArrayList<>() ;
			if (params.get("DeptType").equals("D")){
				excelHeader.add(new HashMap<String, String>() {{   put("colName","성명"); put("colWith","5"); put("colKey","URName"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","본부"); put("colWith","10");put("colKey","DeptName");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","직급"); put("colWith","10");put("colKey","JobPositionName");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","직책"); put("colWith","10");put("colKey","JobTitleName");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","입사일자"); put("colWith","8");put("colKey","EnterDate");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","템플릿");  put("colWith","10");put("colKey","SchName");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","근무일자"); put("colWith","8");put("colKey","TargetDate");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","출근시간"); put("colWith","6");put("colKey","AttStartTime");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","퇴근시간"); put("colWith","6");put("colKey","AttEndTime");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","기본근무"); put("colWith","5");put("colKey","AttAc");  put("colFormat","H");}});
				if(printDN.equals("true")){
					excelHeader.add(new HashMap<String, String>() {{   put("colName","주"); put("colWith","5");put("colKey","AttAcD");  put("colFormat","H");}});
					excelHeader.add(new HashMap<String, String>() {{   put("colName","야"); put("colWith","5");put("colKey","AttAcN");  put("colFormat","H");}});
				}
				excelHeader.add(new HashMap<String, String>() {{   put("colName","연장근무"); put("colWith","5");put("colKey","ExtenAc"); put("colFormat","H");  }});
				if(printDN.equals("true")){
					excelHeader.add(new HashMap<String, String>() {{   put("colName","주"); put("colWith","5");put("colKey","ExtenAcD");  put("colFormat","H");}});
					excelHeader.add(new HashMap<String, String>() {{   put("colName","야"); put("colWith","5");put("colKey","ExtenAcN");  put("colFormat","H");}});
				}
				excelHeader.add(new HashMap<String, String>() {{   put("colName","휴일근무"); put("colWith","5");put("colKey","HoliAc"); put("colFormat","H"); }});
				if(printDN.equals("true")){
					excelHeader.add(new HashMap<String, String>() {{   put("colName","주"); put("colWith","5");put("colKey","HoliAcD");  put("colFormat","H");}});
					excelHeader.add(new HashMap<String, String>() {{   put("colName","야"); put("colWith","5");put("colKey","HoliAcN");  put("colFormat","H");}});
				}
				excelHeader.add(new HashMap<String, String>() {{   put("colName","지각");   put("colWith","5");put("colKey","LateMin"); put("colFormat","H"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","조퇴");   put("colWith","5");put("colKey","EarlyMin");put("colFormat","H");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","휴게");   put("colWith","5");put("colKey","AttIdle");put("colFormat","H");  }});
			}
			else{
				excelHeader.add(new HashMap<String, String>() {{   put("colName","성명"); put("colWith","5"); put("colKey","URName"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","본부"); put("colWith","10");put("colKey","DeptName");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","직급"); put("colWith","10");put("colKey","JobPositionName");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","직책"); put("colWith","10");put("colKey","JobTitleName");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","입사일자"); put("colWith","8");put("colKey","EnterDate");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","기본근무"); put("colWith","5");put("colKey","AttAc");  put("colFormat","H");}});
				if(printDN.equals("true")){
					excelHeader.add(new HashMap<String, String>() {{   put("colName","주"); put("colWith","5");put("colKey","AttAcD");  put("colFormat","H");}});
					excelHeader.add(new HashMap<String, String>() {{   put("colName","야"); put("colWith","5");put("colKey","AttAcN");  put("colFormat","H");}});
				}
				excelHeader.add(new HashMap<String, String>() {{   put("colName","연장근무"); put("colWith","5");put("colKey","ExtenAc"); put("colFormat","H");  }});
				if(printDN.equals("true")){
					excelHeader.add(new HashMap<String, String>() {{   put("colName","주"); put("colWith","5");put("colKey","ExtenAcD");  put("colFormat","H");}});
					excelHeader.add(new HashMap<String, String>() {{   put("colName","야"); put("colWith","5");put("colKey","ExtenAcN");  put("colFormat","H");}});
				}
				excelHeader.add(new HashMap<String, String>() {{   put("colName","휴일근무"); put("colWith","5");put("colKey","HoliAc"); put("colFormat","H"); }});
				if(printDN.equals("true")){
					excelHeader.add(new HashMap<String, String>() {{   put("colName","주"); put("colWith","5");put("colKey","HoliAcD");  put("colFormat","H");}});
					excelHeader.add(new HashMap<String, String>() {{   put("colName","야"); put("colWith","5");put("colKey","HoliAcN");  put("colFormat","H");}});
				}
				excelHeader.add(new HashMap<String, String>() {{   put("colName","지각");   put("colWith","5");put("colKey","LateMin"); put("colFormat","H"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","조퇴");   put("colWith","5");put("colKey","EarlyMin");put("colFormat","H");  }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","휴게");   put("colWith","5");put("colKey","AttIdle");put("colFormat","H");  }});
			}
			
			Row rowTitle = sheet.createRow(0);
//			AttendUtils.writeExcelCellData(rowTitle, 1, excelTitle, textFont,textStyle);
			sheet.addMergedRegion(new CellRangeAddress(0,0,1,4));
			rowTitle = sheet.createRow(1);
//			AttendUtils.writeExcelCellData(rowTitle, 1, "조회: "+startDate+" ~ "+endDate, textFont,textStyle);
			sheet.addMergedRegion(new CellRangeAddress(1,1,1,4));
			
			Row rowHeader = sheet.createRow(2);
			AttendUtils.writeExcelHeaderData(rowHeader, 1, excelHeader, ttlFont, ttlStyle);
			
			for (int j=0; j < cList.size(); j++){
				
				HashMap hMap= (HashMap)cList.get(j);
				Row row= sheet.createRow(j+3);
				AttendUtils.writeExcelRowData(row, 1, excelHeader, hMap, textFont,textStyle);
			}

			for (int i=0; i<excelHeader.size(); i++)
			{
				sheet.setColumnWidth(i+1, Integer.parseInt((String)((HashMap)excelHeader.get(i)).get("colWith"))*512 ); 
			}

			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			workbook.write(response.getOutputStream());
			workbook.dispose(); 
			try { workbook.close(); } 
			catch(IOException ignore) { LOGGER.error(ignore.getLocalizedMessage(), ignore); }
			catch(Exception ignore) { LOGGER.error(ignore.getLocalizedMessage(), ignore); }

		} catch (IOException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
	}

	@RequestMapping(value = "attendPortal/excelPortalDetail.do")
	public void excelPortalDetail(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		try{
			String str = StringUtil.replaceNull(request.getParameter("dataList"), "");
			String printDN = StringUtil.replaceNull(request.getParameter("printDN"), "");
			String DeptName = StringUtil.replaceNull(request.getParameter("DeptName"), "");
			String UserName = StringUtil.replaceNull(request.getParameter("UserName"), "");
			String StartDate = StringUtil.replaceNull(request.getParameter("StartDate"), "");
			String EndDate = StringUtil.replaceNull(request.getParameter("EndDate"), "");
			String UserCode = StringUtil.replaceNull(request.getParameter("UserCode"), "");
			JSONParser parser = new JSONParser();
			String[] dataList = str.split(",");

			ArrayList<HashMap> excelHeader = 	new ArrayList<>() ;
			excelHeader.add(new HashMap<String, String>() {{   put("colName","일자"); put("colWith","5"); put("colKey","Col0"); }});
			excelHeader.add(new HashMap<String, String>() {{   put("colName","요일"); put("colWith","10");put("colKey","Col1");  }});
			excelHeader.add(new HashMap<String, String>() {{   put("colName","Cal"); put("colWith","10");put("colKey","Col2");  }});
			excelHeader.add(new HashMap<String, String>() {{   put("colName","근태"); put("colWith","10");put("colKey","Col3");  }});
			excelHeader.add(new HashMap<String, String>() {{   put("colName","근무구분"); put("colWith","8");put("colKey","Col4");  }});
			excelHeader.add(new HashMap<String, String>() {{   put("colName","출근");  put("colWith","10");put("colKey","Col5");  }});
			excelHeader.add(new HashMap<String, String>() {{   put("colName","퇴근"); put("colWith","8");put("colKey","Col6");  }});
			if(printDN.equals("true")){
				excelHeader.add(new HashMap<String, String>() {{   put("colName","기본근무"); put("colWith","5");put("colKey","Col7"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","주간"); put("colWith","5");put("colKey","Col8"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","야간"); put("colWith","5");put("colKey","Col9"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","연장근무"); put("colWith","5");put("colKey","Col10"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","주간"); put("colWith","5");put("colKey","Col11"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","야간"); put("colWith","5");put("colKey","Col12"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","휴일근무"); put("colWith","5");put("colKey","Col13"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","주간"); put("colWith","5");put("colKey","Col14"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","야간"); put("colWith","5");put("colKey","Col15"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","지각");   put("colWith","5");put("colKey","Col16"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","조퇴");   put("colWith","5");put("colKey","Col17"); }});
			}else{
				excelHeader.add(new HashMap<String, String>() {{   put("colName","기본근무"); put("colWith","5");put("colKey","Col7"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","연장근무"); put("colWith","5");put("colKey","Col8"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","휴일근무"); put("colWith","5");put("colKey","Col9"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","지각");   put("colWith","5");put("colKey","Col10"); }});
				excelHeader.add(new HashMap<String, String>() {{   put("colName","조퇴");   put("colWith","5");put("colKey","Col11"); }});
			}
			
			SXSSFWorkbook workbook = new SXSSFWorkbook();
			Sheet sheet = workbook.createSheet();
			Font ttlFont= workbook.createFont(); //폰트 객체 생성
			CellStyle ttlStyle = workbook.createCellStyle();
			
			Row rowTitle = sheet.createRow(0);
	//		AttendUtils.writeExcelCellData(rowTitle, 1, excelTitle, textFont,textStyle);
			sheet.addMergedRegion(new CellRangeAddress(0,0,1,4));
			rowTitle = sheet.createRow(1);
			Font textFont= workbook.createFont(); //폰트 객체 생성
			CellStyle textStyle = workbook.createCellStyle();
			String deptDate = "";
			deptDate = "소속 : "+DeptName+"   사번/성명 : "+UserCode+" / "+UserName+ "   근무기간 : "+StartDate+" ~ "+EndDate;
			AttendUtils.writeExcelCellData(rowTitle, 1, deptDate, textFont,textStyle);
			sheet.addMergedRegion(new CellRangeAddress(1,1,1,4));
			
			Row rowHeader = sheet.createRow(2);
			AttendUtils.writeExcelHeaderData(rowHeader, 1, excelHeader, ttlFont, ttlStyle);
			
			for (int j=0; j < dataList.length; j++){
				HashMap hMap = new HashMap();
				String[] aList = dataList[j].split("!!");
				for (int i=0; i < aList.length-1; i++){
					hMap.put("Col"+i, aList[i].trim());
				}

				Row row= sheet.createRow(j+3);
				AttendUtils.writeExcelRowData(row, 1, excelHeader, hMap, textFont,textStyle);
			}
	
			for (int i=0; i<excelHeader.size(); i++){
				sheet.setColumnWidth(i+1, Integer.parseInt((String)((HashMap)excelHeader.get(i)).get("colWith"))*512 ); 
			}
			String FileName = "AttendPortalMonth";
			response.reset();
			response.setContentType("application/vnd.ms-Excel");
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			workbook.write(response.getOutputStream());
			response.getOutputStream().flush();
			workbook.dispose(); 
			    
			try { workbook.close(); } 
			catch(IOException ignore) { LOGGER.error(ignore.getLocalizedMessage(), ignore); }
			catch(Exception ignore) { LOGGER.error(ignore.getLocalizedMessage(), ignore); }
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} 
		
	}
	//근태 규정 조회
	@RequestMapping(value = "attendPortal/getAttendPolicy.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAttendPolicy(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap resultList = attendAdminSettingSvc.getAttendMngMst();
			returnList.put("data",resultList);
			 
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
	
	// 웹파트 팀원 근태현황 조회
	@RequestMapping(value = "attendPortal/getDeptAttStatusWebpart.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDeptAttStatusWebpart(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap param = new CoviMap();
			param.put("lang", SessionHelper.getSession("lang"));
			param.put("Today", ComUtils.GetLocalCurrentDate("yyyy-MM-dd", 0, SessionHelper.getSession("UR_TimeZone")));
			param.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			param.put("DeptCode", request.getParameter("DeptCode"));
			param.put("Time", ComUtils.GetLocalCurrentDate("HH:mm", 0, SessionHelper.getSession("UR_TimeZone")));
			param.put("domainID", SessionHelper.getSession("DN_ID"));

			CoviMap resultList = attendPortalSvc.getDeptAttStatusWebpart(param);
			returnList.put("data", resultList.get("list"));
			 
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
	
	// 관리자 근태관리 -> 근무 현황
	@RequestMapping(value = "attend/attendWorkState.do")
	public @ResponseBody ModelAndView attendWorkState(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws Exception {
		String returnURL = "attend/AttendWorkState.user.content" ;
		String userAuth  = attendCommonSvc.getUserAuthType();
			
		SessionHelper.setSession("isAttendAdmin", userAuth);
			
		String dateTerm = "W";
		String userCode = SessionHelper.getSession("USERID");
		String deptCode = SessionHelper.getSession("DEPTID");
		String companyCode = SessionHelper.getSession("DN_Code");
		String domainID = SessionHelper.getSession("DN_ID");
		String targetDate = ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
		String targetDateTime = ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss");
		
		CoviMap params = new CoviMap();

		params.put("lang",  SessionHelper.getSession("lang"));

		CoviMap dateMap = attendUserStatusSvc.setDayParams(dateTerm,targetDate,companyCode);
		
		String sDate = dateMap.getString("sDate");
		String eDate = dateMap.getString("eDate");

		params.put("TargetDate", targetDate);
		params.put("TargetDateTime", targetDateTime);
		params.put("UserCode", userCode);
		params.put("deptCode", deptCode);
		params.put("CompanyCode", companyCode);
		params.put("domainID", domainID);
		params.put("StartDate", sDate);
		params.put("EndDate", eDate);

		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("TargetDate", AttendUtils.maskDate(targetDate));
		mav.addObject("StartDate", sDate);
		mav.addObject("EndDate", eDate);
		
		CoviMap schList =  attendScheduleSvc.getAttendScheduleList(params);
		mav.addObject("SchList", schList.get("list"));
		
		return mav;
	}
}