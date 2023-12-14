package egovframework.covision.coviflow.user.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.coviflow.common.util.ComUtils;
import egovframework.covision.coviflow.user.service.UserBizDocListSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("userBizDocListSvc")
public class UserBizDocListSvcImpl extends EgovAbstractServiceImpl implements UserBizDocListSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public int selectBizDocCount(CoviMap params) throws Exception{
		return (int)coviMapperOne.getNumber("user.bizDocList.selectBizDocCount", params);
	}

	@Override
	public CoviMap selectBizDocListData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.bizDocList.selectBizDocList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "BizDocCode,BizDocName,BizDocID,UserCode"));

		return resultList;
	}

	@Override
	public CoviMap selectBizDocGroupList(CoviMap params) throws Exception {
		//
		CoviList	list = coviMapperOne.list("user.bizDocList.selectBizDoc"+params.get("clickTab")+"GroupList", params);
		CoviMap 	resultList 	= new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "fieldID,fieldCnt,fieldName"));
		return resultList;
	}

	@Override
	public CoviMap selectBizDocProcessListData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		int cnt = (int) coviMapperOne.getNumber("user.bizDocList.selectBizDocListCnt", params);
		
		CoviMap page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("user.bizDocList.selectBizDocProcessListData",params);
		
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list,"FormInstID,ProcessID,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,StartDate,EndDate,DeleteDate,ProcessState,InitiatorSIPAddress,DocSubject,Subject,BizDocFormID,BizDocID,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,SubKind,Reserved2,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10"));
		resultList.put("page", page);

		return resultList;
	}

	@Override
	public CoviMap selectBizDocCompleteLisData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		int cnt = (int) coviMapperOne.getNumber("user.bizDocList.selectBizDocCompleteListCnt", params);
		
		CoviMap page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
		params.addAll(page);

		CoviList list = coviMapperOne.list("user.bizDocList.selectBizDocCompleteListData",params);
		
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list,"FormInstID,ProcessID,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,StartDate,EndDate,DeleteDate,ProcessState,InitiatorSIPAddress,DocSubject,Subject,BizDocFormID,BizDocID,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,SubKind,Reserved2,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,DocNo"));
		resultList.put("page", page);

		return resultList;
	}

	public CoviMap selectExcelData(CoviMap params, String queryID, String headerKey) throws Exception {
		CoviList list = coviMapperOne.list("user.bizDocList."+queryID, params);
		 
		CoviMap resultList = new CoviMap();
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, headerKey));
		 
		return resultList;
	}

}
