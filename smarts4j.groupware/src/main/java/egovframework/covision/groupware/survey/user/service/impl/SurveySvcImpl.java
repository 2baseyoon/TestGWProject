package egovframework.covision.groupware.survey.user.service.impl;

import java.io.File;
import java.lang.reflect.Field;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Set;

import javax.annotation.Resource;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.WordUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.EditorService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.service.MessageService;
import egovframework.covision.groupware.collab.user.service.CollabTaskSvc;
import egovframework.covision.groupware.survey.user.service.SurveySvc;
import egovframework.covision.groupware.survey.user.web.AnswerVO;
import egovframework.covision.groupware.survey.user.web.ItemVO;
import egovframework.covision.groupware.survey.user.web.QuestionVO;
import egovframework.covision.groupware.survey.user.web.SurveyVO;
import egovframework.covision.groupware.survey.user.web.TargetVO;

@Service("surveySvc")
public class SurveySvcImpl extends EgovAbstractServiceImpl implements SurveySvc {
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private FileUtilService fileSvc;

	@Autowired
	private MessageService messageSvc;
	
	@Autowired
	private EditorService editorService;
	
	@Autowired
	private CollabTaskSvc collabTaskSvc;
	
	// 설문 등록
	@Override
	public int insertSurvey(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		SurveyVO surveyVo = (SurveyVO) params.get("surveyVo");
		//surveyVo.setRegisterCode(SessionHelper.getSession("USERID"));
		CoviMap paramMap = convertVOToCoviMap(surveyVo);	// VO를 CoviMap으로 변환
		// surveyEndDate, surveyStartDate, resultViewStartDate, resultViewEndDate
		// 설문기간, 결과조회기간 서버 표준시간으로 변환
		paramMap.put("surveyStartDate", ComUtils.TransServerTime(paramMap.getString("surveyStartDate")+" 00:00:00")); 
		paramMap.put("surveyEndDate", ComUtils.TransServerTime(paramMap.getString("surveyEndDate")+" 23:59:59"));
		paramMap.put("resultViewStartDate", ComUtils.TransServerTime(paramMap.getString("resultViewStartDate")+" 00:00:00"));
		paramMap.put("resultViewEndDate", ComUtils.TransServerTime(paramMap.getString("resultViewEndDate")+" 23:59:59"));
		
		//Editor 처리
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Survey");  //BizSection
		editorParam.put("imgInfo", paramMap.getString("inlineImage"));  
		editorParam.put("objectID", "0");    
		editorParam.put("objectType", "NONE");    
		editorParam.put("messageID", "0");  
		editorParam.put("bodyHtml",paramMap.getString("description"));   //에디터 내용 

		CoviMap editorInfo = editorService.getContent(editorParam); 
		
        if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
        	throw new Exception("InlineImage move BackStorage Error");
        }
	
		surveyVo.setDescription( editorInfo.get("BodyHtml") == null ? paramMap.getString("description") : editorInfo.getString("BodyHtml"));
		paramMap.put("description" ,editorInfo.get("BodyHtml") == null ? paramMap.getString("description") : editorInfo.getString("BodyHtml"));
		
		//setUserInfo(paramMap);	// 다국어 유저 정보 세팅
		
		// 설문 등록
		int rtn = coviMapperOne.insert("user.survey.insertSurvey", paramMap);
		
		if (rtn > 0) {
			surveyVo.setSurveyID(paramMap.getString("SurveyID"));
			
			editorParam.put("messageID", paramMap.getString("SurveyID"));
			editorParam.addAll(editorInfo);
			
			editorService.updateFileMessageID(editorParam);
			
			insertQuestionItem(surveyVo);	// 문항, 보기 등록
			
			insertSurveyTarget(surveyVo);	// 참여 대상, 결과 공개 대상 등록
			
			if(paramMap.getString("state").equals("B") || paramMap.getString("state").equals("C")){ //검토 대기 OR 승인 대기일때
				sendMessage(paramMap,"ApprovalRequest");
			}else if(paramMap.getString("state").equals("F")){ //참여요청
				paramMap.put("surveyID",paramMap.getString("SurveyID"));
				sendMessage(paramMap,"RequestAttendant");
			}
			
			if(fileInfos != null) {
				CoviMap filesParams = new CoviMap();
				filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
				filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
				filesParams.put("MessageID", paramMap.getString("SurveyID"));
				filesParams.put("ObjectID", "0");
				filesParams.put("ObjectType", "NONE");
				
				insertSurveySysFile(filesParams, mf );
			}
		}
		
