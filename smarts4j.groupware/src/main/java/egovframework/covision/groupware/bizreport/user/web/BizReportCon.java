package egovframework.covision.groupware.bizreport.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import net.sf.jxls.transformer.XLSTransformer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.bizreport.user.service.BizReportService;
/**
 * @Class Name : BizReportCommonCon.java
 * @Description : 업무보고 처리
 * @Modification Information 
 * @ 2019.10.08 최초생성
 *
 * @author 코비젼 연구2팀
 * @since 2019.10.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("/bizreport")
public class BizReportCon {
	// log4j obj 
	private Logger LOGGER = LogManager.getLogger(BizReportCon.class);
	
	@Autowired
	BizReportService bizreportSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	//업무보고 프로젝트명 검색
	@RequestMapping(value = "/getMyProject.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap getMyProject(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", request.getParameter("userCd"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			resultList = bizreportSvc.getMyProject(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 업무보고 -업무보고목록조회(팀장 등)
	@RequestMapping(value = "/getTaskReportDailyListAll.do", method = RequestMethod.GET)
	public @ResponseBody CoviMap getTaskReportList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("schTypeSel",request.getParameter("schTypeSel"));			//MyTask or PM
			params.put("projectCode", request.getParameter("projectCode"));			//프로젝트코드
			params.put("deptCode", request.getParameter("deptCode"));				//부서코드
			params.put("TaskGubunCode"  , request.getParameter("TaskGubunCode"));	//업무별
			params.put("startDate", request.getParameter("startDate"));
			params.put("endDate", request.getParameter("endDate"));
			
			resultList = bizreportSvc.getTaskReportDailyListAll(params);
			
			returnList.put("ProjectTaskList", resultList.get("ProjectTaskList"));
			returnList.put("FolderList", resultList.get("FolderList"));
			returnList.put("TaskList", resultList.get("TaskList"));
			returnList.put("ReportList", resultList.get("ReportList"));
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	//일일보고등록 > 항목 조회
	@RequestMapping(value="/getTaskReportDailyList.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getTaskReportDailyList(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("reportDate", paramMap.get("reportDate"));
		params.put("userCode", SessionHelper.getSession("USERID"));
		
		CoviMap resultObj = bizreportSvc.getTaskReportDailyList(params);
		
		returnObj.put("ProjectTaskList", resultObj.get("ProjectTaskList"));
		returnObj.put("FolderList", resultObj.get("FolderList"));
		returnObj.put("TaskList", resultObj.get("TaskList"));
		returnObj.put("ReportList", resultObj.get("ReportList"));
		
		return returnObj;
	}
	
	//일일보고등록 > 등록
	@RequestMapping(value = "/insertTaskReportDaily.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap insertTaskReportDaily(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("insertData", request.getParameter("insertData"));
			params.put("updateData", request.getParameter("updateData"));
			params.put("deleteData", request.getParameter("deleteData"));
			
			bizreportSvc.insertTaskReportDaily(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 업무보고 > 업무보고리스트 다운로드
	@RequestMapping(value = "/getTaskReportListExcel.do", method = RequestMethod.POST)
	public void getTaskReportListExcel(HttpServletRequest request, HttpServletResponse response,
		@RequestParam(value = "name", required = false, defaultValue="" ) String name,
		@RequestParam(value = "secter", required = false, defaultValue="" ) String secter,
		@RequestParam(value = "prjcode", required = false, defaultValue="" ) String prjcode,
		@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy) {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		Workbook resultWorkbook = null;
		
		try {
			// 1. 데이터 조회
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			CoviMap resultList = new CoviMap();
			
			int pageSize = 10000;
			int pageNo =  1;
			int pageOffset = (pageNo - 1) * pageSize;
			
			int start =  (pageNo - 1) * pageSize + 1; 
			int end = start + pageSize -1;
			
			CoviMap params = new CoviMap();
			params.put("pageOffset", pageOffset);
			params.put("pageSize", pageSize);
			params.put("sortColumn",sortColumn);
			params.put("sortDirection",sortDirection);
			
			params.put("userCode", request.getParameter("userCd"));				//sessionID
			params.put("prjCode", request.getParameter("projectSel"));			//프로젝트코드
			params.put("taskName", request.getParameter("taskName"));			//업무명
			params.put("taskCode", request.getParameter("taskCd"));				//업무코드
			params.put("schTypeSel",request.getParameter("schTypeSel"));		//MyTask or PM
			params.put("TaskGubunCode", request.getParameter("TaskGubunCode"));	//업무별
			
			params.put("startDate", request.getParameter("startDate"));
			params.put("endDate", request.getParameter("endDate"));
			params.put("rowEnd", end);
			params.put("rowStart", start);
			
			//resultList = bizreportSvc.getTaskReportList(params);
			
			CoviMap paramMap = new CoviMap();
			paramMap.put("list", resultList.get("list"));
			
			// 2. 엑셀 생성
			String FileName = new SimpleDateFormat("yyyy_MM_dd").format(new Date()) + "_TaskReportList.xlsx";
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//TaskReportList_template.xlsx");
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			is = new BufferedInputStream(new FileInputStream(ExcelPath));
			resultWorkbook = transformer.transformXLS(is, paramMap);
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setContentType("application/vnd.ms-excel;charset=utf-8");
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	//주간보고등록 > 항목 조회
	@RequestMapping(value="getTaskReportWeeklyList.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getTaskReportWeeklyList(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		// Parameter Setting
		String strStartDate = paramMap.get("startDate");
		String strEndDate = paramMap.get("endDate");
		String strUserCode = paramMap.get("userCode");
		String strPrjCode = paramMap.get("projectCode");
		String strtaskGubunCode = paramMap.get("taskGubunCode");
		
		CoviMap params = new CoviMap();
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		params.put("userCode", strUserCode);
		params.put("projectCode", strPrjCode);
		params.put("taskGubunCode", strtaskGubunCode);
		
		CoviMap resultList = bizreportSvc.getTaskReportWeeklyList(params);
		returnObj.put("TaskReportWeeklyList", resultList.get("list"));
		
		return returnObj;
	}
	
	//주간보고등록 > 등록
	@RequestMapping(value = "/insertProjectTaskReportWeekly.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap insertProjectTaskReportWeekly(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("ProjectCode", request.getParameter("ProjectCode"));
			params.put("StartDate", request.getParameter("StartDate"));
			params.put("EndDate", request.getParameter("EndDate"));
			params.put("WeekEtc", request.getParameter("WeekEtc"));
			params.put("NextPlan", request.getParameter("NextPlan"));
			params.put("RegisterCode", request.getParameter("RegisterCode"));
			params.put("RegisterDeptCode", request.getParameter("RegisterDeptCode"));
			params.put("TaskGubunCode", request.getParameter("TaskGubunCode"));
			
			int cnt = bizreportSvc.insertProjectTaskReportWeekly(params);
			
			if(cnt > 0){
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "저장되었습니다.");
			}else{
				returnList.put("result", "ok");
				returnList.put("status", Return.FAIL);
				returnList.put("message", "저장에 실패했습니다.");
			}
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	//주간보고등록 > 수정
	@RequestMapping(value = "/updateProjectTaskReportWeekly.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap updateProjectTaskReportWeekly(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("ReportID", request.getParameter("ReportID"));
			params.put("WeekEtc", request.getParameter("WeekEtc"));
			params.put("NextPlan", request.getParameter("NextPlan"));
			
			int cnt = bizreportSvc.updateProjectTaskReportWeekly(params);
			
			if(cnt > 0){
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "저장되었습니다.");
			}else{
				returnList.put("result", "ok");
				returnList.put("status", Return.FAIL);
				returnList.put("message", "저장에 실패했습니다.");
			}
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	//주간보고등록 > 등록 조회
	@RequestMapping(value = "/checkReportWeeklyRegistered.do")
	public @ResponseBody CoviMap checkReportWeeklyRegistered(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("projectCode", request.getParameter("ProjectCode"));
			params.put("StartDate", request.getParameter("StartDate"));
			params.put("EndDate", request.getParameter("EndDate"));
			params.put("RegisterCode", request.getParameter("RegisterCode"));
			params.put("TaskGubunCode", request.getParameter("TaskGubunCode"));
			
			resultList = bizreportSvc.checkReportWeeklyRegistered(params);
			
			returnList.put("list", resultList.get("list")); //기본정보
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	//주간보고현황 > 리스트 조회
	@RequestMapping(value="/getTaskReportWeeklyListAll.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getTaskReportWeeklyListAll(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("schTypeSel",request.getParameter("schTypeSel"));		//MyTask or PM
			params.put("projectCode", request.getParameter("projectCode"));		//프로젝트코드
			params.put("deptCode", request.getParameter("deptCode"));			//부서코드
			params.put("TaskGubunCode", request.getParameter("TaskGubunCode"));	//업무별
			params.put("startDate", request.getParameter("startDate"));
			params.put("endDate", request.getParameter("endDate"));
			
			resultList = bizreportSvc.getTaskReportWeeklyListAll(params);
			
			returnList.put("ProjectTaskList", resultList.get("ProjectTaskList"));
			returnList.put("FolderList", resultList.get("FolderList"));
			returnList.put("TaskList", resultList.get("TaskList"));
			returnList.put("GeralList", resultList.get("GeralList"));
			returnList.put("ReportList", resultList.get("ReportList"));
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	//관리 팀 및 멤버 조회
	@RequestMapping(value="getMyTeamMembers.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getMyTeamMembers(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		// Parameter Setting
		String strDeptCode = paramMap.get("deptCode");
		
		CoviMap params = new CoviMap();
		params.put("deptCode", strDeptCode);
		
		CoviMap resultList = bizreportSvc.getMyTeamMembers(params);
		returnObj.put("MyTeamList", resultList.get("list"));
		
		return returnObj;
	}
}
