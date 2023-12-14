package egovframework.covision.coviflow.common.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import javax.annotation.Resource;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.common.service.impl.EdmsTransferSvcImpl;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.legacy.service.ForLegacySvc;
import egovframework.baseframework.util.json.JSONSerializer;

@Service("asyncTaskEdmsTransfer")
public class AsyncTaskEdmsTransfer{
	
	private Logger LOGGER = LogManager.getLogger(AsyncTaskEdmsTransfer.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private FormSvc formSvc;
	
	@Autowired
	private ForLegacySvc forLegacySvc;
	
	@Async("executorEdmsTransfer")
	public void executeEdmsTransfer(final CoviList targetList, final String serviceUrl) throws Exception{
		CoviMap target = null;
		for(int i = 0; i < targetList.size(); i++){
			target = targetList.getJSONObject(i);
			
			boolean b1 = executeConvert(target, serviceUrl);
			boolean b2 = false;
			if(b1) {
				b2 = executeTransfer(target);
				if(b2) {
					// EDMS API 호출
					transferDocument(target);
				}
			}
		}
	}
	
	/**
	 * 본문 컨버젼
	 */
	@Transactional
	public boolean executeConvert(CoviMap target, String requestUrl) {
		try {
			StringBuilder buf = new StringBuilder();
			String processId = target.getString("ProcessId");
			String draftId = target.getString("DraftId");
			String uuid = java.util.UUID.randomUUID().toString();
			buf.append("callMode=PDF");
			buf.append("&processID=" + processId);
			buf.append("&logonId=" + draftId);
			buf.append("&UUID=" + uuid);
			
			// 사용자 회사 찾기.
			CoviMap logonUserInfo = forLegacySvc.selectLogonID(draftId);// by UserCode
			String legacyLogonId = logonUserInfo.getString("LogonID");
			
			CoviMap findUserList = forLegacySvc.checkAuthetication("SSO", legacyLogonId, "", "");
			String status = findUserList.optString("status");
			if (!status.equals("OK")) {
				throw new Exception("User Not Found.!");
			}
			CoviMap account = (CoviMap) findUserList.get("account");
			String userDomainID = account.optString("DN_ID");
			
			String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
			if("Y".equals(isSaaS)) {
				requestUrl = RedisDataUtil.getBaseConfig("PCGWServerURL", userDomainID);
				if(StringUtils.isEmpty(requestUrl)) {
					requestUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
				}
			}
			String baseHref = requestUrl;//ex. "http://localhost:8080";
			String url = baseHref + "/approval/pdfTransferView.do?" + buf.toString();
			
			// 기초설정에 별도 URL 이 셋팅되어있다면 해당 URL 을 사용한다.
			String approvalDocRenderURL = RedisDataUtil.getBaseConfig("ApprovalDocRenderURL");
			if(StringUtil.isNotNull(approvalDocRenderURL)) {
				url = approvalDocRenderURL + "?" + buf.toString();
				if(!url.startsWith("http")) {
					url = requestUrl + url;
				}
			}

			Map<String, String> paramMap = new HashMap<>();
			paramMap.put("url", url);
			target.put("UUID", uuid);
			
			// 2. Convert URL(Html) to PDF using wkhtmltopdf (include javascript)
			CoviMap htmlResult = ChromeRenderManager.getInstance().renderURLOnChrome(url);
			if("FAIL".equals(htmlResult.optString("status"))) {
				throw new UnsupportedOperationException(htmlResult.optString("messaage"));
			}
			
			paramMap.put("txtHtml", htmlResult.optString("rtnHtml"));
			CoviMap pdfResult = ChromeRenderManager.getInstance().createPdf(paramMap);
			String saveFileName = pdfResult.optString("saveFileName");
			String savePath = pdfResult.optString("savePath");

			target.put("DocBody", savePath + saveFileName);
			target.put("EndFlag", EdmsTransferSvcImpl.STATUS_PDF_COMPLETE);//PDF Convert Complete
			
			// Complete PDF Convert.
			coviMapperOne.update("form.edmstransfer.updateDocBody", target);
			return true;
		}catch(IOException ioE) {
			LOGGER.error(ioE.getLocalizedMessage(), ioE);
			target.put("EndFlag", EdmsTransferSvcImpl.STATUS_ERROR);//Error
			target.put("ErrMessage", ioE.getLocalizedMessage());
			coviMapperOne.update("form.edmstransfer.updateFlag", target);
			return false;
		}catch(NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			target.put("EndFlag", EdmsTransferSvcImpl.STATUS_ERROR);//Error
			target.put("ErrMessage", npE.getLocalizedMessage());
			coviMapperOne.update("form.edmstransfer.updateFlag", target);
			return false;
		}catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			target.put("EndFlag", EdmsTransferSvcImpl.STATUS_ERROR);//Error
			target.put("ErrMessage", e.getLocalizedMessage());
			coviMapperOne.update("form.edmstransfer.updateFlag", target);
			return false;
		}
	}

