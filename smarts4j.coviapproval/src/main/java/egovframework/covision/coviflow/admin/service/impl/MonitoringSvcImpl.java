package egovframework.covision.coviflow.admin.service.impl;

import java.io.File;
import java.io.FileNotFoundException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.Set;

import javax.annotation.Resource;

import org.apache.commons.collections.ListUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.covision.coviflow.admin.service.MonitoringSvc;
import egovframework.covision.coviflow.common.util.RequestHelper;
import egovframework.covision.coviflow.form.service.FormSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.egovframe.rte.fdl.idgnr.impl.Base64;



@Service("monitoringService")
public class MonitoringSvcImpl extends EgovAbstractServiceImpl implements MonitoringSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private FileUtilService fileUtilSvc;
	
	@Autowired
	private FormSvc formSvc;
	
	@Override
	public CoviList getFormInstance(String fiid) throws Exception {
		CoviMap params = new CoviMap();
		params.put("formInstID", fiid);		
		CoviList list = coviMapperOne.list("admin.monitoring.selectFormInstance", params);
		return convertToJSON(list);
	}
	
	@Override
	public int setFormInstance(CoviMap param) throws Exception {
		
		return coviMapperOne.update("admin.monitoring.updateFormInstance", param);
	}
	
	@Override
	public int setDomainData(CoviMap param) throws Exception {
		int returnVal = coviMapperOne.update("admin.monitoring.updateDomainData", param);
		//returnVal += coviMapperOne.update("admin.monitoring.updateDomainDataArchive", param);				
		return returnVal;
	}
	
	@Override
	public int setIsComment(CoviMap param) throws Exception {
		int returnVal = coviMapperOne.update("admin.monitoring.updateIsComment", param);
		
		return returnVal;
	}
	
	@Override
	public int setProcessStep(CoviMap param) throws Exception {
		String stepData = coviMapperOne.selectOne("admin.monitoring.selectProcessStep", param);
		
		int returnVal = 0;
		if(stepData != null && !stepData.equals("")){
			stepData = param.getString("stepTotalCount") + "_" + stepData.substring(stepData.indexOf("_")+1, stepData.length());
			
			param.put("ApprovalStep", stepData);
			returnVal = coviMapperOne.update("admin.monitoring.updateProcessDesc", param);
		}
		
		return returnVal;
	}
	
	@Override
	public int setWorkitemData(CoviMap param) throws Exception {		
		return coviMapperOne.update("admin.monitoring.updateWorkitemData", param);
	}

	@Override
	public int setDescriptionData(CoviMap param) throws Exception {
		return coviMapperOne.update("admin.monitoring.updateProcessDesc", param);
	}
	
	@Override
	public CoviMap getSuperAdminData(CoviMap param) throws Exception {		
		CoviList list = coviMapperOne.list("admin.monitoring.selectSuperAdminData", param);
		CoviList resultList = convertToJSON(list);		
		return resultList.getJSONObject(0);
	}
	
	@Override
	public CoviList getProcessList(String fiid) throws Exception {
		//covi approval 정보 get
		CoviMap params = new CoviMap();
		params.put("formInstID", fiid);
		
		CoviList list = coviMapperOne.list("admin.monitoring.selectProcess", params);
		return convertToJSON(list);
	}
	
	@Override
	public CoviList getProcessDesc(String pdescId) throws Exception {
		//covi approval 정보 get
		CoviMap params = new CoviMap();
		params.put("processDescriptionID", pdescId);
		
		CoviList list = coviMapperOne.list("admin.monitoring.selectProcessDesc", params);
		return convertToJSON(list);
	}
	
	@Override
	public CoviList getWorkitem(String processId) throws Exception {
		//covi approval 정보 get
		CoviMap params = new CoviMap();
		params.put("processID", processId);
		
		CoviList list = coviMapperOne.list("admin.monitoring.selectWorkitem", params);
		return convertToJSON(list);
	}
	
	@Override
	public CoviList getDomaindata(String processId) throws Exception {
		//covi approval 정보 get
		CoviMap params = new CoviMap();
		params.put("processID", processId);
		
		CoviList list = coviMapperOne.list("admin.monitoring.selectDomaindata", params);		
		return convertToJSON(list);
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

		if (!(reserved1.equals("") && reserved2.equals(""))) {
			params.put("Reserved1", reserved1);
			params.put("Reserved2", reserved2);
			params.put("FormInstID", formInstID);
			coviMapperOne.update("form.forminstance.updateDocNo", params);
		}
	}
	
	//Activiti Process Definition
	@Override
	public CoviMap getActivitiProcessDefinition() throws Exception {
		String url = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
		url += "/service/repository/process-definitions?size=999999";
		
		CoviMap returnObj =  (CoviMap)RequestHelper.sendGET(url).get("result");
		returnObj.put("data", convertNullJSON(returnObj.getJSONArray("data")));
		
		return returnObj;
		
	}
	
	//Activiti Process list
	@Override
	public CoviMap getActivitiProcessList(String processId) throws Exception {
		String url = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
		url += "/service/runtime/process-instances?id=" + processId;
		
		CoviMap returnObj =  (CoviMap)RequestHelper.sendGET(url).get("result");
		returnObj.getJSONArray("data").set(0, convertNullJSON(returnObj.getJSONArray("data").getJSONObject(0)));
				
		return returnObj;
	}
	
	//Activiti Tasks
	@Override
	public CoviMap getActivitiTasks(String processId) throws Exception {
		String url = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
		url += "/service/runtime/tasks?processInstanceId=" + processId;
		
		CoviMap returnObj =  (CoviMap)RequestHelper.sendGET(url).get("result");
		
		// 병렬협조 데이터 가져오지 못해서 수정함.
		returnObj.put("data", convertNullJSON(returnObj.getJSONArray("data")));
				
		return returnObj;
	}
	
	//Activiti Variables
	@Override
	public CoviList getActivitiVariables(String taskId) throws Exception {
		String url = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
		url += "/service/runtime/tasks/" + taskId + "/variables";
		
		CoviList returnObj =  (CoviList)RequestHelper.sendGET(url).get("result");
		returnObj = convertNullJSON(returnObj);
		
		return returnObj;
	}
	
	//Activiti Variable
	@Override
	public CoviMap getActivitiVariable(String taskId, String name) throws Exception {
		String url = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
		url += "/service/runtime/tasks/" + taskId + "/variables/" + name;
		
		CoviMap returnObj =  (CoviMap)RequestHelper.sendGET(url).get("result");
		returnObj = convertNullJSON(returnObj);
		
		return returnObj;
	}
	
	@Override
	public int setActivitiVariables(String taskId, CoviMap domainData) throws Exception {
		return setActivitiVariable(taskId, "g_appvLine", domainData.toString());
	}
	
	@Override
	public int setActivitiVariable(String taskId, String name, String value) throws Exception {
		HttpsUtil httpsUtil = new HttpsUtil();
		
		String url = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
		url += "/service/runtime/tasks/" + taskId + "/variables/" + name;
		
		String activitiID = PropertiesUtil.getGlobalProperties().getProperty("activiti.id");
        String activitiPW = PropertiesUtil.getGlobalProperties().getProperty("activiti.pw");

        CoviMap simpleJsonParam = new CoviMap();
        simpleJsonParam.setConvertJSONObject(false); // value는 string으로 넘겨야됨
        simpleJsonParam.put("name", name); 
        simpleJsonParam.put("value", value);
        simpleJsonParam.put("scope", "global");

		httpsUtil.httpsClientWithRequest(url, "PUT", simpleJsonParam, "UTF-8", "Basic " + Base64.encode((activitiID + ":" + activitiPW).getBytes(StandardCharsets.UTF_8)));
		
		return 1;
	}
	
	@Override
	public void doAction(String taskId, CoviMap param) throws Exception {
		// [20-03-30] Process & Workitem 상태 체크 start ---------------------------------------------------------
		CoviMap paramsObj = new CoviMap();
		paramsObj.put("TaskID", taskId);
		
		// 수동결재 시에는, 275인 경우에도 결재요청 가능하도록 수정함.
		String sPIState = coviMapperOne.selectOne("form.process.selectProcessState", paramsObj);
		if (sPIState == null || !(sPIState.equals("288") || sPIState.equals("275")))
		{
			throw new IllegalStateException(DicHelper.getDic("msg_apv_084"));
		}
		String sWIState = coviMapperOne.selectOne("form.process.selectWorkitemState", paramsObj);
		if (sWIState == null || !(sWIState.equals("288") || sWIState.equals("275")))
		{
			throw new IllegalStateException(DicHelper.getDic("msg_apv_084"));//"결재문서가 이미 처리되었습니다."
		}
		
		try {
			CoviList taskValues = getActivitiVariables(taskId);
			if(taskValues.isEmpty()) {
				throw new IllegalStateException(DicHelper.getDic("msg_apv_084"));//"결재문서가 이미 처리되었습니다."
			}	
		} catch (FileNotFoundException e) { // 활성화 된 task가 없는 경우
			throw new IllegalStateException(DicHelper.getDic("msg_apv_084"));//"결재문서가 이미 처리되었습니다."
		}
		// Process & Workitem 상태 체크 end ----------------------------------------------------------------------
		
		
		String url = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
		url += "/service/runtime/tasks/" + taskId;
		
		RequestHelper.sendPOST(url, param);
	}
	
	@Override
	public void abortProcessFormData(String pFormInstID, CoviMap pAppvLine, CoviList commentArray) throws Exception {
		CoviMap formObj = null;		
		CoviMap attachFileInfoObj = null;
		
		// region - 회수, 기안취소 처리
		// 회수 및 기안 취소시 FormInstance insert
		CoviMap paramsMap = new CoviMap();
		
		// FormInstance Insert
		paramsMap.put("FormInstID", pFormInstID);
		formObj = selectAbortInfo(paramsMap);
		
		coviMapperOne.insert("form.forminstance.insertForTempSave", paramsMap);
		String newFormInstID = paramsMap.optString("FormInstID");
		
		//하위테이블 Insert
		// fmid를 통해 subtable 가져옴
		
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
					
					CoviMap paramsObj = new CoviMap();
					paramsObj.put("tableName", tableName);
					paramsObj.put("columns", columeName);
					paramsObj.put("newFormInstID", newFormInstID);
					paramsObj.put("formInstID", pFormInstID);

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
		
		insertPrivateDomainData(formObj, formObj.getString("Subject"), pAppvLine);
		
		// 첨부파일 처리
		if(formObj.has("AttachFileInfo")) {
			List<MultipartFile> mf = new ArrayList<>();
			String sAttachFileInfo = new String(org.apache.commons.codec.binary.Base64.decodeBase64(formObj.optString("AttachFileInfo")),StandardCharsets.UTF_8);
			
			String objectID = "0";
			String serviceType = "Approval";
			String servicePath = "";
			String objectType = "DEPT";
			String messageID = formObj.optString("FormInstID");
			if(messageID.equals("")) messageID = "0";
			boolean isClear = false;
			
			CoviMap fileObj = new CoviMap();					// 파일 저장 후 리턴받은 com_file 테이블의 정보.
			CoviList fileInfos = new CoviList();
			Boolean isFileUpload = true;
			String isFile = "false";
			
			if(sAttachFileInfo != null && !sAttachFileInfo.equals("")) {
				attachFileInfoObj = CoviMap.fromObject(ComUtils.RemoveScriptAndStyle(sAttachFileInfo));
				if (attachFileInfoObj.getJSONArray("FileInfos").getJSONObject(0).containsKey("MessageID")) {
					fileInfos = fileUtilSvc.uploadToBack(attachFileInfoObj.getJSONArray("FileInfos"), mf, servicePath , serviceType, objectID, objectType, messageID, isClear);
					isFileUpload = true;
					fileObj.put("fileInfos", fileInfos);
					fileObj.put("isSucess", isFileUpload);
					
					if(!fileInfos.isEmpty()) isFile = "true";
					else isFile = "false";	
					
				}
				
				// attachFileInfo update
				setAttachFileInfo(fileInfos, formObj, attachFileInfoObj, isFile, sAttachFileInfo);
				
				// update com_file MessageID - 새로 추가된 첨부파일의 MessageID 수정
				setFormInstanceIDInComFile(isFileUpload, fileInfos, formObj);
			}
		}
	
		// 의견첨부가 존재하는 경우
		if(commentArray != null && !commentArray.isEmpty()) {
			CoviList tmpArray = commentArray; 
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
	
	@Override
	public CoviMap selectAbortInfo(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.listadmin.selectAbortInfo", params);
		return CoviSelectSet.coviSelectJSON(map, "FormID,FormName,Subject,InitiatorName,DomainDataContext,AttachFileInfo").getJSONObject(0);
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
	
	private CoviMap setAttachFileInfo(CoviList fileInfos, CoviMap formObj, CoviMap attachFileInfoObj, String isFile, String attachFileInfoStr) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviMap params = new CoviMap();
		if ((fileInfos != null && !fileInfos.isEmpty()) || (formObj.getString("mode").equals("APPROVAL") && attachFileInfoStr != null && attachFileInfoStr.equals("")) ) {
			// attachFileInfoObj를 가공 후, formInstance에서 update
			
			// FormInstID 삽입과 실제 경로 데이터 삽입.
			if(attachFileInfoStr == null){
				if (attachFileInfoObj.has("FileInfos") && !attachFileInfoObj.getJSONArray("FileInfos").isEmpty() && !attachFileInfoObj.isEmpty()) {
					CoviList arrObj = new CoviList();
					for(Object obj : fileInfos){
						CoviMap attFile = (CoviMap) obj;
						attFile.put("MessageID", formObj.getString("FormInstID"));
						
						arrObj.add(attFile);
					}	
					attachFileInfoObj.put("FileInfos", arrObj);
				}
				
				if(formObj.has("AttachFileSeq") && !formObj.optString("AttachFileSeq").equals("")) {
					String[] seqArr = formObj.getString("AttachFileSeq").split("\\|");
					CoviList arrObj2 = new CoviList();
					
					for(String seqInfo : seqArr) {						
						for(Object obj : attachFileInfoObj.getJSONArray("FileInfos")) {
							CoviMap jsonObj = (CoviMap) obj;
							if(jsonObj.optString("FileName").equals(seqInfo.split(":")[3])) {
								jsonObj.put("Seq", seqInfo.split(":")[1]);
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
			params.put("AttachFileInfo", (attachFileInfoStr != null) ? "" : replaceBodyContext(attachFileInfoObj.toString()));
			// 수정된 날짜, id 추가
			coviMapperOne.update("form.forminstance.updateAttachFileInfo",params);
			
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
	
	public String replaceBodyContext(String oBodyContext) {
		if (oBodyContext == null)
			return null;

		return new String(org.apache.commons.codec.binary.Base64.encodeBase64(oBodyContext.getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
	}
	
	private CoviList convertToJSON(CoviList clist) {
		CoviList returnArray = new CoviList();
		
		if(null != clist && !clist.isEmpty()){
				for(int i=0; i<clist.size(); i++){
					
					CoviMap newObject = new CoviMap();
					
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();
					
					while(iter.hasNext()){
						String ar = iter.next();
						newObject.put(ar, clist.getMap(i).getString(ar));
					}
					
					returnArray.add(newObject);
				}
			}
		
		return returnArray;
	}
	
	// 모니터링에서 activiti를 호출했을 경우, 반환값에서 NULL 값을 문자열 "NULL"값으로 변경
	public CoviMap convertNullJSON(CoviMap paramObj) {
		Iterator<?> keys = paramObj.keys();

		while (keys.hasNext()) {
			String key = (String) keys.next();
			if(paramObj.get(key) == null){
				paramObj.put(key, "NULL");
			}
		}
		
		return paramObj;
	}
	
	public CoviList convertNullJSON(CoviList paramArr) {
		for(Object obj :  paramArr){
			CoviMap paramObj = (CoviMap)obj;
			Iterator<?> keys = paramObj.keys();
	
			while (keys.hasNext()) {
				String key = (String) keys.next();
				if(paramObj.get(key) == null){
					paramObj.put(key, "NULL");
				}
			}
		}
		return paramArr;
	}
	
	@Override
	public CoviMap makeFormObj(String pFormInstID) throws Exception{
		CoviMap returnObj = new CoviMap();
		CoviMap paramsData = new CoviMap();
		
		paramsData.put("FormInstID", pFormInstID);
		CoviMap params = coviMapperOne.select("admin.listadmin.selectForminfo", paramsData);
		
		String ruleItemInfo = params.getString("RuleItemInfo");		
		String formPrefix = params.getString("FormID");
		
		CoviMap processDescription = new CoviMap();
		CoviMap approvalLine = CoviMap.fromObject(params.getString("DomainDataContext"));
		CoviMap formInfoExt = new CoviMap();
		CoviMap formData = new CoviMap();
		CoviMap docInfo = new CoviMap();
		
		params.put("formID", params.getString("FormID"));
		CoviMap formInfoData = formSvc.selectForm(params).getJSONArray("list").getJSONObject(0);
		
		CoviMap formInfoExtData = formInfoData.getJSONObject("ExtInfo");
		
		String formID = formInfoData.getString("FormID");
		String schemaID = formInfoData.getString("SchemaID");
		String formName = formInfoData.getString("FormName");
		String subject = params.getString("Subject");
		String docClassID = formInfoExtData.getString("DocClassID");
		String docClassName = formInfoExtData.getString("DocClassName");
		String saveTerm = formInfoExtData.getString("PreservPeriod");
		String docLevel = formInfoExtData.getString("SecurityGrade");
		
		params.put("schemaID", schemaID);
		CoviMap schemeData = formSvc.selectFormSchema(params).getJSONArray("list").getJSONObject(0).getJSONObject("SchemaContext");
		
		String processDefinitionID = schemeData.getJSONObject("pdef").getString("value");
		
		CoviMap urParams = new CoviMap();
		urParams.put("DeptCode", params.getString("InitiatorUnitID"));
		CoviMap list = coviMapperOne.select("form.org_person.selectGroupInfo", urParams);

		String deptCode = params.getString("InitiatorUnitID");
		String deptName = params.getString("InitiatorUnitName");
		String userCode = params.getString("InitiatorID");
		String userName = params.getString("InitiatorName");
		String entcode = list.optString("COMPANYCODE");
		String entname = list.optString("COMPANYNAME");
		String deptFullPath = list.optString("GROUPPATH");
		
		String appliedDate = DateHelper.getCurrentDay("yyyy-MM-dd HH:mm:ss");
		CoviMap bodyContext = CoviMap.fromObject(new String(org.apache.commons.codec.binary.Base64.decodeBase64(params.getString("BodyContext")),StandardCharsets.UTF_8));
		bodyContext.put("InitiatorDisplay", userName);
		bodyContext.put("InitiatorOUDisplay", deptName);
		
		processDescription.put("FormInstID", pFormInstID);
		processDescription.put("FormID", formID);
		processDescription.put("FormName", formName);
		processDescription.put("FormSubject", subject);
		processDescription.put("IsSecureDoc", "N");
		processDescription.put("IsFile", params.getString("IsFile"));
		processDescription.put("FileExt", "");
		processDescription.put("IsComment", "N");
		processDescription.put("ApproverCode", "");
		processDescription.put("ApproverName", "");
		processDescription.put("ApprovalStep", "");
		processDescription.put("ApproverSIPAddress", "");
		processDescription.put("IsReserved", "N");
		processDescription.put("ReservedGubun", "");
		processDescription.put("ReservedTime", "");
		processDescription.put("Priority", "3");
		processDescription.put("IsModify", "N");
		
		//
		docInfo.put("DocNo", "");
		docInfo.put("ReceiveNo", "");
		docInfo.put("dpdsn", "");
		docInfo.put("DocClassID", docClassID);
		docInfo.put("DocClassName", docClassName);
		docInfo.put("SaveTerm", saveTerm);
		docInfo.put("AppliedYear", DateHelper.getCurrentDay("yyyy"));
		docInfo.put("AppliedDate", appliedDate);
		docInfo.put("DocLevel", docLevel);
		docInfo.put("IsPublic", "N");
		docInfo.put("deptcode", deptCode);
		docInfo.put("deptpath", deptFullPath);
		docInfo.put("AttachFile", "");
		
		//
		formInfoExt.put("scOPub", schemeData.getJSONObject("scOPub").optString("isUse").equalsIgnoreCase("Y") ? "True" : "False" );
		formInfoExt.put("scIPub", schemeData.getJSONObject("scIPub").optString("isUse").equalsIgnoreCase("Y") ? "True" : "False");
		formInfoExt.put("scABox", schemeData.getJSONObject("scABox").getString("isUse"));
		formInfoExt.put("scRPBox", schemeData.getJSONObject("scRPBox").getString("isUse"));
		formInfoExt.put("scJFBox", schemeData.getJSONObject("scJFBox").getString("isUse"));
		formInfoExt.put("scJFBoxV", schemeData.getJSONObject("scJFBox").getString("value"));
		formInfoExt.put("scAutoReview", schemeData.getJSONObject("scAutoReview").getString("isUse"));			//TODO scAutoReview
		formInfoExt.put("IsUseDocNo", schemeData.getJSONObject("scDNum").optString("isUse").equalsIgnoreCase("Y") ? "True" : "False");
		formInfoExt.put("DocInfo", docInfo);
		formInfoExt.put("rejectedto", schemeData.getJSONObject("scRJTO").optString("isUse").equalsIgnoreCase("Y") ? "true" : "false");
		formInfoExt.put("IsLegacy", schemeData.getJSONObject("scLegacy").optString("isUse").equalsIgnoreCase("Y") ? schemeData.getJSONObject("scLegacy").getString("value") : "");
		formInfoExt.put("entcode", entcode);
		formInfoExt.put("entname", entname);
		formInfoExt.put("docnotype", schemeData.getJSONObject("scDNum").getString("value"));
		formInfoExt.put("ConsultOK", schemeData.getJSONObject("scConsultOK").optString("isUse").equalsIgnoreCase("Y") ? "true" : "false");
		formInfoExt.put("IsSubReturn", schemeData.getJSONObject("scDCooReturn").optString("isUse").equalsIgnoreCase("Y") ? "true" : "false");
		formInfoExt.put("IsDeputy", "false");
		formInfoExt.put("IsReUse", "");
		formInfoExt.put("scDocBoxRE", schemeData.getJSONObject("scDocBoxRE").getString("isUse"));
		formInfoExt.put("nCommitteeCount", "2");
		formInfoExt.put("IsReserved", "False");
		formInfoExt.put("scASSBox", schemeData.getJSONObject("scASSBox").getString("isUse"));
		formInfoExt.put("scPreDocNum", schemeData.getJSONObject("scPreDocNum").getString("isUse"));
		formInfoExt.put("scDistDocNum", schemeData.has("scDistDocNum") ? schemeData.getJSONObject("scDistDocNum").getString("isUse") : "N");
		formInfoExt.put("scBatchPub", schemeData.has("scBatchPub") ? schemeData.getJSONObject("scBatchPub").getString("isUse") : "N");
	    //문서번호발번정규식추가 2019.08.26
		formInfoExt.put("scDNumExt", schemeData.getJSONObject("scDNumExt").optString("isUse").equalsIgnoreCase("Y") ? schemeData.getJSONObject("scDNumExt").getString("value") : "false");
		formInfoExt.put("RuleItemInfo", ruleItemInfo);
		
		// JFID
		if (schemeData.getJSONObject("scChgr").optString("isUse").equalsIgnoreCase("Y")) {
			formInfoExt.put("JFID", schemeData.getJSONObject("scChgr").getString("value"));
	    } else if (schemeData.getJSONObject("scChgrEnt").optString("isUse").equalsIgnoreCase("Y")) {
	        if (!schemeData.getJSONObject("scChgrEnt").optString("value").equals("")) {
	            CoviMap chgrEntObj =schemeData.getJSONObject("scChgrEnt").getJSONObject("value");
	            if(chgrEntObj.has("ENT_"+entcode) && !chgrEntObj.getString("ENT_"+entcode).equals("")){
	            	formInfoExt.put("JFID", chgrEntObj.getString("ENT_"+entcode));
	            }
	        }
	    } else if (schemeData.getJSONObject("scChgrReg").optString("isUse").equalsIgnoreCase("Y")) {
	        if (!schemeData.getJSONObject("scChgrReg").optString("value").equals("")) {
	            String regionID = "";			//TODO
	        	CoviMap chgrRegObj =schemeData.getJSONObject("scChgrReg").getJSONObject("value");
	            if(chgrRegObj.has("REG_"+regionID) && !chgrRegObj.getString("REG_"+regionID).equals("")){
	            	formInfoExt.put("JFID", chgrRegObj.getString("REG_"+regionID));
	            }
	        }
	    }
	    else {
	    	formInfoExt.put("JFID", "");
	    }
		
		// ChargeOU
		if (schemeData.getJSONObject("scChgrOU").optString("isUse").equalsIgnoreCase("Y")) {
			formInfoExt.put("ChargeOU", schemeData.getJSONObject("scChgrOU").getString("value"));
	    } else if (schemeData.getJSONObject("scChgrOUEnt").optString("isUse").equalsIgnoreCase("Y")) {
	        if (!schemeData.getJSONObject("scChgrOUEnt").optString("value").equals("")) {
	            CoviMap chgrOUEntObj =schemeData.getJSONObject("scChgrOUEnt").getJSONObject("value");
	            int itemLeng = chgrOUEntObj.getJSONObject("ENT_"+entcode).getJSONArray("item").size();
	            StringBuilder valueStr = new StringBuilder();
	            if (itemLeng > 0) {
	            	for(int i =0; i<itemLeng; i++){
	            		if (i > 0) valueStr.append("^");
	            		valueStr.append(chgrOUEntObj.getJSONObject("ENT_"+entcode).getJSONArray("item").getJSONObject(i).getString("AN") + "@" + chgrOUEntObj.getJSONObject("ENT_"+entcode).getJSONArray("item").getJSONObject(i).getString("DN"));
	            	}
	            	formInfoExt.put("ChargeOU", valueStr.toString());
	            }
	            
	        }
	    } else if (schemeData.getJSONObject("scChgrOUReg").optString("isUse").equalsIgnoreCase("Y")
	    		&& !schemeData.getJSONObject("scChgrOUReg").optString("value").equals("")) {
    		CoviMap chgrOURegObj =schemeData.getJSONObject("scChgrOUReg").getJSONObject("value");
    		String regionID = "";			//TODO
    		int itemLeng = chgrOURegObj.getJSONObject("REG_"+regionID).getJSONArray("item").size();
    		StringBuilder valueStr = new StringBuilder();
            if (itemLeng > 0) {
            	for(int i =0; i<itemLeng; i++){
            		if (i > 0) valueStr.append("^");
            		valueStr.append(chgrOURegObj.getJSONObject("REG_"+regionID).getJSONArray("item").getJSONObject(i).getString("AN") + "@" + chgrOURegObj.getJSONObject("REG_"+regionID).getJSONArray("item").getJSONObject(i).getString("DN"));
                }
            }
        	formInfoExt.put("ChargeOU", valueStr.toString());
	    }
		
		
		// ChargePerson
		if (schemeData.getJSONObject("scChgrPerson").optString("isUse").equalsIgnoreCase("Y")) {
	        String chargePersonStr = schemeData.getJSONObject("scChgrPerson").getString("value");
	        String retChgrPerson = "";
	        
	        if (!chargePersonStr.equals("")) {
	        	CoviMap chargePersonObj = CoviMap.fromObject(chargePersonStr.split("@@")[2]);

	        	int itemLeng = chargePersonObj.getJSONArray("item").size();
	            if (itemLeng > 0) {
	            	StringBuilder buf = new StringBuilder();
	                for(int i=0; i<itemLeng; i++){
	                    if (i > 0) {
	                        buf.append("^");
	                    }
	                    buf.append(chargePersonObj.getJSONArray("item").getJSONObject(i).getString("AN"));
	                    buf.append("@");
	                    buf.append(chargePersonObj.getJSONArray("item").getJSONObject(i).getString("DN"));
	                    buf.append("@");
	                    buf.append(chargePersonObj.getJSONArray("item").getJSONObject(i).getString("GR_Code"));
	                }
	                retChgrPerson = buf.toString(); 
	                formInfoExt.put("ChargePerson", retChgrPerson);
	            }
	        }
		}
		
		formData.put("BodyContext", bodyContext);
		formData.put("InitiatorName", userName);
		formData.put("InitiatorID", userCode);
		formData.put("InitiatorUnitName", deptName);
		formData.put("InitiatorUnitID", deptCode);
		formData.put("AttachFileInfo", "");
		formData.put("AppliedDate", appliedDate);
		formData.put("IsPublic", "");
		formData.put("AppliedTerm", "");
		formData.put("ReceiveNo", "");
		formData.put("ReceiveNames", "");
		formData.put("ReceiptList", "");
		formData.put("DocClassID", docClassID);
		formData.put("EntCode", entcode);
		formData.put("EntName", entname);
		formData.put("DocSummary", "");
		formData.put("DocLinks", "");
		formData.put("DocNo", "");
		formData.put("DocClassName", docClassName);
		formData.put("DocLevel", docLevel);
		formData.put("SaveTerm", saveTerm);
		formData.put("Subject", subject);
		formData.put("RuleItemInfo", ruleItemInfo);
		
		//
		returnObj.put("processID", "");
		returnObj.put("parentprocessID", "");
		returnObj.put("taskID", "");
		returnObj.put("processDefinitionID", processDefinitionID);
		returnObj.put("subkind", "");
		returnObj.put("performerID", "");
		returnObj.put("mode", "DRAFT");
		returnObj.put("gloct", "");
		returnObj.put("dpid", deptCode);
		returnObj.put("usid", userCode);
		returnObj.put("sabun", "");
		returnObj.put("dpid_apv", deptCode);
		returnObj.put("dpdn_apv", deptName);
		returnObj.put("usdn", userName);
		returnObj.put("dpdsn", "");
		returnObj.put("FormID", formID);
		returnObj.put("FormName", formName);
		returnObj.put("FormPrefix", formPrefix);
		returnObj.put("BodyType", "HTML");
		returnObj.put("Revision", formInfoData.getString("Revision"));
		returnObj.put("FormInstID", pFormInstID);
		returnObj.put("formtempID", "");
		returnObj.put("UserCode", "");
		returnObj.put("SchemaID", schemaID);
		returnObj.put("FileName", formInfoData.getString("FormName"));
		returnObj.put("FormTempInstBoxID", "");
		returnObj.put("FormInstID_response", "");
		returnObj.put("FormInstID_spare", "");
		returnObj.put("editMode", "N");
		returnObj.put("ProcessDescription", processDescription);
		returnObj.put("ApprovalLine", approvalLine);
		returnObj.put("FormInfoExt", formInfoExt);
		returnObj.put("Priority", "3");
		returnObj.put("actionMode", "");
		returnObj.put("actionComment", "");
		returnObj.put("actionComment_Attach", "[]");
		returnObj.put("signimagetype", "");			//TODO signimage
		returnObj.put("FormData", formData);
		
		return returnObj;
	}
	
	@Override
	public String getFormSchema(String pFormInstId) throws Exception {
		return coviMapperOne.selectOne("admin.monitoring.selectFormSchema", pFormInstId);
	}
}
