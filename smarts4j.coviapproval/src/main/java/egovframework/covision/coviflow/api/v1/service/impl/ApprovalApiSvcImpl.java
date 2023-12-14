package egovframework.covision.coviflow.api.v1.service.impl;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.Arrays;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.annotation.Resource;

import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DateHelper;
import egovframework.covision.coviflow.api.v1.service.ApprovalApiSvc;
import egovframework.covision.coviflow.common.util.ChromeRenderManager;
import egovframework.covision.coviflow.form.dto.FormRequest;
import egovframework.covision.coviflow.form.dto.UserInfo;
import egovframework.covision.coviflow.form.service.FormAuthSvc;
import egovframework.covision.coviflow.form.service.FormSvc;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("approvalApiService")
public class ApprovalApiSvcImpl extends EgovAbstractServiceImpl implements ApprovalApiSvc{
	private static final Logger LOGGER = LogManager.getLogger(ApprovalApiSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	public FormSvc formSvc;
	
	@Autowired
	private FormAuthSvc formAuthSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
	
	@Override
	public CoviMap getFormObjForProcess(CoviMap param) throws Exception {
		CoviMap formObj = new CoviMap(param);
		
		CoviMap processInfo = coviMapperOne.selectOne("form.formLoad.selectProcess", param);
		if(processInfo == null || processInfo.isEmpty()) {
			throw new Exception ("TaskID Not Found from WorkItemID");
		}
		
		String strTaskID = processInfo.getString("TaskID");
		String wiUserCode = processInfo.getString("UserCode");
		String sessionUserID = SessionHelper.getSession("UR_Code");
		String sessionDeptID = SessionHelper.getSession("DEPTID");
		String sessionDNcode = SessionHelper.getSession("DN_Code");
		String processState = processInfo.optString("ProcessState");
		String workitemState = processInfo.has("State") ? processInfo.optString("State") : "";
		String strDeputyID = processInfo.has("DeputyID") ? processInfo.optString("DeputyID") : "";
		String subKind = processInfo.getString("SubKind");
		String strActionMode = param.optString("actionMode");
		String aMode = "APPROVAL";
		String isArchived = "false";
		String strReadMode = formSvc.getReadMode("", processInfo.optString("BusinessState"), processInfo.optString("SubKind"), processInfo.optString("State"), processInfo.optString("ProcessState"));
		CoviMap schemaContext = coviMapperOne.select("form.forLegacy.selectSchemaContext", processInfo).getJSONObject("SchemaContext");
		CoviMap baseObj = new CoviMap();
		baseObj.put("ProcessID", processInfo.optString("ProcessID"));
		baseObj.put("FormInstID", processInfo.optString("FormInstID"));
		baseObj.put("Archived", "false");
		baseObj.put("Bstored", "false");
		
		// 버튼리스트
		CoviList buttonInfo = new CoviList();
		CoviMap approvalLine = getDomainData(baseObj);
		CoviMap formInstance = getFormInstanceData(baseObj); // forminstance 정보 가져오기
		if(!StringUtil.isNull(param.optString("workitemID"))) { // 사용가능한 버튼 리스트 생성 (workitemid를 받았을때만 상세버튼 설정 가능)
			buttonInfo = getButtonList(strReadMode, sessionUserID, sessionDeptID, sessionDNcode, processInfo, approvalLine, formInstance, schemaContext);
		}
		
		//Validation 체크
		if(subKind != null && subKind.startsWith("T")) { //일반결재/합의
			if (!sessionUserID.equals(wiUserCode) && !sessionUserID.equals(strDeputyID) ){
				throw new Exception("Unauthorized Task.");
			}
		}
		if (!processState.equals("288")){
			throw new Exception("This document Already completed.");
		}
		if (!workitemState.equals("288") && !(strActionMode.equals("ABORT") || strActionMode.equals("WITHDRAW"))){
			throw new Exception("This document Already processed.");
		}
		
		//진행중 편집 및 재기안시 제목, 본문 수정
		boolean bModify = false;
		CoviMap formData = new CoviMap();
		if(param.containsKey("bodyContext")) {
			formData.put("BodyContext", CoviMap.fromObject(new String(Base64.decodeBase64(formInstance.optString("BodyContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8), false));
			CoviMap setBodyContext = formData.getJSONObject("BodyContext");
			setBodyContext.putAll(param.getJSONObject("bodyContext"));
			bModify = true;
		}
		if(param.containsKey("subject")) {
			formData.put("Subject", param.optString("subject"));
			bModify = true;
		}		
		
		boolean bButton = false;
		if(buttonInfo.size() > 0) {
			for(Object obj : buttonInfo) {
				CoviMap btnMap = (CoviMap)obj;
				String getActionMode = strActionMode;
				if(strActionMode.equals("REDRAFT") || strActionMode.equals("RECAPPROVAL")) getActionMode = "Redraft";
				
				if(getActionMode.equalsIgnoreCase(btnMap.optString("code")) || "EDIT".equals(param.optString("btnFlag"))) {
					bButton = true;
					break;
				}
			}
			if(!bButton) {
				throw new Exception ("This document is "+strActionMode+" impassble");
			}
		} else {
			throw new Exception("Please check the form options");
		}
		
		// 버튼id/api코드 : APPROVE , 실제 결재코드 :  APPROVAL 이므로 변경
		if(strActionMode.equals("APPROVE")) formObj.put("actionMode", "APPROVAL");
		
		//협조,합의문서 기안취소 및 회수. 병렬처리로 인해 진행중인 TaskID로 변경
		if(strActionMode.equals("ABORT") || strActionMode.equals("WITHDRAW")) {
			CoviMap cancelData = coviMapperOne.selectOne("form.forLegacy.selectCancelData", processInfo);
			strTaskID = cancelData.optString("TaskID");
			workitemState = cancelData.optString("State");

			if(strTaskID == null || "".equals(strTaskID)) {
				throw new Exception ("TaskID Not Found");
			}
		}else if((strActionMode.equals("REDRAFT") && !formObj.containsKey("approvalLine")) || strActionMode.equals("RECAPPROVAL")) {//재기안, 접수시
			aMode = "REDRAFT";
			formObj.put("ApprovalLine", approvalLine);
			
			CoviMap params = new CoviMap();
			params.put("IsArchived", isArchived);
			params.put("processDescID", processInfo.optString("ProcessDescriptionID"));
        	CoviMap processDesObj = new CoviMap();
        	CoviList processDeslist = (CoviList)(formSvc.selectProcessDes(params)).get("list");
        	if(processDeslist.size() > 0) processDesObj = processDeslist.getJSONObject(0);
        	if(param.optBoolean("isFile")) {
        		processDesObj.put("IsFile", "Y");
        		CoviMap orgAttachInfo = new CoviMap();
    			orgAttachInfo = CoviMap.fromObject(new String(Base64.decodeBase64(formInstance.optString("AttachFileInfo").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8), false);
    			
    			CoviList oldFileList = orgAttachInfo.getJSONArray("FileInfos");
    			
    			CoviList newFileList = param.getJSONObject("AttachFileInfo").getJSONArray("FileInfos");
    			int newFileCnt = oldFileList.size();
    			for(Object Obj : newFileList) {
    				CoviMap map = (CoviMap)Obj;
    				newFileCnt++;
    				String newFileID = processInfo.optString("FormInstID") +"_"+ newFileCnt;
    				map.put("ID",newFileID);
    				oldFileList.add(map);
    			}
    			formData.put("AttachFileInfo", orgAttachInfo.toString());
        	}
        	if(bModify) processDesObj.put("IsModify", "Y");
        	formObj.put("userid", sessionUserID);
        	formObj.put("FormPrefix", formSvc.selectFormPrefixData(baseObj));
        	formObj.put("parentprocessID", processInfo.optString("ParentProcessID"));
        	formObj.put("ProcessDescription", processDesObj);
        	if(strActionMode.equals("RECAPPROVAL")) formObj.put("actionMode", "APPROVAL");
		}
		
		
		// TODO 부서합의 재기안 등 부서코드 workitem 처리

		if(!formData.isEmpty()) formObj.put("FormData", formData);
		formObj.put("taskID", strTaskID);
		formObj.put("mode", aMode);
		formObj.put("subkind", subKind);
		formObj.put("FormInstID", processInfo.getString("FormInstID"));
		formObj.put("processID", processInfo.optString("ProcessID"));		
		if(strReadMode.equals("PCONSULT") && !(strActionMode.equals("ABORT") || strActionMode.equals("WITHDRAW"))) {//합의시 actionMode는 동의, 거부
			formObj.put("mode", strReadMode);
			if(strActionMode.equals("APPROVAL")) formObj.put("actionMode", "AGREE");
			else formObj.put("actionMode", "DISAGREE");
		}
		if("EDIT".equals(param.optString("btnFlag"))) {
			formObj.put("actionMode", ""); //필수값 처리
		}
		return formObj;
	}
	
	@Override
	public CoviMap getFormData(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap formData = new CoviMap();
		CoviMap apiFormData = new CoviMap();
		
		String type = params.optString("type"); // P:ProcessID,F:FormInstID
		String key = params.optString("key");
		String workitemID = params.optString("workitemID");
		CoviMap baseInfo = new CoviMap(); // ProcessID, ParentProcessID, FormInstID, FormID, SchemaID, WorkitemID, ProcessdescriptionID, FormTempID, FormPrefix, Subkind, ReadMode, Archived, Bstored, IsSecdoc
		
		FormRequest formRequest; // 기본정보(요청정보)
		UserInfo userInfo; // 기본정보(사용자정보)
		
    	CoviMap processObj = new CoviMap(); // procses, processDescription 정보
    	
    	CoviMap formInstance = new CoviMap(); // forminstance 정보
    	CoviMap tempInstInfo = new CoviMap(); // formtempinstbox 정보
    	CoviMap bodyContext = new CoviMap(); // 본문(bodycontext) 정보
    	CoviMap bodyData = new CoviMap(); // 본문(하위테이블) 정보
    	
    	CoviMap forms = new CoviMap(); // 양식 설정 정보
    	CoviMap extInfo = new CoviMap(); // 양식 상세 설정정보
    	CoviMap subtableInfo = new CoviMap(); // 하위테이블 설정 정보
        CoviMap autoApprovalLine = new CoviMap(); // 자동결재선 정보
        
    	CoviMap formSchema = new CoviMap(); // 스키마(프로세스) 설정 정보
    	CoviMap schemaContext = new CoviMap();
    	
    	CoviMap approvalLine = new CoviMap(); // 결재선 정보
    	CoviMap approvalLineToken = new CoviMap(); // 결재선 정보(의견첨부 토큰 포함)
    	
    	CoviList comment = new CoviList(); // 의견정보
    	
    	CoviList fileInfos = new CoviList(); // 첨부파일 정보 (sys_file 기준)
    	
    	try {
    		
	    	// 키값 종류에 따라 process, forminstance 정보 조회
	    	if(type.equals("P")) {
	    		baseInfo.put("ProcessID", key);
	    		baseInfo.put("WorkitemID", workitemID);
	    		processObj = getProcessData(baseInfo); // process 정보 가져오기
	    		if(processObj == null || processObj.optString("ProcessID").equals("")) {
	    			throw new Exception("Process Data Not Found.[" + baseInfo.optString("ProcessID") + "].");
	    		}else if(processObj.optJSONObject("ProcessDescription").isEmpty()) {
	    			throw new Exception("ProcessDescription Data Not Found.[" + baseInfo.optString("ProcessdescriptionID") + "].");
	    		}
	    		
	    		key = processObj.optString("ProcessID");
	    		baseInfo.put("ProcessID", key); // workitem에 해당하는 processid가 다른경우 대비해 업데이트
	    		baseInfo.put("FormInstID", processObj.optString("FormInstID"));
	    		formInstance = getFormInstanceData(baseInfo); // forminstance 정보 가져오기
	    		if(formInstance == null || formInstance.isEmpty()) {
	    			throw new Exception("Forminst Data Not Found.[" + baseInfo.optString("FormInstID") + "].");
	    		}
	    	} else if(type.equals("F")) {
	    		baseInfo.put("FormInstID", key);
	    		formInstance = getFormInstanceData(baseInfo); // forminstance 정보 가져오기
	    		if(formInstance == null || formInstance.isEmpty()) {
	    			throw new Exception("Forminst Data Not Found.[" + baseInfo.optString("FormInstID") + "].");
	    		}
	    		
	    		baseInfo.put("ProcessID", formInstance.optString("ProcessID"));
	    		baseInfo.put("WorkitemID", workitemID); // type이 F 인데 wiid를 넘기는경우
	    		processObj = getProcessData(baseInfo); // process 정보 가져오기
	    		baseInfo.put("ProcessID", processObj.optString("ProcessID")); // workitem에 해당하는 processid가 다른경우 대비해 업데이트
	    		
	    		if(processObj == null || processObj.optString("ProcessID").equals("")) {
	    			tempInstInfo = getFormTempInstID(baseInfo); // 임시저장 문서 체크
	    			if(tempInstInfo == null || tempInstInfo.isEmpty()) { // 임시저장 문서가 아닌데 프로세스정보가 없으면 오류
	    				throw new Exception("Process Data Not Found.[" + baseInfo.optString("ProcessID") + "].");
		    		}else {
		    			baseInfo.put("FormTempID", tempInstInfo.optString("FormTempInstBoxID"));
		    		}
	    		}else if(processObj.optJSONObject("ProcessDescription").isEmpty()) {
	    			throw new Exception("ProcessDescription Data Not Found.[" + baseInfo.optString("ProcessdescriptionID") + "].");
	    		}
	    	}else { // type.equals("T")
	    		baseInfo.put("FormTempID", key);
	    		tempInstInfo = getFormTempInstID(baseInfo);
	    		if(tempInstInfo == null || tempInstInfo.isEmpty()) {
	    			throw new Exception("FormTempInstBoxID Data Not Found.[" + baseInfo.optString("FormTempID") + "].");
	    		}
	    		baseInfo.put("FormInstID", tempInstInfo.optString("FormInstID"));
	    		
	    		formInstance = getFormInstanceData(baseInfo); // forminstance 정보 가져오기
	    		if(formInstance == null || formInstance.isEmpty()) {
	    			throw new Exception("Forminst Data Not Found.[" + baseInfo.optString("FormInstID") + "].");
	    		}
	    	}
	    	// base64 인코딩된 값들 디코딩
	    	if(formInstance.has("BodyContext") && !formInstance.get("BodyContext").equals("")) {
				bodyContext = CoviMap.fromObject(new String(Base64.decodeBase64(formInstance.optString("BodyContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8), false);
				formInstance.remove("BodyContext");
			}
	    	if(formInstance.has("AttachFileInfo") && !formInstance.get("AttachFileInfo").equals("")) {
				formInstance.put("AttachFileInfo", CoviMap.fromObject(new String(Base64.decodeBase64(formInstance.optString("AttachFileInfo").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8)));
			}
	        
	    	
	    	// 양식 설정정보 조회
	    	baseInfo.put("FormID", formInstance.optString("FormID"));
	    	forms = getFormsData(baseInfo);
	    	if(forms == null || forms.isEmpty()) {
				throw new Exception("Form Data Not Found.[" + baseInfo.optString("FormID") + "].");
			}
	    	// 하위테이블 설정 정보
	    	if(!forms.get("SubTableInfo").equals("")) subtableInfo = forms.getJSONObject("SubTableInfo");
			forms.remove("SubTableInfo");
			// 자동결재선 정보
			if(!forms.get("AutoApprovalLine").equals("")) autoApprovalLine = forms.getJSONObject("AutoApprovalLine");
			forms.remove("AutoApprovalLine");
			// 양식 도움말과 양식 팝업 내용 디코딩
			if(forms.has("FormHelperContext") && !forms.get("FormHelperContext").equals("")){
				forms.put("FormHelperContext", new String(Base64.decodeBase64(forms.optString("FormHelperContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
			}
			if(forms.has("FormNoticeContext") && !forms.get("FormNoticeContext").equals("")){
				forms.put("FormNoticeContext", new String(Base64.decodeBase64(forms.optString("FormNoticeContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
			}
			// 양식 상세 설정정보 별도저장
			if(!forms.get("ExtInfo").equals("")){
				extInfo = forms.getJSONObject("ExtInfo");
			}
			forms.remove("ExtInfo");
			
			
			// 스키마(프로세스) 설정 정보 조회
			baseInfo.put("SchemaID", forms.getString("SchemaID"));
			formSchema = getSchemaData(baseInfo);
	    	if(formSchema == null || formSchema.isEmpty()) {
				throw new Exception("Schema Data Not Found.[" + baseInfo.optString("SchemaID") + "].");
			}
			// SchemaContext
			if(!formSchema.get("SchemaContext").equals(""))
				schemaContext = formSchema.getJSONObject("SchemaContext");
			
			// 기본정보 생성
			formRequest = initFormRequest(baseInfo);
			userInfo = initUserInfo();
			
			// 삭제/취소 등 문서 유효성 체크
			if(processObj != null && !processObj.optString("ProcessID").equals("")){ // !type.equals("T")
				boolean successYN = true;
				if(!formRequest.getProcessID().equals(processObj.getString("ProcessID"))){
		    		successYN = false;
		    	}else{
		    		String processState = processObj.optString("ProcessState");
		    		String workitemState = processObj.optString("State");
		    		if((processState.equals("") && workitemState.equals("")) || workitemState.equals("546") || processState.equals("546") 
		        				|| ( workitemState.equals("688") || processState.equals("688") )){
		            	successYN = false;
		    		}
		    	}
		    	if (!successYN) 
		    		throw new Exception(DicHelper.getDic("msg_apv_082")); //존재하지 않는 결재문서입니다. 
		    	
		    	// 문서 읽기 권한 체크 formAuthSvc.hasWriteAuth(formRequest, userInfo)
		    	if(!formAuthSvc.hasReadAuth(formRequest, userInfo)) {
		    		throw new Exception(DicHelper.getDic("msg_noViewACL")); // 조회 권한이 없습니다.
		    	}
			}else { // 임시저장 문서
				boolean hasWriteAuth = formAuthSvc.hasWriteAuth(formRequest, userInfo);
                userInfo.setHasWriteAuth(hasWriteAuth);
            	if(!hasWriteAuth)
            		throw new SecurityException(DicHelper.getDic("msg_WriteAuth")); // 작성 권한이 없습니다.
			}
			
	    	/* 초기 변수값 수정
			 *  - ReadMode 변경
			*/ 
	    	/*
	    	String strReadMode = formRequest.getReadMode();
	        if (!strReadMode.equals("COMPLETE"))
	        {
	        	strReadMode = formSvc.getReadMode(strReadMode,  !processObj.isNullObject() ? processObj.optString("BusinessState") : "", formRequest.getSubkind(), (!processObj.isNullObject() && processObj.has("State")) ? processObj.getString("State") : "");
	        	formRequest.setReadMode(strReadMode);
	        } else if(processObj.optString("ProcessState").equals("288")) {
	    		strReadMode = "PROCESS";
	    		formRequest.setReadMode(strReadMode);
	    		formRequest.setReadModeTemp(strReadMode);
	        }
	        */
	    	// 최초에 mode를 받지 않으므로 위 소스 의미가 없음, 추출한 mode로 모두 셋팅
	    	String strReadMode = formSvc.getReadMode("",  processObj.optString("BusinessState"), formRequest.getSubkind(), processObj.optString("State"), processObj.optString("ProcessState"));
	        formRequest.setReadMode(strReadMode);
	        formRequest.setReadModeTemp(strReadMode);
	        
			// 본문(하위테이블) 정보 조회
			bodyData = formSvc.getBodyData(subtableInfo, extInfo, baseInfo.optString("FormInstID"));				/// 하위테이블 데이터가 있을 경우 bodyData에 세팅
			
			
			// 결재선 정보 조회
			if(processObj != null && !processObj.optString("ProcessID").equals("")){ // !type.equals("T")
				approvalLine = getDomainData(baseInfo);
			}else { // 임시저장 문서
				approvalLine = getDomainDataTempBox(baseInfo, userInfo);
			}

			if(approvalLine == null || approvalLine.isEmpty()) {
				throw new Exception("ApprovalLine Data Not Found.[ProcessID:" + baseInfo.optString("ProcessID") + "].");
			}
			approvalLineToken = egovframework.covision.coviflow.common.util.ComUtils.changeCommentFileInfos(approvalLine);
			
			
			// 의견정보 조회
			comment = getCommentData(baseInfo);
	    	
			
			// Request
			CoviMap requestData = getReuqestData(formRequest);
			requestData.put("userCode", processObj.optString("UserCode"));
			// loct/gloct 구하는것이 버튼리스트 조회하는것과 겹치므로, getButtonList 함수에 requestData 객체 넘겨서 loct/gloct 수정함
			
			
			// 첨부파일 정보 (sys_file 기준) 가져오기
			fileInfos = getFileInfosData(baseInfo);
			
			/*
			formData.put("FormInfo", forms);
			formData.put("FormInstanceInfo", formInstance);
			formData.put("ProcessInfo", processObj);				// process 및 workitem 조합 데이터
			formData.put("SchemaContext", schemaContext);
			formData.put("BodyContext", bodyContext);
			formData.put("BodyData", bodyData);
			formData.put("ApprovalLine", approvalLineToken);
			formData.put("ExtInfo", extInfo);
			formData.put("SubTableInfo", subtableInfo);
			formData.put("AutoApprovalLine", autoApprovalLine);
			//formData.put("WorkedAutoApprovalLine", workedAutoApprovalLine);
			formData.put("JWF_Comment", comment);
			//formData.put("Request", requestData); // getButtonList 에서 loct/gloct 수정하므로 이후에 추가하도록
			//formData.put("AppInfo", appInfo);
			//formData.put("BaseConfig", baseConfig);
			formData.put("FileInfos", fileInfos);
			*/
			
			
			// 결재선 일반적 형태로 변환
			apiFormData.put("approvalLine", getApiApprovalLine(approvalLineToken, schemaContext)); // ApprovalLine , SchemaContext
						
			// 버튼리스트
			CoviList buttonInfo = new CoviList();
			if(!StringUtil.isNull(workitemID)) { // 사용가능한 버튼 리스트 생성 (workitemid를 받았을때만 상세버튼 설정 가능)
				buttonInfo = getButtonList(strReadMode, userInfo.getUserID(), userInfo.getApvDeptID(), userInfo.getDNCode(), processObj, approvalLineToken, formInstance, schemaContext, requestData);
			}
			//formData.put("Request", requestData); // getButtonList 에서 loct/gloct 수정하므로 이후에 추가하도록
			apiFormData.put("buttonInfo", buttonInfo);
			
			// 기타의견 정보
			apiFormData.put("etcComment", comment);
						
			// 첨부파일 정보
			apiFormData.put("fileInfo", fileInfos);
			
			// 기타 양식정보 취합(문서기본정보, 다국어처리, 코드명추출, url생성 등)
			apiFormData.put("formInfo", getApiFormInfo(forms, formInstance, processObj, bodyContext, bodyData, requestData));
						
			returnList.put("formData", apiFormData);
			returnList.put("status", Return.SUCCESS.toString());
			returnList.put("message", "처리되었습니다");
    	} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL.toString());
			//returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			returnList.put("message", npE.getMessage());
		} catch (Exception e) {
			returnList.put("status", Return.FAIL.toString());
			//returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			returnList.put("message", e.getMessage());
		}		
    	
		return returnList;
	}
	
	@Override
	public CoviMap getProcessData(CoviMap baseInfo) throws Exception {
		CoviMap processObj = new CoviMap();
        String processID = baseInfo.optString("ProcessID");
        String workitemID = baseInfo.optString("WorkitemID");
        String isArchived = "false";
        String bStored  = "false";
        
        if(!processID.equals("")){
        	CoviMap params = new CoviMap();
        	params.put("processID", processID);
        	params.put("workitemID", workitemID);
        	params.put("IsArchived", isArchived);					// Archive 가 있는 테이블은 반드시 넘겨야 함
        	params.put("bStored", bStored);

        	// "ProcessID,ProcessDescriptionID,FormInstID,      ProcessState,ParentProcessID,         DocSubject,         BusinessState,ProcessName"
        	// "ProcessID,ProcessDescriptionID,FormInstID,State,ProcessState,ParentProcessID,UserCode,DocSubject,DeputyID,BusinessState,ProcessName,TaskID,SubKind"
        	CoviMap resultObj = formSvc.selectProcess(params);
        	CoviList resultList = (CoviList)resultObj.get("list");
        	if(resultList.size() > 0) processObj = resultList.getJSONObject(0);	// process 및 workitem 조합 데이터
        	
        	// 프로세스 조회 후, 값이 변경된 경우 다시 세팅
        	if(resultObj.containsKey("IsArchived")) {
        		isArchived = resultObj.getString("IsArchived");
        		params.put("IsArchived", isArchived);
        	}
        	if(resultObj.containsKey("bStored")) {
        		bStored = resultObj.getString("bStored");
        		params.put("bStored", bStored);
        	}
        	
        	// "ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2"
        	params.put("processDescID", processObj.optString("ProcessDescriptionID"));
        	CoviMap processDesObj = new CoviMap();
        	CoviList processDeslist = (CoviList)(formSvc.selectProcessDes(params)).get("list");
        	if(processDeslist.size() > 0) processDesObj = processDeslist.getJSONObject(0);
        	
            processObj.put("ProcessDescription",processDesObj);
            
            baseInfo.put("Archived", isArchived);
            baseInfo.put("Bstored", bStored);
            baseInfo.put("ProcessdescriptionID", processDesObj.optString("ProcessDescriptionID"));
            baseInfo.put("Subkind", processObj.optString("SubKind"));
            baseInfo.put("ParentProcessID", processObj.optString("ParentProcessID"));
            baseInfo.put("IsSecdoc", processDesObj.optString("IsSecureDoc"));            
        }
        
        return processObj;
	}
	
	@Override
	public CoviMap getFormInstanceData(CoviMap baseInfo) throws Exception {
		CoviMap formInstance = new CoviMap();
        String formInstanceID = baseInfo.optString("FormInstID");
        
        if(!formInstanceID.equals("")){
        	
    		CoviMap params = new CoviMap();
        	params.put("formInstID", formInstanceID);
        	
        	// "FormInstID,ProcessID,FormID,SchemaID,Subject,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,CompletedDate,DeletedDate,LastModifiedDate,LastModifierID,EntCode,EntName,DocNo,DocLevel,DocClassID,DocClassName,DocSummary,IsPublic,SaveTerm,AttachFileInfo,AppliedDate,AppliedTerm,ReceiveNo,ReceiveNames,ReceiptList,BodyType,BodyContext,DocLinks,EDMSDocLinks,RuleItemInfo"
        	if(baseInfo.optString("Bstored").equalsIgnoreCase("true")){
        		CoviList resultList = (CoviList)(formSvc.selectFormInstanceStore(params)).get("list");
            	if(resultList.size() > 0) formInstance = resultList.getJSONObject(0);				
        	}else{
				CoviList resultList = (CoviList)(formSvc.selectFormInstance(params)).get("list");
				if(resultList.size() > 0) formInstance = resultList.getJSONObject(0);				
			}
        }
        
        return formInstance;
	}
	
	@Override
	public CoviMap getFormTempInstID(CoviMap baseInfo) throws Exception {
		CoviMap tempInstInfo = new CoviMap();
        
		String formTempInstID = baseInfo.optString("FormTempID"); 
		String formInstID = baseInfo.optString("FormInstID");
		
        if(!formTempInstID.equals("") || !formInstID.equals("")){
    		CoviMap params = new CoviMap();
        	params.put("formTempInstID", formTempInstID);
        	params.put("formInstID", formInstID);
        	
    		CoviList list = coviMapperOne.list("form.formLoad.selectFormTempInstBox", params);
    		list = CoviSelectSet.coviSelectJSON(list, "FormTempInstBoxID,FormInstID,FormID,SchemaID,FormPrefix,FormInstTableName,UserCode,CreatedDate,Subject,Kind");
    		if(list.size() > 0) tempInstInfo = list.getJSONObject(0);
        	
        }
        
        return tempInstInfo;
	}
	
	@Override
	public CoviMap getFormsData(CoviMap baseInfo) throws Exception {
		CoviMap forms = new CoviMap();
		String formID = baseInfo.optString("FormID");
		
		if(!formID.equals("")){
			
			CoviMap params = new CoviMap();
			params.put("formID", formID);
			params.put("userID", SessionHelper.getSession("USERID"));
			
			CoviList resultList = (CoviList)(formSvc.selectForm(params)).get("list");
        	if(resultList.size() > 0) forms = resultList.getJSONObject(0);
			
			baseInfo.put("FormPrefix", forms.optString("FormPrefix"));
		}
		return forms;
	}
	
	@Override
	public CoviMap getSchemaData(CoviMap baseInfo) throws Exception {
		CoviMap formSchema = new CoviMap();
        String schemaID = baseInfo.optString("SchemaID");
        
        if(!schemaID.equals("")){
        	CoviMap params = new CoviMap();
        	params.put("schemaID", schemaID);
        	
        	// "SchemaID,SchemaName,SchemaDesc,SchemaContext"
        	CoviList resultList = (CoviList)(formSvc.selectFormSchema(params)).get("list");
        	if(resultList.size() > 0) formSchema = resultList.getJSONObject(0);
        }
        
        return formSchema;
	}

	@Override
	public CoviMap getDomainData(CoviMap baseInfo) throws Exception {
		CoviMap approvalLine = new CoviMap();
        String processID = baseInfo.optString("ProcessID");
        
        if(!processID.equals("")){
        	CoviMap params = new CoviMap();
        	params.put("processID", processID);
        	params.put("IsArchived", baseInfo.optString("Archived"));					// Archive 가 있는 테이블은 반드시 넘겨야 함
        	params.put("bStored", baseInfo.optString("Bstored"));
			
        	// "DomainDataID,DomainDataName,ProcessID,DomainDataContext"
        	CoviMap domainData = new CoviMap();
        	CoviList resultList = (CoviList)(formSvc.selectDomainData(params)).get("list");
        	if(resultList.size() > 0) domainData = resultList.getJSONObject(0);
        	if(!domainData.optString("DomainDataContext").equals("")) approvalLine = domainData.getJSONObject("DomainDataContext");
        }
        
        return approvalLine;
	}
	
	@Override
	public CoviMap getDomainDataTempBox(CoviMap baseInfo, UserInfo userInfo) throws Exception {
		CoviMap approvalLine = new CoviMap();
        String formTempID = baseInfo.optString("FormTempID");
        
        if(!formTempID.equals("")){
        	CoviMap params = new CoviMap();
        	params.put("OwnerID", formTempID);
        	
        	CoviMap returnData = (((CoviList)(formSvc.selectPravateDomainData(params)).get("list")).getJSONObject(0));
        	approvalLine = returnData.getJSONObject("PrivateContext");
        	
        	CoviMap apvLine = approvalLine.getJSONObject("steps");
    		if(apvLine.has("division")){													// division
    			CoviList oDivisions = new CoviList();
    			if(apvLine.get("division") instanceof CoviMap)
    				oDivisions.add(apvLine.getJSONObject("division"));
    			else if(apvLine.get("division") instanceof CoviList)
    				oDivisions = apvLine.optJSONArray("division");
    			
				CoviMap oDivision = oDivisions.getJSONObject(0);
				
				if(oDivision.has("step")){											// step
					CoviList oSteps = new CoviList();
					if(oDivision.get("step") instanceof CoviMap)
						oSteps.add(oDivision.getJSONObject("step"));
					else if(oDivision.get("step") instanceof CoviList)
						oSteps = oDivision.optJSONArray("step");
					
					// 임시저장 문서는 결재자만 있으므로 0번쨰에 기안자 step 추가
					CoviMap initStep = new CoviMap();
					initStep.put("unittype","person");
					initStep.put("routetype","approve");
					initStep.put("name","기안자");
					CoviMap initOu = new CoviMap();
					initOu.put("code",userInfo.getApvDeptID());
					initOu.put("name",userInfo.getApvDeptName());
					CoviMap initPerson = new CoviMap();
					initPerson.put("code",userInfo.getUserID());
					initPerson.put("name",userInfo.getUserMultiName());
					initPerson.put("position",userInfo.getJobPositionCode() + ";" + userInfo.getUserMultiJobPositionName());
					initPerson.put("title",userInfo.getJobTitleCode() + ";" + userInfo.getUserMultiJobTitleName());
					initPerson.put("level",userInfo.getJobLevelCode() + ";" + userInfo.getUserMultiJobLevelName());
					initPerson.put("oucode",userInfo.getApvDeptID());
					initPerson.put("ouname",userInfo.getApvDeptName());
					initPerson.put("sipaddress",userInfo.getUserMail());
					CoviMap initTaskinfo = new CoviMap();
					initTaskinfo.put("status","inactive");
					initTaskinfo.put("result","inactive");
					initTaskinfo.put("kind","charge");
					
					initPerson.put("taskinfo",initTaskinfo);
					initOu.put("person",initPerson);
					initStep.put("ou",initOu);
					
					oSteps.add(0, initStep);
				}
    		}
        }
        
        return approvalLine;
	}
	
	@Override
	public CoviList getCommentData(CoviMap baseInfo) throws Exception {
		CoviList comment = new CoviList();
        String formInstID = baseInfo.optString("FormInstID");
        
        if(!formInstID.equals("")){
        	CoviMap params = new CoviMap();
        	params.put("FormInstID", formInstID);
        	
        	// "CommentID,FormInstID,ProcessID,UserCode,UserName,InsertDate,Mode,Kind,Comment,Comment_fileinfo"
        	comment = (CoviList)(formSvc.selectComment(params)).get("list");
        	
        	// 결재문서파일, 결재선파일과 맞추기위해 FileName 추가
        	for(Object objComment : comment){
				CoviMap mapComment = (CoviMap) objComment;
				if(mapComment.has("Comment_fileinfo")){
					CoviList commentFiles = new CoviList();
					commentFiles = mapComment.optJSONArray("Comment_fileinfo");
					for(Object objFile : commentFiles){
						CoviMap mapFile = (CoviMap) objFile;
						mapFile.put("FileName", mapFile.optString("name"));
					}
				}
        	}
        }
        
        return comment;
	}
	
	@Override
	public CoviList getFileInfosData(CoviMap baseInfo) throws Exception {
		CoviList fileInfos = new CoviList();
        String formInstID = baseInfo.optString("FormInstID");
        
        if(!formInstID.equals("")){
        	CoviMap params = new CoviMap();
        	params.put("ServiceType", "Approval");
        	params.put("ObjectType", "DEPT");
        	params.put("FormInstID", formInstID);
        	
        	// "FileID,StorageID,ServiceType,ObjectID,ObjectType,MessageID,SaveType,LastSeq,Seq,FilePath,FileName,SavedName,Extention,Size,RegistDate,RegisterCode,CompanyCode,StorageLastSeq,StorageFilePath,InlinePath,IsActive"
        	fileInfos = (CoviList)(formSvc.selectFiles(params)).get("list");
        }
        
        return fileInfos;
	}
	
	private CoviMap getReuqestData(FormRequest formRequest) {
		CoviMap requestData = new CoviMap();
		
		/* loct 포함 -> CheckLoct()함수 값 */
		//requestData.put("editmode", formRequest.getEditMode());
		//requestData.put("admintype", formRequest.getAdmintype());
		//requestData.put("isAuth", formRequest.getIsAuth());
		requestData.put("mode", formRequest.getReadMode());
		requestData.put("processID", formRequest.getProcessID());
		requestData.put("workitemID", formRequest.getWorkitemID());
		//requestData.put("performerID", formRequest.getPerformerID());
		requestData.put("userCode", formRequest.getUserCode());
		requestData.put("gloct", formRequest.getGLoct());
		requestData.put("loct", "");
		requestData.put("formID", formRequest.getFormId());
		requestData.put("forminstanceID", formRequest.getFormInstanceID());
		requestData.put("subkind", formRequest.getSubkind());
		requestData.put("formtempID", formRequest.getFormTempInstanceID());
		//requestData.put("forminstancetablename", formRequest.getFormInstanceTableName());
		//requestData.put("readtype", formRequest.getReadtype());
		requestData.put("processdescriptionID", formRequest.getProcessdescriptionID());
		//requestData.put("reuse", formRequest.getIsReuse());
		//requestData.put("ishistory", formRequest.getIsHistory());
		//requestData.put("usisdocmanager", formRequest.getIsUsisdocmanager());
		requestData.put("secdoc", formRequest.getIsSecdoc());
		
//		String strgovDocReply = formRequest.getIsgovDocReply();
//		if (strgovDocReply.equals("Y")) {
//			CoviMap govObj = CoviMap.fromObject(egovframework.coviframework.util.ComUtils.getProperties("govdocs.properties"));
//			if(govObj.optString("gov24.reply.use", "N").equals("Y")) {
//				requestData.put("isgovDocReply", strgovDocReply); 
//				requestData.put("ReplyFlag", formSvc.selectCheckReplyDoc(strFormInstanceID) );
//				requestData.put("govFormInstID", formRequest.getGovFormInstID());
//				
//				if(!formRequest.getSenderInfo().equals("")) {
//					requestData.put("gov24sender", formSvc.selectGov24SenderInfo(formRequest.getSenderInfo()));
//				}
//			}
//		}
		
		
//		String isLegacy = formRequest.getIsLegacy();
//		if(isLegacy.equals(""))
//			isLegacy = (forLegacySvc.isLegacyFormCheck(strFormPrefix)) ? "Y" : "N";
//		requestData.put("isLegacy", isLegacy);
		
		//requestData.put("isTempSaveBtn", formRequest.getIsTempSaveBtn());
		//requestData.put("legacyDataType", formRequest.getLegacyDataType());
		
		//CoviMap initializedValueForTemplate = pInitValueForTemplate(strReadMode, formRequest.getReadtype(), formRequest.getEditMode(), strFormFileName, strUnifiedFormYN, filePath);
		
		//requestData.put("templatemode", initializedValueForTemplate.getString("strTemplateType"));
		
		// getApvSpec 에서 셋팅하는것으로 변경
//		String strProcessID = formRequest.getProcessID();
//		if(strProcessID == null || strProcessID.equals("") || processObj.isNullObject() || processObj.isEmpty() ){
//			requestData.put("loct", formRequest.getReadMode());
//		}else{
//			requestData.put("loct", getLOCTData(formRequest, formRequest.getReadMode(), userInfo.getUserID(), processObj));
//		}
		
		//requestData.put("isMobile", formRequest.getIsMobile());
		
		//문서유통 유형 비교를 위해 추가
		//requestData.put("menukind", formRequest.getMenuKind());
		//requestData.put("doclisttype", formRequest.getDoclisttype());
		//requestData.put("govstate", formRequest.getGovState());
		//requestData.put("govdocid", formRequest.getGovDocID());
		
		// 기록물 다안 권한처리를 위해 추가
		//requestData.put("govrecordid", formRequest.getGovRecordID());
		//requestData.put("govrecordrowseq", formRequest.getGovRecordRowSeq());
		
		return requestData;
	}
	
	private FormRequest initFormRequest(CoviMap params){
		FormRequest fReq = new FormRequest();
		
		/** Request */
		// ID
		fReq.setProcessID(params.optString("ProcessID"));
		fReq.setWorkitemID(params.optString("WorkitemID"));
        //fReq.setPerformerID(StringUtil.replaceNull(request.getParameter("performerID"), ""));
		fReq.setFormId(params.optString("FormID"));
		fReq.setFormInstanceID(params.optString("FormInstID"));
        fReq.setFormTempInstanceID(params.optString("FormTempID"));
		fReq.setProcessdescriptionID(params.optString("ProcessdescriptionID"));
        
        // mode 및 gloct, loct
		fReq.setReadMode(params.optString("ReadMode"));
        fReq.setReadModeTemp(params.optString("ReadMode"));
        //fReq.setReadtype(StringUtil.replaceNull(request.getParameter("Readtype"), ""));
        fReq.setGLoct("");
        
        fReq.setUserCode(""); // User Code (세션 정보 X, Performer 및 Workitem의 UserCode)
		fReq.setSubkind(params.optString("Subkind"));
        //fReq.setFormInstanceTableName(StringUtil.replaceNull(request.getParameter("forminstancetablename"), ""));
		fReq.setFormPrefix(params.optString("FormPrefix"));
        //fReq.setRequestFormInstID(StringUtil.replaceNull(request.getParameter("RequestFormInstID"), ""));
        
        //편집할 때 request로 받은 데이터로 세팅
//        if(request.getParameter("DocModifyApvLine") != null && !request.getParameter("DocModifyApvLine").equals(""))
//        	fReq.setDocModifyApvLine(CoviMap.fromObject(request.getParameter("DocModifyApvLine").replace("&quot;", "\"")));
        
		// 구분값 (Y | N)
		fReq.setEditMode("N"); // 편집 모드
		fReq.setArchived(params.optString("Archived")); // archived. 완료 여부
		fReq.setBstored(params.optString("Bstored")); // bStored. 이관함 여부
        //fReq.setAdmintype(StringUtil.replaceNull(request.getParameter("admintype"), "")); // 관리자 페이지에서 조회시 ADMIN
        //fReq.setIsAuth(StringUtil.replaceNull(request.getParameter("isAuth"), "")); 									// 사용자 문서함 권한 부여 여부
		fReq.setIsReuse(""); 									// 재사용 여부
//        fReq.setIsHistory(StringUtil.replaceNull(request.getParameter("ishistory"), "")); // 히스토리 여부
//        fReq.setIsUsisdocmanager(StringUtil.replaceNull(request.getParameter("usisdocmanager"), "")); // 문서 관리자 여부. Y
//        fReq.setIsTempSaveBtn(StringUtil.replaceNull(request.getParameter("isTempSaveBtn"), "Y")); // 임시저장 버튼 표시 여부
//        fReq.setIsgovDocReply(StringUtil.replaceNull(request.getParameter("isgovDocReply"), "N")); // 문서24 개인사용자에 대한 회신표시 여부
//        fReq.setSenderInfo(StringUtil.replaceNull(request.getParameter("senderInfo"), "")); // 문서24 발신한 개인사용자 정보
//        fReq.setGovFormInstID(StringUtil.replaceNull(request.getParameter("govFormInstID"), "")); // 문서24 개인회신을 위한 접수문서 frminstid
//        
		fReq.setIsSecdoc(params.optString("IsSecdoc")); // 기밀문서 여부
//        fReq.setIsMobile(StringUtil.replaceNull(request.getParameter("isMobile"), "N"));
//        fReq.setIsApvLineChg(StringUtil.replaceNull(request.getParameter("isApvLineChg"), "N"));
//        fReq.setIsLegacy(StringUtil.replaceNull(request.getParameter("isLegacy"), "")); // 외부 연동 여부 (기안 양식 오픈을 외부에서)
//        
//        fReq.setJsonBodyContext(StringUtil.replaceNull(request.getParameter("jsonBody"), "")); // 외부 연동시 기안 bodycontext (기안 양식 오픈을 외부에서)
//        fReq.setHtmlBodyContext(StringUtil.replaceNull(request.getParameter("htmlBody"), "")); // 외부 연동시 기안 html (기안 양식 오픈을 외부에서)
//        fReq.setMobileBodyContext(StringUtil.replaceNull(request.getParameter("mobileBody"), "")); // 외부 연동시 기안 html - 모바일 용
//        fReq.setLegacyBodyContext(StringUtil.replaceNull(request.getParameter("bodyContext"), "")); // 외부 연동시 기안 html 과 bodycontext (기안 양식 오픈을 외부에서)
//        fReq.setSubject(StringUtil.replaceNull(request.getParameter("subject"), "")); // 외부 연동시 제목 (기안 양식 오픈을 외부에서)
//        fReq.setLegacyDataType(StringUtil.replaceNull(request.getParameter("legacyDataType"), ""));	// 외부 연동 데이터 타입
//        
//        fReq.setMenuKind(StringUtil.replaceNull(request.getParameter("menukind"), "")); // 양식 구분값(전자결재/문서유통)
//        fReq.setDoclisttype(StringUtil.replaceNull(request.getParameter("doclisttype"), ""));
		fReq.setGovState("");
		fReq.setGovDocID("");
        // 기록물 다안기안 
		fReq.setGovRecordID("");
        
		fReq.setOwnerProcessId("");
        
        //fReq.setExpAppID(StringUtil.replaceNull(request.getParameter("ExpAppID"), "")); // 경비결재 오픈 여부 확인
		fReq.setOwnerExpAppID(""); // 경비결재 오픈 여부 확인
        
		fReq.setIsOpen(""); // 사업관리 오픈 여부 확인 [21-02-01 add]
		
		fReq.setParentProcessID(params.optString("ParentProcessID"));
		
		return fReq;
	}
	
	private UserInfo initUserInfo() throws Exception {
		UserInfo fSes = new UserInfo();
		//세션 값
        fSes.setUserID(SessionHelper.getSession("USERID"));
        fSes.setUserName(SessionHelper.getSession("USERNAME"));
        fSes.setUserMail(SessionHelper.getSession("UR_Mail"));
        fSes.setUserEmpNo(SessionHelper.getSession("UR_EmpNo"));
        fSes.setDeptID(SessionHelper.getSession("DEPTID"));
        fSes.setDeptName(SessionHelper.getSession("DEPTNAME"));
        fSes.setDNName(SessionHelper.getSession("DN_Name"));
        fSes.setDNCode(SessionHelper.getSession("DN_Code"));
        
        fSes.setJobPositionCode(SessionHelper.getSession("UR_JobPositionCode"));
        fSes.setJobPositionName(SessionHelper.getSession("UR_JobPositionName"));
        fSes.setJobTitleCode(SessionHelper.getSession("UR_JobTitleCode"));
        fSes.setJobTitleName(SessionHelper.getSession("UR_JobTitleName"));
        fSes.setJobLevelCode(SessionHelper.getSession("UR_JobLevelCode"));
        fSes.setJobLevelName(SessionHelper.getSession("UR_JobLevelName"));
        
        fSes.setDeptPath(SessionHelper.getSession("GR_GroupPath"));
        fSes.setGRFullName(SessionHelper.getSession("GR_FullName"));

        fSes.setURManagerCode(SessionHelper.getSession("UR_ManagerCode"));
        fSes.setURManagerName(SessionHelper.getSession("UR_ManagerName"));
        fSes.setURIsManager(SessionHelper.getSession("UR_IsManager"));
        
        // 사용자, 부서 다국어명 추가
        fSes.setUserMultiName(SessionHelper.getSession("UR_MultiName"));
        fSes.setUserMultiJobPositionName(SessionHelper.getSession("UR_MultiJobPositionName"));
        fSes.setUserMultiJobTitleName(SessionHelper.getSession("UR_MultiJobTitleName"));
        fSes.setUserMultiJobLevelName(SessionHelper.getSession("UR_MultiJobLevelName"));
        fSes.setDeptMultiName(SessionHelper.getSession("GR_MultiName"));
        
        // 사용자 사업장 추가
        fSes.setUserMultiRegionName(SessionHelper.getSession("UR_MultiRegionName"));
        fSes.setUserRegionCode(SessionHelper.getSession("UR_RegionCode"));

        // 결재 부서
        fSes.setApvDeptID(SessionHelper.getSession("ApprovalParentGR_Code"));
        //fSes.setApvDeptName(formSvc.selectDeptName(fSes.getApvDeptID()));
        fSes.setApvDeptName(StringUtil.replaceNull(SessionHelper.getSession("ApprovalParentGR_Name"),formSvc.selectDeptName(fSes.getApvDeptID())));

        fSes.setUserPhoneNumber(SessionHelper.getSession("PhoneNumber"));
        fSes.setUserFax(SessionHelper.getSession("Fax"));
		
        return fSes;
	}
	
	private CoviMap getApiApprovalLine(CoviMap approvalLine, CoviMap schemaContext) throws Exception {
		String lang = SessionHelper.getSession("lang");
		String dn_Code = SessionHelper.getSession("DN_Code");
		String ur_RegionCode = SessionHelper.getSession("UR_RegionCode");
		
//		CoviMap apvLine = formData.optJSONObject("ApprovalLine");
//		CoviMap schemaContext = formData.optJSONObject("SchemaContext");
		
		CoviMap apiApprovalLine = new CoviMap();
		CoviList apiDivisions = new CoviList();
		CoviMap apiDivision = new CoviMap();
		CoviList apiSteps = new CoviList();
		CoviMap apiStep = new CoviMap();
		boolean isChargeDeputy = false; // 담당자 대결일 경우에만 step이 대결자/원결재자 2개로 되서 예외처리(나머지는 모두 person이 2개)
		boolean isAddApiStep = false; // stepIdx 카운트업 여부
		CoviList apiSubSteps = new CoviList();
		CoviMap apiSubStep = new CoviMap();
		int divisionIdx = 1;
		int stepIdx = 1;
		int subStepIdx = 1;
		CoviList apiCcinfos = new CoviList();
		//CoviMap apiCcinfo = new CoviMap();
		
		CoviMap apvLine = approvalLine.getJSONObject("steps");
		if(apvLine.has("division")){													// division
			CoviList oDivisions = new CoviList();
			if(apvLine.get("division") instanceof CoviMap)
				oDivisions.add(apvLine.getJSONObject("division"));
			else if(apvLine.get("division") instanceof CoviList)
				oDivisions = apvLine.optJSONArray("division");
			
			for(Object jsonObj1 : oDivisions){
				CoviMap oDivision = (CoviMap) jsonObj1;
				String divisionType = (oDivision.optString("divisiontype").equalsIgnoreCase("send")) ? "Send" : "Receive";
				
				if(oDivision.has("step")){											// step
					CoviList oSteps = new CoviList();
					if(oDivision.get("step") instanceof CoviMap)
						oSteps.add(oDivision.getJSONObject("step"));
					else if(oDivision.get("step") instanceof CoviList)
						oSteps = oDivision.optJSONArray("step");
					
					for(Object jsonObj2 : oSteps){
						CoviMap oStep = (CoviMap) jsonObj2;
						
						if(oStep.has("ou")){											// ou
							CoviList oOus = new CoviList();
							if(oStep.get("ou") instanceof CoviMap)
								oOus.add(oStep.getJSONObject("ou"));
							else if(oStep.get("ou") instanceof CoviList)
								oOus = oStep.optJSONArray("ou");
							
							for(Object jsonObj3 : oOus){
								CoviMap oOu = (CoviMap) jsonObj3;
								
								CoviMap stepInfo = new CoviMap(); // type , typeName , result , resultName
								
								if(oOu.has("person")){								// person
									CoviList oPersons = new CoviList();
									if(oOu.get("person") instanceof CoviMap)
										oPersons.add(oOu.getJSONObject("person"));
									else if(oOu.get("person") instanceof CoviList)
										oPersons = oOu.optJSONArray("person");
									
									//String strDivisionOuCode = "";
									for(Object jsonObj4 : oPersons){
										CoviMap oPerson = (CoviMap) jsonObj4;
										CoviMap taskInfo = oPerson.getJSONObject("taskinfo");
										
										boolean isDisplay = false;
										if(taskInfo.has("visible")){
											if(!taskInfo.optString("visible").equals("n"))
												isDisplay = true;
										}else if(!taskInfo.optString("kind").equals("conveyance"))
											isDisplay = true;
										
										if(isDisplay){											
											
											stepInfo = getStepInfo(oStep, oOu, taskInfo); // type , typeName , result , resultName
											
											switch(stepInfo.optString("type")) {
												case "D_P_Consult":	// 부서합의(병렬)
												case "D_S_Consult":	// 부서합의
												case "D_P_Assist":	// 부서협조(병렬)
												case "D_S_Assist":	// 부서협조
												case "D_Audit":		// 부서감사
												case "D_Audit_Law":	// 부서준법
													if(subStepIdx == 1) {
														// 부서step 생성
														// person기준으로 반복문이 진행되므로 subStepIdx 1번에서만 생성 
														// taskinfo 정보(결과, 일자 등)를 OU의 정보 이용하여 생성
														CoviMap taskInfo_ou = oOu.getJSONObject("taskinfo");
														CoviMap stepInfo_ou = getStepInfo(oStep, oOu, taskInfo_ou);
														makeApiStep(apiStep, "OU", stepInfo_ou, oStep, oOu, null, taskInfo_ou, lang, false, false); // update apiStep
													}
													// substep 생성
													apiSubStep = makeApiSubStep(apiSubStep, stepInfo, oStep, oOu, oPerson, taskInfo, lang); // update apiSubStep
													
													// 대결자와 원결재자는 1개의 step으로 표시해야되므로 여기서는 대결자(substitute) 일때는 추가하지 않고, 원결재자(bypassed)에서 apiSubStep에 원결재자 정보 업데이트 후 추가
													// 대결자(substitute)가 있으면 항상 바로뒤에 원결재자(bypassed)가 있음
													if(!taskInfo.optString("kind").equalsIgnoreCase("substitute")) {
														apiSubStep.put("index", subStepIdx);
														apiSubSteps.add(apiSubStep);
														subStepIdx++;
													}
													
													break;
												default:
													boolean isChargeBypassed = false;
													// 담당자 대결일 경우에만 step이 대결자/원결재자 2개로 되서 예외처리(나머지는 모두 person이 2개)
													if(divisionType.equalsIgnoreCase("Receive") && stepIdx == 1 && oSteps.size() > 1) {
														if(taskInfo.optString("kind").equalsIgnoreCase("charge")) {
															isChargeDeputy = chkChargeDeputy(oSteps.getJSONObject(1)); // 담당자 대결 중 대결자 체크
														}else {
															isChargeBypassed = chkChargeDeputy(oSteps.getJSONObject(1)); // 담당자 대결 중 원결재자 체크
														}
													}
													
													makeApiStep(apiStep, "PERSON", stepInfo, oStep, oOu, oPerson, taskInfo, lang, isChargeDeputy, isChargeBypassed); // update apiStep
													break;
											}
										}
									}
								} else {									
									CoviMap taskInfo = null;	
									if(oOu.has("role")){ // role
										CoviMap oRole = oOu.getJSONObject("role");
										taskInfo = oRole.getJSONObject("taskinfo");
									} else {
										taskInfo = oOu.getJSONObject("taskinfo");
									}
									
									stepInfo = getStepInfo(oStep, oOu, taskInfo); // type , typeName , result , resultName
									
									makeApiStep(apiStep, "OU", stepInfo, oStep, oOu, null, taskInfo, lang, false, false); // update apiStep
			                        
								}
								if(!apiStep.isEmpty() && !isChargeDeputy) { // 담당자 대결자인 경우 이전 step을 계속 사용
									apiStep.put("index", stepIdx);
									apiStep.put("subStep", apiSubSteps);
									apiSteps.add(apiStep);
									apiStep = new CoviMap();
									
									isAddApiStep = true;
								}
								isChargeDeputy = false;
								apiSubSteps = new CoviList();
								subStepIdx = 1;
							} // for oOus
							
						} // oStep.has("ou")
						
						if(isAddApiStep) { // apiStep이 추가된 경우에만 카운트업
							stepIdx++; // 부서/개인 병렬은 step 하나에 ou가 여러개있고 같은 stepIdx로 처리해야되므로 step단위로 증가
							isAddApiStep = false;
						}
						
					} // for oSteps
					
				} // oDivision.has("step")
				
				apiDivision.put("index", divisionIdx);
				apiDivision.put("type", divisionType);
				apiDivision.put("processID", oDivision.optString("processID"));
				apiDivision.put("step",apiSteps);
				apiDivisions.add(apiDivision);
				divisionIdx++;
				
				apiDivision = new CoviMap();
				apiSteps = new CoviList();
				stepIdx = 1;
			} // for oDivisions
			
			// 모두 종료 후 도착하지 않은 담당업무, 담당부서 추가
			String[] chgrRoles = getChgrRoles(schemaContext, dn_Code, ur_RegionCode);
			String[] chgrOus = getChgrOus(schemaContext, dn_Code, ur_RegionCode);
			
			// 담당업무
			if(chgrRoles.length > apiDivisions.size() - 1) {
				for (int i = apiDivisions.size() - 1; i < chgrRoles.length; i++) {
					String[] arr_role = chgrRoles[i].split("@");
					if(arr_role.length > 1) {
						CoviMap roleDivision = makeApiDivision("Rec_Role", DicHelper.getDic("lbl_Role"), arr_role[0], DicHelper.getDicInfo(arr_role[1], lang), divisionIdx);
						apiDivisions.add(roleDivision);
						divisionIdx++;
					}
				}
			}
			
			// 수신부서
			if(chgrOus.length > apiDivisions.size() - 1) {
				for (int i = apiDivisions.size() - 1; i < chgrOus.length; i++) {
					String[] arr_chgrOus = chgrOus[i].split("@");
					if(arr_chgrOus.length > 1) {
						CoviMap chgrOusDivision = makeApiDivision("Rec_Dept", DicHelper.getDic("lbl_apv_Acceptdept"), arr_chgrOus[0], DicHelper.getDicInfo(arr_chgrOus[1], lang), divisionIdx);
						apiDivisions.add(chgrOusDivision);
						divisionIdx++;
					}
				}
			}
			
			apiApprovalLine.put("division", apiDivisions);
			
		} // apvLine.has("division")
		
		
		// ccinfo
		if(apvLine.has("ccinfo")){
			CoviList oCcinfos = new CoviList();
			if(apvLine.get("ccinfo") instanceof CoviMap)
				oCcinfos.add(apvLine.getJSONObject("ccinfo"));
			else if(apvLine.get("ccinfo") instanceof CoviList)
				oCcinfos = apvLine.optJSONArray("ccinfo");
			
			for(Object jsonObj : oCcinfos){
				CoviMap oCcinfo = (CoviMap) jsonObj;
				apiCcinfos.add(makeApiCC(oCcinfo, lang));
			} // for oCcinfos
			
			apiApprovalLine.put("ccinfo", apiCcinfos);
		} // apvLine.has("ccinfo")

        return apiApprovalLine;
	}
	
	/*
	 * 결재타입,결과
	 * 결재타입으로 결재종류를 구분하고 그 중 대결은 deputy 정보로 구분
	 * 결재결과는 없음("")/진행중/보류/반려/거부/승인/동의/후열/확인/참조 만 있음
	 */
	private CoviMap getStepInfo(CoviMap oStep, CoviMap oOu, CoviMap taskInfo){
		String routetype = oStep.optString("routetype");
		String unittype = oStep.optString("unittype");
		String allottype = oStep.optString("allottype");
		String stepname = oStep.optString("name");
		String result = taskInfo.optString("result");
		String kind = taskInfo.optString("kind");
		String status = taskInfo.optString("status");
		String datereceived = taskInfo.optString("datereceived");
		boolean hasRole = oOu.has("role");
		
		CoviMap stepInfo = new CoviMap();
		String stepType = "";
		String stepTypeName = "";
		String stepResult = "";
		String stepResultName = "";

		// 결재 타입
		switch(routetype) {
			case "approve":
				if(kind.equalsIgnoreCase("confirm")) stepType = "Confirm"; 				// 확인자
				else if(kind.equalsIgnoreCase("reference")) stepType = "Reference";		// 참조결재
				else if(kind.equalsIgnoreCase("authorize")) stepType = "Authorize";		// 전결
				else if(kind.equalsIgnoreCase("review")) stepType = "Review";			// 후결
				else if(kind.equalsIgnoreCase("skip")) stepType = "Skip";				// 결재안함
				else if(kind.equalsIgnoreCase("bypass")) stepType = "Bypass";			// 후열
				else if(kind.equalsIgnoreCase("substitute")) stepType = "Approve";		// 대결 >> 일반결재
				else stepType = "Approve"; 												// 일반결재 (기안자,결재자,수신기안자,수신결재자)
				break;
			case "consult":
			case "assist":
				if(unittype.equalsIgnoreCase("ou")) {
					if(allottype.equalsIgnoreCase("parallel")) stepType = "D_P_";		// 부서 병렬
					else if(allottype.equalsIgnoreCase("serial")) stepType = "D_S_";	// 부서 순차
				}else if(unittype.equalsIgnoreCase("person")) {
					if(allottype.equalsIgnoreCase("parallel")) stepType = "P_P_";		// 개인 병렬
					else if(allottype.equalsIgnoreCase("serial")) stepType = "P_S_";	// 개인 순차
				}
				if(!stepType.equals("") && routetype.equals("consult")) stepType = stepType + "Consult";	// 합의
				else if(!stepType.equals("") && routetype.equals("assist")) stepType = stepType + "Assist";	// 협조
				break;
			case "audit":
				if(stepname.equalsIgnoreCase("audit")) stepType = "Audit";						// 개인감사
				else if(stepname.equalsIgnoreCase("audit_law")) stepType = "Audit_Law";			// 개인준법
				else if(stepname.equalsIgnoreCase("audit_dept")) stepType = "D_Audit";			// 부서감사
				else if(stepname.equalsIgnoreCase("audit_law_dept")) stepType = "D_Audit_Law";	// 부서준법
				break;
			case "receive":
				if(hasRole) stepType = "Rec_Role";										// 업무문서함
				else if(unittype.equalsIgnoreCase("ou")) stepType = "Rec_Dept";			// 수신부서
				else if(unittype.equalsIgnoreCase("person")) stepType = "Rec_Person";	// 수신자
				break;
			default : 
				break;
		}
		
		// 결재 타입 명
		switch(stepType) {
			case "Confirm": stepTypeName = DicHelper.getDic("lbl_apv_Confirm"); break;			// 확인
			case "Reference": stepTypeName = DicHelper.getDic("lbl_apv_cc"); break;				// 참조
			case "Authorize": stepTypeName = DicHelper.getDic("lbl_apv_authorize"); break;		// 전결
			case "Review": stepTypeName = DicHelper.getDic("lbl_apv_review"); break;			// 후결
			case "Skip": stepTypeName = DicHelper.getDic("lbl_apv_NoApprvl"); break;			// 결재안함
			case "Bypass": stepTypeName = DicHelper.getDic("lbl_apv_bypass"); break;			// 후열
			//case "Substitute": stepTypeName = DicHelper.getDic("lbl_apv_substitue"); break;	// 대결
			case "Approve": stepTypeName = DicHelper.getDic("lbl_apv_app"); break;				// 결재
			case "P_P_Consult": stepTypeName = DicHelper.getDic("btn_apv_consultors_2"); break;	// 개인합의(병렬)
			case "P_S_Consult": stepTypeName = DicHelper.getDic("btn_apv_consultors"); break;	// 개인합의
			case "D_P_Consult": stepTypeName = DicHelper.getDic("lbl_apv_DeptConsent_2"); break;// 부서합의(병렬)
			case "D_S_Consult": stepTypeName = DicHelper.getDic("lbl_apv_DeptConsent"); break;	// 부서합의
			case "P_P_Assist": stepTypeName = DicHelper.getDic("lbl_apv_assist_2"); break;		// 개인협조(병렬)
			case "P_S_Assist": stepTypeName = DicHelper.getDic("lbl_apv_assist"); break;		// 개인협조
			case "D_P_Assist": stepTypeName = DicHelper.getDic("lbl_apv_DeptAssist2"); break;	// 부서협조(병렬)
			case "D_S_Assist": stepTypeName = DicHelper.getDic("lbl_apv_DeptAssist"); break;	// 부서협조
			case "Audit": stepTypeName = DicHelper.getDic("lbl_apv_person_audit3"); break;		// 개인감사
			case "Audit_Law": stepTypeName = DicHelper.getDic("lbl_apv_person_audit"); break;	// 개인준법
			case "D_Audit": stepTypeName = DicHelper.getDic("lbl_apv_dept_audit3"); break;		// 부서감사
			case "D_Audit_Law": stepTypeName = DicHelper.getDic("lbl_apv_dept_audit"); break;	// 부서준법
			case "Rec_Role": stepTypeName = DicHelper.getDic("lbl_Role"); break;				// 담당업무
			case "Rec_Dept": stepTypeName = DicHelper.getDic("lbl_apv_Acceptdept"); break;		// 수신부서
			case "Rec_Person": stepTypeName = DicHelper.getDic("lbl_apv_receive"); break;		// 수신
			default : break;
		}
		
		// 결재 결과
		switch (result)
        {
        	case "inactive": 
        		if(kind.equalsIgnoreCase("review") && !datereceived.equals("")) stepResult = "Approved";	// 후결 >> 결재
        		else stepResult = ""; 																		// 없음 >> ""
        		break;  
        	case "pending": stepResult = "Pending"; break;								// 진행중
            case "authorized": stepResult = "Approved"; break;							// 전결 >> 결재
            case "skipped": stepResult = ""; break;										// 결재안함 >> 없음
            case "agreed": stepResult = "Agreed"; break;								// 동의
            case "disagreed": stepResult = "Disagreed"; break;							// 거부
            case "completed":
            	if(kind.equalsIgnoreCase("confirm")) stepResult = "Confirmed";			// 확인
            	else if(kind.equalsIgnoreCase("reference")) stepResult = "Reference";	// 참조결재
            	else if(kind.equalsIgnoreCase("bypass")) {
            		if(stepname.equals("원결재자")) stepResult = "";						// 원결재자(수신자대결일때만) >> 없음
            		stepResult = "Bypassed";											// 후열
            	}
            	else stepResult = "Approved";											// 결재 
            	break;
            case "bypassed": 
            	if(status.equalsIgnoreCase("rejected")) stepResult = "";				// 원결재자 반려 >> 없음
            	else stepResult = "";													// 원결재자 >> 없음
            	break;									
            case "reserved": stepResult = "Reserved"; break;							// 보류
            case "rejected": 
            	if(kind.equalsIgnoreCase("substitute")) stepResult = "Rejected";		// 대결자 반려 >> 반려
            	stepResult = "Rejected";												// 반려
            	break;							
            case "substituted": stepResult = "Approved"; break;							// 대결자 >> 결재
            // 없는코드로 예상됨
            //case "reviewed":  // 승인
            //case "bypass":  // 후열
            //case "confirmed":  // 확인
            default : break;
        }
        
		// 결재 결과 명
		switch(stepResult) {
			case "Pending": stepResultName = DicHelper.getDic("lbl_Progressing"); break;	// 진행중
			case "Approved": stepResultName = DicHelper.getDic("lbl_apv_Approved"); break;	// 승인
			case "Rejected": stepResultName = DicHelper.getDic("lbl_apv_reject"); break;	// 반려
			case "Reserved": stepResultName = DicHelper.getDic("lbl_apv_hold"); break;		// 보류
			// Approved(승인) 중 상세결과명
			case "Agreed": stepResultName = DicHelper.getDic("lbl_apv_agree"); break;		// 동의
			case "Bypassed": stepResultName = DicHelper.getDic("lbl_apv_bypass"); break;	// 후열
			case "Confirmed": stepResultName = DicHelper.getDic("lbl_apv_confirmed"); break;// 확인
			case "Reference": stepResultName = DicHelper.getDic("lbl_apv_cc"); break;		// 참조
			// Rejected(반려) 중 상세결과명
			case "Disagreed": stepResultName = DicHelper.getDic("lbl_apv_disagree"); break;	// 거부
			default : break;
		}
		
		stepInfo.put("type",stepType);
		stepInfo.put("typeName",stepTypeName);
		stepInfo.put("result",stepResult);
		stepInfo.put("resultName",stepResultName);
		
		return stepInfo;
	}
	
	/*
	 * 이미 정의된 apiStep 객체를 받아서 업데이트 한다
	 * 대결 등 처리를 위해 person으로 루프돌아 1개의 apiStep을 만든다. (대결/전달 등 모든 n개의 person으로 1개의 apiStep을 만든다)
	 * isDeputy : 담당자 대결일 경우 대결자 예외처리
	 * isBypassed : 담당자 대결일 경우 원결재자 예외처리
	 */
	private void makeApiStep(CoviMap apiStep, String stepType, CoviMap stepInfo, CoviMap oStep, CoviMap oOu, CoviMap oPerson, CoviMap taskInfo, String lang, boolean isDeputy, boolean isBypassed) throws Exception {
		apiStep.put("workitemID", oOu.optString("wiid"));
		
		if(stepType.equalsIgnoreCase("OU")) { // OU
			apiStep.put("type",stepInfo.optString("type"));
            apiStep.put("typeName",stepInfo.optString("typeName"));
            apiStep.put("result",stepInfo.optString("result"));
            apiStep.put("resultName",stepInfo.optString("resultName"));
            // userName,userCode
            apiStep.put("deptName",DicHelper.getDicInfo(oOu.optString("name"), lang));
            apiStep.put("deptCode",oOu.optString("code"));
            // deputyUserName,deputyUserCode,deputyDeptName,deputyDeptCode
            apiStep.put("dateReceived",ComUtils.TransLocalTime(taskInfo.optString("datereceived")));
            apiStep.put("dateCompleted",ComUtils.TransLocalTime(taskInfo.optString("datecompleted")));
            // comment,commentFiles
            apiStep.put("subProcessID",taskInfo.optString("piid"));
		}else { // PERSON
			String comment = "";
            CoviList commentFiles = new CoviList();

            if(taskInfo.optString("result").equalsIgnoreCase("bypassed") || isBypassed) { 
            	// 원결재자인 경우 결재자 정보만 셋팅, 나머지 정보(결재결과,일시,의견 등)는 대결자 기준으로 들어있음
            	// kind == bypass 는 후열자도 동일하므로 result == bypassed 조건 이용
            	apiStep.put("userName",DicHelper.getDicInfo(oPerson.optString("name"), lang));
                apiStep.put("userCode",oPerson.optString("code"));
                apiStep.put("deptName",DicHelper.getDicInfo(oPerson.optString("ouname"), lang));
                apiStep.put("deptCode",oPerson.optString("oucode"));
            }else {
                if(taskInfo.has("comment")){
                	comment = new String(Base64.decodeBase64(taskInfo.getJSONObject("comment").optString("#text").getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
                }
                if(taskInfo.has("comment_fileinfo")){
                	CoviList tmpCommentFiles = (CoviList)taskInfo.get("comment_fileinfo");
                	for(Object jsonObj5 : tmpCommentFiles){
						CoviMap tmpCommentFile = (CoviMap) jsonObj5;
						CoviMap commentFile = new CoviMap();
						commentFile.put("FileName", tmpCommentFile.optString("name"));
						commentFile.put("FileID", tmpCommentFile.optString("FileID"));
						commentFile.put("FileToken", tmpCommentFile.optString("FileToken"));
						commentFiles.add(commentFile);
                	}
                }
				
                apiStep.put("type",stepInfo.optString("type"));
                apiStep.put("typeName",stepInfo.optString("typeName"));
                apiStep.put("result",stepInfo.optString("result"));
                apiStep.put("resultName",stepInfo.optString("resultName"));
                if(taskInfo.optString("kind").equalsIgnoreCase("substitute") || isDeputy) { 
                	// 대결자
                    apiStep.put("deputyUserName",DicHelper.getDicInfo(oPerson.optString("name"), lang));
                    apiStep.put("deputyUserCode",oPerson.optString("code"));
                    apiStep.put("deputyDeptName",DicHelper.getDicInfo(oPerson.optString("ouname"), lang));
                    apiStep.put("deputyDeptCode",oPerson.optString("oucode"));
                }else {
                	apiStep.put("userName",DicHelper.getDicInfo(oPerson.optString("name"), lang));
                    apiStep.put("userCode",oPerson.optString("code"));
                    apiStep.put("deptName",DicHelper.getDicInfo(oPerson.optString("ouname"), lang));
                    apiStep.put("deptCode",oPerson.optString("oucode"));
                }
                apiStep.put("dateReceived",ComUtils.TransLocalTime(taskInfo.optString("datereceived")));
                apiStep.put("dateCompleted",ComUtils.TransLocalTime(taskInfo.optString("datecompleted")));
                apiStep.put("comment",comment);
                apiStep.put("comment_fileinfo",commentFiles);
            }
		}
        //return apiStep;
	}
	
	/*
	 * 조건에 따라 이미 정의된 apiSubStep 객체를 받아서 업데이트 한다
	 * 내부 결재선이므로 person으로 루프를 돌아 n개의 person으로 n개의 apiSubStep을 만들지만,
	 * 대결처리가 있는경우에만 대결/원결 관련 2개의 person으로 1개의 apiSubStep을 만든다 (이때는 직전 apiSubStep객체를 받아서 업데이트)
	 */
	private CoviMap makeApiSubStep(CoviMap apiSubStep, CoviMap stepInfo, CoviMap oStep, CoviMap oOu, CoviMap oPerson, CoviMap taskInfo, String lang) throws Exception {
		CoviMap apiSubStep_new = new CoviMap();
		
		String comment = "";
        CoviList commentFiles = new CoviList();

        if(taskInfo.optString("result").equalsIgnoreCase("bypassed")) { 
        	// 원결재자인 경우 결재자 정보만 셋팅, 나머지 정보(결재결과,일시,의견 등)는 대결자 기준으로 들어있음
        	// kind == bypass 는 후열자도 동일하므로 result == bypassed 조건 이용
        	apiSubStep_new = apiSubStep; // 대결자와 원결재자는 1개의 step으로 표시해야되므로 직전 apiSubStep(대결자/substitute)에 원결재자 정보 업데이트
        	apiSubStep_new.put("userName",DicHelper.getDicInfo(oPerson.optString("name"), lang));
        	apiSubStep_new.put("userCode",oPerson.optString("code"));
        	apiSubStep_new.put("deptName",DicHelper.getDicInfo(oPerson.optString("ouname"), lang));
        	apiSubStep_new.put("deptCode",oPerson.optString("oucode"));
        }else {
            if(taskInfo.has("comment")){
            	comment = new String(Base64.decodeBase64(taskInfo.getJSONObject("comment").optString("#text").getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
            }
            if(taskInfo.has("comment_fileinfo")){
            	CoviList tmpCommentFiles = (CoviList)taskInfo.get("comment_fileinfo");
            	for(Object jsonObj5 : tmpCommentFiles){
					CoviMap tmpCommentFile = (CoviMap) jsonObj5;
					CoviMap commentFile = new CoviMap();
					commentFile.put("FileName", tmpCommentFile.optString("name"));
					commentFile.put("FileID", tmpCommentFile.optString("FileID"));
					commentFile.put("FileToken", tmpCommentFile.optString("FileToken"));
					commentFiles.add(commentFile);
            	}
            }
			
            apiSubStep_new.put("type",stepInfo.optString("type"));
            apiSubStep_new.put("typeName",stepInfo.optString("typeName"));
            apiSubStep_new.put("result",stepInfo.optString("result"));
            apiSubStep_new.put("resultName",stepInfo.optString("resultName"));
            apiSubStep_new.put("dateReceived",ComUtils.TransLocalTime(taskInfo.optString("datereceived")));
            apiSubStep_new.put("dateCompleted",ComUtils.TransLocalTime(taskInfo.optString("datecompleted")));
            apiSubStep_new.put("comment",comment);
            apiSubStep_new.put("comment_fileinfo",commentFiles);
            if(taskInfo.optString("kind").equalsIgnoreCase("substitute")) { 
            	// 대결자
            	apiSubStep_new.put("deputyUserName",DicHelper.getDicInfo(oPerson.optString("name"), lang));
            	apiSubStep_new.put("deputyUserCode",oPerson.optString("code"));
            	apiSubStep_new.put("deputyDeptName",DicHelper.getDicInfo(oPerson.optString("ouname"), lang));
            	apiSubStep_new.put("deputyDeptCode",oPerson.optString("oucode"));
            }else {
            	apiSubStep_new.put("userName",DicHelper.getDicInfo(oPerson.optString("name"), lang));
            	apiSubStep_new.put("userCode",oPerson.optString("code"));
            	apiSubStep_new.put("deptName",DicHelper.getDicInfo(oPerson.optString("ouname"), lang));
            	apiSubStep_new.put("deptCode",oPerson.optString("oucode"));
            }
        }
		
        return apiSubStep_new;
	}
	
	private CoviMap makeApiCC(CoviMap oCcinfo, String lang) throws Exception {
		CoviMap apiCcinfo = new CoviMap();
		CoviMap oOu = oCcinfo.optJSONObject("ou");
		CoviMap oPerson = oOu.optJSONObject("person");
        
		apiCcinfo.put("senderCode", oCcinfo.optString("senderid"));
		apiCcinfo.put("senderName", DicHelper.getDicInfo(oCcinfo.optString("sendername"), lang));
		apiCcinfo.put("dateReceived", ComUtils.TransLocalTime(oCcinfo.optString("datereceived")));
		apiCcinfo.put("userCode", oPerson.optString("code"));
		apiCcinfo.put("userName", DicHelper.getDicInfo(oPerson.optString("name"), lang));
		apiCcinfo.put("deptCode", oOu.optString("code"));
		apiCcinfo.put("deptName", DicHelper.getDicInfo(oOu.optString("name"), lang));
		apiCcinfo.put("type", oCcinfo.optString("beforecc").equalsIgnoreCase("y") ? "Before" : "After");
		apiCcinfo.put("kind", oCcinfo.optString("belongto").equalsIgnoreCase("receiver") ? "Receive" : "Send");
		
        return apiCcinfo;
	}
	
	// 담당업무, 담당부서 등 결재선에 없는 division 추가
	private CoviMap makeApiDivision(String type, String typeName, String deptCode, String deptName, int divisionIdx) throws Exception {
		CoviMap oDivision = new CoviMap();
		CoviMap oStep = new CoviMap();
		CoviList oSteps = new CoviList();
		
		oStep.put("type", type);
		oStep.put("typeName", typeName);
		oStep.put("result", "");
		oStep.put("resultName", "");
		oStep.put("deptCode", deptCode);
		oStep.put("deptName", deptName);
		oStep.put("index", "1");
		oSteps.add(oStep);
		
		oDivision.put("index", divisionIdx);
		oDivision.put("type", "Receive");
		oDivision.put("processID", "");
		oDivision.put("step",oSteps);
		
        return oDivision;
	}
	
	private boolean chkChargeDeputy(CoviMap stepNext) throws Exception {
		boolean isChargeDeputy = false;
		
		CoviMap nextOu = new CoviMap();
		CoviMap nextPerson = new CoviMap();
		if(stepNext.has("ou")){											// ou
			if(stepNext.get("ou") instanceof CoviMap) nextOu = stepNext.getJSONObject("ou");
			else if(stepNext.get("ou") instanceof CoviList) nextOu = stepNext.optJSONArray("ou").getJSONObject(0);
			if(nextOu.has("person")){
				if(nextOu.get("person") instanceof CoviMap) nextPerson = nextOu.getJSONObject("person");
				else if(nextOu.get("person") instanceof CoviList) nextPerson = nextOu.optJSONArray("person").getJSONObject(0);
				
				CoviMap nextTaskinfo = nextPerson.getJSONObject("taskinfo");
				if(nextTaskinfo.optString("kind").equalsIgnoreCase("bypass") && stepNext.optString("name").equalsIgnoreCase("원결재자")) {
					// 수신처(receive)에서 2번째 step이 원결재자(bypass)면 수신자 대결
					// 수신처 2번째 결재자가 후열(bypass)인 경우와 구분방법이 step의 name밖에 없음
					isChargeDeputy = true;
				}
			}
		}
		
		return isChargeDeputy;
	}
	
	private String[] getChgrRoles(CoviMap schemaContext, String dn_Code, String ur_RegionCode) throws Exception {
		String strChgrRole = "";
		
		if (schemaContext.getJSONObject("scChgr").optString("isUse").equalsIgnoreCase("Y")) {
			strChgrRole = schemaContext.getJSONObject("scChgr").optString("value");
		} else if (schemaContext.getJSONObject("scChgrEnt").optString("isUse").equalsIgnoreCase("Y")) {
			if (!schemaContext.getJSONObject("scChgrEnt").optString("value").equals("")) {
				CoviMap chgrEntObj =schemaContext.getJSONObject("scChgrEnt").getJSONObject("value");
				if(chgrEntObj.has("ENT_"+dn_Code) && !chgrEntObj.optString("ENT_"+dn_Code).equals("")){
					strChgrRole = chgrEntObj.optString("ENT_"+dn_Code);
				}
			}
		} else if (schemaContext.getJSONObject("scChgrReg").optString("isUse").equalsIgnoreCase("Y")) {
			if (!schemaContext.getJSONObject("scChgrReg").optString("value").equals("")) {
				CoviMap chgrRegObj =schemaContext.getJSONObject("scChgrReg").getJSONObject("value");
				if(chgrRegObj.has("REG_"+ur_RegionCode) && !chgrRegObj.optString("REG_"+ur_RegionCode).equals("")){
					strChgrRole = chgrRegObj.optString("REG_"+ur_RegionCode);
				}
			}
		}
		
		return strChgrRole.split("\\^");
	}
	
	private String[] getChgrOus(CoviMap schemaContext, String dn_Code, String ur_RegionCode) throws Exception {
		String strChgrOu = "";
		
		if (schemaContext.getJSONObject("scChgrOU").optString("isUse").equalsIgnoreCase("Y")) {
			strChgrOu = schemaContext.getJSONObject("scChgrOU").optString("value");
		} else if (schemaContext.getJSONObject("scChgrOUEnt").optString("isUse").equalsIgnoreCase("Y")) {
			if (!schemaContext.getJSONObject("scChgrOUEnt").optString("value").equals("")) {
				CoviMap chgrOUEntObjAll =schemaContext.getJSONObject("scChgrOUEnt").getJSONObject("value");
				CoviList chgrOUEntObjs = chgrOUEntObjAll.getJSONObject("ENT_"+dn_Code).optJSONArray("item");
				for(Object jsonObj : chgrOUEntObjs){
					CoviMap chgrOUEntObj = (CoviMap) jsonObj;
					if(StringUtil.isNull(strChgrOu)) strChgrOu = chgrOUEntObj.optString("AN") + "@" + chgrOUEntObj.optString("DN");
					else strChgrOu += "^" + chgrOUEntObj.optString("AN") + "@" + chgrOUEntObj.optString("DN");
				}
			}
		} else if (schemaContext.getJSONObject("scChgrOUReg").optString("isUse").equalsIgnoreCase("Y")) {
			if (!schemaContext.getJSONObject("scChgrOUReg").optString("value").equals("")) {
				CoviMap chgrOURegObjAll =schemaContext.getJSONObject("scChgrOUReg").getJSONObject("value");
				CoviList chgrOURegObjs = chgrOURegObjAll.getJSONObject("REG_"+ur_RegionCode).optJSONArray("item");
				for(Object jsonObj : chgrOURegObjs){
					CoviMap chgrOURegObj = (CoviMap) jsonObj;
					if(StringUtil.isNull(strChgrOu)) strChgrOu = chgrOURegObj.optString("AN") + "@" + chgrOURegObj.optString("DN");
					else strChgrOu += "^" + chgrOURegObj.optString("AN") + "@" + chgrOURegObj.optString("DN");
				}
			}
		}
		
		return strChgrOu.split("\\^");
	}
	
	@Override
	public CoviList getButtonList(String strReadMode, String strSessionUserID, String strSessionApvDeptID, String strSessionDnCode, CoviMap processObj, CoviMap approvalLine, CoviMap formInstance, CoviMap schemaContext) throws Exception {
		return getButtonList(strReadMode, strSessionUserID, strSessionApvDeptID, strSessionDnCode, processObj, approvalLine, formInstance, schemaContext, null);
	}
	
	/**
	 * buttonlist
		Approved	승인  (동의,확인)	btn_apv_Approved/lbl_apv_agree/lbl_apv_Confirm
		DeptDraft	재기안			btn_apv_redraft
		Reject		반려 (거부)		lbl_apv_disagree
		Withdraw	회수				btn_apv_Withdraw
		Abort		기안취소			btn_apv_cancel
	 * @param strReadMode : formSvc.getReadMode
	 * @param strSessionUserID : USERID(session)
	 * @param strSessionApvDeptID : ApprovalParentGR_Code(session)
	 * @param strSessionDnCode : DN_Code(session)
	 * @param processObj : ProcessState(process) , State(workitem) , DeputyID(workitem) , UserCode(workitem) , SubKind(workitem/performer)
	 * @param approvalLine : 결재선json
	 * @param formInstance : InitiatorID
	 * @param schemaContext :  scDraftCancel
	 * @param requestData : 기존 객체 받아서 loct/gloct 업데이트하는 용도, 기존객체가 없다면 안넘겨도 됨
	 * @return
	 * @throws Exception
	 */
	public CoviList getButtonList(String strReadMode, String strSessionUserID, String strSessionApvDeptID, String strSessionDnCode, CoviMap processObj, CoviMap approvalLine, CoviMap formInstance, CoviMap schemaContext, CoviMap requestData) throws Exception {
		CoviList buttonInfo = new CoviList();
		
		CoviMap apvSpec = new CoviMap();
		String strLoct = "";
		String strGLoct = "";

		String processState = processObj.optString("ProcessState");
		String workitemState = processObj.optString("State");
		String strDeputyID = processObj.optString("DeputyID");
		String subKind = processObj.optString("SubKind");
		String workitemCode = processObj.optString("UserCode");
		
        if (strReadMode.equals("APPROVAL") || strReadMode.equals("PCONSULT") || strReadMode.equals("SUBAPPROVAL") || strReadMode.equals("RECAPPROVAL") || strReadMode.equals("AUDIT")
        		|| (strReadMode.equals("REDRAFT") && subKind.equals("T008")) ){ // 수신자, 개인배포, 담당업무 조건 추가
            if (!processState.equals("288")){//(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                strLoct = "COMPLETE";
            } else {
                if (!workitemState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                    strLoct = "PROCESS";
                } else {
                    if (!StringUtil.isNull(strSessionUserID) &&
                    		(strSessionUserID.equals(workitemCode) || strSessionUserID.equals(strDeputyID)) ){
                        strLoct = "APPROVAL"; //formRequest.getReadModeTemp();
                    } else if(isJobFunctionManager(workitemCode, strSessionUserID, strSessionDnCode)) {
                    	strLoct = "APPROVAL";
                    	strGLoct = "JOBFUNCTION";
                    } else {
                        strLoct = "PROCESS";
                    }
                }
            }
        } else if (strReadMode.equals("REDRAFT") || strReadMode.equals("SUBREDRAFT")){ // 부서수신(담당부서,수신부서,부서합의/협조,부서감사/준법)
            if (!processState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                strLoct = "COMPLETE";
            } else {
            	strGLoct = "DEPART";
                if (!workitemState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                    strLoct = "PROCESS";
                } else {
                	//strLoct = formRequest.getReadModeTemp();
                	if (!StringUtil.isNull(strSessionApvDeptID) && strSessionApvDeptID.equals(workitemCode)){
                        strLoct = strReadMode;
                    } else {
                        strLoct = "PROCESS";
                    }
                }
            }
        } else if (strReadMode.equals("REJECT")){
        	strLoct = "REJECT";
        } else if ((strReadMode.equals("CONSULT") || strReadMode.equals("CONSULTATION")) && workitemState.equals("288")){
        	strLoct = "APPROVAL";
        } else {
            strLoct = strReadMode;
        }

        if(!StringUtil.isNull(strGLoct)) strGLoct = strLoct;
        
        // 승인/반려/재기안
        if(strLoct.equals("APPROVAL") && !strReadMode.equals("REDRAFT")) {									// 개인결재(개인배포, 수신자, 담당업무는 재기안이므로 제외)
        	String[] arrConfirm = {"T019","T005","T018"}; // 확인, 후결, 공람
        	
        	CoviMap btApprove = new CoviMap();
        	CoviMap btReject = new CoviMap();
        	
        	btApprove.put("code", "Approve");
        	btReject.put("code", "Reject");
        	if((strReadMode.equals("PCONSULT") && subKind.equals("T009"))
        			|| (strReadMode.equals("SUBAPPROVAL") && chkDeptConsultSub(approvalLine))) {			// 개인합의 , 부서합의내결재자
        		btApprove.put("name", DicHelper.getDic("lbl_apv_agree")); // 동의
        		btReject.put("name", DicHelper.getDic("lbl_apv_disagree")); // 거부
        		buttonInfo.add(btApprove);
        		buttonInfo.add(btReject);
        	}else if(Arrays.asList(arrConfirm).contains(subKind)) {											// 확인결재
        		btApprove.put("name", DicHelper.getDic("lbl_apv_Confirm")); // 확인
        		buttonInfo.add(btApprove);
        	}else {
	        	btApprove.put("name", DicHelper.getDic("btn_apv_Approved")); // 승인
	        	btReject.put("name", DicHelper.getDic("lbl_apv_reject")); // 반려
	        	buttonInfo.add(btApprove);
        		buttonInfo.add(btReject);
        	}
        }else if(strLoct.equals("REDRAFT") || strLoct.equals("SUBREDRAFT") || strLoct.equals("APPROVAL")) { // 부서결재
        	CoviMap btDeptDraft = new CoviMap();
        	CoviMap btReject = new CoviMap();
        	
        	btDeptDraft.put("code", "Redraft");
        	btDeptDraft.put("name", DicHelper.getDic("btn_apv_redraft")); // 재기안
        	btReject.put("code", "Reject");
        	btReject.put("name", DicHelper.getDic("lbl_apv_reject")); // 반려
        	
        	if(subKind.equals("C")) { 																		// 부서합의
        		btReject.put("name", DicHelper.getDic("lbl_apv_disagree")); // 거부
        	}
        	buttonInfo.add(btDeptDraft);
    		buttonInfo.add(btReject);
        }else if(processState.equals("288") && workitemState.equals("528") && subKind.equals("T006")
        		&& formInstance.optString("InitiatorID").equals(strSessionUserID)) { 						// 회수,취소
        	boolean isCancel = schemaContext.getJSONObject("scDraftCancel").optString("isUse").equalsIgnoreCase("Y");
        	// 발신 진행중인경우 회수/취소 가능, 다음결재자가 진행하지 않은경우 회수 진행한경우 취소 
        	String cancelType = getCancelType(approvalLine);
        	if(cancelType.equals("W")) {
        		CoviMap btWithdraw = new CoviMap();
        		btWithdraw.put("code", "Withdraw");
        		btWithdraw.put("name", DicHelper.getDic("btn_apv_Withdraw")); // 회수
            	buttonInfo.add(btWithdraw);
        	}else if(isCancel && cancelType.equals("C")) {
        		CoviMap btAbort = new CoviMap();
        		btAbort.put("code", "Abort");
        		btAbort.put("name", DicHelper.getDic("btn_apv_cancel")); // 기안취소
            	buttonInfo.add(btAbort);
        	}
        }
        
        if(requestData != null) {
        	requestData.put("loct", strLoct);
        	requestData.put("gloct", strGLoct);
        }
        
        return buttonInfo;
	}
	
	private CoviMap getApiFormInfo(CoviMap forms, CoviMap formInstance, CoviMap processObj, CoviMap bodyContext, CoviMap bodyData, CoviMap requestData) throws Exception {
		CoviMap apvFormInfo = new CoviMap();
		String lang = SessionHelper.getSession("lang");
		
		// forms
		apvFormInfo.put("formPrefix",forms.optString("FormPrefix"));
		
		// formInstance
		//apvFormInfo.putAll(formInstance);
		apvFormInfo.put("formInstID",formInstance.optString("FormInstID"));
		apvFormInfo.put("formID",formInstance.optString("FormID"));
		apvFormInfo.put("schemaID",formInstance.optString("SchemaID"));
		apvFormInfo.put("subject",formInstance.optString("Subject"));
		apvFormInfo.put("initiatorID",formInstance.optString("InitiatorID"));
		apvFormInfo.put("initiatorName",DicHelper.getDicInfo(formInstance.optString("InitiatorName"), lang));
		apvFormInfo.put("initiatorUnitID",formInstance.optString("InitiatorUnitID"));
		apvFormInfo.put("initiatorUnitName",DicHelper.getDicInfo(formInstance.optString("InitiatorUnitName"), lang));
		apvFormInfo.put("initiatedDate",ComUtils.TransLocalTime(formInstance.optString("InitiatedDate")));
		apvFormInfo.put("completedDate",ComUtils.TransLocalTime(formInstance.optString("CompletedDate")));
		apvFormInfo.put("deletedDate",ComUtils.TransLocalTime(formInstance.optString("DeletedDate")));
		apvFormInfo.put("entCode",formInstance.optString("EntCode"));
		apvFormInfo.put("entName",formInstance.optString("EntName"));
		apvFormInfo.put("docNo",formInstance.optString("DocNo"));
		apvFormInfo.put("docLevel",formInstance.optString("DocLevel"));
		apvFormInfo.put("docLevelName",getDocLevelName(formInstance.optString("DocLevel"), lang));
		apvFormInfo.put("docClassID",formInstance.optString("DocClassID"));
		apvFormInfo.put("docClassName",formInstance.optString("DocClassName"));
		apvFormInfo.put("saveTerm",formInstance.optString("SaveTerm"));
		apvFormInfo.put("saveTermName",getSaveTermName(formInstance.optString("SaveTerm"), lang));
		apvFormInfo.put("receiveInfo",getReceiveInfo(formInstance.optString("ReceiveNames"), lang));
		apvFormInfo.put("docLinks",getDocLinks(formInstance.optString("DocLinks")));
		apvFormInfo.put("edmsDocLinks",getEDMSDocLinks(formInstance.optString("EDMSDocLinks")));
		
		// processObj
		apvFormInfo.put("processID",processObj.optString("ProcessID"));
		apvFormInfo.put("processState",getProcessState(processObj.optString("ProcessState"), processObj.optString("BusinessState")));
		apvFormInfo.put("formName",DicHelper.getDicInfo(processObj.optJSONObject("ProcessDescription").optString("FormName"), lang));
		apvFormInfo.put("isSecureDoc",processObj.optJSONObject("ProcessDescription").optString("IsSecureDoc"));
		apvFormInfo.put("isReserved",processObj.optJSONObject("ProcessDescription").optString("IsReserved"));
		apvFormInfo.put("priority",processObj.optJSONObject("ProcessDescription").optString("Priority").equals("5") ? "Y" : "N"); // 5 긴급 , 3 일반
		
		// 본문정보
		apvFormInfo.put("bodyContext",bodyContext);
		apvFormInfo.put("bodyData",bodyData);
		
		// 오픈 url
		apvFormInfo.put("formUrl",getApiFormUrl(processObj, formInstance, requestData));
		
		return apvFormInfo;
	}
	
	public String getDocLevelName(String docLevel, String lang) throws Exception {
		String strReturn = "";
		
		switch (docLevel) {
			case "100": strReturn = DicHelper.getDic("DOC_LEVEL_10"); break; //일반문서
			case "200": strReturn = DicHelper.getDic("DOC_LEVEL_20"); break; //보안문서
			case "300": strReturn = DicHelper.getDic("DOC_LEVEL_30"); break; //3등급
			default:
				strReturn = RedisDataUtil.getBaseCodeDic("DOC_LEVEL", docLevel, lang);
				break;
		}
				
		return strReturn;
	}
	
	public String getSaveTermName(String saveTerm, String lang) throws Exception {
		String strReturn = "";
		
		switch (saveTerm) {
		case "1":	   //1년
		case "01":	   //1년
			strReturn = DicHelper.getDic("lbl_apv_year_1"); break;
		case "3":	   //3년
		case "03":	   //3년
			strReturn = DicHelper.getDic("lbl_apv_year_3"); break;
		case "5":	   //5년
		case "05":	   //5년
			strReturn = DicHelper.getDic("lbl_apv_year_5"); break;
		case "7":	   //7년
			strReturn = DicHelper.getDic("lbl_apv_year_7"); break;
		case "10":	  //10년
			strReturn = DicHelper.getDic("lbl_apv_year_10"); break;
		case "20":	  //20년
			strReturn = DicHelper.getDic("lbl_apv_year_20"); break;
		case "25":	  //30년
			strReturn = DicHelper.getDic("lbl_apv_year_30"); break;
		case "30":	  //준영구
			strReturn = DicHelper.getDic("lbl_apv_semiperm"); break;
		case "99":	  //영구
		case "40":	  //영구
			strReturn = DicHelper.getDic("lbl_apv_permanence"); break;
		default:
			strReturn = RedisDataUtil.getBaseCodeDic("SAVE_TERM", saveTerm, lang);
			break;
		}
				
		return strReturn;
	}

	public CoviList getReceiveInfo(String receiveNames, String lang) throws Exception {
		CoviList listReturn = new CoviList();
		
		String[] receiptItems = receiveNames.split(";");
		
		for(String item: receiptItems){
			if(!item.equals("") && item.split(":").length >= 3) {				
				String[] splitItem = item.split(":");
				
				if(splitItem.length > 1) {	
					CoviMap mapReceipt = new CoviMap();
					mapReceipt.put("type",splitItem[0]); // 0:부서, 1:사용자, 2:배포그룹
					mapReceipt.put("code",splitItem[1]);
					mapReceipt.put("name",DicHelper.getDicInfo(splitItem[0], lang));
					mapReceipt.put("hasSubDept",splitItem[3]); // Y,N,X
					listReturn.add(mapReceipt);
				}
			}
		}
				
		return listReturn;
	}
	
	public CoviList getDocLinks(String docLinks) throws Exception {
		CoviList listReturn = new CoviList();
		
		String[] docItems = docLinks.split("\\^\\^\\^");
		
		for(String item: docItems){
			if(!item.equals("") && item.split("@@@").length >= 9) {				
				String[] splitItem = item.split("@@@");
				
				if(splitItem.length > 1) {	
					CoviMap mapDoc = new CoviMap();
					mapDoc.put("processID",splitItem[0]);
					mapDoc.put("formInstID",splitItem[3]);
					mapDoc.put("formPrefix",splitItem[1]);
					mapDoc.put("subject",splitItem[2]);
					mapDoc.put("docNo",splitItem[8]);
					mapDoc.put("bStored",splitItem[4]);
					
					listReturn.add(mapDoc);
				}
			}
		}
				
		return listReturn;
	}
	
	public CoviList getEDMSDocLinks(String edmsDocLinks) throws Exception {
		CoviList listReturn = new CoviList();
		
		String[] docItems = edmsDocLinks.split("\\^\\^\\^");
		
		for(String item: docItems){
			if(!item.equals("") && item.split("@@@").length >= 8) {				
				String[] splitItem = item.split("@@@");
				
				if(splitItem.length > 1) {	
					CoviMap mapDoc = new CoviMap();
					mapDoc.put("bizSection",splitItem[0]);
					mapDoc.put("menuID",splitItem[1]);
					mapDoc.put("version",splitItem[2]);
					mapDoc.put("folderID",splitItem[3]);
					mapDoc.put("messageID",splitItem[4]);
					mapDoc.put("subject",splitItem[5]);
					mapDoc.put("number",splitItem[7]);
					
					listReturn.add(mapDoc);
				}
			}
		}
				
		return listReturn;
	}
	
	public String getProcessState(String processState, String businessState) throws Exception {
		String strReturn = "";
		
		switch (processState) {
			case "288": strReturn = "Process"; break; 
			case "546": strReturn = "Cancel"; break;
			case "545": strReturn = "Complete(Forced)"; break;
			case "275": strReturn = "Error"; break;
			case "528": 
				if(businessState.startsWith("02_02")) strReturn = "Reject"; 
				else strReturn = "Complete"; 
				break; //3등급
			default : break;
		}
				
		return strReturn;
	}
	
	@Override
	public String getApiFormUrl(CoviMap processObj, CoviMap formInstance, CoviMap requestData) throws Exception {
		String url = "";
		
		String domainID = "";
		String domainCode = formInstance.optString("EntCode");
		String forminstID = formInstance.optString("FormInstID");
		String processID = processObj.optString("ProcessID");
		String workitemID = requestData.optString("workitemID");
		String mode = requestData.optString("mode");
		String userCode = processObj.optString("UserCode");
		String formtempID = requestData.optString("formtempID");
		
		if(formtempID.equals("")) {
			CoviMap params = new CoviMap();
			params.put("domainCode", domainCode);
			domainID = coviMapperOne.getString("form.formLoad.selectDomainID", params);
			
			url+=MessageHelper.getInstance().replaceLinkUrl(domainID, PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"),false)+"/approval/approval_Form.do"+"?";
			if(!StringUtil.isNull(mode)) url += "mode=" + mode + "&";
			url += "processID=" + processID + "&";
			url += "forminstanceID=" + forminstID + "&";
			if(!StringUtil.isNull(workitemID)) url += "workitemID=" + workitemID + "&";
			if(!StringUtil.isNull(workitemID)) url += "userCode=" + userCode + "&";
			//url += "archived=" + getArchived(status) + "&";
			url += "usisdocmanager=true"; // 수신함 문서 상단 버튼 표시용
	//		if(status.equalsIgnoreCase("CCINFO") || status.equalsIgnoreCase("CIRCULATION")) {
	//			url += "&subkind=" + ccType;
	//			
	//			if(type.equalsIgnoreCase("UR")){
	//				url += "&gloct=TCINFO";
	//			} else if(type.equalsIgnoreCase("GR")) {
	//				url += "&gloct=DEPART";
	//			}
	//		}
			if(requestData.optString("gloct").equalsIgnoreCase("JOBFUNCTION")) url += "&subkind=T008";
		}
		
		return url;
	}
	
	private boolean isJobFunctionManager(String jfCode, String strSessionUserID, String strSessionDnCode) {
		boolean isManager = false;
		
		CoviMap params = new CoviMap();
		params.put("JFCode", jfCode);
		params.put("UserID", strSessionUserID);
		params.put("DNCode", strSessionDnCode);
		
		CoviMap map = coviMapperOne.select("form.formLoad.selectJFManagerByCode", params);
		
		if(!StringUtil.isNull(map.optString("UserCode")))
			isManager = true;
		
		return isManager;
	}
	
	private boolean chkDeptConsultSub(CoviMap approvalLine) {
		boolean isDeptConsultSub = false;
		
		CoviMap apvLine = approvalLine.getJSONObject("steps");
		if(apvLine.has("division")){
			CoviList oDivisions = new CoviList();
			if(apvLine.get("division") instanceof CoviMap)
				oDivisions.add(apvLine.getJSONObject("division"));
			else if(apvLine.get("division") instanceof CoviList)
				oDivisions = apvLine.optJSONArray("division");
			
			outerLoop:
			for(Object jsonObj1 : oDivisions){
				CoviMap oDivision = (CoviMap) jsonObj1;
				CoviMap oDivTaskinfo = oDivision.optJSONObject("taskinfo");
				if(oDivTaskinfo.optString("status").equalsIgnoreCase("pending")) {
					if(oDivision.has("step")){
						CoviList oSteps = new CoviList();
						if(oDivision.get("step") instanceof CoviMap)
							oSteps.add(oDivision.getJSONObject("step"));
						else if(oDivision.get("step") instanceof CoviList)
							oSteps = oDivision.optJSONArray("step");
						
						for(Object jsonObj2 : oSteps){
							CoviMap oStep = (CoviMap) jsonObj2;
							
							if(oStep.has("ou")){
								CoviList oOus = new CoviList();
								if(oStep.get("ou") instanceof CoviMap)
									oOus.add(oStep.getJSONObject("ou"));
								else if(oStep.get("ou") instanceof CoviList)
									oOus = oStep.optJSONArray("ou");
								
								for(Object jsonObj3 : oOus){
									CoviMap oOu = (CoviMap) jsonObj3;
									
									if(oOu.has("person")){								// person
										CoviList oPersons = new CoviList();
										if(oOu.get("person") instanceof CoviMap)
											oPersons.add(oOu.getJSONObject("person"));
										else if(oOu.get("person") instanceof CoviList)
											oPersons = oOu.optJSONArray("person");
										
										for(Object jsonObj4 : oPersons){
											CoviMap oPerson = (CoviMap) jsonObj4;
											CoviMap taskInfo = oPerson.getJSONObject("taskinfo");
											
											if(taskInfo.optString("status").equalsIgnoreCase("pending") && oStep.optString("routetype").equalsIgnoreCase("consult")) {
												isDeptConsultSub = true;
												break outerLoop;
											}
										}
									}
								}
							}
						}
					} 
				}
			}
		}
		
		return isDeptConsultSub;
	}
	
	/**
	 * 발신 진행중인경우 회수/취소 가능, 다음결재자가 진행하지 않은경우 회수 진행한경우 취소
	 * @param approvalLine
	 * @return W : 회수 , C : 취소
	 */
	private String getCancelType(CoviMap approvalLine) {
		String cancelType = "";
		
		CoviMap apvLine = approvalLine.getJSONObject("steps");
		if(apvLine.has("division")){
			CoviList oDivisions = new CoviList();
			if(apvLine.get("division") instanceof CoviMap)
				oDivisions.add(apvLine.getJSONObject("division"));
			else if(apvLine.get("division") instanceof CoviList)
				oDivisions = apvLine.optJSONArray("division");
			
			boolean isFirst = true;
			
			outerLoop:
			for(Object jsonObj1 : oDivisions){
				CoviMap oDivision = (CoviMap) jsonObj1;
				CoviMap oDivTaskinfo = oDivision.optJSONObject("taskinfo");
				if(oDivision.optString("divisiontype").equalsIgnoreCase("send")) {
					if(oDivTaskinfo.optString("status").equalsIgnoreCase("pending")) {
						cancelType = "W";
						if(oDivision.has("step")){
							CoviList oSteps = new CoviList();
							if(oDivision.get("step") instanceof CoviMap)
								oSteps.add(oDivision.getJSONObject("step"));
							else if(oDivision.get("step") instanceof CoviList)
								oSteps = oDivision.optJSONArray("step");
							
							
							for(Object jsonObj2 : oSteps){
								CoviMap oStep = (CoviMap) jsonObj2;
								
								if(oStep.has("ou")){											// ou
									CoviList oOus = new CoviList();
									if(oStep.get("ou") instanceof CoviMap)
										oOus.add(oStep.getJSONObject("ou"));
									else if(oStep.get("ou") instanceof CoviList)
										oOus = oStep.optJSONArray("ou");
									
									for(Object jsonObj3 : oOus){
										CoviMap oOu = (CoviMap) jsonObj3;
										
										if(oOu.has("person")){								// person
											CoviList oPersons = new CoviList();
											if(oOu.get("person") instanceof CoviMap)
												oPersons.add(oOu.getJSONObject("person"));
											else if(oOu.get("person") instanceof CoviList)
												oPersons = oOu.optJSONArray("person");
											
											for(Object jsonObj4 : oPersons){
												CoviMap oPerson = (CoviMap) jsonObj4;
												CoviMap taskInfo = oPerson.getJSONObject("taskinfo");
												
												// !taskInfo.optString("kind").equalsIgnoreCase("charge")
												// 부서합의 재기안자도 charge이므로 첫person 넘기도록 변경
												if(!isFirst
														&& !taskInfo.optString("kind").equals("conveyance")
														&& !StringUtil.isNull(taskInfo.optString("datecompleted"))) {
													cancelType = "C";
													break outerLoop;
												}
												isFirst = false;
											}
										} 
									} // for oOus
								} // oStep.has("ou")
							} // for oSteps
						} // oDivision.has("step")
					} else {
						break outerLoop;
					}
				}
			} // for oDivisions
		}
		
		return cancelType;
	}
	
	@Override
	public CoviMap getFormPdf(HttpServletRequest request, HttpServletResponse response, CoviMap formInfo) throws Exception {
		
		CoviMap pdfResult = new CoviMap();
		
		try {
			// url 생성
			String requestUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
			String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
			if("Y".equals(isSaaS)) {
				String PCGWServerURL = RedisDataUtil.getBaseConfig("PCGWServerURL", SessionHelper.getSession("DN_ID"));
				if(!StringUtil.isEmpty(PCGWServerURL)) {
					requestUrl = PCGWServerURL;
				}
			}
			String baseHref = requestUrl;
			String viewUrl = baseHref + "/approval/pdfTransferView.do";
			// 기초설정에 별도 URL 이 셋팅되어있다면 해당 URL 을 사용한다.
			String approvalDocRenderURL = RedisDataUtil.getBaseConfig("ApprovalDocRenderURL");
			if(StringUtil.isNotNull(approvalDocRenderURL)) {
				viewUrl = approvalDocRenderURL;
				if(!viewUrl.startsWith("http")) {
					viewUrl = requestUrl + viewUrl;
				}
			}

			CoviMap oFormInfo = ((formInfo.optJSONObject("formData")).getJSONObject("formInfo"));
			String initiatorID = oFormInfo.optString("initiatorID");
			String processID = oFormInfo.optString("processID");
			String formInstID = oFormInfo.optString("formInstID");
			if(StringUtil.isNull(initiatorID) || StringUtil.isNull(processID)) {
				throw new Exception("Form/Process Data Not Found.");
			}

			StringBuilder buf = new StringBuilder();
			buf.append("callMode=PDF");
						buf.append("&formInstanceID=" + formInstID);
						buf.append("&processID=" + processID);
						buf.append("&logonId=" + initiatorID);
						buf.append("&PAGEONLY=Y");
			String url = viewUrl + "?" + buf.toString();
					
			
			Map<String, String> paramMap = new HashMap<>();
			paramMap.put("url", url);
			
			// html 추출
			CoviMap rst = ChromeRenderManager.getInstance().renderURLOnChrome(paramMap.get("url"));
			
			pdfResult.put("status", rst.optString("status"));
			pdfResult.put("message", rst.optString("message"));
			
			if(pdfResult.optString("status").equals(Return.SUCCESS.toString())) {
				paramMap.put("txtHtml", rst.optString("rtnHtml"));
				
				// pdf변환 후 파일경로 조회
				CoviMap pdfInfo = ChromeRenderManager.getInstance().createPdf(paramMap);
				
				String saveFileName = (String)pdfInfo.get("saveFileName");
				String savePath = (String)pdfInfo.get("savePath");// Full path.
				
				// pdf 다운로드
				File file = new File(FileUtil.checkTraversalCharacter(savePath + saveFileName));
				
				response.reset();
				
				OutputStream os = null;
				try (InputStream is = new FileInputStream(file);){
					response.setHeader("Content-Length", Long.toString(file.length()));
					response.setHeader("Content-Description", "JSP Generated Data");
					response.setHeader("Content-Type", "application/octet-stream; charset=utf-8");
					String disposition = FileUtil.getDisposition(URLDecoder.decode(saveFileName, "UTF-8"), FileUtil.getBrowser(request));
					response.setHeader("Content-Disposition", disposition);
					
					os = response.getOutputStream();
					byte b[] = new byte[8192];
					int leng = 0;
	
					int bytesBuffered=0;
					while ( (leng = is.read(b)) > -1){
						os.write(b,0, leng);
						bytesBuffered += leng;
						if(bytesBuffered > 1024 * 1024){ //flush after 1M
							bytesBuffered = 0;
							os.flush();
						}
					}
					os.flush();
				}finally {
					if(os != null){ 
						try{ os.close(); } 
						catch(IOException e){ LOGGER.error(e.getLocalizedMessage(), e); } 
						catch(Exception e){ LOGGER.error(e.getLocalizedMessage(), e); }
					}
					if(file.exists() && file.isFile()) { 
						if(!file.delete()) {
							LOGGER.warn("file delete failed.");
						}
					}
				}
			} 
		} catch (NullPointerException npE) {
			pdfResult.put("status", Return.FAIL.toString());
			pdfResult.put("message", npE.getMessage());
		} catch (Exception e) {
			pdfResult.put("status", Return.FAIL.toString());
			pdfResult.put("message", e.getMessage());
		}	
		
		return pdfResult;
	}
	
	@Override
	public int setDeputyData(CoviMap baseInfo) throws Exception {
		return coviMapperOne.update("user.rightApprovalConfig.updateUserSettingDeputy",baseInfo);
	}
	
	@Override
	public CoviMap getUserFormList() throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap params = new CoviMap();

		params.put("entCode", SessionHelper.getSession("DN_Code"));
		params.put("deptCode", SessionHelper.getSession("GR_Code"));
		params.put("isSaaS", isSaaS);
		
		CoviList list = coviMapperOne.list("user.formlList.selectFormListData", params);
		
		returnObj.put("list", list.toString());

		return returnObj;
	}

	@Override
	public int setSignData(CoviMap baseInfo) {
		int cnt = 0;
		if(baseInfo.get("IsUse").equals("Y")){
			cnt += coviMapperOne.update("user.signRegistration.insertUserSignUseN",baseInfo);
		}
		cnt += coviMapperOne.insert("user.signRegistration.insertUserSign",baseInfo);
		return cnt;
	}
	
	@Override
	public CoviList getReceiptList(CoviMap params) throws Exception {
		params.put("entCode", SessionHelper.getSession("DN_Code"));
		params.put("deptCode", params.optString("deptCode"));
		
		CoviList list = coviMapperOne.list("form.forLegacy.selectOrgDeptInfo", params);
		
		return list;
	}
}