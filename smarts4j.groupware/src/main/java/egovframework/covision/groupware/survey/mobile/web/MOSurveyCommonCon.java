package egovframework.covision.groupware.survey.mobile.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.survey.user.service.SurveySvc;
import egovframework.covision.groupware.survey.user.web.SurveyVO;

//모바일 설문
@Controller
@RequestMapping("/mobile/survey")
public class MOSurveyCommonCon {
	
	private static final String FILE_SERVICE_TYPE = "Survey";
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	private SurveySvc surveySvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	// 설문(수정, 임시저장) 데이터 조회
	@RequestMapping(value = "/getSurveyData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSurveyData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			param.put("surveyID", request.getParameter("surveyId"));
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("ObjectID", "0");
			filesParams.put("ObjectType", "NONE");
			filesParams.put("MessageID", request.getParameter("surveyId"));
			filesParams.put("Version", "0");
			
			returnList.put("data", surveySvc.getSurveyQuestionItemList(param).get("list"));
			returnList.put("fileList", fileSvc.selectAttachAll(filesParams));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 미리보기 화면 이동
	@RequestMapping(value = "/goSurvey.do", method = RequestMethod.GET)
	public ModelAndView goSurvey(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		ModelAndView mav = new ModelAndView("user/survey/Survey");
		mav.addObject("result", returnList);
		
		return mav;
	}
	
	// 설문참여 > 등록
	@RequestMapping(value = "/insertQuestionItemAnswer.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertQuestionItemAnswer(@RequestBody SurveyVO surveyVO) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("surveyVo", surveyVO);
		
			int result = surveySvc.insertQuestionItemAnswer(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "추가 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 설문보기 화면 데이터 조회
	@RequestMapping(value = "/getSurveyAnswerData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSurveyAnswerData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			param.put("surveyID", request.getParameter("surveyId"));
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("ObjectID", "0");
			filesParams.put("ObjectType", "NONE");
			filesParams.put("MessageID", request.getParameter("surveyId"));
			filesParams.put("Version", "0");
			
			returnList.put("data", surveySvc.getQuestionItemAnswerList(param).get("list"));
			returnList.put("fileList", fileSvc.selectAttachAll(filesParams));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 진행중인 설문, 완료된 설문, 임시저장한 설문, 승인 및 검토요청 화면 데이터 조회
	@RequestMapping(value = "/getSurveyList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSurveyList(
			HttpServletRequest request,
			@RequestParam(value = "reqType", required = true) String reqType,
			@RequestParam(value = "schContentType", required = false) String schContentType,
			@RequestParam(value = "schMySel", required = false) String schMySel,
			@RequestParam(value = "schReqAppType", required = false, defaultValue="myApproval") String schReqAppType, 
			@RequestParam(value = "notReadFg", required = false) String notReadFg,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "simpleSchTxt", required = false) String simpleSchTxt,
			@RequestParam(value = "communityId", required = false) String communityId,
			@RequestParam(value = "startDate", required = false) String startDate,
			@RequestParam(value = "endDate", required = false) String endDate,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			//나의 설문 -> 내가 작성한 설문을 기본으로 설정
			if(reqType.equalsIgnoreCase("mySurvey") && schMySel.equals("")){
				schMySel = "written";
			}
			
			CoviMap params = new CoviMap();
			params.put("reqType", reqType); 		// proceed(진행중), complete(완료), tempSave(임시저장), reqApproval(검토, 승인 대기) 
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("schMySel", schMySel);
			params.put("schReqAppType", schReqAppType); //승인/검토에서만 사용
			params.put("notReadFg", notReadFg);
			params.put("schContentType", schContentType);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			params.put("simpleSchTxt", ComUtils.RemoveSQLInjection(simpleSchTxt, 100));
			params.put("startDate",startDate);
			params.put("endDate", endDate);
			params.put("communityId",communityId);
			params.put("isMobile", "Y");
			params.put("companyCode", SessionHelper.getSession("DN_Code"));
            params.put("lang", SessionHelper.getSession("lang"));
            
			resultList = surveySvc.getSurveyList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 임시저장한 설문 > 삭제
	@RequestMapping(value = "/deleteSurvey.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteSurvey(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="surveyIdArr[]", required=true) String[] surveyIdArr) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("surveyIdArr", surveyIdArr);
		
			int result = surveySvc.deleteSurvey(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "삭제 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 승인 및 검토요청, 설문관리 > 승인, 거부, 강제종료, 삭제
	@RequestMapping(value = "/updateSurveyState.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateSurveyState(@RequestParam(value="surveyIdArr[]", required=true) String[] surveyIdArr, @RequestParam(value="state", required=true) String state) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("surveyIdArr", surveyIdArr);			
			params.put("state", state);
		
			int result = surveySvc.updateSurveyState(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 설문차트보기 화면 이동
	@RequestMapping(value = "/goSurveyChartView.do", method = RequestMethod.GET)
	public ModelAndView goSurveyChartView(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap param = new CoviMap();
		param.put("surveyID", request.getParameter("surveyId"));
		
		CoviMap returnList = surveySvc.getAnswerListForChart(param);
		
		ModelAndView mav = new ModelAndView("user/survey/SurveyChartView");
		mav.addObject("result", returnList);
		
		return mav;
	}
	
	// 설문 대상 조회
	@RequestMapping(value = "/getTargetRespondentList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getTargetRespondentList(
			HttpServletRequest request,
			@RequestParam(value = "surveyId", required = true) String surveyId,
			@RequestParam(value = "targetType", required = false) String targetType,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "targetJoin", required = false) String targetJoin,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize			
			) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey = ( sortBy != null )? sortBy.split(" ")[0] : "DisplayName";
			String sortDirec = ( sortBy != null )? sortBy.split(" ")[1] : "ASC";
						
			CoviMap params = new CoviMap();
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("surveyID", surveyId);
			params.put("targetType", targetType);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			params.put("targetJoin", targetJoin);

			resultList = surveySvc.getTargetRespondentList(params);
			
			returnList.put("page",resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 결과공개 대상 조회 화면 이동
	@RequestMapping(value = "/goTargetResultviewList.do", method = RequestMethod.GET)
	public ModelAndView goTargetResultviewList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/survey/SurveyTargetResultview");
	}
	
	// 결과공개 대상 조회	
	@RequestMapping(value = "/getTargetResultviewList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getTargetResultviewList(
			HttpServletRequest request,
			@RequestParam(value = "surveyId", required = true) String surveyId,
			@RequestParam(value = "targetType", required = false) String targetType,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "targetJoin", required = false) String targetJoin,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "DisplayName";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "ASC";
						
			CoviMap params = new CoviMap();
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("surveyID", surveyId);
			params.put("targetType", targetType);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));

			resultList = surveySvc.getTargetResultviewList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 설문 통계보기 화면 이동
	@RequestMapping(value = "/goSurveyReportList.do", method = RequestMethod.GET)
	public ModelAndView goSurveyReportList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("admin/survey/SurveyReport");
	}
	
	// 설문 통계보기 조회	
	@RequestMapping(value = "/getSurveyReportList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSurveyReportList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("surveyID", request.getParameter("surveyId"));
			params.put("reqType", request.getParameter("reqType"));
			
			resultList = surveySvc.getSurveyReportList(params);

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
	
	// 설문 읽음 업데이트
	@RequestMapping(value = "/updateSurveyTargetRead.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateSurveyTargetRead(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("surveyId", request.getParameter("surveyId"));
		
			int result = surveySvc.updateSurveyTargetRead(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}

}