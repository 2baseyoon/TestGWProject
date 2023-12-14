package egovframework.covision.groupware.webpart.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.groupware.webpart.service.UserApprovalListSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("userApprovalListService")
public class UserApprovalListSvcImpl extends EgovAbstractServiceImpl implements UserApprovalListSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap getUserApprovalList(CoviMap params) throws Exception {
		CoviList resultList = null;
		
		resultList = coviMapperOne.list("webpart.approval.selectApprovalList", params);
		CoviMap returnObj = new CoviMap();
		returnObj.put("list", CoviSelectSet.coviSelectJSON(resultList, "ProcessID,WorkItemID,PerformerID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,Created,FormSubKind,TaskID,ReadDate,ExtInfo,PhotoPath"));
		
		return returnObj;
	}
	
	@Override
	public CoviMap getUserProcessList(CoviMap params) throws Exception {
		CoviList resultList = null;
		
		resultList = coviMapperOne.list("webpart.approval.selectProcessList", params);
		CoviMap returnObj = new CoviMap();
		returnObj.put("list", CoviSelectSet.coviSelectJSON(resultList, "ProcessID,WorkItemID,PerformerID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,StartDate,Finished,FormSubKind,DomainDataContext,ExtInfo,PhotoPath"));
		
		return returnObj;
	}
	
	@Override
	public CoviMap getUserPreApprovalList(CoviMap params) throws Exception {
		CoviList resultList = null;
		
		resultList = coviMapperOne.list("webpart.approval.selectPreApprovalList", params);
		CoviMap returnObj = new CoviMap();
		returnObj.put("list", CoviSelectSet.coviSelectJSON(resultList, "ProcessID,WorkItemID,PerformerID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,Created,ExtInfo,PhotoPath"));
		
		return returnObj;
	}
	
	@Override
	public CoviMap getUserTCInfoList(CoviMap params) throws Exception {
		CoviList resultList = null;
		
		resultList = coviMapperOne.list("webpart.approval.selectTCInfoList", params);
		CoviMap returnObj = new CoviMap();
		returnObj.put("list", CoviSelectSet.coviSelectJSON(resultList, "CirculationBoxID,ProcessID,CirculationBoxDescriptionID,FormInstID,FormPrefix,ReceiptID,ReceiptType,ReceiptName,ReceiptDate,Kind,State,ReadDate,SenderID,SenderName,Subject,Comment,DataState,RegID,RegDate,ModID,ModDate,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,FormSubKind,SubKind,ExtInfo"));
		
		return returnObj;
	}

	@Override
	public int getApprovalListCnt(CoviMap params) throws Exception {
		int iResult = 0;
		iResult = (int)coviMapperOne.getNumber("webpart.approval.selectApprovalListCnt", params);
		return iResult;
	}
	
	@Override
	public int getProcessListCnt(CoviMap params) throws Exception {
		int iResult = 0;
		iResult = (int)coviMapperOne.getNumber("webpart.approval.selectProcessListCnt", params);
		return iResult;
	}
	
	@Override
	public int getPreApprovalListCnt(CoviMap params) throws Exception {
		int iResult = 0;
		iResult = (int)coviMapperOne.getNumber("webpart.approval.selectPreApprovalListCnt", params);
		return iResult;
	}
	
	@Override
	public int getTCInfoListCnt(CoviMap params) throws Exception {
		int iResult = 0;
		iResult = (int)coviMapperOne.getNumber("webpart.approval.selectTCInfoListCnt", params);
		return iResult;
	}
}
