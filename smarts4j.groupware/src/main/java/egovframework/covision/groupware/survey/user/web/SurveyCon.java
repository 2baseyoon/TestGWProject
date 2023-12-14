package egovframework.covision.groupware.survey.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONSerializer;
import net.sf.jxls.transformer.XLSTransformer;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import org.apache.poi.ss.usermodel.Workbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.fasterxml.jackson.databind.ObjectMapper;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.filter.lucyXssFilter;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.collab.user.service.CollabTaskSvc;
import egovframework.covision.groupware.survey.user.service.SurveySvc;

// 전자설문
@Controller
@RequestMapping("survey")
public class SurveyCon {
	private Logger LOGGER = LogManager.getLogger(SurveyCon.class);
			
	private static final String FILE_SERVICE_TYPE = "Survey";
	
	@Autowired
	private SurveySvc surveySvc;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	private CollabTaskSvc collabTaskSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	// 설문(수정, 임시저장) 데이터 조회
	@RequestMapping(value = "/getSurveyData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSurveyData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		lucyXssFilter lucyXssFilter = new lucyXssFilter();
		
		try {
			CoviMap param = new CoviMap();
			param.put("surveyID", request.getParameter("surveyId"));
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("ObjectID", "0");
			filesParams.put("ObjectType", "NONE");
			filesParams.put("MessageID", request.getParameter("surveyId"));
			filesParams.put("Version", "0");
			
			returnList.put("data", lucyXssFilter.xssFilterJsonList(surveySvc.getSurveyQuestionItemList(param).get("list").toString()));
			returnList.put("fileList", fileSvc.selectAttachAll(filesParams));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
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
	
	// 설문작성 > 등록
	@RequestMapping(value = "/insertSurvey.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertSurvey(MultipartHttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			String surveyInfo = request.getParameter("surveyInfo");
			
			ObjectMapper mapper = new ObjectMapper();
			SurveyVO surveyVO = mapper.readValue(surveyInfo, SurveyVO.class);
			
			List<MultipartFile> mf = request.getFiles("files");

			if(!FileUtil.isEnableExtention(mf)){
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnData;
			}
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			params.put("surveyVo", surveyVO);
			
			int result = surveySvc.insertSurvey(params, filesParams, mf);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "추가 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "/insertCollabSurvey.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertCollabSurvey(MultipartHttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String surveyInfo = request.getParameter("surveyInfo");
			
			ObjectMapper mapper = new ObjectMapper();
			SurveyVO surveyVO = mapper.readValue(surveyInfo, SurveyVO.class);
			
			List<MultipartFile> mf = request.getFiles("files");

			if(!FileUtil.isEnableExtention(mf)){
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnData;
			}
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			params.put("surveyVo", surveyVO);
			
			int result = surveySvc.insertCollabSurvey(params, filesParams, mf);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "추가 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 설문수정
	@RequestMapping(value = "/updateSurvey.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateSurvey(MultipartHttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String surveyInfo = request.getParameter("surveyInfo");
			
			ObjectMapper mapper = new ObjectMapper();
			SurveyVO surveyVO = mapper.readValue(surveyInfo, SurveyVO.class);
			
			List<MultipartFile> mf = request.getFiles("files");
			
			if(!FileUtil.isEnableExtention(mf)){
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnData;
			}
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			params.put("surveyVo", surveyVO);
		
			int result = surveySvc.updateSurvey(params, filesParams, mf);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 설문수정
	@RequestMapping(value = "/updateCollabSurvey.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateCollabSurvey(MultipartHttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String surveyInfo = request.getParameter("surveyInfo");
			
			ObjectMapper mapper = new ObjectMapper();
			SurveyVO surveyVO = mapper.readValue(surveyInfo, SurveyVO.class);
			
			List<MultipartFile> mf = request.getFiles("files");
			
			if(!FileUtil.isEnableExtention(mf)){
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnData;
			}
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			params.put("surveyVo", surveyVO);
			
			int result = surveySvc.updateCollabSurvey(params, filesParams, mf);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 설문수정
	@RequestMapping(value = "/updateSurveyInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateSurveyInfo(MultipartHttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String surveyInfo = request.getParameter("surveyInfo");
			
			ObjectMapper mapper = new ObjectMapper();
			SurveyVO surveyVO = mapper.readValue(surveyInfo, SurveyVO.class);
			
			List<MultipartFile> mf = request.getFiles("files");
			
			if(!FileUtil.isEnableExtention(mf)){
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnData;
			}
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			params.put("surveyVo", surveyVO);
			
			int result = surveySvc.updateSurveyInfo(params, filesParams, mf);
			
			if(result > 0){
				String surveySubject = request.getParameter("surveySubject") == null ? surveyVO.getSubject() : request.getParameter("surveySubject");
				
				if(StringUtil.isNotEmpty(surveyVO.getPrjInfo())) {
					CoviMap prjInfo = CoviMap.fromObject(surveyVO.getPrjInfo());
					
					CoviMap updateParams = new CoviMap();
					
					if(!prjInfo.isEmpty()) {
						updateParams.put("prjSeq", prjInfo.getString("prjSeq"));
						updateParams.put("prjType", prjInfo.getString("prjType"));
						updateParams.put("sectionSeq", prjInfo.getString("sectionSeq"));
						updateParams.put("prjTxt", prjInfo.getString("prjTxt"));
					}

					updateParams.put("flag", "collabSurveyUpdate");
					updateParams.put("objectID", surveyVO.getSurveyID());
					updateParams.put("surveySubject", surveySubject);
					updateParams.put("objectType", "SURVEY");
					updateParams.put("startDate", surveyVO.getSurveyStartDate().replaceAll("\\.", ""));
					updateParams.put("endDate", surveyVO.getSurveyEndDate().replaceAll("\\.", ""));
					
					collabTaskSvc.updateTaskDate(updateParams);
				}
			}
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
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
	public @ResponseBody CoviMap insertQuestionItemAnswer(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			String surveyInfo = StringUtil.replaceNull(request.getParameter("surveyInfo"), "");
			surveyInfo = surveyInfo.replaceAll("&quot;", "\"");
			
			ObjectMapper mapper = new ObjectMapper();
			SurveyVO surveyVO = mapper.readValue(surveyInfo, SurveyVO.class);
			
			CoviMap params = new CoviMap();
			params.put("surveyVo", surveyVO);
		
			int result = surveySvc.insertQuestionItemAnswer(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "추가 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 설문참여 > 수정
	@RequestMapping(value = "/updateQuestionItemAnswer.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateQuestionItemAnswer(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			String surveyInfo = StringUtil.replaceNull(request.getParameter("surveyInfo"), "");
			surveyInfo = surveyInfo.replaceAll("&quot;", "\"");
			
			ObjectMapper mapper = new ObjectMapper();
			SurveyVO surveyVO = mapper.readValue(surveyInfo, SurveyVO.class);
			
			CoviMap params = new CoviMap();
			CoviMap delParams = new CoviMap();
			params.put("surveyVo", surveyVO);
			delParams.put("surveyID", surveyVO.getSurveyID());
			delParams.put("respondentCode", surveyVO.getRegisterCode());
			
			int delItemResult = surveySvc.deleteQuestionItemAnswer(delParams);
			int delEtcResult = surveySvc.deleteSurveyEtcOpinion(delParams);
			int insResult = 0;
			
			if(delItemResult != 0 && delEtcResult != 0){
				insResult = surveySvc.insertQuestionItemAnswer(params);
			}
			
			returnData.put("data", insResult);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "추가 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 설문보기 화면 데이터 조회
	@RequestMapping(value = "/getSurveyAnswerData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSurveyAnswerData(
			@RequestParam(value = "surveyId", required = true) String surveyId
			,@RequestParam(value = "viewType", required = true, defaultValue="myAnswer") String viewType
			,@RequestParam(value = "userID", required = false) String userID) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			if(userID == null && viewType.equalsIgnoreCase("myAnswer")){
				userID = SessionHelper.getSession("USERID");
			}
			
			param.put("surveyID", surveyId);
			param.put("viewType", viewType);
			param.put("userID", userID);
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("ObjectID", "0");
			filesParams.put("ObjectType", "NONE");
			filesParams.put("MessageID", surveyId);
			filesParams.put("Version", "0");
			
			
			returnList.put("data", surveySvc.getQuestionItemAnswerList(param).get("list"));
			returnList.put("fileList", fileSvc.selectAttachAll(filesParams));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
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
	
	// 진행중인 설문, 완료된 설문, 임시저장한 설문, 승인 및 검토요청 화면 데이터 조회
	@RequestMapping(value = "/getSurveyList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSurveyList(
			HttpServletRequest request,
			@RequestParam(value = "reqType", required = true) String reqType,
			@RequestParam(value = "schContentType", required = false) String schContentType,
			@RequestParam(value = "schMySel", required = false, defaultValue = "written") String schMySel,
			@RequestParam(value = "schState", required = false) String schState,
			@RequestParam(value = "notReadFg", required = false) String notReadFg,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "simpleSchTxt", required = false) String simpleSchTxt,
			@RequestParam(value = "communityId", required = false) String communityId,
			@RequestParam(value = "projectSeq", required = false) String projectSeq,
			@RequestParam(value = "startDate", required = false) String startDate,
			@RequestParam(value = "endDate", required = false) String endDate,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		lucyXssFilter lucyXssFilter = new lucyXssFilter();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			params.put("reqType", reqType); 		// proceed(진행중), complete(완료), tempSave(임시저장), reqApproval(검토, 승인 대기) 
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("schMySel", schMySel);
			params.put("schState", schState);
			params.put("notReadFg", notReadFg);
			params.put("schContentType", schContentType);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			params.put("simpleSchTxt", ComUtils.RemoveSQLInjection(simpleSchTxt, 100));
			params.put("startDate",startDate);
			params.put("endDate", endDate);
			params.put("communityId",communityId);
			params.put("projectSeq",projectSeq);
			params.put("companyCode", SessionHelper.getSession("DN_Code"));
			
			// 임시저장일 경우 등록일과 비교하기 때문에 타임존 처리 
			//if(reqType.equalsIgnoreCase("tempsave")) {
				//timezone 적용 날짜변환
				if(params.get("startDate") != null && !params.get("startDate").equals("")){
					params.put("startDate", ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
				}
				if(params.get("endDate") != null && !params.get("endDate").equals("")){
					params.put("endDate", ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
				}
			//}
			
			resultList = surveySvc.getSurveyList(params);
			
			returnList.put("list", lucyXssFilter.xssFilterJsonList(resultList.get("list").toString()));
			returnList.put("page",resultList.get("page")) ;
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
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
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
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

			if(StringUtil.equals(state, "del")) {
				for(String surveyId : surveyIdArr) {
					CoviMap param = new CoviMap();
					
					param.put("surveyID", surveyId);
					param.put("lang", SessionHelper.getSession("LanguageCode"));
					
					CoviMap surveyOne = surveySvc.selectSurveyInfoData(param);					

					// 설문이 진행 상태일 경우 삭제할 수 없음
					if(surveyOne.get("State").equals("F")) {						
						returnData.put("status", Return.FAIL);
						returnData.put("message", DicHelper.getDic("msg_NoDeleteProgressSurvey"));
						return returnData;
					}					 
				}
			}
		
			int result = surveySvc.updateSurveyState(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_Edited"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
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
	
	// 설문 대상 조회 화면 이동
	@RequestMapping(value = "/goTargetRespondentList.do", method = RequestMethod.GET)
	public ModelAndView goTargetRespondentList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/survey/SurveyTargetRespondent");
	}
	
	// 설문 대상 조회 ( 참여자 통계와 같이 사용 )
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
			
			returnList.put("page",resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
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
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
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
	
	// 설문관리(관리자) 화면 이동
	@RequestMapping(value = "/goSurveyManage.do", method = RequestMethod.GET)
	public ModelAndView goSurveyManage(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("admin/survey/SurveyManage");
	}
	
	// 설문관리(관리자) 조회	
	@RequestMapping(value = "/getSurveyManageList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSurveyManageList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		lucyXssFilter lucyXssFilter = new lucyXssFilter();
		try {
			CoviMap params = new CoviMap();
			
			String[] sortBy = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ");
			String sortColumn = "";
			String sortDirection = "";
			
			if(sortBy.length > 1) {
				sortColumn = ComUtils.RemoveSQLInjection(sortBy[0], 100);
				sortDirection = ComUtils.RemoveSQLInjection(sortBy[1], 100);
			}
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			params.put("companyCode", request.getParameter("companyCode"));
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));
			params.put("selType", request.getParameter("selType"));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			
			// 관리자화면에서의 DomainCode가 아닌 그룹웨어설정의 DomainID가 전달되었을 경우.
			params.put("domainId", request.getParameter("domainId"));
			
			resultList = surveySvc.getSurveyManageList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list",resultList.get("list"));
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
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
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
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 설문 승인, 거부 팝업 화면 이동
	@RequestMapping(value = "/goSurveyReqApproval.do", method = RequestMethod.GET)
	public ModelAndView goReqApproval(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/survey/SurveyReqApproval");
	}
	
	// 미참여자 알림
	@RequestMapping(value = "/sendNotAttendanceAlarm.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap sendNotAttendanceAlarm(
			@RequestParam(value = "targetCode", required = true) String targetCode,
			@RequestParam(value = "surveyID", required = true) String surveyID	) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			param.put("targetCode", targetCode);
			param.put("surveyID", surveyID);
			param.put("lang", SessionHelper.getSession("LanguageCode"));
			
			surveySvc.sendNotAttendanceAlarm(param);
				
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
	
	// 웹파트 설문 데이터 조회
	@RequestMapping(value = "/getWebpartSurveyList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getWebpartSurveyList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			param.put("userId", SessionHelper.getSession("USERID"));
				
			returnList.put("data", surveySvc.getWebpartSurveyList(param).get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
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
	
	// 엑셀저장 : 설문자료 저장
	@RequestMapping(value = "/excelDownloadRawData.do")
	public void excelDownloadRawData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			CoviMap params = new CoviMap();
			params.put("surveyID", request.getParameter("surveyId"));
			CoviMap resultList = surveySvc.selectSurveyRawDataExcelList(params);
			
			CoviMap excelParams = new CoviMap();
			excelParams.put("title", "설문자료");
			excelParams.put("list", resultList.get("list"));
			
			String FileName = new SimpleDateFormat("yyyy_MM_dd").format(new Date()) + "_SurveyRawData.xlsx";
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//SurveyRaw_templete.xlsx");
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, excelParams);
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+URLEncoder.encode(FileName,"UTF-8")+"\";");    
			response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}	
	
	// 엑셀저장 : 설문통계 저장
	@RequestMapping(value = "/excelDownloadStatistics.do")
	public void excelDownloadStatistics(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			CoviMap params = new CoviMap();
			params.put("surveyID", request.getParameter("surveyId"));
			CoviMap resultList = surveySvc.selectSurveyStatisticsExcelList(params);
			
			String subject = CoviMap.fromObject(resultList.get("list")).get("subject").toString();
			
			CoviMap excelParams = new CoviMap();
			excelParams.put("title", "설문통계_" + subject);
			excelParams.put("list", resultList.get("list"));
			
			String FileName = new SimpleDateFormat("yyyy_MM_dd").format(new Date()) + "_SurveyStatistics.xlsx";
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//Survey_templete.xlsx");
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, excelParams);
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+URLEncoder.encode(FileName,"UTF-8")+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	//설문 데이터 조회
	@RequestMapping(value = "/getSurveyInfoData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSurveyData(	@RequestParam(value = "surveyID", required = true) String surveyID	) throws Exception {
		CoviMap returnList = new CoviMap();
		lucyXssFilter lucyXssFilter = new lucyXssFilter();
		try {
			CoviMap param = new CoviMap();
			param.put("surveyID", surveyID);
			param.put("lang", SessionHelper.getSession("LanguageCode"));
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("ObjectID", "0");
			filesParams.put("ObjectType", "NONE");
			filesParams.put("MessageID", surveyID);
			filesParams.put("Version", "0");
			
			returnList.put("data", lucyXssFilter.xssFilterJsonList(surveySvc.selectSurveyInfoData(param).toString()));
			returnList.put("fileList", fileSvc.selectAttachAll(filesParams));
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
	
	// 웹파트 설문 데이터 목록형 조회
	@RequestMapping(value = "/getWebpartSurveyListNew.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getWebpartSurveyListNew(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			param.put("userId", SessionHelper.getSession("USERID"));
			param.put("reqType", "proceed");
			param.put("communityId", 0); 
			param.put("pageNo", 1); 
			param.put("pageSize", 1000); 
				
			returnList.put("data", surveySvc.getSurveyList(param).get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
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
	
	// 설문 작성 팝업(협업 스페이스)
	@RequestMapping(value = "/goSurveyCollabWritePopup.do", method = RequestMethod.GET)
	public ModelAndView goSurveyCollabWritePopup(@RequestParam Map<String, String> paramMap, HttpServletRequest request) throws Exception {
		ModelAndView mav = new ModelAndView("user/survey/SurveyCollabWritePopup");
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	// 설문 결과 조회 팝업(협업 스페이스)
	@RequestMapping(value = "/goSurveyCollabViewPopup.do", method = RequestMethod.GET)
	public ModelAndView goSurveyCollabViewPopup(@RequestParam Map<String, String> paramMap, HttpServletRequest request) throws Exception {
		ModelAndView mav = new ModelAndView("user/survey/SurveyView");
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	@RequestMapping(value = "/getCollabSurveyInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCollabSurveyInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("surveyID", request.getParameter("surveyID"));
			
			returnList.put("data", surveySvc.getCollabSurveyInfo(params));
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "/getTargetResultViewAuth.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getTargetResultViewAuth(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("surveyId", request.getParameter("surveyId"));
			params.put("userId", SessionHelper.getSession("USERID"));
			
			returnData.put("data", surveySvc.getSurveyTargetViewRead(params));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 웹파트 설문 데이터 조회
	@RequestMapping(value = "/getWebpartSurveyData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getWebpartSurveyData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			param.put("userId", SessionHelper.getSession("USERID"));
				
			returnList.put("data", surveySvc.getWebpartSurveyData(param).get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
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
	
	// 설문 승인자 이름 조회
	@RequestMapping(value = "/getSurveyApprover.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSurveyApprover(	@RequestParam(value = "code", required = true) String code	) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			
			param.put("code", code);
			returnList = surveySvc.getSurveyApprover(param);
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 설문 승인자 이름 조회
	@RequestMapping(value = "/getGroupFullPath.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getGroupFullPath(@RequestParam(value="targetarr[]", required=true) String[] targetarr) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {				
							
			CoviList paramsList = new CoviList();
			for(String target : targetarr){					
				CoviMap params = new CoviMap();
				
				params.put("UserCode", target);				
				paramsList.add(params);
			}
		returnList = surveySvc.getGroupFullPath(paramsList);
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
}