package egovframework.covision.groupware.attend.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLDecoder;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.BorderExtent;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.ss.util.PropertyTemplate;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;


import org.json.simple.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import com.google.gson.Gson;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.LogHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.ExcelUtil;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;
import egovframework.covision.groupware.attend.user.service.AttendUserStatusSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import net.sf.jxls.transformer.XLSTransformer;

@Controller
@RequestMapping("/attendUserSts")
public class AttendUserStatusCon {
	private final Logger LOGGER = LogManager.getLogger(AttendUserStatusCon.class);

	LogHelper logHelper = new LogHelper();
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@Autowired
	AttendCommonSvc attendCommonSvc;
	@Autowired
	AttendUserStatusSvc attendUserStatusSvc;
	
	
	/**
	  * @Method Name : getMyAttStatus
	  * @작성일 : 2020. 4. 24.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 내 근태현황 조회
	  * @param request
	  * @param response
	  * @return
	  */
	@SuppressWarnings("unchecked")
	@RequestMapping( value= "/getMyAttStatus.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyAttStatus(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		String targetDate = request.getParameter("targetDate")!=null&&!"".equals(request.getParameter("targetDate"))?request.getParameter("targetDate"):ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
		String dateTerm = request.getParameter("dateTerm");
		String userCode = SessionHelper.getSession("USERID");
		String deptCode = SessionHelper.getSession("DEPTID");
		String companyCode = SessionHelper.getSession("DN_Code");
		
		try{
			//권한별 검색가능 사용자 코드 조회 
			CoviMap userMap = new CoviMap();
			userMap.put("sUserCode", userCode);
			userMap.put("sDeptCode", deptCode);
			userMap.put("UserCode", userCode);
			userMap.put("DeptCode", deptCode);
//			CoviList userCodeList = attendCommonSvc.getUserListByAuthCoviList(userMap);
			CoviList userCodeList = new CoviList();
			userCodeList.add(userMap);

			CoviMap attMap = new CoviMap();
			CoviList jobHisList = new CoviList();
			CoviList attMonthList = new CoviList();
			
			if("M".equals(dateTerm)){
				CoviMap params = new CoviMap();
				params.put("TargetDate",targetDate);
				params.put("DateTerm","M");
				params.put("CompanyCode",companyCode);
				params.put("userCodeList", userCodeList);
				CoviMap monthMap = attendUserStatusSvc.getUserAttendance(params);
				attMonthList.add(monthMap);
				String pTargetDate = monthMap.getString("sDate");
				for(int i=0;i<6;i++){
					params = new CoviMap();
					params.put("TargetDate",pTargetDate);
					params.put("DateTerm","W");
					params.put("CompanyCode",companyCode);
					params.put("userCodeList", userCodeList);
					CoviMap attMonthMap = attendUserStatusSvc.getUserAttendance(params);
					attMonthList.add(attMonthMap);
					String p_eDate = attMonthMap.getString("p_eDate");
					if(AttendUtils.removeMaskAll(targetDate).substring(0,6).equals(p_eDate.substring(0,6))){
						pTargetDate = p_eDate;
					}else{
						break;
					}
				}
			}else{
				CoviMap params = new CoviMap();
				params.put("TargetDate",targetDate);
				params.put("DateTerm",dateTerm);
				params.put("CompanyCode",companyCode);
				params.put("userCodeList", userCodeList);

				attMap = attendUserStatusSvc.getUserAttendance(params);

				String dayScope = attendUserStatusSvc.getDayScope(dateTerm,targetDate,companyCode);
				String sDate = dayScope.split("/")[0];
				String eDate = dayScope.split("/")[1];

				CoviMap jobParams = new CoviMap();
				jobParams.put("UserCode", userCode);
				jobParams.put("CompanyCode", companyCode);
				jobParams.put("StartDate", sDate);
				jobParams.put("EndDate", eDate);

				jobParams.put("lang",  SessionHelper.getSession("lang"));

				jobHisList = attendUserStatusSvc.getUserJobHistory(jobParams);
			}

			returnObj.put("attMonthList", attMonthList);
			returnObj.put("attMap", attMap);
			returnObj.put("jobHisList", jobHisList);
			returnObj.put("status", Return.SUCCESS);
		} catch(ArrayIndexOutOfBoundsException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
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
	  * @Method Name : goAttMyStatusPopup
	  * @작성일 : 2020. 5. 18.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 내 근태현황 상세 팝업
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/goAttMyStatusPopup.do", method = RequestMethod.GET)
	public ModelAndView goAttMyStatusPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("user/attend/AttendMyStatusPopup");
		String targetDate = request.getParameter("targetDate");
		String userCode = request.getParameter("userCode");
		String mngType = request.getParameter("mngType");
		mav.addObject("userCode",userCode);
		mav.addObject("targetDate",targetDate);
		mav.addObject("mngType",mngType);
		mav.addObject("authType",	attendCommonSvc.getUserAuthType());
		return mav; 
	}
	
	 
	/**
	  * @Method Name : getUserAttendance
	  * @작성일 : 2020. 4. 29.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 매니저 - 근태현황 조회
	  * @param request
	  * @param response
	  * @return
	  */
	@RequestMapping( value= "/getUserAttendance.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserAttendance(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		String targetDate = request.getParameter("targetDate");
		String dateTerm = request.getParameter("dateTerm");
//		String deptList = request.getParameter("deptList");
		String groupPath = request.getParameter("groupPath");
		String sUserTxt = request.getParameter("sUserTxt");
		String companyCode = SessionHelper.getSession("DN_Code");

		String sJobTitleCode = request.getParameter("sJobTitleCode");
		String sJobLevelCode = request.getParameter("sJobLevelCode");

		int pageSize = Integer.parseInt(StringUtil.replaceNull(request.getParameter("pageSize"), "1"));
		int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
		
		try{
			CoviMap userMap = new CoviMap();
			CoviMap page = new CoviMap();
			
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
			                String[] orgOrders = orgMapOrderSet.split("\\|");
			                userMap.put("orgOrders", orgOrders);
			}
//			userMap.put("sDeptCode", deptList);
			userMap.put("groupPath", groupPath);
			userMap.put("pageSize", pageSize);
			userMap.put("pageNo", pageNo);
			userMap.put("sUserTxt", sUserTxt);
			userMap.put("sJobTitleCode", sJobTitleCode);
			userMap.put("sJobLevelCode", sJobLevelCode);
			userMap.put("retireUser", request.getParameter("retireUser"));
			
			int cnt = attendCommonSvc.getUserListByAuthCoviListCnt(userMap);
			page = AttendUtils.setPagingData(pageNo, pageSize, cnt);
			
			userMap.addAll(page);
			
			//권한별 검색가능 사용자 코드 조회
			CoviList userCodeList = attendCommonSvc.getUserListByAuthCoviList(userMap);
			CoviMap attMap = new CoviMap();
			if(userCodeList.size()>0){
				CoviMap params = new CoviMap();
				params.put("TargetDate",targetDate);
				params.put("DateTerm",dateTerm);
				params.put("CompanyCode",companyCode);
				params.put("userCodeList", userCodeList);

				attMap = attendUserStatusSvc.getUserAttendance(params);
			}

			if(pageNo==1) {
				returnObj.put("page", page);
			}

			returnObj.put("loadCnt", userCodeList.size());
			returnObj.put("data", attMap);
			returnObj.put("monthlyMaxWorkTime", attendCommonSvc.getMonthlyMaxWorkTime(targetDate));
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
	  * @Method Name : getMyAttStatusInfo
	  * @작성일 : 2020. 6. 2.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 사용자 근태현황 데이터 조회
	  * @param request
	  * @param response
	  * @return
	  */
	@RequestMapping( value= "/getMyAttStatusInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyAttStatusInfo(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		String targetDate = request.getParameter("targetDate");
		String sUserCode = request.getParameter("sUserCode");
		String companyCode = SessionHelper.getSession("DN_Code");
		try{
			CoviMap userMap = new CoviMap();
			userMap.put("sUserCode", sUserCode);
			//권한별 검색가능 사용자 코드 조회
			CoviList userCodeList = attendCommonSvc.getUserListByAuthCoviList(userMap);
			CoviMap attMap = new CoviMap();
			CoviList appMap = new CoviList();
			if(userCodeList.size()>0){
				CoviMap params = new CoviMap();
				params.put("TargetDate",targetDate);
				params.put("CompanyCode",companyCode);
				params.put("userCodeList", userCodeList);
				params.put("UserCode", ((CoviMap)userCodeList.get(0)).get("UserCode"));
				attMap = attendUserStatusSvc.getUserAttendance(params);
				appMap = attendUserStatusSvc.getUserApprovalList(params);
			} 
			returnObj.put("attMap", attMap);
			returnObj.put("appMap", appMap);
			returnObj.put("monthlyMaxWorkTime", attendCommonSvc.getMonthlyMaxWorkTime(targetDate));
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
	  * @Method Name : goAttUserStatusSetPopup
	  * @작성일 : 2020. 5. 7.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근태기록 추가 수정 팝업
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/goAttUserStatusSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goAttUserStatusSetPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("user/attend/AttendUserStatusSetPopup");
		
		CoviMap params = new CoviMap();
		String targetDate = request.getParameter("targetDate");
		String userCode = request.getParameter("userCode");
		String companyCode = SessionHelper.getSession("DN_Code");
		
		if(userCode!=null && !"".equals(userCode)){
			CoviMap attMap = attendUserStatusSvc.getUserAttData(userCode,companyCode,targetDate);
			//개행 문자 처리..
			attMap.put("UserEtc",attMap.getString("UserEtc").replaceAll("\n", "<br>"));
			attMap.put("Etc",attMap.getString("Etc").replaceAll("\n", "<br>"));
			CoviMap jo = new CoviMap();
			jo.putAll(attMap);
			mav.addObject("attMap",jo);
		}
		
		return mav; 
	}
	

	/**
	  * @Method Name : getUserAttData
	  * @작성일 : 2020. 5. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 지정일 별 사용자 근태 기록 조회
	  * @param request
	  * @param response
	  * @return
	  */
	@RequestMapping( value= "/getUserAttData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserAttData(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		try{
			String targetDate = request.getParameter("targetDate");
			String userCode = request.getParameter("userCode");
			String companyCode = SessionHelper.getSession("DN_Code");
			
			CoviMap attMap = attendUserStatusSvc.getUserAttData(userCode,companyCode,targetDate);
			CoviMap jo = new CoviMap();
			jo.putAll(attMap);
			
			returnObj.put("attMap", attMap);
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
	  * @Method Name : getUserJobHisInfoList
	  * @작성일 : 2020. 5. 11.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기타근무 상태 리스트 조회
	  * @param request
	  * @param response
	  * @return
	  */
	@RequestMapping( value= "/getUserJobHisInfoList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserJobHisInfoList(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		try{
			String targetDate = request.getParameter("targetDate");
			String userCode = request.getParameter("userCode");
			String companyCode = SessionHelper.getSession("DN_Code");
			CoviMap params = new CoviMap();
			params.put("TargetDate", targetDate);
			params.put("UserCode", userCode);
			params.put("CompanyCode", companyCode);
			params.put("lang",  SessionHelper.getSession("lang"));
			
			CoviList jobHistory = attendUserStatusSvc.getUserJobHistory(params);
			returnObj.put("jobHistory", jobHistory);
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
	  * @Method Name : goAttJobHisPopup
	  * @작성일 : 2020. 5. 11.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기타근무기록 수정 팝업
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/goAttJobHisPopup.do", method = RequestMethod.GET)
	public ModelAndView goAttJobHisPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("user/attend/AttendUserStatusJobHisPopup");
		
		
		String targetDate = request.getParameter("targetDate");
		String userCode = request.getParameter("userCode");
		String jobHisSeq = request.getParameter("jobHisSeq");
		String companyCode = SessionHelper.getSession("DN_Code"); 
		
		CoviMap params = new CoviMap();
		params.put("CompanyCode", companyCode);
		params.put("TargetDate", targetDate);
		params.put("UserCode", userCode);
		params.put("JobHisSeq", jobHisSeq); 
		CoviMap returnMap = attendUserStatusSvc.getUserAttJobSts(params);
		
		CoviMap data = new CoviMap();
		data.putAll(returnMap);
		
		mav.addObject("data",data);
		mav.addObject("mngType",request.getParameter("mngType"));
		
		return mav; 
	}
	

	/**
	  * @Method Name : setUserJobHisInfo
	  * @작성일 : 2020. 5. 19.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 :지정일 기타근무 상태 수정 요청
	  * @param map
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping( value= "/setUserJobHisInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setUserJobHisInfo(@RequestBody Map<String, Object> map, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		try{
			CoviMap params = new CoviMap();
			List ReqData = (List)map.get("ReqData");
			params.put("ReqGubun", map.get("ReqGubun"));
			params.put("Comment", map.get("Comment"));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("RegUserCode", SessionHelper.getSession("USERID"));
			
			CoviMap jo = attendUserStatusSvc.setJobHisData(params,ReqData);
			returnObj.put("status", jo.get("status"));
			returnObj.put("dupFlag", jo.get("dupFlag"));
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
	  * @Method Name : goAttUserStatusExPopup
	  * @작성일 : 2020. 5. 11.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 연장근무 일정 수정 팝업
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/goAttUserStatusExPopup.do", method = RequestMethod.GET)
	public ModelAndView goAttUserStatusExPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("user/attend/AttendUserStatusExPopup");
		
		String targetDate = request.getParameter("targetDate");
		String userCode = request.getParameter("userCode"); 
		String companyCode = SessionHelper.getSession("DN_Code");
		String reqType = request.getParameter("reqType");
		String exHoSeq = request.getParameter("exHoSeq");
		
		CoviMap params = new CoviMap();
		params.put("UserCode", userCode);
		params.put("JobDate", targetDate);
		params.put("CompanyCode", companyCode);
		params.put("ReqType", reqType); 
		params.put("ExHoSeq", exHoSeq);
		
		CoviList exList = attendUserStatusSvc.getUserExtentionInfo(params);
		CoviList ja = new CoviList();
		ja.addAll(exList);
		mav.addObject("exList",ja);
		mav.addObject("reqType",reqType);
		mav.addObject("mngType",request.getParameter("mngType"));

		return mav; 
	}
	

	/**
	  * @Method Name : setUserExHoInfo
	  * @작성일 : 2020. 5. 19.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 연장 휴일근무 수정
	  * @param map
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping( value= "/setUserExHoInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setUserExHoInfo(@RequestBody Map<String, Object> map, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		try{
			CoviMap params = new CoviMap();
			List ReqData = (List)map.get("ReqData");
			params.put("ReqType", map.get("ReqType"));
			params.put("ReqGubun", map.get("ReqGubun"));
			params.put("Comment", map.get("Comment"));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			
			attendUserStatusSvc.setExHoData(params,ReqData);
			
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
	  * @Method Name : getUserAttendanceList
	  * @작성일 : 2020. 5. 11.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근태현황 목록형 조회
	  * @param request
	  * @param response
	  * @return
	  */
	@SuppressWarnings("unchecked")
	@RequestMapping( value= "/getUserAttendanceList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserAttendanceList(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		String targetDate = request.getParameter("targetDate");
		String dateTerm = request.getParameter("dateTerm");
//		String deptList = request.getParameter("deptList");
		String groupPath = request.getParameter("groupPath");
		String sUserTxt = request.getParameter("sUserTxt");
		String companyCode = SessionHelper.getSession("DN_Code");
		String sJobTitleCode = request.getParameter("sJobTitleCode");
		String sJobLevelCode = request.getParameter("sJobLevelCode");
		
		try{
			CoviMap userMap = new CoviMap();
//			userMap.put("sDeptCode", deptList);
			userMap.put("groupPath", groupPath);
			userMap.put("sUserTxt", sUserTxt);
			userMap.put("sJobTitleCode", sJobTitleCode);
			userMap.put("sJobLevelCode", sJobLevelCode);
			//권한별 검색가능 사용자 코드 조회
			//CoviList userCodeList = attendCommonSvc.getUserListByAuthCoviList(userMap);
			
			CoviMap params = new CoviMap();
			
			String domainID = SessionHelper.getSession("DN_ID");
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
			                String[] orgOrders = orgMapOrderSet.split("\\|");
			                params.put("orgOrders", orgOrders);
			}
			
			params.put("TargetDate",targetDate);
			params.put("DateTerm",dateTerm);
			params.put("StartDate",request.getParameter("startDate"));
			params.put("EndDate",request.getParameter("endDate"));

			params.put("sUserTxt", sUserTxt);
			params.put("sJobTitleCode", sJobTitleCode);
			params.put("sJobLevelCode", sJobLevelCode);

			params.put("CompanyCode",companyCode);
			params.put("GroupPath", groupPath);
			params.put("AttStatus", request.getParameter("AttStatus"));
			params.put("SchSeq", request.getParameter("SchSeq"));
			//params.put("userCodeList", userCodeList);
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			
			CoviMap attMap = attendUserStatusSvc.getUserAttendanceList(params);

			returnObj.put("page", attMap.get("page"));
			returnObj.put("list", attMap.get("list"));
			returnObj.put("attMap",attMap);
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
	

	@RequestMapping( value= "/getDatScope.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDatScope(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();

		try{  
			String targetDate = StringUtil.replaceNull(request.getParameter("targetDate"), "");
			String dateTerm = StringUtil.replaceNull(request.getParameter("dateTerm"), "");
			String deptList = request.getParameter("deptList");
			String sUserTxt = request.getParameter("sUserTxt"); 
			String companyCode = SessionHelper.getSession("DN_Code");
			 
			CoviMap dayMap = attendUserStatusSvc.setDayParams(dateTerm,targetDate,companyCode);
			
			returnObj.put("dayMap",dayMap);
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
	  * @Method Name : excelDownloadForAttMyStatus
	  * @작성일 : 2020. 5. 26.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 내 근태현황 엑셀 다운로드
	  * @param request
	  * @param response
	  */
	@RequestMapping(value = "/excelDownloadForAttMyStatus.do" , method = RequestMethod.POST)
	public void excelDownloadForAttMyStatus(HttpServletRequest request, HttpServletResponse response) {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			String FileName = "AttendMyStatus.xlsx";
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//AttendMyInfo_templete.xlsx");
			
			String targetDate = request.getParameter("targetDate")!=null&&!"".equals(request.getParameter("targetDate"))?request.getParameter("targetDate"):ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
			String dateTerm = request.getParameter("dateTerm");
			String userCode = SessionHelper.getSession("USERID");
			String companyCode = SessionHelper.getSession("DN_Code");
			String companyId = SessionHelper.getSession("DN_ID");
			String deptCode = SessionHelper.getSession("GR_Code");
			 
			CoviMap dayParams = attendUserStatusSvc.setDayParams(dateTerm, targetDate, companyCode);
			String startDate = dayParams.getString("sDate");
			String endDate = dayParams.getString("eDate");

			CoviMap params = attendUserStatusSvc.getMyAttExcelInfo(userCode,deptCode,companyCode,companyId,startDate,endDate);

			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);

			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			logHelper.getCurrentClassErrorLog(e);
		} catch (NullPointerException e) {
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			logHelper.getCurrentClassErrorLog(e);
		} finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}

	
	@RequestMapping(value = "/excelDownloadForAttMngStatus.do" , method = RequestMethod.POST)
	public void excelDownloadForAttMngStatus(HttpServletRequest request, HttpServletResponse response) {

		try {
			String targetDate = request.getParameter("targetDate")!=null&&!"".equals(request.getParameter("targetDate"))?request.getParameter("targetDate"):ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
			String startDate = request.getParameter("StartDate");
			String endDate = StringUtil.replaceNull(request.getParameter("EndDate"), "");
			
			String dateTerm = request.getParameter("dateTerm");
			String dataMode = StringUtil.replaceNull(request.getParameter("dataMode"), "");
			String outputNumtype = StringUtil.replaceNull(request.getParameter("outputNumtype"), "");
			
			boolean bOutputNumType = false;
			if(outputNumtype.equalsIgnoreCase("Y")){
				bOutputNumType = true;
			}
			
			String groupPath = request.getParameter("groupPath"); 
			String sUserTxt = request.getParameter("sUserTxt");
			String companyCode = SessionHelper.getSession("DN_Code");
			
			String sJobTitleCode = request.getParameter("sJobTitleCode");
			String sJobLevelCode = request.getParameter("sJobLevelCode");			
			
			if (startDate == null){
				CoviMap dayParams = attendUserStatusSvc.setDayParams(dateTerm, targetDate, companyCode);
				startDate = dayParams.getString("sDate");
				endDate = dayParams.getString("eDate");
			}	
			
			CoviMap reqParams = new CoviMap();
			reqParams.put("GroupPath", groupPath);
			reqParams.put("StartDate", startDate); 
			reqParams.put("EndDate", endDate); 
			reqParams.put("DateTerm","");
			reqParams.put("CompanyCode",companyCode);
			reqParams.put("RetireUser",request.getParameter("RetireUser"));
			reqParams.put("AttStatus", request.getParameter("AttStatus"));
			
			reqParams.put("sortColumn", "UserCode asc");
			reqParams.put("sortDirection", ", dayList asc");
			reqParams.put("FirstWeek",Integer.parseInt(RedisDataUtil.getBaseConfig("AttBaseWeek")));
			
			CoviMap attUserMap = attendUserStatusSvc.getUserAttendanceExcelList(reqParams);
			CoviList attUserList  = (CoviList)attUserMap.get("list");
			
			String FileName = "AttendMngStatus"; 
			String excelTitle="";
			CoviList excelList = new CoviList();
			SXSSFWorkbook workbook = new SXSSFWorkbook();
			Sheet sheet = workbook.createSheet();
			Font ttlFont= workbook.createFont(); //폰트 객체 생성
			CellStyle ttlStyle = workbook.createCellStyle();
			
			Font textFont= workbook.createFont(); //폰트 객체 생성
			CellStyle textStyle = workbook.createCellStyle();

			ArrayList<HashMap> excelHeader = new ArrayList<>() ;
			
			
			excelHeader.add(new HashMap<String, String>() {{ put("colName","성명"); put("colWith","50"); put("colKey","DisplayName"); }});
			excelHeader.add(new HashMap<String, String>() {{ put("colName","아이디"); put("colWith","50"); put("colKey","UserCode"); }});
			if (!bOutputNumType) excelHeader.add(new HashMap<String, String>() {{ put("colName","구분"); put("colWith","100"); put("colKey","attendStatusName"); }});
			excelHeader.add(new HashMap<String, String>() {{ put("colName","본부"); put("colWith","100");put("colKey","DeptFullPath"); }});
			excelHeader.add(new HashMap<String, String>() {{ put("colName","부서"); put("colWith","100");put("colKey","DeptName"); }});
			excelHeader.add(new HashMap<String, String>() {{ put("colName","직급"); put("colWith","50");put("colKey","JobPositionName"); }});
			excelHeader.add(new HashMap<String, String>() {{ put("colName","직책"); put("colWith","50");put("colKey","JobTitleName"); }});
			excelHeader.add(new HashMap<String, String>() {{ put("colName","입사일자"); put("colWith","80");put("colKey","EnterDate"); }});
			excelHeader.add(new HashMap<String, String>() {{ put("colName","근무일자"); put("colWith","80");put("colKey","dayList"); }});
			excelHeader.add(new HashMap<String, String>() {{ put("colName","출근시간"); put("colWith","80");put("colKey","v_AttStartTime");}});
			excelHeader.add(new HashMap<String, String>() {{ put("colName","퇴근시간"); put("colWith","80");put("colKey","v_AttEndTime"); }});
			
			if (bOutputNumType){
				excelHeader.add(new HashMap<String, String>() {{ put("colName","일정출근시간"); put("colWith","80");put("colKey","v_AttDayStartTime"); }});
				excelHeader.add(new HashMap<String, String>() {{ put("colName","일정퇴근시간"); put("colWith","80");put("colKey","v_AttDayEndTime"); }});
				
				excelHeader.add(new HashMap<String, String>() {{ put("colName","출근"); put("colWith","80");put("colKey","StartStsName"); }});
				excelHeader.add(new HashMap<String, String>() {{ put("colName","퇴근"); put("colWith","80");put("colKey","EndStsName"); }});
				excelHeader.add(new HashMap<String, String>() {{ put("colName","휴가"); put("colWith","80");put("colKey","VacName"); }});

				excelHeader.add(new HashMap<String, String>() {{ put("colName","인정기준"); put("colWith","80");put("colKey","TotWorkTime"); put("colType","F"); put("colAlign","RIGHT");}});
				excelHeader.add(new HashMap<String, String>() {{ put("colName","실근무기준"); put("colWith","80");put("colKey","v_AttRealTime");put("colType","F"); put("colAlign","RIGHT"); }});
				excelHeader.add(new HashMap<String, String>() {{ put("colName","타각기준"); put("colWith","80");put("colKey","v_startToEnd"); put("colType","F") ;put("colAlign","RIGHT");}});
				
				excelHeader.add(new HashMap<String, String>() {{ put("colName","인정시간"); put("colWith","80");put("colKey","AttRealTime"); put("colType","F"); put("colAlign","RIGHT");}});
				excelHeader.add(new HashMap<String, String>() {{ put("colName","연장"); put("colWith","80");put("colKey","v_ExtenAc"); put("colType","F"); put("colAlign","RIGHT");}});
				excelHeader.add(new HashMap<String, String>() {{ put("colName","휴일"); put("colWith","80");put("colKey","v_HoliAc"); put("colType","F"); put("colAlign","RIGHT");}});
				excelHeader.add(new HashMap<String, String>() {{ put("colName","휴게"); put("colWith","80");put("colKey","AttIdle"); put("colType","F"); put("colAlign","RIGHT");}});
				
				excelHeader.add(new HashMap<String, String>() {{ put("colName","연장시작"); put("colWith","120");put("colKey","ExtenStart"); }});
				excelHeader.add(new HashMap<String, String>() {{ put("colName","연장종료"); put("colWith","120");put("colKey","ExtenEnd"); }});
				excelHeader.add(new HashMap<String, String>() {{ put("colName","휴일시작"); put("colWith","120");put("colKey","HoliStart"); }});
				excelHeader.add(new HashMap<String, String>() {{ put("colName","휴일종료"); put("colWith","120");put("colKey","HoliEnd"); }});
//				AttendUtils.writeExcelRowData(row, 1, excelHeader, userAtt, textFont,textStyle);
				excelTitle = "부서 근태 현황 (" + startDate+"~"+endDate+") RAW";
				workbook = ExcelUtil.makeExcelFile(excelTitle, excelHeader, attUserList);
			}
			else{
				//Condition has no effect
				//String colFormat = bOutputNumType?"":"H";
				String colFormat = "H";
				
				if (dataMode.equals("R")) {
					// 휴게시간
					excelHeader.add(new HashMap<String, String>() {{ put("colName", "휴게시간"); put("colWith", "100"); put("colKey", "AttIdle"); put("colFormat", "H");	}});
					excelHeader.add(new HashMap<String, String>() {{
						put("colName", "타각기준");
						put("colWith", "100");
						put("colKey", "v_startToEnd");
						put("colFormat", colFormat);
					}});
				}else if (dataMode.equals("E")) {
					// 휴게시간
					excelHeader.add(new HashMap<String, String>() {{ put("colName", "휴게시간"); put("colWith", "100"); put("colKey", "AttIdle"); put("colFormat", "H");	}});
					excelHeader.add(new HashMap<String, String>() {{
						put("colName", "실근무기준");
						put("colWith", "100");
						put("colKey", "v_AttRealTime");
						put("colFormat", colFormat);
					}});
				}else {
					excelHeader.add(new HashMap<String, String>() {{ put("colName","실제출근시간"); put("colWith","80");put("colKey","AttStartTimeLate");}});
					excelHeader.add(new HashMap<String, String>() {{ put("colName","실제퇴근시간"); put("colWith","80");put("colKey","AttEndTimeLate"); }});
					// 휴게시간
					excelHeader.add(new HashMap<String, String>() {{ put("colName", "휴게시간"); put("colWith", "100"); put("colKey", "AttIdle"); put("colFormat", "H");	}});
					excelHeader.add(new HashMap<String, String>() {{
						put("colName", "인정기준");
						put("colWith", "100");
						put("colKey", "TotWorkTime");
						put("colFormat", colFormat);
					}});
				}
				
				String  sAddTitle = dataMode.equals("R")? "타각":dataMode.equals("E")? "실":"";
				
				switch (dateTerm){
					case "W":
						excelTitle= "부서 근태 현황(주간)"; 
						FileName = "AttendUserStatusWeekInfo";
						excelHeader.add(new HashMap<String, String>() {{
							put("colName", sAddTitle+"누적시간(주)\r 휴게시간 제외");
							put("colWith", "100");
							put("colKey", "SumWorkTime");
							put("colFormat", colFormat);
						}});
						break;
					case "M":
						excelTitle= "부서 근태 현황(월간)"; 
						FileName = "AttendUserStatusMonthInfo";
						excelHeader.add(new HashMap<String, String>() {{
							put("colName", sAddTitle+"누적시간(주)\r 휴게시간 제외	");
							put("colWith", "100");
							put("colKey", "WeekWorkTime");
							put("colFormat", colFormat);
						}});
						excelHeader.add(new HashMap<String, String>() {{
							put("colName", sAddTitle+"누적시간(월)\r 휴게시간 제외");
							put("colWith", "100");
							put("colKey", "SumWorkTime");
							put("colFormat", colFormat);
						}});
						break;
					default	:
						excelTitle= "부서 근태 현황(기간별)"; 
						FileName = "AttendUserStatusInfo";
						excelHeader.add(new HashMap<String, String>() {{
							put("colName", sAddTitle+"누적시간(주)\r 휴게시간 제외	");
							put("colWith", "100");
							put("colKey", "WeekWorkTime");
							put("colFormat", colFormat);
						}});
						excelHeader.add(new HashMap<String, String>() {{
							put("colName", sAddTitle+"누적시간(기간)\r 휴게시간 제외");
							put("colWith", "100");
							put("colKey", "SumWorkTime");
							put("colFormat", colFormat);
						}});
						break;
				}
				
	
				/*타각 기준에서는 빼기
				if (!dataMode.equals("R")) {
					excelHeader.add(new HashMap<String, String>() {{
						put("colName", "월 누적 시간");
						put("colWith", "10");
						put("colKey", "MonthlyAttAcSum");
						put("colFormat", colFormat);
					}});
				}*/
				excelHeader.add(new HashMap<String, String>() {{ put("colName","기타근무유형"); put("colWith","100");put("colKey","JobStsName"); }});
				excelHeader.add(new HashMap<String, String>() {{ put("colName", "근무유형"); put("colWith", "100"); put("colKey", "SchName"); }});

	
				SimpleDateFormat format = new SimpleDateFormat("yyyymmdd");
	
		        Date FirstDate = format.parse(AttendUtils.removeMaskAll(startDate));
		        Date SecondDate = format.parse(AttendUtils.removeMaskAll(endDate));
		        long calDate = FirstDate.getTime() - SecondDate.getTime(); 
		        long calDateDays = calDate / ( 24*60*60*1000); 
				int diffDay = (int)(Math.abs(calDateDays))+1;
	
				Row rowTitle = sheet.createRow(0);
				AttendUtils.writeExcelCellData(rowTitle, 1, excelTitle, textFont,textStyle);
				sheet.addMergedRegion(new CellRangeAddress(0,0,1,4));
				rowTitle = sheet.createRow(1);
				AttendUtils.writeExcelCellData(rowTitle, 1, "조회: "+startDate+" ~ "+endDate, textFont,textStyle);
				sheet.addMergedRegion(new CellRangeAddress(1,1,1,4));
				
				Row rowHeader = sheet.createRow(2);
	
				AttendUtils.writeExcelHeaderData(rowHeader, 1, excelHeader, ttlFont, ttlStyle);
	
				String UserCode = "";
				String weekO = "";
				int SumWorkTime=0;
				int WeekWorkTime=0;
				CoviList dataList = new CoviList();
				for (int j=0; j < attUserList.size(); j++){
					CoviMap userAtt = attUserList.getMap(j);
					String attendStatusName = "";
					if (AttendUtils.nvlString(userAtt.get("WorkSts"),"").equals("ON")){
						if (userAtt.get("VacName") !=null && !userAtt.get("VacName").equals("")){
							attendStatusName=userAtt.get("VacName").toString();
						}
						
						if (userAtt.get("StartSts") != null){
							if (!("lbl_att_normal_goWork").equals(userAtt.get("StartSts")) && !("lbl_att_goWork").equals(userAtt.get("StartSts"))){
								attendStatusName += (!attendStatusName.equals("")?",":"")+DicHelper.getDic(userAtt.getString("StartSts"));		
							}	
							
							if (userAtt.get("EndSts") != null && !("lbl_att_normal_offWork").equals(userAtt.get("EndSts")) && !("lbl_att_offWork").equals(userAtt.get("EndSts")) && !userAtt.get("StartSts").equals(userAtt.get("EndSts"))){
								attendStatusName += (!attendStatusName.equals("")?",":"")+DicHelper.getDic(userAtt.getString("EndSts"));		
							}	
						}			
								
						if (userAtt.get("StartSts") == null ){
							if (userAtt.getInt("VacCnt") < 1){
								attendStatusName += (!attendStatusName.equals("")?",":"")+"결근";
							}
						}
						
						if (AttendUtils.nvlInt(userAtt.get("ExtenCnt"),0) >0 ){
							attendStatusName+=(!attendStatusName.equals("")?",":"")+"연장근무";
						}					
					} else {
						if (userAtt.get("VacName") !=null && !userAtt.get("VacName").equals("")){
							attendStatusName=userAtt.get("VacName").toString();
						} else {
							if (AttendUtils.nvlInt(userAtt.get("HoliCnt"),0) >0 ){
								attendStatusName="휴일근무";
							} else {
								if (AttendUtils.nvlString(userAtt.get("WorkSts"),"").equals("OFF")) {
									attendStatusName="휴무";
								} else {
									attendStatusName="휴일";
								}
							}
						}	
					}	
					if( ("lbl_att_beingLate").equals(userAtt.get("StartSts")) || ("lbl_att_leaveErly").equals(userAtt.get("EndSts")) ) {
						// 인정근무인 경우, 지각 조퇴시 실제출퇴근시간 표시
						userAtt.put("AttStartTimeLate", userAtt.get("v_AttStartTime"));
						userAtt.put("AttEndTimeLate", userAtt.get("v_AttEndTime"));
					}
					userAtt.put("attendStatusName", attendStatusName);
					if (!dataMode.equals("R") && userAtt.getString("WorkingSystemType").equals("0")) {	//타각이 아닌 경우 일정의 근뮤시간으로 세팅한다.
						userAtt.put("v_AttStartTime", userAtt.get("v_AttDayStartTime"));
						if ( AttendUtils.nvlInt(userAtt.get("ExtenCnt"),0) >0)	//연장근무이면 연장시간
							userAtt.put("v_AttEndTime", userAtt.get("ExtenEnd"));
						else if ( AttendUtils.nvlInt(userAtt.get("HoliCnt"),0) >0) {	//휴일근무이면 연장시간
							userAtt.put("v_AttStartTime", userAtt.get("HoliStart"));
							userAtt.put("v_AttEndTime", userAtt.get("HoliEnd"));
						} else
							userAtt.put("v_AttEndTime", userAtt.get("v_AttDayEndTime"));
					}
						
					
					switch (dataMode){
					case "R":	//타각기준
						SumWorkTime  += userAtt.getInt("v_startToEnd");
						WeekWorkTime += userAtt.getInt("v_startToEnd");
						break;
					case "E":	//실근무기준
						SumWorkTime  += userAtt.getInt("v_AttRealTime");
						WeekWorkTime += userAtt.getInt("v_AttRealTime");
						break;
					default:	//인정기준
						SumWorkTime  += userAtt.getInt("TotWorkTime");
						WeekWorkTime += userAtt.getInt("TotWorkTime");
						break;
						
					}
	
					UserCode = userAtt.getString("UserCode");
					weekO = userAtt.getString("weeko");
					
					if ((j+1)==attUserList.size()){	//마지막 row이면
						userAtt.put("WeekWorkTime",WeekWorkTime);
						userAtt.put("SumWorkTime",SumWorkTime);
					} else {
						CoviMap nextAtt = attUserList.getMap(j+1);
						if (!UserCode.equals(nextAtt.getString("UserCode"))){
							userAtt.put("WeekWorkTime",WeekWorkTime);
							userAtt.put("SumWorkTime",SumWorkTime);
							SumWorkTime=0;
							WeekWorkTime=0;
						} else if (!weekO.equals(nextAtt.getString("weeko"))) {
							userAtt.put("WeekWorkTime",WeekWorkTime);
							WeekWorkTime=0;
						} else {
							userAtt.put("WeekWorkTime","");
							userAtt.put("SumWorkTime","");
						}
					}
					dataList.add(userAtt);
				}
				
				for(int i = (dataList.size()-1); i >= 0; i--){
					CoviMap userAtt = dataList.getMap(i);
					if (i < dataList.size()-1) {
						CoviMap nextAtt = dataList.getMap(i+1);
						if ( (userAtt.getString("UserCode").equals(nextAtt.getString("UserCode"))) 
								&& ("".equals(userAtt.getString("SumWorkTime"))) ) {
							userAtt.put("SumWorkTime",nextAtt.getString("SumWorkTime"));
							if ( (userAtt.getString("weeko").equals(nextAtt.getString("weeko"))) 
									&& ("".equals(userAtt.getString("WeekWorkTime"))) ){
								userAtt.put("WeekWorkTime",nextAtt.getString("WeekWorkTime"));
							}	
						}
					}
				}

				for (int i=0; i<dataList.size(); i++) {
					CoviMap userAtt = dataList.getMap(i);
					Row row = sheet.createRow(i+3);
					AttendUtils.writeExcelRowData(row, 1, excelHeader, userAtt, textFont,textStyle);
				}
				for (int i=0; i<excelHeader.size(); i++) {
					sheet.setColumnWidth(i+1, Integer.parseInt((String)((HashMap)excelHeader.get(i)).get("colWith"))*50 ); 
				}
			}	
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			workbook.write(response.getOutputStream());
			workbook.dispose(); 
			try { workbook.close(); } 
			catch(IOException ignore) { LOGGER.error(ignore.getLocalizedMessage(), ignore); }
			catch(Exception ignore) { LOGGER.error(ignore.getLocalizedMessage(), ignore); }
			
			
		} catch (NullPointerException e) {
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			logHelper.getCurrentClassErrorLog(e);
		}
	}

	@RequestMapping(value = "/excelDownloadForAttMngStatusV2.do" , method = RequestMethod.POST)
	public void/*@ResponseBody JSONObject*/ excelDownloadForAttMngStatusV2(HttpServletRequest request, HttpServletResponse response) {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		CoviMap returnObj = new CoviMap();

		//String str_incld_weeks = request.getParameter("incld_weeks");
		boolean incld_weeks = true;
		/*if(str_incld_weeks!=null && str_incld_weeks.equals("true")){
			incld_weeks =  true;
		}*/

		try {
			String OutpuFileName = "AttendUserStatusInfo.xlsx";
			String FileName = "AttendUserStatusInfo_templete_v2.xlsx";

			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//"+FileName);
			String targetDate = request.getParameter("StartDate")!=null&&!"".equals(request.getParameter("StartDate"))?request.getParameter("StartDate"):ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
			String dateTerm = StringUtil.replaceNull(request.getParameter("dateTerm"), "");
			String companyCode = SessionHelper.getSession("DN_Code");
			String companyId = SessionHelper.getSession("DN_ID");
			//String deptCode = SessionHelper.getSession("GR_Code");
			String groupPath = request.getParameter("groupPath");
			String attStatus = request.getParameter("AttStatus");
			String outputNumtype = request.getParameter("outputNumtype");

			String startDate = "";
			String endDate = "";

			if(dateTerm.equals("M")) {
				//CoviMap rangeFromToDateMapR = attendUserStatusSvc.getRangeFronToDate(targetDate, incld_weeks);//기본 날일 범위는 전달 후다 포함주
				//startDate = rangeFromToDateMapR.getString("RangeStartDate");
				//endDate = rangeFromToDateMapR.getString("RangeEndDate");
				startDate = request.getParameter("StartDate");
				endDate = request.getParameter("EndDate");
			}else{
				CoviMap dayParams = attendUserStatusSvc.setDayParams(dateTerm, targetDate, companyCode);
				startDate = dayParams.getString("sDate");
				endDate = dayParams.getString("eDate");
			}

			CoviMap params = attendUserStatusSvc.getUserAttExcelInfoV2(groupPath,companyCode,companyId,startDate,endDate, attStatus, outputNumtype);

			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);

			response.setHeader("Content-Disposition", "attachment;fileName=\""+OutpuFileName+"\";");
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setContentType("application/vnd.ms-excel;charset=utf-8");
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();

			returnObj.put("data", params);
		} catch (IOException e) {
			logHelper.getCurrentClassErrorLog(e);
		} catch (NullPointerException e) {
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			logHelper.getCurrentClassErrorLog(e);
		} finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
		//return returnObj;
	}
	/**
	  * @Method Name : getUserExhoInfoList
	  * @작성일 : 2020. 5. 11.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 연장/휴일근무 상태 리스트 조회
	  * @param request
	  * @param response
	  * @return
	  */
	@RequestMapping( value= "/getUserExhoInfoList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserExhoInfoList(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		try{
			String targetDate = request.getParameter("targetDate");
			String userCode = request.getParameter("userCode");
			String jobStsName = request.getParameter("jobStsName");
			String companyCode = SessionHelper.getSession("DN_Code");
			CoviMap params = new CoviMap();
			params.put("JobDate", targetDate); 
			params.put("UserCode", userCode);
			params.put("CompanyCode", companyCode); 
			params.put("ReqType", jobStsName); 
			
			CoviList exHoList = attendUserStatusSvc.getUserExtentionInfo(params);
			returnObj.put("exHoList", exHoList);
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

	@RequestMapping( value= "/setUserEtc.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setUserEtc(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		try{
			String targetDate = request.getParameter("targetDate");
			String userCode = request.getParameter("userCode");
			String userEtc = request.getParameter("userEtc");
			String companyCode = SessionHelper.getSession("DN_Code");
			String regUserCode = SessionHelper.getSession("USERID");
			
			
			CoviMap params = new CoviMap();
			params.put("TargetDate", targetDate); 
			params.put("UserCode", userCode);
			params.put("CompanyCode", companyCode); 
			params.put("UserEtc", userEtc); 
			params.put("RegUserCode", regUserCode); 
			
			attendUserStatusSvc.setUserEtc(params);
			
			returnObj.put("status", Return.SUCCESS);   
		} catch(NullPointerException e){
			returnObj.put("status", Return.FAIL);
			logHelper.getCurrentClassErrorLog(e);
		} catch(Exception e){
			returnObj.put("status", Return.FAIL);
			logHelper.getCurrentClassErrorLog(e);
		}
		return returnObj;
	}
	

	@RequestMapping(value = "/goAttUserExcelDownPopup.do", method = RequestMethod.GET)
	public ModelAndView goAttUserExcelDownPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("user/attend/AttendUserExcelDownPopup");
		String StartDate = request.getParameter("StartDate");
		String EndDate = request.getParameter("EndDate");

		mav.addObject("StartDate",StartDate);
		mav.addObject("EndDate",EndDate);
		mav.addObject("retireUser",request.getParameter("retireUser"));
		mav.addObject("pageType",request.getParameter("pageType"));
		return mav;
	}
	
	
	@RequestMapping( value= "/getMyContentWebpartInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyContentWebpartInfo(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		try{
			String targetDate =  ComUtils.GetLocalCurrentDate("yyyy/MM/dd");
			String companyCode = SessionHelper.getSession("DN_Code");
			String userCode = SessionHelper.getSession("USERID");
			
			CoviMap dateMap  = attendUserStatusSvc.setDayParams("W",targetDate,companyCode);
			CoviMap userAttMap = attendUserStatusSvc.getUserAttWorkTimeProc(userCode, companyCode, (String)dateMap.get("sDate"), (String)dateMap.get("eDate"));

			returnObj.put("userAtt", userAttMap);
			returnObj.put("serverTime",ComUtils.GetLocalCurrentDate("yyyy/MM/dd/HH/mm/ss"));
			returnObj.put("status", Return.SUCCESS);   
		} catch(NullPointerException e){
			returnObj.put("status", Return.FAIL);
			logHelper.getCurrentClassErrorLog(e);
		} catch(Exception e){
			returnObj.put("status", Return.FAIL);
			logHelper.getCurrentClassErrorLog(e);
		}
		return returnObj;
	}

	/**
	 * @Method Name : getUserAttendanceViewer
	 * @작성일 : 2021. 8. 24.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 매니저 - 근태현황 조회 2
	 * @param request
	 * @param response
	 * @return
	 */
	@RequestMapping( value= "/getUserAttendanceWeeklyViewer.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserAttendanceWeeklyViewer(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();

		String targetDate = request.getParameter("targetDate");
		String rangeStartDate = request.getParameter("rangeStartDate");
		String rangeEndDate = request.getParameter("rangeEndDate");
		String rangeWeekNum = request.getParameter("rangeWeekNum");
		String dateTerm = request.getParameter("dateTerm");
		String groupPath = request.getParameter("groupPath");
		String companyCode = SessionHelper.getSession("DN_Code");

		int pageSize = Integer.parseInt(StringUtil.replaceNull(request.getParameter("pageSize"), "1"));
		int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
		
		try{
			CoviMap userMap = new CoviMap();
			CoviMap page = new CoviMap();
			
			userMap.put("groupPath", groupPath);
			userMap.put("pageSize", pageSize);
			if("".equals(request.getParameter("weeklyWorkValue"))||"0".equals(request.getParameter("weeklyWorkValue"))) {
				userMap.put("pageNo", pageNo);
			}
			userMap.put("retireUser", request.getParameter("retireUser"));
			
			int cnt = attendCommonSvc.getUserListByAuthCoviListCnt(userMap);
			page = AttendUtils.setPagingData(pageNo, pageSize, cnt);
			userMap.addAll(page);
			
			//권한별 검색가능 사용자 코드 조회
			CoviList userCodeList = attendCommonSvc.getUserListByAuthCoviList(userMap);
			
			if(pageNo==1) {
				returnObj.put("page", page);
			}
			CoviMap attMap = new CoviMap();
			if(userCodeList.size()>0){
				CoviMap params = new CoviMap();
				String domainID = SessionHelper.getSession("DN_ID");

				String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
				if(!orgMapOrderSet.equals("")) {
				                String[] orgOrders = orgMapOrderSet.split("\\|");
				                params.put("orgOrders", orgOrders);
				}
				params.put("TargetDate",targetDate);
				params.put("rangeStartDate",rangeStartDate);
				params.put("rangeEndDate",rangeEndDate);
				params.put("rangeWeekNum",rangeWeekNum);
				params.put("DateTerm",dateTerm);
				params.put("CompanyCode",companyCode);
				params.put("userCodeList", userCodeList);
				params.put("incld_weeks", request.getParameter("incld_weeks"));
				params.put("weeklyWorkType", request.getParameter("weeklyWorkType"));
				params.put("weeklyWorkValue", request.getParameter("weeklyWorkValue"));

				attMap = attendUserStatusSvc.getUserAttendanceWeeklyViewer(params);
			}

			//월 법정근로시간
			int monthlyMaxWorkTime = attendCommonSvc.getMonthlyMaxWorkTime(targetDate);
			attMap.put("monthlyMaxWorkTime", monthlyMaxWorkTime);
			attMap.put("rangeStartDate", rangeStartDate);
			attMap.put("rangeEndDate", rangeEndDate);
			attMap.put("rangeWeekNum", rangeWeekNum);

			returnObj.put("loadCnt", userCodeList.size());
			returnObj.put("data", attMap);
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

	@RequestMapping(value = "/goAttUserWeeklyExcelDownPopup.do", method = RequestMethod.GET)
	public ModelAndView goAttUserWeeklyExcelDownPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("user/attend/AttendUserWeeklyExcelDownPopup");
		String StartDate = request.getParameter("StartDate");
		String EndDate   = request.getParameter("EndDate");
		String sUserTxt  = request.getParameter("sUserTxt");
		mav.addObject("StartDate",StartDate);
		mav.addObject("EndDate",EndDate);
		mav.addObject("rangeWeekNum",request.getParameter("rangeWeekNum"));
		mav.addObject("retireUser",request.getParameter("retireUser"));
		mav.addObject("ckb_incld_weeks",request.getParameter("ckb_incld_weeks"));
		mav.addObject("sUserTxt",sUserTxt);
		mav.addObject("sJobTitleCode",request.getParameter("sJobTitleCode"));
		mav.addObject("sJobLevelCode",request.getParameter("sJobLevelCode"));
		mav.addObject("weeklyWorkType",request.getParameter("weeklyWorkType"));
		mav.addObject("weeklyWorkValue",request.getParameter("weeklyWorkValue"));
		mav.addObject("pageType",request.getParameter("pageType"));
		mav.addObject("printDN",request.getParameter("printDN"));
		return mav;
	}

	@RequestMapping(value = "/excelDownloadForAttMngStatusWeekly.do" , method = RequestMethod.POST)
	public /*@ResponseBody JSONObject*/void excelDownloadForAttMngStatusWeekly(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultList = new CoviMap();
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;

		String TargetDate = request.getParameter("TargetDate");
		String StartDate = request.getParameter("StartDate");
		String EndDate = request.getParameter("EndDate");
		String dateTerm = request.getParameter("dateTerm");
		String groupPath = request.getParameter("groupPath");
		String sUserTxt = request.getParameter("sUserTxt");
		String printDN = StringUtil.replaceNull(request.getParameter("printDN"), "");
		String rangeWeekNum = request.getParameter("rangeWeekNum");
		String outputNumtype = request.getParameter("outputNumtype");


		sUserTxt = URLDecoder.decode(request.getParameter("sUserTxt"), "UTF-8");

		String RetireUser = request.getParameter("RetireUser");
		String companyCode = SessionHelper.getSession("DN_Code");

		String sJobTitleCode = request.getParameter("sJobTitleCode");
		String sJobLevelCode = request.getParameter("sJobLevelCode");

		CoviMap excelMap= new CoviMap();
		String FileName="AttendUserStatusViewWeekly";
		String FileTempName="AttendUserStatusViewWeekly";
		if(printDN.equals("true")){
			FileTempName="AttendUserStatusViewWeeklyDN";
		}

		try{

			CoviMap userMap = new CoviMap();
			userMap.put("groupPath", groupPath);
			userMap.put("sUserTxt", sUserTxt);
			userMap.put("sJobTitleCode", sJobTitleCode);
			userMap.put("sJobLevelCode", sJobLevelCode);
			userMap.put("retireUser", RetireUser);
			//권한별 검색가능 사용자 코드 조회
			CoviList userCodeList = attendCommonSvc.getUserListByAuthCoviList(userMap);
			//System.out.println("###### userCodeList:"+userCodeList.toString());
			CoviMap attMap = new CoviMap();
			if(userCodeList.size()>0){
				CoviMap params = new CoviMap();
				params.put("TargetDate",TargetDate);
				params.put("StartDate",StartDate);
				params.put("EndDate",EndDate);
				params.put("rangeWeekNum",rangeWeekNum);
				params.put("DateTerm",dateTerm);
				params.put("CompanyCode",companyCode);
				params.put("userCodeList", userCodeList);
				params.put("outputNumtype", outputNumtype);
				params.put("incld_weeks", request.getParameter("incld_weeks"));
				params.put("weeklyWorkType", request.getParameter("weeklyWorkType"));
				params.put("weeklyWorkValue", request.getParameter("weeklyWorkValue"));

				attMap = attendUserStatusSvc.getUserAttendanceViewerExcelData(params);
			}
			//System.out.println("######attMap:"+attMap.toString());

			excelMap.put("StartDate",StartDate);
			excelMap.put("EndDate",EndDate);
			excelMap.put("title",DicHelper.getDic("lbl_Weekly")+""+DicHelper.getDic("lbl_Tables"));//주간장표
			excelMap.put("loadCnt", userCodeList.size());
			if(attMap.size()>0) {
				excelMap.put("excelList", attMap.get("userAtt"));
				excelMap.put("excelHCol", attMap.get("excelHCol"));
			}

			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//"+FileTempName+"_templete.xlsx");
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
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);

			excelMap.put("status", Return.FAIL);
			excelMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);

			excelMap.put("status", Return.FAIL);
			excelMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);

			excelMap.put("status", Return.FAIL);
			excelMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			//resultList.put("excelmap", excelMap);
			//return resultList;
		}
	}