	/**
	 * 본문외 정보 조회하여 갱신 (첨부파일, 결재선 등)
	 */
	@Transactional
	public boolean executeTransfer(CoviMap target) throws Exception{
		try {
			String processId = target.getString("ProcessId");
			
			// 프로세스 아이디로 결재자 정보, 첨부파일, 결재선 정보 조회.
			CoviMap paramsProcess = new CoviMap();
	    	paramsProcess.put("processID", processId);
	    	paramsProcess.put("workitemID", "");
	    	paramsProcess.put("IsArchived", "false");
	    	
	    	CoviMap resultObj = formSvc.selectProcess(paramsProcess);
	    	if(!resultObj.has("list") || resultObj.getJSONArray("list").isEmpty()){
	    		throw new NoSuchElementException("Select No DATA by processId["+ processId +"]");
	    	}
	    	CoviMap processObj = (CoviMap)resultObj.getJSONArray("list").get(0);
	    	String formInstanceId = processObj.getString("FormInstID");
	
	    	// 첨부파일 목록 구하기. JSON Base64 encoded.
			CoviMap params = new CoviMap();
			params.put("formInstID", formInstanceId);
			
			CoviMap formInstance = (CoviMap)(formSvc.selectFormInstance(params)).getJSONArray("list").get(0);
			params.put("DocAttach", formInstance.get("AttachFileInfo"));
			params.put("DocNo", formInstance.get("DocNo"));
			params.put("DocTitle", formInstance.get("Subject"));
			params.put("DraftName", formInstance.get("InitiatorName"));
			params.put("DraftDeptId", formInstance.get("InitiatorUnitID"));
			params.put("DraftDeptName", formInstance.get("InitiatorUnitName"));
			params.put("DocClass", formInstance.get("DocClassID"));
			params.put("DraftDate", formInstance.optString("InitiatedDate").substring(0, 19));
			params.put("EndDate", formInstance.optString("CompletedDate").substring(0, 19));

			// 결재선 정보
			params.put("IsArchived", "false");
			params.put("processID", processId);
			params.put("FlagDate", target.getString("FlagDate"));
			params.put("DocId", target.getString("DocId"));
	    	CoviMap domainData = formSvc.selectDomainData(params);
	    	CoviMap domainContext = (CoviMap)domainData.getJSONArray("list").get(0);
	    	params.put("ApvLine", new String(Base64.encodeBase64(domainContext.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8));
	    	
	    	// 상태정보.
	    	params.put("EndFlag", EdmsTransferSvcImpl.STATUS_COMPLETE);//성공
	    	params.put("ErrMessage", "");
			
			coviMapperOne.update("form.edmstransfer.updateDocInfo", params);
			return true;
		}catch(IOException ioE) {
			LOGGER.error(ioE.getLocalizedMessage(), ioE);
			target.put("EndFlag", EdmsTransferSvcImpl.STATUS_ERROR);//Error
			target.put("ErrMessage", ioE.getLocalizedMessage());
			coviMapperOne.update("form.edmstransfer.updateFlag", target);
			return false;
		}catch(NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			target.put("EndFlag", EdmsTransferSvcImpl.STATUS_ERROR);//Error
			target.put("ErrMessage", npE.getLocalizedMessage());
			coviMapperOne.update("form.edmstransfer.updateFlag", target);
			return false;
		}catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			target.put("EndFlag", EdmsTransferSvcImpl.STATUS_ERROR);//Error
			target.put("ErrMessage", e.getLocalizedMessage());
			coviMapperOne.update("form.edmstransfer.updateFlag", target);
			return false;
		}
	}
	
