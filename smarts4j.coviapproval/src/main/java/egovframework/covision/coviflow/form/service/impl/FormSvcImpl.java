package egovframework.covision.coviflow.form.service.impl;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.form.dto.FormRequest;
import egovframework.covision.coviflow.form.dto.UserInfo;
import egovframework.covision.coviflow.form.service.FormSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("formService")
public class FormSvcImpl extends EgovAbstractServiceImpl implements FormSvc{

	private Logger LOGGER = LogManager.getLogger(FormSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	
	@PostConstruct
	@Override
	public void init() throws Exception {
		// 양식별 속성 Redis Cache.
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
		CoviMap params = new CoviMap();
		CoviList list = coviMapperOne.list("form.formLoad.selectFormAll", params);
		
		CoviMap jo = new CoviMap();
		
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		if(list != null && list.size() > 0) {
			for(int i = 0; i < list.size(); i++) {
				String formID = list.getMap(i).getString("FormID");
				String formPrefix = list.getMap(i).getString("FormPrefix");
				String companyCode = list.getMap(i).getString("CompanyCode","");
				String extInfo = list.getMap(i).getString("ExtInfo");
				
				if(!"Y".equals(isSaaS)) {
					companyCode = "";
				}
				jo.put(formID, extInfo);
				jo.put(companyCode + "_" + formPrefix, extInfo); // for SaaS
			}
			instance.save("APV_FORMEXTINFO", jo.toString());
			
			LOGGER.info("Success Form ExtInfo Redis Cache.");
		}else {
			instance.save("APV_FORMEXTINFO", "{}");
		}
	}

	@Override
	public void cacheFormExtInfo(String formID, String companyCode, String formPrefix, CoviMap extInfo) throws Exception {
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String formExtInfo = instance.get("APV_FORMEXTINFO");
		if(formExtInfo == null || "".equals(formExtInfo)) {
			// Redis 초기화 상태 고려
			init();
		}else {
			formExtInfo = instance.get("APV_FORMEXTINFO");
			CoviMap jo = CoviMap.fromObject(formExtInfo);
			if(!"Y".equals(isSaaS)) {
				companyCode = "";
			}
			jo.put(formID, extInfo);
			jo.put(companyCode + "_" + formPrefix, extInfo);
			
			instance.save("APV_FORMEXTINFO", jo.toString());
		}
	}

	@Override
	public CoviMap getCachedFormExtInfo(String formID, String formPrefix) throws Exception {
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String formExtInfo = instance.get("APV_FORMEXTINFO");
		if(formExtInfo == null || "".equals(formExtInfo)) {
			// Redis 초기화 상태 고려
			init();
		}
		
		formExtInfo = instance.get("APV_FORMEXTINFO");
		CoviMap jo = CoviMap.fromObject(formExtInfo);
		if(formID != null && !"".equals(formID) && jo.containsKey(formID)) {
			return jo.getJSONObject(formID);
		} else {
			if(formPrefix != null && !"".equals(formPrefix)) {
				if(!"Y".equals(isSaaS)) {
					if(jo.containsKey("_"+formPrefix)){
						return jo.getJSONObject("_"+formPrefix);
					}
				}else{
					String companyCode = SessionHelper.getSession("DN_Code");
					String findKey = companyCode + "_" + formPrefix;
					if(jo.containsKey(findKey)){
						return jo.getJSONObject(findKey);
					}else {
						findKey = "ORGROOT_" + formPrefix;
						if(jo.containsKey(findKey)){
							return jo.getJSONObject(findKey);
						}
					}
				}
			}
			return new CoviMap();
		}
	}



	@Override
	public CoviMap selectForm(CoviMap params) throws Exception {
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
		params.put("DN_CODE", SessionHelper.getSession("DN_Code"));
		params.put("GR_CODE", SessionHelper.getSession("GR_Code"));
		params.put("isSaaS", isSaaS);
		
		CoviList list = coviMapperOne.list("form.formLoad.selectForm", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		
		return resultList;
		
	}

	@Override
	public CoviMap selectProcess(CoviMap params) throws Exception {
		CoviList list = null;
		CoviMap resultList = new CoviMap();
		String queryName = "";
		boolean hasWorkitemID = !(params.get("workitemID").equals("") || params.get("workitemID") == null);
		
		// 완료문서의 진행데이터 삭제 되었을 떄, 조회해오도록 수정함.
		if(params.containsKey("bStored") && params.optString("bStored").equalsIgnoreCase("true")){
			// Store
			if(!hasWorkitemID)
				queryName = "form.formLoad.selectOnlyProcessStore";
			else
				queryName = "form.formLoad.selectProcessStore";
		}
		else {
			if(params.get("IsArchived").equals("false")){
				// Inst
				if(!hasWorkitemID)
					queryName = "form.formLoad.selectOnlyProcess";
				else
					queryName = "form.formLoad.selectProcess";
			}
			else if(params.get("IsArchived").equals("true")){
				// Archive
				if(!hasWorkitemID)
					queryName = "form.formLoad.selectOnlyProcessArchive";
				else
					queryName = "form.formLoad.selectProcessArchive";
			}
			else{
				LOGGER.debug("IsArchived 에 대한 키값이 잘못 되었습니다.");
			}
		}
		
		if(!queryName.equals("")){
			list = coviMapperOne.list(queryName, params);
		}
		
		if(list == null || list.isEmpty()){
			queryName = "";
			resultList.put("IsArchived", "true");
			
			// Archive
			if(!hasWorkitemID)
				queryName = "form.formLoad.selectOnlyProcessArchive";
			else
				queryName = "form.formLoad.selectProcessArchive";
			
			list = coviMapperOne.list(queryName, params);
			
			if(list == null || list.isEmpty()){
				queryName = "";
				resultList.put("IsArchived", "true");
				
				// Store
				if(!hasWorkitemID)
					queryName = "form.formLoad.selectOnlyProcessStore";
				else
					queryName = "form.formLoad.selectProcessStore";
				
				list = coviMapperOne.list(queryName, params);
			
				if(list == null || list.isEmpty()){
					resultList.put("bStored", "false");
				}
				else {
					resultList.put("bStored", "true");
				}
			}
		}
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ProcessID,ProcessDescriptionID,FormInstID,State,ProcessState,ParentProcessID,UserCode,DocSubject,DeputyID,BusinessState,ProcessName,TaskID,SubKind"));
		return resultList;
	}

	@Override
	public CoviMap selectProcessDes(CoviMap params) throws Exception {
		
		CoviList list;
		CoviMap resultList = new CoviMap();
		String queryName = "";
		
		// Archive 데이터 처리 (완료)
		if(params.get("IsArchived").equals("true")){
			if(params.containsKey("bStored") && params.optString("bStored").equalsIgnoreCase("true")){
				queryName ="form.formLoad.selectProcessDesStore";
			} else {
				queryName = "form.formLoad.selectProcessDesArchive";
			}
		}else if(params.get("IsArchived").equals("false")){
			queryName = "form.formLoad.selectProcessDes";
		}else{
			LOGGER.debug("IsArchived 에 대한 키값이 잘못 되었습니다.");
		}
		
		if(!queryName.equals("")){
			list = coviMapperOne.list(queryName, params);
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2"));
		}
		
		return resultList;
	}

	@Override
	public CoviMap selectFormInstance(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.formLoad.selectFormInstance", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FormInstID,ProcessID,FormID,SchemaID,Subject,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,CompletedDate,DeletedDate,LastModifiedDate,LastModifierID,EntCode,EntName,DocNo,DocLevel,DocClassID,DocClassName,DocSummary,IsPublic,SaveTerm,AttachFileInfo,AppliedDate,AppliedTerm,ReceiveNo,ReceiveNames,ReceiptList,BodyType,BodyContext,DocLinks,EDMSDocLinks,RuleItemInfo"));
		
		return resultList;
	}