	/**
	 * @Method Name : getUserAttendanceDailyViewer
	 * @작성일 : 2021. 8. 31.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 매니저 - 근태현황 조회 -월간장표 일단위 상세 정보
	 * @param request
	 * @param response
	 * @return
	 */
	@RequestMapping( value= "/getUserAttendanceDailyViewer.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserAttendanceDailyViewer(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();

		String targetDate = request.getParameter("targetDate");
		String dateTerm = request.getParameter("dateTerm");
		String groupPath = request.getParameter("groupPath");
		String sUserTxt = request.getParameter("sUserTxt");
		String companyCode = SessionHelper.getSession("DN_Code");

		String sJobTitleCode = request.getParameter("sJobTitleCode");
		String sJobLevelCode = request.getParameter("sJobLevelCode");

		int pageSize = Integer.parseInt(StringUtil.replaceNull(request.getParameter("pageSize"), "1"));
		int pageNo = Integer.parseInt(request.getParameter("pageNo"));

		try{
			CoviMap userMap = new CoviMap();
			CoviMap params = new CoviMap();
			CoviMap page = new CoviMap();
			
			userMap.put("groupPath", groupPath);
			userMap.put("pageSize", pageSize);
			userMap.put("pageNo", pageNo);
			userMap.put("sUserTxt", sUserTxt);
			userMap.put("sJobTitleCode", sJobTitleCode);
			userMap.put("sJobLevelCode", sJobLevelCode);
			userMap.put("retireUser", request.getParameter("retireUser"));
			
			int userCodeCnt = attendCommonSvc.getUserListByAuthCoviListCnt(userMap);
			page = AttendUtils.setPagingData(pageNo, pageSize, userCodeCnt);
			
			userMap.addAll(page);
			params.addAll(page);
			
			//권한별 검색가능 사용자 코드 조회
			CoviList userCodeList = attendCommonSvc.getUserListByAuthCoviList(userMap);
			
			CoviMap attMap = new CoviMap();
			if(userCodeList.size()>0){
				String domainID = SessionHelper.getSession("DN_ID");

				String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
				if(!orgMapOrderSet.equals("")) {
				                String[] orgOrders = orgMapOrderSet.split("\\|");
				                params.put("orgOrders", orgOrders);
				}
				params.put("TargetDate",targetDate);
				params.put("DateTerm",dateTerm);
				params.put("CompanyCode",companyCode);
				params.put("userCodeList", userCodeList);
				params.put("incld_weeks", request.getParameter("incld_weeks"));
				params.put("weeklyWorkType", request.getParameter("weeklyWorkType"));
				params.put("weeklyWorkValue", request.getParameter("weeklyWorkValue"));

				attMap = attendUserStatusSvc.getUserAttendanceDailyViewer(params);
			}
			int rowCnt = 0;
			ArrayList userAttList = new ArrayList();
			if(attMap.size()>0) {
				userAttList = (ArrayList) attMap.get("userAtt");
				rowCnt = userAttList.size();
			}
			if(pageNo==1) {
				returnObj.put("page", page);
			}

			//월 법정근로시간
			int monthlyMaxWorkTime = attendCommonSvc.getMonthlyMaxWorkTime(targetDate);
			attMap.put("monthlyMaxWorkTime", monthlyMaxWorkTime);

			returnObj.put("loadCnt", rowCnt);
			returnObj.put("data", attMap);
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
	
	// 일괄 출퇴근 팝업 호출
	@RequestMapping(value = "/goAttAllCommutePopup.do", method = RequestMethod.GET)
	public ModelAndView goAttAllCommutePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("user/attend/AttendAllCommutePopup");
		return mav;
	}
	
	// 일괄 출퇴근 엑셀 업로드 팝업 호출
	@RequestMapping(value = "/goAttAllCommuteExcelUploadPopup.do", method = RequestMethod.GET)
	public ModelAndView goAttAllCommuteExcelUploadPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("user/attend/AttendAllCommuteExcelUploadPopup");
		return mav;
	}
	
