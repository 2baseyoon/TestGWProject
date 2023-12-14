package egovframework.covision.coviflow.user.service.impl;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.JspWriter;




import org.apache.commons.codec.binary.Base64;
import org.apache.commons.fileupload.disk.DiskFileItem;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.commons.CommonsMultipartFile;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.common.util.ChromeRenderManager;
import egovframework.covision.coviflow.common.util.ComUtils;
import egovframework.covision.coviflow.common.util.RequestHelper;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.user.service.ApprovalListSvc;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("approvalListService")
@Component("approvalListService")
public class ApprovalListSvcImpl extends EgovAbstractServiceImpl implements ApprovalListSvc{
	private Logger LOGGER = LogManager.getLogger(ApprovalListSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private FormSvc formSvc;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Override
	//개인결재함, 부서결재함 공통 그룹별 목록 데이터 조회
	public CoviMap selectApprovalGroupList(CoviMap params) throws Exception {
		//
		CoviMap 	resultList 	= new CoviMap();
		CoviList 	list 		= null;
		if(params.optString("mode").equalsIgnoreCase("PREAPPROVAL")){ // 예고함
			list = coviMapperOne.list("user.approvalList.selectPreApprovalGroupList", params);
		}
		else if(params.optString("mode").equalsIgnoreCase("APPROVAL")){ // 미결함
			list = coviMapperOne.list("user.approvalList.selectApprovalGroupList", params);
		}
		else if(params.optString("mode").equalsIgnoreCase("PROCESS")){ // 진행함
			list = coviMapperOne.list("user.approvalList.selectProcessGroupList", params);
		}
		else if(params.optString("mode").equalsIgnoreCase("COMPLETE")){ // 완료함
			if(params.optString("submode").equalsIgnoreCase("ADMIN")){ // 20210126 이관함 > 관리자문서함
				list = coviMapperOne.list("user.approvalList.selectCompleteGroupListStoreAdmin", params);
			} else {
				if("covi_approval4j_store".equalsIgnoreCase(params.getString("DBName"))) {
					list = coviMapperOne.list("user.approvalList.selectStoreCompleteGroupList", params);
				}else{
					list = coviMapperOne.list("user.approvalList.selectCompleteGroupList", params);
				}
			}
		}
		else if(params.optString("mode").equalsIgnoreCase("REJECT")){ // 반려함
			if("covi_approval4j_store".equalsIgnoreCase(params.getString("DBName"))) { 
				list = coviMapperOne.list("user.approvalList.selectStoreRejectGroupList", params);
			}else{
				list = coviMapperOne.list("user.approvalList.selectRejectGroupList", params);
			}
		}
		else if(params.optString("mode").equalsIgnoreCase("TEMPSAVE")){ // 임시함
			list = coviMapperOne.list("user.approvalList.selectTempSaveGroupList", params);
		}
		else if(params.optString("mode").equalsIgnoreCase("RECEXHIBIT")){ // 수신공람함
			list = coviMapperOne.list("user.approvalList.selectReceiveExhibitGroupList", params);
		}
		else{ // 참조/회람함
			if("covi_approval4j_store".equalsIgnoreCase(params.getString("DBName"))) {
				list = coviMapperOne.list("user.approvalList.selectStoreTCInfoGroupList", params);
			}else {
				list = coviMapperOne.list("user.approvalList.selectTCInfoGroupList", params);
			}
		}
		resultList.put("list", ComUtils.coviSelectJSONForApprovalGroupList(params.getString("searchGroupType"), params.getString("mode"), list, "fieldID,fieldCnt,fieldName"));
		
		return resultList;
	}

	// 개인결재함, 부서결재함 공통 엑셀 데이터 조회
	public CoviMap selectExcelData(CoviMap params, String queryID, String headerKey) throws Exception {
		CoviList list = coviMapperOne.list("user.approvalList."+queryID, params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, headerKey));

		return resultList;
	}

