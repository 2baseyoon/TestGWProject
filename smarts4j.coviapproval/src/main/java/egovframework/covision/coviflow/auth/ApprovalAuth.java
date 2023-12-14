package egovframework.covision.coviflow.auth;

import java.nio.charset.StandardCharsets;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.form.dto.FormRequest;
import egovframework.covision.coviflow.form.dto.UserInfo;
import egovframework.covision.coviflow.form.service.ApvProcessSvc;
import egovframework.covision.coviflow.form.service.ApvlineManagerSvc;
import egovframework.covision.coviflow.form.service.FormAuthSvc;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.form.service.NonApvProcessSvc;
import egovframework.covision.coviflow.user.service.FormListSvc;
import egovframework.covision.coviflow.user.service.JobFunctionListSvc;
import egovframework.covision.coviflow.user.service.SignRegistrationSvc;
import egovframework.covision.coviflow.user.service.UserListFolderSvc;



public class ApprovalAuth {
	
	public static final Logger logger = Logger.getLogger(ApprovalAuth.class);
	private static FormSvc formSvc = StaticContextAccessor.getBean(FormSvc.class);	
	private static ApvProcessSvc apvProcessSvc = StaticContextAccessor.getBean(ApvProcessSvc.class);
	private static FormAuthSvc formAuthSvc = StaticContextAccessor.getBean(FormAuthSvc.class);		
	/**
	 * 문서단건 조회권한 체크
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	public static boolean getReadAuth(CoviMap params) {
		
		if(SessionHelper.getSession("isAdmin").equals("Y")) return true;
		
		Set<Map.Entry<String, Object>> set = params.entrySet();
		String formInstanceID = "";
		String processID = "";

		for(Map.Entry<String, Object> entry : set) {
			logger.debug("CoviMap : " + entry.getKey() + " : " + entry.getValue());
			if("formobj".equalsIgnoreCase(entry.getKey())) {
				Object formObject = entry.getValue();
				CoviMap formobj = null;
				if(formObject instanceof CoviMap) {
					formobj = (CoviMap)entry.getValue();
				}else if(formObject instanceof String) {
					formobj = CoviMap.fromObject(new String(Base64.decodeBase64(entry.getValue().toString().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
				}
				if(formobj != null) {
					Iterator<String> keys = formobj.keys();
					while(keys.hasNext()) {
						String key = keys.next();
						if (key.equalsIgnoreCase("forminstanceid") || key.equalsIgnoreCase("fiid") || key.equalsIgnoreCase("forminstid") || key.equalsIgnoreCase("formInstId")) {
							formInstanceID = formobj.getString(key);
						}
						if (key.equalsIgnoreCase("processid") || key.equalsIgnoreCase("piid")) {
							processID = formobj.getString(key);
						}
					}
				}
			}
			
			if("forminstanceid".equalsIgnoreCase(entry.getKey())
					|| "fiid".equalsIgnoreCase(entry.getKey())
					|| "forminstid".equalsIgnoreCase(entry.getKey())
					|| "FormIstID".equalsIgnoreCase(entry.getKey())) {
				formInstanceID = String.valueOf(entry.getValue());
			}
			if("processid".equalsIgnoreCase(entry.getKey())
					|| "piid".equalsIgnoreCase(entry.getKey())) {
				processID = String.valueOf(entry.getValue());
			}
		}
		
		// 조회시.
		params.put("forminstanceID",StringUtil.replaceNull(formInstanceID,""));
		params.put("processID",StringUtil.replaceNull(processID,""));
		FormRequest formRequest = initFormRequest(params);
		UserInfo userInfo = initFormSession();
		if(StringUtil.isNotNull(formInstanceID) || StringUtil.isNotNull(processID)) {
			boolean processChk = false;
			
			if(StringUtil.isNull(processID) && StringUtil.isNotNull(formInstanceID)) {
				// processID from formInstanceID
				params.put("formInstID", formInstanceID);
				try {
					CoviList arr = (CoviList)(formSvc.selectFormInstance(params)).get("list");
					if(arr.isEmpty()) {
						arr = (CoviList)(formSvc.selectFormInstanceStore(params)).get("list");				
					}
					if(arr == null || arr.isEmpty()) {
						logger.warn("forminstance info not found.");
						return false;
					}
					
					CoviMap formInstance = arr.getJSONObject(0);
					int intProcessID = formInstance.optInt("ProcessID");
					if(intProcessID > 0) {
						processID = String.valueOf(intProcessID);
					}
				} catch (NullPointerException npE) {
					logger.warn("forminstance info not found.");
					return false;
				} catch (Exception e) {
					logger.warn("forminstance info not found.");
					return false;
				}
			}
			if(StringUtil.isNotNull(processID)) {
				// ProcessID 만 넘어오는 경우 formInstanceId 를 찾는다. ( mobile e-accounting )
				if(StringUtil.isNull(formInstanceID)) {
					try {
						params.put("ProcessID",StringUtil.replaceNull(processID,""));
						formInstanceID = formSvc.selectFormInstanceID(params);// ProcessID
						formRequest.setFormInstanceID(StringUtil.replaceNull(formInstanceID,""));
					} catch (NullPointerException npE) {
						logger.warn("forminstance info not found.");
						return false;
					} catch (Exception e) {
						logger.error(e.getLocalizedMessage(), e);
						return false;
					}
				}
				processChk = true;
			}

			boolean hasReadAuth = false;
			if (processChk){
				try {
					hasReadAuth = formAuthSvc.hasReadAuth(formRequest, userInfo);
				} catch (NullPointerException npE) {
					logger.error(npE.getLocalizedMessage(), npE);
					return false;
				} catch (Exception e) {
					logger.error(e.getLocalizedMessage(), e);
					return false;
				}
			}
			if(!hasReadAuth){
				logger.warn("Approval auth check failed. (by Audit Filter)");
				return false;
			}
		}else {
			logger.warn("forminstanceid or processid parameter is empty.");
			return false;
		}
		return true;
	}
	
	/**
	 * 개인폴더 조회 및 수정권한 체크
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	public static boolean getFolderAuth(CoviMap params) {
		Set<Map.Entry<String, Object>> set = params.entrySet();
		String folderId = "";
		String folderListId = "";
		for(Map.Entry<String, Object> entry : set) {
			logger.debug("CoviMap : " + entry.getKey() + " : " + entry.getValue());
			
			if("folderId".equalsIgnoreCase(entry.getKey())){
				folderId = String.valueOf(entry.getValue());
			}
			if("FolderListID".equalsIgnoreCase(entry.getKey())){
				folderListId = String.valueOf(entry.getValue()); // comma separated.
			}
		}
		
		// 조회시.
		UserInfo fSes = initFormSession();
		// 단건 또는 이동대상폴더(Target)
		if(StringUtil.isNotNull(folderId)) {
			CoviMap paramf = new CoviMap();

			paramf.put("userID", fSes.getUserID());
			paramf.put("folderId", folderId);
			int retrunCnt = 0;
			try {
				UserListFolderSvc userListFolderSvc = StaticContextAccessor.getBean(UserListFolderSvc.class);
				retrunCnt = userListFolderSvc.selectUserFolderAuth(paramf);
			} catch (NullPointerException npE) {
				logger.error(npE.getLocalizedMessage(), npE);
			} catch (Exception e) {
				logger.error(e.getLocalizedMessage(), e);
			}
			if (retrunCnt < 1) return false;
		}
		// 다건일 경우 (Source)
		else if(StringUtil.isNotNull(folderListId)) {
			String[] folderIDs = StringUtils.split(folderListId, ",");
			CoviMap paramf = new CoviMap();
			for(int i = 0; folderIDs != null && i < folderIDs.length; i++) {
				paramf.put("userID", fSes.getUserID());
				paramf.put("folderId", folderIDs[i]);

				int retrunCnt = 0;
				try {
					UserListFolderSvc userListFolderSvc = StaticContextAccessor.getBean(UserListFolderSvc.class);
					retrunCnt = userListFolderSvc.selectUserFolderAuth(paramf);
				} catch (NullPointerException npE) {
					logger.error(npE.getLocalizedMessage(), npE);
				} catch (Exception e) {
					logger.error(e.getLocalizedMessage(), e);
				}
				if (retrunCnt < 1) return false;
			}
		}
		else {
			logger.warn("FolderAuth folderid parameter is empty.");
			return false;
		}
		return true;
	}
	
	/**
	 * 서명 수정 및 삭제권한 체크
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	public static boolean getSignAuth(CoviMap params) {
		Set<Map.Entry<String, Object>> set = params.entrySet();
		String signID = "";
		String fileName = ""; //모바일
		for(Map.Entry<String, Object> entry : set) {
			logger.debug("CoviMap : " + entry.getKey() + " : " + entry.getValue());
			
			if("SignID".equalsIgnoreCase(entry.getKey())){
				signID = String.valueOf(entry.getValue());
			}
			if("fileName".equalsIgnoreCase(entry.getKey())){
				fileName = String.valueOf(entry.getValue());
			}			
		}
		
		// 조회시.
		UserInfo fSes = initFormSession();
		if(StringUtil.isNotNull(signID) || StringUtil.isNotNull(fileName)) {
			CoviMap paramf = new CoviMap();

			paramf.put("userID", fSes.getUserID());
			paramf.put("signID", signID);
			paramf.put("fileName", fileName);			
			
			int retrunCnt = 0;
			try {
				SignRegistrationSvc signRegistrationSvc = StaticContextAccessor.getBean(SignRegistrationSvc.class);	
				retrunCnt = signRegistrationSvc.selectUserSignAuth(paramf);
			} catch (NullPointerException npE) {
				logger.error(npE.getLocalizedMessage(), npE);
			} catch (Exception e) {
				logger.error(e.getLocalizedMessage(), e);
			}
			if (retrunCnt < 1) return false;
		}else {
			logger.warn("SignAuth signID parameter is empty.");
			return false;
		}
		return true;
	}
	
	/**
	 * 즐겨찾기 삭제 권한
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	public static boolean getFavoriteAuth(CoviMap params) {
		Set<Map.Entry<String, Object>> set = params.entrySet();
		String formID = "";
		for(Map.Entry<String, Object> entry : set) {
			logger.debug("CoviMap : " + entry.getKey() + " : " + entry.getValue());

			if("formID".equalsIgnoreCase(entry.getKey())){
				formID = String.valueOf(entry.getValue());
			}
		}
		
		// 조회시.
		UserInfo fSes = initFormSession();
		if(StringUtil.isNotNull(formID)) {
			CoviMap paramf = new CoviMap();

			paramf.put("userID", fSes.getUserID());
			paramf.put("formID", formID);
			int retrunCnt = 0;
			try {
				FormListSvc formListSvc = StaticContextAccessor.getBean(FormListSvc.class);
				retrunCnt = formListSvc.selectFavoriteAuth(paramf);
			} catch (NullPointerException npE) {
				logger.error(npE.getLocalizedMessage(), npE);
			} catch (Exception e) {
				logger.error(e.getLocalizedMessage(), e);
			}
			if (retrunCnt < 1) return false;
		}else {
			logger.warn("FavoriteAuth formID parameter is empty.");
			return false;
		}
		return true;
	}
	
	/**
	 * 결재선 삭제 권한
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	public static boolean getApvlineAuth(CoviMap params) {
		Set<Map.Entry<String, Object>> set = params.entrySet();
		String groupID = "";
		for(Map.Entry<String, Object> entry : set) {
			logger.debug("CoviMap : " + entry.getKey() + " : " + entry.getValue());

			if("groupID".equalsIgnoreCase(entry.getKey())){
				groupID = String.valueOf(entry.getValue());
			}
		}
		
		// 조회시.
		UserInfo fSes = initFormSession();
		if(StringUtil.isNotNull(groupID)) {
			CoviMap paramf = new CoviMap();

			paramf.put("ownerID", fSes.getUserID());
			paramf.put("groupID", groupID); //개인수신처
			int retrunCnt = 0;
			try {
				ApvlineManagerSvc apvlineManagerSvc = StaticContextAccessor.getBean(ApvlineManagerSvc.class);
				retrunCnt = apvlineManagerSvc.selectApvlineAuth(paramf);
			} catch (NullPointerException npE) {
				logger.error(npE.getLocalizedMessage(), npE);
			} catch (Exception e) {
				logger.error(e.getLocalizedMessage(), e);
			}
			if (retrunCnt < 1) return false;
		}else {
			logger.warn("FavoriteAuth formID parameter is empty.");
			return false;
		}
		return true;
	}
	
	/**
	 * 참조/회람 리스트 선택 삭제
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	public static boolean getCirculationAuth(CoviMap params) {
		Set<Map.Entry<String, Object>> set = params.entrySet();
		String circulationBoxID = "";
		for(Map.Entry<String, Object> entry : set) {
			logger.debug("CoviMap : " + entry.getKey() + " : " + entry.getValue());

			if("circulationBoxID".equalsIgnoreCase(entry.getKey())){
				circulationBoxID = String.valueOf(entry.getValue());
			}
		}
		
		// 조회시.
		UserInfo fSes = initFormSession();
		if(StringUtil.isNotNull(circulationBoxID)) {
			CoviMap paramf = new CoviMap();

			paramf.put("userID", fSes.getUserID());
			paramf.put("circulationBoxID", circulationBoxID);
			int retrunCnt = 0;
			try {
				NonApvProcessSvc nonApvProcessSvc = StaticContextAccessor.getBean(NonApvProcessSvc.class);
				retrunCnt = nonApvProcessSvc.selectCirculationAuth(paramf);
			} catch (NullPointerException npE) {
				logger.error(npE.getLocalizedMessage(), npE);
			} catch (Exception e) {
				logger.error(e.getLocalizedMessage(), e);
			}
			if (retrunCnt < 1) return false;
		}else {
			logger.warn("FavoriteAuth formID parameter is empty.");
			return false;
		}
		return true;
	}	
	
	/**
	 * 담당업무함 권한
	 * @param params
	 * @return
	 * @throws Exception 
	 */
	public static boolean getJobfunctionAuth(CoviMap params) {
		Set<Map.Entry<String, Object>> set = params.entrySet();
		String jobFunctionCode = "";
		for(Map.Entry<String, Object> entry : set) {
			logger.debug("CoviMap : " + entry.getKey() + " : " + entry.getValue());

			if("jobFunctionCode".equalsIgnoreCase(entry.getKey())){
				jobFunctionCode = String.valueOf(entry.getValue());
			}
		}
		
		// 조회시.
		UserInfo fSes = initFormSession();
		if(StringUtil.isNotNull(jobFunctionCode)) {
			CoviMap paramf = new CoviMap();

			paramf.put("userID", fSes.getUserID());
			paramf.put("jobFunctionCode", jobFunctionCode);
			paramf.put("entCode", fSes.getDNCode());
			int retrunCnt = 0;
			try {
				JobFunctionListSvc jobFunctionListSvc = StaticContextAccessor.getBean(JobFunctionListSvc.class);
				retrunCnt = jobFunctionListSvc.selectJobfunctionAuth(paramf);
			}catch (NullPointerException npE) {
				logger.error(npE.getLocalizedMessage(), npE);
			} catch (Exception e) {
				logger.error(e.getLocalizedMessage(), e);
			}
			if (retrunCnt < 1) return false;
		}else {
			logger.warn("FavoriteAuth formID parameter is empty.");
			return false;
		}
		return true;
	}
	
	
	/**
	 * 임시함,반려함 결재문서 삭제 (workItem 소유자만 , 기안자 X)
	 * @param params
	 * @return
	 */
	public static boolean getWorkItemOwnerAuth(CoviMap params) {
		Set<Map.Entry<String, Object>> set = params.entrySet();
		String workItemID = "";
		String formInstId = "";
		for(Map.Entry<String, Object> entry : set) {
			logger.debug("CoviMap : " + entry.getKey() + " : " + entry.getValue());
			if("workItemID".equalsIgnoreCase(entry.getKey())){
				workItemID = String.valueOf(entry.getValue());
			}
			if("FormInstId".equalsIgnoreCase(entry.getKey())){
				formInstId = String.valueOf(entry.getValue());
			}
		}
		
		// 조회시.
		UserInfo fSes = initFormSession();
		if(StringUtil.isNotNull(workItemID)) {
			String [] workItemIDs = new String[1];
			if(workItemID.indexOf(",") > -1) {
				workItemIDs = workItemID.split(",");
			}else {
				workItemIDs[0] = workItemID;
			}
			for(String _workItemID : workItemIDs) {
				params.put("workitemID", _workItemID);
				params.put("IsArchived", "true");
				try {
					CoviMap resultObj = formSvc.selectProcess(params);
					if(resultObj.getJSONArray("list") == null || resultObj.getJSONArray("list").size() <= 0) {
						return true;
					}
					CoviMap processObj = (((CoviList)resultObj.get("list")).getJSONObject(0));	// process 및 workitem 조합 데이터
					
					// workitem 소유자 및 deputyID 와 비교한다.
					String initiator = processObj.getString("UserCode");
					String deputyID = processObj.getString("DeputyID");
					
					return initiator.equals(fSes.getUserID()) || deputyID.equals(fSes.getUserID());
				} catch (NullPointerException npE) {
					logger.error("", npE);
					logger.warn("process info(by workitemid) not found.");
					return false;
				} catch (Exception e) {
					logger.error("", e);
					logger.warn("process info(by workitemid) not found.");
					return false;
				}
			}
			logger.warn("workItemID parameter is empty.");
			return false;
		}else if(StringUtil.isNotNull(formInstId)){
			// 임시함인 경우 formInstanceID 로 확인
			params.put("formInstID", formInstId);
			try {
				CoviMap resultObj = formSvc.selectFormInstance(params);
				CoviMap processObj = (((CoviList)resultObj.get("list")).getJSONObject(0));	// process 및 workitem 조합 데이터
				
				String initiator = processObj.getString("InitiatorID");
				return initiator.equals(fSes.getUserID());
			} catch (NullPointerException npE) {
				logger.error("", npE);
				logger.warn("process info(by formInstanceId) not found.");
				return false;
			} catch (Exception e) {
				logger.error("", e);
				logger.warn("process info(by formInstanceId) not found.");
				return false;
			}
			
		}else {
			logger.warn("workItemID parameter is empty.");
			return false;
		}
	}
	