	// 일괄 출퇴근 적용
	@RequestMapping(value= "/setAllCommute.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setAllCommute(@RequestBody Map<String, Object> map, HttpServletRequest request) {
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviList TargetUserList = attendUserStatusSvc.getTargetUserList((List)map.get("TargetData"));
			
			CoviMap params = new CoviMap();
			params.put("IsGoWork", map.get("IsGoWork"));
			params.put("IsOffWork", map.get("IsOffWork"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			
			CoviMap resultMap = attendUserStatusSvc.setAllCommute(params, (List)map.get("ReqData"), TargetUserList);
			
			if (resultMap.getInt("cnt") > 0) {
				returnObj.put("status", Return.SUCCESS);
			} else {
				returnObj.put("status", Return.FAIL);
			}
			
		} catch(NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			logHelper.getCurrentClassErrorLog(e);
		} catch(Exception e) {
			returnObj.put("status", Return.FAIL);
			logHelper.getCurrentClassErrorLog(e);
		}
		
		return returnObj;
	}
	
	// 일괄 출퇴근 엑셀 템플릿 파일 다운로드
	@RequestMapping(value = "/allCommuteExcelTemplateDownload.do", method = RequestMethod.GET)
	public void allCommuteExcelTemplateDownload(HttpServletRequest request, HttpServletResponse response) {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		
		try {
			String FileName = "AttendAllCommuteInsertTemplate.xlsx";
			String ExcelPath = this.getClass().getResource("/excel/AttendAllCommuteInsert_template.xlsx").getPath();
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, new CoviMap());
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (NullPointerException e) {
			logHelper.getCurrentClassErrorLog(e);
		} catch (IOException e) {
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			logHelper.getCurrentClassErrorLog(e);
		} finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	// 일괄 출퇴근 엑셀 업로드
	@RequestMapping(value = "/allCommuteExcelUpload.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap allCommuteExcelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("uploadfile", uploadfile);
			
			int result = attendUserStatusSvc.setAllCommuteByExcel(params);
			
			returnData.put("data", result);
			
			if (result > 0) {
				returnData.put("status", Return.SUCCESS);
			} else {
				returnData.put("status", Return.FAIL);
			}
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		}
		
		return returnData;
	}

	@RequestMapping(value = "/excelDownloadForAttMngStatusDaily.do" , method = RequestMethod.POST)
	public /*@ResponseBody JSONObject*/void excelDownloadForAttMngStatusDaily(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultList = new CoviMap();

		String TargetDate = request.getParameter("TargetDate");
		String StartDate = request.getParameter("StartDate");
		String EndDate = request.getParameter("EndDate");
		String p_StartDate = request.getParameter("p_StartDate");
		String p_EndDate = request.getParameter("p_EndDate");
		String dateTerm = request.getParameter("dateTerm");
		String groupPath = request.getParameter("groupPath");
		String sUserTxt = request.getParameter("sUserTxt");
		String detailOption = request.getParameter("detailOption");
		String outputNumtype = StringUtil.replaceNull(request.getParameter("outputNumtype"), "");
		boolean bOutputNumtype = false;
		if(outputNumtype.equals("Y")){
			bOutputNumtype = true;
		}

		sUserTxt = URLDecoder.decode(request.getParameter("sUserTxt"), "UTF-8");

		String RetireUser = request.getParameter("RetireUser");
		String companyCode = SessionHelper.getSession("DN_Code");

		String sJobTitleCode = request.getParameter("sJobTitleCode");
		String sJobLevelCode = request.getParameter("sJobLevelCode");
		String printDN = request.getParameter("printDN");

		CoviMap excelMap= new CoviMap();
		String FileName="AttendUserStatusViewDaily";
		PropertyTemplate propertyTemplate = new PropertyTemplate();

		try{
			//월 법정근로시간
			int monthlyMaxWorkTime = attendCommonSvc.getMonthlyMaxWorkTime(TargetDate);

			CoviMap userMap = new CoviMap();
			userMap.put("groupPath", groupPath);
			userMap.put("sUserTxt", sUserTxt);
			userMap.put("sJobTitleCode", sJobTitleCode);
			userMap.put("sJobLevelCode", sJobLevelCode);
			userMap.put("retireUser", RetireUser);
			//권한별 검색가능 사용자 코드 조회
			CoviList userCodeList = attendCommonSvc.getUserListByAuthCoviList(userMap);
			CoviMap attMap = new CoviMap();
			if(userCodeList.size()>0){
				CoviMap params = new CoviMap();
				params.put("TargetDate",TargetDate);
				params.put("StartDate",StartDate);
				params.put("EndDate",EndDate);
				params.put("p_StartDate",p_StartDate);
				params.put("p_EndDate",p_EndDate);
				params.put("DateTerm",dateTerm);
				params.put("CompanyCode",companyCode);
				params.put("userCodeList", userCodeList);
				params.put("printDN", printDN);
				params.put("outputNumtype", outputNumtype);
				params.put("incld_weeks", request.getParameter("incld_weeks"));
				params.put("weeklyWorkType", request.getParameter("weeklyWorkType"));
				params.put("weeklyWorkValue", request.getParameter("weeklyWorkValue"));

				attMap = attendUserStatusSvc.getUserAttendanceDailyViewerExcelData(params);
			}
			//System.out.println("####attMap:"+new GsonBuilder().setPrettyPrinting().create().toJson(attMap));
			excelMap.put("StartDate",StartDate);
			excelMap.put("EndDate",EndDate);
			excelMap.put("loadCnt", userCodeList.size());
			if(attMap.size()>0) {
				excelMap.put("excelList", attMap.get("userAtt"));
				excelMap.put("excelHCol", attMap.get("excelHCol"));
				excelMap.put("listRangeFronToDate", attMap.get("listRangeFronToDate"));
			}

			String excelTitle=DicHelper.getDic("lbl_Monthly")+DicHelper.getDic("lbl_Tables");//월간장표
			SXSSFWorkbook workbook = new SXSSFWorkbook();
			Sheet sheet = workbook.createSheet();
			Font ttlFont= workbook.createFont(); //폰트 객체 생성
			CellStyle ttlStyle = workbook.createCellStyle();

			Font textFont= workbook.createFont(); //폰트 객체 생성
			CellStyle textStyle = workbook.createCellStyle();

			ArrayList<HashMap> excelHeader = 	new ArrayList<>() ;

			excelHeader.add(new HashMap<String, String>() {{   put("colName","아이디"); put("colWith","5"); put("colKey","UserCode"); }});
			excelHeader.add(new HashMap<String, String>() {{   put("colName","이름"); put("colWith","5"); put("colKey","UserName"); }});
			excelHeader.add(new HashMap<String, String>() {{   put("colName","직급"); put("colWith","5"); put("colKey","JobPositionName"); }});
			excelHeader.add(new HashMap<String, String>() {{   put("colName","직책"); put("colWith","5"); put("colKey","JobTitleName"); }});
			excelHeader.add(new HashMap<String, String>() {{   put("colName","누적 근무시간"); put("colWith","20"); put("colKey","TotWorkTime"); }});


			Row rowTitle = sheet.createRow(0);
			AttendUtils.writeExcelCellData(rowTitle, 1, excelTitle, textFont,textStyle);
			sheet.addMergedRegion(new CellRangeAddress(0,0,1,4));
			rowTitle = sheet.createRow(1);
			AttendUtils.writeExcelCellData(rowTitle, 1, "조회: "+StartDate+" ~ "+EndDate, textFont,textStyle);
			sheet.addMergedRegion(new CellRangeAddress(1,1,1,4));

			Row rowHeader = sheet.createRow(2);
			//헤더 공통 적용
			AttendUtils.writeExcelHeaderData(rowHeader, 1, excelHeader, ttlFont, ttlStyle);
			sheet.addMergedRegion(new CellRangeAddress(2,4,1,1));
			sheet.addMergedRegion(new CellRangeAddress(2,4,2,2));
			sheet.addMergedRegion(new CellRangeAddress(2,4,3,3));
			sheet.addMergedRegion(new CellRangeAddress(2,4,4,4));
			sheet.addMergedRegion(new CellRangeAddress(2,4,5,6));
			propertyTemplate.drawBorders(new CellRangeAddress(2,3,1,1), BorderStyle.THIN, BorderExtent.OUTSIDE);
			propertyTemplate.drawBorders(new CellRangeAddress(2,3,2,2), BorderStyle.THIN, BorderExtent.OUTSIDE);
			propertyTemplate.drawBorders(new CellRangeAddress(2,3,3,3), BorderStyle.THIN, BorderExtent.OUTSIDE);
			propertyTemplate.drawBorders(new CellRangeAddress(2,3,4,4), BorderStyle.THIN, BorderExtent.OUTSIDE);
			propertyTemplate.drawBorders(new CellRangeAddress(2,3,5,6), BorderStyle.THIN, BorderExtent.OUTSIDE);
			propertyTemplate.applyBorders(sheet);
			//헤더부분 동적 생성
			Row rowHeaderDays = sheet.createRow(4);
			ArrayList hColList = (ArrayList) excelMap.get("excelHCol");
			int weekNumCellNum = 7;
			int hColStartNum = 0;
			int mergenum = 0;
			Gson gson = new Gson();
			//System.out.println("#####hColList:"+hColList.size());
			//아이디/이름/직급/직책/누적근무시간 부분 border 닫기
			propertyTemplate = new PropertyTemplate();
			propertyTemplate.drawBorders(new CellRangeAddress(4,4,1,1), BorderStyle.THIN, BorderExtent.OUTSIDE_VERTICAL);
			propertyTemplate.drawBorders(new CellRangeAddress(4,4,2,2), BorderStyle.THIN, BorderExtent.OUTSIDE_VERTICAL);
			propertyTemplate.drawBorders(new CellRangeAddress(4,4,3,3), BorderStyle.THIN, BorderExtent.OUTSIDE_VERTICAL);
			propertyTemplate.drawBorders(new CellRangeAddress(4,4,4,4), BorderStyle.THIN, BorderExtent.OUTSIDE_VERTICAL);
			propertyTemplate.drawBorders(new CellRangeAddress(4,4,5,6), BorderStyle.THIN, BorderExtent.OUTSIDE_VERTICAL);
			propertyTemplate.applyBorders(sheet);
			Font cellValFont= workbook.createFont();
			XSSFCellStyle cellValStyle = (XSSFCellStyle) workbook.createCellStyle();
			Font cellSumFont= workbook.createFont();
			XSSFCellStyle cellSumStyle = (XSSFCellStyle) workbook.createCellStyle();
			int dayCnt = 0;
			for(int i=0;i<hColList.size();i++){
				if (i == 0) {
					hColStartNum += weekNumCellNum;
					dayCnt = weekNumCellNum;
				}else {
					hColStartNum += mergenum+1;
				}
				//System.out.println("#####hColStartNum:"+hColStartNum);
				CoviMap coviMap = gson.fromJson(gson.toJson(hColList.get(i)), CoviMap.class);
				AttendUtils.writeExcelCellDynamicHeaderData(rowHeader, hColStartNum, coviMap.getString("AttDayWeeksNum")+" 주차\n"+coviMap.getString("AttDayStartTime")+" ~ "+coviMap.getString("AttDayEndTime"), ttlFont, ttlStyle);
				mergenum = coviMap.getInt("DaysCount");
				sheet.addMergedRegion(new CellRangeAddress(rowHeader.getRowNum(),rowHeader.getRowNum()+1, hColStartNum,hColStartNum+mergenum));

				propertyTemplate = new PropertyTemplate();
				propertyTemplate.drawBorders(new CellRangeAddress(rowHeader.getRowNum(),rowHeader.getRowNum()+1, hColStartNum,hColStartNum+mergenum), BorderStyle.THIN, BorderExtent.OUTSIDE);
				propertyTemplate.applyBorders(sheet);
				ArrayList ddList = (ArrayList) coviMap.get("eHColDayList");
				for(int j=0;j<ddList.size();j++){
					CoviMap ddMap = gson.fromJson(gson.toJson(ddList.get(j)), CoviMap.class);
					if(ddMap.get("DataType").toString().equals("WeeklyTotal")) {
						AttendUtils.writeExcelCellSumData(rowHeaderDays, dayCnt, ddMap.get("DD").toString(), cellSumFont, cellSumStyle);
					}else{
						AttendUtils.writeExcelCellValData(rowHeaderDays, dayCnt, ddMap.get("DD").toString(), cellValFont, cellValStyle);
					}
					dayCnt++;
				}
			}

			//바디 데이터 동적 생성
			ArrayList bColList = (ArrayList) excelMap.get("excelList");
			//System.out.println("#####bColList:"+bColList.size());
			int bodyStartRowNum = 5;
			for(int i=0;i<bColList.size();i++){
				int bodyStartColNum = 7;
				int rowSpanCnt = 5;
				Row rowBodyData1 = sheet.createRow(bodyStartRowNum);
				Row rowBodyData2 = sheet.createRow(bodyStartRowNum+1);
				Row rowBodyData3 = sheet.createRow(bodyStartRowNum+2);
				Row rowBodyData4 = sheet.createRow(bodyStartRowNum+3);
				Row rowBodyData5 = sheet.createRow(bodyStartRowNum+4);
				Row rowBodyData6 = sheet.createRow(bodyStartRowNum+5);
				Row rowBodyData7 = sheet.createRow(bodyStartRowNum+6);
				//Row rowBodyData6 = sheet.createRow(bodyStartRowNum+5);
				CoviMap coviMap = (CoviMap) bColList.get(i);
				ArrayList ddList = (ArrayList) coviMap.get("userAttDaily");
				boolean partAttFlag = false;
				for(int x=0;x<ddList.size();x++){
					CoviMap ddMap = (CoviMap) ddList.get(x);
					if(ddMap.getString("WorkingSystemType")!=null
					&& ddMap.getString("WorkingSystemType").equals("2")){
						partAttFlag = true;
						rowSpanCnt = 6;
						break;
					}
				}
				AttendUtils.writeExcelCellValData(rowBodyData1, 1, coviMap.getString("UserCode"), cellValFont, cellValStyle);
				AttendUtils.writeExcelCellValData(rowBodyData1, 2, coviMap.getString("UserName"), cellValFont, cellValStyle);
				AttendUtils.writeExcelCellValData(rowBodyData1, 3, coviMap.getString("JobPositionName"), cellValFont, cellValStyle);
				AttendUtils.writeExcelCellValData(rowBodyData1, 4, coviMap.getString("JobTitleName"), cellValFont, cellValStyle);

				AttendUtils.writeExcelCellValData(rowBodyData1, 5, "총근무", cellSumFont, cellSumStyle);
				AttendUtils.writeExcelCellValData(rowBodyData1, 6, coviMap.getString("TotWorkTime_F"), cellSumFont, cellSumStyle);
				AttendUtils.writeExcelCellValData(rowBodyData2, 5, "인정근무", cellSumFont, cellSumStyle);
				AttendUtils.writeExcelCellValData(rowBodyData2, 6, coviMap.getString("AttRealTime_F"), cellSumFont, cellSumStyle);
				AttendUtils.writeExcelCellValData(rowBodyData3, 5, "연장근무", cellSumFont, cellSumStyle);
				AttendUtils.writeExcelCellValData(rowBodyData3, 6, coviMap.getString("ExtenAcDN_F"), cellSumFont, cellSumStyle);
				AttendUtils.writeExcelCellValData(rowBodyData4, 5, "휴일근무", cellSumFont, cellSumStyle);
				AttendUtils.writeExcelCellValData(rowBodyData4, 6, coviMap.getString("HoliAcDN_F"), cellSumFont, cellSumStyle);
				AttendUtils.writeExcelCellValData(rowBodyData5, 5, "실근무", cellSumFont, cellSumStyle);
				AttendUtils.writeExcelCellValData(rowBodyData5, 6, coviMap.getString("TotConfWorkTime_F"), cellSumFont, cellSumStyle);
				AttendUtils.writeExcelCellValData(rowBodyData6, 5, "주평균 시간", cellSumFont, cellSumStyle);
				AttendUtils.writeExcelCellValData(rowBodyData6, 6, coviMap.getString("AvgWorkTime_F"), cellSumFont, cellSumStyle);
				if(partAttFlag) {
					AttendUtils.writeExcelCellValData(rowBodyData7, 5, "월 법정근무", cellSumFont, cellSumStyle);
					AttendUtils.writeExcelCellValData(rowBodyData7, 6, AttendUtils.convertSecToStr(monthlyMaxWorkTime, "H"), cellSumFont, cellSumStyle);
				}
				//AttendUtils.writeExcelCellValData(rowBodyData6, 5, "잔여근무시간", cellSumFont, cellSumStyle);
				//AttendUtils.writeExcelCellValData(rowBodyData6, 6, coviMap.get("RemainTime_F").toString(), cellSumFont, cellSumStyle);

				sheet.addMergedRegion(new CellRangeAddress(rowBodyData1.getRowNum(),rowBodyData1.getRowNum()+rowSpanCnt, 1,1));
				sheet.addMergedRegion(new CellRangeAddress(rowBodyData1.getRowNum(),rowBodyData1.getRowNum()+rowSpanCnt, 2,2));
				sheet.addMergedRegion(new CellRangeAddress(rowBodyData1.getRowNum(),rowBodyData1.getRowNum()+rowSpanCnt, 3,3));
				sheet.addMergedRegion(new CellRangeAddress(rowBodyData1.getRowNum(),rowBodyData1.getRowNum()+rowSpanCnt, 4,4));

				propertyTemplate = new PropertyTemplate();
				propertyTemplate.drawBorders(new CellRangeAddress(rowBodyData1.getRowNum(),rowBodyData1.getRowNum()+rowSpanCnt, 1,1), BorderStyle.THIN, BorderExtent.OUTSIDE);
				propertyTemplate.drawBorders(new CellRangeAddress(rowBodyData1.getRowNum(),rowBodyData1.getRowNum()+rowSpanCnt, 2,2), BorderStyle.THIN, BorderExtent.OUTSIDE);
				propertyTemplate.drawBorders(new CellRangeAddress(rowBodyData1.getRowNum(),rowBodyData1.getRowNum()+rowSpanCnt, 3,3), BorderStyle.THIN, BorderExtent.OUTSIDE);
				propertyTemplate.drawBorders(new CellRangeAddress(rowBodyData1.getRowNum(),rowBodyData1.getRowNum()+rowSpanCnt, 4,4), BorderStyle.THIN, BorderExtent.OUTSIDE);
				propertyTemplate.applyBorders(sheet);

				//일단위 데이터 출력 loop
				for(int j=0;j<ddList.size();j++){
					CoviMap ddMap = (CoviMap) ddList.get(j);
					if(ddMap.get("DataType").toString().equals("WeeklyTotal")) {
						AttendUtils.writeExcelCellSumData(rowBodyData1, bodyStartColNum, ddMap.getString("TotWorkTime_F"), cellSumFont, cellSumStyle);
						AttendUtils.writeExcelCellSumData(rowBodyData2, bodyStartColNum, ddMap.getString("AttRealTime_F"), cellSumFont, cellSumStyle);
						AttendUtils.writeExcelCellSumData(rowBodyData3, bodyStartColNum, ddMap.getString("ExtenAcDN_F"), cellSumFont, cellSumStyle);
						AttendUtils.writeExcelCellSumData(rowBodyData4, bodyStartColNum, ddMap.getString("HoliAcDN_F"), cellSumFont, cellSumStyle);
						AttendUtils.writeExcelCellSumData(rowBodyData5, bodyStartColNum, ddMap.getString("TotConfWorkTime_F"), cellSumFont, cellSumStyle);
						AttendUtils.writeExcelCellSumData(rowBodyData6, bodyStartColNum, "", cellSumFont, cellSumStyle);
						if(partAttFlag) {
							AttendUtils.writeExcelCellSumData(rowBodyData7, bodyStartColNum, ddMap.getString("MonthlyAttAcSum_F"), cellSumFont, cellSumStyle);
						}
					}else{
						AttendUtils.writeExcelCellValData(rowBodyData1, bodyStartColNum, ddMap.getString("TotWorkTime_F"), cellValFont, cellValStyle);
						AttendUtils.writeExcelCellValData(rowBodyData2, bodyStartColNum, ddMap.getString("AttRealTime_F"), cellValFont, cellValStyle);
						AttendUtils.writeExcelCellValData(rowBodyData3, bodyStartColNum, ddMap.getString("ExtenAcDN_F"), cellValFont, cellValStyle);
						AttendUtils.writeExcelCellValData(rowBodyData4, bodyStartColNum, ddMap.getString("HoliAcDN_F"), cellValFont, cellValStyle);
						AttendUtils.writeExcelCellValData(rowBodyData5, bodyStartColNum, ddMap.getString("TotConfWorkTime_F"), cellValFont, cellValStyle);
						AttendUtils.writeExcelCellValData(rowBodyData6, bodyStartColNum, "", cellValFont, cellValStyle);
						if(partAttFlag) {
							AttendUtils.writeExcelCellValData(rowBodyData7, bodyStartColNum, ddMap.getString("MonthlyAttAcSum_F"), cellValFont, cellValStyle);
						}
					}
					bodyStartColNum++;
				}
				if(partAttFlag) {
					bodyStartRowNum += 7; //사용자별 출력 정보 추가시 라인수 맞춰줘야함.
				}else{
					bodyStartRowNum += 6; //사용자별 출력 정보 추가시 라인수 맞춰줘야함.
				}
			}

			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");
			workbook.write(response.getOutputStream());
			workbook.dispose();
			try { workbook.close(); } 
			catch(IOException ignore) { LOGGER.error(ignore.getLocalizedMessage(), ignore); }
			catch(Exception ignore) { LOGGER.error(ignore.getLocalizedMessage(), ignore); }
		} catch (NullPointerException e) {
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			logHelper.getCurrentClassErrorLog(e);
			//System.out.println(e);
		} /*finally {
			resultList.put("excelmap", excelMap);
			return resultList;
		}*/
	}


	@RequestMapping(value = "/excelDownloadForAttMngStatusDailyDetail.do" , method = RequestMethod.POST)
	public /*@ResponseBody JSONObject*/void excelDownloadForAttMngStatusDailyDetail(HttpServletRequest request, HttpServletResponse response) throws Exception {
		//JSONObject resultList = new CoviMap();
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;

		String TargetDate = request.getParameter("TargetDate");
		String StartDate = request.getParameter("StartDate");
		String EndDate = request.getParameter("EndDate");
		String p_StartDate = request.getParameter("p_StartDate");
		String p_EndDate = request.getParameter("p_EndDate");
		String dateTerm = request.getParameter("dateTerm");
		String groupPath = request.getParameter("groupPath");
		String sUserTxt = request.getParameter("sUserTxt");
		String detailOption = request.getParameter("detailOption");
		String outputNumtype = request.getParameter("outputNumtype");

		sUserTxt = URLDecoder.decode(request.getParameter("sUserTxt"), "UTF-8");

		String RetireUser = request.getParameter("RetireUser");
		String companyCode = SessionHelper.getSession("DN_Code");

		String sJobTitleCode = request.getParameter("sJobTitleCode");
		String sJobLevelCode = request.getParameter("sJobLevelCode");
		String printDN = StringUtil.replaceNull(request.getParameter("printDN"), "");

		CoviMap excelMap= new CoviMap();
		String FileName="AttendUserStatusViewDaily";
		String TempFileName="AttendUserStatusViewDailyDetailNoneDN";

		if(printDN.equals("true")){
			TempFileName="AttendUserStatusViewDailyDetail";
		}

		try{
			CoviMap userMap = new CoviMap();
			userMap.put("groupPath", groupPath);
			userMap.put("sUserTxt", sUserTxt);
			userMap.put("sJobTitleCode", sJobTitleCode);
			userMap.put("sJobLevelCode", sJobLevelCode);
			userMap.put("retireUser", RetireUser);
			//권한별 검색가능 사용자 코드 조회
			CoviList userCodeList = attendCommonSvc.getUserListByAuthCoviList(userMap);
			//System.out.println("###### userCodeList:"+userCodeList.toString());
			CoviMap attMap = new CoviMap();
			if(userCodeList.size()>0){
				CoviMap params = new CoviMap();
				params.put("TargetDate",TargetDate);
				params.put("StartDate",StartDate);
				params.put("EndDate",EndDate);
				params.put("p_StartDate",p_StartDate);
				params.put("p_EndDate",p_EndDate);
				params.put("DateTerm",dateTerm);
				params.put("CompanyCode",companyCode);
				params.put("userCodeList", userCodeList);
				params.put("printDN", printDN);
				params.put("outputNumtype", outputNumtype);
				params.put("incld_weeks", request.getParameter("incld_weeks"));
				params.put("weeklyWorkType", request.getParameter("weeklyWorkType"));
				params.put("weeklyWorkValue", request.getParameter("weeklyWorkValue"));

				attMap = attendUserStatusSvc.getUserAttendanceDailyViewerExcelDataDetail(params);
			}
			//System.out.println("######attMap:"+attMap.toString());

			excelMap.put("StartDate",StartDate);
			excelMap.put("EndDate",EndDate);
			excelMap.put("loadCnt", userCodeList.size());
			if(attMap.size()>0) {
				excelMap.put("excelList", attMap.get("userAttDaily"));
			}
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//"+TempFileName+".xlsx");
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
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);

			excelMap.put("status", Return.FAIL);
			excelMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);

			excelMap.put("status", Return.FAIL);
			excelMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);