	/**
	 * Call Groupware EDMS API 
	 * @param target
	 */
	private void transferDocument(CoviMap target){
		try{
			String docId = target.getString("DocId");
			CoviMap params = new CoviMap();
			CoviMap jsonParam = new CoviMap();
			
			params.put("DocID", docId);
			CoviMap resultMap = coviMapperOne.select("form.edmstransfer.selectDocInfo", params);
			
			jsonParam.put("subject", resultMap.getString("DocTitle"));
			jsonParam.put("registDept", resultMap.getString("DraftDeptID"));
			jsonParam.put("groupCode", resultMap.getString("DraftDeptID"));
			jsonParam.put("ownerCode", resultMap.getString("DraftID"));
			jsonParam.put("userCode", resultMap.getString("DraftID"));
			jsonParam.put("folderID", resultMap.getString("DocClass"));
			jsonParam.put("number", resultMap.getString("DocNo"));
			jsonParam.put("pdfPath", resultMap.getString("DocBody"));
			
			
			// EDMS 등록시간은 결재완료일로 셋팅한다. (재처리시에도 동일하게 입력)
			Object endDateObj = resultMap.get("EndDate");
			String registDate = "";
			if(endDateObj instanceof java.sql.Date) {
				java.sql.Date d = (java.sql.Date)endDateObj;
				SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				// forminstance의 CompletedDate 값을 그대로 가져오므로 변환 불필요
				//if(RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) sdf.setTimeZone(TimeZone.getTimeZone("GMT")); 
				registDate = sdf.format(d);
			}
			if(endDateObj instanceof java.sql.Timestamp) {
				java.sql.Timestamp d = (java.sql.Timestamp)endDateObj;
				SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				// forminstance의 CompletedDate 값을 그대로 가져오므로 변환 불필요
				//if(RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) sdf.setTimeZone(TimeZone.getTimeZone("GMT"));	
				registDate = sdf.format(d);
			}
			jsonParam.put("registDate", registDate);
			
			// 권한셋팅. Request, Draft 프로세스에 따라 수신부서별, 전체 결재선 권한으로 분리하여 처리함.
			String processId = resultMap.getString("ProcessID");
			// 프로세스 아이디로 결재자 정보, 첨부파일, 결재선 정보 조회.
			CoviMap paramsProcess = new CoviMap();
	    	paramsProcess.put("processID", processId);
	    	paramsProcess.put("workitemID", "");
	    	paramsProcess.put("IsArchived", "false");
	    	
	    	CoviMap resultObj = formSvc.selectProcess(paramsProcess);
	    	if(!resultObj.has("list") || resultObj.getJSONArray("list").isEmpty()){
	    		throw new NoSuchElementException("Select No DATA by processId["+ processId +"]");
	    	}
	    	CoviMap processObj = (CoviMap)resultObj.getJSONArray("list").get(0);
	    	
	    	String processName = "";
	    	String parentProcessID = processObj.optString("ParentProcessID");
	    	if("".equals(parentProcessID) || "0".equals(parentProcessID)) {
	    		// Request, Draft 인 경우 해당  Process 정보 사용
	    		processName = processObj.optString("ProcessName");
	    	}else {
	    		// Basic 프로세스인 경우
	    		paramsProcess.put("processID", parentProcessID);
	    		resultObj = formSvc.selectProcess(paramsProcess);
	    		CoviMap parentProcessObj = (CoviMap)resultObj.getJSONArray("list").get(0);
	    		processName = parentProcessObj.optString("ProcessName"); // Request, Basic, Draft
	    	}
	    	
	    	// 기밀문서여부 판단.
	    	CoviMap paramsProcessDes = new CoviMap();
        	paramsProcessDes.put("processDescID", processObj.getString("ProcessDescriptionID"));
        	paramsProcessDes.put("IsArchived", "false");
        	CoviMap processDesObj = new CoviMap();
        	processDesObj = (((CoviList)(formSvc.selectProcessDes(paramsProcessDes)).get("list")).getJSONObject(0));
        	String isSecureDoc = processDesObj.getString("IsSecureDoc");
        	jsonParam.put("isSecureDoc", isSecureDoc); // Y/N
        	
			CoviList msgAuthArr = new CoviList();
			List<String> msgAuthDupCheck = new ArrayList<>();
			
			String lang = SessionHelper.getSession("lang");
			CoviMap apvLine = CoviMap.fromObject(JSONSerializer.toJSON(new String(Base64.decodeBase64(resultMap.getString("ApvLine")),StandardCharsets.UTF_8)));
			CoviMap root = apvLine.getJSONObject("DomainDataContext").getJSONObject("steps");
			
			Object divisionObj = root.get("division");
			CoviList divisions = new CoviList();
			if(divisionObj instanceof CoviMap){
				divisions.add(divisionObj);
			} else {
				divisions = (CoviList)divisionObj;
			}
			for(int i = 0; i < divisions.size(); i++){
				CoviMap division = divisions.getJSONObject(i);
				Object stepObj = division.get("step");
				
				
				// 배포프로세스의 경우 이관할 문서의 ProcessID 기준의 결재선 사용자만 권한등록한다.
				String divProcessID = division.optString("processID");
				if("Draft".equals(processName) && !divProcessID.equals(processId)) {
					continue;
				}
				
				CoviList steps = new CoviList();
				if(stepObj instanceof CoviMap){
					steps.add(stepObj);
				} else {
					steps = (CoviList)stepObj;
				}
				
				for(int k = 0; k < steps.size(); k++){
					CoviMap stepJson = steps.getJSONObject(k);
					Object ou = stepJson.get("ou");

					
					CoviList ouArr = new CoviList();
					if(ou instanceof CoviMap){
						ouArr.add(ou);
					} else {
						ouArr = (CoviList)ou;
					}
					
					
					for(int y = 0; y < ouArr.size(); y++){
						Object personObj = ouArr.getJSONObject(y).get("person");
						CoviList personArr = new CoviList();
						if(personObj instanceof CoviMap){
							personArr.add(personObj);
						} else {
							personArr = (CoviList)personObj;
						}	
					
						for(int r = 0; r < personArr.size(); r++){
							CoviMap personInfo = personArr.getJSONObject(r);
							
							CoviMap authParams = new CoviMap();
							
							authParams.put("TargetCode", personInfo.getString("code"));
							authParams.put("DisplayName", DicHelper.getDicInfo(personInfo.getString("name"), lang));
							authParams.put("AclList", "____ER");
							
							if(stepJson.optString("unittype").equals("person")){
								authParams.put("TargetType", "UR");
							}else{
								authParams.put("TargetType", "GR");
							}
							
							authParams.put("IsSubInclude", "Y");
							authParams.put("InheritedObjectID", "0");
							
							String authCheckStr = authParams.getString("TargetCode") + "$" + authParams.getString("TargetType");
						
							// 기안자 (발신, 수신부서)
							if(k == 0 && y == 0 && r == 0){
								// 신청프로세스 : 첫번째 division 기안자
								// 품의프로세스 : 현재 조회중인 division 기안자
								if("Draft".equals(processName) || ( !"Draft".equals(processName) && i == 0 )) {
									authParams.put("AclList", "SCDMER");
									
									String registCode = personInfo.getString("code");
									String deptID = personInfo.getString("oucode");
									jsonParam.put("registDept", deptID);
									jsonParam.put("groupCode", deptID);
									jsonParam.put("ownerCode", registCode);
									jsonParam.put("userCode", registCode);
								}
							}
							
							if(!msgAuthDupCheck.contains(authCheckStr)) {
								msgAuthArr.add(authParams);
							}
							msgAuthDupCheck.add(authCheckStr);
						}
					}
				}
				
				jsonParam.put("messageAuth", msgAuthArr);
			}
			
			// 첨부파일
			if(!resultMap.optString("DocAttach").equals("")){
				CoviMap docAttach = CoviMap.fromObject(JSONSerializer.toJSON(new String(Base64.decodeBase64(resultMap.getString("DocAttach")), StandardCharsets.UTF_8)));
				Object attObj = docAttach.get("FileInfos");
				
				if(attObj instanceof CoviMap){
					CoviMap fileInfo = (CoviMap) attObj;
					CoviList fileInfoList = new CoviList();
					
					fileInfoList.add(fileInfo);
					jsonParam.put("fileInfoList", fileInfoList);
				}else if(attObj instanceof CoviList){
					CoviList fileInfoList = (CoviList) attObj;
					
					jsonParam.put("fileInfoList", fileInfoList);
				}
			}else{
				jsonParam.put("fileInfoList", "");
			}
			
			jsonParam.put("DNID", target.getString("DNID"));
			jsonParam.put("DN_Code", target.getString("DN_Code"));
			String url = RedisDataUtil.getBaseConfig("DocTransferURL");
			
			RequestHelper.sendUrl(url, "application/json", "POST", jsonParam);
			
			target.put("EndFlag", EdmsTransferSvcImpl.STATUS_TRANSFER_COMPLETE);
			coviMapperOne.update("form.edmstransfer.updateFlag", target);
		}catch(IOException ioE){
			LOGGER.error(ioE.getLocalizedMessage(), ioE);
			target.put("EndFlag", EdmsTransferSvcImpl.STATUS_ERROR);//Error
			target.put("ErrMessage", "[Method:transferDocument]" + ioE.getLocalizedMessage());
			coviMapperOne.update("form.edmstransfer.updateFlag", target);
		}catch(NullPointerException npE){
			LOGGER.error(npE.getLocalizedMessage(), npE);
			target.put("EndFlag", EdmsTransferSvcImpl.STATUS_ERROR);//Error
			target.put("ErrMessage", "[Method:transferDocument]" + npE.getLocalizedMessage());
			coviMapperOne.update("form.edmstransfer.updateFlag", target);
		}catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			target.put("EndFlag", EdmsTransferSvcImpl.STATUS_ERROR);//Error
			target.put("ErrMessage", "[Method:transferDocument]" + e.getLocalizedMessage());
			coviMapperOne.update("form.edmstransfer.updateFlag", target);
		}
	}
	
	public static class ReadStream implements Runnable {
		private static final Object LOCK = new Object();
		InputStream is;
		Thread thread;
		
		Logger LOGGER = LogManager.getLogger(this.getClass());
				
		public ReadStream(InputStream is) {
			this.is = is;
		}

		public void start() {
			thread = new Thread(this);
			thread.start();
		}
		
		@Override
		public void run() {
			synchronized (LOCK) {
				try (
						InputStreamReader isr = new InputStreamReader(is, StandardCharsets.UTF_8);
						BufferedReader br = new BufferedReader(isr);
					){
						while(true) {
							String s = br.readLine();
							if (s == null) break;
						}
					} catch (IOException ioE) {
						LOGGER.error(ioE.getLocalizedMessage(), ioE);
					} catch (Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					} finally {
						try {
							if(is != null) is.close();
						} catch (IOException e) {
							LOGGER.error(e.getLocalizedMessage(), e);
						}
					}
			}
		}
	}
}