	/**
	 * 임시저장 / 상신 (initiator 체크) / 승인시
	 * /draft.do, /tempSave.do 에 사용중
	 * @param params
	 * @return
	 */
	public static boolean getTempSaveOwnerAuth(CoviMap params) {
		Set<Map.Entry<String, Object>> set = params.entrySet();
		String initiatorID = "";
		String processID = "";
		String usid = "";
		CoviMap formObj = null;
		CoviMap formData = null;
		for(Map.Entry<String, Object> entry : set) {
			logger.debug("CoviMap : " + entry.getKey() + " : " + entry.getValue());
			if("formobj".equalsIgnoreCase(entry.getKey())) {
				Object formObject = entry.getValue();
				if(formObject instanceof CoviMap) {
					formObj = (CoviMap)entry.getValue();
				}else if(formObject instanceof String) {
					formObj = CoviMap.fromObject(new String(Base64.decodeBase64(entry.getValue().toString().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
				}
				usid = formObj.optString("usid");
				processID = formObj.optString("processID");
				if(formObj.containsKey("FormData")) {
					formData = formObj.getJSONObject("FormData");
					initiatorID = formData.optString("InitiatorID");
				}
			}
		}
		
		// 임시저장, 기안 (tempSave.do, draft.do) 시에는 본인것만 가능함.
		UserInfo fSes = initFormSession();
		String menuUrl = params.getString("menuUrl");
		boolean initiatorCheck = false;
		if(menuUrl.indexOf("/draft.do") > -1 && formObj != null) {
			String mode = formObj.optString("mode");
			if (mode.equals("DRAFT") || mode.equals("TEMPSAVE") || mode.equals("WITHDRAW")) {
				// 기안시에만
				initiatorCheck = true;
			}else {
				initiatorCheck = false;
				if(mode.equals("APPROVAL") || mode.equals("PROCESS") || mode.equals("REDRAFT") || mode.equals("PCONSULT")) {
					// 승인시에는 taskid 기준 usercode 로 체크한다. usercode, unitcode, 담당업무함 코드
					params.put("formObj", formObj);
					return ApprovalAuth.getTaskIDAuth(params);
				}
			}
		} else {
			// 임시저장
			initiatorCheck = true;
		}
		if(initiatorCheck) {
			if(StringUtil.isNotNull(initiatorID) && StringUtil.isNotNull(usid)) {
				if(!initiatorID.equals(fSes.getUserID()) || !usid.equals(fSes.getUserID())) {
					return false;
				}else {
					return true;
				}
			}else {
				logger.warn("formObj's initiatorID parameter is empty.");
				return false;
			}
		}
		return true;
	}
	
	/**
	 * TaskID 기반 권한 체크 (승인,반려등)
	 * @param params
	 * @return
	 */
	public static boolean getTaskIDAuth(CoviMap params) {
		Object formObject = params.get("formObj");
		CoviMap formObj = null;
		if(formObject instanceof CoviMap) {
			formObj = (CoviMap)params.get("formObj");
		}else if(formObject instanceof String) {
			formObj = CoviMap.fromObject(new String(Base64.decodeBase64(formObject.toString().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
		}
		
		if(formObj != null) {
			String actionMode = formObj.getString("actionMode");
			if("APPROVAL".equals(actionMode) || "REJECT".equals(actionMode) || "REDRAFT".equals(actionMode)
					|| "AGREE".equals(actionMode) || "DISAGREE".equals(actionMode) || "RESERVE".equals(actionMode) ) {
				try {
					String taskId = formObj.getString("taskID");
					
					CoviMap param = new CoviMap();
					param.put("userCode", SessionHelper.getSession("USERID"));
					param.put("unitCode", SessionHelper.getSession("DEPTID"));
					String apvUnitCode = SessionHelper.getSession("ApprovalParentGR_Code");// 결재부서확인
					if(StringUtil.isNotNull(apvUnitCode)) {
						param.put("unitCode", apvUnitCode);
					}
					param.put("taskID", taskId);
					if(StringUtil.isNotNull(taskId) && !apvProcessSvc.getAuthByTaskID(param)) {
						logger.debug("TaskID["+taskId+"] is not authorized to user["+param.getString("userCode")+"].");
						return false;
					}
				} catch (NullPointerException npE) {
					logger.error(npE.getLocalizedMessage(), npE);
				} catch (Exception e) {
					logger.error(e.getLocalizedMessage(), e);
				}
			}
		}
		
		return true;
	}
	
	private static FormRequest initFormRequest(CoviMap params){
		FormRequest fReq = new FormRequest();
		
		/** Request */
		fReq.setReadMode("COMPLETE");
        fReq.setBstored(StringUtil.replaceNull(params.getString("bstored"), "false")); 						// bStored. 이관함 여부
        
        fReq.setOwnerProcessId(StringUtil.replaceNull(params.getString("ownerProcessId"), ""));
        fReq.setOwnerExpAppID(StringUtil.replaceNull(params.getString("ownerExpAppID"), "")); // 경비결재 오픈 여부 확인
        
        fReq.setGovState(StringUtil.replaceNull(params.getString("GovState"), ""));
        fReq.setGovDocID(StringUtil.replaceNull(params.getString("GovDocID"), ""));

        fReq.setIsOpen(StringUtil.replaceNull(params.getString("isOpen"), "")); // 사업관리 오픈 여부 확인 [21-02-01 add]
        
        fReq.setFormInstanceID(StringUtil.replaceNull(params.getString("forminstanceID"), ""));
        fReq.setProcessID(StringUtil.replaceNull(params.getString("processID"), ""));
        fReq.setGovRecordID(StringUtil.replaceNull(params.getString("GovRecordID"), ""));
 
		return fReq;
	}
	
	private static UserInfo initFormSession() {
		UserInfo fSes = new UserInfo();
		//세션 값
        fSes.setUserID(SessionHelper.getSession("USERID"));
        fSes.setDeptID(SessionHelper.getSession("DEPTID"));
        fSes.setDNCode(SessionHelper.getSession("DN_Code"));
        return fSes;
	}
}
