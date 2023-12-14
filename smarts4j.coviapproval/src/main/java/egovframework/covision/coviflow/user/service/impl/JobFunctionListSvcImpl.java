package egovframework.covision.coviflow.user.service.impl;

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
import egovframework.covision.coviflow.user.service.JobFunctionListSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("jobFunctionListService")
public class JobFunctionListSvcImpl extends EgovAbstractServiceImpl implements JobFunctionListSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public int selectJobFunctionCount(CoviMap params) throws Exception{
		if(!params.containsKey("JobFunctionType")) {
			params.put("JobFunctionType", "APPROVAL");
		}
		return (int)coviMapperOne.getNumber("user.jobFunctionList.selectJobFunctionCount", params);
	}

	@Override
	public CoviMap selectJobFunctionListData(CoviMap params) throws Exception {
		if(!params.containsKey("JobFunctionType")) {
			params.put("JobFunctionType", "APPROVAL");
		}
		CoviList list = coviMapperOne.list("user.jobFunctionList.selectJobFunctionList", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "JobFunctionCode,JobFunctionName,JobFunctionMemberID,UserCode"));

		return resultList;
	}

	@Override
	public CoviMap selectJobFunctionApprovalListData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("user.jobFunctionList.selectJobFunctionApprovalListCnt", params);
 			page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			
 			resultList.put("page", page);
 		}
		
		CoviList list = coviMapperOne.list("user.jobFunctionList.selectJobFunctionApprovalList",params);
		
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list,"ProcessID,WorkItemID,TaskID,PerformerID,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,SchemaID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,FormSubKind,Created,ExtInfo,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,FormID,SchemaContext"));
		return resultList;
	}

	@Override
	public CoviMap selectJobFunctionProcessListData(CoviMap params) throws Exception {
		int cnt = (int) coviMapperOne.getNumber("user.jobFunctionList.selectJobFunctionProcessListCnt", params);

		CoviMap page = new CoviMap();
		page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
		params.addAll(page);

		CoviList list = coviMapperOne.list("user.jobFunctionList.selectJobFunctionProcessList",params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list,"ProcessID,WorkItemID,PerformerID,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,SchemaID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,FormSubKind,Created,PhotoPath,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,FormID"));
		resultList.put("cnt", cnt);
		resultList.put("page", page);

		return resultList;
	}

	@Override
	public CoviMap selectJobFunctionCompleteListData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("user.jobFunctionList.selectJobFunctionCompleteListCnt", params);
			page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			
			resultList.put("page", page);
 		}		
		
		CoviList list = coviMapperOne.list("user.jobFunctionList.selectJobFunctionCompleteList",params);
		
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list,"ProcessDescriptionID,ProcessArchiveID,WorkItemArchiveID,PerformerID,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionArchiveID,FormInstID,SchemaID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,FormSubKind,Finished,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,FormID"));
		return resultList;
	}

	@Override
	public CoviMap selectJobFunctionRejectListData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("user.jobFunctionList.selectJobFunctionRejectListCnt",params);
 			page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			
 			resultList.put("page", page);
 		}

		CoviList list = coviMapperOne.list("user.jobFunctionList.selectJobFunctionRejectList",params);

		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list,"ProcessDescriptionID,ProcessArchiveID,WorkItemArchiveID,PerformerID,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionArchiveID,FormInstID,SchemaID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,FormSubKind,Finished,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10,FormID"));
		return resultList;
	}

	@Override
	public CoviMap selectExcelData(CoviMap params, String queryID, String headerKey) throws Exception {
		CoviList list = coviMapperOne.list("user.jobFunctionList."+queryID, params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, headerKey));

		return resultList;
	}

	@Override
	public CoviMap selectJobFunctionGroupList(CoviMap params) throws Exception {
		/*params.get("clickTab")
		Approval - 미결함
		Process - 진행함
		Complete - 완료함
		Reject - 반려함 */

		String queryID = "user.jobFunctionList.selectJobFunction"+params.get("clickTab")+"GroupList";
		CoviMap 	resultList 	= new CoviMap();
		
		CoviList list = coviMapperOne.list(queryID, params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "fieldID,fieldCnt,fieldName"));

		return resultList;
	}
	
	// 전자결재 리스트 조회 조건 가져오는 메소드
	// APPROVAL, ACCOUNT 등..
	public CoviMap getApprovalListCode(CoviMap params, String businessData1) throws Exception {		
		// 통합결재에 포함되는 타 시스템 코드
		List<String> bizDataList = new ArrayList<>();

		// 전자결재 포함유무
		if(StringUtil.isBlank(businessData1) || businessData1.equalsIgnoreCase("APPROVAL")) {
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
		} else {
			params.put("isApprovalList", "N");
			bizDataList.add(businessData1);
			params.put("businessData1", businessData1);
		}
		params.put("bizDataList", bizDataList);
		
		return params;
	}
	
	@Override
	public int selectJobfunctionAuth(CoviMap params) {
		return (int) coviMapperOne.getNumber("user.jobFunctionList.selectJobfunctionAuth", params);
	}	
}