	@Override
	public CoviMap selectDomainData(CoviMap params) throws Exception {
		
		CoviList list;
		CoviMap resultList = new CoviMap();
		String queryName = "";
		
		// Archive 데이터 처리 (완료)
		if(params.get("IsArchived").equals("true")){
			queryName = "form.formLoad.selectDomainDataArchive";
		}else if(params.get("IsArchived").equals("false")){
			queryName = "form.formLoad.selectDomainData";
		}else{
			LOGGER.debug("IsArchived 에 대한 키값이 잘못 되었습니다.");
		}
		
		// 이관문서는 결재선 데이터 X 빈값JSON 결재선 세팅
		if(params.containsKey("bStored") && params.get("bStored").equals("true")){ 
			//resultList.put("list","");
			//queryName = "form.formLoad.selectDomainDataStore";
			//list = coviMapperOne.list(queryName, params);
			resultList.put("list", "[{\"DomainDataContext\":{\"steps\":{\"division\":{\"taskinfo\":{\"result\":\"\",\"datereceived\":\"\",\"datecompleted\":\"\",\"kind\":\"\",\"status\":\"\"},\"processID\":\"\",\"divisiontype\":\"\",\"name\":\"\",\"oucode\":\"\",\"step\":{\"unittype\":\"\",\"ou\":{\"code\":\"\",\"pfid\":\"\",\"person\":{\"sipaddress\":\"\",\"code\":\"\",\"taskinfo\":{\"result\":\"\",\"datereceived\":\"\",\"customattribute1\":\"\",\"datecompleted\":\"\",\"kind\":\"\",\"status\":\"\"},\"level\":\"\",\"name\":\"\",\"oucode\":\"\",\"position\":\"\",\"title\":\"\",\"ouname\":\"\"},\"name\":\"\",\"wiid\":\"\",\"widescid\":\"\",\"taskid\":\"\"},\"name\":\"\",\"routetype\":\"\"},\"processDescID\":\"\",\"ouname\":\"\"},\"datecreated\":\"\",\"status\":\"\"}}}]");
		}
		else {
			list = coviMapperOne.list(queryName, params);
			if(list.isEmpty() && queryName.equals("form.formLoad.selectDomainDataArchive")){
				queryName = "form.formLoad.selectDomainData";
				list = coviMapperOne.list(queryName, params);
			}
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DomainDataID,DomainDataName,ProcessID,DomainDataContext"));
		}
		return resultList;
	}

