package egovframework.covision.coviflow.form.service.impl;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystemNotFoundException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.Properties;
import java.util.UUID;

import javax.annotation.Resource;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.collections.ListUtils;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.EditorService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.covision.coviflow.form.service.ApvProcessSvc;
import egovframework.covision.coviflow.form.service.EngineSvc;
import egovframework.covision.coviflow.form.service.FormSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import javax.xml.transform.OutputKeys;


@Scope("prototype") 
@Service("ApvProcessSvc")
public class ApvProcessSvcImpl extends EgovAbstractServiceImpl implements
		ApvProcessSvc {

	private static Logger LOGGER = LogManager.getLogger(ApvProcessSvcImpl.class);

	@Resource(name = "coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private EngineSvc engineSvc;

	@Autowired
	private FileUtilService fileUtilSvc;
	
	@Autowired
	private EditorService editorService;
	
	@Autowired
	private FormSvc formSvc;

	AwsS3 awsS3 = AwsS3.getInstance();
	
	public static Properties getGovDocsProperties() {
		return ComUtils.getProperties("govdocs.properties");
	}
	
	// 기안/결재 요청
	@Override
	public String doProcess(CoviMap pObj, CoviMap processFormDataReturn) throws Exception {
		// 데이터 초기화
		CoviMap formObj = pObj;
		
		String changeApprovalLine = null;
		CoviMap formData = new CoviMap();
		String mode = formObj.getString("mode").toUpperCase();
		String isModified = "false";
		String isFile = "false";
		String strGSubject = "";
		
		if (!formObj.isEmpty() && formObj.has("ChangeApprovalLine"))
			changeApprovalLine = formObj.getString("ChangeApprovalLine");
		
		try {
			formObj = processFormDataReturn.getJSONObject("formObj");
			formData = processFormDataReturn.getJSONObject("formData");
			isFile = processFormDataReturn.getString("isFile");
			strGSubject = processFormDataReturn.getString("strGSubject");
			isModified = processFormDataReturn.getString("isModified");
			 
			// 승인취소 인 경우, 이후 결재자 결재 상태 완료로 변경된 건 있는지 체크함
			if(formObj != null && !formObj.isEmpty() && formObj.containsKey("actionMode")
					&& formObj.optString("actionMode").equalsIgnoreCase("APPROVECANCEL") && getWorkitemAbortCount(formObj) > 0) {
				throw new IllegalStateException(DicHelper.getDic("msg_ChangeApprovalState_05")); // 승인취소 할 수 없는 상태입니다.
			}
			
			// 엔진에 결재 요청 처리
			processProcData(mode, formObj, formData, changeApprovalLine, isModified, strGSubject, isFile);
		} catch (NullPointerException npE) {
			LOGGER.error("ApvProcessSvcImpl", npE);
			throw npE;
		} catch (Exception e) {
			LOGGER.error("ApvProcessSvcImpl", e);
			throw e;
		}	

		if (formObj != null && formObj.has("FormInstID")) {
			return formObj.optString("FormInstID");
		} else {
			return "";
		}
	}
	// 본문 생성과 기안 함수 분리함
	@Override
	public CoviMap doCreateInstance(String processType, CoviMap pObj, List<MultipartFile> mf) throws Exception {
		return doCreateInstance(processType, pObj, mf, null);
	}
	
	// 본문 생성과 기안 함수 분리함
	@Override
	public CoviMap doCreateInstance(String processType, CoviMap pObj, List<MultipartFile> mf, CoviMap mfList) throws Exception {
		CoviMap processFormDataReturn = null;
		
		// 데이터 초기화
		CoviMap formObj = pObj;
		
		CoviMap approvalLine = new CoviMap();
		String changeApprovalLine = null;
		CoviMap processDescription = new CoviMap();
		CoviMap formData = new CoviMap();
		CoviMap attachFileInfoObj = null;					// formInstance 테이블의 attachFileInfo 컬럼 데이터를 가지고 있는 json object
		CoviMap multiattachFileInfoObj = new CoviMap();					// formInstance 테이블의 attachFileInfo 컬럼 데이터를 가지고 있는 json object
		String attachFileInfoStr = null;							// 편집시 파일을 모두 지웠을 경우 빈값만 넘어오는 것에 대한 처리를 위함.
		CoviMap bodyData = new CoviMap();
		CoviMap formInfoExt = new CoviMap();

		String mode = formObj.optString("mode").toUpperCase();
		String isFile = "false";
		boolean isUseMultiEdit = false;

		int revision;

		CoviMap fileObj = new CoviMap();					// 파일 저장 후 리턴받은 com_file 테이블의 정보.
		CoviMap fileInfosObj = new CoviMap();	
		CoviList fileInfos = new CoviList();

		Boolean isFileUpload = null;
		
		//region - 변수 할당
		if (formObj.has("ApprovalLine"))
			approvalLine = CoviMap.fromObject(formObj.get("ApprovalLine"));
		if (formObj.has("FormData"))
			formData = CoviMap.fromObject(formObj.optString("FormData"), false);
		if (formObj.has("ProcessDescription")){
			processDescription = CoviMap.fromObject(formObj.optString("ProcessDescription"));
			isFile = processDescription.getString("IsFile").equals("Y") ? "true" : "false";
		}
		if (formObj.has("ChangeApprovalLine"))
			changeApprovalLine = formObj.getString("ChangeApprovalLine");
		

		if (formObj.has("FormInfoExt")) {
			formInfoExt = CoviMap.fromObject(formObj.optString("FormInfoExt"));

			if (formInfoExt != null && formInfoExt.has("IsUseMultiEdit") && formInfoExt.getString("IsUseMultiEdit").equals("Y")) {
				isUseMultiEdit = true;
			}
		}

		// 2019.06 첨부파일 XSS처리
		if (formData != null && formData.has("AttachFileInfo")) {
			if(!formData.optString("AttachFileInfo").equals("")) {
				attachFileInfoObj = CoviMap.fromObject(ComUtils.RemoveScriptAndStyle(formData.optString("AttachFileInfo")));
			} else {
				attachFileInfoStr = ComUtils.RemoveScriptAndStyle(formData.optString("AttachFileInfo"));
			}
		}

		processDescription.put("_instanceid", formObj.get("FormInstID"));

		// 마스터/서브 테이블이 있는 양식
		if (formData != null && formData.has("BodyData")) {
			bodyData = formData.getJSONObject("BodyData");

			if (isUseMultiEdit && bodyData.has("SubTable1")) {
				Object o = bodyData.get("SubTable1");
				CoviList arr = null;
				if(o instanceof CoviList) {
					arr = (CoviList)o;
				}else if(o instanceof CoviMap) {
					arr = new CoviList();
					arr.add(o);
				}
				if(arr != null && !arr.isEmpty()) {
					for (Object obj : arr) {
						CoviMap fi = (CoviMap) obj;
						if(fi.has("ROWSEQ") && fi.has("MULTI_ATTACH_FILE")) {
							multiattachFileInfoObj.put(fi.get("ROWSEQ"), ComUtils.RemoveScriptAndStyle(fi.optString("MULTI_ATTACH_FILE")));
						}
					}
				}
			}
		}
		processDescription.put("_instanceid", formObj.get("FormInstID"));
		
		// 마스터/서브 테이블이 있는 양식
		if (formData != null && formData.has("BodyData")) {
			bodyData = formData.getJSONObject("BodyData");
		}
		
		// history data 버전 select
		CoviMap params = new CoviMap();
		params.put("FormInstID", Objects.toString(formObj.get("FormInstID"), ""));
		revision = coviMapperOne.selectOne("form.formhistory.selectReivision", params);
		
		// 승인자 내용변경 저장
		if("EDIT".equals(formObj.get("btnFlag")) && revision > 1) {
			params.put("TaskID", Objects.toString(formObj.get("taskID"), ""));
			CoviMap editHistInfo = coviMapperOne.selectOne("form.formhistory.selectEditHistory", params);
			
			//변경 이력 있는 history 에 대해 revision 최대값으로 변경
			if(editHistInfo != null && !editHistInfo.isEmpty()) revision--;
		}
		//endregion		
		
		CoviList editorList = new CoviList();
		CoviMap bodyContext = new CoviMap();
		
		if (formData != null && formData.has("BodyContext")) {
			bodyContext = formData.getJSONObject("BodyContext");

			if(processType.equals("PROCESS")){
				// BodyContext 내 임시성 데이터 삭제 
				bodyContext = deleteBodyContextTempData(bodyContext);
			}
		}		

		//에디터 인라인 이미지 처리 
		if(formData != null) {
			String formInstID = Objects.toString(formObj.getString("FormInstID"),"0").equals("") ? "0" : formObj.getString("FormInstID");
			CoviList contentIdxList = new CoviList();
			
			if(formData.has("EditorImagesContentIdx")) {
				contentIdxList = formData.getJSONArray("EditorImagesContentIdx");
			} else {
				contentIdxList.add("");
			}
			
			for(int i = 0; i < contentIdxList.size(); i++) {
				String idx = contentIdxList.getString(i);
				
				if( !( (bodyContext.has("tbContentElement"+idx) && !bodyContext.getString("tbContentElement"+idx).equals(""))
					&& ((formData.has("EditorInlineImages"+idx) && !formData.getString("EditorInlineImages"+idx).equals("")) || (formData.has("EditorBackgroundImage"+idx) && !formData.getString("EditorBackgroundImage"+idx).equals(""))) )) {
					continue;
				}
				
				CoviMap editorInfo = new CoviMap();
				CoviMap editorParam = new CoviMap();
				
			    editorParam.put("serviceType", "Approval");  //BizSection
			    editorParam.put("imgInfo", Objects.toString(formData.get("EditorInlineImages"+idx), ""));
				editorParam.put("backgroundImage", Objects.toString(formData.get("EditorBackgroundImage"+idx), ""));
			    editorParam.put("objectID", "0");
			    editorParam.put("objectType", "NONE");
			    editorParam.put("messageID" , formInstID);
			    editorParam.putOrigin("bodyHtml",bodyContext.getString("tbContentElement"+idx));
			    
			    editorInfo = editorService.getContent(editorParam);
			    
			    String BodyHtml = editorInfo.getString("BodyHtml");
			    
			    //이미지 경로 체크
			    if(BodyHtml.indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) < 0) {
			    	bodyContext.putOrigin("tbContentElement"+idx, editorInfo.getString("BodyHtml"));
				    formData.putOrigin("BodyContext", bodyContext);
				    
				    //후처리를 위한 에디터 리스트
					CoviMap editorObj = new CoviMap();
				    editorObj.put("editorInfo", editorInfo);
				    editorObj.put("editorParam", editorParam);
				    editorList.add(editorObj);
			    } else {
			    	LOGGER.error("ApvProcessSvcImpl[File Exception]");
			    	throw new Exception("InlineImage move BackStorage Error");
			    }
			}
		}
		
		CoviMap doAttachFileSaveReturn = null;
		if (isUseMultiEdit) {
			if (bodyData.has("SubTable1") && !bodyData.getString("SubTable1").equals("")) {
				Iterator<String> keys = multiattachFileInfoObj.keySet().iterator();
				
				while (keys.hasNext()) {
					String fileConkey = "MultifileData_" + keys.next();
					
					CoviMap tmpAttachFileInfoObj = null;
					CoviList tmpFileInfos = new CoviList();
					
					List<MultipartFile> mmf = new ArrayList<>();
					
					if(mfList != null && mfList.get(fileConkey) != null) {
						mmf = (List<MultipartFile>) mfList.get(fileConkey);
					}
					
					if(!(multiattachFileInfoObj.get(fileConkey.split("_")[1]) == null || multiattachFileInfoObj.get(fileConkey.split("_")[1]).equals(""))) {
						tmpAttachFileInfoObj = multiattachFileInfoObj.getJSONObject(fileConkey.split("_")[1]);
					}

					doAttachFileSaveReturn = doAttachFileSave(processType, mmf, tmpAttachFileInfoObj, formObj, mode, isFile, fileObj, isFileUpload, tmpFileInfos, attachFileInfoStr, fileConkey);
					fileObj.put(fileConkey, doAttachFileSaveReturn.getJSONObject("fileObj")); 
					if(isFileUpload == null || Boolean.FALSE.equals(isFileUpload)) {
						if (doAttachFileSaveReturn.has("isFileUpload"))
							isFileUpload = doAttachFileSaveReturn.getBoolean("isFileUpload");
						else 
							isFileUpload = null; // 초기값이 null이므로 값이 없을 경우 null임
					}
					fileInfosObj.put(fileConkey, doAttachFileSaveReturn.getJSONArray("fileInfos"));
					isFile = isFile.equals("true") ? isFile : doAttachFileSaveReturn.getString("isFile");
				}
			}
		}
		else{
			//첨부파일 처리
			doAttachFileSaveReturn = doAttachFileSave(processType, mf, attachFileInfoObj, formObj, mode, isFile, fileObj, isFileUpload, fileInfos, attachFileInfoStr, null);
			fileObj = doAttachFileSaveReturn.getJSONObject("fileObj");
			isFileUpload = doAttachFileSaveReturn.has("isFileUpload") ? doAttachFileSaveReturn.getBoolean("isFileUpload") : null;			// 초기값이 null이므로 값이 없을 경우 null임
			fileInfos = doAttachFileSaveReturn.getJSONArray("fileInfos");
			isFile = doAttachFileSaveReturn.getString("isFile");
		}
		
		if (isFileUpload == null || isFileUpload) {
			try {
				// db 처리
				if (processType.equals("PROCESS")) {
					processFormDataReturn = processFormData(formObj, formData, bodyData, mode, processDescription, approvalLine, changeApprovalLine, revision, fileInfos, fileInfosObj, (isUseMultiEdit ? multiattachFileInfoObj : attachFileInfoObj), isFile, isFileUpload, attachFileInfoStr);
				} else if (processType.equals("TEMPSAVE")) { // 임시저장
					// 임시저장 처리
					formObj = doTempSave(mode, formObj, formData, bodyData, approvalLine, (isUseMultiEdit ? multiattachFileInfoObj : attachFileInfoObj), fileInfos, fileInfosObj, isFileUpload);
				}
			} catch (NullPointerException npE) {
				LOGGER.error("ApvProcessSvcImpl", npE);

				FileUtil.fileUploadRollBack(fileInfos);
				
				throw npE;
			} catch (Exception e) {
				LOGGER.error("ApvProcessSvcImpl", e);

				// TODO 첨부 편집하다가 오류날경우 기존에 있던 물리파일까지 모두 삭제하고, throw를 해서 db데이터는 삭제되지 않으므로 일단 주석처리
				// 첨부파일 복구 처리(삭제) 
//				if (mf != null && !mf.isEmpty()) {
//					FileUtil.fileUploadRollBack(fileInfos, "MessageID");
//				}

				// 1. 삭제파일 : 편집시 변동된 내역기준으로 Commit 이후에 삭제처리한다. ->> Rollback 시 삭제되지 않으므로 처리할 사항 없음.
				// 2. 신규파일(Garbage) : fileInfos 의 정보는 신규 sys_file 이나, Rollback 되었으므로 파일만 삭제.
				FileUtil.fileUploadRollBack(fileInfos);
				
				throw e;
			}
		} else if (Boolean.FALSE.equals(isFileUpload)) {
			LOGGER.error("ApvProcessSvcImpl[File Exception]");
			throw new IOException();
		}
		
		//에디터 인라인 이미지 처리 
		for(int i = 0; i < editorList.size(); i++) {
			CoviMap editor = editorList.getJSONObject(i);
			CoviMap editorParam = editor.getJSONObject("editorParam");
			CoviMap editorInfo = editor.getJSONObject("editorInfo");
			
			if(editorParam.getString("messageID").equals("0")){
				if(editorInfo.has("FileID") && !editorInfo.getString("FileID").equals("")){
					editorParam.put("messageID", formObj.getString("FormInstID"));
					editorParam.addAll(editorInfo);

					editorService.updateFileMessageID(editorParam);
				}
			}
		}
		
		return processFormDataReturn;
	}
	
	private CoviMap doAttachFileSave(String processType, List<MultipartFile> mf, CoviMap attachFileInfoObj, CoviMap formObj, String mode, String isFile, CoviMap fileObj, Boolean isFileUpload, CoviList fileInfos, String attachFileInfoStr, String fileConkey) throws Exception{
		CoviMap returnObj = new CoviMap();
		String objectID = (fileConkey != null) ? fileConkey.split("_")[1] : "0"; // 다안기안 objectid로 구분됨, 일반첨부는 0이 기본값
		String serviceType = "Approval";
		String servicePath = "";
		String objectType = "DEPT";
		String messageID = formObj.optString("FormInstID");
		if(messageID.equals("")) messageID = "0"; 
		String commentMessageID = "0";
		boolean isClear = (messageID.equals("") || messageID.equals("0")) ? false : true;
		try {
			// 첨부파일 정보가 있을 경우. (일반적인 승인/반려일 때 첨부파일이 있어도 넘어오지 않음.)
			if (attachFileInfoObj != null) {
				// 관리자가 편집하는 경우
				// 결재자가 승인할 때 편집하는 경우
				// 임시함에서 임시저장하는 경우
				if (((mode.equals("ADMIN") || mode.equals("APPROVAL") || mode.equals("REDRAFT") || mode.equals("RECAPPROVAL") 
						|| mode.equals("SUBAPPROVAL") || mode.equals("PCONSULT") || mode.equals("SUBREDRAFT")) && formObj.containsKey("editMode") && formObj.getString("editMode").equals("Y"))
						|| (mode.equals("TEMPSAVE") && processType.equals("TEMPSAVE"))) {
					isClear = true; // 기존파일 삭제
				}
				// 회수 및 기안 취소할 경우
				// 완료함에서 재사용할 경우
				// 반려함에서 재사용할 경우
				// 담당업무함에서 재사용할 경우
				// 임시함에서 임시저장할 경우
				else if (((formObj.getString("gloct").equalsIgnoreCase("PROCESS") || formObj.getString("gloct").equalsIgnoreCase("BIZDOC")) && (formObj.optString("actionMode").equals("ABORT") || formObj.optString("actionMode").equals("WITHDRAW")))
						|| (mode.equals("DRAFT") && formObj.optString("gloct").equals("COMPLETE"))
						|| (mode.equals("DRAFT") && formObj.optString("gloct").equals("REJECT"))
						|| (mode.equals("DRAFT") && formObj.optString("gloct").equals("JOBFUNCTION"))
						|| (processType.equals("PROCESS") && mode.equals("TEMPSAVE"))) {
					isClear = false; // 기존파일 유지
				}

				fileInfos = fileUtilSvc.uploadToBack(attachFileInfoObj.getJSONArray("FileInfos"), mf, servicePath , serviceType, objectID, objectType, messageID, isClear);
				isFileUpload = true;
				fileObj.put("fileInfos", fileInfos);
				fileObj.put("isSucess", isFileUpload);
				
				if(fileInfos.size() > 0) isFile = "true";
				else isFile = "false";			
			} else {
				if (((mode.equals("ADMIN") || mode.equals("APPROVAL") || mode.equals("REDRAFT") || mode.equals("RECAPPROVAL") 
						|| mode.equals("SUBAPPROVAL") || mode.equals("PCONSULT") || mode.equals("SUBREDRAFT")) 
						&& formObj.containsKey("editMode") && formObj.getString("editMode").equals("Y") && attachFileInfoStr !=null && attachFileInfoStr.equals(""))
					|| (mode.equals("TEMPSAVE") && processType.equals("TEMPSAVE"))) {
					fileUtilSvc.clearFile(servicePath, serviceType, objectID, objectType, messageID);
					isFile = "false";
				}
			}
			
			// 의견첨부 삭제 = 회수, 기안 취소할 경우
			if (((formObj.getString("gloct").equalsIgnoreCase("PROCESS") || formObj.getString("gloct").equalsIgnoreCase("BIZDOC"))
					&& (formObj.optString("actionMode").equals("ABORT") || formObj.optString("actionMode").equals("WITHDRAW")))) {
				CoviMap processDescriptionObj = (CoviMap) formObj.get("ProcessDescription");
				
				// 의견첨부가 존재하는 경우
				if(processDescriptionObj.has("commentFileInfos")) {
					CoviList tmpArray = (CoviList) processDescriptionObj.get("commentFileInfos"); 
					List<String> fileIDs = new ArrayList<String>();
					
					for(Object fileinfo : tmpArray) {
						if(fileinfo instanceof CoviMap) {
							CoviMap obj = new CoviMap();
							obj = (CoviMap)fileinfo;
							fileIDs.add(obj.getString("FileID"));
						}
						else {
							CoviList obj = new CoviList();
							obj = (CoviList)fileinfo;
							for(Object fileinfo2 : obj) {
								CoviMap obj2 = new CoviMap();
								obj2 = (CoviMap)fileinfo2;
								fileIDs.add(obj2.getString("FileID"));
							}
						}
					}	
					
					if(fileIDs.size() > 0) fileUtilSvc.deleteFileByID(fileIDs, true); 
				}
			}
		}catch(NullPointerException npE) {
			LOGGER.error("ApvProcessSvcImpl.doAttachFileSave", npE);
			isFileUpload = false;
			fileObj.put("isSucess", isFileUpload);
		}catch(Exception e) {
			LOGGER.error("ApvProcessSvcImpl.doAttachFileSave", e);
			isFileUpload = false;
			fileObj.put("isSucess", isFileUpload);
		}finally {
			returnObj.put("fileObj", fileObj);
			returnObj.put("isFileUpload", isFileUpload);
			returnObj.put("fileInfos", fileInfos);
			returnObj.put("isFile", isFile);
		}
		return returnObj;
	}
	
	public String doCommentAttachFileSave(List<MultipartFile> commentMultiFiles, CoviMap formObj) throws Exception{
		// 첨부파일 처리
		//CoviMap fileObj = new CoviMap();
		CoviList fileInfos = new CoviList();
		List<CoviMap> savedCommentAttachFiles = new ArrayList<>();

		String objectID = "0";
		String serviceType = "Approval";
		String servicePath = "";
		String objectType = "DEPT";
		//String messageID = formObj.optString("FormInstID");
		String commentMessageID = "0";
		boolean isClear = false;
		
		if (commentMultiFiles != null && !commentMultiFiles.isEmpty()) {
			//fileObj = FileUtil.fileUpload(commentMultiFiles);					// 양식 첨부파일에서 MessageID는 FormInstanceID
			fileInfos = fileUtilSvc.uploadToBack(null, commentMultiFiles, servicePath , serviceType, objectID, objectType, commentMessageID, isClear);
			//fileInfos = fileObj.getJSONArray("fileInfos");
			
			for(int i=0; i<fileInfos.size(); i++) {
				CoviMap tmp = new CoviMap();
				tmp.put("id", ((CoviMap)fileInfos.get(i)).optString("FileID").trim());
				tmp.put("name", ((CoviMap)fileInfos.get(i)).optString("FileName"));
				tmp.put("savedname", ((CoviMap)fileInfos.get(i)).optString("SavedName"));
				
				savedCommentAttachFiles.add(tmp);
			}
		}
		
		return savedCommentAttachFiles.toString();
	}
	
	// 엔진에 결재 요청 처리
	private void processProcData(String mode, CoviMap formObj, CoviMap formData, String changeApprovalLine, String isModified, String strGSubject, String isFile) throws Exception {
		if(formObj == null) {
			throw new Exception("formObj Object is null.");
		}
		
		if(!formObj.has("isMobile")){
			formObj.put("isMobile", "N");
		}
		if(!formObj.has("isBatch")){
			formObj.put("isBatch", "N");
		}
		
		// 엔진으로 양식 본문 데이터를 넘기지 않음
		if(formData != null && !formData.isEmpty()) {
			formData.put("BodyContext", "");
			formObj.put("FormData", formData.toString());
		}
		
		if (mode.equals("DRAFT") || mode.equals("TEMPSAVE")) {
			int processId = 0;

			CoviList params = new CoviList();
			String processDefinitionID = formObj.optString("processDefinitionID");

			CoviMap obj1 = new CoviMap();
			obj1.put("name", "g_context");
			obj1.put("value", formObj.toString());
			params.add(obj1);

			obj1 = new CoviMap();
			obj1.put("name", "duedate");
			obj1.put("value", "2016-10-10");
			params.add(obj1);

			obj1 = new CoviMap();
			obj1.put("name", "initiator");
			obj1.put("value", formObj.optString("usid"));
			params.add(obj1);

			obj1 = new CoviMap();
			obj1.put("name", "g_isCancelled");
			obj1.put("value", false);
			params.add(obj1);

			obj1 = new CoviMap();
			obj1.put("name", "difficulty");
			obj1.put("value", "50");
			params.add(obj1);

			processId = engineSvc.requestStart(processDefinitionID, params);

			if (processId != 0) {
				formObj.put("processID", processId);
				CoviMap paramsObj = new CoviMap();
				paramsObj.put("FormInstID", formObj.get("FormInstID"));
				paramsObj.put("ProcessID", formObj.get("processID"));
				coviMapperOne.update("form.forminstance.updateProcessID", paramsObj);
			} else {
				throw new Exception();
			}
		} else if (mode.equals("APPROVAL") || mode.equals("PCONSULT") || mode.equals("REDRAFT") || mode.equals("PROCESS") || mode.equals("SUBREDRAFT") || mode.equals("SUBAPPROVAL") || mode.equals("RECAPPROVAL") || mode.equals("AUDIT")) {
			String taskId = formObj.getString("taskID");
			boolean opScCHB = false;
			
			CoviList params = new CoviList();

			CoviMap obj1 = new CoviMap();
			obj1.put("name", "g_action_" + taskId);
			obj1.put("value", formObj.get("actionMode"));
			obj1.put("scope", "global");
			params.add(obj1);

			obj1 = new CoviMap();
			obj1.put("name", "g_actioncomment_" + taskId);
			byte[] tmpComment = Base64.decodeBase64(((String)formObj.get("actionComment")).getBytes(StandardCharsets.UTF_8));
			String convComment = ComUtils.RemoveScriptAndStyle(new String(tmpComment, StandardCharsets.UTF_8));
			obj1.put("value", Base64.encodeBase64String(convComment.getBytes(StandardCharsets.UTF_8)));
			obj1.put("scope", "global");
			params.add(obj1);
			
			if(formObj.has("actionComment_Attach") && !formObj.optString("actionComment_Attach").equals("")) {
				obj1 = new CoviMap();
				obj1.put("name", "g_actioncomment_attach_" + taskId);
				obj1.put("value", formObj.getJSONArray("actionComment_Attach"));
				obj1.put("scope", "global");
				params.add(obj1);
			}
			else {
				obj1 = new CoviMap();
				obj1.put("name", "g_actioncomment_attach_" + taskId);
				obj1.put("value", new ArrayList<CoviMap>());
				obj1.put("scope", "global");
				params.add(obj1);
			}
			
			obj1 = new CoviMap();
			obj1.put("name", "g_signimage_" + taskId);
			obj1.put("value", formObj.get("signimagetype"));
			obj1.put("scope", "global");
			params.add(obj1);
			
			obj1 = new CoviMap();
			obj1.put("name", "g_isMobile_" + taskId);
			obj1.put("value", formObj.get("isMobile"));
			obj1.put("scope", "global");
			params.add(obj1);
			
			obj1 = new CoviMap();
			obj1.put("name", "g_isBatch_" + taskId);
			obj1.put("value", formObj.get("isBatch"));
			obj1.put("scope", "global");
			params.add(obj1);
			
			// 배포 지정
			obj1 = new CoviMap();
			obj1.put("name", "g_receiptList");
			obj1.put("value", formData.get("ReceiptList")); // 빈값으로 변경된경우도 업데이트해야되므로, 변경사항이없을땐 null로 전달 // formData.has("ReceiptList")?formData.get("ReceiptList"):""
			obj1.put("scope", "global");
			params.add(obj1);
			
			obj1 = new CoviMap();
			obj1.put("name", "g_receiveNames");
			obj1.put("value", formData.get("ReceiveNames"));
			obj1.put("scope", "global");
			params.add(obj1);
			
			// 담당자 지정일 경우
			if(formObj.has("CHARGEID") && formObj.has("CHARGENAME")){
				CoviMap chargeObj = new CoviMap();
				chargeObj.put("CHARGEID", formObj.getString("CHARGEID"));
				chargeObj.put("CHARGENAME", formObj.getString("CHARGENAME"));
				chargeObj.put("CHARGEOUID", formObj.getString("CHARGEOUID"));
				
				obj1 = new CoviMap();
				obj1.put("name", "g_charge_"+ taskId);
				obj1.put("value", chargeObj);
				obj1.put("scope", "global");
				params.add(obj1);
			}
			
			// 중간에 결재선을 수정해서 승인한 경우
			//if (isModified.equals("true") && changeApprovalLine != null) {
			String isChangeLine = "false";
			if (changeApprovalLine != null && (!formObj.has("processName") || !formObj.getString("processName").equalsIgnoreCase("Sub"))) {
				if(mode.equals("PCONSULT")) {
					changeApprovalLine = getChangeApprovalLine(changeApprovalLine, taskId, formObj);
				}
				
				obj1 = new CoviMap();
				obj1.put("name", "g_appvLine");
				obj1.put("value", changeApprovalLine);
				obj1.put("scope", "global");
				params.add(obj1);
				isChangeLine = "true";
			}
			
			if(formObj.has("processName") && formObj.getString("processName").equalsIgnoreCase("SUB")){
				obj1 = new CoviMap();
				obj1.put("name", "g_sub_appvLine");
				obj1.put("value", changeApprovalLine);
				obj1.put("scope", "global");
				params.add(obj1);
				isChangeLine = "true";
			}
			obj1 = new CoviMap();
			obj1.put("name", "g_isChangeLine");
			obj1.put("value", isChangeLine);
			obj1.put("scope", "global");
			params.add(obj1);
			
			// 승인자 내용변경 저장버튼 활성화 옵션 확인
			if(formObj.has("SchemaID")) {
				CoviMap processParams = new CoviMap();
				processParams.put("schemaID", formObj.getString("SchemaID"));
				CoviMap formSchema = ((CoviList)(formSvc.selectFormSchema(processParams)).get("list")).getJSONObject(0);
				
				if(!formSchema.get("SchemaContext").equals("")) {
					CoviMap schemaContext = formSchema.getJSONObject("SchemaContext");
					if( ( schemaContext.has("scCHBis") && "Y".equalsIgnoreCase(schemaContext.getJSONObject("scCHBis").getString("isUse"))
						||schemaContext.has("scRCHBis") && "Y".equalsIgnoreCase(schemaContext.getJSONObject("scRCHBis").getString("isUse")) )
						&&schemaContext.has("scCHBSaveBtn") && "Y".equalsIgnoreCase(schemaContext.getJSONObject("scCHBSaveBtn").getString("isUse")) ) {
						opScCHB = true;
					}
				}
			}
			
			// 중간에 formdata를 수정해서 승인한 경우 / 중간에 승인자 내용변경으로 수정한 문서를 승인한 경우
			if (isModified.equals("true") && (!formData.isEmpty() || (formData.isEmpty() && opScCHB)) && !(formObj.get("actionMode").equals("ABORT") || formObj.get("actionMode").equals("WITHDRAW"))) {
				/*
				 * 엔진으로 양식 본문 데이터를 넘기지 않음 
				 * obj1.put("name", "g_formData");
				 * obj1.put("value", formData.toString()); 
				 * obj1.put("scope", "global"); params.add(obj1);
				 */
				if(formData.has("Subject")){
					obj1 = new CoviMap();
					obj1.put("name", "g_subject");
					obj1.put("value", strGSubject);
					obj1.put("scope", "global");
					params.add(obj1);
					
					obj1 = new CoviMap();
					obj1.put("name", "g_isSubjectModified");
					obj1.put("value", "true");
					obj1.put("scope", "global");
					params.add(obj1);
				} else {
					obj1 = new CoviMap();
					obj1.put("name", "g_isSubjectModified");
					obj1.put("value", "false");
					obj1.put("scope", "global");
					params.add(obj1);
				}
				obj1 = new CoviMap();
				obj1.put("name", "g_isFile");
				obj1.put("value", isFile); // true / false
				obj1.put("scope", "global");
				params.add(obj1);
				
				// 기안부서 편집사항 수신부서에 적용되도록 추가함.\
				obj1 = new CoviMap();
				obj1.put("name", "g_context");
				obj1.put("value", formObj.toString());
				obj1.put("scope", "global");
				params.add(obj1);
			} else {
				obj1 = new CoviMap();
				obj1.put("name", "g_isSubjectModified");
				obj1.put("value", "false");
				obj1.put("scope", "global");
				params.add(obj1);
			}
			obj1 = new CoviMap();
			obj1.put("name", "g_isModified");
			obj1.put("value", isModified); // true / false
			obj1.put("scope", "global");
			params.add(obj1);
			
			engineSvc.requestComplete(taskId, params);
		}
	}

	// db 처리
	private CoviMap processFormData(CoviMap formObj, CoviMap formData, CoviMap bodyData, String mode, CoviMap processDescription, CoviMap approvalLine, String changeApprovalLine, int revision, CoviList fileInfos, CoviMap fileInfosObj, CoviMap attachFileInfoObj, String isFile, Boolean isFileUpload, String attachFileInfoStr) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviMap paramsObj = new CoviMap();
		CoviMap paramsMap = new CoviMap();
		
		String isModified = "false";
		String strGSubject = "";
		String deleteTempFormInstID = ""; // 다안기안 서브 테이블 삭제용 FormInstID

		boolean isUseMultiEdit = false;
		boolean isEditSave = "EDIT".equals(formObj.get("btnFlag"));

		if (formObj.has("FormInfoExt")) {
			CoviMap formInfoExt = CoviMap.fromObject(formObj.optString("FormInfoExt"));

			if (formInfoExt != null && formInfoExt.has("IsUseMultiEdit") && formInfoExt.getString("IsUseMultiEdit").equals("Y")) {
				isUseMultiEdit = true;
			}
		}

		if(formObj.has("ProcessDescription")){
			CoviMap pdesc = (CoviMap)formObj.get("ProcessDescription");
		    if(pdesc.has("IsModify") && pdesc.getString("IsModify").equals("Y")) isModified = "true"; 
		}
		
		// delete jwf_formstempinstbox, jwf_forminstance, jwf_privatedomaindata
		// region - 임시함에서 기안했을 경우 데이터 삭제
		if (mode.equals("TEMPSAVE")) {
			paramsObj.put("FormInstID", formObj.get("FormInstID"));
			paramsObj.put("FormTempInstBoxID", formObj.get("FormTempInstBoxID"));

			// jwf_formstempinstbox
			coviMapperOne.delete("form.formstempinstbox.deleteTemp", paramsObj);

			// jwf_forminstance
			coviMapperOne.delete("form.forminstance.deleteTemp", paramsObj);

			// jwf_privatedomaindata
			coviMapperOne.delete("form.privatedomaindata.deleteTemp", paramsObj);
			
			// 다안기안 서브 테이블 삭제용 FormInstID (임시저장 후 기안 시 기존 데이터 삭제용)
			deleteTempFormInstID = formObj.get("FormInstID").toString();
		}
		// endregion
		
		
		// insert/update forminstance table - 기안 및 임시저장 데이터 저장
		CoviMap setFormInstanceReturn = setFormInstance(mode, formObj, formData, processDescription);
		formObj = setFormInstanceReturn.getJSONObject("formObj");
		processDescription = setFormInstanceReturn.getJSONObject("processDescription");
		
		// region - 회수, 기안취소 처리
		// 회수 및 기안 취소시 FormInstance insert
		paramsMap = new CoviMap();
		
		if (formObj.has("gloct") && (formObj.getString("gloct").equalsIgnoreCase("PROCESS") || formObj.getString("gloct").equalsIgnoreCase("BIZDOC")) && (formObj.get("actionMode").equals("ABORT") || formObj.get("actionMode").equals("WITHDRAW"))) {
			if((formObj.has("ProcessDescription") && formObj.getJSONObject("ProcessDescription").has("BusinessData1") && formObj.getJSONObject("ProcessDescription").getString("BusinessData1").equals("ACCOUNT")) 
					|| (formObj.has("FormPrefix") && formObj.getString("FormPrefix").indexOf("BIZMNT")  > -1)) {
				//ProcessDescription의 BusinessData1이 ACCOUNT인 경우 e-Accounting 문서로 간주
				//e-Accounting 문서는 임시함 저장 X
				//사업관리 양식도 임시함 저장 X
			} else {
				// FormInstance Insert
				paramsMap.put("FormInstID", formObj.optString("FormInstID"));
				coviMapperOne.insert("form.forminstance.insertForTempSave", paramsMap);
				String newFormInstID = paramsMap.optString("FormInstID");
				
				//하위테이블 Insert
				// fmid를 통해 subtable 가져옴
				paramsObj = new CoviMap();
				
				paramsMap.clear();
				paramsMap.put("FormID", formObj.optString("FormID"));
				CoviMap selectResult = coviMapperOne.select("form.forms.select", paramsMap);
	
				CoviMap extInfo = CoviSelectSet.coviSelectJSON(selectResult, "FormID,ExtInfo").getJSONObject(0);
				extInfo = extInfo.getJSONObject("ExtInfo");
				Iterator<?> keys = extInfo.keys();
	
				while (keys.hasNext()) {
					String key = (String) keys.next();
					if(key.equals("MainTable") || key.equals("SubTable1") || key.equals("SubTable2") || key.equals("SubTable3") || key.equals("SubTable4")){
						String tableName = extInfo.getString(key);
						if(tableName != null && !tableName.equals("")){
							paramsMap.clear();
							paramsMap.put("tableName", tableName);
	
							String columeName = coviMapperOne.select("form.subtable.selectColumnNames", paramsMap).getString("ColumnName");
							
							paramsObj.clear();
							paramsObj.put("tableName", tableName);
							paramsObj.put("columns", columeName);
							paramsObj.put("newFormInstID", newFormInstID);
							paramsObj.put("formInstID", formObj.optString("FormInstID"));
							coviMapperOne.insert("form.subtable.insertSelectData", paramsObj);
						}
					}
				}
				
				// FormTempBox Insert
				formObj.put("FormInstID", newFormInstID);
				
				paramsMap.clear();
				paramsMap.put("FormInstID", newFormInstID);
				coviMapperOne.insert("form.formstempinstbox.insertFromForminstanceW", paramsMap);
	
				// Private Domain Data
				String newTempInstBoxID = paramsMap.optString("FormTempInstBoxID");
	
				paramsMap.clear();
				formObj.put("FormTempInstBoxID", newTempInstBoxID);
				
				insertPrivateDomainData(formObj, formData.getString("Subject"), approvalLine);
			}
		}
		// endregion

		
		// 기안 시 하위테이블 있을 경우 데이터 저장
		formObj.put("DeleteTempFormInstID", deleteTempFormInstID);
		formObj = setSubTable(bodyData, formObj);
		
		// 기록물철 저장
		if(!isUseMultiEdit && formData.has("RecordDocInfo")) {
			CoviMap params1 = new CoviMap();
			params1.put("FormInstID", formObj.optString("FormInstID"));
			params1.put("ProcessID", formObj.optString("processID"));
			int cnt = (int) coviMapperOne.getNumber("form.recorddocinfo.selectRecordDocPCnt", params1);
			
			// 기존 기록물철 있을 경우 편집
			if(cnt >0) {
				updateRecordDocInfoData(formObj, formData);
			}else if(formData.has("RecordDocInfo")) {
				insertRecordDocInfoData(formObj, formData);
			}
		}

		// region - insert/update formhistory table (FormInstance) - 히스토리 저장
		paramsObj = new CoviMap();

		// 중간에 본문 내용 변경시 변경한 컬럼에 대해 history 남김
		if (!mode.equals("DRAFT") && !mode.equals("TEMPSAVE") && !((formObj.has("gloct") && (formObj.getString("gloct").equals("PROCESS") || formObj.getString("gloct").equalsIgnoreCase("BIZDOC")) 
				&& (formObj.get("actionMode").equals("ABORT") || formObj.get("actionMode").equals("WITHDRAW"))))) {

			if (formData != null) {
				Iterator<?> keys = formData.keys();
				while (keys.hasNext()) {
					String key = (String) keys.next();
					if (!key.equals("BodyData") && !key.equals("BODY_CONTEXT_HWP") && !key.equals("RecordDocInfo") && !key.matches("EditorInlineImages(.*)") && !key.matches("EditorBackgroundImage(.*)") && !key.equals("EditorImagesContentIdx") && !key.equals("prevBodyData")) { // 하위테이블 히스토리 저장 별도 처리 (임의)
						
						if(key.equals("Subject")){
							strGSubject = formData.getString("Subject");
						}
						
						if(!mode.equals("ADMIN")){
							boolean insertHistFlag = true;
							
							// formhistory insert
							paramsObj.clear();
	
							paramsObj.put("FormInstID", Objects.toString(formObj.get("FormInstID"), ""));
							paramsObj.put("FieldName", Objects.toString(key, ""));
							paramsObj.put("FieldType", Objects.toString("", ""));
							paramsObj.put("Revision", revision);
							paramsObj.put("RegID", Objects.toString(SessionHelper.getSession("USERID"), ""));
							paramsObj.put("ModID", Objects.toString(SessionHelper.getSession("USERID"), ""));
							paramsObj.put("TaskID", isEditSave ? Objects.toString(formObj.get("taskID")) : null);
							
							//승인자 내용변경 저장
							if(isEditSave) insertHistFlag = updateEditSave(paramsObj);
							if(insertHistFlag) coviMapperOne.insert("form.formhistory.insertFromFormInstance", paramsObj);
							
							// 보류 시 제목, 첨부파일 update || 승인자 내용변경 저장
							if(formObj.get("actionMode").equals("RESERVE") || isEditSave) {
								if(key.equals("Subject")) {
									paramsObj.put("FormInstID", formObj.getString("FormInstID"));
									paramsObj.put("SubjecNm", strGSubject);
									
									coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processData", paramsObj);
									coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processdescriptionData", paramsObj);
									coviMapperOne.update("admin.adminDocumentInfo.updateJwf_circulationboxData", paramsObj);
									coviMapperOne.update("admin.adminDocumentInfo.updateJwf_circulationboxdescriptionData", paramsObj);
								} else if(key.equals("AttachFileInfo")){
									paramsObj.put("FormInstID", formObj.getString("FormInstID"));
									paramsObj.put("IsFile", isFile.equals("true") ? "Y" : "N");
									
									coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processdescriptionData", paramsObj);
									coviMapperOne.update("admin.adminDocumentInfo.updateJwf_circulationboxdescriptionData", paramsObj);
								}
							}
						}else{
							paramsObj.clear();
							
							if(key.equals("Subject")){
								paramsObj.put("FormInstID", formObj.getString("FormInstID"));
								paramsObj.put("SubjecNm", strGSubject);
								
								coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processData", paramsObj);
								coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processdescriptionData", paramsObj);
								//coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processArchiveData", paramsObj);
								coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processdescriptionArchiveData", paramsObj);
								coviMapperOne.update("admin.adminDocumentInfo.updateJwf_circulationboxData", paramsObj);
								coviMapperOne.update("admin.adminDocumentInfo.updateJwf_circulationboxdescriptionData", paramsObj);
							}else if(key.equals("AttachFileInfo")){
								paramsObj.put("FormInstID", formObj.getString("FormInstID"));
								paramsObj.put("IsFile", isFile.equals("true") ? "Y" : "N");
								
								coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processdescriptionData", paramsObj);
								coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processdescriptionArchiveData", paramsObj);
								coviMapperOne.update("admin.adminDocumentInfo.updateJwf_circulationboxdescriptionData", paramsObj);
							}
						}

						// forminstance update
						// BodyContext 수정했을 경우, FormInstance에 반영
						if (!key.equals("AttachFileInfo")) {
							paramsObj.clear();

							String fieldValue = formData.optString(key);
							if (key.equals("BodyContext")) {
								// 본문검색용 컬럼 업데이트
								paramsObj.put("FieldName", Objects.toString("BodyContextOrg", ""));
								paramsObj.putOrigin("FieldValue", Objects.toString(fieldValue, ""));
								paramsObj.put("LastModifierID", Objects.toString(SessionHelper.getSession("USERID"), ""));
								paramsObj.put("FormInstID", Objects.toString(formObj.get("FormInstID"), ""));

								coviMapperOne.update("form.forminstance.updateRevision", paramsObj);
								
								fieldValue = replaceBodyContext(fieldValue);
							}

							paramsObj.put("FieldName", Objects.toString(key, ""));
							paramsObj.put("FieldValue", Objects.toString(fieldValue, ""));
							paramsObj.put("LastModifierID", Objects.toString(SessionHelper.getSession("USERID"), ""));
							paramsObj.put("FormInstID", Objects.toString(formObj.get("FormInstID"), ""));

							coviMapperOne.update("form.forminstance.updateRevision", paramsObj);
						}
					} else if(key.equals("prevBodyData")) {
						paramsObj.clear();
						
						String fieldValue = formData.getJSONObject(key).toString();
						paramsObj.put("FormInstID", Objects.toString(formObj.get("FormInstID"), ""));
						paramsObj.put("FieldName", "BodyData");
						paramsObj.put("FieldType", "");
						paramsObj.put("Revision", revision);
						paramsObj.put("RegID", Objects.toString(SessionHelper.getSession("USERID"), ""));
						paramsObj.put("ModID", Objects.toString(SessionHelper.getSession("USERID"), ""));
						paramsObj.put("ModValue",new String(Base64.encodeBase64(fieldValue.getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
						
						coviMapperOne.insert("form.formhistory.insert", paramsObj);
					}
					isModified = "true";
				}
			}
		}
		// endregion
		
		// region - update domaindata table X, formhistory - 결재선 데이터 수정되었을 경우, 히스토리 저장
		// 재기안 시에는 부서=>사용자로 무조건 결재선이 변경되기 때문에 편집이력 남길 때 예외처리함.
		// [21-02-09 mod] 기안, 임시저장 외 결재선, 본문 편집시 편집 이력 남김
		paramsObj = new CoviMap();
		
		if (!mode.equals("DRAFT") && !mode.equals("TEMPSAVE") 
				&& (!mode.equals("REDRAFT") && !mode.equals("SUBREDRAFT") && (changeApprovalLine != null || (formData != null && !formData.isEmpty())))
				&& !((formObj.has("gloct") && formObj.getString("gloct").equals("PROCESS") && (formObj.get("actionMode").equals("ABORT") || formObj.get("actionMode").equals("WITHDRAW"))))) {
			/*
			 * paramsObj.put("ProcessID", formObj.get("processID"));
			 * paramsObj.put("DomainDataContext", changeApprovalLine.toString());
			 * 
			 * coviMapperOne.update("form.formdomaindata.updateFromDomainData",
			 * paramsObj);
			 */

			// history 수정되기 전 데이터 select
			//CoviMap oldDomainData = new CoviMap();
			paramsObj.put("FormInstID", Objects.toString(formObj.get("FormInstID"), ""));
			paramsObj.put("ProcessID", Objects.toString(formObj.get("processID"), ""));
			paramsObj.put("FieldName", "ApprovalLine");
			paramsObj.put("FieldType", Objects.toString("", ""));
			paramsObj.put("Revision", revision);
			paramsObj.put("RegID", Objects.toString(SessionHelper.getSession("USERID"), ""));
			paramsObj.put("ModID", Objects.toString(SessionHelper.getSession("USERID"), ""));
			paramsObj.put("TaskID", isEditSave ? Objects.toString(formObj.get("taskID")) : null);
			
			CoviMap oldDomainDataMap = coviMapperOne.selectOne("form.formhistory.selectDomainData", paramsObj);
			
			if(!mode.equals("REDRAFT") && !mode.equals("SUBREDRAFT") && changeApprovalLine != null) {
				boolean insertHistFlag = true;
				
				paramsObj.replace("FieldName", "isModApprovalLine");
				paramsObj.put("ModValue","Y");

				//승인자 내용변경 저장
				if(isEditSave) insertHistFlag = updateEditSave(paramsObj);
				if(insertHistFlag) coviMapperOne.insert("form.formhistory.insert", paramsObj);
			}
			
			// history data 저장
			coviMapperOne.insert("form.formhistory.insertFromFormInstanceAPST", oldDomainDataMap);

			paramsObj.clear();
			paramsObj.put("LastModifierID", Objects.toString(SessionHelper.getSession("USERID"), ""));
			paramsObj.put("FormInstID", Objects.toString(formObj.get("FormInstID"), ""));

			coviMapperOne.update("form.forminstance.updateRevision", paramsObj);

			isModified = "true";
		}
		// endregion

		if (isUseMultiEdit) {
			if(attachFileInfoObj != null) {
				Iterator<String> keys = attachFileInfoObj.keySet().iterator();
				
				int itIdx = 0;
				int itLength = attachFileInfoObj.keySet().size();
				while (keys.hasNext()) {
					String fileConkey = keys.next();
					CoviList fileInfo = (CoviList) fileInfosObj.get("MultifileData_" + fileConkey);
					CoviMap tmpAttachFileInfoObj = null;
					
					if(!(attachFileInfoObj.get(fileConkey) == null || attachFileInfoObj.get(fileConkey).equals(""))) {
						tmpAttachFileInfoObj = attachFileInfoObj.getJSONObject(fileConkey);
					}
					
					if(fileInfo == null || fileInfo.isEmpty()) {
						if(tmpAttachFileInfoObj != null && tmpAttachFileInfoObj.has("FileInfos")) {
							fileInfo = CoviList.fromObject(tmpAttachFileInfoObj.get("FileInfos"));
						}
					}
	
					// 첨부파일이 있을 경우 formInstance에 저장
					if(itIdx == itLength - 1) {
						formObj.put("__totalFileInfoJson__", fileInfosObj);
					}
					CoviMap setAttachFileInfoReturn = null;
					try {
						setAttachFileInfoReturn = setAttachFileInfo(fileInfo, formObj, tmpAttachFileInfoObj, "", null, isUseMultiEdit);
					}finally {
						formObj.remove("__totalFileInfoJson__");
					}
					attachFileInfoObj.put(fileConkey, setAttachFileInfoReturn.getJSONObject("attachFileInfoObj"));
					isFile = setAttachFileInfoReturn.getString("isFile");
			
					// update com_file MessageID - 새로 추가된 첨부파일의 MessageID 수정
					setFormInstanceIDInComFile(isFileUpload, fileInfo, formObj);
					
					itIdx ++;
				}
			}
		} else {
			// attachFileInfo update
			CoviMap setAttachFileInfoReturn = setAttachFileInfo(fileInfos, formObj, attachFileInfoObj, isFile, attachFileInfoStr, isUseMultiEdit);
			attachFileInfoObj = setAttachFileInfoReturn.getJSONObject("attachFileInfoObj");
			isFile = setAttachFileInfoReturn.getString("isFile");
	
			// update com_file MessageID - 새로 추가된 첨부파일의 MessageID 수정
			setFormInstanceIDInComFile(isFileUpload, fileInfos, formObj);
					
			if (attachFileInfoObj != null && !attachFileInfoObj.isEmpty()) {
				formData.put("AttachFileInfo", attachFileInfoObj);
				formObj.put("FormData", formData);
			}
		}
		
		if(processDescription != null && !processDescription.isEmpty())
			formObj.put("ProcessDescription", processDescription);
		
		returnObj.put("formObj", formObj);
		returnObj.put("formData", formData);
		returnObj.put("isFile", isFile);
		returnObj.put("attachFileInfoObj", attachFileInfoObj);
		returnObj.put("processDescription", processDescription);
		returnObj.put("strGSubject", strGSubject);
		returnObj.put("isModified", isModified);
		return returnObj;
	}
	
	private boolean updateEditSave(CoviMap paramsObj) {
		boolean insertHistFlag = true;
		CoviMap editHistInfo = new CoviMap();
		CoviMap deleteParam = new CoviMap();
		
		editHistInfo = coviMapperOne.selectOne("form.formhistory.selectEditHistory", paramsObj);
		
		if(editHistInfo != null && !editHistInfo.isEmpty()) insertHistFlag = false;
		coviMapperOne.update("form.formhistory.updateEditHistory", paramsObj);
		
		// 기존에 추가된 APST delete
		deleteParam = (CoviMap) paramsObj.clone();
		deleteParam.put("FieldName", "ApprovalLine");
		coviMapperOne.delete("form.formhistory.deleteEditHistory", deleteParam);
		
		return insertHistFlag;
	}

	// insert/update forminstance table
	private CoviMap setFormInstance(String mode, CoviMap formObj, CoviMap formData, CoviMap processDescription) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviMap params = new CoviMap();
		String processID = Objects.toString(formObj.get("processID"), "0");
		String docClassID = Objects.toString(formData.get("DocClassID"), "");
		if (mode.equals("DRAFT") || mode.equals("TEMPSAVE")) {
			params.put("ProcessID", processID.equals("") ? "0" : processID);
			params.put("FormID", Objects.toString(formObj.get("FormID"), ""));
			params.put("SchemaID", Objects.toString(formObj.get("SchemaID"), ""));
			params.put("Subject", Objects.toString(formData.get("Subject"), ""));
			params.put("InitiatorID", Objects.toString(formData.get("InitiatorID"), ""));
			params.put("InitiatorName", Objects.toString(formData.get("InitiatorName"), ""));
			params.put("InitiatorUnitID", Objects.toString(formData.get("InitiatorUnitID"), ""));
			params.put("InitiatorUnitName", Objects.toString(formData.get("InitiatorUnitName"), ""));
			params.put("LastModifierID", Objects.toString(formData.get("InitiatorID"), ""));
			params.put("EntCode", Objects.toString(formData.get("EntCode"), ""));
			params.put("EntName", Objects.toString(formData.get("EntName"), ""));
			params.put("DocNo", Objects.toString(formData.get("DocNo"), ""));
			params.put("DocLevel", Objects.toString(formData.get("DocLevel"), ""));
			params.put("DocClassID", docClassID.equalsIgnoreCase("undefined") ? "" : docClassID);
			params.put("DocClassName", Objects.toString(formData.get("DocClassName"), ""));
			params.put("DocSummary", Objects.toString(formData.get("DocSummary"), ""));
			params.put("IsPublic", Objects.toString(formData.get("IsPublic"), ""));
			params.put("SaveTerm", Objects.toString(formData.get("SaveTerm"), ""));
			params.put("AttachFileInfo", Objects.toString("", ""));													// attachFileInfoObj를 FormInstacneID가 생성된 후, 가공이 되어야 하므로 우선 빈값으로 값을 넣는다.
			params.put("AppliedDate", Objects.toString(formData.get("AppliedDate"), ""));
			params.put("AppliedTerm", Objects.toString(formData.get("AppliedTerm"), ""));
			params.put("ReceiveNo", Objects.toString(formData.get("ReceiveNo"), ""));
			params.put("ReceiveNames", Objects.toString(formData.get("ReceiveNames"), ""));
			params.put("ReceiptList", Objects.toString(formData.get("ReceiptList"), ""));
			params.put("BodyType", Objects.toString(formObj.get("BodyType"), ""));
			params.put("BodyContext", replaceBodyContext(Objects.toString(formData.getString("BodyContext"), "")));
			params.putOrigin("BodyContextOrg", Objects.toString(formData.getString("BodyContext"), "")); // 본문검색용 필드
			params.put("DocLinks", Objects.toString(formData.get("DocLinks"), ""));
			params.put("EDMSDocLinks", Objects.toString(formData.get("EDMSDocLinks"), ""));	
			params.put("RuleItemInfo", Objects.toString(formData.get("RuleItemInfo"), ""));

			coviMapperOne.insert("form.forminstance.insert", params);
			formObj.put("FormInstID", params.optString("FormInstID"));

			if (!processDescription.isNullObject() && !processDescription.isEmpty()) {
				processDescription.put("FormInstID", params.optString("FormInstID"));
				formObj.put("ProcessDescription", processDescription);
			}
		}
		
		returnObj.put("formObj", formObj);
		returnObj.put("processDescription", processDescription);
		return returnObj;
	}

	private CoviMap setAttachFileInfo(CoviList fileInfos, CoviMap formObj, CoviMap attachFileInfoObj, String isFile, String attachFileInfoStr, boolean isUseMultiEdit) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap formInfoExt = new CoviMap();

		
		CoviMap params = new CoviMap();
		// if(attachFileInfoObj != null && !attachFileInfoObj.isNullObject()){
		if ((fileInfos != null && !fileInfos.isEmpty()) || (formObj.getString("mode").equals("APPROVAL") && attachFileInfoStr != null && attachFileInfoStr.equals("")) ) {
			// attachFileInfoObj를 가공 후, formInstance에서 update
			// 일괄기안 처리를 위한 idx
			String tableidx = "";
			// FormInstID 삽입과 실제 경로 데이터 삽입.
			if(attachFileInfoStr == null){
				CoviList arrObj = new CoviList();
				if (attachFileInfoObj.has("FileInfos") && !attachFileInfoObj.getJSONArray("FileInfos").isEmpty() && !attachFileInfoObj.isEmpty()) {
					for(Object obj : fileInfos){
						CoviMap attfile = (CoviMap) obj;
						attfile.put("MessageID", formObj.getString("FormInstID"));
						// 일괄기안 처리를 위한 idx
						tableidx = attfile.getString("ObjectID");
						
						arrObj.add(attfile);
					}
						
					attachFileInfoObj.put("FileInfos", arrObj);
				}

				if(formObj.has("AttachFileSeq") && !formObj.getString("AttachFileSeq").equals("")) {
					String[] seqArr = formObj.getString("AttachFileSeq").split("\\|");					
					String regExp = "insert\\s+|update\\s+|delete\\s+|having\\s+|drop\\s+|(\'|%27).(and|or).(\'|%27)|(\'|%27).%7C{0,2}|%7C{2}";
					CoviList arrObj2 = new CoviList();					
					for(String seqInfo : seqArr) {						
						for(Object obj : attachFileInfoObj.getJSONArray("FileInfos")) {
							CoviMap jsonObj = (CoviMap) obj;							
							if(jsonObj.getString("FileName").replaceAll(regExp, "").equals(seqInfo.split(":")[3])) {
								jsonObj.put("Seq", seqInfo.split(":")[1]);
								// 일괄기안 처리를 위한 idx
								tableidx = jsonObj.getString("ObjectID");
								arrObj2.add(jsonObj);
							}
						}
					}
					attachFileInfoObj.put("FileInfos", arrObj2);
				}
				
				isFile = "true";
			}else{
				isFile = "false";
			}

			params.clear();
			params.put("FormInstID", formObj.get("FormInstID"));
			if(attachFileInfoStr != null) {
				params.put("AttachFileInfo", "");
			} else {
				if(attachFileInfoObj != null)
					params.put("AttachFileInfo", replaceBodyContext(attachFileInfoObj.toString()));
				else 
					params.put("AttachFileInfo", null);
			}			
			
			formInfoExt = formObj.getJSONObject("FormInfoExt");
			String subTable1 = formInfoExt.getString("SubTable1");


			if (isUseMultiEdit) {
				params.put("SEQ", tableidx);
				
				// 다안기안 시 subtable
				String tableName = subTable1;
				if (formObj.getJSONObject("FormInfoExt").optString("IsGovMulti").equalsIgnoreCase("true")) {
					CoviMap subTableParams = new CoviMap();
					subTableParams.put("FormID", formObj.optString("FormID"));
					CoviMap selectSubTableResult = coviMapperOne.select("form.forms.select", subTableParams);
					CoviMap extInfo = CoviSelectSet.coviSelectJSON(selectSubTableResult, "FormID,ExtInfo").getJSONObject(0);
					extInfo = extInfo.getJSONObject("ExtInfo");
					tableName = extInfo.optString("SubTable1");
				}
				params.put("tableName", tableName);
				
				coviMapperOne.update("form.forminstance.updateAttachFileInfoSubTable", params);
				// 안별 전체파일 정보를  jwf_forminstance 에 업데이트 처리한다.
				if(formObj.has("__totalFileInfoJson__")) {
					CoviMap attachTotalInfo = (CoviMap)formObj.get("__totalFileInfoJson__");
					
					Iterator<String> keys = attachTotalInfo.keySet().iterator();
					
					CoviList arr = new CoviList();
					while (keys.hasNext()) {
						String fileConkey = keys.next();
						CoviList fileArr = attachTotalInfo.getJSONArray(fileConkey);
						for(int i = 0; i < fileArr.size(); i++) {
							CoviMap o = fileArr.getJSONObject(i);
							o.put("MessageID", formObj.getString("FormInstID"));
							o.remove("FileToken");
							arr.add(o);
						}
					}
					CoviMap fo = new CoviMap();
					fo.put("FileInfos", arr);
					params.put("AttachFileInfo", replaceBodyContext(fo.toString()));
					
				}
			}
			// 수정된 날짜, id 추가
			coviMapperOne.update("form.forminstance.updateAttachFileInfo", params);
			
			if(attachFileInfoStr == null) {
				fileUtilSvc.updateFileSeq(attachFileInfoObj); //sys_file 내 seq 수정
			}
		}
		
		returnObj.put("attachFileInfoObj", attachFileInfoObj);
		returnObj.put("isFile", isFile);
		return returnObj;
	}

	// update com_file
	private void setFormInstanceIDInComFile(Boolean isFileUpload, CoviList fileInfos, CoviMap formObj) throws Exception {
		CoviMap params = new CoviMap();

		if (isFileUpload != null && isFileUpload) {
			for (Object Obj : fileInfos) {
				CoviMap fileInfoObj = (CoviMap) Obj;

				params.put("ServiceType", Objects.toString(fileInfoObj.optString("ServiceType"), "Approval"));
				params.put("ObjectType", Objects.toString(fileInfoObj.optString("ObjectType"), "Dept"));
				params.put("SavedName", Objects.toString(fileInfoObj.optString("SavedName"), ""));
				params.put("RegisterCode", Objects.toString(fileInfoObj.optString("RegisterCode"), ""));
				params.put("MessageID", Objects.toString(formObj.get("FormInstID"), ""));

				coviMapperOne.update("framework.FileUtil.updateMessageID", params);
			}
		}
	}
	
	private CoviMap setSubTable(CoviMap bodyData, CoviMap formObj) throws Exception {
		//공공버전 하위테이블 관련
		String strDBType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		
		if (bodyData != null && !bodyData.isEmpty()) {
			CoviMap mainTable = bodyData.has("MainTable") ? bodyData.getJSONObject("MainTable") : null;
			CoviList subTable1 = bodyData.has("SubTable1") ? bodyData.getJSONArray("SubTable1") : null;
			CoviList subTable2 = bodyData.has("SubTable2") ? bodyData.getJSONArray("SubTable2") : null;
			CoviList subTable3 = bodyData.has("SubTable3") ? bodyData.getJSONArray("SubTable3") : null;
			CoviList subTable4 = bodyData.has("SubTable4") ? bodyData.getJSONArray("SubTable4") : null;

			if ((mainTable != null && !mainTable.isEmpty())
					|| (subTable1 != null && !subTable1.isEmpty())
					|| (subTable2 != null && !subTable2.isEmpty())
					|| (subTable3 != null && !subTable3.isEmpty())
					|| (subTable4 != null && !subTable4.isEmpty())) {
				String tableName;

				CoviMap paramsJson = new CoviMap();
				CoviMap paramsJsonForGovSub = new CoviMap();
				CoviMap paramsMap = new CoviMap();

				paramsMap.put("FormID", formObj.optString("FormID"));

				CoviMap selectResult = coviMapperOne.select("form.forms.select", paramsMap);

				CoviMap extInfo = CoviSelectSet.coviSelectJSON(selectResult, "FormID,ExtInfo").getJSONObject(0);
				extInfo = extInfo.getJSONObject("ExtInfo");

				CoviMap subTableInfo = CoviSelectSet.coviSelectJSON(selectResult, "SubTableInfo").getJSONObject(0).getJSONObject("SubTableInfo");

				Iterator<?> keys = bodyData.keys();

				while (keys.hasNext()) {
					paramsJson.clear();

					CoviList subTableValues = new CoviList();

					String key = (String) keys.next();
					tableName = extInfo.getString(key);

					// 임시저장 후 기안 시 기존 데이터 삭제처리
					if (formObj.has("DeleteTempFormInstID") && !formObj.getString("DeleteTempFormInstID").isEmpty()) {
						paramsJson.clear();
						paramsJson.put("tableName", tableName);
						paramsJson.put("formInstID", formObj.getString("DeleteTempFormInstID"));
						coviMapperOne.delete("form.subtable.deleteData", paramsJson);
					}
					
					// 같은 instance에 등록된 서브테이블 데이터 삭제(중간에 데이터 변경시)
					paramsJson.clear();
					paramsJson.put("tableName", tableName);
					paramsJson.put("formInstID", formObj.getString("FormInstID"));
					coviMapperOne.delete("form.subtable.deleteData", paramsJson);

					if (key.equals("MainTable")) {
						subTableValues.add(bodyData.getJSONObject(key));
					} else {
						subTableValues = bodyData.getJSONArray(key);
					}
					
					if(tableName.equals("HWP_MULTI_GOV_SUB") && strDBType.equalsIgnoreCase("oracle")){ // oracle clob insert 오류로 별도처리
						paramsJsonForGovSub.put("FormInstID", formObj.getString("FormInstID"));
					}
										
					for (Object obj : subTableValues) {
						if (obj instanceof CoviMap) {
							List<HashMap<String, String>> params = new ArrayList<>();  
							params.add(new HashMap<String, String>() {{
								put("key", "FormInstID");
								put("value", formObj.getString("FormInstID"));
							}});
							
							// ROWSEQ 컬럼은 SubTable 최초 생성될때 하드코딩으로 자동 추가되는 구조
							if (!key.equals("MainTable")) {
								params.add(new HashMap<String, String>() {{
									put("key", "ROWSEQ");
									put("value", ((CoviMap) obj).getString("ROWSEQ").replaceAll("'", "''").replaceAll("\\\\", "\\\\\\\\"));
								}});
							}

							for(Object o : subTableInfo.getJSONArray(key)) {
								CoviMap _jO = (CoviMap) o;
								String columnKey = _jO.getString("FieldName");

								if(!columnKey.isEmpty() && ((CoviMap) obj).containsKey(columnKey) && !columnKey.equalsIgnoreCase("ROWSEQ")) {
									HashMap<String, String> param = new HashMap<>();
									param.put("key", columnKey);
									param.put("value", ((CoviMap) obj).getString(columnKey).replace("'", "''").replace("\\\\", "\\\\\\\\"));
									params.add(param);
								
								if(tableName.equals("HWP_MULTI_GOV_SUB") && strDBType.equalsIgnoreCase("oracle")){ // oracle clob insert 오류로 별도처리
									paramsJsonForGovSub.put(columnKey, Objects.toString(((CoviMap) obj).getString(columnKey).replace("'", "''").replace("\\\\", "\\\\\\\\"), ""));
								}
								
							}
						}

							// insert
							paramsJson.clear();
							paramsJson.put("tableName",tableName);
							paramsJson.put("insertData",params);

							if(tableName.equals("HWP_MULTI_GOV_SUB") && strDBType.equalsIgnoreCase("oracle")){ // oracle clob insert 오류로 별도처리
								coviMapperOne.insert("form.subtable.insertMultiDraft_sub", paramsJsonForGovSub);
							} else {
								coviMapperOne.insert("form.subtable.insertOneData", paramsJson);
							}

						}
					}
				}
			}
			formObj.remove("BodyData");
		}
		// 마스터/서브테이블 처리 종료
		
		return formObj;
	}
	
	// 임시저장 데이터
	private CoviMap doTempSave(String mode, CoviMap formObj, CoviMap formData, CoviMap bodyData, CoviMap approvalLine, CoviMap attachFileInfoObj, CoviList fileInfos, CoviMap fileInfosObj, Boolean isFileUpload) throws Exception {
		String subject = formData.getString("Subject");
		String formTempInstBoxID = formObj.getString("FormTempInstBoxID");
		
		boolean isUseMultiEdit = false;

		if (formObj.has("FormInfoExt")) {
			CoviMap formInfoExt = CoviMap.fromObject(formObj.optString("FormInfoExt"));

			if (formInfoExt != null && formInfoExt.has("IsUseMultiEdit") && formInfoExt.getString("IsUseMultiEdit").equals("Y")) {
				isUseMultiEdit = true;
			}
		}

		// 임시함에서 열었을 경우, Update
		if (mode.equals("TEMPSAVE")) {
			// 1. 임시저장 본문 데이터 update
			updateFormContextData(formObj, formData);
			formObj = setSubTable(bodyData, formObj); // 하위테이블 Insert

			// 2. 임시저장 양식 insert 및 update
			updateTempDataList(formTempInstBoxID, subject); // 임시함에서 임시저장

		} else if (mode.equals("DRAFT")) {
			// 1. 임시저장 본문 데이터 insert
			CoviMap setFormInstanceReturn = setFormInstance(mode, formObj, formData, new CoviMap());
			formObj = setFormInstanceReturn.getJSONObject("formObj");
			
			formObj = setSubTable(bodyData, formObj); // 하위테이블 Insert

			// 2. 임시저장 양식 insert
			formObj = insertTempListData(formObj, formData); // 기안 창에서 임시저장
			formTempInstBoxID = formObj.getString("FormTempInstBoxID");
		}

		if (isUseMultiEdit) {
			if(attachFileInfoObj != null) {
				Iterator<String> keys = attachFileInfoObj.keySet().iterator();
			
				int itIdx = 0;
				int itLength = attachFileInfoObj.keySet().size();
				while(keys.hasNext()){
					String fileConkey = keys.next();
					CoviList fileInfo = (CoviList) fileInfosObj.get("MultifileData_" + fileConkey);
					CoviMap tmpAttachFileInfoObj = null;
					
					if(!(attachFileInfoObj.get(fileConkey) == null || attachFileInfoObj.get(fileConkey).equals(""))) {
						tmpAttachFileInfoObj = attachFileInfoObj.getJSONObject(fileConkey);
					}
					
					if(fileInfo == null || fileInfo.isEmpty()) {
						if(tmpAttachFileInfoObj != null && tmpAttachFileInfoObj.has("FileInfos")) {
							fileInfo = CoviList.fromObject(tmpAttachFileInfoObj.get("FileInfos"));
						}
					}
					
					// 첨부파일이 있을 경우 formInstance에 저장
					if(itIdx == itLength - 1) {
						formObj.put("__totalFileInfoJson__", fileInfosObj);
					}
					CoviMap setAttachFileInfoReturn = null;
					try {
						setAttachFileInfoReturn = setAttachFileInfo(fileInfo, formObj, tmpAttachFileInfoObj, "", null, isUseMultiEdit);
					}finally {
						formObj.remove("__totalFileInfoJson__");
					}
					attachFileInfoObj.put(fileConkey, setAttachFileInfoReturn.getJSONObject("attachFileInfoObj"));
			
					// com_file messageID Update
					setFormInstanceIDInComFile(isFileUpload, fileInfo, formObj);
					itIdx ++;
				}
			}
		} else {
			// 첨부파일이 있을 경우 formInstance에 저장
			CoviMap setAttachFileInfoReturn = setAttachFileInfo(fileInfos, formObj, attachFileInfoObj, "", null, isUseMultiEdit);
			attachFileInfoObj = setAttachFileInfoReturn.getJSONObject("attachFileInfoObj");
	
			// com_file messageID Update
			setFormInstanceIDInComFile(isFileUpload, fileInfos, formObj);
		}

		// 3. 임시저장된 결재선 조회
		if (getPrivateDomainData(formTempInstBoxID) == 0) {
			// 조회되는 결재선이 없을 경우 insert
			insertPrivateDomainData(formObj, subject, approvalLine);
		} else if (getPrivateDomainData(formTempInstBoxID) > 0) {
			if (approvalLine != null && approvalLine.size() > 0) // 조회되는 결재선이 있고, 임시저장할 결재선이 있을 경우, update
				updatePrivateDomainData(formObj, approvalLine, subject);
			else
				// 조회되는 결재선이 있고, 임시저장할 결재선이 없을 경우, delete
				deletePrivateDomainData(formTempInstBoxID);
		}
		
		return formObj;
	}
	
	private void updateFormContextData(CoviMap formObj, CoviMap formData) throws Exception {
		CoviMap params = new CoviMap();

		params.put("FormInstID", Objects.toString(formObj.get("FormInstID"), ""));
		params.put("LastModifierID", Objects.toString(formData.get("InitiatorID"), ""));
		params.put("DocNo", Objects.toString(formData.get("DocNo"), ""));
		params.put("DocLevel", Objects.toString(formData.get("DocLevel"), ""));
		params.put("DocClassID", Objects.toString(formData.get("DocClassID"), ""));
		params.put("DocClassName", Objects.toString(formData.get("DocClassName"), ""));
		params.put("DocSummary", Objects.toString(formData.get("DocSummary"), ""));
		params.put("IsPublic", Objects.toString(formData.get("IsPublic"), ""));
		params.put("SaveTerm", Objects.toString(formData.get("SaveTerm"), ""));
		params.put("AttachFileInfo", replaceBodyContext(Objects.toString(formData.get("AttachFileInfo"), "")));
		params.put("ReceiveNo", Objects.toString(formData.get("ReceiveNo"), ""));
		params.put("ReceiveNames", Objects.toString(formData.get("ReceiveNames"), ""));
		params.put("ReceiptList", Objects.toString(formData.get("ReceiptList"), ""));
		params.put("BodyContext", Objects.toString(replaceBodyContext(formData.getString("BodyContext")), ""));
		params.put("DocLinks", Objects.toString(formData.get("DocLinks"), ""));
		params.put("EDMSDocLinks", Objects.toString(formData.get("EDMSDocLinks"), ""));	
		params.put("Subject", Objects.toString(formData.get("Subject"), ""));
		params.put("RuleItemInfo", Objects.toString(formData.get("RuleItemInfo"), ""));

		coviMapperOne.update("form.forminstance.update", params);
	}

	
	private CoviMap insertTempListData(CoviMap formObj, CoviMap formData) throws NullPointerException {
		CoviMap params = new CoviMap();

		params.put("FormInstID", Objects.toString(formObj.get("FormInstID"), ""));
		params.put("FormID", Objects.toString(formObj.get("FormID"), ""));
		params.put("SchemaID", Objects.toString(formObj.get("SchemaID"), ""));
		params.put("FormPrefix", Objects.toString(formObj.get("FormPrefix"), ""));
		params.put("FormInstTableName", "jwf_formstempinstbox");
		params.put("UserCode", Objects.toString(formData.get("InitiatorID"), ""));
		params.put("Subject", Objects.toString(formData.get("Subject"), ""));
		params.put("Kind", "T");

		coviMapperOne.insert("form.formstempinstbox.insertFromForminstanceT", params);
		formObj.put("FormTempInstBoxID", params.optString("FormTempInstBoxID"));

		return formObj;
	}
	
	private void updateTempDataList(String formTempInstBoxID, String subject) throws Exception {
		CoviMap params = new CoviMap();

		params.put("FormTempInstBoxID", Objects.toString(formTempInstBoxID, ""));
		params.put("Subject", Objects.toString(subject, ""));

		coviMapperOne.insert("form.formstempinstbox.updateFromForminstanceT", params);
	}

	private int getPrivateDomainData(String formTempInstBoxID) {
		CoviMap params = new CoviMap();

		params.put("OwnerID", Objects.toString(formTempInstBoxID, ""));

		return coviMapperOne.selectOne("form.privatedomaindata.selectCountTemp", params);
	}

	private void insertPrivateDomainData(CoviMap formObj, String subject, CoviMap approvalLine) throws Exception {
		CoviMap params = new CoviMap();

		params.put("CustomCategory", "APPROVERCONTEXT");
		params.put("DefaultYN", null);
		params.put("DisplayName", Objects.toString(formObj.get("usdn") + "-" + formObj.get("FormName"), ""));
		params.put("OwnerID", Objects.toString(formObj.get("FormTempInstBoxID"), ""));
		params.put("Abstract", "");
		params.put("Description", Objects.toString(subject, ""));
		params.put("PrivateContext", approvalLine.toString());

		coviMapperOne.insert("form.privatedomaindata.insert", params);
	}

	private void updatePrivateDomainData(CoviMap formObj, CoviMap approvalLine, String subject) throws Exception {
		CoviMap params = new CoviMap();

		params.put("OwnerID", Objects.toString(formObj.get("FormTempInstBoxID"), ""));
		params.put("Description", Objects.toString(subject, ""));
		params.put("DisplayName", Objects.toString(formObj.get("usdn") + "-" + formObj.get("FormName"), ""));
		params.put("PrivateContext", approvalLine.toString());

		coviMapperOne.update("form.privatedomaindata.update", params);
	}

	private int deletePrivateDomainData(String formTempInstBoxID) throws Exception {
		CoviMap params = new CoviMap();

		params.put("OwnerID", Objects.toString(formTempInstBoxID, ""));

		return coviMapperOne.delete("form.privatedomaindata.delete", params);
	}
	
	/**
	 * BodyContext 내 임시성 데이터 삭제 
	 * @param pBodycontext
	 * @throws Exception
	 */
	private CoviMap deleteBodyContextTempData(CoviMap pBodycontext) {
		CoviMap returnData = pBodycontext;

		returnData.remove("TempUseScrecy");
		returnData.remove("TempUseUrgent");
		returnData.remove("TempUseReserveDraft");
		returnData.remove("TempUseReserveDist");
		returnData.remove("reservedDate");
		returnData.remove("reservedHour");
		returnData.remove("reservedHour_TEXT");
		returnData.remove("reservedMin");
		returnData.remove("reservedMin_TEXT");
		returnData.remove("distReservedDate");
		returnData.remove("distReservedHour");
		returnData.remove("distReservedHour_TEXT");
		returnData.remove("distReservedMin");
		returnData.remove("distReservedMin_TEXT");
		
		return returnData;
	}
	
	private void insertRecordDocInfoData(CoviMap formObj, CoviMap formData) throws Exception {
		CoviMap params = new CoviMap();
		CoviMap RecordDocInfo = formData.getJSONObject("RecordDocInfo");

		params.put("FormInstId", formObj.getString("FormInstID"));
		params.put("ProcessId", formObj.getString("processID").equals("") ? "0" : formObj.getString("processID"));
		params.put("State", formObj.getString("processID").equals("") ? "I" : "P");
		params.put("RecordSubject", RecordDocInfo.getString("RECORD_SUBJECT"));
		params.put("RecordClassNum", RecordDocInfo.getString("RECORD_CLASS_NUM"));
		params.put("RegistCheck", RecordDocInfo.getString("REGIST_CHECK"));
		params.put("SpecialRecord", RecordDocInfo.getString("SPECIAL_RECORD"));
		params.put("KeepPeriod", RecordDocInfo.getString("KEEP_PERIOD"));
		params.put("ReleaseCheck", RecordDocInfo.getString("RELEASE_CHECK"));
		params.put("SecureLevel", RecordDocInfo.getString("SECURE_LEVEL"));

		coviMapperOne.insert("form.recorddocinfo.insert", params);
	}
	
	private void updateRecordDocInfoData(CoviMap formObj, CoviMap formData) throws Exception {
		CoviMap params = new CoviMap();
		CoviMap RecordDocInfo = formData.getJSONObject("RecordDocInfo");

		params.put("FormInstId", formObj.getString("FormInstID"));
		params.put("ProcessId", formObj.getString("processID").equals("") ? "0" : formObj.getString("processID"));
		params.put("State", formObj.getString("processID").equals("") ? "I" : "P");
		params.put("RecordSubject", RecordDocInfo.getString("RECORD_SUBJECT"));
		params.put("RecordClassNum", RecordDocInfo.getString("RECORD_CLASS_NUM"));
		params.put("RegistCheck", RecordDocInfo.getString("REGIST_CHECK"));
		params.put("SpecialRecord", RecordDocInfo.getString("SPECIAL_RECORD"));
		params.put("KeepPeriod", RecordDocInfo.getString("KEEP_PERIOD"));
		params.put("ReleaseCheck", RecordDocInfo.getString("RELEASE_CHECK"));
		params.put("SecureLevel", RecordDocInfo.getString("SECURE_LEVEL"));

		coviMapperOne.update("form.recorddocinfo.updateRecordDocInfo", params);
	}
	
	@Override
	public void setPrivateDomainDataForDraft(CoviMap fParams) throws Exception{
		CoviMap paramsObj = new CoviMap();
		String mode = fParams.getString("mode");
		CoviMap approvalLine = fParams.getJSONObject("approvalLine");
		if (mode.equals("DRAFT") || mode.equals("TEMPSAVE") || mode.equals("REDRAFT")) {
			
			CoviMap apvLineObj = new CoviMap();

			String formSubject = fParams.getString("FormSubject");
			String formName = fParams.getString("FormName");
			String usid = fParams.getString("usid");
			String usnm = fParams.getString("usdn");
			String formPrefix = fParams.getString("FormPrefix");
			String ownerID = usid + "_" + formPrefix;
			int countPrivatDomain = 0;

			if (mode.equals("REDRAFT")) {
				ownerID = ownerID + "_REDRAFT";
			}

			// 기안자의 데이터 제외하고 insert / update
			// 전결일 경우 해당 데이터 삭제
			boolean isDelete = false;
			apvLineObj = CoviMap.fromObject(approvalLine.toString());
			if (apvLineObj.getJSONObject("steps").get("division") instanceof CoviMap){
				if (apvLineObj.getJSONObject("steps").getJSONObject("division").get("step") instanceof CoviMap) {
					isDelete = true;
				}else {
					apvLineObj.getJSONObject("steps").getJSONObject("division").getJSONArray("step").remove(0);
				}
			}
			else if (apvLineObj.getJSONObject("steps").get("division") instanceof CoviList){
				int divisionIdx = 0;
				CoviList arrDivision = apvLineObj.getJSONObject("steps").getJSONArray("division");
				
				// 완료된 division 삭제 [2021-03-26 add]
				for(int i = 0; i < arrDivision.size(); i++) {
					// divisiontype='receive' 일 경우 삭제
					String sDivisionStatus = arrDivision.getJSONObject(i).getJSONObject("taskinfo").getString("status");
					
					if(sDivisionStatus.equalsIgnoreCase("completed")) {
						apvLineObj.getJSONObject("steps").getJSONArray("division").remove(i);
					}							
				}
				
				if(((CoviMap) arrDivision.get(divisionIdx)).get("step") instanceof CoviMap) {
					isDelete = true;
				}else {					
					((CoviMap) arrDivision.get(divisionIdx)).getJSONArray("step").remove(0);
				}
				// 기안시 처리부서 division 삭제 [2021-03-26 add]
				if(mode.equals("DRAFT")) {
					for(int i = 0; i < arrDivision.size(); i++) {
						// divisiontype='receive' 일 경우 삭제
						String sDivisionType = arrDivision.getJSONObject(i).getString("divisiontype");
						
						if(sDivisionType.equalsIgnoreCase("receive")) {
							arrDivision.remove(i);
						}							
					}
				}
			}

			if(isDelete){
				paramsObj.put("OwnerID", ownerID);
				coviMapperOne.delete("form.privatedomaindata.delete", paramsObj);
			}else{
				// 참조 데이터 제외하고 insert / update
				apvLineObj.getJSONObject("steps").remove("ccinfo");
	
				// 해당 ownerID 로 조회했을 경우, 데이터가 있으면 update, 없으면 insert
				paramsObj.put("OwnerID", ownerID);
				countPrivatDomain = coviMapperOne.selectOne("form.privatedomaindata.selectCountTemp", paramsObj);
	
				paramsObj.clear();
				paramsObj.put("CustomCategory", "APPROVERCONTEXT");
				paramsObj.put("DefaultYN", null);
				paramsObj.put("DisplayName", usnm + "-" + formName);
				paramsObj.put("OwnerID", ownerID);
				paramsObj.put("Abstract", "");
				paramsObj.put("Description", formSubject);
				paramsObj.put("PrivateContext", apvLineObj.toString());
	
				if (countPrivatDomain > 0) {
					coviMapperOne.update("form.privatedomaindata.update", paramsObj);
				} else {
					coviMapperOne.insert("form.privatedomaindata.insert", paramsObj);
				}
			}
		}
	}

	@Override
	public void updateFormInstDocNumber(String formInstID) throws Exception {
		// Process Description의 Reverse1값 Select 후 FormInstance의 DocNo에 Insert
		// Process Description의 Reverse2값 Select 후 FormInstance의 ReceiveNo에 Insert
		CoviMap params = new CoviMap();
		String reserved1 = "";
		String reserved2 = "";

		params.put("FormInstID", formInstID);
		CoviMap list = coviMapperOne.select("form.processdescription.selectReservedData", params);
		CoviMap listObj = CoviSelectSet.coviSelectJSON(list, "Reserved1,Reserved2").getJSONObject(0);
		
		if (listObj.size() > 0) {
			reserved1 = listObj.optString("Reserved1");
			reserved2 = listObj.optString("Reserved2");
		}

		params.clear();

		if (!"".equals(reserved1) || !"".equals(reserved2)) {
			params.put("Reserved1", reserved1);
			params.put("Reserved2", reserved2);
			params.put("FormInstID", formInstID);
			coviMapperOne.update("form.forminstance.updateDocNo", params);
		}
	}

	// 자동승인 된 문서 표시하기.
	@Override
	public void updateMarkAutoApprove(String taskID, String mark) throws Exception {
		CoviMap params = new CoviMap();
		params.put("taskID", taskID);
		params.put("BusinessData4", mark);
		coviMapperOne.update("form.ApvProcess.updateBusinessDataAuto", params);
	} 
	
	// 승인 - 사용자 전자결재 비밀번호 확인
	@Override
	public boolean chkCommentWrite(String userCode, String password) throws Exception{
		CoviMap params = new CoviMap();

		params.put("UR_Code", userCode);
		params.put("ApprovalPassword", password);
		params.put("aeskey", PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key")));
		
		int cnt = (int) coviMapperOne.getNumber("form.org_person.selectApprovalPassword", params);
		
		return (cnt > 0);
	}

	// 보류
	@Override
	public void doReserve(CoviMap formObj) throws Exception {

		if (formObj.has("processID") && formObj.has("parentprocessID")) {
			String domainData = "";

			List<String> processIDs = new ArrayList<>();
			if (!formObj.getString("processID").equals("0")) {
				processIDs.add(formObj.getString("processID"));
			}
			if (!formObj.getString("parentprocessID").equals("0")) {
				processIDs.add(formObj.getString("parentprocessID"));
			}

			CoviMap params = new CoviMap();
			
			params.put("processID", formObj.getString("processID"));
			params.put("IsArchived", "false");
        	
        	CoviList list = coviMapperOne.list("form.formLoad.selectDomainData", params);
        	
			CoviMap domainObj = CoviSelectSet.coviSelectJSON(list, "DomainDataID,DomainDataName,ProcessID,DomainDataContext").getJSONObject(0);
			
			String strUserCode = SessionHelper.getSession("UR_Code");
			String strUserName = SessionHelper.getSession("USERNAME");
			String strComment = formObj.optString("actionComment");
			String strInitiatorCode = "";
			
			CoviList messageInfos = new CoviList();
			CoviMap processDesObj = (CoviMap)formObj.get("ProcessDescription");
			
			if(!domainObj.get("DomainDataContext").equals("")) {
				domainData = domainObj.getString("DomainDataContext");
				CoviMap apvLineObj = CoviMap.fromObject(domainData);
				
				//보류 결재선 수정
				CoviMap root = (CoviMap)apvLineObj.get("steps");
				Object divisionObj = root.get("division");
				CoviList divisions = new CoviList();
				if(divisionObj instanceof CoviMap){
					CoviMap divisionJsonObj = (CoviMap)divisionObj;
					divisions.add(divisionJsonObj);
				} else {
					divisions = (CoviList)divisionObj;
				}
				
				for(int i = 0; i < divisions.size(); i++)
				{
					CoviMap division = (CoviMap)divisions.get(i);
					CoviMap taskObject = (CoviMap)division.get("taskinfo");
					
					if(taskObject.optString("status").equalsIgnoreCase("pending")) {
						Object stepO = division.get("step");
						CoviList steps = new CoviList();
						if(stepO instanceof CoviMap){
							CoviMap stepJsonObj = (CoviMap)stepO;
							steps.add(stepJsonObj);
						} else {
							steps = (CoviList)stepO;
						}
						
						for(int j = 0; j < steps.size(); j++)
						{
							CoviMap s = (CoviMap)steps.get(j);
							
							//jsonarray와 jsonobject 분기 처리
							Object ouObj = s.get("ou");
							CoviList ouArray = new CoviList();
							if(ouObj instanceof CoviList){
								ouArray = (CoviList)ouObj;
							} else {
								ouArray.add(ouObj);
							}
							
							for(int z = 0; z < ouArray.size(); z++)
							{
								CoviMap ouObject = (CoviMap)ouArray.get(z);
								
								if(ouObject.containsKey("person")){
									Object personObj = ouObject.get("person");
									CoviList persons = new CoviList();
									if(personObj instanceof CoviMap){
										CoviMap jsonObj = (CoviMap)personObj;
										persons.add(jsonObj);
									} else {
										persons = (CoviList)personObj;
									}
									
									for(int pIdx = 0; pIdx < persons.size(); pIdx++)
									{
										CoviMap personObject = (CoviMap)persons.get(pIdx);
										taskObject = (CoviMap)personObject.get("taskinfo");
	
										if(i==0 && taskObject.getString("kind").equalsIgnoreCase("charge")) { // 발신부서 기안자 코드 저장
											strInitiatorCode = personObject.getString("code");
										}
										
										if(taskObject.getString("result").equals("pending")
											&& formObj.getString("actionUser").equalsIgnoreCase(personObject.getString("code"))) {
											taskObject.put("result", "reserved");
											taskObject.put("status", "reserved");
											taskObject.put("datecompleted", ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss")));
											
											CoviMap comment = new CoviMap();
											comment.put("#text", strComment);
											taskObject.put("comment", comment); // 작업필요
											
											CoviMap commentObject = (CoviMap)taskObject.get("comment");
											
											commentObject.put("relatedresult", "reserved");
											commentObject.put("reservecode", strUserCode);
											
											personObject.remove("taskinfo");
											personObject.put("taskinfo", taskObject);

											ouObject.remove("person");
											if(persons.size() > 1) {
												ouObject.put("person", persons);
											} else {
												ouObject.put("person", persons.get(0));
											}										
										}

										
										// 보류 알림 발송용 파라미터 구성
										if(taskObject.getString("result").equalsIgnoreCase("pending") || taskObject.getString("result").equalsIgnoreCase("completed")) {
											CoviMap messageInfo = new CoviMap();
											
											messageInfo.put("UserId", personObject.getString("code"));
											messageInfo.put("Subject", processDesObj.getString("FormSubject"));
											messageInfo.put("Initiator", strInitiatorCode);
											messageInfo.put("Status", "HOLD"); 
											messageInfo.put("ProcessId", division.getString("processID")); 
											if(ouObject.containsKey("wiid")) {
												messageInfo.put("WorkitemId", ouObject.getString("wiid"));
											} else {
												messageInfo.put("WorkitemId", "");
											}
											messageInfo.put("FormInstId", formObj.getString("FormInstID"));
											messageInfo.put("FormName", formObj.getString("FormName"));
											messageInfo.put("Type", "UR");
											
											messageInfo.put("ApproveCode", strUserCode);
											messageInfo.put("SenderID", formObj.getString("actionUser"));
											
											messageInfo.put("Comment", new String(Base64.decodeBase64(strComment.getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
											
											messageInfos.add(messageInfo);	
										}
									}
								} else if(ouObject.containsKey("role")) { // 담당업무함도 보류 가능해야 함.
									CoviMap role = new CoviMap();
									role = (CoviMap)ouObject.get("role");
									taskObject = (CoviMap)role.get("taskinfo");
									
									if(taskObject.getString("result").equals("pending")
										&& formObj.getString("actionUser").equalsIgnoreCase(role.getString("code"))) {
										taskObject.put("result", "reserved");
										taskObject.put("status", "reserved");
										taskObject.put("datecompleted", ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss")));
										
										CoviMap comment = new CoviMap();
										comment.put("#text", strComment);
										taskObject.put("comment", comment); // 작업필요
										
										CoviMap commentObject = (CoviMap)taskObject.get("comment");
										
										commentObject.put("relatedresult", "reserved");
										commentObject.put("reservecode", strUserCode);
										commentObject.put("reservename", strUserName);
										
										role.remove("taskinfo");
										role.put("taskinfo", taskObject);
										
										ouObject.remove("role");
										ouObject.put("role", role);
									}
									
									// 보류 알림 발송용 파라미터 구성
									if(taskObject.getString("result").equalsIgnoreCase("pending") || taskObject.getString("result").equalsIgnoreCase("completed")) {
										CoviMap messageInfo = new CoviMap();
										
										messageInfo.put("UserId", role.getString("code"));
										messageInfo.put("Subject", processDesObj.getString("FormSubject"));
										messageInfo.put("Initiator", strInitiatorCode);
										messageInfo.put("Status", "HOLD"); 
										messageInfo.put("ProcessId", division.getString("processID")); 
										messageInfo.put("WorkitemId", ouObject.getString("wiid"));
										messageInfo.put("FormInstId", formObj.getString("FormInstID"));
										messageInfo.put("FormName", formObj.getString("FormName"));
										messageInfo.put("Type", "UR");
										
										messageInfo.put("ApproveCode", strUserCode);
										messageInfo.put("SenderID", formObj.getString("actionUser"));
										
										messageInfo.put("Comment", new String(Base64.decodeBase64(strComment.getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
										
										messageInfos.add(messageInfo);	
									}
								}
								
								s.remove("ou");
								if(ouArray.size() > 1) {
									s.put("ou", ouArray);
								} else {
									s.put("ou", ouArray.get(0));
								}
							}	      
						}
						
						division.remove("step");
						if(steps.size() > 1) {
							division.put("step", steps);
						} else {
							division.put("step", steps.get(0));
						}
					}
				}
				
				root.remove("division");
				if(divisions.size() > 1) {
					root.put("division", divisions);
				} else {
					root.put("division", divisions.get(0));
				}
				
				apvLineObj.put("steps", root);
				domainData = apvLineObj.toString();

				// 결재선 변경 후 저장
				params.clear();
				params.put("processIDs", processIDs);
				params.put("DomainDataContext", domainData);

				coviMapperOne.update("form.formdomaindata.updateDomainDataIN", params);
			}

			// Process Description 데이터 변경
			params.clear();
			params.put("processIDs", processIDs);
			params.put("IsReserved", "Y");
			if(strComment != null && !strComment.isEmpty()) params.put("IsComment", "Y");

			coviMapperOne.update("form.processdescription.updateProcessID", params);
			
			// 엔진 호출
			String taskID = formObj.optString("taskID");
			
			if(!taskID.isEmpty()) {
				CoviMap variableObj = new CoviMap(); // CoviMap
				variableObj.setConvertJSONObject(false); // value는 string으로 넘겨야됨
				variableObj.put("name", "g_appvLine");
				variableObj.put("value", domainData);
				variableObj.put("scope", "global");
				engineSvc.requestUpdateValue(taskID, "g_appvLine", variableObj);
				
				// 엔진 g_context-ProcessDescription 의견유무가 N이면 Y로 변경
				if(!strComment.isEmpty()) {
					String str_g_context = engineSvc.requestGetActivitiVariables(taskID, "g_context");
					if(str_g_context != null && !str_g_context.isEmpty() && !str_g_context.equalsIgnoreCase("null")) {
						CoviMap obj_g_context = CoviMap.fromObject(str_g_context, false);
						if(obj_g_context.has("ProcessDescription")) {
							CoviMap obj_pDesc = (CoviMap)(obj_g_context.get("ProcessDescription"));
							if(obj_pDesc.optString("IsComment").equalsIgnoreCase("N")) { 
								obj_pDesc.put("IsComment","Y");
								variableObj.clear();
								variableObj.put("name", "g_context");
								variableObj.put("value", obj_g_context.toString());
								variableObj.put("scope", "global");
								engineSvc.requestUpdateValue(taskID, "g_context", variableObj);
							}							
						}
					}
				}
			}
			
			// 알림발송
			String approvalURL = PropertiesUtil.getGlobalProperties().getProperty("approval.legacy.path");
			String httpCommURL = approvalURL + "/legacy/setmessage.do";
			
			CoviMap params2 = new CoviMap();
			params2.put("MessageInfo", messageInfos);
			
			HttpsUtil httpsUtil = new HttpsUtil();
			httpsUtil.httpsClientWithRequest(httpCommURL, "POST", params2, "UTF-8", null);
		}
	}
	
	@Override
	public CoviMap getBatchApvLine(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.formdomaindata.selectBatchDomaindata", params);
		
		CoviMap apvLinesObj = new CoviMap();
		apvLinesObj.put("list",CoviSelectSet.coviSelectJSON(list, "ProcessID,DomainDataContext"));
		
		return apvLinesObj;
	}
	
	// 진행 데이터베이스에서 완료된 건 삭제
	@Override
	public void deleteArchiveInProcess(CoviMap params) throws Exception {
		coviMapperOne.delete("apvProcessSvc.processDelete.deleteProcessData", params);
	}
	
	@Override
	public CoviList selectAutoDeputyList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.ApvProcess.selectAutoDeputyList", params);		
		return CoviSelectSet.coviSelectJSON(list, "TaskID,FormInstID,FilePath,SubKind,FormPrefix");
	}
	
	@Override
	public CoviList selectAutoRecList() throws Exception {
		CoviList list = coviMapperOne.list("form.ApvProcess.selectAutoRecList", null);		
		return CoviSelectSet.coviSelectJSON(list, "TaskID,FormInstID,DomainDataContext");
	}
	
	public String replaceBodyContext(String oBodyContext) {
		if (oBodyContext == null)
			return null;

		return new String(Base64.encodeBase64(oBodyContext.getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
	}

	public String getDraftKey(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("form.ApvProcess.selectDraftTaskID", params);
	}
	
	// uuid 생성
	public String getUUID() {
		return UUID.randomUUID().toString().toUpperCase();
	}

	// json string db에 넣을 시 처리(mybatis에서 $바인딩으로 처리하거나, #바인딩 처리시는 아래함수 통해 single
	// quotation 추가)
	public String addSingleQuote(String str) {
		return "'" + str + "'";
	}
	
	public Boolean checkHasSubProcess(String processID) throws Exception {
		
		CoviMap params = new CoviMap();
		params.put("processID", processID);
		
		int cnt = coviMapperOne.selectOne("form.process.selectIsHasSub", params);
		
		return (cnt > 0);
	}
	
	// 전달
	@Override
	public void doForward(CoviMap formObj) throws Exception {
		// 1. 결재선 update
		if (formObj.has("processID") && formObj.has("parentprocessID")) {
			String domainData = "";
		
			List<String> processIDs = new ArrayList<>();
			if (!formObj.getString("processID").equals("0")) {
				processIDs.add(formObj.getString("processID"));
			}
			if (!formObj.getString("parentprocessID").equals("0")) {
				processIDs.add(formObj.getString("parentprocessID"));
			}
		
			CoviMap params = new CoviMap();
		
			if (formObj.has("ApprovalLine") && !formObj.getString("ApprovalLine").equals("")) {
				domainData = formObj.getString("ApprovalLine");
		
				// 결재선 변경 후 저장
				params.put("processIDs", processIDs);
				params.put("DomainDataContext", domainData);
		
				coviMapperOne.update("form.formdomaindata.updateDomainDataIN", params);
			}
		
			// Process Description 데이터 변경
			params.clear();
			params.put("processIDs", processIDs);
			params.put("IsReserved", "N");
			if(formObj.has("CHARGEID") && !formObj.getString("CHARGEID").equals("")) {
				params.put("ApproverCode", formObj.getString("CHARGEID"));
				params.put("ApproverName", formObj.getString("CHARGENAME"));
			}

			coviMapperOne.update("form.processdescription.updateProcessID", params);
			
			String taskID = formObj.getString("taskID");
		
			CoviMap variableObj = new CoviMap();
			variableObj.setConvertJSONObject(false); // value는 string으로 넘겨야됨
			variableObj.put("name", "g_appvLine");
			variableObj.put("value", domainData);
			variableObj.put("scope", "global");
			engineSvc.requestUpdateValue(taskID, "g_appvLine", variableObj);
		}
		
		// 2. 결재함에 표시, performer update
		if (formObj.has("CHARGEID") && formObj.has("CHARGENAME")) {
			CoviMap params = new CoviMap();
		
			if (!formObj.getString("CHARGEID").equals("") && !formObj.getString("CHARGENAME").equals("")) {
				String sChargeOuId = formObj.getString("CHARGEID");
				String sChargeOuName = formObj.getString("CHARGENAME");
		
				// 결재선 변경 후 저장
				params.put("userCode", sChargeOuId);
				params.put("userName", sChargeOuName);
				params.put("workitemId", formObj.getString("WorkitemID"));
		
				// 대결자 정보 조회
				String sNowDate = ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss"));
				String deputyCode = "";
				String deputyName = "";
				params.put("today", sNowDate);
				CoviMap returnedDeputy = coviMapperOne.select("form.workitem.selectDeputy", params);
				if(returnedDeputy != null && returnedDeputy.size() > 0) {
					deputyCode = returnedDeputy.getString("DeputyCode");
					deputyName = returnedDeputy.getString("DeputyName");
				}
				params.put("deputyCode", deputyCode);
				params.put("deputyName", deputyName);
				
				coviMapperOne.update("form.performer.updatePerformer", params);
				coviMapperOne.update("form.workitem.updateWorkitem", params);
			}
		}
	}
	
	// 승인취소를 위한 정보 조회
	@Override
	public int getWorkitemAbortCount(CoviMap formObj) throws Exception {
		CoviMap paramsMap = new CoviMap();
		
		paramsMap.put("ProcessID", formObj.get("processID"));
		paramsMap.put("taskID", formObj.get("taskID"));

		return coviMapperOne.select("form.performer.selectWorkitemAbortCount", paramsMap).getInt("CNT");
	}
	
	@Override
	public CoviMap getRecApvline(CoviMap appvLine) throws Exception {
		appvLine = setStepTask(appvLine);
		appvLine = setOuTask(appvLine);
		
		return appvLine;
	}
	
	@SuppressWarnings("unchecked")
	public CoviMap setStepTask(CoviMap appvLine) {
		CoviMap root = (CoviMap)appvLine.get("steps");
		Object divisionObj = root.get("division");
		CoviList divisions = new CoviList();
		if(divisionObj instanceof CoviMap){
			CoviMap divisionJsonObj = (CoviMap)divisionObj;
			divisions.add(divisionJsonObj);
		} else {
			divisions = (CoviList)divisionObj;
		}
		CoviMap division = (CoviMap)divisions.get(1);
		Object stepO = division.get("step");
		CoviList stepArray = new CoviList();
		if(stepO instanceof CoviMap){
			CoviMap stepJsonObj = (CoviMap)stepO;
			stepArray.add(stepJsonObj);
		} else {
			stepArray = (CoviList)stepO;
		}
		CoviMap stepObject = (CoviMap)stepArray.get(0);
		
		stepObject.put("unittype", "person");
		stepObject.put("routetype", "approve");
		stepObject.put("name", "담당결재");
		
		return appvLine;
	}
	
	@SuppressWarnings("unchecked")
	public CoviMap setOuTask(CoviMap appvLine) {
		CoviMap root = (CoviMap)appvLine.get("steps");
		Object divisionObj = root.get("division");
		CoviList divisions = new CoviList();
		if(divisionObj instanceof CoviMap){
			CoviMap divisionJsonObj = (CoviMap)divisionObj;
			divisions.add(divisionJsonObj);
		} else {
			divisions = (CoviList)divisionObj;
		}
		CoviMap division = (CoviMap)divisions.get(1);
		Object stepO = division.get("step");
		CoviList stepArray = new CoviList();
		if(stepO instanceof CoviMap){
			CoviMap stepJsonObj = (CoviMap)stepO;
			stepArray.add(stepJsonObj);
		} else {
			stepArray = (CoviList)stepO;
		}
		CoviMap stepObject = (CoviMap)stepArray.get(0);
		
		Object ouObj = stepObject.get("ou");
		CoviList ouArray = new CoviList();
		if(ouObj instanceof CoviMap){
			ouArray.add(ouObj);
		} else {
			ouArray = (CoviList)ouObj;
		}
		
		CoviMap o = (CoviMap)ouArray.get(0);
		
		if(o.containsKey("taskid"))
			o.remove("taskid");
		
		CoviMap personObj = new CoviMap();
		CoviMap personTaskinfoObj = new CoviMap();
		
		personObj.put("code", "systemuser");
		personObj.put("name", "System User");
		personObj.put("position", "");
		personObj.put("title", "");
		personObj.put("level", "");
		personObj.put("oucode", "SystemDept");
		personObj.put("ouname", "시스템부서");
		personObj.put("sipaddress", "");
		
		personTaskinfoObj.put("status", "pending");
		personTaskinfoObj.put("result", "pending");
		personTaskinfoObj.put("kind", "charge");
		personTaskinfoObj.put("datereceived", ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss")));
		
		personObj.put("taskinfo", personTaskinfoObj);
		
		o.put("person", personObj);
				
		return appvLine;
	}
	
	// 예약발송(상신/배포) 목록 가져오기
	@Override
	public CoviList selectReservedDraftList() throws Exception {
		CoviList list = coviMapperOne.list("form.ApvProcess.selectReservedDraftList", null);		
		return CoviSelectSet.coviSelectJSON(list, "TaskID");
	}
	
	//FIDO 보안체크
	@Override
	public String selectFidoStatus(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("form.ApvProcess.selectFidoStatus", params);
	}
	
	//결재 암호 사용중인 양식인지 확인하기
	@Override
	public boolean getIsUsePasswordForm(String formPrefix) throws Exception {
		String strFormSchema = coviMapperOne.selectOne("form.ApvProcess.selectFormSchema", formPrefix);
		CoviMap formSchema = new CoviMap();
		formSchema = CoviMap.fromObject(strFormSchema);
		boolean bReturn = false; 
		
		if(formSchema.getJSONObject("scWFPwd").getString("isUse").equalsIgnoreCase("Y")) {
			bReturn = true;
		}
		
		return bReturn;
	}
	
	@Override
	public CoviMap draftCommentSecure(CoviMap formObj) throws Exception {

		try {
			if(formObj != null && !formObj.isEmpty()) {
				CoviMap approvalLineObj = formObj.getJSONObject("ApprovalLine");
				//기안자 의견 보안취약점 대응
				if (formObj.has("actionComment") && !formObj.getString("actionComment").equals("")){
					byte[] tmpActionComment = Base64.decodeBase64(((String)formObj.get("actionComment")).getBytes(StandardCharsets.UTF_8));
					String convActionComment = ComUtils.RemoveScriptAndStyle(new String(tmpActionComment, StandardCharsets.UTF_8));
					formObj.put("actionComment", Base64.encodeBase64String(convActionComment.getBytes(StandardCharsets.UTF_8)));
					
					CoviMap root = (CoviMap)approvalLineObj.get("steps");
					Object divisionObj = root.get("division");
					CoviList divisionArr = new CoviList();
					if(divisionObj instanceof CoviMap){
						CoviMap divisionJsonObj = (CoviMap)divisionObj;
						divisionArr.add(divisionJsonObj);
					} else {
						divisionArr = (CoviList)divisionObj;
					}
					
					for(int i = 0; i < divisionArr.size(); i++){
						CoviMap getdivision = (CoviMap)divisionArr.get(i);
						
						Object stepO = getdivision.get("step");
						CoviList stepArr = new CoviList();
						if(stepO instanceof CoviMap){
							CoviMap stepJsonObj = (CoviMap)stepO;
							stepArr.add(stepJsonObj);
						} else {
							stepArr = (CoviList)stepO;
						}
						
						for(int j = 0; j < stepArr.size(); j++){
							CoviMap getstep = (CoviMap)stepArr.get(j);
							Object ouObj = getstep.get("ou");
							CoviList ouArr = new CoviList();
							if(ouObj instanceof CoviList){
								ouArr = (CoviList)ouObj;
							} else {
								ouArr.add(ouObj);
							}
	
							for(int k = 0; k < ouArr.size(); k++){
								CoviMap getou = (CoviMap)ouArr.get(k);
								Object personObj = getou.get("person");
								CoviList personArr = new CoviList();
								if(personObj instanceof CoviMap){
									CoviMap jsonObj = (CoviMap)personObj;
									personArr.add(jsonObj);
								} else {
									personArr = (CoviList)personObj;
								}
	
								for(int z = 0; z < personArr.size(); z++){
									CoviMap getperson = (CoviMap)personArr.get(z);
									CoviMap taskinfo = new CoviMap();
									if(getperson.containsKey("taskinfo")){
										taskinfo = (CoviMap)getperson.get("taskinfo");
										if(taskinfo.containsKey("comment")){
											CoviMap commentobj = (CoviMap) taskinfo.get("comment");
											
											byte[] tmpComment = Base64.decodeBase64(((String)commentobj.get("#text")).getBytes(StandardCharsets.UTF_8));
											String convComment = ComUtils.RemoveScriptAndStyle(new String(tmpComment, StandardCharsets.UTF_8));
											commentobj.put("#text", Base64.encodeBase64String(convComment.getBytes(StandardCharsets.UTF_8)));
											taskinfo.put("comment", commentobj);
										}
									}
								}
								getou.remove("person");
								if(personArr.size() > 1) {
									getou.put("person", personArr);
								} else {
									getou.put("person", personArr.get(0));
								}
							}
							getstep.remove("ou");
							if(ouArr.size() > 1) {
								getstep.put("ou", ouArr);
							} else {
								getstep.put("ou", ouArr.get(0));
							}
						}
						getdivision.remove("step");
						if(stepArr.size() > 1) {
							getdivision.put("step", stepArr);
						} else {
							getdivision.put("step", stepArr.get(0));
						}
					}
					root.remove("division");
					if(divisionArr.size() > 1) {
						root.put("division", divisionArr);
					} else {
						root.put("division", divisionArr.get(0));
					}
					approvalLineObj.remove("steps");
					approvalLineObj.put("steps", root);
				}
			}
		} catch (NullPointerException npE) {
			LOGGER.error("ApvProcessSvcImpl", npE);
		} catch (Exception e) {
			LOGGER.error("ApvProcessSvcImpl", e);
		}
		return formObj;
	}
	
	@Override
	public boolean getAuthByTaskID(CoviMap param) throws Exception {
		CoviMap result = coviMapperOne.select("form.ApvProcess.selectWorkItemAuthByTaskID", param);
		return (result.getInt("CNT") > 0);
	}	
	
	@Override
	public CoviMap getFormInfoList(String fiid) throws Exception {
		
		CoviMap map = new CoviMap();
		map.put("fiid", fiid);
		CoviList list = coviMapperOne.list("form.ApvProcess.SelectFormInfo", map);
		
		CoviMap circulationReadListObj = new CoviMap();

		circulationReadListObj.put("list",CoviSelectSet.coviSelectJSON(list, "FormInstID,ProcessID,InitiatorID,FormID,FormPrefix,FormName,FormSubject,IsSecureDoc,IsFile,DocNo,Reserved2"));
		return circulationReadListObj;
		
	}
	
	// 검토 요청
	@Override
	public void doConsultationRequest(CoviMap formObj) throws Exception {
		CoviMap approvalLine = formObj.getJSONObject("ApprovalLine");
		CoviList consultUsers = formObj.getJSONArray("consultUsers");
		String processID = formObj.optString("processID");
		String parentProcessID = formObj.optString("parentprocessID");
		String workitemID = formObj.optString("workitemID");
		String strUserCode = formObj.optString("actionUser");
		String strComment = formObj.optString("actionComment");
		
		String strInitiatorCode = formObj.optString("InitiatorID");
		String subject = formObj.optString("Subject");
		String formInstId = formObj.optString("FormInstID");
		String formName = formObj.optString("FormName");
		String strMode = formObj.optString("mode");
		CoviList deleteInfos = formObj.getJSONArray("deleteInfos");
		CoviList consultUsersApvLine  = new CoviList();
		CoviList consultUsersinfo  = new CoviList();
		CoviList messageInfos = new CoviList();
		
		//결재선 꼬임 방지 ###############
		CoviMap paramsDomain = new CoviMap();
		paramsDomain.put("processID", processID);
		paramsDomain.put("IsArchived", "false"); // Archive 가 있는 테이블은 반드시 넘겨야 함
		paramsDomain.put("bStored", "false");
		
		CoviMap domainData = new CoviMap();
		domainData = (((CoviList)(formSvc.selectDomainData(paramsDomain)).get("list")).getJSONObject(0));
		
		if(!domainData.get("DomainDataContext").equals(""))
			approvalLine = domainData.getJSONObject("DomainDataContext");

		//workitem 삭제
		CoviList deleteUsers = new CoviList();
		if(deleteInfos.size() > 0) {
			deleteWorkitemforConsultation(workitemID, deleteInfos);

			for(Object delObj : deleteInfos) {
				CoviMap deleteUserObject = (CoviMap) delObj;
				//검토 요청자들에게 검토 요청 취소 알림 메시지 전송
				CoviMap messageInfo = new CoviMap();
				messageInfo.put("UserId", deleteUserObject.optString("code"));
				messageInfo.put("Subject", subject);
				messageInfo.put("Initiator", strInitiatorCode);
				messageInfo.put("Status", "CONSULTATIONCANCEL"); 
				messageInfo.put("ProcessId", processID); 
				messageInfo.put("FormInstId", formInstId);
				messageInfo.put("FormName", formName);
				messageInfo.put("Type", "UR");
				messageInfo.put("ApproveCode", strUserCode);
				messageInfo.put("SenderID", strUserCode);
				messageInfo.put("Comment", new String(Base64.decodeBase64(strComment.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8));
				
				messageInfos.add(messageInfo);
				
				deleteUsers.add(deleteUserObject.optString("code"));
			}
		}
		
		CoviMap oConsultinfo = new CoviMap();
		CoviList oApvUsers = new CoviList();
		String currentDate = ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss"));
		for(int idx = 0; idx < consultUsers.size(); idx ++) {
			// jwf_workitemdescription 테이블 사용안함에 따라 0으로 고정함.
			CoviMap consultUser = consultUsers.getJSONObject(idx);
			String userName = consultUser.optString("DN");
			String userCode = consultUser.optString("AN");
			CoviMap newWorkitem = createWorkitemforConsultation(Integer.parseInt(workitemID), userCode, userName, "T023");

			CoviMap oApvUser = new CoviMap();
			oApvUser.put("code", userCode);
			oApvUser.put("name", userName);
			oApvUser.put("position", consultUser.optString("po"));
			oApvUser.put("title", consultUser.optString("tl"));
			oApvUser.put("level", consultUser.optString("lv"));
			oApvUser.put("oucode", consultUser.optString("RG"));
			oApvUser.put("ouname", consultUser.optString("RGNM"));
			oApvUser.put("sipaddress", consultUser.optString("EM"));
			oApvUser.put("wiid", newWorkitem.optString("workitemID"));

			CoviMap oTaskinfo = new CoviMap();
			oTaskinfo.put("status", "pending");
			oTaskinfo.put("result", "pending");
			oTaskinfo.put("kind", "consultation");
			oTaskinfo.put("datereceived", currentDate);
			
			oApvUser.put("taskinfo", oTaskinfo);
			if(strMode.equals("ConsultReqModify")){
				consultUsersinfo.add(oApvUser);
			}
			
			oApvUsers.add(oApvUser);
			
			// 검토 요청 알림 발송용 파라미터 구성
			CoviMap messageInfo = new CoviMap();
			
			messageInfo.put("UserId", userCode);
			messageInfo.put("Subject", subject);
			messageInfo.put("Initiator", strInitiatorCode);
			messageInfo.put("Status", "CONSULTATION"); 
			messageInfo.put("ProcessId", processID); 
			messageInfo.put("WorkitemId", newWorkitem.optString("workitemID"));
			messageInfo.put("FormInstId", formInstId);
			messageInfo.put("FormName", formName);
			messageInfo.put("Type", "UR");
			messageInfo.put("ApproveCode", strUserCode);
			messageInfo.put("SenderID", strUserCode);
			messageInfo.put("Comment", new String(Base64.decodeBase64(strComment.getBytes("UTF-8")), "UTF-8"));
			
			messageInfos.add(messageInfo);
		}
		
		if(strMode.equals("ConsultReq") || strMode.equals("ReConsultReq")) {
			oConsultinfo.put("status", "pending");
			oConsultinfo.put("daterequested", currentDate);
			if(!strComment.isEmpty()) {
				CoviMap comment = new CoviMap();
				comment.put("#text", strComment);
				oConsultinfo.put("consultcomment", comment);
			}
			
			if(oApvUsers.size() > 1) {
				oConsultinfo.put("consultusers", oApvUsers);
			} else {
				oConsultinfo.put("consultusers", (CoviMap)oApvUsers.get(0));
			}
			consultUsersApvLine.add(oConsultinfo);
		}
		
		List<String> processIDs = new ArrayList<String>();
		if (!processID.equals("0")) {
			processIDs.add(processID);
		}

		if (parentProcessID.equals("0")) {
			CoviMap pParam = new CoviMap();
			pParam.put("ProcessID", processID);			
			CoviMap rtnProcessIDMap = coviMapperOne.select("form.nonApvProcess.getParentProcessID1", pParam);
			parentProcessID = rtnProcessIDMap.isEmpty() ? "0" : rtnProcessIDMap.optString("ParentProcessID");
		}
		
		if (!parentProcessID.equals("0")) {
			processIDs.add(parentProcessID);
		}

		// step3. 결재선 수정
		CoviMap root = approvalLine.getJSONObject("steps");
		Object divisionObj = root.get("division");
		CoviList divisions = new CoviList();
		if(divisionObj instanceof CoviMap){
			CoviMap divisionJsonObj = (CoviMap)divisionObj;
			divisions.add(divisionJsonObj);
		} else {
			divisions = (CoviList)divisionObj;
		}
		
		for(int i = 0; i < divisions.size(); i++)
		{
			CoviMap division = (CoviMap)divisions.get(i);
			CoviMap taskObject = (CoviMap)division.get("taskinfo");
			
			if(taskObject.get("status").toString().equalsIgnoreCase("pending")) {
				Object stepO = division.get("step");
				CoviList steps = new CoviList();
				if(stepO instanceof CoviMap){
					CoviMap stepJsonObj = (CoviMap)stepO;
					steps.add(stepJsonObj);
				} else {
					steps = (CoviList)stepO;
				}
				
				String unitType = "";
				
				for(int j = 0; j < steps.size(); j++)
				{
					unitType = "";
					
					CoviMap s = (CoviMap)steps.get(j);
					
					unitType = (String)s.get("unittype");
					
					//jsonarray와 jsonobject 분기 처리
					Object ouObj = s.get("ou");
					CoviList ouArray = new CoviList();
					if(ouObj instanceof CoviList){
						ouArray = (CoviList)ouObj;
					} else {
						ouArray.add((CoviMap)ouObj);
					}
					
					for(int z = 0; z < ouArray.size(); z++)
					{
						CoviMap ouObject = (CoviMap)ouArray.get(z);
						
						if(workitemID.equals(ouObject.optString("wiid"))) {
							if(ouObject.containsKey("person") && unitType.equalsIgnoreCase("person")){
								Object personObj = ouObject.get("person");
								CoviList persons = new CoviList();
								if(personObj instanceof CoviMap){
									CoviMap jsonObj = (CoviMap)personObj;
									persons.add(jsonObj);
								} else {
									persons = (CoviList)personObj;
								}
	
								for(int pIdx = 0; pIdx < persons.size(); pIdx ++) {
									CoviMap personObject = (CoviMap)persons.get(pIdx);
									taskObject = (CoviMap)personObject.get("taskinfo");
									
									if(personObject.optString("code").equalsIgnoreCase(strUserCode) && ("pending,reserved,consultation".contains(taskObject.optString("result")))) {
										taskObject.put("result", "consultation");
										taskObject.put("status", "consultation");
										taskObject.put("datecompleted", "");
										
										personObject.remove("taskinfo");
										personObject.put("taskinfo", taskObject);
										
										Object consultationObj = personObject.get("consultation");
										CoviList consultationList = new CoviList();
										if(consultationObj instanceof CoviMap){
											CoviMap consultJsonObj = (CoviMap)consultationObj;
											consultationList.add(consultJsonObj);
										} else {
											consultationList = (CoviList)consultationObj;
										}
										
										//consultation 노드 추가
										if(strMode.equals("ConsultReq") || strMode.equals("ReConsultReq")) {
											if(consultationList == null) {
												personObject.put("consultation", consultUsersApvLine.get(0));
											} else {
												consultationList.add(consultUsersApvLine.get(0));
												
												personObject.remove("consultation");
												if(consultationList.size() > 1) {
													personObject.put("consultation", consultationList);
												} else {
													personObject.put("consultation", (CoviMap)consultationList.get(0));
												}
											}
										} else if(strMode.equals("ConsultReqModify")) { //결재자 변경
											int finishedUserCnt = 0;
											for(int cIdx = 0; cIdx < consultationList.size(); cIdx ++) {
												CoviMap consultObject = (CoviMap)consultationList.get(cIdx);
												if(consultObject.optString("status").equals("pending")) {
													Object consultUserObj = consultObject.get("consultusers");
													
													CoviList consultUserList = new CoviList();
													if(consultUserObj instanceof CoviMap){
														CoviMap userJsonObj = (CoviMap)consultUserObj;
														consultUserList.add(userJsonObj);
													} else {
														consultUserList = (CoviList)consultUserObj;
													}
													
													int consultSeq = 0;
													for(int uIdx = 0; uIdx < consultUserList.size(); uIdx ++) {
														CoviMap consultUserObject = (CoviMap)consultUserList.get(uIdx);
														if(deleteUsers.size() == 0 || (deleteUsers.size() > 0 && !deleteUsers.contains(consultUserObject.optString("code")))) {
															consultUsersinfo.add(consultSeq, consultUserObject);
															consultSeq++;
															if(consultUserObject.getJSONObject("taskinfo").optString("status").equalsIgnoreCase("completed")) {
																finishedUserCnt++;
															}
														}
													}
													
													if(finishedUserCnt == consultUsersinfo.size()) {
														consultObject.put("status", "completed");
														consultObject.put("datecompleted", currentDate);
														
														taskObject.put("result", "pending");
														taskObject.put("status", "pending");
													}
													
													consultObject.remove("consultusers");
													if(consultUsersinfo.size() > 1) {
														consultObject.put("consultusers", consultUsersinfo);
													} else {
														consultObject.put("consultusers", (CoviMap)consultUsersinfo.get(0));
													}
												}
											}
											personObject.remove("consultation");
											if(consultationList.size() > 1) {
												personObject.put("consultation", consultationList);
											} else {
												personObject.put("consultation", (CoviMap)consultationList.get(0));
											}
										}
										
										ouObject.remove("person");
										if(persons.size() > 1) {
											ouObject.put("person", persons);
										} else {
											ouObject.put("person", (CoviMap)persons.get(0));
										}
									}
								}
							}
						}
						
						s.remove("ou");
						if(ouArray.size() > 1) {
							s.put("ou", ouArray);
						} else {
							s.put("ou", (CoviMap)ouArray.get(0));
						}
					}	      
				}
				
				division.remove("step");
				if(steps.size() > 1) {
					division.put("step", steps);
				} else {
					division.put("step", (CoviMap)steps.get(0));
				}
			}
		}
		
		root.remove("division");
		if(divisions.size() > 1) {
			root.put("division", divisions);
		} else {
			root.put("division", (CoviMap)divisions.get(0));
		}
		
		approvalLine.put("steps", root);
		
		
		// 결재선 변경 후 저장
		CoviMap params = new CoviMap();
		params.put("processIDs", processIDs);
		params.put("DomainDataContext", approvalLine.toString());

		coviMapperOne.update("form.formdomaindata.updateDomainDataIN", params);
			
	
		// Process Description 데이터 변경
		params.put("IsReserved", "N");
		coviMapperOne.update("form.processdescription.updateProcessID", params);
		
		// 알림발송
		String approvalURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") +	"/approval"; 
		String httpCommURL = approvalURL + "/legacy/setmessage.do";
		CoviMap params2 = new CoviMap(); 
		params2.put("MessageInfo",  messageInfos);

		HttpsUtil httpsUtil = new HttpsUtil();
		httpsUtil.httpsClientWithRequest(httpCommURL, "POST", params2, "UTF-8",  null);	 
	}
	
	public CoviMap createWorkitemforConsultation(int prevWorkitemID, String userCode, String userName, String subKind) throws Exception {
		CoviMap prevWorkitem = coviMapperOne.select("form.workitem.select", new CoviMap() {{ put("workitemID", prevWorkitemID); }});
		prevWorkitem.put("TaskID", "0");
		prevWorkitem.put("UserCode", userCode);
		prevWorkitem.put("UserName", userName);
		prevWorkitem.put("DeputyID", "");
		prevWorkitem.put("DeputyName", "");
		prevWorkitem.put("BusinessData5", prevWorkitemID);
		coviMapperOne.insert("form.workitem.insert", prevWorkitem);
		int workitemID = prevWorkitem.getInt("WorkItemID");
		
		CoviMap performerMap = new CoviMap();
		performerMap.put("workitemID", workitemID);
		performerMap.put("allotKey", "");
		performerMap.put("userCode", userCode);
		performerMap.put("userName", userName);
		performerMap.put("actualKind", "0");
		performerMap.put("state", "1");
		performerMap.put("subKind", subKind);
		coviMapperOne.insert("form.performer.insert", performerMap);
		int performerID = performerMap.getInt("PerformerID");

		//2. workitem update
		CoviMap workitemUMap = new CoviMap();
		workitemUMap.put("performerID", performerID);
		workitemUMap.put("workitemID", workitemID);
		coviMapperOne.update("form.workitem.updatePerformerID", workitemUMap);
		
		return workitemUMap;
	}
	
	public void deleteWorkitemforConsultation(String workitemID, CoviList deleteInfos) throws Exception {
		CoviMap workItemMap = new CoviMap();
		workItemMap.put("deleteInfos", deleteInfos);
		workItemMap.put("workitemID", workitemID);
		// 생성된 workitem, performer 삭제
		coviMapperOne.delete("form.performer.deleteUserWorkItemID", workItemMap);
		coviMapperOne.delete("form.workitem.deleteUserWorkItemID", workItemMap );
	}
	
	@Override
	public void doConsultation(CoviMap formObj) throws Exception {
		CoviMap approvalLine = formObj.getJSONObject("ApprovalLine");
		String processID = formObj.optString("processID");
		String parentProcessID = formObj.optString("parentprocessID");
		String workitemID = formObj.optString("workitemID");
		String strUserCode = formObj.optString("actionUser");
		String strAction = formObj.optString("actionMode");
		String strComment = formObj.optString("actionComment");
		String strCommentAttach = (formObj.containsKey("actionComment_Attach")) ? formObj.optString("actionComment_Attach") : "";
		
		String senderCode = null;
		String originWorkitemID = null;
		CoviList messageInfos = new CoviList();
		
		//KH - nykim 결재선 꼬임 방지 ############### 2022.02.21
		CoviMap domainData = new CoviMap();
		
		CoviMap paramsDomain = new CoviMap();
		paramsDomain.put("processID", processID);
		paramsDomain.put("IsArchived", "false"); // Archive 가 있는 테이블은 반드시 넘겨야 함
		paramsDomain.put("bStored", "false");
		domainData = (((CoviList)(formSvc.selectDomainData(paramsDomain)).get("list")).getJSONObject(0));
		
		if(!domainData.get("DomainDataContext").equals(""))
			approvalLine = domainData.getJSONObject("DomainDataContext");
		//KH - nykim 결재선 꼬임 방지 ###############
		
		List<String> processIDs = new ArrayList<String>();
		if (!processID.equals("0")) {
			processIDs.add(processID);
		}
		
		if (parentProcessID.equals("0")) {
			CoviMap pParam = new CoviMap();
			pParam.put("ProcessID", processID);			
			CoviMap rtnProcessIDMap = coviMapperOne.select("form.nonApvProcess.getParentProcessID1", pParam);
			parentProcessID = rtnProcessIDMap.isEmpty() ? "0" : rtnProcessIDMap.optString("ParentProcessID");
		}
		
		if (!parentProcessID.equals("0")) {
			processIDs.add(parentProcessID);
		}
		
		//workitem 수정
		CoviMap workitemUMap = new CoviMap();
		workitemUMap.put("State", 528);
		workitemUMap.put("WorkitemID", workitemID);
		coviMapperOne.update("form.workitem.updateWorkitemforFinish", workitemUMap);

		originWorkitemID = coviMapperOne.selectOne("form.workitem.selectOriginWorkItemID", workitemUMap);
		
		//결재선 수정
		CoviMap root = approvalLine.getJSONObject("steps");
		Object divisionObj = root.get("division");
		CoviList divisions = new CoviList();
		if(divisionObj instanceof CoviMap){
			CoviMap divisionJsonObj = (CoviMap)divisionObj;
			divisions.add(divisionJsonObj);
		} else {
			divisions = (CoviList)divisionObj;
		}
		
		for(int i = 0; i < divisions.size(); i++)
		{
			CoviMap division = (CoviMap)divisions.get(i);
			CoviMap taskObject = (CoviMap)division.get("taskinfo");
			
			if(taskObject.get("status").toString().equalsIgnoreCase("pending")) {
				Object stepO = division.get("step");
				CoviList steps = new CoviList();
				if(stepO instanceof CoviMap){
					CoviMap stepJsonObj = (CoviMap)stepO;
					steps.add(stepJsonObj);
				} else {
					steps = (CoviList)stepO;
				}
				
				String unitType = "";
				
				for(int j = 0; j < steps.size(); j++)
				{
					unitType = "";
					
					CoviMap s = (CoviMap)steps.get(j);
					
					unitType = (String)s.get("unittype");
					
					//jsonarray와 jsonobject 분기 처리
					Object ouObj = s.get("ou");
					CoviList ouArray = new CoviList();
					if(ouObj instanceof CoviList){
						ouArray = (CoviList)ouObj;
					} else {
						ouArray.add((CoviMap)ouObj);
					}
					
					for(int z = 0; z < ouArray.size(); z++)
					{
						CoviMap ouObject = (CoviMap)ouArray.get(z);
						
						if(ouObject.containsKey("person") && unitType.equalsIgnoreCase("person")){
							Object personObj = ouObject.get("person");
							CoviList persons = new CoviList();
							if(personObj instanceof CoviMap){
								CoviMap jsonObj = (CoviMap)personObj;
								persons.add(jsonObj);
							} else {
								persons = (CoviList)personObj;
							}
							
							for(int pIdx = 0; pIdx < persons.size(); pIdx ++) {
								CoviMap personObject = (CoviMap)persons.get(pIdx);
								taskObject = (CoviMap)personObject.get("taskinfo");
															
								if(taskObject.getString("result").equals("consultation") && originWorkitemID.equalsIgnoreCase(ouObject.optString("wiid"))) {
									Object consultationObj = personObject.get("consultation");
									CoviList consultationList = new CoviList();
									if(consultationObj instanceof CoviMap){
										CoviMap consultJsonObj = (CoviMap)consultationObj;
										consultationList.add(consultJsonObj);
									} else {
										consultationList = (CoviList)consultationObj;
									}
									
									int finishedUserCnt = 0;
									for(int cIdx = 0; cIdx < consultationList.size(); cIdx ++) {
										CoviMap consultObject = (CoviMap)consultationList.get(cIdx);
										if(consultObject.optString("status").equals("pending")) {
											Object consultUserObj = consultObject.get("consultusers");
											
											CoviList consultUserList = new CoviList();
											if(consultUserObj instanceof CoviMap){
												CoviMap userJsonObj = (CoviMap)consultUserObj;
												consultUserList.add(userJsonObj);
											} else {
												consultUserList = (CoviList)consultUserObj;
											}
											
											for(int uIdx = 0; uIdx < consultUserList.size(); uIdx ++) {
												CoviMap consultUser = (CoviMap)consultUserList.get(uIdx);
												CoviMap consultUserTaskinfo = consultUser.getJSONObject("taskinfo");
										
												if(strUserCode.equalsIgnoreCase(consultUser.optString("code"))) {
													senderCode = personObject.optString("code");
													consultUserTaskinfo.put("status", "completed");
													consultUserTaskinfo.put("datecompleted", ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss")));
													if(strAction.equals("AGREE")) {
														consultUserTaskinfo.put("result", "agreed");
													} else {
														consultUserTaskinfo.put("result", "disagreed");
													}
		
													if(!strComment.isEmpty()) {
														CoviMap comment = new CoviMap();
														comment.put("#text", strComment);
														consultUserTaskinfo.put("comment", comment); 
													}
													
													// 의견첨부가 존재하는 경우
													if(!strCommentAttach.isEmpty()) {
														consultUserTaskinfo.put("comment_fileinfo", strCommentAttach);
													}
												}
										
												if(consultUserTaskinfo.optString("status").equalsIgnoreCase("completed")) {
													finishedUserCnt++;
												}
		
												consultUser.remove("taskinfo");
												consultUser.put("taskinfo", consultUserTaskinfo);
											}
											
											consultObject.remove("consultusers");
											if(consultUserList.size() > 1) {
												consultObject.put("consultusers", consultUserList);
											} else {
												consultObject.put("consultusers", (CoviMap)consultUserList.get(0));
											}
		
											if(finishedUserCnt == consultUserList.size()) {
												consultObject.put("status", "completed");
												
												taskObject.put("result", "pending");
												taskObject.put("status", "pending");
												
												// 검토 완료 알림 발송
												if(taskObject.optString("result").equalsIgnoreCase("pending") || taskObject.optString("result").equalsIgnoreCase("completed")) {
													CoviMap messageInfo = new CoviMap();
													
													messageInfo.put("UserId", senderCode);
													messageInfo.put("Subject", formObj.optString("Subject"));
													messageInfo.put("Initiator", formObj.optString("InitiatorID"));
													messageInfo.put("Status", "CONSULTATIONCOMPLETE"); 
													messageInfo.put("ProcessId", processID); 
													messageInfo.put("WorkitemId", originWorkitemID);
													messageInfo.put("FormInstId", formObj.optString("FormInstID"));
													messageInfo.put("FormName", formObj.optString("FormName"));
													messageInfo.put("Type", "UR");
													messageInfo.put("ApproveCode", strUserCode);
													messageInfo.put("SenderID", strUserCode);
													messageInfo.put("Comment", new String(Base64.decodeBase64(strComment.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8));
													
													messageInfos.add(messageInfo);	
												}
											}
											
											personObject.remove("taskinfo");
											personObject.put("taskinfo", taskObject);
										}
									}
								}
							}

							ouObject.remove("person");
							if(persons.size() > 1) {
								ouObject.put("person", persons);
							} else {
								ouObject.put("person", (CoviMap)persons.get(0));
							}
						}
						
						s.remove("ou");
						if(ouArray.size() > 1) {
							s.put("ou", ouArray);
						} else {
							s.put("ou", (CoviMap)ouArray.get(0));
						}
					}	      
				}
				
				division.remove("step");
				if(steps.size() > 1) {
					division.put("step", steps);
				} else {
					division.put("step", (CoviMap)steps.get(0));
				}
			}
		}
		
		root.remove("division");
		if(divisions.size() > 1) {
			root.put("division", divisions);
		} else {
			root.put("division", (CoviMap)divisions.get(0));
		}
		
		approvalLine.put("steps", root);
		
		
		// 결재선 변경 후 저장
		CoviMap params = new CoviMap();
		params.put("processIDs", processIDs);
		params.put("DomainDataContext", approvalLine.toString());

		coviMapperOne.update("form.formdomaindata.updateDomainDataIN", params);
			
	
		// Process Description 데이터 변경
		params.put("IsReserved", "N");
		coviMapperOne.update("form.processdescription.updateProcessID", params);
		

		// 알림발송
		String approvalURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") +	"/approval"; 
		String httpCommURL = approvalURL + "/legacy/setmessage.do";
		CoviMap params2 = new CoviMap(); 
		params2.put("MessageInfo",  messageInfos);

		HttpsUtil httpsUtil = new HttpsUtil();
		httpsUtil.httpsClientWithRequest(httpCommURL, "POST", params2, "UTF-8",  null);		 
	}
	
	@Override
	public void consultationRequstCancel(CoviMap formObj) throws Exception {
		CoviMap approvalLine = formObj.getJSONObject("ApprovalLine");
		String processID = formObj.optString("processID");
		String parentProcessID = formObj.optString("parentprocessID");
		String workitemID = formObj.optString("workitemID");
		String strUserCode = formObj.optString("actionUser");
		String strComment = formObj.optString("actionComment");
		CoviList deleteInfos = formObj.getJSONArray("deleteInfos");
		CoviList messageInfos = new CoviList();

		//결재선 꼬임 방지 ###############
		CoviMap domainData = new CoviMap();
		
		CoviMap paramsDomain = new CoviMap();
		paramsDomain.put("processID", processID);
		paramsDomain.put("IsArchived", "false"); // Archive 가 있는 테이블은 반드시 넘겨야 함
		paramsDomain.put("bStored", "false");
		domainData = (((CoviList)(formSvc.selectDomainData(paramsDomain)).get("list")).getJSONObject(0));
		
		if(!domainData.get("DomainDataContext").equals(""))
			approvalLine = domainData.getJSONObject("DomainDataContext");
		
		
		List<String> processIDs = new ArrayList<String>();
		if (!processID.equals("0")) {
			processIDs.add(processID);
		}

		if (parentProcessID.equals("0")) {
			CoviMap pParam = new CoviMap();
			pParam.put("ProcessID", processID);			
			CoviMap rtnProcessIDMap = coviMapperOne.select("form.nonApvProcess.getParentProcessID1", pParam);
			parentProcessID = rtnProcessIDMap.isEmpty() ? "0" : rtnProcessIDMap.optString("ParentProcessID");
		}
		
		if (!parentProcessID.equals("0")) {
			processIDs.add(parentProcessID);
		}

		// step3. 결재선 수정
		CoviMap root = approvalLine.getJSONObject("steps");
		Object divisionObj = root.get("division");
		CoviList divisions = new CoviList();
		if(divisionObj instanceof CoviMap){
			CoviMap divisionJsonObj = (CoviMap)divisionObj;
			divisions.add(divisionJsonObj);
		} else {
			divisions = (CoviList)divisionObj;
		}
		
		for(int i = 0; i < divisions.size(); i++)
		{
			CoviMap division = (CoviMap)divisions.get(i);
			CoviMap taskObject = (CoviMap)division.get("taskinfo");
			
			if(taskObject.get("status").toString().equalsIgnoreCase("pending")) {
				Object stepO = division.get("step");
				CoviList steps = new CoviList();
				if(stepO instanceof CoviMap){
					CoviMap stepJsonObj = (CoviMap)stepO;
					steps.add(stepJsonObj);
				} else {
					steps = (CoviList)stepO;
				}
				
				String unitType = "";
				
				for(int j = 0; j < steps.size(); j++)
				{
					unitType = "";
					
					CoviMap s = (CoviMap)steps.get(j);
					
					unitType = (String)s.get("unittype");
					
					//jsonarray와 jsonobject 분기 처리
					Object ouObj = s.get("ou");
					CoviList ouArray = new CoviList();
					if(ouObj instanceof CoviList){
						ouArray = (CoviList)ouObj;
					} else {
						ouArray.add((CoviMap)ouObj);
					}
					
					for(int z = 0; z < ouArray.size(); z++)
					{
						CoviMap ouObject = (CoviMap)ouArray.get(z);
						
						if(ouObject.containsKey("person") && unitType.equalsIgnoreCase("person")){
							Object personObj = ouObject.get("person");
							CoviList persons = new CoviList();
							if(personObj instanceof CoviMap){
								CoviMap jsonObj = (CoviMap)personObj;
								persons.add(jsonObj);
							} else {
								persons = (CoviList)personObj;
							}
							
							for(int pIdx = 0; pIdx < persons.size(); pIdx ++) {
								CoviMap personObject = (CoviMap)persons.get(pIdx);
								taskObject = (CoviMap)personObject.get("taskinfo");
								if(taskObject.optString("result").equals("consultation") && workitemID.equalsIgnoreCase(ouObject.optString("wiid"))) {
									Object consultationObj = personObject.get("consultation");
									CoviList consultationList = new CoviList();
									if(consultationObj instanceof CoviMap){
										CoviMap consultJsonObj = (CoviMap)consultationObj;
										consultationList.add(consultJsonObj);
									} else {
										consultationList = (CoviList)consultationObj;
									}
																		
									for(int c = 0; c < consultationList.size(); c++){
										CoviMap consultObject = (CoviMap)consultationList.get(c);
										if(consultObject.optString("status").equals("pending")) {
											Object consultUserObj = consultObject.get("consultusers");
											
											CoviList consultUserList = new CoviList();
											if(consultUserObj instanceof CoviMap){
												CoviMap userJsonObj = (CoviMap)consultUserObj;
												consultUserList.add(userJsonObj);
											} else {
												consultUserList = (CoviList)consultUserObj;
											}
											
											for(int uIdx = 0; uIdx < consultUserList.size(); uIdx ++) {
												CoviMap consultUser = (CoviMap)consultUserList.get(uIdx);
										
												//검토 요청자들에게 검토 요청 취소 알림 메시지 전송
												CoviMap messageInfo = new CoviMap();
												
												messageInfo.put("UserId", consultUser.optString("code"));
												messageInfo.put("Subject", formObj.optString("Subject"));
												messageInfo.put("Initiator", formObj.optString("InitiatorID"));
												messageInfo.put("Status", "CONSULTATIONCANCEL"); 
												messageInfo.put("ProcessId", processID); 
												//messageInfo.put("WorkitemId", consultUser.optString("wiid")); 
												messageInfo.put("FormInstId", formObj.optString("FormInstID"));
												messageInfo.put("FormName", formObj.optString("FormName"));
												messageInfo.put("Type", "UR");
												messageInfo.put("ApproveCode", strUserCode);
												messageInfo.put("SenderID", strUserCode);
												messageInfo.put("Comment", new String(Base64.decodeBase64(strComment.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8));
												
												messageInfos.add(messageInfo);
											}
											consultObject.put("status", "canceled");
											consultObject.put("cancelcomment", strComment);
											consultObject.put("datecanceled", ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss")));
											
											taskObject.put("result", "pending");
											taskObject.put("status", "pending");
										}
									}
									
									personObject.remove("taskinfo");
									personObject.put("taskinfo", taskObject);
								}
							}
							ouObject.remove("person");
							if(persons.size() > 1) {
								ouObject.put("person", persons);
							} else {
								ouObject.put("person", (CoviMap)persons.get(0));
							}
						}
						
						s.remove("ou");
						if(ouArray.size() > 1) {
							s.put("ou", ouArray);
						} else {
							s.put("ou", (CoviMap)ouArray.get(0));
						}
					}	      
				}
				
				division.remove("step");
				if(steps.size() > 1) {
					division.put("step", steps);
				} else {
					division.put("step", (CoviMap)steps.get(0));
				}
			}
		}
		
		root.remove("division");
		if(divisions.size() > 1) {
			root.put("division", divisions);
		} else {
			root.put("division", (CoviMap)divisions.get(0));
		}
		
		approvalLine.put("steps", root);
		
		// 결재선 변경 후 저장
		CoviMap params = new CoviMap();
		params.put("processIDs", processIDs);
		params.put("DomainDataContext", approvalLine.toString());

		coviMapperOne.update("form.formdomaindata.updateDomainDataIN", params);

		// Process Description 데이터 변경
		params.put("IsReserved", "N");
		coviMapperOne.update("form.processdescription.updateProcessID", params);
		
		// 생성된 workitem, performer 삭제
		params.put("workitemID", workitemID);
		params.put("deleteInfos", deleteInfos);
		coviMapperOne.delete("form.performer.deleteUserWorkItemID", params);
		coviMapperOne.delete("form.workitem.deleteUserWorkItemID", params);
		
		// 알림발송
		String approvalURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/approval";
		String httpCommURL = approvalURL + "/legacy/setmessage.do";
		
		CoviMap params2 = new CoviMap();
		params2.put("MessageInfo", messageInfos);
		
		HttpsUtil httpsUtil = new HttpsUtil();
		httpsUtil.httpsClientWithRequest(httpCommURL, "POST", params2, "UTF-8", null);
	}

	@Override
	public int deleteFormInstacne(CoviMap paramsObj) throws Exception {
		// jwf_forminstance
		return coviMapperOne.delete("form.forminstance.deleteTemp", paramsObj);
	}
	
	private String getChangeApprovalLine(String changeApprovalLine, String taskId, CoviMap formObj) throws Exception{
		Boolean chkChgApvLine = false;
		CoviMap domainData = new CoviMap();
		CoviMap approvalLine = new CoviMap();
		CoviMap chgApprovalLine = new CoviMap();
		
		String processID = formObj.getString("processID");
		
		CoviMap paramsDomain = new CoviMap();
		paramsDomain.put("processID", processID);
		paramsDomain.put("IsArchived", "false");
		paramsDomain.put("bStored", "false");
		domainData = (((CoviList)(formSvc.selectDomainData(paramsDomain)).get("list")).getJSONObject(0));
		
		if(!domainData.get("DomainDataContext").equals("")) {
			approvalLine = domainData.getJSONObject("DomainDataContext");

			CoviMap root = approvalLine.getJSONObject("steps");
			Object divisionObj = root.get("division");
			CoviList divisions = new CoviList();
			if(divisionObj instanceof CoviMap){
				CoviMap divisionJsonObj = (CoviMap)divisionObj;
				divisions.add(divisionJsonObj);
			} else {
				divisions = (CoviList)divisionObj;
			}

			chgApprovalLine = CoviMap.fromObject(changeApprovalLine);
			
			CoviMap chgRoot = chgApprovalLine.getJSONObject("steps");
			Object chgDivisionObj = chgRoot.get("division");
			CoviList chgDivisions = new CoviList();
			if(chgDivisionObj instanceof CoviMap){
				CoviMap chgDivisionJsonObj = (CoviMap)chgDivisionObj;
				chgDivisions.add(chgDivisionJsonObj);
			} else {
				chgDivisions = (CoviList)chgDivisionObj;
			}
			
			if(divisions.size() == chgDivisions.size()) {
				for(int i = 0; i < divisions.size(); i++)
				{
					CoviMap division = (CoviMap)divisions.get(i);
					CoviMap chgDivision = (CoviMap)chgDivisions.get(i);
					CoviMap taskObject = (CoviMap)division.get("taskinfo");
					
					if(taskObject.get("status").toString().equalsIgnoreCase("pending")) {
						Object stepO = division.get("step");
						CoviList steps = new CoviList();
						if(stepO instanceof CoviMap){
							CoviMap stepJsonObj = (CoviMap)stepO;
							steps.add(stepJsonObj);
						} else {
							steps = (CoviList)stepO;
						}
						
						Object chgStepO = chgDivision.get("step");
						CoviList chgSteps = new CoviList();
						if(chgStepO instanceof CoviMap){
							CoviMap chgStepJsonObj = (CoviMap)chgStepO;
							chgSteps.add(chgStepJsonObj);
						} else {
							chgSteps = (CoviList)chgStepO;
						}

						String status = "";
						String unitType = "";
						String allottype = "";
						
						if(steps.size() == chgSteps.size()) {
							for(int j = 0; j < steps.size(); j++)
							{
								CoviMap step = (CoviMap)steps.get(j);
								
								Object ouObj = step.get("ou");
								CoviList ouArray = new CoviList();
								if(ouObj instanceof CoviList){
									ouArray = (CoviList)ouObj;
								} else {
									ouArray.add((CoviMap)ouObj);
								}
								
								CoviMap chgStep = (CoviMap)chgSteps.get(j);
								
								Object chgOuObj = chgStep.get("ou");
								CoviList chgOuArray = new CoviList();
								if(chgOuObj instanceof CoviList){
									chgOuArray = (CoviList)chgOuObj;
								} else {
									chgOuArray.add((CoviMap)chgOuObj);
								}
								
								unitType = (String)step.get("unittype");
								if(step.containsKey("allottype")){
									allottype = (String)step.get("allottype");
								} else {
									allottype = "";
								}
								
								CoviMap stepTaskObj = new CoviMap();
								if(step.containsKey("taskinfo")) {
									stepTaskObj = (CoviMap)step.get("taskinfo");
								}
								
								if(stepTaskObj.containsKey("status")) {
									status = (String)stepTaskObj.get("status");
								} else {
									status = "";
								}
								
								if(ouArray.size() == chgOuArray.size()) {
									for(int z = 0; z < ouArray.size(); z++)
									{
										CoviMap ouObject = (CoviMap)ouArray.get(z);
										CoviMap chgOuObject = (CoviMap)chgOuArray.get(z);
										
										if(status.equalsIgnoreCase("pending") && ouObject.containsKey("person") && unitType.equalsIgnoreCase("person") 
												&& allottype.equalsIgnoreCase("parallel") && ouObject.containsKey("taskid") && ouObject.getString("taskid").equals(taskId)
												&& chgOuObject.containsKey("taskid") && chgOuObject.getString("taskid").equals(ouObject.getString("taskid"))){
											ouArray.set(z, chgOuObject);
											chkChgApvLine = true;
										}
									}
									
									step.remove("ou");
									if(ouArray.size() > 1) {
										step.put("ou", ouArray);
									} else {
										step.put("ou", (CoviMap)ouArray.get(0));
									}
								}
							}
							
							division.remove("step");
							if(steps.size() > 1) {
								division.put("step", steps);
							} else {
								division.put("step", (CoviMap)steps.get(0));
							}
						}
					}
				}
				
				root.remove("division");
				if(divisions.size() > 1) {
					root.put("division", divisions);
				} else {
					root.put("division", (CoviMap)divisions.get(0));
				}
			
				approvalLine.put("steps", root);
				
				if(chkChgApvLine) {
					changeApprovalLine = approvalLine.toString();
				}
			}
		}
		
		return changeApprovalLine;
	}
	
	public static String GetGovDocumentHTML(String pStrGovDocumentXML)
    {
        String sReturn = "";
		/* 시행문 변환시 오류로 인해 문자열 변경 */
		InputStreamReader 	ipr 	= null;
		BufferedReader 		reader 	= null;
		try {
	        String dtdPath = getGovDocsProperties().getProperty("dtd.path");				
			ipr 	= new InputStreamReader( new FileInputStream(dtdPath+"/siheng.xsl"), "EUC-KR" );		
			reader 	= new BufferedReader(ipr);
			StringBuffer 		sb 		= new StringBuffer();
			String sXslText;
			while((sXslText = reader.readLine())!= null) sb.append(sXslText+"\n");
			String pXMLText = pStrGovDocumentXML.replaceFirst("xml:stylesheet", "xml-stylesheet")
					 .replaceFirst("pubdoc.dtd", getGovDocsProperties().getProperty("dtd.path")+"/pubdoc.dtd" );
			
			// 23.09.15 본문 & 오류 수정
			pXMLText = StringEscapeUtils.unescapeHtml(pXMLText).replaceAll("&", "&amp;");

	        sReturn = convertXMLToPubDocHTMLFile(sb.toString(), pXMLText);
			
	        sReturn = sReturn.replaceAll("<?xml version=\"1.0\" encoding=\"utf-16\"?>", "");
	        sReturn = sReturn.replaceAll("&amp;", "&").replaceAll("null", "");
		
		}catch(IOException ioe) {
			LOGGER.error(ioe.getLocalizedMessage(), ioe); 
		}catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}finally {
			if (ipr != null) { try { ipr.close(); } catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (reader != null) { try { reader.close(); } catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}	
        return sReturn;
    }
	
	public static String convertXMLToPubDocHTMLFile(String pXslText, String pXMLText) throws Exception {
    	Source xmlSource = new StreamSource(new StringReader(pXMLText));
    	Source xsltSource = new StreamSource(new StringReader(pXslText));
    	TransformerFactory ft = TransformerFactory.newInstance();

    	StringWriter writer = new StringWriter();
    	StreamResult result = new StreamResult(writer);

    	Transformer trans = ft.newTransformer(xsltSource);
    	
    	trans.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
    	trans.setOutputProperty(OutputKeys.METHOD, "HTML");
    	trans.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
    	trans.setOutputProperty(OutputKeys.INDENT, "yes");
		
    	trans.transform(xmlSource, result);

    	return writer.toString();
    } 
	
	public void doEditProcess(CoviMap formObj) throws Exception{
		CoviMap params = new CoviMap();
		
		// Process Description 데이터 변경
		if(formObj.has("FormInstID")) {
			params.put("FormInstID", formObj.getString("FormInstID"));
			coviMapperOne.update("form.forLegacy.updateModifyProcessDesc", params);
		}
		
		// 결재선 편집
		if(formObj.has("ChangeApprovalLine")) {
			if (formObj.has("processID") && formObj.has("parentprocessID")) {
				String domainData = "";
				
				List<String> processIDs = new ArrayList<>();
				if (!formObj.getString("processID").equals("0")) {
					processIDs.add(formObj.getString("processID"));
				}
				if (!formObj.getString("parentprocessID").equals("0")) {
					processIDs.add(formObj.getString("parentprocessID"));
				}
				
				if (formObj.has("ApprovalLine") && !formObj.getString("ApprovalLine").equals("")) {
					domainData = formObj.getString("ApprovalLine");
					
					// 결재선 변경 후 저장
					params.clear();
					params.put("processIDs", processIDs);
					params.put("DomainDataContext", domainData);
					coviMapperOne.update("form.formdomaindata.updateDomainDataIN", params);
					
					// 엔진 호출
					String taskID = formObj.optString("taskID");
					
					if(!taskID.isEmpty()) {
						CoviMap variableObj = new CoviMap(); // CoviMap
						variableObj.setConvertJSONObject(false); // value는 string으로 넘겨야됨
						variableObj.put("name", "g_appvLine");
						variableObj.put("value", domainData);
						variableObj.put("scope", "global");
						engineSvc.requestUpdateValue(taskID, "g_appvLine", variableObj);
					}
				}
			}
		}
	}

	public CoviMap getLastModifiedDate(CoviMap params) throws Exception{
		return coviMapperOne.selectOne("form.forminstance.selectLastModifiedDate", params);
	}
}
