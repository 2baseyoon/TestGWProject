package egovframework.covision.coviflow.user.service.impl;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.common.util.ComUtils;
import egovframework.covision.coviflow.user.service.DeptApprovalListSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("deptApprovalListSvc")
public class DeptApprovalListSvcImpl extends EgovAbstractServiceImpl implements DeptApprovalListSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	//개인결재함, 부서결재함 공통 그룹별 목록 데이터 조회
	public CoviMap selectDeptApprovalGroupList(CoviMap params) throws Exception {
		
		CoviMap 	resultList 	= new CoviMap();
		CoviList 	list 		= null;
		if(params.optString("mode").equalsIgnoreCase("DEPTCOMPLETE")){ // 완료함
			if("covi_approval4j_store".equalsIgnoreCase(params.getString("DBName"))) {
				list = coviMapperOne.list("user.deptapprovalList.selectStoreDeptDraftCompleteGroupList", params);
			}else {
				list = coviMapperOne.list("user.deptapprovalList.selectDeptDraftCompleteGroupList", params);
			}
		}
		else if(params.optString("mode").equalsIgnoreCase("SENDERCOMPLETE")){ // 발신함
			list = coviMapperOne.list("user.deptapprovalList.selectDeptSenderCompleteGroupList", params);
		}
		else if(params.optString("mode").equalsIgnoreCase("RECEIVE")){ // 수신함
			list = coviMapperOne.list("user.deptapprovalList.selectDeptReceiveGroupList", params);
		}
		else if(params.optString("mode").equalsIgnoreCase("RECEIVECOMPLETE")){ // 수신/처리함
			list = coviMapperOne.list("user.deptapprovalList.selectDeptReceiveCompleteGroupList", params);
		}
		else if(params.optString("mode").equalsIgnoreCase("DEPTTCINFO")){ // 참조/회람함
			if("covi_approval4j_store".equalsIgnoreCase(params.getString("DBName"))) {
				list = coviMapperOne.list("user.deptapprovalList.selectStoreDeptTCInfoGroupList", params);
			}else {
				list = coviMapperOne.list("user.deptapprovalList.selectDeptTCInfoGroupList", params);
			}
		}
		else if(params.optString("mode").equalsIgnoreCase("DEPTRECEXHIBIT")){ // 수신공람함
			list = coviMapperOne.list("user.deptapprovalList.selectDeptReceiveExhibitGroupList", params);
		}
		else{ // 진행함
			list = coviMapperOne.list("user.deptapprovalList.selectDeptReceiveProcessGroupList", params);
		}
		resultList.put("list", ComUtils.coviSelectJSONForApprovalGroupList(params.getString("searchGroupType"), params.getString("mode"), list, "fieldID,fieldCnt,fieldName"));

		return resultList;
	}

	// 개인결재함, 부서결재함 공통 엑셀 데이터 조회
	public CoviMap selectExcelData(CoviMap params, String queryID, String headerKey) throws Exception {
		CoviList list = coviMapperOne.list("user.deptapprovalList."+queryID, params);

		CoviMap resultList = new CoviMap();
		
		// 20210126 이관함 > 부서 참조/회람함에서 엑셀 저장 시 구분에 합의로 나오는 부분 수정
		if (params.optString("bstored").equalsIgnoreCase("true") && params.optString("queryID").equalsIgnoreCase("selectDeptTCInfoListExcel")) {
			resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, headerKey));
		}else {
			resultList.put("list", ComUtils.coviSelectJSONForApprovalList("D", list, headerKey));
		}
		return resultList;
	}

	@Override
	//부서함 목록 데이터 조회
	public CoviMap selectDeptApprovalList(CoviMap params) throws Exception {
		//
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList list = null;
		int cnt = 0;
		
		String strCountQuery = "";
		String strListQuery = "";
		String strListCol = "";
		if(params.optString("mode").equalsIgnoreCase("DEPTCOMPLETE")){ // 완료함
			if(params.containsKey("DBName") && params.optString("DBName").equalsIgnoreCase("COVI_APPROVAL4J_STORE")) {
				strCountQuery = "user.deptapprovalList.selectStoreDeptDraftCompleteListCnt";
				strListQuery = "user.deptapprovalList.selectStoreDeptDraftCompleteList";
			} else {
				strCountQuery = "user.deptapprovalList.selectDeptDraftCompleteListCnt";
				strListQuery = "user.deptapprovalList.selectDeptDraftCompleteList";
			}			
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,SubKind,UserCode,UserName,FormPrefix,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,EndDate,ExtInfo,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("SENDERCOMPLETE")){ // 발신함
			strCountQuery = "user.deptapprovalList.selectDeptSenderCompleteListCnt";
			strListQuery = "user.deptapprovalList.selectDeptSenderCompleteList";
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,SubKind,UserCode,UserName,FormPrefix,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,EndDate,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("RECEIVE")){ // 수신함
			strCountQuery = "user.deptapprovalList.selectDeptReceiveListCnt";
			strListQuery = "user.deptapprovalList.selectDeptReceiveList";
			strListCol = "ProcessID,ProcessName,WorkItemID,PerformerID,TaskID,SubKind,UserCode,UserName,FormPrefix,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,MODE,Created,FormSubKind,ReadDate,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,SchemaContext";
		}
		else if(params.optString("mode").equalsIgnoreCase("RECEIVECOMPLETE")){ // 수신처리함
			strCountQuery = "user.deptapprovalList.selectDeptReceiveCompleteListCnt";
			strListQuery = "user.deptapprovalList.selectDeptReceiveCompleteList";
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,FormPrefix,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,EndDate,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("DEPTTCINFO")){ // 참조/회람함
			if(params.containsKey("DBName") && params.optString("DBName").equalsIgnoreCase("COVI_APPROVAL4J_STORE")) {
				strCountQuery = "user.deptapprovalList.selectStoreDeptTCInfoListCnt";
				strListQuery = "user.deptapprovalList.selectStoreDeptTCInfoList";
			} else {
				strCountQuery = "user.deptapprovalList.selectDeptTCInfoListCnt";
				strListQuery = "user.deptapprovalList.selectDeptTCInfoList";
			}				
			strListCol = "CirculationBoxID,ProcessID,CirculationBoxDescriptionID,FormInstID,ReceiptID,ReceiptType,ReceiptName,ReceiptDate,SubKind,State,ReadDate,SenderID,SenderName,Subject,Comment,DataState,RegID,RegDate,ModID,ModDate,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,FormID,FormPrefix,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,ReadCheck,FormSubKind,DocNo,ExtInfo,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("DEPTRECEXHIBIT")){ // 수신공람함
			strCountQuery = "user.deptapprovalList.selectDeptReceiveExhibitListCnt";
			strListQuery = "user.deptapprovalList.selectDeptReceiveExhibitList";
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,FormPrefix,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,EndDate,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else{ // 진행함
			strCountQuery = "user.deptapprovalList.selectDeptReceiveProcessListCnt";
			strListQuery = "user.deptapprovalList.selectDeptReceiveProcessList";
			strListCol = "ProcessID,WorkItemID,PerformerID,SubKind,UserCode,UserName,ProcessDescriptionID,FormInstID,FormID,FormPrefix,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,Created,Mode,Charge,FormSubKind,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		
		cnt = (int) coviMapperOne.getNumber(strCountQuery, params);
		
		page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list = coviMapperOne.list(strListQuery, params);
		
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("D", list, strListCol));
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public int selectDeptProcessNotDocReadCnt(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.deptapprovalList.selectDeptProcessNotDocReadCnt", params);
	}

	@Override
	public int selectDeptTCInfoNotDocReadCnt(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.deptapprovalList.selectDeptTCInfoNotDocReadCnt", params);
	}

	@Override
	public int selectDeptTCInfoSingleDocRead(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.deptapprovalList.selectDeptTCInfoSingleDocRead", params);
	}
	
	@Override
	public int selectDeptBoxListCnt(CoviMap params) throws Exception {
		String strCntQuery = "";
		switch (params.getString("listGubun")) {
			case "D_SenderComplete":  
				strCntQuery = "user.deptapprovalList.selectDeptSenderCompleteListCnt";
				break;
			case "D_DeptComplete":  
				strCntQuery = "user.deptapprovalList.selectDeptDraftCompleteListCnt";
				break;
			case "D_ReceiveComplete":  
				strCntQuery = "user.deptapprovalList.selectDeptReceiveCompleteListCnt";
				break;
			default:
		}
		return (int) coviMapperOne.getNumber(strCntQuery, params);
	}

	@Override
	public CoviList getPersonDirectorOfUnitData(CoviMap params) throws Exception {
		CoviList directorArr = new CoviList();
		CoviList unitDirectorArr = new CoviList();
		/*
		 * '소속부서'  AS UnitName
			,'all'        AS UnitCode
		 */
		
		CoviList list = coviMapperOne.list("user.deptapprovalList.selectDeptDirector", params);
		directorArr = CoviSelectSet.coviSelectJSON(list, "UnitName,UnitCode,ViewStartDate,ViewEndDate");
		int directorArrLen = directorArr.size();
		
		list = coviMapperOne.list("user.deptapprovalList.selectDeptUnitDirector", params);
		unitDirectorArr = CoviSelectSet.coviSelectJSON(list, "UnitName,UnitCode,ViewStartDate,ViewEndDate");
		
		if(directorArrLen > 0 || !unitDirectorArr.isEmpty()){
			for(Object obj : unitDirectorArr){
				CoviMap unitDirectorObj = (CoviMap) obj;
				for(int i=0; i<directorArrLen; i++){
					CoviMap directorObj = directorArr.getJSONObject(i);
					if(directorObj.optString("UnitCode").equalsIgnoreCase(unitDirectorObj.getString("UnitCode"))){
						break;
					}else if(directorArrLen == i+1){
						directorArr.add(unitDirectorObj);
					}
				}
			}
			
			if(directorArrLen == 0){
				directorArr = unitDirectorArr;
			}
			
			CoviMap tmpObj = new CoviMap();
			tmpObj.put("UnitName", DicHelper.getDic("lbl_apv_BelongDept"));
			tmpObj.put("UnitCode", "all");
			
			directorArr.add(0, tmpObj);
		}
		
		return directorArr;
	}
	
	// 수신함 전체 개수 조회
	@Override
	public int selectDeptReceptionCnt(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.deptapprovalList.selectDeptReceiveListCnt", params);
	}

	// 진행함 전체 개수 조회
	@Override
	public int selectDeptProcessCnt(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.deptapprovalList.selectDeptReceiveProcessListCnt", params);
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
	public int insertTCInfoDocReadHistory(CoviMap params) throws Exception {
		int result = 0;
		
		ArrayList<CoviMap> paramList = (ArrayList<CoviMap>) params.get("paramList");
		for (CoviMap param : paramList) {
			int cnt = (coviMapperOne.select("form.formLoad.selectTCInfoDocReadHistory", param)).getInt("CNT");
			if (cnt == 0) {
				result += coviMapperOne.insert("form.formLoad.insertTCInfoDocReadHistory",param);
			}
		}
		
		return result;
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
}
