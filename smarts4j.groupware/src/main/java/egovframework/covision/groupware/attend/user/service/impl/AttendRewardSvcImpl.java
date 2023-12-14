package egovframework.covision.groupware.attend.user.service.impl;

import javax.annotation.Resource;



import egovframework.baseframework.util.json.JSONParser;
import egovframework.covision.groupware.vacation.user.service.VacationSvc;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.RedisDataUtil;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import egovframework.covision.groupware.attend.user.service.AttendRewardSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;

@Service("AttendRewardSvc")
public class AttendRewardSvcImpl extends EgovAbstractServiceImpl implements AttendRewardSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	VacationSvc vacationSvc;
	/**
	 * @Method Name : getAttendRewardList
	 * @Description : 근무제 조회
	 */
	@Override 
	public CoviMap getAttendRewardList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("attend.reward.getRewardListCnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
			params.addAll(page);
		}	
		list	= coviMapperOne.list("attend.reward.getRewardList", params);	
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList; 
	}

	/**
	 * @Method Name : getAttendRewardDetail
	 * @Description : 보상 상세정보
	 */
	@Override 
	public CoviMap getAttendRewardDetail(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("attend.reward.getRewardDetailListCnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
			params.addAll(page);
		}	
		list	= coviMapperOne.list("attend.reward.getRewardDetailList", params);	
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList; 
	}

	@Override 
	public CoviList getAttendRewardInfo(CoviMap params) throws Exception {
		return coviMapperOne.list("attend.adminSetting.getRewardVacList", params);	
	}

	
	public int createAttendReward(CoviMap reqMap, List objList) throws Exception {
		int cnt = 0;
		String CreateMethod = "F";
		CoviMap req = new CoviMap();
		req.put("CompanyCode", reqMap.get("CompanyCode").toString());
		req.put("getName", "CreateMethod");
		try{
			CreateMethod = vacationSvc.getVacationConfigVal(req);
		} catch (NullPointerException e) {
			CreateMethod = "F";
		} catch (Exception e) {
			CreateMethod = "F";
		}
		if(CreateMethod==null || CreateMethod.equals("")){
			CreateMethod = "F";
		}
		for(int i=0; i<objList.size(); i++){
			Map dataMap = (Map)objList.get(i);

			dataMap.put("Year", ((String)dataMap.get("RewardMonth")).substring(0,4));
			dataMap.put("ApprovalStatus", "Approval");
			dataMap.put("ApprovalCode", reqMap.get("ApprovalCode"));
			dataMap.put("ApprovalComment", reqMap.get("ApprovalComment"));
			dataMap.put("VacKind", "VACATION_REWARD");
			dataMap.put("DeptCode", reqMap.get("DeptCode"));
			dataMap.put("DeptName", reqMap.get("DeptName"));

			if(CreateMethod.equals("J")){
				coviMapperOne.update("attend.reward.insertAttendRewardV2", dataMap);
			}else {
				coviMapperOne.update("attend.reward.insertAttendReward", dataMap);
			}
			cnt += coviMapperOne.update("attend.reward.insertAttendRewardHistory", dataMap); 
		}

		return cnt;
	}

	public int cancelAttendReward (CoviMap reqMap, List objList) throws Exception {
		int cnt = 0;
		for(int i=0; i<objList.size(); i++){
			Map dataMap = (Map)objList.get(i);
			
			dataMap.put("Year", ((String)dataMap.get("RewardMonth")).substring(0,4));
			dataMap.put("ApprovalStatus", "Reject");
			dataMap.put("RewardDay", 0);
			dataMap.put("ApprovalCode", reqMap.get("ApprovalCode"));
			dataMap.put("ApprovalComment", reqMap.get("ApprovalComment"));
			cnt+=coviMapperOne.update("attend.reward.insertAttendRewardHistory", dataMap); 
		}

		return cnt;
	}
	
}