	@Override
	//개인함 함별 전체 개수 조회
	public int selectUserBoxListCnt(CoviMap params) throws Exception {
		int cnt = 0; 
		String strCntQuery = "";
		switch (params.getString("listGubun")) {
			case "U_PreApproval":  
				strCntQuery = "user.approvalList.selectPreApprovalListCnt";
				break;
			case "U_Complete":  
				strCntQuery = "user.approvalList.selectCompleteListCnt";
				break;
			case "U_Reject":  
				strCntQuery = "user.approvalList.selectRejectListCnt";
				break;
			case "U_TempSave":  
				strCntQuery = "user.approvalList.selectTempSaveListCnt";
				break;
			default:
		}
		cnt =  (int) coviMapperOne.getNumber(strCntQuery, params);
		
		return cnt;
	}
	
	@Override
	//미결함 전체 개수 조회
	public int selectApprovalCnt(CoviMap params) throws Exception {
		int cnt = 0; 
		cnt =  (int) coviMapperOne.getNumber("user.approvalList.selectApprovalListCnt", params);
		
		return cnt;
	}

	@Override
	//진행함 전체 개수 조회
	public int selectProcessCnt(CoviMap params) throws Exception {
		int cnt = 0; 
		cnt =  (int) coviMapperOne.getNumber("user.approvalList.selectProcessListCnt", params);
		
		return cnt;
	}
	