		return rtn;
	}
	
	
	// 설문 등록(협업 스페이스)
	@Override
	public int insertCollabSurvey(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		SurveyVO surveyVo = (SurveyVO) params.get("surveyVo");
		CoviMap prjInfo = CoviMap.fromObject(JSONSerializer.toJSON(surveyVo.getPrjInfo()));
		
		// 설문 등록
		int rtn = insertSurvey(params, fileInfos, mf);
		
		if (rtn > 0) {
			CoviMap reqMap = new CoviMap();	
			
			reqMap.put("prjSeq", prjInfo.getString("prjSeq"));
			reqMap.put("prjType", prjInfo.getString("prjType"));
			reqMap.put("sectionSeq", prjInfo.getString("sectionSeq"));
			reqMap.put("prjTxt", prjInfo.getString("prjTxt"));
			reqMap.put("objectID", surveyVo.getSurveyID());
			
			if(!surveyVo.getState().equals("A")){
				CoviMap trgMap = new CoviMap();
				
				List<CoviMap> trgMember = new ArrayList<CoviMap>();
				trgMap.put("userCode", SessionHelper.getSession("USERID"));
				trgMember.add(trgMap);
				
				reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
				reqMap.put("USERID", SessionHelper.getSession("USERID"));
				reqMap.put("taskName", surveyVo.getSubject());
				reqMap.put("startDate", ComUtils.removeMaskAll(surveyVo.getSurveyStartDate()));
				reqMap.put("endDate", ComUtils.removeMaskAll(surveyVo.getSurveyEndDate()));
				reqMap.put("taskStatus", "W");
				reqMap.put("progRate", "0");
				reqMap.put("parentKey", "0");
				reqMap.put("topParentKey", "0");
				reqMap.put("objectType", "SURVEY");
				
				collabTaskSvc.addTask(reqMap, trgMember);
			}
			
			coviMapperOne.insert("user.survey.insertCollabSurvey", reqMap);
		} 
		
		return rtn;
	}
	
	// 문항, 보기 등록
	private void insertQuestionItem(SurveyVO surveyVo) throws Exception {
		String surveyId = surveyVo.getSurveyID();
		
		List<QuestionVO> qVoList = new ArrayList<QuestionVO>(surveyVo.getQuestions());
		CoviMap paramMap = null; 
		
		for (QuestionVO qVo : qVoList) {
			List<ItemVO> iVoList = qVo.getItems();
			int iSize = iVoList.size();
			
			paramMap = convertVOToCoviMap(qVo);	// VO를 CoviMap으로 변환
			paramMap.put("surveyID", surveyId);
			paramMap.put("itemCount", qVo.getItemCount());
			
			coviMapperOne.insert("user.survey.insertSurveyQuestion", paramMap);	// 문항 등록
			
			int questionId = paramMap.getInt("QuestionID");
			
			if (iSize > 0) {
				for (ItemVO iVo : iVoList) {
					paramMap = convertVOToCoviMap(iVo);	// VO를 CoviMap으로 변환
					paramMap.put("surveyID", surveyId);
					paramMap.put("questionID", questionId);
					
					coviMapperOne.insert("user.survey.insertSurveyQuestionItem", paramMap);	// 보기 등록
					
					String itemId = paramMap.getString("ItemID");
					paramMap.put("objectId", itemId);
					
					if (!paramMap.getString("fileIds").isEmpty()) {	// front 이미지
						CoviList fileJa = CoviList.fromObject(paramMap.getString("fileIds"));					
						CoviList backFileJa = fileSvc.moveToBack(fileJa, "Survey/", "Survey", itemId, "NONE", "0");	// 프론트 TO 백
											
						String fileIds = "";
						int jaSize = backFileJa.size();
						StringBuffer buf = new StringBuffer();
						buf.append(";");
						for (int i=0; i<jaSize; i++) {
							CoviMap jo = backFileJa.getJSONObject(i);
							
							buf.append(jo.getString("FileID") + ";");
						}
						fileIds = buf.toString();
						
						if(!paramMap.getString("updateFileIds").isEmpty()){
							fileIds = fileIds.substring(0, fileIds.length() - 1) + paramMap.getString("updateFileIds");
						}
						
						paramMap.put("itemId", itemId);
						paramMap.put("fileId", fileIds);
						
						coviMapperOne.update("user.survey.updateSurveyQuestionItemFileId", paramMap);	// front 이미지 등록
					}else if(!paramMap.getString("updateFileIds").isEmpty()) {	// back 이미지
						paramMap.put("itemId", itemId);
						paramMap.put("fileId", paramMap.getString("updateFileIds"));
						
						coviMapperOne.update("user.survey.updateSurveyQuestionItemFileId", paramMap);	// back 이미지 수정
					}
					
					
					if (!paramMap.getString("deleteFileIds").isEmpty()) {	// back 이미지
						paramMap.put("fileIdArr", paramMap.getString("deleteFileIds").split("\\,"));
						
						coviMapperOne.delete("framework.FileUtil.deleteFileDbByFileId", paramMap);	// back 이미지 삭제
						
						if(!paramMap.getString("updateFileIds").isEmpty()) {	// back 이미지
							paramMap.put("itemId", itemId);
							paramMap.put("fileId", paramMap.getString("updateFileIds"));
							
							coviMapperOne.update("user.survey.updateSurveyQuestionItemFileId", paramMap);	// back 이미지 수정
						}
					}
				}
			}
		}
	}
	
	// 참여 대상, 결과 공개 대상 등록
	private void insertSurveyTarget(SurveyVO surveyVo) throws Exception {
		String surveyId = surveyVo.getSurveyID();
		String targetResType = surveyVo.getTargetRespondentType();
		
		List<TargetVO> rVoList = new ArrayList<TargetVO>(surveyVo.getRespondentTarget());
		CoviMap paramMap = null;
		
		
		if( targetResType.equals("S") ) { //지정
			
			for (TargetVO tVo : rVoList) {
				paramMap = convertVOToCoviMap(tVo);	// VO를 CoviMap으로 변환
				paramMap.put("surveyId", surveyId);
				
				coviMapperOne.insert("user.survey.insertSurveyRespondentTarget", paramMap);	// 참여대상 등록
			}
			
			rVoList = new ArrayList<TargetVO>(surveyVo.getResultviewTarget());
			
			for (TargetVO tVo : rVoList) {
				paramMap = convertVOToCoviMap(tVo);
				paramMap.put("surveyId", surveyId);
				
				coviMapperOne.insert("user.survey.insertsurveyresultviewTarget", paramMap);	// 결과 공개 대상 등록
			}	
			
		} else if(targetResType.equals("P")) { // 프로젝트
			CoviMap prjInfo = CoviMap.fromObject(JSONSerializer.toJSON(surveyVo.getPrjInfo()));
			String prjSeq = prjInfo.getString("prjSeq");
			String prjType = prjInfo.getString("prjType");
			
			paramMap = new CoviMap();
			paramMap.put("surveyId", surveyId);
			paramMap.put("targetType", "UR");
			paramMap.put("prjSeq", prjSeq);
			paramMap.put("prjType", prjType);
			
			if (prjType.equals("T")) {
				paramMap.put("jobTitleCodes", Arrays.asList(RedisDataUtil.getBaseConfig("WorkReportTMJobTitle", SessionHelper.getSession("DN_ID")).split("\\|")));
			}
			
			coviMapperOne.insert("user.survey.insertCollabSurveyRespondentTarget", paramMap);
			coviMapperOne.insert("user.survey.insertCollabSurveyresultviewTarget", paramMap);
		} else { //커뮤니티			
			paramMap = new CoviMap();
			paramMap.put("surveyId", surveyId);
			paramMap.put("targetType", "UR");			
			paramMap.put("communityID", surveyVo.getCommunityID());			
			coviMapperOne.insert("user.survey.insertSurveyRespondentTargetCmnty", paramMap);
			coviMapperOne.insert("user.survey.insertsurveyresultviewTargetCmnty", paramMap);
		}
			
	}
	
	// 설문 조회(문항, 보기 포함)
	@Override
	public CoviMap getSurveyQuestionItemList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", makeSurveyJsonobject(params));	// 설문 데이터 jsonobject 생성
		
		return resultList;
	}
	
	// 설문 수정
	@Override
	public int updateSurvey(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		SurveyVO surveyVo = (SurveyVO) params.get("surveyVo");
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		//surveyVo.setRegisterCode(SessionHelper.getSession("USERID"));
		
		StringUtil func = new StringUtil();
		CoviMap paramMap = convertVOToCoviMap(surveyVo);	// VO를 CoviMap으로 변환
		
		// 설문시간 서버타임으로 변환하여 등록
		paramMap.put("surveyStartDate", ComUtils.TransServerTime(paramMap.getString("surveyStartDate")+" 00:00:00")); 
		paramMap.put("surveyEndDate", ComUtils.TransServerTime(paramMap.getString("surveyEndDate")+" 23:59:59"));
		paramMap.put("resultViewStartDate", ComUtils.TransServerTime(paramMap.getString("resultViewStartDate")+" 00:00:00"));
		paramMap.put("resultViewEndDate", ComUtils.TransServerTime(paramMap.getString("resultViewEndDate")+" 23:59:59"));
		
		//Editor 처리
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Survey");  //BizSection
		editorParam.put("imgInfo", paramMap.getString("inlineImage"));  
		editorParam.put("objectID", "0");    
		editorParam.put("objectType", "NONE");    
		editorParam.put("messageID", paramMap.getString("surveyID"));  
		editorParam.put("bodyHtml",paramMap.getString("description"));   //에디터 내용 

		CoviMap editorInfo = editorService.getContent(editorParam); 
	
		surveyVo.setDescription( editorInfo.get("BodyHtml") == null ? paramMap.getString("description") : editorInfo.getString("BodyHtml"));
		paramMap.put( "description" ,editorInfo.get("BodyHtml") == null ? paramMap.getString("description") : editorInfo.getString("BodyHtml"));
		
		
		int rtn = coviMapperOne.update("user.survey.updateSurvey", paramMap);	// 설문 수정
		
		if(paramMap.getString("state").equals("B") || paramMap.getString("state").equals("C")){ //검토 대기 OR 승인 대기일때
			sendMessage(paramMap,"ApprovalRequest");
		}
		int delCnt = 0;
		int delTargetCnt = 0;
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			delCnt = coviMapperOne.delete("user.survey.deleteQuestionItem", paramMap);	// 문항, 보기 삭제
			delCnt += coviMapperOne.delete("user.survey.deleteQuestion", paramMap);	// 문항, 보기 삭제
		}else{
			delCnt = coviMapperOne.delete("user.survey.deleteQuestionItem", paramMap);	// 문항, 보기 삭제
		}
		
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			delTargetCnt = coviMapperOne.delete("user.survey.deleteSurveyTarget", paramMap);	// 참여자, 결과 공개 대상자 삭제.
			delTargetCnt += coviMapperOne.delete("user.survey.deleteSurveyTargetRV", paramMap);	// 문항, 보기 삭제
		}else{
			delTargetCnt = coviMapperOne.delete("user.survey.deleteSurveyTarget", paramMap);	// 참여자, 결과 공개 대상자 삭제.
		}
		
		surveyVo.setSurveyID(paramMap.getString("surveyID"));
		
		if (delCnt > 0) {
			insertQuestionItem(surveyVo);	// 문항, 보기 등록
		}	

	/*	if(delTargetCnt > 0){*/
			insertSurveyTarget(surveyVo);	// 참여 대상, 결과 공개 대상 등록
		/*}*/
		
		//첨부파일 처리 
		if(fileInfos != null) {
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("fileCnt", fileInfos.getString("fileCnt"));
			filesParams.put("MessageID", paramMap.getString("surveyID"));
			filesParams.put("ObjectID", "0");
			filesParams.put("ObjectType", "NONE");
			updateSurveySysFile(filesParams, mf);
		}
		
		
		return rtn;
	}
	
	@Override
	public int updateCollabSurvey(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		SurveyVO surveyVo = (SurveyVO) params.get("surveyVo");
		CoviMap prjInfo = CoviMap.fromObject(JSONSerializer.toJSON(surveyVo.getPrjInfo()));
		
		// 설문 수정
		int rtn = updateSurvey(params, fileInfos, mf);
		
		if (rtn > 0) {
			CoviMap reqMap = new CoviMap();	
			
			reqMap.put("prjSeq", prjInfo.getString("prjSeq"));
			reqMap.put("prjType", prjInfo.getString("prjType"));
			reqMap.put("sectionSeq", prjInfo.getString("sectionSeq"));
			reqMap.put("prjTxt", prjInfo.getString("prjTxt"));
			reqMap.put("objectID", surveyVo.getSurveyID());
			
			if(surveyVo.getState().equals("F")){
				CoviMap trgMap = new CoviMap();
				
				List<CoviMap> trgMember = new ArrayList<CoviMap>();
				trgMap.put("userCode", SessionHelper.getSession("USERID"));
				trgMember.add(trgMap);
				
				reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
				reqMap.put("USERID", SessionHelper.getSession("USERID"));
				reqMap.put("taskName", surveyVo.getSubject());
				reqMap.put("startDate", ComUtils.removeMaskAll(surveyVo.getSurveyStartDate()));
				reqMap.put("endDate", ComUtils.removeMaskAll(surveyVo.getSurveyEndDate()));
				reqMap.put("taskStatus", "W");
				reqMap.put("progRate", "0");
				reqMap.put("parentKey", "0");
				reqMap.put("topParentKey", "0");
				reqMap.put("objectType", "SURVEY");
				
				collabTaskSvc.addTask(reqMap, trgMember);
			}
			
			coviMapperOne.insert("user.survey.insertCollabSurvey", reqMap);
		}
		
		return rtn;
	}
	
	// 설문 정보 수정
	@Override
	public int updateSurveyInfo(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		SurveyVO surveyVo = (SurveyVO) params.get("surveyVo");
		CoviMap paramMap = convertVOToCoviMap(surveyVo);	// VO를 CoviMap으로 변환
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		
		StringUtil func = new StringUtil();
		// 설문기간, 결과조회기간 서버 표준시간으로 변환
		paramMap.put("surveyStartDate", ComUtils.TransServerTime(paramMap.getString("surveyStartDate")+" 00:00:00")); 
		paramMap.put("surveyEndDate", ComUtils.TransServerTime(paramMap.getString("surveyEndDate")+" 23:59:59"));
		paramMap.put("resultViewStartDate", ComUtils.TransServerTime(paramMap.getString("resultViewStartDate")+" 00:00:00"));
		paramMap.put("resultViewEndDate", ComUtils.TransServerTime(paramMap.getString("resultViewEndDate")+" 23:59:59"));
		
		//Editor 처리
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Survey");  //BizSection
		editorParam.put("imgInfo", paramMap.getString("inlineImage"));  
		editorParam.put("objectID", "0");    
		editorParam.put("objectType", "NONE");    
		editorParam.put("messageID", paramMap.getString("surveyID"));  
		editorParam.put("bodyHtml",paramMap.getString("description"));   //에디터 내용 

		CoviMap editorInfo = editorService.getContent(editorParam); 
		
        if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
        	throw new Exception("InlineImage move BackStorage Error");
        }
	
		surveyVo.setDescription( editorInfo.getString("BodyHtml"));
		paramMap.put( "description" ,editorInfo.getString("BodyHtml"));
		
		int rtn = coviMapperOne.update("user.survey.updateSurvey", paramMap);	// 설문 수정
		
		if(paramMap.getString("state").equals("B") || paramMap.getString("state").equals("C")){ //검토 대기 OR 승인 대기일때
			sendMessage(paramMap,"ApprovalRequest");
		}
		
		int delTargetCnt = 0;
		
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			delTargetCnt = coviMapperOne.delete("user.survey.deleteSurveyTarget", paramMap);	// 참여자, 결과 공개 대상자 삭제.
			delTargetCnt += coviMapperOne.delete("user.survey.deleteSurveyTargetRV", paramMap);
		}else{
			delTargetCnt = coviMapperOne.delete("user.survey.deleteSurveyTarget", paramMap);	// 참여자, 결과 공개 대상자 삭제.
		}
		
		insertSurveyTarget(surveyVo);
		
		//첨부파일 처리 
		if(fileInfos != null) {
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("fileCnt", fileInfos.getString("fileCnt"));
			filesParams.put("MessageID", paramMap.getString("surveyID"));
			filesParams.put("ObjectID", "0");
			filesParams.put("ObjectType", "NONE");
			updateSurveySysFile(filesParams, mf);
		}
		
		return rtn;
	}
	
	// 설문 참여 등록
	@Override
	public int insertQuestionItemAnswer(CoviMap params) throws Exception {
		SurveyVO surveyVo = (SurveyVO) params.get("surveyVo");
		List<AnswerVO> aVoList = new ArrayList<AnswerVO>(surveyVo.getAnswers());
		//CoviMap userInfoMap = new CoviMap();
		//userInfoMap.put("respondentCode", SessionHelper.getSession("USERID"));
		//setUserInfo(userInfoMap);	// 다국어 유저 정보 세팅
		
		String respondentCode = SessionHelper.getSession("USERID");
/*		String respondentName = "이승목;Seung-Mok Lee;;李承穆;;;;;;;;;;;;;;;;;";
		String respondentLevel = "대리;chief;代理;代理;;;;;;;;;;;;;;;;";
		String respondentPosition = "대리;chief;代理;代理;;;;;;;;;;;;;;;;;;;;;;;;;";
		String respondentTitle = "팀원;Team Members;チーム員;職員;;;;;;;;;;;;;;;;;;;;;;;;;";*/
		String respondentDept = SessionHelper.getSession("DEPTID");
   		
		int rtn = 0;
		CoviMap paramMap = new CoviMap();
		
		for (AnswerVO aVo : aVoList) {
			String questionType = aVo.getQuestionType();
			if (questionType != null) {
				paramMap = convertVOToCoviMap(aVo);	// VO를 CoviMap으로 변환
				
				String itemId = paramMap.getString("itemID");
				String [] itemIdArr = itemId.split(";");
				String [] itemArr = paramMap.getString("answerItem").split(";");
				String [] weighting = paramMap.getString("weighting").split(";");
				
				if (!itemId.isEmpty()) {
					for (int i = 0; i < itemIdArr.length; i++) {
						paramMap.put("itemID", itemIdArr[i]);
						paramMap.put("answerItem", itemArr[i]);
						
						if (questionType.equals("N") && weighting.length > 0) {
							if(weighting.length > i) {
								paramMap.put("weighting", weighting[i]);
							} else {
								paramMap.put("weighting", 0);
							}
						} else {
							paramMap.put("weighting", 0);			// mysql bugfix			
						}
						paramMap.put("respondentCode", respondentCode);
/*						paramMap.put("respondentName", respondentName);
						paramMap.put("respondentLevel", respondentLevel);
						paramMap.put("respondentPosition", respondentPosition);
						paramMap.put("respondentTitle", respondentTitle);*/
						paramMap.put("respondentDeptCode", respondentDept);
						
						// 설문 참여 등록
						rtn += coviMapperOne.insert("user.survey.insertQuestionItemAnswer", paramMap);
					}
				}
			}
		}
		
		//답변이 없어도 참여는 인정되도록 수정
		/*if (rtn > 0) {*/
			paramMap.put("etcOpinion", surveyVo.getEtcOpinion());
			paramMap.put("respondentCode", respondentCode);
/*			paramMap.put("respondentName", respondentName);
			paramMap.put("respondentLevel", respondentLevel);
			paramMap.put("respondentPosition", respondentPosition);
			paramMap.put("respondentTitle", respondentTitle);*/
			paramMap.put("respondentDeptCode", respondentDept);
			
			coviMapperOne.insert("user.survey.insertSurveyEtcOpinion", paramMap);	// 설문 참여 의견 등록
		/*	}*/
		
		
		
		return rtn;
	}
	
	// 설문 참여 결과 조회
	@Override
	public CoviMap getQuestionItemAnswerList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap surveyJo = makeSurveyJsonobject(params);	// 설문 데이터 jsonobject 생성
		
		CoviList list = coviMapperOne.list("user.survey.selectQuestionItemAnswerList", params);
		CoviList ja = CoviSelectSet.coviSelectJSON(list, "SurveyID,QuestionID,AnswerItemId,AnswerItem,EtcOpinion,RespondentCode");
		JSONArray userJa = new JSONArray();
		
		for (int i=0; i<ja.size(); i++) {
			CoviMap jo = ja.getJSONObject(i);
			CoviMap uObj = new CoviMap();
			String userId = jo.getString("RespondentCode");
			uObj.put("userId", userId);
			
			if (userJa.isEmpty()) {
				CoviList answerJa = new CoviList();
				answerJa.add(jo);
				uObj.put("answers", answerJa);
				userJa.add(uObj);
			} else {
				int index = getIndexInArr("userId", userId, userJa);	// 리스트 포함 여부 확인
				
				if (index == -1) {
					CoviList answerJa = new CoviList();
					answerJa.add(jo);
					uObj.put("answers", answerJa);
					userJa.add(uObj);
				} else {
					(userJa.getJSONObject(index)).getJSONArray("answers").add(jo);
				}
			}
		}
		
		surveyJo.put("userAnswers", userJa);

		resultList.put("list", surveyJo);
		
		return resultList;
	}
	
	// 설문 조회
	@Override
	public CoviMap getSurveyList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList retList = new CoviList();
		CoviMap page = new CoviMap();
		int retCnt = 0;
		
		params.put("userId", SessionHelper.getSession("USERID"));
		params.put("lang",SessionHelper.getSession("lang"));
		
		if(params.getString("reqType").equalsIgnoreCase("mySurvey") && params.getString("schMySel").equalsIgnoreCase("written")){ //나의 설문 - 내가 작성한 설문
			retCnt =  (int) coviMapperOne.getNumber("user.survey.selectMySurveyListCnt", params);
			page = ComUtils.setPagingData(params,retCnt);
			params.addAll(page);
			
			retList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.survey.selectMySurveyList", params), 
					"SurveyID,Subject,SubjectHtml,IsImportance,State,SurveyStartDate,SurveyEndDate,RegisterCode,RegisterName,MailAddress,IsTargetRespondent,joinFg,CommunityID,RegistDate,ModifyDate");
		}else if(params.getString("reqType").equalsIgnoreCase("mySurvey") && params.getString("schMySel").equalsIgnoreCase("participated")){ //나의 설문 - 내가 참여한 설문
			retCnt =  (int) coviMapperOne.getNumber("user.survey.selectJoinSurveyListCnt", params);
			page = ComUtils.setPagingData(params,retCnt);
			params.addAll(page);
			
			retList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.survey.selectJoinSurveyList", params), 
					"SurveyID,Subject,SubjectHtml,IsImportance,State,SurveyStartDate,SurveyEndDate,RegisterCode,RegisterName,IsTargetResultView,CommunityID,Description,RegistDate");
		}else if(params.getString("reqType").equalsIgnoreCase("proceed")){
			retCnt =  (int) coviMapperOne.getNumber("user.survey.selectProceedSurveyListCnt", params);
			page = ComUtils.setPagingData(params,retCnt);
			params.addAll(page);
			
			retList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.survey.selectProceedSurveyList", params), 
					"SurveyID,Subject,SubjectHtml,IsImportance,SurveyStartDate,SurveyEndDate,RegisterCode,RegisterName,MailAddress,readFg,IsTargetRespondent,IsTargetResultView,joinFg,joinRate,CommunityID,Description,RegistDate");
		}else if(params.getString("reqType").equalsIgnoreCase("complete")){
			retCnt =  (int) coviMapperOne.getNumber("user.survey.selectCompleteSurveyListCnt", params);
			page = ComUtils.setPagingData(params,retCnt);
			params.addAll(page);
			
			retList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.survey.selectCompleteSurveyList", params), 
					"SurveyID,Subject,SubjectHtml,IsImportance,SurveyStartDate,SurveyEndDate,RegisterCode,RegisterName,MailAddress,readFg,CommunityID,IsTargetResultView,joinFg,joinRate,CommunityID,Description,RegistDate");
		}else if(params.getString("reqType").equalsIgnoreCase("tempsave")){
			retCnt =  (int) coviMapperOne.getNumber("user.survey.selectTempSaveSurveyListCnt", params);
			page = ComUtils.setPagingData(params,retCnt);
			params.addAll(page);
			
			retList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.survey.selectTempSaveSurveyList", params), 
					"SurveyID,Subject,RegisterCode,RegistDate");
		}else if(params.getString("reqType").equalsIgnoreCase("reqApproval")){
			retCnt = (int) coviMapperOne.getNumber("user.survey.selectReqApprovalSurveyListCnt", params);
			page = ComUtils.setPagingData(params,retCnt);
			params.addAll(page);
			
			retList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.survey.selectReqApprovalSurveyList", params), 
					"SurveyID,Subject,SubjectHtml,IsImportance,State,SurveyStartDate,SurveyEndDate,RegisterCode,RegisterName,MailAddress,Description,RegistDate,CommunityID,ReviewerCode,ApproverCode");
		}
		
		resultList.put("list", retList);
		resultList.put("page", page);
		
		return resultList;
	}
	
	// 설문 삭제
	@Override
	public int deleteSurvey(CoviMap params) throws Exception {
		int rtn = coviMapperOne.delete("user.survey.deleteSurvey", params);
		
		if(rtn > 0) {
			// 협업스페이스 설문 삭제
			int collabCnt = (int) coviMapperOne.getNumber("user.survey.selectCollabSurveyCnt", params);
			
			if(collabCnt > 0) {
				coviMapperOne.delete("user.survey.deleteCollabSurvey", params);
			}
		}
		
		return rtn;
	}
	
	// 설문 상태 수정
	@Override
	public int updateSurveyState(CoviMap params) throws Exception {
		// 설문상태(A:작성중, B:검토대기, D:검토거부, C:승인대기, X:승인거부, F:진행중, G:설문종료)
		
		CoviList updateList = coviMapperOne.list("user.survey.selectArrSurveyData", params); //surveyID, subject, state, registerCode, reviewerCode, approverCode

		int retCnt = coviMapperOne.update("user.survey.updateSurveyState", params);
		
		for(int i = 0 ; i < updateList.size(); i++){
			CoviMap obj = updateList.getMap(i);
			if(params.getString("state").equals("B") || params.getString("state").equals("C")){ //검토 대기 OR 승인 대기일때
					sendMessage(obj, "ApprovalRequest"); //승인요청
			}
			
			if( ( obj.getString("state").equals("B") && (params.getString("state").equals("C")|| params.getString("state").equals("F")) )
				|| ( obj.getString("state").equals("C")  && params.getString("state").equals("F")  )	){
				obj.put("senderCode", SessionHelper.getSession("UR_Code"));
				sendMessage(obj, "ApprovalCompleted"); //승인완료
			}
			
			if(params.getString("state").equals("F")){
				sendMessage(obj, "RequestAttendant");
			}
			
			if(params.getString("state").equals("X")){
				sendMessage(obj, "ApprovalCancel");
			}
			
			// 협업스페이스 업무
			if(params.getString("state").equals("del")){
				CoviMap delMap = new CoviMap();
				delMap.put("objectID", obj.get("surveyID"));
				delMap.put("objectType", "SURVEY");
				
				collabTaskSvc.deleteTaskList(delMap);
			}
		}
		
		return retCnt;
	}	
	
	// 차트 데이터 조회
	@Override
	public CoviMap getAnswerListForChart(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap surveyJo = makeSurveyJsonobject(params);	// 설문 데이터 jsonobject 생성
		
		CoviList list = coviMapperOne.list("user.survey.selectAnswerForChart", params);
		CoviList ja = CoviSelectSet.coviSelectJSON(list, "QuestionID,AnswerItem,EtcOpinion,RespondentCode,CNT,Weighting");		
		JSONArray qJa = new JSONArray();
		
		for (int i=0; i<ja.size(); i++) {
			CoviMap jo = ja.getJSONObject(i);
			String questionId = jo.getString("QuestionID");
			String weighting = jo.getString("Weighting");
			CoviMap qObj = new CoviMap();
			qObj.put("questionId", questionId);
			qObj.put("weighting", weighting);
			qObj.put("questionKey", questionId+"_"+weighting);
			
			String answerItem = jo.getString("AnswerItem");
			String cnt = jo.getString("CNT");
			
			CoviList labelJa = new CoviList();
			CoviList dataJa = new CoviList();
			CoviList colorJa = new CoviList();
			
			if (qJa.isEmpty()) {
				labelJa.add(answerItem);
				dataJa.add(cnt);
				colorJa.add(generateColor());	// 랜덤 색상
				qObj.put("labels", labelJa);
				qObj.put("datas", dataJa);
				qObj.put("colors", colorJa);
				
				qJa.add(qObj);
			} else {
				int index = getIndexInArr("questionKey", questionId+"_"+weighting, qJa);	// 리스트 포함 여부 확인
				
				if (index == -1) {
					labelJa.add(answerItem);
					dataJa.add(cnt);
					colorJa.add(generateColor());	// 랜덤 색상
					qObj.put("labels", labelJa);
					qObj.put("datas", dataJa);
					qObj.put("colors", colorJa);
					
					qJa.add(qObj);
				} else {
					JSONObject qJo = qJa.getJSONObject(index);
					qJo.getJSONArray("labels").add(answerItem);
					qJo.getJSONArray("datas").add(cnt);
					qJo.getJSONArray("colors").add(generateColor());	// 랜덤 색상
				}
			}
		}
		
		surveyJo.put("userAnswersChart", qJa);

		resultList.put("list", surveyJo);
		
		return resultList;
	}
	
	// 설문 대상 조회
	@Override
	public CoviMap getTargetRespondentList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("user.survey.selectTargetRespondentListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("user.survey.selectTargetRespondentList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SurveyID,TargetCode,RespondentID,DisplayName,PhotoPath,DeptName,RegistDate,EtcOpinion,RegisterCode"));
		resultList.put("page", page);
		
		return resultList;
	}

	// 결과공개 대상 조회
	@Override
	public CoviMap getTargetResultviewList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("user.survey.selectTargetResultviewListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("user.survey.selectTargetResultviewList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ResultViewID,TargetCode,DisplayName,PhotoPath,DeptName,EtcOpinion"));
		resultList.put("page", page);
		
		return resultList;
	}
	
	// 설문관리(관리자) 조회	
	@Override
	public CoviMap getSurveyManageList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("user.survey.selectSurveyManageListCnt", params);
			page = ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			resultList.put("page", page);
		}
		
		CoviList list = coviMapperOne.list("user.survey.selectSurveyManageList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		
		return resultList;
	}
	
	// 설문 통계보기 조회	
	@Override
	public CoviMap getSurveyReportList(CoviMap params) throws Exception {
		JSONObject resultList = new JSONObject();
		JSONObject surveyAnswerJo = new JSONObject();
		
		JSONArray qiJa = generateQuestionItems(params);	// 문항과 보기 데이터 생성
		
		CoviList list = coviMapperOne.list("user.survey.selectSurveyReportList", params);
		CoviList ja = CoviSelectSet.coviSelectJSON(list, "ItemNO,RespondentCode,Weighting,QuestionID,QuestionNO,QuestionType,QuestionTypeNm,JobLevelCode,MultiJobLevelName,DeptCode,MultiDeptName,Subject,MultiDisplayName,CompanyName,AnswerItem");		
		
		JSONObject irJo = new JSONObject();
		JSONArray irJa = new JSONArray();
		String reqType = params.getString("reqType");
		
		/*CoviMap surveyJo = coviMapperOne.select("user.survey.selectSurveyData", params);*/
		
		CoviList Surveylist = (CoviList) coviMapperOne.list("user.survey.selectSurveyData", params);
		CoviList surveyJo = CoviSelectSet.coviSelectJSON(Surveylist, "SurveyID,CompanyCode,Subject,SubjectHtml,Description,IsDescriptionUseEditor,SurveyStartDate,SurveyEndDate,ResultViewStartDate,ResultViewEndDate,QuestionCount,RespondentCount,TargetRespondentType,TargetResultViewType,SurveyType,State,IsImportance,IsAnonymouse,IsGrouping,IsSendTodo,IsSendMail,RegisterCode,RegisterDeptCode,RegistDate,ModifyDate,DeleteDate,ReviewerCode,ReviewerDeptCode,ApproverCode,ApproverDeptCode,ReviewerDate,ApproverDate,CommunityID,respondentCnt");		
		
		if (ja.size() > 0) {
			if (reqType.equals("all")) {
				// irJo.put("companyName", "코비전");	// 수정 예정 //전체일 경우 그룹 이름 표시 안함
				irJo.put("questionRecords", qiJa);
				
				for (int i=0; i<ja.size(); i++) {
					CoviMap jo = ja.getJSONObject(i);
					
					countRecord(jo.getString("QuestionType"), jo.getString("QuestionID"), jo.getInt("QuestionNO"), jo.getInt("ItemNO"), jo.getInt("Weighting"), irJo.getJSONArray("questionRecords"),"");	// 데이터 카운트
				}
				
				irJa.add(irJo);
			} else {
				for (int i=0; i<ja.size(); i++) {
					CoviMap jo = new CoviMap(ja.getJSONObject(i).toString());
					String questionType = jo.getString("QuestionType");
					String userId = jo.getString("RespondentCode");
					String deptCode = jo.getString("DeptCode");
					String jobLevelCode = jo.getString("JobLevelCode");
					String questionId = jo.getString("QuestionID");
					String answerItem = jo.getString("AnswerItem");
					int questionNo = jo.getInt("QuestionNO");
					int itemNo = jo.getInt("ItemNO");
					int weighting = jo.getInt("Weighting");
					
					if (reqType.equals("dept")) {
						irJo.put("deptCode", deptCode);
						irJo.put("deptName", jo.getString("MultiDeptName"));
					} else if (reqType.equals("job")) {
						irJo.put("jobLevelCode", jobLevelCode);
						irJo.put("jobLevelName", jo.getString("MultiJobLevelName"));
					} else if (reqType.equals("user")) {
						irJo.put("userId", userId);
						irJo.put("userNm", jo.getString("MultiDisplayName"));
						
					}
					irJo.put("questionRecords", qiJa);
					
					if (irJa.isEmpty() ) {
						countRecord(questionType, questionId, questionNo, itemNo, weighting, irJo.getJSONArray("questionRecords"),answerItem);	// 데이터 카운트
						
						irJa.add(new CoviMap(irJo.toString()));
					} else {
						int index = -1;
						if (reqType.equals("dept")) {
							index = getIndexInArr("deptCode", deptCode, irJa);	// 리스트 포함 여부 확인
						} else if (reqType.equals("job")) {
							index = getIndexInArr("jobLevelCode", jobLevelCode, irJa);
						} else if (reqType.equals("user")) {
							index = getIndexInArr("userId", userId, irJa);
						}
						
						if (index == -1) {
							countRecord(questionType, questionId, questionNo, itemNo, weighting, irJo.getJSONArray("questionRecords"),answerItem);
							
							irJa.add(irJo);
						} else {
							countRecord(questionType, questionId, questionNo, itemNo, weighting, irJa.getJSONObject(index).getJSONArray("questionRecords"),answerItem);
						}					
					}
				}
			}
		}

		surveyAnswerJo.put("survey", surveyJo);
		surveyAnswerJo.put("questions", qiJa);
		surveyAnswerJo.put("itemRecords", irJa);

		resultList.put("list", surveyAnswerJo);
		CoviMap result = new CoviMap(resultList);
		return result;
	}
	
	@Override
	public CoviMap getCollabSurveyInfo(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("user.survey.selectCollabSurvey", params);
	}
	
	// 데이터 카운트
	private void countRecord(String questionType, String questionId, int questionNo, int itemNo, int weighting, JSONArray recordJa, String answerItem) throws Exception {
		JSONObject itemCntJo = null;
		
		int questionIndex = getIndexInArr("questionId", questionId, recordJa);
		
		if(questionIndex != -1) {
			if (questionType.equals("N")) {  //순위선택
				if(weighting != 0) {
					itemCntJo = recordJa.getJSONObject(questionIndex).getJSONArray("items").getJSONObject(itemNo - 1).getJSONArray("items").getJSONObject(weighting - 1);
					itemCntJo.put("cnt", itemCntJo.getInt("cnt") + 1);
				}else {
					itemCntJo = recordJa.getJSONObject(questionIndex).getJSONArray("items").getJSONObject(itemNo - 1).getJSONArray("items").getJSONObject(weighting);
					itemCntJo.put("cnt", itemCntJo.getInt("cnt"));
				}
			} else {
				itemCntJo = recordJa.getJSONObject(questionIndex).getJSONArray("items").getJSONObject(itemNo - 1);
				itemCntJo.put("cnt", itemCntJo.getInt("cnt") + 1);
			}
			itemCntJo.put("itemNo", itemCntJo.getString("itemNo"));
			if (questionType.equals("D")) {  //주관식일 경우
				itemCntJo.put("answerItem", answerItem);
			}	
		}
	}
	
	// 문항과 보기 데이터 생성
	private JSONArray generateQuestionItems(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.survey.selectSurveyQuestionItemList", params);
		CoviList ja = CoviSelectSet.coviSelectJSON(list, "ItemNO,Item,GroupingNo,QuestionID,QuestionNO,QuestionType,Question,questionTypeNm");
		
		JSONArray qiJa = new JSONArray();
		
		for (int i=0; i<ja.size(); i++) {
			CoviMap jo = ja.getJSONObject(i);
			String groupingNo = jo.getString("GroupingNo");
			String questionId = jo.getString("QuestionID");
			String questionNo = jo.getString("QuestionNO");
			String itemNo = jo.getString("ItemNO");
			String questionType = jo.getString("QuestionType");
			
			CoviMap qObj = new CoviMap();
			qObj.put("groupingNo", groupingNo);
			qObj.put("questionId", questionId);
			qObj.put("questionNo", questionNo);
			qObj.put("question", jo.getString("Question"));
			qObj.put("questionType", questionType);
			qObj.put("questionTypeNm", jo.getString("questionTypeNm"));
			
			CoviMap itemCntJo = new CoviMap();
			itemCntJo.put("itemNo", itemNo);
			itemCntJo.put("itemName", jo.getString("Item"));
			itemCntJo.put("cnt", 0);

			JSONArray itemJa = new JSONArray();
			
			if (qiJa.isEmpty()) {
				itemJa.add(itemCntJo);
				qObj.put("items", itemJa);
				
				qiJa.add(qObj);
			} else {
				int index = getIndexInArr("questionId", questionId, qiJa);	// 리스트 포함 여부 확인
				
				if (index == -1) {
					if (getIndexInArr("itemNo", itemNo, itemJa) == -1) {
						itemJa.add(itemCntJo);
						qObj.put("items", itemJa);
						qiJa.add(qObj);
					}
				} else {
					JSONObject qJo = qiJa.getJSONObject(index);
					if (getIndexInArr("itemNo", itemNo, qJo.getJSONArray("items")) == -1) {
						qJo.getJSONArray("items").add(itemCntJo);
					}
				}
			}
		}
		
		for (int t=0; t<qiJa.size(); t++) {
			JSONObject jo = qiJa.getJSONObject(t);
			JSONArray itemsJa = jo.getJSONArray("items");
			int itemsSize = itemsJa.size();
			
			jo.put("itemLen", itemsSize);
			int itemLen = 0;
			//순위 선택인 경우
			if (jo.getString("questionType").equals("N")) {
				CoviList copyItemJa= new CoviList(itemsJa.toString());
				
				for (int j=0; j<itemsSize; j++) {
					itemLen += copyItemJa.size();
					
					JSONObject itemJo = itemsJa.getJSONObject(j);
					itemJo.remove("cnt");
					itemJo.put("items",copyItemJa);
				}
				
				jo.put("itemLen", itemLen);
			}
		}
		
		return qiJa;
	}	
	
	// 랜덤 색상
	private String generateColor() throws Exception {
		SecureRandom rnd = new SecureRandom();;
	    return String.format("#%06x", rnd.nextInt(256*256*256));
		
		
	}
	
	// 설문 데이터 jsonobject 생성
	private CoviMap makeSurveyJsonobject(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.survey.selectSurveyQuestionItemList", params);
		CoviList listRespon = coviMapperOne.list("user.survey.selectSurveyQuestionRespondentTarget", params);
		CoviList listResult = coviMapperOne.list("user.survey.selectSurveyQuestionResultviewTarget", params);

		CoviList ja = coviSurveySelectJSON(list, "ItemNO,Item,NextQuestionNO,FileID,QuestionType,QuestionNO,GroupingNo,GroupName,Paragraph,Question,Description,IsRequired,RequiredInfo,IsEtc,NextGroupingNo,SurveyID,CompanyCode,Subject,SubjectHtml,SDescription,IsDescriptionUseEditor,SurveyStartDate,SurveyEndDate,ResultViewStartDate,ResultViewEndDate,TargetRespondentType,TargetResultViewType,SurveyType,State,IsImportance,IsAnonymouse,IsGrouping,IsSendTodo,IsSendMail,RegisterCode,ReviewerCode,ApproverCode,GroupDivOptions,ItemDivOptions,ItemID,QuestionID,GroupMoveOptions,NextDefaultQuestionNO,updateFileIds,reviewerCodeText,approverCodeText");
		CoviMap surveyJo = copyJsonObject(ja.getJSONObject(0), "S");	// 설문
		
		surveyJo.put("respondentTarget", listRespon);
		surveyJo.put("resultviewTarget", listResult);

/*		StringUtil func = new StringUtil();

		CoviList tempRespondentTarget = new CoviList();
		if (surveyJo.has("respondentTarget") && !func.f_NullCheck(surveyJo.getString("respondentTarget")).equals("")) {
			String [] respondentTargetArr = surveyJo.getString("respondentTarget").split(",");
			
			if (respondentTargetArr.length > 0) {		// 설문대상
				for (String str : respondentTargetArr) {
					CoviMap jo = new CoviMap();
					jo.put("type", str.split(";")[0]);
					jo.put("code", str.split(";")[1]);
					jo.put("label", str.split(";")[2]);
					
					tempRespondentTarget.add(jo);
				}
			}
		}
		surveyJo.put("respondentTarget", tempRespondentTarget);
			
		CoviList tempResultviewTarget = new CoviList();
		if (surveyJo.has("resultviewTarget") && !func.f_NullCheck(surveyJo.getString("resultviewTarget")).equals("")) {
			
			String [] resultviewTargetArr = surveyJo.getString("resultviewTarget").split(",");

			if (resultviewTargetArr.length > 0) {		// 결과공개대상
				for (String str : resultviewTargetArr) {
					CoviMap jo = new CoviMap();
					jo.put("type", str.split(";")[0]);
					jo.put("code", str.split(";")[1]);
					jo.put("label", str.split(";")[2]);
					
					tempResultviewTarget.add(jo);
				}
			}
		}
		surveyJo.put("resultviewTarget", tempResultviewTarget);*/		
		
		CoviList questionJa = new CoviList();
		
		for (int i=0; i<ja.size(); i++) {
			CoviMap jo = ja.getJSONObject(i);
			CoviMap qObj = copyJsonObject(jo, "Q");	// 문항 
			
			if (questionJa.isEmpty()) {
				CoviList itemJa = new CoviList();
				itemJa.add(copyJsonObject(jo, "I"));	// 보기
				qObj.put("items", itemJa);
				
				questionJa.add(qObj);
			} else {
				// 문항 리스트 포함 여부 확인
				int index = getIndexQuestionInArr(qObj.getString("groupingNo"), qObj.getString("questionNO"), questionJa);
				if (index == -1) {
					CoviList itemJa = new CoviList();
					itemJa.add(copyJsonObject(jo, "I"));	// 보기
					qObj.put("items", itemJa);
					
					questionJa.add(qObj);
				} else {
					(questionJa.getJSONObject(index)).getJSONArray("items").add(copyJsonObject(jo, "I"));	// 보기
				}
			}
		}
		
		surveyJo.put("questions", questionJa);

	    return surveyJo;
	}
	
	// 다국어 유저 정보 세팅
