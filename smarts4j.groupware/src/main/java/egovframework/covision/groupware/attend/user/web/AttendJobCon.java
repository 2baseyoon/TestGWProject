package egovframework.covision.groupware.attend.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import net.sf.jxls.transformer.XLSTransformer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;
import egovframework.covision.groupware.attend.user.service.AttendJobSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import egovframework.baseframework.data.CoviSelectSet;

@Controller
public class AttendJobCon {
	private final Logger LOGGER = LogManager.getLogger(AttendJobCon.class);
	
	final boolean isDevMode = "Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isDevMode"));
	
	@Autowired 
	AttendCommonSvc attendCommonSvc;

	@Autowired 
	AttendJobSvc attendJobSvc;

	@RequestMapping(value = "attendJob/AttendJobPopup.do", method = RequestMethod.GET)
	public ModelAndView attendJobPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendJobPopup";

		ModelAndView mav = new ModelAndView(returnURL);
		CoviMap reqMap = new CoviMap();
		reqMap.put("ValidYn", "Y");
		reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		reqMap.put("UserCode", SessionHelper.getSession("USERID"));
		reqMap.put("DeptID", SessionHelper.getSession("DEPTID"));

		Object jsonData = attendCommonSvc.getScheduleList(reqMap);

		mav.addObject("list",	jsonData);
		
		String authType = attendCommonSvc.getUserAuthType();
		String jobType = attendCommonSvc.getUserJobAuthType();
		
		if (authType.equals("USER") && jobType.equals("DEVISION")){
			authType= jobType;
		}
		
		mav.addObject("authType",	authType);
		
		return mav;
	}
	
	@RequestMapping(value = "attendJob/AttendJobCopyPopup.do", method = RequestMethod.GET)
	public ModelAndView attendJobCopyPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendJobCopyPopup";

		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("JobDate", request.getParameter("JobDate"));
		mav.addObject("UserCode", request.getParameter("UserCode"));
		mav.addObject("authType",	attendCommonSvc.getUserAuthType());
		return mav;
	}

	/**
	* @Method Name : getAttendJob
	* @작성일 : 2019. 7. 1.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 근무제리스트 조회
	* @param request request
	* @param response response
	 */
	
	@RequestMapping(value = "attendJob/getAttendJob.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAttendJob(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
			                String[] orgOrders = orgMapOrderSet.split("\\|");
			                params.put("orgOrders", orgOrders);
			}
			
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			switch (request.getParameter("mode"))
			{
				case "D":	//일간
					resultList = attendJobSvc.getAttendJobDay(params);
					break;
				case "W":	//주간
					resultList = attendJobSvc.getAttendJobWeek(params);
					break;
				case "M":	//월간
					params.put("StartDate", AttendUtils.removeMaskAll((String)params.get("StartDate")).substring(0,6));
					resultList = attendJobSvc.getAttendJobMonth(params);
					returnList.put("holiList", resultList.get("holiList"));
					break;
				case "L":	//목록
					resultList = attendJobSvc.getAttendJobList(params);
					break;
				default : break;
			}

			if (resultList.get("page") != null){
				returnList.put("page", resultList.get("page"));
			}

			returnList.put("list", resultList.get("list"));
			if (resultList.get("avg") != null) returnList.put("avg", resultList.get("avg"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode?e.getMessage(): DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode?e.getMessage(): DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}
	
	@RequestMapping(value = "attendJob/excelAttendJob.do", method = RequestMethod.POST)
	public void excelAttendJob(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultList = new CoviMap();
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);

			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("UserCode", SessionHelper.getSession("USERID"));
			CoviMap excelMap= new CoviMap();
			String FileName="";
			
			switch (request.getParameter("mode"))
			{
				case "D":	//일간
					excelMap.put("title", "근무일정(일간)"); 
					FileName = "AttendJobDay";
					resultList = attendJobSvc.getAttendJobDay(params);
					break;
				case "W":	//주간
					excelMap.put("title", "근무일정(주간)"); 
					FileName = "AttendJobWeek";
					resultList = attendJobSvc.getAttendJobWeek(params);
					break;
				case "M":	//월간
					params.put("StartDate", AttendUtils.removeMaskAll((String)params.get("StartDate")).substring(0,6));
					resultList = attendJobSvc.getAttendJobMonth(params);
					break;
				case "L":	//목록
					resultList = attendJobSvc.getAttendJobList(params);
					break;
				default :
					break;
			}

			//params.put("list",excelList); 
			excelMap.put("StartDate", params.get("StartDate")); 
			excelMap.put("EndDate", params.get("EndDate")); 
			CoviList userList = (CoviList)resultList.get("list");
			if ("D".equals(request.getParameter("mode"))){
				CoviList excelList = new CoviList();
				for(int i=0; i < userList.size(); i++){
					CoviMap dayMap = (CoviMap)userList.get(i);
					if(dayMap.getInt("WorkingSystemType")>0
							&& dayMap.getString("AttDayStartTime").equalsIgnoreCase("0000")
							&& dayMap.getString("AttDayEndTime").equalsIgnoreCase("0000")) {
						dayMap.put("AttDayTime", AttendUtils.maskTime(dayMap.getString("AttDayStartTime")) + "~" + AttendUtils.maskTime(dayMap.getString("AttDayEndTime")));
						dayMap.put("AttDayAC", AttendUtils.convertSecToStr(dayMap.get("AttDayAC"), "H"));
						if (!dayMap.getString("AttDayStartTime").equals("")) {
							int AttDayStartTime = Integer.parseInt("0000");
							int AttDayEndTime = Integer.parseInt("2400");
							for (int j = 0; j < 24; j++) {
								if (j >= Math.floor(AttDayStartTime / 100) && j * 100 < AttDayEndTime) {
									dayMap.put("Day_" + j, "○");
								}
							}
						}
					}else{
						dayMap.put("AttDayTime", AttendUtils.maskTime(dayMap.getString("AttDayStartTime")) + "~" + AttendUtils.maskTime(dayMap.getString("AttDayEndTime")));
						dayMap.put("AttDayAC", AttendUtils.convertSecToStr(dayMap.get("AttDayAC"), "H"));
						if (!dayMap.getString("AttDayStartTime").equals("")) {
							int AttDayStartTime = Integer.parseInt(dayMap.getString("AttDayStartTime"));
							int AttDayEndTime = Integer.parseInt(dayMap.getString("AttDayEndTime"));
							for (int j = 0; j < 24; j++) {
								if (j >= Math.floor(AttDayStartTime / 100) && j * 100 < AttDayEndTime) {
									dayMap.put("Day_" + j, "○");
								}
							}
						}
					}
					excelList.add(dayMap);
				}
				
				excelMap.put("list", excelList);
			}
			else {
				excelMap.put("list", resultList.get("list"));
			}

			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//"+FileName+"_templete.xlsx");
//			String ExcelPath = "C://eGovFrame-3.5.1//workspace//smarts4j.new_groupware//src//main//resources//excel//"+FileName+"_templete.xlsx";
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
			
//			if (resultList.get("avg") != null) returnList.put("avg", resultList.get("avg"));
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	/**
	 * @Method Name : downloadExcel
	 * @Description : 엑셀 다운로드
	 */
	@RequestMapping(value = "attendJob/downloadExcel.do")
	public ModelAndView downloadExcel(HttpServletRequest	request,			HttpServletResponse	response){
		ModelAndView mav		= new ModelAndView();
		CoviMap result	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
 		
		try {
			String[] headerNames = StringUtil.replaceNull(request.getParameter("headerName"), "").split("†");
			String[] headerKeys  = StringUtil.replaceNull(request.getParameter("headerKey"), "").split(",");
			
			CoviMap params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("UserCode", SessionHelper.getSession("USERID"));
			CoviMap resultList = new CoviMap();
			switch (request.getParameter("mode"))
			{
				case "D":	//일간
					resultList = attendJobSvc.getAttendJobDay(params);
					break;
				case "W":	//주간
					resultList = attendJobSvc.getAttendJobWeek(params);
					break;
				case "M":	//월간
					resultList = attendJobSvc.getAttendJobMonth(params);
					break;
				case "L":	//목록
					resultList = attendJobSvc.getAttendJobList(params);
					break;
				default : 
					break;
			}

			CoviList cList = (CoviList)resultList.get("list");

			viewParams.put("list",			CoviSelectSet.coviSelectJSON(cList, request.getParameter("headerKey")));
			viewParams.put("cnt",			resultList.size());
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerKey",		headerKeys);
			viewParams.put("title",			request.getParameter("title"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}

	/**
	 * @Method Name : delAttendSchAlloc
	 * @작성일 : 2019. 6. 18.
	 * @작성자 : sjhan0418
	 * @변경이력 : 최초생성
	 * @Method 설명 : 사용자삭제
	 * @RequestBody   params
	 * @HttpServletRequest   request
	 *///
	@RequestMapping(value = "attendJob/createAttendScheduleJob.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap createAttendScheduleJob(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			List dataList = (List)params.get("dataList");
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("SchSeq", params.get("SchSeq"));
			reqMap.put("StartDate", params.get("StartDate"));
			reqMap.put("EndDate", params.get("EndDate"));
			reqMap.put("HolidayFlag", params.get("HolidayFlag"));

			if("-1".equals(reqMap.get("SchSeq").toString())) {
				reqMap.put("StartTime",  params.get("StartTime"));
				reqMap.put("EndTime",  params.get("EndTime"));
				reqMap.put("NextDayYn",  params.get("NextDayYn"));
			}

			returnObj = attendJobSvc.createAttendScheduleJob(reqMap, dataList);
			returnObj.put("status", Return.SUCCESS);
			
		} catch(NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	/**
	 * @Method Name : createAttendScheduleJobDiv
	 * @작성일 : 2019. 6. 18.
	 * @작성자 : sjhan0418
	 * @변경이력 : 최초생성
	 * @Method 설명 : 사용자삭제
	 * @RequestBody request
	 * @HttpServletRequest response
	 * @return
	 *///
	@RequestMapping(value = "attendJob/createAttendScheduleJobDiv.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap createAttendScheduleJobDiv(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			List trgUsers = (List)params.get("trgUsers");
			List trgLists = (List)params.get("trgLists");
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
//			reqMap.put("SchSeq", params.get("SchSeq"));
			reqMap.put("StartDate", params.get("StartDate"));
			reqMap.put("EndDate", params.get("EndDate"));
			reqMap.put("HolidayFlag", params.get("HolidayFlag"));
			reqMap.put("WeekFlag", params.get("WeekFlag"));

			returnObj = attendJobSvc.createAttendScheduleJobDiv(reqMap, trgUsers, trgLists);
			returnObj.put("status", Return.SUCCESS);
			
		} catch(NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	@RequestMapping(value = "attendJob/copyAttendScheduleJob.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap copyAttendScheduleJob(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			List trgUsers = (List)params.get("trgUsers");
			List trgDates = (List)params.get("trgDates");
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("orgJobDate", params.get("orgJobDate"));
			reqMap.put("orgUserCode", params.get("orgUserCode"));
			reqMap.put("HolidayFlag", params.get("HolidayFlag"));
			reqMap.put("WeekFlag", params.get("WeekFlag"));
//			reqMap.put("StartDate", params.get("StartDate"));
//			reqMap.put("EndDate", params.get("EndDate"));

			returnObj = attendJobSvc.copyAttendScheduleJob(reqMap, trgUsers, trgDates);
			returnObj.put("status", Return.SUCCESS);
		} catch(NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	//근무일정수정
	@RequestMapping(value = "attendJob/AttendJobDetailPopup.do", method = RequestMethod.GET)
	public ModelAndView attendJobDetailPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendJobDetailPopup";

		ModelAndView mav = new ModelAndView(returnURL);
		CoviMap reqMap = new CoviMap();
		reqMap.put("JobDate", request.getParameter("JobDate"));
		reqMap.put("UserCode", request.getParameter("UserCode"));

		CoviMap jsonData = attendJobSvc.getAttendDetail(reqMap);

		//간주근로 유형
		CoviList assList= attendCommonSvc.getAssList();
		mav.addObject("assList",	assList);
		mav.addObject("data",	jsonData.get("data"));
		return mav;
	}

	/**
	 * @Method Name : getWorkPlaceList
	 * @작성일 : 2021. 10. 21.
	 * @작성자 : yhshin
	 * @변경이력 :
	 * @Method 설명 : 출, 퇴근지 정보 목록
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "attendJob/getWorkPlaceList.do")
	public @ResponseBody CoviMap getWorkPlaceList(HttpServletRequest request) {
		CoviMap params = new CoviMap();
		CoviMap returnJson = new CoviMap();

		try {
			params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));

			List<CoviMap> dataList = attendJobSvc.getWorkPlaceList(params);
			returnJson.put("workPlaceList", dataList);

			returnJson.put("status", Return.SUCCESS);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnJson.put("status", Return.FAIL);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnJson.put("status", Return.FAIL);
		}
		
		return returnJson;
	}
	
		/**
	* @Method Name : addAttendSchedule
	* @Description : 근무일정 수정
	*/
	@RequestMapping(value = "attendJob/saveAttendJob.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveAttendJob(HttpServletRequest request,HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params = AttendUtils.requestToCoviMap(request);
			int cnt =0;
			if (params.get("NextDayYn") == null ) params.put("NextDayYn", "N");
			if (params.get("AssYn") == null ) params.put("AssYn", "N");
			if (params.get("AllowRadius").equals("") ) params.put("AllowRadius", "0");
			
			params.put("URCode", request.getParameter("UserCode"));
			cnt = attendJobSvc.saveAttendJob(params);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장");
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	 * @Method Name : delAttendJob
	 * @작성일 : 2019. 6. 18.
	 * @작성자 :
	 * @변경이력 : 근무일정 삭제
	 * @Method 설명 : 근무일정삭제
	 * @RequestBody params
	 * @HttpServletRequest request
	 */
	@RequestMapping(value = "attendJob/delAttendJob.do")
	public  @ResponseBody CoviMap delAttendJob(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			List jsonObject = (List)params.get("dataList");
			CoviMap returnObj = new CoviMap();
			int resultCnt = attendJobSvc.delAttendJob(jsonObject);
			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnList;

		
	}
	
	/**
	 * @Method Name : confirmAttendJob
	 * @작성일 : 2019. 6. 18.
	 * @작성자 :
	 * @변경이력 : 근무일정 확정
	 * @Method 설명 : 근무일정확정
	 * @RequestBody params
	 * @HttpServletRequest request
	 */
	@RequestMapping(value = "attendJob/confirmAttendJob.do")
	public  @ResponseBody CoviMap confirmAttendJob(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			List jsonObject = (List)params.get("dataList");
			CoviMap returnObj = new CoviMap();
			int resultCnt = attendJobSvc.confirmAttendJob(jsonObject, "Y");
			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnList;

		
	}
	
	/**
	 * @Method Name : confirmAttendJob
	 * @작성일 : 2019. 6. 18.
	 * @작성자 :
	 * @변경이력 : 근무일정 확정취소
	 * @Method 설명 : 근무일정확정
	 * @RequestBody params
	 * @HttpServletRequest request
	 */
	@RequestMapping(value = "attendJob/confirmCancelAttendJob.do")
	public  @ResponseBody CoviMap confirmCancelAttendJob(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			List jsonObject = (List)params.get("dataList");
			CoviMap returnObj = new CoviMap();
			int resultCnt = attendJobSvc.confirmAttendJob(jsonObject, "N");
			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnList;

		
	}
	
	/**
	 * @Method Name : reapplyAttendScheduleJob
	 * @작성일 : 2019. 6. 18.
	 * @Method 설명 : 재반영
	 * @HttpServletRequest request
	 */
	@RequestMapping(value = "attendJob/reapplyAttendScheduleJob.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap reapplyAttendScheduleJob(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("SchSeq", request.getParameter("SchSeq"));
			reqMap.put("StartDate", request.getParameter("StartDate"));
			reqMap.put("EndDate", request.getParameter("EndDate"));
//			reqMap.put("HolidayFlag", params.get("HolidayFlag"));

			returnObj = attendJobSvc.reapplyAttendScheduleJob(reqMap);
			returnObj.put("resultCnt", reqMap.get("RetCount"));
			returnObj.put("result", "ok");
			returnObj.put("status", Return.SUCCESS);
			
		} catch(NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	/**
	 * @Method Name : reapplyAttendHolidayJob
	 * @작성일 : 2019. 6. 18.
	 * @Method 설명 : 휴무일 설정
	 * @HttpServletRequest request
	 */
	@RequestMapping(value = "attendJob/reapplyAttendHolidayJob.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap reapplyAttendHolidayJob(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("HolidayStart", request.getParameter("HolidayStart"));
			reqMap.put("HolidayEnd", request.getParameter("HolidayEnd"));
			reqMap.put("GoogleYn", request.getParameter("GoogleYn"));
//			reqMap.put("HolidayFlag", params.get("HolidayFlag"));

			returnObj = attendJobSvc.reapplyAttendHolidayJob(reqMap);
			returnObj.put("resultCnt", reqMap.get("RetCount"));
			returnObj.put("result", "ok");
			returnObj.put("status", Return.SUCCESS);
		} catch(NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}

	/**
	 * @Method Name : getAttendJobView
	 * @작성일 : 2021. 08. 17.
	 * @작성자 : nkpark
	 * @변경이력 : 최초생성
	 * @Method 설명 : 근무일정 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */

	@RequestMapping(value = "attendJob/getAttendJobView.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAttendJobView(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);
			String mode = StringUtil.replaceNull(request.getParameter("mode"), "");
			
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
			                String[] orgOrders = orgMapOrderSet.split("\\|");
			                params.put("orgOrders", orgOrders);
			}
			
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("DomainCode", SessionHelper.getSession("DN_ID"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			switch (mode)
			{
				case "D":	//일간
					resultList = attendJobSvc.getAttendJobViewDay(params);
					break;
				case "W":	//주간
					resultList = attendJobSvc.getAttendJobViewWeek(params);
					break;
				case "M":	//월간
					resultList = attendJobSvc.getAttendJobViewMonth(params);
					break;
				default :
					break;
			}

			if (resultList.get("page") != null){
				returnList.put("page", resultList.get("page"));
			}

			returnList.put("list", resultList.get("list"));
			if (resultList.get("avg") != null) returnList.put("avg", resultList.get("avg"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			if(mode.equals("M")){
				returnList.put("colNumWeeks", resultList.get("colNumWeeks"));
				returnList.put("weeksNum", resultList.get("weeksNum"));
				returnList.put("rangeStartDate",	resultList.get("rangeStartDate").toString());
				returnList.put("rangeEndDate",	resultList.get("rangeEndDate").toString());
				returnList.put("ThisYearWeeksNum",	resultList.get("ThisYearWeeksNum"));
				returnList.put("LastYearWeeksNum",	resultList.get("LastYearWeeksNum"));
				returnList.put("listRangeFronToDate",	resultList.get("listRangeFronToDate"));
				returnList.put("weeksCnt",	resultList.get("weeksCnt"));
				returnList.put("excelList",	resultList.get("excelList"));
				returnList.put("excelHCol",	resultList.get("excelHCol"));
			}
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}


	@RequestMapping(value = "attendJob/getAttendJobViewExcelDownPopup.do", method = RequestMethod.GET)
	public ModelAndView getAttendJobViewExcelDownPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("user/attend/AttendJobViewerExcelDownPopup");
		String StartDate = request.getParameter("StartDate");
		String EndDate = request.getParameter("EndDate");
		String mode = request.getParameter("mode");

		mav.addObject("StartDate",StartDate);
		mav.addObject("EndDate",EndDate);
		mav.addObject("mode",mode);
		mav.addObject("searchText",request.getParameter("searchText"));
		mav.addObject("weeklyWorkType",request.getParameter("weeklyWorkType"));
		mav.addObject("weeklyWorkValue",request.getParameter("weeklyWorkValue"));
		return mav;
	}


	@RequestMapping(value = "attendJob/getAttendJobViewExcelDownload.do" , method = RequestMethod.POST)
	public void getAttendJobViewExcelDownload(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultList = new CoviMap();
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("DomainCode", SessionHelper.getSession("DN_ID"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("StartDate", request.getParameter("StartDate"));
			params.put("EndDate", request.getParameter("EndDate"));
			params.put("mode", request.getParameter("mode"));
			params.put("DeptCode", request.getParameter("DeptCode"));
			params.put("searchText", request.getParameter("searchText"));
			params.put("weeklyWorkType", request.getParameter("weeklyWorkType"));
			params.put("weeklyWorkValue", request.getParameter("weeklyWorkValue"));

			CoviMap excelMap= new CoviMap();
			String FileName="";

			switch (request.getParameter("mode"))
			{/*
				case "D":	//일간
					excelMap.put("title", "근무일정(일간)");
					FileName = "AttendJobDay";
					resultList = attendJobSvc.getAttendJobDay(params);
					break;*/
				case "W":	//주간
					excelMap.put("title", "근무일정(주간)");
					FileName = "AttendJobViewWeek";
					resultList = attendJobSvc.getAttendJobViewWeek(params);
					break;
				case "M" :	//월간
				case "L":	//목록
					excelMap.put("title", "근무일정(주단위)");
					FileName = "AttendJobViewMonth";
					resultList = attendJobSvc.getAttendJobViewMonth(params);
					break;
				default : break;
			}

			excelMap.put("StartDate", params.get("StartDate"));
			excelMap.put("EndDate", params.get("EndDate"));
			CoviList userList = (CoviList)resultList.get("list");
			if ("D".equals(request.getParameter("mode"))){
				CoviList excelList = new CoviList();
				for(int i=0; i < userList.size(); i++){
					CoviMap dayMap = (CoviMap)userList.get(i);
					dayMap.put("AttDayTime", AttendUtils.maskTime(dayMap.getString("AttDayStartTime"))+"~"+AttendUtils.maskTime(dayMap.getString("AttDayEndTime")));
					dayMap.put("AttDayAC", AttendUtils.convertSecToStr(dayMap.get("AttDayAC"),"H"));
					if (!dayMap.getString("AttDayStartTime").equals("")){
						int AttDayStartTime = Integer.parseInt(dayMap.getString("AttDayStartTime"));
						int AttDayEndTime = Integer.parseInt(dayMap.getString("AttDayEndTime"));
						for (int j=0; j<24;j++){
							if (j >= Math.floor(AttDayStartTime/100) && j*100 < AttDayEndTime){
								dayMap.put("Day_"+j, "○");
							}
						}
					}
					excelList.add(dayMap);
				}

				excelMap.put("list", excelList);
			}
			else {
				excelMap.put("list", resultList.get("list"));
				excelMap.put("excelList", resultList.get("excelList"));
				excelMap.put("excelHCol", resultList.get("excelHCol"));

			}
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

		} catch(IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
}