	@Override
	//개인함 목록 데이터 조회
	public CoviMap selectApprovalList(CoviMap params) throws Exception {
		//
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList 	list = null;
		int cnt = 0;
		
		String strCountQuery = "";
		String strListQuery = "";
		String strListCol = "";
		if(params.optString("mode").equalsIgnoreCase("PREAPPROVAL")){ // 예고함
			strCountQuery = "user.approvalList.selectPreApprovalListCnt";
			strListQuery = "user.approvalList.selectPreApprovalList";
			strListCol = "ProcessID,WorkItemID,PerformerID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,Created,FormSubKind,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("APPROVAL")){ // 미결함
			strCountQuery = "user.approvalList.selectApprovalListCnt";
			strListQuery = "user.approvalList.selectApprovalList";
			strListCol = "ProcessID,ParentProcessID,WorkItemID,PerformerID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,Created,FormSubKind,TaskID,ReadDate,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,ProcessName,SchemaContext,DomainDataContext";
		}
		else if(params.optString("mode").equalsIgnoreCase("PROCESS")){ // 진행함
			strCountQuery = "user.approvalList.selectProcessListCnt";
			strListQuery = "user.approvalList.selectProcessList";
			strListCol = "ProcessID,WorkItemID,PerformerID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,StartDate,Finished,FormSubKind,TaskID,ReadDate,DomainDataContext,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("COMPLETE")){ // 완료함
			if(params.containsKey("DBName") && params.optString("DBName").equalsIgnoreCase("COVI_APPROVAL4J_STORE")) {
				if(params.optString("submode").equalsIgnoreCase("ADMIN")){ // 20210126 이관함 > 관리자문서함
					strCountQuery = "user.approvalList.selectCompleteListCntStoreAdmin";
					strListQuery = "user.approvalList.selectCompleteListStoreAdmin";
				}else {
					strCountQuery = "user.approvalList.selectStoreCompleteListCnt";
					strListQuery = "user.approvalList.selectStoreCompleteList";
				}
			} else {
				strCountQuery = "user.approvalList.selectCompleteListCnt";
				strListQuery = "user.approvalList.selectCompleteList";
			}
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,EndDate,FormSubKind,TaskID,ExtInfo,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("REJECT")){ // 반려함
			if(params.containsKey("DBName") && params.optString("DBName").equalsIgnoreCase("COVI_APPROVAL4J_STORE")) {
				strCountQuery = "user.approvalList.selectStoreRejectListCnt";
				strListQuery = "user.approvalList.selectStoreRejectList";
			} else {
				strCountQuery = "user.approvalList.selectRejectListCnt";
				strListQuery = "user.approvalList.selectRejectList";
			}
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionArchiveID,FormInstID,FormID,SchemaID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,EndDate,FormSubKind,TaskID,ExtInfo,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("TEMPSAVE")){ // 임시함
			strCountQuery = "user.approvalList.selectTempSaveListCnt";
			strListQuery = "user.approvalList.selectTempSaveList";
			strListCol = "FormTempInstBoxID,FormInstID,FormID,SchemaID,FormInstTableName,UserCode,FormPrefix,CreatedDate,SubKind,Subject,Kind,FormName,FormSubject";
		}
		else if(params.optString("mode").equalsIgnoreCase("TOTALPROCESS")){ // 통합진행함
			strCountQuery = "user.approvalList.selectTotalProcessListCnt";
			strListQuery = "user.approvalList.selectTotalProcessList";
			strListCol = "ProcessID,WorkItemID,PerformerID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,StartDate,Finished,ReadDate,FormSubKind,TaskID,DomainDataContext,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,WIState,Mode,ApprovalPassword";
		}
		else if(params.optString("mode").equalsIgnoreCase("RECEXHIBIT")){ // 수신공람함
			if(params.containsKey("DBName") && params.optString("DBName").equalsIgnoreCase("COVI_APPROVAL4J_STORE")) {
				strCountQuery = "user.approvalList.selectStoreReceiveExhibitListCnt";
				strListQuery = "user.approvalList.selectStoreReceiveExhibitList";
			} else {
				strCountQuery = "user.approvalList.selectReceiveExhibitListCnt";
				strListQuery = "user.approvalList.selectReceiveExhibitList";
			}			
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,EndDate,FormSubKind,TaskID,ExtInfo,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else{ // 참조/회람함
			if(params.containsKey("DBName") && params.optString("DBName").equalsIgnoreCase("COVI_APPROVAL4J_STORE")) {
				strCountQuery = "user.approvalList.selectStoreTCInfoListCnt";
				strListQuery = "user.approvalList.selectStoreTCInfoList";
			} else {
				strCountQuery = "user.approvalList.selectTCInfoListCnt";
				strListQuery = "user.approvalList.selectTCInfoList";
			}			
			strListCol = "CirculationBoxID,ProcessID,CirculationBoxDescriptionID,FormInstID,FormPrefix,ReceiptID,ReceiptType,ReceiptName,ReceiptDate,Kind,State,ReadDate,SenderID,SenderName,Subject,Comment,DataState,RegID,RegDate,ModID,ModDate,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,FormSubKind,SubKind,ExtInfo,DocNo,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,TaskID";
		}
		
		cnt = (int) coviMapperOne.getNumber(strCountQuery, params);
		
		page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list = coviMapperOne.list(strListQuery, params);
		
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, strListCol));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectHomeApprovalList(CoviMap params) throws Exception {
		//
		CoviMap resultList = new CoviMap();
		CoviList 	list = null;
		
		String listType = params.optString("listType");
		if("APPROVAL".equals(listType)) {
			list = coviMapperOne.list("user.approvalList.selectHomeApprovalList", params);
			resultList.put("approval", ComUtils.coviSelectJSONForApprovalList("", list, "ProcessID,WorkItemID,PerformerID,FormInstID,ProcessDescriptionID,FormSubject,FormPrefix,FormName,InitiatorID,InitiatorName,InitiatorUnitName,UserCode,UserName,SubKind,FormSubKind,Created,TaskID,PhotoPath,DomainDataContext,SchemaContext,BusinessData1,BusinessData2,ProcessName,FormID"));
		}else if("REF".equals(listType)) {
			list = coviMapperOne.list("user.approvalList.selectHomeReferenceList", params);
			resultList.put("references", ComUtils.coviSelectJSONForApprovalList("", list, "CirculationBoxID,ProcessID,CirculationBoxDescriptionID,FormInstID,FormPrefix,ReceiptID,ReceiptType,ReceiptName,ReceiptDate,Kind,State,SenderID,SenderName,Subject,Comment,DataState,RegID,RegDate,ModID,ModDate,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,FormSubKind,SubKind,ExtInfo,DocNo,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,TaskID"));
		}else if("CIRCULAR".equals(listType)) {
			list = coviMapperOne.list("user.approvalList.selectHomeCircularList", params);
			resultList.put("circular", ComUtils.coviSelectJSONForApprovalList("", list, "CirculationBoxID,ProcessID,CirculationBoxDescriptionID,FormInstID,FormPrefix,ReceiptID,ReceiptType,ReceiptName,ReceiptDate,Kind,State,SenderID,SenderName,Subject,Comment,DataState,RegID,RegDate,ModID,ModDate,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,FormSubKind,SubKind,ExtInfo,DocNo,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,TaskID"));
		}
		
		return resultList;
	}
	
	@Override
	public CoviMap selectHomeApprovalListCnt(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		resultList = coviMapperOne.select("user.approvalList.selectHomeApprovalListCnt", params);
		return resultList;
	}
	