/*	private void setUserInfo(CoviMap paramMap) throws Exception {
		String registerCode = paramMap.getString("registerCode");	// 등록자
		String reviewerCode = paramMap.getString("reviewerCode");	// 검토자
		String approverCode = paramMap.getString("approverCode");	// 승인자
		String respondentCode = paramMap.getString("respondentCode");	// 응답자
		
		List<String> userList = new ArrayList<>();
		if (!registerCode.isEmpty()) userList.add(registerCode);
		if (!reviewerCode.isEmpty()) userList.add(reviewerCode);
		if (!approverCode.isEmpty()) userList.add(approverCode);
		if (!respondentCode.isEmpty()) userList.add(respondentCode);
		
		CoviMap param = new CoviMap();
		param.put("userArr", userList);
		
		CoviList list = coviMapperOne.list("user.survey.selectUserInfoForMultiLanguage", param);
		CoviList ja = CoviSelectSet.coviSelectJSON(list, "UserCode,CompanyCode,MultiJobLevelName,MultiJobPositionName,MultiJobTitleName,MultiDeptName,MultiDisplayName");
		
		int size = ja.size();
		for (int i=0; i<size; i++) {
			CoviMap jo = ja.getJSONObject(i);
			String userCode = jo.getString("UserCode");
			String multiDisplayName = jo.getString("MultiDisplayName");
			String multiJobLevelName = jo.getString("MultiJobLevelName");
			String multiJobPositionName = jo.getString("MultiJobPositionName");
			String multiJobTitleName = jo.getString("MultiJobTitleName");
			String multiDeptName = jo.getString("MultiDeptName");
			
			if (registerCode.equals(userCode)) {
				paramMap.put("companyCode", jo.getString("CompanyCode"));
				paramMap.put("registerName", multiDisplayName);
				paramMap.put("registerLevel", multiJobLevelName);
				paramMap.put("registerPosition", multiJobPositionName);
				paramMap.put("registerTitle", multiJobTitleName);
				paramMap.put("registerDept", multiDeptName);
			}
			if (reviewerCode.equals(userCode)) {
				paramMap.put("reviewerName", multiDisplayName);
				paramMap.put("reviewerLevel", multiJobLevelName);
				paramMap.put("reviewerPosition", multiJobPositionName);
				paramMap.put("reviewerTitle", multiJobTitleName);
				paramMap.put("reviewerDept", multiDeptName);
			}
			if (approverCode.equals(userCode)) {
				paramMap.put("approverName", multiDisplayName);
				paramMap.put("approverLevel", multiJobLevelName);
				paramMap.put("approverPosition", multiJobPositionName);
				paramMap.put("approverTitle", multiJobTitleName);
				paramMap.put("approverDept", multiDeptName);
			}
			if (respondentCode.equals(userCode)) {
				paramMap.put("respondentName", multiDisplayName);
				paramMap.put("respondentLevel", multiJobLevelName);
				paramMap.put("respondentPosition", multiJobPositionName);
				paramMap.put("respondentTitle", multiJobTitleName);
				paramMap.put("respondentDept", multiDeptName);
			}			
		}
	}*/
	
	// 문항 리스트 포함 여부 확인
	private int getIndexQuestionInArr(String gNo, String qNo, CoviList qJa) throws Exception {
		int index = -1;
		
		for (int i=0; i<qJa.size(); i++) {
			CoviMap qJaObj = qJa.getJSONObject(i);
			if (gNo.equals(qJaObj.get("groupingNo")) && qNo.equals(qJaObj.get("questionNO"))) {
				index = i;
				
				break;
			}
		}
		
		return index;
	}
	
	// 리스트 포함 여부 확인
	private int getIndexInArr(String key, String id, JSONArray ja) throws Exception {
		int index = -1;
		
		for (int i=0; i<ja.size(); i++) {
			JSONObject uJaObj = ja.getJSONObject(i);
			
			if (id.equals(uJaObj.getString(key))) {
				index = i;
				
				break;
			}
		}
		
		return index;
	}
	
	// 필요한 데이터만 생성
	private CoviMap copyJsonObject(CoviMap obj, String type) throws Exception {
	    CoviMap rtnJo = new CoviMap();
		final String[] diffS = {"SurveyID", "IsGrouping", "Subject", "IsImportance", "SubjectHtml", "IsAnonymouse", "IsSendTodo", "IsSendMail", "SurveyType", "SDescription", "IsDescriptionUseEditor", "SurveyStartDate", "SurveyEndDate", "ResultViewStartDate", "ResultViewEndDate", "State", "RegisterCode", "respondentTarget", "resultviewTarget", "reviewerCodeText", "approverCodeText", "TargetRespondentType"};
	    final String[] diffQ = {"Paragraph", "Question", "Description", "QuestionNO", "QuestionType", "IsRequired", "RequiredInfo", "IsEtc", "GroupingNo", "GroupName", "NextGroupingNo", "GroupDivOptions", "QuestionID", "GroupMoveOptions", "NextDefaultQuestionNO"};
	    final String[] diffI = {"ItemNO", "Item", "NextQuestionNO", "ItemDivOptions", "ItemID", "updateFileIds"};
	    
	    for (Iterator<String> itr = obj.keys(); itr.hasNext();) {
	        String key = itr.next();
	        String value = obj.getString(key);

	        if (type.equals("S") && Arrays.asList(diffS).contains(key)) {
	        	if (key.equals("SDescription")) {
	        		rtnJo.put(WordUtils.uncapitalize(key.substring(1, key.length())), value);
	        	} else if (key.equals("SubjectHtml")) {
	        		String subjectHtml = StringUtils.substringBetween(value, "<b>", "</b>");
	        		
	        		if (subjectHtml == null || subjectHtml.isEmpty()) {
	        			rtnJo.put("isSubjectBold", "N");
	        		} else {
	        			rtnJo.put("isSubjectBold", "Y");
	        		}
	        		
	        		rtnJo.put("subjectColor", StringUtils.substringBetween(value, "<font background=\"", "\""));
	        		rtnJo.put(WordUtils.uncapitalize(key), value);
	        	} else {
	        		rtnJo.put(WordUtils.uncapitalize(key), value);
	        	}
	        } else if (type.equals("Q") && Arrays.asList(diffQ).contains(key)) {
	        	rtnJo.put(WordUtils.uncapitalize(key), value);
	        } else if (type.equals("I") && Arrays.asList(diffI).contains(key)) {
	        	rtnJo.put(WordUtils.uncapitalize(key), value);
	        }
	    }

	    return rtnJo;
	}
	
	// VO를 CoviMap으로 변환
	private CoviMap convertVOToCoviMap(Object obj) throws Exception {
		Field[] fields = obj.getClass().getDeclaredFields();
		int len = fields.length;
		CoviMap rtnMap = new CoviMap();

		for (int i=0 ; i<len;i++) {
			fields[i].setAccessible(true);
			rtnMap.put(fields[i].getName(), fields[i].get(obj));
		}

		return rtnMap;
	}
	
	// 설문 읽음 업데이트
	@Override
	public int updateSurveyTargetRead(CoviMap params) throws Exception {
		params.put("userId", SessionHelper.getSession("USERID"));
		
		return coviMapperOne.update("user.survey.updateSurveyTargetRead", params);
	}
	
	// 웹파트 설문 데이터 조회
	@Override
	public CoviMap getWebpartSurveyList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("webpart.survey.selectWebpartSurveyList", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ItemID,Item,QuestionID,SurveyID,Subject,Description,RegistDate,respondentYn,totCnt,rate"));
		
		return resultList;
	}	
	
	private void sendMessage(CoviMap surveyParam , String type) throws Exception{
			String cu_id = (surveyParam.getString("communityID") == null) ? "0" : surveyParam.getString("communityID");
			String surveyId = surveyParam.getString("SurveyID");
			
			CoviMap notiParams = new CoviMap();
			switch(type){
			case "ApprovalRequest": //승인 or 검토 요청
				notiParams.put("SenderCode", surveyParam.getString("registerCode"));
				notiParams.put("RegistererCode", surveyParam.getString("registerCode"));
				notiParams.put("ReceiversCode", surveyParam.getString("state").equalsIgnoreCase("B") ? surveyParam.getString("reviewerCode") : surveyParam.getString("approverCode"));
				notiParams.put("MessagingSubject", surveyParam.getString("subject"));
				notiParams.put("GotoURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=reqApproval&communityId=0");
				notiParams.put("PopupURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=reqApproval&communityId=0");
				notiParams.put("MobileURL", "/groupware/mobile/survey/list.do?surveytype=reqApproval");
				notiParams.put("ReceiverText",  surveyParam.getString("subject"));
				notiParams.put("ServiceType", "Survey");
				notiParams.put("MsgType", "ApprovalRequest_Survey");
				notiParams.put("DomainID", surveyParam.getString("domainID"));
				break;
			case "NotAttendance": //미참여자
				notiParams.put("SenderCode", surveyParam.getString("registerCode"));
				notiParams.put("RegistererCode", surveyParam.getString("registerCode"));
				notiParams.put("ReceiversCode", surveyParam.getString("targetCode"));
				notiParams.put("MessagingSubject", surveyParam.getString("subject"));
				if (!"".equals(cu_id) && !"0".equals(cu_id)) {		// 커뮤니티에서 등록한 설문인 경우에 url 변경 처리
					notiParams.put("GotoURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+
						String.format("/groupware/layout/survey_Survey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=join&listType=proceed&surveyId=%s&communityId=%s&CSMU=C", surveyId, cu_id));
					notiParams.put("PopupURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+
							String.format("/groupware/layout/survey_Survey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=join&listType=proceed&surveyId=%s&communityId=%s&CSMU=C", surveyId, cu_id));
					notiParams.put("MobileURL", String.format("/groupware/mobile/survey/list.do?cuid=%s", cu_id));
				}
				else {
					notiParams.put("GotoURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=proceed&communityId=0");
					notiParams.put("PopupURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=proceed&communityId=0");
					notiParams.put("MobileURL", "/groupware/mobile/survey/list.do?surveytype=proceed");
				}
				notiParams.put("ReceiverText",  surveyParam.getString("subject"));
				notiParams.put("ServiceType", "Survey");
				notiParams.put("MsgType", "RequestAttendant_Survey");
				notiParams.put("DomainID", surveyParam.getString("domainID"));
				break;
			case "RequestAttendant": //참여요청
				notiParams.put("SenderCode", surveyParam.getString("registerCode"));
				notiParams.put("RegistererCode", surveyParam.getString("registerCode"));
				notiParams.put("ReceiversCode", surveyTargetUserCode(surveyParam));
				notiParams.put("MessageID", surveyParam.getString("surveyID"));
				notiParams.put("MessagingSubject", surveyParam.getString("subject"));
				if (!"".equals(cu_id) && !"0".equals(cu_id)) {		// 커뮤니티에서 등록한 설문인 경우에 url 변경 처리
					notiParams.put("GotoURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+
						String.format("/groupware/layout/survey_Survey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=join&listType=proceed&surveyId=%s&communityId=%s&CSMU=C", surveyId, cu_id));
					notiParams.put("PopupURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+
							String.format("/groupware/layout/survey_Survey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=join&listType=proceed&surveyId=%s&communityId=%s&CSMU=C", surveyId, cu_id));
					notiParams.put("MobileURL", String.format("/groupware/mobile/survey/list.do?cuid=%s", cu_id));
				}
				else {
					notiParams.put("GotoURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=proceed&communityId=0");
					notiParams.put("PopupURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=proceed&communityId=0");
					notiParams.put("MobileURL", "/groupware/mobile/survey/list.do?surveytype=proceed");
				}
				notiParams.put("ReceiverText",  surveyParam.getString("subject"));
				notiParams.put("ServiceType", "Survey");
				notiParams.put("MsgType", "RequestAttendant_Survey");
				notiParams.put("DomainID", surveyParam.getString("domainID"));
				break;
			case "ApprovalCompleted": //승인완료
				notiParams.put("SenderCode", surveyParam.getString("senderCode"));
				notiParams.put("RegistererCode", surveyParam.getString("senderCode"));
				notiParams.put("ReceiversCode", surveyParam.getString("registerCode"));
				notiParams.put("MessagingSubject", surveyParam.getString("subject"));
				notiParams.put("GotoURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=mySurvey&communityId=0");
				notiParams.put("PopupURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=mySurvey&communityId=0");
				notiParams.put("MobileURL", "/groupware/mobile/survey/list.do?surveytype=mySurvey");
				notiParams.put("ReceiverText",  surveyParam.getString("subject"));
				notiParams.put("ServiceType", "Survey");
				notiParams.put("MsgType", "ApprovalCompleted_Survey");
				notiParams.put("DomainID", surveyParam.getString("domainID"));
				break;
			case "ApprovalCancel": //승인거부
				notiParams.put("SenderCode", surveyParam.getString("senderCode"));
				notiParams.put("RegistererCode", surveyParam.getString("senderCode"));
				notiParams.put("ReceiversCode", surveyParam.getString("registerCode"));
				notiParams.put("MessagingSubject", surveyParam.getString("subject"));
				notiParams.put("GotoURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=mySurvey&communityId=0");
				notiParams.put("PopupURL",  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=mySurvey&communityId=0");
				notiParams.put("MobileURL", "/groupware/mobile/survey/list.do?surveytype=mySurvey");
				notiParams.put("ReceiverText",  surveyParam.getString("subject"));
				notiParams.put("ServiceType", "Survey");
				notiParams.put("MsgType", "ApprovalCancel_Survey");
				notiParams.put("DomainID", surveyParam.getString("domainID"));
				break;
			default :
				break;
			}
			
			if(!"".equals(cu_id) && !"0".equals(cu_id)) {
				notiParams.put("ServiceType", "CommunitySurvey");
			}
			
			sendNotificationMessage(notiParams);
	}
	
	@Override
	public void sendNotAttendanceAlarm(CoviMap param) throws Exception {
		CoviMap surveyInfo = coviMapperOne.select("user.survey.selectSurveyData", param);
		
		if(param.getString("targetCode").equals("all")){
			String allCodes = "";
			
			param.put("targetType", "notAttendance");
			CoviList allList = coviMapperOne.list("user.survey.selectAttendanceCodes", param);
			StringBuffer buf = new StringBuffer();
			for(Object target: allList) {
				buf.append(((CoviMap)target).getString("TargetCode")).append(";");
			}
			allCodes = buf.toString();
			param.put("targetCode", allCodes);
		}
				
		CoviMap notiParams = new CoviMap();
		notiParams.put("subject", surveyInfo.getString("Subject"));
		notiParams.put("targetCode", param.getString("targetCode"));
		notiParams.put("registerCode", surveyInfo.getString("RegisterCode"));
		notiParams.put("domainID", surveyInfo.getString("DomainID"));
		
		sendMessage(notiParams,"NotAttendance");
		
	}
	
	public void sendNotificationMessage(CoviMap params) throws Exception{
		String strServiceType = params.getString("ServiceType");
        String strObjectType = params.getString("ObjectType");
        String strObjectID = params.getString("ObjectID");
        String strMsgType = params.getString("MsgType");
        String strMessageID = params.getString("MessageID");
        String strSubMsgID = params.getString("SubMsgID");
        String strMediaType = params.getString("MediaType");
        String strIsUse = params.getString("IsUse");
        String strIsDelay = params.getString("IsDelay");
        String strApprovalState = params.getString("ApprovalState");
        String strSenderCode = params.getString("SenderCode");
        String strReservedDate = params.getString("ReservedDate");
        String strXSLPath = params.getString("XSLPath");
        String strWidth = params.getString("Width");
        String strHeight = params.getString("Height");
        String strPopupURL = params.getString("PopupURL");
        String strGotoURL = params.getString("GotoURL");
        String strMobileURL = params.getString("MobileURL");
        String strOpenType = params.getString("OpenType");
        String strMessagingSubject = params.getString("MessagingSubject");
        String strMessageContext = params.getString("MessageContext");
        String strReceiverText = params.getString("ReceiverText");
        String strReservedStr1 = params.getString("ReservedStr1");
        String strReservedStr2 = params.getString("ReservedStr2");
        String strReservedStr3 = params.getString("ReservedStr3");
        String strReservedStr4 = params.getString("ReservedStr4");
        String strReservedInt1 = params.getString("ReservedInt1");
        String strReservedInt2 = params.getString("ReservedInt2");
        String strRegistererCode = params.getString("RegistererCode");
        String strReceiversCode = params.getString("ReceiversCode");
        String strDomainID = params.getString("DomainID");
        
        // 값이 비어있을경우 NULL 값으로 전달
        strServiceType = strServiceType == null ? null : (strServiceType.isEmpty() ? null : strServiceType);
        strObjectType = strObjectType == null ? null : (strObjectType.isEmpty() ? null : strObjectType);
        strObjectID = strObjectID == null ? null : (strObjectID.isEmpty() ? null : strObjectID);
        strMsgType = strMsgType == null ? null : (strMsgType.isEmpty() ? null : strMsgType);
        strMessageID = strMessageID == null ? null : (strMessageID.isEmpty() ? null : strMessageID);
        strSubMsgID = strSubMsgID == null ? null : (strSubMsgID.isEmpty() ? null : strSubMsgID);
        strMediaType = strMediaType == null ? null : (strMediaType.isEmpty() ? null : strMediaType);
        strIsUse = strIsUse == null ? "Y" : (strIsUse.isEmpty() ? "Y" : strIsUse);
        strIsDelay = strIsDelay == null ? "N" : (strIsDelay.isEmpty() ? "N" : strIsDelay);
        strApprovalState = strApprovalState == null ? "P" : (strApprovalState.isEmpty() ? "P" : strApprovalState);
        strSenderCode = strSenderCode == null ? null : (strSenderCode.isEmpty() ? null : strSenderCode);
        strReservedDate = strReservedDate == null ? null : (strReservedDate.isEmpty() ? null : strReservedDate);
        strXSLPath = strXSLPath == null ? null : (strXSLPath.isEmpty() ? null : strXSLPath);
        strWidth = strWidth == null ? null : (strWidth.isEmpty() ? null : strWidth);
        strHeight = strHeight == null ? null : (strHeight.isEmpty() ? null : strHeight);
        strPopupURL = strPopupURL == null ? null : (strPopupURL.isEmpty() ? null : strPopupURL);
        strGotoURL = strGotoURL == null ? null : (strGotoURL.isEmpty() ? null : strGotoURL);
        strMobileURL = strMobileURL == null ? null : (strMobileURL.isEmpty() ? null : strMobileURL);
        strOpenType = strOpenType == null ? null : (strOpenType.isEmpty() ? null : strOpenType);
        strMessagingSubject = strMessagingSubject == null ? null : (strMessagingSubject.isEmpty() ? null : strMessagingSubject);
        strMessageContext = strMessageContext == null ? null : (strMessageContext.isEmpty() ? null : strMessageContext);
        strReceiverText = strReceiverText == null ? null : (strReceiverText.isEmpty() ? null : strReceiverText);
        strReservedStr1 = strReservedStr1 == null ? null : (strReservedStr1.isEmpty() ? null : strReservedStr1);
        strReservedStr2 = strReservedStr2 == null ? null : (strReservedStr2.isEmpty() ? null : strReservedStr2);
        strReservedStr3 = strReservedStr3 == null ? null : (strReservedStr3.isEmpty() ? null : strReservedStr3);
        strReservedStr4 = strReservedStr4 == null ? null : (strReservedStr4.isEmpty() ? null : strReservedStr4);
        strReservedInt1 = strReservedInt1 == null ? null : (strReservedInt1.isEmpty() ? null : strReservedInt1);
        strReservedInt2 = strReservedInt2 == null ? null : (strReservedInt2.isEmpty() ? null : strReservedInt2);
        strRegistererCode = strRegistererCode == null ? null : (strRegistererCode.isEmpty() ? null : strRegistererCode);
        strReceiversCode = strReceiversCode == null ? null : (strReceiversCode.isEmpty() ? null : strReceiversCode);
        strDomainID = strDomainID == null ? null : (strDomainID.isEmpty() ? null : strDomainID);
		
		params.put("ServiceType", strServiceType);
        params.put("ObjectType", strObjectType);
        params.put("ObjectID", strObjectID);
        params.put("MsgType", strMsgType);
        params.put("MessageID", strMessageID);
        params.put("SubMsgID", strSubMsgID);
        params.put("MediaType", strMediaType);
        params.put("IsUse", strIsUse);
        params.put("IsDelay", strIsDelay);
        params.put("ApprovalState", strApprovalState);
        params.put("SenderCode", strSenderCode);
        params.put("ReservedDate", strReservedDate);
        params.put("XSLPath", strXSLPath);
        params.put("Width", strWidth);
        params.put("Height", strHeight);
        params.put("PopupURL", strPopupURL);
        params.put("GotoURL", strGotoURL);
        params.put("MobileURL", strMobileURL);
        params.put("OpenType", strOpenType);
        params.put("MessagingSubject", strMessagingSubject);
        params.put("MessageContext", strMessageContext);
        params.put("ReceiverText", strReceiverText);
        params.put("ReservedStr1", strReservedStr1);
        params.put("ReservedStr2", strReservedStr2);
        params.put("ReservedStr3", strReservedStr3);
        params.put("ReservedStr4", strReservedStr4);
        params.put("ReservedInt1", strReservedInt1);
        params.put("ReservedInt2", strReservedInt2);
        params.put("RegistererCode", strRegistererCode);
        params.put("ReceiversCode", strReceiversCode);
        params.put("DomainID", strDomainID);
		
        messageSvc.insertMessagingData(params);
	}
	
	// 엑셀저장 : 설문자료 저장
	@Override
	public CoviMap selectSurveyRawDataExcelList(CoviMap params) throws Exception {
		CoviMap mainObj = makeSurveyJsonobject(params);											// 설문 데이터 jsonobject 생성
		CoviMap resultList = new CoviMap();
		CoviMap respondentsObj = new CoviMap();
		CoviList respondentsArr = new CoviList();
		
		CoviList questionArr = mainObj.getJSONArray("questions");
		
		if(mainObj.get("description") != null && !mainObj.getString("description").equals("")) { //엑셀 저장 시 설명 html tags 모두 제거
			mainObj.put("description", mainObj.getString("description").replaceAll("<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>", ""));
		}
		
		CoviList list = coviMapperOne.list("user.survey.selectSurveyRawDataExcelList", params);
		CoviList resArr = CoviSelectSet.coviSelectJSON(list, "SurveyID,QuestionID,Question,QuestionType,AnswerItemID,AnswerItem,RespondentCode,RespondentDeptCode,RespondentName,RespondentDeptName");
		CoviMap surveyInfo = coviMapperOne.select("user.survey.selectSurveyData", params);
		String tempCode = "";
		for(int i=0; i<resArr.size(); i++) {
			CoviMap resObj1 = resArr.getJSONObject(i);
			CoviMap respondentRowObj = new CoviMap();
			
			// 사용자별 데이터
			if(!tempCode.equals(resObj1.getString("RespondentCode"))) {
				respondentRowObj.put("RespondentCode", resObj1.getString("RespondentCode"));					// 답변자 코드
				respondentRowObj.put("RespondentDeptCode", resObj1.getString("RespondentDeptCode"));			// 답변자 부서코드
				
				if (!surveyInfo.get("IsAnonymouse").equals("Y")){	//익명인 경우 보이지 않기
					respondentRowObj.put("RespondentName", resObj1.getString("RespondentName"));					// 답변자 이름
					respondentRowObj.put("RespondentDeptName", resObj1.getString("RespondentDeptName"));			// 답변자 부서명
				}	
				

				
				// 문항 및 답변
				List<String> answerQuestion = new ArrayList<String>();
				CoviList answersArr = new CoviList();
				for(int k=0; k<resArr.size(); k++) {
					CoviMap resObj2 = resArr.getJSONObject(k);
					
					if(resObj2.getString("RespondentCode").equals(respondentRowObj.getString("RespondentCode"))) {
						answerQuestion.add(resObj2.getString("QuestionID"));
						
						CoviMap questionObj = new CoviMap();
						questionObj.put("QuestionID", resObj2.getString("QuestionID"));						// 질문ID
						questionObj.put("AnswerItemID", resObj2.getString("AnswerItemID"));					// 답변ID (,구분) ex) 112, 113
						
						//questionObj.put("Question", resObj2.getString("Question"));						// 질문
						//questionObj.put("QuestionType", resObj2.getString("QuestionType"));				// 문항유형(S:객관식, D:주관식, M:복수응답, N:순위선택)
						questionObj.put("AnswerItem", resObj2.getString("AnswerItem"));						// 답변
						answersArr.add(questionObj);
					}
				}				
				
				//답변 안한 항목 체크
				if(answersArr.size() < questionArr.size()) {
					for(int k=0; k<questionArr.size(); k++) {
						CoviMap questionObj = questionArr.getJSONObject(k);
						
						if(!answerQuestion.contains(questionObj.getString("questionID"))){
							CoviMap tempObj = new CoviMap();
							tempObj.put("QuestionID", questionObj.getString("questionID"));						// 질문ID
							tempObj.put("AnswerItemID", "");					// 답변ID (,구분) ex) 112, 113
							tempObj.put("AnswerItem", "");						// 답변
							answersArr.add(k, tempObj);
						}
					}
				}
				
				
				respondentRowObj.put("answers", answersArr);
				
				
				
				respondentsArr.add(respondentRowObj);
				tempCode = resObj1.getString("RespondentCode");
			}
		}
		
		respondentsObj.put("questions", questionArr);
		respondentsObj.put("respondents", respondentsArr);
		resultList.put("list", respondentsObj);
		
		return resultList;
	}
	
	// 엑셀저장 : 설문통계 저장
	@Override
	public CoviMap selectSurveyStatisticsExcelList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap mainObj = makeSurveyJsonobject(params);	// 설문 데이터 jsonobject 생성
		mainObj.remove("respondentTarget");
		mainObj.remove("resultviewTarget");
		
		if(mainObj.get("description") != null && !mainObj.getString("description").equals("")) { //엑셀 저장 시 설명 html tags 모두 제거
			mainObj.put("description", mainObj.getString("description").replaceAll("<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>", ""));
		}
		
		CoviList list = coviMapperOne.list("user.survey.selectSurveyStatisticsExcelList", params);
		CoviList resArr = CoviSelectSet.coviSelectJSON(list, "SurveyID,QuestionID,Weighting,AnswerItemID,AnswerItem,RespondentCode,AnswerCnt,TotalUserCnt,AnswerResult");
		
		// 1. 질문목록
		CoviList mainQuestionsArr = CoviList.fromObject(mainObj.get("questions"));
		for(int i=0; i<mainQuestionsArr.size(); i++) {
			CoviMap mainQuestionObj = mainQuestionsArr.getJSONObject(i);
			CoviList mainItemsArr = mainQuestionObj.getJSONArray("items");
			if (mainQuestionObj.getString("questionType").equals("D"))	//주관식
			{
				CoviMap mainItemObj = mainItemsArr.getJSONObject(0);
				int j=0;
				// 결과값 대입
				for(int k=0; k<resArr.size(); k++) {
					CoviMap resObj = resArr.getJSONObject(k);

					if(mainQuestionObj.getString("questionID").equals(resObj.getString("QuestionID"))) {
						if (j>0){
							CoviMap itemObj = new CoviMap();
							itemObj.put("answerResult", resObj.getString("AnswerResult"));
							mainItemsArr.add(itemObj);
						}
						else{
							mainItemObj.put("answerResult", resObj.getString("AnswerResult"));
						}
						j++;
					}
				}
			}
			else if (mainQuestionObj.getString("questionType").equals("N")){	//순위이면
				// 2. 질문 선택항목
				int rnkLen = mainItemsArr.size();
				for (int l=0; l <rnkLen; l++){
					for(int j=0; j<rnkLen; j++) {	
						CoviMap mainItemObj = mainItemsArr.getJSONObject(j);
						
						CoviMap subItemObj = new CoviMap();
						subItemObj.put("itemNO", mainItemObj.get("itemNO"));
						subItemObj.put("item", mainItemObj.get("item"));
						subItemObj.put("nextQuestionNO", mainItemObj.get("nextQuestionNO"));
						subItemObj.put("itemDivOptions", mainItemObj.get("itemDivOptions"));
						subItemObj.put("itemID", mainItemObj.get("itemID"));
						subItemObj.put("updateFileIds", mainItemObj.get("updateFileIds"));
						subItemObj.put("weighting", String.valueOf(l+1));
						
						mainItemsArr.add(subItemObj);
					}
				}
				
				for (int l=0; l <rnkLen; l++){
					mainItemsArr.remove(0);
				}

				for(int j=0; j<mainItemsArr.size(); j++) {
					CoviMap mainItemObj = mainItemsArr.getJSONObject(j);
					// 결과값 대입
					for(int k=0; k<resArr.size(); k++) {
						CoviMap resObj = resArr.getJSONObject(k);
	
						if(mainQuestionObj.getString("questionID").equals(resObj.getString("QuestionID")) 
						&& mainItemObj.getString("itemID").equals(resObj.getString("AnswerItemID"))
							&& mainItemObj.getString("weighting").equals(resObj.getString("Weighting"))) {
							mainItemObj.put("answerResult", resObj.getString("AnswerResult"));
						}
					}
				}
			}	
			else{
				// 2. 질문 선택항목
				for(int j=0; j<mainItemsArr.size(); j++) {
					CoviMap mainItemObj = mainItemsArr.getJSONObject(j);
	
					// 결과값 대입
					for(int k=0; k<resArr.size(); k++) {
						CoviMap resObj = resArr.getJSONObject(k);
	
						if(mainQuestionObj.getString("questionID").equals(resObj.getString("QuestionID")) 
						&& mainItemObj.getString("itemID").equals(resObj.getString("AnswerItemID"))) {
							mainItemObj.put("answerResult", resObj.getString("AnswerResult"));
						}
					}
				}
			}	
		}

		String approvalText = mainObj != null && mainObj.getString("approverCodeText") != null && mainObj.getString("approverCodeText").indexOf(";") > -1 ? mainObj.getString("approverCodeText").split(";")[1] : "";		// 승인자

		mainObj.put("questions", mainQuestionsArr);
		mainObj.put("approverText", approvalText);
		
		resultList.put("list", mainObj);

		return resultList;
	}
	
	@Override
	public CoviMap selectSurveyInfoData(CoviMap param) {
		CoviMap surveyData = new CoviMap();
		surveyData.addAll(coviMapperOne.select("user.survey.selectSurveyData", param));
		
		return surveyData;
	}
	
	// 등록시 파일첨부에 사용
	public void insertSurveySysFile(CoviMap params, List<MultipartFile> mf) throws Exception{
		String uploadPath = params.getString("ServiceType") + File.separator;
		String orgPath = params.getString("ServiceType") + File.separator;

		CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
		CoviList fileObj = fileSvc.moveToService(fileInfos, mf, orgPath, uploadPath, params.getString("ServiceType"), params.getString("ObjectID"), params.getString("ObjectType"), params.getString("MessageID"), "0");
	}
	
	// 수정시 파일정보 수정
	public void updateSurveySysFile(CoviMap params, List<MultipartFile> mf) throws Exception{
		// 파일을 모두 삭제후 수정누를 경우 삭제처리
		if("0".equals(params.get("fileCnt"))){
			fileSvc.deleteFileDbAll(params);
		} else {
			String uploadPath = params.getString("ServiceType") + File.separator;
			CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
			
			CoviMap filesParams = new CoviMap();
			CoviList fileObj = fileSvc.uploadToBack(fileInfos, mf, uploadPath , params.getString("ServiceType"), params.getString("ObjectID"), params.getString("ObjectType"), params.getString("MessageID"), "0");
		}
	}
	
	// 설문 결과 삭제
	@Override
	public int deleteQuestionItemAnswer(CoviMap params) throws Exception {
		return coviMapperOne.delete("user.survey.deleteQuestionItemAnswer", params);
	}
	
	// 설문 의견 삭제
	@Override
	public int deleteSurveyEtcOpinion(CoviMap params) throws Exception {
		return coviMapperOne.delete("user.survey.deleteSurveyEtcOpinion", params);
	}
	
	private CoviList coviSurveySelectJSON(CoviList clist, String str) throws Exception {
		String [] cols = str.split(",");
		
		StringUtil func = new StringUtil();
		
		CoviList returnArray = new CoviList();
		
		if(null != clist && clist.size() > 0){
				for(int i=0; i<clist.size(); i++){
					
					CoviMap newObject = new CoviMap();
					
					for(int j=0; j<cols.length; j++){
						Set<String> set = clist.getMap(i).keySet();
						Iterator<String> iter = set.iterator();
						
						while(iter.hasNext()){   
							Object ar = iter.next();
							//String ar = (String)iter.next();
							if(ar.equals(cols[j].trim())){
								
								Object value = clist.getMap(i).get(cols[j]);
								if(value == null){
									if(func.f_NullCheck(cols[j]).equals("Paragraph") || func.f_NullCheck(cols[j]).equals("Description")){
										newObject.put(cols[j], null);	
									}else{
										newObject.put(cols[j], "");
									}
								} else{
									newObject.put(cols[j], value);	
								}
								
								/*newObject.put(cols[j], clist.getMap(i).getString(cols[j]));*/
							}
						}
					}
					
					returnArray.add(newObject);
				}
			}
		return returnArray;
	}
	
	
	private String surveyTargetUserCode(CoviMap params) {
		params.put("targetType", ""); //참석여부 상관없이 모든 참석자 조회
		CoviList allList = coviMapperOne.list("user.survey.selectAttendanceCodes", params);
		
		StringBuffer buf = new StringBuffer();
		for(Object target: allList) {
			buf.append(((CoviMap)target).getString("TargetCode")).append(";");
		}
		
		return buf.toString();
		
	}
	
	@Override
	public String getSurveyTargetViewRead(CoviMap params) {
		return coviMapperOne.getString("user.survey.getSurveyTargetViewRead", params);
	}
	
	@Override
	public CoviMap getSurveyRespondent(CoviMap params) throws Exception{
		return coviMapperOne.selectOne("user.survey.selectQuestionItemAnswerList", params);
	}
	
	@Override
	public CoviList selectAttendanceCodeList(CoviMap params) throws Exception{
		return coviMapperOne.list("user.survey.selectAttendanceCodes", params);
	}
	// 웹파트 설문 데이터 조회
	@Override
	public CoviMap getWebpartSurveyData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("webpart.survey.getWebpartSurveyData", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ItemID,Item,QuestionID,SurveyID,Subject,Description,RegistDate,respondentYn,totCnt,rate,joinRate,QuestionCount,QuestionType,SurveyStartDate,SurveyEndDate,registerYn"));
		
		return resultList;
	}
	
	@Override
	public CoviMap getSurveyApprover(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		resultList.put("data", coviMapperOne.getString("user.survey.getSurveyApprover", params));
		return resultList;
	}
	
	@Override
	public CoviMap getGroupFullPath(CoviList paramsList) throws Exception {
		CoviMap resultList = new CoviMap();
		
		for(int i = 0 ; i < paramsList.size(); i++) {
			CoviMap item = (CoviMap) paramsList.get(i);
			String param = coviMapperOne.getString("user.survey.getGroupFullPath", item);
				
			resultList.put(item.getString("UserCode"),param);
		}
		
		return resultList;
	}

}