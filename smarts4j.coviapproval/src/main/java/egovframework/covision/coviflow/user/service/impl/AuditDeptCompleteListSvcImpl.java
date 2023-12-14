package egovframework.covision.coviflow.user.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.coviflow.common.util.ComUtils;
import egovframework.covision.coviflow.user.service.AuditDeptCompleteListSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("auditDeptCompleteListSvc")
public class AuditDeptCompleteListSvcImpl extends EgovAbstractServiceImpl implements AuditDeptCompleteListSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	// 개인결재함, 부서결재함 공통 엑셀 데이터 조회
	public CoviMap selectExcelData(CoviMap params, String queryID, String headerKey) throws Exception {
		if(params.containsKey("DBName") && params.optString("DBName").equalsIgnoreCase("COVI_APPROVAL4J_STORE")) {
			queryID = queryID.replace("select","selectStore");
		}		
		CoviList list = coviMapperOne.list("user.AuditDeptCompleteList."+queryID, params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, headerKey));

		return resultList;
	}

	@Override 	//감사문서함 공통 그룹별 목록 데이터 조회
	public CoviMap getAuditDeptCompleteGroupListData(CoviMap params) throws Exception {
		String strListQuery = "user.AuditDeptCompleteList.selectAuditDept"+params.get("clickTab")+"GroupList";
		
		if(params.containsKey("DBName") && params.optString("DBName").equalsIgnoreCase("COVI_APPROVAL4J_STORE")) {
			strListQuery = "user.AuditDeptCompleteList.selectStoreAuditDept"+params.get("clickTab")+"GroupList";
		}
		
		CoviList	list = coviMapperOne.list(strListQuery, params);
		CoviMap 	resultList 	= new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "fieldID,fieldCnt,fieldName"));
		return resultList;
	}

	@Override
	public CoviMap getAuditDeptProcessListData(CoviMap params) throws Exception {
		String strCountQuery = "user.AuditDeptCompleteList.selectAuditDeptProcessListCnt";
		String strListQuery = "user.AuditDeptCompleteList.selectAuditDeptProcessList";
		String headerKey = "FormSubject,FormID,FormInstID,ProcessArchiveID,InitiatorUnitID,InitiatorUnitName,InitiatorID,InitiatorName,InitiatedDate,CompletedDate,EntCode,ProcessState,ProcessDescriptionArchiveID,DocNo,FormName,FormPrefix,BusinessData1,BusinessData2,IsSecureDoc,IsFile";
		
		if(params.containsKey("DBName") && params.optString("DBName").equalsIgnoreCase("COVI_APPROVAL4J_STORE")) {
			strCountQuery = "user.AuditDeptCompleteList.selectStoreAuditDeptProcessListCnt";
			strListQuery = "user.AuditDeptCompleteList.selectStoreAuditDeptProcessList";
			headerKey = "ProcessArchiveID,DocSubject,InitiatorUnitID,InitiatorUnitName,InitiatorID,InitiatorName,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,EndDate,FormPrefix,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		
		CoviMap resultList = new CoviMap();
		int cnt = (int) coviMapperOne.getNumber(strCountQuery, params);
		
		CoviMap page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list(strListQuery, params);
		
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, headerKey));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap getAuditDeptCompleteListData(CoviMap params) throws Exception {
		String strCountQuery = "user.AuditDeptCompleteList.selectAuditDeptCompleteListCnt";
		String strListQuery = "user.AuditDeptCompleteList.selectAuditDeptCompleteList";
		String headerKey = "FormSubject,FormID,FormInstID,ProcessArchiveID,InitiatorUnitID,InitiatorUnitName,InitiatorID,InitiatorName,InitiatedDate,CompletedDate,EntCode,ProcessState,ProcessDescriptionArchiveID,DocNo,FormName,FormPrefix,BusinessData1,BusinessData2,IsSecureDoc,IsFile";
		
		if(params.containsKey("DBName") && params.optString("DBName").equalsIgnoreCase("COVI_APPROVAL4J_STORE")) {
			strCountQuery = "user.AuditDeptCompleteList.selectStoreAuditDeptCompleteListCnt";
			strListQuery = "user.AuditDeptCompleteList.selectStoreAuditDeptCompleteList";
			headerKey = "ProcessArchiveID,DocSubject,InitiatorUnitID,InitiatorUnitName,InitiatorID,InitiatorName,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,EndDate,FormPrefix,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		
		CoviMap resultList = new CoviMap();
		int cnt = (int) coviMapperOne.getNumber(strCountQuery, params);
		
		CoviMap page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list(strListQuery, params);
		
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, headerKey));
		resultList.put("page", page);
		
		return resultList;
	}
}