	@Override
	public CoviMap getHomeApprovalDelayCnt(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		resultList = coviMapperOne.select("user.approvalList.getHomeApprovalDelayCnt", params);
		return resultList;
	}

	@Override
	public int delete(CoviMap params) throws Exception {
		int cnt = 0;

		cnt = coviMapperOne.delete("user.approvalList.deleteFormsTempInstBox", params);
		cnt = coviMapperOne.delete("user.approvalList.deleteFormInstance", params);
		cnt = coviMapperOne.delete("user.approvalList.deletePrivateDomainData", params);

		return cnt;
	}

	@Override
	public int update(CoviMap params) throws Exception {
		return coviMapperOne.update("user.approvalList.updateWorkitemArchive", params);
	}

	@Override
	public int selectApprovalNotDocReadCnt(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.approvalList.selectApprovalNotDocReadCnt", params);
	}

	@Override
	public int selectProcessNotDocReadCnt(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.approvalList.selectProcessNotDocReadCnt", params);
	}

	@Override
	public int selectTCInfoNotDocReadCnt(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.approvalList.selectTCInfoNotDocReadCnt", params);
	}
	
	@Override
	public int selectApprovalTCInfoSingleDocRead(CoviMap params)throws Exception {
		return (int) coviMapperOne.getNumber("user.approvalList.selectApprovalTCInfoSingleDocRead", params);
	}

	@Override
	public int insertDocReadHistory(CoviMap params) throws Exception {
		int result = 0;
		
		ArrayList<CoviMap> paramList = (ArrayList<CoviMap>) params.get("paramList");
		for (CoviMap param : paramList) {
			int cnt = (coviMapperOne.select("form.formLoad.selectDocReadHistory", param)).getInt("CNT");
			if (cnt == 0) {
				result += coviMapperOne.insert("form.formLoad.insertDocReadHistory",param);
			}
		}
		
		return result;
	}
	
	@Override
	public int updateTCInfoDocReadHistory(CoviMap params) throws Exception {
		int result = 0;
		
		ArrayList<CoviMap> paramList = (ArrayList<CoviMap>) params.get("paramList");
		for (CoviMap param : paramList) {
			result = coviMapperOne.update("form.formLoad.updateTCInfoDocReadHistory",param);
		}
		
		return result;
	}

	@Override
	public CoviList selectProfileImagePath(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.approvalList.selectProfileImagePath", params);
		return CoviSelectSet.coviSelectJSON(list, "UserCode,PhotoPath");
	}
	
	// 전자결재 리스트 조회 조건 가져오는 메소드
	// APPROVAL, ACCOUNT 등..
	public CoviMap getApprovalListCode(CoviMap params, String businessData1) throws Exception {		
		// 통합결재에 포함되는 타 시스템 코드
		List<String> bizDataList = new ArrayList<>();

		// 전자결재 포함유무
		if(StringUtil.isBlank(businessData1) || businessData1.equalsIgnoreCase("APPROVAL") || businessData1.equalsIgnoreCase("CONF")) { // 간편관리자(CONF)
			params.put("isApprovalList", "Y");
			
			bizDataList.add("");
			bizDataList.add("APPROVAL");
			
			// 통합결재 사용유무
			if(RedisDataUtil.getBaseConfig("useTotalApproval").equalsIgnoreCase("Y")) {
				CoviList totalApprovalListType = RedisDataUtil.getBaseCode("TotalApprovalListType"); // 통합결재에 표시할 타시스템
				
				for (int i=0; i< totalApprovalListType.size(); i++) {
					// 사용여부 Y 인 경우
					if(totalApprovalListType.getJSONObject(i).optString("IsUse").equalsIgnoreCase("Y")) {
						bizDataList.add(totalApprovalListType.getJSONObject(i).getString("Code"));
					}
				}	
			}
		}
		else {
			params.put("isApprovalList", "N");
			bizDataList.add(businessData1);
			
			//
			params.put("businessData1", businessData1);
		}
		params.put("bizDataList", bizDataList);
		
		return params;
	}
	
	@Override
	public int updateHandoverUser(CoviMap params) throws Exception {
		return coviMapperOne.update("user.approvalList.updateHandoverUser", params);
	}

