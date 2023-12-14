package egovframework.covision.groupware.attend.user.web;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

//import egovframework.baseframework.util.*;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.*;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ACLHelper;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;
import egovframework.covision.groupware.attend.user.service.AttendJobSvc;
import egovframework.covision.groupware.attend.user.service.AttendScheduleSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import egovframework.baseframework.data.CoviList;

@Controller
@RequestMapping("/attendCommon")
public class AttendCommonCon {
	private Logger LOGGER = LogManager.getLogger(AttendCommonCon.class);
	
	@Autowired
	AttendCommonSvc attendCommonSvc; 
	 
	@Autowired 
	AttendJobSvc attendJobSvc;
	
	@Autowired 
	AttendScheduleSvc attendScheduleSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	

	/**
	  * @Method Name : getDeptList
	  * @작성일 : 2020. 3. 27.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 등록 권한 별 조회 가능 부서 리스트 조회
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/getDeptList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDeptList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap deptObj = attendCommonSvc.getDeptListByAuth();
			CoviList deptList = deptObj.getJSONArray("deptList");
			returnList.put("deptList", deptList); 
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
	
	/**
	  * @Method Name : getDeptList
	  * @작성일 : 2020. 3. 27.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 등록 권한 별 조회 가능 부서 리스트 조회(계층형
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/getDeptStepList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDeptStepList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap deptObj = attendCommonSvc.getDeptListByAuth();
			CoviList tmpList = deptObj.getJSONArray("deptList");
			String sortDepth  = "";
			CoviList deptList = new CoviList();
			for (int i=0; i < tmpList.size(); i++){
				CoviMap map = (CoviMap)tmpList.get(i);
				if(map.get("GroupType").equals("Company")) continue;
				if (sortDepth.equals("")){
					sortDepth.equals(map.get("sortDepth"));
				}
				
				if (sortDepth.equals(map.get("sortDepth"))){
					deptList.add(map);
				}
			}
//			CoviList deptList = deptObj.getJSONArray("deptList");
			returnList.put("deptList", deptList); 
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
	
	
	@RequestMapping(value = "/getUserListByAuth.do", method = RequestMethod.GET)
	public @ResponseBody CoviMap getUserListByAuth(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			CoviList userList = attendCommonSvc.getUserListByAuth(params);
			returnList.put("userList", userList);
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
		SimpleDateFormat sd = new SimpleDateFormat("YYYY.mm.dd");
		return returnList;
	}
	
	
	/**
	  * @Method Name : getAclMenuAuth
	  * @작성일 : 2020. 3. 30.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 사용자별 메뉴 접근 권한 조회
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value="/getAclMenuAuth.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAclMenuAuth(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String menuId = String.valueOf(request.getParameter("ObjectID")).trim();
		String objType = String.valueOf(request.getParameter("ObjectType")).trim();
		
		try{
			String[] sType = objType.split(""); 
		
			CoviMap sessionUser = SessionHelper.getSession();
			
			String resultStr = "";
			StringBuffer buf = new StringBuffer();
			for(int i=0;i<sType.length;i++){
				Set<String> authorizedObjectCodeSet = ACLHelper.getACL(sessionUser, "MN", "", sType[i]);
				String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
				String arrayVal = "_";
				
				for(int r=0;r<objectArray.length;r++){
					String menuKey = objectArray[r];
					
					if(menuId.equals(menuKey)){
						arrayVal = sType[i];
						break;
					}
				}
				buf.append(arrayVal);
			}
			resultStr = buf.toString();
			returnList.put("data", resultStr);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		} catch(ArrayIndexOutOfBoundsException e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}
		return returnList;
	}
	
	
	//지도 화면
	@RequestMapping(value = "/AttendMapPopup.do", method = RequestMethod.GET)
	public ModelAndView attendMapPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendMapPopup";

		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
		
	//조직도 화면
	@RequestMapping(value = "/AttendOrgChart.do", method = RequestMethod.GET)
	public ModelAndView attendOrgChart(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendOrgChart";

		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("JobDate", request.getParameter("JobDate"));
		return mav;
	}
		
	//날짜 범위
	@RequestMapping(value = "/AttendDayScope.do")
	public String attendDayScope(HttpServletRequest request,HttpServletResponse response) throws Exception {
		CoviMap params = new CoviMap();
		String companyCode = SessionHelper.getSession("DN_Code");
		String dayTerm = request.getParameter("dayTerm");
		String targetDate = request.getParameter("targetDate");
		params.put("CompanyCode", companyCode);
		params.put("DayTerm", dayTerm);
		params.put("TargetDate", targetDate);
		return attendCommonSvc.getDayScope(params);
	}

	//휴무일 조회
	@RequestMapping(value = "/getHolidaySchedule.do")
	public @ResponseBody CoviMap  getHolidaySchedule(HttpServletRequest request,HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap();
			String companyCode = SessionHelper.getSession("DN_Code");
			String targetDate = request.getParameter("targetDate");
			params.put("CompanyCode", companyCode);
			params.put("TargetDate", targetDate);
			CoviList list = attendCommonSvc.getHolidaySchedule(params);
			returnList.put("list", list);
			returnList.put("status", Return.SUCCESS);	
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	/*
	 * 좌표 API
	 * https://www.juso.go.kr
	 * localhost
	 * U01TX0FVVEgyMDE3MDgyOTEzNTMwODEwNzI5NTI= 
	 * 
	 * */
	@RequestMapping(value = "/getLocationCoordAPI.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLocationCoordAPI(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try{
			String addr   = request.getParameter("addr");
			String admCd   = request.getParameter("admCd");
			String rnMgtSn = request.getParameter("rnMgtSn");
			String udrtYn  = request.getParameter("udrtYn");
			String buldMnnm= request.getParameter("buldMnnm");
			String buldSlno= request.getParameter("buldSlno");
			
			// API 호출 URL 정보 설정*/
			CoviMap returnObj = CoviMap.fromObject(AttendUtils.locationCoordAPI(addr, admCd, rnMgtSn, udrtYn, buldMnnm, buldSlno));
			if (returnObj.getJSONObject("response").getString("status").equals("NOT_FOUND")){//도로명으로 재검색
				returnObj = CoviMap.fromObject(AttendUtils.locationCoordAPI(addr, admCd, rnMgtSn, udrtYn, buldMnnm, buldSlno, "ROAD"));
			}

			CoviMap mapObj = new CoviMap();
			if(returnObj.getJSONObject("response").getString("status").equalsIgnoreCase("OK")){
				//mapObj = new CoviMap();
				//mapObj.put("juso", returnObj.getJSONObject("response").getJSONObject("result"));
				//mapObj.put("result", )
				//returnObj.getJSONObject("response").put("juso",returnObj.getJSONObject("response").getJSONObject("result"));
			}	
			returnList.put("list", returnObj);
			returnList.put("status", Return.SUCCESS);	
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	@RequestMapping(value = "/getLocationAddressAPI.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLocationAddressAPI(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try{
			String x   = request.getParameter("x");
			String y   = request.getParameter("y");
			
			// API 호출 URL 정보 설정*/
			CoviMap returnObj = CoviMap.fromObject(AttendUtils.locationAddressAPI(x, y));
			CoviMap mapObj = new CoviMap();
			if(returnObj.getJSONObject("response").getString("status").equalsIgnoreCase("OK")){
				returnList.put("list", returnObj);
				returnList.put("status", Return.SUCCESS);	
			}	
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	/**
	  * @Method Name : getOtherJobList
	  * @작성일 : 2020. 5. 19.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기타근무 리스트 조회
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/getOtherJobList.do")
	public @ResponseBody CoviMap getOtherJobList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("ValidYn", "Y");//request.getParameter("validYn"));
			params.put("JobStsSeq", request.getParameter("JobStsSeq"));
			
			returnList.put("jobList",attendCommonSvc.getOtherJobList(params)); 
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
	
	/**
	* @Method Name : getAttendJob
	* @작성일 : 2019. 7. 1.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 근무제리스트 조회
	* @param request
	* @param response
	* @return
	* @throws Exception
	*/
	@RequestMapping(value = "/getAttendJobCalendar.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAttendJobCalendar(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		
		try {
			CoviMap params = new CoviMap();
			String StartDate = StringUtil.replaceNull(request.getParameter("StartDate"), "");
			
			StartDate = StartDate.isEmpty() ? "" : AttendUtils.removeMaskAll(StartDate).substring(0, 6);
			
			params.put("StartDate", StartDate);
			params.put("mode", request.getParameter("mode"));
			params.put("UR_Code", request.getParameter("ReqUserCode") == null ? SessionHelper.getSession("UR_Code") : request.getParameter("ReqUserCode"));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			CoviMap resultList = attendCommonSvc.getAttendJobCalendar(params);

			returnList.put("holiList", resultList.get("holiList"));
			if (!"ONLY".equals(request.getParameter("mode"))) returnList.put("jobList", (CoviList)resultList.get("jobList"));

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getAllUserGroupAutoTagList - 자동완성 태그용 근태관련 사용자 조회
	 * @param keyword
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "getAttendUserGroupAutoTagList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getAllUserGroupAutoTagList(
			@RequestParam(value = "keyword", required = false) String keyword) throws Exception{
		
		CoviMap returnList = new CoviMap();
		CoviList result ;
		try{
			
			CoviMap params = new CoviMap();
			params.put("KeyWord", keyword);
			
			result = attendCommonSvc.getAttendUserGroupAutoTagList(params);
			
			returnList.put("list", result);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	/**
	  * @Method Name : goAttMapInfoPopup
	  * @작성일 : 2020. 5. 28.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 지도 표시 팝업 
	  * @param request
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/goAttMapInfoPopup.do", method={RequestMethod.GET,RequestMethod.POST})
	public ModelAndView goAttMapInfoPopup(HttpServletRequest request,HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("user/attend/AttendMapInfoPopup");
		
		String pointX = request.getParameter("pointx");
		String pointY = request.getParameter("pointy");
		String addr = request.getParameter("addr");

		mav.addObject("pointX",pointX);
		mav.addObject("pointY",pointY);
		if (addr != null ){
			mav.addObject("addr", URLDecoder.decode(addr, "UTF-8"));
		}	
		return mav; 
	}
	
	/**
	  * @Method Name : AttendExcelPopup
	  * @작성일 : 2020. 5. 28.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 엑셀 업로드 
	  * @param request
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/AttendExcelPopup.do", method={RequestMethod.GET,RequestMethod.POST})
	public ModelAndView attendExcelPopup(HttpServletRequest request,HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("user/attend/AttendExcelPopup");
		return mav; 
	}
	/**
	 * @Method Name : 
	 * @Description : 엑셀 업로드
	 */
	@RequestMapping(value = "/uploadExcel.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap uploadExcel(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile, HttpServletRequest request) {
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			CoviMap coviMap;
			params.put("uploadfile", uploadfile);

			switch (request.getParameter("mode")){	
				case "SCHEDULE":
					CoviMap reqMap = new CoviMap();
					reqMap.put("ValidYn", "Y");
					reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			
					int AttSeq = 0;			
					try{
						AttSeq = attendCommonSvc.chkAttendanceBaseInfoYn(reqMap);			
					} catch(NullPointerException  e){
						LOGGER.debug(e);
					} catch(Exception  e){
						LOGGER.debug(e);
					}
					params.put("AttSeq", AttSeq);
					coviMap = attendScheduleSvc.uploadExcel(params);
					returnData.put("totalCnt",	coviMap.get("totalCnt"));
					returnData.put("successCnt",	coviMap.get("successCnt"));
					returnData.put("failCnt",	coviMap.get("failCnt"));
	
					break;
				case "JOB":
					coviMap = attendJobSvc.uploadExcel(params);
					returnData.put("totalCnt",	coviMap.get("totalCnt"));
					returnData.put("successCnt",	coviMap.get("successCnt"));
					returnData.put("failCnt",	coviMap.get("failCnt"));

					break;
				case "WORKINFO":
					coviMap = attendJobSvc.uploadExcel(params);
					returnData.put("totalCnt",	coviMap.get("totalCnt"));
					returnData.put("successCnt",	coviMap.get("successCnt"));
					returnData.put("failCnt",	coviMap.get("failCnt"));

					break;
				default : 
					break;
			}

			returnData.put("status",	Return.SUCCESS);
			returnData.put("message",	"업로드 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status",	Return.FAIL);
			returnData.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status",	Return.FAIL);
			returnData.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;		
	}
	
	/**
	* @Method Name : templateDownload
	* @Description : 템플릿 다운로드
	*/
	@RequestMapping(value = "/downloadTemplate.do")
	public ModelAndView downloadTemplate(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		
		try {
				String returnURL = "UtilExcelView";
				CoviMap viewParams = new CoviMap();
				String[] headerNames = null;
				CoviList jsonArray = new CoviList();
				CoviMap jsonObject = new CoviMap();
				int idx=0;
				
				switch (request.getParameter("mode")){	
					case "SCHEDULE":
						headerNames = new String [27];						
						headerNames[idx++]= "근무제명";	
						String[] Weeks = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
						for (int i=0; i <Weeks.length; i++){
							headerNames[idx++]= Weeks[i]+"-근무시작일";
							headerNames[idx++]= Weeks[i]+"-근무종료일";
							headerNames[idx++]= Weeks[i]+"-익일여부";
						}	
						headerNames[idx++]= "간주여부";	
						headerNames[idx++]= "메모";	
						idx=0;
						jsonObject.put(String.valueOf(idx++), "TEST");
						for (int i=0; i <Weeks.length; i++){
							jsonObject.put(String.valueOf(idx++), "0900");	jsonObject.put(String.valueOf(idx++), "1800"); jsonObject.put(String.valueOf(idx++), "N");
						}
						jsonObject.put(String.valueOf(idx++), "N");
						jsonObject.put(String.valueOf(idx++), "");	
						jsonArray.add(jsonObject);
						viewParams.put("title", "ScheduleTemplate");
						break;
					case "JOB":
						headerNames = new String [] {"사용자"
								, "근무일"
								,"시작시간"
								,"종료시간"
								,"익일여부"
								,"근무상태"
								,"비고"
								};
						
						jsonObject.put(String.valueOf(idx++), "superadmin");
						jsonObject.put(String.valueOf(idx++), "20200101");
						jsonObject.put(String.valueOf(idx++), "0900");
						jsonObject.put(String.valueOf(idx++), "1800");
						jsonObject.put(String.valueOf(idx++), "N");
						jsonObject.put(String.valueOf(idx++), "ON");
						jsonArray.add(jsonObject);
						viewParams.put("title", "JobTemplate");
						break;
					default :
						break;
				}
								
				viewParams.put("list", jsonArray);
				viewParams.put("cnt", 0);
				viewParams.put("headerName", headerNames);
				mav = new ModelAndView(returnURL, viewParams);
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e);
		} catch (NullPointerException e) {
			LOGGER.error(e);
		} catch (Exception e) {
			LOGGER.error(e);
		}
		return mav;
	}
	
	
	
	
	/**
	  * @Method Name : getAttendUserAuthType
	  * @작성일 : 2020. 6. 2.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근태관리 사용자별 권한 ( 로그인 시 session에 담으면 좋을텐데.. )
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/getAttendUserAuthType.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getAttendUserAuthType(HttpServletRequest request,HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		try{
			
			//if (SessionHelper.getSession("Attend_Auth") == null)
			{
				SessionHelper.setSession("Attend_Auth", attendCommonSvc.getUserAuthType());
				SessionHelper.setSession("Job_Type", attendCommonSvc.getUserJobAuthType());
			}	
			returnObj.put("attendAuth", SessionHelper.getSession("Attend_Auth"));
			returnObj.put("jobType", SessionHelper.getSession("Job_Type"));
			
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}

	//admin 근무지 관리 - 근무지 등록용 지도 팝업 화면 호출  2021.08.10 nkpark
	@RequestMapping(value = "/AttendMapWorkPlacePopup.do", method = RequestMethod.GET)
	public ModelAndView attendMapWorkPlacePopup(HttpServletRequest request,		HttpServletResponse response) {
		String returnURL = "user/attend/AttendMapWorkPlacePopup";
		CoviMap viewParams = new CoviMap();
		String WorkPlaceWithGrouping = RedisDataUtil.getBaseConfig("WorkPlaceWithGrouping");
		if(WorkPlaceWithGrouping.equalsIgnoreCase("Y")){
			WorkPlaceWithGrouping = "Y";
		}else{
			WorkPlaceWithGrouping = "N";
		}
		viewParams.put("WorkPlaceWithGrouping", WorkPlaceWithGrouping);
		return new ModelAndView(returnURL, viewParams);
	}

	/**
	 * @Method Name : getRewardTimeInfo
	 * @작성일 : 2022. 01. 21.
	 * @작성자 : yhshin
	 * @변경이력 :
	 * @Method 설명 : 회사설정 휴게시간관리 정보 가져오기
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "/getRewardTimeInfo.do", method = RequestMethod.GET)
	public @ResponseBody CoviMap getRewardTimeInfo(HttpServletRequest request) {
		CoviMap params = new CoviMap();
		CoviMap returnJson = new CoviMap();

		try {
			params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));

			CoviMap timeInfo = attendCommonSvc.getRewardTimeInfo(params);
			returnJson.put("timeInfo", timeInfo);

			returnJson.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnJson.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnJson.put("status", Return.FAIL);
		}

		return returnJson;
	}
	
	/**
	  * @Method 설명 : 등록 권한 별 조회 가능 부서 리스트 조회 (본부장:본인포함 하위부서, 그 외:본인 부서만)
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/getDeptListJobType.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDeptListJobType(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap deptObj = attendCommonSvc.getDeptListJobType();
			CoviList deptList = deptObj.getJSONArray("deptList");
			returnList.put("deptList", deptList); 
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
}