	@Override
	public CoviMap selectFormSchema(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.formLoad.selectFormSchema", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SchemaID,SchemaName,SchemaDesc,SchemaContext"));
		
		return resultList;
	}

	@Override
	public CoviMap selectPravateDomainData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.formLoad.selectPravateDomainData", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "PrivateDomainDataID,CustomCategory,DefaultYN,DisplayName,OwnerID,Abstract,Description,PrivateContext"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectFiles(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.formLoad.selectFile", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", FileUtil.getFileTokenArray(CoviSelectSet.coviSelectJSON(list, "FileID,StorageID,ServiceType,ObjectID,ObjectType,MessageID,SaveType,LastSeq,Seq,FilePath,FileName,SavedName,Extention,Size,RegistDate,RegisterCode,CompanyCode,StorageLastSeq,StorageFilePath,InlinePath,IsActive")));
		
		return resultList;
	}
	
	@Override
	public void confirmRead(FormRequest formRequest, UserInfo userInfo, String strReadMode, CoviMap processObj) throws Exception{
		//일반
		String sAdminYN = "N";
		
		//관리자
		if(strReadMode.equalsIgnoreCase("ADMIN")){
			sAdminYN = "Y";
		}
		
		//감사
		if(strReadMode.equalsIgnoreCase("AUDIT")){
			sAdminYN = "A";
		}
				
		if(!formRequest.getFormInstanceID().equals("") && !formRequest.getFormInstanceID().equals("0")) {
			CoviMap params = new CoviMap();
			params.put("UserID", userInfo.getUserID());
			params.put("UserName", userInfo.getUserName());
			params.put("JobTitle", userInfo.getJobTitleCode());
			params.put("JobLevel", userInfo.getJobLevelCode());
			params.put("ProcessID", formRequest.getProcessID());
			params.put("FormInstID", formRequest.getFormInstanceID());
			params.put("AdminYN", sAdminYN);
			insertDocReadHistory(params);
		}
		
		// 참조/회람 읽음 처리		
		if((strReadMode.equals("COMPLETE") || strReadMode.equals("PROCESS")) 
				&& (formRequest.getGLoct().equals("TCINFO") 
						|| (formRequest.getGLoct().equals("DEPART") && formRequest.getSubkind().equals("T006")) 
						|| (formRequest.getGLoct().equals("DEPART") 
								&& (formRequest.getSubkind().equals("T014") || formRequest.getSubkind().equals("0") || formRequest.getSubkind().equals("1") || formRequest.getSubkind().equals("C") )))){
	
			CoviMap params = new CoviMap();
			params.put("Kind", formRequest.getSubkind());
			
			if (formRequest.getGLoct().equals("P") || formRequest.getGLoct().equals("") || formRequest.getGLoct().equals("TCINFO")){
				params.put("FormInstID", formRequest.getFormInstanceID());
				params.put("ReceiptID", userInfo.getUserID());
				
				updateTCInfoDocReadHistory(params);
			}else if (formRequest.getGLoct().equals("DEPART")){
				params.put("FormInstID", formRequest.getFormInstanceID());
				params.put("ReceiptID", formRequest.getUserCode());
				params.put("UserCode", userInfo.getUserID());
				params.put("UserName", userInfo.getUserName());
				params.put("DeptCode", userInfo.getDeptID());
				params.put("DeptName", userInfo.getDeptName());
				
				if(params.get("UserCode").equals("")){
					params.put("UserCode", userInfo.getDeptID());
				}
				
				insertTCInfoDocReadHistory(params);
			}
		}
	}

	@Override
	public int insertDocReadHistory(CoviMap params) throws Exception {
		int result = 0;
		
		int cnt = (coviMapperOne.select("form.formLoad.selectDocReadHistory", params)).getInt("CNT");
		
		if(cnt == 0)
			result = coviMapperOne.insert("form.formLoad.insertDocReadHistory",params);
		
		return result;
	}
	
	@Override
	public int insertTCInfoDocReadHistory(CoviMap params) throws Exception {
		
		int result = 0;
		
		int cnt = (coviMapperOne.select("form.formLoad.selectTCInfoDocReadHistory", params)).getInt("CNT");
		if(cnt == 0)
			result = coviMapperOne.update("form.formLoad.insertTCInfoDocReadHistory",params);
		
		return result;
	}
	
	@Override
	public int updateTCInfoDocReadHistory(CoviMap params) throws Exception {
		
		int result = 0;
		
		result = coviMapperOne.update("form.formLoad.updateTCInfoDocReadHistory",params);
		
		return result;
	}

	@Override
	public void confirmReadStore(FormRequest formRequest, UserInfo userInfo) throws Exception {
		// 20210126 이관문서 참조/회람 문서 읽음처리
		if (formRequest.getGLoct().equals("DEPART") && formRequest.getSubkind().equals("C")){ 
			CoviMap params = new CoviMap();
			params.put("Kind", formRequest.getSubkind());
		
			params.put("FormInstID", formRequest.getFormInstanceID());
			params.put("ReceiptID", formRequest.getUserCode());
			params.put("UserCode", userInfo.getUserID());
			params.put("UserName", userInfo.getUserName());
			params.put("DeptCode", userInfo.getDeptID());
			params.put("DeptName", userInfo.getDeptName());
			
			if (params.get("UserCode").equals("")){
				params.put("UserCode", userInfo.getDeptID());
			}
			
			insertTCInfoDocReadHistoryStore(params);
		} else if (formRequest.getGLoct().equals("TCINFO")) {
			CoviMap params = new CoviMap();
			params.put("Kind", formRequest.getSubkind());
			params.put("FormInstID", formRequest.getFormInstanceID());
			params.put("ReceiptID", userInfo.getUserID());
			
			updateTCInfoDocReadHistoryStore(params);
		}
	}

	// 20210126 이관문서 참조/회람 문서 읽음처리 
	@Override
	public int insertTCInfoDocReadHistoryStore(CoviMap params) throws Exception {
		
		int result = 0;
		
		int cnt = (coviMapperOne.select("form.formLoad.selectTCInfoDocReadHistoryStore", params)).getInt("CNT");
		if(cnt == 0)
			result = coviMapperOne.update("form.formLoad.insertTCInfoDocReadHistoryStore",params);
		
		return result;
	}
	
	// 20210126 이관문서 참조/회람 문서 읽음처리 
	@Override
	public int updateTCInfoDocReadHistoryStore(CoviMap params) throws Exception {
		
		int result = 0;
		
		result = coviMapperOne.update("form.formLoad.updateTCInfoDocReadHistoryStore",params);
		
		return result;
	}
	
	@Override
	public String getReadMode(String strReadMode, String strBusinessState, String strSubkind, String workitemState, String processState) {
		if(SessionHelper.getSession("isAdmin").equals("Y") && strReadMode.equals("ADMIN")) {
			strReadMode = "ADMIN";
		}else{
	        switch (strBusinessState)
	        {
	            case "03_01_02": //수신부서기안대기   "Receive"
	                strReadMode = "REDRAFT";
	                break;
	            case "01_02_01": //"PersonConsult" 개인
	            case "01_04_01":
	            case "01_04_02":
	                strReadMode = "PCONSULT";
	                break;
	            case "01_03_01": //감사 개인
	                strReadMode = "AUDIT";
	                break;
	            case "01_01_02": //"RecApprove"
	                strReadMode = "RECAPPROVAL";
	                break;
	            case "03_01_03": //협조부서
	            case "03_01_04": //"SubRedraft" 합의부서기안대기
	            case "03_01_05": //감사 부서 대기
	                strReadMode = "SUBREDRAFT";
	                break;
	            case "01_01_04": //"SubApprove" 부서결재
	            case "01_02_02":
	            case "01_01_05":
	            case "01_03_02":
	            case "01_03_03":
	            case "01_02_03":
	                strReadMode = "SUBAPPROVAL";
	                break;
	            case "02_02_01":   //기안부서 반려"Reject"
	            case "02_02_02":
	            case "02_02_03":
	            case "02_02_04":
	            case "02_02_05":
	            case "02_02_06":
	            case "02_02_07":
	                strReadMode = "REJECT";
	                break;
	            case "03_01_06": //"Charge"
	                strReadMode = "CHARGE";
	                break;
	            case "01_01_01": //일반결재
	            	if (workitemState.equals("288")) {
		                strReadMode = "APPROVAL";
		             } 
	                break;
	            default:
	            	strReadMode = strReadMode.trim();
	                break;
	        }
	
	        switch (strSubkind) {
	        case "T001":
	        case "T002": //시행문변환
	        	strReadMode = "TRANS"; //변환
	        	break;
	        case "T003":
	        	strReadMode = "SIGN"; //직인
	        	break;
	        case "T018": //공람
	        case "T019": //확인
	        case "T005": //후결
	        	 if (workitemState.equals("288")) {
	                strReadMode = "APPROVAL";
	             } else {
	                strReadMode = "COMPLETE";
	             }
	        	 break;
	        case "T023":
	        	 if (workitemState.equals("288")) {
	                strReadMode = "CONSULT";
	             } else {
	                strReadMode = "COMPLETE"; //공람
	             }
	        	 break;
	    	default:
	    		if(!"REJECT".equals(strReadMode) && processState.equals("528")) {
	    			strReadMode = "COMPLETE"; // 완료문서 mode를 COMPLETE가 아닌 값으로 호출하는경우
	    		}
	    		break;
	        }
		}	
	    return strReadMode;
	}
	
	@Override
	public CoviMap getBodyData(CoviMap subtableInfo, CoviMap extInfo, String strFormInstanceID)
			throws Exception {
		CoviMap bodyData = new CoviMap();
		
		Iterator<?> keys = subtableInfo.keys();		
		if(!strFormInstanceID.isEmpty()) {
			String tableName;
			boolean isUseMultiEditYN = extInfo.optString("UseMultiEditYN").equals("Y");
			while(keys.hasNext()){
				String key = (String) keys.next();
				tableName = extInfo.getString(key);
				
				StringBuilder columns = new StringBuilder();
				columns.append("FormInstID,");
				
				CoviList subTableValues = subtableInfo.getJSONArray(key);
				for(int i=0; i<subTableValues.size(); i++){
					CoviMap subTable = subTableValues.getJSONObject(i);
					if(!subTable.isNullObject() && !subTable.isEmpty() && !subTable.optString("FieldName").equals("")){
						String columnKey = subTable.getString("FieldName");
						columns.append(columnKey + ",");
					}
				}
				columns = columns.deleteCharAt(columns.lastIndexOf(","));
				
				CoviMap params = new CoviMap();
				params.put("columns", columns.toString());
				params.put("tableName", tableName);
				params.put("formInstID", strFormInstanceID);
				
				CoviList subTableDataArr = selectSubTableData(params).getJSONArray("list");
				
				if(!subTableDataArr.isEmpty()){
					if(key.equals("MainTable")) {
						bodyData.put(key, subTableDataArr.getJSONObject(0));
					} else {
						if(isUseMultiEditYN && key.equals("SubTable1")) {						
							for(Object obj : subTableDataArr) {
								CoviMap subTableData = (CoviMap) obj;
								
								if(!subTableData.getString("MULTI_ATTACH_FILE").isEmpty()) {
									CoviMap fileInfos = CoviMap.fromObject(new String(Base64.decodeBase64(subTableData.getString("MULTI_ATTACH_FILE")),StandardCharsets.UTF_8));
									CoviList fileTokenArr = CoviList.fromObject(fileInfos.get("FileInfos"));
									
									for(Object fileObj : fileTokenArr) {
										CoviMap fileData = (CoviMap) fileObj;
										
										fileData.put("FileID", String.valueOf(fileData.get("FileID")).trim());
									}
									
									fileInfos.put("FileInfos", FileUtil.getFileTokenArray(fileTokenArr));
									
									subTableData.put("MULTI_ATTACH_FILE", fileInfos.toString());
								}
							} 
						}
						bodyData.put(key, subTableDataArr);
					}
				}
				columns.delete(0, columns.capacity());
			}
		} else {
			while(keys.hasNext()){
				String key = (String) keys.next();
				bodyData.put(key, "");
			}
		}
		return bodyData;
	}	

	@Override
	public CoviMap selectSubTableData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.subtable.selectData", params);
		CoviMap resultList = new CoviMap();
		
		String selectString = params.getString("columns").replace("`", "");
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, selectString));
		
		return resultList;
	}
	
	@Override
	public String selectUsingSignImageName(String userCode) {
		CoviMap map = coviMapperOne.selectOne("form.formLoad.selectUsingSignImage", userCode);
		String imgName = "";
		if(map != null && !map.isEmpty()) {
			String imgPath = map.getString("FilePath");
			imgName = imgPath.split("/")[imgPath.split("/").length-1];
		}
		return imgName;
	}

	@Override
	public String selectUsingSignImageId(String userCode) {
		String signImgId = coviMapperOne.selectOne("form.formLoad.selectUsingSignImageId", userCode);
		if(StringUtils.isBlank(signImgId)) signImgId = "";
		return signImgId;
	}

	@Override
	public String selectFormInstanceIsArchived(CoviMap paramID) throws Exception{
		CoviMap map = coviMapperOne.select("form.formLoad.selectFormInstanceIsArchived", paramID);
		String isArchive = "false";
		
		if(map.containsKey("isArchive"))
			isArchive = map.getString("isArchive");
		
		return isArchive;
	}

	@Override
	public String selectFormInstanceID(CoviMap params) throws Exception{
		CoviMap map = coviMapperOne.select("form.formLoad.selectFormInstanceID", params);
		String returnStr = "";
		
		// Archive
		if(map.size() <= 0){
			map = coviMapperOne.select("form.formLoad.selectFormInstanceIDArchive", params);
		}
		
		// Store
		if(map.size() <= 0) {
			map = coviMapperOne.select("form.formLoad.selectFormInstanceIDStore", params);
		}
		
		if(map.containsKey("FormInstID"))
			returnStr = map.getString("FormInstID");
		
		return returnStr;
	}

	@Override
	public boolean isPerformer(CoviMap params) {
		boolean isPerformer = false;
		CoviMap map = coviMapperOne.select("form.formLoad.selectPerformerData", params);
		
		// Archive
		if(map.isEmpty()){
			map = coviMapperOne.select("form.formLoad.selectPerformerDataArchive", params);
		}

		// Store
		if(map.isEmpty()){
			map = coviMapperOne.select("form.formLoad.selectPerformerDataStore", params);
		}
		
		// 대결
		if(map.isEmpty()){
			map = coviMapperOne.select("form.formLoad.selectPerformerDeputyData", params);
			// 대결 Archive
			if(map.isEmpty()){
				map = coviMapperOne.select("form.formLoad.selectPerformerDeputyDataArchive", params);
			}
		}
		
		if(map.containsKey("PerformerID") && !map.getString("PerformerID").isEmpty())
			isPerformer = true;
		
		return isPerformer;
	}

	@Override
	public boolean isJobFunctionManager(CoviMap params) {
		boolean isManager = false;
		
		CoviMap map = coviMapperOne.select("form.formLoad.selectJobFunctionData", params);
		
		// Archive
		if(map.isEmpty()){
			map = coviMapperOne.select("form.formLoad.selectJobFunctionDataArchive", params);
		}
		
		if(map.containsKey("PerformerID") && !map.getString("PerformerID").isEmpty())
			isManager = true;
		
		return isManager;
	}

	@Override
	public boolean isReceivedByDept(CoviMap params) {
		boolean isRecevied = false;
		CoviMap list = coviMapperOne.select("form.formLoad.selectDeptReceiveData", params);
		
		// Archive
		if(list.size() <= 0){
			list = coviMapperOne.select("form.formLoad.selectDeptReceiveDataArchive", params);
		}
		
		if(list.containsKey("PerformerID") && !list.getString("PerformerID").isEmpty())
			isRecevied = true;
		
		return isRecevied;
	}

	@Override
	public String selectFormPrefixData(CoviMap params) {
		CoviMap map = coviMapperOne.select("form.formLoad.selectFormPrefixData", params);
		String returnStr = "";
		
		if(map.containsKey("FormPrefix"))
			returnStr = map.getString("FormPrefix");
		
		return returnStr;
	}

	@Override
	public boolean isContainedInManagedBizDoc(CoviMap params){
		CoviMap map = coviMapperOne.select("form.formLoad.selectBizDocData", params);		
		return (map.getInt("CNT") > 0);
	}

	@Override
	public boolean isInTCInfo(CoviMap params){
		CoviMap map = coviMapperOne.select("form.formLoad.selectTCInfoData", params);
		// Store
		//if(map.isEmpty()){
		if(map.getInt("CNT") == 0){// 회람문서 쿼리 안타는 문제 수정
			map = coviMapperOne.select("form.formLoad.selectTCInfoDataStore", params);
		}
		
		return (map.getInt("CNT") > 0);
	}
	
	@Override
	public CoviMap selectFormAfterDomainData(CoviMap params) throws Exception{
		CoviList list = coviMapperOne.list("form.formLoad.selectFormAfterDomainData", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DomainDataContext"));
		
		return resultList;
	}
	
	// 추가 의견 조회
	@Override
	public CoviMap selectComment(CoviMap params) throws Exception{
		CoviList list = coviMapperOne.list("form.comment.select", params);
		CoviMap resultList = new CoviMap();
		
		if(params.containsKey("bStored") && params.get("bStored").equals("true")){
			list.clear();
			list = coviMapperOne.list("form.comment.selectstore", params);
		}
		CoviList commentArr = CoviSelectSet.coviSelectJSON(list, "CommentID,FormInstID,ProcessID,UserCode,UserName,InsertDate,Mode,Kind,Comment,Comment_fileinfo");
		
		for(Object obj : commentArr) {
			CoviMap commentObj = (CoviMap) obj;
			
			if(!commentObj.getString("Comment_fileinfo").isEmpty()) {
				CoviList tokenCommentArr = CoviList.fromObject(commentObj.getString("Comment_fileinfo"));
				
				for(Object tObj : tokenCommentArr) {
					CoviMap tokenCommenObj = (CoviMap)tObj;
					tokenCommenObj.put("FileID", tokenCommenObj.getString("id"));
				}
				
				commentObj.put("Comment_fileinfo", FileUtil.getFileTokenArray(tokenCommentArr));
			}
		}
		
		resultList.put("list", commentArr);
		
		return resultList;
	}

	@Override
	public CoviMap selectFormInstanceStore(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.formLoad.selectFormInstanceStore", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FormInstID,ProcessID,FormID,SchemaID,Subject,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,CompletedDate,DeletedDate,LastModifiedDate,LastModifierID,EntCode,EntName,DocNo,DocLevel,DocClassID,DocClassName,DocSummary,IsPublic,SaveTerm,AttachFileInfo,AppliedDate,AppliedTerm,ReceiveNo,ReceiveNames,ReceiptList,BodyType,BodyContext,DocLinks,RuleItemInfo,EDMSDocLinks"));
		
		return resultList;
	}
	
	@Override
	public String selectFormInstanceIsBStored(CoviMap paramID) throws Exception{
		CoviMap list = coviMapperOne.select("form.formLoad.selectFormInstanceIsBStored", paramID);
		String bstored = "false";
		
		if(list.containsKey("Bstored"))
			bstored = list.getString("Bstored");
		
		return bstored;
	}

	/*이관 파일*/
	@Override
	public CoviMap selectStoreFiles(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.formLoad.selectFileStore", params);
		CoviMap resultList = new CoviMap();		
		resultList.put("list", FileUtil.getFileTokenArray(CoviSelectSet.coviSelectJSON(list, "FileID,StorageID,ServiceType,ObjectID,ObjectType,MessageID,SaveType,LastSeq,Seq,FilePath,FileName,SavedName,Extention,Size,RegistDate,RegisterCode,CompanyCode,StorageLastSeq,StorageFilePath,InlinePath,IsActive")));
		
		return resultList;
	}
	
	 // 감사함 권한 여부 체크
	 @Override
	 public boolean hasDocAuditAuth(CoviMap params) {
		boolean hasAuth = false;
		
		try {
			CoviList list = coviMapperOne.list("form.formLoad.selectAuditDocData", params);
			String entCode = coviMapperOne.selectOne("form.formLoad.selectEntCode", params);
			Set<String>  authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "MN", "", "V");

			for(int i = 0; i < list.size(); i++){
				CoviMap map = list.getMap(i);
				String menuID = map.getString("MenuID");
				String domainCode = map.getString("DomainCode");
			
				if(!menuID.equals("") && authorizedObjectCodeSet.contains(menuID) && (domainCode.equals("ORGROOT") || domainCode.equals(entCode))) {
					hasAuth = true;
					break;
				}
			}
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return hasAuth;
	 }

	 // 이전문서 감사함 권한 여부 체크
	 @Override
	 public boolean hasStoreDocAuditAuth(CoviMap params) {
		boolean hasAuth = false;
		try {
			CoviList list = coviMapperOne.list("form.formLoad.selectAuditDocDataStore", params);
			String entCode = coviMapperOne.selectOne("form.formLoad.selectEntCodeStore", params);
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "MN", "", "V");
		
			for(int i = 0; i < list.size(); i++){
				CoviMap map = list.getMap(i);
				String menuID = map.getString("MenuID");
				String domainCode = map.getString("DomainCode");
			
				if(!menuID.equals("") && authorizedObjectCodeSet.contains(menuID) && (domainCode.equals("ORGROOT") || domainCode.equals(entCode))) {	
					hasAuth = true;
					break;
				}
		 	}
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}  
		return hasAuth;
	 }
	 
	 @Override
	 public CoviMap selectParentDept(CoviMap params) throws Exception{
		 CoviList list = coviMapperOne.list("form.formLoad.selectParentDeptData", params);
		 CoviMap resultList = new CoviMap();
		 
		 resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupCode,DisplayName,Reserved1,Reserved2"));
		 
		 return resultList;
	 }
	 
	@Override
	public boolean isLinkedDoc(CoviMap params) {
		 CoviMap list = coviMapperOne.select("form.formLoad.selectIsLinkedDocData", params);	  
		 return (list.getInt("CNT") > 0);
	}

	@Override
	public List<CoviMap> selectManageDocTarget(CoviMap params) {
		return coviMapperOne.list("form.formLoad.selectManageTarget", params);
	}

	@Override
	public int selectManageDocData(CoviMap params) {
		int completedCnt = 0;
		
		if(params.optString("bStored").equalsIgnoreCase("true")) {
			completedCnt = coviMapperOne.selectOne("form.formLoad.selectManageDocStoreDataCnt", params);
			if(completedCnt == 0) completedCnt = coviMapperOne.selectOne("form.formLoad.selectManageDocTcInfoStoreDataCnt", params);
		} else {
			completedCnt = coviMapperOne.selectOne("form.formLoad.selectManageDocDataCnt", params);
			if(completedCnt == 0) completedCnt = coviMapperOne.selectOne("form.formLoad.selectManageDocTcInfoDataCnt", params);
		}
		return completedCnt;
	}

	@Override
	public String selectPerformerDataGov(CoviMap params) throws Exception{
 		CoviMap list = coviMapperOne.select("form.formLoad.selectPerformerDataGov", params);
		String returnStr = "";
			
		if(list.containsKey("PerformerID"))
			returnStr = list.getString("PerformerID");
		
		return returnStr;
	}

	@Override
	public boolean isLinkedStoreDoc(CoviMap params) {
		 CoviMap list = coviMapperOne.select("form.formLoad.selectIsLinkedDocDataStore", params);
		 return (list.getInt("CNT") > 0);
	}

	@Override
	public boolean isLinkedExpenceDoc(CoviMap params) {
		CoviMap map = coviMapperOne.select("form.formLoad.selectIsLinkedDocExpData", params);
		return (map.getInt("CNT") > 0);
	}

	@Override
	public boolean isLinkedStoreExpenceDoc(CoviMap params) {
		 CoviMap map = coviMapperOne.select("form.formLoad.selectIsLinkedDocExpDataStore", params);	  
		 return (map.getInt("CNT") > 0);
	}
	
	@Override
	public String selectFormCompanyCode(CoviMap params) throws Exception {
		String strListQuery="form.formLoad.selectFormCompanyCode";
		if (params.optString("bStored").equals("true")) strListQuery="form.formLoad.selectStoreFormCompanyCode";

		CoviMap list = coviMapperOne.select(strListQuery, params);
		String returnStr= "";
		
		if(list.containsKey("FormCompanyCode"))
			returnStr = list.getString("FormCompanyCode");
		
		return returnStr;
	}
	
	@Override
	public String selectDeptName(String pDeptCode) throws Exception {
		String strDeptName = "";
		CoviMap param = new CoviMap();
		param.put("DeptCode", pDeptCode);
		CoviMap map = coviMapperOne.select("form.org_person.selectGroupInfo", param);
		if(map.containsKey("MULTIDISPLAYNAME") && !map.getString("MULTIDISPLAYNAME").isEmpty()) {
			strDeptName = map.getString("MULTIDISPLAYNAME");
		}		
		return strDeptName;
	}
	
	@Override
	public String selectGov24SenderInfo(String receiveid) throws Exception {
		StringBuilder strResult = new StringBuilder();
		CoviMap param = new CoviMap();
		param.put("ORGCD", receiveid);
		CoviMap map = coviMapperOne.select("service.ldap.selectGov24Sender", param);
		if(map.containsKey("ORGCD") && !map.getString("ORGCD").isEmpty()) { //DeployGovManager.js 배포처 추가처럼 데이터 가공.
			strResult.append("1");
			strResult.append(":" + map.getString("ORGCD"));
			strResult.append(":" + map.getString("CMPNYNM"));
			strResult.append(":" + map.getString("SENDERNM"));
			strResult.append(":" + map.getString("BIZNO"));
			strResult.append(":" + map.getString("ADRES"));
			strResult.append(":" + map.getString("HASSUBOU"));
			strResult.append(":X");
			strResult.append(":" + map.getString("DISPLAY_UCCHIEFTITLE"));
		}		
		return strResult.toString();
	}
	
	@Override
	public CoviMap selectgov24DocLink(String formInstId) throws Exception {
		CoviList list;
		CoviMap resultList = new CoviMap();
		
		CoviMap param = new CoviMap();
		param.put("FormInstID", formInstId);
		list = coviMapperOne.list("form.formLoad.selectgov24DocLink", param);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ProcessID,FormPrefix,FormSubject,FormInstID,BusinessData1,BusinessData2"));
		
		return resultList;
	}
	
	/* 문서24 회신여부 체크*/
	@Override
	public String selectCheckReplyDoc(String formInstId) throws Exception {
		CoviMap params = new CoviMap();
		params.put("FormInstID", formInstId);
		
		return coviMapperOne.selectOne("form.formLoad.selectCheckReplyDoc", params);
	}
	
	@Override
	public CoviMap selectCstfInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.formLoad.selectCstfInfo", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "StoredFormID,FormPrefix,FormName,FormHtmlFileID,FileName,SavedName,CompanyCode,FullPath"));
		
		return resultList;
	}
	
	@Override
	public String selectGovRecordRowSeq(String govRecordId) {
		CoviMap params = new CoviMap();
		params.put("RecordDocumentID", govRecordId);
		return coviMapperOne.selectOne("form.formLoad.selectGovRecordRowSeq", params);
	}
	
	@Override
	public int updateDocHWP(String formInstID, String bodyContext) throws Exception {
		int returnInt = 0;
		
		CoviMap formMap = new CoviMap();
		formMap.put("formInstID", formInstID);
		formMap.put("bodyContext", bodyContext);
		
		returnInt = coviMapperOne.update("user.govDoc.updateDocBodyContext", formMap);
		
		return returnInt;
	}
	
	@Override
	public CoviMap selectUserInfo(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("common.login.selectSSO", params);
		return map;
	}
	
	@Override
	public String docsTransform(CoviMap params) throws Exception {
		String returnObj = "";
		MultiValueMap<String,String> govMap = new LinkedMultiValueMap<>();
		RestTemplate restTemplate = new RestTemplate();
		CoviMap govObj = new CoviMap();
		CoviMap BodyContextObj = new CoviMap();
		BodyContextObj.setUnEscapeHtmlCharactersOnPut(false);
		CoviMap BodyContext = params.getJSONObject("BodyContext");
		CoviMap FormInstance = params.getJSONObject("FormInstanceInfo");
		CoviMap ProcessInfo = params.getJSONObject("ProcessInfo");
		
		BodyContextObj.put("tbContentElement",  BodyContext.getString("tbContentElement").replaceAll("<(br|Br)[^>]*>","").replaceAll("<(span|SPAN)[^>]","")); //본문	
		govMap.add("bodyContext", BodyContextObj.toString()); //bodyContext
		govMap.add("receiverName", BodyContext.getString("DocRecLine")); //수신처
		govMap.add("approvalContext", params.getString("ApprovalLine")); //결재선
		govMap.add("processSubject", FormInstance.getString("Subject")); //제목
		govMap.add("publicationCode", (BodyContext.getString("publicationCode") == null) ? "1NNNNNNNN" : BodyContext.getString("publicationCode")); // 1NNNNNNNN=공개 / 다른 건 비공개
		govMap.add("RELEASE_CHECK", (BodyContext.getString("RELEASE_CHECK") == null) ? "1" : BodyContext.getString("RELEASE_CHECK")); //공개: 1, 비공개: 3
 		govMap.add("publicationValue", BodyContext.getString("publicationValue"));		
		govMap.add("docNumber", (FormInstance.getString("ReceiveNo") == null || FormInstance.getString("ReceiveNo").equals("")) ? "" : FormInstance.getString("ReceiveNo")); //문서유통 문서번호
		govMap.add("pubenForceDate", (BodyContext.getString("PUBENFORCEDATE") == null || BodyContext.getString("PUBENFORCEDATE").equals("") ? "" : BodyContext.getString("PUBENFORCEDATE"))); //시행일
		govMap.add("enForceDate", (FormInstance.getString("CompletedDate") == null || FormInstance.getString("CompletedDate").equals("")) ? "" : FormInstance.getString("CompletedDate")); //접수일
		govMap.add("attachFileInfo", (FormInstance.getString("AttachFileInfo") == null || FormInstance.getString("AttachFileInfo").equals("")) ? "" : FormInstance.getString("AttachFileInfo")); //첨부파일
		govMap.add("emailAddress", (BodyContext.getString("EMAIL") == null || BodyContext.getString("EMAIL").equals("")) ? "" : BodyContext.getString("EMAIL")); //이메일
		govMap.add("initiatorID", ProcessInfo.getJSONObject("ProcessDescription").getString("ApproverCode")); //기안자 코드
		govMap.add("requestMode", ProcessInfo.getString("ApproverCode"));// 결재자 코드
		govMap.add("isEditor", "Y"); // 일반에디터 사용
		govMap.add("zipCode", (BodyContext.getString("ZIPCODE") == null || BodyContext.getString("EMAIL").equals("")) ? "" : BodyContext.getString("ZIPCODE")); //우편번호
		govMap.add("address", (BodyContext.getString("ADDRESS") == null || BodyContext.getString("ADDRESS").equals("")) ? "" : BodyContext.getString("ADDRESS")); //주소
		govMap.add("homeUrl", (BodyContext.getString("HOMEURL") == null || BodyContext.getString("HOMEURL").equals("")) ? "" : BodyContext.getString("HOMEURL")); //홈페이지
		govMap.add("fax", (BodyContext.getString("FAX") == null || BodyContext.getString("FAX").equals("")) ? "" : BodyContext.getString("FAX")); //팩스번호
		govMap.add("telephone",(BodyContext.getString("TELEPHONE") == null || BodyContext.getString("TELEPHONE").equals("")) ? "" : BodyContext.getString("TELEPHONE")); //전화번호
		govMap.add("email", (BodyContext.getString("EMAIL") == null || BodyContext.getString("EMAIL").equals("")) ? "" : BodyContext.getString("EMAIL")); //이메일
		govMap.add("seal", BodyContext.getString("STAMP")); //스탬프
		govMap.add("logo", BodyContext.getString("LOGO")); //로고
		govMap.add("symbol", BodyContext.getString("SYMBOL")); //심볼
		govMap.add("headCampaign", (BodyContext.getString("CAMPAIGN_T") == null || BodyContext.getString("CAMPAIGN_T").equals("")) ? "" : BodyContext.getString("CAMPAIGN_T")); // 상단 캠페인
		govMap.add("footCampaign", (BodyContext.getString("CAMPAIGN_F") == null || BodyContext.getString("CAMPAIGN_F").equals("")) ? "" : BodyContext.getString("CAMPAIGN_F")); // 하단 캠페인
		govMap.add("organ", BodyContext.getString("ORGAN")); // 기관명
		govMap.add("SENDERMASTER_TEXT", BodyContext.getString("SENDERMASTER_TEXT")); //기관장 명
		//수신문서
		govMap.add("regNumberCode", (BodyContext.getString("PUBREGNUMBERCODE") == null || BodyContext.getString("PUBREGNUMBERCODE").equals("") ? "" : BodyContext.getString("PUBREGNUMBERCODE"))); //시행번호(수신문서) SendReceiveSvcImpl 729 라인 참고
		govMap.add("regNumberValue", (BodyContext.getString("PUBREGNUMBERVALUE") == null || BodyContext.getString("PUBREGNUMBERVALUE").equals("") ? "" : BodyContext.getString("PUBREGNUMBERVALUE"))); //시행번호(수신문서) SendReceiveSvcImpl 729 라인 참고
		govMap.add("APPROVAL_INFO", (BodyContext.getString("APPROVAL_INFO") == null || BodyContext.getString("APPROVAL_INFO").equals("") ? "" : BodyContext.getString("APPROVAL_INFO"))); //수신문서 결재선 출력
		govMap.add("receiveDocNumber", (FormInstance.getString("DocNo") == null || FormInstance.getString("DocNo").equals("")) ? "" : FormInstance.getString("DocNo")); // 접수 문서번호
		govMap.add("receiveDocNumberDate", (FormInstance.getString("CompletedDate") == null || FormInstance.getString("CompletedDate").equals("")) ? "" : FormInstance.getString("CompletedDate")); // 접수 날짜
		
		
		String result = restTemplate.postForObject(PropertiesUtil.getGlobalProperties().getProperty("govDoc.path")+"govdocs/service/govDocsPreview.do", govMap, String.class);
		
		CoviMap  feedback =  CoviMap.fromObject(result);
		
		if( feedback.get("status").equals("INTERNAL_SERVER_ERROR") ) throw new Exception();
    	returnObj = ApvProcessSvcImpl.GetGovDocumentHTML(feedback.getString("content"));
    	
    	return returnObj;
	}
	
	public String saveFilePath(String fileId) {
		CoviMap params = new CoviMap();
		params.put("FileID", fileId);
		CoviMap fileMap = coviMapperOne.select("framework.FileUtil.selectOne", params);
				
		CoviMap storageInfo;
		String fullPath = "";
		try {
			storageInfo = FileUtil.getStorageInfo(fileMap.getString("ServiceType"),fileMap.getString("CompanyCode"));
			String backPath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + storageInfo.optString("FilePath").replace("{0}", fileMap.getString("CompanyCode"))+fileMap.optString("FilePath");
			String savedName = fileMap.getString("SavedName"); 	//서버에 저장된 파일명
			fullPath = (backPath + savedName).replaceAll("//","/");
		} catch (NullPointerException npE) {
            LOGGER.error(npE.getLocalizedMessage(), npE);
        } catch (Exception e) {
            LOGGER.error(e.getLocalizedMessage(), e);
        }  
		return fullPath;
	}
	
}