	@Override
	public int executePdfConvert(CoviMap param, String renderUrl) throws Exception {
		try {
			StringBuilder buf = new StringBuilder();
			String formInstanceId = param.getString("FormInstanceId");
			String processId = param.getString("ProcessId");
			String draftId = param.getString("DraftId");
			//String UUID = java.util.UUID.randomUUID().toString();
			
			buf.append("callMode=PDF");
			buf.append("&formInstanceID=" + formInstanceId);
			buf.append("&processID=" + processId);
			buf.append("&logonId=" + draftId);
			buf.append("&PAGEONLY=Y");
			
			String url = renderUrl + "?" + buf.toString();
			
			Map<String, String> paramMap = new HashMap<>();
			paramMap.put("url", url);
//			param.put("UUID", UUID);
			
			// 2. Convert URL(Html) to PDF using wkhtmltopdf (include javascript)
			CoviMap returnObj = createPdfByUrl(paramMap);
			
			if("FAIL".equals(returnObj.optString("status"))) {
				throw new Exception("Fail.");
			}
			
			//직접변환
			String saveFileName = (String)returnObj.get("saveFileName");
			String savePath = (String)returnObj.get("savePath");// Full path.
			
			param.put("savePath", savePath + saveFileName);
			return 1;
		}catch(NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			return 0;
		}catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return 0;
		}
	}
	
	private CoviMap createPdfByUrl(Map<String, String> paramMap) throws Exception {
		CoviMap rst = ChromeRenderManager.getInstance().renderURLOnChrome(paramMap.get("url"));
		if(rst.containsKey("status") && rst.optString("status").equals("FAIL")) {
			return rst;
		}
		paramMap.put("txtHtml", rst.optString("rtnHtml"));
		return ChromeRenderManager.getInstance().createPdf(paramMap);
	}

	/**
	 * JSP (CollabLink.jsp 에서 호출)
	 */
	@Override
	public void transferCollabLink(HttpServletRequest request, HttpServletResponse response, Map<String, String> params, JspWriter out) throws Exception {
		CoviMap returnObj = new CoviMap();
		int successCnt = 0;
		int failCnt = 0;
		int totalCnt = 0;
		try {
			String paramFormInstanceIds = request.getParameter("formInstanceIDs");
			if(paramFormInstanceIds == null) {
				paramFormInstanceIds = params.get("formInstanceIDs");
			}
			String paramJson = new String(Base64.decodeBase64(paramFormInstanceIds.getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
			CoviList ja =  CoviList.fromObject(paramJson);
			if(ja != null) {
				totalCnt = ja.size();
				for(int i = 0; i < ja.size(); i++) {
					try {
						CoviMap map =  ja.getJSONObject(i);
						String formInstanceId = (String)map.get("formInstanceId");
						String processId = (String)map.get("processId");
						
						CoviList trgMember = new CoviList();
						CoviMap trgMap = new CoviMap();
						trgMap.put("userCode", SessionHelper.getSession("USERID"));
						trgMember.add(trgMap);
						
						// Select formInstance Info.
						CoviMap paramsFormInstance = new CoviMap();
						paramsFormInstance.put("formInstID", formInstanceId);
						CoviMap formInstance = (CoviMap)(formSvc.selectFormInstance(paramsFormInstance)).getJSONArray("list").get(0);
						String docAttachJsonStr = (String)formInstance.get("AttachFileInfo");
						
						CoviMap param = new CoviMap();
						param.put("DN_Code", SessionHelper.getSession("DN_Code"));
						param.put("CompanyCode", SessionHelper.getSession("DN_Code"));
						param.put("USERID", SessionHelper.getSession("USERID"));
						param.put("prjSeq", params.get("PrjSeq"));
						param.put("prjType", params.get("PrjType"));
						param.put("sectionSeq", params.get("SectionSeq"));
						param.put("taskName", formInstance.get("Subject"));
						param.put("taskStatus", "W");
						param.put("progRate", "0");
						param.put("parentKey", "0");
						param.put("topParentKey", "0");
						param.put("objectType", "APPROVAL");
						param.put("objectID", formInstanceId);
						param.put("allowDup", StringUtils.defaultIfEmpty( RedisDataUtil.getBaseConfig("COLLAB_APP_IF_DUP"), "Y"));
						param.put("DocAttach", docAttachJsonStr); // Base64 Encoded.
						
						param.put("taskSeq", params.get("taskSeq"));
						param.put("svcType", params.get("svcType"));
						CoviMap target = new CoviMap();
						target.put("DraftId", formInstance.get("InitiatorID"));
						target.put("ProcessId", processId);
						target.put("FormInstanceId", formInstanceId);
						
						String requestUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
						String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
						if("Y".equals(isSaaS)) {
							String PCGWServerURL = RedisDataUtil.getBaseConfig("PCGWServerURL", SessionHelper.getSession("DN_ID"));
							if(!StringUtils.isEmpty(PCGWServerURL)) {
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
						
						// 본문 변환
						int result = executePdfConvert(target, viewUrl);
						if(result == 0) {
							throw new Exception("Fail to convert PDF." + target.toString());
						}
						
						String contentPdfPath = target.getString("savePath");
						String collabApiUrl = RedisDataUtil.getBaseConfig("COLLAB_ADD_API");
						if(StringUtil.isNull(collabApiUrl)) {
							throw new Exception ("Collab link url is null. check BaseConfig [COLLAB_ADD_API].");
						}
						String url = requestUrl + collabApiUrl;
						if(collabApiUrl.startsWith("http")) {
							url = collabApiUrl;
						}
						
						
						param.put("pdfPath", contentPdfPath); // 본문변환 파일.
						param.put("trgMember", trgMember);
						
						// 첨부파일 (본문, 첨부)
						RequestHelper.sendUrl(url, "application/json", "POST", param);
						successCnt ++;
					}catch(ArrayIndexOutOfBoundsException aioobE) {
						LOGGER.error("", aioobE);
						failCnt ++;
					}catch(NullPointerException npE) {
						LOGGER.error("", npE);
						failCnt ++;
					}catch(Exception ex) {
						LOGGER.error("", ex);
						failCnt ++;
					}finally {
						// 진행율을 표시할 수 있 도록 jspWriter 에 flush.
						out.write("<script type='text/javascript'>setProgress('"+i+"');</script>");
						out.flush();
					}
				}//end for
				
				returnObj.put("status", Return.SUCCESS);
				returnObj.put("message", "등록되었습니다");
			}else {
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "처리할 데이터가 없습니다.");
			}
		} catch (NullPointerException npE) {
			LOGGER.error("", npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error("", e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", DicHelper.getDic("msg_apv_030"));
		} finally {
			if(out != null) {
				out.write("<script type='text/javascript'>setComplete('"+returnObj.get("status")+"', "+totalCnt+" ,"+successCnt+", "+failCnt+", '"+returnObj.get("message")+"');</script>");
				out.flush();
			}
		}
	}
	
	/**
	 * JSP (CollabLink.jsp 에서 호출)
	 */
	@Override
	public CoviMap transferPdfCollab(Map<String, String> params) throws Exception {
		CoviMap returnObj = new CoviMap();
		int successCnt = 0;
		int failCnt = 0;
		int totalCnt = 0;

		String paramFormInstanceId = params.get("formInstanceID");
		String paramJson = new String(Base64.decodeBase64(paramFormInstanceId.getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
		
		CoviMap map =  CoviMap.fromObject(paramJson);
		String formInstanceId = (String)map.get("formInstanceId");
		String processId = (String)map.get("processId");
		
		CoviList trgMember = new CoviList();
		CoviMap trgMap = new CoviMap();
		trgMap.put("userCode", SessionHelper.getSession("USERID"));
		trgMember.add(trgMap);
		
		// Select formInstance Info.
		CoviMap paramsFormInstance = new CoviMap();
		paramsFormInstance.put("formInstID", formInstanceId);
		CoviMap formInstance = (CoviMap)(formSvc.selectFormInstance(paramsFormInstance)).getJSONArray("list").get(0);
		
		CoviMap target = new CoviMap();
		target.put("DraftId", formInstance.get("InitiatorID"));
		target.put("ProcessId", processId);
		target.put("FormInstanceId", formInstanceId);
		
		String requestUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
		if("Y".equals(isSaaS)) {
			String PCGWServerURL = RedisDataUtil.getBaseConfig("PCGWServerURL", SessionHelper.getSession("DN_ID"));
			if(!StringUtils.isEmpty(PCGWServerURL)) {
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
		
		// 본문 변환
		int result = executePdfConvert(target, viewUrl);
		if(result == 0) {
			throw new Exception("Fail to convert PDF." + target.toString());
		}
		
		String contentPdfPath = target.getString("savePath");
		String collabApiUrl = RedisDataUtil.getBaseConfig("COLLAB_ADD_API");
		if(StringUtil.isNull(collabApiUrl)) {
			throw new Exception ("Collab link url is null. check BaseConfig [COLLAB_ADD_API].");
		}
		String url = requestUrl + collabApiUrl;
		if(collabApiUrl.startsWith("http")) {
			url = collabApiUrl;
		}
		
		CoviMap param = new CoviMap();
		param.put("pdfPath", contentPdfPath); // 본문변환 파일.
		param.put("trgMember", trgMember);
		
		List<MultipartFile> mockedFileList = new ArrayList<>();
		File file = new File(param.getString("pdfPath"));
		if(file.exists()) {
			DiskFileItem fileItem = new DiskFileItem("file", Files.probeContentType(file.toPath()), false, params.get("subject") + ".pdf", (int) file.length() , file.getParentFile());
			try (InputStream input = new FileInputStream(file);
					OutputStream os = fileItem.getOutputStream();){
				IOUtils.copy(input, os);
				MultipartFile multipartFile = new CommonsMultipartFile(fileItem);
				mockedFileList.add(0, multipartFile);
			}
		}
		
		if(!FileUtil.isEnableExtention(mockedFileList)){
			throw new SecurityException("Contains not allowd file extension.");
		}
		String objectType = "APPROVAL";
		String fileSvcPath = "Collab/";
		String fileSvcType = "Collab";
		String refId = params.get("taskSeq"); 
		
		fileSvc.uploadToBack(null, mockedFileList, fileSvcPath, fileSvcType, refId, objectType, "0", false);
		return returnObj;
	}
	
	@Override
	public CoviMap selectFormExtInfo(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("form.formLoad.selectFormExtInfo", params);
		return CoviSelectSet.coviSelectMapJSON(map, "SchemaContext");
	}

	@Override
	//개인함 목록 데이터 조회
	public CoviMap selectDocTypeList(CoviMap params) throws Exception {
		//
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList 	list = null;
		int cnt = 0;
		
		String strCountQuery = "user.approvalList.selectDocTypeListCnt";
		String strListQuery = "user.approvalList.selectDocTypeList";
		String strListCol = "ProcessID,FormPrefix,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,EndDate,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";

		cnt = (int) coviMapperOne.getNumber(strCountQuery, params);
		
		page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list = coviMapperOne.list(strListQuery, params);
		
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, strListCol));
		resultList.put("page", page);
		
		return resultList;
	}
	
	
	
	@Override
	public CoviList selectHomeSectionSort(CoviMap params) throws Exception {
		params.put("UserCode", SessionHelper.getSession("USERID"));
		return coviMapperOne.list("user.dashboard.selectHomeSectionSort", params);
	}

	@Override
	public int updateHomeSectionSort(CoviMap params) throws Exception {
		int result = 0;
		String [] sortList = StringUtils.split(params.optString("sortList"), ";");
		CoviList updateList = new CoviList();
		for(int i = 0; sortList != null && i < sortList.length; i++) {
			CoviMap map = new CoviMap();
			map.put("SectionKey", sortList[i]);
			map.put("SortKey", (i + 1));
			updateList.add(map);
		}
		if(updateList.size() > 0) {
			params.put("Type", "SECTION");
			params.put("SortList", updateList);
			result = coviMapperOne.update("user.dashboard.updateHomeSectionSort", params);
		}
		return result;
	}

	@Override
	public int updateHomeListTabSort(CoviMap params) throws Exception {
		int result = 0;
		String [] sortList = StringUtils.split(params.optString("sortList"), ";");
		CoviList updateList = new CoviList();
		for(int i = 0; sortList != null && i < sortList.length; i++) {
			CoviMap map = new CoviMap();
			map.put("SectionKey", sortList[i]);
			map.put("SortKey", (i + 1));
			updateList.add(map);
		}
		if(updateList.size() > 0) {
			params.put("Type", "LISTTYPE");
			params.put("SortList", updateList);
			result = coviMapperOne.update("user.dashboard.updateHomeSectionSort", params);
		}
		return result;
	}
}
