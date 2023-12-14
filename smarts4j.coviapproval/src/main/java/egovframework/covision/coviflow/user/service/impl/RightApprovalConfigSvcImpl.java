package egovframework.covision.coviflow.user.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.coviflow.user.service.RightApprovalConfigSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("rightApprovalConfigService")
public class RightApprovalConfigSvcImpl extends EgovAbstractServiceImpl implements RightApprovalConfigSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap selectUserSetting(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("user.rightApprovalConfig.selectUserSetting", params);

		CoviMap resultList = new CoviMap();
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "UserCode,MultiDisplayName,DeputyCode,UseDeputy,DeputyName,DeputyFromDate,DeputyToDate,DeputyReason,DeputyOption,Alarm,ApprovalPassword,LanguageCode,UseApprovalPassWord"));

		return resultList;
	}


	@Override
	public int updateUserSetting(CoviMap params) throws Exception{
		int cnt =0;
		int totalCnt =0;
		int size = 0;
		boolean usableUser = false;

		CoviList list = coviMapperOne.list("user.rightApprovalConfig.checkUserData", params);
		size = list.size();

		if(size >= 1){
			usableUser=true; //존재하는 사용자
		}else{
			usableUser=false; //존재하지 않는 사용자
		}

		cnt = coviMapperOne.update("user.rightApprovalConfig.updateUserSettingDeputy",params);
		totalCnt += cnt;
		if(usableUser && cnt == 0){ //존재하는 사용자인데 매칭되는 common_deputy row가 없을 경우 row를 추가하고 다시 사용자 정보 update
			totalCnt+=coviMapperOne.insert("user.rightApprovalConfig.insertApprovalRow",params);
			totalCnt+=coviMapperOne.update("user.rightApprovalConfig.updateUserSettingDeputy",params);
		}

		cnt = coviMapperOne.update("user.rightApprovalConfig.updateUserSettingApproval",params);
		totalCnt += cnt;
		if(usableUser && cnt ==0){
			totalCnt+=coviMapperOne.insert("user.rightApprovalConfig.insertApprovalRow",params);
			totalCnt+=coviMapperOne.update("user.rightApprovalConfig.updateUserSettingApproval",params);
		}

		return totalCnt;
	}
	
	@Override 	// 결재함  첨부목록 조회
	public CoviList selectJFMemberID(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.rightApprovalConfig.selectJFMemberID", params);
		return CoviSelectSet.coviSelectJSON(list, "UserCode");
	}
	
	@Override 	// 결재함  첨부목록 조회
	public CoviList selectGRMemberID(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.rightApprovalConfig.selectGRMemberID", params);
		return CoviSelectSet.coviSelectJSON(list, "UserCode");
	}
	
	@Override 	//결재암호 보안대책
	public CoviMap selectApprovalPasswordPolicy(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("user.rightApprovalConfig.getDomainPolicy", params);		
		
		return map;
	}
}