			excelMap.put("status", Return.FAIL);
			excelMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			//resultList.put("excelmap", excelMap);
			//return resultList;
		}
	}

	/**
	 * @Method Name : getMyAttStatusV2
	 * @작성일 : 2021. 9. 10.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 내 근태현황 조회 + v1 대비 야근근무 시작 출력 추가
	 * @param request
	 * @param response
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping( value= "/getMyAttStatusV2.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyAttStatusV2(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();

		String targetDate = request.getParameter("targetDate")!=null&&!"".equals(request.getParameter("targetDate"))?request.getParameter("targetDate"):ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
		String dateTerm = request.getParameter("dateTerm");
		String userCode = SessionHelper.getSession("USERID");
		String deptCode = SessionHelper.getSession("DEPTID");
		String companyCode = SessionHelper.getSession("DN_Code");
		String str_incld_weeks = request.getParameter("incld_weeks");
		boolean incld_weeks = false;
		if(str_incld_weeks!=null && str_incld_weeks.equals("true")){
			incld_weeks =  true;
		}

		try{
			//권한별 검색가능 사용자 코드 조회
			CoviMap userMap = new CoviMap();
			userMap.put("sUserCode", userCode);
			userMap.put("sDeptCode", deptCode);
			userMap.put("UserCode", userCode);
			userMap.put("DeptCode", deptCode);
			CoviList userCodeList = new CoviList();
			userCodeList.add(userMap);

			CoviMap attMap = new CoviMap();
			CoviList jobHisList = new CoviList();
			CoviList attMonthList = new CoviList();

			if("M".equals(dateTerm)){
				CoviMap rangeFromToDateMap = attendUserStatusSvc.getRangeFronToDate(targetDate, true);//기본 날일 범위는 전달 후다 포함주
				CoviMap rangeFromToDateMapR = attendUserStatusSvc.getRangeFronToDate(targetDate, incld_weeks);//기본 날일 범위는 전달 후다 포함주
				//System.out.println("#####rangeFromToDateMap:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(rangeFromToDateMap));
				//System.out.println("#####rangeFromToDateMapR:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(rangeFromToDateMapR));
				returnObj.put("rangeFromToDateMap", rangeFromToDateMapR);


				//3달 평균
				String tDate = targetDate.replaceAll("-","");
				SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
				SimpleDateFormat sdf_dot = new SimpleDateFormat("yyyy.MM.dd");
				Calendar cal = Calendar.getInstance();
				cal.setTime(sdf.parse(tDate));
				cal.add(Calendar.MONTH, -2);

				Date tDATE2MBF = new Date();
				tDATE2MBF = cal.getTime();
				CoviMap rangeFrom2MBF = attendUserStatusSvc.getRangeFronToDate(sdf.format(tDATE2MBF), true);
				//System.out.println("#####rangeFrom2MBF:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(rangeFrom2MBF));
				List<Map<String, String>> listRangeFrom2MBF = (List<Map<String, String>>)rangeFrom2MBF.get("RangeFronToDate");
				Map<String, String> twoMonthAgoStartDateMap = listRangeFrom2MBF.get(0);
				String twoMonthAgoStartDate = twoMonthAgoStartDateMap.keySet().toString().replace("[","").replace("]","");
				//System.out.println("#####twoMonthAgoStartDate:"+twoMonthAgoStartDate);


				CoviMap params = new CoviMap();
				params.put("TargetDate",targetDate);
				params.put("DateTerm","M");
				params.put("CompanyCode",companyCode);
				params.put("userCodeList", userCodeList);
				params.put("userCode", userCode);
				params.put("rangeStartDate", rangeFromToDateMapR.getString("RangeStartDate"));
				params.put("rangeEndDate", rangeFromToDateMapR.getString("RangeEndDate"));

				CoviMap monthMap = attendUserStatusSvc.getUserAttendanceV2Month(params);
				String pTargetDate = rangeFromToDateMap.getString("RangeStartDate");
				List<Map<String, String>> listRangeFromToDate  = (List<Map<String, String>>)rangeFromToDateMap.get("RangeFronToDate");
				List<Map<String, String>> listRangeFromToDateR = (List<Map<String, String>>)rangeFromToDateMapR.get("RangeFronToDate");
				//System.out.println("#####listRangeFronToDate:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(listRangeFronToDate));
				Map<String, String> trange = listRangeFromToDate.get(listRangeFromToDate.size()-1);
				String ts_date = trange.keySet().toString().replace("[","").replace("]","");
				String te_date = trange.get(ts_date);
				CoviMap threeMonthsSum =  attendUserStatusSvc.getUserAttWorkWithDayAndNightTimeProc(userCode,companyCode,twoMonthAgoStartDate,te_date);
				//System.out.println("#####threeMonthsSum:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(threeMonthsSum));
				int threeMonthTotWorkTime = threeMonthsSum.getInt("TotAcWorkTime");
				//System.out.println("#####threeMonthTotWorkTime:"+threeMonthTotWorkTime);
				cal.setTime(sdf.parse(twoMonthAgoStartDate));
				Date tmagoFromDate = cal.getTime();
				cal.setTime(sdf.parse(te_date));
				Date tmagoEndDate = cal.getTime();
				String tmagoRangeFromDate_F = sdf_dot.format(tmagoFromDate);
				String tmagoRangeEndDate_F = sdf_dot.format(tmagoEndDate);

				long diffDays = (tmagoEndDate.getTime() - tmagoFromDate.getTime())/(24*60*60*1000)+1;
				//System.out.println("#####diffDays:"+diffDays);
				long weeksCnt = diffDays/7;
				long avgThreeMonthsWorkTime = threeMonthTotWorkTime/weeksCnt;
				//System.out.println("#####avgThreeMonthsWorkTime:"+avgThreeMonthsWorkTime);

				monthMap.put("threeMonthsSum", threeMonthsSum);
				monthMap.put("threeMonthsAvgWorkTime", avgThreeMonthsWorkTime);
				monthMap.put("threeMonthsAvgWorkTimeInfo", tmagoRangeFromDate_F+"~"+tmagoRangeEndDate_F);
				//-->

				for(int i=0;i<listRangeFromToDate.size();i++){
					Map<String, String> range = listRangeFromToDate.get(i);
					String s_date = range.keySet().toString().replace("[","").replace("]","");
					String e_date = range.get(s_date);
					Map<String, String> rangeR = listRangeFromToDateR.get(i);
					String s_dateR = rangeR.keySet().toString().replace("[","").replace("]","");
					String e_dateR = rangeR.get(s_dateR);
					//System.out.println("#####s_date:"+s_date+"/"+e_date);
					params = new CoviMap();
					params.put("TargetDate",pTargetDate);
					params.put("DateTerm","W");
					params.put("CompanyCode",companyCode);
					params.put("userCodeList", userCodeList);
					params.put("StartDate", s_date);
					params.put("EndDate", e_date);
					params.put("StartDateR", s_dateR);
					params.put("EndDateR", e_dateR);
					params.put("incld_weeks", incld_weeks);
					CoviMap attMonthMap = attendUserStatusSvc.getUserAttendanceV2Range(params);
					attMonthList.add(attMonthMap);
					String p_eDate = attMonthMap.getString("p_eDate");
					if(AttendUtils.removeMaskAll(targetDate).substring(0,6).equals(p_eDate.substring(0,6))){
						pTargetDate = p_eDate;
					}else{
						break;
					}
				}
				//월 법정근로시간
				int monthlyMaxWorkTime = attendCommonSvc.getMonthlyMaxWorkTime(targetDate);
				returnObj.put("monthlyMaxWorkTime", monthlyMaxWorkTime);

				returnObj.put("attMonthList", attMonthList);
				returnObj.put("monthMap", monthMap);
			}else{
				CoviMap params = new CoviMap();
				params.put("TargetDate",targetDate);
				params.put("DateTerm",dateTerm);
				params.put("CompanyCode",companyCode);
				params.put("userCodeList", userCodeList);

				attMap = attendUserStatusSvc.getUserAttendanceV2(params);

				String dayScope = attendUserStatusSvc.getDayScope(dateTerm,targetDate,companyCode);
				String sDate = dayScope.split("/")[0];
				String eDate = dayScope.split("/")[1];

				CoviMap jobParams = new CoviMap();
				jobParams.put("UserCode", userCode);
				jobParams.put("CompanyCode", companyCode);
				jobParams.put("StartDate", sDate);
				jobParams.put("EndDate", eDate);

				jobParams.put("lang",  SessionHelper.getSession("lang"));

				jobHisList = attendUserStatusSvc.getUserJobHistory(jobParams);
				returnObj.put("attMap", attMap);

				//월 법정근로시간
				int monthlyMaxWorkTime = attendCommonSvc.getMonthlyMaxWorkTime(targetDate);
				returnObj.put("monthlyMaxWorkTime", monthlyMaxWorkTime);
			}

			returnObj.put("jobHisList", jobHisList);
			returnObj.put("status", Return.SUCCESS);
		} catch(NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch(ArrayIndexOutOfBoundsException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch(ParseException e){
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
	 * @Method Name : excelDownloadForAttMyStatusV2
	 * @작성일 : 2021. 9. 13
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 내 근태현황 엑셀 다운로드
	 * @param request
	 * @param response
	 */
	@RequestMapping(value = "/excelDownloadForAttMyStatusV2.do" , method = RequestMethod.POST)
	public void/*@ResponseBody JSONObject*/ excelDownloadForAttMyStatusV2(HttpServletRequest request, HttpServletResponse response) {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		CoviMap returnObj = new CoviMap();

		String str_incld_weeks = request.getParameter("incld_weeks");
		boolean incld_weeks = false;
		if(str_incld_weeks!=null && str_incld_weeks.equals("true")){
			incld_weeks =  true;
		}

		try {
			String OutpuFileName = "AttendMyInfo.xlsx";
			String FileName = "AttendMyInfo_templete_v2.xlsx";
			String PrintDn = StringUtil.replaceNull(request.getParameter("printDN"), "");
			if(PrintDn.equals("false")){
				FileName = "AttendMyInfo_templete_v2_noneDayNightTime.xlsx";
			}

			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//"+FileName);

			String targetDate = request.getParameter("targetDate")!=null&&!"".equals(request.getParameter("targetDate"))?request.getParameter("targetDate"):ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
			String dateTerm = StringUtil.replaceNull(request.getParameter("dateTerm"), "");
			String userCode = SessionHelper.getSession("USERID");
			String companyCode = SessionHelper.getSession("DN_Code");
			String companyId = SessionHelper.getSession("DN_ID");
			String deptCode = SessionHelper.getSession("GR_Code");

			String startDate = "";
			String endDate = "";

			if(dateTerm.equals("M")) {
				CoviMap rangeFromToDateMapR = attendUserStatusSvc.getRangeFronToDate(targetDate, incld_weeks);//기본 날일 범위는 전달 후다 포함주
				startDate = rangeFromToDateMapR.getString("RangeStartDate");
				endDate = rangeFromToDateMapR.getString("RangeEndDate");
			}else{

				CoviMap dayParams = attendUserStatusSvc.setDayParams(dateTerm, targetDate, companyCode);
				startDate = dayParams.getString("sDate");
				endDate = dayParams.getString("eDate");
			}

			CoviMap params = attendUserStatusSvc.getMyAttExcelInfoV2(userCode,deptCode,companyCode,companyId,startDate,endDate);

			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);

			response.setHeader("Content-Disposition", "attachment;fileName=\""+OutpuFileName+"\";");
		    response.setHeader("Content-Description", "JSP Generated Data");
			response.setContentType("application/vnd.ms-excel;charset=utf-8");
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
			returnObj.put("data", params);
		} catch (NullPointerException e) {
			logHelper.getCurrentClassErrorLog(e);
		} catch (IOException e) {
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			logHelper.getCurrentClassErrorLog(e);
		} finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
		//return returnObj;
	}
	
	/**
	 * 근태확정 및 취소
	 * 
	 * @param request
	 * @param response
	 * @return
	 */
	@RequestMapping( value= "/updateAttConfirm.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateAttConfirm(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		String[] userList = request.getParameterValues("userList[]");
		String dateTerm = request.getParameter("dateTerm");
		String attConfirmYn = request.getParameter("attConfirmYn");
		String targetDate = request.getParameter("targetDate");
		
		CoviMap params = new CoviMap();
		params.put("userList", userList);
		params.put("dateTerm", dateTerm);
		params.put("attConfirmYn", attConfirmYn);
		params.put("targetDate", targetDate);
		
		try{
			int resultCount = attendUserStatusSvc.updateAttConfirm(params);
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("resultCount", resultCount);
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
