package egovframework.covision.coviflow.user.mobile.service.impl;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.common.util.ComUtils;
import egovframework.covision.coviflow.user.mobile.service.MobileApprovalListSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("mobileApprovalListSvc")
public class MobileApprovalListSvcImpl extends EgovAbstractServiceImpl implements MobileApprovalListSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap selectMobileMenuList(CoviMap params) throws Exception {
		// 구 전자결재 모바일 사용
		CoviList	list = coviMapperOne.list("user.mobileapprovalList.selectMobileMenuList", params);
		CoviMap 	resultList 	= new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "MenuMode,MenuName"));
		return resultList;
	}
	
	@Override
	public CoviMap selectMobileApprovalList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList 	list = null;
		
		String strCountQuery = "";
		String strListQuery = "";
		String strListCol = "";
		if(params.optString("mode").equalsIgnoreCase("PREAPPROVAL")){ // 예고함
			strCountQuery = "user.approvalList.selectPreApprovalListCnt";
			strListQuery = "user.approvalList.selectPreApprovalList";
			strListCol = "ProcessID,WorkItemID,PerformerID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,Created,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("APPROVAL")){ // 미결함
			strCountQuery = "user.approvalList.selectApprovalListCnt";
			strListQuery = "user.approvalList.selectApprovalList";
			strListCol = "ProcessID,WorkItemID,PerformerID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,Created,FormSubKind,TaskID,ReadDate,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,ProcessName,SchemaContext";
		}
		else if(params.optString("mode").equalsIgnoreCase("PROCESS")){ // 진행함
			strCountQuery = "user.approvalList.selectProcessListCnt";
			strListQuery = "user.approvalList.selectProcessList";
			strListCol = "ProcessID,WorkItemID,PerformerID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,StartDate,Finished,FormSubKind,TaskID,ReadDate,DomainDataContext,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("COMPLETE")){ // 완료함
			strCountQuery = "user.approvalList.selectCompleteListCnt";
			strListQuery = "user.approvalList.selectCompleteList";
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,EndDate,FormSubKind,TaskID,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("REJECT")){ // 반려함
			strCountQuery = "user.approvalList.selectRejectListCnt";
			strListQuery = "user.approvalList.selectRejectList";
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionArchiveID,FormInstID,SchemaID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,EndDate,FormSubKind,TaskID,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("TEMPSAVE")){ // 임시함
			strCountQuery = "user.approvalList.selectTempSaveListCnt";
			strListQuery = "user.approvalList.selectTempSaveList";
			strListCol = "FormTempInstBoxID,FormInstID,FormID,SchemaID,FormInstTableName,UserCode,FormPrefix,CreatedDate,SubKind,Subject,Kind,FormName,FormSubject";
		}
		else if(params.optString("mode").equalsIgnoreCase("RECEXHIBIT")){ // 수신공람함
			strCountQuery = "user.approvalList.selectReceiveExhibitListCnt";
			strListQuery = "user.approvalList.selectReceiveExhibitList";
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,EndDate,FormSubKind,TaskID,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else{ // 참조/회람함
			strCountQuery = "user.approvalList.selectTCInfoListCnt";
			strListQuery = "user.approvalList.selectTCInfoList";
			strListCol = "CirculationBoxID,ProcessID,CirculationBoxDescriptionID,FormInstID,FormPrefix,ReceiptID,ReceiptType,ReceiptName,ReceiptDate,Kind,State,ReadDate,SenderID,SenderName,Subject,Comment,DataState,RegID,RegDate,ModID,ModDate,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,FormSubKind,SubKind,ExtInfo,DocNo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,TaskID";
		}
		
		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber(strCountQuery, params);
			page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			
			resultList.put("page", page);
			resultList.put("cnt", cnt);
		}
		
		list = coviMapperOne.list(strListQuery, params);
		
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, strListCol));
		return resultList;
	}
	
	@Override
	//부서함 목록 데이터 조회
	public CoviMap selectMobileDeptApprovalList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList list = null;
		
		String strCountQuery = "";
		String strListQuery = "";
		String strListCol = "";
		
		if(params.optString("mode").equalsIgnoreCase("DEPTCOMPLETE")){ // 완료함
			strCountQuery = "user.deptapprovalList.selectDeptDraftCompleteListCnt";
			strListQuery = "user.deptapprovalList.selectDeptDraftCompleteList";
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,SubKind,UserCode,UserName,FormPrefix,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,EndDate,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("SENDERCOMPLETE")){ // 발신함
			strCountQuery = "user.deptapprovalList.selectDeptSenderCompleteListCnt";
			strListQuery = "user.deptapprovalList.selectDeptSenderCompleteList";
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,SubKind,UserCode,UserName,FormPrefix,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,EndDate,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("RECEIVE")){ // 수신함
			strCountQuery = "user.deptapprovalList.selectDeptReceiveListCnt";
			strListQuery = "user.deptapprovalList.selectDeptReceiveList";
			strListCol = "ProcessID,WorkItemID,PerformerID,TaskID,SubKind,UserCode,UserName,FormPrefix,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,MODE,Created,FormSubKind,ReadDate,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,SchemaContext";
		}
		else if(params.optString("mode").equalsIgnoreCase("RECEIVECOMPLETE")){ // 수신처리함
			strCountQuery = "user.deptapprovalList.selectDeptReceiveCompleteListCnt";
			strListQuery = "user.deptapprovalList.selectDeptReceiveCompleteList";
			strListCol = "ProcessArchiveID,PerformerID,WorkitemArchiveID,FormPrefix,ProcessDescriptionArchiveID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,EndDate,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10";
		}
		else if(params.optString("mode").equalsIgnoreCase("DEPTTCINFO")){ // 참조/회람함
			strCountQuery = "user.deptapprovalList.selectDeptTCInfoListCnt";
			strListQuery = "user.deptapprovalList.selectDeptTCInfoList";
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

		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber(strCountQuery, params);
			page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			
			resultList.put("page", page);
			resultList.put("cnt", cnt);
		}
		
		list = coviMapperOne.list(strListQuery, params);
		
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("D", list, strListCol));
		return resultList;
	}

	@Override
	public CoviMap selectMobileApprovalView(CoviMap params) throws Exception {
		// 사용 안 함
		CoviMap 	resultList 	= new CoviMap();
		
		CoviList processdes = new CoviList();
		if((params.optString("mode").equalsIgnoreCase("COMPLETE") && params.optString("gloct").equalsIgnoreCase("COMPLETE"))
			|| (params.optString("mode").equalsIgnoreCase("COMPLETE") && params.optString("gloct").equalsIgnoreCase("DEPART"))
			|| (params.optString("mode").equalsIgnoreCase("COMPLETE") && params.optString("gloct").equalsIgnoreCase("TCINFO"))
			|| params.optString("mode").equalsIgnoreCase("REJECT")) {
			processdes = coviMapperOne.list("form.formLoad.selectProcessDesArchive", params);
		} else {
			processdes = coviMapperOne.list("form.formLoad.selectProcessDes", params);
		}
		
		CoviList forminstance = coviMapperOne.list("form.formLoad.selectFormInstance", params);
		
		
		resultList.put("processdes", CoviSelectSet.coviSelectJSON(processdes, "ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2"));
		resultList.put("forminstance", CoviSelectSet.coviSelectJSON(forminstance, "FormInstID,ProcessID,FormID,SchemaID,Subject,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,CompletedDate,DeletedDate,LastModifiedDate,LastModifierID,EntCode,EntName,DocNo,DocLevel,DocClassID,DocClassName,DocSummary,IsPublic,SaveTerm,AttachFileInfo,AppliedDate,AppliedTerm,ReceiveNo,ReceiveNames,ReceiptList,BodyType,BodyContext,DocLinks,RuleItemInfo"));
		
		return resultList;
	}
	
	// 전자결재 리스트 조회 조건 가져오는 메소드
	// APPROVAL, ACCOUNT 등..
	public CoviMap getApprovalListCode(CoviMap params, String businessData1) throws Exception {		
		// 통합결재에 포함되는 타 시스템 코드
		List<String> bizDataList = new ArrayList<String>();

		// 전자결재 포함유무
		if(StringUtil.isBlank(businessData1) || businessData1.equalsIgnoreCase("APPROVAL")) {
			params.put("isApprovalList", "Y");
			
			bizDataList.add("");
			bizDataList.add("APPROVAL");
			
			// 통합결재 사용유무
			if(RedisDataUtil.getBaseConfig("useTotalApproval").equalsIgnoreCase("Y")) {
				CoviList TotalApprovalListType = RedisDataUtil.getBaseCode("TotalApprovalListType"); // 통합결재에 표시할 타시스템
				
				for (int i=0; i< TotalApprovalListType.size(); i++) {
					// 사용여부 Y 인 경우
					if(TotalApprovalListType.getJSONObject(i).optString("IsUse").equalsIgnoreCase("Y")) {
						bizDataList.add(TotalApprovalListType.getJSONObject(i).getString("Code"));
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
