package egovframework.covision.groupware.approval.user.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.groupware.approval.user.service.ApprovalSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("approvalService")
public class ApprovalSvcImpl extends EgovAbstractServiceImpl implements ApprovalSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviList selectLastestUsedFormListData(CoviMap params) throws Exception {
		CoviList resultList = new CoviList();		
		CoviList list = coviMapperOne.list("user.approval.selectCompleteAndRejectListData", params);
		resultList = CoviSelectSet.coviSelectJSON(list, "ProcessArchiveID,PerformerID,WorkitemArchiveID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,SchemaID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,EndDate,FormSubKind,TYPE");		
		return resultList;
	}

	@Override
	public CoviList selectFavoriteUsedFormListData(CoviMap params) throws Exception {
		CoviList usedFormListObj = new CoviList();
		
		CoviList list = coviMapperOne.list("user.approval.selectFavoriteUsedFormListData", params);
		usedFormListObj = CoviSelectSet.coviSelectJSON(list, "LabelText,FormID,FormPrefix");
		
		return usedFormListObj;
	}

	@Override
	public CoviList selectMyInfoProfileApprovalData(CoviMap params)
			throws Exception {
		CoviList approvalListObj = new CoviList();
		
		/*2019.06 쿼리 제거 - 의미없음
		String formInstIDs = coviMapperOne.selectOne("user.approval.selectMyInfoProfileApprovalFormInstID", params);
		
		params.put("FormInstIDs", formInstIDs);
		*/
		
		CoviList list = coviMapperOne.list("user.approval.selectMyInfoProfileApprovalData", params);
		approvalListObj = CoviSelectSet.coviSelectJSON(list, "ProcessArchiveID,PerformerID,WorkitemArchiveID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionArchiveID,FormInstID,FormSubject,EndDate");
		
		return approvalListObj;
	}

}
