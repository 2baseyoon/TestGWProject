package egovframework.covision.groupware.attend.user.web;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestParam;





import net.sf.jxls.transformer.XLSTransformer;

import org.apache.poi.ss.usermodel.Workbook;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;
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
import egovframework.coviframework.util.LogHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.covision.groupware.attend.user.service.AttendScheduleSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;

import java.util.List;
@Controller
public class AttendScheduleCon {
	
	private Logger LOGGER = LogManager.getLogger(AttendScheduleCon.class);
	LogHelper logHelper = new LogHelper();
	
	@Autowired 
	AttendCommonSvc attendCommonSvc;

	@Autowired
	AttendScheduleSvc attendScheduleSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
		* @Method Name : getAttendScheduleList
		* @작성일 : 2019. 7. 1.
		* @작성자 : sjhan0418
		* @변경이력 : 최초생성
		* @Method 설명 : 근무제리스트 조회
		* @param request 
		* @param response
		* @return
		* @throws Exception
		*/
	@RequestMapping(value = "attendSchedule/getAttendScheduleList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAttendScheduleList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("schTypeSel", request.getParameter("schTypeSel"));
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));
			resultList = attendScheduleSvc.getAttendScheduleList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
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
	* @Method Name : AttendScheduleAddPopup
	* @Description : 추가화면 호출 
	*/
	@RequestMapping(value = "attendSchedule/AttendSchedulePopup.do", method = RequestMethod.GET)
	public ModelAndView attendSchedulePopup(HttpServletRequest request,
		HttpServletResponse response) throws Exception {
		String returnURL = "user/attend/AttendSchedulePopup";

		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("mode",	request.getParameter("mode"));
		if ("add".equals(request.getParameter("mode"))){
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
	
			mav.addObject("AttSeq",	AttSeq);
			CoviList weekList = new CoviList();
			for (int i=0; i < 8; i++){
				CoviMap weekData = new CoviMap();
				weekData.put("Week", i);
				weekData.put("AttDayStartTime", "0900");
				weekData.put("AttDayEndTime", "1800");
				weekList.add(weekData);
			}
			mav.addObject("week",	weekList);
		}
		else
		{
			CoviMap params = new CoviMap();
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("SchSeq", request.getParameter("SchSeq"));
			
			CoviMap resultObject = attendScheduleSvc.getAttendScheduleDetail(params);
			if (((CoviList)resultObject.get("list")).size()>0)
			{
				mav.addObject("data",	((CoviList)resultObject.get("list")).get(0));
				mav.addObject("week",	resultObject.get("list"));
			}	
		}

		//출근지
		CoviMap placeParams = new CoviMap();
		placeParams.put("SchSeq", request.getParameter("SchSeq"));
		placeParams.put("WorkPlaceType", 0);
		List<CoviMap> goWorkPlaceList = attendScheduleSvc.getAddWorkPlaceList(placeParams);
		mav.addObject("goWorkPlaceList",	goWorkPlaceList);
		//퇴근지
		placeParams.put("WorkPlaceType", 1);
		List<CoviMap> offWorkPlaceList = attendScheduleSvc.getAddWorkPlaceList(placeParams);
		mav.addObject("offWorkPlaceList",	offWorkPlaceList);

		//간주근로 유형
		CoviList assList= attendCommonSvc.getAssList();
		mav.addObject("assList",	assList);
		return mav;
	}

	/**
	* @Method Name : addAttendSchedule
	* @Description : 근무제추가
	*/
	@RequestMapping(value = "attendSchedule/saveAttendSchedule.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveAttendSchedule(HttpServletRequest request,HttpServletResponse response,	@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		int SchSeq = 0;

		try {
			CoviMap params = new CoviMap();
			params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("UserCode",		SessionHelper.getSession("UR_Code"));
			if (params.get("AssSeq").equals("")) params.remove("AssSeq");
			if (params.get("AttDayAC").equals(""))params.put("AttDayAC",		"0");
			if (params.get("AttDayIdle").equals(""))params.put("AttDayIdle",		"0");
			if (params.get("AllowRadius").equals(""))params.put("AllowRadius",		"0");
			int cnt =0;
			if ("add".equals(params.get("mode"))){
				SchSeq = attendScheduleSvc.addAttendSchedule(params);
				returnList.put("SchSeq", SchSeq);
			}	
			else
				cnt = attendScheduleSvc.saveAttendSchedule(params);

			CoviMap placeParams = new CoviMap();
			if ("add".equals(params.get("mode"))) {
				placeParams.put("SchSeq", SchSeq);
			} else {
				placeParams.put("SchSeq", params.get("SchSeq"));
			}
			//출근지 정보
			placeParams.put("WorkPlaceType", 0);
			attendScheduleSvc.deleteAttSchWorkPlace(placeParams); //삭제 후 다시 insert
			if(params.get("GoWorkPlaceCodes") != null && !"".equals(params.get("GoWorkPlaceCodes"))) {
				String[] goWorkPlaceCodes = params.get("GoWorkPlaceCodes").toString().split(",");
				for(int i=0; i<goWorkPlaceCodes.length; i++) {
					placeParams.put("LocationSeq", goWorkPlaceCodes[i]);
					attendScheduleSvc.insertAttSchWorkPlace(placeParams);
				}

			}
			//퇴근지 정보
			placeParams.put("WorkPlaceType", 1);
			attendScheduleSvc.deleteAttSchWorkPlace(placeParams); //삭제 후 다시 insert
			if(params.get("OffWorkPlaceCodes") != null && !"".equals(params.get("OffWorkPlaceCodes"))) {
				String[] offWorkPlaceCodes = params.get("OffWorkPlaceCodes").toString().split(",");
				for(int i=0; i<offWorkPlaceCodes.length; i++) {
					placeParams.put("LocationSeq", offWorkPlaceCodes[i]);
					attendScheduleSvc.insertAttSchWorkPlace(placeParams);
				}
			}

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	* @Method Name : deleteBudgetRegist
	* @Description : 근무제삭제
	*/
	@RequestMapping(value = "attendSchedule/deleteAttendSchedule.do")
	public @ResponseBody CoviMap deleteAttendSchedule(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			List jsonObject = (List)params.get("dataList");
			CoviMap returnObj = new CoviMap();
			int resultCnt = attendScheduleSvc.deleteAttendSchedule(jsonObject);
			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");

			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		}
		return returnList;
	}
	
	/**
	 * @Method Name : updateAttendScheduleBase
	 * @Description : flag 변경
	 * 			HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap,
			@RequestParam(value = "sortBy", required = false, defaultValue = "") String sortBy)

	 */
	@RequestMapping(value = "attendSchedule/updateAttendScheduleBase.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap updateAttendScheduleBase(HttpServletRequest request) throws Exception{

		CoviMap resultList = new CoviMap();
			
		try {
			int resultCnt = 0;
			CoviMap params = new CoviMap();
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("SchSeq", request.getParameter("SchSeq"));
			
			resultCnt = attendScheduleSvc.updateAttendScheduleBase(params);
			resultList.put("resultCnt", resultCnt);
			resultList.put("result", "ok");

			resultList.put("status", Return.SUCCESS);
			resultList.put("message", "저장");
		} catch (NullPointerException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : updateAttendScheduleValid
	 * @Description : flag 변경
	 * 			HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap,
			@RequestParam(value = "sortBy", required = false, defaultValue = "") String sortBy)

	 */
	@RequestMapping(value = "attendSchedule/updateAttendScheduleValid.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap updateAttendScheduleValid(HttpServletRequest request) throws Exception{

		CoviMap resultList = new CoviMap();
			
		try {
			int resultCnt = 0;
			CoviMap params = new CoviMap();
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("ValidYn", request.getParameter("ValidYn"));
			params.put("SchSeq", request.getParameter("SchSeq"));
			
			resultCnt = attendScheduleSvc.updateAttendScheduleValid(params);
			resultList.put("resultCnt", resultCnt);
			resultList.put("result", "ok");

			resultList.put("status", Return.SUCCESS);
			resultList.put("message", "저장");
		} catch (NullPointerException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		}
		
		return resultList;
	}
	/**
	 * @Method Name : downloadExcel
	 * @Description : 엑셀 다운로드
	 */
	@RequestMapping(value = "attendSchedule/downloadExcel.do")
	public ModelAndView downloadExcel(HttpServletRequest	request,			HttpServletResponse	response){
		ModelAndView mav		= new ModelAndView();
		CoviMap result	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			String[] headerNames = StringUtil.replaceNull(request.getParameter("headerName"), "").split("†");
			String[] headerKeys  = StringUtil.replaceNull(request.getParameter("headerKey"), "").split(",");
			
			CoviMap params = new CoviMap();
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("reqType", request.getParameter("reqType"));
			params.put("ValidCheck", request.getParameter("ValidCheck"));
			params.put("schTypeSel", request.getParameter("schTypeSel"));
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));
/*			
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("costCenterName",	request.getParameter("costCenterName"));
			params.put("baseTerm",			request.getParameter("baseTerm"));
			params.put("isControl",			request.getParameter("isControl"));
			params.put("isUse",				request.getParameter("isUse"));
			params.put("costCenterType",	request.getParameter("costCenterType"));
			
			params.put("searchType",		request.getParameter("searchType"));
			params.put("searchStr",			ComUtils.RemoveSQLInjection(request.getParameter("searchStr"), 100));
	*/		
			CoviMap resultList =attendScheduleSvc.getAttendScheduleList(params);
			CoviList cList = new CoviList();

			CoviMap convertList = new CoviMap();
			convertList.put("list", resultList.get("list"));
			
			viewParams.put("list",			convertList.get("list"));
			viewParams.put("cnt",			resultList.size());
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerKey",		headerKeys);
			viewParams.put("title",			request.getParameter("title"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (NullPointerException e) {
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			logHelper.getCurrentClassErrorLog(e);
		}
	
		return mav;
	}
	
	/**
	* @Method Name : goAttSchMemListPopup
	* @작성일 : 2019. 6. 18.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 지정자리스트 팝업
	* @param request
	* @param locale
	* @param model
	* @return
	* @throws Exception
	*/
	@RequestMapping(value = "attendSchedule/goAttSchMemListPopup.do", method = RequestMethod.GET)
	public ModelAndView goAttSchMemListPopup(HttpServletRequest request, Locale locale, Model model) throws Exception {
		
		ModelAndView mav = new ModelAndView("user/attend/AttendScheduleMemListPopup");
		//LOGGER.info("HANSJ!!!!!!!!!-------SCHSEQ : "+request.getParameter("SchSeq"));
		
		mav.addObject("SchSeq",request.getParameter("SchSeq"));
		return mav;
	}

	/**
	 * @Method Name : goAttSchMemAddPopup
	 * @작성일 : 2019. 6. 13.
	 * @작성자 : sjhan0418
	 * @변경이력 : 최초생성
	 * @Method 설명 : 지정자 추가 팝업
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "attendSchedule/goAttSchMemAddPopup.do", method = RequestMethod.GET)
	public ModelAndView goAttSchMemAddPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		
		ModelAndView mav = new ModelAndView("user/attend/AttendScheduleMemAddPopup");
	
		CoviMap params = new CoviMap();
		params = setSessionAttendanceInfo(params);

		SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd");
		
		Calendar cal = Calendar.getInstance(); 
		cal.setTime(new Date());
		cal.add(Calendar.DATE, 1);
		
		String StartDate = sdf.format(cal.getTime());
		LOGGER.debug("START DATE : "+StartDate);
		params.put("StartDate", StartDate);
		
	/*	date.setMonth(1);
		String EndDtae = sdf.format(date);
		LOGGER.debug("End DATE : "+EndDtae);
		params.put("EndDtae", EndDtae);*/

		
		mav.addObject("SchSeq",request.getParameter("SchSeq"));
		mav.addObject("params",params);
		return mav;
	}
	
	/**
	 * @Method Name : getAttendSchMemList
	 * @작성일 : 2019. 6. 13.
	 * @작성자 : sjhan0418
	 * @변경이력 : 최초생성
	 * @Method 설명 : 기준정보 근무제 지정자 등록 리스트 조회
	 * @param request
	 * @param response
	 * @param parameters 
	 * @return 
	 */
	@RequestMapping(value = "attendSchedule/getAttendSchMemList.do", method = RequestMethod.POST) 
	public @ResponseBody CoviMap getAttendSchMemList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, Object> parameters){
		CoviMap params = new CoviMap(); 
		CoviMap returnJson = new CoviMap();
//		params = setSessionAttendanceInfo(params); 
		//parameters
		try{
			params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
/*			String SchSeq = parameters.get("SchSeq")!=null?String.valueOf(parameters.get("SchSeq")):"";
			params.put("SchSeq", SchSeq);

			params.put("pageNo", parameters.get("pageNo")); 
			params.put("pageSize",  parameters.get("pageSize")); 
			
			params.put("S_StartDate", parameters.get("S_StartDate")); 
			params.put("S_EndDate", parameters.get("S_EndDate"));
			params.put("S_Specifier", ComUtils.RemoveSQLInjection(parameters.get("S_Specifier").toString(), 100));
*/
			CoviMap schMemList  = attendScheduleSvc.getSchMemberInfo(params);
			CoviMap page  = (CoviMap)schMemList.get("page");
			returnJson.put("schMemList", schMemList.get("list"));
			CoviMap pageJson = AttendUtils.pagingJson(  (int)page.get("pageNo"), (int)page.get("pageSize"),5, (int)page.get("listCount"));
			returnJson.put("page", pageJson);

			returnJson.put("status", Return.SUCCESS);
			returnJson.put("S_StartDate", parameters.get("S_StartDate"));
			returnJson.put("S_EndDate", parameters.get("S_EndDate"));
			returnJson.put("S_Specifier", parameters.get("S_Specifier"));

		} catch(NullPointerException e){
			returnJson.put("status", Return.FAIL); 
		} catch(Exception e){
			returnJson.put("status", Return.FAIL); 
		}
		
		return returnJson;
		
	}
	/**
	* @Method Name : setAttendanceSchMember
	* @작성일 : 2019. 6. 18.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 지정자등록
	* @param request
	* @param response
	* @param delSchArry
	* @return
	*/
	@RequestMapping(value = "attendSchedule/setAttendSchMember.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap setAttendSchMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, Object> parameters) {
		CoviMap params = new CoviMap(); 
		params = setSessionAttendanceInfo(params);
		CoviMap returnJson = new CoviMap();
		CoviList returnList = new CoviList();
		String paramsArry = parameters.get("paramsArry").toString();
		String SchSeq =		parameters.get("SchSeq").toString();
		String StartDtm = 	parameters.get("StartDtm").toString();
		String EndDtm = 	parameters.get("EndDtm").toString();
		//parameters 
		try{
			ObjectMapper mapper = new ObjectMapper();
			List<Map<String, Object>> userList = mapper.readValue(paramsArry, new TypeReference<ArrayList<Map<String, Object>>>(){});
			
			for(int i=0;i<userList.size();i++){
				Map<String, Object> map = userList.get(i);
				
				params.put("ValidCheck", "Y");
				params.put("p_UserCode", String.valueOf(map.get("UserCode")));
				params.put("nowYn", "D");
				params.put("P_StartDtm", StartDtm);
				params.put("P_EndDtm", EndDtm);

				CoviMap jo  = attendScheduleSvc.getSchMemberInfo(params);

				CoviList schMemList = (CoviList)jo.get("list");
				
				if(schMemList.size()>0){
					boolean flag = false;
					//날짜에 하나의 근무제만 걸리는 경우
					if(schMemList.size()==1){
						CoviMap psml = (CoviMap)schMemList.get(0);
						//등록하는 근무제가 기존과 같을때
						if(SchSeq.equals(psml.get("SchSeq"))){
							String sts = psml.get("Sts").toString();
							CoviMap psmlCMap = new CoviMap();
							psmlCMap = setSessionAttendanceInfo(psmlCMap);
							psmlCMap.put("p_UserCode", String.valueOf(map.get("UserCode")));
							if("A1".equals(sts)){	//당일 기준 시작일 도래 전
								psmlCMap.put("ScMemSeq",psml.get("ScMemSeq"));
								psmlCMap.put("SchSeq",psml.get("SchSeq"));
								psmlCMap.put("ValidYn","Y");
								psmlCMap.put("StartDtm",StartDtm);
								psmlCMap.put("EndDtm",EndDtm);
							}else if("A2".equals(sts)){ //당일 기준 시작일 도래 후 종료일 전
								psmlCMap.put("ScMemSeq",psml.get("ScMemSeq"));
								psmlCMap.put("SchSeq",psml.get("SchSeq"));
								psmlCMap.put("ValidYn","Y");
								psmlCMap.put("EndDtm",EndDtm);
							}else if("A3".equals(sts)){ //당일 기준 시작일 도래 후 종료일 동일
								psmlCMap.put("ScMemSeq",psml.get("ScMemSeq"));
								psmlCMap.put("SchSeq",psml.get("SchSeq"));
								psmlCMap.put("ValidYn","Y");
								psmlCMap.put("EndDtm",EndDtm);
							}
							
							LOGGER.debug("!!!!!!!!!!!!psmlCMap Sts!!!!!!!!!!!!!!!"+sts);
							LOGGER.debug("!!!!!!!!!!!!psmlCMap!!!!!!!!!!!!!!!"+psmlCMap);
							
							attendScheduleSvc.setSchMemberInfo(psmlCMap);
						}else{ 
							flag = true;
						}
					}else{
						flag = true;
					}
					if(flag){
						CoviMap nJson = new CoviMap();
						StringBuffer nSchName = new StringBuffer();
						for(int j=0;j<schMemList.size();j++){
							CoviMap nsml = (CoviMap)schMemList.get(j);
							if(j==0){
								nJson.put("userMulti", nsml.get("userMulti"));
							}else{
								nSchName.append(",");
							}
							nSchName.append(nsml.get("SchName"));
						}
						nJson.put("nAddSchName", nSchName.toString());
						returnList.add(nJson);
					}
				}else{
					CoviMap newPsmlCMap = new CoviMap();
					newPsmlCMap.put("SchSeq", SchSeq);
					newPsmlCMap.put("CompanyCode", params.get("CompanyCode"));
					newPsmlCMap.put("p_UserCode", String.valueOf(map.get("UserCode")));
					newPsmlCMap.put("UserCode", String.valueOf(map.get("UserCode")));
					newPsmlCMap.put("StartDtm", StartDtm);
					newPsmlCMap.put("EndDtm", EndDtm);
					newPsmlCMap.put("ValidYn", "Y");
					
					attendScheduleSvc.setSchMemberInfo(newPsmlCMap);
					
				}
				
							
			}			
			returnJson.put("returnList", returnList);
			returnJson.put("status", Return.SUCCESS);
		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnJson.put("status", Return.FAIL); 
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnJson.put("status", Return.FAIL); 
		}
		
		return returnJson;
		
		
	}

	/**
	 * @Method Name : delSchMemList
	 * @작성일 : 2019. 6. 18.
	 * @작성자 : sjhan0418
	 * @변경이력 : 최초생성
	 * @Method 설명 : 지정자삭제
	 * @param request
	 * @param response
	 * @param ScMemSeq
	 * @param SchSeq
	 * @return
	 */
	@RequestMapping(value = "attendSchedule/delAttendSchMember.do")
	public  @ResponseBody CoviMap delAttendSchMember(HttpServletRequest request, HttpServletResponse response	,@RequestParam(required=false) String[] ScMemSeq,@RequestParam(required=false) String SchSeq) {
		CoviMap params = new CoviMap(); 
		params = setSessionAttendanceInfo(params);
		CoviMap returnJson = new CoviMap();
		for(int i=0;i<ScMemSeq.length;i++){
			try {
				params.put("ScMemSeq", ScMemSeq[i].split(";")[0]);
				CoviMap jo  = attendScheduleSvc.getSchMemberInfo(params);
				CoviList schMemList = (CoviList)jo.get("list");
				for(int j=0;j<schMemList.size();j++){
					CoviMap schMemMap = (CoviMap)schMemList.get(j);
					
					String sts = (schMemMap.get("Sts") == null ?"":schMemMap.getString("Sts"));
					CoviMap delMap = new CoviMap();
					delMap = setSessionAttendanceInfo(delMap);
					delMap.put("ScMemSeq", ScMemSeq[i].split(";")[0]);
					delMap.put("p_UserCode",ScMemSeq[i].split(";")[1]);
					if("A1".equals(sts)){
						attendScheduleSvc.delSchMemberInfo(delMap);
					}else if("A2".equals(sts)){
						Date date = new Date();
						SimpleDateFormat sdf = new SimpleDateFormat("YYYY.MM.dd");
						delMap.put("EndDtm", sdf.format(date));
						delMap.put("ValidYn", "N");
						attendScheduleSvc.setSchMemberInfo(delMap);
					}else if("A3".equals(sts)){
						delMap.put("ValidYn", "N");
						attendScheduleSvc.setSchMemberInfo(delMap);
					}
				}

				returnJson.put("status", Return.SUCCESS); 
			} catch(ArrayIndexOutOfBoundsException e){
				LOGGER.error(e.getLocalizedMessage(), e);
				returnJson.put("status", Return.FAIL); 
			} catch(NullPointerException e){
				LOGGER.error(e.getLocalizedMessage(), e);
				returnJson.put("status", Return.FAIL); 
			} catch(Exception e){
				LOGGER.error(e.getLocalizedMessage(), e);
				returnJson.put("status", Return.FAIL); 
			}
			
		}
		
		return returnJson;
		
	}
	
	/**
	* @Method Name : goAttSchAllocListPopup
	* @작성일 : 2020. 3. 30.
	* @작성자 : 
	* @변경이력 : 최초생성
	* @Method 설명 : 사용가능리스트 팝업
	* @param request
	* @param locale
	* @param model
	* @return
	* @throws Exception
	*/
	@RequestMapping(value = "attendSchedule/goAttSchAllocListPopup.do", method = RequestMethod.GET)
	public ModelAndView goAttSchAllocListPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		ModelAndView mav = new ModelAndView("user/attend/AttendScheduleAllocListPopup");
		
		mav.addObject("SchSeq",request.getParameter("SchSeq"));
		return mav;
	}

	/**
	 * @Method Name : getAttendSchMemList
	 * @작성일 : 2019. 6. 13.
	 * @작성자 : sjhan0418
	 * @변경이력 : 최초생성
	 * @Method 설명 : 사용자 등록 리스트 조회
	 * @param request
	 * @param response
	 * @param parameters 
	 * @return 
	 */
	@RequestMapping(value = "attendSchedule/getAttendSchAllocList.do", method = RequestMethod.POST) 
	public @ResponseBody CoviMap getAttendSchAllocList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, Object> parameters){
		CoviMap params = new CoviMap(); 
		CoviMap returnJson = new CoviMap();

		try{
			params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("S_Specifier", ComUtils.RemoveSQLInjection(parameters.get("S_Specifier").toString(), 100));

			CoviMap schAllocList  = attendScheduleSvc.getSchAllocInfo(params);
			CoviMap page  = (CoviMap)schAllocList.get("page");
			returnJson.put("schMemList", schAllocList.get("list"));
			CoviMap pageJson = AttendUtils.pagingJson(  (int)page.get("pageNo"), (int)page.get("pageSize"),5, (int)page.get("listCount"));
			returnJson.put("page", pageJson);

			returnJson.put("status", Return.SUCCESS);
			returnJson.put("S_Specifier", parameters.get("S_Specifier"));

		} catch(NullPointerException e){
			returnJson.put("status", Return.FAIL); 
		} catch(Exception e){
			returnJson.put("status", Return.FAIL); 
		}
		
		return returnJson;
		
	}
	/**
	* @Method Name : setAttendanceSchMember
	* @작성일 : 2019. 6. 18.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 지정자등록
	* @param request
	* @param response
	* @param delSchArry
	* @return
	*/
	@RequestMapping(value = "attendSchedule/setAttendSchAlloc.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap setAttendSchAlloc(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			List jsonObject = (List)params.get("dataList");
			CoviMap returnObj = new CoviMap();

			int resultCnt = attendScheduleSvc.setSchAllocInfo(jsonObject);
			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");

			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		}
		return returnList;
		
		
	}

	/**
	 * @Method Name : delAttendSchAlloc
	 * @작성일 : 2019. 6. 18.
	 * @작성자 : sjhan0418
	 * @변경이력 : 최초생성
	 * @Method 설명 : 사용자삭제
	 * @param request
	 * @param response
	 * @param ScMemSeq
	 * @param SchSeq
	 * @return
	 */
	@RequestMapping(value = "attendSchedule/delAttendSchAlloc.do")
	public  @ResponseBody CoviMap delAttendSchAlloc(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			List jsonObject = (List)params.get("dataList");
			CoviMap returnObj = new CoviMap();
			int resultCnt = attendScheduleSvc.delSchAllocInfo(jsonObject);
			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");

			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		}
		return returnList;

		
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
	@RequestMapping(value = "attendSchedule/getWorkPlaceList.do")
	public @ResponseBody CoviMap getWorkPlaceList(HttpServletRequest request) {
		CoviMap params = new CoviMap();
		CoviMap returnJson = new CoviMap();

		try {
			params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));

			String validYn = request.getParameter("validYn");
			if(validYn!=null&&!validYn.equals("")){
				params.put("validYn", validYn);
			}
			List<CoviMap> dataList = attendScheduleSvc.getWorkPlaceList(params);
			returnJson.put("workPlaceList", dataList);

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
	* @Method Name : setSessionAttendanceInfo
	* @작성일 : 2019. 6. 5. 
	* @작성자 : sjhan0418
	* @변경이력 :
	* @Method 설명 : session 공통정보  parameter setting
	* @param params
	* @return
	*/
	public CoviMap setSessionAttendanceInfo(CoviMap params){ 
		
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		params.put("DeptCode", SessionHelper.getSession("DEPTID"));
		params.put("IsAdmin", SessionHelper.getSession("isAdmin"));
		params.put("UserCode", SessionHelper.getSession("USERID"));
		params.put("lang", SessionHelper.getSession("lang"));

		return params;
	}

}
